AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Sniper Queen"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Snipe those gBalloons!"
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
ENT.UpgradeReference = {
	{
		Names = {"Sniping Scope","Night Vision Goggles","Semi-Automatic Rifle","Fully-Automatic Rifle","Marking Shots"},
		Descs = {
			"Increases range to infinite.",
			"Grants Hidden gBalloon popping power.",
			"Tremendously increases fire rate.",
			"Colossally increases fire rate!",
			"This tower now places markers on gBalloons. Each marker placed increases damage taken from Sniper Queens by one layer. Markers only affect the gBalloon's outermost layer."
		},
		Prices = {300,750,2500,10000,100000},
		Funcs = {
			function(self)
				self.InfiniteRange = true
			end,
			function(self)
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
			end
		}
	},
	{
		Names = {"Point Five Oh","Large Calibre","Armour Piercing Rounds","Blimp Beatdown","Blimp Eliminator"},
		Descs = {
			"Pops five layers per shot.",
			"Grants Gray gBalloon popping power and pops eight layers per shot!",
			"Pops 18 layers per shot, enough to completely destroy a Ceramic gBalloon.",
			"Pops 54 layers per shot! Shots will also stun gBlimps for 1 second. This upgrade can't stun Purple and Rainbow gBlimps.",
			"Pops 270 layers per shot! Shots will also deal colossally increased damage versus gBlimps."
		},
		Prices = {200,1250,2500,20000,500000},
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
			end
		}
	}
}
ENT.UpgradeLimits = {5,2}

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
				--[[if (IsValid(tracer.Entity) and tracer.Entity:GetClass() == "gballoon_base" and tracer.Entity:GetBalloonProperty("BalloonGray")) then
					tracer.Entity:TakeDamage(self.AttackDamage,self,self)
				end]]
			end,
			Damage = self.AttackDamage + (ent.rotgb_AdditionslSniperDamage or 0),
			Distance = self.DetectionRadius*1.5,
			HullSize = 1,
			AmmoType = self.rotgb_CanPopGray and "SniperPenetratedRound" or "Pistol",
			TracerName = "Tracer",
			Dir = uDir,
			Src = startPos
		}
		if self.rotgb_StunBlimp and ent:GetBalloonProperty("BalloonBlimp") and ent:GetBalloonProperty("BalloonType")~="gballoon_blimp_purple" and ent:GetBalloonProperty("BalloonType")~="gballoon_blimp_rainbow" then
			ent:Stun(1)
		end
		if self.rotgb_MarkingShots then
			ent.rotgb_AdditionslSniperDamage = ent.rotgb_AdditionslSniperDamage + 10
		end
		if self.rotgb_ExtraToBlimp and ent:GetBalloonProperty("BalloonBlimp") then
			bullet.Damage = bullet.Damage * 5
		end
		self:FireBullets(bullet)
	end
end

ENT.thread = coroutine.create(SnipeEntity)
coroutine.resume(ENT.thread)

function ENT:FireFunction(gBalloons)
	local perf,str = coroutine.resume(self.thread,self,gBalloons[1])
	if not perf then error(str) end
end