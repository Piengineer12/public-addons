-- just a simple X effect

function EFFECT:Init(effdata)
	local lifeTime = effdata:GetMagnitude()
	self.KillTime = CurTime() + lifeTime
	local origin = effdata:GetOrigin()
	self.Emitter = ParticleEmitter(origin, false)
	local size = effdata:GetRadius()

	if IsValid(self.Emitter) then
		local particle = self.Emitter:Add("sprites/key_12", origin)
		if particle then
			particle:SetCollide(false)
			particle:SetDieTime(lifeTime)
			particle:SetEndAlpha(255)
			particle:SetEndSize(size)
			particle:SetLighting(false)
			particle:SetStartAlpha(255)
			particle:SetStartSize(size)
			particle:SetRoll(math.pi/4)
		end
	end
end

function EFFECT:Think()
	local curTime = CurTime()
	
	if self.KillTime >= curTime then
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