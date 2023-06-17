AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Rainbow Beamer"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.tower.gballoon_tower_08.purpose"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/hunter/tubes/tube1x1x1.mdl")
ENT.FireRate = 20
ENT.MaxFireRate = 1/0.115
ENT.Cost = 2500
ENT.DetectionRadius = 512
ENT.AbilityCooldown = 60
ENT.AbilityDuration = 5
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,150)
ENT.UserTargeting = true
ENT.AttackDamage = 10
ENT.rotgb_BeamWidth = 8
ENT.rotgb_DamageMul = 10
ENT.UpgradeReference = {
	{
		Prices = {2000,5000,30000,150000,1.25e6,10e6,50e6,1e9},
		Funcs = {
			function(self)
				self.InfiniteRange = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 10
				self.rotgb_BeamWidth = self.rotgb_BeamWidth * math.sqrt(2)
				self.rotgb_UseAltLaser = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 40
				self.rotgb_BeamWidth = self.rotgb_BeamWidth * math.sqrt(3)
				self.rotgb_BeamNoChildren = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 240
				self.rotgb_BeamWidth = self.rotgb_BeamWidth * math.sqrt(5)
				self.SeeCamo = true
			end,
			function(self)
				self.rotgb_Spread = true
				self.UserTargeting = false
			end,
			function(self)
				self.HasAbility = true
				self.UserTargeting = true
				if SERVER and IsValid(self.InternalLaser) then
					self.InternalLaser:Fire("Alpha",127)
				end
			end,
			function(self)
				self.rotgb_Infinite = true
				self.AbilityCooldown = self.AbilityCooldown - 15
			end,
			function(self)
				self.HasAbility = nil
				self.FireRate = self.FireRate / 60
				if SERVER and IsValid(self.InternalLaser) then
					self.InternalLaser:Fire("Alpha",255)
				end
				self.UseLOS = nil
			end
		},
		FusionRequirements = {[8] = true}
	}
}
ENT.UpgradeLimits = {99}

function ENT:ROTGB_ApplyPerks()
	self.rotgb_DamageMul = self.rotgb_DamageMul * (1+hook.Run("GetSkillAmount", "rainbowBeamerDamage")/100)
end

local function SnipeEntity()
	while true do
		local self,ent,damagemul = coroutine.yield()
		self:LaserAttack(ent, self.AttackDamage*damagemul, self.rotgb_BeamWidth, {
			damageType = self.rotgb_BeamNoChildren and DMG_DISSOLVE or self.rotgb_UseAltLaser and DMG_GENERIC,
			scroll = 35,
			rainbow = true,
			decal = "decals/dark",
			sparks = true
		})
		
		--[=[local startPos = self.rotgb_StartPos
		local laser = ents.Create("env_beam")
		--[[local oldEntName = ent:GetName()
		local entityName = ent:GetName() ~= "" and ent:GetName() or "ROTGB08_"..ent:GetCreationID()
		ent:SetName(entityName)]]
		local endEnt = ents.Create("info_target")
		--local percent = math.Remap(self.rotgb_NextFire - CurTime(), self.rotgb_BeamDelay + self.rotgb_BeamTime, self.rotgb_BeamDelay, 1, 0)
		laser:SetPos(startPos:GetPos())
		if IsValid(endEnt) then
			endEnt:SetName("ROTGB08_"..endEnt:GetCreationID())
			endEnt:SetPos(ent:WorldSpaceCenter()+ent.loco:GetVelocity()*0.1)
		end
		laser:SetKeyValue("renderamt","63")
		laser:SetKeyValue("rendercolor","255 255 255")
		laser:SetKeyValue("BoltWidth",self.rotgb_BeamWidth)
		laser:SetKeyValue("NoiseAmplitude","1")
		laser:SetKeyValue("texture","beams/rainbow1.vmt")
		laser:SetKeyValue("TextureScroll","0")
		laser:SetKeyValue("damage",self.AttackDamage*damagemul)
		laser:SetKeyValue("LightningStart",startPos:GetName())
		laser:SetKeyValue("LightningEnd",endEnt:GetName())
		laser:SetKeyValue("HDRColorScale","0.7")
		laser:SetKeyValue("decalname","decals/dark")
		laser:SetKeyValue("spawnflags","97")
		--[[if percent then
			laser:SetKeyValue("life",self.rotgb_BeamTime)
		end]]
		laser:Spawn()
		laser.rotgb_Owner = self
		laser:Activate()
		laser.rotgb_UseLaser = self.rotgb_UseAltLaser and 2 or 1
		laser.rotgb_NoChildren = self.rotgb_BeamNoChildren
		laser.rotgb_Rainbow = true
		--if percent then
			--laser:Fire("Alpha",percent*255)
		--end
		laser:Fire("TurnOn")
		--[[local canOtherBonus = #ents.GetAll()<1000
		if not percent then
			local lastfiretime = CurTime()
			timer.Create("ROTGB_08_B_"..endEnt:GetCreationID(),0.05,self.rotgb_BeamTime*20,function()
				if IsValid(laser) then
					laser.CurAlpha = (laser.CurAlpha or 255) - 0.05/self.rotgb_BeamTime*255
					laser:Fire("Alpha",laser.CurAlpha)
				end
				if (IsValid(self) and self.rotgb_OtherBonus and canOtherBonus) then
					self:ExpensiveThink(true)
					if IsValid(self.SolicitedgBalloon) and IsValid(self.rotgb_StartPos) then
						percent = (CurTime()-lastfiretime)/self.rotgb_BeamTime
						for k,v in pairs(self.gBalloons or {}) do
							local perf,str = coroutine.resume(self.thread,self,v,percent)
							if not perf then error(str) end
						end
					end
				end
			end)
		end]]
		timer.Simple(0.2,function()
			if IsValid(laser) then
				self:DontDeleteOnRemove(laser)
				laser:Remove()
			end
			--[[if (IsValid(ent) and entityName == ent:GetName()) then
				ent:SetName(oldEntName)
			end]]
			if IsValid(endEnt) then
				endEnt:Remove()
			end
		end)
		self:DeleteOnRemove(laser)]=]
	end
end

ENT.thread = coroutine.create(SnipeEntity)
--coroutine.resume(ENT.thread)

function ENT:ROTGB_Initialize()
	if SERVER then
		self.rotgb_CannonPositions = {}
		--[[if not self.rotgb_Infinite then
			self:SetNWFloat("LastFireTime",CurTime()-self.rotgb_BeamTime)
		end]]
		local startPos = ents.Create("info_target")
		startPos:SetName("ROTGB08_"..startPos:GetCreationID())
		startPos:SetPos(self:GetShootPos())
		startPos:SetParent(self)
		startPos:Spawn()
		self.rotgb_StartPos = startPos
		self:DeleteOnRemove(startPos)
		self:SetName("ROTGB08_"..self:GetCreationID())
		local laser = ents.Create("env_beam")
		laser:SetPos(self:GetPos())
		laser:SetKeyValue("renderamt","255")
		laser:SetKeyValue("rendercolor","255 255 255")
		laser:SetKeyValue("BoltWidth","8")
		laser:SetKeyValue("NoiseAmplitude","2")
		laser:SetKeyValue("texture","beams/rainbow1.vmt")
		laser:SetKeyValue("TextureScroll","0")
		laser:SetKeyValue("LightningStart",self:GetName())
		laser:SetKeyValue("LightningEnd",startPos:GetName())
		laser:SetKeyValue("HDRColorScale","0.7")
		laser:SetKeyValue("spawnflags","129")
		laser:Spawn()
		laser:Activate()
		laser:Fire("TurnOn")
		self.InternalLaser = laser
		self:DeleteOnRemove(laser)
	end
end

function ENT:ROTGB_Think()
	local balloonPops = {}
	for k,v in pairs(self.rotgb_CannonPositions) do
		if IsValid(k) then
			for k2,v2 in pairs(ROTGB_GetBalloons()) do
				if self:ValidTargetIgnoreRange(v2) and v2:WorldSpaceCenter():DistToSqr(k:GetPos()) <= 65536 then
					balloonPops[v2] = balloonPops[v2] or {0, v}
					balloonPops[v2][1] = balloonPops[v2][1] + self.AttackDamage*1000*(1+self.FusionPower/100)
					balloonPops[v2][2] = v
				end
			end
		else
			self.rotgb_CannonPositions[k] = nil
		end
	end
	for k,v in pairs(balloonPops) do
		hook.Run("gBalloonDamagedByLaser", k, self:GetTowerOwner(), self, v[2], v[1])
		self:DealDamage(k, v[1])
	end
	
	if IsValid(self.InternalLaser) then
		self.InternalLaser:SetNoDraw(self:GetNoDraw())
	end
end

function ENT:ROTGB_Draw()
	--[[local elapsedseconds = CurTime()-self:GetNWFloat("LastFireTime")
	local val = 0
	if elapsedseconds < self.rotgb_BeamTime then
		val = math.Remap(self.rotgb_BeamTime-elapsedseconds,self.rotgb_BeamTime,0,255,0)
	else
		val = math.Remap(elapsedseconds-self.rotgb_BeamTime,0,self.rotgb_BeamDelay,0,255)
	end]]
	self:DrawModel()
	render.SetColorMaterial()
	render.DrawSphere(self:GetShootPos(),24,24,13,color_white)--val >= 255 and color_white or Color(val,val,val))
end

local abilityFunction

function ENT:FireFunction(gBalloons, damageMultiplier)
	if not self.UseLOS then
		abilityFunction(self)
	elseif IsValid(self.rotgb_StartPos) then
		if not self.rotgb_Spread then
			local perf,str = coroutine.resume(self.thread,self,gBalloons[1],self.rotgb_DamageMul*damageMultiplier)
			if not perf then error(str) end
		else
			for i,v in ipairs(gBalloons) do
				local perf,str = coroutine.resume(self.thread,self,v,self.rotgb_DamageMul*damageMultiplier)
				if not perf then error(str) end
			end
		end
	end
end

local ShotSound = Sound("Airboat.FireGunHeavy")
local AlertSound = Sound("npc/attack_helicopter/aheli_megabomb_siren1.wav")

abilityFunction = function(self)
	if IsValid(self) then
		local duration = 6
		
		local ent = self:ChooseSomething()
		if IsValid(ent) then
			if self.rotgb_Infinite then
				self:AddCash(5e7*(1+self.FusionPower/100), self:GetTowerOwner())
			end
			if ent.UseLOS then
				sound.Play("ambient/explosions/explode_6.wav", ent:GetPos(), 100)
			end
			local numberOfCannons = 1
			for k,v in pairs(ents.FindByClass("gballoon_tower_08")) do
				if v:GetUpgradeStatus() >= 8 then
					numberOfCannons = numberOfCannons + 1
				end
			end
			local startPos = ents.Create("info_target")
			local ecp = ent:GetPos()
			ecp.z = 16368
			startPos:SetPos(ecp)
			startPos:SetName("ROTGB08_"..startPos:GetCreationID())
			startPos:Spawn()
			local endPos = ents.Create("info_target")
			ecp = ent:GetPos()
			endPos:SetPos(ecp)
			endPos:SetName("ROTGB08_"..endPos:GetCreationID())
			endPos:Spawn()
			local effdata = EffectData()
			ecp.z = ecp.z + 24
			effdata:SetOrigin(ecp)
			effdata:SetFlags(self.UseLOS and 0 or 1)
			--effdata:SetMagnitude(512/numberOfCannons)
			util.Effect("gballoon_tower_08_wave",effdata)
			util.ScreenShake(ecp,1.25/numberOfCannons,5,duration,5000)
			local beam = ents.Create("env_beam")
			beam:SetPos(ecp)
			beam:SetKeyValue("renderamt","255")
			beam:SetKeyValue("rendercolor","255 255 255")
			beam:SetKeyValue("BoltWidth","50")
			beam:SetKeyValue("NoiseAmplitude","0")
			beam:SetKeyValue("texture","beams/rainbow1.vmt")
			beam:SetKeyValue("TextureScroll","100")
			beam:SetKeyValue("LightningStart",startPos:GetName())
			beam:SetKeyValue("LightningEnd",endPos:GetName())
			beam:SetKeyValue("HDRColorScale","0.7")
			beam:SetKeyValue("spawnflags","1")
			--beam:SetKeyValue("damage","999999")
			beam:Spawn()
			beam:Activate()
			beam:Fire("TurnOn")
			beam.rotgb_Rainbow = true
			self.rotgb_CannonPositions[endPos] = beam
			timer.Create("ROTGB_08_AB_"..endPos:GetCreationID(),0.05,120,function()
				if IsValid(beam) then
					beam.CurAlpha = (beam.CurAlpha or 255) - 0.05/duration*255
					beam:Fire("Alpha",beam.CurAlpha)
				end
			end)
			timer.Simple(duration,function()
				if IsValid(startPos) then
					startPos:Remove()
				end
				if IsValid(endPos) then
					endPos:Remove()
				end
				if IsValid(beam) then
					beam:Remove()
				end
			end)
		elseif self.UseLOS then
			local tryAgainTime = math.random()
			ROTGB_Log(string.format("DASH-E Unit #%i failed to find any Orbital Friendship Cannon targets, trying again in %.2f ms...", self:GetCreationID(), tryAgainTime*1e3), "towers")
			timer.Simple(tryAgainTime,function()
				abilityFunction(self)
			end)
		end
	end
end

function ENT:TriggerAbility()
	if not ROTGB_BalloonsExist() then return true end
	self:AddDelayedActions(self, "ROTGB_TOWER_08_ABILITY", 0, function(tower)
		tower:EmitSound(ShotSound,0)
		tower:EmitSound(AlertSound,0)
	end, self.AbilityDuration, function(tower)
		abilityFunction(tower)
	end)
end

function ENT:ChooseSomething()
	local oldLos = self.UseLOS
	self.UseLOS = false
	self:ExpensiveThink(true)
	self.UseLOS = oldLos
	return self.gBalloons[1]
end

if CLIENT then
	-- This will be a highly bootlegged version to avoid potential lag.
	-- Also, it should look unnaturally regular compared to a normal Orbital Friendship Cannon, since a DASH-E unit is performing it.

	local EFFECT = {}
	function EFFECT:Init(data)
		local start = data:GetOrigin()
		sound.Play("ambient/explosions/explode_6.wav", start, 100, 100, bit.band(data:GetFlags(),1)==1 and 0.5 or 1)
		local emitter = ParticleEmitter(start)
		local pi2 = math.pi*2
		for i=0,pi2*4,pi2/1024*4 do
			local particle = emitter:Add("particle/smokesprites_0009",start)
			if particle then
				local sine,cosine = math.sin(i),math.cos(i)
				local vellgh = math.random(425,500)
				local vel = Vector(sine,cosine,0)
				vel:Mul(vellgh)
				particle:SetVelocity(vel)
				local col = HSVToColor(math.Remap(math.abs(i%pi2-math.pi),0,math.pi,360,0),1,1)
				particle:SetColor(col.r,col.g,col.b)
				particle:SetDieTime(5+math.random())
                particle:SetLifeTime(1+math.random())
				particle:SetStartSize((vellgh-400)/4)
				particle:SetEndSize(vellgh-400)
				particle:SetAirResistance(5)
				particle:SetRollDelta(4*math.random()-2)
			end
		end
		for i=0,pi2,pi2/512 do
			local particle = emitter:Add("particle/smokesprites_0010",start)
			if particle then
				local vel = Vector(math.random(-100,100),math.random(-100,100),math.random(-3,3))
				local vellgh = math.random(25,600)
				vel:Normalize()
				vel:Mul(vellgh)
				particle:SetVelocity(vel)
				particle:SetColor(255,255,255)
				particle:SetDieTime(5+math.random())
                particle:SetLifeTime(0.3+math.random()/5)
				particle:SetStartSize(37.5-vellgh/16)
				particle:SetEndSize(150-vellgh/4)
				particle:SetAirResistance(50)
				particle:SetRollDelta(4*math.random()-2)
			end
			particle = emitter:Add("particle/smokesprites_0010",start)
			if particle then
				local vel = Vector(math.sin(i),math.cos(i),0)
				vel:Mul(500)
				particle:SetVelocity(vel)
				particle:SetColor(255,255,255)
				particle:SetDieTime(5+math.random())
                particle:SetLifeTime(0.5+math.random()/2)
				particle:SetStartSize(2.5)
				particle:SetEndSize(20+10*math.random())
				particle:SetAirResistance(30+math.random())
				particle:SetRollDelta(4*math.random()-2)
			end
		end
		emitter:Finish()
	end
	function EFFECT:Think() end
	function EFFECT:Render() end
	effects.Register(EFFECT,"gballoon_tower_08_wave")
end