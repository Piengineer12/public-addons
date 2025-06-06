AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Hoverball Factory"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.tower.gballoon_tower_16.purpose"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/maxofs2d/hover_plate.mdl")
ENT.FireRate = 10
ENT.MaxFireRate = 200/3
ENT.Cost = 750
ENT.AbilityCooldown = 60
ENT.LOSOffset = Vector(0,0,5)
ENT.AttackDamage = 0
ENT.ProjectileSize = 1
ENT.DetectionRadius = 0
ENT.InfiniteRange = true
ENT.SeeCamo = true
ENT.FireWhenNoEnemies = true
ENT.rotgb_HoverballWorth = 20
ENT.rotgb_HoverballLife = 20
ENT.rotgb_HoverballDelay = 0.15
ENT.rotgb_BankFactor = 0
ENT.rotgb_BankMax = 1000
ENT.rotgb_HoverballPostCash = 0
ENT.rotgb_Buff = 0
ENT.rotgb_HoverballSkin = 0
ENT.rotgb_HoverballRange = 64
ENT.rotgb_HoverballModel = "models/maxofs2d/hover_classic.mdl"
ENT.UpgradeReference = {
	{
		Names = {"Fast Generation", "Advanced Hoverballs", "Faster Generation", "Elite Hoverballs", "Ultimate Hoverballs", "The Big Bill Balls", "Dark Matter Hoverballs"},
		Descs = {
			"Slightly increases hoverball generation speed.",
			"Slightly increases hoverball cash gain.",
			"Considerably increases hoverball generation speed.",
			"Slightly decreases hoverball generation speed, but colossally increases hoverball cash gain.",
			"Considerably decreases hoverball generation speed to further increase hoverball cash gain.",
			"Yes.",
			"Each hoverball takes a few rounds to be created. This tower creates Dark Matter Hoverballs that give $1.5 million each, with a 10% chance for 10 times the amount."
		},
		Prices = {350,500,1500,7000,40000,250000,5e6},
		Funcs = {
			function(self)
				self.rotgb_HoverballDelay = self.rotgb_HoverballDelay / 1.5
			end,
			function(self)
				self.rotgb_HoverballWorth = self.rotgb_HoverballWorth * 1.5
				self.rotgb_HoverballModel = "models/dav0r/hoverball.mdl"
			end,
			function(self)
				self.rotgb_HoverballDelay = self.rotgb_HoverballDelay / 2
			end,
			function(self)
				self.rotgb_HoverballDelay = self.rotgb_HoverballDelay * 1.5
				self.rotgb_HoverballWorth = self.rotgb_HoverballWorth * 5
				self.rotgb_HoverballModel = "models/maxofs2d/hover_rings.mdl"
			end,
			function(self)
				self.rotgb_HoverballDelay = self.rotgb_HoverballDelay * 2
				self.rotgb_HoverballWorth = self.rotgb_HoverballWorth * 10
				self.rotgb_HoverballModel = "models/maxofs2d/hover_basic.mdl"
			end,
			function(self)
				self.rotgb_HoverballDelay = self.rotgb_HoverballDelay * 3
				self.rotgb_HoverballWorth = self.rotgb_HoverballWorth * 20
				self.rotgb_HoverballSkin = 3
				self.ProjectileSize = self.ProjectileSize * 3
			end,
			function(self)
				self.rotgb_HoverballDelay = self.rotgb_HoverballDelay * 5
				self.rotgb_HoverballWorth = self.rotgb_HoverballWorth * 50
				self.rotgb_HoverballSkin = 0
				self.rotgb_HoverballModel = "models/maxofs2d/hover_rings.mdl"
				self.rotgb_10Chance = true
			end
		}
	},
	{
		Names = {"Long Lasting Hoverballs", "Auto-Sell", "Compound Interest", "Garry's Bank", "Grand Metropolis", "Prop Country", "INFINITE GROWTH!"},
		Descs = {
			"Hoverballs last for 200% longer.",
			"Hoverballs are now automatically removed and all health generated by this tower is doubled.",
			"For each player, this tower generates additional cash equal to 0.5% of their current cash per second, up to $1,000 per second. Only works while gBalloons are present.",
			"This tower now generates 1% interest, up to $5,000 per second.",
			"This tower now generates interest from current cash AND placed towers, up to $25,000 per second.",
			"This tower now generates interest up to $250,000 per second!",
			"This tower no longer has a maximum interest rate! Once every 60 seconds, shooting at this tower doubles everyone's current cash!"
		},
		Prices = {450,1300,10000,60000,650000,7e6,1e9},
		Funcs = {
			function(self)
				self.rotgb_HoverballLife = self.rotgb_HoverballLife * 3
			end,
			function(self)
				self.rotgb_AutoHoverball = true
			end,
			function(self)
				self.rotgb_BankFactor = 0.005
			end,
			function(self)
				self.rotgb_BankFactor = 0.01
				self.rotgb_BankMax = self.rotgb_BankMax * 5
			end,
			function(self)
				self.rotgb_BankMax = self.rotgb_BankMax * 5
				self.rotgb_BankBonus = true
			end,
			function(self)
				self.rotgb_BankMax = self.rotgb_BankMax * 10
			end,
			function(self)
				self.rotgb_BankMax = math.huge
				self.HasAbility = true
			end
		},
		FusionRequirements = {[7] = true}
	},
	{
		Names = {"A Little Extra", "Just Pocket It", "Fuzzy Income", "King of Hearts", "Microbot Research", "Nanomachines"},
		Descs = {
			"At the start of each round, gain 10% of a round's worth of hoverball cash.",
			"This tower no longer generates income. At the start of each round, gain 110% of the hoverball income and 11 seconds of non-hoverball income that would have been generated.",
			"Each round, hoverball cash production is altered to between 0% and 400%.",
			"At the end of each round, all gBalloon Targets' health is increased by 20% of their maximum health, rounded down. This upgrade can overheal targets.",
			"At the end of each round, the hoverball income of all Hoverball Factory towers are multiplied by 1.2!",
			"At the end of each round, all gBalloon Targets' health is increased by 20% of their health, rounded down. This upgrade can overheal targets."
		},
		Prices = {450,1000,2000,5000,75000},
		Funcs = {
			function(self)
				self.rotgb_HoverballPostCash = 0.1
			end,
			function(self)
				--self.rotgb_NoHoverball = true
				--self.rotgb_HoverballPostCash = 1.1
				self.rotgb_HoverballRange = self.rotgb_HoverballRange * 3
				self.rotgb_BankPlus = true
			end,
			function(self)
				self.rotgb_Trading = true
			end,
			function(self)
				self.rotgb_Buff = 1
			end,
			function(self)
				self.rotgb_Buff = 2
			end
		}
	}
}
ENT.UpgradeLimits = {7,2,0}

function ENT:ROTGB_ApplyPerks()
	self.FireRate = self.FireRate / (1+hook.Run("GetSkillAmount", "towerFireRate")/100)
end

function ENT:FireFunction(gBalloons, firePowerExpectedMultiplier)
	if self.rotgb_OldFusionPower ~= self.FusionPower then
		self.FireRate = self.FireRate * (1+self.FusionPower/100) / (1+(self.rotgb_OldFusionPower or 0)/100)
		self.rotgb_OldFusionPower = self.FusionPower
	end
	
	if IsValid(self.rotgb_Spawner) then
		local delayBetweenBalls = self.rotgb_HoverballDelay * 10 / self.FireRate / firePowerExpectedMultiplier
		if self:DetermineCharge(self.rotgb_Spawner) - self.rotgb_LastCharge >= delayBetweenBalls and self.rotgb_HoverballWorth > 0 --[[and not self.rotgb_NoHoverball]] then
			self.rotgb_LastCharge = self.rotgb_LastCharge + delayBetweenBalls
			local should10x = self.rotgb_10Chance and math.random() < 0.1
			local hoverballAmount = self.rotgb_HoverballWorth * (should10x and 10 or 1) * (1+self.FusionPower/100)
			if engine.ActiveGamemode() == "rotgb" then
				hoverballAmount = hoverballAmount * (1+hook.Run("GetSkillAmount", "valuableHoverballs")/100)
			end
			if self.rotgb_AutoHoverball or #ents.FindByClass("gballoon_tower_16_hoverball") > 64 then
				self:AddCash(hoverballAmount, self:GetTowerOwner())
				local effdata = EffectData()
				effdata:SetEntity(self)
				util.Effect("entity_remove",effdata,true,true)
			else
				local hoverball = ents.Create("gballoon_tower_16_hoverball")
				hoverball:SetPos(self:LocalToWorld(self.LOSOffset*2))
				hoverball:SetModel(self.rotgb_HoverballModel)
				if self.rotgb_10Chance then
					hoverball:SetMaterial(should10x and "models/props_combine/portalball001_sheet" or "models/effects/comball_tape")
				end
				hoverball:SetSkin(self.rotgb_HoverballSkin)
				hoverball:Spawn()
				hoverball:SetModelScale(self.ProjectileSize)
				hoverball:Activate()
				hoverball:AddEffects(EF_ITEM_BLINK)
				local physobj = hoverball:GetPhysicsObject()
				if IsValid(physobj) then
					local randnum = math.random()*math.pi*2
					local dirvec = Vector(math.sin(randnum), math.cos(randnum), 0)
					dirvec:Mul(10/delayBetweenBalls)
					physobj:Wake()
					physobj:SetVelocity(dirvec)
				end
				hoverball.rotgb_Range = self.rotgb_HoverballRange * self.ProjectileSize
				hoverball.rotgb_Value = hoverballAmount
				hoverball.rotgb_Tower = self
				timer.Simple(self.rotgb_HoverballLife,function()
					if IsValid(hoverball) then
						hoverball.rotgb_Value = 0
						hoverball:Remove()
					end
				end)
			end
		end
	else
		self:SetName("ROTGB_TOWER_16_"..self:GetCreationID())
		self.rotgb_Spawner = ents.FindByClass("gballoon_spawner")[1]
		if self.rotgb_Spawner then
			self.rotgb_LastCharge = self:DetermineCharge(self.rotgb_Spawner)
			self.rotgb_BankCharge = self:DetermineCharge(self.rotgb_Spawner)
		end
	end
	if self.rotgb_BankFactor > 0 --[[and not self.rotgb_NoHoverball]] and IsValid(gBalloons[1]) then
		self.rotgb_BankCharge = (self.rotgb_BankCharge or 0) + firePowerExpectedMultiplier
		while self.rotgb_BankCharge >= 10 do 
			self.rotgb_BankCharge = self.rotgb_BankCharge - 10
			self:PerformBank()
		end
	end
end

function ENT:DetermineCharge(spawner)
	local charge = spawner:GetWave()-1
	local percent = 1-math.Clamp((spawner:GetNextWaveTime()-CurTime())/spawner:GetWaveDuration(charge)*spawner:GetSpeedMul()*ROTGB_GetConVarValue("rotgb_spawner_spawn_rate"),0,1)
	return charge+percent
end

function ENT:PerformBank(lagless)
	self.rotgb_CashToAdd = lagless and self.rotgb_CashToAdd or {}
	local cashMultiplier = self.rotgb_BankFactor*(1+(hook.Run("GetSkillAmount", "valuableHoverballs") or 0)/100)
	cashMultiplier = cashMultiplier * (1+self.FusionPower/100)
	if self.rotgb_BankBonus then
		if not lagless then
			for k,v in pairs(ents.GetAll()) do
				if (v.Base == "gballoon_tower_base" and IsValid(v:GetTowerOwner())) then
					local towerowner = v:GetTowerOwner()
					self.rotgb_CashToAdd[towerowner] = (self.rotgb_CashToAdd[towerowner] or 0) + (v.SellAmount or 0)
				end
			end
		end
		for k,v in pairs(player.GetAll()) do
			self:AddCash(math.min(self.rotgb_BankMax, (ROTGB_GetCash(v) + (self.rotgb_CashToAdd[v] or 0)) * cashMultiplier), v)
		end
	else
		for k,v in pairs(player.GetAll()) do
			self:AddCash(math.min(self.rotgb_BankMax,ROTGB_GetCash(v)*cashMultiplier),v)
		end
	end
end

hook.Add("gBalloonSpawnerWaveStarted", "ROTGB_TOWER_16", function(spawner,wave)
	for k,v in pairs(ents.FindByClass("gballoon_tower_16")) do
		if v.rotgb_Spawner == spawner then
			local buff = v.rotgb_Buff
			v:AddCash(
				v.rotgb_HoverballWorth
				*(v.rotgb_10Chance and 1.9 or 1)
				/v.rotgb_HoverballDelay
				*(1+v.FusionPower/100)
				*v.FireRate/10
				*v.rotgb_HoverballPostCash
				*(v.rotgb_Trading and math.random()*4 or 1)
				*(1+(hook.Run("GetSkillAmount", "valuableHoverballs") or 0)/100),
				
				v:GetTowerOwner()
			)
			--[[if v.rotgb_BankFactor > 0 and v.rotgb_NoHoverball then
				v:PerformBank()
				for i=1,10 do
					v:PerformBank(true)
				end
			end]]
			-- rotgb_BankPlus
			if v.rotgb_BankFactor > 0 and v.rotgb_BankPlus then
				v:PerformBank()
			end
			if buff > 0 then
				local healthProvide = v.rotgb_AutoHoverball and 0.04 or 0.02
				if engine.ActiveGamemode() == "rotgb" then
					healthProvide = healthProvide*(1+hook.Run("GetSkillAmount", "hoverballFactoryHealthAmplifier")/100)
				end
				--[[if buff > 1 then
					v.rotgb_HoverballWorth = v.rotgb_HoverballWorth * 1.2
				end]]
				local targets = ents.FindByClass("gballoon_target")
				for k2,v2 in pairs(targets) do
					if v2:Health() < 999999999 then
						v2:SetHealth(math.min(v2:Health()+v2:GetMaxHealth()*healthProvide, 999999999))
						if buff > 1 then
							local healing = math.floor(ROTGB_GetCash(v:GetTowerOwner())/2000)
							if v2:Health()+healing > 999999999 then
								healing = 999999999-v2:Health()
							end
							ROTGB_RemoveCash(healing*100, v:GetTowerOwner())
							
							if engine.ActiveGamemode() == "rotgb" then
								healing = healing*(1+hook.Run("GetSkillAmount", "hoverballFactoryHealthAmplifier")/100)
							end
							v2:SetHealth(math.min(v2:Health()+healing, 999999999))
						end
					end
				end
			end
		end
	end
end)

function ENT:TriggerAbility()
	for k,v in pairs(player.GetAll()) do
		self:AddCash(
			ROTGB_GetCash(v)
			*(1+(hook.Run("GetSkillAmount", "valuableHoverballs") or 0)/100)
			*(1+self.FusionPower/100),
			
			v
		)
	end
end