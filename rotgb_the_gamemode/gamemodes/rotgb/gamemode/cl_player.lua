function GM:LoadClient()
	local data = util.JSONToTable(file.Read("rotgb_tg_data.dat", "DATA") or "")
	if not data then
		data = util.JSONToTable(file.Read("rotgb_tg_data.bak.dat", "DATA") or "")
	end
	if data then
		hook.Run("PerformLoadFixups", data)
		
		local ply = LocalPlayer()
		ply.rtg_PreviousXP = tonumber(data.xp) or 0
		local skills = data.skills
		
		net.Start("rotgb_statchanged")
		
		net.WriteUInt(RTG_STAT_INIT, 4)
		net.WriteDouble(ply.rtg_PreviousXP)
		
		if (skills and next(skills)) then
			
			local validatedSkills = {}
			local skillsToAdd = {}
			local skillNames = hook.Run("GetSkillNames")
			for k,v in pairs(skills) do
				local id = skillNames[k]
				if id then
					table.insert(validatedSkills, id-1)
					skillsToAdd[id] = v
				end
			end
			ply:RTG_AddSkills(skillsToAdd)
			
			net.WriteUInt(RTG_SKILL_MULTIPLE, 2)
			net.WriteUInt(#validatedSkills-1, 12)
			
			for k,v in pairs(validatedSkills) do
				net.WriteUInt(v, 12)
			end
		else
			net.WriteUInt(RTG_SKILL_CLEAR, 2)
		end
		
		local statisticAmounts = hook.Run("LoadStatistics", data.statsitics)
		net.WriteUInt(#statisticAmounts, 16)
		for k,v in pairs(statisticAmounts) do
			net.WriteUInt(k-1, 16)
			net.WriteDouble(v)
		end
		
		hook.Run("SetCompletedDifficulties", data.completedDifficulties or {})
		
		-- figure out if the Nightmare difficulty has been beaten
		local nightmareBeaten = false
		for k,v in pairs(hook.Run("GetCompletedDifficulties")) do
			for k2,v2 in pairs(v) do
				if v2 and k2 == "special_nightmare" then
					nightmareBeaten = true break
				end
			end
			if nightmareBeaten then break end
		end
		
		net.WriteBool(nightmareBeaten)
		
		net.SendToServer()
	end
end

function GM:PerformLoadFixups(data)
	if data and not data.savefileVersion then
		if (data.statsitics["success.no_score"] or 0 >= 1) then
			data.xp = (data.xp or 0) + 8.5e6
		end
	end
end

function GM:SaveClient()
	local ply = LocalPlayer()
	local plySkills = ply:RTG_GetSkills()
	local data = {}
	data.xp = ply:RTG_GetExperience()
	data.skills = {}
	for k,v in pairs(hook.Run("GetSkillNames")) do
		if ply:RTG_HasSkill(v) then
			data.skills[k] = plySkills[v]
		end
	end
	data.completedDifficulties = hook.Run("GetCompletedDifficulties")
	data.statsitics = hook.Run("GetStatisticsSaveTable")
	data.savefileVersion = 2
	
	local jsonData = util.TableToJSON(data)
	file.Write("rotgb_tg_data.dat", jsonData)
	timer.Simple(5, function()
		file.Write("rotgb_tg_data.bak.dat", jsonData)
	end)
end

local color_aqua = Color(0, 255, 255)
function GM:OnPlayerChat(ply, message, bTeam, bDead)
    if ply ~= LocalPlayer() then return end
	local loweredMessage = message:lower()
	if loweredMessage == "!help" or loweredMessage == "!rtg_help" then
		chat.AddText(color_white, ROTGB_LocalizeString("rotgb_tg.help"))
		for i=1, 8 do
			local arguments = {
				ROTGB_LocalizeString(string.format("rotgb_tg.help.entry.%i.%i", i, 1)),
				ROTGB_LocalizeString(string.format("rotgb_tg.help.entry.%i.%i", i, 2)),
				ROTGB_LocalizeString(string.format("rotgb_tg.help.entry.%i.%i", i, 3))
			}
			chat.AddText(unpack(ROTGB_LocalizeMulticoloredString(
				"rotgb_tg.help.entry",
				arguments,
				color_white,
				{color_aqua, color_aqua, color_white}
			)))
		end
		return true
	end
	return false
end

function GM:PlayerBindPress(ply, bind, pressed, code)
	-- if the PhysGun is active and the player is holding ATTACK, do not care about weapon selection
	local wep = ply:GetActiveWeapon()
	local shouldIgnore = IsValid(wep) and wep:GetClass() == "weapon_physgun" and ply:KeyDown(IN_ATTACK)
	
	--[[ invnext match:
	invnext
	invnext allen
	invnext invprev
	;;; invnext ;;;
	p2p; lump; invnext; invprev
	
	what shouldn't match:
	q invnext
	invprev invnext
	
	need to match:
	invnext, invprev, slotX
	]]
	if not (GetConVar("hud_fastswitch"):GetBool() or shouldIgnore) then
		for command in string.gmatch(';'..bind, ";%s*(%w+)") do
			if pressed and (command == "invnext" or command == "invprev" or string.match(command, "^slot%d+$")) then
				hook.Run("ProcessWeaponBind", command)
				return true
			end
		end
	end
end

local suppressAttack, suppressAttack2 = false, false
function GM:CreateMove(usercmd)
	if not GetConVar("hud_fastswitch"):GetBool() then
		if usercmd:KeyDown(IN_ATTACK) then
			if hook.Run("ProcessWeaponBind", "attack") then
				suppressAttack = true
			end
			if suppressAttack then
				usercmd:RemoveKey(IN_ATTACK)
			end
		else
			suppressAttack = false
		end
		if usercmd:KeyDown(IN_ATTACK2) then
			if hook.Run("ProcessWeaponBind", "attack2") then
				suppressAttack2 = true
			end
			if suppressAttack2 then
				usercmd:RemoveKey(IN_ATTACK2)
			end
		else
			suppressAttack2 = false
		end
	end
end