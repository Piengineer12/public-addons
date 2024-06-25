--[=[local ConMaxClipOverrideEnabled = CreateConVar("insanestats_adjustablemaxclip", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
[[If enabled, maximum weapon clips can be altered.]])]=]

local ENT = FindMetaTable("Entity")
local entityClassesArmorNotSensible = {
	[CLASS_PLAYER] = true,
	[CLASS_ANTLION] = true,
	[CLASS_BARNACLE] = true,
	[CLASS_HEADCRAB] = true,
	[CLASS_ZOMBIE] = true,
	[CLASS_MISSILE] = true,
	[CLASS_FLARE] = true,
	[CLASS_EARTH_FAUNA] = true,
	[CLASS_ALIEN_MONSTER] = true,
	[CLASS_ALIEN_PREY] = true,
	[CLASS_ALIEN_PREDATOR] = true,
	[CLASS_INSECT] = true,
	[CLASS_PLAYER_BIOWEAPON] = true,
	[CLASS_ALIEN_BIOWEAPON] = true
}
function ENT:InsaneStats_ArmorSensible()
	if self:IsNPC() then
		return not entityClassesArmorNotSensible[self:Classify()]
	else
		return true
	end
end

-- due to info_target_*crash entities, we can't apply non-standard knockback lest we break map logic
-- there's also a few entities that behave very strangely to knockback
-- we won't apply this knockback for scripted entities, those are up to the addon developers
local doNotKnockbackClasses = {
	npc_combinegunship = true,
	npc_helicopter = true,
	prop_physics = true,
	npc_sniper = true
}
function ENT:InsaneStats_ApplyKnockback(knockback, additionalVelocity)
	if IsValid(self:GetPhysicsObject()) and not doNotKnockbackClasses[self:GetClass()]
	and not self:IsScripted() and InsaneStats:GetConVarValue("infhealth_knockback") then
		local reductionFactor = self:GetPhysicsObject():GetMass()
		local originalKnockback = knockback
		knockback = knockback / reductionFactor

		local originalVelocity = self:IsPlayer() and vector_origin or self:GetVelocity()
		if additionalVelocity then
			originalVelocity = originalVelocity + additionalVelocity
		end

		-- if we already have a very high amount of velocity in the direction of the knockback, reduce the knockback taken
		reductionFactor = 1 + (originalVelocity:Dot(knockback) / knockback:LengthSqr())
		knockback:Div(reductionFactor)

		local newVelocity = originalVelocity + knockback
		
		self:SetVelocity(newVelocity)
	end
end

local dLibbed = false
local entities = {}
for k,v in pairs(ents.GetAll()) do
	entities[v] = true
end
timer.Create("InsaneStatsUnlimitedHealth", 0.5, 0, function()
	local i = 1
	for k,v in pairs(entities) do
		if not (IsValid(k) and k:InsaneStats_GetHealth() > 0 and (k:GetModel() or "") ~= "") then
			entities[k] = nil
		end
	end
	
	if not DLib then
		local hookTable = hook.GetTable()
		local etdHooks = hookTable.EntityTakeDamage
		local nisetdHooks = hookTable.NonInsaneStatsEntityTakeDamage
		local petdHooks = hookTable.PostEntityTakeDamage
		local nispetdHooks = hookTable.NonInsaneStatsPostEntityTakeDamage
		local doHealthOverride = InsaneStats:GetConVarValue("infhealth_enabled")
		
		if etdHooks and doHealthOverride then
			for k,v in pairs(etdHooks) do
				if tostring(InsaneStats.NOP) ~= tostring(v) and k ~= "InsaneStatsUnlimitedHealth" and isstring(k) then
					hook.Add("NonInsaneStatsEntityTakeDamage", k, v)
					hook.Add("EntityTakeDamage", k, InsaneStats.NOP)
				end
			end
		end
		
		if nisetdHooks then
			for k,v in pairs(nisetdHooks) do
				if not etdHooks[k] then -- it's gone!
					hook.Remove("NonInsaneStatsEntityTakeDamage", k)
				elseif not doHealthOverride then -- put it back!
					hook.Add("EntityTakeDamage", k, v)
					hook.Remove("NonInsaneStatsEntityTakeDamage", k)
				end
			end
		end
		
		if petdHooks and doHealthOverride then
			for k,v in pairs(petdHooks) do
				if tostring(InsaneStats.NOP) ~= tostring(v) and k ~= "InsaneStatsUnlimitedHealth" then
					hook.Add("NonInsaneStatsPostEntityTakeDamage", k, v)
					hook.Add("PostEntityTakeDamage", k, InsaneStats.NOP)
				end
			end
		end
		
		if nispetdHooks then
			for k,v in pairs(nispetdHooks) do
				if not petdHooks[k] then -- it's gone!
					hook.Remove("NonInsaneStatsPostEntityTakeDamage", k)
				elseif not doHealthOverride then -- put it back!
					hook.Add("EntityTakeDamage", k, v)
					hook.Remove("NonInsaneStatsPostEntityTakeDamage", k)
				end
			end
		end
	elseif not dLibbed and hook.GetTable().EntityTakeDamage.InsaneStatsUnlimitedHealth then
		-- turn the hook overrides off and just use DLib's integrated stuff
		dLibbed = true
		local hookTable = hook.GetTable()
		local nisetdHooks = hookTable.NonInsaneStatsEntityTakeDamage
		local nispetdHooks = hookTable.NonInsaneStatsPostEntityTakeDamage
		
		if nisetdHooks then
			for k,v in pairs(nisetdHooks) do
				-- put it back!
				hook.Add("EntityTakeDamage", k, v)
				hook.Remove("NonInsaneStatsEntityTakeDamage", k)
			end
		end
		
		if nispetdHooks then
			for k,v in pairs(nispetdHooks) do
				-- put it back!
				hook.Add("PostEntityTakeDamage", k, v)
				hook.Remove("NonInsaneStatsPostEntityTakeDamage", k)
			end
		end
		
		hook.Add("EntityTakeDamage", "InsaneStatsUnlimitedHealthPre", function(vic, dmginfo, ...)
			InsaneStats:SetDamage(nil)
		end, -1)
		hook.Add("EntityTakeDamage", "InsaneStatsUnlimitedHealth", hookTable.EntityTakeDamage.InsaneStatsUnlimitedHealth, 1)
		hook.Add("PostEntityTakeDamage", "InsaneStatsUnlimitedHealth", hookTable.PostEntityTakeDamage.InsaneStatsUnlimitedHealth, -1)
	end
end)

hook.Add("Think", "InsaneStatsUnlimitedHealth", function()
	if InsaneStats:GetConVarValue("infhealth_enabled") and CurTime() > 5 then
		for k,v in pairs(entities) do
			if IsValid(k) then
				if k.InsaneStats_GetRawHealth then
					k.insaneStats_OldRawHealth = k.insaneStats_OldRawHealth or k:InsaneStats_GetRawHealth()
					
					if k.insaneStats_OldRawHealth ~= k:InsaneStats_GetRawHealth() then
						local difference = k:InsaneStats_GetRawHealth() - k.insaneStats_OldRawHealth
						--print(difference)
						if difference < 0 and k:IsOnFire() then -- getting set on fire resets the entity's health. Valve, pls fix.
							difference = 0
						end
						
						difference = difference * k:InsaneStats_GetCurrentHealthAdd()
						
						k:SetHealth(k:InsaneStats_GetHealth() + difference)
					end
					
					if k:GetMaxArmor() > 0
					and k:InsaneStats_GetArmor() < k:GetMaxArmor()
					and not k:IsPlayer()
					and (k.insaneStats_LastDamageTaken or 0) + InsaneStats:GetConVarValue("infhealth_armor_regen_delay") <= CurTime() then
						local armorToAdd = k:GetMaxArmor() * InsaneStats:GetConVarValue("infhealth_armor_regen") / 100 * FrameTime()
						--print(k:InsaneStats_GetArmor(), armorToAdd, k:InsaneStats_GetArmor() + armorToAdd)
						k:SetArmor(math.min(k:InsaneStats_GetArmor() + armorToAdd, k:GetMaxArmor()))
					end
				end
				
				if k.InsaneStats_GetRawArmor then
					k.insaneStats_OldRawArmor = k.insaneStats_OldRawArmor or k:InsaneStats_GetRawArmor()
					if k.insaneStats_OldRawArmor ~= k:InsaneStats_GetRawArmor() then
						local difference = k:InsaneStats_GetRawArmor() - k.insaneStats_OldRawArmor
						difference = difference * k:InsaneStats_GetCurrentArmorAdd()
						k:SetArmor(k:InsaneStats_GetArmor() + difference)
					end
				end
			end
		end
	end
end)

AccessorFunc(InsaneStats, "currentAbsorbedDamage", "AbsorbedDamage")

local armorBypassingDamage = bit.bor(DMG_FALL, DMG_DROWN, DMG_POISON, DMG_RADIATION)
hook.Add("EntityTakeDamage", "InsaneStatsUnlimitedHealth", function(vic, dmginfo, ...)
	local developer = GetConVar("developer"):GetInt() > 0
	local richDeveloper = GetConVar("developer"):GetInt() > 1
	if not dLibbed then
		InsaneStats:SetDamage(nil)
	end
	
	-- run the others first
	local shouldNegate = hook.Run("NonInsaneStatsEntityTakeDamage", vic, dmginfo, ...)
	if shouldNegate then return shouldNegate end
	
	vic.insaneStats_LastDamageTaken = CurTime()
	vic.insaneStats_OldRawHealth = vic.InsaneStats_GetRawHealth and vic:InsaneStats_GetRawHealth() or vic:Health()
	vic.insaneStats_CurrentRawDamage = dmginfo:GetDamage()
	InsaneStats:SetAbsorbedDamage(0)
	
	if not vic:IsVehicle() then
		local multiplier = InsaneStats:DetermineDamageMul(vic, dmginfo)
		dmginfo:ScaleDamage(multiplier)
		--print(InsaneStats:GetDamage())
		
		if InsaneStats:GetConVarValue("infhealth_enabled") then
			-- if armor is present and the entity is not a player, reduce raw damage
			local armor = vic:InsaneStats_GetArmor()
			if armor > 0 then
				-- if entity is marked to block ALL damage with armor, use special handling
				if vic:InsaneStats_GetEntityData("armor_blocks_all") then
					local fullDamage = InsaneStats:GetDamage()
					local absorbedDamage = math.min(armor, fullDamage)
					--[[local newArmor = math.max(armor - fullDamage, 0)
					vic:SetArmor(newArmor)
					vic:InsaneStats_DamageNumber(dmginfo:GetAttacker(), absorbedDamage, dmginfo:GetDamageType(), vic.insaneStats_LastHitGroup)]]
					
					InsaneStats:SetAbsorbedDamage(absorbedDamage)
					dmginfo:SubtractDamage(absorbedDamage)
					
					--[[if newArmor == 0 then
						multiplier = multiplier * (fullDamage - absorbedDamage) / fullDamage
					else
						dmginfo:ScaleDamage(multiplier)
						hook.Run("PostEntityTakeDamage", vic, dmginfo, false)
						vic:InsaneStats_ApplyKnockback(dmginfo:GetDamageForce())
						return true
					end]]
				elseif not vic:IsPlayer() and bit.band(dmginfo:GetDamageType(), armorBypassingDamage) == 0 then
					local fullDamage = InsaneStats:GetDamage()
					local absorbedDamage = math.min(armor, fullDamage/1.25)
					
					InsaneStats:SetAbsorbedDamage(absorbedDamage)
					dmginfo:SubtractDamage(absorbedDamage)
					
					--[[if fullDamage ~= 0 then
						multiplier = multiplier * (fullDamage - absorbedDamage) / fullDamage
					end]]
				end
			end
			
			if not (InsaneStats:GetDamage() < math.huge) then
				InsaneStats:SetDamage(math.huge)
			end
			
			-- determine the ACTUAL damage to deal
			if vic:InsaneStats_GetHealth() ~= 0 then
				dmginfo:InsaneStats_SetRawDamage(InsaneStats:GetDamage() * math.abs(vic:InsaneStats_GetRawHealth()) / math.abs(vic:InsaneStats_GetHealth()))
			end
			
			if InsaneStats:GetConVarValue("infhealth_enabled") then
				if dmginfo:IsDamageType(DMG_POISON) and dmginfo:InsaneStats_GetRawDamage() >= vic:InsaneStats_GetRawHealth() and vic:InsaneStats_GetRawHealth() > 0 then
					-- poison damage should leave the user at 1 health, but the limitations of
					-- single floating-point arithmetic is making this more difficult than it needs to be
					--print(vic, dmginfo:InsaneStats_GetRawDamage(), vic:InsaneStats_GetRawHealth())
					local cappedDamage = vic:InsaneStats_GetRawHealth() * 33554431 / 33554432 - 1
					dmginfo:InsaneStats_SetRawDamage(cappedDamage)
					dmginfo:SetMaxDamage(cappedDamage)
					--print(cappedDamage)
					--vic:InsaneStats_SetRawHealth(dmginfo:InsaneStats_GetRawDamage() + 1)
					--print(vic, dmginfo:InsaneStats_GetRawDamage(), vic:InsaneStats_GetRawHealth())
				end
				
				local stunned = vic:InsaneStats_GetStatusEffectLevel("stunned") > 0
				local healthRatio = vic:InsaneStats_GetHealth() / vic:InsaneStats_GetMaxHealth()
				if (vic:InsaneStats_GetStatusEffectLevel("pheonix") > 0
				or vic:InsaneStats_GetStatusEffectLevel("undying") > 0
				or stunned) and not dmginfo:IsDamageType(DMG_DISSOLVE) then
					if developer then
						InsaneStats:Log("Prevented lethal damage to "..tostring(vic).."!")
					end

					-- if damage exceeds health * 0.75, nerf damage received
					-- we have to do this otherwise the helicopter might remain in a dead-not-dead state
					local maxDamage = vic:InsaneStats_GetRawHealth() * 0.75
					if dmginfo:InsaneStats_GetRawDamage() > maxDamage then
						dmginfo:InsaneStats_SetRawDamage(maxDamage)
						if stunned then
							vic:InsaneStats_ClearStatusEffect("stunned")
							vic:InsaneStats_ApplyStatusEffect("invincible", 1, 0.25)
						end
					end
				elseif vic.insaneStats_PreventOverdamage then
					-- make sure to not let the helicopter's health go too low since it also causes issues
					-- again, single floating-point arithmetic makes this more difficult
					local maxDamage = vic:InsaneStats_GetRawHealth() * (1 + 2 ^ -24)
					if dmginfo:InsaneStats_GetRawDamage() > maxDamage then
						dmginfo:InsaneStats_SetRawDamage(maxDamage)
					end
				end
			end
		end
	end

	local rawDamage = InsaneStats:GetConVarValue("infhealth_enabled")
		and dmginfo:InsaneStats_GetRawDamage()
		or dmginfo:GetDamage()
	local rawHealth = InsaneStats:GetConVarValue("infhealth_enabled")
		and vic:InsaneStats_GetRawHealth()
		or vic:Health()
	if rawDamage >= rawHealth then
		local ret = hook.Run("InsaneStatsPreDeath", vic, dmginfo)
		if ret then return ret end
	end

	-- important for next part
	vic:InsaneStats_SetEntityData("health", vic:InsaneStats_GetHealth())
	vic:InsaneStats_SetEntityData("armor", vic:InsaneStats_GetArmor())
	vic:InsaneStats_SetEntityData("old_velocity", vic:GetVelocity())

	if richDeveloper then
		local attacker = dmginfo:GetAttacker()
		if attacker:IsPlayer() then
			InsaneStats:Log(
				string.format(
					"PreEntityTakeDamage: entity = %s, damage = %i, health = %i",
					tostring(vic), rawDamage, rawHealth
				)
			)
		end
	end
end)

hook.Add("PostEntityTakeDamage", "InsaneStatsUnlimitedHealth", function(vic, dmginfo, notImmune, ...)
	local richDeveloper = GetConVar("developer"):GetInt() > 1
	if richDeveloper and InsaneStats:GetConVarValue("infhealth_enabled") then
		local attacker = dmginfo:GetAttacker()
		if attacker:IsPlayer() then
			InsaneStats:Log(
				string.format(
					"PostEntityTakeDamage: entity = %s, damage = %i, health = %i",
					tostring(vic), dmginfo:InsaneStats_GetRawDamage(), vic:InsaneStats_GetRawHealth()
				)
			)
		end
	end

	vic:InsaneStats_SetEntityData("old_velocity", vic:InsaneStats_GetEntityData("old_velocity") or vic:GetVelocity())
	if not dmginfo:IsDamageType(armorBypassingDamage) then
		vic:InsaneStats_ApplyKnockback(
			dmginfo:GetDamageForce(),
			vic:InsaneStats_GetEntityData("old_velocity") - vic:GetVelocity()
		)
	end
	
	if not vic:IsVehicle() then
		local reportedDamage = dmginfo:GetDamage()
		local rawHealthDamage = vic.insaneStats_OldRawHealth and vic.insaneStats_OldRawHealth - (vic.InsaneStats_GetRawHealth and vic:InsaneStats_GetRawHealth() or vic:Health()) or 0
		local rawArmorDamage = vic.InsaneStats_GetRawArmor and vic.insaneStats_OldRawArmor - vic:InsaneStats_GetRawArmor() or 0
		
		--print(vic, dmginfo:GetDamageForce(), vic:InsaneStats_GetEntityData("old_velocity"), vic:GetVelocity())
		
		--print(reportedDamage)
		-- notImmune is set to false when damage == 0, even if vic:InsaneStats_GetEntityData("armor_blocks_all") is present
		if (notImmune or rawHealthDamage ~= 0 or vic:InsaneStats_GetEntityData("armor_blocks_all")) and vic:GetClass() ~= "npc_turret_floor" and InsaneStats:GetConVarValue("infhealth_enabled") then
			local healthDamage = dmginfo:GetDamage()
			local armorDamage = InsaneStats:GetAbsorbedDamage() or 0
			
			--print(armorDamage)
			
			if healthDamage == 0 and armorDamage == 0 then -- calculate damage from total HP
				healthDamage = rawHealthDamage
				
				-- reverse damage nerf, noting that the raw health may be 0
				if vic.insaneStats_OldRawHealth ~= 0 then
					local antiNerf = vic:InsaneStats_GetHealth() / vic.insaneStats_OldRawHealth
					healthDamage = healthDamage * antiNerf
				end
			end
			
			--print(healthDamage, armorDamage)
			if vic:InsaneStats_GetArmor() > 0 then -- it gets complicated
				if vic:IsPlayer() and armorDamage == 0 then
					armorDamage = math.min(vic:InsaneStats_GetArmor(), healthDamage/1.25)
					healthDamage = healthDamage - armorDamage
				--[[elseif bit.band(dmginfo:GetDamageType(), armorBypassingDamage) == 0 then
					armorDamage = math.min(vic:InsaneStats_GetArmor(), healthDamage*4)]]
				end
			end
			
			--print(vic, antiNerf, vic:InsaneStats_GetHealth(), vic.insaneStats_OldRawHealth)
			--print(vic, reportedDamage, healthDamage, armorDamage)
			reportedDamage = healthDamage + armorDamage
			
			local newHealth = vic:InsaneStats_GetHealth() - healthDamage
			local newArmor = vic:InsaneStats_GetArmor() - armorDamage
			
			--print(healthDamage, armorDamage)
			if (vic.InsaneStats_GetRawHealth and (newHealth > 0) ~= (vic:InsaneStats_GetRawHealth() > 0)) then
				-- something ain't holding up...
				if vic:InsaneStats_GetRawHealth() < 0 then -- they are already dead!
					newHealth = 0
				elseif dmginfo:IsDamageType(DMG_POISON) then -- set health to RawHealth
					newHealth = vic:InsaneStats_GetRawHealth()
				else -- scale down our damage to be x/(x+y) or health*0.75, whichever is higher
					newHealth = vic:InsaneStats_GetHealth() * math.max(
						1 - healthDamage / (healthDamage + vic:InsaneStats_GetHealth()),
						0.25
					)
				end
			end
			
			-- beware of the nans!
			if not (healthDamage < math.huge and newHealth > -math.huge) then
				newHealth = -math.huge
			end
			if not (armorDamage < math.huge and newArmor > -math.huge) then
				newArmor = -math.huge
			end
			
			--print(newHealth, newArmor)
			--print(vic, dmginfo:GetDamage(), vic:InsaneStats_GetRawHealth(), vic:InsaneStats_GetHealth())
			vic:SetHealth(newHealth)
			vic:SetArmor(newArmor)
		end
		
		if not notImmune and rawHealthDamage == 0 and armorDamage == 0 then
			reportedDamage = 0
		end
		--print(vic, dmginfo:GetDamage(), vic:InsaneStats_GetRawHealth(), vic:InsaneStats_GetHealth())
		vic:InsaneStats_DamageNumber(dmginfo:GetAttacker(), reportedDamage, dmginfo:GetDamageType(), vic.insaneStats_LastHitGroup)
	end
	
	if vic.insaneStats_CurrentRawDamage and dmginfo.InsaneStats_SetRawDamage then
		dmginfo:InsaneStats_SetRawDamage(vic.insaneStats_CurrentRawDamage)
	end
	
	InsaneStats:SetDamage(nil)
	hook.Run("NonInsaneStatsPostEntityTakeDamage", vic, dmginfo, notImmune, ...)
end)

local multipleDamageClasses = {
	npc_antlionguard = true,
	npc_helicopter = true,
	npc_strider = true,
	npc_hunter = true,
	npc_combinegunship = true
}
hook.Add("InsaneStatsEntityCreated", "InsaneStatsUnlimitedHealth", function(ent)
	entities[ent] = true
	
	local class = ent:GetClass()
	if InsaneStats:GetConVarValue("infhealth_enabled") then
		if (ent:IsNPC() or ent:IsNextBot())
		and math.random() * 100 < InsaneStats:GetConVarValue("infhealth_armor_chance")
		and (ent:InsaneStats_GetMaxArmor() <= 0)
		and (not InsaneStats:GetConVarValue("infhealth_armor_sensible") or ent:InsaneStats_ArmorSensible()) then
			local startingHealth = ent:InsaneStats_GetMaxHealth() / ent:InsaneStats_GetCurrentHealthAdd()
			local startingArmor = startingHealth * InsaneStats:GetConVarValue("infhealth_armor_mul")
			ent:SetMaxArmor(ent:InsaneStats_GetMaxHealth() * InsaneStats:GetConVarValue("infhealth_armor_mul"))
			ent:InsaneStats_SetCurrentArmorAdd(ent:InsaneStats_GetMaxArmor() / startingArmor)
			ent:SetArmor(ent:InsaneStats_GetMaxArmor())
		end

		timer.Simple(0, function()
			if IsValid(ent) then
				if ent.insaneStats_TempOnHalfHealth then
					ent.insaneStats_TempOnHalfHealth = nil
					ent:InsaneStats_ApplyStatusEffect("pheonix", 10, math.huge)
					ent:Fire("AddOutput", "OnHalfHealth !self:InsaneStats_OnHalfHealth")
				elseif class == "npc_helicopter" then
					ent.insaneStats_TempOnHalfHealth = nil
					ent:InsaneStats_ApplyStatusEffect("pheonix", 1, math.huge)
					ent:Fire("AddOutput", "OnHalfHealth !self:InsaneStats_OnHalfHealth")
				end
				if ent.insaneStats_TempOnDamaged then
					ent.insaneStats_TempOnDamaged = nil
					if multipleDamageClasses[class] then
						ent:InsaneStats_ApplyStatusEffect("undying", 10, math.huge)
						ent:Fire("AddOutput", "OnDamaged !self:InsaneStats_OnDamaged")
					end
				end
			end
		end)
	end
	
	if not ent.insaneStats_SpawnModified then
		ent.insaneStats_SpawnModified = true
		if class == "npc_strider" and InsaneStats:GetConVarValue("infhealth_enabled") then
			ent:SetHealth(ent:InsaneStats_GetHealth()*2.5)
			ent:SetMaxHealth(ent:InsaneStats_GetMaxHealth()*2.5)
		elseif class == "npc_combinegunship" and InsaneStats:GetConVarValue("infhealth_enabled") then
			ent:SetHealth(ent:InsaneStats_GetHealth()*7.5)
			ent:SetMaxHealth(ent:InsaneStats_GetMaxHealth()*7.5)
		
		--[[elseif class == "item_suitcharger" or class == "func_recharge" then
			if ent:HasSpawnFlags(8192) then
				ent:Fire("AddOutput","OutRemainingCharge !activator:InsaneStatsSuperSuitChargerPoint::0:-1")
			else
				ent:Fire("AddOutput","OutRemainingCharge !activator:InsaneStatsSuitChargerPoint::0:-1")
			end
		elseif class == "item_healthcharger" or class == "func_healthcharger" then
			ent:Fire("AddOutput","OutRemainingCharge !activator:InsaneStatsHealthChargerPoint::0:-1")]]
		end
	end
end)

hook.Add("PlayerSpawn", "InsaneStatsUnlimitedHealth", function(ply, fromTransition)
	entities[ply] = true
end)

hook.Add("EntityKeyValue", "InsaneStatsUnlimitedHealth", function(ent, key, value)
	if key == "OnHalfHealth" then
		ent.insaneStats_TempOnHalfHealth = true
	elseif key == "OnDamaged" then
		ent.insaneStats_TempOnDamaged = true
	end
end)

hook.Add("AcceptInput", "InsaneStatsUnlimitedHealth", function(ent, input, activator, caller, data)
	if input == "InsaneStats_OnHalfHealth" then
		local developer = GetConVar("developer"):GetInt() > 0
		
		local pheonixLevel = ent:InsaneStats_GetStatusEffectLevel("pheonix")
		if pheonixLevel > 0 then
			if developer then
				InsaneStats:Log("Applying invincibility to "..tostring(ent).."!")
			end
			ent:InsaneStats_ApplyStatusEffect("invincible", 1, pheonixLevel)
			ent:InsaneStats_ClearStatusEffect("pheonix")
		end

		ent.insaneStats_HitAtHalfHealth = (ent.insaneStats_HitAtHalfHealth or 0) + 1
		if developer then
			InsaneStats:Log(tostring(ent).." was hit at half health "..ent.insaneStats_HitAtHalfHealth.." time(s)!")
		end

		timer.Simple(1, function()
			if IsValid(ent) then
				if ent:InsaneStats_GetHealth() / ent:InsaneStats_GetMaxHealth() > 0.9375 then
					ent.insaneStats_HitAtHalfHealth = 0
					InsaneStats:Log(tostring(ent).." is no longer hit at half health!")

					ent:InsaneStats_ApplyStatusEffect("pheonix", pheonixLevel, math.huge)
				end
			end
		end)

		return true
	elseif input == "InsaneStats_OnDamaged" then
		local developer = GetConVar("developer"):GetInt() > 0
		local undyingLevel = ent:InsaneStats_GetStatusEffectLevel("undying")

		if undyingLevel > 0 then
			timer.Simple(0, function()
				if IsValid(ent) then
					if developer then
						InsaneStats:Log("Applying invincibility to "..tostring(ent).."!")
					end
					ent:InsaneStats_ApplyStatusEffect("invincible", 1, 1)

					undyingLevel = undyingLevel - 1
					local duration = ent:InsaneStats_GetStatusEffectDuration("undying")
	
					ent:InsaneStats_ClearStatusEffect("undying")
	
					if undyingLevel > 0 then
						ent:InsaneStats_ApplyStatusEffect(
							"undying",
							undyingLevel,
							duration
						)
					end
				end
			end)
		end
		
		return true
	end
end)
