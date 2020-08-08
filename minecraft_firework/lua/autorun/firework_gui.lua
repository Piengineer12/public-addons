if CLIENT then

local fontSize = 16

surface.CreateFont("Minecraft_Piengineer", {
	font = "Minecraft",
	size = fontSize,
	antialias = false
})

local borderMaterials = {
	Material("vgui/minecraft/border/1.png"),
	Material("vgui/minecraft/border/2.png"),
	Material("vgui/minecraft/border/3.png"),
	Material("vgui/minecraft/border/4.png"),
	nil, -- we don't need a texture for a plain square
	Material("vgui/minecraft/border/6.png"),
	Material("vgui/minecraft/border/7.png"),
	Material("vgui/minecraft/border/8.png"),
	Material("vgui/minecraft/border/9.png")
}

local textEntryMaterials = {
	Material("vgui/minecraft/textentry/1.png"),
	Material("vgui/minecraft/textentry/2.png"),
	Material("vgui/minecraft/textentry/3.png"),
	Material("vgui/minecraft/textentry/4.png"),
	nil,
	Material("vgui/minecraft/textentry/6.png"),
	Material("vgui/minecraft/textentry/7.png"),
	Material("vgui/minecraft/textentry/8.png"),
	Material("vgui/minecraft/textentry/9.png")
}

local buttonMaterials = {
	Material("vgui/minecraft/button/disabled.png", "noclamp"),
	Material("vgui/minecraft/button/normal.png", "noclamp"),
	Material("vgui/minecraft/button/hovered.png", "noclamp")
}

local clickSound = Sound("minecraft/click.wav")

local function GUISkinNull()
end

local function GUISkinBackground(self, w, h)
	local x0, y0 = self:GetPos()
	x0, y0 = -x0, -y0
	surface.SetDrawColor(0, 0, 0, 223)
	surface.DrawRect(x0, y0, ScrW(), ScrH())
	
	local cellsize = 16
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(borderMaterials[1])
	surface.DrawTexturedRect(0, 0, cellsize, cellsize)
	surface.SetMaterial(borderMaterials[2])
	surface.DrawTexturedRect(cellsize, 0, w-cellsize*2, cellsize)
	surface.SetMaterial(borderMaterials[3])
	surface.DrawTexturedRect(w-cellsize, 0, cellsize, cellsize)
	surface.SetMaterial(borderMaterials[4])
	surface.DrawTexturedRect(0, cellsize, cellsize, h-cellsize*2)
	surface.SetDrawColor(198, 198, 198)
	surface.DrawRect(cellsize, cellsize, w-cellsize*2, h-cellsize*2)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(borderMaterials[6])
	surface.DrawTexturedRect(w-cellsize, cellsize, cellsize, h-cellsize*2)
	surface.SetMaterial(borderMaterials[7])
	surface.DrawTexturedRect(0, h-cellsize, cellsize, cellsize)
	surface.SetMaterial(borderMaterials[8])
	surface.DrawTexturedRect(cellsize, h-cellsize, w-cellsize*2, cellsize)
	surface.SetMaterial(borderMaterials[9])
	surface.DrawTexturedRect(w-cellsize, h-cellsize, cellsize, cellsize)
	
	surface.SetFont("Minecraft_Piengineer")
	surface.SetTextColor(63, 63, 63)
	surface.SetTextPos(16, 16)
	surface.DrawText(self.CustomText)
end

local function GUISkinTextEntry(self, w, h)
	local cellsize = 2
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(textEntryMaterials[1])
	surface.DrawTexturedRect(0, 0, cellsize, cellsize)
	surface.SetMaterial(textEntryMaterials[2])
	surface.DrawTexturedRect(cellsize, 0, w-cellsize*2, cellsize)
	surface.SetMaterial(textEntryMaterials[3])
	surface.DrawTexturedRect(w-cellsize, 0, cellsize, cellsize)
	surface.SetMaterial(textEntryMaterials[4])
	surface.DrawTexturedRect(0, cellsize, cellsize, h-cellsize*2)
	surface.SetDrawColor(139, 139, 139)
	surface.DrawRect(cellsize, cellsize, w-cellsize*2, h-cellsize*2)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(textEntryMaterials[6])
	surface.DrawTexturedRect(w-cellsize, cellsize, cellsize, h-cellsize*2)
	surface.SetMaterial(textEntryMaterials[7])
	surface.DrawTexturedRect(0, h-cellsize, cellsize, cellsize)
	surface.SetMaterial(textEntryMaterials[8])
	surface.DrawTexturedRect(cellsize, h-cellsize, w-cellsize*2, cellsize)
	surface.SetMaterial(textEntryMaterials[9])
	surface.DrawTexturedRect(w-cellsize, h-cellsize, cellsize, cellsize)
	
	self.OldPaint(self, w, h)
end

local function GUISkinTextEntryValue(self, w, h)
	local cellsize = 2
	surface.SetDrawColor(127, 127, 127)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(0, 0, 0)
	surface.DrawRect(cellsize, cellsize, w-cellsize*2, h-cellsize*2)
	
	self.OldPaint(self, w, h)
end

local function GUISkinForeground(self, w, h)
	local cellsize = 2
	w = self.W or w
	h = self.H or h
	if not self.NoFrame then
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(textEntryMaterials[1])
		surface.DrawTexturedRect(0, 0, cellsize, cellsize)
		surface.SetMaterial(textEntryMaterials[2])
		surface.DrawTexturedRect(cellsize, 0, w-cellsize*2, cellsize)
		surface.SetMaterial(textEntryMaterials[3])
		surface.DrawTexturedRect(w-cellsize, 0, cellsize, cellsize)
		surface.SetMaterial(textEntryMaterials[4])
		surface.DrawTexturedRect(0, cellsize, cellsize, h-cellsize*2)
	end
	surface.SetDrawColor(139, 139, 139)
	surface.DrawRect(cellsize, cellsize, w-cellsize*2, h-cellsize*2)
	if not self.NoFrame then
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(textEntryMaterials[6])
		surface.DrawTexturedRect(w-cellsize, cellsize, cellsize, h-cellsize*2)
		surface.SetMaterial(textEntryMaterials[7])
		surface.DrawTexturedRect(0, h-cellsize, cellsize, cellsize)
		surface.SetMaterial(textEntryMaterials[8])
		surface.DrawTexturedRect(cellsize, h-cellsize, w-cellsize*2, cellsize)
		surface.SetMaterial(textEntryMaterials[9])
		surface.DrawTexturedRect(w-cellsize, h-cellsize, cellsize, cellsize)
	end
end

--[[local function GUISkinColorDouble(self, w, h)
	local cellsize = 2
	surface.SetDrawColor(63, 63, 63)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(self.Color1:Unpack())
	surface.DrawRect(cellsize, cellsize, w-cellsize*2, h/2-cellsize*2)
	surface.SetDrawColor(self.Color2:Unpack())
	surface.DrawRect(cellsize, cellsize+h/2, w-cellsize*2, h/2-cellsize*2)
end]]

local function GUISkinForegroundFrame(self, w, h)
	local cellsize = 2
	w = self.W or w
	h = self.H or h
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(textEntryMaterials[1])
	surface.DrawTexturedRect(0, 0, cellsize, cellsize)
	surface.SetMaterial(textEntryMaterials[2])
	surface.DrawTexturedRect(cellsize, 0, w-cellsize*2, cellsize)
	surface.SetMaterial(textEntryMaterials[3])
	surface.DrawTexturedRect(w-cellsize, 0, cellsize, cellsize)
	surface.SetMaterial(textEntryMaterials[4])
	surface.DrawTexturedRect(0, cellsize, cellsize, h-cellsize*2)
	surface.SetMaterial(textEntryMaterials[6])
	surface.DrawTexturedRect(w-cellsize, cellsize, cellsize, h-cellsize*2)
	surface.SetMaterial(textEntryMaterials[7])
	surface.DrawTexturedRect(0, h-cellsize, cellsize, cellsize)
	surface.SetMaterial(textEntryMaterials[8])
	surface.DrawTexturedRect(cellsize, h-cellsize, w-cellsize*2, cellsize)
	surface.SetMaterial(textEntryMaterials[9])
	surface.DrawTexturedRect(w-cellsize, h-cellsize, cellsize, cellsize)
end

local function GUISkinSlider(self, w, h)
	local hW, hH = w/2, h/2
	local realX, realY = 400, 400
	local u, v = hW/realX, hH/realY
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(buttonMaterials[1])
	surface.DrawTexturedRectUV(0, 0, hW, hH, 0, 0, u, v)
	surface.DrawTexturedRectUV(hW, 0, hW, hH, 1-u, 0, 1, v)
	surface.DrawTexturedRectUV(0, hH, hW, hH, 0, 1-v, u, 1)
	surface.DrawTexturedRectUV(hW, hH, hW, hH, 1-u, 1-v, 1, 1)
end

local function GUISkinButton(self, w, h)
	local hovered = self:IsHovered()
	local disabled = not self:IsEnabled()
	local hW, hH = w/2, h/2
	local realX, realY = 400, 400
	local u, v = hW/realX, hH/realY
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(buttonMaterials[disabled and 1 or hovered and 3 or 2])
	surface.DrawTexturedRectUV(0, 0, hW, hH, 0, 0, u, v)
	surface.DrawTexturedRectUV(hW, 0, hW, hH, 1-u, 0, 1, v)
	surface.DrawTexturedRectUV(0, hH, hW, hH, 0, 1-v, u, 1)
	surface.DrawTexturedRectUV(hW, hH, hW, hH, 1-u, 1-v, 1, 1)
	
	if self.ButtonText then
		surface.SetFont("Minecraft_Piengineer")
		local textW, textH = surface.GetTextSize(self.ButtonText)
		local pointX, pointY = (w-textW)/2, (h-textH)/2
		local shadowOffset = fontSize / 16
		surface.SetTextPos(pointX+shadowOffset, pointY+shadowOffset)
		if self.ColorOverride then
			local r, g, b, a = self.ColorOverride:Unpack()
			surface.SetTextColor(r/4, g/4, b/4, a)
		elseif disabled then
			surface.SetTextColor(42, 42, 42)
		elseif hovered then
			surface.SetTextColor(63, 63, 47)
		else
			surface.SetTextColor(63, 63, 63)
		end
		surface.DrawText(self.ButtonText)
		surface.SetTextPos(pointX-shadowOffset, pointY-shadowOffset)
		if self.ColorOverride then
			surface.SetTextColor(self.ColorOverride:Unpack())
		elseif disabled then	
			surface.SetTextColor(170, 170, 170)
		elseif hovered then
			surface.SetTextColor(255, 255, 191)
		else
			surface.SetTextColor(255, 255, 255)
		end
		surface.DrawText(self.ButtonText)
	end
	
	if self.TrackDepressed ~= self:IsDown() then
		self.TrackDepressed = self:IsDown()
		if self.TrackDepressed then
			surface.PlaySound(clickSound)
		end
	end
end

local function GUISkinButtonDoubleColor(self, w, h)
	local hovered = self:IsHovered()
	local disabled = not self:IsEnabled()
	local hW, hH = w/2, h/2
	local realX, realY = 400, 400
	local u, v = hW/realX, hH/realY
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(buttonMaterials[disabled and 1 or hovered and 3 or 2])
	surface.DrawTexturedRectUV(0, 0, hW, hH, 0, 0, u, v)
	surface.DrawTexturedRectUV(hW, 0, hW, hH, 1-u, 0, 1, v)
	surface.DrawTexturedRectUV(0, hH, hW, hH, 0, 1-v, u, 1)
	surface.DrawTexturedRectUV(hW, hH, hW, hH, 1-u, 1-v, 1, 1)
	
	surface.SetFont("Minecraft_Piengineer")
	local textW, textH = surface.GetTextSize(self.ButtonText1)
	local pointX, pointY = (w-textW)/2, (h*0.5-textH)/2
	local shadowOffset = fontSize / 16
	local r, g, b = self.Color1:Unpack()
	surface.SetTextColor(r/4, g/4, b/4)
	surface.SetTextPos(pointX+shadowOffset, pointY+shadowOffset)
	surface.DrawText(self.ButtonText1)
	surface.SetTextColor(r, g, b)
	surface.SetTextPos(pointX-shadowOffset, pointY-shadowOffset)
	surface.DrawText(self.ButtonText1)
	
	textW, textH = surface.GetTextSize(self.ButtonText2)
	pointX, pointY = (w-textW)/2, (h*1.5-textH)/2
	r, g, b = self.Color2:Unpack()
	surface.SetTextColor(r/4, g/4, b/4)
	surface.SetTextPos(pointX+shadowOffset, pointY+shadowOffset)
	surface.DrawText(self.ButtonText2)
	surface.SetTextColor(r, g, b)
	surface.SetTextPos(pointX-shadowOffset, pointY-shadowOffset)
	surface.DrawText(self.ButtonText2)
	
	if self.TrackDepressed ~= self:IsDown() then
		self.TrackDepressed = self:IsDown()
		if self.TrackDepressed then
			surface.PlaySound(clickSound)
		end
	end
end

local function GUISkinButtonSmaller(self, w, h)
	local hW, hH = w/2-2, h/2-2
	local realX, realY = 400, 400
	local u, v = hW/realX, hH/realY
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(buttonMaterials[not self:IsEnabled() and 1 or self:IsHovered() and 3 or 2])
	surface.DrawTexturedRectUV(2, 2, hW, hH, 0, 0, u, v)
	surface.DrawTexturedRectUV(hW+2, 2, hW, hH, 1-u, 0, 1, v)
	surface.DrawTexturedRectUV(2, hH+2, hW, hH, 0, 1-v, u, 1)
	surface.DrawTexturedRectUV(hW+2, hH+2, hW, hH, 1-u, 1-v, 1, 1)
	
	if self.TrackDepressed ~= self.Depressed then
		self.TrackDepressed = self.Depressed
		if self.TrackDepressed then
			surface.PlaySound(clickSound)
		end
	end
end



local function OverrideSetValue(self, val)
	if (self:GetValue() == val) then return end
	self.Scratch:SetValue(val)
	self:ValueChanged(self:GetValue())
end

local function OverrideValueChanged(self, val)
	if (self.TextArea ~= vgui.GetKeyboardFocus()) then
		self.TextArea:SetValue(self.Scratch:GetTextValue())
	end
	self.Slider:SetSlideX(self.Scratch:GetFraction(val))
	self:OnValueChanged(val)
end

local function FormattedSlider(parent, name, nw, set, def, mn, mx, dec, dw, disallowOverflow)
	local Slider = vgui.Create("DNumSlider", parent)
	Slider:Dock(TOP)
	Slider:SetTall(40)
	Slider:SetText(name)
	Slider:SetMinMax(mn,mx)
	if not disallowOverflow then
		Slider.SetValue = OverrideSetValue
		Slider.ValueChanged = OverrideValueChanged
	end
	Slider:SetValue(set)
	Slider:SetDefaultValue(def)
	Slider:SetDecimals(dec)
	Slider.PerformLayout = function(self) end
	Slider.Label:SetWide(nw)
	Slider.Label:SetFont("Minecraft_Piengineer")
	Slider.Label:SetTextColor(Color(63, 63, 63))
	Slider.Slider.Paint = GUISkinSlider
	Slider.Slider.Knob:SetTall(40)
	Slider.Slider.Knob.Paint = GUISkinButton
	Slider.Slider.OldMousePressed = Slider.Slider.OnMousePressed
	Slider.Slider.OnMousePressed = function(self, mcode)
		if self:IsEnabled() then
			surface.PlaySound(clickSound)
		end
		self:OldMousePressed(mcode)
	end
	
	local SliderTextArea = Slider:GetTextArea()
	SliderTextArea:SetCursorColor(color_white)
	SliderTextArea:SetTextColor(color_white)
	SliderTextArea:SetHighlightColor(Color(0, 0, 255))
	SliderTextArea:SetFont("Minecraft_Piengineer")
	SliderTextArea:SetWide(dw)
	SliderTextArea:DockMargin(8, 0, 0, 0)
	SliderTextArea.OldPaint = SliderTextArea.Paint
	SliderTextArea.Paint = GUISkinTextEntryValue
	
	return Slider
end

local function FormattedScroll(parent)
	local Scroll = vgui.Create("DScrollPanel", parent)
	Scroll:Dock(FILL)
	Scroll.NoFrame = true
	Scroll.Paint = GUISkinForeground
	Scroll.PaintOver = GUISkinForegroundFrame
	Scroll.OldPerformLayout = Scroll.PerformLayout
	
	local Canvas = Scroll:GetCanvas()
	Canvas:DockPadding(2, 2, 2, 2)
	--Canvas.Paint = GUISkinForeground
	Scroll.PerformLayout = function(self)
		self.W = Canvas:GetWide()
		self.OldPerformLayout(self)
	end
	
	local VBar = Scroll:GetVBar()
	VBar:SetWide(32)
	VBar:SetHideButtons(true)
	VBar.Paint = GUISkinForeground
	--VBar.btnUp.Paint = GUISkinButton
	--VBar.btnDown.Paint = GUISkinButton
	VBar.btnGrip.Paint = GUISkinButtonSmaller
	
	return Scroll
end

local function FormattedFrame(w, h, title)
	local Frame = vgui.Create("DFrame")
	Frame:SetSize(w, h)
	Frame:Center()
	Frame:SetTitle("")
	Frame:MakePopup()
	Frame:NoClipping(true)
	Frame:SetSizable(true)
	Frame:ShowCloseButton(false)
	Frame:DockPadding(16, 24 + fontSize, 16, 16)
	Frame.CustomText = title
	Frame.Paint = GUISkinBackground
	
	return Frame
end



local SelectFireworkRocket, WarnFireworkDelete, GetFireworkRocket, GetFireworkStar, GetStarColor, GetColorOrderMod
local FireworkRockets = util.JSONToTable(util.Decompress(file.Read("minecraft_fireworks.dat") or "") or "") or {}
for k,v in pairs(FireworkRockets) do
	for k2,v2 in pairs(v.FireworkStars) do
		for k3,v3 in pairs(v2.Colors) do
			v2.Colors[k3][1] = Color(v3[1].r, v3[1].g, v3[1].b)
			if v3[2] then
				v2.Colors[k3][2] = Color(v3[2].r, v3[2].g, v3[2].b)
			end
		end
	end
end
local ShootVelocity = 1000
local FireworkShapes = {
	{"Sphere", 0},
	{"Star", 17},
	{"Creeper", 18},
	{"Burst", 1},
	{"Lone Star", 19},
	{"Cube", 16},
	{"Atom", 2},
	{"Arch", 3}
}

SelectFireworkRocket = function(func, velocity)
	local Scroll
	
	local Main = FormattedFrame(480, 540, "Minecraft Firework Selection")
	
	local SearchBar = vgui.Create("DTextEntry", Main)
	SearchBar:SetTall(fontSize + 8)
	SearchBar:Dock(TOP)
	SearchBar:SetFont("Minecraft_Piengineer")
	SearchBar:SetContentAlignment(4)
	SearchBar:SetCursorColor(color_white)
	SearchBar:SetTextColor(color_white)
	SearchBar:SetHighlightColor(Color(0, 0, 255))
	SearchBar:SetPlaceholderText("Search...")
	SearchBar:SetPaintBackground(false)
	SearchBar:SetDrawBorder(false)
	SearchBar.OldPaint = SearchBar.Paint
	SearchBar.Paint = GUISkinTextEntry
	SearchBar.OnChange = function(self)
		Scroll:Update(self:GetValue())
	end
	
	Scroll = FormattedScroll(Main)
	Scroll.Update = function(self, searchStr)
		self:Clear()
		
		for k,v in SortedPairs(FireworkRockets) do
			if string.find(k:lower(), searchStr and searchStr:lower() or "", 1, true) then
				local panelHeight = 58
				
				local RocketPanel = vgui.Create("DPanel", Scroll)
				RocketPanel:SetTall(panelHeight)
				RocketPanel:Dock(TOP)
				RocketPanel.Paint = GUISkinNull
				Scroll:AddItem(RocketPanel)
				
				local ControlPanel = vgui.Create("DPanel", RocketPanel)
				ControlPanel:SetWide(80)
				ControlPanel:Dock(RIGHT)
				ControlPanel.Paint = GUISkinNull
				
				local DeleteButton = vgui.Create("DButton", ControlPanel)
				DeleteButton:SetTall(panelHeight/2+1)
				DeleteButton:Dock(BOTTOM)
				DeleteButton:SetText("")
				DeleteButton.ButtonText = "Delete"
				DeleteButton.ColorOverride = Color(255, 85, 85)
				DeleteButton.Paint = GUISkinButton
				DeleteButton.DoClick = function(self)
					Main:Close()
					WarnFireworkDelete(function()
						FireworkRockets[k] = nil
						util.JSONToTable(util.Decompress(file.Read("minecraft_fireworks.dat")))
						file.Write("minecraft_fireworks.dat", util.Compress(util.TableToJSON(FireworkRockets)))
					end, function()
						SelectFireworkRocket(func, velocity)
					end, k)
				end
				
				local ModifyButton = vgui.Create("DButton", ControlPanel)
				ModifyButton:SetTall(panelHeight/2)
				ModifyButton:Dock(TOP)
				ModifyButton:SetText("")
				ModifyButton.ButtonText = "Modify"
				ModifyButton.Paint = GUISkinButton
				ModifyButton.DoClick = function(self)
					Main:Close()
					GetFireworkRocket(function(rocket)
						if k ~= rocket.Name then
							FireworkRockets[k] = nil
						end
						FireworkRockets[rocket.Name] = rocket
						file.Write("minecraft_fireworks.dat", util.Compress(util.TableToJSON(FireworkRockets)))
					end, function()
						SelectFireworkRocket(func, velocity)
					end, table.Copy(FireworkRockets[k]), false)
				end
				
				local SelectButton = vgui.Create("DButton", RocketPanel)
				SelectButton:Dock(FILL)
				SelectButton:SetText("")
				SelectButton.ButtonText = k
				SelectButton.Paint = GUISkinButton
				SelectButton.DoClick = function(self)
					Main:Close()
					func(FireworkRockets[k], ShootVelocity)
				end
			end
		end
	end
	Scroll:Update()
	
	local BottomPanel = vgui.Create("DPanel", Main)
	BottomPanel:SetTall(88)
	BottomPanel:DockMargin(0, 8, 0, 0)
	BottomPanel:Dock(BOTTOM)
	BottomPanel.Paint = GUISkinNull
	
	local VelocitySlider = FormattedSlider(BottomPanel, "Shoot Velocity", 160, velocity, 500, 0, 2000, 0, 80)
	VelocitySlider:DockMargin(0, 0, 0, 8)
	VelocitySlider.OnValueChanged = function(self, value)
		ShootVelocity = value
	end
	ShootVelocity = velocity
	
	local CancelButton = vgui.Create("DButton", BottomPanel)
	CancelButton:SetWide(100)
	CancelButton:DockMargin(8, 0, 0, 0)
	CancelButton:Dock(RIGHT)
	CancelButton:SetText("")
	CancelButton.ButtonText = "Cancel"
	CancelButton.Paint = GUISkinButton 
	CancelButton.DoClick = function(self)
		Main:Close()
	end
	
	local CreateButton = vgui.Create("DButton", BottomPanel)
	CreateButton:Dock(FILL)
	CreateButton:SetText("")
	CreateButton.ButtonText = "Create New Rocket"
	CreateButton.Paint = GUISkinButton
	CreateButton.DoClick = function(self)
		Main:Close()
		GetFireworkRocket(function(rocket)
			FireworkRockets[rocket.Name] = rocket
			file.Write("minecraft_fireworks.dat", util.Compress(util.TableToJSON(FireworkRockets)))
		end, function()
			SelectFireworkRocket(func, velocity)
		end, {
			Name = "",
			Duration = 1,
			FireworkStars = {}
		}, true)
	end
end

WarnFireworkDelete = function(func, funcReturn, name)
	local Main = FormattedFrame(720, 180, "")
	
	local WarnLabel = vgui.Create("DLabel", Main)
	WarnLabel:SetFont("Minecraft_Piengineer")
	WarnLabel:SetText("Are you sure you want to delete this rocket?")
	WarnLabel:SizeToContentsY(2)
	WarnLabel:SetContentAlignment(5)
	WarnLabel:Dock(TOP)
	WarnLabel:SetTextColor(Color(63, 63, 63))
	
	WarnLabel = vgui.Create("DLabel", Main)
	WarnLabel:SetFont("Minecraft_Piengineer")
	WarnLabel:SetText(string.format("'%s' will be lost forever! (A long time!)", name))
	WarnLabel:SizeToContentsY(2)
	WarnLabel:SetContentAlignment(5)
	WarnLabel:Dock(TOP)
	WarnLabel:SetTextColor(Color(63, 63, 63))
	
	local BottomPanel = vgui.Create("DPanel", Main)
	BottomPanel:SetTall(40)
	BottomPanel:DockMargin(0, 8, 0, 0)
	BottomPanel:Dock(BOTTOM)
	BottomPanel.Paint = GUISkinNull
	
	local NoButton = vgui.Create("DButton", BottomPanel)
	NoButton:SetWide(720/2-20)
	NoButton:DockMargin(8, 0, 0, 0)
	NoButton:Dock(RIGHT)
	NoButton:SetText("")
	NoButton.ButtonText = "No"
	NoButton.Paint = GUISkinButton 
	NoButton.DoClick = function(self)
		Main:Close()
		funcReturn()
	end
	
	local YesButton = vgui.Create("DButton", BottomPanel)
	YesButton:Dock(FILL)
	YesButton:SetText("")
	YesButton.ButtonText = "Yes"
	YesButton.Paint = GUISkinButton
	YesButton.DoClick = function(self)
		Main:Close()
		func(name)
		funcReturn()
	end
end

GetFireworkRocket = function(func, funcReturn, fireworkRocket, isNew)
	local Main = FormattedFrame(720, 480, "Edit Firework Rocket")
	
	local Divider = vgui.Create("DHorizontalDivider", Main)
	Divider:Dock(FILL)
	Divider:SetLeftWidth(720/2-20)
	Divider:SetDividerWidth(8)
	
	local LeftPanel = vgui.Create("DPanel", Divider)
	LeftPanel.Paint = GUISkinNull
	Divider:SetLeft(LeftPanel)
	
	local Scroll = FormattedScroll(LeftPanel)
	Scroll.Update = function(self)
		self:Clear()
		
		for k,v in pairs(fireworkRocket.FireworkStars) do
			local panelHeight = 58
			
			local StarPanel = vgui.Create("DPanel", Scroll)
			StarPanel:SetTall(panelHeight)
			StarPanel:Dock(TOP)
			StarPanel.Paint = GUISkinNull
			Scroll:AddItem(StarPanel)
			
			local OrderPanel = vgui.Create("DPanel", StarPanel)
			OrderPanel:SetWide(80)
			OrderPanel:Dock(RIGHT)
			OrderPanel.Paint = GUISkinNull
			
			local MoveButton = vgui.Create("DButton", OrderPanel)
			MoveButton:SetTall(panelHeight/2)
			MoveButton:Dock(TOP)
			MoveButton:SetText("")
			MoveButton.ButtonText = "Move"
			MoveButton.Paint = GUISkinButton
			MoveButton.DoClick = function(self)
				Main:Close()
				GetColorOrderMod(function(order)
					local maxnum = #fireworkRocket.FireworkStars
					print(maxnum)
					table.insert(fireworkRocket.FireworkStars, math.Clamp(order, 1, maxnum), table.remove(fireworkRocket.FireworkStars, k))
				end, function()
					GetFireworkRocket(func, funcReturn, fireworkRocket, isNew)
				end, k)
			end
			
			local DeleteButton = vgui.Create("DButton", OrderPanel)
			DeleteButton:SetTall(panelHeight/2+1)
			DeleteButton:Dock(BOTTOM)
			DeleteButton:SetText("")
			DeleteButton.ButtonText = "Delete"
			DeleteButton.ColorOverride = Color(255, 85, 85)
			DeleteButton.Paint = GUISkinButton
			DeleteButton.DoClick = function(self)
				table.remove(fireworkRocket.FireworkStars, k)
				Scroll:Update()
			end
			
			local ModifyButton = vgui.Create("DButton", StarPanel)
			ModifyButton:Dock(FILL)
			ModifyButton:SetText("")
			local tr, tg, tb, count = 0, 0, 0, #v.Colors
			for k2,v2 in pairs(v.Colors) do
				local pr, pg, pb = v2[1]:Unpack()
				tr = tr + pr
				tg = tg + pg
				tb = tb + pb
			end
			tr = tr / count
			tg = tg / count
			tb = tb / count
			ModifyButton.Color1 = Color(tr, tg, tb)
			ModifyButton.Color2 = color_white
			ModifyButton.ButtonText1 = string.format("Colors: %u", #v.Colors)
			ModifyButton.ButtonText2 = "Shape: " .. FireworkShapes[v.Shape][1]
			ModifyButton.Paint = GUISkinButtonDoubleColor
			ModifyButton.DoClick = function(self)
				Main:Close()
				GetFireworkStar(function(star)
					fireworkRocket.FireworkStars[k] = star
				end, function()
					GetFireworkRocket(func, funcReturn, fireworkRocket, isNew)
				end, table.Copy(fireworkRocket.FireworkStars[k]), false)
			end
			
			--[[local ColorIndictPanel = vgui.Create("DPanel", StarPanel)
			ColorIndictPanel:SetWide(40)
			ColorIndictPanel:Dock(FILL)
			ColorIndictPanel.Color1 = v[1]
			ColorIndictPanel.Color2 = v[2]
			ColorIndictPanel.Paint = GUISkinColorDouble]]
		end
	end
	Scroll:Update()
	
	local CreateButton = vgui.Create("DButton", LeftPanel)
	CreateButton:DockMargin(0, 8, 0, 0)
	CreateButton:SetTall(40)
	CreateButton:Dock(BOTTOM)
	CreateButton:SetText("")
	CreateButton.ButtonText = "Create New Star"
	CreateButton.Paint = GUISkinButton
	CreateButton.DoClick = function(self)
		Main:Close()
		GetFireworkStar(function(star)
			table.insert(fireworkRocket.FireworkStars, star)
		end, function()
			GetFireworkRocket(func, funcReturn, fireworkRocket, isNew)
		end, {
			Colors = {},
			Shape = 1,
			ParticleMul = 1,
			RadiusMul = 1
		}, true)
	end
	
	local RightPanel = vgui.Create("DPanel", Divider)
	RightPanel.Paint = GUISkinNull
	Divider:SetRight(RightPanel)
	
	local DurationSlider = FormattedSlider(RightPanel, "Gunpowder", 120, fireworkRocket.Duration, 1, 1, 3, 2, 60)
	DurationSlider.OnValueChanged = function(self, value)
		fireworkRocket.Duration = value
	end
	
	local NameLabel = vgui.Create("DLabel", RightPanel)
	NameLabel:DockMargin(0, 32, 0, 0)
	NameLabel:Dock(TOP)
	NameLabel:SetText("Custom Name")
	NameLabel:SetTextColor(Color(63, 63, 63))
	NameLabel:SetFont("Minecraft_Piengineer")
	
	local SearchBar = vgui.Create("DTextEntry", RightPanel)
	SearchBar:SetTall(fontSize + 16)
	--SearchBar:DockMargin(0, 8, 0, 0)
	SearchBar:Dock(TOP)
	SearchBar:SetFont("Minecraft_Piengineer")
	SearchBar:SetContentAlignment(4)
	SearchBar:SetCursorColor(color_white)
	SearchBar:SetTextColor(color_white)
	SearchBar:SetHighlightColor(Color(0, 0, 255))
	SearchBar:SetPaintBackground(false)
	SearchBar:SetDrawBorder(false)
	SearchBar:SetValue(fireworkRocket.Name)
	SearchBar.OldPaint = SearchBar.Paint
	SearchBar.Paint = GUISkinTextEntryValue
	
	local CancelButton = vgui.Create("DButton", RightPanel)
	CancelButton:DockMargin(0, 8, 0, 0)
	CancelButton:SetTall(40)
	CancelButton:Dock(BOTTOM)
	CancelButton:SetText("")
	CancelButton.ButtonText = "Cancel"
	CancelButton.Paint = GUISkinButton
	CancelButton.DoClick = function(self)
		Main:Close()
		funcReturn()
	end
	
	local SubmitButton = vgui.Create("DButton", RightPanel)
	SubmitButton:SetTall(40)
	SubmitButton:Dock(BOTTOM)
	SubmitButton:SetText("")
	SubmitButton.ButtonText = isNew and "Finish New Rocket" or "Modify Rocket"
	SubmitButton.Paint = GUISkinButton
	SubmitButton:SetEnabled(#fireworkRocket.Name > 0)
	SubmitButton.DoClick = function(self)
		Main:Close()
		func(fireworkRocket)
		funcReturn()
	end
	SearchBar.OnChange = function(self)
		fireworkRocket.Name = self:GetValue()
		SubmitButton:SetEnabled(#fireworkRocket.Name > 0)
	end
end

GetFireworkStar = function(func, funcReturn, fireworkStar, isNew)
	local SubmitButton
	
	local Main = FormattedFrame(720, 540, "Edit Firework Star")
	
	local Divider = vgui.Create("DHorizontalDivider", Main)
	Divider:Dock(FILL)
	Divider:SetLeftWidth(720/2-20)
	Divider:SetDividerWidth(8)
	
	local LeftPanel = vgui.Create("DPanel", Divider)
	LeftPanel.Paint = GUISkinNull
	Divider:SetLeft(LeftPanel)
	
	local Scroll = FormattedScroll(LeftPanel)
	Scroll.Update = function(self)
		self:Clear()
		
		for k,v in pairs(fireworkStar.Colors) do
			local panelHeight = 58
			
			local ColorPanel = vgui.Create("DPanel", Scroll)
			ColorPanel:SetTall(panelHeight)
			ColorPanel:Dock(TOP)
			ColorPanel.Paint = GUISkinNull
			Scroll:AddItem(ColorPanel)
			
			local OrderPanel = vgui.Create("DPanel", ColorPanel)
			OrderPanel:SetWide(80)
			OrderPanel:Dock(RIGHT)
			OrderPanel.Paint = GUISkinNull
			
			local MoveButton = vgui.Create("DButton", OrderPanel)
			MoveButton:SetTall(panelHeight/2)
			MoveButton:Dock(TOP)
			MoveButton:SetText("")
			MoveButton.ButtonText = "Move"
			MoveButton.Paint = GUISkinButton
			MoveButton.DoClick = function(self)
				Main:Close()
				GetColorOrderMod(function(order)
					local maxnum = #fireworkStar.Colors
					table.insert(fireworkStar.Colors, math.Clamp(order, 1, maxnum), table.remove(fireworkStar.Colors, k))
				end, function()
					GetFireworkStar(func, funcReturn, fireworkStar, isNew)
				end, k)
			end
			
			local DeleteButton = vgui.Create("DButton", OrderPanel)
			DeleteButton:SetTall(panelHeight/2+1)
			DeleteButton:Dock(BOTTOM)
			DeleteButton:SetText("")
			DeleteButton.ButtonText = "Delete"
			DeleteButton.ColorOverride = Color(255, 85, 85)
			DeleteButton.Paint = GUISkinButton
			DeleteButton.DoClick = function(self)
				table.remove(fireworkStar.Colors, k)
				Scroll:Update()
				SubmitButton:SetEnabled(#fireworkStar.Colors > 0)
			end
			
			local ColorButton = vgui.Create("DButton", ColorPanel)
			ColorButton:Dock(FILL)
			ColorButton:SetText("")
			ColorButton.Color1 = v[1]
			ColorButton.Color2 = v[2] or v[1]
			ColorButton.ButtonText1 = string.format("Color: %u %u %u", v[1]:Unpack())
			if v[2] then
				ColorButton.ButtonText2 = string.format("Fade: %u %u %u", v[2]:Unpack())
			else
				ColorButton.ButtonText2 = "Fade: No"
			end
			ColorButton.Paint = GUISkinButtonDoubleColor
			ColorButton.DoClick = function(self)
				Main:Close()
				GetStarColor(function(color, fadeColor)
					fireworkStar.Colors[k] = {color, fadeColor}
				end, function()
					GetFireworkStar(func, funcReturn, fireworkStar, isNew)
				end, v[1], v[2])
			end
			
			--[[local ColorIndictPanel = vgui.Create("DPanel", ColorPanel)
			ColorIndictPanel:SetWide(40)
			ColorIndictPanel:Dock(FILL)
			ColorIndictPanel.Color1 = v[1]
			ColorIndictPanel.Color2 = v[2]
			ColorIndictPanel.Paint = GUISkinColorDouble]]
		end
	end
	Scroll:Update()
	
	local CreateButton = vgui.Create("DButton", LeftPanel)
	CreateButton:DockMargin(0, 8, 0, 0)
	CreateButton:SetTall(40)
	CreateButton:Dock(BOTTOM)
	CreateButton:SetText("")
	CreateButton.ButtonText = "Add Color"
	CreateButton.Paint = GUISkinButton
	CreateButton.DoClick = function(self)
		Main:Close()
		GetStarColor(function(color, fadeColor)
			table.insert(fireworkStar.Colors, {color, fadeColor})
		end, function()
			GetFireworkStar(func, funcReturn, fireworkStar, isNew)
		end)
	end
	
	local RightPanel = vgui.Create("DPanel", Divider)
	RightPanel.Paint = GUISkinNull
	Divider:SetRight(RightPanel)
	
	local ShapeButton = vgui.Create("DButton", RightPanel)
	ShapeButton:SetTall(40)
	ShapeButton:Dock(TOP)
	ShapeButton:SetText("")
	ShapeButton.ButtonText = "Shape: " .. FireworkShapes[fireworkStar.Shape][1]
	ShapeButton.Paint = GUISkinButton
	ShapeButton.DoClick = function(self)
		if input.IsShiftDown() then
			fireworkStar.Shape = (fireworkStar.Shape - 2) % #FireworkShapes + 1
		else
			fireworkStar.Shape = fireworkStar.Shape % #FireworkShapes + 1
		end
		self.ButtonText = "Shape: " .. FireworkShapes[fireworkStar.Shape][1]
	end
	
	local ParticleSlider = FormattedSlider(RightPanel, "Particle Mult.", 140, fireworkStar.ParticleMul, 1, 0.25, 4, 2, 60)
	ParticleSlider:DockMargin(0, 8, 0, 0)
	ParticleSlider.OnValueChanged = function(self, value)
		fireworkStar.ParticleMul = value
	end
	
	local RadiusSlider = FormattedSlider(RightPanel, "Radius Mult.", 140, fireworkStar.RadiusMul, 1, 0.25, 4, 2, 60)
	RadiusSlider:DockMargin(0, 8, 0, 0)
	RadiusSlider.OnValueChanged = function(self, value)
		fireworkStar.RadiusMul = value
	end
	
	local FlickerButton = vgui.Create("DButton", RightPanel)
	FlickerButton:DockMargin(0, 32, 0, 0)
	FlickerButton:SetTall(40)
	FlickerButton:Dock(TOP)
	FlickerButton:SetText("")
	FlickerButton.ButtonText = fireworkStar.Flicker and "Flicker: Yes" or "Flicker: No"
	FlickerButton.Paint = GUISkinButton
	FlickerButton.DoClick = function(self)
		fireworkStar.Flicker = not fireworkStar.Flicker
		self.ButtonText = fireworkStar.Flicker and "Flicker: Yes" or "Flicker: No"
	end
	
	local TrailButton = vgui.Create("DButton", RightPanel)
	TrailButton:DockMargin(0, 8, 0, 0)
	TrailButton:SetTall(40)
	TrailButton:Dock(TOP)
	TrailButton:SetText("")
	TrailButton.ButtonText = fireworkStar.Trail and "Trail: Yes" or "Trail: No"
	TrailButton.Paint = GUISkinButton
	TrailButton.DoClick = function(self)
		fireworkStar.Trail = not fireworkStar.Trail
		self.ButtonText = fireworkStar.Trail and "Trail: Yes" or "Trail: No"
	end
	
	local CancelButton = vgui.Create("DButton", RightPanel)
	CancelButton:DockMargin(0, 8, 0, 0)
	CancelButton:SetTall(40)
	CancelButton:Dock(BOTTOM)
	CancelButton:SetText("")
	CancelButton.ButtonText = "Cancel"
	CancelButton.Paint = GUISkinButton
	CancelButton.DoClick = function(self)
		Main:Close()
		funcReturn()
	end
	
	SubmitButton = vgui.Create("DButton", RightPanel)
	SubmitButton:DockMargin(0, 8, 0, 0)
	SubmitButton:SetTall(40)
	SubmitButton:Dock(BOTTOM)
	SubmitButton:SetText("")
	SubmitButton:SetEnabled(#fireworkStar.Colors > 0)
	SubmitButton.ButtonText = isNew and "Finish New Star" or "Modify Star"
	SubmitButton.Paint = GUISkinButton
	SubmitButton.DoClick = function()
		Main:Close()
		func(fireworkStar)
		funcReturn()
	end
	
	--[[local AdvancedButton = vgui.Create("DButton", RightPanel)
	AdvancedButton:SetTall(40)
	AdvancedButton:Dock(BOTTOM)
	AdvancedButton:SetText("")
	AdvancedButton.ButtonText = "Advanced Options"
	AdvancedButton.Paint = GUISkinButton]]
end

GetStarColor = function(func, funcReturn, color, fadeColor)
	local StarColor = color and Color(color:Unpack()) or Color(255, 255, 255) -- Using "color or Color(255, 255, 255)" here causes weird things to happen!
	local StarFadeColor = fadeColor and Color(fadeColor:Unpack()) or Color(255, 255, 255)
	
	local Main = FormattedFrame(480, 420, "Add Star Color")
	
	local RedSlider = FormattedSlider(Main, "Red", 80, StarColor.r, 255, 0, 255, 0, 60, true)
	local GreenSlider = FormattedSlider(Main, "Green", 80, StarColor.g, 255, 0, 255, 0, 60, true)
	local BlueSlider = FormattedSlider(Main, "Blue", 80, StarColor.b, 255, 0, 255, 0, 60, true)
	local function UpdateTextColors()
		RedSlider:GetTextArea():SetTextColor(StarColor)
		RedSlider:GetTextArea():SetCursorColor(StarColor)
		GreenSlider:GetTextArea():SetTextColor(StarColor)
		GreenSlider:GetTextArea():SetCursorColor(StarColor)
		BlueSlider:GetTextArea():SetTextColor(StarColor)
		BlueSlider:GetTextArea():SetCursorColor(StarColor)
	end
	UpdateTextColors()
	RedSlider.OnValueChanged = function(self, value)
		StarColor.r = math.Round(value)
		UpdateTextColors()
	end
	GreenSlider.OnValueChanged = function(self, value)
		StarColor.g = math.Round(value)
		UpdateTextColors()
	end
	BlueSlider.OnValueChanged = function(self, value)
		StarColor.b = math.Round(value)
		UpdateTextColors()
	end
	
	local FadeButton = vgui.Create("DButton", Main)
	FadeButton:DockMargin(0, 8, 0, 8)
	FadeButton:SetTall(40)
	FadeButton:Dock(TOP)
	FadeButton:SetText("")
	FadeButton.DoFade = not tobool(fadeColor)
	FadeButton.Paint = GUISkinButton
	
	local FadeRedSlider = FormattedSlider(Main, "Red", 80, StarFadeColor.r, 255, 0, 255, 0, 60, true)
	local FadeGreenSlider = FormattedSlider(Main, "Green", 80, StarFadeColor.g, 255, 0, 255, 0, 60, true)
	local FadeBlueSlider = FormattedSlider(Main, "Blue", 80, StarFadeColor.b, 255, 0, 255, 0, 60, true)
	FadeRedSlider:SetEnabled(false)
	FadeGreenSlider:SetEnabled(false)
	FadeBlueSlider:SetEnabled(false)
	FadeRedSlider:GetTextArea():SetTextColor(Color(127, 127, 127))
	FadeGreenSlider:GetTextArea():SetTextColor(Color(127, 127, 127))
	FadeBlueSlider:GetTextArea():SetTextColor(Color(127, 127, 127))
	local function UpdateFadeTextColors()
		FadeRedSlider:GetTextArea():SetTextColor(StarFadeColor)
		FadeRedSlider:GetTextArea():SetCursorColor(StarFadeColor)
		FadeGreenSlider:GetTextArea():SetTextColor(StarFadeColor)
		FadeGreenSlider:GetTextArea():SetCursorColor(StarFadeColor)
		FadeBlueSlider:GetTextArea():SetTextColor(StarFadeColor)
		FadeBlueSlider:GetTextArea():SetCursorColor(StarFadeColor)
	end
	FadeRedSlider.OnValueChanged = function(self, value)
		StarFadeColor.r = math.Round(value)
		UpdateFadeTextColors()
	end
	FadeGreenSlider.OnValueChanged = function(self, value)
		StarFadeColor.g = math.Round(value)
		UpdateFadeTextColors()
	end
	FadeBlueSlider.OnValueChanged = function(self, value)
		StarFadeColor.b = math.Round(value)
		UpdateFadeTextColors()
	end
	FadeButton.DoClick = function(self)
		self.DoFade = not self.DoFade
		if self.DoFade then
			self.ButtonText = "Fade: Yes"
			FadeRedSlider:SetEnabled(true)
			FadeGreenSlider:SetEnabled(true)
			FadeBlueSlider:SetEnabled(true)
			UpdateFadeTextColors()
		else
			self.ButtonText = "Fade: No"
			FadeRedSlider:SetEnabled(false)
			FadeGreenSlider:SetEnabled(false)
			FadeBlueSlider:SetEnabled(false)
			FadeRedSlider:GetTextArea():SetTextColor(Color(127, 127, 127))
			FadeGreenSlider:GetTextArea():SetTextColor(Color(127, 127, 127))
			FadeBlueSlider:GetTextArea():SetTextColor(Color(127, 127, 127))
		end
	end
	FadeButton:DoClick()
	
	local BottomPanel = vgui.Create("DPanel", Main)
	BottomPanel:SetTall(40)
	BottomPanel:DockMargin(0, 8, 0, 0)
	BottomPanel:Dock(BOTTOM)
	BottomPanel.Paint = GUISkinNull
	
	local CancelButton = vgui.Create("DButton", BottomPanel)
	CancelButton:SetWide(100)
	CancelButton:DockMargin(8, 0, 0, 0)
	CancelButton:Dock(RIGHT)
	CancelButton:SetText("")
	CancelButton.ButtonText = "Cancel"
	CancelButton.Paint = GUISkinButton 
	CancelButton.DoClick = function(self)
		Main:Close()
		funcReturn()
	end
	
	local CreateButton = vgui.Create("DButton", BottomPanel)
	CreateButton:Dock(FILL)
	CreateButton:SetText("")
	CreateButton.ButtonText = "Accept"
	CreateButton.Paint = GUISkinButton
	CreateButton.DoClick = function(self)
		Main:Close()
		func(StarColor, FadeButton.DoFade and StarFadeColor or nil)
		funcReturn()
	end
end

GetColorOrderMod = function(func, funcReturn, order)
	local desiredOrder = order
	local MoveButton
	
	local Main = FormattedFrame(360, 150, "Move To...")
	
	local TopPanel = vgui.Create("DPanel", Main)
	TopPanel:SetTall(fontSize + 16)
	TopPanel:DockMargin(0, 0, 0, 0)
	TopPanel:Dock(TOP)
	TopPanel.Paint = GUISkinNull
	
	local PositionLabel = vgui.Create("DLabel", TopPanel)
	PositionLabel:SetFont("Minecraft_Piengineer")
	PositionLabel:SetText("Numeric Position")
	PositionLabel:SizeToContentsX(8)
	PositionLabel:Dock(LEFT)
	PositionLabel:SetTextColor(Color(63, 63, 63))
	
	local OrderBar = vgui.Create("DTextEntry", TopPanel)
	--OrderBar:DockMargin(0, 8, 0, 0)
	OrderBar:Dock(FILL)
	OrderBar:SetFont("Minecraft_Piengineer")
	OrderBar:SetContentAlignment(4)
	OrderBar:SetCursorColor(color_white)
	OrderBar:SetTextColor(color_white)
	OrderBar:SetHighlightColor(Color(0, 0, 255))
	OrderBar:SetPaintBackground(false)
	OrderBar:SetDrawBorder(false)
	OrderBar:SetValue(order)
	OrderBar.OldPaint = OrderBar.Paint
	OrderBar.Paint = GUISkinTextEntry
	OrderBar.OnChange = function(self)
		desiredOrder = tonumber(self:GetValue())
		if (desiredOrder and desiredOrder % 1 == 0) then
			MoveButton:SetEnabled(true)
		else
			MoveButton:SetEnabled(false)
		end
	end
	
	local BottomPanel = vgui.Create("DPanel", Main)
	BottomPanel:SetTall(40)
	BottomPanel:DockMargin(0, 8, 0, 0)
	BottomPanel:Dock(BOTTOM)
	BottomPanel.Paint = GUISkinNull
	
	local CancelButton = vgui.Create("DButton", BottomPanel)
	CancelButton:SetWide(100)
	CancelButton:DockMargin(8, 0, 0, 0)
	CancelButton:Dock(RIGHT)
	CancelButton:SetText("")
	CancelButton.ButtonText = "Cancel"
	CancelButton.Paint = GUISkinButton 
	CancelButton.DoClick = function(self)
		Main:Close()
		funcReturn()
	end
	
	MoveButton = vgui.Create("DButton", BottomPanel)
	MoveButton:Dock(FILL)
	MoveButton:SetText("")
	MoveButton.ButtonText = "Move"
	MoveButton.Paint = GUISkinButton
	MoveButton.DoClick = function(self)
		Main:Close()
		func(tonumber(desiredOrder))
		funcReturn()
	end
end

MFR_SelectFireworkRocket = SelectFireworkRocket

end