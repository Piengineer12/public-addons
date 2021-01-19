AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Turret Factory"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Gun those gBalloons!"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/props_phx/gears/bevel90_24.mdl")
ENT.FireRate = 1
ENT.Cost = 500
ENT.DetectionRadius = 256
ENT.AttackDamage = 10
ENT.LOSOffset = Vector(0,0,32)
ENT.UserTargeting = true
ENT.HasAbility = true
ENT.AbilityCooldown = 4
ENT.rotgb_TurretSpeed = 300
ENT.rotgb_TurretRange = 256
ENT.rotgb_CritChance = 0
ENT.rotgb_CritMul = 5
ENT.rotgb_PostMul = 1
ENT.UpgradeReference = {
	{
		Names = {"Speed Up","Speed Up II","High Tech Turrets","Final Moments","Golden Bullets"},
		Descs = {
			"Reduces turret generation delay by 1 second.",
			"Reduces turret generation delay by another second. Also slightly increases the turrets' ranges.",
			"Turrets can now detect Hidden gBalloons.",
			"Turrets that are sparking deal decuple (x10) damage!",
			"Every time a turret hits a gBalloon, gain $10!",
		},
		Prices = {150,800,1500,2500,5000},
		Funcs = {
			function(self)
				self.AbilityCooldown = self.AbilityCooldown * 3/4
			end,
			function(self)
				self.AbilityCooldown = self.AbilityCooldown * 2/3
				self.rotgb_TurretRange = self.rotgb_TurretRange * 1.5
			end,
			function(self)
				self.SeeCamo = true
			end,
			function(self)
				self.rotgb_PostMul = self.rotgb_PostMul * 10
			end,
			function(self)
				self.rotgb_TurretBucks = true
			end
		}
	},
	{
		Names = {"Better Clockwork","Even Better Clockwork","Little Machine Guns","LAZARS!","MOAR LAZARS!!!"},
		Descs = {
			"Slightly increases turrets' speeds and fire rates.",
			"Considerably increases turrets' speeds and fire rates.",
			"Tremendously increases turrets' fire rate.",
			"All turrets now shoot lasers!",
			"All turrets can now hit multiple gBalloons at once!",
		},
		Prices = {400,1750,5000,7500,30000},
		Funcs = {
			function(self)
				self.rotgb_TurretSpeed = self.rotgb_TurretSpeed * 1.5
				self.FireRate = self.FireRate * 1.5
			end,
			function(self)
				self.rotgb_TurretSpeed = self.rotgb_TurretSpeed * 2
				self.FireRate = self.FireRate * 2
			end,
			function(self)
				self.FireRate = self.FireRate * 3
			end,
			function(self)
				self.rotgb_TurretLasers = true
				self.FireRate = self.FireRate * 2
			end,
			function(self)
				self.rotgb_TurretMultihit = true
			end
		}
	},
	{
		Names = {"Bigger Bullets","Critical Bullets","Super Bullets","One With The Crits","Real Bangers"},
		Descs = {
			"Considerably increases the turrets' damage.",
			"Turrets have a 10% chance to critically hit, dealing quintuple (x5) damage and ignoring resistances.",
			"Critical hits now deal quindecuple (x15) damage instead of quintuple damage.",
			"Critical hits now deal quinqueseptuagintuple (x75) damage!",
			"Critical hit chance is reduced to 5%, but critical hits deal quincentuple (x500) damage!",
		},
		Prices = {450,1250,5000,25000,75000},
		Funcs = {
			function(self)
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.rotgb_CritChance = 0.1
			end,
			function(self)
				self.rotgb_CritMul = self.rotgb_CritMul * 3
			end,
			function(self)
				self.rotgb_CritMul = self.rotgb_CritMul * 5
			end,
			function(self)
				self.rotgb_CritChance = self.rotgb_CritChance / 2
				self.rotgb_CritMul = self.rotgb_CritMul * 20 / 3
			end
		}
	}
}
ENT.UpgradeLimits = {5,3,0}

function ENT:FireFunction(gBalloons)
end

function ENT:TriggerAbility()
	local navs = navmesh.Find(self:GetShootPos(), self.DetectionRadius, self.DetectionRadius/4, self.DetectionRadius/4)
	if #navs == 0 then return true
	else
		local point = navs[math.random(#navs)]:GetRandomPoint()
		if self:GetShootPos():DistToSqr(point) > self.DetectionRadius * self.DetectionRadius then return true end
		local ent = ents.Create("gballoon_tower_15_helper")
		if IsValid(ent) then
			ent:SetSpawnedTower(self)
			ent:SetPos(point)
			ent:Spawn()
		else return true
		end
	end
	
end

function ENT:ROTGB_Think()
	if self:GetAbilityNextFire()<CurTime() then
		self:SetAbilityNextFire(CurTime() + self.AbilityCooldown)
		local failed = self:TriggerAbility()
		if failed then
			self:SetAbilityNextFire(0)
		end
	elseif (self.HasAbility and self:GetAbilityNextFire()>CurTime()+self.AbilityCooldown) then
		self:SetAbilityNextFire(0)
	end
end