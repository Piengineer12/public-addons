local BaseClass = baseclass.Get('DPanel')
local PANEL = {
  Init = function(self)
    self:Dock(FILL)
    do
      local _with_0 = vgui.Create('InsaneStats_ShopItemLine', self)
      self.insaneStats_HealthItemLine = _with_0
      _with_0:SetText('Health')
      _with_0.OnPollDetails = function(_, id)
        local ply = LocalPlayer()
        local coins = ply:InsaneStats_GetCoins()
        local unitPrice = InsaneStats:ScaleValueToLevel(InsaneStats:GetConVarValue('coins_health_cost'), InsaneStats:GetConVarValue('coins_health_cost_add') / 100, ply:InsaneStats_GetLevel(), 'coins_health_cost_mode')
        local overUnitPrice = InsaneStats:GetConVarValue('coins_health_cost_overmul')
        local shopEntity = self:GetShopEntity()
        local freeQty = 0
        if (IsValid(shopEntity) and not hook.Run('InsaneStatsBlockFreebie', ply, shopEntity, 257)) then
          freeQty = math.max(0, ply:InsaneStats_GetMaxHealth() - ply:InsaneStats_GetHealth())
        end
        local qty, price
        if id > 4 then
          local fullSpend = coins / unitPrice
          price = math.max(0, (function()
            local _exp_0 = id
            if 5 == _exp_0 then
              return fullSpend / 100
            elseif 6 == _exp_0 then
              return fullSpend / 10
            elseif 7 == _exp_0 then
              return fullSpend
            end
          end)())
          qty = price / unitPrice + freeQty
        else
          local maxHealth = ply:InsaneStats_GetMaxHealth()
          local currentRatio = ply:InsaneStats_GetHealth() / maxHealth
          local nerfFactor = ply:InsaneStats_GetHealthNerfFactor()
          local dxs
          local _exp_0 = id
          if 1 == _exp_0 then
            dxs = {
              InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 1 - currentRatio, nerfFactor)
            }
          elseif 2 == _exp_0 then
            dxs = {
              InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 1, nerfFactor)
            }
          elseif 3 == _exp_0 then
            dxs = {
              InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 10, nerfFactor)
            }
          elseif 4 == _exp_0 then
            dxs = {
              InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 100, nerfFactor)
            }
          end
          qty = maxHealth * (dxs[1] + dxs[2] * overUnitPrice)
          price = math.max(0, (qty - freeQty) * unitPrice)
        end
        return unitPrice, qty, price
      end
      _with_0.OnPurchase = function(_, qty)
        net.Start('insane_stats')
        net.WriteUInt(5, 8)
        net.WriteEntity(self:GetShopEntity())
        net.WriteUInt(6, 4)
        net.WriteUInt(257, 9)
        net.WriteDouble(qty)
        return net.SendToServer()
      end
    end
    do
      local _with_0 = vgui.Create('InsaneStats_ShopItemLine', self)
      self.insaneStats_ArmorItemLine = _with_0
      _with_0:SetText('Shield')
      _with_0.OnPollDetails = function(_, id)
        local ply = LocalPlayer()
        local coins = ply:InsaneStats_GetCoins()
        local unitPrice = InsaneStats:ScaleValueToLevel(InsaneStats:GetConVarValue('coins_armor_cost'), InsaneStats:GetConVarValue('coins_armor_cost_add') / 100, ply:InsaneStats_GetLevel(), 'coins_armor_cost_mode')
        local overUnitPrice = InsaneStats:GetConVarValue('coins_armor_cost_overmul')
        local shopEntity = self:GetShopEntity()
        local freeQty = 0
        if (IsValid(shopEntity) and not hook.Run('InsaneStatsBlockFreebie', ply, shopEntity, 258)) then
          freeQty = math.max(0, ply:InsaneStats_GetMaxArmor() - ply:InsaneStats_GetArmor())
        end
        local qty, price
        if id > 4 then
          local fullSpend = coins / unitPrice
          price = math.max(0, (function()
            local _exp_0 = id
            if 5 == _exp_0 then
              return fullSpend / 100
            elseif 6 == _exp_0 then
              return fullSpend / 10
            elseif 7 == _exp_0 then
              return fullSpend
            end
          end)())
          qty = price / unitPrice + freeQty
        else
          local maxArmor = ply:InsaneStats_GetMaxArmor()
          local currentRatio = ply:InsaneStats_GetArmor() / maxArmor
          local nerfFactor = ply:InsaneStats_GetArmorNerfFactor()
          local dxs
          local _exp_0 = id
          if 1 == _exp_0 then
            dxs = {
              InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 1 - currentRatio, nerfFactor)
            }
          elseif 2 == _exp_0 then
            dxs = {
              InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 1, nerfFactor)
            }
          elseif 3 == _exp_0 then
            dxs = {
              InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 10, nerfFactor)
            }
          elseif 4 == _exp_0 then
            dxs = {
              InsaneStats:ComputeDXForNerfedIncrement(currentRatio, 100, nerfFactor)
            }
          end
          qty = maxArmor * (dxs[1] + dxs[2] * overUnitPrice)
          price = math.max(0, (qty - freeQty) * unitPrice)
        end
        return unitPrice, qty, price
      end
      _with_0.OnPurchase = function(_, qty)
        net.Start('insane_stats')
        net.WriteUInt(5, 8)
        net.WriteEntity(self:GetShopEntity())
        net.WriteUInt(6, 4)
        net.WriteUInt(258, 9)
        net.WriteDouble(qty)
        return net.SendToServer()
      end
      return _with_0
    end
  end,
  SetAmmoSold = function(self, ammoIDs)
    local allDetails = self:GetDetailsFromAmmoIDs(ammoIDs)
    self:Clear()
    for _index_0 = 1, #allDetails do
      local details = allDetails[_index_0]
      do
        local _with_0 = vgui.Create('InsaneStats_ShopItemLine', self)
        _with_0:SetText(details.name)
        _with_0.OnPollDetails = details.poll
        _with_0.OnPurchase = details.purchase
      end
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
            local fullSpend = coins / unitPrice
            price = math.max(0, (function()
              local _exp_1 = id
              if 5 == _exp_1 then
                return fullSpend / 100
              elseif 6 == _exp_1 then
                return fullSpend / 10
              elseif 7 == _exp_1 then
                return fullSpend
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
            local fullSpend = coins / unitPrice
            price = math.max(0, (function()
              local _exp_1 = id
              if 5 == _exp_1 then
                return fullSpend / 100
              elseif 6 == _exp_1 then
                return fullSpend / 10
              elseif 7 == _exp_1 then
                return fullSpend
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
    local order = { }
    for _index_0 = 1, #ammoIDs do
      local id = ammoIDs[_index_0]
      local _exp_0 = id
      if 257 == _exp_0 then
        offerHealth = true
      elseif 258 == _exp_0 then
        offerArmor = true
      else
        table.insert(order, id)
      end
    end
    table.sort(order, function(a, b)
      local compA = game.GetAmmoName(a) .. '_ammo'
      local compB = game.GetAmmoName(b) .. '_ammo'
      return language.GetPhrase(compA) < language.GetPhrase(compB)
    end)
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
