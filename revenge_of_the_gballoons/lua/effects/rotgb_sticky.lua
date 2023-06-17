-- base effect for gBalloons with effects applied with framerate correction

-- entity: the tower that created the effect
-- damagetype: the EntIndex of the balloon
-- magnitude: how many seconds the effect lasts - if 0, the effect lasts forever
-- start: the color of the effect - x, y and z components are shoved into the Color function

local particleDelay = 0.015

function EFFECT:Init(data)
	self.KillTime = CurTime() + data:GetMagnitude()
	self.LastRenderCurTime = CurTime()
	if data:GetMagnitude() == 0 then
		self.KillTime = math.huge
	end
	self.Tower = data:GetEntity()
	self.Color = Color(data:GetStart():Unpack())
	
	local balloon = Entity(data:GetDamageType())
	if IsValid(balloon) then
		self.Balloon = balloon
		self.Emitter = ParticleEmitter(self.Balloon:WorldSpaceCenter(), false)
	end
end
function EFFECT:Think()
	local curTime = CurTime()
	
	if self:ShouldLive() then
		self.Emitter:SetPos(self.Balloon:WorldSpaceCenter())
		-- we create new particles based on CurTime, NOT RealTime
		if self.LastRenderCurTime < curTime then
			-- how many?
			local particlesToAdd = math.floor((curTime - self.LastRenderCurTime) / particleDelay)
			self.LastRenderCurTime = self.LastRenderCurTime + particlesToAdd * particleDelay
			
			self:AddParticles(particlesToAdd)
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
	-- this doesn't really work for our case
end

function EFFECT:ShouldLive()
	return self.KillTime >= CurTime() and IsValid(self.Tower) and IsValid(self.Balloon)
end
function EFFECT:AddParticles(num)
	for i=1, num do
		local position = VectorRand(self.Balloon:WorldSpaceAABB())
		local particle = self.Emitter:Add("sprites/glow04_noz_gmod", position)
		if particle then
			-- FIXME: Is this really the best velocity?
			particle:SetDieTime(2)
			particle:SetStartSize(4)
			particle:SetEndSize(0)
			
			particle:SetColor(self.Color.r, self.Color.g, self.Color.b)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetLighting(false)
			
			particle:SetCollide(true)
			particle:SetBounce(0.2)
			particle:SetGravity(physenv.GetGravity())
			particle:SetRoll(math.random()*math.pi*2)
		end
	end
end