AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Coin"
ENT.Purpose			= "Dropped by enemies. Increases coin count."
ENT.Instructions	= "Touch to pick up."
ENT.Category		= "Insane Stats"
ENT.Author			= "Piengineer12"
ENT.Contact			= "https://steamcommunity.com/id/Piengineer12"
ENT.Spawnable		= true
ENT.AdminOnly		= true
ENT.LifeTime		= 60
ENT.DefaultModel	= Model("models/mechanics/wheels/wheel_rounded_36s.mdl")
ENT.LegacyModels	= {
	Model("models/pipann/jewels/asscher_cut.mdl"),
	Model("models/pipann/jewels/baguette_cut.mdl"),
	Model("models/pipann/jewels/cushion_cut.mdl"),
	Model("models/pipann/jewels/emerald_cut.mdl"),
	Model("models/pipann/jewels/heart_cut.mdl"),
	Model("models/pipann/jewels/marquise_cut.mdl"),
	Model("models/pipann/jewels/oval_cut.mdl"),
	Model("models/pipann/jewels/pear_cut.mdl"),
	Model("models/pipann/jewels/princess_cut.mdl"),
	Model("models/pipann/jewels/radiant_cut.mdl"),
	Model("models/pipann/jewels/round_cut.mdl"),
	Model("models/pipann/jewels/trillion_cut.mdl")
}

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "ValueExponent")
end

function ENT:GetSizeMultiplier()
	local valueExponent = self:GetValueExponent()
	return math.abs(1 + valueExponent / (8 + valueExponent / 16))
end

function ENT:SpawnFunction(ply, traceResult, class)
	if traceResult.Hit then
		local ent = ents.Create(class)
		if IsValid(ent) then
			ent:SetValueExponent(math.floor(-math.log(math.random())))
			local spawnPos = traceResult.HitPos + traceResult.HitNormal * 6 * ent:GetSizeMultiplier()
			ent:SetPos(spawnPos)
			ent:Spawn()
			local physobj = ent:GetPhysicsObject()
			if IsValid(physobj) then
				physobj:SetVelocity(VectorRand(-128, 128))
			end
			return ent
		end
	end
end

function ENT:Initialize()
	if SERVER then
		local sizeMultiplier = self:GetSizeMultiplier()
		local model = self.DefaultModel
		local modelModified = false

		if InsaneStats:GetConVarValue("coins_legacy") then
			local desiredModel = self.LegacyModels[self:GetValueExponent() % 12 + 1]
			if util.IsValidModel(desiredModel) then
				model = desiredModel
				modelModified = true
			end
		end
		self:SetModel(model)
		
		local scale = modelModified and 2 or 0.25
		self:SetModelScale(scale * sizeMultiplier)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetTrigger(true)
		self:SetMaterial("models/shiny")
		self:AddEffects(EF_ITEM_BLINK)
		self:SetColor(InsaneStats:GetCoinColor(self:GetValueExponent()))
		self:DrawShadow(false)
		
		if modelModified then
			self:PhysicsInit(SOLID_VPHYSICS)
			self:UseTriggerBounds(true, 32 / sizeMultiplier)
		else
			self:PhysicsInitSphere(6 * sizeMultiplier, "gmod_bouncy")
			self:UseTriggerBounds(true, 128)
		end
		
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			if modelModified then
				physobj:SetMaterial("gmod_bouncy")
			end
			physobj:SetDamping(0.5, 0.5)
			physobj:SetMass(128)
			physobj:Wake()
		end
		
		if modelModified then
			self:Activate()
		end
	end
end

function ENT:Think()
	if SERVER then
		local livedTime = CurTime() - self:GetCreationTime()
		if livedTime > self.LifeTime then
			local effectData = EffectData()
			effectData:SetEntity(self)
			effectData:SetScale(1)
			effectData:SetMagnitude(3)
			effectData:SetRadius(100)
			effectData:SetOrigin(self:GetPos())
			util.Effect("Sparks", effectData)
			self:Remove()
		end

		for i,v in ipairs(player.GetAll()) do
			local sizeMultiplier = self:GetSizeMultiplier()
			local maxdist = 144 * sizeMultiplier * sizeMultiplier
			if self:GetPos():DistToSqr(v:GetPos()) <= maxdist and v:Alive() then
				self:Pickup(v)
			end
		end
	end
end

function ENT:Draw()
	local shouldDraw = true
	local livedTime = CurTime() - self:GetCreationTime()
	if livedTime > self.LifeTime - 10 then
		local dispFactor = math.Remap(livedTime, self.LifeTime - 10, self.LifeTime, 10, 3)
		if 200/dispFactor%1 < 0.5 then
			shouldDraw = false
		end
	end

	if shouldDraw then
		if self:GetModel() == self.DefaultModel then
			local matrix = Matrix()
			matrix:Rotate(self:GetAngles())
			matrix:Invert()
			matrix:Rotate(Angle(90, CurTime()*360%360, 0))
			self:EnableMatrix("RenderMultiply", matrix)
		end
		self:SetColor(InsaneStats:GetCoinColor(self:GetValueExponent()))
		self:DrawModel()
	end
end

function ENT:StartTouch(ply)
	self:Pickup(ply)
end

function ENT:Pickup(ply)
	if SERVER and (IsValid(ply) and ply:IsPlayer()) and IsValid(self) then
		local valueExponent = self:GetValueExponent()
		local denomDist = InsaneStats:GetConVarValue("coins_denomination_mul")
		ply:InsaneStats_AddCoins(denomDist^valueExponent)
		ply:InsaneStats_SetLastCoinTier(math.Clamp(valueExponent, -1, 254))
		self:EmitSound("insane_stats/xylophoneaccept1.wav")
		self:Remove()
	end
end