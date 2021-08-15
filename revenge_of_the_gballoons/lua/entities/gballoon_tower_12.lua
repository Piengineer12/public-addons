AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Sawblade Launcher"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "This tower fires sawblades that can cut through multiple gBalloons, especially when placed on straight tracks."
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/mechanics/wheels/wheel_speed_72.mdl")
ENT.FireRate = 1
ENT.Cost = 450
ENT.DetectionRadius = 384
ENT.AttackDamage = 10
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,20)
ENT.UserTargeting = true
ENT.rotgb_MaxPierce = 3
ENT.rotgb_Size = 2
ENT.rotgb_Torque = 80e3
ENT.UpgradeReference = {
	{
		Names = {"BB Module","RF Module","TX Module","C4 Module","PB Module","5X Module"},
		Descs = {
			"Slightly increases the sawblades' size and considerably increases the sawblades' pierce.",
			"Enables the tower to see Hidden gBalloons.",
			"Sawblades deal considerably more damage.",
			"Sawblades explode with triple damage when expiring!",
			"Slightly increases the sawblades' size and tremendously increases damage dealt!",
			"Considerably reduces fire rate, but explosions pop Black gBalloons and deal 5 times more damage! Also colossally increases damage dealt!",
		},
		Prices = {400,1000,1750,5000,15000,500000},
		Funcs = {
			function(self)
				self.rotgb_Size = self.rotgb_Size * 1.5
				self.rotgb_MaxPierce = self.rotgb_MaxPierce * 2
				self.rotgb_Torque = self.rotgb_Torque * 3
			end,
			function(self)
				self.SeeCamo = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 10
			end,
			function(self)
				self.rotgb_Explosive = true
			end,
			function(self)
				self.rotgb_Size = self.rotgb_Size * 1.5
				self.AttackDamage = self.AttackDamage + 40
				self.rotgb_Torque = self.rotgb_Torque * 3
			end,
			function(self)
				self.FireRate = self.FireRate / 2
				self.rotgb_GigaExplosive = true
				self.AttackDamage = self.AttackDamage + 240
			end,
		}
	},
	{
		Names = {"OD Module","OV Module","FX Module","EV Module","DX Module","8X Module"},
		Descs = {
			"Slightly increases fire rate. Once every 200 pops, the tower overdrives, causing 8 sawblades to be released at once.",
			"Considerably increases fire rate. Reduces pops required to overdrive the tower by 100.",
			"Sawblades pierce considerably more gBalloons before shattering.",
			"Sawblades deal 300% electrical damage per impact!",
			"Sawblades pierce tremendously more gBalloons before shattering!",
			"This tower now always overdrives!"
		},
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
ENT.UpgradeLimits = {5,2}

local rosqrt2 = 1/math.sqrt(2)

local function ExpirySaw(ent,tower)
	ent:EmitSound(string.format("physics/metal/sawblade_stick%u.wav",math.random(3)),60)
	if tower.rotgb_Explosive then
		local pos = ent:GetPos()
		local dmginfo = DamageInfo()
		dmginfo:SetAmmoType(game.GetAmmoID("Grenade"))
		dmginfo:SetAttacker(tower:GetTowerOwner())
		dmginfo:SetInflictor(tower)
		if tower.rotgb_GigaExplosive then
			dmginfo:SetDamageType(DMG_GENERIC)
			dmginfo:SetDamage(tower.AttackDamage * 15)
		else
			dmginfo:SetDamageType(DMG_BLAST)
			dmginfo:SetDamage(tower.AttackDamage * 3)
		end
		dmginfo:SetMaxDamage(dmginfo:GetDamage())
		dmginfo:SetReportedPosition(pos)
		local effdata = EffectData()
		effdata:SetMagnitude(2)
		effdata:SetScale(2)
		effdata:SetOrigin(pos)
		effdata:SetStart(pos)
		util.Effect("Explosion",effdata,true,true)
		for k,v in pairs(ents.FindInSphere(pos,256)) do
			if (tower:ValidTargetIgnoreRange(v) and not v:GetBalloonProperty("BalloonBlack")) then
				dmginfo:SetDamagePosition(v:GetPos())
				v:TakeDamageInfo(dmginfo)
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
			for k2,v2 in pairs(ents.FindInSphere(v:GetPos(),v:GetModelScale()*24)) do
				if self:ValidTargetIgnoreRange(v2) and not (v.IgnoredgBalloons and v.IgnoredgBalloons[v2:GetCreationID()]) then
					if v.SkipPoppables and v.IgnoredgBalloons then
						v.IgnoredgBalloons[v2:GetCreationID()] = true
					else
						atLeastOne = true
						local dmginfo = DamageInfo()
						dmginfo:SetAttacker(self:GetTowerOwner())
						dmginfo:SetInflictor(self)
						dmginfo:SetDamageType(DMG_SLASH)
						dmginfo:SetDamage(self.AttackDamage)
						dmginfo:SetMaxDamage(self.AttackDamage)
						dmginfo:SetReportedPosition(v:GetPos())
						dmginfo:SetDamagePosition(v2:GetPos())
						v2:TakeDamageInfo(dmginfo)
						dmginfo:SetDamage(self.AttackDamage)
						v.rotgb_MaxPierce = v.rotgb_MaxPierce - 1
						self.rotgb_Hits = (self.rotgb_Hits or 0) + 1
						if self.rotgb_Electric and not v2:GetBalloonProperty("BalloonPurple") then
							dmginfo:SetDamageType(DMG_SHOCK)
							dmginfo:ScaleDamage(3)
							v2:TakeDamageInfo(dmginfo)
							dmginfo:ScaleDamage(1/3)
						elseif v2:GetBalloonProperty("BalloonGray") then
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
	for i=1,(self.rotgb_Count and (self.rotgb_Hits or 0)>=self.rotgb_Count and 8 or 1) do
		local saw = ents.Create("prop_physics")
		saw:SetPos(self:GetShootPos())
		saw:AddCallback("PhysicsCollide",OnCollision)
		saw:SetModel("models/props_junk/sawblade001a.mdl")
		saw:SetModelScale(self.rotgb_Size)
		saw:Spawn()
		saw:Activate()
		saw:SetCollisionGroup(COLLISION_GROUP_WORLD)
		saw.Tower = self
		saw.rotgb_MaxPierce = self.rotgb_MaxPierce
		if i == 1 then
			saw.IgnoredgBalloons = {}
		end
		if self.rotgb_Explosive then
			local dbomb = ents.Create("prop_dynamic")
			dbomb:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
			dbomb:SetPos(saw:GetPos())
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
			local ivel = tableOfBalloons[pind]:GetPos()-self:GetShootPos()
			ivel.z = 0
			ivel:Normalize()
			ivel:Mul(500+math.random()*50)
			physobj:SetVelocity(ivel)
			pind = pind + 1
		end
		table.insert(self.rotgb_Sawblades,saw)
	end
	if (self.rotgb_Count and (self.rotgb_Hits or 0)>=self.rotgb_Count) then
		self.rotgb_Hits = 0
	end
end