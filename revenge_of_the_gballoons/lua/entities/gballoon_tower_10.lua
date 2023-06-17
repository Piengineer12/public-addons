AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Particle Charger"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.tower.gballoon_tower_10.purpose"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/hunter/misc/cone1x1.mdl")
ENT.FireRate = 20
ENT.Cost = 650
ENT.DetectionRadius = 256
ENT.AbilityCooldown = 30
ENT.AbilityDuration = 15
ENT.FireWhenNoEnemies = true
ENT.AttackDamage = 10
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,70)
ENT.UserTargeting = true
ENT.rotgb_ChargeDelay = 10
ENT.rotgb_MultiShot = 1
ENT.rotgb_MaxCharges = 200
ENT.rotgb_AbilityDamage = 1000
ENT.UpgradeReference = {
	{
		Prices = {600,4000,45000,200000,1e6,8.5e6},
		Funcs = {
			function(self)
				self.rotgb_ChargeDelay = self.rotgb_ChargeDelay / 2
				self.rotgb_MaxCharges = self.rotgb_MaxCharges * 2
			end,
			function(self)
				self.FireRate = self.FireRate * 1.5
				self.rotgb_ChargeDelay = self.rotgb_ChargeDelay / 2
				self.rotgb_MaxCharges = self.rotgb_MaxCharges * 3
			end,
			function(self)
				self.FireRate = self.FireRate * 2
				self.rotgb_ChargeDelay = self.rotgb_ChargeDelay / 2.5
				self.rotgb_MaxCharges = self.rotgb_MaxCharges * 5
			end,
			function(self)
				self.rotgb_NoConsume = true
				self.rotgb_NoC = true
			end,
			function(self)
				self.HasAbility = true
			end,
			function(self)
				self.rotgb_AbilityDamage = self.rotgb_AbilityDamage * 10
			end
		}
	},
	{
		-- 2, 2, 3, 10 (5*2), 10 (20/2), 50
		Prices = {600,1000,4000,50000,500000,25e6},
		Funcs = {
			function(self)
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.SeeCamo = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 40
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 240
				self.rotgb_NoC = true
			end,
			function(self)
				self.rotgb_MaxCharges = self.rotgb_MaxCharges / 2
				self.AttackDamage = self.AttackDamage + 5700
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 294000
			end
		}
	},
	{
		Prices = {600,1000,3500,20000,75000,300000},
		Funcs = {
			function(self)
				self.rotgb_MultiShot = self.rotgb_MultiShot * 3
			end,
			function(self)
				self.DetectionRadius = self.DetectionRadius * 2
			end,
			function(self)
				self.rotgb_HitCredit = true
			end,
			function(self)
				self.UserTargeting = false
				self.SeeCamo = true
			end,
			function(self)
				self.rotgb_NoI = true
			end,
			function(self)
				self.rotgb_NoA = true
			end
		}
	}
}
ENT.UpgradeLimits = {6,2,0}

local lastshotsounds = {"weapons/airboat/airboat_gun_lastshot1.wav","weapons/airboat/airboat_gun_lastshot2.wav"}
sound.Add({
	name = "ROTGB_TOWER_10_100",
	sound = "weapons/airboat/airboat_gun_loop2.wav",
	level = 120,
	volume = 1,
	pitch = 100,
	channel = CHAN_WEAPON
})
sound.Add({
	name = "ROTGB_TOWER_10_100_L",
	sound = lastshotsounds,
	level = 120,
	volume = 1,
	pitch = 100,
	channel = CHAN_WEAPON
})

function ENT:ROTGB_Initialize()
	--self:SetNWFloat("rotgb_Charges",self.rotgb_MaxCharges)
	if CLIENT then
		self.DispAng = AngleRand()
		self.DispAngA = AngleRand()
		self.DispAngAEnd = self.DispAngA
		self.DispAngAEndTime = 0
	end
end

function ENT:ROTGB_Think()
	if CLIENT and not self.DispAng then
		self:ROTGB_Initialize()
	end
end

function ENT:ROTGB_OnRemove()
	if self.ContFire then
		self:StopSound("ROTGB_TOWER_10_100")
		self:EmitSound("ROTGB_TOWER_10_100_L")
	end
end

local function SnipeEntity()
	while true do
		local self,ent,chargesSpent = coroutine.yield()
		if self.rotgb_HitCredit then
			self:AddCash(5, self:GetTowerOwner())
		end
		if self.rotgb_NoI then
			ent:InflictRotgBStatusEffect("unimmune",999999)
		end
		if self.rotgb_NoA then
			ent:SetBalloonProperty("BalloonArmor", -15)
		end
		self:BulletAttack(ent, self.AttackDamage*chargesSpent, {
			damageType = bit.bor(DMG_CLUB, self.rotgb_NoC and DMG_DISSOLVE or 0),
			tracer = "ToolTracer",
		})
		self:SetNWFloat("rotgb_Charges",self:GetNWFloat("rotgb_Charges")-chargesSpent)
	end
end

ENT.thread = coroutine.create(SnipeEntity)
coroutine.resume(ENT.thread)

function ENT:FireFunction(gBalloons)
	if self:GetSpawnerActive() then
		self:SetNWFloat("rotgb_Charges",math.min(self:GetNWFloat("rotgb_Charges") + 1/self.rotgb_ChargeDelay,self.rotgb_MaxCharges))
	end
	if self:GetNWFloat("rotgb_Charges") >= 1 and next(gBalloons) then
		local chargesSpent = 1
		if not self.ContFire then
			self.ContFire = true
			--self:EmitSound("ROTGB_TOWER_10_"..self.rotgb_SoundType)
			self:EmitSound("ROTGB_TOWER_10_100")
		end
		if self.rotgb_NoConsume then
			local highestHealth = 0
			for k,v in pairs(gBalloons) do
				highestHealth = math.max(highestHealth, v:Health())
			end
			chargesSpent = math.min(highestHealth/self.AttackDamage*10/ROTGB_GetConVarValue("rotgb_damage_multiplier"), self:GetNWFloat("rotgb_Charges"))
		end
		if self.UserTargeting then
			for i=1,self.rotgb_MultiShot do
				if IsValid(gBalloons[i]) then
					local perf,str = coroutine.resume(self.thread,self,gBalloons[i],chargesSpent)
					if not perf then error(str) end
				end
			end
		else
			for k,v in pairs(gBalloons) do
				local perf,str = coroutine.resume(self.thread,self,v,chargesSpent)
				if not perf then error(str) end
			end
		end
	elseif self.ContFire then
		self.ContFire = nil
		self:StopSound("ROTGB_TOWER_10_100")
		self:EmitSound("ROTGB_TOWER_10_100_L")
	end
end

local mins = Vector(-8,-8,-8)
local maxs = -mins
function ENT:ROTGB_Draw()
	local shifttime = math.min(50/self:GetNWFloat("rotgb_Charges"),2)
	
	if self.DispAngAEndTime < CurTime() then
		self.DispAngAStart = self.DispAngAEnd
		self.DispAngAEndTime = CurTime()+shifttime
		self.DispAngAEnd = AngleRand()
	end
	local delta = (self.DispAngAEndTime-CurTime())/shifttime
	self.DispAngA = LerpAngle(delta,self.DispAngAEnd,self.DispAngAStart)
	local valval = math.min(1-self:GetAbilityFraction(), 1e6)
	local mul = FrameTime()*self:GetNWFloat("rotgb_Charges")*0.05/valval
	self.DispAng = self.DispAng + self.DispAngA*mul
	local mapval = math.min(self:GetNWFloat("rotgb_Charges")/self.rotgb_MaxCharges,1)
	
	self:DrawModel()
	render.SetColorMaterial()
	render.DrawBox(self:GetShootPos(),self.DispAng,mins,maxs,HSVToColor(120,valval,mapval))
end

function ENT:TriggerAbility()
	local addDamage = self.rotgb_AbilityDamage
	self:AddDelayedActions(self, "ROTGB_TOWER_10_ABILITY", 0, function(tower)
		tower.AttackDamage = tower.AttackDamage + addDamage
	end, self.AbilityDuration, function(tower)
		tower.AttackDamage = tower.AttackDamage - addDamage
	end)
end