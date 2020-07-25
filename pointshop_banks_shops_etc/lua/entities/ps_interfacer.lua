AddCSLuaFile()

ENT.Model 			= "models/props_wasteland/gaspump001a.mdl"
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Interfacer"
ENT.Author			= "RandomTNT"
ENT.Contact			= "http://steamcommunity.com/id/RandomTNT12/"
ENT.Purpose			= "Something to connect several shops at once."
ENT.Instructions	= "Press 'Use' to open up the menu."
ENT.Category		= "Pointshop"
ENT.Spawnable		= true
ENT.AdminOnly		= true

if SERVER then
	util.AddNetworkString("OpenInterMenu")
	util.AddNetworkString("OpenInterBuyMenu")
	util.AddNetworkString("InterUpdate")
end

function ENT:SpawnFunction( ply, tr, class )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 30
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 90

	local ent = ents.Create( class )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:SetupDataTables()
	for i=0,31 do
		self:NetworkVar("Entity",i,"InterfaceShop"..i)
	end
	self:NetworkVar("Bool",0,"Locked")
	self:NetworkVar("String",1,"InterfaceModel")
end

function ENT:Initialize()
	if self:GetInterfaceModel() ~= nil and util.IsValidModel(self:GetInterfaceModel()) then
		self:SetModel( self:GetInterfaceModel() )
	else
		self:SetModel( self.Model )
	end
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	if SERVER then self:PhysicsInit( SOLID_VPHYSICS ) end

	-- Make prop to fall on spawn
	local phys = self:GetPhysicsObject()
	if ( IsValid( phys ) ) then phys:Wake() end
	if SERVER then self:SetUseType(SIMPLE_USE) end
end

function ENT:Use(activator, ply)
	if self.ITIDS then
		for k,v in pairs(ents.FindByClass("ps_shop")) do
			for i,v2 in pairs(self.ITIDS) do
				if v.ITIDS and v.ITIDS==v2 then
					self["SetInterfaceShop"..i](self,v)
				end
			end
		end
	end
	if IsValid(ply) and ply:IsPlayer() then
		if PS == nil then net.Start("VerifyPointshop",true); net.Send(ply); return end
		if not self:GetLocked() and ply:IsAdmin() then
			net.Start("OpenInterMenu",true)
			net.WriteEntity(self)
			net.Send(ply)
		elseif self:GetLocked() then
			net.Start("OpenInterBuyMenu",true)
			net.WriteEntity(self)
			net.Send(ply)
		end
	end
end

function ENT:Draw()
	self.Entity:DrawModel()
end

-- Client UI

local panelx = 400
local panely = 300
local funclen = 150
local inputentity
local inputindex = 0
local modelname = ""

net.Receive("OpenInterMenu", function()
	if not CLIENT then return end
	local interfacer = net.ReadEntity()
	if not IsValid(interfacer) then notification.AddLegacy( "Interfacer is nonexistent!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
	local Main = vgui.Create("DFrame")
	Main:SetSize( panelx, panely )
	Main:Center()
	Main:SetTitle( "Edit Interfacer" )
	Main:SetVisible( true )
	Main:SetDraggable( true )
	Main:ShowCloseButton( true )
	Main:MakePopup()
	
	Main.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
		draw.RoundedBox( 4, 0, 0, w, h, Color( 127, 0, 127, 255 ) ) -- Draw a box instead of the frame
		if Main:IsActive() then draw.RoundedBox( 4, 0, 0, w, 24, Color( 191, 0, 191, 255 ) ) end
		draw.SimpleText("Shop Connections","PS_ButtonText1",w/2,60,Color(255,255,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
		draw.SimpleText("Slot","PS_ButtonText1",w/2-funclen/2-60,60,Color(0,255,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
		draw.SimpleText("Interfacer Model","PS_ButtonText1",w/2,180,Color(0,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
		if IsValid(inputentity) then draw.SimpleText(tostring(inputentity)..(inputentity:GetLocked() and (" Item: "..PS.Items[inputentity:GetShopItemName()].Name..". Price: "..inputentity:GetShopItemPrice().." "..PS.Config.PointsName) or " ...?"),
		"DermaDefault",w/2,80,Color(0,255,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP) end
	end
	
	--ItemName validation indicator.
	local EntityCheck = vgui.Create("DImage",Main)
	EntityCheck:SetPos(panelx/2+funclen/2+2,60+2)
	EntityCheck:SetSize(16,16)
	
	--ItemName set button.
	local EntityButton = vgui.Create("DButton",Main)
	EntityButton:SetPos(panelx/2-funclen/2,60)
	EntityButton:SetSize(funclen,20)
	EntityButton.DoCheck = function(self)
		EntityCheck:SetImage(IsValid(inputentity) and (inputentity:GetLocked() and "icon16/tick.png" or "icon16/error.png") or "icon16/cross.png")
		self:SetText(IsValid(inputentity) and "Disconnect" or LocalPlayer().PBSI == inputindex and "Cancel Connection" or "Start Connection")
	end
	EntityButton.DoClick = function(self)
		if IsValid(inputentity) or LocalPlayer().PBSIE == interfacer then -- disconnect
			if IsValid(inputentity) then
				net.Start("InterUpdate")
				net.WriteInt(inputindex+32,8)
				net.WriteEntity(interfacer)
				net.SendToServer()
				inputentity = NULL
				chat.AddText(Color(0,255,0),"[PSBanks] ",Color(0,127,255),"Shop Disconnected!")
			else
				chat.AddText(Color(0,255,0),"[PSBanks] ",Color(0,127,255),"Connection canceled.")
			end
			LocalPlayer().PBSI = nil
			LocalPlayer().PBSIE = nil
			self:DoCheck()
		else -- start connection
			LocalPlayer().PBSI = inputindex
			LocalPlayer().PBSIE = interfacer
			self:DoCheck()
			chat.AddText(Color(0,255,0),"[PSBanks] ",Color(0,127,255),"Connection started. Interact with a prepared Shop to complete the connection.")
		end
	end
	
	--EntIndex number wan.
	local CurIndex = vgui.Create("DNumberWang",Main)
	CurIndex:SetPos(panelx/2-funclen/2-100,60)
	CurIndex:SetSize(80,20)
	CurIndex:SetMinMax(0,31)
	CurIndex.OnValueChanged = function(self)
		inputindex = math.Clamp(self:GetValue(),0,31)
		inputentity = interfacer["GetInterfaceShop"..inputindex](interfacer)
		EntityButton:DoCheck()
	end
	CurIndex:SetValue(inputindex)
	
	--Model validation indicator.
	local ModelCheck = vgui.Create("DImage",Main)
	ModelCheck:SetPos(panelx/2+funclen/2+2,180+2)
	ModelCheck:SetSize(16,16)
	
	--Model entry.
	local ModelName = vgui.Create("DTextEntry",Main)
	ModelName:SetPos(-1,180)
	ModelName:SetSize(funclen, 20)
	ModelName:CenterHorizontal()
	ModelName:SetText(modelname)
	if util.IsValidModel(modelname) or modelname == "" then
		ModelCheck:SetImage("icon16/tick.png")
	else
		ModelCheck:SetImage("icon16/cross.png")
	end
	ModelName.OnChange = function(self)
		modelname = self:GetValue()
		if util.IsValidModel(modelname) or modelname == "" then
			ModelCheck:SetImage("icon16/tick.png")
		else
			ModelCheck:SetImage("icon16/cross.png")
		end
	end
	
	--Model revalidation button.
	local ModelRecheck = vgui.Create( "DButton",Main)
	ModelRecheck:SetText("Verify Model")
	ModelRecheck:SetPos(panelx/2+funclen/2+20,180)
	ModelRecheck:SetSize(80, 20)
	ModelRecheck.DoClick = function()
		net.Start("RevalidModel",true)
			net.WriteString(modelname)
		net.SendToServer()
		timer.Simple(RealFrameTime(),function()
			if IsValid(ModelCheck) then
				if util.IsValidModel(modelname) or modelname == "" then
					ModelCheck:SetImage("icon16/tick.png")
				else
					ModelCheck:SetImage("icon16/cross.png")
				end
			end
		end)
	end
	
	--Set button.
	local ItemSet = vgui.Create( "DButton", Main )
	ItemSet:SetText( "Save" )
	ItemSet:SetPos(panelx/2-funclen/2,220)
	ItemSet:SetSize(funclen, 60)
	ItemSet.DoClick = function()
		if modelname == "" then modelname = interfacer:GetModel() end
		if not util.IsValidModel(modelname) then notification.AddLegacy( "Invalid model! Leave blank for default model.", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
		if not IsValid(interfacer) then notification.AddLegacy( "Interfacer is nonexistent!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); Main:Remove(); return end
		net.Start("InterUpdate",true)
			net.WriteInt(-2,8)
			net.WriteEntity(interfacer)
			net.WriteString(modelname)
		net.SendToServer()
		Main:Close()
	end
end)

net.Receive("OpenInterBuyMenu", function(length,sender)
	if CLIENT then
		local shop = net.ReadEntity()
		if not IsValid(shop) then notification.AddLegacy( "Interfacer is nonexistent!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
		local OfferedItems = {}
		for i=0,31 do
			local sht = shop["GetInterfaceShop"..i](shop)
			if (IsValid(sht) and sht:GetLocked()) then
				table.insert(OfferedItems,sht)
			end
		end
		local index = 1
		local UpdIndex -- error prevention
		UpdIndex = function(num)
			index = math.Clamp(index + num,1,math.max(#OfferedItems,1))
			if not IsValid(OfferedItems[index]) and index ~= 1 then
				OfferedItems = {}
				for i=0,31 do
					local sht = shop["GetInterfaceShop"..i](shop)
					if (IsValid(sht) and sht:GetLocked()) then
						table.insert(OfferedItems,sht)
					end
				end
				UpdIndex(0)
			end
			item = IsValid(OfferedItems[1]) and OfferedItems[index]:GetShopItemName() or "<null>"
			name = PS.Items[item] and PS.Items[item].Name or "<null>"
			price = IsValid(OfferedItems[1]) and OfferedItems[index]:GetShopItemPrice() or "<null>"
		end
		UpdIndex(0)
		local Main = vgui.Create("DFrame")
		Main:SetSize( panelx, panely )
		Main:Center()
		Main:SetTitle( "Shop" )
		Main:SetVisible( true )
		Main:SetDraggable( true )
		Main:ShowCloseButton( true )
		Main:MakePopup()
		Main.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
			local points = LocalPlayer():PS_GetPoints() ~= nil and LocalPlayer():PS_GetPoints() or 0
			draw.RoundedBox( 4, 0, 0, w, h, Color( 127, 0, 0, 255 ) ) -- Draw a box instead of the frame
			draw.RoundedBox( 4, 0, 0, w, 24, Color( 191, 0, 0, 255 ) )
			draw.SimpleText("This shop is selling","PS_ButtonText1",w/2,panely/2-60,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
			draw.SimpleText(name,"PS_ButtonText1",w/2,panely/2-40,Color(0,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
			draw.SimpleText("for","PS_ButtonText1",w/2,panely/2-20,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
			draw.SimpleText(price.." "..PS.Config.PointsName,"PS_ButtonText1",w/2,panely/2,Color(0,255,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
			draw.SimpleText("You have "..points.." "..PS.Config.PointsName,"PS_ButtonText1",w/2,panely/2+40,Color(255,255,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
		end
		
		--Buy/sell button.
		local ItemSet = vgui.Create( "DButton", Main )
		ItemSet:SetText( "Buy!" )
		ItemSet:SetPos(panelx/2-funclen/2,panely-90)
		ItemSet:SetSize(funclen, 60)
		ItemSet.DoClick = function()
			if LocalPlayer():PS_HasItem(item) then notification.AddLegacy( "You already have this!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
			if not IsValid(OfferedItems[index]) then notification.AddLegacy( "Shop is nonexistent!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); Main:Remove(); return end
			if price > LocalPlayer():PS_GetPoints() then notification.AddLegacy( "Not enough "..PS.Config.PointsName.."!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
			net.Start("ShopBuy",true)
				net.WriteEntity(OfferedItems[index])
			net.SendToServer()
		end
		
		local ScrollL,ScrollR
		--Left button.
		ScrollL = vgui.Create("DImageButton",Main)
		ScrollL:SetImage("icon16/control_start.png")
		ScrollL:SetSize(32,32)
		ScrollL:SetPos(30,panely/2-16)
		if index <= 1 then
			ScrollL:Hide()
		end
		ScrollL.DoClick = function(self)
			UpdIndex(-1)
			if index <= 1 then
				ScrollL:Hide()
			else
				ScrollL:Show()
			end
			if index >= math.max(#OfferedItems,1) then
				ScrollR:Hide()
			else
				ScrollR:Show()
			end
		end
		ScrollL.RegisterHover = false
		ScrollL.Think = function(self)
			if self:IsHovered() and not ScrollL.RegisterHover then
				ScrollL:SetImage("icon16/control_start_blue.png")
				ScrollL.RegisterHover = true
			elseif not self:IsHovered() and ScrollL.RegisterHover then
				ScrollL:SetImage("icon16/control_start.png")
				ScrollL.RegisterHover = false
			end
		end
		
		--Right button.
		ScrollR = vgui.Create("DImageButton",Main)
		ScrollR:SetImage("icon16/control_end.png")
		ScrollR:SetSize(32,32)
		ScrollR:SetPos(panelx-62,panely/2-16)
		if index >= math.max(#OfferedItems,1) then
			ScrollR:Hide()
		end
		ScrollR.DoClick = function(self)
			UpdIndex(1)
			if index <= 1 then
				ScrollL:Hide()
			else
				ScrollL:Show()
			end
			if index >= math.max(#OfferedItems,1) then
				ScrollR:Hide()
			else
				ScrollR:Show()
			end
		end
		ScrollR.RegisterHover = false
		ScrollR.Think = function(self)
			if self:IsHovered() and not ScrollR.RegisterHover then
				ScrollR:SetImage("icon16/control_end_blue.png")
				ScrollR.RegisterHover = true
			elseif not self:IsHovered() and ScrollR.RegisterHover then
				ScrollR:SetImage("icon16/control_end.png")
				ScrollR.RegisterHover = false
			end
		end
		
		--Unlock button.
		if LocalPlayer():IsAdmin() then
			local ItemSet = vgui.Create( "DButton", Main )
			ItemSet:SetText( "Reset" )
			ItemSet:SetTextColor(Color(255,0,0,255))
			ItemSet:SetPos(panelx/2+funclen/2+30,panely-90)
			ItemSet:SetSize(60, 60)
			ItemSet.DoClick = function()
				if not IsValid(shop) then notification.AddLegacy( "Shop is nonexistent!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); Main:Remove(); return end
				net.Start("OpenInterBuyMenu",true)
					net.WriteEntity(shop)
				net.SendToServer()
				Main:Close()
			end
		end
	else -- server
		local target = net.ReadEntity()
		if not IsValid(target) then return end
		if sender:IsAdmin() and target:GetLocked() then
			target:SetLocked(false)
			if target.Model ~= target:GetModel() then
				target:SetModel(target.Model)
				target:PhysicsInit( SOLID_VPHYSICS )
				local phys = target:GetPhysicsObject()
				if ( IsValid( phys ) ) then phys:Wake() end
			end
		end
	end
end)

-- Server UI
local GenerateUID
GenerateUID = function(connector)
	connector.ITIDS = math.random(-2147483648,2147483647)
	for k,v in pairs(ents.FindByClass"ps_shop") do
		if v~=connector and v.ITIDS==connector.ITIDS then
			GenerateUID(connector)
		end
	end
end

net.Receive("InterUpdate", function(bits,sender)
	if not sender:IsPlayer() or not SERVER then return end
	local index = net.ReadInt(8)
	local target = net.ReadEntity()
	if not IsValid(target) or not sender:IsAdmin() then return end --It *might* have been deleted after the player sent it idk
	local model = target:GetModel()
	if index == -2 then
		model = net.ReadString()
		if not util.IsValidModel(model) then return end
		target:SetLocked(true)
	elseif index >= 32 then
		index = index - 32
		target["SetInterfaceShop"..index](target,NULL)
		target.ITIDS = target.ITIDS or {}
		target.ITIDS[index] = nil
	else
		local connector = net.ReadEntity()
		if not connector.ITIDS then
			GenerateUID(connector)
		end
		target["SetInterfaceShop"..index](target,connector)
		target.ITIDS = target.ITIDS or {}
		target.ITIDS[index] = connector.ITIDS
	end
	if model ~= target:GetModel() then
		target:SetModel(model)
		target:SetInterfaceModel(model)
		target:PhysicsInit( SOLID_VPHYSICS )
		local phys = target:GetPhysicsObject()
		if ( IsValid( phys ) ) then phys:Wake() end
	end
end)