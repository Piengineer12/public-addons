local damageTiers = {0}
-- 0: normal, 0.5: skill reflect, 1: explosive recalculate, 1.5: skill fall, 2: explosive, 3: arcing, 4: status effect, 5: doom
--[[
shock, electroblast and cosmicurse status effects have complicated interactions
only for tier 1 damage PostEntityTakeDamage should apply those status effects immediately
this doesn't happen for any other tier damage
]]

-- if it is a skill-based explosion, it is able to hurt the owner
local isSkillExplosion = false

local entities = {}
for i,v in ipairs(ents.GetAll()) do
	entities[v] = true
end
local rapidThinkEntities = {}
for k,v in pairs(entities) do
	if k:InsaneStats_IsMob() then
		rapidThinkEntities[k] = true
	end
end

local blastDamageTypes = bit.bor(DMG_BLAST, DMG_BLAST_SURFACE)
local fireDamageTypes = bit.bor(DMG_BURN, DMG_SLOWBURN)
local poisonDamageTypes = bit.bor(DMG_PARALYZE, DMG_NERVEGAS, DMG_POISON, DMG_RADIATION, DMG_ACID)
local freezeDamageTypes = bit.bor(DMG_DROWN, DMG_VEHICLE)
local shockDamageTypes = bit.bor(DMG_FALL, DMG_SHOCK)
local vector_down = -vector_up
local explosionCount = 0

hook.Add("InsaneStatsWPASS2Doom", "InsaneStatsWPASS2", function(victim, level, attacker)
	if level ~= 0 and victim:InsaneStats_GetHealth() > 0 then
		table.insert(damageTiers, 5)
		
		if not IsValid(attacker) then
			attacker = victim
		end
		local dmginfo = DamageInfo()
		dmginfo:SetAmmoType(-1)
		dmginfo:SetAttacker(attacker)
		dmginfo:SetBaseDamage(level)
		dmginfo:SetDamage(level)
		dmginfo:SetDamageForce(vector_origin)
		dmginfo:SetDamagePosition(victim:WorldSpaceCenter())
		dmginfo:SetDamageType(DMG_ENERGYBEAM)
		dmginfo:SetInflictor(attacker)
		dmginfo:SetMaxDamage(level)
		dmginfo:SetReportedPosition(attacker:WorldSpaceCenter())
		victim:TakeDamageInfo(dmginfo)
		
		table.remove(damageTiers)
	end
end)

local armoredClasses = { -- these entities are counted as armored for armored_victim_damage
	["npc_antlionguard"]=true,
	["npc_combinedropship"]=true,
	["npc_combinegunship"]=true,
	["npc_helicopter"]=true,
	["npc_rollermine"]=true,
	["npc_sniper"]=true,
	["npc_strider"]=true,
	["npc_turret_floor"]=true,
	["prop_vehicle_apc"]=true
}

local function ShouldDodge(vic, attacker, dmginfo)
	if not dmginfo:IsDamageType(DMG_DISSOLVE) then
		if math.random() < vic:InsaneStats_GetAttributeValue("dodge") - 1 then return true end
		if attacker:InsaneStats_GetStatusEffectLevel("stunned") > 0 then return true end

		if math.random() * 100 < vic:InsaneStats_GetSkillValues("dodger") then return true end
		if vic:InsaneStats_GetStatusEffectLevel("skill_absorption") > 0 then
			if vic:IsPlayer() then
				vic:GiveAmmo(1, math.random(#game.GetAmmoTypes()))
			end
			local newLevel = vic:InsaneStats_GetStatusEffectLevel("skill_absorption") - 1
			local duration = vic:InsaneStats_GetStatusEffectDuration("skill_absorption")

			vic:InsaneStats_ClearStatusEffect("skill_absorption")

			if newLevel > 0 then
				vic:InsaneStats_ApplyStatusEffect(
					"skill_absorption",
					newLevel,
					duration
				)
			end
			return true
		end
	end
end

local function CalculateDamage(vic, attacker, dmginfo)
	local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon()
	--if math.random() < attacker:InsaneStats_GetAttributeValue("misschance") - 1 then return true end
	if ShouldDodge(vic, attacker, dmginfo) then return true end

	local attackerArmorInverseFraction = attacker:InsaneStats_GetArmor() > 0
		and attacker:InsaneStats_GetArmor() / attacker:InsaneStats_GetMaxArmor() or 0

	if attacker:InsaneStats_HasSkill("shield_shell_shots") and attackerArmorInverseFraction >= 1 then
		attacker:SetArmor(
			attacker:InsaneStats_GetArmor()
			+ attacker:InsaneStats_GetMaxArmor()
			* attacker:InsaneStats_GetSkillValues("shield_shell_shots", 2) / 100
			/ attackerArmorInverseFraction
		)
		dmginfo:AddDamage(40)
	end
	
	local totalMul = attacker:InsaneStats_GetAttributeValue("damage")
	local knockbackMul = attacker:InsaneStats_GetAttributeValue("knockback")
	
	totalMul = totalMul * vic:InsaneStats_GetAttributeValue("damagetaken")
	knockbackMul = knockbackMul * vic:InsaneStats_GetAttributeValue("knockbacktaken")
	
	if vic.insaneStats_LastHitGroup == HITGROUP_HEAD then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("crit_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("crit_damagetaken")
	end
	
	if vic == attacker then
		knockbackMul = knockbackMul * vic:InsaneStats_GetAttributeValue("self_knockbacktaken")
	end
	
	local isNotBulletDamage = not dmginfo:IsBulletDamage()
	local attackerHealthFraction = attacker:InsaneStats_GetMaxHealth() > 0
		and 1-math.Clamp(attacker:InsaneStats_GetHealth() / attacker:InsaneStats_GetMaxHealth(), 0, 1) or 0
	local victimHealthFraction = vic:InsaneStats_GetMaxHealth() > 0
		and 1-math.Clamp(vic:InsaneStats_GetHealth() / vic:InsaneStats_GetMaxHealth(), 0, 1) or 0
	local attackerSpeedFraction = attacker:GetVelocity():Length() / 400
	if attacker:IsPlayer() then
		attackerSpeedFraction = attackerSpeedFraction * attacker:GetLaggedMovementValue()
	end
	local victimSpeedFraction = vic:GetVelocity():Length() / 400
	if vic:IsPlayer() then
		victimSpeedFraction = victimSpeedFraction * vic:GetLaggedMovementValue()
	end
	--local attackerCombatFraction = math.Clamp(attacker:InsaneStats_GetCombatTime()/5, 0, 1)
	--local victimCombatFraction = math.Clamp(vic:InsaneStats_GetCombatTime()/5, 0, 1)
	
	--[[local combatDodgeChance = (vic:InsaneStats_GetAttributeValue("combat5s_dodge") - 1) * victimCombatFraction
	if math.random() < combatDodgeChance then return true end]]
	
	if isNotBulletDamage then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("nonbullet_damage")
		--if math.random() < attacker:InsaneStats_GetAttributeValue("nonbullet_misschance") - 1 then return true end
	else
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("bullet_damagetaken")
	end
	if dmginfo:IsDamageType(blastDamageTypes) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("explode_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("explode_damagetaken")
	end
	if dmginfo:IsDamageType(fireDamageTypes) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("fire_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("fire_damagetaken")
	end
	if dmginfo:IsDamageType(poisonDamageTypes) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("poison_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("poison_damagetaken")
	end
	if dmginfo:IsDamageType(freezeDamageTypes) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("freeze_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("freeze_damagetaken")
	end
	if dmginfo:IsDamageType(shockDamageTypes) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("shock_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("shock_damagetaken")
	end
	if dmginfo:IsDamageType(DMG_SLASH) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("bleed_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("bleed_damagetaken")
	end
	if dmginfo:IsDamageType(DMG_CLUB) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("melee_damage")
		totalMul = totalMul * (1 + (attacker:InsaneStats_GetAttributeValue("lowhealth_victim_melee_damage") - 1) * victimHealthFraction)
	end
	
	if (IsValid(wep) and wep.Clip1 and wep:Clip1() < 2) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("lastammo_damage")
	end
	if attacker:WorldSpaceCenter():DistToSqr(vic:WorldSpaceCenter()) > 262144 then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("longrange_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("longrange_damagetaken")
		if isNotBulletDamage then
			totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("longrange_nonbullet_damage")
		end
	else
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("shortrange_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("shortrange_damagetaken")
		if isNotBulletDamage then
			totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("shortrange_nonbullet_damage")
		end
	end
	
	totalMul = totalMul
	* (1 + (attacker:InsaneStats_GetAttributeValue("lowhealth_damage") - 1) * attackerHealthFraction)
	* (1 + (attacker:InsaneStats_GetAttributeValue("lowhealth_victim_damage") - 1) * victimHealthFraction)
	* (1 + (vic:InsaneStats_GetAttributeValue("lowhealth_damagetaken") - 1) * victimHealthFraction)
	if victimHealthFraction > 0.9 then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("high90health_victim_damage")
	end
	if victimHealthFraction < attacker:InsaneStats_GetAttributeValue("lowxhealth_victim_doubledamage") - 1 then
		totalMul = totalMul * 2
	end
	totalMul = totalMul
	* (1 + (attacker:InsaneStats_GetAttributeValue("speed_damage") - 1) * attackerSpeedFraction)
	* (1 + (attacker:InsaneStats_GetAttributeValue("armor_damage") - 1) * attackerArmorInverseFraction)
	/ (1 + (vic:InsaneStats_GetAttributeValue("speed_defence") - 1) * attackerSpeedFraction)
	--* (1 + (attacker:InsaneStats_GetAttributeValue("combat5s_damage") - 1) * attackerCombatFraction)
	--* (1 + (vic:InsaneStats_GetAttributeValue("combat5s_damagetaken") - 1) * victimCombatFraction)
	
	if vic:InsaneStats_TimeSinceCombat() >= 10 then
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("noncombat_damagetaken")
	end
	
	totalMul = totalMul
	* (1-attacker:InsaneStats_GetStatusEffectLevel("damage_down")/100)
	* (1+attacker:InsaneStats_GetStatusEffectLevel("damage_up")/100)
	* (1+attacker:InsaneStats_GetStatusEffectLevel("arcane_damage_up")/100)
	* (1+attacker:InsaneStats_GetStatusEffectLevel("alt_damage_up")/100)
	* (1+attacker:InsaneStats_GetStatusEffectLevel("hittaken_damage_up")/100)
	* (1+attacker:InsaneStats_GetStatusEffectLevel("killstackmarked_damage_up")/100)
	* (1+vic:InsaneStats_GetStatusEffectLevel("defence_down")/100)
	/ (1+vic:InsaneStats_GetStatusEffectLevel("defence_up")/100)
	/ (1+vic:InsaneStats_GetStatusEffectLevel("arcane_defence_up")/100)
	/ (1+vic:InsaneStats_GetStatusEffectLevel("killstackmarked_defence_up")/100)
	/ (1+vic:InsaneStats_GetStatusEffectLevel("alt_defence_up")/100)
	/ (1+vic:InsaneStats_GetStatusEffectLevel("ctrl_defence_up")/100)
	
	--* (1+(attacker:InsaneStats_GetAttributeValue("perdebuff_damage")-1)*vic:InsaneStats_GetStatusEffectCountByType(-1))
	--/ (1+(vic:InsaneStats_GetAttributeValue("perdebuff_defence")-1)*vic:InsaneStats_GetStatusEffectCountByType(-1))
	--print(attacker:InsaneStats_GetAttributeValue("perdebuff_damage"), vic:InsaneStats_GetStatusEffectCountByType(-1))
	
	* (1 + attacker:InsaneStats_GetStatusEffectLevel("stack_damage_up") / 100)
	/ (1 + vic:InsaneStats_GetStatusEffectLevel("stack_defence_up") / 100)
	
	* (1 + vic:InsaneStats_GetStatusEffectLevel("perhit_defence_down")/100)
	* (1 - attacker:InsaneStats_GetStatusEffectLevel("menacing_damage_down")/100)

	if vic:InsaneStats_GetAttributeValue("starlight_defence") ~= 1 then
		totalMul = totalMul / (1 + vic:InsaneStats_GetStatusEffectDuration("starlight") / 100)
	end
	
	--totalMul = totalMul * (1 + attacker:InsaneStats_GetStatusEffectLevel("hit10s_damage_up") / 100)

	if vic:InsaneStats_GetStatusEffectLevel("hittaken1s_damagetaken_cooldown") <= 0 then
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("hittaken1s_damagetaken")
	end
	
	if vic:InsaneStats_IsMob() then
		if attacker:InsaneStats_GetStatusEffectLevel("hit1s_damage_cooldown") <= 0 then
			totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("hit1s_damage")
		end
		
		--[[if attacker:InsaneStats_GetAttributeValue("hit10s_damage") ~= 1
		and attacker:InsaneStats_GetStatusEffectLevel("hit10s_damage_up") <= 0
		and attacker:InsaneStats_GetStatusEffectLevel("hit10s_damage_cooldown") <= 0
		then
			local stacks = (attacker:InsaneStats_GetAttributeValue("hit10s_damage")-1)*100
			attacker:InsaneStats_ApplyStatusEffect("hit10s_damage_up", stacks, 10)
		end]]
	
		--[[if attacker:InsaneStats_GetAttributeValue("hit10s_firerate") ~= 1
		and attacker:InsaneStats_GetStatusEffectLevel("hit10s_firerate_up") <= 0
		and attacker:InsaneStats_GetStatusEffectLevel("hit10s_firerate_cooldown") <= 0
		then
			local stacks = (attacker:InsaneStats_GetAttributeValue("hit10s_firerate")-1)*100
			attacker:InsaneStats_ApplyStatusEffect("hit10s_firerate_up", stacks, 10)
		end]]
		
		if attacker:InsaneStats_GetAttributeValue("hit3_damage") ~= 1 then
			if attacker:InsaneStats_GetStatusEffectLevel("hit3_damage_stacks") < 2 then
				attacker:InsaneStats_ApplyStatusEffect("hit3_damage_stacks", 1, math.huge, {amplify = true})
			else
				attacker:InsaneStats_ClearStatusEffect("hit3_damage_stacks")
				totalMul = totalMul * (1 + attacker:InsaneStats_GetAttributeValue("hit3_damage"))
			end
		end
		
		if attacker:InsaneStats_IsValidAlly(vic) and not (attacker:IsPlayer() and attacker:KeyDown(IN_WALK)) then
			totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("ally_damage")
		end
	--[[else
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("nonliving_damage")]]
	end
	
	local levelDifference = vic:InsaneStats_GetLevel() - attacker:InsaneStats_GetLevel()
	if levelDifference > 0 then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("highlevel_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("lowlevel_damagetaken")
	end
	
	if attacker:InsaneStats_GetAttributeValue("random_damage") ~= 1 then
		local randomness = 1 - attacker:InsaneStats_GetAttributeValue("random_damage")
		totalMul = totalMul * Lerp(math.random(), 1 - randomness, 1 + randomness)
	end
	
	if attacker.insaneStats_MarkedEntity == vic then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("mark_damage")
	end
	if vic.insaneStats_MarkedEntity == attacker then
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("mark_damagetaken")
	end
	
	if attacker:InsaneStats_GetLevel() % 2 == 0 then
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("evenlevel_damagetaken")
	else
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("oddlevel_damagetaken")
	end
	
	if vic:InsaneStats_GetLevel() % 2 == 0 then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("evenlevel_damage")
	else
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("oddlevel_damage")
	end
	
	if armoredClasses[vic:GetClass()] or vic:InsaneStats_GetArmor() > 0 then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("armored_victim_damage")
	else
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("unarmored_victim_damage")
	end
	
	local attackerPositionVector = attacker:WorldSpaceCenter() - vic:WorldSpaceCenter()
	attackerPositionVector:Normalize()
	local vicLookVector = vic:GetForward()
	if vicLookVector:Dot(attackerPositionVector) > 0 then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("front_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("front_damagetaken")
	else
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("back_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("back_damagetaken")
	end

	-- SKILLS

	local vicSuperColdValue = vic:InsaneStats_GetSkillValues("super_cold", 2) or 0

	totalMul = totalMul
	* (1 + attacker:InsaneStats_GetSkillValues("quintessence") / 100)
	* (1 + vic:InsaneStats_GetSkillValues("quintessence", 2) / 100)
	* (1 + attacker:InsaneStats_GetSkillValues("damage") / 100)
	* (1 + vic:InsaneStats_GetSkillValues("defence") / 100)
	* (1 + attacker:InsaneStats_GetSkillStacks("aint_got_time_for_this") / 100)
	/ (1 + vic:InsaneStats_GetSkillStacks("aint_got_time_for_this") / 100)
	/ (1 + vic:InsaneStats_GetSkillStacks("love_and_tolerate") / 100)
	* math.max(0, 1 + vic:InsaneStats_GetSkillValues("four_parallel_universes_ahead") / 100 * victimSpeedFraction)
	* (1 + attacker:InsaneStats_GetSkillValues("rage") / 100 * attackerHealthFraction)
	* (1 + attacker:InsaneStats_GetSkillValues("why_is_it_called_kiting") / 100 * attackerSpeedFraction)
	* (1 + vic:InsaneStats_GetSkillValues("living_on_the_edge") / 100 * victimHealthFraction)
	* (1 + attacker:InsaneStats_GetSkillValues("super_cold") / 100 * attacker:InsaneStats_GetSkillStacks("super_cold"))
	* math.max(0, 1 + vicSuperColdValue / 100 * vic:InsaneStats_GetSkillStacks("super_cold"))
	* (1 + attacker:InsaneStats_GetStatusEffectLevel("charge") / 2)
	* (1 - vic:InsaneStats_GetStatusEffectLevel("charge") / 2.5)
	/ (1 + vic:InsaneStats_GetSkillStacks("starlight") / 100)
	* (1 + attacker:InsaneStats_GetStatusEffectLevel("skill_damage_up") / 100)
	/ (1 + vic:InsaneStats_GetStatusEffectLevel("skill_defence_up") / 100)
	* (1 + attacker:InsaneStats_GetSkillStacks("more_bullet_per_bullet") / 100)
	/ (1 + vic:InsaneStats_GetSkillStacks("more_bullet_per_bullet") / 100)

	if attacker:InsaneStats_GetSkillStacks("rip_and_tear") > 0 then
		totalMul = totalMul * (1 + attacker:InsaneStats_GetSkillValues("rip_and_tear") / 100)
	end
	if attacker:InsaneStats_GetSkillState("anger") == 1 then
		totalMul = totalMul * 2
	end
	if vic:InsaneStats_HasSkill("pulsing_armor") then
		totalMul = totalMul * (1 + vic:InsaneStats_GetSkillValues("pulsing_armor") / 100)
	end
	if dmginfo:IsExplosionDamage() then
		totalMul = totalMul * (1 + attacker:InsaneStats_GetSkillValues("kablooey") / 100)
		if attacker == vic and vic:InsaneStats_HasSkill("blast_proof_suit") then
			totalMul = 0
		else
			totalMul = totalMul * (1 + vic:InsaneStats_GetSkillValues("blast_proof_suit") / 100)
		end
		totalMul = totalMul * (1 + attacker:InsaneStats_GetSkillValues("blast_proof_suit", 2) / 100)
	end
	if vic:InsaneStats_GetSkillStacks("embolden") > 0 then
		totalMul = totalMul * (1 + vic:InsaneStats_GetSkillValues("embolden") / 100)
	end
	if vic.insaneStats_LastHitGroup == HITGROUP_HEAD then
		totalMul = totalMul
		* (1 + attacker:InsaneStats_GetSkillValues("the_sniper") / 100)
		* (1 + attacker:InsaneStats_GetStatusEffectLevel("skill_crit_damage_up")/100)
	end
	if isNotBulletDamage then
		totalMul = totalMul * (1 + attacker:InsaneStats_GetSkillValues("a_little_less_gun") / 100)
		totalMul = totalMul * (1 + vic:InsaneStats_GetSkillValues("iron_skin") / 100)
	else
		totalMul = totalMul * (1 + attacker:InsaneStats_GetSkillValues("silver_bullets") / 100)
	end
	if IsValid(wep) then
		if wep:GetPrimaryAmmoType() == 3 or wep:GetPrimaryAmmoType() == 5
		or wep:GetSecondaryAmmoType() == 3 or wep:GetSecondaryAmmoType() == 5 then
			totalMul = totalMul * (1 + attacker:InsaneStats_GetSkillValues("one_with_the_gun") / 100)
		end
	end
	if vic.insaneStats_MarkedEntity == attacker then
		totalMul = totalMul * (1 + vic:InsaneStats_GetSkillValues("alert", 2) / 100)
	end
	if attacker.insaneStats_MarkedEntity == vic then
		totalMul = totalMul * (1 + attacker:InsaneStats_GetSkillValues("alert") / 100)
	end
	--[[if not game.SinglePlayer() then
		totalMul = totalMul * (1 + math.sqrt(attacker:InsaneStats_GetStatusEffectLevel("multi_killer"))/100)
	end]]

	local acrCount = 0
	if vic:InsaneStats_GetArmor() > 0 then
		totalMul = totalMul * (1 + vic:InsaneStats_GetSkillValues("impenetrable_shield") / 100)
		acrCount = acrCount + 1
	end
	if not vic:InsaneStats_IsMob() then
		totalMul = totalMul * (1 + attacker:InsaneStats_GetSkillValues("the_sniper") / 100)
		acrCount = 1
	end
	if armoredClasses[vic:GetClass()] then
		acrCount = acrCount + 1
	end

	totalMul = totalMul * (1 + attacker:InsaneStats_GetSkillValues("anti_coward_rounds") / 100) ^ acrCount

	knockbackMul = knockbackMul / (1 + vic:InsaneStats_GetStatusEffectLevel("skill_knockback_resistance_up") / 100)
		

	--print(totalMul)
	dmginfo:ScaleDamage(totalMul)
	
	vic:InsaneStats_SetEntityData(
		"armor_blocks_all",
		vic:InsaneStats_GetAttributeValue("armor_trueblock") > 1
		or vic:InsaneStats_HasSkill("impenetrable_shield")
	)
	
	dmginfo:SetDamageForce(dmginfo:GetDamageForce() * knockbackMul)
end

local function CauseExplosion(data)
	local damageTier = data.damageTier
	local attacker = data.attacker
	local damage = data.damage
	local damagePos = data.damagePos
	local damageType = data.damageType
	local radius = data.radius
	if explosionCount < 10 then
		table.insert(damageTiers, damageTier)
		explosionCount = explosionCount + 1
		isSkillExplosion = data.isSkillExplosion
		
		local dmginfo = DamageInfo()
		dmginfo:SetAmmoType(8)
		dmginfo:SetAttacker(attacker)
		dmginfo:SetDamage(damage/2)
		dmginfo:SetDamagePosition(damagePos)
		dmginfo:SetDamageType(damageType)
		dmginfo:SetInflictor(attacker)
		dmginfo:SetReportedPosition(attacker:WorldSpaceCenter())
		util.BlastDamageInfo(dmginfo, damagePos, radius or 128)
		
		timer.Simple(0, function()
			local effdata = EffectData()
			effdata:SetOrigin(damagePos)
			effdata:SetMagnitude(1)
			effdata:SetScale(1)
			effdata:SetFlags(0)
			util.Effect("Explosion", effdata)
		end)
		
		table.remove(damageTiers)
		isSkillExplosion = false
	end
end

local function CauseDelayedDamage(data)
	--{damagePos,attacker,victim,damage,shouldExplode,shouldShock}
	local damagePos = data.pos
	local attacker = data.attacker
	local victim = data.victim
	local damage = data.damage
	local damageTier = data.damageTier
	local shouldExplode = data.shouldExplode
	local shouldShock = data.shouldShock
	local shouldElectroblast = data.shouldElectroblast
	local shouldCosmicurse = data.shouldCosmicurse
	local localPos
	
	if IsValid(victim) then
		localPos = victim:WorldToLocal(damagePos)
	end
					
	if shouldExplode or shouldElectroblast or shouldCosmicurse then
		local effdata = EffectData()
		effdata:SetOrigin(damagePos)
		effdata:SetScale(1)
		effdata:SetMagnitude(1)
		util.Effect("StunstickImpact", effdata)
	end
	
	timer.Simple(0.5, function()
		if IsValid(attacker) then
			local forceDir = vector_origin
			--local halfDamage = damage/2
			--local explosionDamage = halfDamage * attacker:InsaneStats_GetAttributeValue("explode_damage") --this isn't status effect damage
			--print(halfDamage)
			
			-- translate local pos if possible, else use world pos
			if IsValid(victim) then
				damagePos = victim:LocalToWorld(localPos)
				--forceDir = victim:GetPos() - damagePos
				--forceDir:Mul(128/forceDir:Length())
				
				if shouldShock and attacker ~= victim then
					local effectDamage = damage
					effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("shock_damage")
					effectDamage = effectDamage * victim:InsaneStats_GetAttributeValue("shock_damagetaken")
					
					victim:InsaneStats_ApplyStatusEffect("shock", effectDamage, 5, {amplify = true, attacker = attacker})
				end
			end
			
			if (shouldExplode or shouldElectroblast or shouldCosmicurse) then
				local damageType = DMG_BLAST
				if shouldCosmicurse then
					damageType = bit.bor(
						DMG_BLAST, DMG_SHOCK, DMG_NERVEGAS, DMG_SLASH,
						DMG_SLOWBURN, DMG_VEHICLE, DMG_ENERGYBEAM
					)
				elseif shouldElectroblast then
					damageType = bit.bor(DMG_BLAST, DMG_SHOCK)
				end
				CauseExplosion({
					damageTier = damageTier,
					attacker = attacker,
					damage = damage,
					damagePos = damagePos,
					damageType = damageType
				})
			end
		end
	end)
end

local totalDamageTicks = 0
local storedScaleCVars
local neverReflectDamageClasses = {
	-- reflecting stalker attacks will result in INSTANT CTD
	npc_stalker = true,
	trigger_hurt = true
}
hook.Add("EntityTakeDamage", "InsaneStatsWPASS2", function(vic, dmginfo)
	if (InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled")) and IsValid(vic) then
		totalDamageTicks = (totalDamageTicks or 0) + 1
		if totalDamageTicks > 1000 then
			print("Something caused an infinite loop!")
			debug.Trace()
			return true
		end
		
		if vic.insaneStats_LastHitGroupUpdate ~= engine.TickCount() then
			vic.insaneStats_LastHitGroup = 0
		end

		-- crits
		local attacker = dmginfo:GetAttacker()
		if IsValid(attacker) and vic.insaneStats_LastHitGroup ~= HITGROUP_HEAD then
			local shouldCrit = (math.random() < attacker:InsaneStats_GetAttributeValue("crit_chance") - 1)
			or not dmginfo:IsBulletDamage() and math.random() * 100 < attacker:InsaneStats_GetSkillValues("aimbot", 2)
			if shouldCrit then
				if not storedScaleCVars then
					storedScaleCVars = {
						npc = {
							arm = GetConVar("sk_npc_arm"),
							chest = GetConVar("sk_npc_chest"),
							head = GetConVar("sk_npc_head"),
							leg = GetConVar("sk_npc_leg"),
							stomach = GetConVar("sk_npc_stomach")
						},
						player = {
							arm = GetConVar("sk_player_arm"),
							chest = GetConVar("sk_player_chest"),
							head = GetConVar("sk_player_head"),
							leg = GetConVar("sk_player_leg"),
							stomach = GetConVar("sk_player_stomach")
						}
					}
				end
				local damageMultiplier = 1
				local scaleCVars = vic:IsPlayer() and storedScaleCVars.player or storedScaleCVars.npc
				local lastHitGroup = vic.insaneStats_LastHitGroup
				if lastHitGroup == HITGROUP_CHEST then
					damageMultiplier = scaleCVars.chest:GetFloat()
				elseif lastHitGroup == HITGROUP_STOMACH then
					damageMultiplier = scaleCVars.stomach:GetFloat()
				elseif lastHitGroup == HITGROUP_LEFTARM	or lastHitGroup == HITGROUP_RIGHTARM then
					damageMultiplier = scaleCVars.arm:GetFloat()
				elseif lastHitGroup == HITGROUP_LEFTLEG	or lastHitGroup == HITGROUP_RIGHTLEG then
					damageMultiplier = scaleCVars.leg:GetFloat()
				--[[elseif lastHitGroup == HITGROUP_GEAR then
					damageMultiplier = 0.01]]
				end
				if damageMultiplier > 0 then
					damageMultiplier = scaleCVars.head:GetFloat() / damageMultiplier
				end
				dmginfo:ScaleDamage(damageMultiplier)
				vic.insaneStats_LastHitGroup = HITGROUP_HEAD
				vic.insaneStats_LastHitGroupUpdate = engine.TickCount()
			end
		end

		-- always-trigger damage taken skills
		if vic:InsaneStats_HasSkill("medic_bag") and vic:InsaneStats_GetSkillStacks("medic_bag") <= 0 then
			local restoreFrac = vic:InsaneStats_GetSkillValues("medic_bag") / 100
			vic:InsaneStats_AddHealthNerfed(vic:InsaneStats_GetMaxHealth() * restoreFrac)
			vic:InsaneStats_AddArmorNerfed(vic:InsaneStats_GetMaxArmor() * restoreFrac)
			vic:InsaneStats_SetSkillData("medic_bag", -1, 60)
		end

		if attacker:InsaneStats_IsMob() and attacker ~= vic then
			if vic:InsaneStats_HasSkill("love_and_tolerate") then
				vic:InsaneStats_SetSkillData(
					"love_and_tolerate",
					1,
					vic:InsaneStats_GetSkillStacks("love_and_tolerate")
					+ vic:InsaneStats_GetSkillValues("love_and_tolerate")
				)
			end
			if vic:InsaneStats_HasSkill("anger") and vic:InsaneStats_GetSkillState("anger") == 0 then
				vic:InsaneStats_SetSkillData(
					"anger",
					1,
					vic:InsaneStats_GetSkillValues("anger")
				)
			end
		end

		local damageTier = damageTiers[#damageTiers]
		if damageTier < 0.5 and math.random() * 100 < vic:InsaneStats_GetSkillValues("instant_karma") then
			--[[local oldDamage = dmginfo:GetDamage()
			local oldAttacker = attacker]]
			
			table.insert(damageTiers, 0.5)
			--[[dmginfo:SetAttacker(vic)
			dmginfo:SetDamage(40)
			oldAttacker:TakeDamageInfo(dmginfo)
			dmginfo:SetDamage(oldDamage)
			dmginfo:SetAttacker(oldAttacker)]]

			if not neverReflectDamageClasses[attacker:GetClass()] then
				attacker:TakeDamage(40, vic)
			end
			table.remove(damageTiers)
		end

		if vic:InsaneStats_HasSkill("mantreads") and dmginfo:IsFallDamage() and damageTier < 1.5 then
			local targets = {}
			for i,v in ipairs(ents.FindInSphere(vic:WorldSpaceCenter(), 256)) do
				if v ~= vic and v:GetParent() ~= vic then
					table.insert(targets, v)
				end
			end

			local damageScale = 2 ^ vic:InsaneStats_GetSkillValues("mantreads")
			local oldAttacker = attacker

			table.insert(damageTiers, 1.5)
			dmginfo:SetAttacker(vic)
			dmginfo:ScaleDamage(damageScale)
			for i,v in ipairs(targets) do
				v:TakeDamageInfo(dmginfo)
			end
			dmginfo:ScaleDamage(1/damageScale)
			dmginfo:SetAttacker(oldAttacker)
			table.remove(damageTiers)

			vic:InsaneStats_DamageNumber(vic, "immune")
			return true
		end

		if math.random() * 100 < vic:InsaneStats_GetSkillValues("absorption_shield")
		and vic:InsaneStats_GetArmor() > 0 then
			if vic:IsPlayer() then
				vic:GiveAmmo(1, math.random(#game.GetAmmoTypes()))
			end
			
			vic:InsaneStats_DamageNumber(attacker, "miss")
			return true
		end

		if (vic:InsaneStats_GetStatusEffectLevel("hittaken_invincible") > 0 or vic:InsaneStats_GetStatusEffectLevel("invincible") > 0)
		and not dmginfo:IsDamageType(DMG_DISSOLVE) then
			vic:InsaneStats_DamageNumber(attacker, "immune")
			
			-- on melee hits, reduce duration of invincibility
			if dmginfo:IsDamageType(DMG_CLUB) and vic:InsaneStats_GetStatusEffectLevel("hittaken_invincible") > 0 then
				local deduct = vic:InsaneStats_GetAttributeValue("hittaken_invincible_meleebreak") - 1
				vic:InsaneStats_ApplyStatusEffect("hittaken_invincible", 1, deduct, {extend = true})
			end
			
			return true
		end

		if vic:InsaneStats_GetSkillState("ubercharge") == 1 and not dmginfo:IsDamageType(DMG_DISSOLVE) then
			vic:InsaneStats_DamageNumber(attacker, "immune")
			return true
		end

		if vic:InsaneStats_GetSkillState("fight_for_your_life") == 1 then
			vic:InsaneStats_DamageNumber(attacker, "immune")
			return true
		end

		if vic:InsaneStats_GetSkillTier("rock_solid") > 0 then
			if (vic:IsPlayer() and vic:InVehicle()) or dmginfo:IsDamageType(fireDamageTypes)
			or vic:InsaneStats_GetSkillTier("rock_solid") > 1
			and dmginfo:IsDamageType(bit.bor(poisonDamageTypes, DMG_SHOCK)) then
				vic:InsaneStats_DamageNumber(attacker, "immune")
				return true
			end
		end

		if attacker:InsaneStats_IsValidAlly(vic)
		and attacker ~= vic
		and attacker:InsaneStats_GetSkillState("friendly_fire_off") == 1
		and attacker:InsaneStats_HasSkill("friendly_fire_off") then
			vic:InsaneStats_DamageNumber(attacker, "immune")
			return true
		end
		
		if IsValid(attacker) or attacker == game.GetWorld() and not vic:IsVehicle() then
			if attacker:GetClass() == "entityflame"
			and (vic:InsaneStats_GetStatusEffectLevel("fire") > 0
			or vic:InsaneStats_GetStatusEffectLevel("frostfire") > 0
			or vic:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0) then
				return true
			end

			local isDropshipContainer = vic:GetClass() == "prop_dropship_container"
			if isDropshipContainer and InsaneStats:GetConVarValue("wpass2_dropship_invincible") then
				vic:InsaneStats_DamageNumber(attacker, "immune")
				return true
			end
			
			if vic:InsaneStats_IsMob() and damageTier > 0
			and (not attacker:InsaneStats_IsValidEnemy(vic) or isDropshipContainer)
			and not isSkillExplosion then
				if dmginfo:IsExplosionDamage() then
					vic:InsaneStats_ApplyKnockback(dmginfo:GetDamageForce())
				end
				return true
			end
			if vic:InsaneStats_GetHealth() > 0 and damageTier <= 1 then
				local shouldBreak = CalculateDamage(vic, attacker, dmginfo)
				if shouldBreak then
					vic:InsaneStats_DamageNumber(attacker, "miss")
					if attacker == vic then
						vic:InsaneStats_ApplyKnockback(dmginfo:GetDamageForce())
					end
					--print(vic, "BLOCKED")
					return true
				end
			end
		end
	end
end)

hook.Add("PostEntityTakeDamage", "InsaneStatsWPASS2", function(vic, dmginfo, notImmune)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local attacker = dmginfo:GetAttacker()
		local damageTier = damageTiers[#damageTiers]
		if IsValid(attacker) and IsValid(vic) and attacker ~= vic then
			local vicIsMob = vic:InsaneStats_IsMob()
			if vicIsMob and attacker:InsaneStats_IsMob() then
				vic:InsaneStats_UpdateCombatTime()
				attacker:InsaneStats_UpdateCombatTime()

				if attacker:InsaneStats_HasSkill("skip_the_scenery") then
					attacker:InsaneStats_SetSkillData("skip_the_scenery", -1, 10)
				end
				if vic:InsaneStats_HasSkill("skip_the_scenery") then
					vic:InsaneStats_SetSkillData("skip_the_scenery", -1, 10)
				end
			end
			
			local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon()
			
			if damageTier < 4 and not dmginfo:IsDamageType(DMG_BURN) and not IsValid(vic:GetParent()) then
				-- non-damage based effects
				local speedDownLevel = (1 - attacker:InsaneStats_GetAttributeValue("victim_speed")) * 100
				vic:InsaneStats_ApplyStatusEffect("speed_down", speedDownLevel, 5)
				local defenceDownLevel = (attacker:InsaneStats_GetAttributeValue("victim_damagetaken") - 1) * 100
				vic:InsaneStats_ApplyStatusEffect("defence_down", defenceDownLevel, 5)
				local damageDownLevel = (1 - attacker:InsaneStats_GetAttributeValue("victim_damage")) * 100
				vic:InsaneStats_ApplyStatusEffect("damage_down", damageDownLevel, 5)
				local fireRateDownLevel = (1 - attacker:InsaneStats_GetAttributeValue("victim_firerate")) * 100
				vic:InsaneStats_ApplyStatusEffect("firerate_down", fireRateDownLevel, 5)
				
				-- non-over time / delayed effects
				local damage = dmginfo:GetDamage()
				--print(damage)
				--print(not dmginfo:IsBulletDamage(), damageTiers[#damageTiers] < 1, vic:GetCollisionGroup() ~= COLLISION_GROUP_DEBRIS)
				
				if math.random() < attacker:InsaneStats_GetAttributeValue("arc_chance") - 1 then
					-- get a random nearby entity
					local traceResult = {}
					local trace = {
						start = vic:WorldSpaceCenter(),
						filter = {vic, vic.GetVehicle and vic:GetVehicle()},
						mask = MASK_SHOT,
						output = traceResult
					}
					
					local randomEntity = NULL
					for k,v in RandomPairs(ents.FindInSphere(trace.start, 512)) do
						if attacker:InsaneStats_IsValidEnemy(v) then
							local damagePos = v:HeadTarget(attacker:WorldSpaceCenter()) or v:WorldSpaceCenter()
							damagePos = damagePos:IsZero() and v:WorldSpaceCenter() or damagePos
							trace.endpos = damagePos
							util.TraceLine(trace)
							if not traceResult.Hit or traceResult.Entity == v then
								randomEntity = v break
							end
						end
					end
					
					if IsValid(randomEntity) then
						table.insert(damageTiers, 3)
						randomEntity:TakeDamageInfo(dmginfo)
						table.remove(damageTiers)
					end
				end
				
				local worldPos = dmginfo:GetDamagePosition()
				worldPos = worldPos:IsZero() and vic:WorldSpaceCenter() or worldPos
				
				local explodeCondition = not dmginfo:IsBulletDamage() and damageTier < 1 and vic:GetCollisionGroup() ~= COLLISION_GROUP_DEBRIS
				local shouldExplode = math.random() < attacker:InsaneStats_GetAttributeValue("explode") - 1
				local shouldShock = math.random() < attacker:InsaneStats_GetAttributeValue("shock") - 1
				local shouldElectroblast = math.random() < attacker:InsaneStats_GetAttributeValue("electroblast") - 1
				local shouldCosmicurse = attacker:InsaneStats_GetAttributeValue("cosmicurse") > 1
				local shouldSkillExplode = attacker:InsaneStats_HasSkill("brilliant_behemoth")
				and attacker:InsaneStats_GetSkillState("brilliant_behemoth") == 1

				if shouldExplode or shouldShock or shouldElectroblast or shouldCosmicurse then
					CauseDelayedDamage({
						pos = worldPos,
						attacker = attacker,
						victim = vic,
						damage = damage,
						damageTier = 2,
						shouldExplode = explodeCondition and shouldExplode,
						shouldShock = shouldShock,
						shouldElectroblast = explodeCondition and shouldElectroblast,
						shouldCosmicurse = explodeCondition and shouldCosmicurse
					})
				end
				if explodeCondition and shouldSkillExplode then
					CauseExplosion({
						attacker = attacker,
						damageTier = 1,
						damage = dmginfo:GetBaseDamage(),
						damagePos = worldPos,
						damageType = DMG_BLAST,
						radius = attacker:InsaneStats_GetSkillValues(
							"brilliant_behemoth", 2
						),
						isSkillExplosion = true
					})
				end
				
				if attacker:InsaneStats_GetAttributeValue("perhit_victim_damagetaken") ~= 1 then
					local stacks = (attacker:InsaneStats_GetAttributeValue("perhit_victim_damagetaken")-1)*100
					vic:InsaneStats_ApplyStatusEffect("perhit_defence_down", stacks, 5, {amplify = true})
				end
				
				if vic:InsaneStats_GetAttributeValue("hittakenstack_defence") ~= 1 then
					local stacks = (vic:InsaneStats_GetAttributeValue("hittakenstack_defence")-1)*100
					vic:InsaneStats_ApplyStatusEffect("stack_defence_up", stacks, math.huge, {amplify = true})
				end
				
				if vic:InsaneStats_GetAttributeValue("hittaken_invincible") > 1
				and vic:InsaneStats_GetStatusEffectLevel("hittaken_invincible") == 0
				and vic:InsaneStats_GetStatusEffectLevel("hittaken_invincible_cooldown") == 0
				and vic:InsaneStats_GetHealth() > 0 then
					vic:InsaneStats_ApplyStatusEffect("hittaken_invincible", 1, vic:InsaneStats_GetAttributeValue("hittaken_invincible") - 1)
				end
				
				if vic:InsaneStats_GetAttributeValue("hittaken_damage") ~= 1
				and vic:InsaneStats_GetStatusEffectLevel("hittaken_damage_up") <= 0
				and vic:InsaneStats_GetStatusEffectLevel("hittaken_damage_cooldown") <= 0
				and vic:InsaneStats_GetHealth() > 0 then
					local stacks = (vic:InsaneStats_GetAttributeValue("hittaken_damage")-1)*100
					vic:InsaneStats_ApplyStatusEffect("hittaken_damage_up", stacks, 10)
				end
				
				if vic:InsaneStats_GetAttributeValue("hittaken_regen") ~= 1
				and vic:InsaneStats_GetStatusEffectLevel("hittaken_regen") <= 0
				and vic:InsaneStats_GetStatusEffectLevel("hittaken_regen_cooldown") <= 0
				and vic:InsaneStats_GetHealth() > 0 then
					local stacks = (vic:InsaneStats_GetAttributeValue("hittaken_regen")-1)*100
					vic:InsaneStats_ApplyStatusEffect("hittaken_regen", stacks, 10)
				end
				
				if vic:InsaneStats_GetAttributeValue("hittaken_armorregen") ~= 1
				and vic:InsaneStats_GetStatusEffectLevel("hittaken_armorregen") <= 0
				and vic:InsaneStats_GetStatusEffectLevel("hittaken_armorregen_cooldown") <= 0
				and vic:InsaneStats_GetHealth() > 0 then
					local stacks = (vic:InsaneStats_GetAttributeValue("hittaken_armorregen")-1)*100
					vic:InsaneStats_ApplyStatusEffect("hittaken_armorregen", stacks, 10)
				end
				
				-- over time effects
				local shouldPoison = math.random() < attacker:InsaneStats_GetAttributeValue("poison") - 1
				local shouldBleed = math.random() < attacker:InsaneStats_GetAttributeValue("bleed") - 1
				local shouldHemotoxin = math.random() < attacker:InsaneStats_GetAttributeValue("hemotoxic") - 1
				
				local shouldFire = math.random() < attacker:InsaneStats_GetAttributeValue("fire") - 1
				local shouldFreeze = math.random() < attacker:InsaneStats_GetAttributeValue("freeze") - 1
				local shouldFrostfire = math.random() < attacker:InsaneStats_GetAttributeValue("frostfire") - 1
				
				if shouldPoison or shouldBleed or shouldHemotoxin then
					local effectDamage = 0
					
					if shouldPoison or shouldHemotoxin then
						effectDamage = effectDamage + damage*2
					end
					if shouldBleed or shouldHemotoxin then
						effectDamage = effectDamage + damage
					end
					
					if shouldPoison or shouldHemotoxin then
						effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("poison_damage")
						effectDamage = effectDamage * vic:InsaneStats_GetAttributeValue("poison_damagetaken")
					end
					if shouldBleed or shouldHemotoxin then
						effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("bleed_damage")
						effectDamage = effectDamage * vic:InsaneStats_GetAttributeValue("bleed_damagetaken")
					end
					
					if shouldPoison then
						vic:InsaneStats_ApplyStatusEffect("poison", effectDamage, 5, {extend = 5, attacker = attacker})
					elseif shouldBleed then
						vic:InsaneStats_ApplyStatusEffect("bleed", effectDamage, 5, {extend = 5, attacker = attacker})
					else
						vic:InsaneStats_ApplyStatusEffect("hemotoxin", effectDamage, 5, {extend = 5, attacker = attacker})
					end
				end
				
				if shouldFire or shouldFreeze or shouldFrostfire then
					local effectDamage = 0
					
					if shouldFire or shouldFrostfire then
						effectDamage = effectDamage + damage*2
					end
					if shouldFreeze or shouldFrostfire then
						effectDamage = effectDamage + damage
					end
					
					if shouldFire or shouldFrostfire then
						effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("fire_damage")
						effectDamage = effectDamage * vic:InsaneStats_GetAttributeValue("fire_damagetaken")
					end
					if shouldFreeze or shouldFrostfire then
						effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("freeze_damage")
						effectDamage = effectDamage * vic:InsaneStats_GetAttributeValue("freeze_damagetaken")
					end
					
					if shouldFire then
						vic:InsaneStats_ApplyStatusEffect("fire", effectDamage, 5, {extend = 5, attacker = attacker})
					elseif shouldFreeze then
						vic:InsaneStats_ApplyStatusEffect("freeze", effectDamage, 5, {extend = 5, attacker = attacker})
					else
						vic:InsaneStats_ApplyStatusEffect("frostfire", effectDamage, 5, {extend = 5, attacker = attacker})
					end
				end
				
				local hasElectroblast = attacker:InsaneStats_GetAttributeValue("electroblast") > 1
				if damageTier >= 1 and damageTier < 3
				and (hasElectroblast or shouldCosmicurse) then
					local effectDamage = 0
				
					if hasElectroblast then
						effectDamage = damage * 2
					else
						effectDamage = damage * (attacker:InsaneStats_GetAttributeValue("cosmicurse")-1)
					end

					effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("shock_damage")
					effectDamage = effectDamage * vic:InsaneStats_GetAttributeValue("shock_damagetaken")
					effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("explode_damage")
					effectDamage = effectDamage * vic:InsaneStats_GetAttributeValue("explode_damagetaken")

					if shouldCosmicurse then
						effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("poison_damage")
						effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("bleed_damage")
						effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("fire_damage")
						effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("freeze_damage")
						effectDamage = effectDamage * vic:InsaneStats_GetAttributeValue("poison_damagetaken")
						effectDamage = effectDamage * vic:InsaneStats_GetAttributeValue("bleed_damagetaken")
						effectDamage = effectDamage * vic:InsaneStats_GetAttributeValue("fire_damagetaken")
						effectDamage = effectDamage * vic:InsaneStats_GetAttributeValue("freeze_damagetaken")
					end
					
					if hasElectroblast then
						vic:InsaneStats_ApplyStatusEffect("electroblast", effectDamage, 5, {extend = 5, attacker = attacker})
					else
						vic:InsaneStats_ApplyStatusEffect("cosmicurse", effectDamage, 5, {extend = 5, attacker = attacker})
					end
				end
				
				if damageTier < 5 then
					local effectDamage = damage*(attacker:InsaneStats_GetAttributeValue("repeat1s_damage")-1)
					vic:InsaneStats_ApplyStatusEffect("doom", effectDamage, 1, {amplify = true, attacker = attacker})
				end
				
				-- redamage effects
				if vic:InsaneStats_GetAttributeValue("retaliation10_damage") ~= 1 then
					if vic:InsaneStats_GetStatusEffectLevel("retaliation10_buildup") < 9 then
						vic:InsaneStats_ApplyStatusEffect("retaliation10_buildup", 1, 5, {amplify = true})
					elseif not neverReflectDamageClasses[attacker:GetClass()] then
						-- reflecting stalker attacks will result in INSTANT CTD
						vic:InsaneStats_ClearStatusEffect("retaliation10_buildup")
						
						local scaleFactor = vic:InsaneStats_GetAttributeValue("retaliation10_damage") - 1
						local oldAttacker = attacker
						
						dmginfo:SetAttacker(vic)
						dmginfo:ScaleDamage(scaleFactor)
						oldAttacker:TakeDamageInfo(dmginfo)
						dmginfo:ScaleDamage(1/scaleFactor)
						dmginfo:SetAttacker(oldAttacker)
					end
				end
				
				if vicIsMob and notImmune and vic:GetClass() ~= "npc_turret_floor" then
					if vic.insaneStats_LastHitGroup == HITGROUP_HEAD then
						local healthFactor = attacker:InsaneStats_GetMaxHealth() > 0
						and 1 - math.Clamp(attacker:InsaneStats_GetHealth() / attacker:InsaneStats_GetMaxHealth(), 0, 1)
						or 0
						local lifeSteal = (
							attacker:InsaneStats_GetAttributeValue("crit_lifesteal") - 1
						) * attacker:InsaneStats_GetMaxHealth()
						
						if attacker:InsaneStats_GetStatusEffectLevel("bleed") > 0
						or attacker:InsaneStats_GetStatusEffectLevel("hemotoxin") > 0
						or attacker:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
							lifeSteal = lifeSteal / 2
						end
						
						attacker:InsaneStats_AddHealthCapped(lifeSteal)
						
						local armorSteal = (attacker:InsaneStats_GetAttributeValue("crit_armorsteal") - 1) * attacker:InsaneStats_GetMaxArmor()
						
						if attacker:InsaneStats_GetStatusEffectLevel("shock") > 0
						or attacker:InsaneStats_GetStatusEffectLevel("electroblast") > 0
						or attacker:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
							armorSteal = armorSteal / 2
						end
						
						attacker:InsaneStats_AddArmorNerfed(armorSteal)
						
						local stacks = (attacker:InsaneStats_GetAttributeValue("critstack_damage") - 1) * 100
						attacker:InsaneStats_ApplyStatusEffect("stack_damage_up", stacks, math.huge, {amplify = true})
						stacks = (attacker:InsaneStats_GetAttributeValue("critstack_firerate") - 1) * 100
						attacker:InsaneStats_ApplyStatusEffect("stack_firerate_up", stacks, math.huge, {amplify = true})
					end
					
					if attacker:InsaneStats_GetAttributeValue("hit100_damagepulse") ~= 1 then
						if attacker:InsaneStats_GetStatusEffectLevel("hit100_damagepulse_stacks") < 99 then
							attacker:InsaneStats_ApplyStatusEffect("hit100_damagepulse_stacks", 1, math.huge, {amplify = true})
						else
							local damage = attacker:InsaneStats_GetAttributeValue("hit100_damagepulse") - 1
							local dmginfo = DamageInfo()
							dmginfo:SetAttacker(attacker)
							dmginfo:SetInflictor(attacker)
							dmginfo:SetBaseDamage(damage)
							dmginfo:SetDamage(damage)
							dmginfo:SetMaxDamage(damage)
							dmginfo:SetDamageForce(vector_origin)
							dmginfo:SetDamageType(bit.bor(DMG_SONIC, DMG_ENERGYBEAM))
							dmginfo:SetReportedPosition(attacker:WorldSpaceCenter())
							
							local traceResult = {}
							local trace = {
								start = attacker:WorldSpaceCenter(),
								filter = {attacker, attacker.GetVehicle and attacker:GetVehicle()},
								mask = MASK_SHOT_HULL,
								output = traceResult
							}
							
							local success = false
							for k,v in pairs(ents.FindInPVS(attacker)) do
								if v ~= attacker and not attacker:InsaneStats_IsValidAlly(v) then
									local damagePos = v:HeadTarget(attacker:WorldSpaceCenter()) or v:WorldSpaceCenter()
									damagePos = damagePos:IsZero() and v:WorldSpaceCenter() or damagePos
									trace.endpos = damagePos
									util.TraceLine(trace)
									if not traceResult.Hit or traceResult.Entity == v then
										success = true
										attacker:InsaneStats_ClearStatusEffect("hit100_damagepulse_stacks")
										dmginfo:SetDamagePosition(damagePos)
										v:TakeDamageInfo(dmginfo)
									end
								end
							end

							if success then 
								attacker:InsaneStats_ClearStatusEffect("hit100_damagepulse_stacks")
								attacker:EmitSound("ambient/energy/whiteflash.wav", 100, 100, 1, CHAN_WEAPON)
							end
						end
					end
				
					if attacker:InsaneStats_GetAttributeValue("hit100_self_damage") ~= 1 then
						if attacker:InsaneStats_GetStatusEffectLevel("hit100_selfdamage_stacks") < 99 then
							attacker:InsaneStats_ApplyStatusEffect("hit100_selfdamage_stacks", 1, 5, {amplify = true})
						else
							attacker:InsaneStats_ClearStatusEffect("hit100_selfdamage_stacks")
							
							local scaleFactor = attacker:InsaneStats_GetAttributeValue("hit100_self_damage") - 1
							dmginfo:ScaleDamage(scaleFactor)
							attacker:TakeDamageInfo(dmginfo)
							dmginfo:ScaleDamage(1/scaleFactor)
						end
					end
				
					if attacker:InsaneStats_GetAttributeValue("hit1s_damage") ~= 1 and attacker:InsaneStats_GetStatusEffectLevel("hit1s_damage_cooldown") <= 0 then
						attacker:InsaneStats_ApplyStatusEffect("hit1s_damage_cooldown", 1, 1)
					end
					if vic:InsaneStats_GetAttributeValue("hittaken1s_damagetaken") ~= 1 and vic:InsaneStats_GetStatusEffectLevel("hittaken1s_damagetaken_cooldown") <= 0 then
						vic:InsaneStats_ApplyStatusEffect("hittaken1s_damagetaken_cooldown", 1, 1)
					end
				end
			end
		end

		-- SKILLS
		if IsValid(attacker) and IsValid(vic) then
			if vic:InsaneStats_HasSkill("ubercharge")
			and vic:InsaneStats_GetSkillState("ubercharge") == 0 then
				vic:InsaneStats_SetSkillData("ubercharge", 1, 10)
			end

			if attacker ~= vic and not IsValid(vic:GetParent()) then
				if (vic:InsaneStats_GetStatusEffectLevel("skill_bleed") <= 0 or damageTier < 0.5)
				and attacker:InsaneStats_HasSkill("the_red_plague")
				and IsValid(vic:GetPhysicsObject()) then
					vic:InsaneStats_ApplyStatusEffect(
						"skill_bleed",
						1,
						attacker:InsaneStats_GetSkillValues("the_red_plague"),
						{attacker = attacker}
					)
				end
			end

			if vicIsMob and notImmune and vic:GetClass() ~= "npc_turret_floor" then
				if vic.insaneStats_LastHitGroup == HITGROUP_HEAD then
					local healthFactor = attacker:InsaneStats_GetMaxHealth() > 0
					and 1 - math.Clamp(attacker:InsaneStats_GetHealth() / attacker:InsaneStats_GetMaxHealth(), 0, 1)
					or 0
					local lifeSteal = (
						attacker:InsaneStats_GetSkillValues("desperate_harvest") / 100 * healthFactor
					) * attacker:InsaneStats_GetMaxHealth()
					
					if attacker:InsaneStats_GetStatusEffectLevel("bleed") > 0
					or attacker:InsaneStats_GetStatusEffectLevel("hemotoxin") > 0
					or attacker:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
						lifeSteal = lifeSteal / 2
					end
					
					attacker:InsaneStats_AddHealthNerfed(lifeSteal)
				end

				if dmginfo:IsExplosionDamage() then
					attacker:InsaneStats_AddHealthNerfed(
						attacker:InsaneStats_GetMaxHealth() * attacker:InsaneStats_GetSkillValues("kablooey", 2) / 100
					)
					--[[if vic:InsaneStats_GetSkillTier("blast_proof_suit") > 5 then
						vic:InsaneStats_AddHealthNerfed(vic:InsaneStats_GetMaxHealth() * 0.01)
					end]]
				end
			end
		end
	end
end)

hook.Add("ScaleNPCDamage", "InsaneStatsWPASS2", function(vic, hitgroup, dmginfo)
	vic.insaneStats_LastHitGroup = hitgroup
	vic.insaneStats_LastHitGroupUpdate = engine.TickCount()
end)

hook.Add("ScalePlayerDamage", "InsaneStatsWPASS2", function(vic, hitgroup, dmginfo)
	vic.insaneStats_LastHitGroup = hitgroup
	vic.insaneStats_LastHitGroupUpdate = engine.TickCount()
end)

local color_red = Color(255, 0, 0)
local color_yellow = Color(255, 255, 0)
local color_green = Color(0, 255, 0)
local color_aqua = Color(0, 255, 255)
local function CalculateAimbotPosition(ent, sourcePos)
	local pos = ent:HeadTarget(sourcePos)

	if not (pos and not pos:IsZero()) then
		pos = ent:WorldSpaceCenter()
	end

	for i=1, ent:GetHitBoxCount(0) do
		if ent:GetHitBoxHitGroup(i, 0) == HITGROUP_HEAD then
			pos = ent:GetBonePosition(ent:GetHitBoxBone(i, 0))
		end
	end

	return pos
end
hook.Add("EntityFireBullets", "InsaneStatsWPASS2", function(attacker, data)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local shouldAimbot = math.random() + 1 < attacker:InsaneStats_GetAttributeValue("aimbot")
		or math.random() * 100 < attacker:InsaneStats_GetSkillValues("aimbot")
		if shouldAimbot then
			local bestNPC = NULL
			local bestCos = 0
			local traceResult = {}
			local trace = {
				start = attacker.GetShootPos and attacker:GetShootPos() or data.Src,
				filter = {attacker, attacker.GetVehicle and attacker:GetVehicle()},
				mask = MASK_SHOT,
				output = traceResult
			}
			
			-- get every NPC who hates us / entities we hate on the map
			for k,v in pairs(entities) do
				if attacker:InsaneStats_IsValidEnemy(k) then
					local bulletDir = data.Dir
					if bulletDir:LengthSqr() ~= 1 and not bulletDir:IsZero() then
						-- normalize the direction or it will mess up our calculations
						bulletDir:Normalize()
					end
					
					--local allegedHeadTarget = k:HeadTarget(data.Src) or k:WorldSpaceCenter()
					--local endPos = allegedHeadTarget:IsZero() and k:WorldSpaceCenter() or allegedHeadTarget
					local endPos = CalculateAimbotPosition(k, data.Src)
					local desiredDir = endPos - data.Src
					desiredDir:Normalize()
					
					local desiredCos = desiredDir:Dot(bulletDir)
					if desiredCos > bestCos then
						-- hold that thought, we need to make sure the bullet can actually travel through that direction and hit the enemy
						trace.endpos = endPos
						trace.endpos:Mul(2)
						trace.endpos:Sub(trace.start)
						debugoverlay.Cross(endPos, 10, 2, color_aqua, true)
						util.TraceLine(trace)

						local hitEntity = traceResult.Entity
						if hitEntity == k then
							bestNPC = k
							bestCos = desiredCos
						--[[elseif GetConVar("developer"):GetInt() > 0 then
							InsaneStats:Log(string.format(
								"Wanted to aimbot %s but bullet was stopped:",
								tostring(k)
							))
							PrintTable(traceResult)]]
						end
					end
				end
			end
			
			if IsValid(bestNPC) then
				--local allegedHeadTarget = bestNPC:HeadTarget(data.Src) or bestNPC:WorldSpaceCenter()
				--local endPos = allegedHeadTarget:IsZero() and bestNPC:WorldSpaceCenter() or allegedHeadTarget
				local endPos = CalculateAimbotPosition(bestNPC, data.Src)
				debugoverlay.Cross(endPos, 10, 2, color_red, true)
				data.Dir = endPos - data.Src
				data.Dir:Normalize()
			end
		end
		
		local explodeCondition = damageTiers[#damageTiers] < 1
		local shouldExplode = math.random() < attacker:InsaneStats_GetAttributeValue("explode") - 1
		local shouldElectroblast = math.random() < attacker:InsaneStats_GetAttributeValue("electroblast") - 1
		local shouldCosmicurse = attacker:InsaneStats_GetAttributeValue("cosmicurse") > 1
		local shouldSkillExplode = attacker:InsaneStats_HasSkill("brilliant_behemoth")
		and attacker:InsaneStats_GetSkillState("brilliant_behemoth") == 1
		
		if explodeCondition and (shouldExplode or shouldElectroblast or shouldCosmicurse or shouldSkillExplode) then
			local oldCallback = data.Callback
			data.Callback = function(attacker, trace, dmginfo, ...)
				if oldCallback then
					oldCallback(attacker, trace, dmginfo, ...)
				end
				
				if trace.Hit then
					if shouldExplode or shouldElectroblast or shouldCosmicurse then
						CauseDelayedDamage({
							pos = trace.HitPos,
							attacker = attacker,
							victim = trace.Entity,
							damage = dmginfo:GetDamage(),
							damageTier = 1,
							shouldExplode = shouldExplode,
							shouldElectroblast = shouldElectroblast,
							shouldCosmicurse = shouldCosmicurse
						})
					end
					if shouldSkillExplode then
						CauseExplosion({
							attacker = attacker,
							damageTier = 1,
							damage = dmginfo:GetDamage(),
							damagePos = trace.HitPos,
							damageType = DMG_BLAST,
							radius = attacker:InsaneStats_GetSkillValues(
								"brilliant_behemoth", 2
							),
							isSkillExplosion = true
						})
					end
				end
			end
		end
	end
end)

local function CalculateXPFromSkills(attacker, victim)
	local healthFactor = attacker:InsaneStats_GetMaxHealth() > 0
	and 1 - math.Clamp(attacker:InsaneStats_GetHealth() / attacker:InsaneStats_GetMaxHealth(), 0, 1)
	or 0
	local attackerSpeedFraction = attacker:GetVelocity():Length() / 400

	local newXP = (1 + attacker:InsaneStats_GetSkillValues("quintessence", 4) / 100)
	* (1 + attacker:InsaneStats_GetSkillValues("xp") / 100)
	* (1 + attacker:InsaneStats_GetSkillValues("guilt") / 100)
	* (1 + attacker:InsaneStats_GetSkillStacks("mania")/100)
	* (1 + attacker:InsaneStats_GetSkillValues("risk_reward") / 100 * healthFactor)
	* (1 + attacker:InsaneStats_GetSkillValues("jazz_feet") / 100 * attackerSpeedFraction)
	* (1 + attacker:InsaneStats_GetSkillValues("super_cold") / 100 * attacker:InsaneStats_GetSkillStacks("super_cold"))
	* (1 + attacker:InsaneStats_GetStatusEffectLevel("skill_xp_up") / 100)

	local masterfulXPFactor = attacker:InsaneStats_GetSkillStacks("multi_killer")
	masterfulXPFactor = math.max(0, masterfulXPFactor - attacker:InsaneStats_GetSkillValues("multi_killer"))
	newXP = newXP * (1 + math.sqrt(masterfulXPFactor))

	if attacker:InsaneStats_GetSkillStacks("back_to_back") > 0 then
		newXP = newXP * (1 + attacker:InsaneStats_GetSkillValues("back_to_back") / 100)
	end
	if victim.insaneStats_LastHitGroup == HITGROUP_HEAD then
		newXP = newXP
		* (1 + attacker:InsaneStats_GetSkillValues("be_efficient") / 100)
		* (1 + attacker:InsaneStats_GetStatusEffectLevel("skill_crit_xp_up") / 100)
	end
	if (attacker:IsPlayer() and attacker:GetSuitPower() >= 100) then
		newXP = newXP * (1 + attacker:InsaneStats_GetSkillValues("aux_aux_battery") / 100)
	end

	return newXP
end

local function CalculateXP(data)
	local attacker = data.attacker
	local victim = data.victim
	
	local newXP = attacker:InsaneStats_GetAttributeValue("xp")
	* (1 + attacker:InsaneStats_GetStatusEffectLevel("xp_up") / 100)
	* (1 + attacker:InsaneStats_GetStatusEffectLevel("stack_xp_up") / 100)

	local attackerArmorInverseFraction = attacker:InsaneStats_GetArmor() > 0
		and attacker:InsaneStats_GetArmor() / attacker:InsaneStats_GetMaxArmor() or 0
	newXP = newXP * (1 + (attacker:InsaneStats_GetAttributeValue("armor_xp") - 1) * attackerArmorInverseFraction)

	if victim.insaneStats_LastHitGroup == HITGROUP_HEAD then
		newXP = newXP * attacker:InsaneStats_GetAttributeValue("crit_xp")
	end

	local masterfulXPFactor = attacker:InsaneStats_GetStatusEffectDuration("masterful_xp")
	masterfulXPFactor = math.sqrt(math.max(0, masterfulXPFactor - 1))
	masterfulXPFactor = masterfulXPFactor * attacker:InsaneStats_GetStatusEffectLevel("masterful_xp") / 100
	newXP = newXP * (1 + masterfulXPFactor)

	local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon()
	if (IsValid(wep) and wep.Clip1) then
		local clip1 = wep:Clip1()
		local maxClip1 = wep:GetMaxClip1()
		local clip1Fraction = clip1 / maxClip1
		if maxClip1 <= 0 then
			clip1Fraction = 1
		end
		newXP = newXP * (1 + (attacker:InsaneStats_GetAttributeValue("clip_xp") - 1) * clip1Fraction)
	end

	return newXP * CalculateXPFromSkills(attacker, victim)
end

hook.Add("InsaneStatsScaleXP", "InsaneStatsWPASS2", function(data)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local attacker = data.attacker
		local victim = data.victim
		local newXP = data.xp
		
		if IsValid(attacker) then
			if not victim:IsPlayer() then
				if victim:InsaneStats_IsMob() then
					if attacker:InsaneStats_IsValidAlly(victim) then
						newXP = newXP * (
							attacker:InsaneStats_GetAttributeValue("ally_xp")
							+ (attacker:InsaneStats_HasSkill("guilt") and -2 or 0)
						)
					end
				else
					newXP = newXP * (
						attacker:InsaneStats_GetAttributeValue("prop_xp") - 1
						+ attacker:InsaneStats_GetSkillValues("target_practice") / 100
					)
				end
			end

			newXP = newXP * CalculateXP(data)
		end
		data.xp = newXP

		for k,v in pairs(entities) do
			local rewardXP = k:InsaneStats_GetAttributeValue("else_xp") - 1
			+ k:InsaneStats_GetSkillValues("consolation_prize") / 100
	
			if isMultiplayer and k:InsaneStats_IsValidAlly(attacker) then
				rewardXP = rewardXP + k:InsaneStats_GetSkillValues("aint_got_time_for_this") / 100
			end
			if (IsValid(k) and rewardXP > 0 and not data.receivers[k]) then
				data.receivers[k] = rewardXP * CalculateXPFromSkills(k, victim)
			end
		end
	end
end)

hook.Add("InsaneStatsScaleCoins", "InsaneStatsWPASS2", function(data)
	if IsValid(data.attacker) and IsValid(data.victim) then
		data.coins = data.coins * CalculateXP(data)
		data.coins = data.coins * (1 + data.attacker:InsaneStats_GetSkillValues("target_practice", 2) / 100)
	end
end)

local lastPlayersAmmoUpdate = 0
local cachedPlayersAmmo = {}
local keyValuesOrder = {
	"DesiredAmmoAR2",
	"DesiredAmmoAR2_AltFire",
	"DesiredAmmoPistol",
	"DesiredAmmoSMG1",
	"DesiredAmmo357",
	"DesiredAmmoCrossbow",
	"DesiredAmmoBuckshot",
	"DesiredAmmoRPG_Round",
	"DesiredAmmoSMG1_Grenade",
	"DesiredAmmoGrenade"
}
local possibleItems = {
	item_ammo_357 = true,
	item_ammo_ar2 = true,
	item_ammo_ar2_altfire = true,
	item_ammo_crossbow = true,
	item_ammo_pistol = true,
	item_ammo_smg1 = true,
	item_ammo_smg1_grenade = true,
	item_battery = true,
	item_box_buckshot = true,
	item_healthkit = true,
	item_healthvial = true,
	item_rpg_round = true,

	weapon_357 = true,
	weapon_alyxgun = true,
	weapon_annabelle = true,
	weapon_ar2 = true,
	weapon_crossbow = true,
	weapon_frag = true,
	weapon_pistol = true,
	weapon_rpg = true,
	weapon_shotgun = true,
	weapon_smg1 = true,
	weapon_stunstick = true
}
local function SpawnRandomItems(items, pos)
	if math.random() < items then
	--[[if math.random() < items%1 then
		items = math.ceil(items)
	else
		items = math.floor(items)
	end
	for i=1, items do]]
		local currentTick = engine.TickCount()
		local canAnyAmmo = false
		if lastPlayersAmmoUpdate ~= currentTick then
			lastPlayersAmmoUpdate = currentTick
			for i=1,9 do
				cachedPlayersAmmo[i] = false
				for j,v in player.Iterator() do
					if v:GetAmmoCount(i) > 0 then
						cachedPlayersAmmo[i] = true break
					end
				end
			end

			cachedPlayersAmmo[10] = false
			for i,v in player.Iterator() do
				if v:HasWeapon("weapon_grenade") then
					cachedPlayersAmmo[10] = true break
				end
				if v:InsaneStats_HasSkill("looting") or v:InsaneStats_HasSkill("fortune") then
					canAnyAmmo = true
				end
			end
		end

		local item = ents.Create("item_dynamic_resupply")
		item:SetKeyValue("DesiredHealth", string.format("%f", math.random()/16+0.9375))
		item:SetKeyValue("DesiredArmor", string.format("%f", math.random()/16+0.9375))
		for i,v in ipairs(keyValuesOrder) do
			item:SetKeyValue(
				v,
				(canAnyAmmo or cachedPlayersAmmo[i])
				and string.format("%f", math.random()/16+0.9375)
				or "0.0"
			)
		end
		item:SetKeyValue("spawnflags", 8)
		item:SetPos(pos)
		item:Spawn()

		local toDistribute = {}
		local plys = player.GetAll()
		for i,v in ents.Iterator() do
			local class = v:GetClass()
			if possibleItems[class] then
				if not v:CreatedByMap() and not IsValid(v:GetOwner())
				and not v:InsaneStats_GetEntityData("item_teleported") then
					table.insert(toDistribute, v)
				end
			end
		end

		if #toDistribute > 128 then
			-- distribute items randomly
			for i,v in ipairs(toDistribute) do
				v:InsaneStats_SetEntityData("item_teleported", true)
				v:SetPos(plys[math.random(#plys)]:WorldSpaceCenter())
			end
		end
	end
end

local killingSpreeEffects = {
	skill_damage_up = 25,
	skill_crit_damage_up = 50,
	skill_firerate_up = 25,
	skill_accuracy_up = 100,

	skill_defence_up = 25,
	skill_regen = 1,
	skill_armor_regen = 1,
	skill_absorption = 1,

	skill_knockback_resistance_up = 100,
	skill_xp_up = 25,
	skill_crit_xp_up = 25,
	skill_ammo_efficiency_up = 50
}

hook.Add("InsaneStatsEntityKilledOnce", "InsaneStatsSkills", function(victim, attacker, inflictor)
	if InsaneStats:GetConVarValue("skills_enabled") then
		local skillAttackers = {}
		if victim ~= attacker and IsValid(attacker) then
			table.insert(skillAttackers, attacker)
			if (attacker.GetDriver and IsValid(attacker:GetDriver())) then
				table.insert(skillAttackers, attacker:GetDriver())
			end
		end
		for k,v in pairs(InsaneStats:GetEntitiesWithSkills()) do
			local times = k:InsaneStats_GetSkillTier("celebration")
			if k == attacker then
				times = times - 1
			end
			for i=1, times do
				table.insert(skillAttackers, k)
			end
		end

		for i,v in ipairs(skillAttackers) do
			if v:InsaneStats_HasSkill("infusion") then
				v:SetMaxHealth(
					v:InsaneStats_GetMaxHealth() + v:InsaneStats_GetSkillValues("infusion", 2)
				)
			end

			if v:InsaneStats_HasSkill("additional_pylons") then
				local maxArmor = v:InsaneStats_GetSkillValues("additional_pylons", 2)
				-- if insaneStats_CurrentArmorAdd is nil, define it
				-- so that the level system doesn't assume the already level-scaled armor to be starting armor
				if not v:InsaneStats_GetEntityData("xp_armor_mul") and maxArmor > 0 then
					v:InsaneStats_SetCurrentArmorAdd(maxArmor * 5000 / v:InsaneStats_GetSkillTier("additional_pylons"))
				end

				v:SetMaxArmor(
					v:InsaneStats_GetMaxArmor() + maxArmor
				)
			end

			local halveHealthGains = v:InsaneStats_GetStatusEffectLevel("bleed") > 0
				or v:InsaneStats_GetStatusEffectLevel("hemotoxin") > 0
				or v:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0
		
			healthRestored = v:InsaneStats_GetSkillValues("overheal") / 100 * v:InsaneStats_GetMaxHealth()
			if halveHealthGains then
				healthRestored = healthRestored / 2
			end
			v:InsaneStats_AddHealthNerfed(healthRestored)

			local armorRestored = v:InsaneStats_GetSkillValues("overcharge") / 100
			* v:InsaneStats_GetMaxArmor()
					
			if v:InsaneStats_GetStatusEffectLevel("shock") > 0
			or v:InsaneStats_GetStatusEffectLevel("electroblast") > 0
			or v:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
				armorRestored = armorRestored / 2
			end

			v:InsaneStats_AddArmorNerfed(armorRestored)
			
			local stacks = v:InsaneStats_GetSkillValues("multi_killer")
			v:InsaneStats_SetSkillData("multi_killer", 1, stacks + v:InsaneStats_GetSkillStacks("multi_killer"))

			if v:InsaneStats_HasSkill("rip_and_tear") then
				v:InsaneStats_SetSkillData("rip_and_tear", 1, 10)
			end
			if v:InsaneStats_HasSkill("back_to_back") then
				v:InsaneStats_SetSkillData("back_to_back", 1, 10)
			end
			if v:InsaneStats_HasSkill("embolden") then
				v:InsaneStats_SetSkillData("embolden", 1, 10)
			end
			if v:InsaneStats_HasSkill("hunting_spirit") then
				v:InsaneStats_SetSkillData("hunting_spirit", 1, 10)
			end
			if v:InsaneStats_HasSkill("skip_the_scenery") then
				v:InsaneStats_SetSkillData("skip_the_scenery", -1, 10)
			end
			if v:InsaneStats_HasSkill("increase_the_pressure") then
				v:InsaneStats_SetSkillData(
					"increase_the_pressure",
					1,
					v:InsaneStats_GetSkillStacks("increase_the_pressure")
					+ v:InsaneStats_GetSkillValues("increase_the_pressure")
				)
			end
			if v:InsaneStats_HasSkill("mania") then
				v:InsaneStats_SetSkillData(
					"mania",
					1,
					v:InsaneStats_GetSkillStacks("mania")
					+ v:InsaneStats_GetSkillValues("mania")
				)
			end
			if v:InsaneStats_HasSkill("starlight") then
				local newStacks = math.min(
					1000,
					v:InsaneStats_GetSkillStacks("starlight")
					+ v:InsaneStats_GetSkillValues("starlight")
				)
				v:InsaneStats_SetSkillData("starlight", 1, newStacks)
			end

			if v:IsPlayer() then
				SpawnRandomItems(v:InsaneStats_GetSkillValues("looting") / 100, victim:WorldSpaceCenter())
				if v:InsaneStats_HasSkill("productivity") then
					local wep = v:GetActiveWeapon()
					if IsValid(wep) then
						local ammoMul = v:InsaneStats_GetSkillValues("productivity", 2) / 100
						local maxClip1 = wep:GetMaxClip1()
						local maxClip2 = wep:GetMaxClip2()
						local ammoType1 = wep:GetPrimaryAmmoType()
						local ammoType2 = wep:GetSecondaryAmmoType()

						local clip1ToAdd = 0
						local clip2ToAdd = 0

						if maxClip1 > 0 then
							clip1ToAdd = maxClip1
						elseif ammoType1 > 0 then
							clip1ToAdd = game.GetAmmoMax(ammoType1) / 3
						end
						if maxClip2 > 0 then
							clip2ToAdd = maxClip2
						elseif ammoType2 > 0 then
							clip2ToAdd = game.GetAmmoMax(ammoType2) / 3
						end

						clip1ToAdd = clip1ToAdd * ammoMul
						clip2ToAdd = clip2ToAdd * ammoMul

						clip1ToAdd = math[math.random() < clip1ToAdd % 1 and "ceil" or "floor"](clip1ToAdd)
						clip2ToAdd = math[math.random() < clip2ToAdd % 1 and "ceil" or "floor"](clip2ToAdd)

						if clip1ToAdd > 0 then
							if maxClip1 > 0 then
								wep:SetClip1(wep:Clip1() + clip1ToAdd)
							else
								v:GiveAmmo(clip1ToAdd, ammoType1)
							end
						end
						if clip2ToAdd > 0 then
							if maxClip2 > 0 then
								wep:SetClip2(wep:Clip2() + clip2ToAdd)
							else
								v:GiveAmmo(clip2ToAdd, ammoType2)
							end
						end
					end
				end
			end

			if v:InsaneStats_HasSkill("killing_spree") then
				v:InsaneStats_ApplyStatusEffect(
					"killing_spree",
					v:InsaneStats_GetSkillTier("killing_spree"),
					60,
					{amplify = true}
				)

				local effectsToApply = math.log(v:InsaneStats_GetStatusEffectLevel("killing_spree"), 5)
				local possibleEffects = table.GetKeys(killingSpreeEffects)
				for i=1, effectsToApply do
					if table.IsEmpty(possibleEffects) then break end
					local effect = table.remove(possibleEffects, math.random(#possibleEffects))
					local effectLevel = killingSpreeEffects[effect] * effectsToApply
					v:InsaneStats_ApplyStatusEffect(effect, effectLevel, 10)
				end
			end
		end
	end

	if attacker.insaneStats_MarkedEntity == victim then
		timer.Simple(0, function()
			if IsValid(attacker) then
				local shouldMark = attacker:InsaneStats_GetAttributeValue("mark") > 1
				or attacker:InsaneStats_HasSkill("alert")
				if shouldMark then
					-- choose a new entity
					local worldSpaceCenters = {}

					for k,v in pairs(rapidThinkEntities) do
						if IsValid(k) then
							worldSpaceCenters[k] = k:WorldSpaceCenter()
						end
					end
					
					local ourPos = attacker:WorldSpaceCenter()
					local bestDistance = math.huge

					for k,v in pairs(worldSpaceCenters) do
						if attacker:InsaneStats_IsValidEnemy(k) and k ~= victim then
							local thisEnemyDistance = ourPos:DistToSqr(v)
							
							if thisEnemyDistance < bestDistance then
								bestDistance = thisEnemyDistance
								attacker.insaneStats_MarkedEntity = k
							end
						end
					end

					if bestDistance < math.huge then
						local ent = attacker.insaneStats_MarkedEntity
						if attacker:IsPlayer() then
							local pos = ent:HeadTarget(attacker:GetShootPos()) or ent:WorldSpaceCenter()
							pos = pos:IsZero() and ent:WorldSpaceCenter() or pos
							-- send a net message about the current entity
							net.Start("insane_stats", true)
							net.WriteUInt(4, 8)
							net.WriteUInt(ent:EntIndex(), 16)
							net.WriteVector(pos)
							net.WriteString(ent:GetClass())
							net.WriteDouble(ent:InsaneStats_GetHealth())
							net.WriteDouble(ent:InsaneStats_GetMaxHealth())
							net.WriteDouble(ent:InsaneStats_GetArmor())
							net.WriteDouble(ent:InsaneStats_GetMaxArmor())
							net.Send(attacker)
						elseif (attacker:IsNPC() and attacker:Disposition(ent) == D_HT and attacker:HasEnemyEluded(ent)) then
							attacker:UpdateEnemyMemory(ent, ent:GetPos())
						end
					elseif IsValid(attacker.insaneStats_MarkedEntity) then
						attacker.insaneStats_MarkedEntity = NULL

						if attacker:IsPlayer() then
							net.Start("insane_stats")
							net.WriteUInt(4, 8)
							net.WriteUInt(0, 16)
							net.Send(attacker)
						end
					end
				end
			end
		end)
	end
end)

hook.Add("InsaneStatsEntityKilledOnce", "InsaneStatsWPASS2", function(victim, attacker, inflictor)
	if InsaneStats:GetConVarValue("wpass2_enabled") and IsValid(attacker) then
		if (attacker:IsVehicle() and attacker:IsValidVehicle() and IsValid(attacker:GetDriver())) then
			attacker = attacker:GetDriver()
		end

		if victim ~= attacker then
			local halveHealthGains = attacker:InsaneStats_GetStatusEffectLevel("bleed") > 0
				or attacker:InsaneStats_GetStatusEffectLevel("hemotoxin") > 0
				or attacker:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0
			
			local healthRestored = (
				attacker:InsaneStats_GetAttributeValue("kill_lifesteal") - 1
			) * attacker:InsaneStats_GetMaxHealth()
			if halveHealthGains then
				healthRestored = healthRestored / 2
			end
			attacker:InsaneStats_AddHealthCapped(healthRestored)
			--print(attacker:InsaneStats_GetHealth(), healthRestored, attacker:InsaneStats_GetMaxHealth())
			
			if attacker.GetMaxArmor then
				local armorRestored = (
					attacker:InsaneStats_GetAttributeValue("kill_armorsteal") - 1
				) * attacker:InsaneStats_GetMaxArmor()
						
				if attacker:InsaneStats_GetStatusEffectLevel("shock") > 0
				or attacker:InsaneStats_GetStatusEffectLevel("electroblast") > 0
				or attacker:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
					armorRestored = armorRestored / 2
				end

				attacker:InsaneStats_AddArmorNerfed(armorRestored)
			end
			
			local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon() or NULL
			local clipSteal = attacker:InsaneStats_GetAttributeValue("kill_clipsteal") - 1
			if IsValid(wep) and clipSteal ~= 0 then
				local ammoToGive1 = wep:GetMaxClip1() * clipSteal
				local ammoToGive2 = wep:GetMaxClip2() * clipSteal
				local clip1Used = wep:GetMaxClip1() > 0
				local clip2Used = wep:GetMaxClip2() > 0
				
				local isPlayer = attacker:IsPlayer()
				if not clip1Used and isPlayer and wep:GetPrimaryAmmoType() > 0 then
					ammoToGive1 = game.GetAmmoMax(wep:GetPrimaryAmmoType()) / 3 * clipSteal
				end
				if not clip2Used and isPlayer and wep:GetSecondaryAmmoType() > 0 then
					ammoToGive2 = game.GetAmmoMax(wep:GetSecondaryAmmoType()) / 3 * clipSteal
				end
				
				ammoToGive1 = ((math.random() < ammoToGive1 % 1) and math.ceil or math.floor)(ammoToGive1)
				ammoToGive2 = ((math.random() < ammoToGive2 % 1) and math.ceil or math.floor)(ammoToGive2)
				
				if clip1Used then
					wep:SetClip1(wep:Clip1()+ammoToGive1)
				elseif isPlayer then
					attacker:GiveAmmo(ammoToGive1, wep:GetPrimaryAmmoType())
				end
				
				if clip2Used then
					wep:SetClip2(wep:Clip2()+ammoToGive2)
				elseif isPlayer then
					attacker:GiveAmmo(ammoToGive2, wep:GetSecondaryAmmoType())
				end
			end
			
			local stacks = (attacker:InsaneStats_GetAttributeValue("killstack_damage") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("stack_damage_up", stacks, math.huge, {amplify = true})
			stacks = (attacker:InsaneStats_GetAttributeValue("killstack_defence") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("stack_defence_up", stacks, math.huge, {amplify = true})
			--[[stacks = (attacker:InsaneStats_GetAttributeValue("killstack_speed") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("stack_speed_up", stacks, math.huge, {amplify = true})]]
			stacks = (attacker:InsaneStats_GetAttributeValue("killstack_xp") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("stack_xp_up", stacks, math.huge, {amplify = true})
			stacks = (attacker:InsaneStats_GetAttributeValue("killstack_firerate") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("stack_firerate_up", stacks, math.huge, {amplify = true})
			
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill5s_damage") - 1) * 100
			--[[if stacks < 0 then
				attacker:InsaneStats_ApplyStatusEffect("damage_down", -stacks, 5, {extend = true})
			else]]
				attacker:InsaneStats_ApplyStatusEffect("damage_up", stacks, 5, {extend = true})
			--end
			
			stacks = (1 / attacker:InsaneStats_GetAttributeValue("kill5s_damagetaken") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("defence_up", stacks, 5, {extend = true})
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill5s_firerate") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("firerate_up", stacks, 5, {extend = true})
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill5s_xp") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("xp_up", stacks, 5, {extend = true})
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill5s_speed") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("speed_up", stacks, 5, {extend = true})
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill5s_regen") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("regen", stacks, 5, {extend = true})
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill5s_armorregen") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("armor_regen", stacks, 5, {extend = true})
			
			stacks = attacker:InsaneStats_GetAttributeValue("kill5s_damageaura") - 1
			attacker:InsaneStats_ApplyStatusEffect("damage_aura", stacks, 5, {extend = true})
			
			local duration = attacker:InsaneStats_GetAttributeValue("starlight") - 1
			attacker:InsaneStats_ApplyStatusEffect("starlight", 1, duration, {extend = true})
			
			if attacker:InsaneStats_IsValidAlly(victim) then
				stacks = (1 - attacker:InsaneStats_GetAttributeValue("kill5s_ally_damage")) * 100
				attacker:InsaneStats_ApplyStatusEffect("damage_down", stacks, 5, {extend = true})
			end
			
			if attacker.insaneStats_MarkedEntity == victim then
				stacks = (attacker:InsaneStats_GetAttributeValue("killstackmarked_damage") - 1) * 100
				attacker:InsaneStats_ApplyStatusEffect("stack_damage_up", stacks, math.huge, {amplify = true})
				stacks = (attacker:InsaneStats_GetAttributeValue("killstackmarked_defence") - 1) * 100
				attacker:InsaneStats_ApplyStatusEffect("stack_defence_up", stacks, math.huge, {amplify = true})
			end
			
			SpawnRandomItems(attacker:InsaneStats_GetAttributeValue("kill_supplychance") - 1, victim:WorldSpaceCenter())
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill1s_xp") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("masterful_xp", stacks, 1, {extend = true})
		end
	end
end)

hook.Add("InsaneStatsEntityKilledPostXP", "InsaneStatsSkills", function(victim, attacker, inflictor)
	if InsaneStats:GetConVarValue("skills_enabled") then
		local skillAttackers = {}
		if victim ~= attacker and IsValid(attacker) then
			table.insert(skillAttackers, attacker)
		end

		for k,v in pairs(InsaneStats:GetEntitiesWithSkills()) do
			local times = k:InsaneStats_GetSkillTier("celebration")
			if k == attacker then
				times = times - 1
			end
			for i=1, times do
				table.insert(skillAttackers, k)
			end
		end

		for i,v in ipairs(skillAttackers) do
			if v:InsaneStats_GetSkillState("fight_for_your_life") == 1 then
				v:InsaneStats_AddHealthNerfed(v:InsaneStats_GetMaxHealth())
				v:InsaneStats_SetSkillData("fight_for_your_life", 0, v.insaneStats_FFYLStacksAdd or 0)

				local name = v:GetName() ~= "" and v:GetName() or v:GetClass()
				PrintMessage(HUD_PRINTTALK, name.." is back up!")
			end
		end
	end
end)

hook.Add("InsaneStatsEntityKilledPostXP", "InsaneStatsWPASS2", function(victim, attacker, inflictor)
	if InsaneStats:GetConVarValue("wpass2_enabled") and IsValid(attacker) and IsValid(victim) then
		local damage = attacker:InsaneStats_GetStatusEffectLevel("death_promise")
		if damage > 0 then
			local damageOrigin = victim:WorldSpaceCenter()
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(attacker)
			dmginfo:SetInflictor(attacker)
			dmginfo:SetBaseDamage(damage)
			dmginfo:SetDamage(damage)
			dmginfo:SetMaxDamage(damage)
			dmginfo:SetDamageForce(vector_origin)
			dmginfo:SetDamageType(bit.bor(DMG_SONIC, DMG_ENERGYBEAM))
			dmginfo:SetReportedPosition(damageOrigin)
			
			local traceResult = {}
			local trace = {
				start = damageOrigin,
				filter = {victim, victim.GetVehicle and victim:GetVehicle()},
				mask = MASK_SHOT_HULL,
				output = traceResult
			}
			
			local success = false
			for k,v in pairs(ents.FindInPVS(damageOrigin)) do
				if v ~= attacker and not attacker:InsaneStats_IsValidAlly(v) then
					local damagePos = v:HeadTarget(damageOrigin) or v:WorldSpaceCenter()
					damagePos = damagePos:IsZero() and v:WorldSpaceCenter() or damagePos
					trace.endpos = damagePos
					util.TraceLine(trace)
					if not traceResult.Hit or traceResult.Entity == v then
						success = true
						attacker:InsaneStats_ClearStatusEffect("death_promise")
						dmginfo:SetDamagePosition(damagePos)
						v:TakeDamageInfo(dmginfo)
					end
				end
			end
			
			if success then
				local soundIndex = math.random() < 0.5 and 1 or 3
				victim:EmitSound(string.format("weapons/bugbait/bugbait_impact%u.wav", soundIndex), 100, 100, 1, CHAN_WEAPON)
			end
		end
	end
end)

local function AttemptDupeEntity(ply, item)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local itemHasNoModifiers = not item:InsaneStats_IsWPASS2Pickup() or (item.insaneStats_Tier or 0) == 0
		local ignoreWPASS2Pickup = (item.insaneStats_DisableWPASS2Pickup or 0) > RealTime()
		local itemPickupCooldownElapsed = (item.insaneStats_NextPickup or 0) < CurTime()
		
		if itemPickupCooldownElapsed then
			local class = item:GetClass()
			if not item.insaneStats_Duplicated and itemHasNoModifiers
			and (ply:InsaneStats_GetAttributeValue("copying") ~= 1
			or ply:InsaneStats_HasSkill("productivity"))
			and class ~= "item_suit" then
				-- do not duplicate if too many duplicates are within PVS
				local duplicates = {}
				for i,v in ipairs(ents.FindInPVS(item:WorldSpaceCenter())) do
					if v:GetClass() == class and v.insaneStats_Duplicated
					and not v:InsaneStats_GetEntityData("item_teleported") then
						table.insert(duplicates, v)
					end
				end
				if #duplicates < 16 then
					--[[-- try to remove random items if too many duplicates exist
					local otherItems = ents.FindByClass(class)
					for i=32, #otherItems do
						local randomItem = table.remove(otherItems, math.random(#otherItems))
						if randomItem.insaneStats_Duplicated and not IsValid(randomItem:GetOwner())
						and not randomItem:CreatedByMap() then
							SafeRemoveEntity(randomItem)
						end
					end]]
					item.insaneStats_Duplicated = true
					
					local duplicates = ply:InsaneStats_GetAttributeValue("copying") - 1 + ply:InsaneStats_GetSkillValues("productivity") / 100
					if math.random() < duplicates % 1 then
						duplicates = math.ceil(duplicates)
					else
						duplicates = math.floor(duplicates)
					end
					
					for i=1,duplicates do
						local itemDuplicate = ents.Create(class)
						itemDuplicate.insaneStats_Duplicated = true
						itemDuplicate:SetPos(item:GetPos())
						itemDuplicate:SetAngles(item:GetAngles())
						if class == "item_grubnugget" then
							itemDuplicate:SetSaveValue("m_nDenomination", item:GetInternalVariable("m_nDenomination"))
						end
						itemDuplicate.insaneStats_StartTier = 0
						itemDuplicate:Spawn()
						itemDuplicate:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
					end
				else
					for i,v in ipairs(duplicates) do
						v:InsaneStats_SetEntityData("item_teleported", true)
						v:SetPos(ply:WorldSpaceCenter())
						v.insaneStats_PreventMagnet = 100
					end
					return false
				end
			end
			
			local overLoadedArmor = (
				ply:InsaneStats_GetAttributeValue("armor_fullpickup") ~= 1
				and ply:InsaneStats_GetAttributeValue("armor_fullpickup")
				or 0
			) + (ply:InsaneStats_HasSkill("boundless_shield") and 1 or 0)
			
			if (class == "item_battery"
			or class == "weapon_stunstick" and ply:HasWeapon("weapon_stunstick")
			or class == "weapon_medkit" and ply:HasWeapon("weapon_medkit")) and overLoadedArmor > 0 then
				local shouldAutoPickup = true
				local autoPickup = ply:GetInfoNum("insanestats_wpass2_autopickup_battery_override", -1) or -1
				if autoPickup < 0 then
					autoPickup = InsaneStats:GetConVarValueDefaulted("wpass2_autopickup_battery", "wpass2_autopickup")
				end
				if autoPickup == 0 then shouldAutoPickup = false end

				local newTier = item.insaneStats_Tier or 0
				if newTier ~= 0 then
					if autoPickup == 1 then shouldAutoPickup = false end 
					local currentTier = ply.insaneStats_Tier or 0
					if newTier > currentTier and autoPickup < 6 then shouldAutoPickup = false
					elseif newTier == currentTier and autoPickup < 4 then shouldAutoPickup = false
					end
				end
				if shouldAutoPickup or ignoreWPASS2Pickup then
					if class == "weapon_medkit" then
						local expectedHealth = GetConVar("sk_healthkit"):GetFloat() * ply:InsaneStats_GetCurrentHealthAdd()
							
						if ply:InsaneStats_GetStatusEffectLevel("bleed") > 0
						or ply:InsaneStats_GetStatusEffectLevel("hemotoxin") > 0
						or ply:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
							expectedHealth = expectedHealth / 2
						end
						
						hook.Run("InsaneStatsPlayerPickedUpItem", ply, item)
						ply:InsaneStats_AddHealthNerfed(expectedHealth)
						
						ply:EmitSound("HealthKit.Touch")
						net.Start("insane_stats")
						net.WriteUInt(2, 8)
						net.WriteString("item_healthkit")
						net.Send(ply)
						item:Remove()
						
						return false
					else
						local expectedArmor = GetConVar("sk_battery"):GetFloat() * ply:InsaneStats_GetCurrentArmorAdd()
						* (class == "weapon_stunstick" and 0.5 or 1)

						if ply:InsaneStats_GetArmor() + expectedArmor > ply:InsaneStats_GetMaxArmor() then
							if ply:InsaneStats_GetArmor() < ply:InsaneStats_GetMaxArmor() then
								expectedArmor = expectedArmor + ply:InsaneStats_GetArmor() - ply:InsaneStats_GetMaxArmor()
								ply:SetArmor(ply:InsaneStats_GetMaxArmor())
							end
							
							expectedArmor = expectedArmor * overLoadedArmor
							
							if ply:InsaneStats_GetStatusEffectLevel("shock") > 0
							or ply:InsaneStats_GetStatusEffectLevel("electroblast") > 0
							or ply:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
								expectedArmor = expectedArmor / 2
							end
							
							hook.Run("InsaneStatsPlayerPickedUpItem", ply, item)
							ply:InsaneStats_AddArmorNerfed(expectedArmor)
							
							ply:EmitSound("ItemBattery.Touch")
							net.Start("insane_stats")
							net.WriteUInt(2, 8)
							net.WriteString(class)
							net.Send(ply)
							item:Remove()
							
							return false
						end
					end
				end
			end
		end
		item.insaneStats_PreventMagnet = (item.insaneStats_PreventMagnet or 0) + 1
	end
end

hook.Add("InsaneStatsPlayerCanPickupItem", "InsaneStatsWPASS2", AttemptDupeEntity)
hook.Add("InsaneStatsPlayerCanPickupWeapon", "InsaneStatsWPASS2", AttemptDupeEntity)

hook.Add("InsaneStatsPlayerPickedUpItem", "InsaneStatsWPASS2", function(ply, item)
	if InsaneStats:GetConVarValue("skills_enabled") and ply:InsaneStats_HasSkill("better_than_ever")
	and not item.insaneStats_GaveMax then
		local class = item:GetClass()
		
		if class == "item_healthkit" then
			ply:SetMaxHealth(ply:InsaneStats_GetMaxHealth() + ply:InsaneStats_GetSkillValues("better_than_ever", 3))
		elseif class == "item_battery" then
			ply:SetMaxArmor(ply:InsaneStats_GetMaxArmor() + ply:InsaneStats_GetSkillValues("better_than_ever", 4))
		end

		item.insaneStats_GaveMax = true
	end
end)

hook.Add("InsaneStatsArmorBatteryChanged", "InsaneStatsWPASS2", function(ent, item)
	item.insaneStats_Duplicated = true
end)

--local notAppliedForNonNPCs = bit.bor(DMG_SLOWBURN, DMG_NERVEGAS)
local function CauseStatusEffectDamage(data)
	local stat = data.stat
	local timerResolution = data.timerResolution
	for i, victim in ipairs(InsaneStats:GetEntitiesByStatusEffect(stat)) do
		local statLevel = victim:InsaneStats_GetStatusEffectLevel(stat)
		if victim:InsaneStats_GetHealth() > 0 then
			local damageType = victim:InsaneStats_IsMob() and bit.bor(data.damageType, DMG_PREVENT_PHYSICS_FORCE) or 0
			--print(stat, statLevel)
			table.insert(damageTiers, data.damageTier or 4)
			--PrintTable(data)
			local attacker = victim:InsaneStats_GetStatusEffectAttacker(stat)
			if not IsValid(attacker) then
				attacker = victim
			end
			local damage = statLevel * timerResolution * (data.damageMultiplier or 1)
			
			local dmginfo = DamageInfo()
			dmginfo:SetAmmoType(data.ammoType or -1)
			dmginfo:SetAttacker(attacker)
			dmginfo:SetBaseDamage(damage)
			dmginfo:SetDamage(damage)
			dmginfo:SetDamageForce(vector_origin)
			dmginfo:SetDamagePosition(victim:WorldSpaceCenter())
			dmginfo:SetDamageType(damageType)
			dmginfo:SetInflictor(attacker)
			dmginfo:SetMaxDamage(damage)
			dmginfo:SetReportedPosition(attacker:WorldSpaceCenter())
			victim:TakeDamageInfo(dmginfo)
			
			table.remove(damageTiers)
		end
	end
end

local tickIndex = 0
local occupyRatio = 0.05
local timerResolution = 0.2
local decayRate = 0.99^timerResolution
local coins = {}
timer.Create("InsaneStatsWPASS2", timerResolution, 0, function()
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local startTime = SysTime()
		local timeIndex = {0, 0, 0}
		local tempTimeStart
		local isMultiplayer = not game.SinglePlayer()
		
		tickIndex = (tickIndex + 1) % 5
		tempTimeStart = SysTime()
		-- get all entities with regen
		local regenAmounts = {}
		for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("regen")) do
			regenAmounts[v] = v:InsaneStats_GetStatusEffectLevel("regen")
		end
		for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("skill_regen")) do
			regenAmounts[v] = v:InsaneStats_GetStatusEffectLevel("skill_regen")
		end
		for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("hittaken_regen")) do
			regenAmounts[v] = (regenAmounts[v] or 0) + v:InsaneStats_GetStatusEffectLevel("hittaken_regen")
		end

		timeIndex[1] = SysTime() - tempTimeStart
		tempTimeStart = SysTime()

		for k,v in pairs(InsaneStats:GetEntitiesWithSkills()) do
			local healthFactor = k:InsaneStats_GetMaxHealth() > 0
			and 1 - math.Clamp(k:InsaneStats_GetHealth() / k:InsaneStats_GetMaxHealth(), 0, 1)
			or 0

			regenAmounts[k] = (regenAmounts[k] or 0)
			+ k:InsaneStats_GetSkillValues("regeneration")
			+ k:InsaneStats_GetSkillValues("fall_to_rise_up") * healthFactor

			if (k:InsaneStats_HasSkill("aint_got_time_for_this")
			or k:InsaneStats_HasSkill("panic")) and isMultiplayer then
				local regenAmount = k:InsaneStats_GetSkillValues("aint_got_time_for_this", 2)
				for i,v2 in ipairs(ents.FindInSphere(k:WorldSpaceCenter(), 512)) do
					if k:InsaneStats_IsValidAlly(v2) and k ~= v2 then
						regenAmounts[v2] = (regenAmounts[v2] or 0)
						+ regenAmount
						+ k:InsaneStats_GetSkillValues("panic")
						* (
							v2:InsaneStats_GetMaxHealth() > 0
							and 1 - v2:InsaneStats_GetHealth() / v2:InsaneStats_GetMaxHealth()
							or 0
						)
					end
				end
			end
		end

		timeIndex[2] = SysTime() - tempTimeStart
		tempTimeStart = SysTime()

		for k,v in pairs(regenAmounts) do
			local healthRestored = v / 100 * k:InsaneStats_GetMaxHealth() * timerResolution
			
			if k:InsaneStats_GetStatusEffectLevel("bleed") > 0
			or k:InsaneStats_GetStatusEffectLevel("hemotoxin") > 0
			or k:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
				healthRestored = healthRestored / 2
			end
			
			k:InsaneStats_AddHealthCapped(healthRestored)
		end
		
		-- get all entities with armor regen
		regenAmounts = {}
		for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("armor_regen")) do
			regenAmounts[v] = v:InsaneStats_GetStatusEffectLevel("armor_regen")
		end
		for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("skill_armor_regen")) do
			regenAmounts[v] = v:InsaneStats_GetStatusEffectLevel("skill_armor_regen")
		end
		for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("hittaken_armorregen")) do
			regenAmounts[v] = (regenAmounts[v] or 0) + v:InsaneStats_GetStatusEffectLevel("hittaken_armorregen")
		end
		for k,v in pairs(regenAmounts) do
			local armorRestored = v / 100 * k:InsaneStats_GetMaxArmor() * timerResolution
			
			if k:InsaneStats_GetStatusEffectLevel("shock") > 0
			or k:InsaneStats_GetStatusEffectLevel("electroblast") > 0
			or k:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
				armorRestored = armorRestored / 2
			end
			
			k:InsaneStats_AddArmorNerfed(armorRestored)
		end
		
		for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("stack_damage_up")) do
			v:InsaneStats_SetStatusEffectLevel("stack_damage_up", v:InsaneStats_GetStatusEffectLevel("stack_damage_up") * decayRate)
		end
		for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("stack_defence_up")) do
			v:InsaneStats_SetStatusEffectLevel("stack_defence_up", v:InsaneStats_GetStatusEffectLevel("stack_defence_up") * decayRate)
		end
		for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("stack_xp_up")) do
			v:InsaneStats_SetStatusEffectLevel("stack_xp_up", v:InsaneStats_GetStatusEffectLevel("stack_xp_up") * decayRate)
		end
		for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("stack_firerate_up")) do
			v:InsaneStats_SetStatusEffectLevel("stack_firerate_up", v:InsaneStats_GetStatusEffectLevel("stack_firerate_up") * decayRate)
		end
		local starlightRadii = {}
		for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("starlight")) do
			if not v:GetNoDraw() then
				starlightRadii[v] = math.sqrt(v:InsaneStats_GetStatusEffectDuration("starlight")) * 32
			end
		end

		timeIndex[1] = SysTime() - tempTimeStart
		tempTimeStart = SysTime()

		for i,v in player.Iterator() do
			starlightRadii[v] = (starlightRadii[v] or 0) + v:InsaneStats_GetSkillStacks("starlight") * 4
		end

		timeIndex[2] = SysTime() - tempTimeStart
		tempTimeStart = SysTime()

		for k,v in pairs(starlightRadii) do
			if v > 0 then
				if not IsValid(k.insaneStats_Starlight) then
					-- we probably have just lost the pointer to it
					for i,v2 in ipairs(k:GetChildren()) do
						if v2.insaneStats_IsStarlight then
							k.insaneStats_Starlight = v2
						end
					end
				end
				if not IsValid(k.insaneStats_Starlight) then
					local light = ents.Create("light_dynamic")
					light:SetPos(k.GetShootPos and k:GetShootPos() or k:WorldSpaceCenter())
					light:SetParent(k)
					light:SetKeyValue("_light", "255 255 255")
					light:SetKeyValue("style", "12")
					light:Spawn()
					light.insaneStats_IsStarlight = true
					k.insaneStats_Starlight = light
				end
				k.insaneStats_Starlight:Fire("distance", v)
			elseif IsValid(k.insaneStats_Starlight) then
				SafeRemoveEntityDelayed(k.insaneStats_Starlight, 1)
			end
		end
		local magnetRadii = {}
		for i,v in player.Iterator() do
			local magnetRadius = v:InsaneStats_GetAttributeValue("magnet") - 1 + v:InsaneStats_GetSkillValues("item_magnet")
			if magnetRadius > 0 then
				magnetRadii[v] = magnetRadius
			end
		end
		for k,v in pairs(magnetRadii) do
			local traceResult = {}
			local trace = {
				start = k:WorldSpaceCenter(),
				filter = {k, k.GetVehicle and k:GetVehicle()},
				mask = MASK_PLAYERSOLID,
				output = traceResult
			}
			for i,v2 in ipairs(ents.FindInSphere(k:WorldSpaceCenter(), v)) do
				if v2:InsaneStats_IsItem() and not IsValid(v2:GetOwner())
				and (v2.insaneStats_PreventMagnet or 0) < 100
				and (not v2:InsaneStats_IsWPASS2Pickup() or (v2.insaneStats_Tier or 0) == 0) then
					local physObj = v2:GetPhysicsObject()
					if IsValid(physObj) then
						trace.endpos = v2:WorldSpaceCenter()
						util.TraceLine(trace)
						if not traceResult.Hit or traceResult.Entity == v2 then
							local dir = k:WorldSpaceCenter() - v2:WorldSpaceCenter()
							dir:Normalize()
							dir:Mul(512 + trace.endpos:Distance(trace.start) * 5)
							physObj:SetVelocity(dir)
							v2.insaneStats_PreventMagnet = (v2.insaneStats_PreventMagnet or 0) + 1
						end
					end
				end
			end
		end
		
		if tickIndex == 0 then
			CauseStatusEffectDamage({
				stat = "poison",
				damageType = DMG_NERVEGAS,
				timerResolution = timerResolution
			})
			CauseStatusEffectDamage({
				stat = "hemotoxin",
				damageType = bit.bor(DMG_NERVEGAS, DMG_SLASH),
				timerResolution = timerResolution
			})
			CauseStatusEffectDamage({
				stat = "cosmicurse",
				ammoType = 8,
				damageType = bit.bor(DMG_SLASH, DMG_SLOWBURN, DMG_BLAST, DMG_NERVEGAS, DMG_SONIC, DMG_VEHICLE, DMG_SHOCK, DMG_ENERGYBEAM),
				timerResolution = timerResolution
			})
		
			tempTimeStart = SysTime()
			coins = {}
			
			for k,v in pairs(entities) do
				if IsValid(k) then
					local class = k:GetClass()
					if class == "filter_activator_model" then
						local targetModel = k:GetInternalVariable("model")
						if targetModel ~= "" then
							for i,v in pairs(ents.FindByModel(targetModel)) do
								v:SetNWBool("insanestats_vital", true)
							end
						end
					elseif class == "filter_activator_name" then
						local targetName = k:GetInternalVariable("filtername")
						if targetName ~= "" then
							for i,v in pairs(ents.FindByName(targetName)) do
								v:SetNWBool("insanestats_vital", true)
							end
						end
					elseif class == "insanestats_coin" then
						table.insert(coins, k)
					elseif (k:GetModel() or "") == "" then
						entities[k] = nil
					end
				else
					entities[k] = nil
				end
			end
			
			for k,v in pairs(rapidThinkEntities) do
				if not IsValid(k) then
					rapidThinkEntities[k] = nil
				end
			end
			
			timeIndex[4] = SysTime() - tempTimeStart
		elseif tickIndex == 1 then
			CauseStatusEffectDamage({
				stat = "bleed",
				damageType = DMG_SLASH,
				timerResolution = timerResolution
			})
			CauseStatusEffectDamage({
				stat = "skill_bleed",
				damageType = DMG_SLASH,
				timerResolution = timerResolution,
				damageMultiplier = 100,
				damageTier = 0.5
			})
			
			for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("damage_aura")) do
				local damage = v:InsaneStats_GetStatusEffectLevel("damage_aura") * timerResolution * 5
				local dmginfo = DamageInfo()
				dmginfo:SetAttacker(v)
				dmginfo:SetInflictor(v)
				dmginfo:SetBaseDamage(damage)
				dmginfo:SetDamage(damage)
				dmginfo:SetMaxDamage(damage)
				dmginfo:SetDamageForce(vector_origin)
				dmginfo:SetDamageType(bit.bor(DMG_ENERGYBEAM, DMG_PREVENT_PHYSICS_FORCE))
				dmginfo:SetReportedPosition(v:WorldSpaceCenter())
				
				local traceResult = {}
				local trace = {
					start = v:WorldSpaceCenter(),
					filter = {v, v.GetVehicle and v:GetVehicle()},
					mask = MASK_SHOT,
					output = traceResult
				}
				
				for i,v2 in ipairs(ents.FindInSphere(v:WorldSpaceCenter(), 512)) do
					if v:InsaneStats_IsValidEnemy(v2) then
						local damagePos = v2:HeadTarget(v:WorldSpaceCenter()) or v2:WorldSpaceCenter()
						damagePos = damagePos:IsZero() and v2:WorldSpaceCenter() or damagePos
						trace.endpos = damagePos
						util.TraceLine(trace)
						if not traceResult.Hit or traceResult.Entity == v2 then
							dmginfo:SetDamagePosition(damagePos)
							v2:TakeDamageInfo(dmginfo)
						end
					end
				end
			end
		elseif tickIndex == 2 then
			CauseStatusEffectDamage({
				stat = "fire",
				ammoType = 8,
				damageType = DMG_SLOWBURN,
				timerResolution = timerResolution
			})
			CauseStatusEffectDamage({
				stat = "frostfire",
				damageType = bit.bor(DMG_SLOWBURN, DMG_VEHICLE),
				timerResolution = timerResolution
			})
		elseif tickIndex == 3 then
			CauseStatusEffectDamage({
				stat = "freeze",
				damageType = DMG_VEHICLE,
				timerResolution = timerResolution
			})
		elseif tickIndex == 4 then
			CauseStatusEffectDamage({
				stat = "shock",
				ammoType = 17,
				damageType = DMG_SHOCK,
				timerResolution = timerResolution
			})
			CauseStatusEffectDamage({
				stat = "electroblast",
				ammoType = 8,
				damageType = bit.bor(DMG_SHOCK, DMG_BLAST),
				timerResolution = timerResolution
			})
		end
		
		timeIndex[1] = SysTime() - tempTimeStart
		
		for k,v in pairs(rapidThinkEntities) do
			if IsValid(k) then
				tempTimeStart = SysTime()
			
				if k:InsaneStats_GetAttributeValue("toggle_damage") ~= 1
				and k:InsaneStats_GetStatusEffectLevel("arcane_defence_up") == 0
				and k:InsaneStats_GetStatusEffectLevel("arcane_damage_up") == 0 then
					local stacks = (k:InsaneStats_GetAttributeValue("toggle_damage")-1)*100
					k:InsaneStats_ApplyStatusEffect(math.random() < 0.5 and "arcane_defence_up" or "arcane_damage_up", stacks, 5)
				end
				if k.insaneStats_HoldingCtrl then
					local stacks = (k:InsaneStats_GetAttributeValue("ctrl_gamespeed") - 1) * 100 * timerResolution
					if stacks ~= 0 then
						k:InsaneStats_ApplyStatusEffect("ctrl_gamespeed_up", stacks, math.huge, {amplify = true})
					end
					stacks = (k:InsaneStats_GetAttributeValue("ctrl_defence") - 1) * 100 * timerResolution
					if stacks ~= 0 then
						k:InsaneStats_ApplyStatusEffect("ctrl_defence_up", stacks, math.huge, {amplify = true})
					end

					if not isMultiplayer and k:InsaneStats_HasSkill("aint_got_time_for_this")
					and k:InsaneStats_GetSkillState("aint_got_time_for_this") == 0 then
						k:InsaneStats_SetSkillData("aint_got_time_for_this", 1, 0)
					end
				else
					k:InsaneStats_ClearStatusEffect("ctrl_gamespeed_up")
					k:InsaneStats_ClearStatusEffect("ctrl_defence_up")
					if not isMultiplayer then
						k:InsaneStats_SetSkillData("aint_got_time_for_this", 0, 0)
					end
				end
				
				timeIndex[3] = timeIndex[3] + SysTime() - tempTimeStart
			end
		end
		
		tempTimeStart = SysTime()

		for k,v in pairs(InsaneStats:GetEntitiesWithSkills()) do
			local skillTime = k:InsaneStats_GetSkillStacks("sneak_100")
			if k:InsaneStats_GetSkillState("sneak_100", true) == 1 and skillTime <= 0 then
				k:RemoveFlags(FL_NOTARGET)
				k:AddFlags(FL_AIMTARGET)
				k:RemoveEffects(bit.bor(EF_NOSHADOW, EF_NODRAW, EF_NORECEIVESHADOW))
				k:InsaneStats_SetSkillData(
					"sneak_100",
					-1,
					k:InsaneStats_GetSkillValues("sneak_100", 2) + skillTime
				)
			end

			skillTime = k:InsaneStats_GetSkillStacks("ubercharge")
			if k:InsaneStats_GetSkillState("ubercharge", true) == 1 and skillTime <= 0 then
				k:InsaneStats_SetSkillData(
					"ubercharge",
					-1,
					k:InsaneStats_GetSkillValues("ubercharge") + skillTime
				)
			end

			skillTime = k:InsaneStats_GetSkillStacks("just_breathe")
			if k:InsaneStats_GetSkillState("just_breathe", true) == 1 and skillTime <= 0 then
				if not isMultiplayer then
					local newMovementValue = 1
					if not InsaneStats:GetConVarValue("wpass2_attributes_player_constant_speed") then
						newMovementValue = k:GetLaggedMovementValue() / (
							1 + k:InsaneStats_GetSkillValues("just_breathe", 3) / 100
						)
					end
					k:SetLaggedMovementValue(newMovementValue)
				end

				k:InsaneStats_SetSkillData(
					"just_breathe",
					-1,
					60 + skillTime
				)
			end

			skillTime = k:InsaneStats_GetSkillStacks("fight_for_your_life")
			if k:InsaneStats_GetSkillState("fight_for_your_life", true) == 1 and skillTime <= 0 then
				k:InsaneStats_SetSkillData("fight_for_your_life", 0, 0)
				if k:IsPlayer() then
					k:Kill()
				else
					k:Fire("SetHealth", "0")
				end
			end

			skillTime = k:InsaneStats_GetSkillStacks("anger")
			if k:InsaneStats_GetSkillState("anger", true) == 1 and skillTime <= 0 then
				k:InsaneStats_SetSkillData("anger", -1, 60)
			end

			if k:InsaneStats_HasSkill("super_cold") and isMultiplayer then
				local allies = -1
				for i,v2 in ipairs(ents.FindInSphere(k:WorldSpaceCenter(), 512)) do
					if k:InsaneStats_IsValidAlly(v2) then
						allies = allies + 1
					end
				end

				local nextState = allies > 0 and 1 or 0
				if k:InsaneStats_GetSkillStacks("super_cold") ~= allies
				or k:InsaneStats_GetSkillState("super_cold") ~= nextState then
					k:InsaneStats_SetSkillData("super_cold", nextState, allies)
				end
			end
		end
		
		timeIndex[2] = timeIndex[2] + SysTime() - tempTimeStart
		
		local processingTime = SysTime() - startTime
		local newResolution = math.max(processingTime / occupyRatio + timerResolution * 4, 0.5) / 5
		if newResolution ~= timerResolution then
			if GetConVar("developer"):GetInt() > 0 then
				if newResolution < timerResolution then
					InsaneStats:Log("WPASS2 timer interval reduced to "..(newResolution*1000).."ms.")
				else
					InsaneStats:Log("WPASS2 timer interval increased to "..(newResolution*1000).."ms due to lag.")
				end
			end
			timerResolution = newResolution
			decayRate = 0.99^timerResolution
			timer.Adjust("InsaneStatsWPASS2", newResolution)
		end

		--[[InsaneStats:Log("Time breakdown:")
		InsaneStats:Log("1: "..(timeIndex[1]*1000).."ms")
		InsaneStats:Log("2: "..(timeIndex[2]*1000).."ms")
		InsaneStats:Log("3: "..(timeIndex[3]*1000).."ms")]]
	end
end)

hook.Add("InsaneStatsWPASS2AttributesChanged", "InsaneStatsWPASS2", function(ent)
	local oldHealthMul = ent.insaneStats_WPASS2HealthMul or 1
	local oldArmorMul = ent.insaneStats_WPASS2ArmorMul or 1
	
	local newHealthMul = ent:InsaneStats_GetAttributeValue("health")
	local newArmorMul = ent:InsaneStats_GetAttributeValue("armor")
	
	local entNewMaxHealth = ent:InsaneStats_GetMaxHealth() * newHealthMul / oldHealthMul
	local entNewHealth = ent:InsaneStats_GetHealth() * newHealthMul / oldHealthMul
	local entNewMaxArmor = ent:InsaneStats_GetMaxArmor() * newArmorMul / oldArmorMul
	local entNewArmor = ent:InsaneStats_GetArmor() * newArmorMul / oldArmorMul
	
	ent:SetMaxHealth(entNewMaxHealth)
	ent:SetHealth(entNewHealth)
	if ent.SetArmor then
		ent:SetMaxArmor(entNewMaxArmor)
		ent:SetArmor(entNewArmor)
	end
	
	ent.insaneStats_WPASS2HealthMul = newHealthMul
	ent.insaneStats_WPASS2ArmorMul = newArmorMul
end)

hook.Add("InsaneStatsEntityCreated", "InsaneStatsWPASS2", function(ent)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		-- if a gib gets set on fire by an explosion, extinguish it
		local parent = ent:GetParent()
		if (ent:GetClass() == "entityflame" or ent:GetClass() == "env_entity_igniter") then
			--print("Something is on fire...", parent, IsValid(parent) and parent:GetCollisionGroup())
			if (IsValid(parent) and parent:GetCollisionGroup() == COLLISION_GROUP_DEBRIS and IsValid(parent.insaneStats_LastAttacker)) then
				parent:Extinguish()
			end
		end
	end
	
	entities[ent] = true
	if ent:InsaneStats_IsMob() then
		rapidThinkEntities[ent] = true
	end
	if IsValid(ent.insaneStats_Starlight) then
		ent.insaneStats_Starlight:Remove()
	end
	local class = ent:GetClass()
	if class == "momentary_rot_button" then
		ent:Fire("AddOutput", "Position !self:InsaneStatsInteraction::0:-1")
	--[[elseif class:StartsWith("trigger_") and ent:HasSpawnFlags(1) then
		ent:SetNoDraw(false)
		ent:SetRenderMode(10)]]
	elseif class == "func_breakable_surf" then
		ent:Fire("AddOutput", "OnBreak !self:InsaneStats_OnBreak::0:-1")
	end
	ent:InsaneStats_ClearAllStatusEffects()
end)

timer.Create("InsaneStatsWPASS2Look", 5, 0, function()
	local lookPositions = {}
	for i,v in ipairs(ents.FindByClass("trigger_look")) do
		local targetEnts = ents.FindByName(v:GetInternalVariable("target"))
		for i,v2 in pairs(targetEnts) do
			table.insert(lookPositions, v2:GetPos())
		end
	end
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		net.Start("insane_stats", true)
		net.WriteUInt(9, 8)
		net.WriteUInt(#lookPositions, 8)
		for i,v in ipairs(lookPositions) do
			net.WriteVector(v)
		end
		net.Broadcast()
	end
end)

--[[hook.Add("InsaneStatsEntityShouldBeAlpha", "InsaneStatsWPASS2", function(ent)
	if InsaneStats:GetConVarValue("skills_enabled") then
		for k,v in pairs(InsaneStats:GetEntitiesWithSkills()) do
			if k:InsaneStats_GetSkillTier("friendly_fire_off") > 1 and k:InsaneStats_IsValidAlly(ent) then
				return true
			end
		end
	end
end)]]

local function ProcessBreakEvent(victim, attacker)
	if not IsValid(attacker) then
		if IsValid(victim.insaneStats_LastAttacker) then
			attacker = victim.insaneStats_LastAttacker
		else
			attacker = game.GetWorld()
		end
	end
	
	--[[local physAttacker = attacker:GetPhysicsAttacker(5)
	if IsValid(physAttacker) then
		attacker = physAttacker
	end
	
	if IsValid(attacker.insaneStats_LastAttacker) then
		attacker = attacker.insaneStats_LastAttacker
	end]]
	
	if IsValid(attacker) and victim:GetCollisionGroup() ~= COLLISION_GROUP_DEBRIS
	and not victim.insaneStats_SuppressCoinDrops then
		hook.Run("InsaneStatsPropBroke", victim, attacker)
	end
end

hook.Add("InsaneStatsPropBroke", "InsaneStatsWPASS2", function(victim, attacker)
	local stacks = (attacker:InsaneStats_GetAttributeValue("kill1s_xp2") - 1) * 100
	attacker:InsaneStats_ApplyStatusEffect("masterful_xp", stacks, 1, {extend = true})
	stacks = attacker:InsaneStats_GetSkillValues("multi_killer")
	attacker:InsaneStats_SetSkillData("multi_killer", 1, stacks + attacker:InsaneStats_GetSkillStacks("multi_killer"))

	local duration = attacker:InsaneStats_GetAttributeValue("starlight") - 1
	attacker:InsaneStats_ApplyStatusEffect("starlight", 1, duration, {extend = true})
	
	local inflictor = attacker.GetActiveWeapon and attacker:GetActiveWeapon() or attacker
	local xpMul = InsaneStats:GetConVarValue("xp_other_mul")
	local currentHealthAdd = victim:InsaneStats_GetCurrentHealthAdd()
	local startingHealth = victim:InsaneStats_GetMaxHealth() / currentHealthAdd
	
	local data = {
		xp = startingHealth * xpMul / 5,
		attacker = attacker, inflictor = inflictor, victim = victim,
		receivers = {[attacker] = 1, [inflictor] = 1}
	}
	hook.Run("InsaneStatsScaleXP", data)
	
	local xpToGive = data.xp
	local xpDropMul = InsaneStats:GetConVarValue("xp_other_kill")
	
	for k,v in pairs(data.receivers) do
		if IsValid(k) then
			local xp = xpToGive * v
			if xp < -k:InsaneStats_GetXP() then
				xp = -k:InsaneStats_GetXP()
			end
			k:InsaneStats_AddXP(xp, xp*xpDropMul)
			k:InsaneStats_AddBatteryXP(xp)
			
			local wep = k.GetActiveWeapon and k:GetActiveWeapon()
			if IsValid(wep) and wep ~= inflictor then
				wep:InsaneStats_AddXP(xp, xp*xpDropMul)
				wep:InsaneStats_AddBatteryXP(xp)
			end
		end
	end
		
	SpawnRandomItems(attacker:InsaneStats_GetAttributeValue("prop_supplychance") - 1, victim:WorldSpaceCenter())
	SpawnRandomItems(attacker:InsaneStats_GetSkillValues("fortune") / 100, victim:WorldSpaceCenter())
end)

hook.Add("AcceptInput", "InsaneStatsWPASS2", function(ent, input, activator, caller, value)
	input = input:lower()
	if input == "insanestatsinteraction" then
		ent:SetNW2Float("insanestats_progress", tonumber(value) or 0)
	elseif input == "insanestats_onbreak" then
		ProcessBreakEvent(caller, activator)
	end
end)

hook.Add("EntityKeyValue", "InsaneStatsWPASS2", function(ent, key, value)
	key = key:lower()
	if key:StartWith("onplayeruse") or key:StartWith("oncacheinteraction") then
		ent:SetNWBool("insanestats_use", true)
		ent.insaneStats_PreventMagnet = 100
	elseif key:StartWith("onplayerpickup") then
		ent.insaneStats_PreventMagnet = 100
	end
end)

hook.Add("PlayerSpawn", "InsaneStatsWPASS2", function(ply, fromTransition)
	entities[ply] = true
	rapidThinkEntities[ply] = true
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		if fromTransition then
			ply:InsaneStats_ClearAllStatusEffects()
			ply:InsaneStats_ClearSkillData()
		else
			ply:InsaneStats_ClearStatusEffectsByType(-1)
			ply:InsaneStats_ClearStatusEffectsByType(1)
			ply:SetLadderClimbSpeed(200)
		
			ply.insaneStats_WPASS2HealthMul = 1
			ply.insaneStats_WPASS2ArmorMul = 1
		end
		
		ply.insaneStats_OldMoveMul = 1
		ply.insaneStats_OldSprintMoveMul = 1
		ply.insaneStats_OldCrouchedMoveMul = 1
		
		if ply:InsaneStats_GetStatusEffectLevel("invisibility") > 0
		or ply:InsaneStats_GetSkillState("sneak_100") == 1 then
			ply:AddFlags(FL_NOTARGET)
			ply:RemoveFlags(FL_AIMTARGET)
			ply:AddEffects(bit.bor(EF_NOSHADOW, EF_NODRAW, EF_NORECEIVESHADOW))
		end

		timer.Simple(1, function()
			if (
				IsValid(ply)
				and ply:InsaneStats_GetStatusEffectLevel("starlight") <= 0
				and ply:InsaneStats_GetSkillStacks("starlight") <= 0
			) then
				for i,v in ipairs(ply:GetChildren()) do
					if v.insaneStats_IsStarlight then
						SafeRemoveEntity(v)
					end
				end
			end
		end)

		ply:InsaneStats_SetSkillData("fight_for_your_life", 0, 0)
	end
	if IsValid(ply.insaneStats_Starlight) then
		ply.insaneStats_Starlight:Remove()
	end
end)

hook.Add("PlayerUse", "InsaneStatsWPASS2", function(ply, ent)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local overLoadedArmor = (
			ply:InsaneStats_GetAttributeValue("charger_fullpickup") ~= 1
			and ply:InsaneStats_GetAttributeValue("charger_fullpickup")
			or 0
		) + (ply:InsaneStats_GetSkillTier("boundless_shield") > 1 and 1 or 0)

		if (ent:GetClass() == "item_suitcharger" or ent:GetClass() == "func_recharge")
		and overLoadedArmor > 0
		and ply:InsaneStats_GetArmor() >= ply:InsaneStats_GetMaxArmor() then
			local armorToAdd = ent:GetInternalVariable("m_iJuice")
			* overLoadedArmor
			* ply:InsaneStats_GetCurrentArmorAdd()
			
			if ent:HasSpawnFlags(8192) then
				ply:SetHealth(ply:InsaneStats_GetHealth() + armorToAdd/2)
			end
				
			if ply:InsaneStats_GetStatusEffectLevel("shock") > 0
			or ply:InsaneStats_GetStatusEffectLevel("electroblast") > 0
			or ply:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
				armorToAdd = armorToAdd / 2
			end
			
			ply:InsaneStats_AddArmorNerfed(armorToAdd)
			
			ent:SetSaveValue("m_iJuice",0)
		end
	end
end)

local function bloodlet(ent)
	local bloodFrac = ent:InsaneStats_GetAttributeValue("bloodletting")
	if ent:InsaneStats_HasSkill("bloodletter_pact") then
		bloodFrac = math.min(bloodFrac, ent:InsaneStats_GetSkillValues("bloodletter_pact") / 100)
	end

	if bloodFrac ~= 1 and ent:InsaneStats_GetMaxArmor() > 0 then
		local minimumHealth = ent:InsaneStats_GetMaxHealth() * bloodFrac
		local lostHealth = math.ceil(ent:InsaneStats_GetHealth() - minimumHealth)
		local armorMul = 1
		
		if lostHealth > 0 then
			if ent:InsaneStats_GetStatusEffectLevel("shock") > 0
			or ent:InsaneStats_GetStatusEffectLevel("electroblast") > 0
			or ent:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
				armorMul = armorMul / 2
			end

			ent:InsaneStats_AddArmorNerfed(lostHealth * armorMul)
			if lostHealth < math.huge then
				ent:SetHealth(ent:InsaneStats_GetHealth() - lostHealth)
			end
		end
	end
end
hook.Add("InsaneStatsWPASS2AddHealth", "InsaneStatsWPASS2", function(ent)
	bloodlet(ent)
end)

-- this coroutine thread is to deal with marking modifiers
local markingScanner = coroutine.create(function()
	while true do
		local entitiesNeedMarkingEntities = {}
		local worldSpaceCenters = {}

		for k,v in pairs(rapidThinkEntities) do
			if IsValid(k) then
				worldSpaceCenters[k] = k:WorldSpaceCenter()

				local shouldMark = k:InsaneStats_GetAttributeValue("mark") > 1
				or k:InsaneStats_HasSkill("alert")
				if shouldMark then
					entitiesNeedMarkingEntities[k] = true
				end
			end

			coroutine.yield()
		end

		if game.GetMap() == "phys_cratastrophy" then
			for i,v in ipairs(ents.FindByModel("models/props_junk/wood_crate001a.mdl")) do
				if IsValid(v) then
					worldSpaceCenters[v] = v:WorldSpaceCenter()
				end
				coroutine.yield()
			end
		end
		
		for k,v in pairs(entitiesNeedMarkingEntities) do
			if IsValid(k) then
				local ourPos = k:WorldSpaceCenter()
				local bestDistance = math.huge

				for k2,v2 in pairs(worldSpaceCenters) do
					if (IsValid(k2) and k:InsaneStats_IsValidEnemy(k2)) then
						local thisEnemyDistance = ourPos:DistToSqr(v2)
						
						if thisEnemyDistance < bestDistance then
							bestDistance = thisEnemyDistance
							k.insaneStats_MarkedEntity = k2
						end
					end

					coroutine.yield()
				end

				local ent = k.insaneStats_MarkedEntity
				if bestDistance < math.huge and IsValid(ent) then
					if k:IsPlayer() then
						local pos = ent:HeadTarget(k:GetShootPos()) or ent:WorldSpaceCenter()
						pos = pos:IsZero() and ent:WorldSpaceCenter() or pos
						-- send a net message about the current entity
						net.Start("insane_stats", true)
						net.WriteUInt(4, 8)
						net.WriteUInt(ent:EntIndex(), 16)
						net.WriteVector(pos)
						net.WriteString(ent:GetClass())
						net.WriteDouble(ent:InsaneStats_GetHealth())
						net.WriteDouble(ent:InsaneStats_GetMaxHealth())
						net.WriteDouble(ent:InsaneStats_GetArmor())
						net.WriteDouble(ent:InsaneStats_GetMaxArmor())
						net.Send(k)
					elseif (k:IsNPC() and k:Disposition(ent) == D_HT and k:HasEnemyEluded(ent)) then
						k:UpdateEnemyMemory(ent, ent:GetPos())
					end
				elseif IsValid(k.insaneStats_MarkedEntity) then
					k.insaneStats_MarkedEntity = NULL

					if k:IsPlayer() then
						net.Start("insane_stats")
						net.WriteUInt(4, 8)
						net.WriteUInt(0, 16)
						net.Send(k)
					end
				end
			end
		end

		coroutine.yield(true)
	end
end)

local currentCoinIndex = 1
hook.Add("Think", "InsaneStatsWPASS2", function()
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		totalDamageTicks = 0
		explosionCount = 0

		currentCoinIndex = currentCoinIndex + 1
		if not coins[currentCoinIndex] then
			currentCoinIndex = 1
		end
		local currentCoin = coins[currentCoinIndex]
		local coinNearestPlayer = NULL
		local coinShortestDistance = math.huge
		
		game.SetTimeScale(game.GetTimeScale() * (InsaneStats.totalTimeDilation or 1))
		InsaneStats.totalTimeDilation = 1
		
		for k,v in pairs(rapidThinkEntities) do
			if IsValid(k) then
				local wep = k.GetActiveWeapon and k:GetActiveWeapon()
				
				if k:IsPlayer() or k:IsNextBot() then
					-- NPCs can't have their speeds changed, I've tried
					k.insaneStats_OldMoveMul = k.insaneStats_OldMoveMul or 1
					k.insaneStats_OldSprintMoveMul = k.insaneStats_OldSprintMoveMul or 1
					k.insaneStats_OldCrouchedMoveMul = k.insaneStats_OldCrouchedMoveMul or 1
					local data = {ent = k, speed = 1, sprintSpeed = 1, crouchedSpeed = 1}
					hook.Run("InsaneStatsMoveSpeed", data)
					local newMoveSpeed = data.speed
					local newSprintSpeed = data.sprintSpeed
					local newCrouchedSpeed = data.crouchedSpeed
					if k.insaneStats_OldMoveMul ~= newMoveSpeed
					or k.insaneStats_OldSprintMoveMul ~= newSprintSpeed
					or k.insaneStats_OldCrouchedMoveMul ~= newCrouchedSpeed then
						local applyMul = newMoveSpeed / k.insaneStats_OldMoveMul
						local sprintApplyMul = applyMul * newSprintSpeed / k.insaneStats_OldSprintMoveMul
						local crouchedApplyMul = newCrouchedSpeed / k.insaneStats_OldCrouchedMoveMul
						if k:IsPlayer() and not k:IsSprinting() then
							if InsaneStats:GetConVarValue("wpass2_attributes_player_constant_speed") then
								local runSpeed = 400*newMoveSpeed*newSprintSpeed
								local walkSpeed = 200*newMoveSpeed
								local slowWalkSpeed = 100*math.sqrt(newMoveSpeed)
								local crouchSpeed = 0.3*newCrouchedSpeed

								k:SetLadderClimbSpeed(slowWalkSpeed*2)
								k:SetMaxSpeed(walkSpeed)
								k:SetRunSpeed(runSpeed)
								k:SetWalkSpeed(walkSpeed)
								k:SetSlowWalkSpeed(slowWalkSpeed)
								k:SetCrouchedWalkSpeed(crouchSpeed)
								k:SetDuckSpeed(crouchSpeed)
								k:SetUnDuckSpeed(crouchSpeed)
							else
								k:SetLadderClimbSpeed(k:GetLadderClimbSpeed()*math.sqrt(applyMul))
								k:SetMaxSpeed(k:GetMaxSpeed()*applyMul)
								k:SetRunSpeed(k:GetRunSpeed()*sprintApplyMul)
								k:SetWalkSpeed(k:GetWalkSpeed()*applyMul)
								k:SetSlowWalkSpeed(k:GetSlowWalkSpeed()*math.sqrt(applyMul))
								k:SetCrouchedWalkSpeed(k:GetCrouchedWalkSpeed()*crouchedApplyMul)
								k:SetDuckSpeed(k:GetDuckSpeed()*crouchedApplyMul)
								k:SetUnDuckSpeed(k:GetUnDuckSpeed()*crouchedApplyMul)
							end
						elseif SERVER and k:IsNextBot() then
							k.loco:SetDesiredSpeed(k.loco:GetDesiredSpeed()*applyMul)
						end
						
						k.insaneStats_OldMoveMul = newMoveSpeed
						k.insaneStats_OldSprintMoveMul = newSprintSpeed
						k.insaneStats_OldCrouchedMoveMul = newCrouchedSpeed
					end
					
					if k:IsPlayer() then
						-- there are two particular non-Lua weapons - weapon_grenade and weapon_rpg - that don't have unlimited ammo + don't use clips.
						k.insaneStats_LastWeapon = k.insaneStats_LastWeapon or wep
						if k.insaneStats_LastWeapon == wep and (IsValid(wep) and not wep:IsScripted()) then
							if wep:Clip1() <= 0 then
								local ammoType = wep:GetPrimaryAmmoType()
								local count = k:GetAmmoCount(ammoType)
								k.insaneStats_LastPrimaryAmmo = k.insaneStats_LastPrimaryAmmo or count
								if k.insaneStats_LastPrimaryAmmo ~= count then
									-- FIXME: wouldn't it be easier to just call the relevant hook???
									k.insaneStats_OldSetAmmoValue = k.insaneStats_LastPrimaryAmmo
									k:SetAmmo(count, ammoType)
									k.insaneStats_LastPrimaryAmmo = k:GetAmmoCount(ammoType)
									k.insaneStats_OldSetAmmoValue = nil
								end
							else
								k.insaneStats_LastPrimaryAmmo = nil
							end
							if wep:Clip2() <= 0 then
								local ammoType = wep:GetSecondaryAmmoType()
								local count = k:GetAmmoCount(ammoType)
								k.insaneStats_LastSecondaryAmmo = k.insaneStats_LastSecondaryAmmo or count
								if k.insaneStats_LastSecondaryAmmo ~= count then
									k.insaneStats_OldSetAmmoValue = k.insaneStats_LastSecondaryAmmo
									k:SetAmmo(count, ammoType)
									k.insaneStats_LastSecondaryAmmo = k:GetAmmoCount(ammoType)
									k.insaneStats_OldSetAmmoValue = nil
								end
							else
								k.insaneStats_LastSecondaryAmmo = nil
							end
						else
							k.insaneStats_LastPrimaryAmmo = nil
							k.insaneStats_LastSecondaryAmmo = nil
						end
						k.insaneStats_LastWeapon = wep

						-- check for aux drain rate
						local drainRate = k:InsaneStats_GetAttributeValue("aux_drain")
						drainRate = drainRate * (1 - k:InsaneStats_GetSkillValues("aux_aux_battery", 2) / 100)
						if drainRate ~= 1 then
							local suitPower = k:GetSuitPower()
							k.insaneStats_LastSuitPower = k.insaneStats_LastSuitPower or suitPower
							if suitPower < k.insaneStats_LastSuitPower and math.random() >= drainRate then
								k:SetSuitPower(k.insaneStats_LastSuitPower)
							else
								k.insaneStats_LastSuitPower = suitPower
							end
						end

						if IsValid(currentCoin) then
							local squaredDistance = currentCoin:WorldSpaceCenter():DistToSqr(k:WorldSpaceCenter())
							if squaredDistance < coinShortestDistance then
								coinNearestPlayer = k
								coinShortestDistance = squaredDistance
							end
						end
					end
				end

				bloodlet(k)
				
				if (IsValid(wep) and not wep:IsScripted()) then
					wep.insaneStats_LastPrimaryFire = wep.insaneStats_LastPrimaryFire or wep:GetNextPrimaryFire()
					if wep.insaneStats_LastPrimaryFire ~= wep:GetNextPrimaryFire() then
						wep:SetNextPrimaryFire(wep:GetNextPrimaryFire())
						wep.insaneStats_LastPrimaryFire = wep:GetNextPrimaryFire()
					end
					
					wep.insaneStats_LastSecondaryFire = wep.insaneStats_LastSecondaryFire or wep:GetNextSecondaryFire()
					if wep.insaneStats_LastSecondaryFire ~= wep:GetNextSecondaryFire() then
						wep:SetNextSecondaryFire(wep:GetNextSecondaryFire())
						wep.insaneStats_LastSecondaryFire = wep:GetNextSecondaryFire()
					end
					
					wep.insaneStats_LastClip1 = wep.insaneStats_LastClip1 or wep:Clip1()
					if wep.insaneStats_LastClip1 ~= wep:Clip1() then
						wep:SetClip1(wep:Clip1())
						wep.insaneStats_LastClip1 = wep:Clip1()
					end
					
					wep.insaneStats_LastClip2 = wep.insaneStats_LastClip2 or wep:Clip2()
					if wep.insaneStats_LastClip2 ~= wep:Clip2() then
						wep:SetClip2(wep:Clip2())
						wep.insaneStats_LastClip2 = wep:Clip2()
					end
				end
				
				if (k:IsPlayer() and not k:InVehicle()) then
					--print(InsaneStats.totalTimeDilation)
					local plyVel = k:GetVelocity()
					local speedFactor = plyVel:Length2DSqr()^0.25 / 20
					local value = k:InsaneStats_GetAttributeValue("speed_dilation")
					if game.SinglePlayer() then
						value = value * (1 + k:InsaneStats_GetSkillValues("super_cold") / 100)
					end
					if value ~= 1 then
						InsaneStats.totalTimeDilation = InsaneStats.totalTimeDilation
						* (1 + (value - 1) * speedFactor)
						--print(1 + (k:InsaneStats_GetAttributeValue("speed_dilation") - 1) * speedFactor)
					end
					--print(speedFactor, k:InsaneStats_GetAttributeValue("speed_dilation"), InsaneStats.totalTimeDilation)
					
					--[[if k:InsaneStats_GetAttributeValue("dilation") ~= 1 then
						if k:KeyDown(IN_FORWARD) or k:KeyDown(IN_BACK) or k:KeyDown(IN_LEFT) or k:KeyDown(IN_RIGHT) then
							InsaneStats.totalTimeDilation = InsaneStats.totalTimeDilation * k:InsaneStats_GetAttributeValue("dilation")
						end
					end]]
				end
				
				InsaneStats.totalTimeDilation = InsaneStats.totalTimeDilation / (1+k:InsaneStats_GetStatusEffectLevel("ctrl_gamespeed_up")/100)
				InsaneStats.totalTimeDilation = InsaneStats.totalTimeDilation / (1-k:InsaneStats_GetStatusEffectLevel("alt_gamespeed_down")/100)

				-- SKILLS

				if k:IsPlayer() and game.SinglePlayer() then
					InsaneStats.totalTimeDilation = InsaneStats.totalTimeDilation / (1+k:InsaneStats_GetSkillStacks("aint_got_time_for_this")/100)

					if k:InsaneStats_GetSkillState("just_breathe") == 1 then
						InsaneStats.totalTimeDilation = InsaneStats.totalTimeDilation
						/ (1 + k:InsaneStats_GetSkillValues("just_breathe", 2)/100)
					end

					--InsaneStats.totalTimeDilation = InsaneStats.totalTimeDilation * (1+math.sqrt(k:InsaneStats_GetStatusEffectLevel("multi_killer"))/100)
				end
			end
		end
		
		if IsValid(coinNearestPlayer) then
			if CurTime() >= currentCoin:GetCreationTime() + coinNearestPlayer:InsaneStats_GetSkillValues("item_magnet", 2)
			and coinNearestPlayer:InsaneStats_HasSkill("item_magnet") then
				currentCoin:Pickup(coinNearestPlayer)
			end
		end
		
		if InsaneStats:GetConVarValue("wpass2_attributes_player_constant_timescale") then
			game.SetTimeScale(1 / InsaneStats.totalTimeDilation)
		else
			game.SetTimeScale(game.GetTimeScale() / InsaneStats.totalTimeDilation)
		end

		--local timeStart = SysTime()
		for i=1,66 do
			local success, ret = coroutine.resume(markingScanner)
			if success then
				if ret then break end
			else
				error(ret)
			end
		end
		--print((SysTime() - timeStart) * 1000)
		--print(InsaneStats.totalTimeDilation)
	end
end)

hook.Add("break_prop", "InsaneStatsWPASS2", function(data)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local victim = Entity(data.entindex or 0)
		local attacker = Player(data.userid or 0)
		
		ProcessBreakEvent(victim, attacker)
	end
end)

hook.Add("break_breakable", "InsaneStatsWPASS2", function(data)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local victim = Entity(data.entindex or 0)
		local attacker = Player(data.userid or 0)
		
		ProcessBreakEvent(victim, attacker)
	end
end)

hook.Add("InsaneStatsModifyWeaponClip", "InsaneStatsWPASS2", function(data)
	local attacker = data.wep:GetOwner()
	if IsValid(attacker) and data.old > data.new then
		local noSaveChance = 2 - attacker:InsaneStats_GetAttributeValue("ammo_savechance")
		noSaveChance = noSaveChance * (1 - attacker:InsaneStats_GetSkillValues("reuse") / 100)
		noSaveChance = noSaveChance / (1 + attacker:InsaneStats_GetStatusEffectLevel("skill_ammo_efficiency_up") / 100)

		local shouldSave = math.random() >= noSaveChance
		if shouldSave then
			data.new = data.old
		end
	end
end)

hook.Add("InsaneStatsPlayerSetAmmo", "InsaneStatsWPASS2", function(data)
	local attacker = data.ply
	if IsValid(attacker) and data.old > data.new then
		local wep = attacker:GetActiveWeapon()
		local shouldSave = math.random() + 1 < attacker:InsaneStats_GetAttributeValue("ammo_savechance")
		
		if IsValid(wep) then
			local primarySavable = wep:Clip1() <= 0 and wep:GetPrimaryAmmoType() == data.type
			local secondarySavable = wep:Clip2() <= 0 and wep:GetSecondaryAmmoType() == data.type
			shouldSave = shouldSave and (primarySavable or secondarySavable)
		end
		
		if shouldSave then
			data.new = data.old
		end
	end
end)

hook.Add("InsaneStatsPlayerRemoveAmmo", "InsaneStatsWPASS2", function(data)
	local attacker = data.ply
	if IsValid(attacker) and data.num > 0 then
		local wep = attacker:GetActiveWeapon()
		local shouldSave = math.random() + 1 < attacker:InsaneStats_GetAttributeValue("ammo_savechance")
		
		if IsValid(wep) then
			local primarySavable = wep:Clip1() <= 0 and wep:GetPrimaryAmmoType() == data.type
			local secondarySavable = wep:Clip2() <= 0 and wep:GetSecondaryAmmoType() == data.type
			shouldSave = shouldSave and (primarySavable or secondarySavable)
		end
		
		if shouldSave then
			data.num = 0
		end
	end
end)

hook.Add("PlayerAmmoChanged", "InsaneStatsWPASS2", function(ply, ammoID, oldAmount, newAmount)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		local maxReserve = game.GetAmmoMax(ammoID)
		local threshold = ply:InsaneStats_GetAttributeValue("ammo_convert")
		local maxPlayerReserve = math.ceil(maxReserve*threshold)
		if threshold < 1 and newAmount > maxPlayerReserve then
			local stacks = (math.min(newAmount, maxReserve) - maxPlayerReserve) / maxReserve * ply:InsaneStats_GetAttributeValue("death_promise_damage")
			--timer.Simple(0, function()
				ply:InsaneStats_ApplyStatusEffect("death_promise", stacks * 10, math.huge, {amplify = true})
				ply:InsaneStats_SetRawAmmo(maxPlayerReserve, ammoID)
			--end)
		end
	end

	if InsaneStats:GetConVarValue("skills_enabled") and ply:InsaneStats_HasSkill("more_bullet_per_bullet") then
		local maxReserve = game.GetAmmoMax(ammoID)
		local skillValues = {ply:InsaneStats_GetSkillValues("more_bullet_per_bullet")}
		local maxPlayerReserve = math.ceil(maxReserve * skillValues[1] / 100)
		if newAmount > maxPlayerReserve and maxReserve > 0 then
			local newStacks = math.min(
				math.huge,--skillValues[2],
				ply:InsaneStats_GetSkillStacks("more_bullet_per_bullet")
				+ (math.min(newAmount, maxReserve) - maxPlayerReserve) / maxReserve * 100
			)
			ply:InsaneStats_SetSkillData("more_bullet_per_bullet", 1, newStacks)
			ply:InsaneStats_SetRawAmmo(maxPlayerReserve, ammoID)
		end
	end
end)

hook.Add("InsaneStatsPreDeath", "InsaneStatsWPASS2", function(vic, dmginfo)
	if InsaneStats:GetConVarValue("skills_enabled") then
		if vic:InsaneStats_HasSkill("fight_for_your_life")
		and vic:InsaneStats_GetSkillState("fight_for_your_life") == 0 then
			local durationOffset = vic:InsaneStats_GetSkillStacks("fight_for_your_life", true)
			vic:InsaneStats_SetSkillData(
				"fight_for_your_life",
				1,
				vic:InsaneStats_GetSkillValues("fight_for_your_life")
				+ durationOffset
			)
			vic.insaneStats_FFYLStacksAdd = durationOffset - 2

			local name = vic:GetName() ~= "" and vic:GetName() or vic:GetClass()
			PrintMessage(HUD_PRINTTALK, name.." has been downed!")
			vic:SetHealth(1)
			vic:SetArmor(0)
			return true
		end
	end
end)

hook.Add("InsaneStatsLevelChanged", "InsaneStatsWPASS2", function(ent, oldLevel, newLevel)
	if InsaneStats:GetConVarValue("skills_enabled") and ent:InsaneStats_HasSkill("actually_levelling_up")
	and oldLevel ~= newLevel then
		local amplifier = newLevel - oldLevel
		if IsValid(ent) then
			amplifier = amplifier * ent:InsaneStats_GetTotalSkillPoints()

			local mhp, mar = ent:InsaneStats_GetSkillValues("actually_levelling_up", 3)
			ent:SetMaxHealth(ent:InsaneStats_GetMaxHealth() + amplifier * mhp)
			if ent.SetMaxArmor then
				-- if insaneStats_CurrentArmorAdd is nil, define it
				-- so that the level system doesn't assume the already level-scaled armor to be starting armor
				if not ent:InsaneStats_GetEntityData("xp_armor_mul") and mar > 0 then
					ent:InsaneStats_SetCurrentArmorAdd(mar * 100 / ent:InsaneStats_GetSkillTier("actually_levelling_up"))
				end

				ent:SetMaxArmor(ent:InsaneStats_GetMaxArmor() + amplifier * mar)
			end

			ent:InsaneStats_AddHealthNerfed(ent:InsaneStats_GetMaxHealth())
			if ent.SetArmor then
				ent:InsaneStats_AddArmorNerfed(ent:InsaneStats_GetMaxArmor())
			end
		end
	end
end)

hook.Add("InsaneStatsAmmoCrateInteracted", "InsaneStatsWPASS2", function(ent, crate)
	if InsaneStats:GetConVarValue("skills_enabled") and (
		IsValid(ent) and ent:InsaneStats_HasSkill("more_bullet_per_bullet")
	) then
		ent:InsaneStats_SetSkillData("more_bullet_per_bullet", 0, 0)
	end
end)