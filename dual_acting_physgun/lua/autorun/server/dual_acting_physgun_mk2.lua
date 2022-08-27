-- Mark II re-implements most of Fasteroid's original E2 code into Lua. The original code can be found here:
-- https://github.com/Fasteroid/expression2-public/blob/master/physgun_two-way_coupling.txt
-- Some Wiremod E2 source code was also used for a few things, such as QuaternionToRotationVector.

local ConVarForceMultiplier = CreateConVar("dual_acting_physgun_mk2_mul", "1", FCVAR_ARCHIVE, "Multiplier for the force applied by the Dual-Acting Physgun Mark II system. A value of 0 will disable reactive forces. This does not affect the Dual-Acting Physgun Mark I system.")
local ConVarForceMax = CreateConVar("dual_acting_physgun_mk2_max", "10000", FCVAR_ARCHIVE, "Maximum force applied by the Dual-Acting Physgun Mark II.")
local ConVarWhitelist = CreateConVar("dual_acting_physgun_mk2_whitelist", "prop_physics prop_ragdoll", FCVAR_ARCHIVE,
"Whitelist of classes that trigger the Dual-Acting Physgun Mark II system.")

local shadowEntities = {}

local function QuaternionLengthSquared(q)
	return q[1]*q[1] + q[2]*q[2] + q[3]*q[3] + q[4]*q[4]
end

local function QuaternionMultiply(q1, q2)
	local q1r, q1i, q1j, q1k = q1[1], q1[2], q1[3], q1[4]
	local q2r, q2i, q2j, q2k = q2[1], q2[2], q2[3], q2[4]
	return {
		q1r * q2r - q1i * q2i - q1j * q2j - q1k * q2k,
		q1r * q2i + q1i * q2r + q1j * q2k - q1k * q2j,
		q1r * q2j - q1i * q2k + q1j * q2r + q1k * q2i,
		q1r * q2k + q1i * q2j - q1j * q2i + q1k * q2r
	}
end

local function QuaternionDivide(q1, q2)
	local q1r, q1i, q1j, q1k = q1[1], q1[2], q1[3], q1[4]
	local q2r, q2i, q2j, q2k = q2[1], q2[2], q2[3], q2[4]
	local lengthSquared = QuaternionLengthSquared(q2)
	return {
		(q1r * q2r + q1i * q2i + q1j * q2j + q1k * q2k)/lengthSquared,
		(-q1r * q2i + q1i * q2r - q1j * q2k + q1k * q2j)/lengthSquared,
		(-q1r * q2j + q1i * q2k + q1j * q2r - q1k * q2i)/lengthSquared,
		(-q1r * q2k - q1i * q2j + q1j * q2i + q1k * q2r)/lengthSquared
	}
end

local function AngleToQuaternion(angle)
	local p, y, r = angle:Unpack()
	p = math.rad(p/2)
	y = math.rad(y/2)
	r = math.rad(r/2)
	local qr = {math.cos(r), math.sin(r), 0, 0}
	local qp = {math.cos(p), 0, math.sin(p), 0}
	local qy = {math.cos(y), 0, 0, math.sin(y)}
	return QuaternionMultiply(qy, QuaternionMultiply(qp, qr))
end

-- Returns the rotation vector, where the magnitude for each axis is the angle of rotation in degrees.
-- This is basically copied over from Wiremod's E2 source code by coder0xff.
local function QuaternionToRotationVector(q)
	local lengthSquared = QuaternionLengthSquared(q)
	local componentLengthSquared = lengthSquared - q[1]*q[1]
	if componentLengthSquared == 0 then return vector_origin end
	local ang = 2 * math.deg( math.acos( math.Clamp( q[1] / math.sqrt(lengthSquared), -1, 1 ) ) )
	if ang > 180 then ang = ang - 360 end
	ang = ang / math.sqrt(componentLengthSquared)
	return Vector(q[2] * ang, q[3] * ang, q[4] * ang)
end

-- Turns out ApplyTorqueCenter doesn't do a good enough job at prop rotation,
-- so I've also copied over entity:applyTorque() from Wiremod's E2 source.
local function ApplyTorque(physObj, torque)
	local length = torque:Length()
	local off
	if math.abs(torque.x) > length / 10 or math.abs(torque.z) > length / 10 then
		off = Vector(-torque.z, 0, torque.x)
	else
		off = Vector(-torque.y, torque.x, 0)
	end
	off = off:GetNormal() * length / 2

	local dir = torque:Cross(off)
	dir:Normalize()

	physObj:ApplyForceOffset(dir, off)
	physObj:ApplyForceOffset(-dir, -off)
end

local function ReactivePhysgun2Simulate(ent)
	local realEnt = ent.ReactivePhysgun2RealEntity
	local realPhysObj = IsValid(realEnt) and realEnt:GetPhysicsObject()
	if IsValid(realPhysObj) then
		local ply = ent.ReactivePhysgun2Ply
		local mass = realPhysObj:GetMass()
		
		-- determine target and current positions
		local targetPosition = ent:LocalToWorld(ent.ReactivePhysgun2PhysgunOffset)
		targetPosition:Add(ply:GetVelocity()/10)
		local currentPosition = realEnt:LocalToWorld(ent.ReactivePhysgun2PhysgunOffset)
		currentPosition:Add(realPhysObj:GetVelocityAtPoint(currentPosition)/20)
		currentPosition:Add(realPhysObj:GetVelocity()/10)
		
		-- calculate difference and apply forces
		local force = targetPosition - currentPosition
		force:Mul(mass)
		
		realPhysObj:ApplyForceOffset(force, currentPosition)
		
		local playerForce = -force*ConVarForceMultiplier:GetFloat()
		if playerForce:LengthSqr() > ConVarForceMax:GetFloat()^2 then
			playerForce:Normalize()
			playerForce:Mul(ConVarForceMax:GetFloat())
		end
		playerForce:Div(ply:GetPhysicsObject():GetMass())
		ply:SetVelocity(playerForce)
		
		-- determine target and current angles
		local targetAngle = ent:GetPhysicsObject():GetAngles()
		local currentAngle = realPhysObj:GetAngles()
		
		-- calculate difference and apply force
		local quaternionDifference = QuaternionDivide(AngleToQuaternion(targetAngle), AngleToQuaternion(currentAngle))
		local rawTorque = QuaternionToRotationVector(quaternionDifference)--realPhysObj:WorldToLocalVector(QuaternionToRotationVector(quaternionDifference))
		local torque = rawTorque*100*realPhysObj:GetInertia()--rawTorque*50*realPhysObj:GetInertia()/math.min(3,500/mass)-realPhysObj:GetAngleVelocity()/50000
		local counterTorque = realPhysObj:LocalToWorldVector(realPhysObj:GetAngleVelocity()*10*realPhysObj:GetInertia())
		--local maxTorque = 360
		--realPhysObj:ApplyTorqueCenter((torque*100-realPhysObj:GetAngleVelocity()*10)*realPhysObj:GetInertia()*math.min(3,500/mass))
		--realPhysObj:ApplyTorqueCenter(torque-counterTorque)
		--[[realPhysObj:ApplyTorqueCenter(
			Vector(
				math.Clamp(torque.x, -maxTorque, maxTorque),
				math.Clamp(torque.y, -maxTorque, maxTorque),
				math.Clamp(torque.z, -maxTorque, maxTorque)
			)
		)]]
		ApplyTorque(realPhysObj, torque-counterTorque)
		
		-- debugging
		debugoverlay.Cross(currentPosition, 10, 0.05, Color(0, 255, 255), true)
		debugoverlay.Cross(targetPosition, 20, 0.05, Color(255, 0, 0), true)
		--DebugInfo(0, tostring(realPhysObj:GetInertia()))
		--DebugInfo(1, tostring(torque))
		--DebugInfo(2, tostring(counterTorque))
		--debugoverlay.ScreenText(0.5, 0.5, , 0.05, color_white, true)
	else
		ent:Remove()
	end
end

hook.Add("PhysgunPickup", "ReactivePhysgun2", function(ply, ent)
	if ConVarForceMultiplier:GetFloat()~=0 and string.match('\0'..ConVarWhitelist:GetString()..'\0', "%G"..ent:GetClass().."%G") then
		local physObj = ent:GetPhysicsObject()
		
		if not IsValid(ent.ReactivePhysgun2ShadowEntity) and not ent.IsReactivePhysgun2ShadowEntity and IsValid(physObj) then
			-- quickly make a shadow copy of the entity
			local shadowEnt = ents.Create("prop_physics")
			shadowEnt:SetModel(ent:GetModel())
			shadowEnt:SetAngles(ent:GetAngles())
			shadowEnt:SetPos(ent:GetPos() - ply:GetAimVector())
			shadowEnt:Spawn()
			shadowEnt:SetColor(Color(255, 255, 255, 0))
			shadowEnt:SetRenderMode(RENDERMODE_NONE)
			shadowEnt:DrawShadow(false)
			
			shadowEnt.IsReactivePhysgun2ShadowEntity = true
			shadowEnt.ReactivePhysgun2RealEntity = ent
			shadowEnt:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			ent.ReactivePhysgun2ShadowEntity = shadowEnt
			table.insert(shadowEntities, shadowEnt)
			
			local shadowPhysObj = shadowEnt:GetPhysicsObject()
			if IsValid(shadowPhysObj) then
				-- ...?
			end
		end
		
		if not ent.IsReactivePhysgun2ShadowEntity then return false end
	end
end)

hook.Add("OnPhysgunPickup", "ReactivePhysgun2", function(ply, ent)
	if ent.IsReactivePhysgun2ShadowEntity then
		ent.IsReactivePhysgun2Held = true
		ent.ReactivePhysgun2PhysgunOffset = ent:WorldToLocal(ply:GetEyeTrace().HitPos)
		ent.ReactivePhysgun2Ply = ply
		ent:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
		local physObj = ent.ReactivePhysgun2RealEntity:GetPhysicsObject()
		--ent.ReactivePhysgun2OldGravity = physObj:IsGravityEnabled()
		--physObj:EnableGravity(false)
		physObj:EnableMotion(true)
	end
end)

hook.Add("OnPhysgunFreeze", "ReactivePhysgun2", function(wep, physobj, ent, ply)
	if ent.IsReactivePhysgun2ShadowEntity then
		ent.ReactivePhysgun2RealEntity:GetPhysicsObject():EnableMotion(false)
		local effectData = EffectData()
		effectData:SetEntity(ent.ReactivePhysgun2RealEntity)
		util.Effect("phys_freeze", effectData)
	end
end)

hook.Add("PhysgunDrop", "ReactivePhysgun2", function(ply, ent)
	if ent.IsReactivePhysgun2ShadowEntity then
		--[[if IsValid(ent.ReactivePhysgun2RealEntity) then
			local physObj = ent.ReactivePhysgun2RealEntity:GetPhysicsObject()
			
			if IsValid(physObj) then
				physObj:EnableGravity(ent.ReactivePhysgun2OldGravity)
			end
		end]]
		ent:Remove()
	end
end)

hook.Add("Think", "ReactivePhysgun2", function()
	local hasRemoval = false
	
	for _, shadowEntity in pairs(shadowEntities) do
		if not IsValid(shadowEntity) then
			hasRemoval = true
		elseif CurTime() - shadowEntity:GetCreationTime() > 0.05 and not shadowEntity.IsReactivePhysgun2Held then
			shadowEntity:Remove()
			hasRemoval = true
		elseif shadowEntity.IsReactivePhysgun2Held then
			ReactivePhysgun2Simulate(shadowEntity)
		end
	end
	
	if hasRemoval then
		local regeneratedTable = {}
		for _, shadowEntity in pairs(shadowEntities) do
			if IsValid(shadowEntity) then
				table.insert(regeneratedTable, shadowEntity)
			end
		end
		
		shadowEntities = regeneratedTable
	end
end)