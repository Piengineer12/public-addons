--[=[local ConMaxClipOverrideEnabled = CreateConVar("insanestats_adjustablemaxclip", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
[[If enabled, maximum weapon clips can be altered.]])]=]

function InsaneStats:DamageIsPreventable(dmginfo)
	return not dmginfo:IsDamageType(DMG_DISSOLVE)
	and not (dmginfo:IsDamageType(DMG_PHYSGUN) and game.GetGlobalState("super_phys_gun") == 1)
end

local ENT = FindMetaTable("Entity")
local entityClassesArmorNotSensible = {
	[CLASS_PLAYER] = true,
	[CLASS_ANTLION] = true,
	[CLASS_BARNACLE] = true,
	[CLASS_HEADCRAB] = true,
	[CLASS_STALKER] = true,
	[CLASS_ZOMBIE] = true,
	[CLASS_EARTH_FAUNA] = true,
	[CLASS_ALIEN_MONSTER] = true,
	[CLASS_ALIEN_PREY] = true,
	[CLASS_ALIEN_PREDATOR] = true,
	[CLASS_INSECT] = true
}
function ENT:InsaneStats_ArmorSensible()
	if self:IsNPC() then
		return not entityClassesArmorNotSensible[self:Classify()]
	else
		return true
	end
end

function ENT:InsaneStats_ApplyArmor()
	if (self.SetMaxArmor and self:InsaneStats_GetMaxArmor() <= 0) then
		local healthMul = 1 - InsaneStats:GetConVarValue("infhealth_armor_healthcost") / 100
		local newMaxHealth = self:InsaneStats_GetMaxHealth() * healthMul
		self:SetMaxHealth(newMaxHealth)
		self:SetHealth(self:InsaneStats_GetHealth() * healthMul)

		local startingHealth = newMaxHealth / self:InsaneStats_GetCurrentHealthAdd()
		local armorMul = InsaneStats:GetConVarValue("infhealth_armor_mul")
		local startingArmor = startingHealth * armorMul
		local armor = newMaxHealth * armorMul
		self:SetMaxArmor(armor)
		self:SetArmor(armor)

		if armor == math.huge or startingArmor == 0 then
			self:InsaneStats_SetCurrentArmorAdd(1)
		else
			self:InsaneStats_SetCurrentArmorAdd(armor / startingArmor)
		end
	end
end

-- due to info_target_*crash entities, we can't apply non-standard knockback lest we break map logic
-- there's also a few entities that behave very strangely to knockback
-- we won't apply this knockback for scripted entities, those are up to the addon developers
local doNotKnockbackClasses = {
	npc_combinegunship = true,
	npc_helicopter = true,
	prop_physics = true,
	npc_sniper = true,
	prop_door_rotating = true
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

			if InsaneStats:IsDebugLevel(4) and InsaneStats:GetConVarValue("infhealth_enabled") then
				InsaneStats:Log(
					"PreHookDamage: entity = %s, damage = %s, raw = %g, health = %i",
					tostring(vic), tostring(InsaneStats:GetDamage()), dmginfo:InsaneStats_GetRawDamage() or dmginfo:GetDamage(),
					vic:InsaneStats_GetRawHealth() or vic:Health()
				)
			end
		end, -1)
		hook.Add("EntityTakeDamage", "InsaneStatsUnlimitedHealth", hookTable.EntityTakeDamage.InsaneStatsUnlimitedHealth, 1)
		hook.Add("PostEntityTakeDamage", "InsaneStatsUnlimitedHealth", hookTable.PostEntityTakeDamage.InsaneStatsUnlimitedHealth, -1)
	end
end)

local totalDamageTicks = 0
hook.Add("Think", "InsaneStatsUnlimitedHealth", function()
	totalDamageTicks = 0
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
						k:SetArmor(math.Clamp(k:InsaneStats_GetArmor() + armorToAdd, 0, k:GetMaxArmor()))
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
	totalDamageTicks = totalDamageTicks + 1
	if totalDamageTicks > 1000 then
		print("Something caused an infinite loop!")
		debug.Trace()
		return true
	end

	if not dLibbed then
		InsaneStats:SetDamage(nil)

		if InsaneStats:IsDebugLevel(4) and InsaneStats:GetConVarValue("infhealth_enabled") then
			InsaneStats:Log(
				"PreHookDamage: entity = %s, damage = %s, raw = %g, health = %i",
				tostring(vic), tostring(InsaneStats:GetDamage()), dmginfo:InsaneStats_GetRawDamage() or dmginfo:GetDamage(),
				vic:InsaneStats_GetRawHealth() or vic:Health()
			)
		end
	end
	
	-- run the others first
	local shouldNegate = hook.Run("NonInsaneStatsEntityTakeDamage", vic, dmginfo, ...)
	if shouldNegate then
		return shouldNegate
	end

	if InsaneStats:IsDebugLevel(4) and InsaneStats:GetConVarValue("infhealth_enabled") then
		InsaneStats:Log(
			"PostHookDamage: entity = %s, damage = %g, raw = %g, health = %i",
			tostring(vic), InsaneStats:GetDamage() or -1, dmginfo:InsaneStats_GetRawDamage() or dmginfo:GetDamage(),
			vic:InsaneStats_GetRawHealth() or vic:Health()
		)
	end
	
	vic.insaneStats_LastDamageTaken = CurTime()
	vic.insaneStats_OldRawHealth = vic.InsaneStats_GetRawHealth and vic:InsaneStats_GetRawHealth() or vic:Health()
	vic.insaneStats_CurrentRawDamage = dmginfo:GetDamage()
	InsaneStats:SetAbsorbedDamage(0)
	
	if not vic:IsVehicle() then
		local inflictor = dmginfo:GetInflictor()
		local attacker = dmginfo:GetAttacker()
		local multiplier = InsaneStats:DetermineDamageMul(vic, dmginfo)
		dmginfo:ScaleDamage(multiplier)
		
		if InsaneStats:GetConVarValue("infhealth_enabled") then
			local helibomberCondition = IsValid(inflictor) and inflictor:GetClass() == "grenade_helicopter"
				and IsValid(attacker) and attacker:GetClass() ~= "npc_helicopter"
			if helibomberCondition then
				dmginfo:ScaleDamage(1 + attacker:InsaneStats_GetStatusEffectLevel("helibomber") / 100)
			end

			-- if armor is present and the entity is not a player, reduce raw damage
			local armor = vic:InsaneStats_GetArmor()
			if armor > 0 then
				-- if entity is marked to block ALL damage with armor, use special handling
				if vic:InsaneStats_GetEntityData("armor_blocks_all") then
					local fullDamage = InsaneStats:GetDamage()
					local absorbedDamage = math.min(armor, fullDamage)
					
					InsaneStats:SetAbsorbedDamage(absorbedDamage)
					dmginfo:SubtractDamage(absorbedDamage)
				elseif not vic:IsPlayer() and bit.band(dmginfo:GetDamageType(), armorBypassingDamage) == 0 then
					local fullDamage = InsaneStats:GetDamage()
					local absorbedDamage = math.min(armor, fullDamage/1.25)
					
					InsaneStats:SetAbsorbedDamage(absorbedDamage)
					dmginfo:SubtractDamage(absorbedDamage)
				end
			end
			
			if not (InsaneStats:GetDamage() < math.huge) then
				InsaneStats:SetDamage(math.huge)
			end
			
			-- determine the ACTUAL damage to deal
			local insaneStatsHealth = math.abs(vic:InsaneStats_GetHealth())
			local rawHealth = math.abs(vic:InsaneStats_GetRawHealth())
			local damageMul = rawHealth / insaneStatsHealth
			if rawHealth == insaneStatsHealth then
				damageMul = 1
			end

			local insaneStatsDamage = InsaneStats:GetDamage()
			local rawDamage = insaneStatsDamage * damageMul
			if insaneStatsDamage == math.huge then
				rawDamage = insaneStatsDamage
			end
			if InsaneStats:IsDebugLevel(3) then
				InsaneStats:Log(
					"%g damage against %g health is actually %g damage against %g health with %g absorbed",
					insaneStatsDamage, insaneStatsHealth, rawDamage, rawHealth, InsaneStats:GetAbsorbedDamage()
				)
			end
			dmginfo:InsaneStats_SetRawDamage(rawDamage)
			
			if dmginfo:IsDamageType(DMG_POISON) and dmginfo:InsaneStats_GetRawDamage() >= vic:InsaneStats_GetRawHealth() and vic:InsaneStats_GetRawHealth() > 0 then
				-- poison damage should leave the user at 1 health, but the limitations of
				-- single floating-point arithmetic is making this more difficult than it needs to be
				--print(vic, dmginfo:InsaneStats_GetRawDamage(), vic:InsaneStats_GetRawHealth())
				local cappedDamage = vic:InsaneStats_GetRawHealth() * 16777215 / 16777216 - 1
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
			or stunned) and InsaneStats:DamageIsPreventable(dmginfo) then
				if InsaneStats:IsDebugLevel(1) then
					InsaneStats:Log("Prevented lethal damage to %s!", tostring(vic))
				end

				-- if damage exceeds health * 0.75, nerf damage received
				-- we have to do this otherwise the helicopter might remain in a dead-not-dead state
				local maxDamage = vic:InsaneStats_GetRawHealth() * 0.75
				if dmginfo:InsaneStats_GetRawDamage() > maxDamage then
					dmginfo:InsaneStats_SetRawDamage(math.max(maxDamage, 0))
					if stunned then
						vic:InsaneStats_ClearStatusEffect("stunned")
						vic:InsaneStats_ApplyStatusEffect("invincible", 1, 0.25)
					end
				end
			elseif vic.insaneStats_PreventOverdamage then
				-- make sure to not let the helicopter's health go too low since it also causes issues
				-- again, single floating-point arithmetic makes this more difficult
				local maxDamage = vic:InsaneStats_GetRawHealth() * (1 + 2 ^ -24) + 256
				if dmginfo:InsaneStats_GetRawDamage() > maxDamage then
					dmginfo:InsaneStats_SetRawDamage(math.max(maxDamage, 0))
				end
			end

			--[[if helibomberCondition then
				attacker:InsaneStats_ApplyStatusEffect("helibomber", 10, 60, {amplify = true})
			end]]
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
	elseif not (rawDamage >= -math.huge) then
		InsaneStats:SetDamage(0)
		dmginfo:InsaneStats_SetRawDamage(0)
		error("Something tried to set damage to nan!")
	elseif rawDamage == 0 then
		if InsaneStats:GetAbsorbedDamage() > 0 then
			vic:SetArmor(math.max(vic:InsaneStats_GetArmor() - InsaneStats:GetAbsorbedDamage(), 0))
		end

		vic:InsaneStats_DamageNumber(
			attacker,
			InsaneStats:GetDamage() + InsaneStats:GetAbsorbedDamage(),
			dmginfo:GetDamageType(),
			vic.insaneStats_LastHitGroup,
			vic:InsaneStats_GetHealth() > 0
		)
		-- negate the damage entirely because for some yet unknown reason
		-- taking 0 damage at high amounts of health causes an instant death
		return true
	end

	-- important for next part
	vic:InsaneStats_SetEntityData("health", vic:InsaneStats_GetHealth())
	vic:InsaneStats_SetEntityData("armor", vic:InsaneStats_GetArmor())
	vic:InsaneStats_SetEntityData("old_velocity", vic:GetVelocity())

	if InsaneStats:IsDebugLevel(4) then
		InsaneStats:Log(
			"PreEntityTakeDamage: entity = %s, damage = %g, raw = %g, health = %i",
			tostring(vic), InsaneStats:GetDamage(), rawDamage, rawHealth
		)
	end
end)

hook.Add("PostEntityTakeDamage", "InsaneStatsUnlimitedHealth", function(vic, dmginfo, notImmune, ...)
	totalDamageTicks = totalDamageTicks + 1
	if totalDamageTicks > 1000 then
		print("Something caused an infinite loop!")
		debug.Trace()
		return true
	end
	
	if InsaneStats:IsDebugLevel(4) and InsaneStats:GetConVarValue("infhealth_enabled") then
		InsaneStats:Log(
			"PostEntityTakeDamage: entity = %s, damage = %g, raw = %g, health = %i",
			tostring(vic), InsaneStats:GetDamage() or -1, dmginfo:InsaneStats_GetRawDamage(), vic:InsaneStats_GetRawHealth()
		)
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
		local wasHealthyWhenDamaged = vic:InsaneStats_GetHealth() > 0
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
			if not (armorDamage < math.huge and newArmor > 0) then
				newArmor = 0
			end
			
			--print(newHealth, newArmor)
			--print(vic, dmginfo:GetDamage(), vic:InsaneStats_GetRawHealth(), vic:InsaneStats_GetHealth())
			vic:SetHealth(newHealth)
			vic:SetArmor(math.max(newArmor, 0))
		end
		
		if not notImmune and rawHealthDamage == 0 and armorDamage == 0 then
			reportedDamage = 0
		end
		--print(vic, dmginfo:GetDamage(), vic:InsaneStats_GetRawHealth(), vic:InsaneStats_GetHealth())
		vic:InsaneStats_DamageNumber(dmginfo:GetAttacker(), reportedDamage, dmginfo:GetDamageType(), vic.insaneStats_LastHitGroup, wasHealthyWhenDamaged)
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
	npc_combinegunship = true,
	prop_dropship_container = true
}
hook.Add("InsaneStatsEntityCreated", "InsaneStatsUnlimitedHealth", function(ent)
	entities[ent] = true
	
	local class = ent:GetClass()
	if InsaneStats:GetConVarValue("infhealth_enabled") then
		if (ent:IsNPC() or ent:IsNextBot())
		and math.random() * 100 < InsaneStats:GetConVarValue("infhealth_armor_chance")
		and (not InsaneStats:GetConVarValue("infhealth_armor_sensible") or ent:InsaneStats_ArmorSensible()) then
			ent:InsaneStats_ApplyArmor()
		end

		ent.insaneStats_PreventOverdamage = ent.insaneStats_PreventOverdamage or multipleDamageClasses[class]

		--timer.Simple(0, function()
			--if IsValid(ent) then
				if ent.insaneStats_TempOnHalfHealth or class == "npc_helicopter" or class == "prop_dropship_container" then
					ent.insaneStats_TempOnHalfHealth = nil
					local duration = class == "prop_dropship_container" and 100 or class == "npc_helicopter" and 1 or 10
					ent:InsaneStats_ApplyStatusEffect("pheonix", duration, math.huge)
					ent:Fire("AddOutput", "OnHalfHealth !self:InsaneStats_OnHalfHealth")
				end
				if ent.insaneStats_TempOnDamaged or ent.insaneStats_TempOnStun then
					local times = 1
					if ent.insaneStats_TempOnStun or multipleDamageClasses[class]
					and (ent:GetInternalVariable("damagefilter") or "") == "" then
						times = 10
					end
					ent.insaneStats_TempOnDamaged = nil
					ent.insaneStats_TempOnStun = nil
					ent:InsaneStats_ApplyStatusEffect("undying", times, math.huge)
					ent:Fire("AddOutput", "OnDamaged !self:InsaneStats_OnDamaged")
					ent:Fire("AddOutput", "OnHealthChanged !self:InsaneStats_OnDamaged")
				end
			--end
		--end)
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

	local invincibility = InsaneStats:GetConVarValue("infhealth_spawn_invincibility")
	if invincibility > 0 then
		ply:InsaneStats_ApplyStatusEffect("invincible", 1, invincibility)
	end
end)

hook.Add("EntityKeyValue", "InsaneStatsUnlimitedHealth", function(ent, key, value)
	key = key:lower()
	if key == "onhalfhealth" then
		ent.insaneStats_TempOnHalfHealth = true
	elseif key == "ondamaged" or key == "onhealthchanged" then
		ent.insaneStats_TempOnDamaged = true
	elseif key == "onstunnedplayer" then
		ent.insaneStats_TempOnStun = true
	end
end)

hook.Add("AcceptInput", "InsaneStatsUnlimitedHealth", function(ent, input, activator, caller, data)
	input = input:lower()
	if input == "insanestats_onhalfhealth" then
		local developer = InsaneStats:IsDebugLevel(1)
		
		local pheonixLevel = ent:InsaneStats_GetStatusEffectLevel("pheonix")
		if pheonixLevel > 0 then
			if developer then
				InsaneStats:Log("Applying invincibility to %s!", tostring(ent))
			end
			ent:InsaneStats_ApplyStatusEffect("invincible", 1, pheonixLevel)
			ent:InsaneStats_ClearStatusEffect("pheonix")
		end

		ent.insaneStats_HitAtHalfHealth = (ent.insaneStats_HitAtHalfHealth or 0) + 1
		if developer then
			InsaneStats:Log(
				"%s was hit at half health %i time(s)!",
				tostring(ent), ent.insaneStats_HitAtHalfHealth
			)
		end

		timer.Simple(1, function()
			if IsValid(ent) and not ent.insaneStats_NoOSP then
				if ent:InsaneStats_GetHealth() / ent:InsaneStats_GetMaxHealth() > 0.9375 then
					ent.insaneStats_HitAtHalfHealth = 0
					if developer then
						InsaneStats:Log("%s is no longer hit at half health!", tostring(ent))
					end

					ent:InsaneStats_ApplyStatusEffect("pheonix", pheonixLevel, math.huge)
				end
			end
		end)

		return true
	elseif input == "insanestats_ondamaged" then
		local undyingLevel = ent:InsaneStats_GetStatusEffectLevel("undying")

		if undyingLevel > 0 and ent:InsaneStats_GetStatusEffectLevel("invincible") <= 0 then
			local duration = ent:InsaneStats_GetStatusEffectDuration("undying")

			timer.Simple(0, function()
				if IsValid(ent) then
					if InsaneStats:IsDebugLevel(1) then
						InsaneStats:Log("Applying invincibility to %s!", tostring(ent))
					end
					ent:InsaneStats_ApplyStatusEffect("invincible", 1, 1)

					local newUndyingLevel = undyingLevel - 1
	
					ent:InsaneStats_ClearStatusEffect("undying")
	
					if newUndyingLevel > 0 then
						ent:InsaneStats_ApplyStatusEffect(
							"undying",
							newUndyingLevel,
							duration
						)
					end
				end
			end)

			--[[timer.Simple(1, function()
				if IsValid(ent) and not ent.insaneStats_NoOSP then
					if ent:InsaneStats_GetHealth() / ent:InsaneStats_GetMaxHealth() > 0.9375 then
						ent:InsaneStats_ApplyStatusEffect("undying", undyingLevel, duration)
					end
				end
			end)]]
		end
		
		return true
	elseif input == "selfdestruct" then
		ent:InsaneStats_ClearStatusEffect("pheonix")
		ent:InsaneStats_ClearStatusEffect("undying")
		ent.insaneStats_NoOSP = true
	end
end)
