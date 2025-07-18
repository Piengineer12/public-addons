local particleDelay = 0.015
local lifeTime = 1
local color_gray = InsaneStats:GetColor("gray")
local color_dark_green = InsaneStats:GetColor("dark_green")

function EFFECT:Init(effdata)
	self.KillTime = CurTime() + lifeTime
	self.LastRenderCurTime = CurTime()
	self.Entity = effdata:GetEntity()
	self.Particles = 0
	if IsValid(self.Entity) then
		self.Emitter = ParticleEmitter(self.Entity:WorldSpaceCenter(), false)
	end
end

function EFFECT:Think()
	local curTime = CurTime()
	
	if self.KillTime >= curTime then
		if self:ShouldDrawBeam() then
			-- if the entity exists, set the emitter's position to its center
			if IsValid(self.Emitter) then
				self.Emitter:SetPos(self.Entity:WorldSpaceCenter())
			else
				self.Emitter = ParticleEmitter(self.Entity:WorldSpaceCenter(), false)
			end
			
			-- we create new particles based on CurTime, NOT RealTime
			if self.LastRenderCurTime < curTime then
				-- how many?
				local particlesToAdd = math.floor((curTime - self.LastRenderCurTime) / particleDelay)
				self.LastRenderCurTime = self.LastRenderCurTime + particlesToAdd * particleDelay
				self:AddParticles(particlesToAdd)
				--self.Particles = self.Particles + particlesToAdd
			end
		end
		
		return true
	else
		if IsValid(self.Emitter) then
			self.Emitter:Finish()
		end
		return false
	end
end

function EFFECT:Render()
end

function EFFECT:AddParticles(particles)
	for i=1, math.min(particles, 25) do
		-- reminder: particles are NOT entities, otherwise they would hit the object limit extremely fast
		-- the consequence is that particles can't store variables
		local r, g, b = self:GetParticleColor()
		local particle = self.Emitter:Add("effects/laser_tracer", self.Emitter:GetPos())
		particle:SetDieTime(0.2)
		particle:SetStartSize(2)
		particle:SetEndSize(2)
		particle:SetStartLength(32)
		particle:SetEndLength(32)
		particle:SetAirResistance(0)
		particle:SetCollide(false)
		particle:SetVelocity(Vector(0, 0, math.random() * 31 + 1))
		particle:SetGravity(vector_origin)
		particle:SetColor(r, g, b)
		particle:SetStartAlpha(31)
		particle:SetEndAlpha(0)
		particle:SetLighting(false)
		particle:SetNextThink(CurTime())
		particle:SetThinkFunction(function(...)
			if IsValid(self) then
				self:DoParticleThink(...)
			end
		end)
	end

	--self.Particles = 0
end

function EFFECT:ShouldDrawBeam()
	return IsValid(self.Entity) and not IsValid(self.Entity:GetOwner()) and not self.Entity:IsDormant()
end

function EFFECT:GetParticleColor()
	local color = color_black
	
	if self:ShouldDrawBeam() then
		local class = self.Entity:GetClass()
		local healingItemType = self.Entity:InsaneStats_GetHealingItemType()
		
		if healingItemType == 2 then
			color = color_dark_green
		elseif healingItemType == 1 then
			color = color_gray
		elseif self.Entity.insaneStats_Modifiers then
			color = InsaneStats:GetPhasedRarityColor(InsaneStats:GetWPASS2Rarity(self.Entity))
		end
	end
	
	return color.r, color.g, color.b
end

function EFFECT:DoParticleThink(particle)
	local r, g, b = self:GetParticleColor()
	particle:SetColor(r, g, b)
	particle:SetNextThink(CurTime())
	--[[if IsValid(self.Emitter) then
		particle:SetPos(self.Emitter:GetPos())
	end]]
end