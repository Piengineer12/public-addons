--[[
Workshop:		https://steamcommunity.com/sharedfiles/filedetails/?id=2403043112
Profile Page:	https://steamcommunity.com/id/Piengineer12
GitHub Page:	https://github.com/Piengineer12/public-addons/tree/master/lua_repair
Donate:			https://ko-fi.com/piengineer12

Links above are confirmed working as of 2022-05-26. All dates are in ISO 8601 format. 
]]

-- The + at the name of this Lua file is important so that it loads before most other Lua files
LUA_REPAIR_VERSION = "2.0.5"
LUA_REPAIR_VERSION_DATE = "2023-09-09"

local FIXED
local color_aqua = Color(0, 255, 255)
local conVarLogging = CreateConVar("lua_repair_logging", "0", FCVAR_ARCHIVED, "Enables Lua Repair logging.")
local lastError = 0

local function Log(...)
	local message = {color_aqua, "[Lua Repair ", SERVER and "Server] " or "Client] ", color_white, ...}
	table.insert(message, '\n')
	MsgC(unpack(message))
end

local function LogError(...)
	if conVarLogging:GetBool() and lastError < RealTime() and not string.find(debug.traceback(), "'pcall'") then
		lastError = RealTime() + 1
		local message = {color_aqua, "[Lua Repair ", SERVER and "Server] " or "Client] ", color_white, ...}
		table.insert(message, '\n')
		MsgC(unpack(message))
		debug.Trace()
	end
end

-- aaand pretty much everything here is dangerous
local function FixAllErrors()
	if LUA_REPAIR_FIXED then return end
	Log("Loading Lua Repair by Piengineer12, version "..LUA_REPAIR_VERSION.." ("..LUA_REPAIR_VERSION_DATE..")")
	
	Log("Patching primitives...")
	local NIL = getmetatable(nil) or {}
	local NUMBER = getmetatable(0) or {}
	local STRING = getmetatable("") or {}
	local VECTOR = FindMetaTable("Vector")
	local ENTITY = FindMetaTable("Entity")
	local NPC = FindMetaTable("NPC")
	local PLAYER = FindMetaTable("Player")
	local CLUAEMITTER = FindMetaTable("CLuaEmitter")
	local NULL_META = getmetatable(NULL) or {}
	local PHYSOBJ = FindMetaTable("PhysObj")
	local CTAKEDAMAGEINFO = FindMetaTable("CTakeDamageInfo")
	local AUDIOCHANNEL = FindMetaTable("IGModAudioChannel")
	local newNilMeta = {
		__add = function(a,b)
			LogError("Some code attempted to add with nil.")
			return a or b
		end,
		__sub = function(a,b)
			LogError("Some code attempted to subtract with nil.")
			return a or b
		end,
		__mul = function(a,b)
			LogError("Some code attempted to multiply with nil.")
			return a or b
		end,
		__div = function(a,b)
			LogError("Some code attempted to divide with nil.")
			return a
		end,
		__pow = function(a,b)
			LogError("Some code attempted to raise something to a power with nil.")
			if not b then return 1 else return 0 end
		end,
		__unm = function(a)
			LogError("Some code attempted to negate nil.")
			return a
		end,
		__concat = function(a,b)
			LogError("Some code attempted to concatenate with nil.")
			return tostring(a) .. tostring(b)
		end,
		__len = function()
			LogError("Some code attempted to get the length of nil.")
			return 0
		end,
		__lt = function(a,b)
			LogError("Some code attempted to see if something is bigger or smaller than nil.")
			if isnumber(a) or isnumber(b) then
				return (a or 0) < (b or 0)
			else
				return tostring(a) < tostring(b)
			end
		end,
		__le = function(a,b)
			LogError("Some code attempted to see if something is bigger or smaller than nil.")
			if isnumber(a) or isnumber(b) then
				return (a or 0) <= (b or 0)
			else
				return tostring(a) <= tostring(b)
			end
		end,
		__index = function()
			LogError("Some code attempted to index nil.")
		end,
		__newindex = function()
			LogError("Some code attempted to assign a member value to nil.")
		end,
		__call = function()
			LogError("Some code attempted to call nil as a function.")
		end
	}
	for k,v in pairs(newNilMeta) do
		NIL[k] = v
	end
	
	local oldPairs = pairs
	pairs = function(tab, ...)
		if not tab then
			LogError("Some code attempted to iterate over an empty table.")
		end
		tab = tab or {}
		return oldPairs(tab, ...)
	end

	NUMBER.__lt = function(a,b)
		if isnumber(a) or isnumber(b) then
			return (a or 0) < (b or 0)
		else
			if not (isstring(a) and isstring(b)) then
				LogError("Some code attempted to see if a number is bigger or smaller than something else that isn't.")
			end
			return tostring(a) < tostring(b)
		end
	end
	NUMBER.__le = function(a,b)
		if isnumber(a) or isnumber(b) then
			return (a or 0) <= (b or 0)
		else
			if not (isstring(a) and isstring(b)) then
				LogError("Some code attempted to see if a number is bigger or smaller than something else that isn't.")
			end
			return tostring(a) <= tostring(b)
		end
	end
	
	STRING.__concat = function(a,b)
		if not (isstring(a) and isstring(b)) then
			LogError("Some code attempted to concatenate a string with something that isn't.")
		end
		return tostring(a)..tostring(b)
	end
	local oldExplode = string.Explode
	string.Explode = function(separator, str, withpattern)
		if not (separator and str) then
			LogError("Some code attempted to explode a string without providing string separator or haystack.")
		end
		separator = separator or ""
		str = str or ""
		return oldExplode(separator, str, withpattern)
	end
	
	debug.setmetatable(nil,NIL)
	--debug.setmetatable("",STRING)
	--debug.setmetatable(0,NUMBER)
	
	local oldadd,oldsub = VECTOR.__add,VECTOR.__sub
	local oldmul,olddiv = VECTOR.__mul,VECTOR.__div
	VECTOR.__add = function(a,b)
		if not (isvector(a) and isvector(b)) then
			LogError("Some code attempted to add a vector with something that isn't.")
		end
		return oldadd(isvector(a) and a or Vector(a),isvector(b) and b or Vector(b))
	end
	VECTOR.__sub = function(a,b)
		if not (isvector(a) and isvector(b)) then
			LogError("Some code attempted to subtract a vector with something that isn't.")
		end
		return oldsub(isvector(a) and a or Vector(a),isvector(b) and b or Vector(b))
	end
	VECTOR.__mul = function(a,b)
		if not (isnumber(a) or isnumber(b) or isvector(a) and isvector(b)) then
			LogError("Some code attempted to multiply a vector with something that isn't a number.")
		end
		return oldmul(a or 1,b or 1)
	end
	VECTOR.__div = function(a,b)
		if not (isnumber(a) or isnumber(b) or isvector(a) and isvector(b)) then
			LogError("Some code attempted to divide a vector with something that isn't a number.")
		end
		return olddiv(a or 1,b or 1)
	end
	
	local oldGC = ENTITY.GetClass
	ENTITY.GetClass = function(ent, ...)
		if not IsValid(ent) then
			LogError("Some code attempted to get the class of a NULL entity.")
			return ent.__tostring(ent, ...)
		else return oldGC(ent, ...)
		end
	end
	local oldPos = ENTITY.GetPos
	ENTITY.GetPos = function(ent, ...)
		if not IsValid(ent) then
			LogError("Some code attempted to get the position of a NULL entity.")
			return vector_origin
		else return oldPos(ent, ...)
		end
	end
	
	local oldLookupAttachment = ENTITY.LookupAttachment
	ENTITY.LookupAttachment = function(ent, ...)
		if not IsValid(ent) then
			LogError("Some code attempted to lookup an attachment of a NULL entity.")
			return -1
		else return oldLookupAttachment(ent, ...)
		end
	end
	local oldGetBonePosition = ENTITY.GetBonePosition
	ENTITY.GetBonePosition = function(ent, boneIndex, ...)
		if not boneIndex then
			LogError("Some code attempted to call Entity:GetBonePosition() without valid bone index.")
		end
		return oldGetBonePosition(ent, boneIndex or 0, ...)
	end
	local oldLookupBone = ENTITY.LookupBone
	ENTITY.LookupBone = function(ent, name, ...)
		local retValues = {oldLookupBone(ent,name,...)}
		if retValues[1] then return unpack(retValues) end
		
		local retValues = {oldLookupBone(ent,isstring(name) and name:lower() or name,...)}
		if retValues[1] then
			LogError("Some code attempted to call Entity:LookupBone() without lowercased bone name.")
			return unpack(retValues)
		end
	end
	--[[local oldindex = NULL_META.__index
	NULL_META.__index = function(ent,key)
		if rawget() then
			local args = {pcall(oldindex,ent,key)}
			if not args[1] then
				error("Attempt to call \""..key.."\" on a NULL entity (tell the owner of \"Lua and Model Error Fixers\" about it!)")
			end
		else return oldindex(ent,key)
		end
	end]]
	local oldPhysicsAttacker = ENTITY.SetPhysicsAttacker
	ENTITY.SetPhysicsAttacker = function(ent, attacker, ...)
		if attacker:IsPlayer() then
			if oldPhysicsAttacker then
				return oldPhysicsAttacker(ent, attacker, ...)
			end
		else
			LogError("Some code attempted to set the physics attacker of an entity to a non-player.")
		end
	end
	local oldSetColor = ENTITY.SetColor
	ENTITY.SetColor = function(ent, ...)
		if not IsValid(ent) then
			LogError("Some code attempted to set the color of a NULL entity.")
		else return oldSetColor(ent, ...)
		end
	end
	local oldSetColor4Part = ENTITY.SetColor4Part
	ENTITY.SetColor4Part = function(ent, ...)
		if not IsValid(ent) then
			LogError("Some code attempted to set the color of a NULL entity.")
		else return oldSetColor4Part(ent, ...)
		end
	end
	local oldGetBoneCount = ENTITY.GetBoneCount
	ENTITY.GetBoneCount = function(ent, ...)
		if not IsValid(ent) then
			LogError("Some code attempted to get the number of bones of a NULL entity.")
			return 0
		else return oldGetBoneCount(ent, ...)
		end
	end
	local oldEnemy = NPC.GetEnemy
	NPC.GetEnemy = function(ent, ...)
		if not IsValid(ent) then
			LogError("Some code attempted to get the enemy of a NULL entity.")
			return nil
		else
			return oldEnemy(ent, ...)
		end
	end
	
	local oldGetCurrentCommand = PLAYER.GetCurrentCommand
	PLAYER.GetCurrentCommand = function(ply, ...)
		if ply == GetPredictionPlayer() then return oldGetCurrentCommand(ply, ...)
		else LogError("Some code attempted to call Player:GetCurrentCommand() on a player with no commands currently being processed.") end
	end
	
	local oldWake = PHYSOBJ.Wake
	PHYSOBJ.Wake = function(physObj, ...)
		if IsValid(physObj) then
			return oldWake(physObj, ...)
		else
			LogError("Some code attempted to wake a NULL physics object.")
		end
	end
	
	if CLUAEMITTER then
		local oldAdd = CLUAEMITTER.Add
		CLUAEMITTER.Add = function(emitter,...)
			if emitter:IsValid() then return oldAdd(emitter,...)
			else
				LogError("Some code attempted to call CLuaEmitter:Add() on a NULL CLuaEmitter.")
			end
		end
		local oldFinish = CLUAEMITTER.Finish
		CLUAEMITTER.Finish = function(emitter,...)
			if emitter:IsValid() then return oldFinish(emitter,...)
			else
				LogError("Some code attempted to call CLuaEmitter:Finish() on a NULL CLuaEmitter.")
			end
		end
	end
	
	if CTAKEDAMAGEINFO then
		local oldSetAttacker = CTAKEDAMAGEINFO.SetAttacker
		function CTAKEDAMAGEINFO.SetAttacker(dmginfo, attacker, ...)
			if not IsValid(attacker) then
				LogError("Some code attempted to call CTakeDamageInfo:SetAttacker() with NULL attacker.")
				attacker = game.GetWorld()
			end
			oldSetAttacker(dmginfo, attacker, ...)
		end
		local oldSetInflictor = CTAKEDAMAGEINFO.SetInflictor
		function CTAKEDAMAGEINFO.SetInflictor(dmginfo, inflictor, ...)
			if not IsValid(inflictor) then
				LogError("Some code attempted to call CTakeDamageInfo:SetInflictor() with NULL inflictor.")
				inflictor = game.GetWorld()
			end
			oldSetInflictor(dmginfo, inflictor, ...)
		end
	end
	
	if AUDIOCHANNEL then
		local oldStop = AUDIOCHANNEL.Stop
		function AUDIOCHANNEL.Stop(channel, ...)
			if IsValid(channel) then
				oldStop(channel, ...)
			else
				LogError("Some code attempted to call IGModAudioChannel:Stop() with NULL IGModAudioChannel.")
			end
		end
	end

	local oldCreateClientConVar = CreateClientConVar
	function CreateClientConVar(name, default, shouldsave, userinfo, helptext, min, max, ...)
		if min and not isnumber(min) then
			LogError("Some code attempted to call CreateClientConVar with non-number min argument.")
			min = nil
		end
		if max and not isnumber(max) then
			LogError("Some code attempted to call CreateClientConVar with non-number max argument.")
			max = nil
		end
		return oldCreateClientConVar(name, default, shouldsave, userinfo, helptext, min, max, ...)
	end

	local oldCreateConVar = CreateConVar
	function CreateConVar(name, default, flags, helptext, min, max, ...)
		if min and not isnumber(min) then
			LogError("Some code attempted to call CreateConVar with non-number min argument.")
			min = nil
		end
		if max and not isnumber(max) then
			LogError("Some code attempted to call CreateConVar with non-number max argument.")
			max = nil
		end
		return oldCreateConVar(name, default, flags, helptext, min, max, ...)
	end
	
	local oldEntsFindInSphere = ents.FindInSphere
	function ents.FindInSphere(origin, radius, ...)
		if not origin then
			LogError("Some code attempted to call ents.FindInSphere without a sphere center.")
			origin = vector_origin
		end
		if not radius then
			LogError("Some code attempted to call ents.FindInSphere without a radius.")
			radius = 0
		end
		return oldEntsFindInSphere(origin, radius, ...)
	end

	local oldNetStart = net.Start
	net.Start = function(...)
		if net.BytesWritten() then
			if SERVER then
				net.Send({})
			else
				net.SendToServer()
			end
			LogError("Some code attempted to call net.Start without finishing the previous net message.")
		end
		oldNetStart(...)
	end

	local oldNetWriteString = net.WriteString
	function net.WriteString(str, ...)
		if not str then
			LogError("Some code attempted to call net.WriteString without providing a string.")
			str = ''
		end
		return oldNetWriteString(str, ...)
	end
	
	local oldUtilIsValidModel = util.IsValidModel
	function util.IsValidModel(model, ...)
		if not isstring(model) then
			LogError("Some code attempted to call util.IsValidModel with an invalid argument.")
			model = tostring(model)
		end
		return oldUtilIsValidModel(model, ...)
	end
	
	if CLIENT then
		local oldIsKeyDown = input.IsKeyDown
		function input.IsKeyDown(key, ...)
			if not key then
				LogError("Some code attempted to call input.IsKeyDown without specifying a key.")
				return false
			end
			return oldIsKeyDown(key, ...)
		end

		local oldLanguageAdd = language.Add
		function language.Add(key, value, ...)
			if not key then
				LogError("Some code attempted to call language.Add without specifying a language key.")
			elseif not value then
				LogError("Some code attempted to call language.Add without specifying a language value.")
			else return oldLanguageAdd(key, value, ...) end
		end
	end

	Log("Primitives patched!")
	
	Log("Patching hooks...")
	local oldHookAdd = hook.Add
	function hook.Add(event_name, name, func, ...)
		if isfunction(event_name) then
			func = event_name
			event_name = util.CRC(string.dump(event_name))
			LogError("Some code attempted to call hook.Add() with function as first argument.")
		end
		if isfunction(name) then
			func = name
			name = util.CRC(string.dump(name))
			LogError("Some code attempted to call hook.Add() with function as second argument.")
		elseif isnumber(name) and not DLib then
			name = tostring(name)
			LogError("Some code attempted to call hook.Add() with number as second argument.")
		elseif isbool(name) then
			name = tostring(name)
			LogError("Some code attempted to call hook.Add() with boolean as second argument.")
		end
		
		if isstring(event_name) and (isfunction(func) or DLib and type(name) == "thread") then
			local valid = type(name) == "thread" or name.IsValid or IsValid(name)
			if isstring(name) or valid then
				oldHookAdd(event_name, name, func, ...)
			else
				LogError("Some code attempted to call hook.Add() with invalid second argument.")
			end
		end
	end
	if DLib then
		DLib.MessageWarning("DLib hook system is being overwritten by another addon - THIS IS STUPID AND WILL CAUSE ERRORS")
		Log("DLib, shut up and hold still...")
	end
	Log("Hooks patched!")
	LUA_REPAIR_FIXED = true
	
	Log("Waiting for all other addons to load...")
	local startWaitTime = SysTime()
	timer.Simple(0,function()
		Log(string.format("Waited %.2f seconds. Hopefully all other addons have initialized by now.", SysTime()-startWaitTime))
		Log("Patching console commands...")
		
		--[[local shouldBlockCommands = {
			["con_filter_enable"] = true,
			["con_filter_text_out"] = true,
			["crosshair"] = true,
			["sv_cheats"] = true,
			["mp_flashlight"] = true
		}
		local shouldBlockCommandsClientPlayer = {
			["con_filter_text_out"] = true
		}]]
		
		local function ReportBlockedCommand(cmd)
			LogError("An addon tried to use the console command "..cmd.." which is not allowed.")
		end
		
		local oldRunConsoleCommand = RunConsoleCommand
		RunConsoleCommand = function(cmd, ...)
			cmd = cmd or ""
			if IsConCommandBlocked(cmd) or #cmd < 2 then
				ReportBlockedCommand(cmd)
			else
				oldRunConsoleCommand(cmd, ...)
				--[[local resultTab = {pcall(oldRunConsoleCommand, cmd, ...)}
				if not resultTab[1] then
					ReportBlockedCommand(cmd)
				end]]
			end
		end
		local oldGameConsoleCommand = game.ConsoleCommand
		game.ConsoleCommand = function(cmdStr, ...)
			cmdStr = cmdStr or ""
			local cmd = string.match(cmdStr, "^\"([^\"]+)\"")
			if not cmd then
				cmd = string.match(cmdStr, "^[^%s%c]+")
			end
			cmd = cmd or ""
			if IsConCommandBlocked(cmd) then
				ReportBlockedCommand(cmd)
			else
				oldGameConsoleCommand(cmdStr, ...)
				--[[local resultTab = {pcall(oldGameConsoleCommand, cmdStr, ...)}
				if not resultTab[1] then
					ReportBlockedCommand(cmd)
				end]]
			end
		end
		local PLAYER = FindMetaTable("Player")
		local oldConCommand = PLAYER.ConCommand
		PLAYER.ConCommand = function(self, cmdStr, ...)
			if IsValid(self) then
				cmdStr = cmdStr or ""
				local cmd = string.match(cmdStr, "^\"([^\"]+)\"")
				if not cmd then
					cmd = string.match(cmdStr, "^[^%s%c]+")
				end
				cmd = cmd or ""
				if IsConCommandBlocked(cmd) then
					ReportBlockedCommand(cmd)
				else
					oldConCommand(self, cmdStr, ...)
					--[[local resultTab = {pcall(oldConCommand, cmdStr, ...)}
					if not resultTab[1] then
						ReportBlockedCommand(cmd)
					end]]
				end
			end
		end
		
		ErrorNoHalt = function(...)
			--Log("ErrorNoHalt: ", ...)
		end
		Error = function(...)
			--Log("Error: ", ...)
		end
		
		Log("Console commands patched!")
	
		if SERVER then
			Log("Lua has been repaired! Remember that if you are a Lua developer, please disable this addon or your users may get errors from your code!")
		end
		if CLIENT then
			Log("Lua has been repaired! If you still see errors, remember to report the full error message to the creator of Lua Repair!")
		end
	end)
end

FixAllErrors()

--[[function SetAutoFix(bool)
	if bool then
		cookie.Delete("dont_lua_repair")
	else
		cookie.Set("dont_lua_repair", 1)
	end
end

function GetAutoFix()
	return not cookie.GetString("dont_lua_repair")
end

if GetAutoFix() then
	FixAllErrors()
end]]

if SERVER then util.AddNetworkString("lua_repair") end

if CLIENT then
	concommand.Add("lua_repair_run",function(ply,cmd,args,str)
		FixAllErrors()
		net.Start("lua_repair")
		net.SendToServer()
	end)
end

net.Receive("lua_repair",function()
	FixAllErrors()
end)

hook.Add("AddToolMenuCategories","lua_repair",function()
	spawnmenu.AddToolCategory("Utilities","lua_repair","Lua Repair")
end)

hook.Add("OnReloaded","lua_repair",function()
	if FIXED and CLIENT then
		chat.AddText(Color(255,0,0),"Make sure to turn off Lua Repair first before editing your Lua files!")
	end
end)

hook.Add("PopulateToolMenu","lua_repair",function()
	spawnmenu.AddToolMenuOption("Utilities","lua_repair","lua_repair","Lua Repair","","",function(DForm)
		local DLabel = DForm:Help("WARNING: If you are a Lua developer, or want to report an addon bug, make sure that this WHOLE addon is DISABLED before testing!")
		DLabel:SetTextColor(Color(255,0,0))
		DForm:CheckBox("Enable Error Logging", "lua_repair_logging")
		DForm:Button("Run Lua Repair","lua_repair_run")
		--[[local checkBoxLabel = vgui.Create("DCheckBoxLabel")
		checkBoxLabel:SetText("Run On Startup")
		checkBoxLabel:SetValue(GetAutoFix())
		function checkBoxLabel:OnChange(bool)
			SetAutoFix(bool)
		end
		DForm:AddItem(checkBoxLabel)]]
	end)
end)