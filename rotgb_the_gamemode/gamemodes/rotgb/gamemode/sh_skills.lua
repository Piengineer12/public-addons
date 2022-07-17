GM.BaseSkills = {}
local skillLuaFiles, skillLuaDirs = file.Find("rotgb/gamemode/rotgb_tg_skills/*.lua", "LUA")

for k,v in pairs(skillLuaFiles) do
	AddCSLuaFile("rotgb_tg_skills/"..v)
	local skills = include("rotgb_tg_skills/"..v)
	if skills then
		table.insert(GM.BaseSkills, skills)
	else
		hook.Run("RTG_Log", "Return value of skill file \"rotgb_tg_skills/"..v.."\" was "..tostring(skills), RTG_LOGGING_ERROR)
	end
end

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
				if v2 == true then
					newLinks[k2] = true
				else
					local skillID = hook.Run("GetSkillNames")[v2]
					if skillID then
						newLinks[skillID] = true
						links = links + 1
					else
						hook.Run("RTG_Log", "Unknown linked skill \""..tostring(v2).."\" in skill \""..tostring(v.ref).."\"!", RTG_LOGGING_ERROR)
					end
				end
			end
			v.links = newLinks
		end
		for k2,v2 in pairs(v.links) do
			if skills[k2] then
				if not skills[k2].links[k] then
					skills[k2].links[k] = true
					links = links + 1
				end
			else
				hook.Run("RTG_Log", "Skill link to #"..tostring(k2).." in skill \""..tostring(v.ref).."\" established, but linked skill is missing?!", RTG_LOGGING_ERROR)
			end
		end
	end
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
			if skillTable.pos then
				skillTable.pos = VectorTable(skillTable.pos[1], -skillTable.pos[2])
			else
				skillTable.pos = VectorTable(0,0)
			end
			if skillTable.links then
				if istable(skillTable.links) then
					local copiedLinks = {}
					for k,v in pairs(skillTable.links) do
						copiedLinks[k] = v
					end
					skillTable.links = copiedLinks
				end
			else
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
	if traits.targetHealth then
		traits.targetHealth = traits.targetHealth*(1+(traits.targetHealthEffectiveness or 0)/100)
	end
	if traits.skillExperience then
		traits.skillExperience = traits.skillExperience*(1+(traits.skillExperienceEffectiveness or 0)/100)
	end
	if traits.skillExperiencePerWave then
		traits.skillExperiencePerWave = traits.skillExperiencePerWave*(1+(traits.skillExperiencePerWaveEffectiveness or 0)/100)
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
		elseif class == "gballoon_tower_07" and typ == ROTGB_TOWER_PURCHASE and IsValid(data.ply) and hook.Run("GetSkillAmount", "allyPawnFirstFree")>0 then
			if not data.ply.rotgb_allyPawnFirstFreeDone then return 0 end
		end
	end
	return newAmount
end

-- defined in gballoon_target.lua
function GM:gBalloonTargetHealthAdjust(ent, health)
	ent:SetGoldenHealth(hook.Run("GetSkillAmount", "targetGoldenHealth"))
	ent:SetPerWaveShieldPercent(hook.Run("GetSkillAmount", "targetShield"))
	ent:SetOSPs(hook.Run("GetSkillAmount", "targetOSP"))
	local newHealth = health * (1+hook.Run("GetSkillAmount", "targetHealth")/100)
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
	if tower:GetClass() == "gballoon_tower_07" then
		tower:GetTowerOwner().rotgb_allyPawnFirstFreeDone = true
	end
end
function GM:GetMaxRotgBTowerCount(tower)
	if hook.Run("GetSkillAmount", "towerFiveOnly")>0 then return 5 end
	return ROTGB_GetConVarValue("rotgb_tower_maxcount")
end

local PLAYER = FindMetaTable("Player")

local maxLevel = math.huge
local experienceNeeded = {
	100, 250, 500, 1000
}
local function getExperienceNeeded(currentLevel)
	currentLevel = math.floor(currentLevel)
	if currentLevel < 1 then return 0
	elseif currentLevel >= maxLevel then return math.huge
	elseif experienceNeeded[currentLevel] then return experienceNeeded[currentLevel]
	else
		local n = currentLevel-4
		return 500*(n*n+n+2)
	end
end
local function getLevel(currentExperience)
	local experienceNeededLength = #experienceNeeded
	if currentExperience >= math.huge then return math.huge
	elseif currentExperience < experienceNeeded[experienceNeededLength] then
		local level = 1
		for i,v in ipairs(experienceNeeded) do
			if v > currentExperience then break end
			level = i+1
		end
		return level
	else
		return math.min(math.floor(4.5 + math.sqrt(currentExperience/500 - 1.75)), maxLevel)
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
	return (self.rtg_PreviousXP or 0) + (self.rtg_XP or 0)
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
		if v ~= true then
			hook.Run("RTG_Log", "A skill value of \""..tostring(v).."\" was inserted instead of a bool. This is incorrect!", RTG_LOGGING_ERROR)
			debug.Trace()
		end
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
		cachedTowers = ROTGB_GetAllTowers and ROTGB_GetAllTowers() or {}
	end
	return math.max(self:RTG_GetLevel() - self:RTG_GetSkillAmount() - #cachedTowers, 0)
end