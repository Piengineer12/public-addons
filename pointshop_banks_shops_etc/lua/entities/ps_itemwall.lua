AddCSLuaFile()

ENT.Model 			= "models/props_building_details/Storefront_Template001a_Bars.mdl"
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Item Gate"
ENT.Author			= "RandomTNT"
ENT.Contact			= "http://steamcommunity.com/id/RandomTNT12/"
ENT.Purpose			= "A wall that only allows players with certain items to pass."
ENT.Instructions	= "Press 'Use' to open up the menu."
ENT.Category		= "Pointshop"
ENT.Spawnable		= true
ENT.AdminOnly		= true

if SERVER then
	util.AddNetworkString("ItemGateModify")
	util.AddNetworkString("GateUpdate")
	--resource.AddFile("materials/vgui/entities/ps_itemwall.vmt")
		-- The above just wastes space at this point.
end

function ENT:SpawnFunction( ply, tr, class )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 80
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
	self:NetworkVar("String",1,"ShopModel")
	self:NetworkVar("Bool",0,"UsesCash")
	self:NetworkVar("Bool",1,"OnlyOnce")
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

	local phys = self:GetPhysicsObject()
	if ( IsValid( phys ) ) then phys:Wake() end

	if SERVER then self:SetTrigger(true) end
	if SERVER then self:SetUseType(SIMPLE_USE) end
end

function ENT:Use(activator, ply)
	if IsValid(ply) and ply:IsPlayer() then
		if PS == nil then net.Start("VerifyPointshop",true); net.Send(ply); return end
		if ply:IsAdmin() then
			net.Start("ItemGateModify",true)
			net.WriteEntity(self)
			net.Send(ply)
		end
	end
end

function ENT:StartTouch(ply)
	if ply:IsPlayer() then
		if PS == nil then
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			self.NextOpaque = CurTime() + 10
		elseif not self:GetUsesCash() and (ply:PS_HasItemEquipped(self:GetShopItemName()) or PS.Items[self:GetShopItemName()] == nil) then
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			self.NextOpaque = CurTime() + 10
		--[[elseif ply.Cooldown ~= nil then
			if ply.Cooldown <= CurTime() or ply.Cooldown > CurTime() + 1 then
			ply.Cooldown = nil
			end]]
		elseif self:GetUsesCash() and not tonumber(self:GetShopItemName()) then
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			self.NextOpaque = CurTime() + 10
		elseif self:GetUsesCash() and tonumber(self:GetShopItemName()) <= ply:PS_GetPoints() then
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			self.NextOpaque = CurTime() + 10
		elseif self:GetUsesCash() and tonumber(self:GetShopItemName()) > ply:PS_GetPoints() then
			ply:ChatPrint("You require at least "..self:GetShopItemName().." "..PS.Config.PointsName.." to pass!")
		elseif PS.Items[self:GetShopItemName()] ~= nil then --and ply.Cooldown == nil
			ply:ChatPrint("You require a "..PS.Items[self:GetShopItemName()].Name.." to pass!")
			--ply.Cooldown = CurTime() + 1
		end
	else
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
	end
end

function ENT:EndTouch(ply)
	if ply:IsPlayer() then
		if self:GetOnlyOnce() and self.NextOpaque then
			if self:GetUsesCash() then
				ply:PS_TakePoints(tonumber(self:GetShopItemName()))
				ply:ChatPrint("You were deducted "..self:GetShopItemName().." "..PS.Config.PointsName.."!")
			else
				local curItem = PS.Items[self:GetShopItemName()]
				if curItem then
					curItem:OnHolster(ply)
					curItem:OnSell(ply)
					ply:PS_TakeItem(curItem.ID)
					ply:ChatPrint("You lost your "..PS.Items[self:GetShopItemName()].Name.."!")
				end
			end
		end
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self.NextOpaque = nil
	end
end

function ENT:Think()
	if self.NextOpaque then
		if CurTime() > self.NextOpaque then
			self:SetCollisionGroup(COLLISION_GROUP_NONE)
			self.NextOpaque = nil
		end
	end
end

-- Client UI

local panelx = 400
local panely = 300
local funclen = 150
local itemname = ""
local modelname = ""
local usescash = false
local removeafteruse = false

function ENT:Draw()
	self:DrawModel()
end

net.Receive("ItemGateModify", function()
	if not CLIENT then return end
	if not LocalPlayer():IsAdmin() then return end
	local gate = net.ReadEntity()
	if not IsValid(gate) then notification.AddLegacy( "Gate is nonexistent!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
	local Main = vgui.Create("DFrame")
	Main:SetSize( panelx, panely )
	Main:Center()
	Main:SetTitle( "Edit Gate" )
	Main:SetVisible( true )
	Main:SetDraggable( true )
	Main:ShowCloseButton( true )
	Main:MakePopup()
	
	Main.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
		draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 127, 255 ) ) -- Draw a box instead of the frame
		if Main:IsActive() then draw.RoundedBox( 4, 0, 0, w, 24, Color( 0, 0, 191, 255 ) ) end
		draw.SimpleText(not usescash and "Item ClassName" or "Entry Fee","PS_ButtonText1",w/2,60,Color(255,255,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
		draw.SimpleText("Gate Model","PS_ButtonText1",w/2,120,Color(0,255,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
		if PS.Items[itemname] ~= nil and not usescash then draw.SimpleText("Item: "..PS.Items[itemname].Name,
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
	if usescash then
		ItemName:SetText(itemname and tostring(itemname) or "")
	else
		ItemName:SetText(itemname)
	end
	if not usescash then
		ItemCheck:SetImage(PS.Items[itemname] and "icon16/tick.png" or "icon16/cross.png")
	else
		itemname = tonumber(ItemName:GetValue()) or 0
		ItemCheck:SetImage(itemname >= 0 and "icon16/tick.png" or "icon16/cross.png")
	end
	ItemName.OnChange = function(self)
		itemname = self:GetValue()
		if not usescash then
			ItemCheck:SetImage(PS.Items[itemname] and "icon16/tick.png" or "icon16/cross.png")
		else
			itemname = tonumber(self:GetValue()) or 0
			ItemCheck:SetImage(itemname >= 0 and "icon16/tick.png" or "icon16/cross.png")
		end
	end
	
	--ItemName browser button.
	
	local ItemBrowserCache = ItemBrowserCache
	
	local ItemBrowserStart = vgui.Create( "DButton",Main)
	ItemBrowserStart:SetText("Browse...")
	ItemBrowserStart:SetPos(panelx/2+funclen/2+20,60)
	ItemBrowserStart:SetSize(80, 20)
	ItemBrowserStart:SetDisabled(usescash)
	ItemBrowserStart.DoClick = function()
		
		-- ItemBrowser window.
		if IsValid(ItemBrowserCache) then return end
		local ItemBrowser = vgui.Create( "DFrame" )
		ItemBrowser:SetSize( panelx, panely )
		ItemBrowser:Center()
		ItemBrowser:MakePopup()
		ItemBrowser:SetTitle( "Item Browser" )
		ItemBrowser.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 127, 127, 255 ) )
			if ItemBrowser:IsActive() then draw.RoundedBox( 4, 0, 0, w, 24, Color( 0, 191, 191, 255 ) ) end
		end
		ItemBrowserCache = ItemBrowser

		local ItemBrowserGUI = vgui.Create( "DFileBrowser", ItemBrowser )
		ItemBrowserGUI:Dock( FILL )
		ItemBrowserGUI:SetPath( "LUA" )
		ItemBrowserGUI:SetBaseFolder( "pointshop/items" )
		ItemBrowserGUI:SetOpen( true )
		
		function ItemBrowserGUI:OnSelect( path, panel )
			local matched = string.match(path,"%/.*%/.*%/(.*)%.lua") -- This line took about ONE HOUR to make. Why are patterns so hard to understand?
			if matched ~= "__category" then
				ItemCheck:SetImage(PS.Items[matched] and "icon16/tick.png" or "icon16/cross.png")
				ItemName:SetText(matched)
				itemname = matched
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
	
	--Alt button.
	local AltButton = vgui.Create( "DButton",Main)
	AltButton:SetText("Options")
	AltButton:SetPos(panelx/2+funclen/2+20,80)
	AltButton:SetSize(80, 20)
	AltButton.DoClick = function()
	
		--Selection menu.
		local AltMenu = vgui.Create("DMenu",Main)
		--local AltMenu = PreAltMenu:AddSubMenu("Gate Type")
		local Sub1 = AltMenu:AddOption("Uses Cash",function()
			if usescash then
				ItemName:SetNumeric(false)
				usescash = false
				itemname = ItemName:GetValue()
				ItemCheck:SetImage(PS.Items[itemname] and "icon16/tick.png" or "icon16/cross.png")
				ItemBrowserStart:SetDisabled(false)
			else
				ItemName:SetNumeric(true)
				usescash = true
				ItemName:SetText(tonumber(ItemName:GetValue()) and ItemName:GetValue() or "")
				itemname = tonumber(ItemName:GetValue()) or 0
				ItemCheck:SetImage(itemname >= 0 and "icon16/tick.png" or "icon16/cross.png")
				if IsValid(ItemBrowserCache) then ItemBrowserCache:Close() end
				ItemBrowserStart:SetDisabled(true)
			end
		end)
		--[[local Sub2 = AltMenu:AddOption("Cost",function()
			ItemName:SetNumeric(true)
			usescash = true
			ItemName:SetText(tonumber(ItemName:GetValue()) and ItemName:GetValue() or "")
			itemname = tonumber(ItemName:GetValue()) or 0
			ItemCheck:SetImage(itemname >= 0 and "icon16/tick.png" or "icon16/cross.png")
			if IsValid(ItemBrowser) then ItemBrowser:Close() end
			ItemBrowserStart:SetDisabled(true)
		end)]]
		AltMenu:AddSpacer()
		local Sub3 = AltMenu:AddOption("Deduct after use",function()
			removeafteruse = not removeafteruse
		end)
		if usescash then
			--Sub2:SetIcon("icon16/tick.png")
		--else
			Sub1:SetIcon("icon16/tick.png")
		end
		if removeafteruse then Sub3:SetIcon("icon16/tick.png") end
		AltMenu:Open()
	end
	
	--Model validation indicator.
	local ModelCheck = vgui.Create( "DImage",Main)
	ModelCheck:SetPos(panelx/2+funclen/2+2,120+2)
	ModelCheck:SetSize(16,16)
	
	--Model entry.
	local ModelName = vgui.Create( "DTextEntry",Main)
	ModelName:SetPos(-1,120)
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
	ModelRecheck:SetPos(panelx/2+funclen/2+20,120)
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
		if PS.Items[itemname] == nil and not usescash then notification.AddLegacy( "Invalid item!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
		if usescash and itemname < 0 then notification.AddLegacy( "Price can't be negative!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
		if usescash then itemname = tostring(math.min(itemname,2147483647)) end
		if modelname == "" then modelname = gate:GetModel() end
		if not util.IsValidModel(modelname) then notification.AddLegacy( "Invalid model! Leave blank for default model.", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
		if not IsValid(gate) then notification.AddLegacy( "Gate is nonexistent!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); Main:Remove(); return end
		net.Start("GateUpdate",true)
			net.WriteEntity(gate)
			net.WriteString(itemname)
			net.WriteBool(usescash)
			net.WriteBool(removeafteruse)
			net.WriteString(modelname)
		net.SendToServer()
		Main:Close()
	end
end)

-- Server UI

net.Receive("GateUpdate", function(bits,sender)
	if not sender:IsPlayer() or not SERVER then return end
	local target = net.ReadEntity()
	if not IsValid(target) or not sender:IsAdmin() then return end
	local name = net.ReadString()
	local cashonly = net.ReadBool()
	target:SetUsesCash(cashonly)
	if not cashonly and PS.Items[name] == nil then return
	elseif cashonly and not tonumber(name) then return end
	if cashonly and tonumber(name) < 0 then return end
	local removeafteruse = net.ReadBool()
	target:SetOnlyOnce(removeafteruse)
	local model = net.ReadString()
	if not util.IsValidModel(model) then return end
	target:SetShopItemName(name)
	if model ~= target:GetModel() then
		target:SetModel(model)
		target:SetShopModel(model)
		target:PhysicsInit( SOLID_VPHYSICS )
		local phys = target:GetPhysicsObject()
		if ( IsValid( phys ) ) then phys:Wake() end
	end
end)