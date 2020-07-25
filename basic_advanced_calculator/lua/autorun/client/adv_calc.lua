list.Set("DesktopWindows","Advanced Calculator",
{
	title = "Calculator",
	icon = "icon64/advcalc.png",
	init = function( icon, providedwindow )
		BuildAdvCMenu()
		providedwindow:Close()
	end
})

local disttop = 23
local dispy = 50

AdvCalc = AdvCalc or {
Ans =  0,
M = 0,
A = 0,
B = 0,
C = 0,
D = 0,
E = 0,
F = 0,
G = 0,
H = 0,
I = 0,
J = 0,
K = 0,
L = 0,
M = 0,
N = 0,
O = 0,
P = 0,
Q = 0,
R = 0,
S = 0,
T = 0,
U = 0,
V = 0,
W = 0,
X = 0,
Y = 0,
Z = 0,

func = "",
AnsDisp = "0",
typed = {},
Posttyped = "",
Alt = false,
Alpha = false,
AngleMode = "degrees",
ForceInsert = true,
DigitMode = 10,
inspos = 1,
History = {},

Colors = {
	[1]=Color(0,0,0),
	[2]=Color(191,191,191),
	[3]=Color(127,127,127),
	[4]=Color(255,255,255),
	[5]=Color(255,255,0),
	[6]=Color(0,255,0),
	[7]=Color(0,255,255),
	[8]=Color(127,0,255),
	[9]=Color(0,127,255),
	[10]=Color(255,0,0),
	[11]=Color(31,31,31),
	[12]=Color(127,0,0),
	[13]=Color(255,255,191),
	[14]=Color(127,63,0),
	[15]=Color(0,0,0),
	[16]=Color(0,0,0),
	[17]=Color(255,255,255),
	[18]=Color(63,63,63),
	[19]=Color(255,255,255),
	[20]=Color(0,0,0),
	[21]=Color(255,255,255),
	[22]=Color(255,255,255),
	[23]=Color(255,0,0),
	[24]=Color(0,255,0)
},

Translations = {
	[1]="Functions",
	[2]="Numbers",
	[3]="Operations",
	[4]="Equators/Solvants",
	[5]="Shift/Alpha Toggler",
	[6]="Anglizer",
	[7]="Autocorrection Toggler",
	[8]="Arrows",
	[9]="Memory Operators",
	[10]="Clearing Operators",
	[11]="Alternate Functions",
	[12]="Variables",
	[13]="Toggled Shift and Alpha",
	[14]="Alternate Alpha Functions",
	[15]="Backspace",
	[16]="Black Text",
	[17]="White Text",
	[18]="Non-rainbow Options",
	[19]="Screen",
	[20]="Screen Text",
	[21]="Graph Line",
	[22]="Graph Debug Text",
	[23]="Graph X-Axis",
	[24]="Graph Y-Axis"
},
Historyi = 1
}

hook.Add("Initialize", "LoadDataForAdvCalc", function()
	if file.Exists('advcalccolors.txt', 'DATA') then
		table.Merge(AdvCalc.Colors,util.JSONToTable(file.Read('advcalccolors.txt','DATA')) or {})
	end
	if file.Exists('advcalcvarvals.txt', 'DATA') then
		table.Merge(AdvCalc,util.JSONToTable(file.Read('advcalcvarvals.txt','DATA')) or {})
	end
end)

include("buttons+functions.lua")

local ConX = CreateClientConVar("advcalc_button_sizex","40")
local ConY = CreateClientConVar("advcalc_button_sizey","40")
local ConR = CreateClientConVar("advcalc_button_roundness","4")
local ConS = CreateClientConVar("advcalc_button_spacing","2")
local ConO = CreateClientConVar("advcalc_button_clicky","1")
local ConB = CreateClientConVar("advcalc_button_optionrainbow","1")
local ConP = CreateClientConVar("advcalc_color_cyclespeed","1")
local ConH = CreateClientConVar("advcalc_color_addhue","0")
local ConV = CreateClientConVar("advcalc_color_darkness","0.5")
local ConT = CreateClientConVar("advcalc_color_saturation","1")
local ConA = CreateClientConVar("advcalc_button_autorelease","1")

concommand.Add("advcalc",function()

	if SERVER then return end
	BuildAdvCMenu()

end)

function CheckAdvCSyntax(key)
	local tab = AdvCalc.typed
	if key then
		local sp, _1, _2 = string.find(tab[AdvCalc.inspos-1] and string.Right(tab[AdvCalc.inspos-1],1) or "",key)
		return tobool(sp)
	else
		return tab[AdvCalc.inspos-1] == nil
	end
end

function BuildAdvCMenu()
	
	if SERVER then return end

	local xelements = 11
	local yelements = 6
	local buttonx = ConX:GetInt()
	local buttony = ConY:GetInt()
	local spacing = ConS:GetFloat()
	
	local Main = vgui.Create("DFrame")
	Main:SetSize(buttonx*xelements+spacing*(xelements+1), buttony*yelements+spacing*(yelements+2)+dispy+disttop)
	Main:Center()
	Main:MakePopup()
	Main:SetTitle("Basic Advanced Calculator by RandomTNT")
	Main:ShowCloseButton(false)
	Main.Paint = function(panel,w,h)
		draw.RoundedBox(4,0,0,w,h,HSVToColor((SysTime()*ConP:GetFloat()*10+ConH:GetInt())%360,ConT:GetFloat(),1-ConV:GetFloat()))
	end
	
	local Disp = vgui.Create("DPanel", Main)
	Disp:SetSize(buttonx*xelements+spacing*(xelements-1),dispy)
	Disp:SetPos(spacing,spacing+disttop)
	function Disp:Paint(w,h)
		draw.RoundedBox(4,0,0,w,h,AdvCalc.Colors[19])
		draw.SimpleText(string.Comma(AdvCalc.AnsDisp),"DermaLarge",w,h,AdvCalc.Colors[20],TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)
		draw.SimpleText(AdvCalc.func,"DermaDefault",2,2,AdvCalc.Colors[20],TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		if #AdvCalc.typed + 1 ~= AdvCalc.inspos then
			surface.SetFont("DermaDefault")
			local indicator = table.concat(AdvCalc.typed,"",1,AdvCalc.inspos-1)
			local w2, h2 = surface.GetTextSize(indicator)
			surface.SetDrawColor(AdvCalc.Colors[20])
			surface.DrawRect(1+w2,2,1,h2)
		end
	end
	
	local XButton = vgui.Create("DButton",Main)
	XButton:SetPos(buttonx*xelements+spacing*(xelements+1)-disttop,0)
	XButton:SetSize(disttop,disttop)
	XButton:SetFont("Marlett")
	XButton:SetText("r")
	XButton:SetTextColor(Color(255,255,255))
	XButton.DoClick = function()
		Main:Close()
	end
	XButton.Paint = function(panel,w,h)
		--draw.SimpleText("r","Marlett",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	
	local Buttons = vgui.Create("DIconLayout", Main)
	Buttons:SetSize(buttonx*xelements+spacing*(xelements-1),buttony*yelements+spacing*(yelements-1))
	Buttons:SetPos(spacing,spacing*2+disttop+dispy)
	Buttons:SetSpaceX(spacing)
	Buttons:SetSpaceY(spacing)
	
	function Main:PerformLayout(w,h)
		XButton:SetPos(w-disttop,0)
		Disp:SetSize(buttonx*xelements+spacing*(xelements-1),dispy)
		Disp:SetPos(spacing,spacing+disttop)
		Buttons:SetSize(buttonx*xelements+spacing*(xelements-1),buttony*yelements+spacing*(yelements-1))
		Buttons:SetPos(spacing,spacing*2+disttop+dispy)
		Buttons:SetSpaceX(spacing)
		Buttons:SetSpaceY(spacing)
	end
	
	for i=1,(xelements*yelements) do
		if CButtonTable[i] ~= nil then
			local Button = Buttons:Add("DButton")
			local text = CButtonTable[i].Text or ""
			local functext = CButtonTable[i].FuncText or text
			local alttext = CButtonTable[i].AltText or text
			local altfunctext = CButtonTable[i].FuncAltText or CButtonTable[i].AltText or functext
			local alphatext = CButtonTable[i].AlphaText or text
			local alphafunctext = CButtonTable[i].FuncAlphaText or CButtonTable[i].AlphaText or functext
			local altalphatext = CButtonTable[i].AltAlphaText or CButtonTable[i].AlphaText or CButtonTable[i].AltText or text
			local altalphafunctext = CButtonTable[i].FuncAltAlphaText or CButtonTable[i].AltAlphaText or CButtonTable[i].FuncAlphaText or CButtonTable[i].AlphaText or CButtonTable[i].FuncAltText or CButtonTable[i].AltText or functext
			--local tcol = AdvCalc.Colors[CButtonTable[i].TextColor] or AdvCalc.Colors[17]
			local typenorm = CButtonTable[i].ButtonType or "func"
			local typealt = CButtonTable[i].ButtonTypeAlt or typenorm
			local typealpha = CButtonTable[i].ButtonTypeAlpha or typenorm
			local typealtalpha = CButtonTable[i].ButtonTypeAltAlpha or CButtonTable[i].ButtonTypeAlpha or typealt
			-- local col = AdvCalc.Colors[CButtonTable[i].DispColor] or AdvCalc.Colors[1]
			-- local altcol = AdvCalc.Colors[CButtonTable[i].AltDispColor] or col
			-- local alphacol = AdvCalc.Colors[CButtonTable[i].AlphaDispColor] or col
			-- local altalphacol = AdvCalc.Colors[CButtonTable[i].AltAlphaDispColor] or AdvCalc.Colors[CButtonTable[i].AlphaDispColor] or AdvCalc.Colors[CButtonTable[i].AltDispColor] or col
			Button:SetSize(buttonx, buttony)
			--Button:SetTextColor(tcol)
			Button.DoClick = function()
				if ConO:GetBool() then surface.PlaySound("doors/handle_pushbar_locked1.wav") end
				local reqins = AdvCalc.Alt and AdvCalc.Alpha and altalphafunctext or AdvCalc.Alpha and alphafunctext or AdvCalc.Alt and altfunctext or functext
				local ftype = AdvCalc.Alt and AdvCalc.Alpha and typealtalpha or AdvCalc.Alpha and typealpha or AdvCalc.Alt and typealt or typenorm
				if isfunction(CButtonTable[i].RunAltAlphaFunction) and AdvCalc.Alpha and AdvCalc.Alt then
					CButtonTable[i]:RunAltAlphaFunction()
				elseif isfunction(CButtonTable[i].RunAlphaFunction) and AdvCalc.Alpha then
					CButtonTable[i]:RunAlphaFunction()
				elseif isfunction(CButtonTable[i].RunAltFunction) and AdvCalc.Alt then
					CButtonTable[i]:RunAltFunction()
				elseif isfunction(CButtonTable[i].RunFunction) then
					CButtonTable[i]:RunFunction()
				elseif reqins ~= "" then
					if AdvCalc.ForceInsert then
						if ftype == "number" then
							if CheckAdvCSyntax("[%a)]") then
								table.insert(AdvCalc.typed,AdvCalc.inspos,"*"..reqins)
							else
								table.insert(AdvCalc.typed,AdvCalc.inspos,reqins)
							end
						elseif ftype == "func" or ftype == "var" then
							if CheckAdvCSyntax("[%w)]") then
								table.insert(AdvCalc.typed,AdvCalc.inspos,"*"..reqins)
							else
								table.insert(AdvCalc.typed,AdvCalc.inspos,reqins)
							end
						elseif ftype == "pad if null" then
							if CheckAdvCSyntax("[%(,]") or CheckAdvCSyntax(nil) then
								table.insert(AdvCalc.typed,AdvCalc.inspos,"1"..reqins)
							else
								table.insert(AdvCalc.typed,AdvCalc.inspos,reqins)
							end
						elseif ftype == "operand" then
							if CheckAdvCSyntax("[^%w%)]") or CheckAdvCSyntax(nil) then
								table.insert(AdvCalc.typed,AdvCalc.inspos,"0"..reqins)
							else
								table.insert(AdvCalc.typed,AdvCalc.inspos,reqins)
							end
						elseif ftype == "negate" then
							if CheckAdvCSyntax("[%+%-]") and not CheckAdvCSyntax(nil) then
								table.insert(AdvCalc.typed,AdvCalc.inspos,"0"..reqins)
							else
								table.insert(AdvCalc.typed,AdvCalc.inspos,reqins)
							end
						elseif ftype == "space if num" then
							if CheckAdvCSyntax("%d") then
								table.insert(AdvCalc.typed,AdvCalc.inspos," "..reqins)
							elseif CheckAdvCSyntax(nil) then
								table.insert(AdvCalc.typed,AdvCalc.inspos,"\"\""..reqins)
							else
								table.insert(AdvCalc.typed,AdvCalc.inspos,reqins)
							end
						elseif ftype == "raw" then
							table.insert(AdvCalc.typed,AdvCalc.inspos,reqins)
						end
					else
						table.insert(AdvCalc.typed,AdvCalc.inspos,reqins)
					end
					AdvCalc.inspos = AdvCalc.inspos + 1
					AdvCalc.func = table.concat(AdvCalc.typed)
				end
				if ConA:GetBool() and not CButtonTable[i].DisableAutoRelease then
					AdvCalc.Alt = false
					AdvCalc.Alpha = false
				end
			end
			Button.Paint = function(panel,w,h)
				draw.RoundedBox(ConR:GetInt(),0,0,w,h,Button:IsDown() and Color(255,255,255) or ConB:GetBool() and CButtonTable[i].RainbowColors and HSVToColor((SysTime()*ConP:GetFloat()*10+ConH:GetInt())%360,ConT:GetFloat(),math.min(2-ConV:GetFloat()*2,1)) or AdvCalc.Alpha and AdvCalc.Alt and AdvCalc.Colors[CButtonTable[i].AltAlphaDispColor] or AdvCalc.Alpha and AdvCalc.Colors[CButtonTable[i].AlphaDispColor] or AdvCalc.Alt and AdvCalc.Colors[CButtonTable[i].AltDispColor] or AdvCalc.Colors[CButtonTable[i].DispColor] or AdvCalc.Colors[1])
				if CButtonTable[i].Anglizer and Button.OldAngleMode ~= AdvCalc.AngleMode then
					Button.OldAlt = AdvCalc.Alt
					Button.OldAlpha = AdvCalc.Alpha
					Button.OldAngleMode = AdvCalc.AngleMode
					Button:SetText(string.Left(string.upper(AdvCalc.AngleMode),3))
				elseif not CButtonTable[i].Anglizer and (Button.OldAlpha ~= AdvCalc.Alpha or Button.OldAlt ~= AdvCalc.Alt) then
					Button.OldAlt = AdvCalc.Alt
					Button.OldAlpha = AdvCalc.Alpha
					Button:SetText(AdvCalc.Alpha and AdvCalc.Alt and altalphatext or AdvCalc.Alpha and alphatext or AdvCalc.Alt and alttext or text)
				end
				Button:SetTextColor(AdvCalc.Colors[CButtonTable[i].TextColor] or AdvCalc.Colors[17])
				--[[local newcol = AdvCalc.Colors[CButtonTable[i].TextColor] or AdvCalc.Colors[17]
				if tcol ~= newcol then
					tcol = newcol
					Button:SetTextColor(tcol)
				end]]
				local newx,newy,news = ConX:GetInt(),ConY:GetInt(),ConS:GetFloat()
				if w ~= newx or h ~= newy or spacing ~= news then
					buttonx = newx
					buttony = newy
					spacing = news
					Button:SetSize(buttonx, buttony)
					Main:SetSize(buttonx*xelements+spacing*(xelements+1), buttony*yelements+spacing*(yelements+2)+dispy+disttop)
					Main:InvalidateLayout()
				end
			end
		else
			local Button = Buttons:Add("DPanel")
			Button:SetSize(buttonx,buttony)
			Button:SetPaintBackground(false)
		end
	end
end

function ShowAdvCColorMenu()

	local panelx = 400
	local panely = 400

	if SERVER then return end
	local Main = vgui.Create("DFrame")
	Main:SetSize(panelx,panely)
	Main:Center()
	Main:MakePopup()
	Main:SetSizable(true)
	Main:SetTitle("Color Menu")
	
	local Panel = vgui.Create("DScrollPanel",Main)
	Panel:Dock(FILL)
	
	--[[local Warn = vgui.Create("DLabel",Panel)
	Warn:SetFont("DermaDefaultBold")
	Warn:SetText("NOTE: Text colors require a calculator restart to take effect!")
	Warn:SetTextColor(Color(255,255,0))
	Warn:SizeToContents()
	Warn:Dock(TOP)]]
	
	for i=1,#AdvCalc.Colors do
		local Cat = vgui.Create("DCollapsibleCategory",Panel)
		Cat:Dock(TOP)
		Cat:SetLabel(AdvCalc.Translations[i] or "Color "..i)
		
		local Mixer = vgui.Create("DColorMixer", Cat)
		Mixer:SetPos(0,disttop)
		Mixer:SetColor(AdvCalc.Colors[i])
		function Mixer:ValueChanged()
			AdvCalc.Colors[i] = Mixer:GetColor()
		end
		Cat:Toggle()
	end
	
	local Reset = vgui.Create("DButton",Panel)
	Reset:Dock(TOP)
	Reset:SetText("SAVE")
	Reset:SetTextColor(Color(0,127,0))
	Reset.DoClick = function()
		local current = SysTime()
		chat.AddText(Color(255,255,0),"Saving...")
		file.Write('advcalccolors.txt', util.TableToJSON(AdvCalc.Colors))
		chat.AddText(Color(0,255,0),"Finished in "..math.Round(SysTime()-current,6).."s!")
	end
	
	local Reset = vgui.Create("DButton",Panel)
	Reset:Dock(TOP)
	Reset:SetText("Reset All Colors")
	Reset:SetTextColor(Color(255,0,0))
	Reset.DoClick = function()
		Derma_Query("Are you sure?","Confirm Color Reset","Yes",function()
			Main:Close()
			AdvCalc.Colors = {
				[1]=Color(0,0,0),
				[2]=Color(191,191,191),
				[3]=Color(127,127,127),
				[4]=Color(255,255,255),
				[5]=Color(255,255,0),
				[6]=Color(0,255,0),
				[7]=Color(0,255,255),
				[8]=Color(127,0,255),
				[9]=Color(0,127,255),
				[10]=Color(255,0,0),
				[11]=Color(31,31,31),
				[12]=Color(127,0,0),
				[13]=Color(255,255,191),
				[14]=Color(127,63,0),
				[15]=Color(0,0,0),
				[16]=Color(0,0,0),
				[17]=Color(255,255,255),
				[18]=Color(63,63,63),
				[19]=Color(255,255,255),
				[20]=Color(0,0,0),
				[21]=Color(255,255,255),
				[22]=Color(255,255,255),
				[23]=Color(255,0,0),
				[24]=Color(0,255,0)
			}
		end,"No")
	end

end

function ShowAdvCOptionMenu()

	local panelx = 400
	local panely = 400

	if SERVER then return end
	local Main = vgui.Create("DFrame")
	Main:SetSize(panelx,panely)
	Main:Center()
	Main:MakePopup()
	Main:SetSizable(true)
	Main:SetTitle("Option Menu")
	
	local Panel = vgui.Create("DScrollPanel",Main)
	Panel:Dock(FILL)
	
	--[[local Warn = vgui.Create("DLabel",Panel)
	Warn:SetFont("DermaDefaultBold")
	Warn:SetText("NOTE: Resizing options require a\ncalculator restart to take effect!")
	Warn:SetTextColor(Color(255,0,0))
	Warn:SizeToContents()
	Warn:Dock(TOP)
	Warn:SetContentAlignment(8)]]
	
	--[[local Background = vgui.Create("DPanel",Panel)
	Background:Dock(FILL)]]
	
	local Form = vgui.Create("DForm",Panel)
	Form:Dock(TOP)
	Form:SetName("Options")
	Form:NumSlider("Button Length","advcalc_button_sizex",20,80,0)
	Form:NumSlider("Button Width","advcalc_button_sizey",20,80,0)
	Form:NumberWang("Roundness","advcalc_button_roundness",0,64,0)
	Form:NumberWang("Spacing","advcalc_button_spacing",0,80,0)
	Form:CheckBox("Button Sounds","advcalc_button_clicky")
	Form:CheckBox("Rainbow Option Buttons","advcalc_button_optionrainbow")
	Form:NumSlider("BG Speed","advcalc_color_cyclespeed",0,36,2)
	Form:NumSlider("BG Add Hue","advcalc_color_addhue",0,360,0)
	Form:NumSlider("BG Darkness","advcalc_color_darkness",0,1,2)
	Form:NumSlider("BG Saturation","advcalc_color_saturation",0,1,2)
	Form:CheckBox("Automatic Shift/Alpha Release","advcalc_button_autorelease")
	
	local Reset = vgui.Create("DButton",Panel)
	Reset:Dock(TOP)
	Reset:SetText("Reset All Options")
	Reset:SetTextColor(Color(255,0,0))
	Reset.DoClick = function()
		Derma_Query("Are you sure?","Confirm Reset","Yes",function()
			Main:Close()
			ConX:SetInt(40)
			ConY:SetInt(40)
			ConR:SetInt(4)
			ConS:SetInt(2)
			ConO:SetBool(true)
			ConB:SetBool(true)
			ConP:SetInt(1)
			ConH:SetInt(0)
			ConV:SetFloat(0.5)
			ConT:SetInt(1)
		end,"No")
	end

end

function AdvCalcDrawGraph(minx,maxx,func,str)

	local panelx = 400
	local panely = 400
	local maximized = false
	
	local vcenter = maxx > 0 and minx < 0
	local x_render,y_render,xval,yval

	if SERVER then return end
	local Main = vgui.Create("DFrame")
	Main:SetSize(panelx,panely)
	Main:Center()
	Main:MakePopup()
	Main:SetSizable(true)
	Main:SetTitle("Graph for "..str)
	Main:ShowCloseButton(false)
	
	Main.Paint = function(panel,w,h)
		draw.RoundedBox(4,0,0,w,h,HSVToColor((SysTime()*ConP:GetFloat()*10+ConH:GetInt())%360,ConT:GetFloat(),1-ConV:GetFloat()))
	end
	
	local XButton = vgui.Create("DButton",Main)
	XButton:SetPos(panelx-disttop,0)
	XButton:SetSize(disttop,disttop)
	XButton:SetFont("Marlett")
	XButton:SetText("r")
	XButton:SetTextColor(Color(255,255,255))
	XButton.DoClick = function()
		Main:Close()
	end
	XButton.Paint = function(panel,w,h)
		--draw.SimpleText("r","Marlett",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	
	local SButton = vgui.Create("DButton",Main)
	SButton:SetPos(panelx-disttop*2,0)
	SButton:SetSize(disttop,disttop)
	SButton:SetFont("Marlett")
	SButton:SetText("1")
	SButton:SetTextColor(Color(255,255,255))
	SButton.DoClick = function()
		if maximized then
			Main:SetDraggable(true)
			Main:SetSizable(true)
			Main:SetSize(panelx,panely)
			Main:Center()
			maximized = false
			SButton:SetText("1")
		else
			Main:SetSize(ScrW(),ScrH())
			Main:Center()
			Main:SetDraggable(false)
			Main:SetSizable(false)
			maximized = true
			SButton:SetText("2")
		end
	end
	SButton.Paint = function(panel,w,h)
		--draw.SimpleText(maximized and "2" or "1","Marlett",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	
	function Main:PerformLayout(w,h)
		XButton:SetPos(w-disttop,0)
		SButton:SetPos(w-disttop*2,0)
	end
	
	local Background = vgui.Create("DButton",Main)
	Background:Dock(FILL)
	Background:SetCursor("crosshair")
	Background:SetText("")
	
	local results = results or {}
	local maxval = 0
	local minval = 0
	
	function Background:PerformLayout(w,h)
		results = {}
		for i=minx,maxx,(maxx-minx)/w do
			if tostring(func(i)) ~= "nan" then
				results[#results+1] = func(i)
			else
				results[#results+1] = "nan"
			end
		end
		for k,v in ipairs(results) do
			if v ~= "nan" then
				maxval = math.max(maxval,v)
				minval = math.min(minval,v)
			end
		end
		if maxval == minval then
			maxval = maxval + 0.0000001
			minval = minval - 0.0000001
		end
		if x_render then
			xval = (x_render/w)*(maxx-minx)+minx
			yval = func(xval)
			if tostring(yval) ~= "nan" then
				y_render = h-(yval-minval)*h/(maxval-minval)
			else
				y_render = "nan"
			end
		end
	end
	
	local inbuffer = 0
	
	local Input = vgui.Create("DTextEntry",Main)
	Input:Dock(BOTTOM)
	Input:SetNumeric(true)
	Input.OnChange = function(self)
		inbuffer = tonumber(self:GetValue()) or 0
	end
	
	local InputButton = vgui.Create("DButton",Main)
	InputButton:Dock(BOTTOM)
	InputButton:SetText("Set X-coordinate For Selected Point")
	InputButton.DoClick = function()
		local dx,dy = Background:GetSize()
		x_render = math.Clamp(((inbuffer-minx)/(maxx-minx))*dx,0,dx)
		Background:InvalidateLayout(true)
	end
	--Input:SetSize(funclen, 20)
	--Input:CenterHorizontal()
	--Input:SetText(modelname)
	
	--Background:InvalidateLayout(true)
	
	Background.Paint = function(panel,w,h)
		local xcenter = minval < 0 and maxval > 0
		local halfw = vcenter and w*(-minx/(maxx-minx)) or w/2
		local halfh = xcenter and h*(maxval/(maxval-minval)) or h/2
		draw.NoTexture()
		surface.SetDrawColor(0,0,0)
		surface.DrawRect(0,0,w,h)
		draw.SimpleText("Currently rendering "..w.." points","HudHintTextSmall",0,0,AdvCalc.Colors[22])
		surface.SetDrawColor(AdvCalc.Colors[24])
		surface.DrawLine(halfw,0,halfw,h)
		draw.SimpleText(tostring(maxval),"DermaDefault",halfw,0,AdvCalc.Colors[24],TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText(tostring(minval),"DermaDefault",halfw,h,AdvCalc.Colors[24],TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)
		surface.SetDrawColor(AdvCalc.Colors[23])
		surface.DrawLine(0,halfh,w,halfh)
		draw.SimpleText(tostring(minx),"DermaDefault",0,halfh,AdvCalc.Colors[23],TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		draw.SimpleText(tostring(maxx),"DermaDefault",w,halfh,AdvCalc.Colors[23],TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		if xcenter and vcenter then
			draw.SimpleText("0","DermaDefault",halfw,halfh,AdvCalc.Colors[24],TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
			draw.SimpleText("0","DermaDefault",halfw,halfh,AdvCalc.Colors[23],TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		else
			local wx,hx = draw.SimpleText(vcenter and "0" or tostring((maxx+minx)/2),"DermaDefault",halfw,halfh,AdvCalc.Colors[23],TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
			draw.SimpleText(xcenter and "0" or tostring((maxval+minval)/2),"DermaDefault",halfw,halfh+hx,AdvCalc.Colors[24],TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		end
		surface.SetDrawColor(AdvCalc.Colors[21])
		for i=1,w-1 do
			if results[i] ~= "nan" and results[i+1] ~= "nan" then
				local xp = w/(w-1)*(i-1)
				local xp2 = w/(w-1)*(i)
				local yp = h-(results[i]-minval)*h/(maxval-minval)
				local yp2 = h-(results[i+1]-minval)*h/(maxval-minval)
				surface.DrawLine(xp,yp,xp2,yp2)
			end
		end
		if Background:IsDown() then
			local tx,ty = Background:CursorPos()
			x_render = math.Clamp(tx,0,w)
			xval = (x_render/w)*(maxx-minx)+minx
			yval = func(xval)
			if tostring(yval) ~= "nan" then
				y_render = h-(yval-minval)*h/(maxval-minval)
			else
				y_render = "nan"
			end
		end
		if x_render and y_render ~= "nan" then
			surface.DrawCircle(x_render,y_render,5,AdvCalc.Colors[21])
			draw.SimpleText("("..xval..", "..yval..")","DermaDefault",x_render,y_render,AdvCalc.Colors[21],x_render > w/2 and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT,y_render < h/2 and TEXT_ALIGN_TOP or TEXT_ALIGN_BOTTOM)
		end
	end
	
	
	
	--[[Background.DoClick = function()
		local tx,ty = Background:CursorPos()
		local dx,dy = Background:GetSize()
		x_render = math.Clamp(tx,0,dx)
		Background:InvalidateLayout()
	end]]

end