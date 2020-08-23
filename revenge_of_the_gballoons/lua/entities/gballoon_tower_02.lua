AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Proximity Mine"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Blow those gBalloons!"
ENT.Instructions = ""
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/dav0r/tnt/tnttimed.mdl")
ENT.FireRate = 1
ENT.Cost = 400
ENT.DetectionRadius = 384
ENT.AbilityCooldown = 30
ENT.AttackDamage = 10
ENT.UpgradeReference = {
	{
		Names = {"Faster Blasting","Faster-er Blasting","Sticky Bombs","Sticky Cluster Bombs","Infinite Sticky Bombs"},
		Descs = {
			"Increases explosion rate.",
			"Increases explosion rate further.",
			"gBalloons hit by the explosion from this tower explode again after half a second.",
			"gBalloons hit by the explosions caused by Sticky Bombs explode once more after half a second.",
			"gBalloons hit by ANY explosion caused by this tower explode again after half a second.",
		},
		Prices = {350,700,1000,2000,5000},
		Funcs = {
			function(self)
				self.FireRate = self.FireRate * 2
			end,
			function(self)
				self.FireRate = self.FireRate * 2
			end,
			function(self)
				self.rotgb_Recursion = 1
			end,
			function(self)
				self.rotgb_Recursion = 2
			end,
			function(self)
				self.rotgb_Recursion = math.huge
			end
		}
	},
	{
		Names = {"Fat Man Bombs","Mysterious Gadget","Little Boy Bombs","Antimatter Bombs","The Biggest One"},
		Descs = {
			"Increases blast size.",
			"Enables the tower to pop hidden gBalloons.",
			"Significantly increases blast damage.",
			"Enables the tower to pop Black gBalloons, Zebra gBalloons and Monochrome gBlimps.",
			"Increases blast radius considerably and damage colossally.",
		},
		Prices = {350,800,3000,10000,250000},
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
			end
		}
	},
	{
		Names = {"WOWsplosions","Heavy Bombs","Flex Remover","Bombs to be Feared","The Tsar Bomba"},
		Descs = {
			"gBalloons hit by this tower move 30% slower for 3 seconds.",
			"Sharply increases damage versus gBlimps.",
			"Explosions strip gBalloons of their Shielded and Fast properties.",
			"All gBalloons that aren't Blimps get stunned for 1 second per hit.",
			"Once every 30 seconds, firing at this tower deals massive damage to ALL gBalloons regardless of immunities.",
		},
		Prices = {350,1000,1500,10000,250000}, --11450
		Funcs = {
			function(self)
				self.rotgb_AlternateExplode = true
			end,
			function(self)
				self.rotgb_ExtraVsCeramic = true
			end,
			function(self)
				self.rotgb_StrengthBreaker = true
			end,
			function(self)
				self.rotgb_Stun = true
			end,
			function(self)
				self.HasAbility = true
			end
		}
	}
}
ENT.UpgradeLimits = {5,2,0}

function ENT:FireFunction(gBalloons)
	local dmginfo = DamageInfo()
	dmginfo:SetAmmoType(game.GetAmmoID("RPG_Round"))
	dmginfo:SetAttacker(self:GetTowerOwner())
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(self.rotgb_HitBlack and DMG_GENERIC or DMG_BLAST)
	dmginfo:SetReportedPosition(self:GetPos())
	dmginfo:SetDamage(self.AttackDamage)
	dmginfo:SetMaxDamage(self.AttackDamage)
	local effdata = EffectData()
	effdata:SetOrigin(self:GetPos())
	effdata:SetMagnitude(6)
	effdata:SetScale(6)
	if self.rotgb_BIGBOI then
		effdata:SetMagnitude(9)
		effdata:SetScale(9)
	end
	effdata:SetStart(self:GetPos())
	effdata:SetEntity(self)
	util.Effect("HelicopterMegaBomb",effdata,true,true)
	self:EmitSound("phx/kaboom.wav", 75, math.random(80,120), 0.5)
	--if self.rotgb_AlternateExplode then
		for k,v in pairs(gBalloons) do
			dmginfo:SetDamagePosition(v:GetPos())
			local scaled = false
			if self.rotgb_ExtraVsCeramic and v:GetBalloonProperty("BalloonBlimp") then
				dmginfo:ScaleDamage(3)
				scaled = true
			end
			if not v:GetBalloonProperty("BalloonBlimp") then
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
				if self.rotgb_Stun then
					v:Stun(1)
				end
			end
			if self.rotgb_AlternateExplode then
				v:Slowdown("ROTGB_PROX_MINE",0.7,3)
			end
			v:TakeDamageInfo(dmginfo)
			if scaled then
				dmginfo:ScaleDamage(1/3)
			end
			if self.rotgb_Recursion then
				self:Recur(v,self.rotgb_Recursion)
			end
		end
	--[[else
		util.BlastDamageInfo(dmginfo,self:GetPos(),self.DetectionRadius)
		if self.rotgb_Recursion then
			for k,v in pairs(gBalloons) do
				if IsValid(v) then
					self:Recur(v,self.rotgb_Recursion)
				end
			end
		end
	end]]
end

function ENT:Recur(ball,cur)
	local amt = 0
	for k,v in pairs(ents.FindInSphere(ball:GetPos(),self.DetectionRadius)) do
		if self:ValidTarget(v) then
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
							local scale = 1
							if self.rotgb_ExtraVsCeramic and v:GetBalloonProperty("BalloonBlimp") then
								scale = 3
							end
							dmginfo:ScaleDamage(scale)
							if not v:GetBalloonProperty("BalloonBlimp") then
								if self.rotgb_StrengthBreaker and v:GetBalloonProperty("BalloonShielded") then
									v:SetHealth(v:Health()/2)
									v:SetMaxHealth(v:GetMaxHealth()/2)
									v.Properties.BalloonShielded = false
									v:SetNWBool("RenderShield",false)
								end
								if self.rotgb_Stun then
									v:Stun(1)
								end
							end
							if self.rotgb_AlternateExplode then
								v:Slowdown("ROTGB_PROX_MINE",0.75,3)
							end
							v:TakeDamageInfo(dmginfo)
							dmginfo:ScaleDamage(1/scale)
						--[[else
							util.BlastDamageInfo(dmginfo,v:GetPos(),self.DetectionRadius)
						end]]
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
end

function ENT:TriggerAbility()
	local entities = ents.FindByClass("gballoon_base")
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
		ent:TakeDamage(32767,self:GetTowerOwner(),self)
	end
end

list.Set("NPC","gballoon_tower_02",{
	Name = ENT.PrintName,
	Class = "gballoon_tower_02",
	Category = ENT.Category
})