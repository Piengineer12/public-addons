InsaneStats:RegisterClientConVar("hud_xp_enabled", "insanestats_hud_xp_enabled", "1", {
	desc = "Enables the XP bar and gain display.", type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_xp_cumulative", "insanestats_hud_xp_cumulative", "1", {
	desc = "Show cumulative XP instead of current level XP.", type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_xp_x", "insanestats_hud_xp_x", "0.5", {
	desc = "Horizontal position of XP bar.", type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_xp_y", "insanestats_hud_xp_y", "0.95", {
	desc = "Vertical position of XP bar.", type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_xp_gained_x", "insanestats_hud_xp_gain_x", "0", {
	desc = "Horizontal offset of XP gain display.", type = InsaneStats.FLOAT, min = -1, max = 1
})
InsaneStats:RegisterClientConVar("hud_xp_gained_y", "insanestats_hud_xp_gain_y", "-0.3", {
	desc = "Vertical offset of XP gain display.", type = InsaneStats.FLOAT, min = -1, max = 1
})

InsaneStats:RegisterClientConVar("hud_target_enabled", "insanestats_hud_target_enabled", "1", {
	desc = "Enables the target info HUD.", type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_target_x", "insanestats_hud_target_x", "0.5", {
	desc = "Horizontal position of target info.", type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_target_y", "insanestats_hud_target_y", "0.25", {
	desc = "Vertical position of target info.", type = InsaneStats.FLOAT, min = 0, max = 1
})

local oldLevel, olderLevel = -1, -1
local oldXP = -1
local oldXPDelayed = -1
local levelDisplayExpiryTimestamp = 0
local xpDisplayExpiryTimestamp = 0
local xpFlashDisplayExpiryTimestamp = 0
local nextEntityUpdateTimestamp = 0
local lookEntityInfo = {}
local iconSize = 36
local color_gray = InsaneStats:GetColor("gray")
local color_light_red = InsaneStats:GetColor("light_red")
local color_light_yellow = InsaneStats:GetColor("light_yellow")
local color_light_green = InsaneStats:GetColor("light_green")
local color_light_aqua = InsaneStats:GetColor("light_aqua")
local color_light_magenta = InsaneStats:GetColor("light_magenta")

function InsaneStats:CalculateMultibar(x, mx, startHue)
	-- data: bars, frac, color, nextColor
	local data = {}
	local currentHue = startHue
	if x == math.huge then
		data.bars = math.huge
		data.frac = 1
		currentHue = RealTime()*60
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

local statusEffectColors = {
	[-2] = color_light_magenta,
	[-1] = color_light_red,
	[0] = color_light_yellow,
	[1] = color_light_green,
	[2] = color_light_aqua
}

local function UpdateLookEntityInfo(ent)
	local realTime = RealTime()
	
	-- if we're still looking at the same entity, only update specific fields
	if lookEntityInfo.ent == ent then
		lookEntityInfo.health = ent:InsaneStats_GetHealth()
		lookEntityInfo.maxHealth = ent:InsaneStats_GetMaxHealth()
		lookEntityInfo.armor = ent:InsaneStats_GetArmor()
		lookEntityInfo.maxArmor = ent:InsaneStats_GetMaxArmor()
		lookEntityInfo.level = ent:InsaneStats_GetLevel()
		lookEntityInfo.statusEffects = ent.insaneStats_StatusEffects
		lookEntityInfo.decayTimestamp = realTime + 2
	else
		-- do we know its real class?
		if ent.insaneStats_Class then
			-- set the data for lookEntityInfo
			lookEntityInfo = {
				health = ent:InsaneStats_GetHealth(),
				maxHealth = ent:InsaneStats_GetMaxHealth(),
				armor = ent:InsaneStats_GetArmor(),
				maxArmor = ent:InsaneStats_GetMaxArmor(),
				level = ent:InsaneStats_GetLevel(),
				statusEffects = ent.insaneStats_StatusEffects,
				decayTimestamp = realTime + 2,
				isPlayer = false,
				teamColor = color_white,
				startingHue = 60,
				ent = ent
			}
			
			-- figure out class color
			if ent:IsPlayer() then
				lookEntityInfo.teamColor = team.GetColor(ent:Team())
				lookEntityInfo.name = ent:Nick()
				lookEntityInfo.isPlayer = true
				
				if LocalPlayer():Team() == ent:Team() then
					lookEntityInfo.startingHue = 120
				else
					lookEntityInfo.startingHue = 0
				end
			else
				local class = ent.insaneStats_Class
				lookEntityInfo.name = language.GetPhrase(class)
				
				if ent:IsNPC() then
					local disposition = ent.insaneStats_Disposition
					
					if disposition == 1 then
						lookEntityInfo.startingHue = 0
					elseif disposition == 3 then
						lookEntityInfo.startingHue = 120
					end
				end
			end
		else
			ent:InsaneStats_MarkForUpdate()
		end
	end
end

hook.Add("HUDPaint", "InsaneStatsXP", function()
	local scrW = ScrW()
	local scrH = ScrH()
	local ply = LocalPlayer()
	local realTime = RealTime()
	local level = ply:InsaneStats_GetLevel()
	
	if InsaneStats:GetConVarValue("xp_enabled") and InsaneStats:GetConVarValue("hud_xp_enabled") then
		local barHeight = InsaneStats.FONT_MEDIUM - 4
		local barWidth = InsaneStats.FONT_MEDIUM * 24
		
		local barX = (scrW - barWidth) * InsaneStats:GetConVarValue("hud_xp_x")
		local barY = scrH * InsaneStats:GetConVarValue("hud_xp_y") - InsaneStats.FONT_MEDIUM + 2
		local maxSaturation = 0.875
		
		local xp = math.floor(ply:InsaneStats_GetXP())
		local levelHue = (level*5+60) % 360
		if ply:InsaneStats_GetXP() == math.huge then
			levelHue = realTime*60 % 360
		elseif math.abs(level) > 9007199254740992 then
			-- return a random number seeded with the level
			levelHue = math.floor(util.SharedRandom("InsaneStatsLevelHue"..level, 0, 72))*5
		end
		local fgColor = HSVToColor(levelHue, maxSaturation, 1)
		local bgColor = HSVToColor(levelHue, maxSaturation, 0.5)
		
		local barFGColor = fgColor
		local barBGColor = bgColor
		
		if level ~= oldLevel then
			if oldLevel > 0 then
				if levelDisplayExpiryTimestamp < realTime then
					if level > oldLevel then
						surface.PlaySound("ambient/levels/canals/windchime2.wav")
					else
						surface.PlaySound("ambient/alarms/warningbell1.wav")
					end
					olderLevel = oldLevel
				end
				levelDisplayExpiryTimestamp = realTime + 5
			end
			oldLevel = level
		end
		
		if xp ~= oldXP then
			if oldXP >= 0 then
				xpDisplayExpiryTimestamp = realTime + 1.5
			else
				oldXPDelayed = xp
			end
			
			oldXP = xp
		end
		
		if xpDisplayExpiryTimestamp <= realTime and oldXPDelayed ~= xp then
			oldXPDelayed = xp
			xpFlashDisplayExpiryTimestamp = realTime + 0.5
		end
		
		local levelDisplayExpiryDuration = levelDisplayExpiryTimestamp - realTime
		local xpDisplayExpiryDuration = xpDisplayExpiryTimestamp - realTime
		local xpFlashDisplayExpiryDuration = xpFlashDisplayExpiryTimestamp - realTime
		
		if xpFlashDisplayExpiryDuration > 0 then
			local saturation = Lerp(xpFlashDisplayExpiryDuration*2, maxSaturation, 0)
			barFGColor = HSVToColor(levelHue, saturation, 1)
			barBGColor = HSVToColor(levelHue, saturation, 0.5)
		end
		
		surface.SetDrawColor(0,0,0)
		surface.DrawRect(barX-2, barY-2, barWidth+4, barHeight+4)
		surface.SetDrawColor(barBGColor.r, barBGColor.g, barBGColor.b)
		surface.DrawRect(barX, barY, barWidth, barHeight)
		surface.SetDrawColor(barFGColor.r, barFGColor.g, barFGColor.b)
		surface.DrawRect(barX, barY, barWidth * ply:InsaneStats_GetLevelFraction(), barHeight)
		
		draw.SimpleTextOutlined("Level ".. InsaneStats:FormatNumber(level), "InsaneStats.Medium", barX, barY, fgColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, color_black)
		if levelDisplayExpiryDuration < 0 then
			local previousLevelXP = InsaneStats:GetConVarValue("hud_xp_cumulative") and 0 or InsaneStats:GetXPRequiredToLevel(level)
			local currentXP = xp - previousLevelXP
			local nextXP = math.ceil(ply:InsaneStats_GetXPToNextLevel() - previousLevelXP)
			if not (currentXP >= 0 and currentXP < nextXP) and not InsaneStats:GetConVarValue("hud_xp_cumulative") then
				-- precision error
				currentXP = 0
				nextXP = 2^(math.floor(math.log(xp, 2)-52))
				
				if nextXP == math.huge then
					currentXP = math.huge
				end
			end
			
			local xpString = InsaneStats:FormatNumber(currentXP)
			local requiredXp = InsaneStats:FormatNumber(nextXP)
			local experienceText = xpString .. " / " .. requiredXp
			draw.SimpleTextOutlined(experienceText, "InsaneStats.Medium", barX+barWidth, barY, fgColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
			olderLevel = -1
		else
			local color = HSVToColor(levelHue, (math.cos(levelDisplayExpiryDuration*math.pi)+1)/2*maxSaturation, 1)
		
			local levelUpText = "Level up!"
			local levelDiff = level - olderLevel
			
			if levelDiff < 0 then
				levelUpText = "Level down!"
				levelDiff = -levelDiff
			end
			
			if levelDiff ~= 1 then
				levelUpText = levelUpText .. " x" .. InsaneStats:FormatNumber(levelDiff)
			end
			draw.SimpleTextOutlined(levelUpText, "InsaneStats.Medium", barX+barWidth, barY, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
		end
		
		if xpDisplayExpiryDuration > 0 then
			local textX = barX + barWidth / 2
			local textY = barY + barHeight / 2
			
			local frac = math.max(1-xpDisplayExpiryDuration*2, 0)
			local offset = 1-math.ease.InQuad(frac)
			
			textX = textX + offset * scrW * InsaneStats:GetConVarValue("hud_xp_gained_x")
			textY = textY + offset * scrH * InsaneStats:GetConVarValue("hud_xp_gained_y")
			
			local outlineLum = 0
			if xpDisplayExpiryDuration > 1 then
				outlineLum = (xpDisplayExpiryDuration*2-2) * 255
			end
			
			local outlineColor = Color(outlineLum, outlineLum, outlineLum)
			local experienceText = InsaneStats:FormatNumber(xp - oldXPDelayed) .. " xp"
			
			draw.SimpleTextOutlined(experienceText, "InsaneStats.Medium", textX, textY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, outlineColor)
		end
	end
	
	if InsaneStats:GetConVarValue("hud_target_enabled") then
		local lookEntity = ply:GetEyeTrace().Entity
		if IsValid(lookEntity) then
			UpdateLookEntityInfo(lookEntity)
		end
		
		if next(lookEntityInfo) then
			if lookEntityInfo.decayTimestamp <= realTime then
				lookEntityInfo = {}
			else
				local infoY = scrH*InsaneStats:GetConVarValue("hud_target_y")
				local infoW = 2
				surface.SetAlphaMultiplier(lookEntityInfo.decayTimestamp - realTime)
				
				local theirLevel = lookEntityInfo.level
				local theirLevelString = InsaneStats:FormatNumber(theirLevel)
				
				if InsaneStats:GetConVarValue("xp_enabled") then
					surface.SetFont("InsaneStats.Big")
					infoW = infoW + surface.GetTextSize(theirLevelString)
				else
					infoW = 0
				end
				
				local nameColor = lookEntityInfo.teamColor
				
				-- health bar + name widths
				local ourAttack = InsaneStats:GetConVarValue("xp_enabled") and InsaneStats:ScaleValueToLevelQuadratic(
					384,
					level,
					InsaneStats:GetConVarValue("xp_player_damage")/100,
					"xp_player_damage_mode",
					InsaneStats:GetConVarValue("xp_player_damage_add")/100,
					"xp_player_damage_add_mode"
				) or 384
				local barH = InsaneStats.FONT_BIG - InsaneStats.FONT_MEDIUM
				local healthBarWidthPercent = math.min(lookEntityInfo.maxHealth / ourAttack, 1)
				if lookEntityInfo.maxHealth == ourAttack then
					healthBarWidthPercent = 1
				end
				local healthBarWidth = healthBarWidthPercent * InsaneStats.FONT_MEDIUM * 20 + barH
				infoW = infoW + math.max(healthBarWidth, surface.GetTextSize(lookEntityInfo.name))
				
				local infoX = (scrW - infoW) * InsaneStats:GetConVarValue("hud_target_x")
				if InsaneStats:GetConVarValue("xp_enabled") then
					-- calculate strength of entity based on its level compared to us
					local theirStrength = InsaneStats:ScaleValueToLevelQuadratic(
						1,
						theirLevel,
						InsaneStats:GetConVarValue("xp_drop_add")/100,
						"xp_drop_add_mode",
						InsaneStats:GetConVarValue("xp_drop_add_add")/100,
						"xp_drop_add_add_mode"
					)
					local ourStrength = InsaneStats:ScaleValueToLevelQuadratic(
						1,
						level,
						InsaneStats:GetConVarValue("xp_drop_add")/100,
						"xp_drop_add_mode",
						InsaneStats:GetConVarValue("xp_drop_add_add")/100,
						"xp_drop_add_add_mode"
					)
					local strengthMul = theirStrength / ourStrength
					if theirStrength == ourStrength then -- inf
						strengthMul = 1
					end
					
					-- determine color based on strengthMul
					-- e^-0.5 -> aqua, e^0 -> green, e^0.5 -> yellow, e^1 -> red
					local strengthMod = math.log(strengthMul)
					local levelColorHue = math.Remap(math.Clamp(strengthMod, -0.5, 1), -0.5, 1, 180, 0)
					local levelColor = HSVToColor(levelColorHue, 1, 1)
					
					-- now actually draw the text
					--surface.DrawRect(infoX, infoY, 36, 36)
					infoX = infoX + draw.SimpleTextOutlined(theirLevelString, "InsaneStats.Big", infoX, infoY, levelColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, color_black)
					infoX = infoX + 2
				end
				
				-- health bar
				if lookEntityInfo.maxHealth > 0 then
					draw.SimpleTextOutlined(lookEntityInfo.name, "InsaneStats.Medium", infoX, infoY, nameColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, color_black)
					
					-- calculate properties for health and armor display
					local health = IsValid(lookEntityInfo.ent) and lookEntityInfo.health or 0
					lookEntityInfo.slowHealth = InsaneStats:TransitionUINumber(lookEntityInfo.slowHealth or health, health)
					local barData = InsaneStats:CalculateMultibar(lookEntityInfo.slowHealth, math.min(lookEntityInfo.maxHealth, ourAttack), lookEntityInfo.startingHue)
					local healthBars = barData.bars
					local barFrac = barData.frac
					local currentBarColor = barData.color
					local nextBarColor = barData.nextColor
					
					local barX = infoX
					local barY = infoY + InsaneStats.FONT_MEDIUM
					local barW = healthBarWidth
					
					if healthBars > 1 then
						draw.SimpleTextOutlined("x"..InsaneStats:FormatNumber(healthBars), "InsaneStats.Medium", infoX + healthBarWidth, infoY, currentBarColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, color_black)
					end
					
					local currentHealthBarWidth = barFrac > 0 and (barW-4) * barFrac or -2
					
					surface.SetDrawColor(0,0,0)
					surface.DrawRect(barX, barY, barW, barH)
					surface.SetDrawColor(nextBarColor.r, nextBarColor.g, nextBarColor.b, nextBarColor.a)
					surface.DrawRect(barX+2, barY+2, barW-4, barH-4)
					surface.SetDrawColor(currentBarColor.r, currentBarColor.g, currentBarColor.b, currentBarColor.a)
					surface.DrawRect(barX+2, barY+2, currentHealthBarWidth, barH-4)
					surface.SetDrawColor(0,0,0)
					surface.DrawRect(barX+2+currentHealthBarWidth, barY+2, 2, barH-4)
					
					-- armor
					if lookEntityInfo.armor > 0 then
						--print(lookEntityInfo.armor)
						infoY = infoY + InsaneStats.FONT_BIG
						-- FIXME: ugly code duplication!!!
						draw.SimpleTextOutlined("Shield", "InsaneStats.Medium", infoX, infoY, nameColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, color_black)
						
						local armorBarWidthPercent = math.min(lookEntityInfo.maxArmor / ourAttack, 1)
						if lookEntityInfo.maxArmor == ourAttack then
							armorBarWidthPercent = 1
						end
						armorBarWidth = armorBarWidthPercent * 192 + barH
						local armor = IsValid(lookEntityInfo.ent) and lookEntityInfo.armor or 0
						lookEntityInfo.slowArmor = InsaneStats:TransitionUINumber(lookEntityInfo.slowArmor or armor, armor)
						local barData = InsaneStats:CalculateMultibar(lookEntityInfo.slowArmor, math.min(lookEntityInfo.maxArmor, ourAttack), 180)
						local armorBars = barData.bars
						local barFrac = barData.frac
						local currentBarColor = barData.color
						local nextBarColor = barData.nextColor
						
						local barX = infoX
						local barY = infoY + InsaneStats.FONT_MEDIUM
						local barW = armorBarWidth
						
						if armorBars > 1 then
							draw.SimpleTextOutlined("x"..InsaneStats:FormatNumber(armorBars), "InsaneStats.Medium", infoX + armorBarWidth, infoY, currentBarColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, color_black)
						end
						
						local currentArmorBarWidth = barFrac > 0 and (barW-4) * barFrac or -2
						
						surface.SetDrawColor(0,0,0)
						surface.DrawRect(barX, barY, barW, barH)
						surface.SetDrawColor(nextBarColor.r, nextBarColor.g, nextBarColor.b, nextBarColor.a)
						surface.DrawRect(barX+2, barY+2, barW-4, barH-4)
						surface.SetDrawColor(currentBarColor.r, currentBarColor.g, currentBarColor.b, currentBarColor.a)
						surface.DrawRect(barX+2, barY+2, currentArmorBarWidth, barH-4)
						surface.SetDrawColor(0,0,0)
						surface.DrawRect(barX+2+currentArmorBarWidth, barY+2, 2, barH-4)
					end
				else
					draw.SimpleTextOutlined(lookEntityInfo.name, "InsaneStats.Medium", infoX, infoY + InsaneStats.FONT_BIG / 2, nameColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, color_black)
				end
				
				-- status effects
				if lookEntityInfo.statusEffects then
					local iconsPerRow = math.max(math.floor(healthBarWidth / iconSize), 5)
					local startX = infoX
					local startY = infoY + InsaneStats.FONT_BIG
					local statusEffectOrder = {}
					for k,v in pairs(lookEntityInfo.statusEffects) do
						if v.expiry > CurTime() and v.level ~= 0 then
							table.insert(statusEffectOrder, k)
						end
					end
					table.sort(statusEffectOrder, function(a,b)
						local statusEffectA = lookEntityInfo.statusEffects[a]
						local statusEffectB = lookEntityInfo.statusEffects[b]
						
						if statusEffectA.level ~= statusEffectB.level then
							return statusEffectA.level > statusEffectB.level
						elseif statusEffectA.expiry ~= statusEffectB.expiry then
							return statusEffectA.expiry > statusEffectB.expiry
						else
							return a < b
						end
					end)
					
					for i,v in ipairs(statusEffectOrder) do
						local currentX = startX + (i-1) % iconsPerRow * iconSize
						local currentY = startY + math.floor((i-1) / iconsPerRow) * iconSize
						
						local statusEffectInfo = InsaneStats:GetStatusEffectInfo(v)
						local statusEffectData = lookEntityInfo.statusEffects[v]
						local statusEffectColor = statusEffectColors[statusEffectInfo.typ]
						
						surface.SetMaterial(statusEffectInfo.img)
						-- draw the outline
						surface.SetDrawColor(0,0,0,statusEffectColor.a)
						for j=-2,2 do
							for k=-2,2 do
								if j ~= 0 and k ~= 0 then
									surface.DrawTexturedRect(currentX+j, currentY+k, iconSize, iconSize)
								end
							end
						end
						
						surface.SetDrawColor(statusEffectColor.r, statusEffectColor.g, statusEffectColor.b, statusEffectColor.a)
						surface.DrawTexturedRect(currentX, currentY, iconSize, iconSize)
						
						if statusEffectData.level ~= 1 then
							draw.SimpleTextOutlined(InsaneStats:FormatNumber(statusEffectData.level, {decimals = 0}),
								"InsaneStats.Small", currentX + iconSize - 2, currentY + iconSize - 2, statusEffectColor,
								TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black
							)
						end
					end
				end
				
				surface.SetAlphaMultiplier(1)
			end
		end
	end
end)

hook.Add("InsaneStatsEntityUpdated", "InsaneStatsXP", function(ent, flags)
	if ent == lookEntityInfo.ent then
		UpdateLookEntityInfo(ent)
	end
end)