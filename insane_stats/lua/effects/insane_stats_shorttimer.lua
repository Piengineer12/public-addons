local materials

function EFFECT:GetParticleMaterial(particle)
	if not materials then
		materials = {}
		for i=0, 9 do
			materials[i] = Material(string.format("sprites/key_%u", i))
		end
	end
	local timeLeft = particle and particle:GetDieTime() - particle:GetLifeTime() or self.KillTime - CurTime()
	return materials[math.Clamp(math.ceil(timeLeft), 0, 9)]
end

function EFFECT:Init(effdata)
	self.LifeTime = effdata:GetMagnitude()
	self.KillTime = CurTime() + self.LifeTime
	self.Origin = effdata:GetOrigin()
	self.Emitter = ParticleEmitter(self.Origin, false)
	self.Size = effdata:GetRadius()
	self.CurrentMaterial = self:GetParticleMaterial()

	if IsValid(self.Emitter) then
		local particle = self.Emitter:Add(self.CurrentMaterial, self.Origin)
		if particle then
			particle:SetCollide(false)
			particle:SetDieTime(self.LifeTime)
			particle:SetEndAlpha(255)
			particle:SetEndSize(self.Size)
			particle:SetLighting(false)
			particle:SetStartAlpha(255)
			particle:SetStartSize(self.Size)
			--[[particle:SetThinkFunction(function(particle)
				if IsValid(self) then
					particle:SetMaterial(GetParticleMaterial(particle))
					particle:SetNextThink(CurTime() + (1-particle:GetLifeTime()) % 1)
				end
			end)]]

			self.Particle = particle
		end
	end
end

function EFFECT:Think()
	local curTime = CurTime()
	
	if self.KillTime >= curTime then
		if self.Particle then
			local nextMaterial = self:GetParticleMaterial(particle)
			if self.CurrentMaterial ~= nextMaterial then
				self.CurrentMaterial = nextMaterial
				self.Particle:SetMaterial(nextMaterial)
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