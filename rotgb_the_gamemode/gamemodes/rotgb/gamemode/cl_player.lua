function GM:LoadClient()
	local data = util.JSONToTable(file.Read("rotgb_tg_data.dat", "DATA") or "")
	if data then
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
		
		net.SendToServer()
		
		hook.Run("SetCompletedDifficulties", data.completedDifficulties or {})
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
	file.Write("rotgb_tg_data.dat", util.TableToJSON(data))
end

local color_aqua = Color(0, 255, 255)
function GM:OnPlayerChat(ply, message, bTeam, bDead)
    if ply ~= LocalPlayer() then return end
	local loweredMessage = message:lower()
	if loweredMessage == "!help" or loweredMessage == "!rtg_help" then
		chat.AddText(color_white, language.GetPhrase("rotgb_tg.help"))
		for i=1, 6 do
			local arguments = {
				language.GetPhrase(string.format("rotgb_tg.help.entry.%i.%i", i, 1)),
				language.GetPhrase(string.format("rotgb_tg.help.entry.%i.%i", i, 2)),
				language.GetPhrase(string.format("rotgb_tg.help.entry.%i.%i", i, 3))
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