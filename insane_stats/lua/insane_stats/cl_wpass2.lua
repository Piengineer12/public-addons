InsaneStats:SetDefaultConVarCategory("Weapon Prefixes and Suffixes System 2")

-- clients are allowed to choose the auto-pickup mode
InsaneStats:RegisterClientConVar("wpass2_autopickup_override", "insanestats_wpass2_autopickup_override", "-1", {
	display = "Auto Pickup Mode Override", desc = "If 0 or above, overrides insanestats_wpass2_autopickup for yourself.",
	type = InsaneStats.INT, min = -1, max = 6, userinfo = true
})
InsaneStats:RegisterClientConVar("wpass2_autopickup_battery_override", "insanestats_wpass2_autopickup_battery_override", "-1", {
	display = "Auto Battery Pickup Mode Override", desc = "If 0 or above, overrides insanestats_wpass2_autopickup_battery for yourself.",
	type = InsaneStats.INT, min = -1, max = 6, userinfo = true
})
InsaneStats:RegisterClientConVar("wpass2_equip_highest_tier", "insanestats_wpass2_equip_highest_tier", "0", {
	display = "Equip Highest Tiers", desc = "If above 0, causes picked up weapons to be immediately \z
	deployed if they are at least this many tiers higher than what's currently deployed.\n\z
	Consider setting cl_autowepswitch to 0 to disable the default weapon switching behavior, \z
	which does not consider tiers.",
	type = InsaneStats.INT, min = 0, max = 999, userinfo = true
})

InsaneStats:RegisterClientConVar("hud_wpass2_hold", "insanestats_hud_wpass2_hold", "10", {
	display = "Weapon Panel Hold Time", desc = "Amount of time to display weapon information.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterClientConVar("hud_wpass2_width", "insanestats_hud_wpass2_width", "0.33", {
	display = "Weapon Panel Width", desc = "Maximum width of weapon panels.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_wpass2_height", "insanestats_hud_wpass2_height", "0.14", {
	display = "Weapon Panel Height", desc = "Maximum height of weapon panels.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_wpass2_mode", "insanestats_hud_wpass2_mode", "0", {
	display = "Attribute Display Mode", desc = "Changes how attributes are displayed when there are too many to fit.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_wpass2_lootbeams", "insanestats_hud_wpass2_lootbeams", "1", {
	display = "Loot Beams", desc = "Shows loot beams for weapons and armor batteries that have modifiers.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_wpass2_lootbeams_extra", "insanestats_hud_wpass2_lootbeams_extra", "1", {
	display = "Extra Loot Beams", desc = "Shows loot beams for health kits, health vials and ammo.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_wpass2_attributes", "insanestats_hud_wpass2_attributes", "1", {
	display = "Attribute HUDs", desc = "Shows HUD elements added by WPASS2 attributes. Note that this system is also used by some skills.",
	type = InsaneStats.BOOL
})

InsaneStats:RegisterClientConVar("hud_wpass2_current_x", "insanestats_hud_wpass2_current_x", "0.66", {
	display = "Current Weapon Panel X", desc = "Horizontal position of current weapon panel.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_wpass2_current_y", "insanestats_hud_wpass2_current_y", "0.7", {
	display = "Current Weapon Panel Y", desc = "Vertical position of current weapon panel.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_wpass2_hovered_x", "insanestats_hud_wpass2_hovered_x", "0.66", {
	display = "Hovered Weapon Panel X", desc = "Horizontal position of hovered weapon panel.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_wpass2_hovered_y", "insanestats_hud_wpass2_hovered_y", "0.55", {
	display = "Hovered Weapon Panel Y", desc = "Vertical position of hovered weapon panel.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})

InsaneStats:RegisterClientConVar("hud_statuseffects_x", "insanestats_hud_statuseffects_x", "0.01", {
	display = "Status Effects X", desc = "Horizontal position of status effects.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_statuseffects_y", "insanestats_hud_statuseffects_y", "0.5", {
	display = "Status Effects Y", desc = "Vertical position of status effects.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_statuseffects_size", "insanestats_hud_statuseffects_size", "3", {
	display = "Status Effects Size", desc = "Size of status effects.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterClientConVar("hud_statuseffects_per_column", "insanestats_hud_statuseffects_per_column", "10", {
	display = "Status Effects Per Column", desc = "Having more than this number of status effects \z
	causes the display to be compressed. If set to -1, no display compression occurs.",
	type = InsaneStats.INT, min = -1, max = 100
})

local flagsDescriptions = {
	ARMOR = "Only For Armor Batteries (false = Only For Weapons)",
	XP = "Requires Experience Module",
	SCRIPTED_ONLY = "Only For Scripted Weapons",
	SP_ONLY = "Only For Singleplayer",
	SUIT_POWER = "Requires H.E.V. Suit",
	KNOCKBACK = "Requires Custom Knockback",
	MP_ONLY = "Only For Multiplayer"
}

concommand.Add("insanestats_wpass2_swap", function()
	net.Start("insane_stats")
	net.WriteUInt(3, 8)
	net.SendToServer()
end, nil,
"Swaps your current weapon / armor battery with whatever you're hovering over.")
concommand.Add("insanestats_wpass2_modifiers_show", function(ply, cmd, args, argStr)
	if next(args) then
		local modifierInfo = InsaneStats:GetAllModifiers()[argStr]
		if modifierInfo then
			InsaneStats:Log("Attributes:")
			local attributes = InsaneStats:DetermineWPASS2Attributes({[argStr] = 1})
			for i,v in ipairs(InsaneStats:GetAttributeOrder(attributes)) do
				local attributeText = InsaneStats:GetAttributeText(v, attributes[v])
				InsaneStats:Log("- %s", attributeText)
			end
			local maxStacks = modifierInfo.max and InsaneStats:FormatNumber(math.floor(modifierInfo.max)) or "infinity"
			InsaneStats:Log("Max Stacks: %s", maxStacks)
			InsaneStats:Log("Weight: %s", InsaneStats:FormatNumber(modifierInfo.weight or 1))
			local cost = modifierInfo.cost or 1
			InsaneStats:Log(
				"Modifier cost: %s (%s Modifier)", InsaneStats:FormatNumber(cost),
				cost > 0 and "Positive" or cost < 0 and "Negative" or "Neutral"
			)
			InsaneStats:Log("Flags:")
			local flags = modifierInfo.flags or 0
			for k,v in SortedPairsByValue(InsaneStats.WPASS2_FLAGS) do
				InsaneStats:Log("- %s: %s", flagsDescriptions[k], tostring(bit.band(flags, v) ~= 0))
			end
		else
			InsaneStats:Log(
				"Couldn't find modifier named \"%s\". \z
				Make sure to use the internal name, not the display name shown in brackets.",
				argStr
			)
		end
	else
		InsaneStats:Log("The list of every modifier is as follows:")
		for k,v in SortedPairs(InsaneStats:GetAllModifiers()) do
			if v.suffix then
				InsaneStats:Log("- %s (%s, %s)", k, v.prefix, v.suffix)
			elseif v.prefix then
				InsaneStats:Log("- %s (%s)", k, v.prefix)
			else
				InsaneStats:Log("- %s", k)
			end
		end
		InsaneStats:Log("Type insanestats_wpass2_modifiers_show <modifier> \z
		for more information about a particular modifier.")
	end
end, nil, "Shows a list of all registered WPASS2 modifiers, or detailed information about a specific one.")

--[[hook.Run("CCVCCMRun", "InsaneStatsWPASS", function()
	CCVCCM:SetAddon("insane_stats", "Insane Stats")
	CCVCCM:PushCategory("hud", "Client")
	CCVCCM:PushCategory("wpass2", "WPASS2")
	CCVCCM:AddConVar("autopickup_override", {
		realm = "client",
		name = "Auto Pickup Mode Override",
		help = "If 0 or above, overrides insanestats_wpass2_autopickup for yourself.",
		type = "int", default = -1,
		min = -1, max = 6,
		userInfo = true
	})
	CCVCCM:AddConVar("hold", {
		realm = "client",
		name = "Weapon Panel Hold Time",
		help = "Amount of time to display weapon information.",
		type = "float", default = 10,
		min = 0, max = 100
	})
end)]]

local rarityOffset = 5
local rarityNames = {
	"Worthless",
	"Garbage",
	"Trash",
	"Junk",
	"Common", -- this position - rarityOffset should be 0
	"Uncommon",
	"Rare",
	"Epic",
	"Superior",
	"Legendary",
	"Insane",
	"Galactic",
	"Monstrous",
	"Aetheric",
	"Mythical Common",
	"Mythical Uncommon",
	"Mythical Rare",
	"Mythical Epic",
	"Mythical Superior",
	"Mythical Legendary",
	"Mythical Insane",
	"Mythical Galactic",
	"Mythical Monstrous",
	"Mythical Aetheric",
	"Transcendent Common",
	"Transcendent Uncommon",
	"Transcendent Rare",
	"Transcendent Epic",
	"Transcendent Superior",
	"Transcendent Legendary",
	"Transcendent Insane",
	"Transcendent Galactic",
	"Transcendent Monstrous",
	"Transcendent Aetheric",
	"Transcendent Mythical Common",
	"Transcendent Mythical Uncommon",
	"Transcendent Mythical Rare",
	"Transcendent Mythical Epic",
	"Transcendent Mythical Superior",
	"Transcendent Mythical Legendary",
	"Transcendent Mythical Insane",
	"Transcendent Mythical Galactic",
	"Transcendent Mythical Monstrous",
	"Transcendent Mythical Aetheric",
	"Final Common",
	"Final Uncommon",
	"Final Rare",
	"Final Epic",
	"Final Superior",
	"Final Legendary",
	"Final Insane",
	"Final Galactic",
	"Final Monstrous",
	"Final Aetheric",
	"Final Mythical Common",
	"Final Mythical Uncommon",
	"Final Mythical Rare",
	"Final Mythical Epic",
	"Final Mythical Superior",
	"Final Mythical Legendary",
	"Final Mythical Insane",
	"Final Mythical Galactic",
	"Final Mythical Monstrous",
	"Final Mythical Aetheric",
	"Final Transcendent",
	"Rainbow"
}

local equippedWep
local panelDisplayDieTime = 0
local mouseOverDieTime = 0
local panelDisplayChangeTime = 0
local mouseOverChangeTime = 0
local oldXP, oldLevel, olderLevel = 0, 1, 1
local oldStatusEffects = {}
local color_light_red = InsaneStats:GetColor("light_red")
local color_light_yellow = InsaneStats:GetColor("light_yellow")
local color_light_green = InsaneStats:GetColor("light_green")
local color_light_aqua = InsaneStats:GetColor("light_aqua")
local color_light_blue = InsaneStats:GetColor("light_blue")
local color_light_magenta = InsaneStats:GetColor("light_magenta")
local baseHues = {120, 240, 270, 0, 30, 60, 90, 210, 180, 300}

local function CreateName(wep)
	local modifiers = InsaneStats:GetAllModifiers()
	local modifiersAscending = {}
	for k,v in SortedPairsByValue(wep.insaneStats_Modifiers) do
		table.insert(modifiersAscending, k)
	end
	
	local isWep = wep:IsWeapon()
	local name = isWep and InsaneStats:GetWeaponName(wep) or language.GetPhrase("item_battery")
	local lastSuffix = #modifiersAscending
	if lastSuffix % 2 == 0 then lastSuffix = lastSuffix - 1 end
	
	for i,v in ipairs(modifiersAscending) do
		local modifierInfo = modifiers[v]
		if modifierInfo then
			if i % 2 == 0 then
				name = modifierInfo.prefix .. ' ' .. name
			else
				local suffix = modifierInfo.suffix or modifierInfo.prefix
				if i == 1 then
					name = name .. " of " .. suffix
				elseif i == lastSuffix then
					name = name .. " and " .. suffix
				else
					name = name .. ", " .. suffix
				end
			end
		else
			InsaneStats:Log("Couldn't recognize modifier with ID \"%s\"!", v)
		end
	end
	
	local rarityDivide = InsaneStats:GetConVarValueDefaulted(not isWep and "wpass2_tier_raritycost_battery", "wpass2_tier_raritycost")
	local rarityTier = math.floor(wep.insaneStats_Tier/rarityDivide)
	rarityTier = math.Clamp(rarityTier, 1-rarityOffset, #rarityNames-rarityOffset)
	name = rarityNames[rarityTier+rarityOffset] .. ' ' .. name
	
	wep.insaneStats_AttributeOrder = InsaneStats:GetAttributeOrder(wep:InsaneStats_GetAttributes())
	wep.insaneStats_Rarity = rarityTier
	wep.insaneStats_WPASS2Name = name
	wep.insaneStats_WPASS2NameLastRefresh = RealTime()
	wep.insaneStats_BatteryLevel = math.floor(InsaneStats:GetLevelByXPRequired(wep:InsaneStats_GetBatteryXP()))
end

function InsaneStats:GetWPASS2Rarity(wep)
	if not wep.insaneStats_WPASS2Name or (wep.insaneStats_WPASS2NameLastRefresh or 0) + 5 < RealTime() then
		CreateName(wep)
	end

	return wep.insaneStats_Rarity
end

function InsaneStats:GetWPASS2Name(wep)
	if not wep.insaneStats_WPASS2Name or (wep.insaneStats_WPASS2NameLastRefresh or 0) + 5 < RealTime() then
		CreateName(wep)
	end

	return wep.insaneStats_WPASS2Name
end

function InsaneStats:GetAttributeOrder(attributes)
	local attribOrder = {}
	local attribOrderValues = {}
	for k,v in pairs(attributes or {}) do
		v = math.abs(v-1)
		--[[if v < 1 then
			v = 1/v
		end]]
		attribOrderValues[k] = v
	end
	
	for k,v in SortedPairsByValue(attribOrderValues, true) do
		table.insert(attribOrder, k)
	end

	return attribOrder
end

function InsaneStats:GetRarityColor(tier)
	local realTime = RealTime()
	if tier < 0 then
		local l = 255 / (1-tier)
		return Color(l, l, l)
	elseif tier == 0 then return color_white
	elseif tier > 60 then return HSVToColor(realTime * 120 % 360, 1, 1)
	else
		local hue = baseHues[ (tier-1)%10+1 ]
		local sat = 0.5
		local val = 1
		if tier > 40 then
			if tier > 50 then
				sat = math.abs(Lerp(realTime%1, -1, 1))
			end
			hue = (hue + math.ease.InOutCubic(realTime%3/3) * 360) % 360
		elseif tier > 20 then
			if tier > 30 then
				sat = math.abs(Lerp(realTime%1, -1, 1))
			else
				sat = 1
			end
			hue = (hue + math.abs(Lerp(realTime%2/2, -120, 120)) - 60) % 360
		elseif tier > 10 then
			sat = math.abs(Lerp(realTime%1, -1, 1))
		end
		
		return HSVToColor(hue, sat, val)
	end
end

function InsaneStats:GetAttributeText(attribute, value)
	local attribInfo = InsaneStats:GetAllAttributes()[attribute]
	local decimals = 1
	if value > 0 and value < 0.01 then
		decimals = math.floor(-math.log10(value))
	end
	local numberDisplay = InsaneStats:FormatNumber(
		(value-1) * (attribInfo.nopercent and 1 or 100),
		{
			plus = not attribInfo.noplus,
			decimals = decimals,
			distance = attribInfo.nopercent == "distance"
		}
	)..(attribInfo.nopercent and "" or "%")

	return string.format(attribInfo.display, numberDisplay)
end

--[[
drawing the weapon rarity needs to do these:
	1. do not draw text that would not be visible to save performance especially on long weapon names
	2. use the correct color for each drawn letter
in general, all colors symbolic of the rarity must be visible within the maximum rarity text width
]]
local function CalculateTriangleWaveValue(t, period, phase, min, max)
	return max + (min - max) * math.abs((t / period + phase) % 1 * 2 - 1)
end

function InsaneStats:GetPhasedRarityColor(tier, phase)
	-- phase ranges from 0 to 1
	phase = phase or 0

	local realTime = RealTime()
	if tier < 0 then
		local l = 255 / (1-tier)
		return Color(l, l, l)
	elseif tier == 0 then
		return color_white
	elseif tier > 60 then
		return HSVToColor((realTime * 120 + phase * 360) % 360, 1, 1)
	else
		local hue = baseHues[ (tier-1)%10+1 ]
		local sat = 0.5
		local val = 1
		if tier > 40 then
			if tier > 50 then
				sat = CalculateTriangleWaveValue(realTime, 1, phase * 2 + 0.5, 0, 1)
			end
			local t = (realTime/2+phase)%1
			hue = (hue + math.ease.InOutCubic(t) * 360) % 360
		elseif tier > 20 then
			if tier > 30 then
				sat = CalculateTriangleWaveValue(realTime, 1, phase * 2, 0, 1)
			else
				sat = 1
			end
			hue = (hue + CalculateTriangleWaveValue(realTime, 2, phase, -60, 60)) % 360
		elseif tier > 10 then
			sat = CalculateTriangleWaveValue(realTime, 1, phase, 0, 1)
		end
		
		return HSVToColor(hue, sat, val)
	end
end

local function SubstringBySize(text, startX, endX)
	--[[
	there are two binary searches here, this is your only warning

	for sake of example: 'terraformer'
	if 'terra' is enough to reach startX, save the number 5
	and if 'terraform' is enough to reach endX, save the number 9
	
	for startX:
	iL, iR = 1, 11
	iM is 6
	v < startX is false so iR = 6

	iL, iR = 1, 6
	iM is 3
	v < startX is true so iL = 4

	iL, iR = 4, 6
	iM is 5
	v < startX is false (it exceeds startX!) so iR = 5

	iL, iR = 4, 5
	iM is 4
	v < startX is true so iL = 5

	now that iL < iR is false, return iL (5)

	for endX:
	iL, iR = 1, 11
	iM is 6
	v > endX is false so iL = 7

	iL, iR = 7, 11
	iM is 9
	v > endX is true (it exceeds endX!) so iR = 9

	iL, iR = 7, 9
	iM is 8
	v > endX is false so iL = 9

	now that iL < iR is false, return iR (9)
	]]

	local textLength = #text--utf8.len(text)
	local stringSub = string.sub--utf8.sub

	local iL, iR = 1, textLength
	while iL < iR do
		local iM = math.floor((iL + iR) / 2)
		local substring = stringSub(text, 1, iM)
		local x = surface.GetTextSize(substring)
		if x < startX then
			iL = iM + 1
		else
			iR = iM
		end
	end
	local startTextIndex = iL

	iL, iR = 1, textLength
	while iL < iR do
		local iM = math.floor((iL + iR) / 2)
		local substring = stringSub(text, 1, iM)
		local x = surface.GetTextSize(substring)
		if x > endX then
			iR = iM
		else
			iL = iM + 1
		end
	end
	local endTextIndex = iR

	return startTextIndex, endTextIndex
end

function InsaneStats:DrawRarityText(text, size, x, y, w, tier, time, scissorX, scissorY)
	size = size or 2
	local outlineThickness = InsaneStats:GetOutlineThickness()
	local fontName = size == 3 and "InsaneStats.Big" or "InsaneStats.Medium"
	local stringSub = string.sub--utf8.sub
	scissorX = (scissorX or 0) + x - outlineThickness
	scissorY = (scissorY or 0) + y - outlineThickness
	surface.SetFont(fontName)

	-- how much space is overflowed by the text?
	local textTotalWidth, textTotalHeight = surface.GetTextSize(text)
	local nameExtraW = textTotalWidth - w
	local nameScrollFactor = 1
	if nameExtraW > 0 then
		nameScrollFactor = (math.cos(time/2)+1)/2
	end
	local nameScrollAmt = Lerp(nameScrollFactor, nameExtraW, 0)

	-- clip text to what's actually worth drawing
	local startIndex, endIndex = SubstringBySize(
		text,
		nameScrollAmt - outlineThickness,
		nameScrollAmt + w + outlineThickness
	)
	local undrawnX = surface.GetTextSize(stringSub(text, 1, startIndex - 1))
	local offsetX = undrawnX - nameScrollAmt
	local textX = x + offsetX

	-- clip drawing area
	render.SetScissorRect(
		scissorX,
		scissorY,
		scissorX + w + outlineThickness * 2,
		scissorY + textTotalHeight + outlineThickness * 2,
		true
	)

	-- draw, the endIndex+4 part is because of the possibility of truncated utf-8 sequences
	local chars = {}
	for _, code in utf8.codes(utf8.force(stringSub(text, startIndex, endIndex + 4))) do
		table.insert(chars, utf8.char(code))
	end
	
	local charData = {}
	local numberTier = tonumber(tier)
	for i, v in ipairs(chars) do
		local phase = (undrawnX + textX) / w
		local currentData = {
			x = textX,
			color = numberTier and InsaneStats:GetPhasedRarityColor(numberTier, phase) or tier
		}
		charData[i] = currentData
		
		textX = textX + InsaneStats:DrawTextOutlined(
			v, size, textX, y, currentData.color,
			TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, {outlineOnly = true}
		)
	end

	for i, v in ipairs(chars) do
		draw.SimpleText(v, fontName, charData[i].x, y, charData[i].color)
	end

	render.SetScissorRect(0, 0, 0, 0, false)
end

local function DrawWeaponPanel(panelX, panelY, wep, changeDuration, alphaMod, extra)
	local attributes = InsaneStats:GetAllAttributes()
	local textOffsetX, textOffsetY = 0, 0
	local maxW = ScrW() * InsaneStats:GetConVarValue("hud_wpass2_width")
	local maxH = ScrH() * InsaneStats:GetConVarValue("hud_wpass2_height")
	local maxY = panelY + maxH
	local typeText = wep:IsWeapon() and " Weapon" or " Battery"
	local outlineThickness = InsaneStats:GetOutlineThickness()
	extra = extra or {}
	
	panelY = panelY + outlineThickness
	
	surface.SetAlphaMultiplier(alphaMod)
	local name = wep:IsWeapon() and InsaneStats:GetWeaponName(wep) or language.GetPhrase("item_battery")
	local titleText = (extra.dropped and "Hovered " or "Current ")..name..":"
	textOffsetX, textOffsetY = InsaneStats:DrawTextOutlined(
		titleText, 2, panelX+outlineThickness, panelY,
		color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
	)
	panelY = panelY + textOffsetY + outlineThickness

	InsaneStats:DrawRarityText(
		InsaneStats:GetWPASS2Name(wep), 2,
		panelX + outlineThickness, panelY, maxW - outlineThickness * 2,
		InsaneStats:GetWPASS2Rarity(wep), changeDuration
	)
	panelY = panelY + InsaneStats.FONT_MEDIUM + outlineThickness
	
	local tierDisplay = "Tier "..wep.insaneStats_Tier..typeText
	if InsaneStats:GetConVarValue("xp_enabled") then
		if wep:IsPlayer() then
			tierDisplay = "Tier "..wep.insaneStats_Tier..", Level "..InsaneStats:FormatNumber(wep.insaneStats_BatteryLevel)..typeText
		else
			tierDisplay = "Tier "..wep.insaneStats_Tier..", Level "..InsaneStats:FormatNumber(wep:InsaneStats_GetLevel())..typeText
		end
	end
	textOffsetX, textOffsetY = InsaneStats:DrawTextOutlined(
		tierDisplay, 2, panelX+outlineThickness, panelY,
		color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
	)
	
	local levelDiff = extra.levelDiff
	if (levelDiff and levelDiff ~= 0) then
		local levelUpText = "Level up!"
		
		if levelDiff < 0 then
			levelUpText = "Level down!"
			levelDiff = -levelDiff
		end
		
		if levelDiff ~= 1 then
			levelUpText = levelUpText .. " x" .. InsaneStats:FormatNumber(levelDiff)
		end
		InsaneStats:DrawTextOutlined(
			levelUpText, 2, panelX+maxW-outlineThickness, panelY,
			color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP
		)
	end
	
	panelY = panelY + textOffsetY + outlineThickness

	if LocalPlayer():IsSuitEquipped() then
		if not wep.insaneStats_AttributeOrder then error(InsaneStats:GetWPASS2Name(wep), type(InsaneStats:GetWPASS2Name(wep))) end
		
		local textH = InsaneStats.FONT_SMALL + outlineThickness
		if InsaneStats:GetConVarValue("hud_wpass2_mode") then
			local maxLinesPerPage = math.floor((maxY - panelY) / textH)
			if maxLinesPerPage > 0 then
				local pages = math.ceil(#wep.insaneStats_AttributeOrder / maxLinesPerPage)
				local page0d = math.floor(changeDuration / math.pi % 1 * pages)
				local startLine = page0d * maxLinesPerPage + 1
				local endLine = (page0d + 1) * maxLinesPerPage
				local textY = panelY

				for i=startLine, math.min(endLine, #wep.insaneStats_AttributeOrder) do
					local attrib = wep.insaneStats_AttributeOrder[i]
					local attribValue = wep:InsaneStats_GetAttributes()[attrib]
					if not attribValue then
						PrintTable(wep:InsaneStats_GetAttributes())
					end
					local attribInfo = attributes[attrib]
					if not attribInfo then error(attrib) end
					
					local displayColor = (attribValue < 1 == tobool(attribInfo.invert)) and color_light_blue or color_light_red
					local attribDisplay = InsaneStats:GetAttributeText(attrib, attribValue)
					
					textY = textY + select(2, InsaneStats:DrawTextOutlined(
						attribDisplay, 1, panelX+outlineThickness, textY,
						displayColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
					))
				end
			end
		else
			local attribY1 = panelY
			local attribY2 = maxY
			local totalY = #wep.insaneStats_AttributeOrder * textH + outlineThickness
			local excessY = math.max(totalY + attribY1 - attribY2, 0)
			local holdTime = (attribY2 - attribY1) / textH / 2
			local pathDuration = holdTime + excessY / textH
			local animDuration = pathDuration * 2
			local animCurrent = changeDuration % animDuration
			
			local offsetY
			if animCurrent <= pathDuration or excessY == 0 then
				offsetY = math.min(math.Remap(animCurrent, holdTime, pathDuration, 0, -excessY), 0)
			else
				offsetY = math.max(math.Remap(animCurrent, pathDuration + holdTime, animDuration, -excessY, 0), -excessY)
			end
			
			render.SetScissorRect(panelX, panelY-outlineThickness, panelX+maxW, maxY, true)
			
			for i,v in ipairs(wep.insaneStats_AttributeOrder) do
				local textY = panelY + offsetY + (i-1) * textH
				-- don't bother if out of range
				if textY + textH > attribY1 and textY < attribY2 + outlineThickness then
					local attribValue = wep:InsaneStats_GetAttributes()[v]
					if not attribValue then
						PrintTable(wep:InsaneStats_GetAttributes())
					end
					local attribInfo = attributes[v]
					if not attribInfo then error(v) end
					
					local displayColor = (attribValue < 1 == tobool(attribInfo.invert)) and color_light_blue or color_light_red
					local attribDisplay = InsaneStats:GetAttributeText(v, attribValue)
					
					textOffsetX, textOffsetY = InsaneStats:DrawTextOutlined(
						attribDisplay, 1, panelX+outlineThickness, textY,
						displayColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
					)
				end
			end
			
			render.SetScissorRect(0, 0, 0, 0, false)
		end
	elseif next(wep.insaneStats_AttributeOrder) then
		InsaneStats:DrawTextOutlined(
			"(H.E.V. suit required for details)", 1, panelX+outlineThickness, panelY,
			color_light_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
		)
	end
	surface.SetAlphaMultiplier(1)
end

local statusEffectColors = {
	[-2] = color_light_magenta,
	[-1] = color_light_red,
	[0] = color_light_yellow,
	[1] = color_light_green,
	[2] = color_light_aqua
}

local function GetLookedAtWep(pos)
	local bestEntity = NULL
	local bestDistance = 1024
	for k,v in pairs(ents.FindInSphere(pos, 32)) do
		local distanceSquared = pos:DistToSqr(v:GetPos())
		if v:InsaneStats_IsWPASS2Pickup() and distanceSquared < bestDistance
		and not IsValid(v:GetOwner()) and v:GetClass() ~= "weapon_base" then
			bestEntity = v
			bestDistance = distanceSquared
		end
	end
	
	return bestEntity
end

hook.Add("InsaneStatsModifiersChanging", "InsaneStatsWPASS", function(ent, oldMods, newMods, modifierChangeReason)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		local ply = LocalPlayer()
		local modifiers = InsaneStats:GetAllModifiers()
		if oldMods and modifierChangeReason and (ent:IsWeapon() and ent:GetOwner() == ply or ent == ply) and ent:GetCreationTime() + 1 < CurTime() then
			for k,v in pairs(newMods) do
				local baseText
				
				if not oldMods[k] then
					baseText = "Your %s has gained the %s modifier!"
				elseif oldMods[k] < v then
					baseText = "Your %s has strengthened its %s modifier!"
				end
				
				if baseText then
					local entityName = ent:IsWeapon() and InsaneStats:GetWeaponName(ent) or language.GetPhrase("item_battery")
					local modifierName = modifiers[k] and (modifiers[k].suffix or modifiers[k].prefix) or k
					--notification.AddLegacy(string.format(baseText, entityName, modifierName), NOTIFY_GENERIC, 5)
					chat.AddText(string.format(baseText, entityName, modifierName))
				end
			end
		end
	end
end)

local lastLookedAtWep2
local lastLookedAtWepEntIndex
hook.Add("HUDPaint", "InsaneStatsWPASS", function()
	if (InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled"))
	and InsaneStats:ShouldDrawHUD() then
		local ply = LocalPlayer()
		local realTime = RealTime()
		local scrW = ScrW()
		local scrH = ScrH()
		local outlineThickness = InsaneStats:GetOutlineThickness()

		if InsaneStats:GetConVarValue("wpass2_enabled") then
			local wep = ply:KeyDown(IN_WALK) and ply or ply:GetActiveWeapon()
			local trace = ply:GetEyeTrace()
			
			if trace.Hit then
				local lookedAtWep = GetLookedAtWep(trace.HitPos)--ply:GetUseEntity()
				if (IsValid(lookedAtWep) and lookedAtWep:InsaneStats_IsWPASS2Pickup()) then
					if lastLookedAtWepEntIndex ~= lookedAtWep:EntIndex() then
						mouseOverChangeTime = realTime
						panelDisplayChangeTime = realTime
					end
					mouseOverDieTime = realTime + 1.1
					panelDisplayDieTime = realTime + InsaneStats:GetConVarValue("hud_wpass2_hold")
					lastLookedAtWep2 = lookedAtWep
					
					local lookClass = lookedAtWep:GetClass()
					
					if lookClass == "item_battery" then
						wep = ply
					elseif ply:HasWeapon(lookClass) then
						wep = ply:GetWeapon(lookedAtWep:GetClass())
					end
					
					lastLookedAtWepEntIndex = lookedAtWep:EntIndex()
				else
					lastLookedAtWepEntIndex = 0
				end
			else
				lastLookedAtWepEntIndex = 0
			end
			
			if IsValid(wep) then
				local level = wep:InsaneStats_GetLevel()
				if oldXP ~= wep:InsaneStats_GetXP() then
					if oldXP == 0 then
						olderLevel = level
					end
					oldXP = wep:InsaneStats_GetXP()
				end

				if equippedWep ~= wep:EntIndex() or oldLevel ~= level then
					oldLevel = level
					if equippedWep ~= wep:EntIndex() then
						equippedWep = wep:EntIndex()
						panelDisplayChangeTime = realTime
						olderLevel = level
					end
					panelDisplayDieTime = realTime + InsaneStats:GetConVarValue("hud_wpass2_hold") + 1
				end
				
				if wep.insaneStats_Modifiers then
					if panelDisplayDieTime > realTime then
						DrawWeaponPanel(
							scrW*InsaneStats:GetConVarValue("hud_wpass2_current_x"),
							scrH*InsaneStats:GetConVarValue("hud_wpass2_current_y"),
							wep,
							RealTime() - panelDisplayChangeTime,
							math.min(1, panelDisplayDieTime - realTime),
							{levelDiff = level - olderLevel}
						)
					else
						olderLevel = level
					end
				else
					wep:InsaneStats_MarkForUpdate()
				end
			end
			
			if IsValid(lastLookedAtWep2) then
				if lastLookedAtWep2.insaneStats_Modifiers then
					if mouseOverDieTime > realTime then
						DrawWeaponPanel(
							scrW*InsaneStats:GetConVarValue("hud_wpass2_hovered_x"),
							scrH*InsaneStats:GetConVarValue("hud_wpass2_hovered_y"),
							lastLookedAtWep2,
							RealTime() - mouseOverChangeTime,
							math.min(1, mouseOverDieTime - realTime),
							{dropped = true}
						)
					else
						lastLookedAtWep2 = nil
					end
				else
					lastLookedAtWep2:InsaneStats_MarkForUpdate()
				end
			end
		end
		
		if (ply.insaneStats_StatusEffects and next(ply.insaneStats_StatusEffects)) then
			local registeredEffects = InsaneStats:GetAllStatusEffects()
			local statusEffectOrder = {}
			local hasSuit = ply:IsSuitEquipped()
			for k,v in pairs(ply.insaneStats_StatusEffects) do
				oldStatusEffects[k] = oldStatusEffects[k] or {expiry = 0, lastChanged = 0}
				
				if v.expiry > CurTime() and v.level ~= 0 then
					table.insert(statusEffectOrder, k)
					
					if v.expiry ~= oldStatusEffects[k].expiry then
						oldStatusEffects[k] = {expiry = v.expiry, lastChanged = realTime}
					end
				end
			end
			table.sort(statusEffectOrder, function(a,b)
				local statusEffectA = ply.insaneStats_StatusEffects[a]
				local statusEffectB = ply.insaneStats_StatusEffects[b]
				
				if statusEffectA.expiry ~= statusEffectB.expiry then
					return statusEffectA.expiry > statusEffectB.expiry
				elseif statusEffectA.level ~= statusEffectB.level then
					return statusEffectA.level > statusEffectB.level
				else
					return a < b
				end
			end)
			
			local iconSize = InsaneStats.FONT_SMALL * InsaneStats:GetConVarValue("hud_statuseffects_size")
			local baseX = scrW * InsaneStats:GetConVarValue("hud_statuseffects_x")
			local baseY = scrH * InsaneStats:GetConVarValue("hud_statuseffects_y")

			local statusesPerColumn = InsaneStats:GetConVarValue("hud_statuseffects_per_column")
			statusesPerColumn = statusesPerColumn < 1 and 65536 or statusesPerColumn
			
			for i,v in ipairs(statusEffectOrder) do
				local statusEffectInfo = registeredEffects[v]
				local statusEffectData = ply.insaneStats_StatusEffects[v]
				local statusEffectColor = statusEffectColors[statusEffectInfo.typ]
				if oldStatusEffects[v].lastChanged + 1 > realTime then
					local lerpFactor = 0.75+(oldStatusEffects[v].lastChanged - realTime)*0.75
					statusEffectColor = Color(
						Lerp(lerpFactor, statusEffectColor.r, 255),
						Lerp(lerpFactor, statusEffectColor.g, 255),
						Lerp(lerpFactor, statusEffectColor.b, 255),
						statusEffectColor.a
					)
				end

				-- what column number is this status in? (0-indexed)
				local column = math.ceil(i / statusesPerColumn) - 1
	
				-- how many statuses are in this column?
				local columnStatusCount = math.min(#statusEffectOrder - column * statusesPerColumn, statusesPerColumn)

				-- what position in column is this status in? (0-indexed)
				local row = i - column * statusesPerColumn - 1

				local anchorX = baseX + column * (iconSize + outlineThickness)
				local anchorY = baseY + (row - (columnStatusCount-1)/2) * (iconSize + outlineThickness)

				InsaneStats:DrawMaterialOutlined(
					InsaneStats:GetIconMaterial(statusEffectInfo.img),
					anchorX, anchorY - iconSize/2, iconSize, iconSize,
					statusEffectColor
				)
				
				if #statusEffectOrder > statusesPerColumn or not hasSuit then
					local smallText
					if statusEffectData.level ~= 1 then
						smallText = InsaneStats:FormatNumber(statusEffectData.level, {compress = true, decimals = 1})
					elseif statusEffectData.expiry < math.huge then
						local duration = statusEffectData.expiry - CurTime()
						smallText = InsaneStats:FormatNumber(duration, {compress = true, decimals = 1}).."s"
					end

					if smallText then
						InsaneStats:DrawTextOutlined(
							smallText, 1, anchorX + iconSize, anchorY + iconSize / 2,
							statusEffectColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
						)
					end
				else
					local title = statusEffectInfo.name
					if statusEffectData.level ~= 1 then
						title = title .. " " .. InsaneStats:FormatNumber(statusEffectData.level)
					end
					anchorX = anchorX+iconSize+outlineThickness
					InsaneStats:DrawTextOutlined(
						title, 1,
						anchorX, anchorY - outlineThickness / 2,
						statusEffectColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
					)

					local durationText = InsaneStats:FormatNumber(statusEffectData.expiry - CurTime(), {decimals = 1}) .. (statusEffectData.expiry == math.huge and "" or "s")
					InsaneStats:DrawTextOutlined(
						durationText, 1,
						anchorX, anchorY + outlineThickness / 2,
						statusEffectColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
					)
				end
			end
		end
	end
end)

timer.Create("InsaneStatsWPASS", 1, 0, function()
	if InsaneStats:GetConVarValue("hud_wpass2_lootbeams") then
		for i,v in ipairs(ents.GetAll()) do
			if v:InsaneStats_IsWPASS2Pickup() and not IsValid(v:GetOwner()) and not v:IsDormant() then
				if v.insaneStats_Modifiers then
					local effData = EffectData()
					effData:SetEntity(v)
					util.Effect("insane_stats_tier", effData)
				else
					v:InsaneStats_MarkForUpdate()
				end
			elseif v:InsaneStats_GetHealingItemType() then
				local effData = EffectData()
				effData:SetEntity(v)
				util.Effect("insane_stats_tier", effData)
			end
		end
	end
end)