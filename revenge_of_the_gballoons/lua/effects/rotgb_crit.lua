function EFFECT:Init(effdata)
	self.KillTime = CurTime() + 0.75
	self.emitter = ParticleEmitter(effdata:GetOrigin(),false)
	if IsValid(self.emitter) then
		local particle = self.emitter:Add("effects/rotgb_crit",effdata:GetOrigin())
		if particle then
			particle:SetAirResistance(0)
			particle:SetBounce(0.5)
			particle:SetCollide(false)
			particle:SetColor(255,127,0)
			particle:SetDieTime(0.75)
			particle:SetEndAlpha(0)
			--particle:SetEndLength(16)
			particle:SetEndSize(16)
			particle:SetGravity(-vector_up*400)
			particle:SetLifeTime(0)
			particle:SetLighting(false)
			particle:SetStartAlpha(255)
			--particle:SetStartLength(16)
			particle:SetStartSize(16)
			particle:SetVelocity(vector_up*300)
		end
	end
end

function EFFECT:Think()
	if self.KillTime<=CurTime() then
		self.emitter:Finish()
		return false
	else return true end
end

function EFFECT:Render()
end