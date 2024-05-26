--[[
Workshop:		https://steamcommunity.com/sharedfiles/filedetails/?id=2403043112
Profile Page:	https://steamcommunity.com/id/Piengineer12
GitHub Page:	https://github.com/Piengineer12/public-addons/tree/master/lua_patcher
Donate:			https://ko-fi.com/piengineer12

Links above are confirmed working as of 2022-05-26. All dates are in ISO 8601 format. 
]]

-- The + at the name of this Lua file is important so that it loads before most other Lua files on Windows
-- The ~ at the name of the other Lua file is important so that it loads before most other Lua files on Linux
if LUA_PATCHER_VERSION then return end

LUA_PATCHER_VERSION = "2.1.9"
LUA_PATCHER_VERSION_DATE = "2024-04-25"
LUA_REPAIR_VERSION = LUA_PATCHER_VERSION
LUA_REPAIR_VERSION_DATE = LUA_PATCHER_VERSION_DATE

local FIXED
local color_red = Color(255, 0, 0)
local color_aqua = Color(0, 255, 255)
local conVarLogging = CreateConVar("lua_patcher_logging", "0", FCVAR_ARCHIVED, "Enables Lua Patcher logging.")
local lastError = 0

local function Log(...)
	local message = {color_aqua, "[Lua Patcher ", SERVER and "Server] " or "Client] ", color_white, ...}
	table.insert(message, '\n')
	MsgC(unpack(message))
end

local function LogError(...)
	if conVarLogging:GetBool() and lastError < RealTime() and not string.find(debug.traceback(), "'pcall'") then
		lastError = RealTime() + 1
		local message = {color_aqua, "[Lua Patcher ", SERVER and "Server] " or "Client] ", color_white, ...}
		table.insert(message, '\n')
		MsgC(unpack(message))
		debug.Trace()
	end
end

-- aaand pretty much everything here is dangerous
local function FixAllErrors()
	if LUA_PATCHER_FIXED then return end
	Log("Loading Lua Patcher by Piengineer12, version "..LUA_PATCHER_VERSION.." ("..LUA_PATCHER_VERSION_DATE..")")
	
	Log("Patching primitives...")
	do
		local NIL = getmetatable(nil) or {}
		local NUMBER = getmetatable(0) or {}
		local STRING = getmetatable("") or {}
		local VECTOR = FindMetaTable("Vector")
		local ENTITY = FindMetaTable("Entity")
		local WEAPON = FindMetaTable("Weapon")
		local NPC = FindMetaTable("NPC")
		local PLAYER = FindMetaTable("Player")
		local CLUAEMITTER = FindMetaTable("CLuaEmitter")
		local NULL_META = getmetatable(NULL) or {}
		local PHYSOBJ = FindMetaTable("PhysObj")
		local CTAKEDAMAGEINFO = FindMetaTable("CTakeDamageInfo")
		local PHYSCOLLIDE = FindMetaTable("PhysCollide")
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
				LogError("Some code attempted to iterate over nothing.")
			end
			tab = tab or {}
			return oldPairs(tab, ...)
		end

		NUMBER.__lt = function(a,b)
			if not a or not b then
				LogError("Some code attempted to compare a number with nil.")
				return (a or 0) < (b or 0)
			else
				LogError("Some code attempted to see if a number is bigger or smaller than something else that isn't.")
				return tostring(a) < tostring(b)
			end
		end
		NUMBER.__le = function(a,b)
			if not a or not b then
				LogError("Some code attempted to compare a number with nil.")
				return (a or 0) <= (b or 0)
			else
				LogError("Some code attempted to see if a number is bigger or smaller than something else that isn't.")
				return tostring(a) <= tostring(b)
			end
		end
		
		STRING.__concat = function(a,b)
			if not (isstring(a) and isstring(b)) then
				LogError("Some code attempted to concatenate a string with something that isn't.")
			end
			return tostring(a)..tostring(b)
		end
		STRING.__add = function(a,b)
			if not tonumber(a) or not tonumber(b) then
				LogError("Some code attempted to add with a non-number string.")
				return (tonumber(a) or 0) + (tonumber(b) or 0)
			end
		end
		STRING.__lt = function(a,b)
			if not a or not b then
				LogError("Some code attempted to compare a string with nil.")
				return (a or 0) < (b or 0)
			else
				LogError("Some code attempted to see if a string is bigger or smaller than something else that isn't.")
				return tostring(a) < tostring(b)
			end
		end
		STRING.__le = function(a,b)
			if not a or not b then
				LogError("Some code attempted to compare a string with nil.")
				return (a or 0) <= (b or 0)
			else
				LogError("Some code attempted to see if a string is bigger or smaller than something else that isn't.")
				return tostring(a) <= tostring(b)
			end
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
		
		if debug.setmetatable then
			debug.setmetatable(nil, NIL)
		else
			Log("WARNING: debug.setmetatable is missing, nil CANNOT BE PATCHED!")
		end
	end
	Log("Primitives patched!")
	Log("Patching classes...")
	do
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
				LogError("Some code attempted to multiply a vector with something that is neither a vector nor a number.")
			end
			return oldmul(a or 1,b or 1)
		end
		VECTOR.__div = function(a,b)
			if not (isnumber(a) or isnumber(b) or isvector(a) and isvector(b)) then
				LogError("Some code attempted to divide a vector with something that is neither a vector nor a number.")
			end
			return olddiv(a or 1,b or 1)
		end

		-- redefining NULL to not error on index doesn't work because the error happens when the method is called
		-- the error somehow bypasses pcall too so...

		-- this doesn't work either and just subliminates RAM
		--[=[local oldFuncs = {}
		for k,v in pairs(ENTITY) do
			if isfunction(v) then
				oldFuncs[k] = v
			end
		end

		for k,v in pairs(oldFuncs) do
			ENTITY[k] = function(ent, ...)
				local ret = {pcall(v(ent, ...))}
				if ret[1] then
					return select(2, unpack(ret))
				else
					LogError(string.format("Method %s on entity %s failed: %s", tostring(k), tostring(ent), ret[2]))
					return nil
				end
			end
		end]=]
		
		local oldGC = ENTITY.GetClass
		ENTITY.GetClass = function(ent, ...)
			if not IsValid(ent) then
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
			if not IsValid(ent) then
				LogError("Some code attempted to lookup a bone of a NULL entity.")
				return -1
			end
			local retValues = {oldLookupBone(ent,name,...)}
			if retValues[1] then return unpack(retValues) end
			
			local retValues = {oldLookupBone(ent,isstring(name) and name:lower() or name,...)}
			if retValues[1] then
				LogError("Some code attempted to call Entity:LookupBone() without lowercased bone name.")
				return unpack(retValues)
			end
		end
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
		local oldSetBodyGroups = ENTITY.SetBodyGroups
		ENTITY.SetBodyGroups = function(ent, bodygroups, ...)
			if not bodygroups then
				LogError("Some code attempted to call Entity:SetBodyGroups() without valid string.")
			end
			return oldSetBodyGroups(ent, bodygroups or "", ...)
		end
		local oldSetColor = ENTITY.SetColor
		ENTITY.SetColor = function(ent, col, ...)
			if not IsValid(ent) then
				LogError("Some code attempted to set the color of a NULL entity.")
			elseif not istable(col) then
				LogError("Some code attempted to set the color of an entity with a non-table value.")
			else
				local useCol = col
				if not (col.r and col.g and col.b and col.a) then
					LogError("Some code attempted to set the color of an entity with an invalid table.")
					useCol = Color(tonumber(col.r) or 255, tonumber(col.g) or 255, tonumber(col.b) or 255, tonumber(col.a) or 255)
				end
				return oldSetColor(ent, useCol, ...)
			end
		end
		local oldSetColor4Part = ENTITY.SetColor4Part
		ENTITY.SetColor4Part = function(ent, r, g, b, a, ...)
			if not IsValid(ent) then
				LogError("Some code attempted to set the color of a NULL entity.")
			else
				return oldSetColor4Part(ent, r, g, b, a, ...)
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
		local oldEmitSound = ENTITY.EmitSound
		ENTITY.EmitSound = function(ent, soundName, ...)
			if isstring(soundName) then
				return oldEmitSound(ent, soundName, ...)
			else
				LogError("Some code attempted to call EmitSound on an entity with non-string sound name.")
			end
		end
		local oldPhysicsFromMesh = ENTITY.PhysicsFromMesh
		ENTITY.PhysicsFromMesh = function(ent, mesh, ...)
			if istable(mesh) then
				return oldPhysicsFromMesh(ent, mesh, ...)
			else
				LogError("Some code attempted to call PhysicsFromMesh with invalid first argument type.")
			end
		end
		local oldPhysicsInit = ENTITY.PhysicsInit
		ENTITY.PhysicsInit = function(ent, solidType, ...)
			-- errors that happen from this resist pcall, classic...

			if solidType == SOLID_NONE then
				-- take a while to remove the physics object if it exists
				local vars = {...}
				timer.Simple(0, function()
					if (IsValid(ent) and IsValid(ent:GetPhysicsObject())) then
						oldPhysicsInit(ent, solidType, unpack(vars))
						-- below causes issues with iv04 star wars nextbots
						--ent:PhysicsDestroy()
					end
				end)
				return true
			else
				return oldPhysicsInit(ent, solidType, ...)
			end
		end

		local nwToOverride = {
			Angle = angle_zero,
			Bool = false,
			Entity = NULL,
			Float = 0,
			Int = 0,
			String = ""
		}
		local oldNWFuncs = {Set = {}, Get = {}}
		for k,v in pairs(nwToOverride) do
			local setFuncName = "SetNW"..k
			oldNWFuncs.Set[k] = ENTITY[setFuncName]
			ENTITY[setFuncName] = function(ent, ...)
				if not IsValid(ent) then
					LogError("Some code attempted to call "..setFuncName.." on a NULL entity.")
				else return oldNWFuncs.Set[k](ent, ...)
				end
			end

			local getFuncName = "GetNW"..k
			oldNWFuncs.Get[k] = ENTITY[getFuncName]
			ENTITY[getFuncName] = function(ent, ...)
				if not IsValid(ent) then
					LogError("Some code attempted to call "..getFuncName.." on a NULL entity.")
					return v
				else return oldNWFuncs.Get[k](ent, ...)
				end
			end
		end

		local oldGetPrintName = WEAPON.GetPrintName
		WEAPON.GetPrintName = function(ent, ...)
			if not IsValid(ent) then
				LogError("Some code attempted to get the print name of a NULL weapon.")
				return tostring(ent)
			else return oldGetPrintName(ent, ...)
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
		local oldEnableGravity = PHYSOBJ.EnableGravity
		PHYSOBJ.EnableGravity = function(physObj, ...)
			if IsValid(physObj) then
				return oldEnableGravity(physObj, ...)
			else
				LogError("Some code attempted to toggle the gravity of a NULL physics object.")
			end
		end
		local oldEnableMotion = PHYSOBJ.EnableMotion
		PHYSOBJ.EnableMotion = function(physObj, ...)
			if IsValid(physObj) then
				return oldEnableMotion(physObj, ...)
			else
				LogError("Some code attempted to freeze or unfreeze a NULL physics object.")
			end
		end
		local oldSetVelocity = PHYSOBJ.SetVelocity
		PHYSOBJ.SetVelocity = function(physObj, ...)
			if IsValid(physObj) then
				return oldSetVelocity(physObj, ...)
			else
				LogError("Some code attempted to set the velocity of a NULL physics object.")
			end
		end
		local oldTraceBox = PHYSCOLLIDE.TraceBox
		PHYSCOLLIDE.TraceBox = function(physCollide, origin, ...)
			if not origin then
				LogError("Some code attempted to call TraceBox without box origin.")
				return false
			end
			return oldTraceBox(physCollide, origin, ...)
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
	end
	Log("Classes patched!")
	Log("Patching libraries...")
	do
		-- this will break other addons if enabled
		--[[local oldAddCSLuaFile = AddCSLuaFile
		function AddCSLuaFile(...)
			local retValues = {pcall(oldAddCSLuaFile, ...)}
			if retValues[1] then
				return select(2, unpack(retValues))
			else
				LogError("Caught an AddCSLuaFile error: "..retValues[2])
			end
		end]]

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
			if not isstring(helptext) then
				helptext = tostring(helptext)
				LogError("Some code attempted to call CreateConVar with non-string help text.")
			end
			return oldCreateConVar(name, default, flags, helptext, min, max, ...)
		end

		local oldEmitSound = EmitSound
		function EmitSound(soundName, ...)
			if isstring(soundName) then
				return oldEmitSound(soundName, ...)
			else
				LogError("Some code attempted to call EmitSound with non-string sound name.")
			end
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
				net.Abort()
				LogError("Some code attempted to call net.Start without finishing the previous net message.")
			end

			local retValues = {pcall(oldNetStart, ...)}
			if retValues[1] then
				return select(2, unpack(retValues))
			else
				LogError("Caught a net.Start error: "..retValues[2])
				return oldNetStart("lua_patcher")
			end
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
		
		local oldVguiCreate = vgui.Create
		function vgui.Create(pnl, parent, ...)
			if not ispanel(parent) and parent ~= nil then
				LogError("Some code attempted to parent a panel to a non-panel.")
				parent = nil
			end
			return oldVguiCreate(pnl, parent, ...)
		end
		
		if CLIENT then
			local oldCreateParticleSystem = CreateParticleSystem
			function CreateParticleSystem(ent, effect, partAttachment, entAttachment, offset)
				if not isvector(offset) then
					offset = Vector(0, 0, 0)
					LogError("Some code attempted to call CreateParticleSystem with an invalid offset argument.")
				end
				return oldCreateParticleSystem(ent, effect, partAttachment, entAttachment, offset)
			end

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

			local oldSurfaceSetFont = surface.SetFont
			function surface.SetFont(font, ...)
				local retValues = {pcall(oldSurfaceSetFont, font, ...)}
				if retValues[1] then
					return select(2, unpack(retValues))
				else
					LogError("Caught a surface.SetFont error: "..retValues[2])
					return oldSurfaceSetFont("Default")
				end
			end

			local oldDynamicLight = DynamicLight
			function DynamicLight(index, ...)
				if not index then
					LogError("Some code attempted to call DynamicLight without index.")
					index = 0
				end
				return oldDynamicLight(index, ...)
			end
		end
	end
	Log("Libraries patched!")
	Log("Patching hooks...")
	do
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
		local oldHookRemove = hook.Remove
		function hook.Remove(event_name, name, ...)
			if isfunction(event_name) then
				event_name = util.CRC(string.dump(event_name))
				LogError("Some code attempted to call hook.Remove() with function as first argument.")
			end
			if isfunction(name) then
				name = util.CRC(string.dump(name))
				LogError("Some code attempted to call hook.Remove() with function as second argument.")
			elseif isnumber(name) and not DLib then
				name = tostring(name)
				LogError("Some code attempted to call hook.Remove() with number as second argument.")
			elseif isbool(name) then
				name = tostring(name)
				LogError("Some code attempted to call hook.Remove() with boolean as second argument.")
			end
			
			if isstring(event_name) then
				local valid = DLib and type(name) == "thread" or name.IsValid or IsValid(name)
				if isstring(name) or valid then
					oldHookRemove(event_name, name, ...)
				else
					LogError("Some code attempted to call hook.Remove() with invalid second argument.")
				end
			end
		end
	end
	Log("Hooks patched!")
	LUA_PATCHER_FIXED = true
	
	Log("Waiting for all other addons to load...")
	local startWaitTime = SysTime()
	timer.Simple(0,function()
		Log(string.format("Waited %.2f seconds. Hopefully all other addons have initialized by now.", SysTime()-startWaitTime))
		Log("Patching console commands...")
		
		local function ReportBlockedCommand(cmd)
			LogError("An addon tried to use the console command "..cmd.." which is not allowed.")
		end
		
		local oldRunConsoleCommand = RunConsoleCommand
		RunConsoleCommand = function(cmd, ...)
			cmd = string.gsub(cmd or "", "[%c%s]+", "")
			if IsConCommandBlocked(cmd) or #cmd < 2 then
				ReportBlockedCommand(cmd)
			else
				oldRunConsoleCommand(cmd, ...)
			end
		end
		local oldGameConsoleCommand = game.ConsoleCommand
		game.ConsoleCommand = function(cmdStr, ...)
			cmdStr = cmdStr or ""
			local cmd = string.match(cmdStr, "^\"([^\"]+)\"")
			if not cmd then
				cmd = string.match(cmdStr, "^[^%s%c]+")
			end
			cmd = string.gsub(cmd or "", "%c", " ")
			if IsConCommandBlocked(cmd) then
				ReportBlockedCommand(cmd)
			else
				oldGameConsoleCommand(cmdStr, ...)
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
				cmd = string.gsub(cmd or "", "%c", " ")
				if IsConCommandBlocked(cmd) then
					ReportBlockedCommand(cmd)
				else
					oldConCommand(self, cmdStr, ...)
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
			Log("Lua has been patched! Remember that if you are a Lua developer, please disable this addon or your users may get errors from your code!")
		end
		if CLIENT then
			Log("Lua has been patched! Remember that if you are a Lua developer, please disable this addon or your users may get errors from your code!")
		end
	end)
end

FixAllErrors()

if SERVER then util.AddNetworkString("lua_patcher") end

if CLIENT then
	concommand.Add("lua_patcher_run",function(ply,cmd,args,str)
		FixAllErrors()
		net.Start("lua_patcher")
		net.SendToServer()
	end)
end

net.Receive("lua_patcher",function()
	FixAllErrors()
end)

hook.Add("AddToolMenuCategories","lua_patcher",function()
	spawnmenu.AddToolCategory("Utilities","lua_patcher","Lua Patcher")
end)

hook.Add("OnReloaded","lua_patcher",function()
	if FIXED and CLIENT then
		chat.AddText(color_red,"Remember to turn off Lua Patcher first before editing your Lua files!")
	end
end)

hook.Add("PopulateToolMenu","lua_patcher",function()
	spawnmenu.AddToolMenuOption("Utilities","lua_patcher","lua_patcher","Lua Patcher","","",function(DForm)
		local DLabel = DForm:Help("WARNING: If you are a Lua developer, or want to report an addon bug, make sure that this WHOLE addon is DISABLED before testing!")
		DLabel:SetTextColor(color_red)
		DForm:CheckBox("Enable Error Logging", "lua_patcher_logging")
		DForm:Button("Run Lua Patcher","lua_patcher_run")
	end)
end)