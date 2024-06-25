InsaneStats:SetDefaultConVarCategory("Infinite Health and Armor")

InsaneStats:RegisterClientConVar("hud_damage_enabled", "insanestats_hud_damage_enabled", "1", {
	display = "Damage Numbers", desc = "Shows the damage numbers.",
	type = InsaneStats.BOOL
})

InsaneStats:RegisterClientConVar("hud_dps_enabled", "insanestats_hud_dps_enabled", "1", {
	display = "DPS Meter", desc = "Shows the DPS meter.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_dps_x", "insanestats_hud_dps_x", "0.35", {
	display = "DPS Meter X", desc = "Horizontal position of DPS meter.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_dps_y", "insanestats_hud_dps_y", "0.94", {
	display = "DPS Meter Y", desc = "Vertical position of DPS meter.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_dps_time", "insanestats_hud_dps_time", "5", {
	display = "DPS Timer", desc = "Damage done after this amount of time will not be factored into the DPS.",
	type = InsaneStats.FLOAT, min = 0, max = 60
})

InsaneStats:RegisterClientConVar("hud_hp_enabled", "insanestats_hud_hp_enabled", "1", {
	display = "Health and Armor Meters", desc = "Shows the health meter. For the target info HUD, see the hud_target_enabled ConVar.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_hp_x", "insanestats_hud_hp_x", "0.01", {
	display = "Health and Armor Meters X", desc = "Horizontal position of health meter.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_hp_y", "insanestats_hud_hp_y", "0.98", {
	display = "Health and Armor Meters Y", desc = "Vertical position of health meter.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_hp_w", "insanestats_hud_hp_w", "16", {
	display = "Health and Armor Meters Width", desc = "Horizontal width of health meter.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})

local color_gray = InsaneStats:GetColor("gray")
local color_dark_red = InsaneStats:GetColor("dark_red")
local color_red = InsaneStats:GetColor("red")
local color_orange = InsaneStats:GetColor("orange")
local color_yellow = InsaneStats:GetColor("yellow")
local color_lime = InsaneStats:GetColor("lime")
local color_green = InsaneStats:GetColor("green")
local color_mint = InsaneStats:GetColor("mint")
local color_aqua = InsaneStats:GetColor("aqua")
local color_sky = InsaneStats:GetColor("sky")
local color_purple = InsaneStats:GetColor("purple")
local color_magenta = InsaneStats:GetColor("magenta")

local function LerpColor(t, a, b)
	return Color(
		Lerp(t, a.r, b.r),
		Lerp(t, a.g, b.g),
		Lerp(t, a.b, b.b),
		Lerp(t, a.a, b.a)
	)
end

local ourDamages = {}
-- table fields: damage, types, crit, time, origin, posX, posY
local allDamageNumbers = {}
local shouldUpdateDPS = false
hook.Add("InsaneStatsHUDDamageTaken", "InsaneStatsUnlimitedHealth", function(entIndex, attacker, damage, types, hitgroup, position, flags)
	local ply = LocalPlayer()
	if IsValid(ply) then
		allDamageNumbers[entIndex] = allDamageNumbers[entIndex] or {}
		
		local entityDamageNumbers = allDamageNumbers[entIndex]
		local requireNewAdd = true

		if ply:EntIndex() == entIndex then
			flags = bit.bor(flags, 4)
		end

		if next(entityDamageNumbers) then
			local latestEntDamage = entityDamageNumbers[#entityDamageNumbers]
			-- check whether the previous damage number should have elapsed
			if latestEntDamage.time + 1 > RealTime() then
				latestEntDamage.damage = latestEntDamage.damage + damage
				latestEntDamage.types = bit.bor(latestEntDamage.types, types)
				latestEntDamage.crit = latestEntDamage.crit or hitgroup == 1
				--latestEntDamage.time = RealTime()
				--latestEntDamage.origin = position
				latestEntDamage.flags = flags
				
				requireNewAdd = false
			end
		end
		
		if requireNewAdd and (ply:IsLineOfSightClear(position) or attacker == ply) then
			table.insert(entityDamageNumbers, {
				damage = damage,
				types = types,
				crit = hitgroup == 1,
				time = RealTime(),
				origin = position,
				flags = flags
			})
		end
		
		if attacker == ply and Entity(entIndex) ~= ply and not missed and damage > 0 then
			shouldUpdateDPS = true
			table.insert(ourDamages, {
				damage = damage,
				time = RealTime()
			})
		end
	end
end)

local function DrawDamageNumber(entityDamageInfo)
	local timeExisted = RealTime() - entityDamageInfo.time
	local outlineThickness = InsaneStats:GetConVarValue("hud_outline")
	
	-- set the alpha
	local alpha = 2 - timeExisted
	surface.SetAlphaMultiplier(alpha)
	
	local posX = entityDamageInfo.posX
	-- text floats at a rate of 2em/s
	local offsetY = timeExisted * InsaneStats.FONT_MEDIUM * -2
	local posY = entityDamageInfo.posY + offsetY
	
	-- determine outline color
	local outlineColor = color_black
	
	-- determine number colors
	local numberColors = {}
	local types = entityDamageInfo.types
	if bit.band(types, bit.bor(DMG_SLASH)) ~= 0 then
		table.insert(numberColors, color_red)
	end
	if bit.band(types, bit.bor(DMG_BURN, DMG_SLOWBURN, DMG_PHYSGUN)) ~= 0 then
		table.insert(numberColors, color_orange)
	end
	if bit.band(types, bit.bor(DMG_BLAST, DMG_ALWAYSGIB, DMG_BLAST_SURFACE)) ~= 0 then
		table.insert(numberColors, color_yellow)
	end
	if bit.band(types, bit.bor(DMG_PARALYZE, DMG_NERVEGAS, DMG_POISON, DMG_RADIATION, DMG_ACID)) ~= 0 then
		table.insert(numberColors, color_lime)
	end
	if bit.band(types, bit.bor(DMG_DROWNRECOVER)) ~= 0 then
		table.insert(numberColors, color_green)
	end
	if bit.band(types, bit.bor(DMG_SONIC, DMG_AIRBOAT, DMG_SNIPER, DMG_DISSOLVE)) ~= 0 then
		table.insert(numberColors, color_mint)
	end
	if bit.band(types, bit.bor(DMG_DROWN, DMG_VEHICLE, DMG_REMOVENORAGDOLL)) ~= 0 then
		table.insert(numberColors, color_aqua)
	end
	if bit.band(types, bit.bor(DMG_SHOCK)) ~= 0 then
		table.insert(numberColors, color_sky)
	end
	if bit.band(entityDamageInfo.flags, 4) ~= 0 and entityDamageInfo.damage > 0 then
		table.insert(numberColors, color_purple)
	end
	if bit.band(types, bit.bor(DMG_ENERGYBEAM, DMG_PLASMA)) ~= 0 then
		table.insert(numberColors, color_magenta)
	end
	if bit.band(types, bit.bor(DMG_FALL, DMG_DIRECT)) ~= 0 then
		table.insert(numberColors, color_gray)
	end
	if table.IsEmpty(numberColors) then
		numberColors = {color_white}
	end
	
	local numberText, suffixText = InsaneStats:FormatNumber(
		math.floor(math.abs(entityDamageInfo.damage)),
		{separateSuffix = true, plus = entityDamageInfo.damage < 0}
	)
	if bit.band(entityDamageInfo.flags, 3) ~= 0 and entityDamageInfo.damage == 0 then
		if bit.band(entityDamageInfo.flags, 2) ~= 0 then
			numberText = "Immune!"
		else
			numberText = "Miss!"
		end
		
		suffixText = ""
		numberColors = {color_red}
	end
	local offsetX = 0
	-- what is the maximum incremental number draw offset?
	surface.SetFont("InsaneStats.Medium")
	local maxOffsetX = surface.GetTextSize(numberText)
	-- what is the size of the whole text?
	local totalOffsetX = surface.GetTextSize(numberText..suffixText)
	
	local textStartX = posX - totalOffsetX / 2
	draw.SimpleTextOutlined(
		numberText..suffixText, "InsaneStats.Medium", textStartX, posY,
		color_transparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM,
		outlineThickness, outlineColor
	)
	
	for chr in string.gmatch(numberText, '.') do
		local blendFactor = (RealTime() / 2 + offsetX / maxOffsetX) % 1 * #numberColors
		local blendColor1 = numberColors[math.floor(blendFactor + 1)]
		local blendColor2 = numberColors[math.floor(blendFactor + 2)] or numberColors[1]
		local drawColor = LerpColor(math.EaseInOut(blendFactor % 1, 0.5, 0.5), blendColor1, blendColor2)
		
		offsetX = offsetX + draw.SimpleText(chr, "InsaneStats.Medium", textStartX + offsetX, posY, drawColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	end
	
	local drawColor = HSVToColor(RealTime() * 120 % 360, 1, 1)
	draw.SimpleText(suffixText, "InsaneStats.Medium", textStartX + offsetX, posY, drawColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	
	-- if crit, draw extra text
	if entityDamageInfo.crit then
		draw.SimpleTextOutlined(
			"Critical!", "InsaneStats.Medium", posX, posY - InsaneStats.FONT_MEDIUM,
			color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM,
			outlineThickness, outlineColor
		)
	end
end

--local dps = 1
local slowDamage = 0
local totalDamage = 0
local slowDPS = 0
local totalDPS = 0
local slowArmor = 0
local slowHealth = 0
hook.Add("HUDPaint", "InsaneStatsUnlimitedHealth", function()
	if InsaneStats:ShouldDrawHUD() then
		local scrW = ScrW()
		local scrH = ScrH()
		local ply = LocalPlayer()
		local hasSuit = ply:IsSuitEquipped()
		
		if InsaneStats:GetConVarValue("hud_damage_enabled") and hasSuit then
			cam.Start3D()
			for ent,entityDamageNumbers in pairs(allDamageNumbers) do
				local entriesToDelete = 0
				
				for k,entityDamageInfo in pairs(entityDamageNumbers) do
					if entityDamageInfo.time + 2 > RealTime() then
						entityDamageInfo.posX = nil
						entityDamageInfo.posY = nil
						
						if entityDamageInfo.origin then
							local toScreenData = entityDamageInfo.origin:ToScreen()
							
							if toScreenData.visible then
								entityDamageInfo.posX = toScreenData.x
								entityDamageInfo.posY = toScreenData.y
							end
						end
					else
						entriesToDelete = entriesToDelete + 1
					end
				end
				
				if entriesToDelete ~= 0 then
					for i,v in ipairs(entityDamageNumbers) do
						entityDamageNumbers[i] = entityDamageNumbers[i+entriesToDelete]
					end
				end
				
				--[[for i=1,entriesToDelete do
					table.remove(entityDamageNumbers, 1)
				end]]
			end
			cam.End3D()
			
			local plyIndex = ply:EntIndex()
			for ent,entityDamageNumbers in pairs(allDamageNumbers) do
				if ent ~= plyIndex then
					for i,entityDamageInfo in ipairs(entityDamageNumbers) do
						if entityDamageInfo.posX then
							DrawDamageNumber(entityDamageInfo)
						end
					end
				end
			end
			surface.SetAlphaMultiplier(1)
		end
		
		if InsaneStats:GetConVarValue("hud_dps_enabled") and hasSuit then
			local outlineThickness = InsaneStats:GetConVarValue("hud_outline")
			local discardTime = RealTime() - InsaneStats:GetConVarValue("hud_dps_time")
			if shouldUpdateDPS then
				totalDamage = 0
				local totalLatestDamage = 0
				--local entriesToDelete = 0
				local minTime = RealTime()
				local maxTime = 0
				
				for k,v in pairs(ourDamages) do
					totalDamage = totalDamage + v.damage
					
					if v.time > discardTime then
						totalLatestDamage = totalLatestDamage + v.damage
						minTime = math.min(minTime, v.time)
						maxTime = math.max(maxTime, v.time)
					end
					--[[else
						entriesToDelete = entriesToDelete + 1
					end]]
				end
				
				--[[if entriesToDelete ~= 0 then
					for i,v in ipairs(ourDamages) do
						ourDamages[i] = ourDamages[i+entriesToDelete]
					end
				end]]
				
				local entryFactor = #ourDamages > 1 and 1+1/(#ourDamages - 1) or 1
				local timeDifference = math.max((maxTime - minTime) * entryFactor, 1)
				totalDPS = totalLatestDamage / timeDifference
				shouldUpdateDPS = false
			end
			
			if next(ourDamages) then
				local life = ourDamages[#ourDamages].time - discardTime
				surface.SetAlphaMultiplier(life)
				
				if life > 0 then
					--dps = (dps - desiredDPS)/16384^RealFrameTime() + desiredDPS
					--dps = desiredDPS
					slowDamage = InsaneStats:TransitionUINumber(slowDamage, totalDamage)
					slowDPS = InsaneStats:TransitionUINumber(slowDPS, totalDPS)
					local formatString = "Total Damage: %s (%s%s/s)"
					local text = string.format(
						formatString,
						string.Comma(math.floor(slowDamage)),
						slowDamage > 0 and "+" or "",
						string.Comma(math.floor(slowDPS))
					)
					
					local x = scrW * InsaneStats:GetConVarValue("hud_dps_x")
					local y = scrH * InsaneStats:GetConVarValue("hud_dps_y")
					draw.SimpleTextOutlined(
						text, "InsaneStats.Big", x, y,
						color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM,
						outlineThickness, color_black
					)
				else
					ourDamages = {}
					slowDamage = 0
					slowDPS = 0
				end
				surface.SetAlphaMultiplier(1)
			end
		end
		
		if InsaneStats:GetConVarValue("hud_hp_enabled") then
			local baseX = scrW * InsaneStats:GetConVarValue("hud_hp_x")
			local baseY = scrH * InsaneStats:GetConVarValue("hud_hp_y")
			local barW = InsaneStats.FONT_MEDIUM * InsaneStats:GetConVarValue("hud_hp_w")
			local barH = InsaneStats.FONT_MEDIUM / 2
			local outlineThickness = InsaneStats:GetConVarValue("hud_outline")
			
			-- armor bar
			local armor = ply:InsaneStats_GetArmor()
			if armor > 0 then
				local maxArmor = ply:InsaneStats_GetMaxArmor()
				slowArmor = InsaneStats:TransitionUINumber(slowArmor, armor)
				
				local barData = InsaneStats:CalculateMultibar(slowArmor, maxArmor, 180)
				local bars = barData.bars
				local barColor = barData.color
				local nextColor = barData.nextColor
				local barFracWidth = math.floor(barData.frac > 0 and barW * barData.frac or -outlineThickness)
				
				surface.SetDrawColor(0, 0, 0)
				surface.DrawRect(
					baseX - outlineThickness,
					baseY - barH - outlineThickness,
					barW + outlineThickness * 2,
					barH + outlineThickness * 2
				)
				surface.SetDrawColor(nextColor.r, nextColor.g, nextColor.b, nextColor.a)
				surface.DrawRect(baseX, baseY - barH, barW, barH)
				surface.SetDrawColor(barColor.r, barColor.g, barColor.b, barColor.a)
				surface.DrawRect(baseX, baseY - barH, barFracWidth, barH)
				surface.SetDrawColor(0, 0, 0)
				surface.DrawRect(baseX + barFracWidth, baseY - barH, outlineThickness, barH)
				
				local text = InsaneStats:FormatNumber(math.Round(slowArmor)).." / "..InsaneStats:FormatNumber(math.Round(maxArmor))
				local offsetX, offsetY = draw.SimpleTextOutlined(
					"Shield", "InsaneStats.Medium", baseX, baseY - barH - outlineThickness,
					color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM,
					outlineThickness, color_black
				)
				if hasSuit then
					draw.SimpleTextOutlined(
						text, "InsaneStats.Medium", baseX + barW, baseY - barH - outlineThickness,
						barColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM,
						outlineThickness, color_black
					)
				end
				if slowArmor > maxArmor then
					draw.SimpleTextOutlined(
						"x"..InsaneStats:FormatNumber(bars), "InsaneStats.Medium", baseX + barW + outlineThickness, baseY,
						barColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM,
						outlineThickness, color_black
					)
				end
				baseY = baseY - barH - offsetY - outlineThickness * 2
			else
				slowArmor = armor
			end
			
			-- health bar
			local health = ply:InsaneStats_GetHealth()
			local maxHealth = ply:InsaneStats_GetMaxHealth()
			slowHealth = InsaneStats:TransitionUINumber(slowHealth, health)
				
			local barData = InsaneStats:CalculateMultibar(slowHealth, maxHealth, 120)
			local bars = barData.bars
			local barColor = barData.color
			local nextColor = barData.nextColor
			local barFracWidth = math.floor(barData.frac > 0 and barW * barData.frac or -outlineThickness)
			
			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(
				baseX - outlineThickness,
				baseY - barH - outlineThickness,
				barW + outlineThickness * 2,
				barH + outlineThickness * 2
			)
			surface.SetDrawColor(nextColor.r, nextColor.g, nextColor.b, nextColor.a)
			surface.DrawRect(baseX, baseY - barH, barW, barH)
			surface.SetDrawColor(barColor.r, barColor.g, barColor.b, barColor.a)
			surface.DrawRect(baseX, baseY - barH, barFracWidth, barH)
			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(baseX + barFracWidth, baseY - barH, outlineThickness, barH)
			
			local text = InsaneStats:FormatNumber(math.Round(slowHealth)).." / "..InsaneStats:FormatNumber(math.Round(maxHealth))
			draw.SimpleTextOutlined(
				"Health", "InsaneStats.Medium", baseX, baseY - barH - outlineThickness,
				color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM,
				outlineThickness, color_black
			)
			if hasSuit then
				draw.SimpleTextOutlined(
					text, "InsaneStats.Medium", baseX + barW, baseY - barH - outlineThickness,
					barColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM,
					outlineThickness, color_black
				)
			end
			if slowHealth > maxHealth then
				draw.SimpleTextOutlined(
					"x"..InsaneStats:FormatNumber(bars), "InsaneStats.Medium", baseX + barW + outlineThickness, baseY,
					barColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM,
					outlineThickness, color_black
				)
			end

			local entityDamageNumbers = allDamageNumbers[ply:EntIndex()]
			if entityDamageNumbers and hasSuit then
				local setPosX = baseX + barW / 2
				local setPosY = baseY - barH - InsaneStats.FONT_MEDIUM

				for i,entityDamageInfo in ipairs(entityDamageNumbers) do
					entityDamageInfo.posX = setPosX
					entityDamageInfo.posY = setPosY
					DrawDamageNumber(entityDamageInfo)
				end
				surface.SetAlphaMultiplier(1)
			end
		end
	end
end)

local shouldHide = {
	CHudHealth = true,
	CHudBattery = true
}
hook.Add("HUDShouldDraw", "InsaneStatsUnlimitedHealth", function(name)
	if InsaneStats:GetConVarValue("hud_hp_enabled") and shouldHide[name] then return false end
end)
