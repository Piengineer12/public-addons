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
InsaneStats:RegisterClientConVar("hud_coins_simplified", "insanestats_hud_coins_simplified", "0", {
	display = "Compact Coin Counter", desc = "Makes the coin counter use a simplified display like in Insane Stats Coin Shops.",
	type = InsaneStats.BOOL
})

local color_black_translucent = InsaneStats:GetColor("black_translucent")
local color_red = InsaneStats:GetColor("red")
local color_green = InsaneStats:GetColor("green")

local lastCoinUpdate = 0
local slowCoins = 0
local oldCoins = LocalPlayer():InsaneStats_GetCoins()

local function DangerousPaint()
	local ply = LocalPlayer()
	local coins = ply:InsaneStats_GetCoins()
	local lastCoinTier = ply:InsaneStats_GetLastCoinTier()
	local x = 8
	local y = 8
	local outlineThickness = InsaneStats:GetOutlineThickness()

	InsaneStats:DrawMaterialOutlined(
		InsaneStats:GetIconMaterial(
			InsaneStats:GetConVarValue("coins_legacy") and "emerald" or "metal-disc"
		),
		x, y,
		InsaneStats.FONT_BIG, InsaneStats.FONT_BIG,
		InsaneStats:GetCoinColor(lastCoinTier)
	)

	x = x + InsaneStats.FONT_BIG + outlineThickness

	local text = math.floor(coins)
	if InsaneStats:GetConVarValue("hud_coins_simplified") then
		text = InsaneStats:FormatNumber(text)
	else
		text = string.Comma(text)
	end
	InsaneStats:DrawTextOutlined(text, 3, x, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	if slowCoins ~= coins then
		y = y + InsaneStats.FONT_BIG

		local change = coins - slowCoins
		local textColor = change > 0 and color_green or change < 0 and color_red or color_white

		text = math.floor(change)
		if InsaneStats:GetConVarValue("hud_coins_simplified") then
			text = InsaneStats:FormatNumber(text, {plus = true})
		else
			text = (change < 0 and "" or "+")..string.Comma(text)
		end
		InsaneStats:DrawTextOutlined(text, 3, x, y, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
end

hook.Add("HUDPaint", "InsaneStatsCoins", function()
	if InsaneStats:GetConVarValue("hud_coins_enabled")
	and InsaneStats:GetConVarValue("coins_enabled")
	and InsaneStats:ShouldDrawHUD() then
		local ply = LocalPlayer()
		if ply:IsSuitEquipped() then
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
	end
end)

local function CreateWeaponryPanel(parent, shopEntity, weaponsSold)
	local ply = LocalPlayer()
	local selectedWeapon

	local Panel = vgui.Create("DPanel", parent)
	Panel:Dock(FILL)
	Panel.Paint = nil

	local HeaderLabel = vgui.Create("DLabel", Panel)
	HeaderLabel:SetFont("InsaneStats.Medium")
	HeaderLabel:SetText("Select an item:")
	HeaderLabel:Dock(TOP)

	local Divider = vgui.Create("DHorizontalDivider", Panel)
	Divider:SetDividerWidth(4)
	Divider:SetLeftWidth(InsaneStats.FONT_MEDIUM * 24)
	Divider:Dock(FILL)

	local WeaponList = vgui.Create("DListView", Divider)
	WeaponList:AddColumn("ID")
	WeaponList:AddColumn("Display Name")
	WeaponList:AddColumn("Internal Name")
	WeaponList:AddColumn("Cost")
	for i,v in ipairs(weaponsSold) do
		local weaponClass = InsaneStats.ShopItemsAutomaticPrice[v]
		if weaponClass then
			local weaponTable = weapons.Get(weaponClass) or {}
			local weaponName = language.GetPhrase(weaponTable.PrintName ~= "" and weaponTable.PrintName or weaponClass)
			WeaponList:AddLine(
				v,
				weaponName,
				weaponClass,
				InsaneStats:FormatNumber(
					math.ceil(
						InsaneStats:GetWeaponCost(v)
					)
				)
			)
		end
	end
	Divider:SetLeft(WeaponList)

	local RightPanel = vgui.Create("DPanel", Divider)
	RightPanel.Paint = nil
	Divider:SetRight(RightPanel)

	local WeaponImage = vgui.Create("DImage", RightPanel)
	--WeaponImage:SetImageColor(Color(255, 255, 255, 15))
	WeaponImage:Dock(FILL)
	WeaponImage:SetKeepAspect(true)

	local WeaponText = vgui.Create("RichText", RightPanel)
	WeaponText:Dock(FILL)
	function WeaponText:PerformLayout()
		self:SetFontInternal("InsaneStats.Medium")
	end

	local WeaponBuy = vgui.Create("DButton", RightPanel)
	WeaponBuy:SetFont("InsaneStats.Medium")
	WeaponBuy:SetText("BUY")
	WeaponBuy:Dock(BOTTOM)
	WeaponBuy:SetEnabled(false)
	function WeaponBuy:DoClick()
		if ply:InsaneStats_GetCoins() >= InsaneStats:GetWeaponCost(selectedWeaponIndex) then
			net.Start("insane_stats")
			net.WriteUInt(5, 8)
			net.WriteEntity(shopEntity)
			net.WriteUInt(1, 4)
			net.WriteUInt(selectedWeaponIndex, 16)
			net.SendToServer()
		end
	end

	function WeaponList:OnRowSelected(rowIndex, row)
		local class = row:GetValue(3)
		local weaponInfo = weapons.GetStored(class) or {}
		local main = "entities/"..class..".png"
		if not file.Exists("materials/"..main, "GAME") then
			main = "vgui/entities/"..class
		end
		local fallback = "weapons/swep"
		if tonumber(weaponInfo.WepSelectIcon) then
			fallback = surface.GetTextureNameByID(weaponInfo.WepSelectIcon)
		end
		WeaponImage:SetImage(main, fallback)

		WeaponText:SetBGColor(Color(0, 0, 0, 239))
		WeaponText:SetText("")
		WeaponText:InsertColorChange(255, 255, 0, 255)
		WeaponText:AppendText("Name: "..row:GetValue(2).."\n")
		local category = weaponInfo.Category or "Other"
		if category ~= "" then
			WeaponText:InsertColorChange(0, 255, 0, 255)
			WeaponText:AppendText("Category: "..category.."\n")
		end
		local author = weaponInfo.Author or ""
		if author ~= "" then
			WeaponText:InsertColorChange(0, 255, 255, 255)
			WeaponText:AppendText("Author(s): "..author.."\n")
		end
		local contact = weaponInfo.Contact or ""
		if contact ~= "" then
			WeaponText:InsertColorChange(0, 127, 255, 255)
			WeaponText:AppendText("Support: "..contact.."\n\n")
		elseif category or author then
			WeaponText:AppendText("\n")
		end
		local purpose = weaponInfo.Purpose or ""
		if purpose ~= "" then
			WeaponText:InsertColorChange(255, 255, 255, 255)
			WeaponText:AppendText(purpose.."\n\n")
		end
		local instructions = weaponInfo.Instructions or ""
		if instructions ~= "" then
			WeaponText:InsertColorChange(255, 255, 0, 255)
			WeaponText:AppendText(instructions)
		end

		selectedWeaponIndex = row:GetValue(1)
		WeaponBuy:SetEnabled(true)
	end

	return Panel
end

local function CreateReforgePanel(parent, shopEntity)
	local ply = LocalPlayer()

	local Panel = vgui.Create("DScrollPanel", parent)
	Panel:Dock(FILL)
	Panel.Paint = nil

	local wpass2Enabled = InsaneStats:GetConVarValue("wpass2_enabled")

	local SelectLabel = vgui.Create("DLabel", Panel)
	SelectLabel:SetWrap(true)
	SelectLabel:SetAutoStretchVertical(true)
	SelectLabel:SetFont("InsaneStats.Medium")
	SelectLabel:SetText(wpass2Enabled and "Select an item to reroll WPASS2 modifiers:" or "This feature requires WPASS2 to be enabled.")
	SelectLabel:Dock(TOP)

	if wpass2Enabled then
		local selectedEntity, currentModifiers
		local Selector = vgui.Create("DComboBox", Panel)
		Selector:SetContentAlignment(5)
		Selector:SetFont("InsaneStats.Medium")
		Selector:SizeToContentsY(4)
		Selector:Dock(TOP)
		Selector:AddChoice("#item_battery", ply)
		for i,v in ipairs(ply:GetWeapons()) do
			if (v.insaneStats_Tier or 0) ~= 0 then
				Selector:AddChoice(InsaneStats:GetWeaponName(v), v)
			end
		end
		Selector:SetText("SELECT AN ITEM")

		local TierLabel = vgui.Create("DLabel", Panel)
		TierLabel:SetWrap(true)
		TierLabel:SetAutoStretchVertical(true)
		TierLabel:SetFont("InsaneStats.Medium")
		TierLabel:SetText("\nSelect an item to view reforge cost.")
		TierLabel:Dock(TOP)

		local ReforgeButton = vgui.Create("DButton", Panel)
		ReforgeButton:SetFont("InsaneStats.Medium")
		ReforgeButton:SetText("REFORGE")
		ReforgeButton:SizeToContentsY(4)
		ReforgeButton:Dock(TOP)
		ReforgeButton:SetEnabled(false)
		function ReforgeButton:DoClick()
			if ply:InsaneStats_GetCoins() >= InsaneStats:GetReforgeCost(
				selectedEntity,
				ply:InsaneStats_GetReforgeBlacklist()
			) then
				net.Start("insane_stats")
				net.WriteUInt(5, 8)
				net.WriteEntity(shopEntity)
				net.WriteUInt(3, 4)
				net.WriteEntity(selectedEntity)
				net.SendToServer()
				surface.PlaySound(string.format("physics/metal/metal_canister_impact_hard%u.wav", math.random(3)))
			end
		end

		local ModifierLabel = vgui.Create("DLabel", Panel)
		ModifierLabel:SetWrap(true)
		ModifierLabel:SetAutoStretchVertical(true)
		ModifierLabel:SetFont("InsaneStats.Medium")
		ModifierLabel:SetText("\nCurrent Modifiers:")
		ModifierLabel:Dock(TOP)

		local ModifierList = vgui.Create("DListView", Panel)
		--ModifierList:SetTall(ScrH()/3)
		ModifierList:SetTall(InsaneStats.FONT_MEDIUM * 10)
		ModifierList:Dock(TOP)
		local column = ModifierList:AddColumn("Modifier Name")
		-- column.Header:SetFont("InsaneStats.Medium")
		-- column.Header:SizeToContentsY(4)
		column = ModifierList:AddColumn("Internal Name")
		column = ModifierList:AddColumn("Curse?")
		column = ModifierList:AddColumn("Stacks")
		-- column.Header:SetFont("InsaneStats.Medium")
		-- column.Header:SizeToContentsY(4)
		column = ModifierList:AddColumn("Max Stacks")
		-- column.Header:SetFont("InsaneStats.Medium")
		-- column.Header:SizeToContentsY(4)
		column = ModifierList:AddColumn("Relative Weight")
		-- column.Header:SetFont("InsaneStats.Medium")
		-- column.Header:SizeToContentsY(4)

		local modifiers = InsaneStats:GetAllModifiers()
		function Selector:OnSelect(index, key, value)
			local tier = value.insaneStats_Tier or 0
			local text = "\nTier: "..tier..", "
			--TierLabel:SetText("\nTier: "..tier)

			if tier ~= 0 then
				local oldSystemCost = InsaneStats:ScaleValueToLevelPure(
					InsaneStats:GetConVarValue("coins_reforge_cost"),
					InsaneStats:GetConVarValue("coins_reforge_cost_add")/100,
					math.abs(tier),
					true
				)
				
				local cost = InsaneStats:GetReforgeCost(value, ply:InsaneStats_GetReforgeBlacklist())
				--CostLabel:SetText("Reforge Cost: "..InsaneStats:FormatNumber(math.ceil(cost)))
				text = text.."Reforge Cost: "..InsaneStats:FormatNumber(math.ceil(cost))
				if oldSystemCost ~= cost then
					local value = (cost / oldSystemCost - 1) * 100
					text = string.format(
						"%s (%s%% from blacklisted modifiers)",
						text,
						InsaneStats:FormatNumber(math.ceil(value), {plus = true})
					)
				end
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
				local modifierMax = modifiers[k] and modifiers[k].max
				and InsaneStats:FormatNumber(math.floor(modifiers[k].max)) or "∞"
				local modifierWeight = modifiers[k] and modifiers[k].weight or 1
				local modifierCost = modifiers[k] and modifiers[k].cost or 1
				local modifierIsWep = modifiers[k] and bit.band(modifiers[k].flags or 0, InsaneStats.WPASS2_FLAGS.ARMOR) == 0
				if modifierCost < 0 then
					modifierWeight = modifierWeight * InsaneStats:GetConVarValueDefaulted(
						not modifierIsWep and "wpass2_modifiers_negativeweight_battery",
						"wpass2_modifiers_negativeweight"
					)
				end
				ModifierList:AddLine(modifierName, k, modifierCost < 0 and "✓" or "", v, modifierMax, modifierWeight)
			end
			selectedEntity = value
			ReforgeButton:SetEnabled(true)
			ModifierList:SortByColumn(1)
		end

		function Selector:Think()
			self:CheckConVarChanges()
			local newModifiers = selectedEntity and selectedEntity.insaneStats_Modifiers
			if newModifiers ~= currentModifiers then
				currentModifiers = newModifiers
				local text, ent = self:GetSelected()
				self:OnSelect(0, text, ent)
			end
		end

		local AttributesLabel = vgui.Create("DLabel", Panel)
		AttributesLabel:SetWrap(true)
		AttributesLabel:SetAutoStretchVertical(true)
		AttributesLabel:SetFont("InsaneStats.Medium")
		AttributesLabel:SetText("Attributes of Selected Modifiers:\nNo modifiers selected.")
		AttributesLabel:Dock(TOP)

		function ModifierList:OnRowSelected(rowIndex, rowPanel)
			local modifiers = {}
			for i,v in ipairs(self:GetSelected()) do
				local modifier, tier = v:GetValue(2), v:GetValue(4)
				modifiers[modifier] = tier
			end
			local attributes = InsaneStats:DetermineWPASS2Attributes(modifiers)

			local displayText = "Attributes of Selected Modifiers:"
			for i,v in ipairs(InsaneStats:GetAttributeOrder(attributes)) do
				local attributeText = InsaneStats:GetAttributeText(v, attributes[v])
				displayText = displayText..'\n'..attributeText
			end

			AttributesLabel:SetText(displayText)
		end

		local BlacklistTitle = vgui.Create("DLabel", Panel)
		BlacklistTitle:SetWrap(true)
		BlacklistTitle:SetAutoStretchVertical(true)
		BlacklistTitle:SetFont("InsaneStats.Big")
		BlacklistTitle:SetText("\nReforge Modifier Blacklist")
		BlacklistTitle:Dock(TOP)

		local BlacklistLabel = vgui.Create("DLabel", Panel)
		BlacklistLabel:SetWrap(true)
		BlacklistLabel:SetAutoStretchVertical(true)
		BlacklistLabel:SetFont("InsaneStats.Medium")
		BlacklistLabel:SetText("Modifiers can be blacklisted by double-clicking on the modifiers above. \z
		Modifiers can be removed from the blacklist by doing the same on the modifiers below.\
		Blacklisted modifiers will never appear on a reforged item, \z
		but each blacklisted modifier will increase the reforge cost!")
		BlacklistLabel:Dock(TOP)

		local BlacklistModifierList = vgui.Create("DListView", Panel)
		BlacklistModifierList:SetTall(InsaneStats.FONT_MEDIUM * 10)
		BlacklistModifierList:Dock(TOP)
		BlacklistModifierList:AddColumn("Modifier Name")
		BlacklistModifierList:AddColumn("Internal Name")
		BlacklistModifierList:AddColumn("Curse?")
		BlacklistModifierList:AddColumn("Max Stacks")
		BlacklistModifierList:AddColumn("Relative Weight")
		function BlacklistModifierList:AddModifierLine(modifier)
			local modifierName = modifiers[modifier] and (modifiers[modifier].suffix or modifiers[modifier].prefix) or modifier
			local modifierMax = modifiers[modifier] and modifiers[modifier].max
			and InsaneStats:FormatNumber(math.floor(modifiers[modifier].max)) or "∞"
			local modifierWeight = modifiers[modifier] and modifiers[modifier].weight or 1
			local modifierCost = modifiers[modifier] and modifiers[modifier].cost or 1
			local modifierIsWep = modifiers[modifier] and bit.band(modifiers[modifier].flags or 0, InsaneStats.WPASS2_FLAGS.ARMOR) == 0
			if modifierCost < 0 then
				modifierWeight = modifierWeight * InsaneStats:GetConVarValueDefaulted(
					not modifierIsWep and "wpass2_modifiers_negativeweight_battery",
					"wpass2_modifiers_negativeweight"
				)
			end
			self:AddLine(modifierName, modifier, modifierCost < 0 and "✓" or "", modifierMax, modifierWeight)
			self:SortByColumn(1)
		end

		for k,v in pairs(ply:InsaneStats_GetReforgeBlacklist()) do
			BlacklistModifierList:AddModifierLine(k)
		end

		function ModifierList:DoDoubleClick(rowIndex, rowPanel)
			local modifierBlacklist = ply:InsaneStats_GetReforgeBlacklist()
			local modifier = rowPanel:GetValue(2)
			if not modifierBlacklist[modifier] then
				BlacklistModifierList:AddModifierLine(modifier)
	
				local modifierBlacklist = ply:InsaneStats_GetReforgeBlacklist()
				modifierBlacklist[modifier] = true
				ply:InsaneStats_SetReforgeBlacklist(modifierBlacklist)
	
				local text, ent = Selector:GetSelected()
				Selector:OnSelect(0, text, ent)
	
				net.Start("insane_stats")
				net.WriteUInt(5, 8)
				net.WriteEntity(shopEntity)
				net.WriteUInt(5, 4)
				net.WriteUInt(table.Count(modifierBlacklist), 16)
				for k, v in pairs(modifierBlacklist) do
					net.WriteString(k)
				end
				net.SendToServer()
			end
		end

		function BlacklistModifierList:DoDoubleClick(rowIndex, rowPanel)
			local modifier = rowPanel:GetValue(2)
			self:RemoveLine(rowIndex)

			local modifierBlacklist = ply:InsaneStats_GetReforgeBlacklist()
			modifierBlacklist[modifier] = nil
			ply:InsaneStats_SetReforgeBlacklist(modifierBlacklist)

			local text, ent = Selector:GetSelected()
			Selector:OnSelect(0, text, ent)

			net.Start("insane_stats")
			net.WriteUInt(5, 8)
			net.WriteEntity(shopEntity)
			net.WriteUInt(5, 4)
			net.WriteUInt(table.Count(modifierBlacklist), 16)
			for k, v in pairs(modifierBlacklist) do
				net.WriteString(k)
			end
			net.SendToServer()
		end
	end

	return Panel
end

local function CreateItemsPanel(parent, shopEntity)
	local ply = LocalPlayer()
	local currentItem

	local Panel = vgui.Create("DPanel", parent)
	Panel:Dock(FILL)
	Panel.Paint = nil

	local HeaderPanel = vgui.Create("DPanel", Panel)
	HeaderPanel:SetTall(InsaneStats.FONT_MEDIUM + 4)
	HeaderPanel:Dock(TOP)
	HeaderPanel.Paint = nil

	local BuyButton = vgui.Create("DButton", HeaderPanel)
	BuyButton:SetFont("InsaneStats.Medium")
	BuyButton:SetText("BUY")
	BuyButton:SetWide(InsaneStats.FONT_MEDIUM * 5)
	BuyButton:Dock(RIGHT)
	BuyButton:SetEnabled(false)
	function BuyButton:DoClick()
		net.Start("insane_stats")
		net.WriteUInt(5, 8)
		net.WriteEntity(shopEntity)
		net.WriteUInt(2, 4)
		net.WriteUInt(currentItem, 16)
		net.SendToServer()
	end

	local CostLabel = vgui.Create("DLabel", HeaderPanel)
	CostLabel:SetFont("InsaneStats.Medium")
	CostLabel:SetText("Select an item to view buy cost.")
	CostLabel:Dock(FILL)

	local ScrollPanel = vgui.Create("DScrollPanel", Panel)
	ScrollPanel:Dock(FILL)

	local ItemList = vgui.Create("DIconLayout", ScrollPanel)
	ItemList:SetSpaceX(8)
	ItemList:SetSpaceY(8)
	ItemList:Dock(FILL)

	for i,v in ipairs(InsaneStats.ShopItems) do
		local class = v[1]
		local Item = vgui.Create("DImageButton", ItemList)
		Item:SetSize(InsaneStats.FONT_SMALL * 12, InsaneStats.FONT_SMALL * 12)
		Item:SetImage("entities/"..class..".png", "vgui/entities/"..class)

		local costStr = InsaneStats:FormatNumber(math.ceil(InsaneStats:GetItemCost(i, ply)))
		local name = language.GetPhrase(class)
		local itemImage = Item.m_Image
		function itemImage:PaintOver(w, h)
			surface.SetDrawColor(0, 0, 0)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawOutlinedRect(1, 1, w-2, h-2, 1)
			local borderSize = 2

			if not Item:IsHovered() then
				local boxPadding = 2
				local boxHeight = InsaneStats.FONT_SMALL + boxPadding * 2
				local y = h - borderSize - boxHeight
				draw.RoundedBox(4, borderSize, y, w - borderSize * 2, boxHeight, color_black_translucent)
				y = y + boxPadding
				draw.SimpleText(name, "InsaneStats.Small", w/2, y, color_white, TEXT_ALIGN_CENTER)
			end
		end
		
		function Item:DoClick()
			costStr = InsaneStats:FormatNumber(math.ceil(InsaneStats:GetItemCost(i, ply)))
			CostLabel:SetText(name.." Cost: "..costStr)
			currentItem = i
			BuyButton:SetEnabled(true)
		end

		Item.DoDoubleClick = Item.DoClick
	end

	return Panel
end

local function CreateRespecPanel(parent, shopEntity)
	local ply = LocalPlayer()

	local Panel = vgui.Create("DScrollPanel", parent)
	Panel:Dock(FILL)
	Panel.Paint = nil

	local SkillsLabel = vgui.Create("DLabel", Panel)
	SkillsLabel:SetWrap(true)
	SkillsLabel:SetAutoStretchVertical(true)
	SkillsLabel:SetFont("InsaneStats.Big")
	SkillsLabel:SetText("Skills Respec")
	SkillsLabel:Dock(TOP)

	local skillsEnabled = InsaneStats:GetConVarValue("skills_enabled")
	and bit.band(InsaneStats:GetConVarValue("skills_allow_reset"), 2) ~= 0

	local RespecLabel = vgui.Create("DLabel", Panel)
	RespecLabel:SetWrap(true)
	RespecLabel:SetAutoStretchVertical(true)
	RespecLabel:SetFont("InsaneStats.Medium")
	RespecLabel:Dock(TOP)

	local currentText = ""
	local oldThink = RespecLabel.Think
	function RespecLabel:Think()
		local cost = InsaneStats:GetRespecCost(ply)
		if skillsEnabled then
			currentText = "Respec Cost: "..InsaneStats:FormatNumber(math.ceil(cost))
		elseif InsaneStats:GetConVarValue("skills_enabled") then
			currentText = "Skill respec via Insane Stats Coin Shops is disabled."
		else
			currentText = "This feature requires Skills to be enabled."
		end

		if self:GetText() ~= currentText then
			self:SetText(currentText)
		end

		oldThink(self)
	end

	if skillsEnabled then
		local RespecButton = vgui.Create("DButton", Panel)
		RespecButton:SetFont("InsaneStats.Medium")
		RespecButton:SetText("RESPEC")
		RespecButton:Dock(TOP)
		function RespecButton:DoClick()
			if ply:InsaneStats_GetCoins() >= InsaneStats:GetRespecCost(ply) then
				net.Start("insane_stats")
				net.WriteUInt(5, 8)
				net.WriteEntity(shopEntity)
				net.WriteUInt(4, 4)
				net.SendToServer()
			end
		end
	end

	return Panel
end

function InsaneStats:CreateShopMenu(shopEntity, weaponsSold, modifierBlacklist)
	LocalPlayer():InsaneStats_SetReforgeBlacklist(modifierBlacklist)

	local Main = vgui.Create("DFrame")
	Main:SetSize(ScrW()/1.5, ScrH()/1.5)
	Main:SetSizable(true)
	Main:Center()
	Main:MakePopup()
	Main:SetTitle("Insane Stats Coin Shop")
	Main.lblTitle:SetFont("InsaneStats.Medium")
	function Main:Paint(w, h)
		draw.RoundedBox(4, 0, 0, w, h, color_black_translucent)
	end

	local CoinDisplay = vgui.Create("DPanel", Main)
	CoinDisplay:SetTall(InsaneStats.FONT_BIG + 8)
	CoinDisplay:Dock(TOP)
	function CoinDisplay:Paint(w, h)
		local ply = LocalPlayer()
		local outlineThickness = InsaneStats:GetOutlineThickness()
		local x = outlineThickness
		x = x + InsaneStats:DrawTextOutlined(
			"You have ", 3, x, outlineThickness,
			color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
		)
		x = x + outlineThickness
		
		InsaneStats:DrawMaterialOutlined(
			InsaneStats:GetIconMaterial(
				InsaneStats:GetConVarValue("coins_legacy") and "emerald" or "metal-disc"
			),
			x, outlineThickness,
			InsaneStats.FONT_BIG, InsaneStats.FONT_BIG,
			InsaneStats:GetCoinColor(ply:InsaneStats_GetLastCoinTier())
		)
		x = x + InsaneStats.FONT_BIG + outlineThickness

		local text = InsaneStats:FormatNumber(math.floor(ply:InsaneStats_GetCoins()))
		InsaneStats:DrawTextOutlined(
			text, 3, x, outlineThickness,
			color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
		)
	end

	local Categories = vgui.Create("DColumnSheet", Main)
	Categories:Dock(FILL)
	Categories:AddSheet("Weapons", CreateWeaponryPanel(Categories, shopEntity, weaponsSold), "icon16/gun.png")
	Categories:AddSheet("Items", CreateItemsPanel(Categories, shopEntity), "icon16/bricks.png")
	Categories:AddSheet("Reforging", CreateReforgePanel(Categories, shopEntity), "icon16/wand.png")
	Categories:AddSheet("Others", CreateRespecPanel(Categories, shopEntity), "icon16/database_gear.png")
end