CCVCCM.ENUMS = {
  NET = {
    REP = 1,
    EXEC = 2,
    QUERY = 3,
    INIT_REP = 4
  },
  COLORS = {
    GREEN = Color(0, 255, 0),
    AQUA = Color(0, 255, 255)
  }
}
CCVCCM.ShouldLog = function(self)
  return GetConVar('developer'):GetInt() > 0
end
CCVCCM.Log = function(self, ...)
  if self:ShouldLog() then
    local displayTable = { }
    for i, element in ipairs({
      ...
    }) do
      if istable(element) then
        displayTable[i] = util.TableToJSON(element, true) or ''
      else
        displayTable[i] = tostring(element)
      end
    end
    local texts = table.concat(displayTable, '\t')
    return MsgC(self.ENUMS.COLORS.AQUA, '[CCVCCM] ', string.format('%#.2f ', RealTime()), color_white, texts, '\n')
  end
end
CCVCCM.StartNet = function(self)
  return net.Start('ccvccm')
end
CCVCCM.FinishNet = function(self, recipients)
  if CLIENT then
    net.SendToServer()
  end
  if SERVER then
    if recipients then
      return net.Send(recipients)
    else
      return net.Broadcast()
    end
  end
end
CCVCCM.Send = function(self, sendData, recipients)
  self:StartNet()
  self:AddPayloadToNetMessage(sendData)
  return self:FinishNet(recipients)
end
CCVCCM.AddPayloadToNetMessage = function(self, sendData)
  local currentType
  for i, sendUnit in ipairs(sendData) do
    if i % 2 == 0 then
      local _exp_0 = currentType
      if 'b' == _exp_0 then
        net.WriteBool(tobool(sendUnit))
      elseif 'u8' == _exp_0 then
        net.WriteUInt(tonumber(sendUnit), 8)
      elseif 'i16' == _exp_0 then
        net.WriteInt(tonumber(sendUnit), 16)
      elseif 'd' == _exp_0 then
        net.WriteDouble(tonumber(sendUnit))
      elseif 's' == _exp_0 then
        net.WriteString(tostring(sendUnit))
      elseif 't' == _exp_0 then
        net.WriteTable(sendUnit)
      end
    else
      currentType = sendUnit
    end
  end
end
CCVCCM.ExtractSingleFromNetMessage = function(self, dataType)
  local _exp_0 = dataType
  if 'b' == _exp_0 then
    return net.ReadBool()
  elseif 'u8' == _exp_0 then
    return net.ReadUInt(8)
  elseif 'd' == _exp_0 then
    return net.ReadDouble()
  elseif 's' == _exp_0 then
    return net.ReadString()
  elseif 't' == _exp_0 then
    return net.ReadTable()
  end
end
CCVCCM.ExtractPayloadFromNetMessage = function(self, dataTypes)
  if istable(dataTypes) then
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #dataTypes do
      local dataType = dataTypes[_index_0]
      _accum_0[_len_0] = self:ExtractSingleFromNetMessage(dataType)
      _len_0 = _len_0 + 1
    end
    return _accum_0
  else
    return {
      self:ExtractSingleFromNetMessage(dataTypes)
    }
  end
end
CCVCCM.GetNetSingleAddonType = function(self, fullName)
  local registeredData = CCVCCM:_GetRegisteredData(fullName)
  if registeredData then
    local typeInfo = registeredData.data.typeInfo or { }
    local _exp_0 = typeInfo.type
    if 'bool' == _exp_0 then
      return 'b'
    elseif 'number' == _exp_0 then
      return 'd'
    elseif 'keybind' == _exp_0 or 'string' == _exp_0 then
      return 's'
    else
      if typeInfo[1] then
        return 't'
      else
        return ''
      end
    end
  end
end
CCVCCM.SQL = function(self, query, params)
  if params == nil then
    params = { }
  end
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #params do
      local param = params[_index_0]
      _accum_0[_len_0] = sql.SQLStr(param)
      _len_0 = _len_0 + 1
    end
    params = _accum_0
  end
  local queryString
  if next(params) then
    queryString = string.format(query, unpack(params))
  else
    queryString = query
  end
  local result = sql.Query(queryString)
  if result == false then
    local err = sql.LastError()
    if err then
      error(err, 2)
    end
  end
  return result
end
local CCVCCMPointer
do
  local _class_0
  local _base_0 = {
    Get = function(self, ply)
      return CCVCCM:GetVarValue(self.name, ply)
    end,
    Set = function(self, value)
      return CCVCCM:SetVarValue(self.name, value)
    end,
    Revert = function(self)
      return CCVCCM:RevertVarValue(self.name)
    end,
    Run = function(self, value, ply)
      if ply == nil then
        ply = NULL
      end
      return CCVCCM:RunCommand(self.name, ply, value)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, fullName, ply)
      if ply == nil then
        ply = NULL
      end
      if istable(fullName) then
        fullName = table.concat(fullName, '_')
      end
      self.name = fullName
    end,
    __base = _base_0,
    __name = "CCVCCMPointer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  CCVCCMPointer = _class_0
end
CCVCCM.api = CCVCCM.api or {
  layout = {
    [''] = {
      name = 'Other',
      useTab = false,
      layoutOrder = { },
      layoutData = { }
    }
  },
  aliases = { },
  data = { },
  addonVars = { },
  addon = '',
  categoryPath = { }
}
CCVCCM:SQL('CREATE TABLE IF NOT EXISTS "ccvccm" (\r\n	"var" TEXT NOT NULL UNIQUE ON CONFLICT REPLACE,\r\n	"value" TEXT NOT NULL\r\n)')
local loadedData = CCVCCM:SQL('SELECT "value" FROM "ccvccm"')
if loadedData then
  CCVCCM.api.addonVars = util.JSONToTable(loadedData[1].value)
end
CCVCCM.SaveData = function(self)
  self:Log('Saving data...')
  local data
  do
    local _tbl_0 = { }
    for k, v in pairs(self.api.addonVars) do
      _tbl_0[k] = v
    end
    data = _tbl_0
  end
  self:SQL('BEGIN')
  self:SQL('INSERT INTO "ccvccm" ("var", "value") VALUES (%s, %s)', {
    '',
    util.TableToJSON(data)
  })
  self:SQL('COMMIT')
  return self:Log('Saved!')
end
timer.Create('ccvccm_autosave', 120, 0, (function()
  local _base_0 = CCVCCM
  local _fn_0 = _base_0.SaveData
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)())
hook.Add('ShutDown', 'CCVCCM', (function()
  local _base_0 = CCVCCM
  local _fn_0 = _base_0.SaveData
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)())
hook.Add('CCVCCMDataLoad', 'CCVCCM', function(data)
  return table.Add(data, CCVCCM:_CreateElementData())
end)
hook.Add('Initialize', 'CCVCCM', function()
  return hook.Run('CCVCCMRun')
end)
hook.Add('CCVCCMRun', 'CCVCCM', function()
  CCVCCM:SetAddon('ccvccm', 'CCVCCM')
  CCVCCM:AddConVar('autoload', {
    realm = 'client',
    name = 'Autoloaded File',
    help = 'Layout to automatically load when CCVCCM is opened.',
    generate = true
  })
  CCVCCM:AddConVar('autosave_interval_client', {
    realm = 'client',
    name = 'Autosave Interval (Client)',
    help = 'Time between saves.',
    type = 'int',
    min = 30,
    max = 3600,
    generate = true
  })
  CCVCCM:AddConVar('autosave_interval_server', {
    realm = 'server',
    name = 'Autosave Interval (Server)',
    help = 'Time between saves.',
    type = 'int',
    min = 30,
    max = 3600,
    generate = true
  })
  cvars.AddChangeCallback('ccvccm_autosave_interval_client', (function(conVarName, oldValue, newValue)
    return timer.Adjust('ccvccm_autosave', tonumber(newValue))
  end), 'ccvccm_autosave')
  cvars.AddChangeCallback('ccvccm_autosave_interval_server', (function(conVarName, oldValue, newValue)
    return timer.Adjust('ccvccm_autosave', tonumber(newValue))
  end), 'ccvccm_autosave')
  CCVCCM:PushCategory('test', 'API Tests')
  CCVCCM:AddAddonVar('addonvar', {
    realm = 'client',
    name = 'Test AddonVar',
    help = 'This is a test AddonVar to demonstrate the capabilities of CCVCCM\'s API.',
    default = { },
    typeInfo = {
      help = 'You can insert any number of items in this list. Here, every list item also comes with their own list.',
      {
        name = 'Boolean Value',
        type = 'bool'
      },
      {
        name = 'Edit List',
        help = 'This is a sub-list within a list item. Note that the numeric slider is logarithmic.',
        {
          name = 'Text Value',
          type = 'string'
        },
        {
          name = 'Boolean Value',
          type = 'bool'
        },
        {
          name = 'Numeric Value',
          type = 'number',
          min = 1,
          max = 1e6,
          interval = 1,
          logarithmic = true
        }
      }
    },
    userInfo = true,
    notify = true,
    func = function(value, fullName, ply)
      if CCVCCM:ShouldLog() then
        if CLIENT then
          print(tostring(fullName) .. " on client:")
        end
        if SERVER then
          print(tostring(fullName) .. " from " .. tostring(ply) .. " on server:")
        end
        return PrintTable(value)
      end
    end
  })
  CCVCCM:AddAddonCommand('addoncommand', {
    realm = 'server',
    name = 'Test AddonCommand',
    help = 'This is a test AddonCommand to demonstrate the capabilities of CCVCCM\'s API.',
    func = function(ply, value, fullName)
      if CCVCCM:ShouldLog() then
        return print(tostring(ply) .. " has invoked ccvccm_addoncommand!")
      end
    end
  })
end)
CCVCCM._ConstructCategory = function(self, displayName, icon)
  return {
    name = displayName,
    icon = icon,
    useTab = false,
    layoutOrder = { },
    layoutData = { }
  }
end
CCVCCM._GenerateAndGetCategoryTable = function(self, category, categoryName)
  local currentTable = self:_GetCategoryTable()
  local newCategoryTable = currentTable.layoutData[category]
  if not (newCategoryTable) then
    table.insert(currentTable.layoutOrder, category)
    newCategoryTable = self:_ConstructCategory(categoryName)
    currentTable.layoutData[category] = newCategoryTable
  end
  return newCategoryTable
end
CCVCCM._GetCategoryTable = function(self, addon, categoryPath)
  if addon == nil then
    addon = self.api.addon
  end
  if categoryPath == nil then
    categoryPath = self.api.categoryPath
  end
  local currentTable = self.api.layout[addon]
  for _index_0 = 1, #categoryPath do
    local category = categoryPath[_index_0]
    assert(currentTable.layoutData[category], "failed to find " .. tostring(table.concat(categoryPath, '_')) .. " under " .. tostring(addon) .. "!")
    currentTable = currentTable.layoutData[category]
  end
  return currentTable
end
CCVCCM._GetRegisteredData = function(self, fullName)
  return self.api.data[fullName]
end
CCVCCM._GetCheatsEnabled = function(self)
  return GetConVar('sv_cheats'):GetBool()
end
CCVCCM._RegisterIntoCategory = function(self, name, registeredData, registeredType)
  local category = self:_GetCategoryTable()
  local categoryFullName = self:_AssembleVarName(name)
  local realFullName = registeredData.fullName or categoryFullName
  if not (self:_GetRegisteredData(categoryFullName)) then
    table.insert(category.layoutOrder, name)
  end
  do
    local _tbl_0 = { }
    local _list_0 = string.Explode('%s+', registeredData.hide or '', true)
    for _index_0 = 1, #_list_0 do
      local str = _list_0[_index_0]
      _tbl_0[str] = true
    end
    registeredData.hide = _tbl_0
  end
  do
    local _tbl_0 = { }
    local _list_0 = string.Explode('%s+', registeredData.flags or '', true)
    for _index_0 = 1, #_list_0 do
      local str = _list_0[_index_0]
      _tbl_0[str] = true
    end
    registeredData.flags = _tbl_0
  end
  self.api.data[realFullName] = {
    type = registeredType,
    data = registeredData
  }
  if categoryFullName ~= realFullName then
    self.api.aliases[categoryFullName] = realFullName
  end
end
CCVCCM._AssembleVarName = function(self, name, addon, categoryPath)
  if addon == nil then
    addon = self.api.addon
  end
  if categoryPath == nil then
    categoryPath = self.api.categoryPath
  end
  local nameFragments = {
    addon
  }
  for _index_0 = 1, #categoryPath do
    local category = categoryPath[_index_0]
    if category ~= "" then
      table.insert(nameFragments, category)
    end
  end
  table.insert(nameFragments, name)
  return table.concat(nameFragments, '_')
end
CCVCCM._GenerateConVar = function(self, name, data)
  local realm = data.realm or 'server'
  if realm == 'shared' or realm == 'server' and SERVER or realm == 'client' and CLIENT then
    local help, default, hide, flags, min, max, clamp, fullName
    help, default, hide, flags, min, max, clamp, fullName = data.help, data.default, data.hide, data.flags, data.min, data.max, data.clamp, data.fullName
    local archiveFlags = bit.bor(FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX)
    local conFlags = bit.bor(archiveFlags, FCVAR_PRINTABLEONLY)
    if data.userInfo then
      conFlags = bit.bor(conFlags, FCVAR_USERINFO)
    end
    if data.notify then
      conFlags = bit.bor(conFlags, FCVAR_NOTIFY)
    end
    local _exp_0 = realm
    if 'shared' == _exp_0 then
      conFlags = bit.bor(conFlags, FCVAR_REPLICATED)
    end
    if hide then
      if hide.client then
        conFlags = bit.bor(conFlags, FCVAR_PROTECTED)
      end
      if hide.server then
        conFlags = bit.bor(conFlags, FCVAR_SERVER_CANNOT_QUERY)
      end
      if hide.console then
        conFlags = bit.bor(conFlags, FCVAR_UNREGISTERED)
      end
      if hide.log then
        conFlags = bit.bor(conFlags, FCVAR_UNLOGGED)
      end
    end
    if flags then
      if flags.cheat then
        conFlags = bit.bor(conFlags, FCVAR_CHEAT)
      end
      if flags.nosave then
        conFlags = bit.band(conFlags, bit.bnot(archiveFlags))
      end
      if flags.sp then
        conFlags = bit.bor(conFlags, FCVAR_SPONLY)
      end
      if flags.control then
        if realm == 'shared' or data.userInfo or data.notify then
          error('control flag cannot be used in shared realm, .userInfo or .notify')
        end
        conFlags = bit.band(conFlags, bit.bnot(FCVAR_PRINTABLEONLY))
        conFlags = bit.bor(conFlags, FCVAR_NEVER_AS_STRING)
      end
      if flags.demo then
        conFlags = bit.bor(conFlags, FCVAR_DEMO)
      end
      if flags.nodemo then
        if flags.demo then
          error('demo and nodemo flags cannot be on the same ConVar!')
        end
        conFlags = bit.bor(conFlags, FCVAR_DONTRECORD)
      end
    end
    help = help or ''
    default = default or ''
    if not (clamp) then
      min = nil
      max = nil
    end
    fullName = fullName or self:_AssembleVarName(name)
    return CreateConVar(fullName, default, conFlags, help, min, max)
  end
end
CCVCCM._GenerateConCommand = function(self, name, data)
  local realm = data.realm
  if realm == 'shared' or realm == 'server' and SERVER or realm == 'client' and CLIENT then
    local help, func, autoComplete, choices, hide, flags, fullName
    help, func, autoComplete, choices, hide, flags, fullName = data.help, data.func, data.autoComplete, data.choices, data.hide, data.flags, data.fullName
    if not (autoComplete) then
      local choiceValuesLowercase
      do
        local _accum_0 = { }
        local _len_0 = 1
        for k, v in pairs(choices) do
          _accum_0[_len_0] = string.lower(v)
          _len_0 = _len_0 + 1
        end
        choiceValuesLowercase = _accum_0
      end
      autoComplete = function(cmd, argStr)
        local lowercaseArgStr = string.lower(string.Trim(argStr))
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #choiceValuesLowercase do
          local choice = choiceValuesLowercase[_index_0]
          if string.StartsWith(choice, lowercaseArgStr) then
            _accum_0[_len_0] = cmd .. ' ' .. choice
            _len_0 = _len_0 + 1
          end
        end
        return _accum_0
      end
    end
    local conFlags = 0
    if hide.console then
      conFlags = bit.bor(conFlags, FCVAR_UNREGISTERED)
    end
    if hide.log then
      conFlags = bit.bor(conFlags, FCVAR_UNLOGGED)
    end
    if flags.cheat then
      conFlags = bit.bor(conFlags, FCVAR_CHEAT)
    end
    if flags.sp then
      conFlags = bit.bor(conFlags, FCVAR_SPONLY)
    end
    if flags.demo then
      conFlags = bit.bor(conFlags, FCVAR_DEMO)
    end
    if flags.nodemo then
      if flags.demo then
        error('demo and nodemo flags cannot be on the same ConVar!')
      end
      conFlags = bit.bor(conFlags, FCVAR_DONTRECORD)
    end
    fullName = fullName or self:_AssembleVarName(name)
    return concommand.Add(fullName, func, autoComplete, help, conFlags)
  end
end
CCVCCM._SetAddonVar = function(self, fullName, value)
  self.api.addonVars[fullName] = value
end
CCVCCM._GetAddonVar = function(self, fullName)
  return self.api.addonVars[fullName]
end
CCVCCM._RevertDataByRegistered = function(self, registeredData, fullName)
  local registeredType, dataType, default
  registeredType, dataType, default = registeredData.type, registeredData.data.type, registeredData.data.default
  local _exp_0 = registeredType
  if 'convar' == _exp_0 then
    local conVar = GetConVar(fullName)
    if conVar then
      return conVar:Revert()
    end
  elseif 'addonvar' == _exp_0 then
    return self:SetVarValue(fullName, default)
  end
end
CCVCCM._CreateCategoryData = function(self, addon, categoryPath, categoryTable)
  local useTab, layoutOrder, layoutData
  useTab, layoutOrder, layoutData = categoryTable.useTab, categoryTable.layoutOrder, categoryTable.layoutData
  local saveTable = { }
  local tabsTable = { }
  for _index_0 = 1, #layoutOrder do
    local layoutKey = layoutOrder[_index_0]
    if layoutData[layoutKey] then
      table.insert(categoryPath, layoutKey)
      local tabData = layoutData[layoutKey]
      local tabTable = {
        displayName = tabData.name or layoutKey,
        icon = tabData.icon,
        content = self:_CreateCategoryData(addon, categoryPath, tabData)
      }
      table.remove(categoryPath)
      table.insert(tabsTable, tabTable)
    else
      local fullName = self:_AssembleVarName(layoutKey, addon, categoryPath)
      fullName = self.api.aliases[fullName] or fullName
      local registeredData = self:_GetRegisteredData(fullName)
      local name, help, realm, manual, dataType, sep, choices, min, max, interval, logarithmic
      do
        local _obj_0 = registeredData.data
        name, help, realm, manual, dataType, sep, choices, min, max, interval, logarithmic = _obj_0.name, _obj_0.help, _obj_0.realm, _obj_0.manual, _obj_0.type, _obj_0.sep, _obj_0.choices, _obj_0.min, _obj_0.max, _obj_0.interval, _obj_0.logarithmic
      end
      local _exp_0 = registeredData.type
      if 'convar' == _exp_0 then
        local newDataType = dataType or 'string'
        if choices then
          if sep then
            newDataType = 'choiceList'
          else
            newDataType = 'choice'
          end
        elseif dataType == 'int' then
          if sep then
            newDataType = 'numberList'
          else
            newDataType = 'number'
          end
          interval = math.max(math.Round(interval or 1), 1)
        elseif dataType == 'float' then
          if sep then
            newDataType = 'numberList'
          else
            newDataType = 'number'
          end
        elseif newDataType == 'string' and sep then
          newDataType = 'stringList'
        end
        table.insert(saveTable, {
          elementType = (function()
            if realm == 'client' then
              return 'clientConVar'
            else
              return 'serverConVar'
            end
          end)(),
          internalName = fullName,
          displayName = name or fullName,
          manual = manual,
          dataType = newDataType,
          listSeparator = sep,
          choices = choices,
          min = min,
          max = max,
          interval = interval,
          logarithmic = logarithmic
        })
      elseif 'concommand' == _exp_0 then
        local newDataType = dataType or 'none'
        if choices then
          if sep then
            newDataType = 'choiceList'
          else
            newDataType = 'choice'
          end
        elseif dataType == 'int' then
          if sep then
            newDataType = 'numberList'
          else
            newDataType = 'number'
          end
          interval = math.max(math.Round(interval or 1), 1)
        elseif dataType == 'float' then
          if sep then
            newDataType = 'numberList'
          else
            newDataType = 'number'
          end
        elseif dataType == 'string' and sep then
          newDataType = 'stringList'
        end
        table.insert(saveTable, {
          elementType = (function()
            if realm == 'client' then
              return 'clientConCommand'
            else
              return 'serverConCommand'
            end
          end)(),
          internalName = fullName,
          displayName = name or fullName,
          dataType = newDataType,
          listSeparator = sep,
          choices = choices,
          min = min,
          max = max,
          interval = interval,
          logarithmic = logarithmic
        })
      elseif 'addonvar' == _exp_0 or 'addoncommand' == _exp_0 then
        table.insert(saveTable, {
          elementType = 'addon',
          fullName = fullName
        })
      end
      if help then
        table.insert(saveTable, {
          elementType = 'text',
          displayName = help .. '\n'
        })
      end
    end
  end
  if next(tabsTable) then
    if useTab then
      table.insert(saveTable, {
        elementType = 'tabs',
        tabs = tabsTable
      })
    else
      for _index_0 = 1, #tabsTable do
        local tabTable = tabsTable[_index_0]
        table.insert(saveTable, {
          elementType = 'category',
          displayName = tabTable.displayName,
          content = tabTable.content
        })
      end
    end
  end
  return saveTable
end
CCVCCM._CreateElementData = function(self)
  local saveTable = { }
  self:Log('Layout stored by CCVCCM API:')
  if self:ShouldLog() then
    PrintTable(self.api.layout)
  end
  for addon, addonTable in SortedPairs(self.api.layout) do
    if next(addonTable.layoutOrder) then
      table.insert(saveTable, {
        displayName = addonTable.name or addon,
        icon = addonTable.icon,
        content = self:_CreateCategoryData(addon, { }, addonTable),
        static = true
      })
    end
  end
  self:Log('Resulting save table:')
  if self:ShouldLog() then
    PrintTable(saveTable)
  end
  return saveTable
end
CCVCCM.Pointer = function(self, fullName, ply)
  return CCVCCMPointer(fullName, ply)
end
CCVCCM.SetAddon = function(self, addon, display, icon)
  if addon == nil then
    addon = ''
  end
  self.api.addon = addon
  self.api.categoryPath = { }
  if addon ~= '' then
    local layout = self.api.layout
    local _update_0 = addon
    layout[_update_0] = layout[_update_0] or self:_ConstructCategory(display, icon)
  end
end
CCVCCM.PushCategory = function(self, name, display, tabs, icon)
  self:_GetCategoryTable().useTab = self:_GetCategoryTable().useTab or tabs
  self:_GenerateAndGetCategoryTable(name, display)
  return table.insert(self.api.categoryPath, name)
end
CCVCCM.PopCategory = function(self, num)
  if num == nil then
    num = 1
  end
  local categoryPath = self.api.categoryPath
  if num < 0 then
    categoryPath = { }
  else
    for i = 1, num do
      table.remove(categoryPath)
    end
  end
end
CCVCCM.NextCategory = function(self, name, display, tabs)
  if next(self.api.categoryPath) then
    self:PopCategory()
  end
  return self:PushCategory(name, display, tabs)
end
CCVCCM.AddConVar = function(self, name, registeredData)
  if not (registeredData.realm == 'client' and not registeredData.userInfo and SERVER) then
    self:_RegisterIntoCategory(name, registeredData, 'convar')
    if registeredData.generate then
      self:_GenerateConVar(name, registeredData)
    end
    return CCVCCMPointer(registeredData.fullName or self:_AssembleVarName(name))
  end
end
CCVCCM.AddConCommand = function(self, name, registeredData)
  if not (registeredData.realm == 'client' and SERVER) then
    self:_RegisterIntoCategory(name, registeredData, 'concommand')
    if registeredData.generate then
      self:_GenerateConCommand(name, registeredData)
    end
    return CCVCCMPointer(registeredData.fullName or self:_AssembleVarName(name))
  end
end
CCVCCM.AddAddonVar = function(self, name, registeredData)
  local noValue = registeredData.userInfo and SERVER
  if not (registeredData.realm == 'client' and not registeredData.userInfo and SERVER) then
    self:_RegisterIntoCategory(name, registeredData, 'addonvar')
    local fullName = registeredData.fullName or self:_AssembleVarName(name)
    if not (noValue) then
      if self:_GetAddonVar(fullName) == nil or registeredData.flags.nosave then
        self:_SetAddonVar(fullName, registeredData.default)
      end
      if registeredData.func then
        registeredData.func(self:_GetAddonVar(fullName), fullName)
      end
    end
    return CCVCCMPointer(fullName)
  end
end
CCVCCM.AddAddonCommand = function(self, name, registeredData)
  if not (registeredData.realm == 'client' and SERVER) then
    self:_RegisterIntoCategory(name, registeredData, 'addoncommand')
    return CCVCCMPointer(registeredData.fullName or self:_AssembleVarName(name))
  end
end
CCVCCM.GetVarValue = function(self, fullName, ply)
  if istable(fullName) then
    fullName = table.concat(fullName, '_')
  end
  fullName = self.api.aliases[fullName] or fullName
  local registeredData = self:_GetRegisteredData(fullName)
  if registeredData then
    local registeredType, dataType, sep, userInfo
    registeredType, dataType, sep, userInfo = registeredData.type, registeredData.data.type, registeredData.data.sep, registeredData.data.userInfo
    local _exp_0 = registeredType
    if 'convar' == _exp_0 then
      local conVar = GetConVar(fullName)
      if conVar then
        if sep then
          local values = string.Explode(sep, conVar:GetString())
          local _exp_1 = dataType
          if 'bool' == _exp_1 then
            local _accum_0 = { }
            local _len_0 = 1
            for _index_0 = 1, #values do
              local v = values[_index_0]
              _accum_0[_len_0] = tobool(v)
              _len_0 = _len_0 + 1
            end
            return _accum_0
          elseif 'int' == _exp_1 then
            local numbers = { }
            for _index_0 = 1, #values do
              local v = values[_index_0]
              if tonumber(v) then
                table.insert(numbers, math.floor(v))
              else
                table.insert(numbers, 0)
              end
            end
            return numbers
          elseif 'float' == _exp_1 then
            local _accum_0 = { }
            local _len_0 = 1
            for _index_0 = 1, #values do
              local v = values[_index_0]
              _accum_0[_len_0] = tonumber(v) or 0
              _len_0 = _len_0 + 1
            end
            return _accum_0
          else
            return values
          end
        else
          local _exp_1 = dataType
          if 'bool' == _exp_1 then
            return conVar:GetBool()
          elseif 'int' == _exp_1 then
            return conVar:GetInt()
          elseif 'float' == _exp_1 then
            return conVar:GetFloat()
          else
            return conVar:GetString()
          end
        end
      end
    elseif 'addonvar' == _exp_0 then
      if userInfo and SERVER then
        return CCVCCM:_GetUserInfoVar(fullName, ply)
      else
        return CCVCCM:_GetAddonVar(fullName)
      end
    end
  end
end
CCVCCM.SetVarValue = function(self, fullName, value)
  if istable(fullName) then
    fullName = table.concat(fullName, '_')
  end
  fullName = self.api.aliases[fullName] or fullName
  local registeredData = self:_GetRegisteredData(fullName)
  if registeredData then
    local registeredType, dataType, sep, userInfo, typeInfo, realm, notify, flags, func
    registeredType, dataType, sep, userInfo, typeInfo, realm, notify, flags, func = registeredData.type, registeredData.data.type, registeredData.data.sep, registeredData.data.userInfo, registeredData.data.typeInfo, registeredData.data.realm, registeredData.data.notify, registeredData.data.flags, registeredData.data.func
    local _exp_0 = registeredType
    if 'convar' == _exp_0 then
      local conVar = GetConVar(fullName)
      if conVar then
        if sep then
          local processedValues
          local _exp_1 = dataType
          if 'bool' == _exp_1 then
            do
              local _accum_0 = { }
              local _len_0 = 1
              for _index_0 = 1, #value do
                local v = value[_index_0]
                _accum_0[_len_0] = ((function()
                  if v then
                    return '1' or '0'
                  end
                end)())
                _len_0 = _len_0 + 1
              end
              processedValues = _accum_0
            end
          else
            do
              local _accum_0 = { }
              local _len_0 = 1
              for _index_0 = 1, #value do
                local v = value[_index_0]
                _accum_0[_len_0] = tostring(v)
                _len_0 = _len_0 + 1
              end
              processedValues = _accum_0
            end
          end
          conVar:SetString(table.concat(processedValues, ' '))
          return processedValues
        else
          local _exp_1 = dataType
          if 'bool' == _exp_1 then
            return conVar:SetBool(value)
          elseif 'int' == _exp_1 then
            return conVar:SetInt(value)
          elseif 'float' == _exp_1 then
            return conVar:SetFloat(value)
          else
            return conVar:SetString(value)
          end
        end
      end
    elseif 'addonvar' == _exp_0 then
      self:_SetAddonVar(fullName, value)
      if func then
        func(value, fullName)
      end
      if CLIENT and userInfo then
        local payload = {
          'u8',
          self.ENUMS.NET.REP,
          's',
          fullName
        }
        local _exp_1 = typeInfo.type
        if 'bool' == _exp_1 then
          table.insert(payload, 'b')
          table.insert(payload, value)
        elseif 'number' == _exp_1 then
          table.insert(payload, 'd')
          table.insert(payload, value)
        elseif 'string' == _exp_1 then
          table.insert(payload, 's')
          table.insert(payload, value)
        else
          table.insert(payload, 't')
          table.insert(payload, value)
        end
        self:Send(payload)
      end
      if SERVER then
        if notify then
          PrintMessage(HUD_PRINTTALK, "Server addon var '" .. tostring(fullName) .. "' changed to '" .. tostring(value) .. "'")
        end
        if realm == 'shared' then
          local payload = {
            'u8',
            self.ENUMS.NET.REP,
            's',
            fullName
          }
          table.insert(payload, self:GetNetSingleAddonType(fullName))
          table.insert(payload, value)
          return self:Send(payload)
        end
      end
    end
  end
end
CCVCCM.RevertVarValue = function(self, fullName)
  if istable(fullName) then
    fullName = table.concat(fullName, '_')
  end
  fullName = self.api.aliases[fullName] or fullName
  local registeredData = self:_GetRegisteredData(fullName)
  if registeredData then
    return self:_RevertDataByRegistered(registeredData, fullName)
  end
end
CCVCCM.RevertByAddonAndCategory = function(self, addon, ...)
  local categoryPath = {
    ...
  }
  local categoryTable = self:_GetCategoryTable(addon, categoryPath)
  local _list_0 = categoryTable.layoutOrder
  for _index_0 = 1, #_list_0 do
    local layoutKey = _list_0[_index_0]
    if categoryTable.layoutData[layoutKey] then
      table.insert(categoryPath, layoutKey)
      self:RevertByAddonAndCategory(addon, categoryPath)
      table.remove(categoryPath)
    else
      local fullName = self:_AssembleVarName(layoutKey, addon, categoryPath)
      fullName = self.api.aliases[fullName] or fullName
      local registeredData = self:_GetRegisteredData(fullName)
      self:_RevertDataByRegistered(registeredData, fullName)
    end
  end
end
CCVCCM.RunCommand = function(self, fullName, ply, value)
  if istable(fullName) then
    fullName = table.concat(fullName, '_')
  end
  local registeredData = self:_GetRegisteredData(fullName)
  if registeredData then
    local registeredType, dataType, sep, func
    registeredType, dataType, sep, func = registeredData.type, registeredData.data.type, registeredData.data.sep, registeredData.data.func
    local _exp_0 = registeredType
    if 'concommand' == _exp_0 then
      if sep then
        if dataType == 'bool' then
          do
            local _accum_0 = { }
            local _len_0 = 1
            for _index_0 = 1, #value do
              local v = value[_index_0]
              _accum_0[_len_0] = ((function()
                if v then
                  return '1' or '0'
                end
              end)())
              _len_0 = _len_0 + 1
            end
            value = _accum_0
          end
        else
          do
            local _accum_0 = { }
            local _len_0 = 1
            for _index_0 = 1, #value do
              local v = value[_index_0]
              _accum_0[_len_0] = tostring(v)
              _len_0 = _len_0 + 1
            end
            value = _accum_0
          end
        end
        return RunConsoleCommand(fullName, unpack(value))
      else
        if dataType == 'bool' then
          return RunConsoleCommand(fullName, (function()
            if value then
              return '1'
            else
              return '0'
            end
          end)())
        else
          return RunConsoleCommand(fullName, (function()
            if value then
              return tostring(value)
            else
              return ''
            end
          end)())
        end
      end
    elseif 'addoncommand' == _exp_0 then
      return func(ply, value, fullName)
    end
  end
end
return hook.Run('CCVCCMRun')