local BaseClass = baseclass.Get('DPanel')
local PANEL = {
  Init = function(self)
    self:Dock(FILL)
    self.ItemLines = { }
    do
      local _with_0 = vgui.Create('DButton', self)
      _with_0:SetFont('InsaneStats.Big')
      _with_0:SetText('Fill All To Max')
      _with_0:SetTall(InsaneStats.FONT_BIG)
      _with_0:SizeToContentsX(4)
      _with_0:Dock(TOP)
      _with_0:SetZPos(0)
      _with_0:SetDoubleClickingEnabled(false)
      _with_0.DoClick = function()
        local _list_0 = self.ItemLines
        for _index_0 = 1, #_list_0 do
          local itemLine = _list_0[_index_0]
          itemLine:TriggerBuyToMax()
        end
      end
      return _with_0
    end
  end,
  SetAmmoSold = function(self, ammoIDs)
    local _list_0 = self.ItemLines
    for _index_0 = 1, #_list_0 do
      local itemLine = _list_0[_index_0]
      itemLine:Remove()
    end
    self.ItemLines = { }
    local allDetails = self:GetDetailsFromAmmoIDs(ammoIDs)
    for i, details in ipairs(allDetails) do
      table.insert(self.ItemLines, (function()
        do
          local _with_0 = vgui.Create('InsaneStats_ShopItemLine', self)
          _with_0:SetText(details.name)
          _with_0:SetZPos(i)
          _with_0.OnPollDetails = details.poll
          _with_0.OnPurchase = details.purchase
          return _with_0
        end
      end)())
    end
  end,
  GetDetailsFromAmmoIDs = function(self, ammoIDs)
    local allDetails = { }
    local ordered = self:GetOrderFromAmmoIDs(ammoIDs)
    for _index_0 = 1, #ordered do
      local ammoID = ordered[_index_0]
      local details = {
        purchase = function(_, qty)
          net.Start('insane_stats')
          net.WriteUInt(5, 8)
          net.WriteEntity(self:GetShopEntity())
          net.WriteUInt(6, 4)
          net.WriteUInt(ammoID, 9)
          net.WriteDouble(qty)
          return net.SendToServer()
        end
      }
      local _exp_0 = ammoID
      if 257 == _exp_0 then
        details.name = 'Health'
        details.poll = function(_, id)
          local ply = LocalPlayer()
          local coins = ply:InsaneStats_GetCoins()
          local unitPrice = InsaneStats:ScaleValueToLevel(InsaneStats:GetConVarValue('coins_health_cost'), InsaneStats:GetConVarValue('coins_health_cost_add') / 100, ply:InsaneStats_GetLevel(), 'coins_health_cost_mode')
          local overUnitPrice = InsaneStats:GetConVarValue('coins_health_cost_overmul')
          local shopEntity = self:GetShopEntity()
          local freeQty = 0
          if (IsValid(shopEntity) and not hook.Run('InsaneStatsBlockFreebie', ply, shopEntity, ammoID)) then
            freeQty = math.max(0, ply:InsaneStats_GetMaxHealth() - ply:InsaneStats_GetHealth())
          end
          local qty, price
          if id > 4 then
            price = math.max(0, (function()
              local _exp_1 = id
              if 5 == _exp_1 then
                return coins / 100
              elseif 6 == _exp_1 then
                return coins / 10
              elseif 7 == _exp_1 then
                return coins
              end
            end)())
            qty = price / unitPrice + freeQty
          else
            local maxHealth = ply:InsaneStats_GetMaxHealth()
            local currentRatio = ply:InsaneStats_GetHealth() / maxHealth
            local nerfFactor = ply:InsaneStats_GetHealthNerfFactor()
            local dxs
            local _exp_1 = id
            if 1 == _exp_1 then
              dxs = {
                InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 1 - currentRatio, nerfFactor)
              }
            elseif 2 == _exp_1 then
              dxs = {
                InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 1, nerfFactor)
              }
            elseif 3 == _exp_1 then
              dxs = {
                InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 10, nerfFactor)
              }
            elseif 4 == _exp_1 then
              dxs = {
                InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 100, nerfFactor)
              }
            end
            qty = maxHealth * (dxs[1] + dxs[2] * overUnitPrice)
            price = math.max(0, (qty - freeQty) * unitPrice)
          end
          return unitPrice, qty, price
        end
      elseif 258 == _exp_0 then
        details.name = 'Armor'
        details.poll = function(_, id)
          local ply = LocalPlayer()
          local coins = ply:InsaneStats_GetCoins()
          local unitPrice = InsaneStats:ScaleValueToLevel(InsaneStats:GetConVarValue('coins_armor_cost'), InsaneStats:GetConVarValue('coins_armor_cost_add') / 100, ply:InsaneStats_GetLevel(), 'coins_armor_cost_mode')
          local overUnitPrice = InsaneStats:GetConVarValue('coins_armor_cost_overmul')
          local shopEntity = self:GetShopEntity()
          local freeQty = 0
          if (IsValid(shopEntity) and not hook.Run('InsaneStatsBlockFreebie', ply, shopEntity, ammoID)) then
            freeQty = math.max(0, ply:InsaneStats_GetMaxArmor() - ply:InsaneStats_GetArmor())
          end
          local qty, price
          if id > 4 then
            price = math.max(0, (function()
              local _exp_1 = id
              if 5 == _exp_1 then
                return coins / 100
              elseif 6 == _exp_1 then
                return coins / 10
              elseif 7 == _exp_1 then
                return coins
              end
            end)())
            qty = price / unitPrice + freeQty
          else
            local maxArmor = ply:InsaneStats_GetMaxArmor()
            local currentRatio = ply:InsaneStats_GetArmor() / maxArmor
            local nerfFactor = ply:InsaneStats_GetArmorNerfFactor()
            local dxs
            local _exp_1 = id
            if 1 == _exp_1 then
              dxs = {
                InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 1 - currentRatio, nerfFactor)
              }
            elseif 2 == _exp_1 then
              dxs = {
                InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 1, nerfFactor)
              }
            elseif 3 == _exp_1 then
              dxs = {
                InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 10, nerfFactor)
              }
            elseif 4 == _exp_1 then
              dxs = {
                InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 100, nerfFactor)
              }
            end
            qty = maxArmor * (dxs[1] + dxs[2] * overUnitPrice)
            price = math.max(0, (qty - freeQty) * unitPrice)
          end
          return unitPrice, qty, price
        end
      elseif 259 == _exp_0 then
        details.name = 'XP'
        details.poll = function(_, id)
          local ply = LocalPlayer()
          local coins = ply:InsaneStats_GetCoins()
          local level = ply:InsaneStats_GetLevel()
          local unitPrice = InsaneStats:GetConVarValue('coins_xp_cost')
          local qty, price
          if id > 4 then
            price = math.max(0, (function()
              local _exp_1 = id
              if 5 == _exp_1 then
                return coins / 100
              elseif 6 == _exp_1 then
                return coins / 10
              elseif 7 == _exp_1 then
                return coins
              end
            end)())
            qty = price / unitPrice
          else
            local currentXP = ply:InsaneStats_GetXP()
            local rawLevel = InsaneStats:GetLevelByXPRequired(currentXP)
            local newXP
            local _exp_1 = id
            if 1 == _exp_1 then
              newXP = currentXP
            elseif 2 == _exp_1 then
              newXP = InsaneStats:GetXPRequiredToLevel(rawLevel + 1)
            elseif 3 == _exp_1 then
              newXP = InsaneStats:GetXPRequiredToLevel(rawLevel + 10)
            elseif 4 == _exp_1 then
              newXP = InsaneStats:GetXPRequiredToLevel(rawLevel + 100)
            end
            qty = math.max(0, newXP - currentXP)
            price = math.max(0, qty * unitPrice)
          end
          return unitPrice, qty, price
        end
      else
        details.name = "#" .. tostring(game.GetAmmoName(ammoID)) .. "_ammo"
        details.poll = function(_, id)
          local ply = LocalPlayer()
          local coins = ply:InsaneStats_GetCoins()
          local maxAmmo = game.GetAmmoMax(ammoID)
          local unitPrice = InsaneStats:ScaleValueToLevel(InsaneStats:GetConVarValue('coins_ammo_cost') / maxAmmo, InsaneStats:GetConVarValue('coins_ammo_cost_add') / 100, ply:InsaneStats_GetLevel(), 'coins_ammo_cost_mode')
          local shopEntity = self:GetShopEntity()
          local freeQty = 0
          if (IsValid(shopEntity) and not hook.Run('InsaneStatsBlockFreebie', ply, shopEntity, ammoID)) then
            freeQty = math.huge
          end
          local qty, price
          if id > 4 then
            price = math.max(0, (function()
              local _exp_1 = id
              if 5 == _exp_1 then
                return coins / 100
              elseif 6 == _exp_1 then
                return coins / 10
              elseif 7 == _exp_1 then
                return coins
              end
            end)())
            qty = price / unitPrice + freeQty
          else
            local _exp_1 = id
            if 1 == _exp_1 then
              qty = maxAmmo - ply:GetAmmoCount(ammoID)
            elseif 2 == _exp_1 then
              qty = maxAmmo
            elseif 3 == _exp_1 then
              qty = maxAmmo * 10
            elseif 4 == _exp_1 then
              qty = maxAmmo * 100
            end
            price = math.max(0, (qty - freeQty) * unitPrice)
          end
          return unitPrice, qty, price
        end
      end
      table.insert(allDetails, details)
    end
    return allDetails
  end,
  GetOrderFromAmmoIDs = function(self, ammoIDs)
    local offerHealth = false
    local offerArmor = false
    local offerXP = false
    local order = { }
    for _index_0 = 1, #ammoIDs do
      local id = ammoIDs[_index_0]
      local _exp_0 = id
      if 257 == _exp_0 then
        offerHealth = true
      elseif 258 == _exp_0 then
        offerArmor = true
      elseif 259 == _exp_0 then
        offerXP = true
      else
        table.insert(order, id)
      end
    end
    table.sort(order, function(a, b)
      local compA = game.GetAmmoName(a) .. '_ammo'
      local compB = game.GetAmmoName(b) .. '_ammo'
      return language.GetPhrase(compA) < language.GetPhrase(compB)
    end)
    if offerXP then
      table.insert(order, 1, 259)
    end
    if offerArmor then
      table.insert(order, 1, 258)
    end
    if offerHealth then
      table.insert(order, 1, 257)
    end
    return order
  end
}
AccessorFunc(PANEL, 'insaneStats_shopEntity', 'ShopEntity')
return vgui.Register('InsaneStats_ShopItems', PANEL, 'DScrollPanel')
