--[[
Workshop:		N/A
Profile Page:	https://steamcommunity.com/id/Piengineer12
GitHub Page:	https://github.com/Piengineer12/public-addons/tree/master/reactive_physgun
Donate:			https://ko-fi.com/piengineer12

Links above are confirmed working as of 2022-05-12. All dates are in ISO 8601 format.

Version:		0.3.0
]]

local flatMulConVar = CreateConVar("reactive_physgun_mul", "1", FCVAR_ARCHIVE, "Multiplies the amount of reactive force the Physics Gun applies. A value of 0 will disable reactive forces.")
--local ppm2FlyMulConVar = CreateConVar("reactive_physgun_ponyflymul", "0.002", FCVAR_ARCHIVE, "Multiplies the amount of reactive force for flying CPPM or PPM/2 playermodels. Unused if neither are installed.")
local maxMassFactorConVar = CreateConVar("reactive_physgun_maxmassfactor", "15", FCVAR_ARCHIVE, "Maximum multiplier of Physics Gun reactive forces due to object mass.")
local forceAlgorithmConVar = CreateConVar("reactive_physgun_algorithm", "2", FCVAR_ARCHIVE,
[[Sets the algorithm used to determine displacement of expected and actual points.
0: No displacement
1: Tick velocities
2: Expected: tick velocity, Actual: point tick velocity
3: Expected: tick velocity, Actual: dampened point tick velocity]])
local usePredictiveWheelingConVar = CreateConVar("reactive_physgun_predictivewheeling", "0", FCVAR_ARCHIVE,
"Extending / retracting props will adjust predicted distance based on input amount rather than being recalculated after moving the prop.")

local plyReactivePhysguns = {}
hook.Add("OnPhysgunPickup", "ReactivePhysgun", function(ply, ent)
	if flatMulConVar:GetFloat()~=0 then
		local eyeTrace = ply:GetEyeTrace()
		local physObj = ent:GetPhysicsObject()
		if eyeTrace.Entity == ent and IsValid(physObj) then
			local data = {}
			data.ent = ent
			data.localOffset = ent:WorldToLocal(eyeTrace.HitPos)
			data.distance = eyeTrace.HitPos:Distance(ply:GetShootPos())
			data.oldPos = ent:GetPos()
			data.mass = physObj:GetMass()
			
			plyReactivePhysguns[ply] = data
		end
	end
end)

hook.Add("PhysgunDrop", "ReactivePhysgun", function(ply, ent)
	plyReactivePhysguns[ply] = nil
end)

hook.Add("Think", "ReactivePhysgun", function()
	local timeToArrive = GetConVar("physgun_timeToArrive"):GetFloat()
	local dampingFactor = GetConVar("physgun_DampingFactor"):GetFloat()
	local forceAlgorithm = forceAlgorithmConVar:GetInt()
	local frameTime = FrameTime()
	for ply, data in pairs(plyReactivePhysguns) do
		local ent = data.ent
		if IsValid(ent) then
			local aimVec = ply:GetAimVector()
			local physObj = ent:GetPhysicsObject()
			local shootPos = ply:GetShootPos()
			
			local actualGrabPos = ent:LocalToWorld(data.localOffset)
			if forceAlgorithm >= 1 then
				local addVel = forceAlgorithm >= 2 and physObj:GetVelocityAtPoint(actualGrabPos) or physObj:GetVelocity()
				if forceAlgorithm >= 3 then
					addVel:Mul(timeToArrive*dampingFactor)
				else
					addVel:Mul(frameTime)
				end
				actualGrabPos:Add(addVel)
			end
			
			local startGrabPos = shootPos
			if forceAlgorithm >= 1 then
				local addVel = ply:GetVelocity()
				addVel:Mul(frameTime)
				startGrabPos:Add(addVel)
			end
			
			if data.distanceRequiresReset then
				local distance = startGrabPos:Distance(actualGrabPos)
				data.distance = distance
				data.distanceRequiresReset = false
			end
			
			local expectedGrabPos = aimVec
			expectedGrabPos:Mul(data.distance)
			expectedGrabPos:Add(startGrabPos)
			
			local force = actualGrabPos - expectedGrabPos
			local massMul = math.Clamp(data.mass/ply:GetPhysicsObject():GetMass(), 0, maxMassFactorConVar:GetFloat())
			force:Mul(massMul*flatMulConVar:GetFloat())
			
			-- CPPM + PPM/2 flying
			--[[if CPPM and ply:GetMoveType() == MOVETYPE_FLY and ply.Flying then
				force:Mul(ppm2FlyMulConVar:GetFloat())
			elseif PPM2 and ply:IsPonyCached() then
				local data = ply:GetPonyData()
				if (data and data:GetFlightController()) and ply:GetNW2Bool("ppm2_fly") then
					force:Mul(ppm2FlyMulConVar:GetFloat())
				end
			end]]
			
			--[[local frameTime = FrameTime()
			local expectedEntityPos = data.oldPos
			if IsValid(physObj) then
				expectedEntityPos = expectedEntityPos + physObj:GetVelocity() * frameTime
			end
			data.oldPos = ent:GetPos()
			
			local force = expectedEntityPos - ent:GetPos()]]
			
			--local timeToArrive = GetConVar("physgun_timeToArrive"):GetFloat()
			--local vel = physObj:GetVelocity()
			--local plyVel = ply:GetVelocity()
			--local forceLengthSqr = force:LengthSqr()
			
			--addVel:Mul(timeToArrive/2)
			--addVel:Add(vel*-timeToArrive)
			--addVel:Add(ply:GetVelocity()*timeToArrive)
			--force:Mul(1/frameTime)
			--force:Div()
			--force:Add(addVel)
			
			debugoverlay.Cross(actualGrabPos, 10, 0.05, Color(0, 255, 255), true)
			debugoverlay.Cross(expectedGrabPos, 20, 0.05, Color(255, 0, 0), true)
			
			--if forceLengthSqr > 100 then
				--print(force)
				--print(addVel:Length(), (expectedGrabPos - actualGrabPos):Length(), addVel:Dot(force)/addVel:Length()/force:Length())
			--end
			
			ply:SetVelocity(force)
			--print(ent:GetLocalAngularVelocity())
		else
			plyReactivePhysguns[ply] = nil
		end
	end
end)

local payAttentionKeys = bit.bor(IN_USE, IN_WEAPON1, IN_WEAPON2)
hook.Add("PlayerTick", "ReactivePhysgun", function(ply, mv)
	local data = plyReactivePhysguns[ply]
	if data then
		local keys = mv:GetButtons()
		if bit.band(keys, payAttentionKeys) ~= 0 then
			if usePredictiveWheelingConVar:GetBool() then
				local outward = bit.band(keys, IN_WEAPON1) ~= 0
				local inward = bit.band(keys, IN_WEAPON2) ~= 0
				local use = bit.band(keys, IN_USE) ~= 0
				local amount = GetConVar("physgun_wheelspeed"):GetFloat()
				if outward ~= inward then
					amount = amount * (outward and 1 or -1)
					data.distance = data.distance + amount
					--print(amount)
				end
				if use then
					data.distanceRequiresReset = true
					
					--[[data.distance = data.ent:LocalToWorld(data.localOffset):Distance(ply:GetShootPos())
					
					local ent = data.ent
					local aimVec = ply:GetAimVector()
					local physObj = ent:GetPhysicsObject()
					local shootPos = ply:GetShootPos()
					local vel = physObj:GetVelocity()
					
					local expectedGrabPos = ent:LocalToWorld(data.localOffset)
					--expectedGrabPos:Add(vel)
					
					local actualGrabPos = aimVec
					actualGrabPos:Mul(data.distance)
					actualGrabPos:Add(shootPos)
					
					--print(actualGrabPos - expectedGrabPos)]]
				end
			else
				data.distanceRequiresReset = true
			end
		end
	end
end)

--[[hook.Add("KeyRelease", "ReactivePhysgun", function(ply, key)
	local data = plyReactivePhysguns[ply]
	if data and bit.band(key, scrollKeys) ~= 0 and not data.resetting then
		data.resetting = true
		timer.Simple(0.1, function()
			if IsValid(ply) then
				data.resetting = nil
				data.distance = data.ent:LocalToWorld(data.localOffset):Distance(ply:GetShootPos())
			end
		end)
	end
end)]]