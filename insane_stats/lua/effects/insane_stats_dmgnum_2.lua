-- the only purpose of this is to create particles
-- for number positioning purposes

function EFFECT:Init(effdata)
	self.Player = LocalPlayer()
	self.KillTime = CurTime() + effdata:GetMagnitude()
	if IsValid(self.Player) then
		self.Emitter = ParticleEmitter(self.Player:GetShootPos(), false)
	end
	InsaneStats.DamageNumberEntity = self
end

function EFFECT:Think()
	local curTime = CurTime()
	if self.KillTime >= curTime and IsValid(self.Emitter) and IsValid(self.Player) then
		self.Emitter:SetPos(self.Player:GetShootPos())
		return true
	else
		if IsValid(self.Emitter) then
			self.Emitter:Finish()
		end
		return false
	end
end

function EFFECT:CreateParticle(pos, lifeTime)
	if IsValid(self.Emitter) and IsValid(self.Player) then
		self.KillTime = math.max(self.KillTime, CurTime() + lifeTime)

		local particle = self.Emitter:Add("effects/softglow", pos)
		if particle then
			local scatter = pos:DistToSqr(self.Player:GetShootPos()) ^ 0.5 / 4
			local gravity = physenv.GetGravity() * scatter / 256

			particle:SetAirResistance(0)
			particle:SetBounce(.5)
			particle:SetCollide(true)
			particle:SetDieTime(lifeTime)
			particle:SetEndAlpha(0)
			particle:SetGravity(gravity)
			particle:SetLighting(false)
			particle:SetStartAlpha(0)
			particle:SetVelocity(VectorRand(-scatter, scatter) - gravity / 2)

			return particle
		end
	end
end

function EFFECT:Render()
end