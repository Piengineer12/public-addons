AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Fire Cube"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "This tower creates cones of fire that can set multiple gBalloons alight."
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/props_phx/construct/wood/wood_wire1x1x1.mdl")
ENT.FireRate = 4
ENT.Cost = 550
ENT.DetectionRadius = 256
ENT.LOSOffset = Vector(0,0,24)
ENT.UserTargeting = true
ENT.AbilityCooldown = 15
ENT.AttackDamage = 0
ENT.rotgb_SpreadAngle = 5
ENT.rotgb_Flames = 1
ENT.rotgb_FireDuration = 5
ENT.rotgb_FireUptick = 10
ENT.rotgb_FireDamage = 0
ENT.rotgb_ShrapnelDamage = 0
ENT.UpgradeReference = {
	{
		Names = {"Duck Choke","ConeHead Choke","Twin-Spin","Dragon Trio","Ring of Death","Spontaneous Firestorm Protocol"},
		Descs = {
			"Considerably increases the flamethrower's width, but slightly reduces range.",
			"Tremendously increases the flamethrower's width.",
			"Adds another flamethrower to the tower. The flamethrowers now deal direct damage, but spin clockwise at a moderate velocity.",
			"Adds yet another flamethrower to the tower. Flamethrowers' direct damage is considerably increased and now spin clockwise at a high velocity.",
			"Three more flamethrowers are added. Also tremendously increases the flamethrowers' direct damage.",
			"Once every 15 seconds, shooting at this tower ignites ALL gBalloons currently in the map! Also causes them to be poppable by fires for the fire duration."
		},
		Prices = {150,1250,1750,3500,6500,10000},
		Funcs = {
			function(self)
				self.rotgb_SpreadAngle = self.rotgb_SpreadAngle * 2
				self.DetectionRadius = self.DetectionRadius / 1.5
			end,
			function(self)
				self.rotgb_SpreadAngle = self.rotgb_SpreadAngle * 3
			end,
			function(self)
				self.rotgb_Flames = self.rotgb_Flames + 1
				self.rotgb_FireDamage = self.rotgb_FireDamage + 10
				self.rotgb_AngVel = -60
				if self.rotgb_ShrapnelDamage <= 0 then
					self.UserTargeting = false
				end
				self.FireWhenNoEnemies = true
			end,
			function(self)
				self.rotgb_Flames = self.rotgb_Flames + 1
				self.rotgb_FireDamage = self.rotgb_FireDamage + 10
				self.rotgb_AngVel = -120
			end,
			function(self)
				self.rotgb_Flames = self.rotgb_Flames + 3
				self.rotgb_FireDamage = self.rotgb_FireDamage + 40
			end,
			function(self)
				self.HasAbility = true
			end
		}
	},
	{
		Names = {"Second-hand Diesel","Mysterious Diesel","Fresh Fuel","High-Octane gBalloon Fuel","Super Hot Gasoline","Napalm"},
		Descs = {
			"Considerably increases burning duration, but slightly reduces fire rate.",
			"Tremendously increases burning duration and considerably increases damage over time. However, fire rate is considerably reduced.",
			"Slightly increases range and fires now ignore immunities.",
			"Considerably increases range and tremendously increases fire damage over time.",
			"gBlimps take triple fire damage! Also considerably increases fire rate.",
			"Tremendously increases fire rate, and infinitely increases range and burning duration!"
		},
		Prices = {150,1250,3500,25000,100000,350000},
		Funcs = {
			function(self)
				self.rotgb_FireDuration = self.rotgb_FireDuration * 2
				self.FireRate = self.FireRate / 1.5
			end,
			function(self)
				self.rotgb_FireDuration = self.rotgb_FireDuration * 3
				self.rotgb_FireUptick = self.rotgb_FireUptick + 10
				self.FireRate = self.FireRate / 2
			end,
			function(self)
				self.DetectionRadius = self.DetectionRadius * 1.5
				self.rotgb_AltFire = true
			end,
			function(self)
				self.DetectionRadius = self.DetectionRadius * 2
				self.rotgb_FireUptick = self.rotgb_FireUptick + 40
			end,
			function(self)
				self.rotgb_HeavyFireUptick = 3
				self.FireRate = self.FireRate * 2
			end,
			function(self)
				self.FireRate = self.FireRate * 3
				self.InfiniteRange = true
				self.rotgb_FireDuration = self.rotgb_FireDuration * 1000
			end
		}
	},
	{
		Names = {"Inner Fans","Shrapnel Thrower","Hot Shots","Pressurized Tanks","Really Hot Shots","Basically a Tack Shooter"},
		Descs = {
			"Considerably increases the tower's fire rate, but also slightly reduces the flamethrower's width.",
			"The flamethrower now throws shrapnel towards gBalloons when burning them, even through walls.",
			"Shrapnel can now deal damage to Gray gBalloons and Monochrome gBlimps.",
			"Tremendously increases fire rate and shrapnel damage, but considerably reduces the flamethrower's width.",
			"Colossally increases fire rate, but all flamethrowers are removed. Instead, shrapnel thrown by this tower sets them on fire.",
			"Colossally increases shrapnel damage and all gBalloons within range are hit every shot!",
		},
		Prices = {150,1000,1250,10000,25000,1500000},
		Funcs = {
			function(self)
				self.FireRate = self.FireRate * 2
				self.rotgb_SpreadAngle = self.rotgb_SpreadAngle / 1.5
			end,
			function(self)
				self.rotgb_ShrapnelDamage = self.rotgb_ShrapnelDamage + 10
				self.UserTargeting = true
			end,
			function(self)
				self.rotgb_CanPopGray = true
			end,
			function(self)
				self.FireRate = self.FireRate * 3
				self.rotgb_ShrapnelDamage = self.rotgb_ShrapnelDamage + 20
				self.rotgb_SpreadAngle = self.rotgb_SpreadAngle / 2
			end,
			function(self)
				self.FireRate = self.FireRate * 5
				self.rotgb_Flames = self.rotgb_Flames - 1
				self.rotgb_FlamingShrapnel = true
				self:SetNWVector("OurTurning",vector_origin)
			end,
			function(self)
				self.rotgb_ShrapnelDamage = self.rotgb_ShrapnelDamage + 120
				self.rotgb_MultiShot = true
			end
		}
	}
}
ENT.UpgradeLimits = {6,4,2}

hook.Add("EntityTakeDamage","RotgB_Tower13",function(vic,dmginfo)
	if vic:GetClass()=="gballoon_base" then
		if vic:HasRotgBStatusEffect("unimmune_fireonly") and bit.band(dmginfo:GetDamageType(),DMG_BURN)==DMG_BURN then
			dmginfo:SetDamageType(DMG_GENERIC)
		end
	end
end)

function ENT:ROTGB_Initialize()
	self:SetMaterial("phoenix_storms/metal")
end

function ENT:FireFunction(gBalloons)
	local towerTarget = gBalloons[1]
	self:SetNWFloat("LastFireTime",CurTime())
	local startpos = self:GetShootPos()
	if self.rotgb_ShrapnelDamage > 0 then
		if self.rotgb_MultiShot then
			for k,v in pairs(gBalloons) do
				local uDir = v:LocalToWorld(v:OBBCenter())-startpos
				local bullet = {
					Attacker = self:GetTowerOwner(),
					Damage = 0,
					Distance = self.InfiniteRange and 32767 or self.DetectionRadius*1.5,
					HullSize = 1,
					Num = 1,
					Tracer = 1,
					AmmoType = "357",
					TracerName = "Tracer",
					Dir = uDir,
					Src = startpos
				}
				self:FireBullets(bullet)
				local dmginfo = DamageInfo()
				dmginfo:SetAttacker(self:GetTowerOwner())
				dmginfo:SetInflictor(self)
				dmginfo:SetDamage(self.rotgb_ShrapnelDamage + self.AttackDamage)
				dmginfo:SetDamageType(self.rotgb_CanPopGray and DMG_SNIPER or DMG_BULLET)
				v:TakeDamageInfo(dmginfo)
				if self.rotgb_FlamingShrapnel then
					v:RotgB_Ignite(self.rotgb_FireUptick * (v:GetBalloonProperty("BalloonBlimp") and self.rotgb_HeavyFireUptick or 1), self:GetTowerOwner(), self, self.rotgb_FireDuration)
					if self.rotgb_AltFire then
						v:InflictRotgBStatusEffect("unimmune_fireonly",self.rotgb_FireDuration)
					end
				end
			end
		elseif IsValid(towerTarget) then
			local uDir = towerTarget:LocalToWorld(towerTarget:OBBCenter())-startpos
			local bullet = {
				Attacker = self:GetTowerOwner(),
				Damage = 0,
				Distance = self.InfiniteRange and 32767 or self.DetectionRadius*1.5,
				HullSize = 1,
				Num = 1,
				Tracer = 1,
				AmmoType = "357",
				TracerName = "Tracer",
				Dir = uDir,
				Src = startpos
			}
			self:FireBullets(bullet)
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(self:GetTowerOwner())
			dmginfo:SetInflictor(self)
			dmginfo:SetDamage(self.rotgb_ShrapnelDamage + self.AttackDamage)
			dmginfo:SetDamageType(self.rotgb_CanPopGray and DMG_SNIPER or DMG_BULLET)
			towerTarget:TakeDamageInfo(dmginfo)
		end
	end
	if self.rotgb_Flames >= 1 then
		local fireDir = vector_origin
		if self.rotgb_AngVel then
			self.rotgb_CurrentTurn = self.rotgb_CurrentTurn or Vector(1,0,0)
			self.rotgb_CurrentTurn:Rotate(Angle(0,self.rotgb_AngVel/self.FireRate,0))
			fireDir = self.rotgb_CurrentTurn+vector_origin
		else
			local selection = 2
			while IsValid(towerTarget.RotgBFireEnt) do
				towerTarget = gBalloons[selection]
				if not IsValid(towerTarget) then
					towerTarget = gBalloons[1] break
				end
				selection = selection + 1
			end
			fireDir = self:WorldToLocal(towerTarget:LocalToWorld(towerTarget:OBBCenter()))
		end
		fireDir.z = 0
		fireDir:Normalize()
		self:SetNWVector("OurTurning",fireDir)
		local anglecos = math.cos(math.rad(self.rotgb_SpreadAngle))
		for k,v in pairs(gBalloons) do
			if self:ValidTarget(v) then
				local bpos = self:WorldToLocal(v:LocalToWorld(v:OBBCenter()))
				bpos.z = 0
				bpos:Normalize()
				for i=1,self.rotgb_Flames do
					if bpos:Dot(fireDir) >= anglecos then
						v:RotgB_Ignite(self.rotgb_FireUptick * (v:GetBalloonProperty("BalloonBlimp") and self.rotgb_HeavyFireUptick or 1), self:GetTowerOwner(), self, self.rotgb_FireDuration)
						if self.rotgb_AltFire then
							v:InflictRotgBStatusEffect("unimmune_fireonly",self.rotgb_FireDuration)
						end
						if self.rotgb_FireDamage > 0 then
							local dmginfo = DamageInfo()
							dmginfo:SetAttacker(self:GetTowerOwner())
							dmginfo:SetInflictor(self)
							dmginfo:SetDamage(self.rotgb_FireDamage + self.AttackDamage)
							dmginfo:SetDamageType(DMG_BURN)
							v:TakeDamageInfo(dmginfo)
						end
					end
					bpos:Rotate(Angle(0,360/self.rotgb_Flames,0))
				end
			end
		end
	end
end

local laserMat = Material("trails/laser")
local arrowMat = Material("gui/arrow")
function ENT:ROTGB_Draw()
	local delta = math.Clamp(math.Remap(0.5+self:GetNWFloat("LastFireTime",0)-CurTime(),0.5,0,1,0),0,1)
	local col = Color(255,(delta/2+0.5)*255,delta*255)
	render.SetColorMaterial()
	render.DrawBox(self:GetShootPos(),self:GetAngles(),Vector(-20,-20,-20),Vector(20,20,20),col)
	if not self:GetNWVector("OurTurning",vector_origin):IsZero() and delta > 0 then
		for i=1,self.rotgb_Flames do
			local gdir = self:GetNWVector("OurTurning")+vector_origin
			gdir:Rotate(Angle(0,i*360/self.rotgb_Flames-self.rotgb_SpreadAngle,0))
			render.SetMaterial(laserMat)
			for i=0,2,0.25 do
				render.DrawBeam(self:GetShootPos(),self:LocalToWorld(gdir*(self.InfiniteRange and 32768 or self.DetectionRadius)+self.LOSOffset),4,0,1,Color(255,128,0,delta*255))
				gdir:Rotate(Angle(0,self.rotgb_SpreadAngle*0.25,0))
			end
		end
	end
	if (self.DrawFadeNext or 0)>RealTime() then
		local fadeout = GetConVar("rotgb_range_fade_time"):GetFloat()
		local ConAVal = GetConVar("rotgb_range_alpha"):GetFloat()
		local alpha = math.Clamp(math.Remap(self.DrawFadeNext-RealTime(),fadeout,0,ConAVal,0),0,ConAVal)
		local scol = Color(255,127,0,alpha)
		--local scol = Color(255,127,0)
		--[[render.SetMaterial(laserMat)
		local gdir = Vector(1,0,0)
		for i=1,4 do
			render.DrawBeam(self:GetShootPos(),self:LocalToWorld(gdir*self.DetectionRadius+self.LOSOffset),4,0,1,scol)
			gdir:Rotate(Angle(0,90,0))
		end]]
		local selfang = self:GetAngles()
		--local reqang = (self:GetPos()-LocalPlayer():GetShootPos()):Angle()
		--reqang.p = reqang.p+90
		--reqang.y = reqang.y-90
		selfang.r = selfang.r+90
		--for i=1,2 do
			cam.Start3D2D(self:LocalToWorld(self.LOSOffset+Vector(0,0,GetConVar("rotgb_hoverover_distance"):GetFloat()+16+self:OBBMaxs().z)),selfang,1)
				surface.SetDrawColor(scol)
				surface.SetMaterial(arrowMat)
				surface.DrawTexturedRect(-16,-16,32,32)
				surface.DrawTexturedRect(16,-16,-32,32)
			cam.End3D2D()
			--selfang.y = selfang.y + 90
			--reqang.p = reqang.p + 90
		--end
	end
end

function ENT:TriggerAbility()
	local success
	for index,ent in pairs(ents.GetAll()) do
		if ent:GetClass()=="gballoon_base" then
			ent:InflictRotgBStatusEffect("unimmune_fireonly",self.rotgb_FireDuration)
			ent:RotgB_Ignite(self.rotgb_FireUptick * (ent:GetBalloonProperty("BalloonBlimp") and self.rotgb_HeavyFireUptick or 1), self:GetTowerOwner(), self, self.rotgb_FireDuration)
			success = true
		end
	end
	if not success then return true end
end