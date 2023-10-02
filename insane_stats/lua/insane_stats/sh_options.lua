-- CCVCCM compat.

hook.Add("CCVCCMRun", "InsaneStatsOptionsShared", function()
    -- allow editing InsaneStats.ShopItems
	CCVCCM:SetAddon("Insane Stats")
    CCVCCM:PushCategory("Server", nil, true)
    CCVCCM:PushCategory("Coin Drops - Shops")
    CCVCCM:AddAddonVar("items", {
        realm = "shared",
        name = "Item Costs",
        help = "Specifies the items sold by Insane Stats Coin Shops. \z
        Items in this list must have their prices manually specified.",
        default = table.Copy(InsaneStats.ShopItems),
        typeInfo = {
            help = "You must specify both the class name and cost of each item. Note that you are able to rearrange the order of items.",
            {
                name = "Class Name (e.g. item_healthkit)",
                type = "string"
            },
            {
                name = "Cost",
                type = "number",
                min = 1,
                max = 1e6,
                interval = 1,
                logarithmic = true
            }
        },
        func = function(arg, fullName)
            InsaneStats.ShopItems = arg
        end
    })

    local defaultValues = {}
    for i,v in ipairs(InsaneStats.ShopItemsAutomaticPrice) do
        table.insert(defaultValues, {v})
    end
    CCVCCM:AddAddonVar("weapons", {
        realm = "shared",
        name = "Possible Weapons",
        help = "Specifies the weapons sold by Insane Stats Coin Shops. \z
        Items in this list will have their prices calculated based on the insanestats_coins_weapon_price_* ConVars.",
        default = defaultValues,
        typeInfo = {
            help = "Note that prices are assigned top (cheapest) to bottom (most expensive). The order of items can be rearranged.",
            {
                name = "Class Name (e.g. item_healthkit)",
                type = "string"
            }
        },
        func = function(arg, fullName)
            local flattened = {}
            for i,v in ipairs(arg) do
                table.insert(flattened, v[1])
            end
            InsaneStats.ShopItemsAutomaticPrice = flattened
        end
    })
end)