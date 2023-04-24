InsaneStats:SetDefaultConVarCategory("Weapon Prefixes and Suffixes System 2")

InsaneStats:RegisterConVar("wpass2_enabled", "insanestats_wpass2_enabled", "1", {
	display = "Enable WPASS2", desc = "Enables WPASS2, allowing weapons / armor batteries to gain prefixes and suffixes.",
	type = InsaneStats.BOOL
})
InsaneStats.WPASS2_FLAGS = {
	ARMOR = 1,
	XP = 2,
	SCRIPTED_ONLY = 4,
	
	-- non-obvious combinations:
	-- 5: NEVER
	-- 7: same as 5
}

InsaneStats:RegisterConVar("wpass2_tier_start", "insanestats_wpass2_tier_start", "1", {
	display = "Starting Tier", desc = "Starting tier for weapons / armor batteries.",
	type = InsaneStats.FLOAT, min = 0, max = 10000
})
InsaneStats:RegisterConVar("wpass2_tier_start_battery", "insanestats_wpass2_tier_start_battery", "-1", {
	display = "Battery Starting Tier", desc = "If 0 or above, overrides insanestats_wpass2_tier_start for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 10000
})
InsaneStats:RegisterConVar("wpass2_tier_max", "insanestats_wpass2_tier_max", "999", {
	display = "Maximum Tier", desc = "Maximum possible weapon / armor battery tier.",
	type = InsaneStats.INT, min = 0, max = 10000
})
InsaneStats:RegisterConVar("wpass2_tier_max_battery", "insanestats_wpass2_tier_max_battery", "-1", {
	display = "Battery Maximum Tier", desc = "If 0 or above, overrides insanestats_wpass2_tier_max for armor batteries.",
	type = InsaneStats.INT, min = -1, max = 10000
})
InsaneStats:RegisterConVar("wpass2_tier_upchance", "insanestats_wpass2_tier_upchance", "70.71", {
	display = "Tier Up Chance", desc = "% chance for a weapon / armor battery to have its tier increased by 1. This is rolled for continuously until the roll fails.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_tier_upchance_battery", "insanestats_wpass2_tier_upchance_battery", "84.09", {
	display = "Battery Tier Up Chance", desc = "If 0 or above, overrides insanestats_wpass2_tier_upchance for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_tier_newmodifiercost", "insanestats_wpass2_tier_newmodifiercost", "2", {
	display = "New Modifier Cost", desc = "Number of tiers before another weapon / armor battery modifier is attached. Tier 1 weapons / armor batteries will always have one modifier.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_tier_newmodifiercost_battery", "insanestats_wpass2_tier_newmodifiercost_battery", "4", {
	display = "New Battery Modifier Cost", desc = "If 0 or above, overrides insanestats_wpass2_tier_newmodifiercost for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_tier_raritycost", "insanestats_wpass2_tier_raritycost", "2", {
	display = "Tiers Per Rarity", desc = "Number of tiers per rarity.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_tier_raritycost_battery", "insanestats_wpass2_tier_raritycost_battery", "4", {
	display = "Battery Tiers Per Rarity", desc = "If 0 or above, overrides insanestats_wpass2_tier_raritycost for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})

InsaneStats:RegisterConVar("wpass2_chance_unowned", "insanestats_wpass2_chance_unowned", "20", {
	display = "Unowned Chance", desc = "Chance for an unowned weapon / armor battery to be above tier 0, creating at least a tier 1 weapon / armor battery. \z
		Note that weapons / armor batteries above tier 0 cannot be picked up for ammo / armor.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_unowned_battery", "insanestats_wpass2_chance_unowned_battery", "-1", {
	display = "Unowned Battery Chance", desc = "If 0 or above, overrides insanestats_wpass2_chance_unowned for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_player", "insanestats_wpass2_chance_player", "100", {
	display = "Player Chance", desc = "Chance for a player-owned weapon / armor battery to be above tier 0.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_player_battery", "insanestats_wpass2_chance_player_battery", "-1", {
	display = "Player Battery Chance", desc = "If 0 or above, overrides insanestats_wpass2_chance_player for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_player_drop", "insanestats_wpass2_chance_player_drop", "100", {
	display = "Player Drop Chance", desc = "Chance for dead players to drop their weapon / armor battery. Note that other addons can still force players to drop their weapon on death.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_player_drop_battery", "insanestats_wpass2_chance_player_drop_battery", "0", {
	display = "Player Battery Drop Chance", desc = "If 0 or above, overrides insanestats_wpass2_chance_player_drop for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_other", "insanestats_wpass2_chance_other", "20", {
	display = "Non-player Chance", desc = "Chance for an NPC owned weapon / armor battery to be above tier 0.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_other_battery", "insanestats_wpass2_chance_other_battery", "-1", {
	display = "Non-player Battery Chance", desc = "If 0 or above, overrides insanestats_wpass2_chance_other for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_other_battery_sensible", "insanestats_wpass2_chance_other_battery_sensible", "1", {
	display = "Sensible NPCs Only", desc = "If enabled, only humanoid and Combine entities are able to spawn with a modified armor battery.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("wpass2_chance_other_drop", "insanestats_wpass2_chance_other_drop", "100", {
	display = "Non-player Drop Chance", desc = "Chance for NPCs to drop their weapon / armor battery. This only applies in maps where NPCs do not normally drop their weapons.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_other_drop_battery", "insanestats_wpass2_chance_other_drop_battery", "-1", {
	display = "Non-player Battery Drop Chance", desc = "If 0 or above, overrides insanestats_wpass2_chance_other_drop for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})

InsaneStats:RegisterConVar("wpass2_attributes_player_enabled", "insanestats_wpass2_attributes_player_enabled", "1", {
	display = "Player Attirbute Effects", desc = "If disabled, modified weapons / armor batteries will have no effect on players.",
	type = InsaneStats.INT, min = 0, max = 1
})
InsaneStats:RegisterConVar("wpass2_attributes_player_enabled_battery", "insanestats_wpass2_attributes_player_enabled_battery", "-1", {
	display = "Player Battery Attirbute Effects", desc = "If 0 or above, overrides insanestats_wpass2_effects_player_enabled for armor batteries.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("wpass2_attributes_other_enabled", "insanestats_wpass2_attributes_other_enabled", "1", {
	display = "Non-player Attirbute Effects", desc = "If disabled, modified weapons / armor batteries will have no effect on NPCs.",
	type = InsaneStats.INT, min = 0, max = 1
})
InsaneStats:RegisterConVar("wpass2_attributes_other_enabled_battery", "insanestats_wpass2_attributes_other_enabled_battery", "-1", {
	display = "Non-player Battery Attirbute Effects", desc = "If 0 or above, overrides insanestats_wpass2_effects_other_enabled for armor batteries.",
	type = InsaneStats.INT, min = -1, max = 1
})

InsaneStats:RegisterConVar("wpass2_tier_xp_enable", "insanestats_wpass2_tier_xp_enable", "1", {
	display = "Experience Integration", desc = "Allows the weapon's / armor battery's level to influence its tier. Only relevant when Insane Stats XP is enabled.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("wpass2_tier_xp_level_start", "insanestats_wpass2_tier_xp_level_start", "5", {
	display = "Starting Level", desc = "Level before weapons / armor batteries are guaranteed to be tier 1. Below this, weapons / armor batteries may sometimes spawn at tier 0 even after passing the insanestats_wpass2_chance_* check.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("wpass2_tier_xp_level_start_battery", "insanestats_wpass2_tier_xp_level_start_battery", "2.5", {
	display = "Battery Starting Level", desc = "If 0 or above, overrides insanestats_wpass2_xp_tier_levelstart for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 1000
})
InsaneStats:RegisterConVar("wpass2_tier_xp_level_add", "insanestats_wpass2_tier_xp_level_add", "100", {
	display = "Level Scaling", desc = "% additional levels needed per tier up.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("wpass2_tier_xp_level_add_battery", "insanestats_wpass2_tier_xp_level_add_battery", "41.42", {
	display = "Battery Level Scaling", desc = "If 0 or above, overrides insanestats_wpass2_tier_xp_level_add for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 1000
})
InsaneStats:RegisterConVar("wpass2_tier_xp_level_add_mode", "insanestats_wpass2_tier_xp_level_add_mode", "-1", {
	display = "Level Mode", desc = "If enabled, the level tier up % is applied additively rather than multiplicatively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})

local doWeaponOverride = false
local entities = {}
timer.Create("InsaneStatsSharedWPASS", 0.5, 0, function()
	-- the reason we don't alter for DLib is to prevent functions from returning true, which would break our bullets
	local hookTable = hook.GetTable()
	local entityFireBulletsHooks = hookTable.EntityFireBullets
	local nonInsaneStatsHooks = hookTable.NonInsaneStatsEntityFireBullets or {}
	
	if entityFireBulletsHooks and doWeaponOverride then
		for k,v in pairs(entityFireBulletsHooks) do
			if tostring(InsaneStats.NOP) ~= tostring(v) and k ~= "InsaneStats" then
				hook.Add("NonInsaneStatsEntityFireBullets", k, v)
				hook.Add("EntityFireBullets", k, InsaneStats.NOP)
			end
		end
	end
	
	if nonInsaneStatsHooks then
		for k,v in pairs(nonInsaneStatsHooks) do
			if not entityFireBulletsHooks[k] then -- it's gone!
				hook.Remove("NonInsaneStatsEntityFireBullets", k)
			elseif not doWeaponOverride then -- put it back!
				hook.Add("EntityFireBullets", k, v)
				hook.Remove("NonInsaneStatsEntityFireBullets", k)
			end
		end
	end
	
	entities = {}
	for k,v in pairs(ents.GetAll()) do
		if v:InsaneStats_GetHealth() > 0 then
			table.insert(entities, v)
		end
	end
end)

local WEAPON = FindMetaTable("Weapon")
local PLAYER = FindMetaTable("Player")

local function OverrideWeapons()
	if not WEAPON.InsaneStats_SetRawNextPrimaryFire then
		WEAPON.InsaneStats_SetRawNextPrimaryFire = WEAPON.SetNextPrimaryFire
		WEAPON.InsaneStats_SetRawNextSecondaryFire = WEAPON.SetNextSecondaryFire
		WEAPON.InsaneStats_SetRawClip1 = WEAPON.SetClip1
		WEAPON.InsaneStats_SetRawClip2 = WEAPON.SetClip2
		
		PLAYER.InsaneStats_RemoveRawAmmo = PLAYER.RemoveAmmo
		PLAYER.InsaneStats_SetRawAmmo = PLAYER.SetAmmo
	end
	
	function WEAPON:SetNextPrimaryFire(nextTime)
		local data = {next = nextTime, wep = self, attacker = self:GetOwner()}
		hook.Run("InsaneStatsModifyNextFire", data)
		
		return self:InsaneStats_SetRawNextPrimaryFire(data.next)
	end
	
	function WEAPON:SetNextSecondaryFire(nextTime)
		local data = {next = nextTime, wep = self, attacker = self:GetOwner()}
		hook.Run("InsaneStatsModifyNextFire", data)
		
		return self:InsaneStats_SetRawNextSecondaryFire(data.next)
	end
	
	function WEAPON:SetClip1(num)
		local data = {new = num, old = self.insaneStats_LastClip1 or self:Clip1(), wep = self}
		hook.Run("InsaneStatsModifyWeaponClip", data)
		
		return self:InsaneStats_SetRawClip1(data.new)
	end
	
	function WEAPON:SetClip2(num)
		local data = {new = num, old = self.insaneStats_LastClip2 or self:Clip2(), wep = self}
		hook.Run("InsaneStatsModifyWeaponClip", data)
		
		return self:InsaneStats_SetRawClip2(data.new)
	end
	
	function PLAYER:RemoveAmmo(num, ammoType)
		local data = {num = num, type = ammoType, ply = self}
		hook.Run("InsaneStatsPlayerRemoveAmmo", data)
		
		return self:InsaneStats_RemoveRawAmmo(data.num)
	end
	
	function PLAYER:SetAmmo(num, ammoType)
		local data = {new = num, old = self.insaneStats_OldSetAmmoValue or self:GetAmmoCount(ammoType), type = ammoType, ply = self}
		hook.Run("InsaneStatsPlayerSetAmmo", data)
		
		return self:InsaneStats_SetRawAmmo(data.new, data.type)
	end
end

local function DeOverrideWeapons()
	if WEAPON.InsaneStats_SetRawNextPrimaryFire then
		WEAPON.SetNextPrimaryFire = WEAPON.InsaneStats_SetRawNextPrimaryFire
		WEAPON.SetNextSecondaryFire = WEAPON.InsaneStats_SetRawNextSecondaryFire
		WEAPON.SetClip1 = WEAPON.InsaneStats_SetRawClip1
		WEAPON.SetClip2 = WEAPON.InsaneStats_SetRawClip2
		
		PLAYER.RemoveAmmo = PLAYER.InsaneStats_RemoveRawAmmo
		PLAYER.SetAmmo = PLAYER.InsaneStats_SetRawAmmo
		
		WEAPON.InsaneStats_SetRawNextPrimaryFire = nil
		WEAPON.InsaneStats_SetRawNextSecondaryFire = nil
		WEAPON.InsaneStats_SetRawClip1 = nil
		WEAPON.InsaneStats_SetRawClip2 = nil
		
		PLAYER.InsaneStats_RemoveRawAmmo = nil
		PLAYER.InsaneStats_SetRawAmmo = nil
	end
end

local function CheckOverrideWeapons()
	if doWeaponOverride ~= InsaneStats:GetConVarValue("wpass2_enabled") then
		doWeaponOverride = InsaneStats:GetConVarValue("wpass2_enabled")
		if doWeaponOverride then
			OverrideWeapons()
		else
			DeOverrideWeapons()
		end
	end
end

hook.Add("EntityFireBullets", "InsaneStats", function(attacker, data, ...)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		-- run the others first, but in a more roundabout way
		local nonInsaneStatsHooks = hook.GetTable().NonInsaneStatsEntityFireBullets or {}
		local shouldAlter = false
		for k,v in pairs(nonInsaneStatsHooks) do
			local ret = v(attacker, data, ...)
			if ret then
				shouldAlter = true
			elseif ret == false then return false end
		end
		
		if shouldAlter then return true end
	end
end)

local registeredEffects, modifiers, attributes = {}, {}, {}
local effectNamesToIDs = {}
local effectIDsToNames = {}
local expiryEffects = {}
local function MapStatusEffectNamesToIDs()
	effectNamesToIDs = {}
	effectIDsToNames = {}
	
	for k,v in SortedPairs(registeredEffects) do
		effectNamesToIDs[k] = table.insert(effectIDsToNames, k)
		expiryEffects[k] = v.expiry
	end
	
	--print("Client: ", CLIENT)
	--PrintTable(effectNamesToIDs)
end

hook.Add("Initialize", "InsaneStatsSharedWPASS", function()
	modifiers, attributes = {}, {}
	hook.Run("InsaneStatsLoadWPASS", modifiers, attributes, registeredEffects)
	MapStatusEffectNamesToIDs()
	hook.Run("InsaneStatsPostLoadWPASS", modifiers, attributes, registeredEffects)
end)

hook.Run("InsaneStatsLoadWPASS", modifiers, attributes, registeredEffects)
MapStatusEffectNamesToIDs()
hook.Run("InsaneStatsPostLoadWPASS", modifiers, attributes, registeredEffects)

function InsaneStats:GetAllModifiers()
	return modifiers
end

function InsaneStats:GetAllAttributes()
	return attributes
end

function InsaneStats:GetAllStatusEffects()
	return registeredEffects
end

function InsaneStats:GetStatusEffectID(name)
	return effectNamesToIDs[name]
end

function InsaneStats:GetStatusEffectNames()
	return effectIDsToNames
end

function InsaneStats:GetStatusEffectName(id)
	return effectIDsToNames[id]
end

function InsaneStats:GetStatusEffectInfo(id)
	return registeredEffects[id]
end

function InsaneStats:ApplyWPASS2Attributes(wep)
	local wepAttributes = {}
	for k,v in pairs(wep.insaneStats_Modifiers or {}) do
		for k2,v2 in pairs(modifiers[k] and modifiers[k].modifiers or {}) do
			local startValue = attributes[k2].start or 1
			if attributes[k2].mode == 1 then
				wepAttributes[k2] = 1 - (1-(wepAttributes[k2] or startValue)) * v2 ^ v
			elseif attributes[k2].mode == 2 then
				wepAttributes[k2] = 2 - (wepAttributes[k2] or startValue) * v2 ^ v
			elseif attributes[k2].mode == 3 then
				wepAttributes[k2] = (wepAttributes[k2] or startValue) + v2 * v
			else
				local mulValue = attributes[k2].mul or 1
				wepAttributes[k2] = mulValue * ((wepAttributes[k2] or startValue) * v2 ^ v - 1) + 1
			end
		end
	end
	
	--[[if wepAttributes.clip and wep:IsScripted() then
		local weaponTable = wep:GetTable()
		if weaponTable.Primary then
			weaponTable.Primary.ClipSize = math.ceil(weaponTable.Primary.ClipSize * wepAttributes.clip)
		end
		if weaponTable.Secondary then
			weaponTable.Secondary.ClipSize = math.ceil(weaponTable.Secondary.ClipSize * wepAttributes.clip)
		end
	end]]
	
	for k,v in pairs(wepAttributes) do
		if v == 1 then -- remove
			wepAttributes[k] = nil
		end
	end
	
	wep.insaneStats_Attributes = wepAttributes
end

local ENTITY = FindMetaTable("Entity")

function ENTITY:InsaneStats_GetAttributeValue(attribute)
	local totalMul = 1
	local weaponEffectVar = self:IsPlayer() and "wpass2_attributes_player_enabled" or "wpass2_attributes_other_enabled"
	local weaponHasEffect = InsaneStats:GetConVarValue(weaponEffectVar)
	local armorBatteryHasEffect = InsaneStats:GetConVarValueDefaulted(weaponEffectVar.."_battery", weaponEffectVar)
	
	if armorBatteryHasEffect > 0 then
		totalMul = totalMul * (self.insaneStats_Attributes and self.insaneStats_Attributes[attribute] or 1)
	end
	
	local wep = weaponHasEffect > 0 and self.GetActiveWeapon and self:GetActiveWeapon()
	if IsValid(wep) then
		totalMul = totalMul * (wep.insaneStats_Attributes and wep.insaneStats_Attributes[attribute] or 1)
	end
	
	return totalMul
end

function ENTITY:InsaneStats_IsWPASS2Pickup()
	return self:IsWeapon() or self:GetClass() == "item_battery"
end

local function EntityInitStatusEffects(ent)
	ent.insaneStats_StatusEffects = ent.insaneStats_StatusEffects or {}
	if SERVER then
		ent.insaneStats_StatusEffectsToNetwork = ent.insaneStats_StatusEffectsToNetwork or {}
	end
end

local function DoExpiryEffect(ent, statName)
	local statusData = ent.insaneStats_StatusEffects and ent.insaneStats_StatusEffects[statName]
	if expiryEffects[statName] and statusData then
		expiryEffects[statName](ent, statusData.level or 0, statusData.attacker)
	end
end

function ENTITY:InsaneStats_ApplyStatusEffect(id, level, duration, data)
	EntityInitStatusEffects(self)
	local effectTable = self.insaneStats_StatusEffects[id]
	
	data = data or {}
	if effectTable and effectTable.expiry > CurTime() then
		if data.extend and level >= effectTable.level then
			effectTable.expiry = effectTable.expiry + duration
		else
			effectTable.expiry = math.max(effectTable.expiry, CurTime() + duration)
		end
		
		if data.amplify then
			effectTable.level = effectTable.level + level
		else
			effectTable.level = math.max(effectTable.level, level)
		end
		
		effectTable.attacker = data.attacker or effectTable.attacker
	else
		self.insaneStats_StatusEffects[id] = {
			expiry = CurTime() + duration,
			level = level,
			attacker = data.attacker
		}
	end
	
	if SERVER then
		self.insaneStats_StatusEffectsToNetwork[id] = true
		self:InsaneStats_MarkForUpdate(16)
	end
end

function ENTITY:InsaneStats_SetStatusEffectLevel(id, level)
	EntityInitStatusEffects(self)
	if level == 0 then
		DoExpiryEffect(self, id)
		self.insaneStats_StatusEffects[id] = nil
	else
		local effectTable = self.insaneStats_StatusEffects[id]
		if effectTable then
			effectTable.level = level
		end
	end
	
	if SERVER then
		self.insaneStats_StatusEffectsToNetwork[id] = true
		self:InsaneStats_MarkForUpdate(16)
	end
end

function ENTITY:InsaneStats_ClearStatusEffect(id)
	EntityInitStatusEffects(self)
	DoExpiryEffect(self, id)
	self.insaneStats_StatusEffects[id] = nil
	
	if SERVER then
		self.insaneStats_StatusEffectsToNetwork[id] = true
		self:InsaneStats_MarkForUpdate(16)
	end
end

function ENTITY:InsaneStats_GetStatusEffectLevel(id)
	EntityInitStatusEffects(self)
	return self.insaneStats_StatusEffects[id]
	and self.insaneStats_StatusEffects[id].expiry >= CurTime()
	and self.insaneStats_StatusEffects[id].level
	or 0
end

function ENTITY:InsaneStats_GetStatusEffectDuration(id)
	EntityInitStatusEffects(self)
	return self.insaneStats_StatusEffects[id]
	and self.insaneStats_StatusEffects[id].expiry >= CurTime()
	and self.insaneStats_StatusEffects[id].expiry - CurTime()
	or 0
end

function ENTITY:InsaneStats_GetStatusEffectAttacker(id)
	EntityInitStatusEffects(self)
	return self.insaneStats_StatusEffects[id]
	and self.insaneStats_StatusEffects[id].expiry >= CurTime()
	and self.insaneStats_StatusEffects[id].attacker
end

function ENTITY:InsaneStats_GetStatusEffectCountByType(typ)
	EntityInitStatusEffects(self)
	local count = 0
	for k,v in pairs(self.insaneStats_StatusEffects) do
		if v.typ == typ then
			count = count + 1
		end
	end
	return count
end

function ENTITY:InsaneStats_ClearStatusEffectsByType(typ)
	EntityInitStatusEffects(self)
	for k,v in pairs(self.insaneStats_StatusEffects) do
		local statusEffectInfo = registeredEffects[k]
		if statusEffectInfo.typ == typ then
			DoExpiryEffect(self, k)
			self.insaneStats_StatusEffects[k] = nil
			if SERVER then
				self.insaneStats_StatusEffectsToNetwork[k] = true
			end
		end
	end
	
	if SERVER then
		self:InsaneStats_MarkForUpdate(16)
	end
end

hook.Add("Think", "InsaneStatsSharedWPASS", function()
	CheckOverrideWeapons()
	
	for k,v in pairs(entities) do
		if v.insaneStats_StatusEffects then
			for k2,v2 in pairs(expiryEffects) do
				--print(v, k2, v.insaneStats_StatusEffects[k2])
				if (v.insaneStats_StatusEffects[k2] and (v.insaneStats_StatusEffects[k2].expiry or 0) < CurTime()) then
					DoExpiryEffect(v, k2)
					v.insaneStats_StatusEffects[k2] = nil
				end
			end
		end
	end
end)