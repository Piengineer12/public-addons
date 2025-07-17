-- these are the item lines on the first page of the Insane Stats Coin Shop
-- todo: unit price display, qty display, total price display, buy selector button, name display
BaseClass = baseclass.Get 'DPanel'
PANEL = {
    Init: => -- this is the only function that's called automatically on the parent
        color_black_translucent = InsaneStats\GetColor 'black_translucent'
        panelHeight = InsaneStats.FONT_MEDIUM
        outlineWidth = InsaneStats\GetOutlineThickness!

        @SetTall panelHeight * 2 + outlineWidth * 2
        @Dock TOP

        with costDisplay = vgui.Create 'DPanel', @
            \SetTall panelHeight + outlineWidth * 2
            \Paint = (w, h) =>
                -- format: "Unit Price: [], Quantity: [], Total: []"
                parent = @GetParent!
                quantity = parent\GetUnitPrice!
                quantity = parent\GetQuantity!

        with buyButton = vgui.Create 'DButton', @
            \SetFont 'InsaneStats.Medium'
            \SetText 'BUY'
            \SizeToContentsX 4
            \Dock RIGHT
}