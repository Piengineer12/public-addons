AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Turret Factory"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.tower.gballoon_tower_15.purpose"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/props_phx/gears/bevel90_24.mdl")
ENT.FireRate = 1
ENT.Cost = 500
ENT.DetectionRadius = 256
ENT.InfiniteRange2 = true
ENT.AttackDamage = 10
ENT.LOSOffset = Vector(0,0,32)
ENT.UserTargeting = true
ENT.HasAbility = true
ENT.AbilityCooldown = 4
ENT.rotgb_TurretSpeed = 300
ENT.rotgb_TurretRange = 256
ENT.rotgb_CritChance = 0
ENT.rotgb_CritMul = 5
ENT.rotgb_PostFireRate = 1
ENT.rotgb_PostMul = 1
ENT.UpgradeReference = {
	{
		Names = {"Speed Up","High Tech Turrets","All Out Attack","Final Moments","Golden Bullets","Rope Bullets"},
		Descs = {
			"Reduces turret generation delay by 1 second.",
			"Reduces turret generation delay by another second. Also allows turrets to detect Hidden gBalloons.",
			"Turrets that are sparking fire 10 times faster!",
			"Turrets that are sparking deal decuple (x10) damage!",
			"Every time a turret hits a gBalloon, gain $20!",
			"Bullets slow down Green gBlimps and lower by 75% for 1 second!"
		},
		Prices = {150,1500,1750,20000,50000,5e6},
		Funcs = {
			function(self)
				self.AbilityCooldown = self.AbilityCooldown * 3/4
			end,
			function(self)
				self.AbilityCooldown = self.AbilityCooldown * 2/3
				self.SeeCamo = true
			end,
			function(self)
				self.rotgb_PostFireRate = self.rotgb_PostFireRate * 10
			end,
			function(self)
				self.rotgb_PostMul = self.rotgb_PostMul * 10
			end,
			function(self)
				self.rotgb_TurretBucks = true
			end,
			function(self)
				self.rotgb_Slowdown = true
			end
		}
	},
	{
		Names = {"Better Clockwork","Even Better Clockwork","Little Machine Guns","LAZARS!","MOAR LAZARS!!!"},
		Descs = {
			"Slightly increases turrets' speeds and fire rates.",
			"Considerably increases turrets' speeds and fire rates.",
			"Tremendously increases turrets' speeds and fire rates.",
			"All turrets now shoot lasers!",
			"All turrets can now hit multiple gBalloons at once!",
		},
		Prices = {200,650,2500,4000,30000},
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
				self.rotgb_TurretSpeed = self.rotgb_TurretSpeed * 3
				self.FireRate = self.FireRate * 3
			end,
			function(self)
				self.rotgb_TurretLasers = true
				self.MaxFireRate = 10
				self.FireRate = self.FireRate * 2
			end,
			function(self)
				self.rotgb_TurretMultihit = true
			end
		}
	},
	{
		Names = {"Bigger Bullets","Critical Bullets","Super Bullets","One With The Crits","Real Bangers","Killshots","Extreme Precision"},
		Descs = {
			"Considerably increases the turrets' damage.",
			"Turrets have a 20% chance to critically hit, dealing quintuple (x5) damage and ignoring resistances.",
			"Critical hits now deal quindecuple (x15) damage instead of quintuple damage.",
			"Critical hits now deal quinqueseptuagintuple (x75) damage!",
			"Critical hit chance is reduced to 10%, but critical hits deal quincentuple (x500) damage!",
			"Critical hit chance is reduced to 1%, but if it crits...!",
			"Critical hit chance is increased back to 20%."
		},
		Prices = {450,850,1850,10000,30000,1.5e6,30e6},
		Funcs = {
			function(self)
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.rotgb_CritChance = 0.2
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
			end,
			function(self)
				self.rotgb_CritChance = self.rotgb_CritChance / 10
				self.rotgb_CritMul = self.rotgb_CritMul * 400
			end,
			function(self)
				self.rotgb_CritChance = self.rotgb_CritChance * 20
			end,
		}
	}
}
ENT.UpgradeLimits = {7,2,0}

function ENT:ROTGB_ApplyPerks()
	self.AbilityCooldown = self.AbilityCooldown * (1+hook.Run("GetSkillAmount", "turretFactoryAbilityCooldown")/100)
end

function ENT:TriggerAbility()
	local navs = navmesh.Find(self:GetShootPos(), self.DetectionRadius, self.DetectionRadius/4, self.DetectionRadius/4)
	if next(navs) then
		local point = navs[math.random(#navs)]:GetRandomPoint()
		if self:GetShootPos():DistToSqr(point) > self.DetectionRadius * self.DetectionRadius then return true end
		local ent = ents.Create("gballoon_tower_15_helper")
		if IsValid(ent) then
			ent:SetSpawnedTower(self)
			ent:SetPos(point)
			ent:Spawn()
		else return true
		end
	else
		-- get a random point on a circle extending outwards from the tower
		-- with range between 32 and detection radius
		local randomDistance = Lerp(math.random(), 32, self.DetectionRadius)
		local randomAngle = math.random()*math.pi*2
		local xoffset = math.cos(randomAngle)*randomDistance
		local yoffset = math.sin(randomAngle)*randomDistance
		
		-- now the point should be projected onto a dome covering the top of the tower
		local zoffset = math.sqrt(1 - (randomDistance/self.DetectionRadius)^2)*randomDistance
		
		-- create a line trace
		local startPos = self:LocalToWorld(Vector(xoffset, yoffset, zoffset))
		local endPos = self:LocalToWorld(Vector(xoffset, yoffset, -zoffset))
		local traceData = {
			start = startPos,
			endpos = endPos
		}
		local result = util.TraceLine(traceData)
		if not result.StartSolid and result.Hit then
			local ent = ents.Create("gballoon_tower_15_helper")
			if IsValid(ent) then
				ent:SetSpawnedTower(self)
				ent:SetPos(result.HitPos)
				ent:Spawn()
			else return true
			end
		else return true
		end
	end
	
end

function ENT:ROTGB_Think()
	if self:GetAbilityCharge()>=1 then
		self:DoAbility()
	end
end