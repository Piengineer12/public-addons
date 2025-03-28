InsaneStats:SetDefaultConVarCategory("Infinite Health and Armor")

InsaneStats:RegisterClientConVar("hud_damage_enabled", "insanestats_hud_damage_enabled", "1", {
	display = "Damage Numbers", desc = "Shows the damage numbers.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_damage_decimals", "insanestats_hud_damage_decimals", "0", {
	display = "Damage Number Decimals", desc = "Maximum number of decimal digits to show for damage numbers below 1,000.",
	type = InsaneStats.FLOAT, min = 0, max = 3
})
InsaneStats:RegisterClientConVar("hud_damage_selfonly", "insanestats_hud_damage_selfonly", "0", {
	display = "Self(-Dealt) Damage Only", desc = "Damage dealt by other entities to other entities are not displayed.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_damage_mobsonly", "insanestats_hud_damage_mobsonly", "0", {
	display = "Mob Damage Only", desc = "Only damage against mobs are displayed.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_damage_nonzero_health", "insanestats_hud_damage_nonzero_health", "1", {
	display = "Non-Zero HP Only", desc = "Damage dealt to zero health entities are not displayed.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_damage_noselfhealing", "insanestats_hud_damage_noselfhealing", "1", {
	display = "Don't Display Self-Heals", desc = "Self-healing numbers are not displayed.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_damage_particle", "insanestats_hud_damage_particle", "0", {
	display = "Numbers Are Particles", desc = "Makes damage numbers render as bouncy particles. \z
	If 2, damage and healing received are also rendered as particles.",
	type = InsaneStats.INT, min = 0, max = 2
})
InsaneStats:RegisterClientConVar("hud_damage_lifetime", "insanestats_hud_damage_lifetime", "2", {
	display = "Damage Life Time", desc = "How long damage numbers appear for.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterClientConVar("hud_damage_stacktime", "insanestats_hud_damage_stacktime", "1", {
	display = "Damage Stack Time", desc = "Successive damage dealt within this time cumulates into a single number. \z
	Only works for non-particle numbers, see the \"insanestats_hud_damage_particle\" ConVar.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterClientConVar("hud_damage_stackresetlife", "insanestats_hud_damage_stackresetlife", "0", {
	display = "Reset Lifetime When Stacking", desc = "Successive damage dealt can be stacked indefinitely. \z
	Only works for non-particle numbers, see the \"insanestats_hud_damage_particle\" ConVar.",
	type = InsaneStats.BOOL
})

InsaneStats:RegisterClientConVar("hud_dps_enabled", "insanestats_hud_dps_enabled", "0", {
	display = "DPS Meter", desc = "Shows the DPS meter. Note that all settings that affect damage number visibility also affect the DPS meter!",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_dps_decimals", "insanestats_hud_dps_decimals", "0", {
	display = "DPS Meter Decimals", desc = "Maximum number of decimal digits to show for DPS numbers below 1,000.",
	type = InsaneStats.FLOAT, min = 0, max = 3
})
InsaneStats:RegisterClientConVar("hud_dps_x", "insanestats_hud_dps_x", "0.35", {
	display = "DPS Meter X", desc = "Horizontal position of DPS meter.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_dps_y", "insanestats_hud_dps_y", "0.9", {
	display = "DPS Meter Y", desc = "Vertical position of DPS meter.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_dps_time", "insanestats_hud_dps_time", "5", {
	display = "DPS Timer", desc = "Damage done after this amount of time will not be factored into the DPS.",
	type = InsaneStats.FLOAT, min = 0, max = 60
})
InsaneStats:RegisterClientConVar("hud_dps_simplified", "insanestats_hud_dps_simplified", "0", {
	display = "Compact DPS", desc = "Makes the DPS meter use a simplified display like damage numbers.",
	type = InsaneStats.BOOL
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
InsaneStats:RegisterClientConVar("hud_hp_h", "insanestats_hud_hp_h", "0.25", {
	display = "Health and Armor Meters Height", desc = "Vertical height of health meter.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterClientConVar("hud_hp_decimals", "insanestats_hud_hp_decimals", "1", {
	display = "Health and Armor Decimals", desc = "Maximum number of decimal digits to show for health meter numbers below 1,000.",
	type = InsaneStats.FLOAT, min = 0, max = 3
})

local color_gray = InsaneStats:GetColor("gray")
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

local ourDamages = {}
-- table fields: damage, types, crit, time, origin, posX, posY
local allDamageNumbers = {}
local doNotReportDamageOnTheseClasses = {
	env_fire = true
}
hook.Add("InsaneStatsHUDDamageTaken", "InsaneStatsUnlimitedHealth", function(entIndex, attacker, damage, types, hitgroup, position, flags)
	local ply = LocalPlayer()
	if IsValid(ply) then
		allDamageNumbers[entIndex] = allDamageNumbers[entIndex] or {}
		local entityDamageNumbers = allDamageNumbers[entIndex]

		local isSelf = ply:EntIndex() == entIndex
		if isSelf then
			flags = bit.bor(flags, 4)
		end
		
		local ent = Entity(entIndex)
		local condition1 = not InsaneStats:GetConVarValue("hud_damage_selfonly")
			or attacker == ply or ent == ply
		local condition2 = not InsaneStats:GetConVarValue("hud_damage_mobsonly")
			or bit.band(flags, 16) ~= 0 or IsValid(ent) and ent:InsaneStats_IsMob()
		local condition3 = not InsaneStats:GetConVarValue("hud_damage_nonzero_health")
			or bit.band(flags, 8) ~= 0 or IsValid(ent) and ent:InsaneStats_GetHealth() > 0
		local condition4 = not InsaneStats:GetConVarValue("hud_damage_noselfhealing")
			or not isSelf or damage > 0
		local condition5 = not (IsValid(ent) and doNotReportDamageOnTheseClasses[ent:GetClass()])
		--print(ent, condition1, condition2, condition3, condition4, condition5)

		local requireNewAdd = true
		if (ply:IsLineOfSightClear(position) or attacker == ply)
		and condition1 and condition2 and condition3 and condition4 and condition5 then
			if next(entityDamageNumbers) then
				local latestEntDamage = entityDamageNumbers[#entityDamageNumbers]
				-- check whether the previous damage number should have elapsed
				if latestEntDamage.time + InsaneStats:GetConVarValue("hud_damage_stacktime") > RealTime() then
					latestEntDamage.damage = latestEntDamage.damage + damage
					latestEntDamage.types = bit.bor(latestEntDamage.types, types)
					latestEntDamage.flags = flags
					latestEntDamage.crit = hitgroup == 1 and 1 or hitgroup > 3 and -1 or 0
					if InsaneStats:GetConVarValue("hud_damage_stackresetlife") then
						latestEntDamage.time = RealTime()
						latestEntDamage.origin = position
					end
					
					requireNewAdd = false
				end
			end

			if requireNewAdd then
				table.insert(entityDamageNumbers, {
					damage = damage,
					types = types,
					crit = hitgroup == 1 and 1 or hitgroup > 3 and -1 or 0,
					time = RealTime(),
					origin = position,
					flags = flags
				})
			end
		end
		
		if attacker == ply and not isSelf and not missed and damage > 0
		and condition2 and condition3 and condition5 then
			local latestEntry = ourDamages[#ourDamages]
			local curTime = CurTime()
			if (latestEntry and latestEntry.time == curTime) then
				latestEntry.damage = latestEntry.damage + damage
			else
				table.insert(ourDamages, {
					damage = damage,
					time = curTime
				})
			end
		end
	end
end)

local function DrawDamageNumber(entityDamageInfo)
	local timeExisted = RealTime() - entityDamageInfo.time
	local outlineThickness = InsaneStats:GetOutlineThickness()
	
	-- set the alpha
	local alpha = 2 - timeExisted
	surface.SetAlphaMultiplier(alpha)
	
	local posX = entityDamageInfo.posX
	-- text floats at a rate of 2em/s divided by stacking time
	local offsetY = timeExisted * InsaneStats.FONT_MEDIUM * -2
	/ math.max(InsaneStats:GetConVarValue("hud_damage_stacktime"), 1)
	local posY = entityDamageInfo.posY + offsetY
	
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
		math.Round(math.abs(entityDamageInfo.damage), InsaneStats:GetConVarValue("hud_damage_decimals")),
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
	local textDrawColors = {}
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

	local rainbowDrawColor = HSVToColor(RealTime() * 120 % 360, 1, 1)

	InsaneStats:DrawTextOutlined(
		suffixText, 2, textStartX + offsetX, posY,
		rainbowDrawColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM,
		{outlineOnly = true}
	)

	--[[InsaneStats:DrawTextOutlined(
		numberText..suffixText, 2, textStartX, posY,
		color_transparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
	)]]

	offsetX = 0
	
	for i,v in ipairs(textDrawColors) do
		offsetX = offsetX + draw.SimpleText(
			v[1], "InsaneStats.Medium",
			textStartX + offsetX, posY,
			v[2], TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
		)
	end
	
	draw.SimpleText(suffixText, "InsaneStats.Medium", textStartX + offsetX, posY, rainbowDrawColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	
	-- if crit, draw extra text
	if entityDamageInfo.crit > 0 then
		InsaneStats:DrawTextOutlined(
			"Critical!", 2, posX, posY - InsaneStats.FONT_MEDIUM,
			color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		)
	elseif entityDamageInfo.crit < 0 then
		InsaneStats:DrawTextOutlined(
			"Nick!", 2, posX, posY - InsaneStats.FONT_MEDIUM,
			color_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		)
	end
end

--local dps = 1
local slowDamage = 0
local slowDPS = 0
local totalDetimedDamage = 0
local totalDPS = 0
local slowArmor = 0
local slowHealth = 0
hook.Add("HUDPaint", "InsaneStatsUnlimitedHealth", function()
	if InsaneStats:ShouldDrawHUD() then
		local scrW = ScrW()
		local scrH = ScrH()
		local ply = LocalPlayer()
		local hasSuit = ply:IsSuitEquipped()
		local plyIndex = ply:EntIndex()
		--local skipOtherDamageNumbers
		
		if InsaneStats:GetConVarValue("hud_damage_enabled") and hasSuit then
			cam.Start3D()
			for ent,entityDamageNumbers in pairs(allDamageNumbers) do
				local entriesToDelete = 0
				
				for k,entityDamageInfo in pairs(entityDamageNumbers) do
					local shouldBeParticles = InsaneStats:GetConVarValue("hud_damage_particle")
					shouldBeParticles = shouldBeParticles == 2
					or shouldBeParticles == 1 and ent ~= plyIndex
					if shouldBeParticles then
						local effData = EffectData()
						local damage = entityDamageInfo.damage
						if damage < 0 then
							effData:SetMagnitude(-InsaneStats:CalculateRoot8(-damage))
						else
							effData:SetMagnitude(InsaneStats:CalculateRoot8(damage))
						end
						effData:SetDamageType(entityDamageInfo.types)
						local crit = entityDamageInfo.crit
						local flags = entityDamageInfo.flags
						effData:SetFlags(bit.bor(
							crit == 1 and 1 or 0,
							crit == -1 and 2 or 0,
							bit.band(flags, 1) ~= 0 and 4 or 0,
							bit.band(flags, 2) ~= 0 and 8 or 0,
							bit.band(flags, 4) ~= 0 and 16 or 0
						))
						effData:SetScale(InsaneStats:GetConVarValue("hud_damage_lifetime"))
						effData:SetOrigin(entityDamageInfo.origin)
						util.Effect("insane_stats_damage_number", effData)
						entriesToDelete = entriesToDelete + 1
						--skipOtherDamageNumbers = true
					elseif entityDamageInfo.time
					+ InsaneStats:GetConVarValue("hud_damage_lifetime") > RealTime() then
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

				--if skipOtherDamageNumbers then break end
				
				--[[for i=1,entriesToDelete do
					table.remove(entityDamageNumbers, 1)
				end]]
			end
			cam.End3D()
			
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
			--[[
			what if three 20 damage events happen over 6 seconds but only 5 seconds are counted?
			that causes these possibilities:
			[][][
			][][]
			causing the dps meter to be always wrong, either reporting 12 or 8 dps
			
			if only 4 seconds are counted, it can result in these:
			][][
			[][]

			my fix is that instead of dividing over 5 to get dps,
			compute the difference of time between the first and last instance of damage counted,
			then multiply that time difference by 1+1/(i-1), where i is the number of instances
			
			this results in three events being divided over 6 seconds / two events over 4 seconds
			which is significantly more accurate, at least for automatic non-reloading weapons
			]]
			local outlineThickness = InsaneStats:GetOutlineThickness()
			local curTime = CurTime()
			local discardTime = curTime - InsaneStats:GetConVarValue("hud_dps_time")

			-- remove expired entries in the ourDamages table
			if next(ourDamages) then
				while ourDamages[1].time < discardTime do
					local instance = table.remove(ourDamages, 1)
					if next(ourDamages) then
						totalDetimedDamage = totalDetimedDamage + instance.damage
					else
						totalDetimedDamage = 0
						slowDamage = 0
						slowDPS = 0
						break
					end
				end
			end

			if next(ourDamages) then
				local totalLatestDamage = 0
				for i,v in ipairs(ourDamages) do
					totalLatestDamage = totalLatestDamage + v.damage
				end

				local totalDamage = totalDetimedDamage + totalLatestDamage
				local minTime = ourDamages[1].time
				local maxTime = ourDamages[#ourDamages].time
				
				local entryFactor = #ourDamages > 1 and 1+1/(#ourDamages - 1) or 1
				local timeDifference = math.max((maxTime - minTime) * entryFactor, 1)
				local totalDPS = totalLatestDamage / timeDifference
				
				local life = ourDamages[#ourDamages].time - discardTime
				surface.SetAlphaMultiplier(life)
				
				local simplify = InsaneStats:GetConVarValue("hud_dps_simplified")
				slowDamage = InsaneStats:TransitionUINumber(slowDamage, totalDamage)
				slowDPS = InsaneStats:TransitionUINumber(slowDPS, totalDPS)

				local text
				local decimals = InsaneStats:GetConVarValue("hud_dps_decimals")
				if simplify then
					--math.Round(math.abs(entityDamageInfo.damage), )
					text = string.format(
						"Total Damage: %s (%s/s)",
						InsaneStats:FormatNumber(slowDamage, {decimals = decimals}),
						InsaneStats:FormatNumber(slowDPS, {decimals = decimals, plus = true})
					)
				else
					text = string.format(
						"Total Damage: %s (%s%s/s)",
						string.Comma(math.Round(slowDamage, decimals)),
						slowDPS > 0 and "+" or "",
						string.Comma(math.Round(slowDPS, decimals))
					)
				end
				
				local x = scrW * InsaneStats:GetConVarValue("hud_dps_x")
				local y = scrH * InsaneStats:GetConVarValue("hud_dps_y")
				InsaneStats:DrawTextOutlined(
					text, 3, x, y,
					color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
				)

				surface.SetAlphaMultiplier(1)
			end
		end
		
		if InsaneStats:GetConVarValue("hud_hp_enabled") then
			local baseX = scrW * InsaneStats:GetConVarValue("hud_hp_x")
			local baseY = scrH * InsaneStats:GetConVarValue("hud_hp_y")
			local barW = InsaneStats.FONT_MEDIUM * InsaneStats:GetConVarValue("hud_hp_w")
			local barH = InsaneStats.FONT_MEDIUM * InsaneStats:GetConVarValue("hud_hp_h")
			local outlineThickness = InsaneStats:GetOutlineThickness()
			local decimals = InsaneStats:GetConVarValue("hud_hp_decimals")
			
			-- armor bar
			local armor = ply:InsaneStats_GetArmor()
			if armor > 0 then
				local maxArmor = ply:InsaneStats_GetMaxArmor()
				slowArmor = InsaneStats:TransitionUINumber(slowArmor, armor)
				
				local barData = InsaneStats:CalculateMultibar(slowArmor, maxArmor, 180)
				local bars = barData.bars
				local barColor = barData.color
			
				InsaneStats:DrawRectOutlined(
					baseX, baseY - barH, barW, barH,
					barData.frac, barColor, barData.nextColor
				)
				
				local text = string.format(
					"%s / %s",
					InsaneStats:FormatNumber(slowArmor, {decimals = decimals}),
					InsaneStats:FormatNumber(maxArmor, {decimals = decimals})
				)
				local offsetX, offsetY = InsaneStats:DrawTextOutlined(
					"Shield", 2, baseX, baseY - barH - outlineThickness,
					color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
				)
				if hasSuit then
					InsaneStats:DrawTextOutlined(
						text, 2, baseX + barW, baseY - barH - outlineThickness,
						barColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
					)
				end
				if slowArmor > maxArmor then
					InsaneStats:DrawTextOutlined(
						"x"..InsaneStats:FormatNumber(bars), 2, baseX + barW + outlineThickness, baseY,
						barColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
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

			if bars == 1 then
				barColor = HSVToColor(barData.frac * 120, 0.75, 1)
			end
			
			InsaneStats:DrawRectOutlined(
				baseX, baseY - barH, barW, barH,
				barData.frac, barColor, barData.nextColor
			)
			
			local text = string.format(
				"%s / %s",
				InsaneStats:FormatNumber(slowHealth, {decimals = decimals}),
				InsaneStats:FormatNumber(maxHealth, {decimals = decimals})
			)
			InsaneStats:DrawTextOutlined(
				"Health", 2, baseX, baseY - barH - outlineThickness,
				color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
			)
			if hasSuit then
				InsaneStats:DrawTextOutlined(
					text, 2, baseX + barW, baseY - barH - outlineThickness,
					barColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
				)
			end
			if slowHealth > maxHealth then
				InsaneStats:DrawTextOutlined(
					"x"..InsaneStats:FormatNumber(bars), 2, baseX + barW + outlineThickness, baseY,
					barColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
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
