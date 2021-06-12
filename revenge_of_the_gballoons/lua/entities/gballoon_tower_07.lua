AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Ally Pawn"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "The most basic tower. This tower fires bullets at gBalloons."
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/props_phx/games/chess/white_pawn.mdl")
ENT.FireRate = 2
ENT.Cost = 250
ENT.DetectionRadius = 384
ENT.AbilityCooldown = 30
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,25)
ENT.UserTargeting = true
ENT.AttackDamage = 10
ENT.rotgb_AbilityDamage = 0
ENT.rotgb_Targets = 1
ENT.UpgradeReference = {
	{
		Names = {"Faster Cycle","Rapid Cycle","Flaring Shot","Hot Hail","Incinerator","Hellfire Hearth","Of The Sun's Embrace"},
		Descs = {
			"Slightly increases attack speed.",
			"Considerably increases attack speed.",
			"Attacks deal one additional layer of damage and can pop Gray gBalloons.",
			"Fires searing hot shots that set their victims on fire for 5 seconds.",
			"All gBalloons within the tower's range get set on fire. Also considerably increases fire duration.",
			"Once every 30 seconds, shooting at this tower causes it to erupt with a deadly flame, dealing damage to all gBalloons regardless of immunities and setting them on fire that deals 200 layers of damage over 10 seconds.",
			"Hellfire Hearth's fire damage is increased to 4000 layers of damage over 10 seconds!"
		},
		Prices = {100,300,1750,4000,20000,100000,2000000},
		Funcs = {
			function(self)
				self.FireRate = self.FireRate * 1.5
			end,
			function(self)
				self.FireRate = self.FireRate * 2
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
				self.rotgb_AbilityDamage = 200
			end,
			function(self)
				self.rotgb_AbilityDamage = self.rotgb_AbilityDamage * 20
			end
		}
	},
	{
		Names = {"Long Range Bullets","Optical Lens","Binocular Vision","Queen's Grace","Rainbow Beamer Fan Club"},
		Descs = {
			"Slightly increases tower range.",
			"Allows the tower to see Hidden gBalloons.",
			"Considerably increases tower range. This tower now fires two shots at once.",
			"This tower fires an additional shot. Once every 60 seconds, shooting at this tower causes all Ally Pawns to turn into Ally Queens, increasing damage dealt by 10 layers for 20 seconds.",
			"Once every 60 seconds, shooting at this tower causes all Ally Pawns to turn into Rainbow Beamer Prisms, increasing fire rate by 300%, simultaneous hits by 200% and damage dealt by 30 layers for 20 seconds."
		},
		Prices = {100,400,2000,40000,350000},
		Funcs = {
			function(self)
				self.DetectionRadius = self.DetectionRadius * 1.5
			end,
			function(self)
				self.SeeCamo = true
			end,
			function(self)
				self.DetectionRadius = self.DetectionRadius * 2
				self.rotgb_Targets = self.rotgb_Targets * 2
			end,
			function(self)
				self.rotgb_Targets = self.rotgb_Targets * 1.5
				self.HasAbility = true
				self.rotgb_Transformation = 1
			end,
			function(self)
				self.rotgb_Transformation = 2
			end,
		}
	}
}
ENT.UpgradeLimits = {7,2}

local function SnipeEntity()
	while true do
		local self,ent = coroutine.yield()
		local startPos = self:GetShootPos()
		if self.rotgb_Transformed ~= 2 then
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
						ent:RotgB_Ignite(10, self:GetTowerOwner(), self, self.rotgb_DoFireAura and 10 or 5)
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
		else
			local startEnt = ents.Create("info_target")
			local laser = ents.Create("env_beam")
			local endEnt = ents.Create("info_target")
			if IsValid(endEnt) then
				endEnt:SetName("ROTGB07_"..endEnt:GetCreationID())
				endEnt:SetPos(ent:GetPos()+ent.loco:GetVelocity()*0.1+ent:OBBCenter())
			end
			startEnt:SetName("ROTGB07_"..startEnt:GetCreationID())
			startEnt:SetPos(startPos)
			startEnt:Spawn()
			laser:SetPos(startPos)
			
			laser:SetKeyValue("renderamt","63")
			laser:SetKeyValue("rendercolor","255 255 255")
			laser:SetKeyValue("BoltWidth","8")
			laser:SetKeyValue("NoiseAmplitude","1")
			laser:SetKeyValue("texture","beams/rainbow1.vmt")
			laser:SetKeyValue("TextureScroll","0")
			laser:SetKeyValue("damage",self.AttackDamage)
			laser:SetKeyValue("LightningStart",startEnt:GetName())
			laser:SetKeyValue("LightningEnd",endEnt:GetName())
			laser:SetKeyValue("HDRColorScale","0.7")
			laser:SetKeyValue("decalname","decals/dark")
			laser:SetKeyValue("spawnflags","97")
			laser:Spawn()
			laser.rotgb_Owner = self
			laser:Activate()
			laser.rotgb_UseLaser = 2
			laser:Fire("TurnOn")
			timer.Simple(0.2,function()
				if IsValid(laser) then
					self:DontDeleteOnRemove(laser)
					laser:Remove()
				end
				if IsValid(startEnt) then
					startEnt:Remove()
				end
				if IsValid(endEnt) then
					endEnt:Remove()
				end
			end)
			self:DeleteOnRemove(laser)
		end
	end
end

function ENT:ROTGB_Think()
	if (self.rotgb_NextThink or 0) <= CurTime() then
		self.rotgb_NextThink = CurTime() + 0.1
		if self.rotgb_DoFireAura then
			for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
				if self:ValidTargetIgnoreRange(v) then
					v:RotgB_Ignite(10, self:GetTowerOwner(), self, 10)
					--v.FireSusceptibility = (v.FireSusceptibility or 0) + 0.1
				end
			end
		end
	end
end

ENT.thread = coroutine.create(SnipeEntity)
coroutine.resume(ENT.thread)

function ENT:FireFunction(gBalloons)
	for i=1,self.rotgb_Targets do
		if self:ValidTargetIgnoreRange(gBalloons[i]) then
			local perf,str = coroutine.resume(self.thread,self,gBalloons[i])
			if not perf then error(str) end
		end
	end
end

function ENT:TriggerAbility()
	if self.rotgb_AbilityDamage > 0 then
		local entities = ents.FindByClass("gballoon_base")
		if not next(entities) and not self.rotgb_Transformation then return true end
		for index,ent in pairs(entities) do
			local effdata = EffectData()
			effdata:SetOrigin(Vector(ent:GetPos()))
			effdata:SetStart(Vector(ent:GetPos()))
			effdata:SetEntity(ent)
			util.Effect("Explosion",effdata,true,true)
			ent:TakeDamage(64,self:GetTowerOwner(),self)
			--ent.FireSusceptibility = (ent.FireSusceptibility or 0) + 99
			ent:RotgB_Ignite(self.rotgb_AbilityDamage, self:GetTowerOwner(), self, 10)
		end
	end
	if self.rotgb_Transformation then
		local entities = ents.FindByClass("gballoon_tower_07")
		for index,ent in pairs(entities) do
			if not ent.rotgb_Transformed then
				local effdata = EffectData()
				effdata:SetOrigin(Vector(ent:GetPos()))
				effdata:SetStart(Vector(ent:GetPos()))
				effdata:SetEntity(ent)
				effdata:SetMagnitude(1)
				effdata:SetScale(1)
				effdata:SetRadius(1)
				util.Effect("Sparks",effdata,true,true)
				ent.rotgb_Transformed = self.rotgb_Transformation
				local oldMaterial = ent:GetMaterial()
				
				if self.rotgb_Transformation == 1 then
					ent.AttackDamage = ent.AttackDamage + 100
					ent:SetModel("models/props_phx/games/chess/white_queen.mdl")
				else
					ent.AttackDamage = ent.AttackDamage + 300
					ent.FireRate = ent.FireRate * 4
					ent.rotgb_Targets = ent.rotgb_Targets * 3
					ent:SetMaterial("models/spawn_effect2")
				end
				timer.Simple(10, function()
					if IsValid(ent) then
						if ent.rotgb_Transformed == 1 then
							ent.AttackDamage = ent.AttackDamage - 100
						else
							ent.AttackDamage = ent.AttackDamage - 300
							ent.FireRate = ent.FireRate / 4
							ent.rotgb_Targets = ent.rotgb_Targets / 3
						end
						ent.rotgb_Transformed = nil
						ent:SetMaterial(oldMaterial)
						ent:SetModel("models/props_phx/games/chess/white_pawn.mdl")
					end
				end)
			end
		end
	end
end