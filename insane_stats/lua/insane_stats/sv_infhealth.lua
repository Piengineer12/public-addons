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
local doNotKnockbackClasses = {
	npc_combinegunship = true,
	npc_helicopter = true,
	prop_physics = true,
	npc_sniper = true
}
function ENT:InsaneStats_ApplyKnockback(knockback, additionalVelocity)
	if IsValid(self:GetPhysicsObject()) and not doNotKnockbackClasses[self:GetClass()] then
		local reductionFactor = self:GetPhysicsObject():GetMass()
	
		local originalVelocity = self:IsPlayer() and vector_origin or self:GetVelocity()
		if additionalVelocity then
			originalVelocity = originalVelocity + additionalVelocity
		end
		
		self:SetVelocity(originalVelocity + knockback / reductionFactor)
	end
end

local dLibbed = false
local entities = {}
timer.Create("InsaneStatsUnlimitedHealth", 0.5, 0, function()
	entities = {}
	for k,v in pairs(ents.GetAll()) do
		if v:InsaneStats_GetHealth() > 0 then
			table.insert(entities, v)
		end
	end
	
	if not DLib then
		local hookTable = hook.GetTable()
		local etdHooks = hookTable.EntityTakeDamage
		local nisetdHooks = hookTable.NonInsaneStatsEntityTakeDamage or {}
		local petdHooks = hookTable.PostEntityTakeDamage
		local nispetdHooks = hookTable.NonInsaneStatsPostEntityTakeDamage or {}
		local doHealthOverride = InsaneStats:GetConVarValue("infhealth_enabled")
		
		if etdHooks and doHealthOverride then
			for k,v in pairs(etdHooks) do
				if tostring(InsaneStats.NOP) ~= tostring(v) and k ~= "InsaneStatsUnlimitedHealth" then
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
	elseif not dLibbed then
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
	if InsaneStats:GetConVarValue("infhealth_enabled") then
		for k,v in pairs(entities) do
			if IsValid(v) and CurTime() > 5 then
				if v.InsaneStats_GetRawHealth then
					v.insaneStats_OldRawHealth = v.insaneStats_OldRawHealth or v:InsaneStats_GetRawHealth()
					
					if v.insaneStats_OldRawHealth ~= v:InsaneStats_GetRawHealth() then
						local difference = v:InsaneStats_GetRawHealth() - v.insaneStats_OldRawHealth
						--print(difference)
						if difference < 0 and v:IsOnFire() then -- getting set on fire resets the entity's health. Valve, pls fix.
							difference = 0
						end
						
						difference = difference * (v.insaneStats_CurrentHealthAdd or 1)
						
						v:SetHealth(v:InsaneStats_GetHealth() + difference)
					end
					
					if v:GetMaxArmor() > 0
					and v:InsaneStats_GetArmor() < v:GetMaxArmor()
					and not v:IsPlayer()
					and (v.insaneStats_LastDamageTaken or 0) + InsaneStats:GetConVarValue("infhealth_armor_regen_delay") <= CurTime() then
						local armorToAdd = v:GetMaxArmor() * InsaneStats:GetConVarValue("infhealth_armor_regen") / 100 * FrameTime()
						--print(v:InsaneStats_GetArmor(), armorToAdd, v:InsaneStats_GetArmor() + armorToAdd)
						v:SetArmor(math.min(v:InsaneStats_GetArmor() + armorToAdd, v:GetMaxArmor()))
					end
				end
				
				if v.InsaneStats_GetRawArmor then
					v.insaneStats_OldRawArmor = v.insaneStats_OldRawArmor or v:InsaneStats_GetRawArmor()
					if v.insaneStats_OldRawArmor ~= v:InsaneStats_GetRawArmor() then
						local difference = v:InsaneStats_GetRawArmor() - v.insaneStats_OldRawArmor
						difference = difference * (v.insaneStats_CurrentArmorAdd or 1)
						v:SetArmor(v:InsaneStats_GetArmor() + difference)
					end
				end
			end
		end
	end
end)

AccessorFunc(InsaneStats, "currentAbsorbedDamage", "AbsorbedDamage")

local armorBypassingDamage = bit.bor(DMG_FALL, DMG_DROWN, DMG_POISON, DMG_RADIATION)
hook.Add("EntityTakeDamage", "InsaneStatsUnlimitedHealth", function(vic, dmginfo, ...)
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
		
		if InsaneStats:GetConVarValue("infhealth_enabled") then
			-- if armor is present and the entity is not a player, reduce raw damage
			local armor = vic:InsaneStats_GetArmor()
			if armor > 0 then
				-- if entity is marked to block ALL damage with armor, use special handling
				if vic.insaneStats_ArmorBlocksAll then
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
				if dmginfo:IsDamageType(DMG_POISON) and dmginfo:InsaneStats_GetRawDamage() + 1 > vic:InsaneStats_GetRawHealth() and vic:InsaneStats_GetRawHealth() > 0 then
					-- poison damage should ideally leave the user at 1 health, but the limitations of
					-- single floating-point arithmetic is making this more difficult than it needs to be
					dmginfo:InsaneStats_SetRawDamage(vic:InsaneStats_GetRawHealth() * 8388607 / 8388608 - 1)
				end
				
				if vic:GetClass() == "npc_helicopter" and vic:InsaneStats_GetHealth() / vic:InsaneStats_GetMaxHealth() > 0.2 then
					-- if damage exceeds health * 0.75, nerf damage received
					-- we have to do this otherwise the helicopter might remain in a dead-not-dead state
					local maxDamage = vic:InsaneStats_GetRawHealth() * 0.75
					if dmginfo:InsaneStats_GetRawDamage() > maxDamage then
						dmginfo:InsaneStats_SetRawDamage(maxDamage)
					end
				end
			end
		end
	end
	
	-- important for next part
	vic.insaneStats_Health = vic:InsaneStats_GetHealth()
	vic.insaneStats_Armor = vic:InsaneStats_GetArmor()
	vic.insaneStats_OldVelocity = vic:GetVelocity()
	--print("PreEntityTakeDamage", vic, dmginfo:GetAttacker(), dmginfo:GetDamageType(), dmginfo:GetDamage(), vic:InsaneStats_GetRawHealth())
end)

hook.Add("PostEntityTakeDamage", "InsaneStatsUnlimitedHealth", function(vic, dmginfo, notImmune, ...)
	--print("PostEntityTakeDamage", vic, dmginfo:GetAttacker(), dmginfo:GetDamageType(), dmginfo:GetDamage(), vic:InsaneStats_GetRawHealth())
	vic.insaneStats_OldVelocity = vic.insaneStats_OldVelocity or vic:GetVelocity()
	if not dmginfo:IsDamageType(DMG_FALL) then
		vic:InsaneStats_ApplyKnockback(dmginfo:GetDamageForce(), vic.insaneStats_OldVelocity-vic:GetVelocity())
	end
	
	if not vic:IsVehicle() then
		local reportedDamage = dmginfo:GetDamage()
		local rawHealthDamage = vic.insaneStats_OldRawHealth - (vic.InsaneStats_GetRawHealth and vic:InsaneStats_GetRawHealth() or vic:Health())
		local rawArmorDamage = vic.InsaneStats_GetRawArmor and vic.insaneStats_OldRawArmor - vic:InsaneStats_GetRawArmor() or 0
		
		--print(vic, dmginfo:GetDamageForce(), vic.insaneStats_OldVelocity, vic:GetVelocity())
		
		--print(reportedDamage)
		if (notImmune or rawHealthDamage ~= 0) and vic:GetClass() ~= "npc_turret_floor" and InsaneStats:GetConVarValue("infhealth_enabled") then
			local healthDamage = dmginfo:GetDamage()
			local armorDamage = InsaneStats:GetAbsorbedDamage()
			
			--print(armorDamage)
			
			--print(healthDamage, armorDamage)
			if healthDamage == 0 then -- calculate damage from total HP
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
				else -- scale down our damage to be x/(x+y) or health*0.75, whichever is higher
					newHealth = vic:InsaneStats_GetHealth() * math.max(
						1 - healthDamage / (healthDamage + vic:InsaneStats_GetHealth()),
						0.25
					)
				end
			end
			
			-- beware of the nans!
			if not (healthDamage < math.huge) then
				newHealth = -math.huge
			end
			if not (armorDamage < math.huge) then
				newArmor = -math.huge
			end
			
			--print(healthDamage, antiNerf, newHealth)
			--print(vic, dmginfo:GetDamage(), vic:InsaneStats_GetRawHealth(), vic:InsaneStats_GetHealth())
			vic:SetHealth(newHealth)
			vic:SetArmor(newArmor)
		end
		
		if not notImmune and rawHealthDamage == 0 then
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

hook.Add("InsaneStatsEntityCreated", "InsaneStatsUnlimitedHealth", function(ent)
	if InsaneStats:GetConVarValue("infhealth_enabled") then
		--[[if ent:InsaneStats_GetHealth() == math.huge and ent.insaneStats_HealthRoot8 then
			ent.insaneStats_Health = ent.insaneStats_HealthRoot8 ^ 8
		end
		if ent:InsaneStats_GetMaxHealth() == math.huge and ent.insaneStats_MaxHealthRoot8 then
			ent.insaneStats_MaxHealth = ent.insaneStats_MaxHealthRoot8 ^ 8
		end
		if ent:InsaneStats_GetArmor() == math.huge and ent.insaneStats_ArmorRoot8 then
			ent.insaneStats_Armor = ent.insaneStats_ArmorRoot8 ^ 8
		end
		if ent:InsaneStats_GetMaxArmor() == math.huge and ent.insaneStats_MaxArmorRoot8 then
			ent.insaneStats_MaxArmor = ent.insaneStats_MaxArmorRoot8 ^ 8
		end]]
		
		if (ent:IsNPC() or ent:IsNextBot())
		and math.random() * 100 < InsaneStats:GetConVarValue("infhealth_armor_chance")
		and (ent:InsaneStats_GetMaxArmor() <= 0)
		and (not InsaneStats:GetConVarValue("infhealth_armor_sensible") or ent:InsaneStats_ArmorSensible()) then
			local startingHealth = ent:InsaneStats_GetMaxHealth() / (ent.insaneStats_CurrentHealthAdd or 1)
			local startingArmor = startingHealth * InsaneStats:GetConVarValue("infhealth_armor_mul")
			ent:SetMaxArmor(ent:InsaneStats_GetMaxHealth() * InsaneStats:GetConVarValue("infhealth_armor_mul"))
			ent.insaneStats_CurrentArmorAdd = ent:InsaneStats_GetMaxArmor() / startingArmor
			ent:SetArmor(ent:InsaneStats_GetMaxArmor())
		end
	end
	
	if not ent.insaneStats_SpawnModified then
		ent.insaneStats_SpawnModified = true
		local class = ent:GetClass()
		if class == "npc_strider" and InsaneStats:GetConVarValue("infhealth_enabled") then
			ent:SetHealth(ent:InsaneStats_GetHealth()*2.5)
			ent:SetMaxHealth(ent:InsaneStats_GetMaxHealth()*2.5)
		elseif class == "npc_combinegunship" and InsaneStats:GetConVarValue("infhealth_enabled") then
			ent:SetHealth(ent:InsaneStats_GetHealth()*7.5)
			ent:SetMaxHealth(ent:InsaneStats_GetMaxHealth()*7.5)
		
		elseif class == "item_suitcharger" or class == "func_recharge" then
			if ent:HasSpawnFlags(8192) then
				ent:Fire("AddOutput","OutRemainingCharge !activator:InsaneStatsSuperSuitChargerPoint::0:-1")
			else
				ent:Fire("AddOutput","OutRemainingCharge !activator:InsaneStatsSuitChargerPoint::0:-1")
			end
		elseif class == "item_healthcharger" or class == "func_healthcharger" then
			ent:Fire("AddOutput","OutRemainingCharge !activator:InsaneStatsHealthChargerPoint::0:-1")
		end
	end
end)

--[[ to fix transitions
saverestore.AddSaveHook("InsaneStatsUnlimitedHealth", function(save)
	save:StartBlock("InsaneStatsUnlimitedHealth")
	
	-- for every entity, record the 128th root of their health and armor
	local entsToUpdate = {}
	local updateReasons = {}
	for k,v in pairs(ents.GetAll()) do
		local updateReason = bit.bor(
			(v:InsaneStats_GetHealth() >= 2^128 and v:InsaneStats_GetHealth() < math.huge and 1 or 0),
			(v:InsaneStats_GetArmor() >= 2^128 and v:InsaneStats_GetArmor() < math.huge and 2 or 0)
		)
		
		if updateReason ~= 0 then
			table.insert(entsToUpdate, v)
			updateReasons[v] = updateReason
		end
	end
	
	save:WriteInt(#entsToUpdate)
	for k,v in pairs(entsToUpdate) do
		local updateReason = updateReasons[v]
		local hp = bit.band(updateReason, 1) ~= 0 and v:InsaneStats_GetHealth()^0.125 or -1
		local ar = bit.band(updateReason, 2) ~= 0 and v:InsaneStats_GetArmor()^0.125 or -1
		
		save:WriteEntity(v)
		save:WriteFloat(hp)
		save:WriteFloat(ar)
	end
	
	save:EndBlock()
end)

saverestore.AddRestoreHook("InsaneStatsUnlimitedHealth", function(save)
	save:StartBlock("InsaneStatsUnlimitedHealth")
	
	for i=1,save:ReadInt() do
		local ent = save:ReadEntity()
		local hp = save:ReadFloat()
		local ar = save:ReadFloat()
		
		if IsValid(ent) then
			if hp > 0 then
				ent:SetHealth(hp^8)
			end
			if ent.SetArmor and ar > 0 then
				ent:SetArmor(ar^8)
			end
		end
	end
	
	save:EndBlock()
end)]]