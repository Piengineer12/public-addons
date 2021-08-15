GM.Name							= "RotgB: The Gamemode!"
GM.Author						= "Piengineer"
GM.Email						= "[REDACTED]"
GM.Website						= "https://steamcommunity.com/id/Piengineer12"
GM.TeamBased					= true
GM.SecondsBetweenTeamSwitches	= 0
GM.SpawnDelay					= 2
GM.NetSendInterval				= 0.2 -- this is also the scoreboard refresh rate, but if this is too low, messages might be sent to the client so fast that the client might crash!
GM.DatabaseFormatVersion		= 1
GM.DatabaseSaveInterval			= 60
GM.ModeCategories				= {Easy = 1, Medium = 2, Hard = 3}
GM.Modes						= {
	__common = {
		convars = {
			rotgb_regen_delay = true,
			rotgb_func_nav_expand = true,
			rotgb_max_to_exist = true,
			rotgb_ignore_damage_resistances = true,
			rotgb_damage_multiplier = true,
			rotgb_scale = true,
			rotgb_target_choice = true,
			rotgb_target_sort = true,
			rotgb_search_size = true,
			rotgb_target_tolerance = true,
			rotgb_cash_mul = true,
			rotgb_speed_mul = true,
			rotgb_health_multiplier = true,
			rotgb_blimp_health_multiplier = true,
			rotgb_pop_on_contact = true,
			rotgb_use_custom_pathfinding = true,
			rotgb_freeplay = true,
			rotgb_rainbow_gblimp_regen_rate = true,
			rotgb_afflicted_damage_multiplier = true,
			rotgb_tower_range_multiplier = true,
			rotgb_ignore_upgrade_limits = true,
			rotgb_fire_delay = true,
			rotgb_init_rate = true,
			rotgb_starting_cash = true,
			rotgb_tower_income_mul = true,
			rotgb_target_health_override = true,
			rotgb_default_first_wave = true,
			rotgb_tower_ignore_physgun = true,
			
			rotgb_difficulty = true,
			rotgb_default_wave_preset = true,
			rotgb_default_last_wave = true,
			rotgb_target_natural_health = true
		}
	},
	easy_regular = {
		name = "Regular",
		category = "Easy",
		place = 1,
		convars = {
			rotgb_difficulty = -1,
			rotgb_default_last_wave = 40,
			rotgb_target_natural_health = 200
		}
	},
	medium_regular = {
		name = "Regular",
		category = "Medium",
		place = 1,
		convars = {
			rotgb_difficulty = 0,
			rotgb_default_last_wave = 60,
			rotgb_target_natural_health = 150
		}
	},
	hard_regular = {
		name = "Regular",
		category = "Hard",
		place = 1,
		convars = {
			rotgb_difficulty = 1,
			rotgb_default_last_wave = 80,
			rotgb_target_natural_health = 100
		}
	},
	hard_insane = {
		name = "Insane",
		category = "Hard",
		place = 2,
		convars = {
			rotgb_difficulty = 2,
			rotgb_default_last_wave = 100,
			rotgb_target_natural_health = 50
		}
	},
	hard_impossible = {
		name = "Impossible",
		category = "Hard",
		place = 3,
		convars = {
			rotgb_difficulty = 3,
			rotgb_default_wave_preset = "",
			rotgb_default_last_wave = 120,
			rotgb_target_natural_health = 1
		}
	}
}

--[[
TO DO LIST:

sandbox saving
remove water on rotgb_test1
fix autostart on rotgb_heatwave
sfx for upgrading and placing
one click to buy as much as possible - low priority
fix spectator bugs
music?
gamemode: game options GUI
]]

ROTGB_STAT_POPS = 1
ROTGB_STAT_INITEXP = 2

RTG_OPERATION_KICK = 1
RTG_OPERATION_GAMEOVER = 2
RTG_OPERATION_SETDIFFICULTY = 3

AddCSLuaFile()
include("player_class/builder.lua")
include("player_class/hunter.lua")

function GM:PhysgunPickup(ply, ent)
	return ply:IsAdmin() and ent:GetClass()~="player" or ent.Base == "gballoon_tower_base"
end

function GM:CreateTeams()
	TEAM_BUILDER = 1
	team.SetUp(TEAM_BUILDER, "Builder", Color(255,255,0))
	team.SetClass(TEAM_BUILDER, "Builder")
	team.SetSpawnPoint(TEAM_BUILDER, "info_player_start")
	
	TEAM_HUNTER = 2
	team.SetUp(TEAM_HUNTER, "Hunter", Color(255,127,0))
	team.SetClass(TEAM_HUNTER, "Hunter")
	team.SetSpawnPoint(TEAM_HUNTER, "info_player_start")
	
	team.SetColor(TEAM_CONNECTING, Color(127,127,127))
	team.SetColor(TEAM_UNASSIGNED, Color(127,127,127))
	
	team.SetColor(TEAM_SPECTATOR, Color(191,191,191))
	team.SetSpawnPoint(TEAM_SPECTATOR, "info_player_start")
	
	TEAM_DESCRIPTIONS = {
		[TEAM_BUILDER] = {
			"You start with the RotgB Game Tool.",
			"Use the RotgB Game Tool to build towers that pop gBalloons.",
			"You are unable to pop gBalloons yourself."
		},
		[TEAM_HUNTER] = {
			"You start with the Balloon Shooter and $650 less than normal.",
			"You are unable to build towers.",
			"Use the Balloon Shooter to pop gBalloons."
		},
		[TEAM_SPECTATOR] = {
			"You start with nothing and don't gain cash.",
			"You are invisible and can freely roam around the map.",
			"Press the Primary Fire key to cycle forward between views. Most views disable free roaming.",
			"Press the Secondary Fire key to cycle backward.",
			"While spectating a player, press the Crouch key to toggle between first person mode and third person mode."
		}
	}
end

function GM:OnPlayerHitGround(ply, intoWater, onFloating, fallSpeed)
	-- players do not take fall damage
	return true
end

function GM:CanProperty(ply, property, ent)
	if property == "remover" then
		return ent.Base == "gballoon_tower_base"
	end
	return false
end

-- non-base

function GM:ShouldConVarOverride(cvar)
	return self.Modes.Difficulty and self.Modes.Difficulty.convars[cvar] or self.Modes.__common.convars[cvar]
end

local experienceNeeded = {
	1e3, 2.5e3, 5e3, 10e3, 20e3,
	40e3, 75e3, 150e3, 300e3, 600e3,
	1.25e6, 2.5e6, 4.5e6, 7.25e6, 10.75e6,
	15e6, 20e6
}
local function getExperienceNeeded(currentLevel)
	currentLevel = math.floor(currentLevel)
	if currentLevel < 1 then return 0
	elseif experienceNeeded[currentLevel] then return experienceNeeded[currentLevel]
	else
		local n = currentLevel-12
		return (n*n+n+10)*5e5
	end
end

local PLAYER = FindMetaTable("Player")
function PLAYER:ROTGB_GetLevel()
	if getExperienceNeeded(self.rotgb_Level or 1) <= self:ROTGB_GetExperience() then
		self:ROTGB_UpdateLevel()
	end
	return self.rotgb_Level or 1
end

function PLAYER:ROTGB_GetLevelFraction()
	return math.Remap(self:ROTGB_GetExperience(), getExperienceNeeded(self:ROTGB_GetLevel()-1), getExperienceNeeded(self:ROTGB_GetLevel()), 0, 1)
end

function PLAYER:ROTGB_GetExperience()
	-- experience is stored clientside, so it's impossible to completely prevent clients from modifying their experience value
	-- especially with open source code, might as well implement other features
	return math.floor((self.rotgb_PreviousPops or 0) + (self.rotgb_gBalloonPops or 0)) * 10
end

function PLAYER:ROTGB_GetExperienceNeeded()
	return getExperienceNeeded(self:ROTGB_GetLevel())
end

function PLAYER:ROTGB_UpdateLevel()
	while getExperienceNeeded(self.rotgb_Level or 1) <= self:ROTGB_GetExperience() do
		self.rotgb_Level = (self.rotgb_Level or 1) + 1
	end
end

function PLAYER:IsFirstPersonPlayerSpectating()
	return self.rotgb_PlayerFirstPersonView or false
end

function PLAYER:ToggleFirstPersonPlayerSpectating()
	self.rotgb_PlayerFirstPersonView = not self.rotgb_PlayerFirstPersonView
end