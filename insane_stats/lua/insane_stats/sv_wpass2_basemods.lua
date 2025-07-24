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
for i,v in ents.Iterator() do
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
	if InsaneStats:DamageIsPreventable(dmginfo) then
		if math.random() < vic:InsaneStats_GetAttributeValue("dodge") - 1 then return true end
		if attacker:InsaneStats_GetStatusEffectLevel("stunned") > 0 then return true end

		if vic:InsaneStats_EffectivelyHasSkill("hacked_shield") then
			local hackedShieldChance = vic:InsaneStats_GetEffectiveSkillValues("hacked_shield", 5)
			if vic:InsaneStats_GetArmor() > vic:InsaneStats_GetMaxArmor() then
				hackedShieldChance = hackedShieldChance / math.max(vic:InsaneStats_GetArmor() / vic:InsaneStats_GetMaxArmor(), 1)
			end
			if math.random() * 100 < hackedShieldChance then return true end
		end

		if vic:InsaneStats_GetSkillState("dodger") == 1 then
			vic:InsaneStats_SetSkillData("dodger", 0, 0)
			return true
		end

		if vic:InsaneStats_GetStatusEffectLevel("absorption") > 0 then
			if vic:IsPlayer() then
				vic:GiveAmmo(1, math.random(#game.GetAmmoTypes()))
			end
			local newLevel = vic:InsaneStats_GetStatusEffectLevel("absorption") - 1
			local duration = vic:InsaneStats_GetStatusEffectDuration("absorption")

			vic:InsaneStats_ClearStatusEffect("absorption")

			if newLevel > 0 then
				vic:InsaneStats_ApplyStatusEffect(
					"absorption",
					newLevel,
					duration
				)
			end
			return true
		end
	end
end

local totalMul, damageDealer
local lastMuls = {}
local function MultiplyDamage(...)
	local args = {...}
	for i=1, #args, 2 do
		local multiplier, cause = args[i], args[i+1]
		if multiplier ~= 1 then
			if damageDealer:IsPlayer() then
				lastMuls[damageDealer] = lastMuls[damageDealer] or {}
				lastMuls[damageDealer][cause] = multiplier
			end
			totalMul = totalMul * multiplier
		end
	end
end
local function DivideDamage(...)
	local args = {...}
	for i=1, #args, 2 do
		local divider, cause = args[i], args[i+1]
		if divider ~= 1 then
			if damageDealer:IsPlayer() then
				lastMuls[damageDealer] = lastMuls[damageDealer] or {}
				lastMuls[damageDealer][cause] = 1 / divider
			end
			totalMul = totalMul / divider
		end
	end
end
function InsaneStats:GetDamageMultipliers()
	return lastMuls
end
local function CalculateDamage(vic, attacker, dmginfo)
	if ShouldDodge(vic, attacker, dmginfo) then return true end
	local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon()

	if vic:InsaneStats_IsMob() and not armoredClasses[vic:GetClass()] then
		if math.random() * 100 < attacker:InsaneStats_GetEffectiveSkillValues("master_of_fire") then
			dmginfo:SetDamageType(bit.bor(dmginfo:GetDamageType(), DMG_SLOWBURN))
		end
		if math.random() * 100 < attacker:InsaneStats_GetEffectiveSkillValues("master_of_water") then
			dmginfo:SetDamageType(bit.bor(dmginfo:GetDamageType(), DMG_VEHICLE))
		end
		if math.random() * 100 < attacker:InsaneStats_GetEffectiveSkillValues("master_of_earth") then
			dmginfo:SetDamageType(bit.bor(dmginfo:GetDamageType(), DMG_NERVEGAS))
		end
		if math.random() * 100 < attacker:InsaneStats_GetEffectiveSkillValues("master_of_air") then
			dmginfo:SetDamageType(bit.bor(dmginfo:GetDamageType(), DMG_SHOCK))
		end
	end

	local attackerArmorInverseFraction = attacker:InsaneStats_GetArmor() == math.huge and math.huge
		or attacker:InsaneStats_GetMaxArmor() > 0
		and attacker:InsaneStats_GetArmor() / attacker:InsaneStats_GetMaxArmor()
		or 0
	if attacker:InsaneStats_EffectivelyHasSkill("shield_shell_shots") and attackerArmorInverseFraction >= 1
	and attacker ~= vic then
		if attacker:InsaneStats_GetArmor() < math.huge then
			attacker:SetArmor(
				attacker:InsaneStats_GetArmor()
				+ attacker:InsaneStats_GetMaxArmor()
				* attacker:InsaneStats_GetEffectiveSkillValues("shield_shell_shots", 2) / 100
			)
		end
		dmginfo:AddDamage(40)
	end

	if attacker:InsaneStats_GetSkillState("surprise_attack") == 1
	and attacker ~= vic then
		attacker:InsaneStats_SetSkillData("surprise_attack", 0, 0)
		dmginfo:AddDamage(40)
	end
	
	totalMul = 1
	damageDealer = attacker
	lastMuls[damageDealer] = {}
	MultiplyDamage(attacker:InsaneStats_GetAttributeValue("damage"), "damage")
	local knockbackMul = attacker:InsaneStats_GetAttributeValue("knockback")
	
	MultiplyDamage(vic:InsaneStats_GetAttributeValue("damagetaken"), "damagetaken")
	knockbackMul = knockbackMul * vic:InsaneStats_GetAttributeValue("knockbacktaken")
	
	if vic.insaneStats_LastHitGroup == HITGROUP_HEAD then
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("crit_damage"), "crit_damage")
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("crit_damagetaken"), "crit_damagetaken")
	end
	
	if vic == attacker then
		knockbackMul = knockbackMul * vic:InsaneStats_GetAttributeValue("self_knockbacktaken")
	end
	
	local isNotBulletDamage = not dmginfo:IsBulletDamage()
	local attackerHealthFraction = attacker:InsaneStats_GetMaxHealth() > 0
		and 1-math.Clamp(
			attacker:InsaneStats_GetHealth() / attacker:InsaneStats_GetMaxHealth(),
			0,
			1
		) or 0
	local highVictimHealthFraction = vic:InsaneStats_GetMaxHealth() > 0
		and vic:InsaneStats_GetHealth() / vic:InsaneStats_GetMaxHealth()
		or 1
	local victimHealthFraction = 1 - math.Clamp(highVictimHealthFraction, 0, 1)
	local attackerSpeedFraction = attacker:InsaneStats_GetEffectiveSpeed() / 400
	local victimSpeedFraction = vic:InsaneStats_GetEffectiveSpeed() / 400
	--local attackerCombatFraction = math.Clamp(attacker:InsaneStats_GetCombatTime()/5, 0, 1)
	--local victimCombatFraction = math.Clamp(vic:InsaneStats_GetCombatTime()/5, 0, 1)
	
	if isNotBulletDamage then
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("nonbullet_damage"), "nonbullet_damage")
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("nonbullet_damagetaken"), "nonbullet_damagetaken")
	else
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("bullet_damagetaken"), "bullet_damagetaken")
	end
	if dmginfo:IsDamageType(blastDamageTypes) then
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("explode_damage"), "explode_damage")
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("explode_damagetaken"), "explode_damagetaken")
	end
	if dmginfo:IsDamageType(fireDamageTypes) then
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("fire_damage"), "fire_damage")
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("fire_damagetaken"), "fire_damagetaken")
	end
	if dmginfo:IsDamageType(poisonDamageTypes) then
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("poison_damage"), "poison_damage")
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("poison_damagetaken"), "poison_damagetaken")
	end
	if dmginfo:IsDamageType(freezeDamageTypes) then
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("freeze_damage"), "freeze_damage")
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("freeze_damagetaken"), "freeze_damagetaken")
	end
	if dmginfo:IsDamageType(shockDamageTypes) then
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("shock_damage"), "shock_damage")
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("shock_damagetaken"), "shock_damagetaken")
	end
	if dmginfo:IsDamageType(DMG_SLASH) then
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("bleed_damage"), "bleed_damage")
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("bleed_damagetaken"), "bleed_damagetaken")
	end
	if dmginfo:IsDamageType(DMG_CLUB) then
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("melee_damage"), "melee_damage")
	end
	
	if (IsValid(wep) and wep.Clip1 and wep:InsaneStats_Clip1() < 2) then
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("lastammo_damage"), "lastammo_damage")
	end
	if attacker:WorldSpaceCenter():DistToSqr(vic:WorldSpaceCenter()) > 262144 then
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("longrange_damage"), "longrange_damage")
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("longrange_damagetaken"), "longrange_damagetaken")
	else
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("shortrange_damage"), "shortrange_damage")
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("shortrange_damagetaken"), "shortrange_damagetaken")
		if isNotBulletDamage then
			MultiplyDamage(
				attacker:InsaneStats_GetAttributeValue("shortrange_nonbullet_damage"),
				"shortrange_nonbullet_damage"
			)
		end
	end
	
	MultiplyDamage(1 + (attacker:InsaneStats_GetAttributeValue("lowhealth_damage") - 1) * attackerHealthFraction, "lowhealth_damage")
	MultiplyDamage(1 + (attacker:InsaneStats_GetAttributeValue("lowhealth_victim_damage") - 1) * victimHealthFraction, "lowhealth_victim_damage")
	MultiplyDamage(1 + (attacker:InsaneStats_GetAttributeValue("highhealth_victim_damage") - 1) * highVictimHealthFraction, "highhealth_victim_damage")
	MultiplyDamage(1 + (vic:InsaneStats_GetAttributeValue("lowhealth_victim_damagetaken") - 1) * attackerHealthFraction, "lowhealth_victim_damagetaken")
	MultiplyDamage(1 + (vic:InsaneStats_GetAttributeValue("lowhealth_damagetaken") - 1) * victimHealthFraction, "lowhealth_damagetaken")
	if victimHealthFraction < attacker:InsaneStats_GetAttributeValue("lowhealth_victim_doubledamage") - 1 then
		MultiplyDamage(2, "lowhealth_victim_doubledamage")
	end
	MultiplyDamage(1 + (attacker:InsaneStats_GetAttributeValue("speed_damage") - 1) * attackerSpeedFraction, "speed_damage")
	MultiplyDamage(1 + (attacker:InsaneStats_GetAttributeValue("armor_damage") - 1) * attackerArmorInverseFraction, "armor_damage")
	DivideDamage(1 + (vic:InsaneStats_GetAttributeValue("speed_defence") - 1) * attackerSpeedFraction, "speed_defence")
	
	if vic:InsaneStats_TimeSinceCombat() >= 10 then
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("noncombat_damagetaken"), "noncombat_damagetaken")
	end
	
	MultiplyDamage(1-attacker:InsaneStats_GetStatusEffectLevel("damage_down")/100, "damage_down")
	MultiplyDamage(1+attacker:InsaneStats_GetStatusEffectLevel("damage_up")/100, "damage_up")
	MultiplyDamage(1+attacker:InsaneStats_GetStatusEffectLevel("arcane_damage_up")/100, "arcane_damage_up")
	MultiplyDamage(1+attacker:InsaneStats_GetStatusEffectLevel("alt_damage_up")/100, "alt_damage_up")
	MultiplyDamage(1+attacker:InsaneStats_GetStatusEffectLevel("hittaken_damage_up")/100, "hittaken_damage_up")
	MultiplyDamage(1+vic:InsaneStats_GetStatusEffectLevel("defence_down")/100, "defence_down")
	DivideDamage(1+vic:InsaneStats_GetStatusEffectLevel("defence_up")/100, "defence_up")
	DivideDamage(1+vic:InsaneStats_GetStatusEffectLevel("arcane_defence_up")/100, "arcane_defence_up")
	DivideDamage(1+vic:InsaneStats_GetStatusEffectLevel("alt_defence_up")/100, "alt_defence_up")
	DivideDamage(1+vic:InsaneStats_GetStatusEffectLevel("ctrl_defence_up")/100, "ctrl_defence_up")
	
	MultiplyDamage(1 + attacker:InsaneStats_GetStatusEffectLevel("stack_damage_up") / 100, "stack_damage_up")
	DivideDamage(1 + vic:InsaneStats_GetStatusEffectLevel("stack_defence_up") / 100, "stack_defence_up")
	
	MultiplyDamage(1 + vic:InsaneStats_GetStatusEffectLevel("stack_defence_down")/100, "stack_defence_down")
	MultiplyDamage(1 - attacker:InsaneStats_GetStatusEffectLevel("menacing_damage_down")/100, "menacing_damage_down")

	if vic:InsaneStats_GetAttributeValue("starlight_defence") ~= 1 then
		DivideDamage(1 + vic:InsaneStats_GetStatusEffectDuration("starlight") / 100, "starlight")
	end

	if vic:InsaneStats_GetStatusEffectLevel("hittaken1s_damagetaken_cooldown") <= 0 then
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("hittaken1s_damagetaken"), "hittaken1s_damagetaken")
	end
	
	if vic:InsaneStats_IsMob() then
		if attacker:InsaneStats_GetStatusEffectLevel("hit1s_damage_cooldown") <= 0 then
			MultiplyDamage(attacker:InsaneStats_GetAttributeValue("hit1s_damage"), "hit1s_damage")
		end
		
		if attacker:InsaneStats_GetAttributeValue("hit3_damage") ~= 1 then
			if attacker:InsaneStats_GetStatusEffectLevel("hit3_damage_stacks") < 2 then
				attacker:InsaneStats_ApplyStatusEffect("hit3_damage_stacks", 1, math.huge, {amplify = true})
			else
				attacker:InsaneStats_ClearStatusEffect("hit3_damage_stacks")
				MultiplyDamage(1 + attacker:InsaneStats_GetAttributeValue("hit3_damage"), "hit3_damage")
			end
		end
		
		if attacker:InsaneStats_IsValidAlly(vic) and not (attacker:IsPlayer() and attacker:KeyDown(IN_WALK)) then
			MultiplyDamage(attacker:InsaneStats_GetAttributeValue("ally_damage"), "ally_damage")
		end
	end
	
	local levelDifference = vic:InsaneStats_GetLevel() - attacker:InsaneStats_GetLevel()
	if levelDifference > 0 then
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("highlevel_damage"), "highlevel_damage")
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("lowlevel_damagetaken"), "lowlevel_damagetaken")
	end
	
	if attacker:InsaneStats_GetAttributeValue("random_damage") ~= 1 then
		local randomness = 1 - attacker:InsaneStats_GetAttributeValue("random_damage")
		MultiplyDamage(1 + (math.random() * 2 - 1) * randomness, "random_damage")
	end
	if vic:InsaneStats_GetAttributeValue("random_damagetaken") ~= 1 then
		local randomness = 1 - vic:InsaneStats_GetAttributeValue("random_damagetaken")
		MultiplyDamage(1 + (math.random() * 2 - 1) * randomness, "random_damagetaken")
	end
	
	if attacker.insaneStats_MarkedEntity == vic then
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("mark_damage"), "mark_damage")
	end
	if vic.insaneStats_MarkedEntity == attacker then
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("mark_damagetaken"), "mark_damagetaken")
	end
	
	if armoredClasses[vic:GetClass()] or vic:InsaneStats_GetArmor() > 0 then
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("armored_victim_damage"), "armored_victim_damage")
	else
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("unarmored_victim_damage"), "unarmored_victim_damage")
	end
	
	local attackerPositionVector = attacker:WorldSpaceCenter() - vic:WorldSpaceCenter()
	attackerPositionVector:Normalize()
	local vicLookVector = vic:GetForward()
	if vicLookVector:Dot(attackerPositionVector) > 0 then
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("front_damage"), "front_damage")
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("front_damagetaken"), "front_damagetaken")
	else
		MultiplyDamage(attacker:InsaneStats_GetAttributeValue("back_damage"), "back_damage")
		MultiplyDamage(vic:InsaneStats_GetAttributeValue("back_damagetaken"), "back_damagetaken")
	end

	-- SKILLS

	local vicSuperColdValue = vic:InsaneStats_GetEffectiveSkillValues("super_cold", 3) or 0
	local attackerSuperColdValue = attacker:InsaneStats_GetEffectiveSkillValues("super_cold", 2) or 0

	MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("quintessence") / 100, "quintessence")
	MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("quintessence", 2) / 100, "quintessence")
	MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("damage") / 100, "damage")
	MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("defence") / 100, "defence")
	MultiplyDamage(1 + attacker:InsaneStats_GetSkillStacks("aint_got_time_for_this") / 100, "aint_got_time_for_this")
	DivideDamage(1 + vic:InsaneStats_GetSkillStacks("aint_got_time_for_this") / 100, "aint_got_time_for_this")
	DivideDamage(1 + vic:InsaneStats_GetSkillStacks("love_and_tolerate") / 100, "love_and_tolerate")
	DivideDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("four_parallel_universes_ahead") / 100 * victimSpeedFraction, "four_parallel_universes_ahead")
	MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("rage") / 100 * attackerHealthFraction, "rage")
	MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("why_is_it_called_kiting") / 100 * attackerSpeedFraction, "why_is_it_called_kiting")
	MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("living_on_the_edge") / 100 * victimHealthFraction, "living_on_the_edge")
	MultiplyDamage(1 + attackerSuperColdValue / 100 * attacker:InsaneStats_GetSkillStacks("super_cold"), "super_cold")
	MultiplyDamage(math.max(0, 1 + vicSuperColdValue / 100 * vic:InsaneStats_GetSkillStacks("super_cold")), "super_cold")
	MultiplyDamage(1 + attacker:InsaneStats_GetStatusEffectLevel("charge") / 2, "charge")
	MultiplyDamage(1 - vic:InsaneStats_GetStatusEffectLevel("charge") / 2.5, "charge")
	DivideDamage(1 + vic:InsaneStats_GetSkillStacks("starlight") / 100, "starlight")
	MultiplyDamage(1 + attacker:InsaneStats_GetSkillStacks("more_bullet_per_bullet") / 100, "more_bullet_per_bullet")
	DivideDamage(1 + vic:InsaneStats_GetSkillStacks("more_bullet_per_bullet") / 100, "more_bullet_per_bullet")
	MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("you_are_all_bleeders") / 100 * attackerHealthFraction, "you_are_all_bleeders")
	MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("glass") / 100, "glass")
	MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("glass", 2) / 100, "glass")
	MultiplyDamage(1 + attacker:InsaneStats_GetSkillStacks("synergy_1") * attacker:InsaneStats_GetEffectiveSkillValues("synergy_1") / 100, "synergy_1")
	MultiplyDamage(1 + attacker:InsaneStats_GetSkillStacks("synergy_4") * attacker:InsaneStats_GetEffectiveSkillValues("synergy_4") / 100, "synergy_4")
	DivideDamage(1 + vic:InsaneStats_GetSkillStacks("synergy_4") * vic:InsaneStats_GetEffectiveSkillValues("synergy_4") / 100, "synergy_4")
	DivideDamage(1 + vic:InsaneStats_GetSkillStacks("synergy_3") * vic:InsaneStats_GetEffectiveSkillValues("synergy_3", 2) / 100, "synergy_3")
	MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("hellish_challenge") / 100, "hellish_challenge")
	MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("degeneration", 2) / 100, "degeneration")
	MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("shoe_spikes") / 100, "shoe_spikes")
	MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("so_heres_the_problem") / 100, "so_heres_the_problem")
	DivideDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("more_and_more", 5) / 100, "more_and_more")
	MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("feel_the_mass") / 100 * attackerArmorInverseFraction, "feel_the_mass")
	MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("helm_too_big") / 100, "helm_too_big")

	if attacker:InsaneStats_GetEffectiveSkillValues("rip_and_tear") > 0 then
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("rip_and_tear") / 100, "rip_and_tear")
	end
	if attacker:InsaneStats_GetSkillState("anger") == 1 then
		MultiplyDamage(3, "anger")
	end
	if attacker:InsaneStats_GetSkillStacks("friendly_fire_off") > 0 then
		MultiplyDamage(2, "friendly_fire_off")
	end
	if attacker:InsaneStats_GetSkillState("flex") == 1 then
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("flex", 2) / 100, "flex")
	end
	if vic:InsaneStats_EffectivelyHasSkill("pulsing_armor") then
		MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("pulsing_armor") / 100, "pulsing_armor")
	end
	if attacker:InsaneStats_EffectivelyHasSkill("ebb_and_flow") then
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("ebb_and_flow") / 100, "ebb_and_flow")
	end
	if attacker:InsaneStats_EffectivelyHasSkill("rain_from_above") then
		local gravityDir = physenv.GetGravity():GetNormalized()
		gravityDir:Mul(65536)
		local traceResult = util.TraceEntity({
			start = attacker:GetPos(),
			endpos = attacker:GetPos() + gravityDir,
			filter = attacker,
			mask = MASK_PLAYERSOLID
		}, attacker)

		local addDamage, distanceFactor = attacker:InsaneStats_GetEffectiveSkillValues("rain_from_above")
		MultiplyDamage(1 + addDamage * traceResult.Fraction * 655.36 / distanceFactor, "rain_from_above")
	end
	if vic:InsaneStats_EffectivelyHasSkill("across_the_sky") then
		local gravityDir = physenv.GetGravity():GetNormalized()
		gravityDir:Mul(65536)
		local traceResult = util.TraceEntity({
			start = vic:GetPos(),
			endpos = vic:GetPos() + gravityDir,
			filter = vic,
			mask = MASK_PLAYERSOLID
		}, vic)

		local addDamage, distanceFactor = vic:InsaneStats_GetEffectiveSkillValues("across_the_sky")
		DivideDamage(1 + addDamage * traceResult.Fraction * 655.36 / distanceFactor, "across_the_sky")
	end
	if dmginfo:IsExplosionDamage() then
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("kablooey") / 100, "kablooey")
		MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("blast_proof_suit") / 100, "blast_proof_suit")

	end
	if dmginfo:IsDamageType(fireDamageTypes) then
		if attacker:InsaneStats_EffectivelyHasSkill("master_of_fire") then
			MultiplyDamage(2, "master_of_fire")
		end
		if vic:InsaneStats_EffectivelyHasSkill("master_of_fire") then
			DivideDamage(2, "master_of_fire")
		end
	end
	if dmginfo:IsDamageType(freezeDamageTypes) then
		if attacker:InsaneStats_EffectivelyHasSkill("master_of_water") then
			MultiplyDamage(2, "master_of_water")
		end
		if vic:InsaneStats_EffectivelyHasSkill("master_of_water") then
			DivideDamage(2, "master_of_water")
		end
	end
	if dmginfo:IsDamageType(poisonDamageTypes) then
		if attacker:InsaneStats_EffectivelyHasSkill("master_of_earth") then
			MultiplyDamage(2, "master_of_earth")
		end
		if vic:InsaneStats_EffectivelyHasSkill("master_of_earth") then
			DivideDamage(2, "master_of_earth")
		end
	end
	if dmginfo:IsDamageType(shockDamageTypes) then
		if attacker:InsaneStats_EffectivelyHasSkill("master_of_air") then
			MultiplyDamage(2, "master_of_air")
		end
		if vic:InsaneStats_EffectivelyHasSkill("master_of_air") then
			DivideDamage(2, "master_of_air")
		end
	end
	if vic:InsaneStats_GetSkillStacks("embolden") > 0 then
		MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("embolden") / 100, "embolden")
	end
	if vic.insaneStats_LastHitGroup == HITGROUP_HEAD then
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("the_sniper") / 100, "the_sniper")
		MultiplyDamage(1 + attacker:InsaneStats_GetStatusEffectLevel("crit_damage_up")/100, "crit_damage_up")
		DivideDamage(1 + vic:InsaneStats_GetStatusEffectLevel("crit_defence_up")/100, "crit_defence_up")
		MultiplyDamage(1 + vic:InsaneStats_GetStatusEffectLevel("crit_defence_down")/100, "crit_defence_down")
		MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("watch_your_head") / 100, "watch_your_head")
		
		if math.random() < attacker:InsaneStats_GetEffectiveSkillValues("critical_crit") / 100 then
			MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("critical_crit", 2) / 100, "critical_crit")
		end
	end
	if isNotBulletDamage then
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("a_little_less_gun") / 100, "a_little_less_gun")
		MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("iron_skin") / 100, "iron_skin")
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("aimbot", 2) / 100, "aimbot")
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("helm_too_big", 3) / 100, "helm_too_big")
		MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("silver_bullets") / 100, "silver_bullets")
	end
	if IsValid(wep) then
		if wep:GetPrimaryAmmoType() == 3 or wep:GetPrimaryAmmoType() == 5
		or wep:GetSecondaryAmmoType() == 3 or wep:GetSecondaryAmmoType() == 5 then
			MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("one_with_the_gun") / 100, "one_with_the_gun")
		end

		if wep.Clip1 then
			local clip1 = wep:InsaneStats_Clip1()
			local maxClip1 = wep:GetMaxClip1()
			local clip1Fraction = math.sqrt(math.max(clip1, 0) / maxClip1)
			if maxClip1 <= 0 then
				clip1Fraction = 1
			end
			MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("dangerous_preparation") / 100 * clip1Fraction, "dangerous_preparation")
		end
	end
	if vic.insaneStats_MarkedEntity == attacker then
		MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("alert", 2) / 100, "alert")
	end
	if attacker.insaneStats_MarkedEntity == vic then
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("alert") / 100, "alert")
	end
	if game.SinglePlayer() then
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("spongy") / 100, "spongy")
		MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("spongy", 3) / 100, "spongy")

		if vic:InsaneStats_EffectivelyHasSkill("super_cold") then
			MultiplyDamage(game.GetTimeScale(), "super_cold")
		end
	elseif vic.Ping then
		local ping = vic:Ping()
		DivideDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("spongy") / 100 * ping, "spongy")
		DivideDamage(1 + (vic:InsaneStats_GetAttributeValue("ping_defence") - 1) * ping, "ping_defence")
	end
	local distance = attacker:WorldSpaceCenter():DistToSqr(vic:WorldSpaceCenter())
	if vic:InsaneStats_EffectivelyHasSkill("stuff_in_the_way") then
		local sitwAdd, sitwDist = vic:InsaneStats_GetEffectiveSkillValues("stuff_in_the_way")
		DivideDamage(1 + sitwAdd / 100 * math.sqrt(distance) / sitwDist, "stuff_in_the_way")
	end
	if distance > 262144 then
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("you_cant_run") / 100, "you_cant_run")
	else
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("youre_approaching_me") / 100, "youre_approaching_me")
	end
	if victimHealthFraction > 0.9 then
		MultiplyDamage(1 + attacker:InsaneStats_GetSkillStacks("kill_at_first_hit") / 100, "kill_at_first_hit")
	end
	if attacker:InsaneStats_EffectivelyHasSkill("heads_will_roll") then
		local damageMul, below = attacker:InsaneStats_GetEffectiveSkillValues("heads_will_roll")
		below = below / 100
		if victimHealthFraction <= below then
			MultiplyDamage(1 + damageMul / 100, "heads_will_roll")
		end
	end
	if attacker:InsaneStats_EffectivelyHasSkill("campfire") then
		for i,v in ipairs(ents.FindInSphere(attacker:WorldSpaceCenter(), 512)) do
			local class = v:GetClass()
			if class == "env_fire" and not v:IsEFlagSet(EFL_NO_THINK_FUNCTION) or class == "entityflame" then
				MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("campfire") / 100, "campfire")
				break
			end
		end
	end

	if vic:InsaneStats_GetStatusEffectLevel("bleed") > 0
	or vic:InsaneStats_GetStatusEffectLevel("skill_bleed") > 0
	or vic:InsaneStats_GetStatusEffectLevel("hemotoxin") > 0
	or vic:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0
	or vic:InsaneStats_GetStatusEffectLevel("freeze") > 0
	or vic:InsaneStats_GetStatusEffectLevel("frostfire") > 0
	or vic:WaterLevel() > 0 then
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("electric_crowbar") / 100, "electric_crowbar")
		MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("electric_crowbar", 2) / 100, "electric_crowbar")
	end

	local armorBatteryTier = InsaneStats:GetConVarValue("wpass2_enabled") and vic.insaneStats_Tier or 0
	if armorBatteryTier > 0 then
		DivideDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("suit_up", 2) / 100, "suit_up")
	else
		MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("suit_up") / 100, "suit_up")
	end

	if vic:InsaneStats_GetArmor() > 0 then
		MultiplyDamage(1 + vic:InsaneStats_GetEffectiveSkillValues("impenetrable_shield") / 100, "impenetrable_shield")
	end
	if not vic:InsaneStats_IsMob() then
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("the_sniper") / 100, "the_sniper")
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("master_of_fire", 2) / 100, "master_of_fire")
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("master_of_water", 2) / 100, "master_of_water")
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("master_of_earth", 2) / 100, "master_of_earth")
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("master_of_air", 2) / 100, "master_of_air")
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("anti_coward_rounds") / 100, "anti_coward_rounds")
	end
	if armoredClasses[vic:GetClass()] then
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("anti_coward_rounds") / 100, "anti_coward_rounds")
	end

	local victimArmorFraction = vic:InsaneStats_GetMaxArmor() > 0
	and vic:InsaneStats_GetArmor() / vic:InsaneStats_GetMaxArmor()
	or 1
	if victimArmorFraction > 0 then
		MultiplyDamage(1 + attacker:InsaneStats_GetEffectiveSkillValues("anti_coward_rounds", 2) / 100 * victimArmorFraction, "anti_coward_rounds")
	end

	knockbackMul = knockbackMul / (1 + vic:InsaneStats_GetStatusEffectLevel("knockback_resistance_up") / 100)
	* (1 + vic:InsaneStats_GetStatusEffectLevel("knockback_resistance_down") / 100)
	* (1 + attacker:InsaneStats_GetStatusEffectLevel("knockback_up") / 100)
	* (1 - attacker:InsaneStats_GetStatusEffectLevel("knockback_down") / 100)
	* (1 + attacker:InsaneStats_GetEffectiveSkillValues("step_it_up") / 100)
	
	dmginfo:ScaleDamage(totalMul)
	
	vic:InsaneStats_SetEntityData(
		"armor_blocks_all",
		vic:InsaneStats_GetAttributeValue("armor_trueblock") > 1
		or vic:InsaneStats_EffectivelyHasSkill("impenetrable_shield")
	)
	
	dmginfo:SetDamageForce(dmginfo:GetDamageForce() * knockbackMul)
end

local explosionQueued = false
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
		
		if not explosionQueued then
			timer.Simple(0, function()
				explosionQueued = false
				local effdata = EffectData()
				effdata:SetOrigin(damagePos)
				effdata:SetMagnitude(1)
				effdata:SetScale(1)
				effdata:SetFlags(0)
				util.Effect("Explosion", effdata)
			end)
		end
		explosionQueued = true
		
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
	local shouldShock = data.shouldShock
	local explodeDamageType = data.explodeDamageType
	local localPos
	
	if IsValid(victim) then
		localPos = victim:WorldToLocal(damagePos)
	end
					
	if explodeDamageType then
		local effdata = EffectData()
		effdata:SetOrigin(damagePos)
		effdata:SetScale(1)
		effdata:SetMagnitude(1)
		util.Effect("StunstickImpact", effdata)
	end
	
	timer.Simple(0.5, function()
		if IsValid(attacker) then
			-- translate local pos if possible, else use world pos
			if IsValid(victim) then
				damagePos = victim:LocalToWorld(localPos)
				if shouldShock and attacker ~= victim then
					local effectDamage = damage / 10
					effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("shock_damage")
					effectDamage = effectDamage * victim:InsaneStats_GetAttributeValue("shock_damagetaken")
					
					victim:InsaneStats_ApplyStatusEffect(
						"shock", effectDamage,
						10, {amplify = true, attacker = attacker}
					)
				end
			end
			
			if explodeDamageType then
				CauseExplosion({
					damageTier = damageTier,
					attacker = attacker,
					damage = damage,
					damagePos = damagePos,
					damageType = explodeDamageType
				})
			end
		end
	end)
end

local storedScaleCVars
local neverReflectDamageClasses = {
	trigger_hurt = true
}
local maxXPYieldStacks = 2^128
hook.Add("EntityTakeDamage", "InsaneStatsWPASS2", function(vic, dmginfo)
	if (InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled")) and IsValid(vic) then
		
		if vic.insaneStats_LastHitGroupUpdate ~= engine.TickCount() then
			vic.insaneStats_LastHitGroup = 0
		end

		-- crits
		local attacker = dmginfo:GetAttacker()
		if IsValid(attacker) and vic.insaneStats_LastHitGroup ~= HITGROUP_HEAD then
			local shouldCrit = (math.random() < attacker:InsaneStats_GetAttributeValue("crit_chance") - 1)
			or not dmginfo:IsBulletDamage()
			and math.random() * 100 < attacker:InsaneStats_GetEffectiveSkillValues("aimbot", 3)
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
		if vic:InsaneStats_EffectivelyHasSkill("medic_bag") and vic:InsaneStats_GetSkillStacks("medic_bag") <= 0 then
			local restoreFrac = vic:InsaneStats_GetEffectiveSkillValues("medic_bag") / 100
			vic:InsaneStats_AddHealthNerfed(vic:InsaneStats_GetMaxHealth() * restoreFrac)
			vic:InsaneStats_AddArmorNerfed(vic:InsaneStats_GetMaxArmor() * restoreFrac)
			vic:InsaneStats_SetSkillData("medic_bag", -1, 60)
		end
		if vic:InsaneStats_EffectivelyHasSkill("anger") and vic:InsaneStats_GetSkillState("anger") == 0 then
			vic:InsaneStats_SetSkillData("anger", 1, 10)
		end

		if attacker:InsaneStats_IsMob() and attacker ~= vic then
			if vic:InsaneStats_EffectivelyHasSkill("love_and_tolerate") then
				vic:InsaneStats_SetSkillData(
					"love_and_tolerate",
					1,
					vic:InsaneStats_GetSkillStacks("love_and_tolerate")
					+ vic:InsaneStats_GetEffectiveSkillValues("love_and_tolerate")
				)
			end
			local addStacks = 0
			if vic:InsaneStats_EffectivelyHasSkill("synergy_3") then
				addStacks = 0.1
			end
			if vic:InsaneStats_EffectivelyHasSkill("synergy_4") then
				addStacks = addStacks + 0.1
			end
			if addStacks ~= 0 then
				local stacks = math.max(
					vic:InsaneStats_GetSkillStacks("synergy_1"),
					vic:InsaneStats_GetSkillStacks("synergy_2"),
					vic:InsaneStats_GetSkillStacks("synergy_3"),
					vic:InsaneStats_GetSkillStacks("synergy_4")
				)
	
				vic:InsaneStats_SetSkillData("synergy_1", 1, stacks + addStacks)
				vic:InsaneStats_SetSkillData("synergy_2", 1, stacks + addStacks)
				vic:InsaneStats_SetSkillData("synergy_3", 1, stacks + addStacks)
				vic:InsaneStats_SetSkillData("synergy_4", 1, stacks + addStacks)
			end
			if vic:InsaneStats_EffectivelyHasSkill("hellish_challenge") then
				vic:InsaneStats_SetSkillData(
					"hellish_challenge",
					2,
					math.Clamp(
						vic:InsaneStats_GetSkillStacks("hellish_challenge")
						+ vic:InsaneStats_GetEffectiveSkillValues("hellish_challenge", 2),
						0,
						100
					)
				)
			end
			for k,v in pairs(InsaneStats:GetEntitiesWithSkills()) do
				if k:InsaneStats_IsValidAlly(vic) and k:InsaneStats_GetEffectiveSkillTier("friendly_fire_off") > 2 then
					local state = k:InsaneStats_GetSkillState("friendly_fire_off")
					k:InsaneStats_SetSkillData("friendly_fire_off", state, 10)
				end
			end
		end

		local damageTier = damageTiers[#damageTiers]
		if damageTier < 0.5 and math.random() * 100 < vic:InsaneStats_GetEffectiveSkillValues("instant_karma")
		and vic:InsaneStats_GetStatusEffectLevel("no_spreading_damage") <= 0 then
			--[[local oldDamage = dmginfo:GetDamage()
			local oldAttacker = attacker]]

			if not neverReflectDamageClasses[attacker:GetClass()] then
				-- without a timer, reflecting stalker attacks will result in INSTANT CTD
				timer.Simple(0, function()
					if IsValid(attacker) and IsValid(vic) then
						table.insert(damageTiers, 0.5)
						attacker:TakeDamage(40, vic)
						table.remove(damageTiers)
					end
				end)
			end
		end
		
		local damage = dmginfo:GetDamage()
		if damage > 0 and damageTier <= 0.5 then
			local stacks = vic:InsaneStats_GetStatusEffectLevel("stack_xp_yield_up")

			if math.random() < attacker:InsaneStats_GetAttributeValue("victim_xpyield") - 1 then
				stacks = stacks + damage
				stacks = math.Clamp(stacks, 0, maxXPYieldStacks)
				vic:InsaneStats_ApplyStatusEffect("stack_xp_yield_up", stacks, 10)
			end
			
			local mul, _, maxStacks = attacker:InsaneStats_GetEffectiveSkillValues("seasoning")
			if mul > 0 then
				stacks = stacks + math.min(damage * mul / 100, maxStacks)
				stacks = math.Clamp(stacks, 0, maxXPYieldStacks)
				vic:InsaneStats_ApplyStatusEffect("stack_xp_yield_up", stacks, 10)
			end
		end

		--[[local cannonLevel = vic:InsaneStats_GetStatusEffectLevel("ion_cannon_target")
		if vic:InsaneStats_IsMob() and not vic.insaneStats_IsDead and vic:InsaneStats_IsBig()
		and attacker:InsaneStats_EffectivelyHasSkill("ion_cannon")
		and attacker:InsaneStats_IsValidEnemy(vic)
		and (attacker:InsaneStats_GetSkillState("ion_cannon") == 0 or cannonLevel > 0) then
			local maxHits, _, cooldown = attacker:InsaneStats_GetEffectiveSkillValues("ion_cannon")
			if cannonLevel > 0 then
				local maxCannonLevel = 2 ^ maxHits
				if cannonLevel < maxCannonLevel then
					vic:InsaneStats_ApplyStatusEffect(
						"ion_cannon_target", cannonLevel,
						vic:InsaneStats_GetStatusEffectDuration("ion_cannon_target"),
						{amplify = true, attacker = attacker}
					)
				end
			else
				vic:InsaneStats_ApplyStatusEffect("ion_cannon_target", 1, 6, {attacker = attacker})
				attacker:InsaneStats_SetSkillData("ion_cannon", 1, cooldown)
			end
		end]]

		if vic:InsaneStats_EffectivelyHasSkill("mantreads") and dmginfo:IsFallDamage() and damageTier < 1.5 then
			local targets = {}
			for i,v in ipairs(ents.FindInSphere(vic:WorldSpaceCenter(), 256)) do
				if v ~= vic and v:GetParent() ~= vic then
					table.insert(targets, v)
				end
			end

			local damageScale = 2 ^ vic:InsaneStats_GetEffectiveSkillValues("mantreads")
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

		if math.random() * 100 < vic:InsaneStats_GetEffectiveSkillValues("absorption_shield")
		and vic:InsaneStats_GetArmor() > 0 then
			if vic:IsPlayer() then
				vic:GiveAmmo(1, math.random(#game.GetAmmoTypes()))
			end
			
			vic:InsaneStats_DamageNumber(attacker, "miss")
			return true
		end

		local currentWep = vic.GetActiveWeapon and vic:GetActiveWeapon()
		if vic:InsaneStats_GetSkillState("melee_arts") == 1 and 
		(not vic:IsPlayer() or vic:KeyDown(IN_ATTACK2))
		and (IsValid(currentWep) and currentWep:GetHoldType() == "melee") then
			local curTime = CurTime()
			local data = {next = curTime + 1, attacker = vic}
			hook.Run("InsaneStatsModifyNextFire", data)

			vic:InsaneStats_SetSkillData("melee_arts", 0, curTime - data.next + 1)
			if vic:IsPlayer() then
				vic:GiveAmmo(1, math.random(#game.GetAmmoTypes()))
			end
			local effdata = EffectData()
			effdata:SetOrigin(vic:GetPos())
			effdata:SetEntity(vic)
			util.Effect("RPGShotDown", effdata)
			return true
		end

		if (vic:InsaneStats_GetStatusEffectLevel("hittaken_invincible") > 0 or vic:InsaneStats_GetStatusEffectLevel("invincible") > 0)
		and InsaneStats:DamageIsPreventable(dmginfo) then
			vic:InsaneStats_DamageNumber(attacker, "immune")
			
			-- on melee hits, reduce duration of invincibility
			if dmginfo:IsDamageType(DMG_CLUB) and vic:InsaneStats_GetStatusEffectLevel("hittaken_invincible") > 0 then
				local deduct = vic:InsaneStats_GetAttributeValue("hittaken_invincible_meleebreak") - 1
				vic:InsaneStats_ApplyStatusEffect("hittaken_invincible", 1, deduct, {extend = true})
			end
			
			return true
		end

		if vic:InsaneStats_GetSkillState("ubercharge") == 1 and InsaneStats:DamageIsPreventable(dmginfo) then
			vic:InsaneStats_DamageNumber(attacker, "immune")
			return true
		end

		if vic:InsaneStats_GetSkillState("fight_for_your_life") == 1 then
			vic:InsaneStats_DamageNumber(attacker, "immune")
			return true
		end

		if vic:InsaneStats_EffectivelyHasSkill("rock_solid") then
			local negatedDamageTypes = bit.bor(fireDamageTypes, blastDamageTypes)
			if vic:InsaneStats_GetEffectiveSkillTier("rock_solid") > 1 then
				negatedDamageTypes = bit.bor(negatedDamageTypes, poisonDamageTypes, DMG_SHOCK, freezeDamageTypes)
				if vic:InsaneStats_GetEffectiveSkillTier("rock_solid") > 2 then
					negatedDamageTypes = bit.bor(negatedDamageTypes, DMG_CLUB, DMG_SONIC, DMG_ENERGYBEAM, DMG_CRUSH)
				end
			end
			if dmginfo:IsDamageType(negatedDamageTypes) then
				vic:InsaneStats_DamageNumber(attacker, "immune")
				return true
			end
		end

		if vic:IsVehicle() and vic:IsValidVehicle() then
			local driver = vic:GetDriver()
			if IsValid(driver) then
				if driver:InsaneStats_EffectivelyHasSkill("rock_solid") then
					vic:InsaneStats_DamageNumber(attacker, "immune")
					return true
				end
			end
		end

		if attacker:InsaneStats_IsValidAlly(vic)
		and attacker ~= vic
		and attacker:InsaneStats_GetSkillState("friendly_fire_off") == 1
		and attacker:InsaneStats_EffectivelyHasSkill("friendly_fire_off") then
			vic:InsaneStats_DamageNumber(attacker, "immune")
			return true
		end

		if vic.insaneStats_TempKillSkillTriggerer then return true end
		
		if IsValid(attacker) or attacker == game.GetWorld() and not vic:IsVehicle() then
			if attacker:GetClass() == "entityflame"
			and (vic:InsaneStats_GetStatusEffectLevel("fire") > 0
			or vic:InsaneStats_GetStatusEffectLevel("frostfire") > 0
			or vic:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0) then
				return true
			end

			local victimClass = vic:GetClass()
			local isDropshipContainer = victimClass == "prop_dropship_container"
			local isBurrowed = vic:GetInternalVariable("m_bBurrowed")
			--[[if isBurrowed == nil then
				isBurrowed = vic:GetInternalVariable("startburrowed")
			end]]
			if isDropshipContainer and InsaneStats:GetConVarValue("wpass2_dropship_invincible")
			or isBurrowed and InsaneStats:GetConVarValue("wpass2_burrowed_invincible")
			or victimClass == "env_fire" then
				--[[local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon()
				if not (IsValid(wep) and wep:GetClass() == "weapon_rpg") then]]
					vic:InsaneStats_DamageNumber(attacker, "immune")
					return true
				--end
			end
			
			if vic:InsaneStats_IsMob() and damageTier > 0
			and (not attacker:InsaneStats_IsValidEnemy(vic) or isDropshipContainer)
			and not isSkillExplosion then
				if dmginfo:IsExplosionDamage() then
					vic:InsaneStats_ApplyKnockback(dmginfo:GetDamageForce())
				end
				return true
			end

			-- weapon_striderbuster will not kill striders
			-- if destroyed via an explosion instead of a bullet. why?
			if victimClass == "weapon_striderbuster" and damageTier > 0 then
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

				--[[if vic:InsaneStats_EffectivelyHasSkill("countdown_to_destruction") and dmginfo:GetDamage() > 0 then
					local bleedLevel = vic:InsaneStats_GetEffectiveSkillValues("countdown_to_destruction")
					local bleedDPS = bleedLevel * 8
					local duration = dmginfo:GetDamage() / bleedDPS
					--print(dmginfo:GetDamage(), duration)
					duration = (math.random() < duration * 2 % 1 and math.floor or math.ceil)(duration * 2) / 2
					if duration > 0 then
						vic:InsaneStats_ApplyStatusEffect(
							"skill_bleed",
							bleedLevel,
							duration,
							{attacker = attacker, extend = true}
						)
					end

					return true
				end]]
			end
		end
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
	item_dynamic_resupply = true,

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
local pendingItemSpawns = {}
local function GetItemMultiplier(ply)
	return ply:InsaneStats_GetAttributeValue("copying")
	* (1 + ply:InsaneStats_GetEffectiveSkillValues("productivity") / 100)
	* (1 + ply:InsaneStats_GetStatusEffectLevel("item_duplicator"))
end
local function SpawnRandomItems(items, pos, activator, triggers)
	triggers = triggers or 1
	local closestSqrDist = math.huge
	local closestPlayer = nil

	for i,v in player.Iterator() do
		local sqrDist = v:WorldSpaceCenter():DistToSqr(pos)
		if sqrDist < closestSqrDist then
			closestSqrDist = sqrDist
			closestPlayer = v
		end
	end

	if IsValid(closestPlayer) then
		if closestPlayer:InsaneStats_EffectivelyHasSkill("too_many_items")
		or closestPlayer:InsaneStats_GetHealth() == math.huge
		or closestPlayer:InsaneStats_GetArmor() == math.huge then
			closestPlayer:InsaneStats_SetSkillData(
				"too_many_items", 0, closestPlayer:InsaneStats_GetSkillStacks("too_many_items")
				+ closestPlayer:InsaneStats_GetEffectiveSkillValues("too_many_items", 2)
				* items * triggers * GetItemMultiplier(closestPlayer)
			)
		else
			for i=1, triggers do
				if math.random() < items then
					local itemSpawnPlaces = {pos}
					if closestPlayer:InsaneStats_GetEffectiveSkillValues("item_magnet")^2 >= closestSqrDist then
						table.insert(itemSpawnPlaces, closestPlayer)
				
						if InsaneStats:IsDebugLevel(4) then
							InsaneStats:Log("Item spawn position set to %s", tostring(closestPlayer))
						end
					end

					table.insert(pendingItemSpawns, itemSpawnPlaces)
				end
			end
		end
	end
end

local scatterShotEntities = {}
local grenadedEntities = {}
local rechargerClasses = {
	func_healthcharger = true,
	item_healthcharger = true,
	func_recharge = true,
	item_suitcharger = true
}
local infestationEffects = {
	damage_down = 5,
	firerate_down = 5,
	accuracy_down = 20,
	knockback_down = 20,

	field_of_shards = 5,
	defence_down = 5,
	crit_defence_down = 10,
	knockback_resistance_down = 20,

	xp_down = 5,
	xp_yield_up = 5,
}
local killingSpreeEffects = {
	{
		damage_up = 25,

		defence_up = 25,

		xp_up = 25,
		speed_up = 25,
	},
	{
		firerate_up = 25,
		accuracy_up = 100,

		regen = 1,
		armor_regen = 1,
	},
	{
		crit_damage_up = 50,

		crit_defence_up = 50,

		item_duplicator = 0.25,
		crit_xp_up = 50,
	},
	{
		ammo_efficiency_up = 50,
		knockback_up = 100,

		knockback_resistance_up = 100,
		pheonix = 1,
	}
}
hook.Add("PostEntityTakeDamage", "InsaneStatsWPASS2", function(vic, dmginfo, notImmune)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local attacker = dmginfo:GetAttacker()
		local damageTier = damageTiers[#damageTiers]
		if IsValid(attacker) and IsValid(vic) and attacker ~= vic then
			local vicIsMob = vic:InsaneStats_IsMob()
			if vicIsMob and attacker:InsaneStats_IsMob() then
				vic:InsaneStats_UpdateCombatTime()
				attacker:InsaneStats_UpdateCombatTime()

				if attacker:InsaneStats_EffectivelyHasSkill("skip_the_scenery") then
					attacker:InsaneStats_SetSkillData("skip_the_scenery", -1, 10)
				end
				if vic:InsaneStats_EffectivelyHasSkill("skip_the_scenery") then
					vic:InsaneStats_SetSkillData("skip_the_scenery", -1, 10)
				end
			end
			
			local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon()
			
			if not (dmginfo:IsDamageType(DMG_BURN) or IsValid(vic:GetParent())) then
				local damage = dmginfo:GetDamage()
				--print(damage)
				--print(not dmginfo:IsBulletDamage(), damageTiers[#damageTiers] < 1, vic:GetCollisionGroup() ~= COLLISION_GROUP_DEBRIS)

				if damageTier < 4 then
					-- non-damage based effects
					local speedDownLevel = (1 - attacker:InsaneStats_GetAttributeValue("victim_speed")) * 100
					vic:InsaneStats_ApplyStatusEffect("speed_down", speedDownLevel, 10)
					local defenceDownLevel = (attacker:InsaneStats_GetAttributeValue("victim_damagetaken") - 1) * 100
					vic:InsaneStats_ApplyStatusEffect("defence_down", defenceDownLevel, 10)
					local damageDownLevel = (1 - attacker:InsaneStats_GetAttributeValue("victim_damage")) * 100
					vic:InsaneStats_ApplyStatusEffect("damage_down", damageDownLevel, 10)
					local fireRateDownLevel = (1 - attacker:InsaneStats_GetAttributeValue("victim_firerate")) * 100
					vic:InsaneStats_ApplyStatusEffect("firerate_down", fireRateDownLevel, 10)
					
					-- non-over time / delayed effects
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
					local shouldSkillExplode = attacker:InsaneStats_GetSkillState("brilliant_behemoth") == 1
					if explodeCondition and shouldSkillExplode then
						CauseExplosion({
							attacker = attacker,
							damageTier = 1,
							damage = dmginfo:GetBaseDamage(),
							damagePos = worldPos,
							damageType = DMG_BLAST,
							radius = attacker:InsaneStats_GetEffectiveSkillValues(
								"brilliant_behemoth", 2
							),
							isSkillExplosion = true
						})
					end
					
					if attacker:InsaneStats_GetAttributeValue("hitstack_victim_damagetaken") ~= 1 then
						local stacks = (attacker:InsaneStats_GetAttributeValue("hitstack_victim_damagetaken")-1)*100
						vic:InsaneStats_ApplyStatusEffect("stack_defence_down", stacks, 10, {amplify = true})
					end
					if vic:InsaneStats_GetAttributeValue("perhittaken_damagetaken") ~= 1 then
						local stacks = (vic:InsaneStats_GetAttributeValue("perhittaken_damagetaken")-1)*100
						vic:InsaneStats_ApplyStatusEffect("stack_defence_down", stacks, 10, {amplify = true})
					end
					
					if vic:InsaneStats_GetAttributeValue("hittakenstack_defence") ~= 1 then
						local stacks = (vic:InsaneStats_GetAttributeValue("hittakenstack_defence")-1)*100
						vic:InsaneStats_ApplyStatusEffect("stack_defence_up", stacks, 10, {amplify = true})
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
					
					if vic:InsaneStats_GetAttributeValue("hittaken10s_speed") ~= 1
					and vic:InsaneStats_GetHealth() > 0 then
						local stacks = (vic:InsaneStats_GetAttributeValue("hittaken10s_speed")-1)*100
						vic:InsaneStats_ApplyStatusEffect("speed_up", stacks, 10)
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
					
					if shouldPoison or shouldBleed or shouldHemotoxin then
						local poisonMul = attacker:InsaneStats_GetAttributeValue("poison_damage")
							* vic:InsaneStats_GetAttributeValue("poison_damagetaken")
						local bleedMul = attacker:InsaneStats_GetAttributeValue("bleed_damage")
							* vic:InsaneStats_GetAttributeValue("bleed_damagetaken")
						
						if shouldPoison then
							vic:InsaneStats_ApplyStatusEffect(
								"poison", damage * .1 * poisonMul,
								10, {extend = 10, attacker = attacker}
							)
						end
						if shouldBleed then
							vic:InsaneStats_ApplyStatusEffect(
								"bleed", damage * .05 * bleedMul,
								10, {extend = 10, attacker = attacker}
							)
						end
						if shouldHemotoxin then
							vic:InsaneStats_ApplyStatusEffect(
								"hemotoxin", damage * .15 * poisonMul * bleedMul,
								10, {extend = 10, attacker = attacker}
							)
						end
					end
					
					local shouldFire = math.random() < attacker:InsaneStats_GetAttributeValue("fire") - 1
					local shouldFreeze = math.random() < attacker:InsaneStats_GetAttributeValue("freeze") - 1
					local shouldFrostfire = math.random() < attacker:InsaneStats_GetAttributeValue("frostfire") - 1
					
					if shouldFire or shouldFreeze or shouldFrostfire then
						local fireMul = attacker:InsaneStats_GetAttributeValue("fire_damage")
							* vic:InsaneStats_GetAttributeValue("fire_damagetaken")
						local freezeMul = attacker:InsaneStats_GetAttributeValue("freeze_damage")
							* vic:InsaneStats_GetAttributeValue("freeze_damagetaken")
						
						if shouldFire then
							vic:InsaneStats_ApplyStatusEffect("fire", damage * .1 * fireMul,
							10, {extend = 10, attacker = attacker})
						elseif shouldFreeze then
							vic:InsaneStats_ApplyStatusEffect("freeze", damage * .05 * freezeMul,
							10, {extend = 10, attacker = attacker})
						else
							vic:InsaneStats_ApplyStatusEffect("frostfire", damage * .15 * fireMul * freezeMul,
							10, {extend = 10, attacker = attacker})
						end
					end
					
					local shouldExplode = math.random() < attacker:InsaneStats_GetAttributeValue("explode") - 1
					local shouldShock = math.random() < attacker:InsaneStats_GetAttributeValue("shock") - 1
					local shouldElectroblast = math.random() < attacker:InsaneStats_GetAttributeValue("electroblast") - 1
					local shouldCosmicurse = attacker:InsaneStats_GetAttributeValue("cosmicurse") > 1

					if shouldExplode or shouldShock or shouldElectroblast or shouldCosmicurse then
						local damageType = DMG_BLAST

						if explodeCondition then
							if shouldCosmicurse then
								damageType = bit.bor(
									DMG_BLAST, DMG_SHOCK, DMG_NERVEGAS, DMG_SLASH,
									DMG_SLOWBURN, DMG_VEHICLE, DMG_ENERGYBEAM
								)
							elseif shouldElectroblast then
								damageType = bit.bor(DMG_BLAST, DMG_SHOCK)
							end
						end

						CauseDelayedDamage({
							pos = worldPos,
							attacker = attacker,
							victim = vic,
							damage = damage,
							damageTier = 2,
							explodeDamageType = explodeCondition and damageType,
							shouldShock = shouldShock
						})
					end
					
					-- delayed damage handler handles shock, these are for what happens after the explosion
					-- and entities were hit by that
					shouldElectroblast = attacker:InsaneStats_GetAttributeValue("electroblast") > 1
					if damageTier >= 1 and damageTier < 3 and (shouldElectroblast or shouldCosmicurse) then
						local electroBlastMul = attacker:InsaneStats_GetAttributeValue("shock_damage")
							* attacker:InsaneStats_GetAttributeValue("explode_damage")
							* vic:InsaneStats_GetAttributeValue("shock_damagetaken")
							* vic:InsaneStats_GetAttributeValue("explode_damagetaken")
						local nonElectroBlastMul = attacker:InsaneStats_GetAttributeValue("poison_damage")
							* attacker:InsaneStats_GetAttributeValue("bleed_damage")
							* attacker:InsaneStats_GetAttributeValue("fire_damage")
							* attacker:InsaneStats_GetAttributeValue("freeze_damage")
							* vic:InsaneStats_GetAttributeValue("poison_damagetaken")
							* vic:InsaneStats_GetAttributeValue("bleed_damagetaken")
							* vic:InsaneStats_GetAttributeValue("fire_damagetaken")
							* vic:InsaneStats_GetAttributeValue("freeze_damagetaken")
						
						if shouldElectroblast then
							vic:InsaneStats_ApplyStatusEffect(
								"electroblast", damage * .1 * electroBlastMul,
								10, {extend = 10, attacker = attacker}
							)
						end
						if shouldCosmicurse then
							vic:InsaneStats_ApplyStatusEffect(
								"cosmicurse", damage * .1 * electroBlastMul * nonElectroBlastMul
								* attacker:InsaneStats_GetAttributeValue("cosmicurse")-1,
								10, {extend = 10, attacker = attacker}
							)
						end
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
							attacker:InsaneStats_AddHealthCapped(
								(attacker:InsaneStats_GetAttributeValue("crit_lifesteal") - 1)
								* attacker:InsaneStats_GetMaxHealth()
							)
							
							attacker:InsaneStats_AddArmorNerfed(
								(attacker:InsaneStats_GetAttributeValue("crit_armorsteal") - 1)
								* attacker:InsaneStats_GetMaxArmor()
							)
							local stackMul = vic:IsPlayer() and 100 or 10
							local stacks = (attacker:InsaneStats_GetAttributeValue("critstack_damage") - 1) * stackMul
							attacker:InsaneStats_ApplyStatusEffect("stack_damage_up", stacks, 10, {amplify = true})
							stacks = (attacker:InsaneStats_GetAttributeValue("critstack_firerate") - 1) * stackMul
							attacker:InsaneStats_ApplyStatusEffect("stack_firerate_up", stacks, 10, {amplify = true})
							stacks = (attacker:InsaneStats_GetAttributeValue("critstack_defence") - 1) * stackMul
							attacker:InsaneStats_ApplyStatusEffect("stack_defence_up", stacks, 10, {amplify = true})
							stacks = (attacker:InsaneStats_GetAttributeValue("critstack_xp") - 1) * stackMul
							attacker:InsaneStats_ApplyStatusEffect("stack_xp_up", stacks, 10, {amplify = true})
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
								attacker:InsaneStats_ApplyStatusEffect("hit100_selfdamage_stacks", 1, math.huge, {amplify = true})
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
					
				if damageTier < 5 and attacker:InsaneStats_GetAttributeValue("repeat1s_damage") > 1 then
					vic:InsaneStats_ApplyStatusEffect(
						"doom", damage * (attacker:InsaneStats_GetAttributeValue("repeat1s_damage")-1),
						1, {amplify = true, attacker = attacker}
					)
				end
			end
		end

		-- SKILLS
		if IsValid(attacker) and IsValid(vic) then
			if vic:InsaneStats_EffectivelyHasSkill("ubercharge")
			and vic:InsaneStats_GetSkillState("ubercharge") == 0
			and vic:IsPlayer() then
				vic:InsaneStats_SetSkillData("ubercharge", 1, 10)
			end

			local class = vic:GetClass()
			local vicIsMob = vic:InsaneStats_IsMob()

			if attacker ~= vic and not IsValid(vic:GetParent()) then
				if (vic:InsaneStats_GetStatusEffectLevel("skill_bleed") <= 0 or damageTier < 0.5)
				and attacker:InsaneStats_EffectivelyHasSkill("the_red_plague")
				and IsValid(vic:GetPhysicsObject()) and vicIsMob then
					vic:InsaneStats_ApplyStatusEffect(
						"skill_bleed",
						1,
						attacker:InsaneStats_GetEffectiveSkillValues("the_red_plague"),
						{attacker = attacker}
					)
				end

				local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon()
				local scatterShotState = attacker:InsaneStats_GetSkillState("scattershot")
				if IsValid(wep) and scatterShotState == 1 then 
					-- check that it is a shotgun
					if dmginfo:IsDamageType(DMG_BUCKSHOT) or wep:GetPrimaryAmmoType() == 7 or wep:GetSecondaryAmmoType() == 7 then
						scatterShotEntities[vic] = true
						-- get a random nearby entity
						local traceResult = {}
						local trace = {
							start = vic:WorldSpaceCenter(),
							filter = {vic, vic.GetVehicle and vic:GetVehicle()},
							mask = MASK_SHOT,
							output = traceResult
						}
						table.Add(trace.filter, ents.FindByClass("insanestats_coin"))
						table.Add(trace.filter, ents.FindByClass("item_*"))
						
						for i,v in RandomPairs(ents.FindInPVS(trace.start)) do
							if attacker:InsaneStats_IsValidEnemy(v) and not scatterShotEntities[v] then
								local damagePos = v:HeadTarget(attacker:WorldSpaceCenter()) or v:WorldSpaceCenter()
								damagePos = damagePos:IsZero() and v:WorldSpaceCenter() or damagePos
								trace.endpos = damagePos
								util.TraceLine(trace)
								if not traceResult.Hit or traceResult.Entity == v then
									local newStacks = attacker:InsaneStats_GetSkillStacks("scattershot") - 1
									attacker:InsaneStats_SetSkillData("scattershot", newStacks >= 1 and 1 or 0, newStacks)
									local oldDamageAmount = dmginfo:GetDamage()
									dmginfo:SetDamage(4)
									if InsaneStats:IsDebugLevel(2) then
										InsaneStats:Log("Scattershot to %s!", tostring(v))
									end
									v:TakeDamageInfo(dmginfo)
									dmginfo:SetDamage(oldDamageAmount)
									if newStacks < 1 then break end
								end
							end
						end
					end
				end

				if vic:InsaneStats_EffectivelyHasSkill("hacked_shield") then
					local mult = 1 + vic:InsaneStats_GetEffectiveSkillValues("hacked_shield", 3)/100
					local minimum = vic:InsaneStats_GetEffectiveSkillValues("hacked_shield", 4)
					local currentMaxArmor = vic:InsaneStats_GetMaxArmor()
					local currentRatio = vic:InsaneStats_GetArmor() / currentMaxArmor
					if currentMaxArmor ~= minimum then
						vic:SetMaxArmor(math.max(currentMaxArmor * mult, minimum))

						if currentRatio < math.huge then
							vic:SetArmor(currentRatio * vic:InsaneStats_GetMaxArmor())
						end
					end
				end
				
				if attacker:InsaneStats_EffectivelyHasSkill("hateful") and vic.insaneStats_LastHitGroup == HITGROUP_HEAD then
					local stacks = attacker:InsaneStats_GetEffectiveSkillValues("hateful")
					vic:InsaneStats_ApplyStatusEffect("stack_defence_down", stacks, 10, {amplify = true})
				end
				
				if attacker:InsaneStats_EffectivelyHasSkill("vitality_to_go") and rechargerClasses[class]
				and dmginfo:IsDamageType(DMG_CLUB) and not vic:GetNWBool("insanestats_use") then
					vic.insaneStats_DeadToPlayers = vic.insaneStats_DeadToPlayers or {}
					if not vic.insaneStats_DeadToPlayers[attacker] then
						-- boom
						local effdata = EffectData()
						effdata:SetOrigin(vic:GetPos())
						effdata:SetEntity(vic)
						--effdata:SetMagnitude(1)
						--effdata:SetScale(1)
						--effdata:SetFlags(0)
						util.Effect("RPGShotDown", effdata)

						local stacks = 0
						if class == "func_healthcharger" or class == "item_healthcharger" then
							stacks = GetConVar("sk_healthcharger"):GetFloat()
						else
							local spawnFlags = vic:GetSpawnFlags()
							if bit.band(spawnFlags, 24576) ~= 0 then
								stacks = 45
							elseif bit.band(spawnFlags, 16384) ~= 0 then
								stacks = 25
							elseif bit.band(spawnFlags, 8192) ~= 0 then
								stacks = GetConVar("sk_suitcharger_citadel"):GetFloat() * 1.5
							else
								stacks = GetConVar("sk_suitcharger"):GetFloat()
							end
						end

						attacker:InsaneStats_SetSkillData(
							"vitality_to_go", 1,
							stacks
							* attacker:InsaneStats_GetEffectiveSkillValues("vitality_to_go") / 100
							+ attacker:InsaneStats_GetSkillStacks("vitality_to_go")
						)
						attacker:InsaneStats_ApplyDoTCustom("skill_vitality_to_go")

						vic.insaneStats_DeadToPlayers[attacker] = true

						net.Start("insane_stats")
						net.WriteUInt(12, 8)
						net.WriteEntity(vic)
						net.Send(attacker)
					end
				end

				if vicIsMob and dmginfo:IsExplosionDamage()
				and vic:InsaneStats_GetStatusEffectLevel("anger_resist") <= 0
				and attacker:InsaneStats_EffectivelyHasSkill("anger") then
					vic:InsaneStats_ApplyStatusEffect(
						"anger_resist", 1, not vic.insaneStats_IsDead and 5 or math.huge
					)
					--[[local grenadePos = dmginfo:GetDamagePosition()
					grenadePos = grenadePos:IsZero() and vic:WorldSpaceCenter() or grenadePos]]
					grenadedEntities[attacker] = grenadedEntities[attacker] or {}
					table.insert(grenadedEntities[attacker], vic:WorldSpaceCenter())
					--grenadedEntities[attacker].z = grenadedEntities[attacker].z + vic:OBBMaxs().z
				end
					
				if damageTier < 5 and attacker:InsaneStats_EffectivelyHasSkill("doom") then
					local damage = dmginfo:GetDamage()
					local damageMul = attacker:InsaneStats_GetEffectiveSkillValues("doom") / 100
					vic:InsaneStats_ApplyStatusEffect(
						"doom", damage * damageMul, 1, {amplify = true, attacker = attacker}
					)
				end

				if vicIsMob and vic:InsaneStats_GetStatusEffectLevel("stun_immune") <= 0
				and not vic.insaneStats_IsDead
				and vic:InsaneStats_GetStatusEffectLevel("stunned") <= 0
				and attacker:InsaneStats_GetSkillState("beep3") == 1 then
					vic:InsaneStats_ApplyStatusEffect("stunned", 1, 2)
					attacker:InsaneStats_SetSkillData("beep3", 0, 0)
				end

				if attacker:InsaneStats_EffectivelyHasSkill("infestation") then
					local effectLevel = attacker:InsaneStats_GetEffectiveSkillValues("infestation", 3)
					local possibleEffects = {}
					for k,v in pairs(infestationEffects) do
						if vic:InsaneStats_GetStatusEffectDuration(k) < 10
						or vic:InsaneStats_GetStatusEffectLevel(k) < v * effectLevel then
							table.insert(possibleEffects, k)
						end
					end

					if next(possibleEffects) then
						local effect = table.remove(possibleEffects, math.random(#possibleEffects))
						vic:InsaneStats_ApplyStatusEffect(
							effect, infestationEffects[effect] * effectLevel, 10,
							{attacker = attacker}
						)
					end
				end

				if attacker:InsaneStats_EffectivelyHasSkill("bloodsapper")
				and attacker:InsaneStats_IsValidEnemy(vic) then
					vic:InsaneStats_ApplyStatusEffect(
						"bloodsapped",
						attacker:InsaneStats_GetEffectiveSkillValues("bloodsapper"),
						10,
						{attacker = attacker}
					)
				end
			end

			if vic:InsaneStats_EffectivelyHasSkill("infestation") then
				local effectLevel = vic:InsaneStats_GetEffectiveSkillValues("infestation", 3)
				local possibleEffects = {}
				for k,v in pairs(infestationEffects) do
					if vic:InsaneStats_GetStatusEffectDuration(k) < 10
					or vic:InsaneStats_GetStatusEffectLevel(k) < v * effectLevel then
						table.insert(possibleEffects, k)
					end
				end

				if next(possibleEffects) then
					local effect = table.remove(possibleEffects, math.random(#possibleEffects))
					vic:InsaneStats_ApplyStatusEffect(
						effect, infestationEffects[effect] * effectLevel, 10,
						{attacker = attacker}
					)
				end
			end

			if vicIsMob and notImmune --[[and class ~= "npc_turret_floor"]] and not vic.insaneStats_IsDead then
				if vic.insaneStats_LastHitGroup == HITGROUP_HEAD then
					local healthFactor = attacker:InsaneStats_GetMaxHealth() > 0
					and 1 - math.Clamp(attacker:InsaneStats_GetHealth() / attacker:InsaneStats_GetMaxHealth(), 0, 1)
					or 0
					
					attacker:InsaneStats_AddHealthCapped(
						attacker:InsaneStats_GetEffectiveSkillValues("desperate_harvest") / 100 * healthFactor
						* attacker:InsaneStats_GetMaxHealth()
					)
				end

				attacker:InsaneStats_AddHealthCapped(
					attacker:InsaneStats_GetEffectiveSkillValues("vampiric") / 100
					* attacker:InsaneStats_GetMaxHealth()
				)

				if dmginfo:IsExplosionDamage() then
					SpawnRandomItems(
						attacker:InsaneStats_GetEffectiveSkillValues("kablooey", 2) / 100,
						vic:GetPos(), attacker
					)
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
		or math.random() * 100 < attacker:InsaneStats_GetEffectiveSkillValues("aimbot")
		if shouldAimbot then
			local bestNPC = NULL
			local bestCos = -2
			local traceResult = {}
			local trace = {
				start = attacker.GetShootPos and attacker:GetShootPos() or data.Src,
				filter = {attacker, attacker.GetVehicle and attacker:GetVehicle()},
				mask = MASK_SHOT,
				output = traceResult
			}
			
			-- get every NPC who hates us / entities we hate on the map
			local showDebug = InsaneStats:IsDebugLevel(1)
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
						if showDebug then
							debugoverlay.Cross(endPos, 10, 2, color_aqua, true)
						end
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
				if showDebug then
					debugoverlay.Cross(endPos, 10, 2, color_red, true)
				end
				data.Dir = endPos - data.Src
				data.Dir:Normalize()
			end
		end
		
		local explodeCondition = damageTiers[#damageTiers] < 1
		local shouldExplode = math.random() < attacker:InsaneStats_GetAttributeValue("explode") - 1
		local shouldElectroblast = math.random() < attacker:InsaneStats_GetAttributeValue("electroblast") - 1
		local shouldCosmicurse = attacker:InsaneStats_GetAttributeValue("cosmicurse") > 1
		local shouldSkillExplode = attacker:InsaneStats_GetSkillState("brilliant_behemoth") == 1
		
		if explodeCondition and (shouldExplode or shouldElectroblast or shouldCosmicurse or shouldSkillExplode) then
			local oldCallback = data.Callback
			data.Callback = function(attacker, trace, dmginfo, ...)
				if oldCallback then
					oldCallback(attacker, trace, dmginfo, ...)
				end
				
				if trace.Hit then
					if shouldExplode or shouldElectroblast or shouldCosmicurse then
						local damageType = DMG_BLAST
	
						if shouldCosmicurse then
							damageType = bit.bor(
								DMG_BLAST, DMG_SHOCK, DMG_NERVEGAS, DMG_SLASH,
								DMG_SLOWBURN, DMG_VEHICLE, DMG_ENERGYBEAM
							)
						elseif shouldElectroblast then
							damageType = bit.bor(DMG_BLAST, DMG_SHOCK)
						end

						CauseDelayedDamage({
							pos = trace.HitPos,
							attacker = attacker,
							victim = trace.Entity,
							damage = dmginfo:GetDamage(),
							damageTier = 1,
							explodeDamageType = damageType,
						})
					end
					if shouldSkillExplode then
						CauseExplosion({
							attacker = attacker,
							damageTier = 1,
							damage = dmginfo:GetDamage(),
							damagePos = trace.HitPos,
							damageType = DMG_BLAST,
							radius = attacker:InsaneStats_GetEffectiveSkillValues(
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

local newXP, giveXPTo
local lastXPMuls = {}
local function MultiplyXP(multiplier, cause)
	if multiplier ~= 1 then
		if giveXPTo:IsPlayer() then
			lastXPMuls[giveXPTo] = lastXPMuls[giveXPTo] or {}
			lastXPMuls[giveXPTo][cause] = multiplier
		end
		newXP = newXP * multiplier
	end
end
function InsaneStats:GetXPMultipliers()
	return lastXPMuls
end
local function CalculateXPFromSkills(attacker, victim)
	local health = attacker:InsaneStats_GetHealth()
	local maxHealth = attacker:InsaneStats_GetMaxHealth()
	local healthFactor = health == math.huge and 1 or maxHealth > 0
	and 1 - math.Clamp(health / maxHealth, 0, 1)
	or 0
	local armor = attacker:InsaneStats_GetArmor()
	local maxArmor = attacker:InsaneStats_GetMaxArmor()
	local attackerSpeedFraction = attacker:InsaneStats_GetEffectiveSpeed() / 400
	local attackerSuperColdValue = attacker:InsaneStats_GetEffectiveSkillValues("super_cold", 2) or 0
	giveXPTo = attacker
	lastXPMuls[giveXPTo] = {}
	newXP = 1

	MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("quintessence", 4) / 100, "quintessence")
	MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("xp") / 100, "xp")
	MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("guilt") / 100, "guilt")
	MultiplyXP(1 + attacker:InsaneStats_GetSkillStacks("mania")/100, "mania")
	MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("daredevil") / 100 * healthFactor, "daredevil")
	MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("jazz_feet") / 100 * attackerSpeedFraction, "jazz_feet")
	MultiplyXP(1 + attackerSuperColdValue / 100 * attacker:InsaneStats_GetSkillStacks("super_cold"), "super_cold")
	MultiplyXP(1 + attacker:InsaneStats_GetSkillStacks("keep_it_fresh")/100, "keep_it_fresh")
	MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("glass", 3) / 100, "glass")
	MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("upward_spiralling", 2) / 100, "upward_spiralling")
	MultiplyXP(1 + attacker:InsaneStats_GetSkillStacks("synergy_1") * attacker:InsaneStats_GetEffectiveSkillValues("synergy_1") / 100, "synergy_1")
	MultiplyXP(1 + attacker:InsaneStats_GetSkillStacks("synergy_2") * attacker:InsaneStats_GetEffectiveSkillValues("synergy_2", 2) / 100, "synergy_2")
	MultiplyXP(1 + attacker:InsaneStats_GetSkillStacks("better_healthcare", 3) / 100, "better_healthcare")
	MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("hellish_challenge") / 100, "hellish_challenge")
	MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("degeneration", 2) / 100, "degeneration")
	MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("bookworm", 2) / 100, "bookworm")
	MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("so_heres_the_problem") / 100, "so_heres_the_problem")

	if attacker:InsaneStats_EffectivelyHasSkill("um_what") then
		MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("um_what") / 100, "um_what")
	end

	if attacker:InsaneStats_EffectivelyHasSkill("insane_stats_skills_plus") then
		MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("insane_stats_skills_plus") / 100, "insane_stats_skills_plus")
	end

	--[[if attacker:InsaneStats_GetSkillStacks("triple_kill") >= 2 then
		newXP = newXP * (1 + attacker:InsaneStats_GetEffectiveSkillValues("triple_kill") / 100)
	end]]

	if attacker:InsaneStats_EffectivelyHasSkill("feel_the_energy") then
		local armorInverseFactor = armor == math.huge and math.huge or maxArmor > 0
			and attacker:InsaneStats_GetArmor() / maxArmor or 0
		MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("feel_the_energy")/100 * armorInverseFactor, "feel_the_energy")
	end

	if newXP == math.huge then return newXP end

	local masterfulXPFactor = attacker:InsaneStats_GetSkillStacks("multi_killer")
	masterfulXPFactor = math.max(0, masterfulXPFactor - attacker:InsaneStats_GetEffectiveSkillValues("multi_killer"))
	MultiplyXP(1 + masterfulXPFactor / 100, "multi_killer") --* (1 + math.sqrt(masterfulXPFactor))

	if attacker:InsaneStats_GetSkillStacks("back_to_back") > 0 then
		MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("back_to_back") / 100, "back_to_back")
	end
	if victim.insaneStats_LastHitGroup == HITGROUP_HEAD then
		MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("be_efficient") / 100, "be_efficient")
		MultiplyXP(1 + attacker:InsaneStats_GetStatusEffectLevel("crit_xp_up") / 100, "crit_xp_up")
	end
	if (attacker:IsPlayer() and attacker:GetSuitPower() >= 100) then
		MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("aux_aux_battery") / 100, "aux_aux_battery")
	end

	local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon()
	if (IsValid(wep) and wep.Clip1) then
		local clip1 = wep:InsaneStats_Clip1()
		local maxClip1 = wep:GetMaxClip1()
		local clip1Fraction = math.sqrt(math.max(clip1, 0) / maxClip1)
		if maxClip1 <= 0 then
			clip1Fraction = 1
		end
		MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("keep_it_ready") / 100 * clip1Fraction, "keep_it_ready")
	end

	if attacker:InsaneStats_EffectivelyHasSkill("skill_sealer") then
		local mult = attacker:InsaneStats_GetEffectiveSkillValues("skill_sealer")
		for k,v in pairs(attacker:InsaneStats_GetSealedSkills()) do
			MultiplyXP(1 + attacker:InsaneStats_GetSkillTier(k) * mult / 100, "skill_sealer")
		end
	end

	if attacker:InsaneStats_EffectivelyHasSkill("adamantite_forge") then
		if not (InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("coins_enabled")) then
			MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("adamantite_forge", 3) / 100, "adamantite_forge")
		end
	end

	local victimXP = victim:InsaneStats_GetXP()
	if victim:InsaneStats_IsBig() and victimXP > 1 and victim:InsaneStats_IsMob() then
		MultiplyXP(victimXP ^ attacker:InsaneStats_GetEffectiveSkillValues("the_bigger_they_are", 2), "the_bigger_they_are")
	end

	if attacker:InsaneStats_EffectivelyHasSkill("skystriker") then
		local gravityDir = physenv.GetGravity():GetNormalized()
		gravityDir:Mul(65536)
		local traceResult = util.TraceEntity({
			start = attacker:GetPos(),
			endpos = attacker:GetPos() + gravityDir,
			filter = attacker,
			mask = MASK_PLAYERSOLID
		}, attacker)

		local mult, distanceFactor = attacker:InsaneStats_GetEffectiveSkillValues("skystriker")
		MultiplyXP(1 + mult * traceResult.Fraction * 655.36 / distanceFactor, "skystriker")
	end

	if attacker:InsaneStats_EffectivelyHasSkill("controlled_reaction") then
		local active = 0
		for skill, skillInfo in pairs(InsaneStats:GetAllSkills()) do
			if attacker:InsaneStats_GetSkillState(skill) > 0 then
				active = active + 1
			end
		end

		MultiplyXP(1 + active * attacker:InsaneStats_GetEffectiveSkillValues("controlled_reaction") / 100, "controlled_reaction")
	end

	if attacker:InsaneStats_EffectivelyHasSkill("unseen_killer") then
		local arccos = -1

		if attacker:IsLineOfSightClear(victim) then
			local dir1 = attacker:GetAimVector()
			local pos = victim:WorldSpaceCenter()
			local dir2 = pos - attacker:GetShootPos()

			if not dir2:IsZero() then
				dir2:Normalize()
				arccos = dir1:Dot(dir2)
			end
		end

		if arccos < 0 then
			MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("unseen_killer") / 100, "unseen_killer")
		end
	end

	if attacker:InsaneStats_GetSkillState("flex") == 1 then
		MultiplyXP(1 + attacker:InsaneStats_GetEffectiveSkillValues("flex", 2) / 100, "flex")
	end

	return newXP
end

local function CalculateXP(data)
	local attacker = data.attacker
	local victim = data.victim
	
	local newXP = attacker:InsaneStats_GetAttributeValue("xp")
	* (1 + attacker:InsaneStats_GetStatusEffectLevel("xp_up") / 100)
	* (1 - attacker:InsaneStats_GetStatusEffectLevel("xp_down") / 100)
	* (1 + attacker:InsaneStats_GetStatusEffectLevel("stack_xp_up") / 100)
	* (1 + victim:InsaneStats_GetStatusEffectLevel("xp_yield_up") / 100)
	* (1 - victim:InsaneStats_GetStatusEffectLevel("xp_yield_down") / 100)
	* (1 + victim:InsaneStats_GetStatusEffectLevel("stack_xp_yield_up") / 100)

	local health = attacker:InsaneStats_GetHealth()
	local maxHealth = attacker:InsaneStats_GetMaxHealth()
	local attackerHealthFraction = health == math.huge and 1 or maxHealth > 0
		and 1-math.Clamp(health / maxHealth, 0, 1) or 0
	newXP = newXP * (1 + (attacker:InsaneStats_GetAttributeValue("lowhealth_xp") - 1) * attackerHealthFraction)
	
	if attacker:InsaneStats_GetAttributeValue("armor_xp") ~= 1 then
		local armor = attacker:InsaneStats_GetArmor()
		local maxArmor = attacker:InsaneStats_GetMaxArmor()
		local attackerArmorInverseFraction = armor == math.huge and math.huge or maxArmor > 0
			and armor / maxArmor or 0
		newXP = newXP * (1 + (attacker:InsaneStats_GetAttributeValue("armor_xp") - 1) * attackerArmorInverseFraction)
	end

	local attackerSpeedFraction = attacker:InsaneStats_GetEffectiveSpeed() / 400
	newXP = newXP * (1 + (attacker:InsaneStats_GetAttributeValue("speed_xp") - 1) * attackerSpeedFraction)

	if victim.insaneStats_LastHitGroup == HITGROUP_HEAD then
		newXP = newXP * attacker:InsaneStats_GetAttributeValue("crit_xp")
	end


	local masterfulXPFactor = attacker:InsaneStats_GetStatusEffectDuration("masterful_xp")
	masterfulXPFactor = math.sqrt(math.max(0, masterfulXPFactor - 1))
	masterfulXPFactor = masterfulXPFactor * attacker:InsaneStats_GetStatusEffectLevel("masterful_xp") / 100
	newXP = newXP * (1 + masterfulXPFactor)

	local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon()
	if (IsValid(wep) and wep.Clip1) then
		local clip1 = wep:InsaneStats_Clip1()
		local maxClip1 = wep:GetMaxClip1()
		local clip1Fraction = math.sqrt(math.max(clip1, 0) / maxClip1)
		if maxClip1 <= 0 then
			clip1Fraction = 1
		end
		newXP = newXP * (1 + (attacker:InsaneStats_GetAttributeValue("clip_xp") - 1) * clip1Fraction)
	end

	newXP = newXP * CalculateXPFromSkills(attacker, victim)
	return newXP
end

hook.Add("InsaneStatsScaleXP", "InsaneStatsWPASS2", function(data)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local attacker = data.attacker
		local inflictor = data.inflictor
		local victim = data.victim
		local newXP = data.xp
		
		if IsValid(attacker) then
			if not victim:IsPlayer() then
				if victim:InsaneStats_IsMob() then
					if attacker:InsaneStats_IsValidAlly(victim) then
						newXP = newXP * (
							attacker:InsaneStats_GetAttributeValue("ally_xp")
							+ (attacker:InsaneStats_EffectivelyHasSkill("guilt") and -2 or 0)
						)
					end
				else
					newXP = newXP * (
						attacker:InsaneStats_GetAttributeValue("prop_xp") - 1
						+ attacker:InsaneStats_GetEffectiveSkillValues("target_practice") / 100
					)
				end
			end

			local mult = CalculateXP(data)
			newXP = mult < math.huge and newXP * mult or mult
		end
		data.xp = newXP

		for k,v in pairs(entities) do
			if IsValid(k) and k ~= attacker and k ~= inflictor then
				local rewardXP = k:InsaneStats_GetAttributeValue("else_xp") - 1
				+ k:InsaneStats_GetEffectiveSkillValues("consolation_prize") / 100
		
				if not game.SinglePlayer() and k:InsaneStats_IsValidAlly(attacker) then
					rewardXP = rewardXP + k:InsaneStats_GetEffectiveSkillValues("aint_got_time_for_this") / 100
				end

				--rewardXP = rewardXP * CalculateXPFromSkills(k, victim)

				if rewardXP > 0 then
					data.receivers[k] = (data.receivers[k] or 0) + rewardXP
				end
			end
		end
	end
end)

hook.Add("InsaneStatsScaleCoins", "InsaneStatsWPASS2", function(data)
	if IsValid(data.attacker) and IsValid(data.victim) then
		data.coins = data.coins * CalculateXP(data)
		data.coins = data.coins * (1 + data.attacker:InsaneStats_GetEffectiveSkillValues("target_practice", 2) / 100)
	end
end)

local pyrotheumRadiusMul = 90
--local pyrotheumMaxDuration = 60
local pyrotheumModel = Model("models/hunter/misc/sphere375x375.mdl")
local pools = {}
local traceResult = {}
local function GetPyrotheumRadius(level)
	return pyrotheumRadiusMul * level
end
local function CreatePyrotheumPool(victim, attacker, range, limit, duration)
	local poolPos = victim:WorldSpaceCenter()
	local createNew = true
	local trace = {
		start = poolPos,
		mask = MASK_SOLID_BRUSHONLY,
		output = traceResult
	}
	--duration = duration * triggers
	local level = range / pyrotheumRadiusMul

	local toCheck = InsaneStats:GetEntitiesByStatusEffect("pyrotheum")
	for k,v in pairs(pools) do
		if IsValid(k) then
			table.insert(toCheck, k)
		else
			pools[k] = nil
		end
	end

	local ourNodes = {}
	for i,v in ipairs(toCheck) do
		-- this must be done since it can be triggered several times due to several attackers
		-- imagine if there were 1000 of them
		local radius = GetPyrotheumRadius(level)
		local theirLevel = pools[v] and pools[v].level or v:InsaneStats_GetStatusEffectLevel("pyrotheum")
		local theirDuration = pools[v] and pools[v].duration or v:InsaneStats_GetStatusEffectDuration("pyrotheum")
		local theirRadius = GetPyrotheumRadius(theirLevel)
		trace.endpos = v:WorldSpaceCenter()
		--util.TraceLine(trace)
		if --(not traceResult.Hit or traceResult.Entity == v) and
		math.max(theirRadius, radius) ^ 2 > trace.start:DistToSqr(trace.endpos) then
			local newDuration = duration + theirDuration
			local newLevel = math.max(level, theirLevel)
			local newPos = LerpVector(
				theirDuration / (duration + theirDuration),
				poolPos, v:WorldSpaceCenter()
			)
			if duration <= theirDuration then
				v:SetModelScale(newLevel)
				v:SetPos(newPos)
				if pools[v] then
					pools[v].level = newLevel
					pools[v].duration = newDuration
				else
					v:InsaneStats_ApplyStatusEffect(
						"pyrotheum", newLevel, newDuration,
						{attacker = attacker}
					)
				end
				createNew = false
				break
			else
				v:InsaneStats_ClearStatusEffect("pyrotheum")
				poolPos = newPos
				duration = newDuration
				level = newLevel
			end
		end

		if attacker == v:InsaneStats_GetStatusEffectAttacker("pyrotheum") then
			table.insert(ourNodes, v)
		end
	end

	local excess = #ourNodes - limit + 1
	if excess > 0 and createNew then
		table.sort(ourNodes, function(a, b)
			local a2 = a:InsaneStats_GetEntityData("pyrotheum_lastapplied") or CurTime()
			local b2 = b:InsaneStats_GetEntityData("pyrotheum_lastapplied") or CurTime()
			return a2 < b2
		end)
		for i,v in ipairs(ourNodes) do
			local theirLevel = pools[v] and pools[v].level or v:InsaneStats_GetStatusEffectLevel("pyrotheum")
			local theirDuration = pools[v] and pools[v].duration or v:InsaneStats_GetStatusEffectDuration("pyrotheum")
			level = math.max(level, theirLevel)
			duration = duration + theirDuration
			v:InsaneStats_ClearStatusEffect("pyrotheum")
			if i >= excess then break end
		end
	end

	if createNew then
		local pool = ents.Create("prop_dynamic")
		pool:SetPos(poolPos)
		pool:SetModel(pyrotheumModel)
		pool:Spawn()
		pool:SetModelScale(level)
		pool:SetRenderMode(RENDERMODE_TRANSCOLOR)
		pool:SetMaterial("models/props_combine/portalball001_sheet")
		pool:AddEffects(EF_NOSHADOW)
		pools[pool] = {level = level, duration = duration}

		--local level = math.max(duration / pyrotheumMaxDuration, 1)
		--local effectiveDuration = math.min(duration, pyrotheumMaxDuration)
		timer.Simple(0, function()
			pools[pool] = nil
			if IsValid(pool) then
				pool:InsaneStats_ApplyStatusEffect(
					"pyrotheum", level, duration,
					{attacker = attacker}
				)
			end
		end)
	end
end

--[[
\	MOF	0	1	2
CEL	\---------------
0	|	1	2	3
1	|	e	2e	3e
2	|	2e	4e	6e
]]
hook.Add("InsaneStatsEntityKilledOnce", "InsaneStatsSkills", function(victim, attacker, inflictor)
	if InsaneStats:GetConVarValue("skills_enabled") then
		-- who's kill skills should trigger?
		local skillAttackers = {}
		if victim ~= attacker and IsValid(attacker) then
			skillAttackers[attacker] = 1

			if (attacker.GetDriver and IsValid(attacker:GetDriver())) then
				local driver = attacker:GetDriver()
				skillAttackers[driver] = 1
			end
		end

		for k,v in pairs(InsaneStats:GetEntitiesWithSkills()) do
			local times = k:InsaneStats_GetEffectiveSkillTier("celebration")
			if k == attacker then
				times = times - 1
			end
			if times > 0 then
				skillAttackers[k] = (skillAttackers[k] or 0) + times
			end
		end

		--local bestForLDTA = {}
		local doLDTA
		local pyrotheumData = {
			attacker = attacker,
			tier = IsValid(attacker) and attacker:InsaneStats_GetEffectiveSkillTier("pyrotheum") or 0,
			duration = 0
		}
		for attacker, triggers in pairs(skillAttackers) do
			-- now... trigger!
			triggers = triggers * (1 + attacker:InsaneStats_GetEffectiveSkillTier("master_of_fire"))
			* (1 + victim:InsaneStats_GetStatusEffectLevel("kill_skill_triggerer"))

			if attacker:InsaneStats_EffectivelyHasSkill("master_of_earth") and victim:GetClass() == "item_item_crate" then
				triggers = triggers * attacker:InsaneStats_GetEffectiveSkillTier("master_of_earth")
			end

			if attacker:InsaneStats_GetSkillState("master_of_air") > -1 then
				triggers = triggers + math.floor(
					attacker:InsaneStats_GetTotalSkillPoints()
					/ attacker:InsaneStats_GetEffectiveSkillValues("master_of_air", 4)
				)
				attacker:InsaneStats_SetSkillData("master_of_air", -1, 0)
			end

			--[[if attacker:InsaneStats_EffectivelyHasSkill("more_and_more") and attacker:InsaneStats_GetArmor() > 0 then
				local armorBars = attacker:InsaneStats_GetMaxArmor() > 0
				and attacker:InsaneStats_GetArmor() / attacker:InsaneStats_GetMaxArmor()
				or 1
				local triggerMul = math.floor(math.max(2 + math.log(
					armorBars,
					attacker:InsaneStats_GetEffectiveSkillValues("more_and_more")
				), 1))
				triggers = triggers * triggerMul
			end]]

			--[[if attacker:InsaneStats_EffectivelyHasSkill("sick_combo") then
				local sickComboTriggersToParse = triggers
				local comboIncrement, addDuration, _, stackLimit, base = attacker:InsaneStats_GetEffectiveSkillValues("sick_combo")
				local combo = attacker:InsaneStats_GetStatusEffectLevel("sick_combo")
				local duration = attacker:InsaneStats_GetStatusEffectDuration("sick_combo")
				local maxDuration = 60--3.75

				-- perform this discretely, go from 0 -> 5, then 5 -> 25, and so on
				for i=1, 256 do
					if sickComboTriggersToParse <= 0 then break end
					local currentIncrement = math.max(0, math.floor(math.log(combo, base)))
					local toParse = math.ceil(math.min(
						sickComboTriggersToParse,
						(base ^ (currentIncrement + 1) - combo) / (currentIncrement + 1) / comboIncrement
					))

					combo = combo + toParse * (currentIncrement + 1) * comboIncrement
					if combo > stackLimit then
						combo = stackLimit
						toParse = sickComboTriggersToParse
					end

					triggers = triggers + toParse * currentIncrement
					--InsaneStats:Log("Changing %u triggers to %u triggers", toParse, toParse * currentIncrement)
					duration = duration + toParse * (currentIncrement + 1) * addDuration --* 2 ^ -currentIncrement
					sickComboTriggersToParse = sickComboTriggersToParse - toParse
					--maxDuration = 3.75 * 2 ^ currentIncrement
				end

				duration = math.min(duration, maxDuration)
				attacker:InsaneStats_ApplyStatusEffect("sick_combo", combo, duration)
			end]]

			if attacker:InsaneStats_EffectivelyHasSkill("infusion") then
				local maxHealth = attacker:InsaneStats_GetEffectiveSkillValues("infusion", 2) * triggers
				attacker:InsaneStats_AddMaxHealth(maxHealth)
			end
			if attacker:InsaneStats_EffectivelyHasSkill("additional_pylons") then
				local maxArmor = attacker:InsaneStats_GetEffectiveSkillValues("additional_pylons", 2) * triggers
				attacker:InsaneStats_AddMaxArmor(maxArmor)
			end
			if attacker:InsaneStats_EffectivelyHasSkill("bastion_of_flesh") then
				local skillValues = {attacker:InsaneStats_GetEffectiveSkillValues("bastion_of_flesh")}
				local maxHealth = (1-(1-skillValues[2]/100)^triggers) * attacker:InsaneStats_GetMaxArmor()
				local minimumArmor = skillValues[5]
				local currentMaxArmor = attacker:InsaneStats_GetMaxArmor()
				if currentMaxArmor > minimumArmor then
					if currentMaxArmor - maxHealth < minimumArmor then
						maxHealth = currentMaxArmor - minimumArmor
					end
					attacker:InsaneStats_AddMaxHealth(maxHealth)
					if attacker:InsaneStats_GetMaxArmor() < math.huge then
						local currentRatio = attacker:InsaneStats_GetArmor() / currentMaxArmor
						attacker:SetMaxArmor(math.max(attacker:InsaneStats_GetMaxArmor() - maxHealth, minimumArmor))
						
						if currentRatio < math.huge then
							attacker:SetArmor(currentRatio * attacker:InsaneStats_GetMaxArmor())
						end
					end
					attacker:InsaneStats_AddHealthNerfed(maxHealth * skillValues[3])
				end
			end
		
			attacker:InsaneStats_AddHealthNerfed(
				(attacker:InsaneStats_GetEffectiveSkillValues("overheal")
				+ attacker:InsaneStats_GetEffectiveSkillValues("honorbound"))
				/ 100 * attacker:InsaneStats_GetMaxHealth() * triggers
			)

			attacker:InsaneStats_AddArmorNerfed(
				attacker:InsaneStats_GetEffectiveSkillValues("overshield") / 100 * attacker:InsaneStats_GetMaxArmor() * triggers
			)
			
			local stacks = attacker:InsaneStats_GetEffectiveSkillValues("multi_killer") * triggers
			attacker:InsaneStats_SetSkillData(
				"multi_killer", 1, stacks + attacker:InsaneStats_GetSkillStacks("multi_killer")
			)

			if attacker:InsaneStats_EffectivelyHasSkill("rip_and_tear") then
				attacker:InsaneStats_SetSkillData("rip_and_tear", 1, 10)
			end
			if attacker:InsaneStats_EffectivelyHasSkill("back_to_back") then
				attacker:InsaneStats_SetSkillData("back_to_back", 1, 10)
			end
			if attacker:InsaneStats_EffectivelyHasSkill("embolden") then
				attacker:InsaneStats_SetSkillData("embolden", 1, 10)
			end
			if attacker:InsaneStats_EffectivelyHasSkill("hunting_spirit") then
				attacker:InsaneStats_SetSkillData("hunting_spirit", 1, 10)
			end
			if attacker:InsaneStats_EffectivelyHasSkill("skip_the_scenery") then
				attacker:InsaneStats_SetSkillData("skip_the_scenery", -1, 10)
			end
			if attacker:InsaneStats_EffectivelyHasSkill("kill_aura") then
				attacker:InsaneStats_SetSkillData(
					"kill_aura",
					1,
					attacker:InsaneStats_GetSkillStacks("kill_aura")
					+ attacker:InsaneStats_GetEffectiveSkillValues("kill_aura") * triggers
				)

				attacker:InsaneStats_ApplyDoTCustom("skill_kill_aura")
			end
			if attacker:InsaneStats_EffectivelyHasSkill("stabilization") then
				attacker:InsaneStats_SetSkillData("stabilization", 1, attacker:InsaneStats_GetEffectiveSkillValues("stabilization", 2))
			end
			if attacker:InsaneStats_EffectivelyHasSkill("increase_the_pressure") then
				attacker:InsaneStats_SetSkillData(
					"increase_the_pressure",
					1,
					attacker:InsaneStats_GetSkillStacks("increase_the_pressure")
					+ attacker:InsaneStats_GetEffectiveSkillValues("increase_the_pressure") * triggers
				)
			end
			--[[if attacker:InsaneStats_EffectivelyHasSkill("reject_humanity") then
				attacker:InsaneStats_SetSkillData(
					"reject_humanity",
					1,
					attacker:InsaneStats_GetSkillStacks("reject_humanity")
					+ attacker:InsaneStats_GetEffectiveSkillValues("reject_humanity") * triggers
				)
			end]]
			if attacker:InsaneStats_EffectivelyHasSkill("mania") then
				attacker:InsaneStats_SetSkillData(
					"mania",
					1,
					attacker:InsaneStats_GetSkillStacks("mania")
					+ attacker:InsaneStats_GetEffectiveSkillValues("mania") * triggers
				)
			end
			if attacker:InsaneStats_EffectivelyHasSkill("starlight") then
				attacker:InsaneStats_SetSkillData(
					"starlight",
					1,
					attacker:InsaneStats_GetSkillStacks("starlight")
					+ attacker:InsaneStats_GetEffectiveSkillValues("starlight") * triggers
				)
			end
			--[[if attacker:InsaneStats_EffectivelyHasSkill("triple_kill") then
				local newStacks = (attacker:InsaneStats_GetSkillStacks("triple_kill") + triggers) % 3
				attacker:InsaneStats_SetSkillData(
					"triple_kill",
					newStacks >= 2 and 1 or 0,
					newStacks
				)
			end]]
			if attacker:InsaneStats_EffectivelyHasSkill("killing_spree") then
				attacker:InsaneStats_ApplyStatusEffect(
					"killing_spree",
					triggers,
					60,
					{amplify = true}
				)

				local effectLevel = math.log(attacker:InsaneStats_GetStatusEffectLevel("killing_spree"), 5)
				local effectsToApply = effectLevel * triggers
				local possibleEffects = {}
				for i,v in ipairs(killingSpreeEffects) do
					if i <= attacker:InsaneStats_GetEffectiveSkillTier("killing_spree") then
						for k,v2 in pairs(v) do
							if attacker:InsaneStats_GetStatusEffectDuration(k) < 10
							or attacker:InsaneStats_GetStatusEffectLevel(k) < v2 * effectLevel then
								table.insert(possibleEffects, {k, v2 * effectLevel})
							end
						end
					end
				end
				for i=1, effectsToApply do
					if table.IsEmpty(possibleEffects) then break end
					local effect = table.remove(possibleEffects, math.random(#possibleEffects))
					attacker:InsaneStats_ApplyStatusEffect(effect[1], effect[2], 10)
				end
			end
			if attacker:InsaneStats_EffectivelyHasSkill("keep_it_fresh") then
				local setStacks, decayStacks = attacker:InsaneStats_GetEffectiveSkillValues("keep_it_fresh")
				local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon()
				if wep == attacker.insaneStats_LastKIFWeapon then
					local newStacks = math.max(attacker:InsaneStats_GetSkillStacks("keep_it_fresh") + decayStacks * triggers, 0)
					attacker:InsaneStats_SetSkillData("keep_it_fresh", newStacks > 0 and 1 or 0, newStacks)
				else
					attacker:InsaneStats_SetSkillData("keep_it_fresh", 1, setStacks)
				end
				attacker.insaneStats_LastKIFWeapon = wep
			end
			local addStacks = 0
			if attacker:InsaneStats_EffectivelyHasSkill("synergy_1") then
				addStacks = 0.1
			end
			if attacker:InsaneStats_EffectivelyHasSkill("synergy_4") then
				addStacks = addStacks + 0.1
			end
			if addStacks ~= 0 then
				local stacks = math.max(
					attacker:InsaneStats_GetSkillStacks("synergy_1"),
					attacker:InsaneStats_GetSkillStacks("synergy_2"),
					attacker:InsaneStats_GetSkillStacks("synergy_3"),
					attacker:InsaneStats_GetSkillStacks("synergy_4")
				)
				addStacks = addStacks * triggers

				attacker:InsaneStats_SetSkillData("synergy_1", 1, stacks + addStacks)
				attacker:InsaneStats_SetSkillData("synergy_2", 1, stacks + addStacks)
				attacker:InsaneStats_SetSkillData("synergy_3", 1, stacks + addStacks)
				attacker:InsaneStats_SetSkillData("synergy_4", 1, stacks + addStacks)
			end

			local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon()
			if IsValid(wep) then
				local ammoMul = (
					attacker:InsaneStats_GetEffectiveSkillValues("productivity", 3) / 100
					+ attacker:InsaneStats_GetStatusEffectLevel("ammo_stealer") / 100
				) * triggers
				if ammoMul > 0 then
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

					--clip1ToAdd = math[math.random() < clip1ToAdd % 1 and "ceil" or "floor"](clip1ToAdd)
					--clip2ToAdd = math[math.random() < clip2ToAdd % 1 and "ceil" or "floor"](clip2ToAdd)

					if clip1ToAdd > 0 then
						if maxClip1 > 0 then
							wep:SetClip1(math.min(wep:InsaneStats_Clip1() + clip1ToAdd, 2147483647))
						elseif attacker:IsPlayer() then
							attacker:GiveAmmo(clip1ToAdd, ammoType1)
						end
					end
					if clip2ToAdd > 0 then
						if maxClip2 > 0 then
							wep:SetClip2(math.min(wep:InsaneStats_Clip2() + clip2ToAdd, 2147483647))
						elseif attacker:IsPlayer() then
							attacker:GiveAmmo(clip2ToAdd, ammoType2)
						end
					end
				end
			end

			local chance = attacker:InsaneStats_GetEffectiveSkillValues("looting") / 100
			SpawnRandomItems(chance, victim:GetPos(), attacker, triggers)

			if attacker:InsaneStats_EffectivelyHasSkill("kill_at_first_hit") and attacker.GetWeapons
			and attacker:IsPlayer() then
				local hasMelee = false
				for i,v in ipairs(attacker:GetWeapons()) do
					local ht = v:GetHoldType()
					if ht == "melee" or ht == "melee2" or ht == "knife" or ht == "fist" then
						hasMelee = true
						break
					end
				end

				if hasMelee then
					chance = attacker:InsaneStats_GetEffectiveSkillValues("kill_at_first_hit") / 100 * triggers

					--[[if attacker:InsaneStats_EffectivelyHasSkill("too_many_items") or not attacker:IsPlayer() then
						attacker:InsaneStats_SetSkillData(
							"too_many_items", 0, attacker:InsaneStats_GetSkillStacks("too_many_items")
							+ attacker:InsaneStats_GetEffectiveSkillValues("too_many_items", 2)
							* chance * GetItemMultiplier(attacker)
						)
					else
						chance = (math.random() < chance % 1 and math.ceil or math.floor)(chance)
						if chance > 0 then
							local position = victim:GetPos()
							if position:DistToSqr(attacker:GetPos())
							< attacker:InsaneStats_GetEffectiveSkillValues("item_magnet") ^ 2 then
								position = attacker:GetPos()
							end

							local item = ents.Create("weapon_crowbar")
							item:SetPos(position)
							item:Spawn()
							item:Activate()
							item:SetCollisionGroup(COLLISION_GROUP_WORLD)
							item.insaneStats_TempKillSkillTriggerer = chance - 1
						end
					end]]
					
					chance = (math.random() < chance % 1 and math.ceil or math.floor)(chance)
					if chance > 0 then
						attacker:InsaneStats_SetSkillData(
							"kill_at_first_hit", 1, attacker:InsaneStats_GetSkillStacks("kill_at_first_hit")
							+ 25 * chance
						)
					end
				end
			end
			
			if victim:InsaneStats_IsBig() and victim:InsaneStats_IsMob()
			and attacker:InsaneStats_EffectivelyHasSkill("the_bigger_they_are") then
				-- merge with crates that are in a 64^3 area centered on the item crate
				local testPos = victim:WorldSpaceCenter()
				local mergeWith
				for i,v in ipairs(ents.FindByClass("item_item_crate")) do
					if v:GetInternalVariable("ItemClass") == "item_dynamic_resupply"
					and v:GetPos():DistToSqr(testPos) < 4096 then
						mergeWith = v break
					end
				end
				if mergeWith then
					mergeWith:Fire("AddOutput", string.format(
						"ItemCount %u",
						math.min(attacker:InsaneStats_GetEffectiveSkillValues("the_bigger_they_are")
						+ mergeWith:GetInternalVariable("ItemCount"), 64)
					))
					if mergeWith.insaneStats_TempKillSkillTriggerer then
						mergeWith.insaneStats_TempKillSkillTriggerer = mergeWith.insaneStats_TempKillSkillTriggerer + triggers
					else
						mergeWith:InsaneStats_ApplyStatusEffect("kill_skill_triggerer", triggers, math.huge, {amplify = true})
					end
				else
					local crate = ents.Create("item_item_crate")
					crate:SetKeyValue("ItemClass", "item_dynamic_resupply")
					crate:SetKeyValue(
						"ItemCount",
						attacker:InsaneStats_GetEffectiveSkillValues("the_bigger_they_are")
					)
					crate:SetPos(victim:GetPos())
					crate:Spawn()
					crate:Activate()
					crate.insaneStats_TempKillSkillTriggerer = triggers - 1
				end
			end

			if attacker:InsaneStats_EffectivelyHasSkill("pyrotheum") then
				local duration = attacker:InsaneStats_GetEffectiveSkillValues("pyrotheum", 3)
				pyrotheumData.duration = pyrotheumData.duration + duration * triggers
				
				local tier = attacker:InsaneStats_GetEffectiveSkillTier("pyrotheum")
				if pyrotheumData.tier < tier then
					--pyrotheumData.attacker = attacker
					pyrotheumData.tier = tier
				end
			end

			if not doLDTA and victim:InsaneStats_IsMob()
			and victim:InsaneStats_GetStatusEffectLevel("no_skill_forced_respawning") <= 0 then
				local failChance = (1 - attacker:InsaneStats_GetEffectiveSkillValues("lets_do_that_again") / 100) ^ triggers
				doLDTA = math.random() >= failChance
			end

			if attacker:InsaneStats_GetSkillState("flex") == 0 then
				local choices = {
					{"disagree", ACT_GMOD_GESTURE_DISAGREE},
					{"becon", ACT_GMOD_GESTURE_BECON},
					{"halt", ACT_SIGNAL_HALT},
					{"pers", ACT_GMOD_TAUNT_PERSISTENCE},
					{"muscle", ACT_GMOD_TAUNT_MUSCLE},
					{"laugh", ACT_GMOD_TAUNT_LAUGH},
					{"cheer", ACT_GMOD_TAUNT_CHEER},
					{"zombie", ACT_GMOD_GESTURE_TAUNT_ZOMBIE},
					{"dance", ACT_GMOD_TAUNT_DANCE},
					{"robot", ACT_GMOD_TAUNT_ROBOT}
				}

				local choice = choices[math.random(#choices)]
				attacker:ConCommand(string.format("act %s", choice[1]))

				local addDuration = attacker:SequenceDuration(attacker:SelectWeightedSequence(choice[2]))
				attacker:InsaneStats_ApplyStatusEffect("speed_down", 100, addDuration)
				attacker:InsaneStats_ApplyStatusEffect("invincible", 1, addDuration)
				attacker:InsaneStats_SetSkillData(
					"flex", 1,
					attacker:InsaneStats_GetEffectiveSkillValues("flex", 3) + addDuration
				)
			end

			attacker:InsaneStats_SetSkillData("honorbound", 0, 0)
		end

		if pyrotheumData.tier > 0 and (IsValid(pyrotheumData.attacker)
		and pyrotheumData.attacker:InsaneStats_EffectivelyHasSkill("pyrotheum"))
		and victim:GetClass() ~= "info_null" then
			local range, _, limit = pyrotheumData.attacker:InsaneStats_GetEffectiveSkillValues("pyrotheum")
			CreatePyrotheumPool(victim, pyrotheumData.attacker, range, limit, pyrotheumData.duration)
		end

		--local attacker = bestForLDTA[1]
		if doLDTA and (victim:IsNPC() or victim:IsNextBot()) then
			--local xpBonus = attacker:InsaneStats_GetEffectiveSkillValues("lets_do_that_again")
			local class = victim:GetClass()
			local spawnFlags = bit.band(victim:GetSpawnFlags(), bit.bnot(bit.bor(128, 2048)))
			local effectPos = victim:WorldSpaceCenter()
			local effectRadius = victim:BoundingRadius()
			local pos = victim:GetPos() + vector_up
			local angles = victim:GetAngles()
			local wepClass = victim.GetActiveWeapon and victim:GetActiveWeapon()
			wepClass = IsValid(wepClass) and wepClass:GetClass()
			local mins, maxs = victim:GetCollisionBounds()
			local trace = {
				start = pos, endpos = pos,
				mins = mins, maxs = maxs,
				output = traceResult
			}

			local duration = victim:InsaneStats_IsBig() and 8+math.random() or 4+math.random()
			local effData = EffectData()
			effData:SetOrigin(effectPos)
			effData:SetMagnitude(duration)
			effData:SetRadius(effectRadius)
			util.Effect("insane_stats_shorttimer", effData)

			local isNPC = victim:IsNPC()
			timer.Simple(duration, function()
				trace.mask = MASK_NPCSOLID
				util.TraceHull(trace)
				if traceResult.Hit or IsValid(victim) then
					local effData = EffectData()
					effData:SetOrigin(effectPos)
					effData:SetMagnitude(1)
					effData:SetRadius(effectRadius)
					util.Effect("insane_stats_x", effData)
				else
					local newEnt = ents.Create(class)
					newEnt:SetPos(pos)
					newEnt:SetAngles(angles)
					newEnt:SetSpawnFlags(spawnFlags)
					if wepClass then
						newEnt:SetKeyValue("additionalequipment", wepClass)
					end
					newEnt:Spawn()
					newEnt:Activate()
					newEnt.insaneStats_TempLDTA = true
					if isNPC then newEnt:AddRelationship("player D_HT 99") end
				end
			end)
		end

		--[[if victim:InsaneStats_GetStatusEffectLevel("ion_cannon_target") > 0 then
			local applier = victim:InsaneStats_GetStatusEffectAttacker("ion_cannon_target")
			if IsValid(applier) then
				applier:InsaneStats_SetSkillData("ion_cannon", 0, 0)
			end
			-- FIXME: directly changing a field is bad
			victim.insaneStats_StatusEffects.ion_cannon_target.attacker = nil
			victim:InsaneStats_ClearStatusEffect("ion_cannon_target")
		end]]
	end

	if attacker.insaneStats_MarkedEntity == victim then
		timer.Simple(0, function()
			if IsValid(attacker) then
				local shouldMark = attacker:InsaneStats_GetAttributeValue("mark") > 1
				or attacker:InsaneStats_EffectivelyHasSkill("alert")
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
							net.WriteBool(false)
							net.WriteUInt(ent:EntIndex(), 16)
							net.WriteVector(pos)
							net.WriteString(ent:GetClass())
							net.WriteDouble(ent:InsaneStats_GetHealth())
							net.WriteDouble(ent:InsaneStats_GetMaxHealth())
							net.WriteDouble(ent:InsaneStats_GetArmor())
							net.WriteDouble(ent:InsaneStats_GetMaxArmor())
							net.WriteBool(select(3, ColorToHSL(ent:GetColor())) < 0.05)
							net.Send(attacker)
						elseif (attacker:IsNPC() and attacker:Disposition(ent) == D_HT
						and attacker.HasEnemyEluded and attacker:HasEnemyEluded(ent)) then
							attacker:UpdateEnemyMemory(ent, ent:GetPos())
						end
					elseif IsValid(attacker.insaneStats_MarkedEntity) then
						attacker.insaneStats_MarkedEntity = NULL

						if attacker:IsPlayer() then
							net.Start("insane_stats")
							net.WriteUInt(4, 8)
							net.WriteBool(false)
							net.WriteUInt(0, 16)
							net.Send(attacker)
						end
					end
				end
			end
		end)
	end
end)

function InsaneStats:TestPyrotheumPool(ply, range, duration)
	ply:InsaneStats_SetEntityData("pyrotheum_debug", true)
	return CreatePyrotheumPool(ply, ply, range, duration, 1)
end

hook.Add("InsaneStatsEntityKilledOnce", "InsaneStatsWPASS2", function(victim, attacker, inflictor)
	if InsaneStats:GetConVarValue("wpass2_enabled") and IsValid(attacker) then
		if (attacker:IsVehicle() and attacker:IsValidVehicle() and IsValid(attacker:GetDriver())) then
			attacker = attacker:GetDriver()
		end

		if victim ~= attacker then
			attacker:InsaneStats_AddHealthCapped(
				(attacker:InsaneStats_GetAttributeValue("kill_lifesteal") - 1)
				* attacker:InsaneStats_GetMaxHealth()
			)
			--print(attacker:InsaneStats_GetHealth(), healthRestored, attacker:InsaneStats_GetMaxHealth())
			
			attacker:InsaneStats_AddArmorNerfed(
				(attacker:InsaneStats_GetAttributeValue("kill_armorsteal") - 1)
				* attacker:InsaneStats_GetMaxArmor()
			)
			
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
				
				if clip1Used then
					wep:SetClip1(math.min(wep:InsaneStats_Clip1()+ammoToGive1, 2147483647))
				elseif isPlayer then
					attacker:GiveAmmo(ammoToGive1, wep:GetPrimaryAmmoType())
				end
				
				if clip2Used then
					wep:SetClip2(math.min(wep:InsaneStats_Clip2()+ammoToGive2, 2147483647))
				elseif isPlayer then
					attacker:GiveAmmo(ammoToGive2, wep:GetSecondaryAmmoType())
				end
			end
			
			local stackMul = victim:IsPlayer() and 100 or 10
			local stacks = (attacker:InsaneStats_GetAttributeValue("killstack_damage") - 1) * stackMul
			attacker:InsaneStats_ApplyStatusEffect("stack_damage_up", stacks, 10, {amplify = true})
			stacks = (attacker:InsaneStats_GetAttributeValue("killstack_defence") - 1) * stackMul
			attacker:InsaneStats_ApplyStatusEffect("stack_defence_up", stacks, 10, {amplify = true})
			stacks = (attacker:InsaneStats_GetAttributeValue("killstack_xp") - 1) * stackMul
			attacker:InsaneStats_ApplyStatusEffect("stack_xp_up", stacks, 10, {amplify = true})
			stacks = (attacker:InsaneStats_GetAttributeValue("killstack_firerate") - 1) * stackMul
			attacker:InsaneStats_ApplyStatusEffect("stack_firerate_up", stacks, 10, {amplify = true})
			stacks = (attacker:InsaneStats_GetAttributeValue("killstack_damagetaken") - 1) * stackMul
			attacker:InsaneStats_ApplyStatusEffect("stack_defence_down", stacks, 10, {amplify = true})
			
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill10s_damage") - 1) * 100
			if stacks < 0 then
				attacker:InsaneStats_ApplyStatusEffect("damage_down", -stacks, 10)
			elseif stacks > 0 then
				attacker:InsaneStats_ApplyStatusEffect("damage_up", stacks, 10)
			end
			
			stacks = (1 / attacker:InsaneStats_GetAttributeValue("kill10s_damagetaken") - 1) * 100
			if stacks < 0 then
				attacker:InsaneStats_ApplyStatusEffect("defence_down", -stacks, 10)
			elseif stacks > 0 then
				attacker:InsaneStats_ApplyStatusEffect("defence_up", stacks, 10)
			end
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill10s_firerate") - 1) * 100
			if stacks < 0 then
				attacker:InsaneStats_ApplyStatusEffect("firerate_down", -stacks, 10)
			elseif stacks > 0 then
				attacker:InsaneStats_ApplyStatusEffect("firerate_up", stacks, 10)
			end
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill10s_xp") - 1) * 100
			if stacks > 0 then
				attacker:InsaneStats_ApplyStatusEffect("xp_up", stacks, 10)
			end
			
			stacks = (1 / attacker:InsaneStats_GetAttributeValue("kill10s_ammo_consumption") - 1) * 100
			if stacks > 0 then
				attacker:InsaneStats_ApplyStatusEffect("ammo_efficiency_up", stacks, 10)
			end
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill10s_regen") - 1) * 100
			if stacks > 0 then
				attacker:InsaneStats_ApplyStatusEffect("regen", stacks, 10)
			end
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill10s_armorregen") - 1) * 100
			if stacks > 0 then
				attacker:InsaneStats_ApplyStatusEffect("armor_regen", stacks, 10)
			end
			
			stacks = attacker:InsaneStats_GetAttributeValue("kill10s_damageaura") - 1
			if stacks > 0 then
				attacker:InsaneStats_ApplyStatusEffect("damage_aura", stacks, 10)
			end
			
			local duration = attacker:InsaneStats_GetAttributeValue("starlight") - 1
			attacker:InsaneStats_ApplyStatusEffect("starlight", 1, duration)
			
			if attacker:InsaneStats_IsValidAlly(victim) then
				stacks = (1 - attacker:InsaneStats_GetAttributeValue("kill10s_ally_damage")) * 100
				if stacks > 0 then
					attacker:InsaneStats_ApplyStatusEffect("damage_down", stacks, 10)
				end
			end
			
			if attacker.insaneStats_MarkedEntity == victim then
				stacks = (attacker:InsaneStats_GetAttributeValue("killstackmarked_damage") - 1) * stackMul
				attacker:InsaneStats_ApplyStatusEffect("stack_damage_up", stacks, 10, {amplify = true})
				stacks = (attacker:InsaneStats_GetAttributeValue("killstackmarked_defence") - 1) * stackMul
				attacker:InsaneStats_ApplyStatusEffect("stack_defence_up", stacks, 10, {amplify = true})
				stacks = (attacker:InsaneStats_GetAttributeValue("killstackmarked_xp") - 1) * stackMul
				attacker:InsaneStats_ApplyStatusEffect("stack_xp_up", stacks, 10, {amplify = true})
			end
			
			SpawnRandomItems(
				attacker:InsaneStats_GetAttributeValue("kill_supplychance") - 1,
				victim:GetPos(), attacker
			)
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill1s_xp") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("masterful_xp", stacks, 1, {extend = true})
		end
	end
end)

hook.Add("InsaneStatsEntityKilledPostXP", "InsaneStatsSkills", function(victim, attacker, inflictor)
	if InsaneStats:GetConVarValue("skills_enabled") then
		-- multitrigger is pointless, at least for now
		local skillAttackers = {}
		if victim ~= attacker and IsValid(attacker) then
			--for i=0, attacker:InsaneStats_GetEffectiveSkillTier("master_of_fire") do
				table.insert(skillAttackers, attacker)
				if (attacker.GetDriver and IsValid(attacker:GetDriver())) then
					table.insert(skillAttackers, attacker:GetDriver())
				end
			--end
		end

		for k,v in pairs(InsaneStats:GetEntitiesWithSkills()) do
			local triggers = 1 --+ k:InsaneStats_GetEffectiveSkillTier("master_of_fire")
			local times = k:InsaneStats_GetEffectiveSkillTier("celebration") * triggers
			if k == attacker then
				times = times - triggers
			end
			if times > 0 then--for i=1, times do
				table.insert(skillAttackers, k)
			end
		end

		for i,v in ipairs(skillAttackers) do
			if v:InsaneStats_GetSkillState("fight_for_your_life") == 1 then
				v:SetHealth(v:InsaneStats_GetMaxHealth())
				v:InsaneStats_SetSkillData("fight_for_your_life", 0, v.insaneStats_FFYLStacksAdd or 0)

				local name = v:GetName() ~= "" and v:GetName() or v:GetClass()
				PrintMessage(HUD_PRINTTALK, name.." is back up!")
			end
		end
	end
end)

local function UpdateWeaponDeploySpeed(owner, wep)
	local desiredDeploySpeedMul = owner:InsaneStats_GetAttributeValue("switch_speed")
	* (1 + owner:InsaneStats_GetEffectiveSkillValues("responsive_movement", 3) / 100)
	if desiredDeploySpeedMul ~= wep.insaneStats_OldDeploySpeedMul
	or owner ~= wep.insaneStats_OldDeploySpeedOwner then
		local newDeploySpeed = desiredDeploySpeedMul / (wep.insaneStats_OldDeploySpeedMul or 1) * wep:GetDeploySpeed()
		wep:SetDeploySpeed(newDeploySpeed)
		if owner:IsPlayer() then
			net.Start("insane_stats")
			net.WriteUInt(12, 8)
			net.WriteEntity(wep)
			net.WriteFloat(wep:GetDeploySpeed())
			net.Send(owner)
		end
		wep.insaneStats_OldDeploySpeedMul = desiredDeploySpeedMul
		wep.insaneStats_OldDeploySpeedOwner = owner
	end
end

local function DoItemPickupTriggers(ply, item, class)
	local ignoreWPASS2Pickup = (item.insaneStats_DisableWPASS2Pickup or 0) > RealTime()
	local deleteItem

	if (class == "weapon_crowbar" or class == "weapon_physcannon")
	and ply:InsaneStats_EffectivelyHasSkill("kill_at_first_hit") then
		local shouldAutoPickup = ply:InsaneStats_ShouldAutoPickup(item)
		if (shouldAutoPickup or ignoreWPASS2Pickup) and ply:HasWeapon(class) then
			ply:InsaneStats_SetSkillData(
				"kill_at_first_hit", 1, ply:InsaneStats_GetSkillStacks("kill_at_first_hit") + 25
			)
			deleteItem = true
		end
	end
	
	if (class == "item_battery"
	or class == "weapon_stunstick" and ply:HasWeapon("weapon_stunstick")
	or class == "weapon_medkit" and ply:HasWeapon("weapon_medkit")) then
		local overLoadedArmor = (
			ply:InsaneStats_GetAttributeValue("armor_fullpickup") ~= 1
			and ply:InsaneStats_GetAttributeValue("armor_fullpickup")
			or 0
		)

		if ply:InsaneStats_EffectivelyHasSkill("boundless_shield") then
			if ply:InsaneStats_GetEffectiveSkillTier("boundless_shield") > 2 or class ~= "weapon_stunstick" then
				overLoadedArmor = overLoadedArmor + 1
			end
		end
		
		local shouldAutoPickup = ply:InsaneStats_ShouldAutoPickup(item)
		if (shouldAutoPickup or ignoreWPASS2Pickup) and overLoadedArmor > 0 then
			if class == "weapon_medkit" then
				ply:InsaneStats_AddHealthNerfed(
					GetConVar("sk_healthkit"):GetFloat()
					* ply:InsaneStats_GetCurrentHealthAdd()
				)
				
				ply:EmitSound("HealthKit.Touch")
				net.Start("insane_stats")
				net.WriteUInt(2, 8)
				net.WriteString("item_healthkit")
				net.Send(ply)

				deleteItem = true
			else
				local expectedArmor = GetConVar("sk_battery"):GetFloat() * ply:InsaneStats_GetCurrentArmorAdd()
				* (class == "weapon_stunstick" and 0.5 or 1)

				local currentArmor = ply:InsaneStats_GetArmor()
				local maxArmor = ply:InsaneStats_GetMaxArmor()
				if currentArmor + expectedArmor > maxArmor then
					if currentArmor < maxArmor then
						-- directly set the armor independently from armor-reducing effects
						expectedArmor = expectedArmor - maxArmor + currentArmor
						ply:SetArmor(maxArmor)
					end
					expectedArmor = expectedArmor * overLoadedArmor
					
					ply:InsaneStats_AddArmorNerfed(expectedArmor)
					
					ply:EmitSound("ItemBattery.Touch")
					net.Start("insane_stats")
					net.WriteUInt(2, 8)
					net.WriteString("item_battery")
					net.Send(ply)
					
					deleteItem = true
				end
			end
		end
	end

	if item:IsWeapon() and ply:InsaneStats_EffectivelyHasSkill("productivity")
	and ply:HasWeapon(class) then
		local mul = 1 + ply:InsaneStats_GetEffectiveSkillValues("productivity", 2) / 100
		local ammoToGive1 = {item:GetPrimaryAmmoType(), item:GetMaxClip1() * mul}
		local ammoToGive2 = {item:GetSecondaryAmmoType(), item:GetMaxClip2() * mul}
		if ammoToGive1[1] > 0 then
			if ammoToGive1[2] <= 0 then
				ammoToGive1[2] = game.GetAmmoMax(ammoToGive1[1]) * mul
			end
			ply:GiveAmmo(ammoToGive1[2], ammoToGive1[1])
		end
		if ammoToGive2[1] > 0 then
			if ammoToGive2[2] <= 0 then
				ammoToGive2[2] = game.GetAmmoMax(ammoToGive2[1]) * mul
			end
			ply:GiveAmmo(ammoToGive2[2], ammoToGive2[1])
		end
		deleteItem = true
	end
	
	hook.Run("InsaneStatsPlayerPickedUpItem", ply, item)

	if deleteItem then
		item:Remove()
		return false
	end
end

local function AttemptDupeEntity(ply, item)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local itemHasNoModifiers = not item:InsaneStats_IsWPASS2Pickup() or (item.insaneStats_Tier or 0) == 0
		local itemPickupCooldownElapsed = (item.insaneStats_NextPickup or 0) < CurTime()

		if InsaneStats:IsDebugLevel(4) then
			InsaneStats:Log("%s is trying to pick up %s", tostring(ply), tostring(item))
		end
		
		if itemPickupCooldownElapsed then
			local class = item:GetClass()

			if not item.insaneStats_Duplicated and itemHasNoModifiers
			and not (item:IsWeapon() and item:IsScripted())
			and class ~= "item_suit" then
				-- do not duplicate if too many duplicates are within PVS
				local duplicates = {}
				local itemLimit = InsaneStats:GetConVarValue("wpass2_item_limit")
				if itemLimit >= 0 then
					for i,v in ipairs(ents.FindInPVS(item:WorldSpaceCenter())) do
						if v:GetClass() == class and v.insaneStats_Duplicated then
							table.insert(duplicates, v)
						end
					end
				end
				if #duplicates <= itemLimit or itemLimit < 0 then
					item.insaneStats_Duplicated = true
					
					duplicates = ply:InsaneStats_GetAttributeValue("copying")
					* (1 + ply:InsaneStats_GetEffectiveSkillValues("productivity") / 100)
					* (1 + ply:InsaneStats_GetStatusEffectLevel("item_duplicator")) - 1
					duplicates = (math.random() < duplicates % 1 and math.ceil or math.floor)(duplicates)
					
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
						itemDuplicate:SetCollisionGroup(COLLISION_GROUP_WORLD)
					end
				else
					for i,v in ipairs(duplicates) do
						if (v:InsaneStats_GetEntityData("item_teleported") or 0) + 1 < CurTime() then
							v:InsaneStats_SetEntityData("item_teleported", CurTime())
							v:SetPos(ply:WorldSpaceCenter())
							v.insaneStats_PreventMagnet = 100
						end
					end

					if #duplicates <= itemLimit * 2 then return false end
				end
			end

			if not item:GetNWBool("insanestats_use") then
				local ret = DoItemPickupTriggers(ply, item, class)
				if ret ~= nil then return ret end
			end
		end

		if item:IsWeapon() then
			UpdateWeaponDeploySpeed(ply, item)
		end

		item.insaneStats_PreventMagnet = (item.insaneStats_PreventMagnet or 0) + 1

		if InsaneStats:IsDebugLevel(4) then
			InsaneStats:Log("Allowed pickup on Skill System's end")
		end
	end
end

hook.Add("InsaneStatsPlayerCanPickupItem", "InsaneStatsWPASS2", AttemptDupeEntity)
hook.Add("InsaneStatsPlayerCanPickupWeapon", "InsaneStatsWPASS2", AttemptDupeEntity)

hook.Add("InsaneStatsPlayerPickedUpItem", "InsaneStatsWPASS2", function(ply, item, count)
	count = count or 1
	if InsaneStats:GetConVarValue("skills_enabled") then
		--[[local statusEffectLevel = ply:InsaneStats_GetStatusEffectLevel("sick_combo")
		if not item:InsaneStats_GetEntityData("sick_comboed")
		and ply:InsaneStats_EffectivelyHasSkill("sick_combo")
		and statusEffectLevel > 0 then
			item:InsaneStats_SetEntityData("sick_comboed", true)
			local durationAdd = ply:InsaneStats_GetEffectiveSkillValues("sick_combo", 2)
			--local currentIncrement = math.max(0, math.floor(math.log(statusEffectLevel, base)))
	
			local duration = math.min(
				ply:InsaneStats_GetStatusEffectDuration("sick_combo")
				+ durationAdd * count,-- * 2 ^ (-currentIncrement-1),
				60--3.75 * 2 ^ currentIncrement
			)
			ply:InsaneStats_ApplyStatusEffect("sick_combo", statusEffectLevel, duration)
		end]]
	
		--[[if not item:InsaneStats_GetEntityData("synergized") and (
			ply:InsaneStats_EffectivelyHasSkill("synergy_1")
			or ply:InsaneStats_EffectivelyHasSkill("synergy_2")
		) then]]
		local addStacks = 0
		if ply:InsaneStats_EffectivelyHasSkill("synergy_1") then
			addStacks = 0.1
		end
		if ply:InsaneStats_EffectivelyHasSkill("synergy_2") then
			addStacks = addStacks + 0.1
		end
		if addStacks ~= 0 and not item:InsaneStats_GetEntityData("synergized") then
			item:InsaneStats_SetEntityData("synergized", true)
			
			local stacks = math.max(
				ply:InsaneStats_GetSkillStacks("synergy_1"),
				ply:InsaneStats_GetSkillStacks("synergy_2"),
				ply:InsaneStats_GetSkillStacks("synergy_3"),
				ply:InsaneStats_GetSkillStacks("synergy_4")
			)
			addStacks = addStacks * count
	
			ply:InsaneStats_SetSkillData("synergy_1", 1, stacks + addStacks)
			ply:InsaneStats_SetSkillData("synergy_2", 1, stacks + addStacks)
			ply:InsaneStats_SetSkillData("synergy_3", 1, stacks + addStacks)
			ply:InsaneStats_SetSkillData("synergy_4", 1, stacks + addStacks)
		end
		
		local tmiTriggerer = item:InsaneStats_GetEntityData("tmi_triggerer")
		if not item:InsaneStats_GetEntityData("tmi_triggered") and not tmiTriggerer
		and ply:InsaneStats_EffectivelyHasSkill("too_many_items") then
			item:InsaneStats_SetEntityData("tmi_triggered", true)
			ply:InsaneStats_SetSkillData(
				"too_many_items", 0,
				ply:InsaneStats_GetSkillStacks("too_many_items")
				+ ply:InsaneStats_GetEffectiveSkillValues("too_many_items") * count
			)
		end

		if not item.insaneStats_GaveMax then
			local class = item:GetClass()

			if ply:InsaneStats_EffectivelyHasSkill("better_than_ever") then
				if class == "item_healthkit" or tmiTriggerer then
					ply:InsaneStats_AddMaxHealth(ply:InsaneStats_GetEffectiveSkillValues("better_than_ever", 3) * count)
				end
				if class == "item_battery" or tmiTriggerer then
					ply:InsaneStats_AddMaxArmor(ply:InsaneStats_GetEffectiveSkillValues("better_than_ever", 4) * count)
				end

				item.insaneStats_GaveMax = true
			end

			if ply:InsaneStats_EffectivelyHasSkill("until_the_last_bit") then
				if class == "item_healthkit" or tmiTriggerer then
					ply:InsaneStats_AddHealthCapped(
						ply:InsaneStats_GetMaxHealth()
						* ply:InsaneStats_GetEffectiveSkillValues("until_the_last_bit") / 100
						* count
					)
				elseif class == "item_healthvial" then
					ply:InsaneStats_AddHealthCapped(
						ply:InsaneStats_GetMaxHealth()
						* ply:InsaneStats_GetEffectiveSkillValues("until_the_last_bit", 2) / 100
						* count
					)
				end
				if class == "item_battery" or tmiTriggerer then
					ply:InsaneStats_AddArmorCapped(
						ply:InsaneStats_GetMaxArmor()
						* ply:InsaneStats_GetEffectiveSkillValues("until_the_last_bit", 3) / 100
						* count
					)
				end

				item.insaneStats_GaveMax = true
			end
		end

		if tmiTriggerer then
			if ply:IsPlayer() then
				if not ply:HasWeapon("weapon_frag") then
					ply:Give("weapon_frag")
				end
				local toRefill = {}
				for i,v in ipairs(ply:GetWeapons()) do
					toRefill[v:GetPrimaryAmmoType()] = true
					toRefill[v:GetSecondaryAmmoType()] = true
				end
				for k,v in ipairs(toRefill) do
					if k > 0 then
						local maxcarry = game.GetAmmoData(k).maxcarry
						local maximum = tonumber(maxcarry)
						local current = ply:InsaneStats_GetAmmoCount(k)
						if not maximum then
							local conVar = GetConVar(maxcarry)
							if conVar then
								maximum = conVar:GetFloat()
							end
						end
						if (maximum and maximum > 0) then
							ply:GiveAmmo((maximum - current) * count, k)
						end
					end
				end
			end

			ply:InsaneStats_AddHealthNerfed(ply:InsaneStats_GetMaxHealth() * count)
			ply:InsaneStats_AddArmorNerfed(ply:InsaneStats_GetMaxArmor() * count)
		end
	end
end)

hook.Add("InsaneStatsArmorBatteryChanged", "InsaneStatsWPASS2", function(ent, item)
	item.insaneStats_Duplicated = true
end)

local function CauseStatusEffectDamage(data)
	local victim = data.victim
	local effect = data.effect
	local attacker = data.attacker or victim:InsaneStats_GetStatusEffectAttacker(effect)
	if not IsValid(attacker) then
		attacker = victim
	end

	local damageType = victim:InsaneStats_IsMob() and bit.bor(data.damageType, DMG_PREVENT_PHYSICS_FORCE) or 0
	--print(stat, statLevel)
	--PrintTable(data)
	local damage = (data.damageMul or 1) * victim:InsaneStats_GetStatusEffectLevel(effect)
	damage = damage / 2
	
	table.insert(damageTiers, data.damageTier or 4)
	
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

local isSlowRecovery = false
hook.Add("InsaneStatsWPASSDoT", "InsaneStatsWPASS2", function(ent, effect)
	local data = {}
	
	if effect == "poison" then data.damageType = DMG_NERVEGAS
	elseif effect == "bleed" then data.damageType = DMG_SLASH
	elseif effect == "hemotoxin" then data.damageType = bit.bor(DMG_NERVEGAS, DMG_SLASH)
	elseif effect == "shock" then data.damageType = DMG_SHOCK
	elseif effect == "electroblast" then data.damageType = bit.bor(DMG_SHOCK, DMG_BLAST)
	elseif effect == "freeze" then data.damageType = DMG_VEHICLE
	elseif effect == "fire" then
		data.ammoType = 8
		data.damageType = DMG_SLOWBURN
	elseif effect == "frostfire" then
		data.ammoType = 8
		data.damageType = bit.bor(DMG_SLOWBURN, DMG_VEHICLE)
	elseif effect == "cosmicurse" then
		data.ammoType = 8
		data.damageType = bit.bor(
			DMG_SLASH, DMG_SLOWBURN, DMG_BLAST, DMG_NERVEGAS,
			DMG_SONIC, DMG_VEHICLE, DMG_SHOCK, DMG_ENERGYBEAM
		)
	elseif effect == "skill_bleed" then
		data.damageMul = 40
		data.damageTier = 0.5
		data.damageType = DMG_SLASH
	elseif effect == "regen" then
		ent:InsaneStats_AddHealthCapped(
			ent:InsaneStats_GetMaxHealth() * ent:InsaneStats_GetStatusEffectLevel("regen") * 0.005
		)
	elseif effect == "hittaken_regen" then
		ent:InsaneStats_AddHealthCapped(
			ent:InsaneStats_GetMaxHealth() * ent:InsaneStats_GetStatusEffectLevel("hittaken_regen") * 0.005
		)
	elseif effect == "armor_regen" then
		ent:InsaneStats_AddArmorNerfed(
			ent:InsaneStats_GetMaxArmor() * ent:InsaneStats_GetStatusEffectLevel("armor_regen") * 0.005
		)
	elseif effect == "hittaken_regen" then
		ent:InsaneStats_AddArmorNerfed(
			ent:InsaneStats_GetMaxArmor() * ent:InsaneStats_GetStatusEffectLevel("hittaken_regen") * 0.005
		)
	elseif effect == "damage_aura" then
		local damage = ent:InsaneStats_GetStatusEffectLevel("damage_aura") * 0.5
		local trace = {
			start = ent.GetShootPos and ent:GetShootPos() or ent:WorldSpaceCenter(),
			filter = {ent, ent.GetVehicle and ent:GetVehicle() or nil},
			mask = MASK_SHOT,
			output = traceResult
		}

		for i,v in ipairs(ents.FindInSphere(ent:WorldSpaceCenter(), 512)) do
			if ent:InsaneStats_IsValidEnemy(v) then
				local damagePos = v:HeadTarget(ent:WorldSpaceCenter()) or v:WorldSpaceCenter()
				damagePos = damagePos:IsZero() and v:WorldSpaceCenter() or damagePos
				trace.endpos = damagePos

				util.TraceLine(trace)
				if not traceResult.Hit or traceResult.Entity == v then
					local dmginfo = DamageInfo()
					dmginfo:SetAttacker(ent)
					dmginfo:SetInflictor(ent)
					dmginfo:SetBaseDamage(damage)
					dmginfo:SetDamage(damage)
					dmginfo:SetMaxDamage(damage)
					dmginfo:SetDamageForce(vector_origin)
					dmginfo:SetDamageType(bit.bor(DMG_ENERGYBEAM, DMG_PREVENT_PHYSICS_FORCE))
					dmginfo:SetReportedPosition(ent:WorldSpaceCenter())
					dmginfo:SetDamagePosition(damagePos)
					v:TakeDamageInfo(dmginfo)
				end
			end
		end
	elseif effect == "skill_kill_aura" then
		if ent:InsaneStats_GetSkillState("kill_aura") ~= 1 then return true end
		local radiusSqr, damage = ent:InsaneStats_GetEffectiveSkillValues("kill_aura", 2)
		radiusSqr = radiusSqr * ent:InsaneStats_GetSkillStacks("kill_aura")
		radiusSqr = radiusSqr * radiusSqr
		damage = damage * 0.5
	
		local trace = {
			start = ent.GetShootPos and ent:GetShootPos() or ent:WorldSpaceCenter(),
			filter = {ent, ent.GetVehicle and ent:GetVehicle() or nil},
			mask = MASK_SHOT,
			output = traceResult
		}

		for i,v in ipairs(ents.FindInPVS(trace.start)) do
			local damagePos = v:HeadTarget(trace.start) or v:WorldSpaceCenter()
			damagePos = damagePos:IsZero() and v:WorldSpaceCenter() or damagePos
			trace.endpos = damagePos

			if ent:InsaneStats_IsValidEnemy(v) and trace.start:DistToSqr(damagePos) <= radiusSqr then
				util.TraceLine(trace)
				if not traceResult.Hit or traceResult.Entity == v then
					local dmginfo = DamageInfo()
					dmginfo:SetAttacker(ent)
					dmginfo:SetInflictor(ent)
					dmginfo:SetBaseDamage(damage)
					dmginfo:SetDamage(damage)
					dmginfo:SetMaxDamage(damage)
					dmginfo:SetDamageForce(vector_origin)
					dmginfo:SetDamageType(bit.bor(DMG_ENERGYBEAM, DMG_PREVENT_PHYSICS_FORCE))
					dmginfo:SetReportedPosition(trace.start)
					dmginfo:SetDamagePosition(damagePos)
					v:TakeDamageInfo(dmginfo)
				end
			end
		end
	elseif effect == "skill_vitality_to_go" then
		local change = ent:InsaneStats_GetSkillStacks("vitality_to_go") / 200
		ent:InsaneStats_AddHealthCapped(ent:InsaneStats_GetMaxHealth() * change)
		ent:InsaneStats_AddArmorNerfed(ent:InsaneStats_GetMaxArmor() * change)
	elseif effect == "pyrotheum" then
		local attacker = ent:InsaneStats_GetStatusEffectAttacker("pyrotheum")

		if (IsValid(attacker) and (
			attacker:InsaneStats_EffectivelyHasSkill("pyrotheum")
			or attacker:InsaneStats_GetEntityData("pyrotheum_debug")
		)) then
			local level = ent:InsaneStats_GetStatusEffectLevel("pyrotheum")
			local duration = ent:InsaneStats_GetStatusEffectDuration("pyrotheum")
			local damage = duration
			local radius = GetPyrotheumRadius(level)
			local trace = {
				start = ent:WorldSpaceCenter(),
				filter = ent,
				output = traceResult
			}

			for i,v in ipairs(ents.FindInSphere(trace.start, radius)) do
				if v:InsaneStats_GetHealth() > 0 and IsValid(v:GetPhysicsObject())
				and attacker:InsaneStats_GetSkillState("pyrotheum") >= 0
				and not attacker:InsaneStats_IsValidAlly(v)
				and (not v:InsaneStats_IsMob() or attacker:InsaneStats_IsValidEnemy(v))
				and v:GetCollisionGroup() ~= COLLISION_GROUP_DEBRIS then
					trace.mask = MASK_SHOT_HULL
					local damagePos = v:HeadTarget(trace.start) or v:WorldSpaceCenter()
					damagePos = damagePos:IsZero() and v:WorldSpaceCenter() or damagePos
					trace.endpos = damagePos
	
					util.TraceLine(trace)
					if not traceResult.Hit or traceResult.Entity == v then
						--[[if attacker:InsaneStats_IsValidAlly(v) then
							v:InsaneStats_AddHealthCapped(v:InsaneStats_GetMaxHealth() / 1000 * damage)
						else]]
							local dmginfo = DamageInfo()
							dmginfo:SetAttacker(attacker)
							dmginfo:SetInflictor(attacker)
							dmginfo:SetBaseDamage(damage)
							dmginfo:SetDamage(damage)
							dmginfo:SetMaxDamage(damage)
							dmginfo:SetDamageForce(vector_origin)
							dmginfo:SetDamageType(bit.bor(DMG_ENERGYBEAM, DMG_PREVENT_PHYSICS_FORCE))
							dmginfo:SetReportedPosition(attacker:WorldSpaceCenter())
							dmginfo:SetDamagePosition(damagePos)
							v:TakeDamageInfo(dmginfo)
						--end
					end
				end

				if v:InsaneStats_GetStatusEffectDuration("pyrotheum") > 0 and ent ~= v then
					--trace.mask = MASK_SOLID_BRUSHONLY
					local theirLevel = v:InsaneStats_GetStatusEffectLevel("pyrotheum")
					local theirDuration = v:InsaneStats_GetStatusEffectDuration("pyrotheum")
					local theirRadius = GetPyrotheumRadius(theirLevel)
					trace.endpos = v:WorldSpaceCenter()
					--util.TraceLine(trace)
					if --(not traceResult.Hit or traceResult.Entity == v) and
					math.max(theirRadius, radius) ^ 2 > trace.start:DistToSqr(trace.endpos) then
						local newLevel = math.max(level, theirLevel)
						local newDuration = duration + theirDuration
						local newPos = LerpVector(
							theirDuration / (duration + theirDuration),
							ent:WorldSpaceCenter(), v:WorldSpaceCenter()
						)
						if duration <= theirDuration then
							v:SetModelScale(newLevel)
							v:InsaneStats_ApplyStatusEffect(
								"pyrotheum", newLevel, newDuration,
								{attacker = attacker}
							)
							v:SetPos(newPos)
							ent:InsaneStats_ClearStatusEffect("pyrotheum")
							break
						else
							ent:SetModelScale(newLevel)
							ent:InsaneStats_ApplyStatusEffect(
								"pyrotheum", newLevel, newDuration,
								{attacker = attacker}
							)
							ent:SetPos(newPos)
							v:InsaneStats_ClearStatusEffect("pyrotheum")
						end
					end
				end
			end
		else
			ent:InsaneStats_ClearStatusEffect("pyrotheum")
		end
	elseif effect == "xp_up_aura" then
		local stacks = ent:InsaneStats_GetStatusEffectLevel("xp_up_aura")
		for i,v in ipairs(ents.FindInSphere(ent:WorldSpaceCenter(), 512)) do
			v:InsaneStats_ApplyStatusEffect("xp_up", stacks, 1)
		end
	elseif effect == "damage_up_aura" then
		local stacks = ent:InsaneStats_GetStatusEffectLevel("damage_up_aura")
		for i,v in ipairs(ents.FindInSphere(ent:WorldSpaceCenter(), 512)) do
			v:InsaneStats_ApplyStatusEffect("damage_up", stacks, 1)
		end
	elseif effect == "defence_up_aura" then
		local stacks = ent:InsaneStats_GetStatusEffectLevel("defence_up_aura")
		for i,v in ipairs(ents.FindInSphere(ent:WorldSpaceCenter(), 512)) do
			v:InsaneStats_ApplyStatusEffect("defence_up", stacks, 1)
		end
	elseif effect == "bloodsapped" and not ent.insaneStats_IsDead then
		local attacker = ent:InsaneStats_GetStatusEffectAttacker("bloodsapped")
		if IsValid(attacker) then
			attacker:InsaneStats_AddHealthCapped(
				attacker:InsaneStats_GetMaxHealth() * ent:InsaneStats_GetStatusEffectLevel("bloodsapped") * 0.005
			)
		end
	elseif effect == "field_of_shards" then
		local distanceTravelled = ent:InsaneStats_GetEntityData("distance_travelled") or 0
		local oldDistanceTravelled = ent:InsaneStats_GetEntityData("field_of_shards_distance_travelled")
		or distanceTravelled
		local plusDistance = distanceTravelled - oldDistanceTravelled

		if plusDistance ~= 0 then
			data.damageMul = plusDistance / 100
			data.damageTier = 0.5
			data.damageType = DMG_SLASH
		end
		
		ent:InsaneStats_SetEntityData("field_of_shards_distance_travelled", distanceTravelled)
	end

	if data.damageType and ent:InsaneStats_GetHealth() > 0 then
		data.victim = ent
		data.effect = effect
		CauseStatusEffectDamage(data)
	end
end)

local function ApplyRegeneration(frameTime)
	-- get all entities with regen
	local regenAmounts = {}
	for k,v in pairs(InsaneStats:GetEntitiesWithSkills()) do
		local healthFactor = k:InsaneStats_GetMaxHealth() > 0
		and 1 - math.Clamp(k:InsaneStats_GetHealth() / k:InsaneStats_GetMaxHealth(), 0, 1)
		or 0

		regenAmounts[k] = (regenAmounts[k] or 0)
		+ k:InsaneStats_GetEffectiveSkillValues("regeneration")
		+ k:InsaneStats_GetEffectiveSkillValues("fall_to_rise_up") * healthFactor

		if (k:InsaneStats_EffectivelyHasSkill("aint_got_time_for_this")
		or k:InsaneStats_EffectivelyHasSkill("panic")) and not game.SinglePlayer() then
			local regenAmount = k:InsaneStats_GetEffectiveSkillValues("aint_got_time_for_this", 3)
			for i,v2 in ipairs(ents.FindInSphere(k:WorldSpaceCenter(), 512)) do
				if k:InsaneStats_IsValidAlly(v2) and k ~= v2 then
					regenAmounts[v2] = (regenAmounts[v2] or 0)
					+ regenAmount
					+ k:InsaneStats_GetEffectiveSkillValues("panic", 2)
					* (
						v2:InsaneStats_GetMaxHealth() > 0
						and 1 - v2:InsaneStats_GetHealth() / v2:InsaneStats_GetMaxHealth()
						or 0
					)
				end
			end
		end

		if k:InsaneStats_EffectivelyHasSkill("solar_power")
		or k:InsaneStats_EffectivelyHasSkill("vampiric") then
			local checkDir = Vector(0, 0, 1)
			local envSun = ents.FindByClass("env_sun")[1]
			local shadowControl = ents.FindByClass("shadow_control")[1]
			if IsValid(envSun) then
				local angles = envSun:GetAngles()
				local pitchOverride = envSun:GetInternalVariable("pitch")
				angles.pitch = pitchOverride and -pitchOverride or angles.pitch
				checkDir = -angles:Forward()
			elseif IsValid(shadowControl) then
				local newDir = shadowControl:GetInternalVariable("direction")
				checkDir = not newDir:IsZero() and -newDir or checkDir
			end

			checkDir:Normalize()
			checkDir:Mul(65536)

			local trace = {
				start = k:GetShootPos(),
				endpos = k:GetShootPos() + checkDir,
				filter = k,
				mask = MASK_OPAQUE,
				output = traceResult
			}
			util.TraceLine(trace)

			k:InsaneStats_SetSkillData("solar_power", traceResult.HitSky and 1 or 0, 0)
			k:InsaneStats_SetSkillData("vampiric", traceResult.HitSky and 2 or 0, 0)
			if traceResult.HitSky then
				if k:InsaneStats_EffectivelyHasSkill("solar_power") then
					regenAmounts[k] = (regenAmounts[k] or 0) + k:InsaneStats_GetEffectiveSkillValues("solar_power")
				end
				if k:InsaneStats_EffectivelyHasSkill("vampiric") then
					local damage = k:InsaneStats_GetEffectiveSkillTier("vampiric") / 2
					table.insert(damageTiers, 0)
					
					local dmginfo = DamageInfo()
					dmginfo:SetAttacker(k)
					dmginfo:SetBaseDamage(damage)
					dmginfo:SetDamage(damage)
					dmginfo:SetDamageForce(vector_origin)
					dmginfo:SetDamagePosition(k:WorldSpaceCenter())
					dmginfo:SetDamageType(DMG_SLOWBURN)
					dmginfo:SetInflictor(k)
					dmginfo:SetMaxDamage(damage)
					dmginfo:SetReportedPosition(k:WorldSpaceCenter())
					k:TakeDamageInfo(dmginfo)
					
					table.remove(damageTiers)
				end
			end
		end

		if k:InsaneStats_EffectivelyHasSkill("so_heres_the_problem") and k:OnGround() then
			local checkDir = physenv.GetGravity():GetNormalized()

			local trace = {
				start = k:GetPos(),
				endpos = k:GetPos() + checkDir,
				filter = k,
				mask = MASK_PLAYERSOLID,
				output = traceResult
			}
			util.TraceLine(trace)

			local surfaceProperty = util.GetSurfacePropName(traceResult.SurfaceProps)
			local isGrass = surfaceProperty == "grass" or surfaceProperty == "hay"

			k:InsaneStats_SetSkillData("so_heres_the_problem", (isGrass or k:WaterLevel() > 1) and 2 or 0, 0)
			if isGrass then
				local damage = k:InsaneStats_GetEffectiveSkillTier("so_heres_the_problem") / 2
				table.insert(damageTiers, 0)
				
				local dmginfo = DamageInfo()
				dmginfo:SetAttacker(k)
				dmginfo:SetBaseDamage(damage)
				dmginfo:SetDamage(damage)
				dmginfo:SetDamageForce(vector_origin)
				dmginfo:SetDamagePosition(k:WorldSpaceCenter())
				dmginfo:SetDamageType(DMG_NERVEGAS)
				dmginfo:SetInflictor(k)
				dmginfo:SetMaxDamage(damage)
				dmginfo:SetReportedPosition(k:WorldSpaceCenter())
				k:TakeDamageInfo(dmginfo)
				
				table.remove(damageTiers)
			end
		end

		if k:InsaneStats_EffectivelyHasSkill("degeneration") then
			local oldHealth = k:InsaneStats_GetHealth()
			local healthLost = k:InsaneStats_GetEffectiveSkillValues("degeneration") / 100
			local mult = (1 + healthLost) ^ frameTime
			healthLost = (1 - mult) * oldHealth
			k:SetHealth(k:InsaneStats_GetHealth() * mult)
			k:InsaneStats_DamageNumber(k, healthLost, bit.bor(DMG_ENERGYBEAM, DMG_PREVENT_PHYSICS_FORCE))
		end

		if k:InsaneStats_EffectivelyHasSkill("slow_recovery") then
			isSlowRecovery = true
			local consumeFrac = k:InsaneStats_GetEffectiveSkillValues("slow_recovery", 2) / 100
			local consumeStacks = k:InsaneStats_GetSkillStacks("slow_recovery") * consumeFrac
			k:InsaneStats_AddHealthCapped(k:InsaneStats_GetMaxHealth() * consumeStacks / 100)
			k:InsaneStats_SetSkillData(
				"slow_recovery", 1,
				k:InsaneStats_GetSkillStacks("slow_recovery") * (1 - consumeFrac)
			)
			isSlowRecovery = false
		end
	end

	for k,v in pairs(regenAmounts) do
		k:InsaneStats_AddHealthCapped(v / 100 * k:InsaneStats_GetMaxHealth() * frameTime)
	end
end

hook.Add("InsaneStatsCtrlStateChanged", "InsaneStatsWPASS2", function(ply, bool)
	if game.SinglePlayer() and ply:InsaneStats_EffectivelyHasSkill("aint_got_time_for_this") then
		local newState = bool and 1 or 0
		if ply:InsaneStats_GetSkillState("aint_got_time_for_this") ~= newState then
			ply:InsaneStats_SetSkillData("aint_got_time_for_this", newState, 0)
		end
	end
end)

local occupyRatio = 0.05
local timerResolution = 0.5
local decayRate = 0.99^timerResolution
timer.Create("InsaneStatsWPASS2", timerResolution, 0, function()
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local startTime = SysTime()
		local timeIndex = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
		local tempTimeStart = SysTime()
		
		local starlightRadii = {}

		for i,v in player.Iterator() do
			if not v:GetNoDraw() then
				starlightRadii[v] = (starlightRadii[v] or 0)
				--[[+ math.sqrt(v:InsaneStats_GetSkillStacks("starlight"))
				* v:InsaneStats_GetEffectiveSkillValues("starlight", 2)
				+ math.sqrt(v:InsaneStats_GetStatusEffectDuration("starlight")) * 32]]
			end
		end

		timeIndex[1] = SysTime() - tempTimeStart
		tempTimeStart = SysTime()

		ApplyRegeneration(timerResolution)

		timeIndex[2] = SysTime() - tempTimeStart
		--[=[tempTimeStart = SysTime()

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
					--light:SetPos(k:GetPos() + vector_up)
					light:SetPos(k.GetShootPos and k:GetShootPos() or k:GetPos() + vector_up)
					light:SetParent(k)
					--light:SetKeyValue("style", "1")
					--light:SetKeyValue("_light", "0 63 0")
					light:SetKeyValue("brightness", "-4")
					--light:SetSpawnFlags(18)
					light:Spawn()
					light.insaneStats_IsStarlight = true
					k.insaneStats_Starlight = light

					--[[local attachment = k:LookupAttachment("eyes")
					local light = ents.Create("env_projectedtexture")
					light:SetPos(k.GetShootPos and k:GetShootPos() or k:GetPos() + vector_up)
					light:SetParent(k, attachment == 0 and -1 or attachment)
					light:SetAngles(k:GetAimVector():Angle())
					light:SetKeyValue("texturename", "effects/flashlight/soft")
					light:SetKeyValue("lightcolor", "255 255 255")
					light:SetKeyValue("lightstrength", "1")
					light:SetKeyValue("lightfov", "150")
					light:SetKeyValue("nearz", "16")
					light:SetKeyValue("enableshadows", "1")
					light:SetKeyValue("shadowquality", "1")
					light:SetKeyValue("lightworld", "1")
					light:Spawn()
					light.insaneStats_IsStarlight = true
					k.insaneStats_Starlight = light]]
				end
				k.insaneStats_Starlight:Fire("distance", v)
				--k.insaneStats_Starlight:Fire("SetFarZ", v)

				--local desiredColor = HSVToColor(CurTime() % 360, 0.75, math.Clamp(16 / math.sqrt(v), 0.0078125, 1))
				local desiredColor = HSVToColor(CurTime() % 360, 0.75, 1)
				k.insaneStats_Starlight:Fire("Color", string.format(
				--k.insaneStats_Starlight:Fire("LightColor", string.format(
					"%u %u %u", desiredColor.r, desiredColor.g, desiredColor.b
				))
				--local desiredBrightness = math.ceil(math.min(1, 256 / v) * 255)
				--[[k.insaneStats_Starlight:Fire("Color", string.format(
					"%u %u %u", desiredBrightness, desiredBrightness, desiredBrightness
				))]]
			elseif IsValid(k.insaneStats_Starlight) then
				SafeRemoveEntityDelayed(k.insaneStats_Starlight, 1)
			end
		end
		
		timeIndex[3] = SysTime() - tempTimeStart]=]
		tempTimeStart = SysTime()
		
		for k,v in pairs(entities) do
			if IsValid(k) then
				local class = k:GetClass()
				if class == "filter_activator_model" then
					local targetModel = k:GetInternalVariable("model")
					if targetModel ~= "" then
						for i,v in pairs(ents.FindByModel(targetModel)) do
							v:SetNWBool("insanestats_vital", true)
							local relatedEntities = v:InsaneStats_GetEntityData("insanestats_vital") or {}
							relatedEntities[k] = true
							v:InsaneStats_SetEntityData("insanestats_vital", relatedEntities)
						end
					end
				elseif class == "filter_activator_name" then
					local targetName = k:GetInternalVariable("filtername")
					if targetName ~= "" then
						for i,v in pairs(ents.FindByName(targetName)) do
							v:SetNWBool("insanestats_vital", true)
							local relatedEntities = v:InsaneStats_GetEntityData("insanestats_vital") or {}
							relatedEntities[k] = true
							v:InsaneStats_SetEntityData("insanestats_vital", relatedEntities)
						end
					end
				elseif (k:GetModel() or "") == "" then
					entities[k] = nil
				end
			else
				entities[k] = nil
			end
		end
		
		timeIndex[4] = SysTime() - tempTimeStart
		tempTimeStart = SysTime()
		
		for k,v in pairs(rapidThinkEntities) do
			if IsValid(k) then
				if k:InsaneStats_GetAttributeValue("toggle_damage") ~= 1
				and k:InsaneStats_GetStatusEffectLevel("arcane_defence_up") == 0
				and k:InsaneStats_GetStatusEffectLevel("arcane_damage_up") == 0
				and k:InsaneStats_GetStatusEffectLevel("mundane_defence_down") == 0
				and k:InsaneStats_GetStatusEffectLevel("mundane_damage_down") == 0 then
					local value = k:InsaneStats_GetAttributeValue("toggle_damage")
					if value > 1 then
						k:InsaneStats_ApplyStatusEffect(math.random() < 0.5 and "arcane_defence_up" or "arcane_damage_up", value * 100 - 100, 5)
					elseif value < 1 then
						if math.random() < 0.5 then
							k:InsaneStats_ApplyStatusEffect("mundane_defence_down", 100 / value - 100, 5)
						else
							k:InsaneStats_ApplyStatusEffect("mundane_damage_down", 100 - value * 100, 5)
						end
					end
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
				else
					k:InsaneStats_ClearStatusEffect("ctrl_gamespeed_up")
					k:InsaneStats_ClearStatusEffect("ctrl_defence_up")
				end
			else
				rapidThinkEntities[k] = nil
			end
		end
		
		timeIndex[5] = SysTime() - tempTimeStart
		tempTimeStart = SysTime()

		for k,v in pairs(InsaneStats:GetEntitiesWithSkills()) do
			local skillTime = k:InsaneStats_GetSkillStacks("fight_for_your_life")
			if k:InsaneStats_GetSkillState("fight_for_your_life", true) == 1 and skillTime <= 0 then
				k:InsaneStats_SetSkillData("fight_for_your_life", 0, 0)
				if k:IsPlayer() then
					k:Kill()
				else
					k:TakeDamage(math.huge)
				end
			end

			--[[local skillTime = k:InsaneStats_GetSkillStacks("sneak_100")
			if k:InsaneStats_GetSkillState("sneak_100", true) == 1 and skillTime <= 0 then
				k:RemoveFlags(FL_NOTARGET)
				k:AddFlags(FL_AIMTARGET)
				k:RemoveEffects(bit.bor(EF_NOSHADOW, EF_NODRAW, EF_NORECEIVESHADOW))
				k:InsaneStats_SetSkillData(
					"sneak_100",
					-1,
					k:InsaneStats_GetEffectiveSkillValues("sneak_100", 2) + skillTime
				)
			end

			skillTime = k:InsaneStats_GetSkillStacks("ubercharge")
			if k:InsaneStats_GetSkillState("ubercharge", true) == 1 and skillTime <= 0 then
				k:InsaneStats_SetSkillData(
					"ubercharge",
					-1,
					k:InsaneStats_GetEffectiveSkillValues("ubercharge") + skillTime
				)
			end

			skillTime = k:InsaneStats_GetSkillStacks("just_breathe")
			if k:InsaneStats_GetSkillState("just_breathe", true) == 1 and skillTime <= 0 then
				k:InsaneStats_SetSkillData(
					"just_breathe",
					-1,
					60 + skillTime
				)
			end

			skillTime = k:InsaneStats_GetSkillStacks("anger")
			if k:InsaneStats_GetSkillState("anger", true) == 1 and skillTime <= 0 then
				k:InsaneStats_SetSkillData(
					"anger",
					-1,
					k:InsaneStats_GetEffectiveSkillValues("anger", 2) + skillTime
				)
			end]]

			if k:InsaneStats_EffectivelyHasSkill("super_cold") and not game.SinglePlayer() then
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
					
			if k:IsPlayer() then
				for i,v2 in ipairs(k:GetWeapons()) do
					UpdateWeaponDeploySpeed(k, v2)
				end
			end

			local activate1 = k:InsaneStats_GetSkillState("totem_of_wisdom") == 0
			local activate2 = k:InsaneStats_GetSkillState("totem_of_vigor") == 0
			local activate3 = k:InsaneStats_GetSkillState("totem_of_courage") == 0
			if activate1 or activate2 or activate3 then
				-- find all entities that got applied status effects by us, remove them
				if activate1 then
					for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("xp_up_aura")) do
						if v:InsaneStats_GetStatusEffectAttacker("xp_up_aura") == k then
							SafeRemoveEntity(v)
						end
					end
				end
				if activate2 then
					for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("damage_up_aura")) do
						if v:InsaneStats_GetStatusEffectAttacker("damage_up_aura") == k then
							SafeRemoveEntity(v)
						end
					end
				end
				if activate3 then
					for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("defence_up_aura")) do
						if v:InsaneStats_GetStatusEffectAttacker("defence_up_aura") == k then
							SafeRemoveEntity(v)
						end
					end
				end

				-- create a new totem
				local color = Color(activate2 and 255 or 0, activate3 and 255 or 0, activate1 and 255 or 0)
				local totem = ents.Create("prop_physics")
				totem:SetModel("models/maxofs2d/companion_doll.mdl")
				totem:SetPos(k:WorldSpaceCenter())
				totem:SetMaxHealth(100)
				totem:SetHealth(100)
				totem:Spawn()
				totem:SetCollisionGroup(COLLISION_GROUP_WORLD)
				totem:SetColor(color)
				timer.Simple(0, function()
					if IsValid(totem) and IsValid(k) then
						totem:InsaneStats_ApplyStatusEffect("invincible", 1, math.huge)
						if activate1 then
							k:InsaneStats_SetSkillData("totem_of_wisdom", -1, 30)
							totem:InsaneStats_ApplyStatusEffect(
								"xp_up_aura",
								k:InsaneStats_GetEffectiveSkillValues("totem_of_wisdom", 2),
								math.huge,
								{attacker = k}
							)
						end
						if activate2 then
							k:InsaneStats_SetSkillData("totem_of_vigor", -1, 30)
							totem:InsaneStats_ApplyStatusEffect(
								"damage_up_aura",
								k:InsaneStats_GetEffectiveSkillValues("totem_of_vigor", 2),
								math.huge,
								{attacker = k}
							)
						end
						if activate3 then
							k:InsaneStats_SetSkillData("totem_of_courage", -1, 30)
							totem:InsaneStats_ApplyStatusEffect(
								"defence_up_aura",
								k:InsaneStats_GetEffectiveSkillValues("totem_of_courage", 2),
								math.huge,
								{attacker = k}
							)
						end
					end
				end)
			end

			local distanceTravelled = k:InsaneStats_GetEntityData("distance_travelled") or 0
			local oldDistanceTravelled = k:InsaneStats_GetEntityData("skill_distance_travelled") or distanceTravelled
			local plusDistance = distanceTravelled - oldDistanceTravelled

			if plusDistance ~= 0 then
			local addStacks = 0
				if k:InsaneStats_EffectivelyHasSkill("synergy_2") then
					addStacks = plusDistance * 0.1 / k:InsaneStats_GetEffectiveSkillValues("synergy_2")
				end
				if k:InsaneStats_EffectivelyHasSkill("synergy_3") then
					addStacks = addStacks + plusDistance * 0.1 / k:InsaneStats_GetEffectiveSkillValues("synergy_3")
				end
				if addStacks ~= 0 then
					local stacks = math.max(
						k:InsaneStats_GetSkillStacks("synergy_1"),
						k:InsaneStats_GetSkillStacks("synergy_2"),
						k:InsaneStats_GetSkillStacks("synergy_3"),
						k:InsaneStats_GetSkillStacks("synergy_4")
					)
		
					k:InsaneStats_SetSkillData("synergy_1", 1, stacks + addStacks)
					k:InsaneStats_SetSkillData("synergy_2", 1, stacks + addStacks)
					k:InsaneStats_SetSkillData("synergy_3", 1, stacks + addStacks)
					k:InsaneStats_SetSkillData("synergy_4", 1, stacks + addStacks)
				end

				if k:InsaneStats_EffectivelyHasSkill("master_of_water") then
					local newStacks = k:InsaneStats_GetSkillStacks("master_of_water")
					+ plusDistance / 400 * k:InsaneStats_GetEffectiveSkillValues("master_of_water", 3)

					local nextStacks = newStacks % 100
					local triggers = math.Round((newStacks - nextStacks) / 100)

					if triggers > 0 then
						local tempEnt = ents.Create("info_null")
						tempEnt:SetPos(k:WorldSpaceCenter())
						tempEnt:InsaneStats_ApplyStatusEffect("kill_skill_triggerer", triggers, math.huge)

						hook.Run(
							"InsaneStatsEntityKilled",
							tempEnt,
							k,
							k.GetActiveWeapon and k:GetActiveWeapon() or k
						)

						tempEnt:Spawn()
					end

					k:InsaneStats_SetSkillData("master_of_water", 0, nextStacks)
				end
			end

			k:InsaneStats_SetEntityData("skill_distance_travelled", distanceTravelled)
		end
		
		timeIndex[6] = SysTime() - tempTimeStart
		tempTimeStart = SysTime()

		for i,v in ipairs(ents.FindByClass("npc_grenade_frag")) do
			local detonateTime = v:GetInternalVariable("m_flDetonateTime")
			if detonateTime > 0 then
				detonateTime = detonateTime + CurTime()
				v:SetNW2Float("insanestats_detonatetime", detonateTime)
			end
		end

		for i,v in ipairs(ents.FindByClass("grenade_helicopter")) do
			local active = v:GetInternalVariable("m_bActivated")
			if active then
				local detonateTime = v:GetInternalVariable("m_flBlinkFastTime") + 1 + CurTime()
				v:SetNW2Float("insanestats_detonatetime", detonateTime)
			end
		end
		
		timeIndex[7] = SysTime() - tempTimeStart
		
		--[[local processingTime = SysTime() - startTime
		local newResolution = math.Clamp(processingTime / occupyRatio + timerResolution, 0.5, 100) / 2
		if newResolution ~= timerResolution then
			if InsaneStats:IsDebugLevel(1) then
				if newResolution < timerResolution then
					InsaneStats:Log("WPASS2 timer interval reduced to %fs.", newResolution)
				else
					InsaneStats:Log("WPASS2 timer interval increased to %fs due to lag.", newResolution)
				end
			end
			timerResolution = newResolution
			decayRate = 0.99^timerResolution
			timer.Adjust("InsaneStatsWPASS2", newResolution)
		end]]

		if InsaneStats:IsDebugLevel(2) then
			InsaneStats:Log("Time breakdown:")
			for i,v in ipairs(timeIndex) do
				InsaneStats:Log("%u: %fms", i, v*1000)
			end
		end
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

local onBreakClasses = {
	func_breakable = true,
	func_breakable_surf = true,
	func_physbox = true,
	func_physbox_multiplayer = true,
	prop_physics = true,
	prop_physics_override = true,
	prop_physics_multiplayer = true,
	prop_sphere = true,
	prop_dynamic = true,
	prop_dynamic_override = true,
	prop_dynamic_ornament = true
}
local crossbowBolts = {}
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

		if ent:InsaneStats_IsMob() then
			ent:InsaneStats_SetSkillData("master_of_air", 0, 0)
		end
	end
	
	entities[ent] = true
	if ent:InsaneStats_IsMob() then
		rapidThinkEntities[ent] = true
	end
	--[[if IsValid(ent.insaneStats_Starlight) then
		ent.insaneStats_Starlight:Remove()
	end]]
	local class = ent:GetClass()
	if class == "momentary_rot_button" then
		ent:Fire("AddOutput", "Position !self:InsaneStatsInteraction::0:-1")
	--[[elseif class:StartsWith("trigger_") and ent:HasSpawnFlags(1) then
		ent:SetNoDraw(false)
		ent:SetRenderMode(10)]]
	elseif class == "trigger_look" then
		local lookPositions = {}
		for i,v in ipairs(ents.FindByClass("trigger_look")) do
			local targetEnts = ents.FindByName(v:GetInternalVariable("target"))
			for j,v2 in ipairs(targetEnts) do
				table.insert(lookPositions, v2:GetPos())
			end
		end

		net.Start("insane_stats", true)
		net.WriteUInt(9, 8)
		net.WriteUInt(#lookPositions, 8)
		for i,v in ipairs(lookPositions) do
			net.WriteVector(v)
		end
		net.Broadcast()
	elseif class == "npc_grenade_frag" then
		local thrower = ent:GetInternalVariable("m_hThrower")
		if (IsValid(thrower) and bit.band(thrower:InsaneStats_GetSkillStacks("explosive_arsenal"), 1) == 0
		and thrower:InsaneStats_EffectivelyHasSkill("explosive_arsenal")) then
			local boost = (1 + thrower:InsaneStats_GetEffectiveSkillValues("explosive_arsenal", 2) / 100)
			ent:SetSaveValue("m_flDamage", ent:GetInternalVariable("m_flDamage") * boost)
			ent:SetSaveValue("m_DmgRadius", ent:GetInternalVariable("m_DmgRadius") * boost)
			ent:AddCallback("PhysicsCollide", function(this, data)
				if not data.OurOldVelocity:IsEqualTol(data.OurNewVelocity, 1) then
					ent:Fire("SetTimer", 0, 0, thrower, thrower)
				end
			end)
		end
	elseif onBreakClasses[class] then
		ent:Fire("AddOutput", "OnBreak !self:InsaneStats_OnBreak::0:-1")
	elseif rechargerClasses[class] then
		ent:SetSaveValue("m_takedamage", 1)
	end
	
	ent:InsaneStats_ClearAllStatusEffects()

	if ent.insaneStats_TempKillSkillTriggerer then
		ent:InsaneStats_ApplyStatusEffect("kill_skill_triggerer", ent.insaneStats_TempKillSkillTriggerer, math.huge)
		ent.insaneStats_TempKillSkillTriggerer = nil
	end

	if ent.insaneStats_TempLDTA then
		--[[local xpBonus = ent.insaneStats_TempLDTA
		ent:InsaneStats_SetXP(ent:InsaneStats_GetXP() * (1 + xpBonus / 100))
		ent:InsaneStats_ApplyStatusEffect("xp_yield_up", xpBonus, math.huge)]]
		ent:InsaneStats_ApplyStatusEffect("no_skill_forced_respawning", 1, math.huge)
		ent.insaneStats_TempLDTA = nil
	end

	if ent.insaneStats_TempInvincible then
		ent:InsaneStats_ApplyStatusEffect("invincible", ent.insaneStats_TempInvincible, math.huge)
	end
	
	if class == "helicopter_chunk" and InsaneStats:GetConVarValue("wpass2_disintegrate_helicopter_chunk") then
		ent:InsaneStats_ApplyStatusEffect("certain_deletion", 1, 5)
	end
end)

hook.Add("EntityRemoved", "InsaneStatsWPASS2", function(ent)
	local class = ent:GetClass()
	if class == "trigger_look" then
		timer.Simple(0, function()
			local lookPositions = {}
			for i,v in ipairs(ents.FindByClass("trigger_look")) do
				local targetEnts = ents.FindByName(v:GetInternalVariable("target"))
				for j,v2 in ipairs(targetEnts) do
					table.insert(lookPositions, v2:GetPos())
				end
			end
			net.Start("insane_stats")
			net.WriteUInt(9, 8)
			net.WriteUInt(#lookPositions, 8)
			for i,v in ipairs(lookPositions) do
				net.WriteVector(v)
			end
			net.Broadcast()
		end)
	elseif class == "crossbow_bolt" then
		if not ent.insaneStats_Landed then
			local attacker = ent.insaneStats_FiredBy
			local shouldSkillExplode = IsValid(attacker) and attacker:InsaneStats_GetSkillState("brilliant_behemoth") == 1
			if shouldSkillExplode then
				CauseExplosion({
					attacker = attacker,
					damageTier = 1,
					damage = GetConVar("sk_plr_dmg_xbow_bolt_npc"):GetFloat(),
					damagePos = ent:WorldSpaceCenter(),
					damageType = DMG_BLAST,
					radius = attacker:InsaneStats_GetEffectiveSkillValues(
						"brilliant_behemoth", 2
					),
					isSkillExplosion = true
				})
			end
		end
	end
end)

local function ProcessBreakEvent(victim, attacker)
	if not IsValid(attacker) then
		if IsValid(victim.insaneStats_LastAttacker) then
			attacker = victim.insaneStats_LastAttacker
		else
			attacker = game.GetWorld()
		end
	end
	
	if IsValid(attacker) and victim:GetCollisionGroup() ~= COLLISION_GROUP_DEBRIS
	and not victim.insaneStats_SuppressCoinDrops and not victim.insaneStats_IsDead then
		hook.Run("InsaneStatsPropBroke", victim, attacker)
		victim.insaneStats_IsDead = true
	end
end

hook.Add("InsaneStatsPropBroke", "InsaneStatsWPASS2", function(victim, attacker)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local stacks = (attacker:InsaneStats_GetAttributeValue("kill1s_xp2") - 1) * 100
		attacker:InsaneStats_ApplyStatusEffect("masterful_xp", stacks, 1, {extend = true})
		stacks = attacker:InsaneStats_GetEffectiveSkillValues("multi_killer")
		attacker:InsaneStats_SetSkillData("multi_killer", 1, stacks + attacker:InsaneStats_GetSkillStacks("multi_killer"))

		local duration = attacker:InsaneStats_GetAttributeValue("starlight") - 1
		attacker:InsaneStats_ApplyStatusEffect("starlight", 1, duration, {extend = true})
		if attacker:InsaneStats_EffectivelyHasSkill("starlight") then
			attacker:InsaneStats_SetSkillData(
				"starlight",
				1,
				attacker:InsaneStats_GetSkillStacks("starlight")
				+ attacker:InsaneStats_GetEffectiveSkillValues("starlight")
			)
		end
		
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
			
		SpawnRandomItems(
			attacker:InsaneStats_GetAttributeValue("prop_supplychance") - 1,
			victim:GetPos(), attacker
		)
		SpawnRandomItems(
			attacker:InsaneStats_GetEffectiveSkillValues("fortune") / 100,
			victim:GetPos(), attacker
		)

		if victim:GetClass() == "item_item_crate" then
			for i=1, attacker:InsaneStats_GetEffectiveSkillTier("master_of_earth") do
				hook.Run("InsaneStatsEntityKilled", victim, attacker, inflictor)
			end
		elseif math.random() * 100 < attacker:InsaneStats_GetEffectiveSkillValues("master_of_earth", 3) then
			hook.Run("InsaneStatsEntityKilled", victim, attacker, inflictor)
		end
	end
end)

hook.Add("InsaneStatsReloadXBow", "InsaneStatsWPASS2", function(wep, ply)
	if ply:InsaneStats_EffectivelyHasSkill("crunch") then
		-- FIXME: so much hacks here and there
		local bolts = wep:InsaneStats_Clip1() - 1
		local data = {wep = wep, old = wep:InsaneStats_Clip1(), new = 1}
		hook.Run("InsaneStatsModifyWeaponClip", data)
		bolts = bolts * bolts / math.max(data.old - data.new, 4.6566128730774e-10)

		local bolts2 = ply:InsaneStats_GetAmmoCount(6)
		local data = {ply = ply, old = bolts2, new = 0, type = 6}
		hook.Run("InsaneStatsPlayerSetAmmo", data)
		bolts2 = bolts2 * bolts2 / math.max(data.old - data.new, 4.6566128730774e-10)

		bolts = bolts + bolts2
		if bolts > 0 then
			-- FIXME: more ugly code duplication!!!
			local attacker = ply
			local inflictor = wep
			local startingHealth = ply:InsaneStats_GetEffectiveSkillValues("crunch", 2) * bolts
			
			local data = {
				xp = startingHealth,
				attacker = attacker, inflictor = inflictor, victim = wep,
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

			wep.insaneStats_Clip1Adj = 0
			wep.insaneStats_LastClip1 = 1
			(wep.InsaneStats_SetRawClip1 or wep.SetClip1)(wep, 1)
			ply.insaneStats_AmmoAdjs[6] = 0
			(ply.InsaneStats_SetRawAmmo or ply.SetAmmo)(ply, 0, 6)

			return true
		end
	end
end)

local queuedUnlockSends = {}
hook.Add("AcceptInput", "InsaneStatsWPASS2", function(ent, input, activator, caller, value)
	local class = ent:GetClass()
	input = input:lower()
	if input == "insanestatsinteraction" then
		ent:SetNW2Float("insanestats_progress", tonumber(value) or 0)
	elseif input == "insanestats_onbreak" then
		ProcessBreakEvent(caller, activator)
	elseif input == "unlock" or input == "open" or input == "close" or input == "setanimation" or input == "setskin"
	or (input == "enable" or input == "disable" or input == "break" or input == "kill")
	and (class:StartWith("func_") or class:StartWith("trigger_")) then
		queuedUnlockSends[ent] = true
		if input == "break" then ent.insaneStats_IsDead = true end
	end
end)

-- there are a set of inputs and outputs that need to be remembered for ctrl_f skill
local jotRelayerInputs = {
	trigger = true,				--logic_relay
	setvaluetest = true,		--logic_branch
	toggletest = true,			--logic_branch
	test = true,				--logic_branch
	invalue = true,				--logic_case
	pickrandom = true,			--logic_case
	pickrandomshuffle = true,	--logic_case
	add = true,					--math_counter
	divide = true,				--math_counter
	multiply = true,			--math_counter
	setvalue = true,			--math_counter
	setvaluenofire = true,		--math_counter
	subtract = true,			--math_counter
	sethitmax = true,			--math_counter
	sethitmin = true,			--math_counter
	open = true,				--func_movelinear
	close = true,				--func_movelinear
	setspeed = true,			--func_movelinear
}
local relayers = {
	logic_relay = true,
	logic_branch = true,
	logic_case = true,
	math_counter = true,
	func_movelinear = true
}
--[[local jotRelayerOutputs = {
	ontrigger = true,	--logic_relay
	ontrue = true,		--logic_branch
	onfalse = true		--logic_branch
}]]
--[[local jotTriggerOutputs = {
	ontrigger = true,				--trigger_once, trigger_multiple,
	ontimeout = true,				--trigger_look,
	nearestentitydistance = true,	--trigger_proximity,
	onstarttouch = true,			--trigger_once, trigger_multiple, trigger_look, trigger_proximity,
	onstarttouchall = true,			--trigger_multiple, trigger_look, trigger_proximity,
	onendtouch = true,				--trigger_multiple, trigger_look, trigger_proximity,
	onendtouchall = true,			--trigger_multiple, trigger_look, trigger_proximity,
	ontouching = true,				--trigger_multiple, trigger_look, trigger_proximity,
	onnottouching = true			--trigger_multiple, trigger_look, trigger_proximity
}]]
--[[
how ctrl_f works:
:: phase 1: entitykeyvalue
whenever value after the comma is one of jotRelayerInputs keys: insert caller/receiver pair into A
if value matches "^[^,]+,unlock": insert caller/receiver pair into B
:: phase 2: initialize
for each B:
	if caller is relay:
		read A to find caller/receiver pair for caller
		insert found caller/receiver pair into C
	else:
		insert caller/receiver pair into F
insert all C into B
jump back to start of phase 2 if B is not empty

for each F:
	if caller is trigger:
		read filtername to figure out activator name
		change F's caller to activator name

# now, F = unlockers/receivers
]]
local jottedRelayerInputs = {}
local jottedUnlockerInputs = {}
hook.Add("EntityKeyValue", "InsaneStatsWPASS2", function(ent, key, value)
	key = key:lower()
	if key:StartWith("onplayeruse") or key:StartWith("oncacheinteraction")
	or key:StartWith("outremaininghealth") or key:StartWith("outremainingcharge")
	or key:StartWith("onhalfempty") or key:StartWith("onempty") or key:StartWith("onfull") then
		ent:SetNWBool("insanestats_use", true)
		ent.insaneStats_PreventMagnet = 100
	elseif key:StartWith("onplayerpickup") then
		ent:SetNWBool("insanestats_use", true)
		ent.insaneStats_Duplicated = true
		ent.insaneStats_PreventMagnet = 100
	elseif key:StartWith("ondamaged") then
		ent:SetNWBool("insanestats_break", true)
	elseif key:StartWith("onphysgun") then
		ent:SetNWBool("insanestats_use", true)
		ent.insaneStats_PreventMagnet = 100
		--[[ent.insaneStats_PhysGunOutputs = ent.insaneStats_PhysGunOutputs or {}

		local rawData = string.Explode("\x1B", value)
		if #rawData < 2 then
			rawData = string.Explode(",", value)
		end

		if #rawData > 1 then
			table.insert(ent.insaneStats_PhysGunOutputs, {
				entities = rawData[1] or "",
				input = rawData[2] or "",
				param = rawData[3] or "",
				delay = tonumber(rawData[4]) or 0,
				times = tonumber(rawData[5]) or -1
			})
		end]]
	elseif key:StartWith("onawakened") then
		ent:SetNWBool("insanestats_use", true)
	end

	local targetEntName, targetInput = string.match(value, "^([^\27]*)\27([^\27]+)")
	if not targetInput then
		targetEntName, targetInput = string.match(value, "^([^,]*),([^,]+)")
	end

	if targetInput then
		targetInput = targetInput:lower()
		if jotRelayerInputs[targetInput] then
			jottedRelayerInputs[targetEntName] = jottedRelayerInputs[targetEntName] or {}
			jottedRelayerInputs[targetEntName][ent] = true
		end
		if targetInput == "unlock" or targetInput == "open" or targetInput == "close"
		or targetInput == "setanimation" or targetInput == "break" or targetInput == "setspeed" then
			jottedUnlockerInputs[targetEntName] = jottedUnlockerInputs[targetEntName] or {}
			jottedUnlockerInputs[targetEntName][ent] = true
		end
	end
end)
InsaneStats.SkillRelayerInputs = jottedRelayerInputs
InsaneStats.SkillUnlockerInputs = jottedUnlockerInputs

local entitiesRequiredToUnlock = {}
local entitiesUnlock = {}
local function MapUnlocks()
	entitiesRequiredToUnlock = {}
	entitiesUnlock = {}

	local queuedUnlockerInputs = jottedUnlockerInputs
	for iterations = 1, 10 do
		if InsaneStats:IsDebugLevel(2) then
			InsaneStats:Log("Unlocking inputs to process #%i:", iterations)
			PrintTable(queuedUnlockerInputs)
		end

		local newJottedUnlockerInputs = {}

		for targetname, unlockingEntities in pairs(queuedUnlockerInputs) do
			for unlockingEntity, _ in pairs(unlockingEntities) do
				if IsValid(unlockingEntity) then
					local class = unlockingEntity:GetClass()
					local filterName = unlockingEntity:GetInternalVariable("filtername") or ""
					if relayers[class] then
						newJottedUnlockerInputs[targetname] = newJottedUnlockerInputs[targetname] or {}
						for k,v in pairs(jottedRelayerInputs[unlockingEntity:GetName()] or {}) do
							newJottedUnlockerInputs[targetname][k] = v
						end
					elseif class == "filter_activator_name" or class == "filter_activator_model" then
						-- figure out what's the unlocking entity name
						local isTargetNameSearching = class == "filter_activator_name"
						filterName = unlockingEntity:GetInternalVariable(
							isTargetNameSearching and "filtername" or "model"
						)
						if filterName ~= "" then
							newJottedUnlockerInputs[targetname] = newJottedUnlockerInputs[targetname] or {}

							local searchFunc = isTargetNameSearching and ents.FindByName or ents.FindByModel
							for i, unlockingEntity2 in ipairs(searchFunc(filterName)) do
								if (unlockingEntity2:GetModel() or "") ~= "" then
									newJottedUnlockerInputs[targetname][unlockingEntity2] = true
								end
							end
						end
					elseif class:StartWith("trigger_") and filterName ~= "" then
						-- figure out what's the filter entity
						newJottedUnlockerInputs[targetname] = newJottedUnlockerInputs[targetname] or {}

						for i, filterEntity in ipairs(ents.FindByName(filterName)) do
							local filterClass = filterEntity:GetClass()
							if filterClass == "filter_activator_name" or filterClass == "filter_activator_model" then
								newJottedUnlockerInputs[targetname][filterEntity] = true
							end
						end
					else
						entitiesUnlock[unlockingEntity] = entitiesUnlock[unlockingEntity] or {}
						local lockedEnts = ents.FindByName(targetname)
						for _, targetEnt in ipairs(lockedEnts) do
							entitiesRequiredToUnlock[targetEnt] = entitiesRequiredToUnlock[targetEnt] or {}
							entitiesRequiredToUnlock[targetEnt][unlockingEntity] = true
							entitiesUnlock[unlockingEntity][targetEnt] = true
						end
					end
				end
			end
		end

		queuedUnlockerInputs = newJottedUnlockerInputs
		if table.IsEmpty(queuedUnlockerInputs) then break end
	end

	if InsaneStats:IsDebugLevel(1) then
		InsaneStats:Log("To unlock:")
		PrintTable(entitiesRequiredToUnlock)
		InsaneStats:Log("From:")
		PrintTable(entitiesUnlock)
	end
end
hook.Add("InitPostEntity", "InsaneStatsWPASS2", MapUnlocks)
hook.Add("PostCleanupMap", "InsaneStatsWPASS2", MapUnlocks)

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
			if IsValid(ply) then
				if ply:InsaneStats_GetStatusEffectLevel("starlight") <= 0
				and ply:InsaneStats_GetSkillStacks("starlight") <= 0 then
					for i,v in ipairs(ply:GetChildren()) do
						if v.insaneStats_IsStarlight then
							SafeRemoveEntity(v)
						end
					end
				end
			end
		end)

		ply:InsaneStats_SetSkillData("fight_for_your_life", 0, 0)
		ply:InsaneStats_SetSkillData("master_of_air", 0, 0)
	end
	--[[if IsValid(ply.insaneStats_Starlight) then
		ply.insaneStats_Starlight:Remove()
	end]]
end)

hook.Add("PlayerUse", "InsaneStatsWPASS2", function(ply, ent)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local class = ent:GetClass()
		if rechargerClasses[class] and (ent.insaneStats_DeadToPlayers and ent.insaneStats_DeadToPlayers[ply]) then
			return false
		elseif (class == "item_suitcharger" or class == "func_recharge")
		and ply:InsaneStats_GetArmor() >= ply:InsaneStats_GetMaxArmor() then
			local overLoadedArmor = (
				ply:InsaneStats_GetAttributeValue("charger_fullpickup") ~= 1
				and ply:InsaneStats_GetAttributeValue("charger_fullpickup")
				or 0
			) + (ply:InsaneStats_GetEffectiveSkillTier("boundless_shield") > 1 and 1 or 0)
			if overLoadedArmor > 0 then
				local armorToAdd = ent:GetInternalVariable("m_iJuice")
				* overLoadedArmor
				* ply:InsaneStats_GetCurrentArmorAdd()
				
				if ent:HasSpawnFlags(8192) then
					ply:InsaneStats_AddHealthNerfed(ply:InsaneStats_GetHealth() + armorToAdd/2)
				end
				
				ply:InsaneStats_AddArmorNerfed(armorToAdd)
				
				ent:SetSaveValue("m_iJuice",0)
			end
		elseif (entitiesRequiredToUnlock[ent] or entitiesUnlock[ent])
		and (
			ply:InsaneStats_EffectivelyHasSkill("ctrl_f")
			--or ply:InsaneStats_GetAttributeValue("ctrl_f") > 1
		) then
			local tableToSend = {}
			local curTime = CurTime()

			if ply:InsaneStats_GetEffectiveSkillTier("ctrl_f") > 1 then
				local toCheck = entitiesUnlock[ent] or {}
				while next(toCheck) do
					local nextCheck = {}
					for k,v in pairs(toCheck) do
						if IsValid(k) and not tableToSend[k] then
							tableToSend[k] = 2
							local kName = k:GetName()
							table.Merge(nextCheck, jottedUnlockerInputs[kName] or {})
							table.Merge(nextCheck, jottedRelayerInputs[kName] or {})
						end
					end
					toCheck = nextCheck
				end

				local toCheck = entitiesRequiredToUnlock[ent] or {}
				while next(toCheck) do
					local nextCheck = {}
					for k,v in pairs(toCheck) do
						if IsValid(k) and not tableToSend[k] then
							tableToSend[k] = 1
							local kName = k:GetName()
							table.Merge(nextCheck, jottedUnlockerInputs[kName] or {})
							table.Merge(nextCheck, jottedRelayerInputs[kName] or {})
						end
					end
					toCheck = nextCheck
				end
			else
				for k,v in pairs(entitiesRequiredToUnlock[ent] or {}) do
					if IsValid(k) then
						tableToSend[k] = 1
					else
						entitiesRequiredToUnlock[ent][k] = nil
					end
				end
				for k,v in pairs(entitiesUnlock[ent] or {}) do
					if IsValid(k) then
						tableToSend[k] = 2
					else
						entitiesUnlock[ent][k] = nil
					end
				end
			end

			net.Start("insane_stats")
			net.WriteUInt(4, 8)
			net.WriteBool(true)
			
			local count = math.min(table.Count(tableToSend), 255)
			net.WriteUInt(count, 8)

			for k,v in pairs(tableToSend) do
				net.WriteUInt(k:EntIndex(), 16)
				net.WriteVector(k:WorldSpaceCenter())
				net.WriteString(k:GetClass())
				net.WriteUInt(v, 2)
			end

			net.Send(ply)
		end

		local physObj = ent:GetPhysicsObject()
		local realTime = RealTime()
		if ent:GetSolid() == SOLID_VPHYSICS and IsValid(physObj)
		and ply:InsaneStats_GetSkillState("blast_proof_suit") == 1 then
			local maxMass = 35 * (1 + ply:InsaneStats_GetEffectiveSkillValues("blast_proof_suit", 3) / 100)

			local last_use_press = ent:InsaneStats_GetEntityData("last_use_press") or 0
			if last_use_press + 0.05 < realTime
			and physObj:GetMass() <= maxMass and physObj:IsMoveable() then
				--print("YES")
				timer.Simple(0, function()
					if IsValid(ply) and (IsValid(ent) and not ent:IsPlayerHolding()) then
						ply:PickupObject(ent)
					end
				end)
			--else
				--print("NO")
			end

			ent:InsaneStats_SetEntityData("last_use_press", realTime)
		end

		local button = class == "momentary_rot_button" and ent
		local parent = ent:GetParent()
		if (IsValid(parent) and parent:GetClass() == "momentary_rot_button") then
			button = parent
		end
		if (IsValid(button) and button:HasSpawnFlags(1024))
		and ply:InsaneStats_GetSkillState("celebration") == 1 then
			local last_use_press = button:InsaneStats_GetEntityData("last_use_press") or 0
			local cancel
			if last_use_press + 0.05 < realTime then
				local desiredDir = button:GetInternalVariable("startdirection")
				if desiredDir < 0 then
					button:Fire("setposition", 1)
					cancel = true
				else
					button:Fire("setposition", 0)
					cancel = true
				end
			else
				cancel = true
			end

			button:InsaneStats_SetEntityData("last_use_press", realTime)
			if cancel then return false end
		end
	end
end)

local function bloodlet(ent)
	local bloodFrac = ent:InsaneStats_GetAttributeValue("bloodletting")
	if ent:InsaneStats_EffectivelyHasSkill("bloodletter_pact") then
		bloodFrac = math.min(bloodFrac, ent:InsaneStats_GetEffectiveSkillValues("bloodletter_pact") / 100)
	end

	if bloodFrac ~= 1 and ent:InsaneStats_GetMaxArmor() > 0 then
		local minimumHealth = ent:InsaneStats_GetMaxHealth() * bloodFrac
		local lostHealth = minimumHealth < math.huge
			and math.ceil(ent:InsaneStats_GetHealth() - minimumHealth) or math.huge
		local armorMul = 1
		
		if lostHealth > 0 then
			ent:InsaneStats_AddArmorNerfed(lostHealth * armorMul)
			ent:SetHealth(minimumHealth)
		end
	end
end
hook.Add("InsaneStatsWPASS2AddedHealth", "InsaneStatsWPASS2", function(ent)
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
				or k:InsaneStats_EffectivelyHasSkill("alert")
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
						net.WriteBool(false)
						net.WriteUInt(ent:EntIndex(), 16)
						net.WriteVector(pos)
						net.WriteString(ent:GetClass())
						net.WriteDouble(ent:InsaneStats_GetHealth())
						net.WriteDouble(ent:InsaneStats_GetMaxHealth())
						net.WriteDouble(ent:InsaneStats_GetArmor())
						net.WriteDouble(ent:InsaneStats_GetMaxArmor())
						net.WriteBool(select(3, ColorToHSL(ent:GetColor())) < 0.05)
						net.Send(k)
					elseif (k:IsNPC() and k:Disposition(ent) == D_HT and k.HasEnemyEluded and k:HasEnemyEluded(ent)) then
						k:UpdateEnemyMemory(ent, ent:GetPos())
					end
				elseif k.insaneStats_MarkedEntity then
					k.insaneStats_MarkedEntity = nil

					if k:IsPlayer() then
						net.Start("insane_stats")
						net.WriteUInt(4, 8)
						net.WriteBool(false)
						net.WriteUInt(0, 16)
						net.Send(k)
					end
				end
			end
		end

		coroutine.yield(true)
	end
end)

hook.Add("InsaneStatsCrossbowBoltLanded", "InsaneStatsWPASS2", function(bolt, attacker)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local shouldSkillExplode = IsValid(attacker) and attacker:InsaneStats_GetSkillState("brilliant_behemoth") == 1
		if shouldSkillExplode then
			CauseExplosion({
				attacker = attacker,
				damageTier = 1,
				damage = GetConVar("sk_plr_dmg_xbow_bolt_npc"):GetFloat(),
				damagePos = bolt:WorldSpaceCenter(),
				damageType = DMG_BLAST,
				radius = attacker:InsaneStats_GetEffectiveSkillValues(
					"brilliant_behemoth", 2
				),
				isSkillExplosion = true
			})
		end
	end
end)

hook.Add("InsaneStatsWeaponSwitched", "InsaneStatsWPASS2", function(ply, old, new)
	if IsValid(old) then
		if ply:InsaneStats_GetSkillState("honorbound") == 2 then
			ply:SetHealth(ply:InsaneStats_GetHealth() * (
				1 + ply:InsaneStats_GetEffectiveSkillValues("honorbound", 2) / 100
			))
		else
			ply:InsaneStats_SetSkillData("honorbound", 2, 0)
		end
	end
end)

local nextItemSpawn = 0
local currentCoinIndex, coins
hook.Add("Think", "InsaneStatsWPASS2", function()
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		explosionCount = 0
		scatterShotEntities = {}

		for k,v in pairs(grenadedEntities) do
			if IsValid(k) then
				for i,v2 in ipairs(v) do
					local grenade = ents.Create("npc_grenade_frag")
					if IsValid(grenade) then
						grenade:SetPos(v2)
						grenade:SetOwner(k)
						grenade:SetSaveValue("m_hThrower", k)
						grenade:Spawn()
						grenade:Activate()
						grenade:SetSaveValue("m_takedamage", 1)

						local physObj = grenade:GetPhysicsObject()
						if IsValid(physObj) then
							physObj:ApplyTorqueCenter(VectorRand(-4, 4))
							physObj:SetVelocity(-physenv.GetGravity() * 1.125)
						end

						grenade:Fire("SetTimer", 2)
					end
				end
			end
		end
		grenadedEntities = {}

		if not coins then
			coins = ents.FindByClass("insanestats_coin")
			currentCoinIndex = 0
		end

		currentCoinIndex = currentCoinIndex + 1
		if not IsValid(coins[currentCoinIndex]) then
			if currentCoinIndex > 2 then
				currentCoinIndex = 1
			elseif currentCoinIndex > 1 then
				currentCoinIndex = -10
				coins = ents.FindByClass("insanestats_coin")
			end
		end
		local currentCoin = coins[currentCoinIndex]
		local coinNearestPlayer = NULL
		local coinShortestDistance = math.huge
		local oldTotalDilation = InsaneStats.totalTimeDilation or 1
		
		InsaneStats.totalTimeDilation = 1
		local curTime = CurTime()
		
		for k,v in pairs(rapidThinkEntities) do
			if IsValid(k) then
				local wep = k.GetActiveWeapon and k:GetActiveWeapon()
				
				if k:IsPlayer() or k:IsNextBot() then
					-- NPCs can't have their speeds changed, I've tried
					k.insaneStats_OldMoveMul = k.insaneStats_OldMoveMul or 1
					k.insaneStats_OldSprintMoveMul = k.insaneStats_OldSprintMoveMul or 1
					k.insaneStats_OldCrouchedMoveMul = k.insaneStats_OldCrouchedMoveMul or 1
					k.insaneStats_OldLaggedMoveMul = k.insaneStats_OldLaggedMoveMul or 1
					k.insaneStats_OldHullMul = k.insaneStats_OldHullMul or 1
					k.insaneStats_OldFrictionMul = k.insaneStats_OldFrictionMul or 1
					k.insaneStats_OldStepMul = k.insaneStats_OldStepMul or 1
					local data = {
						ent = k, speed = 1, sprintSpeed = 1, crouchedSpeed = 1, laggedSpeed = 1,
						hullSize = 1, friction = 1, stepHeight = 1
					}
					hook.Run("InsaneStatsMoveSpeed", data)
					local newMoveSpeed = data.speed
					local newSprintSpeed = data.sprintSpeed
					local newCrouchedSpeed = data.crouchedSpeed
					local newLaggedSpeed = data.laggedSpeed
					local newHullMul = data.hullSize
					local newFrictionMul = data.friction
					local newStepHeight = data.stepHeight
					if k.insaneStats_OldMoveMul ~= newMoveSpeed
					or k.insaneStats_OldSprintMoveMul ~= newSprintSpeed
					or k.insaneStats_OldCrouchedMoveMul ~= newCrouchedSpeed
					or k.insaneStats_OldLaggedMoveMul ~= laggedSpeed
					or k.insaneStats_OldHullMul ~= newHullMul
					or k.insaneStats_OldFrictionMul ~= newFrictionMul
					or k.insaneStats_OldStepMul ~= newStepHeight
					or engine.TickCount() % 200 == 0 then
						local applyMul = newMoveSpeed / k.insaneStats_OldMoveMul
						local sprintApplyMul = applyMul * newSprintSpeed / k.insaneStats_OldSprintMoveMul
						local crouchedApplyMul = newCrouchedSpeed / k.insaneStats_OldCrouchedMoveMul
						local laggedApplyMul = newLaggedSpeed / k.insaneStats_OldLaggedMoveMul
						local hullMul = newHullMul / k.insaneStats_OldHullMul
						local frictionMul = newFrictionMul / k.insaneStats_OldFrictionMul
						local stepMul = newStepHeight / k.insaneStats_OldStepMul
						if (
							k:IsPlayer() and (
								not k:IsSprinting()
								or k:InsaneStats_GetEntityData("update_speed_immediately")
							)
						) then
							k:InsaneStats_SetEntityData("update_speed_immediately", false)
							if InsaneStats:GetConVarValue("wpass2_attributes_player_constant_speed") then
								local runSpeed = 400*newMoveSpeed*newSprintSpeed
								local walkSpeed = 200*newMoveSpeed
								local slowWalkSpeed = 100*math.sqrt(newMoveSpeed)
								local crouchSpeed = 0.3*newCrouchedSpeed
								local stepHeight = 18*newStepHeight

								k:SetLadderClimbSpeed(slowWalkSpeed*2)
								k:SetMaxSpeed(walkSpeed)
								k:SetRunSpeed(runSpeed)
								k:SetWalkSpeed(walkSpeed)
								k:SetSlowWalkSpeed(slowWalkSpeed)
								k:SetCrouchedWalkSpeed(crouchSpeed)
								k:SetDuckSpeed(crouchSpeed)
								k:SetUnDuckSpeed(crouchSpeed)
								k:SetFriction(newFrictionMul)
								k:SetStepSize(stepHeight)
								if laggedApplyMul ~= 1 then
									k:SetLaggedMovementValue(newLaggedSpeed)
								end

								if hullMul ~= 1 then
									k:SetHull(
										Vector(-16 * newHullMul, -16 * newHullMul, 0),
										Vector(16 * newHullMul, 16 * newHullMul, 72 * newHullMul)
									)
									k:SetHullDuck(
										Vector(-16 * newHullMul, -16 * newHullMul, 0),
										Vector(16 * newHullMul, 16 * newHullMul, 36 * newHullMul)
									)
								end
							else
								k:SetLadderClimbSpeed(k:GetLadderClimbSpeed()*math.sqrt(applyMul))
								k:SetMaxSpeed(k:GetMaxSpeed()*applyMul)
								k:SetRunSpeed(k:GetRunSpeed()*sprintApplyMul)
								k:SetWalkSpeed(k:GetWalkSpeed()*applyMul)
								k:SetSlowWalkSpeed(k:GetSlowWalkSpeed()*math.sqrt(applyMul))
								k:SetCrouchedWalkSpeed(k:GetCrouchedWalkSpeed()*crouchedApplyMul)
								k:SetDuckSpeed(k:GetDuckSpeed()*crouchedApplyMul)
								k:SetUnDuckSpeed(k:GetUnDuckSpeed()*crouchedApplyMul)
								k:SetLaggedMovementValue(k:GetLaggedMovementValue()*laggedApplyMul)
								k:SetFriction(k:GetFriction()*frictionMul)
								k:SetStepSize(k:GetStepSize()*stepMul)

								local mins, maxs = k:GetHull()
								k:SetHull(mins * hullMul, maxs * hullMul)
								mins, maxs = k:GetHullDuck()
								k:SetHullDuck(mins * hullMul, maxs * hullMul)
							end
							
							-- only update if speed was actually updated
							k.insaneStats_OldMoveMul = newMoveSpeed
							k.insaneStats_OldSprintMoveMul = newSprintSpeed
							k.insaneStats_OldCrouchedMoveMul = newCrouchedSpeed
							k.insaneStats_OldLaggedMoveMul = newLaggedSpeed
							k.insaneStats_OldHullMul = newHullMul
							k.insaneStats_OldFrictionMul = newFrictionMul
							k.insaneStats_OldStepMul = newStepHeight
						elseif SERVER and k:IsNextBot() then
							k.loco:SetDesiredSpeed(k.loco:GetDesiredSpeed()*applyMul)
						
							k.insaneStats_OldMoveMul = newMoveSpeed
							k.insaneStats_OldSprintMoveMul = newSprintSpeed
							k.insaneStats_OldCrouchedMoveMul = newCrouchedSpeed
							k.insaneStats_OldLaggedMoveMul = newLaggedSpeed
							k.insaneStats_OldHullMul = newHullMul
							k.insaneStats_OldFrictionMul = newFrictionMul
							k.insaneStats_OldStepMul = newStepHeight
						end
					end
					
					if k:IsPlayer() then
						-- there are two particular non-Lua weapons - weapon_grenade and weapon_rpg - that don't have unlimited ammo + don't use clips.
						k.insaneStats_LastWeapon = k.insaneStats_LastWeapon or wep
						if k.insaneStats_LastWeapon == wep and (IsValid(wep) and not wep:IsScripted()) then
							if wep:InsaneStats_Clip1() <= 0 then
								local ammoType = wep:GetPrimaryAmmoType()
								local count = k:InsaneStats_GetAmmoCount(ammoType)
								k.insaneStats_LastPrimaryAmmo = k.insaneStats_LastPrimaryAmmo or count
								if k.insaneStats_LastPrimaryAmmo ~= count then
									-- FIXME: wouldn't it be easier to just call the relevant hook???
									k.insaneStats_OldSetAmmoValue = k.insaneStats_LastPrimaryAmmo
									k:SetAmmo(count, ammoType)
									k.insaneStats_LastPrimaryAmmo = k:InsaneStats_GetAmmoCount(ammoType)
									k.insaneStats_OldSetAmmoValue = nil
								end
							else
								k.insaneStats_LastPrimaryAmmo = nil
							end
							if wep:InsaneStats_Clip2() <= 0 then
								local ammoType = wep:GetSecondaryAmmoType()
								local count = k:InsaneStats_GetAmmoCount(ammoType)
								k.insaneStats_LastSecondaryAmmo = k.insaneStats_LastSecondaryAmmo or count
								if k.insaneStats_LastSecondaryAmmo ~= count then
									k.insaneStats_OldSetAmmoValue = k.insaneStats_LastSecondaryAmmo
									k:SetAmmo(count, ammoType)
									k.insaneStats_LastSecondaryAmmo = k:InsaneStats_GetAmmoCount(ammoType)
									k.insaneStats_OldSetAmmoValue = nil
								end
							else
								k.insaneStats_LastSecondaryAmmo = nil
							end
						else
							k.insaneStats_LastPrimaryAmmo = nil
							k.insaneStats_LastSecondaryAmmo = nil

							if k.insaneStats_LastWeapon ~= wep then
								hook.Run("InsaneStatsWeaponSwitched", k, k.insaneStats_LastWeapon, wep)
							end
						end
						k.insaneStats_LastWeapon = wep

						-- check for aux drain rate
						local drainRate = k:InsaneStats_GetAttributeValue("aux_drain")
						drainRate = drainRate * (1 - k:InsaneStats_GetEffectiveSkillValues("aux_aux_battery", 2) / 100)
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

						local magnetRadius = k:InsaneStats_GetAttributeValue("magnet") - 1 + k:InsaneStats_GetEffectiveSkillValues("item_magnet")
						local traceResult = {}
						local trace = {
							start = k:WorldSpaceCenter(),
							filter = {k, k.GetVehicle and k:GetVehicle()},
							mask = MASK_PLAYERSOLID,
							output = traceResult
						}
						local backupPosition = k:WorldSpaceCenter()
						local ourPosition = backupPosition + k:GetVelocity() * engine.TickInterval() * 3
						--debugoverlay.Cross(ourPosition, 1, 1, color_white, true)
						if not util.IsInWorld(ourPosition) then ourPosition = backupPosition end

						local otherPlayerPositions = {}
						for i,v2 in player.Iterator() do
							if v2 ~= k then
								table.insert(otherPlayerPositions, v2:WorldSpaceCenter())
							end
						end
						for i,v2 in ipairs(ents.FindInSphere(k:WorldSpaceCenter(), magnetRadius)) do
							local shouldAutoPickup, shouldSwap = true, true
							if v2:InsaneStats_IsWPASS2Pickup() then
								shouldAutoPickup, shouldSwap = k:InsaneStats_ShouldAutoPickup(v2, true)
							end

							-- if there is a player closer to the item, bail
							local closestPlayer = true
							local itemPos = v2:WorldSpaceCenter()
							local ourDistanceSqr = ourPosition:DistToSqr(itemPos)
							for i,v in ipairs(otherPlayerPositions) do
								if v:DistToSqr(itemPos) < ourDistanceSqr then
									closestPlayer = false break
								end
							end

							if v2:InsaneStats_IsItem() and not IsValid(v2:GetOwner())
							and (v2.insaneStats_PreventMagnet or 0) < 100
							and not (v2:IsWeapon() and v2:HasSpawnFlags(SF_WEAPON_NO_PLAYER_PICKUP))
							and (shouldAutoPickup or shouldSwap) and closestPlayer then
								local physObj = v2:GetPhysicsObject()
								if IsValid(physObj) then
									trace.endpos = itemPos
									util.TraceLine(trace)
									if not traceResult.Hit or traceResult.Entity == v2 then
										local dir = ourPosition - itemPos
										if not dir:IsZero() then
											--local len = dir:Length()
											local mult = 64
											dir:Normalize()
											dir:Mul(0 + trace.endpos:Distance(trace.start) * mult)
											physObj:SetVelocity(dir)
											v2:SetCollisionGroup(COLLISION_GROUP_WORLD)
											v2.insaneStats_PreventMagnet = (v2.insaneStats_PreventMagnet or 0) + 0.25
										end
									end
								end
							end
						end
					
						for i,v2 in ipairs(k:GetWeapons()) do
							local lastFired = v2:InsaneStats_GetEntityData("last_fired_t4d")
		
							if k:InsaneStats_EffectivelyHasSkill("the_fourth_dimension")
							and (lastFired and lastFired + k:InsaneStats_GetEffectiveSkillValues("the_fourth_dimension") < curTime) then
								v2:InsaneStats_SetEntityData("last_fired_t4d", nil)
		
								local clip = v2:InsaneStats_Clip1()
								local maxClip = v2:GetMaxClip1()
								if maxClip > 0 and clip < maxClip then
									local ammoType = v2:GetPrimaryAmmoType()
									local playerAmmoCount = k:InsaneStats_GetAmmoCount(ammoType)
									local ammoToRemove = math.min(maxClip - clip, playerAmmoCount)
									v2:SetClip1(clip + ammoToRemove)
									k:SetAmmo(playerAmmoCount - ammoToRemove, ammoType)
								end
		
								clip = v2:InsaneStats_Clip2()
								maxClip = v2:GetMaxClip2()
								if maxClip > 0 and clip < maxClip then
									local ammoType = v2:GetSecondaryAmmoType()
									local playerAmmoCount = k:InsaneStats_GetAmmoCount(ammoType)
									local ammoToRemove = math.min(maxClip - clip, playerAmmoCount)
									v2:SetClip2(clip + ammoToRemove)
									k:SetAmmo(playerAmmoCount - ammoToRemove, ammoType)
								end
							end
						end

						if (IsValid(wep) and wep:GetClass() == "weapon_rpg")
						and (k:InsaneStats_GetEntityData("explosive_arsenal_rpg_nextfire") or 0) <= CurTime()
						and k:KeyDown(IN_ATTACK2) and k:InsaneStats_EffectivelyHasSkill("explosive_arsenal") then
							if k:InsaneStats_GetAmmoCount("RPG_Round") > 0 then
								local cooldown = k:InsaneStats_GetEffectiveSkillValues("explosive_arsenal", 5)
								local invincible = bit.band(k:InsaneStats_GetSkillStacks("explosive_arsenal"), 2) == 0
								k:RemoveAmmo(1, "RPG_Round")

								if invincible then cooldown = cooldown * 2 end
								k:InsaneStats_SetEntityData("explosive_arsenal_rpg_nextfire", CurTime() + cooldown)
				
								local rocket = ents.Create("rpg_missile")
								rocket:SetOwner(k)
								rocket:SetSaveValue("m_flDamage", 150)
								rocket:SetPos(k:GetShootPos())
								rocket:SetAngles(k:EyeAngles())
								rocket:Spawn()
								rocket:Activate()
								rocket:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
				
								if invincible then
									rocket.insaneStats_TempInvincible = 1
									rocket:SetSaveValue("m_takedamage", 1)
								end
							else
								wep:EmitSound("Weapon_Pistol.Empty")
								k:InsaneStats_SetEntityData("explosive_arsenal_rpg_nextfire", CurTime() + 1)
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
					
					wep.insaneStats_LastClip1 = wep.insaneStats_LastClip1 or wep:InsaneStats_Clip1()
					if wep.insaneStats_LastClip1 ~= wep:InsaneStats_Clip1() then
						wep:SetClip1(wep:InsaneStats_Clip1())
						wep.insaneStats_LastClip1 = wep:InsaneStats_Clip1()
					end
					
					wep.insaneStats_LastClip2 = wep.insaneStats_LastClip2 or wep:InsaneStats_Clip2()
					if wep.insaneStats_LastClip2 ~= wep:InsaneStats_Clip2() then
						wep:SetClip2(wep:InsaneStats_Clip2())
						wep.insaneStats_LastClip2 = wep:InsaneStats_Clip2()
					end
				end
				
				if k:InsaneStats_GetStatusEffectLevel("no_time_manipulation") <= 0 then
					if (k:IsPlayer() and not k:InVehicle()) then
						local plyVel = k:GetVelocity()
						local speedFactor = plyVel:Length2DSqr()^0.25 / 20
						* math.sqrt(1 + k:InsaneStats_GetEffectiveSkillValues("beyond_240_kmph") / 100)
						local value = k:InsaneStats_GetAttributeValue("speed_dilation")
						if game.SinglePlayer() then
							value = value * (1 + k:InsaneStats_GetEffectiveSkillValues("super_cold") / 100)
						end
						if value ~= 1 then
							InsaneStats.totalTimeDilation = InsaneStats.totalTimeDilation
							* (1 + (value - 1) * speedFactor)
						end
					end
					
					InsaneStats.totalTimeDilation = InsaneStats.totalTimeDilation / (1+k:InsaneStats_GetStatusEffectLevel("ctrl_gamespeed_up")/100)
					InsaneStats.totalTimeDilation = InsaneStats.totalTimeDilation / (1-k:InsaneStats_GetStatusEffectLevel("alt_gamespeed_down")/100)
				end

				-- SKILLS

				if k:IsPlayer() then
					--[[if k:InsaneStats_GetSkillState("mantreads") == 1 and k:GetVelocity().z > -3400 then
						k:SetVelocity(vector_up * -10000)
					end]]

					if game.SinglePlayer() and k:InsaneStats_GetStatusEffectLevel("no_time_manipulation") <= 0 then
						InsaneStats.totalTimeDilation = InsaneStats.totalTimeDilation / (1+k:InsaneStats_GetSkillStacks("aint_got_time_for_this")/100)

						if k:InsaneStats_GetSkillState("just_breathe") == 1 then
							InsaneStats.totalTimeDilation = InsaneStats.totalTimeDilation
							/ (1 + k:InsaneStats_GetEffectiveSkillValues("just_breathe", 2)/100)
						end
					end
				end

				k:InsaneStats_SetEntityData(
					"distance_travelled",
					(k:InsaneStats_GetEntityData("distance_travelled") or 0)
					+ k:InsaneStats_GetEffectiveSpeed() * FrameTime()
				)

				if k:InsaneStats_EffectivelyHasSkill("too_many_items") then
					local tmiStacks = k:InsaneStats_GetSkillStacks("too_many_items")
					local nextStacks = tmiStacks % 100
					local triggers = math.Round((tmiStacks - nextStacks) / 100)

					if triggers > 0 then
						local tempEnt = ents.Create("info_null")
						tempEnt:SetPos(k:WorldSpaceCenter())
						tempEnt:InsaneStats_SetEntityData("tmi_triggerer", true)

						hook.Run("InsaneStatsPlayerPickedUpItem", k, tempEnt, triggers)

						tempEnt:Spawn()
					end

					k:InsaneStats_SetSkillData("too_many_items", 0, nextStacks)
				end
			end
		end
		
		if IsValid(coinNearestPlayer) then
			if CurTime() >= currentCoin:GetCreationTime() + coinNearestPlayer:InsaneStats_GetEffectiveSkillValues("item_magnet", 2)
			and coinNearestPlayer:InsaneStats_EffectivelyHasSkill("item_magnet") then
				currentCoin:Pickup(coinNearestPlayer)
			end
		end

		if oldTotalDilation ~= InsaneStats.totalTimeDilation then
			if InsaneStats:GetConVarValue("wpass2_attributes_player_constant_timescale") then
				game.SetTimeScale(1 / InsaneStats.totalTimeDilation)
			else
				game.SetTimeScale(game.GetTimeScale() * oldTotalDilation / InsaneStats.totalTimeDilation)
			end
			
			oldTotalDilation = InsaneStats.totalTimeDilation
		end

		--local timeStart = SysTime()
		if coroutine.status(markingScanner) ~= "dead" then
			for i=1,100 do
				local success, ret = coroutine.resume(markingScanner)
				if success then
					if ret then break end
				else
					error(ret)
				end
			end
		end

		if next(queuedUnlockSends) then
			local playerFilter = RecipientFilter()
			for i,v in player.Iterator() do
				if v:InsaneStats_GetEffectiveSkillTier("ctrl_f") > 1 then
					playerFilter:AddPlayer(v)
				end
			end

			net.Start("insane_stats")
			net.WriteUInt(4, 8)
			net.WriteBool(true)

			local toNetwork = {}
			for k,v in pairs(queuedUnlockSends) do
				if IsValid(k) then
					table.insert(toNetwork, {k:EntIndex(), k:WorldSpaceCenter(), k:GetClass()})
				end
			end

			net.WriteUInt(#toNetwork, 8)
			for i,v in ipairs(toNetwork) do
				net.WriteUInt(v[1], 16)
				net.WriteVector(v[2])
				net.WriteString(v[3])
				net.WriteUInt(3, 2)
			end

			net.Send(playerFilter)

			queuedUnlockSends = {}
		end

		if nextItemSpawn < CurTime() then
			nextItemSpawn = CurTime() + 0.5
			local pos = table.remove(pendingItemSpawns, 1)
			if pos then
				local parent = pos[2]
				if IsValid(parent) then
					--[[local backupPos = parent:GetPos()
					local traceResult = util.TraceLine({
						start = backupPos,
						endpos = backupPos + parent:GetVelocity() * engine.TickInterval() * 4,
						filter = parent,
						mask = MASK_PLAYERSOLID
					})
					pos = traceResult.HitPos]]
					-- pos = backupPos + parent:GetVelocity() * engine.TickInterval() * 4
					-- if not util.IsInWorld(pos) then pos = backupPos end
					pos = parent:GetPos()
				else
					pos = pos[1]
				end
				local canAnyAmmo = false

				for i,v in player.Iterator() do
					if v:InsaneStats_EffectivelyHasSkill("looting") or v:InsaneStats_EffectivelyHasSkill("fortune") then
						canAnyAmmo = true
					else
						for j=1,9 do
							if v:InsaneStats_GetAmmoCount(j) > 0 then
								cachedPlayersAmmo[j] = true break
							end
						end
						if v:HasWeapon("weapon_grenade") then
							cachedPlayersAmmo[10] = true
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
				if IsValid(parent) then
					item:SetParent(parent)
				end
				item:Spawn()
				item:Activate()
			end
		
			local toDistribute = {}
			local itemLimit = InsaneStats:GetConVarValue("wpass2_item_limit")
			
			if itemLimit >= 0 then
				for i,v in ents.Iterator() do
					local class = v:GetClass()
					if possibleItems[class] then
						if not v:CreatedByMap() and not IsValid(v:GetOwner()) then
							table.insert(toDistribute, v)
						end
					end
				end
		
				if #toDistribute > itemLimit then
					if #toDistribute > itemLimit * 2 then
						for i,v in ipairs(toDistribute) do
							SafeRemoveEntity(v)
						end
					else
						local plys = {}
						for i,v in player.Iterator() do
							if v:GetMoveType() == MOVETYPE_WALK and not v:IsFrozen() then
								table.insert(plys, v)
							end
						end
						
						if next(plys) then
							-- distribute items randomly
							for i,v in ipairs(toDistribute) do
								if (v:InsaneStats_GetEntityData("item_teleported") or 0) + 1 < CurTime() then
									v:InsaneStats_SetEntityData("item_teleported", CurTime())
									v:SetPos(plys[math.random(#plys)]:WorldSpaceCenter())
								end
							end
						end
					end
				end
			end
		end

		-- item parenting is a very bad idea
		-- since it's not clear whether the item will be automatically picked up or not

		--print((SysTime() - timeStart) * 1000)
		--print(InsaneStats.totalTimeDilation)
	end
end)

hook.Add("OnEntityWaterLevelChanged", "InsaneStatsWPASS2", function(ent, old, new)
	if (new > 1) ~= (old > 1) then
		ent:InsaneStats_SetEntityData("update_speed_immediately", true)
		ent:InsaneStats_SetSkillData("so_heres_the_problem", new > 1 and 2 or 0, 0)
	end
end)

hook.Add("break_prop", "InsaneStatsWPASS2", function(data)
	local victim = Entity(data.entindex or 0)
	local attacker = Player(data.userid or 0)
	
	ProcessBreakEvent(victim, attacker)
end)

hook.Add("break_breakable", "InsaneStatsWPASS2", function(data)
	local victim = Entity(data.entindex or 0)
	local attacker = Player(data.userid or 0)
	
	ProcessBreakEvent(victim, attacker)
end)

hook.Add("PropBreak", "InsaneStatsWPASS2", function(attacker, victim)
	ProcessBreakEvent(victim, attacker)
end)

local function GetAmmoConsumptionMul(ent, wep, secondary)
	local mul = ent:InsaneStats_GetAttributeValue("ammo_consumption")
	* (1 + ent:InsaneStats_GetEffectiveSkillValues("reuse") / 100)
	/ (1 + ent:InsaneStats_GetStatusEffectLevel("ammo_efficiency_up") / 100)
	/ (1 + ent:InsaneStats_GetStatusEffectLevel("stack_ammo_efficiency_up") / 100)
	
	if IsValid(wep) and ent:InsaneStats_EffectivelyHasSkill("dangerous_preparation") then
		local clip = secondary and wep:InsaneStats_Clip2() or wep:InsaneStats_Clip1()
		local maxClip = secondary and wep:GetMaxClip2() or wep:GetMaxClip1()
		local clipFraction = math.sqrt(math.max(clip, 0) / maxClip)
		if maxClip <= 0 then
			clipFraction = 1
		end
		mul = mul
		* (1 + ent:InsaneStats_GetEffectiveSkillValues("dangerous_preparation") / 100 * clipFraction)
	end

	return mul
end
hook.Add("InsaneStatsModifyWeaponClip", "InsaneStatsWPASS2", function(data)
	local attacker = data.wep:GetOwner()
	if IsValid(attacker) and data.old > data.new then
		local toRemove = (data.old - data.new) * GetAmmoConsumptionMul(
			attacker, data.wep, data.secondary
		)
		data.new = data.old - toRemove
	end
end)

local function ProcessAmmoChange(ply, ammoID, current)
	local new
	if not tonumber(ammoID) then ammoID = game.GetAmmoID(ammoID) end
	if ply:InsaneStats_EffectivelyHasSkill("more_bullet_per_bullet") then
		local maxReserve = game.GetAmmoMax(ammoID)
		local skillValues = {ply:InsaneStats_GetEffectiveSkillValues("more_bullet_per_bullet")}
		local maxPlayerReserve = maxReserve * skillValues[1] / 100
		if current > maxPlayerReserve and maxReserve > 0 then
			local newStacks = math.min(
				math.huge,--skillValues[2],
				ply:InsaneStats_GetSkillStacks("more_bullet_per_bullet")
				+ (current - maxPlayerReserve) / maxReserve * 100
			)
			ply:InsaneStats_SetSkillData("more_bullet_per_bullet", 1, newStacks)
			new = maxPlayerReserve
			current = maxPlayerReserve
		end
	end
	
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		local maxReserve = game.GetAmmoMax(ammoID)
		local threshold = ply:InsaneStats_GetAttributeValue("ammo_convert")
		local maxPlayerReserve = maxReserve*threshold
		if threshold < 1 and current > maxPlayerReserve and maxReserve > 0 then
			local stacks = (current - maxPlayerReserve) / maxReserve
			ply:InsaneStats_ApplyStatusEffect("stack_ammo_efficiency_up", stacks * 100, math.huge, {amplify = true})
			new = maxPlayerReserve
		end
	end

	return new
end

hook.Add("InsaneStatsPlayerAddAmmo", "InsaneStatsWPASS2", function(data)
	local attacker = data.ply
	if IsValid(attacker) then
		local current = attacker:InsaneStats_GetAmmoCount(data.type)
		local new = ProcessAmmoChange(attacker, data.type, current + data.num)
		if new then
			data.num = math.max(new - current, 0)
		end
	end
end)

hook.Add("InsaneStatsPlayerSetAmmo", "InsaneStatsWPASS2", function(data)
	local attacker = data.ply
	if IsValid(attacker) then
		if data.old > data.new then
			local wep = attacker:GetActiveWeapon()
			
			if IsValid(wep) then
				local primarySavable = wep:GetMaxClip1() <= 0 and wep:GetPrimaryAmmoType() == data.type
				local secondarySavable = wep:GetMaxClip2() <= 0 and wep:GetSecondaryAmmoType() == data.type
				if primarySavable or secondarySavable then
					local toRemove = (data.old - data.new) * GetAmmoConsumptionMul(
						attacker, wep, not primarySavable
					)
					data.new = data.old - toRemove
				end
			end
		end
		data.new = ProcessAmmoChange(attacker, data.type, data.new) or data.new
	end
end)

hook.Add("InsaneStatsPlayerRemoveAmmo", "InsaneStatsWPASS2", function(data)
	local attacker = data.ply
	if IsValid(attacker) and data.num > 0 then
		local wep = attacker:GetActiveWeapon()
		
		if IsValid(wep) then
			local primarySavable = wep:GetMaxClip1() <= 0 and wep:GetPrimaryAmmoType() == data.type
			local secondarySavable = wep:GetMaxClip2() <= 0 and wep:GetSecondaryAmmoType() == data.type
			if primarySavable or secondarySavable then
				data.num = data.num * GetAmmoConsumptionMul(attacker, wep, not primarySavable)
			end
		end
	end
end)

hook.Add("PlayerAmmoChanged", "InsaneStatsWPASS2", function(ply, ammoID, oldAmount, newAmount)
	newAmount = newAmount - (ply.insaneStats_AmmoAdjs and ply.insaneStats_AmmoAdjs[ammoID] or 0)
	local newValue = ProcessAmmoChange(ply, ammoID, newAmount)
	if newValue then
		ply.insaneStats_AmmoAdjs = ply.insaneStats_AmmoAdjs or {}
		ply.insaneStats_AmmoAdjs[ammoID] = (1 - newValue) % 1
		net.Start("insane_stats")
		net.WriteUInt(13, 8)
		net.WriteBool(false)
		net.WriteUInt(1, 16)
		net.WriteUInt(ammoID, 16)
		net.WriteDouble(ply.insaneStats_AmmoAdjs[ammoID])
		net.Send(ply)

		ply:InsaneStats_SetRawAmmo(math.ceil(newValue), ammoID)
	end
	--[[if ply:InsaneStats_EffectivelyHasSkill("more_bullet_per_bullet") then
		newAmount = newAmount - (ply.insaneStats_AmmoAdjs and ply.insaneStats_AmmoAdjs[ammoID] or 0)
		local maxReserve = game.GetAmmoMax(ammoID)
		local skillValues = {ply:InsaneStats_GetEffectiveSkillValues("more_bullet_per_bullet")}
		local maxPlayerReserve = maxReserve * skillValues[1] / 100
		if newAmount > maxPlayerReserve and maxReserve > 0 then
			local newStacks = math.min(
				math.huge,--skillValues[2],
				ply:InsaneStats_GetSkillStacks("more_bullet_per_bullet")
				+ (math.min(newAmount, maxReserve) - maxPlayerReserve) / maxReserve * 100
			)
			ply:InsaneStats_SetSkillData("more_bullet_per_bullet", 1, newStacks)

			ply.insaneStats_AmmoAdjs = ply.insaneStats_AmmoAdjs or {}
			ply.insaneStats_AmmoAdjs[ammoID] = (1 - maxPlayerReserve) % 1
			net.Start("insane_stats")
			net.WriteUInt(13, 8)
			net.WriteBool(false)
			net.WriteUInt(1, 16)
			net.WriteUInt(ammoID, 16)
			net.WriteDouble(ply.insaneStats_AmmoAdjs[ammoID])
			net.Send(ply)

			newAmount = math.ceil(maxPlayerReserve)
			ply:InsaneStats_SetRawAmmo(newAmount, ammoID)
		end
	end
	
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		newAmount = newAmount - (ply.insaneStats_AmmoAdjs and ply.insaneStats_AmmoAdjs[ammoID] or 0)
		local maxReserve = game.GetAmmoMax(ammoID)
		local threshold = ply:InsaneStats_GetAttributeValue("ammo_convert")
		local maxPlayerReserve = maxReserve*threshold
		if threshold < 1 and newAmount > maxPlayerReserve and maxReserve > 0 then
			local stacks = (math.min(newAmount, maxReserve) - maxPlayerReserve) / maxReserve --* ply:InsaneStats_GetAttributeValue("death_promise_damage")
			--timer.Simple(0, function()
				ply:InsaneStats_ApplyStatusEffect("stack_ammo_efficiency_up", stacks * 100, math.huge, {amplify = true})

				ply.insaneStats_AmmoAdjs = ply.insaneStats_AmmoAdjs or {}
				ply.insaneStats_AmmoAdjs[ammoID] = (1 - maxPlayerReserve) % 1
				net.Start("insane_stats")
				net.WriteUInt(13, 8)
				net.WriteBool(false)
				net.WriteUInt(1, 16)
				net.WriteUInt(ammoID, 16)
				net.WriteDouble(ply.insaneStats_AmmoAdjs[ammoID])
				net.Send(ply)

				ply:InsaneStats_SetRawAmmo(math.ceil(maxPlayerReserve), ammoID)
			--end)
		end
	end]]
end)

hook.Add("InsaneStatsPreDeath", "InsaneStatsWPASS2", function(vic, dmginfo)
	if InsaneStats:GetConVarValue("skills_enabled") then
		if vic:InsaneStats_EffectivelyHasSkill("fight_for_your_life")
		and vic:InsaneStats_GetSkillState("fight_for_your_life") == 0
		and vic:IsPlayer() then
			local durationOffset = vic:InsaneStats_GetSkillStacks("fight_for_your_life", true)
			vic:InsaneStats_SetSkillData(
				"fight_for_your_life",
				1,
				vic:InsaneStats_GetEffectiveSkillValues("fight_for_your_life")
				+ durationOffset
			)
			vic.insaneStats_FFYLStacksAdd = durationOffset - 2

			local name = vic:GetName() ~= "" and vic:GetName() or vic:GetClass()
			PrintMessage(HUD_PRINTTALK, name.." has been downed!")
			vic:SetHealth(0)
			vic:SetArmor(0)
			return true
		end
	end
end)

hook.Add("InsaneStatsLevelChanged", "InsaneStatsWPASS2", function(ent, oldLevel, newLevel)
	if InsaneStats:GetConVarValue("skills_enabled") and ent:InsaneStats_EffectivelyHasSkill("actually_levelling_up")
	and oldLevel < newLevel and IsValid(ent) then
		local amplifier = newLevel - oldLevel
		local args = {ent:InsaneStats_GetEffectiveSkillValues("actually_levelling_up", 5)}
		-- wait for level to apply first!
		timer.Simple(0.5, function()
			if IsValid(ent) then
				ent:InsaneStats_AddMaxHealth(amplifier * args[2])
				ent:InsaneStats_AddMaxArmor(amplifier * args[3])
				ent:InsaneStats_AddHealthNerfed(amplifier * args[2] * 2)
				ent:InsaneStats_AddArmorNerfed(amplifier * args[3] * 2)
			end
		end)
	end
end)

hook.Add("InsaneStatsAmmoCrateInteracted", "InsaneStatsWPASS2", function(ent, crate)
	if InsaneStats:GetConVarValue("skills_enabled") and (
		IsValid(ent) and ent:InsaneStats_EffectivelyHasSkill("more_bullet_per_bullet")
	) then
		ent:InsaneStats_SetSkillData("more_bullet_per_bullet", 0, 0)
	end
end)

hook.Add("InsaneStatsCoinsSpawned", "InsaneStatsWPASS2", function()
	coins = nil
end)

hook.Add("InsaneStatsWPASS2AddHealth", "InsaneStatsWPASS2", function(data)
	local ent = data.ent
	if ent:InsaneStats_EffectivelyHasSkill("slow_recovery") and ent:InsaneStats_GetMaxHealth() > 0
	and not isSlowRecovery then
		local stacks = data.health / ent:InsaneStats_GetMaxHealth() * 100
			* (1 + ent:InsaneStats_GetEffectiveSkillValues("slow_recovery") / 100)
			+ ent:InsaneStats_GetSkillStacks("slow_recovery")
		ent:InsaneStats_SetSkillData("slow_recovery", 1, stacks)
		data.health = 0
	else
		data.health = data.health * (1 + ent:InsaneStats_GetEffectiveSkillValues("better_healthcare") / 100)
		* (1 - ent:InsaneStats_GetSkillStacks("hellish_challenge") / 100)
		* (1 + ent:InsaneStats_GetSkillStacks("synergy_2") * ent:InsaneStats_GetEffectiveSkillValues("synergy_2", 2) / 100)
		* (1 + ent:InsaneStats_GetSkillStacks("synergy_3") * ent:InsaneStats_GetEffectiveSkillValues("synergy_3", 2) / 100)

		if ent:InsaneStats_GetStatusEffectLevel("bleed") > 0
		or ent:InsaneStats_GetStatusEffectLevel("hemotoxin") > 0
		or ent:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
			data.health = data.health / 2
		end

		if ent:InsaneStats_EffectivelyHasSkill("more_and_more") and ent:InsaneStats_GetArmor() > 0 then
			local armorBars = ent:InsaneStats_GetMaxArmor() > 0
			and ent:InsaneStats_GetArmor() / ent:InsaneStats_GetMaxArmor()
			or 1
			local potency, base = ent:InsaneStats_GetEffectiveSkillValues("more_and_more")
			local healingMul = math.max(2 + math.log(armorBars, base), 1)
			data.health = data.health * ((healingMul - 1) * potency / 100 + 1)
		end
	end
end)

hook.Add("InsaneStatsWPASS2AddArmor", "InsaneStatsWPASS2", function(data)
	local ent = data.ent
	data.armor = data.armor * (1 + ent:InsaneStats_GetEffectiveSkillValues("better_healthcare") / 100)
	* (1 - ent:InsaneStats_GetSkillStacks("hellish_challenge") / 100)
	* (1 + ent:InsaneStats_GetSkillStacks("synergy_2") * ent:InsaneStats_GetEffectiveSkillValues("synergy_2", 2) / 100)
	* (1 + ent:InsaneStats_GetSkillStacks("synergy_3") * ent:InsaneStats_GetEffectiveSkillValues("synergy_3", 2) / 100)

	if ent:InsaneStats_GetStatusEffectLevel("shock") > 0
	or ent:InsaneStats_GetStatusEffectLevel("electroblast") > 0
	or ent:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
		data.armor = data.armor / 2
	end

	if ent:InsaneStats_EffectivelyHasSkill("more_and_more") and ent:InsaneStats_GetArmor() > 0 then
		local armorBars = ent:InsaneStats_GetMaxArmor() > 0
		and ent:InsaneStats_GetArmor() / ent:InsaneStats_GetMaxArmor()
		or 1
		local potency, base = ent:InsaneStats_GetEffectiveSkillValues("more_and_more")
		local healingMul = math.max(2 + math.log(armorBars, base), 1)
		data.armor = data.armor * ((healingMul - 1) * potency / 100 + 1)
	end
end)

hook.Add("InsaneStatsWPASS2AddMaxHealth", "InsaneStatsWPASS2", function(data)
	data.maxHealth = data.maxHealth
	* (1 + data.ent:InsaneStats_GetEffectiveSkillValues("overheal", 2) / 100)
	* (1 + data.ent:InsaneStats_GetEffectiveSkillValues("better_healthcare") / 100)
end)

hook.Add("InsaneStatsWPASS2AddMaxArmor", "InsaneStatsWPASS2", function(data)	
	local ent = data.ent

	data.maxArmor = data.maxArmor
	* (1 + ent:InsaneStats_GetEffectiveSkillValues("overshield", 2) / 100)
	* (1 + ent:InsaneStats_GetEffectiveSkillValues("better_healthcare") / 100)

	if ent:InsaneStats_GetMaxArmor() > 0 then
		local splitRatio = ent:InsaneStats_GetEffectiveSkillValues("bastion_of_flesh")/100
		local healthMul = ent:InsaneStats_GetEffectiveSkillValues("bastion_of_flesh", 3)

		ent:InsaneStats_AddMaxHealth(data.maxArmor * splitRatio)
		ent:InsaneStats_AddHealthNerfed(data.maxArmor * splitRatio * healthMul)
		if splitRatio == 1 then
			data.maxArmor = 0
		else
			data.maxArmor = data.maxArmor * (1 - splitRatio)
		end
	end
end)

hook.Add("InsaneStatsPreReforge", "InsaneStatsWPASS2", function(ent, ply)
	local addTier = ply:InsaneStats_GetEffectiveSkillValues("adamantite_forge", 2)
	if (ent.insaneStats_WPASS2NeoForged or 0) < addTier and ent.insaneStats_StartTier
	and ply:InsaneStats_EffectivelyHasSkill("adamantite_forge") then
		ent.insaneStats_StartTier = ent.insaneStats_StartTier + addTier
		ent.insaneStats_WPASS2NeoForged = addTier
	end
end)

local lastCoinCheck
local lastCoinCheck2
local coinNearestPlayer
hook.Add("InsaneStatsCoinsSpawn", "InsaneStatsWPASS2", function(victim, pos, value, valueExponent)
	if lastCoinCheck ~= engine.TickCount() or lastCoinCheck2 ~= pos then
		lastCoinCheck = engine.TickCount()
		lastCoinCheck2 = pos
		coinNearestPlayer = NULL
	end

	if not IsValid(coinNearestPlayer) then
		local coinShortestDistance = math.huge

		for i,v in player.Iterator() do
			local squaredDistance = pos:DistToSqr(v:WorldSpaceCenter())
			if squaredDistance < coinShortestDistance then
				coinNearestPlayer = v
				coinShortestDistance = squaredDistance
			end
		end
	end
		
	if (IsValid(coinNearestPlayer) and coinNearestPlayer:InsaneStats_GetEffectiveSkillValues("item_magnet", 2) <= 0) then
		coinNearestPlayer:InsaneStats_AddCoins(value)
		coinNearestPlayer:InsaneStats_SetLastCoinTier(math.Clamp(valueExponent, -1, 254))
		EmitSound("insane_stats/xylophoneaccept1.wav", pos)
		return true
	end
end)