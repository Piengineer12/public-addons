util.AddNetworkString("rotgb_statchanged")
util.AddNetworkString("rotgb_gamemode")

net.Receive("rotgb_statchanged", function(length, ply)
	if IsValid(ply) then
		local func = net.ReadUInt(4)
		if func == RTG_STAT_INITEXP then
			if not ply.rtg_PreviousXP then
				ply.rtg_PreviousXP = net.ReadDouble()
				net.Start("rotgb_statchanged", true)
				net.WriteUInt(RTG_STAT_INITEXP, 4)
				net.WriteEntity(ply)
				net.WriteDouble(ply.rtg_PreviousXP)
				net.Broadcast()
			end
		elseif func == RTG_STAT_VOTES then
			local currentVote = hook.Run("GetCurrentVote")
			if (currentVote and currentVote.expiry>=RealTime()) then
				local changed = hook.Run("AddToCurrentVote", ply, net.ReadBool())
				if changed then
					hook.Run("SyncCurrentVote")
				end
			end
		end
	end
end)

net.Receive("rotgb_gamemode", function(length, ply)
	local operation = net.ReadUInt(4)
	if operation == RTG_OPERATION_GAMEOVER and hook.Run("GetGameIsOver") then
		hook.Run("CleanUpMap")
	elseif operation == RTG_OPERATION_DIFFICULTY and ply:IsAdmin() then
		hook.Run("ChangeDifficulty", net.ReadString())
	elseif operation == RTG_OPERATION_VOTESTART then
		local typ = net.ReadUInt(4)
		local target = net.ReadString()
		local reason = net.ReadString()
		hook.Run("StartVote", ply, typ, target, reason)
	elseif operation == RTG_OPERATION_SKILLS then
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
end)

