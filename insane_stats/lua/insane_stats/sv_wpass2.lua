-- this Lua file runs after all shared files, this table would be empty after shared load
-- unless this is done
InsaneStats.mergeEffectsToCheck = InsaneStats.mergeEffectsToCheck or {}

hook.Add("InsaneStatsPostLoadWPASS", "InsaneStatsWPASS", function(modifiers, attributes, registeredEffects)
	InsaneStats.mergeEffectsToCheck = {}
	for k,v in pairs(modifiers) do
		if v.merge then
			for k2,v2 in pairs(v.merge) do
				InsaneStats.mergeEffectsToCheck[v2] = InsaneStats.mergeEffectsToCheck[v2] or {}
				table.insert(InsaneStats.mergeEffectsToCheck[v2], k)
			end
		end
	end
end)

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

local function ApplyWPASS2StartTier(ent)
	-- figure out weapon tier
	local probability
	local isNotWep = not ent:IsWeapon()
	local owner = ent:GetOwner()
	
	if ent:InsaneStats_IsWPASS2Pickup() and not IsValid(owner) then
		probability = InsaneStats:GetConVarValueDefaulted(isNotWep and "wpass2_chance_unowned_battery", "wpass2_chance_unowned")
	elseif owner:IsPlayer() or ent:IsPlayer() then
		probability = InsaneStats:GetConVarValueDefaulted(isNotWep and "wpass2_chance_player_battery", "wpass2_chance_player")
	else
		probability = InsaneStats:GetConVarValueDefaulted(isNotWep and "wpass2_chance_other_battery", "wpass2_chance_other")
	end
	
	local canGetModifiers = ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() or ent:IsWeapon() or ent:GetClass() == "item_battery"
	if InsaneStats:GetConVarValue("wpass2_chance_other_battery_sensible") and not ent:InsaneStats_ArmorSensible() then
		canGetModifiers = false
	end
	
	if math.random()*100 < probability and canGetModifiers then
		--print(probability, ent)
		local tier = InsaneStats:GetConVarValueDefaulted(isNotWep and "wpass2_tier_start_battery", "wpass2_tier_start")
		local tierEnd = InsaneStats:GetConVarValueDefaulted(isNotWep and "wpass2_tier_max_battery", "wpass2_tier_max")
		
		local rolls = 0
		local chance = InsaneStats:GetConVarValueDefaulted(isNotWep and "wpass2_tier_upchance_battery", "wpass2_tier_upchance")
		
		while rolls < 12058 and math.random()*100 < chance and tier < tierEnd do
			rolls = rolls + 1
			tier = tier + 1
		end
		
		ent.insaneStats_StartTier = tier + math.random()
	else
		ent.insaneStats_StartTier = 0
	end
	
	return ent.insaneStats_StartTier
end

local function ApplyWPASS2Tier(ent)
	local tier = ent.insaneStats_StartTier or ApplyWPASS2StartTier(ent)
	local isNotWep = not ent:IsWeapon()
	
	if InsaneStats:GetConVarValue("xp_enabled") and InsaneStats:GetConVarValue("wpass2_tier_xp_enable") and tier ~= 0 then
		local effectiveLevel = ent:InsaneStats_GetLevel()
		if isNotWep and ent:GetClass() ~= "item_battery" then
			--print(ent)
			ent.insaneStats_BatteryXP = InsaneStats:DetermineEntitySpawnedXP(ent:GetPos())
			if not ent.insaneStats_BatteryXP then return false end
			effectiveLevel = math.floor(InsaneStats:GetLevelByXPRequired(ent.insaneStats_BatteryXP))
		end
		local tierUpMode = InsaneStats:GetConVarValueDefaulted("wpass2_tier_xp_level_add_mode", "xp_mode") > 0
		local startLevel = InsaneStats:GetConVarValueDefaulted(isNotWep and "wpass2_tier_xp_level_start_battery", "wpass2_tier_xp_level_start")
		local levelScale = InsaneStats:GetConVarValueDefaulted(isNotWep and "wpass2_tier_xp_level_add_battery", "wpass2_tier_xp_level_add")
		if tierUpMode then
			local distanceBetweenTiers = startLevel * levelScale / 100
			local startForTiers = startLevel - distanceBetweenTiers
			tier = tier + (effectiveLevel - startForTiers) / distanceBetweenTiers
		else
			local distanceBetweenTiers = 1 + levelScale / 100
			local invertedStartForTiers = distanceBetweenTiers / startLevel
			tier = tier + math.log(effectiveLevel * invertedStartForTiers, distanceBetweenTiers)
		end
	end
		
	ent.insaneStats_Tier = math.floor(
		math.Clamp(
			tier,
			0,
			math.min(
				InsaneStats:GetConVarValueDefaulted(
					isNotWep and "wpass2_tier_max_battery",
					"wpass2_tier_max"
				),
				10000
			)
		)
	)
	
	return true
end

local toUpdateModifierEntities = {}
function InsaneStats:ApplyWPASS2Modifiers(wep)
	if not ApplyWPASS2Tier(wep) then
		toUpdateModifierEntities[wep] = true
		return
	end
	
	-- assemble modifier probabilities
	local modifiers = self:GetAllModifiers()
	local inclusiveFlags = 0
	local isWep = wep:IsWeapon()
	if not isWep then
		inclusiveFlags = bit.bor(inclusiveFlags, 1)
	elseif wep:IsScripted() then
		inclusiveFlags = bit.bor(inclusiveFlags, 4)
	end
	if self:GetConVarValue("xp_enabled") then
		inclusiveFlags = bit.bor(inclusiveFlags, 2)
	end
	
	local modifierProbabilities = {}
	for k,v in pairs(modifiers) do
		if not (v.flags and bit.band(inclusiveFlags, v.flags) ~= v.flags) then
			local weight = v.weight or 1
			-- if a modifier DOES NOT have bitflag 1 and inclusiveFlags DOES,
			-- do not consider the probability, and vice versa
			if bit.band(v.flags or 0, 1) == bit.band(inclusiveFlags, 1) then
				modifierProbabilities[k] = weight
			end
		end
	end
	
	local applyModifiers = wep.insaneStats_Modifiers or {}
	local rolls = 0
	local points = wep.insaneStats_Tier
	local modifiersLeft = math.ceil(points / self:GetConVarValueDefaulted(not isWep and "wpass2_tier_newmodifiercost_battery", "wpass2_tier_newmodifiercost"))
	local maxSpendablePoints = 0
	
	for k,v in pairs(applyModifiers) do
		local modifierTable = modifiers[k]
		
		modifiersLeft = modifiersLeft - 1
		maxSpendablePoints = maxSpendablePoints + (modifierTable.max or 65536)
		
		points = points - (modifierTable.cost or 1) * v
		if v >= (modifierTable.max or 65536) then
			modifierProbabilities[k] = nil
		end
	end
	
	while rolls < 12058 and points > 0 do
		rolls = rolls + 1
		
		-- check each entry and remove inapplicable ones
		local canSpendAllPointsOnExistingModifiers = maxSpendablePoints >= wep.insaneStats_Tier
		for k,v in pairs(modifierProbabilities) do
			local modifierTable = modifiers[k]
			
			if (modifierTable.cost or 1) > points or modifiersLeft < 1 and not applyModifiers[k] and canSpendAllPointsOnExistingModifiers then
				modifierProbabilities[k] = nil
			end
		end
		
		if next(modifierProbabilities) then
			local appliedModifier = SelectWeightedRandom(modifierProbabilities)
			local modifierTable = modifiers[appliedModifier]
			
			if applyModifiers[appliedModifier] then
				applyModifiers[appliedModifier] = applyModifiers[appliedModifier] + 1
			else
				applyModifiers[appliedModifier] = 1
				modifiersLeft = modifiersLeft - 1
				maxSpendablePoints = maxSpendablePoints + (modifierTable.max or 65536)
			end
			
			points = points - (modifierTable.cost or 1)
			if applyModifiers[appliedModifier] >= (modifierTable.max or 65536) then
				modifierProbabilities[appliedModifier] = nil
			end
			
			-- if the selected modifier is mergable and the other modifiers required for merging are present, always do so
			
			if self.mergeEffectsToCheck[appliedModifier] then
				for k,v in pairs(self.mergeEffectsToCheck[appliedModifier]) do
					local modifierTable = modifiers[v]
					local modifiersRequiredToMerge = modifierTable.merge
					local mergePoints = 0
					
					for k2,v2 in pairs(modifiersRequiredToMerge) do
						if applyModifiers[v2] then
							mergePoints = mergePoints + applyModifiers[v2]
						else
							mergePoints = 0 break
						end
					end
					
					if mergePoints > 0 then
						if applyModifiers[v] then
							applyModifiers[v] = applyModifiers[v] + mergePoints
						else
							applyModifiers[v] = mergePoints
							modifiersLeft = modifiersLeft - 1
							maxSpendablePoints = maxSpendablePoints + (modifierTable.max or 65536)
						end
						
						modifierProbabilities[v] = modifierTable.weight or 1
						
						for k2,v2 in pairs(modifiersRequiredToMerge) do
							modifiersLeft = modifiersLeft + 1
							maxSpendablePoints = maxSpendablePoints - (modifiers[v2].max or 65536)
							applyModifiers[v2] = nil
							modifierProbabilities[v2] = nil
						end
					end
				end
			end
		else break
		end
	end
	
	wep.insaneStats_Modifiers = applyModifiers
	if not wep:InsaneStats_IsWPASS2Pickup() and (wep.GetMaxArmor and wep:GetMaxArmor() <= 0) and not wep:IsPlayer() and wep.insaneStats_Tier ~= 0 then
		-- apply armor
		local startingHealth = wep:InsaneStats_GetMaxHealth() / (wep.insaneStats_CurrentHealthAdd or 1)
		local startingArmor = startingHealth * self:GetConVarValue("infhealth_armor_mul")
		wep:SetMaxArmor(wep:InsaneStats_GetMaxHealth() * self:GetConVarValue("infhealth_armor_mul"))
		wep.insaneStats_CurrentArmorAdd = wep:InsaneStats_GetMaxArmor() / startingArmor
		wep:SetArmor(wep:InsaneStats_GetMaxArmor())
	end
	
	self:ApplyWPASS2Attributes(wep)
	wep.insaneStats_ModifierChangeReason = 1
	wep:InsaneStats_MarkForUpdate(8)
end

timer.Create("InsaneStatsWPASS", 0.5, 0, function()
	if next(toUpdateModifierEntities) then
		for k,v in pairs(toUpdateModifierEntities) do
			toUpdateModifierEntities[k] = nil
			
			if IsValid(k) then
				InsaneStats:ApplyWPASS2Modifiers(k)
			end
		end
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

function ENTITY:InsaneStats_AddArmorNerfed(armor)
	local unnerfedArmorRestored = math.Clamp(self:InsaneStats_GetMaxArmor() - self:InsaneStats_GetArmor(), 0, armor)
	armor = armor - unnerfedArmorRestored
	if unnerfedArmorRestored > 0 then
		self:SetArmor(self:InsaneStats_GetArmor() + unnerfedArmorRestored)
	end
	
	if armor > 0 then
		-- nerfed amount, yes it is a bit complicated
		local currentArmorPercent = self:InsaneStats_GetArmor() / self:InsaneStats_GetMaxArmor()
		local wouldRestoreToPercent = currentArmorPercent + armor / self:InsaneStats_GetMaxArmor()
		
		if wouldRestoreToPercent > currentArmorPercent then
			local nerfMul = math.log(wouldRestoreToPercent/currentArmorPercent) / (wouldRestoreToPercent-currentArmorPercent)
			armor = armor * nerfMul
			self:SetArmor(self:InsaneStats_GetArmor() + armor)
		end
	end
end

function ENTITY:InsaneStats_IsValidEnemy(ent)
	if not (IsValid(ent) and ent:GetClass() ~= "npc_enemyfinder") then return false end
	
	-- poll Disposition to figure out if they're enemies
	if (ent.Disposition and ent:Disposition(self) == D_HT) then return true end
	if (self.Disposition and self:Disposition(ent) == D_HT) then return true end
	
	-- poll GetRelationship
	if (ent.GetRelationship and ent:GetRelationship(self) == D_HT) then return true end
	if (self.GetRelationship and self:GetRelationship(ent) == D_HT) then return true end
	
	-- poll GetEnemy
	if (ent.GetEnemy and ent:GetEnemy() == self) then return true end
	if (self.GetEnemy and self:GetEnemy() == ent) then return true end
	
	-- do Team check
	if (ent.Team and self.Team and ent:Team() ~= self:Team()) then return true end
	
	return false
end

function ENTITY:InsaneStats_IsValidAlly(ent)
	-- this returns true when ent -> self is an ally relationship (without regarding self -> ent)
	if not IsValid(ent) then return false end
	
	-- poll Disposition to figure out if ent is an ally
	if (ent.Disposition and ent:Disposition(self) == D_LI) then return true end
	
	-- poll GetRelationship
	if (ent.GetRelationship and ent:GetRelationship(self) == D_LI) then return true end
	
	-- do Team check
	if (ent.Team and self.Team and ent:Team() == self:Team()) then return true end
	
	return false
end

local PLAYER = FindMetaTable("Player")
function PLAYER:InsaneStats_EquipBattery(item)
	--error(tostring(item))
	local selfHasModifiers = self.insaneStats_Modifiers and next(self.insaneStats_Modifiers)
	local itemHasModifiers = item.insaneStats_Modifiers and next(item.insaneStats_Modifiers)
	local armorMaxed = self:InsaneStats_GetArmor() >= self:InsaneStats_GetMaxArmor()
	
	if selfHasModifiers and itemHasModifiers or armorMaxed then
		-- drop the old one
		local oldItem = ents.Create("item_battery")
		oldItem:SetPos(self:GetShootPos())
		oldItem:Spawn()
		oldItem:InsaneStats_SetXP(self.insaneStats_BatteryXP or 0)
		oldItem.insaneStats_StartTier = self.insaneStats_StartTier
		oldItem.insaneStats_Tier = self.insaneStats_Tier
		oldItem.insaneStats_Modifiers = self.insaneStats_Modifiers or {}
		oldItem.insaneStats_NextPickup = CurTime() + 1
		InsaneStats:ApplyWPASS2Attributes(oldItem)
		
		local physObj = oldItem:GetPhysicsObject()
		if IsValid(physObj) then
			physObj:SetVelocity(self:GetAimVector() * 256)
		end
	else -- pick it up like normal
		local newArmor = math.min(
			self:InsaneStats_GetMaxArmor(),
			self:InsaneStats_GetArmor()+GetConVar("sk_battery"):GetFloat()*(self.insaneStats_CurrentArmorAdd or 1)
		)
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
		self.insaneStats_StartTier = item.insaneStats_StartTier
		self.insaneStats_Tier = item.insaneStats_Tier
		self.insaneStats_Modifiers = item.insaneStats_Modifiers
		self.insaneStats_BatteryXP = item:InsaneStats_GetXP()
		self.insaneStats_WPASS2Name = nil
		InsaneStats:ApplyWPASS2Attributes(self)
		self.insaneStats_ModifierChangeReason = 2
		self:InsaneStats_MarkForUpdate(8)
	end
	item:Remove()
end

hook.Add("InsaneStatsEntityCreated", "InsaneStatsWPASS", function(ent)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		timer.Simple(0, function()
			if IsValid(ent) then
				InsaneStats:ApplyWPASS2Modifiers(ent)
				
				if ent:IsNPC() and math.random() * 100 < InsaneStats:GetConVarValue("wpass2_chance_other_drop") then
					ent:SetKeyValue("spawnflags", bit.band(ent:GetSpawnFlags(), bit.bnot(SF_NPC_NO_WEAPON_DROP)))
				end
			end
		end)
	end
end)

hook.Add("InsaneStatsPlayerCanPickupItem", "InsaneStatsWPASS", function(ply, item)
	if InsaneStats:GetConVarValue("wpass2_enabled") and item:GetClass() == "item_battery" then
		-- if the player already has a modified armor battery
		-- and the to-be-picked-up battery is also modified
		-- don't auto pickup
		local entModified = ply.insaneStats_Modifiers and next(ply.insaneStats_Modifiers)
		local itemHasModifiers = item.insaneStats_Modifiers and next(item.insaneStats_Modifiers)
		if entModified and itemHasModifiers then return false end
	end
end)

hook.Add("PlayerCanPickupWeapon", "InsaneStatsWPASS", function(ply, wep)
	hook.Run("InsaneStatsPlayerCanPickupWeapon", ply, wep)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		if (wep.insaneStats_Tier or 0) > 0 and ply:HasWeapon(wep:GetClass()) and InsaneStats:GetConVarValue("wpass2_enabled") then return false end
	end
end)

hook.Add("PlayerUse", "InsaneStatsWPASS", function(ply, ent)
	if (ent.insaneStats_NextPickup or 0) < CurTime() and InsaneStats:GetConVarValue("wpass2_enabled") then
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

local function ProcessKillEvent(victim, attacker, inflictor)
	local selfHasModifiers = victim.insaneStats_Modifiers and next(victim.insaneStats_Modifiers)
	
	if selfHasModifiers then
		local chance = victim:IsPlayer()
		and InsaneStats:GetConVarValueDefaulted("wpass2_chance_player_drop_battery", "wpass2_chance_player_drop")
		or InsaneStats:GetConVarValueDefaulted("wpass2_chance_other_drop_battery", "wpass2_chance_other_drop")
		
		if math.random() * 100 < chance then
			-- drop the old one
			local oldItem = ents.Create("item_battery")
			oldItem:SetPos(victim.GetShootPos and victim:GetShootPos() or victim:WorldSpaceCenter())
			oldItem:Spawn()
			oldItem:InsaneStats_SetXP(victim.insaneStats_BatteryXP or 0)
			oldItem.insaneStats_StartTier = victim.insaneStats_StartTier
			oldItem.insaneStats_Modifiers = victim.insaneStats_Modifiers or {}
			oldItem.insaneStats_NextPickup = CurTime() + 1
			InsaneStats:ApplyWPASS2Attributes(oldItem)
			
			-- set our modifiers to the null one
			-- we do this because NPCs such as npc_turret_floor for example can be revived
			victim.insaneStats_Tier = 0
			victim.insaneStats_Modifiers = {}
			victim.insaneStats_BatteryXP = 0
			InsaneStats:ApplyWPASS2Attributes(victim)
			victim.insaneStats_ModifierChangeReason = 2
			victim:InsaneStats_MarkForUpdate(8)
		end
	end
end

hook.Add("entity_killed", "InsaneStatsWPASS", function(data)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		local victim = Entity(data.entindex_killed or 0)
		local attacker = Entity(data.entindex_attacker or 0)
		local inflictor = Entity(data.entindex_inflictor or 0)
		
		ProcessKillEvent(victim, attacker, inflictor)
	end
end)

hook.Add("OnNPCKilled", "InsaneStatsWPASS", function(victim, attacker, inflictor)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		ProcessKillEvent(victim, attacker, inflictor)
	end
end)

hook.Add("InsaneStatsApplyLevel", "InsaneStatsWPASS", function(ent, level)
	timer.Simple(0, function()
		if IsValid(ent) then
			local oldTier = ent.insaneStats_Tier
			ApplyWPASS2Tier(ent)
			if ent.insaneStats_Tier ~= oldTier then
				InsaneStats:ApplyWPASS2Modifiers(ent)
			end
		end
	end)
end)