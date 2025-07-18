InsaneStats:SetDefaultConVarCategory("XP - General")

InsaneStats:RegisterConVar("xp_enabled", "insanestats_xp_enabled", "1", {
	display = "Enable Experience", desc = "Enables the experience system. You can use insanestats_xp_player_level_set to manually set a player's level.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("xp_mode", "insanestats_xp_mode", "0", {
	display = "Mode", desc = "All insanestats_xp_*mode ConVars which have been set to -1 will use this value instead.",
	type = InsaneStats.INT, min = 0, max = 1
})
InsaneStats:RegisterConVar("xp_damagemode", "insanestats_xp_damagemode", "0", {
	display = "Inflictor Damage Scaling", desc = "\z
		Determines whether the damage inflictor should determine damage scaling, instead of the attacker.\n\z
		0: Never base damage on damage inflictor\n\z
		1: When inflictor is a thrown prop\n\z
		2: When inflictor is a weapon\n\z
		3: Both\n\z
		Note that the inflictor will always receive the same XP as the attacker regardless of circumstance.",
	type = InsaneStats.INT, min = 0, max = 3
})
InsaneStats:RegisterConVar("xp_player_share", "insanestats_xp_player_share", "25", {
	display = "Team XP", desc = "All team members of a player who earns XP also gain this % of XP.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("xp_player_save", "insanestats_xp_player_save", "1", {
	display = "Save Player XP Across Maps", desc = "If enabled, player XP will be saved across maps.",
	type = InsaneStats.BOOL
})

InsaneStats:SetDefaultConVarCategory("XP - XP Calculations")

InsaneStats:RegisterConVar("xp_drop_add", "insanestats_xp_drop_add", "10", {
	display = "Drop Scaling", desc = "Additional % experience dropped per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_drop_add_mode", "insanestats_xp_drop_add_mode", "-1", {
	display = "Drop Scaling Mode", desc = "If 1, additional experience dropped is applied multiplicatively rather than additively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})

InsaneStats:RegisterConVar("xp_player_mul", "insanestats_xp_player_mul", "1", {
	display = "Player Drop Multiplier", desc = "Multiplier for experience dropped by players. The amount of experience dropped is based on max starting health and level.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("xp_player_kill", "insanestats_xp_player_yieldmul", "0", {
	display = "Player Yield Multiplier", desc = "Multiplier for added experience dropped when a non-player kills a player.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("xp_player_lose", "insanestats_xp_player_losepercent", "0", {
	display = "Player XP % Lost On Death", desc = "Experience % lost when a player dies. Non-players will always lose 100% of their experience on death.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("xp_player_weekday_mul", "insanestats_xp_player_weekday_mul", "1 1 1 1 1 1 1", {
	display = "Player Weekday Drop Multiplier",
	desc = "Multiplier for experience dropped by players based on the day of the week. \z
	The first number is for Sunday, the second Monday, and so on.",
	type = InsaneStats.STRING
})
InsaneStats:RegisterConVar("xp_other_mul", "insanestats_xp_other_mul", "1", {
	display = "Non-player Drop Multiplier", desc = "Multiplier for experience dropped by non-players. The amount of experience dropped is based on max starting health and level.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("xp_other_kill", "insanestats_xp_other_yieldmul", "3", {
	display = "Non-player Yield Multiplier", desc = "Multiplier for added experience dropped when a non-player kills another non-player.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("xp_other_weekday_mul", "insanestats_xp_other_weekday_mul", "1 1 1 1 1 1 1", {
	display = "Non-player Weekday Drop Multiplier",
	desc = "Multiplier for experience dropped by non-players based on the day of the week. \z
	The first number is for Sunday, the second Monday, and so on.",
	type = InsaneStats.STRING
})
InsaneStats:RegisterConVar("xp_other_extra", "insanestats_xp_other_extrapercent", "20", {
	display = "Non-player Additional XP %", desc = "Experience % added when non-players kill other non-players, scaled by the difference between levels.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_weapon_mul", "insanestats_xp_weapon_mul", "1", {
	display = "Weapon Gain Multiplier", desc = "Multiplier for experience gained by weapons.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})

InsaneStats:SetDefaultConVarCategory("XP - Level Calculations")

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

InsaneStats:RegisterConVar("xp_scale_maxlevel", "insanestats_xp_scale_level_max", "-1", {
	display = "Maximum Level", desc = "Maximum level. At this level, it takes an infinite amount of experience to level up. Set to -1 for no limit.",
	type = InsaneStats.FLOAT, min = -1, max = 10000
})
InsaneStats:RegisterConVar("xp_player_level_start", "insanestats_xp_player_level_start", "1", {
	display = "Player Starting Level", desc = "Starting level for spawned players.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_level_start", "insanestats_xp_other_level_start", "1", {
	display = "Non-player Starting Level", desc = "Starting level for spawned non-players.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_level_factor", "insanestats_xp_other_level_factor", "0", {
	display = "Non-player Level Scaling", desc = "Determines additional factor for increasing the XP of spawned entities.\n\z
		0: No Scaling\n\z
		1: Scale based on average level across players\n\z
		2: Scale based on geometric average level across players\n\z
		3: Scale based on highest level across players\n\z
		4: Scale based on level of activator / nearest player",
	type = InsaneStats.INT, min = 0, max = 4
})
InsaneStats:RegisterConVar("xp_other_level_players", "insanestats_xp_other_players", "25", {
	display = "Non-player Player Bonus XP", desc = "Raises the levels of non-players by spawning them with this % more XP per extra player in the server.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_level_maps", "insanestats_xp_other_level_maps", "0", {
	display = "Non-player Maps Level Scaling", desc = "% level increase of spawned entities per map.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_level_maps_mode", "insanestats_xp_other_level_maps_mode", "-1", {
	display = "Non-player Maps Level Scaling Mode", desc = "If 1, insanestats_xp_other_level_maps is applied additively rather than multiplicatively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_other_level_maps_minimum", "insanestats_xp_other_level_maps_minimum", "0", {
	display = "Non-player Maps Level Minimum", desc = "Minimum level increase of spawned entities per map.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_level_time", "insanestats_xp_other_level_time", "0", {
	display = "Non-player Time Level Scaling", desc = "% level increase of spawned entities per minute.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_level_time_mode", "insanestats_xp_other_level_time_mode", "-1", {
	display = "Non-player Time Level Scaling Mode", desc = "If 1, insanestats_xp_other_level_time is applied additively rather than multiplicatively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("xp_other_level_time_minimum", "insanestats_xp_other_level_time_minimum", "0", {
	display = "Non-player Time Level Minimum", desc = "Minimum level increase of spawned entities per minute.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_level_drift", "insanestats_xp_other_drift", "2", {
	display = "Non-player XP Drift", desc = "Randomly alters spawned non-players' XP by multiplying / dividing up to this factor.",
	type = InsaneStats.FLOAT, min = 1, max = 100
})
InsaneStats:RegisterConVar("xp_other_level_drift_harshness", "insanestats_xp_other_drift_harshness", "1", {
	display = "Non-player XP Drift Harshness", desc = "Reduces the chance for high amounts of XP drift. \z
		At 0, the drift distribution is uniform (every possible drift amount is equally likely).",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("xp_other_alpha_chance", "insanestats_xp_other_alpha_chance", "1.5625", {
	display = "Alpha Chance", desc = "% chance for a non-player entity to be an Alpha, spawning with much more XP.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("xp_other_alpha_mul", "insanestats_xp_other_alpha_mul", "8", {
	display = "Alpha XP Multiplier", desc = "Alpha entities spawn with this times more XP.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("xp_other_alpha_model_scale", "insanestats_xp_other_model_scale", "1", {
	display = "Alpha Model Scale", desc = "Alpha entities will be resized by this factor.",
	type = InsaneStats.FLOAT, min = 0.25, max = 4
})
InsaneStats:RegisterConVar("xp_other_max_mul", "insanestats_xp_other_max_mul", "-1", {
	display = "Max Other XP vs. Players", desc = "If 0 or above, non-player entities \z
	will spawn with at most this times the highest amount of XP among players.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})

InsaneStats:SetDefaultConVarCategory("XP - Player Scales")

InsaneStats:RegisterConVar("xp_player_health", "insanestats_xp_player_health_add", "10", {
	display = "Player Health Scaling", desc = "Player % max health gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_player_health_mode", "insanestats_xp_player_health_add_mode", "-1", {
	display = "Player Health Scaling Mode", desc = "If 1, player max health gained is applied multiplicatively rather than additively. \z
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

InsaneStats:RegisterConVar("xp_player_damage", "insanestats_xp_player_damage_add", "10", {
	display = "Player Damage Scaling", desc = "Player % damage dealt gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_player_damage_mode", "insanestats_xp_player_damage_add_mode", "-1", {
	display = "Player Damage Scaling Mode", desc = "If 1, player damage dealt gained is applied multiplicatively rather than additively. \z
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

InsaneStats:SetDefaultConVarCategory("XP - Non-Player Scales")

InsaneStats:RegisterConVar("xp_other_health", "insanestats_xp_other_health_add", "10", {
	display = "Non-player Health Scaling", desc = "Non-player % max health gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_health_mode", "insanestats_xp_other_health_add_mode", "-1", {
	display = "Non-player Health Scaling Mode", desc = "If 1, non-player max health gained is applied multiplicatively rather than additively. \z
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

InsaneStats:RegisterConVar("xp_other_damage", "insanestats_xp_other_damage_add", "10", {
	display = "Non-player Damage Scaling", desc = "Non-player % damage dealt gained per level.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("xp_other_damage_mode", "insanestats_xp_other_damage_add_mode", "-1", {
	display = "Non-player Damage Scaling Mode", desc = "If 1, non-player damage dealt gained is applied multiplicatively rather than additively. \z
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

function InsaneStats:ScaleValueToLevelPure(value, mul, level, multiplicative)
	if math.abs(level) == math.huge and (mul == 0 or value == 0) then
		return value
	elseif multiplicative then
		return value*(1+mul)^(level-1)
	else
		return value*(1+mul*(level-1))
	end
end

function InsaneStats:ScaleLevelFromValuePure(value, mul, start, multiplicative)
	if multiplicative then
		return math.log(value/start, 1+mul)+1
	else
		return (value/start-1)/mul+1
	end
end

function InsaneStats:ScaleValueToLevel(value, mul, level, mode, invertMode)
	local multiplicative = self:GetConVarValueDefaulted(mode, "xp_mode") > 0
	if invertMode then
		multiplicative = not multiplicative
	end
	return self:ScaleValueToLevelPure(value, mul, level, multiplicative)
end

function InsaneStats:ScaleValueToLevelQuadratic(value, mul, level, mode, invertMode, mul2)
	local multiplicative = self:GetConVarValueDefaulted(mode, "xp_mode") > 0
	if invertMode then
		multiplicative = not multiplicative
	end
	if not multiplicative then
		mul = self:ScaleValueToLevelPure(mul, mul2, level, false)
	end

	return self:ScaleValueToLevelPure(value, mul, level, multiplicative)
end

local function ScaleTotalValueToLevel(value, mul, level, multiplicative)
	if multiplicative then
		return -value/mul*(1-(mul+1)^(level-1))
	else
		-- value*(level-1+(level^2-3*level+2)*mul/2)
		return value*(level/2*(mul*(level-3)+2)+mul-1)
	end
end

function InsaneStats:ScaleLevelToTotalValue(value, mul, start, multiplicative)
	if multiplicative then
		-- value = -start/mul*(1-(mul+1)^(level-1))
		-- log(value/start*mul+1)/log((mul+1))+1 = level
		
		return math.log(math.max(value/start*mul+1, 0), mul+1)+1
	else
		--[[
		if c = a*(x-1+(x^2-3*x+2)*b/2)
		then x = (sqrt(a (b - 2)^2 + 8 b c) + sqrt(a) (3 b - 2))/(2 sqrt(a) b) and a b!=0, courtesy of WolframAlpha
		]]
		
		local part = math.sqrt(math.max(start*(mul - 2)^2 + 8*mul*value, 0))
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
	local rawValue = InsaneStats:ScaleLevelToTotalValue(
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

function InsaneStats:DetermineDamageMulPure(attacker, vic)
	local damageBonus = 1
	
	if self:GetConVarValue("xp_enabled") then
		local level = attacker:InsaneStats_GetLevel()
		if attacker:IsPlayer() then
			damageBonus = self:ScaleValueToLevel(
				damageBonus,
				self:GetConVarValue("xp_player_damage")/100,
				level,
				"xp_player_damage_mode"
			)
		else
			damageBonus = self:ScaleValueToLevel(
				damageBonus,
				self:GetConVarValue("xp_other_damage")/100,
				level,
				"xp_other_damage_mode"
			)
		end

		level = vic:InsaneStats_GetLevel()
		if vic:IsPlayer() then
			damageBonus = damageBonus / self:ScaleValueToLevel(
				1,
				self:GetConVarValue("xp_player_resistance")/100,
				level,
				"xp_player_resistance_mode"
			)
		else
			damageBonus = damageBonus / self:ScaleValueToLevel(
				1,
				self:GetConVarValue("xp_other_resistance")/100,
				level,
				"xp_other_resistance_mode"
			)
		end
	end

	return damageBonus
end

local ENT = FindMetaTable("Entity")

function ENT:InsaneStats_GetLevel()
	return self:InsaneStats_GetEntityData("level") or 1
end

function ENT:InsaneStats_GetLevelProgress()
	local level = self:InsaneStats_GetLevel()
	local xp = self:InsaneStats_GetXP()
	local previousXP = InsaneStats:GetXPRequiredToLevel(level)

	local currentXP = math.max(xp - previousXP, 0)
	local nextXP = InsaneStats:ScaleValueToLevel(
		InsaneStats:GetConVarValue("xp_scale_start"),
		InsaneStats:GetConVarValue("xp_scale_add")/100,
		level,
		"xp_scale_add_mode"
	)

	return currentXP, nextXP
end

function ENT:InsaneStats_GetLevelFraction()
	if self:InsaneStats_GetXP() == math.huge then
		return 1
	else
		local current, to = self:InsaneStats_GetLevelProgress()
		if to == math.huge then
			to = 2^(1024-2^-43)
		end
		return math.Clamp(current / to, 0, 1)
	end
end

function ENT:InsaneStats_GetXP()
	return self:InsaneStats_GetEntityData("xp") or 0
end

function ENT:InsaneStats_SetXP(xp, dropValue)
	if isstring(xp) then
		InsaneStats:Log("XP for %s attempted to be set to a string value \"%s\"!", tostring(self), xp)
		InsaneStats:Log("This is a bug, report this if you see this message!")
		debug.Trace()
		xp = tonumber(xp) or math.huge
	end
	assert(xp >= -math.huge, "Something tried to set XP on "..tostring(self).." to nan!")

	local maxMul = InsaneStats:GetConVarValue("xp_other_max_mul")
	if maxMul >= 0 and not self:IsPlayer() then
		local maxXP = -1
		for i,v in player.Iterator() do
			maxXP = math.max(maxXP, v:InsaneStats_GetEntityData("xp") or -1)
		end
		if maxXP >= 0 then
			maxXP = maxXP * maxMul
			if maxXP < xp then
				xp = maxXP
			end
		end
	end
	
	self:InsaneStats_SetEntityData("xp", xp)
	if xp > 0 then
		self.insaneStats_XPRoot8 = InsaneStats:CalculateRoot8(xp)
	end
	
	if dropValue then
		self:InsaneStats_SetDropXP(dropValue)
		if dropValue > 0 then
			self.insaneStats_DropXPRoot8 = InsaneStats:CalculateRoot8(dropValue)
		end
	end
	
	local newLevel = math.floor(InsaneStats:GetLevelByXPRequired(xp))
	-- self.insaneStats_Level can be nil
	if self:InsaneStats_GetEntityData("level") ~= newLevel and SERVER then
		hook.Run("InsaneStatsLevelChanged", self, self:InsaneStats_GetEntityData("level") or newLevel, newLevel)
		self:InsaneStats_ApplyLevel(newLevel)
	end
	
	self:InsaneStats_SetEntityData("level", newLevel)
    if SERVER then
	    self:InsaneStats_MarkForUpdate(2)
    end
end

function ENT:InsaneStats_GetIsAlpha(isAlpha)
	return tobool(self.insaneStats_IsAlpha)
end

function ENT:InsaneStats_SetIsAlpha(isAlpha)
	self.insaneStats_IsAlpha = tobool(isAlpha)
	if self:GetModelScale() == 1 and self:IsNPC() then
		self:SetModelScale(isAlpha and InsaneStats:GetConVarValue("xp_other_alpha_model_scale") or 1, 0.01)
	end
   --[[if SERVER then
	    self:InsaneStats_MarkForUpdate(4)
    end]]
end

function ENT:InsaneStats_AddXP(xp, addDropValue)
	return self:InsaneStats_SetXP(self:InsaneStats_GetXP() + xp, self:InsaneStats_GetDropXP() + addDropValue)
end

-- this is deprecated but turns out there's a part of D/GL4 that still needs this!
-- TODO: tell!
function ENT:InsaneStats_GetXPToNextLevel()
	local nextXP = InsaneStats:GetXPRequiredToLevel(self:InsaneStats_GetLevel() + 1)
	if not InsaneStats:GetConVarValue("hud_xp_cumulative") then
		nextXP = select(2, self:InsaneStats_GetLevelProgress())
	end
	return nextXP
end