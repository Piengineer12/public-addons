AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Ally Pawn"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.tower.gballoon_tower_07.purpose"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/props_phx/games/chess/white_pawn.mdl")
ENT.FireRate = 2
ENT.Cost = 250
ENT.DetectionRadius = 256
ENT.AbilityCooldown = 30
ENT.AbilityDuration = 10
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,25)
ENT.UserTargeting = true
ENT.AttackDamage = 10
ENT.IsChessPiece = true
ENT.rotgb_AbilityDamage = 0
ENT.rotgb_Targets = 1
ENT.UpgradeReference = {
	{
		Prices = {100,300,1750,3500,20000,100000,2e6},
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
				self.rotgb_AbilityDamage = 2000
			end,
			function(self)
				self.rotgb_AbilityDamage = self.rotgb_AbilityDamage * 25
			end
		}
	},
	{
		-- 1.5, 2, 4, 8.5 (1.5*(2/3+1/3*3*5)), 24 2/3 (2/3+1/3*3*3*4*2)
		Prices = {100,300,1750,15000,400000},
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

--[[function ENT:ROTGB_ApplyPerks()
	--self.FireRate = self.FireRate * (1+hook.Run("GetSkillAmount", "allyPawnFireRate")/100)
	--self.DetectionRadius = self.DetectionRadius * (1+hook.Run("GetSkillAmount", "allyPawnRange")/100)
	--self.rotgb_Targets = self.rotgb_Targets + (1+hook.Run("GetSkillAmount", "allyPawnTargets")/100)
	if not RTG_FirstAllyPawnFreeDone and hook.Run("GetSkillAmount", "allyPawnFirstFree") > 0 then
		self.Cost = 0
	end
end

function ENT:ROTGB_Initialize()
	if engine.ActiveGamemode() == "rotgb" then
		RTG_FirstAllyPawnFreeDone = true
	end
end]]

local function SnipeEntity()
	while true do
		local self,ent = coroutine.yield()
		local startPos = self:GetShootPos()
		if self.rotgb_Transformed ~= 2 then
			self:BulletAttack(ent, self.AttackDamage, {
				damageType = self.rotgb_CanPopGray and DMG_SNIPER or DMG_BULLET,
				callback = function(attacker, tracer, dmginfo)
					if IsValid(ent) and self.rotgb_DoFire then
						ent:RotgB_Ignite(20, self:GetTowerOwner(), self, self.rotgb_DoFireAura and 10 or 5)
					end
				end
			})
		else
			self:LaserAttack(ent, self.AttackDamage, 8, {
				damageType = DMG_GENERIC,
				scroll = 35,
				rainbow = true,
				decal = "decals/dark",
				sparks = true
			})
			
			--[[local startEnt = ents.Create("info_target")
			local laser = ents.Create("env_beam")
			local endEnt = ents.Create("info_target")
			if IsValid(endEnt) then
				endEnt:SetName("ROTGB07_"..endEnt:GetCreationID())
				endEnt:SetPos(ent:WorldSpaceCenter()+ent.loco:GetVelocity()*0.1)
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
			self:DeleteOnRemove(laser)]]
		end
	end
end

function ENT:ROTGB_Think()
	if (self.NextLocalThink or 0) < CurTime() and self.rotgb_DoFireAura then
		self.NextLocalThink = CurTime() + 0.1
		for k,v in pairs(ROTGB_GetBalloons()) do
			if self:ValidTarget(v) then
				v:RotgB_Ignite(20, self:GetTowerOwner(), self, 10)
				--v.FireSusceptibility = (v.FireSusceptibility or 0) + 0.1
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
	local success = false
	if self.rotgb_AbilityDamage > 0 then
		local entities = ROTGB_GetBalloons()
		if next(entities) then
			success = true
			for index,ent in pairs(entities) do
				local effdata = EffectData()
				effdata:SetOrigin(ent:GetPos())
				effdata:SetStart(ent:GetPos())
				effdata:SetEntity(ent)
				util.Effect("Explosion",effdata,true,true)
				self:DealDamage(ent, 8192)
				--ent.FireSusceptibility = (ent.FireSusceptibility or 0) + 99
				ent:RotgB_Ignite(self.rotgb_AbilityDamage, self:GetTowerOwner(), self, self.AbilityDuration)
			end
		elseif not self.rotgb_Transformation then return true end
	end
	if self.rotgb_Transformation then
		for index,ent in pairs(ents.FindInSphere(self:GetShootPos(), self.DetectionRadius)) do
			if ent:GetClass()=="gballoon_tower_07" then
				success = true
				ent:AddDelayedActions(self, "ROTGB_TOWER_07_TRANSFORM", 0, function(tower)
					local effdata = EffectData()
					effdata:SetOrigin(tower:GetPos())
					effdata:SetStart(tower:GetPos())
					effdata:SetEntity(tower)
					effdata:SetMagnitude(1)
					effdata:SetScale(1)
					effdata:SetRadius(1)
					util.Effect("Sparks",effdata,true,true)
					
					tower.rotgb_OldMaterial = tower:GetMaterial()
					tower.rotgb_Transformed = self.rotgb_Transformation
					
					if tower.rotgb_Transformed == 1 then
						tower.AttackDamage = tower.AttackDamage + 100
						tower:SetModel("models/props_phx/games/chess/white_queen.mdl")
					else
						tower.AttackDamage = tower.AttackDamage + 300
						tower.FireRate = tower.FireRate * 4
						tower.rotgb_Targets = tower.rotgb_Targets * 3
						tower:SetMaterial("!gBalloonRainbow")
					end
				end, self.AbilityDuration, function(tower)
					if tower.rotgb_Transformed == 1 then
						tower.AttackDamage = tower.AttackDamage - 100
					else
						tower.AttackDamage = tower.AttackDamage - 300
						tower.FireRate = tower.FireRate / 4
						tower.rotgb_Targets = tower.rotgb_Targets / 3
					end
					tower.rotgb_Transformed = nil
					tower:SetMaterial(tower.rotgb_OldMaterial)
					tower:SetModel("models/props_phx/games/chess/white_pawn.mdl")
				end)
			end
		end
		if not success then return true end
	end
end