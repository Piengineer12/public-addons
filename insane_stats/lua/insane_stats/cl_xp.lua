InsaneStats:SetDefaultConVarCategory("Experience")

InsaneStats:RegisterClientConVar("hud_xp_enabled", "insanestats_hud_xp_enabled", "1", {
	display = "XP Bar", desc = "Enables the XP bar and gain display.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_xp_cumulative", "insanestats_hud_xp_cumulative", "0", {
	display = "XP Numbers Are Cumulative", desc = "Show cumulative XP instead of current level XP.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_xp_x", "insanestats_hud_xp_x", "0.5", {
	display = "XP Bar X", desc = "Horizontal position of XP bar.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_xp_y", "insanestats_hud_xp_y", "0.98", {
	display = "XP Bar Y", desc = "Vertical position of XP bar.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
--[[InsaneStats:RegisterClientConVar("hud_xp_w", "insanestats_hud_xp_w", "200", {
	display = "XP Bar Width", desc = "Width of XP bar.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterClientConVar("hud_xp_h", "insanestats_hud_xp_h", "8", {
	display = "XP Bar Height", desc = "Height of XP bar.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterClientConVar("hud_xp_font_level", "insanestats_hud_xp_font_level", "8", {
	display = "Level Font Size", desc = "Size of XP bar level font.",
	type = InsaneStats.INT, min = 0, max = 100
})
InsaneStats:RegisterClientConVar("hud_xp_font", "insanestats_hud_xp_font", "8", {
	display = "XP Font Size", desc = "Size of XP font.",
	type = InsaneStats.INT, min = 0, max = 100
})]]
InsaneStats:RegisterClientConVar("hud_xp_gained_x", "insanestats_hud_xp_gain_x", "0", {
	display = "XP Gained Offset X", desc = "Horizontal offset of XP gain display.",
	type = InsaneStats.FLOAT, min = -1, max = 1
})
InsaneStats:RegisterClientConVar("hud_xp_gained_y", "insanestats_hud_xp_gain_y", "-0.4", {
	display = "XP Gained Offset Y", desc = "Vertical offset of XP gain display.",
	type = InsaneStats.FLOAT, min = -1, max = 1
})
--[[InsaneStats:RegisterClientConVar("hud_xp_gained_font", "insanestats_hud_xp_gained_font", "8", {
	display = "XP Gained Font Size", desc = "Size of XP gained font.",
	type = InsaneStats.INT, min = 0, max = 100
})]]

InsaneStats:RegisterClientConVar("hud_target_enabled", "insanestats_hud_target_enabled", "1", {
	display = "Target Info", desc = "Enables the target info HUD.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_target_x", "insanestats_hud_target_x", "0.5", {
	display = "Target Info X", desc = "Horizontal position of target info.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_target_y", "insanestats_hud_target_y", "0.25", {
	display = "Target Info Y", desc = "Vertical position of target info.",
	type = InsaneStats.FLOAT, min = 0, max = 1
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

local statusEffectColors = {
	[-2] = color_light_magenta,
	[-1] = color_light_red,
	[0] = color_light_yellow,
	[1] = color_light_green,
	[2] = color_light_aqua
}

local function UpdateLookEntityInfo(ent, reset)
	local realTime = RealTime()
	
	if (ent.insaneStats_TargetLastUpdate or 0) + 0.5 < realTime then
		ent.insaneStats_TargetLastUpdate = realTime
		ent:InsaneStats_MarkForUpdate()
	end
	
	if lookEntityInfo.ent ~= ent then
		lookEntityInfo = {}
	end
	
	-- if we're still looking at the same entity, only update specific fields
	if next(lookEntityInfo) and not reset then
		lookEntityInfo.health = ent:InsaneStats_GetHealth()
		lookEntityInfo.maxHealth = ent:InsaneStats_GetMaxHealth()
		lookEntityInfo.armor = ent:InsaneStats_GetArmor()
		lookEntityInfo.maxArmor = ent:InsaneStats_GetMaxArmor()
		lookEntityInfo.level = ent:InsaneStats_GetLevel()
		lookEntityInfo.statusEffects = ent.insaneStats_StatusEffects
		lookEntityInfo.decayTimestamp = realTime + 2
	elseif ent.insaneStats_Class then -- do we know its real class?
		-- set the data for lookEntityInfo
		lookEntityInfo.health = ent:InsaneStats_GetHealth()
		lookEntityInfo.maxHealth = ent:InsaneStats_GetMaxHealth()
		lookEntityInfo.armor = ent:InsaneStats_GetArmor()
		lookEntityInfo.maxArmor = ent:InsaneStats_GetMaxArmor()
		lookEntityInfo.level = ent:InsaneStats_GetLevel()
		lookEntityInfo.statusEffects = ent.insaneStats_StatusEffects
		lookEntityInfo.decayTimestamp = realTime + 2
		
		lookEntityInfo.isPlayer = ent:IsPlayer()
		lookEntityInfo.startingHue = 60
		lookEntityInfo.ent = ent
		
		-- figure out class color
		if lookEntityInfo.isPlayer then
			lookEntityInfo.teamColor = team.GetColor(ent:Team())
			lookEntityInfo.name = ent:Nick()
			
			if LocalPlayer():Team() == ent:Team() then
				lookEntityInfo.startingHue = 120
			else
				lookEntityInfo.startingHue = 0
			end
		else
			lookEntityInfo.teamColor = color_white
			lookEntityInfo.name = language.GetPhrase(ent.PrintName or ent.insaneStats_Class)
			
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

local function DrawOutlinedImage(img, x, y, w, h, color, outline, bgColor)
	surface.SetMaterial(img)
	
	-- draw the outline
	surface.SetDrawColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
	
	-- use the same algorithm as SimpleTextOutlined, otherwise both will look slightly, annoyingly different!
	local steps = outline * 2/3
	if steps < 1 then steps = 1 end
	
	for dx = -outline, outline, steps do
		for dy = -outline, outline, steps do
			surface.DrawTexturedRect(x+dx, y+dy, w, h)
		end
	end
	
	surface.SetDrawColor(color.r, color.g, color.b, color.a)
	surface.DrawTexturedRect(x, y, w, h)
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
		local maxSaturation = 0.75
		
		local xp = math.floor(ply:InsaneStats_GetXP())
		local levelHue = (level*5+60) % 360
		if ply:InsaneStats_GetXP() == math.huge then
			levelHue = realTime*120 % 360
		elseif math.abs(level) > 9007199254740992 then
			-- return a random number seeded with the level
			levelHue = math.floor(util.SharedRandom("InsaneStatsLevelHue"..level, 0, 72))*5
		end
		local fgColor = HSVToColor(levelHue, maxSaturation, 1)
		local bgColor = HSVToColor(levelHue, maxSaturation, 0.5)
		
		if not ply.insaneStats_XP then
			-- ask the server
			xp = -1
			ply:InsaneStats_MarkForUpdate()
		end
		
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
			local previousLevelXP = math.floor(InsaneStats:GetConVarValue("hud_xp_cumulative") and 0 or InsaneStats:GetXPRequiredToLevel(level))
			local currentXP = xp - previousLevelXP
			local nextXP = math.ceil(ply:InsaneStats_GetXPToNextLevel() - previousLevelXP)
			--print(currentXP, nextXP)
			if (currentXP < 0 or currentXP >= nextXP) and not InsaneStats:GetConVarValue("hud_xp_cumulative") then
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
				local healthBarWidth = healthBarWidthPercent * InsaneStats.FONT_MEDIUM * 20 + barH * 10
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
					if theirStrength == ourStrength then -- to deal with inf
						strengthMul = 1
					end
					
					-- determine color based on strengthMul
					-- e^-2.5 -> sky, e^-2 -> aqua, e^-1 -> green, e^0 -> yellow, e^1 -> red, e^2 -> magenta, e^2.5 -> purple
					local strengthMod = math.log(strengthMul)
					local levelColorHue = math.Remap(math.Clamp(strengthMod, -2, 2), -2, 2, 180, -60)
					local levelColor = HSVToColor(levelColorHue % 360, 1, 1)
					
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
					
					local currentHealthBarWidth = math.floor(barFrac > 0 and (barW-4) * barFrac or -2)
					
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
						armorBarWidth = armorBarWidthPercent * InsaneStats.FONT_MEDIUM * 20 + barH * 10
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
						
						local currentArmorBarWidth = math.floor(barFrac > 0 and (barW-4) * barFrac or -2)
						
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
						
						DrawOutlinedImage(
							statusEffectInfo.img,
							currentX, currentY,
							iconSize, iconSize,
							statusEffectColor,
							2, color_black
						)
						
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
	if ent == lookEntityInfo.ent or ent:GetClass() == "func_breakable" then
		UpdateLookEntityInfo(ent, bit.band(flags, 4) == 4)
	end
end)