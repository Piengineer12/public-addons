--[[
what still needs to be done:

accomodate for ConVar / ConCommand flags
hook for modifying save data
custom API for addons to add root tabs with elements
element eyedropper
]]

--[[
-- if you want to use Moonloader, make sure to also remove all .lua files in lua/ccvccm!
require 'moonloader'
moonloader.PreCacheDir 'ccvccm'
]]

CCVCCM = {
	_VERSION = '0.1.2',
	_VERSIONDATE = '2023-08-03',
	_VERSIONNUMBER = 102
}

if SERVER then
	AddCSLuaFile 'ccvccm/shared.lua'
	AddCSLuaFile 'ccvccm/client.lua'
	include 'ccvccm/shared.lua'
	include 'ccvccm/server.lua'
end
if CLIENT then
	include 'ccvccm/shared.lua'
	include 'ccvccm/client.lua'
end