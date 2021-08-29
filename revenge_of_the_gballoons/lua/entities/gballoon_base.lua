AddCSLuaFile()

ENT.Type = "nextbot"
ENT.Base = "base_nextbot"
ENT.PrintName = "Rouge gBalloon"
ENT.Category = "RotgB: Basic"
-- ENT.ScriptedEntityType = "entity"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "To conquer the world!"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Editable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.DisableDuplicator = false
ENT.rotgb_rbetab = {
	gballoon_red=1,
	gballoon_blue=2,
	gballoon_green=3,
	gballoon_yellow=4,
	gballoon_pink=5,
	gballoon_black=11,
	gballoon_white=11,
	gballoon_purple=11,
	gballoon_orange=11,
	gballoon_gray=23,
	gballoon_zebra=23,
	gballoon_aqua=23,
	gballoon_error=23,
	gballoon_rainbow=93,
	gballoon_ceramic=103,
	gballoon_brick=133,
	gballoon_marble=193,
	
	gballoon_blimp_blue=612,
	gballoon_blimp_red=3148,
	gballoon_blimp_green=16592,
	gballoon_blimp_gray=972,
	gballoon_blimp_purple=57072,
	gballoon_blimp_magenta=9276,
	gballoon_blimp_rainbow=232695,
	
	-- the gBalloon Spawner implodes if we don't define these for some reason
	gballoon_fast_hidden_regen_shielded_blimp_gray=1944,
	gballoon_fast_blimp_magenta=5388,
	
	gballoon_glass=1,
	gballoon_void=1,
	gballoon_cfiber=999999999,
}
ENT.rotgb_spawns = {
	gballoon_blue={gballoon_red=1},
	gballoon_green={gballoon_blue=1},
	gballoon_yellow={gballoon_green=1},
	gballoon_pink={gballoon_yellow=1},
	gballoon_black={gballoon_pink=2},
	gballoon_white={gballoon_pink=2},
	gballoon_purple={gballoon_pink=2},
	gballoon_orange={gballoon_pink=2},
	gballoon_gray={gballoon_black=2},
	gballoon_zebra={gballoon_white=2},
	gballoon_aqua={gballoon_white=2},
	gballoon_error={gballoon_purple=2},
	gballoon_rainbow={gballoon_gray=1,gballoon_zebra=1,gballoon_aqua=1,gballoon_error=1},
	gballoon_ceramic={gballoon_rainbow=1},
	gballoon_brick={gballoon_ceramic=1},
	gballoon_marble={gballoon_brick=1},

	gballoon_blimp_blue={gballoon_ceramic=4},
	gballoon_blimp_red={gballoon_blimp_blue=4},
	gballoon_blimp_green={gballoon_blimp_red=4},
	gballoon_blimp_gray={gballoon_marble=4},
	gballoon_blimp_purple={gballoon_blimp_green=2,gballoon_fast_hidden_regen_shielded_blimp_gray=2},
	gballoon_blimp_magenta={gballoon_fast_hidden_regen_shielded_blimp_gray=4},
	gballoon_blimp_rainbow={gballoon_blimp_purple=2,gballoon_fast_blimp_magenta=2},
}
ENT.DebugArgs = {"fire","damage","func_nav_detection","pathfinding","popping","regeneration","targeting","towers"}

ROTGB_GBALLOONS = {}
ROTGB_CVARS = {}
local R_INT = 1
local R_FLOAT = 2
local R_BOOL = 3

ROTGB_OPERATION_BLACKLIST = 1
ROTGB_OPERATION_WAVE_TRANSFER = 2
ROTGB_OPERATION_TRANSFER = 3
ROTGB_OPERATION_ACHIEVEMENT = 4
ROTGB_OPERATION_WAVE_EDIT = 5

function ROTGB_Log(message,attrib)
	if ROTGB_GetConVarValue("rotgb_debug"):find(attrib) then
		MsgC(Color(0,255,0),"[RotgB] ",Color(255,255,0),string.FormattedTime(CurTime(),"[%02i:%02i.%02i]: "),Color(0,255,255),message,"\n")
	end
end

function ROTGB_LogError(message,attrib)
	if ROTGB_GetConVarValue("rotgb_debug"):find(attrib) then
		MsgC(Color(0,255,0),"[RotgB] ",Color(255,255,0),string.FormattedTime(CurTime(),"[%02i:%02i.%02i]: "),Color(255,127,127),message,"\n")
	end
end

function ROTGB_EntityLog(entity,message,attrib)
	if ROTGB_GetConVarValue("rotgb_debug"):find(attrib) then
		MsgC(Color(0,255,0),"[RotgB] ",Color(255,255,0),string.FormattedTime(CurTime(),"[%02i:%02i.%02i] "),color_white,tostring(entity)..": ",Color(0,255,255),message,"\n")
	end
end

function ROTGB_EntityLogError(entity,message,attrib)
	if ROTGB_GetConVarValue("rotgb_debug"):find(attrib) then
		MsgC(Color(0,255,0),"[RotgB] ",Color(255,255,0),string.FormattedTime(CurTime(),"[%02i:%02i.%02i] "),color_white,tostring(entity)..": ",Color(255,127,127),message,"\n")
	end
end

function ENT:Log(message,attrib)
	ROTGB_EntityLog(self,message,attrib)
end

function ENT:LogError(message,attrib)
	ROTGB_EntityLogError(self,message,attrib)
end

local function RegisterConVar(cvarName, default, retrieveType, description)
	if ROTGB_CVARS[cvarName] then
		ROTGB_LogError("The ConVar "..cvarName.." was already registered, expect side effects!","")
	end
	ROTGB_CVARS[cvarName] = {}
	ROTGB_CVARS[cvarName][1] = CreateConVar(cvarName, default, bit.bor(FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_REPLICATED), description)
	ROTGB_CVARS[cvarName][2] = retrieveType
end

local function ConvertToAppropriateRetrieveType(value, cvar)
	local retrieveType = ROTGB_CVARS[cvar][2]
	if retrieveType == R_INT then
		return math.floor(tonumber(value) or 0)
	elseif retrieveType == R_FLOAT then
		return tonumber(value) or 0
	elseif retrieveType == R_BOOL then
		return tobool(value)
	else return value
	end
end

function ROTGB_GetConVarValue(cvar)
	if engine.ActiveGamemode() == "rotgb" then
		local returnValue = hook.Run("ShouldConVarOverride", cvar)--GAMEMODE.Modes[hook.Run("GetCurrentMode")].convars[cvar] or GAMEMODE.Modes.__common.convars[cvar]
		if returnValue then
			if returnValue == true then
				return ConvertToAppropriateRetrieveType(ROTGB_CVARS[cvar][1]:GetDefault(), cvar)
			else
				return ConvertToAppropriateRetrieveType(returnValue, cvar)
			end
		end
	end
	if ROTGB_CVARS[cvar] then
		local conVar = ROTGB_CVARS[cvar][1]
		local retrieveType = ROTGB_CVARS[cvar][2]
		if retrieveType == R_INT then
			return conVar:GetInt()
		elseif retrieveType == R_FLOAT then
			return conVar:GetFloat()
		elseif retrieveType == R_BOOL then
			return conVar:GetBool()
		else return conVar:GetString()
		end
	else
		ROTGB_LogError("Tried to retrieve value of unregistered ConVar "..cvar.."!","")
		return 0
	end
end

RegisterConVar("rotgb_max_effects_per_second","20",R_FLOAT,
[[Maximum effects to show per second.
 - May also be a decimal value.]])

RegisterConVar("rotgb_regen_delay","2",R_FLOAT,
[[Amount of time it takes for a Regen gBalloon to regenerate one layer.]])

RegisterConVar("rotgb_func_nav_expand","10",R_FLOAT,
[[Additional bounding box size for func_nav_* entities.
 - Requires map restart to take effect.
 - The effects of this ConVar are only visible on mvm_* maps.]])

RegisterConVar("rotgb_path_delay","20",R_FLOAT,
[[Pathway re-computation delay modifier.
 - Increase this value if you experience constant lag with far away gBalloons.]])

RegisterConVar("rotgb_debug","",R_STRING,
[[Shows verbose developer debug messages. Available arguments:
 - ]]..table.concat(ENT.DebugArgs,", ")..'\n'..
[[ - You can seperate arguments with spaces.]])

RegisterConVar("rotgb_max_to_exist","64",R_INT,
[[Maximum amount of gBalloons to exist at once.
 - Note that this is only enforced when gBalloons are popped, not when they are spawned.]])

RegisterConVar("rotgb_ignore_damage_resistances","0",R_BOOL,
[[Causes all gBalloons to lose all damage resistances, including armored gBalloons.]])

RegisterConVar("rotgb_damage_multiplier","1",R_FLOAT,
[[Modifies damage taken by gBalloons from attacks.
 - The actual number of pops they undergo can be calculated with the formula
 - pop_count = ceil( damage * 0.1 * <this multiplier> )]])

RegisterConVar("rotgb_scale","1",R_FLOAT,
[[Modifies the scale of newer gBalloons.
 - This will also increase their hitbox size.]])

RegisterConVar("rotgb_visual_scale","1",R_FLOAT,
[[Visually modifies the scale of newer gBalloons.
 - This will not modify their hitbox.]])

RegisterConVar("rotgb_target_choice","3",R_INT,
[[Causes gBalloons to target:
 - 0 : None except for the gBalloon targets.
 - 1 : Players.
 - 2 : Citizens/Rebels.
 - 4 : Combine troops.
 - 8 : Zombies.
 - 16 : Antlions.
 - 32 : Other HL2 NPCs.
 - 64 : SNPCs.
 - 128 : NextBots other than ourselves.
 - 256 : Props and destructibles that have health.

 - Note: You can combine the values above. "25" (1+8+16) will cause the gBalloons to target players, zombies and antlions.
 - -1 means Target All Entities That Have Health.

 - Note: gBalloons will always target the gBalloon target whenever possible.
 - The ConVar ai_ignoreplayers will also modify player targeting and may cause this value to be silently subtracted by 1 if its odd.]])

RegisterConVar("rotgb_target_sort","0",R_INT,
[[Causes gBalloons to target:

 - 0 : the nearest enemy.
 - 1 : the furthest enemy.
 - 2 : the healthiest enemy.
 - 3 : the weakest enemy.

 - -1 means target randomly.]])

RegisterConVar("rotgb_search_size","-1",R_FLOAT,
[[Determines radius to search for enemies.
 - -1 means no limit.]])

RegisterConVar("rotgb_target_tolerance","32",R_FLOAT,
[[Determines how close the gBalloons should be to a target before popping.]])

RegisterConVar("rotgb_setminlookaheaddistance","10",R_FLOAT,
[[I don't know what this does. See PathFollower:SetMinLookAheadDistance(number).]])

RegisterConVar("rotgb_cash_param","0",R_FLOAT,
[[Sets the cash value for the rotgb_*cash ConCommands.]])

concommand.Add("rotgb_cash_param_internal",function(ply,cmd,args,argStr) if (not IsValid(ply) or ply:IsAdmin()) then ROTGB_CVARS["rotgb_cash_param"][1]:SetFloat(tonumber(args[1]) or 0) end end,nil,nil,FCVAR_UNREGISTERED)

RegisterConVar("rotgb_individualcash","0",R_BOOL,
[[Sets whether cash is shared or split among players.]])

local function CreateCfunction(fname,vname)
	return function(ply,cmd,args,argStr)
		if (not IsValid(ply) or ply:IsAdmin()) then
			if ROTGB_GetConVarValue("rotgb_individualcash") then
				if table.IsEmpty(args) then
					ROTGB_Log("Usage: ",vname," <amount> [player]\nOr: ",vname," * [player]","")
				else
					local num = table.remove(args,1)
					if next(args) then
						if args[1] == '*' then
							_G[fname](tonumber(num) or ROTGB_GetConVarValue("rotgb_cash_param"))
						else
							ply = nil
							local name = table.concat(args," ")
							for k,v in pairs(player.GetAll()) do
								if v:Nick()==name then
									ply = v
									break
								end
							end
						end
					else
						_G[fname](tonumber(num) or ROTGB_GetConVarValue("rotgb_cash_param"),ply)
					end
				end
			else
				_G[fname](tonumber(num) or ROTGB_GetConVarValue("rotgb_cash_param"))
			end
		end
	end
end

concommand.Add("rotgb_setcash",CreateCfunction("ROTGB_SetCash","rotgb_setcash"),nil,
[[Admin only command.
 - Sets the current amount of cash from input or the rotgb_cash_param ConVar.

 - Related commands:
 - rotgb_addcash
 - rotgb_subcash]])

concommand.Add("rotgb_addcash",CreateCfunction("ROTGB_AddCash","rotgb_addcash"),nil,
[[Admin only command.
 - Adds cash by input or the rotgb_cash_param ConVar.]])

concommand.Add("rotgb_subcash",CreateCfunction("ROTGB_RemoveCash","rotgb_subcash"),nil,
[[Admin only command.
 - Subtracts cash by input or the rotgb_cash_param ConVar.]])

RegisterConVar("rotgb_cash_mul","1",R_FLOAT,
[[Sets the cash multiplier.]])

RegisterConVar("rotgb_speed_mul","1",R_FLOAT,
[[Sets the gBalloon speed multiplier.]])

RegisterConVar("rotgb_health_multiplier","1",R_FLOAT,
[[Modifies health of gBalloons. This includes gBlimps.
 - See rotgb_blimp_health_multiplier to modify gBlimp health only.]])

RegisterConVar("rotgb_blimp_health_multiplier","1",R_FLOAT,
[[Modifies health of gBlimps only.
 - See rotgb_health_multiplier to modify all gBalloons' health.]])

RegisterConVar("rotgb_pop_on_contact","0",R_INT,
[[While a gBalloon travels, it may hit other entities in its path.
 - This option causes gBalloons to pop when colliding with:
 - 1 : Players.
 - 2 : Citizens/Rebels.
 - 4 : Combine troops.
 - 8 : Zombies.
 - 16 : Antlions.
 - 32 : Other HL2 NPCs.
 - 64 : SNPCs.
 - 128 : NextBots other than ourselves.
 - 256 : Props and destructibles that have health.

 - Note: You can combine the values above. "276" (4+16+256) will cause the gBalloons to pop when colliding with players, zombies and antlions.
 - -1 means any potential targets (see the 'rotgb_target_choice' ConVar).
 - -2 means Pop On Contact with All Entities That Have Health.]])

RegisterConVar("rotgb_use_custom_pathfinding","1",R_BOOL,
[[Causes gBalloons to use the custom pathfinding algorithm.
 - Disabling this option may drastically improve performance, but gBalloons will not obey func_nav_* entities and may cross over areas that were marked to be avoided.]])

RegisterConVar("rotgb_legacy_gballoons","0",R_BOOL,
[[Causes gBalloons to use the old no-effect models instead.]])

RegisterConVar("rotgb_pertain_effects","0",R_BOOL,
[[Only functional when Legacy Models are enabled (see the 'rotgb_legacy_gballoons' ConVar).
 - gBalloons will pertain rendering effects from the newer models.]])

RegisterConVar("rotgb_freeplay","1",R_BOOL,
[[Enables gBalloon Spawners to keep generating waves after the final wave is beaten.]])

RegisterConVar("rotgb_rainbow_gblimp_regen_rate","3",R_FLOAT,
[[Health healed by the Rainbow gBlimp per tick. 200 ticks occur every 3 seconds.]])

RegisterConVar("rotgb_afflicted_damage_multiplier","1",R_FLOAT,
[[Multiplier of damage dealt by the gBalloons when they hit something.]])

RegisterConVar("rotgb_tower_range_multiplier","1",R_FLOAT,
[[Multiplier for the towers' ranges.]])

RegisterConVar("rotgb_ignore_upgrade_limits","0",R_BOOL,
[[Causes towers to be fully upgradable on all paths.]])

RegisterConVar("rotgb_resist_effect_delay","1",R_FLOAT,
[[Sets the delay between "Resist!" text effects shown by the gBalloons.
 - A value of -1 disables the effect altogether.]])

RegisterConVar("rotgb_tower_maxcount","-1",R_INT,
[[Sets the maximum number of towers allowed.
 - A value of -1 disables this restriction.]])

RegisterConVar("rotgb_bloodtype","-1",R_INT,
[[Sets the blood type that gBalloons spew when hurt / killed. Default is -1 which is none.
 - Available values (taken from developer notes, may be inaccurate):
 - 0 : Red
 - 1 : Yellow
 - 2 : Green-Red
 - 3 : None, but emit sparks
 - 4 : Antlion
 - 5 : Zombie
 - 6 : Antlion Worker
 - 7 : VVV  SPECIALS  VVV
 - 8 : Splatoon Ink (broken? notes say the support is from 8-14, none appear to work)
 - 15 : VVV  CUSTOM  VVV
 - 16 : Custom, based on rotgb_blooddecal]])

RegisterConVar("rotgb_blooddecal","",R_STRING,
[[If rotgb_bloodtype is 16, this sets the decal material to leave. Possible types:
 - ]] .. table.concat(list.Get("PaintMaterials"),", ") .. ".")

RegisterConVar("rotgb_fire_delay","1",R_FLOAT,
[[Amount of time it takes for fire to damage a gBalloon.]])

RegisterConVar("rotgb_init_rate","-1",R_FLOAT,
[[Maximum number of gBalloons to enable AI per second.
 - A value of -1 means that gBalloons will always have their AI enabled upon spawn.]])

RegisterConVar("rotgb_notrails","0",R_BOOL,
[[Enabling this option will cause fast gBalloons to not have trails.]])
 
RegisterConVar("rotgb_use_custom_ai","0",R_BOOL,
[[Only functional when Custom Pathfinding is enabled (see the 'rotgb_use_custom_pathfinding' ConVar).
 - Causes gBalloons to use a completely custom AI for navigation.
 - This may increase performance but is otherwise EXPERIMENTAL. Use at your own risk.]])

RegisterConVar("rotgb_starting_cash","650",R_FLOAT,
[[Amount of starting cash every player gets.
 - Cash is reset upon leaving the server.]])

RegisterConVar("rotgb_crit_effect_delay","0",R_FLOAT,
[[Sets the delay between "Crit!" text effects shown by the gBalloons.
 - A value of -1 disables the effect altogether.]])

RegisterConVar("rotgb_use_kill_handler","0",R_BOOL,
[[Enabling this option will cause gBalloons to trigger on-kill effects when popped.]])

RegisterConVar("rotgb_use_achievement_handler","1",R_INT,
[[Enabling this option will cause popping gBalloons to count towards the Popper achievement.
 - If 2 and above, the achievement is incremented for each pop (which can cause massive lag). Otherwise multiple pops on the same gBalloon will only increment the achievement counter once.]])

RegisterConVar("rotgb_difficulty","1",R_FLOAT,
[[Sets the difficulty of RotgB.
 - Available values:
 - 0: Easy (x0.8 tower costs)
 - 1: Normal (x1.0 tower costs)
 - 2: Hard (x1.2 tower costs)
 - 3: Insane (x1.4 tower costs)
 
 - Note: The prices displayed in the spawnmenu are always the Normal difficulty prices due to the spawnmenu being static (names cannot be changed).]])

RegisterConVar("rotgb_tower_income_mul","1",R_FLOAT,
[[Similar to the 'rotgb_cash_mul' ConVar, but only affects tower-generated income.]])

RegisterConVar("rotgb_default_wave_preset","",R_STRING,
[[Newly-spawned gBalloon Spawners will have this wave preset. Default is "" which are the default waves.]])

RegisterConVar("rotgb_default_last_wave","120",R_INT,
[[Newly-spawned gBalloon Spawners will stop spawning more gBalloons after this wave, unless the rotgb_freeplay ConVar is enabled.]])

RegisterConVar("rotgb_default_first_wave","1",R_INT,
[[Newly-spawned gBalloon Spawners will start from this wave.]])

RegisterConVar("rotgb_target_health_override","0",R_FLOAT,
[[If above 0, all newly-spawned gBalloon Targets will start at this much health regardless of settings.]])

RegisterConVar("rotgb_tower_damage_others","0",R_BOOL,
[[If set, all towers will be able to damage non-gBalloon entities.]])

RegisterConVar("rotgb_target_natural_health","100",R_FLOAT,
[[Sets the "natural" health of gBalloon Targets. Only works if it isn't overridden by the map.]])

RegisterConVar("rotgb_tower_ignore_physgun","0",R_BOOL,
[[If set, towers cannot be moved by the Physics Gun.]])

concommand.Add("rotgb_reset_convars",function(ply,cmd,args,argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		for k,v in pairs(ROTGB_CVARS) do
			v[1]:Revert()
		end
		ROTGB_Log("All ConVars reset.", "")
	end
end,nil,
[[Admin only command.
 - Resets the value of all SERVERSIDE ConVars.]])

--[=[POP_PREDICTIONS = POP_PREDICTIONS or {}

concommand.Add("rotgb_popsave_clearcache",function(ply,cmd,args,argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		table.Empty(POP_PREDICTIONS)
		POP_PREDICTIONS.SCRIPT_CRC32 = PopSaveCRC32
		file.Delete("rotgb_pop_memory.dat")
	end
end,nil,
[[Admin only command.
 - Clears the pop result cache.]])]=]

local ticktime2 = 0

--[=[concommand.Add("rotgb_popsave_save",function(ply,cmd,args,argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		ticktime = 0
	end
end,nil,
[[Admin only command.
 - Saves the pop result cache.]])]=]

ROTGB_BLACKLIST = ROTGB_BLACKLIST or {}

ROTGB_WHITELIST = ROTGB_WHITELIST or {}

concommand.Add("rotgb_blacklist",function(ply,cmd,args,argStr)
	if (IsValid(ply) and ply:IsAdmin()) and SERVER then
		net.Start("rotgb_generic")
		net.WriteUInt(ROTGB_OPERATION_BLACKLIST, 8)
		net.WriteUInt(#ROTGB_BLACKLIST,32)
		for k,v in pairs(ROTGB_BLACKLIST) do
			net.WriteString(v[1])
			net.WriteUInt(v[2],8)
		end
		net.WriteUInt(#ROTGB_WHITELIST,32)
		for k,v in pairs(ROTGB_WHITELIST) do
			net.WriteString(v[1])
			net.WriteUInt(v[2],8)
		end
		net.Send(ply)
	end
end,nil,
[[Admin only command.
 - Opens the blacklist editor.]])

concommand.Add("rotgb_waveeditor",function(ply,cmd,args,argStr)
	if IsValid(ply) and SERVER then
		net.Start("rotgb_generic")
		net.WriteUInt(ROTGB_OPERATION_WAVE_EDIT, 8)
		net.Send(ply)
	end
end,nil,
[[Admin only command.
 - Opens the blacklist editor.]])

if SERVER then
	local reqgen
	local nextCashThink = 5
	local cashLoaded = false
	--util.AddNetworkString("NavmeshMissing")
	util.AddNetworkString("rotgb_generic")
	--[[net.Receive("NavmeshMissing",function()
		if not navmesh.IsLoaded() then
			reqgen = true
			--RunConsoleCommand("nav_quicksave","0")
			local spawnPoint = (GAMEMODE.SpawnPoints and GAMEMODE.SpawnPoints[1] or nil)
			if IsValid(spawnPoint) then
				navmesh.SetPlayerSpawnName(spawnPoint:GetClass())
				navmesh.BeginGeneration()
			else
				PrintMessage(HUD_PRINTTALK,"NavMesh Auto-Generation Failed! If you are not playing in Sandbox, switch to that and try again.")
				net.Start("NavmeshMissing")
				net.WriteBool(true)
				net.Broadcast()
			end
		end
	end)]]
	net.Receive("rotgb_generic",function(length, ply)
		local operation = net.ReadUInt(8)
		if operation == ROTGB_OPERATION_BLACKLIST and ply:IsAdmin() then
			ROTGB_BLACKLIST, ROTGB_WHITELIST = {}, {}
			for i=1, net.ReadUInt(32) do
				table.insert(ROTGB_BLACKLIST, {net.ReadString(), net.ReadUInt(8)})
			end
			for i=1, net.ReadUInt(32) do
				table.insert(ROTGB_WHITELIST, {net.ReadString(), net.ReadUInt(8)})
			end
			local other_data = util.JSONToTable(file.Read("rotgb_data.txt","DATA") or "") or {}
			other_data.blacklist = ROTGB_BLACKLIST
			other_data.whitelist = ROTGB_WHITELIST
			file.Write("rotgb_data.txt",util.TableToJSON(other_data))
		elseif operation == ROTGB_OPERATION_WAVE_TRANSFER and ply:IsAdmin() then
			ROTGB_WAVEPARTS = ROTGB_WAVEPARTS or {}
			local wavename, totalpackets, currentpacket, bytes = net.ReadString(), net.ReadUInt(16), net.ReadUInt(16), net.ReadUInt(16)
			local datachunk = net.ReadData(bytes)
			ROTGB_WAVEPARTS[wavename] = ROTGB_WAVEPARTS[wavename] or {}
			ROTGB_WAVEPARTS[wavename][currentpacket] = datachunk
			if #ROTGB_WAVEPARTS[wavename] == totalpackets then
				file.Write("rotgb_wavedata/"..wavename..".dat",table.concat(ROTGB_WAVEPARTS[wavename]))
				PrintMessage(HUD_PRINTTALK, "\""..wavename.."\" assembled successfully.")
			end
		elseif operation == ROTGB_OPERATION_TRANSFER then
			local ply2 = net.ReadEntity()
			if IsValid(ply2) and ply2:IsPlayer() and ply ~= ply2 then
				local transferAmount = ROTGB_GetTransferAmount(ply)
				ROTGB_AddCash(transferAmount, ply2)
				ROTGB_RemoveCash(transferAmount, ply)
			end
		end
	end)
	hook.Add("Think","RotgB",function()
		local initRate = ROTGB_GetConVarValue("rotgb_init_rate")
		if initRate>=0 and ticktime2 < CurTime() then
			ticktime2 = CurTime() + 1/initRate
			for k,v in pairs(ROTGB_GBALLOONS) do
				if IsValid(v) and not v.AIEnabled then
					v.AIEnabled = true
				end
			end
		end
		if nextCashThink < CurTime() then
			nextCashThink = CurTime() + 5
			if not cashLoaded then
				cashLoaded = true
				ROTGB_CASH = ROTGB_GetConVarValue("rotgb_starting_cash")
				ROTGB_UpdateCash()
			end
			for k,v in pairs(player.GetAll()) do
				if not v.ROTGB_cashLoaded then
					v.ROTGB_cashLoaded = true
					v.ROTGB_CASH = ROTGB_GetConVarValue("rotgb_starting_cash")
					ROTGB_UpdateCash(v)
				end
			end
		end
	end)
	hook.Add("InitPostEntity","RotgB",function()
		local other_data = util.JSONToTable(file.Read("rotgb_data.txt","DATA") or "") or {}
		if other_data.blacklist then
			ROTGB_BLACKLIST = other_data.blacklist
		end
		if other_data.whitelist then
			ROTGB_WHITELIST = other_data.whitelist
		end
	end)
end

local entitiestoconsider = {}

function ENT:KeyValue(key,value)
	self.Properties = self.Properties or {}
	self.Properties[key] = value
end

function ENT:AcceptInput(input,activator,caller,data)
	if input:lower()=="pop" then
		self:Pop(data or 0)
	elseif input:lower()=="stun" then
		self:Stun(data or 1)
	elseif input:lower()=="unstun" then
		self:UnStun()
	elseif input:lower()=="freeze" then
		self:Freeze(data or 1)
	elseif input:lower()=="unfreeze" then
		self:UnFreeze()
	end
end

function ENT:GetBalloonProperty(key)
	self.Properties = self.Properties or {}
	if not self.PropertyConverted then
		local useLegacy = ROTGB_GetConVarValue("rotgb_legacy_gballoons")
		local noTrails = ROTGB_GetConVarValue("rotgb_notrails")
		self.Properties.BalloonFast = tobool(self.Properties.BalloonFast)
		self.Properties.BalloonMoveSpeed = self.Properties.BalloonMoveSpeed or 100
		self.Properties.BalloonScale = self.Properties.BalloonScale or 1
		self.Properties.BalloonShielded = tobool(self.Properties.BalloonShielded)
		self.Properties.BalloonHealth = self.Properties.BalloonHealth or 1
		self.Properties.BalloonHealth = self.Properties.BalloonHealth or 1
		self.Properties.BalloonRainbow = tobool(self.Properties.BalloonRainbow)
		self.Properties.BalloonHidden = tobool(self.Properties.BalloonHidden)
		self.Properties.BalloonColor = self.Properties.BalloonColor or "255 255 255 127"
		self.Properties.BalloonMaterial = self.Properties.BalloonMaterial
			or useLegacy and self.Properties.BalloonShielded and "models/balloon/balloon_star"
			or self.Properties.BalloonRegen and "models/balloon/balloon_classicheart"
			or (useLegacy or noTrails) and self.Properties.BalloonFast and "models/balloon/balloon_dog"
			or "models/balloon/balloon"
		self.Properties.BalloonModel = self.Properties.BalloonModel
			or useLegacy and self.Properties.BalloonShielded and "models/balloons/balloon_star.mdl"
			or self.Properties.BalloonRegen and "models/balloons/balloon_classicheart.mdl"
			or (useLegacy or noTrails) and self.Properties.BalloonFast and "models/balloons/balloon_dog.mdl"
			or "models/maxofs2d/balloon_classic.mdl"
		self.Properties.BalloonPopSound = self.Properties.BalloonPopSound or "garrysmod/balloon_pop_cute.wav"
		self.Properties.BalloonType = self.Properties.BalloonType or "gballoon_red"
		self.Properties.BalloonBlack = tobool(self.Properties.BalloonBlack)
		self.Properties.BalloonWhite = tobool(self.Properties.BalloonWhite)
		self.Properties.BalloonPurple = tobool(self.Properties.BalloonPurple)
		self.Properties.BalloonGray = tobool(self.Properties.BalloonGray)
		self.Properties.BalloonAqua = tobool(self.Properties.BalloonAqua)
		self.Properties.BalloonBlimp = tobool(self.Properties.BalloonBlimp)
		self.Properties.BalloonRegen = tobool(self.Properties.BalloonRegen)
		self.Properties.BalloonVoid = tobool(self.Properties.BalloonVoid)
		self.Properties.BalloonGlass = tobool(self.Properties.BalloonGlass)
		self.PropertyConverted = true
	end
	return tonumber(self.Properties[key]) or self.Properties[key]
end

function ENT:SpawnFunction(ply,trace,classname)
	if not trace.Hit then return end

	local ent = ents.Create(classname)
	ent:SetPos(trace.HitPos+self:GetBalloonProperty("BalloonScale")*10*trace.HitNormal)
	ent:SetCreator(ply)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:RegistergBalloon()
	ROTGB_GBALLOONS[self:EntIndex()] = self
end

function ROTGB_GetBalloons()
	for k,v in pairs(ROTGB_GBALLOONS) do
		if not IsValid(v) then ROTGB_GBALLOONS[k] = nil end
	end
	return table.ClearKeys(ROTGB_GBALLOONS)
end

function ROTGB_GetBalloonCount()
	for k,v in pairs(ROTGB_GBALLOONS) do
		if not IsValid(v) then ROTGB_GBALLOONS[k] = nil end
	end
	return table.Count(ROTGB_GBALLOONS)
end

local function HasAllBits(a,b)
	return bit.band(a,b)==b
end

local notifshown

function ENT:Initialize()
	self:RegistergBalloon()
	if SERVER then
		local failslist
		for k,v in pairs(ROTGB_BLACKLIST) do
			if v[1] == "gballoon_*" or self:GetBalloonProperty("BalloonBlimp") and v[1] == "gballoon_blimp_*" or self:GetBalloonProperty("BalloonType") == v[1] then
				local bitcondition = Either(self:GetBalloonProperty("BalloonFast"), HasAllBits(v[2],1), HasAllBits(v[2],2))
				bitcondition = bitcondition or Either(self:GetBalloonProperty("BalloonHidden"), HasAllBits(v[2],4), HasAllBits(v[2],8))
				bitcondition = bitcondition or Either(self:GetBalloonProperty("BalloonRegen"), HasAllBits(v[2],16), HasAllBits(v[2],32))
				bitcondition = bitcondition or Either(self:GetBalloonProperty("BalloonShielded"), HasAllBits(v[2],64), HasAllBits(v[2],128))
				
				if bitcondition then
					failslist = true
				end
			end
		end
		if failslist then
			for k,v in pairs(ROTGB_WHITELIST) do
				if v[1] == "gballoon_*" or self:GetBalloonProperty("BalloonBlimp") and v[1] == "gballoon_blimp_*" or self:GetBalloonProperty("BalloonType") == v[1] then
					local bitcondition = Either(self:GetBalloonProperty("BalloonFast"), HasAllBits(v[2],1), HasAllBits(v[2],2))
					bitcondition = bitcondition or Either(self:GetBalloonProperty("BalloonHidden"), HasAllBits(v[2],4), HasAllBits(v[2],8))
					bitcondition = bitcondition or Either(self:GetBalloonProperty("BalloonRegen"), HasAllBits(v[2],16), HasAllBits(v[2],32))
					bitcondition = bitcondition or Either(self:GetBalloonProperty("BalloonShielded"), HasAllBits(v[2],64), HasAllBits(v[2],128))
					
					if bitcondition then
						failslist = false
					end
				end
			end
			if failslist then
				return self:Remove()
			end
		end
		if not (navmesh.IsLoaded() or notifshown) and game.SinglePlayer() then
			PrintMessage(HUD_PRINTTALK, "No NavMesh found! Please generate one first!")
			notifshown = true
		end
		--self:SetLocalPos(Vector(0,0,10))
		local model = self:GetBalloonProperty("BalloonModel")
		if not model then
			self.PropertyConverted = false
			model = self:GetBalloonProperty("BalloonModel")
		end
		self:SetModel(model)
		self:SetModelScale(self:GetBalloonProperty("BalloonScale")*ROTGB_GetConVarValue("rotgb_scale"))
		local desiredCol = self:GetBalloonProperty("BalloonRainbow") and Color(255,255,255) or string.ToColor(self:GetBalloonProperty("BalloonColor"))
		if self:GetBalloonProperty("BalloonHidden") then
			self:SetNWBool("BalloonHidden",true)
			desiredCol.a = 0
			self:SetRenderFX(kRenderFxHologram)
		end
		self:SetColor(desiredCol)
		self:SetMaterial(self:GetBalloonProperty("BalloonMaterial"))
		local hp = math.Round(
			self:GetBalloonProperty("BalloonHealth")
			*(self:GetBalloonProperty("BalloonShielded") and 2 or 1)
			*(self:GetBalloonProperty("BalloonBlimp") and ROTGB_GetConVarValue("rotgb_blimp_health_multiplier") or 1)
			*ROTGB_GetConVarValue("rotgb_health_multiplier")
		)
		if self.SetHealth then
			self:SetMaxHealth(hp)
			self:SetHealth(hp)
		else
			self:LogError("gBalloon health is bugged out!","damage")
		end
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
		self:SetBloodColor(ROTGB_GetConVarValue("rotgb_bloodtype")<7 and ROTGB_GetConVarValue("rotgb_bloodtype") or DONT_BLEED)
		--[=[if not IsValid(self.Attractor) then
			local filterbits = 0
			self.Attractor = ents.Create("npc_bullseye")
			self.Attractor:SetPos(self:GetPos())
			self.Attractor:SetParent(self)
			self.Attractor:SetModelScale(self:GetModelScale())
			self.Attractor:SetHealth(self:Health()*10)
			self.Attractor:SetMaxHealth(self:GetMaxHealth()*10)
			if self:GetBalloonProperty("BalloonBlack") then filterbits = filterbits+DMG_BLAST+DMG_BLAST_SURFACE end
			if self:GetBalloonProperty("BalloonWhite") then filterbits = filterbits+DMG_DROWN+DMG_PARALYZE end
			if self:GetBalloonProperty("BalloonPurple") then filterbits = filterbits+DMG_BURN+DMG_SHOCK+DMG_ENERGYBEAM+DMG_REMOVENORAGDOLL+DMG_PLASMA+DMG_DISSOLVE end
			if self:GetBalloonProperty("BalloonGray") then filterbits = filterbits+DMG_BULLET+DMG_SLASH+DMG_BUCKSHOT end
			if self:GetBalloonProperty("BalloonAqua") then filterbits = filterbits+DMG_CRUSH+DMG_VEHICLE+DMG_FALL+DMG_CLUB+DMG_PHYSGUN end
			if filterbits > 0 and not (ROTGB_GetConVarValue("rotgb_ignore_damage_resistances") or self:HasRotgBStatusEffect("unimmune")) then
				self.Attractor.Filter = ents.Create("filter_damage_type")
				self.Attractor.Filter:SetKeyValue("damagetype",filterbits)
				self.Attractor.Filter:SetKeyValue("Negated",1)
				self.Attractor.Filter:SetName(self:GetCreationID().."_attractor_filter")
				self.Attractor.Filter:Spawn()
				self.Attractor.Filter:Activate()
				self.Attractor.Filter.From_gBalloons = true
				self.Attractor:SetKeyValue("damagefilter",self.Attractor.Filter:GetName())
			end
			self.Attractor:Spawn()
			self.Attractor:Activate()
			self.Attractor.From_gBalloons = true
			--[[local physobj = self.Attractor:GetPhysicsObject()
			if IsValid(physobj) then
				physobj:AddGameFlag(FVPHYSICS_CONSTRAINT_STATIC)
			end]]
			self.Attractor:AddRelationship("player D_HT 30")
			self.Attractor:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			--self.Attractor:SetNotSolid(true)
			self:DeleteOnRemove(self.Attractor)
			--[[self.Attractor:CallOnRemove("pop_self",function(att)
				if IsValid(self) then
					self:SetHealth(0)
					self:Pop(0)
				end
			end)]]
		end]=]
		local pertainEffects = ROTGB_GetConVarValue("rotgb_pertain_effects")
		local useLegacy = ROTGB_GetConVarValue("rotgb_legacy_gballoons")
		if self:GetBalloonProperty("BalloonPurple") and not (self:GetBalloonProperty("BalloonHidden") or useLegacy and not pertainEffects) then
			self:SetNWBool("BalloonPurple",true)
		end
		if self:GetBalloonProperty("BalloonShielded") and self:Health()*2>self:GetMaxHealth() and (not useLegacy or pertainEffects) then
			self:SetNWBool("RenderShield",true)
		end
		if self:GetBalloonProperty("BalloonFast") and not (useLegacy and not pertainEffects or ROTGB_GetConVarValue("rotgb_notrails")) then
			if IsValid(self.FastTrail) then self.FastTrail:Remove() end
			local col = self:GetBalloonProperty("BalloonRainbow") and Color(255,255,255) or string.ToColor(self:GetBalloonProperty("BalloonColor"))
			col.a = self:GetBalloonProperty("BalloonHidden") and col.a/4 or col.a
			self.FastTrail = util.SpriteTrail(self,0,col,false,self:BoundingRadius()*2,0,1,0.125,self:GetBalloonProperty("BalloonRainbow") and "beams/rainbow1.vmt" or "effects/beam_generic01.vmt")
		end
		--self:AddRelationship("player D_HT 30")
		local mask = ROTGB_GetConVarValue("rotgb_target_choice")
		for k,v in pairs(ents.GetAll()) do
			if v:IsNPC() then
				if mask<0 and v:Health()>0 and v:GetClass()~="gballoon_base" then
					v:AddEntityRelationship(self,D_HT,99)
					--v:AddRelationship("!self D_HT 98")
				elseif self:MaskFilter(mask,v) then
					v:AddEntityRelationship(self,D_HT,99)
					--v:AddRelationship("!self D_HT 98")
				end
			end
		end
		self:AddFlags(FL_OBJECT)
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:AddGameFlag(FVPHYSICS_CONSTRAINT_STATIC)
		end
		--self.BeaconsReached = {}
	end
	if CLIENT then
		local matrix = Matrix()
		self.VModelScale = Vector(1,1,1)
		self.VModelScale:Mul(ROTGB_GetConVarValue("rotgb_visual_scale"))
		matrix:Scale(self.VModelScale)
		self:EnableMatrix("RenderMultiply",matrix)
	end
end

function ENT:PostEntityPaste(ply,ent,tab)
	ent:Spawn()
	ent:Activate()
end

--[[function ENT:SetMaxHealth(num)
	self:SetNWInt("MaxHealth",num)
end
function ENT:GetMaxHealth(num)
	self:GetNWInt("MaxHealth",0)
end

function ENT:SetHealth(num)
	self:SetNWInt("Health",num)
end
function ENT:Health(num)
	self:GetNWInt("Health",0)
end]]

--start of custom pathfinding

local MAX_CORNER_DISTANCE = 64

function ENT:GenerateDotsFromArea(area)
	-- Generates a vector table, a corners table and an attributes number from a CNavArea.
	local vectors, corners = {}, {}
	table.insert(vectors, area:GetCenter())
	for i=0,3 do
		table.insert(vectors, area:GetCorner(i))
		table.insert(corners, area:GetCorner(i))
	end
	-- table has 1+4
	for i=2,5 do
		if i==5 then
			table.insert(vectors, (vectors[5] + vectors[2])/2)
		else
			table.insert(vectors, (vectors[i] + vectors[i+1])/2)
		end
	end
	-- table has 1+4+4
	local maxcornerdist_sqr, corner_dist_sqr = MAX_CORNER_DISTANCE*MAX_CORNER_DISTANCE
	if IsValid(area) then -- it is rectangular
		corner_dist_sqr = vectors[1]:DistToSqr(vectors[2])
	else
		for i=2,5 do
			corner_dist_sqr = math.max( corner_dist_sqr, vectors[1]:DistToSqr(vector[i]) )
		end
	end
	if corner_dist_sqr>maxcornerdist_sqr then
		local partitions = math.ceil( math.sqrt(corner_dist_sqr/maxcornerdist_sqr) )
		for i=2,9 do
			for j=1,partitions-1 do
				table.insert(vectors, ((partitions-j)*vectors[1] + j*vectors[i])/partitions)
			end
		end
	end
	return vectors, corners, area:GetAttributes()
end

function ENT:MakeDotStruct(dotstoattribs,dotsfrom,dotsto)
	local dotstruct = {}
	if not dotsto then dotsto = dotsfrom end
	for k,v in pairs(dotsfrom) do
		dotstruct[v] = {}
		for k2,v2 in pairs(dotsto) do
			if v ~= v2 then
				dotstruct[v][v2] = {v:Distance(v2),dotstoattribs}
			end
		end
	end
	return dotstruct
end

function ENT:GetVectorsOnBorder(vecs,corners)
	local dirs = {}
	local newvectors = {}
	for i=1,4 do
		local newvec
		if i==4 then
			newvec = corners[4] - corners[1]
			newvec:Normalize()
		else
			newvec = corners[i] - corners[i+1]
			newvec:Normalize()
		end
		table.insert(dirs, newvec)
		table.insert(dirs, -newvec)
	end
	for k,v in pairs(vecs) do
		for i=1,7,2 do
			local dir = v - corners[(i+1)/2]
			dir:Normalize()
			if dir == dirs[i] then
				if i==7 then
					dir = v - corners[1]
				else
					dir = v - corners[(i+3)/2]
				end
				dir:Normalize()
				if dir == dirs[i+1] then
					table.insert(newvectors, v)
				end
			end
		end
	end
	return newvectors
end

function ENT:GetClosestVectorPair(dotstruct1,dotstruct2)
	local data = {}
	for vec,_ in pairs(dotstruct1) do
		for vec2,_ in pairs(dotstruct2) do
			if vec ~= vec2 then
				table.insert(data, {vec,vec2,vec:DistToSqr(vec2)})
			end
		end
	end
	table.SortByMember(data, 3, true)
	return data[1][1], data[1][2]
end

function ENT:BuildDotMesh()
	dotmeshes, dotmesh = {}, {}
	local navspecificmeshes = {}
	local navspecificcorners = {}
	for k,v in pairs(navmesh.GetAllNavAreas()) do
		local vectors, corners, attribs = self:GenerateDotsFromArea(v)
		navspecificmeshes[v:GetID()] = self:MakeDotStruct(attribs, vectors)
		navspecificcorners[v:GetID()] = corners
		table.insert(dotmeshes, navspecificmeshes[v:GetID()])
	end
	for k,v in pairs(navmesh.GetAllNavAreas()) do
		for k2,v2 in pairs(v:GetAdjacentAreas()) do
			local directjoinvectors = self:GetVectorsOnBorder(table.GetKeys(navspecificmeshes[v:GetID()]), navspecificcorners[v2:GetID()])
			if table.IsEmpty(directjoinvectors) then
				local dot1, dot2 = self:GetClosestVectorPair(navspecificmeshes[v:GetID()], navspecificmeshes[v2:GetID()])
				table.insert(dotmeshes, self:MakeDotStruct(v2:GetAttributes(), {dot1}, {dot2}))
			else
				table.insert(dotmeshes, self:MakeDotStruct(v2:GetAttributes(), directjoinvectors, navspecificmeshes[v2:GetID()]))
			end
		end
	end
	for k,v in pairs(dotmeshes) do
		table.Merge(dotmesh,v)
	end
	return dotmesh
end

function ENT:CreatePathFromPrecedents(pathPrecedents, pathProperties, last)
	local path_points = {}
	table.insert(path_points, last)
	while pathPrecedents[last] do
		local next_node = pathPrecedents[last]
		pathPrecedents[last] = nil
		table.insert(path_points, next_node)
		last = next_node
	end
	path_points = table.Reverse(path_points)
	path_points.checks = pathProperties
	return path_points
end

local NAV_MESH_PREFER = 1048576
function ENT:CalculatePath(dotmesh,first,last)
	local pathPrecedents, pathBlocks = {}, {}
	local distancecosts,totalcosts = {[first]=0},{[first]=first:DistToSqr(last)}
	local openSet = {[first]=-totalcosts[first]}
	local supptab = {}
	while next(openSet) do
		local current = table.GetWinningKey(openSet)
		openSet[current] = nil
		if current == last then
			return self:CreatePathFromPrecedents(pathPrecedents, pathBlocks, last)
		else
			for k,v in pairs(dotmesh[current] or {}) do
				local distancecost = v[1]
				if pathBlocks[k]~=NAV_MESH_TRANSIENT and bit.band(v[2],bit.bor(NAV_MESH_TRANSIENT,NAV_MESH_HAS_ELEVATOR))~=0 then
					util.TraceLine({
						start = k,
						endpos = k+vector_up*self:BoundingRadius(),
						filter = self,
						mask = MASK_NPCSOLID,
						ignoreworld = true,
						output = supptab
					})
					if supptab.Hit then
						pathBlocks[k] = NAV_MESH_TRANSIENT
						continue
					end
				end
				if bit.band(v[2],bit.bor(NAV_MESH_AVOID))~=0 then
					distancecost = distancecost * 1e6
				end
				for k2,v2 in pairs(entitiestoconsider) do
					if IsValid(k2) then
						self:Log(tostring(k2).." sensed. Position: "..tostring(k)..", Vector1:"..tostring(v2[1])..", Vector2:"..tostring(v2[2])..", InPosition="..tostring(pos:WithinAABox(v2[1],v2[2])),"func_nav_detection")
						if k:WithinAABox(v2[1],v2[2]) and k2.Enabled then
							if k2:GetClass()=="func_nav_avoid" then
								distancecost = distancecost * 1e6
								pathBlocks[k] = NAV_MESH_AVOID
								self:Log("Detected "..tostring(k2).." and avoiding, cost to cross is now "..distancecost,"func_nav_detection") break
							elseif k2:GetClass()=="func_nav_prefer" then
								distancecost = distancecost * 1e-6
								pathBlocks[k] = NAV_MESH_PREFER
								self:Log("Detected "..tostring(k2).." and preferring, cost to cross is now "..distancecost,"func_nav_detection") break
							end
						end
					else
						entitiestoconsider[k2] = nil
					end
				end
				local totaldistancecost = distancecosts[current] + distancecost
				if not (distancecosts[k] and totaldistancecost >= distancecosts[k]) then
					pathPrecedents[k] = current
					--pathProperties[k] = v[2]
					distancecosts[k] = totaldistancecost
					totalcosts[k] = totaldistancecost + k:DistToSqr(last)
					openSet[k] = -totalcosts[k]
				end
			end
		end
	end
	return {checks=pathBlocks}
end

function ENT:BlocksStillPresent(navs_to_check)
	for vec,property in pairs(navs_to_check) do
		if property == NAV_MESH_TRANSIENT then
			util.TraceLine({
				start = vec,
				endpos = vec+vector_up*self:BoundingRadius(),
				filter = self,
				mask = MASK_NPCSOLID,
				ignoreworld = true,
				output = supptab
			})
			if not supptab.Hit then return false end
		elseif property == NAV_MESH_AVOID or property == NAV_MESH_PREFER then
			for k2,v2 in pairs(entitiestoconsider) do
				if (IsValid(k2) and k2.Enabled) then
					if vec:WithinAABox(v2[1],v2[2]) then
						if k2:GetClass()=="func_nav_avoid" and property==NAV_MESH_AVOID then break
						elseif k2:GetClass()=="func_nav_prefer" and property==NAV_MESH_PREFER then break
						else return false
						end
					end
				else
					if not IsValid(k2) then
						entitiestoconsider[k2] = nil
					end
					return false
				end
			end
		end
	end
	return true
end

function ENT:CopyPathCarbon(original_path)
	local new_path = {}
	for i,v in ipairs(original_path) do
		new_path[i] = v
	end
	return new_path
end

function ENT:GetSavedPath(actualfirst,actuallast)
	return ((ROTGB_SAVEDPATHS or {})[actualfirst] or {})[actuallast]
end

function ENT:SavePath(new_path,actualfirst,actuallast)
	ROTGB_SAVEDPATHS = ROTGB_SAVEDPATHS or {}
	ROTGB_SAVEDPATHS[actualfirst] = ROTGB_SAVEDPATHS[actualfirst] or {}
	ROTGB_SAVEDPATHS[actualfirst][actuallast] = new_path
end

function ENT:GeneratePath(dotmesh,first,last)
	local actualfirst, min_distance = first, math.huge
	for k,v in pairs(dotmesh) do
		if k:DistToSqr(first) < min_distance then
			min_distance = k:DistToSqr(first)
			actualfirst = k
		end
	end
	min_distance = math.huge
	local actuallast = last
	for k,v in pairs(dotmesh) do
		if k:DistToSqr(last) < min_distance then
			min_distance = k:DistToSqr(last)
			actuallast = k
		end
	end
	local saved_path = self:GetSavedPath(actualfirst,actuallast)
	if saved_path and self:BlocksStillPresent(saved_path.checks) then
		self.GeneratedPath = self:CopyPathCarbon(saved_path)
		self.GeneratedPathTimestamp = CurTime()
	else
		local new_path = self:CalculatePath(dotmesh,actualfirst,actuallast)
		self:SavePath(new_path,actualfirst,actuallast)
		self.GeneratedPath = self:CopyPathCarbon(new_path)
		self.GeneratedPathTimestamp = CurTime()
	end
end

function ENT:InchCloser()
	if self:GetPos():DistToSqr(self.GeneratedPath[1]) < MAX_CORNER_DISTANCE*MAX_CORNER_DISTANCE then
		table.remove(self.GeneratedPath,1)
		if table.IsEmpty(self.GeneratedPath) then
			self.GeneratedPath = nil return
		end
	end
	local movdir = self.GeneratedPath[1]-self:GetPos()
	movdir:Normalize()
	self.loco:Approach(self.GeneratedPath[1],1)
	self.loco:SetVelocity(movdir*self.DesiredSpeed)
end

function ENT:MoveToTargetNew()
	--coroutine.wait(0.05*ROTGB_GetConVarValue("rotgb_path_delay")*ROTGB_GetBalloonCount())
	--[[local path = Path("Chase")
	local position = self:GetTarget():GetPos()
	path:SetGoalTolerance(ROTGB_GetConVarValue("rotgb_target_tolerance"))
	path:SetMinLookAheadDistance(ROTGB_GetConVarValue("rotgb_setminlookaheaddistance"))]]
	if not ROTGB_DOT_MESH then
		local waitamt = SysTime()
		ROTGB_DOT_MESH = self:BuildDotMesh()
		self:Log("Generated DotMesh in "..SysTime()-waitamt.." seconds.","pathfinding")
	end
	local position = self:GetTarget():GetPos()
	local waitamt = SysTime()
	self:GeneratePath(ROTGB_DOT_MESH,self:GetPos(),position)
	waitamt = SysTime()-waitamt
	waitamt = math.max(waitamt*ROTGB_GetBalloonCount()*ROTGB_GetConVarValue("rotgb_path_delay"),0.5)
	self:Log("Regenerated pathway. Recomputing in "..waitamt.." seconds...","pathfinding")
	--self.RecheckPath = true
	if not self.GeneratedPath then return "Failed to find a path." end
	--local supptab = {}
	--[[for k,v in pairs(path:GetAllSegments()) do
		if v.area:HasAttributes(NAV_MESH_TRANSIENT) then
			util.TraceLine({
				start = v.area:GetCenter(),
				endpos = v.area:GetCenter()+vector_up*self:BoundingRadius(),
				filter = self,
				mask = MASK_NPCSOLID,
				ignoreworld = true,
				output = supptab
			})
			if supptab.Hit then
				return "Transient NavMesh #"..v.area:GetID().." should not be crossed! Abort!"
			end
		end
	end]]
	while self.GeneratedPath and IsValid(self:GetTarget()) and not GetConVar("ai_disabled"):GetBool() do
		--[[if self:GetTarget():GetPos():DistToSqr(position)>ROTGB_GetConVarValue("rotgb_target_tolerance")^2 or CurTime()-self.GeneratedPathTimestamp>waitamt then
			self.RecheckPath = nil
			position = self:GetTarget():GetPos()
			waitamt = SysTime()
			self:ComputePathWrapper(path,position)
			waitamt = SysTime()-waitamt
			waitamt = math.max(waitamt*ROTGB_GetBalloonCount()*ROTGB_GetConVarValue("rotgb_path_delay"),0.5)
			self:Log("Regenerated pathway. Recomputing in "..waitamt.." seconds...","pathfinding")
		end]]
		if string.find(ROTGB_GetConVarValue("rotgb_debug"),"pathfinding") then
			--path:Draw()
		end
		local firstPos = self:GetPos()
		if not self:IsStunned() then
			self:InchCloser()
			--path:Chase(self,self:GetTarget())
		end
		--[[if not self.GeneratedPath and (IsValid(self:GetTarget()) and not navmesh.GetNearestNavArea(self:GetPos()):HasAttributes(NAV_MESH_STOP) and self:GetTarget():GetPos():DistToSqr(self:GetPos()) > ROTGB_GetConVarValue("rotgb_target_tolerance")^2*2.25) then
			self:LogError("Temporarily lost track! Using stock pathfinding...","pathfinding")
			self.correcting = true
			path = Path("Chase")
			path:SetGoalTolerance(ROTGB_GetConVarValue("rotgb_target_tolerance"))
			path:SetMinLookAheadDistance(ROTGB_GetConVarValue("rotgb_setminlookaheaddistance"))
			path:Compute(self,self:GetTarget():GetPos())
			path:Chase(self,self:GetTarget())
		end]]
		if --[[self.loco:IsStuck() or]] self.GeneratedPath and (self.WallStuck or 0)>=4 and not self:IsStunned() then
			self.WallStuck = nil
			if (self.ResetStuck or 0) < CurTime() then
				self.UnstuckAttempts = 0
			end
			self.UnstuckAttempts = self.UnstuckAttempts + 1
			self.ResetStuck = CurTime() + 30
			if self.UnstuckAttempts == 1 then
				self.loco:Jump()
			elseif self.UnstuckAttempts == 2 then
				self:SetPos(self:GetPos()+vector_up*20)
			else -- If not, just teleport us ahead on the path. (Sanic method)
				self.LastStuck = CurTime()
				local dir = self.GeneratedPath[1]-self:GetPos()
				local deltasqr = 2^self.UnstuckAttempts
				local lengthsqr = dir:LengthSqr()
				if lengthsqr <= deltasqr then
					self:SetPos(self.GeneratedPath[1])
				else
					dir:Mul(math.sqrt(deltasqr/lengthsqr))
					self:SetPos(self:GetPos()+dir)
				end
			end
			return "Got stuck for the "..self.UnstuckAttempts..STNDRD(self.UnstuckAttempts).." time!"
		end
		self:CheckForRegenAndFire()
		self:CheckForSpeedMods()
		self:PerformPops()
		coroutine.yield()
		firstPos:Sub(self:GetPos())
		local cdd = firstPos:Length()
		self.TravelledDistance = (self.TravelledDistance or 0) + cdd
		if cdd==0 and not (self:IsStunned() or navmesh.GetNearestNavArea(self:GetPos()):HasAttributes(NAV_MESH_STOP)) then
			self.WallStuck = (self.WallStuck or 0) + 1
			self:LogError("Stuck in a wall, "..self.WallStuck*25 .."% sure.","pathfinding")
			if self.WallStuck>=4 then
				self:LogError("Definitely stuck! Waiting for HandleStuck...","pathfinding")
			end
		else
			self.WallStuck = nil
		end
	end
	if not IsValid(self:GetTarget()) then
		return "Lost its target."
	end
	return "Completely lost track!!"
end

--end of custom pathfinding

function ENT:SetTarget(ent)
	if isentity(ent) then
		self.Target = ent
	else
		self.Target = NULL
	end
end

function ENT:GetTarget()
	if self:CanTarget(self.Target) then
		return self.Target
	else return NULL
	end
end

function ENT:MaskFilter(mask,ent)
	if ent:IsNPC() then
		local entclass = ent:Classify()
		if HasAllBits(mask,2) and (entclass==CLASS_PLAYER_ALLY or entclass==CLASS_PLAYER_ALLY_VITAL or entclass==CLASS_CITIZEN_PASSIVE or entclass==CLASS_CITIZEN_REBEL or entclass==CLASS_VORTIGAUNT or entclass==CLASS_HACKED_ROLLERMINE) then return true
		elseif HasAllBits(mask,4) and (entclass==CLASS_COMBINE or entclass==CLASS_COMBINE_GUNSHIP or entclass==CLASS_MANHACK or entclass==CLASS_METROPOLICE or entclass==CLASS_MILITARY or entclass==CLASS_SCANNER or entclass==CLASS_STALKER or entclass==CLASS_PROTOSNIPER or entclass==CLASS_COMBINE_HUNTER) then return true
		elseif HasAllBits(mask,8) and (entclass==CLASS_HEADCRAB or entclass==CLASS_ZOMBIE) then return true
		elseif HasAllBits(mask,16) and (entclass==CLASS_ANTLION) then return true
		elseif HasAllBits(mask,32) and (entclass==CLASS_BARNACLE or entclass==CLASS_BULLSEYE or entclass==CLASS_CONSCRIPT or entclass==CLASS_MISSILE or entclass==CLASS_FLARE or entclass==CLASS_EARTH_FAUNA or entclass>25) then return true
		elseif HasAllBits(mask,64) and ent:IsScripted() then return true
		end
	elseif HasAllBits(mask,1) and ent:IsPlayer() and (ent:OnGround() or math.abs(ent:GetPos().z - (navmesh.GetGroundHeight(ent:GetPos()) or math.huge))<ROTGB_GetConVarValue("rotgb_target_tolerance")*0.9) and not GetConVar("ai_ignoreplayers"):GetBool() then return true
	elseif HasAllBits(mask,128) and ent:Health()>0 and ent.RunBehaviour and ent:GetClass()~="gballoon_base" then return true
	elseif HasAllBits(mask,256) and ent:Health()>0 and not ent.RunBehaviour then return true
	end
	return false
end

function ENT:CanTarget(ent)
	if not (isentity(ent) and IsValid(ent)) then return false end
	if ent:GetClass()=="gballoon_target" then return not (ent:GetIsBeacon() and self.LastBeacon == ent) end
	local mask = ROTGB_GetConVarValue("rotgb_target_choice")
	if mask<0 and ent:Health()>0 and ent:GetClass()~="gballoon_base" then return true end
	return self:MaskFilter(mask,ent)
end

function ENT:FindTarget()
	local ourPos = self:GetPos()
	local searchSize = ROTGB_GetConVarValue("rotgb_search_size")
	local entis = searchSize<0 and ents.GetAll() or ents.FindInSphere(ourPos,searchSize)
	local resulttabs = {}
	self:Log("We are considering the following: "..util.TableToJSON(table.Sanitise(entis),true),"targeting")
	for k,v in pairs(entis) do
		if self:CanTarget(v) then
			self:Log("We can target "..tostring(v)..". Attempting to build a path...","targeting")
			local path = Path("Chase")
			local position = v:GetPos()
			path:SetGoalTolerance(ROTGB_GetConVarValue("rotgb_target_tolerance"))
			path:SetMinLookAheadDistance(ROTGB_GetConVarValue("rotgb_setminlookaheaddistance"))
			if ROTGB_GetConVarValue("rotgb_use_custom_pathfinding") then
				self:ComputePathWrapper(path,position)
			else
				path:Compute(self,position)
			end
			if IsValid(path) then
				local isTarget = v:GetClass()=="gballoon_target"
				local targetSorting = ROTGB_GetConVarValue("rotgb_target_sort")
				--[[if IsValid(self.Attractor) and v:IsNPC() then
					self.Attractor:AddEntityRelationship(v,D_HT,4)
					v:AddEntityRelationship(self.Attractor,D_HT,4)
					v:AddEntityRelationship(self,D_HT,4)
				end]]
				if targetSorting==-1 then
					resulttabs[v] = math.random()
				elseif targetSorting==0 then
					resulttabs[v] = -v:GetPos():DistToSqr(ourPos)+math.random()
				elseif targetSorting==1 then
					resulttabs[v] = v:GetPos():DistToSqr(ourPos)+math.random()
				elseif targetSorting==2 then
					resulttabs[v] = v:Health()+math.random()
				elseif targetSorting==3 then
					resulttabs[v] = -v:Health()+math.random()
				end
				if isTarget then resulttabs[v] = resulttabs[v] + 1e10 * (v:GetWeight() + 1) end
				self:Log("Targeted "..tostring(v).." with priority "..resulttabs[v]..".","targeting")
			else
				self:LogError("Couldn't build a path! Discarding current target.","targeting")
			end
		--[[elseif IsValid(self.Attractor) and v:IsNPC() then
			self.Attractor:AddEntityRelationship(v,D_LI,4)
			v:AddEntityRelationship(self.Attractor,D_LI,4)
			v:AddEntityRelationship(self,D_LI,4)]]
		end
	end
	if next(resulttabs) then
		self:SetTarget(table.GetWinningKey(resulttabs))
		self:Log("Set our target to "..tostring(self:GetTarget()),"targeting")
		return true
	else return false
	end
end

function ENT:ComputePathWrapper(path,pos)
	local sttime = SysTime()
	self:Log("Path Computation Started!","pathfinding")
	local supptab,igids = {},{}
	for k,v in pairs(navmesh.GetAllNavAreas()) do
		if v:HasAttributes(NAV_MESH_TRANSIENT) then
			util.TraceLine({
				start = v:GetCenter(),
				endpos = v:GetCenter()+vector_up*self:BoundingRadius(),
				filter = self,
				mask = MASK_NPCSOLID,
				ignoreworld = true,
				output = supptab
			})
			if supptab.Hit then
				self:Log("Transient NavMesh #"..v:GetID().." should not be crossed!","pathfinding")
				igids[v:GetID()] = true
			end
		end
	end
	local function ComputePath(nextArea,prevArea,ladder,elevator,length)
		if not IsValid(prevArea) then return 0
		else
			local isJump = nextArea:HasAttributes(NAV_MESH_JUMP)
			if not self.loco:IsAreaTraversable(nextArea) then
				return -1
			else
				local height = prevArea:ComputeAdjacentConnectionHeightChange(nextArea)
				if height > self.loco:GetStepHeight() then
					if height <= self.loco:GetMaxJumpHeight() then
						isJump = true
					else
						return -1
					end
				elseif height <= -self.loco:GetDeathDropHeight() then
					return -1
				end
			end
			if nextArea:HasAttributes(NAV_MESH_TRANSIENT) and igids[nextArea:GetID()] then
				return -1
			end

			local dist = 0
			if IsValid(ladder) then
				dist = ladder:GetLength()
			elseif length > 0 then
				dist = length
			elseif nextArea:GetCenter() and prevArea:GetCenter() then
				dist = (nextArea:GetCenter()-prevArea:GetCenter()):Length()
			end
			if nextArea:HasAttributes(NAV_MESH_AVOID) then
				dist = dist * 1000000
			elseif isJump and not nextArea:HasAttributes(NAV_MESH_STAIRS) then
				dist = dist * 1000
			end
			--local brushStat
			--local obeyCount = 0
			--[[ for i=0,3 do
				local pos = nextArea:GetCorner(i)
				for k,v in pairs(ents.FindInSphere(pos,30)) do
					if i==0 then
						if v:GetClass()=="func_nav_avoid" and v.Enabled then
							-- print("AVOID: 0")
							brushStat = "avoid" break
						elseif v:GetClass()=="func_nav_prefer" and v.Enabled then
							-- print("PREFER: 0")
							brushStat = "prefer" break
						end
					else
						if brushStat=="avoid" and v:GetClass()=="func_nav_avoid" and v.Enabled then
							-- print("AVOID: "..obeyCount + 1)
							obeyCount = obeyCount + 1 break
						elseif brushStat=="prefer" and v:GetClass()=="func_nav_prefer" and v.Enabled then
							-- print("PREFER: "..obeyCount + 1)
							obeyCount = obeyCount + 1 break
						end
					end
				end
			end
			if obeyCount>=2 then
				if brushStat=="avoid" then
					-- print("Avoiding")
					return -1-- dist = dist * 1000000
				elseif brushStat=="prefer" then
					dist = dist * 0.01
					-- print("Preferring, dist is now",dist)
				end
			end]]
			local pos = nextArea:GetCenter()
			for k,v in pairs(entitiestoconsider) do
				if IsValid(k) then
					self:Log(tostring(k).." sensed. Position: "..tostring(pos)..", Vector1:"..tostring(v[1])..", Vector2:"..tostring(v[2])..", InPosition="..tostring(pos:WithinAABox(v[1],v[2])),"func_nav_detection")
					if pos:WithinAABox(v[1],v[2]) and k.Enabled then
						if k:GetClass()=="func_nav_avoid" then
							dist = dist * 1000000
							self:Log("Detected "..tostring(k).." and avoiding, cost to cross is now "..dist,"func_nav_detection") break
						elseif k:GetClass()=="func_nav_prefer" then
							dist = dist * 0.000001
							self:Log("Detected "..tostring(k).." and preferring, cost to cross is now "..dist,"func_nav_detection") break
						end
					end
				else
					entitiestoconsider[k] = nil
				end
			end
			return (prevArea:GetCostSoFar()+dist)
		end
	end
	if ROTGB_GetConVarValue("rotgb_use_custom_pathfinding") then
		path:Compute(self,pos,ComputePath)
	else
		path:Compute(self,pos)
	end
	self:Log("Path Computation Time: "..(SysTime()-sttime)*1000 .." ms","pathfinding")
end

function ENT:MoveToTarget()
	if (self:GetTarget():GetClass()=="gballoon_target" and self:GetTarget():GetTeleport()) then
		self:SetPos(self:GetTarget():GetPos())
	else
		--coroutine.wait(0.05*ROTGB_GetConVarValue("rotgb_path_delay")*ROTGB_GetBalloonCount())
		local path = Path("Chase")
		local position = self:GetTarget():GetPos()
		path:SetGoalTolerance(ROTGB_GetConVarValue("rotgb_target_tolerance"))
		path:SetMinLookAheadDistance(ROTGB_GetConVarValue("rotgb_setminlookaheaddistance"))
		local waitamt = SysTime()
		self:ComputePathWrapper(path,position)
		waitamt = SysTime()-waitamt
		waitamt = math.max(waitamt*ROTGB_GetBalloonCount()*ROTGB_GetConVarValue("rotgb_path_delay"),0.5)
		self:Log("Regenerated pathway. Recomputing in "..waitamt.." seconds...","pathfinding")
		self.RecheckPath = true
		if not IsValid(path) then return "Failed to find a path." end
		--local supptab = {}
		--[[for k,v in pairs(path:GetAllSegments()) do
			if v.area:HasAttributes(NAV_MESH_TRANSIENT) then
				util.TraceLine({
					start = v.area:GetCenter(),
					endpos = v.area:GetCenter()+vector_up*self:BoundingRadius(),
					filter = self,
					mask = MASK_NPCSOLID,
					ignoreworld = true,
					output = supptab
				})
				if supptab.Hit then
					return "Transient NavMesh #"..v.area:GetID().." should not be crossed! Abort!"
				end
			end
		end]]
		while IsValid(path) and IsValid(self:GetTarget()) and not GetConVar("ai_disabled"):GetBool() do
			if self:GetTarget():GetPos():DistToSqr(position)>ROTGB_GetConVarValue("rotgb_target_tolerance")^2 or path:GetAge()>(self.RecheckPath and 0.5 or waitamt) then
				self.RecheckPath = nil
				position = self:GetTarget():GetPos()
				waitamt = SysTime()
				self:ComputePathWrapper(path,position)
				waitamt = SysTime()-waitamt
				waitamt = math.max(waitamt*ROTGB_GetBalloonCount()*ROTGB_GetConVarValue("rotgb_path_delay"),0.5)
				self:Log("Regenerated pathway. Recomputing in "..waitamt.." seconds...","pathfinding")
			end
			if string.find(ROTGB_GetConVarValue("rotgb_debug"),"pathfinding") then
				path:Draw()
			end
			local firstPos = self:GetPos()
			if not self:IsStunned() then
				path:Chase(self,self:GetTarget())
			end
			if not IsValid(path) and (IsValid(self:GetTarget()) and not navmesh.GetNearestNavArea(self:GetPos()):HasAttributes(NAV_MESH_STOP) and self:GetTarget():GetPos():DistToSqr(self:GetPos()) > ROTGB_GetConVarValue("rotgb_target_tolerance")^2*2.25) then
				self:LogError("Temporarily lost track! Using stock pathfinding...","pathfinding")
				self.correcting = true
				path:Compute(self,self:GetTarget():GetPos())
				path:Chase(self,self:GetTarget())
			end
			if self.loco:IsStuck() or (self.WallStuck or 0)>=4 and not self:IsStunned() then
				self.WallStuck = nil
				if (self.ResetStuck or 0) < CurTime() then
					self.UnstuckAttempts = 0
				end
				self.UnstuckAttempts = self.UnstuckAttempts + 1
				self.ResetStuck = CurTime() + 30
				if self.UnstuckAttempts == 1 then -- A simple jump should fix it.
					self:ComputePathWrapper(path,position)
					self.loco:Jump()
					self.loco:ClearStuck()
				elseif self.UnstuckAttempts == 2 then -- That didn't fix it, try to teleport slightly upwards instead.
					self:SetPos(self:GetPos()+vector_up*20)
					self.loco:ClearStuck()
				elseif self.UnstuckAttempts == 3 then -- If not, ask GMod kindly to free us.
					self:HandleStuck()
				else -- If not, just teleport us ahead on the path. (Sanic method)
					self.LastStuck = CurTime()
					self:SetPos(path:GetPositionOnPath(path:GetCursorPosition()+2^self.UnstuckAttempts))
					self.loco:ClearStuck()
				end
				return "Got stuck for the "..self.UnstuckAttempts..STNDRD(self.UnstuckAttempts).." time!"
			end
			self:CheckForRegenAndFire()
			self:CheckForSpeedMods()
			self:PerformPops()
			coroutine.yield()
			if self.correcting and navmesh.GetNearestNavArea(self:GetPos()):HasAttributes(NAV_MESH_STOP) then
				self.correcting = nil
				self:ComputePathWrapper(path,position)
			end
			firstPos:Sub(self:GetPos())
			local cdd = firstPos:Length()
			self.TravelledDistance = (self.TravelledDistance or 0) + cdd
			if cdd==0 and not (self:IsStunned() or navmesh.GetNearestNavArea(self:GetPos()):HasAttributes(NAV_MESH_STOP)) then
				self.WallStuck = (self.WallStuck or 0) + 1
				self:LogError("Stuck in a wall, "..self.WallStuck*25 .."% sure.","pathfinding")
				if self.WallStuck>=4 then
					self:LogError("Definitely stuck! Waiting for HandleStuck...","pathfinding")
				end
			else
				self.WallStuck = nil
			end
		end
		if not IsValid(self:GetTarget()) then
			return "Lost its target."
		end
	end
	return "Completely lost track!!"
end

function ENT:ChooseNextTargetWeighted(current, targets)
	local targetWeightSelectionZones = {}
	local totalWeights = 0
	
	for i,v in ipairs(targets) do
		if v:GetWeight() > 0 then
			table.insert(targetWeightSelectionZones, {totalWeights, v})
			totalWeights = totalWeights + v:GetWeight()
		end
	end
	
	if totalWeights > 0 then
		current = current % totalWeights
		for i,v in ipairs(table.Reverse(targetWeightSelectionZones)) do
			if current >= v[1] then return v[2] end
		end
	end
	
	return targets[math.random(#targets)]
end

function ENT:RunBehaviour()
	while true do
		if not self.FirstRunBehaviour then
			self.FirstRunBehaviour = true
			if self:Health() <= 0 then
				self:SetHealth(1)
				self:Log("Took damage WHILE spawning. Damage negated.", "damage")
			end
		end
		self:CheckForRegenAndFire()
		self:PerformPops()
		if GetConVar("ai_disabled"):GetBool() then
			self:Log("ai_disabled is set, waiting...","pathfinding")
			coroutine.wait(1)
		elseif ROTGB_GetConVarValue("rotgb_init_rate")>=0 and not self.AIEnabled then
			self:Log("AI disabled, waiting...","pathfinding")
			coroutine.wait(1)
		else
			if IsValid(self:GetTarget()) then
				self.loco:SetAcceleration(self:GetBalloonProperty("BalloonMoveSpeed")*(self:GetBalloonProperty("BalloonFast") and 2 or 1)*ROTGB_GetConVarValue("rotgb_speed_mul")*5)
				self.DesiredSpeed = self.loco:GetAcceleration()*0.2
				self.loco:SetDesiredSpeed(self.DesiredSpeed)
				self.loco:SetDeceleration(self.loco:GetAcceleration())
				self.loco:SetJumpHeight(58)
				self.loco:SetStepHeight(18)
				local result = ROTGB_GetConVarValue("rotgb_use_custom_pathfinding") and ROTGB_GetConVarValue("rotgb_use_custom_ai") and self:MoveToTargetNew() or self:MoveToTarget()
				local selftarg = self:GetTarget()
				if (IsValid(selftarg) and not GetConVar("ai_disabled"):GetBool() and selftarg:GetPos():DistToSqr(self:GetPos()) <= ROTGB_GetConVarValue("rotgb_target_tolerance")^2*2.25) then
					if (selftarg:GetClass()=="gballoon_target" and selftarg:GetIsBeacon()) and self.LastBeacon ~= selftarg then
						self.LastBeacon = selftarg
						local nextTargs = {}
						if self:GetBalloonProperty("BalloonBlimp") then
							selftarg.rotgb_TimesBlimpWaypointed = (selftarg.rotgb_TimesBlimpWaypointed or 0) + 1
							selftarg:TriggerOutput("OnWaypointedBlimp",self,selftarg.rotgb_TimesBlimpWaypointed)
							for i=1,16 do
								local gTarg = selftarg["GetNextBlimpTarget"..i](selftarg)
								if IsValid(gTarg) then
									table.insert(nextTargs,gTarg)
								end
							end
						else
							selftarg.rotgb_TimesWaypointed = (selftarg.rotgb_TimesWaypointed or 0) + 1
							selftarg:TriggerOutput("OnWaypointedNonBlimp",self,selftarg.rotgb_TimesWaypointed)
						end
						selftarg:TriggerOutput("OnWaypointed",self,(selftarg.rotgb_TimesWaypointed or 0)+(selftarg.rotgb_TimesBlimpWaypointed or 0))
						if next(nextTargs) then
							--[[ local nextTargetNum = selftarg.rotgb_TimesBlimpWaypointed % #nextTargs
							if nextTargetNum == 0 then nextTargetNum = #nextTargs end
							self:SetTarget(nextTargs[nextTargetNum]) ]]
							self:SetTarget(self:ChooseNextTargetWeighted(selftarg.rotgb_TimesBlimpWaypointed, nextTargs))
						else
							for i=1,16 do
								local gTarg = selftarg["GetNextTarget"..i](selftarg)
								if IsValid(gTarg) then
									table.insert(nextTargs,gTarg)
								end
							end
							if next(nextTargs) then
								local times = self:GetBalloonProperty("BalloonBlimp") and (selftarg.rotgb_TimesWaypointed or 0)+selftarg.rotgb_TimesBlimpWaypointed or selftarg.rotgb_TimesWaypointed
								--[[ local nextTargetNum = times % #nextTargs
								if nextTargetNum == 0 then nextTargetNum = #nextTargs end
								self:SetTarget(nextTargs[nextTargetNum]) ]]
								self:SetTarget(self:ChooseNextTargetWeighted(times, nextTargs))
							end
						end
					else
						self:Pop(nil,selftarg)
					end
				else
					self:LogError(tostring(result),"pathfinding")
				end
			else
				self.loco:SetDesiredSpeed(0)
				if not self:FindTarget() then
					coroutine.wait(1)
				end
			end
		end
		coroutine.yield()
	end
end

function ENT:Stun(tim)
	self.StunUntil = math.max(CurTime() + tim,self.StunUntil or 0)
end

function ENT:UnStun()
	self.StunUntil = nil
end

function ENT:Freeze(tim)
	self:SetNWFloat("rotgb_FreezeTime",CurTime()+tim)
	self.FreezeUntil = math.max(CurTime() + tim,self.FreezeUntil or 0)
end

function ENT:UnFreeze()
	self:SetNWFloat("rotgb_FreezeTime",0)
	self.FreezeUntil = nil
end

function ENT:Freeze2(tim)
	self:SetNWFloat("rotgb_FreezeTime",CurTime()+tim)
	self.FreezeUntil2 = math.max(CurTime() + tim,self.FreezeUntil2 or 0)
end

function ENT:UnFreeze2()
	self:SetNWFloat("rotgb_FreezeTime",0)
	self.FreezeUntil2 = nil
end

function ENT:IsStunned()
	return self.StunUntil and self.StunUntil>CurTime() or self.FreezeUntil and self.FreezeUntil>CurTime() or self.FreezeUntil2 and self.FreezeUntil2>CurTime() or false
end

function ENT:CheckForSpeedMods()
	local mul = 0.2
	for k,v in pairs(self.rotgb_SpeedMods or {}) do
		if v[1] > CurTime() then
			mul = mul * v[2]
		else
			self.rotgb_SpeedMods[k] = nil
		end
	end
	self.DesiredSpeed = self.loco:GetAcceleration()*mul
	self.loco:SetDesiredSpeed(self.DesiredSpeed)
end

function ENT:Slowdown(id,amt,tim)
	self.rotgb_SpeedMods = self.rotgb_SpeedMods or {}
	if self.rotgb_SpeedMods[id] then
		tim = math.max(tim,self.rotgb_SpeedMods[id][1]-CurTime())
		amt = math.min(amt,self.rotgb_SpeedMods[id][2])
	end
	self.rotgb_SpeedMods[id] = {CurTime() + tim,amt}
end

function ENT:UnSlowdown(id)
	self.rotgb_SpeedMods = self.rotgb_SpeedMods or {}
	self.rotgb_SpeedMods[id] = nil
end

function ENT:GetAndApplyValueMultipliers(value)
	local total = value
	for k,v in pairs(self.rotgb_ValueMultipliers or {}) do
		if v[1] > CurTime() then
			local increment = v[2]*value
			total = total + increment
			if IsValid(v[3]) then
				v[3]:SetCashGenerated(v[3]:GetCashGenerated()+increment)
			end
		else
			self.rotgb_ValueMultipliers[k] = nil
		end
	end
	return total
end

function ENT:MultiplyValue(id,tower,amt,tim)
	self.rotgb_ValueMultipliers = self.rotgb_ValueMultipliers or {}
	if self.rotgb_ValueMultipliers[id] then
		tim = math.max(tim,self.rotgb_ValueMultipliers[id][1]-CurTime())
		amt = math.max(amt,self.rotgb_ValueMultipliers[id][2])
	end
	self.rotgb_ValueMultipliers[id] = {CurTime() + tim,amt,tower}
end

function ENT:CreateFire(dmg, atk, inflictor, tim)
	self.RotgBFireEnt = ents.Create("env_fire")
	self.RotgBFireEnt:SetPos(self:GetPos())
	self.RotgBFireEnt:SetParent(self)
	self.RotgBFireEnt:SetKeyValue("spawnflags",bit.bor(2,32,128))
	self.RotgBFireEnt:SetKeyValue("firesize",64)
	self.RotgBFireEnt:SetKeyValue("health",tim)
	self.RotgBFireEnt:Spawn()
	self.RotgBFireEnt:Fire("StartFire")
	self.RotgBFireEnt.damage = dmg
	self.RotgBFireEnt.attacker = atk
	self.RotgBFireEnt.inflictor = inflictor
	self.RotgBFireEnt.dietime = CurTime()+tim
end

function ENT:RotgB_Ignite(dmg, atk, inflictor, tim)
	--self:Extinguish()
	--self:Ignite(tim)
	if IsValid(self.RotgBFireEnt) then
		if self.RotgBFireEnt.damage < dmg then
			self.RotgBFireEnt.damage = dmg
			self.RotgBFireEnt.attacker = atk
			self.RotgBFireEnt.inflictor = inflictor
			self.RotgBFireEnt.dietime = CurTime()+tim
			self.RotgBFireEnt:SetKeyValue("health",tim)
			self.RotgBFireEnt:Fire("StartFire")
		elseif self.RotgBFireEnt.dietime < CurTime()+tim then
			self.RotgBFireEnt.dietime = CurTime()+tim
			self.RotgBFireEnt:SetKeyValue("health",tim)
			self.RotgBFireEnt:Fire("StartFire")
		end
	else
		self:Log("Caught on fire by "..tostring(inflictor).."!","fire")
		self:CreateFire(dmg, atk, inflictor, tim)
	end
end

function ENT:InflictRotgBStatusEffect(typ,tim)
	self["rotgb_SE_"..typ] = math.max(self["rotgb_SE_"..typ] or 0,CurTime() + tim)
end

function ENT:HasRotgBStatusEffect(typ)
	return (self["rotgb_SE_"..typ] or 0) >= CurTime()
end

function ENT:GetRotgBStatusEffectDuration(typ)
	return (self["rotgb_SE_"..typ] or 0) - CurTime()
end

function ENT:GetRgBE()
	return self.rotgb_rbetab[self:GetBalloonProperty("BalloonType")]*(self:GetBalloonProperty("BalloonShielded") and 2 or 1)+math.max(self:Health(), 1)-self:GetMaxHealth()
end

function ENT:GetDistanceTravelled()
	return self.TravelledDistance or 0
end

function ENT:GetBitflagPropertyState(fast, hidden, regen, shielded)
	return bit.bor(
		(regen or self:GetBalloonProperty("BalloonRegen")) and 1 or 0,
		(fast or self:GetBalloonProperty("BalloonFast")) and 2 or 0,
		(shielded or self:GetBalloonProperty("BalloonShielded")) and 4 or 0,
		(hidden or self:GetBalloonProperty("BalloonHidden")) and 8 or 0
	)
end

local function HasAnyBits(dmgbits,...)
	return bit.band(dmgbits or 0,bit.bor(...))~=0
end

function ENT:ShowResistEffect(typ)
	local effectDelay = ROTGB_GetConVarValue("rotgb_resist_effect_delay")
	if effectDelay>=0 and (ROTGB_LASTSHOW or 0) + effectDelay<=CurTime() then
		local effdata = EffectData()
		effdata:SetOrigin(self:GetPos())
		effdata:SetColor(typ)
		util.Effect("rotgb_resist",effdata)
		ROTGB_LASTSHOW = CurTime()
	end
end

function ENT:ShowCritEffect()
	local effectDelay = ROTGB_GetConVarValue("rotgb_crit_effect_delay")
	if effectDelay>=0 and (ROTGB_LASTSHOW2 or 0) + effectDelay<=CurTime() then
		local effdata = EffectData()
		effdata:SetOrigin(self:GetPos())
		util.Effect("rotgb_crit",effdata)
		ROTGB_LASTSHOW2 = CurTime()
	end
end

local function TestDamageResistances(properties,dmgbits,frozen)
	if properties.BalloonGlass and dmgbits then return 8
	elseif ROTGB_GetConVarValue("rotgb_ignore_damage_resistances") then return
	elseif frozen and HasAnyBits(dmgbits,DMG_BULLET+DMG_SLASH+DMG_BUCKSHOT) then return 6
	elseif properties.BalloonBlack and HasAnyBits(dmgbits,DMG_BLAST,DMG_BLAST_SURFACE) then return 2
	elseif properties.BalloonWhite and HasAnyBits(dmgbits,DMG_VEHICLE,DMG_DROWN,DMG_DROWNRECOVER) then return 1
	elseif properties.BalloonPurple and HasAnyBits(dmgbits,DMG_BURN,DMG_SHOCK,DMG_ENERGYBEAM,DMG_SLOWBURN,
	DMG_REMOVENORAGDOLL,DMG_PLASMA,DMG_DISSOLVE,DMG_DIRECT) then return 3
	elseif properties.BalloonGray and HasAnyBits(dmgbits,DMG_BULLET+DMG_SLASH+DMG_BUCKSHOT) then return 4 end
	--if properties.BalloonAqua and (HasAnyBits(dmgbits,DMG_CRUSH+DMG_FALL+DMG_CLUB+DMG_PHYSGUN)) then return 6 end
end

game.AddDecal("InkWhite","decals/decal_paintsplattergreen001")
function ENT:PerformPops()
	local health = self:Health()
	if health<=0 then
		local attacker = self.LastAttacker
		local bloodType = ROTGB_GetConVarValue("rotgb_bloodtype")
		if bloodType>=16 then
			util.Decal(ROTGB_GetConVarValue("rotgb_blooddecal"),self:GetPos()+vector_up,self:GetPos()-vector_up*self:BoundingRadius()*self:GetModelScale(),self)
		elseif bloodType>=8 then
			local inkproj = ents.Create("splashootee")
			if IsValid(inkproj) then
				local CNames = {"Orange","Pink","Purple","Blue","Cyan","Green",[0]="White"}
				--local CCodes = {30,300,270,240,180,120,360}
				inkproj:SetNoDraw(true)
				inkproj:Setscale(Vector(1,1,1))
				inkproj:SetModel("models/spitball_small.mdl")
				inkproj:SetPos(self:WorldSpaceCenter())
				inkproj:SetOwner(attacker)
				inkproj:SetPhysicsAttacker(attacker)
				inkproj:SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
				inkproj.InkColor = CNames[bloodType-8]
				inkproj.Dmg = 0
				inkproj:Spawn()
				inkproj:GetPhysicsObject():ApplyForceCenter(Vector(0,0,-600))
			end
		end
		local damageType = self.LastDamageType
		self:Pop(-health,nil,damageType)
	end
end

function ENT:OnInjured(dmginfo)
	if dmginfo:GetInflictor():GetClass()~="env_fire" then
		self.BalloonRegenTime = CurTime()+ROTGB_GetConVarValue("rotgb_regen_delay")
		self.LastAttacker = dmginfo:GetAttacker()
		self.LastInflictor = dmginfo:GetInflictor()
		self.LastDamageType = dmginfo:GetDamageType()
		dmginfo:SetDamage(math.ceil(dmginfo:GetDamage()*0.1*ROTGB_GetConVarValue("rotgb_damage_multiplier")))
		self:Log("About to take "..dmginfo:GetDamage().." damage at "..self:Health().." health!","damage")
		local resistresults = TestDamageResistances(self.Properties,self.LastDamageType,(self.FreezeUntil or 0)>CurTime() or (self.FreezeUntil2 or 0)>CurTime())
		local ignoreResistances = ROTGB_GetConVarValue("rotgb_ignore_damage_resistances")
		if resistresults and not self:HasRotgBStatusEffect("unimmune") then
			dmginfo:SetDamage(0)
			self:ShowResistEffect(resistresults)
		end
		if self:GetBalloonProperty("BalloonArmor") and not ignoreResistances then
			if self:GetBalloonProperty("BalloonArmor") < 0 then
				dmginfo:AddDamage(-self:GetBalloonProperty("BalloonArmor"))
			else
				dmginfo:SubtractDamage(self:GetBalloonProperty("BalloonArmor"))
			end
			if dmginfo:GetDamage()<=0 and not resistresults then
				self:ShowResistEffect(7)
			end
		end
		if self:GetBalloonProperty("BalloonMaxDamage") and not ignoreResistances then
			if dmginfo:GetDamage() > self:GetBalloonProperty("BalloonMaxDamage") then
				local remainingdamage = dmginfo:GetDamage() - self:GetBalloonProperty("BalloonMaxDamage")
				dmginfo:SetDamage(self:GetBalloonProperty("BalloonMaxDamage")+math.floor(remainingdamage*0.9))
			end
		end
		if self:GetBalloonProperty("BalloonShielded") and self:HasRotgBStatusEffect("unshield") then
			dmginfo:ScaleDamage(2)
		end
		--[[if self.FireSusceptibility and (dmginfo:IsDamageType(DMG_BURN) or IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():GetClass()=="env_fire") then
			dmginfo:ScaleDamage(1+self.FireSusceptibility)
			dmginfo:SetDamage(math.ceil(dmginfo:GetDamage()))
		end]]
		local newhealth = self:Health()-math.max(dmginfo:GetDamage(),0)
		local addDamageThisLayer = self:Health()-math.max(newhealth, 0)-1
		self:SetHealth(newhealth)
		self:Log("Took "..dmginfo:GetDamage().." damage! We are now at "..newhealth.." health.","damage")
		if (IsValid(self.LastInflictor) and (self.LastInflictor.Base == "gballoon_tower_base" or self.LastInflictor:GetClass()=="rotgb_shooter")) and addDamageThisLayer > 0 then
			self.LastInflictor:AddPops(addDamageThisLayer)
			self:Log("Credited "..tostring(self.LastInflictor).." "..addDamageThisLayer.." pop(s).","damage")
			hook.Run("gBalloonDamaged", self, self.LastAttacker, self.LastInflictor, addDamageThisLayer, false)
		end
		if self:GetBalloonProperty("BalloonShielded") and self:Health()*2>self:GetMaxHealth() and (not ROTGB_GetConVarValue("rotgb_legacy_gballoons") or ROTGB_GetConVarValue("rotgb_pertain_effects")) then
			self:SetNWBool("RenderShield",true)
		else
			self:SetNWBool("RenderShield",false)
		end
	end
	dmginfo:SetDamage(0)
end

function ENT:ShouldPopOnContact(ent)
	if (ent:GetClass()=="gballoon_target" and ent:GetIsBeacon()) then return false end
	local mask = ROTGB_GetConVarValue("rotgb_pop_on_contact")
	if mask==-1 and self:CanTarget(ent) then return true
	elseif mask<-1 and ent:Health()>0 and ent:GetClass()~="gballoon_base" then return true end
	return self:MaskFilter(mask,ent)
end

function ENT:OnContact(ent)
	if IsValid(ent) then
		if self:ShouldPopOnContact(ent) then self:Pop(-1,ent) end
	end
	--[[if ent.SawbladeDamage then
		local dmginfo = DamageInfo()
		dmginfo:SetDamageType(DMG_SLASH)
		dmginfo:SetDamage(ent.SawbladeDamage)
		self:TakeDamageInfo(,ent,ent)
	end]]
end

local baseNextbotClass = baseclass.Get("base_nextbot")
function ENT:OnKilled(dmginfo)
	if ROTGB_GetConVarValue("rotgb_use_kill_handler") then
		baseNextbotClass.OnKilled(self, dmginfo)
	end
	-- self.Attractor:Remove()
	-- self:Pop(-self:Health(),nil,dmginfo:GetDamageType())
end

local lastEffectRender = 0

function ENT:DetermineNextBalloons(blns,dmgbits,instant)
	local pluses = 0
	local pops = 0
	local newspawns = {}
	local oldnv,opls,opop = 0,0,0
	for k,v in pairs(blns) do
		if istable(v) then
			local class = v.Type
			--local DoRegen = v.DoRegen
			--local Fast = v.Fast
			local Shield = v.Shield
			local Hidden = v.Hidden
			local keyvals = list.GetForEdit("NPC")[class].KeyValues
			local blockbymaxdamage = (v.InternalPops or 0) >= (tonumber(keyvals.BalloonMaxDamage) or math.huge)
			local unitshift = blockbymaxdamage and 0.1 or 1
			if TestDamageResistances(keyvals,dmgbits,v.Frozen) and not self:HasRotgBStatusEffect("unimmune") then
				table.insert(newspawns,v)
			elseif (istable(v) and (v.Health or 1)>unitshift) and not instant then
			--elseif (istable(v) and v.Health > 1) and (not instant or blockbymaxdamage) then
				--if not blockbymaxdamage then
					v.InternalPops = (v.InternalPops or 0) + 1
					v.Health = v.Health - unitshift
					pops = pops + v.Amount * unitshift
				--end
				table.insert(newspawns,v)
			elseif self.rotgb_spawns[class] then
				for k2,v2 in pairs(self.rotgb_spawns[class]) do
					local keyvals2 = list.GetForEdit("NPC")[k2].KeyValues
					local crt = {
						Type=k2,
						Amount=v2*v.Amount,
						Health=math.Round(
							(keyvals2.BalloonHealth or 1)*(keyvals2.BalloonShielded or HasAllBits(v.Properties, 4) and 2 or 1)
							*(keyvals2.BalloonBlimp and ROTGB_GetConVarValue("rotgb_blimp_health_multiplier") or 1)*ROTGB_GetConVarValue("rotgb_health_multiplier")
						),
						Properties=v.Properties
						--Frozen=(self.FreezeUntil2 or 0)>CurTime()
					}
					if HasAllBits(v.Properties, 1) and not v.Blimp then
						crt.PrevBalloons=table.Copy(v.PrevBalloons or {})
						table.insert(crt.PrevBalloons,class)
						self:Log("A gBalloon will regenerate, to a maximum of: "..util.TableToJSON(crt.PrevBalloons,true),"regeneration")
					end
					table.insert(newspawns,crt)
				end
				pluses = pluses + v.Amount
				pops = pops + v.Amount * v.Health
			else
				pluses = pluses + v.Amount
				pops = pops + v.Amount * v.Health
			end
		end
	end
	return newspawns,pluses,pops
end

function ENT:Pop(damage,target,dmgbits)
	damage = damage or -1--math.ceil(math.Clamp(damage or -1,-999999999,999999999))
	self:Log("Popping for "..damage.." damage...","damage")
	-- self:SetNWBool("BalloonPurple",false)
	local maxToExist = ROTGB_GetConVarValue("rotgb_max_to_exist")
	local doAchievement = ROTGB_GetConVarValue("rotgb_use_achievement_handler")
	local selftype = self:GetBalloonProperty("BalloonType")
	local selfblmp = self:GetBalloonProperty("BalloonBlimp")
	local nexts = {{Type=selftype,Amount=1,Health=1,Properties=self:GetBitflagPropertyState(),PrevBalloons=self.PrevBalloons,Blimp=selfblmp,Frozen=(self.FreezeUntil2 or 0)>CurTime()}}
	local cash = 0
	local pops = 0
	local balloonnum = ROTGB_GetBalloonCount()
	--local nextsasstring = self:GetPopSaveString(nexts[1],damage,dmgbits or 0)
	if damage < 0 or damage>self:GetRgBE()*10 then damage = math.huge end
	self:Log("Before Popping: "..util.TableToJSON(nexts,true),"damage")
	local ctime = SysTime()
	local i = 1
	local spawnedBalloonCount = 1
	while i <= damage+1 or spawnedBalloonCount+balloonnum > maxToExist do
		local addcash,addpops = 0,0
		local overspawned = spawnedBalloonCount+balloonnum > maxToExist
		nexts,addcash,addpops = self:DetermineNextBalloons(nexts,overspawned and 0 or dmgbits,damage==math.huge or overspawned)
		self:Log("Pop #"..i.." of #"..damage+1 ..":"..util.TableToJSON(nexts,true),"damage")
		if (self.DeductCash or 0)>0 then
			self.DeductCash = self.DeductCash - 1
		else
			cash = cash + addcash
		end
		i = i + 1
		pops = pops + addpops
		spawnedBalloonCount = 0
		for k,v in pairs(nexts) do
			spawnedBalloonCount = spawnedBalloonCount + (v.Amount or 1)
		end
		if spawnedBalloonCount==0 or addpops==0 then break end
	end
	--[[if next(toAdd) then
		self:Log("Values to push:"..util.TableToJSON(toAdd,true),"popping")
		for k,v in pairs(toAdd) do
			table.Add(nexts,v)
		end
	end]]
	self:Log("After Popping: "..util.TableToJSON(nexts,true),"damage")
	self:Log("Time taken: "..(SysTime()-ctime)*1000 .." ms","damage")
	if (IsValid(self.LastAttacker) and self.LastAttacker:IsPlayer()) then
		if doAchievement == 1 then
			self.LastAttacker:SendLua("achievements.BalloonPopped()") -- What? It's a balloon, right?
		elseif doAchievement > 1 then
			net.Start("rotgb_generic")
			net.WriteUInt(ROTGB_OPERATION_ACHIEVEMENT, 8)
			net.WriteUInt(cash, 32)
			net.Send(self.LastAttacker)
		end
	end
	if IsValid(target) then
		local damage = (pops+math.max(self:Health(), 1)-1)*ROTGB_GetConVarValue("rotgb_afflicted_damage_multiplier")
		local dmginfo = DamageInfo()
		local dir = target:WorldSpaceCenter() - self:GetPos()
		dir:Normalize()
		dir:Mul(damage)
		dmginfo:SetDamage(damage)
		dmginfo:SetReportedPosition(self:GetPos())
		dmginfo:SetDamageForce(dir)
		dmginfo:SetAttacker(self)
		dmginfo:SetInflictor(self)
		target:TakeDamageInfo(dmginfo)
		self:Log("Hurting "..tostring(target).." for "..damage.." damage...","damage")
	else
		local baseMul = ROTGB_GetConVarValue("rotgb_cash_mul")
		local newcash = self:GetAndApplyValueMultipliers(cash)
		self:Log("Awarding "..cash*baseMul.." cash (x"..newcash/cash..") after "..pops.." pops...","damage")
		cash = newcash
		ROTGB_AddCash(cash*baseMul)
		if (IsValid(self.LastInflictor) and (self.LastInflictor.Base == "gballoon_tower_base" or self.LastInflictor:GetClass()=="rotgb_shooter")) and pops > 0 then
			self.LastInflictor:AddPops(pops)
			self:Log("Credited "..tostring(self.LastInflictor).." "..pops.." pop(s).","damage")
			hook.Run("gBalloonDamaged", self, self.LastAttacker, self.LastInflictor, pops, true)
		end
	end
	--for i=1,pops do
		self:EmitSound(self:GetBalloonProperty("BalloonPopSound"),75,math.random(80,120),1)
	--end
	if not self:GetBalloonProperty("BalloonBlimp") and lastEffectRender<CurTime() then
		if lastEffectRender+1<CurTime() then
			lastEffectRender = CurTime() - 1
		end
		lastEffectRender = lastEffectRender+1/ROTGB_GetConVarValue("rotgb_max_effects_per_second")
		local effdata = EffectData()
		effdata:SetStart(string.ToColor(self:GetBalloonProperty("BalloonColor")):ToVector()*255)
		effdata:SetEntity(self)
		effdata:SetRadius(100)
		effdata:SetScale(1)
		effdata:SetMagnitude(1)
		effdata:SetOrigin(self:GetPos())
		util.Effect("balloon_pop",effdata)
	end
	for i,v in ipairs(nexts) do
		if --[[i+balloonnum<ROTGB_GetConVarValue("rotgb_max_to_exist") and]] istable(v) then
			for j=1,v.Amount do
				self:Log("To Spawn: "..util.TableToJSON(v,true),"damage")
				local tospawn = v.Type
				local spe = ents.Create("gballoon_base")
				spe:SetPos(self:GetPos()+VectorRand()+vector_up)
				spe.Properties = list.Get("NPC")[tospawn].KeyValues
				if istable(v) then
					spe.Properties.BalloonRegen = spe.Properties.BalloonRegen or HasAllBits(v.Properties, 1)
					spe.Properties.BalloonFast = spe.Properties.BalloonFast or HasAllBits(v.Properties, 2)
					spe.Properties.BalloonShielded = spe.Properties.BalloonShielded or HasAllBits(v.Properties, 4)
					spe.Properties.BalloonHidden = spe.Properties.BalloonHidden or HasAllBits(v.Properties, 8)
				end
				spe:Spawn()
				spe:Activate()
				spe.StunUntil = self.StunUntil
				spe.FreezeUntil2 = self.FreezeUntil2
				spe.AcidicList = self.AcidicList
				spe.TravelledDistance = self.TravelledDistance
				spe.rotgb_SpeedMods = self.rotgb_SpeedMods
				spe.rotgb_ValueMultipliers = self.rotgb_ValueMultipliers
				if spe.rotgb_ValueMultipliers and spe.rotgb_ValueMultipliers.ROTGB_TOWER_17 then
					local effData = EffectData()
					effData:SetEntity(spe)
					util.Effect("gballoon_tower_17_morecash", effData)
				end
				if not self:HasRotgBStatusEffect("glue_soak") and spe.rotgb_SpeedMods then
					spe.rotgb_SpeedMods.ROTGB_GLUE_TOWER = nil
				elseif spe.rotgb_SpeedMods and spe.rotgb_SpeedMods.ROTGB_GLUE_TOWER then
					local effData = EffectData()
					effData:SetEntity(spe)
					effData:SetFlags(spe.AcidicList and next(spe.AcidicList) and 1 or 0)
					effData:SetHitBox(self:GetRotgBStatusEffectDuration("glue_soak")*10)
					util.Effect("gballoon_tower_9_glued", effData)
					spe:InflictRotgBStatusEffect("glue_soak", self:GetRotgBStatusEffectDuration("glue_soak"))
				end
				spe.DeductCash = self.DeductCash
				--spe.BeaconsReached = table.Copy(self.BeaconsReached)
				spe.LastBeacon = self.LastBeacon
				if IsValid(self.RotgBFireEnt) then
					spe:CreateFire(self.RotgBFireEnt.damage, self.RotgBFireEnt.attacker, self.RotgBFireEnt.inflictor, self.RotgBFireEnt.dietime-CurTime())
					spe.LastBurn = CurTime()
				end
				--[[if (self.BurnTime or 0)-0.5 >= CurTime() then
					local cBurnTime = self.BurnTime
					timer.Simple(0.5,function()
						if IsValid(spe) then
							spe.BurnTime = cBurnTime
							spe:RotgB_Ignite(spe.BurnTime-CurTime())
						end
					end)
				end]]
				spe:SetTarget(self:GetTarget())
				if istable(v) and SERVER then
					spe.PrevBalloons = v.PrevBalloons
					spe:SetHealth(math.max(v.Health or 1, 1))
				end
				--[[timer.Simple(0,function()
					if (IsValid(spe) and spe:Health()<=0) then spe:Pop(-spe:Health()) end
				end)]]
			end
		end
	end
	SafeRemoveEntity(self.RotgBFireEnt)
	SafeRemoveEntity(self.FastTrail)
	self:Remove()
end

function ENT:CheckForRegenAndFire()
	if SERVER then
		if IsValid(self.RotgBFireEnt) then
			--[[local numberstoremove = {}
			for k,v in pairs(self.FireBurns) do
				if v[4] <= CurTime() or not (IsValid(v[3]) and IsValid(v[2])) then
					if not IsValid(v[3]) then
						self:Log("Fire attacker MISSING?!","fire")
					end
					if not IsValid(v[2]) then
						self:Log("Fire inflictor MISSING?!","fire")
					end
					self:Log("Fire #"..k.." expired.","fire")
					self.FireBurns[k] = nil
				end
			end
			if table.IsEmpty(self.FireBurns) then
				self.RotgBFireEnt:Remove()
			else]]
			if not (IsValid(self.RotgBFireEnt.attacker) and IsValid(self.RotgBFireEnt.inflictor)) then
				self.RotgBFireEnt:Remove()
			elseif not self.LastBurn then
				self.LastBurn = CurTime()
			elseif (self.LastBurn + ROTGB_GetConVarValue("rotgb_fire_delay")) < CurTime() --[[and next(self.FireBurns)]] then
				self.LastBurn = CurTime()
				local dmginfo = DamageInfo()
				dmginfo:SetDamagePosition(self:GetPos())
				dmginfo:SetDamageType(bit.bor(DMG_BURN,DMG_DIRECT))
				--for k,v in pairs(self.FireBurns) do
					dmginfo:SetDamage(self.RotgBFireEnt.damage)
					dmginfo:SetAttacker(self.RotgBFireEnt.attacker)
					dmginfo:SetInflictor(self.RotgBFireEnt.inflictor)
					dmginfo:SetReportedPosition(self.RotgBFireEnt.inflictor:GetPos())
					self:TakeDamageInfo(dmginfo)
					--if not (IsValid(self) and self:Health()>0) then break end
				--end
			end
		end
		if self:GetBalloonProperty("BalloonRegen") and (self.PrevBalloons and next(self.PrevBalloons)) then
			local curtime = CurTime()
			local regenDelay = ROTGB_GetConVarValue("rotgb_regen_delay")
			self.BalloonRegenTime = self.BalloonRegenTime or curtime+regenDelay
			if self.BalloonRegenTime <= curtime then
				self.BalloonRegenTime = curtime+regenDelay
				local prevballoon = table.remove(self.PrevBalloons)
				self:Log("Regenerating to: "..prevballoon,"regeneration")
				local bits = self:GetBitflagPropertyState()
				self.Properties = list.Get("NPC")[prevballoon].KeyValues
				if HasAllBits(bits, 2) then
					self.Properties.BalloonFast = true
				end
				if HasAllBits(bits, 4) then
					self.Properties.BalloonShielded = true
				end
				if HasAllBits(bits, 8) then
					self.Properties.BalloonHidden = true
				end
				self:SetNWBool("BalloonPurple",false)
				self:SetNWBool("RenderShield",false)
				self.Properties.BalloonRegen = true
				self:Spawn()
				self:Activate()
				self.DeductCash = (self.DeductCash or 0) + 1
				self:Log("Regenerated to: "..prevballoon..". Fast = "..tostring(HasAllBits(bits, 2))..", Shielded = "..tostring(HasAllBits(bits, 4))..", Hidden = "..tostring(HasAllBits(bits, 8)),"regeneration")
				self:Log("This gBalloon will yield "..self.DeductCash.." less cash than usual.","regeneration")
			end
		end
		if self:GetBalloonProperty("BalloonType")=="gballoon_blimp_rainbow" then
			local oldHealth = self:Health()
			local rainbowRegen = ROTGB_GetConVarValue("rotgb_rainbow_gblimp_regen_rate")
			self:SetHealth(math.min(oldHealth+rainbowRegen,self:GetMaxHealth()))
			self:Log("Regenerated "..self:Health()-oldHealth.." health.","regeneration")
		end
	end
end

local shieldcolor = Color(0,255,255,31)
function ENT:DrawTranslucent()
	self:Draw()
	render.SetColorMaterial()
	if self:GetNWBool("RenderShield") then
		render.DrawSphere(self:GetPos()+self:OBBCenter(),self:BoundingRadius()*self:GetModelScale()*self.VModelScale.x,8,5,shieldcolor)
	end
end

function ENT:GetRelationship(ent)
	if SERVER then
		local mask = ROTGB_GetConVarValue("rotgb_target_choice")
		for k,v in pairs(ents.GetAll()) do
			if v:IsNPC() then
				if mask<0 and v:Health()>0 and v:GetClass()~="gballoon_base" then
					v:AddEntityRelationship(self,D_HT,99)
					return D_HT
				elseif self:MaskFilter(mask,v) then
					v:AddEntityRelationship(self,D_HT,99)
					return D_HT
				end
			end
		end
	end
end

--[=[function ENT:Think()
	--[[if self:GetBalloonProperty("BalloonHidden") then
		local mgh = CurTime()%2<1.5
		if mgh and not self:GetNoDraw() then
			self:SetNoDraw(true)
		elseif not mgh and self:GetNoDraw() then
			self:SetNoDraw(false)
		end
	end]]
end]=]

hook.Add("EntityKeyValue","RotgB",function(ent,key,value)
	if ent:GetClass()=="func_nav_avoid" or ent:GetClass()=="func_nav_prefer" then
		ent.Enabled = nil
		if not tobool(ent:GetKeyValues().start_disabled) then
			ent.Enabled = true
		end
	end
end)

hook.Add("AcceptInput","RotgB",function(ent,inputname)
	local FNT = ROTGB_GetConVarValue("rotgb_func_nav_expand")
	if ent:GetClass()=="func_nav_avoid" or ent:GetClass()=="func_nav_prefer" then
		if inputname:lower()=="enable" then
			entitiestoconsider[ent] = {ent:GetPos()+ent:OBBMins()+Vector(-FNT,-FNT,-FNT),ent:GetPos()+ent:OBBMaxs()+Vector(FNT,FNT,FNT)}
			ent.Enabled = true
		elseif inputname:lower()=="disable" then
			ent.Enabled = nil
		elseif inputname:lower()=="toggle" then
			ent.Enabled = not ent.Enabled
		end
	elseif ent:GetName()=="wave_finished_relay" and inputname:lower()=="trigger" then
		for k,v in pairs(ents.GetAll()) do
			if ent:GetClass()=="func_nav_avoid" or ent:GetClass()=="func_nav_prefer" then
				ent.Enabled = nil
			end
		end
	end
end)

local drawtable = {}
--local drawtable2 = {}
local visibles = {}
local nextsee = 0
hook.Add("PreDrawHalos","RotgB",function()
	if not GetConVar("rotgb_no_glow"):GetBool() then
		local showfrozen = GetConVar("rotgb_freeze_effect"):GetBool()
		if nextsee < CurTime() then
			visibles = ROTGB_GetBalloons()
			nextsee = CurTime() + 0.2
		end
		table.Empty(drawtable)
		--table.Empty(drawtable2)
		for k,v in pairs(visibles) do
			if IsValid(v) then
				if v:GetNWFloat("rotgb_FreezeTime")>CurTime() and showfrozen and not v.rotgb_IsFrozen then
					v.rotgb_IsFrozen = true
					local effdata = EffectData()
					effdata:SetEntity(v)
					util.Effect("phys_freeze",effdata)
					--v.rotgb_FreezeTime = CurTime() + 0.5
				elseif v:GetNWFloat("rotgb_FreezeTime")<=CurTime() and v.rotgb_IsFrozen then
					v.rotgb_IsFrozen = nil
					local effdata = EffectData()
					effdata:SetEntity(v)
					util.Effect("phys_unfreeze",effdata)
					--v.rotgb_FreezeTime = CurTime() + 0.5
				end
				--[[if (v.rotgb_FreezeTime and v.rotgb_FreezeTime>CurTime()) and showfrozen then
					table.insert(drawtable2,{{v},(v.rotgb_FreezeTime-CurTime())*4,v.rotgb_IsFrozen})
				end]]
				if v:GetNWBool("BalloonPurple") then
					table.insert(drawtable,v)
				end
			end
		end
		if #drawtable>0 then
			halo.Add(drawtable,Color(0,255,255),2,2,1,true,false)
		end
		--[[for k,v in pairs(drawtable2) do
			local col = v[3] and Color(0,255,0) or Color(255,0,0)
			halo.Add(v[1],col,v[2],v[2],1,true,false)
		end]]
	end
end)



if CLIENT then
	local spacing_top = 32
	local color_red = Color(255,0,0)
	local color_green = Color(0,255,0)
	local color_aqua = Color(0,255,255)
	local color_white_translucent = Color(255,255,255,223)
	local color_gray = Color(127,127,127)
	local color_gray_translucent = Color(127,127,127,223)
	local color_black_translucent = Color(0,0,0,223)

	local classes = {
		"gballoon_red",
		"gballoon_blue",
		"gballoon_green",
		"gballoon_yellow",
		"gballoon_pink",
		"gballoon_white",
		"gballoon_black",
		"gballoon_purple",
		"gballoon_orange",
		"gballoon_zebra",
		"gballoon_aqua",
		"gballoon_gray",
		"gballoon_error",
		"gballoon_rainbow",
		"gballoon_ceramic",
		"gballoon_blimp_blue",
		"gballoon_brick",
		"gballoon_blimp_red",
		"gballoon_marble",
		"gballoon_blimp_green",
		"gballoon_blimp_gray",
		"gballoon_blimp_purple",
		"gballoon_blimp_magenta",
		"gballoon_blimp_rainbow",
	}
	
	local function GetUserEntry(run_func, def_type, def_flags)
		local currentparams = {def_type or "gballoon_*", def_flags or 255}
		
		local Main = vgui.Create("DFrame")
		Main:SetSize(ScrH()/3,ScrH()/2.5)
		Main:Center()
		Main:SetTitle("Entry Maker")
		Main:SetSizable(true)
		Main:MakePopup()
		
		local Scroller = vgui.Create("DScrollPanel", Main)
		Scroller:Dock(FILL)
		
		function Scroller:CreateEntry(text, optiontable, func, default)
		
			local Text = vgui.Create("DLabel", self)
			Text:SetText(text)
			Text:Dock(TOP)
			
			local OptionSelector = vgui.Create("DComboBox", self)
			OptionSelector:SetSortItems(false)
			for i,v in ipairs(optiontable) do
				OptionSelector:AddChoice(unpack(v))
			end
			OptionSelector:DockMargin(0,0,0,10)
			OptionSelector:Dock(TOP)
			function OptionSelector:OnSelect(index, name, value)
				func(value)
			end
			OptionSelector:SetValue(OptionSelector:GetOptionTextByData(default))
			
			return OptionSelector
		
		end
		
		local typetable = {
			{"Any gBalloon", "gballoon_*"},
			{"Any gBlimp", "gballoon_blimp_*"}
		}
		for k,v in pairs(classes) do
			table.insert(typetable, {list.GetForEdit("NPC")[v].Name, v})
		end
		Scroller:CreateEntry("Type:", typetable, function(value)
			currentparams[1] = value
		end, currentparams[1])

		--[[ List flags:
		1: +Fast
		2: -Fast
		4: +Hidden
		8: -Hidden
		16: +Regen
		32: -Regen
		64: +Shielded
		128: -Shielded]]
		
		Scroller.Modifier1 = Scroller:CreateEntry("Is Regen:", {{"#GameUI_Yes", 16}, {"#GameUI_No", 32}, {"Any", 48}}, function(value)
			currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(48)), value )
		end, bit.band(currentparams[2], 48))
		
		Scroller.Modifier3 = Scroller:CreateEntry("Is Fast:", {{"#GameUI_Yes", 1}, {"#GameUI_No", 2}, {"Any", 3}}, function(value)
			currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(3)), value )
		end, bit.band(currentparams[2], 3))
		
		Scroller.Modifier4 = Scroller:CreateEntry("Is Shielded:", {{"#GameUI_Yes", 64}, {"#GameUI_No", 128}, {"Any", 192}}, function(value)
			currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(192)), value )
		end, bit.band(currentparams[2], 192))
		
		Scroller.Modifier2 = Scroller:CreateEntry("Is Hidden:", {{"#GameUI_Yes", 4}, {"#GameUI_No", 8}, {"Any", 12}}, function(value)
			currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(12)), value )
		end, bit.band(currentparams[2], 12))
		
		local OKButton = vgui.Create("DButton", Scroller)
		OKButton:SetText(def_type and "Update Entry" or "Add Entry")
		OKButton:Dock(TOP)
		function OKButton:DoClick()
			Main:Close()
			run_func(currentparams)
		end
	end
	
	local function MakePopulationFunction(main_panel, list_panel, gballoon_list)
		local ToBeReturned
		ToBeReturned = function()
			list_panel:Clear()
			for k,v in pairs(gballoon_list) do
				local controlpanel = vgui.Create("DPanel", list_panel)
				controlpanel:SetTall(64)
				function controlpanel:Paint() end
				controlpanel:Dock(TOP)
				
				local buttonpanel = vgui.Create("DPanel", controlpanel)
				buttonpanel:SetWidth(32)
				function buttonpanel:Paint() end
				buttonpanel:Dock(RIGHT)
				
				local editbutton = vgui.Create("DImageButton", buttonpanel)
				editbutton:SetImage("icon16/cog.png")
				editbutton:SetTooltip("#GameUI_Modify")
				editbutton:SetTall(32)
				editbutton:Dock(TOP)
				function editbutton:DoClick()
					GetUserEntry(function(entry)
						if not IsValid(main_panel) then return end
						gballoon_list[k] = entry
						main_panel:SendToServer()
						ToBeReturned()
					end, v[1], v[2])
				end
				
				local removebutton = vgui.Create("DImageButton", buttonpanel)
				removebutton:SetImage("icon16/cancel.png")
				removebutton:SetTooltip("#GameUI_Remove")
				removebutton:Dock(FILL)
				function removebutton:DoClick()
					if not IsValid(main_panel) then return end
					table.remove(gballoon_list, k)
					main_panel:SendToServer()
					ToBeReturned()
				end
				
				local text = v[1] == "gballoon_*" and "All gBalloons" or v[1] == "gballoon_blimp_*" and "All gBlimps" or list.GetForEdit("NPC")[v[1]].Name.."s"
				if v[2] ~= 255 then
					local textparams = {}
					text = text.." that "
					if bit.band(v[2], 3) == 1 then
						table.insert(textparams, "are fast")
					elseif bit.band(v[2], 3) == 2 then
						table.insert(textparams, "are not fast")
					end
					if bit.band(v[2], 12) == 4 then
						table.insert(textparams, "are hidden")
					elseif bit.band(v[2], 12) == 8 then
						table.insert(textparams, "are not hidden")
					end
					if bit.band(v[2], 48) == 16 then
						table.insert(textparams, "can regenerate")
					elseif bit.band(v[2], 48) == 32 then
						table.insert(textparams, "can not regenerate")
					end
					if bit.band(v[2], 192) == 64 then
						table.insert(textparams, "are shielded")
					elseif bit.band(v[2], 192) == 128 then
						table.insert(textparams, "are not shielded")
					end
					
					local param_length = #textparams
					for i=1,param_length-2 do
						text = text..textparams[i]..", "
					end
					if param_length == 1 then
						text = text..textparams[1].."."
					else
						text = text..textparams[param_length-1].." and "..textparams[param_length].."."
					end
				else
					text = text.."."
				end
				
				local label = vgui.Create("DLabel", controlpanel)
				label:SetText(text)
				label:SetContentAlignment(7)
				label:SetWrap(true)
				label:Dock(FILL)
			end
		end
		return ToBeReturned
	end
	
	local function CreateBlacklistPanel(blacklist, whitelist)
		
		local Main = vgui.Create("DFrame")
		Main:SetSize(ScrH()/2,ScrH()/2)
		Main:Center()
		Main:SetTitle("Blacklist Editor")
		Main:SetSizable(true)
		Main:MakePopup()
		function Main:Paint(w,h)
			draw.RoundedBox(8,0,0,w,h,color_black_translucent)
			if self:HasFocus() then
				draw.RoundedBox(8,0,0,w,24,color_black)
			end
		end
		Main.Blacklist = blacklist
		Main.Whitelist = whitelist
		function Main:SendToServer()
			net.Start("rotgb_generic")
			net.WriteUInt(ROTGB_OPERATION_BLACKLIST, 8)
			net.WriteUInt(#self.Blacklist,32)
			for k,v in pairs(self.Blacklist) do
				net.WriteString(v[1])
				net.WriteUInt(v[2],8)
			end
			net.WriteUInt(#self.Whitelist,32)
			for k,v in pairs(self.Whitelist) do
				net.WriteString(v[1])
				net.WriteUInt(v[2],8)
			end
			net.SendToServer()
		end
		
		local WarningText = vgui.Create("DLabel", Main)
		WarningText:SetFont("DermaDefaultBold")
		WarningText:SetText("Warning: The blacklist also affects gBalloon Spawners and gBalloons' children!")
		WarningText:SetWrap(true)
		WarningText:SetAutoStretchVertical(true)
		WarningText:SetTextColor(color_red)
		WarningText:Dock(TOP)
		
		local Divider = vgui.Create("DHorizontalDivider",Main)
		Divider:Dock(FILL)
		Divider:SetDividerWidth(4)
		Divider:SetLeftWidth(ScrH()/4-7)
		
		local LeftPanel = vgui.Create("DPanel",Divider)
		LeftPanel:DockPadding(4,4,4,4)
		function LeftPanel:Paint(w,h)
			draw.RoundedBox(8,0,0,w,h,color_black_translucent)
		end
		Divider:SetLeft(LeftPanel)
		
		local LeftScrollPanel = vgui.Create("DScrollPanel", LeftPanel)
		LeftScrollPanel:Dock(FILL)
		LeftScrollPanel.Populate = MakePopulationFunction(Main, LeftScrollPanel, Main.Blacklist)
		LeftScrollPanel:Populate()
		
		local LeftHeader = vgui.Create("DPanel",LeftPanel)
		function LeftHeader:Paint() end
		LeftHeader:Dock(TOP)
		
		local LeftButton = vgui.Create("DButton",LeftHeader)
		LeftButton:SetText("Add New Entry")
		LeftButton:SetTextColor(color_aqua)
		LeftButton:SizeToContentsX(8)
		LeftButton:Dock(RIGHT)
		function LeftButton:DoClick()
			GetUserEntry(function(entry)
				if not IsValid(Main) then return end
				table.insert(Main.Blacklist, entry)
				Main:SendToServer()
				LeftScrollPanel:Populate()
			end)
		end
		function LeftButton:Paint(w,h)
			draw.RoundedBox(8,0,0,w,h,self:IsHovered() and color_gray_translucent or color_black_translucent)
		end
		
		local LeftText = vgui.Create("DLabel",LeftHeader)
		LeftText:SetText("Blacklist:")
		LeftText:Dock(FILL)
		
		local RightPanel = vgui.Create("DPanel",Divider)
		RightPanel:DockPadding(4,4,4,4)
		function RightPanel:Paint(w,h)
			draw.RoundedBox(8,0,0,w,h,color_black_translucent)
		end
		Divider:SetRight(RightPanel)
		
		local RightScrollPanel = vgui.Create("DScrollPanel", RightPanel)
		RightScrollPanel:Dock(FILL)
		RightScrollPanel.Populate = MakePopulationFunction(Main, RightScrollPanel, Main.Whitelist)
		RightScrollPanel:Populate()
		
		local RightHeader = vgui.Create("DPanel",RightPanel)
		function RightHeader:Paint() end
		RightHeader:Dock(TOP)
		
		local RightButton = vgui.Create("DButton",RightHeader)
		RightButton:SetText("Add New Entry")
		RightButton:SetTextColor(color_aqua)
		RightButton:SizeToContentsX(8)
		RightButton:Dock(RIGHT)
		function RightButton:DoClick()
			GetUserEntry(function(entry)
				if not IsValid(Main) then return end
				table.insert(Main.Whitelist, entry)
				Main:SendToServer()
				RightScrollPanel:Populate()
			end)
		end
		function RightButton:Paint(w,h)
			draw.RoundedBox(8,0,0,w,h,self:IsHovered() and color_gray_translucent or color_black_translucent)
		end
		
		local RightText = vgui.Create("DLabel",RightHeader)
		RightText:SetText("Except for:")
		RightText:Dock(FILL)
	end
	
	
	
	local function GetUserWaveCompEntry(run_func, defs)
		local currentparams = {"gballoon_*", 255, -1, -1, -1}
		
		--[[ List flags:
		1: +Fast
		2: -Fast
		4: +Hidden
		8: -Hidden
		16: +Regen
		32: -Regen
		64: +Shielded
		128: -Shielded]]
		
		if defs then
			local npcdata = list.GetForEdit("NPC")[defs[1]]
			local KVs = npcdata.KeyValues
			currentparams[1] = KVs.BalloonType
			local bits = currentparams[2]
			if tobool(KVs.BalloonFast) then
				bits = bits - 2
			else
				bits = bits - 1
			end
			if tobool(KVs.BalloonHidden) then
				bits = bits - 8
			else
				bits = bits - 4
			end
			if tobool(KVs.BalloonRegen) then
				bits = bits - 32
			else
				bits = bits - 16
			end
			if tobool(KVs.BalloonShielded) then
				bits = bits - 128
			else
				bits = bits - 64
			end
			currentparams[2], currentparams[3], currentparams[4], currentparams[5] = bits, defs[2] or 1, defs[3] or 0, defs[4] or 0
		end
		
		local Main = vgui.Create("DFrame")
		Main:SetSize(ScrH()*0.4,ScrH()*0.5)
		Main:Center()
		Main:SetTitle("Entry Maker")
		Main:SetSizable(true)
		Main:MakePopup()
		
		local Scroller = vgui.Create("DScrollPanel", Main)
		Scroller:Dock(FILL)
		
		function Scroller:CreateEntry(text, optiontable, func, default)
		
			local Text = vgui.Create("DLabel", self)
			Text:SetText(text)
			Text:Dock(TOP)
			
			local OptionSelector = vgui.Create("DComboBox", self)
			OptionSelector:SetSortItems(false)
			for i,v in ipairs(optiontable) do
				OptionSelector:AddChoice(unpack(v))
			end
			OptionSelector:DockMargin(0,0,0,10)
			OptionSelector:Dock(TOP)
			function OptionSelector:OnSelect(index, name, value)
				func(value)
			end
			OptionSelector:SetValue(OptionSelector:GetOptionTextByData(default))
			
			return OptionSelector
		
		end
		
		local typetable = {
			Either(defs,nil,{"< don't change >", "gballoon_*"})
		}
		for k,v in pairs(classes) do
			table.insert(typetable, {list.GetForEdit("NPC")[v].Name, v})
		end
		Scroller:CreateEntry("Type:", typetable, function(value)
			currentparams[1] = value
		end, currentparams[1])
		
		Scroller.Modifier1 = Scroller:CreateEntry("Is Regen:", {{"#GameUI_Yes", 16}, {"#GameUI_No", 32}, not defs and {"< don't change >", 48} or nil}, function(value)
			currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(48)), value )
		end, bit.band(currentparams[2], 48))
		
		Scroller.Modifier2 = Scroller:CreateEntry("Is Fast:", {{"#GameUI_Yes", 1}, {"#GameUI_No", 2}, not defs and {"< don't change >", 3} or nil}, function(value)
			currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(3)), value )
		end, bit.band(currentparams[2], 3))
		
		Scroller.Modifier3 = Scroller:CreateEntry("Is Shielded:", {{"#GameUI_Yes", 64}, {"#GameUI_No", 128}, not defs and {"< don't change >", 192} or nil}, function(value)
			currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(192)), value )
		end, bit.band(currentparams[2], 192))
		
		Scroller.Modifier4 = Scroller:CreateEntry("Is Hidden:", {{"#GameUI_Yes", 4}, {"#GameUI_No", 8}, not defs and {"< don't change >", 12} or nil}, function(value)
			currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(12)), value )
		end, bit.band(currentparams[2], 12))
		
		function Main:CreateNumSlider(argnum, low, dec, text)
			local AmountSelector = vgui.Create("DNumSlider", Main)
			AmountSelector:SetText(text.." (-1 = don't change)")
			AmountSelector:Dock(TOP)
			AmountSelector:SetMin(-1)
			AmountSelector:SetMax(300)
			AmountSelector:SetDecimals(dec)
			AmountSelector:SetDefaultValue(low)
			AmountSelector:SetValue(currentparams[argnum])
			function AmountSelector:OnValueChanged(value)
				currentparams[argnum] = value
			end
		end
		
		Main:CreateNumSlider(3, 1, 0, "Amount")
		Main:CreateNumSlider(4, 0, 2, "Timespan")
		Main:CreateNumSlider(5, 0, 2, "Delay")
		
		local OKButton = vgui.Create("DButton", Scroller)
		OKButton:SetText("Modify Entry")
		OKButton:Dock(TOP)
		function OKButton:DoClick()
			Main:Close()
			run_func(currentparams)
		end
		
		return Main
	end
	
	local function GetUserWaveEntry(wavedata, run_func)
		
		local Main = vgui.Create("DFrame")
		Main:SetSize(ScrH()*0.6,ScrH()*0.6)
		Main:Center()
		Main:SetTitle("Wave Editor")
		Main:SetSizable(true)
		Main:MakePopup()
		function Main:Paint(w,h)
			draw.RoundedBox(8,0,0,w,h,color_black_translucent)
			if Main:HasFocus() then
				draw.RoundedBox(8,0,0,w,24,color_black)
			end
		end
		--[[function Main:SwitchBoolsToText(booly,booln)
			return tobool(booly) and not tobool(booln) and "#GameUI_Yes" or "#GameUI_No"
		end]]
		
		local buttonpanel = vgui.Create("DPanel", Main)
		buttonpanel:SetWidth(32)
		function buttonpanel:Paint() end
		buttonpanel:Dock(RIGHT)
		
		local WaveComponents = vgui.Create("DListView", Main)
		WaveComponents:Dock(FILL)
		WaveComponents:SetMultiSelect(true)
		local col = WaveComponents:AddColumn("Type")
		col:SetWidth(250)
		WaveComponents:AddColumn("Amount")
		WaveComponents:AddColumn("Timespan")
		WaveComponents:AddColumn("Delay")
		function WaveComponents:OnRowSelected()
			if not self.first then
				for k,v in pairs(buttonpanel:GetChildren()) do
					v:Show()
				end
				self.first = true
			end
		end
		
		function Main:GetWaveStats()
			local rbe, duration = 0, 0
			for k,v in pairs(WaveComponents:GetLines()) do
				local npcdata = list.GetForEdit("NPC")[v.wavecomp[1]]
				local KVs = npcdata.KeyValues
				--[[PrintTable(scripted_ents.GetStored("gballoon_base").t.rotgb_rbetab)
				print(KVs.BalloonType)
				print(scripted_ents.GetStored("gballoon_base").t.rotgb_rbetab[KVs.BalloonType])
				print(tobool(KVs.BalloonShielded) and 2 or 1)]]
				--PrintTable(v.wavecomp)
				rbe = rbe + scripted_ents.GetStored("gballoon_base").t.rotgb_rbetab[KVs.BalloonType]*(tobool(KVs.BalloonShielded) and 2 or 1)*(v.wavecomp[2] or 1)
				duration = math.max(duration, (v.wavecomp[3] or 0)+(v.wavecomp[4] or 0))
			end
			return rbe, duration
		end
		
		local lineclassfunc = function(self)
			local npcdata = list.GetForEdit("NPC")[self.wavecomp[1]]
			local name = npcdata.Name
			local KVs = npcdata.KeyValues
			
			if tobool(KVs.BalloonShielded) then
				name = "Shielded " .. name
			end
			if tobool(KVs.BalloonRegen) then
				name = "Regen " .. name
			end
			if tobool(KVs.BalloonHidden) then
				name = "Hidden " .. name
			end
			if tobool(KVs.BalloonFast) then
				name = "Fast " .. name
			end
			
			self:SetColumnText(1, name)
			self:SetColumnText(2, self.wavecomp[2] or 1)
			self:SetColumnText(3, self.wavecomp[3] or 0)
			self:SetColumnText(4, self.wavecomp[4] or 0)
		end
		
		local addbutton = vgui.Create("DImageButton", buttonpanel)
		addbutton:SetImage("icon16/add.png")
		addbutton:SetTooltip("#GameUI_Add")
		addbutton:SetTall(32)
		addbutton:Dock(TOP)
		function addbutton:DoClick()
			local Line = WaveComponents:AddLine("Red gBalloon", 1, 0, 0)
			Line.wavecomp = {"gballoon_red"}
			Line.Refresh = lineclassfunc
		end
		
		local editbutton = vgui.Create("DImageButton", buttonpanel)
		editbutton:SetImage("icon16/cog.png")
		editbutton:SetTooltip("#GameUI_Modify")
		editbutton:SetTall(32)
		editbutton:Dock(TOP)
		editbutton:Hide()
		editbutton.HideOnDeselect = true
		function editbutton:DoClick()
			local liness = WaveComponents:GetSelected()
			--if #liness > 1 then
				local wpanel = GetUserWaveCompEntry(function(compdata)
					if IsValid(Main) then
						for k,v in pairs(liness) do
							--[[print("START:")
							PrintTable(v.wavecomp)
							print("MERGE:")
							PrintTable(compdata)]]
							local npcdata = list.GetForEdit("NPC")[v.wavecomp[1]]
							local KVs = npcdata.KeyValues
							local name, bits = "gballoon_", compdata[2]
							if bit.band(bits,3)==1 then
								name = name.."fast_"
							elseif bit.band(bits,3)==3 and tobool(KVs.BalloonFast) then
								name = name.."fast_"
							end
							if bit.band(bits,12)==4 then
								name = name.."hidden_"
							elseif bit.band(bits,12)==12 and tobool(KVs.BalloonHidden) then
								name = name.."hidden_"
							end
							if bit.band(bits,48)==16 then
								name = name.."regen_"
							elseif bit.band(bits,48)==48 and tobool(KVs.BalloonRegen) then
								name = name.."regen_"
							end
							if bit.band(bits,192)==64 then
								name = name.."shielded_"
							elseif bit.band(bits,192)==192 and tobool(KVs.BalloonShielded) then
								name = name.."shielded_"
							end
							local dname = compdata[1] ~= "gballoon_*" and compdata[1] or v.wavecomp[1]
							v.wavecomp[1] = name .. (dname:match("blimp_%w+$") or dname:match("%w+$"))
							if compdata[3] >= 0 then
								v.wavecomp[2] = compdata[3] > 1 and math.Round(compdata[3])
							end
							if compdata[4] >= 0 then
								v.wavecomp[3] = compdata[4] > 0 and compdata[4]
							end
							if compdata[5] >= 0 then
								v.wavecomp[4] = compdata[5] > 0 and compdata[5]
							end
							v:Refresh()
						end
					end
				end, #liness == 1 and liness[1].wavecomp)
			--[[else
				GetUserWaveCompEntry(function(d)
					local v = WaveComponents:GetSelectedLine()
					select(2,v).wavecomp = d
					v:Refresh()
				end)
			end]]
		end
		
		local removebutton = vgui.Create("DImageButton", buttonpanel)
		removebutton:SetImage("icon16/delete.png")
		removebutton:SetTooltip("#GameUI_Remove")
		removebutton:SetTall(32)
		removebutton:Dock(TOP)
		removebutton:Hide()
		removebutton.HideOnDeselect = true
		function removebutton:DoClick()
			Derma_Query("Are you sure?","#GameUI_Remove","#GameUI_Yes",function()
				for k,v in pairs(WaveComponents:GetSelected()) do
					WaveComponents:RemoveLine(v:GetID())
				end
				for k,v in pairs(buttonpanel:GetChildren()) do
					if v.HideOnDeselect then
						v:Hide()
					end
				end
				WaveComponents.first = false
			end,"#GameUI_No")
		end 
		
		--[[local upbutton = vgui.Create("DImageButton", buttonpanel)
		upbutton:SetImage("icon16/arrow_up.png")
		upbutton:SetTooltip("#tool.hoverball.up")
		upbutton:SetTall(32)
		upbutton:Dock(TOP)
		upbutton:Hide()
		upbutton.HideOnDeselect = true
		function upbutton:DoClick()
		end
		
		local downbutton = vgui.Create("DImageButton", buttonpanel)
		downbutton:SetImage("icon16/bullet_arrow_bottom.png")
		downbutton:SetTooltip("Move to Bottom")
		downbutton:SetTall(32)
		downbutton:Dock(TOP)
		downbutton:Hide()
		downbutton.HideOnDeselect = true
		function downbutton:DoClick()
			for k,v in pairs(WaveComponents:GetSelected()) do
				
			end
		end]]
		
		local acceptbutton = vgui.Create("DImageButton", buttonpanel)
		acceptbutton:SetImage("icon16/tick.png")
		acceptbutton:SetTooltip("#GameUI_Accept")
		acceptbutton:SetTall(32)
		acceptbutton:Dock(BOTTOM)
		function acceptbutton:DoClick()
			local preptable = {}
			for i,v in ipairs(WaveComponents:GetLines()) do
				table.insert(preptable,v.wavecomp)
			end
			preptable.rbe, preptable.duration = Main:GetWaveStats()
			Main:Close()
			run_func(preptable)
		end
		
		local cancelbutton = vgui.Create("DImageButton", buttonpanel)
		cancelbutton:SetImage("icon16/cross.png")
		cancelbutton:SetTooltip("#GameUI_Cancel")
		cancelbutton:SetTall(32)
		cancelbutton:Dock(BOTTOM)
		function cancelbutton:DoClick()
			Main:Close()
		end
		
		for i,v in ipairs(wavedata) do
			local Line = WaveComponents:AddLine("INVALID", -1, -1, -1)
			Line.wavecomp = v
			--Line.ID = i
			Line.Refresh = lineclassfunc
			Line:Refresh()
		end
		
	end
	
	local acceptmat = Material("icon16/tick.png")
	
	local localWaves, localEdited = {}
	
	local function CreateWavePanel()
		
		local Main = vgui.Create("DFrame")
		Main:SetSize(ScrH()*0.5,ScrH()*0.5)
		Main:Center()
		Main:SetTitle("Wave Editor")
		Main:SetSizable(true)
		Main:MakePopup()
		function Main:Paint(w,h)
			draw.RoundedBox(8,0,0,w,h,color_black_translucent)
			if Main:HasFocus() then
				draw.RoundedBox(8,0,0,w,24,color_black)
			end
		end
		function Main:SupplyFileSelector(rtext, rfunc)
			return function()
				local FileMain = vgui.Create("DFrame")
				FileMain:SetSize(ScrH()*0.5,ScrH()*0.5)
				FileMain:Center()
				FileMain:MakePopup()
				
				if not file.IsDir("rotgb_wavedata", "DATA") then
					file.CreateDir("rotgb_wavedata")
				end
				
				local ButtonPanel = vgui.Create("DPanel", FileMain)
				function ButtonPanel:Paint() end
				
				local FileEntry = vgui.Create("DTextEntry", ButtonPanel)
				FileEntry:Dock(FILL)
				FileEntry:SetPlaceholderText("Enter a file name")
				
				--[[function FileBrowser:OnSelect(path)
					
				end]]
				
				local OKButton = vgui.Create("DButton", ButtonPanel)
				OKButton:SetText(rtext)
				OKButton:SizeToContentsX(8)
				OKButton:SizeToContentsY(8)
				
				ButtonPanel:SetHeight(OKButton:GetTall())
				ButtonPanel:Dock(BOTTOM)
				
				OKButton:Dock(RIGHT)
				
				local FileBrowser = vgui.Create("DTree", FileMain)
				FileBrowser:Dock(FILL)
				function FileBrowser:Refresh()
					FileBrowser:Clear()
					local FolderNode = FileBrowser:AddNode("data/rotgb_wavedata")
					for k,v in pairs(file.Find("rotgb_wavedata/*.dat","DATA")) do
						local FileNode = FolderNode:AddNode(v, "icon16/page.png")
						function FileNode:DoClick()
							
							FileEntry:SetValue(string.gsub(v, "^(.*)%.dat$", "%1"))
							
						end
						function FileNode:DoRightClick()
							
							local FileMenu = DermaMenu()
							FileMenu:AddOption("#GameUI_Delete", function()
								Derma_Query("Are you sure?","#GameUI_Delete","#GameUI_Yes",function()
									file.Delete("rotgb_wavedata/"..v)
									FileBrowser:Refresh()
								end,"#GameUI_No")
							end)
							FileMenu:AddOption("Rename", function()
								Derma_StringRequest("Rename","Enter New Name",Main.FileName,function(text)
									file.Rename("rotgb_wavedata/"..v, "rotgb_wavedata/"..text..".dat")
									FileBrowser:Refresh()
								end,nil,"Rename")
							end)
							FileMenu:Open()
							
						end
					end
				end
				FileBrowser:Refresh()
				
				--[[FileBrowser:SetPath("DATA")
				FileBrowser:SetBaseFolder("rotgb_wavedata")
				FileBrowser:SetName("data/rotgb_wavedata")]]
				
				function OKButton:DoClick()
					if FileEntry:GetValue()=="" then
						Derma_Message("Please enter a file name.",rtext,"#GameUI_OK")
					else
						rfunc("rotgb_wavedata/"..FileEntry:GetValue()..".dat", FileMain)
					end
				end
			end
		end
		Main.btnMaxim:SetEnabled(true)
		function Main.btnMaxim:DoClick()
			if Main.OldBounds then
				Main:SetSize(Main.OldBounds[3],Main.OldBounds[4])
				Main:SetPos(Main.OldBounds[1],Main.OldBounds[2])
				Main:SetDraggable(true)
				Main:SetSizable(true)
				Main.OldBounds = nil
			else
				Main.OldBounds = {Main:GetBounds()}
				Main:SetSize(ScrW(),ScrH())
				Main:SetPos(0,0)
				Main:SetDraggable(false)
				Main:SetSizable(false)
			end
		end
		Main.FileName = ""
		
		local HeadingBar = vgui.Create("DMenuBar", Main)
		HeadingBar:Dock(TOP)
		
		local ScrollPanel = vgui.Create("DScrollPanel", Main)
		ScrollPanel:Dock(FILL)
		
		local FileMenu = HeadingBar:AddMenu("File")
		
		FileMenu:AddOption("#GameUI_SaveGame_New", function()
			if localEdited then
				Derma_Query("Are you sure?","#GameUI_SaveGame_New","#GameUI_Yes",function()
					if not IsValid(Main) then return end
					localEdited = false
					localWaves = {}
					ScrollPanel:Populate()
				end,"#GameUI_No")
			else
				localWaves = {}
				ScrollPanel:Populate()
			end
		end):SetIcon("icon16/page_white.png")
		
		FileMenu:AddOption("#GameUI_Save", Main:SupplyFileSelector("#GameUI_Save", function(path, window)
			if not IsValid(Main) then return end
			if file.Exists(path, "DATA") then
				Derma_Query("Are you sure?","#GameUI_SaveGame_Overwrite","#GameUI_ConfirmOverwriteSaveGame_OK",function()
					if not IsValid(Main) then return end
					file.Write(path, util.Compress(util.TableToJSON(localWaves)))
					localEdited = false
					window:Close()
				end,"#GameUI_No")
			else
				file.Write(path, util.Compress(util.TableToJSON(localWaves)))
				localEdited = false
				window:Close()
			end
		end)):SetIcon("icon16/disk.png")
		
		FileMenu:AddOption("#GameUI_Load", Main:SupplyFileSelector("#GameUI_Load", function(path, window)
			if not IsValid(Main) then return end
			local rawdata = file.Read(path)
			if rawdata then
				rawdata = util.JSONToTable(util.Decompress(rawdata))
				if rawdata then
					localWaves = rawdata
					localEdited = false
					window:Close()
					ScrollPanel:Populate()
				else
					Derma_Message("File decoding failed. It may have been corrupted.","#GameUI_LoadFailed","#GameUI_OK")
				end
			else
				Derma_Message("File not found.","#GameUI_LoadFailed","#GameUI_OK")
			end
		end)):SetIcon("icon16/folder_page.png")
		
		FileMenu:AddOption("Load Default Waves", function()
			if localEdited then
				Derma_Query("Are you sure?","Load Default Waves","#GameUI_Yes",function()
					if not IsValid(Main) then return end
					localEdited = false
					localWaves = table.Copy(ROTGB_WAVES)
					ScrollPanel:Populate()
				end,"#GameUI_No")
			else
				localWaves = table.Copy(ROTGB_WAVES)
				ScrollPanel:Populate()
			end
		end):SetIcon("icon16/arrow_refresh.png")
		
		FileMenu:AddSpacer()
		
		FileMenu:AddOption("Save to Server (Multiplayer Only)", function() 
			if not LocalPlayer():IsAdmin() then
				return Derma_Message("You don't have administrator privileges!","#GameUI_LoadFailed","#GameUI_OK")
			end
			if game.SinglePlayer() then
				return Derma_Message("This option is only useful in multiplayer.","#GameUI_ServerAuthDisabled","#GameUI_OK")
			end
			Main:SupplyFileSelector("Save to Server", function(path, window)
				if not IsValid(Main) then return end
				local rawdata = file.Read(path)
				if rawdata then
					local textdata = util.JSONToTable(util.Decompress(rawdata))
					if textdata then
						local packetlength = 60000
						local datablocks = math.ceil(#rawdata/packetlength)
						for i=1,datablocks do
							net.Start("rotgb_generic")
							net.WriteUInt(ROTGB_OPERATION_WAVE_TRANSFER, 8)
							net.WriteString(string.gsub(path, "^rotgb_wavedata/(.*)%.dat$", "%1"))
							net.WriteUInt(datablocks, 16)
							net.WriteUInt(i, 16)
							local datafrac = rawdata:sub(packetlength*(i-1)+1, packetlength*i)
							net.WriteUInt(#datafrac, 16)
							net.WriteData(datafrac, #datafrac)
							net.SendToServer()
						end
					else
						Derma_Message("File decoding failed. It may have been corrupted.","#GameUI_LoadFailed","#GameUI_OK")
					end
				else
					Derma_Message("File not found.","#GameUI_LoadFailed","#GameUI_OK")
				end
			end)()
		end):SetIcon("icon16/transmit_go.png")
		
		FileMenu = HeadingBar:AddMenu("Edit")
		
		--[[local FileSubMenu, FileButton = FileMenu:AddSubMenu("Add New Wave")
		FileButton:SetIcon("icon16/add.png")]]
		
		FileMenu:AddOption("Add New Wave (from top)", function()
			localEdited = true
			table.insert(localWaves, 1, { {"gballoon_red",10,10}, rbe=10, duration=10} )
			ScrollPanel:Populate()
		end):SetIcon("icon16/add.png")
		
		FileMenu:AddOption("Add New Wave (from bottom)", function()
			localEdited = true
			table.insert(localWaves, { {"gballoon_red",10,10}, rbe=10, duration=10} )
			ScrollPanel:Populate()
		end):SetIcon("icon16/add.png")
		
		function ScrollPanel:Populate()
			self:Clear()
			local rbelist = scripted_ents.GetStored("gballoon_base").t.rotgb_rbetab
			for i,v in ipairs(localWaves) do
				local controlpanel = vgui.Create("DPanel", self)
				controlpanel:SetTall(128)
				function controlpanel:Paint(w,h)
					draw.RoundedBox(8,0,0,w,h,color_black_translucent)
				end
				controlpanel:DockMargin(0,4,0,0)
				controlpanel:Dock(TOP)
				
				local buttonpanel = vgui.Create("DPanel", controlpanel)
				buttonpanel:SetWidth(64)
				function buttonpanel:Paint() end
				buttonpanel:Dock(RIGHT)
				
				local editbutton = vgui.Create("DImageButton", buttonpanel)
				editbutton:SetImage("icon16/cog.png")
				editbutton:SetTooltip("#GameUI_Modify")
				editbutton:SetSize(32,32)
				editbutton:SetPos(0,32)
				function editbutton:DoClick()
					GetUserWaveEntry(v,function(wavedata)
						localEdited = true
						--PrintTable(wavedata)
						if IsValid(Main) then
							localWaves[i] = wavedata
							ScrollPanel:Populate()
						end
					end)
				end
				
				local removebutton = vgui.Create("DImageButton", buttonpanel)
				removebutton:SetImage("icon16/cancel.png")
				removebutton:SetTooltip("#GameUI_Remove")
				removebutton:SetSize(32,32)
				removebutton:SetPos(32,32)
				function removebutton:DoClick()
					Derma_Query("Are you sure?","#GameUI_Remove","#GameUI_Yes",function()
						localEdited = true
						if not IsValid(Main) then return end
						table.remove(localWaves, i)
						ScrollPanel:Populate()
					end,"#GameUI_No")
				end
				
				local copybutton = vgui.Create("DImageButton", buttonpanel)
				copybutton:SetImage("icon16/page_copy.png")
				copybutton:SetTooltip("#spawnmenu.menu.copy")
				copybutton:SetSize(32,32)
				copybutton:SetPos(0,64)
				function copybutton:DoClick()
					SetClipboardText(util.TableToJSON(v))
					copybutton.realtimeset = RealTime() + 1
				end
				function copybutton:PaintOver()
					if (copybutton.realtimeset or 0) > RealTime() then
						surface.SetMaterial(acceptmat)
						surface.SetDrawColor(255,255,255,255*math.sqrt(copybutton.realtimeset-RealTime()))
						self:DrawTexturedRect()
					end
				end
				
				local pastebutton = vgui.Create("DImageButton", buttonpanel)
				pastebutton:SetImage("icon16/page_paste.png")
				pastebutton:SetTooltip("Paste / Import")
				pastebutton:SetSize(32,32)
				pastebutton:SetPos(32,64)
				function pastebutton:DoClick()
					Derma_StringRequest("Paste / Import","Paste textual wave data below, then press \"Import\".","",function(text)
						local data = util.JSONToTable(text)
						if (data and data.rbe and data.duration) then
							localEdited = true
							localWaves[i] = data
							ScrollPanel:Populate()
						else
							Derma_Message("Wave data was invalid!","JSON Error","#GameUI_OK")
						end
					end,nil,"Import")
				end
				
				if i ~= 1 then
					local upbutton = vgui.Create("DImageButton", buttonpanel)
					upbutton:SetImage("icon16/bullet_arrow_up.png")
					upbutton:SetTooltip("Move Up")
					upbutton:SetSize(32,32)
					upbutton:SetPos(0,0)
					function upbutton:DoClick()
						localEdited = true
						table.insert(localWaves, i-1, table.remove(localWaves, i))
						ScrollPanel:Populate()
					end
					
					local superupbutton = vgui.Create("DImageButton", buttonpanel)
					superupbutton:SetImage("icon16/bullet_arrow_top.png")
					superupbutton:SetTooltip("Move To Top")
					superupbutton:SetSize(32,32)
					superupbutton:SetPos(32,0)
					function superupbutton:DoClick()
						localEdited = true
						table.insert(localWaves, 1, table.remove(localWaves, i))
						ScrollPanel:Populate()
					end
				end
				
				if i ~= #localWaves then
					local downbutton = vgui.Create("DImageButton", buttonpanel)
					downbutton:SetImage("icon16/bullet_arrow_down.png")
					downbutton:SetTooltip("Move Down")
					downbutton:SetSize(32,32)
					downbutton:SetPos(0,96)
					function downbutton:DoClick()
						localEdited = true
						table.insert(localWaves, i+1, table.remove(localWaves, i))
						ScrollPanel:Populate()
					end
					
					local superdownbutton = vgui.Create("DImageButton", buttonpanel)
					superdownbutton:SetImage("icon16/bullet_arrow_bottom.png")
					superdownbutton:SetTooltip("Move To Bottom")
					superdownbutton:SetSize(32,32)
					superdownbutton:SetPos(32,96)
					function superdownbutton:DoClick()
						localEdited = true
						table.insert(localWaves, table.remove(localWaves, i))
						ScrollPanel:Populate()
					end
				end
				
				local balloons, rbe, duration = {}, 0
				for k2, v2 in pairs(v) do
					if k2 == "rbe" then
						rbe = v2
					elseif k2 == "duration" then
						duration = v2
					elseif tonumber(k2) then
						balloons[v2[1]] = (balloons[v2[1]] or 0) + (v2[2] or 1)
					end
				end
				
				local balloonkeys = table.GetKeys(balloons)
				table.sort(balloonkeys, function(a,b)
					local npcdata1 = list.GetForEdit("NPC")[a]
					local KV1 = npcdata1.KeyValues
					local npcdata2 = list.GetForEdit("NPC")[b]
					local KV2 = npcdata2.KeyValues
					local rbe1 = rbelist[KV1.BalloonType]
					local rbe2 = rbelist[KV2.BalloonType]
					if rbe1 == rbe2 then
						rbe1, rbe2 = tobool(KV1.BalloonFast), tobool(KV2.BalloonFast)
						if rbe1 == rbe2 then
							rbe1, rbe2 = tobool(KV1.BalloonHidden), tobool(KV2.BalloonHidden)
							if rbe1 == rbe2 then
								rbe1, rbe2 = tobool(KV1.BalloonRegen), tobool(KV2.BalloonRegen)
								if rbe1 == rbe2 then return tobool(KV1.BalloonShielded)
								else return rbe1
								end
							else return rbe1
							end
						else return rbe1
						end
					else
						return rbe1 > rbe2 
					end
				end)
				
				local wavelabel = vgui.Create("DLabel", controlpanel)
				wavelabel:SetText("Wave "..i.." (RgBE: "..rbe..(duration and ", Duration: "..duration or "")..")")
				wavelabel:SetFont("DermaDefaultBold")
				wavelabel:SizeToContentsY()
				wavelabel:Dock(TOP)
				
				local wavecontents = vgui.Create("RichText", controlpanel)
				wavecontents:SetText("")
				wavecontents:SetVerticalScrollbarEnabled()
				wavecontents:Dock(FILL)
				function wavecontents:PerformLayout()
					self:SetFontInternal("DermaDefault")
					if self:GetNumLines() > 9 then
						self:SetVerticalScrollbarEnabled(true)
					end
				end
				
				for i2,v2 in ipairs(balloonkeys) do
					local npcdata = list.GetForEdit("NPC")[v2]
					local KVs = npcdata.KeyValues
					local hue,sat,val = ColorToHSV(string.ToColor(KVs.BalloonColor))
					if sat == 1 then val = 1 end
					sat = sat / 2
					val = (val + 1) / 2
					local col = HSVToColor(hue,sat,val)
					wavecontents:InsertColorChange(col.r,col.g,col.b,col.a)
					wavecontents:AppendText(balloons[v2] .. "x ")
					if tobool(KVs.BalloonFast) then
						wavecontents:AppendText("Fast ")
					end
					if tobool(KVs.BalloonHidden) then
						wavecontents:AppendText("Hidden ")
					end
					if tobool(KVs.BalloonRegen) then
						wavecontents:AppendText("Regen ")
					end
					if tobool(KVs.BalloonShielded) then
						wavecontents:AppendText("Shielded ")
					end
					wavecontents:AppendText(npcdata.Name.."\n")
				end
			end
		end
		ScrollPanel:Populate()
		
	end
	
	ROTGB_CLIENTWAVES = {}
	
	net.Receive("rotgb_generic",function()
		local operation = net.ReadUInt(8)
		if operation == ROTGB_OPERATION_BLACKLIST then
			local blacklist, whitelist = {}, {}
			for i=1, net.ReadUInt(32) do
				table.insert(blacklist, {net.ReadString(), net.ReadUInt(8)})
			end
			for i=1, net.ReadUInt(32) do
				table.insert(whitelist, {net.ReadString(), net.ReadUInt(8)})
			end
			CreateBlacklistPanel(blacklist, whitelist)
		elseif operation == ROTGB_OPERATION_WAVE_EDIT then
			CreateWavePanel()
		elseif operation == ROTGB_OPERATION_WAVE_TRANSFER then
			local wavename, totalpackets, currentpacket, bytes = net.ReadString(), net.ReadUInt(16), net.ReadUInt(16), net.ReadUInt(16)
			local datachunk = net.ReadData(bytes)
			ROTGB_CLIENTWAVES[wavename] = ROTGB_CLIENTWAVES[wavename] or {}
			if ROTGB_CLIENTWAVES[wavename].rbe then
				table.Empty(ROTGB_CLIENTWAVES[wavename])
			end
			ROTGB_CLIENTWAVES[wavename][currentpacket] = datachunk
			if #ROTGB_CLIENTWAVES[wavename] == totalpackets then
				local wavedata = util.JSONToTable(util.Decompress(table.concat(ROTGB_CLIENTWAVES[wavename])))
				table.Empty(ROTGB_CLIENTWAVES[wavename])
				ROTGB_CLIENTWAVES[wavename] = wavedata
			end
		elseif operation == ROTGB_OPERATION_ACHIEVEMENT then
			for i=1, net.ReadUInt(32) do
				achievements.BalloonPopped()
			end
		end
	end)
	
	CreateMaterial("gBalloonZebra","VertexLitGeneric",{
		["$basetexture"] = "effects/flashlight/bars",
		["$model"] = 1,
		["$vertexcolor"] = 1
	})
	CreateMaterial("gBalloonError","VertexLitGeneric",{
		["$basetexture"] = "___error",
		["$model"] = 1,
		["$vertexcolor"] = 1
	})
	CreateMaterial("gBalloonRainbow","VertexLitGeneric",{
		["$basetexture"] = "vgui/hsv-bar",
		["$model"] = 1,
		["$vertexcolor"] = 1
	})
end

local minuteclass = {Base = "base_anim", Type = "anim"}

local registerkeys = {
	red = {
		Name = "Red gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "100",
			BalloonScale = "1",
			BalloonColor = "255 0 0 255",
			BalloonType = "gballoon_red"
		}
	},
	blue = {
		Name = "Blue gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "125",
			BalloonScale = "1.25",
			BalloonColor = "0 127 255 255",
			BalloonType = "gballoon_blue"
		}
	},
	green = {
		Name = "Green gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "150",
			BalloonScale = "1.5",
			BalloonColor = "127 255 0 255",
			BalloonType = "gballoon_green"
		}
	},
	yellow = {
		Name = "Yellow gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "175",
			BalloonScale = "1.75",
			BalloonColor = "255 255 0 255",
			BalloonType = "gballoon_yellow"
		}
	},
	pink = {
		Name = "Pink gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "200",
			BalloonScale = "2",
			BalloonColor = "255 127 127 255",
			BalloonType = "gballoon_pink"
		}
	},
	white = {
		Name = "White gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "150",
			BalloonScale = "0.75",
			BalloonColor = "255 255 255 255",
			BalloonType = "gballoon_white",
			BalloonWhite = "1"
		}
	},
	black = {
		Name = "Black gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "150",
			BalloonScale = "0.75",
			BalloonColor = "0 0 0 255",
			BalloonType = "gballoon_black",
			BalloonBlack = "1"
		}
	},
	purple = {
		Name = "Purple gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "150",
			BalloonScale = "1.5",
			BalloonColor = "127 0 255 255",
			BalloonType = "gballoon_purple",
			BalloonPurple = "1"
		}
	},
	orange = {
		Name = "Orange gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "250",
			BalloonScale = "2.5",
			BalloonColor = "255 127 0 255",
			BalloonType = "gballoon_orange"
		}
	},
	gray = {
		Name = "Gray gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "175",
			BalloonScale = "1.75",
			BalloonColor = "127 127 127 255",
			BalloonType = "gballoon_gray",
			BalloonMaterial = "phoenix_storms/side",
			BalloonGray = "1"
		}
	},
	zebra = {
		Name = "Zebra gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "175",
			BalloonScale = "1.75",
			BalloonColor = "255 255 255 255",
			BalloonType = "gballoon_zebra",
			BalloonMaterial = "!gBalloonZebra",
			BalloonWhite = "1",
			BalloonBlack = "1"
		}
	},
	aqua = {
		Name = "Aqua gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "175",
			BalloonScale = "1.75",
			BalloonColor = "0 255 255 255",
			BalloonType = "gballoon_aqua",
			BalloonAqua = "1"
		}
	},
	error = {
		Name = "Error gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "175",
			BalloonScale = "1.75",
			BalloonColor = "255 0 255 255",
			BalloonType = "gballoon_error",
			BalloonMaterial = "!gBalloonError",
			BalloonArmor = "1",
			BalloonBlack = "1"
		}
	},
	rainbow = {
		Name = "Rainbow gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "225",
			BalloonScale = "2.25",
			BalloonColor = "255 255 255 255",
			BalloonType = "gballoon_rainbow",
			BalloonMaterial = "!gBalloonRainbow",
			BalloonRainbow = "1"
		}
	},
	ceramic = {
		Name = "Ceramic gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "175",
			BalloonScale = "1.75",
			BalloonColor = "127 63 0 255",
			BalloonType = "gballoon_ceramic",
			BalloonMaterial = "models/props_debris/plasterceiling008a",
			BalloonHealth = "10"
		}
	},
	brick = {
		Name = "Brick gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "150",
			BalloonScale = "2",
			BalloonColor = "255 63 63 255",
			BalloonType = "gballoon_brick",
			BalloonMaterial = "brick/brick_model",
			BalloonHealth = "30",
			BalloonMaxDamage = "4"
		}
	},
	marble = {
		Name = "Marble gBalloon",
		KeyValues = {
			BalloonMoveSpeed = "125",
			BalloonScale = "2.25",
			BalloonColor = "255 255 255 255",
			BalloonType = "gballoon_marble",
			BalloonMaterial = "phoenix_storms/plastic",
			BalloonHealth = "60",
			BalloonMaxDamage = "4"
		}
	},
	blimp_blue = {
		Name = "Blue gBlimp",
		KeyValues = {
			BalloonMoveSpeed = "175",
			BalloonScale = "2",
			BalloonColor = "0 127 255 255",
			BalloonType = "gballoon_blimp_blue",
			BalloonMaterial = "models/debug/debugwhite",
			BalloonModel = "models/props_phx/ww2bomb.mdl",
			BalloonHealth = "200",
			BalloonBlimp = "1",
			BalloonPopSound = "ambient/explosions/explode_5.wav"
		}
	},
	blimp_red = {
		Name = "Red gBlimp",
		KeyValues = {
			BalloonMoveSpeed = "150",
			BalloonScale = "2.25",
			BalloonColor = "255 0 0 255",
			BalloonType = "gballoon_blimp_red",
			BalloonMaterial = "models/debug/debugwhite",
			BalloonModel = "models/props_phx/ww2bomb.mdl",
			BalloonHealth = "700",
			BalloonBlimp = "1",
			BalloonPopSound = "ambient/explosions/explode_5.wav"
		}
	},
	blimp_green = {
		Name = "Green gBlimp",
		KeyValues = {
			BalloonMoveSpeed = "125",
			BalloonScale = "2.5",
			BalloonColor = "0 255 0 255",
			BalloonType = "gballoon_blimp_green",
			BalloonMaterial = "models/debug/debugwhite",
			BalloonModel = "models/props_phx/ww2bomb.mdl",
			BalloonHealth = "4000",
			BalloonBlimp = "1",
			BalloonPopSound = "ambient/explosions/explode_5.wav"
		}
	},
	blimp_gray = {
		Name = "Monochrome gBlimp",
		KeyValues = {
			BalloonMoveSpeed = "150",
			BalloonScale = "2",
			BalloonColor = "127 127 127 255",
			BalloonType = "gballoon_blimp_gray",
			BalloonMaterial = "models/debug/debugwhite",
			BalloonModel = "models/props_phx/ww2bomb.mdl",
			BalloonHealth = "200",
			BalloonBlack = "1",
			BalloonGray = "1",
			BalloonBlimp = "1",
			BalloonPopSound = "ambient/explosions/explode_5.wav"
		}
	},
	blimp_purple = {
		Name = "Purple gBlimp",
		KeyValues = {
			BalloonMoveSpeed = "100",
			BalloonScale = "2.75",
			BalloonColor = "127 0 255 255",
			BalloonType = "gballoon_blimp_purple",
			BalloonMaterial = "models/debug/debugwhite",
			BalloonModel = "models/props_phx/ww2bomb.mdl",
			BalloonHealth = "20000",
			BalloonBlimp = "1",
			BalloonPopSound = "ambient/explosions/explode_5.wav"
		}
	},
	blimp_magenta = {
		Name = "Magenta gBlimp",
		KeyValues = {
			BalloonMoveSpeed = "300",
			BalloonScale = "2.25",
			BalloonColor = "255 0 255 255",
			BalloonType = "gballoon_blimp_magenta",
			BalloonMaterial = "models/shiny",
			BalloonModel = "models/props_phx/ww2bomb.mdl",
			BalloonHealth = "1500",
			BalloonBlimp = "1",
			BalloonArmor = "15",
			BalloonPopSound = "ambient/explosions/explode_5.wav"
		}
	},
	blimp_rainbow = {
		Name = "Rainbow gBlimp",
		KeyValues = {
			BalloonMoveSpeed = "100",
			BalloonScale = "3",
			BalloonColor = "255 255 255 255",
			BalloonType = "gballoon_blimp_rainbow",
			BalloonMaterial = "!gBalloonRainbow",
			BalloonModel = "models/props_phx/ww2bomb.mdl",
			BalloonHealth = "99999",
			BalloonPurple = "1",
			BalloonAqua = "1",
			BalloonRainbow = "1",
			BalloonBlimp = "1",
			BalloonArmor = "15",
			BalloonPopSound = "ambient/explosions/explode_5.wav"
		}
	}
}

for i=0,15 do
	for k,v in pairs(table.Copy(registerkeys)) do
		local cat = v.KeyValues.BalloonBlimp and "RotgB: gBlimps" or "RotgB: gBalloons"
		local prefix = "gballoon_"
		if bit.band(i,1)==1 then
			v.KeyValues.BalloonFast = "1"
			cat = cat.." Fast"
			prefix = prefix.."fast_"
		end
		if bit.band(i,2)==2 then
			v.KeyValues.BalloonHidden = "1"
			cat = cat.." Hidden"
			prefix = prefix.."hidden_"
		end
		if bit.band(i,4)==4 then
			v.KeyValues.BalloonRegen = "1"
			cat = cat.." Regen"
			prefix = prefix.."regen_"
		end
		if bit.band(i,8)==8 then
			v.KeyValues.BalloonShielded = "1"
			cat = cat.." Shielded"
			prefix = prefix.."shielded_"
		end
		if i==0 then cat = cat.." Basic" end
		v.Class = "gballoon_base"
		v.Category = cat
		list.Set("NPC",prefix..k,v)
		scripted_ents.Register(minuteclass,prefix..k)
	end
end

list.Set("NPC","gballoon_void",{
	Name = "Void gBalloon",
	Class = "gballoon_base",
	Category = "RotgB: gBalloons Miscellaneous",
	KeyValues = {
		BalloonMoveSpeed = "500",
		BalloonScale = "3",
		BalloonType = "gballoon_void",
		BalloonMaterial = "models/wireframe",
		BalloonColor = "255 255 255 255",
		BalloonVoid = "1"
	}
})
list.Set("NPC","gballoon_glass",{
	Name = "Glass gBalloon",
	Class = "gballoon_base",
	Category = "RotgB: gBalloons Miscellaneous",
	KeyValues = {
		BalloonMoveSpeed = "100",
		BalloonScale = "3",
		BalloonColor = "255 255 255 255",
		BalloonType = "gballoon_glass",
		BalloonMaterial = "phoenix_storms/glass",
		BalloonGlass = "1"
	}
})
list.Set("NPC","gballoon_cfiber",{
	Name = "Carbon Fiber gBalloon",
	Class = "gballoon_base",
	Category = "RotgB: gBalloons Miscellaneous",
	KeyValues = {
		BalloonMoveSpeed = "100",
		BalloonScale = "3",
		BalloonColor = "127 127 127 255",
		BalloonType = "gballoon_cfiber",
		BalloonMaterial = "phoenix_storms/mat/mat_phx_carbonfiber2",
		BalloonHealth = "999999999"
	}
})
list.Set("NPC","gballoon_hidden",{
	Name = "Hidden gBalloon",
	Class = "gballoon_base",
	Category = "RotgB: gBalloons Miscellaneous",
	KeyValues = {
		BalloonMoveSpeed = "150",
		BalloonScale = "1.5",
		BalloonColor = "0 255 0 255",
		BalloonType = "gballoon_orange",
		BalloonMaterial = "models/xqm/cellshadedcamo_diffuse",
		BalloonHidden = "1"
	}
})
scripted_ents.Register(minuteclass,"gballoon_void")
scripted_ents.Register(minuteclass,"gballoon_glass")
scripted_ents.Register(minuteclass,"gballoon_cfiber")
scripted_ents.Register(minuteclass,"gballoon_hidden")