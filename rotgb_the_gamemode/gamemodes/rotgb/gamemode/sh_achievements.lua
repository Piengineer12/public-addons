GM.BaseAchievements = {
	--[[ xp reference amounts:
	25,000 = level 25+
	100,000 = level 50+
	500,000 = level 100+
	1,500,000 = level 200+
	10,000,000 = level 500+
	
	50,000,000 = level 1,000+
	250,000,000 = level 2,500+
	999,999,999 = level 5,000+
	
	ideas:
	One of a Kind - win an Impossible+ game with only one of each tower ever placed
	All for One and One for One - Win a Hard+ game with only 1 tower on the map at any one time
	activate 3/10/30 abilities at once
	
	pop X Ceramic/Brick/Marble gBalloons
	pop X Y gBlimps
	pop X Fast/Hidden/Regen/Shielded gBalloons
	]]
	
	{name="popper1", tier=1, amount=1e3, criteria="pops", xp=500},
	{name="popper2", tier=2, amount=1e5, criteria="pops", xp=25e3},
	{name="popper3", tier=3, amount=1e7, criteria="pops", xp=500e3},
	{name="damage1", tier=1, amount=1e4, criteria="damage", xp=1000},
	{name="damage2", tier=2, amount=1e6, criteria="damage", xp=100e3},
	{name="damage3", tier=3, amount=1e8, criteria="damage", xp=1.5e6},
	
	{name="level1", tier=1, amount=18, criteria="level", xp=10e3},
	{name="level2", tier=2, amount=100, criteria="level", xp=50e3},
	{name="level3", tier=3, amount=999, criteria="level", xp=500e3},
	
	{name="builder1", tier=1, amount=50, criteria="towers", xp=25e3},
	{name="builder2", tier=2, amount=200, criteria="towers", xp=100e3},
	{name="builder3", tier=3, amount=1000, criteria="towers", xp=500e3},
	{name="cashspend1", tier=1, amount=1e6, criteria="cash.towers", display=1, xp=25e3},
	{name="cashspend2", tier=2, amount=1e8, criteria="cash.towers", display=1, xp=100e3},
	{name="cashspend3", tier=3, amount=1e10, criteria="cash.towers", display=1, xp=500e3},
	
	{name="upgrade1", tier=1, amount=100, criteria="towers.upgrades", xp=25e3},
	{name="upgrade2", tier=2, amount=500, criteria="towers.upgrades", xp=100e3},
	{name="upgrade3", tier=3, amount=2500, criteria="towers.upgrades", xp=500e3},
	
	{name="superpowered", tier=1, amount=100e3, criteria="towers.upgrades.max_price", display=1, xp=25e3},
	{name="hyperpowered", tier=2, amount=10e6, criteria="towers.upgrades.max_price", display=1, xp=100e3},
	{name="rainbow_beamer_maxed", tier=2, amount=8, criteria="towers.upgrades.max_tier.gballoon_tower_08", xp=500e3},
	
	{name="success", tier=1, criteria="success", xp=2000},
	{name="success_all", tier=2, criteria="success.all", xp=1.5e6},
	{name="success_flawless", tier=1, criteria="success.no_damage", xp=5000},
	{name="fail1", tier=1, amount=1, criteria="fail", xp=100},
	{name="fail2", tier=2, amount=20, criteria="fail", xp=25e3},
	{name="fail_notowers", tier=1, criteria="fail.no_score", xp=1},
	{name="success_notowers", tier=3, criteria="success.no_score", xp=1.5e6},
	
	{name="rainbow_gblimp_kill", tier=1, criteria="pops.gballoon_blimp_rainbow", xp=100e3},
	{name="bosses_success", tier=1, criteria="success.insane_bosses", xp=500e3},
	{name="super_bosses_success", tier=2, criteria="success.impossible_bosses", xp=1.5e6},
	
	{name="economy", tier=3, amount=1.797693e308, criteria="cash", display=1, xp=10e6}
}

AccessorFunc(GM, "StoredStatistics", "StoredStatistics")
AccessorFunc(GM, "StatisticIDs", "StatisticIDs")
AccessorFunc(GM, "StatisticAmounts", "StatisticAmounts")
AccessorFunc(GM, "StoredAchievements", "StoredAchievements")
AccessorFunc(GM, "AchievementIDs", "AchievementIDs")
AccessorFunc(GM, "StoredAchievementsByStat", "StoredAchievementsByStat")

function GM:CreateStoredStatistics()
	local ids = {}
	
	local statisticNames = {}
	for k,v in pairs(hook.Run("GetAchievements")) do
		local stat = v.criteria
		if stat and not statisticNames[stat] then
			statisticNames[stat] = true
		end
	end
	
	local statistics = table.GetKeys(statisticNames)
	table.sort(statistics)
	
	for i,v in ipairs(statistics) do
		ids[v] = i
	end
	
	hook.Run("SetStoredStatistics", statistics)
	hook.Run("SetStatisticIDs", ids)
end

function GM:GetStatistics()
	if not hook.Run("GetStoredStatistics") then
		hook.Run("CreateStoredStatistics")
	end
	
	return hook.Run("GetStoredStatistics")
end

function GM:GetStatisticID(statName)
	if not hook.Run("GetStoredStatistics") then
		hook.Run("CreateStoredStatistics")
	end
	return hook.Run("GetStatisticIDs")[statName]
end

function GM:CreateStoredAchievements()
	local achievements = table.Copy(self.BaseAchievements)
	hook.Run("GatherCustomAchievements", achievements)
	
	local achievementIDs = {}
	for i,v in ipairs(achievements) do
		v.amount = v.amount or 1
		v.id = i
		achievementIDs[v.name] = i
	end
	
	hook.Run("SetStoredAchievements", achievements)
	hook.Run("SetAchievementIDs", achievementIDs)
end

function GM:GetAchievements()
	if not hook.Run("GetStoredAchievements") then
		hook.Run("CreateStoredAchievements")
	end
	return hook.Run("GetStoredAchievements")
end

function GM:GetAchievementID(achievementName)
	if not hook.Run("GetAchievementIDs") then
		hook.Run("CreateStoredAchievements")
	end
	return hook.Run("GetAchievementIDs")[achievementName]
end

function GM:GetAchievementByID(achievementID)
	return hook.Run("GetAchievements")[achievementID]
end

function GM:GetAchievementByName(achievementName)
	return hook.Run("GetAchievementByID", hook.Run("GetAchievementID", achievementName))
end

function GM:GatherCustomAchievements(achievements)
	-- meant to be used by custom addons via hook.Add
end

function GM:CreateStoredAchievementsByStat()
	local achievementsByStat = {}
	
	for i,v in ipairs(hook.Run("GetAchievements")) do
		local stat = hook.Run("GetStatisticID", v.criteria)
		achievementsByStat[stat] = achievementsByStat[stat] or {}
		table.insert(achievementsByStat[stat], v)
	end
	
	hook.Run("SetStoredAchievementsByStat", achievementsByStat)
end

function GM:GetAchievementsByStat(stat)
	if not hook.Run("GetStoredAchievementsByStat") then
		hook.Run("CreateStoredAchievementsByStat")
	end
	return hook.Run("GetStoredAchievementsByStat")[stat]
end

local PLAYER = FindMetaTable("Player")
function PLAYER:RTG_SetStat(stat, amount, ...)
	if isstring(stat) then
		stat = hook.Run("GetStatisticID", stat)
	end
	
	return self:_RTG_SetStat(stat, amount, ...)
end

function PLAYER:RTG_AddStat(stat, amount, ...)
	if amount > 0 then
		if isstring(stat) then
			stat = hook.Run("GetStatisticID", stat)
		end
		
		return self:_RTG_AddStat(stat, amount, ...)
	end
end

function PLAYER:RTG_GetStat(stat, ...)
	if isstring(stat) then
		stat = hook.Run("GetStatisticID", stat)
	end
	
	return self:_RTG_GetStat(stat, ...)
end