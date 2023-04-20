--[[NEXT:
make npc_helicopter behave properly when killed (don't let it set health to extreme values)
make sure poison headcrabs do not instakill
test what happens when DLib is not present
GUI options, and DForm for options
]]

local clientFiles = {
	"cl_base",
	"cl_infhealth",
	"cl_net",
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