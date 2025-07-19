local BaseClass = baseclass.Get('DPanel')
local PANEL = {
  Init = function(self)
    local panelHeight = InsaneStats.FONT_MEDIUM
    local outlineWidth = InsaneStats:GetOutlineThickness()
    self:SetTall(panelHeight * 2 + outlineWidth * 2)
    self:Dock(TOP)
    do
      local costDisplay = vgui.Create('DPanel', self)
      costDisplay:SetTall(panelHeight + outlineWidth * 2)
      costDisplay:Dock(BOTTOM)
      costDisplay:SetZPos(1)
      costDisplay.Paint = function(_, w, h)
        local unitPrice = self:GetUnitPrice()
        local quantity = self:GetQuantity()
        local freeQuantity = self:GetFreeQuantity()
        local total = unitPrice * quantity
        local iconMaterial = InsaneStats:GetIconMaterial(InsaneStats:GetConVarValue('coins_legacy' and 'emerald' or 'metal-disc'))
        local outlineThickness = InsaneStats:GetOutlineThickness()
        local x = outlineThickness
        x = x + InsaneStats:DrawTextOutlined('Unit Price: ', 2, x, outlineThickness, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        x = x + outlineThickness
        x = x + InsaneStats:DrawMaterialOutlined(iconMaterial, x, outlineThickness, InsaneStats.FONT_MEDIUM, InsaneStats.FONT_MEDIUM, InsaneStats:GetCoinColor(math.floor(InsaneStats:GetCoinValueExponent(unitPrice))))
        x = x + outlineThickness
        local text = InsaneStats:FormatNumber(unitPrice)
        local text2 = InsaneStats:FormatNumber(quantity + freeQuantity)
        x = x + InsaneStats:DrawTextOutlined(tostring(text) .. ", Quantity: " .. tostring(text2) .. ", Total: ", 2, x, outlineThickness, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        x = x + outlineThickness
        x = x + InsaneStats:DrawMaterialOutlined(iconMaterial, x, outlineThickness, InsaneStats.FONT_MEDIUM, InsaneStats.FONT_MEDIUM, InsaneStats:GetCoinColor(math.floor(InsaneStats:GetCoinValueExponent(total))))
        x = x + outlineThickness
        x = x + InsaneStats:DrawTextOutlined(InsaneStats:FormatNumber(total), 2, x, outlineThickness, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        x = x + outlineThickness
      end
    end
    do
      local buyButton = vgui.Create('DButton', self)
      buyButton:SetFont('InsaneStats.Medium')
      buyButton:SetText('BUY')
      buyButton:SizeToContentsX(4)
      buyButton:Dock(RIGHT)
      buyButton:SetZPos(2)
      buyButton:SetDoubleClickingEnabled(false)
      buyButton.DoClick = function()
        local unitPrice = self:GetUnitPrice()
        local quantity = self:GetQuantity()
        local freeQuantity = self:GetFreeQuantity()
        local total = unitPrice * quantity
        return self:OnPurchase(quantity + freeQuantity, total)
      end
    end
    do
      local _with_0 = vgui.Create('DComboBox', self)
      self.BuyOptions = _with_0
      _with_0:SetFont('InsaneStats.Medium')
      _with_0:SetValue('100% of Coins')
      _with_0:SizeToContentsX(4)
      _with_0:Dock(RIGHT)
      _with_0:SetZPos(3)
      _with_0.OnSelect = function(_, index, value, data)
        return self:OnOptionSelected(data)
      end
      _with_0:AddChoice('To Max', 0x1, true)
      _with_0:AddChoice('+1x Max', 0x10)
      _with_0:AddChoice('+10x Max', 0x11)
      _with_0:AddChoice('+100x Max', 0x12)
      _with_0:AddChoice('1% of Coins', 0x20)
      _with_0:AddChoice('10% of Coins', 0x21)
      _with_0:AddChoice('100% of Coins', 0x22)
      return _with_0
    end
  end,
  OnOptionSelected = function(self, id) end,
  OnPurchase = function(self) end
}
AccessorFunc(PANEL, 'insaneStats_UnitPrice', 'UnitPrice', FORCE_NUMBER)
AccessorFunc(PANEL, 'insaneStats_Quantity', 'Quantity', FORCE_NUMBER)
AccessorFunc(PANEL, 'insaneStats_FreeQuantity', 'FreeQuantity', FORCE_NUMBER)
return vgui.Register('InsaneStats_ShopItemLine', PANEL, 'DPanel')
