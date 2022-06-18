util.AddNetworkString("rotgb_statchanged")
util.AddNetworkString("rotgb_gamemode")

net.Receive("rotgb_statchanged", function(length, ply)
	if IsValid(ply) then
		local func = net.ReadUInt(4)
		if func == RTG_STAT_INIT then
			if not ply.rtg_XP then
				hook.Run("InitializePlayer", ply)
			end
			if not ply.rtg_PreviousXP then
				-- update our values
				ply.rtg_PreviousXP = net.ReadDouble()
				hook.Run("ReadSkillMessage", ply)
				
				local plyStats = {}
				for i=1,net.ReadUInt(16) do
					local stat = net.ReadUInt(16)+1
					plyStats[stat] = net.ReadDouble()
				end
				hook.Run("GetStatisticAmounts")[ply] = plyStats
				hook.Run("GetPlayerStatsRequireUpdates")[ply] = plyStats
				
				-- send updated values to players
				net.Start("rotgb_statchanged")
				net.WriteUInt(RTG_STAT_INIT, 4)
				net.WriteEntity(ply)
				net.WriteDouble(ply.rtg_PreviousXP)
				net.Broadcast()
				
				-- send current values to player
				local plys = player.GetAll()
				net.Start("rotgb_statchanged")
				net.WriteUInt(RTG_STAT_FULLUPDATE, 4)
				net.WriteUInt(#plys, 12)
				for k,v in pairs(plys) do
					net.WriteInt(v:UserID(), 16)
					net.WriteDouble(v.rtg_gBalloonPops)
					net.WriteDouble(v.rtg_PreviousXP)
					net.WriteDouble(v.rtg_XP)
				end
				net.Send(ply)
				
				local appliedSkills = hook.Run("GetAppliedSkills")
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
				net.Send(ply)
				
				net.Start("rotgb_gamemode")
				net.WriteUInt(RTG_OPERATION_ONESHOT, 4)
				hook.Run("SendMapDifficulties")
				net.Send(ply)
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

local achievementAllSuccessAlreadyDonePlayers = {}
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
		hook.Run("ReadSkillMessage", ply)
	elseif operation == RTG_OPERATION_MAPS then
		local mapNames = {}
		for i,v in ipairs(file.Find("maps/*.bsp","GAME")) do
			if string.sub(v, 1, 6) == "rotgb_" then
				table.insert(mapNames, string.sub(v, 1, -5))
			end
		end
		
		net.Start("rotgb_gamemode")
		net.WriteUInt(RTG_OPERATION_MAPS, 4)
		net.WriteUInt(#mapNames, 16)
		for i,v in ipairs(mapNames) do
			net.WriteString(v)
		end
		net.Send(ply)
	elseif operation == RTG_OPERATION_ACHIEVEMENT then
		local statID = net.ReadUInt(16)+1
		if statID == hook.Run("GetStatisticID", "success.all") and hook.Run("GetGameIsOver") and not achievementAllSuccessAlreadyDonePlayers[ply:SteamID()] then
			hook.Run("SetGameIsOver", false)
			ply:RTG_SetStat(statID, net.ReadDouble())
			hook.Run("SetGameIsOver", true)
			achievementAllSuccessAlreadyDonePlayers[ply:SteamID()] = true
		end
	end
end)

