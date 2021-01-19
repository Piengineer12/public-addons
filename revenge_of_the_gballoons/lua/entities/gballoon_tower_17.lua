AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Pill Lobber"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Treat those gBalloons!"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/maxofs2d/thruster_projector.mdl")
ENT.FireRate = 0.5
ENT.Cost = 400
ENT.DetectionRadius = 384
ENT.AttackDamage = 20
ENT.UseLOS = true
ENT.LOSOffset = Vector(0, 0, 25)
ENT.UserTargeting = true
ENT.AbilityCooldown = 80
ENT.rotgb_Pills = 1
ENT.rotgb_ExploRadius = 64
ENT.rotgb_PoisonDamage = 10
ENT.rotgb_SplashDamageModifier = -10
ENT.rotgb_AbilityType = 0
ENT.rotgb_FlyTime = 1
ENT.UpgradeReference = {
	{
		Names = {"Faster Cooking","Better Cooking","Fire Pill Recipe","Rush Hour"},
		Descs = {
			"Slightly increases fire rate.",
			"Considerably increases fire rate and slightly increases splash radius.",
			"Enables the tower to lob fire pills that set gBalloons on fire for 10 seconds.",
			"Once every 80 seconds, shooting at this tower tremendously increases fire rate and considerably increases pill count for 60 seconds.",
		},
		Prices = {175,1000,6000,20000},
		Funcs = {
			function(self)
				self.FireRate = self.FireRate*1.5
			end,
			function(self)
				self.FireRate = self.FireRate*2
				self.rotgb_ExploRadius = self.rotgb_ExploRadius*1.5
			end,
			function(self)
				table.insert(self.rotgb_PillTypes, 0)
			end,
			function(self)
				self.HasAbility = true
				self.rotgb_AbilityType = self.rotgb_AbilityType + 1
			end,
		}
	},
	{
		Names = {"Better Pills","Better Splash","Toxic Pill Recipe","Toxin Cloud"},
		Descs = {
			"Slightly increases direct hit damage and splash radius.",
			"Considerably increases splash radius and tremendously increases indirect hit damage.",
			"Enables the tower to lob toxic pills that leave a poisonous cloud behind. The clouds last for 10 seconds and deal 1 damage per half-second.",
			"Tremendously increases poison cloud damage. Once every 80 seconds, shooting at this tower poisons all gBalloons in the map for 90 seconds.",
		},
		Prices = {300,2750,10000,25000},
		Funcs = {
			function(self)
				self.AttackDamage = self.AttackDamage + 10
				self.rotgb_SplashDamageModifier = self.rotgb_SplashDamageModifier - 10
				self.rotgb_ExploRadius = self.rotgb_ExploRadius*1.5
			end,
			function(self)
				self.rotgb_ExploRadius = self.rotgb_ExploRadius*2
				self.rotgb_SplashDamageModifier = self.rotgb_SplashDamageModifier + 20
			end,
			function(self)
				table.insert(self.rotgb_PillTypes, 1)
			end,
			function(self)
				self.rotgb_PoisonDamage = self.rotgb_PoisonDamage + 20
				self.HasAbility = true
				self.rotgb_AbilityType = self.rotgb_AbilityType + 2
			end,
		}
	},
	{
		Names = {"Sharper Glass","Even Sharper Glass","Electric Pill Recipe","Shock N' Wave"},
		Descs = {
			"Slightly increases direct hit damage and considerably increases indirect hit damage.",
			"Considerably increases direct hit damage and tremendously increases indirect hit damage.",
			"Enables the tower to lob electric pills that create an electric spark, arcing up to 4 gBalloons. Also enables the tower to pop Hidden gBallons.",
			"Once every 80 seconds, shooting at this tower causes it to emit two pulses, dealing 2,000 layers of shock and sonic damage to all gBalloons within its radius.",
		},
		Prices = {350,1250,20000,100000},
		Funcs = {
			function(self)
				self.AttackDamage = self.AttackDamage + 10
				self.rotgb_SplashDamageModifier = self.rotgb_SplashDamageModifier - 10
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 30
				self.rotgb_SplashDamageModifier = self.rotgb_SplashDamageModifier + 20
			end,
			function(self)
				self.SeeCamo = true
				table.insert(self.rotgb_PillTypes, 2)
			end,
			function(self)
				self.HasAbility = true
				self.rotgb_AbilityType = self.rotgb_AbilityType + 4
			end,
		}
	}
}
ENT.UpgradeLimits = {4,3,0}

function ENT:GetZVelocity(heightDifference)
	local flyTime = self.rotgb_FlyTime
	return (heightDifference-physenv.GetGravity().z*flyTime*flyTime/2)/flyTime
end

function ENT:ROTGB_Initialize()
	self.rotgb_PillTypes = {}
	self.rotgb_PoisonSpots = {}
	self.rotgb_TaggedgBalloons = {}
end

function ENT:FireFunction(tableOfBalloons)
	local attempts = self.rotgb_Pills
	local success = nil
	for i,bln in ipairs(tableOfBalloons) do
		if self:ValidTargetIgnoreRange(bln) and not self.rotgb_TaggedgBalloons[bln] then
			success = true
			self:LobPill(bln)
			self.rotgb_TaggedgBalloons[bln] = true
			attempts = attempts - 1
			if attempts <= 0 then break end
		end
	end
	if not success then
		table.Empty(self.rotgb_TaggedgBalloons)
		return true
	end
end

local function OnCollision(ent,coldata)
	if IsValid(ent.Tower) then
		local tower = ent.Tower
		local closestBln, closestDist = NULL, math.huge
		local entCenter = ent:LocalToWorld(ent:OBBCenter())
		local zapBln = false
		if IsValid(ent.gBalloon) then
			tower.rotgb_TaggedgBalloons[ent.gBalloon] = nil
		end
		for k,v in pairs(ents.FindInSphere(entCenter, ent:BoundingRadius()*1.5)) do
			local dist = entCenter:DistToSqr(v:LocalToWorld(v:OBBCenter()))
			if tower:ValidTargetIgnoreRange(v) and dist < closestDist then
				closestDist = dist
				closestBln = v
			end
		end
		if IsValid(closestBln) then
			tower:ApplyDirectDamage(closestBln,ent)
		end
		for k,v in pairs(ents.FindInSphere(entCenter, tower.rotgb_ExploRadius)) do
			if tower:ValidTargetIgnoreRange(v) and v~=closestBln then
				tower:ApplyIndirectDamage(v,ent)
				if not zapBln and ent.rotgb_PillType == 2 then
					zapBln = true
					for k,v in pairs(tower:AccumulategBalloons(v)) do
						local dmginfo = tower:CreateDamageInfo()
						dmginfo:SetDamageType(DMG_SHOCK)
						dmginfo:SetDamage(tower.AttackDamage+tower.rotgb_SplashDamageModifier)
						dmginfo:SetDamagePosition(k:GetPos()+k:OBBCenter())
						k:TakeDamageInfo(dmginfo)
					end
				end
			end
		end
		if ent.rotgb_PillType == 1 then
			local poisonPos = coldata.HitPos+coldata.HitNormal
			tower.rotgb_PoisonSpots[CurTime()+10] = poisonPos
			local effData = EffectData()
			effData:SetOrigin(poisonPos)
			effData:SetEntity(tower)
			util.Effect("gballoon_tower_17_poison", effData)
		end
	end
	ent:EmitSound(string.format("physics/glass/glass_impact_bullet%u.wav",math.random(1,4)), 60, math.Remap(math.random(), 0, 1, 80, 120), 1, CHAN_WEAPON)
	SafeRemoveEntity(ent)
end

function ENT:ApplyDirectDamage(bln,pill)
	bln:ShowCritEffect()
	pill:EmitSound("phx/epicmetal_hard"..math.random(7)..".wav",60,100,1,CHAN_WEAPON)
	if pill.rotgb_PillType == 0 then
		bln:RotgB_Ignite(10, self:GetTowerOwner(), self, 10)
	end
	local dmginfo = self:CreateDamageInfo()
	dmginfo:SetDamage(self.rotgb_SplashDamageModifier > 0 and self.AttackDamage+self.rotgb_SplashDamageModifier or self.AttackDamage)
	dmginfo:SetDamagePosition(bln:GetPos()+bln:OBBCenter())
	bln:TakeDamageInfo(dmginfo)
end

function ENT:ApplyIndirectDamage(bln,pill)
	if pill.rotgb_PillType == 0 then
		bln:RotgB_Ignite(10, self:GetTowerOwner(), self, 10)
	end
	local dmginfo = self:CreateDamageInfo()
	dmginfo:SetDamage(self.AttackDamage+self.rotgb_SplashDamageModifier)
	dmginfo:SetDamagePosition(bln:GetPos()+bln:OBBCenter())
	bln:TakeDamageInfo(dmginfo)
end

function ENT:CreateDamageInfo()
	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(self:GetTowerOwner())
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(DMG_SLASH)
	dmginfo:SetReportedPosition(self:GetShootPos())
	return dmginfo
end

function ENT:LobPill(bln)
	local pill = ents.Create("prop_physics")
	pill:SetPos(self:GetShootPos())
	pill:AddCallback("PhysicsCollide",OnCollision)
	pill:SetModel("models/props_lab/jar01b.mdl")
	pill:Spawn()
	pill:SetCollisionGroup(COLLISION_GROUP_WORLD)
	if next(self.rotgb_PillTypes) then
		self.rotgb_CurrentPill = (self.rotgb_CurrentPill or 0) + 1
		if not self.rotgb_PillTypes[self.rotgb_CurrentPill] then
			self.rotgb_CurrentPill = 1
		end
		pill.rotgb_PillType = self.rotgb_PillTypes[self.rotgb_CurrentPill]
		if pill.rotgb_PillType == 1 then
			pill:SetColor(Color(0, 255, 127))
		elseif pill.rotgb_PillType == 2 then
			pill:SetColor(Color(127, 0, 255))
		else
			pill:SetColor(Color(255, 127, 0))
		end
	end
	pill.Tower = self
	pill.gBalloon = bln
	local physobj = pill:GetPhysicsObject()
	if IsValid(physobj) then
		physobj:AddAngleVelocity(VectorRand(-1000,1000))
		physobj:EnableDrag(false)
		local ivel = bln:GetPos()+bln.loco:GetVelocity()*self.rotgb_FlyTime-self:GetShootPos()
		ivel.x = ivel.x / self.rotgb_FlyTime
		ivel.y = ivel.y / self.rotgb_FlyTime
		ivel.z = self:GetZVelocity(ivel.z)
		physobj:SetVelocity(ivel)
	end
end

function ENT:AccumulategBalloons(bln)
	local count, tab1 = 0, {}
	for k,v in pairs(ents.FindInSphere(bln:GetPos(), self.rotgb_ExploRadius)) do
		if self:ValidTargetIgnoreRange(v) and not tab1[v] then
			count = count + 1
			tab1[v] = true
			if count >= 4 then return tab1 end
		end
	end
	return tab1
end

function ENT:ROTGB_Think()
	if (self.rotgb_NextPoisonCheck or 0) < CurTime() then
		self.rotgb_NextPoisonCheck = CurTime() + 0.5
		local dmginfo = self:CreateDamageInfo()
		dmginfo:SetDamageType(DMG_POISON)
		for k,v in pairs(self.rotgb_PoisonSpots) do
			if k < CurTime() then
				self.rotgb_PoisonSpots[k] = nil
			else
				for k2,v2 in pairs(ents.FindInSphere(v, 64)) do
					if self:ValidTargetIgnoreRange(v2) then
						dmginfo:SetDamage(self.rotgb_PoisonDamage)
						dmginfo:SetDamagePosition(v2:GetPos()+v2:OBBCenter())
						v2:TakeDamageInfo(dmginfo)
					end
				end
			end
		end
		for k,v in pairs(ents.FindByClass("gballoon_base")) do
			v.AcidicList = v.AcidicList or {}
			if v.AcidicList[self] then
				if v.AcidicList[self] < CurTime() then
					v.AcidicList[self] = nil
				else
					dmginfo:SetDamage(self.rotgb_PoisonDamage)
					dmginfo:SetDamagePosition(v:LocalToWorld(v:OBBCenter()))
					v:TakeDamageInfo(dmginfo)
				end
			end
		end
	end
end

function ENT:TriggerAbility()
	local gBalloonTable = baseclass.Get("gballoon_base")
	if bit.band(self.rotgb_AbilityType, 1) ~= 0 then
		self.FireRate = self.FireRate*3
		self.rotgb_Pills = self.rotgb_Pills*2
		timer.Simple(60, function()
			if IsValid(self) then
				self.FireRate = self.FireRate/3
				self.rotgb_Pills = self.rotgb_Pills/2
			end
		end)
	end
	if bit.band(self.rotgb_AbilityType, 2) ~= 0 then
		local effData = EffectData()
		for k,v in pairs(gBalloonTable:GetgBalloons()) do
			effData:SetEntity(v)
			util.Effect("gballoon_tower_17_poison", effData)
			v.AcidicList = v.AcidicList or {}
			v.AcidicList[self] = CurTime()+90
		end
	end
	if bit.band(self.rotgb_AbilityType, 4) ~= 0 then
		local dmginfo = self:CreateDamageInfo()
		dmginfo:SetDamage(10000)
		for k,v in pairs(ents.FindInSphere(self:GetShootPos(), self.DetectionRadius)) do
			if self:ValidTarget(v) then
				dmginfo:SetDamagePosition(v:LocalToWorld(v:OBBCenter()))
				dmginfo:SetDamageType(DMG_SHOCK)
				v:TakeDamageInfo(dmginfo)
				dmginfo:SetDamageType(DMG_SONIC)
				v:TakeDamageInfo(dmginfo)
			end
		end
	end
end

if CLIENT then
	local EFFECT = {}
	function EFFECT:Init(data)
		self.KillTime = CurTime() + 10
		self.emitter = ParticleEmitter(data:GetOrigin(), false)
		self.tower = data:GetEntity()
	end
	function EFFECT:Think()
		if self.KillTime < CurTime() then
			self.emitter:Finish()
			return false
		else return true
		end
	end
	function EFFECT:Render()
		if IsValid(self.emitter) and IsValid(self.tower) and self.KillTime - 1 > CurTime() then
			if self.emitter:GetNumActiveParticles() < 100 then
				local particle = self.emitter:Add("particle/smokestack", self.tower:GetClass()=="gballoon_base" and self.tower:GetPos() or self.emitter:GetPos())
				if particle then
					particle:SetVelocity(VectorRand(-100,100))
					particle:SetColor(0,math.random()*127,0)
					particle:SetDieTime(1)
					particle:SetStartSize(16)
					particle:SetEndSize(16)
					--particle:SetLighting(true)
					particle:SetAirResistance(50)
					particle:SetRoll(math.random()*math.pi*2)
					particle:SetRollDelta(math.random(-3,3))
				end
			end
		end
	end
	effects.Register(EFFECT,"gballoon_tower_17_poison")
end