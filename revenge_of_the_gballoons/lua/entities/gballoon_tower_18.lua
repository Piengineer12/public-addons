AddCSLuaFile()
ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Potion Brewer [WIP]"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.tower.gballoon_tower_18.purpose"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/mechanics/wheels/wheel_extruded_48.mdl")
ENT.IsWaterTower = true
ENT.FireRate = 1
ENT.MaxFireRate = 1/0.115
ENT.Cost = 1000
ENT.DetectionRadius = 384
ENT.AttackDamage = 10
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,30)
ENT.UserTargeting = true
ENT.AbilityDuration = 0
ENT.AbilityCooldown = 30
ENT.ProjectileSize = 1
ENT.rotgb_PotionDelay = 1
ENT.rotgb_HarmingPotionEffects = 1
ENT.rotgb_Abilities = 0
ENT.rotgb_EnergyPotionFireRate = 1.5
ENT.rotgb_EnergyPotionDuration = 3
ENT.rotgb_BerserkPotionArmoredBlimpDamage = 0
ENT.rotgb_BerserkPotionMultipurposeEngineDamageMul = 1
ENT.rotgb_BerserkPotionDuration = 6
ENT.rotgb_BerserkPotionCooldowns = -2
ENT.rotgb_AcidPotionDamage = 10
ENT.rotgb_LaserDamage = 0
ENT.rotgb_LaserAbilityDamage = 200
ENT.rotgb_MidasDiamondSingularity = 0
ENT.rotgb_ReturnPortalDuration = 10
ENT.rotgb_IdleAbilities = 0
ENT.rotgb_Barricades = 1
ENT.rotgb_BarricadeDamage = 100
ENT.rotgb_BarricadeSpeed = 0
ENT.rotgb_HastePotionAttack = 0
ENT.rotgb_HastePotionTaps = 2
ENT.rotgb_HastePotionFireRate = 1
ENT.UpgradeReference = {
	{
		Prices = {450, 2750, 12500, 50e3, 125e3, 400e3, 5e6},
		Funcs = {
			function(ent)
				ent.FireRate = ent.FireRate*1.5
			end,
			function(ent)
				ent.AttackDamage = ent.AttackDamage + 20
			end,
			function(ent)
				ent.FireRate = ent.FireRate*2
				ent.ProjectileSize = ent.ProjectileSize*2
			end,
			function(ent)
				ent.rotgb_PotionOrder[2] = 1
			end,
			function(ent)
				ent.rotgb_HarmingPotionEffects = bit.bor(ent.rotgb_HarmingPotionEffects, 2)
			end,
			function(ent)
				ent.HasAbility = true
				ent.rotgb_Abilities = bit.bor(ent.rotgb_Abilities, 1)
			end,
			function(ent)
				ent.AbilityDuration = math.max(ent.AbilityDuration, 6)
				ent.rotgb_Electron = true
			end,
		}
	},
	{
		Prices = {0, 1500, 50e3, 100e3, 125e3},
		Funcs = {
			function(ent)
				ent.rotgb_HarmingPotionsTargetTowers = true
				local removedHarming = bit.band(ent.rotgb_HarmingPotionEffects, bit.bnot(1))
				ent.rotgb_HarmingPotionEffects = bit.bor(removedHarming, 4)
			end,
			function(ent)
				ent.FireRate = ent.FireRate*1.5
				ent.rotgb_EnergyPotionDuration = ent.rotgb_EnergyPotionDuration*1.5
				ent.rotgb_EnergyPotionFireRate = ent.rotgb_EnergyPotionFireRate*4/3
			end,
			function(ent)
				ent.rotgb_PotionOrder[3] = 2
				ent.rotgb_PotionOrder[8] = 2
			end,
			function(ent)
				ent.rotgb_EnergyPotionDuration = ent.rotgb_EnergyPotionDuration*2
				ent.rotgb_BerserkPotionDuration = ent.rotgb_BerserkPotionDuration*2
				ent.rotgb_BerserkPotionArmoredBlimpDamage = ent.rotgb_BerserkPotionArmoredBlimpDamage + 150
				ent.rotgb_BerserkPotionMultipurposeEngineDamageMul = ent.rotgb_BerserkPotionMultipurposeEngineDamageMul*2
				ent.rotgb_BerserkPotionCooldowns = ent.rotgb_BerserkPotionCooldowns*2
			end,
			function(ent)
				ent.rotgb_EnergyPotionDuration = math.huge
				ent.rotgb_BerserkPotionDuration = math.huge
				ent.rotgb_EnergyBerserkPotionMorePECDamage = true
			end,
		}
	},
	{
		Prices = {100, 400, 500, 20e3, 125e3},
		Funcs = {
			function(ent)
				ent.FireWhenNoEnemies = true
			end,
			function(ent)
				ent.rotgb_AcidPotionDamage = ent.rotgb_AcidPotionDamage + 20
				ent.rotgb_AcidPotionMoreGrayCeramicDamage = true
			end,
			function(ent)
				ent.rotgb_AcidPotionUnstable = true
			end,
			function(ent)
				ent.HasAbility = true
				ent.rotgb_Abilities = bit.bor(ent.rotgb_Abilities, 2)
				ent.AbilityDuration = math.max(ent.AbilityDuration, 15)
			end,
			function(ent)
				ent.rotgb_LaserAbilityDamage = ent.rotgb_LaserAbilityDamage*2
				ent.rotgb_LaserAbilitySpinup = true
			end,
		}
	},
	{
		Prices = {1e3, 2e3, 3e3, 500e3, 1.5e6},
		Funcs = {
			function(ent)
				ent.ProjectileSize = ent.ProjectileSize*2
				ent.rotgb_AcidPotionDamage = ent.rotgb_AcidPotionDamage + 10
			end,
			function(ent)
				ent.rotgb_Alchemic = true
			end,
			function(ent)
				ent.rotgb_HarmingPotionEffects = bit.bor(ent.rotgb_HarmingPotionEffects, 8)
			end,
			function(ent)
				ent.rotgb_MidasDiamondSingularity = 1
			end,
			function(ent)
				ent.rotgb_MidasDiamondSingularity = 2
				ent.HasAbility = true
				ent.rotgb_Abilities = bit.bor(ent.rotgb_Abilities, 4)
				ent.AbilityDuration = math.max(ent.AbilityDuration, 15)
			end,
		}
	},
	{
		Prices = {2.5e3, 50e3, 150e3, 200e3, 2e6},
		Funcs = {
			function(ent)
				ent.rotgb_PotionOrder[5] = 4
			end,
			function(ent)
				ent.rotgb_PotionOrder[4] = 3
			end,
			function(ent)
				ent.rotgb_LifeforcePotionResetCooldowns = true
			end,
			function(ent)
				ent.rotgb_PanicPotions = true
			end,
			function(ent)
				ent.rotgb_SelfSacrifice = true
			end,
		}
	},
	{
		Prices = {2.5e3, 3e3, 5e3, 10e3, 25e3, 125e3},
		Funcs = {
			function(ent)
				ent.rotgb_PotionOrder[6] = 5
			end,
			function(ent)
				ent.rotgb_PotionOrder[9] = 6
			end,
			function(ent)
				ent.HasAbility = true
				ent.rotgb_Abilities = bit.bor(ent.rotgb_Abilities, 8)
				ent.AbilityDuration = math.max(ent.AbilityDuration, 10)
			end,
			function(ent)
				ent.rotgb_ReturnPortalDuration = ent.rotgb_ReturnPortalDuration * 3
				ent.AbilityDuration = math.max(ent.AbilityDuration, 30)
				ent.rotgb_ReturnPortalsAffectBlimps = true
			end,
			function(ent)
				ent.rotgb_ReturnPortalsDamage = true
			end,
			function(ent)
				ent.rotgb_IdleAbilities = bit.bor(ent.rotgb_IdleAbilities, 1)
				ent.rotgb_ReturnPortalsMagicAttack = true
			end,
		}
	},
	{
		Prices = {300, 1250, 2000, 3500, 22500, 250e3, 1e6},
		Funcs = {
			function(ent)
				ent.rotgb_HarmingPotionEffects = bit.bor(ent.rotgb_HarmingPotionEffects, 16)
			end,
			function(ent)
				ent.rotgb_HarmingPotionSlow = true
			end,
			function(ent)
				ent.HasAbility = true
				ent.rotgb_Abilities = bit.bor(ent.rotgb_Abilities, 16)
			end,
			function(ent)
				ent.rotgb_BarricadeDamage = ent.rotgb_BarricadeDamage * 3
			end,
			function(ent)
				ent.rotgb_BarricadeMulti = true
				ent.rotgb_Barricades = ent.rotgb_Barricades * 3
			end,
			function(ent)
				ent.rotgb_BarricadeSpeed = 200
				ent.rotgb_BarricadeDamage = ent.rotgb_BarricadeDamage * 5
			end,
			function(ent)
				ent.rotgb_IdleAbilities = bit.bor(ent.rotgb_IdleAbilities, 2)
				ent.rotgb_BarricadeDamage = ent.rotgb_BarricadeDamage * 2
			end,
		}
	},
	{
		Prices = {950, 17.5e3, 65e3, 125e3, 200e3},
		Funcs = {
			function(ent)
				ent.rotgb_PotionOrder[10] = 7
			end,
			function(ent)
				ent.rotgb_HastePotionAttack = ent.rotgb_HastePotionAttack + 20
				ent.rotgb_HastePotionTaps = ent.rotgb_HastePotionTaps * 1.5
			end,
			function(ent)
				ent.rotgb_HastePotionFireRate = ent.rotgb_HastePotionFireRate * 5
				ent.rotgb_HastePotionAttack = ent.rotgb_HastePotionAttack + 30
				ent.rotgb_HastePotionTaps = ent.rotgb_HastePotionTaps / 3 * 5
			end,
			function(ent)
				ent.HasAbility = true
				ent.rotgb_Abilities = bit.bor(ent.rotgb_Abilities, 32)
				ent.AbilityDuration = math.max(ent.AbilityDuration, 15)
			end,
			function(ent)
				ent.rotgb_Hyperclock = true
				ent.rotgb_HastePotionTaps = ent.rotgb_HastePotionTaps * 2
			end,
		}
	},
}
ENT.UpgradeLimits = {7,6,5,4,3,2,1,0}
-- {- (0), Hermes (1), Berserk (2), Lifeforce/3 (3), Healing (4),
-- Mundane (5), - (0), Berserk (2), Projectile (6), Haste (7)},
-- Unused (8), Acid (9), Panic (10)
local color_yellow = Color(255, 255, 0)
local vector_yellow = Vector(255, 255, 0)
local vector_green = Vector(0, 255, 0)
local vector_magenta = Vector(255, 0, 255)
local vector_white = Vector(255, 255, 255)
local vector_black = Vector(0, 0, 0)
local potionColors = {
	[0] = Color(255, 255, 255), -- white
	Color(0, 255, 255), -- aqua
	Color(255, 127, 0), -- orange
	Color(255, 0, 255), -- magenta
	Color(255, 0, 0), -- red
	Color(0, 0, 255), -- blue
	Color(127, 0, 255), -- purple
	Color(255, 255, 0), -- yellow
	Color(0, 0, 0, 0),
	Color(0, 255, 0), -- green
	Color(0, 0, 0), -- black
}

function ENT:ROTGB_Initialize()
	self.rotgb_PotionOrder = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	self.rotgb_TargetedBalloons = {}
	self.rotgb_AfterShockPositions = {}
	self.rotgb_AcidCloudPositions = {}
	self.rotgb_MidasCloudPositions = {}
	self.rotgb_Singularities = {}
	self.rotgb_ReturnPortals = {}
	self.rotgb_ReturnPortalsRippedBalloons = {}
end

local spawnerOffset = Vector(0, 0, 10)
function ENT:ROTGB_Think()
	if next(self.rotgb_AfterShockPositions) or next(self.rotgb_AcidCloudPositions) or next(self.rotgb_MidasCloudPositions)
	or next(self.rotgb_Singularities) or next(self.rotgb_ReturnPortals) or self.rotgb_IdleAbilities ~= 0 then
		local gBalloonPositions = {}
		for i,v in ipairs(ROTGB_GetBalloons()) do
			gBalloonPositions[v] = v:WorldSpaceCenter()
		end
		
		local damage = (self.rotgb_ElectronCloudStacks or 0) * 10
		for i,v in ipairs(self.rotgb_AfterShockPositions) do
			for k,v2 in pairs(gBalloonPositions) do
				if v:DistToSqr(v2) <= 16384 and self:ValidTargetIgnoreRange(k) then
					self:DealDamageProxy(k, damage, DMG_SHOCK)
				end
			end 
		end
		
		self.rotgb_AcidNextThink = self.rotgb_AcidNextThink or 0
		if self.rotgb_AcidNextThink < self:CurTime() then
			self.rotgb_AcidNextThink = self:CurTime() + 1
			
			for i,v in ipairs(self.rotgb_AcidCloudPositions) do
				for k,v2 in pairs(gBalloonPositions) do
					if v:DistToSqr(v2) <= 16384 and self:ValidTargetIgnoreRange(k) then
						damage = self.rotgb_AcidPotionDamage
						if k:GetSlowdown("ROTGB_GLUE_TOWER") then
							damage = damage + 10
						end
						if self.rotgb_AcidPotionMoreGrayCeramicDamage and (k:GetBalloonProperty("BalloonType") == "gballoon_ceramic" or k:GetBalloonProperty("BalloonGray")) then
							damage = damage + 20
						end
						if self.rotgb_AcidPotionUnstable and k:GetBalloonProperty("BalloonBlimp") then
							k.rotgb_Tower18_Unstable = self
						end
						self:DealDamageProxy(k, damage, DMG_ACID)
					end
				end
			end
			
			local index = 1
			while self.rotgb_ReturnPortalsRippedBalloons[index] do
				local bln = self.rotgb_ReturnPortalsRippedBalloons[index]
				if IsValid(bln) then
					self:DealDamageProxy(bln, 100, DMG_GENERIC)
					index = index + 1
				else
					table.remove(self.rotgb_ReturnPortalsRippedBalloons, index)
				end
			end
		end
		
		local index = 1
		while self.rotgb_MidasCloudPositions[index] do
			local pos = self.rotgb_MidasCloudPositions[index]
			local success = false
			
			for k,v in pairs(gBalloonPositions) do
				if pos:DistToSqr(v) <= 4096 and self:ValidTargetIgnoreRange(k) then
					local valueMulExists = k.rotgb_ValueMultipliers and k.rotgb_ValueMultipliers.ROTGB_TOWER_18
					and k.rotgb_ValueMultipliers.ROTGB_TOWER_18[1] > k:CurTime()
					
					if not k:GetBalloonProperty("BalloonBlimp") and not valueMulExists then
						k:MultiplyValue("ROTGB_TOWER_18", self, 1, 1000)
						success = true
					elseif self.rotgb_MidasDiamondSingularity > 0 and not k.rotgb_Tower18_Diamond then
						k.rotgb_Tower18_Diamond = self
						success = true
					end
				end
			end
			
			if success then
				table.remove(self.rotgb_MidasCloudPositions, index)
			else
				index = index + 1
			end
		end
	
		for k,v in pairs(self.rotgb_Singularities) do
			if IsValid(k) then
				local pos = k:WorldSpaceCenter()
				
				for k2,v2 in pairs(gBalloonPositions) do
					if pos:DistToSqr(v2) <= 4096 and self:ValidTargetIgnoreRange(k2) then
						k2.rotgb_Tower18_SingularityMarked = self
					end
				end
			else
				self.rotgb_Singularities[k] = nil
			end
		end
		
		for i,v in ipairs(self.rotgb_ReturnPortals) do
			for k,v2 in pairs(gBalloonPositions) do
				if v:DistToSqr(v2) <= 16384 and self:ValidTargetIgnoreRange(k) and not k.rotgb_Tower18_Teleported
				and (not k:GetBalloonProperty("BalloonBlimp") or self.rotgb_ReturnPortalsAffectBlimps) then
					-- return to start
					local spawners = ents.FindByClass("gballoon_spawner")
					local spawner = spawners[math.random(#spawners)]
					k:SetPos(spawner:GetPos() + spawnerOffset)
					k:SetBalloonProperty("BalloonFast", true)
					spawner:DetermineNextTarget(k)
					k.rotgb_Tower18_Teleported = true
					
					if self.rotgb_ReturnPortalsDamage then
						local data = EffectData()
						data:SetEntity(self)
						data:SetDamageType(k:EntIndex())
						data:SetMagnitude(0)
						data:SetStart(vector_magenta)
						util.Effect("rotgb_sticky", data, true, true)
						
						table.insert(self.rotgb_ReturnPortalsRippedBalloons, k)
					end
				end
			end 
		end
		
		if bit.band(self.rotgb_IdleAbilities, 1) ~= 0 and table.IsEmpty(self.rotgb_ReturnPortals) then
			for k,v in pairs(gBalloonPositions) do
				local target = k:GetTarget()
				--print(v:Distance(target:GetPos()), k, target)
				if (IsValid(target) and v:DistToSqr(target:GetPos()) <= 16384 and target:GetClass() == "gballoon_target" and not target:GetIsBeacon()) and self:ValidTargetIgnoreRange(k) then
					--print(self, k, target)
					self.rotgb_ReturningTarget = k
					self:TriggerAbility()
				end
			end
		end
		
		if bit.band(self.rotgb_IdleAbilities, 2) ~= 0 then
			if self:GetAbilityCharge() >= 1 then
				self:DoAbility()
			end
			
			if #ents.FindByClass("gballoon_tower_18_minion") < 6 then
				for k,v in pairs(gBalloonPositions) do
					local target = k:GetTarget()
					if (IsValid(target) and v:DistToSqr(target:GetPos()) <= 16384 and target:GetClass() == "gballoon_target" and not target:GetIsBeacon()) and self:ValidTargetIgnoreRange(k) then
						self.rotgb_ReturningTarget = k
						self:TriggerAbility()
					end
				end
			end
		end
	end
end

function ENT:DealDamageProxy(bln, ...)
	if bln:GetBalloonProperty("BalloonGray") and self.rotgb_Alchemic then
		self:DealDamage(bln, 2147483647, DMG_DISSOLVE)
		self:AddCash(25, self:GetTowerOwner())
	else
		self:DealDamage(bln, ...)
	end
end

local alwaysProjectileTargets = {
	gballoon_tower_12 = true,
	gballoon_tower_13 = true,
	gballoon_tower_14 = true,
	gballoon_tower_15 = true,
	gballoon_tower_16 = true,
	gballoon_tower_17 = true,
	gballoon_tower_18 = true,
}
function ENT:FireFunction(tableOfBalloons, damageMultiplier)
	self.rotgb_PotionCharge = (self.rotgb_PotionCharge or 0) + damageMultiplier
	
	local damage = self.rotgb_LaserDamage
	if damage > 0 and IsValid(tableOfBalloons[1]) then
		self:LaserAttack(tableOfBalloons[1], damage, self.rotgb_LaserSpinup and 10 or 4, {
			color = color_yellow,
			scroll = 35
		})
		
		if tableOfBalloons[1]:GetBalloonProperty("BalloonGray") and self.rotgb_Alchemic then
			self:DealDamageProxy(tableOfBalloons[1], 0, DMG_GENERIC)
		end
	end
	
	while self.rotgb_PotionCharge >= self.rotgb_PotionDelay do
		self.rotgb_PotionCharge = 0--self.rotgb_PotionCharge - self.rotgb_PotionDelay
		if next(tableOfBalloons) then
			-- what is our current potion?
			local potionNumber
			if self.rotgb_NextPotionIsPanic then
				self.rotgb_NextPotionIsPanic = nil
				potionNumber = 10
			else
				self.rotgb_CurrentPotion = (self.rotgb_CurrentPotion or 0) % 10 + 1
				potionNumber = self.rotgb_PotionOrder[self.rotgb_CurrentPotion]
			end
			
			if potionNumber == 3 then
				-- only allow it 1/3 of the time
				self.rotgb_LifeforcePotionCharge = (self.rotgb_LifeforcePotionCharge or 0) % 3 + 1
				if self.rotgb_LifeforcePotionCharge ~= 3 then
					potionNumber = 0
				end
			elseif potionNumber == 4 and self.rotgb_HealingPotionIsPanic then
				potionNumber = 10
			end
			
			if potionNumber == 0 and not self.rotgb_HarmingPotionsTargetTowers then
				-- calculate target
				local success = nil
				for k, v in pairs(self.rotgb_TargetedBalloons) do
					if not IsValid(k) then
						self.rotgb_TargetedBalloons[k] = nil
					end
				end
				
				for i, bln in ipairs(tableOfBalloons) do
					if self:ValidTargetIgnoreRange(bln) and not self.rotgb_TargetedBalloons[bln] then
						self.rotgb_TargetedBalloons[bln] = true
						success = true
						self:TossPotion(tableOfBalloons[1], potionNumber) break
					end
				end
				
				if not success then
					self.rotgb_TargetedBalloons = {}
					self:TossPotion(tableOfBalloons[1], potionNumber)
				end
			elseif potionNumber == 3 or potionNumber == 4 or potionNumber == 10 then
				self:TossPotion(self, potionNumber)
			else
				-- calculate random target
				local backupTargets = {self}
				local targets = {}
				
				for i, v in ipairs(ents.FindInSphere(self:GetShootPos(), self.DetectionRadius)) do
					if v.Base == "gballoon_tower_base" and v ~= self
					and (potionNumber ~= 6 or alwaysProjectileTargets[v:GetClass()] or v.rotgb_Tower18_IsLaserTower) then
						table.insert(backupTargets, v)
						
						local shouldInsert = false
						
						if potionNumber == 0 and not v:GetDelayedActions("ROTGB_TOWER_18_ENERGY") then
							shouldInsert = true
						elseif potionNumber == 1 and not v:GetDelayedActions("ROTGB_TOWER_18_HERMES") then
							shouldInsert = true
						elseif potionNumber == 2 and not v:GetDelayedActions("ROTGB_TOWER_18_BERSERK") then
							shouldInsert = true
						elseif potionNumber == 5 and not v:GetDelayedActions("ROTGB_TOWER_18_MUNDANE") then
							shouldInsert = true
						elseif potionNumber == 6 and not v:GetDelayedActions("ROTGB_TOWER_18_PROJECTILE") then
							shouldInsert = true
						elseif potionNumber == 7 and not v:GetDelayedActions("ROTGB_TOWER_18_HASTE") then
							shouldInsert = true
						end
						
						if shouldInsert then
							table.insert(targets, v)
						end
					end
				end
				
				if table.IsEmpty(targets) then
					targets = backupTargets
				end
				
				self:TossPotion(targets[math.random(#targets)], potionNumber)
			end
		elseif self:GetSpawnerActive() then
			-- toss a potion randomly
			local randomYaw = Lerp(math.random(), -math.pi, math.pi)
			local randomOffset = Vector(math.sin(randomYaw),  math.cos(randomYaw), 0)
			
			-- be smart about the random radius
			local randomRadius = math.sqrt(math.random()) * self.DetectionRadius
			randomOffset:Mul(randomRadius)
			randomOffset:Add(self:GetShootPos())
			
			self:TossPotion(randomOffset, 9)
		end
	end
end

local function OnCollision(potion, data)
	if IsValid(potion.rotgb_Tower) then
		potion.rotgb_Tower:OnPotionCollision(potion, data)
	end
	
	potion:EmitSound(string.format("physics/glass/glass_impact_bullet%u.wav",math.random(1,4)), 60, math.Remap(math.random(), 0, 1, 80, 120), 1, CHAN_WEAPON)
	SafeRemoveEntity(potion)
end

function ENT:TossPotion(target, typ)
	local spawnPos = self:GetShootPos()
	local potion = ents.Create("prop_physics")
	potion:SetPos(spawnPos)
	potion:AddCallback("PhysicsCollide", OnCollision)
	potion:SetModel("models/props_junk/glassjug01.mdl")
	potion:SetMaterial("models/debug/debugwhite")
	potion:SetColor(potionColors[typ])
	potion:Spawn()
	potion:SetMaxHealth(9999)
	potion:SetHealth(9999)
	potion:SetModelScale(self.ProjectileSize)
	potion:Activate()
	potion:SetCollisionGroup(COLLISION_GROUP_WORLD)
	potion.rotgb_Tower = self
	potion.rotgb_Target = isentity(target) and target
	potion.rotgb_Type = typ
	
	local physobj = potion:GetPhysicsObject()
	if IsValid(physobj) then
		physobj:AddAngleVelocity(VectorRand(-1000, 1000))
		physobj:EnableDrag(false)
		physobj:SetVelocity(self:GetThrowVelocity(spawnPos, target, 1))
	end
end

function ENT:GetThrowVelocity(origin, targetEntity, airTime)
	local targetPosition = targetEntity
	
	if isentity(targetEntity) then
		targetPosition = targetEntity:GetPos()
		
		if targetEntity:IsNextBot() then
			targetPosition = targetPosition + targetEntity.loco:GetVelocity() * airTime
		else
			-- FIXME: Shouldn't this be targetEntity:GetPhysicsObject():GetVelocity()?
			targetPosition = targetPosition + targetEntity:GetVelocity() * airTime
		end
	end
	
	-- remember! d = vt + at^2/2
	-- so v = (d - at^2/2)/t = d/t - at/2
	
	local dOverT = targetPosition
	dOverT:Sub(origin)
	dOverT:Div(airTime)
	
	local atOver2 = physenv.GetGravity() * (airTime / 2)
	dOverT:Sub(atOver2) -- here, dOverT is actually v
	
	return dOverT
end

function ENT:OnPotionCollision(potion, data)
	local potionType = potion.rotgb_Type
	if potionType == 0 then
		local accumulatedBalloons = {}
		local success = false
		
		for i, v in ipairs(ents.FindInSphere(potion:WorldSpaceCenter(), potion:GetModelScale() * 128)) do
			if self:ValidTargetIgnoreRange(v) then
				success = true
				
				if bit.band(self.rotgb_HarmingPotionEffects, 1) ~= 0 then
					self:DealDamageProxy(v, self.AttackDamage, DMG_DIRECT)
				end
				if bit.band(self.rotgb_HarmingPotionEffects, 2) ~= 0 then
					self:AccumulateBalloons(v, accumulatedBalloons)
				end
				if bit.band(self.rotgb_HarmingPotionEffects, 8) ~= 0 then
					if not v:GetBalloonProperty("BalloonPurple") then
						if not v:GetBalloonProperty("BalloonBlimp") then
							v:MultiplyValue("ROTGB_TOWER_18", self, 1, 1000)
						elseif self.rotgb_MidasDiamondSingularity > 0 then
							v.rotgb_Tower18_Diamond = self
							if self.rotgb_MidasDiamondSingularity > 1 and v:GetRgBE() <= v:GetRgBEByType("gballoon_blimp_red") then
								self:DealDamageProxy(v, 2147483647, DMG_GENERIC)
								
								if v:GetBalloonProperty("BalloonType") ~= "gballoon_red" then
									local bln = ents.Create("gballoon_base")
									if IsValid(bln) then
										bln:SetPos(v:GetPos())
										local keyValues = list.GetForEdit("NPC").gballoon_red.KeyValues
										for k,v2 in pairs(keyValues) do
											bln:SetKeyValue(k,v2)
										end
										bln:Spawn()
										bln:Activate()
										bln:SetTarget(v:GetTarget())
									end
								end
							end
						end
					end
					
					if self.rotgb_SingularityPotions and v:GetBalloonProperty("BalloonFast") then
						local data = EffectData()
						data:SetEntity(self)
						data:SetDamageType(v:EntIndex())
						data:SetMagnitude(0)
						data:SetStart(vector_black)
						util.Effect("rotgb_sticky", data, true, true)
						
						self.rotgb_Singularities[v] = true
					end
				end
				if bit.band(self.rotgb_HarmingPotionEffects, 16) ~= 0 then
					local stunDuration = self.rotgb_HarmingPotionSlow and v:GetBalloonProperty("BalloonFast") and 2 or 0.5
					
					v:Stun(stunDuration)
					v:InflictRotgBStatusEffect("ROTGB_TOWER_18_STUNNED", stunDuration)
					
					if self.rotgb_HarmingPotionSlow then
						v:Slowdown("ROTGB_TOWER_18_SLOWED", 0.5, 2)
					end
				end
			end
		end
		
		if bit.band(self.rotgb_HarmingPotionEffects, 2) ~= 0 then
			for k,v in pairs(accumulatedBalloons) do
				self:DealDamageProxy(k, self.AttackDamage, DMG_SHOCK)
			end
		end
		
		if bit.band(self.rotgb_HarmingPotionEffects, 4) ~= 0 then
			local target = potion.rotgb_Target
			if (IsValid(target) and target.Base == "gballoon_tower_base") then
				local fireRate = self.rotgb_EnergyPotionFireRate
				target:AddDelayedActions(self, "ROTGB_TOWER_18_ENERGY", 0, function(tower)
					tower.FireRate = tower.FireRate * fireRate
					tower.rotgb_Tower18_CeramicPlusDamage = (tower.rotgb_Tower18_CeramicPlusDamage or 0) + 20
					tower.rotgb_Tower18_CanPopGray = bit.bor(tower.rotgb_Tower18_CanPopGray or 0, 2)
				end, self.rotgb_EnergyPotionDuration, function(tower)
					tower.FireRate = tower.FireRate / fireRate
					tower.rotgb_Tower18_CeramicPlusDamage = tower.rotgb_Tower18_CeramicPlusDamage - 20
					tower.rotgb_Tower18_CanPopGray = bit.band(tower.rotgb_Tower18_CanPopGray, bit.bnot(2))
				end)
			end
		end
		
		if bit.band(self.rotgb_HarmingPotionEffects, 8) ~= 0 and self.rotgb_MidasDiamondSingularity > 0 and not success then
			local pos = potion:WorldSpaceCenter()
			local data = EffectData()
			data:SetEntity(self)
			data:SetOrigin(pos)
			data:SetScale(2)
			data:SetMagnitude(0)
			data:SetStart(vector_yellow)
			data:SetDamageType(0)
			util.Effect("rotgb_cloud", data, true, true)
			
			table.insert(self.rotgb_MidasCloudPositions, pos)
		end
	elseif potionType == 3 then
		local targets = ents.FindByClass("gballoon_target")
		self:AddDelayedActions(self, "ROTGB_TOWER_18_LIFEFORCE", 0, function(tower)
			for i,v in ipairs(targets) do
				v.rotgb_Tower18_OldMaxHealth = v:GetMaxHealth()
				v:SetMaxHealth(v.rotgb_Tower18_OldMaxHealth * 1.2)
			end
		end, 480, function(tower)
			for i,v in ipairs(targets) do
				if IsValid(v) then
					v:SetMaxHealth(v.rotgb_Tower18_OldMaxHealth)
				end
			end
		end)
		
		if self.rotgb_LifeforcePotionResetCooldowns then
			for i,v in ipairs(ents.FindInSphere(self:GetShootPos(), self.DetectionRadius)) do
				if v.Base == "gballoon_tower_base" then
					if v:GetAbilityCharge() < 1 then
						v:SetAbilityCharge(1)
					end
					v.rotgb_Tower18_BoostedAbilityDamage = self
				end
			end
		end
	elseif potionType == 4 then
		for i,v in ipairs(ents.FindByClass("gballoon_target")) do
			if v:Health() < v:GetMaxHealth() then
				v:SetHealth(math.min(v:Health() + 1, v:GetMaxHealth()))
			end
		end
	elseif potionType == 9 then
		local pos = potion:WorldSpaceCenter()
		self:AddDelayedActions(self, nil, 0, function(tower)
			local data = EffectData()
			data:SetEntity(tower)
			data:SetOrigin(pos)
			data:SetScale(2)
			data:SetMagnitude(10)
			data:SetStart(vector_green)
			data:SetDamageType(0)
			util.Effect("rotgb_cloud", data, true, true)
			
			table.insert(tower.rotgb_AcidCloudPositions, pos)
		end, 10, function(tower)
			table.remove(tower.rotgb_AcidCloudPositions, 1)
		end)
	elseif potionType == 10 then
		for i,v in ipairs(ents.GetAll()) do
			if v.Base == "gballoon_tower_base" then
				v:AddDelayedActions(self, "ROTGB_TOWER_18_PANIC_2", 0, function(tower)
					tower.AttackDamage = tower.AttackDamage + 20
					tower.FireRate = tower.FireRate * 2
				end, 10, function(tower)
					tower.AttackDamage = tower.AttackDamage - 20
					tower.FireRate = tower.FireRate / 2
				end)
			end
		end
	else
		-- we already know our target, it would be more efficient to just not consider that the target has moved
		-- it's a tower, would so much movement even be possible?
		local target = potion.rotgb_Target
		if IsValid(target) then
			if potionType == 1 then
				target:AddDelayedActions(self, "ROTGB_TOWER_18_HERMES", 0, function(tower)
					tower.FireRate = tower.FireRate * 2
					tower.rotgb_Tower18_CanPopGray = bit.bor(tower.rotgb_Tower18_CanPopGray or 0, 1)
				end, 10, function(tower)
					tower.FireRate = tower.FireRate / 2
					tower.rotgb_Tower18_CanPopGray = bit.band(tower.rotgb_Tower18_CanPopGray, bit.bnot(1))
				end)
			elseif potionType == 2 then
				local extraArmoredBlimpDamage = self.rotgb_BerserkPotionArmoredBlimpDamage
				local multipurposeEngineDamageMul = self.rotgb_BerserkPotionMultipurposeEngineDamageMul
				local morePECDamage = self.rotgb_EnergyBerserkPotionMorePECDamage
				
				target:AddDelayedActions(self, "ROTGB_TOWER_18_BERSERK", 0, function(tower)
					if tower.AbilityCooldown ~= 0 then
						tower:SetAbilityCharge(math.min(1, tower:GetAbilityCharge()-self.rotgb_BerserkPotionCooldowns/tower.AbilityCooldown))
					end
					tower.FireRate = tower.FireRate * 2
					tower.rotgb_Tower18_Damage = (tower.rotgb_Tower18_Damage or 0) + 20
					tower.rotgb_Tower18_ArmoredBlimpDamage = (tower.rotgb_Tower18_ArmoredBlimpDamage or 0) + extraArmoredBlimpDamage
					tower.rotgb_Tower18_CanPopGray = bit.bor(tower.rotgb_Tower18_CanPopGray or 0, 4)
					if tower:GetClass() == "gballoon_tower_06" then
						tower.rotgb_AttackDamageMul = tower.rotgb_AttackDamageMul * multipurposeEngineDamageMul
					end
					if morePECDamage then
						tower.rotgb_Tower18_PurpleDamage = (tower.rotgb_Tower18_PurpleDamage or 0) + 150
						tower.rotgb_Tower18_ArmoredDamage = (tower.rotgb_Tower18_ArmoredDamage or 0) + 150
						tower.rotgb_Tower18_CeramicPlusDamage = (tower.rotgb_Tower18_CeramicPlusDamage or 0) + 150
					end
				end, self.rotgb_BerserkPotionDuration, function(tower)
					tower.FireRate = tower.FireRate / 2
					tower.rotgb_Tower18_Damage = tower.rotgb_Tower18_Damage - 20
					tower.rotgb_Tower18_ArmoredBlimpDamage = tower.rotgb_Tower18_ArmoredBlimpDamage - extraArmoredBlimpDamage
					tower.rotgb_Tower18_CanPopGray = bit.band(tower.rotgb_Tower18_CanPopGray, bit.bnot(4))
					if tower:GetClass() == "gballoon_tower_06" then
						tower.rotgb_AttackDamageMul = tower.rotgb_AttackDamageMul / multipurposeEngineDamageMul
					end
					if morePECDamage then
						tower.rotgb_Tower18_PurpleDamage = tower.rotgb_Tower18_PurpleDamage - 150
						tower.rotgb_Tower18_ArmoredDamage = tower.rotgb_Tower18_ArmoredDamage - 150
						tower.rotgb_Tower18_CeramicPlusDamage = tower.rotgb_Tower18_CeramicPlusDamage - 150
					end
				end)
			elseif potionType == 5 then
				target:AddDelayedActions(self, "ROTGB_TOWER_18_MUNDANE", 0, function(tower)
					tower.rotgb_Tower18_CanPopPurple = true
					tower.rotgb_Tower18_SetOnFire = true
				end, 30, function(tower)
					tower.rotgb_Tower18_CanPopPurple = nil
					tower.rotgb_Tower18_SetOnFire = nil
				end)
			elseif potionType == 6 then
				target:AddDelayedActions(self, "ROTGB_TOWER_18_PROJECTILE", 0, function(tower)
					tower.ProjectileSize = tower.ProjectileSize * 2
					tower.FireRate = tower.FireRate / 1.5
					tower.rotgb_Tower18_DealDoubleDamage = self
				end, 30, function(tower)
					tower.ProjectileSize = tower.ProjectileSize / 2
					tower.FireRate = tower.FireRate * 1.5
					tower.rotgb_Tower18_DealDoubleDamage = nil
				end)
			elseif potionType == 7 then
				local bursts = self.rotgb_HastePotionTaps
				local extraAttack = self.rotgb_HastePotionAttack
				local extraFireRate = self.rotgb_HastePotionFireRate
				local doNotBurst = (target.MaxFireRate or math.huge)*3 < 200
				
				target:AddDelayedActions(self, "ROTGB_TOWER_18_HASTE", 0, function(tower)
					tower.AttackDamage = tower.AttackDamage + extraAttack
					tower.FireRate = tower.FireRate * extraFireRate
					
					if doNotBurst then
						tower.FireRate = tower.FireRate * bursts
					else
						if not tower.rotgb_Tower18_OldFireFunction then
							tower.rotgb_Tower18_OldFireFunction = tower.FireFunction
						end
						
						function tower:FireFunction(...)
							for i=1, bursts do
								local ret = self:rotgb_Tower18_OldFireFunction(...)
								if ret then return true end
							end
						end
					end
				end, 30, function(tower)
					tower.AttackDamage = tower.AttackDamage - extraAttack
					tower.FireRate = tower.FireRate / extraFireRate
					
					if doNotBurst then
						tower.FireRate = tower.FireRate / bursts
					elseif tower.rotgb_Tower18_OldFireFunction then
						tower.FireFunction = tower.rotgb_Tower18_OldFireFunction
					end
				end)
			end
		end
	end
end

function ENT:AccumulateBalloons(bln, accumulatedBalloons)
	accumulatedBalloons[bln] = true
	
	for i, v in ipairs(ents.FindInSphere(bln:WorldSpaceCenter(), 128)) do
		if self:ValidTargetIgnoreRange(v) and not accumulatedBalloons[v] then
			self:AccumulateBalloons(v, accumulatedBalloons)
		end
	end 
end

function ENT:ChooseSomethings()
	if IsValid(self.rotgb_ReturningTarget) then
		local target = {self.rotgb_ReturningTarget}
		return target
	end
	
	local oldLos = self.UseLOS
	local oldInfiniteRange2 = self.InfiniteRange2
	self.UseLOS = false
	self.InfiniteRange2 = true
	self:ExpensiveThink(true)
	self.UseLOS = oldLos
	self.InfiniteRange2 = oldInfiniteRange2
	return self.gBalloons
end

function ENT:TriggerAbility()
	local success = false
	
	if bit.band(self.rotgb_Abilities, 1) ~= 0 then
		local strongestRgBE = 0
		local strongestBalloon = NULL
		
		for i, v in ipairs(ROTGB_GetBalloons()) do
			local rgbe = v:GetRgBE()
			
			if strongestRgBE < rgbe then
				strongestRgBE = rgbe
				strongestBalloon = v
			end
		end
		
		if IsValid(strongestBalloon) then
			local data = EffectData()
			data:SetOrigin(strongestBalloon:WorldSpaceCenter())
			data:SetMagnitude(3)
			data:SetScale(3)
			data:SetRadius(3)
			util.Effect("StunstickImpact", data, true, true)
			
			self:DealDamageProxy(strongestBalloon, 2e6, DMG_SHOCK)
			success = true
		end
		
		if self.rotgb_Electron then
			success = true
			local calledTower = self.rotgb_ElectronCloudTarget
			
			if IsValid(calledTower) then
				calledTower.rotgb_ElectronCloudStacks = calledTower.rotgb_ElectronCloudStacks + 1
			else
				self.rotgb_ElectronCloudStacks = 1
				for i, v in ipairs(ents.FindByClass("gballoon_tower_18")) do
					v.rotgb_ElectronCloudTarget = self
					v:DoAbility()
					v.rotgb_ElectronCloudTarget = nil
				end
				
				local stacks = self.rotgb_ElectronCloudStacks
				for i = 2, 6, 2 do
					self:AddDelayedActions(self, nil, i, function(tower)
						local strongestRgBE = 0
						local strongestBalloon = NULL
						
						for i, v in ipairs(ROTGB_GetBalloons()) do
							local rgbe = v:GetRgBE()
							
							if strongestRgBE < rgbe then
								strongestRgBE = rgbe
								strongestBalloon = v
							end
							
							if v:GetBalloonProperty("BalloonFast") then
								v:Slowdown("ROTGB_TOWER_18_ELECTRON", 1.5, 2)
							end
						end
						
						if IsValid(strongestBalloon) then
							local damage = 20e6 * stacks
							if strongestBalloon:GetBalloonProperty("BalloonFast") then
								damage = damage / 2
							end
							
							local data = EffectData()
							data:SetOrigin(strongestBalloon:WorldSpaceCenter())
							data:SetMagnitude(3)
							data:SetScale(3)
							data:SetRadius(3)
							util.Effect("StunstickImpact", data, true, true)
							
							tower:DealDamageProxy(strongestBalloon, damage, DMG_SHOCK)
							
							local pos = strongestBalloon:WorldSpaceCenter()
							self:AddDelayedActions(self, nil, 0, function(tower)
								local data = EffectData()
								data:SetEntity(tower)
								data:SetOrigin(pos)
								data:SetScale(2)
								data:SetMagnitude(2)
								data:SetStart(vector_white)
								data:SetDamageType(0)
								util.Effect("rotgb_cloud", data, true, true)
								
								table.insert(tower.rotgb_AfterShockPositions, pos)
							end, 2, function(tower)
								table.remove(tower.rotgb_AfterShockPositions, 1)
							end)
						end
					end)
				end
			end
		end
	end
	
	if bit.band(self.rotgb_Abilities, 2) ~= 0 then
		local laserAbilityDamage = self.rotgb_LaserAbilityDamage
		
		for i,v in ipairs(ents.FindInSphere(self:GetShootPos(), self.DetectionRadius)) do
			if (v:GetClass() == "gballoon_tower_18" and not v:GetDelayedActions("ROTGB_TOWER_18_LASER")) then
				success = true
				local spinup = self.rotgb_LaserAbilitySpinup
				
				v:AddDelayedActions(self, "ROTGB_TOWER_18_LASER", 0, function(tower)
					tower.rotgb_LaserDamage = tower.rotgb_LaserDamage + laserAbilityDamage
					tower.rotgb_PotionDelay = tower.rotgb_PotionDelay * 10
					tower.FireRate = tower.FireRate * 10
				end, 7.5, function(tower)
					if spinup then
						tower.rotgb_LaserDamage = tower.rotgb_LaserDamage + laserAbilityDamage * 4
						tower.rotgb_LaserSpinup = true
					end
				end, 15, function(tower)
					local mul = spinup and 5 or 1
					tower.rotgb_LaserDamage = tower.rotgb_LaserDamage - laserAbilityDamage * mul
					tower.rotgb_LaserSpinup = false
					tower.rotgb_PotionDelay = tower.rotgb_PotionDelay / 10
					tower.FireRate = tower.FireRate / 10
				end)
			end
		end
	end
	
	if bit.band(self.rotgb_Abilities, 4) ~= 0 and not self:GetDelayedActions("ROTGB_TOWER_18_SINGULARITY") then
		success = true
		self:AddDelayedActions(self, "ROTGB_TOWER_18_SINGULARITY", 0, function(tower)
			tower.rotgb_SingularityPotions = true
		end, 15, function(tower)
			tower.rotgb_SingularityPotions = false
		end)
	end
	
	if bit.band(self.rotgb_Abilities, 8) ~= 0 then
		local target = self:ChooseSomethings()[1]
		if IsValid(target) then
			success = true
			local pos = target:WorldSpaceCenter()
			self:AddDelayedActions(self, nil, 0, function(tower)
				local data = EffectData()
				data:SetEntity(tower)
				data:SetOrigin(pos)
				data:SetScale(2)
				data:SetMagnitude(self.rotgb_ReturnPortalDuration)
				data:SetStart(vector_magenta)
				data:SetDamageType(0)
				util.Effect("rotgb_cloud", data, true, true)
				
				table.insert(tower.rotgb_ReturnPortals, pos)
			end, self.rotgb_ReturnPortalDuration, function(tower)
				table.remove(tower.rotgb_ReturnPortals, 1)
			end)
			
			if self.rotgb_ReturnPortalsMagicAttack then
				for i,v in ipairs(ents.GetAll()) do
					if v.Base == "gballoon_tower_base" then
						v:AddDelayedActions(self, "ROTGB_TOWER_18_RETURNING", 0, function(tower)
							tower.rotgb_Tower18_ExtraMagicDamage = self
						end, self.rotgb_ReturnPortalDuration, function(tower)
							tower.rotgb_Tower18_ExtraMagicDamage = nil
						end)
					end
				end
			end
		end
	end
	
	if bit.band(self.rotgb_Abilities, 16) ~= 0 then
		local targets = self:ChooseSomethings()
		
		if IsValid(targets[1]) then
			success = true
			local targetIndex = 1
			
			for i=1, self.rotgb_Barricades do
				if not IsValid(targets[targetIndex]) then
					targetIndex = 1
				end
				local target = targets[targetIndex]
				
				local barricade = ents.Create("gballoon_tower_18_minion")
				barricade:SetTower(self)
				barricade:SetPos(target:GetPos() + spawnerOffset)
				barricade:Spawn()
				
				targetIndex = targetIndex + 1
			end
		end
	end
	
	if bit.band(self.rotgb_Abilities, 32) ~= 0 then
		for i,v in ipairs(ents.FindInSphere(self:GetShootPos(), self.DetectionRadius)) do
			if (v.Base == "gballoon_tower_base" and not v:GetDelayedActions("ROTGB_TOWER_18_SUPERCLOCK")) then
				success = true
				if self.rotgb_Hyperclock then
					v.AbilityCooldown = (v.AbilityCooldown or 0) * 0.9
				end
				
				v:AddDelayedActions(self, "ROTGB_TOWER_18_SUPERCLOCK", 0, function(tower)
					tower.FireRate = tower.FireRate * 5
					tower.rotgb_Tower18_BlimpDamage = (tower.rotgb_Tower18_BlimpDamage or 0) + 50
				end, 15, function(tower)
					tower.FireRate = tower.FireRate / 5
					tower.rotgb_Tower18_BlimpDamage = tower.rotgb_Tower18_BlimpDamage - 50
				end)
			end
		end
	end
	
	self.rotgb_ReturningTarget = nil
	
	if not success then return true end
end

hook.Add("gBalloonSpawnerWaveStarted", "ROTGB_TOWER_18", function(spawner,wave)
	for i,v in ipairs(ents.FindByClass("gballoon_tower_18")) do
		if not IsValid(v.rotgb_Spawner) then
			v.rotgb_Spawner = spawner
		end
		
		if v.rotgb_Spawner == spawner then
			local cash = 0
			
			for j,v2 in ipairs(ents.FindInSphere(v:GetShootPos(), v.DetectionRadius)) do
				if v2:GetClass() == "gballoon_tower_18" then
					cash = cash + 10e3
				end
			end
			
			v:AddCash(cash, v:GetTowerOwner())
		end
	end
end)

local grayResistances = bit.bor(DMG_BULLET, DMG_SLASH, DMG_BUCKSHOT)
local purpleResistances = bit.bor(DMG_BURN,DMG_SHOCK,DMG_ENERGYBEAM,DMG_SLOWBURN,DMG_REMOVENORAGDOLL,DMG_PLASMA,DMG_DIRECT)
hook.Add("RotgBTowerDealDamage", "ROTGB_TOWER_18", function(vic, dmginfo)
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	
	if (inflictor.rotgb_Tower18_CanPopGray or 0) ~= 0 then
		dmginfo:SetDamageType(bit.band(dmginfo:GetDamageType(), bit.bnot(grayResistances)))
	end
	
	if inflictor.rotgb_Tower18_CanPopPurple then
		dmginfo:SetDamageType(bit.band(dmginfo:GetDamageType(), bit.bnot(purpleResistances)))
	end
	
	if vic:GetClass() == "gballoon_base" then
		if inflictor.rotgb_Tower18_SetOnFire then
			vic:RotgB_Ignite(10, attacker, inflictor, 3)
		end
		if inflictor.rotgb_Tower18_CeramicPlusDamage and vic:GetRgBE() >= vic:GetRgBEByType("gballoon_ceramic") - 10 then
			dmginfo:AddDamage(inflictor.rotgb_Tower18_CeramicPlusDamage)
		end
		
		if vic:GetBalloonProperty("BalloonArmor") > 0 then
			if inflictor.rotgb_Tower18_ArmoredDamage then
				dmginfo:AddDamage(inflictor.rotgb_Tower18_ArmoredDamage)
			end
			
			if inflictor.rotgb_Tower18_ArmoredBlimpDamage and vic:GetBalloonProperty("BalloonBlimp") then
				dmginfo:AddDamage(inflictor.rotgb_Tower18_ArmoredBlimpDamage)
			end
		end
			
		if inflictor.rotgb_Tower18_BlimpDamage and vic:GetBalloonProperty("BalloonBlimp") then
			dmginfo:AddDamage(inflictor.rotgb_Tower18_BlimpDamage)
		end
		
		if inflictor.rotgb_Tower18_PurpleDamage and vic:GetBalloonProperty("BalloonPurple") then
			dmginfo:AddDamage(inflictor.rotgb_Tower18_PurpleDamage)
		end
		
		if vic:HasRotgBStatusEffect("ROTGB_TOWER_18_STUNNED")
		and (inflictor:GetClass() == "gballoon_tower_05"
		or inflictor:GetClass() == "gballoon_tower_09") then
			dmginfo:AddDamage(20)
		end
	end
	
	if IsValid(inflictor.rotgb_Tower18_ExtraMagicDamage) and bit.band(dmginfo:GetDamageType(), purpleResistances) ~= 0 then
		dmginfo:AddDamage(100)
	end
	
	if IsValid(inflictor.rotgb_Tower18_BoostedAbilityDamage) and inflictor:GetAbilityFraction() > 0 then
		dmginfo:ScaleDamage(2)
	end
	
	if IsValid(inflictor.rotgb_Tower18_DealDoubleDamage) then
		dmginfo:ScaleDamage(2)
	end
end)

hook.Add("RotgBTowerFireLaser", "ROTGB_TOWER_18", function(tower, bln, data)
	if IsValid(tower.rotgb_Tower18_DealDoubleDamage) then
		data.width = data.width * 2
	end
end)

hook.Add("gBalloonPrePop", "ROTGB_TOWER_18", function(vic, damage, target, dmgbits)
	if IsValid(vic.rotgb_Tower18_Unstable) then
		local causedTower = vic.rotgb_Tower18_Unstable
		local data = EffectData()
		data:SetOrigin(vic:WorldSpaceCenter())
		data:SetMagnitude(1)
		data:SetScale(1)
		data:SetFlags(0)
		util.Effect("Explosion", data, true, true)
		
		for i,v in ipairs(ents.FindInSphere(vic:WorldSpaceCenter(), 128)) do
			if causedTower:ValidTargetIgnoreRange(v) and v ~= self then
				causedTower:DealDamageProxy(v, 200, DMG_BLAST)
			end
		end
	end
	
	if (vic.rotgb_ValueMultipliers and vic.rotgb_ValueMultipliers.ROTGB_TOWER_18) and math.random() < 0.1 then
		local timeLeft = vic.rotgb_ValueMultipliers.ROTGB_TOWER_18[1] - vic:CurTime()
		local tower = vic.rotgb_ValueMultipliers.ROTGB_TOWER_18[3]
		
		if IsValid(tower) then
			local cashToGive = math.min(300/(1000-timeLeft), 300)
			tower:AddCash(cashToGive, tower:GetTowerOwner())
		end
	end
	
	if IsValid(vic.rotgb_Tower18_Diamond) then
		local causedTower = vic.rotgb_Tower18_Diamond
		causedTower:AddCash(5000, causedTower:GetTowerOwner())
	end
	
	if IsValid(vic.rotgb_Tower18_SingularityMarked) then
		local causedTower = vic.rotgb_Tower18_SingularityMarked
		causedTower:AddCash(1e6, causedTower:GetTowerOwner())
	end
end)

hook.Add("RotgBBalloonPostDealDamage", "ROTGB_TOWER_18", function(data)
	local victimHealth = data.victim:Health()
	
	for i,v in ipairs(ents.FindByClass("gballoon_tower_18")) do
		if v.rotgb_PanicPotions then
			v.rotgb_NextPotionIsPanic = true
			
			v:AddDelayedActions(v, "ROTGB_TOWER_18_PANIC", 0, function(tower)
				tower.rotgb_HealingPotionIsPanic = true
			end, 10, function(tower)
				tower.rotgb_HealingPotionIsPanic = nil
			end)
		end
		
		if victimHealth < 50 and v.rotgb_SelfSacrifice then
			for j,v2 in ipairs(ents.GetAll()) do
				if v2:GetClass() == "gballoon_base" then
					v:DealDamageProxy(v2, 10e6, DMG_GENERIC)
				elseif v2:GetClass() == "gballoon_target" then
					v:SetHealth(v:Health() + 500)
				elseif v2.Base == "gballoon_tower_base" then
					v2:Stun(3)
				end
			end
			
			v.SellAmount = 0
			v:Remove()
		end
	end
	
	if IsValid(data.attacker.rotgb_Tower18_SingularityMarked) then
		data.damage = data.damage * 3
	end
end)