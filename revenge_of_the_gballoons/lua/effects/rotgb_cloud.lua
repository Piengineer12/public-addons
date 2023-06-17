-- base effect for tower-induced clouds with framerate correction

-- entity: the tower that created the cloud
-- origin: where the cloud is
-- scale: the size of the cloud
-- magnitude: how many seconds the cloud lasts - if 0, the cloud lasts forever
-- start: the color of the cloud - x, y and z components are shoved into the Color function
-- damagetype: if this is a valid EntIndex, the particles after being positioned will be parented to that entity

local particleDelay = 0.015

function EFFECT:Init(data)
	self.KillTime = CurTime() + data:GetMagnitude()
	self.LastRenderCurTime = CurTime()
	if data:GetMagnitude() == 0 then
		self.KillTime = math.huge
	end
	self.Emitter = ParticleEmitter(data:GetOrigin(), false)
	self.Tower = data:GetEntity()
	self.Velocity = data:GetScale() * 96
	self.Color = Color(data:GetStart():Unpack())
	
	local balloon = Entity(data:GetDamageType())
	if IsValid(balloon) then
		self.Balloon = balloon
		self.Offset = data:GetOrigin() - balloon:GetPos()
	end
end
function EFFECT:Think()
	local curTime = CurTime()
	
	if self:ShouldLive() then
		-- we create new particles based on CurTime, NOT RealTime
		if self.LastRenderCurTime < curTime then
			-- how many?
			local particlesToAdd = math.floor((curTime - self.LastRenderCurTime) / particleDelay)
			self.LastRenderCurTime = self.LastRenderCurTime + particlesToAdd * particleDelay
			
			self:AddParticles(particlesToAdd)
		end
		
		return true
	else
		self.Emitter:Finish()
		return false
	end
end
function EFFECT:Render()
	-- this doesn't really work for our case
end

function EFFECT:ShouldLive()
	return self.KillTime >= CurTime() and IsValid(self.Tower) and (not self.Offset or IsValid(self.Balloon))
end
function EFFECT:AddParticles(num)
	for i=1, num do
		local position = self.Offset and self.Balloon:GetPos() + self.Offset or self.Emitter:GetPos()
		local particle = self.Emitter:Add("particle/smokestack", position)
		if particle then
			-- FIXME: Is this really the best velocity?
			particle:SetDieTime(1)
			particle:SetStartSize(8)
			particle:SetEndSize(8)
			
			particle:SetColor(self.Color.r, self.Color.g, self.Color.b)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetLighting(false)
			
			particle:SetVelocity(VectorRand(-self.Velocity, self.Velocity))
			particle:SetCollide(false)
			particle:SetRoll(math.random()*math.pi*2)
			particle:SetRollDelta(Lerp(math.random(), -math.pi, math.pi))
			particle:SetAirResistance(32)
		end
	end
end