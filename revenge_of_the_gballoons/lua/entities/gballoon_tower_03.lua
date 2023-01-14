AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Sniper Queen"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.tower.gballoon_tower_03.purpose"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/props_phx/games/chess/white_queen.mdl")
ENT.FireRate = 1
ENT.Cost = 350
ENT.DetectionRadius = 512
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,40)
ENT.UserTargeting = true
ENT.AttackDamage = 30
ENT.IsChessPiece = true
ENT.rotgb_MaxMarkers = 1000
ENT.UpgradeReference = {
	{
		-- 2, 4, 3, 5, 10, 25
		Prices = {300,1750,4500,25000,250000,20e6},
		Funcs = {
			function(self)
				self.InfiniteRange = true
			end,
			function(self)
				self.FireRate = self.FireRate * 2
				self.SeeCamo = true
			end,
			function(self)
				self.FireRate = self.FireRate * 3
			end,
			function(self)
				self.FireRate = self.FireRate * 5
			end,
			function(self)
				self.rotgb_MarkingShots = true
			end,
			function(self)
				self.FireRate = self.FireRate * 5
				self.rotgb_Spread = true
				self.rotgb_MaxMarkers = self.rotgb_MaxMarkers * 10
			end
		}
	},
	{
		Prices = {200,1250,2000,20000,500000,20e6},
		Funcs = {
			function(self)
				self.AttackDamage = self.AttackDamage + 20
			end,
			function(self)
				self.rotgb_CanPopGray = true
				self.AttackDamage = self.AttackDamage + 30
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 100
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 360
				self.rotgb_StunBlimp = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 2160
				self.rotgb_ExtraToBlimp = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 24300
				self.rotgb_NoImmune = true
			end
		}
	}
}
ENT.UpgradeLimits = {6,2}

function ENT:ROTGB_ApplyPerks()
	self.FireRate = self.FireRate * (1+hook.Run("GetSkillAmount", "sniperQueenFireRate")/100)
end

local function SnipeEntity()
	while true do
		local self,ent = coroutine.yield()
		local startPos = self:GetShootPos()
		local uDir = ent:LocalToWorld(ent:OBBCenter())-startPos
		--uDir:Normalize()
		local bullet = {
			Attacker = self:GetTowerOwner(),
			Callback = function(attacker,tracer,dmginfo)
				dmginfo:SetDamageType(self.rotgb_CanPopGray and DMG_SNIPER or DMG_BULLET)
			end,
			Damage = self.AttackDamage + math.floor((ent.rotgb_AdditionslSniperDamage or 0) / 10)*10,
			Distance = self.DetectionRadius*1.5,
			HullSize = 1,
			AmmoType = self.rotgb_CanPopGray and "SniperPenetratedRound" or "Pistol",
			TracerName = "Tracer",
			Dir = uDir,
			Src = startPos
		}
		if self.rotgb_StunBlimp and ent:GetBalloonProperty("BalloonBlimp") and ent:GetRgBE()<ent:GetRgBEByType("gballoon_blimp_purple")-ent:GetMaxHealth() then
			ent:Stun(1)
		end
		if self.rotgb_MarkingShots and (ent.rotgb_AdditionslSniperDamage or 0) < self.rotgb_MaxMarkers then
			ent.rotgb_AdditionslSniperDamage = (ent.rotgb_AdditionslSniperDamage or 0) + 1
		end
		if self.rotgb_ExtraToBlimp and ent:GetBalloonProperty("BalloonBlimp") then
			bullet.Damage = bullet.Damage * 5
		end
		if self.rotgb_NoImmune then
			ent:SetBalloonProperty("BalloonFast", false)
			ent:SetBalloonProperty("BalloonHidden", false)
			ent:SetBalloonProperty("BalloonRegen", false)
			ent:SetBalloonProperty("BalloonShielded", false)
			ent:InflictRotgBStatusEffect("unimmune",1)
		end
		self:FireBullets(bullet)
	end
end

ENT.thread = coroutine.create(SnipeEntity)
coroutine.resume(ENT.thread)

function ENT:FireFunction(gBalloons)
	if self.rotgb_Spread then
		for k,v in pairs(gBalloons) do
			local perf,str = coroutine.resume(self.thread,self,v)
			if not perf then error(str) end
		end
	else
		local perf,str = coroutine.resume(self.thread,self,gBalloons[1])
		if not perf then error(str) end
	end
end