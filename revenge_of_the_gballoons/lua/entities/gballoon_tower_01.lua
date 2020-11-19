AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Electrostatic Barrel"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Zap those gBalloons!"
ENT.Instructions = ""
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/props_phx/facepunch_barrel.mdl")
ENT.FireRate = 1
ENT.Cost = 500
ENT.DetectionRadius = 384
ENT.AttackDamage = 10
ENT.UserTargeting = true
ENT.rotgb_Radius = 128
ENT.rotgb_Bounces = 4
ENT.UpgradeReference = {
	{
		Names = {"Long Spark","Faster Recharge","High Farad Capacitors","Recursive Zap"},
		Descs = {
			"Increases the travel distance of electrostatic jumps.",
			"Static electricity is generated faster.",
			"Static electricity is generated even faster and deals more damage.",
			"Static electricity can now hit multiple gBalloons and bounce on the same gBalloon multiple times, resulting in extremely large amounts of damage per hit."
		},
		Prices = {250,700,4000,35000},
		Funcs = {
			function(self)
				self.rotgb_Radius = self.rotgb_Radius * 2
			end,
			function(self)
				self.FireRate = self.FireRate*2
			end,
			function(self)
				self.FireRate = self.FireRate*2
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.rotgb_Recursion = 1
			end
		}
	},
	{
		Names = {"High Voltage","Wild Sparks","Heart Stopper","Electromagnetic Pulser"},
		Descs = {
			"Doubles the number of electrostatic jumps.",
			"Electrostatic jumps can hit hidden gBalloons.",
			"On hit, stuns gBalloons for 0.25s and Regen gBalloons may only regenerate up to their current tier.",
			"This tower now radiates an electric field that shocks all gBalloons within its radius. Also considerably increases range and enables the tower to pop Purple gBalloons."
		},
		Prices = {400,1000,2000,15000},
		Funcs = {
			function(self)
				self.rotgb_Bounces = self.rotgb_Bounces * 2
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
			end
		}
	}
}
ENT.UpgradeLimits = {4,2}

function ENT:AccumulategBalloons(tab1)
	local success
	local count = 1
	for ki,vi in pairs(tab1) do
		if IsValid(ki) then
			for k,v in pairs(ents.FindInSphere(ki:GetPos(),self.rotgb_Radius)) do
				if self:ValidTarget(v) and (not tab1[v] or self.rotgb_Recursion) then
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

function ENT:FireFunction(gBalloons)
	local enttable = {[gBalloons[1]]=self}
	local delta = 0
	for i=1,self.rotgb_Bounces do
		if not self:AccumulategBalloons(enttable) then break end
	end
	if not self.UserTargeting then
		table.Empty(enttable)
		for k,v in pairs(gBalloons) do
			enttable[v] = self
			v.Recurse = 1
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
			dmginfo:SetDamage(self.AttackDamage*(k.Recurse or 1)*(self.rotgb_Recursion or 1))
			--dmginfo:SetMaxDamage(self.AttackDamage*(k.Recurse or 1)*(self.rotgb_Recursion or 1))
			if k:GetBalloonProperty("BalloonPurple") and not self.UserTargeting then
				dmginfo:SetDamageType(DMG_GENERIC)
				k:TakeDamageInfo(dmginfo)
				dmginfo:SetDamageType(DMG_SHOCK)
			else
				k:TakeDamageInfo(dmginfo)
			end
			k.Recurse = nil
		--elseif IsValid(k) then
			--k:ShowResistEffect(3)
		end
	end
end

list.Set("NPC","gballoon_tower_01",{
	Name = ENT.PrintName,
	Class = "gballoon_tower_01",
	Category = ENT.Category
})