AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Sawblade Launcher"
ENT.Category = "RotgB: Towers"
ENT.Author = "RandomTNT"
ENT.Contact = "http://steamcommunity.com/id/RandomTNT12/"
ENT.Purpose = "Shred those gBalloons!"
ENT.Instructions = ""
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/mechanics/wheels/wheel_speed_72.mdl")
ENT.FireRate = 1
ENT.Cost = 450
ENT.DetectionRadius = 512
ENT.AttackDamage = 10
ENT.UseLOS = true
ENT.LOSOffset = Vector(0,0,20)
ENT.UserTargeting = true
ENT.rotgb_MaxPierce = 3
ENT.rotgb_Size = 2
ENT.rotgb_Torque = 1e5
ENT.UpgradeReference = {
	{
		Names = {"BB Module","RF Module","TX Module","C4 Module","PB Module"},
		Descs = {
			"Slightly increases the sawblades' size and piercing power.",
			"Enables the tower to see Hidden gBalloons.",
			"Sawblades deal slightly more direct damage.",
			"Sawblades explode when expiring!",
			"Considerably increases the sawblades' size and damage dealt!",
		},
		Prices = {300,125,800,1500,9000},
		Funcs = {
			function(self)
				self.rotgb_Size = self.rotgb_Size*1.5
				self.rotgb_MaxPierce = self.rotgb_MaxPierce*5/3
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
				self.rotgb_Size = self.rotgb_Size*1.5
				self.AttackDamage = self.AttackDamage + 20
				self.rotgb_Torque = self.rotgb_Torque * 3
			end,
		}
	},
	{
		Names = {"OD Module","OV Module","FX Module","EV Module","DX Module"},
		Descs = {
			"Very slightly increases the tower's fire rate. Once every 200 pops, the tower overdrives, causing 8 sawblades to be released at once.",
			"Slightly increases fire rate. Reduces pops required to overdrive the tower by 100.",
			"Sawblades pierce considerably more gBalloons before shattering.",
			"Sawblades deal additional electrical damage upon any impact!",
			"Sawblades pierce tremendously more gBalloons before shattering!"
		},
		Prices = {175,250,850,1750,6500},
		Funcs = {
			function(self)
				self.FireRate = self.FireRate*1.15
				self.rotgb_Count = 200
			end,
			function(self)
				self.FireRate = self.FireRate*1.15
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
		dmginfo:SetInflictor(ent)
		dmginfo:SetDamageType(DMG_BLAST)
		dmginfo:SetDamage(10)
		dmginfo:SetMaxDamage(10)
		dmginfo:SetReportedPosition(pos)
		local effdata = EffectData()
		effdata:SetMagnitude(2)
		effdata:SetScale(2)
		effdata:SetOrigin(pos)
		effdata:SetStart(pos)
		util.Effect("Explosion",effdata,true,true)
		for k,v in pairs(ents.FindInSphere(pos,256)) do
			if tower:ValidTarget(v) then
				dmginfo:SetDamagePosition(v:GetPos())
				v:TakeDamageInfo(dmginfo)
				if not v:GetBalloonProperty("BalloonBlack") then
					tower.rotgb_Hits = tower.rotgb_Hits + 1
				end
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
	if math.abs(vector_up:Dot(coldata.HitNormal))<rosqrt2 then
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
			for k2,v2 in pairs(ents.FindInSphere(v:GetPos(),v:GetModelScale()*24)) do
				if self:ValidTarget(v2) then
					local dmginfo = DamageInfo()
					dmginfo:SetAttacker(self:GetTowerOwner())
					dmginfo:SetInflictor(v)
					dmginfo:SetDamageType(DMG_SLASH)
					dmginfo:SetDamage(self.AttackDamage)
					dmginfo:SetMaxDamage(self.AttackDamage)
					dmginfo:SetReportedPosition(v:GetPos())
					dmginfo:SetDamagePosition(v2:GetPos())
					v2:TakeDamageInfo(dmginfo)
					v.rotgb_MaxPierce = v.rotgb_MaxPierce - 1
					self.rotgb_Hits = (self.rotgb_Hits or 0) + 1
					if self.rotgb_Electric and IsValid(v2) then
						dmginfo:SetDamageType(DMG_SHOCK)
						v2:TakeDamageInfo(dmginfo)
					elseif v2:GetBalloonProperty("BalloonGray") then
						v.rotgb_MaxPierce = 0
						self.rotgb_Hits = self.rotgb_Hits - 1
					end
				end
			end
			if v.rotgb_MaxPierce<=0 then
				ExpirySaw(v,self)
			end
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
			physobj:ApplyTorqueCenter(vector_up*self.rotgb_Torque*math.random())
			local ivel = tableOfBalloons[pind]:GetPos()-self:GetShootPos()
			ivel.z = 0
			ivel:Normalize()
			ivel:Mul(500)
			physobj:SetVelocity(ivel)
			pind = pind + 1
		end
		table.insert(self.rotgb_Sawblades,saw)
	end
	if (self.rotgb_Count and (self.rotgb_Hits or 0)>=self.rotgb_Count) then
		self.rotgb_Hits = 0
	end
end

list.Set("NPC","gballoon_tower_12",{
	Name = ENT.PrintName,
	Class = "gballoon_tower_12",
	Category = ENT.Category
})