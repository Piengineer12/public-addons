local markedEntityInfo = {refreshedTime = -999}
local highlightedEntities = {}
local color_yellow = InsaneStats:GetColor("yellow")
local color_green = InsaneStats:GetColor("green")
local color_aqua = InsaneStats:GetColor("aqua")
local color_magenta = InsaneStats:GetColor("magenta")
local color_black_translucent = InsaneStats:GetColor("black_translucent")
local color_gray_translucent = InsaneStats:GetColor("gray_translucent")
local color_white_translucent = InsaneStats:GetColor("white_translucent")
local color_red_translucent = InsaneStats:GetColor("red_translucent")
local color_aqua_translucent = InsaneStats:GetColor("aqua_translucent")

hook.Add("InsaneStatsWPASS2EntityMarked", "InsaneStatsWPASS2", function(entIndex, pos, class, health, maxHealth, armor, maxArmor, lie)
	markedEntityInfo = {
		index = entIndex,
		pos = pos,
		class = lie and InsaneStats:GetFakeClass(entIndex) or class,
		lie = lie,
		hp = health,
		mhp = maxHealth,
		ar = armor,
		mar = maxArmor,
		refreshedTime = CurTime()
	}
end)

hook.Add("InsaneStatsWPASS2EntitiesHighlighted", "InsaneStatsWPASS2", function(highlights)
	for i,v in ipairs(highlights) do
		highlightedEntities[v.index] = {
			pos = v.pos,
			class = v.class,
			start = v.start,
			indicator = v.indicator
		}
	end
end)

--[[
red: danger
yeelow: map
green: healing / shield
gray: weapon / ammo
]]

local revealIcons = {
	["class C_BaseToggle"] = InsaneStats:GetIconMaterial("cursor"),
	func_button = InsaneStats:GetIconMaterial("cursor"),
	func_rot_button = InsaneStats:GetIconMaterial("cursor"),
	momentary_rot_button = InsaneStats:GetIconMaterial("cursor"),
	func_breakable = InsaneStats:GetIconMaterial("asterisk_orange"),
	func_breakable_surf = InsaneStats:GetIconMaterial("asterisk_orange"),
	func_door = InsaneStats:GetIconMaterial("door"),
	func_door_rotating = InsaneStats:GetIconMaterial("door"),
	prop_door_rotating = InsaneStats:GetIconMaterial("door"),
	npc_grenade_frag = InsaneStats:GetIconMaterial("cancel"),
	item_item_crate = InsaneStats:GetIconMaterial("bricks"),
	item_ammo_crate = InsaneStats:GetIconMaterial("newspaper_add"),

	trigger_hurt = InsaneStats:GetIconMaterial("cancel"),
	trigger_push = InsaneStats:GetIconMaterial("weather_clouds"),
	trigger_teleport = InsaneStats:GetIconMaterial("transmit"),
	trigger_once = InsaneStats:GetIconMaterial("transmit"),
	trigger_multiple = InsaneStats:GetIconMaterial("transmit"),

	item_battery = InsaneStats:GetIconMaterial("tag_blue"),
	item_healthcharger = InsaneStats:GetIconMaterial("heart_add"),
	func_healthcharger = InsaneStats:GetIconMaterial("heart_add"),
	item_suitcharger = InsaneStats:GetIconMaterial("tag_blue_add"),
	func_suitcharger = InsaneStats:GetIconMaterial("tag_blue_add"),
}

local function GetIconForEntity(ent)
	local ply = LocalPlayer()
	if (ent == ply or ent:GetOwner() == ply or ent:GetParent() == ply) and ent:GetClass() ~= "npc_grenade_frag" then return end
	if ent:GetNWBool("insanestats_vital") then return InsaneStats:GetIconMaterial("key") end
	if ent:GetNWBool("insanestats_use") then return revealIcons.func_button end
	if ent:GetClass() == "func_breakable_surf" and ent:InsaneStats_GetHealth() <= 0 then return end
	if ent:GetNWBool("insanestats_break") then return InsaneStats:GetIconMaterial("asterisk_orange") end
	if ent:IsWeapon() and not IsValid(ent:GetOwner()) and not ent:IsDormant() then
		return InsaneStats:GetIconMaterial("gun")
	end

	local healingItemType = ent:InsaneStats_GetHealingItemType()
	if healingItemType == 2 then
		return InsaneStats:GetIconMaterial("heart")
	elseif healingItemType == 1 then
		return InsaneStats:GetIconMaterial("newspaper")
	end

	if (ent:GetModel() or "")~="" then
		local icon = revealIcons[ent:GetClass()]
		if icon and not ent.insaneStats_NoTargetID then return icon end
	end
end

local lookPositions
local nextLookPositionsRequestTime = 0
hook.Add("HUDPaint", "InsaneStatsWPASS2", function()
	if InsaneStats:GetConVarValue("hud_wpass2_attributes") and InsaneStats:ShouldDrawHUD() then
		local ply = LocalPlayer()
		local curTime = CurTime()
		local lifeTime = ply:InsaneStats_GetEffectiveSkillValues("ctrl_f")
		local magentaStartExpiryTime = curTime - lifeTime
		local outlineThickness = InsaneStats:GetOutlineThickness()
		if markedEntityInfo.refreshedTime + 2 > curTime and (markedEntityInfo.index or 0) ~= 0 then
			ply:InsaneStats_SetSkillData("alert", 1, 0)
			-- if the entity is valid, update markedEntityInfo
			local ent = Entity(markedEntityInfo.index)
			if (IsValid(ent) and not ent:IsDormant()) then
				-- figure out where the head is positioned
				local pos
				for i=0, (ent:GetHitboxSetCount() or 0)-1 do
					for j=0, ent:GetHitBoxCount(i)-1 do
						if ent:GetHitBoxHitGroup(j, i) == HITGROUP_HEAD then
							local bone = ent:GetHitBoxBone(j, i)
							pos = ent:GetBonePosition(bone)
							break
						end
					end
					if pos then break end
				end
				markedEntityInfo.pos = pos or ent:WorldSpaceCenter()
				markedEntityInfo.lie = select(3, ColorToHSL(ent:GetColor())) < 0.05
				markedEntityInfo.class = markedEntityInfo.lie
				and InsaneStats:GetFakeClass(markedEntityInfo.index) or ent:GetClass()
				--[[markedEntityInfo.hp = ent:InsaneStats_GetHealth()
				markedEntityInfo.mhp = ent:InsaneStats_GetMaxHealth()
				markedEntityInfo.ar = ent:InsaneStats_GetArmor()
				markedEntityInfo.mar = ent:InsaneStats_GetMaxArmor()]]
			end
			
			-- get the entity position in 2D space
			cam.Start3D()
			local toScreenData = markedEntityInfo.pos:ToScreen()
			cam.End3D()
			
			--if toScreenData.visible then
			toScreenData.x = math.Clamp(toScreenData.x, 0, ScrW())
			toScreenData.y = math.Clamp(toScreenData.y, 0, ScrH())
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
			local name = language.GetPhrase(markedEntityInfo.class)..(markedEntityInfo.lie and "?" or "")
			local textPosX = toScreenData.x
			local textPosY = bottomY + outlineThickness
			local texts = {
				name,
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
				InsaneStats:DrawTextOutlined(
					v,
					1,
					textPosX,
					textPosY + (InsaneStats.FONT_SMALL + outlineThickness) * (i - 1),
					color_yellow,
					TEXT_ALIGN_CENTER,
					TEXT_ALIGN_TOP
				)
			end
		else
			ply:InsaneStats_SetSkillData("alert", 0, 0)
		end

		local revealRadius = ply:InsaneStats_GetAttributeValue("reveal") - 1
		+ ply:InsaneStats_GetEffectiveSkillValues("map_sense", 2)
		if revealRadius > 0 then
			local toDraw = {}
			local eyePos = EyePos()

			if not lookPositions and nextLookPositionsRequestTime < curTime then
				nextLookPositionsRequestTime = curTime + 5
				net.Start("insane_stats")
				net.WriteUInt(7, 8)
				net.SendToServer()
			end

			cam.Start3D()
			for i,v in ipairs(ents.FindInSphere(eyePos, revealRadius)) do
				local icon = GetIconForEntity(v)
				if icon then
					local pos = v:WorldSpaceCenter()
					local viewData = pos:ToScreen()
					if viewData.visible then
						local progress = v:GetNW2Float("insanestats_progress")
						local detonateTime = v:GetNW2Float("insanestats_detonatetime")
						if detonateTime > 0 then
							local totalTime = v:GetClass() == "grenade_helicopter" and 5 or 2
							progress = math.Remap(CurTime(), detonateTime - totalTime, detonateTime, 0, 1)
						end
						table.insert(toDraw, {
							icon = icon,
							x = viewData.x,
							y = viewData.y,
							dist = pos:Distance(eyePos),
							progress = progress
						})
					end
				end
			end
			for i,v in ipairs(lookPositions or {}) do
				local dist = v:Distance(eyePos)
				if dist <= revealRadius then
					local viewData = v:ToScreen()
					if viewData.visible then
						table.insert(toDraw, {
							icon = InsaneStats:GetIconMaterial("eye"),
							x = viewData.x,
							y = viewData.y,
							dist = dist,
							progress = 0
						})
					end
				end
			end
			cam.End3D()

			for i,v in ipairs(toDraw) do
				local alpha = (1-v.dist/revealRadius)^2
				surface.SetAlphaMultiplier(math.Clamp(alpha, 0, 1))
				if v.progress > 0 then
					render.SetScissorRect(v.x-12, v.y-12, v.x+12, v.y+12-24*v.progress, true)
					draw.RoundedBox(8, v.x-12, v.y-12, 24, 24, color_black_translucent)
					
					render.SetScissorRect(v.x-12, v.y+12-24*v.progress, v.x+12, v.y+12, true)
					draw.RoundedBox(8, v.x-12, v.y-12, 24, 24, color_gray_translucent)
					render.SetScissorRect(0, 0, 0, 0, false)
				else
					draw.RoundedBox(8, v.x-12, v.y-12, 24, 24, color_black_translucent)
				end
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(v.icon)
				surface.DrawTexturedRect(v.x-8, v.y-8, 16, 16)
				surface.SetAlphaMultiplier(1)
			end
		end

		if next(highlightedEntities) then
			local screenData = {}

			cam.Start3D()
			for k,v in pairs(highlightedEntities) do
				-- if the entity is valid
				local sqrDistToHide = 16384
				local ent = Entity(k)
				if (IsValid(ent) and not ent:IsDormant()) then
					sqrDistToHide = math.max(sqrDistToHide, ent:BoundingRadius()^2)
				end
				
				local distSqr = v.pos:DistToSqr(ply:WorldSpaceCenter())
				if distSqr < sqrDistToHide or v.start > 0 and v.start < magentaStartExpiryTime then
					highlightedEntities[k] = nil
				else
					-- get the entity position in 2D space
					screenData[k] = v.pos:ToScreen()
				end
			end
			cam.End3D()

			for k,v in pairs(highlightedEntities) do
				--local expires = v.start > 0
				local toScreenData = screenData[k]
				--if toScreenData.visible then
				toScreenData.x = math.Clamp(toScreenData.x, 0, ScrW())
				toScreenData.y = math.Clamp(toScreenData.y, 0, ScrH())
				
				-- draw the target indicator
				local alpha = 1 - (curTime - v.start) / lifeTime
				local indicator = v.indicator
				surface.SetAlphaMultiplier(alpha)
				if indicator == 3 then
					surface.DrawCircle(toScreenData.x, toScreenData.y, InsaneStats.FONT_SMALL, 0, 255, 255)
				elseif indicator == 2 then
					surface.DrawCircle(toScreenData.x, toScreenData.y, InsaneStats.FONT_SMALL, 0, 255, 0)
				elseif indicator == 1 then
					surface.DrawCircle(toScreenData.x, toScreenData.y, InsaneStats.FONT_SMALL, 255, 0, 255)
				end
				
				-- draw the target information
				local textPosX = toScreenData.x
				local textPosY = toScreenData.y + InsaneStats.FONT_SMALL + outlineThickness
				
				InsaneStats:DrawTextOutlined(
					language.GetPhrase(v.class), 1,
					textPosX, textPosY,
					indicator == 3 and color_aqua
					or indicator == 2 and color_green
					or indicator == 1 and color_magenta,
					TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP
				)

				--if expires then
					surface.SetAlphaMultiplier(1)
				--end
			end
		end
	end
end)

hook.Add("CreateMove", "InsaneStatsWPASS2", function(usercmd)
	-- during cutscenes the server will not listen to us
	-- this is bad because it ruins the purpose of Fleeting
	local isHoldingCtrl = usercmd:KeyDown(IN_DUCK)
	local ply = LocalPlayer()
	if isHoldingCtrl ~= ply.insaneStats_HoldingCtrl then
		ply.insaneStats_HoldingCtrl = isHoldingCtrl
		net.Start("insane_stats", true)
		net.WriteUInt(4, 8)
		net.WriteBool(isHoldingCtrl)
		net.SendToServer()
	end
end)

hook.Add("InsaneStatsLookPositionsRecieved", "InsaneStatsWPASS2", function(positions)
	lookPositions = positions
end)

hook.Add("Think", "InsaneStatsWPASS2", function()
	for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("pyrotheum")) do
		if IsValid(v) then
			local duration = v:InsaneStats_GetStatusEffectDuration("pyrotheum")
			local alpha = math.log(duration * 2 + 1, 4)
			local desiredColor = HSVToColor(
				math.max(alpha - 1, 0) * 60 % 360,
				1,
				math.min(alpha, 1) / 2
			)
			v:SetColor(desiredColor)
		end
	end
end)

--[[hook.Add("PostDrawTranslucentRenderables", "InsaneStatsWPASS2", function()
	local toSphere = {}
	for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("xp_up_aura")) do
		toSphere[v] = bit.bor(toSphere[v] or 0, 4)
	end
	for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("damage_up_aura")) do
		toSphere[v] = bit.bor(toSphere[v] or 0, 1)
	end
	for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("defence_up_aura")) do
		toSphere[v] = bit.bor(toSphere[v] or 0, 2)
	end

	for k,v in pairs(toSphere) do
		local color = Color(
			bit.band(v, 1) ~= 0 and 255 or 63,
			bit.band(v, 2) ~= 0 and 255 or 63,
			bit.band(v, 4) ~= 0 and 255 or 63,
			127
		)
		render.DrawWireframeSphere(k:WorldSpaceCenter(), 512, 8, 7, color, true)
	end
end)]]

hook.Add("InsaneStatsReloadXBow", "InsaneStatsWPASS2", function(wep, ply)
	if ply:InsaneStats_EffectivelyHasSkill("crunch") then
		return true
	end
end)