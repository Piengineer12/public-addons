InsaneStats:SetDefaultConVarCategory("Coin Drops - General")

InsaneStats:RegisterConVar("coins_enabled", "insanestats_coins_enabled", "1", {
	display = "Enable Coin Drops", desc = "Enables coin drops.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("coins_legacy", "insanestats_coins_legacy", "0", {
	display = "Use Gemstone Models", desc = "If Cut/Faceted Jewels Pack is installed, gems will be dropped instead of coins.\n\z
	This is largely an aesthetic change, as tribute to an abandoned gamemode.",
	type = InsaneStats.BOOL
})

InsaneStats:RegisterConVar("coins_player_lose", "insanestats_coins_player_losepercent", "10", {
	display = "Player Coins % Lost On Death", desc = "Coins % lost when a player dies. Non-players will always lose 100% of their coins on death.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("coins_player_save", "insanestats_coins_player_save", "1", {
	display = "Save Player Coins Across Maps", desc = "If enabled, player coins will be saved across maps.",
	type = InsaneStats.BOOL
})

InsaneStats:RegisterConVar("coins_denomination_mul", "insanestats_coins_denomination_distance", "5", {
	display = "Denomination Distance", desc = "Multiplier between each coin tier.",
	type = InsaneStats.FLOAT, min = 2, max = 1000
})
InsaneStats:RegisterConVar("coins_drop_count", "insanestats_coins_drop_count", "5", {
	display = "Coins Dropped", desc = "Entities that drop coins will spawn a maximum of this many coins.",
	type = InsaneStats.INT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("coins_drop_max", "insanestats_coins_drop_max", "25", {
	display = "Max Coins", desc = "Maximum number of coins allowed to be present in the world. \z
	If this limit is reached, addtional coins dropped by entities will cause existing coins to be randomly given to random players.",
	type = InsaneStats.INT, min = 0, max = 1000
})

InsaneStats:SetDefaultConVarCategory("Coin Drops - Values")

InsaneStats:RegisterConVar("coins_player_mul", "insanestats_coins_player_mul", "1", {
	display = "Player Drop Multiplier", desc = "Multiplier for coins dropped by players. The amount of coins dropped is based on max starting health and level.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("coins_breakable_mul", "insanestats_coins_breakable_mul", "1", {
	display = "Breakable Drop Multiplier", desc = "Multiplier for coins dropped by breakables. The amount of coins dropped is based on max starting health and level.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("coins_other_mul", "insanestats_coins_other_mul", "1", {
	display = "Other Drop Multiplier", desc = "Multiplier for coins dropped by others. The amount of coins dropped is based on max starting health and level.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("coins_level_add", "insanestats_coins_level_add", "10", {
	display = "Level Scaling", desc = "% additional coins dropped per level. Only relevant when Insane Stats XP is enabled.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("coins_level_add_mode", "insanestats_coins_level_add_mode", "-1", {
	display = "Level Mode", desc = "If enabled, additional coins dropped is applied additively rather than multiplicatively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("coins_level_add_add", "insanestats_coins_level_add_add", "10", {
	display = "Level Growth", desc = "Additional % of % additional coins dropped per level. \z
	This is only applied if \"insanestats_coins_level_add_mode\" is 0.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})

InsaneStats:SetDefaultConVarCategory("Coin Drops - Costs")

InsaneStats:RegisterConVar("coins_weapon_price_start", "insanestats_coins_weapon_price_start", "1", {
	display = "Weapon Cost Minimum", desc = "Lowest weapon item price.",
	type = InsaneStats.FLOAT, min = 0, max = 10000
})
InsaneStats:RegisterConVar("coins_weapon_price_end", "insanestats_coins_weapon_price_end", "10000", {
	display = "Weapon Cost Maximum", desc = "Highest weapon item price.",
	type = InsaneStats.FLOAT, min = 0, max = 10000
})
InsaneStats:RegisterConVar("coins_weapon_price_geometric", "insanestats_coins_weapon_price_geometric", "1", {
	display = "Weapon Costs Follow Geometric Progression", desc = "If disabled, weapon costs will increase linearly between items. \z
	This is forcefully disabled when either insanestats_coins_weapon_price_start or insanestats_coins_weapon_price_end are 0 or less.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("coins_weapon_max", "insanestats_coins_weapon_max", "50", {
	display = "Weapons Per Shop", desc = "Up to this many weapons will be randomly chosen for each Insane Stats Coin Shop.",
	type = InsaneStats.INT, min = 0, max = 65535
})
InsaneStats:RegisterConVar("coins_weapon_max_price", "insanestats_coins_weapon_max_price", "100", {
	display = "Max Considered Weapon Price", desc = "The maximum price of weapons randomly chosen by Insane Stats Coin Shops will not exceed this value, \z
	unless there are less than insanestats_coins_weapon_max weapons to choose from.",
	type = InsaneStats.FLOAT, min = 0, max = 10000
})
InsaneStats:RegisterConVar("coins_weapon_max_price_level_add", "insanestats_coins_weapon_max_price_level_add", "10", {
	display = "Level Scaling", desc = "% additional max considered weapon price per Insane Stats Coin Shop level. Only relevant when Insane Stats XP is enabled.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("coins_weapon_max_price_level_add_mode", "insanestats_coins_weapon_max_price_level_add_mode", "-1", {
	display = "Level Mode", desc = "If enabled, % additional max considered weapon price is applied additively rather than multiplicatively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("coins_weapon_max_price_level_add_add", "insanestats_coins_weapon_max_price_level_add_add", "10", {
	display = "Level Growth", desc = "Additional % of % additional max considered weapon price per level. \z
	This is only applied if \"insanestats_coins_weapon_max_price_level_add_mode\" is 0.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})

InsaneStats:RegisterConVar("coins_reforge_cost", "insanestats_coins_reforge_cost", "100", {
	display = "Reforge Cost", desc = "Base price of rerolling WPASS2 modifiers on a tier 1 weapon / armor battery.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("coins_reforge_cost_add", "insanestats_coins_reforge_cost_add", "40", {
	display = "Reforge Cost Scaling", desc = "% additional cost per tier. This is always applied multiplicatively.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})

InsaneStats:RegisterConVar("coins_respec_cost", "insanestats_coins_respec_cost", "100", {
	display = "Respec Cost", desc = "Base price of refunding all skill points spent.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("coins_respec_cost_add", "insanestats_coins_respec_cost_add", "10", {
	display = "Respec Cost Scaling", desc = "% additional cost per skill point spent. This is always applied multiplicatively.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})

InsaneStats.ShopItems = {
	{"item_battery", 25},
	{"item_healthvial", 10},
	{"item_healthkit", 25},
	{"item_ammo_357", 10},
	{"item_ammo_ar2", 10},
	{"item_ammo_ar2_altfire", 50},
	{"item_ammo_crossbow", 25},
	{"item_ammo_pistol", 10},
	{"item_ammo_smg1", 10},
	{"item_ammo_smg1_grenade", 50},
	{"item_box_buckshot", 25},
	{"item_rpg_round", 50},
}
InsaneStats.ShopItemsAutomaticPrice = {
	"gmod_camera",
	"weapon_fists",
	"weapon_medkit",
	"weapon_slam",
	"weapon_physgun",
	"gmod_tool"
}

function InsaneStats:GetReforgeCost(wep, blacklisted)
	-- the old system simply used the formula mult^tier where mult is the tier multiplier
	-- so if mult = 1.1, reforging tier 1 would cost 1x, tier 2 costing 1.1x, tier 3 costing 1.21x, etc.
	-- the new system is (mult/p)^tier, where p is the probability that the reforge will not add a blacklisted modifier
	blacklisted = blacklisted or {}
	local modifierProbabilities = self:GetModifierProbabilities(wep)

	local totalWeight = 0
	local blacklistedWeight = 0

	for k,v in pairs(modifierProbabilities) do
		totalWeight = totalWeight + v

		if blacklisted[k] then
			blacklistedWeight = blacklistedWeight + v
		end
	end

	local selectableWeightFraction = 1 - blacklistedWeight / totalWeight
	local scaling = (1 + self:GetConVarValue("coins_reforge_cost_add")/100) / selectableWeightFraction - 1

	if InsaneStats:IsDebugLevel(1) then
		InsaneStats:Log(
			"Reforge of %s: Total Weight = %f, Blacklisted Weight = %f, Selectable Fraction = %f",
			tostring(wep), totalWeight, blacklistedWeight, selectableWeightFraction
		)
	end

	return self:ScaleValueToLevelPure(
		self:GetConVarValue("coins_reforge_cost"),
		scaling,
		math.abs(wep.insaneStats_Tier or 0),
		true
	)
end

function InsaneStats:GetItemCost(index, ply)
	local itemInfo = self.ShopItems[index]
	local cost = itemInfo[2]
	if self:GetConVarValue("xp_enabled") and cost then
		cost = self:ScaleValueToLevelQuadratic(
			cost,
			self:GetConVarValue("coins_level_add")/100,
			ply:InsaneStats_GetLevel(),
			"coins_level_add_mode",
			false,
			self:GetConVarValue("coins_level_add_add")/100
		)
	end
	return cost
end

function InsaneStats:GetWeaponCost(index)
	local maxIndex = #self.ShopItemsAutomaticPrice
	local minPrice = self:GetConVarValue("coins_weapon_price_start")
	local maxPrice = self:GetConVarValue("coins_weapon_price_end")
	local geometric = minPrice > 0 and maxPrice > 0 and self:GetConVarValue("coins_weapon_price_geometric")

	if geometric then
		return math.exp(math.Remap(index, 1, maxIndex, math.log(minPrice), math.log(maxPrice)))
	else
		return math.Remap(index, 1, maxIndex, minPrice, maxPrice)
	end
end

function InsaneStats:GetRespecCost(ent)
	return self:ScaleValueToLevelPure(
		self:GetConVarValue("coins_respec_cost"),
		self:GetConVarValue("coins_respec_cost_add")/100,
		ent:InsaneStats_GetTotalSkillPoints() - ent:InsaneStats_GetSkillPoints()
		+ ent:InsaneStats_GetTotalUberSkillPoints() - ent:InsaneStats_GetUberSkillPoints(),
		true
	)
end

-- the server needs access for setting the fallback coin color
local color_gray = Color(127, 127, 127)
function InsaneStats:GetCoinColor(valueExponent)
	local realTime = RealTime()
	local hue = (valueExponent + 1) * 30
	local sat = 1

	if valueExponent % 24 >= 12 then
		sat = math.abs(Lerp(realTime%1, -1, 1))
	end

	if valueExponent < 0 then
		return color_gray
	elseif valueExponent < 24 then
		-- nothing needs to be done
	elseif valueExponent < 48 then -- 3.553e33
		hue = hue + math.abs(Lerp(realTime%2/2, -120, 120)) - 60
	elseif valueExponent < 72 then -- 2.118e50
		hue = hue + math.ease.InOutCubic(realTime%3/3) * 360
	else
		hue = realTime * 120
		sat = 1
	end
	return HSVToColor(hue % 360, sat, 1)
end

local ENT = FindMetaTable("Entity")

function ENT:InsaneStats_GetCoins()
	return self:InsaneStats_GetEntityData("coins") or 0
end

function ENT:InsaneStats_SetCoins(coins)
	self:InsaneStats_SetEntityData("coins", coins)
	if coins > 0 then
		self.insaneStats_CoinsRoot8 = InsaneStats:CalculateRoot8(coins)
	end
    if SERVER then
	    self:InsaneStats_MarkForUpdate(64)
    end
end

function ENT:InsaneStats_AddCoins(coins)
    return self:InsaneStats_SetCoins(self:InsaneStats_GetCoins() + coins)
end

function ENT:InsaneStats_RemoveCoins(coins)
    return self:InsaneStats_SetCoins(self:InsaneStats_GetCoins() - coins)
end

function ENT:InsaneStats_SetLastCoinTier(tier)
	self.insaneStats_LastCoinTier = tier
end

function ENT:InsaneStats_GetLastCoinTier()
	return self.insaneStats_LastCoinTier or 254
end

local PLAYER = FindMetaTable("Player")

function PLAYER:InsaneStats_SetReforgeBlacklist(blacklist)
	self.insaneStats_ReforgeBlacklist = blacklist
end

function PLAYER:InsaneStats_GetReforgeBlacklist()
	return self.insaneStats_ReforgeBlacklist or {}
end

hook.Add("InsaneStatsTransitionCompat", "InsaneStatsCoinsShared", function(ent)
	if ent.insaneStats_CoinsRoot8 then
		ent:InsaneStats_SetCoins(ent.insaneStats_CoinsRoot8 ^ 8)
	end
end)