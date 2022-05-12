--[[
Workshop:		N/A
Profile Page:	https://steamcommunity.com/id/Piengineer12
GitHub Page:	https://github.com/Piengineer12/public-addons/tree/master/reactive_physgun
Donate:			https://ko-fi.com/piengineer12

Links above are confirmed working as of 2022-05-12. All dates are in ISO 8601 format.

Version:		0.2.0
]]

local flatMulConVar = CreateConVar("reactive_physgun_mul", "1", FCVAR_ARCHIVE, "Multiplies the amount of reactive force the Physics Gun applies. A value of 0 will disable reactive forces.")
--local ppm2FlyMulConVar = CreateConVar("reactive_physgun_ponyflymul", "0.002", FCVAR_ARCHIVE, "Multiplies the amount of reactive force for flying CPPM or PPM/2 playermodels. Unused if neither are installed.")
local maxMassFactorConVar = CreateConVar("reactive_physgun_maxmassfactor", "15", FCVAR_ARCHIVE, "Maximum multiplier of Physics Gun reactive forces due to object mass.")

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
	for ply, data in pairs(plyReactivePhysguns) do
		local ent = data.ent
		if IsValid(ent) then
			local aimVec = ply:GetAimVector()
			local physObj = ent:GetPhysicsObject()
			local shootPos = ply:GetShootPos()
			local timeToArrive = GetConVar("physgun_timeToArrive"):GetFloat()
			local dampingFactor = GetConVar("physgun_DampingFactor"):GetFloat()
			local frameTime = FrameTime()
			
			local actualGrabPos = ent:LocalToWorld(data.localOffset)
			local addVel = physObj:GetVelocityAtPoint(actualGrabPos)
			addVel:Mul(timeToArrive*dampingFactor)
			actualGrabPos:Add(addVel)
			
			local expectedGrabPos = aimVec
			local addVel = ply:GetVelocity()
			addVel:Mul(frameTime)
			addVel:Add(shootPos)
			if data.distanceRequiresReset then
				local samplingPos = addVel
				local distance = samplingPos:Distance(actualGrabPos)
				data.distance = distance
				data.distanceRequiresReset = false
			end
			expectedGrabPos:Mul(data.distance)
			expectedGrabPos:Add(addVel)
			
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
			local outward = bit.band(keys, IN_WEAPON1) ~= 0
			local inward = bit.band(keys, IN_WEAPON2) ~= 0
			local use = bit.band(keys, IN_USE) ~= 0
			local amount = GetConVar("physgun_wheelspeed"):GetFloat()
			if outward ~= inward then
				amount = amount * (outward and 1 or -1)
				plyReactivePhysguns[ply].distance = plyReactivePhysguns[ply].distance + amount
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