AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Mortar Tower"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Blast those gBalloons!"
ENT.Instructions = ""
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/hunter/tubes/tube1x1x1.mdl")
ENT.FireRate = 0.5
ENT.ShellAmt = 1
ENT.Cost = 500
ENT.DetectionRadius = 512
ENT.AttackDamage = 30
ENT.UserTargeting = true
ENT.AbilityCooldown = 30
ENT.rotgb_ExploRadius = 64
ENT.rotgb_TravelTime = 0.6
ENT.UpgradeReference = {
	{
		Names = {"Faster Reload","High Impact Shells","Slippery Shells","Double Up","Artillery Cannons"},
		Descs = {
			"Slightly increases the tower's fire rate.",
			"Enables the tower to pop Black gBalloons, Zebra gBalloons and Monochrome gBlimps.",
			"Considerably increases the tower's fire rate and shells' speed.",
			"Tremendously increases fire rate and two shells are fired at once!",
			"The tower now fires three shells at once! Once every 30 seconds, shooting at this tower colossally increases its fire rate, shells' speed and causes its shots to stun gBalloons for 1 second! Lasts for 10 seconds when activated.",
		},
		Prices = {200,750,2000,15000,100000},
		Funcs = {
			function(self)
				self.FireRate = self.FireRate*1.5
			end,
			function(self)
				self.rotgb_RespectPlayers = true
			end,
			function(self)
				self.FireRate = self.FireRate*2
				self.rotgb_TravelTime = self.rotgb_TravelTime*0.5
			end,
			function(self)
				self.ShellAmt = self.ShellAmt*2
				self.FireRate = self.FireRate*3
			end,
			function(self)
				self.ShellAmt = self.ShellAmt*1.5
				--self.SeeCamo = true
				self.HasAbility = true
			end
		}
	},
	{
		Names = {"Bigger Shells","Seeking Shells","Longer Cannon","Q.U.A.K.E. Shells","Sol Shells"},--{"Bigger Shells","Longer Cannon","Shell Lobber","Q.U.A.K.E. Shells","Sol Shells"},
		Descs = {
			"Slightly increases the shells' explosion radii.",
			"Slightly increases the shells' speed and enables the tower to pop Hidden gBalloons.",
			"Considerably increases damage and increases range to infinite.",
			"Tremendously increases the shells' explosion radii and damage.",
			"Colossally increases damage. Shots will also set gBalloons on fire."
		},
		Prices = {200,1500,6000,40000,175000},--{200,1000,5000,30000,125000},
		Funcs = {
			function(self)
				self.rotgb_ExploRadius = self.rotgb_ExploRadius*1.5
			end,
			function(self)
				--self.DetectionRadius = self.DetectionRadius*1.5
				self.rotgb_TravelTime = self.rotgb_TravelTime/1.5
				self.SeeCamo = true
				--[[self:SetModel("models/hunter/tubes/tube1x1x2.mdl")
				self:PhysicsInit(SOLID_VPHYSICS)
				if IsValid(self:GetPhysicsObject()) then
					self:GetPhysicsObject():EnableMotion(false)
				end]]
			end,
			function(self)
				self.InfiniteRange = true
				self.AttackDamage = self.AttackDamage + 30
				self:SetModel("models/hunter/tubes/tube1x1x2.mdl")
				self:PhysicsInit(SOLID_VPHYSICS)
				if IsValid(self:GetPhysicsObject()) then
					self:GetPhysicsObject():EnableMotion(false)
				end
			end,
			function(self)
				self.rotgb_ExploRadius = self.rotgb_ExploRadius*2 --self.rotgb_ExploRadius = self.rotgb_ExploRadius*3
				self.AttackDamage = self.AttackDamage + 120
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 720
				self.rotgb_SetOnFire = true
			end
		}
	}
}
ENT.UpgradeLimits = {5,2}

function ENT:ROTGB_Initialize()
	self:SetMaterial("phoenix_storms/metalset_1-2")
	self:EmitSound("phx/kaboom.wav",60,100,0,CHAN_WEAPON)
end

function ENT:FireFunction(tableOfBalloons)
	self:SetModelScale(1.05)
	self:SetModelScale(1,0.2)
	self:EmitSound("weapons/crossbow/fire1.wav",75,150,1,CHAN_WEAPON)
	local poses = {}
	for i=1,self.ShellAmt do
		if IsValid(tableOfBalloons[i]) then
			table.insert(poses,tableOfBalloons[i]:GetPos())
		end
	end
	timer.Simple(self.rotgb_TravelTime,function()
		if IsValid(self) then
			local dmginfo = DamageInfo()
			dmginfo:SetAmmoType(game.GetAmmoID("Grenade"))
			dmginfo:SetAttacker(self:GetTowerOwner())
			dmginfo:SetInflictor(self)
			dmginfo:SetDamageType(self.rotgb_RespectPlayers and DMG_GENERIC or DMG_BLAST)
			dmginfo:SetDamage(self.AttackDamage)
			dmginfo:SetMaxDamage(self.AttackDamage)
			local effdata = EffectData()
			effdata:SetMagnitude(self.rotgb_ExploRadius/32)
			effdata:SetScale(self.rotgb_ExploRadius/32)
			for _,pos in pairs(poses) do
				dmginfo:SetReportedPosition(pos)
				effdata:SetOrigin(pos)
				effdata:SetStart(pos)
				--util.Effect("Explosion",effdata,true,true)
				util.Effect("HelicopterMegaBomb",effdata,true,true)
				EmitSound("phx/kaboom.wav", pos, 0, CHAN_WEAPON, 0.5, 75, SND_SHOULDPAUSE, math.random(80,120))
				--if self.rotgb_RespectPlayers then
					for k,v in pairs(ents.FindInSphere(pos,self.rotgb_ExploRadius)) do
						if self:ValidTarget(v) then
							dmginfo:SetDamagePosition(v:GetPos())
							if self.rotgb_Stun then
								v:Stun(1)
							end
							if self.rotgb_SetOnFire then
								v:RotgB_Ignite(10, self:GetTowerOwner(), self, 10)
							end
							--[[if self.rotgb_Heavy and v:GetBalloonProperty("BalloonBlimp") then
								dmginfo:ScaleDamage(5)
							end]]
							v:TakeDamageInfo(dmginfo)
							--[[if self.rotgb_Heavy and v:GetBalloonProperty("BalloonBlimp") then
								dmginfo:ScaleDamage(0.2)
							end]]
						end
					end
				--[[else
					if self.rotgb_Stun then
						for k,v in pairs(ents.FindInSphere(pos,self.rotgb_ExploRadius)) do
							if v:GetClass()=="gballoon_base" then
								v:Stun(1)
							end
						end
					end
					util.BlastDamageInfo(dmginfo,pos,self.rotgb_ExploRadius)
				end]]
			end
		end
	end)
end

function ENT:TriggerAbility()
	self.rotgb_Stun = true
	self.FireRate = self.FireRate*5
	self.rotgb_TravelTime = self.rotgb_TravelTime/5
	timer.Simple(10,function()
		self.rotgb_Stun = nil
		self.FireRate = self.FireRate/5
		self.rotgb_TravelTime = self.rotgb_TravelTime*5
	end)
end

list.Set("NPC","gballoon_tower_11",{
	Name = ENT.PrintName,
	Class = "gballoon_tower_11",
	Category = ENT.Category
})