-- The entity may be NULL clientside, best not to take risks...
function EFFECT:DetermineColour(bits)
	if bits==1 then return 255,255,255 -- frost
	elseif bits==2 then return 0,0,0 -- explosion
	elseif bits==3 then return 127,0,255 -- magic
	elseif bits==4 then return 127,127,127 -- bullet
	elseif bits==5 then return 255,255,0 -- glue (replaced the melee effect)
	elseif bits==6 then return 0,255,255 -- melee (now unused)
	elseif bits==7 then return 255,0,255 -- armor
	elseif bits==8 then return "rainbow" -- glass
	else return 255,0,0 -- invalid
	end
end

function EFFECT:Init(effdata)
	self.KillTime = CurTime() + 4
	self.emitter = ParticleEmitter(effdata:GetOrigin(),false)
	if IsValid(self.emitter) then
		self.particle = self.emitter:Add("effects/rotgb_resist",effdata:GetOrigin())
		if self.particle then
			self.particle:SetAirResistance(0)
			self.particle:SetBounce(0.5)
			self.particle:SetCollide(false)
			if self:DetermineColour(effdata:GetColor()) == "rainbow" then
				self.RainbowParticle = true
			else
				self.particle:SetColor(self:DetermineColour(effdata:GetColor()))
			end
			self.particle:SetDieTime(4)
			self.particle:SetEndAlpha(255)
			--particle:SetEndLength(16)
			self.particle:SetEndSize(16)
			self.particle:SetGravity(-vector_up*100)
			self.particle:SetLifeTime(0)
			self.particle:SetLighting(false)
			self.particle:SetStartAlpha(255)
			--particle:SetStartLength(16)
			self.particle:SetStartSize(16)
			self.particle:SetVelocity(vector_up*150)
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
	if self.RainbowParticle then
		self.particle:SetColor(HSVToColor((CurTime()-self.KillTime)*120%360,1,1):Unpack())
	end 
end