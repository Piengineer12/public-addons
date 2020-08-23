AddCSLuaFile()

ENT.Model 			= "models/props_wasteland/gaspump001a.mdl"
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Shop"
ENT.Author			= "Piengineer"
ENT.Contact			= "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose			= "A shop to sell things."
ENT.Instructions	= "Press 'Use' to open up the menu."
ENT.Category		= "Pointshop"
ENT.Spawnable		= true
ENT.AdminOnly		= true

if SERVER then
	util.AddNetworkString("OpenShopMenu")
	util.AddNetworkString("OpenBuyMenu")
	util.AddNetworkString("ShopUpdate")
	util.AddNetworkString("ShopBuy")
	util.AddNetworkString("ShopBuyModify")
	util.AddNetworkString("RevalidModel")
	--resource.AddFile("materials/vgui/entities/ps_shop.vmt")
		-- The above just wastes space at this point.
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
	self:NetworkVar("String",0,"ShopItemName")
	self:NetworkVar("Int",0,"ShopItemPrice")
	self:NetworkVar("Bool",0,"Locked")
	self:NetworkVar("String",1,"ShopModel")
end

function ENT:Initialize()
	if self:GetShopModel() ~= nil and util.IsValidModel(self:GetShopModel()) then
		self:SetModel( self:GetShopModel() )
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
	if IsValid(ply) and ply:IsPlayer() then
		if PS == nil then net.Start("VerifyPointshop",true); net.Send(ply); return end
		if not self:GetLocked() and ply:IsAdmin() then
			net.Start("OpenShopMenu",true)
			net.WriteEntity(self)
			net.Send(ply)
		elseif self:GetLocked() then
			net.Start("OpenBuyMenu",true)
			net.WriteEntity(self)
			net.WriteString(self:GetShopItemName())
			net.WriteInt(self:GetShopItemPrice(),32)
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
local inputname = ""
local inputprice = 0
local modelname = ""

net.Receive("OpenShopMenu", function()
	if not CLIENT then return end
	local shop = net.ReadEntity()
	if not IsValid(shop) then notification.AddLegacy( "Shop is nonexistent!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
	local Main = vgui.Create("DFrame")
	Main:SetSize( panelx, panely )
	Main:Center()
	Main:SetTitle( "Edit Shop" )
	Main:SetVisible( true )
	Main:SetDraggable( true )
	Main:ShowCloseButton( true )
	Main:MakePopup()
	
	Main.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
		local points = LocalPlayer():PS_GetPoints() ~= nil and LocalPlayer():PS_GetPoints() or 0
		draw.RoundedBox( 4, 0, 0, w, h, Color( 127, 0, 0, 255 ) ) -- Draw a box instead of the frame
		if Main:IsActive() then draw.RoundedBox( 4, 0, 0, w, 24, Color( 191, 0, 0, 255 ) ) end
		draw.SimpleText("Item ClassName","PS_ButtonText1",w/2,60,Color(255,255,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
		draw.SimpleText("Item Price","PS_ButtonText1",w/2,120,Color(0,255,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
		draw.SimpleText("Shop Model","PS_ButtonText1",w/2,180,Color(0,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
		if PS.Items[inputname] ~= nil then draw.SimpleText("Item: "..PS.Items[inputname].Name..". Original Price: "..PS.Items[inputname].Price.." "..PS.Config.PointsName,
		"DermaDefault",w/2,80,Color(0,255,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP) end
	end
	
	--ItemName validation indicator.
	local ItemCheck = vgui.Create( "DImage",Main)
	ItemCheck:SetPos(panelx/2+funclen/2+2,60+2)
	ItemCheck:SetSize(16,16)
	
	--ItemName entry.
	local ItemName = vgui.Create( "DTextEntry",Main)
	ItemName:SetPos(-1,60)
	ItemName:SetSize(funclen, 20)
	ItemName:CenterHorizontal()
	ItemName:SetText(inputname)
	ItemCheck:SetImage(PS.Items[inputname] and "icon16/tick.png" or "icon16/cross.png")
	ItemName.OnChange = function(self)
		inputname = self:GetValue()
		ItemCheck:SetImage(PS.Items[inputname] and "icon16/tick.png" or "icon16/cross.png")
	end
	
	--ItemName browser button.
	local ItemBrowserStart = vgui.Create( "DButton",Main)
	ItemBrowserStart:SetText("Browse...")
	ItemBrowserStart:SetPos(panelx/2+funclen/2+20,60)
	ItemBrowserStart:SetSize(80, 20)
	ItemBrowserStart.DoClick = function()
		
		-- ItemBrowser window.
		local ItemBrowser = vgui.Create( "DFrame" )
		ItemBrowser:SetSize( panelx, panely )
		ItemBrowser:Center()
		ItemBrowser:MakePopup()
		ItemBrowser:SetTitle( "Item Browser" )
		ItemBrowser.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 127, 127, 255 ) )
			if ItemBrowser:IsActive() then draw.RoundedBox( 4, 0, 0, w, 24, Color( 0, 191, 191, 255 ) ) end
		end

		local ItemBrowserGUI = vgui.Create( "DFileBrowser", ItemBrowser )
		ItemBrowserGUI:Dock( FILL )
		ItemBrowserGUI:SetPath( "LUA" )
		ItemBrowserGUI:SetBaseFolder( "pointshop/items" )
		ItemBrowserGUI:SetOpen( true )
		
		function ItemBrowserGUI:OnSelect(path,panel)
			local matched = string.match(path,"%/.*%/.*%/(.*)%.lua") -- This line took about ONE HOUR to make. Why are patterns so hard to understand?
			if matched ~= "__category" then
				ItemCheck:SetImage(PS.Items[matched] and "icon16/tick.png" or "icon16/cross.png")
				ItemName:SetText(matched)
				inputname = matched
			end
		end
		
		function ItemBrowserGUI:OnDoubleClick( path, panel )
			ItemBrowser:Close()
		end
		
		function Main:OnClose()
			if IsValid(ItemBrowser) then
				ItemBrowser:Close()
			end
		end
	
	end
	
	--ItemPrice validation indicator.
	local ItemTick = vgui.Create( "DImage",Main)
	ItemTick:SetPos(panelx/2+funclen/2+2,120+2)
	ItemTick:SetSize(16,16)
	
	--ItemPrice entry.
	local ItemPrice = vgui.Create( "DTextEntry",Main)
	ItemPrice:SetPos(-1,120)
	ItemPrice:SetSize(funclen, 20)
	ItemPrice:CenterHorizontal()
	ItemPrice:SetText(inputprice ~= 0 and inputprice or "")
	ItemPrice:SetNumeric(true)
	ItemTick:SetImage(inputprice >= 0 and "icon16/tick.png" or "icon16/cross.png")
	ItemPrice.OnChange = function(self)
		inputprice = tonumber(self:GetValue()) or 0
		ItemTick:SetImage(inputprice >= 0 and "icon16/tick.png" or "icon16/cross.png")
	end
	
	--Model validation indicator.
	local ModelCheck = vgui.Create( "DImage",Main)
	ModelCheck:SetPos(panelx/2+funclen/2+2,180+2)
	ModelCheck:SetSize(16,16)
	
	--Model entry.
	local ModelName = vgui.Create( "DTextEntry",Main)
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
		if PS.Items[inputname] == nil then notification.AddLegacy( "Invalid item!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
		if modelname == "" then modelname = shop:GetModel() end
		if not util.IsValidModel(modelname) then notification.AddLegacy( "Invalid model! Leave blank for default model.", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
		if inputprice < 0 then notification.AddLegacy( "Price can't be negative!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
		inputprice = math.min(inputprice,2147483647)
		if not IsValid(shop) then notification.AddLegacy( "Shop is nonexistent!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); Main:Remove(); return end
		net.Start("ShopUpdate",true)
			net.WriteEntity(shop)
			net.WriteString(inputname)
			net.WriteInt(inputprice,32)
			net.WriteString(modelname)
		net.SendToServer()
		Main:Close()
	end
end)

net.Receive("OpenBuyMenu", function()
	if not CLIENT then return end
	local shop = net.ReadEntity()
	if not IsValid(shop) then notification.AddLegacy( "Shop is nonexistent!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
	local item = net.ReadString()
	local name = PS.Items[item].Name
	local price = net.ReadInt(32)
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
		if not IsValid(shop) then notification.AddLegacy( "Shop is nonexistent!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); Main:Remove(); return end
		if price > LocalPlayer():PS_GetPoints() then notification.AddLegacy( "Not enough "..PS.Config.PointsName.."!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
		net.Start("ShopBuy",true)
			net.WriteEntity(shop)
		net.SendToServer()
		Main:Close()
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
			net.Start("ShopBuyModify",true)
				net.WriteEntity(shop)
			net.SendToServer()
			Main:Close()
		end
	
		if IsValid(LocalPlayer().PBSIE) then
			--Interfacer connect button.
			local StartCon = vgui.Create( "DButton",Main)
			StartCon:SetText("Connect...")
			StartCon:SetTextColor(Color(0,0,255,255))
			StartCon:SetPos(panelx/2-funclen/2-90,panely-90)
			StartCon:SetSize(60, 60)
			StartCon.DoClick = function()
				net.Start("InterUpdate")
				net.WriteInt(LocalPlayer().PBSI,8)
				net.WriteEntity(LocalPlayer().PBSIE)
				net.WriteEntity(shop)
				net.SendToServer()
				LocalPlayer().PBSI = nil
				LocalPlayer().PBSIE = nil
				chat.AddText(Color(0,255,0),"[PSBanks] ",Color(0,127,255),"Shop Connected!")
				StartCon:Remove()
			end
		end
	end
end)

-- Server UI

net.Receive("ShopUpdate", function(bits,sender)
	if not sender:IsPlayer() or not SERVER then return end
	local target = net.ReadEntity()
	if not IsValid(target) or not sender:IsAdmin() then return end --It *might* have been deleted after the player sent it idk
	local name = net.ReadString()
	if PS.Items[name] == nil then return end
	local price = net.ReadInt(32)
	if price == nil or price < 0 then return end
	local model = net.ReadString()
	if not util.IsValidModel(model) then return end
	target:SetShopItemName(name)
	target:SetShopItemPrice(price)
	target:SetLocked(true)
	if model ~= target:GetModel() then
		target:SetModel(model)
		target:SetShopModel(model)
		target:PhysicsInit( SOLID_VPHYSICS )
		local phys = target:GetPhysicsObject()
		if ( IsValid( phys ) ) then phys:Wake() end
	end
end)

net.Receive("ShopBuy", function(bits,sender)
	if not sender:IsPlayer() or not SERVER then return end
	local target = net.ReadEntity()
	if not IsValid(target) then return end --It *might* have been deleted after the player sent it idk
	if sender:PS_GetPoints() >= target:GetShopItemPrice() then
		sender:PS_TakePoints(target:GetShopItemPrice())
		PS.Items[target:GetShopItemName()]:OnBuy(sender)
		sender:ChatPrint("Bought "..PS.Items[target:GetShopItemName()].Name..".")
		if PS.Items[target:GetShopItemName()].SingleUse then return end
		sender:PS_GiveItem(target:GetShopItemName())
		sender:PS_EquipItem(target:GetShopItemName())
	end
end)

net.Receive("ShopBuyModify", function(bits,sender)
	if not sender:IsPlayer() or not SERVER then return end
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
end)

net.Receive("RevalidModel", function(bits,sender)
	if not sender:IsPlayer() or not SERVER then return end
	local target = net.ReadString()
	util.IsValidModel(Model(target)) -- This apparently tells the client it's there. So, don't do anything.
end)