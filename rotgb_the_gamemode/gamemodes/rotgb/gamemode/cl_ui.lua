-- real talk, I should probably make an addon to ease the process of making UIs
-- right now there is way too many UI code duplication going on across my addons...
local color_gray = Color(127, 127, 127)
local color_red = Color(255, 0, 0)
local color_light_red = Color(255, 127, 127)
local color_yellow = Color(255, 255, 0)
local color_green = Color(0, 255, 0)
local color_light_green = Color(127, 255, 127)
local color_aqua = Color(0, 255, 255)
local SCOREBOARD_CELL_WIDTH_MULTIPLIERS = {1, 6, 6, 2, 2, 6, {1, 3, 2}, 4}
local SCOREBOARD_PADDING = 2
local SCOREBOARD_CELL_SPACE = 1
local SCOREBOARD_FIELDS = {"Name", "Current Cash", "Score", "Ping", "Level", "Transfer", "Voice", "Kick"}
local SCOREBOARD_FUNCS = {
	[2] = function(ply)
		return ROTGB_FormatCash(ROTGB_GetCash(ply))
	end,
	[3] = function(ply)
		return string.Comma(math.floor(ply.rotgb_gBalloonPops or 0) * 10)
	end,
	[4] = function(ply)
		return string.Comma(ply:Ping())
	end
}

local ROTGB_TRANSFER = 1
local ROTGB_KICK = 6

local FONT_HEADER_HEIGHT = ScreenScale(24)
local FONT_BODY_HEIGHT = ScreenScale(12)
local FONT_SCOREBOARD_HEADER_HEIGHT = ScreenScale(8)
local FONT_SCOREBOARD_BODY_HEIGHT = ScreenScale(8)
local FONT_LEVEL_SMALL_HEIGHT = ScreenScale(6)
local indentX = ScrW()*0.2
local indentY = ScrH()*0.1

surface.CreateFont("rotgb_header", {
	font = "Coolvetica",
	size = FONT_HEADER_HEIGHT
})

surface.CreateFont("rotgb_body", {
	font = "Roboto",
	size = FONT_BODY_HEIGHT
})

surface.CreateFont("rotgb_scoreboard_header", {
	font = "Coolvetica",
	size = FONT_SCOREBOARD_HEADER_HEIGHT
})

surface.CreateFont("rotgb_scoreboard_body", {
	font = "Luckiest Guy",
	size = FONT_SCOREBOARD_BODY_HEIGHT
})

surface.CreateFont("rotgb_level_small", {
	font = "Luckiest Guy",
	size = FONT_LEVEL_SMALL_HEIGHT
})

local function DoNothing()
	-- does nothing
end

local function DrawDarkBackground(panel, w, h)
	surface.SetDrawColor(0,0,0,191)
	surface.DrawRect(0,0,w,h)
end

local function CreateMenu()
	local Menu = vgui.Create("DFrame")
	Menu:SetSize(ScrW(), ScrH())
	Menu:SetDraggable(false)
	Menu.Paint = DrawDarkBackground
	Menu:DockPadding(indentX, indentY, indentX, indentY)
	Menu:MakePopup()
	
	return Menu
end

local function CreateHeader(parent, zPos, text)
	local HeaderText = vgui.Create("DLabel", parent)
	HeaderText:SetFont("rotgb_header")
	HeaderText:SetText(text)
	HeaderText:SetTextColor(color_white)
	HeaderText:SetZPos(zPos)
	HeaderText:Dock(TOP)
	HeaderText:SetWrap(true)
	HeaderText:SetAutoStretchVertical(true)
	
	return HeaderText
end

local function CreateText(parent, zPos, text)
	local BodyText = vgui.Create("DLabel", parent)
	BodyText:SetFont("rotgb_body")
	BodyText:SetText(text)
	BodyText:SetTextColor(color_white)
	BodyText:SetZPos(zPos)
	BodyText:Dock(TOP)
	BodyText:SetWrap(true)
	BodyText:SetAutoStretchVertical(true)
	
	return BodyText
end

local function ButtonSetColor(panel, color)
	panel._Color = color
	panel._HoverColor = Color(127.5 + color.r/2, 127.5 + color.g/2, 127.5 + color.b/2)
end

local function ButtonPaintDetermineColor(panel)
	local drawColor = panel._Color or color_white
	if not panel:IsEnabled() then
		drawColor = color_gray
	elseif panel:IsDown() then
		drawColor = color_white
	elseif panel:IsHovered() then
		drawColor = panel._HoverColor or color_white
	end
	
	if panel:GetTextColor()~=drawColor then
		panel:SetTextColor(drawColor)
	end
	
	return drawColor
end

local function ButtonPaint(panel, w, h)
	local drawColor = ButtonPaintDetermineColor(panel)
	
	draw.RoundedBox(8, 0, 0, w, h, drawColor)
	draw.RoundedBox(8, 4, 4, w-8, h-8, color_black)
end

local function ButtonPaintSmall(panel, w, h)
	local drawColor = ButtonPaintDetermineColor(panel)
	
	draw.RoundedBox(4, 0, 0, w, h, drawColor)
	draw.RoundedBox(4, 2, 2, w-4, h-4, color_black)
end

local function CreateButton(parent, text, color, clickFunc)
	local Button = vgui.Create("DButton", parent)
	Button:SetFont("rotgb_header")
	Button:SetText(text)
	Button:SizeToContentsX(FONT_HEADER_HEIGHT/2)
	Button:SizeToContentsY(FONT_HEADER_HEIGHT/2)
	Button.DoClick = clickFunc
	Button.SetColor = ButtonSetColor
	Button.Paint = ButtonPaint
	
	Button:SetColor(color)
	return Button
end

local function CreateTeamLeftPanel()
	local Panel = vgui.Create("DPanel")
	Panel.CurrentTeam = 0
	
	local AllTeams = team.GetAllTeams()
	for k,v in pairs(AllTeams) do
		if k ~= TEAM_CONNECTING and k ~= TEAM_UNASSIGNED then
			local TeamButton = CreateButton(Panel, "Loading...", v.Color, function()
				hook.Run("HideTeam")
				RunConsoleCommand("changeteam", k)
			end)
			function TeamButton:RefreshText()
				local text = string.format("%s (%u) >", v.Name, team.NumPlayers(k))
				self:SetText(text)
			end
			function TeamButton:Think()
				-- I'd use PANEL:IsHovered() but apparently there is also DButton.Hovered
				-- I wonder if the class variable exists purely due to code spaghetti though, oh well
				if self.Hovered and Panel.CurrentTeam~=k then
					Panel.CurrentTeam = k
					Panel:OnTeamHovered(Panel.CurrentTeam)
				end
				
				if team.NumPlayers(k) ~= self.TeamNum then
					self.TeamNum = team.NumPlayers(k)
					self:RefreshText()
				end
			end
			TeamButton:Dock(TOP)
			TeamButton:SetZPos(k)
			
			if IsValid(LocalPlayer()) and LocalPlayer():Team()==k then
				TeamButton:SetCursor("no")
				TeamButton:SetEnabled(false)
			end
		end
	end
	
	return Panel
end

local function CreateTeamRightPanel()
	local Panel = vgui.Create("DPanel")
	local Header = CreateHeader(Panel, 1, "")
	local DescriptionPanels = {}
	local teamID = LocalPlayer():Team()
	
	function Panel:OnTeamHovered(teamID)
		for k,v in pairs(DescriptionPanels) do
			v:Remove()
		end
		
		Header:SetText(team.GetName(teamID))
		for k,v in pairs(TEAM_DESCRIPTIONS[teamID]) do
			table.insert(DescriptionPanels, CreateText(Panel, k+1, v))
		end
	end
	
	return Panel
end

local function CreateScoreboardNameCell(parent, ply)
	local PFPPanel = vgui.Create("DPanel", parent)
	PFPPanel:SetWide(FONT_SCOREBOARD_BODY_HEIGHT)
	PFPPanel:Dock(LEFT)
	PFPPanel.Paint = DoNothing
	
	local avatarSize = FONT_SCOREBOARD_BODY_HEIGHT
	if avatarSize < 184 then
		avatarSize = bit.lshift(1, math.floor(math.log(avatarSize, 2))) 
	else
		avatarSize = 184
	end
	local PFPImage = vgui.Create("AvatarImage", PFPPanel)
	PFPImage:SetSize(avatarSize, avatarSize)
	PFPImage:SetPlayer(ply, avatarSize)
	function PFPPanel:PerformLayout()
		PFPImage:Center()
	end
	
	local NamePanel = vgui.Create("DLabel", parent)
	NamePanel:Dock(FILL)
	NamePanel:SetFont("rotgb_scoreboard_body")
	function NamePanel:Update()
		NamePanel:SetText(ply:Nick())
		NamePanel:SetTextColor(team.GetColor(ply:Team()))
	end
	NamePanel:Update()
	
	return NamePanel
end

local function CreateScoreboardOtherLevelCell(parent, ply)
	local LevelPanel = vgui.Create("DPanel", parent)
	LevelPanel:SetWide(FONT_SCOREBOARD_BODY_HEIGHT*SCOREBOARD_CELL_WIDTH_MULTIPLIERS[1]*SCOREBOARD_CELL_WIDTH_MULTIPLIERS[5])
	LevelPanel:Dock(RIGHT)
	LevelPanel:SetZPos(-5)
	LevelPanel.Level, LevelPanel.LevelFrac = ply:ROTGB_GetLevel()
	function LevelPanel:Paint(w, h)
		surface.SetFont("rotgb_level_small")
		surface.SetTextPos(0,0)
		surface.SetTextColor(127,0,255)
		surface.DrawText(string.Comma(self.Level))
		
		surface.SetDrawColor(63,0,127)
		surface.DrawRect(0,h*.75,w,h*.25)
		surface.SetDrawColor(127,0,255)
		surface.DrawRect(0,h*.75,w*self.LevelFrac,h*.25)
	end
	function LevelPanel:Update()
		local curXP = ply:ROTGB_GetExperience()
		if self.LastCurXP ~= curXP then
			self.LastCurXP = curXP
			self.Level = ply:ROTGB_GetLevel()
			self.LevelFrac = ply:ROTGB_GetLevelFraction()
			self:SetTooltip(string.format("%s / %s", string.Comma(curXP), string.Comma(ply:ROTGB_GetExperienceNeeded())))
		end
	end
	
	return LevelPanel
end

local function CreateScoreboardTransferCell(parent, ply)
	local TransferButton = CreateButton(parent, "$? >", color_green, function()
		-- the code for this is defined in weapons/rotgb_control.lua in the main RotgB addon, not in this gamemode
		-- also ROTGB_GetTransferAmount is in the main RotgB addon under entities/gballoon_target.lua 
		-- the code is all over the place because I don't want to break older worlds
		net.Start("rotgb_controller")
		net.WriteUInt(ROTGB_TRANSFER, 8)
		net.WriteEntity(v)
		net.SendToServer()
	end)
	
	TransferButton.Paint = ButtonPaintSmall
	TransferButton:SetFont("rotgb_scoreboard_header")
	TransferButton:SetWide(FONT_SCOREBOARD_BODY_HEIGHT*SCOREBOARD_CELL_WIDTH_MULTIPLIERS[1]*SCOREBOARD_CELL_WIDTH_MULTIPLIERS[6])
	TransferButton:Dock(RIGHT)
	TransferButton:SetZPos(-6)
	
	if ply == LocalPlayer() then
		TransferButton:SetCursor("no")
		TransferButton:SetEnabled(false)
	end
	
	function TransferButton:Update()
		self:SetText(string.format("%s >", ROTGB_FormatCash(ROTGB_GetTransferAmount(LocalPlayer())))) -- I feel like I've seen this many brackets before...
	end
	
	return TransferButton
end

local function DrawVolumeBackground(panel, w, h)
	draw.RoundedBox(4, 0, 0, w, h, color_gray)
	draw.RoundedBox(4, 2, 2, w-4, h-4, color_black)
end

local function DrawVolumeSlider(panel, w, h)
	draw.RoundedBox(4, 0, 0, w, h, color_white)
	draw.RoundedBox(4, 2, 2, w-4, h-4, color_black)
end

local function CreateScoreboardVoiceCell(parent, ply)
	local baseWidth = FONT_SCOREBOARD_HEADER_HEIGHT*SCOREBOARD_CELL_WIDTH_MULTIPLIERS[1]
	local cellWidths = SCOREBOARD_CELL_WIDTH_MULTIPLIERS[7]
	local totalWidth = 0
	for k,v in pairs(cellWidths) do
		totalWidth = totalWidth + baseWidth * v
	end
	
	local VoiceCell = vgui.Create("DPanel", parent)
	local VoiceButton = vgui.Create("DImageButton", VoiceCell)
	local VoiceSlider = vgui.Create("DSlider", VoiceCell)
	local VoiceTextEntry = vgui.Create("DTextEntry", VoiceCell)
	
	VoiceCell:SetWide(totalWidth)
	VoiceCell:Dock(RIGHT)
	VoiceCell:SetZPos(-7)
	VoiceCell.VolumeValue = -1
	function VoiceCell:UpdateVolume(newVolume, fromTextEntry)
		if newVolume ~= self.VolumeValue then
			self.VolumeValue = newVolume
			VoiceButton:UpdateImage(newVolume)
			VoiceSlider:SetSlideX(newVolume)
			if not fromTextEntry then
				VoiceTextEntry:SetText(math.Round(newVolume*100))
			end
			if IsValid(ply) then
				ply:SetVoiceVolumeScale(newVolume)
			end
		end
	end
	function VoiceCell:Update()
		if IsValid(ply) then
			VoiceTextEntry:SetTextColor(team.GetColor(ply:Team()))
			VoiceTextEntry:SetCursorColor(team.GetColor(ply:Team()))
		end
	end
	VoiceCell.Paint = DoNothing
	
	VoiceButton:SetWide(baseWidth*cellWidths[1])
	VoiceButton:Dock(LEFT)
	function VoiceButton:DoClick()
		if VoiceCell.VolumeValue > 0 then
			VoiceCell.OldVolume = VoiceCell.VolumeValue
			VoiceCell:UpdateVolume(0)
		else
			VoiceCell:UpdateVolume(VoiceCell.OldVolume or 0.01)
		end
	end
	function VoiceButton:UpdateImage(newVolume)
		if newVolume <= 0 then
			self:SetImage("icon16/sound_none.png")
		elseif newVolume <= 0.5 then
			self:SetImage("icon16/sound_low.png")
		else
			self:SetImage("icon16/sound.png")
		end
	end
	
	VoiceSlider:SetWide(baseWidth*cellWidths[2])
	VoiceSlider:SetTrapInside(true) -- """appears to be non-functioning""" ~GMod Wiki
	VoiceSlider:Dock(FILL)
	VoiceSlider:SetLockY(0.5)
	VoiceSlider.Paint = DrawVolumeBackground
	VoiceSlider.Knob:SetSize(FONT_SCOREBOARD_HEADER_HEIGHT/2, FONT_SCOREBOARD_HEADER_HEIGHT)
	VoiceSlider.Knob.Paint = DrawVolumeSlider
	function VoiceSlider:TranslateValues(x, y)
		VoiceCell:UpdateVolume(x)
		return x, y
	end
	
	VoiceTextEntry:SetFont("rotgb_scoreboard_header")
	VoiceTextEntry:SetWide(baseWidth*cellWidths[3])
	VoiceTextEntry:Dock(RIGHT)
	VoiceTextEntry:SetPaintBackground(false)
	VoiceTextEntry:SetNumeric(true)
	function VoiceTextEntry:OnChange()
		local num = tonumber(self:GetValue())
		if num then
			VoiceCell:UpdateVolume(math.Round(num/100, 2), true)
		end
	end
	
	-- this was the old method, ditched because DNumSlider is a mess
	--[[local NumSlider = vgui.Create("DNumSlider", parent)
	NumSlider:SetWide(FONT_SCOREBOARD_HEADER_HEIGHT*SCOREBOARD_CELL_WIDTH_MULTIPLIERS[6])
	NumSlider:Dock(RIGHT)
	NumSlider:SetZPos(6)
	NumSlider:SetDecimals(2)
	NumSlider:SetMinMax(0, 100)
	NumSlider:SetDefaultValue(100)
	function NumSlider:OnValueChanged(value)
		ply:SetMuted(value <= 0)
		ply:SetVoiceVolumeScale(value / 100)
	end]]
	
	VoiceCell:UpdateVolume(ply:GetVoiceVolumeScale())
	
	return VoiceCell
end

local function CreateScoreboardKickCell(parent, ply)
	local KickButton = CreateButton(parent, "Kick >", color_red, function()
		-- the code for this is defined in weapons/rotgb_control.lua in the main RotgB addon, not in this gamemode
		net.Start("rotgb_scoreboard_header")
		net.WriteUInt(ROTGB_KICK, 8)
		net.WriteEntity(v)
		net.SendToServer()
	end)
	
	KickButton.Paint = ButtonPaintSmall
	KickButton:SetFont("rotgb_scoreboard_header")
	KickButton:SetWide(FONT_SCOREBOARD_BODY_HEIGHT*SCOREBOARD_CELL_WIDTH_MULTIPLIERS[1]*SCOREBOARD_CELL_WIDTH_MULTIPLIERS[8])
	KickButton:Dock(RIGHT)
	KickButton:SetZPos(-8)
	return KickButton
end

local function DrawScoreboardRow(panel, w, h)
	draw.RoundedBox(4, 0, 0, w, h, panel._Color or color_white)
	draw.RoundedBox(4, SCOREBOARD_PADDING, SCOREBOARD_PADDING, w-SCOREBOARD_PADDING*2, h-SCOREBOARD_PADDING*2, color_black)
end

local function CreateScoreboardHeader(parent, zPos)
	local Panel = vgui.Create("DPanel", parent)
	Panel:SetTall(FONT_SCOREBOARD_HEADER_HEIGHT+SCOREBOARD_PADDING*2)
	Panel:SetZPos(zPos)
	Panel:Dock(TOP)
	Panel:DockPadding(SCOREBOARD_PADDING, SCOREBOARD_PADDING, SCOREBOARD_PADDING, SCOREBOARD_PADDING)
	Panel.Paint = DoNothing
	--Panel._Color = teamColor
	
	-- attach the panels in reverse of the SCOREBOARD_FIELDS table
	for i=8,1,-1 do
		local width = SCOREBOARD_CELL_WIDTH_MULTIPLIERS[i]
		if istable(width) then
			local innerwidth = 0
			for k,v in pairs(width) do
				innerwidth = innerwidth + v
			end
			width = innerwidth
		end
		width = width * FONT_SCOREBOARD_BODY_HEIGHT*SCOREBOARD_CELL_WIDTH_MULTIPLIERS[1]
		
		local textCell = vgui.Create("DLabel", Panel)
		textCell:SetText(SCOREBOARD_FIELDS[i])
		textCell:SetFont("rotgb_scoreboard_header")
		textCell:SetTextColor(color_white)
		textCell:SetZPos(-i)
		if i==1 then
			textCell:Dock(FILL)
		else
			textCell:DockMargin(FONT_SCOREBOARD_BODY_HEIGHT*SCOREBOARD_CELL_SPACE,0,0,0)
			textCell:SetWide(width)
			textCell:Dock(RIGHT)
		end
	end
	
	return Panel
end

local function CreateScoreboardRow(parent, ply, zPos)
	local teamColor = team.GetColor(ply:Team())
	local Panel = vgui.Create("DPanel", parent)
	Panel:SetTall(FONT_SCOREBOARD_HEADER_HEIGHT+SCOREBOARD_PADDING*2)
	Panel:SetZPos(zPos)
	Panel:Dock(TOP)
	Panel:DockPadding(SCOREBOARD_PADDING, SCOREBOARD_PADDING, SCOREBOARD_PADDING, SCOREBOARD_PADDING)
	Panel.Paint = DrawScoreboardRow
	Panel.Cells = {}
	--Panel._Color = teamColor
	
	-- attach the panels in reverse of the SCOREBOARD_FIELDS table
	for i=8,1,-1 do
		local cell
		if SCOREBOARD_FUNCS[i] then
			cell = vgui.Create("DLabel", Panel)
			cell:SetWide(FONT_SCOREBOARD_BODY_HEIGHT*SCOREBOARD_CELL_WIDTH_MULTIPLIERS[1]*SCOREBOARD_CELL_WIDTH_MULTIPLIERS[i])
			cell:SetFont("rotgb_scoreboard_body")
			cell:SetTextColor(teamColor)
			cell:SetZPos(-i)
			cell:Dock(RIGHT)
			function cell:Update()
				cell:SetText(SCOREBOARD_FUNCS[i](ply))
			end
		elseif i == 1 then
			cell = CreateScoreboardNameCell(Panel, ply)
		elseif i == 5 then
			cell = CreateScoreboardOtherLevelCell(Panel, ply)
		elseif i == 6 then
			cell = CreateScoreboardTransferCell(Panel, ply)
		elseif i == 7 then
			cell = CreateScoreboardVoiceCell(Panel, ply)
		elseif i == 8 then
			cell = CreateScoreboardKickCell(Panel, ply)
		end
		if i ~= 1 then
			cell:DockMargin(FONT_SCOREBOARD_BODY_HEIGHT*SCOREBOARD_CELL_SPACE,0,0,0)
		end
		Panel.Cells[i] = cell
	end
	
	function Panel:Update()
		if IsValid(ply) then
			self._Color = team.GetColor(ply:Team())
			
			for k,v in pairs(self.Cells) do
				if v.Update then
					v:Update()
				end
			end
		elseif IsValid(parent) then
			parent:MarkScoreboardForRecreation()
		end
	end
	
	return Panel
end

local function CreateScoreboardPanel(parent)
	local Panel = vgui.Create("DScrollPanel", parent)
	Panel:Dock(FILL)
	Panel.PlayerCount = player.GetCount()
	Panel.Scores = {}
	Panel.PlayerOrder = {}
	Panel.ScoreboardRows = {}
	Panel.PlayerTeams = {}
	Panel.ScoreboardNeedsRefresh = false
	-- I have NO idea if the Think function is being used by anything
	-- but better to be safe than sorry
	Panel.OldThink = Panel.Think
	Panel.NextUpdate = 0
	function Panel:Think()
		if self.NextUpdate < RealTime() then
			self.NextUpdate = RealTime() + GAMEMODE.NetSendInterval
			if self.PlayerCount ~= player.GetCount() then
				self.PlayerCount = player.GetCount()
				self:MarkScoreboardForRecreation()
			end
			if self.ScoreboardNeedsRefresh then
				self:RecreateScoreboard()
				self.ScoreboardNeedsRefresh = false
			end
			for k,v in pairs(self.ScoreboardRows) do
				if v.Update then
					v:Update()
				end
			end
		end
		if self.OldThink then
			self:OldThink()
		end
	end
	function Panel:ScoreUpdate(ply, score)
		self.Scores[ply] = score
		local i = 1
		for k,v in SortedPairsByValue(self.Scores, true) do
			if self.PlayerOrder[i] ~= k then
				self:MarkScoreboardForRecreation()
				break
			end
			i = i + 1
		end
	end
	function Panel:MarkScoreboardForRecreation()
		self.ScoreboardNeedsRefresh = true
	end
	function Panel:RecreateScoreboard()
		for k,v in pairs(self.ScoreboardRows) do
			v:Remove()
		end
		table.Empty(self.ScoreboardRows)
		
		self.ScoreboardRows[1] = CreateScoreboardHeader(self, 0)
		table.Empty(self.PlayerOrder)
		for k,v in SortedPairsByValue(self.Scores, true) do
			table.insert(self.PlayerOrder, k)
		end
		for k,v in pairs(self.PlayerOrder) do
			self.ScoreboardRows[k+1] = CreateScoreboardRow(self, v, k)
		end
	end
	
	for k,v in pairs(player.GetAll()) do
		Panel:ScoreUpdate(v, v.rotgb_gBalloonPops or 0)
	end
	Panel:Think()
	return Panel
end

local function CreateMVPPanel(parent, zPos)
	local plys = player.GetAll()
	table.sort(plys, function(ply1, ply2)
		return (ply1.rotgb_gBalloonPops or 0) > (ply2.rotgb_gBalloonPops or 0)
	end)
	local panelHeight = FONT_HEADER_HEIGHT+FONT_BODY_HEIGHT*2*#plys
	
	--[[local Panel = vgui.Create("DPanel", parent)
	Panel:SetTall(panelHeight)
	Panel:Dock(TOP)
	Panel:SetZPos(zPos)
	
	CreateHeader(Panel, 1, "Most Valued Players:")
	
	for i,v in ipairs(plys) do
		local PlayerPanel = vgui.Create("DPanel", parent)
		PlayerPanel:SetTall(FONT_BODY_HEIGHT*2)
		PlayerPanel:Dock(TOP)
		PlayerPanel:SetZPos(i+1)
		PlayerPanel.Paint = ScoreboardRowPaint
		PlayerPanel._Team = v:Team()
	end]]
	
	local Panel = vgui.Create("DListView", parent)
	Panel:SetTall(panelHeight)
	Panel:Dock(TOP)
	Panel:SetZPos(zPos)
	Panel:SetSortable(false)
	Panel:SetHeaderHeight(FONT_HEADER_HEIGHT)
	Panel:SetDataHeight(FONT_BODY_HEIGHT)
	Panel.Paint = DoNothing
	
	local Column1 = Panel:AddColumn("Most Valued Players", 1)
	Column1.Header:SetTextColor(color_white)
	Column1.Header:SetFont("rotgb_header")
	Column1.Header.Paint = DoNothing
	local Column2 = Panel:AddColumn("Damage", 2)
	Column2.Header:SetTextColor(color_white)
	Column2.Header:SetFont("rotgb_header")
	Column2.Header.Paint = DoNothing
	
	for i,v in ipairs(plys) do
		local PlayerRow = Panel:AddLine(v:Nick(), v.rotgb_gBalloonPops or 0)
		PlayerRow:SetFontInternal("rotgb_body")
		PlayerRow.Paint = ScoreboardRowPaint
		PlayerRow._Color = team.GetColor(v:Team())
	end
	
	return Panel
end

local function ExitButtonFunction()
	Derma_Query("Are you sure you want to leave this server?", "#quit", "#GameUI_Yes", function()
		RunConsoleCommand("disconnect")
	end, "#GameUI_No")
end

local function RestartButtonFunction(button)
	Derma_Query("Are you sure you want to start a new game?", "#new_game", "#GameUI_Yes", function()
		net.Start("rotgb_gameend")
		net.SendToServer()
	end, "GameUI_No")
end

local function CreateGameOverButtons(parent, canContinue)
	local ExitButton = CreateButton(parent, "Quit >", color_aqua, ExitButtonFunction)
	ExitButton:SetZPos(1)
	ExitButton:Dock(BOTTOM)
	
	local RestartButton = CreateButton(parent, "Restart >", color_yellow, RestartButtonFunction)
	RestartButton:SetZPos(2)
	RestartButton:Dock(BOTTOM)
	
	if canContinue then
		local ContinueButton = CreateButton(parent, "Continue >", color_green, function()
			parent:Close()
		end)
		ContinueButton:SetZPos(3)
		ContinueButton:Dock(BOTTOM)
	end
end



function GM:CreateStartupMenu()
	local Menu = CreateMenu()
	CreateHeader(Menu, 1, "Welcome to Revenge of the gBalloons: The Gamemode!")
	CreateText(Menu, 2, "RotgB: The Gamemode is a singleplayer / cooperative multiplayer PvE gamemode, where enemy gBalloons are spawned in waves.")
	CreateText(Menu, 3, "Build towers to attack the gBalloons or attack them yourself to pop them.")
	CreateText(Menu, 4, "If the gBalloons reach a gBalloon Target, the gBalloon Target will take damage.")
	CreateText(Menu, 5, "The game ends when all waves have been cleared or all gBalloon Targets have been destroyed.")
	
	local NextButton = CreateButton(Menu, "Continue >", color_green, function()
		hook.Run("ShowHelp")
	end)
	NextButton:SetPos(Menu:GetWide()-NextButton:GetWide()-indentX, Menu:GetTall()-NextButton:GetTall()-indentY)
	
	return Menu
end

function GM:CreateTeamSelectMenu()
	local Menu = CreateMenu()
	CreateHeader(Menu, 1, "Select Your Team")
	
	if LocalPlayer():Team()~=TEAM_UNASSIGNED and LocalPlayer():Team()~=TEAM_SPECTATOR then
		local WarningText = CreateText(Menu, 2, "Changing teams will cause all of your buildings and weapons to be sold!")
		function WarningText:DoFlashAnim()
			WarningText.anim = WarningText:NewAnimation(2, 0, 1, function(anim, panel)
				panel:DoFlashAnim()
			end)
			WarningText.anim.Think = function(anim, panel, frac)
				local delta = frac * 2
				if delta > 1 then
					delta = 2 - delta
				end
				delta = delta * delta
				panel:SetTextColor(Color(255, 255 * delta, 0))
			end
		end
		WarningText:DoFlashAnim()
	end
	
	local Divider = vgui.Create("DHorizontalDivider", Menu)
	Divider:Dock(FILL)
	local LeftPanel = CreateTeamLeftPanel()
	local RightPanel = CreateTeamRightPanel()
	function LeftPanel:OnTeamHovered(teamID)
		RightPanel:OnTeamHovered(teamID)
	end
	Divider:SetLeft(LeftPanel)
	Divider:SetRight(RightPanel)
	Divider:SetDividerWidth(FONT_HEADER_HEIGHT)
	Divider:SetLeftWidth((Menu:GetWide()-FONT_HEADER_HEIGHT)/2-indentX)
	
	return Menu
end

function GM:CreateScoreboard()
	local Menu = CreateMenu()
	CreateHeader(Menu, 1, "Scoreboard")
	
	function Menu:RecreateScoreboard()
		if IsValid(self.Scoreboard) then
			self.Scoreboard:Remove()
		end
		self.Scoreboard = CreateScoreboardPanel(self)
	end
	Menu:RecreateScoreboard()
	
	return Menu
end

function GM:CreateSuccessMenu()
	local Menu = CreateMenu()
	
	local flawless = true
	for k,v in pairs(ents.FindByClass("gballoon_target")) do
		if not v:GetNonVital() and v:GetMaxHealth() > v:Health() then
			flawless = false
		end
	end
	local Header = CreateHeader(Menu, 1, flawless and "Flawless Victory!" or "Victory!")
	Header:SetTextColor(color_light_green)
	
	CreateScoreboardPanel(Menu)
	CreateGameOverButtons(Menu, true)
	
	return Menu
end

function GM:CreateFailureMenu()
	local Menu = CreateMenu()
	
	local flawless = true
	for k,v in pairs(player.GetAll()) do
		if (v.rotgb_gBalloonPops or 0) > 0 then
			flawless = false
		end
	end
	local Header = CreateHeader(Menu, 1, flawless and "Flawless Defeat!" or "Defeat!")
	Header:SetTextColor(color_light_red)
	
	CreateScoreboardPanel(Menu)
	CreateGameOverButtons(Menu)
	
	return Menu
end



function GM:ShowHelp()
	if IsValid(self.StartupMenu) then
		self.StartupMenu:Close()
		self.HasReadHelp = true
	else
		self.StartupMenu = self:CreateStartupMenu()
	end
end

function GM:ShowTeam()
	if IsValid(self.TeamSelectFrame) then
		self.TeamSelectFrame:Close()
	end
	self.TeamSelectFrame = self:CreateTeamSelectMenu()
end

function GM:HideTeam()
	if IsValid(self.TeamSelectFrame) then
		self.TeamSelectFrame:Close()
		self.HasSeenTeams = true
	end
end

function GM:ScoreboardShow()
	if IsValid(self.ScoreboardFrame) then
		self.ScoreboardFrame:Close()
	end
	self.ScoreboardFrame = self:CreateScoreboard()
end

function GM:ScoreboardHide()
	if IsValid(self.ScoreboardFrame) then
		self.ScoreboardFrame:Close()
	end
end

local blockedElements = {
	CHudHealth = true,
	CHudBattery = true,
	CHUDQuickInfo = true
}
function GM:HUDShouldDraw(name)
	if blockedElements[name] then return false end
	
	-- I don't think we should allow other weapons at all, but I'll define the wep.HUDShouldDraw
	-- functionality anyway since it is part of the base gamemode
	local ply = LocalPlayer()
	if IsValid(ply) then
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep.HUDShouldDraw ~= nil then
			return wep.HUDShouldDraw(wep, name)
		end
	end
	
	return true
end

function GM:HUDPaint()
	hook.Run("HUDDrawTargetID")
	hook.Run("DrawDeathNotice", 0.85, 0.04)
end

function GM:GameOver(success)
	if success then
		self.GameOverMenu = hook.Run("CreateSuccessMenu")
	else
		self.GameOverMenu = hook.Run("CreateFailureMenu")
	end
end