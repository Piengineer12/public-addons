if false then
	-- if you want to use Moonloader, make sure to also remove all .lua files in lua/capawc!
	require 'moonloader'
	moonloader.PreCacheDir 'capawc'
end

capawc = {
	_VERSION = '1.0.0-pre.1',
	_VERSIONDATE = '2023-10-29'
}

if SERVER then
	AddCSLuaFile 'capawc/client.lua'
	include 'capawc/server.lua'
end
if CLIENT then
	include 'capawc/client.lua'
end