AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Proximity Mine"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.tower.gballoon_tower_02.purpose"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/dav0r/tnt/tnttimed.mdl")
ENT.FireRate = 0.5
ENT.Cost = 850
ENT.DetectionRadius = 256
ENT.AbilityCooldown = 30
ENT.AttackDamage = 10
ENT.rotgb_AbilityDamage = 32768
ENT.UpgradeReference = {
	{
		Prices = {400,1200,7000,27500,275000},
		Funcs = {
			function(self)
				self.FireRate = self.FireRate * 1.5
			end,
			function(self)
				self.FireRate = self.FireRate * 2
			end,
			function(self)
				self.rotgb_Recursion = 1
			end,
			function(self)
				self.FireRate = self.FireRate / 2
				self.rotgb_Recursion = 2
			end,
			function(self)
				self.DetectionRadius = self.DetectionRadius * 3
				self.AttackDamage = self.AttackDamage + 20
			end
		}
	},
	{
		-- 1.5, 2, 3, 2, 10 (5*2), 10 (2*5)
		Prices = {400,1200,4500,6500,120000,1.2e6},
		Funcs = {
			function(self)
				self.DetectionRadius = self.DetectionRadius * 1.5
			end,
			function(self)
				self.SeeCamo = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 20
			end,
			function(self)
				self.rotgb_HitBlack = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 120
				self.DetectionRadius = self.DetectionRadius * 2
				self.rotgb_BIGBOI = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 150
				self.FireRate = self.FireRate * 5
			end
		}
	},
	{
		Prices = {400,3500,12500,30000,100000,1.25e6},
		Funcs = {
			function(self)
				self.rotgb_ExtraVsCeramic = true
			end,
			function(self)
				self.rotgb_AlternateExplode = true
			end,
			function(self)
				self.rotgb_StrengthBreaker = true
			end,
			function(self)
				self.rotgb_Stun = true
			end,
			function(self)
				self.HasAbility = true
			end,
			function(self)
				self.rotgb_AbilityDamage = self.rotgb_AbilityDamage * 16
			end
		}
	}
}
ENT.UpgradeLimits = {6,2,0}

function ENT:ROTGB_ApplyPerks()
	self.DetectionRadius = self.DetectionRadius * (1+hook.Run("GetSkillAmount", "proximityMineRange")/100)
end

function ENT:FireFunction(gBalloons)
	self:EmitSound("phx/kaboom.wav", 75, math.random(80,120), 0.5)
	self.rotgb_Exploded = true
	self:Explode(self:GetShootPos(), self.rotgb_Recursion or 0, gBalloons)
end

function ENT:ROTGB_Think()
	if self.rotgb_Exploded then
		local dmginfo = DamageInfo()
		dmginfo:SetAmmoType(game.GetAmmoID("RPG_Round"))
		dmginfo:SetAttacker(self:GetTowerOwner())
		dmginfo:SetInflictor(self)
		dmginfo:SetDamageType(self.rotgb_HitBlack and DMG_GENERIC or DMG_BLAST)
		dmginfo:SetReportedPosition(self:GetShootPos())
		
		for k,v in pairs(ROTGB_GetBalloons()) do
			if v.ROTGB_TOWER_02_Marks then
				dmginfo:SetDamage(v.ROTGB_TOWER_02_Marks)
				dmginfo:SetMaxDamage(v.ROTGB_TOWER_02_Marks)
				v:TakeDamageInfo(dmginfo)
				v.ROTGB_TOWER_02_Marks = nil
			end
		end
		self.rotgb_Exploded = false
	end
end

function ENT:Explode(pos, recursion, gBalloons)
	if not gBalloons then
		gBalloons = ents.FindInSphere(pos, self.DetectionRadius)
	end
	local effdata = EffectData()
	effdata:SetOrigin(pos)
	effdata:SetMagnitude(2)
	effdata:SetScale(2)
	effdata:SetRadius(2)
	effdata:SetNormal(LocalToWorld(vector_up, angle_zero, vector_origin, self:GetAngles()))
	if self.rotgb_BIGBOI then
		effdata:SetMagnitude(3)
		effdata:SetScale(3)
		effdata:SetRadius(3)
	end
	effdata:SetStart(pos)
	util.Effect("StunstickImpact",effdata,true,true)
	for k,v in pairs(gBalloons) do
		if self:ValidTargetIgnoreRange(v) then
			local markedDamage = self.AttackDamage
			if self.rotgb_ExtraVsCeramic and v:GetBalloonProperty("BalloonBlimp") then
				markedDamage = markedDamage * 2
			end
			if self.rotgb_StrengthBreaker then
				v:SetBalloonProperty("BalloonShielded", false)
				v:SetBalloonProperty("BalloonFast", false)
			end
			if not v:GetBalloonProperty("BalloonBlimp") then
				if self.rotgb_AlternateExplode then
					v:Slowdown("ROTGB_PROX_MINE",0.5,3)
				end
				if self.rotgb_Stun then
					if not (v:GetBalloonProperty("BalloonWhite") or v:GetBalloonProperty("BalloonBlimp") or v:GetBalloonProperty("BalloonBlack")) or v:HasRotgBStatusEffect("unimmune") then
						v:Freeze2(2)
					elseif not v:GetBalloonProperty("BalloonBlack") then
						v:ShowResistEffect(1)
					end
				end
			end
			v.ROTGB_TOWER_02_Marks = (v.ROTGB_TOWER_02_Marks or 0) + markedDamage
		end
	end
	if recursion > 0 then
		--self:Recur(v,self.rotgb_Recursion)
		timer.Simple(1/3, function()
			if IsValid(self) then
				local distance = self.DetectionRadius/2
				for i=45,360,45 do
					local angle = math.rad(i)
					local nextPos = pos + Vector(math.sin(angle)*distance, math.cos(angle)*distance, 0)
					self:Explode(nextPos, recursion-1)
				end
				self.rotgb_Exploded = true
			end
		end)
	end
end

function ENT:TriggerAbility()
	local entities = ROTGB_GetBalloons()
	if not next(entities) then return true end
	for index,ent in pairs(entities) do
		local effdata = EffectData()
		effdata:SetOrigin(Vector(ent:GetPos()))
		effdata:SetStart(Vector(ent:GetPos()))
		effdata:SetEntity(ent)
		util.Effect("HelicopterMegaBomb",effdata,true,true)
		ent:EmitSound("phx/kaboom.wav", 75, math.random(80,120), 0.5)
		--[[if ent:GetBalloonProperty("BalloonBlimp") then
			ent:TakeDamage(ent:GetMaxHealth()/2,self,self)
		else
			ent:Pop(-1)
		end]]
		ent:TakeDamage(self.rotgb_AbilityDamage,self:GetTowerOwner(),self)
	end
end