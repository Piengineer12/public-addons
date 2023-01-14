GM.Name							= "RotgB: The Gamemode!"
GM.Author						= "Piengineer12"
GM.Version						= "2.0.1"
GM.VersionDate					= "2023-01-14"
GM.Email						= "[REDACTED]"
GM.Website						= "https://steamcommunity.com/id/Piengineer12"
GM.TeamBased					= false
GM.SecondsBetweenTeamSwitches	= 1
GM.SpawnDelay					= 2
GM.NetFullUpdateInterval		= 15
GM.DatabaseFormatVersion		= 1
GM.DatabaseSaveInterval			= 30
GM.VoteTime						= 15
GM.DebugMode					= false

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
RTG_OPERATION_ONESHOT = 10

RTG_VOTE_KICK = 1
RTG_VOTE_HOGALLXP = 2
RTG_VOTE_CHANGEDIFFICULTY = 3
RTG_VOTE_RESTART = 4
RTG_VOTE_MAP = 5

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
	"cl_difficulty.lua",
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
	"sh_difficulty.lua",
	"sh_misc.lua",
	"sh_player.lua",
	"sh_skills.lua",
	"sh_teams.lua",
	"player_class/builder.lua",
	"player_class/hunter.lua",
}

local serverFiles = {
	"sv_achievements.lua",
	"sv_difficulty.lua",
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
	resource.AddWorkshop("1616333917") -- the base RotgB addon
	resource.AddWorkshop("2734409345") -- in case rotgb.txt doesn't do its job
	for i,v in ipairs(serverFiles) do
		include(v)
	end
end