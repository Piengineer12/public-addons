AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Electrostatic Barrel"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "This tower fires electrical sparks that arc from one gBalloon to another, provided that they are close enough to each other."
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/props_phx/facepunch_barrel.mdl")
ENT.FireRate = 2
ENT.Cost = 500
ENT.DetectionRadius = 192
ENT.AttackDamage = 10
ENT.UserTargeting = true
ENT.rotgb_Radius = 64
ENT.rotgb_Bounces = 4
ENT.UpgradeReference = {
	{
		Names = {"High Voltage","Faster Recharge","Instant Discharger","Recursive Zap","Extreme Voltage"},
		Descs = {
			"Considerably increases the number of electrostatic jumps.",
			"Static electricity is generated considerably faster.",
			"Static electricity is generated tremendously faster and deals considerably more damage.",
			"Static electricity can now hit multiple gBalloons and bounce on the same gBalloon multiple times, resulting in extremely large amounts of damage per hit.",
			"Tremendously increases the number of electrostatic jumps. Enables the tower to pop Purple gBalloons.",
		},
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
		Names = {"Long Spark","Wild Sparks","Heart Stopper","Electromagnetic Pulser","Supercell"},
		Descs = {
			"Considerably increases the travel distance of electrostatic jumps.",
			"Electrostatic jumps can hit hidden gBalloons.",
			"On hit, stuns gBalloons for 0.25s and Regen gBalloons may only regenerate up to their current tier.",
			"This tower now radiates an electric field that shocks all gBalloons within its radius. Also considerably increases range and enables the tower to pop Purple gBalloons.",
			"Tremendously increases attack damage, fire rate and range."
		},
		Prices = {450,1000,2000,25000,750000},
		Funcs = {
			function(self)
				self.rotgb_Radius = self.rotgb_Radius * 2
			end,
			function(self)
				self.SeeCamo = true
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

function ENT:AccumulategBalloons(tab1)
	local success
	local count = 1
	for ki,vi in pairs(tab1) do
		if IsValid(ki) then
			for k,v in pairs(ents.FindInSphere(ki:GetPos(),self.rotgb_Radius)) do
				if self:ValidTargetIgnoreRange(v) and (not tab1[v] or self.rotgb_Recursion) then
					v.Recurse = (v.Recurse or 0) + 1
					count = count + 1
					tab1[v] = ki
					success = true
					if count >= self.rotgb_Bounces and not self.rotgb_Recursion then return end
				end
			end
		end
	end
	return success
end

function ENT:AccumulategBalloons(first)
	local accumulated = {[first]=1}
	local count = 0
	local worldSpaceCenters = {}
	for k,v in pairs(ROTGB_GetBalloons()) do
		if self:ValidTargetIgnoreRange(v) then
			worldSpaceCenters[v] = v:LocalToWorld(v:WorldSpaceCenter())
		end
	end
	for i=1,self.rotgb_Bounces do
		local accumulateAdd = {}
		for k,v in pairs(accumulated) do
			for k2,v2 in pairs(worldSpaceCenters) do
				local currentChains = accumulateAdd[k2] or 0
				if worldSpaceCenters[k]:DistToSqr(v2) <= self.rotgb_Radius * self.rotgb_Radius and (currentChains <= 0 and not accumulated[k2] or self.rotgb_Recursion) then
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
	local dmginfo = DamageInfo()
	--dmginfo:SetAmmoType(game.GetAmmoID("Battery"))
	dmginfo:SetAttacker(self:GetTowerOwner())
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(DMG_SHOCK)
	dmginfo:SetReportedPosition(self:GetPos())
	--[[local effdata = EffectData()
	effdata:SetMagnitude(10)
	effdata:SetScale(10)
	effdata:SetRadius(self.DetectionRadius)
	effdata:SetOrigin(Vector(self:GetPos()))]]
	for k,v in pairs(enttable) do
		if IsValid(k) then--(IsValid(k) and (not k:GetBalloonProperty("BalloonPurple") or not self.UserTargeting or k:HasRotgBStatusEffect("unimmune"))) then
			--[[effdata:SetStart(Vector(v:GetPos()))
			effdata:SetEntity(k)
			util.Effect("TeslaZap",effdata,true,true)]]
			dmginfo:SetDamagePosition(k:GetPos())
			if self.rotgb_StopRegen then
				k.PrevBalloons = nil
				k:Stun(0.25)
			end
			--[[if self.rotgb_Stun and k:GetBalloonProperty("BalloonType")~="gballoon_blimp_purple" and k:GetBalloonProperty("BalloonType")~="gballoon_blimp_rainbow" then
				k:Stun(1)
			end]]
			dmginfo:SetDamage(self.AttackDamage*v)
			--dmginfo:SetMaxDamage(self.AttackDamage*(k.Recurse or 1)*(self.rotgb_Recursion or 1))
			if k:GetBalloonProperty("BalloonPurple") and self.rotgb_HitPurple then
				dmginfo:SetDamageType(DMG_GENERIC)
				k:TakeDamageInfo(dmginfo)
				dmginfo:SetDamageType(DMG_SHOCK)
			else
				k:TakeDamageInfo(dmginfo)
			end
		--elseif IsValid(k) then
			--k:ShowResistEffect(3)
		end
	end
end