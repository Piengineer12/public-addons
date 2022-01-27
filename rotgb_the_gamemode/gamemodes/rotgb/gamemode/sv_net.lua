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
				ply.rtg_PreviousXP = net.ReadDouble()
				hook.Run("ReadSkillMessage", ply)
				net.Start("rotgb_statchanged")
				net.WriteUInt(RTG_STAT_INIT, 4)
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
	end
end)

