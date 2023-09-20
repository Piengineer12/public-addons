InsaneStats:SetDefaultConVarCategory("Coin Drops")

InsaneStats:RegisterClientConVar("hud_coins_enabled", "insanestats_hud_coins_enabled", "1", {
	display = "Coins", desc = "Shows the number of coins collected.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_coins_x", "insanestats_hud_coins_x", "0.01", {
	display = "Coin Display X", desc = "Horizontal position of coin display.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_coins_y", "insanestats_hud_coins_y", "0.02", {
	display = "Coin Display Y", desc = "Vertical position of coin display.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})

local color_red = InsaneStats:GetColor("red")
local color_green = InsaneStats:GetColor("green")

local lastCoinUpdate = 0
local slowCoins = 0
local oldCoins = LocalPlayer():InsaneStats_GetCoins()
local icons = {
	Material("insane_stats/metal-disc.png", "mips smooth"),
	Material("insane_stats/emerald.png", "mips smooth")
}

local function DangerousPaint()
	local ply = LocalPlayer()
	local coins = ply:InsaneStats_GetCoins()
	local lastCoinTier = ply:InsaneStats_GetLastCoinTier()
	local x = 8
	local y = 8

	InsaneStats:DrawMaterialOutlined(
		icons[InsaneStats:GetConVarValue("coins_legacy") and 2 or 1],
		x, y,
		InsaneStats.FONT_BIG, InsaneStats.FONT_BIG,
		InsaneStats:GetCoinColor(lastCoinTier),
		2,
		color_black
	)

	x = x + InsaneStats.FONT_BIG + 2

	local text = string.Comma(math.floor(coins))
	draw.SimpleTextOutlined(text, "InsaneStats.Big", x, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, color_black)

	if slowCoins ~= coins then
		y = y + InsaneStats.FONT_BIG

		local change = coins - slowCoins
		local textColor = change > 0 and color_green or change < 0 and color_red or color_white
		text = string.format(
			"%s%s",
			change < 0 and "" or "+",
			string.Comma(math.floor(change))
		)
		draw.SimpleTextOutlined(text, "InsaneStats.Big", x, y, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, color_black)
	end
end

hook.Add("HUDPaint", "InsaneStatsCoins", function()
	if InsaneStats:GetConVarValue("hud_coins_enabled") then
		local ply = LocalPlayer()
		local coins = ply:InsaneStats_GetCoins()
		local mustShow = ply:KeyDown(IN_WALK)
		local realTime = RealTime()
		if oldCoins ~= coins then
			if oldCoins then
				lastCoinUpdate = realTime
			end
			oldCoins = coins
		elseif mustShow then
			lastCoinUpdate = math.max(lastCoinUpdate, realTime - 3.5)
		end
		local life = 5 + lastCoinUpdate - realTime
		if life < 0 then
			slowCoins = coins
		else
			surface.SetAlphaMultiplier(life)
	
			local popAmt = math.max(1, life - 3.75)
			local scrW = ScrW()
			local scrH = ScrH()
			local x = scrW * InsaneStats:GetConVarValue("hud_coins_x") - 8
			local y = scrH * InsaneStats:GetConVarValue("hud_coins_y") - 8
	
			local m = Matrix()
			m:Translate(Vector(x, y, 0))
			m:Scale(Vector(popAmt, popAmt, popAmt))
			
			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			cam.PushModelMatrix(m, true)

			local ok, err = pcall(DangerousPaint)
	
			cam.PopModelMatrix()
			render.PopFilterMag()
			surface.SetAlphaMultiplier(1)

			if not ok then
				error(err)
			end
		end
	end
end)

local function CreateReforgePanel(parent)
	local ply = LocalPlayer()

	local Panel = vgui.Create("DScrollPanel", parent)
	Panel:Dock(FILL)

	local wpass2Enabled = InsaneStats:GetConVarValue("wpass2_enabled")

	local SelectLabel = vgui.Create("DLabel", Panel)
	SelectLabel:SetWrap(true)
	SelectLabel:SetAutoStretchVertical(true)
	SelectLabel:SetFont("InsaneStats.Medium")
	SelectLabel:SetText(wpass2Enabled and "Select an item to reroll WPASS2 modifiers:" or "This feature requires WPASS2 to be enabled.")
	SelectLabel:Dock(TOP)

	if wpass2Enabled then
		local Selector = vgui.Create("DComboBox", Panel)
		for i,v in ipairs(ply:GetWeapons()) do
			if (v.insaneStats_Tier or 1) > 0 then
				Selector:AddChoice(InsaneStats:GetWeaponName(v), v)
			end
		end
		Selector:SetContentAlignment(5)
		Selector:SetFontInternal("InsaneStats.Medium")
		Selector:AddChoice("#item_battery", ply, true)
		Selector:Dock(TOP)

		local TierLabel = vgui.Create("DLabel", Panel)
		TierLabel:SetWrap(true)
		TierLabel:SetAutoStretchVertical(true)
		TierLabel:SetFont("InsaneStats.Medium")
		TierLabel:Dock(TOP)

		--[[local CostLabel = vgui.Create("DLabel", Panel)
		CostLabel:SetWrap(true)
		CostLabel:SetAutoStretchVertical(true)
		CostLabel:SetFont("InsaneStats.Medium")
		CostLabel:Dock(TOP)]]

		local ReforgeButton = vgui.Create("DButton", Panel)
		ReforgeButton:SetFont("InsaneStats.Medium")
		ReforgeButton:SetText("REFORGE")
		ReforgeButton:Dock(TOP)

		local ModifierLabel = vgui.Create("DLabel", Panel)
		ModifierLabel:SetWrap(true)
		ModifierLabel:SetAutoStretchVertical(true)
		ModifierLabel:SetFont("InsaneStats.Medium")
		ModifierLabel:SetText("\nCurrent Modifiers:")
		ModifierLabel:Dock(TOP)

		local ModifierList = vgui.Create("DListView", Panel)
		ModifierList:SetTall(ScrH()/3)
		ModifierList:Dock(TOP)
		ModifierList:AddColumn("Modifier Name")
		ModifierList:AddColumn("Stacks")
		ModifierList:AddColumn("Max Stacks")
		ModifierList:AddColumn("Relative Weight")

		local modifiers = InsaneStats:GetAllModifiers()
		function Selector:OnSelect(index, key, value)
			local tier = value.insaneStats_Tier or 1
			local text = "\nTier: "..tier..", "
			--TierLabel:SetText("\nTier: "..tier)

			if tier > 0 then
				local cost = InsaneStats:ScaleValueToLevelPure(
					InsaneStats:GetConVarValue("coins_reforge_cost"),
					InsaneStats:GetConVarValue("coins_reforge_cost_add")/100,
					tier,
					true
				)
				--CostLabel:SetText("Reforge Cost: "..InsaneStats:FormatNumber(math.ceil(cost)))
				text = text.."Reforge Cost: "..InsaneStats:FormatNumber(math.ceil(cost))
			else
				--CostLabel:SetText("Cannot be rerolled")
				text = text.."Cannot be rerolled"
			end
			TierLabel:SetText(text)
			
			for i=#ModifierList:GetLines(), 1, -1 do
				ModifierList:RemoveLine(i)
			end
			for k,v in pairs(value.insaneStats_Modifiers or {}) do
				local modifierName = modifiers[k] and (modifiers[k].suffix or modifiers[k].prefix) or k
				local modifierMax = modifiers[k] and modifiers[k].max or "∞"
				local modifierWeight = modifiers[k] and modifiers[k].weight or 1
				ModifierList:AddLine(modifierName, v, modifierMax, modifierWeight * 100)
			end
			ModifierList:SortByColumn(1)
		end
		Selector:OnSelect(0, "#item_battery", ply)
	end

	return Panel
end

local shopItems = {
	{"item_battery", 25},
	{"item_healthvial", 10},
	{"item_healthkit", 25},
	{"item_ammo_357", 10},
	{"item_ammo_ar2", 10},
	{"item_ammo_ar2_altfire", 50},
	{"item_ammo_crossbow", 25},
	{"item_ammo_pistol", 10},
	{"item_ammo_smg1", 10},
	{"item_ammo_smg1_grenade", 50},
	{"item_box_buckshot", 25},
	{"item_rpg_round", 50},
}

local function CreateItemsPanel(parent)
	local ply = LocalPlayer()

	local Panel = vgui.Create("DPanel", parent)
	Panel:Dock(FILL)
	Panel.Paint = nil

	local HeaderPanel = vgui.Create("DPanel", Panel)
	--HeaderPanel:SetTall(InsaneStats.FONT_MEDIUM * 1.5)
	HeaderPanel:Dock(TOP)
	HeaderPanel.Paint = nil

	local Buy10Button = vgui.Create("DButton", HeaderPanel)
	Buy10Button:SetFont("InsaneStats.Medium")
	Buy10Button:SetText("BUY 10")
	Buy10Button:SetWide(InsaneStats.FONT_MEDIUM * 5)
	Buy10Button:Dock(RIGHT)
	Buy10Button:SetEnabled(false)

	local BuyButton = vgui.Create("DButton", HeaderPanel)
	BuyButton:SetFont("InsaneStats.Medium")
	BuyButton:SetText("BUY 1")
	BuyButton:SetWide(InsaneStats.FONT_MEDIUM * 5)
	BuyButton:Dock(RIGHT)
	BuyButton:SetEnabled(false)

	local CostLabel = vgui.Create("DLabel", HeaderPanel)
	CostLabel:SetFont("InsaneStats.Medium")
	CostLabel:SetText("Select an item to view buy cost.")
	CostLabel:Dock(FILL)

	local ScrollPanel = vgui.Create("DScrollPanel", Panel)
	ScrollPanel:Dock(FILL)

	local ItemList = vgui.Create("DIconLayout", ScrollPanel)
	ItemList:Dock(FILL)

	for i,v in ipairs(shopItems) do
		local Item = vgui.Create("ContentIcon", ItemList)
		local name = language.GetPhrase(v[1])
		Item:SetName(name)
		Item:SetMaterial("entities/"..v[1]..".png")
		function Item:DoClick()
			local cost = v[2]
			if InsaneStats:GetConVarValue("xp_enabled") then
				cost = InsaneStats:ScaleValueToLevelQuadratic(
					cost,
					InsaneStats:GetConVarValue("coins_level_add")/100,
					ply:InsaneStats_GetLevel(),
					"coins_level_add_mode",
					false,
					InsaneStats:GetConVarValue("coins_level_add_add")/100
				)
			end
			CostLabel:SetText(name.." Cost: "..InsaneStats:FormatNumber(math.ceil(cost)))
			Buy10Button:SetEnabled(true)
			BuyButton:SetEnabled(true)
		end
	end

	return Panel
end

local function CreateShopMenu()
	local Main = vgui.Create("DFrame")
	Main:SetSize(ScrW()/1.5, ScrH()/1.5)
	Main:SetSizable(true)
	Main:Center()
	Main:MakePopup()

	local CoinDisplay = vgui.Create("DPanel", Main)
	CoinDisplay:SetTall(InsaneStats.FONT_BIG + 8)
	CoinDisplay:Dock(TOP)
	function CoinDisplay:Paint(w, h)
		local ply = LocalPlayer()
		local x = 2
		x = x + draw.SimpleTextOutlined("You have ", "InsaneStats.Big", x, 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, color_black)
		x = x + 2
		
		InsaneStats:DrawMaterialOutlined(
			icons[InsaneStats:GetConVarValue("coins_legacy") and 2 or 1],
			x, 2,
			InsaneStats.FONT_BIG, InsaneStats.FONT_BIG,
			InsaneStats:GetCoinColor(ply:InsaneStats_GetLastCoinTier()),
			2,
			color_black
		)
		x = x + InsaneStats.FONT_BIG + 2

		local text = InsaneStats:FormatNumber(math.floor(ply:InsaneStats_GetCoins()))
		draw.SimpleTextOutlined(text, "InsaneStats.Big", x, 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, color_black)
	end

	local Categories = vgui.Create("DColumnSheet", Main)
	Categories:Dock(FILL)
	Categories:AddSheet("Reforge", CreateReforgePanel(Categories), "icon16/database_gear.png")
	Categories:AddSheet("Items", CreateItemsPanel(Categories), "icon16/bricks.png")
end

concommand.Add("insanestats_coins_shop", CreateShopMenu, nil, "WIP. The shop is currently nonfunctional.")