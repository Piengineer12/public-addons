--[[
what still needs to be done:

autosaving of addon vars
finish implementing CCVCCMPointer methods
accomodate for ConVar / ConCommand flags on addon vars / commands
foolproofing

ability to copy all elements in spawnmenu [tab['s category['s subcategory] ] ]

super keybinds
	1 2 -> press 1 then press 2
	1+2 -> press 1 and 2
	1/2 -> press 1 or 2
	-1 -> don't press 1
	\* -> press *, * may be any non-alphabetical character
	#1 -> always interpreted as true, can be used for comments
	!1 -> same as #1 but entire keybind is aborted if 1 is pressed after this set
	@1 -> same as #1 but entire keybind is accepted if 1 is pressed after this set
	1x2 -> 1+*2, where * is one of the five unary operators above
	1,2 -> 1 -1+2
	1+2,3 -> 1+2 -2+3
	(1+2),3 -> (1+2) -(1+2)+3

	examples
	-- press 1 and 2, then press 1 and 3
	1+2 1+3
	-- press 1 and 2, then press 1 and 3 with 2 released
	1+2,1+3 or 1+2 -2+1+3
	-- press 1 and 2, then press 3 and 4 with either 1 or 2 released
	(1+2),3+4 or (1+2) -(1+2)+3+4
	-- press 1 and 2, then release both, then press 1 and 3
	1+2 -1-2 1+3 or 1+2 -1+-2 1+3
	-- press 1 and 2, then press 1 and 3 unless 1 and 2 was pressed again
	1+2,!(1+2) 1+3 or 1+2 -2+!(1+2) 1+3
]]

-- if you want to use Moonloader, make sure to also remove all .lua files in lua/ccvccm!
-- require 'moonloader'
-- moonloader.PreCacheDir 'ccvccm'

CCVCCM = {
	_VERSION = '0.2.0',
	_VERSIONDATE = '2023-09-04',
	_VERSIONNUMBER = 200
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