AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Sniper Queen"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Snipe those gBalloons!"
ENT.Instructions = ""
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/props_phx/games/chess/white_queen.mdl")
ENT.FireRate = 1
ENT.Cost = 400
ENT.DetectionRadius = 1024
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,40)
ENT.UserTargeting = true
ENT.AttackDamage = 20
ENT.UpgradeReference = {
	{
		Names = {"Sniping Scope","Night Vision Goggles","Semi-Automatic Rifle","Fully-Automatic Rifle"},
		Descs = {
			"Increases range to infinite.",
			"Grants Hidden gBalloon popping power.",
			"Dramatically increases fire rate.",
			"Increases fire rate to an incomprehensible amount."
		},
		Prices = {300,750,5000,25000},
		Funcs = {
			function(self)
				self.InfiniteRange = true
			end,
			function(self)
				self.SeeCamo = true
			end,
			function(self)
				self.FireRate = self.FireRate * 5
			end,
			function(self)
				self.FireRate = self.FireRate * 5
			end
		}
	},
	{
		Names = {"Point Five Oh","Large Calibre","Armour Piercing Rounds","Blimp Beatdown"},
		Descs = {
			"Pops five layers per shot.",
			"Grants Gray gBalloon popping power and pops eight layers per shot!",
			"Pops 18 layers per shot, enough to completely destroy a Ceramic gBalloon. If a gBlimp is destroyed this way, its children are all popped instantly.",
			"Pops 540 layers per shot! Shots will also stun gBlimps for 2 seconds. This upgrade can't stun Purple and Rainbow gBlimps."
		},
		Prices = {300,3000,4500,400000},
		Funcs = {
			function(self)
				self.AttackDamage = self.AttackDamage + 30
			end,
			function(self)
				self.rotgb_CanPopGray = true
				self.AttackDamage = self.AttackDamage + 30
			end,
			function(self)
				self.rotgb_ExtraToBlimp = true
				self.AttackDamage = self.AttackDamage + 100
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 5220
				self.rotgb_StunBlimp = true
			end
		}
	}
}
ENT.UpgradeLimits = {4,2}

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
			Damage = self.AttackDamage,
			Distance = self.DetectionRadius*1.5,
			HullSize = 1,
			AmmoType = self.rotgb_CanPopGray and "SniperPenetratedRound" or "Pistol",
			TracerName = "Tracer",
			Dir = uDir,
			Src = startPos
		}
		if self.rotgb_StunBlimp and ent:GetBalloonProperty("BalloonBlimp") and ent:GetBalloonProperty("BalloonType")~="gballoon_blimp_purple" and ent:GetBalloonProperty("BalloonType")~="gballoon_blimp_rainbow" then
			ent:Stun(2)
		end
		if self.rotgb_ExtraToBlimp and self.AttackDamage/10>=ent:Health() and ent:GetBalloonProperty("BalloonBlimp") then
			ent:Pop(-1)
			self:FireBullets(bullet)
		else
			self:FireBullets(bullet)
		end
	end
end

ENT.thread = coroutine.create(SnipeEntity)
coroutine.resume(ENT.thread)

function ENT:FireFunction(gBalloons)
	local perf,str = coroutine.resume(self.thread,self,gBalloons[1])
	if not perf then error(str) end
end

list.Set("NPC","gballoon_tower_03",{
	Name = ENT.PrintName,
	Class = "gballoon_tower_03",
	Category = ENT.Category
})