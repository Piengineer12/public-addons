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

InsaneStats:RegisterConVar("coins_reforge_cost", "insanestats_coins_reforge_cost", "100", {
	display = "Reforge Cost", desc = "Base price of rerolling WPASS2 modifiers on a tier 1 weapon / armor battery.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("coins_reforge_cost_add", "insanestats_coins_reforge_cost_add", "40", {
	display = "Reforge Cost Scaling", desc = "% additional cost per tier. This is always applied multiplicatively.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})

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
	return self.insaneStats_Coins or 0
end

function ENT:InsaneStats_SetCoins(coins)
	self.insaneStats_Coins = coins
	if coins > 0 then
		self.insaneStats_CoinsRoot8 = coins^0.125
	end
    if SERVER then
	    self:InsaneStats_MarkForUpdate(64)
    end
end

function ENT:InsaneStats_AddCoins(coins)
    return self:InsaneStats_SetCoins(self:InsaneStats_GetCoins() + coins)
end

function ENT:InsaneStats_SetLastCoinTier(tier)
	self.insaneStats_LastCoinTier = tier
end

function ENT:InsaneStats_GetLastCoinTier()
	return self.insaneStats_LastCoinTier or 254
end

hook.Add("InsaneStatsTransitionCompat", "InsaneStatsCoinsShared", function(ent)
	if ent.insaneStats_CoinsRoot8 then
		ent:InsaneStats_SetCoins(ent.insaneStats_CoinsRoot8 ^ 8)
	end
end)