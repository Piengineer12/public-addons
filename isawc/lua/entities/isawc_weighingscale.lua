ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Weighing Scale"
ENT.Category = "ISAWC"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Displays the mass, volume and count of entities."
ENT.Instructions = "Put something on this entity."
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Spawnable = true
ENT.WeightedEntities = {}

AddCSLuaFile()

function ENT:SetupDataTables()
	self:NetworkVar("Float",0,"MassDisplay")
	self:NetworkVar("Float",1,"VolumeDisplay")
	self:NetworkVar("Int",0,"CountDisplay")
end

function ENT:SpawnFunction(ply,trace,classname)
	if not trace.Hit then return end
	
	local ent = ents.Create(classname)
	ent:Spawn()
	ent:Activate()
	ent:SetPos(trace.HitPos-trace.HitNormal*ent:OBBMins().z)
	local ang = ply:GetAngles()
	ang.p = 0
	ang.y = ang.y - 90
	ent:SetAngles(ang)
	
	return ent
end

function ENT:Initialize()
	self:SetModel("models/hunter/tubes/circle2x2.mdl")
	self:SetMaterial("maxofs2d/models/motion_sensor_lens")
	if SERVER then
		self:SetTrigger(true)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:SetMass(100)
			physobj:Wake()
		end
		if WireLib then
			self.Outputs = WireLib.CreateSpecialOutputs(self,
				{"Mass", "Volume", "Count"},
				{"NORMAL", "NORMAL", "NORMAL"}
			)
			local baseClass = baseclass.Get("base_wire_entity")
			self.OnRemove = baseClass.OnRemove
			self.OnRestore = baseClass.OnRestore
			self.BuildDupeInfo = baseClass.BuildDupeInfo
			self.ApplyDupeInfo = baseClass.ApplyDupeInfo
			self.PreEntityCopy = baseClass.PreEntityCopy
			self.OnEntityCopyTableFinish = baseClass.OnEntityCopyTableFinish
			self.OnDuplicated = baseClass.OnDuplicated
			self.PostEntityPaste = baseClass.PostEntityPaste
		end
	end
end

function ENT:Think()
	if SERVER then
		local TotalMass, TotalVolume, TotalCount = 0,0,0
		for ent, data in pairs(self.WeightedEntities) do
			if IsValid(ent) then
				if not data[1] then
					data[1], data[2], data[3] = ISAWC:CalculateEntitySpace(ent)
				end
				TotalMass = TotalMass + data[1]
				TotalVolume = TotalVolume + data[2]
				TotalCount = TotalCount + data[3]
			else
				self.WeightedEntities[ent] = nil
			end
		end
		if self:GetMassDisplay()~=TotalMass then
			self:SetMassDisplay(TotalMass)
			if WireLib then
				Wire_TriggerOutput(self, "Mass", self:GetMassDisplay())
			end
		end
		if self:GetVolumeDisplay()~=TotalVolume then
			self:SetVolumeDisplay(TotalVolume)
			if WireLib then
				Wire_TriggerOutput(self, "Volume", self:GetVolumeDisplay() * ISAWC.dm3perHu)
			end
		end
		if self:GetCountDisplay()~=TotalCount then
			self:SetCountDisplay(TotalCount)
			if WireLib then
				Wire_TriggerOutput(self, "Count", self:GetCountDisplay())
			end
		end
		
		--[[local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			if physobj:IsMotionEnabled() and next(self.WeightedEntities) then
				physobj:EnableMotion(false)
			elseif not (physobj:IsMotionEnabled() or next(self.WeightedEntities)) then
				physobj:EnableMotion(true)
			end
		end]]
	end
end

function ENT:Use(activator, caller)
	if activator:IsPlayer() then
		local text1 = string.format("Mass: %.2f kg", self:GetMassDisplay())
		local text2 = string.format("Volume: %.2f dm³", self:GetVolumeDisplay() * ISAWC.dm3perHu)
		local text3 = string.format("Count: %i", self:GetCountDisplay())
		activator:PrintMessage(HUD_PRINTTALK, text1)
		activator:PrintMessage(HUD_PRINTTALK, text2)
		activator:PrintMessage(HUD_PRINTTALK, text3)
	end
end

function ENT:StartTouch(ent)
	if not self.WeightedEntities[ent] then
		self.WeightedEntities[ent] = {}
	end
end

function ENT:EndTouch(ent)
	self.WeightedEntities[ent] = nil
end

local displayOffset = Vector(0, -48, 0)

function ENT:DrawTranslucent()
	local text1 = string.format("Mass: %.2f kg", self:GetMassDisplay())
	local text2 = string.format("Volume: %.2f dm³", self:GetVolumeDisplay() * ISAWC.dm3perHu)
	local text3 = string.format("Count: %i", self:GetCountDisplay())
	surface.SetFont("DermaLarge")
	local t1x,t1y = surface.GetTextSize(text1)
	local t2x,t2y = surface.GetTextSize(text2)
	local t3x,t3y = surface.GetTextSize(text3)
	local maxWidth = math.max(t1x, t2x, t3x) + 16
	--[[local reqang = (self:GetPos()-LocalPlayer():GetShootPos()):Angle()
	reqang.p = 0
	reqang.y = reqang.y-90
	reqang.r = 90]]
	cam.Start3D2D(self:LocalToWorld(displayOffset),self:GetAngles(),0.2)
		surface.SetDrawColor(0,0,0,191)
		surface.DrawRect(maxWidth/-2,0,maxWidth,t1y)
		surface.SetTextColor(255, 127, 127)
		surface.SetTextPos(t1x/-2,0)
		surface.DrawText(text1)
		
		surface.DrawRect(maxWidth/-2,t1y,maxWidth,t2y)
		surface.SetTextColor(127, 255, 127)
		surface.SetTextPos(t2x/-2,t1y)
		surface.DrawText(text2)
		
		surface.DrawRect(maxWidth/-2,t1y+t2y,maxWidth,t3y)
		surface.SetTextColor(127, 127, 255)
		surface.SetTextPos(t3x/-2,t1y+t2y)
		surface.DrawText(text3)
	cam.End3D2D()
end