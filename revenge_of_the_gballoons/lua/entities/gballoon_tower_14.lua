AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Microwave Generator"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Cook those gBalloons!"
ENT.Instructions = ""
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/hunter/blocks/cube1x1x025.mdl")
ENT.FireRate = 0.5
ENT.Cost = 700
ENT.DetectionRadius = 512
ENT.AttackDamage = 10
ENT.LOSOffset = Vector(0,0,32)
ENT.UserTargeting = true
ENT.AbilityCooldown = 45
ENT.rotgb_MicrowaveAngle = 20
ENT.rotgb_AbilityType = 0
ENT.rotgb_Lighten = 0
ENT.rotgb_FiresMade = {}
ENT.UpgradeReference = {
	{
		Names = {"Concentrated Waves","Intense Waves","Thermal Detection","Super Intense Waves","Extreme Frequency Waves"},
		Descs = {
			"Slightly increases the tower's range.",
			"Considerably increases microwave damage.",
			"Enables the tower to see hidden gBalloons.",
			"Tremendously increases microwave damage.",
			"Colossally increases microwave damage. Once every 45 seconds, firing at this tower colossally increases fire rate and triples the width of microwaves for 10 seconds.",
		},
		Prices = {300,900,2000,7500,100000},
		Funcs = {
			function(self)
				self.DetectionRadius = self.DetectionRadius * 1.5
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.SeeCamo = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 40
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 240
				self.HasAbility = true
				self.rotgb_AbilityType = bit.bor(self.rotgb_AbilityType, 1)
			end
		}
	},
	{
		Names = {"Stronger Battery","Diffractional Waves","Open Fryer","20-Star Fryer","gBalloon S.E.A.R."},
		Descs = {
			"Increases the tower's fire rate.",
			"Triples the width of microwaves.",
			"Microwaves are now emitted in all directions.",
			"Microwaves now have a 20% chance to set gBalloons on fire permanently. Every time the tower successfully does this, fires from this tower pop one extra layer for 10 seconds. This effect stacks.",
			"Microwaves are now guaranteed to set gBalloons alight. Once every 45 seconds, firing at this tower massively increases damage dealt for 10 seconds.",
		},
		Prices = {300,1000,2000,3000,50000},
		Funcs = {
			function(self)
				self.FireRate = self.FireRate * 1.5
			end,
			function(self)
				self.rotgb_MicrowaveAngle = self.rotgb_MicrowaveAngle * 3
			end,
			function(self)
				self.rotgb_MicrowaveAngle = self.rotgb_MicrowaveAngle * 3
			end,
			function(self)
				self.rotgb_Lighten = 0.2
			end,
			function(self)
				self.rotgb_Lighten = 1
				self.HasAbility = true
				self.rotgb_AbilityType = bit.bor(self.rotgb_AbilityType, 2)
			end
		}
	}
}
ENT.UpgradeLimits = {5,2}

function ENT:FireFunction(gBalloons)
	self:SetNWFloat("LastFireTime",CurTime())
	local startpos = self:GetShootPos()
	local fireDir = self:WorldToLocal(gBalloons[1]:LocalToWorld(gBalloons[1]:OBBCenter()))
	fireDir.z = 0
	fireDir:Normalize()
	self:SetNWVector("OurTurning",fireDir)
	local anglecos = math.cos(math.rad(self.rotgb_MicrowaveAngle))
	for k,v in pairs(gBalloons) do
		local bpos = self:WorldToLocal(v:LocalToWorld(v:OBBCenter()))
		bpos.z = 0
		bpos:Normalize()
		if bpos:Dot(fireDir) >= anglecos then
			v:TakeDamage(self.AttackDamage,self:GetTowerOwner(),self)
			if not v.MicrowaveFire and self.rotgb_Lighten > math.random() then
				v:RotgB_Ignite(10 + self:GetFireDamageBonus(), self:GetTowerOwner(), self, 1000000)
				v.MicrowaveFire = true
				table.insert(self.rotgb_FiresMade, CurTime() + 10)
			end
		end
	end
end

function ENT:GetFireDamageBonus()
	for k,v in pairs(self.rotgb_FiresMade) do
		if v < CurTime() then
			self.rotgb_FiresMade[k] = nil
		end
	end
	return #self.rotgb_FiresMade * 10
end

local laserMat = Material("trails/laser")
local layer_color = Color(255,255,255,31)
function ENT:ROTGB_Draw()
	local delta = math.Clamp(math.Remap(1/self.FireRate+self:GetNWFloat("LastFireTime",0)-CurTime(),1/self.FireRate,0,1,0),0,1)
	local abilitydelta = math.Clamp(math.Remap(self:GetNWFloat("rotgb_CC")-CurTime(),10,0,1,0),0,1)
	local desiredangle = Angle(0,90*CurTime()%360,0)
	if not self:GetNWVector("OurTurning",vector_origin):IsZero() and delta > 0 then
		local gdir = self:GetNWVector("OurTurning")+vector_origin
		local abmul = abilitydelta > 0 and bit.band(self.rotgb_AbilityType, 1) == 1 and 3 or 1
		gdir:Rotate(Angle(0,-self.rotgb_MicrowaveAngle*abmul,0))
		render.SetMaterial(laserMat)
		for i=0,2,0.125 do
			render.DrawBeam(self:GetShootPos(),self:LocalToWorld(gdir*(self.InfiniteRange and 32768 or self.DetectionRadius)+self.LOSOffset),4,0,1,Color(255,255,0,delta*255))
			gdir:Rotate(Angle(0,self.rotgb_MicrowaveAngle*0.125*abmul,0))
		end
	end
	render.SetColorMaterial()
	render.DrawBox(self:GetShootPos(),self:LocalToWorldAngles(desiredangle),Vector(-8,-8,-8),Vector(8,8,8),Color(255,255,abilitydelta*255))
	for i=1,6 do
		if i == 5 then
			desiredangle = Angle(89.99, desiredangle[2], 0)
		elseif i == 6 then
			desiredangle = Angle(-89.99, desiredangle[2], 0)
		else
			desiredangle:RotateAroundAxis(vector_up,90)
		end
		local preangle = self:LocalToWorldAngles(desiredangle)
		local normal = preangle:Forward()
		local dist = normal*(delta+1)*12
		render.DrawQuadEasy(self:GetShootPos()+dist, normal, 16, 16, layer_color, preangle[3])
		render.DrawQuadEasy(self:GetShootPos()+dist, -normal, 16, 16, layer_color, -preangle[3])
	end
end

function ENT:TriggerAbility()
	self:SetNWFloat("rotgb_CC", CurTime()+10)
	if bit.band(self.rotgb_AbilityType, 1) == 1 then
		self.FireRate = self.FireRate * 5
		self.rotgb_MicrowaveAngle = self.rotgb_MicrowaveAngle * 3
		timer.Simple(10,function()
			if IsValid(self) then
				self.FireRate = self.FireRate / 5
				self.rotgb_MicrowaveAngle = self.rotgb_MicrowaveAngle / 3
			end
		end)
	end
	if bit.band(self.rotgb_AbilityType, 2) == 2 then
		self.AttackDamage = self.AttackDamage + 190
		local timetoinsert = CurTime() + 10
		for i=1,95 do
			table.insert(self.rotgb_FiresMade, timetoinsert)
		end
	end
end

list.Set("NPC","gballoon_tower_14",{
	Name = ENT.PrintName,
	Class = "gballoon_tower_14",
	Category = ENT.Category
})