function EFFECT:Init(effdata)
	self.KillTime = CurTime() + effdata:GetMagnitude()
	self.tower = effdata:GetEntity()
	
	if IsValid(self.tower) then
		local showPos = self:GetShowPos()
		local emitter = ParticleEmitter(showPos, false)
		
		if IsValid(emitter) then
			local particleThinkFunction = function(...)
				if IsValid(self) then
					self:ParticleThink(...)
				end
			end
			
			local particle = emitter:Add("effects/rotgb_stunned", showPos)
			if particle then
				particle:SetDieTime(effdata:GetMagnitude())
				particle:SetStartSize(16)
				particle:SetEndSize(0)
				
				particle:SetColor(255, 255, 0)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(255)
				particle:SetLighting(false)
				
				particle:SetCollide(false)
			
				particle:SetNextThink(CurTime())
				particle:SetThinkFunction(particleThinkFunction)
			end
			
			emitter:Finish()
		end
	end
end

function EFFECT:Think()
	return self.KillTime > CurTime()
end

function EFFECT:Render()
end

function EFFECT:GetShowPos()
	return self.tower:LocalToWorld(Vector(0, 0, ROTGB_GetConVarValue("rotgb_hoverover_distance") + self.tower:OBBMaxs().z))
end

function EFFECT:ParticleThink(particle)
	if IsValid(self.tower) then
		particle:SetPos(self:GetShowPos())
		particle:SetNextThink(CurTime())
	end
end