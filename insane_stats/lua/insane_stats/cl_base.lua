--local createdFonts = {}

local colors = {
	black_translucent = Color(0, 0, 0, 191),
	gray = Color(127, 127, 127),
	gray_translucent = Color(127, 127, 127, 191),
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

InsaneStats:RegisterClientConVar("hud_wepsel_volume", "insanestats_hud_wepsel_volume", "25", {
	display = "Weapon Selector Volume",
	desc = "Volume of sounds produced by the weapon selector.",
	type = InsaneStats.FLOAT, min = 1, max = 100
})
InsaneStats:RegisterClientConVar("hud_wepsel_nobounce", "insanestats_hud_wepsel_nobounce", "0", {
	display = "Weapon Sel. No Bounce", desc = "Stops weapon icons from bouncing.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_wepsel_tint", "insanestats_hud_wepsel_tint", "2", {
	display = "Weapon Selector Tint", desc = "Causes all non-scripted weapons to be tinted based on rarity. \z
	If 2, scripted weapons with the default icon will also be tinted. \z
	If 3, as many scripted weapon icons as possible will be tinted.",
	type = InsaneStats.INT, min = 0, max = 3
})
InsaneStats:RegisterClientConVar("hud_wepsel_alphabetic", "insanestats_hud_wepsel_alphabetic", "0", {
	display = "Weapon Selector Alphabetic", desc = "If above 0, weapon hotbar slots are ignored entirely, \z
	instead the first letter of the weapon name is used to group weapons into columns, \z
	with higher values of this ConVar causing more letters to be grouped into the same column.\n\z
	This option probably won't work well with non-alphabetic languages.",
	type = InsaneStats.INT, min = 0, max = 255
})
InsaneStats:RegisterClientConVar("hud_wepsel_sensitivity_x", "insanestats_hud_wepsel_sensitivity_x", "1.5", {
	display = "Weapon Sel. Horiz. Sensitivity",
	desc = "Makes the weapon selector more receptive to horizontal mouse movement.",
	type = InsaneStats.FLOAT, min = 1, max = 10
})
InsaneStats:RegisterClientConVar("hud_wepsel_sensitivity_y", "insanestats_hud_wepsel_sensitivity_y", "1.5", {
	display = "Weapon Sel. Vert. Sensitivity",
	desc = "Makes the weapon selector more receptive to vertical mouse movement.",
	type = InsaneStats.FLOAT, min = 1, max = 10
})
InsaneStats:RegisterClientConVar("hud_wepsel_wep_w", "insanestats_hud_wepsel_wep_w", "256", {
	display = "Weapon Sel. Weapon Width",
	desc = "Width of weapon icons in the weapon selector, in pixels. Changing this value is not recommended.",
	type = InsaneStats.FLOAT, min = 1, max = 10000
})
InsaneStats:RegisterClientConVar("hud_wepsel_wep_h", "insanestats_hud_wepsel_wep_h", "128", {
	display = "Weapon Sel. Weapon Height",
	desc = "Height of weapon icons in the weapon selector, in pixels. Changing this value is not recommended.",
	type = InsaneStats.FLOAT, min = 1, max = 10000
})
InsaneStats:RegisterClientConVar("hud_wepsel_wep_color", "insanestats_hud_wepsel_wep_color", "255 255 255 255", {
	display = "Weapon Sel. Default Color",
	desc = "Default color of non-scripted weapons in the weapon selector. \z
	AutoIcons weapon colors is approximately 255 237 13 255.",
	type = InsaneStats.STRING
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
local weaponSelectorChars = {
	weapon_smg1 = 'a',
	weapon_shotgun = 'b',
	weapon_crowbar = 'c',
	weapon_pistol = 'd',
	weapon_357 = 'e',
	weapon_crossbow = 'g',
	weapon_physgun = 'h',
	weapon_rpg = 'i',
	weapon_bugbait = 'j',
	weapon_frag = 'k',
	weapon_ar2 = 'l',
	weapon_physcannon = 'm',
	weapon_stunstick = 'n',
	weapon_slam = 'o'
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

local color_black_ui = Color(0, 0, 0, 223)
local color_gray_ui = Color(127, 127, 127, 223)
local oldWeaponH, autoiconsWarned
if IsValid(InsaneStats.WeaponSelectorWindow) then InsaneStats.WeaponSelectorWindow:Close() end
local function InitWeaponSelectorWindow()
	local selectedWeapon = nil
	local weaponW = InsaneStats:GetConVarValue("hud_wepsel_wep_w")
	local weaponH = InsaneStats:GetConVarValue("hud_wepsel_wep_h")
	local ply = LocalPlayer()
	local gapSize = 2
	local openTime = RealTime()
	local defaultWeaponIconID = surface.GetTextureID("weapons/swep")

	-- remember the default weapon drawing function
	-- if this compares equal to another weapon's drawing function,
	-- then it's safe to be overridden by our own
	local defaultWeaponSelectionFunc = weapons.GetStored("weapon_base").DrawWeaponSelection


	local Main = vgui.Create("DFrame")
	Main:SetSize(ScrW(), ScrH())
	Main:Hide()
	Main:SetTitle("")
	Main:ShowCloseButton(false)
	Main.Paint = nil
	Main.insaneStats_LastWeapons = {}
	Main.insaneStats_VSCs = {}
	Main.insaneStats_WeaponButtons = {}
	Main.insaneStats_CustomSlots = {}
	InsaneStats.WeaponSelectorWindow = Main
	function Main:DrawScrollingText(text, x, y, w, color, outlineThickness)
		surface.SetFont("InsaneStats.Medium")
		local nameExtraW = surface.GetTextSize(text) - w
		local nameScrollFactor = 1
		if nameExtraW > 0 then
			nameScrollFactor = (math.cos((RealTime() - openTime)/2)+1)/2
		end
		local nameScrollAmt = Lerp(nameScrollFactor, nameExtraW, 0)

		InsaneStats:DrawTextOutlined(text, 2, x - nameScrollAmt, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	end
	function Main:OnMousePressed(key)
		if key == MOUSE_RIGHT then
			selectedWeapon = nil
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

	local oldPerformLayout = Main.PerformLayout
	function Main:PerformLayout(...)
		if oldPerformLayout then oldPerformLayout(self, ...) end
		self:UpdateWeaponPositions()
	end
	
	local HorizontalSlidePanel = vgui.Create("DSizeToContents", Main)
	HorizontalSlidePanel:SetSizeY(false)
	HorizontalSlidePanel:StretchToParent(nil, 0, nil, 0)
	function HorizontalSlidePanel:OnCursorMoved()
		Main:OnWeaponSelected()
		return Main:UpdateWeaponPositions()
	end
	function HorizontalSlidePanel:Paint(x, y)
		surface.SetDrawColor(255, 0, 0, 0)
		surface.DrawRect(0, 0, x, y)
	end
	function HorizontalSlidePanel:OnMousePressed(...)
		return Main:OnMousePressed(...)
	end
	Main.insaneStats_HSC = HorizontalSlidePanel
	
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
				) and rarityColor or string.ToColor(InsaneStats:GetConVarValue("hud_wepsel_wep_color"))
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
	function Main:DestructAndRebuildSelectors()
		for i,v in ipairs(self.insaneStats_VSCs) do
			v:Remove()
		end
		self.insaneStats_VSCs = {}
		self.insaneStats_WeaponButtons = {}
	
		local HorizontalSlidePanel = self.insaneStats_HSC
		
		local offsetX = 0
		for k,v in SortedPairs(self.insaneStats_LastWeapons) do
			local VerticalSlidePanel = vgui.Create("DSizeToContents", HorizontalSlidePanel)
			VerticalSlidePanel:SetWide(weaponW)
			VerticalSlidePanel:SetX(offsetX)
			VerticalSlidePanel:SetSizeX(false)
			VerticalSlidePanel.OnCursorMoved = function() return self:UpdateWeaponPositions() end
			VerticalSlidePanel.OnMousePressed = function(...) return self:OnMousePressed(...) end
			function VerticalSlidePanel:Paint(x, y)
				surface.SetDrawColor(255, 255, 0, 0)
				surface.DrawRect(0, 0, x, y)
			end
			table.insert(self.insaneStats_VSCs, VerticalSlidePanel)
	
			for k2,v2 in SortedPairsByValue(v) do
				local WeaponButton = vgui.Create("DButton", VerticalSlidePanel)
				WeaponButton:SetText("")
				WeaponButton:SetTall(weaponH)
				WeaponButton:Dock(TOP)
				WeaponButton.insaneStats_Weapon = k2
				table.insert(self.insaneStats_WeaponButtons, WeaponButton)

				function WeaponButton:Paint(w, h)
					local outlineThickness = InsaneStats:GetOutlineThickness()
					local tintMode = InsaneStats:GetConVarValue("hud_wepsel_tint")
					--[[if self.insaneStats_Selected then
						draw.RoundedBox(
							8, gapSize, gapSize, w-gapSize*2, h-gapSize*2,
							colors.white_translucent
						)
					end]]
					draw.RoundedBox(
						8, gapSize, gapSize, w-gapSize*2, h-gapSize*2,
						self.insaneStats_Selected and color_gray_ui or color_black_ui
					)
					local hasModifiers = InsaneStats:GetConVarValue("wpass2_enabled") and k2.insaneStats_Modifiers
					local rarityColor = hasModifiers and InsaneStats:GetRarityColor(InsaneStats:GetWPASS2Rarity(k2))
					or string.ToColor(InsaneStats:GetConVarValue("hud_wepsel_wep_color"))
					
					if k2.DrawWeaponSelection then
						local x, y = self:LocalToScreen()
						Main:DrawScriptedWeaponSelection(self.insaneStats_Selected, k2, rarityColor, x, y, w, h)
					elseif not k2:IsScripted() then
						local char = weaponSelectorChars[k2:GetClass()] or 'V'
						local weaponColor = tintMode > 0 and hasModifiers
						and InsaneStats:GetRarityColor(InsaneStats:GetWPASS2Rarity(k2))
						or string.ToColor(InsaneStats:GetConVarValue("hud_wepsel_wep_color"))
						draw.SimpleText(
							char, "InsaneStats.WeaponIcons", w/2, h/2, weaponColor,
							TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
						)
						draw.SimpleText(
							char, "InsaneStats.WeaponIconsBackground", w/2, h/2, weaponColor,
							TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
						)
					else
						local weaponColor = tintMode > 0 and rarityColor or string.ToColor(InsaneStats:GetConVarValue("hud_wepsel_wep_color"))
						InsaneStats:DrawTextOutlined(
							utf8.char(175, 92, 95, 40, 12484, 41, 95, 47, 175),
							3, w/2, h/2, weaponColor,
							TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
						)
					end

					local weaponDetails = {}
					local textX = gapSize+outlineThickness
					local textY = h-gapSize-outlineThickness
					local maxWidth = w-gapSize*2-outlineThickness*2

					if InsaneStats:GetConVarValue("wpass2_enabled") then
						if k2.insaneStats_Modifiers then
							table.insert(weaponDetails, "Tier "..k2.insaneStats_Tier)
						else
							k2:InsaneStats_MarkForUpdate()
						end
					end
					if InsaneStats:GetConVarValue("xp_enabled") then
						table.insert(weaponDetails, "Level "..InsaneStats:FormatNumber(k2:InsaneStats_GetLevel()))
					end
					
					local panelPosX, panelPosY = self:LocalToScreen()
					render.SetScissorRect(
						panelPosX + gapSize,
						panelPosY,
						panelPosX + w - gapSize,
						panelPosY + h,
						true
					)

					if next(weaponDetails) then
						Main:DrawScrollingText(
							table.concat(weaponDetails, ", "),
							textX, textY, maxWidth,
							color_white, outlineThickness
						)

						textY = textY - InsaneStats.FONT_MEDIUM - outlineThickness
					end

					if hasModifiers then
						Main:DrawScrollingText(
							InsaneStats:GetWPASS2Name(k2),
							textX, textY, maxWidth,
							rarityColor, outlineThickness
						)

						textY = textY - InsaneStats.FONT_MEDIUM - outlineThickness
					end

					Main:DrawScrollingText(
						v2,
						textX, textY, maxWidth,
						color_white, outlineThickness
					)
	
					render.SetScissorRect(0, 0, 0, 0, false)
				end

				WeaponButton.OnCursorMoved = function(panel)
					panel.insaneStats_Selected = true
					self:OnWeaponSelected(k2)
					VerticalSlidePanel:SetZPos(1)
					return self:UpdateWeaponPositions()
				end
				WeaponButton.OnWeaponDeselected = function(panel)
					panel.insaneStats_Selected = nil
				end
				WeaponButton.DoClick = function()
					self:Commit()
				end
				WeaponButton.DoRightClick = function()
					selectedWeapon = nil
					self:Commit()
				end
			end

			offsetX = offsetX + weaponW
		end
	end

	function Main:OnWeaponSelected(wep)
		if wep ~= selectedWeapon then
			selectedWeapon = wep
			if wep then
				ply:EmitSound("common/wpn_moveselect.wav", 0, 100, InsaneStats:GetConVarValue("hud_wepsel_volume") / 100)
			end

			local selectedColumn

			for i,v in ipairs(self.insaneStats_WeaponButtons) do
				if v.insaneStats_Weapon ~= wep then
					v:OnWeaponDeselected()
				else
					selectedColumn = v:GetParent()
				end
			end

			for i,v in ipairs(self.insaneStats_VSCs) do
				if v ~= selectedColumn then
					v:SetZPos(0)
				end
			end
		end
	end

	function Main:UpdateWeaponPositions()
		local xMax, yMax = self:GetSize()
		local hscW = self.insaneStats_HSC:GetWide()
		local sensitivityX = InsaneStats:GetConVarValue("hud_wepsel_sensitivity_x")
		local sensitivityY = InsaneStats:GetConVarValue("hud_wepsel_sensitivity_y")

		local leftBoundary = (sensitivityX - 1) / sensitivityX / 2 * xMax
		local rightBoundary = xMax - leftBoundary
		local upBoundary = (sensitivityY - 1) / sensitivityY / 2 * yMax
		local downBoundary = yMax - upBoundary

		local cursorX, cursorY = input.GetCursorPos()

		if hscW > rightBoundary - leftBoundary then
			local xPos = math.Remap(cursorX, leftBoundary, rightBoundary, leftBoundary, rightBoundary - hscW)
			self.insaneStats_HSC:SetX(xPos)
		else
			self.insaneStats_HSC:SetX((xMax - hscW) / 2)
		end

		for i,v in ipairs(self.insaneStats_VSCs) do
			local vscH = v:GetTall()
			if vscH > downBoundary - upBoundary then
				local yPos = math.Remap(cursorY, upBoundary, downBoundary, upBoundary, downBoundary - vscH)
				v:SetY(yPos)
			else
				v:SetY((yMax - vscH) / 2)
			end
		end
	end
	
	function Main:OnCursorMoved()
		self:OnWeaponSelected()
		self:UpdateWeaponPositions()
	end
	
	function Main:Refresh()
		selectedWeapon = nil
		local refreshRequired = false

		if oldWeaponH ~= InsaneStats:GetConVarValue("hud_wepsel_wep_h") then
			oldWeaponH = InsaneStats:GetConVarValue("hud_wepsel_wep_h")
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
		
		self.insaneStats_CustomSlots = {}
		for i,v in ipairs(InsaneStats.WeaponSelectorWeaponSlots) do
			self.insaneStats_CustomSlots[v[1]] = v[2]
		end

		self.insaneStats_LastWeapons = {}

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
			self.insaneStats_LastWeapons = {}
			
			for i,v in ipairs(ply:GetWeapons()) do
				local weaponSlot = self:GetWeaponSlot(v)
				self.insaneStats_LastWeapons[weaponSlot] = self.insaneStats_LastWeapons[weaponSlot] or {}
				self.insaneStats_LastWeapons[weaponSlot][v] = InsaneStats:GetWeaponName(v)
			end
	
			self:DestructAndRebuildSelectors()
		end

		ply:EmitSound("common/wpn_hudon.wav", 0, 100, InsaneStats:GetConVarValue("hud_wepsel_volume") / 100)
		openTime = RealTime()
		self:InvalidateLayout()
	end

	function Main:Commit()
		if self:IsVisible() then
			if IsValid(selectedWeapon) then
				input.SelectWeapon(selectedWeapon)
				ply:EmitSound("common/wpn_hudoff.wav", 0, 100, InsaneStats:GetConVarValue("hud_wepsel_volume") / 100)
			else
				ply:EmitSound("common/wpn_denyselect.wav", 0, 100, InsaneStats:GetConVarValue("hud_wepsel_volume") / 100)
			end

			self:Hide()
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
	InsaneStats.WeaponSelectorWindow:Commit()
end)