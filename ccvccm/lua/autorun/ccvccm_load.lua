--[[
what still needs to be done:

element copy + paste
element eyedropper
custom API for addons to add root tabs with elements
]]

--[[
-- if you want to use Moonloader, make sure to also remove all .lua files in lua/ccvccm!
require 'moonloader'
moonloader.PreCacheDir 'ccvccm'
]]

CCVCCM = {
	_VERSION = '0.1.1',
	_VERSIONDATE = '2023-07-30',
	_VERSIONNUMBER = 101
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