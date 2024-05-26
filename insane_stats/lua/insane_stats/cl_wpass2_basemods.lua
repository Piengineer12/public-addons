local markedEntityInfo = {refreshedTime = -999}
local color_yellow = InsaneStats:GetColor("yellow")
local color_black_translucent = InsaneStats:GetColor("black_translucent")
local color_white_translucent = InsaneStats:GetColor("white_translucent")

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

local revealIcons = {
	["class C_BaseEntity"] = InsaneStats:GetIconMaterial("cursor"),
	func_button = InsaneStats:GetIconMaterial("cursor"),
	func_rot_button = InsaneStats:GetIconMaterial("cursor"),
	momentary_rot_button = InsaneStats:GetIconMaterial("cursor"),
	func_breakable = InsaneStats:GetIconMaterial("asterisk_yellow"),
	func_breakable_surf = InsaneStats:GetIconMaterial("asterisk_orange"),
	func_door = InsaneStats:GetIconMaterial("door"),
	func_door_rotating = InsaneStats:GetIconMaterial("door"),
	prop_door_rotating = InsaneStats:GetIconMaterial("door"),
	npc_grenade_frag = InsaneStats:GetIconMaterial("exclamation"),

	trigger_hurt = InsaneStats:GetIconMaterial("error"),
	trigger_push = InsaneStats:GetIconMaterial("weather_clouds"),
	trigger_teleport = InsaneStats:GetIconMaterial("transmit"),
	trigger_once = InsaneStats:GetIconMaterial("transmit"),
	trigger_multiple = InsaneStats:GetIconMaterial("transmit"),
}

local function GetIconForEntity(ent)
	local ply = LocalPlayer()
	if ent == ply or ent:GetOwner() == ply or ent:GetParent() == ply then return end
	if ent:GetNWBool("insanestats_vital") then return InsaneStats:GetIconMaterial("ruby") end
	if ent:GetNWBool("insanestats_use") then return revealIcons.func_button end

	if (ent:GetModel() or "")~="" then
		local icon = revealIcons[ent:GetClass()]
		if icon then return icon end
	end
end

hook.Add("HUDPaint", "InsaneStatsWPASS2", function()
	if InsaneStats:GetConVarValue("hud_wpass2_attributes") and InsaneStats:ShouldDrawHUD() then
		if  markedEntityInfo.refreshedTime + 5 > CurTime() and (markedEntityInfo.index or 0) ~= 0 then
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
				markedEntityInfo.class = ent:GetClass()
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
					InsaneStats:GetConVarValue("hud_outline"),
					color_black
				)
			end
		end

		local ply = LocalPlayer()
		local revealRadius = ply:InsaneStats_GetAttributeValue("reveal") - 1
		+ ply:InsaneStats_GetSkillValues("map_sense")
		if revealRadius > 0 then
			local toDraw = {}
			local eyePos = EyePos()

			cam.Start3D()
			for i,v in ipairs(ents.FindInSphere(eyePos, revealRadius)) do
				local icon = GetIconForEntity(v)
				if icon then
					local pos = v:WorldSpaceCenter()
					local viewData = pos:ToScreen()
					if viewData.visible then
						table.insert(toDraw, {
							icon = icon,
							x = viewData.x,
							y = viewData.y,
							dist = pos:Distance(eyePos),
							progress = v:GetNW2Float("insanestats_progress")
						})
					end
				end
			end
			for i,v in ipairs(InsaneStats.lookPositions or {}) do
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
				draw.RoundedBox(8, v.x-12, v.y-12, 24, 24, color_black_translucent)
				if v.progress > 0 then
					render.SetScissorRect(v.x-12, v.y+12-24*v.progress, v.x+12, v.y+12, true)
					draw.RoundedBox(8, v.x-12, v.y-12, 24, 24, color_white_translucent)
					render.SetScissorRect(0, 0, 0, 0, false)
				end
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(v.icon)
				surface.DrawTexturedRect(v.x-8, v.y-8, 16, 16)
				surface.SetAlphaMultiplier(1)
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