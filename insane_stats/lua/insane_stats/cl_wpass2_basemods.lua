local markedEntityInfo = {refreshedTime = -999}
local color_yellow = InsaneStats:GetColor("yellow")

hook.Add("InsaneStatsWPASS2EntityMarked", "InsaneStatsWPASS2", function(entIndex, pos, class, health, maxHealth, armor, maxArmor)
	markedEntityInfo = {
		index = entIndex,
		pos = pos,
		class = class,
		hp = health,
		mhp = maxHealth,
		ar = armor,
		mar = maxArmor,
		refreshedTime = CurTime()
	}
end)

hook.Add("HUDPaint", "InsaneStatsWPASS2", function()
	if InsaneStats:GetConVarValue("wpass2_enabled") and markedEntityInfo.refreshedTime + 1 > CurTime() then
		-- if the entity is valid, update markedEntityInfo
		local ent = Entity(markedEntityInfo.index)
		if (IsValid(ent) and not ent:IsDormant()) then
			markedEntityInfo.pos = ent:WorldSpaceCenter()
			markedEntityInfo.class = ent:GetClass()
			markedEntityInfo.hp = ent:InsaneStats_GetHealth()
			markedEntityInfo.mhp = ent:InsaneStats_GetMaxHealth()
			markedEntityInfo.ar = ent:InsaneStats_GetArmor()
			markedEntityInfo.mar = ent:InsaneStats_GetMaxArmor()
		end
		
		-- get the entity position in 2D space
		cam.Start3D()
		local toScreenData = markedEntityInfo.pos:ToScreen()
		cam.End3D()
		
		if toScreenData.visible then
			-- get the coordinates for the target indicator
			local leftX = toScreenData.x - InsaneStats.FONT_SMALL
			local rightX = toScreenData.x + InsaneStats.FONT_SMALL
			local topY = toScreenData.y - InsaneStats.FONT_SMALL
			local bottomY = toScreenData.y + InsaneStats.FONT_SMALL
			
			-- draw the target indicator
			surface.SetDrawColor(255, 255, 0)
			surface.DrawLine(leftX, topY, rightX, bottomY)
			surface.DrawLine(rightX, topY, leftX, bottomY)
			
			-- draw the target information
			local textPosX = (leftX + rightX) / 2
			local textPosY = bottomY + 2
			local texts = {
				language.GetPhrase(markedEntityInfo.class),
				string.format(
					"Health: %s / %s",
					InsaneStats:FormatNumber(math.floor(markedEntityInfo.hp)),
					InsaneStats:FormatNumber(math.floor(markedEntityInfo.mhp))
				)
			}
			if markedEntityInfo.mar > 0 then
				texts[3] = string.format(
					"Armor: %s / %s",
					InsaneStats:FormatNumber(math.floor(markedEntityInfo.ar)),
					InsaneStats:FormatNumber(math.floor(markedEntityInfo.mar))
				)
			end
			
			for i,v in ipairs(texts) do
				draw.SimpleTextOutlined(
					v,
					"InsaneStats.Small",
					textPosX,
					textPosY + InsaneStats.FONT_SMALL * (i - 1),
					color_yellow,
					TEXT_ALIGN_CENTER,
					TEXT_ALIGN_TOP,
					2,
					color_black
				)
			end
			
		end
	end
end)