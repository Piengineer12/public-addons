InsaneStats:SetDefaultConVarCategory("Experience")

InsaneStats:RegisterConVar("xp_enabled", "insanestats_xp_enabled", "1", {
	display = "Enable Experience", desc = "Enables the experience system.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("xp_mode", "insanestats_xp_mode", "0", {
	display = "Mode", desc = "All insanestats_xp_*mode ConVars which have been set to -1 will use this value instead.",
	type = InsaneStats.INT, min = 0, max = 1
})
InsaneStats:RegisterConVar("xp_damagemode", "insanestats_xp_damagemode", "1", {
	display = "Inflictor Damage Scaling", desc = "Determines whether the damage inflictor should determine damage scaling, instead of the attacker.\n\z
		0: Never base damage on damage inflictor\n\z
		1: When inflictor is a thrown prop\n\z
		2: When inflictor is a weapon\n\z
		3: Both\n\z
		Note that the inflictor will always receive the same XP as the attacker regardless of circumstance.",
	type = InsaneStats.INT, min = 0, max = 3
})

InsaneStats:RegisterConVar("xp_other_mul", "insanestats_xp_other_mul", "1", {
	display = "Non-player Drop Multiplier", desc = "Multiplier for experience dropped by non-players. The amount of experience dropped is based on max starting health and level.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("xp_player_mul", "insanestats_xp_player_mul", "1", {
	display = "Player Drop Multiplier", desc = "Multiplier for experience dropped by players. The amount of experience dropped is based on max starting health and level.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("xp_other_kill", "insanestats_xp_other_yieldmul", "3", {
	display = "Non-player Yield Multiplier", desc = "Multiplier for added experience dropped when a non-player kills another non-player.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("xp_player_kill", "insanestats_xp_player_yieldmul", "3", {
	display = "Player Yield Multiplier", desc = "Multiplier for added experience dropped when a non-player kills a player.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("xp_other_extra", "insanestats_xp_other_extrapercent", "100", {
	display = "Non-player Additional XP %", desc = "Experience % added when non-players kill other non-players, scaled by the difference between levels.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_player_lose", "insanestats_xp_player_losepercent", "0", {
	display = "Player XP % Lost On Death", desc = "Experience % lost when a player dies. Non-players will always lose 100% of their experience on death.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})

InsaneStats:RegisterConVar("xp_drop_add", "insanestats_xp_drop_add", "10", {
	display = "Drop Scaling", desc = "Additional % experience dropped per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_drop_add_mode", "insanestats_xp_drop_add_mode", "-1", {
	display = "Drop Scaling Mode", desc = "If 1, additional experience dropped is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_drop_add_add", "insanestats_xp_drop_add_add", "0.1", {
	display = "Drop Growth", desc = "Additional % of additional % experience dropped per level. \z
		Note that this value also influences experience % added when non-players kill other non-players.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("xp_drop_add_add_mode", "insanestats_xp_drop_add_add_mode", "0", {
	display = "Drop Growth Mode", desc = "If 1, additional additional experience dropped is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})

InsaneStats:RegisterConVar("xp_other_level_start", "insanestats_xp_other_level_start", "1", {
	display = "Non-player Starting Level", desc = "Starting level for spawned non-players.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_level_drift", "insanestats_xp_other_level_drift", "10", {
	display = "Non-player Level Drift", desc = "Randomly alters NPC levels by +/- this value.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_level_drift_mode", "insanestats_xp_other_level_drift_mode", "-1", {
	display = "Non-player Level Drift Mode", desc = "If 1, the level drift is interpreted as an absolute value instead of a percentage. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_other_level_drift_harshness", "insanestats_xp_other_level_drift_harshness", "1", {
	display = "Non-player Level Drift Harshness", desc = "Reduces the chance for high amounts of level drift. \z
		At 0, the drift distribution is uniform (every possible drift amount is equally likely).",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("xp_other_level_factor", "insanestats_xp_other_level_factor", "1", {
	display = "Non-player Level Scaling", desc = "Determines factor for increasing the XP of spawned entities.\n\z
		0: No Scaling\n\z
		1: Scale based on average level across players\n\z
		2: Scale based on geometric average level across players\n\z
		3: Scale based on highest level across players\n\z
		4: Scale based on level of activator / nearest player\n\z
		5: Scale based on maps played since insanestats_xp_other_level_maps_reset was called",
	type = InsaneStats.INT, min = 0, max = 5
})
InsaneStats:RegisterConVar("xp_other_level_players", "insanestats_xp_other_level_players", "10", {
	display = "Non-player Player Level Scaling", desc = "Level increase of spawned non-players per extra player in the server.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_level_players_mode", "insanestats_xp_other_level_players_mode", "-1", {
	display = "Non-player Player Level Scaling Mode", desc = "If 1, insanestats_xp_other_levelplayers is interpreted as an absolute value instead of a percentage. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_other_level_maps", "insanestats_xp_other_level_maps", "10", {
	display = "Non-player Maps Level Scaling", desc = "% level increase of spawned entities per map. Only relevant when insanestats_xp_other_level_factor is 4.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_level_maps_mode", "insanestats_xp_other_level_maps_mode", "-1", {
	display = "Non-player Maps Level Scaling Mode", desc = "If 1, insanestats_xp_other_levelmaps is applied additively rather than multiplicatively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_other_level_maps_minimum", "insanestats_xp_other_level_maps_minimum", "1", {
	display = "Non-player Maps Level Minimum", desc = "Minimum level increase of spawned entities per map.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})

InsaneStats:RegisterConVar("xp_player_level_start", "insanestats_xp_player_level_start", "1", {
	display = "Player Starting Level", desc = "Starting level for spawned players.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_scale_maxlevel", "insanestats_xp_scale_level_max", "-1", {
	display = "Maximum Level", desc = "Maximum level. At this level, it takes an infinite amount of experience to level up. Set to -1 for no limit.",
	type = InsaneStats.FLOAT, min = -1, max = 10000
})
InsaneStats:RegisterConVar("xp_scale_start", "insanestats_xp_scale_level_start", "100", {
	display = "Starting XP Required", desc = "Experience required to reach level 2.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_scale_add", "insanestats_xp_scale_add", "20", {
	display = "XP Scaling", desc = "Additional % experience required per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_scale_add_mode", "insanestats_xp_scale_add_mode", "-1", {
	display = "XP Scaling Mode", desc = "If 1, experience required is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})

-- TODO: make health, armor, damage and resistance scaling quadratic
InsaneStats:RegisterConVar("xp_player_health", "insanestats_xp_player_health_add", "10", {
	display = "Player Health Scaling", desc = "Player % max health gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_player_health_mode", "insanestats_xp_player_health_add_mode", "-1", {
	display = "Player Health Scaling Mode", desc = "If 1, player max health gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_player_health_add", "insanestats_xp_player_health_add_add", "10", {
	display = "Player Health Growth", desc = "Additional % of player % max health gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_player_health_add_mode", "insanestats_xp_player_health_add_add_mode", "0", {
	display = "Player Health Growth Mode", desc = "If 1, additional % of player max health gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_player_armor", "insanestats_xp_player_armor_add", "10", {
	display = "Player Armor Scaling", desc = "Player % max armor gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_player_armor_mode", "insanestats_xp_player_armor_add_mode", "-1", {
	display = "Player Armor Scaling Mode", desc = "If 1, player max armor gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_player_armor_add", "insanestats_xp_player_armor_add_add", "10", {
	display = "Player Armor Growth", desc = "Additional % of player % max armor gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_player_armor_add_mode", "insanestats_xp_player_armor_add_add_mode", "0", {
	display = "Player Armor Growth Mode", desc = "If 1, additional % of player max armor gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})

InsaneStats:RegisterConVar("xp_player_damage", "insanestats_xp_player_damage_add", "10", {
	display = "Player Damage Scaling", desc = "Player % damage dealt gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_player_damage_mode", "insanestats_xp_player_damage_add_mode", "-1", {
	display = "Player Damage Scaling Mode", desc = "If 1, player damage dealt gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_player_damage_add", "insanestats_xp_player_damage_add_add", "10", {
	display = "Player Damage Growth", desc = "Additional % of player % damage dealt gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_player_damage_add_mode", "insanestats_xp_player_damage_add_add_mode", "0", {
	display = "Player Damage Growth Mode", desc = "If 1, additional % of player damage dealt gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_player_resistance", "insanestats_xp_player_resistance_add", "0", {
	display = "Player Resistance Scaling", desc = "Player % resistance gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_player_resistance_mode", "insanestats_xp_player_resistance_add_mode", "-1", {
	display = "Player Resistance Scaling Mode", desc = "If 1, player damage resistance gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_player_resistance_add", "insanestats_xp_player_resistance_add_add", "0", {
	display = "Player Resistance Growth", desc = "Additional % of player % resistance gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_player_resistance_add_mode", "insanestats_xp_player_resistance_add_add_mode", "0", {
	display = "Player Resistance Growth Mode", desc = "If 1, additional % of player damage resistance gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})

InsaneStats:RegisterConVar("xp_other_health", "insanestats_xp_other_health_add", "10", {
	display = "Non-player Health Scaling", desc = "Non-player % max health gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_health_mode", "insanestats_xp_other_health_add_mode", "-1", {
	display = "Non-player Health Scaling Mode", desc = "If 1, non-player max health gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_other_health_add", "insanestats_xp_other_health_add_add", "10", {
	display = "Non-player Health Growth", desc = "Additional % of non-player % max health gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_health_add_mode", "insanestats_xp_other_health_add_add_mode", "0", {
	display = "Non-player Health Growth Mode", desc = "If 1, additional % of non-player max health gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_other_armor", "insanestats_xp_other_armor_add", "10", {
	display = "Non-player Armor Scaling", desc = "Non-player % max armor gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_armor_mode", "insanestats_xp_other_armor_add_mode", "-1", {
	display = "Non-player Armor Scaling Mode", desc = "If 1, non-player max armor gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_other_armor_add", "insanestats_xp_other_armor_add_add", "10", {
	display = "Non-player Armor Growth", desc = "Additional % of non-player % max armor gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_armor_add_mode", "insanestats_xp_other_armor_add_add_mode", "0", {
	display = "Non-player Armor Growth Mode", desc = "If 1, additional % of non-player max armor gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})

InsaneStats:RegisterConVar("xp_other_damage", "insanestats_xp_other_damage_add", "10", {
	display = "Non-player Damage Scaling", desc = "Non-player % damage dealt gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_damage_mode", "insanestats_xp_other_damage_add_mode", "-1", {
	display = "Non-player Damage Scaling Mode", desc = "If 1, non-player damage dealt gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_other_damage_add", "insanestats_xp_other_damage_add_add", "10", {
	display = "Non-player Damage Growth", desc = "Additional % of non-player % damage dealt gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_damage_add_mode", "insanestats_xp_other_damage_add_add_mode", "0", {
	display = "Non-player Damage Growth Mode", desc = "If 1, additional % of non-player damage dealt gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_other_resistance", "insanestats_xp_other_resistance_add", "0", {
	display = "Non-player Resistance Scaling", desc = "Non-player % damage resistance gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_resistance_mode", "insanestats_xp_other_resistance_add_mode", "-1", {
	display = "Non-player Resistance Scaling Mode", desc = "If 1, non-player damage resistance gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_other_resistance_add", "insanestats_xp_other_resistance_add_add", "0", {
	display = "Non-player Resistance Growth", desc = "Additional % of non-player % damage resistance gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_resistance_add_mode", "insanestats_xp_other_resistance_add_add_mode", "0", {
	display = "Non-player Resistance Growth Mode", desc = "If 1, additional % of non-player damage resistance gained is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})

function InsaneStats:ScaleValueToLevel(value, mul, level, mode, invertMode)
	if math.abs(level) == math.huge and (mul == 0 or value == 0) then
		return value
	else
		local multiplicative = self:GetConVarValueDefaulted(mode, "xp_mode") > 0
		if invertMode then
			multiplicative = not multiplicative
		end
		if multiplicative then
			return value*(1+mul)^(level-1)
		else
			return value*(1+mul*(level-1))
		end
	end
end

function InsaneStats:ScaleValueToLevelQuadratic(value, level, mul, mode, mul2, mode2, invertMode, invertMode2)
	return self:ScaleValueToLevel(
		value,
		self:ScaleValueToLevel(
			mul,
			mul2,
			level,
			mode2,
			invertMode2
		),
		level,
		mode,
		invertMode
	)
end

local function ScaleTotalValueToLevel(value, mul, level, multiplicative)
	if multiplicative then
		return -value/mul*(1-(mul+1)^(level-1))
	else
		-- value*(level-1+(level^2-3*level+2)*mul/2)
		return value*(level/2*(mul*(level-3)+2)+mul-1)
	end
end

local function ScaleLevelToTotalValue(value, mul, start, multiplicative)
	if multiplicative then
		-- value = -start/mul*(1-(mul+1)^(level-1))
		-- log(value/start*mul+1)/log((mul+1))+1 = level
		
		return math.log(value/start*mul+1, mul+1)+1
	else
		--[[
		if c = a*(x-1+(x^2-3*x+2)*b/2)
		then x = (sqrt(a (b - 2)^2 + 8 b c) + sqrt(a) (3 b - 2))/(2 sqrt(a) b) and a b!=0, courtesy of WolframAlpha
		]]
		
		local part = math.sqrt(start*(mul - 2)^2 + 8*mul*value)
		local sqrtStart = math.sqrt(start)
		
		return (part + sqrtStart*(3*mul - 2))/(2*sqrtStart*mul)
	end
end

function InsaneStats:GetXPRequiredToLevel(level)
	if level <= self:GetConVarValue("xp_scale_maxlevel") or self:GetConVarValue("xp_scale_maxlevel") <= 0 then
		return ScaleTotalValueToLevel(
			self:GetConVarValue("xp_scale_start"),
			self:GetConVarValue("xp_scale_add")/100,
			level,
			self:GetConVarValueDefaulted("xp_scale_add_mode", "xp_mode") > 0
		)
	else return math.huge
	end
end

function InsaneStats:GetLevelByXPRequired(xp)
	if xp == math.huge then return math.huge end
	local rawValue = ScaleLevelToTotalValue(
		xp,
		self:GetConVarValue("xp_scale_add")/100,
		self:GetConVarValue("xp_scale_start"),
		self:GetConVarValueDefaulted("xp_scale_add_mode", "xp_mode") > 0
	)
	if self:GetConVarValue("xp_scale_maxlevel") > 0 then
		return math.min(rawValue, self:GetConVarValue("xp_scale_maxlevel"))
	else
		return rawValue
	end
end

local ENT = FindMetaTable("Entity")

function ENT:InsaneStats_GetLevel()
	return self.insaneStats_Level or 1
end

function ENT:InsaneStats_GetLevelFraction()
	local currentLevel = self:InsaneStats_GetLevel()
	local prevXP = InsaneStats:GetXPRequiredToLevel(currentLevel)
	local nextXP = InsaneStats:GetXPRequiredToLevel(currentLevel+1)
	if nextXP == math.huge then
		nextXP = 2^(1024-2^-43)
	end
	if self:InsaneStats_GetXP() == math.huge then
		return 1
	else
		return math.Clamp(math.Remap(self:InsaneStats_GetXP(), prevXP, nextXP, 0, 1), 0, 1)
	end
end

function ENT:InsaneStats_GetXP()
	return self.insaneStats_XP or 0
end

function ENT:InsaneStats_SetXP(xp, dropValue)
	assert(xp >= -math.huge, "Something tried to set XP on "..tostring(self).." to nan!")
	
	self.insaneStats_XP = xp
	
	if dropValue then
		self.insaneStats_DropXP = dropValue
	end
	
	local newLevel = math.floor(InsaneStats:GetLevelByXPRequired(xp))
	-- self.insaneStats_Level can be nil
	if self.insaneStats_Level ~= newLevel and SERVER then
		self:InsaneStats_ApplyLevel(newLevel)
	end
	
	self.insaneStats_Level = newLevel
	self:InsaneStats_MarkForUpdate(2)
end

function ENT:InsaneStats_AddXP(xp, addDropValue)
	return self:InsaneStats_SetXP((self.insaneStats_XP or 0) + xp, (self.insaneStats_DropXP or 0) + addDropValue)
end

function ENT:InsaneStats_GetXPToNextLevel()
	return InsaneStats:GetXPRequiredToLevel(self:InsaneStats_GetLevel()+1)
end

