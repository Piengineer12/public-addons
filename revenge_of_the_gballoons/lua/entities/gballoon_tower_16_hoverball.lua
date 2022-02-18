-- this is adapted from gmod_hoverball.lua, needed to make sure this works even when not in Sandbox
AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "TargetZ")
end

function ENT:Initialize()
	if CLIENT then
		self.Glow = Material("sprites/light_glow02_add")
	end
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		
		local physObj = self:GetPhysicsObject()
		if IsValid(physObj) then
			physObj:EnableGravity(false)
			physObj:Wake()
		end

		-- Start the motion controller (so PhysicsSimulate gets called)
		self:StartMotionController()

		self:SetTargetZ(self:GetPos().z)
		self.rotgb_Collectable = true
		self:SetTrigger(true)
	end
end

function ENT:Think()
	if self.rotgb_Collectable then
		for k,v in pairs(player.GetAll()) do
			if self:WorldSpaceCenter():DistToSqr(v:WorldSpaceCenter()) <= self.rotgb_Range^2 then
				self.rotgb_Collectable = false
				self:SetTrigger(false)
				self:SetNotSolid(true)
				self:SetMoveType(MOVETYPE_NONE)
				self:SetNoDraw(true)
				local effdata = EffectData()
				effdata:SetEntity(self)
				util.Effect("entity_remove",effdata,true,true)
				self:GiveCash()
				SafeRemoveEntityDelayed(self,1)
			end
		end
	end
end

function ENT:StartTouch(ent)
	if (IsValid(ent) and ent:IsPlayer()) and self.rotgb_Collectable then
		self.rotgb_Collectable = false
		self:SetTrigger(false)
		self:SetNotSolid(true)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetNoDraw(true)
		local effdata = EffectData()
		effdata:SetEntity(self)
		util.Effect("entity_remove",effdata,true,true)
		self:GiveCash()
		SafeRemoveEntityDelayed(self,1)
	end
end

function ENT:OnRemove()
	self:GiveCash()
end

function ENT:GiveCash()
	if self.rotgb_Value then
		if IsValid(self.rotgb_Tower) then
			self.rotgb_Tower:AddCash(self.rotgb_Value, self.rotgb_Tower:GetTowerOwner())
		else
			ROTGB_AddCash(self.rotgb_Value*ROTGB_GetConVarValue("rotgb_cash_mul")*ROTGB_GetConVarValue("rotgb_tower_income_mul"))
		end
		self.rotgb_Value = 0
	end
end

function ENT:DrawEffects()
	local vOffset = self:GetPos()
	local vDiff = (vOffset - LocalPlayer():EyePos()):GetNormalized()

	render.SetMaterial(self.Glow)
	local color = Color(70, 180, 255, 255)
	render.DrawSprite(vOffset - vDiff * 2, 22, 22, color)

	local distance = math.abs((self:GetTargetZ() - self:GetPos().z) * math.sin(CurTime() * 20)) * 0.05
	color.r = color.r * math.Clamp(distance, 0, 1)
	color.b = color.b * math.Clamp(distance, 0, 1)
	color.g = color.g * math.Clamp(distance, 0, 1)

	render.DrawSprite(vOffset + vDiff * 4, 48, 48, color)
	render.DrawSprite(vOffset + vDiff * 4, 52, 52, color)
end

-- We have to do this to ensure DrawTranslucent is called for Opaque only models to draw our effects
ENT.RenderGroup = RENDERGROUP_BOTH
function ENT:DrawTranslucent(flags)
	self:DrawEffects()
	self:Draw(flags)
end

function ENT:PhysicsSimulate(phys, deltatime)
	phys:Wake()
	
	local distance = self:GetTargetZ() - phys:GetPos().z
	if distance == 0 then return end

	local exponent = distance * distance
	if distance < 0 then
		exponent = exponent * -1
	end

	exponent = math.Clamp(exponent * deltatime * 300 - phys:GetVelocity().z * deltatime * 600, -5000, 5000)

	return vector_origin, Vector(0, 0, exponent), SIM_GLOBAL_ACCELERATION
end

function ENT:SetStrength(strength)
	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:SetMass(150 * strength)
	end
end