AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"

if SERVER then
	AccessorFunc(ENT, "LifeTime", "LifeTime", FORCE_NUMBER)
	AccessorFunc(ENT, "FireRate", "FireRate", FORCE_NUMBER)
	AccessorFunc(ENT, "MinionSpeed", "MinionSpeed", FORCE_NUMBER)
	AccessorFunc(ENT, "MaxFireRate", "MaxFireRate", FORCE_NUMBER)
	AccessorFunc(ENT, "DetectionRadius", "DetectionRadius", FORCE_NUMBER)
	AccessorFunc(ENT, "GoalTolerance", "GoalTolerance", FORCE_NUMBER)
	AccessorFunc(ENT, "Tower", "Tower")
	AccessorFunc(ENT, "Enemy", "Enemy")
end

function ENT:Initialize()
	if SERVER then
		self:SetModel(self.Model)
		self.NextFire = CurTime()
		self:SetHealth(self:GetCreationID())
		self:SetMaxHealth(self:GetCreationID())
		-- COLLISION_GROUP_WORLD makes us collide with bullets, we don't want that here
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetBloodColor(DONT_BLEED)
	end
end

function ENT:GetShootPos()
	return self:WorldSpaceCenter()
end

function ENT:OnInjured(dmginfo)
	dmginfo:SetDamage(0)
	return true
end

function ENT:HaveEnemy()
	local tower = self:GetTower()
	return IsValid(tower) and not tower:IsStunned() and (tower:ValidTargetIgnoreRange(self:GetEnemy()) or self:FindEnemy())
end

function ENT:FindEnemy()
	local tower = self:GetTower()
	
	if not IsValid(tower) then return false end
	self.balloonTable = self.balloonTable or {}
	self.lastBalloonTrace = self.lastBalloonTrace or {}
	table.Empty(self.balloonTable)
	for k,v in pairs(ROTGB_GetBalloons()) do
		if tower:ValidTargetIgnoreRange(v) then
			local mode = tower:GetTargeting()
			if mode==0 then
				self.balloonTable[v] = v:GetDistanceTravelled()
			elseif mode==1 then
				self.balloonTable[v] = -v:GetDistanceTravelled()
			elseif mode==2 then
				self.balloonTable[v] = v:GetRgBE()
			elseif mode==3 then
				self.balloonTable[v] = -v:GetRgBE()
			elseif mode==4 then
				self.balloonTable[v] = v:BoundingRadius()^2/self:GetShootPos():DistToSqr(v:WorldSpaceCenter())
			elseif mode==5 then
				self.balloonTable[v] = -v:BoundingRadius()^2/self:GetShootPos():DistToSqr(v:WorldSpaceCenter())
			elseif mode==6 then
				self.balloonTable[v] = v.loco:GetAcceleration()
			elseif mode==7 then
				self.balloonTable[v] = -v.loco:GetAcceleration()
			end
		end
	end
	if next(self.balloonTable) then
		self:SetEnemy(table.GetWinningKey(self.balloonTable))
		return true
	else return false
	end
end

function ENT:Think()
	if SERVER then
		local tower = self:GetTower()
		
		if IsValid(tower) then
			if tower:GetSpawnerActive() then
				self:SetLifeTime(self:GetLifeTime() - FrameTime())
			end
			
			if self:GetLifeTime() < 0 then
				self:Remove()
			end
			
			if self.StraightMovement and IsValid(self:GetEnemy()) then
				self.loco:Approach(self:GetEnemy():GetPos(), 1)
			end
		else
			self:Remove()
		end
	end
end

function ENT:MoveToEnemy()
	local enemy = self:GetEnemy()
	local path = Path("Chase")
	path:SetMinLookAheadDistance(64)
	path:SetGoalTolerance(self:GetGoalTolerance() or 0)
	path:Compute(self, enemy:GetPos())
	
	local lastComputation = CurTime()
	if not IsValid(path) then
		self.StraightMovement = true
		while not IsValid(path) and self:HaveEnemy() do
			if self:GetEnemy() ~= enemy then break end
			if self:GetShootPos():DistToSqr(enemy:WorldSpaceCenter()) <= self:GetGoalTolerance()^2 then
				self.gBTraceData = self.gBTraceData or {
					filter = self,
					mask = MASK_SHOT,
					output = self.lastBalloonTrace
				}
				self.gBTraceData.start = self:GetShootPos()
				self.gBTraceData.endpos = enemy:WorldSpaceCenter()
				util.TraceLine(self.gBTraceData)
				
				local ent = self.lastBalloonTrace.Entity
				if (IsValid(ent) and ent:GetClass() == "gballoon_base") then break end
			end
			if CurTime() - lastComputation > 0.5 then
				path:Compute(self, enemy:GetPos())
			end
			if self.loco:IsStuck() or (self.WallStuck or 0)>=4 then
				if (self.ResetStuck or 0) < CurTime() then
					self.UnstuckAttempts = 0
				end
				self.UnstuckAttempts = self.UnstuckAttempts + 1
				self.ResetStuck = CurTime() + 10
				if self.UnstuckAttempts == 1 then -- A simple jump should fix it.
					self.loco:Jump()
					path:Compute(self, enemy:GetPos())
					self.loco:ClearStuck()
				elseif self.UnstuckAttempts == 2 then -- That didn't fix it, try to teleport slightly upwards instead.
					self:SetPos(self:GetPos()+vector_up*20)
					self.loco:ClearStuck()
				elseif self.UnstuckAttempts == 3 then -- If not, ask GMod kindly to free us.
					self:HandleStuck()
				else -- If not, just teleport us ahead on the path. (Sanic method)
					self:SetPos(path:GetPositionOnPath(path:GetCursorPosition()+2^self.UnstuckAttempts))
					self.loco:ClearStuck()
				end
			end
			
			local oldPos = self:GetPos()
			coroutine.yield()
			local difference = self:GetPos() - oldPos
			local movedSqr = difference:LengthSqr()
			difference:Add(self:GetPos())
			self.loco:FaceTowards(difference)
			self:DoFireFunction()
			
			if moved==0 then
				self.WallStuck = (self.WallStuck or 0) + 1
				--[[self:LogError("Stuck in a wall, "..self.WallStuck*25 .."% sure.","pathfinding")
				if self.WallStuck>=4 then
					self:LogError("Definitely stuck! Waiting for HandleStuck...","pathfinding")
				end]]
			else
				self.WallStuck = nil
			end
		end
		self.StraightMovement = false
	end
	
	while IsValid(path) and self:HaveEnemy() do
		if self:GetEnemy() ~= enemy then break end
		if self:GetShootPos():DistToSqr(enemy:WorldSpaceCenter()) <= self:GetGoalTolerance()^2 then
			self.gBTraceData = self.gBTraceData or {
				filter = self,
				mask = MASK_SHOT,
				output = self.lastBalloonTrace
			}
			self.gBTraceData.start = self:GetShootPos()
			self.gBTraceData.endpos = enemy:WorldSpaceCenter()
			util.TraceLine(self.gBTraceData)
			
			local ent = self.lastBalloonTrace.Entity
			if (IsValid(ent) and ent:GetClass() == "gballoon_base") then break end
		end
		if CurTime() - lastComputation > 0.5 then
			path:Compute(self, enemy:GetPos())
		end
		path:Chase(self, enemy)
		if self.loco:IsStuck() then
			if (self.ResetStuck or 0) < CurTime() then
				self.UnstuckAttempts = 0
			end
			self.UnstuckAttempts = self.UnstuckAttempts + 1
			self.ResetStuck = CurTime() + 10
			if self.UnstuckAttempts == 1 then -- A simple jump should fix it.
				self.loco:Jump()
				path:Compute(self, enemy:GetPos())
				self.loco:ClearStuck()
			elseif self.UnstuckAttempts == 2 then -- That didn't fix it, try to teleport slightly upwards instead.
				self:SetPos(self:GetPos()+vector_up*20)
				self.loco:ClearStuck()
			elseif self.UnstuckAttempts == 3 then -- If not, ask GMod kindly to free us.
				self:HandleStuck()
			else -- If not, just teleport us ahead on the path. (Sanic method)
				self:SetPos(path:GetPositionOnPath(path:GetCursorPosition()+2^self.UnstuckAttempts))
				self.loco:ClearStuck()
			end
		end
		coroutine.yield()
		self:DoFireFunction()
	end
end

function ENT:RunBehaviour()
	while IsValid(self:GetTower()) do
		if self:HaveEnemy() and not GetConVar("ai_disabled"):GetBool() then
			local speed = self:GetMinionSpeed()
			self.loco:SetDesiredSpeed(speed)
			self.loco:SetAcceleration(speed*5)
			self.loco:SetDeceleration(speed*5)
			
			local result = self:MoveToEnemy()
			if IsValid(self:GetTower()) then
				while self:DoFireFunction() do
					coroutine.yield()
				end
			end
		else
			self.loco:SetDesiredSpeed(0)
			coroutine.wait(0.1)
		end
	end
	self:Remove()
end

function ENT:DoFireFunction()
	local tower = self:GetTower()
	if self:HaveEnemy() and not GetConVar("ai_disabled"):GetBool() and IsValid(tower)
	and self:GetShootPos():DistToSqr(self:GetEnemy():WorldSpaceCenter()) <= self:GetDetectionRadius()^2 then
		if (self.NextFire or 0) < CurTime() then
			local fireRate = self:GetFireRate()
			
			if tower.BonusFireRate then
				fireRate = fireRate * (tower.BonusFireRate or 1)
			end
			
			local fireDelay = 1 / fireRate
			local fireAmplification = 1
			local maxFireRate = self:GetMaxFireRate()
			if (maxFireRate and fireRate > maxFireRate) then
				fireAmplification = fireRate / maxFireRate
				fireDelay = 1 / maxFireRate
			end
			
			self.NextFire = CurTime() + fireDelay
			self.rotgb_Owner = self:GetTower()
			self:FireFunction(self:GetEnemy(), fireAmplification)
		end
		return true
	else
		return false
	end
end

function ENT:FireFunction(gBalloon, attackMultiplier)
end

function ENT:PreEntityCopy()
	self.rotgb_DuplicatorTimeOffset = CurTime()
end

function ENT:PostEntityPaste(ply,ent,tab)
	self:AddTimePhase(CurTime() - (self.rotgb_DuplicatorTimeOffset or CurTime()))
end

function ENT:AddTimePhase(timeToAdd)
	self.NextFire = (self.NextFire or 0) + timeToAdd
	self.ResetStuck = (self.ResetStuck or 0) + timeToAdd
end