HUD_PLUS = HUD_PLUS or {}



HUD = HUD or {}
if istable(HUD) then
	HUD.PLUS = {} -- I keep doing the mistake of using HUD.PLUS instead of HUD_PLUS.
	local HUD_PLUS_META = {
		__index = function(tab,key)
			return HUD_PLUS[key]
		end,
		__newindex = function(tab,key,value)
			HUD_PLUS[key] = value
		end
	}
	setmetatable(HUD.PLUS,HUD_PLUS_META)
end



HUD_PLUS.FontName = "Roboto"
HUD_PLUS.FontSize = 16
HUD_PLUS.FontBold = false
HUD_PLUS.FontItalic = false
HUD_PLUS.FontUnderline = false
HUD_PLUS.FontAntiAlias = true
HUD_PLUS.FontShadow = false
HUD_PLUS.FontAdditive = false
HUD_PLUS.RecreateFont = function()
	surface.CreateFont("HUD+",{
		font=HUD_PLUS.FontName,
		size=HUD_PLUS.FontSize,
		weight=HUD_PLUS.FontBold and 800 or 500,
		italic=HUD_PLUS.FontItalic,
		underline=HUD_PLUS.FontUnderline,
		antialias=HUD_PLUS.FontAntiAlias,
		shadow=HUD_PLUS.FontShadow,
		additive=HUD_PLUS.FontAdditive
	})
end
HUD_PLUS.RecreateFont()



HUD_PLUS.enabled = true
HUD_PLUS.backgroundColor = Color(0,0,0,127)
HUD_PLUS.foregroundColor = Color(0,255,0)
HUD_PLUS.cornerRadius = 8
HUD_PLUS.extraRadius = 8
HUD_PLUS.signal_rate = 5
HUD_PLUS.unittable = {
	data = {"B","KiB","MiB","GiB","TiB"}
}
HUD_PLUS.GetUnit = function(self,typ,mag)
	return self.unittable[typ][mag]
end
HUD_PLUS.MaterialTable = {}
HUD_PLUS.GetMaterial = function(self,name)
	if not self.MaterialTable[name] then
		self.MaterialTable[name] = Material(name)
	end
	return self.MaterialTable[name]
end
HUD_PLUS.DoNothing = function(...)
	return ...
end



HUD_PLUS.lastmem = 0
HUD_PLUS.maxmem = HUD_PLUS.maxmem or 0
HUD_PLUS.mem_x = 0.8
HUD_PLUS.mem_y = 0.1
HUD_PLUS.__memory = {}
HUD_PLUS.DrawMem = true
HUD_PLUS.DrawMemHUD = function(self)
	if not self.DrawMem then return false end
	local sw,sh = self.ScrW,self.ScrH
	local xm,ym = sw*self.mem_x,sh*self.mem_y
	local oym = ym
	local maxw,t1,t2 = 0
	local kbs = collectgarbage("count")
	local texts = {
		"GLua Client Memory Usage:",
		string.format("   Bytes: %s %s (%.1f %s)",string.Comma(kbs*1024),self:GetUnit("data",1),kbs/1024,self:GetUnit("data",3)),
		string.format("   Highest: %.1f %s (%.1f%%)",self.maxmem/1024,self:GetUnit("data",3),kbs/self.maxmem*100),
		string.format("   Delta: %.1f %s/frame (%.1f %s/s)",kbs - self.lastmem,self:GetUnit("data",2),(kbs - self.lastmem)/RealFrameTime()/1024,self:GetUnit("data",3))
	}
	surface.SetFont("HUD+")
	surface.SetTextColor(self.foregroundColor)
	for k,v in pairs(texts) do
		t1,t2 = surface.GetTextSize(v)
		maxw = math.max(maxw,t1)
		HUD_PLUS.__memory[k] = ym
		ym = ym + t2
	end
	if self.backgroundColor.a > 0 then
		draw.RoundedBox(self.cornerRadius,xm-self.extraRadius,oym-self.extraRadius,maxw+self.extraRadius*2,ym-oym+self.extraRadius*2,self.backgroundColor)
	end
	for k,v in pairs(texts) do
		surface.SetTextPos(xm,HUD_PLUS.__memory[k])
		surface.DrawText(v)
	end
	self.maxmem = math.max(self.maxmem,kbs)
	self.lastmem = kbs
end



HUD_PLUS.curmem_server = 0
HUD_PLUS.lastmem_server = 0
HUD_PLUS.curmem_server_timestamp = 0
HUD_PLUS.lastmem_server_timestamp = 0
HUD_PLUS.maxmem_server = HUD_PLUS.maxmem_server or 0
HUD_PLUS.mems_x = 0.8
HUD_PLUS.mems_y = 0.2
HUD_PLUS.DrawServerMem = true
HUD_PLUS.DrawBasicMemUnits = false
HUD_PLUS.DrawServerMemHUD = function(self)
	if not self.DrawServerMem then return false end
	if self.curmem_server_timestamp == 0 then return false end
	local sw,sh = self.ScrW,self.ScrH
	local xm,ym = sw*self.mems_x,sh*self.mems_y
	local oym = ym
	local maxw,t1,t2 = 0
	local kbs = self.curmem_server
	local texts = {
		"GLua Server Memory Usage:",
		string.format("   Bytes: %s %s (%.1f %s)",string.Comma(kbs*1024),self:GetUnit("data",1),kbs/1024,self:GetUnit("data",3)),
		string.format("   Highest: %.1f %s (%.1f%%)",self.maxmem_server/1024,self:GetUnit("data",3),kbs/self.maxmem_server*100),
		string.format("   Delta: %.1f %s/s",(kbs - self.lastmem_server)/(self.curmem_server_timestamp - self.lastmem_server_timestamp)/1024,self:GetUnit("data",3))
	}
	surface.SetFont("HUD+")
	surface.SetTextColor(self.foregroundColor)
	for k,v in pairs(texts) do
		t1,t2 = surface.GetTextSize(v)
		maxw = math.max(maxw,t1)
		HUD_PLUS.__memory[k] = ym
		ym = ym + t2
	end
	if self.backgroundColor.a > 0 then
		draw.RoundedBox(self.cornerRadius,xm-self.extraRadius,oym-self.extraRadius,maxw+self.extraRadius*2,ym-oym+self.extraRadius*2,self.backgroundColor)
	end
	for k,v in pairs(texts) do
		surface.SetTextPos(xm,HUD_PLUS.__memory[k])
		surface.DrawText(v)
	end
end



HUD_PLUS.lastentscantime = 0
HUD_PLUS.itements = {}
local large_ammo = "icon16/package_add.png"
local small_ammo = "icon16/package.png"
local doors = "icon16/door.png"
HUD_PLUS.itemtable = {
	item_healthkit = "icon16/heart_add.png",
	item_healthvial = "icon16/heart.png",
	item_battery = "icon16/lightning.png",
	item_ammo_357 = small_ammo,
	item_ammo_357_large = large_ammo,
	item_ammo_ar2 = small_ammo,
	item_ammo_ar2_large = large_ammo,
	item_ammo_ar2_altfire = large_ammo,
	item_ammo_crossbow = large_ammo,
	item_ammo_pistol = small_ammo,
	item_ammo_pistol_large = large_ammo,
	item_box_buckshot = large_ammo,
	item_rpg_round = large_ammo,
	item_ammo_smg1 = small_ammo,
	item_ammo_smg1_large = large_ammo,
	item_ammo_smg1_grenade = large_ammo,
	["class C_BaseEntity"] = "icon16/magnifier.png",
	func_door = doors,
	prop_door_rotating = doors,
	func_door_rotating = doors,
	combine_mine = "icon16/bomb.png",
	npc_grenade_frag = "icon16/exclamation.png",
	grenade_helicopter = "icon16/exclamation.png",
	item_healthcharger = "icon16/folder_heart.png",
	item_suitcharger = "icon16/folder_lightbulb.png",
	item_ammo_crate = "icon16/box.png",
}
HUD_PLUS.itemstartfade = 64
HUD_PLUS.itemendfade = 256
HUD_PLUS.itemhudsize = 32
HUD_PLUS.itemhudpanelsizeratio = 1.5
HUD_PLUS.DrawItemLocations = true
HUD_PLUS.DrawItemLocationsHUD = function(self)
	if not self.DrawItemLocations then return false end
	if self.lastentscantime < RealTime() then
		--self.lastentscantime = RealTime() + 1/self.signal_rate
		self.itements = ents.FindInSphere(self.EyePos,self.itemendfade*2)
	end
	cam.Start3D()
	for k,v in pairs(self.itements) do
		if (IsValid(v) and (self.itemtable[v:GetClass()] or v:IsWeapon() and not IsValid(v.Owner)) and v:GetModel() and v:GetModel()~="" and self.LocalPlayer:IsLineOfSightClear(v)) then
			local pos = v:GetPos()+v:OBBCenter()
			local lengthsqr = self.EyePos:DistToSqr(pos)
			local dat = pos:ToScreen()
			if dat.visible then
				self.__memory[v] = {dat.x,dat.y,lengthsqr}
			end
		end
	end
	cam.End3D()
	cam.PopModelMatrix()
	local ih = self.itemhudsize
	local ih2 = ih/2
	local ih2r = ih2*self.itemhudpanelsizeratio
	local ihr = ih*self.itemhudpanelsizeratio
	for ent,tab in pairs(self.__memory) do
		if IsValid(ent) then
			local pX,pY,lengthsqr = unpack(tab)
			surface.SetAlphaMultiplier(math.Clamp(math.Remap(lengthsqr,self.itemstartfade*self.itemstartfade,self.itemendfade*self.itemendfade,1,0),0,1))
			draw.RoundedBox(self.cornerRadius,pX-ih2r,pY-ih2r,ihr,ihr,self.backgroundColor)
			surface.SetDrawColor(color_white)
			surface.SetMaterial(self:GetMaterial(self.itemtable[ent:GetClass()] or "icon16/gun.png"))
			surface.DrawTexturedRect(pX-ih2,pY-ih2,ih,ih)
			surface.SetAlphaMultiplier(1)
		end
	end
	cam.PushModelMatrix(self.Matrix)
end



HUD_PLUS.MinHealthBarWidth = 0.1
HUD_PLUS.HealthBarHeight = 8
HUD_PLUS.HealthBarColor = Color(255,0,0)
HUD_PLUS.HealthBackgroundBarColor = Color(0,0,0)
HUD_PLUS.ArmorBarColor = Color(0,255,255)
HUD_PLUS.TargetIDX = 0.5
HUD_PLUS.TargetIDY = 0.2
HUD_PLUS.TargetIDDynamic = true
HUD_PLUS.DrawTargetID = true
HUD_PLUS.CachedEntity = NULL
HUD_PLUS.EntityNextFade = 0
HUD_PLUS.TargetIDFadeTime = 1
HUD_PLUS.TranslateClass = true
HUD_PLUS.ShowZeroHealth = false
local customnames = {}
HUD_PLUS.GetNameFunction = function(self,ent)
	return customnames[ent:GetClass()] or ent:IsPlayer() and ent:Nick() or not self.TranslateClass and ent:GetClass() or ent.PrintName or language.GetPhrase(ent:GetClass())
end
HUD_PLUS.DrawTargetIDHUD = function(self)
	if not self.DrawTargetID then return false end
	local eyetrace = self.LocalPlayer:GetEyeTrace()
	local ent = eyetrace.Entity
	if IsValid(ent) then
		self.EntityNextFade = self.RealTime + self.TargetIDFadeTime
		self.CachedEntity = ent
	elseif self.EntityNextFade > self.RealTime then
		ent = self.CachedEntity
	end
	if (IsValid(ent) and (self.ShowZeroHealth or ent:Health()>0)) then
		local drawpos = ent:GetPos()
		drawpos.z = drawpos.z + ent:OBBMaxs().z
		if self.TargetIDDynamic then
			cam.PopModelMatrix()
			cam.Start3D()
			self.__memory = drawpos:ToScreen()
			cam.End3D()
		end
		if not self.TargetIDDynamic or self.__memory.visible then
			local pX,pY = 0,0
			if self.TargetIDDynamic then
				pX,pY = self.__memory.x,self.__memory.y
			else
				pX,pY = self.ScrW*self.TargetIDX,self.ScrH*self.TargetIDY
			end
			surface.SetFont("HUD+")
			local armor = 0
			if ent:GetNWInt("HUD_PLUS.ARMOR")~=0 then
				armor = ent:GetNWInt("HUD_PLUS.ARMOR")
			elseif ent.Armor then
				if (isfunction(ent.Armor) and ent:Armor()>0) then
					armor = ent:Armor()
				elseif (tonumber(ent.Armor) or 0) > 0 then
					armor = ent.Armor
				end
			end
			local hp,mhp = ent:GetNWInt("HUD_PLUS.HEALTH",ent:Health()),ent:GetNWInt("HUD_PLUS.MAX_HEALTH",ent:GetMaxHealth())
			local text = self:GetNameFunction(ent).." ("..hp.."/"..mhp..")"
			if armor > 0 then
				text = text..string.format("+%u",armor)
			end
			local hpp = math.Clamp(hp/mhp,0,1)
			local textx,texty = surface.GetTextSize(text)
			local hW = math.max(self.MinHealthBarWidth*self.ScrW,textx)
			local hX,hY = pX-hW/2,pY-self.HealthBarHeight-texty-self.extraRadius
			surface.SetAlphaMultiplier((self.EntityNextFade - self.RealTime) / self.TargetIDFadeTime)
			draw.RoundedBox(self.cornerRadius,hX-self.extraRadius,hY-self.extraRadius,hW+self.extraRadius*2,self.HealthBarHeight+texty+self.extraRadius*2,self.backgroundColor)
			surface.SetDrawColor(self.HealthBackgroundBarColor)
			surface.DrawRect(hX,hY,hW,self.HealthBarHeight)
			surface.SetDrawColor(self.HealthBarColor)
			surface.DrawRect(hX,hY,hW*hpp,self.HealthBarHeight)
			if armor > 0 then
				local app = math.Clamp(armor/mhp,0,1)
				surface.SetDrawColor(self.ArmorBarColor)
				surface.DrawRect(hX,hY,hW*app,self.HealthBarHeight/2)
			end
			draw.SimpleText(text,"HUD+",pX,pY-self.extraRadius,self.foregroundColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
			surface.SetAlphaMultiplier(1)
		end
		if self.TargetIDDynamic then
			cam.PushModelMatrix(self.Matrix)
		end
	end
end



HUD_PLUS.ConDisableDrawMem = CreateClientConVar("hud_plus_disable_clientmemory","0",false,false,"Disables the GLua Client Memory Usage.\nNote that this value is NOT saved between sessions - use the options menu for that!")
HUD_PLUS.ConDisableDrawMemServer = CreateClientConVar("hud_plus_disable_servermemory","0",false,false,"Disables the GLua Server Memory Usage.\nNote that this value is NOT saved between sessions - use the options menu for that!")
HUD_PLUS.ConDisableDrawItemLocations = CreateClientConVar("hud_plus_disable_itemlocations","0",false,false,"Disables the Item Locator HUD.\nNote that this value is NOT saved between sessions - use the options menu for that!")
HUD_PLUS.ConDisableDrawTargetIDHUD = CreateClientConVar("hud_plus_disable_targetids","0",false,false,"Disables the Accurate TargetID HUD.\nNote that this value is NOT saved between sessions - use the options menu for that!")
HUD_PLUS.DrawAllHUDs = function(self)
	self:CalculateMatrix()
	cam.PushModelMatrix(self.Matrix)
	if not self.ConDisableDrawMem:GetBool() then
		self:DrawMemHUD()
		table.Empty(self.__memory)
	end
	if not self.ConDisableDrawMemServer:GetBool() then
		self:DrawServerMemHUD()
		table.Empty(self.__memory)
	end
	if not self.ConDisableDrawItemLocations:GetBool() then
		self:DrawItemLocationsHUD()
	end
	if not self.ConDisableDrawTargetIDHUD:GetBool() then
		self:DrawTargetIDHUD()
		table.Empty(self.__memory)
	end
	cam.PopModelMatrix()
end



HUD_PLUS.DefineVariables = function(self)
	self.ScrW = ScrW()
	self.ScrH = ScrH()
	self.LocalPlayer = LocalPlayer()
	self.EyePos = EyePos()
	self.RealTime = RealTime()
end



HUD_PLUS.ImpliedAngle = Angle()
HUD_PLUS.SwaySensitivity = 3.5
HUD_PLUS.SwayMagnitude = 10
HUD_PLUS.SwayPassiveAmplitude = 0.01
HUD_PLUS.SwayPassiveSpeed = 1
HUD_PLUS.SwayPassiveDirection = 90
HUD_PLUS.DoSway = true
HUD_PLUS.CalculateMatrix = function(self)
	self.Matrix = Matrix()
	if self.DoSway then
		local angs = EyeAngles()
		self.ImpliedAngle = LerpAngle(FrameTime()*self.SwaySensitivity,self.ImpliedAngle,angs)
		local swayFactor = HUD_PLUS.SwayPassiveAmplitude * math.sin(CurTime()*HUD_PLUS.SwayPassiveSpeed) * self.ScrW
		local dirInRads = math.rad(HUD_PLUS.SwayPassiveDirection)
		local dX = math.Round(-math.AngleDifference(self.ImpliedAngle.y,angs.y)*self.SwayMagnitude) + math.sin(dirInRads) * swayFactor
		local dY = math.Round(math.AngleDifference(self.ImpliedAngle.p,angs.p)*self.SwayMagnitude) + math.cos(dirInRads) * swayFactor
		local vec = Vector(dX,dY,0)
		self.Matrix:Translate(vec)
	end
end



HUD_PLUS.PainterFunction = function()
	if HUD_PLUS.enabled then
		HUD_PLUS:DefineVariables()
		HUD_PLUS:DrawAllHUDs()
	end
end



HUD_PLUS.DataReceiveFunction = function(self,func)
	if func == "mem-server" then
		self.lastmem_server = self.curmem_server
		self.lastmem_server_timestamp = self.curmem_server_timestamp
		self.maxmem_server = math.max(self.maxmem_server,self.curmem_server)
		self.curmem_server = net.ReadString()
		self.curmem_server_timestamp = RealTime()
	elseif func == "class-name-assignment" then
		table.Empty(customnames)
		for i=1,net.ReadUInt(16) do
			customnames[net.ReadString()] = net.ReadString()
		end
	end
end



HUD_PLUS.DataRelayFunction = function(length,sender)
	HUD_PLUS:DataReceiveFunction(net.ReadString())
end



net.Receive("HUD+",HUD_PLUS.DataRelayFunction)
hook.Add("HUDPaint","HUD+",HUD_PLUS.PainterFunction)



HUD_PLUS.AddToolTab = function()
	spawnmenu.AddToolTab("Options")
end
HUD_PLUS.AddToolCategory = function()
	spawnmenu.AddToolCategory("Options","HUD+","HUD+")
end
HUD_PLUS.AddToolMenuOption = function()
	spawnmenu.AddToolMenuOption("Options","HUD+","HUD+_Options","Options","hud_plus_open_gui")
end



hook.Add("AddToolMenuTabs","HUD+",HUD_PLUS.AddToolTab)
hook.Add("AddToolMenuCategories","HUD+",HUD_PLUS.AddToolCategory)
hook.Add("PopulateToolMenu","HUD+",HUD_PLUS.AddToolMenuOption)



do -- a bunch of panel generating stuff:

	HUD_PLUS.GenerateColorPanel = function(self,prop,parent)
		
		local ColorPanel,ColorLabel,ColorLabelEdit = vgui.Create("DPanel",parent)
		ColorPanel:Dock(FILL)
		ColorPanel:InvalidateParent(true)
		ColorPanel.Color = {ColorToHSV(self[prop])}
		ColorPanel.Color[4] = self[prop].a/255
		ColorPanel.UpdateColors = function(self)
			local h,s,v,a2 = unpack(self.Color)
			HUD_PLUS[prop] = HSVToColor(h,s,v)
			HUD_PLUS[prop].a = a2*255
			local r,g,b,a = HUD_PLUS[prop].r,HUD_PLUS[prop].g,HUD_PLUS[prop].b,HUD_PLUS[prop].a
			ColorLabel:SetText(string.format("Current Color Value:\n  {R=%u,G=%u,B=%u,A=%u}\n  {H=%u,S=%.2f,V=%.2f,A=%.2f}\n\nHexadecimal (Press Enter to confirm):",
				r,g,b,a,h,s,v,a2
			))
			ColorLabel:SizeToContentsY()
			local rec_709luma = 0.2126*r + 0.7152*g + 0.0722*b -- https://en.wikipedia.org/wiki/Rec._709#Luma_coefficients
			if rec_709luma-(1-math.sqrt(a2))*255 < 128 then
				ColorLabel:SetTextColor(color_white)
			else
				ColorLabel:SetTextColor(color_black)
			end
			local largenum = bit.lshift(r,24)+bit.lshift(g,16)+bit.lshift(b,8)+a
			if a >= 255 then
				largenum = bit.rshift(largenum,8)
				ColorLabelEdit:SetText(bit.tohex(largenum,6))
			else
				ColorLabelEdit:SetText(bit.tohex(largenum))
			end
		end
		ColorPanel.GetColorNoAlpha = function(self)
			return HSVToColor(unpack(self.Color))
		end
		ColorPanel.Paint = function(self,w,h)
			surface.SetDrawColor(HUD_PLUS[prop])
			surface.DrawRect(0,0,w,h)
		end
		
		local AlphaBar = vgui.Create("DAlphaBar",ColorPanel)
		AlphaBar:SetWidth(self.ScrW/50)
		AlphaBar:Dock(RIGHT)
		AlphaBar:SetBarColor(ColorPanel:GetColorNoAlpha())
		AlphaBar:SetValue(ColorPanel.Color[4])
		AlphaBar.OnChange = function(self,alpha)
			ColorPanel.Color[4] = alpha
			ColorPanel:UpdateColors()
			self:SetBarColor(ColorPanel:GetColorNoAlpha())
		end
		
		local SVCube = vgui.Create("DColorCube",ColorPanel)
		SVCube:Dock(RIGHT)
		SVCube:SetColor(self[prop])
		SVCube:SetCursor("crosshair")
		SVCube.OnUserChanged = function(self,col)
			ColorPanel.Color[2],ColorPanel.Color[3] = select(2,ColorToHSV(col))
			ColorPanel:UpdateColors()
			AlphaBar:SetBarColor(ColorPanel:GetColorNoAlpha())
		end
		
		local HueBar = vgui.Create("DRGBPicker",ColorPanel)
		HueBar:SetWidth(self.ScrW/50)
		HueBar:Dock(RIGHT)
		HueBar:InvalidateParent(true)
		local hbH = select(2,HueBar:GetSize())
		HueBar:SetRGB(HSVToColor(ColorPanel.Color[1],1,1))
		HueBar.LastY = hbH*(1-(ColorPanel.Color[1]/360))
		HueBar.OnChange = function(self,col)
			ColorPanel.Color[1] = ColorToHSV(col)
			ColorPanel:UpdateColors()
			AlphaBar:SetBarColor(ColorPanel:GetColorNoAlpha())
			SVCube:SetBaseRGB(HSVToColor(ColorPanel.Color[1],1,1))
		end
		SVCube:SetWidth(hbH)
		
		ColorLabel = vgui.Create("DLabel",ColorPanel)
		ColorLabel:Dock(TOP)
		
		ColorLabelEdit = vgui.Create("DTextEntry",ColorPanel)
		ColorLabelEdit:Dock(TOP)
		ColorLabelEdit.OnEnter = function(self)
			local hex = self:GetValue()
			if tonumber("0x"..hex) then
				local color_construct = {}
				if #hex<5 then
					color_construct.r = tonumber("0x"..hex[1]..hex[1]) or 0
					color_construct.g = tonumber("0x"..hex[2]..hex[2]) or 0
					color_construct.b = tonumber("0x"..hex[3]..hex[3]) or 0
					color_construct.a = tonumber("0x"..hex[4]..hex[4]) or 255
				else
					color_construct.r = tonumber("0x"..hex:sub(1,2)) or 0
					color_construct.g = tonumber("0x"..hex:sub(3,4)) or 0
					color_construct.b = tonumber("0x"..hex:sub(5,6)) or 0
					color_construct.a = tonumber("0x"..hex:sub(7,8)) or 255
				end
				ColorPanel.Color = {ColorToHSV(color_construct)}
				ColorPanel.Color[4] = color_construct.a/255
				ColorPanel:UpdateColors()
				AlphaBar:SetValue(ColorPanel.Color[4])
				AlphaBar:SetBarColor(ColorPanel:GetColorNoAlpha())
				SVCube:SetColor(HUD_PLUS[prop])
				HueBar:SetRGB(HSVToColor(ColorPanel.Color[1],1,1))
				HueBar.LastY = hbH*(1-(ColorPanel.Color[1]/360))
			end
		end

		local Palette = vgui.Create("DColorPalette",ColorPanel)
		Palette:SetHeight(8)
		Palette:Dock(FILL)
		Palette:SetButtonSize(8)
		Palette:SetNumRows(24)
		Palette:Reset()
		Palette.OnValueChanged = function(self,color)
			ColorPanel.Color = {ColorToHSV(color)}
			ColorPanel.Color[4] = color.a/255
			ColorPanel:UpdateColors()
			AlphaBar:SetValue(ColorPanel.Color[4])
			AlphaBar:SetBarColor(ColorPanel:GetColorNoAlpha())
			SVCube:SetColor(HUD_PLUS[prop])
			HueBar:SetRGB(HSVToColor(ColorPanel.Color[1],1,1))
			HueBar.LastY = hbH*(1-(ColorPanel.Color[1]/360))
		end
		Palette.OnRightClickButton = function(ctrl,btn)
			local m = DermaMenu()
			m:AddOption("Save Color",function()ctrl:SaveColor(btn,self:GetColor())end)
			m:AddOption("Reset Palette",function()ctrl:ResetSavedColors()end)
			m:Open()
		end
		
		ColorPanel:UpdateColors()
		
		return ColorPanel
		
	end

	HUD_PLUS.GenerateIconPanel = function(self,prop,parent)

		parent:InvalidateParent(true)
		
		local MainPanel = vgui.Create("DPanel",parent)
		MainPanel:Dock(FILL)
		MainPanel.Paint = HUD_PLUS.SystemBlack
		
		local IconPanel = vgui.Create("DPanel",MainPanel)
		IconPanel:SetWidth(parent:GetTall())
		IconPanel:Dock(RIGHT)
		IconPanel.Paint = HUD_PLUS.DoNothing
		
		local IconBrowser = vgui.Create("DIconBrowser",IconPanel)
		IconBrowser:Dock(FILL)
		IconBrowser:SelectIcon("icon16/accept.png")
		
		local IconSearch = vgui.Create("DTextEntry",IconPanel)
		IconSearch:Dock(TOP)
		IconSearch:SetPlaceholderText("#spawnmenu.search")
		IconSearch.OnChange = function(self)
			IconBrowser:FilterByText(self:GetValue())
		end
		
		local ItemPanel = vgui.Create("DPanel",MainPanel)
		ItemPanel.Paint = HUD_PLUS.DoNothing
		ItemPanel:Dock(FILL)
		
		local ItemListInternal = vgui.Create("DScrollPanel",ItemPanel)
		ItemListInternal:Dock(FILL)
		HUD_PLUS:PaintBar(ItemListInternal:GetVBar())
		ItemListInternal.RegenerateList = function(self)
			self:Clear()
			local newentry
			for k,v in SortedPairs(HUD_PLUS[prop]) do
				
				local Item = vgui.Create("DPanel",self)
				Item:SetHeight(32)
				Item:Dock(TOP)
				Item.Paint = HUD_PLUS.DoNothing
				
				local ItemIcon = vgui.Create("DImageButton",Item)
				ItemIcon:SetSize(32,32)
				ItemIcon:SetImage(v)
				ItemIcon:Dock(LEFT)
				ItemIcon.DoClick = function(self)
					local Selections = DermaMenu(ItemIcon)
					local ApplyOption = Selections:AddOption("Apply Selected Icon",function()
						HUD_PLUS[prop][k] = IconBrowser:GetSelectedIcon()
						ItemListInternal:RegenerateList()
					end)
					ApplyOption:SetIcon(IconBrowser:GetSelectedIcon())
					local DeleteOption = Selections:AddOption("Delete Entry",function()
						HUD_PLUS[prop][k] = nil
						ItemListInternal:RegenerateList()
					end)
					DeleteOption:SetIcon("icon16/delete.png")
					Selections:Open()
				end
				ItemIcon.DoRightClick = ItemIcon.DoClick
				
				local ItemName = vgui.Create("DTextEntry",Item)
				HUD_PLUS:PaintTextBox(ItemName)
				ItemName:Dock(FILL)
				ItemName:SetText(k)
				ItemName.Think = function(self)
					if self:GetValue()~=k and not self:IsEditing() then
						if not HUD_PLUS[prop][self:GetValue()] then
							local oldV = HUD_PLUS[prop][k]
							HUD_PLUS[prop][k] = nil
							HUD_PLUS[prop][self:GetValue()] = oldV
						end
						ItemListInternal:RegenerateList()
					end
				end
				
				if k == "< New Entry >" then
					newentry = Item
				end
				
			end
			if IsValid(newentry) then
				self:ScrollToChild(newentry)
			end
		end
		ItemListInternal:RegenerateList()
		
		local ItemAddButton = vgui.Create("DButton",ItemPanel)
		ItemAddButton:Dock(TOP)
		ItemAddButton:SetText("Add Item")
		ItemAddButton.DoClick = function(self)
			HUD_PLUS[prop]["< New Entry >"] = IconBrowser:GetSelectedIcon()
			ItemListInternal:RegenerateList()
		end
		
		return MainPanel
		
	end

	HUD_PLUS.AddColorOption = function(self,pnl,class,name)
		local Category = pnl:Add(name)
		Category.Paint = HUD_PLUS.DoNothing
		Category:SetHeight(self.ScrH/6)
		Category:SetContents(self:GenerateColorPanel(class,Category))
	end

	HUD_PLUS.AddIconOption = function(self,pnl,class,name)
		local Category = pnl:Add(name)
		Category.Paint = HUD_PLUS.DoNothing
		Category:SetHeight(self.ScrH/3)
		Category:SetContents(self:GenerateIconPanel(class,Category))
	end

	HUD_PLUS.AddNumberOption = function(self,pnl,class,name,mins,maxs,decimals,default)
		local NumSlider = vgui.Create("DNumSlider",pnl)
		NumSlider:SetMinMax(mins,maxs)
		NumSlider:SetText(name)
		NumSlider:SetValue(self[class])
		if decimals then
			NumSlider:SetDecimals(decimals)
		end
		if default then
			NumSlider:SetDefaultValue(default)
		end
		NumSlider.OnValueChanged = function(self,val)
			HUD_PLUS[class] = val
		end
		NumSlider.Label:SetTextColor(color_white)
		NumSlider.TextArea:SetTextColor(color_white)
		pnl:AddItem(NumSlider)
	end

	HUD_PLUS.AddCheckBoxOption = function(self,pnl,class,name)
		local CheckBox = vgui.Create("DCheckBoxLabel",pnl)
		CheckBox:SetText(name)
		CheckBox:SetValue(self[class])
		CheckBox.OnChange = function(self,val)
			HUD_PLUS[class] = val
		end
		CheckBox.Label:SetTextColor(color_white)
		pnl:AddItem(CheckBox)
	end

	HUD_PLUS.AddTextEntryOption = function(self,pnl,class,name)
		local MainPanel = vgui.Create("DPanel",pnl)
		MainPanel.Paint = HUD_PLUS.DoNothing
		
		local TextLabel = vgui.Create("DLabel",MainPanel)
		TextLabel:SetText(name)
		TextLabel:SetTextColor(color_white)
		TextLabel:SizeToContentsX()
		TextLabel:Dock(LEFT)
		
		local TextEntry = vgui.Create("DTextEntry",MainPanel)
		HUD_PLUS:PaintTextBox(TextEntry)
		TextEntry:Dock(FILL)
		TextEntry:SetText(HUD_PLUS[class])
		TextEntry.OnChange = function(self)
			HUD_PLUS[class] = self:GetValue()
		end
		
		pnl:AddItem(MainPanel)
	end

	HUD_PLUS.AddButtonOption = function(self,pnl,name,func)
		local Button = vgui.Create("DButton",pnl)
		Button:SetText(name)
		Button:SetTextColor(color_white)
		Button.Paint = HUD_PLUS.SystemBlackButton
		Button.DoClick = func
		pnl:AddItem(Button)
	end

	HUD_PLUS.SystemBlackCol = Color(0,0,0,191)
	HUD_PLUS.editableColor = Color(255,255,255,3)
	HUD_PLUS.editColor = Color(255,255,255,31)
	HUD_PLUS.hoverColor = Color(255,255,255,191)
	HUD_PLUS.highlightColor = Color(0,255,255,191)
	HUD_PLUS.SystemBlack = function(pnl,w,h)
		draw.RoundedBox(4,0,0,w,h,HUD_PLUS.SystemBlackCol)
	end
	HUD_PLUS.SystemBlackButton = function(pnl,w,h)
		draw.RoundedBox(4,0,0,w,h,pnl.Depressed and HUD_PLUS.highlightColor or pnl:IsHovered() and HUD_PLUS.hoverColor or HUD_PLUS.SystemBlackCol)
	end
	HUD_PLUS.SystemBlackBrighter = function(pnl,w,h)
		draw.RoundedBox(4,0,0,w,h,HUD_PLUS.editableColor)
	end
	HUD_PLUS.PaintBar = function(self,pnl)
		pnl.btnUp.Paint = function(self,w,h)
			HUD_PLUS.SystemBlackButton(self,w,h)
			draw.SimpleText("t","Marlett",w/2,h/2,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
		pnl.btnDown.Paint = function(self,w,h)
			HUD_PLUS.SystemBlackButton(self,w,h)
			draw.SimpleText("u","Marlett",w/2,h/2,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
		pnl.btnGrip.Paint = HUD_PLUS.SystemBlackButton
		pnl.Paint = HUD_PLUS.SystemBlackBrighter
	end
	HUD_PLUS.PaintTextBox = function(self,pnl)
		pnl:SetPaintBackground(false)
		pnl:SetDrawBorder(false)
		pnl:SetTextColor(color_white)
		pnl:SetCursorColor(color_white)
		pnl:SetHighlightColor(HUD_PLUS.highlightColor)
		pnl.OnGetFocus = function(self)
			self.DrawEditOverlay = true
			hook.Run("OnTextEntryGetFocus",self)
		end
		pnl.OnLoseFocus = function(self)
			self.DrawEditOverlay = nil
			hook.Run("OnTextEntryLoseFocus",self)
		end
		pnl.PaintOver = function(self,w,h)
			if self.DrawEditOverlay then
				draw.RoundedBox(4,0,0,w,h,HUD_PLUS.editColor)
			else
				draw.RoundedBox(4,0,0,w,h,HUD_PLUS.editableColor)
			end
		end
	end

end



HUD_PLUS.ShowOptions = function()
	HUD_PLUS:DefineVariables()
	local Main = vgui.Create("DFrame")
	Main:SetSize(HUD_PLUS.ScrW/3,HUD_PLUS.ScrH/2)
	Main:Center()
	Main:SetTitle("HUD+ Options")
	Main:SetIcon("icon16/application_view_tile.png")
	Main:SetSizable(true)
	Main:SetDraggable(true)
	Main:MakePopup()
	Main.Paint = function(self,w,h)
		HUD_PLUS.SystemBlack(self,w,h)
		if self:IsActive() then
			draw.RoundedBox(4,0,0,w,24,HUD_PLUS.SystemBlackCol)
		end
		draw.SimpleText("o","Marlett",w,h,color_white,TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)
	end
	
	local Sheets = vgui.Create("DPropertySheet",Main)
	Sheets:Dock(FILL)
	Sheets.Paint = HUD_PLUS.DoNothing
	Sheets.InstallSheet = function(self,name,icn)
		local Sheet = vgui.Create("DCategoryList",Sheets)
		HUD_PLUS:PaintBar(Sheet:GetVBar())
		Sheet:Dock(FILL)
		Sheet.Paint = HUD_PLUS.SystemBlack
		local InternalSheet = Sheets:AddSheet(name,Sheet,icn)
		InternalSheet.Tab.Paint = function(self,w,h)
			if self:IsActive() then
				draw.RoundedBoxEx(8,0,0,w,h,HUD_PLUS.SystemBlackCol,true,true)
			end
		end
		return Sheet
	end
	local GeneralList = Sheets:InstallSheet("General","icon16/world.png")
	HUD_PLUS:AddCheckBoxOption(GeneralList,"enabled","Enable HUD")
	HUD_PLUS:AddColorOption(GeneralList,"backgroundColor","Background Colour")
	HUD_PLUS:AddColorOption(GeneralList,"foregroundColor","Foreground Colour")
	HUD_PLUS:AddNumberOption(GeneralList,"cornerRadius","Roundness",0,32,0,8)
	HUD_PLUS:AddNumberOption(GeneralList,"extraRadius","Padding",0,32,0,8)
	HUD_PLUS:AddCheckBoxOption(GeneralList,"DoSway","Enable Sway")
	HUD_PLUS:AddNumberOption(GeneralList,"SwaySensitivity","Sway Acceleration",0,64,2,3.5)
	HUD_PLUS:AddNumberOption(GeneralList,"SwayMagnitude","Sway Magnitude",0,64,2,10)
	HUD_PLUS:AddNumberOption(GeneralList,"SwayPassiveAmplitude","Passive Sway Magnitude",0,1,3,0.01)
	HUD_PLUS:AddNumberOption(GeneralList,"SwayPassiveDirection","Passive Sway Direction",0,180,1,90)
	HUD_PLUS:AddNumberOption(GeneralList,"SwayPassiveSpeed","Passive Sway Speed",0,32,2,1)
	HUD_PLUS:AddButtonOption(GeneralList,"Reset All Options",function()
		Main:Close()
		HUD_PLUS:ResetEverything()
	end)
	local FontList = Sheets:InstallSheet("Fonts","icon16/font.png")
	HUD_PLUS:AddTextEntryOption(FontList,"FontName","System Font Name:")
	HUD_PLUS:AddNumberOption(FontList,"FontSize","Font Size",0,128,0,16)
	HUD_PLUS:AddCheckBoxOption(FontList,"FontBold","Bold Font")
	HUD_PLUS:AddCheckBoxOption(FontList,"FontItalic","Italic Font")
	HUD_PLUS:AddCheckBoxOption(FontList,"FontUnderline","Underline Font")
	HUD_PLUS:AddCheckBoxOption(FontList,"FontAntiAlias","Anti-alias Font")
	HUD_PLUS:AddCheckBoxOption(FontList,"FontShadow","Enable Font Shadow")
	HUD_PLUS:AddCheckBoxOption(FontList,"FontAdditive","Draw Font Additively")
	HUD_PLUS:AddButtonOption(FontList,"Recreate Font",HUD_PLUS.RecreateFont)
	local MemList = Sheets:InstallSheet("Memory Usage","icon16/script_gear.png")
	HUD_PLUS:AddCheckBoxOption(MemList,"DrawMem","Draw Client HUD")
	HUD_PLUS:AddNumberOption(MemList,"mem_x","Client Position X",0,1,3,0.8)
	HUD_PLUS:AddNumberOption(MemList,"mem_y","Client Position Y",0,1,3,0.1)
	HUD_PLUS:AddCheckBoxOption(MemList,"DrawServerMem","Draw Server HUD")
	HUD_PLUS:AddNumberOption(MemList,"mems_x","Server Position X",0,1,3,0.8)
	HUD_PLUS:AddNumberOption(MemList,"mems_y","Server Position Y",0,1,3,0.2)
	HUD_PLUS:AddCheckBoxOption(MemList,"DrawBasicMemUnits","Display KB instead of KiB, MB instead of MiB, etc.")
	MemList.Think = function(self)
		if HUD_PLUS.DrawBasicMemUnits and not self.UseBasic then
			self.UseBasic = true
			HUD_PLUS.unittable.data = {"B","KB","MB","GB","TB"}
		elseif not HUD_PLUS.DrawBasicMemUnits and self.UseBasic then
			self.UseBasic = false
			HUD_PLUS.unittable.data = {"B","KiB","MiB","GiB","TiB"}
		end
	end
	local ItemList = Sheets:InstallSheet("Entity Indicators","icon16/bricks.png")
	HUD_PLUS:AddCheckBoxOption(ItemList,"DrawItemLocations","Draw Entity Indicators")
	HUD_PLUS:AddIconOption(ItemList,"itemtable","Entity Icons")
	HUD_PLUS:AddNumberOption(ItemList,"itemstartfade","Start Fade",0,2048,0,64)
	HUD_PLUS:AddNumberOption(ItemList,"itemendfade","End Fade",0,2048,0,256)
	HUD_PLUS:AddNumberOption(ItemList,"itemhudsize","Indicator Size",0,512,0,32)
	HUD_PLUS:AddNumberOption(ItemList,"itemhudpanelsizeratio","Border Size Multiplier",0,10,2,1.5)
	local TargetIDList = Sheets:InstallSheet("TargetIDs","icon16/report_user.png")
	HUD_PLUS:AddCheckBoxOption(TargetIDList,"DrawTargetID","Draw Target IDs")
	HUD_PLUS:AddCheckBoxOption(TargetIDList,"TranslateClass","Show Translated Class Names")
	HUD_PLUS:AddCheckBoxOption(TargetIDList,"ShowZeroHealth","Show Zero Health Entities")
	HUD_PLUS:AddNumberOption(TargetIDList,"TargetIDFadeTime","Fade Time",0,10,2,1)
	HUD_PLUS:AddNumberOption(TargetIDList,"TargetIDX","X Position",0,1,3,0.5)
	HUD_PLUS:AddNumberOption(TargetIDList,"TargetIDY","Y Position",0,1,3,0.2)
	HUD_PLUS:AddCheckBoxOption(TargetIDList,"TargetIDDynamic","Use Dynamic Position Instead")
	HUD_PLUS:AddNumberOption(TargetIDList,"HealthBarHeight","Health Bar Height",0,32,0,8)
	HUD_PLUS:AddNumberOption(TargetIDList,"MinHealthBarWidth","Minimum Health Bar Width",0,1,3,0.2)
	HUD_PLUS:AddColorOption(TargetIDList,"HealthBarColor","Health Colour")
	HUD_PLUS:AddColorOption(TargetIDList,"HealthBackgroundBarColor","Health Background Colour")
	HUD_PLUS:AddColorOption(TargetIDList,"ArmorBarColor","Armour Colour")
end



HUD_PLUS.LoadEverything = function()
	local data = util.JSONToTable(file.Read("hud+_scheme.txt","DATA") or "")
	if data then
		table.Merge(HUD_PLUS,data)
	end
	HUD_PLUS.maxmem = 0
	HUD_PLUS.maxmem_server = 0
end
HUD_PLUS.SaveEverything = function()
	file.Write("hud+_scheme.txt",util.TableToJSON(HUD_PLUS,true))
end
HUD_PLUS.ResetEverything = function()
	include("autorun/client/hud+.lua")
end



hook.Add("InitPostEntity","HUD+",HUD_PLUS.LoadEverything)
hook.Add("ShutDown","HUD+",HUD_PLUS.SaveEverything)
concommand.Add("hud_plus_open_gui",HUD_PLUS.ShowOptions)
concommand.Add("hud_plus_reset",HUD_PLUS.ResetEverything)