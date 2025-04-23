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
InsaneStats:RegisterConVar("skills_shuffle", "insanestats_skills_shuffle", "1", {
	display = "Shuffle Skills", desc = "If 2, causes the position of skills in the skill grid \z
	to be shuffled whenever skills change. If 1, shuffling only occurs on 1 April.",
	type = InsaneStats.INT, min = 0, max = 2
})
InsaneStats:RegisterConVar("skills_shuffle_seed", "insanestats_skills_shuffle_seed", "default", {
	display = "Skill Shuffle Seed", desc = "Seed for the skill shuffle algorithm.",
	type = InsaneStats.STRING
})

InsaneStats:RegisterConVar("skills_level_start", "insanestats_skills_level_start", "2", {
	display = "Starting Level Required", desc = "Level required to earn the first skill point.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("skills_level_add", "insanestats_skills_level_add", "10", {
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

-- I really don't like that these are hardcoded
-- but I can't think of a better way
InsaneStats.SealedInfo = {
	name = "[SEALED]",
	desc = "%+.1f%% coins and XP gain. \z
	(Unseal this skill to restore normal behavior.)",
	values = function(level, ent)
		return level * ent:InsaneStats_GetEffectiveSkillValues("skill_sealer")
	end,
	img = "interdiction"
}
InsaneStats.DisabledInfo = {
	name = "[DISABLED]",
	desc = "%+i skill point(s)%s",
	desc_uber = " and +1 über skill point",
	img = "padlock"
}

AccessorFunc(InsaneStats, "AllSkills", "AllSkills")
InsaneStats:SetAllSkills({})

local skillNames = {}
local skillPositions = {}
local maxSkillPoints = 0
local maxUberSkillPoints = 0
local function MapSkillsToIDs()
	maxSkillPoints = 0
	maxUberSkillPoints = 0

	for k,v in SortedPairs(InsaneStats:GetAllSkills()) do
		v.id = table.insert(skillNames, k)

		local x, y = v.pos[1], v.pos[2]
		skillPositions[x] = skillPositions[x] or {}
		skillPositions[x][y] = k

		maxUberSkillPoints = maxUberSkillPoints + 1
		maxSkillPoints = maxSkillPoints + (v.max or 5)
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
	return maxSkillPoints
end

function InsaneStats:GetMaxUberSkillPoints()
	return maxUberSkillPoints
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
	if self:InsaneStats_GetTotalSkillPoints() >= InsaneStats:GetMaxSkillPoints() then
		uber = uber and self:InsaneStats_GetTotalUberSkillPoints() >= InsaneStats:GetMaxUberSkillPoints()

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

function ENTITY:InsaneStats_GetSkillTier(skill)
	if InsaneStats:GetConVarValue("skills_enabled") then
		return self:InsaneStats_GetSkills()[skill] or 0
	else
		return 0
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

	for k,v in pairs(InsaneStats:GetDisabledSkills()) do
		local skillInfo = InsaneStats:GetSkillInfo(k)
		points = points + math.min(self:InsaneStats_GetSkillTier(k), skillInfo.max or 5)
	end

	return math.max(math.floor(points), 0)
end

function ENTITY:InsaneStats_GetSpentSkillPoints()
	local invested = 0
	for k,v in pairs(self:InsaneStats_GetSkills()) do
		local max = InsaneStats:GetSkillInfo(k).max or 5
		invested = invested + math.min(max, v)
	end

	return invested
end

function ENTITY:InsaneStats_GetSkillPoints()
	return math.min(
		self:InsaneStats_GetTotalSkillPoints(),
		InsaneStats:GetMaxSkillPoints()
	) - self:InsaneStats_GetSpentSkillPoints()
end

function ENTITY:InsaneStats_GetTotalUberSkillPoints()
	if self:InsaneStats_EffectivelyHasSkill("when_the_sigma_grind_aint_enough") then
		local levels = self:InsaneStats_GetEffectiveSkillValues("when_the_sigma_grind_aint_enough")
		local points = math.floor(self:InsaneStats_GetTotalSkillPoints() / levels)

		for k,v in pairs(InsaneStats:GetDisabledSkills()) do
			local skillInfo = InsaneStats:GetSkillInfo(k)
			if self:InsaneStats_GetSkillTier(k) > (skillInfo.max or 5) then
				points = points + 1
			end
		end

		return points
	else
		return 0
	end
end

function ENTITY:InsaneStats_GetSpentUberSkillPoints()
	local invested = 0
	for k,v in pairs(self:InsaneStats_GetSkills()) do
		local max = InsaneStats:GetSkillInfo(k).max or 5
		if v > max then
			invested = invested + 1
		end
	end

	return invested
end

function ENTITY:InsaneStats_GetUberSkillPoints()
	return math.min(
		self:InsaneStats_GetTotalUberSkillPoints(),
		InsaneStats:GetMaxUberSkillPoints()
	) - self:InsaneStats_GetSpentUberSkillPoints()
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

-- skill sealing and disabling
function ENTITY:InsaneStats_CanSealSkills()
	return self:InsaneStats_EffectivelyHasSkill("skill_sealer")
end
function ENTITY:InsaneStats_SetSealedSkills(skills)
	self.insaneStats_SealedSkills = skills
	hook.Run("InsaneStatsSkillsChanged", self)
end
-- FIXME: this should explicitly specify on whether the skill should be sealed or unsealed
-- as the sealed state could become unsynchronized if packets get dropped
function ENTITY:InsaneStats_SealSkill(skill)
	self.insaneStats_SealedSkills = self.insaneStats_SealedSkills or {}
	if self.insaneStats_SealedSkills[skill] then
		self.insaneStats_SealedSkills[skill] = nil
	else
		self.insaneStats_SealedSkills[skill] = true
	end
	hook.Run("InsaneStatsSkillsChanged", self)
end
function ENTITY:InsaneStats_GetSealedSkills()
	local skills = self.insaneStats_SealedSkills or {}
	for k,v in pairs(skills) do
		if not InsaneStats:GetSkillInfo(k) then
			skills[k] = nil
		end
	end
	return skills
end
function ENTITY:InsaneStats_IsSkillSealed(skill)
	self.insaneStats_SealedSkills = self.insaneStats_SealedSkills or {}
	return self.insaneStats_SealedSkills[skill]
end

local range = 65536
function ENTITY:InsaneStats_GetCurrentRNGSeed()
	generatorName = "InsaneStatsRNGGenerator_"..InsaneStats:GetConVarValue("skills_shuffle_seed")
	seed = 0

	local selfSkills = self:InsaneStats_GetSkills()
	for i,v in ipairs(skillNames) do
		local tier = selfSkills[v] or 0
		seed = math.floor(util.SharedRandom(
			generatorName, -2147483648, 2147483648, bit.tobit(seed + range * tier)
		))
	end

	return seed
end
function ENTITY:InsaneStats_GenerateRNGSkillPositions()
	local minMax = {}
	local newMinMax = {}
	local skillsData = InsaneStats:GetAllSkills()
	for i,v in ipairs(skillNames) do
		local skillData = skillsData[v]
		local mn = skillData.minpts or 0
		local mx = skillData.max or 5
		minMax[mn] = minMax[mn] or {}
		minMax[mn][mx] = minMax[mn][mx] or {}
		table.insert(minMax[mn][mx], v)

		newMinMax[mn] = newMinMax[mn] or {}
		newMinMax[mn][mx] = newMinMax[mn][mx] or {}
		table.insert(newMinMax[mn][mx], v)
	end

	-- shuffle the ones in newMinMax
	math.randomseed(self:InsaneStats_GetCurrentRNGSeed())
	for mn,maxs in SortedPairs(newMinMax) do
		for mx,skillNames in SortedPairs(maxs) do
			table.Shuffle(skillNames)
		end
	end
	math.randomseed(os.time())

	local rngData = {{}, {}}
	for mn,maxs in pairs(minMax) do
		for mx,skillNames in pairs(maxs) do
			for i,fromSkill in ipairs(skillNames) do
				local toSkill = newMinMax[mn][mx][i]
				local toSkillPos = skillsData[toSkill].pos
				local x, y = toSkillPos[1], toSkillPos[2]
				rngData[1][fromSkill] = toSkillPos
				rngData[2][x] = rngData[2][x] or {}
				rngData[2][x][y] = fromSkill
			end
		end
	end

	return rngData
end
function ENTITY:InsaneStats_GetSkillPosition(skill)
	local doShuffle = InsaneStats:GetConVarValue("skills_shuffle")
	doShuffle = doShuffle == 2 or doShuffle == 1 and os.date("!%m-%d") == "04-01"
	if doShuffle and self:InsaneStats_GetEffectiveSkillTier("master_of_air") <= 1 then
		local rngSkillData = self:InsaneStats_GetEntityData("skill_rng_data")
		if not rngSkillData then
			rngSkillData = self:InsaneStats_GenerateRNGSkillPositions()
			self:InsaneStats_SetEntityData("skill_rng_data", rngSkillData)
		end
		return rngSkillData[1][skill]
	else
		return InsaneStats:GetSkillInfo(skill).pos
	end
end
function ENTITY:InsaneStats_GetSkillByPosition(x, y)
	local doShuffle = InsaneStats:GetConVarValue("skills_shuffle")
	doShuffle = doShuffle == 2 or doShuffle == 1 and os.date("!%m-%d") == "04-01"
	if doShuffle and self:InsaneStats_GetEffectiveSkillTier("master_of_air") <= 1 then
		local rngSkillData = self:InsaneStats_GetEntityData("skill_rng_data")
		if not rngSkillData then
			rngSkillData = self:InsaneStats_GenerateRNGSkillPositions()
			self:InsaneStats_SetEntityData("skill_rng_data", rngSkillData)
		end
		return (rngSkillData[2][x] or {})[y]
	else
		return (skillPositions[x] or {})[y]
	end
end

function ENTITY:InsaneStats_CanDisableSkills()
	return self:IsAdmin()
end
function InsaneStats:SetDisabledSkills(skills)
	self.DisabledSkills = skills

	for i,v in ents.Iterator() do
		if v.insaneStats_Skills then
			hook.Run("InsaneStatsSkillsChanged", v)
		end
	end
end
function InsaneStats:GetDisabledSkills()
	self.DisabledSkills = self.DisabledSkills or {}
	return self.DisabledSkills
end
function InsaneStats:DisableSkill(skill, bool)
	self.DisabledSkills = self.DisabledSkills or {}
	self.DisabledSkills[skill] = bool or nil

	for i,v in ents.Iterator() do
		if v.insaneStats_Skills then
			if v:InsaneStats_IsSkillSealed(skill) then
				v:InsaneStats_SealSkill(skill)
				hook.Run("InsaneStatsSkillsChanged", v)
			end
		end
	end
end
function InsaneStats:IsSkillDisabled(skill)
	self.DisabledSkills = self.DisabledSkills or {}
	return self.DisabledSkills[skill]
end

-- effective skill stats
function ENTITY:InsaneStats_EffectivelyHasSkill(skill)
	return self:InsaneStats_GetEffectiveSkillTier(skill) > 0
end

local cachedTotals = {}
local lastCache = math.floor(engine.TickCount() / 10)
function ENTITY:InsaneStats_GetEffectiveSkillTier(skill)
	if InsaneStats:GetConVarValue("skills_enabled") then
		local tickCount = math.floor(engine.TickCount() / 10)
		if tickCount ~= lastCache then
			cachedTotals = {}
			lastCache = tickCount
		end

		cachedTotals[self] = cachedTotals[self] or {}
		if cachedTotals[self][skill] then return cachedTotals[self][skill] end

		local val = hook.Run("InsaneStatsGetSkillTier", self, skill)
		if val then
			cachedTotals[self][skill] = val
		elseif not (self:InsaneStats_IsSkillSealed(skill) or InsaneStats:IsSkillDisabled(skill)) then
			cachedTotals[self][skill] = self:InsaneStats_GetSkills()[skill] or 0
		else
			cachedTotals[self][skill] = 0
		end

		return cachedTotals[self][skill]
	end
	
	return 0
end

function ENTITY:InsaneStats_GetEffectiveSkillValues(skill, index)
	if index then
		return select(index, self:InsaneStats_GetEffectiveSkillValues(skill))
	else
		local skillInfo = InsaneStats:GetSkillInfo(skill)
		return skillInfo.values(self:InsaneStats_GetEffectiveSkillTier(skill), self)
	end
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
	if self:InsaneStats_EffectivelyHasSkill(skill) then
		local skillInfo = InsaneStats:GetSkillInfo(skill)
		if skillInfo.stackTick and not skipUpdate then
			local skillData = self:InsaneStats_GetSkillData(skill)
			local diffTime = math.max(CurTime() - (skillData.updateTime or CurTime()), 0)
			local diffTimeData = {diffTime = diffTime, ent = self, skill = skill}
			hook.Run("InsaneStatsSkillDiffTime", diffTimeData)
			local newState, newStacks = skillInfo.stackTick(skillData.state or -2, skillData.stacks or 0, diffTimeData.diffTime, self)
			
			local skillData = self:InsaneStats_GetSkillData(skill)
			skillData.state = newState
			skillData.stacks = newStacks
			skillData.updateTime = CurTime()
			return newStacks
		else
			return self:InsaneStats_GetSkillData(skill).stacks or 0
		end
	else return 0
	end
end

function ENTITY:InsaneStats_GetSkillState(skill, skipUpdate)
	if self:InsaneStats_EffectivelyHasSkill(skill) then
		local skillInfo = InsaneStats:GetSkillInfo(skill)
		if skillInfo.stackTick and not skipUpdate then
			local skillData = self:InsaneStats_GetSkillData(skill)
			local diffTime = math.max(CurTime() - (skillData.updateTime or CurTime()), 0)
			local diffTimeData = {diffTime = diffTime, ent = self, skill = skill}
			hook.Run("InsaneStatsSkillDiffTime", diffTimeData)
			local newState, newStacks = skillInfo.stackTick(skillData.state or -2, skillData.stacks or 0, diffTimeData.diffTime, self)
			
			local skillData = self:InsaneStats_GetSkillData(skill)
			skillData.state = newState
			skillData.stacks = newStacks
			skillData.updateTime = CurTime()
			return newState
		else
			return self:InsaneStats_GetSkillData(skill).state or -2
		end
	else return -2
	end
end

hook.Add("InsaneStatsSkillsChanged", "InsaneStatsSkillsShared", function(ent)
	--if ent:IsPlayer() then print(RealTime(), ent) end
	cachedTotals[ent] = nil
	ent:InsaneStats_SetEntityData("skill_rng_data", nil)
end)