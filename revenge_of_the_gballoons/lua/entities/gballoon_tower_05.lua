AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Orb of Cold"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.tower.gballoon_tower_05.purpose"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/hunter/misc/cone1x05.mdl")
ENT.FireRate = 0.4
ENT.Cost = 450
ENT.DetectionRadius = 256
ENT.AbilityCooldown = 30
ENT.FireWhenNoEnemies = true
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,40)
ENT.AttackDamage = 0
ENT.rotgb_ShardDamage = 10
--ENT.rotgb_FreezeFireRate = 1
ENT.rotgb_FreezeTime = 1
ENT.rotgb_SpeedPercent = 1
ENT.rotgb_FireRateMul = 1
ENT.UpgradeReference = {
	{
		Names = {"Snappy Freezing","Thorough Freezing","Snappier Freezing","Breakneck Freezing","Snappiest Freezing","Fiery Freezing"},
		Descs = {
			"Pops one layer when freezing gBalloons.",
			"gBalloons move 50% slower after frozen, for 3 seconds.",
			"Considerably increases freezing damage.",
			"Considerably increases freezing rate and tremendously increases freezing damage.",
			"Colossally increases freezing damage! Frozen gBalloons also lose all damage type immunities while frozen (if they can be frozen).",
			"Freezing gBalloons now sets them on fire, dealing 500 layers of damage over 5 seconds! gBalloons that are immune to freezing can be affected by this upgrade."
		},
		Prices = {500,2750,3500,35000,375000,1e6},
		Funcs = {
			function(self)
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.rotgb_SpeedPercent = self.rotgb_SpeedPercent * 0.5
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.FireRate = self.FireRate * 2
				self.AttackDamage = self.AttackDamage + 40
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 240
				self.rotgb_PowerFreeze = true
			end,
			function(self)
				self.rotgb_FireLight = true
			end
		}
	},
	{
		Names = {"Greater Influence","Better Coolant","Below Zero","Winds of Antarctica","Ice Sign: Absolute Zero","The World of White Wonderland"},
		Descs = {
			"Slightly increases freezing range.",
			"Slightly increases freezing duration.",
			"Freezing now causes ALL layers to be frozen. Enables the tower to freeze Blue gBlimps and lower non-white gBalloons.",
			"Red gBlimps and lower within radius move 50% slower, even if hidden.",
			"Once every 30 seconds, shooting at this tower causes ALL gBalloons to move 75% slower for 15 seconds. This ability does not affect newly spawned gBalloons.",
			"Considerably increases freezing range and all gBalloons move 75% slower regardless of range. Once every 30 seconds, shooting at this tower freezes all Green gBlimps and lower regardless of immunities in addition to slowing them down for 15 seconds."
		},
		Prices = {200,950,7500,100000,200000,25e6},
		Funcs = {
			function(self)
				self.DetectionRadius = self.DetectionRadius * 1.5
			end,
			function(self)
				self.rotgb_FreezeTime = self.rotgb_FreezeTime * 1.5
				--self.rotgb_FreezeBoost = true
			end,
			function(self)
				self.rotgb_Intense = true
			end,
			function(self)
				self.rotgb_SpeedSlowdown = true
			end,
			function(self)
				--self.rotgb_Viral = true
				self.HasAbility = true
			end,
			function(self)
				self.DetectionRadius = self.DetectionRadius * 2
				self.rotgb_Wonderland = true
			end,
		}
	},
	{
		Names = {"Agitated Core","Quick Refresher","Angered Core","Cold Play","Icicle Storm","Blizzard and Hail"},
		Descs = {
			"The Orb of Cold now fires ice shards which pop one layer per shot.",
			"Slightly increases shard fire rate and freezing rate.",
			"Tremendously increases shard fire rate and damage.",
			"Colossally increases shard damage and shards gain infinite range. Will still freeze gBalloons only in its original radius.",
			"Increases shard fire rate by 1% per RgBE of every gBalloon within range.",
			"Every time a shard hits a gBalloon, shard damage is increased by 1/10th of a layer. All bonus damage is lost when no gBalloons can be attacked with shards."
		},
		Prices = {250,1750,2750,30000,275000,2.5e6},
		Funcs = {
			function(self)
				self.FireRate = self.FireRate * 5
				self.rotgb_FireRateMul = self.rotgb_FireRateMul * 5
				self.UserTargeting = true
			end,
			function(self)
				self.FireRate = self.FireRate * 1.5
			end,
			function(self)
				self.FireRate = self.FireRate * 3
				self.rotgb_FireRateMul = self.rotgb_FireRateMul * 3
				self.rotgb_ShardDamage = self.rotgb_ShardDamage + 20
			end,
			function(self)
				self.rotgb_ShardDamage = self.rotgb_ShardDamage + 120
				self.InfiniteRange = true
			end,
			function(self)
				self.rotgb_FireRateBoost = true
			end,
			function(self)
				self.rotgb_DamageBoost = true
			end
		}
	}
}
ENT.UpgradeLimits = {6,2,0}

function ENT:ROTGB_ApplyPerks()
	self.rotgb_SpeedPercent = self.rotgb_SpeedPercent * (1+hook.Run("GetSkillAmount", "orbOfColdSpeedPercent")/100)
end

function ENT:DoFreeze(ent)
	if self:ValidTarget(ent) then
		if self.rotgb_FireLight then
			ent:RotgB_Ignite(1000, self:GetTowerOwner(), self, 5)
		end
		if not ent:GetBalloonProperty("BalloonBlimp") or self.rotgb_Intense and ent:GetRgBE()<=ent:GetRgBEByType("gballoon_blimp_blue") then
			if self.rotgb_Intense then
				ent:Freeze2(self.rotgb_FreezeTime)
			else
				ent:Freeze(self.rotgb_FreezeTime)
			end
			if self.rotgb_SpeedPercent ~= 1 then
				ent:Slowdown("ROTGB_ICE_TOWER",self.rotgb_SpeedPercent,3+self.rotgb_FreezeTime)
			end
			if self.rotgb_PowerFreeze then
				ent:InflictRotgBStatusEffect("unimmune",1)
			end
		else
			ent:ShowResistEffect(1)
		end
	end
end

function ENT:FireFunction(gBalloons)
	self.rotgb_Freezer = (self.rotgb_Freezer or 0) + --[[self.rotgb_FreezeFireRate]]1/self.rotgb_FireRateMul
	if self.rotgb_Freezer >= 1 then
		self.FireWhenNoEnemies = false
	end
	if self.rotgb_Freezer >= 1 and next(gBalloons) then
		self.rotgb_Freezer = self.rotgb_Freezer - 1
		self.FireWhenNoEnemies = true
		local drrt = self.DetectionRadius*self.DetectionRadius
		if self.AttackDamage > 0 then
			for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
				if self:ValidTargetIgnoreRange(v) and v:GetPos():DistToSqr(self:GetShootPos())<=drrt then
					if not v:GetBalloonProperty("BalloonBlimp") or self.rotgb_Intense and v:GetRgBE()<=v:GetRgBEByType("gballoon_blimp_blue") then
						v:TakeDamage(self.AttackDamage,self:GetTowerOwner(),self)
					else
						v:ShowResistEffect(1)
					end
				end
			end
		end
		timer.Simple(0,function()
			for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
				self:DoFreeze(v)
			end
		end)
		self:SetNWFloat("LastFireTime",CurTime())
	end
	if self.UserTargeting and IsValid(gBalloons[1]) then
		local startPos = self:GetShootPos()
		local uDir = gBalloons[1]:LocalToWorld(gBalloons[1]:OBBCenter())-startPos
		local bullet = {
			Attacker = self:GetTowerOwner(),
			Callback = function(attacker,tracer,dmginfo)
				dmginfo:SetDamageType(DMG_SNIPER)
			end,
			Damage = self.rotgb_ShardDamage,
			Distance = self.DetectionRadius*1.5,
			HullSize = 1,
			AmmoType = "",
			TracerName = "GlassImpact",
			Dir = uDir,
			Src = startPos
		}
		self:FireBullets(bullet)
		if self.rotgb_DamageBoost then
			self.rotgb_ShardDamage = self.rotgb_ShardDamage + 1
			self.rotgb_ExtraDamage = (self.rotgb_ExtraDamage or 0) + 1
		end
		self:SetNWFloat("LastFireTime",CurTime())
	elseif self.rotgb_DamageBoost then
		self.rotgb_ShardDamage = self.rotgb_ShardDamage - (self.rotgb_ExtraDamage or 0)
		self.rotgb_ExtraDamage = 0
	end
	if self.rotgb_FireRateBoost then
		local increment = 0
		for k,v in pairs(gBalloons) do
			increment = v:GetRgBE()
		end
		self.FireRate = self.FireRate / self.rotgb_FireRateMul
		self.rotgb_FireRateMul = 8 * (1 + increment * 0.01)
		self.FireRate = self.FireRate * self.rotgb_FireRateMul
	end
end

function ENT:ROTGB_Think()
	--[[if self.rotgb_Viral then
		for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
			if self:ValidTargetIgnoreRange(v) and ((v.FreezeUntil or 0)>CurTime() or (v.FreezeUntil2 or 0)>CurTime()) then
				for k2,v2 in pairs(ents.FindInSphere(v:GetPos(),self:BoundingRadius()*2)) do
					self:DoFreeze(v2)
				end
			end
		end
	end]]
	if (self.NextLocalThink or 0) < CurTime() then
		self.NextLocalThink = CurTime() + 0.1
		if self.rotgb_SpeedSlowdown then
			if self.rotgb_Wonderland then
				for index,ent in pairs(ROTGB_GetBalloons()) do
					ent:Slowdown("ROTGB_ICE_TOWER_ARCTIC",0.25,999999)
				end
			else
				for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
					if v:GetClass()=="gballoon_base" and v:GetRgBE() <= v:GetRgBEByType("gballoon_blimp_red") then
						v:Slowdown("ROTGB_ICE_TOWER_ARCTIC",0.5,0.25)
					end
				end
			end
		end
	end
end

function ENT:ROTGB_Draw()
	local curTime = CurTime()
	local pi = math.pi
	self.DispVec = self.DispVec or Vector()
	self.DispVec.z = math.sin(curTime%2*pi)*6
	local elapsedseconds = curTime-self:GetNWFloat("LastFireTime")
	local dispvec = self.LOSOffset + self.DispVec
	local sat = math.min(math.EaseInOut(math.abs(curTime*pi/2%2-1),0.5,0.5)/2+0.5,elapsedseconds*pi)
	self:DrawModel()
	render.SetColorMaterial()
	render.DrawSphere(self:LocalToWorld(dispvec),6,24,13,HSVToColor(180,sat,1))
end

function ENT:TriggerAbility()
	local entities = ROTGB_GetBalloons()
	if not next(entities) then return true end
	for index,ent in pairs(entities) do
		ent:Slowdown("ROTGB_ICE_TOWER_ABILITY",0.25,15)
		if self.rotgb_Wonderland then
			if self.rotgb_FireLight then
				ent:RotgB_Ignite(1000, self:GetTowerOwner(), self, 5)
			end
			if not ent:GetBalloonProperty("BalloonBlimp") or ent:GetRgBE()<=ent:GetRgBEByType("gballoon_blimp_green") then
				if self.rotgb_Intense then
					ent:Freeze2(15)
				else
					ent:Freeze(15)
				end
				if self.rotgb_SpeedPercent ~= 1 then
					ent:Slowdown("ROTGB_ICE_TOWER",self.rotgb_SpeedPercent,18)
				end
				if self.rotgb_PowerFreeze then
					ent:InflictRotgBStatusEffect("unimmune",1)
				end
			else
				ent:ShowResistEffect(1)
			end
		end
	end
end