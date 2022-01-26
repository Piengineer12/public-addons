GM.Name							= "RotgB: The Gamemode!"
GM.Author						= "Piengineer12"
GM.Version						= "1.0.0"
GM.VersionDate					= "2022-01-23"
GM.Email						= "[REDACTED]"
GM.Website						= "https://steamcommunity.com/id/Piengineer12"
GM.TeamBased					= true
GM.SecondsBetweenTeamSwitches	= 1
GM.SpawnDelay					= 2
GM.NetSendInterval				= 0.2 -- this is also the scoreboard refresh rate, but if this is too low, messages might be sent to the client so fast that the client might crash!
GM.DatabaseFormatVersion		= 1
GM.DatabaseSaveInterval			= 30
GM.VoteTime						= 15
GM.DebugMode					= true
GM.ModeCategories				= {Easy = 1, Medium = 2, Hard = 3, Insane = 4, Impossible = 5}
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
			
			rotgb_difficulty = true,
			rotgb_default_wave_preset = true,
			rotgb_default_last_wave = true,
			rotgb_target_natural_health = true
		}
	},
	easy_regular = {
		category = "Easy",
		name = "Regular",
		description = "Easy difficulty, ends at Wave 40. Towers and upgrades are 20% cheaper and gBalloons move 10% slower.",
		place = 1,
		xpmul = 1,
		convars = {
			rotgb_difficulty = 0,
			rotgb_default_last_wave = 40,
			rotgb_target_natural_health = 200
		}
	},
	easy_chessonly = {
		category = "Easy",
		name = "Chess Only",
		description = "Easy difficulty, but only chess towers can be placed. Experience gain is increased by 20%.",
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
		category = "Easy",
		name = "Half Cash",
		description = "Easy difficulty, but all income and cash gains are halved. Experience gain is increased by 100%.",
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
		name = "Regular",
		category = "Medium",
		description = "Medium difficulty, ends at Wave 60.",
		place = 1,
		xpmul = 0.5,
		convars = {
			rotgb_difficulty = 1,
			rotgb_default_last_wave = 60,
			rotgb_target_natural_health = 150
		}
	},
	medium_rainstorm = {
		name = "Rainstorm",
		category = "Medium",
		description = "Medium difficulty, but waves always start immediately one after another, regardless of Auto-Start settings. Experience gain is increased by 20%.",
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
		name = "Strategic",
		category = "Medium",
		description = "Medium difficulty, but starts at Wave 51. You also start with 20,000 cash instead of 650, but you cannot gain cash from any sources. Experience gain is increased by 40%.",
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
		name = "Regular",
		category = "Hard",
		description = "Hard difficulty, ends at Wave 80. Towers and upgrades are 20% more expensive and gBalloons move 10% faster.",
		place = 1,
		xpmul = 0.25,
		convars = {
			rotgb_difficulty = 2,
			rotgb_default_last_wave = 80,
			rotgb_target_natural_health = 100
		}
	},
	hard_doublehpblimps = {
		name = "Double HP gBlimps",
		category = "Hard",
		description = "Hard difficulty, except all gBlimps have double health. Experience gain is increased by 20%.",
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
		name = "Legacy Monsoon",
		category = "Hard",
		description = "Hard difficulty, but ends at Wave 120, waves start every 10 seconds and pre-Update 4.0.0 waves are used instead. Experience gain is decreased by 98%.",
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
		name = "Regular",
		category = "Insane",
		description = "Insane difficulty, ends at Wave 100. Towers and upgrades are 40% more expensive and gBalloons move 20% faster.",
		place = 1,
		xpmul = 0.125,
		convars = {
			rotgb_difficulty = 3,
			rotgb_default_last_wave = 100,
			rotgb_target_natural_health = 50
		}
	},
	insane_doublehp = {
		name = "Double HP gBalloons",
		category = "Insane",
		description = "Insane difficulty, except ALL gBalloons have double health. Experience gain is increased by 20%.",
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
		name = "Bosses",
		category = "Insane",
		description = "Insane difficulty, but waves always start immediately one after another and a boss gBalloon spawns once every 20 waves. Experience gain is increased by 40%.",
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
		name = "Regular",
		category = "Impossible",
		description = "Impossible difficulty, ends at Wave 120. Towers and upgrades are 60% more expensive and gBalloons move 30% faster.",
		place = 1,
		xpmul = 0.0625,
		convars = {
			rotgb_difficulty = 4,
			rotgb_default_last_wave = 120,
			rotgb_target_natural_health = 1
		}
	},
	impossible_monsoon = {
		name = "Monsoon",
		category = "Impossible",
		description = "Impossible difficulty, but waves always start two seconds apart from each other, regardless of Auto-Start settings. Experience gain is increased by 20%.",
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
		name = "Super Bosses",
		category = "Impossible",
		description = "Impossible difficulty, but with super bosses and ends at Wave 140. Hopefully. Experience gain is decreased by 92%.",
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

--[[
TO DO LIST:

skill tree img
sfx for upgrading - how?
music - how?

button to sell all towers - low priority
button to activate all abilities - low priority

fix Multipurpose Engine buff desync - difficult to solve on client side
+ several others (*.txt in fan_sent_content) - no thanks

GAMEMODE:

skill web: skill web stars?

ADDON: PZDraw

fonts
rich text

WPASS:

fire element - flaming
earth element - corroding
water element - freezing
wind element - poisonous, poison

BETTER DAMAGE API:
see above
multiple damage objects
]]

RTG_STAT_POPS = 1
RTG_STAT_INIT = 2
RTG_STAT_VOTES = 3

RTG_OPERATION_KICK = 1
RTG_OPERATION_GAMEOVER = 2
RTG_OPERATION_DIFFICULTY = 3
RTG_OPERATION_VOTESTART = 4
RTG_OPERATION_VOTEEND = 5
RTG_OPERATION_SKILLS = 6
RTG_OPERATION_MAPS = 7

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
	"cl_common_functions.lua",
	"cl_hud.lua",
	"cl_misc.lua",
	"cl_net.lua",
	"cl_player.lua",
	"cl_skills.lua",
	"cl_ui.lua",
	"cl_voting.lua",
}

local sharedFiles = {
	"sh_common_functions.lua",
	"sh_misc.lua",
	"sh_player.lua",
	"sh_skills.lua",
	"sh_teams.lua",
	"player_class/builder.lua",
	"player_class/hunter.lua"
}

local serverFiles = {
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
	for i,v in ipairs(serverFiles) do
		include(v)
	end
end