-- these are the item lines on the first page of the Insane Stats Coin Shop
-- todo: function to set buy options

BaseClass = baseclass.Get 'DPanel'
PANEL = {
    Init: => -- this is the only function that's called automatically on the parent too
        panelHeight = InsaneStats.FONT_BIG
        font = 'InsaneStats.Big'
        fontSizeNum = 3
        outlineWidth = InsaneStats\GetOutlineThickness!

        @SetTall panelHeight * 2 + outlineWidth * 2
        @Dock TOP

        with vgui.Create 'DPanel', @
            \SetTall panelHeight + outlineWidth * 2
            \Dock BOTTOM
            \SetZPos 1
            .Paint = (_, w, h) ->
                -- format: "Unit Price: [], Total: []"
                unitPrice, qty, total = @GetDetails!
                outlineThickness = InsaneStats\GetOutlineThickness!
                iconMaterial = InsaneStats\GetIconMaterial InsaneStats\GetConVarValue('coins_legacy') and
                    'emerald' or 'metal-disc'

                x = outlineThickness
                x += InsaneStats\DrawTextOutlined(
                    'Base Unit Price: ', fontSizeNum, x, outlineThickness,
                    color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
                )
                x += outlineThickness
                
                x += InsaneStats\DrawMaterialOutlined(
                    iconMaterial, x, outlineThickness,
                    panelHeight, panelHeight,
                    InsaneStats\GetCoinColor math.floor InsaneStats\GetCoinValueExponent unitPrice
                )
                x += outlineThickness

                text = InsaneStats\FormatNumber unitPrice
                x += InsaneStats\DrawTextOutlined(
                    "#{text}, Total Price: ", fontSizeNum, x, outlineThickness,
                    color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
                )
                x += outlineThickness
                
                x += InsaneStats\DrawMaterialOutlined(
                    iconMaterial, x, outlineThickness,
                    panelHeight, panelHeight,
                    InsaneStats\GetCoinColor math.floor InsaneStats\GetCoinValueExponent total
                )
                x += outlineThickness

                text = total == 0 and qty > 0 and 'Free!' or InsaneStats\FormatNumber total
                x += InsaneStats\DrawTextOutlined(
                    text, fontSizeNum, x, outlineThickness,
                    color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
                )
                x += outlineThickness

        with @insaneStats_BuyButton = vgui.Create 'DButton', @
            \SetFont font
            \SetText 'BUY'
            \SizeToContentsX 4
            \Dock RIGHT
            \SetZPos 2
            \SetDoubleClickingEnabled false
            .DoClick = ->
                coins = @GetCurrentCoins!
                unitPrice, quantity, price = @GetDetails!

                if coins >= price and quantity > 0
                    @OnPurchase quantity
                    surface.PlaySound 'buttons/button6.wav'
        
        with @insaneStats_BuyOptions = vgui.Create 'DComboBox', @
            \SetFont font
            \SetValue '100% of Coins'
            \SizeToContentsX 4
            \Dock RIGHT
            \SetZPos 3
            \SetSortItems false

            \AddChoice 'To Max', 1, true
            \AddChoice '+1x Max', 2
            \AddChoice '+10x Max', 3
            \AddChoice '+100x Max', 4
            \AddSpacer!
            \AddChoice '1% of Coins', 5
            \AddChoice '10% of Coins', 6
            \AddChoice '100% of Coins', 7
        
        with @insaneStats_Label = vgui.Create 'DLabel', @
            \SetFont font
            \SetText ''
            \Dock FILL
            \SetDark true
    
    GetDetails: => @OnPollDetails select 2, @insaneStats_BuyOptions\GetSelected!
    GetCurrentCoins: => LocalPlayer!\InsaneStats_GetCoins!
    SetText: (...) => @insaneStats_Label\SetText ...
    
    -- to override
    OnPollQuantity: (id) => 0
    OnPurchase: (quantity, paid) =>
}

vgui.Register 'InsaneStats_ShopItemLine', PANEL, 'DPanel'