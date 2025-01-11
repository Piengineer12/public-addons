InsaneStats:SetDefaultConVarCategory("Weapon Selector")

InsaneStats:RegisterClientConVar("hud_wepsel_volume", "insanestats_hud_wepsel_volume", "25", {
	display = "Volume",
	desc = "Volume of sounds produced by the weapon selector.",
	type = InsaneStats.FLOAT, min = 1, max = 100
})
InsaneStats:RegisterClientConVar("hud_wepsel_nobounce", "insanestats_hud_wepsel_nobounce", "0", {
	display = "No Bouncing", desc = "Stops weapon icons from bouncing.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_wepsel_tint", "insanestats_hud_wepsel_tint", "2", {
	display = "Tint", desc = "Causes all non-scripted weapons to be tinted based on rarity. \z
	If 2, scripted weapons with the default icon will also be tinted. \z
	If 3, as many scripted weapon icons as possible will be tinted.",
	type = InsaneStats.INT, min = 0, max = 3
})
InsaneStats:RegisterClientConVar("hud_wepsel_alphabetic", "insanestats_hud_wepsel_alphabetic", "0", {
	display = "Alphabetic", desc = "If above 0, weapon hotbar slots are ignored entirely, \z
	instead the first letter of the weapon name is used to group weapons into columns, \z
	with higher values of this ConVar causing more letters to be grouped into the same column.\n\z
	This option probably won't work well with non-alphabetic languages.",
	type = InsaneStats.INT, min = 0, max = 255
})
InsaneStats:RegisterClientConVar("hud_wepsel_sensitivity_x", "insanestats_hud_wepsel_sensitivity_x", "1.5", {
	display = "Horiz. Sensitivity",
	desc = "Makes the weapon selector more receptive to horizontal mouse movement.",
	type = InsaneStats.FLOAT, min = 1, max = 10
})
InsaneStats:RegisterClientConVar("hud_wepsel_sensitivity_y", "insanestats_hud_wepsel_sensitivity_y", "1.5", {
	display = "Vert. Sensitivity",
	desc = "Makes the weapon selector more receptive to vertical mouse movement.",
	type = InsaneStats.FLOAT, min = 1, max = 10
})
InsaneStats:RegisterClientConVar("hud_wepsel_wep_w", "insanestats_hud_wepsel_wep_w", "256", {
	display = "Weapon Width",
	desc = "Width of weapon icons in the weapon selector, in pixels. Changing this value is not recommended.",
	type = InsaneStats.FLOAT, min = 1, max = 10000
})
InsaneStats:RegisterClientConVar("hud_wepsel_wep_h", "insanestats_hud_wepsel_wep_h", "128", {
	display = "Weapon Height",
	desc = "Height of weapon icons in the weapon selector, in pixels. Changing this value is not recommended.",
	type = InsaneStats.FLOAT, min = 1, max = 10000
})
InsaneStats:RegisterClientConVar("hud_wepsel_wep_color", "insanestats_hud_wepsel_wep_color", "255 255 255 255", {
	display = "Default Color",
	desc = "Default color of non-scripted weapons in the weapon selector. \z
	AutoIcons weapon colors is approximately 255 237 13 255.",
	type = InsaneStats.STRING
})

local weaponSelectorChars = {
	weapon_smg1 = 'a',
	weapon_shotgun = 'b',
	weapon_shotgun_hl1 = 'b',
	weapon_crowbar = 'c',
	weapon_crowbar_hl1 = 'c',
	weapon_pistol = 'd',
	weapon_357 = 'e',
	weapon_357_hl1 = 'e',
	weapon_crossbow = 'g',
	weapon_physgun = 'h',
	weapon_rpg = 'i',
	weapon_rpg_hl1 = 'i',
	weapon_bugbait = 'j',
	weapon_frag = 'k',
	weapon_ar2 = 'l',
	weapon_physcannon = 'm',
	weapon_stunstick = 'n',
	weapon_slam = 'o',

	--[[weapon_satchel = 'T',
	weapon_mp5_hl1 = 'a',
	weapon_glock_hl1 = 'd',
	weapon_crossbow_hl1 = 'g',
	weapon_gauss = 'h',
	weapon_snark = 'j',
	weapon_handgrenade = 'k',
	weapon_hornetgun = 'm',
	weapon_egon = 'n',
	weapon_tripmine = 'o',]]
}
local color_black_translucent = InsaneStats:GetColor("black_translucent")
local color_gray = InsaneStats:GetColor("gray")
local color_gray_translucent = InsaneStats:GetColor("gray_translucent")
local gapSize = 2
if IsValid(InsaneStats.WeaponSelectorWindow) then InsaneStats.WeaponSelectorWindow:Close() end

local function CreateForwarder(objFrom, objTo, funcName)
	objFrom[funcName] = function(_, ...)
		return objTo[funcName](objTo, ...)
	end
end

local function DrawScrollingText(text, time, x, y, w, color, size)
	surface.SetFont(size == 3 and "InsaneStats.Big" or "InsaneStats.Medium")
	local nameExtraW = surface.GetTextSize(text) - w
	local nameScrollFactor = 1
	if nameExtraW > 0 then
		nameScrollFactor = (math.cos(time/2)+1)/2
	end
	local nameScrollAmt = Lerp(nameScrollFactor, nameExtraW, 0)

	InsaneStats:DrawTextOutlined(text, size or 2, x - nameScrollAmt, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

local function CreateWeaponButton(main, parent, wep, name, isSelected)
	local weaponW = main.insaneStats_WeaponW
	local weaponH = main.insaneStats_WeaponH
	local WeaponButton = vgui.Create("DButton", parent)
	WeaponButton:SetText("")
	WeaponButton:SetSize(weaponW, weaponH)
	WeaponButton.insaneStats_Selected = isSelected
	WeaponButton.insaneStats_Weapon = wep

	function WeaponButton:Paint(w, h)
		if IsValid(wep) then
			local outlineThickness = InsaneStats:GetOutlineThickness()
			local tintMode = InsaneStats:GetConVarValue("hud_wepsel_tint")
			draw.RoundedBox(
				8, gapSize, gapSize, w-gapSize*2, h-gapSize*2,
				self.insaneStats_Selected and color_gray_translucent or color_black_translucent
			)
			local hasModifiers = InsaneStats:GetConVarValue("wpass2_enabled") and wep.insaneStats_Modifiers
			local tier = hasModifiers and InsaneStats:GetWPASS2Rarity(wep) or 0
			local rarityColor = InsaneStats:GetPhasedRarityColor(tier)
			
			if wep.DrawWeaponSelection then
				local x, y = self:LocalToScreen()
				main:DrawScriptedWeaponSelection(self.insaneStats_Selected, wep, rarityColor, x, y, w, h)
			elseif not wep:IsScripted() then
				local class = wep:GetClass():lower()
				local char = weaponSelectorChars[class] or 'V'
				local weaponColor = tintMode > 0 and hasModifiers
				and InsaneStats:GetPhasedRarityColor(InsaneStats:GetWPASS2Rarity(wep))
				or string.ToColor(InsaneStats:GetConVarValue("hud_wepsel_wep_color"))
				draw.SimpleText(
					char, "InsaneStats.WeaponIcons", w/2, h/2, weaponColor,
					TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
				)
				draw.SimpleText(
					char, "InsaneStats.WeaponIconsBackground", w/2, h/2, weaponColor,
					TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
				)
			end

			local ply = LocalPlayer()
			if (IsValid(ply) and ply:IsSuitEquipped()) then
				local ammoMaxOverride = GetConVar("gmod_maxammo"):GetInt()
				ammoMaxOverride = ammoMaxOverride > 0 and ammoMaxOverride
				local customAmmoDisplay = wep.CustomAmmoDisplay and wep:CustomAmmoDisplay()
				if not (customAmmoDisplay and customAmmoDisplay.Draw) then
					customAmmoDisplay = {}
				end
				local textY = outlineThickness

				-- primary bar
				local ammoType1 = wep:GetPrimaryAmmoType()
				local useAmmoType1 = ammoType1 > -1
				local reserve1 = tonumber(customAmmoDisplay.PrimaryAmmo or useAmmoType1 and ply:GetAmmoCount(ammoType1)) or -1
				local maxClip1 = tonumber(wep:GetMaxClip1()) or -1
				local clip1 = tonumber(customAmmoDisplay.PrimaryClip or wep:Clip1()) or -1
				local maxReserve1 = tonumber(ammoMaxOverride or useAmmoType1 and game.GetAmmoMax(ammoType1)) or -1
				local ammoUnits = {}
				if maxClip1 > -1 or clip1 > -1 then
					table.insert(ammoUnits, {clip1, maxClip1})
				end
				if reserve1 > -1 then
					table.insert(ammoUnits, {reserve1, maxReserve1})
				end
				if next(ammoUnits) then
					local clipData = ammoUnits[1]
					local barColor = InsaneStats:GetAmmoColor(clipData[1], clipData[2])

					InsaneStats:DrawAmmoText(ammoUnits, w - outlineThickness, textY, TEXT_ALIGN_TOP, barColor)

					textY = textY + InsaneStats.FONT_MEDIUM
				end
			
				-- secondary bar
				local ammoType2 = wep:GetSecondaryAmmoType()
				local useAmmoType2 = ammoType2 > -1
				local reserve2 = tonumber(customAmmoDisplay.SecondaryAmmo or useAmmoType2 and ply:GetAmmoCount(ammoType2)) or -1
				local maxClip2 = tonumber(wep:GetMaxClip2()) or -1
				local clip2 = tonumber(customAmmoDisplay.SecondaryClip or wep:Clip2()) or -1
				local maxReserve2 = tonumber(ammoMaxOverride or useAmmoType2 and game.GetAmmoMax(ammoType2)) or -1
				ammoUnits = {}
				if maxClip2 > -1 or clip2 > -1 then
					table.insert(ammoUnits, {clip2, maxClip2})
				end
				if reserve2 > -1 then
					table.insert(ammoUnits, {reserve2, maxReserve2})
				end
				if next(ammoUnits) then
					local clipData = ammoUnits[1]
					local barColor = InsaneStats:GetAmmoColor(clipData[1], clipData[2])

					InsaneStats:DrawAmmoText(ammoUnits, w - outlineThickness, textY, TEXT_ALIGN_TOP, barColor)
				end
			end

			-- other info

			local weaponDetails = {}
			local textX = gapSize+outlineThickness
			local textY = h-gapSize-InsaneStats.FONT_MEDIUM-outlineThickness*2
			local maxWidth = w-gapSize*2-outlineThickness*2
			local displayTime = RealTime() - main.insaneStats_OpenTime

			if InsaneStats:GetConVarValue("wpass2_enabled") then
				if wep.insaneStats_Modifiers then
					table.insert(weaponDetails, "Tier "..wep.insaneStats_Tier)
				else
					wep:InsaneStats_MarkForUpdate()
				end
			end
			if InsaneStats:GetConVarValue("xp_enabled") then
				table.insert(weaponDetails, "Level "..InsaneStats:FormatNumber(wep:InsaneStats_GetLevel()))
			end
			
			local panelPosX, panelPosY = self:LocalToScreen()

			if next(weaponDetails) then
				InsaneStats:DrawRarityText(
					table.concat(weaponDetails, ", "), 2,
					textX, textY, maxWidth,
					color_white, displayTime, panelPosX, panelPosY
				)

				textY = textY - InsaneStats.FONT_MEDIUM - outlineThickness
			end

			if hasModifiers then
				InsaneStats:DrawRarityText(
					InsaneStats:GetWPASS2Name(wep), 2,
					textX, textY, maxWidth,
					tier, displayTime, panelPosX, panelPosY
				)

				textY = textY - InsaneStats.FONT_MEDIUM - outlineThickness
			end

			InsaneStats:DrawRarityText(
				name, 2,
				textX, textY, maxWidth,
				color_white, displayTime, panelPosX, panelPosY
			)
		else
			main:Refresh()
		end
	end
	function WeaponButton:OnCursorMoved()
		main:OnWeaponSelected(wep)
		main:UpdateWeaponPositions()
	end
	function WeaponButton:OnWeaponSelected()
		self.insaneStats_Selected = true
	end
	function WeaponButton:OnWeaponDeselected()
		self.insaneStats_Selected = nil
	end
	function WeaponButton:DoClick()
		main:Commit()
	end
	function WeaponButton:DoRightClick()
		main.insaneStats_SelectedWeapon = nil
		main:Commit()
	end

	return WeaponButton
end

local function CreateVSC(main, parent, weaponTable)
	local weaponW = main.insaneStats_WeaponW
	local weaponH = main.insaneStats_WeaponH
	local VSC = vgui.Create("DSizeToContents", parent)
	VSC:SetWide(weaponW)
	VSC:SetSizeX(false)
	CreateForwarder(VSC, main, "OnCursorMoved")
	CreateForwarder(VSC, main, "OnMousePressed")
	function VSC:OnWeaponSelected(wep)
		local isSelectedColumn

		for i,v in ipairs(self:GetChildren()) do
			if v.insaneStats_Weapon == wep then
				isSelectedColumn = true
				v:OnWeaponSelected()
			else
				v:OnWeaponDeselected()
			end
		end

		self:SetZPos(isSelectedColumn and 1 or 0)
	end
	function VSC:FindWeaponElement(wep)
		for i,v in ipairs(self:GetChildren()) do
			if v.insaneStats_Weapon == wep then return v end
		end
	end

	local offsetY = 0
	for k,v in SortedPairsByValue(weaponTable) do
		local isSelected = k == main.insaneStats_SelectedWeapon
		local WeaponButton = CreateWeaponButton(main, VSC, k, v, isSelected)
		WeaponButton:SetPos(0, offsetY)

		offsetY = offsetY + weaponH
	end

	return VSC
end

local function InitWeaponSelectorWindow()
	local ply = LocalPlayer()
	local defaultWeaponIconID = surface.GetTextureID("weapons/swep")

	-- remember the default weapon drawing function
	-- if a weapon's drawing function compares equal to this,
	-- then it's safe to be overridden by our own
	local defaultWeaponSelectionFunc = weapons.GetStored("weapon_base").DrawWeaponSelection

	local Main = vgui.Create("DFrame")
	Main:SetSize(ScrW(), ScrH())
	Main:Hide()
	Main:SetTitle("")
	Main:ShowCloseButton(false)
	Main.Paint = nil
	Main.insaneStats_LastWeapons = {}
	Main.insaneStats_CustomSlots = {}
	Main.insaneStats_OpenTime = RealTime()
	InsaneStats.WeaponSelectorWindow = Main
	function Main:OnMousePressed(key)
		if key == MOUSE_RIGHT then
			self.insaneStats_SelectedWeapon = nil
			self:Commit()
		end
	end

	function Main:GetWeaponSlot(wep)
		local customWeaponSlot = self.insaneStats_CustomSlots[wep:GetClass()]
		if customWeaponSlot then return customWeaponSlot - 1 end

		local alphabeticSize = InsaneStats:GetConVarValue("hud_wepsel_alphabetic")
		if alphabeticSize > 0 then
			return math.floor(utf8.codepoint(InsaneStats:GetWeaponName(wep):lower()) / alphabeticSize)
		else
			return wep:GetSlot()
		end
	end

	function Main:OnCursorMoved()
		self:OnWeaponSelected()
		self:UpdateWeaponPositions()
	end
	
	function Main:DrawScriptedWeaponSelection(selected, wep, rarityColor, x, y, w, h)
		local tintMode = InsaneStats:GetConVarValue("hud_wepsel_tint")
		local oldClipState = DisableClipping(selected or false)

		if wep.DrawWeaponSelection == defaultWeaponSelectionFunc
		or wep.DrawWeaponSelection_DLib == defaultWeaponSelectionFunc then
			-- draw this my way! ...but also call hooks for DLib
			local can = hook.Run("DrawWeaponSelection", wep, 0, 0, w, h, 255)
			if can ~= false then
				hook.Run("PreDrawWeaponSelection", wep, 0, 0, w, h, 255)

				local weaponColor = (
					tintMode > 2 or tintMode > 1 and wep.WepSelectIcon == defaultWeaponIconID
				) and rarityColor or color_white
				surface.SetDrawColor(weaponColor)
				surface.SetTexture(wep.WepSelectIcon)
				local fsin = 0
				if wep.BounceWeaponIcon == true and not InsaneStats:GetConVarValue("hud_wepsel_nobounce") then
					fsin = math.sin(CurTime() * 10) * 5
				end

				local borderSize = 10
				surface.DrawTexturedRect(
					borderSize+fsin, borderSize-fsin,
					w-(borderSize+fsin)*2, w/2-borderSize+fsin
				)

				if selected then
					wep:PrintWeaponInfo(borderSize + w, borderSize + h * 0.95, 255)
				end
				
				hook.Run("PostDrawWeaponSelection", wep, 0, 0, w, h, 255)
			end
		else
			-- not safe to overwrite for tinting
			local oldBounceValue = wep.BounceWeaponIcon
			if InsaneStats:GetConVarValue("hud_wepsel_nobounce") then
				wep.BounceWeaponIcon = nil
			end
			local oldDrawWeaponInfoBox = wep.DrawWeaponInfoBox
			if not selected then
				wep.DrawWeaponInfoBox = false
			end

			if autoicon then
				-- FIXME: this is stupid and arguably doesn't even support AutoIcons properly
				local m = Matrix()
				m:Translate(Vector(-x, -y, 0))
				cam.PushModelMatrix(m, true)
				local success, err = pcall(wep.DrawWeaponSelection, wep, x, y, w, h, 255)
				cam.PopModelMatrix()
				if not success then error(err) end
			else
				wep:DrawWeaponSelection(0, 0, w, h, 255)
			end

			wep.BounceWeaponIcon = oldBounceValue
			wep.DrawWeaponInfoBox = oldDrawWeaponInfoBox
		end

		DisableClipping(oldClipState)
	end
	
	function Main:Refresh()
		local refreshRequired = false

		local weaponH = InsaneStats:GetConVarValue("hud_wepsel_wep_h")
		if self.insaneStats_WeaponH ~= weaponH then
			self.insaneStats_WeaponH = weaponH

			surface.CreateFont("InsaneStats.WeaponIcons", {
				font = "HalfLife2",
				size = weaponH,
				weight = 0,
				antialias = true,
				additive = true
			})
			surface.CreateFont("InsaneStats.WeaponIconsBackground", {
				font = "HalfLife2",
				size = weaponH,
				weight = 0,
				antialias = true,
				blursize = 14,
				scanlines = 5,
				additive = true
			})

			refreshRequired = true
		end

		local weaponW = InsaneStats:GetConVarValue("hud_wepsel_wep_w")
		if self.insaneStats_WeaponW ~= weaponW then
			self.insaneStats_WeaponW = weaponW

			refreshRequired = true
		end

		if not refreshRequired then
			local w, h = self:GetSize()
			if w ~= ScrW() or h ~= ScrH() then refreshRequired = true end
		end

		if not refreshRequired then
			for i,v in ipairs(ply:GetWeapons()) do
				local weaponSlot = self:GetWeaponSlot(v)
				local slotTable = self.insaneStats_LastWeapons[weaponSlot]
				if not (slotTable and slotTable[v]) then
					refreshRequired = true break
				end
			end
		end
	
		if not refreshRequired then
			for slot,weaponTable in pairs(self.insaneStats_LastWeapons) do
				for wep,_ in pairs(weaponTable) do
					if not (IsValid(wep) and wep:GetOwner() == ply) then
						refreshRequired = true break
					end
				end
			end
		end
	
		if refreshRequired then
			self:SetSize(ScrW(), ScrH())
			self.insaneStats_LastWeapons = {}
			
			for i,v in ipairs(ply:GetWeapons()) do
				local weaponSlot = self:GetWeaponSlot(v)
				self.insaneStats_LastWeapons[weaponSlot] = self.insaneStats_LastWeapons[weaponSlot] or {}
				self.insaneStats_LastWeapons[weaponSlot][v] = InsaneStats:GetWeaponName(v)
			end
			if InsaneStats:IsDebugLevel(1) then
				InsaneStats:Log("Refreshed weapon selector weapons!")
				if InsaneStats:IsDebugLevel(2) then
					PrintTable(self.insaneStats_LastWeapons)
				end
			end
	
			self:DestructAndRebuildSelectors()
		end

		self:InvalidateChildren(true)
		self:UpdateWeaponPositions()

		local selectedWeapon = self.insaneStats_SelectedWeapon
		if IsValid(selectedWeapon) then
			input.SetCursorPos(self:GetCursorPositionForWeapon(selectedWeapon))
			self:UpdateWeaponPositions() -- this must be called again because the cursor was moved to another panel
		end
	end

	function Main:Begin()
		self.insaneStats_SelectedWeapon = ply:GetActiveWeapon()
		self.insaneStats_OpenTime = RealTime()

		self.insaneStats_CustomSlots = {}
		for i,v in ipairs(InsaneStats.WeaponSelectorWeaponSlots) do
			self.insaneStats_CustomSlots[v[1]] = v[2]
		end

		self:Refresh()
		
		ply:EmitSound("common/wpn_hudon.wav", 0, 100, InsaneStats:GetConVarValue("hud_wepsel_volume") / 100)
	end

	function Main:Commit()
		if self:IsVisible() then
			local selectedWeapon = self.insaneStats_SelectedWeapon
			if IsValid(selectedWeapon) then
				input.SelectWeapon(selectedWeapon)
				if InsaneStats:IsDebugLevel(2) then
					InsaneStats:Log("Switching to %s!", tostring(selectedWeapon))
				end
				ply:EmitSound("common/wpn_hudoff.wav", 0, 100, InsaneStats:GetConVarValue("hud_wepsel_volume") / 100)
			else
				ply:EmitSound("common/wpn_denyselect.wav", 0, 100, InsaneStats:GetConVarValue("hud_wepsel_volume") / 100)
			end

			self:Hide()
		end
	end
	
	local HSC = vgui.Create("DSizeToContents", Main)
	HSC:SetSizeY(false)
	HSC:StretchToParent(nil, 0, nil, 0)
	CreateForwarder(HSC, Main, "OnCursorMoved")
	CreateForwarder(HSC, Main, "OnMousePressed")
	function HSC:OnWeaponSelected(wep)
		for i,v in ipairs(self:GetChildren()) do
			v:OnWeaponSelected(wep)
		end
	end
	function HSC:FindWeaponElement(...)
		for i,v in ipairs(self:GetChildren()) do
			local button = v:FindWeaponElement(...)
			if button then return button, v end
		end
	end

	function Main:DestructAndRebuildSelectors()
		HSC:Clear()
		
		local offsetX = 0
		local weaponW = self.insaneStats_WeaponW
		for k,v in SortedPairs(self.insaneStats_LastWeapons) do
			local VSC = CreateVSC(self, HSC, v)
			VSC:SetPos(offsetX, 0)

			offsetX = offsetX + weaponW
		end
	end

	function Main:OnWeaponSelected(wep)
		if wep ~= self.insaneStats_SelectedWeapon then
			self.insaneStats_SelectedWeapon = wep
			if wep then
				ply:EmitSound("common/wpn_moveselect.wav", 0, 100, InsaneStats:GetConVarValue("hud_wepsel_volume") / 100)
			end

			HSC:OnWeaponSelected(wep)
		end
	end

	function Main:UpdateWeaponPositions()
		-- all positioning is done by Main for optimization reasons
		local xMax, yMax = self:GetSize()
		local hscW = HSC:GetWide()
		local sensitivityX = InsaneStats:GetConVarValue("hud_wepsel_sensitivity_x")
		local sensitivityY = InsaneStats:GetConVarValue("hud_wepsel_sensitivity_y")

		local leftBoundary = (sensitivityX - 1) / sensitivityX / 2 * xMax
		local rightBoundary = xMax - leftBoundary
		local upBoundary = (sensitivityY - 1) / sensitivityY / 2 * yMax
		local downBoundary = yMax - upBoundary

		local cursorX, cursorY = input.GetCursorPos()

		if hscW > rightBoundary - leftBoundary then
			local xPos = math.Remap(cursorX, leftBoundary, rightBoundary, leftBoundary, rightBoundary - hscW)
			HSC:SetX(xPos)
		else
			HSC:SetX((xMax - hscW) / 2)
		end

		for i,v in ipairs(HSC:GetChildren()) do
			local vscH = v:GetTall()
			if vscH > downBoundary - upBoundary then
				local yPos = math.Remap(cursorY, upBoundary, downBoundary, upBoundary, downBoundary - vscH)
				v:SetY(yPos)
			else
				v:SetY((yMax - vscH) / 2)
			end
		end
	end

	function Main:GetCursorPositionForWeapon(wep)
		-- figure out which button and column
		local button, VSC = HSC:FindWeaponElement(wep)
		if not button then return end

		-- figure out x-position
		local xMax, yMax = self:GetSize()
		local sensitivityX = InsaneStats:GetConVarValue("hud_wepsel_sensitivity_x")
		local sensitivityY = InsaneStats:GetConVarValue("hud_wepsel_sensitivity_y")

		local leftBoundary = (sensitivityX - 1) / sensitivityX / 2 * xMax
		local rightBoundary = xMax - leftBoundary
		local upBoundary = (sensitivityY - 1) / sensitivityY / 2 * yMax
		local downBoundary = yMax - upBoundary

		local hscW = HSC:GetWide()
		local xPos
		if hscW > rightBoundary - leftBoundary then
			xPos = math.Remap(VSC:GetX() + VSC:GetWide() / 2, 0, hscW, leftBoundary, rightBoundary)
		else
			xPos = HSC:GetX() + VSC:GetX() + VSC:GetWide() / 2
		end

		-- figure out y-position
		local vscH = VSC:GetTall()
		local yPos
		if vscH > downBoundary - upBoundary then
			yPos = math.Remap(button:GetY() + button:GetTall() / 2, 0, vscH, upBoundary, downBoundary)
		else
			yPos = VSC:GetY() + button:GetY() + button:GetTall() / 2
		end

		if InsaneStats:IsDebugLevel(2) then
			InsaneStats:Log(
				"Boundaries: up=%i, right=%i, down=%i, left=%i",
				upBoundary, rightBoundary, downBoundary, leftBoundary
			)
			InsaneStats:Log(
				"HSC Bounds: %i, %i, %i, %i,", HSC:GetBounds()
			)
			InsaneStats:Log(
				"VSC Bounds: %i, %i, %i, %i,", VSC:GetBounds()
			)
			InsaneStats:Log("Snapped cursor position to %i, %i", xPos, yPos)
		end

		return xPos, yPos
	end
end

local mathEnv = {
	inf = math.huge,
	pi = math.pi,
	e = math.exp(1),
	tau = math.tau,
	abs = math.abs,
	acos = math.acos,
	asin = math.asin,
	atan = math.atan,
	ceil = math.ceil,
	cos = math.cos,
	cosh = math.cosh,
	deg = math.deg,
	exp = math.exp,
	fact = math.Factorial,
	floor = math.floor,
	log = math.log,
	max = math.max,
	min = math.min,
	rad = math.rad,
	random = math.random,
	sin = math.sin,
	sinh = math.sinh,
	tan = math.tan,
	tanh = math.tanh
}

local function InitWeaponSearchWindow()
	local ply = LocalPlayer()

	local Main = vgui.Create("DFrame")
	Main:SetSize(ScrW() / 2, InsaneStats.FONT_BIG + 34)
	Main:Hide()
	Main:SetTitle("Gimme...")
	Main.lblTitle:SetFont("InsaneStats.Big")
	Main:Center()
	InsaneStats.WeaponSearchWindow = Main
	function Main:Paint(w, h)
		draw.RoundedBox(4, 0, 0, w, h, color_black_translucent)
	end
	function Main:Begin()
		for i,v in ipairs(ply:GetWeapons()) do
			if not v.insaneStats_Modifiers then
				v:InsaneStats_MarkForUpdate()
			end
		end
	end
	function Main:InsaneStats_SelectWeapon(wep)
		self:Close()
		if IsValid(wep) then
			input.SelectWeapon(wep)
			if InsaneStats:IsDebugLevel(2) then
				InsaneStats:Log("Switching to %s!", tostring(wep))
			end
			ply:EmitSound("common/wpn_hudoff.wav", 0, 100, InsaneStats:GetConVarValue("hud_wepsel_volume") / 100)
		else
			ply:EmitSound("common/wpn_denyselect.wav", 0, 100, InsaneStats:GetConVarValue("hud_wepsel_volume") / 100)
		end
	end

	local SearchBar = vgui.Create("DTextEntry", Main)
	SearchBar:Dock(TOP)
	SearchBar:RequestFocus()
	SearchBar:SetTabbingDisabled(true)
	SearchBar:SetFont("InsaneStats.Big")
	SearchBar:SetTall(InsaneStats.FONT_BIG)
	function SearchBar:GetAutoComplete(inputText)
		-- calculate search string here, since time is needed for the server to respond with weapon naming
		if not self.insaneStats_WeaponSearchStrings or inputText == "" then
			-- search string:
			-- <wpass2 name> tier:<tier> level:<level>
			self.insaneStats_WeaponSearchStrings = {}
			for i,v in ipairs(ply:GetWeapons()) do
				if v.insaneStats_Modifiers then
					local wpass2Name = InsaneStats:GetWPASS2Name(v)
					local tier = v.insaneStats_Tier or 1
					if wpass2Name then
						local weaponSearchString = string.lower(string.format(
							"%s %s tier:%i level:%s",
							v:GetClass(),
							wpass2Name,
							tier,
							InsaneStats:FormatNumber(v:InsaneStats_GetLevel())
						))

						-- store the wpass2 name, search string, tier (for coloring) and the weapon entity
						table.insert(self.insaneStats_WeaponSearchStrings, {
							name = InsaneStats:GetWeaponName(v),
							wpass2 = wpass2Name,
							search = weaponSearchString,
							tier = tier,
							wep = v
						})
					end
				else
					v:InsaneStats_MarkForUpdate()
				end
			end

			local wpass2Enabled = InsaneStats:GetConVarValue("wpass2_enabled")
			if wpass2Enabled then
				table.sort(self.insaneStats_WeaponSearchStrings, function(a, b)
					if a.tier ~= b.tier then return a.tier > b.tier
					else return a.name < b.name
					end
				end)
			else
				table.SortByMember(self.insaneStats_WeaponSearchStrings, "name", true)
			end
		end

		if inputText ~= "" then
			if inputText[1] == "=" then
				local compiled = CompileString(
					"return "..string.sub(inputText, 2),
					"error",
					false
				)
				if isfunction(compiled) then
					setfenv(compiled, mathEnv)
					local success, ret = pcall(compiled)
					if success then
						return {{name = "="..tostring(ret), wpass2 = ""}}
					else
						return {{name = "=?", wpass2 = ret}}
					end
				else
					return {{name = "=?", wpass2 = compiled}}
				end
			else
				-- inputText is split by spaces, then _ are converted into .
				inputText = string.PatternSafe(string.lower(inputText))
				inputText = string.gsub(inputText, "_", ".")

				local matcheses = {}
				for i,v in ipairs(self.insaneStats_WeaponSearchStrings) do
					local matches = true
					for inputArg in string.gmatch(inputText, "(%S+)") do
						if not string.find(v.search, inputArg) then
							matches = false break
						end
					end
					if matches then
						table.insert(matcheses, v)
						if #matcheses >= 10 then break end
					end
				end

				return matcheses
			end
		end
	end
	function SearchBar:OpenAutoComplete(tab)
		if table.IsEmpty(tab) then return end
	
		self.Menu = DermaMenu()
		self.HistoryPos = 1
		function self.Menu:Paint(w, h)
			draw.RoundedBox(4, 0, 0, w, h, color_black_translucent)
		end
	
		local startDrawTime = RealTime()
		local wpass2Enabled = InsaneStats:GetConVarValue("wpass2_enabled")
		for i,v in pairs(tab) do
			local opt = self.Menu:AddOption("", function()
				Main:InsaneStats_SelectWeapon(v.wep)
			end)
			opt:SetFont("InsaneStats.Big")
			opt:SetTextInset(0, 0)
			function opt:Paint(w, h)
				local outlineThickness = InsaneStats:GetOutlineThickness()
				local isWep = IsValid(v.wep)
				local tier = isWep and InsaneStats:GetWPASS2Rarity(v.wep) or -1
				local rarityColor = (not isWep or wpass2Enabled) and InsaneStats:GetPhasedRarityColor(tier)
				or HSVToColor(RealTime() * 120 % 360, 0.75, 1)
				local displayTime = RealTime() - startDrawTime

				if self.Highlight then
					draw.RoundedBox(4, 0, 0, w, h, rarityColor)
				elseif self.Hovered then
					draw.RoundedBox(4, 0, 0, w, h, color_gray_translucent)
				end

				local panelPosX, panelPosY = self:LocalToScreen()
				InsaneStats:DrawRarityText(
					v.name, 3,
					outlineThickness, outlineThickness, w - outlineThickness * 2,
					color_white, displayTime,
					panelPosX, panelPosY
				)
				if wpass2Enabled or not isWep then
					InsaneStats:DrawRarityText(
						v.wpass2, 2,
						outlineThickness, InsaneStats.FONT_BIG + outlineThickness, w - outlineThickness * 2,
						tier, displayTime,
						panelPosX, panelPosY
					)
				end
			end
			function opt:PerformLayout(w, h)
				local outlineThickness = InsaneStats:GetOutlineThickness()
				local isWep = IsValid(v.wep)
				local ySize = (wpass2Enabled or not isWep)
				and InsaneStats.FONT_BIG + InsaneStats.FONT_MEDIUM + outlineThickness * 3
				or InsaneStats.FONT_BIG + outlineThickness * 2
				self:SetSize(self:GetParent():GetWide(), ySize)
			
				if IsValid(self.SubMenuArrow) then
					self.SubMenuArrow:SetSize(15, 15)
					self.SubMenuArrow:CenterVertical()
					self.SubMenuArrow:AlignRight( 4 )
				end
			
				DButton.PerformLayout(self, w, h)
			end

			if i == 1 then
				opt.Highlight = true
			end
		end
	
		local x, y = self:LocalToScreen(0, self:GetTall())
		self.Menu:SetMinimumWidth(self:GetWide())
		self.Menu:Open(x, y, true, self)
		self.Menu:SetPos(x, y)
		self.Menu:SetMaxHeight( (ScrH() - y) - 10 )
	end
	function SearchBar:OnKeyCodeTyped(code)
		self:OnKeyCode(code)
	
		if code == KEY_ENTER --[[and not self:IsMultiline() and self:GetEnterAllowed()]] then
			if IsValid(self.Menu) then
				-- simulate click on the first item and delete this menu
				self.Menu:GetChild(math.max(1, self.HistoryPos)):DoClick()
				self.Menu:Remove()
			else
				Main:InsaneStats_SelectWeapon()
			end
	
			--[[self:FocusNext()
			self:OnEnter(self:GetText())
			self.HistoryPos = 0]]
		end
	
		if --[[self.m_bHistory or]] IsValid(self.Menu) then
			if code == KEY_UP then
				self.HistoryPos = self.HistoryPos - 1
				self:UpdateFromHistory()
			end
	
			if code == KEY_DOWN or code == KEY_TAB then
				self.HistoryPos = self.HistoryPos + 1
				self:UpdateFromHistory()
			end
		end
	end
	function SearchBar:UpdateFromMenu()
		local pos = self.HistoryPos
		local num = self.Menu:ChildCount()
	
		self.Menu:ClearHighlights()
	
		if pos < 1 then pos = num end
		if pos > num then pos = 1 end
	
		local item = self.Menu:GetChild(pos)
		self.Menu:HighlightItem(item)
		self.HistoryPos = pos
	end
end

concommand.Add("+insanestats_wepsel", function()
	if not IsValid(InsaneStats.WeaponSelectorWindow) then InitWeaponSelectorWindow() end
	InsaneStats.WeaponSelectorWindow:Show()
	InsaneStats.WeaponSelectorWindow:MakePopup()
	InsaneStats.WeaponSelectorWindow:SetKeyboardInputEnabled(false)
	InsaneStats.WeaponSelectorWindow:Begin()
end)
concommand.Add("-insanestats_wepsel", function()
	InsaneStats.WeaponSelectorWindow:Commit()
end)
concommand.Add("insanestats_wepsel_gimme", function()
	if not IsValid(InsaneStats.WeaponSearchWindow) then InitWeaponSearchWindow() end
	InsaneStats.WeaponSearchWindow:Show()
	InsaneStats.WeaponSearchWindow:MakePopup()
	InsaneStats.WeaponSearchWindow:Begin()
end)