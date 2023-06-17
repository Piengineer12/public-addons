function EFFECT:Init(data)
	self.KillTime = CurTime() + 1
	local isCentral = data:GetFlags() ~= 0 -- there may be several non-centrals for a single central
	self.effectOrigin = data:GetOrigin()
	
	if isCentral then
		self:CreateCentralParticles()
	else
		self.effectStart = data:GetStart()
		self:CreateNonCentralParticles()
	end
	
	ROTGB_Log("Infinity Fusion particle effect created!", "towers")
end

function EFFECT:Think()
	return self.KillTime >= CurTime()
end

function EFFECT:Render()
end

function EFFECT:CreateNonCentralParticles()
	local emitter = ParticleEmitter(self.effectOrigin, false)
	if IsValid(emitter) then
		local particleThinkFunction = function(...)
			if IsValid(self) then
				self:ParticleThink(...)
			end
		end
		
		local particle = emitter:Add("sprites/glow04_noz_gmod", self.effectStart)
		if particle then
			particle:SetDieTime(1)
			particle:SetStartSize(16)
			particle:SetEndSize(16)
			
			particle:SetColor(self:GetParticleColor())
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetLighting(false)
			
			particle:SetCollide(false)
			particle:SetVelocity(self:GetParticleVelocity())
			particle:SetGravity(physenv.GetGravity())
			particle:SetRoll(math.pi*Lerp(math.random(), -1, 1))
			particle:SetRollDelta(math.pi*Lerp(math.random(), -2, 2))
			particle:SetAirResistance(0)
			
			particle:SetNextThink(CurTime())
			particle:SetThinkFunction(particleThinkFunction)
		else
			ROTGB_LogError("Infinity Fusion particle effect failed!", "towers")
		end
		
		emitter:Finish()
	else
		ROTGB_LogError("Infinity Fusion emitter failed!", "towers")
	end
end

function EFFECT:CreateCentralParticles()
	local emitter = ParticleEmitter(self.effectOrigin, false)
	if IsValid(emitter) then
		local particleThinkFunction = function(...)
			if IsValid(self) then
				self:ParticleThink(...)
			end
		end
		
		for i = 1, 4 do
			local particle = emitter:Add("sprites/glow04_noz_gmod", self.effectOrigin)
			if particle then
				particle:SetDieTime(1)
				particle:SetStartSize(16)
				particle:SetEndSize(128)
				
				particle:SetColor(self:GetParticleColor())
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)
				particle:SetLighting(false)
				
				particle:SetCollide(false)
				particle:SetVelocity(vector_origin)
				particle:SetGravity(vector_origin)
				particle:SetRoll(math.pi*Lerp(math.random(), -1, 1))
				particle:SetRollDelta(math.pi*Lerp(math.random(), -2, 2))
				
				particle:SetNextThink(CurTime())
				particle:SetThinkFunction(particleThinkFunction)
			else
				ROTGB_LogError("Infinity Fusion particle effect failed!", "towers")
			end
		end
		
		emitter:Finish()
	else
		ROTGB_LogError("Infinity Fusion emitter failed!", "towers")
	end
end

function EFFECT:ParticleThink(particle)
	particle:SetColor(self:GetParticleColor())
	particle:SetNextThink(CurTime())
end

function EFFECT:GetParticleVelocity()
	local vel = self.effectOrigin - self.effectStart
	local accDiv2 = physenv.GetGravity() / -2
	vel:Add(accDiv2)
	
	return vel
end

function EFFECT:GetParticleColor()
	local col = HSVToColor(RealTime()*60%360, 1, 1)
	return col.r, col.g, col.b
end