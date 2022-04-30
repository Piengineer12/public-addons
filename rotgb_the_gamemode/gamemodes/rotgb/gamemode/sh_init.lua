GM.Name							= "RotgB: The Gamemode!"
GM.Author						= "Piengineer12"
GM.Version						= "1.5.0"
GM.VersionDate					= "2022-04-23"
GM.Email						= "[REDACTED]"
GM.Website						= "https://steamcommunity.com/id/Piengineer12"
GM.TeamBased					= true
GM.SecondsBetweenTeamSwitches	= 1
GM.SpawnDelay					= 2
GM.NetSendInterval				= 0.2 -- this is also the scoreboard refresh rate, but if this is too low, messages might be sent to the client so fast that the client might crash!
GM.NetFullUpdateInterval		= 15
GM.DatabaseFormatVersion		= 1
GM.DatabaseSaveInterval			= 30
GM.VoteTime						= 15
GM.DebugMode					= false
GM.ModeCategories				= {easy = 1, medium = 2, hard = 3, insane = 4, impossible = 5}
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
			rotgb_spawner_force_auto_start = true,
			rotgb_spawner_no_multi_start = 1,
			rotgb_individualcash = 1,
			rotgb_tower_force_charge = true,
			rotgb_tower_charge_rate = true,
			
			rotgb_difficulty = true,
			rotgb_default_wave_preset = true,
			rotgb_default_last_wave = true,
			rotgb_target_natural_health = true
		}
	},
	easy_regular = {
		category = "easy",
		place = 1,
		xpmul = 1,
		convars = {
			rotgb_difficulty = 0,
			rotgb_default_last_wave = 40,
			rotgb_target_natural_health = 200
		}
	},
	easy_chessonly = {
		category = "easy",
		place = 2,
		xpmul = 1.2,
		convars = {
			rotgb_difficulty = 0,
			rotgb_default_last_wave = 40,
			rotgb_target_natural_health = 200,
			rotgb_tower_chess_only = 1
		}
	},
	easy_halfcash = {
		category = "easy",
		place = 3,
		xpmul = 2,
		convars = {
			rotgb_difficulty = 0,
			rotgb_default_last_wave = 40,
			rotgb_target_natural_health = 200,
			rotgb_starting_cash = 325,
			rotgb_cash_mul = 0.5
		}
	},
	medium_regular = {
		category = "medium",
		place = 1,
		xpmul = 0.5,
		convars = {
			rotgb_difficulty = 1,
			rotgb_default_last_wave = 60,
			rotgb_target_natural_health = 150
		}
	},
	medium_rainstorm = {
		category = "medium",
		place = 2,
		xpmul = 0.6,
		convars = {
			rotgb_difficulty = 1,
			rotgb_default_last_wave = 60,
			rotgb_target_natural_health = 150,
			rotgb_spawner_force_auto_start = 1,
		}
	},
	medium_strategic = {
		category = "medium",
		place = 3,
		xpmul = 0.7,
		convars = {
			rotgb_difficulty = 1,
			rotgb_default_first_wave = 51,
			rotgb_default_last_wave = 60,
			rotgb_target_natural_health = 150,
			rotgb_starting_cash = 20000,
			rotgb_cash_mul = 0,
		}
	},
	hard_regular = {
		category = "hard",
		place = 1,
		xpmul = 0.25,
		convars = {
			rotgb_difficulty = 2,
			rotgb_default_last_wave = 80,
			rotgb_target_natural_health = 100
		}
	},
	hard_doublehpblimps = {
		category = "hard",
		place = 2,
		xpmul = 0.3,
		convars = {
			rotgb_difficulty = 2,
			rotgb_default_last_wave = 80,
			rotgb_target_natural_health = 100,
			rotgb_blimp_health_multiplier = 2
		}
	},
	hard_legacy = {
		category = "hard",
		place = 3,
		xpmul = 0.005,
		convars = {
			rotgb_difficulty = 2,
			rotgb_default_last_wave = 120,
			rotgb_target_natural_health = 100,
			rotgb_default_wave_preset = "?LEGACY_10S",
			rotgb_spawner_force_auto_start = 1
		}
	},
	insane_regular = {
		category = "insane",
		place = 1,
		xpmul = 0.125,
		convars = {
			rotgb_difficulty = 3,
			rotgb_default_last_wave = 100,
			rotgb_target_natural_health = 50
		}
	},
	insane_doublehp = {
		category = "insane",
		place = 2,
		xpmul = 0.15,
		convars = {
			rotgb_difficulty = 3,
			rotgb_default_last_wave = 100,
			rotgb_target_natural_health = 50,
			rotgb_health_multiplier = 2
		}
	},
	insane_bosses = {
		category = "insane",
		place = 3,
		xpmul = 0.175,
		convars = {
			rotgb_difficulty = 3,
			rotgb_default_last_wave = 100,
			rotgb_target_natural_health = 50,
			rotgb_default_wave_preset = "?BOSSES",
			rotgb_spawner_force_auto_start = 1
		}
	},
	impossible_regular = {
		category = "impossible",
		place = 1,
		xpmul = 0.0625,
		convars = {
			rotgb_difficulty = 4,
			rotgb_default_last_wave = 120,
			rotgb_target_natural_health = 1
		}
	},
	impossible_monsoon = {
		category = "impossible",
		place = 2,
		xpmul = 0.075,
		convars = {
			rotgb_difficulty = 4,
			rotgb_default_last_wave = 120,
			rotgb_target_natural_health = 1,
			rotgb_default_wave_preset = "?2S",
			rotgb_spawner_force_auto_start = 1
		}
	},
	impossible_bosses = {
		category = "impossible",
		place = 3,
		xpmul = 0.005,
		convars = {
			rotgb_difficulty = 4,
			rotgb_default_last_wave = 140,
			rotgb_target_natural_health = 1,
			rotgb_default_wave_preset = "?BOSSES_SUPER",
			rotgb_spawner_force_auto_start = 1
		}
	},
}

RTG_STAT_POPS = 1
RTG_STAT_INIT = 2
RTG_STAT_VOTES = 3
RTG_STAT_FULLUPDATE = 4
RTG_STAT_ACHIEVEMENTS = 5

RTG_OPERATION_KICK = 1
RTG_OPERATION_GAMEOVER = 2
RTG_OPERATION_DIFFICULTY = 3
RTG_OPERATION_VOTESTART = 4
RTG_OPERATION_VOTEEND = 5
RTG_OPERATION_SKILLS = 6
RTG_OPERATION_MAPS = 7
RTG_OPERATION_TEAM = 8
RTG_OPERATION_ACHIEVEMENT = 9

RTG_VOTE_KICK = 1
RTG_VOTE_CHANGEDIFFICULTY = 2
RTG_VOTE_RESTART = 3
RTG_VOTE_MAP = 4

RTG_VOTERESULT_NOTARGET = 1
RTG_VOTERESULT_COOLDOWN = 2
RTG_VOTERESULT_AGREED = 3
RTG_VOTERESULT_DISAGREED = 4
RTG_VOTERESULT_KICKBYCHANGEDNICK = 5

RTG_SKILL_CLEAR = 1
RTG_SKILL_ONE = 2
RTG_SKILL_MULTIPLE = 3

RTG_TEAM_WAIT = 1
RTG_TEAM_SAME = 2
RTG_TEAM_INVALID = 3
RTG_TEAM_REJECTED = 4
RTG_TEAM_CHANGED = 5

RTG_LOGGING_INFO = 1
RTG_LOGGING_ERROR = 2

local color_aqua = Color(0,255,255)
local color_light_red = Color(255,127,127)

function GM:RTG_Log(message, logging, noNewline)
	local logColor = color_white
	if logging == RTG_LOGGING_ERROR then
		logColor = color_light_red
	end
	local newline = '\n'
	if noNewline then
		newline = nil
	end
	MsgC(color_aqua, "[RotgB:TG] ", logColor, message, newline)
end

local clientFiles = {
	"cl_achievements.lua",
	"cl_common_functions.lua",
	"cl_hud.lua",
	"cl_localization.lua",
	"cl_misc.lua",
	"cl_net.lua",
	"cl_player.lua",
	"cl_skills.lua",
	"cl_ui.lua",
	"cl_voting.lua",
}

local sharedFiles = {
	"sh_achievements.lua",
	"sh_common_functions.lua",
	"sh_misc.lua",
	"sh_player.lua",
	"sh_skills.lua",
	"sh_teams.lua",
	"player_class/builder.lua",
	"player_class/hunter.lua",
}

local serverFiles = {
	"sv_achievements.lua",
	"sv_misc.lua",
	"sv_net.lua",
	"sv_player.lua",
	"sv_skills.lua",
	"sv_spectators.lua",
	"sv_teams.lua",
	"sv_voting.lua",
}

for i,v in ipairs(clientFiles) do
	if SERVER then
		AddCSLuaFile(v)
	end
	if CLIENT then
		include(v)
	end
end

for i,v in ipairs(sharedFiles) do
	if SERVER then
		AddCSLuaFile(v)
	end
	include(v)
end

if SERVER then
	resource.AddWorkshop("1616333917")
	for i,v in ipairs(serverFiles) do
		include(v)
	end
end