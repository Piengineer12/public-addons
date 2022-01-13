net.Receive("rotgb_statchanged", function()
	local func = net.ReadUInt(4)
	if func == RTG_STAT_POPS then
		for i=1,net.ReadUInt(12) do
			local ply = net.ReadEntity()
			if IsValid(ply) then
				ply.rtg_gBalloonPops = net.ReadDouble()
				ply.rtg_XP = net.ReadDouble()
			end
		end
	elseif func == RTG_STAT_INIT then
		local ply = net.ReadEntity()
		if IsValid(ply) then
			ply.rtg_PreviousXP = net.ReadDouble()
			if ply == LocalPlayer() then
				hook.Run("SetNextSave", RealTime())
			end
		end
	elseif func == RTG_STAT_VOTES then
		local voteWindow = hook.Run("GetVoterMenu")
		if IsValid(voteWindow) then
			local yes = net.ReadUInt(8)
			local no = net.ReadUInt(8)
			voteWindow:SetValues(yes, no)
		end
	end
end)

net.Receive("rotgb_gamemode", function()
	local operation = net.ReadUInt(4)
	if operation == RTG_OPERATION_GAMEOVER then
		hook.Run("GameOver", net.ReadBool())
	elseif operation == RTG_OPERATION_DIFFICULTY then
		hook.Run("SetDifficulty", net.ReadString())
	elseif operation == RTG_OPERATION_VOTESTART then
		local compiledVote = {}
		compiledVote.initiator = Player(net.ReadInt(16))
		compiledVote.expiry = net.ReadFloat()
		compiledVote.startTime = net.ReadFloat()
		compiledVote.typ = net.ReadUInt(4)
		compiledVote.target = net.ReadString()
		compiledVote.reason = net.ReadString()
		compiledVote.agrees = 0
		compiledVote.disagrees = 0
		hook.Run("StartVote", compiledVote)
	elseif operation == RTG_OPERATION_VOTEEND then
		local result = net.ReadUInt(4)
		local voteWindow = hook.Run("GetVoterMenu")
		if IsValid(voteWindow) then
			voteWindow:ApplyResult(hook.Run("GetCurrentVote"), result)
		end
	elseif operation == RTG_OPERATION_SKILLS then
		local ply = LocalPlayer()
		local isForSelf = net.ReadBool()
		local amount = net.ReadUInt(2)
		if amount == RTG_SKILL_CLEAR or amount == RTG_SKILL_MULTIPLE and not isForSelf then
			if isForSelf then
				ply:RTG_ClearSkills()
			else
				hook.Run("ClearAppliedSkills")
			end
		end
		if amount ~= RTG_SKILL_CLEAR then
			if amount == RTG_SKILL_ONE then
				amount = 1
			elseif amount == RTG_SKILL_MULTIPLE then
				amount = net.ReadUInt(12)+1
			end
			if isForSelf then
				local skills = {}
				for i=1,amount do
					skills[net.ReadUInt(12)+1] = true
				end
				ply:RTG_AddSkills(skills)
			else
				skillsToApply = {}
				for i=1,amount do
					local skill = net.ReadUInt(12)+1
					skillsToApply[skill] = true
				end
				hook.Run("AddAppliedSkills", skillsToApply)
			end
		end
	end
end)