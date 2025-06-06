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
InsaneStats:RegisterClientConVar("hud_xp_w", "insanestats_hud_xp_w", "20", {
	display = "XP Bar Width", desc = "Width of XP bar.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterClientConVar("hud_xp_h", "insanestats_hud_xp_h", "0.25", {
	display = "XP Bar Height", desc = "Height of XP bar.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterClientConVar("hud_xp_gained_x", "insanestats_hud_xp_gain_x", "0", {
	display = "XP Gained Offset X", desc = "Horizontal offset of XP gain display.",
	type = InsaneStats.FLOAT, min = -1, max = 1
})
InsaneStats:RegisterClientConVar("hud_xp_gained_y", "insanestats_hud_xp_gain_y", "-0.4", {
	display = "XP Gained Offset Y", desc = "Vertical offset of XP gain display.",
	type = InsaneStats.FLOAT, min = -1, max = 1
})

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
InsaneStats:RegisterClientConVar("hud_target_w", "insanestats_hud_target_w", "12", {
	display = "Target Info Bar Width", desc = "Width of target info bars.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterClientConVar("hud_target_h", "insanestats_hud_target_h", "0.25", {
	display = "Target Info Bar Height", desc = "Height of target info bars.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterClientConVar("hud_target_statuseffects_size", "insanestats_hud_target_statuseffects_size", "3", {
	display = "Target Info Status Effect Size", desc = "Size of target info status effects.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterClientConVar("hud_target_halo", "insanestats_hud_target_halo", "1", {
	display = "Show Halo", desc = "Show a halo for the current entity displayed by the target info HUD.",
	type = InsaneStats.BOOL
})

local oldLevel, olderLevel = 1, 1
local oldXP = 0
local oldXPDelayed = 0
local levelDisplayExpiryTimestamp = 0
local xpDisplayExpiryTimestamp = 0
local xpFlashDisplayExpiryTimestamp = 0
local nextEntityUpdateTimestamp = 0
local lookEntityInfo = {}
local color_light_red = InsaneStats:GetColor("light_red")
local color_light_yellow = InsaneStats:GetColor("light_yellow")
local color_light_green = InsaneStats:GetColor("light_green")
local color_light_aqua = InsaneStats:GetColor("light_aqua")
local color_light_magenta = InsaneStats:GetColor("light_magenta")

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
		--lookEntityInfo.wpLevel = ent.worldProgression_Level
		--lookEntityInfo.wpDangerous = ent.worldProgression_Dangerous
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
			
			if ent:IsNPC() then
				local disposition = ent.insaneStats_Disposition
				
				if disposition == 1 then
					lookEntityInfo.startingHue = 0
				elseif disposition == 3 then
					lookEntityInfo.startingHue = 120
				end
			end
			
			lookEntityInfo.name = ent:InsaneStats_GetPrintName()
		end
	else
		ent:InsaneStats_MarkForUpdate()
	end
end

function InsaneStats:GetXPBarHue(level)
	if level == math.huge then
		return RealTime()*120 % 360
	elseif math.abs(level) > 1099511627776 then
		-- return a random number seeded with the level
		return math.floor(util.SharedRandom("InsaneStatsLevelHue"..string.format("%.10e", level), 0, 72))*5
	else
		return (level*5+60) % 360
	end
end

function InsaneStats:GetXPInfo()
	local ply = LocalPlayer()
	local xp = ply:InsaneStats_GetXP()
	local level = ply:InsaneStats_GetLevel()

	local nextXP = InsaneStats:GetXPRequiredToLevel(level + 1)
	if not InsaneStats:GetConVarValue("hud_xp_cumulative") then
		xp, nextXP = ply:InsaneStats_GetLevelProgress()
	end

	return {
		level = level,
		current = math.floor(xp),
		required = math.ceil(nextXP),
		fraction = ply:InsaneStats_GetLevelFraction()
	}
end

hook.Add("HUDPaint", "InsaneStatsXP", function()
	if InsaneStats:ShouldDrawHUD() then
		local scrW = ScrW()
		local scrH = ScrH()
		local ply = LocalPlayer()
		local hasSuit = ply:IsSuitEquipped()
		local realTime = RealTime()
		local curTime = CurTime()
		local level = ply:InsaneStats_GetLevel()

		if InsaneStats:GetConVarValue("xp_enabled") and InsaneStats:GetConVarValue("hud_xp_enabled") then
			local barHeight = InsaneStats.FONT_MEDIUM * InsaneStats:GetConVarValue("hud_xp_h")
			local barWidth = InsaneStats.FONT_MEDIUM * InsaneStats:GetConVarValue("hud_xp_w")
			local outlineThickness = InsaneStats:GetOutlineThickness()
			
			local barX = (scrW - barWidth) * InsaneStats:GetConVarValue("hud_xp_x")
			local barY = scrH * InsaneStats:GetConVarValue("hud_xp_y") - barHeight
			local maxSaturation = 0.75
			
			local xp = math.floor(ply:InsaneStats_GetXP())
			local levelHue = InsaneStats:GetXPBarHue(level)
			local fgColor = HSVToColor(levelHue, maxSaturation, 1)
			local bgColor = HSVToColor(levelHue, maxSaturation, 0.5)
			
			if not ply:InsaneStats_GetEntityData("xp") then
				-- ask the server
				xp = 0
				ply:InsaneStats_MarkForUpdate()
			end
			
			local barFGColor = fgColor
			local barBGColor = bgColor
			
			if level ~= oldLevel then
				if oldXP > 0 then
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
				if oldXP > 0 and hasSuit then
					xpDisplayExpiryTimestamp = realTime + 2
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
			
			local data = InsaneStats:GetXPInfo()
			local level = data.level
			local currentXP = data.current
			local nextXP = data.required
			local fraction = data.fraction
			InsaneStats:DrawRectOutlined(
				barX, barY, barWidth, barHeight,
				fraction, barFGColor, barBGColor
			)
			
			InsaneStats:DrawTextOutlined(
				"Level ".. InsaneStats:FormatNumber(level), 2, barX, barY-outlineThickness,
				fgColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
			)
			if levelDisplayExpiryDuration < 0 and hasSuit then
				local xpString = InsaneStats:FormatNumber(currentXP)
				local requiredXp = InsaneStats:FormatNumber(nextXP)
				local experienceText = xpString .. " / " .. requiredXp
				InsaneStats:DrawTextOutlined(
					experienceText, 2, barX+barWidth, barY-outlineThickness,
					fgColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
				)
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
				InsaneStats:DrawTextOutlined(
					levelUpText, 2, barX+barWidth, barY-outlineThickness,
					color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
				)
			end
			
			if xpDisplayExpiryDuration > 0 then
				local textX = barX + barWidth / 2
				local textY = barY + barHeight / 2
				
				local frac = math.max(1-xpDisplayExpiryDuration*2, 0)
				local offset = 1-math.ease.InQuad(frac)
				
				textX = textX + offset * scrW * InsaneStats:GetConVarValue("hud_xp_gained_x")
				textY = textY + offset * scrH * InsaneStats:GetConVarValue("hud_xp_gained_y")
				
				local outlineLum = InsaneStats:GetConVarValue("hud_outline_colormul") * 255 / 100
				if xpDisplayExpiryDuration > 1.5 then
					outlineLum = math.Remap(
						xpDisplayExpiryDuration, 2, 1.5,
						255, InsaneStats:GetConVarValue("hud_outline_colormul") * 255 / 100
					)
				end
				
				local outlineColor = Color(outlineLum, outlineLum, outlineLum)
				local experienceText = InsaneStats:FormatNumber(xp - oldXPDelayed) .. " xp"
				
				InsaneStats:DrawTextOutlined(
					experienceText, 2, textX, textY,
					color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
					{outlineColor = outlineColor}
				)
			end
		end
		
		if InsaneStats:GetConVarValue("hud_target_enabled") and hasSuit then
			local outlineThickness = InsaneStats:GetOutlineThickness()
			local lookEntity = ply:GetEyeTrace().Entity
			if IsValid(lookEntity) and not lookEntity.insaneStats_NoTargetID then
				UpdateLookEntityInfo(lookEntity)
			end
			
			if next(lookEntityInfo) then
				if lookEntityInfo.decayTimestamp <= realTime then
					lookEntityInfo = {}
				else
					local infoY = scrH*InsaneStats:GetConVarValue("hud_target_y")
					local infoW = outlineThickness
					local fontName = "InsaneStats.Medium"
					local fontSize = 2
					local fontHeight = InsaneStats.FONT_MEDIUM
					-- outlineThickness is the thickness between the level number and health bars
					surface.SetAlphaMultiplier(lookEntityInfo.decayTimestamp - realTime)
					
					local theirLevel = lookEntityInfo.level
					local theirLevelString = InsaneStats:FormatNumber(theirLevel)
					
					if InsaneStats:GetConVarValue("xp_enabled") then
						surface.SetFont("InsaneStats.Big")
						infoW = infoW + surface.GetTextSize(theirLevelString) + outlineThickness
					end
					
					local nameColor = lookEntityInfo.teamColor
					
					-- health bar + name widths
					local ourAttack = InsaneStats:GetConVarValue("xp_enabled") and InsaneStats:ScaleValueToLevel(
						250,
						InsaneStats:GetConVarValue("xp_player_damage")/100,
						level,
						"xp_player_damage_mode"
					) or 250
					local barH = fontHeight * InsaneStats:GetConVarValue("hud_target_h")
					local maxBarW = fontHeight * InsaneStats:GetConVarValue("hud_target_w")
					local healthBarWidthPercent = math.min(lookEntityInfo.maxHealth / ourAttack, 1)
					if lookEntityInfo.maxHealth == ourAttack then
						healthBarWidthPercent = 1
					end
					local healthBarWidth = healthBarWidthPercent * maxBarW + barH * 2
					surface.SetFont(fontName)
					infoW = infoW + math.max(healthBarWidth, surface.GetTextSize(lookEntityInfo.name)) + outlineThickness
					
					-- level
					local infoX = (scrW - infoW) * InsaneStats:GetConVarValue("hud_target_x") + outlineThickness
					if InsaneStats:GetConVarValue("xp_enabled") then
						-- calculate strength of entity based on its level compared to us
						local theirStrength = InsaneStats:ScaleValueToLevel(
							1,
							InsaneStats:GetConVarValue("xp_drop_add")/100,
							theirLevel,
							"xp_drop_add_mode"
						)
						local ourStrength = InsaneStats:ScaleValueToLevel(
							1,
							InsaneStats:GetConVarValue("xp_drop_add")/100,
							level,
							"xp_drop_add_mode"
						)

						--[[if wpLevel then
							theirStrength = theirStrength * (1 + (wpLevel*0.08 + 0.04) * wpLevel)
						end]]

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
						local infoYOffset = fontHeight + outlineThickness * 2
						if lookEntityInfo.maxHealth > 0 then
							infoYOffset = infoYOffset + barH + outlineThickness
						end
						infoX = infoX + InsaneStats:DrawTextOutlined(
							theirLevelString, 3, infoX, infoY + infoYOffset / 2,
							levelColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
						)
						infoX = infoX + outlineThickness
					end
					
					-- health bar
					if lookEntityInfo.maxHealth > 0 then
						InsaneStats:DrawTextOutlined(
							lookEntityInfo.name, fontSize, infoX, infoY,
							nameColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
						)
						
						-- calculate properties for health and armor display
						local health = IsValid(lookEntityInfo.ent) and lookEntityInfo.health or 0
						lookEntityInfo.slowHealth = InsaneStats:TransitionUINumber(lookEntityInfo.slowHealth or health, health)
						local barData = InsaneStats:CalculateMultibar(lookEntityInfo.slowHealth, math.min(lookEntityInfo.maxHealth, ourAttack), lookEntityInfo.startingHue)
						local healthBars = barData.bars
						local currentBarColor = barData.color
						
						local barX = infoX
						local barY = infoY + fontHeight + outlineThickness
						local barW = healthBarWidth
						
						if healthBars > 1 then
							InsaneStats:DrawTextOutlined(
								"x"..InsaneStats:FormatNumber(healthBars), fontSize,
								infoX + healthBarWidth, infoY, currentBarColor,
								TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP
							)
						end
						
						InsaneStats:DrawRectOutlined(
							barX, barY, barW, barH,
							barData.frac, currentBarColor, barData.nextColor
						)
						
						-- armor
						if lookEntityInfo.armor > 0 then
							--print(lookEntityInfo.armor)
							infoY = infoY + fontHeight + barH + outlineThickness * 2
							-- FIXME: ugly code duplication!!!
							InsaneStats:DrawTextOutlined(
								"Shield", fontSize, infoX, infoY,
								nameColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
							)
							
							local armorBarWidthPercent = math.min(lookEntityInfo.maxArmor / ourAttack, 1)
							if lookEntityInfo.maxArmor == ourAttack then
								armorBarWidthPercent = 1
							end
							local armorBarWidth = armorBarWidthPercent * maxBarW + barH * 2
							local armor = IsValid(lookEntityInfo.ent) and lookEntityInfo.armor or 0
							lookEntityInfo.slowArmor = InsaneStats:TransitionUINumber(lookEntityInfo.slowArmor or armor, armor)
							local barData = InsaneStats:CalculateMultibar(lookEntityInfo.slowArmor, math.min(lookEntityInfo.maxArmor, ourAttack), 180)
							local armorBars = barData.bars
							local currentBarColor = barData.color
							
							local barX = infoX
							local barY = infoY + fontHeight + outlineThickness
							local barW = armorBarWidth
							
							if armorBars > 1 then
								InsaneStats:DrawTextOutlined(
									"x"..InsaneStats:FormatNumber(armorBars), fontSize,
									infoX + armorBarWidth, infoY, currentBarColor,
									TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP
								)
							end
						
							InsaneStats:DrawRectOutlined(
								barX, barY, barW, barH,
								barData.frac, currentBarColor, barData.nextColor
							)
						end
					else
						InsaneStats:DrawTextOutlined(
							lookEntityInfo.name, fontSize, infoX, infoY + InsaneStats.FONT_BIG / 2,
							nameColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
						)
					end
					
					-- status effects
					if lookEntityInfo.statusEffects then
						infoY = infoY + fontHeight + barH + outlineThickness * 2
						local iconSize = InsaneStats.FONT_SMALL * InsaneStats:GetConVarValue("hud_target_statuseffects_size")
						local iconsPerRow = math.max(math.floor(healthBarWidth / iconSize), 5)
						local statusEffectOrder = {}
						for k,v in pairs(lookEntityInfo.statusEffects) do
							if v.expiry > curTime and v.level ~= 0 then
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
							local currentX = infoX + (i-1) % iconsPerRow * iconSize
							local currentY = infoY + math.floor((i-1) / iconsPerRow) * iconSize
							
							local statusEffectInfo = InsaneStats:GetStatusEffectInfo(v)
							local statusEffectData = lookEntityInfo.statusEffects[v]
							local statusEffectColor = statusEffectColors[statusEffectInfo.typ]
							
							InsaneStats:DrawMaterialOutlined(
								InsaneStats:GetIconMaterial(statusEffectInfo.img),
								currentX, currentY,
								iconSize, iconSize,
								statusEffectColor
							)
							
							local smallText
							if statusEffectData.level ~= 1 then
								smallText = InsaneStats:FormatNumber(statusEffectData.level, {compress = true, decimals = 1})
							elseif statusEffectData.expiry < math.huge then
								local duration = statusEffectData.expiry - curTime
								smallText = InsaneStats:FormatNumber(duration, {compress = true, decimals = 1}).."s"
							end

							if smallText then
								InsaneStats:DrawTextOutlined(
									smallText, 1, currentX + iconSize - 2, currentY + iconSize - 2,
									statusEffectColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
								)
							end
						end
					end
					
					surface.SetAlphaMultiplier(1)
				end
			end
		end
	end
end)

hook.Add("PreDrawHalos", "InsaneStatsXP", function()
	if IsValid(lookEntityInfo.ent) and InsaneStats:GetConVarValue("hud_target_enabled")
	and InsaneStats:GetConVarValue("hud_target_halo") then
		local haloAlpha = math.min(lookEntityInfo.decayTimestamp - RealTime(), 1)
		if haloAlpha > 0 then
			local haloColor = HSVToColor(lookEntityInfo.startingHue, 0.75, haloAlpha)
			halo.Add({lookEntityInfo.ent}, haloColor, 1, 1)
		end
	end
end)

hook.Add("InsaneStatsEntityUpdated", "InsaneStatsXP", function(ent, flags)
	if ent == lookEntityInfo.ent or ent:GetClass() == "func_breakable" then
		UpdateLookEntityInfo(ent, bit.band(flags, 4) == 4)
	end
end)