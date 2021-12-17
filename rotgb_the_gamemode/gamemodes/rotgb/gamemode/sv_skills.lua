function GM:ReadSkillMessage(ply)
	local amount = net.ReadUInt(2)
	if amount == RTG_SKILL_CLEAR then
		ply:RTG_ClearSkills()
	else
		if amount == RTG_SKILL_ONE then
			amount = 1
		elseif amount == RTG_SKILL_MULTIPLE then
			amount = net.ReadUInt(12)+1 -- max is 4,096
		end
		if amount <= ply:RTG_GetSkillPoints() then
			local skills = {}
			for i=1,amount do
				local skill = net.ReadUInt(12)+1
				if hook.Run("GetSkills")[skill] and not ply:RTG_HasSkill(skill) then
					skills[skill] = true
				end
			end
			if next(skills) then
				ply:RTG_AddSkills(skills)
			end
		end
	end
end

function GM:PlayerAddSkills(ply, skillIDs)
	local appliedSkills = hook.Run("GetAppliedSkills")
	local appliedSkillsToAdd = {}
	for k,v in pairs(skillIDs) do
		if not appliedSkills[k] then
			appliedSkillsToAdd[k] = v
		end
	end
	hook.Run("AddAppliedSkills", appliedSkillsToAdd)
	
	net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_SKILLS, 4)
	net.WriteBool(true)
	if next(skillIDs, next(skillIDs)) then
		net.WriteUInt(RTG_SKILL_MULTIPLE, 2)
		net.WriteUInt(table.Count(skillIDs)-1, 12)
		for k,v in pairs(skillIDs) do
			net.WriteUInt(k-1, 12)
		end
	else
		net.WriteUInt(RTG_SKILL_ONE, 2)
		net.WriteUInt(next(skillIDs)-1, 12)
	end
	net.Send(ply)
	
	local nextKey = next(appliedSkillsToAdd)
	if nextKey then
		net.Start("rotgb_gamemode")
		net.WriteUInt(RTG_OPERATION_SKILLS, 4)
		net.WriteBool(false)
		if next(appliedSkillsToAdd, nextKey) then
			net.WriteUInt(RTG_SKILL_MULTIPLE, 2)
			net.WriteUInt(table.Count(appliedSkillsToAdd)-1, 12)
			for k,v in pairs(appliedSkillsToAdd) do
				net.WriteUInt(k-1, 12)
			end
		else
			net.WriteUInt(RTG_SKILL_ONE, 2)
			net.WriteUInt(nextKey-1, 12)
		end
		net.Broadcast()
	end
end

function GM:PlayerClearSkills(ply)
	local appliedSkills = {}
	local plys = player.GetAll()
	for k,v in pairs(hook.Run("GetSkills")) do
		for k2,v2 in pairs(plys) do
			if v2:RTG_HasSkill(k) then
				appliedSkills[k2] = v2 break
			end
		end
	end
	hook.Run("SetAppliedSkills", appliedSkills)
	
	net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_SKILLS, 4)
	net.WriteBool(true)
	net.WriteUInt(RTG_SKILL_CLEAR, 2)
	net.Send(ply)
	
	net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_SKILLS, 4)
	net.WriteBool(false)
	if next(appliedSkills) then
		net.WriteUInt(RTG_SKILL_MULTIPLE, 2)
		net.WriteUInt(table.Count(appliedSkills)-1, 12)
		for k,v in pairs(appliedSkills) do
			net.WriteUInt(k-1, 12)
		end
	else
		net.WriteUInt(RTG_SKILL_CLEAR, 2)
	end
	net.Broadcast()
end

-- defined in rotgb_general.lua
function GM:GetStartingRotgBCash()
	return 650 + hook.Run("GetSkillAmount", "startingCash")
end

-- defined in gballoon_spawner.lua
function GM:gBalloonSpawnerPrespawn(bln, keyValues)
	if tobool(keyValues.BalloonBlimp) then
		local outerCashBonus = (tonumber(keyValues.BalloonCashBonus) or 0) + (tonumber(keyValues.BalloonHealth) or 1) * hook.Run("GetSkillAmount", "gBlimpOuterHealthCash")/100
		bln:SetKeyValue("BalloonCashBonus",outerCashBonus)
	end
	bln:SetKeyValue("BalloonMoveSpeed", (tonumber(keyValues.BalloonMoveSpeed) or 100)*(1+hook.Run("GetSkillAmount", "gBalloonSpeed")/100))
end