ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Base Backpack"
ENT.Category = "Backpacks"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Base backpack for the Inventory System."
ENT.Instructions = "Link this backpack to something."
ENT.AutomaticFrameAdvance = true
ENT.Editable = true

ENT.BackpackModel = Model("models/props_junk/watermelon01.mdl")
ENT.BackpackMassMul = 1
ENT.BackpackVolumeMul = 1
ENT.BackpackCountMul = 10

AddCSLuaFile()

function ENT:SetupDataTables()
	self:NetworkVar("Float",0,"MassMul",{KeyName="isawc_mass_mul",Edit={type="Float",category="Multipliers",title="Mass Mul.",min=0,max=10,order=10}})
	self:NetworkVar("Float",1,"VolumeMul",{KeyName="isawc_volume_mul",Edit={type="Float",category="Multipliers",title="Volume Mul.",min=0,max=10,order=11}})
	self:NetworkVar("Int",1,"CountMul",{KeyName="isawc_count_mul",Edit={type="Int",category="Multipliers",title="Count Amt.",min=0,max=100,order=12}})
	self:NetworkVar("Int",0,"ContainerHealth",{KeyName="isawc_container_health",Edit={type="Int",title="Backpack Health",min=0,max=1000,order=2}})
end

function ENT:SpawnFunction(ply,trace,classname)
	if not trace.Hit then return end
	
	local ent = ents.Create(classname)
	ent:Spawn()
	ent:Activate()
	ent:SetPos(trace.HitPos-trace.HitNormal*ent:OBBMins().z)
	local ang = ply:GetAngles()
	ang.p = 0
	ang.y = ang.y + 180
	ent:SetAngles(ang)
	
	return ent
end

function ENT:ISAWC_Initialize()
end

function ENT:Initialize()
	self:SetModel(self.BackpackModel)
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:Wake()
		end
		self:PrecacheGibs()
	end
	self:SetMassMul(1)
	self:SetVolumeMul(1)
	self:SetCountMul(1)
	self:ISAWC_Initialize()
end

function ENT:Think()
	if SERVER and self.CHealth~=self:GetContainerHealth() then
		self.CHealth = self:GetContainerHealth()
		self:SetHealth(self.CHealth)
		self:SetMaxHealth(self.CHealth)
	end
end