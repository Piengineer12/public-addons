InsaneStats.BOOL = 1
InsaneStats.INT = 2
InsaneStats.FLOAT = 3
InsaneStats.STRING = 4
InsaneStats.NOP = function()end

InsaneStats.EVENTS = {
	INIT = 0,
	DISC = 1,
	CHANGE = 2,
	RESTART = 3,
	END = 4,
	KILL = 5,
	INPUT = 6,
	TRIGGER = 7,
	VAR = 8,
	CREATE = 9
}

InsaneStats.ACTIONS = {
	CANCEL = 0,
	CHANGE = 1,
	INPUT = 2,
	APPLY_STATUS = 3,
	CLEAR_STATUS = 4,
	RUN_COMMAND = 5,
	TOGGLE_CVAR = 6,
	ADD_CVAR = 7,
	MULT_CVAR = 8,
	NO_WEPS = 9,
	NO_SUIT = 10,
	PLAY = 11,
	SET_SVAR = 12,
	TOGGLE_SVAR = 13,
	ADD_SVAR = 14,
	MULT_SVAR = 15,
	LUA = 16,
	TIMER = 17,
	WAVE = 18,
	CHAT = 19,
	SPECIAL = 20
}

InsaneStats.numConVars = 0
InsaneStats.conVars = {}
InsaneStats._defaultConVarCategory = ""
--defaultConVarCategoryDisplay = ""

-- this is on the shared side, because the client needs to know
-- the server's ConVars for the GUI menu, but at the same time
-- the server doesn't need to know about the client's ConVars
AccessorFunc(InsaneStats, "_defaultConVarCategory", "DefaultConVarCategory", FORCE_STRING)

--[[function InsaneStats:SetDefaultConVarCategory(name, display)
	self.defaultConVarCategory = name
	self.defaultConVarCategoryDisplay = display
end]]

function InsaneStats:RegisterConVar(name, internal, default, data)
	local conVar

	-- if it is of boolean type, only 0 and 1 values are allowed
	if data.type == self.BOOL then
		data.min = 0
		data.max = 1
	end

	if data.type == self.INT or data.type == self.BOOL then
		conVar = CreateConVar(
			internal,
			default,
			bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
			data.desc,
			data.min,
			data.max
		)
	else
		conVar = CreateConVar(
			internal,
			default,
			bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
			data.desc
		)
	end

	self.numConVars = self.numConVars + 1

	local conVarData = {
		conVar = conVar,
		internal = internal,
		default = default,
		id = self.numConVars
	}
	table.Merge(conVarData, data)

	if not conVarData.category then
		conVarData.category = self:GetDefaultConVarCategory()
		--conVarData.category, conVarData.categoryDisplay = self:GetDefaultConVarCategory()
	end

	self.conVars[name] = conVarData

	return conVar
end

function InsaneStats:GetConVarValue(name)
	if not self.conVars[name] then
		InsaneStats:Log("%s is not a valid ConVar!", name)
	end
	local valueType = self.conVars[name].type
	local conVar = self.conVars[name].conVar

	if valueType == self.BOOL then
		return conVar:GetBool()
	elseif valueType == self.INT then
		return conVar:GetInt()
	elseif valueType == self.FLOAT then
		return conVar:GetFloat()
	elseif conVar then
		return conVar:GetString()
	end
end

function InsaneStats:GetConVarValueDefaulted(...)
	local vars = {...}

	if istable(vars[1]) then
		vars = vars[1]
	end

	for i,v in ipairs(vars) do
		if v then
			local value = self:GetConVarValue(v)
			if value >= 0 then
				return value
			end
		end
	end

	return self:GetConVarValue(vars[#vars])
end

function InsaneStats:GetConVarData(name)
	return self.conVars[name]
end

function InsaneStats:CalculateRoot8(num)
	local tentativeNum = num^0.125

	-- for some fucking reason 1e+40^0.125 = 1e+40 on the non-x64 branch
	if tentativeNum == num then
		return math.sqrt(math.sqrt(math.sqrt(num)))
	else return tentativeNum
	end
end

function InsaneStats:IsDebugLevel(num)
	return self:GetConVarValue("debug") >= num
end

function InsaneStats:GetAmmoMax(id)
	local ammoMaxOverride = GetConVar("gmod_maxammo"):GetFloat()
	return tonumber(ammoMaxOverride > 0 and ammoMaxOverride or game.GetAmmoMax(id)) or -1
end

function InsaneStats:CalculateTriangleWaveValue(t, period, phase, min, max)
	return max + (min - max) * math.abs((t / period + phase) % 1 * 2 - 1)
end

function InsaneStats:GetEntityIterator()
    local ret = {ents.Iterator()}
    if table.IsEmpty(ret[2]) then
        -- HACK: this should never happen since even worldspawn is an entity
        -- but if an addon uses ents.Iterator() incorrectly, this can't be trusted
        return ipairs(ents.GetAll())
    else
        return unpack(ret)
    end
end

local ENTITY = FindMetaTable("Entity")

function ENTITY:InsaneStats_IsMob()
	return IsValid(self) and (
		self:IsPlayer() or self:IsNPC() or self:IsNextBot()
		or self:GetClass()=="prop_vehicle_apc"
	) and self:GetClass() ~= "npc_bullseye"
end

function ENTITY:InsaneStats_IsBig()
	if IsValid(self) and not self:IsPlayer() then
		local bounds = {self:GetCollisionBounds()}
		bounds = bounds[2] - bounds[1]
		return bounds[1] > 29 and bounds[2] > 29 and bounds[3] > 71
	end
end

-- MISC

InsaneStats:SetDefaultConVarCategory("Miscellaneous")
InsaneStats:RegisterConVar("save_file", "insanestats_save_file", "default", {
	display = "Save File Name", desc = "Data from other modules such as XP and WPASS2 will be saved in \z
	data/insane_stats/<name>.json.\n\z
	Note that ConVar values are not saved this way, and changes to this ConVar only take effect after a map change.",
	type = InsaneStats.STRING
})
InsaneStats:RegisterConVar("spawn_delay", "insanestats_spawn_delay", "0", {
	display = "Insane Stats Spawn Delay", desc = "Delays the effects of Insane Stats to newly spawned entities for this many seconds. \z
	Note that WPASS2 and the Experience System causes entities to be invincible before the spawn delay elapses.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
--[[InsaneStats:RegisterConVar("minimum_spawn_delay", "insanestats_minimum_spawn_delay", "-1", {
	display = "Minimum NPC Maker Delay", desc = "npc_maker and npc_template_maker require at least this many seconds \z
	to spawn a new NPC. Useful for preventing lag caused by way too many NPC kills. \z
	Set to a negative value to disable.",
	type = InsaneStats.FLOAT, min = -1, max = 10
})]]
InsaneStats:RegisterConVar("resource_addworkshop", "insanestats_resource_addworkshop", "1", {
	display = "Add to WorkshopDL", desc = "Uses resource.AddWorkshop to add Insane Stats to the download list, \z
	allowing all clients to listen to the sounds and see the images and fonts added by Insane Stats.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("debug", "insanestats_debug", "0", {
	display = "Debug Level", desc = "Causes Insane Stats to display messages used for debugging. Higher numbers cause more messages to be displayed.",
	type = InsaneStats.INT, min = 0, max = 4
})
