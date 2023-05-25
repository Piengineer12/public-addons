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
	elseif ent:IsNPC() then
		local isAlly, isEnemy = false, false
		for k,v in pairs(player.GetAll()) do
			if v:InsaneStats_IsValidAlly(ent) then
				isAlly = true
			end
			if v:InsaneStats_IsValidEnemy(ent) then
				isEnemy = true
			end
		end
		
		if isAlly == isEnemy then
			probability = InsaneStats:GetConVarValueDefaulted(isNotWep and "wpass2_chance_other_battery", "wpass2_chance_other")
		elseif isAlly then
			probability = InsaneStats:GetConVarValueDefaulted(
				isNotWep and "wpass2_chance_ally_battery",
				"wpass2_chance_ally",
				isNotWep and "wpass2_chance_other_battery",
				"wpass2_chance_other"
			)
		else
			probability = InsaneStats:GetConVarValueDefaulted(
				isNotWep and "wpass2_chance_enemy_battery",
				"wpass2_chance_enemy",
				isNotWep and "wpass2_chance_other_battery",
				"wpass2_chance_other"
			)
		end
	else
		probability = InsaneStats:GetConVarValueDefaulted(isNotWep and "wpass2_chance_other_battery", "wpass2_chance_other")
	end
	
	local canGetModifiers = ent:InsaneStats_IsMob() or ent:IsWeapon() or ent:GetClass() == "item_battery"
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
		if not ent:InsaneStats_IsWPASS2Pickup() then
			if not ent.insaneStats_BatteryXP then
				ent:InsaneStats_SetBatteryXP(InsaneStats:DetermineEntitySpawnedXP(ent:GetPos()))
				if not ent.insaneStats_BatteryXP then return false end
			end
			effectiveLevel = math.floor(InsaneStats:GetLevelByXPRequired(ent:InsaneStats_GetBatteryXP()))
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
		inclusiveFlags = bit.bor(inclusiveFlags, self.WPASS2_FLAGS.ARMOR)
	elseif wep:IsScripted() then
		inclusiveFlags = bit.bor(inclusiveFlags, self.WPASS2_FLAGS.SCRIPTED_ONLY)
	end
	if self:GetConVarValue("xp_enabled") then
		inclusiveFlags = bit.bor(inclusiveFlags, self.WPASS2_FLAGS.XP)
	end
	if game.SinglePlayer() then
		inclusiveFlags = bit.bor(inclusiveFlags, self.WPASS2_FLAGS.SP_ONLY)
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

local SaveData, SaveDataFile
local toSavePlayers = {}
local playerLoadoutData = {}
local saveRequested = false
local saveThinkCooldown = 10
timer.Create("InsaneStatsWPASS", 0.5, 0, function()
	if next(toUpdateModifierEntities) then
		for k,v in pairs(toUpdateModifierEntities) do
			toUpdateModifierEntities[k] = nil
			
			if IsValid(k) then
				InsaneStats:ApplyWPASS2Modifiers(k)
			end
		end
	end
	
	if next(toSavePlayers) then
		for k,v in pairs(toSavePlayers) do
			SaveData(k)
		end
		toSavePlayers = {}
	end
	
	if saveThinkCooldown < RealTime() then
		for k,v in pairs(player.GetAll()) do
			SaveData(v)
		end
		saveThinkCooldown = RealTime() + 10
	end
	
	if saveRequested then
		SaveDataFile()
		saveRequested = false
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
	if self:InsaneStats_GetArmor() < math.huge and self:InsaneStats_GetHealth() > 0 then
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
		
		local armorAdded = unnerfedArmorRestored + armor
		self:InsaneStats_DamageNumber(self, -armorAdded, DMG_DROWN)
	end
end

function ENTITY:InsaneStats_AddHealthCapped(health)
	if self:InsaneStats_GetHealth() > 0 and self:InsaneStats_GetHealth() < self:InsaneStats_GetMaxHealth() then
		local healthAdded = self:InsaneStats_GetHealth() < math.huge and math.min(health, self:InsaneStats_GetMaxHealth() - self:InsaneStats_GetHealth()) or 0
		self:SetHealth(self:InsaneStats_GetHealth() + healthAdded)
		self:InsaneStats_DamageNumber(self, -healthAdded, DMG_DROWNRECOVER)
	end
end

function ENTITY:InsaneStats_IsMob()
	return self:IsPlayer() or self:IsNPC() or self:IsNextBot() or self:GetClass()=="prop_vehicle_apc"
end

function ENTITY:InsaneStats_IsValidEnemy(ent)
	if not (IsValid(ent) and ent:GetClass() ~= "npc_enemyfinder") then return false end
	if ent:InsaneStats_GetHealth() <= 0 or ent.insaneStats_IsDead then return false end
	
	if self:IsPlayer() and ent:GetClass() == "npc_antlion_grub" then return true end
	
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
	if ent.Team and self.Team then
		if (isfunction(ent.Team) and isfunction(self.Team) and ent:Team() ~= self:Team()) then
			return true
		elseif ent.Team ~= self.Team then
			return true
		end
	end
	
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
	if ent.Team and self.Team then
		if (isfunction(ent.Team) and isfunction(self.Team) and ent:Team() == self:Team()) then
			return true
		elseif ent.Team == self.Team then
			return true
		end
	end
	
	return false
end

function ENTITY:InsaneStats_AddBatteryXP(xp)
	self:InsaneStats_SetBatteryXP(self:InsaneStats_GetBatteryXP() + xp)
	
	local oldTier = self.insaneStats_Tier
	ApplyWPASS2Tier(self)
	if self.insaneStats_Tier ~= oldTier then
		InsaneStats:ApplyWPASS2Modifiers(self)
	end
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
		oldItem:InsaneStats_SetXP(self:InsaneStats_GetBatteryXP())
		oldItem.insaneStats_StartTier = self.insaneStats_StartTier
		oldItem.insaneStats_Tier = self.insaneStats_Tier
		oldItem.insaneStats_Modifiers = self.insaneStats_Modifiers or {}
		oldItem.insaneStats_NextPickup = CurTime() + 1
		oldItem:SetPos(self:GetShootPos())
		oldItem:Spawn()
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
		self:InsaneStats_SetBatteryXP(item:InsaneStats_GetXP())
		
		InsaneStats:ApplyWPASS2Attributes(self)
		self.insaneStats_ModifierChangeReason = 2
		self:InsaneStats_MarkForUpdate(8)
	end
	item:Remove()
end

hook.Add("InsaneStatsEntityCreated", "InsaneStatsWPASS", function(ent)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		timer.Simple(0, function() -- wait for xp to settle first
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
		local ignoreWPASS2Pickup = (item.insaneStats_DisableWPASS2Pickup or 0) > RealTime()
		if entModified and itemHasModifiers and not ignoreWPASS2Pickup then return false end
	end
	toSavePlayers[ply] = true
end)

hook.Add("PlayerCanPickupWeapon", "InsaneStatsWPASS", function(ply, wep)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		local wepHasModifiers = wep.insaneStats_Modifiers and next(wep.insaneStats_Modifiers)
		local ignoreWPASS2Pickup = (wep.insaneStats_DisableWPASS2Pickup or 0) > RealTime()
		--[[local pickupDelayed = (wep.insaneStats_NextPickup or 0) > CurTime()]]
		if wepHasModifiers and ply:HasWeapon(wep:GetClass()) and not ignoreWPASS2Pickup --[[or pickupDelayed]] then return false end
	end
	hook.Run("InsaneStatsPlayerCanPickupWeapon", ply, wep)
	toSavePlayers[ply] = true
end)

hook.Add("PlayerUse", "InsaneStatsWPASS", function(ply, ent)
	if (ply.insaneStats_NextPickup or 0) > CurTime() + 0.2 then
		ply.insaneStats_NextPickup = nil
	end
	
	if (ply.insaneStats_NextPickup or 0) < CurTime() and InsaneStats:GetConVarValue("wpass2_enabled") then
		if ent:IsWeapon() and not ent:HasSpawnFlags(SF_WEAPON_NO_PLAYER_PICKUP) and ply:HasWeapon(ent:GetClass()) and not IsValid(ent:GetOwner()) then
			ply.insaneStats_NextPickup = CurTime() + 0.2
			
			if ply:KeyDown(IN_SPEED) then
				ent.insaneStats_DisableWPASS2Pickup = RealTime() + 1
			else
				local oldEnt = ply:GetWeapon(ent:GetClass())
				oldEnt.insaneStats_NextPickup = CurTime() + 1
				ply:DropWeapon(oldEnt)
				timer.Simple(0.2, function()
					if (IsValid(ply) and IsValid(ent) and not ply:HasWeapon(ent:GetClass())) then
						-- somehow the player didn't pick up the weapon
						InsaneStats:Log("Forcing weapon "..tostring(ent).." into "..tostring(ply).."'s hands...")
						ply:PickupWeapon(ent)
					end
				end)
			end
		elseif ent:GetClass() == "item_battery" then
			ply.insaneStats_NextPickup = CurTime() + 0.2
			
			if ply:KeyDown(IN_SPEED) then
				ent.insaneStats_DisableWPASS2Pickup = RealTime() + 1
			else
				ply:InsaneStats_EquipBattery(ent)
				timer.Simple(1, function()
					if IsValid(ply) then
						SaveData(ply)
					end
				end)
			end
		end
	end
end)

SaveDataFile = function()
	local shouldSave = InsaneStats:GetConVarValue("wpass2_modifiers_player_save")
	local shouldSaveBattery = InsaneStats:GetConVarValueDefaulted("wpass2_modifiers_player_save_battery", "wpass2_modifiers_player_save")
	
	if shouldSave > 0 or shouldSaveBattery > 0 then
		local data = util.JSONToTable(file.Read("insane_stats.txt") or "") or {}
		data.wpass2 = playerLoadoutData
		
		file.Write("insane_stats.txt", util.TableToJSON(data))
	end
end

local function GetPlayerWPASS2SaveData(ply, shouldSave, shouldSaveBattery)
	local steamID = ply:SteamID()
	if steamID then
		local plyWPASS2Data = {}
		plyWPASS2Data.modifiers = plyWPASS2Data.modifiers or {}
		
		if shouldSave > 0 then
			plyWPASS2Data.modifiers.weapons = {}
			
			if shouldSave == 1 then
				plyWPASS2Data.weaponsAndAmmo = {weapons = {}, ammo = {}}
				
				for k,v in pairs(ply:GetAmmo()) do
					local ammoName = game.GetAmmoName(k)
					plyWPASS2Data.weaponsAndAmmo.ammo[ammoName] = v
				end
			else
				plyWPASS2Data.weaponsAndAmmo = nil
			end
			
			for k,v in pairs(ply:GetWeapons()) do
				plyWPASS2Data.modifiers.weapons[v:GetClass()] = {
					modifiers = v.insaneStats_Modifiers,
					startTier = v.insaneStats_StartTier,
					xp = v.insaneStats_XP ~= math.huge and v.insaneStats_XP or "inf"
				}
				
				if shouldSave == 1 then
					plyWPASS2Data.weaponsAndAmmo.weapons[v:GetClass()] = {
						primary = v:Clip1(),
						secondary = v:Clip2()
					}
				end
			end
		end
		
		if shouldSaveBattery > 0 then
			plyWPASS2Data.modifiers.battery = {
				modifiers = ply.insaneStats_Modifiers,
				startTier = ply.insaneStats_StartTier,
				xp = ply:InsaneStats_GetBatteryXP() ~= math.huge and ply:InsaneStats_GetBatteryXP() or "inf"
			}
			
			if shouldSaveBattery == 1 then
				-- save health, max health, armor, max armor and suit status
				plyWPASS2Data.healthArmorAndSuitStats = {
					health = ply:Alive() and ply:InsaneStats_GetHealth(),
					maxHealth = ply:InsaneStats_GetMaxHealth(),
					armor = ply:Alive() and ply:InsaneStats_GetArmor(),
					maxArmor = ply:InsaneStats_GetMaxArmor(),
					suit = ply:IsSuitEquipped()
				}
			end
		end
		
		return plyWPASS2Data
	end
end

SaveData = function(ply, forced)
	local steamID = ply:SteamID()
	if steamID and (ply:Alive() or forced) and ply.insaneStats_WPASS2DataLoaded then
		local shouldSave = InsaneStats:GetConVarValue("wpass2_modifiers_player_save_death")
		local shouldSaveBattery = InsaneStats:GetConVarValueDefaulted("wpass2_modifiers_player_save_death_battery", "wpass2_modifiers_player_save_death")
		
		if shouldSave > 0 or shouldSaveBattery > 0 then
			playerLoadoutData[steamID] = GetPlayerWPASS2SaveData(ply, shouldSave, shouldSaveBattery)
		else
			playerLoadoutData[steamID] = nil
		end
		
		saveRequested = true
	end
end

local function ForceSaveData(ply)
	SaveData(ply, true)
	ply.insaneStats_WPASS2DataLoaded = false
end

hook.Add("DoPlayerDeath", "InsaneStatsWPASS", ForceSaveData)
hook.Add("PlayerSilentDeath", "InsaneStatsWPASS", ForceSaveData)
hook.Add("PlayerDisconnected", "InsaneStatsWPASS", ForceSaveData)
hook.Add("ShutDown", "InsaneStatsWPASS", function()
	for k,v in pairs(player.GetAll()) do
		SaveData(v)
	end
	SaveDataFile()
end)

hook.Add("InitPostEntity", "InsaneStatsWPASS", function()
	local shouldSave = InsaneStats:GetConVarValue("wpass2_modifiers_player_save")
	local shouldSaveBattery = InsaneStats:GetConVarValueDefaulted("wpass2_modifiers_player_save_battery", "wpass2_modifiers_player_save")
	
	local data = util.JSONToTable(file.Read("insane_stats.txt") or "") or {}
	if data.wpass2 then
		for k,v in pairs(data.wpass2) do
			local plyWPASS2Data = {}
			
			if v.modifiers and (shouldSave > 0 or shouldSaveBattery > 0) then
				plyWPASS2Data.modifiers = {}
				
				if v.modifiers.weapons and shouldSave > 0 then
					plyWPASS2Data.modifiers.weapons = v.modifiers.weapons
				end
				if v.modifiers.battery and shouldSaveBattery > 0 then
					plyWPASS2Data.modifiers.battery = v.modifiers.battery
				end
			end
			
			if v.weaponsAndAmmo and shouldSave == 1 then
				plyWPASS2Data.weaponsAndAmmo = v.weaponsAndAmmo
			end
			if v.healthArmorAndSuitStats and shouldSaveBattery == 1 then
				plyWPASS2Data.healthArmorAndSuitStats = v.healthArmorAndSuitStats
			end
			
			playerLoadoutData[k] = plyWPASS2Data
		end
	end
end)

hook.Add("PlayerLoadout", "InsaneStatsWPASS", function(ply)
	local steamID = ply:SteamID()
	local plyWPASS2Data = steamID and playerLoadoutData[steamID]
	if (plyWPASS2Data and plyWPASS2Data.weaponsAndAmmo) then
		ply:RemoveAllAmmo()
		
		for k,v in pairs(plyWPASS2Data.weaponsAndAmmo.ammo) do
			ply:GiveAmmo(v, k, true)
		end
		
		for k,v in pairs(plyWPASS2Data.weaponsAndAmmo.weapons) do
			local wep = ply:Give(k, true)
			if IsValid(wep) then
				wep:SetClip1(v.primary)
				wep:SetClip2(v.secondary)
			end
		end
		
		return true
	end
end)

hook.Add("InsaneStatsTransitionCompat", "InsaneStatsWPASS", function(ent)
	if ent.insaneStats_BatteryXPRoot8 then
		ent:InsaneStats_SetBatteryXP(ent.insaneStats_BatteryXPRoot8 ^ 8)
	end
end)

hook.Add("PlayerSpawn", "InsaneStatsWPASS", function(ply, fromTransition)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		timer.Simple(0, function() -- wait for xp to settle first
			if IsValid(ply) then
				InsaneStats:ApplyWPASS2Modifiers(ply)
				
				if math.random() * 100 < InsaneStats:GetConVarValue("wpass2_chance_player_drop") then
					ply:ShouldDropWeapon(true)
				end
			end
		end)
	end
	
	-- FIXME: Triple cascading timers?! There has to be a better way than this!
	timer.Simple(0.25, function() -- wait for xp to settle first
		timer.Simple(0.25, function() -- wait for WPASS2 to settle first
			timer.Simple(0.25, function() -- wait for WPASS2 health and armor mods to settle first
				if IsValid(ply) then
					ply.insaneStats_WPASS2DataLoaded = true
					
					local steamID = ply:SteamID()
					local plyWPASS2Data = steamID and playerLoadoutData[steamID]
					-- reject from transitions
					if plyWPASS2Data and not fromTransition then
						InsaneStats:Log("Loaded data for "..steamID)
						PrintTable(plyWPASS2Data)
						
						if plyWPASS2Data.modifiers then
							for k,v in pairs(plyWPASS2Data.modifiers.weapons) do
								local wep = ply:GetWeapon(k)
								if IsValid(wep) then
									wep.insaneStats_Modifiers = v.modifiers or wep.insaneStats_Modifiers
									wep.insaneStats_StartTier = v.startTier or wep.insaneStats_StartTier
									if v.xp then
										if v.xp == "inf" then v.xp = math.huge end
										wep:InsaneStats_SetXP(v.xp)
									end
									
									ApplyWPASS2Tier(wep)
									InsaneStats:ApplyWPASS2Attributes(wep)
									wep.insaneStats_ModifierChangeReason = 2
									wep:InsaneStats_MarkForUpdate(8)
								end
							end
							
							ply.insaneStats_Modifiers = plyWPASS2Data.modifiers.battery.modifiers or ply.insaneStats_Modifiers
							ply.insaneStats_StartTier = plyWPASS2Data.modifiers.battery.startTier or ply.insaneStats_StartTier
							ply:InsaneStats_SetBatteryXP(plyWPASS2Data.modifiers.battery.xp or ply:InsaneStats_GetBatteryXP())
							
							if ply:InsaneStats_GetBatteryXP() == "inf" then
								ply:InsaneStats_SetBatteryXP(math.huge)
							end
							
							ApplyWPASS2Tier(ply)
							InsaneStats:ApplyWPASS2Attributes(ply)
							ply.insaneStats_ModifierChangeReason = 2
							ply:InsaneStats_MarkForUpdate(8)
						end
						
						if plyWPASS2Data.healthArmorAndSuitStats then
							if plyWPASS2Data.healthArmorAndSuitStats.health then
								ply:SetHealth(plyWPASS2Data.healthArmorAndSuitStats.health)
							end
							if plyWPASS2Data.healthArmorAndSuitStats.armor then
								ply:SetArmor(plyWPASS2Data.healthArmorAndSuitStats.armor)
							end
							ply:SetMaxHealth(plyWPASS2Data.healthArmorAndSuitStats.maxHealth)
							ply:SetMaxArmor(plyWPASS2Data.healthArmorAndSuitStats.maxArmor)
							
							if ply:IsSuitEquipped() ~= plyWPASS2Data.healthArmorAndSuitStats.suit then
								if plyWPASS2Data.healthArmorAndSuitStats.suit then
									ply:EquipSuit()
								else
									ply:RemoveSuit()
								end
							end
						end
					end
				end
			end)
		end)
	end)
end)

hook.Add("InsaneStatsEntityKilled", "InsaneStatsWPASS", function(victim, attacker, inflictor)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
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
				oldItem:InsaneStats_SetXP(victim:InsaneStats_GetBatteryXP())
				oldItem.insaneStats_StartTier = victim.insaneStats_StartTier
				oldItem.insaneStats_Modifiers = victim.insaneStats_Modifiers or {}
				InsaneStats:ApplyWPASS2Attributes(oldItem)
				
				if victim:IsPlayer() then
					timer.Simple(0, function()
						if IsValid(victim) then
							-- set our modifiers to the null one if we dropped the battery
							victim.insaneStats_Tier = 0
							victim.insaneStats_Modifiers = {}
							victim:InsaneStats_SetBatteryXP(0)
							InsaneStats:ApplyWPASS2Attributes(victim)
							victim.insaneStats_ModifierChangeReason = 2
							victim:InsaneStats_MarkForUpdate(8)
						end
					end)
				else
					if IsValid(victim) then
						-- set our modifiers to the null one
						-- we do this because NPCs such as npc_turret_floor for example can be revived
						victim.insaneStats_Tier = 0
						victim.insaneStats_Modifiers = {}
						victim:InsaneStats_SetBatteryXP(0)
						InsaneStats:ApplyWPASS2Attributes(victim)
						victim.insaneStats_ModifierChangeReason = 2
						victim:InsaneStats_MarkForUpdate(8)
					end
				end
			end
		end
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