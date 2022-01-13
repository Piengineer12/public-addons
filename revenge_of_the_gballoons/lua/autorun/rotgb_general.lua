--[[
Workshop:		https://steamcommunity.com/sharedfiles/filedetails/?id=1616333917
Profile Page:	https://steamcommunity.com/id/Piengineer12
GitHub Page:	https://github.com/Piengineer12/public-addons/tree/master/revenge_of_the_gballoons
Donate:			https://ko-fi.com/piengineer12

Links above are confirmed working as of 2021-06-21. All dates are in ISO 8601 format.

Version:		5.0.0-alpha.4
]]

local DebugArgs = {"fire","damage","func_nav_detection","pathfinding","popping","regeneration","targeting","towers"}

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

ROTGB_OPERATION_BLACKLIST = 1
ROTGB_OPERATION_WAVE_TRANSFER = 2
ROTGB_OPERATION_TRANSFER = 3
ROTGB_OPERATION_ACHIEVEMENT = 4
ROTGB_OPERATION_WAVE_EDIT = 5
ROTGB_OPERATION_HEALTH_EDIT = 6
ROTGB_OPERATION_TRIGGER = 7
ROTGB_OPERATION_BOSS = 8

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
[[If set, all towers will be able to damage non-gBalloon entities.]])

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

RegisterConVar("rotgb_spawner_force_auto_start","0",R_BOOL,
[[Newly-spawned gBalloon Spawners will have Force Auto-Start enabled.]])

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

function ROTGB_UpdateCash(ply)
	if SERVER then
		net.Start("rotgb_cash", true)
		net.WriteUInt(ply and ply:UserID() or 0, 16)
		net.WriteDouble(ROTGB_GetCash(ply))
		net.Broadcast()
	end
end

function ROTGB_SetCash(num,ply)
	if ROTGB_GetConVarValue("rotgb_individualcash") then
		if ply then
			ply.ROTGB_CASH = tonumber(num) or 0
			ROTGB_UpdateCash(ply)
		else
			for k,v in pairs(player.GetAll()) do
				v.ROTGB_CASH = tonumber(num) or 0
				ROTGB_UpdateCash(v)
			end
		end
	else
		ROTGB_CASH = tonumber(num) or 0
		ROTGB_UpdateCash()
	end
end

function ROTGB_GetCash(ply)
	if ROTGB_GetConVarValue("rotgb_individualcash") then
		ply = ply or CLIENT and LocalPlayer()
		if ply then return ply.ROTGB_CASH or 0
		else
			local average = 0
			for k,v in pairs(player.GetAll()) do
				average = average + (v.ROTGB_CASH or 0)
			end
			return average
		end
	else
		return ROTGB_CASH or 0
	end
end

function ROTGB_AddCash(num,ply)
	num = tonumber(num) or 0
	if ROTGB_GetConVarValue("rotgb_individualcash") then
		if ply then
			ROTGB_SetCash(ROTGB_GetCash(ply)+num,ply)
		else
			local count = player.GetCount()
			for k,v in pairs(player.GetAll()) do
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
		if ply then
			ROTGB_SetCash(ROTGB_GetCash(ply)-num,ply)
		else
			local count = player.GetCount()
			for k,v in pairs(player.GetAll()) do
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
	local newAmount = hook.Run("RotgBScaleBuyCost", num, ent, data)
	if newAmount then
		return newAmount
	else
		return num * (1 + (ROTGB_GetConVarValue("rotgb_difficulty") - 1)/5)
	end
end

if SERVER then
	util.AddNetworkString("rotgb_cash")
	
	local ticktime2 = 0
	local nextCashThink = 5
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
	 - Opens the blacklist editor.]])

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
			if (IsValid(tower) and tower.Base == "gballoon_tower_base") then
				tower:DoAbility()
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
				ROTGB_CASH = hook.Run("GetStartingRotgBCash") or ROTGB_GetConVarValue("rotgb_starting_cash")
				ROTGB_UpdateCash()
			end
			for k,v in pairs(player.GetAll()) do
				if not v.ROTGB_cashLoaded then
					v.ROTGB_cashLoaded = true
					v.ROTGB_CASH = hook.Run("GetStartingRotgBCash") or ROTGB_GetConVarValue("rotgb_starting_cash")
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



if CLIENT then
	ROTGB_CLIENTWAVES = ROTGB_CLIENTWAVES or {}
	
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
	[[Disable all halo effects, including the turquoise halo around purple gBalloons.
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
	
	function ROTGB_FormatCash(cash, roundUp)
		if cash==math.huge then -- number is inf
			return "$∞"
		elseif cash==-math.huge then -- number is negative inf
			return "$-∞"
		elseif cash<math.huge and cash>-math.huge then -- number is real
			if cash>-1e12 and cash<1e12 then
				return "$"..string.Comma((roundUp and math.ceil or math.floor)(cash))
			else
				return string.format("$%.6E", cash)
			end
		else -- number isn't a number. Caused by inf minus inf
			return "$?"
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
	
	local function CreateGBFont(fontsize)
		surface.CreateFont("RotgB_font",{
			font="Luckiest Guy",
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
		local id = net.ReadUInt(16)
		local amt = net.ReadDouble()
		if id==0 then
			ROTGB_CASH = amt
		elseif IsValid(Player(id)) then
			Player(id).ROTGB_CASH = amt
		end
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
				displayName = npcTable.Name
				if bit.band(flags,32)==32 then
					displayName = "Shielded "..displayName
				end
				if bit.band(flags,16)==16 then
					displayName = "Regen "..displayName
				end
				if bit.band(flags,8)==8 then
					displayName = "Hidden "..displayName
				end
				if bit.band(flags,4)==4 then
					displayName = "Fast "..displayName
				end
				local h,s,v = ColorToHSV(string.ToColor(npcTable.KeyValues.BalloonColor))
				if s == 1 then v = 1 end
				s = s / 2
				v = (v + 1) / 2
				color = HSVToColor(h,s,v)
			else
				displayName = language.GetPhrase(attackerLabel)
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
			local realTime = RealTime()
			local spawners = FilterSequentialTable(ents.GetAll(), TableFilterSpawners)
			table.sort(spawners, SpawnerSorter)
			for k,v in pairs(spawners) do
				spawners[k] = string.Comma(v:GetWave()-1).." / "..string.Comma(v:GetLastWave())
			end
			
			local targets = FilterSequentialTable(ents.GetAll(), TableFilterWaypoints)
			table.sort(targets, WaypointSorter)
			
			local size = ROTGB_GetConVarValue("rotgb_hud_size")
			if oldSize ~= size then
				oldSize = size
				generateCooldown = realTime + 1
			end
			if generateCooldown < realTime and generateCooldown >= 0 then
				generateCooldown = -1
				CreateGBFont(size)
			end
			local xPos = ROTGB_GetConVarValue("rotgb_hud_x")*ScrW()
			local yPos = ROTGB_GetConVarValue("rotgb_hud_y")*ScrH()
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
					tX = tX + draw.SimpleTextOutlined(string.Comma(v:Health()).." ","RotgB_font",tX,tY,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
					if v:GetOSPs() > 0 then
						tX = tX + draw.SimpleTextOutlined("+ "..string.Comma(v:GetOSPs()).."* ","RotgB_font",tX,tY,color_magenta,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
					end
					if v:GetGoldenHealth() > 0 then
						tX = tX + draw.SimpleTextOutlined("+ "..string.Comma(v:GetGoldenHealth()).." ","RotgB_font",tX,tY,color_yellow,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
					end
					if v:GetPerWaveShield() > 0 then
						tX = tX + draw.SimpleTextOutlined("+ "..string.Comma(v:GetPerWaveShield()).." ","RotgB_font",tX,tY,color_aqua,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
					end
					tX = tX + draw.SimpleTextOutlined("/ "..string.Comma(v:GetMaxHealth()),"RotgB_font",tX,tY,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
					if i < #targets then
						draw.SimpleTextOutlined(" + ","RotgB_font",tX,tY,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
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
			
			local hurtFeedKeyless = table.ClearKeys(hurtFeed, true)
			table.sort(hurtFeedKeyless, function(a,b)
				return a.damage > b.damage
			end)
			
			local textOffset = size*3
			for i,v in ipairs(hurtFeedKeyless) do
				local attributed = v.isBalloon and v.instances > 1 and string.format("%ux %s", v.instances, v.__key) or v.__key
				local textPart1 = "Took "..string.Comma(v.damage).." damage from "
				if v.damage < 0 then
					textPart1 = "Healed "..string.Comma(-v.damage).." health from "
				end
				local textPart2 = "!"
				local alpha = math.Remap(realTime, v.timestamp, v.timestamp+hurtFeedStaySeconds, 512, 0)
				local fgColor = Color(255, 255, 255, math.min(alpha, 255))
				local fgColor2 = v.color or fgColor
				fgColor2 = Color(fgColor2.r, fgColor2.g, fgColor2.b, math.min(alpha, 255))
				local bgColor = Color(0, 0, 0, math.min(alpha, 255))
				local offsetX = draw.SimpleTextOutlined(textPart1, "Trebuchet24", textX, yPos+textOffset, fgColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, bgColor)
				offsetX = offsetX + draw.SimpleTextOutlined(attributed, "Trebuchet24", textX+offsetX, yPos+textOffset, fgColor2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, bgColor)
				draw.SimpleTextOutlined(textPart2, "Trebuchet24", textX+offsetX, yPos+textOffset, fgColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, bgColor)
				textOffset = textOffset + 24
			end
			
			if (bossData.lastUpdateTime or -4) + 3 > RealTime() then
				if not bossData.title then
					local npcTable = list.GetForEdit("NPC")[bossData.type]
					local displayName = npcTable.Name
					if bit.band(bossData.flags,8)==8 then
						displayName = "Shielded "..displayName
					end
					if bit.band(bossData.flags,4)==4 then
						displayName = "Regen "..displayName
					end
					if bit.band(bossData.flags,2)==2 then
						displayName = "Hidden "..displayName
					end
					if bit.band(bossData.flags,1)==1 then
						displayName = "Fast "..displayName
					end
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
				local barW = ScrW() / 3
				local barH = BOSS_FONT_HEIGHT
				local barX = (ScrW() - barW) / 2
				local barY = BOSS_FONT_HEIGHT * 2 + padding
				
				local healthBarsP = math.floor(BOSS_FONT_HEIGHT / 8)
				local healthBarsPW = BOSS_FONT_HEIGHT
				local healthBarsW = healthBarsPW - healthBarsP * 2
				local healthBarsX = barX + barW
				local healthBarsY = barY + barH
				
				local backgroundW = barW + padding * 2
				local backgroundH = BOSS_FONT_HEIGHT + barH + healthBarsPW + padding * 2
				local backgroundX = (ScrW() - backgroundW) / 2
				local backgroundY = BOSS_FONT_HEIGHT
				local backgroundC = color_black_semiopaque
				
				-- TODO: health bars indicator
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
				draw.SimpleText(bossData.title, "RotgBBossFont", ScrW()/2, backgroundY+padding, bossData.color, TEXT_ALIGN_CENTER)
				
				local previousSegmentColorsAmount = #bossData.previousHealthSegmentColors
				local previousSegmentColor = bossData.previousHealthSegmentColors[previousSegmentColorsAmount] or color_black_semiopaque
				surface.SetDrawColor(previousSegmentColor.r, previousSegmentColor.g, previousSegmentColor.b, previousSegmentColor.a)
				surface.DrawRect(barX, barY, barW, barH)
				
				surface.SetDrawColor(255,255,255)
				surface.DrawRect(barX, barY, barW*bossData.oldBufferHealthPercent, barH)
				
				local segmentColor = bossData.currentHealthSegmentColor
				surface.SetDrawColor(segmentColor.r, segmentColor.g, segmentColor.b, segmentColor.a)
				surface.DrawRect(barX, barY, barW*bossData.oldHealthPercent, barH)
				
				draw.SimpleText(string.format("%s / %s", string.Comma(bossData.health), string.Comma(bossData.maxHealth)), "RotgBBossFont", barX, barY+barH, color_white)
				
				if currentHealthSegment > 20 then
					local localX = healthBarsX - healthBarsPW + healthBarsP
					local localY = healthBarsY + healthBarsP
					
					surface.SetDrawColor(previousSegmentColor.r,previousSegmentColor.g,previousSegmentColor.b)
					surface.DrawRect(localX, localY, healthBarsW, healthBarsW)
					
					draw.SimpleText("x "..string.Comma(currentHealthSegment-1), "RotgBBossFont", localX - healthBarsP, localY + healthBarsW / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
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
		end
	end)

	hook.Add("AddToolMenuTabs","RotgB",function()
		spawnmenu.AddToolTab("RotgB")
	end)

	hook.Add("AddToolMenuCategories","RotgB",function()
		spawnmenu.AddToolCategory("RotgB","Client","Client")
		spawnmenu.AddToolCategory("RotgB","Server","Server")
	end)

	hook.Add("PopulateToolMenu","RotgB",function()
		spawnmenu.AddToolMenuOption("RotgB","Server","RotgB_Server1","Cash","","",function(DForm)
			DForm:TextEntry("Cash Value","rotgb_cash_param")
			DForm:Help(" - "..GetConVar("rotgb_cash_param"):GetHelpText().."\n")
			DForm:Button("Set Cash","rotgb_setcash","*")
			DForm:Button("Add Cash","rotgb_addcash","*")
			DForm:Button("Subtract Cash","rotgb_subcash","*")
			DForm:Help("Preset Values:")
			DForm:Button("Set Value to 0","rotgb_cash_param_internal","0")
			DForm:Button("Set Value to 650","rotgb_cash_param_internal","650")
			DForm:Button("Set Value to 850","rotgb_cash_param_internal","850")
			DForm:Button("Set Value to 20000","rotgb_cash_param_internal","20000")
			DForm:Button("Set Value to ∞","rotgb_cash_param_internal","0x1p128")
			DForm:Help("You can use the ConCommmands rotgb_setcash, rotgb_addcash and rotgb_subcash to modify the cash value.\n")
			DForm:NumSlider("Cash Multiplier","rotgb_cash_mul",0,10,3)
			DForm:Help(" - "..GetConVar("rotgb_cash_mul"):GetHelpText().."\n")
			DForm:CheckBox("Split Cash Between Players","rotgb_individualcash")
			DForm:Help(" - "..GetConVar("rotgb_individualcash"):GetHelpText().."\n")
			DForm:NumSlider("Starting Cash","rotgb_starting_cash",0,1000,0)
			DForm:Help(" - "..GetConVar("rotgb_starting_cash"):GetHelpText().."\n")
		end)
		spawnmenu.AddToolMenuOption("RotgB","Server","RotgB_Server2","gBalloons","","",function(DForm)
			DForm:NumSlider("Fire Damage Delay","rotgb_fire_delay",0,10,3)
			DForm:Help(" - "..GetConVar("rotgb_fire_delay"):GetHelpText().."\n")
			DForm:NumSlider("Regen Delay","rotgb_regen_delay",0,10,3)
			DForm:Help(" - "..GetConVar("rotgb_regen_delay"):GetHelpText().."\n")
			DForm:NumSlider("Rainbow Rate","rotgb_rainbow_gblimp_regen_rate",0,10,3)
			DForm:Help(" - "..GetConVar("rotgb_rainbow_gblimp_regen_rate"):GetHelpText().."\n")
			DForm:NumSlider("gBalloon Scale","rotgb_scale",0,10,3)
			DForm:Help(" - "..GetConVar("rotgb_scale"):GetHelpText().."\n")
			DForm:NumSlider("Speed Multiplier","rotgb_speed_mul",0,10,3)
			DForm:Help(" - "..GetConVar("rotgb_speed_mul"):GetHelpText().."\n")
			DForm:NumSlider("Health Multiplier","rotgb_health_multiplier",0,10,3)
			DForm:Help(" - "..GetConVar("rotgb_health_multiplier"):GetHelpText().."\n")
			DForm:NumSlider("Blimp Health Multiplier","rotgb_blimp_health_multiplier",0,10,3)
			DForm:Help(" - "..GetConVar("rotgb_blimp_health_multiplier"):GetHelpText().."\n")
			DForm:NumSlider("Aff. Damage Multiplier","rotgb_afflicted_damage_multiplier",0,10,3)
			DForm:Help(" - "..GetConVar("rotgb_afflicted_damage_multiplier"):GetHelpText().."\n")
			DForm:CheckBox("Ignore Damage Resistances","rotgb_ignore_damage_resistances")
			DForm:Help(" - "..GetConVar("rotgb_ignore_damage_resistances"):GetHelpText().."\n")
			DForm:CheckBox("Trigger On Kill Effects","rotgb_use_kill_handler")
			DForm:Help(" - "..GetConVar("rotgb_use_kill_handler"):GetHelpText().."\n")
			DForm:CheckBox("Trigger Achievements","rotgb_use_achievement_handler")
			DForm:Help(" - "..GetConVar("rotgb_use_achievement_handler"):GetHelpText().."\n")
			DForm:CheckBox("Use Legacy Models","rotgb_legacy_gballoons")
			DForm:Help(" - "..GetConVar("rotgb_legacy_gballoons"):GetHelpText().."\n")
			DForm:CheckBox("Pertain New Model Effects","rotgb_pertain_effects")
			DForm:Help(" - "..GetConVar("rotgb_pertain_effects"):GetHelpText().."\n")
			DForm:NumSlider("Blood Effect","rotgb_bloodtype",-1,16,0)
			DForm:Help(" - "..GetConVar("rotgb_bloodtype"):GetHelpText().."\n")
			DForm:TextEntry("Blood Decal","rotgb_blooddecal")
			DForm:Help(" - "..GetConVar("rotgb_blooddecal"):GetHelpText().."\n")
			DForm:Button("Blacklist Editor (Admin Only)","rotgb_blacklist")
		end)
		spawnmenu.AddToolMenuOption("RotgB","Server","RotgB_Server3","gBalloon Spawners + Targets","","",function(DForm)
			DForm:TextEntry("Health Value","rotgb_health_param")
			DForm:Help(" - "..GetConVar("rotgb_health_param"):GetHelpText().."\n")
			DForm:Button("Set Health","rotgb_sethealth","*")
			DForm:Button("Heal Health","rotgb_healhealth","*")
			DForm:Button("Add Health","rotgb_addhealth","*")
			DForm:Button("Subtract Health","rotgb_subhealth","*")
			DForm:Button("Set Max Health","rotgb_setmaxhealth","*")
			DForm:Button("Add Max Health","rotgb_addmaxhealth","*")
			DForm:Button("Subtract Max Health","rotgb_submaxhealth","*")
			DForm:Help("Preset Values:")
			DForm:Button("Set Health to 1","rotgb_health_param_internal","0")
			DForm:Button("Set Health to 100","rotgb_health_param_internal","100")
			DForm:Button("Set Health to 150","rotgb_health_param_internal","150")
			DForm:Button("Set Health to 200","rotgb_health_param_internal","200")
			DForm:Button("Set Health to 999,999,999","rotgb_health_param_internal","999999999")
			DForm:Help("You can use the ConCommmands rotgb_sethealth, rotgb_healhealth, rotgb_addhealth and rotgb_subhealth to modify the health of all gBalloon Targets, as well as rotgb_setmaxhealth, rotgb_addmaxhealth and rotgb_submaxhealth to modify the maximum health.\n")
			
			DForm:NumSlider("Default First Wave","rotgb_default_first_wave",1,1000,0)
			DForm:Help(" - "..GetConVar("rotgb_default_first_wave"):GetHelpText().."\n")
			DForm:NumSlider("Default Last Wave","rotgb_default_last_wave",1,1000,0)
			DForm:Help(" - "..GetConVar("rotgb_default_last_wave"):GetHelpText().."\n")
			DForm:CheckBox("Force Auto-Start","rotgb_spawner_force_auto_start")
			DForm:Help(" - "..GetConVar("rotgb_spawner_force_auto_start"):GetHelpText().."\n")
			DForm:CheckBox("Enable Freeplay","rotgb_freeplay")
			DForm:Help(" - "..GetConVar("rotgb_freeplay"):GetHelpText().."\n")
			DForm:TextEntry("Default Wave Preset","rotgb_default_wave_preset")
			DForm:Help(" - "..GetConVar("rotgb_default_wave_preset"):GetHelpText().."\n")
			DForm:NumSlider("Target Health Override","rotgb_target_health_override",0,1000,0)
			DForm:Help(" - "..GetConVar("rotgb_target_health_override"):GetHelpText().."\n")
			DForm:Button("Wave Editor","rotgb_waveeditor")
		end)
		spawnmenu.AddToolMenuOption("RotgB","Server","RotgB_Server4","AI","","",function(DForm)
			DForm:CheckBox("Custom Pathfinding","rotgb_use_custom_pathfinding")
			DForm:Help(" - "..GetConVar("rotgb_use_custom_pathfinding"):GetHelpText().."\n")
			--[[DForm:CheckBox("Custom AI","rotgb_use_custom_ai")
			DForm:Help(" - "..GetConVar("rotgb_use_custom_ai"):GetHelpText().."\n")]]
			DForm:NumSlider("Targets","rotgb_target_choice",-1,511,0)
			DForm:Help(" - "..GetConVar("rotgb_target_choice"):GetHelpText().."\n")
			DForm:NumberWang("Target Sorting","rotgb_target_sort",-1,3)
			DForm:Help(" - "..GetConVar("rotgb_target_sort"):GetHelpText().."\n")
			DForm:NumSlider("Search Size","rotgb_search_size",-1,2048,0)
			DForm:Help(" - "..GetConVar("rotgb_search_size"):GetHelpText().."\n")
			DForm:NumSlider("Tolerance","rotgb_target_tolerance",0,1000,1)
			DForm:Help(" - "..GetConVar("rotgb_target_tolerance"):GetHelpText().."\n")
			DForm:NumSlider("Pop On Contact","rotgb_pop_on_contact",-2,511,0)
			DForm:Help(" - "..GetConVar("rotgb_pop_on_contact"):GetHelpText().."\n")
			DForm:NumSlider("MinLookAheadDistance","rotgb_setminlookaheaddistance",0,1000,1)
			DForm:Help(" - "..GetConVar("rotgb_setminlookaheaddistance"):GetHelpText().."\n")
			DForm:NumSlider("func_nav_* Tolerance","rotgb_func_nav_expand",0,100,2)
			DForm:Help(" - "..GetConVar("rotgb_func_nav_expand"):GetHelpText().."\n")
		end)
		spawnmenu.AddToolMenuOption("RotgB","Server","RotgB_Server5","Towers","","",function(DForm)
			DForm:TextEntry("Tower Blacklist","rotgb_tower_blacklist")
			DForm:Help(" - "..GetConVar("rotgb_tower_blacklist"):GetHelpText().."\n")
			DForm:NumberWang("Chess Only","rotgb_tower_chess_only",-1,1)
			DForm:Help(" - "..GetConVar("rotgb_tower_chess_only"):GetHelpText().."\n")
			DForm:CheckBox("Hurt Non-gBalloons","rotgb_tower_damage_others")
			DForm:Help(" - "..GetConVar("rotgb_tower_damage_others"):GetHelpText().."\n")
			DForm:CheckBox("Ignore Upgrade Limits","rotgb_ignore_upgrade_limits")
			DForm:Help(" - "..GetConVar("rotgb_ignore_upgrade_limits"):GetHelpText().."\n")
			DForm:CheckBox("Ignore Physics Gun","rotgb_tower_ignore_physgun")
			DForm:Help(" - "..GetConVar("rotgb_tower_ignore_physgun"):GetHelpText().."\n")
			DForm:NumSlider("Difficulty","rotgb_difficulty",0,3,0)
			DForm:Help(" - "..GetConVar("rotgb_difficulty"):GetHelpText().."\n")
			DForm:NumSlider("Damage Multiplier","rotgb_damage_multiplier",0,10,3)
			DForm:Help(" - "..GetConVar("rotgb_damage_multiplier"):GetHelpText().."\n")
			DForm:NumSlider("Range Multiplier","rotgb_tower_range_multiplier",0,10,3)
			DForm:Help(" - "..GetConVar("rotgb_tower_range_multiplier"):GetHelpText().."\n")
			DForm:NumSlider("Income Multiplier","rotgb_tower_income_mul",0,10,3)
			DForm:Help(" - "..GetConVar("rotgb_tower_income_mul"):GetHelpText().."\n")
		end)
		spawnmenu.AddToolMenuOption("RotgB","Server","RotgB_Server6","Optimization","","",function(DForm)
			DForm:CheckBox("No gBalloon Trails","rotgb_notrails")
			DForm:Help(" - "..GetConVar("rotgb_notrails"):GetHelpText().."\n")
			DForm:NumSlider("Max gBalloons","rotgb_max_to_exist",0,1024,0)
			DForm:Help(" - "..GetConVar("rotgb_max_to_exist"):GetHelpText().."\n")
			DForm:NumSlider("Max Pop Effects/Second","rotgb_max_effects_per_second",0,100,2)
			DForm:Help(" - "..GetConVar("rotgb_max_effects_per_second"):GetHelpText().."\n")
			DForm:NumSlider("Resist Effect Delay","rotgb_resist_effect_delay",-1,10,3)
			DForm:Help(" - "..GetConVar("rotgb_resist_effect_delay"):GetHelpText().."\n")
			DForm:NumSlider("Critical Effect Delay","rotgb_crit_effect_delay",-1,10,3)
			DForm:Help(" - "..GetConVar("rotgb_crit_effect_delay"):GetHelpText().."\n")
			DForm:NumSlider("Path Computation Delay","rotgb_path_delay",0,100,2)
			DForm:Help(" - "..GetConVar("rotgb_path_delay"):GetHelpText().."\n")
			DForm:NumSlider("Max Towers","rotgb_tower_maxcount",-1,64,0)
			DForm:Help(" - "..GetConVar("rotgb_tower_maxcount"):GetHelpText().."\n")
			DForm:NumSlider("Initialization Rate","rotgb_init_rate",-1,100,2)
			DForm:Help(" - "..GetConVar("rotgb_init_rate"):GetHelpText().."\n")
		end)
		spawnmenu.AddToolMenuOption("RotgB","Server","RotgB_Server7","Miscellaneous","","",function(DForm)
			DForm:NumSlider("gBalloon Visual Scale","rotgb_visual_scale",0,10,3)
			DForm:Help(" - "..GetConVar("rotgb_visual_scale"):GetHelpText().."\n")
			DForm:ControlHelp("Addon not working as intended?")
			local dangerbutton = DForm:Button("Set All ConVars To Default","rotgb_reset_convars")
			dangerbutton:SetTextColor(Color(255,0,0))
			local DTextEntry = DForm:TextEntry("Debug Parameters","rotgb_debug")
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
			DForm:Help(" - "..GetConVar("rotgb_debug"):GetHelpText().."\n")
		end)
		spawnmenu.AddToolMenuOption("RotgB","Client","RotgB_Client","Options","","",function(DForm)
			DForm:Help("") --whitespace
			DForm:ControlHelp("Cash Display")
			DForm:CheckBox("Enable HUD Display","rotgb_hud_enabled")
			DForm:Help(" - "..GetConVar("rotgb_hud_enabled"):GetHelpText().."\n")
			DForm:NumSlider("X-Position","rotgb_hud_x",0,1,3)
			DForm:Help(" - "..GetConVar("rotgb_hud_x"):GetHelpText().."\n")
			DForm:NumSlider("Y-Position","rotgb_hud_y",0,1,3)
			DForm:Help(" - "..GetConVar("rotgb_hud_y"):GetHelpText().."\n")
			DForm:NumSlider("HUD Size","rotgb_hud_size",0,128,0)
			DForm:Help(" - "..GetConVar("rotgb_hud_size"):GetHelpText().."\n")
			DForm:Help("") --whitespace
			DForm:ControlHelp("Tower Ranges")
			DForm:CheckBox("Show Tower Ranges","rotgb_range_enable_indicators")
			DForm:Help(" - "..GetConVar("rotgb_range_enable_indicators"):GetHelpText().."\n")
			DForm:NumSlider("Hold Time","rotgb_range_hold_time",0,10,3)
			DForm:Help(" - "..GetConVar("rotgb_range_hold_time"):GetHelpText().."\n")
			DForm:NumSlider("Fade Time","rotgb_range_fade_time",0,10,3)
			DForm:Help(" - "..GetConVar("rotgb_range_fade_time"):GetHelpText().."\n")
			DForm:NumSlider("Visibility","rotgb_range_alpha",0,255,0)
			DForm:Help(" - "..GetConVar("rotgb_range_alpha"):GetHelpText().."\n")
			DForm:Help("") --whitespace
			DForm:ControlHelp("Other")
			DForm:NumSlider("Circle Side Count","rotgb_circle_segments",3,200,0)
			DForm:Help(" - "..GetConVar("rotgb_circle_segments"):GetHelpText().."\n")
			DForm:NumSlider("Text Hover Distance","rotgb_hoverover_distance",0,100,1)
			DForm:Help(" - "..GetConVar("rotgb_hoverover_distance"):GetHelpText().."\n")
			DForm:CheckBox("Enable Freeze Effect","rotgb_freeze_effect")
			DForm:Help(" - "..GetConVar("rotgb_freeze_effect"):GetHelpText().."\n")
			DForm:CheckBox("Disable Halo Effects","rotgb_no_glow")
			DForm:Help(" - "..GetConVar("rotgb_no_glow"):GetHelpText().."\n")
		end)
		--[[spawnmenu.AddToolMenuOption("Options","RotgB","RotgB_Bestiary","Bestiary","","",function(DForm) -- Add panel
			local CategoryList = vgui.Create("DCategoryList",DForm)
			for i,v in ipairs(order) do
				AddBalloon(CategoryList,v)
			end
			CategoryList:SetHeight(768)
			CategoryList:Dock(FILL)
			DForm:AddItem(CategoryList)
		end)]]
		spawnmenu.AddToolMenuOption("Options","RotgB","RotgB_NavEditorTool","#tool.nav_editor_rotgb.name",game.SinglePlayer() and "gmod_tool nav_editor_rotgb" or "","",function(form)
			if game.SinglePlayer() then
				form:Help("#tool.nav_editor_rotgb.desc")
				local label = form:Help("This tool is only available in single player.")
				label:SetTextColor(Color(255,0,0))
				form:ControlHelp("NOTE: You can also mark the area to be avoided using the Easy Navmesh Editor by adding the AVOID attribute.")
				form:Button("Equip the Easy Navmesh Editor (if available)","gmod_tool","rb655_easy_navedit")
				local Button = form:Button("Get The Easy Navmesh Editor On Workshop")
				Button.DoClick = function() gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=527885257") end
			else
				local label = form:Help("This tool is only available in single player.")
				label:SetTextColor(Color(255,0,0))
			end
		end)
		spawnmenu.AddToolMenuOption("Options","RotgB","RotgB_WaypointEditorTool","#tool.waypoint_editor_rotgb.name","gmod_tool waypoint_editor_rotgb","",function(form)
			form:Help("#tool.waypoint_editor_rotgb.desc")
			form:CheckBox("Teleport Instantly","waypoint_editor_rotgb_teleport")
			form:NumSlider("Weight","waypoint_editor_rotgb_weight",0,100,0)
			form:Help("gBalloon Targets with higher weights are targeted first if the gBalloons do not have a target.")
			form:Help("If weighted targets are linked up, gBalloons are divided among the targets based on their weights.")
			form:Help("If all linked targets have a weight of 0, gBalloons will randomly pick one of the targets.")
			form:CheckBox("Always Show Paths","waypoint_editor_rotgb_indicator_always")
			local choicelist = form:ComboBox("Path Sprite","waypoint_editor_rotgb_indicator_effect")
			choicelist:SetSortItems(false)
			choicelist:AddChoice("Glow","sprites/glow04_noz")
			choicelist:AddChoice("Glow 2","sprites/light_ignorez")
			choicelist:AddChoice("PhysGun Glow","sprites/physg_glow1")
			choicelist:AddChoice("PhysGun Glow 2","sprites/physg_glow2")
			choicelist:AddChoice("Comic Balls","sprites/sent_ball")
			choicelist:AddChoice("Rings","effects/select_ring")
			choicelist:AddChoice("Crosses","effects/select_dot")
			choicelist:AddChoice("Circled Crosses","gui/close_32")
			choicelist:AddChoice("Circled Crosses 2","icon16/circlecross.png")
			choicelist:AddChoice("Cogs","gui/progress_cog.png")
			form:NumSlider("Sprite Scale","waypoint_editor_rotgb_indicator_scale",0,10)
			form:NumSlider("Sprite Speed","waypoint_editor_rotgb_indicator_speed",0.1,10)
			form:CheckBox("Target-to-Target Sprite Bounce","waypoint_editor_rotgb_indicator_bounce")
			choicelist = form:ComboBox("Path Colour","waypoint_editor_rotgb_indicator_color")
			choicelist:AddChoice("Rainbow",0)
			choicelist:AddChoice("Rainbow (Fade In Out)",1)
			choicelist:AddChoice("Rainbow (Fade Middle)",2)
			choicelist:AddChoice("Solid",3)
			choicelist:AddChoice("Solid (Fade In Out)",4)
			choicelist:AddChoice("Solid (Fade Middle)",5)
			choicelist:AddChoice("Rainbow, Solid for Blimps",6)
			choicelist:AddChoice("Rainbow, Solid for Blimps (Fade In Out)",7)
			choicelist:AddChoice("Rainbow, Solid for Blimps (Fade Middle)",8)
			choicelist:AddChoice("Solid, Rainbow for Blimps",9)
			choicelist:AddChoice("Solid, Rainbow for Blimps (Fade In Out)",10)
			choicelist:AddChoice("Solid, Rainbow for Blimps (Fade Middle)",11)
			local mixer = vgui.Create("DColorMixer")
			mixer:SetLabel("Solid Colour")
			mixer:SetConVarR("waypoint_editor_rotgb_indicator_r")
			mixer:SetConVarG("waypoint_editor_rotgb_indicator_g")
			mixer:SetConVarB("waypoint_editor_rotgb_indicator_b")
			mixer:SetConVarA("waypoint_editor_rotgb_indicator_a")
			form:AddItem(mixer)
			mixer = vgui.Create("DColorMixer")
			mixer:SetLabel("Solid Colour for Blimps")
			mixer:SetConVarR("waypoint_editor_rotgb_indicator_boss_r")
			mixer:SetConVarG("waypoint_editor_rotgb_indicator_boss_g")
			mixer:SetConVarB("waypoint_editor_rotgb_indicator_boss_b")
			mixer:SetConVarA("waypoint_editor_rotgb_indicator_boss_a")
			form:AddItem(mixer)
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
		elseif operation == ROTGB_OPERATION_ACHIEVEMENT then
			for i=1, net.ReadUInt(32) do
				achievements.BalloonPopped()
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
		end
	end)
	
	local drawNoBuilds = false
	function ROTGB_SetDrawNoBuilds(value)
		drawNoBuilds = value
	end
	
	local nextUpdate = nil
	hook.Add("PreDrawTranslucentRenderables", "RotgB", function(depth, skybox, skybox3d)
		if (nextUpdate or 0) < RealTime() then
			nextUpdate = RealTime() + 0.5
			for k,v in pairs(ents.FindByClass("func_rotgb_nobuild")) do
				v:SetNoDraw(not drawNoBuilds)
			end
		end
	end)
end