--[[
Workshop:		https://steamcommunity.com/sharedfiles/filedetails/?id=1616333917
Profile Page:	https://steamcommunity.com/id/Piengineer12
GitHub Page:	https://github.com/Piengineer12/public-addons/tree/master/revenge_of_the_gballoons
Donate:			https://ko-fi.com/piengineer12

Links above are confirmed working as of 2021-06-21. All dates are in ISO 8601 format.

Version:		6.6.5
Version Date:	2023-01-24
]]

local DebugArgs = {"fire","damage","func_nav_detection","pathfinding","popping","regeneration","targeting","spawning","towers","music"}

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

function ROTGB_LoggingEnabled(attrib)
	return not not ROTGB_GetConVarValue("rotgb_debug"):find(attrib)
end

function ROTGB_HasAllBits(bits,required)
	return bit.band(bits,required)==required
end

function ROTGB_HasAnyBits(bits,...)
	return bit.band(bits or 0,bit.bor(...))~=0
end

function ROTGB_FilterSequential(tab,func)
	local filtered = {}
	for i,v in ipairs(tab) do
		if func(i,v) then
			table.insert(filtered, v)
		end
	end
	return filtered
end

function ROTGB_StringExplodeIncludeSeperators(seperator, toExplode, withpattern)
	if seperator == "" then return totable(toExplode) end
	withpattern = withpattern or false
	
	local ret = {}
	local current_pos = 1
	
	for i=1,#toExplode do
		local start_pos, end_pos = string.find(toExplode, seperator, current_pos, not withpattern)
		if not start_pos then break end
		table.insert(ret, string.sub(toExplode, current_pos, start_pos-1))
		table.insert(ret, string.sub(toExplode, start_pos, end_pos))
		current_pos = end_pos + 1
	end
	
	table.insert(ret, string.sub(toExplode, current_pos))
	return ret
end

ROTGB_OPERATION_BLACKLIST = 1
ROTGB_OPERATION_WAVE_TRANSFER = 2
ROTGB_OPERATION_TRANSFER = 3
ROTGB_OPERATION_NOTIFY = 4
ROTGB_OPERATION_WAVE_EDIT = 5
ROTGB_OPERATION_HEALTH_EDIT = 6
ROTGB_OPERATION_TRIGGER = 7
ROTGB_OPERATION_BOSS = 8
ROTGB_OPERATION_NOTIFYCHAT = 9
ROTGB_OPERATION_NOTIFYARG = 10
ROTGB_OPERATION_SYNCENTITY = 11

ROTGB_TOWER_MENU = 0
ROTGB_TOWER_UPGRADE = 1
ROTGB_TOWER_PURCHASE = 2

ROTGB_HEALTH_SET = 1
ROTGB_HEALTH_HEAL = 2
ROTGB_HEALTH_ADD = 3
ROTGB_HEALTH_SUB = 4
ROTGB_MAXHEALTH_SET = 5
ROTGB_MAXHEALTH_ADD = 6
ROTGB_MAXHEALTH_SUB = 7

ROTGB_NOTIFYTYPE_ERROR = 1
ROTGB_NOTIFYTYPE_CHAT = 2
ROTGB_NOTIFYTYPE_INFO = 3
ROTGB_NOTIFYTYPE_HINT = 4

ROTGB_NOTIFY_NOMULTISTART = 1
ROTGB_NOTIFY_WAVESTART = 2
ROTGB_NOTIFY_WIN = 3
ROTGB_NOTIFY_WAVELOADED = 4
ROTGB_NOTIFY_PLACEMENTILLEGAL = 5
ROTGB_NOTIFY_PLACEMENTILLEGALOFF = 6
ROTGB_NOTIFY_NOSPAWNERS = 7
ROTGB_NOTIFY_TRANSFERSHARED = 8
ROTGB_NOTIFY_TOWERLEVEL = 9
ROTGB_NOTIFY_TOWERCASH = 10
ROTGB_NOTIFY_NAVMESHMISSING = 11
ROTGB_NOTIFY_TOWERBLACKLISTED = 12
ROTGB_NOTIFY_TOWERCHESSONLY = 13
ROTGB_NOTIFY_TOWERMAX = 14
ROTGB_NOTIFY_TOWERNOTOWNER = 15
ROTGB_NOTIFY_WAVEEND = 16
ROTGB_NOTIFY_TUTORIAL = 17

-- deprecated:
ROTGB_NOTIFYCHAT_NOMULTISTART = ROTGB_NOTIFY_NOMULTISTART
ROTGB_NOTIFYCHAT_WAVESTART = ROTGB_NOTIFY_WAVESTART
ROTGB_NOTIFYCHAT_WIN = ROTGB_NOTIFY_WIN
ROTGB_NOTIFYCHAT_WAVELOADED = ROTGB_NOTIFY_WAVELOADED
ROTGB_NOTIFYCHAT_PLACEMENTILLEGAL = ROTGB_NOTIFY_PLACEMENTILLEGAL
ROTGB_NOTIFYCHAT_PLACEMENTILLEGALOFF = ROTGB_NOTIFY_PLACEMENTILLEGALOFF
ROTGB_NOTIFYCHAT_NOSPAWNERS = ROTGB_NOTIFY_NOSPAWNERS
ROTGB_NOTIFYCHAT_TRANSFERSHARED = ROTGB_NOTIFY_TRANSFERSHARED
ROTGB_NOTIFYARG_TOWERLEVEL = ROTGB_NOTIFY_TOWERLEVEL
ROTGB_NOTIFYARG_TOWERCASH = ROTGB_NOTIFY_TOWERCASH

ROTGB_GBALLOONS = {}
ROTGB_CVARS = {}
local R_INT = 1
local R_FLOAT = 2
local R_BOOL = 3

local function RegisterConVar(cvarName, default, retrieveType, description)
	if ROTGB_CVARS[cvarName] then
		ROTGB_LogError("The ConVar "..cvarName.." was already registered! Expect side effects!","")
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
	local returnValue = hook.Run("ShouldConVarOverride", cvar)--GAMEMODE.Modes[hook.Run("GetCurrentMode")].convars[cvar] or GAMEMODE.Modes.__common.convars[cvar]
	if returnValue then
		if returnValue == true then
			return ConvertToAppropriateRetrieveType(ROTGB_CVARS[cvar][1]:GetDefault(), cvar)
		else
			return ConvertToAppropriateRetrieveType(returnValue, cvar)
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
 - ]]..table.concat(DebugArgs,", ")..'\n'..
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
[[If set, cash is split individually among all players - all players have their own wallets.
 - Otherwise, cash is stored globally in the map - all players share the same wallet.]])

local function CreateCfunction(fname,vname)
	return function(ply,cmd,args,argStr)
		if engine.ActiveGamemode()=="rotgb" and not GAMEMODE.DebugMode then
			ROTGB_LogError("Access denied.","")
		elseif (not IsValid(ply) or ply:IsAdmin()) then
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
				_G[fname](tonumber(args[1]) or ROTGB_GetConVarValue("rotgb_cash_param"))
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
 - Adds cash by the inputted value or the rotgb_cash_param ConVar.]])

concommand.Add("rotgb_subcash",CreateCfunction("ROTGB_RemoveCash","rotgb_subcash"),nil,
[[Admin only command.
 - Subtracts cash by the inputted value or the rotgb_cash_param ConVar.]])

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
[[Amount of starting cash every player gets.]])

RegisterConVar("rotgb_crit_effect_delay","0",R_FLOAT,
[[Sets the delay between "Crit!" text effects shown by the gBalloons.
 - A value of -1 disables the effect altogether.]])

RegisterConVar("rotgb_use_kill_handler","0",R_BOOL,
[[Enabling this option will cause gBalloons to trigger on-kill effects when popped.]])

RegisterConVar("rotgb_use_achievement_handler","1",R_BOOL,
[[Enabling this option will cause popping gBalloons to count towards the Popper achievement.]])

RegisterConVar("rotgb_difficulty","1",R_FLOAT,
[[Sets the difficulty of RotgB.
 - Available values:
 - 0: Easy (x0.8 tower costs, x0.9 gBalloon speed)
 - 1: Normal (x1.0 tower costs, x1.0 gBalloon speed)
 - 2: Hard (x1.2 tower costs, x1.1 gBalloon speed)
 - 3: Insane (x1.4 tower costs, x1.2 gBalloon speed)
 
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
[[If set, all towers will be able to accidentally damage non-gBalloon entities.]])

RegisterConVar("rotgb_target_natural_health","100",R_FLOAT,
[[Sets the "natural" health of gBalloon Targets. Only works if it isn't overridden by the map.]])

RegisterConVar("rotgb_tower_ignore_physgun","0",R_BOOL,
[[If set, towers cannot be moved by the Physics Gun.]])

RegisterConVar("rotgb_health_param","0",R_FLOAT,
[[Sets the health value for the rotgb_*health ConCommands.]])

RegisterConVar("rotgb_tower_blacklist","",R_STRING,
[[Tower classes in the blacklist cannot be placed. Separate entries with spaces.]])

RegisterConVar("rotgb_tower_chess_only","0",R_INT,
[[Enabling this option will allow only chess towers to be placed. Towers can declare whether they are chess towers or not in their respective class files.
 - If -1, only NON-chess towers can be placed.]])

RegisterConVar("rotgb_spawner_force_auto_start","-1",R_INT,
[[If 1, newly-spawned gBalloon Spawners will have Force Auto-Start enabled.
 - If 0, newly-spawned gBalloon Spawners will have Force Auto-Start disabled.
 - If -1, the map's values are used where applicable, otherwise 0 is used.]])

concommand.Add("rotgb_health_param_internal",function(ply,cmd,args,argStr) if (not IsValid(ply) or ply:IsAdmin()) then ROTGB_CVARS["rotgb_health_param"][1]:SetInt(tonumber(args[1]) or 0) end end,nil,nil,FCVAR_UNREGISTERED)

local function CreateHfunction(iname,vname)
	return function(ply,cmd,args,argStr)
		if engine.ActiveGamemode()=="rotgb" and not GAMEMODE.DebugMode then
			ROTGB_LogError("Access denied.","")
		elseif (not IsValid(ply) or ply:IsAdmin()) then
			for k,v in pairs(ents.FindByName("gballoon_target")) do
				v:Fire(iname,tonumber(args[1]) or ROTGB_GetConVarValue("rotgb_health_param"),0,ply,ply)
			end
		end
	end
end

concommand.Add("rotgb_sethealth",CreateHfunction("SetHealth","rotgb_sethealth"),nil,
[[Admin only command.
 - Sets the current amount of health from input or the rotgb_health_param ConVar.

 - Related commands:
 - rotgb_addhealth
 - rotgb_subhealth]])

concommand.Add("rotgb_addhealth",CreateHfunction("AddHealth","rotgb_addhealth"),nil,
[[Admin only command.
 - Same as rotgb_healhealth, but can go beyond the maximum health limit.]])

concommand.Add("rotgb_healhealth",CreateHfunction("HealHealth","rotgb_healhealth"),nil,
[[Admin only command.
 - Adds health by input or the rotgb_health_param ConVar.]])

concommand.Add("rotgb_subhealth",CreateHfunction("RemoveHealth","rotgb_subhealth"),nil,
[[Admin only command.
 - Subtracts health by input or the rotgb_health_param ConVar.]])

concommand.Add("rotgb_setmaxhealth",CreateHfunction("SetMaxHealth","rotgb_setmaxhealth"),nil,
[[Admin only command.
 - Sets the current amount of maximum health from input or the rotgb_health_param ConVar.

 - Related commands:
 - rotgb_addmaxhealth
 - rotgb_submaxhealth]])

concommand.Add("rotgb_addmaxhealth",CreateHfunction("AddMaxHealth","rotgb_addmaxhealth"),nil,
[[Admin only command.
 - Adds maximum health by input or the rotgb_health_param ConVar.]])

concommand.Add("rotgb_submaxhealth",CreateHfunction("RemoveMaxHealth","rotgb_submaxhealth"),nil,
[[Admin only command.
 - Subtracts maximum health by input or the rotgb_health_param ConVar.]])

RegisterConVar("rotgb_spawner_no_multi_start","-1",R_INT,
[[If 1, newly-spawned gBalloon Spawners will have Allow Multiple Waves disabled.
 - If 0, newly-spawned gBalloon Spawners will have Allow Multiple Waves enabled.
 - If -1, the map's values are used where applicable, otherwise 0 is used.]])

RegisterConVar("rotgb_max_fires_per_second","20",R_FLOAT,
[[Maximum gBalloons to visibly ignite per second. Lowering this value can improve performance.
 - Note that invisible fires can still deal fire damage to gBalloons.
 - This may also be a decimal value.]])

RegisterConVar("rotgb_tower_force_charge","0",R_BOOL,
[[If set, active abilities will charge even no waves are currently in progress.]])

RegisterConVar("rotgb_tower_charge_rate","1",R_FLOAT,
[[Multiplier for how fast towers recharge their active abilities.]])

RegisterConVar("rotgb_spawner_spawn_rate","1",R_FLOAT,
[[Multiplier for how fast gBalloons are spawned from gBalloon Spawners.]])

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

ROTGB_CASH = ROTGB_CASH or 0



function ROTGB_SetCash(num,ply)
	if SERVER then
		ROTGB_GetGameEntity():SetCash(num, ply)
		ROTGB_UpdateCash(ply)
	else
		if ROTGB_GetConVarValue("rotgb_individualcash") then
			if ply then
				ply.ROTGB_CASH = tonumber(num) or 0
			else
				for k,v in pairs(player.GetAll()) do
					v.ROTGB_CASH = tonumber(num) or 0
				end
			end
		else
			ROTGB_CASH = tonumber(num) or 0
		end
	end
end

function ROTGB_GetCash(ply)
	if SERVER then
		return ROTGB_GetGameEntity():GetCash(ply)
	else
		if ROTGB_GetConVarValue("rotgb_individualcash") then
			ply = ply or CLIENT and LocalPlayer()
			if ply then return ply.ROTGB_CASH or 0
			else
				local sum = 0
				for k,v in pairs(player.GetAll()) do
					sum = sum + (v.ROTGB_CASH or 0)
				end
				return sum
			end
		else
			return ROTGB_CASH or 0
		end
	end
end

function ROTGB_AddCash(num,ply)
	num = tonumber(num) or 0
	if ROTGB_GetConVarValue("rotgb_individualcash") then
		if IsValid(ply) then
			ROTGB_SetCash(ROTGB_GetCash(ply)+num,ply)
		else
			local plys = {}
			for k,v in pairs(player.GetAll()) do
				if v:Team() ~= TEAM_SPECTATOR and v:Team() ~= TEAM_CONNECTING then
					table.insert(plys, v)
				end
			end
			
			local count = #plys
			for k,v in pairs(plys) do
				ROTGB_SetCash(ROTGB_GetCash(v)+num/count,v)
			end
		end
	else
		ROTGB_SetCash(ROTGB_GetCash()+num)
	end
end

function ROTGB_RemoveCash(num,ply)
	num = tonumber(num) or 0
	if ROTGB_GetConVarValue("rotgb_individualcash") then
		if IsValid(ply) then
			ROTGB_SetCash(ROTGB_GetCash(ply)-num,ply)
		else
			local plys = {}
			for k,v in pairs(player.GetAll()) do
				if v:Team() ~= TEAM_SPECTATOR and v:Team() ~= TEAM_CONNECTING then
					table.insert(plys, v)
				end
			end
			
			local count = #plys
			for k,v in pairs(plys) do
				ROTGB_SetCash(ROTGB_GetCash(v)-num/count,v)
			end
		end
	else
		ROTGB_SetCash(ROTGB_GetCash()-num)
	end
end

function ROTGB_GetTransferAmount(ply)
	local cash = ROTGB_GetCash(ply)
	if not cash == cash then return cash end
	return math.floor(math.max(0, cash / 5, math.min(cash, 100)))
end

function ROTGB_ScaleBuyCost(num,ent,data)
	num = num or 0
	-- note: an entity PROTOTYPE might be passed here!
	if IsValid(ent) and data.type == ROTGB_TOWER_UPGRADE then
		if ent:GetNWBool("rotgb_noupgradelimit") then
			-- figure out how many upgrades are already on the tower
			local totalUpgrades = 0
			for i=0,#ent.UpgradeReference-1 do
				totalUpgrades = totalUpgrades + bit.band(bit.rshift(ent:GetUpgradeStatus(),i*4),15)
			end
			
			-- figure out how many upgrades away, at minimum, the upgrade is
			local upgradeDistance = data.tier - bit.band(bit.rshift(ent:GetUpgradeStatus(),data.path*4-4),15)
			
			-- total amount of doubling = total upgrades + upgrade distance - 1
			num = num * 4^(totalUpgrades+upgradeDistance-1)
		end
		if ent:GetNWBool("rotgb_tower_06_discount") then
			num = num * 0.875
		end
	end
	local newAmount = hook.Run("RotgBScaleBuyCost", num, ent, data)
	if newAmount then
		return newAmount
	else
		return num * (1 + (ROTGB_GetConVarValue("rotgb_difficulty") - 1)/5)
	end
end

function ROTGB_CauseNotification(msg,level,ply,additionalArguments)
	additionalArguments = additionalArguments or {}
	if SERVER then
		net.Start("rotgb_generic")
		net.WriteUInt(ROTGB_OPERATION_NOTIFY,8)
		
		local deprecationWarning
		if not isnumber(level) then
			ply = level
			level = ROTGB_NOTIFYTYPE_ERROR
			deprecationWarning = "DEPRECATION WARNING: On the server, the second argument of ROTGB_CauseNotification must be message level."
		end
		net.WriteUInt(level, 4)
		
		if isstring(msg) then
			net.WriteBool(true)
			net.WriteString(msg)
			--deprecationWarning = "DEPRECATION WARNING: On the server, the third argument of ROTGB_CauseNotification must be an enumeration for non-map invocations."
		else
			net.WriteBool(false)
			net.WriteUInt(msg, 8)
		end
		
		local flags = 0
		
		if additionalArguments.color or additionalArguments.holdtime then
			flags = bit.bor(flags, 1)
		end
		
		net.WriteUInt(flags, 8)
		
		if bit.band(flags, 1)~=0 then
			if level == ROTGB_NOTIFYTYPE_CHAT then 
				net.WriteColor(additionalArguments.color)
			elseif level == ROTGB_NOTIFYTYPE_INFO or level == ROTGB_NOTIFYTYPE_ERROR or level == ROTGB_NOTIFYTYPE_HINT then
				net.WriteFloat(additionalArguments.holdtime)
			end
		end
		
		for i=1,#additionalArguments do
			local typ = additionalArguments[i*2-1]
			local value = additionalArguments[i*2]
			if typ == "b" then
				net.WriteBool(value)
			elseif typ == "i32" then
				net.WriteInt(value, 32)
			elseif typ == "u8" then
				net.WriteUInt(value, 8)
			elseif typ == "e" then
				net.WriteEntity(value)
			elseif typ == "f" then
				net.WriteFloat(value)
			elseif typ == "d" then
				net.WriteDouble(value)
			elseif typ == "s" then
				net.WriteString(value)
			end
		end
		
		if not ply then
			net.Broadcast()
		elseif ply:IsPlayer() then
			net.Send(ply)
		end
		
		if deprecationWarning then
			ROTGB_LogError(deprecationWarning, "")
			debug.Trace()
		end
	end
	if CLIENT then
		if level == ROTGB_NOTIFYTYPE_ERROR then
			notification.AddLegacy(msg,NOTIFY_ERROR,additionalArguments.holdtime or 5)
			surface.PlaySound("buttons/button10.wav")
		elseif level == ROTGB_NOTIFYTYPE_CHAT then
			if additionalArguments.color then
				chat.AddText(additionalArguments.color, msg)
			else
				chat.AddText(msg)
			end
		elseif level == ROTGB_NOTIFYTYPE_INFO then
			notification.AddLegacy(msg,NOTIFY_GENERIC,additionalArguments.holdtime or 5)
		elseif level == ROTGB_NOTIFYTYPE_HINT then
			notification.AddLegacy(msg,NOTIFY_HINT,additionalArguments.holdtime or 5)
		end
	end
end

if SERVER then
	util.AddNetworkString("rotgb_cash")
	local cashUpdatePlayers = {}
	
	function ROTGB_GetGameEntity()
		if not IsValid(ROTGB_GameEntity) then
			ROTGB_GameEntity = ents.FindByClass("game_rotgb")[1]
			if not IsValid(ROTGB_GameEntity) then
				ROTGB_GameEntity = ents.Create("game_rotgb")
				ROTGB_GameEntity:Spawn()
			end
		end
		return ROTGB_GameEntity
	end
	
	function ROTGB_UpdateCash(ply)
		if ply then
			cashUpdatePlayers[ply] = true
		else
			cashUpdatePlayers[game.GetWorld()] = true
		end
	end
	
	net.Receive("rotgb_cash",function(length, ply)
		if ROTGB_GetConVarValue("rotgb_individualcash") then
			for k,v in pairs(player.GetAll()) do
				ROTGB_UpdateCash(v)
			end
		else
			ROTGB_UpdateCash()
		end
	end)
	
	local ticktime2 = 0
	local cashLoaded = false
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
	 - Opens the wave editor.]])

	util.AddNetworkString("rotgb_generic")
	net.Receive("rotgb_generic",function(length, ply)
		local operation = net.ReadUInt(8)
		local plyIsAdmin = ply:IsAdmin()
		if plyIsAdmin then
			if operation == ROTGB_OPERATION_BLACKLIST then
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
			elseif operation == ROTGB_OPERATION_WAVE_TRANSFER then
				ROTGB_WAVEPARTS = ROTGB_WAVEPARTS or {}
				local wavename, totalpackets, currentpacket, bytes = net.ReadString(), net.ReadUInt(16), net.ReadUInt(16), net.ReadUInt(16)
				local datachunk = net.ReadData(bytes)
				ROTGB_WAVEPARTS[wavename] = ROTGB_WAVEPARTS[wavename] or {}
				ROTGB_WAVEPARTS[wavename][currentpacket] = datachunk
				if #ROTGB_WAVEPARTS[wavename] == totalpackets then
					file.Write("rotgb_wavedata/"..wavename..".dat",table.concat(ROTGB_WAVEPARTS[wavename]))
					PrintMessage(HUD_PRINTTALK, "\""..wavename.."\" assembled successfully.")
				end
			elseif operation == ROTGB_OPERATION_HEALTH_EDIT and (engine.ActiveGamemode()~="rotgb" or GAMEMODE.DebugMode) then
				local target = net.ReadEntity()
				local subOperation = net.ReadUInt(4)
				local amt = net.ReadInt(32)
				if subOperation == ROTGB_HEALTH_SET then
					target:Fire("SetHealth",amt,0,ply,ply)
				elseif subOperation == ROTGB_HEALTH_ADD then
					target:Fire("AddHealth",amt,0,ply,ply)
				elseif subOperation == ROTGB_HEALTH_HEAL then
					target:Fire("HealHealth",amt,0,ply,ply)
				elseif subOperation == ROTGB_HEALTH_SUB then
					target:Fire("RemoveHealth",amt,0,ply,ply)
				elseif subOperation == ROTGB_MAXHEALTH_SET then
					target:Fire("SetMaxHealth",amt,0,ply,ply)
				elseif subOperation == ROTGB_MAXHEALTH_ADD then
					target:Fire("AddMaxHealth",amt,0,ply,ply)
				elseif subOperation == ROTGB_MAXHEALTH_SUB then
					target:Fire("RemoveMaxHealth",amt,0,ply,ply)
				end
			end
		end
		if operation == ROTGB_OPERATION_TRANSFER then
			local ply2 = net.ReadEntity()
			if ply2:IsPlayer() and ply ~= ply2 then
				local transferAmount = ROTGB_GetTransferAmount(ply)
				ROTGB_AddCash(transferAmount, ply2)
				ROTGB_RemoveCash(transferAmount, ply)
			end
		elseif operation == ROTGB_OPERATION_TRIGGER then
			local tower = net.ReadEntity()
			if IsValid(tower) then
				if tower.Base == "gballoon_tower_base" then
					tower:DoAbility()
				elseif tower == ply then
					for k,v in pairs(ents.GetAll()) do
						if v.Base == "gballoon_tower_base" then
							v:DoAbility()
						end
					end
				end
			end
		elseif operation == ROTGB_OPERATION_SYNCENTITY then
			local ent = net.ReadEntity()
			if IsValid(ent) then
				local class = ent:GetClass()
				if class == "gballoon_spawner" then
					ent:SyncEntity(ply)
				end
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
		if next(cashUpdatePlayers) then
			local tableOfKeys = table.GetKeys(cashUpdatePlayers)
			local worldspawn = game.GetWorld()
			
			net.Start("rotgb_cash")
			net.WriteUInt(#tableOfKeys, 8)
			for k,v in pairs(tableOfKeys) do
				if v == worldspawn then
					net.WriteUInt(0, 16)
					net.WriteDouble(ROTGB_GetCash())
				elseif IsValid(v) then
					net.WriteUInt(v:UserID(), 16)
					net.WriteDouble(ROTGB_GetCash(v))
				end
			end
			net.Broadcast()
			cashUpdatePlayers = {}
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
	
	hook.Add("PostCleanupMap","RotgB",function()
		ROTGB_UpdateCash()
		for k,v in pairs(player.GetAll()) do
			ROTGB_UpdateCash(v)
		end
	end)
end



if CLIENT then
	ROTGB_CLIENTWAVES = ROTGB_CLIENTWAVES or {}
	
	function ROTGB_LocalizeString(token, ...)
		local pieces = {["%"] = "%", n="\n", t="\t"}
		for k,v in pairs({...}) do
			pieces[string.format("%i", k)] = v
		end
		
		local phrase = language.GetPhrase(token)
		if phrase == token and ROTGB_HasLocalization(token..".1") then
			-- it is a multipart
			local phrases = {}
			
			-- the one time where a post-test loop actually becomes useful
			local i = 1
			local multipartToken = token..".1"
			repeat
				local phrase = language.GetPhrase(multipartToken)
				
				-- remove all control characters
				phrase = string.gsub(phrase, "%c+", "")
				
				-- remove quote marks if surrounded by them
				if string.find(phrase, "^\".*\"$") then
					phrase = string.match(phrase, "^\"(.*)\"$")
				end
				table.insert(phrases, phrase)
				
				i = i + 1
				multipartToken = token..string.format(".%i", i)
			until not ROTGB_HasLocalization(multipartToken)
			
			phrase = table.concat(phrases)
		else
			-- remove all control characters
			phrase = string.gsub(phrase, "%c+", "")
			
			-- remove quote marks if surrounded by them
			if string.find(phrase, "^\".*\"$") then
				phrase = string.match(phrase, "^\"(.*)\"$")
			end
		end
		
		return (string.gsub(phrase, "%%(.)", pieces))
	end
	
	function ROTGB_HasLocalization(token)
		return language.GetPhrase(token) ~= token
	end
	
	function ROTGB_LocalizeMulticoloredString(token, replacements, defaultColor, replacementColors)
		local returnTable = {}
		local template = language.GetPhrase(token)
		
		-- remove all control characters
		template = string.gsub(template, "%c+", "")
		
		-- remove quote marks if surrounded by them
		if string.find(template, "^\".*\"$") then
			template = string.match(template, "^\"(.*)\"$")
		end
		
		local translationTable = ROTGB_StringExplodeIncludeSeperators("%%.", template, true)
		for i,v in ipairs(translationTable) do
			if i%2==0 then
				local token = string.match(v, "%%(.)")
				if token == "%" then
					table.insert(returnTable, "%")
				elseif token == "n" then
					table.insert(returnTable, "\n")
				elseif token == "t" then
					table.insert(returnTable, "\t")
				else
					token = tonumber(token)
					if token then
						table.insert(returnTable, replacementColors[token])
						table.insert(returnTable, replacements[token])
					end
				end
			else
				table.insert(returnTable, defaultColor)
				table.insert(returnTable, v)
			end
		end
		return returnTable
	end
	
	function ROTGB_InsertRichTextWithMulticoloredString(RichText, multiColoredString)
		for i,v in ipairs(multiColoredString) do
			if istable(v) then
				RichText:InsertColorChange(v.r,v.g,v.b,v.a)
			else
				RichText:AppendText(tostring(v))
			end
		end
	end
	
	function ROTGB_DrawMultiColoredText(data, font, x, y, xAlign, yAlign)
		local w, h = ROTGB_GetMultiColoredTextSize(data, font)
		
		if xAlign == TEXT_ALIGN_RIGHT then
			x = x - w
		elseif xAlign == TEXT_ALIGN_CENTER then
			x = x - w / 2
		end
		if yAlign == TEXT_ALIGN_BOTTOM then
			y = y - h
		elseif yAlign == TEXT_ALIGN_CENTER then
			y = y - h / 2
		end
		
		surface.SetTextPos(x, y)
		
		for i,v in ipairs(data) do
			if istable(v) then
				surface.SetTextColor(v.r or 255, v.g or 255, v.b or 255, v.a or 255)
			else
				surface.DrawText(tostring(v))
			end
		end
		
		return w, h
	end
	
	function ROTGB_DrawMultiColoredOutlinedText(data, font, x, y, xAlign, yAlign, outlineWidth, outlineColor)
		local w, h = ROTGB_GetMultiColoredTextSize(data, font)
		
		if xAlign == TEXT_ALIGN_RIGHT then
			x = x - w
		elseif xAlign == TEXT_ALIGN_CENTER then
			x = x - w / 2
		end
		if yAlign == TEXT_ALIGN_BOTTOM then
			y = y - h
		elseif yAlign == TEXT_ALIGN_CENTER then
			y = y - h / 2
		end
		
		local currentColor = color_white
		
		for i,v in ipairs(data) do
			if istable(v) then
				currentColor = v
			else
				local text = tostring(v)
				surface.SetTextColor(outlineColor.r or 0, outlineColor.g or 0, outlineColor.b or 0, outlineColor.a or 255)
				
				for dX = -outlineWidth, outlineWidth, outlineWidth do
					for dY = -outlineWidth, outlineWidth, outlineWidth do
						if dX ~=0 and dY ~= 0 then
							surface.SetTextPos(x+dX, y+dY)
							surface.DrawText(text)
						end
					end
				end
				
				surface.SetTextColor(currentColor.r or 255, currentColor.g or 255, currentColor.b or 255, currentColor.a or 255)
				surface.SetTextPos(x, y)
				surface.DrawText(text)
				x = x + surface.GetTextSize(text)
			end
		end
		
		return w, h
	end
	
	function ROTGB_GetMultiColoredTextSize(data, font)
		local w, h = 0, 0
		surface.SetFont(font)
		for i,v in ipairs(data) do
			if not istable(v) then
				local dW, dH = surface.GetTextSize(tostring(v))
				w = w + dW
				h = math.max(h, dH)
			end
		end
		return w, h
	end
	
	function ROTGB_GetBalloonName(balloonType, isFast, isHidden, isRegen, isShielded)
		local balloonString = ROTGB_LocalizeString("rotgb.gballoon."..balloonType)
		local fastString = ROTGB_LocalizeString(isFast and "rotgb.gballoon.property.fast" or "rotgb.gballoon.property.not_fast")
		local hiddenString = ROTGB_LocalizeString(isHidden and "rotgb.gballoon.property.hidden" or "rotgb.gballoon.property.not_hidden")
		local regenString = ROTGB_LocalizeString(isRegen and "rotgb.gballoon.property.regen" or "rotgb.gballoon.property.not_regen")
		local shieldedString = ROTGB_LocalizeString(isShielded and "rotgb.gballoon.property.shielded" or "rotgb.gballoon.property.not_shielded")
		return ROTGB_LocalizeString("rotgb.gballoon.name", balloonString, fastString, hiddenString, regenString, shieldedString)
	end
	
	function ROTGB_FormatCash(cash, roundUp)
		if cash==math.huge then -- number is inf
			return ROTGB_LocalizeString("rotgb.cash.inf")
		elseif cash==-math.huge then -- number is negative inf
			return ROTGB_LocalizeString("rotgb.cash.-inf")
		elseif cash<math.huge and cash>-math.huge then -- number is real
			if cash>-1e12 and cash<1e12 then
				return ROTGB_LocalizeString("rotgb.cash", ROTGB_Commatize((roundUp and math.ceil or math.floor)(cash)))
			else
				return ROTGB_LocalizeString("rotgb.cash", string.format("%.6E", cash))
			end
		else -- number isn't a number. Caused by inf minus inf
			return ROTGB_LocalizeString("rotgb.cash.nan")
		end
	end
	
	function ROTGB_Commatize(number)
		if number == math.huge then return ROTGB_LocalizeString("rotgb.number.inf")
		elseif number == -math.huge then return ROTGB_LocalizeString("rotgb.number.-inf")
		elseif number < math.huge and number > -math.huge then 
			local originalCommatated = string.Comma(number)
			return string.gsub(originalCommatated, "([,.])", {
				[','] = ROTGB_LocalizeString("rotgb.number.thousands_separator"),
				['.'] = ROTGB_LocalizeString("rotgb.number.decimal_separator")
			})
		else return ROTGB_LocalizeString("rotgb.number.nan")
		end
	end
	
	function ROTGB_DrawCircle(x,y,r,percent,...)
		if percent > 0 then
			local SEGMENTS = ROTGB_GetConVarValue("rotgb_circle_segments")
			local seoul = -360/SEGMENTS
			percent = math.Clamp(percent*SEGMENTS,0,SEGMENTS)
			local vertices = {{x=x,y=y}}
			local pi = math.pi
			for i=0,math.floor(percent) do
				local compx = x+math.sin(math.rad(i*seoul)+pi)*r
				local compy = y+math.cos(math.rad(i*seoul)+pi)*r
				table.insert(vertices,{x=compx,y=compy})
			end
			if math.floor(percent)~=percent then
				local compx = x+math.sin(math.rad(percent*seoul)+pi)*r
				local compy = y+math.cos(math.rad(percent*seoul)+pi)*r
				table.insert(vertices,{x=compx,y=compy})
			end
			draw.NoTexture()
			surface.SetDrawColor(...)
			surface.DrawPoly(vertices)
			table.insert(vertices,table.remove(vertices,1))
			surface.DrawPoly(table.Reverse(vertices))
		end
	end
	
	local function RegisterClientConVar(cvarName, default, retrieveType, description)
		if ROTGB_CVARS[cvarName] then
			ROTGB_LogError("The ConVar "..cvarName.." was already registered! Expect side effects!","")
		end
		ROTGB_CVARS[cvarName] = {}
		ROTGB_CVARS[cvarName][1] = CreateConVar(cvarName, default, bit.bor(FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX), description)
		ROTGB_CVARS[cvarName][2] = retrieveType
	end
	
	RegisterClientConVar("rotgb_hoverover_distance","15",R_FLOAT,
	[[Determines the height of the text hovering above the gBalloon Spawner and gBalloon Targets.]])
	
	RegisterClientConVar("rotgb_hud_enabled","1",R_BOOL,
	[[Determines the visibility of the cash and gBalloon Target health display.]])
	
	RegisterClientConVar("rotgb_hud_x","0.1",R_FLOAT,
	[[Determines the horizontal position of the cash display.]])
	
	RegisterClientConVar("rotgb_hud_y","0.1",R_FLOAT,
	[[Determines the vertical position of the cash display.]])
	
	RegisterClientConVar("rotgb_hud_size","32",R_INT,
	[[Determines the size of the cash display.]])
	
	RegisterClientConVar("rotgb_freeze_effect","0",R_BOOL,
	[[Shows the freezing effect when a gBalloon is frozen.
	 - Only enable this if you have a high-end PC.]])
	
	RegisterClientConVar("rotgb_no_glow","0",R_BOOL,
	[[Disable all halo effects, including owner halos and the turquoise halo around purple gBalloons.
	 - Only enable this if you have a low-end PC.]])
	
	RegisterClientConVar("rotgb_circle_segments","24",R_INT,
	[[Sets the number of sides each drawn "circle" has.
	 - Lowering this value can improve performance.]])
	
	RegisterClientConVar("rotgb_range_enable_indicators","1",R_BOOL,
	[[Hovering over a tower shows its range.
	 - An aqua range means that its range is finite.
	 - A blue range means that its range is infinite.
	 - A red range means that its placement is invalid.]])
	
	RegisterClientConVar("rotgb_range_hold_time","0.25",R_FLOAT,
	[[Time to hold the range indicator before it fades out.]])
	
	RegisterClientConVar("rotgb_range_fade_time","0.25",R_FLOAT,
	[[Time to fade out the range indicator.]])
	
	RegisterClientConVar("rotgb_range_alpha","15",R_FLOAT,
	[[Sets how visible the range indicator is, in the range of 0-255.]])
	
	RegisterClientConVar("rotgb_music_volume","1",R_FLOAT,
	[[Multiplier for gBalloon Spawner music volume. If 0, music does not play at all.
	 - Relies on BASS library for music, so values > 1 are supported.]])
	
	RegisterClientConVar("rotgb_no_wave_hints","0",R_BOOL,
	[[Hides the hints that sometimes appear after a wave ends.]])
	
	local function CreateGBFont(fontsize)
		surface.CreateFont("RotgB_font",{
			font="Luckiest Guy Rotgb",
			extended=true,
			size=fontsize
		})
	end
	local BOSS_FONT_HEIGHT = 16
	surface.CreateFont("RotgBBossFont",{
		font="Roboto",
		size=BOSS_FONT_HEIGHT
	})
	
	CreateGBFont(32)
	
	local function FilterSequentialTable(tab,func)
		local filtered = {}
		for i,v in ipairs(tab) do
			if func(i,v) then
				table.insert(filtered, v)
			end
		end
		return filtered
	end

	local function TableFilterWaypoints(k,v)
		return IsValid(v) and v:GetClass()=="gballoon_target" and not v:GetIsBeacon() and not v:GetHideHealth()
	end

	local function TableFilterSpawners(k,v)
		return IsValid(v) and v:GetClass()=="gballoon_spawner" and not v:GetHideWave()
	end

	local function WaypointSorter(a,b)
		return a:GetWeight() > b:GetWeight()
	end

	local function SpawnerSorter(a,b)
		return a:GetWave() > b:GetWave()
	end

	net.Receive("rotgb_cash", function()
		local iterations = net.ReadUInt(8)
		for i=1,iterations do
			local id = net.ReadUInt(16)
			local amt = net.ReadDouble()
			if id==0 then
				ROTGB_CASH = amt
			elseif IsValid(Player(id)) then
				Player(id).ROTGB_CASH = amt
			end
		end
	end)
	
	hook.Add("InitPostEntity", "RotgB", function()
		net.Start("rotgb_cash")
		net.SendToServer()
	end)
	
	local hurtFeed = {}
	local hurtFeedStaySeconds = 10
	net.Receive("rotgb_target_received_damage", function()
		local target = net.ReadEntity()
		--local newHealth = net.ReadInt(32)
		--local goldenHealth = net.ReadInt(32)
		local flags = net.ReadUInt(8)
		
		--[[if IsValid(target) then
			if bit.band(flags,7)==7 then
				target.rotgb_ActualMaxHealth = newHealth
			else
				target.rotgb_ActualHealth = newHealth
			end
			target:SetGoldenHealth(goldenHealth)
		end]]
		
		if bit.band(flags,3)~=3 then
			local attackerLabel = net.ReadString()
			local damage = net.ReadInt(32)
			local timestamp = RealTime()
			local displayName = "<unknown>"
			local isBalloon = bit.band(flags,1)==1
			local color
			
			if bit.band(flags,2)==2 then
				local ply = Player(tonumber(attackerLabel))
				if IsValid(ply) then
					displayName = ply:Nick()
					color = team.GetColor(ply:Team())
				end
			elseif isBalloon then
				local npcTable = list.GetForEdit("NPC")[attackerLabel]
				displayName = ROTGB_GetBalloonName(attackerLabel, bit.band(flags,4)==4, bit.band(flags,8)==8, bit.band(flags,16)==16, bit.band(flags,32)==32)
				local h,s,v = ColorToHSV(string.ToColor(npcTable.KeyValues.BalloonColor))
				if s == 1 then v = 1 end
				s = s / 2
				v = (v + 1) / 2
				color = HSVToColor(h,s,v)
			else
				displayName = ROTGB_LocalizeString(attackerLabel)
			end
			
			local existingEntry = hurtFeed[displayName]
			if existingEntry then
				existingEntry.damage = existingEntry.damage + damage
				existingEntry.timestamp = timestamp
				existingEntry.instances = existingEntry.instances + 1
			else
				hurtFeed[displayName] = {
					damage = damage,
					timestamp = timestamp,
					instances = 1,
					color = color,
					isBalloon = isBalloon
				}
			end
		end
	end)
	
	--[[local hintBox = vgui.Create("DPanel")
	hintBox:SetPos(ScrW()*3/8, ScrH()*6/8)
	hintBox:SetSize(ScrW()/4, ScrH()/8)
	hintBox:Hide()
	
	local hintBoxLabel = hintBox:Add("DLabel")
	hintBoxLabel:Dock(FILL)
	hintBoxLabel:SetWrap(true)
	
	local nextHintMessage = nil
	local hintExpiryTime = RealTime()]]
	
	local wavemat = Material("icon16/flag_green.png")
	local coinmat = Material("icon16/coins.png")
	local heartmat = Material("icon16/heart.png")
	local oldSize = 0
	local generateCooldown = 1
	local bossData = {}
	local color_yellow = Color(255,255,0)
	local color_aqua = Color(0,255,255)
	local color_magenta = Color(255,0,255)
	local color_black_semiopaque = Color(0,0,0,191)
	hook.Add("HUDPaint","RotgB",function()
		if ROTGB_GetConVarValue("rotgb_hud_enabled") then
			local scrW = ScrW()
			local scrH = ScrH()
			
			local realTime = RealTime()
			local spawners = FilterSequentialTable(ents.GetAll(), TableFilterSpawners)
			table.sort(spawners, SpawnerSorter)
			for k,v in pairs(spawners) do
				spawners[k] = ROTGB_Commatize(v:GetWave()-1).." / "..ROTGB_Commatize(v:GetLastWave())
			end
			
			local targets = FilterSequentialTable(ents.GetAll(), TableFilterWaypoints)
			table.sort(targets, WaypointSorter)
			
			local size = ROTGB_GetConVarValue("rotgb_hud_size")
			if oldSize ~= size then
				oldSize = size
				generateCooldown = realTime + 2
			end
			if generateCooldown < realTime and generateCooldown >= 0 then
				generateCooldown = -1
				CreateGBFont(size)
			end
			local xPos = ROTGB_GetConVarValue("rotgb_hud_x")*scrW
			local yPos = ROTGB_GetConVarValue("rotgb_hud_y")*scrH
			surface.SetDrawColor(255,255,255)
			surface.SetMaterial(wavemat)
			surface.DrawTexturedRect(xPos,yPos,size,size)
			surface.SetMaterial(heartmat)
			surface.DrawTexturedRect(xPos,yPos+size,size,size)
			surface.SetMaterial(coinmat)
			surface.DrawTexturedRect(xPos,yPos+size*2,size,size)
			
			local textX = xPos+size+2
			
			if next(spawners) then
				draw.SimpleTextOutlined(table.concat(spawners, " + "),"RotgB_font",textX,yPos,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
			else
				draw.SimpleTextOutlined("0","RotgB_font",textX,yPos,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
			end
			
			if next(targets) then
				local tX, tY = textX, yPos+size
				for i,v in ipairs(targets) do
					local needsBrackets = v:GetOSPs() > 0 or v:GetGoldenHealth() > 0 or v:GetPerWaveShield() > 0
					if needsBrackets then
						tX = tX + draw.SimpleTextOutlined("( ","RotgB_font",tX,tY,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
					end
					tX = tX + draw.SimpleTextOutlined(ROTGB_Commatize(v:Health()).." ","RotgB_font",tX,tY,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
					if v:GetOSPs() > 0 then
						tX = tX + draw.SimpleTextOutlined("+ "..ROTGB_Commatize(v:GetOSPs()).."* ","RotgB_font",tX,tY,color_magenta,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
					end
					if v:GetGoldenHealth() > 0 then
						tX = tX + draw.SimpleTextOutlined("+ "..ROTGB_Commatize(v:GetGoldenHealth()).." ","RotgB_font",tX,tY,color_yellow,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
					end
					if v:GetPerWaveShield() > 0 then
						tX = tX + draw.SimpleTextOutlined("+ "..ROTGB_Commatize(v:GetPerWaveShield()).." ","RotgB_font",tX,tY,color_aqua,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
					end
					if needsBrackets then
						tX = tX + draw.SimpleTextOutlined(") ","RotgB_font",tX,tY,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
					end
					tX = tX + draw.SimpleTextOutlined("/ "..ROTGB_Commatize(v:GetMaxHealth()),"RotgB_font",tX,tY,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
					if i < #targets then
						tX = tX + draw.SimpleTextOutlined(" + ","RotgB_font",tX,tY,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
					end
				end
			else
				draw.SimpleTextOutlined("0","RotgB_font",textX,yPos+size,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
			end
			
			draw.SimpleTextOutlined(ROTGB_FormatCash(ROTGB_GetCash(LocalPlayer())),"RotgB_font",textX,yPos+size*2,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
			
			for k,v in pairs(hurtFeed) do
				if v.timestamp + hurtFeedStaySeconds < realTime then
					hurtFeed[k] = nil
				end
			end
			
			if next(hurtFeed) then
				local hurtFeedKeyless = table.ClearKeys(hurtFeed, true)
				table.sort(hurtFeedKeyless, function(a,b)
					return a.damage > b.damage
				end)
				
				local textOffset = size*3
				for i,v in ipairs(hurtFeedKeyless) do
					local attributed = v.isBalloon and v.instances > 1 and ROTGB_LocalizeString("rotgb.gballoon_target.damage.multiple", ROTGB_Commatize(v.instances), v.__key) or v.__key
					
					local damageText = v.damage < 0 and "rotgb.gballoon_target.heal" or "rotgb.gballoon_target.damage"
					
					--[[local textPart1 = "Took "..ROTGB_Commatize(v.damage).." damage from "
					if v.damage < 0 then
						textPart1 = "Healed "..ROTGB_Commatize(-v.damage).." health from "
					end
					local textPart2 = "!"]]
					local alpha = math.Remap(realTime, v.timestamp, v.timestamp+hurtFeedStaySeconds, 512, 0)
					local fgColor = Color(255, 255, 255, math.min(alpha, 255))
					local fgColor2 = v.color or fgColor
					fgColor2 = Color(fgColor2.r, fgColor2.g, fgColor2.b, math.min(alpha, 255))
					local bgColor = Color(0, 0, 0, math.min(alpha, 255))
					
					ROTGB_DrawMultiColoredOutlinedText(
						ROTGB_LocalizeMulticoloredString(
							damageText,
							{ROTGB_Commatize(math.abs(v.damage)), attributed},
							fgColor,
							{fgColor, fgColor2}
						),
						"Trebuchet24",
						textX,
						yPos+textOffset,
						TEXT_ALIGN_LEFT,
						TEXT_ALIGN_TOP,
						2,
						bgColor
					)
					
					--[[local offsetX = draw.SimpleTextOutlined(textPart1, "Trebuchet24", textX, yPos+textOffset, fgColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, bgColor)
					offsetX = offsetX + draw.SimpleTextOutlined(attributed, "Trebuchet24", textX+offsetX, yPos+textOffset, fgColor2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, bgColor)
					draw.SimpleTextOutlined(textPart2, "Trebuchet24", textX+offsetX, yPos+textOffset, fgColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, bgColor)]]
					textOffset = textOffset + 24
				end
			end
			
			if (bossData.lastUpdateTime or -4) + 3 > RealTime() then
				if not bossData.title then
					local npcTable = list.GetForEdit("NPC")[bossData.type]
					local displayName = ROTGB_GetBalloonName(bossData.type, bit.band(bossData.flags,1)==1, bit.band(bossData.flags,2)==2, bit.band(bossData.flags,4)==4, bit.band(bossData.flags,8)==8)
					bossData.title = string.upper(displayName)
					local h,s,v = ColorToHSV(string.ToColor(npcTable.KeyValues.BalloonColor))
					if s == 1 then v = 1 end
					s = s / 2
					v = (v + 1) / 2
					bossData.color = HSVToColor(h,s,v)
				end
				if bit.band(bossData.flags,16)==16 then
					bossData.color = HSVToColor(RealTime()*60%360,0.5,1)
				end
				bossData.healthHistory = bossData.healthHistory or {}
				table.insert(bossData.healthHistory, bossData.health)
				if #bossData.healthHistory > 60 then
					table.remove(bossData.healthHistory, 1)
				end
				local currentHealthSegment = math.max(math.ceil(bossData.health / bossData.maxHealth * bossData.healthSegments), 1)
				local healthPerSegment = bossData.maxHealth / bossData.healthSegments
				local maximumSegmentHealth = bossData.maxHealth / bossData.healthSegments * currentHealthSegment
				local healthPercent = (bossData.health - maximumSegmentHealth + healthPerSegment) / healthPerSegment
				local bufferHealthPercent = (math.min(bossData.healthHistory[1], maximumSegmentHealth) - maximumSegmentHealth + healthPerSegment) / healthPerSegment
				
				local padding = BOSS_FONT_HEIGHT / 2
				local barW = scrW / 3
				local barH = BOSS_FONT_HEIGHT
				local barX = (scrW - barW) / 2
				local barY = BOSS_FONT_HEIGHT * 2 + padding
				
				local healthBarsP = math.floor(BOSS_FONT_HEIGHT / 8)
				local healthBarsPW = BOSS_FONT_HEIGHT
				local healthBarsW = healthBarsPW - healthBarsP * 2
				local healthBarsX = barX + barW
				local healthBarsY = barY + barH
				
				local backgroundW = barW + padding * 2
				local backgroundH = BOSS_FONT_HEIGHT + barH + healthBarsPW + padding * 2
				local backgroundX = (scrW - backgroundW) / 2
				local backgroundY = BOSS_FONT_HEIGHT
				local backgroundC = color_black_semiopaque
				
				if bossData.currentHealthSegment ~= currentHealthSegment then
					if bossData.currentHealthSegment then
						bossData.lastWarningTime = RealTime()
					end
					bossData.currentHealthSegment = currentHealthSegment
					bossData.currentHealthSegmentColor = HSVToColor((currentHealthSegment-1)*30%360,1,1)
					bossData.previousHealthSegmentColors = {}
					for i=0,currentHealthSegment-2 do
						table.insert(bossData.previousHealthSegmentColors, HSVToColor(i*30%360,1,1))
					end
				end
				if (bossData.lastWarningTime or -4) + 3 > RealTime() then
					local redness = math.Clamp((bossData.lastWarningTime+3-RealTime())*85, 0, 255)
					backgroundC = Color(redness, 0, 0, 191)
				end
				bossData.oldHealthPercent = bossData.oldHealthPercent or healthPercent
				--[[if bossData.oldHealthPercent < healthPercent then
					bossData.oldHealthPercent = healthPercent
				else]]
					bossData.oldHealthPercent = (bossData.oldHealthPercent*4 + healthPercent) / 5
				--end
				bossData.oldBufferHealthPercent = bossData.oldBufferHealthPercent or bufferHealthPercent
				--[[if bossData.oldBufferHealthPercent < bufferHealthPercent then
					bossData.oldBufferHealthPercent = bufferHealthPercent
				else]]
					bossData.oldBufferHealthPercent = (bossData.oldBufferHealthPercent*4 + bufferHealthPercent) / 5
				--end
				
				draw.RoundedBox(8, backgroundX, backgroundY, backgroundW, backgroundH, backgroundC)
				draw.SimpleText(bossData.title, "RotgBBossFont", scrW/2, backgroundY+padding, bossData.color, TEXT_ALIGN_CENTER)
				
				local previousSegmentColorsAmount = #bossData.previousHealthSegmentColors
				local previousSegmentColor = bossData.previousHealthSegmentColors[previousSegmentColorsAmount] or color_black_semiopaque
				surface.SetDrawColor(previousSegmentColor.r, previousSegmentColor.g, previousSegmentColor.b, previousSegmentColor.a)
				surface.DrawRect(barX, barY, barW, barH)
				
				surface.SetDrawColor(255,255,255)
				surface.DrawRect(barX, barY, barW*bossData.oldBufferHealthPercent, barH)
				
				local segmentColor = bossData.currentHealthSegmentColor
				surface.SetDrawColor(segmentColor.r, segmentColor.g, segmentColor.b, segmentColor.a)
				surface.DrawRect(barX, barY, barW*bossData.oldHealthPercent, barH)
				
				local healthText = ROTGB_LocalizeString("rotgb.gballoon.health", ROTGB_Commatize(bossData.health), ROTGB_Commatize(bossData.maxHealth))
				draw.SimpleText(healthText, "RotgBBossFont", barX, barY+barH, color_white)
				
				if currentHealthSegment > 20 then
					local localX = healthBarsX - healthBarsPW + healthBarsP
					local localY = healthBarsY + healthBarsP
					
					surface.SetDrawColor(previousSegmentColor.r,previousSegmentColor.g,previousSegmentColor.b)
					surface.DrawRect(localX, localY, healthBarsW, healthBarsW)
					
					local healthSegmentsText = ROTGB_LocalizeString("rotgb.gballoon.health.segments", ROTGB_Commatize(currentHealthSegment-1))
					draw.SimpleText(healthSegmentsText, "RotgBBossFont", localX - healthBarsP, localY + healthBarsW / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				else
					for k,v in pairs(bossData.previousHealthSegmentColors) do
						local localX = healthBarsX - healthBarsPW * (previousSegmentColorsAmount-k+1) + healthBarsP
						local localY = healthBarsY + healthBarsP
						
						surface.SetDrawColor(v.r,v.g,v.b)
						surface.DrawRect(localX, localY, healthBarsW, healthBarsW)
					end
				end
			elseif bossData then
				bossData = {}
			end
			
			--[[local hintMessage
			if hintExpiryTime < RealTime() then
				if nextHintMessage then
					hintMessage = nextHintMessage
					nextHintMessage = nil
					hintExpiryTime = RealTime() + 5
				elseif hintBox:IsVisible() then
					hintBox:Hide()
				end
			end
			if hintMessage then
				if not hintBox:IsVisible() then
					hintBox:Show()
				end
				hintBoxLabel:SetText(nextHintMessage)
				hintBox.hintExpiryTime = hintExpiryTime
			end]]
		end
	end)

	hook.Add("AddToolMenuTabs","RotgB",function()
		spawnmenu.AddToolTab("RotgB",ROTGB_LocalizeString("rotgb.spawnmenu.category"))
	end)

	hook.Add("AddToolMenuCategories","RotgB",function()
		spawnmenu.AddToolCategory("RotgB","Client",ROTGB_LocalizeString("rotgb.spawnmenu.category.client"))
		spawnmenu.AddToolCategory("RotgB","Server",ROTGB_LocalizeString("rotgb.spawnmenu.category.server"))
		spawnmenu.AddToolCategory("RotgB","Tools",ROTGB_LocalizeString("rotgb.spawnmenu.category.tools"))
	end)
	
	local function AddDFormConVarDescription(DForm, conVar, ...)
		local localizedText = ROTGB_LocalizeString("rotgb.convar.description.display", ROTGB_LocalizeString("rotgb.convar."..conVar..".description", ...))
		DForm:Help(localizedText)
	end
	
	local function PopulateClientDForm(DForm)
		DForm:Help("") --whitespace
		DForm:ControlHelp(ROTGB_LocalizeString("rotgb.spawnmenu.category.client.display"))
		DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_hud_enabled.name"),"rotgb_hud_enabled")
		AddDFormConVarDescription(DForm, "rotgb_hud_enabled")
		DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_hud_x.name"),"rotgb_hud_x",0,1,3)
		AddDFormConVarDescription(DForm, "rotgb_hud_x")
		DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_hud_y.name"),"rotgb_hud_y",0,1,3)
		AddDFormConVarDescription(DForm, "rotgb_hud_y")
		DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_hud_size.name"),"rotgb_hud_size",0,128,0)
		AddDFormConVarDescription(DForm, "rotgb_hud_size")
		DForm:Help("") --whitespace
		DForm:ControlHelp(ROTGB_LocalizeString("rotgb.spawnmenu.category.client.ranges"))
		DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_range_enable_indicators.name"),"rotgb_range_enable_indicators")
		AddDFormConVarDescription(DForm, "rotgb_range_enable_indicators")
		DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_range_hold_time.name"),"rotgb_range_hold_time",0,10,3)
		AddDFormConVarDescription(DForm, "rotgb_range_hold_time")
		DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_range_fade_time.name"),"rotgb_range_fade_time",0,10,3)
		AddDFormConVarDescription(DForm, "rotgb_range_fade_time")
		DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_range_alpha.name"),"rotgb_range_alpha",0,255,0)
		AddDFormConVarDescription(DForm, "rotgb_range_alpha")
		DForm:Help("") --whitespace
		DForm:ControlHelp(ROTGB_LocalizeString("rotgb.spawnmenu.category.client.others"))
		DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_music_volume.name"),"rotgb_music_volume",0,4,3)
		AddDFormConVarDescription(DForm, "rotgb_music_volume")
		DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_no_wave_hints.name"),"rotgb_no_wave_hints")
		AddDFormConVarDescription(DForm, "rotgb_no_wave_hints")
		DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_circle_segments.name"),"rotgb_circle_segments",3,200,0)
		AddDFormConVarDescription(DForm, "rotgb_circle_segments")
		DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_hoverover_distance.name"),"rotgb_hoverover_distance",0,100,1)
		AddDFormConVarDescription(DForm, "rotgb_hoverover_distance")
		DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_freeze_effect.name"),"rotgb_freeze_effect")
		AddDFormConVarDescription(DForm, "rotgb_freeze_effect")
		DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_no_glow.name"),"rotgb_no_glow")
		AddDFormConVarDescription(DForm, "rotgb_no_glow")
	end
	
	hook.Add("PopulateToolMenu","RotgB",function()
		spawnmenu.AddToolMenuOption("RotgB","Server","RotgB_Server1",ROTGB_LocalizeString("rotgb.spawnmenu.category.server.cash"),"","",function(DForm)
			DForm:TextEntry(ROTGB_LocalizeString("rotgb.convar.rotgb_cash_param.name"),"rotgb_cash_param")
			AddDFormConVarDescription(DForm, "rotgb_cash_param")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_setcash.name"),"rotgb_setcash","*")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_addcash.name"),"rotgb_addcash","*")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_subcash.name"),"rotgb_subcash","*")
			DForm:Help(ROTGB_LocalizeString("rotgb.command.presets"))
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_cash_param_internal.0"),"rotgb_cash_param_internal","0")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_cash_param_internal.650"),"rotgb_cash_param_internal","650")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_cash_param_internal.850"),"rotgb_cash_param_internal","850")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_cash_param_internal.20000"),"rotgb_cash_param_internal","20000")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_cash_param_internal.0x1p128"),"rotgb_cash_param_internal","0x1p128")
			DForm:Help(ROTGB_LocalizeString("rotgb.command.rotgb_cash_param_internal.hint"))
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_cash_mul.name"),"rotgb_cash_mul",0,10,3)
			AddDFormConVarDescription(DForm, "rotgb_cash_mul")
			DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_individualcash.name"),"rotgb_individualcash")
			AddDFormConVarDescription(DForm, "rotgb_individualcash")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_starting_cash.name"),"rotgb_starting_cash",0,10000,0)
			AddDFormConVarDescription(DForm, "rotgb_starting_cash")
		end)
		spawnmenu.AddToolMenuOption("RotgB","Server","RotgB_Server2",ROTGB_LocalizeString("rotgb.spawnmenu.category.server.gballoons"),"","",function(DForm)
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_difficulty.name"),"rotgb_difficulty",0,3,0)
			AddDFormConVarDescription(DForm, "rotgb_difficulty")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_fire_delay.name"),"rotgb_fire_delay",0,10,3)
			AddDFormConVarDescription(DForm, "rotgb_fire_delay")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_regen_delay.name"),"rotgb_regen_delay",0,10,3)
			AddDFormConVarDescription(DForm, "rotgb_regen_delay")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_rainbow_gblimp_regen_rate.name"),"rotgb_rainbow_gblimp_regen_rate",0,10,3)
			AddDFormConVarDescription(DForm, "rotgb_rainbow_gblimp_regen_rate")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_scale.name"),"rotgb_scale",0,10,3)
			AddDFormConVarDescription(DForm, "rotgb_scale")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_speed_mul.name"),"rotgb_speed_mul",0,10,3)
			AddDFormConVarDescription(DForm, "rotgb_speed_mul")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_health_multiplier.name"),"rotgb_health_multiplier",0,10,3)
			AddDFormConVarDescription(DForm, "rotgb_health_multiplier")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_blimp_health_multiplier.name"),"rotgb_blimp_health_multiplier",0,10,3)
			AddDFormConVarDescription(DForm, "rotgb_blimp_health_multiplier")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_afflicted_damage_multiplier.name"),"rotgb_afflicted_damage_multiplier",0,10,3)
			AddDFormConVarDescription(DForm, "rotgb_afflicted_damage_multiplier")
			DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_ignore_damage_resistances.name"),"rotgb_ignore_damage_resistances")
			AddDFormConVarDescription(DForm, "rotgb_ignore_damage_resistances")
			DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_use_kill_handler.name"),"rotgb_use_kill_handler")
			AddDFormConVarDescription(DForm, "rotgb_use_kill_handler")
			DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_use_achievement_handler.name"),"rotgb_use_achievement_handler")
			AddDFormConVarDescription(DForm, "rotgb_use_achievement_handler")
			DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_legacy_gballoons.name"),"rotgb_legacy_gballoons")
			AddDFormConVarDescription(DForm, "rotgb_legacy_gballoons")
			DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_pertain_effects.name"),"rotgb_pertain_effects")
			AddDFormConVarDescription(DForm, "rotgb_pertain_effects")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_bloodtype.name"),"rotgb_bloodtype",-1,16,0)
			AddDFormConVarDescription(DForm, "rotgb_bloodtype")
			DForm:TextEntry(ROTGB_LocalizeString("rotgb.convar.rotgb_blooddecal.name"),"rotgb_blooddecal")
			AddDFormConVarDescription(DForm, "rotgb_blooddecal", table.concat(list.Get("PaintMaterials"), ", "))
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_blacklist.name"),"rotgb_blacklist")
		end)
		spawnmenu.AddToolMenuOption("RotgB","Server","RotgB_Server3",ROTGB_LocalizeString("rotgb.spawnmenu.category.server.spawners_targets"),"","",function(DForm)
			DForm:TextEntry(ROTGB_LocalizeString("rotgb.convar.rotgb_health_param.name"),"rotgb_health_param")
			AddDFormConVarDescription(DForm, "rotgb_health_param")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_sethealth.name"),"rotgb_sethealth","*")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_healhealth.name"),"rotgb_healhealth","*")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_addhealth.name"),"rotgb_addhealth","*")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_subhealth.name"),"rotgb_subhealth","*")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_setmaxhealth.name"),"rotgb_setmaxhealth","*")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_addmaxhealth.name"),"rotgb_addmaxhealth","*")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_submaxhealth.name"),"rotgb_submaxhealth","*")
			DForm:Help(ROTGB_LocalizeString("rotgb.command.presets"))
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_health_param_internal.1"),"rotgb_health_param_internal","1")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_health_param_internal.100"),"rotgb_health_param_internal","100")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_health_param_internal.150"),"rotgb_health_param_internal","150")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_health_param_internal.200"),"rotgb_health_param_internal","200")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_health_param_internal.999999999"),"rotgb_health_param_internal","999999999")
			DForm:Help(ROTGB_LocalizeString("rotgb.command.rotgb_health_param_internal.hint"))
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_target_natural_health.name"),"rotgb_target_natural_health",0,1000,0)
			AddDFormConVarDescription(DForm, "rotgb_target_natural_health")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_target_health_override.name"),"rotgb_target_health_override",0,1000,0)
			AddDFormConVarDescription(DForm, "rotgb_target_health_override")
			
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_default_first_wave.name"),"rotgb_default_first_wave",1,1000,0)
			AddDFormConVarDescription(DForm, "rotgb_default_first_wave")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_default_last_wave.name"),"rotgb_default_last_wave",1,1000,0)
			AddDFormConVarDescription(DForm, "rotgb_default_last_wave")
			DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_freeplay.name"),"rotgb_freeplay")
			AddDFormConVarDescription(DForm, "rotgb_freeplay")
			DForm:NumberWang(ROTGB_LocalizeString("rotgb.convar.rotgb_spawner_force_auto_start.name"),"rotgb_spawner_force_auto_start",-1,1)
			AddDFormConVarDescription(DForm, "rotgb_spawner_force_auto_start")
			DForm:NumberWang(ROTGB_LocalizeString("rotgb.convar.rotgb_spawner_no_multi_start.name"),"rotgb_spawner_no_multi_start",-1,1)
			AddDFormConVarDescription(DForm, "rotgb_spawner_no_multi_start")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_spawner_spawn_rate.name"),"rotgb_spawner_spawn_rate",0,10,3)
			AddDFormConVarDescription(DForm, "rotgb_spawner_spawn_rate")
			DForm:TextEntry(ROTGB_LocalizeString("rotgb.convar.rotgb_default_wave_preset.name"),"rotgb_default_wave_preset")
			AddDFormConVarDescription(DForm, "rotgb_default_wave_preset")
			DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_waveeditor.name"),"rotgb_waveeditor")
		end)
		spawnmenu.AddToolMenuOption("RotgB","Server","RotgB_Server4",ROTGB_LocalizeString("rotgb.spawnmenu.category.server.ai"),"","",function(DForm)
			DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_use_custom_pathfinding.name"),"rotgb_use_custom_pathfinding")
			AddDFormConVarDescription(DForm, "rotgb_use_custom_pathfinding")
			--[[DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_use_custom_ai.name"),"rotgb_use_custom_ai")
			AddDFormConVarDescription(DForm, "rotgb_use_custom_ai")]]
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_target_choice.name"),"rotgb_target_choice",-1,511,0)
			AddDFormConVarDescription(DForm, "rotgb_target_choice")
			DForm:NumberWang(ROTGB_LocalizeString("rotgb.convar.rotgb_target_sort.name"),"rotgb_target_sort",-1,3)
			AddDFormConVarDescription(DForm, "rotgb_target_sort")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_search_size.name"),"rotgb_search_size",-1,2048,0)
			AddDFormConVarDescription(DForm, "rotgb_search_size")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_target_tolerance.name"),"rotgb_target_tolerance",0,1000,1)
			AddDFormConVarDescription(DForm, "rotgb_target_tolerance")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_pop_on_contact.name"),"rotgb_pop_on_contact",-2,511,0)
			AddDFormConVarDescription(DForm, "rotgb_pop_on_contact")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_setminlookaheaddistance.name"),"rotgb_setminlookaheaddistance",0,1000,1)
			AddDFormConVarDescription(DForm, "rotgb_setminlookaheaddistance")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_func_nav_expand.name"),"rotgb_func_nav_expand",0,100,2)
			AddDFormConVarDescription(DForm, "rotgb_func_nav_expand")
		end)
		spawnmenu.AddToolMenuOption("RotgB","Server","RotgB_Server5",ROTGB_LocalizeString("rotgb.spawnmenu.category.server.towers"),"","",function(DForm)
			DForm:TextEntry(ROTGB_LocalizeString("rotgb.convar.rotgb_tower_blacklist.name"),"rotgb_tower_blacklist")
			AddDFormConVarDescription(DForm, "rotgb_tower_blacklist")
			DForm:NumberWang(ROTGB_LocalizeString("rotgb.convar.rotgb_tower_chess_only.name"),"rotgb_tower_chess_only",-1,1)
			AddDFormConVarDescription(DForm, "rotgb_tower_chess_only")
			DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_tower_damage_others.name"),"rotgb_tower_damage_others")
			AddDFormConVarDescription(DForm, "rotgb_tower_damage_others")
			DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_tower_force_charge.name"),"rotgb_tower_force_charge")
			AddDFormConVarDescription(DForm, "rotgb_tower_force_charge")
			DForm:NumSlider("rotgb.convar.rotgb_tower_charge_rate.name","rotgb_tower_charge_rate",0,10,3)
			AddDFormConVarDescription(DForm, "rotgb_tower_charge_rate")
			DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_ignore_upgrade_limits.name"),"rotgb_ignore_upgrade_limits")
			AddDFormConVarDescription(DForm, "rotgb_ignore_upgrade_limits")
			DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_tower_ignore_physgun.name"),"rotgb_tower_ignore_physgun")
			AddDFormConVarDescription(DForm, "rotgb_tower_ignore_physgun")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_damage_multiplier.name"),"rotgb_damage_multiplier",0,10,3)
			AddDFormConVarDescription(DForm, "rotgb_damage_multiplier")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_tower_range_multiplier.name"),"rotgb_tower_range_multiplier",0,10,3)
			AddDFormConVarDescription(DForm, "rotgb_tower_range_multiplier")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_tower_income_mul.name"),"rotgb_tower_income_mul",0,10,3)
			AddDFormConVarDescription(DForm, "rotgb_tower_income_mul")
		end)
		spawnmenu.AddToolMenuOption("RotgB","Server","RotgB_Server6",ROTGB_LocalizeString("rotgb.spawnmenu.category.server.optimization"),"","",function(DForm)
			DForm:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_notrails.name"),"rotgb_notrails")
			AddDFormConVarDescription(DForm, "rotgb_notrails")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_max_to_exist.name"),"rotgb_max_to_exist",0,1024,0)
			AddDFormConVarDescription(DForm, "rotgb_max_to_exist")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_max_effects_per_second.name"),"rotgb_max_effects_per_second",0,100,2)
			AddDFormConVarDescription(DForm, "rotgb_max_effects_per_second")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_max_fires_per_second.name"),"rotgb_max_fires_per_second",0,100,2)
			AddDFormConVarDescription(DForm, "rotgb_max_fires_per_second")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_resist_effect_delay.name"),"rotgb_resist_effect_delay",-1,10,3)
			AddDFormConVarDescription(DForm, "rotgb_resist_effect_delay")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_crit_effect_delay.name"),"rotgb_crit_effect_delay",-1,10,3)
			AddDFormConVarDescription(DForm, "rotgb_crit_effect_delay")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_path_delay.name"),"rotgb_path_delay",0,100,2)
			AddDFormConVarDescription(DForm, "rotgb_path_delay")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_tower_maxcount.name"),"rotgb_tower_maxcount",-1,64,0)
			AddDFormConVarDescription(DForm, "rotgb_tower_maxcount")
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_init_rate.name"),"rotgb_init_rate",-1,100,2)
			AddDFormConVarDescription(DForm, "rotgb_init_rate")
		end)
		spawnmenu.AddToolMenuOption("RotgB","Server","RotgB_Server7",ROTGB_LocalizeString("rotgb.spawnmenu.category.server.miscellaneous"),"","",function(DForm)
			DForm:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_visual_scale.name"),"rotgb_visual_scale",0,10,3)
			AddDFormConVarDescription(DForm, "rotgb_visual_scale")
			DForm:ControlHelp(ROTGB_LocalizeString("rotgb.command.rotgb_reset_convars.hint"))
			local dangerbutton = DForm:Button(ROTGB_LocalizeString("rotgb.command.rotgb_reset_convars.name"),"rotgb_reset_convars")
			dangerbutton:SetTextColor(Color(255,0,0))
			local DTextEntry = DForm:TextEntry(ROTGB_LocalizeString("rotgb.convar.rotgb_debug.name"),"rotgb_debug")
			function DTextEntry:GetAutoComplete(text)
				local dbags = DebugArgs
				local last = string.match(text,"[%w_]+$") or ""
				if last==text then
					text=""
				else
					text = text:sub(1,-#last-1)
				end
				local adctab = {}
				for i,v in ipairs(dbags) do
					if string.find(v,"^"..last) and not string.match(text," ?"..v.." ?") then
						table.insert(adctab,text..v)
					end
				end
				return adctab
			end
			AddDFormConVarDescription(DForm, "rotgb_debug", table.concat(DebugArgs, ", "))
		end)
		spawnmenu.AddToolMenuOption("RotgB","Client","RotgB_Client",ROTGB_LocalizeString("rotgb.spawnmenu.category.client.options"),"","",PopulateClientDForm)
		--[[spawnmenu.AddToolMenuOption("Options","RotgB","RotgB_Bestiary","Bestiary","","",function(DForm) -- Add panel
			local CategoryList = vgui.Create("DCategoryList",DForm)
			for i,v in ipairs(order) do
				AddBalloon(CategoryList,v)
			end
			CategoryList:SetHeight(768)
			CategoryList:Dock(FILL)
			DForm:AddItem(CategoryList)
		end)]]
		spawnmenu.AddToolMenuOption("RotgB","Tools","RotgB_NavEditorTool",ROTGB_LocalizeString("tool.rotgb_nav_editor.name"),game.SinglePlayer() and "gmod_tool rotgb_nav_editor" or "","",function(form)
			if game.SinglePlayer() then
				form:Help(ROTGB_LocalizeString("tool.rotgb_nav_editor.desc"))
				local label = form:Help(ROTGB_LocalizeString("tool.rotgb_nav_editor.singleplayer"))
				label:SetTextColor(Color(255,0,0))
				form:ControlHelp(ROTGB_LocalizeString("tool.rotgb_nav_editor.rb655_easy_navedit.hint"))
				form:Button(ROTGB_LocalizeString("tool.rotgb_nav_editor.rb655_easy_navedit.equip"),"gmod_tool","rb655_easy_navedit")
				local Button = form:Button(ROTGB_LocalizeString("tool.rotgb_nav_editor.rb655_easy_navedit.get"))
				Button.DoClick = function() gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=527885257") end
			else
				local label = form:Help(ROTGB_LocalizeString("tool.rotgb_nav_editor.singleplayer"))
				label:SetTextColor(Color(255,0,0))
			end
		end)
		spawnmenu.AddToolMenuOption("RotgB","Tools","RotgB_WaypointEditorTool",ROTGB_LocalizeString("tool.rotgb_waypoint_editor.name"),"gmod_tool rotgb_waypoint_editor","",function(form)
			form:Help(ROTGB_LocalizeString("tool.rotgb_waypoint_editor.desc"))
			form:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_teleport.name"),"rotgb_waypoint_editor_teleport")
			form:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_straight.name"),"rotgb_waypoint_editor_straight")
			form:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_weight.name"),"rotgb_waypoint_editor_weight",0,100,0)
			form:Help(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_weight.description"))
			form:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_always.name"),"rotgb_waypoint_editor_indicator_always")
			local choicelist = form:ComboBox(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_effect.name"),"rotgb_waypoint_editor_indicator_effect")
			choicelist:SetSortItems(false)
			choicelist:AddChoice(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_effect.sprites.glow04_noz"),"sprites/glow04_noz")
			choicelist:AddChoice(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_effect.sprites.light_ignorez"),"sprites/light_ignorez")
			choicelist:AddChoice(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_effect.sprites.physg_glow1"),"sprites/physg_glow1")
			choicelist:AddChoice(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_effect.sprites.physg_glow2"),"sprites/physg_glow2")
			choicelist:AddChoice(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_effect.sprites.sent_ball"),"sprites/sent_ball")
			choicelist:AddChoice(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_effect.effects.select_ring"),"effects/select_ring")
			choicelist:AddChoice(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_effect.effects.select_dot"),"effects/select_dot")
			choicelist:AddChoice(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_effect.gui.close_32"),"gui/close_32")
			choicelist:AddChoice(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_effect.icon16.circlecross.png"),"icon16/circlecross.png")
			choicelist:AddChoice(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_effect.gui.progress_cog.png"),"gui/progress_cog.png")
			form:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_scale.name"),"rotgb_waypoint_editor_indicator_scale",0,10)
			form:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_speed.name"),"rotgb_waypoint_editor_indicator_speed",0.1,10)
			form:CheckBox(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_bounce.name"),"rotgb_waypoint_editor_indicator_bounce")
			choicelist = form:ComboBox(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_color.name"),"rotgb_waypoint_editor_indicator_color")
			for i=0,11 do
				choicelist:AddChoice(ROTGB_LocalizeString(string.format("rotgb.convar.rotgb_waypoint_editor_indicator_color.%i", i)), i)
			end
			local mixer = vgui.Create("DColorMixer")
			mixer:SetLabel(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_color.solid_selection"))
			mixer:SetConVarR("rotgb_waypoint_editor_indicator_r")
			mixer:SetConVarG("rotgb_waypoint_editor_indicator_g")
			mixer:SetConVarB("rotgb_waypoint_editor_indicator_b")
			mixer:SetConVarA("rotgb_waypoint_editor_indicator_a")
			form:AddItem(mixer)
			mixer = vgui.Create("DColorMixer")
			mixer:SetLabel(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_indicator_color.solid_gblimp_selection"))
			mixer:SetConVarR("rotgb_waypoint_editor_indicator_boss_r")
			mixer:SetConVarG("rotgb_waypoint_editor_indicator_boss_g")
			mixer:SetConVarB("rotgb_waypoint_editor_indicator_boss_b")
			mixer:SetConVarA("rotgb_waypoint_editor_indicator_boss_a")
			form:AddItem(mixer)
		end)
		spawnmenu.AddToolMenuOption("RotgB","Tools","RotgB_NobuildEditorTool",ROTGB_LocalizeString("tool.rotgb_nobuild_editor.name"),"gmod_tool rotgb_nobuild_editor","",function(form)
			form:Help(ROTGB_LocalizeString("tool.rotgb_nobuild_editor.desc"))
			form:NumSlider(ROTGB_LocalizeString("rotgb.convar.rotgb_nobuild_editor_scale.name"),"rotgb_nobuild_editor_scale",0.1,10,3)
		end)
	end)
	
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
			ROTGB_CreateBlacklistPanel(blacklist, whitelist)
		elseif operation == ROTGB_OPERATION_WAVE_EDIT then
			ROTGB_CreateWavePanel()
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
		elseif operation == ROTGB_OPERATION_BOSS then
			local id = net.ReadUInt(16)
			if bossData.id ~= id then
				bossData = {}
			end
			bossData.id = id
			bossData.type = net.ReadString()
			bossData.flags = net.ReadUInt(8)
			bossData.health = math.max(net.ReadInt(32), 0)
			bossData.maxHealth = net.ReadInt(32)
			bossData.healthSegments = net.ReadUInt(8)
			bossData.lastUpdateTime = RealTime()
		elseif operation == ROTGB_OPERATION_NOTIFY then
			local level = net.ReadUInt(4)
			local isCustom = net.ReadBool()
			if isCustom then
				local msg = net.ReadString()
				local flags = net.ReadUInt(8)
				local additionalArguments = {}
				
				if bit.band(flags, 1)~=0 then
					if level == ROTGB_NOTIFYTYPE_CHAT then 
						additionalArguments.color = net.ReadColor()
					elseif level == ROTGB_NOTIFYTYPE_INFO or level == ROTGB_NOTIFYTYPE_ERROR or level == ROTGB_NOTIFYTYPE_HINT then
						additionalArguments.holdtime = net.ReadFloat()
					end
				end
				
				ROTGB_CauseNotification(msg,level,nil,additionalArguments)
			else
				local message = net.ReadUInt(8)
				local flags = net.ReadUInt(8)
				local additionalArguments = {}
				
				if bit.band(flags, 1)~=0 then
					if level == ROTGB_NOTIFYTYPE_CHAT then 
						additionalArguments.color = net.ReadColor()
					elseif level == ROTGB_NOTIFYTYPE_INFO or level == ROTGB_NOTIFYTYPE_ERROR or level == ROTGB_NOTIFYTYPE_HINT then
						additionalArguments.holdtime = net.ReadFloat()
					end
				end
				
				if message == ROTGB_NOTIFY_NOMULTISTART then
					ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.gballoon_spawner.no_multi_start"), level, nil, additionalArguments)
				elseif message == ROTGB_NOTIFY_WAVESTART then
					ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.gballoon_spawner.wave_start", net.ReadInt(32), net.ReadDouble()), level, nil, additionalArguments)
				elseif message == ROTGB_NOTIFY_WIN then
					ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.gballoon_spawner.win"), level, nil, additionalArguments)
					if ROTGB_GetConVarValue("rotgb_freeplay") then
						ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.gballoon_spawner.freeplay"), level, nil, additionalArguments)
					end
				elseif message == ROTGB_NOTIFY_WAVELOADED then
					ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.gballoon_spawner.loaded", net.ReadString()), level, nil, additionalArguments)
				elseif message == ROTGB_NOTIFY_PLACEMENTILLEGAL then
					local tower = net.ReadEntity()
					if IsValid(tower) then
						ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.tower.no_build", ROTGB_LocalizeString("rotgb.tower."..tower:GetClass()..".name")), level, nil, additionalArguments)
					end
				elseif message == ROTGB_NOTIFY_PLACEMENTILLEGALOFF then
					local tower = net.ReadEntity()
					if IsValid(tower) then
						ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.tower.no_build.off", ROTGB_LocalizeString("rotgb.tower."..tower:GetClass()..".name")), level, nil, additionalArguments)
					end
				elseif message == ROTGB_NOTIFY_NOSPAWNERS then
					ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.gballoon_spawner.missing"), level, nil, additionalArguments)
				elseif message == ROTGB_NOTIFY_TRANSFERSHARED then
					ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.game_swep.transfer.shared"), level, nil, additionalArguments)
				elseif message == ROTGB_NOTIFY_TOWERLEVEL then
					ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.tower.no_place.level", ROTGB_Commatize(net.ReadUInt(8))), level, nil, additionalArguments)
				elseif message == ROTGB_NOTIFY_TOWERCASH then
					local cost = net.ReadFloat()
					ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.tower.no_place.cant_afford", ROTGB_FormatCash(cost, true)), level, nil, additionalArguments)
				elseif message == ROTGB_NOTIFY_NAVMESHMISSING then
					ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.navmesh.missing"), level, nil, additionalArguments)
					ROTGB_LogError("DEPRECATION WARNING: ROTGB_NOTIFY_NAVMESHMISSING is now unused and will be deleted in the future.", "")
					debug.Trace()
				elseif message == ROTGB_NOTIFY_TOWERBLACKLISTED then
					ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.tower.no_place.blacklist"), level, nil, additionalArguments)
				elseif message == ROTGB_NOTIFY_TOWERCHESSONLY then
					local mustChess = net.ReadBool()
					ROTGB_CauseNotification(ROTGB_LocalizeString(mustChess and "rotgb.tower.no_place.chess" or "rotgb.tower.no_place.no_chess"), level, nil, additionalArguments)
				elseif message == ROTGB_NOTIFY_TOWERMAX then
					ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.tower.no_place.no_more"), level, nil, additionalArguments)
				elseif message == ROTGB_NOTIFY_TOWERNOTOWNER then
					ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.tower.upgrade.not_owner"), level, nil, additionalArguments)
				elseif message == ROTGB_NOTIFY_WAVEEND and not ROTGB_GetConVarValue("rotgb_no_wave_hints") then
					local token = string.format("rotgb.wave_hints.%i", net.ReadInt(32))
					local localized = ROTGB_LocalizeString(token)
					if token ~= localized then
						ROTGB_CauseNotification(localized, level, nil, additionalArguments)
					end
				elseif message == ROTGB_NOTIFY_TUTORIAL then
					local token = string.format("rotgb_tg.tutorial.%i", net.ReadUInt(8))
					local localized = ROTGB_LocalizeString(token)
					ROTGB_CauseNotification(localized, level, nil, additionalArguments)
				end
			end
		elseif operation == ROTGB_OPERATION_NOTIFYCHAT then
			local message = net.ReadUInt(8)
			if message == ROTGB_NOTIFYCHAT_NOMULTISTART then
				ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.gballoon_spawner.no_multi_start"), ROTGB_NOTIFYTYPE_CHAT)
			elseif message == ROTGB_NOTIFYCHAT_WAVESTART then
				ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.gballoon_spawner.wave_start", net.ReadInt(32), net.ReadDouble()), ROTGB_NOTIFYTYPE_CHAT)
			elseif message == ROTGB_NOTIFYCHAT_WIN then
				ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.gballoon_spawner.win"), ROTGB_NOTIFYTYPE_CHAT)
				if ROTGB_GetConVarValue("rotgb_freeplay") then
					ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.gballoon_spawner.freeplay"), ROTGB_NOTIFYTYPE_CHAT)
				end
			elseif message == ROTGB_NOTIFYCHAT_WAVELOADED then
				ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.gballoon_spawner.loaded", net.ReadString()), ROTGB_NOTIFYTYPE_CHAT)
			elseif message == ROTGB_NOTIFYCHAT_PLACEMENTILLEGAL then
				local tower = net.ReadEntity()
				if IsValid(tower) then
					ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.tower.no_build", ROTGB_LocalizeString("rotgb.tower."..tower:GetClass()..".name")), ROTGB_NOTIFYTYPE_CHAT)
				end
			elseif message == ROTGB_NOTIFYCHAT_PLACEMENTILLEGALOFF then
				local tower = net.ReadEntity()
				if IsValid(tower) then
					ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.tower.no_build.off", ROTGB_LocalizeString("rotgb.tower."..tower:GetClass()..".name")), ROTGB_NOTIFYTYPE_CHAT)
				end
			elseif message == ROTGB_NOTIFYCHAT_NOSPAWNERS then
				ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.gballoon_spawner.missing"), ROTGB_NOTIFYTYPE_CHAT)
			elseif message == ROTGB_NOTIFYCHAT_TRANSFERSHARED then
				ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.game_swep.transfer.shared"), ROTGB_NOTIFYTYPE_CHAT)
			end
			ROTGB_LogError("DEPRECATION WARNING: ROTGB_OPERATION_NOTIFYCHAT must not be used, use ROTGB_CauseNotification() instead.", "")
			debug.Trace()
		elseif operation == ROTGB_OPERATION_NOTIFYARG then
			local message = net.ReadUInt(8)
			if message == ROTGB_NOTIFYARG_TOWERLEVEL then
				local level = net.ReadUInt(8)
				ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.tower.no_place.level", ROTGB_Commatize(level)), ROTGB_NOTIFYTYPE_ERROR)
			elseif message == ROTGB_NOTIFYARG_TOWERCASH then
				local cost = net.ReadFloat()
				ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.tower.no_place.cant_afford", ROTGB_FormatCash(cost, true)), ROTGB_NOTIFYTYPE_ERROR)
			end
			ROTGB_LogError("DEPRECATION WARNING: ROTGB_OPERATION_NOTIFYARG must not be used, use ROTGB_CauseNotification() instead.", "")
			debug.Trace()
		elseif operation == ROTGB_OPERATION_SYNCENTITY then
			local ent = net.ReadEntity()
			if IsValid(ent) then
				if ent:GetClass() == "gballoon_spawner" then
					local dataNum = net.ReadInt(16)
					if dataNum ~= -1 then
						ent.MusicData = {}
						for i=1, dataNum do
							local data = {}
							data.wave = net.ReadInt(32)
							data.file = net.ReadString()
							data.texts = {}
							
							for i=1, net.ReadUInt(8) do
								data.texts[i] = net.ReadString()
							end
							
							table.insert(ent.MusicData, data)
						end
						
						table.SortByMember(ent.MusicData, "wave")
						if ent.GetWave then
							ent:CheckForMusicPlay(ent:GetWave()-1)
						end
					else
						ROTGB_EntityLog(ent, "Received info that music data has not changed!", "music")
					end
					ROTGB_EntityLog(ent, "Received music data! Tracks = "..util.TableToJSON(ent.MusicData, true), "music")
					--ent:CheckForMusicPlay(ent:GetWave())
				end
			end
		end
	end)
	
	--local drawNoBuilds = false
	function ROTGB_SetDrawNoBuilds(value)
		ROTGB_LogError("ROTGB_SetDrawNoBuilds is deprecated and will be removed in Version 7!", "")
		debug.Trace()
	end
	
	--[[local nextUpdate = nil
	hook.Add("PreDrawTranslucentRenderables", "RotgB", function(depth, skybox, skybox3d)
		if (nextUpdate or 0) < RealTime() then
			nextUpdate = RealTime() + 0.5
			for k,v in pairs(ents.FindByClass("func_rotgb_nobuild")) do
				v:SetNoDraw(not drawNoBuilds)
			end
		end
	end)]]
	
	concommand.Add("rotgb_debug_getversion5towerlang",function(ply,cmd,args,argStr)
		if next(args) then
			local resultantString = ""
			for i,v in ipairs(args) do
				local class = v
				local tower = scripted_ents.GetStored(class).t
				resultantString = resultantString..string.format("rotgb.tower.%s.name=%s\n", class, tower.PrintName)
				resultantString = resultantString..string.format("rotgb.tower.%s.purpose=%s\n", class, tower.Purpose)
				
				local ref = tower.UpgradeReference
				for k,v2 in pairs(ref) do
					resultantString = resultantString.."\n"
					for i2=1,#v2.Names do
						resultantString = resultantString..string.format("rotgb.tower.%s.upgrades.%i.%i.name=%s\n", class, k, i2, v2.Names[i2])
						resultantString = resultantString..string.format("rotgb.tower.%s.upgrades.%i.%i.description=%s\n", class, k, i2, v2.Descs[i2])
					end
				end
				resultantString = resultantString.."\n\n\n"
			end
			SetClipboardText(resultantString)
		else
			print(ROTGB_LocalizeString("rotgb.convar.description.display", ROTGB_LocalizeString("rotgb.concommand.rotgb_debug_getversion5towerlang.description")))
		end
	end,"Copies the V6 language strings of V5 towers to your clipboard, which can be readily pasted into a .properties file.\n - Usage: rotgb_debug_getversion5towerlang <classname> <classname> ...")
	
	concommand.Add("rotgb_config_menu_client",function(ply,cmd,args,argStr)
		local Frame = vgui.Create("DFrame")
		Frame:SetSize(ScrW()/2, ScrH()/2)
		Frame:SetTitle(ROTGB_LocalizeString("rotgb.spawnmenu.category.client"))
		Frame:Center()
		Frame:MakePopup()
		
		local Panel = Frame:Add("DPanel")
		Panel:Dock(FILL)
		
		local Scroller = Panel:Add("DScrollPanel")
		Scroller:Dock(FILL)
		
		local DForm = Scroller:Add("DForm")
		DForm:Dock(FILL)
		DForm:SetName(ROTGB_LocalizeString("rotgb.spawnmenu.category.client.options"))
		PopulateClientDForm(DForm)
	end,"Opens the client ConVar configuration menu.")
end