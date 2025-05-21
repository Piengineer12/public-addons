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

local ENTITY = FindMetaTable("Entity")

function ENTITY:InsaneStats_IsMob()
	return IsValid(self) and (self:IsPlayer() or self:IsNPC() or self:IsNextBot() or self:GetClass()=="prop_vehicle_apc")
end

function ENTITY:InsaneStats_IsBig()
	if IsValid(self) then
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
InsaneStats:RegisterConVar("spawn_master", "insanestats_spawn_master", "0", {
	display = "Spawn At First Spawn Position", desc = "Players will always spawn at the first spawn position within the map, \z
	instead of a random spawn position. \z
	Additionally, master info_player_starts will always take priority over other info_player_starts.\n\z
	Useful for maps that have made the above assumptions, such as campaign maps.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("transition_delay", "insanestats_transition_delay", "1", {
	display = "Level Transitions Have Cooldowns", desc = "trigger_changelevels cannot be activated within the first 15 seconds of a map.\n\z
	Useful for maps where both trigger_changelevels are at the same place.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("ammocrate_maxammo", "insanestats_ammocrate_maxammo", "1", {
	display = "Ammo Crates Give 9999", desc = "Ammo crates always give 9999 ammo, limited only by the gmod_maxammo ConVar.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("gargantua_is_monster", "insanestats_gargantua_is_monster", "1", {
	display = "Correct Gargantua Class Name", desc = "Redirects most npc_gargantua references to monster_gargantua. \z
	Fixes at least a few Synergy maps from not working at all in GMod.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("sleepphys_lagamount", "insanestats_sleepphys_lagamount", "50", {
	display = "Sleep Physics On Lag", desc = "If the server's taking 0.5 seconds to process ticks \z
	for this many ticks, ALL physics objects will be put to sleep. 0 disables this feature.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("sleepphys_cooldown", "insanestats_sleepphys_cooldown", "1", {
	display = "Sleep Physics Cooldown", desc = "Minimum seconds between \"insanestats_sleepphys_lagamount\" triggers.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("camera_no_kill", "insanestats_camera_no_kill", "1", {
	display = "No Camera Killing", desc = "point_viewcontrols will not be removed when the Kill input is sent to them.\n\z
	Fixes certain cameras not working in some older campaign maps.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("skip_missing_scenes", "insanestats_skip_missing_scenes", "1", {
	display = "Skip Missing Scenes", desc = "Causes logic_choreographed_scenes to fire all outputs \z
	if the required VCD is missing. Technically fixes maps with broken scenes.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("nonsolid_combine_dropship", "insanestats_nonsolid_combine_dropship", "1", {
	display = "Non-Solid Combine Dropships", desc = "Causes npc_combinedropships to be non-solid. \z
	Prevents combine dropships that travel to the same location from getting stuck against each other.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("solid_bolts", "insanestats_solid_bolts", "0", {
	display = "Solid Crossbow Bolts", desc = "Crossbow bolts that hit a surface become solid, up to this many per player. \z
	Allows maps such as sp_crossbowplatformer, which makes heavy use of bolt physics, to work in GMod.",
	type = InsaneStats.INT, min = 0, max = 100
})
InsaneStats:RegisterConVar("flashlight_disable_fix", "insanestats_flashlight_disable_fix", "0", {
	display = "Fix DisableFlashlight", desc = "The DisableFlashlight map input will now actually disable the player's flashlight.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("flashlight_disable_fix_modifyspeed", "insanestats_flashlight_disable_fix_modifyspeed", "0", {
	display = "ModifySpeed on player_speedmod Disables Flashlight", desc = "In HL2, the ModifySpeed input on a player_speedmod entity would disable the player's flashlight. \z
	You can reenable this behaviour via this ConVar.",
	type = InsaneStats.BOOL
})
--[[InsaneStats:RegisterConVar("minimum_spawn_delay", "insanestats_minimum_spawn_delay", "-1", {
	display = "Minimum NPC Maker Delay", desc = "npc_maker and npc_template_maker require at least this many seconds \z
	to spawn a new NPC. Useful for preventing lag caused by way too many NPC kills. \z
	Set to a negative value to disable.",
	type = InsaneStats.FLOAT, min = -1, max = 10
})]]
InsaneStats:RegisterConVar("gametext_tochat", "insanestats_gametext_tochat", "1", {
	display = "game_text To Chat", desc = "Activated game_texts will also send their texts to chat.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("gametext_tochat_once", "insanestats_gametext_tochat_once", "1", {
	display = "Chat Only Once", desc = "Activated game_texts will only send their texts to chat once.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("hudhint_tochat", "insanestats_hudhint_tochat", "1", {
	display = "env_hudhint To Chat", desc = "Activated env_hudhints will also send their texts to chat.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("resource_addworkshop", "insanestats_resource_addworkshop", "1", {
	display = "Add to WorkshopDL", desc = "Uses resource.AddWorkshop to add Insane Stats to the download list, \z
	allowing all clients to listen to the sounds and see the images and fonts added by Insane Stats.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("debug", "insanestats_debug", "0", {
	display = "Debug Level", desc = "Causes Insane Stats to display messages used for debugging. Higher numbers cause more messages to be displayed.",
	type = InsaneStats.INT, min = 0, max = 4
})

local hlsAliases = {
	npc_gargantua = "monster_gargantua",
	npc_alien_grunt = "monster_alien_grunt",
	npc_houndeye = "monster_houndeye",
	npc_bullsquid = "monster_bullchicken",
}
local function aliasHLSEnts(forced)
	-- the class of entities can't really be changed in Lua
	-- solution: register an extremely barebones entity with the sole purpose
	-- of spawning the actual entity with the right keyvalues
	for k,v in pairs(hlsAliases) do
		if not scripted_ents.GetStored(k) or forced then
			local entTable = {Type = "ai", Base = "base_ai"}
			function entTable:KeyValue(k2,v2)
				self.insaneStats_KVs = self.insaneStats_KVs or {}
				if k2:lower() ~= "classname" then
					table.insert(self.insaneStats_KVs, {k2, v2})
				end
				--[[self:AddOutputFromAcceptInput(k2,v2)

				if k2:lower() == "ondeath" then
					self.insaneStats_MustHandleDeath = true
				end]]
			end
			function entTable:Initialize()
				if SERVER then
					if self:HasSpawnFlags(SF_NPC_TEMPLATE) then
						self:SetNoDraw(true)
						self:SetNotSolid(true)
					else
						local actualEnt = ents.Create(v)
						actualEnt:SetPos(self:GetPos())
						for i,v2 in ipairs(self.insaneStats_KVs or {}) do
							actualEnt:SetKeyValue(v2[1], v2[2])
						end
						actualEnt:Spawn()
						actualEnt:Activate()
						self:Remove()
					end
				end
			end
			scripted_ents.Register(entTable, k)
		end
	end
end

hook.Add("Initialize", "InsaneStatsShared", function()
	if InsaneStats:GetConVarValue("gargantua_is_monster") then
		aliasHLSEnts()
	end

	if InsaneStats:GetConVarValue("hudhint_tochat") and not scripted_ents.GetStored("env_hudhint") then
		local entTable = {Type = "point", Base = "base_point"}
		function entTable:KeyValue(k,v)
			if k:lower() == "message" then
				self.insaneStats_Text = v
			end
		end
		scripted_ents.Register(entTable, "env_hudhint")
	end
end)

if InsaneStats:GetConVarValue("gargantua_is_monster") and player.GetCount() > 0 then
	aliasHLSEnts(true)
end

if InsaneStats:GetConVarValue("hudhint_tochat") and player.GetCount() > 0 then
	local entTable = {Type = "point", Base = "base_point"}
	function entTable:KeyValue(k,v)
		if k:lower() == "message" then
			self.insaneStats_Text = v
		end
	end
	scripted_ents.Register(entTable, "env_hudhint")
end