GM.BaseSkills = {}
local skillLuaFiles, skillLuaDirs = file.Find("rotgb/gamemode/rotgb_tg_skills/*.lua", "LUA") -- FIXME: this doesn't work on client, we have to hardcode this for now

--[[local skillLuaFiles = {
	"base.lua",
	"skill_effectiveness.lua"
}]]

for k,v in pairs(skillLuaFiles) do
	AddCSLuaFile("rotgb_tg_skills/"..v)
	local skills = include("rotgb_tg_skills/"..v)
	if skills then
		table.insert(GM.BaseSkills, skills)
	else
		hook.Run("RTG_Log", "Return value of skill file \"rotgb_tg_skills/"..v.."\" was "..tostring(skills), RTG_LOGGING_ERROR)
	end
end

local color_yellow = Color(255, 255, 0)
GM.BaseTraitsText = {
	[""] = {color_white, "This perk does nothing."},
	skillEffectiveness = {color_white, "All ", color_yellow, "yellow", color_white, " skill effects are increased by ", 1, "%."},
	
	towerPrice = {color_yellow, 1, color_white, "% tower cost"},
	physgun = {color_white, "Gain the Physics Gun, which can be used to move towers, but only while there are no gBalloons on the map."},
	towerFireRate = {color_yellow, 1, color_white, "% tower fire rate"},
	towerEarlyFireRate = {color_yellow, 1, color_white, "% tower fire rate, but gradually reduces down to +0.00% after Wave 40."},
	towerAbilityD3FireRate = {color_yellow, 1, color_white, "% tower fire rate when an activated ability is triggered, for 1/3 of the cooldown duration."},
	towerMoneyFireRate = {color_yellow, 1, color_white, "% tower fire rate, multiplied by the natural logarithm of the tower's price."},
	sniperQueenFireRate = {color_yellow, 1, color_white, "% Sniper Queen fire rate"},
	allyPawnFireRate = {color_yellow, 1, color_white, "% Ally Pawn fire rate"},
	fireCubeFireRate = {color_yellow, 1, color_white, "% Fire Cube fire rate"},
	towerRange = {color_yellow, 1, color_white, "% tower range"},
	proximityMineRange = {color_yellow, 1, color_white, "% Proximity Mine range"},
	allyPawnRange = {color_yellow, 1, color_white, "% Ally Pawn range"},
	fireCubeRange = {color_yellow, 1, color_white, "% Fire Cube range"},
	electrostaticBarrelBounces = {color_yellow, 1, color_white, " Electrostatic Barrel arcs (rounded down)"},
	gatlingGunKnightSpread = {color_yellow, 1, color_white, "% Gatling Gun Knight bullet spread"},
	mortarTowerBombRadius = {color_yellow, 1, color_white, "% Mortar Tower explosion radius"},
	sawbladeLauncherPierce = {color_yellow, 1, color_white, " Sawblade Launcher pierce (rounded down)"},
	microwaveGeneratorMicrowaveAngle = {color_yellow, 1, color_white, "% Microwave Generator fire angle"},
	turretFactoryAbilityCooldown = {color_yellow, 1, color_white, "% Turret Factory generation delay"},
	pillLobberFlyTime = {color_yellow, 1, color_white, "% Pill Lobber pill travel time"},
	pillLobberExploRadius = {color_yellow, 1, color_white, "% Pill Lobber pill splash radius"},
	pillLobberDirectDamage = {color_yellow, 1, color_white, " Pill Lobber direct hit damage (rounded down)"},
	rainbowBeamerDamage = {color_yellow, 1, color_white, "% Rainbow Beamer damage (rounding up)"},
	targetDefence = {color_yellow, 1, color_white, "% gBalloon Target defence. Damage taken is divided by defence (rounding up)."},
	targetHealth = {color_yellow, 1, color_white, "% gBalloon Target health (rounded down)"},
	targetOSP = {color_white, "For ", color_yellow, 1, color_white, " times (rounded down), all fatal damage received by gBalloon Targets are negated."},
	targetRegeneration = {color_white, "All damaged gBalloon Targets gain ", color_yellow, 1, color_white, " health at the end of each wave (rounded down)."},
	hoverballFactoryHealthAmplifier = {color_yellow, 1, color_white, "% X-X-4+ Hoverball Factory health generation"},
	targetShield = {color_white, "All gBalloon Targets are shielded by ", color_yellow, 1, color_white, "% of their maximum health (rounded down). Shields fully recharge at the end of each wave."},
	targetGoldenHealth = {color_yellow, 1, color_white, " gBalloon Target golden health (rounded down)"},
	targetArmor = {color_yellow, 1, color_white, " gBalloon Target armor. Damage taken is subtracted by armor (rounding up)."},
	targetDodge = {color_yellow, 1, color_white, "% chance to completely prevent damage"},
	targetHealthEffectiveness = {color_yellow, 1, color_white, "% gBalloon Target health health effects"},
	cashFromBalloons = {color_yellow, 1, color_white, "% cash from gBalloons"},
	waveIncome = {color_yellow, 1, color_white, "% bonus cash per wave"},
	waveWaveIncome = {color_yellow, 1, color_white, " bonus cash per wave, per wave"},
	startingCash = {color_yellow, 1, color_white, " starting cash"},
	hoverballFactoryCosts = {color_yellow, 1, color_white, "% Hoverball Factory tower and upgrade costs"},
	proximityMineCosts = {color_yellow, 1, color_white, "% Proximity Mine tower and upgrade costs"},
	rainbowBeamerCosts = {color_yellow, 1, color_white, "% Rainbow Beamer tower and upgrade costs"},
	towerCosts = {color_yellow, 1, color_white, "% tower and upgrade costs"},
	microwaveGeneratorCosts = {color_yellow, 1, color_white, "% Microwave Generator tower and upgrade costs"},
	towerIncome = {color_yellow, 1, color_white, "% tower cash generation"},
	allyPawnFirstFree = {color_white, "The first Ally Pawn placed by one player is absolutely free."},
	hoverballFactoryIncome = {color_yellow, 1, color_white, "% Hoverball Factory cash generation"},
	gBlimpOuterHealthCash = {color_white, "All spawned gBlimps' outermost layer yields extra cash when popped, equal to ", color_yellow, 1, color_white, "% of the outer layer's health."},
	bishopOfGlueFireRate = {color_yellow, 1, color_white, "% Bishop of Glue fire rate"},
	orbOfColdSpeedPercent = {color_yellow, 1, color_white, "% gBalloon speed after frozen by Orbs Of Cold, for 3 seconds"},
	gBalloonMissingProperty = {color_yellow, 1, color_white, "% chance for gBalloons to be missing Fast, Hidden, Regen or Shielded properties"},
	gBalloonSpeed = {color_yellow, 1, color_white, "% gBalloon speed"},
	gBalloonFastSpeed = {color_yellow, 1, color_white, "% Fast gBalloon speed modifier"},
	gBalloonRegenRate = {color_yellow, 1, color_white, "% Regen gBalloon regeneration rate"},
	gBlimpSpeed = {color_yellow, 1, color_white, "% gBlimp speed"},
	gBalloonOuterArmor = {color_white, "All spawned gBalloons' outermost layer has ", color_yellow, 1, color_white, " armor (rounding up)."},
	gBlimpOuterHealth = {color_yellow, 1, color_white, "% gBlimp outermost layer health (rounded down)"},
	gBalloonErrorExplosionUnimmune = {color_white, "Error gBalloons are no longer immune to explosions."},
	gBlimpArmoredArmor = {color_yellow, 1, color_white, " armor on armored gBlimps (rounding up)"},
	gBalloonFireGeneric = {color_white, "Purple gBalloons and Rainbow gBlimps are no longer immune to fire."},
	gBalloonCritChance = {color_yellow, 1, color_white, "% chance to deal double damage"},
	--targetRevenge = {color_yellow, 1, color_white, " damage dealt (rounded down) to all gBalloons whenever any gBalloon Target takes damage."},
}

GM.AppliedSkills = {}

--[[ TODO: skill ideas
health reduction (gBalloons)
speed reduction (gBalloons)
armor reduction (gBalloons)
resistance reduction (gBalloons)
[chance for] missing attribute (gBalloons)
chance to block for each damage point taken (targets)
max health (targets)
shield (targets)
@towers [on certain upgrades] [with certain targeting] [when damage is taken] [increased by damage taken]
fire rate (towers)
damage (towers)
upgrade restriction reduction (towers)
cost reduction (cash<towers)
starting cash (cash)
cash gain [from [gBlimp] pops|from gBlimp hits] [from towers] (cash)
start with pistol (meta)
start with rocket launcher (meta)
start with physgun (meta)
skill effectiveness (meta)
experience gain [from gBlimps] [in freeplay] (meta)
]]

AccessorFunc(GM, "CachedSkillAmounts", "CachedSkillAmounts")
AccessorFunc(GM, "SkillNames", "SkillNames")
AccessorFunc(GM, "Skills", "Skills")
AccessorFunc(GM, "TraitsText", "TraitsText")

function GM:RebuildSkills()
	hook.Run("RTG_Log", "Building skill web...", RTG_LOGGING_INFO)
	local buildTime = SysTime()
	local links = 0
	hook.Run("SetSkills", {})
	hook.Run("SetSkillNames", {})
	local unprocessedSkills = {}
	for k,v in pairs(self.BaseSkills) do
		unprocessedSkills[k] = v
	end
	hook.Run("ROTGB:TG_GatherCustomSkills", unprocessedSkills)
	for k,v in pairs(unprocessedSkills) do
		hook.Run("CompileSkillTable", v)
	end
	-- yes, we have to loop *again*
	local skills = hook.Run("GetSkills")
	for k,v in pairs(skills) do
		if v.parent then
			local lookupName = v.parent
			local parentID = hook.Run("GetSkillNames")[lookupName]
			if parentID then
				v.parent = parentID
			else
				hook.Run("RTG_Log", "Unknown parent skill \""..tostring(lookupName).."\" in skill \""..tostring(v.ref).."\"!", RTG_LOGGING_ERROR)
			end
		end
		if v.links == "parent" then
			v.links = {[v.parent]=true}
		else -- table of refs
			local newLinks = {}
			for k2,v2 in pairs(v.links) do
				local skillID = hook.Run("GetSkillNames")[v2]
				if skillID then
					newLinks[skillID] = true
					links = links + 1
				else
					hook.Run("RTG_Log", "Unknown linked skill \""..tostring(v2).."\" in skill \""..tostring(v.ref).."\"!", RTG_LOGGING_ERROR)
				end
			end
			v.links = newLinks
		end
		for k2,v2 in pairs(v.links) do
			if (skills[k2] and not skills[k2].links[k]) then
				skills[k2].links[k] = true
				links = links + 1
			end
		end
	end
	local skillsText = {}
	for k,v in pairs(self.BaseTraitsText) do
		skillsText[k] = v
	end
	hook.Run("ROTGB:TG_GatherCustomTraitsText", skillsText)
	hook.Run("SetTraitsText", skillsText)
	--PrintTable(hook.Run("GetSkills"))
	hook.Run("RTG_Log", string.format("Finished building skill web in %.2f mcs.", (SysTime()-buildTime)*1e6), RTG_LOGGING_INFO)
	hook.Run("RTG_Log", string.format("Nodes: %i, Links: %i", #skills, links/2), RTG_LOGGING_INFO)
end

function GM:CompileSkillTable(unprocessedSkill)
	if istable(unprocessedSkill) then
		local skillTable = {}
		local currentSkills = hook.Run("GetSkills")
		local skillNum = #currentSkills+1
		local skillNames = hook.Run("GetSkillNames")
		for k,v in pairs(unprocessedSkill) do
			if k == "ref" then
				if skillNames[v] then
					hook.Run("RTG_Log", "Replacing a skill with a duplicate identifier \""..tostring(v).."\"!", RTG_LOGGING_ERROR)
				end
				skillNames[v] = skillNum
			end
			skillTable[k] = v
		end
		if skillTable.ref then
			if not skillTable.tier then
				skillTable.tier = 0
			end
			if not skillTable.ang then
				skillTable.ang = 0
			end
			if not skillTable.pos then
				skillTable.pos = VectorTable(0,0)
			else
				skillTable.pos[2] = -skillTable.pos[2]
			end
			if not skillTable.links then
				skillTable.links = {}
			end
			hook.Run("GetSkills")[skillNum] = skillTable
		else -- recursive structure
			for k,v in pairs(skillTable) do
				hook.Run("CompileSkillTable", v)
			end
		end
	else
		hook.Run("RTG_Log", "\""..tostring(unprocessedSkill).."\" is not a skill table!", RTG_LOGGING_ERROR)
	end
end

function GM:GatherCustomSkills(skills)
	-- skills can be added here, ideally through a hook (hook.Add("GatherCustomSkills", ...))
end

function GM:CreateSkillAmountsCache(extraTrait)
	local appliedSkills = hook.Run("GetAppliedSkills")
	local skills = hook.Run("GetSkills")
	local traits = {}
	for k,v in pairs(appliedSkills) do
		local skill = skills[k]
		if istable(skill.trait) then
			for k,v in pairs(skill.trait) do
				traits[v] = (traits[v] or 0) + skill.amount[k]
			end
		else
			traits[skill.trait] = (traits[skill.trait] or 0) + skill.amount
		end
	end
	if not traits[extraTrait] then
		traits[extraTrait] = 0
	end
	for k,v in pairs(traits) do
		if k ~= "skillEffectiveness" then
			traits[k] = v*(1+(traits.skillEffectiveness or 0)/100)
		end
	end
	hook.Run("SetCachedSkillAmounts", traits)
end

function GM:GetSkillAmount(trait)
	local cachedSkillTraits = hook.Run("GetCachedSkillAmounts")
	if not cachedSkillTraits[trait] then
		hook.Run("CreateSkillAmountsCache", trait)
		cachedSkillTraits = hook.Run("GetCachedSkillAmounts")
	end
	
	return cachedSkillTraits[trait]
end

function GM:AddAppliedSkills(skills)
	hook.Run("SetAppliedSkills", table.Merge(skills, hook.Run("GetAppliedSkills")))
end

function GM:ClearAppliedSkills(skills)
	table.Empty(self.AppliedSkills)
	table.Empty(hook.Run("GetCachedSkillAmounts"))
end

function GM:SetAppliedSkills(skills)
	self.AppliedSkills = skills
	table.Empty(hook.Run("GetCachedSkillAmounts"))
end

function GM:GetAppliedSkills()
	return self.AppliedSkills or {}
end

function GM:IsAppliedSkill(skillName)
	return hook.Run("GetAppliedSkills")[hook.Run("GetSkillNames")[skillName]]
end

-- defined in rotgb_general.lua
function GM:RotgBScaleBuyCost(num,ent,data)
	local newAmount = num * (1 + (ROTGB_GetConVarValue("rotgb_difficulty") - 1)/5)
	local typ = data.type
	if typ == ROTGB_TOWER_PURCHASE or typ == ROTGB_TOWER_UPGRADE then
		newAmount = newAmount * (1+hook.Run("GetSkillAmount", "towerCosts")/100)
		local class = ent.GetClass and ent:GetClass() or ent.ClassName
		
		if class == "gballoon_tower_02" then
			newAmount = newAmount * (1+hook.Run("GetSkillAmount", "proximityMineCosts")/100)
		elseif class == "gballoon_tower_08" then
			newAmount = newAmount * (1+hook.Run("GetSkillAmount", "rainbowBeamerCosts")/100)
		elseif class == "gballoon_tower_14" then
			newAmount = newAmount * (1+hook.Run("GetSkillAmount", "microwaveGeneratorCosts")/100)
		elseif class == "gballoon_tower_16" then
			newAmount = newAmount * (1+hook.Run("GetSkillAmount", "hoverballFactoryCosts")/100)
		end
	end
	return newAmount
end

-- defined in gballoon_target.lua
function GM:gBalloonTargetHealthAdjust(ent, health)
	ent:SetGoldenHealth(hook.Run("GetSkillAmount", "targetGoldenHealth"))
	ent:SetPerWaveShieldPercent(hook.Run("GetSkillAmount", "targetShield"))
	ent:SetOSPs(hook.Run("GetSkillAmount", "targetOSP"))
	local newHealth = health * (1+hook.Run("GetSkillAmount", "targetHealth")/100*(1+hook.Run("GetSkillAmount", "targetHealthEffectiveness")/100))
	ent:SetPerWaveShield(newHealth*ent:GetPerWaveShieldPercent()/100)
	return newHealth
end

-- defined in gballoon_tower_base.lua
function GM:RotgBTowerPlaced(tower)
	local maxWave = 0
	for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
		maxWave = math.max(maxWave, v:GetWave())
	end
	tower.MaxWaveReached = maxWave
end

local PLAYER = FindMetaTable("Player")

local experienceNeeded = {
	100, 250, 500, 1000
}
local function getExperienceNeeded(currentLevel)
	currentLevel = math.floor(currentLevel)
	if currentLevel < 1 then return 0
	--elseif currentLevel >= 999 then return math.huge
	elseif experienceNeeded[currentLevel] then return experienceNeeded[currentLevel]
	else
		local n = currentLevel-4
		return 500*(n*n+n+2)
	end
end
local function getLevel(currentExperience)
	local experienceNeededLength = #experienceNeeded
	if currentExperience < experienceNeeded[experienceNeededLength] then
		local level = 1
		for i,v in ipairs(experienceNeeded) do
			if v > currentExperience then break end
			level = i+1
		end
		return level
	else
		return math.floor(4.5 + math.sqrt(currentExperience/500 - 1.75))
	end
end

function PLAYER:RTG_GetLevel()
	self.rtg_Level = self.rtg_Level or 1
	if getExperienceNeeded(self.rtg_Level) <= self:RTG_GetExperience() then
		self:RTG_UpdateLevel()
	end
	return self.rtg_Level
end

function PLAYER:RTG_GetLevelFraction()
	-- 1.797693134e+308
	if getExperienceNeeded(self:RTG_GetLevel()) < math.huge then
		return math.Remap(self:RTG_GetExperience(), getExperienceNeeded(self:RTG_GetLevel()-1), getExperienceNeeded(self:RTG_GetLevel()), 0, 1)
	elseif self:RTG_GetExperience() < math.huge then
		return math.Remap(self:RTG_GetExperience(), getExperienceNeeded(self:RTG_GetLevel()-1), 1.797693134e+308, 0, 1)
	else return 1
	end
end

function PLAYER:RTG_GetExperience()
	-- experience is stored clientside, so it's impossible to completely prevent clients from modifying their experience value
	-- especially with open source code, it's better to just not bother about it rather then losing sleep over it
	return (self.rtg_PreviousXP or 0) + self.rtg_XP
end

function PLAYER:RTG_GetExperienceNeeded()
	return getExperienceNeeded(self:RTG_GetLevel())
end

function PLAYER:RTG_UpdateLevel()
	self.rtg_Level = getLevel(self:RTG_GetExperience())
end

function PLAYER:RTG_ClearSkills()
	table.Empty(self.rtg_Skills)
	self.rtg_SkillAmount = 0
	hook.Run("PlayerClearSkills", self)
end

function PLAYER:RTG_AddSkills(skillIDs)
	for k,v in pairs(skillIDs) do
		self.rtg_Skills[k] = v
	end
	self.rtg_SkillAmount = table.Count(self.rtg_Skills)
	hook.Run("PlayerAddSkills", self, skillIDs)
end

function PLAYER:RTG_GetSkillAmount()
	return self.rtg_SkillAmount
end

function PLAYER:RTG_GetSkills()
	return self.rtg_Skills
end

function PLAYER:RTG_HasSkill(skillID)
	return self.rtg_Skills[skillID] or false
end

function PLAYER:RTG_SkillUnlocked(skillID, skills)
	skills = skills or hook.Run("GetSkills")
	for k,v in pairs(skills[skillID].links) do
		if self:RTG_HasSkill(k) then return true end
	end
	return skills[skillID].alwaysUnlocked
end

local cachedTowers
function PLAYER:RTG_GetSkillPoints()
	if not cachedTowers then
		cachedTowers = ROTGB_GetAllTowers()
	end
	return math.min(self:RTG_GetLevel(), 999) - self:RTG_GetSkillAmount() - #cachedTowers
end