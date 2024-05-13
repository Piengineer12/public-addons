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
	elseif absNumber < (data.maximumBeforeShortening or 1e6) then
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

function InsaneStats:DrawMaterialOutlined(material, x, y, w, h, color, outlineThickness, outlineColor)
	surface.SetMaterial(material)
	-- draw the outline
	surface.SetDrawColor(outlineColor.r, outlineColor.g, outlineColor.b, outlineColor.a)
	
	local steps = outlineThickness * 2 / 3
	if steps < 1 then steps = 1 end

	for dx = -outlineThickness, outlineThickness, steps do
		for dy = -outlineThickness, outlineThickness, steps do
			surface.DrawTexturedRect(x + dx, y + dy, w, h)
		end
	end
	
	surface.SetDrawColor(color.r, color.g, color.b, color.a)
	return surface.DrawTexturedRect(x, y, w, h)
end

function InsaneStats:ShouldDrawHUD()
	return GetConVar("cl_drawhud"):GetBool() and GetConVar("hidehud"):GetInt() < 1
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
local allEntities = {}
local citizenSlowHealths = {}
timer.Create("InsaneStats", 1, 0, function()
	if scale ~= InsaneStats:GetConVarValue("hud_scale") or font ~= InsaneStats:GetConVarValue("hud_font") then
		scale = InsaneStats:GetConVarValue("hud_scale")
		font = InsaneStats:GetConVarValue("hud_font")
		GenerateFonts()
	end

	citizens = ents.FindByClass("npc_citizen")
	allEntities = ents.GetAll()

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
	if InsaneStats:GetConVarValue("hud_ally_enabled") and InsaneStats:ShouldDrawHUD() and hasSuit then
		local citizenCounts = {0, 0, 0}
		local outlineThickness = InsaneStats:GetConVarValue("hud_outline")
		
		for i,v in ipairs(citizens) do
			if (IsValid(v) and not v:IsDormant()) then
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
		for i,v in ipairs(allEntities) do
			if (IsValid(v) and not v:IsDormant() and v ~= ply) then
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
			local x = InsaneStats:GetConVarValue("hud_ally_x") * ScrW()
			local y = InsaneStats:GetConVarValue("hud_ally_y") * ScrH()

			draw.SimpleTextOutlined(
				"Allies:", "InsaneStats.Big", x, y,
				color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP,
				outlineThickness, color_black
			)
			y = y + InsaneStats.FONT_BIG + outlineThickness

			for i,v in ipairs(citizenCounts) do
				if v ~= 0 then
					InsaneStats:DrawMaterialOutlined(
						InsaneStats:GetIconMaterial(citizenIcons[i][1]),
						x, y,
						InsaneStats.FONT_BIG, InsaneStats.FONT_BIG,
						citizenIcons[i][2], outlineThickness, color_black
					)

					draw.SimpleTextOutlined(
						InsaneStats:FormatNumber(v), "InsaneStats.Big",
						x + InsaneStats.FONT_BIG + outlineThickness, y,
						color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP,
						outlineThickness, color_black
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

				draw.SimpleTextOutlined(
					v.name, "InsaneStats.Small",
					baseX, baseY - outlineThickness,
					v.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM,
					outlineThickness, color_black
				)

				if v.mhp > 0 then
					-- calculate properties for health and armor display
					local health = v.hp
					local ent = v.ent
					citizenSlowHealths[ent] = citizenSlowHealths[ent] or {}
					citizenSlowHealths[ent].hp = InsaneStats:TransitionUINumber(citizenSlowHealths[ent].hp or health, health)
					local barData = InsaneStats:CalculateMultibar(citizenSlowHealths[ent].hp, v.mhp, 120)
					local healthBars = barData.bars
					local barFrac = barData.frac
					local currentBarColor = barData.color
					local nextBarColor = barData.nextColor
					
					local barX = baseX - barW / 2
					local barY = baseY
					
					local currentHealthBarWidth = math.floor(barFrac > 0 and barW * barFrac or -outlineThickness)
					
					surface.SetDrawColor(0,0,0)
					surface.DrawRect(barX-outlineThickness, barY-outlineThickness, barW+outlineThickness*2, barH+outlineThickness*2)
					surface.SetDrawColor(nextBarColor.r, nextBarColor.g, nextBarColor.b, nextBarColor.a)
					surface.DrawRect(barX, barY, barW, barH)
					surface.SetDrawColor(currentBarColor.r, currentBarColor.g, currentBarColor.b, currentBarColor.a)
					surface.DrawRect(barX, barY, currentHealthBarWidth, barH)
					surface.SetDrawColor(0,0,0)
					surface.DrawRect(barX+currentHealthBarWidth, barY, outlineThickness, barH)
					
					-- armor
					if v.ar > 0 then
						barY = barY + barH + outlineThickness
						
						local armor = v.ar
						citizenSlowHealths[ent].ar = InsaneStats:TransitionUINumber(citizenSlowHealths[ent].ar or armor, armor)
						local barData = InsaneStats:CalculateMultibar(citizenSlowHealths[ent].ar, v.mar, 180)
						local armorBars = barData.bars
						local barFrac = barData.frac
						local currentBarColor = barData.color
						local nextBarColor = barData.nextColor
						
						local currentArmorBarWidth = math.floor(barFrac > 0 and barW * barFrac or -outlineThickness)
					
						surface.SetDrawColor(0,0,0)
						surface.DrawRect(barX-outlineThickness, barY-outlineThickness, barW+outlineThickness*2, barH+outlineThickness*2)
						surface.SetDrawColor(nextBarColor.r, nextBarColor.g, nextBarColor.b, nextBarColor.a)
						surface.DrawRect(barX, barY, barW, barH)
						surface.SetDrawColor(currentBarColor.r, currentBarColor.g, currentBarColor.b, currentBarColor.a)
						surface.DrawRect(barX, barY, currentArmorBarWidth, barH)
						surface.SetDrawColor(0,0,0)
						surface.DrawRect(barX+currentArmorBarWidth, barY, outlineThickness, barH)
					end
				end
				surface.SetAlphaMultiplier(1)
			end
		end
	end
end)

hook.Add("HUDShouldDraw", "InsaneStats", function(name)
	if InsaneStats:GetConVarValue("hud_ally_enabled") and name == "CHudSquadStatus" then return false end
end)
