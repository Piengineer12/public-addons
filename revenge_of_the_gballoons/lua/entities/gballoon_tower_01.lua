AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Electrostatic Barrel"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.tower.gballoon_tower_01.purpose"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/props_phx/facepunch_barrel.mdl")
ENT.FireRate = 2
ENT.Cost = 500
ENT.DetectionRadius = 256
ENT.AttackDamage = 10
ENT.UserTargeting = true
ENT.rotgb_Radius = 64
ENT.rotgb_Bounces = 4
ENT.UpgradeReference = {
	{
		Prices = {450,850,7500,125000,1.2e6},
		Funcs = {
			function(self)
				self.rotgb_Bounces = self.rotgb_Bounces * 2
			end,
			function(self)
				self.FireRate = self.FireRate*2
			end,
			function(self)
				self.FireRate = self.FireRate*3
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.rotgb_Recursion = 1
			end,
			function(self)
				self.rotgb_Bounces = self.rotgb_Bounces * 3
				self.rotgb_HitPurple = true
			end,
		}
	},
	{
		-- 2, 2, 2, 8 (2*2*2), 27 (3*3*3)
		Prices = {450,900,1750,25000,700000},
		Funcs = {
			function(self)
				self.SeeCamo = true
			end,
			function(self)
				self.rotgb_Radius = self.rotgb_Radius * 2
			end,
			function(self)
				self.rotgb_StopRegen = true
			end,
			function(self)
				self.rotgb_Bounces = 0
				self.DetectionRadius = self.DetectionRadius * 2
				self.UserTargeting = false
				self.rotgb_HitPurple = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 20
				--self.rotgb_Bounces = 99
				self.FireRate = self.FireRate * 3
				self.rotgb_Radius = self.rotgb_Radius * 3
				--self.UserTargeting = true
			end
		}
	}
}
ENT.UpgradeLimits = {5,2}

function ENT:ROTGB_ApplyPerks()
	self.rotgb_Bounces = self.rotgb_Bounces + hook.Run("GetSkillAmount", "electrostaticBarrelBounces")
end

function ENT:AccumulategBalloons(first)
	local accumulated = {[first]=1}
	local count = 0
	local worldSpaceCenters = {}
	for k,v in pairs(ROTGB_GetBalloons()) do
		if self:ValidTargetIgnoreRange(v) then
			worldSpaceCenters[v] = v:WorldSpaceCenter()
		end
	end
	for i=1,self.rotgb_Bounces do
		local accumulateAdd = {}
		for k,v in pairs(accumulated) do
			local currentChainPos = worldSpaceCenters[k]
			
			for k2,v2 in pairs(worldSpaceCenters) do
				local currentChains = accumulateAdd[k2] or 0
				if currentChainPos:DistToSqr(v2) <= self.rotgb_Radius^2 and (currentChains <= 0 and not accumulated[k2] or self.rotgb_Recursion) then
					accumulateAdd[k2] = currentChains + 1
					count = count + 1
					if count >= self.rotgb_Bounces and not self.rotgb_Recursion then break end
				end
			end
			if count >= self.rotgb_Bounces and not self.rotgb_Recursion then break end
		end
		for k,v in pairs(accumulateAdd) do
			accumulated[k] = (accumulated[k] or 0) + v
		end
	end
	return accumulated
end

function ENT:FireFunction(gBalloons)
	local enttable
	local delta = 0
	if self.UserTargeting then
		enttable = self:AccumulategBalloons(gBalloons[1])
	else
		enttable = {}
		for k,v in pairs(gBalloons) do
			enttable[v] = 1
		end
	end
	
	local dmginfo = self:CreateDamage(nil, DMG_SHOCK)
	for k,v in pairs(enttable) do
		if IsValid(k) then
			if self.rotgb_StopRegen then
				k.PrevBalloons = nil
				k:Stun(0.25)
			end
			
			dmginfo:SetDamage(self.AttackDamage*v)
			if k:GetBalloonProperty("BalloonPurple") and self.rotgb_HitPurple then
				dmginfo:SetDamageType(DMG_GENERIC)
				self:DealDamage(k, dmginfo)
				dmginfo:SetDamageType(DMG_SHOCK)
			else
				self:DealDamage(k, dmginfo)
			end
		end
	end
end