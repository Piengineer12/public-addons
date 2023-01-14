AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Microwave Generator"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.tower.gballoon_tower_14.purpose"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/hunter/blocks/cube1x1x025.mdl")
ENT.FireRate = 2
ENT.Cost = 700
ENT.DetectionRadius = 256
ENT.AttackDamage = 10
ENT.LOSOffset = Vector(0,0,32)
ENT.UserTargeting = true
ENT.AbilityCooldown = 45
ENT.AbilityDuration = 15
ENT.rotgb_MicrowaveAngle = 15
ENT.rotgb_AbilityType = 0
ENT.rotgb_Lighten = 0
ENT.rotgb_Shatter = 0
ENT.rotgb_FiresMade = {}
ENT.UpgradeReference = {
	{
		-- 2, 2, 3, 10 (2*5), 3 1/6 (2/3+1/3*5*3/2), 4 (2*2), 8 (2*2*2)
		Prices = {650,1250,5000,65000,150000,600000,2.5e6},
		Funcs = {
			function(self)
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.DetectionRadius = self.DetectionRadius * 2
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 40
			end,
			function(self)
				self.rotgb_Shatter = 1
				self.AttackDamage = self.AttackDamage + 240
			end,
			function(self)
				self.HasAbility = true
				self.rotgb_AbilityType = bit.bor(self.rotgb_AbilityType, 1)
			end,
			function(self)
				self.rotgb_Shatter = 2
				self.FireRate = self.FireRate * 2
			end,
			function(self)
				self.rotgb_Shatter = 3
			end
		}
	},
	{
		-- 2, 3, 4
		Prices = {650,2500,10000,20000,100000,3e6},
		Funcs = {
			function(self)
				self.SeeCamo = true
			end,
			function(self)
				self.rotgb_MicrowaveAngle = self.rotgb_MicrowaveAngle * 3
			end,
			function(self)
				self.rotgb_MicrowaveAngle = self.rotgb_MicrowaveAngle * 4
			end,
			function(self)
				self.rotgb_Lighten = 0.2
			end,
			function(self)
				self.rotgb_Lighten = 1
				self.HasAbility = true
				self.rotgb_AbilityType = bit.bor(self.rotgb_AbilityType, 2)
			end,
			function(self)
				self.rotgb_OmegaFires = true
			end
		}
	}
}
ENT.UpgradeLimits = {7,2}

function ENT:ROTGB_ApplyPerks()
	self.rotgb_MicrowaveAngle = self.rotgb_MicrowaveAngle * (1+hook.Run("GetSkillAmount", "microwaveGeneratorMicrowaveAngle")/100)
end

function ENT:FireFunction(gBalloons)
	self:SetNWFloat("LastFireTime",CurTime())
	local startpos = self:GetShootPos()
	local fireDir = self:WorldToLocal(gBalloons[1]:LocalToWorld(gBalloons[1]:OBBCenter()))
	fireDir.z = 0
	fireDir:Normalize()
	self:SetNWVector("OurTurning",fireDir)
	local anglecos = math.cos(math.min(math.rad(self.rotgb_MicrowaveAngle), math.pi))
	for k,v in pairs(gBalloons) do
		local bpos = self:WorldToLocal(v:LocalToWorld(v:OBBCenter()))
		bpos.z = 0
		bpos:Normalize()
		if bpos:Dot(fireDir) >= anglecos then
			if not v.MicrowaveFire and self.rotgb_Lighten > math.random() then
				local damage = (10 + self:GetFireDamageBonus()) * (self.rotgb_OmegaFires and 25 or 1)
				v:RotgB_Ignite(damage, self:GetTowerOwner(), self, 1000000)
				v.MicrowaveFire = true
				table.insert(self.rotgb_FiresMade, CurTime() + 10)
			end
			if self.rotgb_Shatter >= 3 then
				v:SetBalloonProperty("BalloonRegen", false)
				v:SetBalloonProperty("BalloonFast", false)
				v:SetBalloonProperty("BalloonShielded", false)
			end
			if self.rotgb_Shatter >= 2 then
				v:InflictRotgBStatusEffect("unimmune", 999999)
			end
			if self.rotgb_Shatter >= 1 then
				v:SetBalloonProperty("BalloonHidden", false)
			end
			v:TakeDamage(self.AttackDamage,self:GetTowerOwner(),self)
		end
	end
end

function ENT:GetFireDamageBonus()
	for k,v in pairs(self.rotgb_FiresMade) do
		if v < CurTime() then
			self.rotgb_FiresMade[k] = nil
		end
	end
	return table.Count(self.rotgb_FiresMade) * 10
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
	self:SetNWFloat("rotgb_CC", CurTime()+self.AbilityDuration)
	if bit.band(self.rotgb_AbilityType, 1) == 1 then
		self:ApplyBuff(self, "ROTGB_TOWER_14_ABILITY", self.AbilityDuration, function(tower)
			tower.FireRate = tower.FireRate * 5
			tower.rotgb_MicrowaveAngle = tower.rotgb_MicrowaveAngle * 3
		end, function(tower)
			tower.FireRate = tower.FireRate / 5
			tower.rotgb_MicrowaveAngle = tower.rotgb_MicrowaveAngle / 3
		end)
	end
	if bit.band(self.rotgb_AbilityType, 2) == 2 then
		self.AttackDamage = self.AttackDamage + 190
		local timetoinsert = CurTime() + self.AbilityDuration
		for i=1,95 do
			table.insert(self.rotgb_FiresMade, timetoinsert)
		end
	end
end