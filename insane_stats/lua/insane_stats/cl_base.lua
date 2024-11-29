--local createdFonts = {}

local colors = {
	black_translucent = Color(0, 0, 0, 239),
	gray = Color(127, 127, 127),
	gray_translucent = Color(127, 127, 127, 239),
	light_gray = Color(191, 191, 191),
	dark_red = Color(127, 0, 0),
	red = Color(255, 0, 0),
	semilight_red = Color(255, 63, 63),
	light_red = Color(255, 127, 127),
	orange = Color(255, 127, 0),
	yellow = Color(255, 255, 0),
	light_yellow = Color(255, 255, 127),
	lime = Color(127, 255, 0),
	dark_green = Color(0, 127, 0),
	green = Color(0, 255, 0),
	light_green = Color(127, 255, 127),
	mint = Color(0, 255, 127),
	aqua = Color(0, 255, 255),
	light_aqua = Color(127, 255, 255),
	sky = Color(0, 127, 255),
	light_blue = Color(127, 127, 255),
	purple = Color(127, 0, 255),
	magenta = Color(255, 0, 255),
	light_magenta = Color(255, 127, 255)
}
InsaneStats.WeaponSelectorWeaponSlots = {}

--[[function InsaneStats:GetFont(size)
	local fontName = string.format("InsaneStats-%u", size)
	if not createdFonts[fontName] then
		surface.CreateFont(fontName, {
			font = "Orbitron Medium",
			size = ScreenScale(size)
		})
		
		createdFonts[fontName] = true
	end
	
	return fontName
end]]

function InsaneStats:GetWeaponName(wep)
	return language.GetPhrase(wep.PrintName ~= "" and wep.PrintName or wep:GetClass())
end

function InsaneStats:GetColor(color)
	return colors[color]
end

function InsaneStats:TransitionUINumber(a, b)
	local numSpeed = InsaneStats:GetConVarValue("hud_number_speed")
	if a == math.huge or b == math.huge or a == -math.huge or b == -math.huge or numSpeed <= 0 then
		return b
	else
		return Lerp(1 - math.exp(-numSpeed * RealFrameTime()), a, b)
	end
end

local order = {"M", "B", "T", "Q", "Qt", "Sx", "Sp", "Oc", "No", "De"--[[,
"Un", "Du", "Te", "Qtd", "Qid", "Sed", "Spd", "Ocd", "Nod", "Vig",
"Unv", "Duv", "Tiv", "Qtv", "Qiv", "Sev", "Spv", "Ocv", "Nov"]]}
function InsaneStats:FormatNumber(number, data)
	data = data or {}
	local plusStr = data.plus and number > 0 and "+" or ""
	local decimalPlaces = data.decimals or 3
	local decimalStr = string.format("%u", decimalPlaces)
	
	local numberStr = '?'
	local suffixStr = ""
	
	local absNumber = math.abs(number)
	if absNumber < 1e3 then
		numberStr = plusStr..string.Comma(math.Round(number, decimalPlaces))
	elseif absNumber < (data.maximumBeforeShortening or 1e6) or InsaneStats:GetConVarValue("hud_never_simplify") then
		numberStr = plusStr..string.Comma(math.floor(number))
	elseif absNumber < math.huge then
		local orderNeeded = math.floor(math.log10(absNumber)/3)-1
		if order[orderNeeded] then
			number = number / 1e3^(orderNeeded+1)
			
			numberStr = string.format("%"..plusStr.."."..decimalStr.."f", number)
			suffixStr = " "..order[orderNeeded]
		else
			local expStr = bit.band(InsaneStats:GetConVarValue("hud_exponent_format"), 2) == 0 and "e" or "E"
			local rawStr = string.format("%"..plusStr.."."..decimalStr..expStr, number)
			numberStr, suffixStr = string.match(rawStr, "^(%A*)("..expStr..".*)$")
		end
	elseif number == math.huge then
		numberStr = ""
		suffixStr = "∞"
	elseif number == -math.huge then
		numberStr = ""
		suffixStr = "-∞"
	end

	if bit.band(InsaneStats:GetConVarValue("hud_exponent_format"), 1) == 0 then
		suffixStr = suffixStr:Replace("+", "")
	end
	
	if data.separateSuffix then
		return numberStr, suffixStr
	else
		return numberStr..suffixStr
	end
end

function InsaneStats:RegisterClientConVar(name, internal, default, data)
	local conVar
	
	-- if it is of boolean type, only 0 and 1 values are allowed
	if data.type == self.BOOL then
		data.min = 0
		data.max = 1
	end
	
	if data.type == self.INT then
		conVar = CreateClientConVar(
			internal,
			default,
			true,
			data.userinfo,
			data.desc,
			data.min,
			data.max
		)
	else
		conVar = CreateClientConVar(
			internal,
			default,
			true,
			data.userinfo,
			data.desc
		)
	end
	
	self.numConVars = self.numConVars + 1
	
	local conVarData = {
		conVar = conVar,
		internal = internal,
		default = default,
		id = self.numConVars
	}
	table.Merge(conVarData, data)
	
	if not conVarData.category then
		conVarData.category = self:GetDefaultConVarCategory()
	end
	
	self.conVars[name] = conVarData
	
	return conVar
end

local icons = {}
function InsaneStats:GetIconMaterial(name)
	if not icons[name] then
		icons[name] = Material("insane_stats/"..name..".png", "mips smooth")
		if icons[name]:IsError() then
			icons[name] = Material("icon16/"..name..".png", "mips smooth")
		end
	end
	return icons[name]
end

local outlineThickness = 2
function InsaneStats:GetOutlineThickness()
	return outlineThickness
end

function InsaneStats:IntColor(color)
	return bit.bor(
		bit.lshift(math.floor(color.r), 16),
		bit.lshift(math.floor(color.g), 8),
		math.floor(color.b),
		bit.lshift(
			bit.band(
				bit.bnot(math.floor(color.a)), 255
			), 24
		)
	)
end

local outlineColorsCache = {}
local oldOutlineColorMul = 0
function InsaneStats:GetOutlineColor(color)
	local outlineColorMul = InsaneStats:GetConVarValue("hud_outline_colormul") / 100
	if outlineColorMul > 0 then
		if oldOutlineColorMul ~= outlineColorMul then
			outlineColorsCache = {}
		end

		local encoded = InsaneStats:IntColor(color)
		if not outlineColorsCache[encoded] then
			outlineColorsCache[encoded] = Color(
				color.r * outlineColorMul,
				color.g * outlineColorMul,
				color.b * outlineColorMul
			)
		end

		return outlineColorsCache[encoded]
	end

	return color_black
end

local fonts = {
	"InsaneStats.Small",
	"InsaneStats.Medium",
	"InsaneStats.Big"
}
function InsaneStats:DrawTextOutlined(text, size, x, y, color, alignX, alignY, data)
	data = data or {}
	local outlineColor = data.outlineColor or self:GetOutlineColor(color)

	if data.outlineOnly then color = color_transparent end

	if InsaneStats:GetConVarValue("hud_outline_mode") then
		for i=1, outlineThickness do
			draw.SimpleText(
				text, fonts[size], x + i, y + i,
				outlineColor, alignX, alignY
			)
		end

		return draw.SimpleText(
			text, fonts[size], x, y,
			color, alignX, alignY
		)
	else
		return draw.SimpleTextOutlined(
			text, fonts[size], x, y,
			color, alignX, alignY,
			outlineThickness, outlineColor
		)
	end
end

function InsaneStats:DrawMaterialOutlined(material, x, y, w, h, color)
	surface.SetMaterial(material)
	-- draw the outline
	local outlineColor = self:GetOutlineColor(color)
	surface.SetDrawColor(outlineColor.r, outlineColor.g, outlineColor.b, outlineColor.a)
	
	if InsaneStats:GetConVarValue("hud_outline_mode") then
		for i=1, outlineThickness do
			surface.DrawTexturedRect(x + i, y + i, w, h)
		end
	else
		local steps = outlineThickness * 2 / 3
		if steps < 1 then steps = 1 end

		for dx = -outlineThickness, outlineThickness, steps do
			for dy = -outlineThickness, outlineThickness, steps do
				surface.DrawTexturedRect(x + dx, y + dy, w, h)
			end
		end
	end
	
	surface.SetDrawColor(color.r, color.g, color.b, color.a)
	return surface.DrawTexturedRect(x, y, w, h)
end

function InsaneStats:DrawRectOutlined(x, y, w, h, frac, colorFG, colorBG)
	local newOutlines = InsaneStats:GetConVarValue("hud_outline_mode")

	local outlineColor = self:GetOutlineColor(colorBG)
	surface.SetDrawColor(outlineColor.r, outlineColor.g, outlineColor.b, outlineColor.a)
	if newOutlines then
		for i=1, outlineThickness do
			surface.DrawRect(x + i, y + i, w, h)
		end
	else
		surface.DrawRect(
			x - outlineThickness,
			y - outlineThickness,
			w + outlineThickness*2,
			h + outlineThickness*2
		)
	end

	surface.SetDrawColor(colorBG.r, colorBG.g, colorBG.b, colorBG.a)
	surface.DrawRect(x, y, w, h)

	if frac > 0 then
		outlineColor = self:GetOutlineColor(colorFG)
		surface.SetDrawColor(outlineColor.r, outlineColor.g, outlineColor.b, outlineColor.a)
		if newOutlines then
			for i=1, outlineThickness do
				surface.DrawRect(x + i, y + i, w*frac, h)
			end
		else
			surface.DrawRect(
				x - outlineThickness,
				y - outlineThickness,
				w*frac + outlineThickness*2,
				h + outlineThickness*2
			)
		end

		surface.SetDrawColor(colorFG.r, colorFG.g, colorFG.b, colorFG.a)
		surface.DrawRect(x, y, w*frac, h)
	end
end

function InsaneStats:ShouldDrawHUD()
	return GetConVar("cl_drawhud"):GetBool() and GetConVar("hidehud"):GetInt() < 1
end

local color_gray = colors.gray
function InsaneStats:CalculateMultibar(x, mx, startHue)
	-- data: bars, frac, color, nextColor
	local data = {}
	local currentHue = startHue
	if x == math.huge or x > 0 and mx <= 0 then
		data.bars = math.huge
		data.frac = 1
		currentHue = RealTime()*120
	else
		data.bars = math.max(math.ceil(x / mx), 1)
		data.frac = x / mx - data.bars + 1
		currentHue = currentHue + (data.bars-1)*30
	end
	
	data.color = HSVToColor(currentHue % 360, 0.75, 1)
	if data.bars > 1 then
		data.nextColor = HSVToColor((currentHue - 30) % 360, 0.75, 1)
	else
		data.nextColor = color_gray
	end
	
	return data
end

function InsaneStats:GetAmmoColor(ammo, maxAmmo)
	if ammo == math.huge or ammo > 0 and maxAmmo <= 0 then
		return HSVToColor(RealTime() * 120 % 360, 0.75, 1)
	elseif ammo < maxAmmo or maxAmmo <= 0 then
		return HSVToColor(ammo / math.max(maxAmmo, 1) * 120, 0.75, 1)
	else
		local bars = math.max(math.ceil(ammo / maxAmmo), 1)
		return HSVToColor((bars+3) * 30 % 360, 0.75, 1)
	end
end

function InsaneStats:DrawAmmoText(ammoData, x, y, alignY, firstColorOverride)
	local clipData = ammoData[1]
	local reserveData = ammoData[2]
	local textPieces = {
		InsaneStats:FormatNumber(clipData[1])
		.." / "..(clipData[2] > 0 and InsaneStats:FormatNumber(clipData[2]) or '?')
	}
	local textColors = {firstColorOverride or self:GetAmmoColor(clipData[1], clipData[2])}

	if reserveData then
		table.insert(textPieces, "   |   ")
		table.insert(
			textPieces, 
			InsaneStats:FormatNumber(reserveData[1])
			.." / "..(reserveData[2] > 0 and InsaneStats:FormatNumber(reserveData[2]) or '?')
		)

		table.insert(textColors, color_white)
		table.insert(textColors, self:GetAmmoColor(reserveData[1], reserveData[2]))
	end

	surface.SetFont("InsaneStats.Medium")
	local textX = x - surface.GetTextSize(table.concat(textPieces))

	for i,v in ipairs(textPieces) do
		textX = textX + InsaneStats:DrawTextOutlined(
			v, 2, textX, y,
			textColors[i], TEXT_ALIGN_LEFT, alignY
		)
	end
end

InsaneStats:SetDefaultConVarCategory("Miscellaneous")

InsaneStats:RegisterClientConVar("hud_scale", "insanestats_hud_scale", "1", {
	display = "HUD Scale", desc = "Modifies HUD scale.",
	type = InsaneStats.FLOAT, min = 0.1, max = 10
})
InsaneStats:RegisterClientConVar("hud_font", "insanestats_hud_font", "Orbitron Medium", {
	display = "HUD Font", desc = "Modifies HUD font.",
	type = InsaneStats.STRING
})
InsaneStats:RegisterClientConVar("hud_outline", "insanestats_hud_outline", "2", {
	display = "HUD Outline", desc = "Modifies HUD outline width.",
	type = InsaneStats.INT, min = 0, max = 10
})
InsaneStats:RegisterClientConVar("hud_outline_colormul", "insanestats_hud_outline_colormul", "0", {
	display = "HUD Outline Color %", desc = "% of color retained in the outlines.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterClientConVar("hud_outline_mode", "insanestats_hud_outline_mode", "0", {
	display = "Alternative HUD Outlines", desc = "Outlines are rendered as shadows instead.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_number_speed", "insanestats_hud_number_speed", "20", {
	display = "HUD Number Speed", desc = "Modifies the number update speed. 0 will remove number animations altogether.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterClientConVar("hud_never_simplify", "insanestats_hud_never_simplify", "0", {
	display = "Don't Simplify Numbers", desc = "Disables numbers beyond 1 million being shown in simplified format. This only affects Insane Stats HUDs and GUIs.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_exponent_format", "insanestats_hud_exponent_format", "0", {
	display = "Exponent Format", desc = "Controls how to display the exponent indicator. \z
	One undecillion (10^36) will appear as:\n\z
	0: 1.000e36\n\z
	1: 1.000e+36\n\z
	2: 1.000E36\n\z
	3: 1.000E+36",
	type = InsaneStats.INT, min = 0, max = 3
})

InsaneStats:RegisterClientConVar("hud_ally_enabled", "insanestats_hud_ally_enabled", "0", {
	display = "Allies", desc = "Shows ally status displays.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_ally_x", "insanestats_hud_ally_x", "0.01", {
	display = "Allies Display X", desc = "Horizontal position of allies display.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_ally_y", "insanestats_hud_ally_y", "0.06", {
	display = "Allies Display Y", desc = "Vertical position of allies display.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_ally_w", "insanestats_hud_ally_w", "4", {
	display = "Allies Display Width", desc = "Horizontal width of allies display.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterClientConVar("hud_ally_h", "insanestats_hud_ally_h", "0.4", {
	display = "Allies Display Height", desc = "Vertical height of allies display.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterClientConVar("hud_ally_dist_min", "insanestats_hud_ally_dist_min", "512", {
	display = "Allies Display Distance Minimum", desc = "Minimum distance to see simplified ally status display.",
	type = InsaneStats.FLOAT, min = 0, max = 4096
})
InsaneStats:RegisterClientConVar("hud_ally_dist_opaque", "insanestats_hud_ally_dist_opaque", "256", {
	display = "Allies Display Distance Opaque", desc = "Allies closer than this will have their simplified ally status display be at full opacity.",
	type = InsaneStats.FLOAT, min = 0, max = 4096
})

InsaneStats:RegisterClientConVar("hud_ammo_enabled", "insanestats_hud_ammo_enabled", "1", {
	display = "Clip Meters", desc = "Shows the ammo meters. For the target info HUD, see the hud_target_enabled ConVar.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_ammo_x", "insanestats_hud_ammo_x", "0.99", {
	display = "Clip Meters X", desc = "Horizontal position of ammo meters.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_ammo_y", "insanestats_hud_ammo_y", "0.98", {
	display = "Clip Meters Y", desc = "Vertical position of ammo meters.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_ammo_w", "insanestats_hud_ammo_w", "16", {
	display = "Clip Meters Width", desc = "Horizontal width of ammo meters.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterClientConVar("hud_ammo_h", "insanestats_hud_ammo_h", "0.25", {
	display = "Clip Meters Height", desc = "Vertical height of ammo meters.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})

local ENT = FindMetaTable("Entity")

function ENT:InsaneStats_GetPrintName()
	local classDisplayName = language.GetPhrase(
		self.PrintName ~= "" and self.PrintName
		or self.insaneStats_Class
		or self:GetClass()
	)
	local mappingName = self.insaneStats_Name or ""
	classDisplayName = (self:InsaneStats_GetIsAlpha() and "Alpha " or "")..classDisplayName
	if mappingName == "" then return classDisplayName
	else return string.format("%s (%s)", classDisplayName, mappingName)
	end
end

local function GenerateFonts()
	local scale = InsaneStats:GetConVarValue("hud_scale")
	local font = InsaneStats:GetConVarValue("hud_font")

	InsaneStats.FONT_SMALL = ScreenScale(6 * scale)
	InsaneStats.FONT_MEDIUM = ScreenScale(8 * scale)
	InsaneStats.FONT_BIG = ScreenScale(12 * scale)
	
	surface.CreateFont("InsaneStats.Small", {
		font = font,
		size = InsaneStats.FONT_SMALL
	})
	surface.CreateFont("InsaneStats.Medium", {
		font = font,
		size = InsaneStats.FONT_MEDIUM
	})
	surface.CreateFont("InsaneStats.Big", {
		font = font,
		size = InsaneStats.FONT_BIG
	})
end

GenerateFonts() -- FIXME: is this really necessary?

local scale, font
local citizens = {}
local citizenSlowHealths = {}
timer.Create("InsaneStats", 1, 0, function()
	if scale ~= InsaneStats:GetConVarValue("hud_scale") or font ~= InsaneStats:GetConVarValue("hud_font") then
		scale = InsaneStats:GetConVarValue("hud_scale")
		font = InsaneStats:GetConVarValue("hud_font")
		GenerateFonts()
	end

	citizens = ents.FindByClass("npc_citizen")

	for k,v in pairs(citizenSlowHealths) do
		if not IsValid(k) then
			citizenSlowHealths[k] = nil
		end
	end
end)

-- MISC

local citizenIcons = {
	{"hospital-cross", colors.light_red},
	{"knapsack", colors.light_green},
	{"run", colors.light_blue}
}
hook.Add("HUDPaint", "InsaneStats", function()
	local ply = LocalPlayer()
	local hasSuit = ply:IsSuitEquipped()
	outlineThickness = InsaneStats:GetConVarValue("hud_outline")
	if InsaneStats:ShouldDrawHUD() and hasSuit then
		local scrW = ScrW()
		local scrH = ScrH()

		if InsaneStats:GetConVarValue("hud_ally_enabled") then
			local citizenCounts = {0, 0, 0}
			
			for i,v in ipairs(citizens) do
				if (IsValid(v) and not v:IsDormant() and v.insaneStats_Disposition ~= 1) then
					local citizenFlags = v.insaneStats_CitizenFlags
					if citizenFlags then
						if bit.band(citizenFlags, 4) ~= 0 then
							if bit.band(citizenFlags, 1) ~= 0 then
								citizenCounts[1] = citizenCounts[1] + 1
							elseif bit.band(citizenFlags, 2) ~= 0 then
								citizenCounts[2] = citizenCounts[2] + 1
							else
								citizenCounts[3] = citizenCounts[3] + 1
							end
						end
					else
						v:InsaneStats_MarkForUpdate()
					end
				end
			end

			local viewPoint = ply:GetShootPos()
			local minDistSqr = InsaneStats:GetConVarValue("hud_ally_dist_min")^2
			local opaqueDistSqr = InsaneStats:GetConVarValue("hud_ally_dist_opaque")^2
			local allyValues = {}
			cam.Start3D()
			for i,v in ents.Iterator() do
				if (IsValid(v) and not v:IsDormant()) and v ~= ply then
					local isAlly = false

					if v:IsNPC() then
						if v.insaneStats_Disposition then
							isAlly = v.insaneStats_Disposition == 3
						else
							v:InsaneStats_MarkForUpdate()
						end
					elseif v:IsPlayer() then
						isAlly = v:Team() == ply:Team()
					end

					if isAlly then
						local allyPos = v:WorldSpaceCenter()
						local distSqr = allyPos:DistToSqr(viewPoint)
						if distSqr < minDistSqr then
							local alphaRatio = math.Remap(distSqr, minDistSqr, opaqueDistSqr, 0, 1)^4
							alphaRatio = math.min(alphaRatio, 1)
							table.insert(allyValues, {
								name = v:IsPlayer() and v:Nick() or v:InsaneStats_GetPrintName(),
								hp = v:InsaneStats_GetHealth(),
								mhp = v:InsaneStats_GetMaxHealth(),
								ar = v:InsaneStats_GetArmor(),
								mar = v:InsaneStats_GetMaxArmor(),
								alpha = alphaRatio,
								ent = v,
								pos = allyPos:ToScreen(),
								color = v:IsPlayer() and team.GetColor(v:Team()) or color_white
							})
						end
					end
				end
			end
			cam.End3D()

			if citizenCounts[1] ~= 0 or citizenCounts[2] ~= 0 or citizenCounts[3] ~= 0 then
				local x = InsaneStats:GetConVarValue("hud_ally_x") * scrW
				local y = InsaneStats:GetConVarValue("hud_ally_y") * scrH

				InsaneStats:DrawTextOutlined(
					"Allies:", 3, x, y,
					color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
				)
				y = y + InsaneStats.FONT_BIG + outlineThickness

				for i,v in ipairs(citizenCounts) do
					if v ~= 0 then
						InsaneStats:DrawMaterialOutlined(
							InsaneStats:GetIconMaterial(citizenIcons[i][1]),
							x, y,
							InsaneStats.FONT_BIG, InsaneStats.FONT_BIG,
							citizenIcons[i][2]
						)

						InsaneStats:DrawTextOutlined(
							InsaneStats:FormatNumber(v), 3,
							x + InsaneStats.FONT_BIG + outlineThickness, y,
							color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
						)

						y = y + InsaneStats.FONT_BIG + outlineThickness
					end
				end
			end

			local barW = InsaneStats.FONT_SMALL * InsaneStats:GetConVarValue("hud_ally_w")
			local barH = InsaneStats.FONT_SMALL * InsaneStats:GetConVarValue("hud_ally_h")

			for i,v in ipairs(allyValues) do
				if v.pos.visible and IsValid(v.ent) then
					surface.SetAlphaMultiplier(v.alpha)
					local baseX = v.pos.x
					local baseY = v.pos.y

					InsaneStats:DrawTextOutlined(
						v.name, 1,
						baseX, baseY - outlineThickness,
						v.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
					)

					if v.mhp > 0 then
						-- calculate properties for health and armor display
						local health = v.hp
						local ent = v.ent
						citizenSlowHealths[ent] = citizenSlowHealths[ent] or {}
						citizenSlowHealths[ent].hp = InsaneStats:TransitionUINumber(citizenSlowHealths[ent].hp or health, health)
						local barData = InsaneStats:CalculateMultibar(citizenSlowHealths[ent].hp, v.mhp, 120)
						
						local barX = baseX - barW / 2
						local barY = baseY
						InsaneStats:DrawRectOutlined(barX, barY, barW, barH, barData.frac, barData.color, barData.nextColor)
						
						-- armor
						if v.ar > 0 then
							barY = barY + barH + outlineThickness
							
							local armor = v.ar
							citizenSlowHealths[ent].ar = InsaneStats:TransitionUINumber(citizenSlowHealths[ent].ar or armor, armor)
							local barData = InsaneStats:CalculateMultibar(citizenSlowHealths[ent].ar, v.mar, 180)
							InsaneStats:DrawRectOutlined(barX, barY, barW, barH, barData.frac, barData.color, barData.nextColor)
						end
					end
					surface.SetAlphaMultiplier(1)
				end
			end
		end

		local wep = ply:GetActiveWeapon()
		if InsaneStats:GetConVarValue("hud_ammo_enabled") then
			local baseX = scrW * InsaneStats:GetConVarValue("hud_ammo_x")
			local baseY = scrH * InsaneStats:GetConVarValue("hud_ammo_y")
			local barW = InsaneStats.FONT_MEDIUM * InsaneStats:GetConVarValue("hud_ammo_w")
			local barH = InsaneStats.FONT_MEDIUM * InsaneStats:GetConVarValue("hud_ammo_h")
			local ammoMaxOverride = GetConVar("gmod_maxammo"):GetInt()
			ammoMaxOverride = ammoMaxOverride > 0 and ammoMaxOverride

			-- tertiary bar
			local vehicle = ply:GetVehicle()
			local vehicleAmmoData = {0}
			if IsValid(vehicle) then
				if vehicle:InsaneStats_GetEntityData("buggy_charge") then
					local maxAmmo = game.GetAmmoMax(18)
					local timePassed = CurTime() - vehicle:InsaneStats_GetEntityData("buggy_charge_updated")
					local charge = vehicle:InsaneStats_GetEntityData("buggy_charge")
					+ vehicle:InsaneStats_GetEntityData("buggy_charge_rate") * timePassed

					vehicleAmmoData = {18, maxAmmo, math.Clamp(charge, 0, maxAmmo)}
				else
					vehicleAmmoData = vehicle.GetAmmo and {vehicle:GetAmmo()} or {0}
				end
			end
			local ammoType3 = vehicleAmmoData[1]
			if ammoType3 > 0 then
				local ammo3 = vehicleAmmoData[3]
				local maxAmmo3 = vehicleAmmoData[2] > 0 and vehicleAmmoData[2] or 100
				
				local barData = InsaneStats:CalculateMultibar(ammo3, maxAmmo3, 120)
				local bars = barData.bars
				local barColor = barData.color

				if bars == 1 then
					barColor = HSVToColor(barData.frac * 120, 0.75, 1)
				end
				
				InsaneStats:DrawRectOutlined(
					baseX - barW, baseY - barH,
					barW, barH,
					barData.frac, barColor, barData.nextColor
				)
				
				local ammoName = language.GetPhrase(
					string.format(
						"#%s_ammo",
						game.GetAmmoName(ammoType3)
					)
				)
				local offsetX, offsetY = InsaneStats:DrawTextOutlined(
					ammoName, 2, baseX - barW, baseY - barH - outlineThickness,
					color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
				)
				if hasSuit then
					local textY = baseY - barH - outlineThickness
					local text = InsaneStats:FormatNumber(math.floor(ammo3)).." / "..InsaneStats:FormatNumber(maxAmmo3)
					InsaneStats:DrawTextOutlined(
						text, 2, baseX, baseY - barH - outlineThickness,
						barColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
					)
				end
				if bars > 1 then
					InsaneStats:DrawTextOutlined(
						InsaneStats:FormatNumber(bars).."x", 2, baseX - barW - outlineThickness, baseY,
						barColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
					)
				end
				baseY = baseY - barH - offsetY - outlineThickness * 2
			end
			
			if IsValid(wep) then
				local customAmmoDisplay = wep.CustomAmmoDisplay and wep:CustomAmmoDisplay() or {}
				--[[
					weapons can behave very differently! the following should apply when displaying ammo:
					-1 ammo type, -1 max clip, -1 clip: don't display
					-1 ammo type, -1 max clip, has clip: clip / ?
					-1 ammo type, has max clip, ANY clip: clip / max clip
					virtual ammo type, -1 max clip, -1 clip: ammo type / ?
					virtual ammo type, -1 max clip, has clip: clip / ? | ammo type / ?
					virtual ammo type, has max clip, ANY clip: clip / max clip | ammo type / ?
					has ammo type, -1 max clip, -1 clip: ammo type / max ammo type
					has ammo type, -1 max clip, has clip: clip / ? | ammo type / max ammo type
					has ammo type, has max clip, ANY clip: clip / max clip | ammo type / max ammo type
				]]
				
				--if customAmmoDisplay.Draw ~= false then
					-- secondary bar
					local ammoType2 = wep:GetSecondaryAmmoType()
					local useAmmoType2 = ammoType2 > -1
					local reserve2 = tonumber(customAmmoDisplay.SecondaryAmmo or useAmmoType2 and ply:GetAmmoCount(ammoType2)) or -1
					local maxClip2 = tonumber(wep:GetMaxClip2()) or -1
					local clip2 = tonumber(customAmmoDisplay.SecondaryClip or wep:Clip2()) or -1
					local maxReserve2 = tonumber(ammoMaxOverride or useAmmoType2 and game.GetAmmoMax(ammoType2)) or -1
					local ammoUnits = {}
					if maxClip2 > -1 or clip2 > -1 then
						table.insert(ammoUnits, {clip2, maxClip2})
					end
					if reserve2 > -1 then
						table.insert(ammoUnits, {reserve2, maxReserve2})
					end
					if next(ammoUnits) then
						local clipData = ammoUnits[1]
						local barData = InsaneStats:CalculateMultibar(clipData[1], clipData[2], 120)
						local bars = barData.bars
						local barColor = barData.color

						if bars == 1 then
							barColor = HSVToColor(barData.frac * 120, 0.75, 1)
						end
						
						InsaneStats:DrawRectOutlined(
							baseX - barW, baseY - barH,
							barW, barH,
							barData.frac, barColor, barData.nextColor
						)
						
						local ammoName = useAmmoType2 and language.GetPhrase(
							string.format(
								"#%s_ammo",
								game.GetAmmoName(ammoType2)
							)
						) or "Secondary Ammo"
						local offsetX, offsetY = InsaneStats:DrawTextOutlined(
							ammoName, 2, baseX - barW, baseY - barH - outlineThickness,
							color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
						)
						if hasSuit then
							local textY = baseY - barH - outlineThickness
							InsaneStats:DrawAmmoText(ammoUnits, baseX, textY, TEXT_ALIGN_BOTTOM, barColor)
						end
						if bars > 1 then
							InsaneStats:DrawTextOutlined(
								InsaneStats:FormatNumber(bars).."x", 2, baseX - barW - outlineThickness, baseY,
								barColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
							)
						end

						baseY = baseY - barH - offsetY - outlineThickness * 2
					end
					
					-- primary bar
					local ammoType1 = wep:GetPrimaryAmmoType()
					local useAmmoType1 = ammoType1 > -1
					local reserve1 = tonumber(customAmmoDisplay.PrimaryAmmo or useAmmoType1 and ply:GetAmmoCount(ammoType1)) or -1
					local maxClip1 = tonumber(wep:GetMaxClip1()) or -1
					local clip1 = tonumber(customAmmoDisplay.PrimaryClip or wep:Clip1()) or -1
					local maxReserve1 = tonumber(ammoMaxOverride or useAmmoType1 and game.GetAmmoMax(ammoType1)) or -1
					ammoUnits = {}
					if maxClip1 > -1 or clip1 > -1 then
						table.insert(ammoUnits, {clip1, maxClip1})
					end
					if reserve1 > -1 then
						table.insert(ammoUnits, {reserve1, maxReserve1})
					end
					if next(ammoUnits) then
						local clipData = ammoUnits[1]
						local barData = InsaneStats:CalculateMultibar(clipData[1], clipData[2], 120)
						local bars = barData.bars
						local barColor = barData.color

						if bars == 1 then
							barColor = HSVToColor(barData.frac * 120, 0.75, 1)
						end
						
						InsaneStats:DrawRectOutlined(
							baseX - barW, baseY - barH,
							barW, barH,
							barData.frac, barColor, barData.nextColor
						)
						
						local ammoName = useAmmoType1 and language.GetPhrase(
							string.format(
								"#%s_ammo",
								game.GetAmmoName(ammoType1)
							)
						) or "Primary Ammo"
						local offsetX, offsetY = InsaneStats:DrawTextOutlined(
							ammoName, 2, baseX - barW, baseY - barH - outlineThickness,
							color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
						)
						if hasSuit then
							local textY = baseY - barH - outlineThickness
							InsaneStats:DrawAmmoText(ammoUnits, baseX, textY, TEXT_ALIGN_BOTTOM, barColor)
						end
						if bars > 1 then
							InsaneStats:DrawTextOutlined(
								InsaneStats:FormatNumber(bars).."x", 2, baseX - barW - outlineThickness, baseY,
								barColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
							)
						end
					end
				--end
			end
		end
	end
end)

hook.Add("HUDShouldDraw", "InsaneStats", function(name)
	if InsaneStats:GetConVarValue("hud_ally_enabled") and name == "CHudSquadStatus" then return false end
	if InsaneStats:GetConVarValue("hud_ammo_enabled") and (name == "CHudAmmo" or name == "CHudSecondaryAmmo") then return false end
end)