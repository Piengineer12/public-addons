InsaneStats:SetDefaultConVarCategory("Compatibility")

InsaneStats:RegisterConVar("spawn_master", "insanestats_spawn_master", "0", {
	display = "Spawn At First Spawn Position",
	desc = "Players will always spawn at the first spawn position within the map, \z
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
InsaneStats:RegisterConVar("transition_delay_forcesolid", "insanestats_transition_delay_forcesolid", "0", {
	display = "Force Triggerable Level Transitions After Cooldown", desc = "After the first 15 seconds of a map, \z
	trigger_changelevels will be forcefully triggerable even if specified not to be by the map.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("ammocrate_maxammo", "insanestats_ammocrate_maxammo", "0", {
	display = "Ammo Crates Give 9999", desc = "Ammo crates always give 9999 ammo, limited only by the gmod_maxammo ConVar.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("gargantua_is_monster", "insanestats_gargantua_is_monster", "1", {
	display = "Correct Gargantua Class Name", desc = "Redirects most npc_gargantua references to monster_gargantua. \z
	Fixes at least a few Synergy maps from not working at all in GMod.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("other_game_entities", "insanestats_other_game_entities", "1", {
	display = "Entities of Other Games", desc = "Adds some Synergy-specific entities \z
	if they haven't yet been added by other addons. \z
	Fixes most Synergy maps not working at all in GMod.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("maker_spawn_enable", "insanestats_maker_spawn_enable", "-2", {
	display = "NPC Maker Spawning Enables It", desc = "An npc_template_maker that spawns an entity \z
    while disabled will always become enabled, taking a maximum of this many seconds between spawns. \z
    A value of -1 causes NPC makers to spawn an entity when the last spawned entity is dead.\z
    A value lower than -1 disables this feature.",
	type = InsaneStats.FLOAT, min = -2, max = 10
})
InsaneStats:RegisterConVar("sleepphys_lagamount", "insanestats_sleepphys_lagamount", "50", {
	display = "Sleep Physics On Lag", desc = "If the server's taking 0.5 seconds to process ticks \z
	for this many ticks, ALL physics objects will be put to sleep. 0 disables this feature.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("sleepphys_cooldown", "insanestats_sleepphys_cooldown", "1", {
	display = "Sleep Physics Cooldown", desc = "Minimum seconds between \"insanestats_sleepphys_lagamount\" triggers.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("prevent_gunship_death_crash", "insanestats_prevent_gunship_death_crash", "0", {
	display = "Prevent Gunship Death Crash", desc = "If an npc_combinegunship is marked as a template NPC, \z
	ALL npc_combinegunships are replaced with npc_helicopters.",
	type = InsaneStats.BOOL
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
	display = "Non-Solid Combine Dropships",
	desc = "Causes npc_combinedropships and prop_dropship_containers to be non-solid. \z
	Prevents combine dropships that travel to the same location from getting stuck against each other.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("solid_bolts", "insanestats_solid_bolts", "0", {
	display = "Solid Crossbow Bolts", desc = "Crossbow bolts that hit a surface become solid, up to this many per player. \z
	Allows maps such as sp_crossbowplatformer, which makes heavy use of bolt physics, to work in GMod.",
	type = InsaneStats.INT, min = 0, max = 100
})
InsaneStats:RegisterConVar("void_rescue", "insanestats_void_rescue", "1", {
	display = "Rescue from Void",
	desc = "Players that fall into the void are eventually teleported to an available spawnpoint.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("lego_softcap", "insanestats_lego_softcap", "1", {
	display = "Softcap Dropped Studs",
	desc = "If Lego Stud Drop Effect is enabled, entities that would drop over 10,000 studs will have their drops softcapped. \z
    Requires a map restart to take effect.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("unfiltered_teams", "insanestats_unfiltered_teams", "3 4", {
	display = "Unfiltered Teams",
	desc = "filter_activator_teams searching for these teams will always pass. Separate entries with whitespace.",
	type = InsaneStats.STRING
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

local hlsAliases = {
	npc_gargantua = "monster_gargantua",
	npc_alien_grunt = "monster_alien_grunt",
	npc_houndeye = "monster_houndeye",
	npc_panthereye = "monster_houndeye",
	npc_bullsquid = "monster_bullchicken",
	npc_hunter_elite = "npc_hunter",
	npc_hgrunt = "monster_human_grunt",
	npc_hassassin = "monster_human_assassin",
	npc_combine_cannon = "npc_sniper"
}
local function aliasHLSEnts(forced)
	-- the class of entities can't really be changed in Lua
	-- solution: register an extremely barebones entity with the sole purpose
	-- of spawning the actual entity with the keyvalues of the temp entity
	for k,v in pairs(hlsAliases) do
		if not scripted_ents.GetStored(k) or forced then
			local entTable = {Type = "ai", Base = "base_ai"}
			function entTable:KeyValue(k2,v2)
				self.insaneStats_KVs = self.insaneStats_KVs or {}
				if k2:lower() ~= "classname" then
					table.insert(self.insaneStats_KVs, {k2, v2})
				end
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

						for i,v in ipairs(self:GetChildren()) do
							v:SetMoveParent(actualEnt)
						end
						self:Remove()
					end
				end
			end
			scripted_ents.Register(entTable, k)
		end
	end
end

local function makeOtherGameEntities(forced)
	if not scripted_ents.GetStored("hud_timer") or forced then
		local entTable = {Type = "point", Base = "base_point"}
		function entTable:KeyValue(k, v)
			self:AddOutputFromKeyValue(k, v)
			k = k:lower()
			if k == "timertext" then
				self.insaneStats_Text = v
			end
		end
		function entTable:AcceptInput(input, activator, caller, data)
			input = input:lower()

			if input == "start" then
				self.insaneStats_EndTime = CurTime() + (tonumber(data) or 0)
				self.insaneStats_Activator = activator

				net.Start("insane_stats")
				net.WriteUInt(10, 8)
				net.WriteFloat(self.insaneStats_EndTime)
				net.WriteFloat(math.huge)
				net.WriteString(self.insaneStats_Text or "")
				net.Broadcast()
				return true
			elseif input == "stop" then
				self.insaneStats_EndTime = nil

				net.Start("insane_stats")
				net.WriteUInt(10, 8)
				net.WriteFloat(-10)
				net.WriteFloat(math.huge)
				net.WriteString(self.insaneStats_Text or "")
				net.Broadcast()
				return true
			elseif input == "change" then
				self.insaneStats_EndTime = (self.insaneStats_EndTime or CurTime())
					+ (tonumber(data) or 0)
				self.insaneStats_Activator = activator

				net.Start("insane_stats")
				net.WriteUInt(10, 8)
				net.WriteFloat(self.insaneStats_EndTime)
				net.WriteFloat(math.huge)
				net.WriteString(self.insaneStats_Text or "")
				net.Broadcast()
				return true
			end
		end
		function entTable:Think()
			if (self.insaneStats_EndTime and CurTime() > self.insaneStats_EndTime) then
				self.insaneStats_EndTime = nil
				self:TriggerOutput("OnTimer", self.insaneStats_Activator)
			end
		end
		scripted_ents.Register(entTable, "hud_timer")
	end

	if not scripted_ents.GetStored("info_player_equip") or forced then
		local entTable = {Type = "point", Base = "base_point"}
		function entTable:KeyValue(k, v)
			self:AddOutputFromKeyValue(k, v)
			k = k:lower()
			if k == "startdisabled" then
				self.insaneStats_Disabled = tobool(v)
			else
				self.insaneStats_KVs = self.insaneStats_KVs or {}
				table.insert(self.insaneStats_KVs, {k, v})
			end
		end
		function entTable:AcceptInput(input, activator, caller, data)
			input = input:lower()

			if input == "enable" then
				self.insaneStats_Disabled = nil
				return true
			elseif input == "disable" then
				self.insaneStats_Disabled = true
				return true
			elseif input == "equipplayer" and activator:IsPlayer() then
				self:EquipPlayer(activator)
				return true
			elseif input == "equipallplayers" then
				for i,v in player.Iterator() do
					self:EquipPlayer(v)
				end
				return true
			end
		end
		function entTable:EquipPlayer(ply)
			for i,v in ipairs(self.insaneStats_KVs or {}) do
				local key, value = unpack(v)
				local num = tonumber(value) or 0
				if key == "item_armor" then
					ply:InsaneStats_AddArmorCapped(
						ply:InsaneStats_GetArmor() * num / 100
					)
				elseif key:sub(1, 5) == "ammo_" then
					local ammoType = key:sub(6)
					ply:GiveAmmo(num, ammoType)
				elseif num > 0 then
					ply:Give(key, num > 1)
				end
			end
		end
		scripted_ents.Register(entTable, "info_player_equip")
	end

	if not scripted_ents.GetStored("synergy_gameinfo") or forced then
		local entTable = {Type = "point", Base = "base_point"}
		function entTable:KeyValue(k, v)
			if k == "mode" then
				self.insaneStats_Mode = tonumber(v)
			end
		end
		scripted_ents.Register(entTable, "synergy_gameinfo")
	end

	if not scripted_ents.GetStored("info_spawn_manager") or forced then
		local entTable = {Type = "point", Base = "base_point"}
		function entTable:KeyValue(k, v)
			self:AddOutputFromKeyValue(k, v)
		end
		function entTable:AcceptInput(input, activator, caller, data)
			input = input:lower()

			if input == "setcheckpoint" then
				for i,v in ipairs(ents.FindByClass("info_player_coop")) do
					v.insaneStats_Disabled = v:GetName() ~= data
				end
				return true
			elseif input == "respawnplayers" then
				for i,v in player.Iterator() do
					if not v:Alive() then v:Spawn() end
				end
				return true
			elseif input == "teleportplayers" then
				local targets = ents.FindByName(data)
				if next(targets) then
					for i,v in player.Iterator() do
						local target = targets[i % #targets + 1]
						v:SetPos(target:GetPos())
					end
				end
				return true
			elseif input == "moveplayers" then
				if (IsValid(activator) and activator.Alive and activator:Alive()) then
					for i,v in player.Iterator() do
						v:SetPos(activator:GetPos())
					end
				else
					local targets = {}
					for i,v in ipairs(ents.FindByClass("info_player_coop")) do
						if not v.insaneStats_Disabled then
							table.insert(targets, v)
						end
					end
					if next(targets) then
						for i,v in player.Iterator() do
							local target = targets[i % #targets + 1]
							v:SetPos(target:GetPos())
						end
					end
				end
				return true
			end
		end
		scripted_ents.Register(entTable, "info_spawn_manager")
	end

	if not scripted_ents.GetStored("trigger_coop") or forced then
		local entTable = {Type = "brush", Base = "base_brush"}
		function entTable:KeyValue(k, v)
			self:AddOutputFromKeyValue(k, v)
			k = k:lower()
			if k == "counttype" then
				self.insaneStats_UsePercentage = tobool(v)
			elseif k == "playervalue" then
				self.insaneStats_Required = tonumber(v) or 0
			elseif k == "target" then
				self.insaneStats_TeleportTarget = v
			end
		end
		function entTable:AcceptInput(input, activator, caller, data)
			input = input:lower()
			if input == "teleportplayersnottouching" and self.insaneStats_TeleportTarget then
				local targets = ents.FindByName(self.insaneStats_TeleportTarget)
				if next(targets) then
					self.insaneStats_Touching = self.insaneStats_Touching or {}
					for i,v in player.Iterator() do
						if not self.insaneStats_Touching[v] then
							local target = targets[i % #targets + 1]
							v:SetPos(target:GetPos())
						end
					end
				end
				return true
			end
		end
		function entTable:StartTouch(ent)
			if ent:IsPlayer() then
				self.insaneStats_Touching = self.insaneStats_Touching or {}
				self.insaneStats_Touching[ent] = true

				local plyCount = self:GetTouchingCount()
				local playersNeeded = self:GetPlayersNeeded()

				if plyCount >= playersNeeded and not self.insaneStats_Complete then
					self.insaneStats_Complete = true
					self:TriggerOutput("OnPlayersIn", ent)
				end

				if plyCount >= player.GetCount() then
					self:TriggerOutput("OnAllPlayersIn", ent)
				end
			end
		end
		function entTable:EndTouch(ent)
			self.insaneStats_Touching = self.insaneStats_Touching or {}
			self.insaneStats_Touching[ent] = nil

			local plyCount = self:GetTouchingCount()
			local playersNeeded = self:GetPlayersNeeded()

			if plyCount < playersNeeded and self.insaneStats_Complete then
				self.insaneStats_Complete = nil
				self:TriggerOutput("OnPlayersOut", ent)
			end
		end
		function entTable:GetTouchingCount()
			local plyCount = 0
			for k,v in pairs(self.insaneStats_Touching) do
				if IsValid(k) then
					plyCount = plyCount + 1
				else
					self.insaneStats_Touching[k] = nil
				end
			end
			return plyCount
		end
		function entTable:GetPlayersNeeded()
			local playersNeeded
			if self.insaneStats_UsePercentage then
				playersNeeded = math.ceil(player.GetCount() * self.insaneStats_Required / 100)
			else
				playersNeeded = math.min(player.GetCount(), self.insaneStats_Required)
			end

			return playersNeeded
		end
		scripted_ents.Register(entTable, "trigger_coop")
	end

	if not scripted_ents.GetStored("prop_vehicle_mp") or forced then
		-- FIXME: this is the wrong model
		local entTable = {Type = "point", Base = "base_point"}
		function entTable:KeyValue(k, v)
			self.insaneStats_KVs = self.insaneStats_KVs or {}
			k = k:lower()
			if k == "model" then
				if util.IsValidModel(v) then
					table.insert(self.insaneStats_KVs, {k, v})
				else
					table.insert(self.insaneStats_KVs, {k, "models/buggy.mdl"})
				end
			elseif k ~= "classname" then
				table.insert(self.insaneStats_KVs, {k, v})
			end
		end
		function entTable:Initialize()
			if SERVER then
				local actualEnt = ents.Create("prop_vehicle_jeep")
				actualEnt:SetPos(self:GetPos())
				for i,v in ipairs(self.insaneStats_KVs or {}) do
					actualEnt:SetKeyValue(v[1], v[2])
				end
				actualEnt:Spawn()
				actualEnt:Activate()

				for i,v in ipairs(self:GetChildren()) do
					v:SetMoveParent(actualEnt)
				end
				self:Remove()
			end
		end
		scripted_ents.Register(entTable, "prop_vehicle_mp")
	end
end

hook.Add("Initialize", "InsaneStatsCompatShared", function()
	if InsaneStats:GetConVarValue("gargantua_is_monster") then
		aliasHLSEnts()
	end

	if InsaneStats:GetConVarValue("other_game_entities") then
		makeOtherGameEntities()
	end

	if not scripted_ents.GetStored("env_hudhint") then
		local entTable = {Type = "point", Base = "base_point"}
		function entTable:KeyValue(k,v)
			if k:lower() == "message" then
				self.m_iszMessage = v
			end
		end
		scripted_ents.Register(entTable, "env_hudhint")
	end
end)

if player.GetCount() > 0 then
	if InsaneStats:GetConVarValue("gargantua_is_monster") then
		aliasHLSEnts(true)
	end

	if InsaneStats:GetConVarValue("other_game_entities") then
		makeOtherGameEntities(true)
	end

	local entTable = {Type = "point", Base = "base_point"}
	function entTable:KeyValue(k,v)
		if k:lower() == "message" then
			self.m_iszMessage = v
		end
	end
	scripted_ents.Register(entTable, "env_hudhint")
end
