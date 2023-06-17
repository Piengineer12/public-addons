local gballoon_tower_minion_base = baseclass.Get("gballoon_tower_minion_base")
AddCSLuaFile()

ENT.Model = "models/hunter/misc/cone2x2.mdl"
ENT.LifeTime = 60
ENT.FireRate = 1
ENT.MinionSpeed = 0
ENT.DetectionRadius = 64
ENT.GoalTolerance = 0
ENT.rotgb_Durability = 100

function ENT:Initialize()
	gballoon_tower_minion_base.Initialize(self)
	self:SetMaterial("models/XQM/LightLinesRed_tool")
	local barricades = ents.FindByClass("gballoon_tower_18_minion")
	
	for i,v in ipairs(barricades) do
		v.rotgb_Barricades = #barricades
	end
end

function ENT:Think()
	gballoon_tower_minion_base.Think(self)
	
	if SERVER then
		local tower = self:GetTower()
		if IsValid(tower) then
			local efficiency = 1 + (tower.rotgb_BarricadeMulti and (self.rotgb_Barricades - 1) / 10 or 0)
			for k,v in pairs(ents.FindInSphere(self:GetPos(), self:GetDetectionRadius())) do
				if tower:ValidTargetIgnoreRange(v) then
					v:Stun(0.5)
					tower:DealDamage(v, tower.rotgb_BarricadeDamage * self.FireRate * efficiency, DMG_GENERIC)
					self.rotgb_Durability = self.rotgb_Durability - self.FireRate / efficiency
					
					if self.rotgb_Durability <= 0 then
						self:Remove() break
					end
				end
			end
		end
	end
end

function ENT:GetMinionSpeed()
	local tower = self:GetTower()
	if IsValid(tower) then
		return tower.rotgb_BarricadeSpeed
	else
		return self.MinionSpeed
	end
end

function ENT:OnRemove()
	local barricades = ents.FindByClass("gballoon_tower_18_minion")
	
	for i,v in ipairs(barricades) do
		v.rotgb_Barricades = #barricades - 1
	end
end