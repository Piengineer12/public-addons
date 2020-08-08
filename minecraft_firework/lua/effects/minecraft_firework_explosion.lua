--[[ CEffectData parameters:

Attachment: Effect shape:
	0 - Sphere
	1 - Burst
	2 - Axial Circles
	3 - Arch
	16 - Cube
	17 - Star
	18 - Creeper
	19 - Lone Star
DamageType: Effect colour, an integer with the format 0xRRGGBB
Flags: Effect flags
	1 - Flicker
	2 - Trail
	64 - No Explosion Sound
	128 - Firework Jet (internal use only!)
HitBox: Only every nth particle is drawn
Magnitude: Effect particle multiplier, 64 is x1, 128 is x2, etc.
MaterialIndex: Effect speed, only for Burst shape
Normal: Effect direction, only for Burst shape
Origin: Effect position
Radius: Effect radius multiplier, 64 is x1, 128 is x2, etc.
Scale: Effect size multiplier
Start: Fade colour, Vector(255, 127, 0) is Color(255, 127, 0)
SurfaceProp: Phase shift for the HitBox parameter

]]

local networkingConstant = 64
local particleFailures = 0
local prevFailMsgTime = 0
local nextFailMsgTime = 0

local pio2, pio4 = math.pi/2, math.pi/4
local pi2 = math.pi*2
local sqrt3 = math.sqrt(3)

local fireworkTextures = {
	Material("effects/minecraft/firework_particle_1"),
	Material("effects/minecraft/firework_particle_1"),
	Material("effects/minecraft/firework_particle_2"),
	Material("effects/minecraft/firework_particle_1"),
	Material("effects/minecraft/firework_particle_2"),
	Material("effects/minecraft/firework_particle_3"),
	Material("effects/minecraft/firework_particle_4"),
	Material("effects/minecraft/firework_particle_5"),
	Material("effects/minecraft/firework_particle_6")
}

local function getCircleVector(circSect, doY)
	return Vector(not doY and math.sin(pi2*circSect) or 0, doY and math.sin(pi2*circSect) or 0, math.cos(pi2*circSect))
end

local function getCircleVectorPlanar(circSect, dZ)
	return Vector(math.sin(pi2*circSect), math.cos(pi2*circSect), dZ or 0)
end

local starShapeConstant = math.cos(math.pi/5) - math.sin(math.pi/5) * math.tan(math.pi/5)

local explosionSounds = {
	Sound("minecraft/firework.wav"),
	Sound("minecraft/firework_big.wav"),
	Sound("minecraft/firework_far.wav"),
	Sound("minecraft/firework_big_far.wav"),
}

local fireworkShapePaths = {
	{
		Vector(-1,-1,-1), Vector(1,-1,-1),
		"<", Vector(1,1,-1),
		"<", Vector(-1,1,-1),
		"<", Vector(-1,-1,-1),
		Vector(-1,-1,1), Vector(-1,1,1),
		"<", Vector(1,1,1),
		"<", Vector(1,-1,1),
		"<", Vector(-1,-1,1),
		Vector(-1,-1,-1), Vector(-1,-1,1),
		Vector(1,-1,1), Vector(1,-1,-1),
		Vector(-1,1,1), Vector(-1,1,-1),
		Vector(1,1,-1), Vector(1,1,1)
	},
	{
		getCircleVector(0), getCircleVector(0.1) * starShapeConstant,
		"<", getCircleVector(0.2),
		"<", getCircleVector(0.3) * starShapeConstant,
		"<", getCircleVector(0.4),
		"<", getCircleVector(0.5) * starShapeConstant,
		"<", getCircleVector(0.6),
		"<", getCircleVector(0.7) * starShapeConstant,
		"<", getCircleVector(0.8),
		"<", getCircleVector(0.9) * starShapeConstant,
		"<", getCircleVector(1),
		getCircleVector(0, true), getCircleVector(0.1, true) * starShapeConstant,
		"<", getCircleVector(0.2, true),
		"<", getCircleVector(0.3, true) * starShapeConstant,
		"<", getCircleVector(0.4, true),
		"<", getCircleVector(0.5, true) * starShapeConstant,
		"<", getCircleVector(0.6, true),
		"<", getCircleVector(0.7, true) * starShapeConstant,
		"<", getCircleVector(0.8, true),
		"<", getCircleVector(0.9, true) * starShapeConstant,
		"<", getCircleVector(1, true)
	},
	{
		Vector(-1,0,1), Vector(-2/3,0,1),
		"<", Vector(-1/3,0,1),
		"<", Vector(-1/3,0,2/3),
		"<", Vector(-1/3,0,1/3),
		"<", Vector(-1/3,0,0),
		"<", Vector(-2/3,0,0),
		"<", Vector(-2/3,0,-1/3),
		"<", Vector(-2/3,0,-2/3),
		"<", Vector(-2/3,0,-1),
		"<", Vector(-1/3,0,-1),
		"<", Vector(-1/3,0,-2/3),
		"<", Vector(0,0,-2/3),
		"<", Vector(1/3,0,-2/3),
		"<", Vector(1/3,0,-1),
		"<", Vector(2/3,0,-1),
		"<", Vector(2/3,0,-2/3),
		"<", Vector(2/3,0,-1/3),
		"<", Vector(2/3,0,0),
		"<", Vector(1/3,0,0),
		"<", Vector(1/3,0,1/3),
		"<", Vector(1/3,0,2/3),
		"<", Vector(1/3,0,1),
		"<", Vector(2/3,0,1),
		"<", Vector(1,0,1),
		"<", Vector(1,0,2/3),
		"<", Vector(1,0,1/3),
		"<", Vector(2/3,0,1/3),
		"<", Vector(1/3,0,1/3),
		"<", Vector(0,0,1/3),
		"<", Vector(-1/3,0,1/3),
		"<", Vector(-2/3,0,1/3),
		"<", Vector(-1,0,1/3),
		"<", Vector(-1,0,2/3),
		"<", Vector(-1,0,1)
	},
	{
		getCircleVector(0), getCircleVector(0.1) * starShapeConstant,
		"<", getCircleVector(0.2),
		"<", getCircleVector(0.3) * starShapeConstant,
		"<", getCircleVector(0.4),
		"<", getCircleVector(0.5) * starShapeConstant,
		"<", getCircleVector(0.6),
		"<", getCircleVector(0.7) * starShapeConstant,
		"<", getCircleVector(0.8),
		"<", getCircleVector(0.9) * starShapeConstant,
		"<", getCircleVector(1)
	}
}

local velocityConstant = 128
local sizeConstant = 8
local maxCloseDistance = 2048

function EFFECT:GetParticleColor(col)
	local r = bit.rshift(bit.band(col, 0xff0000), 16)
	local g = bit.rshift(bit.band(col, 0xff00), 8)
	local b = bit.band(col, 0xff)
	return r, g, b
end

function EFFECT:CheckParticle(particle)
	timer.Simple(0,function()
		print(IsValid(particle))
	end)
end

function EFFECT:GetParticleThinkNoTrail(flicker, flickerTime, fadeTime, origR, origG, origB, fadeR, fadeG, fadeB)
	return function(particle)
		local lifeTime = particle:GetLifeTime()
		local materialType = math.Remap(lifeTime, 0, particle:GetDieTime(), 0, 9)
		local desiredMaterialType = math.ceil(math.Clamp(materialType, 1, 9))
		local fadeTimeMax = fadeTime + 1
		if particle:GetMaterial() ~= fireworkTextures[desiredMaterialType] then
			particle:SetMaterial(fireworkTextures[desiredMaterialType])
		end
		if flicker and lifeTime > flickerTime then
			particle:SetLighting(math.random() < 0.5)
		end
		if lifeTime > fadeTime and lifeTime <= fadeTimeMax and fadeR then
			local r = math.Clamp(math.Remap(lifeTime, fadeTime, fadeTimeMax, origR, fadeR), 0, 255)
			local g = math.Clamp(math.Remap(lifeTime, fadeTime, fadeTimeMax, origG, fadeG), 0, 255)
			local b = math.Clamp(math.Remap(lifeTime, fadeTime, fadeTimeMax, origB, fadeB), 0, 255)
			particle:SetColor(r, g, b)
		end
		particle:SetNextThink(CurTime()+0.05)
	end
end

function EFFECT:GetParticleThink(flicker, trail, r, g, b, size, acceleration, fr, fg, fb)
	local fadeTime = 1.5
	return function(particle)
		local lifeTime = particle:GetLifeTime()
		local materialType = math.Remap(lifeTime, 0, particle:GetDieTime(), 0, 9)
		local desiredMaterialType = math.ceil(math.Clamp(materialType, 1, 9))
		local fadeTimeMax = fadeTime + 1
		if particle:GetMaterial() ~= fireworkTextures[desiredMaterialType] then
			particle:SetMaterial(fireworkTextures[desiredMaterialType])
		end
		if lifeTime > 1.5 and flicker then
			particle:SetLighting(math.random() < 0.5)
		end
		if lifeTime > fadeTime and lifeTime <= fadeTimeMax and fr then
			local r = math.Clamp(math.Remap(lifeTime, fadeTime, fadeTimeMax, r, fr), 0, 255)
			local g = math.Clamp(math.Remap(lifeTime, fadeTime, fadeTimeMax, g, fg), 0, 255)
			local b = math.Clamp(math.Remap(lifeTime, fadeTime, fadeTimeMax, b, fb), 0, 255)
			particle:SetColor(r, g, b)
		end
		if IsValid(self.Emitter) and trail then
			local oldPartNum = self.Emitter:GetNumActiveParticles()
			local newParticle = self.Emitter:Add(fireworkTextures[1], particle:GetPos())
			local thinkFunc
			if lifeTime <= fadeTimeMax then
				thinkFunc = self:GetParticleThinkNoTrail(flicker, 1.5 - lifeTime, fadeTime - lifeTime, r, g, b, fr, fg, fb)
			else
				thinkFunc = self:GetParticleThinkNoTrail(flicker, 1.5 - lifeTime, fadeTime - lifeTime)
			end
			newParticle:SetAirResistance(25)
			newParticle:SetBounce(0)
			newParticle:SetCollide(true)
			if lifeTime > fadeTimeMax and fr then
				newParticle:SetColor(fr, fg, fb)
			else
				newParticle:SetColor(r, g, b)
			end
			newParticle:SetDieTime(1)
			newParticle:SetEndAlpha(0)
			newParticle:SetEndSize(size)
			newParticle:SetGravity(acceleration)
			newParticle:SetLifeTime(0)
			newParticle:SetLighting(false)
			newParticle:SetStartAlpha(255)
			newParticle:SetStartSize(size)
			newParticle:SetThinkFunction(thinkFunc)
			newParticle:SetNextThink(CurTime())
			timer.Simple(0, function()
				if (IsValid(self) and IsValid(self.Emitter)) then
					particleFailures = particleFailures + math.max(oldPartNum - self.Emitter:GetNumActiveParticles(), 0)
				end
			end)
		end
		particle:SetNextThink(CurTime()+0.05)
	end
end

function EFFECT:GetLocalParticleVelocity(pathnum, particle, maximum, effdata)
	if pathnum >= 16 then
		local paths = fireworkShapePaths[pathnum-15]
		local currentpath = math.floor(math.Remap(particle, 1, maximum+1, 1, #paths/2+1))
		local pathpoint1 = paths[currentpath*2-1]
		local pathpoint2 = paths[currentpath*2]
		if pathpoint1 == "<" then pathpoint1 = paths[currentpath*2-2] end
		return LerpVector(particle / maximum * #paths / 2 % 1, pathpoint1, pathpoint2)
	elseif pathnum == 0 then
		return AngleRand():Forward()
	elseif pathnum == 1 then
		local baseVector = effdata:GetNormal()
		baseVector:Mul(effdata:GetMaterialIndex())
		local vMul = velocityConstant * effdata:GetRadius() / networkingConstant * effdata:GetScale()
		baseVector:Add(VectorRand(-vMul, vMul))
		baseVector:Rotate(-effdata:GetAngles())
		return baseVector, true
	elseif pathnum == 2 then
		local particlesPerLane = maximum / 3
		local lane = math.ceil(particle / particlesPerLane)
		local localParticleNum = particle % particlesPerLane
		if lane == 1 then return getCircleVector(localParticleNum / particlesPerLane)
		elseif lane == 2 then return getCircleVector(localParticleNum / particlesPerLane, true)
		else return getCircleVectorPlanar(localParticleNum / particlesPerLane)
		end
	elseif pathnum == 3 then
		return getCircleVector(((particle - 1) / (maximum - 1)) / 2 - 0.25)
	end
end

function EFFECT:GetParticleVelocity(paths, particle, maximum, effdata)
	if self.IsRocketJet then
		local baseVector = -self.RocketEntity:GetVelocity()
		baseVector:Normalize()
		baseVector:Mul(120)
		local randVector = VectorRand()
		randVector:Mul(60)
		baseVector:Add(randVector)
		return baseVector
	end
	local localVelocity, preventMulCorrection = self:GetLocalParticleVelocity(paths, particle, maximum, effdata)
	if not preventMulCorrection then
		localVelocity:Mul(velocityConstant * effdata:GetRadius() / networkingConstant * effdata:GetScale())
	end
	localVelocity:Rotate(effdata:GetAngles())
	return localVelocity
end

function EFFECT:GetMinParticles(effdata)
	if self.IsRocketJet then return 1 end
	local pathnum = effdata:GetAttachment()
	local refinedMagnitude = effdata:GetMagnitude()/networkingConstant
	if pathnum >= 16 then
		return #fireworkShapePaths[pathnum-15]*refinedMagnitude
	elseif pathnum == 2 then return 48*refinedMagnitude
	elseif pathnum == 3 then return 16*refinedMagnitude+1
	else return 64*refinedMagnitude
	end
end

function EFFECT:Init(effdata)
	local flicker = bit.band(effdata:GetFlags(), 1)~=0
	local trail = bit.band(effdata:GetFlags(), 2)~=0
	local nosounds = bit.band(effdata:GetFlags(), 64)~=0
	self.IsRocketJet = bit.band(effdata:GetFlags(), 128)~=0
	if prevFailMsgTime + 3 < CurTime() then
		particleFailures = 0
	end
	if self.IsRocketJet then
		self.NextParticle = CurTime() + 0.1
		self.RocketEntity = effdata:GetEntity()
	end
	self.KillTime = CurTime() + (trail and 6 or 5)
	local bitflag = effdata:GetOrigin():DistToSqr(LocalPlayer():GetShootPos()) > maxCloseDistance * maxCloseDistance and 2 or 0
	if effdata:GetRadius() >= sqrt3 * networkingConstant then
		bitflag = bit.bor(bitflag, 1)
	end
	if not nosounds then
		timer.Simple(effdata:GetOrigin():Distance(LocalPlayer():GetShootPos()) / 18005, function()
			if IsValid(self) then
				self:EmitSound(explosionSounds[bitflag+1], 120, 100, 1, CHAN_AUTO)
			end
			if flicker then
				timer.Simple(1,function()
					if IsValid(self) then
						self:EmitSound(bit.band(bitflag, 2)==2 and "minecraft/firework_twinkle_far.wav" or "minecraft/firework_twinkle.wav", 120, 100, 1, CHAN_AUTO)
					end
				end)
			end
		end)
	end
	self.Emitter = ParticleEmitter(effdata:GetOrigin(), false)
	if IsValid(self.Emitter) then
		local r, g, b = self:GetParticleColor(effdata:GetDamageType())
		local size = sizeConstant * effdata:GetScale()
		local acceleration = vector_up*-60
		local maxParticles = math.Round(self:GetMinParticles(effdata))
		local maxParticleDeduct = 0
		local thinkFunc
		if effdata:GetStart().x < 0 then
			thinkFunc = self:GetParticleThink(flicker, trail, r, g, b, size, acceleration)
		else
			local fr, fg, fb = effdata:GetStart():Unpack()
			thinkFunc = self:GetParticleThink(flicker, trail, r, g, b, size, acceleration, math.Round(fr), math.Round(fg), math.Round(fb))
		end
		for i=1,maxParticles do
			if effdata:GetHitBox() <= 0 or (i + effdata:GetSurfaceProp()) % effdata:GetHitBox() == 0 then
				local particle = self.Emitter:Add(fireworkTextures[1],effdata:GetOrigin())
				particle:SetAirResistance(25)
				particle:SetBounce(0)
				particle:SetCollide(true)
				particle:SetColor(r, g, b)
				particle:SetDieTime(self.IsRocketJet and 2 or 5)
				particle:SetEndAlpha(0)
				--particle:SetEndLength(16)
				particle:SetEndSize(size)
				particle:SetGravity(acceleration)
				particle:SetLifeTime(math.random()/2)
				particle:SetLighting(false)
				particle:SetStartAlpha(255)
				--particle:SetStartLength(16)
				particle:SetStartSize(size)
				particle:SetThinkFunction(thinkFunc)
				particle:SetNextThink(CurTime()+math.random()*0.05)
				particle:SetVelocity(self:GetParticleVelocity(effdata:GetAttachment(), i, maxParticles, effdata))
			else
				maxParticleDeduct = maxParticleDeduct + 1
			end
		end
		timer.Simple(0, function()
			if (IsValid(self) and IsValid(self.Emitter)) then
				particleFailures = particleFailures + math.max(maxParticles - maxParticleDeduct - self.Emitter:GetNumActiveParticles(), 0)
			end
		end)
	else
		DebugInfo(1, "WARNING: ParticleEmitter limit reached! Can't create new particles!")
	end
end

function EFFECT:Think()
	local curtime = CurTime()
	if self.KillTime <= curtime then
		self.Emitter:Finish()
		return false
	end
	prevFailMsgTime = curtime
	if particleFailures > 0 and nextFailMsgTime < curtime then
		nextFailMsgTime = curtime + 0.2
		DebugInfo(0, "[Working Minecraft Fireworks] Max particles reached! Failed to create " .. string.Comma(particleFailures) .. " particles!")
	end
	if self.IsRocketJet and IsValid(self.Emitter) and (self.NextParticle or 0) < CurTime() and (IsValid(self.RocketEntity)
	and CurTime() - self.RocketEntity:GetCreationTime() < self.RocketEntity:GetLifeTime() - 0.2) then
		self.NextParticle = CurTime() + 0.1
		self.KillTime = CurTime() + 5
		self:SetPos(self.RocketEntity:GetPos())
		local size = sizeConstant
		local acceleration = vector_up*-60
		local thinkFunc = self:GetParticleThink(false, false, 255, 255, 255, size, acceleration)
		local particle = self.Emitter:Add(fireworkTextures[1],self:GetPos())
		particle:SetAirResistance(25)
		particle:SetBounce(0)
		particle:SetCollide(true)
		particle:SetColor(255, 255, 255)
		particle:SetDieTime(2)
		particle:SetEndAlpha(0)
		--particle:SetEndLength(16)
		particle:SetEndSize(size)
		particle:SetGravity(acceleration)
		particle:SetLifeTime(math.random()/2)
		particle:SetLighting(false)
		particle:SetStartAlpha(255)
		--particle:SetStartLength(16)
		particle:SetStartSize(size)
		particle:SetThinkFunction(thinkFunc)
		particle:SetNextThink(CurTime()+math.random()*0.05)
		particle:SetVelocity(self:GetParticleVelocity())
		timer.Simple(0, function()
			if (IsValid(self) and IsValid(self.Emitter)) then
				particleFailures = particleFailures + math.max(1 - self.Emitter:GetNumActiveParticles(), 0)
			end
		end)
	end
	return true
end

function EFFECT:Render()
	-- Think() is superior
end