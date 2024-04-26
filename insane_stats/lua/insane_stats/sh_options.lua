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
			help = "* and ? wildcards are accepted.",
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
					max = 9,
					choices = {
						{"Initialize", InsaneStats.EVENTS.INIT},
						{"Map Disconnect / Background Map", InsaneStats.EVENTS.DISC},
						{"Map Change", InsaneStats.EVENTS.CHANGE},
						{"Map Restart", InsaneStats.EVENTS.RESTART},
						{"Game End", InsaneStats.EVENTS.END},
						{"Entity Created", InsaneStats.EVENTS.CREATE},
						{"Entity Removed", InsaneStats.EVENTS.KILL},
						{"Map Entity Input", InsaneStats.EVENTS.INPUT},
						{"Spherical Player Trigger", InsaneStats.EVENTS.TRIGGER},
						{"Insane Stats Variable Changed (NYI)", InsaneStats.EVENTS.VAR}
					}
				},
				{
					name = "Event Parameters",
					help = "* and ? wildcards are accepted, except for numeric parameters and the operator parameter.\n\z
					Note that the number of text lines that need to be here changes depending on type:\n\z
					Initialize: 0\n\z
					Map Disconnect / Background Map: 0-1 ([target map])\n\z
					Map Change: 0-1 ([target map])\n\z
					Map Restart: 0\n\z
					Game End: 0\n\z
					Entity Created: 0-3 ([targetname], [class], [model])\n\z
					Entity Removed: 0-4 ([targetname], [max left (default: 0)], [class], [model])\n\z
					Map Entity Input: 0-5 ([targetname], [input], [value], [class], [model])\n\z
					Spherical Player Trigger: 3-5 (<x>, <y>, <z>, [radius (default: 128)], [minPercentOfPlayers (default: 1)])\n\z
					Insane Stats Variable Changed (NYI): 0-3 ([name], [operator (< / <= / = / >= / > / !=) (default: =)], [new value (default: 1)])",
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
						max = 20,
						choices = {
							{"Cancel", InsaneStats.ACTIONS.CANCEL},
							{"Restart / Map Change", InsaneStats.ACTIONS.CHANGE},
							{"Chat Text", InsaneStats.ACTIONS.CHAT},
							{"Map Entity Input", InsaneStats.ACTIONS.INPUT},
							{"Apply Status Effect", InsaneStats.ACTIONS.APPLY_STATUS},
							{"Clear Status Effect", InsaneStats.ACTIONS.CLEAR_STATUS},
							{"Remove Weapons", InsaneStats.ACTIONS.NO_WEPS},
							{"Remove Suit", InsaneStats.ACTIONS.NO_SUIT},
							{"Play Sound", InsaneStats.ACTIONS.PLAY},
							{"Show Timer", InsaneStats.ACTIONS.TIMER},
							{"Run Command", InsaneStats.ACTIONS.RUN_COMMAND},
							{"Toggle ConVar", InsaneStats.ACTIONS.TOGGLE_CVAR},
							{"Add ConVar", InsaneStats.ACTIONS.ADD_CVAR},
							{"Multiply ConVar", InsaneStats.ACTIONS.MULT_CVAR},
							{"Set Insane Stats Variable (NYI)", InsaneStats.ACTIONS.SET_SVAR},
							{"Toggle Insane Stats Variable (NYI)", InsaneStats.ACTIONS.TOGGLE_SVAR},
							{"Add Insane Stats Variable (NYI)", InsaneStats.ACTIONS.ADD_SVAR},
							{"Multiply Insane Stats Variable (NYI)", InsaneStats.ACTIONS.MULT_SVAR},
							{"Show Wave Bar (NYI)", InsaneStats.ACTIONS.WAVE},
							{"Mark As Special (NYI)", InsaneStats.ACTIONS.SPECIAL},
							{"Run Lua Code", InsaneStats.ACTIONS.LUA}
						}
					},
					{
						name = "Action Parameters",
						help = "* and ? wildcards can only be used where /* has been noted.\n\z
						Note that the number of text lines that need to be here changes depending on type:\n\z
						Cancel: 0\n\z
						Restart / Map Change: 0-1 ([target map (default: current map)])\n\z
						Chat Text: 1+ (<line1/color1>, [line2/color2], [...] (color: \"&<r> <g> <b> [a (default: 255)]\"))\n\z
						Map Entity Input: 2-5 (<targetname/*>, <input>, [value], [class/*], [model/*])\n\z
						Apply Status Effect: 2-6 (<targetname/*>, <effectname>, [level (default: 1)], [duration (default: 10)], [class/*], [model/*])\n\z
						Clear Status Effect: 0-4 ([targetname/*], [effectname/*], [class/*], [model/*])\n\z
						Remove Weapons: 0\n\z
						Remove Suit: 0\n\z
						Play Sound: 2-7 (<targetname/*>, <sound>, [class/*], [model/*], [soundlevel (default: 75)], [pitch (default: 100)], [volume (default: 1)])\n\z
						Show Timer: 1-2 (<duration>, [color (default: -1)])\n\z
						Run Command: 1+ (<command>, [arg1], [arg2], [...])\n\z
						Toggle ConVar: 1 (<name>)\n\z
						Add ConVar: 2 (<name>, <value>)\n\z
						Multiply ConVar: 2 (<name>, <value>)\n\z
						Set Insane Stats Variable (NYI): 2 (<name>, <value>)\n\z
						Toggle Insane Stats Variable (NYI): 1 (<name>)\n\z
						Add Insane Stats Variable (NYI): 2 (<name>, <value>)\n\z
						Multiply Insane Stats Variable (NYI): 2 (<name>, <value>)\n\z
						Show Wave Bar (NYI): 1+ (<wavecomp1>, [wavecomp2], [...] (wavecomp: \"<targetname/*>;<amount>[;<class/*>[;<model/*>[;<icon>]]]\"))\n\z
						Mark As Special (NYI): 1-4 (<label (possible values: boss, ally)>, [targetname/*], [class/*], [model/*])\n\z
						Run Lua Code: 1+ (<line1>, [line2], [...])",
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
			InsaneStats.LocalMapEvents = nil
		end
	})

	if CLIENT then hook.Run("InsaneStats_CCVCCMRun") end
end)