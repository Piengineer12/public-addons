-- this Lua file runs after all shared files, this table would be empty after shared load
-- unless this is done
InsaneStats.mergeEffectsToCheck = InsaneStats.mergeEffectsToCheck or {}

concommand.Add("insanestats_wpass2_statuseffect", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		if #args < 1 then
			InsaneStats:Log("Format: insanestats_wpass2_statuseffect <internalName> [level=1] [duration=10] [entity=self]")
		else
			local status, level, duration = args[1], args[2], args[3]
			local target = table.concat(args, " ", 4)
			level = tonumber(level) or 1
			duration = tonumber(duration) or 10

			if not InsaneStats:GetStatusEffectInfo(status) then
				return InsaneStats:Log("\"%s\" is not a valid status effect!", status)
			end

			local targets
			if target == "" then
				targets = IsValid(ply) and {ply} or player.GetAll()
			else
				-- don't know if it's safe to modify the table returned by ents.FindByName
				-- better to be safe than sorry
				targets = {}
				for i,v in ents.Iterator() do
					if v:GetName() == target then
						table.insert(targets, v)
					end
				end
			end
			
			if next(targets) then
				for i,v in ipairs(targets) do
					v:InsaneStats_ApplyStatusEffect(status, level, duration, {attacker = IsValid(ply) and ply or game.GetWorld()})
				end
			else
				InsaneStats:Log("Could not find entity named \"%s\".", target)
			end
		end
	end
end, function(cmd, argStr)
	local _, internalName, level, duration, playerInput = unpack(string.Explode("%s", argStr, true))
	if playerInput then
		local suggestions = {}
		playerInput = playerInput:lower():Trim()
		
		for i,v in ents.Iterator() do
			local entityName = v:GetName():Trim()
			if entityName ~= "" and entityName:lower():StartsWith(playerInput) then
				table.insert(suggestions, "insanestats_wpass2_statuseffect "..internalName.." "..level.." "..duration.." \""..entityName.."\"")
			end
		end
		
		table.sort(suggestions)
		return suggestions
	elseif internalName and not level then
		local suggestions = {}
		internalName = internalName:lower():Trim()
		
		for k,v in pairs(InsaneStats:GetAllStatusEffects()) do
			if k:lower():StartsWith(internalName) then
				table.insert(suggestions, "insanestats_wpass2_statuseffect "..k)
			end
		end
		
		table.sort(suggestions)
		return suggestions
	end
end, "Applies a status effect to a named entity. If no name is specified, the effect will be applied to you, \z
or to all players when entered through the server console.\
Format: insanestats_wpass2_statuseffect <internalName> [level=1] [duration=10] [entity=self]")

concommand.Add("insanestats_wpass2_statuseffect_clear", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		if #args < 1 then
			InsaneStats:Log("Format: insanestats_wpass2_statuseffect_clear <internalName> [entity=self]")
		else
			local status = args[1]
			local target = table.concat(args, " ", 2)

			if not InsaneStats:GetStatusEffectInfo(status) then
				return InsaneStats:Log("\"%s\" is not a valid status effect!", status)
			end

			local targets
			if target == "" then
				targets = IsValid(ply) and {ply} or player.GetAll()
			else
				targets = {}
				for i,v in ents.Iterator() do
					if v:GetName() == target then
						table.insert(targets, v)
					end
				end
			end
			
			if next(targets) then
				for i,v in ipairs(targets) do
					v:InsaneStats_ClearStatusEffect(status)
				end
			else
				InsaneStats:Log("Could not find entity named \"%s\".", target)
			end
		end
	end
end, function(cmd, argStr)
	local _, internalName, playerInput = unpack(string.Explode("%s", argStr, true))
	if playerInput then
		local suggestions = {}
		playerInput = playerInput:lower():Trim()
		
		for i,v in ents.Iterator() do
			local entityName = v:GetName():Trim()
			if entityName ~= "" and entityName:lower():StartsWith(playerInput) then
				table.insert(suggestions, "insanestats_wpass2_statuseffect_clear "..internalName.." \""..entityName.."\"")
			end
		end

		table.sort(suggestions)
		return suggestions
	elseif internalName then
		local suggestions = {}
		internalName = internalName:lower():Trim()
		
		for k,v in pairs(InsaneStats:GetAllStatusEffects()) do
			if k:lower():StartsWith(internalName) then
				table.insert(suggestions, "insanestats_wpass2_statuseffect_clear "..k)
			end
		end
		
		table.sort(suggestions)
		return suggestions
	end
end, "Clears a status effect from a named entity. If no name is specified, the effect will be cleared from you, \z
or from all players when entered through the server console.\
Format: insanestats_wpass2_statuseffect_clear <internalName> [entity=self]")

concommand.Add("insanestats_wpass2_modifiers_stats", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		local modifierWeights = {
			weapon = {total = 0, negative = 0, totalCount = 0, negativeCount = 0},
			armor = {total = 0, negative = 0, totalCount = 0, negativeCount = 0}
		}

		for k,v in pairs(InsaneStats:GetAllModifiers()) do
			if bit.band(v.flags or 0, InsaneStats.WPASS2_FLAGS.ARMOR) == 0 then
				local relevantTable = modifierWeights.weapon
				local weight = v.weight or 1
				relevantTable.total = relevantTable.total + weight
				relevantTable.totalCount = relevantTable.totalCount + 1

				if (v.cost or 1) < 0 then
					relevantTable.negative = relevantTable.negative + weight
					relevantTable.negativeCount = relevantTable.negativeCount + 1
				end
			else
				local relevantTable = modifierWeights.armor
				local weight = v.weight or 1
				relevantTable.total = relevantTable.total + weight
				relevantTable.totalCount = relevantTable.totalCount + 1

				if (v.cost or 1) < 0 then
					relevantTable.negative = relevantTable.negative + weight
					relevantTable.negativeCount = relevantTable.negativeCount + 1
				end
			end
		end

		local relevantTable = modifierWeights.weapon
		InsaneStats:Log("Weapon Modifiers: %u (Weight: %.1f)",
			relevantTable.totalCount,
			relevantTable.total
		)
		InsaneStats:Log("- Positive: %u (Weight: %.1f (%.1f%%))",
			relevantTable.totalCount - relevantTable.negativeCount,
			relevantTable.total - relevantTable.negative,
			100 - (relevantTable.negative / relevantTable.total) * 100
		)
		InsaneStats:Log("- Negative: %u (Weight: %.1f (%.1f%%))",
			relevantTable.negativeCount,
			relevantTable.negative,
			relevantTable.negative / relevantTable.total * 100
		)

		local relevantTable = modifierWeights.armor
		InsaneStats:Log("Armor Modifiers: %u (Weight: %.1f)",
			relevantTable.totalCount,
			relevantTable.total
		)
		InsaneStats:Log("- Positive: %u (Weight: %.1f (%.1f%%))",
			relevantTable.totalCount - relevantTable.negativeCount,
			relevantTable.total - relevantTable.negative,
			100 - (relevantTable.negative / relevantTable.total) * 100
		)
		InsaneStats:Log("- Negative: %u (Weight: %.1f (%.1f%%))",
			relevantTable.negativeCount,
			relevantTable.negative,
			relevantTable.negative / relevantTable.total * 100
		)
	end
end, nil, "Calculates some numbers related to modifier counts, weights and percentages.")

concommand.Add("insanestats_wpass2_modifiers_add", function(ply, cmd, args, argStr)
	if (IsValid(ply) and ply:IsAdmin()) then
		if #args < 1 then
			InsaneStats:Log("Format: insanestats_wpass2_modifiers_add <\"held\"|\"battery\"> <internalName> [tiers=1] [force]")
		else
			local currentWep = NULL
			if args[1] == "held" then
				currentWep = ply:GetActiveWeapon()
				if not IsValid(currentWep) then
					return InsaneStats:Log("You need to hold a weapon first!")
				end
			elseif args[1] == "battery" then
				currentWep = ply
			else
				return InsaneStats:Log("First argument must be \"held\" or \"battery\"!")
			end

			local modifiers = InsaneStats:GetAllModifiers()
			local name = args[2]
			local tiers = args[3] or 1
			local force = args[4] == "force"

			local tiersTemp = tonumber(tiers)
			if not tiersTemp then
				return InsaneStats:Log("\"%s\" is not a valid number!", tiers)
			end
			tiers = math.floor(tiersTemp)

			local toApply = {}
			if name == "***" then
				for k,v in pairs(modifiers) do
					toApply[k] = tiers
				end
			elseif name == "*" then
				for k,v in pairs(InsaneStats:GetModifierProbabilities(currentWep)) do
					toApply[k] = tiers
				end
			elseif modifiers[name] then
				toApply[name] = tiers
			else
				return InsaneStats:Log(
					"\"%s\" is not a valid modifier, make sure to use the modifier's internal name!",
					name
				)
			end

			currentWep.insaneStats_Modifiers = currentWep.insaneStats_Modifiers or {}
			local wepModifiers = currentWep.insaneStats_Modifiers

			if not force then
				for k,v in pairs(toApply) do
					local currentTier = wepModifiers[k] or 0
					local maxTier = modifiers[k].max or math.huge
					if currentTier + v > maxTier then
						toApply[k] = maxTier - currentTier
					elseif currentTier + v < 0 then
						toApply[k] = -currentTier
					end
				end
			end

			local tierChange = 0
			local anyApplied = false
			for k,v in pairs(toApply) do
				if v ~= 0 then
					anyApplied = true
					tierChange = tierChange + (modifiers[k].cost or 1) * v

					local newModifierTier = (currentWep.insaneStats_Modifiers[k] or 0) + v
					if newModifierTier == 0 then
						currentWep.insaneStats_Modifiers[k] = nil
					else
						currentWep.insaneStats_Modifiers[k] = newModifierTier
					end
				end
			end

			if anyApplied then
				currentWep.insaneStats_StartTier = (currentWep.insaneStats_StartTier or 0) + tierChange
				InsaneStats:ApplyWPASS2Modifiers(currentWep)
			else
				InsaneStats:Log("Applied modifiers, but weapon remains unchanged!")
			end
		end
	end
end, function(cmd, argStr)
	local _, battery, internalName, tier, force = unpack(string.Explode("%s", argStr, true))
	if force then
		return {"insanestats_wpass2_modifiers_add "..battery.." "..internalName.." "..tier.." force"}
	elseif internalName and not tier then
		local suggestions = {}
		internalName = internalName:lower():Trim()
		
		for k,v in pairs(InsaneStats:GetAllModifiers()) do
			if k:lower():StartsWith(internalName) then
				table.insert(suggestions, "insanestats_wpass2_modifiers_add "..battery.." "..k)
			end
		end
		
		table.sort(suggestions)
		return suggestions
	elseif battery and not internalName then
		return {
			"insanestats_wpass2_modifiers_add battery",
			"insanestats_wpass2_modifiers_add held"
		}
	end
end, "Adds a modifier to the currently held weapon. \z
Negative tiers will cause modifiers to be removed instead.\
Specify the word \"force\" after the number of tiers \z
to make the command ignore minimum and maximum modifier tiers.\
You can specify * as the modifier name to select all possible modifiers for the current weapon \z
and *** to select ALL modifiers including impossible modifiers.\
Format: insanestats_wpass2_modifiers_add  <\"held\"|\"battery\"> <internalName> [tiers=1] [force]")

concommand.Add("insanestats_wpass2_giverandomweapons", function(ply, cmd, args, argStr)
	if (IsValid(ply) and ply:IsAdmin()) then
		local percent = tonumber(argStr)
		if percent then
			local fraction = math.Clamp(percent / 100, 0, 1)
			local spawnableWeaponList = {}
			for i,v in ipairs(weapons.GetList()) do
				if v.Spawnable then
					table.insert(spawnableWeaponList, v.ClassName)
				end
			end
			local numberOfWeapons = #spawnableWeaponList

			-- FIXME: this creates a table containing values from 1 to n
			-- just to sample some % of items from an n-long list, bweh
			local toShuffle = {}
			for i=1, numberOfWeapons do
				table.insert(toShuffle, i)
			end
			table.Shuffle(toShuffle)
			for i=1, math.Round(fraction * numberOfWeapons) do
				ply:Give(spawnableWeaponList[toShuffle[i]])
			end
		else
			InsaneStats:Log("\"%s\" is not a valid number!", percent)
		end
	end
end, nil, "Gives a random % of all weapons in the game for debugging purposes.")

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
		if v > 0 then
			table.insert(possibleSelections, k)
			weightSum = weightSum + v
			table.insert(selectionGaps, weightSum)
		end
	end
	
	-- generate a random number, then see where it fits
	local selection = math.random()*weightSum
	for i,v in ipairs(selectionGaps) do
		if selection < v then return possibleSelections[i] end
	end
	
	error(string.format("Failed to choose weighted random choice! Sum = %.1f, Selection = %.1f", weightSum, selection))
end

local function ApplyWPASS2StartTier(ent)
	-- figure out weapon tier
	local probability
	local isNotWep = not ent:IsWeapon()
	local owner = ent:GetOwner()

	if not IsValid(owner) then owner = ent.insaneStats_ProxyWeaponTo or NULL end
	
	if ent:InsaneStats_IsWPASS2Pickup() and not IsValid(owner) then
		probability = InsaneStats:GetConVarValueDefaulted(isNotWep and "wpass2_chance_unowned_battery", "wpass2_chance_unowned")
	elseif owner:IsPlayer() or ent:IsPlayer() then
		probability = InsaneStats:GetConVarValueDefaulted(isNotWep and "wpass2_chance_player_battery", "wpass2_chance_player")
	elseif ent:IsNPC() then
		local isAlly, isEnemy = false, false
		for k,v in player.Iterator() do
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
	else
		local blacklist = ' '..InsaneStats:GetConVarValue("wpass2_tier_blacklist")..' '
		if string.match(blacklist, "%s"..string.PatternSafe(ent:GetClass()).."%s") then
			canGetModifiers = false
		end
	end
	
	if math.random()*100 < probability and canGetModifiers then
		local tier = InsaneStats:GetConVarValueDefaulted(isNotWep and "wpass2_tier_start_battery", "wpass2_tier_start")
		local tierMax = InsaneStats:GetConVarValue("wpass2_tier_max")
		local tierMin = InsaneStats:GetConVarValue("wpass2_tier_min")
		
		local rolls = 0
		local chance = InsaneStats:GetConVarValueDefaulted(isNotWep and "wpass2_tier_upchance_battery", "wpass2_tier_upchance")
		
		while rolls < 12058 and math.random()*100 < chance and tier < tierMax - tierMin do
			rolls = rolls + 1
			tier = tier + 1
		end

		chance = InsaneStats:GetConVarValueDefaulted(isNotWep and "wpass2_tier_downchance_battery", "wpass2_tier_downchance")
		while rolls < 24116 and math.random()*100 < chance and tier > tierMin do
			rolls = rolls + 1
			tier = tier - 1
		end
		
		ent.insaneStats_StartTier = math.min(tier, tierMax) + math.random()
	else
		ent.insaneStats_StartTier = 0
	end
	
	return ent.insaneStats_StartTier
end

local function ApplyWPASS2Tier(ent)
	if CurTime() < 2 or player.GetCount() == 0 then return false end
	local tier = ent.insaneStats_StartTier or ApplyWPASS2StartTier(ent)
	local isNotWep = not ent:IsWeapon()
	
	if InsaneStats:GetConVarValue("xp_enabled") and InsaneStats:GetConVarValue("wpass2_tier_xp_enable") and tier ~= 0 then
		local effectiveLevel = ent:InsaneStats_GetLevel()
		if not ent:InsaneStats_IsWPASS2Pickup() then
			if not ent:InsaneStats_GetEntityData("battery_xp") then
				ent:InsaneStats_SetBatteryXP(ent:InsaneStats_GetXP())
				if not ent:InsaneStats_GetEntityData("battery_xp") then return false end
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
			math.max(
				InsaneStats:GetConVarValue("wpass2_tier_min"),
				-10000
			),
			math.min(
				InsaneStats:GetConVarValue("wpass2_tier_max"),
				10000
			)
		)
	)
	
	return true
end

local function MergeWPASS2Modifiers(applyModifiers, modifierProbabilities, toCheck)
	local modifiers = InsaneStats:GetAllModifiers()
	local mergeEffects = InsaneStats.mergeEffectsToCheck
	local modifierCount = 0

	while next(toCheck) do
		local appliedModifier = table.remove(toCheck)
		for k,v in pairs(mergeEffects[appliedModifier]) do
			local modifierTable = modifiers[v]

			if applyModifiers[v] then
				-- recursively grab all constituent modifiers
				-- FIXME: this is inefficient, previous modifiers may already have been checked!
				local modifiersToMerge = {}
				local modifiersRequiredToMerge = {}
				for i,v2 in ipairs(modifierTable.merge) do
					modifiersRequiredToMerge[v2] = true
				end

				while next(modifiersRequiredToMerge) do
					local additionalRequiredToMerge = {}

					for k2,v2 in pairs(modifiersRequiredToMerge) do
						modifiersToMerge[k2] = true
						for i,v3 in ipairs(modifiers[k2] and modifiers[k2].merge or {}) do
							additionalRequiredToMerge[v3] = true
						end
					end

					modifiersRequiredToMerge = additionalRequiredToMerge
				end

				local mergePoints = applyModifiers[v]
				for k2,v2 in pairs(modifiersToMerge) do
					if applyModifiers[k2] then
						mergePoints = mergePoints + applyModifiers[k2]

						modifierCount = modifierCount - 1
						--maxModifiersLevel = maxModifiersLevel - (modifiers[v2].max or 65536)
						applyModifiers[k2] = nil
						modifierProbabilities[k2] = nil
					end
				end
				
				applyModifiers[v] = mergePoints
				modifierProbabilities[v] = modifierTable.weight or 1
			else
				local mergePoints = 0
				local modifiersRequiredToMerge = modifierTable.merge

				--[[local mergeInto
				local toCheckForAlreadyApplied = {v}
				while toCheckForAlreadyApplied do
					if applyModifiers[v] then
						mergeInto = v break
					elseif mergeEffects[v] then
						-- ...
					end
				end]]
				
				for k2,v2 in pairs(modifiersRequiredToMerge) do
					if applyModifiers[v2] then
						mergePoints = mergePoints + applyModifiers[v2]
					else
						mergePoints = 0 break
					end
				end
				
				if mergePoints > 0 then
					applyModifiers[v] = mergePoints
					modifierCount = modifierCount + 1
					--maxModifiersLevel = maxModifiersLevel + (modifierTable.max or 65536)
					
					modifierProbabilities[v] = modifierTable.weight or 1
					
					for k2,v2 in pairs(modifiersRequiredToMerge) do
						modifierCount = modifierCount - 1
						--maxModifiersLevel = maxModifiersLevel - (modifiers[v2].max or 65536)
						applyModifiers[v2] = nil
						modifierProbabilities[v2] = nil
					end
				end
			end

			if mergeEffects[v] then
				table.insert(toCheck, 1, v)
			end
		end
	end

	return applyModifiers, modifierProbabilities, modifierCount
end

local toUpdateModifierEntities = {}
function InsaneStats:ApplyWPASS2Modifiers(wep, blacklist)
	if not ApplyWPASS2Tier(wep) then
		toUpdateModifierEntities[wep] = true
		return
	end
	
	local modifiers = self:GetAllModifiers()
	local modifierProbabilities = self:GetModifierProbabilities(wep)
	local blacklistedModifiers = blacklist and table.Copy(blacklist) or {}

	for k,v in pairs(modifierProbabilities) do
		if blacklistedModifiers[k] then
			modifierProbabilities[k] = nil
		end
	end
	
	-- TODO: flags should be ignored if the weapon somehow already has the modifier (such as from a merge)
	-- if a merge occured, the constituent modifiers cannot appear
	local appliedModifiers = wep.insaneStats_Modifiers or {}
	if appliedModifiers then
	end

	local applyModifiers = wep.insaneStats_Modifiers or {}
	local modifierCount = 0
	local tiersPerModifier = self:GetConVarValueDefaulted(not isWep and "wpass2_tier_newmodifiercost_battery", "wpass2_tier_newmodifiercost")
	local points = wep.insaneStats_Tier
	local modifiersLeveled = 0
	--local maxModifiersLevel = 0
	local potentiallyMergableModifiers = {}

	for k,v in pairs(applyModifiers) do
		local modifierTable = modifiers[k]
		if modifierTable then
			if self.mergeEffectsToCheck[k] then
				table.insert(potentiallyMergableModifiers, k)
			end

			modifierCount = modifierCount + 1
			--maxModifiersLevel = maxModifiersLevel + (modifierTable.max or 65536)

			modifiersLeveled = modifiersLeveled + v
			points = points - (modifierTable.cost or 1) * v
			if v >= (modifierTable.max or 65536) then
				modifierProbabilities[k] = nil
			end
		else
			applyModifiers[k] = nil
		end
	end

	local mergeReturn = {MergeWPASS2Modifiers(
		applyModifiers,
		modifierProbabilities,
		potentiallyMergableModifiers
	)}
	applyModifiers = mergeReturn[1]
	modifierProbabilities = mergeReturn[2]
	modifierCount = modifierCount + mergeReturn[3]

	local wpass2Enabled = InsaneStats:GetConVarValue("wpass2_enabled")
	if self:IsDebugLevel(2) and wpass2Enabled then
		InsaneStats:Log("Spending %i points on %s...", points, tostring(wep))
	end
	for i=1+modifiersLeveled, 12058+modifiersLeveled do
		if points == 0 then break end
		
		-- check each entry and figure out which ones are applicable
		local currentModifierProbabilities = {}
		for k,v in pairs(modifierProbabilities) do
			local modifierTable = modifiers[k]
			local cost = modifierTable.cost or 1

			if (cost < 0 or cost <= points) and v > 0
			and (modifierCount * tiersPerModifier < math.abs(wep.insaneStats_Tier) or applyModifiers[k] and cost >= 0) then
				currentModifierProbabilities[k] = v
			end
		end

		if table.IsEmpty(currentModifierProbabilities) then -- use more lenient criteria
			for k,v in pairs(modifierProbabilities) do
				local modifierTable = modifiers[k]
				local cost = modifierTable.cost or 1
	
				if (cost < 0 or cost <= points) and v > 0 then
					currentModifierProbabilities[k] = v
				end
			end
		end

		if self:IsDebugLevel(2) and wpass2Enabled then
			InsaneStats:Log("Possible choices:")
			PrintTable(currentModifierProbabilities)
		end

		if next(currentModifierProbabilities) then
			local appliedModifier = SelectWeightedRandom(currentModifierProbabilities)

			if self:IsDebugLevel(2) and wpass2Enabled then
				InsaneStats:Log("Selected %s!", appliedModifier)
			end
			local modifierTable = modifiers[appliedModifier]
			
			if applyModifiers[appliedModifier] then
				applyModifiers[appliedModifier] = applyModifiers[appliedModifier] + 1
			else
				applyModifiers[appliedModifier] = 1
				modifierCount = modifierCount + 1
				--maxModifiersLevel = maxModifiersLevel + (modifierTable.max or 65536)
			end
			
			points = points - (modifierTable.cost or 1)
			if applyModifiers[appliedModifier] >= (modifierTable.max or 65536) then
				modifierProbabilities[appliedModifier] = nil
			end

			if self.mergeEffectsToCheck[appliedModifier] then
				local mergeReturn = {MergeWPASS2Modifiers(
					applyModifiers,
					modifierProbabilities,
					{appliedModifier}
				)}
				
				applyModifiers = mergeReturn[1]
				modifierProbabilities = mergeReturn[2]
				modifierCount = modifierCount + mergeReturn[3]
			end
		else
			break--InsaneStats:Log("Couldn't spend %i points to modify %s further!", points, tostring(wep))
		end
	end
	if self:IsDebugLevel(2) and wpass2Enabled then
		InsaneStats:Log("%i points left!", points)
	end
	
	wep.insaneStats_Modifiers = applyModifiers
	if not wep:InsaneStats_IsWPASS2Pickup() and (wep.GetMaxArmor and wep:GetMaxArmor() <= 0)
	and not wep:IsPlayer() and wep.insaneStats_Tier ~= 0 then
		-- apply armor
		local startingHealth = wep:InsaneStats_GetMaxHealth() / wep:InsaneStats_GetCurrentHealthAdd()
		local startingArmor = startingHealth * self:GetConVarValue("infhealth_armor_mul")
		wep:SetMaxArmor(wep:InsaneStats_GetMaxHealth() * self:GetConVarValue("infhealth_armor_mul"))
		wep:InsaneStats_SetCurrentArmorAdd(wep:InsaneStats_GetMaxArmor() / startingArmor)
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

function InsaneStats:GetWPASS2SavedData()
	return playerLoadoutData
end

-- this coroutine thread deals with entity relationship collections
-- for ENTITY:InsaneStats_GetValidEnemies() and ENTITY:InsaneStats_GetValidAllies()
--[[local relationships = {}
local markingScanner = coroutine.create(function()
	while true do
		local allEnts = ents.GetAll()
		local npcs = {}
		for i,v in ipairs(allEnts) do
			if v:IsNPC() then
				table.insert(npcs, v)
			end
			coroutine.yield()
		end

		for i,v in ipairs(relationships) do
			if IsValid(v) then
			end
		end
	end
end)

hook.Add("Think", "InsaneStatsWPASS", function()
end)]]

timer.Create("InsaneStatsWPASS", 5, 0, function()
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
		for i,v in player.Iterator() do
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
	if self.insaneStats_LastCombatTime and self.insaneStats_LastCombatTime + 10 < CurTime() then
		self.insaneStats_StartCombatTime = nil
	end
	return self.insaneStats_StartCombatTime and CurTime() - self.insaneStats_StartCombatTime or -1
end

function ENTITY:InsaneStats_UpdateCombatTime()
	if self.insaneStats_LastCombatTime and self.insaneStats_LastCombatTime + 10 < CurTime() then
		self.insaneStats_StartCombatTime = nil
	end
	if not self.insaneStats_StartCombatTime then
		self.insaneStats_StartCombatTime = CurTime()
	end
	self.insaneStats_LastCombatTime = CurTime()
end

function ENTITY:InsaneStats_TimeSinceCombat()
	return self.insaneStats_LastCombatTime and self.insaneStats_LastCombatTime - CurTime() or math.huge
end

function ENTITY:InsaneStats_AddHealthNerfed(health)
	local oldHealth = self:InsaneStats_GetHealth()
	if oldHealth < math.huge and oldHealth > 0 
	and self:InsaneStats_GetMaxHealth() > 0 then
		local data = {health = health, ent = self, nerfFactor = 0.5}
		hook.Run("InsaneStatsWPASS2AddHealth", data)

		local maxHealth = self:InsaneStats_GetMaxHealth()
		local oldRatio = oldHealth / maxHealth
		local nerfFactor = data.nerfFactor
		if oldRatio > 1 then
			oldRatio = oldRatio^(1/nerfFactor)
		end

		local newRatio = oldRatio + data.health / maxHealth
		if newRatio > 1 then
			newRatio = newRatio^nerfFactor
		end
		local healthAdded = newRatio * maxHealth - oldHealth
		
		if healthAdded ~= 0 then
			self:SetHealth(newRatio * maxHealth)
			hook.Run("InsaneStatsWPASS2AddedHealth", self)
			self:InsaneStats_DamageNumber(self, oldHealth - self:InsaneStats_GetHealth(), DMG_DROWNRECOVER)
		end
	end
end

function ENTITY:InsaneStats_AddArmorNerfed(armor)
	local oldArmor = self:InsaneStats_GetArmor()
	if oldArmor < math.huge and self:InsaneStats_GetHealth() > 0
	and self:InsaneStats_GetMaxArmor() > 0 then
		local data = {armor = armor, ent = self, nerfFactor = 0.5}
		hook.Run("InsaneStatsWPASS2AddArmor", data)

		local maxArmor = self:InsaneStats_GetMaxArmor()
		local oldRatio = oldArmor / maxArmor
		local nerfFactor = data.nerfFactor
		if oldRatio > 1 then
			oldRatio = oldRatio^(1/nerfFactor)
		end

		local newRatio = oldRatio + armor / maxArmor
		if newRatio > 1 then
			newRatio = newRatio^nerfFactor
		end
		local armorAdded = newRatio * maxArmor - oldArmor
		
		if armorAdded ~= 0 then
			self:SetArmor(newRatio * maxArmor)
			hook.Run("InsaneStatsWPASS2AddedArmor", self)
			self:InsaneStats_DamageNumber(self, oldArmor - self:InsaneStats_GetArmor(), DMG_DROWN)
		end
	end
end

function ENTITY:InsaneStats_AddHealthCapped(health)
	local oldHealth = self:InsaneStats_GetHealth()
	if oldHealth > 0 and oldHealth < self:InsaneStats_GetMaxHealth() then
		local data = {health = health, ent = self, nerfFactor = 0.5}
		hook.Run("InsaneStatsWPASS2AddHealth", data)

		local healthAdded = oldHealth < math.huge and math.min(data.health, self:InsaneStats_GetMaxHealth() - oldHealth) or 0
		if healthAdded ~= 0 then
			self:SetHealth(oldHealth + healthAdded)
			hook.Run("InsaneStatsWPASS2AddedHealth", self)
			self:InsaneStats_DamageNumber(self, oldHealth - self:InsaneStats_GetHealth(), DMG_DROWNRECOVER)
		end
	end
end

function ENTITY:InsaneStats_AddArmorCapped(armor)
	local oldArmor = self:InsaneStats_GetArmor()
	if self:InsaneStats_GetHealth() > 0 and oldArmor < self:InsaneStats_GetMaxArmor() then
		local data = {armor = armor, ent = self, nerfFactor = 0.5}
		hook.Run("InsaneStatsWPASS2AddArmor", data)

		local armorAdded = oldArmor < math.huge and math.min(data.armor, self:InsaneStats_GetMaxArmor() - oldArmor) or 0
		if armorAdded ~= 0 then
			self:SetArmor(oldArmor + armorAdded)
			hook.Run("InsaneStatsWPASS2AddedArmor", self)
			self:InsaneStats_DamageNumber(self, oldArmor - self:InsaneStats_GetArmor(), DMG_DROWN)
		end
	end
end

function ENTITY:InsaneStats_AddMaxHealth(health)
	health = math.max(health, 0)

	-- if insaneStats_CurrentHealthAdd is nil, define it
	-- so that the level system doesn't assume the already level-scaled health to be starting health
	if (self:InsaneStats_GetEntityData("xp_health_mul") or 1) == 1 then
		local scaleType = self:IsPlayer() and "player" or "other"
		local effectiveLevel = InsaneStats:GetConVarValue("xp_enabled") and self:InsaneStats_GetLevel() or 1
		local val = InsaneStats:ScaleValueToLevelQuadratic(
			100,
			InsaneStats:GetConVarValue("xp_"..scaleType.."_health")/100,
			effectiveLevel,
			"xp_"..scaleType.."_health_mode",
			false,
			InsaneStats:GetConVarValue("xp_"..scaleType.."_health_add")/100
		)

		self:InsaneStats_SetCurrentHealthAdd(val)
	end

	local data = {maxHealth = health, ent = self}
	hook.Run("InsaneStatsWPASS2AddMaxHealth", data)
	self:SetMaxHealth(math.max(self:InsaneStats_GetMaxHealth() + data.maxHealth, 0))
end

function ENTITY:InsaneStats_AddMaxArmor(armor)
	if self.SetMaxArmor then
		if (self:InsaneStats_GetEntityData("xp_armor_mul") or 1) == 1 then
			local scaleType = self:IsPlayer() and "player" or "other"
			local effectiveLevel = InsaneStats:GetConVarValue("xp_enabled") and self:InsaneStats_GetLevel() or 1
			local val = InsaneStats:ScaleValueToLevelQuadratic(
				100,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_armor")/100,
				effectiveLevel,
				"xp_"..scaleType.."_armor_mode",
				false,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_armor_add")/100
			)
	
			self:InsaneStats_SetCurrentArmorAdd(val)
		end

		local data = {maxArmor = armor, ent = self}
		hook.Run("InsaneStatsWPASS2AddMaxArmor", data)
		self:SetMaxArmor(math.max(self:InsaneStats_GetMaxArmor() + data.maxArmor, 0))
	end
end

function ENTITY:InsaneStats_IsValidEnemy(ent)
	local class = IsValid(ent) and ent:GetClass()
	if not IsValid(self) or not (class and class ~= "npc_enemyfinder" and class ~= "monster_hgrunt_dead") then
		return false
	end
	if (ent:InsaneStats_GetHealth() <= 0 or ent.insaneStats_IsDead) and class ~= "npc_rollermine" then
		return false
	end
	
	if self:IsPlayer() and class == "npc_antlion_grub" then return true end
	
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

	-- if in a map named "phys_cratastrophy", all crates are enemies lol
	if game.GetMap() == "phys_cratastrophy" and ent:GetModel() == "models/props_junk/wood_crate001a.mdl" then return true end
	
	return false
end

function ENTITY:InsaneStats_IsValidAlly(ent)
	-- this returns true when ent -> self is an ally relationship (without regarding self -> ent)
	if not IsValid(ent) then return false end
	
	-- poll Disposition to figure out if ent is an ally
	if (ent.Disposition and ent:Disposition(self) == D_LI) then return true end

	-- if it's a citizen, neutrals count as allies as well
	if (ent:GetClass() == "npc_citizen" and ent:Disposition(self) == D_NU) then return true end
	
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

function ENTITY:InsaneStats_GetEffectiveSpeed()
	local data = {speed = self:GetVelocity():Length(), ent = self}
	if self:IsPlayer() then
		data.speed = data.speed * self:GetLaggedMovementValue()
	end
	hook.Run("InsaneStatsEffectiveSpeed", data)
	return data.speed
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
		oldItem.insaneStats_NextPickup = CurTime() + 0.2
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
			self:InsaneStats_GetArmor() + GetConVar("sk_battery"):GetFloat() * self:InsaneStats_GetCurrentArmorAdd()
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

function PLAYER:InsaneStats_AttemptEquipItem(ent)
	if InsaneStats:GetConVarValue("wpass2_enabled") and IsValid(ent) then
		local nextPickup = self.insaneStats_NextPickup or 0
		local curTime = CurTime()
		
		if nextPickup < curTime or nextPickup > curTime + 0.2 then
			if ent:IsWeapon() and not ent:HasSpawnFlags(SF_WEAPON_NO_PLAYER_PICKUP) and self:HasWeapon(ent:GetClass()) and not IsValid(ent:GetOwner()) then
				self.insaneStats_NextPickup = curTime + 0.2
				
				local mins, maxs = self:GetHull()
				mins = mins + self:GetPos() + Vector(-32, -32, -32)
				maxs = maxs + self:GetPos() + Vector(32, 32, 32)
				local class = ent:GetClass()
				for i,v in ipairs(ents.FindInBox(mins, maxs)) do
					if v:GetClass() == class and v ~= ent then
						v.insaneStats_NextPickup = curTime + 0.2
					end
				end
				
				local oldEnt = self:GetWeapon(ent:GetClass())
				--[[oldEnt.insaneStats_NextPickup = curTime + 1]]
				self:DropWeapon(oldEnt)
				--[[timer.Simple(0.2, function()
					if (IsValid(self) and IsValid(ent) and not self:HasWeapon(ent:GetClass())) then
						-- somehow the player didn't pick up the weapon
						InsaneStats:Log("Forcing weapon "..tostring(ent).." into "..tostring(self).."'s hands...")
						self:PickupWeapon(ent)
						SaveData(self)
					end
				end)]]
			elseif ent:GetClass() == "item_battery" then
				self.insaneStats_NextPickup = curTime + 0.2
				
				self:InsaneStats_EquipBattery(ent)
				timer.Simple(1, function()
					if IsValid(self) then
						SaveData(self)
					end
				end)
			end

			if ent:InsaneStats_IsWPASS2Pickup() then
				self.insaneStats_Last2Pickups = self.insaneStats_Last2Pickups or {}
				while #self.insaneStats_Last2Pickups > 1 do
					local lastLastPickup = table.remove(self.insaneStats_Last2Pickups)
					if lastLastPickup == ent then
						self.insaneStats_ReswappedCount = (self.insaneStats_ReswappedCount or 0) + 1
					else
						self.insaneStats_ReswappedCount = 0
					end
				end
				table.insert(self.insaneStats_Last2Pickups, 1, ent)

				if (self.insaneStats_ReswappedCount or 0) > 4 then
					self.insaneStats_ReswappedCount = -5
					net.Start("insane_stats")
					net.WriteUInt(5, 8)
					net.WriteString("Hold the Sprint key while pressing Use to pick up items normally!")
					net.WriteColor(Color(255, 0, 0))
					net.Send(self)
				end
			end
		end
	end
end

function PLAYER:InsaneStats_ShouldAutoPickup(item, speculative)
	if IsValid(item:GetOwner()) then return true end

	local devEnabled = InsaneStats:IsDebugLevel(3)
	local isBattery = item:GetClass() == "item_battery"
	local autoPickup

	if isBattery then
		autoPickup = self:GetInfoNum("insanestats_wpass2_autopickup_battery_override", -1) or -1
		if autoPickup < 0 then
			autoPickup = InsaneStats:GetConVarValueDefaulted("wpass2_autopickup_battery", "wpass2_autopickup")
		end
	else
		autoPickup = self:GetInfoNum("insanestats_wpass2_autopickup_override", -1) or -1
		if autoPickup < 0 then
			autoPickup = InsaneStats:GetConVarValue("wpass2_autopickup")
		end
	end

	--[[if devEnabled then
		InsaneStats:Log(string.format(
			"Auto pickup mode is %s for %s.",
			autoPickup, tostring(self)
		))
	end]]

	if autoPickup == 0 then
		if devEnabled then
			InsaneStats:Log(
				"[%f] Prevented %s from picking up %s due to auto pickup rules.",
				RealTime(), tostring(self), tostring(item)
			)
		end
		return false
	end

	local newTier = item.insaneStats_Tier or 0
	if newTier ~= 0 then
		if autoPickup == 1 then
			if devEnabled then
				InsaneStats:Log(
					"[%f] Prevented %s from picking up %s due to auto pickup rules.",
					RealTime(), tostring(self), tostring(item)
				)
			end
			return false
		end 
		
		local ourItem = isBattery and self or self:GetWeapon(item:GetClass())
		if IsValid(ourItem) then
			local currentTier = ourItem.insaneStats_Tier or 0
			
			if newTier > currentTier then
				local autoSwap = autoPickup == 3 or autoPickup == 5
				if autoSwap and not speculative then
					self:InsaneStats_AttemptEquipItem(item)
				end
				
				if autoPickup < 6 then
					if devEnabled then
						InsaneStats:Log(
							"[%f] Prevented %s from picking up %s due to auto pickup rules.",
							RealTime(), tostring(self), tostring(item)
						)
					end
					return false, autoSwap
				end
			elseif newTier == currentTier and autoPickup < 4 then
				if devEnabled then
					InsaneStats:Log(
						"[%f] Prevented %s from picking up %s due to auto pickup rules.",
						RealTime(), tostring(self), tostring(item)
					)
				end
				return false
			end
		end
	end

	return true
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

		--[[if ent:GetClass() == "trigger_changelevel" then
			ent:Fire("AddOutput", "OnChangeLevel !self:InsaneStatsChangeLevel::0:-1")
		end]]
	end
end)

hook.Add("AcceptInput", "InsaneStatsWPASS", function(ent, input, activator, caller, value)
	input = input:lower()
	if input == "insidetransition" or input == "outsidetransition" then
		-- purge stats
		if input == "outsidetransition" then
			if InsaneStats:IsDebugLevel(1) and ent.insaneStats_Modifiers then
				InsaneStats:Log(
					"Purging %u modifiers from %s entities to save space!",
					table.Count(ent.insaneStats_Modifiers), tostring(ent)
				)
			end
			ent.insaneStats_Modifiers = nil
			--[[if devEnabled and ent.insaneStats_Attributes then
				InsaneStats:Log(string.format("Purging %u attributes from %s to save space!", table.Count(ent.insaneStats_Attributes), tostring(ent)))
			end
			ent.insaneStats_Attributes = nil]]
			if ent.insaneStats_IsProxyWeapon then
				ent:Fire("Kill")
			end
		end
	end
end)

hook.Add("InsaneStatsPlayerCanPickupItem", "InsaneStatsWPASS", function(ply, item)
	local class = item:GetClass()
	if InsaneStats:GetConVarValue("wpass2_enabled")
	and (item.insaneStats_DisableWPASS2Pickup or 0) <= RealTime() 
	and class == "item_battery"
	and not ply:InsaneStats_ShouldAutoPickup(item) then
		return false
	elseif class == "item_suit" and item:CreatedByMap() then
		ply:InsaneStats_SetEntityData("do_not_strip_suit", true)
	end

	toSavePlayers[ply] = true
end)

hook.Add("PlayerCanPickupWeapon", "InsaneStatsWPASS", function(ply, wep)
	local nextPickup = wep.insaneStats_NextPickup or 0
	local curTime = CurTime()
	local devEnabled = InsaneStats:IsDebugLevel(3)
	
	-- we want to pick up the correct weapon in a pile,
	-- so prevent them from picking up the wrong weapons for a sec
	if nextPickup > curTime and nextPickup < curTime + 2 then
		if devEnabled then
			InsaneStats:Log(
				"Prevented %s from picking up %s due to pickup cooldown.",
				tostring(ply), tostring(wep)
			)
		end
		return false
	end

	local class = wep:GetClass()
	if InsaneStats:GetConVarValue("wpass2_enabled")
	and (wep.insaneStats_DisableWPASS2Pickup or 0) <= RealTime()
	and ply:HasWeapon(class)
	and not ply:InsaneStats_ShouldAutoPickup(wep) then
		return false
	end

	if InsaneStats:GetConVarValue("wpass2_enabled")
	and wep:IsWeapon() and ply:HasWeapon(class)
	and not wep.insaneStats_Tier then
		return false
	end
	
	hook.Run("InsaneStatsPlayerCanPickupWeapon", ply, wep)
	toSavePlayers[ply] = true
end)

hook.Add("WeaponEquip", "InsaneStatsWPASS", function(wep, ply)
	timer.Simple(0, function()
		if wep.insaneStats_Tier and IsValid(ply) then
			local minTierDifference = ply:GetInfoNum("insanestats_wpass2_equip_highest_tier", 0)
			local currentlyEquippedTier = ply:GetActiveWeapon().insaneStats_Tier
			if minTierDifference > 0 and (
				currentlyEquippedTier
				and wep.insaneStats_Tier - currentlyEquippedTier >= minTierDifference
			) then
				-- tell the client to switch to it
				net.Start("insane_stats", true)
				net.WriteUInt(14, 8)
				net.WriteEntity(wep)
				net.Send(ply)
			end
		end
	end)
end)

hook.Add("PlayerUse", "InsaneStatsWPASS", function(ply, ent)
	if ent:InsaneStats_IsWPASS2Pickup() and ply:KeyDown(IN_SPEED) then
		local nextPickup = ply.insaneStats_NextPickup or 0
		local curTime = CurTime()
		
		if nextPickup < curTime or nextPickup > curTime + 0.2 then
			ply.insaneStats_NextPickup = curTime + 0.2
			ent.insaneStats_DisableWPASS2Pickup = RealTime() + 1
		end
	else
		ply:InsaneStats_AttemptEquipItem(ent)
	end
end)

SaveDataFile = function()
	local shouldSave = InsaneStats:GetConVarValue("wpass2_modifiers_player_save")
	local shouldSaveBattery = InsaneStats:GetConVarValueDefaulted("wpass2_modifiers_player_save_battery", "wpass2_modifiers_player_save")
	
	if shouldSave > 0 or shouldSaveBattery > 0 then
		local data = InsaneStats:Load()
		data.wpass2 = playerLoadoutData
		InsaneStats:Save(data)
	end
end

local function GetPlayerWPASS2SaveData(ply, forced, shouldSave, shouldSaveBattery, oldData)
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
					xp = v:InsaneStats_GetXP() ~= math.huge and v:InsaneStats_GetXP() or "inf"
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
				oldData = oldData or {}
				oldData.healthArmorAndSuitStats = oldData.healthArmorAndSuitStats or {}
				plyWPASS2Data.healthArmorAndSuitStats = {
					maxHealth = oldData.healthArmorAndSuitStats.maxHealth,
					maxArmor = oldData.healthArmorAndSuitStats.maxArmor,
					suit = ply:IsSuitEquipped()
				}

				local health, maxHealth = ply:InsaneStats_GetHealth(), ply:InsaneStats_GetMaxHealth()
				local armor, maxArmor = ply:InsaneStats_GetArmor(), ply:InsaneStats_GetMaxArmor()
				if not forced then
					if health > 0 then
						plyWPASS2Data.healthArmorAndSuitStats.health = health
					end
					if armor > 0 then
						plyWPASS2Data.healthArmorAndSuitStats.armor = armor
					end
				end
				if maxHealth > 0 then
					plyWPASS2Data.healthArmorAndSuitStats.maxHealth = maxHealth
				end
				if maxArmor > 0 then
					plyWPASS2Data.healthArmorAndSuitStats.maxArmor = maxArmor
				end
			end
		end
		
		--[[if GetConVar("developer"):GetInt() > 0 then
			InsaneStats:Log("Saved data for "..steamID)
			PrintTable(plyWPASS2Data)
		end]]
		return plyWPASS2Data
	end
end

SaveData = function(ply, forced)
	local steamID = ply:SteamID()
	-- if ply.insaneStats_WPASS2DataLoaded is false, do not save as the player is still initializing
	-- otherwise other addons that set a much lower max health on spawn will do so, then *that* data will be saved
	if steamID and (ply:Alive() or forced) and ply.insaneStats_WPASS2DataLoaded then
		local shouldSave = InsaneStats:GetConVarValue(
			forced and "wpass2_modifiers_player_save_death" or "wpass2_modifiers_player_save"
		)
		local shouldSaveBattery = InsaneStats:GetConVarValueDefaulted(
			forced and "wpass2_modifiers_player_save_death_battery" or "wpass2_modifiers_player_save_battery",
			forced and "wpass2_modifiers_player_save_death" or "wpass2_modifiers_player_save"
		)
		if shouldSave > 0 or shouldSaveBattery > 0 then
			playerLoadoutData[steamID] = GetPlayerWPASS2SaveData(ply, forced, shouldSave, shouldSaveBattery, playerLoadoutData[steamID])
		else
			playerLoadoutData[steamID] = nil
		end
		
		saveRequested = true

		if InsaneStats:IsDebugLevel(2) then
			InsaneStats:Log("Save data requested for %s, forced = %s", tostring(ply), tostring(forced))
		end
	end
end

local function ForceSaveData(ply)
	SaveData(ply, true)
	-- do not save while dead until data is loaded again
	ply.insaneStats_WPASS2DataLoaded = false
end

hook.Add("Saved", "InsaneStatsWPASS", function()
	for i,v in player.Iterator() do
		SaveData(v)
	end
	SaveDataFile()
end)
hook.Add("DoPlayerDeath", "InsaneStatsWPASS", ForceSaveData, -1)
hook.Add("PlayerSilentDeath", "InsaneStatsWPASS", ForceSaveData, -1)
hook.Add("PlayerDisconnected", "InsaneStatsWPASS", function(ply)
	SaveData(ply)
end)
hook.Add("ShutDown", "InsaneStatsWPASS", function()
	for i,v in player.Iterator() do
		SaveData(v)
	end
	SaveDataFile()
end)

hook.Add("InitPostEntity", "InsaneStatsWPASS", function()
	local shouldSave = InsaneStats:GetConVarValue("wpass2_modifiers_player_save")
	local shouldSaveBattery = InsaneStats:GetConVarValueDefaulted("wpass2_modifiers_player_save_battery", "wpass2_modifiers_player_save")
	
	local data = InsaneStats:Load()
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
	if ent.insaneStats_HealthRoot8 then
		ent:InsaneStats_SetEntityData("health", ent.insaneStats_HealthRoot8 ^ 8)
	end
	if ent.insaneStats_MaxHealthRoot8 then
		ent:InsaneStats_SetEntityData("max_health", ent.insaneStats_MaxHealthRoot8 ^ 8)
	end
	if ent.insaneStats_ArmorRoot8 then
		ent:InsaneStats_SetEntityData("armor", ent.insaneStats_ArmorRoot8 ^ 8)
	end
	if ent.insaneStats_MaxArmorRoot8 then
		ent:InsaneStats_SetEntityData("max_armor", ent.insaneStats_MaxArmorRoot8 ^ 8)
	end
	if ent.insaneStats_CurrentHealthAddRoot8 then
		ent:InsaneStats_SetCurrentHealthAdd(ent.insaneStats_CurrentHealthAddRoot8 ^ 8)
	end
	if ent.insaneStats_CurrentArmorAddRoot8 then
		ent:InsaneStats_SetCurrentArmorAdd(ent.insaneStats_CurrentArmorAddRoot8 ^ 8)
	end
	if ent.insaneStats_XPRoot8 then
		ent:InsaneStats_SetXP(ent.insaneStats_XPRoot8 ^ 8)
	end
	if ent.insaneStats_DropXPRoot8 then
		ent:InsaneStats_SetDropXP(ent.insaneStats_DropXPRoot8 ^ 8)
	end
	if ent.insaneStats_Modifiers then
		InsaneStats:ApplyWPASS2Attributes(ent)
	end
	if ent.insaneStats_BatteryXPRoot8 then
		ent:InsaneStats_SetBatteryXP(ent.insaneStats_BatteryXPRoot8 ^ 8)
	end
	if ent.insaneStats_IsProxyWeapon and not IsValid(ent.insaneStats_ProxyWeaponTo) then
		SafeRemoveEntityDelayed(ent, 0.015)
	end
end)

hook.Add("PlayerInitialSpawn", "InsaneStatsWPASS", function(ply, fromTransition)
	-- do not save until data is fully loaded
	-- this value resets on map transition, so it needs to be set again
	ply.insaneStats_WPASS2DataLoaded = false
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
	
	-- FIXME: 4x cascading timers?! There has to be a better way than this!
	timer.Simple(0.25, function() -- wait for xp to settle first
		timer.Simple(0.25, function() -- wait for WPASS2 to settle first
			timer.Simple(0.25, function() -- wait for WPASS2 health and armor mods to settle first
				timer.Simple(0.25, function()
					if IsValid(ply) then
						ply.insaneStats_WPASS2DataLoaded = true
						
						local steamID = ply:SteamID()
						local plyWPASS2Data = steamID and playerLoadoutData[steamID]
						
						if plyWPASS2Data then
							if InsaneStats:IsDebugLevel(1) then
								InsaneStats:Log("Loaded data for %s:", steamID)
								PrintTable(plyWPASS2Data)
							end
							
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
								local batteryXP = plyWPASS2Data.modifiers.battery.xp
								ply:InsaneStats_SetBatteryXP(batteryXP or ply:InsaneStats_GetBatteryXP())
								
								if ply:InsaneStats_GetBatteryXP() == "inf" then
									ply:InsaneStats_SetBatteryXP(math.huge)
								end
								
								ApplyWPASS2Tier(ply)
								InsaneStats:ApplyWPASS2Attributes(ply)
								ply.insaneStats_ModifierChangeReason = 2
								ply:InsaneStats_MarkForUpdate(72)
							end
							
							if plyWPASS2Data.healthArmorAndSuitStats then
								if plyWPASS2Data.healthArmorAndSuitStats.health then
									ply:SetHealth(plyWPASS2Data.healthArmorAndSuitStats.health)
								end
								if plyWPASS2Data.healthArmorAndSuitStats.armor then
									ply:SetArmor(plyWPASS2Data.healthArmorAndSuitStats.armor)
								end
								if (plyWPASS2Data.healthArmorAndSuitStats.maxHealth or 0) > 0 then
									ply:SetMaxHealth(plyWPASS2Data.healthArmorAndSuitStats.maxHealth)
								end
								if (plyWPASS2Data.healthArmorAndSuitStats.maxArmor or 0) > 0 then
									ply:SetMaxArmor(plyWPASS2Data.healthArmorAndSuitStats.maxArmor)
								end
								
								if ply:IsSuitEquipped() ~= plyWPASS2Data.healthArmorAndSuitStats.suit then
									if plyWPASS2Data.healthArmorAndSuitStats.suit or ply:InsaneStats_GetEntityData("do_not_strip_suit") then
										ply:EquipSuit()
									else
										ply:RemoveSuit()
									end
								end
							end
						end
					else
						InsaneStats:Log("Failed to load data for player %s!", tostring(ply))
					end
				end)
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
							victim.insaneStats_StartTier = nil
							victim.insaneStats_Modifiers = {}
							victim:InsaneStats_SetEntityData("battery_xp", nil)
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
						victim.insaneStats_StartTier = nil
						victim.insaneStats_Modifiers = {}
						victim:InsaneStats_SetEntityData("battery_xp", nil)
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
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		timer.Simple(0, function()
			if IsValid(ent) then
				local oldTier = ent.insaneStats_Tier
				ApplyWPASS2Tier(ent)
				if ent.insaneStats_Tier ~= oldTier then
					InsaneStats:ApplyWPASS2Modifiers(ent)
				end
			end
		end)
	end
end)

hook.Add("InsaneStatsScaleXP", "InsaneStatsWPASS2", function(data)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		local victim = data.victim
		if IsValid(victim) then
			data.xp = data.xp * victim:InsaneStats_GetAttributeValue("reverse_xp")
		end
	end
end)

hook.Add("EntityRemoved", "InsaneStatsWPASS", function(ent)
	SafeRemoveEntity(ent.insaneStats_ProxyWeapon)
end)

hook.Add("EntityTakeDamage", "InsaneStatsWPASS", function(vic, dmginfo)
	if InsaneStats:GetConVarValue("wpass2_enabled") and not vic.insaneStats_Tier then return true end
end)