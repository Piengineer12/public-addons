local ENUMS
ENUMS = CCVCCM.ENUMS
local GetBitflagFromIndices, BasePanel, CustomNumSlider, CustomPanelContainer, SavablePanel, ContentPanel, TextPanel, CategoryPanel, TabPanel, CAVACPanel, CCVCCPanel, BaseUI, ManagerUI, AddElementUI, EditIconUI, MultilineTextUI, ListInputUI, ProgressUI, LoadUI
CCVCCM.GetUserInfoValues = function(self)
  local results = { }
  for fullName, registeredData in pairs(self.api.data) do
    local userInfo, realm
    do
      local _obj_0 = registeredData.data
      userInfo, realm = _obj_0.userInfo, _obj_0.realm
    end
    if userInfo and realm == 'client' then
      table.insert(results, {
        fullName = fullName,
        type = self:GetNetSingleAddonType(fullName),
        value = self:_GetAddonVar(fullName)
      })
      coroutine.yield(false, results)
    end
  end
  return true, results
end
local avuiProcess
CCVCCM.StartAVUIProcess = function(self)
  avuiProcess = coroutine.create((function()
    local _base_0 = self
    local _fn_0 = _base_0.GetUserInfoValues
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)())
  return timer.UnPause('CCVCCM')
end
timer.Create('CCVCCM', 0.015, 0, function()
  if avuiProcess then
    local ok, status, results = coroutine.resume(avuiProcess)
    if not ok then
      return error(status, results)
    elseif #results > 64 or status then
      CCVCCM:StartNet()
      CCVCCM:AddPayloadToNetMessage({
        'u8',
        ENUMS.NET.INIT_REP,
        'b',
        status,
        'u8',
        #results
      })
      for i, result in ipairs(results) do
        CCVCCM:AddPayloadToNetMessage({
          's',
          result.fullName
        })
        CCVCCM:AddPayloadToNetMessage({
          result.type,
          result.value
        })
        results[i] = nil
      end
      CCVCCM:FinishNet()
      if status then
        avuiProcess = nil
      end
    end
  else
    return timer.Pause('CCVCCM')
  end
end)
hook.Add('InitPostEntity', 'CCVCCM', function()
  return CCVCCM:StartAVUIProcess()
end)
net.Receive('ccvccm', function(length)
  local operation = CCVCCM:ExtractSingleFromNetMessage('u8')
  local _exp_0 = operation
  if CCVCCM.ENUMS.NET.REP == _exp_0 then
    local fullName = CCVCCM:ExtractSingleFromNetMessage('s')
    local unitType = CCVCCM:GetNetSingleAddonType(fullName)
    local value = CCVCCM:ExtractSingleFromNetMessage(unitType)
    CCVCCM:Log('Recieved value of ', fullName, ':')
    if CCVCCM:ShouldLog() then
      PrintTable(value)
    end
    return CCVCCM:_SetAddonVar(fullName, value)
  elseif CCVCCM.ENUMS.NET.QUERY == _exp_0 then
    local cls = ManagerUI:GetInstance()
    if cls then
      for i = 1, CCVCCM:ExtractSingleFromNetMessage('u8') do
        local fullName = CCVCCM:ExtractSingleFromNetMessage('s')
        local registeredData = CCVCCM:_GetRegisteredData(fullName)
        if registeredData.type == 'addonvar' or registeredData.type == 'addoncommand' then
          local unitType = CCVCCM:GetNetSingleAddonType(fullName)
          local value = CCVCCM:ExtractSingleFromNetMessage(unitType)
          cls:ReceiveServerVarQueryResult(fullName, value)
        else
          local value = CCVCCM:ExtractSingleFromNetMessage('s')
          cls:ReceiveServerVarQueryResult(name, value)
        end
      end
    end
  elseif CCVCCM.ENUMS.NET.INIT_REP == _exp_0 then
    for i = 1, CCVCCM:ExtractSingleFromNetMessage('u8') do
      local fullName = CCVCCM:ExtractSingleFromNetMessage('s')
      local unitType = CCVCCM:GetNetSingleAddonType(fullName)
      local value = CCVCCM:ExtractSingleFromNetMessage(unitType)
      CCVCCM:_SetAddonVar(fullName, value)
    end
  end
end)
CCVCCM.CountTablesRecursive = function(self, items, acc, fillAccOnly)
  if acc == nil then
    acc = { }
  end
  if fillAccOnly == nil then
    fillAccOnly = false
  end
  acc[items] = true
  for k, v in pairs(items) do
    if istable(k) and not acc[k] then
      self:CountTablesRecursive(k, acc, true)
    end
    if istable(v) and not acc[v] then
      self:CountTablesRecursive(v, acc, true)
    end
  end
  if not (fillAccOnly) then
    return table.Count(acc)
  end
end
GetBitflagFromIndices = function(...)
  local result = 0
  local _list_0 = {
    ...
  }
  for _index_0 = 1, #_list_0 do
    local i = _list_0[_index_0]
    result = bit.bor(result, bit.lshift(1, i))
  end
  return result
end
concommand.Add('ccvccm_open', function()
  return ManagerUI(0.5, 0.5)
end)
do
  local _class_0
  local _base_0 = {
    Log = function(self, ...)
      return CCVCCM:Log(self:GetPanel(), ...)
    end,
    SetPanel = function(self, panel)
      self.panel = panel
    end,
    GetPanel = function(self)
      return self.panel
    end,
    SortPanelsByPosition = function(self, panels)
      return table.sort(panels, function(a, b)
        local ax, ay = a:LocalToScreen(0, 0)
        local bx, by = b:LocalToScreen(0, 0)
        return ax + ay < bx + by
      end)
    end,
    CreateButton = function(self, parent, name, zPos, icon)
      do
        local _with_0 = vgui.Create('DButton', parent)
        _with_0:SetText(name)
        if icon then
          _with_0:SetImage("icon16/" .. tostring(icon) .. ".png")
          _with_0:SizeToContentsX(44)
        else
          _with_0:SizeToContentsX(22)
        end
        if zPos then
          _with_0:SetZPos(zPos)
        end
        return _with_0
      end
    end,
    CreateLabel = function(self, parent, label, zPos)
      do
        local _with_0 = Label(label, parent)
        _with_0:SetWrap(true)
        _with_0:SetAutoStretchVertical(true)
        _with_0:SetZPos(zPos)
        return _with_0
      end
    end,
    WrapFunc = function(self, tbl, funcname, post, callback)
      local oldFunc = tbl[funcname]
      if oldFunc then
        tbl[funcname] = function(...)
          if not (post) then
            callback(...)
          end
          oldFunc(...)
          if post then
            return callback(...)
          end
        end
      else
        tbl[funcname] = callback
      end
    end,
    MakeDraggable = function(self, panel)
      local dragSystemName = string.format('ccvccm_%u', BasePanel.accumulator)
      panel:MakeDroppable(dragSystemName)
      BasePanel.accumulator = BasePanel.accumulator + 1
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "BasePanel"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.accumulator = 0
  BasePanel = _class_0
end
do
  local _class_0
  local _parent_0 = BasePanel
  local _base_0 = {
    clamp = false,
    logarithmic = false,
    negative = false,
    interval = 0.01,
    GetTextValue = function(self)
      return self:GetPanel().Scratch:GetTextValue()
    end,
    SetClamp = function(self, clamp)
      self.clamp = clamp
    end,
    SetText = function(self, text)
      local panel = self:GetPanel()
      if text then
        panel:SetText(text)
      end
      return panel.Label:SetVisible(text ~= nil)
    end,
    SetMinMax = function(self, ...)
      return self:GetPanel():SetMinMax(...)
    end,
    SetInterval = function(self, interval)
      self:GetPanel():SetDecimals(math.log10(math.abs(interval)))
      self.interval = interval
    end,
    SetLogarithmic = function(self, logarithmic)
      local panel = self:GetPanel()
      if self.logarithmic ~= logarithmic then
        if logarithmic then
          self.logarithmic = logarithmic
          self.negative = panel:GetMin() < 0
          panel:SetMin(self:UntranslateValue(panel:GetMin()))
          return panel:SetMax(self:UntranslateValue(panel:GetMax()))
        else
          panel:SetMin(self:TranslateValue(panel:GetMin()))
          panel:SetMax(self:TranslateValue(panel:GetMax()))
          self.logarithmic = logarithmic
        end
      end
    end,
    SetCallback = function(self, callback)
      self.callback = callback
    end,
    DetermineDecimals = function(self, interval)
      local floatStr = string.format('%.9f', interval)
      floatStr = string.TrimRight(floatStr, '0')
      return #(string.match(floatStr, '%.(.*)'))
    end,
    TranslateValue = function(self, value)
      if self.logarithmic then
        if self.negative then
          value = -(10 ^ value)
        else
          value = 10 ^ value
        end
      end
      if self.interval then
        value = math.floor(value / self.interval + 0.5) * self.interval
      end
      return value
    end,
    UntranslateValue = function(self, value)
      if self.logarithmic then
        return math.log10(math.abs(value))
      end
      return value
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, parent)
      _class_0.__parent.__init(self)
      do
        local panel = vgui.Create('DNumSlider', parent)
        panel.TextArea:SetNumeric(false)
        panel.Scratch.SetValue = function(scratch, val)
          val = tonumber(val)
          if val ~= nil then
            val = self:UntranslateValue(val)
            if val ~= scratch:GetFloatValue() then
              scratch:SetFloatValue(val)
              scratch:OnValueChanged(val)
              return scratch:UpdateConVar()
            end
          end
        end
        panel.Scratch.GetTextValue = function(scratch)
          local decimals = self:DetermineDecimals(self.interval)
          return string.format("%." .. tostring(decimals) .. "f", self:TranslateValue(scratch:GetFloatValue()))
        end
        panel.TranslateSliderValues = function(numSlider, x, y)
          numSlider:SetValue(self:TranslateValue(numSlider.Scratch:GetMin() + x * numSlider.Scratch:GetRange()))
          return numSlider.Scratch:GetFraction(), y
        end
        panel.SetValue = function(numSlider, value)
          value = tonumber(value)
          if value and numSlider:GetValue() ~= value then
            return numSlider.Scratch:SetValue(value)
          end
        end
        panel.GetValue = function(numSlider)
          return self:TranslateValue(numSlider.Scratch:GetFloatValue())
        end
        panel.ValueChanged = function(numSlider, value)
          value = tonumber(value)
          if value then
            if self.clamp then
              value = math.Clamp(value, numSlider:GetMin(), numSlider:GetMax())
            end
            numSlider.TextArea:SetValue(numSlider.Scratch:GetTextValue())
            numSlider.Slider:SetSlideX(numSlider.Scratch:GetFraction(value))
            return numSlider:OnValueChanged(self:TranslateValue(value))
          end
        end
        panel.OnValueChanged = function(numSlider, value)
          if self.callback then
            return self:callback(value)
          end
        end
        self:SetPanel(panel)
        return panel
      end
    end,
    __base = _base_0,
    __name = "CustomNumSlider",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  CustomNumSlider = _class_0
end
do
  local _class_0
  local _parent_0 = BasePanel
  local _base_0 = {
    stretchW = false,
    stretchH = false,
    vertical = false,
    space = 0,
    SetSpace = function(self, space)
      self.space = space
      return self:GetPanel():InvalidateLayout()
    end,
    SetVertical = function(self, vertical)
      self.vertical = vertical
      return self:GetPanel():InvalidateLayout()
    end,
    SetStretch = function(self, stretchW, stretchH)
      if stretchW == nil then
        stretchW = false
      end
      if stretchH == nil then
        stretchH = false
      end
      self.stretchW = stretchW
      self.stretchH = stretchH
      return self:GetPanel():InvalidateLayout()
    end,
    SetStretchRatio = function(self, ratio)
      self.stretchRatio = ratio
      return self:GetPanel():InvalidateLayout()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, parent)
      _class_0.__parent.__init(self)
      self.stretchRatio = { }
      local panel
      do
        local _with_0 = vgui.Create('DPanel', parent)
        _with_0.Paint = nil
        panel = _with_0
      end
      self:SetPanel(panel)
      self:WrapFunc(panel, 'PerformLayout', false, function(panel, w, h)
        local children = panel:GetChildren()
        local totalLength
        if self.vertical then
          totalLength = h
        else
          totalLength = w
        end
        local stretchOnLength
        if self.vertical then
          stretchOnLength = self.stretchH
        else
          stretchOnLength = self.stretchW
        end
        local stretchOnWidth
        if self.vertical then
          stretchOnWidth = self.stretchW
        else
          stretchOnWidth = self.stretchH
        end
        local childOffset
        if stretchOnLength then
          local childrenSpace = totalLength - self.space * (#children - 1)
          local totalWeightedLength = 0
          for i = 1, #children do
            totalWeightedLength = totalWeightedLength + (self.stretchRatio[i] or 1)
          end
          for i, child in ipairs(children) do
            local childWeightedLength = self.stretchRatio[i] or 1
            local childLength = childrenSpace * childWeightedLength / totalWeightedLength
            if self.vertical then
              child:SetTall(childLength)
            else
              child:SetWide(childLength)
            end
          end
          childOffset = 0
        else
          local childrenLength = -self.space
          for _index_0 = 1, #children do
            local child = children[_index_0]
            local childLength
            if self.vertical then
              childLength = child:GetTall()
            else
              childLength = child:GetWide()
            end
            childrenLength = childrenLength + (childLength + self.space)
          end
          childrenLength = math.max(childrenLength, 0)
          childOffset = (totalLength - childrenLength) / 2
        end
        if stretchOnWidth then
          for _index_0 = 1, #children do
            local child = children[_index_0]
            if self.vertical then
              child:SetWide(w)
            else
              child:SetTall(h)
            end
          end
        end
        for _index_0 = 1, #children do
          local child = children[_index_0]
          if self.vertical then
            child:SetY(childOffset)
            child:CenterHorizontal()
            childOffset = childOffset + child:GetTall()
          else
            child:SetX(childOffset)
            child:CenterVertical()
            childOffset = childOffset + child:GetWide()
          end
        end
      end)
      return self:WrapFunc(panel, 'OnChildAdded', false, function(self, child)
        return self:InvalidateLayout()
      end)
    end,
    __base = _base_0,
    __name = "CustomPanelContainer",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  CustomPanelContainer = _class_0
end
do
  local _class_0
  local _parent_0 = BasePanel
  local _base_0 = {
    RegisterAsSavable = function(self)
      SavablePanel.panelClasses[self:GetPanel()] = self
    end,
    UnregisterAsSavable = function(self)
      SavablePanel.panelClasses[self:GetPanel()] = nil
    end,
    UpdateSavables = function(self)
      for panel, cls in pairs(SavablePanel.panelClasses) do
        if not (IsValid(panel)) then
          SavablePanel.panelClasses[panel] = nil
        end
      end
    end,
    RemoveClassAndPanel = function(self)
      self:UnregisterAsSavable()
      return self:GetPanel():Remove()
    end,
    GetSavableClassFromPanel = function(self, panel)
      if panel == nil then
        panel = self:GetPanel()
      end
      return SavablePanel.panelClasses[panel]
    end,
    InitializeElementPanel = function(self, parent, static)
      local panel
      do
        local _with_0 = vgui.Create('DPanel', parent)
        if not (static) then
          _with_0:SetCursor('sizeall')
        end
        _with_0:Dock(TOP)
        _with_0.Paint = nil
        panel = _with_0
      end
      self:SetPanel(panel)
      self:WrapFunc(panel, 'PerformLayout', false, function(self, w, h)
        self:SizeToChildren(false, true)
        return CCVCCM:Log(self, 'PerformLayout')
      end)
      self:RegisterAsSavable()
      return panel
    end,
    PromptDelete = function(self)
      return Derma_Query('Are you sure?', 'Delete', 'Yes', (function()
        local _base_1 = self
        local _fn_0 = _base_1.RemoveClassAndPanel
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), 'No')
    end,
    SaveToClipboard = function(self)
      SavablePanel.lastCopied = util.TableToJSON(self:SaveToTable())
      SetClipboardText(SavablePanel.lastCopied)
      return Derma_Message('Element copied!', 'Copy', 'OK')
    end,
    GetLastCopiedPanel = function(self)
      return SavablePanel.lastCopied
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "SavablePanel",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.panelClasses = { }
  self.lastCopied = ''
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  SavablePanel = _class_0
end
do
  local _class_0
  local _parent_0 = SavablePanel
  local _base_0 = {
    GetControlPanel = function(self)
      return self.controlPanel
    end,
    GetStatic = function(self)
      return self.static
    end,
    AddElement = function(self, data)
      if data == nil then
        data = { }
      end
      local ETYPES = AddElementUI.ELEMENT_TYPES
      local createdPanel
      local _exp_0 = data.elementType
      if ETYPES.TEXT == _exp_0 then
        local classPanel = TextPanel(self.items, data, self.window, self.static)
        createdPanel = classPanel:GetPanel()
      elseif ETYPES.CATEGORY == _exp_0 then
        local classPanel = CategoryPanel(self.items, data, self.window, self.static)
        createdPanel = classPanel:GetPanel()
      elseif ETYPES.TABS == _exp_0 then
        local classPanel = TabPanel(self.items, data, self.window, self.static)
        createdPanel = classPanel:GetPanel()
      elseif ETYPES.CLIENT_CCMD == _exp_0 or ETYPES.CLIENT_CVAR == _exp_0 or ETYPES.SERVER_CCMD == _exp_0 or ETYPES.SERVER_CVAR == _exp_0 then
        local classPanel = CCVCCPanel(self.items, data, self.window, self.static)
        createdPanel = classPanel:GetPanel()
      elseif ETYPES.ADDON == _exp_0 then
        local classPanel = CAVACPanel(self.items, data, self.window, self.static)
        createdPanel = classPanel:GetPanel()
      end
      return createdPanel
    end,
    AddControlPanel = function(self, panel)
      return self.window:AddControlPanel(panel)
    end,
    GetTabAndParent = function(self)
      local panel = self:GetPanel()
      local parent = panel:GetParent()
      local _list_0 = parent:GetItems()
      for _index_0 = 1, #_list_0 do
        local _des_0 = _list_0[_index_0]
        local Tab, Panel
        Tab, Panel = _des_0.Tab, _des_0.Panel
        if Panel == panel then
          return Tab, parent
        end
      end
    end,
    PromptAddElement = function(self)
      if IsValid(self.addUI) then
        self.addUI:Close()
      end
      do
        local _with_0 = AddElementUI(0.5, 0.5)
        _with_0:SetCallback(function(classData, ...)
          return self:AddElement(...)
        end)
        self.addUI = _with_0
      end
    end,
    PromptRenameTab = function(self)
      local tab, container = self:GetTabAndParent()
      return Derma_StringRequest('Rename', 'Enter new tab name:', tab:GetText(), function(newName)
        tab:SetText(newName)
        return container:InvalidateChildren()
      end)
    end,
    PromptDeleteTab = function(self)
      return Derma_Query('Are you sure?', 'Delete', 'Yes', (function()
        local _base_1 = self
        local _fn_0 = _base_1.DeleteTab
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), 'No')
    end,
    FilterElements = function(self, text)
      local children = self.items:GetChildren()
      for _index_0 = 1, #children do
        local child = children[_index_0]
        local cls = self:GetSavableClassFromPanel(child)
        cls:FilterElements(text)
      end
    end,
    DeleteTab = function(self)
      self:UnregisterAsSavable()
      local tab, container = self:GetTabAndParent()
      local items = container:GetItems()
      if #items == 1 then
        container:Remove()
      else
        container:CloseTab(tab, true)
      end
      return self:UpdateSavables()
    end,
    SaveToTable = function(self)
      local children = self.items:GetChildren()
      self:SortPanelsByPosition(children)
      local saveTable = { }
      for _index_0 = 1, #children do
        local child = children[_index_0]
        local cls = self:GetSavableClassFromPanel(child)
        table.insert(saveTable, cls:SaveToTable())
        coroutine.yield()
      end
      return saveTable
    end,
    ReformatData = function(self, data)
      local ETYPES = AddElementUI.ELEMENT_TYPES
      local DTYPES = AddElementUI.DATA_TYPES
      local _exp_0 = data.elementType
      if 'text' == _exp_0 then
        data.elementType = ETYPES.TEXT
      elseif 'category' == _exp_0 then
        data.elementType = ETYPES.CATEGORY
      elseif 'tabs' == _exp_0 then
        data.elementType = ETYPES.TABS
      elseif 'clientConVar' == _exp_0 then
        data.elementType = ETYPES.CLIENT_CVAR
      elseif 'clientConCommand' == _exp_0 then
        data.elementType = ETYPES.CLIENT_CCMD
      elseif 'serverConVar' == _exp_0 then
        data.elementType = ETYPES.SERVER_CVAR
      elseif 'serverConCommand' == _exp_0 then
        data.elementType = ETYPES.SERVER_CCMD
      elseif 'addon' == _exp_0 then
        data.elementType = ETYPES.ADDON
      end
      local _exp_1 = data.dataType
      if 'none' == _exp_1 then
        data.dataType = DTYPES.NONE
      elseif 'bool' == _exp_1 then
        data.dataType = DTYPES.BOOL
      elseif 'choices' == _exp_1 then
        data.dataType = DTYPES.CHOICE
      elseif 'keybind' == _exp_1 then
        data.dataType = DTYPES.KEYBIND
      elseif 'number' == _exp_1 then
        data.dataType = DTYPES.NUMBER
      elseif 'string' == _exp_1 then
        data.dataType = DTYPES.STRING
      elseif 'choiceList' == _exp_1 then
        data.dataType = DTYPES.CHOICE_LIST
      elseif 'numberList' == _exp_1 then
        data.dataType = DTYPES.NUMBER_LIST
      elseif 'stringList' == _exp_1 then
        data.dataType = DTYPES.STRING_LIST
      end
      return data
    end,
    LoadFromTable = function(self, contentsData)
      if contentsData == nil then
        contentsData = { }
      end
      for _index_0 = 1, #contentsData do
        local rawData = contentsData[_index_0]
        local data = table.Copy(rawData)
        self:ReformatData(data)
        self:AddElement(data)
        coroutine.yield()
      end
    end,
    LoadFromClipboard = function(self, text)
      local data = util.JSONToTable(text)
      if data then
        self:ReformatData(data)
        return self:AddElement(data)
      else
        return Derma_Message('Couldn\'t parse decoded element!', 'Paste Error', 'OK')
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, contentType, window, static)
      if static == nil then
        static = false
      end
      _class_0.__parent.__init(self)
      self.window = window
      local panel
      do
        local _with_0 = vgui.Create('DPanel')
        _with_0.CenterVertical = function() end
        panel = _with_0
      end
      self:SetPanel(panel)
      self:RegisterAsSavable()
      self.static = static
      self:WrapFunc(panel, 'PerformLayout', false, function(self, w, h)
        self:SizeToChildren(false, true)
        return CCVCCM:Log(self, 'PerformLayout')
      end)
      do
        local _with_0 = vgui.Create('DTextEntry', panel)
        _with_0:SetZPos(2)
        _with_0:Dock(TOP)
        _with_0:SetPlaceholderText('Search...')
        _with_0.OnChange = function(textEntry)
          return self:FilterElements(string.lower(textEntry:GetValue()))
        end
        _with_0.OnValueChange = _with_0.OnChange
      end
      do
        local _with_0 = vgui.Create('DIconLayout', panel)
        _with_0:SetZPos(3)
        _with_0:Dock(TOP)
        if not (static) then
          _with_0:SetDropPos('28')
          _with_0:SetUseLiveDrag(true)
          _with_0:MakeDroppable('ccvccm_content', true)
        end
        self.items = _with_0
      end
      if not (static) then
        do
          local _with_0 = vgui.Create('DPanel', panel)
          _with_0:SetTall(22)
          _with_0:SetZPos(1)
          _with_0:Dock(TOP)
          _with_0.Paint = nil
          self.controlPanel = _with_0
        end
        do
          local _with_0 = self:CreateButton(self.controlPanel, 'Add Element', 1, 'add')
          _with_0:Dock(LEFT)
          do
            local _base_1 = self
            local _fn_0 = _base_1.PromptAddElement
            _with_0.DoClick = function(...)
              return _fn_0(_base_1, ...)
            end
          end
        end
        do
          local _with_0 = self:CreateButton(self.controlPanel, 'Paste Contents', 4, 'page_white_paste')
          _with_0:Dock(LEFT)
          _with_0.DoClick = function()
            local pasteText = self:GetLastCopiedPanel()
            if pasteText == '' then
              return Derma_StringRequest('Paste', 'Enter panel data:', '', function(pasteText)
                return self:LoadFromClipboard(pasteText)
              end)
            else
              return self:LoadFromClipboard(pasteText)
            end
          end
        end
        if contentType == 'tab' then
          do
            local _with_0 = self:CreateButton(self.controlPanel, 'Rename Tab', 2, 'pencil')
            _with_0:Dock(LEFT)
            do
              local _base_1 = self
              local _fn_0 = _base_1.PromptRenameTab
              _with_0.DoClick = function(...)
                return _fn_0(_base_1, ...)
              end
            end
          end
          do
            local _with_0 = self:CreateButton(self.controlPanel, 'Edit Icon', 3, 'image_edit')
            _with_0:Dock(LEFT)
            _with_0.DoClick = function()
              if IsValid(self.addUI) then
                self.addUI:Close()
              end
              local tab, container = self:GetTabAndParent()
              local icon
              if tab.Image then
                icon = tab.Image:GetImage()
              else
                icon = ''
              end
              self.addUI = EditIconUI(0.5, 0.5, icon, function(newImage)
                if newImage == nil then
                  newImage = ''
                end
                if newImage ~= '' then
                  if not (IsValid(tab.Image)) then
                    tab.Image = vgui.Create('DImage', tab)
                  end
                  do
                    local _with_1 = tab.Image
                    _with_1:SetImage(newImage)
                    _with_1:SizeToContents()
                  end
                elseif IsValid(tab.Image) then
                  tab.Image:Remove()
                  tab.Image = nil
                end
                tab:InvalidateLayout()
                return container:InvalidateChildren()
              end)
            end
          end
          do
            local _with_0 = self:CreateButton(self.controlPanel, 'Delete Tab', 5, 'delete')
            _with_0:Dock(LEFT)
            do
              local _base_1 = self
              local _fn_0 = _base_1.PromptDeleteTab
              _with_0.DoClick = function(...)
                return _fn_0(_base_1, ...)
              end
            end
            return _with_0
          end
        end
      end
    end,
    __base = _base_0,
    __name = "ContentPanel",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ContentPanel = _class_0
end
do
  local _class_0
  local _parent_0 = SavablePanel
  local _base_0 = {
    PromptRenameDisplay = function(self)
      return MultilineTextUI(0.5, 0.5, self.label:GetText(), function(newName)
        return self.label:SetText(newName)
      end)
    end,
    FilterElements = function(self, text)
      do
        local _with_0 = self:GetPanel()
        _with_0:SetVisible(tobool(string.find(string.lower(self.label:GetText()), text, 1, true)))
        _with_0:GetParent():InvalidateLayout()
        _with_0:GetParent():GetParent():InvalidateLayout()
        return _with_0
      end
    end,
    SaveToTable = function(self)
      return {
        elementType = "text",
        displayName = self.label:GetText()
      }
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, parent, data, window, static)
      _class_0.__parent.__init(self)
      self.window = window
      local panel = self:InitializeElementPanel(parent, static)
      do
        local controlPanel = vgui.Create('DPanel', panel)
        controlPanel:SetTall(22)
        controlPanel:SetZPos(1)
        controlPanel:DockMargin(0, 22, 0, 0)
        controlPanel:Dock(TOP)
        controlPanel.Paint = nil
        do
          local _with_0 = self:CreateButton(controlPanel, 'Copy Element', 2, 'page_white_copy')
          _with_0:Dock(LEFT)
          _with_0.DoClick = function()
            return self:SaveToClipboard()
          end
        end
        if not (static) then
          do
            local _with_0 = self:CreateButton(controlPanel, 'Edit', 1, 'pencil')
            _with_0:Dock(LEFT)
            _with_0.DoClick = function()
              return self:PromptRenameDisplay()
            end
          end
          do
            local _with_0 = self:CreateButton(controlPanel, 'Delete', 3, 'delete')
            _with_0:Dock(LEFT)
            _with_0.DoClick = function()
              return self:PromptDelete()
            end
          end
        end
        window:AddControlPanel(controlPanel)
      end
      local labelParent
      do
        local _with_0 = vgui.Create('DSizeToContents', panel)
        _with_0:SetSizeX(false)
        _with_0:SetZPos(2)
        _with_0:DockPadding(4, 4, 4, 4)
        _with_0:Dock(TOP)
        labelParent = _with_0
      end
      do
        local _with_0 = self:CreateLabel(labelParent, (data.displayName or ''))
        _with_0:Dock(TOP)
        _with_0:SetDark(true)
        _with_0:SetMouseInputEnabled(true)
        if not (static) then
          _with_0.DoDoubleClick = function()
            if self.window:GetControlPanelVisibility() then
              return self:PromptRenameDisplay()
            end
          end
        end
        self.label = _with_0
      end
    end,
    __base = _base_0,
    __name = "TextPanel",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  TextPanel = _class_0
end
do
  local _class_0
  local _parent_0 = SavablePanel
  local _base_0 = {
    PromptRenameDisplay = function(self)
      local categoryHeader = self.category.Header
      return Derma_StringRequest('Rename', 'Enter new category name:', categoryHeader:GetText(), function(newName)
        return categoryHeader:SetText(newName)
      end)
    end,
    FilterElements = function(self, text)
      return self.contentPanel:FilterElements(text)
    end,
    SaveToTable = function(self)
      return {
        elementType = "category",
        displayName = self.category.Header:GetText(),
        content = self.contentPanel:SaveToTable()
      }
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, parent, data, window, static)
      _class_0.__parent.__init(self)
      self.window = window
      local panel = self:InitializeElementPanel(parent, static)
      do
        local controlPanel = vgui.Create('DPanel', panel)
        controlPanel:SetTall(22)
        controlPanel:SetZPos(1)
        controlPanel:DockMargin(0, 22, 0, 0)
        controlPanel:Dock(TOP)
        controlPanel.Paint = nil
        do
          local _with_0 = self:CreateButton(controlPanel, 'Copy Element', 2, 'page_white_copy')
          _with_0:Dock(LEFT)
          _with_0.DoClick = function()
            return self:SaveToClipboard()
          end
        end
        if not (static) then
          do
            local _with_0 = self:CreateButton(controlPanel, 'Rename', 1, 'pencil')
            _with_0:Dock(LEFT)
            _with_0.DoClick = function()
              return self:PromptRenameDisplay()
            end
          end
          do
            local _with_0 = self:CreateButton(controlPanel, 'Delete', 3, 'delete')
            _with_0:Dock(LEFT)
            _with_0.DoClick = function()
              return self:PromptDelete()
            end
          end
        end
        window:AddControlPanel(controlPanel)
      end
      local hostPanel
      do
        local _with_0 = vgui.Create('DSizeToContents', panel)
        _with_0:SetSizeX(false)
        _with_0:SetZPos(2)
        _with_0:DockPadding(4, 0, 4, 0)
        _with_0:Dock(TOP)
        hostPanel = _with_0
      end
      self.contentPanel = ContentPanel('category', window, static)
      do
        local _with_0 = vgui.Create('DCollapsibleCategory', hostPanel)
        _with_0:SetCursor('sizeall')
        _with_0:SetLabel(data.displayName or 'New Category')
        _with_0:SetContents(self.contentPanel:GetPanel())
        _with_0:SetList(parent)
        _with_0:Dock(TOP)
        if not (static) then
          _with_0.Header.DoDoubleClick = function()
            if window:GetControlPanelVisibility() then
              return self:PromptRenameDisplay()
            end
          end
        end
        self.category = _with_0
      end
      self:WrapFunc(self.category, 'OnRemove', false, function()
        return self:UpdateSavables()
      end)
      self.contentPanel:LoadFromTable(data.content)
      return window:AddControlPanel(self.contentPanel:GetControlPanel())
    end,
    __base = _base_0,
    __name = "CategoryPanel",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  CategoryPanel = _class_0
end
do
  local _class_0
  local _parent_0 = SavablePanel
  local _base_0 = {
    AddTab = function(self, displayName, icon, content)
      if displayName == nil then
        displayName = 'New Tab'
      end
      local contentPanel = ContentPanel('tab', self.window, self.static)
      local tab
      tab = self.sheet:AddSheet(displayName, contentPanel:GetPanel(), icon, false, true).Tab
      if not (self.static) then
        tab.DoDoubleClick = function()
          if self.window:GetControlPanelVisibility() then
            return contentPanel:PromptRenameTab()
          end
        end
      end
      self.window:AddControlPanel(contentPanel:GetControlPanel())
      return contentPanel:LoadFromTable(content)
    end,
    FilterElements = function(self, text)
      local _list_0 = self.sheet:GetItems()
      for _index_0 = 1, #_list_0 do
        local _des_0 = _list_0[_index_0]
        local panel
        panel = _des_0.Panel
        self:GetSavableClassFromPanel(panel):FilterElements(text)
      end
    end,
    SaveToTable = function(self)
      local generalSaveTable = {
        elementType = 'tabs'
      }
      local tabs = self.sheet.tabScroller:GetCanvas():GetChildren()
      self:SortPanelsByPosition(tabs)
      local tabContentClasses
      do
        local _tbl_0 = { }
        local _list_0 = self.sheet:GetItems()
        for _index_0 = 1, #_list_0 do
          local _des_0 = _list_0[_index_0]
          local tab, panel
          tab, panel = _des_0.Tab, _des_0.Panel
          _tbl_0[tab] = self:GetSavableClassFromPanel(panel)
        end
        tabContentClasses = _tbl_0
      end
      local saveTable = { }
      for i, tab in ipairs(tabs) do
        local tabSaveTable = {
          displayName = tab:GetText(),
          content = tabContentClasses[tab]:SaveToTable()
        }
        if tab.Image then
          tabSaveTable.icon = tab.Image:GetImage()
        end
        saveTable[i] = tabSaveTable
        coroutine.yield()
      end
      generalSaveTable.tabs = saveTable
      return generalSaveTable
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, parent, data, window, static)
      _class_0.__parent.__init(self)
      self.window = window
      local panel = self:InitializeElementPanel(parent, static)
      self.static = static
      do
        local controlPanel = vgui.Create('DPanel', panel)
        controlPanel:SetTall(22)
        controlPanel:SetZPos(1)
        controlPanel:DockMargin(0, 22, 0, 0)
        controlPanel:Dock(TOP)
        controlPanel.Paint = nil
        do
          local _with_0 = self:CreateButton(controlPanel, 'Copy Element', 2, 'page_white_copy')
          _with_0:Dock(LEFT)
          _with_0.DoClick = function()
            return self:SaveToClipboard()
          end
        end
        if not (static) then
          do
            local _with_0 = self:CreateButton(controlPanel, 'Add Tab', 1, 'add')
            _with_0:Dock(LEFT)
            _with_0.DoClick = function()
              return self:AddTab()
            end
          end
        end
        window:AddControlPanel(controlPanel)
      end
      do
        local _with_0 = vgui.Create('DPropertySheet', panel)
        _with_0:SetZPos(2)
        _with_0:Dock(TOP)
        _with_0.tabScroller:SetUseLiveDrag(true)
        self:MakeDraggable(_with_0.tabScroller)
        self.sheet = _with_0
      end
      self:WrapFunc(self.sheet, 'OnRemove', false, function()
        return self:RemoveClassAndPanel()
      end)
      self:WrapFunc(self.sheet, 'PerformLayout', true, function(self, w, h)
        local padding = self:GetPadding()
        panel = self:GetActiveTab():GetPanel()
        self:SetTall(panel:GetTall() + 20 + padding * 2)
        return CCVCCM:Log(self, 'PerformLayout')
      end)
      if data.tabs then
        local _list_0 = data.tabs
        for _index_0 = 1, #_list_0 do
          local tabData = _list_0[_index_0]
          self:AddTab(tabData.displayName, tabData.icon, tabData.content)
        end
      else
        return self:AddTab()
      end
    end,
    __base = _base_0,
    __name = "TabPanel",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  TabPanel = _class_0
end
do
  local _class_0
  local _parent_0 = SavablePanel
  local _base_0 = {
    SetArgs = function(self, arguments)
      self.arguments = arguments
    end,
    SendToServer = function(self)
      local fullName = self.data.fullName
      local payload = {
        'u8',
        CCVCCM.ENUMS.NET.EXEC,
        'b',
        true,
        's',
        fullName
      }
      table.insert(payload, CCVCCM:GetNetSingleAddonType(fullName))
      table.insert(payload, self.arguments)
      return CCVCCM:Send(payload)
    end,
    UpdateAddonVar = function(self)
      local elementType, fullName
      do
        local _obj_0 = self.data
        elementType, fullName = _obj_0.elementType, _obj_0.fullName
      end
      local registeredData = CCVCCM:_GetRegisteredData(fullName)
      if registeredData then
        local apiType, realm, flags, func
        apiType, realm, flags, func = registeredData.type, registeredData.data.realm, registeredData.data.flags, registeredData.data.func
        if flags then
          if flags.cheat and not CCVCCM:_GetCheatsEnabled() then
            return Derma_Message('sv_cheats must be enabled!', 'Runtime Error', 'OK')
          elseif flags.sp and not game.SinglePlayer() then
            return Derma_Message('Game must be singleplayer!', 'Runtime Error', 'OK')
          end
        end
        if realm == 'client' then
          if apiType == 'addonvar' then
            return CCVCCM:SetVarValue(fullName, self.arguments)
          else
            return CCVCCM:RunCommand(fullName, LocalPlayer(), self.arguments)
          end
        else
          return self:SendToServer()
        end
      end
    end,
    TranslateTypeInfo = function(self, component, parentTable)
      local DTYPES = AddElementUI.DATA_TYPES
      local name, help, compType, choices, min, max, interval, logarithmic
      name, help, compType, choices, min, max, interval, logarithmic = component.name, component.help, component.type, component.choices, component.min, component.max, component.interval, component.logarithmic
      if parentTable then
        parentTable.names = parentTable.names or { }
        table.insert(parentTable.names, name)
      end
      local dataType = {
        name = name,
        header = help,
        choices = choices,
        min = min,
        max = max,
        interval = interval,
        logarithmic = logarithmic
      }
      if choices then
        dataType.dataType = DTYPES.CHOICE
      else
        local _exp_0 = compType
        if 'bool' == _exp_0 then
          dataType.dataType = DTYPES.BOOL
        elseif 'keybind' == _exp_0 then
          dataType.dataType = DTYPES.KEYBIND
        elseif 'number' == _exp_0 then
          dataType.dataType = DTYPES.NUMBER
        elseif 'string' == _exp_0 then
          dataType.dataType = DTYPES.STRING
        else
          dataType.dataType = DTYPES.COMPLEX_LIST
          do
            local _accum_0 = { }
            local _len_0 = 1
            for _index_0 = 1, #component do
              local v = component[_index_0]
              _accum_0[_len_0] = self:TranslateTypeInfo(v, dataType)
              _len_0 = _len_0 + 1
            end
            dataType.types = _accum_0
          end
        end
      end
      return dataType
    end,
    FilterElements = function(self, text)
      local fullName
      fullName = self.data.fullName
      local displayName
      displayName = CCVCCM:_GetRegisteredData(fullName).data.name
      local haystack = string.lower(fullName .. '\n' .. displayName)
      do
        local _with_0 = self:GetPanel()
        _with_0:SetVisible(tobool(string.find(haystack, text, 1, true)))
        _with_0:GetParent():InvalidateLayout()
        _with_0:GetParent():GetParent():InvalidateLayout()
        return _with_0
      end
    end,
    SaveToTable = function(self)
      return {
        fullName = self.data.fullName,
        elementType = 'addon',
        arguments = self.arguments
      }
    end,
    SetValue = function(self, value)
      self.arguments = value
      if IsValid(self.rawPanel) then
        if self.rawPanel.SetSelectedNumber then
          self.rawPanel:SetSelectedNumber(input.GetKeyCode(value))
        else
          self.rawPanel:SetValue(value)
        end
        if self.rawPanel.Data then
          for choiceIndex, data in pairs(self.rawPanel.Data) do
            if data == value then
              self.rawPanel:ChooseOptionID(choiceIndex)
              break
            end
          end
        end
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, parent, data, window, static)
      _class_0.__parent.__init(self)
      self.data = data
      self.window = window
      self:InitializeElementPanel(parent, static)
      local panel = self:GetPanel()
      local arguments, fullName
      arguments, fullName = data.arguments, data.fullName
      local apiType, realm, displayName, default, manual, typeInfo
      do
        local _obj_0 = CCVCCM:_GetRegisteredData(fullName)
        apiType, realm, displayName, default, manual, typeInfo = _obj_0.type, _obj_0.data.realm, _obj_0.data.name, _obj_0.data.default, _obj_0.data.manual, _obj_0.data.typeInfo
      end
      local DTYPES = AddElementUI.DATA_TYPES
      local dataType = self:TranslateTypeInfo(typeInfo)
      self:Log('TranslateTypeInfo')
      if CCVCCM:ShouldLog() then
        PrintTable(dataType)
      end
      local isClient = realm == 'client'
      local isVar = apiType == 'addonvar'
      if not isVar and arguments ~= nil then
        self.arguments = arguments
      else
        self.arguments = CCVCCM:_GetAddonVar(fullName)
      end
      do
        local controlPanel = vgui.Create('DPanel', panel)
        controlPanel:SetTall(22)
        controlPanel:SetZPos(1)
        controlPanel:DockMargin(0, 22, 0, 0)
        controlPanel:Dock(TOP)
        controlPanel.Paint = nil
        do
          local _with_0 = self:CreateButton(controlPanel, 'Copy Element', nil, 'page_white_copy')
          _with_0:Dock(LEFT)
          _with_0.DoClick = function()
            return self:SaveToClipboard()
          end
        end
        if not (static) then
          do
            local _with_0 = self:CreateButton(controlPanel, 'Delete', 3, 'delete')
            _with_0:Dock(LEFT)
            _with_0.DoClick = function()
              return self:PromptDelete()
            end
          end
        end
        self.window:AddControlPanel(controlPanel)
      end
      if not isVar or manual then
        local buttonText
        if isVar then
          buttonText = 'Apply Changes'
        elseif dataType.dataType == DTYPES.NONE then
          buttonText = displayName
        else
          buttonText = 'Run ConCommand'
        end
        do
          local _with_0 = self:CreateButton(panel, buttonText, 3)
          _with_0:Dock(TOP)
          do
            local _base_1 = self
            local _fn_0 = _base_1.UpdateAddonVar
            _with_0.DoClick = function(...)
              return _fn_0(_base_1, ...)
            end
          end
        end
      end
      local _exp_0 = dataType.dataType
      if DTYPES.BOOL == _exp_0 then
        local hostPanel
        do
          local _with_0 = vgui.Create('DSizeToContents', panel)
          _with_0:SetSizeX(false)
          _with_0:SetZPos(2)
          _with_0:DockPadding(4, 0, 0, 0)
          _with_0:Dock(TOP)
          hostPanel = _with_0
        end
        do
          local _with_0 = vgui.Create('DCheckBoxLabel', hostPanel)
          _with_0:SetValue(self.arguments)
          _with_0:Dock(TOP)
          _with_0:SetText(displayName)
          _with_0:SetDark(true)
          _with_0.OnChange = function(panel, checked)
            self:SetArgs(checked)
            if not (manual) then
              return self:UpdateAddonVar()
            end
          end
          self.rawPanel = _with_0
        end
      elseif DTYPES.CHOICE == _exp_0 then
        local hostPanelClass
        do
          local _with_0 = CustomPanelContainer(panel)
          _with_0:SetStretch(true, true)
          _with_0:SetStretchRatio({
            1,
            1.4
          })
          hostPanelClass = _with_0
        end
        local hostPanel
        do
          local _with_0 = hostPanelClass:GetPanel()
          _with_0:SetTall(22)
          _with_0:SetZPos(2)
          _with_0:Dock(TOP)
          _with_0.Paint = nil
          hostPanel = _with_0
        end
        do
          local _with_0 = self:CreateLabel(hostPanel, displayName)
          _with_0:SetTextInset(4, 0)
          _with_0:SetContentAlignment(4)
          _with_0:SetDark(true)
        end
        do
          local _with_0 = vgui.Create('DComboBox', hostPanel)
          _with_0.OnSelect = function(panel, index, value, selectedData)
            local returnVal
            if selectedData ~= nil then
              returnVal = selectedData
            else
              returnVal = value
            end
            self:SetArgs(returnVal)
            if not (manual) then
              return self:UpdateAddonVar()
            end
          end
          self.rawPanel = _with_0
        end
        for i, choicesInfo in ipairs(dataType.choices) do
          local k, v
          k, v = choicesInfo[1], choicesInfo[2]
          self.rawPanel:AddChoice(k, v, self.arguments == v)
        end
      elseif DTYPES.KEYBIND == _exp_0 then
        local hostPanelClass
        do
          local _with_0 = CustomPanelContainer(panel)
          _with_0:SetStretch(true, true)
          _with_0:SetStretchRatio({
            1,
            1.4
          })
          hostPanelClass = _with_0
        end
        local hostPanel
        do
          local _with_0 = hostPanelClass:GetPanel()
          _with_0:SetTall(22)
          _with_0:SetZPos(2)
          _with_0:Dock(TOP)
          _with_0.Paint = nil
          hostPanel = _with_0
        end
        do
          local _with_0 = self:CreateLabel(hostPanel, displayName)
          _with_0:SetTextInset(4, 0)
          _with_0:SetContentAlignment(4)
          _with_0:SetDark(true)
        end
        do
          local _with_0 = vgui.Create('DBinder', hostPanel)
          _with_0:SetSelectedNumber(input.GetKeyCode((self.arguments or '')))
          _with_0.OnChange = function(panel, value)
            self:SetArgs(input.GetKeyName(value))
            if not (manual) then
              return self:UpdateAddonVar()
            end
          end
          self.rawPanel = _with_0
        end
      elseif DTYPES.NUMBER == _exp_0 then
        do
          local _with_0 = CustomNumSlider(panel)
          _with_0:SetText(displayName)
          _with_0:SetMinMax(tonumber(dataType.min), tonumber(dataType.max))
          if dataType.interval then
            _with_0:SetInterval(tonumber(dataType.interval))
          end
          _with_0:SetLogarithmic(dataType.logarithmic)
          _with_0:SetCallback(function(classData, value)
            self:SetArgs(value)
            if not (manual) then
              return self:UpdateAddonVar()
            end
          end)
          self.rawPanel = _with_0:GetPanel()
          do
            local _with_1 = self.rawPanel
            _with_1:SetValue(self.arguments)
            _with_1:SetDark(true)
            _with_1.Label:SetTextInset(4, 0)
            _with_1:SetZPos(2)
            _with_1:Dock(TOP)
          end
        end
      elseif DTYPES.STRING == _exp_0 then
        local hostPanelClass
        do
          local _with_0 = CustomPanelContainer(panel)
          _with_0:SetStretch(true, true)
          _with_0:SetStretchRatio({
            1,
            1.4
          })
          hostPanelClass = _with_0
        end
        local hostPanel
        do
          local _with_0 = hostPanelClass:GetPanel()
          _with_0:SetTall(22)
          _with_0:SetZPos(2)
          _with_0:Dock(TOP)
          _with_0.Paint = nil
          hostPanel = _with_0
        end
        do
          local _with_0 = self:CreateLabel(hostPanel, displayName)
          _with_0:SetTextInset(4, 0)
          _with_0:SetContentAlignment(4)
          _with_0:SetDark(true)
        end
        do
          local _with_0 = vgui.Create('DTextEntry', hostPanel)
          _with_0:SetValue(self.arguments)
          _with_0.OnChange = function(textEntry)
            self:SetArgs(textEntry:GetValue())
            if not (manual) then
              return self:UpdateAddonVar()
            end
          end
          _with_0.OnValueChange = _with_0.OnChange
          self.rawPanel = _with_0
        end
      elseif DTYPES.COMPLEX_LIST == _exp_0 then
        local hostPanelClass
        do
          local _with_0 = CustomPanelContainer(panel)
          _with_0:SetStretch(true, true)
          _with_0:SetStretchRatio({
            1,
            1.4
          })
          hostPanelClass = _with_0
        end
        local hostPanel
        do
          local _with_0 = hostPanelClass:GetPanel()
          _with_0:SetTall(22)
          _with_0:SetZPos(2)
          _with_0:Dock(TOP)
          _with_0.Paint = nil
          hostPanel = _with_0
        end
        do
          local _with_0 = self:CreateLabel(hostPanel, displayName)
          _with_0:SetTextInset(4, 0)
          _with_0:SetContentAlignment(4)
          _with_0:SetDark(true)
        end
        do
          local _with_0 = self:CreateButton(hostPanel, dataType.name or 'Edit List', 2)
          _with_0.DoClick = function()
            local listInputUI = ListInputUI(0.5, 0.5, dataType, self.arguments)
            return listInputUI:SetCallback(function(classData, values)
              self:SetArgs(values)
              if not (manual) then
                return self:UpdateAddonVar()
              end
            end)
          end
        end
      end
      if (realm or 'server') == 'server' then
        return self.window:AddServerVarQueryRequest(fullName, self)
      end
    end,
    __base = _base_0,
    __name = "CAVACPanel",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  CAVACPanel = _class_0
end
do
  local _class_0
  local _parent_0 = SavablePanel
  local _base_0 = {
    arguments = '',
    SetArgs = function(self, arguments)
      self.arguments = arguments
    end,
    SendToServer = function(self)
      return CCVCCM:Send({
        'u8',
        CCVCCM.ENUMS.NET.EXEC,
        'b',
        false,
        's',
        self.data.internalName .. ' ' .. self.arguments
      })
    end,
    PopulatePanel = function(self)
      local data = self.data
      local panel = self:GetPanel()
      local displayName, dataType, elementType, internalName, manual
      displayName, dataType, elementType, internalName, manual = data.displayName, data.dataType, data.elementType, data.internalName, data.manual
      local DTYPES = AddElementUI.DATA_TYPES
      local ETYPES = AddElementUI.ELEMENT_TYPES
      local isClient = elementType == ETYPES.CLIENT_CCMD or elementType == ETYPES.CLIENT_CVAR
      local isVar = elementType == ETYPES.CLIENT_CVAR or elementType == ETYPES.SERVER_CVAR
      do
        local controlPanel = vgui.Create('DPanel', panel)
        controlPanel:SetTall(22)
        controlPanel:SetZPos(1)
        controlPanel:DockMargin(0, 22, 0, 0)
        controlPanel:Dock(TOP)
        controlPanel.Paint = nil
        do
          local _with_0 = self:CreateButton(controlPanel, 'Copy Element', 2, 'page_white_copy')
          _with_0:Dock(LEFT)
          _with_0.DoClick = function()
            return self:SaveToClipboard()
          end
        end
        if not (self.static) then
          do
            local _with_0 = self:CreateButton(controlPanel, 'Edit', 1, 'pencil')
            _with_0:Dock(LEFT)
            _with_0.DoClick = function()
              return self:PromptEditPanel()
            end
          end
          do
            local _with_0 = self:CreateButton(controlPanel, 'Delete', 3, 'delete')
            _with_0:Dock(LEFT)
            _with_0.DoClick = function()
              return self:PromptDelete()
            end
          end
        end
        self.window:AddControlPanel(controlPanel)
      end
      local clickFunc
      clickFunc = function()
        if isClient then
          return LocalPlayer():ConCommand(internalName .. ' ' .. self.arguments)
        else
          return self:SendToServer()
        end
      end
      if not isVar or manual then
        local buttonText
        if isVar then
          buttonText = 'Apply Changes'
        elseif dataType == DTYPES.NONE then
          buttonText = displayName
        else
          buttonText = 'Run ConCommand'
        end
        do
          local _with_0 = self:CreateButton(panel, buttonText, 3)
          _with_0:Dock(TOP)
          _with_0.DoClick = clickFunc
        end
      end
      local _exp_0 = dataType
      if DTYPES.BOOL == _exp_0 then
        local hostPanel
        do
          local _with_0 = vgui.Create('DSizeToContents', panel)
          _with_0:SetSizeX(false)
          _with_0:SetZPos(2)
          _with_0:DockPadding(4, 0, 0, 0)
          _with_0:Dock(TOP)
          hostPanel = _with_0
        end
        do
          local _with_0 = vgui.Create('DCheckBoxLabel', hostPanel)
          _with_0:SetValue(self.arguments)
          _with_0:Dock(TOP)
          _with_0:SetText(displayName)
          _with_0:SetDark(true)
          _with_0.OnChange = function(panel, checked)
            self:SetArgs(checked and '1' or '0')
            if not (isClient or manual) then
              return self:SendToServer()
            end
          end
          if elementType == ETYPES.CLIENT_CVAR and not manual then
            _with_0:SetConVar(internalName)
          end
          self.rawPanel = _with_0
        end
      elseif DTYPES.CHOICE == _exp_0 then
        local hostPanelClass
        do
          local _with_0 = CustomPanelContainer(panel)
          _with_0:SetStretch(true, true)
          _with_0:SetStretchRatio({
            1,
            1.4
          })
          hostPanelClass = _with_0
        end
        local hostPanel
        do
          local _with_0 = hostPanelClass:GetPanel()
          _with_0:SetTall(22)
          _with_0:SetZPos(2)
          _with_0:Dock(TOP)
          _with_0.Paint = nil
          hostPanel = _with_0
        end
        do
          local _with_0 = self:CreateLabel(hostPanel, displayName)
          _with_0:SetTextInset(4, 0)
          _with_0:SetContentAlignment(4)
          _with_0:SetDark(true)
        end
        do
          local _with_0 = vgui.Create('DComboBox', hostPanel)
          _with_0.OnSelect = function(panel, index, value, selectedData)
            local returnVal = tostring((function()
              if selectedData ~= nil then
                return selectedData
              else
                return value
              end
            end)())
            self:SetArgs(returnVal)
            if panel.m_strConVar then
              return LocalPlayer():ConCommand(panel.m_strConVar .. ' ' .. returnVal)
            elseif not (isClient or manual) then
              return self:SendToServer()
            end
          end
          if elementType == ETYPES.CLIENT_CVAR and not manual then
            _with_0:SetConVar(internalName)
          end
          self.rawPanel = _with_0
        end
        for i, choicesInfo in ipairs(data.choices) do
          local k, v
          k, v = choicesInfo[1], choicesInfo[2]
          self.rawPanel:AddChoice(k, v, self.arguments == v)
        end
      elseif DTYPES.KEYBIND == _exp_0 then
        local hostPanelClass
        do
          local _with_0 = CustomPanelContainer(panel)
          _with_0:SetStretch(true, true)
          _with_0:SetStretchRatio({
            1,
            1.4
          })
          hostPanelClass = _with_0
        end
        local hostPanel
        do
          local _with_0 = hostPanelClass:GetPanel()
          _with_0:SetTall(22)
          _with_0:SetZPos(2)
          _with_0:Dock(TOP)
          _with_0.Paint = nil
          hostPanel = _with_0
        end
        do
          local _with_0 = self:CreateLabel(hostPanel, displayName)
          _with_0:SetTextInset(4, 0)
          _with_0:SetContentAlignment(4)
          _with_0:SetDark(true)
        end
        do
          local _with_0 = vgui.Create('DBinder', hostPanel)
          _with_0:SetSelectedNumber(input.GetKeyCode(self.arguments))
          _with_0.OnChange = function(panel, value)
            self:SetArgs(input.GetKeyName(value))
            if not (isClient or manual) then
              return self:SendToServer()
            end
          end
          if elementType == ETYPES.CLIENT_CVAR and not manual then
            _with_0:SetConVar(internalName)
          end
          self.rawPanel = _with_0
        end
      elseif DTYPES.NUMBER == _exp_0 then
        do
          local _with_0 = CustomNumSlider(panel)
          _with_0:SetText(displayName)
          _with_0:SetMinMax(tonumber(data.min), tonumber(data.max))
          if data.interval then
            _with_0:SetInterval(tonumber(data.interval))
          end
          _with_0:SetLogarithmic(data.logarithmic)
          _with_0:SetCallback(function(classData, value)
            self:SetArgs(classData:GetTextValue())
            if not (isClient or manual) then
              return self:SendToServer()
            end
          end)
          self.rawPanel = _with_0:GetPanel()
          do
            local _with_1 = self.rawPanel
            _with_1:SetValue(self.arguments)
            _with_1:SetDark(true)
            _with_1.Label:SetTextInset(4, 0)
            _with_1:SetZPos(2)
            _with_1:Dock(TOP)
            if elementType == ETYPES.CLIENT_CVAR and not manual then
              _with_1:SetConVar(internalName)
            end
          end
        end
      elseif DTYPES.STRING == _exp_0 then
        local hostPanelClass
        do
          local _with_0 = CustomPanelContainer(panel)
          _with_0:SetStretch(true, true)
          _with_0:SetStretchRatio({
            1,
            1.4
          })
          hostPanelClass = _with_0
        end
        local hostPanel
        do
          local _with_0 = hostPanelClass:GetPanel()
          _with_0:SetTall(22)
          _with_0:SetZPos(2)
          _with_0:Dock(TOP)
          _with_0.Paint = nil
          hostPanel = _with_0
        end
        do
          local _with_0 = self:CreateLabel(hostPanel, displayName)
          _with_0:SetTextInset(4, 0)
          _with_0:SetContentAlignment(4)
          _with_0:SetDark(true)
        end
        do
          local _with_0 = vgui.Create('DTextEntry', hostPanel)
          _with_0:SetValue(self.arguments)
          _with_0.GetAutoComplete = function(self, value)
            local possibilities = concommand.AutoComplete(internalName, value)
            if possibilities then
              local startPos = #internalName + 2
              local _accum_0 = { }
              local _len_0 = 1
              for _index_0 = 1, #possibilities do
                local item = possibilities[_index_0]
                _accum_0[_len_0] = string.sub(item, startPos)
                _len_0 = _len_0 + 1
              end
              return _accum_0
            end
          end
          _with_0.OnChange = function(textEntry)
            self:SetArgs(textEntry:GetValue())
            if not (isClient or manual) then
              return self:SendToServer()
            end
          end
          _with_0.OnValueChange = _with_0.OnChange
          if elementType == ETYPES.CLIENT_CVAR and not manual then
            _with_0:SetConVar(internalName)
          end
          self.rawPanel = _with_0
        end
      elseif DTYPES.CHOICE_LIST == _exp_0 or DTYPES.NUMBER_LIST == _exp_0 or DTYPES.STRING_LIST == _exp_0 then
        local hostPanelClass
        do
          local _with_0 = CustomPanelContainer(panel)
          _with_0:SetStretch(true, true)
          _with_0:SetStretchRatio({
            1,
            1.4
          })
          hostPanelClass = _with_0
        end
        local hostPanel
        do
          local _with_0 = hostPanelClass:GetPanel()
          _with_0:SetTall(22)
          _with_0:SetZPos(2)
          _with_0:Dock(TOP)
          _with_0.Paint = nil
          hostPanel = _with_0
        end
        do
          local _with_0 = self:CreateLabel(hostPanel, displayName)
          _with_0:SetTextInset(4, 0)
          _with_0:SetContentAlignment(4)
          _with_0:SetDark(true)
        end
        local listSeparator = data.listSeparator or ' '
        do
          local _with_0 = self:CreateButton(hostPanel, 'Edit List', 2)
          _with_0.DoClick = function()
            local conVarValue = self.arguments
            if elementType == ETYPES.CLIENT_CVAR and not manual then
              local conVar = GetConVar(internalName)
              if conVar then
                conVarValue = conVar:GetString()
              end
            end
            local listValues
            do
              local _accum_0 = { }
              local _len_0 = 1
              local _list_0 = string.Explode(listSeparator, conVarValue)
              for _index_0 = 1, #_list_0 do
                local str = _list_0[_index_0]
                _accum_0[_len_0] = {
                  str
                }
                _len_0 = _len_0 + 1
              end
              listValues = _accum_0
            end
            local individualDataType
            local _exp_1 = dataType
            if DTYPES.CHOICE_LIST == _exp_1 then
              individualDataType = DTYPES.CHOICE
            elseif DTYPES.NUMBER_LIST == _exp_1 then
              individualDataType = DTYPES.NUMBER
            elseif DTYPES.STRING_LIST == _exp_1 then
              individualDataType = DTYPES.STRING
            end
            local listInputUI = ListInputUI(0.5, 0.5, {
              header = 'Enter values:',
              types = {
                {
                  dataType = individualDataType,
                  choices = data.choices,
                  min = data.min,
                  max = data.max,
                  interval = data.interval,
                  logarithmic = data.logarithmic
                }
              }
            }, listValues)
            return listInputUI:SetCallback(function(classData, values)
              local flattenedValues
              do
                local _accum_0 = { }
                local _len_0 = 1
                for _index_0 = 1, #values do
                  local value = values[_index_0]
                  _accum_0[_len_0] = tostring(value[1])
                  _len_0 = _len_0 + 1
                end
                flattenedValues = _accum_0
              end
              local strValue = table.concat(flattenedValues, listSeparator)
              self:SetArgs(strValue)
              if elementType == ETYPES.CLIENT_CVAR and not manual then
                return LocalPlayer():ConCommand(internalName .. ' ' .. strValue)
              elseif not (isClient or manual) then
                return self:SendToServer()
              end
            end)
          end
        end
      end
      if elementType == ETYPES.SERVER_CVAR and not GetConVar(internalName) then
        return self.window:AddServerVarQueryRequest(internalName, self)
      end
    end,
    PromptEditPanel = function(self)
      do
        local _with_0 = AddElementUI(0.5, 0.5, self.data)
        _with_0:SetCallback(function(classData, newData)
          self.data = newData
          local _list_0 = self:GetPanel():GetChildren()
          for _index_0 = 1, #_list_0 do
            local panel = _list_0[_index_0]
            panel:Remove()
          end
          self.arguments = ''
          return self:PopulatePanel()
        end)
        return _with_0
      end
    end,
    FilterElements = function(self, text)
      local haystack = string.lower(self.data.internalName .. '\n' .. self.data.displayName)
      do
        local _with_0 = self:GetPanel()
        _with_0:SetVisible(tobool(string.find(haystack, text, 1, true)))
        _with_0:GetParent():InvalidateLayout()
        _with_0:GetParent():GetParent():InvalidateLayout()
        return _with_0
      end
    end,
    SaveToTable = function(self)
      local data = self.data
      local saveTable = {
        internalName = data.internalName,
        displayName = data.displayName,
        arguments = self.arguments,
        manual = data.manual
      }
      local elementTypeStr
      local ETYPES = AddElementUI.ELEMENT_TYPES
      local _exp_0 = data.elementType
      if ETYPES.CLIENT_CVAR == _exp_0 then
        elementTypeStr = 'clientConVar'
      elseif ETYPES.CLIENT_CCMD == _exp_0 then
        elementTypeStr = 'clientConCommand'
      elseif ETYPES.SERVER_CVAR == _exp_0 then
        elementTypeStr = 'serverConVar'
      elseif ETYPES.SERVER_CCMD == _exp_0 then
        elementTypeStr = 'serverConCommand'
      end
      saveTable.elementType = elementTypeStr
      local dataTypeStr
      local DTYPES = AddElementUI.DATA_TYPES
      local _exp_1 = data.dataType
      if DTYPES.NONE == _exp_1 then
        dataTypeStr = 'none'
      elseif DTYPES.BOOL == _exp_1 then
        dataTypeStr = 'bool'
      elseif DTYPES.CHOICE == _exp_1 then
        dataTypeStr = 'choice'
        saveTable.choices = data.choices
      elseif DTYPES.KEYBIND == _exp_1 then
        dataTypeStr = 'keybind'
      elseif DTYPES.NUMBER == _exp_1 then
        dataTypeStr = 'number'
        do
          saveTable.min = data.min
          saveTable.max = data.max
          saveTable.interval = data.interval
          saveTable.logarithmic = data.logarithmic
        end
      elseif DTYPES.STRING == _exp_1 then
        dataTypeStr = 'string'
      elseif DTYPES.CHOICE_LIST == _exp_1 then
        data.dataType = 'choiceList'
      elseif DTYPES.NUMBER_LIST == _exp_1 then
        data.dataType = 'numberList'
      elseif DTYPES.STRING_LIST == _exp_1 then
        dataTypeStr = 'stringList'
      end
      saveTable.dataType = dataTypeStr
      return saveTable
    end,
    SetValue = function(self, value)
      self.arguments = value
      if IsValid(self.rawPanel) then
        if self.rawPanel.SetSelectedNumber then
          self.rawPanel:SetSelectedNumber(input.GetKeyCode(value))
        else
          self.rawPanel:SetValue(value)
        end
        if self.rawPanel.Data then
          for choiceIndex, data in pairs(self.rawPanel.Data) do
            if data == value then
              self.rawPanel:ChooseOptionID(choiceIndex)
              break
            end
          end
        end
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, parent, data, window, static)
      _class_0.__parent.__init(self)
      self.data = data
      if data.arguments then
        self.arguments = data.arguments
      end
      self.window = window
      self:InitializeElementPanel(parent, static)
      self.static = static
      return self:PopulatePanel()
    end,
    __base = _base_0,
    __name = "CCVCCPanel",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  CCVCCPanel = _class_0
end
do
  local _class_0
  local _parent_0 = BasePanel
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, w, h)
      _class_0.__parent.__init(self)
      self.scrW = ScrW()
      self.scrH = ScrH()
      local panel
      do
        local _with_0 = vgui.Create('DFrame')
        _with_0:SetSize(self.scrW * w, self.scrH * h)
        _with_0:SetSizable(true)
        _with_0:Center()
        _with_0:MakePopup()
        panel = _with_0
      end
      return self:SetPanel(panel)
    end,
    __base = _base_0,
    __name = "BaseUI",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  BaseUI = _class_0
end
do
  local _class_0
  local _parent_0 = BaseUI
  local _base_0 = {
    controlPanelVisibility = true,
    GetInstance = function(self)
      return self.__class.managerClass
    end,
    AddControlPanel = function(self, panel)
      table.insert(self.controlPanels, panel)
      if not (self.controlPanelVisibility) then
        return panel:Hide()
      end
    end,
    SetControlPanelVisibility = function(self, menu, bool)
      self.controlPanelVisibility = bool
      local _list_0 = self.controlPanels
      for _index_0 = 1, #_list_0 do
        local panel = _list_0[_index_0]
        if IsValid(panel) then
          panel:SetVisible(bool)
          panel:GetParent():InvalidateLayout()
          panel:GetParent():GetParent():InvalidateLayout()
        end
      end
    end,
    GetControlPanelVisibility = function(self)
      return self.controlPanelVisibility
    end,
    AddServerVarQueryRequest = function(self, var, cls)
      local _update_0 = var
      self.serverVarClass[_update_0] = self.serverVarClass[_update_0] or { }
      table.insert(self.serverVarClass[var], cls)
      self.serverVarQueryRequests[var] = true
    end,
    FulfillServerVarQueryRequests = function(self)
      if next(self.serverVarQueryRequests) then
        local varSendTable = { }
        for k, v in pairs(self.serverVarQueryRequests) do
          table.insert(varSendTable, 's')
          table.insert(varSendTable, k)
          self.serverVarQueryRequests[k] = nil
          if #varSendTable >= 127 then
            break
          end
        end
        CCVCCM:StartNet()
        CCVCCM:AddPayloadToNetMessage({
          'u8',
          CCVCCM.ENUMS.NET.QUERY,
          'u8',
          #varSendTable / 2
        })
        CCVCCM:AddPayloadToNetMessage(varSendTable)
        return CCVCCM:FinishNet()
      end
    end,
    ReceiveServerVarQueryResult = function(self, var, val)
      local _list_0 = self.serverVarClass[var]
      for _index_0 = 1, #_list_0 do
        local cls = _list_0[_index_0]
        cls:SetValue(val)
      end
    end,
    AddMenuOption = function(self, menuBar, menuName, menuOptions)
      local menu = menuBar:AddMenu(menuName)
      for _index_0 = 1, #menuOptions do
        local _des_0 = menuOptions[_index_0]
        local name, func, icon, value, toggle
        name, func, icon, value, toggle = _des_0.name, _des_0.func, _des_0.icon, _des_0.value, _des_0.toggle
        do
          local _with_0 = menu:AddOption(name)
          if icon then
            _with_0:SetIcon("icon16/" .. tostring(icon) .. ".png")
          end
          if toggle then
            _with_0:SetIsCheckable(toggle)
            _with_0:SetChecked(value or false)
            _with_0.OnChecked = func or _with_0.OnChecked
          else
            _with_0.DoClick = func or _with_0.DoClick
          end
        end
      end
      return menu
    end,
    AddRootTab = function(self, displayName, icon, content, static)
      if displayName == nil then
        displayName = 'New Tab'
      end
      if not (IsValid(self.sheet)) then
        self:CreateSheet()
      end
      local contentPanel = ContentPanel('tab', self, static)
      local tab
      tab = self.sheet:AddSheet(displayName, contentPanel:GetPanel(), icon, false, true).Tab
      if not (static) then
        tab.DoDoubleClick = function()
          if self.controlPanelVisibility then
            return contentPanel:PromptRenameTab()
          end
        end
      end
      self:AddControlPanel(contentPanel:GetControlPanel())
      return contentPanel:LoadFromTable(content)
    end,
    CreateSheet = function(self)
      do
        local _with_0 = vgui.Create('DPropertySheet', self.scrollPanel)
        _with_0:Dock(TOP)
        _with_0.tabScroller:SetUseLiveDrag(true)
        self:MakeDraggable(_with_0.tabScroller)
        self.sheet = _with_0
      end
      return self:WrapFunc(self.sheet, 'PerformLayout', true, function(self, w, h)
        local padding = self:GetPadding()
        local panel = self:GetActiveTab():GetPanel()
        self:SetTall(panel:GetTall() + 20 + padding * 2)
        return CCVCCM:Log(self, 'PerformLayout')
      end)
    end,
    PromptClear = function(self)
      return Derma_Query('Are you sure?', 'New File', 'Yes', (function()
        self.__class.saveName = ''
        if IsValid(self.sheet) then
          return self.sheet:Remove()
        end
      end), 'No')
    end,
    PromptSave = function(self)
      if self.__class.saveName ~= '' then
        return self:SaveToFile(self.__class.saveName)
      else
        return self:PromptSaveAs()
      end
    end,
    PromptSaveAs = function(self)
      return Derma_StringRequest('Save', 'Enter file name:', self.__class.saveName, function(saveName)
        if file.Exists("ccvccm/" .. tostring(saveName) .. ".json", 'DATA') then
          return Derma_Query('Overwrite existing file?', 'Overwrite', 'Yes', (function()
            return self:SaveToFile(saveName)
          end), 'No')
        else
          return self:SaveToFile(saveName)
        end
      end)
    end,
    PromptAutoLoad = function(self)
      if self.__class.saveName == '' then
        return Derma_Message('Save your current layout first!', 'Load Error', 'OK')
      else
        return Derma_Query("This will set the current save file (ccvccm/" .. tostring(self.__class.saveName) .. ".json) to be automatically loaded when the CCVCCM is opened. Are you sure?", 'Set As Autoloaded File', 'Yes', (function()
          return CCVCCM:SetVarValue('ccvccm_autoload', self.__class.saveName)
        end), 'No')
      end
    end,
    SaveToFile = function(self, saveName)
      self.__class.saveName = saveName
      local fileName = "ccvccm/" .. tostring(saveName) .. ".json"
      local routine = coroutine.create((function()
        local _base_1 = self
        local _fn_0 = _base_1.SaveToFileRoutine
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)())
      coroutine.resume(routine, fileName)
      SavablePanel:UpdateSavables()
      return ProgressUI(0.25, 0.25, {
        routine = routine,
        expectedRuns = table.Count(SavablePanel.panelClasses),
        headerText = 'Your data is being saved, please wait!'
      })
    end,
    SaveToFileRoutine = function(self, fileName)
      if not (file.IsDir('ccvccm', 'DATA')) then
        file.CreateDir('ccvccm')
      end
      coroutine.yield()
      local data = self:SaveToTable()
      file.Write(fileName, util.TableToJSON(data))
      return "Successfully saved to \"data/" .. tostring(fileName) .. "\"!"
    end,
    SaveToTable = function(self)
      if IsValid(self.sheet) then
        local tabs = self.sheet.tabScroller:GetCanvas():GetChildren()
        self:SortPanelsByPosition(tabs)
        local tabContentClasses
        do
          local _tbl_0 = { }
          local _list_0 = self.sheet:GetItems()
          for _index_0 = 1, #_list_0 do
            local _des_0 = _list_0[_index_0]
            local tab, panel
            tab, panel = _des_0.Tab, _des_0.Panel
            _tbl_0[tab] = SavablePanel.panelClasses[panel]
          end
          tabContentClasses = _tbl_0
        end
        local saveTable = { }
        for i, tab in ipairs(tabs) do
          if not (tabContentClasses[tab]:GetStatic()) then
            local tabSaveTable = {
              displayName = tab:GetText(),
              content = tabContentClasses[tab]:SaveToTable()
            }
            if tab.Image then
              tabSaveTable.icon = tab.Image:GetImage()
            end
            table.insert(saveTable, tabSaveTable)
          end
          coroutine.yield()
        end
        return saveTable
      else
        return { }
      end
    end,
    PromptLoad = function(self)
      do
        local _with_0 = LoadUI(0.5, 0.5)
        _with_0:SetCallback(function(classData, saveName)
          return self:LoadFromFile(saveName)
        end)
        return _with_0
      end
    end,
    LoadFromFile = function(self, saveName)
      self.__class.saveName = saveName
      local fileName = "ccvccm/" .. tostring(saveName) .. ".json"
      if file.Exists(fileName, 'DATA') then
        local routine = coroutine.create((function()
          local _base_1 = self
          local _fn_0 = _base_1.LoadFromFileRoutine
          return function(...)
            return _fn_0(_base_1, ...)
          end
        end)())
        local ok, data = coroutine.resume(routine, fileName)
        if ok then
          return ProgressUI(0.25, 0.25, {
            routine = routine,
            expectedRuns = (function()
              if data then
                return CCVCCM:CountTablesRecursive(data)
              else
                return 1
              end
            end)(),
            headerText = 'Your data is being loaded, please wait!'
          })
        else
          return error(data)
        end
      else
        return Derma_Message("Couldn't load file \"data/" .. tostring(fileName) .. "\"!", 'Load Error', 'OK')
      end
    end,
    LoadFromFileRoutine = function(self, fileName)
      local fileText = file.Read(fileName, 'DATA')
      local data
      if fileText then
        data = util.JSONToTable(fileText)
      end
      hook.Run('CCVCCMDataLoad', data)
      coroutine.yield(data)
      if data then
        if IsValid(self.sheet) then
          self.sheet:Remove()
        end
        self:LoadFromTable(data)
        return "Successfully loaded from \"data/" .. tostring(fileName) .. "\"!"
      else
        return "\"data/" .. tostring(fileName) .. "\" is corrupted!"
      end
    end,
    LoadFromTable = function(self, data)
      for _index_0 = 1, #data do
        local _des_0 = data[_index_0]
        local displayName, icon, content, static
        displayName, icon, content, static = _des_0.displayName, _des_0.icon, _des_0.content, _des_0.static
        self:AddRootTab(displayName, icon, content, static)
        coroutine.yield()
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, w, h)
      if IsValid(self.__class.managerWindow) then
        return self.__class.managerWindow:Show()
      else
        _class_0.__parent.__init(self, w, h)
        local window = self:GetPanel()
        window:SetTitle('Console ConVar and ConCommand Manager')
        self:WrapFunc(window, 'Think', false, function()
          if (self.nextQueryTime or 0) < RealTime() then
            self.nextQueryTime = RealTime() + 0.25
            return self:FulfillServerVarQueryRequests()
          end
        end)
        do
          local _with_0 = window.btnClose
          _with_0.DoClick = function()
            return Derma_Query('Are you sure you want to delete this window? Consider using the Minimize button instead.', 'Close', 'Yes', (function()
              return window:Close()
            end), 'No')
          end
        end
        do
          local _with_0 = window.btnMinim
          _with_0:SetDisabled(false)
          _with_0.DoClick = function()
            return window:Hide()
          end
        end
        do
          local _with_0 = window.btnMaxim
          _with_0:SetDisabled(false)
          _with_0.DoClick = function()
            if window:GetSizable() then
              self.oldBounds = {
                window:GetBounds()
              }
              window:SetPos(0, 0)
              window:SetSize(ScrW(), ScrH())
              window:SetSizable(false)
              return window:SetDraggable(false)
            else
              local x, y
              do
                local _obj_0 = self.oldBounds
                x, y, w, h = _obj_0[1], _obj_0[2], _obj_0[3], _obj_0[4]
              end
              window:SetPos(x, y)
              window:SetSize(w, h)
              window:SetSizable(true)
              return window:SetDraggable(true)
            end
          end
          _with_0.Paint = function(panel, w, h)
            if window:GetSizable() then
              return derma.SkinHook('Paint', 'WindowMaximizeButton', panel, w, h)
            else
              local skinData = panel:GetSkin()
              if skinData.PaintWindowRestoreButton then
                return derma.SkinHook('Paint', 'WindowRestoreButton', panel, w, h)
              elseif panel.m_bBackground then
                if panel:GetDisabled() then
                  return skinData.tex.Window.Restore(0, 0, w, h, Color(255, 255, 255, 50))
                end
                if panel.Depressed or panel:IsSelected() then
                  return skinData.tex.Window.Restore_Down(0, 0, w, h)
                end
                if panel.Hovered then
                  return skinData.tex.Window.Restore_Hover(0, 0, w, h)
                end
                return skinData.tex.Window.Restore(0, 0, w, h)
              end
            end
          end
        end
        self.__class.managerWindow = window
        self.__class.managerClass = self
        local menuBar = vgui.Create('DMenuBar', window)
        self:AddMenuOption(menuBar, 'File', {
          {
            name = 'New',
            icon = 'page_add',
            func = (function()
              local _base_1 = self
              local _fn_0 = _base_1.PromptClear
              return function(...)
                return _fn_0(_base_1, ...)
              end
            end)()
          },
          {
            name = 'Open',
            icon = 'folder_page',
            func = (function()
              local _base_1 = self
              local _fn_0 = _base_1.PromptLoad
              return function(...)
                return _fn_0(_base_1, ...)
              end
            end)()
          },
          {
            name = 'Save',
            icon = 'disk',
            func = (function()
              local _base_1 = self
              local _fn_0 = _base_1.PromptSave
              return function(...)
                return _fn_0(_base_1, ...)
              end
            end)()
          },
          {
            name = 'Save As',
            icon = 'page_save',
            func = (function()
              local _base_1 = self
              local _fn_0 = _base_1.PromptSaveAs
              return function(...)
                return _fn_0(_base_1, ...)
              end
            end)()
          },
          {
            name = 'Set As Autoloaded File',
            icon = 'page_link',
            func = (function()
              local _base_1 = self
              local _fn_0 = _base_1.PromptAutoLoad
              return function(...)
                return _fn_0(_base_1, ...)
              end
            end)()
          }
        })
        self:AddMenuOption(menuBar, 'Edit', {
          {
            name = 'Toggle Layout Editing Mode',
            toggle = true,
            value = self.controlPanelVisibility,
            func = (function()
              local _base_1 = self
              local _fn_0 = _base_1.SetControlPanelVisibility
              return function(...)
                return _fn_0(_base_1, ...)
              end
            end)()
          },
          {
            name = 'Add Root Tab',
            icon = 'tab_add',
            func = function()
              return self:AddRootTab()
            end
          }
        })
        do
          local _with_0 = vgui.Create('DScrollPanel', window)
          _with_0:Dock(FILL)
          self.scrollPanel = _with_0
        end
        self.controlPanels = { }
        self.serverVarClass = { }
        self.serverVarQueryRequests = { }
        local saveFile = CCVCCM:GetVarValue('ccvccm_autoload')
        if saveFile ~= '' then
          return self:LoadFromFile(saveFile)
        end
      end
    end,
    __base = _base_0,
    __name = "ManagerUI",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.saveName = ''
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ManagerUI = _class_0
end
do
  local _class_0
  local _parent_0 = BaseUI
  local _base_0 = {
    AddElementPanels = function(self, scrollPanel)
      local elementTypeSelected = self.data.elementType
      local dataTypeSelected = self.data.dataType
      local ETYPES = self.__class.ELEMENT_TYPES
      local cvarDisplayFlags = GetBitflagFromIndices(ETYPES.CLIENT_CVAR, ETYPES.SERVER_CVAR)
      local ccmdDisplayFlags = GetBitflagFromIndices(ETYPES.CLIENT_CCMD, ETYPES.SERVER_CCMD)
      local textDisplayFlags = GetBitflagFromIndices(ETYPES.TEXT, ETYPES.CATEGORY)
      local commDisplayFlags = bit.bor(cvarDisplayFlags, ccmdDisplayFlags)
      do
        local _with_0 = self:CreateLabel(scrollPanel, 'Element Type', 1)
        _with_0:Dock(TOP)
      end
      do
        local _with_0 = vgui.Create('DComboBox', scrollPanel)
        _with_0:AddChoice('Text', ETYPES.TEXT, elementTypeSelected == ETYPES.TEXT)
        _with_0:AddChoice('Category', ETYPES.CATEGORY, elementTypeSelected == ETYPES.CATEGORY)
        _with_0:AddChoice('Tabs', ETYPES.TABS, elementTypeSelected == ETYPES.TABS)
        _with_0:AddChoice('Client ConVar', ETYPES.CLIENT_CVAR, elementTypeSelected == ETYPES.CLIENT_CVAR)
        _with_0:AddChoice('Client ConCommand', ETYPES.CLIENT_CCMD, elementTypeSelected == ETYPES.CLIENT_CCMD)
        _with_0:AddChoice('Server ConVar (Admin Only)', ETYPES.SERVER_CVAR, elementTypeSelected == ETYPES.SERVER_CVAR)
        _with_0:AddChoice('Server ConCommand (Admin Only)', ETYPES.SERVER_CCMD, elementTypeSelected == ETYPES.SERVER_CCMD)
        _with_0:SetZPos(2)
        _with_0:Dock(TOP)
        _with_0.OnSelect = function(selector, index, name, value)
          return self:OnETypeSelect(value)
        end
        if self.data.elementTypeLocked then
          _with_0:SetEnabled(false)
        end
      end
      do
        local panel = self:CreateLabel(scrollPanel, 'Display Name', 3)
        panel:Dock(TOP)
        self.elementPanelDisplayFlags[panel] = bit.bor(commDisplayFlags, textDisplayFlags)
      end
      do
        local panel = vgui.Create('DTextEntry', scrollPanel)
        if self.data.displayName then
          panel:SetText(self.data.displayName)
        end
        panel:SetZPos(4)
        panel:Dock(TOP)
        panel.OnChange = function()
          self.data.displayName = panel:GetValue()
        end
        self.elementPanelDisplayFlags[panel] = bit.bor(commDisplayFlags, textDisplayFlags)
      end
      do
        local panel = self:CreateLabel(scrollPanel, 'ConVar', 5)
        panel:Dock(TOP)
        self.elementPanelDisplayFlags[panel] = cvarDisplayFlags
      end
      do
        local panel = self:CreateLabel(scrollPanel, 'ConCommand', 5)
        panel:Dock(TOP)
        self.elementPanelDisplayFlags[panel] = ccmdDisplayFlags
      end
      do
        local panel = vgui.Create('DTextEntry', scrollPanel)
        if self.data.internalName then
          panel:SetText(self.data.internalName)
        end
        panel:SetZPos(6)
        panel:Dock(TOP)
        panel.OnChange = function()
          self.data.internalName = panel:GetValue()
        end
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
      end
      do
        local panel = self:CreateLabel(scrollPanel, 'ConVar Type', 7)
        panel:Dock(TOP)
        self.elementPanelDisplayFlags[panel] = cvarDisplayFlags
      end
      do
        local panel = self:CreateLabel(scrollPanel, 'ConCommand Type', 7)
        panel:Dock(TOP)
        self.elementPanelDisplayFlags[panel] = ccmdDisplayFlags
      end
      local DTYPES = self.__class.DATA_TYPES
      do
        local panel = vgui.Create('DComboBox', scrollPanel)
        panel:AddChoice('None (ConCommands only)', DTYPES.NONE, dataTypeSelected == DTYPES.NONE)
        panel:AddChoice('Boolean', DTYPES.BOOL, dataTypeSelected == DTYPES.BOOL)
        panel:AddChoice('Choices', DTYPES.CHOICE, dataTypeSelected == DTYPES.CHOICE)
        panel:AddChoice('Keybind', DTYPES.KEYBIND, dataTypeSelected == DTYPES.KEYBIND)
        panel:AddChoice('Numeric', DTYPES.NUMBER, dataTypeSelected == DTYPES.NUMBER)
        panel:AddChoice('Text', DTYPES.STRING, dataTypeSelected == DTYPES.STRING)
        panel:AddChoice('Choices List', DTYPES.CHOICE_LIST, dataTypeSelected == DTYPES.CHOICE_LIST)
        panel:AddChoice('Numeric List', DTYPES.NUMBER_LIST, dataTypeSelected == DTYPES.NUMBER_LIST)
        panel:AddChoice('Text List', DTYPES.STRING_LIST, dataTypeSelected == DTYPES.STRING_LIST)
        panel:SetZPos(8)
        panel:Dock(TOP)
        panel.OnSelect = function(selector, index, name, value)
          return self:OnDTypeSelect(value)
        end
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
      end
      do
        local panel = self:CreateButton(scrollPanel, 'Set Choices', 9)
        panel:Dock(TOP)
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.CHOICE, DTYPES.CHOICE_LIST)
        panel.DoClick = function()
          do
            local _with_0 = ListInputUI(0.5, 0.5, {
              names = {
                'Display Name',
                'Value'
              },
              types = {
                {
                  dataType = DTYPES.STRING
                },
                {
                  dataType = DTYPES.STRING
                }
              }
            }, self.data.choices)
            _with_0:SetCallback(function(classData, values)
              self.data.choices = values
            end)
            return _with_0
          end
        end
      end
      do
        local panel = self:CreateLabel(scrollPanel, 'Minimum Value', 9)
        panel:Dock(TOP)
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.NUMBER, DTYPES.NUMBER_LIST)
      end
      do
        local panel = vgui.Create('DTextEntry', scrollPanel)
        if self.data.min then
          panel:SetValue(self.data.min)
        end
        panel:SetZPos(10)
        panel:Dock(TOP)
        panel.OnChange = function()
          self.data.min = panel:GetValue()
        end
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.NUMBER, DTYPES.NUMBER_LIST)
      end
      do
        local panel = self:CreateLabel(scrollPanel, 'Maximum Value', 11)
        panel:Dock(TOP)
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.NUMBER, DTYPES.NUMBER_LIST)
      end
      do
        local panel = vgui.Create('DTextEntry', scrollPanel)
        if self.data.max then
          panel:SetValue(self.data.max)
        end
        panel:SetZPos(12)
        panel:Dock(TOP)
        panel.OnChange = function()
          self.data.max = panel:GetValue()
        end
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.NUMBER, DTYPES.NUMBER_LIST)
      end
      do
        local panel = self:CreateLabel(scrollPanel, 'Interval Between Values (blank = 0.01)', 13)
        panel:Dock(TOP)
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.NUMBER, DTYPES.NUMBER_LIST)
      end
      do
        local panel = vgui.Create('DTextEntry', scrollPanel)
        if self.data.interval then
          panel:SetValue(self.data.interval)
        end
        panel:SetZPos(14)
        panel:Dock(TOP)
        panel.OnChange = function()
          self.data.interval = panel:GetValue()
        end
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.NUMBER, DTYPES.NUMBER_LIST)
      end
      do
        local panel = vgui.Create('DCheckBoxLabel', scrollPanel)
        if self.data.logarithmic then
          panel:SetValue(self.data.logarithmic)
        end
        panel:SetText('Logarithmic')
        panel:SetZPos(15)
        panel:Dock(TOP)
        panel.OnChange = function(panel, value)
          self.data.logarithmic = value
        end
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.NUMBER, DTYPES.NUMBER_LIST)
      end
      do
        local panel = self:CreateLabel(scrollPanel, 'List Separator', 16)
        panel:Dock(TOP)
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.CHOICE_LIST, DTYPES.NUMBER_LIST, DTYPES.STRING_LIST)
      end
      do
        local panel = vgui.Create('DTextEntry', scrollPanel)
        if self.data.listSeparator then
          panel:SetValue(self.data.listSeparator)
        end
        panel:SetZPos(17)
        panel:Dock(TOP)
        panel.OnChange = function()
          self.data.listSeparator = panel:GetValue()
        end
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.CHOICE_LIST, DTYPES.NUMBER_LIST, DTYPES.STRING_LIST)
      end
      do
        local panel = vgui.Create('DCheckBoxLabel', scrollPanel)
        if self.data.manual then
          panel:SetValue(self.data.manual)
        end
        panel:SetText('Update ConVar Manually')
        panel:SetZPos(18)
        panel:Dock(TOP)
        panel.OnChange = function(panel, value)
          self.data.manual = value
        end
        self.elementPanelDisplayFlags[panel] = cvarDisplayFlags
        return panel
      end
    end,
    CheckDataValidity = function(self)
      local dataValid = true
      local invalidReason = 'One of the entered values is invalid!'
      local ETYPES = self.__class.ELEMENT_TYPES
      local DTYPES = self.__class.DATA_TYPES
      local elementType = self.data.elementType
      local isCVar = elementType == ETYPES.CLIENT_CVAR or elementType == ETYPES.SERVER_CVAR
      local isCCmd = elementType == ETYPES.CLIENT_CCMD or elementType == ETYPES.SERVER_CCMD
      if isCVar or isCCmd then
        local name = self.data.internalName or ''
        if elementType == ETYPES.CLIENT_CVAR then
          local conVar = GetConVar(name)
          if (conVar and conVar:IsFlagSet(FCVAR_REPLICATED)) then
            dataValid = false
            invalidReason = "\"" .. tostring(name) .. "\" is a replicated ConVar and must be added as a Server ConVar!"
          end
        end
        if name == '' then
          dataValid = false
          invalidReason = "\"" .. tostring(name) .. "\" is not a valid ConCommand / ConVar!"
        elseif IsConCommandBlocked(name) then
          dataValid = false
          invalidReason = "\"" .. tostring(name) .. "\" can't be altered / used by CCVCCM!"
        elseif dataValid then
          local _exp_0 = self.data.dataType
          if DTYPES.NONE == _exp_0 then
            if isCVar then
              dataValid = false
              invalidReason = "None data type is only valid for ConCommands!"
            end
          elseif DTYPES.NUMBER == _exp_0 or DTYPES.NUMBER_LIST == _exp_0 then
            local minValue = tonumber(self.data.min)
            if not (minValue) then
              dataValid = false
              invalidReason = "Minimum value \"" .. tostring(minValue) .. "\" is not a number!"
            end
            local maxValue = tonumber(self.data.max)
            if not (maxValue) then
              dataValid = false
              invalidReason = "Maximum value \"" .. tostring(maxValue) .. "\" is not a number!"
            end
            local stepValue = self.data.interval or ''
            if stepValue == '' then
              stepValue = 0.01
            else
              stepValue = tonumber(stepValue)
            end
            if not (stepValue) then
              dataValid = false
              invalidReason = "Step value \"" .. tostring(stepValue) .. "\" is not a number!"
            elseif not (stepValue > 0) then
              dataValid = false
              invalidReason = "Step value \"" .. tostring(stepValue) .. "\" must be positive!"
            end
            if self.data.logarithmic and not (minValue * maxValue > 0) then
              dataValid = false
              invalidReason = "Minimum value times maximum value must be positive in logarithmic mode!"
            end
          elseif DTYPES.CHOICE == _exp_0 or DTYPES.CHOICE_LIST == _exp_0 then
            local choices
            if self.data.choices then
              choices = #self.data.choices
            else
              choices = 0
            end
            if not (choices > 0) then
              dataValid = false
              invalidReason = "You must specify at least one choice!"
            end
          end
        end
      end
      return dataValid, invalidReason
    end,
    SetCallback = function(self, func)
      self.callback = func
    end,
    UpdatePanelVisibilities = function(self)
      local elementDisplayFlag = bit.lshift(1, self.data.elementType)
      local dataDisplayFlag = bit.lshift(1, self.data.dataType)
      for panel, flags in pairs(self.elementPanelDisplayFlags) do
        local shouldDisplay = (bit.band(flags, elementDisplayFlag)) ~= 0
        local dataRequiredFlags = self.dataPanelDisplayFlags[panel]
        if dataRequiredFlags then
          shouldDisplay = shouldDisplay and ((bit.band(dataRequiredFlags, dataDisplayFlag)) ~= 0)
        end
        panel:SetVisible(shouldDisplay)
      end
    end,
    OnETypeSelect = function(self, value)
      self.data.elementType = value
      local displayFlag = bit.lshift(1, value)
      return self:UpdatePanelVisibilities()
    end,
    OnDTypeSelect = function(self, value)
      self.data.dataType = value
      local displayFlag = bit.lshift(1, value)
      return self:UpdatePanelVisibilities()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, w, h, defaultData)
      _class_0.__parent.__init(self, w, h)
      local window = self:GetPanel()
      local scrollPanel
      do
        local _with_0 = vgui.Create('DScrollPanel', window)
        _with_0:Dock(FILL)
        scrollPanel = _with_0
      end
      do
        local _with_0 = self:CreateButton(window, 'OK')
        _with_0:Dock(BOTTOM)
        _with_0.DoClick = function()
          local dataValid, invalidReason = self:CheckDataValidity()
          if dataValid then
            window:Close()
            if self.callback then
              return self:callback(self.data)
            end
          else
            return Derma_Message(invalidReason, 'Invalid Arguments', 'OK')
          end
        end
      end
      self.elementPanelDisplayFlags = { }
      self.dataPanelDisplayFlags = { }
      if defaultData then
        self.data = table.Copy(defaultData)
        if not (self.data.elementType) then
          self.data.elementType = self.__class.ELEMENT_TYPES.TEXT
        end
        if not (self.data.dataType) then
          self.data.dataType = self.__class.DATA_TYPES.BOOL
        end
        self.data.elementTypeLocked = true
      else
        self.data = {
          elementType = self.__class.ELEMENT_TYPES.TEXT,
          dataType = self.__class.DATA_TYPES.BOOL
        }
      end
      self:AddElementPanels(scrollPanel)
      self:OnETypeSelect(self.data.elementType)
      return self:OnDTypeSelect(self.data.dataType)
    end,
    __base = _base_0,
    __name = "AddElementUI",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.ELEMENT_TYPES = {
    TEXT = 0,
    CATEGORY = 1,
    TABS = 2,
    CLIENT_CVAR = 3,
    CLIENT_CCMD = 4,
    SERVER_CVAR = 5,
    SERVER_CCMD = 6,
    ADDON = 7
  }
  self.DATA_TYPES = {
    NONE = 0,
    BOOL = 1,
    CHOICE = 2,
    KEYBIND = 3,
    NUMBER = 4,
    STRING = 5,
    CHOICE_LIST = 6,
    NUMBER_LIST = 7,
    STRING_LIST = 8,
    COMPLEX_LIST = 9
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  AddElementUI = _class_0
end
do
  local _class_0
  local _parent_0 = BaseUI
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, w, h, selectedIcon, callback)
      if selectedIcon == nil then
        selectedIcon = ''
      end
      if callback == nil then
        callback = function() end
      end
      _class_0.__parent.__init(self, w, h)
      local window = self:GetPanel()
      local browser
      do
        local _with_0 = vgui.Create('DIconBrowser', window)
        _with_0:Dock(FILL)
        _with_0:SelectIcon(selectedIcon)
        if selectedIcon == '' then
          _with_0.m_pSelectedIcon = NULL
        end
        browser = _with_0
      end
      do
        local _with_0 = self:CreateButton(window, 'Clear Icon', 1)
        _with_0:Dock(TOP)
        _with_0.DoClick = function()
          browser:SelectIcon('')
          browser.m_pSelectedIcon = NULL
        end
      end
      do
        local _with_0 = vgui.Create('DTextEntry', window)
        _with_0:SetPlaceholderText('Search...')
        _with_0:SetZPos(2)
        _with_0:Dock(TOP)
        _with_0.OnChange = function(self)
          return browser:FilterByText(self:GetValue())
        end
      end
      do
        local _with_0 = self:CreateButton(window, 'OK')
        _with_0:Dock(BOTTOM)
        _with_0.DoClick = function()
          window:Close()
          return callback(browser:GetSelectedIcon())
        end
        return _with_0
      end
    end,
    __base = _base_0,
    __name = "EditIconUI",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  EditIconUI = _class_0
end
do
  local _class_0
  local _parent_0 = BaseUI
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, w, h, text, callback)
      if text == nil then
        text = ''
      end
      if callback == nil then
        callback = function() end
      end
      _class_0.__parent.__init(self, w, h)
      local window = self:GetPanel()
      do
        local _with_0 = self:CreateLabel(window, 'You can enter multiple lines in this text box.')
        _with_0:Dock(TOP)
      end
      local textEntry
      do
        local _with_0 = vgui.Create('DTextEntry', window)
        _with_0:Dock(FILL)
        _with_0:SetMultiline(true)
        _with_0:SetValue(text)
        textEntry = _with_0
      end
      do
        local _with_0 = self:CreateButton(window, 'OK')
        _with_0:Dock(BOTTOM)
        _with_0.DoClick = function()
          window:Close()
          return callback(textEntry:GetValue())
        end
        return _with_0
      end
    end,
    __base = _base_0,
    __name = "MultilineTextUI",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  MultilineTextUI = _class_0
end
do
  local _class_0
  local _parent_0 = BaseUI
  local _base_0 = {
    SetCallback = function(self, callback)
      self.callback = callback
    end,
    AddRow = function(self, rowValues)
      if rowValues == nil then
        rowValues = { }
      end
      local rowPanel
      do
        local _with_0 = vgui.Create('DPanel', self.listPanel)
        _with_0:SetTall(22)
        _with_0:Dock(TOP)
        _with_0:SetCursor('sizeall')
        _with_0.Paint = nil
        rowPanel = _with_0
      end
      local rowClass
      do
        local _with_0 = vgui.Create('DImageButton', rowPanel)
        _with_0:SetStretchToFit(false)
        _with_0:SetImage('icon16/delete.png')
        _with_0:SetWide(22)
        _with_0:Dock(RIGHT)
        _with_0.DoClick = function()
          self.rowPanels[rowClass] = nil
          return rowPanel:Remove()
        end
      end
      local dragImageParent
      do
        local _with_0 = CustomPanelContainer(rowPanel)
        dragImageParent = _with_0:GetPanel()
      end
      do
        dragImageParent:SetMouseInputEnabled(false)
        dragImageParent:SetWide(22)
        dragImageParent:Dock(LEFT)
      end
      do
        local _with_0 = vgui.Create('DImage', dragImageParent)
        _with_0:SetImage('icon16/shape_handles.png')
        _with_0:SizeToContents()
      end
      rowClass = CustomPanelContainer(rowPanel)
      rowClass:SetStretch(true, false)
      local rowElementPanel = rowClass:GetPanel()
      rowElementPanel:Dock(FILL)
      local DTYPES = AddElementUI.DATA_TYPES
      for i, dataTypeInfo in ipairs(self.dataTypes) do
        local currentValue = rowValues[i]
        local _exp_0 = dataTypeInfo.dataType
        if DTYPES.BOOL == _exp_0 then
          local hostPanel = CustomPanelContainer(rowElementPanel)
          do
            local _with_0 = vgui.Create('DCheckBox', hostPanel:GetPanel())
            _with_0:SetPos(3, 3)
            if currentValue then
              _with_0:SetValue(currentValue)
            end
          end
        elseif DTYPES.CHOICE == _exp_0 then
          local comboBox = vgui.Create('DComboBox', rowElementPanel)
          local _list_0 = dataTypeInfo.choices
          for _index_0 = 1, #_list_0 do
            local _des_0 = _list_0[_index_0]
            local display, value
            display, value = _des_0[1], _des_0[2]
            comboBox:AddChoice(display, value, currentValue == value)
          end
        elseif DTYPES.NUMBER == _exp_0 then
          local min, max, interval, logarithmic
          min, max, interval, logarithmic = dataTypeInfo.min, dataTypeInfo.max, dataTypeInfo.interval, dataTypeInfo.logarithmic
          do
            local _with_0 = CustomNumSlider(rowElementPanel)
            _with_0:SetText(nil)
            _with_0:SetMinMax(min, max)
            _with_0:SetInterval(interval)
            _with_0:SetLogarithmic(logarithmic)
            if currentValue then
              _with_0:GetPanel():SetValue(currentValue)
            end
          end
        elseif DTYPES.STRING == _exp_0 then
          do
            local _with_0 = vgui.Create('DTextEntry', rowElementPanel)
            if currentValue then
              _with_0:SetValue(currentValue)
            end
          end
        elseif DTYPES.COMPLEX_LIST == _exp_0 then
          local button = self:CreateButton(rowElementPanel, dataTypeInfo.name or 'Edit List')
          button.DoClick = function()
            do
              local _with_0 = ListInputUI(0.5, 0.5, dataTypeInfo, currentValue)
              _with_0:SetCallback(function(classData, values)
                currentValue = values
              end)
              return _with_0
            end
          end
          button.GetValue = function()
            return currentValue
          end
        end
      end
      self.rowPanels[rowClass] = true
      return rowClass
    end,
    GetValues = function(self)
      local sortedRowPanels
      do
        local _accum_0 = { }
        local _len_0 = 1
        for rowClass, _ in pairs(self.rowPanels) do
          _accum_0[_len_0] = rowClass:GetPanel()
          _len_0 = _len_0 + 1
        end
        sortedRowPanels = _accum_0
      end
      self:SortPanelsByPosition(sortedRowPanels)
      local DTYPES = AddElementUI.DATA_TYPES
      local values = { }
      for i, rowPanel in ipairs(sortedRowPanels) do
        local childrenPanels = rowPanel:GetChildren()
        self:SortPanelsByPosition(childrenPanels)
        local rowValues = { }
        for j, dataTypeInfo in ipairs(self.dataTypes) do
          local _exp_0 = dataTypeInfo.dataType
          if DTYPES.BOOL == _exp_0 then
            rowValues[j] = childrenPanels[j]:GetChild(0):GetChecked() or false
          elseif DTYPES.CHOICE == _exp_0 then
            rowValues[j] = select(2, childrenPanels[j]:GetSelected())
          elseif DTYPES.NUMBER == _exp_0 then
            rowValues[j] = childrenPanels[j]:GetValue()
          elseif DTYPES.STRING == _exp_0 then
            rowValues[j] = childrenPanels[j]:GetText()
          elseif DTYPES.COMPLEX_LIST == _exp_0 then
            rowValues[j] = childrenPanels[j]:GetValue()
          end
        end
        values[i] = rowValues
      end
      return values
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, w, h, data, values)
      if data == nil then
        data = { }
      end
      if values == nil then
        values = { }
      end
      _class_0.__parent.__init(self, w, h)
      local window = self:GetPanel()
      self.dataTypes = data.types
      self.rowPanels = { }
      if data.header then
        do
          local _with_0 = self:CreateLabel(window, data.header)
          _with_0:SetZPos(1)
          _with_0:Dock(TOP)
        end
      end
      if data.names then
        local rowPanel
        do
          local _with_0 = vgui.Create('DPanel', window)
          _with_0:SetTall(22)
          _with_0:Dock(TOP)
          _with_0:SetZPos(2)
          _with_0.Paint = nil
          rowPanel = _with_0
        end
        local rowElementPanel
        do
          local _with_0 = CustomPanelContainer(rowPanel)
          _with_0:SetStretch(true, false)
          rowElementPanel = _with_0:GetPanel()
        end
        do
          rowElementPanel:DockMargin(22, 0, 22, 0)
          rowElementPanel:Dock(FILL)
        end
        for i, name in ipairs(data.names) do
          self:CreateLabel(rowElementPanel, name, i)
        end
      end
      do
        local _with_0 = self:CreateButton(window, 'OK')
        _with_0:Dock(BOTTOM)
        _with_0.DoClick = function()
          window:Close()
          if self.callback then
            return self:callback(self:GetValues())
          end
        end
      end
      local scrollPanel
      do
        local _with_0 = vgui.Create('DScrollPanel', window)
        _with_0:Dock(FILL)
        scrollPanel = _with_0
      end
      do
        local _with_0 = vgui.Create('DIconLayout', scrollPanel)
        _with_0:SetZPos(1)
        _with_0:Dock(TOP)
        _with_0:SetDropPos('28')
        _with_0:SetUseLiveDrag(true)
        self.listPanel = _with_0
      end
      self:MakeDraggable(self.listPanel)
      do
        local _with_0 = vgui.Create('DImageButton', scrollPanel)
        _with_0:SetImage('icon16/add.png')
        _with_0:SetStretchToFit(false)
        _with_0:SetTall(22)
        _with_0:SetZPos(2)
        _with_0:Dock(TOP)
        _with_0.DoClick = function()
          return self:AddRow()
        end
      end
      for _index_0 = 1, #values do
        local rowValues = values[_index_0]
        self:AddRow(rowValues)
      end
    end,
    __base = _base_0,
    __name = "ListInputUI",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ListInputUI = _class_0
end
do
  local _class_0
  local _parent_0 = BaseUI
  local _base_0 = {
    stopped = false,
    resumes = 0,
    RecomputeFraction = function(self)
      local fraction = math.Clamp(self.resumes / self.expectedRuns, 0, 1)
      self.progressBar:SetFraction(fraction)
      if fraction == 0 then
        return self.progressLabel:SetText('0.00%')
      else
        local timeTaken = SysTime() - self.startProgressTime
        local timeLeft = timeTaken / fraction - timeTaken
        return self.progressLabel:SetText(string.format('%#.2f%% (%s estimated time left)', fraction * 100, self:GetTimeString(timeLeft)))
      end
    end,
    GetTimeString = function(self, rawTime)
      local mins, minFrac = math.modf(rawTime / 60)
      local secs, secFrac = math.modf(minFrac * 60)
      local millis = secFrac * 1000
      return string.format('%02u:%02u.%03u', mins, secs, millis)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, w, h, data)
      _class_0.__parent.__init(self, w, h)
      local window = self:GetPanel()
      self.startProgressTime = SysTime()
      local routine, expectedRuns, headerText
      routine, expectedRuns, headerText = data.routine, data.expectedRuns, data.headerText
      self.expectedRuns = expectedRuns
      self:WrapFunc(window, 'Think', false, function()
        if not self.stopped then
          local ok
          ok, self.stopped = coroutine.resume(routine)
          self.resumes = self.resumes + 1
          if ok then
            if self.stopped then
              self.button:SetText('OK')
              self.button:SizeToContentsX(22)
              self.progressBar:SetFraction(1)
              return self.progressLabel:SetText(self.stopped)
            else
              return self:RecomputeFraction()
            end
          elseif self.stopped then
            return error(self.stopped)
          else
            self.stopped = true
          end
        end
      end)
      do
        local _with_0 = self:CreateLabel(window, headerText)
        _with_0:SetZPos(1)
        _with_0:Dock(TOP)
      end
      do
        local _with_0 = vgui.Create('DProgress', window)
        _with_0:SetZPos(2)
        _with_0:Dock(TOP)
        self.progressBar = _with_0
      end
      do
        local _with_0 = self:CreateLabel(window, '0.00%')
        _with_0:SetContentAlignment(8)
        _with_0:SetZPos(3)
        _with_0:Dock(TOP)
        self.progressLabel = _with_0
      end
      local containerClass
      do
        local _with_0 = CustomPanelContainer(window)
        _with_0:SetStretch(false, true)
        containerClass = _with_0
      end
      local containerPanel
      do
        local _with_0 = containerClass:GetPanel()
        _with_0:SetTall(22)
        _with_0:Dock(BOTTOM)
        containerPanel = _with_0
      end
      do
        local _with_0 = self:CreateButton(containerPanel, 'Cancel')
        _with_0.DoClick = function()
          return self:GetPanel():Close()
        end
        self.button = _with_0
      end
    end,
    __base = _base_0,
    __name = "ProgressUI",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ProgressUI = _class_0
end
do
  local _class_0
  local _parent_0 = BaseUI
  local _base_0 = {
    SetCallback = function(self, callback)
      self.callback = callback
    end,
    PromptAction = function(self, action)
      local textEntryValue = self.textEntry:GetValue()
      local fileName = "ccvccm/" .. tostring(textEntryValue) .. ".json"
      if file.Exists(fileName, 'DATA') then
        local _exp_0 = action
        if 1 == _exp_0 then
          self.window:Close()
          if self.callback then
            return self:callback(textEntryValue)
          end
        elseif 2 == _exp_0 then
          return Derma_StringRequest('Rename', 'Enter new file name:', textEntryValue, function(saveName)
            local newFileName = "ccvccm/" .. tostring(saveName) .. ".json"
            if file.Exists(newFileName, 'DATA') then
              Derma_Message("File \"data/" .. tostring(newFileName) .. "\" already exists!", 'Rename Error', 'OK')
            else
              file.Rename(fileName, newFileName)
            end
            for i, line in ipairs(self.listView:GetLines()) do
              if line:GetValue(1) == textEntryValue then
                line:SetColumnText(1, saveName)
                self.listView:SetDirty(true)
                self.listView:InvalidateLayout()
                break
              end
            end
          end)
        elseif 3 == _exp_0 then
          return Derma_Query('Are you sure?', 'Delete File', 'Yes', (function()
            file.Delete(fileName)
            for i, line in ipairs(self.listView:GetLines()) do
              if line:GetValue(1) == textEntryValue then
                self.listView:RemoveLine(i)
                break
              end
            end
          end), 'No')
        end
      else
        return Derma_Message("Couldn't load file \"data/" .. tostring(fileName) .. "\"!", 'Load Error', 'OK')
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, w, h)
      _class_0.__parent.__init(self, w, h)
      self.window = self:GetPanel()
      local controlPanel
      do
        local _with_0 = vgui.Create('DPanel', self.window)
        _with_0:SetTall(22)
        _with_0:Dock(BOTTOM)
        controlPanel = _with_0
      end
      do
        local _with_0 = self:CreateButton(controlPanel, 'Delete', 1, 'delete')
        _with_0:Dock(RIGHT)
        _with_0.DoClick = function()
          return self:PromptAction(3)
        end
      end
      do
        local _with_0 = self:CreateButton(controlPanel, 'Rename', 2, 'pencil')
        _with_0:Dock(RIGHT)
        _with_0.DoClick = function()
          return self:PromptAction(2)
        end
      end
      do
        local _with_0 = self:CreateButton(controlPanel, 'Load', 3, 'folder_page')
        _with_0:Dock(RIGHT)
        _with_0.DoClick = function()
          return self:PromptAction(1)
        end
      end
      do
        local _with_0 = vgui.Create('DTextEntry', controlPanel)
        _with_0:Dock(FILL)
        self.textEntry = _with_0
      end
      do
        local _with_0 = vgui.Create('DListView', self.window)
        _with_0:Dock(FILL)
        _with_0:SetMultiSelect(false)
        _with_0:AddColumn('Name')
        _with_0:AddColumn('Size')
        _with_0:AddColumn('Modified')
        _with_0.OnRowSelected = function(listView, rowIndex, rowPanel)
          return self.textEntry:SetValue(string.StripExtension(rowPanel:GetValue(1)))
        end
        self.listView = _with_0
      end
      local fileNames = file.Find('ccvccm/*.json', 'DATA')
      if fileNames then
        for _index_0 = 1, #fileNames do
          local fileName = fileNames[_index_0]
          local moreQualifiedFileName = 'ccvccm/' .. fileName
          local displayedName = string.StripExtension(fileName)
          local fileSize = string.NiceSize(file.Size(moreQualifiedFileName, 'DATA'))
          local fileModified = os.date('%Y-%m-%dT%X%z', file.Time(moreQualifiedFileName, 'DATA'))
          self.listView:AddLine(displayedName, fileSize, fileModified)
        end
      end
    end,
    __base = _base_0,
    __name = "LoadUI",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  LoadUI = _class_0
  return _class_0
end