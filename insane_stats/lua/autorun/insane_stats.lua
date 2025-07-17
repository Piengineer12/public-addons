--[[
Workshop:		https://steamcommunity.com/sharedfiles/filedetails/?id=2980423627
Profile Page:	https://steamcommunity.com/id/Piengineer12
GitHub Page:	https://github.com/Piengineer12/public-addons/tree/master/insane_stats
Donate:			https://ko-fi.com/piengineer12

ideas for skills

thrown bugbait marks target for death, and r -> teleport antlions to self
make starlight range fixed

misc

make shops accessible via infinite ammo crates / chargers
- cost per health point: 1 unless health charger, where Fill to Max is free
- - buy options: Fill to Max, x1, x10, x100, 1%c, 10%c and 100%c
- - bloodletting effects disables ability to restore health for free
- cost per armor point: 2 unless suit charger, where Fill to Max is free
- - buy options: Fill to Max, x1, x10, x100, 1%c, 10%c and 100%c
- base full refill cost per ammo type: 100 * missing fraction (* 0 for matching ammo crate)
- - only Fill to Max buy option is available
- - More Bullet per Bullet adds buy options x1, x10, x100, 1%c, 10%c and 100%c, but disables ability to restore ammo for free
- - option to randomize costs
- - option to limit number of extra ammo types sold, as %
add more support for Synergy maps (info_player_equip, trigger_coop, hud_timer)
]]

InsaneStats = {
	VERSION = "2.1.2-alpha.1",
	VERSION_DATE = "2025-07-13",
	WORKSHOP_ID = "2980423627"
}

function InsaneStats:Log(msg, ...)
	msg = msg:format(...)
	MsgC(
		Color(0, 255, 255),
		SERVER and "[Insane Stats Server] " or "[Insane Stats Client] ",
		color_white,
		msg,
		"\n"
	)
end

InsaneStats:Log(
	"Loading Insane Stats version %s (%s) by Piengineer12",
	InsaneStats.VERSION, InsaneStats.VERSION_DATE
)

local clientFiles = {
	"cl_base",
	"cl_coin",
	"cl_infhealth",
	"cl_net",
	"cl_options",
	"cl_pointcommander",
	"cl_skills",
	"cl_wpass2",
	"cl_wpass2_basemods",
	"cl_xp"
}

local sharedFiles = {
	"sh_base",
	"sh_coin",
	"sh_infhealth",
	"sh_options",
	"sh_pointcommander",
	"sh_skills",
	"sh_skills_basemods",
	"sh_soundfixes",
	"sh_wpass2",
	"sh_wpass2_basemods",
	"sh_xp"
}

local serverFiles = {
	"sv_base",
	"sv_coin",
	"sv_infhealth",
	"sv_net",
	"sv_pointcommander",
	"sv_skills",
	"sv_wpass2",
	"sv_wpass2_basemods",
	"sv_xp"
}

local baseFilePath = "insane_stats/%s.lua"

for i,v in ipairs(sharedFiles) do
	local filePath = string.format(baseFilePath, v)
	AddCSLuaFile(filePath)
	include(filePath)
end

if SERVER then
	for i,v in ipairs(serverFiles) do
		local filePath = string.format(baseFilePath, v)
		include(filePath)
	end
end

for i,v in ipairs(clientFiles) do
	local filePath = string.format(baseFilePath, v)
	if SERVER then
		AddCSLuaFile(filePath)
	else
		include(filePath)
	end
end

for i,v in ents.Iterator() do
	hook.Run("InsaneStatsTransitionCompat", v)
end
