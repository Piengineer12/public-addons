AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Sniper Queen"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "This tower slowly fires bullets that deal high damage."
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
ENT.UpgradeReference = {
	{
		Names = {"Sniping Scope","Night Vision Goggles","Semi-Automatic Rifle","Fully-Automatic Rifle","Marking Shots","England's Grace"},
		Descs = {
			"Increases range to infinite.",
			"Considerably increases fire rate and grants Hidden gBalloon popping power.",
			"Tremendously increases fire rate.",
			"Colossally increases fire rate!",
			"This tower now places markers on gBalloons. Each marker placed increases damage taken from Sniper Queens by one layer. Markers only affect the gBalloon's outermost layer.",
			"Doubles fire rate and hits all gBalloons in its radius per shot!"
		},
		Prices = {300,2000,5000,25000,250000,10e6},
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
			"Pops 2700 layers per shot! Shots will also cause gBalloons to lose all immunities and all of its properties do not function for 1 second!"
		},
		Prices = {200,1250,2000,20000,500000,10e6},
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
			Damage = self.AttackDamage + (ent.rotgb_AdditionslSniperDamage or 0),
			Distance = self.DetectionRadius*1.5,
			HullSize = 1,
			AmmoType = self.rotgb_CanPopGray and "SniperPenetratedRound" or "Pistol",
			TracerName = "Tracer",
			Dir = uDir,
			Src = startPos
		}
		if self.rotgb_StunBlimp and ent:GetBalloonProperty("BalloonBlimp") and ent:GetRgBE()<35128 then
			ent:Stun(1)
		end
		if self.rotgb_MarkingShots then
			ent.rotgb_AdditionslSniperDamage = (ent.rotgb_AdditionslSniperDamage or 0) + 10
		end
		if self.rotgb_ExtraToBlimp and ent:GetBalloonProperty("BalloonBlimp") then
			bullet.Damage = bullet.Damage * 5
		end
		if self.rotgb_NoImmune then
			ent.BalloonRegenTime = CurTime()+ROTGB_GetConVarValue("rotgb_regen_delay")+1
			if ent:GetBalloonProperty("BalloonFast") then
				ent:Slowdown("ROTGB_FASTLESS",0.5,1)
			end
			if ent:GetBalloonProperty("BalloonHidden") then
				ent:InflictRotgBStatusEffect("unhide",1)
			end
			if ent:GetBalloonProperty("BalloonShielded") then
				ent:InflictRotgBStatusEffect("unshield",1)
			end
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