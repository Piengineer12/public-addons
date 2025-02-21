info = {
    workshop_page: 'TBD'
    profile_page: 'https://steamcommunity.com/id/Piengineer12'
    github_page: 'https://github.com/Piengineer12/public-addons/tree/master/mwsas'
    donate_page: 'https://ko-fi.com/piengineer12'
    extra_info: 'Links above are confirmed working as of 2025-02-21. All dates are in ISO 8601 format.'
}

local WeaponSelectorVerticalScroller

class BasicDrawing
	@cvarInfo: {}
	@cvars: {}

	CreateForwarder: (target, funcName) => (...) => target[funcName] target, ...
	
	GetWeaponName: (wep) => language.GetPhrase(wep.PrintName ~= "" and wep.PrintName or wep\GetClass!)

	RegisterCVars: (name, info) => @@RegisterCVarsStatic name, info
	
	@RegisterCVarsStatic: (name, info) =>
		table.insert @cvarInfo, {:name, :info}
		for entry in *info
			ref = entry.name or entry.ref
			conVarName = 'mwsas_'..ref
			description = @AssemblePhrase '#mwsas.'..ref..'.desc'
			conVar = switch entry.type
				when 'bool' then CreateClientConVar conVarName, entry.default, true, false,
						description, 0, 1
				when 'int' then CreateClientConVar conVarName, entry.default, true, false,
						description, entry.min, entry.max
				else CreateClientConVar conVarName, entry.default, true, false,
						description
			@cvars[entry.ref] = :conVar, type: entry.type

	GetConVarValue: (ref) =>
		entry = @@cvars[ref]
		if entry then switch entry.type
			when 'bool' then entry.conVar\GetBool!
			when 'int' then entry.conVar\GetInt!
			when 'float' then entry.conVar\GetFloat!
			else entry.conVar\GetString!
		else
			@Log 'Failed to associate %s with any ConVar!', ref

	@PopulateToolMenu: =>
		for categoryInfo in *@cvarInfo
			spawnmenu.AddToolMenuOption 'Utilities', 'MWS&S',
				categoryInfo.name, '#mwsas.'..categoryInfo.name,
				nil, nil, @FillInDForm categoryInfo
		return
	
	@FillInDForm: (categoryInfo) =>
		(panel) ->
			categoryPrefix = '#mwsas.'..categoryInfo.name
			panel\ControlHelp categoryPrefix
			for info in *categoryInfo.info
				ref = info.name or info.ref
				displayName = '#mwsas.'..ref
				cvar = 'mwsas_'..ref
				switch info.type
					when 'bool'
						panel\CheckBox displayName, cvar
					when 'int'
						panel\NumberWang displayName, cvar, info.min, info.max
					when 'float'
						decimals = 4 - math.Round math.log10 info.max - info.min
						panel\NumSlider displayName, cvar, info.min, info.max, decimals
					else
						panel\TextEntry displayName, cvar
				panel\Help @AssemblePhrase displayName..'.desc'
	
	@AssemblePhrase: (phrase) =>
		token = phrase..'.1'
		if token == language.GetPhrase token
			phrase
		else
			assembled = {}
			i = 1

			while i < 99
				token = string.format '%s.%u', phrase, i
				translated = language.GetPhrase token
				break if token == translated
				table.insert assembled, translated
				i += 1
			table.concat assembled

	IsDebugLevel: (level) => level <= @GetConVarValue 'debug'

	Log: (text, ...) => MsgC Color(0, 255, 255), "[MWS&S] ", color_white, string.format "#{text}\n", ...

	FormatNumber: (num) => num < 1e3 and string.Comma(math.Round num, 3) or string.Comma math.Round num

	DrawTextOutlined: (text, font, x, y, color, outlineOnly) =>
		if outlineOnly then color = color_transparent

		draw.SimpleTextOutlined text, font,
			x, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP,
			@GetConVarValue('outline'), @GetOutlineColor color
	
	GetOutlineColor: (color) =>
		outlineColorMul = @GetConVarValue('outline_colorbleed') / 100
		if outlineColorMul > 0
			Color color.r * outlineColorMul,
				color.g * outlineColorMul,
				color.b * outlineColorMul
		else
			color_black

	DrawRarityText: (text, font, x, y, w, tier, time, scissorX, scissorY) =>
		outlineThickness = @GetConVarValue 'outline'
		stringSub = string.sub--utf8.sub
		scissorX = (scissorX or 0) + x - outlineThickness
		scissorY = (scissorY or 0) + y - outlineThickness
		surface.SetFont font

		-- how much space is overflowed by the text?
		textTotalWidth, textTotalHeight = surface.GetTextSize text
		nameExtraW = textTotalWidth - w
		nameScrollFactor = nameExtraW > 0 and (math.cos(time/2)+1)/2 or 1
		nameScrollAmt = Lerp nameScrollFactor, nameExtraW, 0

		-- clip text to what's actually worth drawing
		startIndex, endIndex = @SubstringBySize text,
			nameScrollAmt - outlineThickness,
			nameScrollAmt + w + outlineThickness
		undrawnX = surface.GetTextSize stringSub text, 1, startIndex - 1
		offsetX = undrawnX - nameScrollAmt
		textX = x + offsetX

		-- clip drawing area
		render.SetScissorRect scissorX, scissorY,
			scissorX + w + outlineThickness * 2,
			scissorY + textTotalHeight + outlineThickness * 2,
			true

		-- draw, the endIndex+4 part is because of the possibility of truncated utf-8 sequences
		chars = [utf8.char code for i, code in utf8.codes utf8.force stringSub text, startIndex, endIndex + 4]
		
		charData = {}
		numberTier = tonumber tier
		for char in *chars
			color = tier
			if numberTier then color = InsaneStats\GetPhasedRarityColor numberTier, (undrawnX + textX) / w
			table.insert charData, {x: textX, :color}
			
			textX += @DrawTextOutlined char, font, textX, y, color, true

		draw.SimpleText v, font, charData[i].x, y, charData[i].color for i, v in ipairs chars

		render.SetScissorRect 0, 0, 0, 0, false

	SubstringBySize: (text, startX, endX) =>
		textLength = #text--utf8.len(text)
		stringSub = string.sub--utf8.sub

		iL, iR = 1, textLength
		while iL < iR
			iM = math.floor((iL + iR) / 2)
			substring = stringSub text, 1, iM
			x = surface.GetTextSize substring
			if x < startX
				iL = iM + 1
			else
				iR = iM
		startTextIndex = iL

		iL, iR = 1, textLength
		while iL < iR
			iM = math.floor((iL + iR) / 2)
			substring = stringSub text, 1, iM
			x = surface.GetTextSize substring
			if x > endX
				iR = iM
			else
				iL = iM + 1
		endTextIndex = iR

		startTextIndex, endTextIndex

class WeaponSelector extends BasicDrawing
	new: =>
		@weaponData = {}
		@RegisterCVars 'selector', {
			{ref: 'selector_alphabetic', type: 'int', default: '0', min: 0, max: 255}
			{ref: 'selector_color', type: 'string', default: '255 255 255 255'}
			{ref: 'selector_nobounce', type: 'bool', default: '0'}
			{ref: 'selector_sensitivity_x', type: 'float', default: '1.5', min: 1, max: 10}
			{ref: 'selector_sensitivity_y', type: 'float', default: '1.5', min: 1, max: 10}
			{ref: 'selector_width', type: 'float', default: '256', min: 0, max: 10000}
			{ref: 'selector_height', type: 'float', default: '128', min: 0, max: 10000}
			{ref: 'selector_clip_font', type: 'string', default: 'Orbitron Medium'}
			{ref: 'selector_clip_font_size', type: 'float', default: '8', min: 0, max: 1000}
			{ref: 'selector_details_font', type: 'string', default: 'Orbitron Medium'}
			{ref: 'selector_details_font_size', type: 'float', default: '8', min: 0, max: 1000}
		}

	GetWeaponSlot: (wep) =>
		alphabetRange = @GetConVarValue 'selector_alphabetic'
		if alphabetRange > 0
			math.floor utf8.codepoint(@GetWeaponName(wep)\lower!) / alphabetRange
		else
			wep\GetSlot!
	
	Start: =>
		@ply = LocalPlayer!
		selectedWeapon = @ply\GetActiveWeapon!
		@selectedWeapon = nil

		@CreateWindow! unless IsValid @window
		@Refresh!
		@RefreshFonts!
		@SelectWeapon selectedWeapon

		@window\Show!
		@window\MakePopup!
		@window\SetKeyboardInputEnabled false
		@window\InvalidateChildren true
		@UpdateWeaponPositions!

		if IsValid selectedWeapon
			input.SetCursorPos @GetCursorPositionForWeapon selectedWeapon
			@UpdateWeaponPositions! -- this must be called again because the cursor was moved to another panel
		
		@ply\EmitSound 'common/wpn_hudon.wav', 0, 100, @GetConVarValue('volume') / 100
	
	CreateWindow: =>
		window = with vgui.Create 'DFrame'
			\SetSize ScrW!, ScrH!
			\SetTitle ''
			\ShowCloseButton false
			.Paint = nil
			.OnMousePressed = (panel, key) ->
				if key == MOUSE_RIGHT
					@SelectWeapon!
					@End!
				return
			.OnCursorMoved = ->
				@SelectWeapon!
				@UpdateWeaponPositions!
				return
		@window = window
		
		@horizontalScroller = with vgui.Create 'DSizeToContents', window
			\SetSizeY false
			\SetTall window\GetTall!
			.OnCursorMoved = @CreateForwarder window, 'OnCursorMoved'
			.OnMousePressed = @CreateForwarder window, 'OnMousePressed'

	GetHorizontalScroller: => @horizontalScroller
	
	RefreshRequired: =>
		weaponH = @GetConVarValue 'selector_height'
		weaponW = @GetConVarValue 'selector_width'
		if @weaponH ~= weaponH or @weaponW ~= weaponW
			@weaponH = weaponH
			@weaponW = weaponW
			@RefreshFonts true
			return true

		w, h = @window\GetSize!
		if w ~= ScrW! or h ~= ScrH! then return true

		for wep in *@ply\GetWeapons!
			weaponSlot = @GetWeaponSlot wep
			slotTable = @weaponData[weaponSlot]
			unless slotTable and slotTable[v] then return true
	
		for slot, weps in pairs @weaponData
			for wep, data in pairs weps
				unless IsValid wep and wep\GetOwner! == @ply then return true
		false
	
	Refresh: =>
		if @RefreshRequired!
			@window\SetSize ScrW!, ScrH!
			@weaponData = {}
			
			for wep in *@ply\GetWeapons!
				weaponSlot = @GetWeaponSlot wep
				@weaponData[weaponSlot] or= {}
				@weaponData[weaponSlot][wep] = @GetWeaponName wep

			if @IsDebugLevel 1
				@Log 'Refreshed weapon selector weapons!'
				PrintTable @weaponData if @IsDebugLevel 2

			@RebuildWeaponButtons!
	
	FontRefreshRequired: =>
		clipFont = @GetConVarValue 'selector_clip_font'
		clipFontHeight = @GetFontHeight 'clip'
		detailsFont = @GetConVarValue 'selector_details_font'
		detailsFontHeight = @GetFontHeight 'details'
		if @clipFont ~= clipFont or @clipFontHeight ~= clipFontHeight or
		@detailsFont ~= detailsFont or @detailsFontHeight ~= detailsFontHeight
			@clipFont = clipFont
			@clipFontHeight = clipFontHeight
			@detailsFont = detailsFont
			@detailsFontHeight = detailsFontHeight
			true
		else
			false
	
	GetFontHeight: (arg) => ScreenScale @GetConVarValue "selector_#{arg}_font_size"

	RefreshFonts: (force) =>
		if @FontRefreshRequired! or force
			surface.CreateFont 'MWSAS.WeaponIcons', {
				font: 'HalfLife2'
				size: @weaponH
				weight: 0
				antialias: true
				additive: true
			}
			surface.CreateFont 'MWSAS.WeaponIconsBackground', {
				font: 'HalfLife2'
				size: @weaponH
				weight: 0
				antialias: true
				blursize: 14
				scanlines: 5
				additive: true
			}
			surface.CreateFont 'MWSAS.Clip', {
				font: @clipFont
				size: @clipFontHeight
			}
			surface.CreateFont 'MWSAS.SelectorDetails', {
				font: @detailsFont
				size: @detailsFontHeight
			}
	
	RebuildWeaponButtons: =>
		@horizontalScroller\Clear!
		@verticalScrollers = {}
		
		offsetX = 0
		weaponW = @weaponW
		weaponH = @weaponH
		for slot, weps in SortedPairs @weaponData
			verticalScroller = WeaponSelectorVerticalScroller @, offsetX, weaponW, weaponH, weps
			verticalScroller\SelectWeapon wep
			table.insert @verticalScrollers, verticalScroller
			offsetX += weaponW
	
	GetCursorPositionForWeapon: (wep) =>
		local target, wepY
		for verticalScroller in *@verticalScrollers
			if wepY = verticalScroller\GetWeaponY wep
				target = verticalScroller
				break
		return unless target

		-- figure out x-position
		xMax, yMax = @window\GetSize!
		sensitivityX = @GetConVarValue 'selector_sensitivity_x'
		sensitivityY = @GetConVarValue 'selector_sensitivity_y'

		leftBoundary = (sensitivityX - 1) / sensitivityX / 2 * xMax
		rightBoundary = xMax - leftBoundary
		upBoundary = (sensitivityY - 1) / sensitivityY / 2 * yMax
		downBoundary = yMax - upBoundary

		vsX, vsY, vsW, vsH = target\GetBounds!
		scrollerWidth = @horizontalScroller\GetWide!
		offsetX = vsX + vsW / 2
		xPos = if scrollerWidth > rightBoundary - leftBoundary
			math.Remap offsetX, 0, scrollerWidth, leftBoundary, rightBoundary
		else
			@horizontalScroller\GetX! + offsetX

		-- figure out y-position
		scrollerHeight = vsH
		yPos = if scrollerHeight > downBoundary - upBoundary
			math.Remap wepY, 0, scrollerHeight, upBoundary, downBoundary
		else
			vsY + wepY

		if @IsDebugLevel 2
			@Log 'Boundaries: up=%i, right=%i, down=%i, left=%i',
				upBoundary, rightBoundary, downBoundary, leftBoundary
			@Log 'HSC Bounds: %i, %i, %i, %i,', @horizontalScroller\GetBounds!
			@Log 'VSC Bounds: %i, %i, %i, %i,', vsX, vsY, vsW, vsH
			@Log 'Snapped cursor position to %i, %i', xPos, yPos

		xPos, yPos
	
	UpdateWeaponPositions: =>
		xMax, yMax = @window\GetSize!
		width = @horizontalScroller\GetWide!
		sensitivityX = @GetConVarValue 'selector_sensitivity_x'
		sensitivityY = @GetConVarValue 'selector_sensitivity_y'

		leftBoundary = (sensitivityX - 1) / sensitivityX / 2 * xMax
		rightBoundary = xMax - leftBoundary
		upBoundary = (sensitivityY - 1) / sensitivityY / 2 * yMax
		downBoundary = yMax - upBoundary

		cursorX, cursorY = input.GetCursorPos!

		if width > rightBoundary - leftBoundary
			xPos = math.Remap cursorX, leftBoundary, rightBoundary, leftBoundary, rightBoundary - width
			@horizontalScroller\SetX xPos
		else
			@horizontalScroller\SetX (xMax - width) / 2

		for verticalScroller in *@verticalScrollers
			height = verticalScroller\GetTall!
			if height > downBoundary - upBoundary
				yPos = math.Remap cursorY, upBoundary, downBoundary, upBoundary, downBoundary - height
				verticalScroller\SetY yPos
			else
				verticalScroller\SetY (yMax - height) / 2

	SelectWeapon: (wep) =>
		if wep ~= @selectedWeapon
			@selectedWeapon = wep
			if wep then @ply\EmitSound 'common/wpn_moveselect.wav', 0, 100, @GetConVarValue('volume') / 100

			verticalScroller\SelectWeapon wep for verticalScroller in *@verticalScrollers

	End: =>
		if @window\IsVisible!
			selectedWeapon = @selectedWeapon
			if IsValid selectedWeapon
				input.SelectWeapon selectedWeapon
				if @IsDebugLevel 2 then @Log 'Switching to %s!', tostring selectedWeapon
				@ply\EmitSound 'common/wpn_hudoff.wav', 0, 100, @GetConVarValue('volume') / 100
			else
				@ply\EmitSound 'common/wpn_denyselect.wav', 0, 100, @GetConVarValue('volume') / 100

			@window\Hide!

class WeaponSelectorVerticalScroller extends BasicDrawing
	gapSize: 2
	colors: {
		normal: Color 0, 0, 0, 239
		selected: Color 127, 127, 127, 239
	}
	weaponSelectorChars: {
		weapon_smg1: 'a'
		weapon_shotgun: 'b'
		weapon_shotgun_hl1: 'b'
		weapon_crowbar: 'c'
		weapon_crowbar_hl1: 'c'
		weapon_pistol: 'd'
		weapon_357: 'e'
		weapon_357_hl1: 'e'
		weapon_crossbow: 'g'
		weapon_physgun: 'h'
		weapon_rpg: 'i'
		weapon_rpg_hl1: 'i'
		weapon_bugbait: 'j'
		weapon_frag: 'k'
		weapon_ar2: 'l'
		weapon_physcannon: 'm'
		weapon_stunstick: 'n'
		weapon_slam: 'o'
	}

	new: (weaponSelector, x, w, h, weps) =>
		@openTime = RealTime!
		@weaponSelector = weaponSelector
		@horizontalScroller = weaponSelector\GetHorizontalScroller!
		-- restructure weps
		@weps = [{wep, name} for wep, name in SortedPairsByValue weps]
		@panel = with vgui.Create 'DSizeToContents', @horizontalScroller
			\SetX x
			\SetWide w
			\SetSizeX false
			.OnCursorMoved = @CreateForwarder @horizontalScroller, 'OnCursorMoved'
			.OnMousePressed = @CreateForwarder @horizontalScroller, 'OnMousePressed'
		@weaponPanels = {}
		@weaponH = h
		@selectedIndex = 0
		@ply = LocalPlayer!
		@defaultWeaponIconID = surface.GetTextureID 'weapons/swep'

		-- remember the default weapon drawing function
		-- if a weapon's drawing function compares equal to this,
		-- then it's safe to be overridden by our own
		@defaultWeaponDrawing = weapons.GetStored('weapon_base').DrawWeaponSelection

		offsetY = 0
		for i, {wep, name} in ipairs @weps
			weaponPanel = @CreateWeaponPanel i, wep, name
			weaponPanel\SetY offsetY
			table.insert @weaponPanels, weaponPanel

			offsetY += h
	
	GetFontHeight: (...) => @weaponSelector\GetFontHeight ...
	
	CreateWeaponPanel: (index, wep, name) =>
		with vgui.Create 'DButton', @panel
			\SetText ''
			\SetSize @panel\GetWide!, @weaponH
			.Paint = (panel, w, h) ->
				if IsValid wep
					selected = @selectedIndex == index
					gapSize = @gapSize
					draw.RoundedBox 8, gapSize, gapSize, w-gapSize*2, h-gapSize*2,
						@colors[selected and 'selected' or 'normal']

					color = @DetermineWeaponColor wep
					x, y = panel\LocalToScreen!
					
					@DrawWeaponIcon wep, selected, color, x, y, w, h
					@DrawWeaponClips wep, w
					@DrawWeaponDetails wep, name, x, y, w, h
				else
					@weaponSelector\Refresh!
			
			.OnCursorMoved = (panel, w, h) ->
				@weaponSelector\SelectWeapon wep
				@weaponSelector\UpdateWeaponPositions!
			.DoClick = -> @weaponSelector\End!
			.DoRightClick = ->
				@weaponSelector\SelectWeapon!
				@weaponSelector\End!
	
	DetermineWeaponColor: (wep) =>
		if (InsaneStats and InsaneStats\GetConVarValue('wpass2_enabled'))
			tintMode = InsaneStats\GetConVarValue 'hud_wepsel_tint'
			if tintMode > 2 or
			tintMode > 1 and wep.WepSelectIcon == defaultWeaponIconID or
			tintMode > 0 and not wep\IsScripted!
				tier = InsaneStats\GetWPASS2Rarity(wep) or 0
				return InsaneStats\GetPhasedRarityColor tier
		if wep\IsScripted!
			color_white
		else
			string.ToColor @GetConVarValue 'selector_color'
	
	DrawWeaponIcon: (wep, selected, color, x, y, w, h) =>
		if wep.DrawWeaponSelection
			@DrawScriptedWeaponIcon wep, selected, color, x, y, w, h
		elseif not wep\IsScripted!
			wepClass = wep\GetClass!\lower!
			char = @weaponSelectorChars[wepClass] or 'V'

			draw.SimpleText char, "MWSAS.WeaponIconsBackground", w/2, h/2, color,
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
			draw.SimpleText char, "MWSAS.WeaponIcons", w/2, h/2, color,
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
	
	DrawScriptedWeaponIcon: (wep, selected, color, x, y, w, h) =>
		oldClipState = DisableClipping selected or false

		if wep.DrawWeaponSelection == @defaultWeaponDrawing or
		wep.DrawWeaponSelection_DLib == @defaultWeaponDrawing
			-- draw this my way! ...but also call hooks for DLib
			can = hook.Run 'DrawWeaponSelection', wep, 0, 0, w, h, 255
			if can ~= false
				hook.Run 'PreDrawWeaponSelection', wep, 0, 0, w, h, 255

				surface.SetDrawColor color
				surface.SetTexture wep.WepSelectIcon
				
				fsin = 0
				if wep.BounceWeaponIcon == true and not @GetConVarValue 'selector_nobounce'
					fsin = math.sin(CurTime! * 10) * 5

				borderSize = 10
				surface.DrawTexturedRect borderSize+fsin, borderSize-fsin,
					w-(borderSize+fsin)*2, w/2-borderSize+fsin

				if selected then wep\PrintWeaponInfo borderSize + w, borderSize + h * 0.95, 255
				
				hook.Run 'PostDrawWeaponSelection', wep, 0, 0, w, h, 255
		else
			-- not safe to overwrite for tinting
			oldBounceValue = wep.BounceWeaponIcon
			wep.BounceWeaponIcon = nil if @GetConVarValue 'selector_nobounce'
			
			oldDrawWeaponInfoBox = wep.DrawWeaponInfoBox
			wep.DrawWeaponInfoBox = false unless selected

			if autoicon
				-- FIXME: this is stupid and arguably doesn't even support AutoIcons properly
				m = Matrix!
				m\Translate Vector -x, -y, 0
				cam.PushModelMatrix m, true
				success, err = pcall wep.DrawWeaponSelection, wep, x, y, w, h, 255
				cam.PopModelMatrix!
				error err unless success
			else
				wep\DrawWeaponSelection 0, 0, w, h, 255

			wep.BounceWeaponIcon = oldBounceValue
			wep.DrawWeaponInfoBox = oldDrawWeaponInfoBox

		DisableClipping oldClipState
	
	DrawWeaponClips: (wep, x) =>
		ply = @ply
		if (IsValid(ply) and ply\IsSuitEquipped!)
			outlineThickness = @GetConVarValue 'outline'

			ammoMaxOverride = GetConVar('gmod_maxammo')\GetInt!
			ammoMaxOverride = ammoMaxOverride > 0 and ammoMaxOverride
			
			customAmmoDisplay = wep.CustomAmmoDisplay and wep\CustomAmmoDisplay!
			customAmmoDisplay = {} unless (customAmmoDisplay and customAmmoDisplay.Draw)
			
			gapSize = @gapSize
			textY = outlineThickness + gapSize

			-- primary bar
			ammoType1 = wep\GetPrimaryAmmoType!
			useAmmoType1 = ammoType1 > -1
			reserve1 = tonumber(customAmmoDisplay.PrimaryAmmo or useAmmoType1 and ply\GetAmmoCount ammoType1) or -1
			maxClip1 = tonumber(wep\GetMaxClip1!) or -1
			clip1 = tonumber(customAmmoDisplay.PrimaryClip or wep\Clip1!) or -1
			maxReserve1 = tonumber(ammoMaxOverride or useAmmoType1 and game.GetAmmoMax ammoType1) or -1

			ammoUnits = {}
			table.insert ammoUnits, {clip1, maxClip1} if maxClip1 > -1 or clip1 > -1
			table.insert ammoUnits, {reserve1, maxReserve1} if reserve1 > -1

			fontHeight = @GetFontHeight 'clip'
			if next ammoUnits
				@DrawAmmoText ammoUnits, x - outlineThickness - gapSize, textY
				textY += fontHeight
		
			-- secondary bar
			ammoType2 = wep\GetSecondaryAmmoType!
			useAmmoType2 = ammoType2 > -1
			reserve2 = tonumber(customAmmoDisplay.SecondaryAmmo or useAmmoType2 and ply\GetAmmoCount ammoType2) or -1
			maxClip2 = tonumber(wep\GetMaxClip2!) or -1
			clip2 = tonumber(customAmmoDisplay.SecondaryClip or wep\Clip2!) or -1
			maxReserve2 = tonumber(ammoMaxOverride or useAmmoType2 and game.GetAmmoMax ammoType2) or -1

			ammoUnits = {}
			table.insert ammoUnits, {clip2, maxClip2} if maxClip2 > -1 or clip2 > -1
			table.insert ammoUnits, {reserve2, maxReserve2} if reserve2 > -1

			if next ammoUnits then @DrawAmmoText ammoUnits, x - outlineThickness - gapSize, textY

	DrawWeaponDetails: (wep, name, x, y, w, h) =>
		outlineThickness = @GetConVarValue 'outline'
		gapSize = @gapSize
		fontHeight = @GetFontHeight 'details'
		weaponDetails = {}
		textX = gapSize + outlineThickness
		textY = h - gapSize - fontHeight - outlineThickness * 2
		maxWidth = w - gapSize * 2 - outlineThickness * 2
		displayTime = RealTime! - @openTime

		if InsaneStats
			local rarity
			if InsaneStats\GetConVarValue 'wpass2_enabled'
				if wep.insaneStats_Modifiers
					rarity = InsaneStats\GetWPASS2Rarity(wep) or 0
					table.insert weaponDetails, 'Tier ' .. wep.insaneStats_Tier
				else
					wep\InsaneStats_MarkForUpdate!
			if InsaneStats\GetConVarValue 'xp_enabled'
				table.insert weaponDetails, 'Level ' .. InsaneStats\FormatNumber wep\InsaneStats_GetLevel!

			if next weaponDetails
				@DrawRarityText table.concat(weaponDetails, ", "), 'MWSAS.SelectorDetails',
					textX, textY, maxWidth, color_white, displayTime, x, y

				textY -= fontHeight + outlineThickness

			if rarity
				@DrawRarityText InsaneStats\GetWPASS2Name(wep), 'MWSAS.SelectorDetails',
					textX, textY, maxWidth, rarity, displayTime, x, y

				textY -= fontHeight + outlineThickness

		@DrawRarityText name, 'MWSAS.SelectorDetails',
			textX, textY, maxWidth, color_white, displayTime, x, y
	
	GetAmmoColor: (ammo, maxAmmo) =>
		if ammo == math.huge or ammo > 0 and maxAmmo <= 0
			return HSVToColor RealTime! * 120 % 360, 0.75, 1
		elseif ammo < maxAmmo or maxAmmo <= 0
			return HSVToColor ammo / math.max(maxAmmo, 1) * 120, 0.75, 1
		else
			bars = math.max math.ceil(ammo / maxAmmo), 1
			return HSVToColor (bars + 3) * 30 % 360, 0.75, 1

	DrawAmmoText: (ammoData, x, y) =>
		{clipData, reserveData} = ammoData
		textPieces, textColors = {}, {}

		table.insert textPieces, string.format '%s / %s',
			@FormatNumber(clipData[1]),
			clipData[2] > 0 and @FormatNumber(clipData[2]) or '?'
		table.insert textColors, @GetAmmoColor clipData[1], clipData[2]

		if reserveData
			table.insert textPieces, "   |   "
			table.insert textColors, color_white

			table.insert textPieces, string.format '%s / %s',
				@FormatNumber(reserveData[1]),
				reserveData[2] > 0 and @FormatNumber(reserveData[2]) or '?'
			table.insert textColors, @GetAmmoColor reserveData[1], reserveData[2]

		surface.SetFont 'MWSAS.Clip'
		textX = x - surface.GetTextSize table.concat textPieces

		for i, textPiece in ipairs textPieces
			textX += @DrawTextOutlined textPiece, 'MWSAS.Clip', textX, y, textColors[i]
	
	SelectWeapon: (target) =>
		@selectedIndex = 0
		@panel\SetZPos 0
		for i, {wep, name} in ipairs @weps
			if wep == target
				@selectedIndex = i
				@panel\SetZPos 1
	
	GetWeaponY: (target) =>
		for i, {wep, name} in ipairs @weps
			if wep == target then return (i - 0.5) * @weaponH
		return
	
	GetBounds: => @panel\GetBounds!
	GetTall: => @panel\GetTall!
	SetY: (y) => @panel\SetY y

class WeaponSearcher extends BasicDrawing
	colors: {
		normal: Color 0, 0, 0, 239
		selected: Color 255, 255, 255, 239
		hovered: Color 127, 127, 127, 239
	}

	mathEnv: {
		inf: math.huge
		pi: math.pi
		e: math.exp 1
		tau: math.tau
		abs: math.abs
		acos: math.acos
		asin: math.asin
		atan: math.atan
		ceil: math.ceil
		cos: math.cos
		cosh: math.cosh
		deg: math.deg
		exp: math.exp
		fact: math.Factorial
		floor: math.floor
		fmod: math.fmod
		ln: (x) -> math.log x
		log: (x, b) -> if b then math.log x, b else math.log10 x
		max: math.max
		min: math.min
		mod: (x, b) -> x % b
		rad: math.rad
		random: math.random
		round: math.Round
		sin: math.sin
		sinh: math.sinh
		tan: math.tan
		tanh: math.tanh
	}

	new: =>
		@RegisterCVars 'searcher', {
			{ref: 'searcher_width', type: 'float', default: '50', min: 0, max: 100}
			{ref: 'searcher_title_font', type: 'string', default: 'Orbitron Medium'}
			{ref: 'searcher_bar_font', type: 'string', default: 'Orbitron Medium'}
			{ref: 'searcher_bar_font_size', type: 'float', default: '12', min: 0, max: 1000}
			{ref: 'searcher_details_font', type: 'string', default: 'Orbitron Medium'}
			{ref: 'searcher_details_font_size', type: 'float', default: '8', min: 0, max: 1000}
		}

	Start: =>
		@ply = LocalPlayer!
		@weaponInfo = nil
		@RefreshFonts!
		@CreateWindow!

		if InsaneStats then for wep in *@ply\GetWeapons!
			wep\InsaneStats_MarkForUpdate! unless wep.insaneStats_Modifiers
	
	CreateWindow: =>
		barHeight = @GetFontHeight 'bar'
		@panel = with vgui.Create 'DFrame'
			\SetSize ScrW! * @GetConVarValue('searcher_width') / 100, barHeight + 34
			\SetTitle '#mwsas.searcher.title'
			\Center!
			\MakePopup!
			.lblTitle\SetFont 'MWSAS.SearcherTitle'
			.Paint = (panel, w, h) -> draw.RoundedBox 4, 0, 0, w, h, @colors.normal
		
		searchBar = with vgui.Create 'DTextEntry', @panel
			\Dock TOP
			\RequestFocus!
			\SetTabbingDisabled true
			\SetFont 'MWSAS.Searcher'
			\SetTall barHeight
			.GetAutoComplete = (panel, inputText) ->
				-- calculate search string here, since time is needed for the server to respond with weapon naming
				@FillWeaponInfo! unless @weaponInfo and inputText ~= ""
				@GetAutoComplete inputText
			.OpenAutoComplete = (panel, tab) -> @OpenAutoComplete panel, tab unless table.IsEmpty tab
			.OnKeyCodeTyped = (panel, code) ->
				panel\OnKeyCode code
			
				if IsValid panel.Menu then switch code
					when KEY_ENTER
						-- simulate click on the first item and delete this menu
						panel.Menu\GetChild(math.max 1, panel.HistoryPos)\DoClick!
						panel.Menu\Remove!

					when KEY_UP
						panel.HistoryPos = panel.HistoryPos - 1
						panel\UpdateFromHistory!
			
					when KEY_DOWN, KEY_TAB
						panel.HistoryPos = panel.HistoryPos + 1
						panel\UpdateFromHistory!
				elseif code == KEY_ENTER
					@SelectWeapon!
			.UpdateFromMenu = (panel) ->
				pos = panel.HistoryPos
				num = panel.Menu\ChildCount!
			
				panel.Menu\ClearHighlights!
			
				if pos < 1 then pos = num
				elseif pos > num then pos = 1
			
				item = panel.Menu\GetChild pos
				panel.Menu\HighlightItem item
				panel.HistoryPos = pos
	
	FontRefreshRequired: =>
		titleFont = @GetConVarValue 'searcher_title_font'
		barFont = @GetConVarValue 'searcher_bar_font'
		barFontHeight = @GetFontHeight 'bar'
		detailsFont = @GetConVarValue 'searcher_details_font'
		detailsFontHeight = @GetFontHeight 'details'
		if @titleFont ~= titleFont or
		@barFont ~= barFont or @barFontHeight ~= barFontHeight or
		@detailsFont ~= detailsFont or @detailsFontHeight ~= detailsFontHeight
			@titleFont = titleFont
			@barFont = barFont
			@barFontHeight = barFontHeight
			@detailsFont = detailsFont
			@detailsFontHeight = detailsFontHeight
			true
		else false
	
	GetFontHeight: (arg) => ScreenScale @GetConVarValue "searcher_#{arg}_font_size"

	RefreshFonts: =>
		if @FontRefreshRequired!
			surface.CreateFont 'MWSAS.SearcherTitle', {
				font: @titleFont
				size: 20
			}
			surface.CreateFont 'MWSAS.Searcher', {
				font: @barFont
				size: @barFontHeight
			}
			surface.CreateFont 'MWSAS.SearcherDetails', {
				font: @detailsFont
				size: @detailsFontHeight
			}
	
	FillWeaponInfo: =>
		-- search string:
		-- <wpass2 name> tier:<tier> level:<level>
		@weaponInfo = {}
		ply = @ply
		for wep in *ply\GetWeapons!
			name = @GetWeaponName wep
			search = string.lower string.format '%s %s', wep\GetClass!, name
			tier = 1

			local wpass2Name, tier
			if (InsaneStats and InsaneStats\GetConVarValue 'wpass2_enabled')
				if wep.insaneStats_Modifiers
					wpass2Name = InsaneStats\GetWPASS2Name(wep) or name
					tier = wep.insaneStats_Tier or 1
					search = string.lower string.format '%s %s', wep\GetClass!, wpass2Name
				else wep\InsaneStats_MarkForUpdate!
		
			table.insert @weaponInfo, {:name, wpass2: wpass2Name, :search, :tier, :wep}
		
		table.sort @weaponInfo, (a, b) ->
			if a.tier ~= b.tier then a.tier > b.tier else a.name < b.name
	
	GetAutoComplete: (inputText) =>
		if inputText ~= ''
			if inputText[1] == '='
				compiled = CompileString 'return '..string.sub(inputText, 2), 'error', false
				if isfunction compiled
					setfenv compiled, @mathEnv
					success, ret = pcall compiled
					if success
						{{name: '='..tostring(ret), wpass2: ''}}
					else
						{{name: '=?', wpass2: ret}}
				else
					{{name: '=?', wpass2: compiled}}
			else
				-- inputText is split by spaces, then _ are converted into .
				inputText = string.PatternSafe string.lower inputText
				inputText = string.gsub inputText, '_', '.'

				matches = {}
				for weaponInfo in *@weaponInfo
					found = true
					for inputArg in string.gmatch inputText, '(%S+)'
						unless string.find weaponInfo.search, inputArg
							found = false
							break
					if found
						table.insert matches, weaponInfo
						if #matches >= 10 then break
				matches
	
	OpenAutoComplete: (panel, tab) =>
		panel.Menu = DermaMenu!
		panel.HistoryPos = 1
	
		startDrawTime = RealTime!
		wpass2Enabled = InsaneStats and InsaneStats\GetConVarValue 'wpass2_enabled'

		for i, v in ipairs tab
			opt = with panel.Menu\AddOption '', -> @SelectWeapon v.wep
				\SetFont 'MWSAS.Searcher'
				\SetTextInset 0, 0
				.Highlight = i == 1
				.Paint = (panel, w, h) ->
					outlineThickness = @GetConVarValue 'outline'
					isWep = IsValid v.wep
					rarityColor = @colors.selected
					local rarity
					if isWep and wpass2Enabled
						rarity = InsaneStats\GetWPASS2Rarity(v.wep) or -1
						rarityColor = InsaneStats\GetPhasedRarityColor rarity
					displayTime = RealTime! - startDrawTime

					if panel.Highlight
						draw.RoundedBox 4, 0, 0, w, h, rarityColor
					elseif panel.Hovered
						draw.RoundedBox 4, 0, 0, w, h, @colors.hovered

					x, y = panel\LocalToScreen!
					@DrawRarityText v.name, 'MWSAS.Searcher',
						outlineThickness, outlineThickness, w - outlineThickness * 2,
						color_white, displayTime, x, y
					if wpass2Enabled or not isWep
						@DrawRarityText v.wpass2, 'MWSAS.SearcherDetails',
							outlineThickness, @GetFontHeight('bar') + outlineThickness * 2,
							w - outlineThickness * 2,
							rarity or rarityColor, displayTime, x, y
				.PerformLayout = (panel, w, h) ->
					outlineThickness = @GetConVarValue 'outline'
					isWep = IsValid v.wep
					ySize = if wpass2Enabled or not isWep
						@GetFontHeight('bar') + @GetFontHeight('details') + outlineThickness * 3
					else
						@GetFontHeight('bar') + outlineThickness * 2
					panel\SetSize panel\GetParent!\GetWide!, ySize
				
					DButton.PerformLayout panel, w, h

		w, h = panel\GetSize!
		x, y = panel\LocalToScreen 0, h
		with panel.Menu
			\SetMinimumWidth w
			\Open x, y, true, panel
			\SetPos x, y
			\SetMaxHeight ScrH! - y - 10
			.Paint = (panel, w, h) -> draw.RoundedBox 4, 0, 0, w, h, @colors.normal
	
	SelectWeapon: (wep) =>
		ply = @ply
		@panel\Close!
		if IsValid wep
			input.SelectWeapon wep
			if @IsDebugLevel 2 then @Log 'Switching to %s!', tostring wep
			ply\EmitSound 'common/wpn_hudoff.wav', 0, 100, @GetConVarValue('volume') / 100
		else
			ply\EmitSound 'common/wpn_denyselect.wav', 0, 100, @GetConVarValue('volume') / 100

BasicDrawing\RegisterCVarsStatic 'miscellaneous', {
	{ref: 'debug', type: 'int', default: '0', min: 0, max: 3}
	{ref: 'outline', type: 'float', default: '2', min: 0, max: 100}
	{ref: 'outline_colorbleed', type: 'float', default: '0', min: 0, max: 100}
	{ref: 'volume', type: 'float', default: '25', min: 0, max: 100}
}

selector = WeaponSelector!
searcher = WeaponSearcher!

concommand.Add '+mwsas_wepsel', -> selector\Start!
concommand.Add '-mwsas_wepsel', -> selector\End!
concommand.Add 'mwsas_wepsearch', -> searcher\Start!

hook.Add 'AddToolMenuCategories', 'MWS&S', ->
	spawnmenu.AddToolCategory 'Utilities', 'MWS&S', '#mwsas'
	return

hook.Add 'PopulateToolMenu', 'MWS&S', BasicDrawing\PopulateToolMenu
