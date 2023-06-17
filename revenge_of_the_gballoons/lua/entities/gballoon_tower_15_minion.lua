local gballoon_tower_minion_base = baseclass.Get("gballoon_tower_minion_base")
AddCSLuaFile()

ENT.Model = "models/maxofs2d/motion_sensor.mdl"
ENT.LifeTime = 20

function ENT:GetDetectionRadius()
	local tower = self:GetTower()
	if IsValid(tower) then
		return tower.rotgb_TurretRange
	else
		return self.DetectionRadius or 1
	end
end

function ENT:GetGoalTolerance()
	return self:GetDetectionRadius() / 2
end

function ENT:GetMinionSpeed()
	local tower = self:GetTower()
	if IsValid(tower) then
		return tower.rotgb_TurretSpeed
	else
		return self.MinionSpeed or 1
	end
end

function ENT:GetFireRate()
	local tower = self:GetTower()
	if IsValid(tower) then
		return tower.FireRate
	else
		return self.FireRate or 1
	end
end

function ENT:GetMaxFireRate()
	local tower = self:GetTower()
	if IsValid(tower) then
		return tower.MaxFireRate
	else
		return self.MaxFireRate
	end
end

function ENT:Think()
	gballoon_tower_minion_base.Think(self)
	
	if (SERVER and self:GetLifeTime() <= 1) then
		local effdata = EffectData()
		effdata:SetEntity(self)
		effdata:SetOrigin(self:GetShootPos())
		effdata:SetMagnitude(1)
		effdata:SetScale(0)
		effdata:SetRadius(4)
		util.Effect("Sparks", effdata)
	end
end

function ENT:FireFunction(gBalloon, attackMultiplier)
	local tower = self:GetTower()
	local iscrit = math.random() < tower.rotgb_CritChance
	local damage = tower.AttackDamage * attackMultiplier
	if iscrit then
		damage = damage * tower.rotgb_CritMul
	end
	if self:GetLifeTime() <= 1 then
		damage = damage * tower.rotgb_PostMul
	end
	local dir = gBalloon:WorldSpaceCenter()
	self.loco:FaceTowards(dir)
	if tower.rotgb_TurretLasers then
		local targets = {gBalloon}
		if tower.rotgb_TurretMultihit then
			self.gBTraceData = self.gBTraceData or {
				filter = self,
				mask = MASK_SHOT,
				output = self.lastBalloonTrace
			}
			targets = {}
			local selfpos = self:GetShootPos()
			self.gBTraceData.start = selfpos
			for k,v in pairs(ents.FindInSphere(selfpos, self:GetDetectionRadius())) do
				if tower:ValidTargetIgnoreRange(v) then
					self.gBTraceData.endpos = v:WorldSpaceCenter()
					util.TraceLine(self.gBTraceData)
					if (IsValid(self.lastBalloonTrace.Entity) and self.lastBalloonTrace.Entity:GetClass() == "gballoon_base") then
						table.insert(targets, v)
					end
				end
			end
		end
		for k,v in pairs(targets) do
			if tower.rotgb_TurretBucks then
				tower:AddCash(20, tower:GetTowerOwner())
			end
			if iscrit then
				v:ShowCritEffect()
			end
			tower:LaserAttack(v, damage, 4, {
				startEntity = self,
				startPos = self:GetShootPos(),
				damageType = iscrit and DMG_GENERIC,
				color = iscrit and color_magenta or color_blue,
				sparks = true,
				laser = true,
				scroll = 35
			})
		end
	else
		if tower.rotgb_TurretBucks then
			tower:AddCash(20, tower:GetTowerOwner())
		end
		if iscrit then
			gBalloon:ShowCritEffect()
		end
		if tower.rotgb_Slowdown and gBalloon:GetRgBE() <= gBalloon:GetRgBEByType("gballoon_blimp_green") then
			gBalloon:Slowdown("ROTGB_TOWER_15",0.25,1)
		end
		tower:BulletAttack(gBalloon, damage, {
			startPos = self:GetShootPos(),
			inflictor = self,
			callback = function(attacker, trace, dmginfo)
				local effdata = EffectData()
				effdata:SetEntity(self)
				effdata:SetOrigin(self:GetShootPos())
				util.Effect("ShellEject",effdata,true,true)
				self:EmitSound("weapons/pistol/pistol_fire2.wav",60,100,1,CHAN_WEAPON)
			end,
			damageType = iscrit and DMG_GENERIC
		})
		
		--[[local bulletstruct = {
			Attacker = tower:GetTowerOwner(),
			Damage = damage,
			Force = damage,
			Distance = self:GetDetectionRadius(),
			HullSize = 64,
			Num = 1,
			Tracer = 1,
			AmmoType = "Pistol",
			TracerName = "Tracer",
			Dir = dir,
			Spread = vector_origin,
			Src = self:GetShootPos(),
			IgnoreEntity = self
		}
		bulletstruct.Callback = 
		self:FireBullets(bulletstruct)]]
	end
end