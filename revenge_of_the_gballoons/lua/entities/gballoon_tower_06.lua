AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Multipurpose Engine"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.tower.gballoon_tower_06.purpose"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/maxofs2d/hover_propeller.mdl")
ENT.FireRate = 100
ENT.Cost = 600
ENT.AbilityCooldown = 30
ENT.AbilityDuration = 15
ENT.LOSOffset = Vector(0,0,25)
ENT.AttackDamage = 0
ENT.DetectionRadius = 512
ENT.SeeCamo = true
ENT.InfiniteRange2 = true
ENT.rotgb_Buff = 0
ENT.rotgb_AttackDamageMul = 1
ENT.UpgradeReference = {
	{
		Prices = {0,10e3,100e3,1e6,10e6,100e6},
		Funcs = {
			function(self)
				self.rotgb_NoRegen = true
			end,
			function(self)
				self.rotgb_NoFast = true
			end,
			function(self)
				self.rotgb_NoHidden = true
			end,
			function(self)
				self.rotgb_NoShielded = true
			end,
			function(self)
				self.rotgb_NoImmunities = true
			end,
			function(self)
				self.HasAbility = true
			end
		}
	},
	{
		Prices = {2000,3000,18000,170000,785000,3.65e6,17.5e6,51e6,210e6,1.00e9},
		Funcs = {
			function(self)
				self.AttackDamage = self.AttackDamage + 20
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 30
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 180
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 1730
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 7880
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 36520
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 179080
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 511360
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 2110470
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 10499990
			end,
		},
		FusionRequirements = {[10] = true}
	},
	{
		Prices = {5000,20e3,75e3,300e3},
		Funcs = {
			function(self)
				self.rotgb_Buff = 1
				self.FireWhenNoEnemies = true
			end,
			function(self)
				self.rotgb_Buff = 2
			end,
			function(self)
				self.rotgb_Buff = 3
			end,
			function(self)
				self.rotgb_Buff = 4
			end,
			--[[function(self)
				self.rotgb_Buff = 5
			end]]
		}
	}
}
ENT.UpgradeLimits = {10,2,0}

--[[function ENT:FireFunction(gBalloons)
	if self.rotgb_Buff > 4 then
		self.rotgb_TowerCharge = (self.rotgb_TowerCharge or 0) + 1
		if self.rotgb_TowerCharge >= 60 then
			self.rotgb_TowerCharge = 0
			for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
				if v:GetClass()=="gballoon_tower_base" then
					v.FireRate = v.FireRate * 1.05
					v.DetectionRadius = v.DetectionRadius * 1.05
				end
			end
		end
	end
end]]

function ENT:FireFunction(gBalloons)
	local anotherfired = 0
	local radiusTowers = {}
	for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
		if self:ValidTargetIgnoreRange(v) and v:WorldSpaceCenter():DistToSqr(self:GetShootPos()) <= self.DetectionRadius * self.DetectionRadius then
			if self.rotgb_NoRegen then
				v:SetBalloonProperty("BalloonRegen", false)
			end
			if self.rotgb_NoFast then
				v:SetBalloonProperty("BalloonFast", false)
			end
			if self.rotgb_NoHidden then
				v:SetBalloonProperty("BalloonHidden", false)
			end
			if self.rotgb_NoShielded then
				v:SetBalloonProperty("BalloonShielded", false)
			end
			if self.rotgb_NoImmunities then
				v:InflictRotgBStatusEffect("unimmune",999999)
			end
			if v:GetRgBE() <= self.AttackDamage/10*(1+self.FusionPower/100)*self.rotgb_AttackDamageMul and self.AttackDamage > 0 then
				self:DealDamage(v, 2147483647, DMG_DISSOLVE)
			end
		elseif v.Base=="gballoon_tower_base" then
			if self.rotgb_Buff > 1 then
				v:AddDelayedActions(self, "ROTGB_TOWER_06_PASSIVE_2", 0, function(tower)
					tower.AttackDamage = (tower.AttackDamage or 0) + 10
				end, 1, function(tower)
					tower.AttackDamage = (tower.AttackDamage or 0) - 10
				end)
			end
			if self.rotgb_Buff > 2 then
				v:AddDelayedActions(self, "ROTGB_TOWER_06_PASSIVE", 0, function(tower)
					tower.FireRate = tower.FireRate * 1.2
				end, 1, function(tower)
					tower.FireRate = tower.FireRate / 1.2
				end)
			end
			if self.rotgb_Buff > 3 and v ~= self then
				v:AddDelayedActions(self, "ROTGB_TOWER_06_PASSIVE_3", 0, function(tower)
					tower:SetNWBool("rotgb_tower_06_discount", true)
				end, 1, function(tower)
					tower:SetNWBool("rotgb_tower_06_discount", false)
				end)
			end
			--[[if self.rotgb_Buff > 4 and v ~= self then
				v:AddDelayedActions(self, "ROTGB_TOWER_06_PASSIVE_4", 0, function(tower)
					tower:SetNWBool("rotgb_noupgradelimit", true)
				end, 1, function(tower)
					tower:SetNWBool("rotgb_noupgradelimit", false)
				end)
			end]]
		end
	end
end

function ENT:TriggerAbility()
	for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
		if v.Base=="gballoon_tower_base" then
			local fusionFactor = 1+self.FusionPower/100
			v:AddDelayedActions(self, "ROTGB_TOWER_06_TM", 0, function(tower)
				tower.AttackDamage = (tower.AttackDamage or 0) + 100e3*fusionFactor
			end, self.AbilityDuration, function(tower)
				tower.AttackDamage = (tower.AttackDamage or 0) - 100e3*fusionFactor
			end)
		end
	end
end

hook.Add("RotgBBalloonDealDamage", "ROTGB_TOWER_06", function(data)
	local insure = {}
	for k,v in pairs(ents.FindByClass("gballoon_tower_06")) do
		if v.rotgb_Buff > 0 then table.insert(insure, v) end
	end
	if #insure > 0 then
		local cash = data.damage*1000*player.GetCount()
		for k,v in pairs(insure) do
			v:AddCash(cash)
		end
	end
end)