AddCSLuaFile()

--SWEP.Base = "weapon_base"
SWEP.PrintName = "#rotgb.game_swep.name"
SWEP.Category = "#rotgb.category.rotgb"
SWEP.Author = "Piengineer12"
SWEP.Contact = "http://steamcommunity.com/id/Piengineer12/"
SWEP.Purpose = "#rotgb.game_swep.purpose"
SWEP.Instructions = "#rotgb.game_swep.instructions"
SWEP.WorldModel = "models/weapons/w_c4.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_c4.mdl"
SWEP.ViewModelFOV = 30
--SWEP.ViewModelFlip = false
--SWEP.ViewModelFlip1 = false
--SWEP.ViewModelFlip2 = false
SWEP.Spawnable = true
--SWEP.AdminOnly = false
SWEP.Slot = 1
--SWEP.SlotPos = 10
--SWEP.BounceWeaponIcon = true
--SWEP.DrawAmmo = true
--SWEP.DrawCrosshair = true
--SWEP.AccurateCrosshair = false
--SWEP.DrawWeaponInfoBox = true
--SWEP.WepSelectIcon = surface.GetTextureID("weapons/swep")
--SWEP.SpeechBubbleLid = surface.GetTextureID("gui/speech_lid")
SWEP.AutoSwitchFrom = false
SWEP.AutoSwitchTo = false
--SWEP.Weight = 5
--SWEP.CSMuzzleFlashes = false
--SWEP.CSMuzzleX = false
--SWEP.BobScale = 1
--SWEP.SwayScale = 1
SWEP.UseHands = true
--SWEP.m_WeaponDeploySpeed = 1
--SWEP.m_bPlayPickupSound = true
--SWEP.RenderGroup = RENDERGROUP_OPAQUE
--SWEP.ScriptedEntityType = "weapon"
--SWEP.IconOverride = "materials/entities/base.png"
--SWEP.DisableDuplicator = false
SWEP.Primary = {
	Ammo = "none",
	ClipSize = -1,
	DefaultClip = -1,
	Automatic = false
}
SWEP.Secondary = {
	Ammo = "none",
	ClipSize = -1,
	DefaultClip = -1,
	Automatic = false
}
local ROTGB_TOWERPLACEMENT = 1
local ROTGB_SETTOWER = 2
local ROTGB_SPEED = 3
local ROTGB_PLAY = 4
local ROTGB_AUTOSTART = 5
--local ROTGB_KICK = 6

if SERVER then
	util.AddNetworkString("rotgb_controller")
end

local color_black_semiopaque = Color(0, 0, 0, 191)
local color_gray = Color(127, 127, 127)
local color_light_gray = Color(191, 191, 191)
local color_red = Color(255, 0, 0)
local color_light_red = Color(255, 127, 127)
local color_orange = Color(255, 127, 0)
local color_light_orange = Color(255, 191, 127)
local color_green = Color(0, 255, 0)
local color_light_green = Color(127, 255, 127)
local color_aqua = Color(0, 255, 255)
local color_light_aqua = Color(127, 255, 255)
local color_light_blue = Color(127, 127, 255)

local padding = 8
local buttonHeight = 48
--local screenMaterial = Material("models/screenspace")

if CLIENT then
	surface.CreateFont("RotgBUIHeader",{
		font="Roboto",
		size=24
	})
	surface.CreateFont("RotgBUIBody",{
		font="Roboto",
		size=24
	})
	surface.CreateFont("RotgBUITitleFont",{
		font="Luckiest Guy Rotgb",
		extended=true,
		size=48
	})
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int",0,"CurrentTower")
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if IsValid(self:GetOwner()) and SERVER and self:GetNextPrimaryFire()<=CurTime() then
		local ply = self:GetOwner()
		self:SetNextPrimaryFire(CurTime()+0.2)
		local trace = self:BuildTraceData(ply)
		if self:GetCurrentTower() ~= 0 and trace.Hit then
			if not self.TowerTable then
				self.TowerTable = ROTGB_GetAllTowers()
			end
			local tempang = ply:GetAngles()
			tempang.p = 0
			tempang.r = 0
			if ply:IsNPC() then
				self:SetCurrentTower(math.random(#self.TowerTable))
			end
			local tower = ents.Create(self.TowerTable[self:GetCurrentTower()].ClassName)
			tower:SetPos(trace.HitPos)
			tower:SetAngles(tempang)
			tower:SetTowerOwner(ply)
			tower:Spawn()
			--util.ScreenShake(ply:GetShootPos(), 4, 20, 0.5, 64)
			if (ply:IsPlayer() and not ply:IsSprinting()) then
				self:SetCurrentTower(0)
				--self:SendWeaponAnim(ACT_VM_DRAW)
			end
		else
			local tower = trace.Entity
			if (IsValid(tower) and tower.Base == "gballoon_tower_base" and tower.HasAbility) then
				tower:DoAbility()
			else
				ply:EmitSound("items/medshotno1.wav",60,100,1,CHAN_WEAPON)
			end
		end
	end
end

function SWEP:CanSecondaryAttack()
	return CLIENT and self:GetOwner() == LocalPlayer()
end

function SWEP:SecondaryAttack()
	if game.SinglePlayer() then
		self:CallOnClient("SecondaryAttack")
	elseif not IsFirstTimePredicted() then return
	end
	if self:CanSecondaryAttack() then
		self:SetNextSecondaryFire(CurTime()+0.2)
		-- FIXME: This is kind of a bad way to get the modified amounts!
		self.TowerTable = table.Copy(ROTGB_GetAllTowers())
		for k,v in pairs(self.TowerTable) do
			if not self.BaseTowerTable then	
				self.BaseTowerTable = scripted_ents.GetStored("gballoon_tower_base")
			end
			table.Inherit(v, self.BaseTowerTable.t)
			self.BaseTowerTable.t.ApplyPerks(v)
		end
		if IsValid(self.TowerMenu) then
			if self.TowerMenu:IsVisible() then
				self.TowerMenu:Hide()
			else
				self.TowerMenu:Show()
				self.TowerMenu:MakePopup()
				self.TowerMenu.TowerScrollPanel:Refresh()
				self.TowerMenu.AbilityScrollPanel:Refresh()
				self.TowerMenu:OnShow()
			end
		else
			self:CreateTowerMenu()
		end
	end
end

function SWEP:PostDrawViewModel(viewmodel, weapon, ply)
	if IsValid(viewmodel) and viewmodel:GetCycle()>0.99 then
		--if self:GetCurrentTower() == 0 then
			local renderPos, renderAngles = LocalToWorld(Vector(26.6,2,-2.5), Angle(1,-95,47), viewmodel:GetPos(), viewmodel:GetAngles())
			cam.Start3D2D(renderPos, renderAngles, 0.01)
			-- screen is 3.8 x 2.0
			if self:GetCurrentTower() ~= 0 then
				if RealTime() % 10 < 5 then
					draw.SimpleText("#rotgb.game_swep.instructions.sprint_place.1", "RotgBUITitleFont", 190, 52, color_aqua, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					draw.SimpleText("#rotgb.game_swep.instructions.sprint_place.2", "RotgBUITitleFont", 190, 100, color_aqua, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				else
					draw.SimpleText("#rotgb.game_swep.instructions.primary_place.1", "RotgBUITitleFont", 190, 52, color_aqua, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					draw.SimpleText("#rotgb.game_swep.instructions.primary_place.2", "RotgBUITitleFont", 190, 100, color_aqua, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				end
			elseif IsValid(self.TowerMenu) and self.TowerMenu:IsVisible() then
				draw.SimpleText("#rotgb.game_swep.instructions.secondary_close.1", "RotgBUITitleFont", 190, 52, color_aqua, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				draw.SimpleText("#rotgb.game_swep.instructions.secondary_close.2", "RotgBUITitleFont", 190, 100, color_aqua, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			else
				if RealTime() % 10 < 5 then
					draw.SimpleText("#rotgb.game_swep.instructions.secondary_open.1", "RotgBUITitleFont", 190, 52, color_aqua, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					draw.SimpleText("#rotgb.game_swep.instructions.secondary_open.2", "RotgBUITitleFont", 190, 100, color_aqua, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				else
					draw.SimpleText("#rotgb.game_swep.instructions.primary.1", "RotgBUITitleFont", 190, 52, color_aqua, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					draw.SimpleText("#rotgb.game_swep.instructions.primary.2", "RotgBUITitleFont", 190, 100, color_aqua, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				end
			end
			cam.End3D2D()
		--[[else
			local renderPos, renderAngles = LocalToWorld(Vector(19.15,1.3,0.2), Angle(-3,-92,69), viewmodel:GetPos(), viewmodel:GetAngles())
			cam.Start3D2D(renderPos, renderAngles, 0.1)
			-- screen is 3.8 x 2.0
			--draw.SimpleText("TEST")
			cam.End3D2D()
			if viewmodel:GetRenderFX() ~= kRenderFxFadeFast then
				viewmodel:SetRenderFX(kRenderFxFadeFast)
			end
		end]]
	end
end

--[[local function HideAllNoBuilds()
	ROTGB_SetDrawNoBuilds(false)
end]]

function SWEP:Think()
	if not self.TowerTable then
		self:SetHoldType("slam")
		-- FIXME: duplication of above FIXME
		self.TowerTable = table.Copy(ROTGB_GetAllTowers())
		for k,v in pairs(self.TowerTable) do
			if not self.BaseTowerTable then	
				self.BaseTowerTable = scripted_ents.GetStored("gballoon_tower_base")
			end
			table.Inherit(v, self.BaseTowerTable.t)
			self.BaseTowerTable.t.ApplyPerks(v)
		end
	end
	if CLIENT then
		if self:GetCurrentTower() == 0 then
			if IsValid(self.ClientsideModel) then
				self.ClientsideModel:Remove()
			end
			
			--[[local viewmodel = LocalPlayer():GetViewModel()
			if (IsValid(viewmodel) and viewmodel:GetRenderFX() ~= kRenderFxSolidFast) then
				viewmodel:SetRenderFX(kRenderFxSolidFast)
			end]]
		else
			local tower = self.TowerTable[self:GetCurrentTower()]
			if not IsValid(self.ClientsideModel) then
				self.ClientsideModel = ClientsideModel(tower.Model, RENDERGROUP_BOTH)
				self.ClientsideModel:SetMaterial("models/wireframe")
				self.ClientsideModel:SetModel(tower.Model)
				self.ClientsideModel:SetColor(color_aqua)
				self.ClientsideModel.TowerType = self:GetCurrentTower()
				self.ClientsideModel.RenderOverride = function(self)
					self:DrawModel()
					if tower.DetectionRadius < 16384 and ROTGB_GetConVarValue("rotgb_range_enable_indicators") then
						local fadeout = ROTGB_GetConVarValue("rotgb_range_fade_time")
						self.DrawFadeNext = RealTime()+fadeout+ROTGB_GetConVarValue("rotgb_range_hold_time")
						if (self.DrawFadeNext or 0)>RealTime() then
							local maxAlpha = ROTGB_GetConVarValue("rotgb_range_alpha")
							local scol = self:GetColor() == color_aqua and tower.InfiniteRange and color_blue or self:GetColor()
							local alpha = math.Clamp(math.Remap(self.DrawFadeNext-RealTime(),fadeout,0,maxAlpha,0),0,maxAlpha)
							scol = Color(scol.r,scol.g,scol.b,alpha)
							render.DrawWireframeSphere(self:LocalToWorld(tower.LOSOffset or vector_origin),-tower.DetectionRadius,32,17,scol,true)
						end
					end
					--local mins, maxs = self:GetCollisionBounds()
					--render.DrawWireframeBox(self:GetPos(), self:GetAngles(), mins, maxs, color_white, true)
				end
				--ROTGB_SetDrawNoBuilds(true)
				--self.ClientsideModel:CallOnRemove("ROTGB_SetDrawNoBuilds", HideAllNoBuilds)
			elseif self.ClientsideModel.TowerType ~= self:GetCurrentTower() then
				self.ClientsideModel:Remove()
			end
			
			local trace = self:BuildTraceData(LocalPlayer())
			if trace.Hit then
				self.ClientsideModel:SetPos(trace.HitPos)
				local tempang = LocalPlayer():EyeAngles()
				tempang.p = 0
				tempang.r = 0
				self.ClientsideModel:SetAngles(tempang)
			end
		end
	end
	if SERVER then
		if self:GetCurrentTower() == 0 then
			if IsValid(self.ServersideModel) then
				self.ServersideModel:Remove()
			end
			
			--[[local viewmodel = LocalPlayer():GetViewModel()
			if (IsValid(viewmodel) and viewmodel:GetRenderFX() ~= kRenderFxSolidFast) then
				viewmodel:SetRenderFX(kRenderFxSolidFast)
			end]]
		else
			local tower = self.TowerTable[self:GetCurrentTower()]
			local owner = self:GetOwner()
			if not IsValid(self.ServersideModel) then
				local detector = ents.Create("prop_physics")
				detector:SetModel(tower.Model)
				detector:Spawn()
				detector:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
				detector:SetNoDraw(true)
				detector.TowerType = self:GetCurrentTower()
				detector.rotgb_isDetector = true
				
				local physObj = detector:GetPhysicsObject()
				if IsValid(physObj) then
					physObj:EnableGravity(false)
				end
				
				function detector:NoBuildTriggered(state)
					timer.Simple(detector:GetCreationTime()-CurTime()+0.1, function()
						if owner:IsPlayer() then
							net.Start("rotgb_controller", true)
							net.WriteUInt(ROTGB_TOWERPLACEMENT, 8)
							net.WriteBool(not state)
							net.Send(owner)
						end
					end)
				end
				
				self.ServersideModel = detector
			elseif self.ServersideModel.TowerType ~= self:GetCurrentTower() then
				self.ServersideModel:Remove()
			end
			
			if owner:IsPlayer() or owner:IsNPC() then
				local trace = self:BuildTraceData(owner)
				if trace.Hit then
					self.ServersideModel:SetPos(trace.HitPos)
					local tempang = owner:EyeAngles()
					tempang.p = 0
					tempang.r = 0
					self.ServersideModel:SetAngles(tempang)
					
					local physObj = self.ServersideModel:GetPhysicsObject()
					if IsValid(physObj) then
						physObj:Wake()
					end
				end
			end
		end
	end
end

function SWEP:OnRemove()
	if SERVER then
		self:SetCurrentTower(0)
		if IsValid(self.ServersideModel) then
			self.ServersideModel:Remove()
		end
	end
	if CLIENT then
		if IsValid(self.TowerMenu) then
			self.TowerMenu:Close()
		end
		if IsValid(self.ClientsideModel) then
			self.ClientsideModel:Remove()
		end
		--[[if CLIENT then
			local viewmodel = LocalPlayer():GetViewModel()
			if (IsValid(viewmodel) and viewmodel:GetRenderFX() == kRenderFxFadeFast) then
				viewmodel:SetRenderFX(kRenderFxSolidFast)
			end
		end]]
	end
end

function SWEP:Holster()
	if SERVER then
		self:SetCurrentTower(0)
		if IsValid(self.ServersideModel) then
			self.ServersideModel:Remove()
		end
	end
	if CLIENT then
		if IsValid(self.TowerMenu) then
			self.TowerMenu:Hide()
		end
		if IsValid(self.ClientsideModel) then
			self.ClientsideModel:Remove()
		end
	end
	return true
end

net.Receive("rotgb_controller", function(length, ply)
	local func = net.ReadUInt(8)
	if SERVER then
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) then
			if wep:GetClass()=="rotgb_control" and func == ROTGB_SETTOWER then
				local desiredtower = net.ReadUInt(8)
				if wep.TowerTable[desiredtower] or desiredtower == 0 then
					--[[if desiredtower == 0 then
						wep:SendWeaponAnim(ACT_VM_DRAW)
					elseif wep:GetCurrentTower() == 0 then
						wep:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
					end]]
					wep:SetCurrentTower(desiredtower)
					wep:Think()
				end
			end
			if wep:GetClass()=="rotgb_control" or wep:GetClass()=="rotgb_shooter" then
				if func == ROTGB_SPEED then
					local shouldGoFaster = net.ReadBool()
					local newSpeed = math.Clamp(game.GetTimeScale() * (shouldGoFaster and 2 or 0.5), 1, 4)
					game.SetTimeScale(newSpeed)
					if shouldGoFaster then
						ply:EmitSound("buttons/combine_button5.wav",60,80+math.log(game.GetTimeScale(),2)*20,1,CHAN_WEAPON)
					else
						ply:EmitSound("buttons/combine_button3.wav",60,100+math.log(game.GetTimeScale(),2)*20,1,CHAN_WEAPON)
					end
				elseif func == ROTGB_PLAY then
					local spawners = ents.FindByClass("gballoon_spawner")
					if table.IsEmpty(spawners) then
						--ply:EmitSound("buttons/button18.wav",60,100,1,CHAN_WEAPON)
						ROTGB_CauseNotification(ROTGB_NOTIFY_NOSPAWNERS, ROTGB_NOTIFYTYPE_ERROR, ply)
					end
					for k,v in pairs(spawners) do
						v:Fire("Use",nil,nil,ply)
					end
					ply:EmitSound("buttons/button14.wav",60,100,1,CHAN_WEAPON)
				elseif func == ROTGB_AUTOSTART then
					local shouldAutoStart = net.ReadBool()
					
					local spawners = ents.FindByClass("gballoon_spawner")
					if table.IsEmpty(spawners) then
						ROTGB_CauseNotification(ROTGB_NOTIFY_NOSPAWNERS, ROTGB_NOTIFYTYPE_ERROR, ply)
					end
					for k,v in pairs(spawners) do
						v:SetAutoStart(shouldAutoStart)
					end
					ply:EmitSound(shouldAutoStart and "buttons/button17.wav" or "buttons/button16.wav",60,100,1,CHAN_WEAPON)
				end
			end
		end
	end
	if CLIENT then
		local wep = LocalPlayer():GetActiveWeapon()
		if (IsValid(wep) and wep:GetClass()=="rotgb_control" and IsValid(wep.ClientsideModel)) and func == ROTGB_TOWERPLACEMENT then
			local valid = net.ReadBool()
			if valid then
				wep.ClientsideModel:SetColor(color_aqua)
			else
				wep.ClientsideModel:SetColor(color_red)
			end
		end
	end
end)

function SWEP:BuildTraceData(ent)
	self.CommonTraceData = self.CommonTraceData or {}
	self.TraceResult = self.TraceResult or {}
	self.CommonTraceData.start = ent:GetShootPos()
	self.CommonTraceData.endpos = ent:GetShootPos() + ent:GetAimVector() * 32767
	self.CommonTraceData.filter = ent
	self.CommonTraceData.output = self.TraceResult
	self.CommonTraceData.collisiongroup = COLLISION_GROUP_DEBRIS_TRIGGER
	util.TraceLine(self.CommonTraceData)
	return self.TraceResult
end

function SWEP:DoTowerSelector(id)
	net.Start("rotgb_controller")
	net.WriteUInt(ROTGB_SETTOWER, 8)
	net.WriteUInt(id, 8)
	net.SendToServer()
end

local function PaintBackground(self, w, h)
	draw.RoundedBox(8, 0, 0, w, h, color_black_semiopaque)
end

function SWEP:DeterminePowerOfTwoSize(size)
	return bit.lshift(1, math.floor(math.log(size,2)))
end

function SWEP:InstallMenuFunctions(Main)
	function Main:OnShow()
		self.AutoStartCheckBox:Refresh()
	end
	function Main:CreateButton(text, parent, color1, color2, color3)
		local Button = vgui.Create("DButton", parent)
		Button:SetFont("RotgBUIHeader")
		Button:SetText(text)
		Button:SetColor(color_black)
		Button:SetTall(buttonHeight)
		
		function Button:Paint(w, h)
			draw.RoundedBox(8, 0, 0, w, h, not self:IsEnabled() and color_gray or self:IsDown() and color3 or self:IsHovered() and color2 or color1)
		end
		
		return Button
	end
	function Main:AddHeader(text, parent)
		local Label = vgui.Create("DLabel", parent)
		Label:SetFont("RotgBUIHeader")
		Label:SetText(text)
		Label:DockMargin(0,0,0,padding)
		Label:SetColor(color_aqua)
		Label:SizeToContentsY()
		Label:Dock(TOP)
		
		return Label
	end
	function Main:AddSearchBox(parent)
		local TextEntry = vgui.Create("DTextEntry", parent)
		TextEntry:SetFont("RotgBUIBody")
		TextEntry:SetPlaceholderText("#rotgb.game_swep.transfer.search")
		TextEntry:SetTall(buttonHeight)
		TextEntry:Dock(TOP)
		
		return TextEntry
	end
end

function SWEP:CreateTowerMenu()
	local wep = self
	
	local Main = vgui.Create("DFrame")
	Main:SetPos(0,0)
	Main:SetSize(ScrW(),ScrH())
	Main:DockPadding(padding,padding,padding,padding)
	Main.Paint = nil
	Main:MakePopup()
	self:InstallMenuFunctions(Main)
	self.TowerMenu = Main
	
	local LeftDivider = vgui.Create("DHorizontalDivider", Main)
	LeftDivider:Dock(FILL)
	LeftDivider:SetDividerWidth(padding)
	LeftDivider:SetLeftWidth(ScrW()*0.2-padding*1.5)
	
	local RightDivider = vgui.Create("DHorizontalDivider")
	LeftDivider:SetRight(RightDivider)
	RightDivider:SetDividerWidth(padding)
	RightDivider:SetLeftWidth(ScrW()*0.6-padding)
	
	LeftDivider:SetLeft(self:CreateLeftPanel(Main))
	RightDivider:SetRight(self:CreateRightPanel(Main))
	RightDivider:SetLeft(self:CreateMiddlePanel(Main))
	function Main:Think()
		if IsValid(wep) then
			local selectedTower = wep:GetCurrentTower()
			if selectedTower ~= self.TowerSelected then
				self.TowerSelected = selectedTower
				if selectedTower ~= 0 then
					self:SignalTowerSelected(wep, selectedTower)
				elseif selectedTower == 0 then
					self:SignalTowerUnselected(wep)
				end
			end
		else
			Main:Close()
		end
	end
	function Main:SignalTowerSelected(wep, index)
		local data = wep.TowerTable[wep:GetCurrentTower()]
		LeftDivider:GetLeft():Remove()
		LeftDivider:SetLeft(wep:CreateLeftTowerPanel(self, data))
	end
	function Main:SignalTowerUnselected(wep)
		LeftDivider:GetLeft():Remove()
		LeftDivider:SetLeft(wep:CreateLeftPanel(self))
	end
	
	--Main:AddHeader("Secondary Fire to Hide Menu", MiddlePanel)
	
	Main:SetTitle("")
	Main:ShowCloseButton(false)
end

function SWEP:CreateLeftPanel(Main)
	local wep = self
	local LeftPanel = vgui.Create("DPanel")
	LeftPanel.Paint = PaintBackground
	LeftPanel:DockPadding(padding,padding,padding,padding)
	local TransferHeader = Main:AddHeader("", LeftPanel)
	
	local RefreshButton = Main:CreateButton("#rotgb.game_swep.transfer.refresh", LeftPanel, color_green, color_light_green, color_white)
	RefreshButton:DockMargin(0,0,0,padding)
	RefreshButton:Dock(TOP)
	
	local ScrollPanel = vgui.Create("DScrollPanel", LeftPanel)
	function RefreshButton:DoClick()
		ScrollPanel:Refresh()
	end
	ScrollPanel:Dock(FILL)
	
	local SearchBox = Main:AddSearchBox(LeftPanel)
	SearchBox:DockMargin(0,0,0,padding)
	function ScrollPanel:Refresh()
		if IsValid(wep) then
			ScrollPanel:Clear()
			local text = SearchBox:GetValue():lower()
			
			for k,v in pairs(player.GetAll()) do
				if v:Nick():lower():find(text, 1, true) --[[and v ~=LocalPlayer()]] then
					local NameButton = Main:CreateButton("", ScrollPanel, color_aqua, color_light_aqua, color_white)
					NameButton:DockMargin(0,0,0,padding)
					NameButton:Dock(TOP)
					function NameButton:DoClick()
						if IsValid(v) then
							net.Start("rotgb_generic")
							net.WriteUInt(ROTGB_OPERATION_TRANSFER, 8)
							net.WriteEntity(v)
							net.SendToServer()
							
							if not ROTGB_GetConVarValue("rotgb_individualcash") then
								ROTGB_CauseNotification(ROTGB_NOTIFY_TRANSFERSHARED, ROTGB_NOTIFYTYPE_ERROR, ply)
							end
						else
							ScrollPanel:Refresh()
						end
					end
					function NameButton:PaintOver(w,h)
						if IsValid(v) then
							draw.SimpleText(ROTGB_LocalizeString("rotgb.game_swep.transfer.target", v:Nick(), ROTGB_FormatCash(ROTGB_GetCash(v))), "RotgBUIBody", w/2, h/2, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						else -- eee!
							ScrollPanel:Refresh()
						end
					end
					
					if v == LocalPlayer() then
						NameButton:SetCursor("no")
						NameButton:SetEnabled(false)
					end
				end
			end
		end
	end
	function SearchBox:OnChange()
		ScrollPanel:Refresh()
	end
	function TransferHeader:Think()
		local newCash = ROTGB_GetCash()
		local oldCash = self.cash
		if newCash ~= oldCash and (oldCash == oldCash or newCash == newCash) then -- needed to weed out NaNs, otherwise this will try to change the text EVERY FRAME
			self.cash = newCash
			self:SetText(ROTGB_LocalizeString("rotgb.game_swep.transfer.header", ROTGB_FormatCash(ROTGB_GetTransferAmount(LocalPlayer())))) -- this many brackets might be confusing
		end
	end
	ScrollPanel:Refresh()
	
	return LeftPanel
end

function SWEP:CreateLeftTowerPanel(Main, data)
	local wep = self
	local class = data.ClassName
	local LeftPanel = vgui.Create("DPanel")
	LeftPanel.Paint = PaintBackground
	LeftPanel:DockPadding(padding,padding,padding,padding)
	Main:AddHeader(language.GetPhrase("rotgb.tower."..class..".name"), LeftPanel)
	
	local DescLabel = vgui.Create("DLabel", LeftPanel)
	DescLabel:Dock(TOP)
	DescLabel:SetWrap(true)
	DescLabel:SetAutoStretchVertical(true)
	DescLabel:SetFont("RotgBUIBody")
	DescLabel:SetText(language.GetPhrase("rotgb.tower."..class..".purpose"))
	
	local DamageLabel = vgui.Create("DLabel", LeftPanel)
	DamageLabel:Dock(TOP)
	DamageLabel:SetFont("RotgBUIBody")
	DamageLabel:SetText(ROTGB_LocalizeString("rotgb.game_swep.tower.damage", string.format("%u", data.AttackDamage/10)))
	DamageLabel:SetTextColor(color_light_red)
	DamageLabel:SizeToContents()
	
	local FireRateLabel = vgui.Create("DLabel", LeftPanel)
	FireRateLabel:Dock(TOP)
	FireRateLabel:SetFont("RotgBUIBody")
	FireRateLabel:SetText(ROTGB_LocalizeString("rotgb.game_swep.tower.fire_rate", string.format("%.2f", data.FireRate)))
	FireRateLabel:SetTextColor(color_light_green)
	FireRateLabel:SizeToContents()
	
	local RangePanel = vgui.Create("DLabel", LeftPanel)
	RangePanel:Dock(TOP)
	RangePanel:SetFont("RotgBUIBody")
	RangePanel:SetText(ROTGB_LocalizeString("rotgb.game_swep.tower.range", string.format("%u", data.DetectionRadius)))
	RangePanel:SetTextColor(color_light_blue)
	RangePanel:SizeToContents()
	
	local CancelButton = Main:CreateButton("#rotgb.game_swep.tower.cancel", LeftPanel, color_red, color_light_red, color_white)
	CancelButton:Dock(BOTTOM)
	function CancelButton:DoClick()
		wep:DoTowerSelector(0)
	end
	
	return LeftPanel
end

function SWEP:CreateRightPanel(Main)
	local wep = self
	local RightDivider = vgui.Create("DVerticalDivider")
	RightDivider:SetDividerHeight(padding)
	RightDivider:SetTopHeight(ScrH()*0.8)
	
	local UpperPanel = vgui.Create("DPanel")
	RightDivider:SetTop(UpperPanel)
	UpperPanel.Paint = PaintBackground
	UpperPanel:DockPadding(padding,padding,padding,padding)
	Main:AddHeader("#rotgb.game_swep.tower.header", UpperPanel)
	
	local ScrollPanel = vgui.Create("DScrollPanel", UpperPanel)
	ScrollPanel:Dock(FILL)
	
	local TowersPanel = vgui.Create("DIconLayout", ScrollPanel)
	TowersPanel:SetSpaceX(padding)
	TowersPanel:SetSpaceY(padding)
	TowersPanel:Dock(FILL)
	--[[local oldThink = ScrollPanel.Think
	function ScrollPanel:Think(...)
		if self.Difficulty ~= ROTGB_GetConVarValue("rotgb_difficulty") then
			self.Difficulty = ROTGB_GetConVarValue("rotgb_difficulty")
			self:Refresh()
		end
		if oldThink then
			oldThink(self, ...)
		end
	end]]
	function ScrollPanel:Refresh()
		TowersPanel:Clear()
		local towerPanelSize = wep:DeterminePowerOfTwoSize(ROTGB_GetConVarValue("rotgb_hud_size")*4)
		
		local blacklisted = {}
		for entry in string.gmatch(ROTGB_GetConVarValue("rotgb_tower_blacklist"), "%S+") do
			blacklisted[entry] = true
		end
		local chessOnly = ROTGB_GetConVarValue("rotgb_tower_chess_only")
		for i,v in ipairs(wep.TowerTable) do
			if not (blacklisted[v.ClassName] or chessOnly > 0 and not v.IsChessPiece or chessOnly < 0 and v.IsChessPiece) then
				local TowerPanel = vgui.Create("DImageButton", TowersPanel)
				TowerPanel:SetMaterial("vgui/entities/"..v.ClassName)
				TowerPanel:SetSize(towerPanelSize, towerPanelSize)
				TowerPanel:SetColor(color_gray)
				TowerPanel.affordable = false
				TowerPanel.minimumLevel = engine.ActiveGamemode() == "rotgb" and i or 0
				TowerPanel.levelLocked = false
				TowerPanel.price = ROTGB_ScaleBuyCost(v.Cost, v, {type = ROTGB_TOWER_PURCHASE, ply = LocalPlayer()})
				TowerPanel.cashText = ROTGB_FormatCash(TowerPanel.price, true)
				TowerPanel:SetTooltip(v.PrintName)
				
				function TowerPanel:PaintOver(w, h)
					local drawColor = color_white
					local isLevelLocked = false
					if self.minimumLevel > 0 then
						isLevelLocked = LocalPlayer():RTG_GetLevel() < self.minimumLevel
					end
					if isLevelLocked then
						drawColor = color_red
						if not self.levelLocked then
							self.levelLocked = true
							self:SetColor(color_gray)
							TowerPanel.cashText = ROTGB_LocalizeString("rotgb.game_swep.tower.level_required", string.format("%u", self.minimumLevel)) 
						end
					elseif self.levelLocked then
						self.levelLocked = false
						TowerPanel.cashText = ROTGB_FormatCash(self.price, true)
						if self.affordable and not self.levelLocked then
							self:SetColor(color_white)
						end
					end
					
					if ROTGB_GetCash() < self.price then
						drawColor = color_red
						if self.affordable then
							self.affordable = false
							self:SetColor(color_gray)
						end
					elseif not self.affordable then
						self.affordable = true
						if self.affordable and not self.levelLocked then
							self:SetColor(color_white)
						end
					end
					
					if self:IsHovered() then
						surface.SetDrawColor(drawColor.r, drawColor.g, drawColor.b, 31)
						surface.DrawRect(0, 0, w, h)
					end
					
					draw.SimpleTextOutlined(self.cashText, "RotgB_font", w/2, h, drawColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, color_black)
				end
				
				function TowerPanel:DoClick()
					wep:DoTowerSelector(i)
				end
			end
		end
	end
	ScrollPanel:Refresh()
	Main.TowerScrollPanel = ScrollPanel
	
	RightDivider:SetBottom(self:CreateBottomRightPanel(Main))
	
	return RightDivider
end

function SWEP:CreateBottomRightPanel(Main)
	local function DrawTriangle(centerX, centerY, radius, angle)
		angle = math.rad(angle)
		local deg120 = math.pi*2/3
		local points = {}
		
		draw.NoTexture()
		surface.SetDrawColor(color_black)
		for i=0,2 do
			table.insert(points, {
				x = centerX + radius * math.sin(angle+i*deg120),
				y = centerY + radius * -math.cos(angle+i*deg120) -- y is down, not up
			})
		end
		
		surface.DrawPoly(points)
	end
	
	local BottomPanel = vgui.Create("DPanel")
	BottomPanel.Paint = PaintBackground
	BottomPanel:DockPadding(padding,padding,padding,padding)
	
	local AutoCheckBox = vgui.Create("DCheckBoxLabel", BottomPanel)
	AutoCheckBox:SetFont("RotgBUIHeader")
	AutoCheckBox:SetText("#rotgb.game_swep.auto_start")
	AutoCheckBox:SizeToContentsY()
	AutoCheckBox:Dock(BOTTOM)
	AutoCheckBox:DockMargin(0,padding,0,0)
	function AutoCheckBox:OnChange(value)
		net.Start("rotgb_controller")
		net.WriteUInt(ROTGB_AUTOSTART, 8)
		net.WriteBool(value)
		net.SendToServer()
	end
	function AutoCheckBox:Refresh()
		self:SetChecked(false)
		for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
			if v:GetAutoStart() then
				self:SetChecked(true)
				break
			end
		end
	end
	AutoCheckBox:Refresh()
	Main.AutoStartCheckBox = AutoCheckBox
	
	local ButtonDivider = vgui.Create("DHorizontalDivider", BottomPanel)
	ButtonDivider:Dock(FILL)
	ButtonDivider:SetLeftWidth(ScrW()/15-padding/2)
	
	local SpeedPanel = vgui.Create("DPanel")
	ButtonDivider:SetDividerWidth(padding)
	ButtonDivider:SetLeft(SpeedPanel)
	SpeedPanel.Paint = nil
	local FastButton = Main:CreateButton("", SpeedPanel, color_aqua, color_light_aqua, color_white)
	FastButton:DockMargin(0,0,0,padding)
	FastButton:Dock(TOP)
	FastButton:SetEnabled(game.GetTimeScale() < 4)
	function FastButton:PaintOver(w,h)
		local y = h/2
		local size = math.min(w/8,h/4)
		DrawTriangle(w/2-size*0.75, y, size, 90)
		DrawTriangle(w/2+size*0.75, y, size, 90)
	end
	function SpeedPanel:PerformLayout()
		FastButton:SetTall((self:GetTall()-padding)/2)
	end
	local SlowButton = Main:CreateButton("", SpeedPanel, color_orange, color_light_orange, color_white)
	SlowButton:Dock(FILL)
	SlowButton:SetEnabled(game.GetTimeScale() > 1)
	function SlowButton:PaintOver(w,h)
		local y = h/2
		local size = math.min(w/8,h/4)
		DrawTriangle(w/2-size*0.75, y, size, -90)
		DrawTriangle(w/2+size*0.75, y, size, -90)
	end
	function SpeedPanel:Think()
		if self.CurrentSpeed ~= game.GetTimeScale() then
			self.CurrentSpeed = game.GetTimeScale()
			FastButton:SetEnabled(self.CurrentSpeed < 4)
			SlowButton:SetEnabled(self.CurrentSpeed > 1)
		end
	end
	function FastButton:DoClick()
		net.Start("rotgb_controller", true)
		net.WriteUInt(ROTGB_SPEED, 8)
		net.WriteBool(true)
		net.SendToServer()
	end
	function SlowButton:DoClick()
		net.Start("rotgb_controller", true)
		net.WriteUInt(ROTGB_SPEED, 8)
		net.WriteBool(false)
		net.SendToServer()
	end
	
	local PlayButton = Main:CreateButton("", BottomPanel, color_green, color_light_green, color_white)
	ButtonDivider:SetRight(PlayButton)
	--PlayButton:NoClipping(true)
	function PlayButton:PaintOver(w,h)
		DrawTriangle(w/2, h/2, math.min(w/4,h/4), 90)
	end
	function PlayButton:DoClick()
		net.Start("rotgb_controller")
		net.WriteUInt(ROTGB_PLAY, 8)
		net.SendToServer()
	end
	
	return BottomPanel
end

function SWEP:CreateUpperPanel(Main)
	local wep = self
	local UpperPanel = vgui.Create("DPanel")
	UpperPanel.Paint = PaintBackground
	UpperPanel:DockPadding(padding,padding,padding,padding)
	Main:AddHeader("#rotgb.game_swep.abilities.header", UpperPanel)
	
	local ScrollPanel = vgui.Create("DScrollPanel", UpperPanel)
	ScrollPanel:Dock(FILL)
	
	local TowersPanel = vgui.Create("DIconLayout", ScrollPanel)
	TowersPanel:SetSpaceX(padding)
	TowersPanel:SetSpaceY(padding)
	TowersPanel:Dock(FILL)
	
	function ScrollPanel:Refresh()
		TowersPanel:Clear()
		local towerPanelSize = wep:DeterminePowerOfTwoSize(ScrH()*0.15-padding*4.5-24)
		local halfSize = towerPanelSize/2
		local success = false
		local AllTowersPanel = false
		
		for k,v in pairs(ents.GetAll()) do
			if v.Base == "gballoon_tower_base" and v.HasAbility then
				success = true
				
				if not AllTowersPanel then
					AllTowersPanel = Main:CreateButton("#rotgb.game_swep.abilities.all", TowersPanel, color_green, color_light_green, color_white)
					AllTowersPanel:SetSize(towerPanelSize*2+padding, towerPanelSize)
					function AllTowersPanel:DoClick()
						net.Start("rotgb_generic")
						net.WriteUInt(ROTGB_OPERATION_TRIGGER, 8)
						net.WriteEntity(LocalPlayer())
						net.SendToServer()
					end
				end
				
				local TowerPanel = vgui.Create("DImageButton", TowersPanel)
				TowerPanel.Tower = v
				TowerPanel:SetMaterial("vgui/entities/"..v:GetClass())
				TowerPanel:SetSize(towerPanelSize, towerPanelSize)
				TowerPanel:SetColor(color_gray)
				TowerPanel.activatable = false
				TowerPanel.upgradeText = ""
				
				local reference = v.UpgradeReference
				local upgradeAmounts = {}
				for i=1,#reference do
					upgradeAmounts[i] = string.format("%u", bit.rshift(v:GetUpgradeStatus(),(i-1)*4)%16)
				end
				TowerPanel.upgradeText = table.concat(upgradeAmounts, "-")
				
				function TowerPanel:PaintOver(w, h)
					local tower = self.Tower
					if IsValid(tower) then
						if self.activatable == (tower:GetAbilityCharge() < 1) then
							self.activatable = not self.activatable
							if self.activatable then
								self:SetColor(color_white)
							else
								self:SetColor(color_gray)
							end
						end
						local drawColor = self.activatable and color_white or color_red
						if self:IsHovered() then
							surface.SetDrawColor(drawColor.r, drawColor.g, drawColor.b, 31)
							surface.DrawRect(0, 0, w, h)
						end
						if not self.activatable then
							local percent = math.Clamp(tower:GetAbilityCharge(),0,1)
							local circleColor = HSVToColor(percent*120,1,1)
							ROTGB_DrawCircle(
								halfSize,halfSize,halfSize,percent,
								circleColor.r,circleColor.g,circleColor.b,circleColor.a
							)
						end
						draw.SimpleTextOutlined(self.upgradeText, "RotgBUIBody", w/2, h, drawColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
					else
						self:Remove()
					end
				end
				
				function TowerPanel:DoClick()
					net.Start("rotgb_generic")
					net.WriteUInt(ROTGB_OPERATION_TRIGGER, 8)
					net.WriteEntity(self.Tower)
					net.SendToServer()
				end
			end
		end
		
		if not success then
			Main:AddHeader("#rotgb.game_swep.abilities.description", TowersPanel)
		end
		TowersPanel:InvalidateLayout(true)
		ScrollPanel:InvalidateLayout(true)
	end
	ScrollPanel:Refresh()
	Main.AbilityScrollPanel = ScrollPanel
	
	return UpperPanel
end

function SWEP:CreateMiddlePanel(Main)
	local MiddleDivider = vgui.Create("DVerticalDivider")
	MiddleDivider:SetDividerHeight(padding)
	MiddleDivider:SetTopHeight(ScrH()*0.15-padding*1.5)
	MiddleDivider:SetTop(self:CreateUpperPanel(Main))
	
	local LowerPanel = vgui.Create("DPanel")
	MiddleDivider:SetBottom(LowerPanel)
	--MiddlePanel:DockPadding(padding,padding,padding,padding)
	LowerPanel.Paint = nil
	LowerPanel:SetWorldClicker(true)
	
	local CloseButton = Main:CreateButton("#rotgb.game_swep.hide", LowerPanel, color_red, color_light_red, color_white)
	CloseButton:SizeToContentsX(buttonHeight-24)
	function CloseButton:DoClick()
		Main:Hide()
	end
	function LowerPanel:PerformLayout(w, h)
		CloseButton:SetPos(w/2-CloseButton:GetWide()/2, h-CloseButton:GetTall())
	end
	
	return MiddleDivider
end