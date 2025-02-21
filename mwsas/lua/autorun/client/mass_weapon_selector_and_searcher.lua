local info = {
  workshop_page = 'TBD',
  profile_page = 'https://steamcommunity.com/id/Piengineer12',
  github_page = 'https://github.com/Piengineer12/public-addons/tree/master/mwsas',
  donate_page = 'https://ko-fi.com/piengineer12',
  extra_info = 'Links above are confirmed working as of 2025-02-21. All dates are in ISO 8601 format.'
}
local WeaponSelectorVerticalScroller
local BasicDrawing
do
  local _class_0
  local _base_0 = {
    CreateForwarder = function(self, target, funcName)
      return function(self, ...)
        return target[funcName](target, ...)
      end
    end,
    GetWeaponName = function(self, wep)
      return language.GetPhrase(wep.PrintName ~= "" and wep.PrintName or wep:GetClass())
    end,
    RegisterCVars = function(self, name, info)
      return self.__class:RegisterCVarsStatic(name, info)
    end,
    GetConVarValue = function(self, ref)
      local entry = self.__class.cvars[ref]
      if entry then
        local _exp_0 = entry.type
        if 'bool' == _exp_0 then
          return entry.conVar:GetBool()
        elseif 'int' == _exp_0 then
          return entry.conVar:GetInt()
        elseif 'float' == _exp_0 then
          return entry.conVar:GetFloat()
        else
          return entry.conVar:GetString()
        end
      else
        return self:Log('Failed to associate %s with any ConVar!', ref)
      end
    end,
    IsDebugLevel = function(self, level)
      return level <= self:GetConVarValue('debug')
    end,
    Log = function(self, text, ...)
      return MsgC(Color(0, 255, 255), "[MWS&S] ", color_white, string.format(tostring(text) .. "\n", ...))
    end,
    FormatNumber = function(self, num)
      return num < 1e3 and string.Comma(math.Round(num, 3)) or string.Comma(math.Round(num))
    end,
    DrawTextOutlined = function(self, text, font, x, y, color, outlineOnly)
      if outlineOnly then
        color = color_transparent
      end
      return draw.SimpleTextOutlined(text, font, x, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, self:GetConVarValue('outline'), self:GetOutlineColor(color))
    end,
    GetOutlineColor = function(self, color)
      local outlineColorMul = self:GetConVarValue('outline_colorbleed') / 100
      if outlineColorMul > 0 then
        return Color(color.r * outlineColorMul, color.g * outlineColorMul, color.b * outlineColorMul)
      else
        return color_black
      end
    end,
    DrawRarityText = function(self, text, font, x, y, w, tier, time, scissorX, scissorY)
      local outlineThickness = self:GetConVarValue('outline')
      local stringSub = string.sub
      scissorX = (scissorX or 0) + x - outlineThickness
      scissorY = (scissorY or 0) + y - outlineThickness
      surface.SetFont(font)
      local textTotalWidth, textTotalHeight = surface.GetTextSize(text)
      local nameExtraW = textTotalWidth - w
      local nameScrollFactor = nameExtraW > 0 and (math.cos(time / 2) + 1) / 2 or 1
      local nameScrollAmt = Lerp(nameScrollFactor, nameExtraW, 0)
      local startIndex, endIndex = self:SubstringBySize(text, nameScrollAmt - outlineThickness, nameScrollAmt + w + outlineThickness)
      local undrawnX = surface.GetTextSize(stringSub(text, 1, startIndex - 1))
      local offsetX = undrawnX - nameScrollAmt
      local textX = x + offsetX
      render.SetScissorRect(scissorX, scissorY, scissorX + w + outlineThickness * 2, scissorY + textTotalHeight + outlineThickness * 2, true)
      local chars
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i, code in utf8.codes(utf8.force(stringSub(text, startIndex, endIndex + 4))) do
          _accum_0[_len_0] = utf8.char(code)
          _len_0 = _len_0 + 1
        end
        chars = _accum_0
      end
      local charData = { }
      local numberTier = tonumber(tier)
      for _index_0 = 1, #chars do
        local char = chars[_index_0]
        local color = tier
        if numberTier then
          color = InsaneStats:GetPhasedRarityColor(numberTier, (undrawnX + textX) / w)
        end
        table.insert(charData, {
          x = textX,
          color = color
        })
        textX = textX + self:DrawTextOutlined(char, font, textX, y, color, true)
      end
      for i, v in ipairs(chars) do
        draw.SimpleText(v, font, charData[i].x, y, charData[i].color)
      end
      return render.SetScissorRect(0, 0, 0, 0, false)
    end,
    SubstringBySize = function(self, text, startX, endX)
      local textLength = #text
      local stringSub = string.sub
      local iL, iR = 1, textLength
      while iL < iR do
        local iM = math.floor((iL + iR) / 2)
        local substring = stringSub(text, 1, iM)
        local x = surface.GetTextSize(substring)
        if x < startX then
          iL = iM + 1
        else
          iR = iM
        end
      end
      local startTextIndex = iL
      iL, iR = 1, textLength
      while iL < iR do
        local iM = math.floor((iL + iR) / 2)
        local substring = stringSub(text, 1, iM)
        local x = surface.GetTextSize(substring)
        if x > endX then
          iR = iM
        else
          iL = iM + 1
        end
      end
      local endTextIndex = iR
      return startTextIndex, endTextIndex
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "BasicDrawing"
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
  self.cvarInfo = { }
  self.cvars = { }
  self.RegisterCVarsStatic = function(self, name, info)
    table.insert(self.cvarInfo, {
      name = name,
      info = info
    })
    for _index_0 = 1, #info do
      local entry = info[_index_0]
      local ref = entry.name or entry.ref
      local conVarName = 'mwsas_' .. ref
      local description = self:AssemblePhrase('#mwsas.' .. ref .. '.desc')
      local conVar
      local _exp_0 = entry.type
      if 'bool' == _exp_0 then
        conVar = CreateClientConVar(conVarName, entry.default, true, false, description, 0, 1)
      elseif 'int' == _exp_0 then
        conVar = CreateClientConVar(conVarName, entry.default, true, false, description, entry.min, entry.max)
      else
        conVar = CreateClientConVar(conVarName, entry.default, true, false, description)
      end
      self.cvars[entry.ref] = {
        conVar = conVar,
        type = entry.type
      }
    end
  end
  self.PopulateToolMenu = function(self)
    local _list_0 = self.cvarInfo
    for _index_0 = 1, #_list_0 do
      local categoryInfo = _list_0[_index_0]
      spawnmenu.AddToolMenuOption('Utilities', 'MWS&S', categoryInfo.name, '#mwsas.' .. categoryInfo.name, nil, nil, self:FillInDForm(categoryInfo))
    end
  end
  self.FillInDForm = function(self, categoryInfo)
    return function(panel)
      local categoryPrefix = '#mwsas.' .. categoryInfo.name
      panel:ControlHelp(categoryPrefix)
      local _list_0 = categoryInfo.info
      for _index_0 = 1, #_list_0 do
        local info = _list_0[_index_0]
        local ref = info.name or info.ref
        local displayName = '#mwsas.' .. ref
        local cvar = 'mwsas_' .. ref
        local _exp_0 = info.type
        if 'bool' == _exp_0 then
          panel:CheckBox(displayName, cvar)
        elseif 'int' == _exp_0 then
          panel:NumberWang(displayName, cvar, info.min, info.max)
        elseif 'float' == _exp_0 then
          local decimals = 4 - math.Round(math.log10(info.max - info.min))
          panel:NumSlider(displayName, cvar, info.min, info.max, decimals)
        else
          panel:TextEntry(displayName, cvar)
        end
        panel:Help(self:AssemblePhrase(displayName .. '.desc'))
      end
    end
  end
  self.AssemblePhrase = function(self, phrase)
    local token = phrase .. '.1'
    if token == language.GetPhrase(token) then
      return phrase
    else
      local assembled = { }
      local i = 1
      while i < 99 do
        token = string.format('%s.%u', phrase, i)
        local translated = language.GetPhrase(token)
        if token == translated then
          break
        end
        table.insert(assembled, translated)
        i = i + 1
      end
      return table.concat(assembled)
    end
  end
  BasicDrawing = _class_0
end
local WeaponSelector
do
  local _class_0
  local _parent_0 = BasicDrawing
  local _base_0 = {
    GetWeaponSlot = function(self, wep)
      local alphabetRange = self:GetConVarValue('selector_alphabetic')
      if alphabetRange > 0 then
        return math.floor(utf8.codepoint(self:GetWeaponName(wep):lower()) / alphabetRange)
      else
        return wep:GetSlot()
      end
    end,
    Start = function(self)
      self.ply = LocalPlayer()
      local selectedWeapon = self.ply:GetActiveWeapon()
      self.selectedWeapon = nil
      if not (IsValid(self.window)) then
        self:CreateWindow()
      end
      self:Refresh()
      self:RefreshFonts()
      self:SelectWeapon(selectedWeapon)
      self.window:Show()
      self.window:MakePopup()
      self.window:SetKeyboardInputEnabled(false)
      self.window:InvalidateChildren(true)
      self:UpdateWeaponPositions()
      if IsValid(selectedWeapon) then
        input.SetCursorPos(self:GetCursorPositionForWeapon(selectedWeapon))
        self:UpdateWeaponPositions()
      end
      return self.ply:EmitSound('common/wpn_hudon.wav', 0, 100, self:GetConVarValue('volume') / 100)
    end,
    CreateWindow = function(self)
      local window
      do
        local _with_0 = vgui.Create('DFrame')
        _with_0:SetSize(ScrW(), ScrH())
        _with_0:SetTitle('')
        _with_0:ShowCloseButton(false)
        _with_0.Paint = nil
        _with_0.OnMousePressed = function(panel, key)
          if key == MOUSE_RIGHT then
            self:SelectWeapon()
            self:End()
          end
        end
        _with_0.OnCursorMoved = function()
          self:SelectWeapon()
          self:UpdateWeaponPositions()
        end
        window = _with_0
      end
      self.window = window
      do
        local _with_0 = vgui.Create('DSizeToContents', window)
        _with_0:SetSizeY(false)
        _with_0:SetTall(window:GetTall())
        _with_0.OnCursorMoved = self:CreateForwarder(window, 'OnCursorMoved')
        _with_0.OnMousePressed = self:CreateForwarder(window, 'OnMousePressed')
        self.horizontalScroller = _with_0
      end
    end,
    GetHorizontalScroller = function(self)
      return self.horizontalScroller
    end,
    RefreshRequired = function(self)
      local weaponH = self:GetConVarValue('selector_height')
      local weaponW = self:GetConVarValue('selector_width')
      if self.weaponH ~= weaponH or self.weaponW ~= weaponW then
        self.weaponH = weaponH
        self.weaponW = weaponW
        self:RefreshFonts(true)
        return true
      end
      local w, h = self.window:GetSize()
      if w ~= ScrW() or h ~= ScrH() then
        return true
      end
      local _list_0 = self.ply:GetWeapons()
      for _index_0 = 1, #_list_0 do
        local wep = _list_0[_index_0]
        local weaponSlot = self:GetWeaponSlot(wep)
        local slotTable = self.weaponData[weaponSlot]
        if not (slotTable and slotTable[v]) then
          return true
        end
      end
      for slot, weps in pairs(self.weaponData) do
        for wep, data in pairs(weps) do
          if not (IsValid(wep and wep:GetOwner() == self.ply)) then
            return true
          end
        end
      end
      return false
    end,
    Refresh = function(self)
      if self:RefreshRequired() then
        self.window:SetSize(ScrW(), ScrH())
        self.weaponData = { }
        local _list_0 = self.ply:GetWeapons()
        for _index_0 = 1, #_list_0 do
          local wep = _list_0[_index_0]
          local weaponSlot = self:GetWeaponSlot(wep)
          self.weaponData[weaponSlot] = self.weaponData[weaponSlot] or { }
          self.weaponData[weaponSlot][wep] = self:GetWeaponName(wep)
        end
        if self:IsDebugLevel(1) then
          self:Log('Refreshed weapon selector weapons!')
          if self:IsDebugLevel(2) then
            PrintTable(self.weaponData)
          end
        end
        return self:RebuildWeaponButtons()
      end
    end,
    FontRefreshRequired = function(self)
      local clipFont = self:GetConVarValue('selector_clip_font')
      local clipFontHeight = self:GetFontHeight('clip')
      local detailsFont = self:GetConVarValue('selector_details_font')
      local detailsFontHeight = self:GetFontHeight('details')
      if self.clipFont ~= clipFont or self.clipFontHeight ~= clipFontHeight or self.detailsFont ~= detailsFont or self.detailsFontHeight ~= detailsFontHeight then
        self.clipFont = clipFont
        self.clipFontHeight = clipFontHeight
        self.detailsFont = detailsFont
        self.detailsFontHeight = detailsFontHeight
        return true
      else
        return false
      end
    end,
    GetFontHeight = function(self, arg)
      return ScreenScale(self:GetConVarValue("selector_" .. tostring(arg) .. "_font_size"))
    end,
    RefreshFonts = function(self, force)
      if self:FontRefreshRequired() or force then
        surface.CreateFont('MWSAS.WeaponIcons', {
          font = 'HalfLife2',
          size = self.weaponH,
          weight = 0,
          antialias = true,
          additive = true
        })
        surface.CreateFont('MWSAS.WeaponIconsBackground', {
          font = 'HalfLife2',
          size = self.weaponH,
          weight = 0,
          antialias = true,
          blursize = 14,
          scanlines = 5,
          additive = true
        })
        surface.CreateFont('MWSAS.Clip', {
          font = self.clipFont,
          size = self.clipFontHeight
        })
        return surface.CreateFont('MWSAS.SelectorDetails', {
          font = self.detailsFont,
          size = self.detailsFontHeight
        })
      end
    end,
    RebuildWeaponButtons = function(self)
      self.horizontalScroller:Clear()
      self.verticalScrollers = { }
      local offsetX = 0
      local weaponW = self.weaponW
      local weaponH = self.weaponH
      for slot, weps in SortedPairs(self.weaponData) do
        local verticalScroller = WeaponSelectorVerticalScroller(self, offsetX, weaponW, weaponH, weps)
        verticalScroller:SelectWeapon(wep)
        table.insert(self.verticalScrollers, verticalScroller)
        offsetX = offsetX + weaponW
      end
    end,
    GetCursorPositionForWeapon = function(self, wep)
      local target, wepY
      local _list_0 = self.verticalScrollers
      for _index_0 = 1, #_list_0 do
        local verticalScroller = _list_0[_index_0]
        do
          wepY = verticalScroller:GetWeaponY(wep)
          if wepY then
            target = verticalScroller
            break
          end
        end
      end
      if not (target) then
        return 
      end
      local xMax, yMax = self.window:GetSize()
      local sensitivityX = self:GetConVarValue('selector_sensitivity_x')
      local sensitivityY = self:GetConVarValue('selector_sensitivity_y')
      local leftBoundary = (sensitivityX - 1) / sensitivityX / 2 * xMax
      local rightBoundary = xMax - leftBoundary
      local upBoundary = (sensitivityY - 1) / sensitivityY / 2 * yMax
      local downBoundary = yMax - upBoundary
      local vsX, vsY, vsW, vsH = target:GetBounds()
      local scrollerWidth = self.horizontalScroller:GetWide()
      local offsetX = vsX + vsW / 2
      local xPos
      if scrollerWidth > rightBoundary - leftBoundary then
        xPos = math.Remap(offsetX, 0, scrollerWidth, leftBoundary, rightBoundary)
      else
        xPos = self.horizontalScroller:GetX() + offsetX
      end
      local scrollerHeight = vsH
      local yPos
      if scrollerHeight > downBoundary - upBoundary then
        yPos = math.Remap(wepY, 0, scrollerHeight, upBoundary, downBoundary)
      else
        yPos = vsY + wepY
      end
      if self:IsDebugLevel(2) then
        self:Log('Boundaries: up=%i, right=%i, down=%i, left=%i', upBoundary, rightBoundary, downBoundary, leftBoundary)
        self:Log('HSC Bounds: %i, %i, %i, %i,', self.horizontalScroller:GetBounds())
        self:Log('VSC Bounds: %i, %i, %i, %i,', vsX, vsY, vsW, vsH)
        self:Log('Snapped cursor position to %i, %i', xPos, yPos)
      end
      return xPos, yPos
    end,
    UpdateWeaponPositions = function(self)
      local xMax, yMax = self.window:GetSize()
      local width = self.horizontalScroller:GetWide()
      local sensitivityX = self:GetConVarValue('selector_sensitivity_x')
      local sensitivityY = self:GetConVarValue('selector_sensitivity_y')
      local leftBoundary = (sensitivityX - 1) / sensitivityX / 2 * xMax
      local rightBoundary = xMax - leftBoundary
      local upBoundary = (sensitivityY - 1) / sensitivityY / 2 * yMax
      local downBoundary = yMax - upBoundary
      local cursorX, cursorY = input.GetCursorPos()
      if width > rightBoundary - leftBoundary then
        local xPos = math.Remap(cursorX, leftBoundary, rightBoundary, leftBoundary, rightBoundary - width)
        self.horizontalScroller:SetX(xPos)
      else
        self.horizontalScroller:SetX((xMax - width) / 2)
      end
      local _list_0 = self.verticalScrollers
      for _index_0 = 1, #_list_0 do
        local verticalScroller = _list_0[_index_0]
        local height = verticalScroller:GetTall()
        if height > downBoundary - upBoundary then
          local yPos = math.Remap(cursorY, upBoundary, downBoundary, upBoundary, downBoundary - height)
          verticalScroller:SetY(yPos)
        else
          verticalScroller:SetY((yMax - height) / 2)
        end
      end
    end,
    SelectWeapon = function(self, wep)
      if wep ~= self.selectedWeapon then
        self.selectedWeapon = wep
        if wep then
          self.ply:EmitSound('common/wpn_moveselect.wav', 0, 100, self:GetConVarValue('volume') / 100)
        end
        local _list_0 = self.verticalScrollers
        for _index_0 = 1, #_list_0 do
          local verticalScroller = _list_0[_index_0]
          verticalScroller:SelectWeapon(wep)
        end
      end
    end,
    End = function(self)
      if self.window:IsVisible() then
        local selectedWeapon = self.selectedWeapon
        if IsValid(selectedWeapon) then
          input.SelectWeapon(selectedWeapon)
          if self:IsDebugLevel(2) then
            self:Log('Switching to %s!', tostring(selectedWeapon))
          end
          self.ply:EmitSound('common/wpn_hudoff.wav', 0, 100, self:GetConVarValue('volume') / 100)
        else
          self.ply:EmitSound('common/wpn_denyselect.wav', 0, 100, self:GetConVarValue('volume') / 100)
        end
        return self.window:Hide()
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      self.weaponData = { }
      return self:RegisterCVars('selector', {
        {
          ref = 'selector_alphabetic',
          type = 'int',
          default = '0',
          min = 0,
          max = 255
        },
        {
          ref = 'selector_color',
          type = 'string',
          default = '255 255 255 255'
        },
        {
          ref = 'selector_nobounce',
          type = 'bool',
          default = '0'
        },
        {
          ref = 'selector_sensitivity_x',
          type = 'float',
          default = '1.5',
          min = 1,
          max = 10
        },
        {
          ref = 'selector_sensitivity_y',
          type = 'float',
          default = '1.5',
          min = 1,
          max = 10
        },
        {
          ref = 'selector_width',
          type = 'float',
          default = '256',
          min = 0,
          max = 10000
        },
        {
          ref = 'selector_height',
          type = 'float',
          default = '128',
          min = 0,
          max = 10000
        },
        {
          ref = 'selector_clip_font',
          type = 'string',
          default = 'Orbitron Medium'
        },
        {
          ref = 'selector_clip_font_size',
          type = 'float',
          default = '8',
          min = 0,
          max = 1000
        },
        {
          ref = 'selector_details_font',
          type = 'string',
          default = 'Orbitron Medium'
        },
        {
          ref = 'selector_details_font_size',
          type = 'float',
          default = '8',
          min = 0,
          max = 1000
        }
      })
    end,
    __base = _base_0,
    __name = "WeaponSelector",
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
  WeaponSelector = _class_0
end
do
  local _class_0
  local _parent_0 = BasicDrawing
  local _base_0 = {
    gapSize = 2,
    colors = {
      normal = Color(0, 0, 0, 239),
      selected = Color(127, 127, 127, 239)
    },
    weaponSelectorChars = {
      weapon_smg1 = 'a',
      weapon_shotgun = 'b',
      weapon_shotgun_hl1 = 'b',
      weapon_crowbar = 'c',
      weapon_crowbar_hl1 = 'c',
      weapon_pistol = 'd',
      weapon_357 = 'e',
      weapon_357_hl1 = 'e',
      weapon_crossbow = 'g',
      weapon_physgun = 'h',
      weapon_rpg = 'i',
      weapon_rpg_hl1 = 'i',
      weapon_bugbait = 'j',
      weapon_frag = 'k',
      weapon_ar2 = 'l',
      weapon_physcannon = 'm',
      weapon_stunstick = 'n',
      weapon_slam = 'o'
    },
    GetFontHeight = function(self, ...)
      return self.weaponSelector:GetFontHeight(...)
    end,
    CreateWeaponPanel = function(self, index, wep, name)
      do
        local _with_0 = vgui.Create('DButton', self.panel)
        _with_0:SetText('')
        _with_0:SetSize(self.panel:GetWide(), self.weaponH)
        _with_0.Paint = function(panel, w, h)
          if IsValid(wep) then
            local selected = self.selectedIndex == index
            local gapSize = self.gapSize
            draw.RoundedBox(8, gapSize, gapSize, w - gapSize * 2, h - gapSize * 2, self.colors[selected and 'selected' or 'normal'])
            local color = self:DetermineWeaponColor(wep)
            local x, y = panel:LocalToScreen()
            self:DrawWeaponIcon(wep, selected, color, x, y, w, h)
            self:DrawWeaponClips(wep, w)
            return self:DrawWeaponDetails(wep, name, x, y, w, h)
          else
            return self.weaponSelector:Refresh()
          end
        end
        _with_0.OnCursorMoved = function(panel, w, h)
          self.weaponSelector:SelectWeapon(wep)
          return self.weaponSelector:UpdateWeaponPositions()
        end
        _with_0.DoClick = function()
          return self.weaponSelector:End()
        end
        _with_0.DoRightClick = function()
          self.weaponSelector:SelectWeapon()
          return self.weaponSelector:End()
        end
        return _with_0
      end
    end,
    DetermineWeaponColor = function(self, wep)
      if (InsaneStats and InsaneStats:GetConVarValue('wpass2_enabled')) then
        local tintMode = InsaneStats:GetConVarValue('hud_wepsel_tint')
        if tintMode > 2 or tintMode > 1 and wep.WepSelectIcon == defaultWeaponIconID or tintMode > 0 and not wep:IsScripted() then
          local tier = InsaneStats:GetWPASS2Rarity(wep) or 0
          return InsaneStats:GetPhasedRarityColor(tier)
        end
      end
      if wep:IsScripted() then
        return color_white
      else
        return string.ToColor(self:GetConVarValue('selector_color'))
      end
    end,
    DrawWeaponIcon = function(self, wep, selected, color, x, y, w, h)
      if wep.DrawWeaponSelection then
        return self:DrawScriptedWeaponIcon(wep, selected, color, x, y, w, h)
      elseif not wep:IsScripted() then
        local wepClass = wep:GetClass():lower()
        local char = self.weaponSelectorChars[wepClass] or 'V'
        draw.SimpleText(char, "MWSAS.WeaponIconsBackground", w / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return draw.SimpleText(char, "MWSAS.WeaponIcons", w / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end
    end,
    DrawScriptedWeaponIcon = function(self, wep, selected, color, x, y, w, h)
      local oldClipState = DisableClipping(selected or false)
      if wep.DrawWeaponSelection == self.defaultWeaponDrawing or wep.DrawWeaponSelection_DLib == self.defaultWeaponDrawing then
        local can = hook.Run('DrawWeaponSelection', wep, 0, 0, w, h, 255)
        if can ~= false then
          hook.Run('PreDrawWeaponSelection', wep, 0, 0, w, h, 255)
          surface.SetDrawColor(color)
          surface.SetTexture(wep.WepSelectIcon)
          local fsin = 0
          if wep.BounceWeaponIcon == true and not self:GetConVarValue('selector_nobounce') then
            fsin = math.sin(CurTime() * 10) * 5
          end
          local borderSize = 10
          surface.DrawTexturedRect(borderSize + fsin, borderSize - fsin, w - (borderSize + fsin) * 2, w / 2 - borderSize + fsin)
          if selected then
            wep:PrintWeaponInfo(borderSize + w, borderSize + h * 0.95, 255)
          end
          hook.Run('PostDrawWeaponSelection', wep, 0, 0, w, h, 255)
        end
      else
        local oldBounceValue = wep.BounceWeaponIcon
        if self:GetConVarValue('selector_nobounce') then
          wep.BounceWeaponIcon = nil
        end
        local oldDrawWeaponInfoBox = wep.DrawWeaponInfoBox
        if not (selected) then
          wep.DrawWeaponInfoBox = false
        end
        if autoicon then
          local m = Matrix()
          m:Translate(Vector(-x, -y, 0))
          cam.PushModelMatrix(m, true)
          local success, err = pcall(wep.DrawWeaponSelection, wep, x, y, w, h, 255)
          cam.PopModelMatrix()
          if not (success) then
            error(err)
          end
        else
          wep:DrawWeaponSelection(0, 0, w, h, 255)
        end
        wep.BounceWeaponIcon = oldBounceValue
        wep.DrawWeaponInfoBox = oldDrawWeaponInfoBox
      end
      return DisableClipping(oldClipState)
    end,
    DrawWeaponClips = function(self, wep, x)
      local ply = self.ply
      if (IsValid(ply) and ply:IsSuitEquipped()) then
        local outlineThickness = self:GetConVarValue('outline')
        local ammoMaxOverride = GetConVar('gmod_maxammo'):GetInt()
        ammoMaxOverride = ammoMaxOverride > 0 and ammoMaxOverride
        local customAmmoDisplay = wep.CustomAmmoDisplay and wep:CustomAmmoDisplay()
        if not ((customAmmoDisplay and customAmmoDisplay.Draw)) then
          customAmmoDisplay = { }
        end
        local gapSize = self.gapSize
        local textY = outlineThickness + gapSize
        local ammoType1 = wep:GetPrimaryAmmoType()
        local useAmmoType1 = ammoType1 > -1
        local reserve1 = tonumber(customAmmoDisplay.PrimaryAmmo or useAmmoType1 and ply:GetAmmoCount(ammoType1)) or -1
        local maxClip1 = tonumber(wep:GetMaxClip1()) or -1
        local clip1 = tonumber(customAmmoDisplay.PrimaryClip or wep:Clip1()) or -1
        local maxReserve1 = tonumber(ammoMaxOverride or useAmmoType1 and game.GetAmmoMax(ammoType1)) or -1
        local ammoUnits = { }
        if maxClip1 > -1 or clip1 > -1 then
          table.insert(ammoUnits, {
            clip1,
            maxClip1
          })
        end
        if reserve1 > -1 then
          table.insert(ammoUnits, {
            reserve1,
            maxReserve1
          })
        end
        local fontHeight = self:GetFontHeight('clip')
        if next(ammoUnits) then
          self:DrawAmmoText(ammoUnits, x - outlineThickness - gapSize, textY)
          textY = textY + fontHeight
        end
        local ammoType2 = wep:GetSecondaryAmmoType()
        local useAmmoType2 = ammoType2 > -1
        local reserve2 = tonumber(customAmmoDisplay.SecondaryAmmo or useAmmoType2 and ply:GetAmmoCount(ammoType2)) or -1
        local maxClip2 = tonumber(wep:GetMaxClip2()) or -1
        local clip2 = tonumber(customAmmoDisplay.SecondaryClip or wep:Clip2()) or -1
        local maxReserve2 = tonumber(ammoMaxOverride or useAmmoType2 and game.GetAmmoMax(ammoType2)) or -1
        ammoUnits = { }
        if maxClip2 > -1 or clip2 > -1 then
          table.insert(ammoUnits, {
            clip2,
            maxClip2
          })
        end
        if reserve2 > -1 then
          table.insert(ammoUnits, {
            reserve2,
            maxReserve2
          })
        end
        if next(ammoUnits) then
          return self:DrawAmmoText(ammoUnits, x - outlineThickness - gapSize, textY)
        end
      end
    end,
    DrawWeaponDetails = function(self, wep, name, x, y, w, h)
      local outlineThickness = self:GetConVarValue('outline')
      local gapSize = self.gapSize
      local fontHeight = self:GetFontHeight('details')
      local weaponDetails = { }
      local textX = gapSize + outlineThickness
      local textY = h - gapSize - fontHeight - outlineThickness * 2
      local maxWidth = w - gapSize * 2 - outlineThickness * 2
      local displayTime = RealTime() - self.openTime
      if InsaneStats then
        local rarity
        if InsaneStats:GetConVarValue('wpass2_enabled') then
          if wep.insaneStats_Modifiers then
            rarity = InsaneStats:GetWPASS2Rarity(wep) or 0
            table.insert(weaponDetails, 'Tier ' .. wep.insaneStats_Tier)
          else
            wep:InsaneStats_MarkForUpdate()
          end
        end
        if InsaneStats:GetConVarValue('xp_enabled') then
          table.insert(weaponDetails, 'Level ' .. InsaneStats:FormatNumber(wep:InsaneStats_GetLevel()))
        end
        if next(weaponDetails) then
          self:DrawRarityText(table.concat(weaponDetails, ", "), 'MWSAS.SelectorDetails', textX, textY, maxWidth, color_white, displayTime, x, y)
          textY = textY - (fontHeight + outlineThickness)
        end
        if rarity then
          self:DrawRarityText(InsaneStats:GetWPASS2Name(wep), 'MWSAS.SelectorDetails', textX, textY, maxWidth, rarity, displayTime, x, y)
          textY = textY - (fontHeight + outlineThickness)
        end
      end
      return self:DrawRarityText(name, 'MWSAS.SelectorDetails', textX, textY, maxWidth, color_white, displayTime, x, y)
    end,
    GetAmmoColor = function(self, ammo, maxAmmo)
      if ammo == math.huge or ammo > 0 and maxAmmo <= 0 then
        return HSVToColor(RealTime() * 120 % 360, 0.75, 1)
      elseif ammo < maxAmmo or maxAmmo <= 0 then
        return HSVToColor(ammo / math.max(maxAmmo, 1) * 120, 0.75, 1)
      else
        local bars = math.max(math.ceil(ammo / maxAmmo), 1)
        return HSVToColor((bars + 3) * 30 % 360, 0.75, 1)
      end
    end,
    DrawAmmoText = function(self, ammoData, x, y)
      local clipData, reserveData
      clipData, reserveData = ammoData[1], ammoData[2]
      local textPieces, textColors = { }, { }
      table.insert(textPieces, string.format('%s / %s', self:FormatNumber(clipData[1]), clipData[2] > 0 and self:FormatNumber(clipData[2]) or '?'))
      table.insert(textColors, self:GetAmmoColor(clipData[1], clipData[2]))
      if reserveData then
        table.insert(textPieces, "   |   ")
        table.insert(textColors, color_white)
        table.insert(textPieces, string.format('%s / %s', self:FormatNumber(reserveData[1]), reserveData[2] > 0 and self:FormatNumber(reserveData[2]) or '?'))
        table.insert(textColors, self:GetAmmoColor(reserveData[1], reserveData[2]))
      end
      surface.SetFont('MWSAS.Clip')
      local textX = x - surface.GetTextSize(table.concat(textPieces))
      for i, textPiece in ipairs(textPieces) do
        textX = textX + self:DrawTextOutlined(textPiece, 'MWSAS.Clip', textX, y, textColors[i])
      end
    end,
    SelectWeapon = function(self, target)
      self.selectedIndex = 0
      self.panel:SetZPos(0)
      for i, _des_0 in ipairs(self.weps) do
        local wep, name
        wep, name = _des_0[1], _des_0[2]
        if wep == target then
          self.selectedIndex = i
          self.panel:SetZPos(1)
        end
      end
    end,
    GetWeaponY = function(self, target)
      for i, _des_0 in ipairs(self.weps) do
        local wep, name
        wep, name = _des_0[1], _des_0[2]
        if wep == target then
          return (i - 0.5) * self.weaponH
        end
      end
    end,
    GetBounds = function(self)
      return self.panel:GetBounds()
    end,
    GetTall = function(self)
      return self.panel:GetTall()
    end,
    SetY = function(self, y)
      return self.panel:SetY(y)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, weaponSelector, x, w, h, weps)
      self.openTime = RealTime()
      self.weaponSelector = weaponSelector
      self.horizontalScroller = weaponSelector:GetHorizontalScroller()
      do
        local _accum_0 = { }
        local _len_0 = 1
        for wep, name in SortedPairsByValue(weps) do
          _accum_0[_len_0] = {
            wep,
            name
          }
          _len_0 = _len_0 + 1
        end
        self.weps = _accum_0
      end
      do
        local _with_0 = vgui.Create('DSizeToContents', self.horizontalScroller)
        _with_0:SetX(x)
        _with_0:SetWide(w)
        _with_0:SetSizeX(false)
        _with_0.OnCursorMoved = self:CreateForwarder(self.horizontalScroller, 'OnCursorMoved')
        _with_0.OnMousePressed = self:CreateForwarder(self.horizontalScroller, 'OnMousePressed')
        self.panel = _with_0
      end
      self.weaponPanels = { }
      self.weaponH = h
      self.selectedIndex = 0
      self.ply = LocalPlayer()
      self.defaultWeaponIconID = surface.GetTextureID('weapons/swep')
      self.defaultWeaponDrawing = weapons.GetStored('weapon_base').DrawWeaponSelection
      local offsetY = 0
      for i, _des_0 in ipairs(self.weps) do
        local wep, name
        wep, name = _des_0[1], _des_0[2]
        local weaponPanel = self:CreateWeaponPanel(i, wep, name)
        weaponPanel:SetY(offsetY)
        table.insert(self.weaponPanels, weaponPanel)
        offsetY = offsetY + h
      end
    end,
    __base = _base_0,
    __name = "WeaponSelectorVerticalScroller",
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
  WeaponSelectorVerticalScroller = _class_0
end
local WeaponSearcher
do
  local _class_0
  local _parent_0 = BasicDrawing
  local _base_0 = {
    colors = {
      normal = Color(0, 0, 0, 239),
      selected = Color(255, 255, 255, 239),
      hovered = Color(127, 127, 127, 239)
    },
    mathEnv = {
      inf = math.huge,
      pi = math.pi,
      e = math.exp(1),
      tau = math.tau,
      abs = math.abs,
      acos = math.acos,
      asin = math.asin,
      atan = math.atan,
      ceil = math.ceil,
      cos = math.cos,
      cosh = math.cosh,
      deg = math.deg,
      exp = math.exp,
      fact = math.Factorial,
      floor = math.floor,
      fmod = math.fmod,
      ln = function(x)
        return math.log(x)
      end,
      log = function(x, b)
        if b then
          return math.log(x, b)
        else
          return math.log10(x)
        end
      end,
      max = math.max,
      min = math.min,
      mod = function(x, b)
        return x % b
      end,
      rad = math.rad,
      random = math.random,
      round = math.Round,
      sin = math.sin,
      sinh = math.sinh,
      tan = math.tan,
      tanh = math.tanh
    },
    Start = function(self)
      self.ply = LocalPlayer()
      self.weaponInfo = nil
      self:RefreshFonts()
      self:CreateWindow()
      if InsaneStats then
        local _list_0 = self.ply:GetWeapons()
        for _index_0 = 1, #_list_0 do
          local wep = _list_0[_index_0]
          if not (wep.insaneStats_Modifiers) then
            wep:InsaneStats_MarkForUpdate()
          end
        end
      end
    end,
    CreateWindow = function(self)
      local barHeight = self:GetFontHeight('bar')
      do
        local _with_0 = vgui.Create('DFrame')
        _with_0:SetSize(ScrW() * self:GetConVarValue('searcher_width') / 100, barHeight + 34)
        _with_0:SetTitle('#mwsas.searcher.title')
        _with_0:Center()
        _with_0:MakePopup()
        _with_0.lblTitle:SetFont('MWSAS.SearcherTitle')
        _with_0.Paint = function(panel, w, h)
          return draw.RoundedBox(4, 0, 0, w, h, self.colors.normal)
        end
        self.panel = _with_0
      end
      local searchBar
      do
        local _with_0 = vgui.Create('DTextEntry', self.panel)
        _with_0:Dock(TOP)
        _with_0:RequestFocus()
        _with_0:SetTabbingDisabled(true)
        _with_0:SetFont('MWSAS.Searcher')
        _with_0:SetTall(barHeight)
        _with_0.GetAutoComplete = function(panel, inputText)
          if not (self.weaponInfo and inputText ~= "") then
            self:FillWeaponInfo()
          end
          return self:GetAutoComplete(inputText)
        end
        _with_0.OpenAutoComplete = function(panel, tab)
          if not (table.IsEmpty(tab)) then
            return self:OpenAutoComplete(panel, tab)
          end
        end
        _with_0.OnKeyCodeTyped = function(panel, code)
          panel:OnKeyCode(code)
          if IsValid(panel.Menu) then
            local _exp_0 = code
            if KEY_ENTER == _exp_0 then
              panel.Menu:GetChild(math.max(1, panel.HistoryPos)):DoClick()
              return panel.Menu:Remove()
            elseif KEY_UP == _exp_0 then
              panel.HistoryPos = panel.HistoryPos - 1
              return panel:UpdateFromHistory()
            elseif KEY_DOWN == _exp_0 or KEY_TAB == _exp_0 then
              panel.HistoryPos = panel.HistoryPos + 1
              return panel:UpdateFromHistory()
            end
          elseif code == KEY_ENTER then
            return self:SelectWeapon()
          end
        end
        _with_0.UpdateFromMenu = function(panel)
          local pos = panel.HistoryPos
          local num = panel.Menu:ChildCount()
          panel.Menu:ClearHighlights()
          if pos < 1 then
            pos = num
          elseif pos > num then
            pos = 1
          end
          local item = panel.Menu:GetChild(pos)
          panel.Menu:HighlightItem(item)
          panel.HistoryPos = pos
        end
        searchBar = _with_0
      end
    end,
    FontRefreshRequired = function(self)
      local titleFont = self:GetConVarValue('searcher_title_font')
      local barFont = self:GetConVarValue('searcher_bar_font')
      local barFontHeight = self:GetFontHeight('bar')
      local detailsFont = self:GetConVarValue('searcher_details_font')
      local detailsFontHeight = self:GetFontHeight('details')
      if self.titleFont ~= titleFont or self.barFont ~= barFont or self.barFontHeight ~= barFontHeight or self.detailsFont ~= detailsFont or self.detailsFontHeight ~= detailsFontHeight then
        self.titleFont = titleFont
        self.barFont = barFont
        self.barFontHeight = barFontHeight
        self.detailsFont = detailsFont
        self.detailsFontHeight = detailsFontHeight
        return true
      else
        return false
      end
    end,
    GetFontHeight = function(self, arg)
      return ScreenScale(self:GetConVarValue("searcher_" .. tostring(arg) .. "_font_size"))
    end,
    RefreshFonts = function(self)
      if self:FontRefreshRequired() then
        surface.CreateFont('MWSAS.SearcherTitle', {
          font = self.titleFont,
          size = 20
        })
        surface.CreateFont('MWSAS.Searcher', {
          font = self.barFont,
          size = self.barFontHeight
        })
        return surface.CreateFont('MWSAS.SearcherDetails', {
          font = self.detailsFont,
          size = self.detailsFontHeight
        })
      end
    end,
    FillWeaponInfo = function(self)
      self.weaponInfo = { }
      local ply = self.ply
      local _list_0 = ply:GetWeapons()
      for _index_0 = 1, #_list_0 do
        local wep = _list_0[_index_0]
        local name = self:GetWeaponName(wep)
        local search = string.lower(string.format('%s %s', wep:GetClass(), name))
        local tier = 1
        local wpass2Name, tier
        if (InsaneStats and InsaneStats:GetConVarValue('wpass2_enabled')) then
          if wep.insaneStats_Modifiers then
            wpass2Name = InsaneStats:GetWPASS2Name(wep) or name
            tier = wep.insaneStats_Tier or 1
            search = string.lower(string.format('%s %s', wep:GetClass(), wpass2Name))
          else
            wep:InsaneStats_MarkForUpdate()
          end
        end
        table.insert(self.weaponInfo, {
          name = name,
          wpass2 = wpass2Name,
          search = search,
          tier = tier,
          wep = wep
        })
      end
      return table.sort(self.weaponInfo, function(a, b)
        if a.tier ~= b.tier then
          return a.tier > b.tier
        else
          return a.name < b.name
        end
      end)
    end,
    GetAutoComplete = function(self, inputText)
      if inputText ~= '' then
        if inputText[1] == '=' then
          local compiled = CompileString('return ' .. string.sub(inputText, 2), 'error', false)
          if isfunction(compiled) then
            setfenv(compiled, self.mathEnv)
            local success, ret = pcall(compiled)
            if success then
              return {
                {
                  name = '=' .. tostring(ret),
                  wpass2 = ''
                }
              }
            else
              return {
                {
                  name = '=?',
                  wpass2 = ret
                }
              }
            end
          else
            return {
              {
                name = '=?',
                wpass2 = compiled
              }
            }
          end
        else
          inputText = string.PatternSafe(string.lower(inputText))
          inputText = string.gsub(inputText, '_', '.')
          local matches = { }
          local _list_0 = self.weaponInfo
          for _index_0 = 1, #_list_0 do
            local weaponInfo = _list_0[_index_0]
            local found = true
            for inputArg in string.gmatch(inputText, '(%S+)') do
              if not (string.find(weaponInfo.search, inputArg)) then
                found = false
                break
              end
            end
            if found then
              table.insert(matches, weaponInfo)
              if #matches >= 10 then
                break
              end
            end
          end
          return matches
        end
      end
    end,
    OpenAutoComplete = function(self, panel, tab)
      panel.Menu = DermaMenu()
      panel.HistoryPos = 1
      local startDrawTime = RealTime()
      local wpass2Enabled = InsaneStats and InsaneStats:GetConVarValue('wpass2_enabled')
      for i, v in ipairs(tab) do
        local opt
        do
          local _with_0 = panel.Menu:AddOption('', function()
            return self:SelectWeapon(v.wep)
          end)
          _with_0:SetFont('MWSAS.Searcher')
          _with_0:SetTextInset(0, 0)
          _with_0.Highlight = i == 1
          _with_0.Paint = function(panel, w, h)
            local outlineThickness = self:GetConVarValue('outline')
            local isWep = IsValid(v.wep)
            local rarityColor = self.colors.selected
            local rarity
            if isWep and wpass2Enabled then
              rarity = InsaneStats:GetWPASS2Rarity(v.wep) or -1
              rarityColor = InsaneStats:GetPhasedRarityColor(rarity)
            end
            local displayTime = RealTime() - startDrawTime
            if panel.Highlight then
              draw.RoundedBox(4, 0, 0, w, h, rarityColor)
            elseif panel.Hovered then
              draw.RoundedBox(4, 0, 0, w, h, self.colors.hovered)
            end
            local x, y = panel:LocalToScreen()
            self:DrawRarityText(v.name, 'MWSAS.Searcher', outlineThickness, outlineThickness, w - outlineThickness * 2, color_white, displayTime, x, y)
            if wpass2Enabled or not isWep then
              return self:DrawRarityText(v.wpass2, 'MWSAS.SearcherDetails', outlineThickness, self:GetFontHeight('bar') + outlineThickness * 2, w - outlineThickness * 2, rarity or rarityColor, displayTime, x, y)
            end
          end
          _with_0.PerformLayout = function(panel, w, h)
            local outlineThickness = self:GetConVarValue('outline')
            local isWep = IsValid(v.wep)
            local ySize
            if wpass2Enabled or not isWep then
              ySize = self:GetFontHeight('bar') + self:GetFontHeight('details') + outlineThickness * 3
            else
              ySize = self:GetFontHeight('bar') + outlineThickness * 2
            end
            panel:SetSize(panel:GetParent():GetWide(), ySize)
            return DButton.PerformLayout(panel, w, h)
          end
          opt = _with_0
        end
      end
      local w, h = panel:GetSize()
      local x, y = panel:LocalToScreen(0, h)
      do
        local _with_0 = panel.Menu
        _with_0:SetMinimumWidth(w)
        _with_0:Open(x, y, true, panel)
        _with_0:SetPos(x, y)
        _with_0:SetMaxHeight(ScrH() - y - 10)
        _with_0.Paint = function(panel, w, h)
          return draw.RoundedBox(4, 0, 0, w, h, self.colors.normal)
        end
        return _with_0
      end
    end,
    SelectWeapon = function(self, wep)
      local ply = self.ply
      self.panel:Close()
      if IsValid(wep) then
        input.SelectWeapon(wep)
        if self:IsDebugLevel(2) then
          self:Log('Switching to %s!', tostring(wep))
        end
        return ply:EmitSound('common/wpn_hudoff.wav', 0, 100, self:GetConVarValue('volume') / 100)
      else
        return ply:EmitSound('common/wpn_denyselect.wav', 0, 100, self:GetConVarValue('volume') / 100)
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      return self:RegisterCVars('searcher', {
        {
          ref = 'searcher_width',
          type = 'float',
          default = '50',
          min = 0,
          max = 100
        },
        {
          ref = 'searcher_title_font',
          type = 'string',
          default = 'Orbitron Medium'
        },
        {
          ref = 'searcher_bar_font',
          type = 'string',
          default = 'Orbitron Medium'
        },
        {
          ref = 'searcher_bar_font_size',
          type = 'float',
          default = '12',
          min = 0,
          max = 1000
        },
        {
          ref = 'searcher_details_font',
          type = 'string',
          default = 'Orbitron Medium'
        },
        {
          ref = 'searcher_details_font_size',
          type = 'float',
          default = '8',
          min = 0,
          max = 1000
        }
      })
    end,
    __base = _base_0,
    __name = "WeaponSearcher",
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
  WeaponSearcher = _class_0
end
BasicDrawing:RegisterCVarsStatic('miscellaneous', {
  {
    ref = 'debug',
    type = 'int',
    default = '0',
    min = 0,
    max = 3
  },
  {
    ref = 'outline',
    type = 'float',
    default = '2',
    min = 0,
    max = 100
  },
  {
    ref = 'outline_colorbleed',
    type = 'float',
    default = '0',
    min = 0,
    max = 100
  },
  {
    ref = 'volume',
    type = 'float',
    default = '25',
    min = 0,
    max = 100
  }
})
local selector = WeaponSelector()
local searcher = WeaponSearcher()
concommand.Add('+mwsas_wepsel', function()
  return selector:Start()
end)
concommand.Add('-mwsas_wepsel', function()
  return selector:End()
end)
concommand.Add('mwsas_wepsearch', function()
  return searcher:Start()
end)
hook.Add('AddToolMenuCategories', 'MWS&S', function()
  spawnmenu.AddToolCategory('Utilities', 'MWS&S', '#mwsas')
end)
return hook.Add('PopulateToolMenu', 'MWS&S', (function()
  local _base_0 = BasicDrawing
  local _fn_0 = _base_0.PopulateToolMenu
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)())
