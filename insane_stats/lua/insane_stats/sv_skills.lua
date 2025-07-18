local savedPlayerSkills, savedPlayerSealedSkills
local skillEntities = {}
for k,v in pairs(ents.GetAll()) do
	if v.insaneStats_Skills then
		skillEntities[v] = true
	end
end

function InsaneStats:GetEntitiesWithSkills()
	for k,v in pairs(skillEntities) do
		if not IsValid(k) then
			skillEntities[k] = nil
		end
	end
	return skillEntities
end

function InsaneStats:SetEntityAsContainingSkills(ent)
	if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
		skillEntities[ent] = true
	else
		error(string.format("%s cannot be marked as having skills!", tostring(ent)))
	end
end

AccessorFunc(InsaneStats, "SkillDataToNetwork", "SkillDataToNetwork")

hook.Add("InsaneStatsSave", "InsaneStatsSkills", function(data)
	if InsaneStats:GetConVarValue("skills_enabled") and InsaneStats:GetConVarValue("skills_save") and savedPlayerSkills then
		for i,v in player.Iterator() do
			local steamID = v:SteamID()
            local skills = v:InsaneStats_GetSkills()
			if steamID and skills then
				savedPlayerSkills[steamID] = skills
				savedPlayerSealedSkills[steamID] = v:InsaneStats_GetSealedSkills()
			end
		end
		data.playerSkills = savedPlayerSkills
		data.playerSealedSkills = savedPlayerSealedSkills
		data.disabledSkills = InsaneStats:GetDisabledSkills()
	end
end)

local function ReloadSkills()
	local fileContent = InsaneStats:Load()
	savedPlayerSkills = fileContent.playerSkills or {}
	savedPlayerSealedSkills = fileContent.playerSealedSkills or {}
	InsaneStats:SetDisabledSkills(fileContent.disabledSkills)
end

ReloadSkills()

hook.Add("InitPostEntity", "InsaneStatsSkills", function()
	ReloadSkills()
end)

hook.Add("PlayerSpawn", "InsaneStatsSkills", function(ply, fromTransition)
	if fromTransition then
		ply:InsaneStats_SetSkills(nil)
		ply:InsaneStats_SetSealedSkills(nil)
	end
	
	if not ply.insaneStats_Skills and InsaneStats:GetConVarValue("skills_save") then
		local skills = savedPlayerSkills[ply:SteamID()] or {}
		ply:InsaneStats_SetSkills(skills)
		skills = savedPlayerSealedSkills[ply:SteamID()] or {}
		ply:InsaneStats_SetSealedSkills(skills)
	end
end)

hook.Add("InsaneStatsSkillsChanged", "InsaneStatsSkills", function(ent)
	InsaneStats:SetEntityAsContainingSkills(ent)
end)

timer.Create("InsaneStatsSkills", 0, 0, function()
	if not InsaneStats:GetSkillDataToNetwork() then
		InsaneStats:SetSkillDataToNetwork({})
	end

	for k,v in pairs(InsaneStats:GetSkillDataToNetwork()) do
		if k:IsPlayer() then
			net.Start("insane_stats")
			net.WriteUInt(8, 8)

			local data = {}
			for k2,v2 in pairs(v) do
				local skillData = k:InsaneStats_GetSkillData(k2)
		
				table.insert(data, {
					id = InsaneStats:GetSkillID(k2),
					state = skillData.state or -2,
					stacks = skillData.stacks or 0,
					updateTime = skillData.updateTime or CurTime()
				})
			end
			
			net.WriteUInt(#data, 16)
			for i,v2 in ipairs(data) do
				net.WriteUInt(v2.id or 0, 16)
				net.WriteInt(v2.state, 4)
				net.WriteDouble(v2.stacks)
				net.WriteFloat(v2.updateTime)
			end

			net.Send(k)
		end
	end

	InsaneStats:SetSkillDataToNetwork({})
end)