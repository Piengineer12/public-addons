--local createdFonts = {}

InsaneStats.FONT_SMALL = ScreenScale(6)
InsaneStats.FONT_MEDIUM = ScreenScale(8)
InsaneStats.FONT_BIG = ScreenScale(12)

surface.CreateFont("InsaneStats.Small", {
	font = "Orbitron Medium",
	size = InsaneStats.FONT_SMALL
})

surface.CreateFont("InsaneStats.Medium", {
	font = "Orbitron Medium",
	size = InsaneStats.FONT_MEDIUM
})

surface.CreateFont("InsaneStats.Big", {
	font = "Orbitron Medium",
	size = InsaneStats.FONT_BIG
})

local colors = {
	gray = Color(127, 127, 127),
	dark_red = Color(127, 0, 0),
	red = Color(255, 0, 0),
	semilight_red = Color(255, 63, 63),
	light_red = Color(255, 127, 127),
	orange = Color(255, 127, 0),
	yellow = Color(255, 255, 0),
	light_yellow = Color(255, 255, 127),
	lime = Color(127, 255, 0),
	green = Color(0, 255, 0),
	light_green = Color(127, 255, 127),
	marine = Color(0, 255, 127),
	aqua = Color(0, 255, 255),
	light_aqua = Color(127, 255, 255),
	sky = Color(0, 127, 255),
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

local order = {"M", "B", "T", "Q", "Qt", "Se", "Sp", "Oc", "No", "De", "Un", --[["Du", "Te", "Qtd", "Qid", "Sed", "Spd", "Ocd", "Nod", "Vig"]]}
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
	elseif absNumber < 1e36 then
		local orderNeeded = math.floor(math.log10(absNumber)/3)-1
		number = number / 1e3^(orderNeeded+1)
		
		numberStr = string.format("%"..plusStr.."."..decimalStr.."f", number)
		suffixStr = " "..order[orderNeeded]
	elseif absNumber < math.huge then
		local rawStr = string.format("%"..plusStr.."."..decimalStr.."e", number)
		
		numberStr, suffixStr = string.match(rawStr, "^(%A*)(e.*)$")
		--print(rawStr, numberStr, suffixStr)
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

--[[InsaneStats:SetDefaultConVarCategory("HUD")

InsaneStats:RegisterClientConVar("hud_outline", "insanestats_hud_outline", "1", {
	display = "Outline Thickness", desc = "Outline thickness of elements. A value of -1 disables outlines.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})]]