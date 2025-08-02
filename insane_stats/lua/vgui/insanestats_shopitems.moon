-- this is the actual item buy page of the Insane Stats Coin Shop

BaseClass = baseclass.Get 'DPanel'
PANEL = {
    Init: => -- this is the only function that's called automatically on the parent too
        @Dock FILL
        @ItemLines = {}
        
        with vgui.Create 'DButton', @
            \SetFont 'InsaneStats.Big'
            \SetText 'Fill All To Max'
            \SizeToContentsY 4
            \Dock TOP
            \DockMargin 0, 0, 0, 4
            \SetZPos 0
            \SetDoubleClickingEnabled false
            .DoClick = -> itemLine\TriggerBuyToMax! for itemLine in *@ItemLines
    
    SetAmmoSold: (ammoIDs) =>
        itemLine\Remove! for itemLine in *@ItemLines
        @ItemLines = {}

        allDetails = @GetDetailsFromAmmoIDs ammoIDs
        for i, details in ipairs allDetails
            table.insert @ItemLines, with vgui.Create 'InsaneStats_ShopItemLine', @
                \SetText details.name
                \SetZPos i
                .OnPollDetails = details.poll
                .OnPurchase = details.purchase
    
    GetDetailsFromAmmoIDs: (ammoIDs) =>
        allDetails = {}
        ordered = @GetOrderFromAmmoIDs ammoIDs
        for ammoID in *ordered
            details = {purchase: (_, qty) ->
                net.Start 'insane_stats'
                net.WriteUInt 5, 8
                net.WriteEntity @GetShopEntity!
                net.WriteUInt 6, 4
                net.WriteUInt ammoID, 9
                net.WriteDouble qty
                net.SendToServer!
            }
            switch ammoID
                when 257
                    details.name = 'Health'
                    details.poll = (_, id) ->
                        ply = LocalPlayer!
                        coins = ply\InsaneStats_GetCoins!
                        unitPrice = InsaneStats\ScaleValueToLevel(
                            InsaneStats\GetConVarValue('coins_health_cost'),
                            InsaneStats\GetConVarValue('coins_health_cost_add')/100,
                            ply\InsaneStats_GetLevel!, 'coins_health_cost_mode'
                        )
                        overUnitPrice = InsaneStats\GetConVarValue 'coins_health_cost_overmul'
                        
                        shopEntity = @GetShopEntity!
                        freeQty = 0
                        if (IsValid(shopEntity) and not hook.Run 'InsaneStatsBlockFreebie', ply, shopEntity, ammoID)
                            freeQty = math.max 0, ply\InsaneStats_GetMaxHealth! - ply\InsaneStats_GetHealth!

                        local qty, price
                        if id > 4
                            price = math.max 0, switch id
                                when 5 then coins / 100
                                when 6 then coins / 10
                                when 7 then coins
                            qty = price / unitPrice + freeQty
                        else
                            maxHealth = ply\InsaneStats_GetMaxHealth!
                            currentRatio = ply\InsaneStats_GetHealth! / maxHealth
                            nerfFactor = ply\InsaneStats_GetHealthNerfFactor!
                            dxs = switch id
                                when 1
                                    {InsaneStats\ComputeDXForNerfedIncrement currentRatio, 1 - currentRatio, nerfFactor}
                                when 2
                                    {InsaneStats\ComputeDXForNerfedIncrement currentRatio, 1, nerfFactor}
                                when 3
                                    {InsaneStats\ComputeDXForNerfedIncrement currentRatio, 10, nerfFactor}
                                when 4
                                    {InsaneStats\ComputeDXForNerfedIncrement currentRatio, 100, nerfFactor}
                            qty = maxHealth * (dxs[1] + dxs[2] * overUnitPrice)
                            price = math.max 0, (qty - freeQty) * unitPrice
                        
                        unitPrice, qty, price
                when 258
                    details.name = 'Armor'
                    details.poll = (_, id) ->
                        ply = LocalPlayer!
                        coins = ply\InsaneStats_GetCoins!
                        unitPrice = InsaneStats\ScaleValueToLevel(
                            InsaneStats\GetConVarValue('coins_armor_cost'),
                            InsaneStats\GetConVarValue('coins_armor_cost_add')/100,
                            ply\InsaneStats_GetLevel!, 'coins_armor_cost_mode'
                        )
                        overUnitPrice = InsaneStats\GetConVarValue 'coins_armor_cost_overmul'
                        
                        shopEntity = @GetShopEntity!
                        freeQty = 0
                        if (IsValid(shopEntity) and not hook.Run 'InsaneStatsBlockFreebie', ply, shopEntity, ammoID)
                            freeQty = math.max 0, ply\InsaneStats_GetMaxArmor! - ply\InsaneStats_GetArmor!

                        local qty, price
                        if id > 4
                            price = math.max 0, switch id
                                when 5 then coins / 100
                                when 6 then coins / 10
                                when 7 then coins
                            qty = price / unitPrice + freeQty
                        else
                            maxArmor = ply\InsaneStats_GetMaxArmor!
                            currentRatio = ply\InsaneStats_GetArmor! / maxArmor
                            nerfFactor = ply\InsaneStats_GetArmorNerfFactor!
                            dxs = switch id
                                when 1
                                    {InsaneStats\ComputeDXForNerfedIncrement currentRatio, 1 - currentRatio, nerfFactor}
                                when 2
                                    {InsaneStats\ComputeDXForNerfedIncrement currentRatio, 1, nerfFactor}
                                when 3
                                    {InsaneStats\ComputeDXForNerfedIncrement currentRatio, 10, nerfFactor}
                                when 4
                                    {InsaneStats\ComputeDXForNerfedIncrement currentRatio, 100, nerfFactor}
                            qty = maxArmor * (dxs[1] + dxs[2] * overUnitPrice)
                            price = math.max 0, (qty - freeQty) * unitPrice
                        
                        unitPrice, qty, price
                when 259
                    details.name = 'XP'
                    details.poll = (_, id) ->
                        ply = LocalPlayer!
                        coins = ply\InsaneStats_GetCoins!
                        level = ply\InsaneStats_GetLevel!
                        unitPrice = InsaneStats\GetConVarValue 'coins_xp_cost'

                        local qty, price
                        if id > 4
                            price = math.max 0, switch id
                                when 5 then coins / 100
                                when 6 then coins / 10
                                when 7 then coins
                            qty = price / unitPrice
                        else
                            currentXP = ply\InsaneStats_GetXP!
                            rawLevel = InsaneStats\GetLevelByXPRequired currentXP
                            newXP = switch id
                                when 1 then currentXP
                                when 2 then InsaneStats\GetXPRequiredToLevel rawLevel + 1
                                when 3 then InsaneStats\GetXPRequiredToLevel rawLevel + 10
                                when 4 then InsaneStats\GetXPRequiredToLevel rawLevel + 100
                            qty = math.max 0, newXP - currentXP
                            price = math.max 0, qty * unitPrice
                        
                        unitPrice, qty, price
                else
                    details.name = "##{game.GetAmmoName ammoID}_ammo"
                    details.poll = (_, id) ->
                        ply = LocalPlayer!
                        coins = ply\InsaneStats_GetCoins!
                        maxAmmo = game.GetAmmoMax ammoID
                        unitPrice = InsaneStats\ScaleValueToLevel(
                            InsaneStats\GetConVarValue('coins_ammo_cost') / maxAmmo,
                            InsaneStats\GetConVarValue('coins_ammo_cost_add')/100,
                            ply\InsaneStats_GetLevel!, 'coins_ammo_cost_mode'
                        )
                        
                        shopEntity = @GetShopEntity!
                        freeQty = 0
                        if (IsValid(shopEntity) and not hook.Run 'InsaneStatsBlockFreebie', ply, shopEntity, ammoID)
                            freeQty = math.huge

                        local qty, price
                        if id > 4
                            price = math.max 0, switch id
                                when 5 then coins / 100
                                when 6 then coins / 10
                                when 7 then coins
                            qty = price / unitPrice + freeQty
                        else
                            qty = switch id
                                when 1 then maxAmmo - ply\GetAmmoCount ammoID
                                when 2 then maxAmmo
                                when 3 then maxAmmo * 10
                                when 4 then maxAmmo * 100
                            price = math.max 0, (qty - freeQty) * unitPrice
                        
                        unitPrice, qty, price
            table.insert allDetails, details
        allDetails
    
    GetOrderFromAmmoIDs: (ammoIDs) =>
        offerHealth = false
        offerArmor = false
        offerXP = false
        order = {}

        for id in *ammoIDs
            switch id
                when 257 then offerHealth = true
                when 258 then offerArmor = true
                when 259 then offerXP = true
                else table.insert order, id
        
        table.sort order, (a, b) ->
            compA = game.GetAmmoName(a)..'_ammo'
            compB = game.GetAmmoName(b)..'_ammo'
            return language.GetPhrase(compA) < language.GetPhrase(compB)
        
        table.insert order, 1, 259 if offerXP
        table.insert order, 1, 258 if offerArmor
        table.insert order, 1, 257 if offerHealth

        order
}

AccessorFunc PANEL, 'insaneStats_shopEntity', 'ShopEntity'
vgui.Register 'InsaneStats_ShopItems', PANEL, 'DScrollPanel'