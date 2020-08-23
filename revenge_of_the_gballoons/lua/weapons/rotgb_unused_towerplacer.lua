AddCSLuaFile()

SWEP.Category			= "RotgB"
--	SWEP.Spawnable			= false
--	SWEP.AdminOnly			= false
SWEP.PrintName			= "Tower Placer"
--	SWEP.Base				= weapon_base
SWEP.m_WeaponDeploySpeed= 1
SWEP.Author				= "Piengineer"
SWEP.Contact			= "http://steamcommunity.com/id/Piengineer12/"
SWEP.Purpose			= "Place RotgB towers."
SWEP.Instructions		= "Primary: Place.\nSecondary: Cycle forward.\nSprint + Secondary: Cycle backward."
SWEP.ViewModel			= "models/weapons/cstrike/c_c4.mdl"
--	SWEP.ViewModelFlip		= false
--	SWEP.ViewModelFlip1		= false
--	SWEP.ViewModelFlip2		= false
SWEP.ViewModelFOV		= 30
SWEP.WorldModel			= "models/weapons/w_c4.mdl"
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
SWEP.Slot				= 1
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
SWEP.UseHands			= true
--	SWEP.AccurateCrosshair	= false
--	SWEP.DisableDuplicator	= false
SWEP.m_bPlayPickupSound	= false
SWEP.CommonTraceData = {}
SWEP.TraceResult = {}

function SWEP:BuildTowerTable()
	local temptable = {}
	for k,v in pairs(scripted_ents.GetList()) do
		if v.Base == "gballoon_tower_base" then
			table.insert(temptable, {class=v.t.ClassName, name=v.t.PrintName, cost=v.t.Cost, model=v.t.Model, infinite=v.t.InfiniteRange, range=v.t.DetectionRadius, damage=v.t.AttackDamage, firerate=v.t.FireRate, losoffset=v.t.LOSOffset or vector_origin})
		end
	end
	table.sort(temptable, function(a,b)
		if a.cost == b.cost then
			return a.name < b.name
		else
			return a.cost < b.cost
		end
	end)
	return temptable
end

function SWEP:BuildTraceData(ent)
	self.CommonTraceData.start = ent:GetShootPos()
	self.CommonTraceData.endpos = ent:GetShootPos() + ent:GetAimVector() * 32767
	self.CommonTraceData.filter = ent
	self.CommonTraceData.output = self.TraceResult
	util.TraceLine(self.CommonTraceData)
	return self.CommonTraceData.output
end

function SWEP:OnReloaded()
	self.TowerTable = nil
end

function SWEP:Think()
	if not self.TowerTable then
		self.TowerTable = self:BuildTowerTable()
		--self:SetSubMaterial(0,"phoenix_storms/stripes")
		self:SetHoldType("slam")
	end
	if SERVER and IsValid(self.Owner) then
		local tower3 = self.TowerTable[self:GetCurrentTower()+1]
		if not IsValid(self.ServersideModel) then
			self.ServersideModel = ents.Create("prop_dynamic")
			self.ServersideModel:SetModel(tower3.model)
			self.ServersideModel:Spawn()
			--self.ServersideModel:PhysicsInit(SOLID_BBOX)
			--self.ServersideModel:SetCollisionGroup(COLLISION_GROUP_DISSOLVING)
			self.ServersideModel:SetNWBool("rotgb_isDetector", true)
			self.ServersideModel:SetNoDraw(true)
		elseif self.ServersideModel:GetModel() ~= tower3.model then
			self.ServersideModel:SetModel(tower3.model)
		end
		
		local trace = self:BuildTraceData(self.Owner)
		self.ServersideModel:SetPos(trace.HitPos)
		local tempang = self.Owner:GetAngles()
		tempang.p = 0
		tempang.r = 0
		self.ServersideModel:SetAngles(tempang)
		--self:SetServerMentionBlock(self.ServersideModel:GetNWBool("rotgb_isDetected"))
		
		local not_nobuilds = ents.GetAll()
		for k,v in pairs(not_nobuilds) do
			if v:GetClass()=="func_rotgb_nobuild" then
				not_nobuilds[k] = nil
			end
		end
		local p1, p2 = self.ServersideModel:WorldSpaceAABB()
		--p1:Add(trace.HitPos)
		--p2:Add(trace.HitPos)
		
		local tempvar = false
		--debugoverlay.Line(p1, p2, 0.05)
		for k,v in pairs(ents.FindInSphere(p1,1)) do
			if v:GetClass()=="func_rotgb_nobuild" and not v:GetDisabled() then
				tempvar = true break 
			end
		end
		for k,v in pairs(ents.FindInSphere(p2,1)) do
			if v:GetClass()=="func_rotgb_nobuild" and not v:GetDisabled() then
				tempvar = true break 
			end
		end
		--[[local tracedata = {
			start = trace.HitPos + self.ServersideModel:GetCollisionBounds(),
			endpos = trace.HitPos + select(2,self.ServersideModel:GetCollisionBounds()),
			filter = table.ClearKeys(not_nobuilds),
			ignoreworld = true,
			mask = MASK_ALL
		}
		local trace2 = util.TraceLine(tracedata)]]
		--PrintTable(trace2)
		self:SetServerMentionBlock(tempvar)
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int",0,"CurrentTower")
	self:NetworkVar("Bool",0,"ServerMentionBlock")
end

local color_blue = Color(0,0,255)
local color_aqua = Color(0,255,255)
local color_red = Color(255,0,0)
local color_red_dark = Color(127,0,0)
local color_gray = Color(127,127,127)

local ConR = GetConVar("rotgb_range_enable_indicators")
local ConH = GetConVar("rotgb_range_hold_time")
local ConT = GetConVar("rotgb_range_fade_time")
local ConA = GetConVar("rotgb_range_alpha")

function SWEP:DrawHUD()
	if not self.TowerTable then
		self.TowerTable = self:BuildTowerTable()
	end
	local cash = ROTGB_GetCash(LocalPlayer())
	local tower1 = self.TowerTable[ self:GetCurrentTower()-1 ]
	local tower2 = self.TowerTable[ self:GetCurrentTower()   ]
	local tower3 = self.TowerTable[ self:GetCurrentTower()+1 ]
	local tower4 = self.TowerTable[ self:GetCurrentTower()+2 ]
	local tower5 = self.TowerTable[ self:GetCurrentTower()+3 ]
	
	if not IsValid(self.ClientsideModel) then
		self.ClientsideModel = ClientsideModel(tower3.model, RENDERGROUP_BOTH)
		self.ClientsideModel:SetMaterial("models/wireframe")
	elseif self.ClientsideModel:GetModel() ~= tower3.model then
		self.ClientsideModel:SetModel(tower3.model)
	end
	
	local statustext = "Cost: $"..string.Comma(tower3.cost)
	
	local trace = self:BuildTraceData(LocalPlayer())
	if trace.Hit then
		self.ClientsideModel:SetPos(trace.HitPos)
		self.ClientsideModel.RenderOverride = function(self)
			self:DrawModel()
			if tower3.range < 16384 and ConR:GetBool() then
				local fadeout = ConT:GetFloat()
				self.DrawFadeNext = RealTime()+fadeout+ConH:GetFloat()
				if (self.DrawFadeNext or 0)>RealTime() then
					local scol = self:GetColor() == color_aqua and tower3.infinite and color_blue or self:GetColor()
					local alpha = math.Clamp(math.Remap(self.DrawFadeNext-RealTime(),fadeout,0,ConA:GetFloat(),0),0,ConA:GetFloat())
					scol = Color(scol.r,scol.g,scol.b,alpha)
					render.DrawWireframeSphere(self:LocalToWorld(tower3.losoffset),-tower3.range,16,9,scol,true)
				end
			end
		end
		local tempang = EyeAngles()
		tempang.p = 0
		tempang.r = 0
		self.ClientsideModel:SetAngles(tempang)
		
		if self:GetServerMentionBlock() then
			self.ClientsideModel:SetColor(color_red)
			statustext = "Placement is illegal!"
		elseif (ply:GetShootPos():DistToSqr(trace.HitPos) <= 65536 and tower3.cost <= cash) and self.ClientsideModel:GetColor() ~= color_aqua then
			self.ClientsideModel:SetColor(color_aqua)
		elseif tower3.cost > cash and self.ClientsideModel:GetColor() ~= color_red then
			self.ClientsideModel:SetColor(color_red)
		elseif ply:GetShootPos():DistToSqr(trace.HitPos) > 65536 and self.ClientsideModel:GetColor() ~= color_red then
			self.ClientsideModel:SetColor(color_red)
			statustext = "Too far!"
		end
	end
	
	local anchorx, anchory = ScrW()/3, ScrH()/2
	local font1, font2 = "CloseCaption_Normal", "Trebuchet18"
	local width, height = draw.SimpleTextOutlined(tower3.name, font1, anchorx, anchory, tower3.cost > cash and color_red or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
	if tower1 then
		draw.SimpleTextOutlined(tower1.name, font1, anchorx, anchory-height*2, tower1.cost > cash and color_red_dark or color_gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
	end
	if tower2 then
		draw.SimpleTextOutlined(tower2.name, font1, anchorx, anchory-height, tower2.cost > cash and color_red_dark or color_gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
	end
	if tower4 then
		draw.SimpleTextOutlined(tower4.name, font1, anchorx, anchory+height, tower4.cost > cash and color_red_dark or color_gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
	end
	if tower5 then
		draw.SimpleTextOutlined(tower5.name, font1, anchorx, anchory+height*2, tower5.cost > cash and color_red_dark or color_gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
	end
	
	anchorx, anchory = ScrW()/2, ScrH()/4
	draw.SimpleTextOutlined("Sprint+Secondary: Backward", font1, anchorx, anchory, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
	draw.SimpleTextOutlined("Secondary: Forward", font1, anchorx, anchory-height, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
	
	anchorx, anchory = ScrW()/2, ScrH()*3/4
	draw.SimpleTextOutlined(statustext, font1, anchorx, anchory, self.ClientsideModel:GetColor().r==255 and color_red or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	
	anchorx, anchory = ScrW()*2/3, ScrH()/2
	draw.SimpleTextOutlined("Damage: "..tower3.damage/10, font1, anchorx, anchory-height, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
	draw.SimpleTextOutlined("Fire Rate: "..math.Round(tower3.firerate,2).."/s", font1, anchorx, anchory, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
	draw.SimpleTextOutlined("Range: "..tower3.range.." Hu", font1, anchorx, anchory+height, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
end

function SWEP:Holster()
	if IsValid(self.ClientsideModel) then
		self.ClientsideModel:Remove()
	end
	if IsValid(self.ServersideModel) then
		self.ServersideModel:Remove()
	end
	return true
end

function SWEP:OnRemove()
	if IsValid(self.ClientsideModel) then
		self.ClientsideModel:Remove()
	end
	if IsValid(self.ServersideModel) then
		self.ServersideModel:Remove()
	end
end

function SWEP:PrimaryAttack()
	--self.Weapon:SetNextPrimaryFire(CurTime()+1)
	if not IsFirstTimePredicted() then return end
	if IsValid(self.Owner) and SERVER then
		local ply = self.Owner
		local trace = self:BuildTraceData(ply)
		if (trace.Hit and ply:GetShootPos():DistToSqr(trace.HitPos) <= 65536) then
			if not self.TowerTable then
				self.TowerTable = self:BuildTowerTable()
			end
			local tempang = ply:GetAngles()
			tempang.p = 0
			tempang.r = 0
			if ply:IsNPC() then
				self:SetCurrentTower(math.random(#self.TowerTable)-1)
			end
			local tower = ents.Create(self.TowerTable[self:GetCurrentTower()+1].class)
			tower:SetPos(trace.HitPos)
			tower:SetAngles(tempang)
			tower:SetTowerOwner(self.Owner)
			tower:Spawn()
			--util.ScreenShake(self.Owner:GetShootPos(), 4, 20, 0.5, 64)
			tower:EmitSound("phx/epicmetal_soft"..math.random(7)..".wav",60,100,0.5,CHAN_WEAPON)
		end
	end
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	local shft = self.Owner:IsNPC() and 1 or self.Owner:KeyDown(IN_SPEED) and -1 or 1
	self:SetCurrentTower( (self:GetCurrentTower()+shft) % #self.TowerTable)
	self.Weapon:EmitSound("weapons/pistol/pistol_empty.wav",60,100,1,CHAN_WEAPON)
end