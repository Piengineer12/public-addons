--[[
what still needs to be done:

element copy + paste
element eyedropper
option for ConVars to include a button confirming the change
custom API for addons to add root tabs with elements
make client.lua fit within 64 KB or split the file into smaller files
	GMod refuses to download Lua files over 64 KB in size
]]

--[[
-- if you want to use Moonloader, make sure to also remove all .lua files in lua/ccvccm!
require 'moonloader'
moonloader.PreCacheDir 'ccvccm'
]]

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