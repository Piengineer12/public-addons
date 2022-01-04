GM.Name							= "RotgB: The Gamemode!"
GM.Author						= "Piengineer"
GM.Email						= "[REDACTED]"
GM.Website						= "https://steamcommunity.com/id/Piengineer12"
GM.TeamBased					= true
GM.SecondsBetweenTeamSwitches	= 1
GM.SpawnDelay					= 2
GM.NetSendInterval				= 0.2 -- this is also the scoreboard refresh rate, but if this is too low, messages might be sent to the client so fast that the client might crash!
GM.DatabaseFormatVersion		= 1
GM.DatabaseSaveInterval			= 30
GM.VoteTime						= 20
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
		convars = {
			rotgb_difficulty = 0,
			rotgb_default_last_wave = 40,
			rotgb_target_natural_health = 200
		}
	},
	easy_chessonly = {
		category = "Easy",
		name = "Chess Only",
		description = "Easy difficulty, but only chess towers can be placed.",
		place = 2,
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
		description = "Easy difficulty, but all income and cash gains are halved.",
		place = 3,
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
		convars = {
			rotgb_difficulty = 1,
			rotgb_default_last_wave = 60,
			rotgb_target_natural_health = 150
		}
	},
	medium_avalanche = {
		name = "Avalanche",
		category = "Medium",
		description = "Medium difficulty, but rounds always start immediately one after another, regardless of Auto-Start settings.",
		place = 2,
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
		description = "Medium difficulty, but starts at Wave 51. You also start with 20,000 cash instead of 650, but you cannot gain cash from any sources.",
		place = 3,
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
		convars = {
			rotgb_difficulty = 2,
			rotgb_default_last_wave = 80,
			rotgb_target_natural_health = 100
		}
	},
	hard_legacy = {
		name = "Legacy Waves",
		category = "Hard",
		description = "Hard difficulty, except pre-Update 5.0.0 waves are used instead.",
		place = 2,
		convars = {
			rotgb_difficulty = 2,
			rotgb_default_last_wave = 80,
			rotgb_target_natural_health = 100,
			rotgb_default_wave_preset = "?LEGACY"
		}
	},
	hard_doublehpblimps = {
		name = "Double HP gBlimps",
		category = "Hard",
		description = "Hard difficulty, except all gBlimps have double health.",
		place = 3,
		convars = {
			rotgb_difficulty = 2,
			rotgb_default_last_wave = 80,
			rotgb_target_natural_health = 100,
			rotgb_blimp_health_multiplier = 2
		}
	},
	insane_regular = {
		name = "Regular",
		category = "Insane",
		description = "Insane difficulty, ends at Wave 100. Towers and upgrades are 40% more expensive and gBalloons move 20% faster.",
		place = 1,
		convars = {
			rotgb_difficulty = 3,
			rotgb_default_last_wave = 100,
			rotgb_target_natural_health = 50
		}
	},
	insane_doublehp = {
		name = "Double HP gBalloons",
		category = "Insane",
		description = "Insane difficulty, except ALL gBalloons have double health.",
		place = 2,
		convars = {
			rotgb_difficulty = 3,
			rotgb_default_last_wave = 100,
			rotgb_target_natural_health = 50,
			rotgb_health_multiplier = 2
		}
	},
	impossible_regular = {
		name = "Regular",
		category = "Impossible",
		description = "Impossible difficulty, ends at Wave 120. Towers and upgrades are 60% more expensive and gBalloons move 30% faster.",
		place = 1,
		convars = {
			rotgb_difficulty = 4,
			rotgb_default_last_wave = 120,
			rotgb_target_natural_health = 1
		}
	}
}

--[[
TO DO LIST:
+ several others (*.txt in same directory)

complete new spawner waves
update the readme file
sandbox saving
fix autostart on rotgb_heatwave
sfx for upgrading and placing
music?
fix Multipurpose Engine buff desync - difficult to solve on client side
popped gBalloons MIGHT incorrectly render a shield when their health is actually too low to render - low priority
button to sell all towers - low priority
button to activate all abilities - low priority

ISAWC:

TEST

GAMEMODE:

implement more game difficulty modes
implement description field for difficulty GUI
skill web: skill web stars?
voting: kicking + difficulty setting
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

RTG_VOTE_KICK = 1

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

local files = {
	"sh_common_functions.lua",
	"sh_player.lua",
	"sh_skills.lua",
	"sh_teams.lua",
	"player_class/builder.lua",
	"player_class/hunter.lua"
}

for i,v in ipairs(files) do
	AddCSLuaFile(v)
	include(v)
end

function GM:CreateTeams()
	hook.Run("InitializeTeams")
end

function GM:PhysgunPickup(ply, ent)
	if self.DebugMode then return true
	elseif ent.Base == "gballoon_tower_base" then return hook.Run("GetSkillAmount", "physgun") > 0 and not ROTGB_BalloonsExist()
	end
	return false
end

function GM:PlayerNoClip(ply, desired)
	return self.DebugMode
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

function GM:PostCleanupMap()
	RTG_FirstAllyPawnFreeDone = nil
	if SERVER then
		hook.Run("PostCleanupMapServer")
	end
end

-- non-base

function GM:SharedInitialize()
	hook.Run("RebuildSkills")
	hook.Run("SetCachedSkillAmounts", {})
end

AccessorFunc(GM, "Difficulty", "Difficulty", FORCE_STRING)
AccessorFunc(GM, "CurrentVote", "CurrentVote")

function GM:ShouldConVarOverride(cvar)
	local currentDifficulty = hook.Run("GetDifficulty")
	return self.Modes[currentDifficulty] and self.Modes[currentDifficulty].convars[cvar] or self.Modes.__common.convars[cvar]
end
