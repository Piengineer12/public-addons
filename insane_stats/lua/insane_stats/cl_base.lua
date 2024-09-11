--local createdFonts = {}

local colors = {
	black_translucent = Color(0, 0, 0, 191),
	gray = Color(127, 127, 127),
	light_gray = Color(191, 191, 191),
	white_translucent = Color(255, 255, 255, 191),
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
	if a == math.huge or b == math.huge or a == -math.huge or b == -math.huge then
		return b
	else
		return Lerp(1 - 2^(-14*RealFrameTime()), a, b)
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
			local rawStr = string.format("%"..plusStr.."."..decimalStr.."e", number)
			numberStr, suffixStr = string.match(rawStr, "^(%A*)(e.*)$")
		end
	elseif number == math.huge then
		numberStr = ""
		suffixStr = "∞"
	elseif number == -math.huge then
		numberStr = ""
		suffixStr = "-∞"
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
	if x == math.huge then
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
InsaneStats:RegisterClientConVar("hud_never_simplify", "insanestats_hud_never_simplify", "0", {
	display = "Don't Simplify Numbers", desc = "Disables numbers beyond 1 million being shown in simplified format. This only affects Insane Stats HUDs and GUIs.",
	type = InsaneStats.BOOL
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

			local barW = InsaneStats.FONT_SMALL * 4
			local barH = InsaneStats.FONT_SMALL / 2

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
		if InsaneStats:GetConVarValue("hud_ammo_enabled") and IsValid(wep) then
			local baseX = scrW * InsaneStats:GetConVarValue("hud_ammo_x")
			local baseY = scrH * InsaneStats:GetConVarValue("hud_ammo_y")
			local barW = InsaneStats.FONT_MEDIUM * InsaneStats:GetConVarValue("hud_ammo_w")
			local barH = InsaneStats.FONT_MEDIUM / 2
			local ammoMaxOverride = GetConVar("gmod_maxammo"):GetInt()
			ammoMaxOverride = ammoMaxOverride > 0 and ammoMaxOverride
			
			-- secondary bar
			local ammoType2 = wep:GetSecondaryAmmoType()
			if ammoType2 > 0 then
				-- format: (ammo / maxAmmo (reserve / maxReserve))
				local reserve2 = ply:GetAmmoCount(ammoType2)
				local maxReserve2 = ammoMaxOverride or game.GetAmmoMax(ammoType2)
				local useClip2 = wep:GetMaxClip2() > 0
				local ammo2 = useClip2 and wep:Clip2() or reserve2
				local maxAmmo2 = useClip2 and wep:GetMaxClip2() or maxReserve2
				
				local barData = InsaneStats:CalculateMultibar(ammo2, maxAmmo2, 120)
				local bars = barData.bars
				local barColor = barData.color

				if ammo2 < maxAmmo2 then
					barColor = HSVToColor(ammo2 / maxAmmo2 * 120, 0.75, 1)
				end
				
				InsaneStats:DrawRectOutlined(
					baseX - barW, baseY - barH,
					barW, barH,
					barData.frac, barColor, barData.nextColor
				)
				
				local ammoName = language.GetPhrase(
					string.format(
						"#%s_ammo",
						game.GetAmmoName(ammoType2)
					)
				)
				local offsetX, offsetY = InsaneStats:DrawTextOutlined(
					ammoName, 2, baseX - barW, baseY - barH - outlineThickness,
					color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
				)
				if hasSuit then
					local textY = baseY - barH - outlineThickness
					if useClip2 then
						local textPieces = {
							InsaneStats:FormatNumber(ammo2).." / "..InsaneStats:FormatNumber(maxAmmo2),
							"   |   ",
							InsaneStats:FormatNumber(reserve2).." / "..InsaneStats:FormatNumber(maxReserve2)
						}

						surface.SetFont("InsaneStats.Medium")
						local textX = baseX - surface.GetTextSize(table.concat(textPieces))
						local text3Color = HSVToColor(reserve2 / maxReserve2 * 120, 0.75, 1)

						textX = textX + InsaneStats:DrawTextOutlined(
							textPieces[1], 2, textX, textY,
							barColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
						)
						textX = textX + InsaneStats:DrawTextOutlined(
							textPieces[2], 2, textX, textY,
							color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
						)
						InsaneStats:DrawTextOutlined(
							textPieces[3], 2, textX, textY,
							text3Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
						)
					else
						local text = InsaneStats:FormatNumber(ammo2).." / "..InsaneStats:FormatNumber(maxAmmo2)
						InsaneStats:DrawTextOutlined(
							text, 2, baseX, baseY - barH - outlineThickness,
							barColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
						)
					end
				end
				if ammo2 > maxAmmo2 then
					InsaneStats:DrawTextOutlined(
						InsaneStats:FormatNumber(bars).."x", 2, baseX - barW - outlineThickness, baseY,
						barColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
					)
				end
				baseY = baseY - barH - offsetY - outlineThickness * 2
			end
			
			-- primary bar
			local ammoType1 = wep:GetPrimaryAmmoType()
			if ammoType1 > 0 then
				-- format: (ammo / maxAmmo (reserve / maxReserve))
				local reserve1 = ply:GetAmmoCount(ammoType1)
				local maxReserve1 = ammoMaxOverride or game.GetAmmoMax(ammoType1)
				local useClip1 = wep:GetMaxClip1() > 0
				local ammo1 = useClip1 and wep:Clip1() or reserve1
				local maxAmmo1 = useClip1 and wep:GetMaxClip1() or maxReserve1
				
				local barData = InsaneStats:CalculateMultibar(ammo1, maxAmmo1, 120)
				local bars = barData.bars
				local barColor = barData.color

				if ammo1 < maxAmmo1 then
					barColor = HSVToColor(ammo1 / maxAmmo1 * 120, 0.75, 1)
				end
				
				InsaneStats:DrawRectOutlined(
					baseX - barW, baseY - barH,
					barW, barH,
					barData.frac, barColor, barData.nextColor
				)
				
				local ammoName = language.GetPhrase(
					string.format(
						"#%s_ammo",
						game.GetAmmoName(ammoType1)
					)
				)
				InsaneStats:DrawTextOutlined(
					ammoName, 2, baseX - barW, baseY - barH - outlineThickness,
					color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
				)
				if hasSuit then
					local textY = baseY - barH - outlineThickness
					if useClip1 then
						local textPieces = {
							InsaneStats:FormatNumber(ammo1).." / "..InsaneStats:FormatNumber(maxAmmo1),
							"   |   ",
							InsaneStats:FormatNumber(reserve1).." / "..InsaneStats:FormatNumber(maxReserve1)
						}

						surface.SetFont("InsaneStats.Medium")
						local textX = baseX - surface.GetTextSize(table.concat(textPieces))
						local text3Color = HSVToColor(reserve1 / maxReserve1 * 120, 0.75, 1)

						textX = textX + InsaneStats:DrawTextOutlined(
							textPieces[1], 2, textX, textY,
							barColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
						)
						textX = textX + InsaneStats:DrawTextOutlined(
							textPieces[2], 2, textX, textY,
							color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
						)
						InsaneStats:DrawTextOutlined(
							textPieces[3], 2, textX, textY,
							text3Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
						)
					else
						local text = InsaneStats:FormatNumber(ammo1).." / "..InsaneStats:FormatNumber(maxAmmo1)
						InsaneStats:DrawTextOutlined(
							text, 2, baseX, baseY - barH - outlineThickness,
							barColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
						)
					end
				end
				if ammo1 > maxAmmo1 then
					InsaneStats:DrawTextOutlined(
						InsaneStats:FormatNumber(bars).."x", 2, baseX - barW - outlineThickness, baseY,
						barColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
					)
				end
			end
		end
	end
end)

hook.Add("HUDShouldDraw", "InsaneStats", function(name)
	if InsaneStats:GetConVarValue("hud_ally_enabled") and name == "CHudSquadStatus" then return false end
	if InsaneStats:GetConVarValue("hud_ammo_enabled") and (name == "CHudAmmo" or name == "CHudSecondaryAmmo") then return false end
end)

if IsValid(InsaneStats.WeaponSelectorWindow) then InsaneStats.WeaponSelectorWindow:Close() end
local function InitWeaponSelectorWindow()
	local weaponW, weaponH = 256, 128

	local Main = vgui.Create("DFrame")
	Main:SetSize(ScrW(), ScrH())
	Main:Hide()
	Main:SetTitle("")
	Main.Paint = nil
	Main.insaneStats_LastWeapons = {}
	Main.insaneStats_VerticalSlidePanels = {}
	InsaneStats.WeaponSelectorWindow = Main
	
	local HorizontalSlidePanel = vgui.Create("DSizeToContents", Main)
	HorizontalSlidePanel:SetSizeY(false)
	HorizontalSlidePanel:StretchToParent(nil, 0, nil, 0)
	function HorizontalSlidePanel:OnCursorMoved() return Main:OnCursorMoved() end
	Main.insaneStats_HorizontalSlidePanel = HorizontalSlidePanel
	
	function Main:DestructAndRebuildSelectors()
		for i,v in ipairs(self.insaneStats_VerticalSlidePanels) do
			v:Remove()
		end
		self.insaneStats_VerticalSlidePanels = {}
	
		local HorizontalSlidePanel = self.insaneStats_HorizontalSlidePanel
		
		local offsetX = 0
		for k,v in SortedPairs(self.insaneStats_LastWeapons) do
			local VerticalSlidePanel = vgui.Create("DSizeToContents", HorizontalSlidePanel)
			VerticalSlidePanel:SetWide(weaponW)
			VerticalSlidePanel:SetX(offsetX)
			VerticalSlidePanel:SetSizeX(false)
			VerticalSlidePanel.OnCursorMoved = function() return self:OnCursorMoved() end
			table.insert(self.insaneStats_VerticalSlidePanels, VerticalSlidePanel)
	
			local weaponHeight = math.max(ScrH() / table.Count(v), weaponH)
			for k2,v2 in SortedPairs(v) do
				local WeaponButton = vgui.Create("DButton", VerticalSlidePanel)
				WeaponButton:SetText(k2)
				WeaponButton:SetTall(weaponHeight)
				WeaponButton:Dock(TOP)
				WeaponButton.OnCursorMoved = function()
					self:OnWeaponSelected(k2)
					return self:OnCursorMoved()
				end
			end

			offsetX = offsetX + weaponW
		end
	end

	function Main:OnWeaponSelected(class)
		print(class)
	end
	
	function Main:OnCursorMoved()
		local xMax, yMax = self:GetSize()
		local cursorX, cursorY = input.GetCursorPos()
		local xFrac = cursorX / xMax
		local yFrac = cursorY / yMax
	
		-- the slider moves from 0 to xMax - slider size
		self.insaneStats_HorizontalSlidePanel:SetX(xFrac * (xMax - self.insaneStats_HorizontalSlidePanel:GetWide()))
		for i,v in ipairs(self.insaneStats_VerticalSlidePanels) do
			v:SetY(yFrac * (yMax - v:GetTall()))
		end
	end
	
	function Main:Refresh()
		local ply = LocalPlayer()
		local refreshRequired = false
		for i,v in ipairs(ply:GetWeapons()) do
			local weaponSlot = math.Clamp(v:GetSlot(), 0, 10)
			local slotTable = self.insaneStats_LastWeapons[weaponSlot]
			if not (slotTable and slotTable[v:GetClass()]) then
				refreshRequired = true break
			end
		end
	
		if not refreshRequired then
			for k,v in pairs(self.insaneStats_LastWeapons) do
				for k2,v2 in pairs(v) do
					if not ply:HasWeapon(k2) then
						refreshRequired = true break
					end
				end
			end
		end
	
		if refreshRequired then
			self.insaneStats_LastWeapons = {}
	
			for i,v in ipairs(ply:GetWeapons()) do
				local weaponSlot = math.Clamp(v:GetSlot(), 0, 10)
				self.insaneStats_LastWeapons[weaponSlot] = self.insaneStats_LastWeapons[weaponSlot] or {}
				self.insaneStats_LastWeapons[weaponSlot][v:GetClass()] = true
			end
	
			self:DestructAndRebuildSelectors()
		end
	end
end

concommand.Add("+insanestats_weapon_selector", function()
	if not IsValid(InsaneStats.WeaponSelectorWindow) then InitWeaponSelectorWindow() end
	InsaneStats.WeaponSelectorWindow:Show()
	InsaneStats.WeaponSelectorWindow:MakePopup()
	InsaneStats.WeaponSelectorWindow:Refresh()
end)
concommand.Add("-insanestats_weapon_selector", function()
	InsaneStats.WeaponSelectorWindow:Hide()
end)