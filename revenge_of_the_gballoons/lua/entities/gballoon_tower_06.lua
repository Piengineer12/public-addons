AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Multipurpose Engine"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "This tower does nothing until upgraded. Most upgrades are focused on assisting other towers."
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/maxofs2d/hover_propeller.mdl")
ENT.FireRate = 0
ENT.Cost = 600
ENT.AbilityCooldown = 45
ENT.LOSOffset = Vector(0,0,25)
ENT.AttackDamage = 0
ENT.DetectionRadius = 512
ENT.SeeCamo = true
ENT.InfiniteRange2 = true
ENT.rotgb_Buff = 0
ENT.UpgradeReference = {
	{
		Names = {"Ultrasound Annoyance","Speed Traps","Radar Pulsar","Unfastening Dust","Immunity Shatter","Total Meltdown"},
		Descs = {
			"Prevents gBalloons in the tower's radius from regenerating health.",
			"All Fast gBalloons within this tower's radius move 50% slower.",
			"All Hidden gBalloons within this tower's radius become visible to all towers.",
			"All Shielded gBalloons within this tower's radius take double damage from all sources.",
			"All gBalloons within the tower's range lose all immunities. gBalloon armour is not affected.",
			"Once every 45 seconds, shooting at this tower causes all towers within this tower's radius to deal 15 extra layers of damage for 15 seconds.",
		},
		Prices = {500,1000,2000,4000,30000,35000},
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
		Names = {"Violent Blades","Faster Blades","Heated Blades","Super Blades","Unstable Blades","Tyrant Blades"},
		Descs = {
			"This tower can now instantly pop Blue gBalloons and lower, regardless of immunities and properties.",
			"This tower can now instantly pop Pink gBalloons and lower.",
			"This tower can now instantly pop Gray, Zebra, Aqua and Error gBalloons, as well as anything lower.",
			"This tower can now instantly pop Ceramic gBalloons and anything lower!",
			"This tower can now instantly pop Blue gBlimps, Marble gBalloons and anything lower!",
			"This tower can now instantly pop Red gBlimps and anything lower!",
		},
		Prices = {3000,4500,25000,120000,750000,3750000},
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
				self.AttackDamage = self.AttackDamage + 800
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 5090
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 25360
			end
		}
	},
	{
		Names = {"Morale Boost","Premium Incentive","Jungle Drumming","Health Insurance","Trusted Partnerships","Maximum Potential"},
		Descs = {
			"All towers in this tower's radius fire 20% faster.",
			"Whenever a tower is placed, you gain a 20% rebate. This upgrade does not stack at all.",
			"All towers within the range of this tower pop one extra layer per attack, and have 20% more range.",
			"Whenever a gBalloon reaches its target and pops, each player gains $1000 for each damage point taken by the target, ignoring all damage reduction effects.",
			"Whenever a tower fires within this tower's range, there is a chance that a random tower within this tower's range will also fire! \z
				The chance is reduced if the firing tower fires faster than the targeted tower.",
			"All towers except this tower in this tower's radius no longer have upgrade path restrictions!",
		},
		Prices = {400,500,2500,5000,15000,50000000},
		Funcs = {
			function(self)
				self.rotgb_Buff = 1
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
			function(self)
				self.rotgb_Buff = 5
			end,
			function(self)
				self.rotgb_Buff = 6
			end
		}
	}
}
ENT.UpgradeLimits = {6,2,0}

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

function ENT:ROTGB_Think()
	local anotherfired = 0
	local radiusTowers = {}
	for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
		if v:GetClass()=="gballoon_base" then
			if self.rotgb_NoRegen then
				v.BalloonRegenTime = CurTime()+(hook.Run("GetgBalloonRegenDelay", self) or ROTGB_GetConVarValue("rotgb_regen_delay"))
			end
			if self.rotgb_NoFast and v:GetBalloonProperty("BalloonFast") then
				v:Slowdown("ROTGB_FASTLESS",0.5,0.25)
			end
			if self.rotgb_NoHidden and v:GetBalloonProperty("BalloonHidden") then
				v:InflictRotgBStatusEffect("unhide",0.25)
			end
			if self.rotgb_NoShielded and v:GetBalloonProperty("BalloonShielded") then
				v:InflictRotgBStatusEffect("unshield",0.25)
			end
			if self.rotgb_NoImmunities then
				v:InflictRotgBStatusEffect("unimmune",0.25)
			end
			if v:GetRgBE() <= self.AttackDamage/10 and self.AttackDamage > 0 then
				v:TakeDamage(v:GetRgBE() * 1000, self:GetTowerOwner(), self)
			end
		elseif v.Base=="gballoon_tower_base" then
			if self.rotgb_Buff > 0 then
				v:ApplyBuff(self, "ROTGB_TOWER_06_PASSIVE", 999999, function(tower)
					tower.FireRate = tower.FireRate * 1.2
				end, function(tower)
					tower.FireRate = tower.FireRate / 1.2
				end)
			end
			if self.rotgb_Buff > 2 then
				v:ApplyBuff(self, "ROTGB_TOWER_06_PASSIVE_2", 999999, function(tower)
					tower.AttackDamage = (tower.AttackDamage or 0) + 10
					tower.DetectionRadius = tower.DetectionRadius * 1.2
				end, function(tower)
					tower.AttackDamage = (tower.AttackDamage or 0) - 10
					tower.DetectionRadius = tower.DetectionRadius / 1.2
				end)
			end
			if self.rotgb_Buff > 4 then
				if v.NextFire~=v.rotgb_Tower06BuffTrack then
					v.rotgb_Tower06BuffTrack = v.NextFire
					anotherfired = math.min(anotherfired, v.FireRate or 1)
				else
					table.insert(radiusTowers, v)
				end
			end
			if self.rotgb_Buff > 5 and v ~= self then
				v:SetNWFloat("rotgb_noupgradelimit", CurTime()+2)
			end
		end
	end
	if anotherfired and next(radiusTowers) then
		local selectedTower = radiusTowers[math.random(#radiusTowers)]
		if math.random() < (selectedTower.FireRate or 1) / anotherfired then
			selectedTower:DoFireFunction()
		end
	end
end

function ENT:TriggerAbility()
	for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
		if v.Base=="gballoon_tower_base" then
			v:ApplyBuff(self, "ROTGB_TOWER_06_TM", 15, function(tower)
				tower.AttackDamage = (tower.AttackDamage or 0) + 150
			end, function(tower)
				tower.AttackDamage = (tower.AttackDamage or 0) - 150
			end)
		end
	end
end

hook.Add("OnEntityCreated","ROTGB_TOWER_06",function(ent)
	timer.Simple(0,function()
		if (IsValid(ent) and ent.Base=="gballoon_tower_base") then
			local rebate = nil
			for k,v in pairs(ents.FindByClass("gballoon_tower_06")) do
				if v.rotgb_Buff > 1 then rebate = v break end
			end
			if rebate then
				timer.Simple(0.1,function()
					if IsValid(ent) and IsValid(rebate) then
						rebate:AddCash((ent.Cost or 0)*0.2, ent:GetTowerOwner())
					end
				end)
			end
		end
	end)
end)

hook.Add("EntityTakeDamage","ROTGB_TOWER_06",function(ent,dmginfo)
	local caller = dmginfo:GetInflictor()
	if (IsValid(caller) and caller:GetClass()=="gballoon_base") then
		local insure = {}
		for k,v in pairs(ents.FindByClass("gballoon_tower_06")) do
			if v.rotgb_Buff > 3 then table.insert(insure, v) end
		end
		if #insure > 0 then
			local cash = dmginfo:GetDamage()*1000*player.GetCount()
			for k,v in pairs(insure) do
				v:AddCash(cash)
			end
		end
	end
end)