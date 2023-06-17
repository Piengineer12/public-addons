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
		-- 4/3, 3 (1.5*2), 1.45 (19/20+1/20*10), 5.95 (19/20+1/20*10*10)
		Prices = {150,1250,850,12500,50000,5e6},
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
				self.MaxFireRate = 1/0.115
				self.FireRate = self.FireRate * 2
			end,
			function(self)
				self.rotgb_TurretMultihit = true
			end
		}
	},
	{
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
		local ent = ents.Create("gballoon_tower_15_minion")
		if IsValid(ent) then
			ent:SetTower(self)
			ent:SetPos(point)
			ent:Spawn()
		else return true
		end
	else
		-- get a random point on a circle extending outwards from the tower
		-- with range between 32 and detection radius
		-- points closer to the tower are more likely to be chosen - this is intentional
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
			local ent = ents.Create("gballoon_tower_15_minion")
			if IsValid(ent) then
				ent:SetTower(self)
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