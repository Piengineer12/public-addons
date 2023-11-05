if false then
	-- if you want to use Moonloader, make sure to also remove all .lua files in lua/capawc!
	require 'moonloader'
	moonloader.PreCacheDir 'capawc'
end

capawc = {
	_VERSION = '1.0.1',
	_VERSIONDATE = '2023-11-05'
}

if SERVER then
	AddCSLuaFile 'capawc/shared.lua'
	AddCSLuaFile 'capawc/client.lua'
	include 'capawc/shared.lua'
	include 'capawc/server.lua'
end
if CLIENT then
	include 'capawc/shared.lua'
	include 'capawc/client.lua'
end