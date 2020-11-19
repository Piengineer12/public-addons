AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Orb of Cold"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Freeze those gBalloons!"
ENT.Instructions = ""
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/hunter/misc/cone1x05.mdl")
ENT.FireRate = 0.5
ENT.Cost = 450
ENT.DetectionRadius = 512
ENT.AbilityCooldown = 30
ENT.FireWhenNoEnemies = true
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,40)
ENT.AttackDamage = 0
ENT.rotgb_ShardDamage = 10
ENT.rotgb_FreezeFireRate = 0.5
ENT.rotgb_FreezeTime = 1
ENT.rotgb_SpeedPercent = 1
ENT.rotgb_FireRateMul = 1
ENT.UpgradeReference = {
	{
		Names = {"Snappy Freezing","Thorough Freezing","Snappier Freezing","Pathogenic Freezing","Snappiest Freezing"},
		Descs = {
			"Pops one layer when freezing gBalloons.",
			"gBalloons move 50% slower after frozen, for 3 seconds.",
			"Pops 4 layers when freezing gBalloons.",
			"Significantly increases freezing rate. Freezes gBalloons that come in contact with frozen gBalloons in this tower's radius.",
			"Pops 16 layers when freezing gBalloons! White gBalloons still cannot be frozen.",
		},
		Prices = {500,850,5000,7500,40000},
		Funcs = {
			function(self)
				self.rotgb_DoFreezeDamage = true
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.rotgb_SpeedPercent = self.rotgb_SpeedPercent * 0.5
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 30
			end,
			function(self)
				self.rotgb_FreezeFireRate = self.rotgb_FreezeFireRate * 2
				self.rotgb_Viral = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 120
			end
		}
	},
	{
		Names = {"Greater Influence","Better Coolant","Below Zero","Winds of Antarctica","Ice Sign: Absolute Zero"},
		Descs = {
			"Increases freezing range.",
			"gBalloons are frozen for 50% longer. Enables the tower to freeze white gBalloons, but not gBlimps.",
			"Freezing now causes ALL layers to be frozen. Enables the tower to freeze gBlimps weaker than Purple gBlimps.",
			"Every gBalloon in its radius moves 50% slower, even if hidden.",
			"Once every 30 seconds, shooting at this tower causes ALL gBalloons to move 75% slower for 15 seconds.",
		},
		Prices = {200,1250,4000,5000,10000},
		Funcs = {
			function(self)
				self.DetectionRadius = self.DetectionRadius * 1.5
			end,
			function(self)
				self.rotgb_FreezeTime = self.rotgb_FreezeTime * 1.5
				self.rotgb_FreezeBoost = true
			end,
			function(self)
				self.rotgb_Intense = true
			end,
			function(self)
				self.rotgb_SpeedSlowdown = true
			end,
			function(self)
				self.HasAbility = true
			end
		}
	},
	{
		Names = {"Quick Refresher","Agitated Core","Angered Core","Cold Play","Icicle Storm"},
		Descs = {
			"Increases freezing rate.",
			"The Orb of Cold now fires ice shards which pop one layer per shot.",
			"Ice shards are shot twice as often and pop two layers per shot.",
			"Ice shards pop four layers per shot and now have infinite range. Will still freeze gBalloons only in its original radius.",
			"Increases fire rate by 1% per RgBE of every gBalloon within range.",
		},
		Prices = {400,450,3500,10000,45000},
		Funcs = {
			function(self)
				self.FireRate = self.FireRate * 1.5
				self.rotgb_FreezeFireRate = self.rotgb_FreezeFireRate * 1.5
			end,
			function(self)
				self.FireRate = self.FireRate * 4
				self.rotgb_FireRateMul = self.rotgb_FireRateMul * 4
				self.UserTargeting = true
			end,
			function(self)
				self.FireRate = self.FireRate * 2
				self.rotgb_FireRateMul = self.rotgb_FireRateMul * 2
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 20
				self.InfiniteRange = true
			end,
			function(self)
				self.rotgb_FireRateBoost = true
			end
		}
	}
}
ENT.UpgradeLimits = {5,2,0}

function ENT:DoFreeze(ent)
	if (self:ValidTarget(ent) and ent:GetPos():DistToSqr(self:GetShootPos())<=self.DetectionRadius*self.DetectionRadius) then
		if (not ent:GetBalloonProperty("BalloonWhite") or self.rotgb_FreezeBoost)
		and (not ent:GetBalloonProperty("BalloonBlimp") or self.rotgb_Intense and ent:GetBalloonProperty("BalloonType")~="gballoon_blimp_purple" and ent:GetBalloonProperty("BalloonType")~="gballoon_blimp_rainbow")
		or ent:HasRotgBStatusEffect("unimmune") then
			if self.rotgb_Intense then
				ent:Freeze2(self.rotgb_FreezeTime)
			else
				ent:Freeze(self.rotgb_FreezeTime)
			end
			if self.rotgb_SpeedPercent ~= 1 then
				ent:Slowdown("ROTGB_ICE_TOWER",self.rotgb_SpeedPercent,3+self.rotgb_FreezeTime)
			end
		else
			ent:ShowResistEffect(1)
		end
	end
end

function ENT:FireFunction(gBalloons)
	self.rotgb_Freezer = (self.rotgb_Freezer or 0) + self.rotgb_FreezeFireRate/self.rotgb_FireRateMul
	if self.rotgb_Freezer >= 1 then
		self.FireWhenNoEnemies = false
	end
	if self.rotgb_Freezer >= 1 and next(gBalloons) then
		self.rotgb_Freezer = 0
		self.FireWhenNoEnemies = true
		local drrt = self.DetectionRadius*self.DetectionRadius
		if self.rotgb_DoFreezeDamage then
			for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
				if self:ValidTarget(v) and v:GetPos():DistToSqr(self:GetShootPos())<=drrt then
					if (not v:GetBalloonProperty("BalloonWhite") or self.rotgb_FreezeBoost or v:HasRotgBStatusEffect("unimmune"))
					and (not v:GetBalloonProperty("BalloonBlimp") or self.rotgb_Intense and ent:GetBalloonProperty("BalloonType")~="gballoon_blimp_purple" and ent:GetBalloonProperty("BalloonType")~="gballoon_blimp_rainbow") then
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
		self:SetNWFloat("LastFireTime",CurTime())
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
	if self.rotgb_Viral then
		for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
			if self:ValidTarget(v) and ((v.FreezeUntil or 0)>CurTime() or (v.FreezeUntil2 or 0)>CurTime()) then
				for k2,v2 in pairs(ents.FindInSphere(v:GetPos(),self:BoundingRadius()*2)) do
					self:DoFreeze(v2)
				end
			end
		end
	end
	if self.rotgb_SpeedSlowdown then
		for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
			if v:GetClass()=="gballoon_base" then
				v:Slowdown("ROTGB_ICE_TOWER_ARCTIC",0.5,0.25)
			end
		end
	end
end

function ENT:ROTGB_Draw()
	self.DispVec = self.DispVec or Vector()
	self.DispVec.z = math.sin(CurTime()%2*math.pi)*6
	local elapsedseconds = CurTime()-self:GetNWFloat("LastFireTime")
	local dispvec = self.LOSOffset + self.DispVec
	local sat = math.min(math.EaseInOut(math.abs(CurTime()*math.pi/2%2-1),0.5,0.5)/2+0.5,elapsedseconds*math.pi)
	self:DrawModel()
	render.SetColorMaterial()
	render.DrawSphere(self:LocalToWorld(dispvec),6,24,13,HSVToColor(180,sat,1))
end

function ENT:TriggerAbility()
	local entities = ents.FindByClass("gballoon_base")
	if not next(entities) then return true end
	for index,ent in pairs(entities) do
		ent:Slowdown("ROTGB_ICE_TOWER_ABILITY",0.25,15)
	end
end

list.Set("NPC","gballoon_tower_05",{
	Name = ENT.PrintName,
	Class = "gballoon_tower_05",
	Category = ENT.Category
})