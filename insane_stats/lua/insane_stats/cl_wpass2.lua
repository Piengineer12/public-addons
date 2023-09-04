InsaneStats:SetDefaultConVarCategory("Weapon Prefixes and Suffixes System 2")

InsaneStats:RegisterClientConVar("hud_wpass2_hold", "insanestats_hud_wpass2_hold", "10", {
	display = "Weapon Panel Hold Time", desc = "Amount of time to display weapon information.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterClientConVar("hud_wpass2_width", "insanestats_hud_wpass2_width", "0.33", {
	display = "Weapon Panel Width", desc = "Maximum width of weapon panels.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_wpass2_height", "insanestats_hud_wpass2_height", "0.19", {
	display = "Weapon Panel Height", desc = "Maximum height of weapon panels.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_wpass2_lootbeams", "insanestats_hud_wpass2_lootbeams", "1", {
	display = "Loot Beams", desc = "Shows loot beams for weapons and armor batteries that have modifiers.",
	type = InsaneStats.BOOL
})

InsaneStats:RegisterClientConVar("hud_wpass2_current_x", "insanestats_hud_wpass2_current_x", "0.66", {
	display = "Current Weapon Panel X", desc = "Horizontal position of current weapon panel.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_wpass2_current_y", "insanestats_hud_wpass2_current_y", "0.7", {
	display = "Current Weapon Panel Y", desc = "Vertical position of current weapon panel.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_wpass2_hovered_x", "insanestats_hud_wpass2_hovered_x", "0.66", {
	display = "Hovered Weapon Panel X", desc = "Horizontal position of hovered weapon panel.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_wpass2_hovered_y", "insanestats_hud_wpass2_hovered_y", "0.5", {
	display = "Hovered Weapon Panel Y", desc = "Vertical position of hovered weapon panel.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})

-- clients are allowed to choose the auto-pickup mode
InsaneStats:RegisterClientConVar("wpass2_autopickup_override", "insanestats_wpass2_autopickup_override", "-1", {
	display = "Auto Pickup Mode Override", desc = "If 0 or above, overrides insanestats_wpass2_autopickup for yourself.",
	type = InsaneStats.INT, min = -1, max = 6, userinfo = true
})
InsaneStats:RegisterClientConVar("wpass2_autopickup_battery_override", "insanestats_wpass2_autopickup_battery_override", "-1", {
	display = "Auto Battery Pickup Mode Override", desc = "If 0 or above, overrides insanestats_wpass2_autopickup_battery for yourself.",
	type = InsaneStats.INT, min = -1, max = 6, userinfo = true
})

InsaneStats:RegisterClientConVar("hud_statuseffects_x", "insanestats_hud_statuseffects_x", "0.01", {
	display = "Status Effects X", desc = "Horizontal position of status effects.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_statuseffects_y", "insanestats_hud_statuseffects_y", "0.5", {
	display = "Status Effects Y", desc = "Vertical position of status effects.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})

concommand.Add("insanestats_wpass2_swap", function()
	net.Start("insane_stats")
	net.WriteUInt(3, 8)
	net.SendToServer()
end, nil,
"Swaps your current weapon / armor battery with whatever you're hovering over.")

local rarityNames = {
	"Junk",
	"Common",
	"Uncommon",
	"Rare",
	"Epic",
	"Superior",
	"Legendary",
	"Insane",
	"Galactic",
	"Monstrous",
	"Aetheric",
	"Mythical Common",
	"Mythical Uncommon",
	"Mythical Rare",
	"Mythical Epic",
	"Mythical Superior",
	"Mythical Legendary",
	"Mythical Insane",
	"Mythical Galactic",
	"Mythical Monstrous",
	"Mythical Aetheric",
	"Ultimate Common",
	"Ultimate Uncommon",
	"Ultimate Rare",
	"Ultimate Epic",
	"Ultimate Superior",
	"Ultimate Legendary",
	"Ultimate Insane",
	"Ultimate Galactic",
	"Ultimate Monstrous",
	"Ultimate Aetheric",
	"Ultimate Mythical Common",
	"Ultimate Mythical Uncommon",
	"Ultimate Mythical Rare",
	"Ultimate Mythical Epic",
	"Ultimate Mythical Superior",
	"Ultimate Mythical Legendary",
	"Ultimate Mythical Insane",
	"Ultimate Mythical Galactic",
	"Ultimate Mythical Monstrous",
	"Ultimate Mythical Aetheric",
	"Final Common",
	"Final Uncommon",
	"Final Rare",
	"Final Epic",
	"Final Superior",
	"Final Legendary",
	"Final Insane",
	"Final Galactic",
	"Final Monstrous",
	"Final Aetheric",
	"Final Mythical Common",
	"Final Mythical Uncommon",
	"Final Mythical Rare",
	"Final Mythical Epic",
	"Final Mythical Superior",
	"Final Mythical Legendary",
	"Final Mythical Insane",
	"Final Mythical Galactic",
	"Final Mythical Monstrous",
	"Final Mythical Aetheric",
	"Final Ultimate",
	"Rainbow"
}

local equippedWep
local panelDisplayDieTime = 0
local mouseOverDieTime = 0
local panelDisplayChangeTime = 0
local mouseOverChangeTime = 0
local oldLevel, olderLevel = -1, -1
local oldStatusEffects = {}
local color_gray = Color(127, 127, 127)
local color_light_red = Color(255, 127, 127)
local color_light_yellow = Color(255, 255, 127)
local color_light_green = Color(127, 255, 127)
local color_light_aqua = Color(127, 255, 255)
local color_light_blue = Color(127, 127, 255)
local color_light_magenta = Color(255, 127, 255)
local baseHues = {120, 240, 270, 0, 30, 60, 90, 210, 180, 300}
local iconSize = 36

local function CreateName(wep)
	local modifiers = InsaneStats:GetAllModifiers()
	local modifiersAscending = {}
	for k,v in SortedPairsByValue(wep.insaneStats_Modifiers) do
		table.insert(modifiersAscending, k)
	end
	
	local isWep = wep:IsWeapon()
	local name = language.GetPhrase(wep.PrintName ~= "" and wep.PrintName or isWep and wep:GetClass() or "item_battery")
	local lastSuffix = #modifiersAscending
	if lastSuffix % 2 == 0 then lastSuffix = lastSuffix - 1 end
	
	for i,v in ipairs(modifiersAscending) do
		local modifierInfo = modifiers[v]
		if modifierInfo then
			if i % 2 == 0 then
				name = modifierInfo.prefix .. ' ' .. name
			else
				local suffix = modifierInfo.suffix or modifierInfo.prefix
				if i == 1 then
					name = name .. " of " .. suffix
				elseif i == lastSuffix then
					name = name .. " and " .. suffix
				else
					name = name .. ", " .. suffix
				end
			end
		else
			InsaneStats:Log("Couldn't recognize modifier with ID \""..v.."\"!")
		end
	end
	
	local rarityDivide = InsaneStats:GetConVarValueDefaulted(not isWep and "wpass2_tier_raritycost_battery", "wpass2_tier_raritycost")
	local rarityTier = math.floor(wep.insaneStats_Tier/rarityDivide)
	rarityTier = math.min(rarityTier, #rarityNames-2)
	name = rarityNames[rarityTier+2] .. ' ' .. name
	
	local attribOrder = {}
	local attribOrderValues = {}
	for k,v in pairs(wep.insaneStats_Attributes) do
		v = math.abs(v-1)
		--[[if v < 1 then
			v = 1/v
		end]]
		attribOrderValues[k] = v
	end
	
	for k,v in SortedPairsByValue(attribOrderValues, true) do
		table.insert(attribOrder, k)
	end
	
	wep.insaneStats_AttributeOrder = attribOrder
	wep.insaneStats_Rarity = rarityTier
	wep.insaneStats_WPASS2Name = name
	wep.insaneStats_WPASS2NameLastRefresh = RealTime()
	wep.insaneStats_BatteryLevel = math.floor(InsaneStats:GetLevelByXPRequired(wep:InsaneStats_GetBatteryXP()))
end

function InsaneStats:GetRarityColor(tier)
	local realTime = RealTime()
	if tier < 0 then return color_gray
	elseif tier == 0 then return color_white
	elseif tier > 60 then return HSVToColor(realTime * 120 % 360, 1, 1)
	else
		local hue = baseHues[ (tier-1)%10+1 ]
		local sat = 0.5
		local val = 1
		if tier > 40 then
			if tier > 50 then
				sat = math.abs(Lerp(realTime%1, -1, 1))
			end
			hue = (hue + math.ease.InOutCubic(realTime%3/3) * 360) % 360
		elseif tier > 20 then
			if tier > 30 then
				sat = math.abs(Lerp(realTime%1, -1, 1))
			else
				sat = 1
			end
			hue = (hue + math.abs(Lerp(realTime%2/2, -120, 120)) - 60) % 360
		elseif tier > 10 then
			sat = math.abs(Lerp(realTime%1, -1, 1))
		end
		
		return HSVToColor(hue, sat, val)
	end
end

local function DrawWeaponPanel(panelX, panelY, wep, changeDuration, alphaMod, extra)
	local attributes = InsaneStats:GetAllAttributes()
	local textOffsetX, textOffsetY = 0, 0
	local maxW = ScrW() * InsaneStats:GetConVarValue("hud_wpass2_width")
	local maxH = ScrH() * InsaneStats:GetConVarValue("hud_wpass2_height")
	local maxY = panelY + maxH
	local rarityColor = InsaneStats:GetRarityColor(wep.insaneStats_Rarity)
	local typeText = wep:IsWeapon() and " Weapon" or " Battery"
	local outlineThickness = 2
	extra = extra or {}
	
	surface.SetAlphaMultiplier(alphaMod)
	local titleText = (extra.dropped and "Hovered " or "Current ")..language.GetPhrase(wep.PrintName ~= "" and wep.PrintName or wep:IsWeapon() and wep:GetClass() or "item_battery")..":"
	textOffsetX, textOffsetY = draw.SimpleTextOutlined(titleText, "InsaneStats.Medium", panelX+outlineThickness, panelY+outlineThickness, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outlineThickness, color_black)
	panelY = panelY + textOffsetY
	
	surface.SetFont("InsaneStats.Medium")
	local nameExtraW = surface.GetTextSize(wep.insaneStats_WPASS2Name) - maxW + outlineThickness*2
	local nameScrollFactor = 1
	if nameExtraW > 0 then
		nameScrollFactor = (math.cos(changeDuration/2)+1)/2
	end
	local nameScrollAmt = Lerp(nameScrollFactor, nameExtraW, 0)
	
	render.SetScissorRect(panelX, panelY, panelX+maxW, panelY+InsaneStats.FONT_MEDIUM+outlineThickness*2, true)
	
	textOffsetX, textOffsetY = draw.SimpleTextOutlined(wep.insaneStats_WPASS2Name, "InsaneStats.Medium", panelX-nameScrollAmt+outlineThickness, panelY+outlineThickness, rarityColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outlineThickness, color_black)
	panelY = panelY + textOffsetY
	
	render.SetScissorRect(0, 0, 0, 0, false)
	
	local tierDisplay = "Tier "..wep.insaneStats_Tier..typeText
	if InsaneStats:GetConVarValue("xp_enabled") then
		if wep:IsPlayer() then
			tierDisplay = "Tier "..wep.insaneStats_Tier..", Level "..InsaneStats:FormatNumber(wep.insaneStats_BatteryLevel)..typeText
		else
			tierDisplay = "Tier "..wep.insaneStats_Tier..", Level "..InsaneStats:FormatNumber(wep:InsaneStats_GetLevel())..typeText
		end
	end
	textOffsetX, textOffsetY = draw.SimpleTextOutlined(tierDisplay, "InsaneStats.Medium", panelX+outlineThickness, panelY+outlineThickness, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outlineThickness, color_black)
	
	local levelDiff = extra.levelDiff
	if (levelDiff and levelDiff ~= 0) then
		local levelUpText = "Level up!"
		
		if levelDiff < 0 then
			levelUpText = "Level down!"
			levelDiff = -levelDiff
		end
		
		if levelDiff ~= 1 then
			levelUpText = levelUpText .. " x" .. InsaneStats:FormatNumber(levelDiff)
		end
		draw.SimpleTextOutlined(levelUpText, "InsaneStats.Medium", panelX+maxW-outlineThickness, panelY+outlineThickness, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, outlineThickness, color_black)
	end
	
	panelY = panelY + textOffsetY
	
	if not wep.insaneStats_AttributeOrder then error(wep.insaneStats_WPASS2Name, type(wep.insaneStats_WPASS2Name)) end
	
	local attribY1 = panelY + 2
	local attribY2 = maxY
	local excessY = math.max(#wep.insaneStats_AttributeOrder * InsaneStats.FONT_SMALL + attribY1 - attribY2 + outlineThickness*2, 0)
	local holdTime = (attribY2 - attribY1) / InsaneStats.FONT_SMALL / 2
	local pathDuration = holdTime + excessY / InsaneStats.FONT_SMALL
	local animDuration = pathDuration * 2
	local animCurrent = changeDuration % animDuration
	
	local offsetY
	if animCurrent <= pathDuration or excessY == 0 then
		offsetY = math.min(math.Remap(animCurrent, holdTime, pathDuration, 0, -excessY), 0)
	else
		offsetY = math.max(math.Remap(animCurrent, pathDuration + holdTime, animDuration, -excessY, 0), -excessY)
	end
	
	--[[local sf1 = math.max(#wep.insaneStats_AttributeOrder - 4, 4)
	local sf2 = (changeDuration + sf1) % (sf1 * 2) - sf1
	local sf3 = math.Clamp(math.abs(sf2) - 2, 0, sf1-4)]]
	
	render.SetScissorRect(panelX, panelY+outlineThickness, panelX+maxW, maxY, true)
	
	for i,v in ipairs(wep.insaneStats_AttributeOrder) do
		local textY = panelY + (i-1) * InsaneStats.FONT_SMALL + offsetY
		-- don't bother if out of range
		if textY > attribY1-InsaneStats.FONT_SMALL-4 and textY < attribY2+outlineThickness then
			local attribValue = wep.insaneStats_Attributes[v]
			if not attribValue then
				PrintTable(wep.insaneStats_Attributes)
			end
			if not attributes[v] then error(v) end
			
			local displayColor = (attribValue < 1 == tobool(attributes[v].invert)) and color_light_blue or color_light_red
			
			local numberDisplay = InsaneStats:FormatNumber((attribValue-1)*(attributes[v].nopercent and 1 or 100), {plus = true, decimals = 1})
				..(attributes[v].nopercent and "" or "%")
			--[[if attribValue >= 10001 then
				numberDisplay = InsaneStats:FormatNumber((attribValue-1)*100) .. " %"
			end]]
			local attribDisplay = string.format(attributes[v].display, numberDisplay)
			
			textOffsetX, textOffsetY = draw.SimpleTextOutlined(attribDisplay, "InsaneStats.Small", panelX+outlineThickness, textY+outlineThickness, displayColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outlineThickness, color_black)
		end
	end
	
	render.SetScissorRect(0, 0, 0, 0, false)
	surface.SetAlphaMultiplier(1)
end

local statusEffectColors = {
	[-2] = color_light_magenta,
	[-1] = color_light_red,
	[0] = color_light_yellow,
	[1] = color_light_green,
	[2] = color_light_aqua
}

local function GetLookedAtWep(pos)
	local bestEntity = NULL
	local bestDistance = 1024
	for k,v in pairs(ents.FindInSphere(pos, 32)) do
		local distanceSquared = pos:DistToSqr(v:GetPos())
		if v:InsaneStats_IsWPASS2Pickup() and distanceSquared < bestDistance and not IsValid(v:GetOwner()) then
			bestEntity = v
			bestDistance = distanceSquared
		end
	end
	
	return bestEntity
end

hook.Add("InsaneStatsModifiersChanging", "InsaneStatsWPASS", function(ent, oldMods, newMods, modifierChangeReason)
	local ply = LocalPlayer()
	local modifiers = InsaneStats:GetAllModifiers()
	if oldMods and modifierChangeReason and (ent:IsWeapon() and ent:GetOwner() == ply or ent == ply) and ent:GetCreationTime() + 1 < CurTime() then
		for k,v in pairs(newMods) do
			local baseText
			
			if not oldMods[k] then
				baseText = "Your %s has gained the %s modifier!"
			elseif oldMods[k] < v then
				baseText = "Your %s has strengthened its %s modifier!"
			end
			
			if baseText then
				local entityName = language.GetPhrase(ent.PrintName ~= "" and ent.PrintName or ent:IsPlayer() and "item_battery" or ent:GetClass())
				local modifierName = modifiers[k] and (modifiers[k].suffix or modifiers[k].prefix) or k
				--notification.AddLegacy(string.format(baseText, entityName, modifierName), NOTIFY_GENERIC, 5)
				chat.AddText(string.format(baseText, entityName, modifierName))
			end
		end
	end
end)

local lastLookedAtWep2
local lastLookedAtWepEntIndex
hook.Add("HUDPaint", "InsaneStatsWPASS", function()
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		local ply = LocalPlayer()
		local wep = ply:KeyDown(IN_WALK) and ply or ply:GetActiveWeapon()
		local realTime = RealTime()
		local trace = ply:GetEyeTrace()
		local scrW = ScrW()
		local scrH = ScrH()
		
		if trace.Hit then
			local lookedAtWep = GetLookedAtWep(trace.HitPos)--ply:GetUseEntity()
			if (IsValid(lookedAtWep) and lookedAtWep:InsaneStats_IsWPASS2Pickup()) then
				if lastLookedAtWepEntIndex ~= lookedAtWep:EntIndex() then
					mouseOverChangeTime = realTime
					panelDisplayChangeTime = realTime
				end
				mouseOverDieTime = realTime + 1.1
				panelDisplayDieTime = realTime + InsaneStats:GetConVarValue("hud_wpass2_hold")
				lastLookedAtWep2 = lookedAtWep
				
				local lookClass = lookedAtWep:GetClass()
				
				if lookClass == "item_battery" then
					wep = ply
				elseif ply:HasWeapon(lookClass) then
					wep = ply:GetWeapon(lookedAtWep:GetClass())
				end
				
				lastLookedAtWepEntIndex = lookedAtWep:EntIndex()
			else
				lastLookedAtWepEntIndex = 0
			end
		else
			lastLookedAtWepEntIndex = 0
		end
		
		if IsValid(wep) then
			if equippedWep ~= wep:EntIndex() or oldLevel ~= wep:InsaneStats_GetLevel() then
				oldLevel = wep:InsaneStats_GetLevel()
				if equippedWep ~= wep:EntIndex() then
					equippedWep = wep:EntIndex()
					panelDisplayChangeTime = realTime
					olderLevel = oldLevel
				--[[elseif panelDisplayDieTime <= realTime then
					olderLevel = oldLevel]]
				end
				panelDisplayDieTime = realTime + InsaneStats:GetConVarValue("hud_wpass2_hold") + 1
			end
			
			if wep.insaneStats_Modifiers then
				if not wep.insaneStats_WPASS2Name or (wep.insaneStats_WPASS2NameLastRefresh or 0) + 5 < RealTime() then
					CreateName(wep)
				end
				if panelDisplayDieTime > realTime then
					DrawWeaponPanel(
						scrW*InsaneStats:GetConVarValue("hud_wpass2_current_x"),
						scrH*InsaneStats:GetConVarValue("hud_wpass2_current_y"),
						wep,
						RealTime() - panelDisplayChangeTime,
						math.min(1, panelDisplayDieTime - realTime),
						{levelDiff = wep:InsaneStats_GetLevel() - olderLevel}
					)
				else
					olderLevel = oldLevel
				end
			else
				wep:InsaneStats_MarkForUpdate()
			end
		end
		
		if IsValid(lastLookedAtWep2) then
			if lastLookedAtWep2.insaneStats_Modifiers then
				if not lastLookedAtWep2.insaneStats_WPASS2Name or (wep.insaneStats_WPASS2NameLastRefresh or 0) + 5 < RealTime() then
					CreateName(lastLookedAtWep2)
				end
				if mouseOverDieTime > realTime then
					DrawWeaponPanel(
						scrW*InsaneStats:GetConVarValue("hud_wpass2_hovered_x"),
						scrH*InsaneStats:GetConVarValue("hud_wpass2_hovered_y"),
						lastLookedAtWep2,
						RealTime() - mouseOverChangeTime,
						math.min(1, mouseOverDieTime - realTime),
						{dropped = true}
					)
				else
					lastLookedAtWep2 = nil
				end
			else
				lastLookedAtWep2:InsaneStats_MarkForUpdate()
			end
		end
		
		if (ply.insaneStats_StatusEffects and next(ply.insaneStats_StatusEffects)) then
			local registeredEffects = InsaneStats:GetAllStatusEffects()
			local statusEffectOrder = {}
			for k,v in pairs(ply.insaneStats_StatusEffects) do
				oldStatusEffects[k] = oldStatusEffects[k] or {expiry = 0, lastChanged = 0}
				
				if v.expiry > CurTime() and v.level ~= 0 then
					table.insert(statusEffectOrder, k)
					
					if v.expiry ~= oldStatusEffects[k].expiry then
						oldStatusEffects[k] = {expiry = v.expiry, lastChanged = realTime}
					end
				end
			end
			table.sort(statusEffectOrder, function(a,b)
				local statusEffectA = ply.insaneStats_StatusEffects[a]
				local statusEffectB = ply.insaneStats_StatusEffects[b]
				
				if statusEffectA.expiry ~= statusEffectB.expiry then
					return statusEffectA.expiry > statusEffectB.expiry
				elseif statusEffectA.level ~= statusEffectB.level then
					return statusEffectA.level > statusEffectB.level
				else
					return a < b
				end
			end)
			
			local baseX = scrW * InsaneStats:GetConVarValue("hud_statuseffects_x")
			local baseY = (scrH - #statusEffectOrder * iconSize) * InsaneStats:GetConVarValue("hud_statuseffects_y")
			
			for i,v in ipairs(statusEffectOrder) do
				local statusEffectInfo = registeredEffects[v]
				local statusEffectData = ply.insaneStats_StatusEffects[v]
				local statusEffectColor = statusEffectColors[statusEffectInfo.typ]
				if oldStatusEffects[v].lastChanged + 1 > realTime then
					local lerpFactor = 0.75+(oldStatusEffects[v].lastChanged - realTime)*0.75
					--print(v, lerpFactor)
					statusEffectColor = Color(
						Lerp(lerpFactor, statusEffectColor.r, 255),
						Lerp(lerpFactor, statusEffectColor.g, 255),
						Lerp(lerpFactor, statusEffectColor.b, 255),
						statusEffectColor.a
					)
				end
				
				InsaneStats:DrawMaterialOutlined(
					statusEffectInfo.img,
					baseX,
					baseY+(i-1)*iconSize,
					iconSize,
					iconSize,
					statusEffectColor,
					2,
					Color(0, 0, 0, statusEffectColor.a)
				)
				
				--[[surface.SetMaterial(statusEffectInfo.img)
				-- draw the outline
				surface.SetDrawColor(0,0,0,statusEffectColor.a)
				for j=-2,2 do
					for k=-2,2 do
						if j ~= 0 and k ~= 0 then
							surface.DrawTexturedRect(baseX+j, baseY+(i-1)*iconSize+k, iconSize, iconSize)
						end
					end
				end
				
				surface.SetDrawColor(statusEffectColor.r, statusEffectColor.g, statusEffectColor.b, statusEffectColor.a)
				surface.DrawTexturedRect(baseX, baseY+(i-1)*iconSize, iconSize, iconSize)]]
				
				local title = statusEffectInfo.name
				if statusEffectData.level ~= 1 then
					title = title .. " " .. InsaneStats:FormatNumber(statusEffectData.level)
				end
				draw.SimpleTextOutlined(title, "InsaneStats.Small", baseX+iconSize, baseY+(i-0.5)*iconSize, statusEffectColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, color_black)
				
				local durationText = InsaneStats:FormatNumber(statusEffectData.expiry - CurTime(), {decimals = 1}) .. (statusEffectData.expiry == math.huge and "" or "s")
				draw.SimpleTextOutlined(durationText, "InsaneStats.Small", baseX+iconSize, baseY+(i-0.5)*iconSize, statusEffectColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, color_black)
			end
		end
	end
end)

timer.Create("InsaneStatsWPASS", 1, 0, function()
	if InsaneStats:GetConVarValue("hud_wpass2_lootbeams") then
		for k,v in pairs(ents.GetAll()) do
			if v:InsaneStats_IsWPASS2Pickup() and not IsValid(v:GetOwner()) and not v:IsDormant() then
				if v.insaneStats_Modifiers then
					if not v.insaneStats_WPASS2Name or (v.insaneStats_WPASS2NameLastRefresh or 0) + 5 < RealTime() then
						CreateName(v)
					end
					
					local effData = EffectData()
					effData:SetEntity(v)
					util.Effect("insane_stats_tier", effData)
				else
					v:InsaneStats_MarkForUpdate()
				end
			end
		end
	end
end)