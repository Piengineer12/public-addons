ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Chest"
ENT.Category = "Containers - MC"

AddCSLuaFile()

ENT.ContainerModel = Model("models/mcmodelpack/entities/chest-new.mdl")
ENT.Spawnable = util.IsValidModel("models/mcmodelpack/entities/chest-new.mdl")
ENT.ContainerMassMul = 3
ENT.ContainerConstants = {
	Mass = 60,
	Volume = 65
}
ENT.OpenAnimTime = 1/3
ENT.CloseAnimTime = 1/3
ENT.OpenSounds = {Sound("chest/open.wav")}
ENT.CloseSounds = {Sound("chest/close.wav"),Sound("chest/close2.wav"),Sound("chest/close3.wav")}

function ENT:ISAWC_Initialize()
	if SERVER then -- physics were initiated improperly because it is supposed to be a ragdoll.
		self:PhysicsInitBox(Vector(-16,-16,0),Vector(16,16,32))
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:EnableCustomCollisions(true) -- ...but now the context menu is broken. we'll fix that below.
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:SetMass(20.9457216262817)
			physobj:Wake()
		end
		--self:SetUnFreezable(true)
		self:CollisionRulesChanged()
	end
end

function ENT:TestCollision(start,delta,isbox,extent,mask)
	if mask>0 then
		local hitpos,normal,fraction = util.IntersectRayWithOBB(start,delta,self:GetPos(),self:GetAngles(),self:GetCollisionBounds())
		return {HitPos=hitpos,Fraction=fraction,Normal=normal}
	end
end

function ENT:OpenAnim(delta)
	local roll = math.Remap(math.EaseInOut(delta,0,1),0,1,0,-90)
	self:ManipulateBoneAngles(1,Angle(0,0,roll))
end

function ENT:CloseAnim(delta)
	local roll = math.Remap(math.EaseInOut(delta,1,0),0,1,-90,0)
	self:ManipulateBoneAngles(1,Angle(0,0,roll))
end