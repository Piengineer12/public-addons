--[[
flags:
1: crit
2: nick
4: miss
8: immune
16: ally
]]

function EFFECT:Init(effdata)
	local damage = effdata:GetMagnitude()
	local damageType = effdata:GetDamageType()
	local flags = effdata:GetFlags()
	local lifeTime = effdata:GetScale()
	local pos = effdata:GetOrigin()

	if damage < 0 then
		damage = -(damage^8)
	else
		damage = damage^8
	end

	local emitter = ParticleEmitter(pos)
	local particle = emitter:Add("effects/softglow", pos)
	local scatter = pos:DistToSqr(LocalPlayer():GetShootPos()) ^ 0.25 * 4-- + 8
	local gravity = physenv.GetGravity() * scatter / 256
	particle:SetAirResistance(0)
	particle:SetBounce(.5)
	particle:SetCollide(true)
	particle:SetDieTime(lifeTime)
	particle:SetEndAlpha(0)
	particle:SetGravity(gravity)
	particle:SetLighting(false)
	particle:SetNextThink(CurTime())
	particle:SetStartAlpha(0)
	particle:SetThinkFunction(function(particle)
		if IsValid(self) then
			self.pos = particle:GetPos()
			particle:SetNextThink(CurTime())
		end
	end)
	particle:SetVelocity(VectorRand(-scatter, scatter) - gravity / 2)
	emitter:Finish()

	self.pos = pos
	self.startTime = CurTime()
	self.dieTime = CurTime() + lifeTime
	self.damage = damage
	self.damageType = damageType
	self.crit = bit.band(flags, 1) ~= 0
	self.nick = bit.band(flags, 2) ~= 0
	self.miss = bit.band(flags, 4) ~= 0
	self.immune = bit.band(flags, 8) ~= 0
	self.ally = bit.band(flags, 16) ~= 0
end

function EFFECT:Think()
	return self.dieTime >= CurTime()
end

local gammaCVar
local function LerpColor(t, a, b)
	gammaCVar = gammaCVar or GetConVar("mat_monitorgamma")
	local gamma = gammaCVar:GetFloat()
	local invGamma = 1/gamma
	return Color(
		Lerp(t, a.r ^ gamma, b.r ^ gamma) ^ invGamma,
		Lerp(t, a.g ^ gamma, b.g ^ gamma) ^ invGamma,
		Lerp(t, a.b ^ gamma, b.b ^ gamma) ^ invGamma,
		Lerp(t, a.a ^ gamma, b.a ^ gamma) ^ invGamma
	)
end

function EFFECT:DrawDamageNumber(x, y)
	local outlineThickness = InsaneStats:GetOutlineThickness()
	local posX = x
	local posY = y

	-- determine the text
	local numberText
	local suffixText = ""
	if self.miss then
		numberText = "Miss!"
	elseif self.immune then
		numberText = "Immune!"
	else
		numberText, suffixText = InsaneStats:FormatNumber(
			math.Round(
				math.abs(self.damage),
				InsaneStats:GetConVarValue("hud_damage_decimals")
			),
			{separateSuffix = true, plus = self.damage < 0}
		)
	end

	-- determine number colors
	local numberColors = {}
	if self.miss or self.immune then
		numberColors = {InsaneStats:GetColor("red")}
	else
		local types = self.damageType
		if bit.band(types, bit.bor(DMG_SLASH)) ~= 0 then
			table.insert(numberColors, InsaneStats:GetColor("red"))
		end
		if bit.band(types, bit.bor(DMG_BURN, DMG_SLOWBURN, DMG_PHYSGUN)) ~= 0 then
			table.insert(numberColors, InsaneStats:GetColor("orange"))
		end
		if bit.band(types, bit.bor(DMG_BLAST, DMG_ALWAYSGIB, DMG_BLAST_SURFACE)) ~= 0 then
			table.insert(numberColors, InsaneStats:GetColor("yellow"))
		end
		if bit.band(types, bit.bor(DMG_PARALYZE, DMG_NERVEGAS, DMG_POISON, DMG_RADIATION, DMG_ACID)) ~= 0 then
			table.insert(numberColors, InsaneStats:GetColor("lime"))
		end
		if bit.band(types, bit.bor(DMG_DROWNRECOVER)) ~= 0 then
			table.insert(numberColors, InsaneStats:GetColor("green"))
		end
		if bit.band(types, bit.bor(DMG_SONIC, DMG_AIRBOAT, DMG_SNIPER, DMG_DISSOLVE)) ~= 0 then
			table.insert(numberColors, InsaneStats:GetColor("mint"))
		end
		if bit.band(types, bit.bor(DMG_DROWN, DMG_VEHICLE, DMG_REMOVENORAGDOLL)) ~= 0 then
			table.insert(numberColors, InsaneStats:GetColor("aqua"))
		end
		if bit.band(types, bit.bor(DMG_SHOCK)) ~= 0 then
			table.insert(numberColors, InsaneStats:GetColor("sky"))
		end
		if self.ally and self.damage > 0 then
			table.insert(numberColors, InsaneStats:GetColor("purple"))
		end
		if bit.band(types, bit.bor(DMG_ENERGYBEAM, DMG_PLASMA)) ~= 0 then
			table.insert(numberColors, InsaneStats:GetColor("magenta"))
		end
		if bit.band(types, bit.bor(DMG_FALL, DMG_DIRECT)) ~= 0 then
			table.insert(numberColors, InsaneStats:GetColor("gray"))
		end
		if table.IsEmpty(numberColors) then
			numberColors = {color_white}
		end
	end

	-- what is the maximum incremental number draw offset?
	surface.SetFont("InsaneStats.Medium")
	local maxOffsetX = surface.GetTextSize(numberText)
	-- what is the size of the whole text?
	local totalOffsetX = surface.GetTextSize(numberText..suffixText)
	
	-- draw number outline
	local textStartX = posX - totalOffsetX / 2
	local textDrawColors = {}
	local offsetX = 0
	for chr in string.gmatch(numberText, '.') do
		local blendFactor = (RealTime() / 2 + offsetX / maxOffsetX) % 1 * #numberColors
		local blendColor1 = numberColors[math.floor(blendFactor + 1)]
		local blendColor2 = numberColors[math.floor(blendFactor + 2)] or numberColors[1]
		local drawColor = LerpColor(math.EaseInOut(blendFactor % 1, 0.5, 0.5), blendColor1, blendColor2)

		table.insert(textDrawColors, {chr, drawColor})

		offsetX = offsetX + InsaneStats:DrawTextOutlined(
			chr, 2, textStartX + offsetX, posY,
			drawColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM,
			{outlineOnly = true}
		)
	end

	-- draw suffix outline
	local rainbowDrawColor = HSVToColor(RealTime() * 120 % 360, 1, 1)
	InsaneStats:DrawTextOutlined(
		suffixText, 2, textStartX + offsetX, posY,
		rainbowDrawColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM,
		{outlineOnly = true}
	)

	-- draw number
	offsetX = 0
	for i,v in ipairs(textDrawColors) do
		offsetX = offsetX + draw.SimpleText(
			v[1], "InsaneStats.Medium",
			textStartX + offsetX, posY,
			v[2], TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
		)
	end
	
	-- draw suffix
	draw.SimpleText(
		suffixText, "InsaneStats.Medium",
		textStartX + offsetX, posY,
		rainbowDrawColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
	)
	
	-- if crit, draw extra text
	if self.crit then
		InsaneStats:DrawTextOutlined(
			"Critical!", 2, posX, posY - InsaneStats.FONT_MEDIUM,
			InsaneStats:GetColor("red"), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		)
	elseif self.nick then
		InsaneStats:DrawTextOutlined(
			"Nick!", 2, posX, posY - InsaneStats.FONT_MEDIUM,
			InsaneStats:GetColor("gray"), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		)
	end
end

function EFFECT:Render()
	local toScreenData = self.pos:ToScreen()
	if toScreenData.visible then
		-- set the alpha
		local alpha = math.Remap(CurTime(), self.startTime, self.dieTime, 2, 0)
		cam.Start2D()
		surface.SetAlphaMultiplier(alpha)

		local success, err = pcall(self.DrawDamageNumber, self, toScreenData.x, toScreenData.y)

		surface.SetAlphaMultiplier(1)
		cam.End2D()

		if not success then error(err) end
	end
end