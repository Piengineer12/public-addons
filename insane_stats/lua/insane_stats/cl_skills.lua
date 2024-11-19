InsaneStats:SetDefaultConVarCategory("Skills")

InsaneStats:RegisterClientConVar("hud_skills_enabled", "insanestats_hud_skills_enabled", "1", {
	display = "Skill Statuses", desc = "Enables skill status indicators.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_skills_x", "insanestats_hud_skills_x", "0.5", {
	display = "Skill Statuses X", desc = "Horizontal position of skill status indicators.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_skills_y", "insanestats_hud_skills_y", "0.92", {
	display = "Skill Statuses Y", desc = "Vertical position of skill status indicators.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_skills_size", "insanestats_hud_skills_size", "3", {
	display = "Skill Statuses Size", desc = "Size of skill status indicators.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterClientConVar("hud_skills_per_row", "insanestats_hud_skills_per_row", "0", {
	display = "Skill Statuses Per Row", desc = "Number of skill statuses per row. If set to 0, all skill status indicators will be in a single row.",
	type = InsaneStats.INT, min = 0, max = 100
})

concommand.Add("insanestats_skills_menu", function()
	InsaneStats:CreateSkillMenu()
end, nil, "Opens the skill web.")
concommand.Add("insanestats_skills_reset", function()
	net.Start("insane_stats")
	net.WriteUInt(6, 8)
	net.WriteUInt(4, 4)
	net.WriteUInt(3, 8)
	net.SendToServer()
end, nil, "If manual skill respecs are enabled, this ConCommand respecs all skills.")

local color_gray = InsaneStats:GetColor("gray")
local color_yellow = InsaneStats:GetColor("yellow")
local color_green = InsaneStats:GetColor("green")
local color_aqua = InsaneStats:GetColor("aqua")
local color_black_translucent = InsaneStats:GetColor("black_translucent")

local function CreateSkillButton(parent, skillName)
	local ply = LocalPlayer()
	local skillInfo = InsaneStats:GetSkillInfo(skillName)
	local outlineWidth = InsaneStats:GetOutlineThickness()
	local buttonSize = InsaneStats.FONT_BIG * 2.5 + outlineWidth * 2
	local buttonDistance = 1.5
	local buttonOffset = buttonSize * buttonDistance * 5
	local Button = vgui.Create("DButton", parent)
	local buttonX, buttonY = skillInfo.pos[1] * buttonDistance * buttonSize + buttonOffset, skillInfo.pos[2] * 1.5 * buttonSize + buttonOffset
	Button:SetPos(buttonX, buttonY)
	Button:SetSize(buttonSize, buttonSize)
	Button:SetText("")
	--Button:SetImage("icon16/star.png")

	local oldOnCursorEntered = Button.OnCursorEntered
	function Button:OnCursorEntered(...)
		oldOnCursorEntered(self, ...)
		parent:InsaneStats_SkillHovered(skillName)
	end
	function Button:DoClick()
		if (input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT)) and ply:InsaneStats_CanSealSkills() and not hook.Run("InsaneStatsCannotSealSkill", skillName) then
			ply:InsaneStats_SealSkill(skillName)

			net.Start("insane_stats")
			net.WriteUInt(6, 8)
			net.WriteUInt(2, 4)
			net.WriteUInt(InsaneStats:GetSkillID(skillName) - 1, 8)
			net.SendToServer()

			parent:InsaneStats_SkillHovered(skillName)
			parent:Refresh()
		else
			local currentTier = ply:InsaneStats_GetSkillTier(skillName)
			local max = skillInfo.max or 5
			if ply:InsaneStats_GetSkillPoints() >= 1 and currentTier < max
			or ply:InsaneStats_GetUberSkillPoints() >= 1 and currentTier >= max and currentTier < max * 2 then
				net.Start("insane_stats")
				net.WriteUInt(6, 8)
				net.WriteUInt(0, 4)
				net.WriteUInt(InsaneStats:GetSkillID(skillName) - 1, 8)
				net.SendToServer()
				-- update immediately on client's end
				if currentTier < max then
					ply:InsaneStats_SetSkillTier(skillName, currentTier + 1)
				else
					ply:InsaneStats_SetSkillTier(skillName, currentTier * 2)
				end
				parent:InsaneStats_SkillHovered(skillName)
				parent:Refresh()
			end
		end
	end
	Button.DoDoubleClick = Button.DoClick
	function Button:DoRightClick()
		if (input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT)) and ply:InsaneStats_CanDisableSkills() then
			InsaneStats:DisableSkill(skillName, not InsaneStats:IsSkillDisabled(skillName))

			net.Start("insane_stats")
			net.WriteUInt(6, 8)
			net.WriteUInt(3, 4)
			net.WriteUInt(InsaneStats:GetSkillID(skillName) - 1, 8)
			net.SendToServer()

			parent:InsaneStats_SkillHovered(skillName)
			parent:Refresh()
		else
			local currentTier = ply:InsaneStats_GetSkillTier(skillName)
			local max = skillInfo.max or 5
			if ply:InsaneStats_GetSkillPoints() >= 1 and currentTier < max then
				net.Start("insane_stats")
				net.WriteUInt(6, 8)
				net.WriteUInt(1, 4)
				net.WriteUInt(InsaneStats:GetSkillID(skillName) - 1, 8)
				net.SendToServer()
				-- update immediately on client's end
				local spend = math.min(ply:InsaneStats_GetSkillPoints(), max - currentTier)
				ply:InsaneStats_SetSkillTier(skillName, currentTier + spend)

				parent:InsaneStats_SkillHovered(skillName)
				parent:Refresh()
			else
				self:DoClick()
			end
		end
	end
	function Button:Paint(w, h)
		local disabled = InsaneStats:IsSkillDisabled(skillName)
		local sealed = ply:InsaneStats_IsSkillSealed(skillName)
		local tier = ply:InsaneStats_GetSkillTier(skillName)
		local max = skillInfo.max or 5
		local enabled = self:IsEnabled()
		local color = tier > max and color_aqua
			or tier == max and color_green
			or tier > 0 and color_yellow
			or enabled and color_white
			or color_gray
		local icon = disabled and InsaneStats.DisabledInfo.img
		or sealed and InsaneStats.SealedInfo.img
		or skillInfo.img
		InsaneStats:DrawMaterialOutlined(
			InsaneStats:GetIconMaterial(icon),
			outlineWidth, outlineWidth,
			w - outlineWidth * 2, h - outlineWidth * 2,
			color
		)

		InsaneStats:DrawTextOutlined(
			string.format("%u/%u", tier, max),
			1,
			w-outlineWidth,
			h-outlineWidth,
			color,
			TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
		)
		if not enabled then
			local colorArg = 127 + self.insaneStats_Adjacent / ((skillInfo.minpts or 0) - 1) * 128
			InsaneStats:DrawTextOutlined(
				string.format("%i/%i", self.insaneStats_Adjacent, skillInfo.minpts or 0),
				3,
				w/2,
				h/2,
				Color(colorArg, colorArg, colorArg),
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
			)
		end
	end
	function Button:Refresh()
		local requiredAdjacent = skillInfo.minpts or 0
		local adjacent = -ply:InsaneStats_GetEffectiveSkillValues("master_of_air", 3)

		local x, y = skillInfo.pos[1], skillInfo.pos[2]
		local offsets = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}
		for i, v in ipairs(offsets) do
			local skillName = InsaneStats:GetSkillNameByPosition(x + v[1], y + v[2])
			if skillName then
				adjacent = adjacent + ply:InsaneStats_GetSkillTier(skillName)
			end
		end

		self:SetEnabled(adjacent >= requiredAdjacent)
		self.insaneStats_Adjacent = adjacent
	end
	Button:Refresh()

	return Button
end

local function CreateSkillPanel()
    local Panel = vgui.Create("DPanPanel")
	Panel:SetKeyboardInputEnabled(true)

	local skillButtons = {}
	function Panel:InsaneStats_SetSkillInfoPanel(panel)
		self.insaneStats_SkillInfoPanel = panel
	end
	function Panel:Refresh()
		for i,v in ipairs(skillButtons) do
			v:Refresh()
		end
	end
	function Panel:InsaneStats_SkillHovered(skillName)
		self.insaneStats_SkillInfoPanel:InsaneStats_SkillHovered(skillName)
	end
	function Panel.pnlCanvas:Paint(w, h)
		local halfW, halfH = w/2, h/2
		local p = {
			c = {x=w/2, y=h/2},
			ul = {x=0, y=0},
			ur = {x=w, y=0},
			dl = {x=0, y=h},
			dr = {x=w, y=h}
		}
		draw.NoTexture()

		surface.SetDrawColor(255, 0, 0, 31)
		surface.DrawPoly({p.c, p.ul, p.ur})
		surface.SetDrawColor(127, 0, 255, 31)
		surface.DrawPoly({p.c, p.ur, p.dr})
		surface.SetDrawColor(0, 255, 255, 31)
		surface.DrawPoly({p.c, p.dr, p.dl})
		surface.SetDrawColor(127, 255, 0, 31)
		surface.DrawPoly({p.c, p.dl, p.ul})
	end

	for k,v in pairs(InsaneStats:GetAllSkills()) do
		table.insert(skillButtons, CreateSkillButton(Panel, k))
	end

    -- move the canvas to the center
	local outlineWidth = InsaneStats:GetOutlineThickness()
	local buttonSize = InsaneStats.FONT_BIG * 2.5 + outlineWidth * 2
    Panel.pnlCanvas:SetPos(
		buttonSize * -8 + ScrW()/4,
		buttonSize * -8 + ScrH()/3 - 19 - InsaneStats.FONT_MEDIUM - outlineWidth
	)

    return Panel
end

local function CreateSkillInfoPanel()
	local Panel = vgui.Create("RichText")
	local constantUpdate
	local currentSkill

	function Panel:PerformLayout()
		Panel:SetFontInternal("InsaneStats.Medium")
	end

	function Panel:InsaneStats_SkillHovered(skillName)
		currentSkill = skillName
		local skillInfo = InsaneStats:GetSkillInfo(skillName)

		constantUpdate = skillInfo.no_cache_values
		if not constantUpdate then
			self:Refresh()
		end
	end

	function Panel:Refresh()
		if currentSkill then
			local ply = LocalPlayer()
			local skillInfo = InsaneStats:GetSkillInfo(currentSkill)
			local currentTier = ply:InsaneStats_GetSkillTier(currentSkill)
			local isDisabled = InsaneStats:IsSkillDisabled(currentSkill)
			local isSealed = ply:InsaneStats_IsSkillSealed(currentSkill)
			local skillDesc = isDisabled and InsaneStats.DisabledInfo.desc
			or isSealed and InsaneStats.SealedInfo.desc
			or skillInfo.desc
			local skillValues = isDisabled and function(currentTier, ply)
				local maxTier = skillInfo.max or 5
				local uberText = currentTier > maxTier and InsaneStats.DisabledInfo.desc_uber or ""
				return math.min(currentTier, maxTier), uberText
			end or isSealed and InsaneStats.SealedInfo.values
			or skillInfo.values

			Panel:SetText("")

			Panel:InsertColorChange(255, 255, 0, 255)
			Panel:AppendText(
				isDisabled and InsaneStats.DisabledInfo.name
				or isSealed and InsaneStats.SealedInfo.name
				or skillInfo.name
			)

			if currentTier > 0 then
				local tierDescription = string.format(skillDesc, skillValues(currentTier, ply))
				Panel:InsertColorChange(255, 255, 255, 255)
				Panel:AppendText("\n"..tierDescription)
			end

			if currentTier < (skillInfo.max or 5) then
				local nextTierDescription = string.format(skillDesc, skillValues(currentTier+1, ply))
				Panel:InsertColorChange(255, 255, 0, 255)
				Panel:AppendText("\n\nNext Tier:\n"..nextTierDescription)
			elseif currentTier < (skillInfo.max or 5) * 2 and ply:InsaneStats_GetUberSkillPoints() > 0 then
				local nextTierDescription = string.format(skillDesc, skillValues(currentTier*2, ply))
				Panel:InsertColorChange(0, 255, 255, 255)
				Panel:AppendText("\n\nNext Tier:\n"..nextTierDescription)
			end
		end
	end

	function Panel:Think()
		if constantUpdate then
			self:Refresh()
		end
	end

	return Panel
end

local function CreateSkillHeaders(parent)
	local Header = vgui.Create("DPanel", parent)
	Header:SetTall(InsaneStats.FONT_MEDIUM + InsaneStats:GetOutlineThickness()*2)
	Header:SetZPos(1)
	Header:Dock(TOP)
	function Header:Paint(w, h)
		-- You have X über skill point(s) and Y skill point(s) remaining - next at Level Z
		local ply = LocalPlayer()
		local outlineThickness = InsaneStats:GetOutlineThickness()
		local x = outlineThickness
		x = x + InsaneStats:DrawTextOutlined(
			"You have ", 2, x, outlineThickness,
			color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
		)

		if ply:InsaneStats_GetUberSkillPoints() ~= 0 then
			local skillPoints = ply:InsaneStats_GetUberSkillPoints()
			local text = InsaneStats:FormatNumber(skillPoints)
			x = x + InsaneStats:DrawTextOutlined(
				text, 2, x, outlineThickness,
				skillPoints > 0 and color_aqua or color_white,
				TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
			)
	
			x = x + InsaneStats:DrawTextOutlined(
				" über skill point(s) and ", 2, x, outlineThickness,
				color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
			)
		end

		local skillPoints = ply:InsaneStats_GetSkillPoints()
		local text = InsaneStats:FormatNumber(skillPoints)
		x = x + InsaneStats:DrawTextOutlined(
			text, 2, x, outlineThickness,
			skillPoints > 0 and color_yellow or color_white,
			TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
		)

		x = x + InsaneStats:DrawTextOutlined(
			string.format(
				" skill point(s) remaining",
				ply:InsaneStats_GetTotalSkillPoints()
			),
			2, x, outlineThickness,
			color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
		)

		if skillPoints < ply:InsaneStats_GetTotalSkillPoints() then
			x = x + InsaneStats:DrawTextOutlined(
				string.format(
					" (%u total)",
					ply:InsaneStats_GetTotalSkillPoints()
				),
				2, x, outlineThickness,
				color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
			)
		end

		if InsaneStats:GetConVarValue("xp_enabled") and skillPoints < math.huge then
			x = x + InsaneStats:DrawTextOutlined(
				" - next at ", 2, x, outlineThickness,
				color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
			)
			
			local nextLevel = ply:InsaneStats_GetNextSkillPointLevel()
			text = "Level "..InsaneStats:FormatNumber(nextLevel)
			x = x + InsaneStats:DrawTextOutlined(
				text, 2, x, outlineThickness,
				HSVToColor(InsaneStats:GetXPBarHue(nextLevel), 0.75, 1),
				TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
			)
		end
	end

	local HeaderLabel = vgui.Create("DLabel", parent)
	HeaderLabel:SetWrap(true)
	HeaderLabel:SetFont("InsaneStats.Medium")
	HeaderLabel:SetZPos(2)
	HeaderLabel:Dock(TOP)
	HeaderLabel:SetTextColor(color_gray)
	HeaderLabel:SetTall(0)
	function HeaderLabel:Think()
		local ply = LocalPlayer()
		local texts = {}
		local skillPoints, totalSkillPoints = ply:InsaneStats_GetSkillPoints(), ply:InsaneStats_GetTotalSkillPoints()
		totalSkillPoints = math.min(totalSkillPoints, InsaneStats:GetMaxSkillPoints())
		local uberSkillPoints, totalUberSkillPoints = ply:InsaneStats_GetUberSkillPoints(), ply:InsaneStats_GetTotalUberSkillPoints()
		totalUberSkillPoints = math.min(totalUberSkillPoints, InsaneStats:GetMaxUberSkillPoints())
		local allSkillsMaxed = totalSkillPoints - skillPoints >= InsaneStats:GetMaxSkillPoints()
		local allSkillsUberMaxed = totalUberSkillPoints - uberSkillPoints >= InsaneStats:GetMaxUberSkillPoints()

		if skillPoints > 0 and not allSkillsMaxed then
			table.insert(texts, "Left click to assign 1 skill point. Right click to assign max skill points.")
		end
		if uberSkillPoints > 0 and not allSkillsUberMaxed then
			table.insert(texts, "On a fully upgraded skill, both left click and right click will instead assign 1 über skill point.")
		end
		if totalSkillPoints >= InsaneStats:GetMaxSkillPoints() and not allSkillsMaxed then
			table.insert(texts, "Press Ctrl + Space to assign max skill points to all skills.")
		end
		if totalUberSkillPoints >= InsaneStats:GetMaxUberSkillPoints() and not allSkillsUberMaxed then
			table.insert(texts, "Press Ctrl + Shift + Space to assign max skill points and über skill points to all skills.")
		end
		if ply:InsaneStats_CanSealSkills() then
			table.insert(texts, "Hold Alt before left-clicking a skill to seal / unseal the skill.")
		end
		if ply:InsaneStats_CanDisableSkills() then
			table.insert(texts, "Hold Alt before right-clicking a skill to disable / enable the skill for the whole server (admin only).")
		end
		if totalSkillPoints > skillPoints and bit.band(InsaneStats:GetConVarValue("skills_allow_reset"), 1) ~= 0 then
			table.insert(texts, "Press Ctrl + Delete to respec.")
		end
		texts = table.concat(texts, '\n')
		if self:GetText() ~= texts then
			self:SetText(texts)
		end

		if texts == "" then
			self:SetTall(4)
		else
			self:SizeToContentsY(4)
		end
	end
end

function InsaneStats:CreateSkillMenu(frame)
	-- the frame created by the context menu loses focus when the context menu is closed,
	-- which causes the frame to be uninteractable
	
	local SkillPanel
	-- create a new frame for now until that bug is fixed
	local Main = vgui.Create("DFrame")
	--local Main = frame or vgui.Create("DFrame")
	Main:SetSize(ScrW()/1.5, ScrH()/1.5)
	Main:SetSizable(true)
	Main:Center()
	Main:MakePopup()
	Main:SetTitle("Insane Stats Skills")
	Main.lblTitle:SetFont("InsaneStats.Medium")
	function Main:Paint(w, h)
		draw.RoundedBox(4, 0, 0, w, h, color_black_translucent)
	end
	if InsaneStats:GetConVarValue("skills_enabled") then
		function Main:OnKeyCodePressed(key)
			if input.IsControlDown() then
				if key == KEY_SPACE then
					LocalPlayer():InsaneStats_MaxAllSkills(input.IsShiftDown())
					net.Start("insane_stats")
					net.WriteUInt(6, 8)
					net.WriteUInt(4, 4)
					net.WriteUInt(input.IsShiftDown() and 2 or 1, 8)
					net.SendToServer()

					SkillPanel:Refresh()
				elseif key == KEY_DELETE and bit.band(InsaneStats:GetConVarValue("skills_allow_reset"), 1) ~= 0 then
					LocalPlayer():InsaneStats_SetSkills({})
					LocalPlayer():InsaneStats_SetSealedSkills({})

					net.Start("insane_stats")
					net.WriteUInt(6, 8)
					net.WriteUInt(4, 4)
					net.WriteUInt(3, 8)
					net.SendToServer()

					SkillPanel:Refresh()
				end
			end
		end

		CreateSkillHeaders(Main)

		local Divider = vgui.Create("DHorizontalDivider", Main)
		Divider:SetDividerWidth(4)
		Divider:SetLeftWidth(ScrW()/2)
		Divider:Dock(FILL)

		SkillPanel = CreateSkillPanel()
		Divider:SetLeft(SkillPanel)

		local SkillInfoPanel = CreateSkillInfoPanel()
		Divider:SetRight(SkillInfoPanel)

		SkillPanel:InsaneStats_SetSkillInfoPanel(SkillInfoPanel)
	else
		local HeaderLabel = vgui.Create("DLabel", Main)
		HeaderLabel:SetWrap(true)
		HeaderLabel:SetFont("InsaneStats.Medium")
		HeaderLabel:SetZPos(2)
		HeaderLabel:Dock(TOP)
		HeaderLabel:SetTextColor(color_gray)
		HeaderLabel:SetText("Insane Stats Skills must be enabled for this to function.")
	end
end

if IsValid(LocalPlayer()) then
	net.Start("insane_stats")
	net.WriteUInt(6, 8)
	net.WriteUInt(4, 4)
	net.WriteUInt(0, 8)
	net.SendToServer()
end

hook.Add("InitPostEntity", "InsaneStatsSkills", function()
	net.Start("insane_stats")
	net.WriteUInt(6, 8)
	net.WriteUInt(4, 4)
	net.WriteUInt(0, 8)
	net.SendToServer()
end)

local oldTotalSkillPoints, oldTotalUberSkillPoints = -1, -1
hook.Add("HUDPaint", "InsaneStatsSkills", function()
	local ply = LocalPlayer()
	if InsaneStats:GetConVarValue("skills_enabled") and InsaneStats:GetConVarValue("hud_skills_enabled")
	and IsValid(ply) and InsaneStats:ShouldDrawHUD() then
		local totalSkillPoints = math.min(
			ply:InsaneStats_GetTotalSkillPoints(),
			InsaneStats:GetMaxSkillPoints()
		)
		local totalUberSkillPoints = math.min(
			ply:InsaneStats_GetTotalUberSkillPoints(),
			InsaneStats:GetMaxUberSkillPoints()
		)
		if totalSkillPoints ~= oldTotalSkillPoints then
			if oldTotalSkillPoints >= 0 then
				local diff = totalSkillPoints - oldTotalSkillPoints
				if diff > 0 then
					chat.AddText(string.format(
						"You have gained %s skill point(s)! Open the Insane Stats Skills menu to spend them.",
						InsaneStats:FormatNumber(diff)
					))
				else
					chat.AddText(string.format(
						"You have lost %s skill point(s)!",
						InsaneStats:FormatNumber(-diff)
					))
				end
			end
			oldTotalSkillPoints = totalSkillPoints
		end
		if totalUberSkillPoints ~= oldTotalUberSkillPoints then
			if oldTotalUberSkillPoints >= 0 then
				local diff = totalUberSkillPoints - oldTotalUberSkillPoints
				if diff > 0 then
					chat.AddText(string.format(
						"You have gained %s über skill point(s)! Open the Insane Stats Skills menu to spend them.",
						InsaneStats:FormatNumber(diff)
					))
				else
					chat.AddText(string.format(
						"You have lost %s über skill point(s)!",
						InsaneStats:FormatNumber(-diff)
					))
				end
			end
			oldTotalUberSkillPoints = totalUberSkillPoints
		end
		if ply:IsSuitEquipped() then
			local iconSkills = {}
			for k,v in SortedPairs(InsaneStats:GetAllSkills(), true) do
				if ply:InsaneStats_GetSkillState(k) ~= -2 then
					table.insert(iconSkills, k)
				end
			end

			local baseX = InsaneStats:GetConVarValue("hud_skills_x") * ScrW()
			local baseY = InsaneStats:GetConVarValue("hud_skills_y") * ScrH()
			local skillSize = InsaneStats.FONT_SMALL * InsaneStats:GetConVarValue("hud_skills_size")
			local outlineThickness = InsaneStats:GetOutlineThickness()
			local totalIconSkills = #iconSkills
			local skillsPerRow = InsaneStats:GetConVarValue("hud_skills_per_row")
			skillsPerRow = skillsPerRow < 1 and 65536 or skillsPerRow

			for i,v in ipairs(iconSkills) do
				local skillInfo = InsaneStats:GetSkillInfo(v)
				local skillState = ply:InsaneStats_GetSkillState(v, true)
				local skillStacks = ply:InsaneStats_GetSkillStacks(v, true)
				local skillColor = skillState == 0 and color_white or skillState > 0 and color_aqua or color_gray

				-- what row number is this skill in? (0-indexed)
				local rowY = math.ceil(i / skillsPerRow) - 1

				-- how many skills are in this row?
				local rowSkillCount = math.min(totalIconSkills - rowY * skillsPerRow, skillsPerRow)

				-- what position in row is this skill in? (0-indexed)
				local rowX = i - rowY * skillsPerRow - 1

				local anchorX = baseX + ((rowSkillCount-1)/2 - rowX) * (skillSize + outlineThickness)
				local anchorY = baseY - rowY * (skillSize + outlineThickness)

				InsaneStats:DrawMaterialOutlined(
					InsaneStats:GetIconMaterial(skillInfo.img),
					anchorX - skillSize/2, anchorY - skillSize,
					skillSize, skillSize, skillColor
				)
				if skillStacks ~= 0 then
					local stackText = math.abs(skillStacks) >= 1000 and InsaneStats:FormatNumber(skillStacks) or string.format("%.1f", skillStacks)
					InsaneStats:DrawTextOutlined(
						stackText, 1,
						anchorX + skillSize/2, anchorY, color_white,
						TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
					)
				end
			end
		end
	end
end)

list.Set("DesktopWindows", "InsaneStatsSkills", {
	title = "I. Stats Skills",
	icon = "insane_stats/insane_stats_skills.png",
	init = function(iconPanel, frame)
		InsaneStats:CreateSkillMenu(frame)
	end
})