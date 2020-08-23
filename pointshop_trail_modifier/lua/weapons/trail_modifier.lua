AddCSLuaFile()
if SERVER then
	util.AddNetworkString("OpenTrailMenu")
end

SWEP.Category			= "Pointshop"
SWEP.Spawnable			= true
SWEP.AdminOnly			= GetConVar("trailmodifier_admin_only") and GetConVar("trailmodifier_admin_only"):GetBool()
SWEP.PrintName			= "Trail Modifier"
--	SWEP.Base				= weapon_base
SWEP.m_WeaponDeploySpeed= util.IsValidModel("models/weapons/v_models/v_builder_engineer.mdl") and 0.5 or 2
SWEP.Author				= "Piengineer"
SWEP.Contact			= "http://steamcommunity.com/id/Piengineer12/"
SWEP.Purpose			= "Allows you to add custom trails to yourself."
SWEP.Instructions		= "Right-click while this device is equipped."
SWEP.ViewModel			= util.IsValidModel("models/weapons/v_models/v_builder_engineer.mdl") and "models/weapons/v_models/v_builder_engineer.mdl" or "models/weapons/cstrike/c_c4.mdl"
--	SWEP.ViewModelFlip		= false
--	SWEP.ViewModelFlip1		= false
--	SWEP.ViewModelFlip2		= false
--	SWEP.ViewModelFOV		= 62
SWEP.WorldModel			= util.IsValidModel("models/weapons/w_models/w_builder.mdl") and "models/weapons/w_models/w_builder.mdl" or "models/weapons/w_c4.mdl"
SWEP.AutoSwitchFrom		= false
SWEP.AutoSwitchTo		= false
--	SWEP.Weight				= 5
--	SWEP.BobScale			= 1
--	SWEP.SwayScale			= 1
--	SWEP.BounceWeaponIcon	= true
--	SWEP.DrawWeaponInfoBox	= true
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
--	SWEP.RenderGroup		= RENDERGROUP_OPAQUE
SWEP.Slot				= 3
--	SWEP.SlotPos			= 10
--	SWEP.SpeechBubbleLid	= surface.GetTextureID("gui/speech_lid")
--	SWEP.WepSelectIcon		= surface.GetTextureID("weapons/swep")
--	SWEP.CSMuzzleFlashes	= false
--	SWEP.CSMuzzleX			= false
SWEP.Primary			= {
	Ammo		= "none",
	ClipSize	= -1,
	DefaultClip	= -1,
	Automatic	= false
}
SWEP.Secondary			= {
	Ammo		= "none",
	ClipSize	= -1,
	DefaultClip	= -1,
	Automatic	= false
}
--	SWEP.UseHands			= false
--	SWEP.AccurateCrosshair	= false
--	SWEP.DisableDuplicator	= false

function SWEP:PrimaryAttack()
	-- Do nothing
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	if IsValid(self.Owner) and SERVER then
		net.Start("OpenTrailMenu",true)
			net.WriteBool(false)
			net.WriteTable(self.Owner.RemotelyAddedTrails or {})
		net.Send(self.Owner)
	end
	--self.Weapon:SetSubMaterial(4,"computerscreen03")
end

function SWEP:Deploy()
end

-- Shared

local trailfiles
local customTrails

local function ReadFiles()

	trailfiles = file.Find("materials/trails/*.vmt","GAME")
	customTrails = {}
	for k,v in ipairs(trailfiles) do
		customTrails["trails/"..v] = 100
	end
	--local _1,_2 = SortedPairs(customTrails)
	--customTrails = _2
	--PrintTable(customTrails)

	if file.Exists("customtrailoptions.txt","DATA") then
		local rawtext = file.Read("customtrailoptions.txt","DATA")
		if rawtext then
			local newtable = util.JSONToTable(rawtext)
			if newtable then
				table.Merge(customTrails,newtable)
				file.Write("customtrailoptions.txt",util.TableToJSON(customTrails,true))
			else
				--print("Not JSONable")
				file.Write("customtrailoptions.txt",util.TableToJSON(customTrails,true))
			end
		else
			--print("Not Readable")
			file.Write("customtrailoptions.txt",util.TableToJSON(customTrails,true))
		end
	else
		--print("Not Findable")
		file.Write("customtrailoptions.txt",util.TableToJSON(customTrails,true))
	end

	for k,v in pairs(customTrails) do
		if tonumber(v) then
			if tonumber(v) < 0 then
				customTrails[k] = nil
			end
		else
			customTrails[k] = nil
		end
	end

end

ReadFiles()

-- Client

if CLIENT then
	local attachments = attachments or {}
	local equippedMat = Material("gui/ps_hover.png")
	local holsteredMat = Material("gui/sm_hover.png")
	local isInInventory = false
	net.Receive("OpenTrailMenu",function(length,sender)
		if not PS then return end
		local ply = LocalPlayer()
		if not ply.RemotelyAddedTrails then ply.RemotelyAddedTrails = {} end
		local isReceiving = net.ReadBool()
		if not IsValid(sender) and not isReceiving then -- It's the server who sent it
			
			local dataGotten = net.ReadTable()
			if dataGotten ~= {} then -- We actually got something?
				ply.RemotelyAddedTrails = dataGotten
			end
			
			surface.PlaySound("buttons/button9.wav")
			local panelx = ScrW()/2
			local panely = ScrH()/2
			local spacing = 2
			local spaceY = 24
			local spaceFromBottom = 0
			local itemname, cost
			local Main = vgui.Create("DFrame")
			Main:SetSize(panelx,panely)
			Main:Center()
			Main:SetTitle("")
			Main:SetVisible(true)
			Main:SetDraggable(true)
			Main:ShowCloseButton(true)
			Main:MakePopup()
			function Main:Paint(w,h)
				draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 127 ) )
				if Main:IsActive() then draw.RoundedBox( 4, 0, 0, w, spaceY, Color( 0, 0, 0, 127 ) ) end
				local w2,h2 = draw.SimpleText("Trail Store","PS_LargeTitle",0,0,color_white)
				draw.SimpleText("(You have "..ply:PS_GetPoints().." "..PS.Config.PointsName..")","PS_Heading2",16+w2,0,Color(255,255,0))
			end
			
			--TrailModifierUniqueNameMenu = Main
			
			local Scroller = vgui.Create("DScrollPanel",Main)
			Scroller:Dock(FILL)
			Scroller:InvalidateParent(true)
			local ToPaint = Scroller:GetVBar()
			function ToPaint:Paint(w,h)
				draw.RoundedBox( 2, 0, 0, w, h, Color( 0, 0, 0, 127 ) )
			end
			function ToPaint.btnUp:Paint(w,h)
				local onhov = self:IsHovered() and 255 or 191
				draw.RoundedBox( 2, 0, 0, w, h, Color( onhov, onhov, onhov, 255 ) )
				draw.SimpleText("5","marlett",w/2,h/2,Color(0,0,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			end
			function ToPaint.btnDown:Paint(w,h)
				local onhov = self:IsHovered() and 255 or 191
				draw.RoundedBox( 2, 0, 0, w, h, Color( onhov, onhov, onhov, 255 ) )
				draw.SimpleText("6","marlett",w/2,h/2,Color(0,0,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			end
			function ToPaint.btnGrip:Paint(w,h)
				local onhov = self:IsHovered() and 255 or 191
				draw.RoundedBox( 2, 0, 0, w, h, Color( onhov, onhov, onhov, 255 ) )
			end
			--Scroller:SetSize(panelx-spacing*2,panely-spacing-spaceY-spaceFromBottom)
			--Scroller:SetPos(spacing,spacing+spaceY)
			
			local Trails
			local ActivationButton
			local Main1
			local function CreateItems()
			
				if not IsValid(Scroller) then return end
				if IsValid(Trails) then Trails:Remove() end
				Trails = vgui.Create("DIconLayout",Scroller)
				Trails:SetSize(Scroller:GetSize())
				Trails:SetPos(0,0)
				Trails:SetSpaceX(spacing)
				Trails:SetSpaceY(spacing)
				
				local AllButton = Trails:Add("DButton")
				AllButton:SetSize(128,128)
				AllButton:SetText("< all\ntrails >")
				AllButton:SetTextColor(color_white)
				AllButton:SetFont("PS_Heading2")
				function AllButton:Paint(w,h)
					--surface.SetDrawColor(0,0,0,self:IsHovered() and 191 or 127)
					--surface.DrawRect(0,0,w,h)
				end
				function AllButton:DoClick()
					local SubMenu3 = DermaMenu(AllButton)
					local Sub11 = SubMenu3:AddOption("Buy All")
					local Sub12 = SubMenu3:AddOption("Sell All")
					local Sub13 = SubMenu3:AddOption("Equip All")
					local Sub14 = SubMenu3:AddOption("Holster All")
					local Sub15 = SubMenu3:AddOption("Modify All")
					function Sub11:DoClick()
						local buyprice = 0
						for k,v in pairs(customTrails) do
							if not ply.RemotelyAddedTrails[k] then
								buyprice = buyprice + PS.Config.CalculateBuyPrice(ply, {Price=v or 100})
							end
						end
						Derma_Query("Are you sure?\nIt takes "..buyprice.." "..PS.Config.PointsName.." to buy all of them!","Buy All","Yes",function()
							if buyprice > LocalPlayer():PS_GetPoints() then notification.AddLegacy( "Not enough "..PS.Config.PointsName.."!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
							net.Start("OpenTrailMenu",true)
								net.WriteString("ALL")
								net.WriteBool(true)
								net.WriteTable({buy=true})
							net.SendToServer()
						end,"No")
					end
					function Sub12:DoClick()
						local sellprice = 0
						for k,v in pairs(customTrails) do
							if ply.RemotelyAddedTrails[k] then
								sellprice = sellprice + PS.Config.CalculateSellPrice(ply, {Price=v or 100})
							end
						end
						Derma_Query("Are you sure?\nYou will earn up to "..sellprice.." "..PS.Config.PointsName.." if you do!","Sell All","Yes",function()
							net.Start("OpenTrailMenu",true)
								net.WriteString("ALL")
								net.WriteBool(true)
								net.WriteTable({sell=true})
							net.SendToServer()
						end,"No")
					end
					function Sub13:DoClick()
						local counter = 0
						for k,v in pairs(customTrails) do
							if isentity(ply.RemotelyAddedTrails[k]) and not IsValid(ply.RemotelyAddedTrails[k]) then
								counter = counter + 1
							end
						end
						Derma_Query("Are you sure?\nThis will equip "..counter.." trail"..(counter == 1 and "" or "s").."!","Equip All","Yes",function()
							net.Start("OpenTrailMenu",true)
								net.WriteString("ALL")
								net.WriteBool(true)
								net.WriteTable({equip=true})
							net.SendToServer()
						end,"No")
					end
					function Sub14:DoClick()
						local counter = 0
						for k,v in pairs(customTrails) do
							if IsValid(ply.RemotelyAddedTrails[k]) then
								counter = counter + 1
							end
						end
						Derma_Query("Are you sure?\nThis will holster "..counter.." trail"..(counter == 1 and "" or "s").."!","Holster All","Yes",function()
							net.Start("OpenTrailMenu",true)
								net.WriteString("ALL")
								net.WriteBool(true)
								net.WriteTable({holster=true})
							net.SendToServer()
						end,"No")
					end
					function Sub15:DoClick()
						if not ply.RemotelyAddedTrails.CUSTOM_OPTIONS then ply.RemotelyAddedTrails.CUSTOM_OPTIONS = {} end
						local options = ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trailTex] or {color_white, true, 16, 0, 4, 0.07}
						if IsValid(Main1) then Main1:Remove() end
						Main1 = vgui.Create("DFrame")
						Main1:SetSize(panelx,panely)
						Main1:Center()
						Main1:SetTitle("")
						Main1:SetVisible(true)
						Main1:SetDraggable(true)
						Main1:ShowCloseButton(true)
						Main1:MakePopup()
						function Main1:Paint(w,h)
							draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 191, 191, 255 ) )
							if Main1:IsActive() then draw.RoundedBox( 4, 0, 0, w, spaceY, Color( 0, 255, 255, 255 ) ) end
							draw.SimpleText("Mods For All Trails","PS_LargeTitle",0,0,color_white)
						end

						local Main2 = vgui.Create("DScrollPanel",Main1)
						Main2:Dock(FILL)
						Main2:InvalidateParent(true)
						
						local ResetButton = vgui.Create("DButton",Main2)
						ResetButton:Dock(TOP)
						--ResetButton:SetFont("PS_Heading2")
						ResetButton:SetText("Reset Options")
						ResetButton:SetTextColor(Color(255,0,0))
						
						local Option1 = vgui.Create("DColorMixer",Main2)
						Option1:Dock(TOP)
						Option1:SetLabel("Subtractive Coloring")
						Option1:SetColor(options[1])
						function Option1:ValueChanged(newval)
							options[1] = newval
						end
						
						local Option2 = vgui.Create("DCheckBoxLabel",Main2)
						Option2:Dock(TOP)
						Option2:SetText("Additive Rendering")
						Option2:SetValue(options[2])
						Option2:SetDark(true)
						function Option2:OnChange(newval)
							options[2] = newval
						end
						
						local Option3 = vgui.Create("DNumSlider",Main2)
						Option3:Dock(TOP)
						Option3:SetText("Starting Width")
						Option3:SetMin(0)
						Option3:SetMax(ConVarExists("trailmodifier_max_width") and GetConVar("trailmodifier_max_width"):GetFloat() or 128)
						Option3:SetDecimals(2)
						Option3:SetValue(options[3])
						Option3:SetDark(true)
						function Option3:OnValueChanged(newval)
							options[3] = newval
						end
						
						local Option4 = vgui.Create("DNumSlider",Main2)
						Option4:Dock(TOP)
						Option4:SetText("Ending Width")
						Option4:SetMin(0)
						Option4:SetMax(ConVarExists("trailmodifier_max_width") and GetConVar("trailmodifier_max_width"):GetFloat() or 128)
						Option4:SetDecimals(2)
						Option4:SetValue(options[4])
						Option4:SetDark(true)
						function Option4:OnValueChanged(newval)
							options[4] = newval
						end
						
						local Option5 = vgui.Create("DNumSlider",Main2)
						Option5:Dock(TOP)
						Option5:SetText("Lifetime")
						Option5:SetMin(0)
						Option5:SetMax(ConVarExists("trailmodifier_max_lifetime") and GetConVar("trailmodifier_max_lifetime"):GetFloat() or 30)
						Option5:SetDecimals(2)
						Option5:SetValue(options[5])
						Option5:SetDark(true)
						function Option5:OnValueChanged(newval)
							options[5] = newval
						end
						
						local Option6 = vgui.Create("DNumSlider",Main2)
						Option6:Dock(TOP)
						Option6:SetText("Resolution")
						Option6:SetMin(0.001)
						Option6:SetMax(0.999)
						Option6:SetDecimals(3)
						Option6:SetValue(options[6])
						Option6:SetDark(true)
						function Option6:OnValueChanged(newval)
							options[6] = newval
						end
						
						function ResetButton:DoClick()
							Derma_Query("Are you sure?","Reset Changes","Yes",function()
								options = {color_white, true, 16, 0, 4, 0.07}
								Option1:SetColor(options[1])
								Option2:SetValue(options[2])
								Option3:SetValue(options[3])
								Option4:SetValue(options[4])
								Option5:SetValue(options[5])
								Option6:SetValue(options[6])
							end,"No")
						end
						function ResetButton:Paint(w,h)
							draw.RoundedBox(4,0,0,w,h,Color(255,255,255,self:IsHovered() and 191 or 127))
						end
						
						local CommitButton = vgui.Create("DButton",Main2)
						CommitButton:Dock(TOP)
						--CommitButton:SetFont("PS_Heading2")
						CommitButton:SetText("Commit Changes")
						CommitButton:SetFont("PS_Heading2")
						CommitButton:SetTextColor(Color(0,127,0))
						function CommitButton:DoClick()
							net.Start("OpenTrailMenu",true)
								net.WriteString("ALL")
								net.WriteBool(false)
								net.WriteTable({modify=options})
							net.SendToServer()
							Main1:Close()
						end
						function CommitButton:Paint(w,h)
							draw.RoundedBox(4,0,0,w,h,Color(255,255,255,self:IsHovered() and 191 or 127))
						end
					end
					SubMenu3:Open()
				end
				for i,v in ipairs(attachments) do
					if not attachments[i]:IsError() then
						local trailTex = attachments[i]:GetName()..".vmt"
						if (not isInInventory or (isInInventory and ply.RemotelyAddedTrails[trailTex])) and tonumber(customTrails[trailTex]) then
							local Trail = Trails:Add("DImageButton")
							Trail:SetSize(128,128)
							Trail:SetMaterial(attachments[i])
							function Trail:DoClick()
								--print(attachments[i]:GetName())
								local SubMenu = DermaMenu(Trail)
								local Sub1 = SubMenu:AddOption(ply.RemotelyAddedTrails[trailTex] and "Sell" or "Buy")
								if ply.RemotelyAddedTrails[trailTex] then
									local Sub2
									if IsValid(ply.RemotelyAddedTrails[trailTex]) then
										Sub2 = SubMenu:AddOption("Holster")
									else
										Sub2 = SubMenu:AddOption("Equip")
									end
									function Sub2:DoClick()
										net.Start("OpenTrailMenu",true)
											net.WriteString(trailTex)
											net.WriteBool(false)
											net.WriteTable({})
										net.SendToServer()
									end
									Sub3 = SubMenu:AddOption("Modify")
									function Sub3:DoClick()
										if not ply.RemotelyAddedTrails.CUSTOM_OPTIONS then ply.RemotelyAddedTrails.CUSTOM_OPTIONS = {} end
										local options = ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trailTex] or {color_white, true, 16, 0, 4, 0.07}
										if IsValid(Main1) then Main1:Remove() end
										Main1 = vgui.Create("DFrame")
										Main1:SetSize(panelx,panely)
										Main1:Center()
										Main1:SetTitle("")
										Main1:SetVisible(true)
										Main1:SetDraggable(true)
										Main1:ShowCloseButton(true)
										Main1:MakePopup()
										function Main1:Paint(w,h)
											draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 191, 191, 255 ) )
											if Main1:IsActive() then draw.RoundedBox( 4, 0, 0, w, spaceY, Color( 0, 255, 255, 255 ) ) end
											draw.SimpleText("Mods For Trail \""..attachments[i]:GetName().."\"","PS_LargeTitle",0,0,color_white)
										end
			
										local Main2 = vgui.Create("DScrollPanel",Main1)
										Main2:Dock(FILL)
										Main2:InvalidateParent(true)
										
										local ResetButton = vgui.Create("DButton",Main2)
										ResetButton:Dock(TOP)
										--ResetButton:SetFont("PS_Heading2")
										ResetButton:SetText("Reset Options")
										ResetButton:SetTextColor(Color(255,0,0))
										
										local Option1 = vgui.Create("DColorMixer",Main2)
										Option1:Dock(TOP)
										Option1:SetLabel("Subtractive Coloring")
										Option1:SetColor(options[1])
										function Option1:ValueChanged(newval)
											options[1] = newval
										end
										
										local Option2 = vgui.Create("DCheckBoxLabel",Main2)
										Option2:Dock(TOP)
										Option2:SetText("Additive Rendering")
										Option2:SetValue(options[2])
										Option2:SetDark(true)
										function Option2:OnChange(newval)
											options[2] = newval
										end
										
										local Option3 = vgui.Create("DNumSlider",Main2)
										Option3:Dock(TOP)
										Option3:SetText("Starting Width")
										Option3:SetMin(0)
										Option3:SetMax(ConVarExists("trailmodifier_max_width") and GetConVar("trailmodifier_max_width"):GetFloat() or 128)
										Option3:SetDecimals(2)
										Option3:SetValue(options[3])
										Option3:SetDark(true)
										function Option3:OnValueChanged(newval)
											options[3] = newval
										end
										
										local Option4 = vgui.Create("DNumSlider",Main2)
										Option4:Dock(TOP)
										Option4:SetText("Ending Width")
										Option4:SetMin(0)
										Option4:SetMax(ConVarExists("trailmodifier_max_width") and GetConVar("trailmodifier_max_width"):GetFloat() or 128)
										Option4:SetDecimals(2)
										Option4:SetValue(options[4])
										Option4:SetDark(true)
										function Option4:OnValueChanged(newval)
											options[4] = newval
										end
										
										local Option5 = vgui.Create("DNumSlider",Main2)
										Option5:Dock(TOP)
										Option5:SetText("Lifetime")
										Option5:SetMin(0)
										Option5:SetMax(ConVarExists("trailmodifier_max_lifetime") and GetConVar("trailmodifier_max_lifetime"):GetFloat() or 30)
										Option5:SetDecimals(2)
										Option5:SetValue(options[5])
										Option5:SetDark(true)
										function Option5:OnValueChanged(newval)
											options[5] = newval
										end
										
										local Option6 = vgui.Create("DNumSlider",Main2)
										Option6:Dock(TOP)
										Option6:SetText("Resolution")
										Option6:SetMin(0.001)
										Option6:SetMax(0.999)
										Option6:SetDecimals(3)
										Option6:SetValue(options[6])
										Option6:SetDark(true)
										function Option6:OnValueChanged(newval)
											options[6] = newval
										end
										
										function ResetButton:DoClick()
											Derma_Query("Are you sure?","Reset Changes","Yes",function()
												options = {color_white, true, 16, 0, 4, 0.07}
												Option1:SetColor(options[1])
												Option2:SetValue(options[2])
												Option3:SetValue(options[3])
												Option4:SetValue(options[4])
												Option5:SetValue(options[5])
												Option6:SetValue(options[6])
											end,"No")
										end
										function ResetButton:Paint(w,h)
											draw.RoundedBox(4,0,0,w,h,Color(255,255,255,self:IsHovered() and 191 or 127))
										end
										
										local CommitButton = vgui.Create("DButton",Main2)
										CommitButton:Dock(TOP)
										--CommitButton:SetFont("PS_Heading2")
										CommitButton:SetText("Commit Changes")
										CommitButton:SetFont("PS_Heading2")
										CommitButton:SetTextColor(Color(0,127,0))
										function CommitButton:DoClick()
											net.Start("OpenTrailMenu",true)
												net.WriteString(trailTex)
												net.WriteBool(false)
												net.WriteTable(options)
											net.SendToServer()
											Main1:Close()
										end
										function CommitButton:Paint(w,h)
											draw.RoundedBox(4,0,0,w,h,Color(255,255,255,self:IsHovered() and 191 or 127))
										end
									end
								end
								function Sub1:DoClick()
									if not ply.RemotelyAddedTrails[trailTex] and customTrails[trailTex] > LocalPlayer():PS_GetPoints() then notification.AddLegacy( "Not enough "..PS.Config.PointsName.."!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
									Derma_Query("Are you sure?","Buy/Sell","Yes",function()
										net.Start("OpenTrailMenu",true)
											net.WriteString(trailTex)
											net.WriteBool(true)
										net.SendToServer()
									end,"No")
								end
								SubMenu:Open()
							end
							function Trail:DoRightClick()
								local SubMenu2 = DermaMenu(Trail)
								local Sub4 = SubMenu2:AddOption("Copy")
								function Sub4:DoClick()
									SetClipboardText(attachments[i]:GetName()..".vmt")
								end
								SubMenu2:Open()
							end
							function Trail:PaintOver(w,h)
								if ply.RemotelyAddedTrails[trailTex] then
									if IsValid(ply.RemotelyAddedTrails[trailTex]) then
										surface.SetDrawColor(255,255,255)
										surface.SetMaterial(equippedMat)
										surface.DrawTexturedRect(0,0,w,h)
									else
										surface.SetDrawColor(255,255,255)
										surface.SetMaterial(holsteredMat)
										surface.DrawTexturedRect(0,0,w,h)
									end
								end
								if self:IsHovered() then
									local targetPrice = PS.Config.CalculateBuyPrice(ply, {Price=customTrails[attachments[i]:GetName()..".vmt"] or 100})
									local sellPrice = PS.Config.CalculateSellPrice(ply, {Price=customTrails[attachments[i]:GetName()..".vmt"] or 100})
									draw.DrawText(attachments[i]:GetName().."\n"..(ply.RemotelyAddedTrails[trailTex] and ("+"..sellPrice) or ("-"..targetPrice)),"DefaultSmall",0,0,HSVToColor(((RealTime()*270)%360),1,1))
								end
							end
						end
					end
				end
			end
			
			if not attachments or #attachments == 0 then
				ActivationButton = vgui.Create("DButton",Main)
				ActivationButton:Dock(FILL)
				ActivationButton:SetFont("PS_Heading2")
				ActivationButton:SetText("Start loading!")
				ActivationButton:SetTextColor(Color(0,127,0))
				local prog = 0
				function ActivationButton:Paint(w,h)
					surface.SetDrawColor(0,0,0,self:IsHovered() and 191 or 127)
					surface.DrawRect(0,0,w,h)
					if true then
						surface.SetDrawColor(0,0,0,127)
						surface.DrawRect(0,h-20,w,20)
						surface.SetDrawColor(0,255,0,127)
						surface.DrawRect(0,h-20,prog and w*prog or 0,20)
					end
				end
				function ActivationButton:DoClick()
					ActivationButton:SetText("Just a minute...")
					ActivationButton:SetCursor("hourglass")
					--ActivationButton:Remove()
					--local ProgressBar = vgui.Create("DProgress",Main)
					--ProgressBar:Dock(BOTTOM)
					--ProgressBar:SetFraction(1/#trailfiles)
					--[[cam.Start2D()
						if isRendering then
							draw.SimpleText(math.Round(prog).."%","PS_Heading2",panelx+128,panely+128,Color(0,127,0))
						end
					cam.End2D()]]
					timer.Simple(RealFrameTime(),function()
						attachments = {}
						ActivationButton:SetPaintedManually(true)
						local lasttime = SysTime()
						for i,v in ipairs(trailfiles) do
							table.insert(attachments,(Material("trails/"..v)))
							if SysTime() > lasttime + 1/10 then
								cam.Start2D()
									prog = i/#trailfiles/2
									ActivationButton:PaintManual()
									render.Spin()
									lasttime = SysTime()
								cam.End2D()
							end
						end
						if not IsValid(Scroller) then return end
						if IsValid(Trails) then Trails:Remove() end
						Trails = vgui.Create("DIconLayout",Scroller)
						Trails:SetSize(Scroller:GetSize())
						Trails:SetPos(0,0)
						Trails:SetSpaceX(spacing)
						Trails:SetSpaceY(spacing)
						for i,v in ipairs(attachments) do
							if not attachments[i]:IsError() then
								local trailTex = attachments[i]:GetName()..".vmt"
								local Trail = Trails:Add("DImage")
								Trail:SetSize(128,128)
								Trail:SetMaterial(attachments[i])
							end
							if SysTime() > lasttime + 1/10 then
								cam.Start2D()
									prog = i/#attachments/2+0.5
									ActivationButton:PaintManual()
									render.Spin()
									lasttime = SysTime()
								cam.End2D()
							end
						end
						Main:Close()
					end)
				end
				return
			end
			
			CreateItems()
			
			local TabButton = vgui.Create("DButton",Main)
			TabButton:Dock(TOP)
			TabButton:SetFont("PS_Heading2")
			TabButton:SetText(isInInventory and "Back" or "See Trails in Inventory")
			TabButton:SetTextColor(color_white)
			--TabButton:SetTextColor(Color(0,255,0))
			function TabButton:DoClick()
				if IsValid(Trails) then Trails:Remove() end
				if isInInventory then
					isInInventory = false
					TabButton:SetText("See Trails in Inventory")
				else
					isInInventory = true
					TabButton:SetText("Back")
				end
				CreateItems()
			end
			function TabButton:Paint(w,h)
				draw.RoundedBox(4,0,0,w,h,Color(0,0,0,self:IsHovered() and 191 or 127))
			end
			
			if LocalPlayer():IsAdmin() then
				local AdminButton = vgui.Create("DButton",Main)
				AdminButton:Dock(BOTTOM)
				AdminButton:SetFont("PS_Heading2")
				AdminButton:SetText("Trail Prices (Admin Only)")
				AdminButton:SetTextColor(color_white)
				function AdminButton:Paint(w,h)
					draw.RoundedBox(4,0,0,w,h,Color(255,0,0,self:IsHovered() and 191 or 127))
				end
				function AdminButton:DoClick()
					local Main3 = vgui.Create("DFrame")
					Main3:SetSize(panelx,panely)
					Main3:Center()
					Main3:SetTitle("")
					Main3:SetVisible(true)
					Main3:SetDraggable(true)
					Main3:ShowCloseButton(true)
					Main3:MakePopup()
					function Main3:Paint(w,h)
						draw.RoundedBox( 4, 0, 0, w, h, Color( 127, 0, 0, 255 ) )
						if Main3:IsActive() then draw.RoundedBox( 4, 0, 0, w, spaceY, Color( 255, 0, 0, 255 ) ) end
						draw.SimpleText("Trail Prices","PS_LargeTitle",0,0,color_white)
					end
					
					local Scroller2
					
					local function UpdateString()
					
						if IsValid(Scroller2) then Scroller2:Remove() end
						Scroller2 = vgui.Create("DScrollPanel",Main3)
						Scroller2:SetSize(panelx,panely-spaceY-80)
						Scroller2:SetPos(0,spaceY+80)
					
						local content = util.TableToJSON(customTrails,true)
						
						for i=1,math.ceil(#content/1000) do
							local DispLabel = Label(string.sub(content,i*1000-999,math.min(i*1000,#content)))
							DispLabel:SetTextColor(color_white)
							DispLabel:SizeToContents()
							DispLabel:Dock(TOP)
							Scroller2:AddItem(DispLabel)
						end
						
					end
					
					UpdateString()
					
					local State = Label("Sorry for the occasional line breaks! It will still be saved properly.",Main3)
					State:SetTextColor(Color(255,255,0))
					State:SetSize(panelx,20)
					State:SetPos(0,spaceY+60)
					
					local key, value = "", 0
					
					local Entry = vgui.Create("DTextEntry",Main3)
					Entry:SetSize(panelx,20)
					Entry:SetPos(0,spaceY)
					Entry:SetText("Type material here, set to ALL to set for all trails (e.g. trails/lol.vmt)")
					function Entry:OnChange()
						key = Entry:GetValue() or key
					end
					
					local Entry2 = vgui.Create("DTextEntry",Main3)
					Entry2:SetSize(panelx,20)
					Entry2:SetPos(0,spaceY+20)
					Entry2:SetText("Type price here, set to -1 to disable (e.g. 50)")
					function Entry2:OnChange()
						value = tonumber(Entry2:GetValue()) or value
					end
					
					local CommitEntry = vgui.Create("DButton",Main3)
					CommitEntry:SetSize(panelx,20)
					CommitEntry:SetPos(0,spaceY+40)
					CommitEntry:SetText("Commit Change")
					CommitEntry:SetFont("PS_Heading2")
					CommitEntry:SetTextColor(Color(0,127,0))
					function CommitEntry:DoClick()
						net.Start("OpenTrailMenu",true)
							net.WriteString(key)
							net.WriteBool(false)
							net.WriteTable({TO_COMBINE = true, price = value})
						net.SendToServer()
						timer.Simple(RealFrameTime()*10, function()
							UpdateString()
							CreateItems()
						end)
					end
					function CommitEntry:Paint(w,h)
						draw.RoundedBox(4,0,0,w,h,Color(255,255,255,self:IsHovered() and 191 or 127))
					end
				end
			end
			
		elseif not IsValid(sender) and PS then
			local data = net.ReadTable()
			if data.READ_FILES then
				ReadFiles()
			else
				ply.RemotelyAddedTrails = data
			end
		end
	end)
end

-- Server

local readmetext = [[
NOTE: You may need to use WordPad (or similar) to display this text file properly.

The .vmt (Valve Material Type) files in this folder are to be placed inside materials/trails.
Simply remove the .txt extension of the files to activate the VMTs.
All VMTs inside the files follow the following structure:

"UnlitGeneric"
{
	"$basetexture" "<name>"
	"$vertexalpha" 1
	"$vertexcolor" 1
}

...where <name> is the respective VTF (Valve Texture Format).

Note that the above is very simple and has much room for improvement.
However, if you are unfamiliar with the VMT format, the above will suffice for most cases.

If there are too many files, you can use @RENAMER.bat to strip the .txt extension from all files, but I stress the following:

BATCH FILES CAN BE VERY DANGEROUS AND MAY RESULT IN DATA LOSS OR CORRUPTION, SYSTEM FAILURE AND EVEN POSSIBLE INJURY!
DO NOT USE FILES WITH THE .bat EXTENSION IF YOU ARE NOT AWARE OF THE RISKS THAT THEY MAY CARRY!

To use @RENAMER.bat, simply strip the .txt file extension of the file.
]]

if SERVER then
	
	local ConA = CreateConVar("trailmodifier_admin_only","1",FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE,"Sets whether only admins can use the trail modifier.\n - A server restart is required for changes to take effect.")
	local ConE = CreateConVar("trailmodifier_saving_enabled","1",FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE,"Enables or disables saving and loading.\n - Trail information is stored inside data/customtrailplayerdata.txt.")
	local ConW = CreateConVar("trailmodifier_max_width","128",FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE,"Sets the maximum width of all trails.")
	local ConL = CreateConVar("trailmodifier_max_lifetime","30",FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE,"Sets the maximum lifetime of all trails.")

	local function ScanForOptions(ply,trail)
		if not IsValid(ply) then return end
		if not ply:IsPlayer() then return end
		if not istable(ply.RemotelyAddedTrails) then ply.RemotelyAddedTrails = {} end
		if not istable(ply.RemotelyAddedTrails.CUSTOM_OPTIONS) then ply.RemotelyAddedTrails.CUSTOM_OPTIONS = {} end
		if not istable(ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL) then ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL = {color_white,true,16,0,4,0.07} end
		if #ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL ~= 6 then ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL = {color_white,true,16,0,4,0.07} end
		if not (istable(ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL[1])
			and isbool(ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL[2])
			and isnumber(ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL[3])
			and isnumber(ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL[4])
			and isnumber(ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL[5])
			and isnumber(ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL[6])
		)
		then ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL = {color_white,true,16,0,4,0.07} end
		ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL[3] = math.Clamp(ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL[3],0,ConW:GetFloat())
		ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL[4] = math.Clamp(ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL[4],0,ConW:GetFloat())
		ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL[5] = math.Clamp(ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL[5],0,ConL:GetFloat())
		if trail then
			if not istable(ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail]) then ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail] = ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL end
			if #ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail] ~= 6 then ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail] = ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL end
			if not (istable(ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail][1])
				and isbool(ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail][2])
				and isnumber(ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail][3])
				and isnumber(ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail][4])
				and isnumber(ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail][5])
				and isnumber(ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail][6])
			)
			then ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail] = ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL end
			ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail][3] = math.Clamp(ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail][3],0,ConW:GetFloat())
			ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail][4] = math.Clamp(ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail][4],0,ConW:GetFloat())
			ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail][5] = math.Clamp(ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail][5],0,ConL:GetFloat())
			return ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail]
		else
			return ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL
		end
	end
	
	concommand.Add("trailmodifier_create_vmts",function()
		if not file.IsDir("customtrailvmts","DATA") then
			file.CreateDir("customtrailvmts")
		end
		local vmts = file.Find("materials/trails/*.vmt","GAME")
		for k,v in pairs(vmts) do
			--local Ftext = file.Read("materials/trails/"..v,"GAME")
			if not file.Exists("materials/trails/"..v,"MOD") then--if string.find(Ftext,"Sprite") then
				file.Write("customtrailvmts/"..v..".txt",'"UnlitGeneric"\n{\n\t"$basetexture" "trails/'..string.StripExtension(v)..'"\n\t"$vertexalpha" 1\n\t"$vertexcolor" 1\n}')
			end--end
		end
		file.Write("customtrailvmts/@RENAMER.bat.txt",[[
		@echo off

		for %%A in (".\*.txt") do call :rename %%A
		pause
		exit

		:rename
		set name=%~n1
		rename .\%name%.txt %name%
		echo Renamed %name%.txt to %name%
		goto :eof
		]])
		file.Write("customtrailvmts/@README.txt",readmetext)
	end,nil,"Creates VMTs for all VTF trails.\n - Once executed, refer to @README.txt inside data/customtrailvmts for further details.",FCVAR_SERVER_CAN_EXECUTE)
	
	concommand.Add("trailmodifier_reset_prices",function(ply)
		local trailfiles2 = file.Find("materials/trails/*.vmt","GAME")
		local customTrails2 = {}
		for k,v in ipairs(trailfiles2) do
			customTrails2["trails/"..v] = 100
		end
		file.Write("customtrailoptions.txt",util.TableToJSON(customTrails2,true))
		ply:ChatPrint("All trails have been set to ".. 100 .." "..PS.Config.PointsName)
	end,nil," - Recreates data/customtrailoptions.txt.",FCVAR_SERVER_CAN_EXECUTE)
	
	hook.Add("PlayerInitialSpawn","GetCustomTrailData",function(ply)
		if file.Exists("customtrailplayerdata.txt","DATA") then
			local data = util.JSONToTable(file.Read("customtrailplayerdata.txt","DATA"))
			if data then
				local idToFind = game.SinglePlayer() and STEAM_ID_PENDING or ply:SteamID()
				if data[idToFind] then
					if not istable(ply.RemotelyAddedTrails) then ply.RemotelyAddedTrails = {} end
					for k,v in pairs(data[idToFind]) do
						if k == "CUSTOM_OPTIONS" then
							ply.RemotelyAddedTrails.CUSTOM_OPTIONS = v
						else
							local options = ScanForOptions(ply,k)
							local l1, l2, l3, l4, l5, l6 = unpack(options)
							if customTrails[k] then --server has trail, check ply
								if v then
									ply.RemotelyAddedTrails[k] = util.SpriteTrail(ply,0,l1,l2,l3,l4,l5,l6,k)
								else
									ply.RemotelyAddedTrails[k] = NULL
								end
							elseif not Material(k):IsError() then
								if v then
									ply.RemotelyAddedTrails[k] = util.SpriteTrail(ply,0,l1,l2,l3,l4,l5,l6,k)
								else
									ply.RemotelyAddedTrails[k] = NULL
								end
							end
						end
					end
				end
			end
		end
	end)
	
	net.Receive("OpenTrailMenu",function(length,ply)
		if IsValid(ply) and ply:IsPlayer() then -- ply sent it
			if ConA:GetBool() and not ply:IsAdmin() then return end
			local trail = net.ReadString()
			local operCash = net.ReadBool()
			if not trail then -- Probably just prodding
				net.Start("OpenTrailMenu")
					net.WriteBool(true)
					net.WriteTable(ply.RemotelyAddedTrails)
				net.Send(ply)
			return end
			if string.GetExtensionFromFilename(trail) ~= "vmt" and trail ~= "ALL" then return end
			--if not IsValid((Material(trail))) then return end
			if (Material(trail):IsError() or not customTrails[trail]) and trail ~= "ALL" then return end
			local optionsRead = ScanForOptions(ply,trail)
			local l1, l2, l3, l4, l5, l6 = unpack(optionsRead)
			if trail == "ALL" then
				local options = net.ReadTable() or {}
				if options.buy then
					local buyprice = 0
					for k,v in pairs(customTrails) do
						if not ply.RemotelyAddedTrails[k] then
							buyprice = buyprice + PS.Config.CalculateBuyPrice(ply, {Price=v or 100})
						end
					end
					if ply:PS_GetPoints() < buyprice then return end
					for k,v in pairs(customTrails) do
						if not ply.RemotelyAddedTrails[k] then
							ply.RemotelyAddedTrails[k] = util.SpriteTrail(ply,0,l1,l2,l3,l4,l5,l6,k)
						end
					end
					ply:PS_TakePoints(buyprice)
					ply:ChatPrint("Bought EVERYTHING!")
					net.Start("OpenTrailMenu")
						net.WriteBool(true)
						net.WriteTable(ply.RemotelyAddedTrails)
					net.Send(ply)
				elseif options.sell then
					local sellprice = 0
					for k,v in pairs(customTrails) do
						if ply.RemotelyAddedTrails[k] then
							sellprice = sellprice + PS.Config.CalculateSellPrice(ply, {Price=v or 100})
						end
					end
					for k,v in pairs(customTrails) do
						if IsValid(ply.RemotelyAddedTrails[k]) then
							ply.RemotelyAddedTrails[k]:Remove()
						end
						ply.RemotelyAddedTrails[k] = nil
					end
					ply:PS_GivePoints(sellprice)
					ply:ChatPrint("Sold EVERYTHING!")
					net.Start("OpenTrailMenu")
						net.WriteBool(true)
						net.WriteTable(ply.RemotelyAddedTrails)
					net.Send(ply)
				elseif options.equip then
					for k,v in pairs(customTrails) do
						if ply.RemotelyAddedTrails[k] == NULL then
							ply.RemotelyAddedTrails[k] = util.SpriteTrail(ply,0,l1,l2,l3,l4,l5,l6,k)
						end
					end
					ply:ChatPrint("Equipped EVERYTHING!")
					net.Start("OpenTrailMenu")
						net.WriteBool(true)
						net.WriteTable(ply.RemotelyAddedTrails)
					net.Send(ply)
				elseif options.holster then
					for k,v in pairs(customTrails) do
						if IsValid(ply.RemotelyAddedTrails[k]) then
							ply.RemotelyAddedTrails[k]:Remove()
						end
					end
					ply:ChatPrint("Holstered EVERYTHING!")
					net.Start("OpenTrailMenu")
						net.WriteBool(true)
						net.WriteTable(ply.RemotelyAddedTrails)
					net.Send(ply)
				elseif istable(options.modify) then
					if #options.modify == 6 then
						if not (istable(options.modify[1])
							and isbool(options.modify[2])
							and isnumber(options.modify[3])
							and isnumber(options.modify[4])
							and isnumber(options.modify[5])
							and isnumber(options.modify[6])
						)
						then return end
						local mods = options.modify
						ply.RemotelyAddedTrails.CUSTOM_OPTIONS = {}
						ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL = mods
						l1, l2, l3, l4, l5, l6 = unpack(ply.RemotelyAddedTrails.CUSTOM_OPTIONS.ALL)
						for k,v in pairs(customTrails) do
							if IsValid(ply.RemotelyAddedTrails[k]) then
								ply.RemotelyAddedTrails[k]:Remove()
								ply.RemotelyAddedTrails[k] = util.SpriteTrail(ply,0,l1,l2,l3,l4,l5,l6,k)
							end
						end
						ply:ChatPrint("Changes saved.")
						net.Start("OpenTrailMenu")
							net.WriteBool(true)
							net.WriteTable(ply.RemotelyAddedTrails)
						net.Send(ply)
					end
				elseif not operCash then
					if options.TO_COMBINE and ply:IsAdmin() then
						local trailers = file.Read("customtrailoptions.txt","DATA")
						if not isstring(trailers) then return end
						local tab = util.JSONToTable(trailers)
						if not istable(tab) then return end
						if tonumber(options.price) then
							for k,v in pairs(tab) do
								tab[k] = tonumber(options.price)
							end
							file.Write("customtrailoptions.txt",util.TableToJSON(tab,true))
							ReadFiles()
							ply:ChatPrint("All trails have been set to "..options.price.." "..PS.Config.PointsName)
							net.Start("OpenTrailMenu")
								net.WriteBool(true)
								net.WriteTable({READ_FILES = true})
							net.Send(ply)
						else
							ply:ChatPrint("\""..options.price.."\" is not a valid number!")			
						end
					end
				end
			elseif operCash then
				if ply.RemotelyAddedTrails[trail] then
					local sellprice = PS.Config.CalculateSellPrice(ply, {Price=customTrails[trail] or 100})
					ply:PS_GivePoints(sellprice)
					if IsValid(ply.RemotelyAddedTrails[trail]) then ply.RemotelyAddedTrails[trail]:Remove() end
					ply.RemotelyAddedTrails[trail] = nil
					ply:ChatPrint("Sold trail \""..trail.."\" for "..sellprice.." "..PS.Config.PointsName)
					net.Start("OpenTrailMenu")
						net.WriteBool(true)
						net.WriteTable(ply.RemotelyAddedTrails)
					net.Send(ply)
				else
					local buyprice = PS.Config.CalculateBuyPrice(ply, {Price=customTrails[trail] or 100})
					if ply:PS_GetPoints() < buyprice then return end
					ply.RemotelyAddedTrails[trail] = util.SpriteTrail(ply,0,l1,l2,l3,l4,l5,l6,trail)
					ply:PS_TakePoints(buyprice)
					ply:ChatPrint("Bought trail \""..trail.."\" for "..buyprice.." "..PS.Config.PointsName)
					net.Start("OpenTrailMenu")
						net.WriteBool(true)
						net.WriteTable(ply.RemotelyAddedTrails)
					net.Send(ply)
				end
			else
				local options = net.ReadTable() or {}
				--print(trail)
				--PrintTable(options)
				if options.TO_COMBINE and ply:IsAdmin() then
					local trailers = file.Read("customtrailoptions.txt","DATA")
					if not isstring(trailers) then return end
					local tab = util.JSONToTable(trailers)
					if not istable(tab) then return end
					if tab[trail] and tonumber(options.price) then
						tab[trail] = tonumber(options.price)
						file.Write("customtrailoptions.txt",util.TableToJSON(tab,true))
						ReadFiles()
						ply:ChatPrint("Trail \""..trail.."\" has been set to "..options.price.." "..PS.Config.PointsName)
						net.Start("OpenTrailMenu")
							net.WriteBool(true)
							net.WriteTable({READ_FILES = true})
						net.Send(ply)
					elseif tab[trail] then
						ply:ChatPrint("\""..options.price.."\" is not a valid number!")
					else					
						ply:ChatPrint("Trail \""..trail.."\" is invalid!")
					end
				elseif #options == 6 then
					if not (istable(options[1])
						and isbool(options[2])
						and isnumber(options[3])
						and isnumber(options[4])
						and isnumber(options[5])
						and isnumber(options[6])
					)
					then return end
					ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail] = options
					l1, l2, l3, l4, l5, l6 = unpack(ply.RemotelyAddedTrails.CUSTOM_OPTIONS[trail])
					if IsValid(ply.RemotelyAddedTrails[trail]) then
						ply.RemotelyAddedTrails[trail]:Remove()
						ply.RemotelyAddedTrails[trail] = util.SpriteTrail(ply,0,l1,l2,l3,l4,l5,l6,trail)
					end
					ply:ChatPrint("Changes saved.")
					net.Start("OpenTrailMenu")
						net.WriteBool(true)
						net.WriteTable(ply.RemotelyAddedTrails)
					net.Send(ply)
				elseif IsValid(ply.RemotelyAddedTrails[trail]) then
					ply.RemotelyAddedTrails[trail]:Remove()
					ply:ChatPrint("Holstered trail \""..trail.."\".")
					net.Start("OpenTrailMenu")
						net.WriteBool(true)
						net.WriteTable(ply.RemotelyAddedTrails)
					net.Send(ply)
				elseif ply.RemotelyAddedTrails[trail] ~= nil then
					ply.RemotelyAddedTrails[trail] = util.SpriteTrail(ply,0,l1,l2,l3,l4,l5,l6,trail)
					ply:ChatPrint("Equipped trail \""..trail.."\".")
					net.Start("OpenTrailMenu")
						net.WriteBool(true)
						net.WriteTable(ply.RemotelyAddedTrails)
					net.Send(ply)
				end
			end
			if ConE:GetBool() then
				timer.Simple(FrameTime()*5, function()
					local toWriteTable = {}
					local id = ply:SteamID()
					toWriteTable[id] = {}
					for k,v in pairs(ply.RemotelyAddedTrails) do
						if isentity(v) then
							if IsValid(v) then
								toWriteTable[id][k] = true
							else --NULL entity
								toWriteTable[id][k] = false
							end
						elseif k == "CUSTOM_OPTIONS" then
							toWriteTable[id]["CUSTOM_OPTIONS"] = v
						end
					end
					local toWriteString = util.TableToJSON(toWriteTable,true)
					file.Write("customtrailplayerdata.txt",toWriteString)
				end)
			end
		end
	end)
end