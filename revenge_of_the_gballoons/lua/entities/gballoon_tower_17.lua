AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Pill Lobber"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.tower.gballoon_tower_17.purpose"
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
ENT.rotgb_PoisonDuration = 10
ENT.rotgb_PoisonRange = 64
ENT.rotgb_SplashDamageModifier = -10
ENT.rotgb_AbilityType = 0
ENT.rotgb_FlyTime = 1
ENT.rotgb_ExtraMul = 0
ENT.UpgradeReference = {
	{
		Prices = {175,1000,5000,12500,150000},
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
				self.rotgb_AbilityType = bit.bor(self.rotgb_AbilityType, 1)
			end,
			function(self)
				self.rotgb_AbilityType = bit.bor(self.rotgb_AbilityType, 8)
			end
		}
	},
	{
		Prices = {250,2750,10000,25000,1.2e6},
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
				self.rotgb_AbilityType = bit.bor(self.rotgb_AbilityType, 2)
			end,
			function(self)
				self.rotgb_PoisonDamage = self.rotgb_PoisonDamage + 240
				self.rotgb_PoisonDuration = self.rotgb_PoisonDuration * 2
				self.rotgb_PoisonRange = self.rotgb_PoisonRange * 2
			end,
		}
	},
	{
		Prices = {375,1500,7500,30000,750000},
		Funcs = {
			function(self)
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 30
				self.rotgb_SplashDamageModifier = self.rotgb_SplashDamageModifier + 10
			end,
			function(self)
				table.insert(self.rotgb_PillTypes, 2)
			end,
			function(self)
				self.HasAbility = true
				self.rotgb_AbilityType = bit.bor(self.rotgb_AbilityType, 4)
			end,
			function(self)
				self:SetAbilityCharge(0)
				self.rotgb_AbilityType = bit.bor(self.rotgb_AbilityType, 16)
			end,
		}
	},
	{
		Prices = {125,1000,12500,25000,1e6},
		Funcs = {
			function(self)
				self.DetectionRadius = self.DetectionRadius * 4/3
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 50
				self.rotgb_SplashDamageModifier = self.rotgb_SplashDamageModifier - 50
				self.InfiniteRange = true
				self.SeeCamo = true
			end,
			function(self)
				table.insert(self.rotgb_PillTypes, 3)
			end,
			function(self)
				self.rotgb_ExtraMul = 1
			end,
			function(self)
				self.rotgb_ExtraBlimps = true
				self.rotgb_ExtraMul = self.rotgb_ExtraMul * 9
			end,
		}
	}
}
ENT.UpgradeLimits = {5,3,3,0}

function ENT:ROTGB_ApplyPerks()
	self.rotgb_FlyTime = self.rotgb_FlyTime * (1+hook.Run("GetSkillAmount", "pillLobberFlyTime")/100)
	self.rotgb_ExploRadius = self.rotgb_ExploRadius * (1+hook.Run("GetSkillAmount", "pillLobberExploRadius")/100)
	
	local directDamage = math.floor(hook.Run("GetSkillAmount", "pillLobberDirectDamage"))*10
	self.AttackDamage = self.AttackDamage + directDamage
	self.rotgb_SplashDamageModifier = self.rotgb_SplashDamageModifier - directDamage
end

function ENT:GetThrowVelocity(localVector)
	local flyTime = self.rotgb_FlyTime
	local tsd = flyTime*flyTime/2
	local datsd = localVector-physenv.GetGravity()*tsd
	datsd:Div(flyTime)
	return datsd
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
			tower.rotgb_PoisonSpots[CurTime()+tower.rotgb_PoisonDuration] = poisonPos
			local effData = EffectData()
			effData:SetOrigin(poisonPos)
			effData:SetEntity(tower)
			effData:SetMagnitude(tower.rotgb_PoisonDuration)
			effData:SetScale(tower.rotgb_PoisonRange / 64)
			util.Effect("gballoon_tower_17_poison", effData)
		end
	end
	ent:EmitSound(string.format("physics/glass/glass_impact_bullet%u.wav",math.random(1,4)), 60, math.Remap(math.random(), 0, 1, 80, 120), 1, CHAN_WEAPON)
	SafeRemoveEntity(ent)
end

function ENT:ApplyDirectDamage(bln,pill)
	bln:ShowCritEffect()
	local owner = self:GetTowerOwner()
	pill:EmitSound("phx/epicmetal_hard"..math.random(7)..".wav",60,100,1,CHAN_WEAPON)
	if pill.rotgb_PillType == 0 then
		bln:RotgB_Ignite(20, owner, self, 10)
	elseif pill.rotgb_PillType == 3 and self.rotgb_ExtraMul > 0 and not bln:GetBalloonProperty("BalloonBlimp") or self.rotgb_ExtraBlimps then
		bln:MultiplyValue("ROTGB_TOWER_17",self,self.rotgb_ExtraMul,99999)
		local effData = EffectData()
		effData:SetEntity(bln)
		util.Effect("gballoon_tower_17_morecash", effData)
	end
	local dmginfo = self:CreateDamageInfo()
	if pill.rotgb_PillType == 3 and bln:GetBalloonProperty("BalloonType")=="gballoon_gray" then
		dmginfo:SetDamage(2147483647)
		dmginfo:SetBaseDamage(2147483647)
		dmginfo:SetDamageType(bit.bor(DMG_ACID, DMG_DISSOLVE))
		self:AddCash(bit.lshift(25,2*#self.rotgb_PillTypes), owner)
	elseif pill.rotgb_PillType == 2 then
		dmginfo:SetDamage(self.AttackDamage+self.rotgb_SplashDamageModifier)
		dmginfo:SetDamageType(DMG_SHOCK)
	else
		dmginfo:SetDamage(self.rotgb_SplashDamageModifier > 0 and self.AttackDamage+self.rotgb_SplashDamageModifier or self.AttackDamage)
	end
	dmginfo:SetDamagePosition(bln:GetPos()+bln:OBBCenter())
	bln:TakeDamageInfo(dmginfo)
end

function ENT:ApplyIndirectDamage(bln,pill)
	local owner = self:GetTowerOwner()
	if pill.rotgb_PillType == 0 then
		bln:RotgB_Ignite(20, owner, self, 10)
	elseif pill.rotgb_PillType == 3 and self.rotgb_ExtraMul > 0 and not bln:GetBalloonProperty("BalloonBlimp") or self.rotgb_ExtraBlimps then
		bln:MultiplyValue("ROTGB_TOWER_17",self,self.rotgb_ExtraMul,99999)
		local effData = EffectData()
		effData:SetEntity(bln)
		util.Effect("gballoon_tower_17_morecash", effData)
	end
	local dmginfo = self:CreateDamageInfo()
	if pill.rotgb_PillType == 3 and bln:GetBalloonProperty("BalloonType")=="gballoon_gray" then
		dmginfo:SetDamage(2147483647)
		dmginfo:SetBaseDamage(2147483647)
		dmginfo:SetDamageType(bit.bor(DMG_ACID, DMG_DISSOLVE))
		self:AddCash(bit.lshift(25,2*#self.rotgb_PillTypes), owner)
	elseif pill.rotgb_PillType == 2 then
		dmginfo:SetDamage(self.AttackDamage+self.rotgb_SplashDamageModifier)
		dmginfo:SetDamageType(DMG_SHOCK)
	else
		dmginfo:SetDamage(self.AttackDamage+self.rotgb_SplashDamageModifier)
	end
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
			pill:SetColor(Color(0, 255, 0))
		elseif pill.rotgb_PillType == 2 then
			pill:SetColor(Color(0, 127, 255))
		elseif pill.rotgb_PillType == 3 then
			pill:SetColor(Color(255, 0, 255))
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
		local ivel = self:GetThrowVelocity(bln:GetPos()+bln.loco:GetVelocity()*self.rotgb_FlyTime-self:GetShootPos())
		--[[ivel.x = ivel.x / self.rotgb_FlyTime
		ivel.y = ivel.y / self.rotgb_FlyTime
		ivel.z = self:GetZVelocity(ivel.z)]]
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
				for k2,v2 in pairs(ents.FindInSphere(v, self.rotgb_PoisonRange)) do
					if self:ValidTargetIgnoreRange(v2) then
						dmginfo:SetDamage(self.rotgb_PoisonDamage)
						dmginfo:SetDamagePosition(v2:GetPos()+v2:OBBCenter())
						v2:TakeDamageInfo(dmginfo)
					end
				end
			end
		end
		for k,v in pairs(ROTGB_GetBalloons()) do
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
	if bit.band(self.rotgb_AbilityType, 1) ~= 0 then
		if bit.band(self.rotgb_AbilityType, 8) == 0 then
			self:ApplyBuff(self, "ROTGB_TOWER_17_ABILITY", 60, function(tower)
				tower.FireRate = tower.FireRate * 3
				tower.rotgb_Pills = tower.rotgb_Pills * 2
			end, function(tower)
				tower.FireRate = tower.FireRate / 3
				tower.rotgb_Pills = tower.rotgb_Pills / 2
			end)
		else
			self:ApplyBuff(self, "ROTGB_TOWER_17_ABILITY", 60, function(tower)
				tower.FireRate = tower.FireRate * 15
				tower.rotgb_Pills = tower.rotgb_Pills * 6
			end, function(tower)
				tower.FireRate = tower.FireRate / 15
				tower.rotgb_Pills = tower.rotgb_Pills / 6
			end)
		end
	end
	if bit.band(self.rotgb_AbilityType, 2) ~= 0 then
		local effData = EffectData()
		effData:SetMagnitude(90)
		effData:SetScale(1)
		for k,v in pairs(ROTGB_GetBalloons()) do
			effData:SetEntity(v)
			effData:SetOrigin(v:GetPos())
			util.Effect("gballoon_tower_17_poison", effData)
			v.AcidicList = v.AcidicList or {}
			v.AcidicList[self] = CurTime()+90
		end
	end
	if bit.band(self.rotgb_AbilityType, 4) ~= 0 then
		local dmginfo = self:CreateDamageInfo()
		if bit.band(self.rotgb_AbilityType, 16) == 0 then
			dmginfo:SetDamage(10000)
		else
			dmginfo:SetDamage(1000000)
		end
		for k,v in pairs(ents.FindInSphere(self:GetShootPos(), self.DetectionRadius)) do
			if self:ValidTarget(v) then
				dmginfo:SetDamagePosition(v:LocalToWorld(v:OBBCenter()))
				dmginfo:SetDamageType(DMG_SHOCK)
				v:TakeDamageInfo(dmginfo)
				dmginfo:SetDamageType(DMG_SONIC)
				v:TakeDamageInfo(dmginfo)
			end
		end
		if bit.band(self.rotgb_AbilityType, 16) ~= 0 then
			local effdata = EffectData()
			effdata:SetMagnitude(1)
			effdata:SetScale(1)
			effdata:SetOrigin(self:GetPos())
			effdata:SetStart(self:GetPos())
			util.Effect("Explosion",effdata,true,true)
			self.SellAmount = 0
			self:Remove()
		end
	end
end

if CLIENT then
	local EFFECT = {}
	function EFFECT:Init(data)
		self.KillTime = CurTime() + data:GetMagnitude()
		self.emitter = ParticleEmitter(data:GetOrigin(), false)
		self.tower = data:GetEntity()
		self.velocity = data:GetScale() * 100
	end
	function EFFECT:Think()
		if self.KillTime < CurTime() then
			self.emitter:Finish()
			return false
		else return true
		end
	end
	function EFFECT:Render()
		if IsValid(self.emitter) and IsValid(self.tower) and self.KillTime - 1 > CurTime() and FrameTime() > 0 then
			if self.emitter:GetNumActiveParticles() < 100 then
				local particle = self.emitter:Add("particle/smokestack", self.tower:GetClass()=="gballoon_base" and self.tower:GetPos() or self.emitter:GetPos())
				if particle then
					particle:SetVelocity(VectorRand(-self.velocity,self.velocity))
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
	
	EFFECT = {}
	function EFFECT:Init(data)
		self.entity = data:GetEntity()
		if IsValid(self.entity) then
			self.emitter = ParticleEmitter(self.entity:GetPos(), false)
		end
	end
	function EFFECT:Think()
		if not IsValid(self.entity) then
			if self.emitter then
				self.emitter:Finish()
			end
			return false
		else
			self.emitter:SetPos(self.entity:GetPos())
			return true
		end
	end
	function EFFECT:Render()
		if IsValid(self.emitter) and IsValid(self.entity) and FrameTime() > 0 then
			local startPos = VectorRand(self.entity:OBBMins(), self.entity:OBBMaxs())
			startPos:Add(self.entity:GetPos())
			local particle = self.emitter:Add("sprites/orangecore2_gmod", startPos)
			if particle then
				particle:SetColor(255,0,255)
				particle:SetBounce(0.2)
				particle:SetCollide(true)
				particle:SetGravity(Vector(0,0,-600))
				particle:SetDieTime(2)
				particle:SetStartAlpha(32)
				particle:SetEndAlpha(1024)
				particle:SetStartSize(8)
				particle:SetEndSize(0)
				--particle:SetLighting(true)
				particle:SetRoll(math.random()*math.pi*2)
			end
		end
	end
	effects.Register(EFFECT,"gballoon_tower_17_morecash")
end