--[[NEXT:
make npc_helicopter behave properly when killed (don't let it set health to extreme values) (test!)
fix props having health set to -inf after taking damage
fix health, armor, damage becoming inf when too high after level transition
fix picked up SMGs having 50M ammo
rework Mysticality and possibly other modifiers
]]

local clientFiles = {
	"cl_base",
	"cl_infhealth",
	"cl_net",
	"cl_options",
	"cl_wpass2",
	"cl_wpass2_basemods",
	"cl_xp"
}

local serverFiles = {
	"sv_base",
	"sv_infhealth",
	"sv_net",
	"sv_wpass2",
	"sv_wpass2_basemods",
	"sv_xp"
}

local sharedFiles = {
	"sh_base",
	"sh_infhealth",
	"sh_wpass2",
	"sh_wpass2_basemods",
	"sh_xp"
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