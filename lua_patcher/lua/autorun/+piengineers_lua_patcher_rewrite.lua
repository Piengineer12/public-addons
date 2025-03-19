LUA_PATCHER = LUA_PATCHER or {
  workshop_page = "https://steamcommunity.com/sharedfiles/filedetails/?id=2403043112",
  profile_page = "https://steamcommunity.com/id/Piengineer12",
  github_page = "https://github.com/Piengineer12/public-addons/tree/master/lua_patcher",
  donate_page = "https://ko-fi.com/piengineer12",
  extra_info = "Links above are confirmed working as of 2022-05-26. All dates are in ISO 8601 format.",
  unpatched = { }
}
LUA_PATCHER.VERSION = "3.0.6-rc.1"
LUA_PATCHER.VERSION_DATE = "2025-03-19"
local Log, LogError
if gmod then
  local next_report_time = 0
  local color_red = Color(255, 0, 0)
  local color_aqua = Color(0, 255, 255)
  if SERVER then
    util.AddNetworkString("lua_patcher")
  end
  hook.Add("AddToolMenuCategories", "lua_patcher", function()
    spawnmenu.AddToolCategory("Utilities", "lua_patcher", "Lua Patcher")
  end)
  hook.Add("OnReloaded", "lua_patcher", function()
    if LUA_PATCHER.FIXED and CLIENT then
      chat.AddText(color_red, "Remember to turn off Lua Patcher first before editing your Lua files!")
    end
  end)
  hook.Add("PopulateToolMenu", "lua_patcher", function()
    spawnmenu.AddToolMenuOption("Utilities", "lua_patcher", "lua_patcher", "Lua Patcher", "", "", function(DForm)
      local DLabel = DForm:Help("WARNING: If you are a Lua developer, or want to report an addon bug, " .. "make sure that this WHOLE addon is DISABLED before testing!")
      DLabel:SetTextColor(color_red)
      DForm:CheckBox("Enable Lua Patcher", "lua_patcher_enable")
      DForm:CheckBox("Enable Error Logging", "lua_patcher_logging")
    end)
  end)
  local ConVarLogging = CreateConVar("lua_patcher_logging", "0", FCVAR_ARCHIVED, "Enables Lua Patcher logging.")
  Log = function(...)
    local message = {
      color_aqua,
      "[Lua Patcher ",
      (function()
        if SERVER then
          return "Server] "
        else
          return "Client] "
        end
      end)(),
      color_white,
      string.format(...),
      "\n"
    }
    return MsgC(unpack(message))
  end
  LogError = function(...)
    local real_time = RealTime()
    if ConVarLogging:GetBool() and next_report_time < real_time and not string.find(debug.traceback(), "'pcall'") then
      next_report_time = real_time + 1
      Log(...)
      return debug.Trace()
    end
  end
else
  Log = function(...)
    return print("[Lua Patcher] " .. tostring(string.format(...)))
  end
  LogError = function(...)
    return print(debug.traceback("[Lua Patcher] " .. tostring(string.format(...)), 2))
  end
end
local OverwriteTable
OverwriteTable = function(table_name, table_contents, new_table_contents)
  LUA_PATCHER.unpatched[table_name] = LUA_PATCHER.unpatched[table_name] or { }
  local target_table = LUA_PATCHER.unpatched[table_name]
  for k, v in pairs(new_table_contents) do
    target_table[k] = table_contents[k] or true
  end
  for k, v in pairs(new_table_contents) do
    table_contents[k] = v
  end
end
local RollbackTable
RollbackTable = function(table_name, table_contents)
  for k, v in pairs(LUA_PATCHER.unpatched[table_name]) do
    if v == true then
      table_contents[k] = nil
    else
      table_contents[k] = v
    end
  end
end
local OverwriteFunction
OverwriteFunction = function(func_name, func_body)
  LUA_PATCHER.unpatched[func_name] = _G[func_name]
  _G[func_name] = func_body
end
local RollbackFunction
RollbackFunction = function(func_name)
  _G[func_name] = LUA_PATCHER.unpatched[func_name]
end
local PatchPrimitives
PatchPrimitives = function()
  local NIL = getmetatable(nil) or { }
  OverwriteTable("NIL", NIL, {
    __add = function(a, b)
      LogError("Some code attempted to add with nil.")
      return a or b
    end,
    __sub = function(a, b)
      LogError("Some code attempted to subtract with nil.")
      return a or -b
    end,
    __mul = function(a, b)
      LogError("Some code attempted to multiply with nil.")
      return a or b
    end,
    __div = function(a, b)
      LogError("Some code attempted to divide with nil.")
      return a
    end,
    __pow = function(a, b)
      LogError("Some code attempted to raise something to a power with nil.")
      if b then
        return nil
      else
        return a
      end
    end,
    __unm = function(a)
      LogError("Some code attempted to negate nil.")
      return a
    end,
    __concat = function(a, b)
      LogError("Some code attempted to concatenate with nil.")
      return tostring(a) .. tostring(b)
    end,
    __len = function(a)
      LogError("Some code attempted to get the length of nil.")
      return 0
    end,
    __lt = function(a, b)
      LogError("Some code attempted to see if something is bigger or smaller than nil.")
      if type(a) == "number" or type(b) == "number" then
        return (a or 0) < (b or 0)
      else
        return tostring(a) < tostring(b)
      end
    end,
    __le = function(a, b)
      LogError("Some code attempted to see if something is bigger or smaller than nil.")
      if type(a) == "number" or type(b) == "number" then
        return (a or 0) <= (b or 0)
      else
        return tostring(a) <= tostring(b)
      end
    end,
    __index = function()
      return LogError("Some code attempted to index nil.")
    end,
    __newindex = function()
      return LogError("Some code attempted to assign a member value to nil.")
    end,
    __call = function()
      return LogError("Some code attempted to call nil as a function.")
    end
  })
  local BOOL = getmetatable(true) or { }
  OverwriteTable("BOOL", BOOL, {
    __index = function()
      return LogError("Some code attempted to index a boolean.")
    end,
    __newindex = function()
      return LogError("Some code attempted to assign a member value to a boolean.")
    end,
    __call = function()
      return LogError("Some code attempted to call a boolean as a function.")
    end
  })
  OverwriteFunction("pairs", function(tab, ...)
    if not tab then
      tab = { }
      LogError("Some code attempted to iterate over nothing.")
    elseif type(tab) == "number" then
      tab = { }
      LogError("Some code attempted to iterate over a number.")
    end
    return LUA_PATCHER.unpatched.pairs(tab, ...)
  end)
  local NUMBER = getmetatable(0) or { }
  OverwriteTable("NUMBER", NUMBER, {
    __lt = function(a, b)
      if a and b then
        LogError("Some code attempted to see if a number is bigger or smaller than something else that isn't.")
        return tostring(a) < tostring(b)
      else
        LogError("Some code attempted to compare a number with nil.")
        return (a or 0) < (b or 0)
      end
    end,
    __le = function(a, b)
      if a and b then
        LogError("Some code attempted to see if a number is bigger or smaller than something else that isn't.")
        return tostring(a) <= tostring(b)
      else
        LogError("Some code attempted to compare a number with nil.")
        return (a or 0) <= (b or 0)
      end
    end
  })
  local STRING = getmetatable("") or { }
  OverwriteTable("STRING", STRING, {
    __concat = function(a, b)
      if not (type(a) == "string" and type(b) == "string") then
        LogError("Some code attempted to concatenate a string with something that isn't.")
      end
      return tostring(a) .. tostring(b)
    end,
    __add = function(a, b)
      if not (tonumber(a) and tonumber(b)) then
        LogError("Some code attempted to add two strings where at least one isn't a number.")
        return (tonumber(a) or 0) + (tonumber(b) or 0)
      end
    end,
    __lt = function(a, b)
      if a and b then
        LogError("Some code attempted to see if a string is bigger or smaller than something else that isn't.")
        return tostring(a) < tostring(b)
      else
        LogError("Some code attempted to compare a string with nil.")
        return (a or 0) < (b or 0)
      end
    end,
    __le = function(a, b)
      if a and b then
        LogError("Some code attempted to see if a string is bigger or smaller than something else that isn't.")
        return tostring(a) <= tostring(b)
      else
        LogError("Some code attempted to compare a string with nil.")
        return (a or 0) <= (b or 0)
      end
    end
  })
  if debug.setmetatable then
    debug.setmetatable(nil, NIL)
    debug.setmetatable(true, BOOL)
    debug.setmetatable(0, NUMBER)
    return debug.setmetatable("", STRING)
  else
    return Log("WARNING: debug.setmetatable is missing, many primitives cannot be patched!")
  end
end
local UnpatchPrimitives
UnpatchPrimitives = function()
  local NIL = getmetatable(nil) or { }
  RollbackTable("NIL", NIL)
  local BOOL = getmetatable(true) or { }
  RollbackTable("BOOL", BOOL)
  RollbackFunction("pairs")
  local NUMBER = getmetatable(0) or { }
  RollbackTable("NUMBER", NUMBER)
  local STRING = getmetatable("") or { }
  RollbackTable("STRING", STRING)
  if debug.setmetatable then
    debug.setmetatable(nil, NIL)
    debug.setmetatable(true, BOOL)
    debug.setmetatable(0, NUMBER)
    return debug.setmetatable("", STRING)
  end
end
local PatchLibraries
PatchLibraries = function()
  OverwriteFunction("CreateClientConVar", function(name, default, shouldsave, userinfo, helptext, min, max, ...)
    if min and not isnumber(min) then
      LogError("Some code attempted to call CreateClientConVar with non-number min argument.")
      min = nil
    end
    if max and not isnumber(max) then
      LogError("Some code attempted to call CreateClientConVar with non-number max argument.")
      max = nil
    end
    return LUA_PATCHER.unpatched.CreateClientConVar(name, default, shouldsave, userinfo, helptext, min, max, ...)
  end)
  OverwriteFunction("CreateConVar", function(name, default, flags, helptext, min, max, ...)
    if min and not isnumber(min) then
      LogError("Some code attempted to call CreateConVar with non-number min argument.")
      min = nil
    end
    if max and not isnumber(max) then
      LogError("Some code attempted to call CreateConVar with non-number max argument.")
      max = nil
    end
    if not (isstring(helptext)) then
      helptext = tostring(helptext)
      LogError("Some code attempted to call CreateConVar with non-string help text.")
    end
    return LUA_PATCHER.unpatched.CreateConVar(name, default, flags, helptext, min, max, ...)
  end)
  OverwriteFunction("EmitSound", function(soundName, ...)
    if isstring(soundName) then
      return LUA_PATCHER.unpatched.EmitSound(soundName, ...)
    else
      return LogError("Some code attempted to call EmitSound with non-string sound name.")
    end
  end)
  OverwriteFunction("CreateParticleSystem", function(ent, effect, partAttachment, entAttachment, offset, ...)
    if not (isvector(offset)) then
      offset = Vector(0, 0, 0)
      LogError("Some code attempted to call CreateParticleSystem with an invalid offset argument.")
    end
    return LUA_PATCHER.unpatched.CreateParticleSystem(ent, effect, partAttachment, entAttachment, offset, ...)
  end)
  OverwriteFunction("DynamicLight", function(index, ...)
    if not (index) then
      LogError("Some code attempted to call DynamicLight without index.")
      index = 0
    end
    return LUA_PATCHER.unpatched.DynamicLight(index, ...)
  end)
  OverwriteTable("string", string, {
    Explode = function(separator, str, ...)
      if not (separator and str) then
        LogError("Some code attempted to explode a string without providing string separator or haystack.")
      end
      return LUA_PATCHER.unpatched.string.Explode(separator or "", str or "", ...)
    end
  })
  OverwriteTable("ents", ents, {
    FindInSphere = function(origin, radius, ...)
      if not (origin) then
        LogError("Some code attempted to call ents.FindInSphere without a sphere center.")
        origin = vector_origin
      end
      if not (radius) then
        LogError("Some code attempted to call ents.FindInSphere without a radius.")
        radius = 0
      end
      return LUA_PATCHER.unpatched.ents.FindInSphere(origin, radius, ...)
    end
  })
  OverwriteTable("net", net, {
    Start = function(...)
      if net.BytesWritten() then
        net.Abort()
        LogError("Some code attempted to call net.Start without finishing the previous net message.")
      end
      local retValues = {
        pcall(LUA_PATCHER.unpatched.net.Start, ...)
      }
      if retValues[1] then
        return select(2, unpack(retValues))
      else
        LogError("Caught a net.Start error: %s", retValues[2])
        return LUA_PATCHER.unpatched.net.Start("lua_patcher")
      end
    end,
    WriteString = function(str, ...)
      if not str then
        str = ""
        LogError("Some code attempted to call net.WriteString without providing a string.")
      elseif not isstring(str) then
        str = tostring(str)
        LogError("Some code attempted to call net.WriteString with a non-string value.")
      end
      return LUA_PATCHER.unpatched.net.WriteString(str, ...)
    end
  })
  OverwriteTable("util", util, {
    IsValidModel = function(model, ...)
      if not (isstring(model)) then
        LogError("Some code attempted to call util.IsValidModel with an invalid argument.")
        model = tostring(model)
      end
      return LUA_PATCHER.unpatched.util.IsValidModel(model, ...)
    end
  })
  OverwriteTable("vgui", vgui, {
    Create = function(pnl, parent, ...)
      if parent ~= nil and not ispanel(parent) then
        LogError("Some code attempted to parent a panel to a non-panel.")
        parent = nil
      end
      return LUA_PATCHER.unpatched.vgui.Create(pnl, parent, ...)
    end
  })
  OverwriteTable("bit", bit, {
    band = function(value, ...)
      if not (value) then
        LogError("Some code attempted to call bit.band without any arguments.")
      end
      return LUA_PATCHER.unpatched.bit.band(value or 0, ...)
    end,
    bor = function(value, ...)
      if not (value) then
        LogError("Some code attempted to call bit.bor without any arguments.")
      end
      return LUA_PATCHER.unpatched.bit.bor(value or 0, ...)
    end
  })
  OverwriteTable("input", input, {
    IsKeyDown = function(key, ...)
      if key then
        return LUA_PATCHER.unpatched.input.IsKeyDown(key, ...)
      else
        LogError("Some code attempted to call input.IsKeyDown without specifying a key.")
        return false
      end
    end
  })
  OverwriteTable("language", language, {
    Add = function(key, value, ...)
      if not key then
        return LogError("Some code attempted to call language.Add without specifying a language key.")
      elseif not value then
        return LogError("Some code attempted to call language.Add without specifying a language value.")
      else
        return LUA_PATCHER.unpatched.language.Add(key, value, ...)
      end
    end
  })
  return OverwriteTable("surface", surface, {
    SetFont = function(font, ...)
      local retValues = {
        pcall(LUA_PATCHER.unpatched.surface.SetFont, font, ...)
      }
      if retValues[1] then
        return select(2, unpack(retValues))
      else
        LogError("Caught a surface.SetFont error: %s", retValues[2])
        return LUA_PATCHER.unpatched.surface.SetFont("Default")
      end
    end
  })
end
local UnpatchLibraries
UnpatchLibraries = function()
  RollbackFunction("CreateClientConVar")
  RollbackFunction("CreateConVar")
  RollbackFunction("EmitSound")
  RollbackFunction("CreateParticleSystem")
  RollbackFunction("DynamicLight")
  RollbackTable("string", string)
  RollbackTable("ents", ents)
  RollbackTable("net", net)
  RollbackTable("util", util)
  RollbackTable("vgui", vgui)
  RollbackTable("input", input)
  RollbackTable("language", language)
  return RollbackTable("surface", surface)
end
local PatchClasses
PatchClasses = function()
  local VECTOR = FindMetaTable("Vector")
  OverwriteTable("VECTOR", VECTOR, {
    __add = function(a, b)
      if not (isvector(a) and isvector(b)) then
        LogError("Some code attempted to add a vector with something that isn't.")
      end
      return LUA_PATCHER.unpatched.VECTOR.__add((function()
        if isvector(a) then
          return a
        else
          return Vector(a)
        end
      end)(), (function()
        if isvector(b) then
          return b
        else
          return Vector(b)
        end
      end)())
    end,
    __sub = function(a, b)
      if not (isvector(a) and isvector(b)) then
        LogError("Some code attempted to subtract a vector with something that isn't.")
      end
      return LUA_PATCHER.unpatched.VECTOR.__sub((function()
        if isvector(a) then
          return a
        else
          return Vector(a)
        end
      end)(), (function()
        if isvector(b) then
          return b
        else
          return Vector(b)
        end
      end)())
    end,
    __mul = function(a, b)
      if not (isnumber(a) or isnumber(b) or isvector(a) and isvector(b)) then
        LogError("Some code attempted to multiply a vector with something that is neither a vector nor a number.")
      end
      return LUA_PATCHER.unpatched.VECTOR.__mul(a or 1, b or 1)
    end,
    __div = function(a, b)
      if not (isnumber(a) or isnumber(b) or isvector(a) and isvector(b)) then
        LogError("Some code attempted to divide a vector with something that is neither a vector nor a number.")
      end
      return LUA_PATCHER.unpatched.VECTOR.__div(a or 1, b or 1)
    end
  })
  local VMATRIX = FindMetaTable("VMatrix")
  OverwriteTable("VMATRIX", VMATRIX, {
    __add = function(a, b)
      if not (ismatrix(a) and ismatrix(b)) then
        LogError("Some code attempted to add a matrix with something that isn't.")
      end
      return LUA_PATCHER.unpatched.VMATRIX.__add((function()
        if ismatrix(a) then
          return a
        else
          return Matrix({
            {
              0,
              0,
              0,
              0
            },
            {
              0,
              0,
              0,
              0
            },
            {
              0,
              0,
              0,
              0
            },
            {
              0,
              0,
              0,
              0
            }
          })
        end
      end)(), (function()
        if ismatrix(b) then
          return b
        else
          return Matrix({
            {
              0,
              0,
              0,
              0
            },
            {
              0,
              0,
              0,
              0
            },
            {
              0,
              0,
              0,
              0
            },
            {
              0,
              0,
              0,
              0
            }
          })
        end
      end)())
    end,
    __sub = function(a, b)
      if not (ismatrix(a) and ismatrix(b)) then
        LogError("Some code attempted to subtract a matrix with something that isn't.")
      end
      return LUA_PATCHER.unpatched.VMATRIX.__sub((function()
        if ismatrix(a) then
          return a
        else
          return Matrix({
            {
              0,
              0,
              0,
              0
            },
            {
              0,
              0,
              0,
              0
            },
            {
              0,
              0,
              0,
              0
            },
            {
              0,
              0,
              0,
              0
            }
          })
        end
      end)(), (function()
        if ismatrix(b) then
          return b
        else
          return Matrix({
            {
              0,
              0,
              0,
              0
            },
            {
              0,
              0,
              0,
              0
            },
            {
              0,
              0,
              0,
              0
            },
            {
              0,
              0,
              0,
              0
            }
          })
        end
      end)())
    end,
    __mul = function(a, b)
      if not (isvector(a) or isvector(b) or ismatrix(a) and ismatrix(b)) then
        LogError("Some code attempted to multiply a matrix with something that is neither a matrix nor a vector.")
      end
      return LUA_PATCHER.unpatched.VMATRIX.__mul(a or Matrix(a), b or Matrix(b))
    end
  })
  local new_entity_metatable = {
    GetClass = function(self, ...)
      if "[NULL Entity]" == tostring(self) then
        LogError("Some code attempted to get the class of a NULL entity.")
        return "[NULL Entity]"
      else
        return LUA_PATCHER.unpatched.ENTITY.GetClass(self, ...)
      end
    end,
    SetPos = function(self, ...)
      if "[NULL Entity]" == tostring(self) then
        return LogError("Some code attempted to set the position of a NULL entity.")
      else
        return LUA_PATCHER.unpatched.ENTITY.SetPos(self, ...)
      end
    end,
    GetPos = function(self, ...)
      if "[NULL Entity]" == tostring(self) then
        LogError("Some code attempted to get the position of a NULL entity.")
        return vector_origin
      else
        return LUA_PATCHER.unpatched.ENTITY.GetPos(self, ...)
      end
    end,
    SetAngles = function(self, ...)
      if "[NULL Entity]" == tostring(self) then
        return LogError("Some code attempted to set the angles of a NULL entity.")
      else
        return LUA_PATCHER.unpatched.ENTITY.SetAngles(self, ...)
      end
    end,
    LookupAttachment = function(self, ...)
      if "[NULL Entity]" == tostring(self) then
        LogError("Some code attempted to lookup an attachment of a NULL entity.")
        return -1
      else
        return LUA_PATCHER.unpatched.ENTITY.LookupAttachment(self, ...)
      end
    end,
    SetColor4Part = function(self, ...)
      if "[NULL Entity]" == tostring(self) then
        return LogError("Some code attempted to set the color of a NULL entity.")
      else
        return LUA_PATCHER.unpatched.ENTITY.SetColor4Part(self, ...)
      end
    end,
    GetBoneCount = function(self, ...)
      if "[NULL Entity]" == tostring(self) then
        LogError("Some code attempted to get the number of bones of a NULL entity.")
        return 0
      else
        return LUA_PATCHER.unpatched.ENTITY.GetBoneCount(self, ...)
      end
    end,
    Spawn = function(self, ...)
      if "[NULL Entity]" == tostring(self) then
        return LogError("Some code attempted to spawn a NULL entity.")
      else
        return LUA_PATCHER.unpatched.ENTITY.Spawn(self, ...)
      end
    end,
    Activate = function(self, ...)
      if "[NULL Entity]" == tostring(self) then
        return LogError("Some code attempted to activate a NULL entity.")
      else
        return LUA_PATCHER.unpatched.ENTITY.Activate(self, ...)
      end
    end,
    Remove = function(self, ...)
      if "[NULL Entity]" == tostring(self) then
        return LogError("Some code attempted to remove a NULL entity.")
      else
        return LUA_PATCHER.unpatched.ENTITY.Remove(self, ...)
      end
    end,
    GetPhysicsObject = function(self, ...)
      if "[NULL Entity]" == tostring(self) then
        return LogError("Some code attempted to get the physics object of a NULL entity.")
      else
        return LUA_PATCHER.unpatched.ENTITY.GetPhysicsObject(self, ...)
      end
    end,
    GetBonePosition = function(self, boneIndex, ...)
      if not (boneIndex) then
        LogError("Some code attempted to call Entity:GetBonePosition() without valid bone index.")
      end
      return LUA_PATCHER.unpatched.ENTITY.GetBonePosition(self, boneIndex or 0, ...)
    end,
    LookupBone = function(self, name, ...)
      if "[NULL Entity]" == tostring(self) then
        LogError("Some code attempted to lookup a bone of a NULL entity.")
        return -1
      end
      local retValues = {
        LUA_PATCHER.unpatched.ENTITY.LookupBone(self, name, ...)
      }
      if retValues[1] then
        return unpack(retValues)
      end
      retValues = {
        LUA_PATCHER.unpatched.ENTITY.LookupBone(self, isstring(name) and name:lower() or name, ...)
      }
      if retValues[1] then
        LogError("Some code attempted to call Entity:LookupBone() without lowercased bone name.")
        return unpack(retValues)
      end
    end,
    SetPhysicsAttacker = function(self, attacker, ...)
      if "[NULL Entity]" == tostring(self) then
        return LogError("Some code attempted to set the physics attacker of a NULL entity.")
      elseif attacker:IsPlayer() then
        if LUA_PATCHER.unpatched.ENTITY.SetPhysicsAttacker then
          return LUA_PATCHER.unpatched.ENTITY.SetPhysicsAttacker(self, attacker, ...)
        end
      else
        return LogError("Some code attempted to set the physics attacker of an entity to a non-player.")
      end
    end,
    SetBodyGroups = function(self, bodygroups, ...)
      if not (bodygroups) then
        LogError("Some code attempted to call Entity:SetBodyGroups() without valid string.")
      end
      return LUA_PATCHER.unpatched.ENTITY.SetBodyGroups(self, bodygroups or "", ...)
    end,
    SetColor = function(self, col, ...)
      if "[NULL Entity]" == tostring(self) then
        return LogError("Some code attempted to set the color of a NULL entity.")
      elseif not istable(col) then
        return LogError("Some code attempted to set the color of an entity with a non-table value.")
      else
        local useCol = col
        if not (col.r and col.g and col.b and col.a) then
          LogError("Some code attempted to set the color of an entity with an invalid table.")
          useCol = Color(tonumber(col.r) or 255, tonumber(col.g) or 255, tonumber(col.b) or 255, tonumber(col.a) or 255)
        end
        return LUA_PATCHER.unpatched.ENTITY.SetColor(self, useCol, ...)
      end
    end,
    SetSkin = function(self, skin, ...)
      if skin then
        return LUA_PATCHER.unpatched.ENTITY.SetSkin(self, skin, ...)
      else
        return LogError("Some code attempted to set the skin of an entity to nil.")
      end
    end,
    EmitSound = function(self, soundName, ...)
      if isstring(soundName) then
        return LUA_PATCHER.unpatched.ENTITY.EmitSound(self, soundName, ...)
      else
        return LogError("Some code attempted to call EmitSound on an entity with non-string sound name.")
      end
    end,
    PhysicsFromMesh = function(self, mesh, ...)
      if istable(mesh) then
        return LUA_PATCHER.unpatched.ENTITY.PhysicsFromMesh(self, mesh, ...)
      else
        return LogError("Some code attempted to call PhysicsFromMesh with non-table mesh.")
      end
    end,
    PhysicsInit = function(self, solidType, ...)
      if solidType == SOLID_NONE then
        local vars = {
          ...
        }
        timer.Simple(0, function()
          if (("[NULL Entity]" ~= tostring(self)) and IsValid(self:GetPhysicsObject())) then
            return LUA_PATCHER.unpatched.ENTITY.PhysicsInit(self, solidType, unpack(vars))
          end
        end)
        return true
      else
        return LUA_PATCHER.unpatched.ENTITY.PhysicsInit(self, solidType, ...)
      end
    end,
    SetAnimation = function(self, ...)
      if "[NULL Entity]" == tostring(self) then
        return LogError("Some code attempted to set the animation of a NULL entity.")
      else
        return LUA_PATCHER.unpatched.ENTITY.SetAnimation(self, ...)
      end
    end
  }
  local nw_override_table = {
    Angle = angle_zero,
    Bool = false,
    Entity = NULL,
    Float = 0,
    Int = 0,
    String = ""
  }
  for k, v in pairs(nw_override_table) do
    local set_func_name = "SetNW" .. k
    new_entity_metatable[set_func_name] = function(self, ...)
      if "[NULL Entity]" == tostring(self) then
        return LogError("Some code attempted to call " .. tostring(set_func_name) .. " on a NULL entity.")
      else
        return LUA_PATCHER.unpatched.ENTITY[set_func_name](self, ...)
      end
    end
    local get_func_name = "GetNW" .. k
    new_entity_metatable[get_func_name] = function(self, ...)
      if "[NULL Entity]" == tostring(self) then
        LogError("Some code attempted to call " .. tostring(get_func_name) .. " on a NULL entity.")
        return v
      else
        return LUA_PATCHER.unpatched.ENTITY[get_func_name](self, ...)
      end
    end
  end
  local ENTITY = FindMetaTable("Entity")
  OverwriteTable("ENTITY", ENTITY, new_entity_metatable)
  local WEAPON = FindMetaTable("Weapon")
  OverwriteTable("WEAPON", WEAPON, {
    GetPrintName = function(self, ...)
      if IsValid(self) then
        return LUA_PATCHER.unpatched.WEAPON.GetPrintName(self, ...)
      else
        LogError("Some code attempted to get the print name of a NULL weapon.")
        return tostring(self)
      end
    end
  })
  local NPC = FindMetaTable("NPC")
  OverwriteTable("NPC", NPC, {
    GetEnemy = function(self, ...)
      if IsValid(self) then
        return LUA_PATCHER.unpatched.NPC.GetEnemy(self, ...)
      else
        return LogError("Some code attempted to get the enemy of a NULL NPC.")
      end
    end,
    SelectWeapon = function(self, class_name, ...)
      if not (class_name) then
        class_name = ""
        LogError("Some code did not specify which weapon an NPC should hold.")
      end
      return LUA_PATCHER.unpatched.NPC.SelectWeapon(self, class_name, ...)
    end
  })
  local PLAYER = FindMetaTable("Player")
  OverwriteTable("PLAYER", PLAYER, {
    GetCurrentCommand = function(self, ...)
      if self == GetPredictionPlayer() then
        return LUA_PATCHER.unpatched.PLAYER.GetCurrentCommand(self, ...)
      else
        return LogError("Some code attempted to call Player:GetCurrentCommand() " .. "on a player with no commands currently being processed.")
      end
    end,
    SelectWeapon = function(self, class_name, ...)
      if not (class_name) then
        class_name = ""
        LogError("Some code did not specify which weapon a player should hold.")
      end
      return LUA_PATCHER.unpatched.PLAYER.SelectWeapon(self, class_name, ...)
    end
  })
  local PHYSOBJ = FindMetaTable("PhysObj")
  OverwriteTable("PHYSOBJ", PHYSOBJ, {
    Wake = function(self, ...)
      if IsValid(self) then
        return LUA_PATCHER.unpatched.PHYSOBJ.Wake(self, ...)
      else
        return LogError("Some code attempted to wake a NULL physics object.")
      end
    end,
    EnableGravity = function(self, ...)
      if IsValid(self) then
        return LUA_PATCHER.unpatched.PHYSOBJ.EnableGravity(self, ...)
      else
        return LogError("Some code attempted to toggle the gravity of a NULL physics object.")
      end
    end,
    EnableMotion = function(self, ...)
      if IsValid(self) then
        return LUA_PATCHER.unpatched.PHYSOBJ.EnableMotion(self, ...)
      else
        return LogError("Some code attempted to freeze or unfreeze a NULL physics object.")
      end
    end,
    SetVelocity = function(self, ...)
      if IsValid(self) then
        return LUA_PATCHER.unpatched.PHYSOBJ.SetVelocity(self, ...)
      else
        return LogError("Some code attempted to set the velocity of a NULL physics object.")
      end
    end
  })
  local PHYSCOLLIDE = FindMetaTable("PhysCollide")
  OverwriteTable("PHYSCOLLIDE", PHYSCOLLIDE, {
    TraceBox = function(self, origin, ...)
      if origin then
        return LUA_PATCHER.unpatched.PHYSCOLLIDE.TraceBox(self, origin, ...)
      else
        LogError("Some code attempted to call TraceBox without box origin.")
        return false
      end
    end
  })
  local CLUAEMITTER = FindMetaTable("CLuaEmitter")
  OverwriteTable("CLUAEMITTER", CLUAEMITTER, {
    Add = function(self, ...)
      if self:IsValid() then
        return LUA_PATCHER.unpatched.CLUAEMITTER.Add(self, ...)
      else
        return LogError("Some code attempted to call CLuaEmitter:Add() on a NULL CLuaEmitter.")
      end
    end,
    Finish = function(self, ...)
      if self:IsValid() then
        return LUA_PATCHER.unpatched.CLUAEMITTER.Finish(self, ...)
      else
        return LogError("Some code attempted to call CLuaEmitter:Finish() on a NULL CLuaEmitter.")
      end
    end
  })
  local CTAKEDAMAGEINFO = FindMetaTable("CTakeDamageInfo")
  OverwriteTable("CTAKEDAMAGEINFO", CTAKEDAMAGEINFO, {
    SetAttacker = function(self, attacker, ...)
      if "[NULL Entity]" == tostring(attacker) then
        LogError("Some code attempted to call CTakeDamageInfo:SetAttacker() with NULL attacker.")
        attacker = game.GetWorld()
      end
      return LUA_PATCHER.unpatched.CTAKEDAMAGEINFO.SetAttacker(self, attacker, ...)
    end,
    SetInflictor = function(self, inflictor, ...)
      if "[NULL Entity]" == tostring(inflictor) then
        LogError("Some code attempted to call CTakeDamageInfo:SetInflictor() with NULL inflictor.")
        inflictor = game.GetWorld()
      end
      return LUA_PATCHER.unpatched.CTAKEDAMAGEINFO.SetInflictor(self, inflictor, ...)
    end
  })
  local AUDIOCHANNEL = FindMetaTable("IGModAudioChannel")
  return OverwriteTable("AUDIOCHANNEL", AUDIOCHANNEL, {
    Stop = function(self, ...)
      if IsValid(self) then
        return LUA_PATCHER.unpatched.AUDIOCHANNEL.Stop(self, ...)
      else
        return LogError("Some code attempted to call IGModAudioChannel:Stop() with NULL IGModAudioChannel.")
      end
    end
  })
end
local UnpatchClasses
UnpatchClasses = function()
  RollbackTable("VECTOR", FindMetaTable("Vector"))
  RollbackTable("VMATRIX", FindMetaTable("VMatrix"))
  RollbackTable("ENTITY", FindMetaTable("Entity"))
  RollbackTable("WEAPON", FindMetaTable("Weapon"))
  RollbackTable("NPC", FindMetaTable("NPC"))
  RollbackTable("PLAYER", FindMetaTable("Player"))
  RollbackTable("PHYSOBJ", FindMetaTable("PhysObj"))
  RollbackTable("PHYSCOLLIDE", FindMetaTable("PhysCollide"))
  RollbackTable("CLUAEMITTER", FindMetaTable("CLuaEmitter"))
  RollbackTable("CTAKEDAMAGEINFO", FindMetaTable("CTakeDamageInfo"))
  return RollbackTable("AUDIOCHANNEL", FindMetaTable("IGModAudioChannel"))
end
local PatchHooks
PatchHooks = function()
  OverwriteTable("hook", hook, {
    Add = function(event_name, name, func, ...)
      if isfunction(event_name) then
        func = event_name
        event_name = util.CRC(string.dump(event_name))
        LogError("Some code attempted to call hook.Add() with function as first argument.")
      end
      if isfunction(name) then
        func = name
        name = util.CRC(string.dump(name))
        LogError("Some code attempted to call hook.Add() with function as second argument.")
      elseif not DLib and isnumber(name) then
        name = tostring(name)
        LogError("Some code attempted to call hook.Add() with number as second argument.")
      elseif isbool(name) then
        name = tostring(name)
        LogError("Some code attempted to call hook.Add() with boolean as second argument.")
      end
      if (isfunction(func) or DLib and type(name) == "thread") and isstring(event_name) then
        local valid = DLib and type(name) == "thread" or name.IsValid or IsValid(name)
        if valid or isstring(name) then
          return LUA_PATCHER.unpatched.hook.Add(event_name, name, func, ...)
        else
          return LogError("Some code attempted to call hook.Add() with invalid second argument.")
        end
      end
    end,
    Remove = function(event_name, name, ...)
      if isfunction(event_name) then
        event_name = util.CRC(string.dump(event_name))
        LogError("Some code attempted to call hook.Remove() with function as first argument.")
      end
      if isfunction(name) then
        name = util.CRC(string.dump(name))
        LogError("Some code attempted to call hook.Remove() with function as second argument.")
      elseif not DLib and isnumber(name) then
        name = tostring(name)
        LogError("Some code attempted to call hook.Remove() with number as second argument.")
      elseif isbool(name) then
        name = tostring(name)
        LogError("Some code attempted to call hook.Remove() with boolean as second argument.")
      end
      if isstring(event_name) then
        local valid = DLib and type(name) == "thread" or name.IsValid or IsValid(name)
        if valid or isstring(name) then
          return LUA_PATCHER.unpatched.hook.Remove(event_name, name, ...)
        else
          return LogError("Some code attempted to call hook.Remove() with invalid second argument.")
        end
      end
    end
  })
  if DLib then
    DLib.MessageWarning("DLib hook system is being overwritten by another addon - " .. "THIS IS STUPID AND WILL CAUSE ERRORS")
    return Log("DLib, shut up and hold still...")
  end
end
local UnpatchHooks
UnpatchHooks = function()
  RollbackTable("hook", hook)
  if DLib then
    return DLib.MessageWarning("DLib hook system is being overwritten by another addon - " .. "THIS IS STUPID AND WILL CAUSE ERRORS")
  end
end
local ReportBlockedCommand
ReportBlockedCommand = function(cmd)
  return LogError("An addon tried to use the console command %s which is not allowed.", cmd)
end
local PatchConsoleCommands
PatchConsoleCommands = function()
  Log("Waited %.2f seconds. Hopefully all other addons have initialized by now.", SysTime() - LUA_PATCHER.start_wait_time)
  Log("Patching console commands...")
  OverwriteFunction("RunConsoleCommand", function(cmd, ...)
    cmd = string.gsub(cmd or "", "[%c%s]+", "")
    if IsConCommandBlocked(cmd or #cmd < 2) then
      return ReportBlockedCommand(cmd)
    else
      return LUA_PATCHER.unpatched.RunConsoleCommand(cmd, ...)
    end
  end)
  OverwriteFunction("Error", function() end)
  OverwriteFunction("ErrorNoHalt", function() end)
  OverwriteTable("game", game, {
    ConsoleCommand = function(cmdStr, ...)
      if cmdStr == nil then
        cmdStr = ""
      end
      local cmd = string.match(cmdStr, "^\"([^\"]+)\"")
      if not (cmd) then
        cmd = string.match(cmdStr, "^[^%s%c]+")
      end
      cmd = string.gsub(cmd or "", "%c", " ")
      if IsConCommandBlocked(cmd) then
        return ReportBlockedCommand(cmd)
      else
        return LUA_PATCHER.unpatched.game.ConsoleCommand(cmdStr, ...)
      end
    end
  })
  local PLAYER = FindMetaTable("Player")
  OverwriteTable("PLAYER", PLAYER, {
    ConCommand = function(self, cmdStr, ...)
      if cmdStr == nil then
        cmdStr = ""
      end
      if IsValid(self) then
        local cmd = string.match(cmdStr, "^\"([^\"]+)\"")
        if not (cmd) then
          cmd = string.match(cmdStr, "^[^%s%c]+")
        end
        cmd = string.gsub(cmd or "", "%c", " ")
        if IsConCommandBlocked(cmd) then
          return ReportBlockedCommand(cmd)
        else
          return LUA_PATCHER.unpatched.PLAYER.ConCommand(self, cmdStr, ...)
        end
      end
    end
  })
  Log("Console commands patched!")
  if SERVER then
    Log("Lua has been patched! Remember that if you are a Lua developer, " .. "please disable this addon or your users may get errors from your code!")
  end
  if CLIENT then
    return Log("Lua has been patched! If you still see errors, " .. "remember to report the full error message to the creator of Lua Patcher!")
  end
end
local UnpatchConsoleCommands
UnpatchConsoleCommands = function()
  RollbackFunction("RunConsoleCommand")
  RollbackFunction("Error")
  RollbackFunction("ErrorNoHalt")
  RollbackTable("game", game)
  return RollbackTable("PLAYER", FindMetaTable("Player"))
end
local Patch
Patch = function()
  if LUA_PATCHER.FIXED then
    return 
  end
  LUA_PATCHER.FIXED = true
  Log("Running Lua Patcher by Piengineer12, version %s (%s)", LUA_PATCHER.VERSION, LUA_PATCHER.VERSION_DATE)
  Log("Patching primitives...")
  PatchPrimitives()
  Log("Primitives patched!")
  if gmod then
    Log("Patching classes...")
    PatchClasses()
    Log("Classes patched!")
    Log("Patching libraries...")
    PatchLibraries()
    Log("Libraries patched!")
    Log("Patching hooks...")
    PatchHooks()
    Log("Hooks patched!")
    Log("Waiting for all other addons to load...")
    LUA_PATCHER.start_wait_time = SysTime()
    return timer.Simple(0, PatchConsoleCommands)
  else
    return Log("Lua has been patched! Remember that if you are a Lua developer, " .. "please disable this script or your users may get errors from your code! " .. "Also, if you still see errors, " .. "remember to report the FULL error message to the creator of Lua Patcher!")
  end
end
local Unpatch
Unpatch = function()
  if not (LUA_PATCHER.FIXED) then
    return 
  end
  LUA_PATCHER.FIXED = nil
  Log("Running Lua Patcher by Piengineer12, version %s (%s)", LUA_PATCHER.VERSION, LUA_PATCHER.VERSION_DATE)
  if gmod then
    Log("Unpatching console commands...")
    UnpatchConsoleCommands()
    Log("Console commands unpatched!")
    Log("Unpatching hooks...")
    UnpatchHooks()
    Log("Hooks unpatched!")
    Log("Unpatching libraries...")
    UnpatchLibraries()
    Log("Libraries unpatched!")
    Log("Unpatching classes...")
    UnpatchClasses()
    Log("Classes unpatched!")
  end
  Log("Unpatching primitives...")
  UnpatchPrimitives()
  Log("Primitives unpatched!")
  return Log("All patches have been reverted!")
end
Patch()
LUA_PATCHER.Patch = Patch
LUA_PATCHER.Unpatch = Unpatch
if gmod then
  local ConVarEnable = CreateConVar("lua_patcher_enable", "1", FCVAR_ARCHIVED, "Enables Lua Patcher.")
  local CheckPatch
  CheckPatch = function()
    if LUA_PATCHER.FIXED and not ConVarEnable:GetBool() then
      Unpatch()
    elseif not LUA_PATCHER.FIXED and ConVarEnable:GetBool() then
      Patch()
    end
  end
  return hook.Add("Initialize", "lua_patcher", function()
    hook.Add("Think", "lua_patcher", CheckPatch)
  end)
end
