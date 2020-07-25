local ConE = CreateClientConVar("hud_sway_enabled","1",true,false,"Should HUD Sway be enabled?")
local ConR = CreateClientConVar("hud_sway_rate","20",true,false,"Higher values make the HUD recover faster. Range: 0-100")
local ConA = CreateClientConVar("hud_sway_intensity","20",true,false,"Higher values increase turning effects.")
local ConC = CreateClientConVar("hud_sway_noclip","1",true,false,"Enables HUDs to draw off-screen. You will want to leave this active.")
local ConX = CreateClientConVar("hud_sway_scale_x","1",true,false,"Scales the HUDs horizontally.\
 - All individual elements of the HUDs are scaled, except for the default HUD, which is treated as one element.")
local ConY = CreateClientConVar("hud_sway_scale_y","1",true,false,"Scales the HUDs vertically.\
 - All individual elements of the HUDs are scaled, except for the default HUD, which is treated as one element.")
local ConP = CreateClientConVar("hud_sway_push_x","0",true,false,"Pushes the HUDs horizontally. Negative values push the HUDs leftwards.")
local ConQ = CreateClientConVar("hud_sway_push_y","0",true,false,"Pushes the HUDs vertically. Negative values push the HUDs upwards.")
local ConU = CreateClientConVar("hud_sway_canvas_x","1",true,false,"Resizes the HUDs' canvas horizontally.\
 - Does nothing for the default HUD.")
local ConV = CreateClientConVar("hud_sway_canvas_y","1",true,false,"Resizes the HUDs' canvas vertically.\
 - Does nothing for the default HUD.")
local ConB = CreateClientConVar("hud_sway_passive_intensity","10",true,false,"Higher values increase passive sway effects.")
local ConD = CreateClientConVar("hud_sway_passive_direction","90",true,false,"Changes the passive sway direction clockwise.")
local ConF = CreateClientConVar("hud_sway_passive_speed","1",true,false,"Higher values increase passive sway movement.")
local oldAngle = Angle()
local oldScrW = ScrW
local oldScrH = ScrH
local HudMatrix = Matrix()
local function newScrW(...)
	return oldScrW(...)*ConU:GetFloat()/ConX:GetFloat()
end
local function newScrH(...)
	return oldScrH(...)*ConV:GetFloat()/ConY:GetFloat()
end
local function shouldFilter()
	return ConU:GetFloat()/ConX:GetFloat()~=1 or ConV:GetFloat()/ConY:GetFloat()~=1
end
local function applySway()
	if ConE:GetBool() then
		HudMatrix:Identity()
		local newAngle = EyeAngles()
		oldAngle = LerpAngle(ConR:GetFloat()*.01,oldAngle,newAngle)
		local swayFactor = ConB:GetFloat() * math.sin(CurTime()*ConF:GetFloat())
		local dirInRads = math.rad(ConD:GetFloat())
		local dX = math.Round(-math.AngleDifference(oldAngle.y,newAngle.y)*ConA:GetFloat()) + math.sin(dirInRads) * swayFactor
		local dY = math.Round(math.AngleDifference(oldAngle.p,newAngle.p)*ConA:GetFloat()) + math.cos(dirInRads) * swayFactor
		HudMatrix:Scale(Vector(ConX:GetFloat(),ConY:GetFloat(),1))
		HudMatrix:Translate(Vector(dX+ConP:GetFloat(),dY+ConQ:GetFloat(),0))
		cam.PushModelMatrix(HudMatrix)
		if shouldFilter() then
			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			render.PushFilterMin(TEXFILTER.ANISOTROPIC)
			if ConU:GetFloat()/ConX:GetFloat()~=1 then
				ScrW = newScrW
			end
			if ConV:GetFloat()/ConY:GetFloat()~=1 then
				ScrH = newScrH
			end
		end
	end
	if ConC:GetBool() then
		surface.DisableClipping(true)
	end
end
local function removeSway()
	if ConE:GetBool() then
		--cam.PopModelMatrix()
		if shouldFilter() then
			render.PopFilterMag()
			render.PopFilterMin()
			if ConU:GetFloat()/ConX:GetFloat()~=1 then
				ScrW = oldScrW
			end
			if ConV:GetFloat()/ConY:GetFloat()~=1 then
				ScrH = oldScrH
			end
		end
	end
	if ConC:GetBool() then
		surface.DisableClipping(false)
	end
end

hook.Add("HUDPaintBackground","HudSway",applySway)
hook.Add("PostDrawHUD","HudSwoi",removeSway)

hook.Add("AddToolMenuTabs","HudSoi",function()
	spawnmenu.AddToolTab("Options")
end)

hook.Add("AddToolMenuCategories","HudSoiSoiSoi",function()
	spawnmenu.AddToolCategory("Options","HUDSway","HUDSway")
end)

hook.Add("PopulateToolMenu","HudSwoiSwoiSwoi",function()
	spawnmenu.AddToolMenuOption("Options","HUDSway","HUDSway_Options","Options","","",function(DForm) -- Add panel
		DForm:Help("") --whitespace
		DForm:CheckBox("Enable HUDSway",ConE:GetName())
		DForm:Help(" - "..ConE:GetHelpText().."\n")
		DForm:NumSlider("Recover Rate",ConR:GetName(),0,100,2)
		DForm:Help(" - "..ConR:GetHelpText().."\n")
		DForm:NumSlider("Intensity",ConA:GetName(),0,100,2)
		DForm:Help(" - "..ConA:GetHelpText().."\n")
		DForm:NumSlider("Passive Intensity",ConB:GetName(),0,5000,0)
		DForm:Help(" - "..ConB:GetHelpText().."\n")
		DForm:NumSlider("Passive Sway Direction",ConD:GetName(),0,180,1)
		DForm:Help(" - "..ConD:GetHelpText().."\n")
		DForm:NumSlider("Passive Speed",ConF:GetName(),0,20,2)
		DForm:Help(" - "..ConF:GetHelpText().."\n")
		DForm:CheckBox("HUDSway Noclip",ConC:GetName())
		DForm:Help(" - "..ConC:GetHelpText().."\n")
		DForm:NumSlider("Width Scale",ConX:GetName(),0.1,10,2)
		DForm:Help(" - "..ConX:GetHelpText().."\n")
		DForm:NumSlider("Height Scale",ConY:GetName(),0.1,10,2)
		DForm:Help(" - "..ConY:GetHelpText().."\n")
		DForm:NumSlider("HUDSway Width",ConU:GetName(),0.1,10,2)
		DForm:Help(" - "..ConU:GetHelpText().."\n")
		DForm:NumSlider("HUDSway Height",ConV:GetName(),0.1,10,2)
		DForm:Help(" - "..ConV:GetHelpText().."\n")
		DForm:NumSlider("X Offset",ConP:GetName(),-5000,5000,0)
		DForm:Help(" - "..ConP:GetHelpText().."\n")
		DForm:NumSlider("Y Offset",ConQ:GetName(),-5000,5000,0)
		DForm:Help(" - "..ConQ:GetHelpText().."\n")
	end)
end)