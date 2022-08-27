net.Receive("rotgb_statchanged", function()
	local func = net.ReadUInt(4)
	if func == RTG_STAT_POPS then
		for i=1,net.ReadUInt(12) do
			local ply = net.ReadEntity()
			if IsValid(ply) then
				ply.rtg_gBalloonPops = net.ReadDouble()
				ply.rtg_XP = net.ReadDouble()
				ply.rtg_CashGenerated = net.ReadDouble()
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
	elseif func == RTG_STAT_FULLUPDATE then
		for i=1,net.ReadUInt(12) do
			local ply = Player(net.ReadInt(16))
			if IsValid(ply) then
				ply.rtg_gBalloonPops = net.ReadDouble()
				ply.rtg_PreviousXP = net.ReadDouble()
				ply.rtg_XP = net.ReadDouble()
				ply.rtg_CashGenerated = net.ReadDouble()
			end
		end
	elseif func == RTG_STAT_ACHIEVEMENTS then
		for i=1,net.ReadUInt(16) do
			local stat = net.ReadUInt(16)+1
			LocalPlayer():RTG_SetStat(stat, net.ReadDouble())
		end
	end
end)

local color_yellow = Color(255,255,0)
local color_light_orange = Color(255,191,127)
local color_light_green = Color(127,255,127)
local color_light_blue = Color(127,127,255)
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
		
		-- RealTime() is not synchronized, so force it to be in sync
		compiledVote.expiry = compiledVote.expiry - compiledVote.startTime + RealTime()
		compiledVote.startTime = RealTime()
		
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
	elseif operation == RTG_OPERATION_MAPS then
		local receivedMaps = {}
		for i=1,net.ReadUInt(16) do
			table.insert(receivedMaps, net.ReadString())
		end
		
		hook.Run("SetMapTable", receivedMaps)
		if IsValid(hook.Run("GetVoteMenu")) then
			hook.Run("GetVoteMenu"):UpdateRightPanel(RTG_VOTE_MAP)
		end
	elseif operation == RTG_OPERATION_TEAM then
		local suboperation = net.ReadUInt(4)
		if suboperation == RTG_TEAM_WAIT then
			chat.AddText(unpack(ROTGB_LocalizeMulticoloredString(
				"rotgb_tg.teams.too_fast",
				{string.format("%.2f", net.ReadFloat())},
				color_white,
				{color_yellow}
			)))
		elseif suboperation == RTG_TEAM_SAME then
			chat.AddText(color_white, "#rotgb_tg.teams.already_on_team")
		elseif suboperation == RTG_TEAM_INVALID then
			chat.AddText(color_white, "#rotgb_tg.teams.invalid_team")
		elseif suboperation == RTG_TEAM_REJECTED then
			chat.AddText(color_white, "#rotgb_tg.teams.rejected_from_team")
		elseif suboperation == RTG_TEAM_CHANGED then
			local ply = Player(net.ReadUInt(16))
			local oldTeam = net.ReadInt(32)
			local newTeam = net.ReadInt(32)
			
			if oldTeam == TEAM_UNASSIGNED then
				chat.AddText(unpack(ROTGB_LocalizeMulticoloredString(
					"rotgb_tg.teams.joined",
					{ply:Nick(), hook.Run("GetTeamName", newTeam)},
					color_white,
					{team.GetColor(oldTeam), team.GetColor(newTeam)}
				)))
			else
				chat.AddText(unpack(ROTGB_LocalizeMulticoloredString(
					"rotgb_tg.teams.joined_from",
					{ply:Nick(), hook.Run("GetTeamName", oldTeam), hook.Run("GetTeamName", newTeam)},
					color_white,
					{team.GetColor(oldTeam), team.GetColor(oldTeam), team.GetColor(newTeam)}
				)))
			end
		end
	elseif operation == RTG_OPERATION_ACHIEVEMENT then
		local achievementID = net.ReadUInt(16)+1
		local ply = Player(net.ReadInt(12))
		
		if IsValid(ply) then
			local achievement = hook.Run("GetAchievementByID", achievementID)
			local tierColor = achievement.tier == 3 and color_light_orange or achievement.tier == 2 and color_light_blue or color_light_green
			local rewardText = ""
			local rewardType = achievement.reward or 0
			if rewardType == 0 then
				rewardText = ROTGB_LocalizeString("rotgb_tg.achievement.unlocked.player.reward.xp", ROTGB_Commatize(achievement.xp))
			elseif rewardType == 1 then
				rewardText = language.GetPhrase("rotgb_tg.achievement.unlocked.player.reward.skills")
			end
			chat.AddText(unpack(ROTGB_LocalizeMulticoloredString(
				"rotgb_tg.achievement.unlocked.player",
				{
					ply:Nick(),
					language.GetPhrase("rotgb_tg.achievement."..achievement.name..".name"),
					rewardText
				},
				color_white,
				{
					team.GetColor(ply:Team()),
					tierColor,
					color_light_green
				}
			)))
		end
	elseif operation == RTG_OPERATION_ONESHOT then
		hook.Run("ReceiveMapDifficulties")
	end
end)