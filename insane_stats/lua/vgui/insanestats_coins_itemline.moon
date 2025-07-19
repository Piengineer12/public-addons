-- these are the item lines on the first page of the Insane Stats Coin Shop
-- todo: buy selector button, name display

BaseClass = baseclass.Get 'DPanel'
PANEL = {
    Init: => -- this is the only function that's called automatically on the parent
        panelHeight = InsaneStats.FONT_MEDIUM
        outlineWidth = InsaneStats\GetOutlineThickness!

        @SetTall panelHeight * 2 + outlineWidth * 2
        @Dock TOP

        with costDisplay = vgui.Create 'DPanel', @
            \SetTall panelHeight + outlineWidth * 2
            \Dock BOTTOM
            \SetZPos 1
            .Paint = (_, w, h) ->
                -- format: "Unit Price: [], Quantity: [], Total: []"
                unitPrice = @GetUnitPrice!
                quantity = @GetQuantity!
                freeQuantity = @GetFreeQuantity!

                total = unitPrice * quantity
                iconMaterial = InsaneStats\GetIconMaterial InsaneStats\GetConVarValue(
                    'coins_legacy' and 'emerald' or 'metal-disc'
                )

                outlineThickness = InsaneStats\GetOutlineThickness!
                x = outlineThickness
                x += InsaneStats\DrawTextOutlined(
                    'Unit Price: ', 2, x, outlineThickness,
                    color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
                )
                x += outlineThickness
                
                x += InsaneStats\DrawMaterialOutlined(
                    iconMaterial, x, outlineThickness,
                    InsaneStats.FONT_MEDIUM, InsaneStats.FONT_MEDIUM,
                    InsaneStats\GetCoinColor math.floor InsaneStats\GetCoinValueExponent unitPrice
                )
                x += outlineThickness

                text = InsaneStats\FormatNumber unitPrice
                text2 = InsaneStats\FormatNumber quantity + freeQuantity
                x += InsaneStats\DrawTextOutlined(
                    "#{text}, Quantity: #{text2}, Total: ", 2, x, outlineThickness,
                    color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
                )
                x += outlineThickness
                
                x += InsaneStats\DrawMaterialOutlined(
                    iconMaterial, x, outlineThickness,
                    InsaneStats.FONT_MEDIUM, InsaneStats.FONT_MEDIUM,
                    InsaneStats\GetCoinColor math.floor InsaneStats\GetCoinValueExponent total
                )
                x += outlineThickness

                x += InsaneStats\DrawTextOutlined(
                    InsaneStats\FormatNumber(total), 2, x, outlineThickness,
                    color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
                )
                x += outlineThickness

        with buyButton = vgui.Create 'DButton', @
            \SetFont 'InsaneStats.Medium'
            \SetText 'BUY'
            \SizeToContentsX 4
            \Dock RIGHT
            \SetZPos 2
            \SetDoubleClickingEnabled false
            .DoClick = ->
                unitPrice = @GetUnitPrice!
                quantity = @GetQuantity!
                freeQuantity = @GetFreeQuantity!

                total = unitPrice * quantity
                @OnPurchase quantity + freeQuantity, total
        
        with @BuyOptions = vgui.Create 'DComboBox', @
            \SetFont 'InsaneStats.Medium'
            \SetValue '100% of Coins'
            \SizeToContentsX 4
            \Dock RIGHT
            \SetZPos 3
            .OnSelect = (_, index, value, data) -> @OnOptionSelected data

            \AddChoice 'To Max', 0x1, true
            \AddChoice '+1x Max', 0x10
            \AddChoice '+10x Max', 0x11
            \AddChoice '+100x Max', 0x12
            \AddChoice '1% of Coins', 0x20
            \AddChoice '10% of Coins', 0x21
            \AddChoice '100% of Coins', 0x22
    
    -- to override
    OnOptionSelected: (id) =>
    OnPurchase: =>
}

AccessorFunc PANEL, 'insaneStats_UnitPrice', 'UnitPrice', FORCE_NUMBER
AccessorFunc PANEL, 'insaneStats_Quantity', 'Quantity', FORCE_NUMBER
AccessorFunc PANEL, 'insaneStats_FreeQuantity', 'FreeQuantity', FORCE_NUMBER
vgui.Register 'InsaneStats_ShopItemLine', PANEL, 'DPanel'