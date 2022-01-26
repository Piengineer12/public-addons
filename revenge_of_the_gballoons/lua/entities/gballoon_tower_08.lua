AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Rainbow Beamer"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "This tower shoots a rainbow beam that shreds gBalloons."
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/hunter/tubes/tube1x1x1.mdl")
ENT.FireRate = 20
ENT.Cost = 2500
ENT.DetectionRadius = 512
ENT.AbilityCooldown = 60
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,150)
ENT.UserTargeting = true
ENT.AttackDamage = 10
ENT.rotgb_BeamWidth = 8
ENT.rotgb_DamageMul = 10
ENT.UpgradeReference = {
	{
		Names = {"Super Range","Enhanced Prisms","Secondary Spectrum","Fury of the Radiant Sun","Rainbow Overlord","Orbital Friendship Cannon","Dyson Sphere","INFINITE POWER!"},
		Descs = {
			"Increases range to infinite.",
			"Considerably increases attack damage and enables the tower to pop purple gBalloons.",
			"Tremendously increases attack damage. gBalloons popped by this tower do not spawn any children.",
			"Colossally increases attack damage and enables the tower to pop Hidden gBalloons.",
			"This tower now hits ALL gBalloons within sight.",
			"Once every 60 seconds, shooting at this tower inflicts x1,000 damage per tick at the location of the strongest gBalloon on the map after 5 seconds.",
			"Reduces Orbital Friendship Cannon's cooldown by 30 seconds and you gain $50,000,000 for every use.",
			"It's worth it."
		},
		Prices = {2000,5000,30000,150000,1.25e6,10e6,50e6,1e9},--{2000,15000,100000,1.25e6,5e6,10e6,50e6,1e9},
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
				--self.AttackDamage = self.AttackDamage + 300
				self.UserTargeting = false
			end,
			function(self)
				self.HasAbility = true
				if SERVER and IsValid(self.InternalLaser) then
					self.InternalLaser:Fire("Alpha",127)
				end
			end,
			function(self)
				self.rotgb_Infinite = true
				self.AbilityCooldown = self.AbilityCooldown / 2
			end,
			function(self)
				self.HasAbility = nil
				self.FireRate = self.FireRate / 10
				if SERVER and IsValid(self.InternalLaser) then
					self.InternalLaser:Fire("Alpha",255)
				end
				self.UseLOS = nil
			end
		}
	}
}
ENT.UpgradeLimits = {99}

function ENT:ROTGB_ApplyPerks()
	self.rotgb_DamageMul = self.rotgb_DamageMul * (1+hook.Run("GetSkillAmount", "rainbowBeamerDamage")/100)
end

local function SnipeEntity()
	while true do
		local self,ent,damagemul = coroutine.yield()
		local startPos = self.rotgb_StartPos
		local laser = ents.Create("env_beam")
		--[[local oldEntName = ent:GetName()
		local entityName = ent:GetName() ~= "" and ent:GetName() or "ROTGB08_"..ent:GetCreationID()
		ent:SetName(entityName)]]
		local endEnt = ents.Create("info_target")
		--local percent = math.Remap(self.rotgb_NextFire - CurTime(), self.rotgb_BeamDelay + self.rotgb_BeamTime, self.rotgb_BeamDelay, 1, 0)
		laser:SetPos(startPos:GetPos())
		if IsValid(endEnt) then
			endEnt:SetName("ROTGB08_"..endEnt:GetCreationID())
			endEnt:SetPos(ent:GetPos()+ent.loco:GetVelocity()*0.1+ent:OBBCenter())
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
		self:DeleteOnRemove(laser)
	end
end

ENT.thread = coroutine.create(SnipeEntity)
--coroutine.resume(ENT.thread)

function ENT:ROTGB_Initialize()
	if SERVER then
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
	if IsValid(self.KillDamagePos) then
		for k,v in pairs(ents.FindInSphere(self.KillDamagePos:GetPos(),32)) do
			if v:GetClass()=="gballoon_base" then
				v:TakeDamage(self.AttackDamage*1000, self:GetTowerOwner(), self)
			end
		end
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

function ENT:FireFunction(gBalloons)
	if not self.UseLOS then
		abilityFunction(self)
	elseif IsValid(self.rotgb_StartPos) then
		--[[if self.rotgb_NextFire <= CurTime() then
			self.rotgb_NextFire = CurTime() + self.rotgb_BeamDelay + self.rotgb_BeamTime
			if not self.rotgb_Infinite then
				self:SetNWFloat("LastFireTime",CurTime())
			end
		end
		if self.rotgb_NextFire > CurTime() + self.rotgb_BeamDelay then]]
			if self.UserTargeting then
				local perf,str = coroutine.resume(self.thread,self,gBalloons[1],self.rotgb_DamageMul)
				if not perf then error(str) end
			else
				--[[local damagemul = 10
				if self.rotgb_Infinite then
					damagemul = 10
					for k,v in pairs(gBalloons) do
						damagemul = damagemul + v:GetRgBE() / 10
					end
				end]]
				--local i = 1
				for k,v in pairs(gBalloons) do
					local perf,str = coroutine.resume(self.thread,self,v,self.rotgb_DamageMul)
					if not perf then error(str) end
					--i = i + 1
					--if i > 10 then break end
				end
			end
		--end
		--[[if self.rotgb_OtherBonus then
			self.rotgb_OtherBy = self.rotgb_OtherBy or 0
			self.FireRate = self.FireRate / (1+self.rotgb_OtherBy*0.2)
			self.rotgb_OtherBy = ents.FindInSphere(self:GetShootPos(),512)
			for k,v in pairs(self.rotgb_OtherBy) do
				if v:GetClass()~="gballoon_tower_08" then
					self.rotgb_OtherBy[k] = nil
				end
			end
			self.rotgb_OtherBy = #self.rotgb_OtherBy
			self.FireRate = self.FireRate * (1+self.rotgb_OtherBy*0.2)
		end]]
	end
end

local ShotSound = Sound("Airboat.FireGunHeavy")
local AlertSound = Sound("npc/attack_helicopter/aheli_megabomb_siren1.wav")

abilityFunction = function(self)
	if IsValid(self) then
		local entities = ROTGB_GetBalloons()
		--if not next(entities) then return true end
		local enttab = {}
		for index,ent in pairs(entities) do
			if self:ValidTargetIgnoreRange(ent) then
				enttab[ent] = ent:GetRgBE()+ent:GetDistanceTravelled()*1e-9
			end
		end
		local ent = next(entities) and self:ChooseSomething(enttab)
		if IsValid(ent) then
			if self.rotgb_Infinite then
				self:AddCash(5e7, self:GetTowerOwner())
			end
			ent:EmitSound("ambient/explosions/explode_6.wav",100,100,0.5)
			local startPos = ents.Create("info_target")
			local ecp = ent:GetPos()
			ecp.z = 16000
			startPos:SetPos(ecp)
			startPos:SetName("ROTGB08_"..startPos:GetCreationID())
			local endPos = ents.Create("info_target")
			ecp = ent:GetPos()
			ecp.z = ecp.z + ent:OBBMins().z
			endPos:SetPos(ecp)
			endPos:SetName("ROTGB08_"..endPos:GetCreationID())
			self.KillDamagePos = endPos
			local effdata = EffectData()
			ecp.z = ecp.z + 24
			effdata:SetOrigin(ecp)
			util.Effect("rainbow_wave",effdata)
			util.ScreenShake(ecp,5,5,6,1024)
			local beam = ents.Create("env_beam")
			beam:SetPos(ecp)
			beam:SetKeyValue("renderamt","255")
			beam:SetKeyValue("rendercolor","255 255 255")
			beam:SetKeyValue("BoltWidth","64")
			beam:SetKeyValue("NoiseAmplitude","0")
			beam:SetKeyValue("texture","beams/rainbow1.vmt")
			beam:SetKeyValue("TextureScroll","100")
			beam:SetKeyValue("LightningStart",startPos:GetName())
			beam:SetKeyValue("LightningEnd",endPos:GetName())
			beam:SetKeyValue("HDRColorScale","1")
			beam:SetKeyValue("spawnflags","1")
			--beam:SetKeyValue("damage","999999")
			beam:Spawn()
			beam:Activate()
			beam:Fire("TurnOn")
			timer.Create("ROTGB_08_AB_"..endPos:GetCreationID(),0.05,120,function()
				if IsValid(beam) then
					beam.CurAlpha = (beam.CurAlpha or 255) - 0.05/6*255
					beam:Fire("Alpha",beam.CurAlpha)
				end
			end)
			timer.Simple(6,function()
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
	local entities = ROTGB_GetBalloons()
	if not next(entities) then return true end
	local enttab = {}
	for index,ent in pairs(entities) do
		enttab[ent] = ent:GetRgBE()
	end
	local ent = self:ChooseSomething(enttab)
	if IsValid(ent) then
		self:EmitSound(ShotSound,0)
		self:EmitSound(AlertSound,0)
		timer.Simple(5,function()
			abilityFunction(self)
		end)
	else return true
	end
end

function ENT:ChooseSomething(enttab)
	local chosen = table.GetWinningKey(enttab)
	--[[local trace = util.TraceLine({
		start = chosen:GetPos(),
		endpos = chosen:GetPos()+Vector(0,0,32768),
		filter = ents.GetAll(),
	})]]
	--if trace.HitSky then
		return chosen
	--[[else
		enttab[chosen] = nil
		if next(enttab) then
			return self:ChooseSomething(enttab)
		else return NULL
		end
	end]]
end

if CLIENT then

	-- This will be a highly bootlegged version to avoid potential lag.

	local EFFECT = {}
	function EFFECT:Init(data)
		local start = data:GetOrigin()
		local emitter = ParticleEmitter(start)
		local pi2 = math.pi*2
		for i=1,360 do
			local particle = emitter:Add("particle/smokesprites_0009",start)
			if particle then
				local radians = math.rad(i)
				local sine,cosine = math.sin(radians),math.cos(radians)
				local vellgh = math.random(340,400)
				local vel = Vector(sine,cosine,0)*vellgh
				particle:SetVelocity(vel)
				local col = HSVToColor(math.Remap(sine,-1,1,0,360),1,1)
				particle:SetColor(col.r,col.g,col.b)
				particle:SetDieTime(5+math.random())
				particle:SetStartSize((vellgh-320)*0.25)
				particle:SetEndSize(vellgh-320)
				particle:SetAirResistance(5)
				particle:SetRollDelta(math.random(-2,2))
			end
		end
		for i=1,100 do
			local particle = emitter:Add("particle/smokesprites_0010",start)
			if particle then
				local vel = Vector(math.random(-100,100),math.random(-100,100),math.random(-3,3)):GetNormal()*math.random(20,480)
				local vellgh = vel:Length2D()
				particle:SetVelocity(vel)
				particle:SetColor(255,255,255)
				particle:SetDieTime(5+math.random())
				particle:SetStartSize(30-vellgh/16)
				particle:SetEndSize(120-vellgh/4)
				particle:SetAirResistance(50)
				particle:SetRollDelta(math.random(-2,2))
			end
			particle = emitter:Add("particle/smokesprites_0010",start)
			if particle then
				particle:SetVelocity(Vector(math.random(-10,10),math.random(-10,10),0):GetNormal()*400)
				particle:SetColor(255,255,255)
				particle:SetDieTime(5+math.random())
				particle:SetStartSize(5)
				particle:SetEndSize(16+8*math.random())
				particle:SetAirResistance(30+math.random())
				particle:SetRollDelta(math.random(-2,2))
			end
		end
		emitter:Finish()
	end
	function EFFECT:Think() end
	function EFFECT:Render() end
	effects.Register(EFFECT,"rainbow_wave")
end