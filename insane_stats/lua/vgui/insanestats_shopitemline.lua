local BaseClass = baseclass.Get('DPanel')
local PANEL = {
  Init = function(self)
    local panelHeight = InsaneStats.FONT_BIG
    local font = 'InsaneStats.Big'
    local fontSizeNum = 3
    local outlineWidth = InsaneStats:GetOutlineThickness()
    self:SetTall(panelHeight * 2 + outlineWidth * 2 + 8)
    self:DockPadding(4, 4, 4, 4)
    self:DockMargin(0, 0, 0, 4)
    self:Dock(TOP)
    self:SetBulkOption(1)
    do
      local _with_0 = vgui.Create('DPanel', self)
      _with_0:SetTall(panelHeight + outlineWidth * 2)
      _with_0:Dock(BOTTOM)
      _with_0:SetZPos(1)
      _with_0.Paint = function(_, w, h)
        local unitPrice, qty, total = self:GetDetails()
        local outlineThickness = InsaneStats:GetOutlineThickness()
        local iconMaterial = InsaneStats:GetIconMaterial(InsaneStats:GetConVarValue('coins_legacy') and 'emerald' or 'metal-disc')
        local x = outlineThickness
        x = x + InsaneStats:DrawTextOutlined('Base Unit Price: ', fontSizeNum, x, outlineThickness, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        x = x + outlineThickness
        x = x + InsaneStats:DrawMaterialOutlined(iconMaterial, x, outlineThickness, panelHeight, panelHeight, InsaneStats:GetCoinColor(math.floor(InsaneStats:GetCoinValueExponent(unitPrice))))
        x = x + outlineThickness
        local text = InsaneStats:FormatNumber(unitPrice)
        x = x + InsaneStats:DrawTextOutlined(tostring(text) .. ", Total Price: ", fontSizeNum, x, outlineThickness, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        x = x + outlineThickness
        x = x + InsaneStats:DrawMaterialOutlined(iconMaterial, x, outlineThickness, panelHeight, panelHeight, InsaneStats:GetCoinColor(math.floor(InsaneStats:GetCoinValueExponent(total))))
        x = x + outlineThickness
        text = total == 0 and qty > 0 and 'Free!' or InsaneStats:FormatNumber(total)
        x = x + InsaneStats:DrawTextOutlined(text, fontSizeNum, x, outlineThickness, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        x = x + outlineThickness
      end
    end
    do
      local _with_0 = vgui.Create('DButton', self)
      self.insaneStats_BuyButton = _with_0
      _with_0:SetFont(font)
      _with_0:SetText('BUY')
      _with_0:SizeToContentsX(4)
      _with_0:Dock(RIGHT)
      _with_0:SetZPos(2)
      _with_0:SetDoubleClickingEnabled(false)
      _with_0.DoClick = function()
        local coins = self:GetCurrentCoins()
        local unitPrice, quantity, price = self:GetDetails()
        if coins >= price and quantity > 0 then
          self:OnPurchase(quantity)
          return surface.PlaySound('buttons/button6.wav')
        end
      end
    end
    do
      local _with_0 = vgui.Create('DComboBox', self)
      self.insaneStats_BuyOptions = _with_0
      _with_0:SetFont(font)
      _with_0:SetValue('100% of Coins')
      _with_0:SizeToContentsX(4)
      _with_0:Dock(RIGHT)
      _with_0:SetZPos(3)
      _with_0:SetSortItems(false)
      _with_0:AddChoice('To Max', 1, true)
      _with_0:AddChoice('+1x Max', 2)
      _with_0:AddChoice('+10x Max', 3)
      _with_0:AddChoice('+100x Max', 4)
      _with_0:AddSpacer()
      _with_0:AddChoice('1% of Coins', 5)
      _with_0:AddChoice('10% of Coins', 6)
      _with_0:AddChoice('100% of Coins', 7)
      _with_0.OnSelect = function(_, index, text, data)
        return self:SetBulkOption(data)
      end
    end
    do
      local _with_0 = vgui.Create('DLabel', self)
      self.insaneStats_Label = _with_0
      _with_0:SetFont(font)
      _with_0:SetText('')
      _with_0:Dock(FILL)
      return _with_0
    end
  end,
  Paint = function(self, w, h)
    if not (self.insaneStats_panelColor) then
      self.insaneStats_panelColor = InsaneStats:GetColor('black_translucent')
    end
    return draw.RoundedBox(4, 0, 0, w, h, self.insaneStats_panelColor)
  end,
  GetDetails = function(self)
    return self:OnPollDetails(self:GetBulkOption())
  end,
  GetCurrentCoins = function(self)
    return LocalPlayer():InsaneStats_GetCoins()
  end,
  SetText = function(self, ...)
    return self.insaneStats_Label:SetText(...)
  end,
  TriggerBuyToMax = function(self)
    local oldBulkOption = self:GetBulkOption()
    self:SetBulkOption(1)
    self.insaneStats_BuyButton:DoClick()
    return self:SetBulkOption(oldBulkOption)
  end,
  OnPollQuantity = function(self, id)
    return 0
  end,
  OnPurchase = function(self, quantity, paid) end
}
AccessorFunc(PANEL, 'insaneStats_bulkOption', 'BulkOption', FORCE_NUMBER)
return vgui.Register('InsaneStats_ShopItemLine', PANEL, 'DPanel')
