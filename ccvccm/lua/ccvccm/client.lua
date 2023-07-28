CCVCCM.Send = function(self, sendTable)
  net.Start('ccvccm')
  CCVCCM:AddPayloadToNetMessage(sendTable)
  return net.SendToServer()
end
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
local GetBitflagFromIndices, BasePanel, CustomNumSlider, CustomPanelContainer, ContentPanel, TextPanel, CategoryPanel, TabPanel, CCVCCPanel, BaseUI, ManagerUI, AddElementUI, EditIconUI, ListInputUI, ProgressUI, LoadUI
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
    SetPanel = function(self, panel)
      self.panel = panel
    end,
    GetPanel = function(self)
      return self.panel
    end,
    RegisterAsSavable = function(self)
      BasePanel.panelClasses[self.panel] = self
    end,
    UnregisterAsSavable = function(self)
      BasePanel.panelClasses[self.panel] = nil
    end,
    RemoveClassAndPanel = function(self)
      self:UnregisterAsSavable()
      return self.panel:Remove()
    end,
    GetSavableClassFromPanel = function(self, panel)
      return BasePanel.panelClasses[panel]
    end,
    SortPanelsByPosition = function(self, panels)
      return table.sort(panels, function(a, b)
        local ax, ay = a:LocalToScreen(0, 0)
        local bx, by = b:LocalToScreen(0, 0)
        if ay ~= by then
          return ay < by
        else
          return ax < bx
        end
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
      print(dragSystemName)
      BasePanel.accumulator = BasePanel.accumulator + 1
    end,
    PromptDelete = function(self)
      return Derma_Query('Are you sure?', 'Delete', 'Yes', (function()
        local _base_1 = self
        local _fn_0 = _base_1.RemoveClassAndPanel
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), 'No')
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
  self.panelClasses = { }
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
      return panel:SetVisible(text ~= nil)
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
          panel:SetMax(self:UntranslateValue(panel:GetMax()))
          return print(panel:GetMin(), panel:GetMax())
        else
          panel:SetMin(self:TranslateValue(panel:GetMin()))
          panel:SetMax(self:TranslateValue(panel:GetMax()))
          self.logarithmic = logarithmic
          return print(panel:GetMin(), panel:GetMax())
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
          if value then
            if numSlider:GetValue() ~= value then
              return numSlider.Scratch:SetValue(value)
            end
          end
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
    GetControlPanel = function(self)
      return self.controlPanel
    end,
    AddElement = function(self, data)
      if data == nil then
        data = { }
      end
      local ETYPES = AddElementUI.ELEMENT_TYPES
      local createdPanel
      local _exp_0 = data.elementType
      if ETYPES.TEXT == _exp_0 then
        local classPanel = TextPanel(self.items, data, self.window)
        createdPanel = classPanel:GetPanel()
      elseif ETYPES.CATEGORY == _exp_0 then
        local classPanel = CategoryPanel(self.items, data, self.window)
        createdPanel = classPanel:GetPanel()
      elseif ETYPES.TABS == _exp_0 then
        local classPanel = TabPanel(self.items, data, self.window)
        createdPanel = classPanel:GetPanel()
      elseif ETYPES.CLIENT_CCMD == _exp_0 or ETYPES.CLIENT_CVAR == _exp_0 or ETYPES.SERVER_CCMD == _exp_0 or ETYPES.SERVER_CVAR == _exp_0 then
        local classPanel = CCVCCPanel(self.items, data, self.window)
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
    PromptRenameCategory = function(self)
      local categoryHeader = self:GetPanel():GetParent().Header
      return Derma_StringRequest('Rename', 'Enter new category name:', categoryHeader:GetText(), function(newName)
        return categoryHeader:SetText(newName)
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
    PromptDeleteCategory = function(self)
      return Derma_Query('Are you sure?', 'Delete', 'Yes', (function()
        self:UnregisterAsSavable()
        return self:GetPanel():GetParent():Remove()
      end), 'No')
    end,
    DeleteTab = function(self)
      self:UnregisterAsSavable()
      local tab, container = self:GetTabAndParent()
      local items = container:GetItems()
      if #items == 1 then
        return container:Remove()
      else
        return container:CloseTab(tab, true)
      end
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
    LoadFromTable = function(self, contentsData)
      if contentsData == nil then
        contentsData = { }
      end
      local ETYPES = AddElementUI.ELEMENT_TYPES
      local DTYPES = AddElementUI.DATA_TYPES
      for _index_0 = 1, #contentsData do
        local rawData = contentsData[_index_0]
        local data = table.Copy(rawData)
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
        end
        local _exp_1 = data.dataType
        if 'none' == _exp_1 then
          data.dataType = DTYPES.NONE
        elseif 'bool' == _exp_1 then
          data.dataType = DTYPES.BOOL
        elseif 'choices' == _exp_1 then
          data.dataType = DTYPES.CHOICE
        elseif 'number' == _exp_1 then
          data.dataType = DTYPES.NUMBER
        elseif 'string' == _exp_1 then
          data.dataType = DTYPES.STRING
        elseif 'stringList' == _exp_1 then
          data.dataType = DTYPES.STRING_LIST
        end
        self:AddElement(data)
        coroutine.yield()
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, contentType, window)
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
      do
        local _with_0 = vgui.Create('DPanel', panel)
        _with_0:SetTall(22)
        _with_0:Dock(TOP)
        _with_0.Paint = nil
        self.controlPanel = _with_0
      end
      self:WrapFunc(panel, 'PerformLayout', false, function(self, w, h)
        self:SizeToChildren(false, true)
        return print(RealTime(), self)
      end)
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
            do
              local _with_1 = EditIconUI(0.5, 0.5, icon)
              _with_1:SetCallback(function(classData, newImage)
                if newImage == nil then
                  newImage = ''
                end
                if newImage ~= '' then
                  if not (IsValid(tab.Image)) then
                    tab.Image = vgui.Create('DImage', tab)
                  end
                  do
                    local _with_2 = tab.Image
                    _with_2:SetImage(newImage)
                    _with_2:SizeToContents()
                  end
                elseif IsValid(tab.Image) then
                  tab.Image:Remove()
                  tab.Image = nil
                end
                tab:InvalidateLayout()
                return container:InvalidateChildren()
              end)
              self.addUI = _with_1
            end
          end
        end
      elseif contentType == 'category' then
        do
          local _with_0 = self:CreateButton(self.controlPanel, 'Rename Category', 2, 'pencil')
          _with_0:Dock(LEFT)
          do
            local _base_1 = self
            local _fn_0 = _base_1.PromptRenameCategory
            _with_0.DoClick = function(...)
              return _fn_0(_base_1, ...)
            end
          end
        end
      end
      if contentType == 'tab' then
        do
          local _with_0 = self:CreateButton(self.controlPanel, 'Delete Tab', 6, 'delete')
          _with_0:Dock(LEFT)
          do
            local _base_1 = self
            local _fn_0 = _base_1.PromptDeleteTab
            _with_0.DoClick = function(...)
              return _fn_0(_base_1, ...)
            end
          end
        end
      elseif contentType == 'category' then
        do
          local _with_0 = self:CreateButton(self.controlPanel, 'Delete Category', 6, 'delete')
          _with_0:Dock(LEFT)
          do
            local _base_1 = self
            local _fn_0 = _base_1.PromptDeleteCategory
            _with_0.DoClick = function(...)
              return _fn_0(_base_1, ...)
            end
          end
        end
      end
      do
        local _with_0 = vgui.Create('DIconLayout', panel)
        _with_0:Dock(TOP)
        _with_0:SetDropPos('28')
        _with_0:SetUseLiveDrag(true)
        _with_0:MakeDroppable('ccvccm_content', true)
        self.items = _with_0
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
  local _parent_0 = BasePanel
  local _base_0 = {
    PromptRenameDisplay = function(self)
      return Derma_StringRequest('Rename', 'Enter new display name:', self.label:GetText(), function(newName)
        return self.label:SetText(newName)
      end)
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
    __init = function(self, parent, data, window)
      _class_0.__parent.__init(self)
      self.window = window
      local panel
      do
        local _with_0 = vgui.Create('DPanel', parent)
        _with_0:SetCursor('sizeall')
        _with_0:Dock(TOP)
        _with_0.Paint = nil
        panel = _with_0
      end
      self:SetPanel(panel)
      self:WrapFunc(panel, 'PerformLayout', false, function(self, w, h)
        self:SizeToChildren(false, true)
        return print(RealTime(), self)
      end)
      self:RegisterAsSavable()
      do
        local controlPanel = vgui.Create('DPanel', panel)
        controlPanel:SetTall(22)
        controlPanel:SetZPos(1)
        controlPanel:DockMargin(0, 22, 0, 0)
        controlPanel:Dock(TOP)
        controlPanel.Paint = nil
        do
          local _with_0 = self:CreateButton(controlPanel, 'Edit', 1, 'pencil')
          _with_0:Dock(LEFT)
          _with_0.DoClick = function()
            return self:PromptRenameDisplay()
          end
        end
        do
          local _with_0 = self:CreateButton(controlPanel, 'Delete', 2, 'delete')
          _with_0:Dock(LEFT)
          _with_0.DoClick = function()
            return self:PromptDelete()
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
        _with_0.DoDoubleClick = function()
          if self.window:GetControlPanelVisibility() then
            return self:PromptRenameDisplay()
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
  local _parent_0 = BasePanel
  local _base_0 = {
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
    __init = function(self, parent, data, window)
      _class_0.__parent.__init(self)
      self.window = window
      local panel
      do
        local _with_0 = vgui.Create('DPanel', parent)
        _with_0:SetCursor('sizeall')
        _with_0:Dock(TOP)
        _with_0.Paint = nil
        panel = _with_0
      end
      self:SetPanel(panel)
      self:WrapFunc(panel, 'PerformLayout', false, function(self, w, h)
        self:SizeToChildren(false, true)
        return print(RealTime(), self)
      end)
      self:RegisterAsSavable()
      do
        local controlPanel = vgui.Create('DPanel', panel)
        controlPanel:SetTall(22)
        controlPanel:SetZPos(1)
        controlPanel:Dock(TOP)
        controlPanel:SetMouseInputEnabled(false)
        controlPanel.Paint = nil
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
      self.contentPanel = ContentPanel('category', window)
      do
        local _with_0 = vgui.Create('DCollapsibleCategory', hostPanel)
        _with_0:SetCursor('sizeall')
        _with_0:SetLabel(data.displayName or 'New Category')
        _with_0:SetContents(self.contentPanel:GetPanel())
        _with_0:SetList(parent)
        _with_0:Dock(TOP)
        _with_0.Header.DoDoubleClick = function()
          if window:GetControlPanelVisibility() then
            return self.contentPanel:PromptRenameCategory()
          end
        end
        self.category = _with_0
      end
      self:WrapFunc(self.category, 'OnRemove', false, function()
        return self:RemoveClassAndPanel()
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
  local _parent_0 = BasePanel
  local _base_0 = {
    AddTab = function(self, displayName, icon, content)
      if displayName == nil then
        displayName = 'New Tab'
      end
      local contentPanel = ContentPanel('tab', self.window)
      local tab
      tab = self.sheet:AddSheet(displayName, contentPanel:GetPanel(), icon, false, true).Tab
      tab.DoDoubleClick = function()
        if self.window:GetControlPanelVisibility() then
          return contentPanel:PromptRenameTab()
        end
      end
      self.window:AddControlPanel(contentPanel:GetControlPanel())
      return contentPanel:LoadFromTable(content)
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
    __init = function(self, parent, data, window)
      _class_0.__parent.__init(self)
      self.window = window
      local panel
      do
        local _with_0 = vgui.Create('DPanel', parent)
        _with_0:SetCursor('sizeall')
        _with_0:Dock(TOP)
        _with_0.Paint = nil
        panel = _with_0
      end
      self:SetPanel(panel)
      self:WrapFunc(panel, 'PerformLayout', false, function(self, w, h)
        self:SizeToChildren(false, true)
        return print(RealTime(), self)
      end)
      self:RegisterAsSavable()
      do
        local controlPanel = vgui.Create('DPanel', panel)
        controlPanel:SetTall(22)
        controlPanel:SetZPos(1)
        controlPanel:DockMargin(0, 22, 0, 0)
        controlPanel:Dock(TOP)
        controlPanel.Paint = nil
        do
          local _with_0 = self:CreateButton(controlPanel, 'Add Tab', nil, 'add')
          _with_0:Dock(LEFT)
          _with_0.DoClick = function()
            return self:AddTab()
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
        return print(RealTime(), self)
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
  local _parent_0 = BasePanel
  local _base_0 = {
    arguments = '',
    SetArgs = function(self, arguments)
      self.arguments = arguments
      local ETYPES = AddElementUI.ELEMENT_TYPES
      local _exp_0 = self.data.elementType
      if ETYPES.SERVER_CVAR == _exp_0 or ETYPES.SERVER_CCMD == _exp_0 then
        local consoleRunStr = self.data.internalName .. ' ' .. self.arguments
        return CCVCCM:Send({
          's',
          consoleRunStr
        })
      end
    end,
    PopulatePanel = function(self)
      local data = self.data
      local panel = self:GetPanel()
      local displayName, dataType, elementType, internalName
      displayName, dataType, elementType, internalName = data.displayName, data.dataType, data.elementType, data.internalName
      local DTYPES = AddElementUI.DATA_TYPES
      local ETYPES = AddElementUI.ELEMENT_TYPES
      do
        local controlPanel = vgui.Create('DPanel', panel)
        controlPanel:SetTall(22)
        controlPanel:SetZPos(1)
        controlPanel:DockMargin(0, 22, 0, 0)
        controlPanel:Dock(TOP)
        controlPanel.Paint = nil
        do
          local _with_0 = self:CreateButton(controlPanel, 'Edit', 1, 'pencil')
          _with_0:Dock(LEFT)
          _with_0.DoClick = function()
            return self:PromptEditPanel()
          end
        end
        do
          local _with_0 = self:CreateButton(controlPanel, 'Delete', 2, 'delete')
          _with_0:Dock(LEFT)
          _with_0.DoClick = function()
            return self:PromptDelete(panel)
          end
        end
        self.window:AddControlPanel(controlPanel)
      end
      if elementType == ETYPES.CLIENT_CCMD or elementType == ETYPES.SERVER_CCMD then
        local buttonText
        if dataType == DTYPES.NONE then
          buttonText = displayName
        else
          buttonText = 'Run ConCommand'
        end
        do
          local _with_0 = self:CreateButton(panel, buttonText, 3)
          _with_0:Dock(TOP)
          _with_0.DoClick = function()
            return LocalPlayer():ConCommand(internalName .. ' ' .. self.arguments)
          end
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
          _with_0:SetZPos(2)
          _with_0:Dock(TOP)
          _with_0:SetText(displayName)
          _with_0:SetDark(true)
          _with_0.OnChange = function(panel, checked)
            return self:SetArgs((function()
              if checked then
                return '1'
              else
                return '0'
              end
            end)())
          end
          if elementType == ETYPES.CLIENT_CVAR then
            _with_0:SetConVar(internalName)
          end
          return _with_0
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
        local comboBox
        do
          local _with_0 = vgui.Create('DComboBox', hostPanel)
          _with_0:SetConVar(internalName)
          _with_0.OnSelect = function(panel, index, value, selectedData)
            self:SetArgs(tostring(selectedData or value))
            if elementType == ETYPES.CLIENT_CVAR and panel.m_strConVar then
              return LocalPlayer():ConCommand(panel.m_strConVar .. ' ' .. tostring(selectedData or value))
            end
          end
          comboBox = _with_0
        end
        for i, choicesInfo in ipairs(data.choices) do
          comboBox:AddChoice(choicesInfo[1], choicesInfo[2])
        end
      elseif DTYPES.NUMBER == _exp_0 then
        do
          local _with_0 = CustomNumSlider(panel)
          _with_0:SetText(displayName)
          _with_0:SetMinMax(tonumber(data.minimum), tonumber(data.maximum))
          if data.interval then
            _with_0:SetInterval(tonumber(data.interval))
          end
          _with_0:SetLogarithmic(data.logarithmic)
          do
            local _with_1 = _with_0:GetPanel()
            _with_1:SetDark(true)
            _with_1.Label:SetTextInset(4, 0)
            _with_1:SetZPos(2)
            _with_1:Dock(TOP)
            if elementType == ETYPES.CLIENT_CVAR then
              _with_1:SetConVar(internalName)
            end
          end
          _with_0:SetCallback(function(classData, value)
            return self:SetArgs(classData:GetTextValue())
          end)
          return _with_0
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
            return self:SetArgs(textEntry:GetValue())
          end
          _with_0.OnValueChange = _with_0.OnChange
          if elementType == ETYPES.CLIENT_CVAR then
            _with_0:SetConVar(internalName)
          end
          return _with_0
        end
      elseif DTYPES.STRING_LIST == _exp_0 then
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
            if elementType == ETYPES.CLIENT_CVAR then
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
            local listInputUI = ListInputUI(0.5, 0.5, {
              header = 'Enter texts:',
              types = {
                {
                  dataType = DTYPES.STRING
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
                  _accum_0[_len_0] = value[1]
                  _len_0 = _len_0 + 1
                end
                flattenedValues = _accum_0
              end
              local strValue = table.concat(flattenedValues, listSeparator)
              self:SetArgs(strValue)
              if elementType == ETYPES.CLIENT_CVAR then
                return LocalPlayer():ConCommand(internalName .. ' ' .. strValue)
              end
            end)
          end
          return _with_0
        end
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
    SaveToTable = function(self)
      local data = self.data
      local saveTable = {
        internalName = data.internalName,
        displayName = data.displayName,
        arguments = self.arguments
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
      elseif DTYPES.NUMBER == _exp_1 then
        dataTypeStr = 'number'
        do
          saveTable.minimum = data.minimum
          saveTable.maximum = data.maximum
          saveTable.interval = data.interval
          saveTable.logarithmic = data.logarithmic
        end
      elseif DTYPES.STRING == _exp_1 then
        dataTypeStr = 'string'
      elseif DTYPES.STRING_LIST == _exp_1 then
        dataTypeStr = 'stringList'
      end
      saveTable.dataType = dataTypeStr
      return saveTable
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, parent, data, window)
      _class_0.__parent.__init(self)
      self.data = data
      self.window = window
      local panel
      do
        local _with_0 = vgui.Create('DPanel', parent)
        _with_0:SetCursor('sizeall')
        _with_0:Dock(TOP)
        _with_0.Paint = nil
        panel = _with_0
      end
      self:SetPanel(panel)
      self:RegisterAsSavable()
      self:WrapFunc(panel, 'PerformLayout', false, function(self, w, h)
        self:SizeToChildren(false, true)
        return print(RealTime(), self)
      end)
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
    AddRootTab = function(self, displayName, icon, content)
      if displayName == nil then
        displayName = 'New Tab'
      end
      if not (IsValid(self.sheet)) then
        self:CreateSheet()
      end
      local contentPanel = ContentPanel('tab', self)
      local tab
      tab = self.sheet:AddSheet(displayName, contentPanel:GetPanel(), icon, false, true).Tab
      tab.DoDoubleClick = function()
        if self.controlPanelVisibility then
          return contentPanel:PromptRenameTab()
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
        return print(RealTime(), self)
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
      return ProgressUI(0.25, 0.25, {
        routine = routine,
        expectedRuns = table.Count(BasePanel.panelClasses),
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
    end,
    LoadFromFileRoutine = function(self, fileName)
      local fileText = file.Read(fileName, 'DATA')
      local data
      if fileText then
        data = util.JSONToTable(fileText)
      end
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
        local displayName, icon, content
        displayName, icon, content = _des_0.displayName, _des_0.icon, _des_0.content
        self:AddRootTab(displayName, icon, content)
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
        do
          local _with_0 = window.btnMinim
          _with_0:SetDisabled(false)
          _with_0.DoClick = function()
            return window:Hide()
          end
        end
        self.__class.managerWindow = window
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
        panel:AddChoice('Numeric', DTYPES.NUMBER, dataTypeSelected == DTYPES.NUMBER)
        panel:AddChoice('Text', DTYPES.STRING, dataTypeSelected == DTYPES.STRING)
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
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.CHOICE)
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
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.NUMBER)
      end
      do
        local panel = vgui.Create('DTextEntry', scrollPanel)
        if self.data.minimum then
          panel:SetText(self.data.minimum)
        end
        panel:SetZPos(10)
        panel:Dock(TOP)
        panel.OnChange = function()
          self.data.minimum = panel:GetValue()
        end
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.NUMBER)
      end
      do
        local panel = self:CreateLabel(scrollPanel, 'Maximum Value', 11)
        panel:Dock(TOP)
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.NUMBER)
      end
      do
        local panel = vgui.Create('DTextEntry', scrollPanel)
        if self.data.maximum then
          panel:SetText(self.data.maximum)
        end
        panel:SetZPos(12)
        panel:Dock(TOP)
        panel.OnChange = function()
          self.data.maximum = panel:GetValue()
        end
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.NUMBER)
      end
      do
        local panel = self:CreateLabel(scrollPanel, 'Interval Between Values (blank = 0.01)', 13)
        panel:Dock(TOP)
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.NUMBER)
      end
      do
        local panel = vgui.Create('DTextEntry', scrollPanel)
        if self.data.interval then
          panel:SetText(self.data.interval)
        end
        panel:SetZPos(14)
        panel:Dock(TOP)
        panel.OnChange = function()
          self.data.interval = panel:GetValue()
        end
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.NUMBER)
      end
      do
        local panel = self:CreateLabel(scrollPanel, 'List Separator', 15)
        panel:Dock(TOP)
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.STRING_LIST)
      end
      do
        local panel = vgui.Create('DTextEntry', scrollPanel)
        if self.data.listSeparator then
          panel:SetText(self.data.listSeparator)
        end
        panel:SetZPos(16)
        panel:Dock(TOP)
        panel.OnChange = function()
          self.data.listSeparator = panel:GetValue()
        end
        self.elementPanelDisplayFlags[panel] = commDisplayFlags
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.STRING_LIST)
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
        self.dataPanelDisplayFlags[panel] = GetBitflagFromIndices(DTYPES.NUMBER)
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
        if name == '' then
          dataValid = false
          invalidReason = "\"" .. tostring(name) .. "\" is not a valid ConCommand / ConVar!"
        elseif IsConCommandBlocked(name) then
          dataValid = false
          invalidReason = "\"" .. tostring(name) .. "\" can't be altered / used by CCVCCM!"
        else
          local _exp_0 = self.data.dataType
          if DTYPES.NONE == _exp_0 then
            if isCVar then
              dataValid = false
              invalidReason = "None data type is only valid for ConCommands!"
            end
          elseif DTYPES.NUMBER == _exp_0 then
            local minValue = tonumber(self.data.minimum)
            if not (minValue) then
              dataValid = false
              invalidReason = "Minimum value \"" .. tostring(minValue) .. "\" is not a number!"
            end
            local maxValue = tonumber(self.data.maximum)
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
          elseif DTYPES.CHOICE == _exp_0 then
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
    SERVER_CCMD = 6
  }
  self.DATA_TYPES = {
    NONE = 0,
    BOOL = 1,
    CHOICE = 2,
    NUMBER = 3,
    STRING = 4,
    STRING_LIST = 5,
    COMPLEX_LIST = 6
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  AddElementUI = _class_0
end
do
  local _class_0
  local _parent_0 = BaseUI
  local _base_0 = {
    SetCallback = function(self, func)
      self.callback = func
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, w, h, selectedIcon)
      if selectedIcon == nil then
        selectedIcon = ''
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
        _with_0:SetPlaceholderText('Filter...')
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
          if self.callback then
            return self:callback(browser:GetSelectedIcon())
          end
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
          do
            local _with_0 = vgui.Create('DCheckBox', rowElementPanel)
            if currentValue then
              _with_0:SetValue(currentValue)
            end
          end
        elseif DTYPES.CHOICE == _exp_0 then
          local comboBox = vgui.Create('DComboBox', rowElementPanel)
          for display, value in pairs(dataTypeInfo.choices) do
            comboBox:AddChoice(display, value, currentValue == value)
          end
        elseif DTYPES.NUMBER == _exp_0 then
          local min, max, interval, logarithmic
          min, max, interval, logarithmic = dataTypeInfo.min, dataTypeInfo.max, dataTypeInfo.interval, dataTypeInfo.logarithmic
          local slider
          do
            local _with_0 = CustomNumSlider(rowElementPanel)
            _with_0:SetText(nil)
            _with_0:SetMinMax(min, max)
            _with_0:SetInterval(interval)
            _with_0:SetLogarithmic(logarithmic)
            if currentValue then
              _with_0:GetPanel():SetValue(currentValue)
            end
            slider = _with_0
          end
        elseif DTYPES.STRING == _exp_0 then
          do
            local _with_0 = vgui.Create('DTextEntry', rowElementPanel)
            if currentValue then
              _with_0:SetValue(currentValue)
            end
          end
        end
      end
      self.rowPanels[rowClass] = true
      return rowClass
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
            values = { }
            for i, rowPanel in ipairs(sortedRowPanels) do
              local childrenPanels = rowPanel:GetChildren()
              self:SortPanelsByPosition(childrenPanels)
              do
                local _accum_0 = { }
                local _len_0 = 1
                for _index_0 = 1, #childrenPanels do
                  local childPanel = childrenPanels[_index_0]
                  _accum_0[_len_0] = childPanel:GetValue()
                  _len_0 = _len_0 + 1
                end
                values[i] = _accum_0
              end
            end
            return self:callback(values)
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