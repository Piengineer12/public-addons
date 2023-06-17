AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Mortar Tower"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.tower.gballoon_tower_11.purpose"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/hunter/tubes/tube1x1x1.mdl")
ENT.FireRate = 1
ENT.ShellAmt = 1
ENT.Cost = 500
ENT.DetectionRadius = 512
ENT.AttackDamage = 10
ENT.UserTargeting = true
ENT.AbilityCooldown = 30
ENT.AbilityDuration = 10
ENT.rotgb_ExploRadius = 64
ENT.rotgb_TravelTime = 0.5
ENT.rotgb_Stun = 0
ENT.rotgb_StunMaxRgBE = 0
ENT.rotgb_FireDamage = 0
ENT.rotgb_FireDuration = 0
ENT.rotgb_AbilityType = 0
ENT.rotgb_HeavyMultiplier = 1
ENT.rotgb_Fragments = 0
ENT.UpgradeReference = {
	{
		Names = {"Faster Reload","High Impact Shells","Slippery Shells","Double Up","Artillery Cannons","Super Spread Cannon"},
		Descs = {
			"Slightly increases the tower's fire rate.",
			"Enables the tower to pop Black gBalloons, Zebra gBalloons and Monochrome gBlimps.",
			"Considerably increases the tower's fire rate and shells' speed.",
			"Tremendously increases fire rate and two shells are fired at once!",
			"The tower now fires three shells at once! Once every 30 seconds, shooting at this tower colossally increases its fire rate, shells' speed and causes its shots to stun gBalloons for 1 second! Lasts for 10 seconds when activated.",
			"This tower fires a shell at each gBalloon per shot!",
		},
		Prices = {200,750,2000,15000,100000,350000},
		Funcs = {
			function(self)
				self.FireRate = self.FireRate*1.5
			end,
			function(self)
				self.rotgb_RespectPlayers = true
			end,
			function(self)
				self.FireRate = self.FireRate*2
				self.rotgb_TravelTime = self.rotgb_TravelTime/2
			end,
			function(self)
				self.ShellAmt = self.ShellAmt*2
				self.FireRate = self.FireRate*3
			end,
			function(self)
				self.ShellAmt = self.ShellAmt*1.5
				self.HasAbility = true
				self.rotgb_AbilityType = bit.bor(self.rotgb_AbilityType, 1)
			end,
			function(self)
				self.ShellAmt = math.huge
			end
		}
	},
	{
		Names = {"Bigger Shells","Seeking Shells","Longer Cannon","Q.U.A.K.E. Shells","Sol Shells","Ω-Shells"},
		Descs = {
			"Slightly increases the shells' explosion radii.",
			"Slightly increases the shells' speed and enables the tower to pop Hidden gBalloons.",
			"Increases damage by 1 layer and increases range to infinite.",
			"Considerably increases the shells' explosion radii and increases damage by 4 layers.",
			"Increases damage by 24 layers! Shots will also set gBalloons on fire, popping 150 layers over 5 seconds.",
			"Increases damage by 270 layers! Shots will also deal triple damage versus gBlimps."
		},
		Prices = {200,1000,5000,30000,300000,4.5e6},
		Funcs = {
			function(self)
				self.rotgb_ExploRadius = self.rotgb_ExploRadius*1.5
			end,
			function(self)
				self.rotgb_TravelTime = self.rotgb_TravelTime/1.5
				self.SeeCamo = true
			end,
			function(self)
				self.InfiniteRange = true
				self.AttackDamage = self.AttackDamage + 10
				self:SetModel("models/hunter/tubes/tube1x1x2.mdl")
				self:PhysicsInit(SOLID_VPHYSICS)
				if IsValid(self:GetPhysicsObject()) then
					self:GetPhysicsObject():EnableMotion(false)
				end
			end,
			function(self)
				self.rotgb_ExploRadius = self.rotgb_ExploRadius*2
				self.AttackDamage = self.AttackDamage + 40
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 240
				self.rotgb_FireDamage = self.rotgb_FireDamage + 300
				self.rotgb_FireDuration = self.rotgb_FireDuration + 5
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 2700
				self.rotgb_HeavyMultiplier = self.rotgb_HeavyMultiplier * 3
			end
		}
	},
	{
		Names = {"Harder Shells", "Fragmentation Shells", "Shocking Shells", "Flaming Shells", "Blitz Cannon", "Greek Fire Cannon"},
		Descs = {
			"Increases the shells' damage by 1 layer.",
			"Each shell yields 5 fragments on impact. Each fragment has a 20% chance to hit a random gBalloon, deals damage equal to the shell's explosion damage, travels up to twice of the shell's explosion radius and four times of the shell's speed, can pop Black gBalloons and can pass through walls.",
			"Explosions stun gBalloons for 2 seconds, if they aren't immune to explosions. This upgrade can't stun gBlimps, but gBalloons stunned this way take 1 extra layer of damage from all sources.",
			"Shells deal tremendously more damage versus gBlimps and Gray gBalloons, and can stun Red gBlimps and lower. Explosions and fragments will also set gBalloons on fire, popping 20 layers over 10 seconds.",
			"Tremendously increases the number of shell fragments, considerably increases burning damage and shells can stun Green gBlimps and lower. Once every 30 seconds, shooting at this tower causes shells to be lobbed to every gBalloon on the map.",
			"Shells can stun Purple gBlimps and lower, and gBalloons permanently lose all damage type immunities (if they aren't immune to explosions)! Also tremendously increases fire damage and slightly increases ability recharge rate. Blitz Cannon ability now also incrases fire damage to 12,000 layers per second, gives a 20% chance to deal 1,000x explosion damage versus gBlimps and causes ALL Mortar Towers' shells to stun and burn gBalloons at a rate similar to the Flaming Shells upgrade. The ability lasts for 10 seconds when activated."
		},
		-- 2, 6, 12, 102, 235.73, >=100,000
		Prices = {450,1750,2500,37500,50000,35e6},
		Funcs = {
			function(self)
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.rotgb_Fragments = self.rotgb_Fragments + 5
			end,
			function(self)
				self.rotgb_Stun = self.rotgb_Stun + 2
				self.rotgb_StunVulnerability = true
			end,
			function(self)
				self.rotgb_HeavyMultiplier = self.rotgb_HeavyMultiplier * 3
				self.rotgb_GrayHeavy = true
				self.rotgb_StunMaxRgBE = self.rotgb_StunMaxRgBE + 4668
				self.rotgb_FireDamage = self.rotgb_FireDamage + 20
				self.rotgb_FireDuration = self.rotgb_FireDuration + 10
			end,
			function(self)
				self.rotgb_Fragments = self.rotgb_Fragments * 3
				self.rotgb_FireDamage = self.rotgb_FireDamage + 20
				self.rotgb_StunMaxRgBE = self.rotgb_StunMaxRgBE + 22672 - 4668
				self.HasAbility = true
				self.rotgb_AbilityType = bit.bor(self.rotgb_AbilityType, 2)
			end,
			function(self)
				self.rotgb_StunMaxRgBE = self.rotgb_StunMaxRgBE + 74000 - 22672
				self.rotgb_WeakenStun = true
				self.rotgb_FireDamage = self.rotgb_FireDamage + 80
				self.AbilityCooldown = self.AbilityCooldown / 1.5
				self.rotgb_AbilityType = bit.bor(self.rotgb_AbilityType, 4)
			end
		}
	}
}
ENT.UpgradeLimits = {6,2,0}

function ENT:ROTGB_Initialize()
	self:SetMaterial("phoenix_storms/metalset_1-2")
	self:EmitSound("phx/kaboom.wav",60,100,0,CHAN_WEAPON)
end

function ENT:ROTGB_ApplyPerks()
	self.rotgb_ExploRadius = self.rotgb_ExploRadius * (1+hook.Run("GetSkillAmount", "mortarTowerBombRadius")/100)
end

function ENT:FireFunction(tableOfBalloons)
	self:SetModelScale(1.05)
	self:SetModelScale(1,0.2)
	self:EmitSound("weapons/crossbow/fire1.wav",75,150,1,CHAN_WEAPON)
	local poses = {}
	for i=1,self.ShellAmt do
		if IsValid(tableOfBalloons[i]) then
			table.insert(poses, tableOfBalloons[i]:WorldSpaceCenter())
		else break
		end
	end
	self:Bombshell(poses)
end

function ENT:Bombshell(poses)
	timer.Simple(self.rotgb_TravelTime,function()
		if IsValid(self) then
			local shouldBlimpCrit = self.rotgb_HeavyCrits and math.random()<0.2
			if self.rotgb_Fragments > 0 then
				self:FireFragments(poses, shouldBlimpCrit)
			end
			local dmginfo = self:CreateDamage(self.AttackDamage, self.rotgb_RespectPlayers and DMG_GENERIC or DMG_BLAST)
			local effdata = EffectData()
			effdata:SetMagnitude(self.rotgb_ExploRadius/32)
			effdata:SetScale(self.rotgb_ExploRadius/32)
			for _,pos in pairs(poses) do
				dmginfo:SetReportedPosition(pos)
				effdata:SetOrigin(pos)
				effdata:SetStart(pos)
				--util.Effect("Explosion",effdata,true,true)
				util.Effect("HelicopterMegaBomb",effdata,true,true)
				if shouldBlimpCrit then
					util.Effect("rotgb_crit",effdata,true,true)
				end
				EmitSound("phx/kaboom.wav", pos, 0, CHAN_WEAPON, 0.5, 75, SND_SHOULDPAUSE, math.random(80,120))
				for k,v in pairs(ents.FindInSphere(pos,self.rotgb_ExploRadius)) do
					if self:ValidTargetIgnoreRange(v) then
						if self.rotgb_Stun > 0 and v:DamageTypeCanDamage(dmginfo:GetDamageType()) and (not v:GetBalloonProperty("BalloonBlimp") or v:GetRgBE() <= self.rotgb_StunMaxRgBE) then
							v:Stun(self.rotgb_Stun)
							if self.rotgb_StunVulnerability then
								v:InflictRotgBStatusEffect("shell_shocked", self.rotgb_Stun)
							end
							if self.rotgb_WeakenStun then
								v:InflictRotgBStatusEffect("unimmune", math.huge)
							end
						end
						if self.rotgb_FireDamage > 0 then
							v:RotgB_Ignite(self.rotgb_FireDamage, self:GetTowerOwner(), self, self.rotgb_FireDuration)
						end
						if v:GetBalloonProperty("BalloonBlimp") then
							dmginfo:ScaleDamage(self.rotgb_HeavyMultiplier)
							if shouldBlimpCrit then
								dmginfo:ScaleDamage(1000)
							end
						elseif self.rotgb_GrayHeavy and v:GetBalloonProperty("BalloonGray") then
							dmginfo:ScaleDamage(3)
						end
						self:DealDamage(v, dmginfo)
						if v:GetBalloonProperty("BalloonBlimp") then
							dmginfo:ScaleDamage(1/self.rotgb_HeavyMultiplier)
						elseif self.rotgb_GrayHeavy and v:GetBalloonProperty("BalloonGray") then
							dmginfo:ScaleDamage(1/3)
							if shouldBlimpCrit then
								dmginfo:ScaleDamage(0.001)
							end
						end
					end
				end
			end
		end
	end)
end

function ENT:FireFragments(poses, shouldBlimpCrit)
	timer.Simple(self.rotgb_TravelTime/4,function()
		if IsValid(self) then
			local dmginfo = self:CreateDamage(self.AttackDamage, DMG_BULLET)
			for _,pos in pairs(poses) do
				local gBalloonsToHit = {}
				dmginfo:SetReportedPosition(pos)
				for i=1,self.rotgb_Fragments do
					if math.random()<0.2 then
						local possiblegBalloons = {}
						for k,v in pairs(ents.FindInSphere(pos,self.rotgb_ExploRadius*2)) do
							if self:ValidTargetIgnoreRange(v) then
								possiblegBalloons[v] = true
							end
						end
						for k,v in RandomPairs(possiblegBalloons) do
							if not gBalloonsToHit[k] then
								gBalloonsToHit[k] = true break
							end
						end
					end
				end
				for balloon,_ in pairs(gBalloonsToHit) do
					if self.rotgb_FireDamage > 0 then
						balloon:RotgB_Ignite(self.rotgb_FireDamage, self:GetTowerOwner(), self, self.rotgb_FireDuration)
					end
					if balloon:GetBalloonProperty("BalloonBlimp") then
						dmginfo:ScaleDamage(self.rotgb_HeavyMultiplier)
						if shouldBlimpCrit then
							dmginfo:ScaleDamage(1000)
						end
					elseif self.rotgb_GrayHeavy and balloon:GetBalloonProperty("BalloonGray") then
						dmginfo:ScaleDamage(3)
					end
					self:DealDamage(balloon, dmginfo)
					if balloon:GetBalloonProperty("BalloonBlimp") then
						dmginfo:ScaleDamage(1/self.rotgb_HeavyMultiplier)
						if shouldBlimpCrit then
							dmginfo:ScaleDamage(0.001)
						end
					elseif self.rotgb_GrayHeavy and balloon:GetBalloonProperty("BalloonGray") then
						dmginfo:ScaleDamage(1/3)
					end
				end
			end
		end
	end)
end

function ENT:TriggerAbility()
	local abilityType = self.rotgb_AbilityType
	if bit.band(abilityType, 1)==1 then
		self:AddDelayedActions(self, "ROTGB_TOWER_11_AC", 0, function(tower)
			tower.rotgb_Stun = tower.rotgb_Stun + 1
			tower.rotgb_StunMaxRgBE = tower.rotgb_StunMaxRgBE + 2e9
			tower.FireRate = tower.FireRate*5
			tower.rotgb_TravelTime = tower.rotgb_TravelTime/5
		end, self.AbilityDuration, function(tower)
			tower.rotgb_Stun = tower.rotgb_Stun - 1
			tower.rotgb_StunMaxRgBE = tower.rotgb_StunMaxRgBE - 2e9
			tower.FireRate = tower.FireRate/5
			tower.rotgb_TravelTime = tower.rotgb_TravelTime*5
		end)
	end
	if bit.band(abilityType, 4)==4 then
		self:AddDelayedActions(self, "ROTGB_TOWER_11_GFC", 0, function(tower)
			tower.rotgb_FireDamage = tower.rotgb_FireDamage + 199880
			tower.rotgb_HeavyCrits = true
		end, self.AbilityDuration, function(tower)
			tower.rotgb_FireDamage = tower.rotgb_FireDamage - 199880
			tower.rotgb_HeavyCrits = nil
		end)
		for k,v in pairs(ents.FindByClass("gballoon_tower_11")) do
			v:AddDelayedActions(self, "ROTGB_TOWER_11_GFC_OTHER", 0, function(tower)
				tower.rotgb_Stun = tower.rotgb_Stun + 2
				tower.rotgb_StunMaxRgBE = tower.rotgb_StunMaxRgBE + 4668
				tower.rotgb_FireDamage = tower.rotgb_FireDamage + 20
				tower.rotgb_FireDuration = tower.rotgb_FireDuration + 10
			end, self.AbilityDuration, function(tower)
				tower.rotgb_Stun = tower.rotgb_Stun - 2
				tower.rotgb_StunMaxRgBE = tower.rotgb_StunMaxRgBE - 4668
				tower.rotgb_FireDamage = tower.rotgb_FireDamage - 20
				tower.rotgb_FireDuration = tower.rotgb_FireDuration - 10
			end)
		end
	end
	if bit.band(abilityType, 2)==2 then
		self:SetModelScale(1.05)
		self:SetModelScale(1,0.2)
		self:EmitSound("weapons/crossbow/fire1.wav",125,125,1,CHAN_WEAPON)
		local poses = {}
		for k,v in pairs(ROTGB_GetBalloons()) do
			table.insert(poses, v:WorldSpaceCenter())
		end
		self:Bombshell(poses)
	end
end