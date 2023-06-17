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
ENT.AbilityDuration = 15
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
		Prices = {400,800,1500,15000,100000,1e6},
		Funcs = {
			function(self)
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.SeeCamo = true
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
		local detectionRadiusSquared = self.DetectionRadius^2
		if self.AttackDamage > 0 then
			-- we call ents.FindInSphere here because this effect should be regardless of LOS
			for k,v in pairs(ents.FindInSphere(self:GetShootPos(), self.DetectionRadius)) do
				if self:ValidTargetIgnoreRange(v) then
					if not v:GetBalloonProperty("BalloonBlimp") or self.rotgb_Intense and v:GetRgBE()<=v:GetRgBEByType("gballoon_blimp_blue") then
						self:DealDamage(v, self.AttackDamage)
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
		self:BulletAttack(gBalloons[1], self.rotgb_ShardDamage, {
			damageType = DMG_SNIPER,
			tracer = "GlassImpact",
		})
		
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
		ent:Slowdown("ROTGB_ICE_TOWER_ABILITY",0.25,self.AbilityDuration)
		if self.rotgb_Wonderland then
			if self.rotgb_FireLight then
				ent:RotgB_Ignite(1000, self:GetTowerOwner(), self, 5)
			end
			if not ent:GetBalloonProperty("BalloonBlimp") or ent:GetRgBE()<=ent:GetRgBEByType("gballoon_blimp_green") then
				if self.rotgb_Intense then
					ent:Freeze2(self.AbilityDuration)
				else
					ent:Freeze(self.AbilityDuration)
				end
				if self.rotgb_SpeedPercent ~= 1 then
					ent:Slowdown("ROTGB_ICE_TOWER",self.rotgb_SpeedPercent,self.AbilityDuration+3)
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