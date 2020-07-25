AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Ally Pawn"
ENT.Category = "RotgB: Towers"
ENT.Author = "RandomTNT"
ENT.Contact = "http://steamcommunity.com/id/RandomTNT12/"
ENT.Purpose = "Shoot those gBalloons!"
ENT.Instructions = ""
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/props_phx/games/chess/white_pawn.mdl")
ENT.FireRate = 2
ENT.Cost = 250
ENT.DetectionRadius = 384
ENT.AbilityCooldown = 60
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,25)
ENT.UserTargeting = true
ENT.AttackDamage = 10
ENT.UpgradeReference = {
	{
		Names = {"Faster Cycle","Rapid Cycle","Flaring Shot","Hot Hail","Incinerator","Hellfire Hearth"},
		Descs = {
			"Fires 10% faster.",
			"Fires 30% faster.",
			"Attacks deal one additional layer of damage and can pop Gray gBalloons.",
			"Fires searing hot shots that set their victims on fire.",
			"All gBalloons within the tower's range get set on fire. Also slightly increases fire damage dealt.",
			"Once every 60 seconds, shooting at this tower causes it to erupt with a deadly flame, dealing damage to ALL gBalloons regardless of immunities, setting them on fire, and causing them to take tremendously increased damage from fires."
		},
		Prices = {100,150,350,1000,5000,15000},
		Funcs = {
			function(self)
				self.FireRate = self.FireRate * 1.1
			end,
			function(self)
				self.FireRate = self.FireRate * 1.3
			end,
			function(self)
				self.rotgb_CanPopGray = true
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.rotgb_DoFire = true
			end,
			function(self)
				self.rotgb_DoFireAura = true
			end,
			function(self)
				self.HasAbility = true
			end
		}
	},
	{
		Names = {"Long Range Bullets","Optical Lens"},
		Descs = {
			"Slightly increases tower range.",
			"Allows the tower to see Hidden gBalloons and slightly increases tower range.",
		},
		Prices = {125,750},
		Funcs = {
			function(self)
				self.DetectionRadius = self.DetectionRadius * 1.25
			end,
			function(self)
				self.SeeCamo = true
				self.DetectionRadius = self.DetectionRadius * 1.25
			end
		}
	}
}
ENT.UpgradeLimits = {6,2}

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
				if IsValid(ent) and self.rotgb_DoFire then
					ent:RotgB_Ignite(10, self:GetTowerOwner(), self, 5)
				end
			end,
			Damage = self.AttackDamage,
			Distance = self.DetectionRadius*1.5,
			HullSize = 1,
			AmmoType = self.rotgb_CanPopGray and "SniperPenetratedRound" or "Pistol",
			TracerName = "Tracer",
			Dir = uDir,
			Src = startPos
		}
		self:FireBullets(bullet)
	end
end

function ENT:ROTGB_Think()
	if (self.rotgb_NextThink or 0) <= CurTime() then
		self.rotgb_NextThink = CurTime() + 0.1
		if self.rotgb_DoFireAura then
			for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
				if self:ValidTarget(v) then
					v:RotgB_Ignite(20, self:GetTowerOwner(), self, 5)
					--v.FireSusceptibility = (v.FireSusceptibility or 0) + 0.1
				end
			end
		end
	end
end

ENT.thread = coroutine.create(SnipeEntity)
coroutine.resume(ENT.thread)

function ENT:FireFunction(gBalloons)
	local perf,str = coroutine.resume(self.thread,self,gBalloons[1])
	if not perf then error(str) end
end

function ENT:TriggerAbility()
	local entities = ents.FindByClass("gballoon_base")
	if not next(entities) then return true end
	for index,ent in pairs(entities) do
		local effdata = EffectData()
		effdata:SetOrigin(Vector(ent:GetPos()))
		effdata:SetStart(Vector(ent:GetPos()))
		effdata:SetEntity(ent)
		util.Effect("Explosion",effdata,true,true)
		ent:TakeDamage(64,self:GetTowerOwner(),self)
		ent.FireSusceptibility = (ent.FireSusceptibility or 0) + 9
		ent:RotgB_Ignite(10, self:GetTowerOwner(), self, 15)
	end
end

list.Set("NPC","gballoon_tower_07",{
	Name = ENT.PrintName,
	Class = "gballoon_tower_07",
	Category = ENT.Category
})