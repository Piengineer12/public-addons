function GM:ReadSkillMessage(ply)
	local amount = net.ReadUInt(2)
	if amount == RTG_SKILL_CLEAR then
		ply:RTG_ClearSkills()
	else
		if amount == RTG_SKILL_ONE then
			amount = 1
		elseif amount == RTG_SKILL_MULTIPLE then
			amount = net.ReadUInt(12)+1 -- max is 4,096
		end
		if amount <= ply:RTG_GetSkillPoints() then
			local skills = {}
			for i=1,amount do
				local skill = net.ReadUInt(12)+1
				if hook.Run("GetSkills")[skill] and not ply:RTG_HasSkill(skill) then
					skills[skill] = true
				end
			end
			if next(skills) then
				ply:RTG_AddSkills(skills)
			end
		end
	end
end

function GM:PlayerAddSkills(ply, skillIDs)
	--[[local appliedSkills = hook.Run("GetAppliedSkills")
	local appliedSkillsToAdd = {}
	for k,v in pairs(skillIDs) do
		if not appliedSkills[k] then
			appliedSkillsToAdd[k] = v
		end
	end
	hook.Run("AddAppliedSkills", appliedSkillsToAdd)]]
	
	net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_SKILLS, 4)
	net.WriteBool(true)
	if next(skillIDs, next(skillIDs)) then
		net.WriteUInt(RTG_SKILL_MULTIPLE, 2)
		net.WriteUInt(table.Count(skillIDs)-1, 12)
		for k,v in pairs(skillIDs) do
			net.WriteUInt(k-1, 12)
		end
	else
		net.WriteUInt(RTG_SKILL_ONE, 2)
		net.WriteUInt(next(skillIDs)-1, 12)
	end
	net.Send(ply)
	
	--[[local nextKey = next(appliedSkillsToAdd)
	if nextKey then
		net.Start("rotgb_gamemode")
		net.WriteUInt(RTG_OPERATION_SKILLS, 4)
		net.WriteBool(false)
		if next(appliedSkillsToAdd, nextKey) then
			net.WriteUInt(RTG_SKILL_MULTIPLE, 2)
			net.WriteUInt(table.Count(appliedSkillsToAdd)-1, 12)
			for k,v in pairs(appliedSkillsToAdd) do
				net.WriteUInt(k-1, 12)
			end
		else
			net.WriteUInt(RTG_SKILL_ONE, 2)
			net.WriteUInt(nextKey-1, 12)
		end
		net.Broadcast()
	end]]
end

function GM:PlayerClearSkills(ply)
	--[[local appliedSkills = {}
	local plys = player.GetAll()
	for k,v in pairs(hook.Run("GetSkills")) do
		for k2,v2 in pairs(plys) do
			if v2:RTG_HasSkill(k) then
				appliedSkills[k] = true break
			end
		end
	end
	hook.Run("SetAppliedSkills", appliedSkills)]]
	
	net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_SKILLS, 4)
	net.WriteBool(true)
	net.WriteUInt(RTG_SKILL_CLEAR, 2)
	net.Send(ply)
	
	--[[net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_SKILLS, 4)
	net.WriteBool(false)
	if next(appliedSkills) then
		net.WriteUInt(RTG_SKILL_MULTIPLE, 2)
		net.WriteUInt(table.Count(appliedSkills)-1, 12)
		for k,v in pairs(appliedSkills) do
			net.WriteUInt(k-1, 12)
		end
	else
		net.WriteUInt(RTG_SKILL_CLEAR, 2)
	end
	net.Broadcast()]]
end

function GM:UpdateAppliedSkills()
	local appliedSkills = {}
	local plys = player.GetAll()
	for k,v in pairs(hook.Run("GetSkills")) do
		for k2,v2 in pairs(plys) do
			if v2:RTG_HasSkill(k) then
				appliedSkills[k] = true break
			end
		end
	end
	hook.Run("SetAppliedSkills", appliedSkills)
	
	net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_SKILLS, 4)
	net.WriteBool(false)
	if next(appliedSkills) then
		net.WriteUInt(RTG_SKILL_MULTIPLE, 2)
		net.WriteUInt(table.Count(appliedSkills)-1, 12)
		for k,v in pairs(appliedSkills) do
			net.WriteUInt(k-1, 12)
		end
	else
		net.WriteUInt(RTG_SKILL_CLEAR, 2)
	end
	net.Broadcast()
end

-- defined in rotgb_general.lua
function GM:GetStartingRotgBCash()
	return ROTGB_GetConVarValue("rotgb_starting_cash") + hook.Run("GetSkillAmount", "startingCash")
end

-- defined in gballoon_spawner.lua
function GM:gBalloonSpawnerPostSpawn(spawner, bln, keyValues)
	if bln:GetBalloonProperty("BalloonBlimp") then
		local cashBonus = bln:GetBalloonProperty("BalloonCashBonus") + bln:GetMaxHealth() * hook.Run("GetSkillAmount", "gBlimpOuterHealthCash")/100
		bln:SetBalloonProperty("BalloonCashBonus", cashBonus)
		bln:SetHealth(bln:GetMaxHealth()*(1+hook.Run("GetSkillAmount", "gBlimpOuterHealth")/100))
	end
	if hook.Run("GetSkillAmount", "gBalloonMissingProperty") > 0 then
		local missingPropertyChance = hook.Run("GetSkillAmount", "gBalloonMissingProperty")/100
		local missingFast = bln:GetBalloonProperty("BalloonFast") and math.random() < missingPropertyChance
		local missingHidden = bln:GetBalloonProperty("BalloonHidden") and math.random() < missingPropertyChance
		local missingRegen = bln:GetBalloonProperty("BalloonRegen") and math.random() < missingPropertyChance
		local missingShielded = bln:GetBalloonProperty("BalloonShielded") and math.random() < missingPropertyChance
		if missingFast then
			bln:SetBalloonProperty("BalloonFast", false)
		end
		if missingHidden then
			bln:SetBalloonProperty("BalloonHidden", false)
		end
		if missingRegen then
			bln:SetBalloonProperty("BalloonRegen", false)
		end
		if missingShielded then
			bln:SetBalloonProperty("BalloonShielded", false)
		end
	end
	bln:SetBalloonProperty("BalloonArmor", (bln:GetBalloonProperty("BalloonArmor") or 0)+math.ceil(hook.Run("GetSkillAmount", "gBalloonOuterArmor")))
	hook.Run("SetPreventPlayerPhysgun", true)
end
function GM:gBalloonSpawnerWaveStarted(spawner, cwave)
	local maxWave = cwave
	for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
		maxWave = math.max(maxWave, v:GetWave()-1)
	end
	hook.Run("SetMaxWaveReached", maxWave)
end

-- defined in gballoon_target.lua
function GM:gballoonTargetTakeDamage(target, dmginfo)
	dmginfo:SubtractDamage(hook.Run("GetSkillAmount", "targetArmor"))
	if dmginfo:GetDamage() < 0 then
		dmginfo:SetDamage(0)
	end
	dmginfo:ScaleDamage(1/(1+hook.Run("GetSkillAmount", "targetDefence")/100))
	if math.random() < hook.Run("GetSkillAmount", "targetDodge")/100 then
		dmginfo:SetDamage(0)
	end
end
function GM:PostgballoonTargetTakeDamage(target, dmginfo)
	if hook.Run("GetSkillAmount", "targetRevenge") > 0 then
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker(target)
		dmginfo:SetInflictor(target)
		dmginfo:SetDamage(math.floor(hook.Run("GetSkillAmount", "targetRevenge"))*10)
		dmginfo:SetDamageType(DMG_GENERIC)
		dmginfo:SetReportedPosition(target:GetPos())
		
		for k,v in pairs(ROTGB_GetBalloons()) do
			dmginfo:SetDamagePosition(v:GetPos())
			v:TakeDamageInfo(dmginfo)
		end
	end
end

-- defined in gballoon_base.lua
function GM:gBalloonPostInitialize(bln)
	local slowDown = 1+hook.Run("GetSkillAmount", "gBalloonSpeed")/100
	if bln:GetBalloonProperty("BalloonBlimp") then
		slowDown = slowDown * (1+hook.Run("GetSkillAmount", "gBlimpSpeed")/100)
	end
	bln:Slowdown("gBalloonSpeedSkill", slowDown, 9999)
	if bln:GetBalloonProperty("BalloonFast") then	
		bln:Slowdown("BalloonFast", 2+hook.Run("GetSkillAmount", "gBalloonFastSpeed")/100, 9999)
	end
	if hook.Run("GetSkillAmount", "gBalloonDoubleSpeed") > 0 then
		bln:Slowdown("gBalloonDoubleSpeedSkill", 2, 9999)
	end
end
function GM:gBalloonKeyValuesApply(keyValues)
	if keyValues.BalloonType == "gballoon_error" and hook.Run("GetSkillAmount", "gBalloonErrorExplosionUnimmune") > 0 then
		keyValues.BalloonBlack = "0"
	end
	if tobool(keyValues.BalloonBlimp) then
		local newHealth = (tonumber(keyValues.BalloonHealth) or 1) * (1+hook.Run("GetSkillAmount", "gBlimpHealth")/100)
		keyValues.BalloonHealth = string.format("%i", math.ceil(newHealth))
		if (tonumber(keyValues.BalloonArmor) or 0) > 0 then
			local newArmor = tonumber(keyValues.BalloonArmor) + hook.Run("GetSkillAmount", "gBlimpArmoredArmor")
			keyValues.BalloonArmor = string.format("%i", math.ceil(newArmor))
		end
	end
end
function GM:gBalloonTakeDamage(bln, dmginfo)
	if math.random()*100 < hook.Run("GetSkillAmount", "gBalloonCritChance") then
		dmginfo:ScaleDamage(2)
	end
	if hook.Run("GetSkillAmount", "gBalloonFireGeneric") > 0 then
		local exclude = bit.bor(DMG_BURN,DMG_SLOWBURN,DMG_DIRECT)
		local newFlags = bit.band(dmginfo:GetDamageType(), bit.bnot(exclude))
		dmginfo:SetDamageType(newFlags)
	end
	local isFatal = math.ceil(dmginfo:GetDamage()/10*ROTGB_GetConVarValue("rotgb_damage_multiplier"))>=bln:Health()
	if isFatal and not bln:GetBalloonProperty("BalloonBoss") and bln:DamageTypeCanDamage(dmginfo:GetDamageType()) and math.random()*100 < hook.Run("GetSkillAmount", "gBalloonChildrenSuppressChance") then
		dmginfo:SetDamage(bln:GetRgBE() * 1000)
		dmginfo:SetDamageType(DMG_GENERIC)
	end
end
function GM:GetgBalloonRegenDelay(bln)
	return ROTGB_GetConVarValue("rotgb_regen_delay") / (1+hook.Run("GetSkillAmount", "gBalloonRegenRate")/100)
end
function GM:GetgBalloonHealth(typ, health)
	return health * (hook.Run("GetSkillAmount", "gBalloonDoubleHealth") > 0 and 2 or 1)
end