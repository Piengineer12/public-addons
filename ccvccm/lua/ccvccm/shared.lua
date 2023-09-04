CCVCCM.ENUMS = {
  NET = {
    REP = 1,
    EXEC = 2,
    QUERY = 3
  }
}
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
      elseif 'ts' == _exp_0 then
        net.WriteUInt(#sendUnit, 16)
        for _index_0 = 1, #sendUnit do
          local str = sendUnit[_index_0]
          net.WriteString(str)
        end
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
  elseif 'ts' == _exp_0 then
    local _accum_0 = { }
    local _len_0 = 1
    for i = 1, net.ReadUInt(16) do
      _accum_0[_len_0] = net.ReadString()
      _len_0 = _len_0 + 1
    end
    return _accum_0
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
CCVCCM.GetNetSingleAddonType = function(self, addon, categoryPath, name)
  local registeredData = CCVCCM:_GetRegisteredData(name, addon, categoryPath)
  if registeredData then
    local unitType
    local _exp_0 = registeredData.data.typeInfo.type
    if 'bool' == _exp_0 then
      return 'b'
    elseif 'number' == _exp_0 then
      return 'd'
    elseif 'keybind' == _exp_0 or 'string' == _exp_0 then
      return 's'
    else
      return 't'
    end
  end
end
local CCVCCMPointer
do
  local _class_0
  local _base_0 = {
    Get = function(self)
      return CCVCCM:GetVarValue(self.addon, self.categoryPath, self.name)
    end,
    Set = function(self, value)
      return CCVCCM:SetVarValue(self.addon, self.categoryPath, self.name, value)
    end,
    Revert = function(self)
      return CCVCCM:RevertVarValue(self.addon, self.categoryPath, self.name)
    end,
    Run = function(self, value)
      return CCVCCM:RunCommand(self.addon, self.categoryPath, self.name, value)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, name, addon, categoryPath)
      if addon == nil then
        addon = CCVCCM.api.addon
      end
      if categoryPath == nil then
        categoryPath = CCVCCM.api.categoryPath
      end
      self.addon = addon
      self.categoryPath = categories
      self.name = name
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
  data = {
    [''] = {
      name = 'Other',
      categories = { },
      categoriesOrder = { },
      categoriesUseTab = false,
      registered = { },
      registeredOrder = { }
    }
  },
  addonVars = {
    [''] = { }
  },
  addon = '',
  categoryPath = { }
}
if SERVER then
  CCVCCM.api.clientInfoVars = {
    [''] = { }
  }
end
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
    help = 'Layout to automatically load when CCVCCM is opened.'
  })
  CCVCCM:AddConVar('test', {
    realm = 'client',
    name = 'TESTING ONLY',
    type = 'string',
    sep = ' ',
    choices = {
      {
        "Display Name 1",
        "value1"
      },
      {
        "Display Name 2",
        "value2"
      }
    }
  })
  return CCVCCM:AddAddonVar('addonvar', {
    name = 'Display Name',
    help = 'Description',
    default = { },
    typeInfo = {
      name = 'Display Name 2',
      help = 'Description 2',
      {
        name = 'Display Name 3-1',
        type = 'bool'
      },
      {
        name = 'Display Name 3-2',
        help = 'Description 3-2',
        {
          name = 'Display Name 4-1',
          type = 'string',
          min = 1,
          max = 10,
          interval = 0.01,
          logarithmic = true
        },
        {
          name = 'Display Name 4-2',
          type = 'bool',
          min = 1,
          max = 10,
          interval = 0.01,
          logarithmic = true
        },
        {
          name = 'Display Name 4-3',
          type = 'number',
          min = 1,
          max = 10,
          interval = 0.01,
          logarithmic = true
        }
      }
    },
    notify = true
  })
end)
CCVCCM._ConstructCategory = function(self)
  return {
    categories = { },
    categoriesOrder = { },
    categoriesUseTab = false,
    registered = { },
    registeredOrder = { }
  }
end
CCVCCM._GetCategoryTable = function(self, addon, categoryPath)
  if addon == nil then
    addon = self.api.addon
  end
  if categoryPath == nil then
    categoryPath = self.api.categoryPath
  end
  local currentTable = self.api.data[addon]
  for _index_0 = 1, #categoryPath do
    local category = categoryPath[_index_0]
    if not (currentTable.categories[category]) then
      table.insert(currentTable.categoriesOrder, category)
      currentTable.categories[category] = self:_ConstructCategory()
    end
    currentTable = currentTable.categories[category]
  end
  return currentTable
end
CCVCCM._GetRegisteredData = function(self, name, addon, categoryPath)
  if addon == nil then
    addon = self.api.addon
  end
  if categoryPath == nil then
    categoryPath = self.api.categoryPath
  end
  local categoryTable = self:_GetCategoryTable(addon, categoryPath)
  return categoryTable.registered[name]
end
CCVCCM._GetCheatsEnabled = function(self)
  return GetConVar('sv_cheats'):GetBool()
end
CCVCCM._RegisterIntoCategory = function(self, internal, data, typ)
  local registered, registeredOrder
  do
    local _obj_0 = self:_GetCategoryTable()
    registered, registeredOrder = _obj_0.registered, _obj_0.registeredOrder
  end
  if not registered[internal] then
    table.insert(registeredOrder, internal)
  end
  if data.hide then
    do
      local _tbl_0 = { }
      local _list_0 = string.Explode('%s+', data.hide or '', true)
      for _index_0 = 1, #_list_0 do
        local str = _list_0[_index_0]
        _tbl_0[str] = true
      end
      data.hide = _tbl_0
    end
  end
  if data.flags then
    do
      local _tbl_0 = { }
      local _list_0 = string.Explode('%s+', data.flags or '', true)
      for _index_0 = 1, #_list_0 do
        local str = _list_0[_index_0]
        _tbl_0[str] = true
      end
      data.flags = _tbl_0
    end
  end
  registered[internal] = {
    type = typ,
    data = data
  }
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
    table.insert(nameFragments, category)
  end
  table.insert(nameFragments, name)
  return table.concat(nameFragments, '_')
end
CCVCCM._GenerateConVar = function(self, internal, data)
  local realm = data.realm or 'server'
  if realm == 'shared' or realm == 'server' and SERVER or realm == 'client' and CLIENT then
    local help, default, hide, flags, min, max, clamp
    help, default, hide, flags, min, max, clamp = data.help, data.default, data.hide, data.flags, data.min, data.max, data.clamp
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
    return CreateConVar(self:_AssembleVarName(internal), default, conFlags, help, min, max)
  end
end
CCVCCM._GenerateConCommand = function(self, internal, data)
  local realm = data.realm
  if realm == 'shared' or realm == 'server' and SERVER or realm == 'client' and CLIENT then
    local help, func, autoComplete, choices, hide, flags
    help, func, autoComplete, choices, hide, flags = data.help, data.func, data.autoComplete, data.choices, data.hide, data.flags
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
    return concommand.Add(self:_AssembleVarName(internal), func, autoComplete, help, conFlags)
  end
end
CCVCCM._SetAddonVar = function(self, internal, value, addon, categoryPath)
  if addon == nil then
    addon = self.api.addon
  end
  if categoryPath == nil then
    categoryPath = self.api.categoryPath
  end
  local _update_0 = addon
  self.api.addonVars[_update_0] = self.api.addonVars[_update_0] or { }
  local currentTable = self.api.addonVars[addon]
  for _index_0 = 1, #categoryPath do
    local category = categoryPath[_index_0]
    local _update_1 = category
    currentTable[_update_1] = currentTable[_update_1] or { }
    currentTable = currentTable[category]
  end
  currentTable[internal] = value
end
CCVCCM._GetAddonVar = function(self, internal, addon, categoryPath)
  if addon == nil then
    addon = self.api.addon
  end
  if categoryPath == nil then
    categoryPath = self.api.categoryPath
  end
  local _update_0 = addon
  self.api.addonVars[_update_0] = self.api.addonVars[_update_0] or { }
  local currentTable = self.api.addonVars[addon]
  for _index_0 = 1, #categoryPath do
    local category = categoryPath[_index_0]
    local _update_1 = category
    currentTable[_update_1] = currentTable[_update_1] or { }
    currentTable = currentTable[category]
  end
  return currentTable[internal]
end
CCVCCM._CreateCategoryData = function(self, addon, categoryPath, categoryTable)
  local categoryName, categories, categoriesOrder, categoriesUseTab, registeredOrder, registered
  categoryName, categories, categoriesOrder, categoriesUseTab, registeredOrder, registered = categoryTable.categoryName, categoryTable.categories, categoryTable.categoriesOrder, categoryTable.categoriesUseTab, categoryTable.registeredOrder, categoryTable.registered
  local saveTable = { }
  for _index_0 = 1, #registeredOrder do
    local registeredName = registeredOrder[_index_0]
    local elementData = registered[registeredName]
    local name, help, realm, manual, dataType, sep, choices, min, max, interval, logarithmic
    do
      local _obj_0 = elementData.data
      name, help, realm, manual, dataType, sep, choices, min, max, interval, logarithmic = _obj_0.name, _obj_0.help, _obj_0.realm, _obj_0.manual, _obj_0.type, _obj_0.sep, _obj_0.choices, _obj_0.min, _obj_0.max, _obj_0.interval, _obj_0.logarithmic
    end
    local _exp_0 = elementData.type
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
      local internalName = self:_AssembleVarName(registeredName, addon, categoryPath)
      table.insert(saveTable, {
        elementType = (function()
          if realm == 'client' then
            return 'clientConVar'
          else
            return 'serverConVar'
          end
        end)(),
        internalName = internalName,
        displayName = name or internalName,
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
      local internalName = self:_AssembleVarName(registeredName, addon, categoryPath)
      table.insert(saveTable, {
        elementType = (function()
          if realm == 'client' then
            return 'clientConCommand'
          else
            return 'serverConCommand'
          end
        end)(),
        internalName = internalName,
        displayName = name or internalName,
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
        internalName = {
          addon,
          categoryPath,
          registeredName
        }
      })
    end
    if help then
      table.insert(saveTable, {
        elementType = 'text',
        displayName = help
      })
    end
  end
  local tabsTable = { }
  for _index_0 = 1, #categoriesOrder do
    local category = categoriesOrder[_index_0]
    table.insert(categoryPath, category)
    local tabData = categories[category]
    local tabTable = {
      displayName = tabData.name or category,
      icon = tabData.icon,
      content = self:_CreateCategoryData(addon, categoryPath, tabData)
    }
    table.remove(categoryPath)
    table.insert(tabsTable, tabTable)
  end
  if categoriesUseTab then
    table.insert(saveTable, {
      type = "tabs",
      tabs = tabsTable
    })
  else
    for _index_0 = 1, #tabsTable do
      local tabTable = tabsTable[_index_0]
      table.insert(saveTable, {
        type = "category",
        displayName = tabTable.displayName,
        content = tabTable.content
      })
    end
  end
  return saveTable
end
CCVCCM._CreateElementData = function(self)
  local saveTable = { }
  for addon, addonTable in SortedPairs(self.api.data) do
    if next(addonTable.registered or next(addonTable.categories)) then
      table.insert(saveTable, {
        displayName = addonTable.name or addon,
        icon = addonTable.icon,
        content = self:_CreateCategoryData(addon, { }, addonTable),
        static = true
      })
    end
  end
  return saveTable
end
CCVCCM._RevertDataByRegistered = function(self, registeredData, addon, categoryPath, name)
  local registeredType, dataType, default
  registeredType, dataType, default = registeredData.type, registeredData.data.type, registeredData.data.default
  local _exp_0 = registeredType
  if 'convar' == _exp_0 then
    local conVar = GetConVar(self:_AssembleVarName(name, addon, categoryPath))
    if conVar then
      return conVar:Revert()
    end
  elseif 'addonvar' == _exp_0 then
    return self:SetVarValue(addon, categoryPath, name, default)
  end
end
CCVCCM.Pointer = function(self, addon, categoryPath, name)
  return CCVCCMPointer(name, addon, categoryPath)
end
CCVCCM.SetAddon = function(self, addon, display, icon)
  if addon == nil then
    addon = ''
  end
  local data = self.api.data
  local _update_0 = addon
  data[_update_0] = data[_update_0] or self:_ConstructCategory()
  self.api.addon = addon
  self.api.categoryPath = { }
  if addon ~= '' then
    local _update_1 = addon
    data[_update_1].name = data[_update_1].name or display
    local _update_2 = addon
    data[_update_2].icon = data[_update_2].icon or icon
  end
end
CCVCCM.PushCategory = function(self, internal, display, tabs, icon)
  self:_GetCategoryTable().categoriesUseTab = self:_GetCategoryTable().categoriesUseTab or tabs
  table.insert(self.api.categoryPath, internal)
  local categoryTable = self:_GetCategoryTable()
  categoryTable.name = categoryTable.name or display
  categoryTable.icon = categoryTable.icon or display
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
CCVCCM.NextCategory = function(self, internal, display, tabs)
  if next(self.api.categoryPath) then
    self:PopCategory()
  end
  return self:PushCategory(internal, display, tabs)
end
CCVCCM.AddConVar = function(self, internal, data)
  if not (data.realm == 'client' and data.userInfo and SERVER) then
    self:_RegisterIntoCategory(internal, data, 'convar')
    if not (data.uiOnly) then
      self:_GenerateConVar(internal, data)
    end
    return CCVCCMPointer(internal)
  end
end
CCVCCM.AddConCommand = function(self, internal, data)
  if not (data.realm == 'client' and SERVER) then
    self:_RegisterIntoCategory(internal, data, 'concommand')
    if not (data.uiOnly) then
      self:_GenerateConCommand(internal, data)
    end
    return CCVCCMPointer(internal)
  end
end
CCVCCM.AddAddonVar = function(self, internal, data)
  if not (data.realm == 'client' and SERVER) then
    self:_RegisterIntoCategory(internal, data, 'addonvar')
    self:_SetAddonVar(internal, data.default)
    return CCVCCMPointer(internal)
  end
end
CCVCCM.AddAddonCommand = function(self, internal, data)
  if not (data.realm == 'client' and SERVER) then
    self:_RegisterIntoCategory(internal, data, 'addoncommand')
    return CCVCCMPointer(internal)
  end
end
CCVCCM.GetVarValue = function(self, addon, categoryPath, name)
  local registeredData = self:_GetRegisteredData(name, addon, categoryPath)
  if registeredData then
    local registeredType, dataType, sep
    registeredType, dataType, sep = registeredData.type, registeredData.data.type, registeredData.data.sep
    local _exp_0 = registeredType
    if 'convar' == _exp_0 then
      local conVar = GetConVar(self:_AssembleVarName(name, addon, categoryPath))
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
      return CCVCCM:_GetAddonVar(name, addon, categoryPath)
    end
  end
end
CCVCCM.SetVarValue = function(self, addon, categoryPath, name, value)
  local registeredData = self:_GetRegisteredData(name, addon, categoryPath)
  if registeredData then
    local registeredType, dataType, sep, userInfo, typeInfo, realm, notify, flags
    registeredType, dataType, sep, userInfo, typeInfo, realm, notify, flags = registeredData.type, registeredData.data.type, registeredData.data.sep, registeredData.data.userInfo, registeredData.data.typeInfo, registeredData.data.realm, registeredData.data.notify, registeredData.data.flags
    local _exp_0 = registeredType
    if 'convar' == _exp_0 then
      local conVar = GetConVar(self:_AssembleVarName(name, addon, categoryPath))
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
      local oldValue = self:_GetAddonVar(name, addon, categoryPath)
      if oldValue ~= value then
        self:_SetAddonVar(name, value, addon, categoryPath)
        if CLIENT and userInfo then
          local payload = {
            'u8',
            self.ENUMS.NET.REP,
            's',
            addon,
            't',
            categoryPath,
            's',
            name
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
            local varName = self:_AssembleVarName(name, addon, categoryPath)
            PrintMessage(HUD_PRINTTALK, "Server addon var '" .. tostring(varName) .. "' changed to '" .. tostring(tostring(value)) .. "'")
          end
          if realm == 'shared' then
            local payload = {
              'u8',
              self.ENUMS.NET.REP,
              's',
              addon,
              't',
              categoryPath,
              's',
              name
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
            return self:Send(payload)
          end
        end
      end
    end
  end
end
CCVCCM.RevertVarValue = function(self, addon, categoryPath, name)
  if categoryPath == nil then
    categoryPath = { }
  end
  if name then
    local registeredData = self:_GetRegisteredData(name, addon, categoryPath)
    if registeredData then
      return self:_RevertDataByRegistered(registeredData, addon, categoryPath, name)
    end
  else
    local categoryTable = self:_GetCategoryTable(addon, categoryPath)
    for name, registeredData in pairs(categoryTable.registered) do
      self:_RevertDataByRegistered(registeredData, addon, categoryPath, name)
    end
    for category, subCategoryTable in pairs(categoryTable.categories) do
      table.insert(categoryPath, category)
      self:RevertVarValue(addon, categoryPath)
      table.remove(categoryPath)
    end
  end
end
CCVCCM.RunCommand = function(self, addon, categoryPath, name, value)
  local registeredData = self:_GetRegisteredData(name, addon, categoryPath)
  if registeredData then
    local registeredType, dataType, sep, func
    registeredType, dataType, sep, func = registeredData.type, registeredData.data.type, registeredData.data.sep, registeredData.data.func
    local _exp_0 = registeredType
    if 'concommand' == _exp_0 then
      local varName = self:_AssembleVarName(name, addon, categoryPath)
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
        return RunConsoleCommand(varName, unpack(value))
      else
        if dataType == 'bool' then
          return RunConsoleCommand(varName, (function()
            if value then
              return '1' or '0'
            end
          end)())
        else
          return RunConsoleCommand(varName, tostring(value))
        end
      end
    elseif 'addoncommand' == _exp_0 then
      return func(NULL, {
        addon,
        categoryPath,
        name
      }, value)
    end
  end
end
return hook.Run('CCVCCMRun')