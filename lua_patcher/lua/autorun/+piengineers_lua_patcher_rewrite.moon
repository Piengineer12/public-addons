export LUA_PATCHER
LUA_PATCHER or= {
    workshop_page: "https://steamcommunity.com/sharedfiles/filedetails/?id=2403043112"
    profile_page: "https://steamcommunity.com/id/Piengineer12"
    github_page: "https://github.com/Piengineer12/public-addons/tree/master/lua_patcher"
    donate_page: "https://ko-fi.com/piengineer12"
    extra_info: "Links above are confirmed working as of 2022-05-26. All dates are in ISO 8601 format."
    unpatched: {}
}

LUA_PATCHER.VERSION = "3.0.6-rc.1"
LUA_PATCHER.VERSION_DATE = "2025-03-19"

local Log, LogError

if gmod
    next_report_time = 0
    color_red = Color 255, 0, 0
    color_aqua = Color 0, 255, 255

    util.AddNetworkString "lua_patcher" if SERVER

    hook.Add "AddToolMenuCategories", "lua_patcher", ->
        spawnmenu.AddToolCategory "Utilities", "lua_patcher", "Lua Patcher"
        return

    hook.Add "OnReloaded", "lua_patcher", ->
        if LUA_PATCHER.FIXED and CLIENT
            chat.AddText color_red, "Remember to turn off Lua Patcher first before editing your Lua files!"
        return

    hook.Add "PopulateToolMenu", "lua_patcher", ->
        spawnmenu.AddToolMenuOption "Utilities",
            "lua_patcher", "lua_patcher", "Lua Patcher",
            "", "", (DForm) ->
                DLabel = DForm\Help "WARNING: If you are a Lua developer, or want to report an addon bug, "..
                "make sure that this WHOLE addon is DISABLED before testing!"
                DLabel\SetTextColor color_red
                DForm\CheckBox "Enable Lua Patcher", "lua_patcher_enable"
                DForm\CheckBox "Enable Error Logging", "lua_patcher_logging"
                return
        return

    ConVarLogging = CreateConVar "lua_patcher_logging",
        "0",
        FCVAR_ARCHIVED,
        "Enables Lua Patcher logging."

    Log = (...) ->
        message = {
            color_aqua
            "[Lua Patcher "
            if SERVER then "Server] " else "Client] "
            color_white
            string.format(...)
            "\n"
        }

        MsgC unpack message

    LogError = (...) ->
        real_time = RealTime!
        if ConVarLogging\GetBool! and next_report_time < real_time and not string.find debug.traceback!, "'pcall'"
            next_report_time = real_time + 1
            Log ...
            debug.Trace!
else
    -- ...be agnostic!
    Log = (...) -> print "[Lua Patcher] #{string.format ...}"
    LogError = (...) -> print debug.traceback "[Lua Patcher] #{string.format ...}", 2

OverwriteTable = (table_name, table_contents, new_table_contents) ->
    LUA_PATCHER.unpatched[table_name] or= {}
    target_table = LUA_PATCHER.unpatched[table_name]
    target_table[k] = table_contents[k] or true for k, v in pairs new_table_contents
    table_contents[k] = v for k, v in pairs new_table_contents

RollbackTable = (table_name, table_contents) ->
    for k, v in pairs LUA_PATCHER.unpatched[table_name]
        table_contents[k] = if v == true then nil else v


OverwriteFunction = (func_name, func_body) ->
    LUA_PATCHER.unpatched[func_name] = _G[func_name]
    _G[func_name] = func_body

RollbackFunction = (func_name) ->
    _G[func_name] = LUA_PATCHER.unpatched[func_name]

PatchPrimitives = ->
	NIL = getmetatable(nil) or {}
    OverwriteTable "NIL", NIL, {
        __add: (a, b) ->
            LogError "Some code attempted to add with nil."
            a or b
        __sub: (a, b) ->
            LogError "Some code attempted to subtract with nil."
            a or -b
        __mul: (a, b) ->
            LogError "Some code attempted to multiply with nil."
            a or b
        __div: (a, b) ->
            LogError "Some code attempted to divide with nil."
            a
        __pow: (a, b) ->
            LogError "Some code attempted to raise something to a power with nil."
            if b then nil else a
        __unm: (a) ->
            LogError "Some code attempted to negate nil."
            a
        __concat: (a, b) ->
            LogError "Some code attempted to concatenate with nil."
            tostring(a) .. tostring(b)
        __len: (a) ->
            LogError "Some code attempted to get the length of nil."
            0
        __lt: (a, b) ->
            LogError "Some code attempted to see if something is bigger or smaller than nil."
            if type(a) == "number" or type(b) == "number"
                (a or 0) < (b or 0)
            else
                tostring(a) < tostring(b)
        __le: (a, b) ->
            LogError "Some code attempted to see if something is bigger or smaller than nil."
            if type(a) == "number" or type(b) == "number"
                (a or 0) <= (b or 0)
            else
                tostring(a) <= tostring(b)
        __index: -> LogError "Some code attempted to index nil."
        __newindex: -> LogError "Some code attempted to assign a member value to nil."
        __call: -> LogError "Some code attempted to call nil as a function."
    }
	BOOL = getmetatable(true) or {}
    OverwriteTable "BOOL", BOOL, {
        __index: -> LogError "Some code attempted to index a boolean."
        __newindex: -> LogError "Some code attempted to assign a member value to a boolean."
        __call: -> LogError "Some code attempted to call a boolean as a function."
    }
	
    OverwriteFunction "pairs", (tab, ...) ->
        if not tab
            tab = {}
            LogError "Some code attempted to iterate over nothing."
        elseif type(tab) == "number"
            -- TODO: is this actually supposed to mean {[1]: 1, [2]: 2, ..., [tab]: tab}?
            tab = {}
            LogError "Some code attempted to iterate over a number."
        LUA_PATCHER.unpatched.pairs tab, ...

	NUMBER = getmetatable(0) or {}
    OverwriteTable "NUMBER", NUMBER, {
        __lt: (a, b) ->
            if a and b
				LogError "Some code attempted to see if a number is bigger or smaller than something else that isn't."
				tostring(a) < tostring(b)
			else
				LogError "Some code attempted to compare a number with nil."
				(a or 0) < (b or 0)
        __le: (a, b) ->
			if a and b
				LogError "Some code attempted to see if a number is bigger or smaller than something else that isn't."
				tostring(a) <= tostring(b)
			else
				LogError "Some code attempted to compare a number with nil."
				(a or 0) <= (b or 0)
    }

	STRING = getmetatable("") or {}
    OverwriteTable "STRING", STRING, {
        __concat: (a, b) ->
			unless type(a) == "string" and type(b) == "string"
				LogError "Some code attempted to concatenate a string with something that isn't."
		    tostring(a) .. tostring(b)
        __add: (a, b) ->
			unless tonumber(a) and tonumber(b)
				LogError "Some code attempted to add two strings where at least one isn't a number."
				(tonumber(a) or 0) + (tonumber(b) or 0)
        __lt: (a, b) ->
			if a and b
				LogError "Some code attempted to see if a string is bigger or smaller than something else that isn't."
				tostring(a) < tostring(b)
			else
				LogError "Some code attempted to compare a string with nil."
				(a or 0) < (b or 0)
        __le: (a, b) ->
			if a and b
				LogError "Some code attempted to see if a string is bigger or smaller than something else that isn't."
				tostring(a) <= tostring(b)
			else
				LogError "Some code attempted to compare a string with nil."
				(a or 0) <= (b or 0)
    }
	
    if debug.setmetatable
        debug.setmetatable nil, NIL
        debug.setmetatable true, BOOL
        debug.setmetatable 0, NUMBER
        debug.setmetatable "", STRING
    else
        Log "WARNING: debug.setmetatable is missing, many primitives cannot be patched!"

UnpatchPrimitives = ->
	NIL = getmetatable(nil) or {}
    RollbackTable "NIL", NIL

	BOOL = getmetatable(true) or {}
    RollbackTable "BOOL", BOOL

    RollbackFunction "pairs"

    NUMBER = getmetatable(0) or {}
    RollbackTable "NUMBER", NUMBER

	STRING = getmetatable("") or {}
    RollbackTable "STRING", STRING

    if debug.setmetatable
        debug.setmetatable nil, NIL
        debug.setmetatable true, BOOL
        debug.setmetatable 0, NUMBER
        debug.setmetatable "", STRING

PatchLibraries = ->
    OverwriteFunction "CreateClientConVar", (name, default, shouldsave, userinfo, helptext, min, max, ...) ->
        if min and not isnumber min
            LogError "Some code attempted to call CreateClientConVar with non-number min argument."
            min = nil
        if max and not isnumber max
            LogError "Some code attempted to call CreateClientConVar with non-number max argument."
            max = nil
        LUA_PATCHER.unpatched.CreateClientConVar name, default, shouldsave, userinfo, helptext, min, max, ...
    
    OverwriteFunction "CreateConVar", (name, default, flags, helptext, min, max, ...) ->
        if min and not isnumber min
            LogError "Some code attempted to call CreateConVar with non-number min argument."
            min = nil
        if max and not isnumber max
            LogError "Some code attempted to call CreateConVar with non-number max argument."
            max = nil
        unless isstring helptext
            helptext = tostring helptext
            LogError "Some code attempted to call CreateConVar with non-string help text."
        LUA_PATCHER.unpatched.CreateConVar name, default, flags, helptext, min, max, ...
    
    OverwriteFunction "EmitSound", (soundName, ...) ->
        if isstring soundName
            LUA_PATCHER.unpatched.EmitSound soundName, ...
        else
            LogError "Some code attempted to call EmitSound with non-string sound name."
    
    OverwriteFunction "CreateParticleSystem", (ent, effect, partAttachment, entAttachment, offset, ...) ->
        unless isvector offset
            offset = Vector 0, 0, 0
            LogError "Some code attempted to call CreateParticleSystem with an invalid offset argument."
        LUA_PATCHER.unpatched.CreateParticleSystem ent, effect, partAttachment, entAttachment, offset, ...
    
    OverwriteFunction "DynamicLight", (index, ...) ->
        unless index
            LogError "Some code attempted to call DynamicLight without index."
            index = 0
        LUA_PATCHER.unpatched.DynamicLight index, ...

    OverwriteTable "string", string, {
        Explode: (separator, str, ...) ->
            unless separator and str
                LogError "Some code attempted to explode a string without providing string separator or haystack."
            LUA_PATCHER.unpatched.string.Explode separator or "", str or "", ...
    }

    OverwriteTable "ents", ents, {
        FindInSphere: (origin, radius, ...) ->
			unless origin
				LogError "Some code attempted to call ents.FindInSphere without a sphere center."
				origin = vector_origin
			unless radius
				LogError "Some code attempted to call ents.FindInSphere without a radius."
				radius = 0
			LUA_PATCHER.unpatched.ents.FindInSphere origin, radius, ...
    }

    OverwriteTable "net", net, {
        Start: (...) ->
			if net.BytesWritten!
				net.Abort!
				LogError "Some code attempted to call net.Start without finishing the previous net message."

			retValues = {pcall LUA_PATCHER.unpatched.net.Start, ...}
			if retValues[1]
				select 2, unpack retValues
			else
				LogError "Caught a net.Start error: %s", retValues[2]
				LUA_PATCHER.unpatched.net.Start "lua_patcher"
        
        WriteString: (str, ...) ->
			if not str
                str = ""
				LogError "Some code attempted to call net.WriteString without providing a string."
            elseif not isstring str
                str = tostring str
				LogError "Some code attempted to call net.WriteString with a non-string value."
			LUA_PATCHER.unpatched.net.WriteString str, ...
    }

    OverwriteTable "util", util, {
        IsValidModel: (model, ...) ->
			unless isstring model
				LogError "Some code attempted to call util.IsValidModel with an invalid argument."
				model = tostring model
			LUA_PATCHER.unpatched.util.IsValidModel model, ...
    }

    OverwriteTable "vgui", vgui, {
        Create: (pnl, parent, ...) ->
			if parent ~= nil and not ispanel parent
				LogError "Some code attempted to parent a panel to a non-panel."
				parent = nil
			LUA_PATCHER.unpatched.vgui.Create pnl, parent, ...
    }

    OverwriteTable "bit", bit, {
        band: (value, ...) ->
            unless value
                LogError "Some code attempted to call bit.band without any arguments."
            LUA_PATCHER.unpatched.bit.band(value or 0, ...)
        bor: (value, ...) ->
            unless value
                LogError "Some code attempted to call bit.bor without any arguments."
            LUA_PATCHER.unpatched.bit.bor(value or 0, ...)
    }

    OverwriteTable "input", input, {
        IsKeyDown: (key, ...) ->
            if key
                LUA_PATCHER.unpatched.input.IsKeyDown(key, ...)
            else
                LogError "Some code attempted to call input.IsKeyDown without specifying a key."
                false
    }

    OverwriteTable "language", language, {
        Add: (key, value, ...) ->
            if not key
                LogError "Some code attempted to call language.Add without specifying a language key."
            elseif not value
                LogError "Some code attempted to call language.Add without specifying a language value."
            else
                LUA_PATCHER.unpatched.language.Add key, value, ...
    }

    OverwriteTable "surface", surface, {
        SetFont: (font, ...) ->
            retValues = {pcall LUA_PATCHER.unpatched.surface.SetFont, font, ...}
            if retValues[1]
                select 2, unpack retValues
            else
                LogError "Caught a surface.SetFont error: %s", retValues[2]
                LUA_PATCHER.unpatched.surface.SetFont "Default"
    }

UnpatchLibraries = ->
    RollbackFunction "CreateClientConVar"
    RollbackFunction "CreateConVar"
    RollbackFunction "EmitSound"
    RollbackFunction "CreateParticleSystem"
    RollbackFunction "DynamicLight"
    RollbackTable "string", string
    RollbackTable "ents", ents
    RollbackTable "net", net
    RollbackTable "util", util
    RollbackTable "vgui", vgui
    RollbackTable "input", input
    RollbackTable "language", language
    RollbackTable "surface", surface

PatchClasses = ->
	VECTOR = FindMetaTable "Vector"
    OverwriteTable "VECTOR", VECTOR, {
        __add: (a, b) ->
			unless isvector(a) and isvector(b)
				LogError "Some code attempted to add a vector with something that isn't."
			LUA_PATCHER.unpatched.VECTOR.__add(
                if isvector a then a else Vector(a),
                if isvector b then b else Vector(b)
            )
        __sub: (a, b) ->
			unless isvector(a) and isvector(b)
				LogError "Some code attempted to subtract a vector with something that isn't."
			LUA_PATCHER.unpatched.VECTOR.__sub(
                if isvector a then a else Vector(a),
                if isvector b then b else Vector(b)
            )
        __mul: (a, b) ->
			unless isnumber(a) or isnumber(b) or isvector(a) and isvector(b)
				LogError "Some code attempted to multiply a vector with something that is neither a vector nor a number."
			LUA_PATCHER.unpatched.VECTOR.__mul(a or 1, b or 1)
        __div: (a, b) ->
			unless isnumber(a) or isnumber(b) or isvector(a) and isvector(b)
				LogError "Some code attempted to divide a vector with something that is neither a vector nor a number."
			LUA_PATCHER.unpatched.VECTOR.__div(a or 1, b or 1)
    }

	VMATRIX = FindMetaTable "VMatrix"
    OverwriteTable "VMATRIX", VMATRIX, {
        __add: (a, b) ->
			unless ismatrix(a) and ismatrix(b)
				LogError "Some code attempted to add a matrix with something that isn't."
			LUA_PATCHER.unpatched.VMATRIX.__add(
                if ismatrix a then a else Matrix({
                    {0, 0, 0, 0}
                    {0, 0, 0, 0}
                    {0, 0, 0, 0}
                    {0, 0, 0, 0}
                }),
                if ismatrix b then b else Matrix({
                    {0, 0, 0, 0}
                    {0, 0, 0, 0}
                    {0, 0, 0, 0}
                    {0, 0, 0, 0}
                })
            )
        __sub: (a, b) ->
			unless ismatrix(a) and ismatrix(b)
				LogError "Some code attempted to subtract a matrix with something that isn't."
			LUA_PATCHER.unpatched.VMATRIX.__sub(
                if ismatrix a then a else Matrix({
                    {0, 0, 0, 0}
                    {0, 0, 0, 0}
                    {0, 0, 0, 0}
                    {0, 0, 0, 0}
                }),
                if ismatrix b then b else Matrix({
                    {0, 0, 0, 0}
                    {0, 0, 0, 0}
                    {0, 0, 0, 0}
                    {0, 0, 0, 0}
                })
            )
        __mul: (a, b) ->
			unless isvector(a) or isvector(b) or ismatrix(a) and ismatrix(b)
				LogError "Some code attempted to multiply a matrix with something that is neither a matrix nor a vector."
			LUA_PATCHER.unpatched.VMATRIX.__mul(a or Matrix(a), b or Matrix(b))
    }

    new_entity_metatable = {
        GetClass: (...) =>
			if NULL == @
				LogError "Some code attempted to get the class of a NULL entity."
				"[NULL Entity]"
			else
                LUA_PATCHER.unpatched.ENTITY.GetClass @, ...
        SetPos: (...) =>
			if NULL == @
				LogError "Some code attempted to set the position of a NULL entity."
			else
                LUA_PATCHER.unpatched.ENTITY.SetPos @, ...
        GetPos: (...) =>
			if NULL == @
				LogError "Some code attempted to get the position of a NULL entity."
                vector_origin
			else
                LUA_PATCHER.unpatched.ENTITY.GetPos @, ...
        SetAngles: (...) =>
			if NULL == @
				LogError "Some code attempted to set the angles of a NULL entity."
			else
                LUA_PATCHER.unpatched.ENTITY.SetAngles @, ...
        LookupAttachment: (...) =>
			if NULL == @
				LogError "Some code attempted to lookup an attachment of a NULL entity."
				-1
			else
                LUA_PATCHER.unpatched.ENTITY.LookupAttachment @, ...
        SetColor4Part: (...) =>
			if NULL == @
				LogError "Some code attempted to set the color of a NULL entity."
			else
				LUA_PATCHER.unpatched.ENTITY.SetColor4Part @, ...
        GetBoneCount: (...) =>
			if NULL == @
				LogError "Some code attempted to get the number of bones of a NULL entity."
				0
			else
                LUA_PATCHER.unpatched.ENTITY.GetBoneCount @, ...
        Spawn: (...) =>
			if NULL == @
				LogError "Some code attempted to spawn a NULL entity."
			else
                LUA_PATCHER.unpatched.ENTITY.Spawn @, ...
        Activate: (...) =>
			if NULL == @
				LogError "Some code attempted to activate a NULL entity."
			else
                LUA_PATCHER.unpatched.ENTITY.Activate @, ...
        Remove: (...) =>
			if NULL == @
				LogError "Some code attempted to remove a NULL entity."
			else
                LUA_PATCHER.unpatched.ENTITY.Remove @, ...
        GetPhysicsObject: (...) =>
			if NULL == @
				LogError "Some code attempted to get the physics object of a NULL entity."
			else
                LUA_PATCHER.unpatched.ENTITY.GetPhysicsObject @, ...
        GetBonePosition: (boneIndex, ...) =>
			unless boneIndex
				LogError "Some code attempted to call Entity:GetBonePosition() without valid bone index."
			LUA_PATCHER.unpatched.ENTITY.GetBonePosition @, boneIndex or 0, ...
        LookupBone: (name, ...) =>
			if NULL == @
				LogError "Some code attempted to lookup a bone of a NULL entity."
				return -1
            
			retValues = {LUA_PATCHER.unpatched.ENTITY.LookupBone @, name, ...}
			if retValues[1] then return unpack retValues
			
			retValues = {LUA_PATCHER.unpatched.ENTITY.LookupBone @, isstring(name) and name\lower! or name, ...}
			if retValues[1]
				LogError "Some code attempted to call Entity:LookupBone() without lowercased bone name."
				unpack retValues
        SetPhysicsAttacker: (attacker, ...) =>
			if NULL == @
				LogError "Some code attempted to set the physics attacker of a NULL entity."
			elseif attacker\IsPlayer!
                if LUA_PATCHER.unpatched.ENTITY.SetPhysicsAttacker
                    LUA_PATCHER.unpatched.ENTITY.SetPhysicsAttacker @, attacker, ...
			else
				LogError "Some code attempted to set the physics attacker of an entity to a non-player."
        SetBodyGroups: (bodygroups, ...) =>
			unless bodygroups
				LogError "Some code attempted to call Entity:SetBodyGroups() without valid string."
			LUA_PATCHER.unpatched.ENTITY.SetBodyGroups @, bodygroups or "", ...
        SetColor: (col, ...) =>
			if NULL == @
				LogError "Some code attempted to set the color of a NULL entity."
			elseif not istable col
				LogError "Some code attempted to set the color of an entity with a non-table value."
			else
				useCol = col
				unless col.r and col.g and col.b and col.a
					LogError "Some code attempted to set the color of an entity with an invalid table."
					useCol = Color(
                        tonumber(col.r) or 255,
                        tonumber(col.g) or 255,
                        tonumber(col.b) or 255,
                        tonumber(col.a) or 255
                    )
				LUA_PATCHER.unpatched.ENTITY.SetColor @, useCol, ...
        SetSkin: (skin, ...) =>
            if skin
			    LUA_PATCHER.unpatched.ENTITY.SetSkin @, skin, ...
            else
				LogError "Some code attempted to set the skin of an entity to nil."
        EmitSound: (soundName, ...) =>
			if isstring soundName
				LUA_PATCHER.unpatched.ENTITY.EmitSound @, soundName, ...
			else
				LogError "Some code attempted to call EmitSound on an entity with non-string sound name."
        PhysicsFromMesh: (mesh, ...) =>
			if istable mesh then
				LUA_PATCHER.unpatched.ENTITY.PhysicsFromMesh @, mesh, ...
			else
				LogError "Some code attempted to call PhysicsFromMesh with non-table mesh."
        PhysicsInit: (solidType, ...) =>
			-- errors that happen from this resist pcall, classic...

			if solidType == SOLID_NONE
				-- capture arguments since ... becomes invalid
				vars = {...}
				-- take a while to remove the physics object if it exists
				timer.Simple 0, ->
					if (NULL ~= @ and IsValid @GetPhysicsObject!)
						-- @PhysicsDestroy! causes issues with iv04 star wars nextbots
						LUA_PATCHER.unpatched.ENTITY.PhysicsInit @, solidType, unpack vars
				true
			else
				LUA_PATCHER.unpatched.ENTITY.PhysicsInit @, solidType, ...
        SetAnimation: (...) =>
			if NULL == @
				LogError "Some code attempted to set the animation of a NULL entity."
			else
                LUA_PATCHER.unpatched.ENTITY.SetAnimation @, ...
    }

    nw_override_table = {
        Angle: angle_zero
        Bool: false
        Entity: NULL
        Float: 0
        Int: 0
        String: ""
    }
    for k, v in pairs nw_override_table
        set_func_name = "SetNW"..k
        new_entity_metatable[set_func_name] = (...) =>
            if NULL == @
                LogError "Some code attempted to call #{set_func_name} on a NULL entity."
            else
                LUA_PATCHER.unpatched.ENTITY[set_func_name](@, ...)
        
        get_func_name = "GetNW"..k
        new_entity_metatable[get_func_name] = (...) =>
            if NULL == @
                LogError "Some code attempted to call #{get_func_name} on a NULL entity."
                v
            else
                LUA_PATCHER.unpatched.ENTITY[get_func_name](@, ...)

	ENTITY = FindMetaTable "Entity"
    OverwriteTable "ENTITY", ENTITY, new_entity_metatable

    WEAPON = FindMetaTable "Weapon"
    OverwriteTable "WEAPON", WEAPON, {
        GetPrintName: (...) =>
			if NULL == @
                LUA_PATCHER.unpatched.WEAPON.GetPrintName @, ...
			else
				LogError "Some code attempted to get the print name of a NULL weapon."
				tostring @
    }

    NPC = FindMetaTable "NPC"
    OverwriteTable "NPC", NPC, {
        GetEnemy: (...) =>
			if NULL == @
				LUA_PATCHER.unpatched.NPC.GetEnemy @, ...
			else
				LogError "Some code attempted to get the enemy of a NULL NPC."
        SelectWeapon: (class_name, ...) =>
			unless class_name
				class_name = ""
				LogError "Some code did not specify which weapon an NPC should hold."
			LUA_PATCHER.unpatched.NPC.SelectWeapon @, class_name, ...
    }

    PLAYER = FindMetaTable "Player"
    OverwriteTable "PLAYER", PLAYER, {
        GetCurrentCommand: (...) =>
			if @ == GetPredictionPlayer!
                LUA_PATCHER.unpatched.PLAYER.GetCurrentCommand @, ...
			else
                LogError "Some code attempted to call Player:GetCurrentCommand() "..
                "on a player with no commands currently being processed."
        SelectWeapon: (class_name, ...) =>
			unless class_name
				class_name = ""
				LogError "Some code did not specify which weapon a player should hold."
			LUA_PATCHER.unpatched.PLAYER.SelectWeapon @, class_name, ...
    }

	PHYSOBJ = FindMetaTable "PhysObj"
    OverwriteTable "PHYSOBJ", PHYSOBJ, {
        Wake: (...) =>
			if IsValid @ then
				LUA_PATCHER.unpatched.PHYSOBJ.Wake @, ...
			else
				LogError "Some code attempted to wake a NULL physics object."
        EnableGravity: (...) =>
			if IsValid @ then
				LUA_PATCHER.unpatched.PHYSOBJ.EnableGravity @, ...
			else
				LogError "Some code attempted to toggle the gravity of a NULL physics object."
        EnableMotion: (...) =>
			if IsValid @ then
				LUA_PATCHER.unpatched.PHYSOBJ.EnableMotion @, ...
			else
				LogError "Some code attempted to freeze or unfreeze a NULL physics object."
        SetVelocity: (...) =>
			if IsValid @ then
				LUA_PATCHER.unpatched.PHYSOBJ.SetVelocity @, ...
			else
				LogError "Some code attempted to set the velocity of a NULL physics object."
    }

	PHYSCOLLIDE = FindMetaTable "PhysCollide"
    OverwriteTable "PHYSCOLLIDE", PHYSCOLLIDE, {
        TraceBox: (origin, ...) =>
			if origin 
			    LUA_PATCHER.unpatched.PHYSCOLLIDE.TraceBox @, origin, ...
            else
				LogError "Some code attempted to call TraceBox without box origin."
				false
    }

    CLUAEMITTER = FindMetaTable "CLuaEmitter"
    OverwriteTable "CLUAEMITTER", CLUAEMITTER, {
        Add: (...) =>
            if @IsValid!
                LUA_PATCHER.unpatched.CLUAEMITTER.Add @, ...
            else
                LogError "Some code attempted to call CLuaEmitter:Add() on a NULL CLuaEmitter."
        Finish: (...) =>
            if @IsValid!
                LUA_PATCHER.unpatched.CLUAEMITTER.Finish @, ...
            else
                LogError "Some code attempted to call CLuaEmitter:Finish() on a NULL CLuaEmitter."
    }

    CTAKEDAMAGEINFO = FindMetaTable "CTakeDamageInfo"
    OverwriteTable "CTAKEDAMAGEINFO", CTAKEDAMAGEINFO, {
        SetAttacker: (attacker, ...) =>
            if NULL == attacker
                LogError "Some code attempted to call CTakeDamageInfo:SetAttacker() with NULL attacker."
                attacker = game.GetWorld!
            LUA_PATCHER.unpatched.CTAKEDAMAGEINFO.SetAttacker @, attacker, ...
        SetInflictor: (inflictor, ...) =>
            if NULL == inflictor
                LogError "Some code attempted to call CTakeDamageInfo:SetInflictor() with NULL inflictor."
                inflictor = game.GetWorld!
            LUA_PATCHER.unpatched.CTAKEDAMAGEINFO.SetInflictor @, inflictor, ...
    }

    AUDIOCHANNEL = FindMetaTable "IGModAudioChannel"
    OverwriteTable "AUDIOCHANNEL", AUDIOCHANNEL, {
        Stop: (...) =>
            if IsValid @
                LUA_PATCHER.unpatched.AUDIOCHANNEL.Stop @, ...
            else
                LogError "Some code attempted to call IGModAudioChannel:Stop() with NULL IGModAudioChannel."
    }

UnpatchClasses = ->
    RollbackTable "VECTOR", FindMetaTable "Vector"
    RollbackTable "VMATRIX", FindMetaTable "VMatrix"
    RollbackTable "ENTITY", FindMetaTable "Entity"
    RollbackTable "WEAPON", FindMetaTable "Weapon"
    RollbackTable "NPC", FindMetaTable "NPC"
    RollbackTable "PLAYER", FindMetaTable "Player"
    RollbackTable "PHYSOBJ", FindMetaTable "PhysObj"
    RollbackTable "PHYSCOLLIDE", FindMetaTable "PhysCollide"
    RollbackTable "CLUAEMITTER", FindMetaTable "CLuaEmitter"
    RollbackTable "CTAKEDAMAGEINFO", FindMetaTable "CTakeDamageInfo"
    RollbackTable "AUDIOCHANNEL", FindMetaTable "IGModAudioChannel"

PatchHooks = ->
    OverwriteTable "hook", hook, {
        Add: (event_name, name, func, ...) ->
			if isfunction event_name
				func = event_name
				event_name = util.CRC string.dump event_name
				LogError "Some code attempted to call hook.Add() with function as first argument."
			if isfunction name
				func = name
				name = util.CRC string.dump name
				LogError "Some code attempted to call hook.Add() with function as second argument."
			elseif not DLib and isnumber name
				name = tostring name
				LogError "Some code attempted to call hook.Add() with number as second argument."
			elseif isbool name
				name = tostring name
				LogError "Some code attempted to call hook.Add() with boolean as second argument."
			
			if (isfunction(func) or DLib and type(name) == "thread") and isstring event_name
				valid = DLib and type(name) == "thread" or name.IsValid or IsValid name
				if valid or isstring name
					LUA_PATCHER.unpatched.hook.Add event_name, name, func, ...
				else
					LogError "Some code attempted to call hook.Add() with invalid second argument."
        Remove: (event_name, name, ...) ->
			if isfunction event_name
				event_name = util.CRC string.dump event_name
				LogError "Some code attempted to call hook.Remove() with function as first argument."
			if isfunction name
				name = util.CRC string.dump name
				LogError "Some code attempted to call hook.Remove() with function as second argument."
			elseif not DLib and isnumber name
				name = tostring name
				LogError "Some code attempted to call hook.Remove() with number as second argument."
			elseif isbool name
				name = tostring name
				LogError "Some code attempted to call hook.Remove() with boolean as second argument."
			
			if isstring event_name
				valid = DLib and type(name) == "thread" or name.IsValid or IsValid name
				if valid or isstring name
					LUA_PATCHER.unpatched.hook.Remove event_name, name, ...
				else
					LogError "Some code attempted to call hook.Remove() with invalid second argument."
    }

    if DLib
        DLib.MessageWarning "DLib hook system is being overwritten by another addon - "..
        "THIS IS STUPID AND WILL CAUSE ERRORS"
        Log "DLib, shut up and hold still..."

UnpatchHooks = ->
    RollbackTable "hook", hook

    if DLib
        DLib.MessageWarning "DLib hook system is being overwritten by another addon - "..
        "THIS IS STUPID AND WILL CAUSE ERRORS"

ReportBlockedCommand = (cmd) ->
    LogError "An addon tried to use the console command %s which is not allowed.", cmd

PatchConsoleCommands = ->
    Log "Waited %.2f seconds. Hopefully all other addons have initialized by now.",
        SysTime! - LUA_PATCHER.start_wait_time
    Log "Patching console commands..."

    OverwriteFunction "RunConsoleCommand", (cmd, ...) ->
        cmd = string.gsub(cmd or "", "[%c%s]+", "")
        if IsConCommandBlocked cmd or #cmd < 2 then
            ReportBlockedCommand cmd
        else
            LUA_PATCHER.unpatched.RunConsoleCommand cmd, ...

    OverwriteFunction "Error", ->
    OverwriteFunction "ErrorNoHalt", ->

    OverwriteTable "game", game, {
        ConsoleCommand: (cmdStr="", ...) ->
			cmd = string.match cmdStr, "^\"([^\"]+)\""
			cmd = string.match cmdStr, "^[^%s%c]+" unless cmd
			cmd = string.gsub(cmd or "", "%c", " ")
			if IsConCommandBlocked cmd
				ReportBlockedCommand cmd
			else
				LUA_PATCHER.unpatched.game.ConsoleCommand cmdStr, ...
    }

    PLAYER = FindMetaTable "Player"
    OverwriteTable "PLAYER", PLAYER, {
        ConCommand: (cmdStr="", ...) =>
			if IsValid @
				cmd = string.match cmdStr, "^\"([^\"]+)\""
				cmd = string.match cmdStr, "^[^%s%c]+" unless cmd
				cmd = string.gsub(cmd or "", "%c", " ")
                if IsConCommandBlocked cmd
                    ReportBlockedCommand cmd
                else
					LUA_PATCHER.unpatched.PLAYER.ConCommand @, cmdStr, ...
    }
    
    Log "Console commands patched!"
	
    if SERVER
        Log "Lua has been patched! Remember that if you are a Lua developer, "..
        "please disable this addon or your users may get errors from your code!"
    if CLIENT
        Log "Lua has been patched! If you still see errors, "..
        "remember to report the full error message to the creator of Lua Patcher!"

UnpatchConsoleCommands = ->
    RollbackFunction "RunConsoleCommand"
    RollbackFunction "Error"
    RollbackFunction "ErrorNoHalt"
    RollbackTable "game", game
    RollbackTable "PLAYER", FindMetaTable "Player"

Patch = ->
    return if LUA_PATCHER.FIXED
    LUA_PATCHER.FIXED = true

    Log "Running Lua Patcher by Piengineer12, version %s (%s)",
        LUA_PATCHER.VERSION,
        LUA_PATCHER.VERSION_DATE
	
	Log "Patching primitives..."
    PatchPrimitives!
	Log "Primitives patched!"
	
    if gmod
        Log "Patching classes..."
        PatchClasses!
        Log "Classes patched!"

        Log "Patching libraries..."
        PatchLibraries!
        Log "Libraries patched!"

        Log "Patching hooks..."
        PatchHooks!
        Log "Hooks patched!"

        Log "Waiting for all other addons to load..."
        LUA_PATCHER.start_wait_time = SysTime!
        timer.Simple 0, PatchConsoleCommands
    else
        Log "Lua has been patched! Remember that if you are a Lua developer, "..
        "please disable this script or your users may get errors from your code! "..
        "Also, if you still see errors, "..
        "remember to report the FULL error message to the creator of Lua Patcher!"

Unpatch = ->
    return unless LUA_PATCHER.FIXED
    LUA_PATCHER.FIXED = nil

    Log "Running Lua Patcher by Piengineer12, version %s (%s)",
        LUA_PATCHER.VERSION,
        LUA_PATCHER.VERSION_DATE
	
    if gmod
        Log "Unpatching console commands..."
        UnpatchConsoleCommands!
        Log "Console commands unpatched!"

        Log "Unpatching hooks..."
        UnpatchHooks!
        Log "Hooks unpatched!"

        Log "Unpatching libraries..."
        UnpatchLibraries!
        Log "Libraries unpatched!"

        Log "Unpatching classes..."
        UnpatchClasses!
        Log "Classes unpatched!"
	
	Log "Unpatching primitives..."
    UnpatchPrimitives!
	Log "Primitives unpatched!"
	
	Log "All patches have been reverted!"

Patch! -- preemptively patch since CVars are not loaded yet

LUA_PATCHER.Patch = Patch
LUA_PATCHER.Unpatch = Unpatch

if gmod
    ConVarEnable = CreateConVar "lua_patcher_enable",
        "1",
        FCVAR_ARCHIVED,
        "Enables Lua Patcher."

    CheckPatch = ->
        if LUA_PATCHER.FIXED and not ConVarEnable\GetBool! then Unpatch!
        elseif not LUA_PATCHER.FIXED and ConVarEnable\GetBool! then Patch!
        return

    hook.Add "Initialize", "lua_patcher", ->
        hook.Add "Think", "lua_patcher", CheckPatch
        return