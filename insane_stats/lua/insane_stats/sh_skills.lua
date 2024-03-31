InsaneStats:SetDefaultConVarCategory("Skills - General")

InsaneStats:RegisterConVar("skills_enabled", "insanestats_skills_enabled", "1", {
	display = "Enable Skills", desc = "Enables the skill system, allowing players to gain and spend skill points. \z
	The skill menu can be opened with the command \"insanestats_skills_menu\".",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("skills_start", "insanestats_skills_start", "0", {
	display = "Starting Skill Points", desc = "Starting number of skill points for each player.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("skills_allow_reset", "insanestats_skills_allow_reset", "2", {
	display = "Respec Mode", desc = "Determines how players respec their skills.\n\z
	0: None\n\z
	1: Manually via insanestats_skills_reset ConCommand\n\z
	2: Insane Stats Coin Shop\n\z
	3: Both\n\z",
	type = InsaneStats.INT, min = 0, max = 3
})
InsaneStats:RegisterConVar("skills_save", "insanestats_skills_save", "1", {
	display = "Save Player Skills", desc = "Causes player skills to be saved across maps. \z
	Disconnected players will also have their skills saved even if the map has changed.\n\z
	Note that Half-Life 2 level transitions already carry skills across the transitioned levels, even when this ConVar is off.",
	type = InsaneStats.BOOL
})

InsaneStats:RegisterConVar("skills_level_start", "insanestats_skills_level_start", "2", {
	display = "Starting Level Required", desc = "Level required to earn the first skill point.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("skills_level_add", "insanestats_skills_level_add", "20", {
	display = "Level Scaling", desc = "Additional % levels required per skill point.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("skills_level_add_mode", "insanestats_skills_level_add_mode", "-1", {
	display = "Level Scaling Mode", desc = "If 1, insanestats_skills_level_add is applied additively rather than multiplicatively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("skills_level_add_minimum", "insanestats_skills_level_add_minimum", "1", {
	display = "Level Scaling Minimum", desc = "Minimum level increase per skill point.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})

AccessorFunc(InsaneStats, "AllSkills", "AllSkills")
InsaneStats:SetAllSkills({})

local skillNames = {}
local skillPositions = {}
local function MapSkillsToIDs()
	for k,v in SortedPairs(InsaneStats:GetAllSkills()) do
		v.id = table.insert(skillNames, k)

		local x, y = v.pos[1], v.pos[2]
		skillPositions[x] = skillPositions[x] or {}
		skillPositions[x][y] = k
	end
end

hook.Run("InsaneStatsSkillLoad", InsaneStats:GetAllSkills())
MapSkillsToIDs()

hook.Add("Initialize", "InsaneStatsSkillsShared", function()
	InsaneStats:SetAllSkills({})
	hook.Run("InsaneStatsSkillLoad", InsaneStats:GetAllSkills())
	MapSkillsToIDs()
end)

function InsaneStats:GetSkillName(id)
	return skillNames[id]
end

function InsaneStats:GetSkillID(name)
	return InsaneStats:GetSkillInfo(name).id
end

function InsaneStats:GetSkillInfo(name)
	return InsaneStats:GetAllSkills()[name]
end

function InsaneStats:GetSkillNameByPosition(x, y)
	return (skillPositions[x] or {})[y]
end

function InsaneStats:GetMaxSkillPoints()
	return 341
end

function InsaneStats:GetMaxUberSkillPoints()
	return 81
end

local ENTITY = FindMetaTable("Entity")

function ENTITY:InsaneStats_SetSkills(skills)
	self.insaneStats_Skills = skills
	hook.Run("InsaneStatsSkillsChanged", self)
end

function ENTITY:InsaneStats_SetSkillTier(skill, level)
	self.insaneStats_Skills = self.insaneStats_Skills or {}
	self.insaneStats_Skills[skill] = level
	hook.Run("InsaneStatsSkillsChanged", self)
end

function ENTITY:InsaneStats_MaxAllSkills(uber)
	if self:InsaneStats_GetTotalSkillPoints() > 340 then
		uber = uber and self:InsaneStats_GetTotalUberSkillPoints() > 80

		for k,v in pairs(InsaneStats:GetAllSkills()) do
			self.insaneStats_Skills[k] = math.max((v.max or 5) * (uber and 2 or 1), self.insaneStats_Skills[k] or 0)
		end
		hook.Run("InsaneStatsSkillsChanged", self)
	end
end

function ENTITY:InsaneStats_GetSkills()
	local skills = self.insaneStats_Skills or {}
	for k,v in pairs(skills) do
		if not InsaneStats:GetSkillInfo(k) then
			skills[k] = nil
		end
	end
	return skills
end

function ENTITY:InsaneStats_HasSkill(skill)
	return self:InsaneStats_GetSkillTier(skill) > 0
end

function ENTITY:InsaneStats_GetSkillTier(skill)
	if InsaneStats:GetConVarValue("skills_enabled") then
		local val = hook.Run("InsaneStatsGetSkillTier", self, skill)
		if val then
			return val
		else
			return self:InsaneStats_GetSkills()[skill] or 0
		end
	else
		return 0
	end
end

function ENTITY:InsaneStats_GetSkillValues(skill, index)
	if index then
		return select(index, self:InsaneStats_GetSkillValues(skill))
	else
		return InsaneStats:GetSkillInfo(skill).values(self:InsaneStats_GetSkillTier(skill), self)
	end
end

function ENTITY:InsaneStats_GetTotalSkillPoints()
	local points = InsaneStats:GetConVarValue("skills_start")

	if InsaneStats:GetConVarValue("xp_enabled") then
		local level = self:InsaneStats_GetLevel()
		local startLevel = InsaneStats:GetConVarValue("skills_level_start")
		local multiplicative = not (InsaneStats:GetConVarValueDefaulted("skills_level_add_mode", "xp_mode") > 0)
		local addPoints = InsaneStats:ScaleLevelFromValuePure(
			level,
			InsaneStats:GetConVarValue("skills_level_add")/100,
			startLevel,
			multiplicative
		)
		local maxAddPoints = math.max(0, 1 + (level - startLevel) / InsaneStats:GetConVarValue("skills_level_add_minimum"))
		points = points + math.min(addPoints, maxAddPoints)
	end

	return math.max(math.floor(points), 0)
end

function ENTITY:InsaneStats_GetSkillPoints()
	local invested = 0
	for k,v in pairs(self:InsaneStats_GetSkills()) do
		local max = InsaneStats:GetSkillInfo(k).max or 5
		invested = invested + math.min(max, v)
	end

	return math.min(self:InsaneStats_GetTotalSkillPoints(), InsaneStats:GetMaxSkillPoints()) - invested
end

function ENTITY:InsaneStats_GetTotalUberSkillPoints()
	if self:InsaneStats_GetSkillTier("when_the_sigma_grind_aint_enough") > 0 then
		local levels = self:InsaneStats_GetSkillValues("when_the_sigma_grind_aint_enough")

		return math.floor(self:InsaneStats_GetTotalSkillPoints() / levels)
	else
		return 0
	end
end

function ENTITY:InsaneStats_GetUberSkillPoints()
	local invested = 0
	for k,v in pairs(self:InsaneStats_GetSkills()) do
		local max = InsaneStats:GetSkillInfo(k).max or 5
		if v > max then
			invested = invested + 1
		end
	end

	return math.min(
		self:InsaneStats_GetTotalUberSkillPoints(),
		InsaneStats:GetMaxUberSkillPoints()
	) - invested
end

function ENTITY:InsaneStats_GetNextSkillPointLevel()
	local startLevel = InsaneStats:GetConVarValue("skills_level_start")
	local points = self:InsaneStats_GetTotalSkillPoints() - InsaneStats:GetConVarValue("skills_start")
	local level = InsaneStats:ScaleValueToLevel(
		startLevel,
		InsaneStats:GetConVarValue("skills_level_add")/100,
		points + 1,
		"skills_level_add_mode",
		true
	)
	local levelMin = math.max(startLevel + points * InsaneStats:GetConVarValue("skills_level_add_minimum"))
	return math.ceil(math.max(level, levelMin))
end

-- skill states and stacks
function ENTITY:InsaneStats_GetSkillData(skill)
	self.insaneStats_SkillData = self.insaneStats_SkillData or {}
	self.insaneStats_SkillData[skill] = self.insaneStats_SkillData[skill] or {}
	return self.insaneStats_SkillData[skill]
end

function ENTITY:InsaneStats_SetSkillData(skill, state, stacks)
	local skillData = self:InsaneStats_GetSkillData(skill)
	skillData.state = state
	skillData.stacks = stacks
	skillData.updateTime = CurTime()
	if SERVER then
		self:InsaneStats_MarkForUpdate(128)
		if not InsaneStats:GetSkillDataToNetwork() then
			InsaneStats:SetSkillDataToNetwork({})
		end
		local skillDataToNetwork = InsaneStats:GetSkillDataToNetwork()
		skillDataToNetwork[self] = skillDataToNetwork[self] or {}
		skillDataToNetwork[self][skill] = true
	end
end

function ENTITY:InsaneStats_ClearSkillData()
	if SERVER then
		self:InsaneStats_MarkForUpdate(128)
		if not InsaneStats:GetSkillDataToNetwork() then
			InsaneStats:SetSkillDataToNetwork({})
		end
		local skillDataToNetwork = InsaneStats:GetSkillDataToNetwork()
		skillDataToNetwork[self] = skillDataToNetwork[self] or {}
		for k,v in pairs(self.insaneStats_SkillData or {}) do
			skillDataToNetwork[self][k] = true
		end
	end
	
	self.insaneStats_SkillData = {}
end

function ENTITY:InsaneStats_GetSkillStacks(skill, skipUpdate)
	local skillInfo = InsaneStats:GetSkillInfo(skill)
	if skillInfo.stackTick and not skipUpdate then
		local skillData = self:InsaneStats_GetSkillData(skill)
		local diffTime = math.max(CurTime() - (skillData.updateTime or CurTime()), 0)
		local newState, newStacks = skillInfo.stackTick(skillData.state or -2, skillData.stacks or 0, diffTime, self)
		
		local skillData = self:InsaneStats_GetSkillData(skill)
		skillData.state = newState
		skillData.stacks = newStacks
		skillData.updateTime = CurTime()
		return newStacks
	else
		return self:InsaneStats_GetSkillData(skill).stacks or 0
	end
end

function ENTITY:InsaneStats_GetSkillState(skill, skipUpdate)
	local skillInfo = InsaneStats:GetSkillInfo(skill)
	if skillInfo.stackTick and not skipUpdate then
		local skillData = self:InsaneStats_GetSkillData(skill)
		local diffTime = math.max(CurTime() - (skillData.updateTime or CurTime()), 0)
		local newState, newStacks = skillInfo.stackTick(skillData.state or -2, skillData.stacks or 0, diffTime, self)
		
		local skillData = self:InsaneStats_GetSkillData(skill)
		skillData.state = newState
		skillData.stacks = newStacks
		skillData.updateTime = CurTime()
		return newState
	else
		return self:InsaneStats_GetSkillData(skill).state or -2
	end
end