AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Bishop of Glue"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "This tower slows gBalloons that it hits, but deals zero damage."
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/props_phx/games/chess/black_bishop.mdl")
ENT.FireRate = 2
ENT.Cost = 300
ENT.DetectionRadius = 256
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,40)
ENT.UserTargeting = true
ENT.AttackDamage = 0
ENT.AbilityCooldown = 15
ENT.rotgb_Hits = 1
ENT.rotgb_GlueSlowdown = 1/3
ENT.rotgb_GlueDamage = 0
ENT.rotgb_GlueDuration = 5
ENT.UpgradeReference = {
	{
		Names = {"Stronger Glue","High Speed Glue Nozzle","Liquid-Solid Glue","G.G. Glue","Shattering Glue"},
		Descs = {
			"Glue slows down gBalloons more and lasts slightly longer.",
			"Considerably increases fire rate.",
			"Glue slows down gBalloons even more.",
			"Glue can now affect gBlimps weaker than Purple gBlimps.",
			"Glue causes gBalloons to lose all immunities, if they can be glued."
		},
		Prices = {250,500,1000,10000,150000},
		Funcs = {
			function(self)
				self.rotgb_GlueSlowdown = self.rotgb_GlueSlowdown * 1.5
				self.rotgb_GlueDuration = self.rotgb_GlueDuration * 1.5
			end,
			function(self)
				self.FireRate = self.FireRate * 2
			end,
			function(self)
				self.rotgb_GlueSlowdown = self.rotgb_GlueSlowdown * 1.5
			end,
			function(self)
				self.rotgb_GreatGlue = true
			end,
			function(self)
				self.rotgb_ShatterGlue = true
			end
		}
	},
	{
		Names = {"Glue Soak","Corrosive Glue","Acid-Glue Mixture","gBalloon Dissolver","gBalloon Ultimate Solvent"},
		Descs = {
			"Glue soaks through all layers of gBalloons.",
			"Glue causes gBalloons to take damage over time.",
			"Glue pops two layers per second and lasts considerably longer.",
			"Glue pops ten layers per second!",
			"Glue pops 100 layers per second!"
		},
		Prices = {250,1250,3500,17500,200000},
		Funcs = {
			function(self)
				self.rotgb_GlueSoak = true
			end,
			function(self)
				self.rotgb_GlueDamage = self.rotgb_GlueDamage + 10
			end,
			function(self)
				self.rotgb_DoubleThink = true
				self.rotgb_GlueDuration = self.rotgb_GlueDuration * 2
			end,
			function(self)
				self.rotgb_GlueDamage = self.rotgb_GlueDamage + 40
			end,
			function(self)
				self.rotgb_GlueDamage = self.rotgb_GlueDamage + 450
			end
		}
	},
	{
		Names = {"Glue Nozzle","Glue Splatter","Glue Blaster","Glue Sprinkler","Glue Air Strike"},
		Descs = {
			"Glue travels considerably further.",
			"Three gBalloons are glued per shot.",
			"One gBalloon is glued per shot, but glue hits affect surrounding gBalloons.",
			"Any non-immune gBalloon within the tower's range gets glued! Also enables the tower to glue hidden gBalloons.",
			"Glue lasts considerably longer. Once every 15 seconds, shooting at this tower causes ALL gBalloons to be glued, regardless of immunities!"
		},
		Prices = {250,1000,3500,12500,50000},
		Funcs = {
			function(self)
				self.DetectionRadius = self.DetectionRadius * 2
			end,
			function(self)
				self.rotgb_Hits = self.rotgb_Hits * 3
			end,
			function(self)
				self.rotgb_Hits = self.rotgb_Hits / 3
				self.rotgb_GlueSplatter = true
			end,
			function(self)
				self.rotgb_GlueSlosher = true
				self.SeeCamo = true
			end,
			function(self)
				self.HasAbility = true
				self.rotgb_GlueDuration = self.rotgb_GlueDuration * 2
			end
		}
	}
}
ENT.UpgradeLimits = {5,2,0}

function ENT:ROTGB_ApplyPerks()
	self.FireRate = self.FireRate * (1+hook.Run("GetSkillAmount", "bishopOfGlueFireRate")/100)
end

local function SnipeEntity()
	while true do
		local self,ent = coroutine.yield()
		ent:Slowdown("ROTGB_GLUE_TOWER",1-self.rotgb_GlueSlowdown,self.rotgb_GlueDuration)
		local effData = EffectData()
		effData:SetEntity(ent)
		effData:SetFlags(self.rotgb_GlueDamage > 0 and 1 or 0)
		effData:SetHitBox(self.rotgb_GlueDuration*10)
		util.Effect("gballoon_tower_9_glued", effData)
		if self.rotgb_GlueSoak then
			ent:InflictRotgBStatusEffect("glue_soak",self.rotgb_GlueDuration)
		end
		if self.rotgb_ShatterGlue then
			ent:InflictRotgBStatusEffect("unimmune",self.rotgb_GlueDuration)
		end
		if self.rotgb_GlueDamage > 0 then
			ent.AcidicList = ent.AcidicList or {}
			ent.AcidicList[self] = {self.rotgb_GlueDamage,CurTime()+self.rotgb_GlueDuration}
		end
		if self.AttackDamage > 0 then
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(self:GetTowerOwner())
			dmginfo:SetInflictor(self)
			dmginfo:SetDamageType(DMG_CRUSH)
			dmginfo:SetReportedPosition(self:GetShootPos())
			dmginfo:SetDamage(self.AttackDamage)
			dmginfo:SetDamagePosition(ent:LocalToWorld(ent:OBBCenter()))
			ent:TakeDamageInfo(dmginfo)
		end
	end
end

ENT.thread = coroutine.create(SnipeEntity)
coroutine.resume(ENT.thread)

function ENT:FireFunction(gBalloons)
	local hits = 0
	if self.rotgb_GlueSplatter then
		for i,v in ipairs(gBalloons) do
			if not (v.rotgb_SpeedMods and v.rotgb_SpeedMods.ROTGB_GLUE_TOWER) then
				for k,v2 in pairs(ents.FindInSphere(v:GetPos(),64)) do
					if self:ValidTargetIgnoreRange(v2) and not (v2.rotgb_SpeedMods and v2.rotgb_SpeedMods.ROTGB_GLUE_TOWER) then
						self:GlueBalloon(v2)
					end
				end
				hits = hits + 1
				if hits >= self.rotgb_Hits then break end
			end
		end
	else
		for i,v in ipairs(gBalloons) do
			if not (v.rotgb_SpeedMods and v.rotgb_SpeedMods.ROTGB_GLUE_TOWER) then
				self:GlueBalloon(v)
				hits = hits + 1
				if hits >= self.rotgb_Hits then break end
			end
		end
	end
end

function ENT:GlueBalloon(balloon)
	if (not balloon:GetBalloonProperty("BalloonBlimp") or self.rotgb_GreatGlue and balloon:GetRgBE()<=37072) and not balloon:GetBalloonProperty("BalloonAqua") then
		local perf,str = coroutine.resume(self.thread,self,balloon)
		if not perf then error(str) end
	else
		balloon:ShowResistEffect(5)
	end
end

function ENT:ROTGB_Think()
	self.ThinkD = self.ThinkD or CurTime()
	self.ThinkC = self.ThinkC or CurTime()
	if CurTime()>self.ThinkD and self.rotgb_GlueDamage>0 then
		self.ThinkD = CurTime() + (self.rotgb_DoubleThink and 0.5 or 1)
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker(self:GetTowerOwner())
		dmginfo:SetInflictor(self)
		dmginfo:SetDamageType(DMG_ACID)
		dmginfo:SetReportedPosition(self:GetShootPos())
		for k,v in pairs(ROTGB_GetBalloons()) do
			v.AcidicList = v.AcidicList or {}
			if v.AcidicList[self] then
				if v.AcidicList[self][2] < CurTime() then
					v.AcidicList[self] = nil
				else
					dmginfo:SetDamage(v.AcidicList[self][1])
					dmginfo:SetDamagePosition(v:LocalToWorld(v:OBBCenter()))
					v:TakeDamageInfo(dmginfo)
				end
			end
		end
	end
	if CurTime()>self.ThinkC and self.rotgb_GlueSlosher then
		self.ThinkC = CurTime() + 0.5
		for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
			if v:GetClass()=="gballoon_base" then
				self:GlueBalloon(v)
			end
		end
	end
end

function ENT:TriggerAbility()
	for k,v in pairs(ROTGB_GetBalloons()) do
		local perf,str = coroutine.resume(self.thread,self,v)
		if not perf then error(str) end
	end
end

if CLIENT then
	local EFFECT = {}
	function EFFECT:Init(data)
		self.entity = data:GetEntity()
		if IsValid(self.entity) then
			self.emitter = ParticleEmitter(self.entity:GetPos(), false)
		end
		self.expiryTime = CurTime() + data:GetHitBox()/10
		self.alternateColor = data:GetFlags() == 1
	end
	function EFFECT:Think()
		if not IsValid(self.entity) or self.expiryTime < CurTime() then
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
		if IsValid(self.emitter) and IsValid(self.entity) --[[and self.nextParticle < CurTime()]] then
			local startPos = VectorRand(self.entity:OBBMins(), self.entity:OBBMaxs())
			startPos:Add(self.entity:GetPos())
			local particle = self.emitter:Add("sprites/orangecore2_gmod", startPos)
			if particle then
				particle:SetColor(self.alternateColor and 63 or 255,255,0)
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
	effects.Register(EFFECT,"gballoon_tower_9_glued")
end