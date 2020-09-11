AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Particle Charger"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Bombard those gBalloons!"
ENT.Instructions = ""
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/hunter/misc/cone1x1.mdl")
ENT.FireRate = 10
ENT.Cost = 650
ENT.DetectionRadius = 384
ENT.AbilityCooldown = 30
ENT.FireWhenNoEnemies = true
ENT.AttackDamage = 10
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,70)
ENT.UserTargeting = true
ENT.rotgb_ChargeDelay = 4
ENT.rotgb_MultiShot = 1
ENT.rotgb_MaxCharges = 250
--ENT.rotgb_SoundType = "67"
ENT.UpgradeReference = {
	{
		Names = {"Faster Production", "Erratic Spinner", "Omega Battery", "Rubber Smasher", "Machine Gun Module"},
		Descs = {
			"Particle charges are accumulated faster.",
			"Increases fire rate and maximum charges considerably.",
			"Tremendously increases fire rate and particle charges are accumulated even faster.",
			"Whenever this tower loses a charge, this tower gains a charge.",
			"Once every 60 seconds, firing at this tower massively increases fire rate and attack damage for 15 seconds!",
		},
		Prices = {600,3500,12500,20000,100000},
		Funcs = {
			function(self)
				self.rotgb_ChargeDelay = self.rotgb_ChargeDelay / 2
			end,
			function(self)
				self.FireRate = self.FireRate * 2
				self.rotgb_ChargeDelay = self.rotgb_ChargeDelay * 2
				self.rotgb_MaxCharges = self.rotgb_MaxCharges * 2
				--self.ContFire = nil
				--self:StopSound("ROTGB_TOWER_10_67")
				--self.rotgb_SoundType = "100"
			end,
			function(self)
				self.FireRate = self.FireRate * 2
				--self.ContFire = nil
				--self:StopSound("ROTGB_TOWER_10_100")
				--self.rotgb_SoundType = "200"
			end,
			function(self)
				self.rotgb_NoConsume = true
			end,
			function(self)
				self.HasAbility = true
			end
		}
	},
	{
		Names = {"Higher Speed Particles", "Magnetic Particles", "Antimatter Particles", ".99c Particles", "Exotic Particles"},
		Descs = {
			"Slightly increases attack damage.",
			"Allows the tower to see Hidden gBalloons.",
			"Considerably increases attack damage.",
			"Tremendously increases attack damage. Balloons popped by this tower do not spawn any children.",
			"Colossally increases attack damage!",
		},
		Prices = {600,1500,5000,30000,300000},
		Funcs = {
			function(self)
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.SeeCamo = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 40
				--self.rotgb_PopAqua = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 240
				self.rotgb_NoC = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 2700
				--self.rotgb_MultiShot = self.rotgb_MultiShot * 16
			end
		}
	},
	{
		Names = {"Particle Splitter", "Long Range Sparks", "Transforming Particles", "Particle Pulverizer", "Terraforming Particles"},
		Descs = {
			"The tower now pops multiple gBalloons each shot.",
			"Increases the tower's range.",
			"Whenever a particle from this tower hits a gBalloon, gain $10.",
			"The tower now hits all gBalloons within its radius each shot.",
			"gBalloons hit by this tower's shots permanently lose all immunities."
		},
		Prices = {600,1500,7500,20000,100000},
		Funcs = {
			function(self)
				self.rotgb_MultiShot = self.rotgb_MultiShot * 3
			end,
			function(self)
				self.DetectionRadius = self.DetectionRadius * 1.5
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
			end
		}
	}
}
ENT.UpgradeLimits = {5,2,0}

local lastshotsounds = {"weapons/airboat/airboat_gun_lastshot1.wav","weapons/airboat/airboat_gun_lastshot2.wav"}
--[[sound.Add({
	name = "ROTGB_TOWER_10_67",
	sound = "weapons/airboat/airboat_gun_loop2.wav",
	level = 120,
	volume = 1,
	pitch = 200/3,
	channel = CHAN_WEAPON
})]]
sound.Add({
	name = "ROTGB_TOWER_10_100",
	sound = "weapons/airboat/airboat_gun_loop2.wav",
	level = 120,
	volume = 1,
	pitch = 100,
	channel = CHAN_WEAPON
})
--[[sound.Add({
	name = "ROTGB_TOWER_10_200",
	sound = "weapons/airboat/airboat_gun_loop2.wav",
	level = 120,
	volume = 1,
	pitch = 200,
	channel = CHAN_WEAPON
})
sound.Add({
	name = "ROTGB_TOWER_10_67_L",
	sound = lastshotsounds,
	level = 120,
	volume = 1,
	pitch = 200/3,
	channel = CHAN_WEAPON
})]]
sound.Add({
	name = "ROTGB_TOWER_10_100_L",
	sound = lastshotsounds,
	level = 120,
	volume = 1,
	pitch = 100,
	channel = CHAN_WEAPON
})
--[[sound.Add({
	name = "ROTGB_TOWER_10_200_L",
	sound = lastshotsounds,
	level = 120,
	volume = 1,
	pitch = 200,
	channel = CHAN_WEAPON
})]]

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
	if CLIENT and not self.DispAng then --https://github.com/Facepunch/garrysmod-issues/issues/2732
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
		local self,ent = coroutine.yield()
		local startPos = self:GetShootPos()
		local uDir = ent:LocalToWorld(ent:OBBCenter())-startPos
		local bullet = {
			Attacker = self:GetTowerOwner(),
			Callback = function(attacker,tracer,dmginfo)
				dmginfo:SetDamageType((self.rotgb_PopAqua or self.rotgb_PopAqua2) and DMG_AIRBOAT or DMG_CLUB)
			end,
			Damage = self.AttackDamage,
			Distance = self.DetectionRadius*1.5,
			HullSize = 1,
			TracerName = "ToolTracer",
			Dir = uDir,
			Src = startPos
		}
		if self.rotgb_HitCredit then
			ROTGB_AddCash(10, self:GetTowerOwner())
		end
		if self.rotgb_NoI then
			ent:InflictRotgBStatusEffect("unimmune",999999)
		end
		if self.rotgb_NoC and self.AttackDamage/10>=ent:Health() then
			ent:Pop(-1)
			self:FireBullets(bullet)
		else
			self:FireBullets(bullet)
		end
	end
end

ENT.thread = coroutine.create(SnipeEntity)
coroutine.resume(ENT.thread)

function ENT:FireFunction(gBalloons)
	self:SetNWFloat("rotgb_Charges",math.min(self:GetNWFloat("rotgb_Charges") + 1/self.rotgb_ChargeDelay,self.rotgb_MaxCharges))
	if self:GetNWFloat("rotgb_Charges") >= 1 and next(gBalloons) then
		if not self.ContFire then
			self.ContFire = true
			--self:EmitSound("ROTGB_TOWER_10_"..self.rotgb_SoundType)
			self:EmitSound("ROTGB_TOWER_10_100")
		end
		if not self.rotgb_NoConsume then
			self:SetNWFloat("rotgb_Charges",self:GetNWFloat("rotgb_Charges")-1)
			self.FireWhenNoEnemies = true
		end
		if self.UserTargeting then
			for i=1,self.rotgb_MultiShot do
				if IsValid(gBalloons[i]) then
					local perf,str = coroutine.resume(self.thread,self,gBalloons[i])
					if not perf then error(str) end
				end
			end
		else
			for k,v in pairs(gBalloons) do
				local perf,str = coroutine.resume(self.thread,self,v)
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
	local valval = 1-math.max(self:GetNWFloat("rotgb_CC")-CurTime(),0)/10
	local mul = FrameTime()*self:GetNWFloat("rotgb_Charges")*0.05/valval
	self.DispAng = self.DispAng + self.DispAngA*mul
	local mapval = math.min(self:GetNWFloat("rotgb_Charges")/self.rotgb_MaxCharges,1)
	
	self:DrawModel()
	render.SetColorMaterial()
	render.DrawBox(self:GetShootPos(),self.DispAng,mins,maxs,HSVToColor(120,valval,mapval))
end

function ENT:TriggerAbility()
	self.FireRate = self.FireRate * 2
	self.AttackDamage = self.AttackDamage + 380
	--self.rotgb_PopAqua2 = true
	self:SetNWFloat("rotgb_CC",CurTime()+10)
	timer.Simple(15,function()
		if IsValid(self) then
			self.FireRate = self.FireRate / 2
			self.AttackDamage = self.AttackDamage - 380
			--self.rotgb_PopAqua2 = nil
		end
	end)
end

list.Set("NPC","gballoon_tower_10",{
	Name = ENT.PrintName,
	Class = "gballoon_tower_10",
	Category = ENT.Category
})