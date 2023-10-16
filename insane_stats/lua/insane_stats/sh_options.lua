-- CCVCCM compat.

hook.Add("CCVCCMRun", "InsaneStatsOptionsShared", function()
	-- allow editing InsaneStats.ShopItems
	CCVCCM:SetAddon("Insane Stats")
	CCVCCM:PushCategory("Server", nil, true)
	CCVCCM:PushCategory("Coin Drops - Shops")
	-- ^ even though this is a mistake, DO NOT CHANGE
	-- as old save files still use this name
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

	CCVCCM:NextCategory("Point Commander")
	CCVCCM:AddAddonVar("custom_events", {
		realm = "server",
		name = "Custom Events",
		help = "Allows other events to happen when a map event happens.",
		default = table.Copy(InsaneStats.PointCommandCustomEvents),
		typeInfo = {
			{
				name = "Map Name",
				type = "string"
			},
			{
				name = "Map Events",
				{
					name = "Event Type",
					type = "number",
					min = 0,
					max = 3,
					choices = {
						{"Initialize", 0},
						{"Disconnect / Background Map", 1},
						{"Map Change", 2},
						{"Game End", 3},
						{"All Enemies Killed", 4},
						{"Map Entity Input", 5},
						{"Spherical Player Trigger", 6}
					}
				},
				{
					name = "Event Parameters",
					help = "* and ? wildcards are accepted. Note that the number of text lines that need to be here changes depending on type:\n\z
					Initialize: 0\n\z
					Disconnect / Background Map: 0-1, [target map]\n\z
					Map Change: 0-1, [target map]\n\z
					Map Entity Input: 2-3, <name> <input> [value]\n\z
					Spherical Player Trigger: 4, <x> <y> <z> <radius>",
					{
						name = "Event Parameters",
						type = "string"
					}
				},
				{
					name = "Actions",
					{
						name = "Action Type",
						type = "number",
						min = 0,
						max = 11,
						choices = {
							{"Cancel", 0},
							{"Cancel + Map Change", 1},
							{"Map Entity Input", 2},
							{"Apply Status Effect", 3},
							{"Clear Status Effect", 4},
							{"Toggle ConVar", 5},
							{"Add ConVar", 6},
							{"Multiply ConVar", 7},
							{"Remove Weapons", 8},
							{"Remove Suit", 9},
							{"Play Sound", 10},
							{"Run Command", 11},
							{"Run Lua Code", 12}
						}
					},
					{
						name = "Action Parameters",
						help = "Note that the number of text lines that need to be here changes depending on type:\n\z
						Cancel: 0\n\z
						Cancel + Map Change: 0-1, [target map]\n\z
						Map Entity Input: 2-3, <name> <input> [value]\n\z
						Apply Status Effect: 1-3, <name> [level] [duration]\n\z
						Clear Status Effect: 1, <name>\n\z
						Toggle ConVar: 1, <name>\n\z
						Add ConVar: 2, <name> <value>\n\z
						Multiply ConVar: 2, <name> <value>\n\z
						Remove Weapons: 0\n\z
						Remove Suit: 0\n\z
						Play Sound: 1, <name>\n\z
						Run Command: 1+, <command> [arg1] [arg2] [...]\n\z
						Run Lua Code: 1, <code>",
						{
							name = "Action Parameters",
							type = "string"
						}
					},
					{
						name = "Delay",
						type = "number",
						min = 0,
						max = 600
					},
					{
						name = "Max Times To Fire (-1 = infinite)",
						type = "number",
						min = -1,
						max = 1000,
						interval = 1
					}
				}
			}
		},
		func = function(arg, fullName)
			InsaneStats.PointCommandCustomEvents = arg
		end
	})

	if CLIENT then hook.Run("InsaneStats_CCVCCMRun") end
end)