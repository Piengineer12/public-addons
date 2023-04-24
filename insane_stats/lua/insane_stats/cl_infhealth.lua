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

InsaneStats:RegisterClientConVar("hud_hp_enabled", "insanestats_hud_hp_enabled", "1", {
	display = "Health and Armor Meters", desc = "Shows the health meter. For the target info HUD, see the hud_target_enabled ConVar.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_hp_x", "insanestats_hud_hp_x", "0.01", {
	display = "Health and Armor Meters X", desc = "Horizontal position of DPS meter.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_hp_y", "insanestats_hud_hp_y", "0.98", {
	display = "Health and Armor Meters Y", desc = "Vertical position of DPS meter.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})

local color_gray = InsaneStats:GetColor("gray")
local color_dark_red = InsaneStats:GetColor("dark_red")
local color_red = InsaneStats:GetColor("red")
local color_orange = InsaneStats:GetColor("orange")
local color_yellow = InsaneStats:GetColor("yellow")
local color_lime = InsaneStats:GetColor("lime")
local color_green = InsaneStats:GetColor("green")
local color_marine = InsaneStats:GetColor("marine")
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
hook.Add("InsaneStatsHUDDamageTaken", "InsaneStats", function(entIndex, attacker, damage, types, hitgroup, position, flags)
	allDamageNumbers[entIndex] = allDamageNumbers[entIndex] or {}
	
	local missed = bit.band(flags, 1) ~= 0 and damage == 0
	local entityDamageNumbers = allDamageNumbers[entIndex]
	local requireNewAdd = Entity(entIndex) ~= LocalPlayer()
	if next(entityDamageNumbers) and requireNewAdd then
		local latestEntDamage = entityDamageNumbers[#entityDamageNumbers]
		-- check whether the previous damage number should have elapsed
		if latestEntDamage.time + 0.5 > RealTime() then
			latestEntDamage.damage = latestEntDamage.damage + damage
			latestEntDamage.types = bit.bor(latestEntDamage.types, types)
			latestEntDamage.crit = latestEntDamage.crit or hitgroup == 1
			--latestEntDamage.time = RealTime()
			--latestEntDamage.origin = position
			latestEntDamage.ally = bit.band(flags, 2) ~= 0
			latestEntDamage.miss = latestEntDamage.miss and missed
			
			requireNewAdd = false
		end
	end
	
	if requireNewAdd then
		table.insert(entityDamageNumbers, {
			damage = damage,
			types = types,
			crit = hitgroup == 1,
			time = RealTime(),
			origin = position,
			ally = isAlly,
			miss = missed
		})
	end
	
	if attacker == LocalPlayer() and not missed then
		shouldUpdateDPS = true
		table.insert(ourDamages, {
			damage = damage,
			time = RealTime()
		})
	end
end)

--local dps = 1
local slowDamage = 0
local totalDamage = 0
local slowDPS = 0
local totalDPS = 0
local slowArmor = 0
local slowHealth = 0
hook.Add("HUDPaint", "InsaneStats", function()
	local scrW = ScrW()
	local scrH = ScrH()
	
	if InsaneStats:GetConVarValue("hud_damage_enabled") then
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
		
		for ent,entityDamageNumbers in pairs(allDamageNumbers) do
			for k,entityDamageInfo in pairs(entityDamageNumbers) do
				if entityDamageInfo.posX then
					local timeExisted = RealTime() - entityDamageInfo.time
					
					-- set the alpha
					local alpha = 2 - timeExisted
					surface.SetAlphaMultiplier(alpha)
					
					local posX = entityDamageInfo.posX
					-- text floats at a rate of 2em/s
					local offsetY = timeExisted * -48
					local posY = entityDamageInfo.posY + offsetY
					
					-- determine outline color
					local outlineColor = color_black
					
					-- determine number colors
					local numberColors = {}
					local types = entityDamageInfo.types
					local ent = Entity(k)
					if bit.band(types, DMG_SLASH) ~= 0 then
						table.insert(numberColors, color_red)
					end
					if bit.band(types, bit.bor(DMG_BURN, DMG_ENERGYBEAM, DMG_SLOWBURN, DMG_PHYSGUN)) ~= 0 then
						table.insert(numberColors, color_orange)
					end
					if bit.band(types, bit.bor(DMG_BLAST, DMG_ALWAYSGIB, DMG_BLAST_SURFACE)) ~= 0 then
						table.insert(numberColors, color_yellow)
					end
					if bit.band(types, bit.bor(DMG_PARALYZE, DMG_NERVEGAS, DMG_POISON, DMG_RADIATION, DMG_ACID)) ~= 0 then
						table.insert(numberColors, color_lime)
					end
					if bit.band(types, DMG_DROWNRECOVER) ~= 0 then
						table.insert(numberColors, color_green)
					end
					if bit.band(types, bit.bor(DMG_SONIC, DMG_AIRBOAT, DMG_DISSOLVE, DMG_SNIPER)) ~= 0 then
						table.insert(numberColors, color_marine)
					end
					if bit.band(types, DMG_DROWN) ~= 0 then
						table.insert(numberColors, color_aqua)
					end
					if bit.band(types, DMG_SHOCK) ~= 0 then
						table.insert(numberColors, color_sky)
					end
					if entityDamageInfo.isAlly then
						table.insert(numberColors, color_purple)
					end
					if bit.band(types, bit.bor(DMG_REMOVENORAGDOLL, DMG_PLASMA)) ~= 0 then
						table.insert(numberColors, color_magenta)
					end
					if bit.band(types, bit.bor(DMG_FALL, DMG_DIRECT)) ~= 0 then
						table.insert(numberColors, color_gray)
					end
					if table.IsEmpty(numberColors) then
						numberColors = {color_white}
					end
					
					local numberText, suffixText = InsaneStats:FormatNumber(math.floor(entityDamageInfo.damage), {separateSuffix = true})
					if entityDamageInfo.miss then
						numberText = "Miss!"
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
					draw.SimpleTextOutlined(numberText..suffixText, "InsaneStats.Medium", textStartX, posY, color_transparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, outlineColor)
					
					for chr in string.gmatch(numberText, '.') do
						local blendFactor = (RealTime() / 2 + offsetX / maxOffsetX) % 1 * #numberColors
						local blendColor1 = numberColors[math.floor(blendFactor + 1)]
						local blendColor2 = numberColors[math.floor(blendFactor + 2)] or numberColors[1]
						local drawColor = LerpColor(math.EaseInOut(blendFactor % 1, 0.5, 0.5), blendColor1, blendColor2)
						
						offsetX = offsetX + draw.SimpleText(chr, "InsaneStats.Medium", textStartX + offsetX, posY, drawColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
					end
					
					local drawColor = HSVToColor(RealTime() * 180 % 360, 1, 1)
					draw.SimpleText(suffixText, "InsaneStats.Medium", textStartX + offsetX, posY, drawColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
					
					-- if crit, draw extra text
					if entityDamageInfo.crit then
						draw.SimpleTextOutlined("Critical!", "InsaneStats.Medium", posX, posY - InsaneStats.FONT_MEDIUM, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, outlineColor)
					end
				end
			end
		end
		surface.SetAlphaMultiplier(1)
	end
	
	if InsaneStats:GetConVarValue("hud_dps_enabled") then
		if shouldUpdateDPS then
			totalDamage = 0
			local totalLatestDamage = 0
			--local entriesToDelete = 0
			local minTime = RealTime()
			local maxTime = 0
			
			for k,v in pairs(ourDamages) do
				totalDamage = totalDamage + v.damage
				
				if v.time + 5 > RealTime() then
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
			--print(totalDamage, "over", timeDifference)
			totalDPS = totalLatestDamage / timeDifference
			shouldUpdateDPS = false
		end
		
		if next(ourDamages) then
			local life = ourDamages[#ourDamages].time - RealTime() + 10
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
				draw.SimpleTextOutlined(text, "InsaneStats.Big", x, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, color_black)
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
		local barW = InsaneStats.FONT_MEDIUM * 17
		local barH = InsaneStats.FONT_MEDIUM
		local ply = LocalPlayer()
		
		-- armor bar
		local armor = ply:InsaneStats_GetArmor()
		if armor > 0 then
			local maxArmor = ply:InsaneStats_GetMaxArmor()
			slowArmor = InsaneStats:TransitionUINumber(slowArmor, armor)
			
			local barData = InsaneStats:CalculateMultibar(slowArmor, maxArmor, 180)
			local barColor = barData.color
			local nextColor = barData.nextColor
			local barFracWidth = barData.frac > 0 and (barW - 4) * barData.frac or -2
			
			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(baseX, baseY - barH, barW, barH)
			surface.SetDrawColor(nextColor.r, nextColor.g, nextColor.b, nextColor.a)
			surface.DrawRect(baseX + 2, baseY - barH + 2, barW - 4, barH - 4)
			surface.SetDrawColor(barColor.r, barColor.g, barColor.b, barColor.a)
			surface.DrawRect(baseX + 2, baseY - barH + 2, barFracWidth, barH - 4)
			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(baseX + 2 + barFracWidth, baseY - barH + 2, 2, barH - 4)
			
			local text = InsaneStats:FormatNumber(math.Round(slowArmor)).." / "..InsaneStats:FormatNumber(math.Round(maxArmor))
			draw.SimpleTextOutlined("Shield", "InsaneStats.Medium", baseX + 2, baseY - barH, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, color_black)
			draw.SimpleTextOutlined(text, "InsaneStats.Medium", baseX + barW - 2, baseY - barH, barColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
			baseY = baseY - barH * 2
		end
		
		-- health bar
		local health = ply:InsaneStats_GetHealth()
		local maxHealth = ply:InsaneStats_GetMaxHealth()
		slowHealth = InsaneStats:TransitionUINumber(slowHealth, health)
			
		local barData = InsaneStats:CalculateMultibar(slowHealth, maxHealth, 120)
		local barColor = barData.color
		local nextColor = barData.nextColor
		local barFracWidth = barData.frac > 0 and (barW - 4) * barData.frac or -2
		
		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(baseX, baseY - barH, barW, barH)
		surface.SetDrawColor(nextColor.r, nextColor.g, nextColor.b, nextColor.a)
		surface.DrawRect(baseX + 2, baseY - barH + 2, barW - 4, barH - 4)
		surface.SetDrawColor(barColor.r, barColor.g, barColor.b, barColor.a)
		surface.DrawRect(baseX + 2, baseY - barH + 2, barFracWidth, barH - 4)
		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(baseX + 2 + barFracWidth, baseY - barH + 2, 2, barH - 4)
		
		local text = InsaneStats:FormatNumber(math.Round(slowHealth)).." / "..InsaneStats:FormatNumber(math.Round(maxHealth))
		draw.SimpleTextOutlined("Health", "InsaneStats.Medium", baseX + 2, baseY - barH, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, color_black)
		draw.SimpleTextOutlined(text, "InsaneStats.Medium", baseX + barW - 2, baseY - barH, barColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
	end
end)

local shouldHide = {
	CHudHealth = true,
	CHudBattery = true
}
hook.Add("HUDShouldDraw", "InsaneStats", function(name)
	if InsaneStats:GetConVarValue("hud_hp_enabled") and shouldHide[name] then return false end
end)
