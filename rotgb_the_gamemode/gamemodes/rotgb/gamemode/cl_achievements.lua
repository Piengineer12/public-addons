function GM:IsAchievementUnlocked(id)
	local achievement = hook.Run("GetAchievements")[id]
	return LocalPlayer():RTG_GetStat(achievement.criteria) >= achievement.amount
end

function GM:GetStatisticsSaveTable()
	local saveTable = {}
	
	for k,v in pairs(hook.Run("GetStatistics")) do
		saveTable[v] = math.min(LocalPlayer():RTG_GetStat(k), 1.797693e308)
	end
	
	return saveTable
end

function GM:LoadStatistics(nameAmounts)
	local idAmounts = {}
	
	for k,v in pairs(nameAmounts or {}) do
		local id = hook.Run("GetStatisticID", k)
		if id then
			idAmounts[id] = v
		end
	end
	
	hook.Run("SetStatisticAmounts", idAmounts)
	return idAmounts
end

local PLAYER = FindMetaTable("Player")

function PLAYER:_RTG_SetStat(stat, amount)
	local stats = hook.Run("GetStatisticAmounts")
	local oldValue = stats[stat] or 0
	
	if oldValue < amount then
		stats[stat] = amount
		hook.Run("PlayerAchievementStatChanged", self, stat, oldValue, amount)
	end
end

function PLAYER:_RTG_AddStat(stat, amount)
	local stats = hook.Run("GetStatisticAmounts")
	local oldValue = stats[stat] or 0

	if oldValue < math.huge then
		local newValue = stats[stat] + amount
		stats[stat] = newValue
		hook.Run("PlayerAchievementStatChanged", self, stat, oldValue, newValue)
	end
end

function PLAYER:_RTG_GetStat(stat)
	return hook.Run("GetStatisticAmounts")[stat] or 0
end

concommand.Add("rotgb_tg_achievements", function()
	hook.Run("ShowAchievementsMenu")
end, nil, "Opens the RotgB: The Gamemode! achievements menu.")