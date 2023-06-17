AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Sawblade Launcher"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.tower.gballoon_tower_12.purpose"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/mechanics/wheels/wheel_speed_72.mdl")
ENT.FireRate = 1
ENT.Cost = 450
ENT.DetectionRadius = 384
ENT.AttackDamage = 20
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,20)
ENT.UserTargeting = true
ENT.rotgb_Count = math.huge
ENT.rotgb_MaxPierce = 3
ENT.ProjectileSize = 2
ENT.rotgb_Torque = 80e3
ENT.UpgradeReference = {
	{
		-- 2, 2, 2, 3, 3, 8.75 (5/2*3.5)
		Prices = {400,750,1500,6000,17500,200000},
		Funcs = {
			function(self)
				self.ProjectileSize = self.ProjectileSize * 1.5
				self.rotgb_MaxPierce = self.rotgb_MaxPierce * 2
				self.rotgb_Torque = self.rotgb_Torque * 3
			end,
			function(self)
				self.SeeCamo = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 20
			end,
			function(self)
				self.rotgb_Explosive = true
			end,
			function(self)
				self.ProjectileSize = self.ProjectileSize * 1.5
				self.AttackDamage = self.AttackDamage + 80
				self.rotgb_Torque = self.rotgb_Torque * 3
			end,
			function(self)
				self.FireRate = self.FireRate / 2
				self.rotgb_GigaExplosive = true
				self.AttackDamage = self.AttackDamage + 480
			end,
		}
	},
	{
		Prices = {200,750,1250,7500,20000,90000},
		Funcs = {
			function(self)
				self.FireRate = self.FireRate * 1.5
				self.rotgb_Count = 200
			end,
			function(self)
				self.FireRate = self.FireRate * 2
				self.rotgb_Count = self.rotgb_Count - 100
			end,
			function(self)
				self.rotgb_MaxPierce = self.rotgb_MaxPierce * 2
			end,
			function(self)
				self.rotgb_Electric = true
			end,
			function(self)
				self.rotgb_MaxPierce = self.rotgb_MaxPierce * 3
			end,
			function(self)
				self.rotgb_Count = 0
			end,
		}
	}
}
ENT.UpgradeLimits = {6,2}

function ENT:ROTGB_ApplyPerks()
	self.rotgb_MaxPierce = self.rotgb_MaxPierce + hook.Run("GetSkillAmount", "sawbladeLauncherPierce")
end

local rosqrt2 = 1/math.sqrt(2)

local function ExpirySaw(ent,tower)
	ent:EmitSound(string.format("physics/metal/sawblade_stick%u.wav",math.random(3)))
	if tower.rotgb_Explosive then
		local pos = ent:WorldSpaceCenter()
		local dmginfo = tower:CreateDamage()
		if tower.rotgb_GigaExplosive then
			dmginfo:SetDamageType(DMG_GENERIC)
			dmginfo:SetDamage(tower.AttackDamage * 3)
		else
			dmginfo:SetDamageType(DMG_BLAST)
			dmginfo:SetDamage(tower.AttackDamage / 2)
		end
		local effdata = EffectData()
		effdata:SetOrigin(pos)
		util.Effect("HelicopterMegaBomb",effdata,true,true)
		ent:EmitSound("phx/kaboom.wav")
		for k,v in pairs(ents.FindInSphere(pos, 256)) do
			if (tower:ValidTargetIgnoreRange(v) and v:DamageTypeCanDamage(dmginfo:GetDamageType())) then
				tower:DealDamage(v, dmginfo)
				tower.rotgb_Hits = tower.rotgb_Hits + 1
			end
		end
	end
	if IsValid(ent.cbomb) then
		SafeRemoveEntity(ent.cbomb)
	end
	SafeRemoveEntity(ent)
end

local function OnCollision(ent,coldata)
	if not IsValid(ent.Tower) then
		SafeRemoveEntity(ent)
	end
	if math.abs(vector_up:Dot(coldata.HitNormal))<rosqrt2 and coldata.HitEntity:GetClass()~="gballoon_base" then
		ExpirySaw(ent,ent.Tower)
	end
end

function ENT:ROTGB_Initialize()
	if IsValid(self:GetPhysicsObject()) then
		self:GetPhysicsObject():SetMaterial("gmod_ice")
	end
	self.rotgb_Sawblades = {}
end

function ENT:ROTGB_Think()
	for k,v in pairs(self.rotgb_Sawblades) do
		if IsValid(v) then
			local atLeastOne = false
			for k2,v2 in pairs(ents.FindInSphere(v:WorldSpaceCenter(), v:GetModelScale()*24)) do
				if self:ValidTargetIgnoreRange(v2) and not (v.IgnoredgBalloons and v.IgnoredgBalloons[v2:GetCreationID()]) then
					if v.SkipPoppables and v.IgnoredgBalloons then
						v.IgnoredgBalloons[v2:GetCreationID()] = true
					else
						atLeastOne = true
						self:DealDamage(v2, self.AttackDamage, DMG_SLASH)
						
						v.rotgb_MaxPierce = v.rotgb_MaxPierce - 1
						self.rotgb_Hits = (self.rotgb_Hits or 0) + 1
						if self.rotgb_Electric and v2:DamageTypeCanDamage(DMG_SHOCK) then
							self:DealDamage(v2, self.AttackDamage * 3, DMG_SHOCK)
						elseif not v2:DamageTypeCanDamage(DMG_SLASH) then
							v.rotgb_MaxPierce = 0
							self.rotgb_Hits = self.rotgb_Hits - 1
						end
					end
				end
			end
			if v.rotgb_MaxPierce<=0 then
				ExpirySaw(v,self)
			end
			v.SkipPoppables = atLeastOne
		else
			self.rotgb_Sawblades[k] = nil
		end
	end
end

function ENT:FireFunction(tableOfBalloons)
	local pind = 1
	for i=1,(self.rotgb_Hits or 0)>=self.rotgb_Count and 8 or 1 do
		local saw = ents.Create("prop_physics")
		saw:SetPos(self:GetShootPos())
		saw:AddCallback("PhysicsCollide",OnCollision)
		saw:SetModel("models/props_junk/sawblade001a.mdl")
		saw:SetModelScale(self.ProjectileSize)
		saw:SetCollisionGroup(COLLISION_GROUP_WORLD)
		saw:Spawn()
		saw:Activate()
		saw.Tower = self
		saw.rotgb_MaxPierce = self.rotgb_MaxPierce
		if i == 1 then
			saw.IgnoredgBalloons = {}
		end
		if self.rotgb_Explosive then
			local dbomb = ents.Create("prop_dynamic")
			dbomb:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
			dbomb:SetPos(saw:WorldSpaceCenter())
			dbomb:Spawn()
			dbomb:SetParent(saw)
			saw.cbomb = dbomb
		end
		if self.rotgb_Electric then
			saw:SetMaterial("models/alyx/emptool_glow")
		end
		if not IsValid(tableOfBalloons[pind]) then
			pind = 1
		end
		local physobj = saw:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:SetMaterial("gmod_ice")
			physobj:ApplyTorqueCenter(Vector(0, 0, self.rotgb_Torque*(1+math.random())/2))
			local ivel = tableOfBalloons[pind]:WorldSpaceCenter()-self:GetShootPos()
			ivel.z = 0
			ivel:Normalize()
			ivel:Mul(1000+math.random()*100)
			physobj:SetVelocity(ivel)
			pind = pind + 1
		end
		table.insert(self.rotgb_Sawblades,saw)
	end
	if (self.rotgb_Hits or 0)>=self.rotgb_Count then
		self.rotgb_Hits = 0
	end
end