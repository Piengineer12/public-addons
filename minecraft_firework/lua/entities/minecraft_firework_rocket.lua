AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Firework Rocket"
ENT.Author			= "Piengineer"
ENT.Contact			= "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose			= "Launched firework rocket, will explode after some time."
ENT.Instructions	= "How are you reading this?!"
ENT.Category		= "Minecraft"
ENT.Spawnable		= false
ENT.AdminOnly		= false
ENT.RenderGroup		= RENDERGROUP_OTHER

local fireworkModel = "models/mcitems3d_mariro/firework_rocket.mdl"
local altFireworkModel = false
if not util.IsValidModel(fireworkModel) then
	fireworkModel = "models/mcmodelpack/items/rocket.mdl"
	altFireworkModel = true
end

local fireworkRadius = 12
local fireworkTravelVelocity = vector_up * 15
local fireworkTravelWaterVelocity = vector_up * -8

local networkingConstant = 64

util.PrecacheModel(fireworkModel)

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "LifeTime")
end

function ENT:SpawnFunction(ply, trace, class)
	if not trace.Hit then return end
	
	local SpawnPos = trace.HitPos + trace.HitNormal * fireworkRadius 
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y - 90
	SpawnAng.r = -180
	
	local ent = ents.Create(class)
	ent:SetPos(SpawnPos)
	ent:SetAngles(SpawnAng)
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:Initialize()
	if not self.Initialized then
		self.Initialized = true
		self:SetModel("models/hunter/misc/sphere025x025.mdl")
		if SERVER then
			self:SetTrigger(true)
			if self:PhysicsInitSphere(fireworkRadius, "paper") then
				local physobj = self:GetPhysicsObject()
				physobj:Wake()
			end
			self:EmitSound("minecraft/firework_launch.wav", 75, 100, 1, CHAN_WEAPON)
		end
		if CLIENT then
			self:CheckProxyModel()
			local effdata = EffectData()
			effdata:SetOrigin(self:GetPos())
			effdata:SetEntity(self)
			effdata:SetDamageType(0xFFFFFF)
			effdata:SetMagnitude(networkingConstant)
			effdata:SetRadius(networkingConstant)
			effdata:SetScale(1)
			effdata:SetHitBox(1)
			effdata:SetFlags(192)
			effdata:SetStart(Vector(-1, 0, 0))
			util.Effect("minecraft_firework_explosion", effdata)
		end
	end
end

function ENT:Think()
	if not self.Initialized then
		self:Initialize()
	end
	if SERVER then
		local physobj = self:GetPhysicsObject()
		local parent = self:GetParent()
		if IsValid(parent) then
			if (parent:IsPlayer() and not parent:Alive()) then
				self:ExplodeEffect()
				self:Remove()
			elseif (PPM2 and parent:IsPlayer() and parent:IsPonyCached()) then -- this may get interesting!
				local data = parent:GetPonyData()
				if (data and data:GetFly()) then -- use a very different velocity of moving
					parent:SetVelocity(parent:GetAimVector() / 2)
				else
					parent:SetVelocity(parent:GetAimVector() * 15)
				end
			else
				parent:SetVelocity(parent:GetAimVector() * 15)
			end
		elseif IsValid(physobj) then
			if self:WaterLevel() > 2 then
				physobj:AddVelocity(fireworkTravelWaterVelocity)
			else
				physobj:AddVelocity(fireworkTravelVelocity)
			end
		end
		if CurTime() - self:GetCreationTime() > self:GetLifeTime() then
			self:ExplodeEffect()
			self:Remove()
		end
		self:NextThink(CurTime())
		return true
	end
	if CLIENT then
		if self:CheckProxyModel() then
			--[[if IsValid(self:GetParent()) and not self.ClientModel.NoShow then
				self.ClientModel:SetNoDraw(true)
				self.ClientModel.NoShow = true
			else
				if self.ClientModel.NoShow then
					self.ClientModel:SetNoDraw(false)
					self.ClientModel.NoShow = false
				end]]
				self.ClientModel:SetPos(self:GetPos())
				local fAng = self:EyeAngles()
				if IsValid(self:GetParent()) then
					fAng = self:GetParent():EyeAngles()
					if altFireworkModel then
						fAng.p = -90 - fAng.p
						fAng.y = fAng.y + 180
						fAng.r = 0
					else
						fAng.y = fAng.y - 90
						fAng.r = 90 - fAng.p
						fAng.p = 0
					end
				else
					fAng.p = 0
					if altFireworkModel then
						fAng.y = fAng.y - 90
						fAng.r = 0
					else
						fAng.r = -180
					end
				end
				self.ClientModel:SetAngles(fAng)
			--end
		end
	end
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() or ent:IsNPC() then
		self:ExplodeEffect()
		self:Remove()
	end
end

local FireworkShapes = {
	{"Sphere", 0},
	{"Star", 17},
	{"Creeper", 18},
	{"Burst", 1},
	{"Lone Star", 19},
	{"Cube", 16},
	{"Atom", 2},
	{"Arch", 3}
}

function ENT:ExplodeEffect()
	local physobj = self:GetPhysicsObject()
	local highest = 0
	local playedsound = false
	for k,v in pairs(self.FireworkStars or {}) do
		local shape = FireworkShapes[v.Shape or 0] and FireworkShapes[v.Shape][2] or 0
		local particleMul = v.ParticleMul or 1
		local radiusMul = v.RadiusMul or 1
		highest = math.max(highest, radiusMul)
		local flags = bit.bor(v.Flicker and 1 or 0, v.Trail and 2 or 0, playedsound and 64 or 0)
		playedsound = true
		local totalColors = #v.Colors
		for k2,v2 in ipairs(v.Colors) do
			local effdata = EffectData()
			effdata:SetOrigin(self:GetPos())
			effdata:SetAttachment(shape)
			effdata:SetDamageType(bit.bor(bit.lshift(v2[1].r, 16), bit.lshift(v2[1].g, 8), v2[1].b))
			effdata:SetMagnitude(particleMul * networkingConstant)
			effdata:SetRadius(radiusMul * networkingConstant)
			effdata:SetScale(1)
			effdata:SetHitBox(totalColors)
			effdata:SetSurfaceProp(k2-1)
			effdata:SetFlags(flags)
			effdata:SetStart(v2[2] and Vector(v2[2].r, v2[2].g, v2[2].b) or Vector(-1, 0, 0))
			if IsValid(physobj) then
				local vel = physobj:GetVelocity()
				effdata:SetMaterialIndex(math.min(math.ceil(vel:Length()), 4095))
				vel:Normalize()
				effdata:SetNormal(vel)
			end
			local fAng = self:GetAngles()
			fAng.p = 0
			fAng.r = 0
			effdata:SetAngles(fAng)
			util.Effect("minecraft_firework_explosion", effdata)
			flags = bit.bor(flags, 64)
		end
	end
	--print(128 * highest, 25 + #(self.FireworkStars or {}) * 10)
	local creditEntity = IsValid(self:GetCreator()) and self:GetCreator() or self
	local detonationCount = #(self.FireworkStars or {})
	if detonationCount > 0 then
		util.BlastDamage(self, creditEntity, self:GetPos(), 128 * highest, 25 + detonationCount * 10)
	end
end

function ENT:CheckProxyModel()
	if not IsValid(self.ClientModel) then
		self.ClientModel = ClientsideModel(fireworkModel, RENDERGROUP_OPAQUE)
	end
	return IsValid(self.ClientModel)
end

--[[function ENT:Draw()
	if self:CheckProxyModel() and not IsValid(self:GetParent()) then
		self.ClientModel:DrawModel()
	end
end]]

function ENT:OnRemove()
	if IsValid(self.ClientModel) then
		self.ClientModel:Remove()
	end
end