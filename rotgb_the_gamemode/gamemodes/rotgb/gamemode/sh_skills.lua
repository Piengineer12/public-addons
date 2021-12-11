GM.BaseSkills = {
	{
		ref = "physgun",
		name = "Physics Gun",
		trait = "physgun",
		amount = 1,
		tier = 2,
		alwaysUnlocked = true
	},
	{
		{
			{
				ref = "fr1",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "physgun",
				links = "parent",
				pos = VectorTable(4,4),
			},
			{
				ref = "fr2",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr1",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "fr3",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr1",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "fr4",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr2",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "fr5",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr3",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "fr6",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr4",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "fr7",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr5",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "fr8",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr6",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "fr9",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr7",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "fr10",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr8",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "fr11",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr9",
				links = "parent",
				pos = VectorTable(1,1),
			},
		},
		{
			{
				ref = "fr12",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr6",
				links = {"fr6","fr7"},
				pos = VectorTable(1,0),
			},
			{
				ref = "extraBatteries",
				name = "Extra Batteries",
				trait = "electrostaticBarrelBounces",
				amount = 1,
				tier = 1,
				parent = "fr12",
				links = "parent",
				pos = VectorTable(-1,-1),
			}
		},
		{
			{
				ref = "fastCaliberTechnique",
				name = "Fast Caliber Technique",
				trait = "sniperQueenFireRate",
				amount = 15,
				tier = 1,
				parent = "fr10",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "bigBombs",
				name = "Bigger Bombs",
				trait = "mortarTowerBombRadius",
				amount = 25,
				tier = 1,
				parent = "fr11",
				links = {"fr11", "fastCaliberTechnique"},
				pos = VectorTable(1,1),
			}
		},
		{
			{
				ref = "range1",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "fastCaliberTechnique",
				links = "parent",
				pos = VectorTable(-1,1),
			},
			{
				ref = "range3",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range1",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "range5",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range3",
				links = "parent",
				pos = VectorTable(-1,1),
			},
			{
				ref = "range2",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "bigBombs",
				links = "parent",
				pos = VectorTable(1,-1),
			},
			{
				ref = "range4",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range2",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "range6",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range4",
				links = "parent",
				pos = VectorTable(1,-1),
			}
		},
		{
			{
				ref = "biggerMines",
				name = "Bigger Mines",
				trait = "proximityMineRange",
				amount = 25,
				tier = 1,
				parent = "range5",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "betterGattlerDesign",
				name = "Better Gattler Design",
				trait = "gatlingGunKnightSpread",
				amount = -15,
				tier = 1,
				parent = "range6",
				links = "parent",
				pos = VectorTable(1,0),
			}
		},
		{
			{
				ref = "range7",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "biggerMines",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "range9",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range7",
				links = "parent",
				pos = VectorTable(1,-1),
			},
			{
				ref = "range11",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range9",
				links = "parent",
				pos = VectorTable(1,-1),
			},
			{
				ref = "range8",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "betterGattlerDesign",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "range10",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range8",
				links = "parent",
				pos = VectorTable(-1,1),
			},
			{
				ref = "range12",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range10",
				links = "parent",
				pos = VectorTable(-1,1),
			}
		},
		{
			{
				ref = "strongerSawblades",
				name = "Stronger Sawblades",
				trait = "sawbladeLauncherPierce",
				amount = 1,
				tier = 1,
				parent = "range11",
				links = "parent",
				pos = VectorTable(0,-1),
			},
			{
				ref = "pyroTraining",
				name = "Pyro Training",
				trait = {"fireCubeFireRate", "fireCubeRange"},
				amount = {10, 15},
				tier = 1,
				parent = "range12",
				links = "parent",
				pos = VectorTable(-1,0),
			}
		},
		{
			{
				ref = "motivation1",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "range11",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "motivation2",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "motivation1",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "motivation3",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "motivation2",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "motivation4",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "motivation3",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "motivation5",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "motivation4",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "motivation6",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "motivation5",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "motivation7",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "motivation6",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "motivation8",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "motivation7",
				links = "parent",
				pos = VectorTable(1,1),
			},
		},
		{
			{
				ref = "warHorn1",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "strongerSawblades",
				links = {"strongerSawblades", "pyroTraining"},
				pos = VectorTable(1,0),
			},
			{
				ref = "warHorn2",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "warHorn1",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "warHorn3",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "warHorn2",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "warHorn4",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "warHorn3",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "warHorn5",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "warHorn4",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "warHorn6",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "warHorn5",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "warHorn7",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "warHorn6",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "warHorn8",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "warHorn7",
				links = "parent",
				pos = VectorTable(1,1),
			},
		},
		{
			{
				ref = "mip1",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "range12",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "mip2",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "mip1",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "mip3",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "mip2",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "mip4",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "mip3",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "mip5",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "mip4",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "mip6",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "mip5",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "mip7",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "mip6",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "mip8",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "mip7",
				links = "parent",
				pos = VectorTable(1,1),
			},
		},
		{
			{
				ref = "betterDiffraction",
				name = "Better Diffraction",
				trait = "microwaveGeneratorMicrowaveAngle",
				amount = 25,
				tier = 1,
				parent = "motivation8",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "fasterAssembly",
				name = "Faster Assembly",
				trait = "turretFactoryAbilityCooldown",
				amount = -15,
				tier = 1,
				parent = "warHorn8",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "aerodynamicPills",
				name = "Aerodynamic Pills",
				trait = {"pillLobberFlyTime", "pillLobberExploRadius"},
				amount = {-25, 15},
				tier = 1,
				parent = "mip8",
				links = "parent",
				pos = VectorTable(0,1),
			}
		},
		{
			ref = "twoHanded100",
			name = "Two-Handed 100",
			trait = "allyPawnTargets",
			amount = 100,
			tier = 2,
			parent = "betterDiffraction",
			links = {"betterDiffraction", "fasterAssembly", "aerodynamicPills"},
			pos = VectorTable(1,0)
		},
	},
	{
		ref = "tc1",
		name = "Tower Discount",
		trait = "towerPrice",
		amount = -2,
		parent = "physgun",
		links = "parent",
		pos = VectorTable(4,4),
		ang = 90
	},
	{
		ref = "mhp1",
		name = "Maximum Health",
		trait = "targetMaximumHealth",
		amount = 2,
		parent = "physgun",
		links = "parent",
		pos = VectorTable(4,4),
		ang = 180
	},
	{
		ref = "gbs1",
		name = "gBalloon Sabotage",
		trait = "gBalloonSpeed",
		amount = -1,
		parent = "physgun",
		links = "parent",
		pos = VectorTable(4,4),
		ang = 270
	}
}
GM.BaseTraitsText = {
	physgun = "Gain the Physics Gun, which can be used to move towers while there are no gBalloons on the map.",
	towerFireRate = "{0}% tower fire rate",
	towerEarlyFireRate = "{0}% tower fire rate, but gradually reduces down to +0.00% after Wave 40",
	towerAbilityD3FireRate = "When an activated ability is triggered, all towers fire {0}% faster for 1/3 of the cooldown duration",
	towerMoneyFireRate = "{0}% tower fire rate, multiplied by the natural logarithm of the tower's price",
	sniperQueenFireRate = "{0}% Sniper Queen fire rate",
	allyPawnFireRate = "{0}% Ally Pawn fire rate",
	--bishopOfGlueFireRate = "{0}% Bishop of Glue fire rate",
	fireCubeFireRate = "{0}% Fire Cube fire rate",
	towerRange = "{0}% tower range",
	proximityMineRange = "{0}% Proximity Mine range",
	allyPawnRange = "{0}% Ally Pawn range",
	fireCubeRange = "{0}% Fire Cube range",
	towerPrice = "{0}% tower cost",
	electrostaticBarrelBounces = "{0} Electrostatic Barrel arcs (rounded down)",
	gatlingGunKnightSpread = "{0}% Gatling Gun Knight bullet spread",
	--orbOfColdSpeedPercent = "gBalloons frozen by Orb Of Cold get {0}% speed for 3 seconds",
	mortarTowerBombRadius = "{0}% Mortar Tower explosion radius",
	targetMaximumHealth = "gBalloon Targets start with {0}% more health (rounded down)",
	gBalloonSpeed = "{0}% gBalloon speed",
	sawbladeLauncherPierce = "{0} Sawblade Launcher pierce (rounded down)",
	microwaveGeneratorMicrowaveAngle = "{0}% Microwave Generator fire angle",
	turretFactoryAbilityCooldown = "{0}% Turret Factory generation delay",
	pillLobberFlyTime = "{0}% Pill Lobber pill travel time",
	pillLobberExploRadius = "{0}% Pill Lobber pill splash radius",
	allyPawnTargets = "{0}% Ally Pawn targets (rounded down)",
}

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
			v.parent = hook.Run("GetSkillNames")[lookupName]
			if not v.parent then
				error("Untranslatable skill name: "..tostring(lookupName))
			end
		end
		if v.links == "parent" then
			v.links = {[v.parent]=true}
		else -- table of refs
			local newLinks = {}
			for k,v in pairs(v.links) do
				local skillID = hook.Run("GetSkillNames")[v]
				if skillID then
					newLinks[skillID] = true
				else
					error("Untranslatable skill name: "..tostring(v))
				end
			end
			v.links = newLinks
		end
		for k2,v2 in pairs(v.links) do
			skills[k2].links[k] = true
		end
	end
	local skillsText = {}
	for k,v in pairs(self.BaseTraitsText) do
		skillsText[k] = v
	end
	hook.Run("ROTGB:TG_GatherCustomTraitsText", skillsText)
	hook.Run("SetTraitsText", skillsText)
	--PrintTable(hook.Run("GetSkills"))
end

function GM:CompileSkillTable(unprocessedSkill)
	local skillTable = {}
	local currentSkills = hook.Run("GetSkills")
	local skillNum = #currentSkills+1
	for k,v in pairs(unprocessedSkill) do
		if k == "ref" then
			hook.Run("GetSkillNames")[v] = skillNum
			skillTable.ref = skillNum
		else
			skillTable[k] = v
		end
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

local PLAYER = FindMetaTable("Player")

local experienceNeeded = {
	100, 250, 500, 1e3, 2e3,
	4e3, 7.5e3, 13.5e3, 23e3, 38e3
}
local function getExperienceNeeded(currentLevel)
	currentLevel = math.floor(currentLevel)
	if currentLevel < 1 then return 0
	elseif experienceNeeded[currentLevel] then return experienceNeeded[currentLevel]
	else
		local n = currentLevel-8.7
		return 5e3*(n*n+n+4.61)
	end
end

function PLAYER:RTG_GetLevel()
	if getExperienceNeeded(self.rtg_Level) <= self:RTG_GetExperience() then
		self:RTG_UpdateLevel()
	end
	return self.rtg_Level
end

function PLAYER:RTG_GetLevelFraction()
	return math.Remap(self:RTG_GetExperience(), getExperienceNeeded(self:RTG_GetLevel()-1), getExperienceNeeded(self:RTG_GetLevel()), 0, 1)
end

function PLAYER:RTG_GetExperience()
	-- experience is stored clientside, so it's impossible to completely prevent clients from modifying their experience value
	-- especially with open source code, it's better to not bother about it
	return (self.rtg_PreviousXP or 0) + self.rtg_XP
end

function PLAYER:RTG_GetExperienceNeeded()
	return getExperienceNeeded(self:RTG_GetLevel())
end

function PLAYER:RTG_UpdateLevel()
	while getExperienceNeeded(self.rtg_Level) <= self:RTG_GetExperience() do
		self.rtg_Level = self.rtg_Level + 1
	end
end

function PLAYER:RTG_ClearSkills()
	table.Empty(self.rtg_Skills)
	self.rtg_SkillAmount = 0
	hook.Run("PlayerClearSkills", self, cleared)
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
	return self:RTG_GetLevel() - self:RTG_GetSkillAmount() - #cachedTowers
end