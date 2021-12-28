local spacing_top = 32
local color_dark_red = Color(127,0,0)
local color_red = Color(255,0,0)
local color_yellow = Color(255,255,0)
local color_green = Color(0,255,0)
local color_aqua = Color(0,255,255)
local color_blue = Color(0,0,255)
local color_gray = Color(127,127,127)
local color_gray_translucent = Color(127,127,127,127)
local color_black_translucent = Color(0,0,0,127)

local buttonlabs = {"First","Last","Strong","Weak","Close","Far","Fast","Slow"}
local icns = {"shape_move_front","shape_move_back","award_star_gold_3","award_star_bronze_1","connect","disconnect","control_fastforward_blue","control_play"}

local classes = {
	"gballoon_red",
	"gballoon_blue",
	"gballoon_green",
	"gballoon_yellow",
	"gballoon_pink",
	"gballoon_white",
	"gballoon_black",
	"gballoon_purple",
	"gballoon_orange",
	"gballoon_zebra",
	"gballoon_aqua",
	"gballoon_gray",
	"gballoon_error",
	"gballoon_rainbow",
	"gballoon_ceramic",
	"gballoon_blimp_blue",
	"gballoon_brick",
	"gballoon_blimp_red",
	"gballoon_marble",
	"gballoon_blimp_green",
	"gballoon_blimp_gray",
	"gballoon_blimp_purple",
	"gballoon_blimp_magenta",
	"gballoon_blimp_rainbow",
}

local function GetUserEntry(run_func, def_type, def_flags)
	local currentparams = {def_type or "gballoon_*", def_flags or 255}
	
	local Main = vgui.Create("DFrame")
	Main:SetSize(ScrH()/3,ScrH()/2.5)
	Main:Center()
	Main:SetTitle("Entry Maker")
	Main:SetSizable(true)
	Main:MakePopup()
	
	local Scroller = vgui.Create("DScrollPanel", Main)
	Scroller:Dock(FILL)
	
	function Scroller:CreateEntry(text, optiontable, func, default)
	
		local Text = vgui.Create("DLabel", self)
		Text:SetText(text)
		Text:Dock(TOP)
		
		local OptionSelector = vgui.Create("DComboBox", self)
		OptionSelector:SetSortItems(false)
		for i,v in ipairs(optiontable) do
			OptionSelector:AddChoice(unpack(v))
		end
		OptionSelector:DockMargin(0,0,0,10)
		OptionSelector:Dock(TOP)
		function OptionSelector:OnSelect(index, name, value)
			func(value)
		end
		OptionSelector:SetValue(OptionSelector:GetOptionTextByData(default))
		
		return OptionSelector
	
	end
	
	local typetable = {
		{"Any gBalloon", "gballoon_*"},
		{"Any gBlimp", "gballoon_blimp_*"}
	}
	for k,v in pairs(classes) do
		table.insert(typetable, {list.GetForEdit("NPC")[v].Name, v})
	end
	Scroller:CreateEntry("Type:", typetable, function(value)
		currentparams[1] = value
	end, currentparams[1])

	--[[ List flags:
	1: +Fast
	2: -Fast
	4: +Hidden
	8: -Hidden
	16: +Regen
	32: -Regen
	64: +Shielded
	128: -Shielded]]
	
	Scroller.Modifier1 = Scroller:CreateEntry("Is Regen:", {{"#GameUI_Yes", 16}, {"#GameUI_No", 32}, {"Any", 48}}, function(value)
		currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(48)), value )
	end, bit.band(currentparams[2], 48))
	
	Scroller.Modifier3 = Scroller:CreateEntry("Is Fast:", {{"#GameUI_Yes", 1}, {"#GameUI_No", 2}, {"Any", 3}}, function(value)
		currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(3)), value )
	end, bit.band(currentparams[2], 3))
	
	Scroller.Modifier4 = Scroller:CreateEntry("Is Shielded:", {{"#GameUI_Yes", 64}, {"#GameUI_No", 128}, {"Any", 192}}, function(value)
		currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(192)), value )
	end, bit.band(currentparams[2], 192))
	
	Scroller.Modifier2 = Scroller:CreateEntry("Is Hidden:", {{"#GameUI_Yes", 4}, {"#GameUI_No", 8}, {"Any", 12}}, function(value)
		currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(12)), value )
	end, bit.band(currentparams[2], 12))
	
	local OKButton = vgui.Create("DButton", Scroller)
	OKButton:SetText(def_type and "Update Entry" or "Add Entry")
	OKButton:Dock(TOP)
	function OKButton:DoClick()
		Main:Close()
		run_func(currentparams)
	end
end

local function MakePopulationFunction(main_panel, list_panel, gballoon_list)
	local ToBeReturned
	ToBeReturned = function()
		list_panel:Clear()
		for k,v in pairs(gballoon_list) do
			local controlpanel = vgui.Create("DPanel", list_panel)
			controlpanel:SetTall(64)
			function controlpanel:Paint() end
			controlpanel:Dock(TOP)
			
			local buttonpanel = vgui.Create("DPanel", controlpanel)
			buttonpanel:SetWidth(32)
			function buttonpanel:Paint() end
			buttonpanel:Dock(RIGHT)
			
			local editbutton = vgui.Create("DImageButton", buttonpanel)
			editbutton:SetImage("icon16/cog.png")
			editbutton:SetTooltip("#GameUI_Modify")
			editbutton:SetTall(32)
			editbutton:Dock(TOP)
			function editbutton:DoClick()
				GetUserEntry(function(entry)
					if not IsValid(main_panel) then return end
					gballoon_list[k] = entry
					main_panel:SendToServer()
					ToBeReturned()
				end, v[1], v[2])
			end
			
			local removebutton = vgui.Create("DImageButton", buttonpanel)
			removebutton:SetImage("icon16/cancel.png")
			removebutton:SetTooltip("#GameUI_Remove")
			removebutton:Dock(FILL)
			function removebutton:DoClick()
				if not IsValid(main_panel) then return end
				table.remove(gballoon_list, k)
				main_panel:SendToServer()
				ToBeReturned()
			end
			
			local text = v[1] == "gballoon_*" and "All gBalloons" or v[1] == "gballoon_blimp_*" and "All gBlimps" or list.GetForEdit("NPC")[v[1]].Name.."s"
			if v[2] ~= 255 then
				local textparams = {}
				text = text.." that "
				if bit.band(v[2], 3) == 1 then
					table.insert(textparams, "are fast")
				elseif bit.band(v[2], 3) == 2 then
					table.insert(textparams, "are not fast")
				end
				if bit.band(v[2], 12) == 4 then
					table.insert(textparams, "are hidden")
				elseif bit.band(v[2], 12) == 8 then
					table.insert(textparams, "are not hidden")
				end
				if bit.band(v[2], 48) == 16 then
					table.insert(textparams, "can regenerate")
				elseif bit.band(v[2], 48) == 32 then
					table.insert(textparams, "can not regenerate")
				end
				if bit.band(v[2], 192) == 64 then
					table.insert(textparams, "are shielded")
				elseif bit.band(v[2], 192) == 128 then
					table.insert(textparams, "are not shielded")
				end
				
				local param_length = #textparams
				for i=1,param_length-2 do
					text = text..textparams[i]..", "
				end
				if param_length == 1 then
					text = text..textparams[1].."."
				else
					text = text..textparams[param_length-1].." and "..textparams[param_length].."."
				end
			else
				text = text.."."
			end
			
			local label = vgui.Create("DLabel", controlpanel)
			label:SetText(text)
			label:SetContentAlignment(7)
			label:SetWrap(true)
			label:Dock(FILL)
		end
	end
	return ToBeReturned
end

function ROTGB_CreateBlacklistPanel(blacklist, whitelist)
	
	local Main = vgui.Create("DFrame")
	Main:SetSize(ScrH()/2,ScrH()/2)
	Main:Center()
	Main:SetTitle("Blacklist Editor")
	Main:SetSizable(true)
	Main:MakePopup()
	function Main:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_translucent)
		if self:HasFocus() then
			draw.RoundedBox(8,0,0,w,24,color_black)
		end
	end
	Main.Blacklist = blacklist
	Main.Whitelist = whitelist
	function Main:SendToServer()
		net.Start("rotgb_generic")
		net.WriteUInt(ROTGB_OPERATION_BLACKLIST, 8)
		net.WriteUInt(#self.Blacklist,32)
		for k,v in pairs(self.Blacklist) do
			net.WriteString(v[1])
			net.WriteUInt(v[2],8)
		end
		net.WriteUInt(#self.Whitelist,32)
		for k,v in pairs(self.Whitelist) do
			net.WriteString(v[1])
			net.WriteUInt(v[2],8)
		end
		net.SendToServer()
	end
	
	local WarningText = vgui.Create("DLabel", Main)
	WarningText:SetFont("DermaDefaultBold")
	WarningText:SetText("Warning: The blacklist also affects gBalloon Spawners and gBalloons' children!")
	WarningText:SetWrap(true)
	WarningText:SetAutoStretchVertical(true)
	WarningText:SetTextColor(color_red)
	WarningText:Dock(TOP)
	
	local Divider = vgui.Create("DHorizontalDivider",Main)
	Divider:Dock(FILL)
	Divider:SetDividerWidth(4)
	Divider:SetLeftWidth(ScrH()/4-7)
	
	local LeftPanel = vgui.Create("DPanel",Divider)
	LeftPanel:DockPadding(4,4,4,4)
	function LeftPanel:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_translucent)
	end
	Divider:SetLeft(LeftPanel)
	
	local LeftScrollPanel = vgui.Create("DScrollPanel", LeftPanel)
	LeftScrollPanel:Dock(FILL)
	LeftScrollPanel.Populate = MakePopulationFunction(Main, LeftScrollPanel, Main.Blacklist)
	LeftScrollPanel:Populate()
	
	local LeftHeader = vgui.Create("DPanel",LeftPanel)
	function LeftHeader:Paint() end
	LeftHeader:Dock(TOP)
	
	local LeftButton = vgui.Create("DButton",LeftHeader)
	LeftButton:SetText("Add New Entry")
	LeftButton:SetTextColor(color_aqua)
	LeftButton:SizeToContentsX(8)
	LeftButton:Dock(RIGHT)
	function LeftButton:DoClick()
		GetUserEntry(function(entry)
			if not IsValid(Main) then return end
			table.insert(Main.Blacklist, entry)
			Main:SendToServer()
			LeftScrollPanel:Populate()
		end)
	end
	function LeftButton:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,self:IsHovered() and color_gray_translucent or color_black_translucent)
	end
	
	local LeftText = vgui.Create("DLabel",LeftHeader)
	LeftText:SetText("Blacklist:")
	LeftText:Dock(FILL)
	
	local RightPanel = vgui.Create("DPanel",Divider)
	RightPanel:DockPadding(4,4,4,4)
	function RightPanel:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_translucent)
	end
	Divider:SetRight(RightPanel)
	
	local RightScrollPanel = vgui.Create("DScrollPanel", RightPanel)
	RightScrollPanel:Dock(FILL)
	RightScrollPanel.Populate = MakePopulationFunction(Main, RightScrollPanel, Main.Whitelist)
	RightScrollPanel:Populate()
	
	local RightHeader = vgui.Create("DPanel",RightPanel)
	function RightHeader:Paint() end
	RightHeader:Dock(TOP)
	
	local RightButton = vgui.Create("DButton",RightHeader)
	RightButton:SetText("Add New Entry")
	RightButton:SetTextColor(color_aqua)
	RightButton:SizeToContentsX(8)
	RightButton:Dock(RIGHT)
	function RightButton:DoClick()
		GetUserEntry(function(entry)
			if not IsValid(Main) then return end
			table.insert(Main.Whitelist, entry)
			Main:SendToServer()
			RightScrollPanel:Populate()
		end)
	end
	function RightButton:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,self:IsHovered() and color_gray_translucent or color_black_translucent)
	end
	
	local RightText = vgui.Create("DLabel",RightHeader)
	RightText:SetText("Except for:")
	RightText:Dock(FILL)
end

function ROTGB_CauseNotification(msg)
	notification.AddLegacy(msg,NOTIFY_ERROR,5)
	surface.PlaySound("buttons/button10.wav")
end


local function GetUserWaveCompEntry(run_func, defs)
	local currentparams = {"gballoon_*", 255, -1, -1, -1}
	
	--[[ List flags:
	1: +Fast
	2: -Fast
	4: +Hidden
	8: -Hidden
	16: +Regen
	32: -Regen
	64: +Shielded
	128: -Shielded]]
	
	if defs then
		local npcdata = list.GetForEdit("NPC")[defs[1]]
		local KVs = npcdata.KeyValues
		currentparams[1] = KVs.BalloonType
		local bits = currentparams[2]
		if tobool(KVs.BalloonFast) then
			bits = bits - 2
		else
			bits = bits - 1
		end
		if tobool(KVs.BalloonHidden) then
			bits = bits - 8
		else
			bits = bits - 4
		end
		if tobool(KVs.BalloonRegen) then
			bits = bits - 32
		else
			bits = bits - 16
		end
		if tobool(KVs.BalloonShielded) then
			bits = bits - 128
		else
			bits = bits - 64
		end
		currentparams[2], currentparams[3], currentparams[4], currentparams[5] = bits, defs[2] or 1, defs[3] or 0, defs[4] or 0
	end
	
	local Main = vgui.Create("DFrame")
	Main:SetSize(ScrH()*0.4,ScrH()*0.5)
	Main:Center()
	Main:SetTitle("Entry Maker")
	Main:SetSizable(true)
	Main:MakePopup()
	
	local Scroller = vgui.Create("DScrollPanel", Main)
	Scroller:Dock(FILL)
	
	function Scroller:CreateEntry(text, optiontable, func, default)
	
		local Text = vgui.Create("DLabel", self)
		Text:SetText(text)
		Text:Dock(TOP)
		
		local OptionSelector = vgui.Create("DComboBox", self)
		OptionSelector:SetSortItems(false)
		for i,v in ipairs(optiontable) do
			OptionSelector:AddChoice(unpack(v))
		end
		OptionSelector:DockMargin(0,0,0,10)
		OptionSelector:Dock(TOP)
		function OptionSelector:OnSelect(index, name, value)
			func(value)
		end
		OptionSelector:SetValue(OptionSelector:GetOptionTextByData(default))
		
		return OptionSelector
	
	end
	
	local typetable = {
		Either(defs,nil,{"< don't change >", "gballoon_*"})
	}
	for k,v in pairs(classes) do
		table.insert(typetable, {list.GetForEdit("NPC")[v].Name, v})
	end
	Scroller:CreateEntry("Type:", typetable, function(value)
		currentparams[1] = value
	end, currentparams[1])
	
	Scroller.Modifier1 = Scroller:CreateEntry("Is Regen:", {{"#GameUI_Yes", 16}, {"#GameUI_No", 32}, not defs and {"< don't change >", 48} or nil}, function(value)
		currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(48)), value )
	end, bit.band(currentparams[2], 48))
	
	Scroller.Modifier2 = Scroller:CreateEntry("Is Fast:", {{"#GameUI_Yes", 1}, {"#GameUI_No", 2}, not defs and {"< don't change >", 3} or nil}, function(value)
		currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(3)), value )
	end, bit.band(currentparams[2], 3))
	
	Scroller.Modifier3 = Scroller:CreateEntry("Is Shielded:", {{"#GameUI_Yes", 64}, {"#GameUI_No", 128}, not defs and {"< don't change >", 192} or nil}, function(value)
		currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(192)), value )
	end, bit.band(currentparams[2], 192))
	
	Scroller.Modifier4 = Scroller:CreateEntry("Is Hidden:", {{"#GameUI_Yes", 4}, {"#GameUI_No", 8}, not defs and {"< don't change >", 12} or nil}, function(value)
		currentparams[2] = bit.bor( bit.band(currentparams[2], bit.bnot(12)), value )
	end, bit.band(currentparams[2], 12))
	
	function Main:CreateNumSlider(argnum, low, dec, text)
		local AmountSelector = vgui.Create("DNumSlider", Main)
		AmountSelector:SetText(text.." (-1 = don't change)")
		AmountSelector:Dock(TOP)
		AmountSelector:SetMin(-1)
		AmountSelector:SetMax(300)
		AmountSelector:SetDecimals(dec)
		AmountSelector:SetDefaultValue(low)
		AmountSelector:SetValue(currentparams[argnum])
		function AmountSelector:OnValueChanged(value)
			currentparams[argnum] = value
		end
	end
	
	Main:CreateNumSlider(3, 1, 0, "Amount")
	Main:CreateNumSlider(4, 0, 2, "Timespan")
	Main:CreateNumSlider(5, 0, 2, "Delay")
	
	local OKButton = vgui.Create("DButton", Scroller)
	OKButton:SetText("Modify Entry")
	OKButton:Dock(TOP)
	function OKButton:DoClick()
		Main:Close()
		run_func(currentparams)
	end
	
	return Main
end

local function GetUserWaveEntry(wavedata, run_func)
	
	local Main = vgui.Create("DFrame")
	Main:SetSize(ScrH()*0.6,ScrH()*0.6)
	Main:Center()
	Main:SetTitle("Wave Editor")
	Main:SetSizable(true)
	Main:MakePopup()
	function Main:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_translucent)
		if Main:HasFocus() then
			draw.RoundedBox(8,0,0,w,24,color_black)
		end
	end
	--[[function Main:SwitchBoolsToText(booly,booln)
		return tobool(booly) and not tobool(booln) and "#GameUI_Yes" or "#GameUI_No"
	end]]
	
	local buttonpanel = vgui.Create("DPanel", Main)
	buttonpanel:SetWidth(32)
	function buttonpanel:Paint() end
	buttonpanel:Dock(RIGHT)
	
	local WaveComponents = vgui.Create("DListView", Main)
	WaveComponents:Dock(FILL)
	WaveComponents:SetMultiSelect(true)
	local col = WaveComponents:AddColumn("Type")
	col:SetWidth(250)
	WaveComponents:AddColumn("Amount")
	WaveComponents:AddColumn("Timespan")
	WaveComponents:AddColumn("Delay")
	function WaveComponents:OnRowSelected()
		if not self.first then
			for k,v in pairs(buttonpanel:GetChildren()) do
				v:Show()
			end
			self.first = true
		end
	end
	
	function Main:GetWaveStats()
		local rbe, duration = 0, 0
		for k,v in pairs(WaveComponents:GetLines()) do
			local npcdata = list.GetForEdit("NPC")[v.wavecomp[1]]
			local KVs = npcdata.KeyValues
			--[[PrintTable(scripted_ents.GetStored("gballoon_base").t.rotgb_rbetab)
			print(KVs.BalloonType)
			print(scripted_ents.GetStored("gballoon_base").t.rotgb_rbetab[KVs.BalloonType])
			print(tobool(KVs.BalloonShielded) and 2 or 1)]]
			--PrintTable(v.wavecomp)
			rbe = rbe + scripted_ents.GetStored("gballoon_base").t.rotgb_rbetab[KVs.BalloonType]*(tobool(KVs.BalloonShielded) and 2 or 1)*(v.wavecomp[2] or 1)
			duration = math.max(duration, (v.wavecomp[3] or 0)+(v.wavecomp[4] or 0))
		end
		return rbe, duration
	end
	
	local lineclassfunc = function(self)
		local npcdata = list.GetForEdit("NPC")[self.wavecomp[1]]
		local name = npcdata.Name
		local KVs = npcdata.KeyValues
		
		if tobool(KVs.BalloonShielded) then
			name = "Shielded " .. name
		end
		if tobool(KVs.BalloonRegen) then
			name = "Regen " .. name
		end
		if tobool(KVs.BalloonHidden) then
			name = "Hidden " .. name
		end
		if tobool(KVs.BalloonFast) then
			name = "Fast " .. name
		end
		
		self:SetColumnText(1, name)
		self:SetColumnText(2, self.wavecomp[2] or 1)
		self:SetColumnText(3, self.wavecomp[3] or 0)
		self:SetColumnText(4, self.wavecomp[4] or 0)
	end
	
	local addbutton = vgui.Create("DImageButton", buttonpanel)
	addbutton:SetImage("icon16/add.png")
	addbutton:SetTooltip("#GameUI_Add")
	addbutton:SetTall(32)
	addbutton:Dock(TOP)
	function addbutton:DoClick()
		local Line = WaveComponents:AddLine("Red gBalloon", 1, 0, 0)
		Line.wavecomp = {"gballoon_red"}
		Line.Refresh = lineclassfunc
	end
	
	local editbutton = vgui.Create("DImageButton", buttonpanel)
	editbutton:SetImage("icon16/cog.png")
	editbutton:SetTooltip("#GameUI_Modify")
	editbutton:SetTall(32)
	editbutton:Dock(TOP)
	editbutton:Hide()
	editbutton.HideOnDeselect = true
	function editbutton:DoClick()
		local liness = WaveComponents:GetSelected()
		--if #liness > 1 then
			local wpanel = GetUserWaveCompEntry(function(compdata)
				if IsValid(Main) then
					for k,v in pairs(liness) do
						--[[print("START:")
						PrintTable(v.wavecomp)
						print("MERGE:")
						PrintTable(compdata)]]
						local npcdata = list.GetForEdit("NPC")[v.wavecomp[1]]
						local KVs = npcdata.KeyValues
						local name, bits = "gballoon_", compdata[2]
						if bit.band(bits,3)==1 then
							name = name.."fast_"
						elseif bit.band(bits,3)==3 and tobool(KVs.BalloonFast) then
							name = name.."fast_"
						end
						if bit.band(bits,12)==4 then
							name = name.."hidden_"
						elseif bit.band(bits,12)==12 and tobool(KVs.BalloonHidden) then
							name = name.."hidden_"
						end
						if bit.band(bits,48)==16 then
							name = name.."regen_"
						elseif bit.band(bits,48)==48 and tobool(KVs.BalloonRegen) then
							name = name.."regen_"
						end
						if bit.band(bits,192)==64 then
							name = name.."shielded_"
						elseif bit.band(bits,192)==192 and tobool(KVs.BalloonShielded) then
							name = name.."shielded_"
						end
						local dname = compdata[1] ~= "gballoon_*" and compdata[1] or v.wavecomp[1]
						v.wavecomp[1] = name .. (dname:match("blimp_%w+$") or dname:match("%w+$"))
						if compdata[3] >= 0 then
							v.wavecomp[2] = compdata[3] > 1 and math.Round(compdata[3])
						end
						if compdata[4] >= 0 then
							v.wavecomp[3] = compdata[4] > 0 and compdata[4]
						end
						if compdata[5] >= 0 then
							v.wavecomp[4] = compdata[5] > 0 and compdata[5]
						end
						v:Refresh()
					end
				end
			end, #liness == 1 and liness[1].wavecomp)
		--[[else
			GetUserWaveCompEntry(function(d)
				local v = WaveComponents:GetSelectedLine()
				select(2,v).wavecomp = d
				v:Refresh()
			end)
		end]]
	end
	
	local removebutton = vgui.Create("DImageButton", buttonpanel)
	removebutton:SetImage("icon16/delete.png")
	removebutton:SetTooltip("#GameUI_Remove")
	removebutton:SetTall(32)
	removebutton:Dock(TOP)
	removebutton:Hide()
	removebutton.HideOnDeselect = true
	function removebutton:DoClick()
		Derma_Query("Are you sure?","#GameUI_Remove","#GameUI_Yes",function()
			for k,v in pairs(WaveComponents:GetSelected()) do
				WaveComponents:RemoveLine(v:GetID())
			end
			for k,v in pairs(buttonpanel:GetChildren()) do
				if v.HideOnDeselect then
					v:Hide()
				end
			end
			WaveComponents.first = false
		end,"#GameUI_No")
	end 
	
	--[[local upbutton = vgui.Create("DImageButton", buttonpanel)
	upbutton:SetImage("icon16/arrow_up.png")
	upbutton:SetTooltip("#tool.hoverball.up")
	upbutton:SetTall(32)
	upbutton:Dock(TOP)
	upbutton:Hide()
	upbutton.HideOnDeselect = true
	function upbutton:DoClick()
	end
	
	local downbutton = vgui.Create("DImageButton", buttonpanel)
	downbutton:SetImage("icon16/bullet_arrow_bottom.png")
	downbutton:SetTooltip("Move to Bottom")
	downbutton:SetTall(32)
	downbutton:Dock(TOP)
	downbutton:Hide()
	downbutton.HideOnDeselect = true
	function downbutton:DoClick()
		for k,v in pairs(WaveComponents:GetSelected()) do
			
		end
	end]]
	
	local acceptbutton = vgui.Create("DImageButton", buttonpanel)
	acceptbutton:SetImage("icon16/tick.png")
	acceptbutton:SetTooltip("#GameUI_Accept")
	acceptbutton:SetTall(32)
	acceptbutton:Dock(BOTTOM)
	function acceptbutton:DoClick()
		local preptable = {}
		for i,v in ipairs(WaveComponents:GetLines()) do
			table.insert(preptable,v.wavecomp)
		end
		preptable.rbe, preptable.duration = Main:GetWaveStats()
		Main:Close()
		run_func(preptable)
	end
	
	local cancelbutton = vgui.Create("DImageButton", buttonpanel)
	cancelbutton:SetImage("icon16/cross.png")
	cancelbutton:SetTooltip("#GameUI_Cancel")
	cancelbutton:SetTall(32)
	cancelbutton:Dock(BOTTOM)
	function cancelbutton:DoClick()
		Main:Close()
	end
	
	for i,v in ipairs(wavedata) do
		local Line = WaveComponents:AddLine("INVALID", -1, -1, -1)
		Line.wavecomp = v
		--Line.ID = i
		Line.Refresh = lineclassfunc
		Line:Refresh()
	end
	
end

local acceptmat = Material("icon16/tick.png")

local localWaves, localEdited = {}

function ROTGB_CreateWavePanel()
	
	local Main = vgui.Create("DFrame")
	Main:SetSize(ScrH()*0.5,ScrH()*0.5)
	Main:Center()
	Main:SetTitle("Wave Editor")
	Main:SetSizable(true)
	Main:MakePopup()
	function Main:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_translucent)
		if Main:HasFocus() then
			draw.RoundedBox(8,0,0,w,24,color_black)
		end
	end
	function Main:SupplyFileSelector(rtext, rfunc)
		return function()
			local FileMain = vgui.Create("DFrame")
			FileMain:SetSize(ScrH()*0.5,ScrH()*0.5)
			FileMain:Center()
			FileMain:MakePopup()
			
			if not file.IsDir("rotgb_wavedata", "DATA") then
				file.CreateDir("rotgb_wavedata")
			end
			
			local ButtonPanel = vgui.Create("DPanel", FileMain)
			function ButtonPanel:Paint() end
			
			local FileEntry = vgui.Create("DTextEntry", ButtonPanel)
			FileEntry:Dock(FILL)
			FileEntry:SetPlaceholderText("Enter a file name")
			
			--[[function FileBrowser:OnSelect(path)
				
			end]]
			
			local OKButton = vgui.Create("DButton", ButtonPanel)
			OKButton:SetText(rtext)
			OKButton:SizeToContentsX(8)
			OKButton:SizeToContentsY(8)
			
			ButtonPanel:SetHeight(OKButton:GetTall())
			ButtonPanel:Dock(BOTTOM)
			
			OKButton:Dock(RIGHT)
			
			local FileBrowser = vgui.Create("DTree", FileMain)
			FileBrowser:Dock(FILL)
			function FileBrowser:Refresh()
				FileBrowser:Clear()
				local FolderNode = FileBrowser:AddNode("data/rotgb_wavedata")
				for k,v in pairs(file.Find("rotgb_wavedata/*.dat","DATA")) do
					local FileNode = FolderNode:AddNode(v, "icon16/page.png")
					function FileNode:DoClick()
						
						FileEntry:SetValue(string.gsub(v, "^(.*)%.dat$", "%1"))
						
					end
					function FileNode:DoRightClick()
						
						local FileMenu = DermaMenu()
						FileMenu:AddOption("#GameUI_Delete", function()
							Derma_Query("Are you sure?","#GameUI_Delete","#GameUI_Yes",function()
								file.Delete("rotgb_wavedata/"..v)
								FileBrowser:Refresh()
							end,"#GameUI_No")
						end)
						FileMenu:AddOption("Rename", function()
							Derma_StringRequest("Rename","Enter New Name",Main.FileName,function(text)
								file.Rename("rotgb_wavedata/"..v, "rotgb_wavedata/"..text..".dat")
								FileBrowser:Refresh()
							end,nil,"Rename")
						end)
						FileMenu:Open()
						
					end
				end
			end
			FileBrowser:Refresh()
			
			--[[FileBrowser:SetPath("DATA")
			FileBrowser:SetBaseFolder("rotgb_wavedata")
			FileBrowser:SetName("data/rotgb_wavedata")]]
			
			function OKButton:DoClick()
				if FileEntry:GetValue()=="" then
					Derma_Message("Please enter a file name.",rtext,"#GameUI_OK")
				else
					rfunc("rotgb_wavedata/"..FileEntry:GetValue()..".dat", FileMain)
				end
			end
		end
	end
	Main.btnMaxim:SetEnabled(true)
	function Main.btnMaxim:DoClick()
		if Main.OldBounds then
			Main:SetSize(Main.OldBounds[3],Main.OldBounds[4])
			Main:SetPos(Main.OldBounds[1],Main.OldBounds[2])
			Main:SetDraggable(true)
			Main:SetSizable(true)
			Main.OldBounds = nil
		else
			Main.OldBounds = {Main:GetBounds()}
			Main:SetSize(ScrW(),ScrH())
			Main:SetPos(0,0)
			Main:SetDraggable(false)
			Main:SetSizable(false)
		end
	end
	Main.FileName = ""
	
	local HeadingBar = vgui.Create("DMenuBar", Main)
	HeadingBar:Dock(TOP)
	
	local ScrollPanel = vgui.Create("DScrollPanel", Main)
	ScrollPanel:Dock(FILL)
	
	local FileMenu = HeadingBar:AddMenu("File")
	
	FileMenu:AddOption("#GameUI_SaveGame_New", function()
		if localEdited then
			Derma_Query("Are you sure?","#GameUI_SaveGame_New","#GameUI_Yes",function()
				if not IsValid(Main) then return end
				localEdited = false
				localWaves = {}
				ScrollPanel:Populate()
			end,"#GameUI_No")
		else
			localWaves = {}
			ScrollPanel:Populate()
		end
	end):SetIcon("icon16/page_white.png")
	
	FileMenu:AddOption("#GameUI_Save", Main:SupplyFileSelector("#GameUI_Save", function(path, window)
		if not IsValid(Main) then return end
		if file.Exists(path, "DATA") then
			Derma_Query("Are you sure?","#GameUI_SaveGame_Overwrite","#GameUI_ConfirmOverwriteSaveGame_OK",function()
				if not IsValid(Main) then return end
				file.Write(path, util.Compress(util.TableToJSON(localWaves)))
				localEdited = false
				window:Close()
			end,"#GameUI_No")
		else
			file.Write(path, util.Compress(util.TableToJSON(localWaves)))
			localEdited = false
			window:Close()
		end
	end)):SetIcon("icon16/disk.png")
	
	FileMenu:AddOption("#GameUI_Load", Main:SupplyFileSelector("#GameUI_Load", function(path, window)
		if not IsValid(Main) then return end
		local rawdata = file.Read(path)
		if rawdata then
			rawdata = util.JSONToTable(util.Decompress(rawdata))
			if rawdata then
				localWaves = rawdata
				localEdited = false
				window:Close()
				ScrollPanel:Populate()
			else
				Derma_Message("File decoding failed. It may have been corrupted.","#GameUI_LoadFailed","#GameUI_OK")
			end
		else
			Derma_Message("File not found.","#GameUI_LoadFailed","#GameUI_OK")
		end
	end)):SetIcon("icon16/folder_page.png")
	
	FileMenu:AddOption("Load Default Waves", function()
		if localEdited then
			Derma_Query("Are you sure?","Load Default Waves","#GameUI_Yes",function()
				if not IsValid(Main) then return end
				localEdited = false
				localWaves = table.Copy(ROTGB_WAVES)
				ScrollPanel:Populate()
			end,"#GameUI_No")
		else
			localWaves = table.Copy(ROTGB_WAVES)
			ScrollPanel:Populate()
		end
	end):SetIcon("icon16/arrow_refresh.png")
	
	FileMenu:AddSpacer()
	
	FileMenu:AddOption("Save to Server (Multiplayer Only)", function() 
		if not LocalPlayer():IsAdmin() then
			return Derma_Message("You don't have administrator privileges!","#GameUI_LoadFailed","#GameUI_OK")
		end
		if game.SinglePlayer() then
			return Derma_Message("This option is only useful in multiplayer.","#GameUI_ServerAuthDisabled","#GameUI_OK")
		end
		Main:SupplyFileSelector("Save to Server", function(path, window)
			if not IsValid(Main) then return end
			local rawdata = file.Read(path)
			if rawdata then
				local textdata = util.JSONToTable(util.Decompress(rawdata))
				if textdata then
					local packetlength = 60000
					local datablocks = math.ceil(#rawdata/packetlength)
					for i=1,datablocks do
						net.Start("rotgb_generic")
						net.WriteUInt(ROTGB_OPERATION_WAVE_TRANSFER, 8)
						net.WriteString(string.gsub(path, "^rotgb_wavedata/(.*)%.dat$", "%1"))
						net.WriteUInt(datablocks, 16)
						net.WriteUInt(i, 16)
						local datafrac = rawdata:sub(packetlength*(i-1)+1, packetlength*i)
						net.WriteUInt(#datafrac, 16)
						net.WriteData(datafrac, #datafrac)
						net.SendToServer()
					end
				else
					Derma_Message("File decoding failed. It may have been corrupted.","#GameUI_LoadFailed","#GameUI_OK")
				end
			else
				Derma_Message("File not found.","#GameUI_LoadFailed","#GameUI_OK")
			end
		end)()
	end):SetIcon("icon16/transmit_go.png")
	
	FileMenu = HeadingBar:AddMenu("Edit")
	
	--[[local FileSubMenu, FileButton = FileMenu:AddSubMenu("Add New Wave")
	FileButton:SetIcon("icon16/add.png")]]
	
	FileMenu:AddOption("Add New Wave (from top)", function()
		localEdited = true
		table.insert(localWaves, 1, { {"gballoon_red",10,10}, rbe=10, duration=10} )
		ScrollPanel:Populate()
	end):SetIcon("icon16/add.png")
	
	FileMenu:AddOption("Add New Wave (from bottom)", function()
		localEdited = true
		table.insert(localWaves, { {"gballoon_red",10,10}, rbe=10, duration=10} )
		ScrollPanel:Populate()
	end):SetIcon("icon16/add.png")
	
	function ScrollPanel:Populate()
		self:Clear()
		local rbelist = scripted_ents.GetStored("gballoon_base").t.rotgb_rbetab
		for i,v in ipairs(localWaves) do
			local controlpanel = vgui.Create("DPanel", self)
			controlpanel:SetTall(128)
			function controlpanel:Paint(w,h)
				draw.RoundedBox(8,0,0,w,h,color_black_translucent)
			end
			controlpanel:DockMargin(0,4,0,0)
			controlpanel:Dock(TOP)
			
			local buttonpanel = vgui.Create("DPanel", controlpanel)
			buttonpanel:SetWidth(64)
			function buttonpanel:Paint() end
			buttonpanel:Dock(RIGHT)
			
			local editbutton = vgui.Create("DImageButton", buttonpanel)
			editbutton:SetImage("icon16/cog.png")
			editbutton:SetTooltip("#GameUI_Modify")
			editbutton:SetSize(32,32)
			editbutton:SetPos(0,32)
			function editbutton:DoClick()
				GetUserWaveEntry(v,function(wavedata)
					localEdited = true
					--PrintTable(wavedata)
					if IsValid(Main) then
						localWaves[i] = wavedata
						ScrollPanel:Populate()
					end
				end)
			end
			
			local removebutton = vgui.Create("DImageButton", buttonpanel)
			removebutton:SetImage("icon16/cancel.png")
			removebutton:SetTooltip("#GameUI_Remove")
			removebutton:SetSize(32,32)
			removebutton:SetPos(32,32)
			function removebutton:DoClick()
				Derma_Query("Are you sure?","#GameUI_Remove","#GameUI_Yes",function()
					localEdited = true
					if not IsValid(Main) then return end
					table.remove(localWaves, i)
					ScrollPanel:Populate()
				end,"#GameUI_No")
			end
			
			local copybutton = vgui.Create("DImageButton", buttonpanel)
			copybutton:SetImage("icon16/page_copy.png")
			copybutton:SetTooltip("#spawnmenu.menu.copy")
			copybutton:SetSize(32,32)
			copybutton:SetPos(0,64)
			function copybutton:DoClick()
				SetClipboardText(util.TableToJSON(v))
				copybutton.realtimeset = RealTime() + 1
			end
			function copybutton:PaintOver()
				if (copybutton.realtimeset or 0) > RealTime() then
					surface.SetMaterial(acceptmat)
					surface.SetDrawColor(255,255,255,255*math.sqrt(copybutton.realtimeset-RealTime()))
					self:DrawTexturedRect()
				end
			end
			
			local pastebutton = vgui.Create("DImageButton", buttonpanel)
			pastebutton:SetImage("icon16/page_paste.png")
			pastebutton:SetTooltip("Paste / Import")
			pastebutton:SetSize(32,32)
			pastebutton:SetPos(32,64)
			function pastebutton:DoClick()
				Derma_StringRequest("Paste / Import","Paste textual wave data below, then press \"Import\".","",function(text)
					local data = util.JSONToTable(text)
					if (data and data.rbe and data.duration) then
						localEdited = true
						localWaves[i] = data
						ScrollPanel:Populate()
					else
						Derma_Message("Wave data was invalid!","JSON Error","#GameUI_OK")
					end
				end,nil,"Import")
			end
			
			if i ~= 1 then
				local upbutton = vgui.Create("DImageButton", buttonpanel)
				upbutton:SetImage("icon16/bullet_arrow_up.png")
				upbutton:SetTooltip("Move Up")
				upbutton:SetSize(32,32)
				upbutton:SetPos(0,0)
				function upbutton:DoClick()
					localEdited = true
					table.insert(localWaves, i-1, table.remove(localWaves, i))
					ScrollPanel:Populate()
				end
				
				local superupbutton = vgui.Create("DImageButton", buttonpanel)
				superupbutton:SetImage("icon16/bullet_arrow_top.png")
				superupbutton:SetTooltip("Move To Top")
				superupbutton:SetSize(32,32)
				superupbutton:SetPos(32,0)
				function superupbutton:DoClick()
					localEdited = true
					table.insert(localWaves, 1, table.remove(localWaves, i))
					ScrollPanel:Populate()
				end
			end
			
			if i ~= #localWaves then
				local downbutton = vgui.Create("DImageButton", buttonpanel)
				downbutton:SetImage("icon16/bullet_arrow_down.png")
				downbutton:SetTooltip("Move Down")
				downbutton:SetSize(32,32)
				downbutton:SetPos(0,96)
				function downbutton:DoClick()
					localEdited = true
					table.insert(localWaves, i+1, table.remove(localWaves, i))
					ScrollPanel:Populate()
				end
				
				local superdownbutton = vgui.Create("DImageButton", buttonpanel)
				superdownbutton:SetImage("icon16/bullet_arrow_bottom.png")
				superdownbutton:SetTooltip("Move To Bottom")
				superdownbutton:SetSize(32,32)
				superdownbutton:SetPos(32,96)
				function superdownbutton:DoClick()
					localEdited = true
					table.insert(localWaves, table.remove(localWaves, i))
					ScrollPanel:Populate()
				end
			end
			
			local balloons, rbe, duration = {}, 0
			for k2, v2 in pairs(v) do
				if k2 == "rbe" then
					rbe = v2
				elseif k2 == "duration" then
					duration = v2
				elseif tonumber(k2) then
					balloons[v2[1]] = (balloons[v2[1]] or 0) + (v2[2] or 1)
				end
			end
			
			local balloonkeys = table.GetKeys(balloons)
			table.sort(balloonkeys, function(a,b)
				local npcdata1 = list.GetForEdit("NPC")[a]
				local KV1 = npcdata1.KeyValues
				local npcdata2 = list.GetForEdit("NPC")[b]
				local KV2 = npcdata2.KeyValues
				local rbe1 = rbelist[KV1.BalloonType]
				local rbe2 = rbelist[KV2.BalloonType]
				if rbe1 == rbe2 then
					rbe1, rbe2 = tobool(KV1.BalloonFast), tobool(KV2.BalloonFast)
					if rbe1 == rbe2 then
						rbe1, rbe2 = tobool(KV1.BalloonHidden), tobool(KV2.BalloonHidden)
						if rbe1 == rbe2 then
							rbe1, rbe2 = tobool(KV1.BalloonRegen), tobool(KV2.BalloonRegen)
							if rbe1 == rbe2 then return tobool(KV1.BalloonShielded)
							else return rbe1
							end
						else return rbe1
						end
					else return rbe1
					end
				else
					return rbe1 > rbe2 
				end
			end)
			
			local wavelabel = vgui.Create("DLabel", controlpanel)
			wavelabel:SetText("Wave "..i.." (RgBE: "..rbe..(duration and ", Duration: "..duration or "")..")")
			wavelabel:SetFont("DermaDefaultBold")
			wavelabel:SizeToContentsY()
			wavelabel:Dock(TOP)
			
			local wavecontents = vgui.Create("RichText", controlpanel)
			wavecontents:SetText("")
			wavecontents:SetVerticalScrollbarEnabled()
			wavecontents:Dock(FILL)
			function wavecontents:PerformLayout()
				self:SetFontInternal("DermaDefault")
				if self:GetNumLines() > 9 then
					self:SetVerticalScrollbarEnabled(true)
				end
			end
			
			for i2,v2 in ipairs(balloonkeys) do
				local npcdata = list.GetForEdit("NPC")[v2]
				local KVs = npcdata.KeyValues
				local hue,sat,val = ColorToHSV(string.ToColor(KVs.BalloonColor))
				if sat == 1 then val = 1 end
				sat = sat / 2
				val = (val + 1) / 2
				local col = HSVToColor(hue,sat,val)
				wavecontents:InsertColorChange(col.r,col.g,col.b,col.a)
				wavecontents:AppendText(balloons[v2] .. "x ")
				if tobool(KVs.BalloonFast) then
					wavecontents:AppendText("Fast ")
				end
				if tobool(KVs.BalloonHidden) then
					wavecontents:AppendText("Hidden ")
				end
				if tobool(KVs.BalloonRegen) then
					wavecontents:AppendText("Regen ")
				end
				if tobool(KVs.BalloonShielded) then
					wavecontents:AppendText("Shielded ")
				end
				wavecontents:AppendText(npcdata.Name.."\n")
			end
		end
	end
	ScrollPanel:Populate()
end

function ROTGB_UpgradeMenu(ent)

	if not IsValid(ent) then return end
	if not ent.SellAmount then
		ent.SellAmount = ent.Cost and ROTGB_ScaleBuyCost(ent.Cost, ent, {type = ROTGB_TOWER_PURCHASE}) or 0
	end
	
	local Main = vgui.Create("DFrame")
	Main:SetSize(ScrH()/2,ScrH()/2)
	Main:Center()
	Main:SetTitle(language.GetPhrase(ent:GetClass()).." Upgrade Tree")
	Main:SetSizable(true)
	Main:MakePopup()
	function Main:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_translucent)
		if self:HasFocus() then
			draw.RoundedBox(8,0,0,w,24,color_black)
		end
		if gui.IsGameUIVisible() then self:Close() end
	end
	Main.SetOfUpgrades = {}
	function Main:Refresh(bool)
		--[[ this is kinda complicated
		first, order the bought upgrades so that the highest tier is first in the table, then the second highest, etc.
		so 0-3-0-3 becomes 3-3-0-0
		
		then, calculate upgrade limits
		4 <= 5 -> 5
		4 <= 4 -> 5
		1 <= 3 -> 3
		0 <= 0 -> 0
		]]
		local ctiers = {}
		for k,v in pairs(self.SetOfUpgrades) do
			table.insert(ctiers,{v.Tier-1,v})
		end
		table.SortByMember(ctiers,1)
		--[[for i,v in ipairs(ctiers) do
			local pathLevel = v[1]
			local prevPath = ctiers[i-1] or {}
			local prevPathLevel, prevPathUpgrade = prevPath[1], prevPath[2]
			local prevPathUpgradeEnabled = not prevPathUpgrade or prevPathUpgrade:IsEnabled()
			local dontLock = pathLevel < ent.UpgradeLimits[i] or (prevPathUpgradeEnabled and prevPathLevel == pathLevel)
			local enabled = dontLock or ROTGB_GetConVarValue("rotgb_ignore_upgrade_limits") or ent:GetNWFloat("rotgb_noupgradelimit") >= CurTime()
			v[2]:SetEnabled(enabled)
		end]]
		local slot = 1
		for i,v in ipairs(ctiers) do
			v[2].MaxTier = ent.UpgradeLimits[slot]
			if v[1] > (ent.UpgradeLimits[i+1] or 0) then slot = i + 1 end
		end
		for k,v in pairs(ctiers) do
			local pathRespected = v[1] < v[2].MaxTier or ROTGB_GetConVarValue("rotgb_ignore_upgrade_limits") or ent:GetNWFloat("rotgb_noupgradelimit") >= CurTime()
			v[2]:SetEnabled(pathRespected)
		end
		if bool then
			for k,v in pairs(self.SetOfUpgrades) do
				v:Refresh()
			end
		end
	end
	
	local ListOfUpgrades = vgui.Create("DScrollPanel",Main)
	ListOfUpgrades:Dock(FILL)
	
	local reference = ent.UpgradeReference
	
	local SellButton = vgui.Create("DButton",Main)
	SellButton:SetText("Sell / Remove ($"..string.Comma(math.floor(ent.SellAmount*0.8))..")")
	SellButton:SetTextColor(color_red)
	SellButton:SetFont("DermaLarge")
	SellButton:SetTall(32)
	SellButton:Dock(BOTTOM)
	function SellButton:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,self:IsHovered() and color_gray_translucent or color_black_translucent)
	end
	function SellButton:DoClick()
		if not IsValid(ent) then
			Main:Close()
			return ROTGB_CauseNotification("Tower is invalid!")
		end
		Derma_Query("Are you sure you want to sell this tower?","Are you sure?",
		"Yes",function()
			if IsValid(ent) then
				if IsValid(Main) then Main:Close() end
				net.Start("rotgb_openupgrademenu")
				net.WriteEntity(ent)
				net.WriteUInt(11,4)
				net.SendToServer()
			end
		end,"No")
	end
	
	for i=0,#reference-1 do -- make this zero-indexed
		
		local curcash = ROTGB_GetCash(LocalPlayer())
		local reftab = reference[i+1]
		local upgradenum = #reftab.Prices
		local UpgradeStatement = ListOfUpgrades:Add("DButton")
		UpgradeStatement:SetSize(128,128)
		UpgradeStatement:DockMargin(0,0,0,5)
		UpgradeStatement:Dock(TOP)
		UpgradeStatement:SetContentAlignment(7)
		UpgradeStatement:SetWrap(true)
		UpgradeStatement:SetDoubleClickingEnabled(false)
		function UpgradeStatement:Refresh(bool)
			if not IsValid(ent) then
				Main:Close()
				return ROTGB_CauseNotification("Tower is invalid!")
			end
			self.Tier = self.Tier or bit.rshift(ent:GetUpgradeStatus(),i*4)%16+1
			self.price = ROTGB_ScaleBuyCost(reftab.Prices[self.Tier], ent, {type = ROTGB_TOWER_UPGRADE, path = i+1, tier = self.Tier})
			self:SetText(not reftab.Descs[self.Tier] and "\n\nThis path has been fully upgraded!" or not self:IsEnabled() and "\n\nThis path is locked due to the purchase of a certain upgrade!" or ("\n\n"..reftab.Descs[self.Tier]))
			self:SetTextColor(not reftab.Descs[self.Tier] and color_green or not self:IsEnabled() and color_red or color_white)
			Main:Refresh(bool)
			SellButton:SetText("Sell / Remove ($"..string.Comma(math.floor(ent.SellAmount*0.8))..")")
		end
		function UpgradeStatement:Paint(w,h)
			if not IsValid(ent) then
				Main:Close()
				return ROTGB_CauseNotification("Tower is invalid!")
			end
			curcash = ROTGB_GetCash(LocalPlayer())
			draw.RoundedBox(8,0,0,w,h,self:IsHovered() and color_gray_translucent or color_black_translucent)
			draw.SimpleText(not reftab.Names[self.Tier] and "Fully Upgraded!" or not self:IsEnabled() and "Path Locked!" or reftab.Names[self.Tier],"DermaLarge",0,0,not reftab.Names[self.Tier] and color_green or not self:IsEnabled() and color_red or color_white)
			if reftab.Prices[self.Tier] and self:IsEnabled() then
				draw.SimpleText("Price: "..string.Comma(math.ceil(self.price)),"DermaLarge",w,0,self.price>curcash and color_red or color_green,TEXT_ALIGN_RIGHT)
			end
		end
		function UpgradeStatement:DoClick()
			if not IsValid(ent) then
				Main:Close()
				return ROTGB_CauseNotification("Tower is invalid!")
			end
			if not reftab.Prices[self.Tier] then return ROTGB_CauseNotification("Upgrade is invalid!") end
			if curcash<self.price then return ROTGB_CauseNotification("You need $"..string.Comma(math.ceil(self.price-curcash)).." more to buy this upgrade!") end
			if (reftab.Funcs and reftab.Funcs[self.Tier]) then
				reftab.Funcs[self.Tier](ent)
			end
			net.Start("rotgb_openupgrademenu")
			net.WriteEntity(ent)
			net.WriteUInt(i,4)
			net.WriteUInt(0,4)
			net.SendToServer()
			ent.SellAmount = (ent.SellAmount or 0) + self.price
			self.Tier = self.Tier + 1
			self.price = ROTGB_ScaleBuyCost(reftab.Prices[self.Tier], ent, {type = ROTGB_TOWER_UPGRADE, path = i+1, tier = self.Tier})
			self:Refresh(true)
		end
		
		local UpgradeIndicatorPanel = UpgradeStatement:Add("DPanel")
		UpgradeIndicatorPanel:SetTall(24)
		UpgradeIndicatorPanel:Dock(BOTTOM)
		function UpgradeIndicatorPanel:Paint() end
		
		for j=1,upgradenum do
			local price = ROTGB_ScaleBuyCost(reftab.Prices[j], ent, {type = ROTGB_TOWER_UPGRADE, path = i+1, tier = j})
			local HoverButton = UpgradeIndicatorPanel:Add("DButton")
			HoverButton:SetWide(24)
			HoverButton:SetText("")
			HoverButton:SetTooltip(reftab.Names[j].." ("..ROTGB_FormatCash(price, true)..")\n"..reftab.Descs[j])
			HoverButton:DockMargin(0,0,8,0)
			HoverButton:Dock(LEFT)
			HoverButton.RequiredAmount = 0
			function HoverButton:Paint(w,h)
				if self.Tier ~= UpgradeStatement.Tier then
					self.Tier = UpgradeStatement.Tier
					self.RequiredAmount = self:GetRequiredAmount()
				end
				local canAfford = curcash >= self.RequiredAmount
				local drawColor
				local pulser = math.sin(CurTime()*math.pi*2)/2+0.5
				local ignoreTier = ROTGB_GetConVarValue("rotgb_ignore_upgrade_limits") or ent:GetNWFloat("rotgb_noupgradelimit") >= CurTime()
				if j==self.Tier then
					if j>UpgradeStatement.MaxTier and not ignoreTier then
						drawColor = color_red
					elseif canAfford then
						drawColor = HSVToColor(60, 1-pulser, 1)
					else
						drawColor = color_yellow
					end
				else
					if j>UpgradeStatement.MaxTier and not ignoreTier then
						drawColor = color_dark_red
					elseif j>self.Tier then
						drawColor = canAfford and HSVToColor(0, 0, pulser/2+0.5) or color_gray
					else
						drawColor = color_green
					end
				end
				draw.RoundedBox(8,0,0,w,h,drawColor)
			end
			function HoverButton:GetRequiredAmount()
				if not self.Tier then return math.huge end
				if j < self.Tier then return 0 end
				local cost = 0
				for k=self.Tier,j do
					cost = cost + ROTGB_ScaleBuyCost(reftab.Prices[k], ent, {type = ROTGB_TOWER_UPGRADE, path = i+1, tier = k})
				end
				return cost
			end
			function HoverButton:DoClick()
				if not IsValid(ent) then
					Main:Close()
					return ROTGB_CauseNotification("Tower is invalid!")
				end
				if not (UpgradeStatement.MaxTier >= j or ROTGB_GetConVarValue("rotgb_ignore_upgrade_limits") or ent:GetNWFloat("rotgb_noupgradelimit") >= CurTime()) then return end
				local moreCashNeeded = self.RequiredAmount - curcash
				if moreCashNeeded>0 then return ROTGB_CauseNotification("You need "..ROTGB_FormatCash(moreCashNeeded, true).." more to buy this upgrade!") end
				for k=self.Tier,j do
					if (reftab.Funcs and reftab.Funcs[k]) then
						reftab.Funcs[k](ent)
					end
					UpgradeStatement.Tier = UpgradeStatement.Tier + 1
				end
				net.Start("rotgb_openupgrademenu")
				net.WriteEntity(ent)
				net.WriteUInt(i,4)
				net.WriteUInt(j-self.Tier,4)
				net.SendToServer()
				ent.SellAmount = (ent.SellAmount or 0) + self.RequiredAmount
				UpgradeStatement:Refresh(true)
			end
		end
		
		UpgradeStatement:Refresh()
		table.insert(Main.SetOfUpgrades,UpgradeStatement)
		
	end
	
	local TargetButton = vgui.Create("DButton",Main)
	TargetButton.CurSetting = ent:GetTargeting()
	TargetButton:SetText(ent.UserTargeting and "Targeting: "..buttonlabs[TargetButton.CurSetting+1] or "Targeting: Ambiguous")
	TargetButton:SetTextColor(ent.UserTargeting and color_white or color_gray)
	TargetButton:SetFont("DermaLarge")
	TargetButton:SetContentAlignment(5)
	TargetButton:SetTall(32)
	TargetButton:Dock(BOTTOM)
	function TargetButton:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,self:IsHovered() and ent.UserTargeting and color_gray_translucent or color_black_translucent)
	end
	function TargetButton:DoClick()
		if not IsValid(ent) then
			Main:Close()
			return ROTGB_CauseNotification("Tower is invalid!")
		end
		if input.IsShiftDown() then
			self.CurSetting = (self.CurSetting-1)%#buttonlabs
			net.Start("rotgb_openupgrademenu")
			net.WriteEntity(ent)
			net.WriteUInt(9,4)
			net.SendToServer()
		else
			self.CurSetting = (self.CurSetting+1)%#buttonlabs
			net.Start("rotgb_openupgrademenu")
			net.WriteEntity(ent)
			net.WriteUInt(8,4)
			net.SendToServer()
		end
		self:SetText(ent.UserTargeting and "Targeting: "..buttonlabs[self.CurSetting+1] or "Targeting: Ambiguous")
		self:SetTextColor(ent.UserTargeting and color_white or color_gray)
	end
	function TargetButton:DoRightClick()
		if not IsValid(ent) then
			Main:Close()
			return ROTGB_CauseNotification("Tower is invalid!")
		end
		if not ent.UserTargeting then return end
		local TargetMenu = DermaMenu(self)
		for i=1,#buttonlabs do
			local Option = TargetMenu:AddOption(buttonlabs[i],function()
				self.CurSetting = i-1
				net.Start("rotgb_openupgrademenu")
				net.WriteEntity(ent)
				net.WriteUInt(10,4)
				net.WriteUInt(i-1,4)
				net.SendToServer()
				self:SetText(ent.UserTargeting and "Targeting: "..buttonlabs[self.CurSetting+1] or "Targeting: Ambiguous")
				self:SetTextColor(ent.UserTargeting and color_white or color_gray)
			end)
			Option:SetIcon("icon16/"..icns[i]..".png")
		end
		TargetMenu:Open()
	end
	
	local InfoButton = vgui.Create("DButton",Main)
	InfoButton.CurrentPops = ent:GetPops()
	InfoButton.CurrentCash = ent:GetCashGenerated()
	if InfoButton.CurrentCash > 0 then
		InfoButton:SetText("Damage: "..string.Comma(InfoButton.CurrentPops).." | Cash: "..ROTGB_FormatCash(InfoButton.CurrentCash))
	else
		InfoButton:SetText("Damage: "..string.Comma(InfoButton.CurrentPops))
	end
	InfoButton:SetTextColor(color_white)
	InfoButton:SetFont("DermaLarge")
	InfoButton:SetContentAlignment(5)
	InfoButton:SetTall(32)
	InfoButton:Dock(BOTTOM)
	function InfoButton:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_translucent)
		if (IsValid(ent) and (self.CurrentPops ~= ent:GetPops() or self.CurrentCash ~= ent:GetCashGenerated())) then
			self.CurrentPops = ent:GetPops()
			self.CurrentCash = ent:GetCashGenerated()
			if self.CurrentCash > 0 then
				self:SetText("Damage: "..string.Comma(self.CurrentPops).." | Cash: "..ROTGB_FormatCash(self.CurrentCash))
			else
				self:SetText("Damage: "..string.Comma(self.CurrentPops))
			end
		end
	end
	
	Main:Refresh(true)
	
end