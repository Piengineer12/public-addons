AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Proximity Mine"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "This tower very slowly creates explosions that deal damage to everything in its radius."
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
		Names = {"Faster Blasting","Faster-er Blasting","Cluster Bombs","Recursive Cluster Bombs","Field Destroyer"},
		Descs = {
			"Slightly increases explosion rate.",
			"Considerably increases explosion rate.",
			"Each explosion created by this tower causes 8 more explosions!",
			"Considerably reduces fire rate, but more explosions are created!",
			"Tremendously increases blast range and damage."
		},
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
		Names = {"Fat Bombs","Mysterious Gadget","Concentrated Explosions","Antimatter Bombs","The Biggest One","Pyromaniac"},
		Descs = {
			"Slightly increases blast size.",
			"Enables the tower to pop hidden gBalloons.",
			"Tremendously increases blast damage.",
			"Enables the tower to pop Black gBalloons, Zebra gBalloons and Monochrome gBlimps.",
			"Increases blast size considerably and damage colossally.",
			"Considerably increases blast damage and colossally increases fire rate!"
		},
		Prices = {400,1500,5000,8500,125000,1.25e6},
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
		Names = {"Heavy Bombs","WOWsplosions","Flex Remover","Ice Bombs","The Tsar Bomba","Meteor Nuke"},
		Descs = {
			"Considerably increases damage versus gBlimps.",
			"gBalloons hit by this tower move 50% slower for 3 seconds.",
			"Explosions strip gBalloons of their Shielded and Fast properties.",
			"Freezes gBalloons for 2 seconds per hit. Note that White and Black gBalloons cannot be frozen by this upgrade.",
			"Once every 30 seconds, firing at this tower deals massive damage to all gBalloons regardless of immunities.",
			"The Tsar Bomba deals far more damage, enough to wipe out all Purple gBlimps on the map!",
		},
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
				--[[if self.rotgb_HitBlack and v:Health() <= v.ROTGB_TOWER_02_Marks then
					dmginfo:SetDamage(v:GetRgBE() * 1000)
					dmginfo:SetMaxDamage(v:GetRgBE() * 1000)
				else]]
					dmginfo:SetDamage(v.ROTGB_TOWER_02_Marks)
					dmginfo:SetMaxDamage(v.ROTGB_TOWER_02_Marks)
				--end
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
	util.Effect(recursion == self.rotgb_Recursion and "HelicopterMegaBomb" or "StunstickImpact",effdata,true,true)
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

--[=[function ENT:Recur(ball,cur)
	local amt = 0
	for k,v in pairs(ents.FindInSphere(ball:GetPos(),self.DetectionRadius)) do
		if self:ValidTargetIgnoreRange(v) then
			v.WillExplode = (v.WillExplode or 0) + 1
			if v.WillExplode==1 then
				timer.Simple(0.5,function()
					if IsValid(self) and IsValid(v) then
						local dmginfo = DamageInfo()
						dmginfo:SetAmmoType(game.GetAmmoID("RPG_Round"))
						dmginfo:SetAttacker(self:GetTowerOwner())
						dmginfo:SetInflictor(self)
						dmginfo:SetDamageType(self.rotgb_HitBlack and DMG_GENERIC or DMG_BLAST)
						dmginfo:SetReportedPosition(v:GetPos())
						dmginfo:SetDamage(self.AttackDamage*v.WillExplode)
						dmginfo:SetMaxDamage(self.AttackDamage*v.WillExplode)
						local effdata = EffectData()
						effdata:SetOrigin(v:GetPos())
						if self.rotgb_BIGBOI then
							effdata:SetMagnitude(2)
							effdata:SetScale(2)
						end
						effdata:SetStart(v:GetPos())
						effdata:SetEntity(v)
						util.Effect("HelicopterMegaBomb",effdata,true,true)
						v:EmitSound("phx/kaboom.wav", 75, math.random(80,120), 0.5)
						--if self.rotgb_AlternateExplode then
							if self.rotgb_ExtraVsCeramic and v:GetBalloonProperty("BalloonBlimp") then
								dmginfo:ScaleDamage(3)
							end
							if self.rotgb_HitBlack and v:Health() <= dmginfo:GetDamage() then
								dmginfo:SetDamage(v:GetRgBE() * 1000)
							end
							if self.rotgb_StrengthBreaker then
								if v:GetBalloonProperty("BalloonShielded") then
									v:SetHealth(v:Health()/2)
									v:SetMaxHealth(v:GetMaxHealth()/2)
									v.Properties.BalloonShielded = false
									v:SetNWBool("RenderShield",false)
								end
								if v:GetBalloonProperty("BalloonFast") then
									v.loco:SetAcceleration(v.loco:GetAcceleration()/2)
									v.loco:SetDesiredSpeed(v.loco:GetAcceleration()*0.2)
									v.loco:SetDeceleration(v.loco:GetAcceleration())
									v.Properties.BalloonFast = false
									if IsValid(self.FastTrail) then self.FastTrail:Remove() end
								end
							end
							if not v:GetBalloonProperty("BalloonBlimp") and self.rotgb_Stun then
								if not (v:GetBalloonProperty("BalloonWhite") or v:GetBalloonProperty("BalloonBlimp") or v:GetBalloonProperty("BalloonBlack")) or v:HasRotgBStatusEffect("unimmune") then
									v:Freeze2(2)
								elseif not v:GetBalloonProperty("BalloonBlack") then
									v:ShowResistEffect(1)
								end
							end
							if self.rotgb_AlternateExplode then
								v:Slowdown("ROTGB_PROX_MINE",0.7,3)
							end
							--dmginfo:ScaleDamage(1/scale)
						--[[else
							util.BlastDamageInfo(dmginfo,v:GetPos(),self.DetectionRadius)
						end]]
						v:TakeDamageInfo(dmginfo)
						if cur > 1 then
							self:Recur(v,cur-1)
						end
						v.WillExplode = nil
					end
				end)
			end
			amt = amt + 1
			if amt > 10 then break end
		end
	end
end]=]

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