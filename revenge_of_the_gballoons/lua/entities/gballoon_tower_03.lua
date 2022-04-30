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
		Names = {"Sniping Scope","Night Vision Goggles","Semi-Automatic Rifle","Fully-Automatic Rifle","Marking Shots","England's Grace"},
		Descs = {
			"Increases range to infinite.",
			"Considerably increases fire rate and grants Hidden gBalloon popping power.",
			"Tremendously increases fire rate.",
			"Colossally increases fire rate!",
			"This tower now places markers on gBalloons. Every 10 markers placed will increase damage taken from Sniper Queens by one layer, up to 100 extra layers of damage. Markers only affect the gBalloon's outermost layer.",
			"Doubles fire rate, increases the maximum marker limit to 1,000 extra layers of damage and all shots hit all gBalloons in its radius!"
		},
		Prices = {300,2000,5000,25000,250000,20e6},
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
		Names = {"Point Five Oh","Large Calibre","Armour Piercing Rounds","Blimp Beatdown","Blimp Eliminator","gBalloon Annihilator"},
		Descs = {
			"Pops five layers per shot.",
			"Grants Gray gBalloon popping power and pops eight layers per shot!",
			"Pops 18 layers per shot, enough to completely destroy a Ceramic gBalloon.",
			"Pops 54 layers per shot! Shots will also stun gBlimps for 3 seconds. This upgrade can't stun Purple gBlimps and above.",
			"Pops 270 layers per shot! Shots will also deal colossally increased damage versus gBlimps, enough to destroy Red gBlimps in a single hit!",
			"Pops 2700 layers per shot! Shots will also cause gBalloons to lose all damage type immunities for 1 second and strips Fast, Hidden, Regen and Shielded properties off gBalloons!"
		},
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
		if self.rotgb_MarkingShots then
			ent.rotgb_AdditionslSniperDamage = math.min((ent.rotgb_AdditionslSniperDamage or 0) + 1, self.rotgb_MaxMarkers)
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