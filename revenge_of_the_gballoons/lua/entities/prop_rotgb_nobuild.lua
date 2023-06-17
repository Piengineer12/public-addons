AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "RotgB Nobuild Prop"
ENT.Purpose = "Defines an area where towers can't be placed."
ENT.Instructions = "Set a model, then this entity will disallow towers to be placed within it."
ENT.Category = "#rotgb.category.miscellaneous"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.DisableDuplicator = false

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"Disabled")
end

function ENT:KeyValue(key,value)
	if key:lower()=="start_disabled" then
		self.TempDisabled = tobool(value)
	end
end

function ENT:AcceptInput(input,activator,caller,data)
	input = input:lower()
	if input=="enable" then
		self:SetDisabled(false)
	elseif input=="disable" then
		self:SetDisabled(true)
	elseif input=="toggle" then
		self:SetDisabled(not self:GetDisabled())
	end
end

function ENT:SpawnFunction(ply,trace,classname)
	if not trace.Hit then return end
	
	local ent = ents.Create(classname)
	ent:SetPos(trace.HitPos+trace.HitNormal*5)
	ent:SetModel("models/hunter/blocks/cube1x1x1.mdl")
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:Initialize()
	if SERVER then
		self:SetMaterial("!gBalloonDamage")
		self:SetColor(Color(255,0,0,127))
		self:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetTrigger(true)
		self:SetDisabled(tobool(self.TempDisabled))
		
		local physObj = self:GetPhysicsObject()
		if IsValid(physObj) then
			physObj:EnableMotion(false)
		end
	end
end

function ENT:ToggleSolidity()
	if self:GetNoDraw() then
		self:SetNotSolid(false)
		self:SetNoDraw(false)
	else
		self:SetNotSolid(true)
		self:SetNoDraw(true)
	end
end

function ENT:Touch(ent)
	if not self:GetDisabled() then
		if ent.Base=="gballoon_tower_base" or ent.rotgb_isDetector then
			ent:Stun2(self)
		end
	end
end

function ENT:EndTouch(ent)
	if ent.Base=="gballoon_tower_base" or ent.rotgb_isDetector then
		ent:UnStun2(self)
	end
end

--[[list.Set("SpawnableEntities","prop_rotgb_nobuild",{
	PrintName = "#rotgb.prop_rotgb_nobuild",
	ClassName = "prop_rotgb_nobuild",
	Category = "#rotgb.category.miscellaneous"
})]]