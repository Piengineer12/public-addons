local ConEnabled = CreateConVar("insanestats_wpass2_enabled", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
"Enables WPASS2, allowing weapons and armor batteries to gain prefixes and suffixes.")
local ConTierStart = CreateConVar("insanestats_wpass2_tier", "1", FCVAR_ARCHIVE,
"Starting tier for weapons and armor batteries.")
local ConTierProbability = CreateConVar("insanestats_wpass2_chance", "20", FCVAR_ARCHIVE,
"Chance for a weapon or armor battery to be above tier 0. Successful rolls will create at least a tier 1 weapon or armor battery. \z
Note that weapons and armor batteries above tier 0 cannot be picked up for ammo and armor, respectively.")
local ConTierEnd = CreateConVar("insanestats_wpass2_tiermax", "999", FCVAR_ARCHIVE,
"Maximum possible weapon or armor battery tier.", 0, 9999)
local ConTierUpProbability = CreateConVar("insanestats_wpass2_tierupchance", "50", FCVAR_ARCHIVE,
"% chance for a weapon or armor battery to have its tier increased by 1. This is rolled for continuously until \z
either the roll fails or 9,999 rolls have been performed.")
local ConTiersPerModifier = CreateConVar("insanestats_wpass2_tierspermodifier", "2", FCVAR_ARCHIVE,
"Number of tiers before another weapon or armor battery modifier is attached. Tier 1 weapons and armor batteries will always have one modifier.")

local ConXPTierEnabled = CreateConVar("insanestats_wpass2_xp_tierenable", "1", FCVAR_ARCHIVE,
"Allows weapon level to influence weapon tier. Only relevant when Insane Stats XP is enabled.")
local ConXPTierStartLevel = CreateConVar("insanestats_wpass2_xp_tierlevelstart", "5", FCVAR_ARCHIVE,
"Level before weapons are guaranteed to be tier 1. Below this, weapons may sometimes spawn at tier 0 even after passing the insanestats_wpass2_chance check.")
local ConXPTierUpLevel = CreateConVar("insanestats_wpass2_xp_tierleveladd", "100", FCVAR_ARCHIVE,
"% additional levels needed per tier up.")
local ConXPTierUpLevelMode = CreateConVar("insanestats_wpass2_xp_tierleveladdmode", "0", FCVAR_ARCHIVE,
"If enabled, the level tier up % is applied multiplicatively rather than additively.")

local ConHoldTime = CreateConVar("insanestats_wpass2_hudhold", "4", FCVAR_ARCHIVE,
"Amount of time to display weapon information.")
local ConTierUpRarityUp = CreateConVar("insanestats_wpass2_hudraritytiermul", "2", FCVAR_ARCHIVE,
"Number of tiers per rarity.")

local rarityNames = {
	"Junk",
	"Common",
	"Uncommon",
	"Rare",
	"Epic",
	"Supreme",
	"Legendary",
	"Intangible",
	"Galactic",
	"Monstrous",
	"Aetheric",
	"Mythical Common",
	"Mythical Uncommon",
	"Mythical Rare",
	"Mythical Epic",
	"Mythical Supreme",
	"Mythical Legendary",
	"Mythical Intangible",
	"Mythical Galactic",
	"Mythical Monstrous",
	"Mythical Aetheric",
	"Ultimate Common",
	"Ultimate Uncommon",
	"Ultimate Rare",
	"Ultimate Epic",
	"Ultimate Supreme",
	"Ultimate Legendary",
	"Ultimate Intangible",
	"Ultimate Galactic",
	"Ultimate Monstrous",
	"Ultimate Aetheric",
	"Ultimate Mythical",
	"Rainbow",
}

local registeredEffects = {}
local effectNamesToIDs = {}
local effectIDsToNames = {}
local function MapStatusEffectNamesToIDs()
	effectNamesToIDs = {}
	effectIDsToNames = {}
	
	for k,v in SortedPairs(registeredEffects) do
		effectNamesToIDs[k] = table.insert(effectIDsToNames, k)
	end
end

local modifiers, attributes = {}, {}
hook.Add("Initialize", "InsaneStatsWPASS", function()
	modifiers, attributes = {}, {}
	hook.Run("InsaneStatsLoadWPASS", modifiers, attributes, registeredEffects)
	MapStatusEffectNamesToIDs()
end)

hook.Run("InsaneStatsLoadWPASS", modifiers, attributes, registeredEffects)
MapStatusEffectNamesToIDs()

function InsaneStats_GetStatusEffectID(name)
	return effectNamesToIDs[name]
end

function InsaneStats_GetStatusEffectName(id)
	return effectIDsToNames[id]
end

local function SelectWeightedRandom(tab)
	local possibleSelections = {}
	local selectionGaps = {}
	
	local weightSum = 0
	for k,v in pairs(tab) do
		table.insert(possibleSelections, k)
		weightSum = weightSum + v
		table.insert(selectionGaps, weightSum)
	end
	
	-- generate a random number, then see where it fits
	local selection = math.random()*weightSum
	for i,v in ipairs(selectionGaps) do
		if selection < v then return possibleSelections[i] end
	end
	
	error("Failed to choose weighted random choice!")
end

local function ApplyWPASS2Tier(ent)
	-- figure out weapon tier
	if math.random()*100 < ConTierProbability:GetFloat() then
		local tier = ConTierStart:GetFloat()
		
		if GetConVar("insanestats_xp_enabled"):GetBool() and ConXPTierEnabled:GetBool() then
			local effectiveLevel = ent:InsaneStats_GetLevel()
			if not (ent:IsWeapon() or ent:GetClass() == "item_battery") then
				--print(ent)
				ent.insaneStats_BatteryXP = InsaneStats_DetermineEntitySpawnedXP(ent:GetPos())
				if not ent.insaneStats_BatteryXP then return false end
				effectiveLevel = math.floor(InsaneStats_GetLevelByXPRequired(ent.insaneStats_BatteryXP))
			end
			if ConXPTierUpLevelMode:GetBool() then
				local distanceBetweenTiers = 1 + ConXPTierUpLevel:GetFloat() / 100
				local invertedStartForTiers = distanceBetweenTiers / ConXPTierStartLevel:GetFloat()
				tier = tier + math.log(effectiveLevel * invertedStartForTiers, distanceBetweenTiers)
			else
				local distanceBetweenTiers = ConXPTierStartLevel:GetFloat() * ConXPTierUpLevel:GetFloat() / 100
				local startForTiers = ConXPTierStartLevel:GetFloat() - distanceBetweenTiers
				tier = tier + (effectiveLevel - startForTiers) / distanceBetweenTiers
			end
		end
		
		local rolls = 0
		local chance = ConTierUpProbability:GetFloat()
		
		while rolls < 12058 and math.random()*100 < chance and tier < ConTierEnd:GetInt() do
			rolls = rolls + 1
			tier = tier + 1
		end
		
		if math.random() < tier % 1 then
			tier = math.ceil(tier)
		else
			tier = math.floor(tier)
		end
		ent.insaneStats_Tier = math.Clamp(tier, 0, math.Clamp(ConTierEnd:GetInt(), 0, 9999))
	else
		ent.insaneStats_Tier = 0
	end
	
	return true
end

function InsaneStats_ApplyWPASS2Modifiers(wep)
	if not ApplyWPASS2Tier(wep) then return end -- determine at runtime instead
	
	-- assemble modifier probabilities
	local inclusiveFlags = 0
	if not wep:IsWeapon() then
		inclusiveFlags = bit.bor(inclusiveFlags, 1)
	elseif wep:IsScripted() then
		inclusiveFlags = bit.bor(inclusiveFlags, 4)
	end
	if GetConVar("insanestats_xp_enabled"):GetBool() then
		inclusiveFlags = bit.bor(inclusiveFlags, 2)
	end
	
	local modifierProbabilities = {}
	for k,v in pairs(modifiers) do
		if not (v.flags and bit.band(inclusiveFlags, v.flags) ~= v.flags) then
			local weight = v.weight or 1
			-- if a modifier DOES NOT have bitflag 1 and inclusiveFlags DOES, halve the probability
			if bit.band(v.flags or 0, 1) == 0 and bit.band(inclusiveFlags, 1) ~= 0 then
				weight = weight / 2
			end
			modifierProbabilities[k] = weight
		end
	end
	
	local applyModifiers = {}
	local rolls = 0
	local points = wep.insaneStats_Tier
	local modifiersLeft = math.ceil(points / ConTiersPerModifier:GetFloat())
	while rolls < 12058 and points > 0 do
		rolls = rolls + 1
		
		-- check each entry and remove inapplicable ones
		for k,v in pairs(modifierProbabilities) do
			local modifierTable = modifiers[k]
			
			if (modifierTable.cost or 1) > points or modifiersLeft < 1 and not applyModifiers[k] then
				modifierProbabilities[k] = nil
			end
		end
		
		if next(modifierProbabilities) then
			local appliedModifier = SelectWeightedRandom(modifierProbabilities)
			if applyModifiers[appliedModifier] then
				applyModifiers[appliedModifier] = applyModifiers[appliedModifier] + 1
			else
				applyModifiers[appliedModifier] = 1
				modifiersLeft = modifiersLeft - 1
			end
			
			local modifierTable = modifiers[appliedModifier]
			points = points - (modifierTable.cost or 1)
			if applyModifiers[appliedModifier] >= (modifierTable.max or 65536) then
				modifierProbabilities[appliedModifier] = nil
			end
		elseif modifiersLeft < 1 then
			modifiersLeft = modifiersLeft + 1
			
			-- refill entries since we get one more modifier to work with
			for k,v in pairs(modifiers) do
				if not (v.flags and bit.band(applicableFlags, v.flags) ~= v.flags) and (applyModifiers[k] or 0) < (v.max or 65536) then
					modifierProbabilities[k] = v.weight or 1
				end
			end
		else break
		end
	end
	
	wep.insaneStats_Modifiers = applyModifiers
	
	InsaneStats_ApplyWPASS2Attributes(wep)
	wep:InsaneStats_MarkForUpdate(8)
end

function InsaneStats_ApplyWPASS2Attributes(wep)
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
				wepAttributes[k2] = (wepAttributes[k2] or startValue) * v2 ^ v
			end
		end
	end
	
	if wepAttributes.clip and wep:IsScripted() then
		local weaponTable = wep:GetTable()
		if weaponTable.Primary then
			weaponTable.Primary.ClipSize = math.ceil(weaponTable.Primary.ClipSize * wepAttributes.clip)
		end
		if weaponTable.Secondary then
			weaponTable.Secondary.ClipSize = math.ceil(weaponTable.Secondary.ClipSize * wepAttributes.clip)
		end
	end
	
	for k,v in pairs(wepAttributes) do
		if v == 1 then -- remove
			wepAttributes[k] = nil
		end
	end
	
	wep.insaneStats_Attributes = wepAttributes
end

local WEAPON = FindMetaTable("Weapon")

local function OverrideWeapons()
	if not WEAPON.InsaneStats_SetRawNextPrimaryFire then
		WEAPON.InsaneStats_SetRawNextPrimaryFire = WEAPON.SetNextPrimaryFire
		WEAPON.InsaneStats_SetRawNextSecondaryFire = WEAPON.SetNextSecondaryFire
	end
	
	function WEAPON:SetNextPrimaryFire(nextTime)
		local data = {next = nextTime, wep = self}
		hook.Run("InsaneStatsModifyNextFire", data)
		
		return self:InsaneStats_SetRawNextPrimaryFire(data.next)
	end
	
	function WEAPON:SetNextSecondaryFire(nextTime)
		local data = {next = nextTime, wep = self}
		hook.Run("InsaneStatsModifyNextFire", data)
		
		return self:InsaneStats_SetRawNextSecondaryFire(data.next)
	end
end

local function DeOverrideWeapons()
	if WEAPON.InsaneStats_SetRawNextPrimaryFire then
		WEAPON.SetNextPrimaryFire = WEAPON.InsaneStats_SetRawNextPrimaryFire
		WEAPON.SetNextSecondaryFire = WEAPON.InsaneStats_SetRawNextSecondaryFire
		
		WEAPON.InsaneStats_SetRawNextPrimaryFire = nil
		WEAPON.InsaneStats_SetRawNextSecondaryFire = nil
	end
end

local doWeaponOverride = false
local expensiveThinkCooldown = 0
hook.Add("Think", "InsaneStatsWPASS", function()
	if doWeaponOverride ~= ConEnabled:GetBool() then
		doWeaponOverride = ConEnabled:GetBool()
		if doWeaponOverride then
			OverrideWeapons()
		else
			DeOverrideWeapons()
		end
	end
	
	if expensiveThinkCooldown < RealTime() then
		expensiveThinkCooldown = RealTime() + 1
		
		local hookTable = hook.GetTable()
		local entityFireBulletsHooks = hookTable.EntityFireBullets
		local nonInsaneStatsHooks = hookTable.NonInsaneStatsEntityFireBullets or {}
		
		if entityFireBulletsHooks and doWeaponOverride then
			for k,v in pairs(entityFireBulletsHooks) do
				if tostring(InsaneStats_nop) ~= tostring(v) and k ~= "InsaneStats" then
					hook.Add("NonInsaneStatsEntityFireBullets", k, v)
					hook.Add("EntityFireBullets", k, InsaneStats_nop)
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
	end
end)

hook.Add("EntityFireBullets", "InsaneStats", function(attacker, data, ...)
	if ConEnabled:GetBool() then
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

local ENTITY = FindMetaTable("Entity")

function ENTITY:InsaneStats_GetCombatTime()
	if self.insaneStats_LastCombatTime and self.insaneStats_LastCombatTime + 5 < CurTime() then
		self.insaneStats_StartCombatTime = nil
	end
	return self.insaneStats_StartCombatTime and CurTime() - self.insaneStats_StartCombatTime or -1
end

function ENTITY:InsaneStats_UpdateCombatTime()
	if self.insaneStats_LastCombatTime and self.insaneStats_LastCombatTime + 5 < CurTime() then
		self.insaneStats_StartCombatTime = nil
	end
	if not self.insaneStats_StartCombatTime then
		self.insaneStats_StartCombatTime = CurTime()
	end
	self.insaneStats_LastCombatTime = CurTime()
end

function ENTITY:InsaneStats_GetAttributeValue(attribute)
	local totalMul = 1
	totalMul = totalMul * (self.insaneStats_Attributes and self.insaneStats_Attributes[attribute] or 1)
	local wep = self.GetActiveWeapon and self:GetActiveWeapon()
	if IsValid(wep) then
		totalMul = totalMul * (wep.insaneStats_Attributes and wep.insaneStats_Attributes[attribute] or 1)
	end
	return totalMul
end

function ENTITY:InsaneStats_IsWPASS2Able()
	return self:IsWeapon() or self:GetClass() == "item_battery"
end

local function EntityInitStatusEffects(ent)
	ent.insaneStats_StatusEffects = ent.insaneStats_StatusEffects or {}
	if SERVER then
		ent.insaneStats_StatusEffectsToNetwork = ent.insaneStats_StatusEffectsToNetwork or {}
	end
end

function ENTITY:InsaneStats_ApplyStatusEffect(id, level, duration, data)
	EntityInitStatusEffects(self)
	local effectTable = self.insaneStats_StatusEffects[id]
	
	data = data or {}
	if data.damage then
		level = level + data.damage / self:InsaneStats_GetFractionalMaxHealth() * 100
		if effectTable then
			level = level + effectTable.level
		end
	end
	
	if effectTable then
		effectTable.expiry = math.max(effectTable.expiry, CurTime() + duration)
		effectTable.level = math.max(effectTable.level, level)
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

if SERVER then
	
	function ENTITY:InsaneStats_AddArmorNerfed(armor)
		local unnerfedArmorRestored = math.Clamp(self:InsaneStats_GetFractionalMaxArmor() - self:InsaneStats_GetFractionalArmor(), 0, armor)
		armor = armor - unnerfedArmorRestored
		self:SetArmor(self:InsaneStats_GetFractionalArmor() + unnerfedArmorRestored)
		
		if armor > 0 then
			-- nerfed amount, yes it is a bit complicated
			local currentArmorPercent = self:InsaneStats_GetFractionalArmor() / self:InsaneStats_GetFractionalMaxArmor()
			local wouldRestoreToPercent = currentArmorPercent + armor / self:InsaneStats_GetFractionalMaxArmor()
			
			local nerfMul = math.log(wouldRestoreToPercent/currentArmorPercent) / (wouldRestoreToPercent-currentArmorPercent)
			armor = armor * nerfMul
			self:SetArmor(self:InsaneStats_GetFractionalArmor() + armor)
		end
	end
	
	local PLAYER = FindMetaTable("Player")
	function PLAYER:InsaneStats_EquipBattery(item)
		local selfHasModifiers = self.insaneStats_Modifiers and next(self.insaneStats_Modifiers)
		local itemHasModifiers = item.insaneStats_Modifiers and next(item.insaneStats_Modifiers)
		local armorMaxed = self:InsaneStats_GetFractionalArmor() >= self:InsaneStats_GetFractionalMaxArmor()
		
		if selfHasModifiers and itemHasModifiers or armorMaxed then
			-- drop the old one
			local oldItem = ents.Create("item_battery")
			oldItem:SetPos(self:GetShootPos())
			oldItem:Spawn()
			oldItem:InsaneStats_SetXP(self.insaneStats_BatteryXP or 0)
			oldItem.insaneStats_Tier = self.insaneStats_Tier
			oldItem.insaneStats_Modifiers = self.insaneStats_Modifiers or {}
			oldItem.insaneStats_NextPickup = CurTime() + 1
			InsaneStats_ApplyWPASS2Attributes(oldItem)
			
			local physObj = oldItem:GetPhysicsObject()
			if IsValid(physObj) then
				physObj:SetVelocity(self:GetAimVector() * 256)
			end
		else -- pick it up like normal
			local newArmor = math.min(self:InsaneStats_GetFractionalMaxArmor(), self:InsaneStats_GetFractionalArmor()+self:InsaneStats_GetFractionalMaxArmor()*GetConVar("sk_battery"):GetFloat()/100)
			self:SetArmor(newArmor)
			self:EmitSound("ItemBattery.Touch")
			
			net.Start("insane_stats")
			net.WriteUInt(2, 8)
			net.WriteString("item_battery")
			net.Send(self)
		end
		
		if itemHasModifiers or armorMaxed then
			-- set our modifiers to the new one
			hook.Run("InsaneStatsArmorBatteryChanged", self, item)
			self.insaneStats_Tier = item.insaneStats_Tier
			self.insaneStats_Modifiers = item.insaneStats_Modifiers
			self.insaneStats_BatteryXP = item:InsaneStats_GetXP()
			self.insaneStats_WPASS2Name = nil
			InsaneStats_ApplyWPASS2Attributes(self)
			self:InsaneStats_MarkForUpdate(8)
		end
		item:Remove()
	end
	
	hook.Add("InsaneStatsEntityCreated", "InsaneStatsWPASS", function(ent)
		if ConEnabled:GetBool() then
			local canGetModifiers = ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() or ent:IsWeapon() or ent:GetClass() == "item_battery"
			timer.Simple(0, function()
				if IsValid(ent) and not ent.insaneStats_Modifiers and canGetModifiers then
					InsaneStats_ApplyWPASS2Modifiers(ent)
				end
			end)
		end
	end)
	
	hook.Add("PlayerCanPickupWeapon", "InsaneStatsWPASS", function(ply, wep)
		hook.Run("InsaneStatsPlayerCanPickupWeapon", ply, wep)
		if (wep.insaneStats_Tier or 0) > 0 and ply:HasWeapon(wep:GetClass()) and ConEnabled:GetBool() then return false end
	end)
	
	hook.Add("PlayerUse", "InsaneStatsWPASS", function(ply, ent)
		if (ent.insaneStats_NextPickup or 0) < CurTime() then
			if ent:IsWeapon() and not ent:HasSpawnFlags(SF_WEAPON_NO_PLAYER_PICKUP) and ply:HasWeapon(ent:GetClass()) then
				-- drop the old gun
				local oldEnt = ply:GetWeapon(ent:GetClass())
				ply:DropWeapon(oldEnt)
				ply:PickupWeapon(ent)
				oldEnt.insaneStats_NextPickup = CurTime() + 1
				--ply:SetActiveWeapon(ent)
			elseif ent:GetClass() == "item_battery" then
				ply:InsaneStats_EquipBattery(ent)
			end
		end
	end)
end

if CLIENT then
	surface.CreateFont("InsaneStats_Small", {
		font = "WillowBody",
		size = 18
	})
	
	local equippedWep
	local panelDisplayDieTime = 0
	local mouseOverDieTime = 0
	local panelDisplayChangeTime = 0
	local mouseOverChangeTime = 0
	local nextEntityUpdateTimestamp = 0
	local color_gray = Color(127, 127, 127)
	local color_light_blue = Color(127, 127, 255)
	local color_light_red = Color(255, 127, 127)
	local baseHues = {120, 240, 270, 0, 30, 60, 90, 210, 180, 300}
	
	local function CreateName(wep)
		local modifiersAscending = {}
		for k,v in SortedPairsByValue(wep.insaneStats_Modifiers) do
			table.insert(modifiersAscending, k)
		end
		
		local name = language.GetPhrase(wep:IsPlayer() and "item_battery" or wep:GetClass())
		local lastSuffix = #modifiersAscending
		if lastSuffix % 2 == 0 then lastSuffix = lastSuffix - 1 end
		
		for i,v in ipairs(modifiersAscending) do
			local modifierInfo = modifiers[v]
			if not modifierInfo then
				print(v)
			end
			
			if i % 2 == 0 then
				name = modifierInfo.prefix .. ' ' .. name
			else
				local suffix = modifierInfo.suffix or modifierInfo.prefix
				if i == 1 then
					name = name .. " of " .. suffix
				elseif i == lastSuffix then
					name = name .. " and " .. suffix
				else
					name = name .. ", " .. suffix
				end
			end
		end
		
		local rarityTier = math.floor(wep.insaneStats_Tier/ConTierUpRarityUp:GetFloat())+2
		rarityTier = math.min(rarityTier, #rarityNames)
		name = rarityNames[rarityTier] .. ' ' .. name
		
		local attribOrder = {}
		local attribOrderValues = {}
		for k,v in pairs(wep.insaneStats_Attributes) do
			v = math.abs(v-1)
			--[[if v < 1 then
				v = 1/v
			end]]
			attribOrderValues[k] = v
		end
		
		for k,v in SortedPairsByValue(attribOrderValues, true) do
			table.insert(attribOrder, k)
		end
		
		wep.insaneStats_AttributeOrder = attribOrder
		wep.insaneStats_Rarity = rarityTier
		wep.insaneStats_WPASS2Name = name
		wep.insaneStats_BatteryLevel = math.floor(InsaneStats_GetLevelByXPRequired(wep.insaneStats_BatteryXP))
	end
	
	local function GetRarityColor(tier)
		tier = tier - 2
		if tier < 0 then return color_gray
		elseif tier == 0 then return color_white
		elseif tier > 30 then return HSVToColor(RealTime() * 180 % 360, 1, 1)
		else
			local hue = baseHues[ (tier-1)%10+1 ]
			local lum = 0.75
			if tier > 20 then
				lum = math.abs( RealTime()%2-1 )
			elseif tier > 10 then
				lum = math.abs( (RealTime()%2-1)/2 ) + 0.5
			end
			
			return HSLToColor(hue, 1, lum)
		end
	end
	
	local function DrawWeaponPanel(panelX, panelY, wep, changeDuration, alphaMod, extra)
		local textOffsetX, textOffsetY = 0, 0
		local maxW = 384
		local rarityColor = GetRarityColor(wep.insaneStats_Rarity)
		rarityColor = Color(rarityColor.r, rarityColor.g, rarityColor.b, alphaMod * 255)
		local neutralColor = Color(255, 255, 255, alphaMod * 255)
		local outlineColor = Color(0, 0, 0, alphaMod * 255)
		local backgroundColor = Color(0, 0, 0, alphaMod / 2 * 255)
		extra = extra or {}
		
		surface.SetFont("InsaneStats_Small")
		local nameW = surface.GetTextSize(wep.insaneStats_WPASS2Name) - maxW + 2
		local nameScrollFactor = 1
		if nameW > 0 then
			nameScrollFactor = (math.cos(changeDuration/2)+1)/2
		end
		local nameScrollAmt = Lerp(nameScrollFactor, nameW, 0)
		
		render.SetScissorRect(panelX-2, panelY-2, panelX+maxW+2, panelY+18+2, true)
		
		textOffsetX, textOffsetY = draw.SimpleTextOutlined(wep.insaneStats_WPASS2Name, "InsaneStats_Small", panelX-nameScrollAmt, panelY, rarityColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, outlineColor)
		panelY = panelY + textOffsetY
		
		render.SetScissorRect(0, 0, 0, 0, false)
		
		local tierDisplay = "Tier "..wep.insaneStats_Tier.." Weapon"
		if GetConVar("insanestats_xp_enabled"):GetBool() then
			if wep:IsPlayer() then
				tierDisplay = "Tier "..wep.insaneStats_Tier..", Level "..InsaneStats_FormatNumber(wep.insaneStats_BatteryLevel).." Weapon"
			else
				tierDisplay = "Tier "..wep.insaneStats_Tier..", Level "..InsaneStats_FormatNumber(wep:InsaneStats_GetLevel()).." Weapon"
			end
		end
		textOffsetX, textOffsetY = draw.SimpleTextOutlined(tierDisplay, "InsaneStats_Small", panelX, panelY, neutralColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, outlineColor)
		panelY = panelY + textOffsetY
		
		if not wep.insaneStats_AttributeOrder then print(wep.insaneStats_WPASS2Name, type(wep.insaneStats_WPASS2Name)) end
		
		local sf1 = math.max(#wep.insaneStats_AttributeOrder - 4, 4)
		local sf2 = (changeDuration + sf1) % (sf1 * 2) - sf1
		local sf3 = math.Clamp(math.abs(sf2) - 2, 0, sf1-4)
		
		render.SetScissorRect(panelX-2, panelY-2, panelX+maxW+2, panelY+144, true)
		
		for i,v in ipairs(wep.insaneStats_AttributeOrder) do
			local textY = panelY + (i-sf3-1) * 18
			-- don't bother if out of range
			if textY > panelY-20 and textY < panelY+144 then
				local attribValue = wep.insaneStats_Attributes[v]
				if not attribValue then
					PrintTable(wep.insaneStats_Attributes)
				end
				if not attributes[v] then print(v) end
				
				local displayColor = (attribValue < 1 == tobool(attributes[v].invert)) and color_light_blue or color_light_red
				displayColor = Color(displayColor.r, displayColor.g, displayColor.b, alphaMod * 255)
				
				local numberDisplay = InsaneStats_FormatNumber(math.Round((attribValue-1)*(attributes[v].nopercent and 1 or 100), 3), {plus = true})
					..(attributes[v].nopercent and "" or "%")
				--[[if attribValue >= 10001 then
					numberDisplay = InsaneStats_FormatNumber((attribValue-1)*100) .. " %"
				end]]
				local attribDisplay = string.format(attributes[v].display, numberDisplay)
				
				textOffsetX, textOffsetY = draw.SimpleTextOutlined(attribDisplay, "InsaneStats_Small", panelX, textY, displayColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, outlineColor)
			end
		end
		
		render.SetScissorRect(0, 0, 0, 0, false)
		
		if extra.compare then
			draw.SimpleTextOutlined("Your current weapon:", "InsaneStats_Small", panelX, panelY, displayColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, outlineColor)
		end
	end
	
	local lastLookedAtWep
	hook.Add("HUDPaint", "InsaneStatsWPASS", function()
		if ConEnabled:GetBool() then
			local ply = LocalPlayer()
			local wep = ply:GetActiveWeapon()
			local realTime = RealTime()
			local lookedAtWep = ply:GetEyeTrace().Entity
			
			if (IsValid(lookedAtWep) and lookedAtWep:InsaneStats_IsWPASS2Able()) then
				if mouseOverDieTime < realTime or lastLookedAtWep:EntIndex() ~= lookedAtWep:EntIndex() then
					mouseOverChangeTime = realTime
					panelDisplayChangeTime = realTime
				end
				mouseOverDieTime = realTime + 1.1
				panelDisplayDieTime = realTime + 1.1
				lastLookedAtWep = lookedAtWep
				
				local lookClass = lookedAtWep:GetClass()
				
				if lookClass == "item_battery" then
					wep = ply
				elseif ply:HasWeapon(lookClass) then
					wep = ply:GetWeapon(lookedAtWep:GetClass())
				end
			end
			
			if IsValid(wep) then
				if equippedWep ~= wep:EntIndex() then
					equippedWep = wep:EntIndex()
					panelDisplayDieTime = realTime + ConHoldTime:GetFloat() + 1
					panelDisplayChangeTime = realTime
				end
				
				if wep.insaneStats_Modifiers then
					if not wep.insaneStats_WPASS2Name then
						CreateName(wep)
					end
					if panelDisplayDieTime > realTime then
						DrawWeaponPanel(ScrW()-400, ScrH()-300, wep, RealTime() - panelDisplayChangeTime, math.min(1, panelDisplayDieTime - realTime))
					end
				elseif nextEntityUpdateTimestamp < realTime then
					nextEntityUpdateTimestamp = realTime + 0.25
					
					-- probe the server for weapon stats
					net.Start("insane_stats")
					net.WriteEntity(wep)
					net.SendToServer()
				end
			end
			
			if IsValid(lastLookedAtWep) then
				if lastLookedAtWep.insaneStats_Modifiers then
					if not lastLookedAtWep.insaneStats_WPASS2Name then
						CreateName(lastLookedAtWep)
					end
					if mouseOverDieTime > realTime then
						DrawWeaponPanel(ScrW()-800, ScrH()-300, lastLookedAtWep, RealTime() - mouseOverChangeTime, math.min(1, mouseOverDieTime - realTime))
					else
						lastLookedAtWep = nil
					end
				elseif nextEntityUpdateTimestamp < realTime then
					nextEntityUpdateTimestamp = realTime + 0.25
					
					-- probe the server for weapon stats
					net.Start("insane_stats")
					net.WriteEntity(lastLookedAtWep)
					net.SendToServer()
				end
			end
		end
	end)
end