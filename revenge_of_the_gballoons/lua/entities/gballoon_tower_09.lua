AddCSLuaFile()

-- TODO: nerf this

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Bishop of Glue"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "This tower slows gBalloons that it hits, but deals zero damage."
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/props_phx/games/chess/black_bishop.mdl")
ENT.FireRate = 2
ENT.Cost = 300
ENT.DetectionRadius = 384
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,40)
ENT.UserTargeting = true
ENT.AttackDamage = 0
ENT.AbilityCooldown = 15
ENT.rotgb_Hits = 1
ENT.rotgb_GlueSlowdown = 1/3
ENT.rotgb_GlueDamage = 0
ENT.rotgb_GlueDuration = 5
ENT.UpgradeReference = {
	{
		Names = {"Stronger Glue","High Speed Glue Nozzle","Liquid-Solid Glue","G.G. Glue","Shattering Glue"},
		Descs = {
			"Glue slows down gBalloons more and lasts slightly longer.",
			"Considerably increases fire rate.",
			"Glue slows down gBalloons even more.",
			"Glue can now affect gBlimps.",
			"Glue causes gBalloons to lose all immunities."
		},
		Prices = {250,500,2000,40000,200000},
		Funcs = {
			function(self)
				self.rotgb_GlueSlowdown = self.rotgb_GlueSlowdown * 1.5
				self.rotgb_GlueDuration = self.rotgb_GlueDuration * 1.5
			end,
			function(self)
				self.FireRate = self.FireRate * 2
			end,
			function(self)
				self.rotgb_GlueSlowdown = self.rotgb_GlueSlowdown * 1.5
			end,
			function(self)
				self.rotgb_GreatGlue = true
			end,
			function(self)
				self.rotgb_ShatterGlue = true
			end
		}
	},
	{
		Names = {"Glue Soak","Corrosive Glue","Acid-Glue Mixture","gBalloon Dissolver","gBalloon Ultimate Solvent"},
		Descs = {
			"Glue soaks through all layers of gBalloons.",
			"Glue causes gBalloons to take damage over time.",
			"Glue pops two layers per second and lasts considerably longer.",
			"Glue pops ten layers per second!",
			"Glue pops 100 layers per second!"
		},
		Prices = {250,1250,7500,75000,1500000},
		Funcs = {
			function(self)
				self.rotgb_GlueSoak = true
			end,
			function(self)
				self.rotgb_GlueDamage = self.rotgb_GlueDamage + 10
			end,
			function(self)
				self.rotgb_DoubleThink = true
				self.rotgb_GlueDuration = self.rotgb_GlueDuration * 2
			end,
			function(self)
				self.rotgb_GlueDamage = self.rotgb_GlueDamage + 40
			end,
			function(self)
				self.rotgb_GlueDamage = self.rotgb_GlueDamage + 450
			end
		}
	},
	{
		Names = {"Glue Nozzle","Glue Splatter","Glue Blaster","Glue Sprinkler","Glue Air Strike"},
		Descs = {
			"Glue travels considerably further.",
			"Three gBalloons are glued per shot.",
			"One gBalloon is glued per shot, but glue hits affect surrounding gBalloons.",
			"Any non-immune gBalloon within the tower's range gets glued! Also enables the tower to glue hidden gBalloons.",
			"Glue lasts considerably longer. Once every 15 seconds, shooting at this tower causes ALL gBalloons to be glued, regardless of immunities!"
		},
		Prices = {250,1000,5000,35000,125000},
		Funcs = {
			function(self)
				self.DetectionRadius = self.DetectionRadius * 2
			end,
			function(self)
				self.rotgb_Hits = self.rotgb_Hits * 3
			end,
			function(self)
				self.rotgb_Hits = self.rotgb_Hits / 3
				self.rotgb_GlueSplatter = true
			end,
			function(self)
				self.rotgb_GlueSlosher = true
				self.SeeCamo = true
			end,
			function(self)
				self.HasAbility = true
				self.rotgb_GlueDuration = self.rotgb_GlueDuration * 2
			end
		}
	}
}
ENT.UpgradeLimits = {5,5,5}

local function SnipeEntity()
	while true do
		local self,ent,nosplat = coroutine.yield()
		ent:Slowdown("ROTGB_GLUE_TOWER",1-self.rotgb_GlueSlowdown,self.rotgb_GlueDuration)
		if not nosplat then
			util.Decal("Antlion.Splat",self:GetShootPos(),ent:LocalToWorld(ent:OBBCenter()),self)
		end
		if self.rotgb_GlueSoak then
			ent:InflictRotgBStatusEffect("glue_soak",self.rotgb_GlueDuration)
		end
		if self.rotgb_ShatterGlue then
			ent:InflictRotgBStatusEffect("unimmune",self.rotgb_GlueDuration)
		end
		if self.rotgb_GlueDamage > 0 then
			ent.AcidicList = ent.AcidicList or {}
			ent.AcidicList[self] = {self.rotgb_GlueDamage,CurTime()+self.rotgb_GlueDuration}
		end
		if self.AttackDamage > 0 then
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(self:GetTowerOwner())
			dmginfo:SetInflictor(self)
			dmginfo:SetDamageType(DMG_CRUSH)
			dmginfo:SetReportedPosition(self:GetShootPos())
			dmginfo:SetDamage(self.AttackDamage)
			dmginfo:SetDamagePosition(ent:LocalToWorld(ent:OBBCenter()))
			ent:TakeDamageInfo(dmginfo)
		end
	end
end

ENT.thread = coroutine.create(SnipeEntity)
coroutine.resume(ENT.thread)

function ENT:FireFunction(gBalloons)
	local hits = 0
	if self.rotgb_GlueSplatter then
		for k,v in pairs(ents.FindInSphere(v:GetPos(),64)) do
			if self:ValidTargetIgnoreRange(v) and (not (v.rotgb_SpeedMods and v.rotgb_SpeedMods.ROTGB_GLUE_TOWER)) then
				if not (v:GetBalloonProperty("BalloonBlimp") and not self.rotgb_GreatGlue or v:GetBalloonProperty("BalloonAqua")) then
					local perf,str = coroutine.resume(self.thread,self,v,true)
					if not perf then error(str) end
				else
					v:ShowResistEffect(5)
				end
			end
		end
	else
		for i,v in ipairs(gBalloons) do
			if not (v.rotgb_SpeedMods and v.rotgb_SpeedMods.ROTGB_GLUE_TOWER) then
				if not (v:GetBalloonProperty("BalloonBlimp") and not self.rotgb_GreatGlue or v:GetBalloonProperty("BalloonAqua")) then
					local perf,str = coroutine.resume(self.thread,self,v)
					if not perf then error(str) end
				else
					v:ShowResistEffect(5)
				end
				hits = hits + 1
				if hits >= self.rotgb_Hits then break end
			end
		end
	end
end

function ENT:ROTGB_Think()
	self.ThinkD = self.ThinkD or CurTime()
	self.ThinkC = self.ThinkC or CurTime()
	if CurTime()>self.ThinkD and self.rotgb_GlueDamage>0 then
		self.ThinkD = CurTime() + (self.rotgb_DoubleThink and 0.5 or 1)
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker(self:GetTowerOwner())
		dmginfo:SetInflictor(self)
		dmginfo:SetDamageType(DMG_ACID)
		dmginfo:SetReportedPosition(self:GetShootPos())
		for k,v in pairs(ents.FindByClass("gballoon_base")) do
			v.AcidicList = v.AcidicList or {}
			if v.AcidicList[self] then
				if v.AcidicList[self][2] < CurTime() then
					v.AcidicList[self] = nil
				else
					dmginfo:SetDamage(v.AcidicList[self][1])
					dmginfo:SetDamagePosition(v:LocalToWorld(v:OBBCenter()))
					v:TakeDamageInfo(dmginfo)
				end
			end
		end
	end
	if CurTime()>self.ThinkC and self.rotgb_GlueSlosher then
		self.ThinkC = CurTime() + 0.5
		for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
			if v:GetClass()=="gballoon_base" then
				if not (v:GetBalloonProperty("BalloonBlimp") and not self.rotgb_GreatGlue or v:GetBalloonProperty("BalloonAqua")) then
					local perf,str = coroutine.resume(self.thread,self,v,true)
					if not perf then error(str) end
				else
					v:ShowResistEffect(5)
				end
			end
		end
	end
end

function ENT:TriggerAbility()
	for k,v in pairs(ents.FindByClass("gballoon_base")) do
		local perf,str = coroutine.resume(self.thread,self,v,true)
		if not perf then error(str) end
	end
end