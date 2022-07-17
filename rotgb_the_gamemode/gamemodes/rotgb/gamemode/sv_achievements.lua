AccessorFunc(GM, "PlayerStatsRequireUpdates", "PlayerStatsRequireUpdates")
local nextUpdate = 0

function GM:PlayerAchievementStatChanged(ply, stat, oldValue, newValue)
	for k,v in pairs(hook.Run("GetAchievementsByStat", stat)) do
		if oldValue < v.amount and newValue >= v.amount then
			net.Start("rotgb_gamemode")
			net.WriteUInt(RTG_OPERATION_ACHIEVEMENT, 4)
			net.WriteUInt(v.id-1, 16)
			net.WriteInt(ply:UserID(), 12)
			net.Broadcast()
			
			if (v.reward or 0) == 0 then
				ply.rtg_XP = (ply.rtg_XP or 0) + (v.xp or 0)
				ply:RTG_SetStat("level", ply:RTG_GetLevel())
				net.Start("rotgb_statchanged", true)
				net.WriteUInt(RTG_STAT_POPS, 4)
				net.WriteUInt(1, 12)
				net.WriteEntity(ply)
				net.WriteDouble(ply.rtg_gBalloonPops or 0)
				net.WriteDouble(ply.rtg_XP)
				net.Send(ply)
				hook.Run("SetStatRebroadcastRequired", true)
			end
		end
	end
	
	local statUpdates = hook.Run("GetPlayerStatsRequireUpdates") 
	statUpdates[ply] = statUpdates[ply] or {}
	statUpdates[ply][stat] = ply:RTG_GetStat(stat)
end

function GM:StatisticsThink()
	local statUpdates = hook.Run("GetPlayerStatsRequireUpdates") 
	if RealTime() > nextUpdate and next(statUpdates) then
		nextUpdate = RealTime() + self.NetSendInterval
		for k,v in pairs(statUpdates) do
			net.Start("rotgb_statchanged")
			net.WriteUInt(RTG_STAT_ACHIEVEMENTS, 4)
			net.WriteUInt(table.Count(v), 16)
			for k2,v2 in pairs(v) do
				net.WriteUInt(k2-1, 16)
				net.WriteDouble(v2)
			end
			net.Send(k)
		end
	end
end

local PLAYER = FindMetaTable("Player")
function PLAYER:_RTG_SetStat(stat, amount)
	local difficultyNotCustom = not hook.Run("GetDifficulties")[hook.Run("GetDifficulty")].custom
	if not hook.Run("GetGameIsOver") and difficultyNotCustom or GAMEMODE.DebugMode then
		local stats = hook.Run("GetStatisticAmounts")
		
		local plyStats = stats[self]
		if not plyStats then
			stats[self] = {}
			plyStats = stats[self]
		end
		
		local oldValue = plyStats[stat] or 0
		if oldValue < amount then
			plyStats[stat] = amount
			hook.Run("PlayerAchievementStatChanged", self, stat, oldValue, amount)
		end
	end
end

function PLAYER:_RTG_AddStat(stat, amount)
	local difficultyNotCustom = not hook.Run("GetDifficulties")[hook.Run("GetDifficulty")].custom
	if not hook.Run("GetGameIsOver") and difficultyNotCustom or GAMEMODE.DebugMode then
		local stats = hook.Run("GetStatisticAmounts")
		
		local plyStats = stats[self]
		if not plyStats then
			stats[self] = {}
			plyStats = stats[self]
		end
		
		local oldValue = plyStats[stat] or 0
		if oldValue < math.huge then
			local newValue = oldValue + amount
			plyStats[stat] = newValue
			hook.Run("PlayerAchievementStatChanged", self, stat, oldValue, newValue)
		end
	end
end

function PLAYER:_RTG_GetStat(stat)
	local stats = hook.Run("GetStatisticAmounts")
	return stats[self] and stats[self][stat] or 0
end