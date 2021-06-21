--[[
Workshop:		https://steamcommunity.com/sharedfiles/filedetails/?id=2523149203
Profile Page:	https://steamcommunity.com/id/Piengineer12
GitHub Page:	https://github.com/Piengineer12/public-addons/tree/master/hacpg
Donate:			https://ko-fi.com/piengineer12

Links above are confirmed working as of 2021-06-21. All dates are in ISO 8601 format. 
VERSION = 1.0.1
VERSION_DATE = 2021-06-21
]]

AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.Category = "HACPG"
ENT.PrintName = "Particle Generator"
ENT.Author = "Piengineer"
ENT.Contact = "https://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Highly Advanced Customizable Particle Generator"
ENT.Instructions = "Use and see."
ENT.Spawnable = true
--ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_OPAQUE
--ENT.DisableDuplicator = false
--ENT.DoNotDuplicate = false
--ENT.IconOverride = "materials/entities/base.png"
--ENT.AutomaticFrameAdvance = false
--ENT.Editable = false
ENT.ClientHACPGVarInfo = {
	{
		name = "Particle Density",
		options = {
			{
				class = "BurstDelay",
				type = "Float",
				min = 0,
				max = 10,
				name = "Burst Delay",
				desc = "Time between bursts."
			},
			{
				class = "ParticlesPerBurst",
				type = "Int",
				min = 1,
				max = 100,
				name = "Particles Per Burst",
				desc = "Number of particles to create per burst."
			},
			{
				class = "BurstDuration",
				type = "Float",
				min = 0,
				max = 10,
				name = "Burst Duration",
				desc = "Amount of time to spend spawning particles within a burst."
			},
		}
	},
	{
		name = "Particle Spawning",
		options = {
			{
				class = "LifeTime",
				type = "Float",
				min = 0,
				max = 10,
				name = "Life Time",
				desc = "How long each particle lasts."
			},
			{
				class = "Origin",
				type = "Vector",
				minmax = false,
				min = -500,
				max = 500,
				name = "Origin Offset",
				desc = "The origin's offset from the center of the emitter."
			},
			{
				class = "SpawnDistance",
				type = "Float",
				min = 0,
				max = 1000,
				name = "Spawn Distance From Origin",
				desc = "Particle spawn distance from the origin of the particle emitter."
			},
			{
				class = "SpawnOffset",
				type = "Vector",
				min = -500,
				max = 500,
				name = "Spawn Offset",
				desc = "The origin's offset from the center of the emitter."
			},
			{
				class = "ParticleAngles",
				type = "Angle",
				name = "Spawn Angle",
				desc = "Angle of particles when spawned. If 2D, only the roll component is used."
			},
		}
	},
	{
		name = "Particle Rendering",
		options = {
			{
				class = "MaterialList",
				type = "MaterialList",
				name = "Materials",
				desc = "Materials that the particles should be animated from. At least 1 material is required."
			},
			{
				class = "3D",
				name = "3D Particles",
				desc = "Allows particles to be rendered in 3D, unlike 2D particles which always face the player."
			},
			{
				class = "StartSize",
				type = "Float",
				min = 0,
				max = 100,
				name = "Starting Size",
				desc = "Size of particles right after spawning."
			},
			{
				class = "EndSize",
				type = "Float",
				min = 0,
				max = 100,
				name = "Ending Size",
				desc = "Size of particles right before dying."
			},
			{
				class = "ParticleColor",
				type = "Color",
				name = "Color",
				desc = "Color of particles. Note that colors are applied subtractively."
			},
			{
				class = "Unlit",
				name = "Always Bright",
				desc = "Causes particles to be unaffected by darkness. Useful on dark maps."
			},
			{
				class = "StartAlpha",
				type = "Int",
				min = 0,
				max = 255,
				name = "Starting Alpha",
				desc = "Opacity of particles right after spawning."
			},
			{
				class = "EndAlpha",
				type = "Int",
				min = 0,
				max = 255,
				name = "Ending Alpha",
				desc = "Opacity of particles right before dying."
			},
			{
				class = "StartLength",
				type = "Float",
				min = 0,
				max = 100,
				name = "Starting Length",
				desc = "Length of particles right after spawning."
			},
			{
				class = "EndLength",
				type = "Float",
				min = 0,
				max = 100,
				name = "Ending Length",
				desc = "Length of particles right before dying."
			}
		}
	},
	{
		name = "Particle Physics",
		options = {
			{
				class = "ParticleVelocity",
				type = "Vector",
				min = -500,
				max = 500,
				name = "Velocity",
				desc = "Particle velocity."
			},
			{
				class = "VelocityFromOrigin",
				type = "Float",
				min = -500,
				max = 500,
				name = "Velocity From Origin",
				desc = "Particle outward velocity from the origin. Negative values cause particles to move towards the origin instead."
			},
			{
				class = "ClockwiseVelocityFromOrigin",
				type = "Float",
				min = -500,
				max = 500,
				name = "Clockwise Velocity From Origin",
				desc = "Particle rightward velocity from the origin. Negative values cause particles to move leftwards instead."
			},
			{
				class = "Acceleration",
				type = "Vector",
				min = -500,
				max = 500,
				name = "Acceleration",
				desc = "Particle acceleration. Can be used to simulate gravity."
			},
			{
				class = "Orbiting",
				name = "Always Adjust Acceleration To Point Towards Origin",
				desc = "Causes particles to orbit around the origin."
			},
			{
				class = "AngularVelocity",
				type = "Angle",
				mul = 10,
				name = "Angular Velocity",
				desc = "Angular velocity of particles. If 2D, only the roll component is used."
			},
			{
				class = "CollisionsEnabled",
				name = "Collisions",
				desc = "Allows particles to collide with terrain."
			},
			{
				class = "Bounciness",
				type = "Float",
				min = 0,
				max = 10,
				name = "Bounciness",
				desc = "Multiplier for velocity after any collision."
			},
			{
				class = "AirResistance",
				type = "Float",
				min = 0,
				max = 100,
				name = "Air Resistance",
				desc = "Multiplier for how much air slows down each particle."
			}
		}
	},
}
ENT.ServerHACPGVarInfo = {}
for k,v in pairs(ENT.ClientHACPGVarInfo) do
	for k2,v2 in pairs(v.options) do
		ENT.ServerHACPGVarInfo[v2.class] = v2.type or "Bool"
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"3D")
	self:NetworkVar("Bool",1,"CollisionsEnabled")
	self:NetworkVar("Bool",2,"Orbiting")
	self:NetworkVar("Bool",3,"Unlit")
	self:NetworkVar("Int",0,"MinParticlesPerBurst")
	self:NetworkVar("Int",1,"MaxParticlesPerBurst")
	self:NetworkVar("Int",2,"MinStartAlpha")
	self:NetworkVar("Int",3,"MaxStartAlpha")
	self:NetworkVar("Int",4,"MinEndAlpha")
	self:NetworkVar("Int",5,"MaxEndAlpha")
	self:NetworkVar("Float",0,"MinBurstDuration")
	self:NetworkVar("Float",1,"MaxBurstDuration")
	self:NetworkVar("Float",2,"MinBurstDelay")
	self:NetworkVar("Float",3,"MaxBurstDelay")
	self:NetworkVar("Float",4,"MinSpawnDistance")
	self:NetworkVar("Float",5,"MaxSpawnDistance")
	self:NetworkVar("Float",6,"MinLifeTime")
	self:NetworkVar("Float",7,"MaxLifeTime")
	self:NetworkVar("Float",8,"MinVelocityFromOrigin")
	self:NetworkVar("Float",9,"MaxVelocityFromOrigin")
	self:NetworkVar("Float",10,"MinBounciness")
	self:NetworkVar("Float",11,"MaxBounciness")
	self:NetworkVar("Float",12,"MinAirResistance")
	self:NetworkVar("Float",13,"MaxAirResistance")
	self:NetworkVar("Float",14,"MinStartSize")
	self:NetworkVar("Float",15,"MaxStartSize")
	self:NetworkVar("Float",16,"MinEndSize")
	self:NetworkVar("Float",17,"MaxEndSize")
	self:NetworkVar("Float",18,"MinStartLength")
	self:NetworkVar("Float",19,"MaxStartLength")
	self:NetworkVar("Float",20,"MinEndLength")
	self:NetworkVar("Float",21,"MaxEndLength")
	self:NetworkVar("Float",22,"MinClockwiseVelocityFromOrigin")
	self:NetworkVar("Float",23,"MaxClockwiseVelocityFromOrigin")
	self:NetworkVar("Vector",0,"Origin")
	self:NetworkVar("Vector",1,"MinSpawnOffset")
	self:NetworkVar("Vector",2,"MaxSpawnOffset")
	self:NetworkVar("Vector",3,"MinParticleColor")
	self:NetworkVar("Vector",4,"MaxParticleColor")
	self:NetworkVar("Vector",5,"MinParticleAngles")
	self:NetworkVar("Vector",6,"MaxParticleAngles")
	self:NetworkVar("Vector",7,"MinParticleVelocity")
	self:NetworkVar("Vector",8,"MaxParticleVelocity")
	self:NetworkVar("Vector",9,"MinAngularVelocity")
	self:NetworkVar("Vector",10,"MaxAngularVelocity")
	self:NetworkVar("Vector",11,"MinAcceleration")
	self:NetworkVar("Vector",12,"MaxAcceleration")
end

function ENT:SpawnFunction(ply, trace, classname)
	if not trace.Hit then return end
	
	local ent = ents.Create(classname)
	ent:Spawn()
	ent:Activate()
	ent:SetSubMaterial(2, "sprites/glow04_noz_gmod")
	ent:SetHACPGVar("ParticlesPerBurst", 10)
	ent:SetHACPGVar("StartAlpha", 255)
	ent:SetHACPGVar("BurstDelay", 1)
	ent:SetHACPGVar("LifeTime", 1)
	ent:SetHACPGVar("ParticleVelocity", Vector(-100,-100,-100), Vector(100,100,100))
	ent:SetHACPGVar("StartSize", 10)
	ent:SetHACPGVar("ParticleColor", Vector(1,1,1))
	ent:SetHACPGVar("Unlit", true)
	ent:SetPos(trace.HitPos+trace.HitNormal*16)
	ent:SetAngles(ply:GetAngles())
	
	return ent
end

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/maxofs2d/cube_tool.mdl")
		self:SetMaterial("models/hacpg_generator")
		self:PhysicsInit(SOLID_VPHYSICS)
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:Wake()
		end
		self:SetUseType(SIMPLE_USE)
			
		if WireLib then
			local inputs, inputTypes = {"Fire"}, {"NORMAL"}
			for i,v in ipairs(self.ClientHACPGVarInfo) do
				for i2,v2 in ipairs(v.options) do
					local class = v2.class
					if v2.type == "Float" or v2.type == "Int" then
						table.insert(inputs, "Min"..class)
						table.insert(inputTypes, "NORMAL")
						table.insert(inputs, "Max"..class)
						table.insert(inputTypes, "NORMAL")
					elseif v2.type == "Vector" or v2.type == "Color" or v2.type == "Angle" then
						if v2.minmax == false then
							table.insert(inputs, class)
							table.insert(inputTypes, "VECTOR")
						else
							table.insert(inputs, "Min"..class)
							table.insert(inputTypes, "VECTOR")
							table.insert(inputs, "Max"..class)
							table.insert(inputTypes, "VECTOR")
						end
					--[[elseif v2.type == "Angle" then
						table.insert(inputs, "Min"..class)
						table.insert(inputTypes, "ANGLE")
						table.insert(inputs, "Max"..class)
						table.insert(inputTypes, "ANGLE")]]
					elseif v2.type == "MaterialList" then
						table.insert(inputs, class)
						table.insert(inputTypes, "STRING")
					else
						table.insert(inputs, class)
						table.insert(inputTypes, "NORMAL")
					end
				end
			end
			self.ValidWiremodInputNames = {}
			for k,v in pairs(inputs) do
				self.ValidWiremodInputNames[v] = true
			end
			self.Inputs = WireLib.CreateSpecialInputs(self, inputs, inputTypes)
			
			-- Had to scrape code from other addons for Wiremod functionality.
			-- Where on earth is the official API documentation anyway?!
			local baseClass = baseclass.Get("base_wire_entity")
			self.OnRemove = baseClass.OnRemove
			self.OnRestore = baseClass.OnRestore
			self.BuildDupeInfo = baseClass.BuildDupeInfo
			self.ApplyDupeInfo = baseClass.ApplyDupeInfo
			self.OnEntityCopyTableFinish = baseClass.OnEntityCopyTableFinish
			self.OnDuplicated = baseClass.OnDuplicated
		end
	end
	if CLIENT then
		self.ParticleEmitters = {}
		self.DeadParticleEmitters = {}
	end
end

function ENT:TriggerInput(input, value)
	if self.ValidWiremodInputNames[input] then
		self:SetHACPGVar(input, value)
	end
end

function ENT:Think()
	if CLIENT then
		if CurTime() > (self.NextBurst or 0) then
			self.NextBurst = CurTime() + self:GetHACPGVar("BurstDelay")
			self:FireBurst()
		end
		--[[if CurTime() > (self.NextAngleParameterCheck or 0) then
			self.NextAngleParameterCheck = CurTime() + 1
			for class,typ in pairs(self.ServerHACPGVarInfo) do
				if typ == "Angle" then
					-- ...
				end
			end
		end]]
		self:DoParticleEmitterThink()
		self:SetNextClientThink(CurTime())
	end
end

function ENT:Use(activator, caller)
	if activator:IsPlayer() then
		net.Start("hacpg")
		net.WriteString("customize_generator")
		net.WriteEntity(self)
		net.Send(activator)
	end
end

function ENT:PreEntityCopy()
	-- this is kind of inefficient
	baseclass.Get("base_wire_entity").PreEntityCopy(self)
	
	-- invalid submaterials are not transferred, but we want to do it anyway
	self.CopyParticleMaterials = {}
	for i=0,31 do
		self.CopyParticleMaterials[i] = self:GetSubMaterial(i)
	end
end

function ENT:PostEntityPaste(...)
	-- again
	baseclass.Get("base_wire_entity").PostEntityPaste(self, ...)
	
	if self.CopyParticleMaterials then
		for i=0,31 do
			self:SetSubMaterial(i, self.CopyParticleMaterials[i])
		end
	end
end

if CLIENT then
	function ENT:OnRemove()
		local particleEmitters = self.ParticleEmitters or {}
		-- Wait! Sometimes OnRemove is lying!
		timer.Simple(1, function()
			if not IsValid(self) then
				for k,v in pairs(particleEmitters) do
					if IsValid(v.emitter) then
						v.emitter:Finish()
					end
				end
			end
		end)
	end
end

--[[function ENT:Draw()
	self:DrawModel()
end]]



if SERVER then
	util.AddNetworkString("hacpg")
end

net.Receive("hacpg", function(length, ply)
	local func = net.ReadString()
	if func == "customize_generator" then
		if SERVER then
			if (ply.HACPG_ExpensiveMessageDelay or 0) > RealTime() then
				return
			end
			local ent = net.ReadEntity()
			if (IsValid(ent) and ent:GetClass()=="hacpg_default_generator") then
				local receivedTable = net.ReadTable()
				--PrintTable(receivedTable)
				for k,v in pairs(receivedTable) do
					if istable(v) then
						if ent.ServerHACPGVarInfo[k]=="MaterialList" then
							local checksOut = true
							for k2,v2 in pairs(v) do
								if not isstring(v2) then
									checksOut = false
								end
							end
							if checksOut then
								for k2,v2 in pairs(v) do
									ent:SetSubMaterial(math.Clamp(k2, 2, 31), v2)
								end
							end
						elseif ent:TypesCheckOut(v[1], ent.ServerHACPGVarInfo[k]) and ent:TypesCheckOut(v[2], ent.ServerHACPGVarInfo[k]) then
							ent:SetHACPGVar(k, v[1], v[2])
						end
					elseif ent:TypesCheckOut(v, ent.ServerHACPGVarInfo[k]) then
						ent:SetHACPGVar(k, v)
					end
				end
			end
			ply.HACPG_ExpensiveMessageDelay = RealTime() + 1
		end
		if CLIENT then
			net.ReadEntity():CreateEditUI()
		end
	end
end)

function ENT:TypesCheckOut(argument, typeStr)
	if not typeStr then return false
	elseif typeStr == "Float" or typeStr == "Int" then
		return isnumber(argument) and (typeStr ~= "Int" or argument % 1 == 0)
	elseif typeStr == "Vector" or typeStr == "Color" or typeStr == "Angle" then
		return isvector(argument)
	--[[elseif typeStr == "Angle" then
		return isangle(argument)]]
	elseif typeStr == "Bool" then
		return isbool(argument)
	end
	return false
end

function ENT:RandomFloat(minFloat, maxFloat)
	return math.random()*(maxFloat-minFloat)+minFloat
end

function ENT:RandomVector(minVector, maxVector)
	local retVector = maxVector-minVector
	retVector.x = retVector.x * math.random()
	retVector.y = retVector.y * math.random()
	retVector.z = retVector.z * math.random()
	retVector:Add(minVector)
	return retVector
end

--[[function ENT:RandomAngle(minAngle, maxAngle)
	local retAngle = maxAngle-minAngle
	retAngle.p = retAngle.p * math.random()
	retAngle.y = retAngle.y * math.random()
	retAngle.r = retAngle.r * math.random()
	retAngle:Add(minAngle)
	return retAngle
end]]

function ENT:VectorToAngle(vector)
	return Angle(vector.x, vector.y, vector.z)
end

function ENT:CreateRandomNormalizedVector()
	for i=1,1000 do
		local vector = VectorRand()
		if vector:LengthSqr() <= 1 and not vector:IsZero() then
			vector:Normalize()
			return vector
		end
	end
	return vector_up
end

local thingsThatDontReturnAFloat = {
	ParticlesPerBurst = "Int", SpawnOffset = "Vector",
	ParticleColor = "Vector", StartAlpha = "Int", EndAlpha = "Int",
	ParticleVelocity = "Vector", Acceleration = "Vector",
	ParticleAngles = "Vector", AngularVelocity = "Vector"
}

function ENT:SetHACPGVar(var, minValue, maxValue)
	local setFunction = self["Set"..var]
	if setFunction then
		setFunction(self, minValue)
	else
		local setFunctionMin = self["SetMin"..var]
		local setFunctionMax = self["SetMax"..var]
		if setFunctionMin and setFunctionMax then
			setFunctionMin(self, minValue)
			setFunctionMax(self, maxValue or minValue)
		end
	end
end

function ENT:GetHACPGVar(var)
	local getFunction = self["Get"..var]
	if getFunction then
		return getFunction(self)
	else
		local getFunctionMin = self["GetMin"..var]
		local getFunctionMax = self["GetMax"..var]
		if getFunctionMin and getFunctionMax then
			local customReturnType = thingsThatDontReturnAFloat[var]
			if customReturnType == "Int" then
				return math.random(getFunctionMin(self), getFunctionMax(self))
			elseif customReturnType == "Vector" then
				return self:RandomVector(getFunctionMin(self), getFunctionMax(self))
			--[[elseif customReturnType == "Angle" then
				return self:RandomAngle(getFunctionMin(self), getFunctionMax(self))]]
			else
				return self:RandomFloat(getFunctionMin(self), getFunctionMax(self))
			end
		end
	end
end

function ENT:GetMaterialList()
	local materials = {}
	for i=2,31 do
		materials[i] = self:GetSubMaterial(i)
	end
	return materials
end

function ENT:FireBurst()
	local emitter = ParticleEmitter(self:LocalToWorld(self:GetHACPGVar("Origin")), self:GetHACPGVar("3D"))
	if IsValid(emitter) then
		table.insert(self.ParticleEmitters, {
			emitter = emitter,
			curParticles = 0,
			maxParticles = self:GetHACPGVar("ParticlesPerBurst"),
			startTime = CurTime(),
			endTime = CurTime()+self:GetHACPGVar("BurstDuration")
		})
	end
end

function ENT:GenerateParticleThinkFunction(emitter)
	local orbitPos = emitter:GetPos()
	local gravityMul
	local materialsNeeded = {}
	for i=2,31 do
		if self:GetSubMaterial(i)~="" then
			materialsNeeded[i-1] = self:GetSubMaterial(i)
		else break
		end
	end
	local materialCount = #materialsNeeded -- cheaper than doing it every frame
	local currentMaterial = materialsNeeded[1]
	return function(particle)
		if not gravityMul then
			gravityMul = particle:GetGravity():Length()*1e4
		end
		if IsValid(self) then
			if self:GetHACPGVar("Orbiting") then
				local gravityVector = orbitPos - particle:GetPos()
				gravityVector:Mul(gravityMul/gravityVector:Length()^3)
				particle:SetGravity(gravityVector)
				--print("[HACPG] particle "..CurTime()..' '..gravityMul..' '..tostring(particle:GetGravity()))
				if materialCount <= 1 then
					particle:SetNextThink(CurTime())
				end
			end
			if materialCount > 1 then
				local materialIndex = math.min(math.floor(materialCount*particle:GetLifeTime()/particle:GetDieTime())+1, materialCount)
				local neededMaterial = materialsNeeded[materialIndex]
				if currentMaterial ~= neededMaterial then
					particle:SetMaterial(neededMaterial)
					currentMaterial = neededMaterial
				end
				particle:SetNextThink(CurTime())
			end
		end
	end
end

function ENT:DoParticleEmitterThink()
	for k,v in pairs(self.ParticleEmitters) do
		if IsValid(v.emitter) then
			local expectedActivations
			if v.endTime - v.startTime <= 0 then
				expectedActivations = v.maxParticles
			else
				expectedActivations = math.min(math.floor(math.Remap(CurTime(), v.startTime, v.endTime, 0, v.maxParticles)), v.maxParticles)
			end
			for i=1, expectedActivations - v.curParticles do
				self:GetEmitterToAddParticle(v.emitter)
			end
			v.curParticles = expectedActivations
			if expectedActivations == v.maxParticles then
				table.insert(self.DeadParticleEmitters, k)
			end
		else
			print("[HACPG] NULL CLuaEmitter - this is not supposed to happen!")
		end
	end
	table.SortDesc(self.DeadParticleEmitters)
	for i,v in ipairs(self.DeadParticleEmitters) do
		self.ParticleEmitters[v].emitter:Finish()
		table.remove(self.ParticleEmitters, v)
	end
	table.Empty(self.DeadParticleEmitters)
end

local rot90 = Angle(0,-90,0)
function ENT:GetEmitterToAddParticle(emitter)
	local spawnPos = Vector(0,0,0)
	local spawnDistance = self:GetHACPGVar("SpawnDistance")
	if spawnDistance ~= 0 then
		spawnPos = self:CreateRandomNormalizedVector()
		spawnPos:Mul(spawnDistance)
	end
	spawnPos:Add(self:GetHACPGVar("SpawnOffset"))
	spawnPos:Add(self:WorldToLocal(emitter:GetPos()))
	local particle = emitter:Add(self:GetSubMaterial(2), self:LocalToWorld(spawnPos))
	if particle then
		local velocity = self:LocalToWorld(spawnPos) - emitter:GetPos()
		velocity:Normalize()
		local upVector = Vector(0,0,1)
		upVector:Rotate(self:GetAngles())
		local velocity2 = upVector:Cross(velocity)
		--velocity2:Rotate(rot90)
		--velocity2:Rotate(self:GetAngles())
		velocity2:Normalize()
		velocity:Mul(self:GetHACPGVar("VelocityFromOrigin"))
		velocity2:Mul(self:GetHACPGVar("ClockwiseVelocityFromOrigin"))
		velocity:Add(velocity2)
		velocity2 = self:GetHACPGVar("ParticleVelocity")
		velocity2:Rotate(self:GetAngles())
		velocity:Add(velocity2)
		local angles = self:LocalToWorldAngles(self:VectorToAngle(self:GetHACPGVar("ParticleAngles")))
		local angularVelocity = self:VectorToAngle(self:GetHACPGVar("AngularVelocity"))
		local particleColor = self:GetHACPGVar("ParticleColor"):ToColor()
		local acceleration = self:GetHACPGVar("Acceleration")
		acceleration:Rotate(self:GetAngles())
		
		particle:SetStartSize(self:GetHACPGVar("StartSize"))
		particle:SetEndSize(self:GetHACPGVar("EndSize"))
		particle:SetStartLength(self:GetHACPGVar("StartLength"))
		particle:SetEndLength(self:GetHACPGVar("EndLength"))
		particle:SetLighting(not self:GetHACPGVar("Unlit"))
		particle:SetColor(particleColor.r, particleColor.g, particleColor.b)
		particle:SetStartAlpha(self:GetHACPGVar("StartAlpha"))
		particle:SetEndAlpha(self:GetHACPGVar("EndAlpha"))
		particle:SetDieTime(self:GetHACPGVar("LifeTime"))
		particle:SetVelocityScale(false)
		particle:SetVelocity(velocity)
		particle:SetGravity(acceleration)
		if emitter:Is3D() then
			particle:SetAngles(angles)
			particle:SetAngleVelocity(angularVelocity)
		else
			particle:SetRoll(angles.r)
			particle:SetRollDelta(angularVelocity.r)
		end
		particle:SetCollide(self:GetHACPGVar("CollisionsEnabled"))
		particle:SetBounce(self:GetHACPGVar("Bounciness"))
		particle:SetAirResistance(self:GetHACPGVar("AirResistance"))
		particle:SetThinkFunction(self:GenerateParticleThinkFunction(emitter))
	end
end



function ENT:CreateDataTable()
	local dataTable = {}
	for k,v in pairs(self.ClientHACPGVarInfo) do
		for k2,v2 in pairs(v.options) do
			local var = v2.class
			local getFunction = self["Get"..var]
			if getFunction then
				dataTable[var] = getFunction(self)
			else
				local getFunctionMin = self["GetMin"..var]
				local getFunctionMax = self["GetMax"..var]
				if getFunctionMin and getFunctionMax then
					dataTable[var] = {getFunctionMin(self), getFunctionMax(self)}
				end
			end
		end
	end
	return dataTable
end

function ENT:SendDataTable(dataTable)
	--PrintTable(dataTable)
	net.Start("hacpg")
	net.WriteString("customize_generator")
	net.WriteEntity(self)
	net.WriteTable(dataTable) -- I'm too lazy to think about this properly...
	net.SendToServer()
end

function ENT:CreateEditUI()
	local ent = self
	local dataTable = ent:CreateDataTable()
	
	local Main = vgui.Create("DFrame")
	Main:SetSize(ScrW()/2, ScrH()/2)
	Main:Center()
	Main:SetSizable(true)
	Main:SetTitle("Particle Generator Settings Editor")
	Main:MakePopup()
	function Main:InsertMinMaxSliders(OptionPanel, name, desc, decimals, minValue, maxValue, minDefault, maxDefault, minFunction, maxFunction)
		local MinSlider, MaxSlider
		
		MinSlider = OptionPanel:Add("DNumSlider")
		MinSlider:SetText("Minimum "..name)
		MinSlider:SetMinMax(minValue, maxValue)
		MinSlider:SetValue(minDefault)
		MinSlider:SetDefaultValue(minDefault)
		MinSlider:SetDecimals(decimals)
		MinSlider:SetDark(true)
		MinSlider:Dock(TOP)
		MinSlider:SetTooltip(desc)
		function MinSlider:OnValueChanged(value)
			if MaxSlider:GetValue() < value then
				MaxSlider:SetValue(value)
			end
			minFunction(value)
		end
		
		MaxSlider = OptionPanel:Add("DNumSlider")
		MaxSlider:SetText("Maximum "..name)
		MaxSlider:SetMinMax(minValue, maxValue)
		MaxSlider:SetValue(maxDefault)
		MaxSlider:SetDefaultValue(maxDefault)
		MaxSlider:SetDecimals(decimals)
		MaxSlider:SetDark(true)
		MaxSlider:Dock(TOP)
		MaxSlider:SetTooltip(desc)
		function MaxSlider:OnValueChanged(value)
			if MinSlider:GetValue() > value then
				MinSlider:SetValue(value)
			end
			maxFunction(value)
		end
	end
	
	if not file.IsDir("hacpg_presets", "DATA") then
		file.CreateDir("hacpg_presets")
	end
	if not file.IsDir("hacpg_presets/examples", "DATA") then
		file.CreateDir("hacpg_presets/examples")
		self:CreateExamples()
	end
	
	local Categories = vgui.Create("DCategoryList", Main)
	Categories:SetTall(ScrH())
	Categories:Dock(FILL)
	function Categories:Paint() end
	
	function Main:Refresh()
		if not IsValid(ent) then return end
		
		Categories:Clear()
		local Category = Categories:Add("Presets")
		local Options = vgui.Create("DPanel")
		Options:DockPadding(2,2,2,2)
		Category:SetContents(Options)
		
		local WarningLabel = Options:Add("DLabel")
		WarningLabel:SetText("Remember that your settings will be lost if you close this window without saving!")
		WarningLabel:SetDark(true)
		WarningLabel:Dock(TOP)
		
		local PresetPanel = Options:Add("DPanel")
		PresetPanel:Dock(TOP)
		
		local LoadButton = PresetPanel:Add("DButton")
		LoadButton:SetText("Load Preset")
		LoadButton:SizeToContentsX(8)
		LoadButton:Dock(RIGHT)
		
		local SaveButton = PresetPanel:Add("DButton")
		SaveButton:SetText("Save Preset")
		SaveButton:SizeToContentsX(8)
		SaveButton:Dock(RIGHT)
		
		local PresetEntry = PresetPanel:Add("DTextEntry")
		PresetEntry:SetPlaceholderText("Preset name...")
		PresetEntry:Dock(FILL)
		PresetEntry.knownPresetNames = {}
		function PresetEntry:ScanFiles(filePath)
			local files, dirs = file.Find("hacpg_presets/"..filePath.."*", "DATA")
			for k,v in pairs(files) do
				self.knownPresetNames[filePath..v:StripExtension()] = true
			end
			for k,v in pairs(dirs) do
				self:ScanFiles(filePath..v..'/')
			end
		end
		function PresetEntry:GetAutoComplete(text)
			local results = {}
			
			for k,v in pairs(PresetEntry.knownPresetNames) do
				if k:StartWith(text:lower()) then
					table.insert(results, k)
				end
			end
			
			return results
		end
		PresetEntry:ScanFiles("")
		
		PresetPanel:SetTall(LoadButton:GetTall())
		function SaveButton:SaveData(fileName, overwrite)
			-- Windows becomes suprisingly unstable if these names are used, better reject these
			local illegalNames = {"con", "prn", "aux", "nul", "lpt1", "lpt2", "lpt3", "lpt4", "com1", "com2", "com3", "com4"}
			local illegal = false
			
			for k,v in pairs(illegalNames) do
				if fileName:match("%W"..v.."%W") then
					illegal = v
					break
				end
			end
			
			if illegal and system.IsWindows() then
				Derma_Message("You can't name a file/folder \""..illegal.."\"!\n(Blame Microsoft)",
				"Save Failed", "#GameUI_OK")
			elseif file.Exists(fileName, "DATA") and not overwrite then
				Derma_Query("Are you sure you want to overwrite this preset?", "Overwrite Preset",
				"Yes", function()
					if IsValid(self) then
						self:SaveData(fileName, true)
					end
				end, "No")
			else
				surface.PlaySound("buttons/button15.wav")
				local dataStr = util.TableToJSON(dataTable)
				local filePath = fileName:GetPathFromFilename()
				if not file.IsDir(filePath, "DATA") then
					file.CreateDir(filePath:sub(1,-2))
				end
				file.Write(fileName, dataStr)
				PresetEntry.knownPresetNames = {}
				PresetEntry:ScanFiles("")
			end
		end
		function SaveButton:DoClick()
			if PresetEntry:GetValue()=="" then
				Derma_Message("Please enter a preset name.","Save Failed","#GameUI_OK")
			else
				local fileName = string.format("hacpg_presets/%s.dat", PresetEntry:GetValue())
				self:SaveData(fileName:lower())
			end
		end
		function LoadButton:DoClick()
			if IsValid(ent) then
				ent:FileLoader(function(fileName)
					if IsValid(Main) then
						local dataStr = file.Read(fileName, "DATA")
						dataTable = util.JSONToTable(dataStr)
						Main:Refresh()
						ent:SendDataTable(dataTable)
					end
				end)
			end
		end
		Category:SetExpanded(false)
		
		for i,v in ipairs(ent.ClientHACPGVarInfo) do
			local Category = Categories:Add(v.name)
			local Options = vgui.Create("DPanel")
			Options:DockPadding(2,2,2,2)
			Category:SetContents(Options)
			
			for i2,v2 in ipairs(v.options) do
				if v2.type == "Float" or v2.type == "Int" then
					local decimals = v2.type == "Int" and 0 or math.Round(4-math.log10(v2.max-v2.min))
					Main:InsertMinMaxSliders(Options, v2.name, v2.desc, decimals, v2.min, v2.max,
					dataTable[v2.class][1], dataTable[v2.class][2],
					function(value) dataTable[v2.class][1] = math.Round(value, decimals) end, function(value) dataTable[v2.class][2] = math.Round(value, decimals) end)
				elseif v2.type == "Vector" then
					local decimals = math.Round(4-math.log10(v2.max-v2.min))
					-- this looks ugly as hell, but I really don't have much of a choice here...
					for i3,v3 in ipairs({{'x'," X"}, {'y'," Y"}, {'z'," Z"}}) do
						local axis = v3[1]
						if v2.minmax ~= false then
							Main:InsertMinMaxSliders(Options, v2.name..v3[2], v2.desc, decimals, v2.min, v2.max,
							dataTable[v2.class][1][axis], dataTable[v2.class][2][axis],
							function(value) dataTable[v2.class][1][axis] = value end, function(value) dataTable[v2.class][2][axis] = value end)
						else
							local Slider = Options:Add("DNumSlider")
							Slider:SetText(v2.name..v3[2])
							Slider:SetMinMax(v2.min, v2.max)
							Slider:SetValue(dataTable[v2.class][axis])
							Slider:SetDefaultValue(dataTable[v2.class][axis])
							Slider:SetDecimals(decimals)
							Slider:SetDark(true)
							Slider:Dock(TOP)
							Slider:SetTooltip(v2.desc)
							function Slider:OnValueChanged(value)
								dataTable[v2.class][axis] = value
							end
						end
					end
				elseif v2.type == "Angle" then
					--[[for i3,v3 in ipairs({{'p'," Pitch"}, {'y'," Yaw"}, {'r'," Roll"}}) do
						local axis = v3[1]
						Main:InsertMinMaxSliders(Options, v2.name..v3[2], 1, axis=='p' and -90 or -179.9, axis=='p' and 90 or 180,
						dataTable[v2.class][1][axis], dataTable[v2.class][2][axis],
						function(value) dataTable[v2.class][1][axis] = value end, function(value) dataTable[v2.class][2][axis] = value end)
					end]]
					for i3,v3 in ipairs({{'x'," Pitch"}, {'y'," Yaw"}, {'z'," Roll"}}) do
						local axis = v3[1]
						Main:InsertMinMaxSliders(Options, v2.name..v3[2], v2.desc, 1, -180*(v2.mul or 1), 180*(v2.mul or 1),
						dataTable[v2.class][1][axis], dataTable[v2.class][2][axis],
						function(value) dataTable[v2.class][1][axis] = value end, function(value) dataTable[v2.class][2][axis] = value end)
					end
				elseif v2.type == "Color" then
					for i3,v3 in ipairs({{'x'," Red"}, {'y'," Green"}, {'z'," Blue"}}) do
						local axis = v3[1]
						Main:InsertMinMaxSliders(Options, v2.name..v3[2], v2.desc, 4, 0, 1,
						dataTable[v2.class][1][axis], dataTable[v2.class][2][axis],
						function(value) dataTable[v2.class][1][axis] = value end, function(value) dataTable[v2.class][2][axis] = value end)
					end
				elseif v2.type == "MaterialList" then
					local Label = Options:Add("DLabel")
					Label:SetText("Animation Material List")
					Label:SetDark(true)
					Label:Dock(TOP)
					Label:SetTooltip(v2.desc)
					
					local ScrollPanel = Options:Add("DScrollPanel")
					ScrollPanel:SetTall(ScrH()/9)
					ScrollPanel:Dock(TOP)
					ScrollPanel:SetTooltip(v2.desc)
					
					local MaterialEntries = ScrollPanel:Add("DIconLayout")
					MaterialEntries:SetSpaceY(0)
					MaterialEntries:SetStretchHeight(true)
					MaterialEntries:Dock(TOP)
					
					for i=2,31 do
						local MaterialDPanel = MaterialEntries:Add("DPanel")
						MaterialDPanel:SetTall(24)
						MaterialDPanel:Dock(TOP)
						
						local BrowserButton = MaterialDPanel:Add("DButton")
						BrowserButton:SetText("Browse...")
						BrowserButton:SizeToContentsX(8)
						BrowserButton:Dock(LEFT)
						
						local MaterialEntry = MaterialDPanel:Add("DTextEntry")
						MaterialEntry:SetText(dataTable[v2.class][i])
						MaterialEntry:Dock(FILL)
						function MaterialEntry:OnChange()
							dataTable[v2.class][i] = self:GetText()
						end
						
						function BrowserButton:DoClick()
							if IsValid(ent) then
								ent:CreateMaterialBrowser(function(material)
									MaterialEntry:SetText(material)
									dataTable[v2.class][i] = material
								end)
							end
						end
					end
				else
					local CheckBox = Options:Add("DCheckBoxLabel")
					CheckBox:SetText(v2.name)
					CheckBox:SetValue(dataTable[v2.class])
					CheckBox:SetDark(true)
					CheckBox:Dock(TOP)
					CheckBox:SetTooltip(v2.desc)
					function CheckBox:OnChange(value)
						dataTable[v2.class] = value
					end
				end
			end
			
			Category:SetExpanded(false)
			--Options:SetTall(ScrH()/6)
		end
	end
	Main:Refresh()
	
	local Accept = Main:Add("DButton")
	Accept:SetText("Set Changes")
	Accept:Dock(BOTTOM)
	function Accept:DoClick()
		surface.PlaySound("buttons/button15.wav")
		if IsValid(ent) then
			ent:SendDataTable(dataTable)
		end
	end
end

function ENT:CreateMaterialBrowser(callback)
	local Main = vgui.Create("DFrame")
	Main:SetSize(640, 480)
	Main:SetTitle("Material Browser")
	Main:Center()
	Main:MakePopup()
	Main:SetSizable(true)
	Main.btnMaxim:SetDisabled(false)
	function Main.btnMaxim:DoClick()
		if Main:GetDraggable() then
			Main.savedPos = {Main:GetPos()}
			Main:SetPos(0, 0)
			Main:SetSize(ScrW(), ScrH())
			Main:SetDraggable(false)
			Main:SetSizable(false)
		else
			Main:SetPos(unpack(Main.savedPos))
			Main:SetSize(640, 480)
			Main:SetDraggable(true)
			Main:SetSizable(true)
		end
	end
	
	local Label = vgui.Create("DLabel", Main)
	Label:SetText("I'd recommend searching through the \"effects\", \"sprites\" or \"particle\" folders to find a good particle image.\n\z
	NOTE: I very strongly recommend using Extended Spawnmenu's material browser and copying the image you want to your clipboard rather than using this, \z
	as there are MAJOR bugs with this browser (including one which keeps creating giant rapidly flickering pixels on the screen!).")
	Label:SetWrap(true)
	Label:SetAutoStretchVertical(true)
	Label:Dock(TOP)
	
	local HorizontalDivider = vgui.Create("DHorizontalDivider", Main)
	HorizontalDivider:Dock(FILL)
	HorizontalDivider:SetLeftWidth(240)
	
	local Browser = vgui.Create("DTree")
	HorizontalDivider:SetLeft(Browser)
	
	local MaterialNode = Browser:AddNode("materials")
	MaterialNode:MakeFolder("materials", "GAME")
	
	local MaterialSelectScroller = vgui.Create("DScrollPanel")
	HorizontalDivider:SetRight(MaterialSelectScroller)
	
	local MaterialSelect = vgui.Create("DIconLayout", MaterialSelectScroller)
	MaterialSelect:Dock(FILL)
	MaterialSelect.nextLoad = RealTime()
	
	function Browser:DoClick()
		local selectedNode = self:GetSelectedItem()
		MaterialSelect:GetMaterialsInFolder(selectedNode:GetFolder())
	end
	function MaterialSelect:GetMaterialsInFolder(folder)
		MaterialSelect:Clear()
		self.materialStrings = {}
		self.lastMaterial = nil
		for i,v in ipairs(file.Find(folder.."/*.vmt", "GAME")) do
			if v:GetExtensionFromFilename() == "vmt" then
				local path = folder:sub(11)..'/'
				table.insert(self.materialStrings, path..v)
			end
		end
	end
	function MaterialSelect:Think()
		if self.materialStrings and self.nextLoad <= RealTime() then
			local k,v = next(self.materialStrings, self.lastMaterial)
			if v then
				local startTime = SysTime()
				local material = Material(v)
				if material:GetShader():lower() ~= "spritecard" then
					local Image = vgui.Create("DImageButton", MaterialSelect)
					Image:SetSize(128, 128)
					Image:SetMaterial(material)
					Image:SetTooltip(v)
					function Image:DoClick()
						Main:Close()
						callback(v)
					end
				end
				self.nextLoad = RealTime() + (SysTime() - startTime)
				self.lastMaterial = k
			else
				self.materialStrings = nil
			end
		end
	end
end

function ENT:FileLoader(callback)
	local ent = self
	
	local FileMain = vgui.Create("DFrame")
	FileMain:SetSize(ScrH()/2,ScrH()/2)
	FileMain:Center()
	FileMain:MakePopup()
	FileMain:SetTitle("File Browser")
	
	local ButtonPanel = vgui.Create("DPanel", FileMain)
	function ButtonPanel:Paint() end
	
	local FileEntry = vgui.Create("DTextEntry", ButtonPanel)
	FileEntry:Dock(FILL)
	FileEntry:SetPlaceholderText("Enter a preset name...")
	
	local OKButton = vgui.Create("DButton", ButtonPanel)
	OKButton:SetText("Load Preset")
	OKButton:SizeToContentsX(8)
	OKButton:SizeToContentsY(8)

	ButtonPanel:SetHeight(OKButton:GetTall())
	ButtonPanel:Dock(BOTTOM)
	
	OKButton:Dock(RIGHT)
	
	local DeleteButton = vgui.Create("DButton", ButtonPanel)
	DeleteButton:SetText("Delete Preset")
	DeleteButton:SizeToContentsX(8)
	DeleteButton:SizeToContentsY(8)
	DeleteButton:Dock(RIGHT)
	function DeleteButton:DoClick()
		local pathFileName = "hacpg_presets/"..FileEntry:GetValue()..".dat"
		if FileEntry:GetValue()=="" then
			Derma_Message("Please enter a preset name.","Load Failed","#GameUI_OK")
		elseif file.Exists(pathFileName, "DATA") then
			Derma_Query("Are you sure you want to delete the preset \""..FileEntry:GetValue().."\"?", "Confirm Deletion",
			"Yes", function()
				if IsValid(FileMain) and IsValid(ent) then
					file.Delete(pathFileName)
					local localPath = pathFileName:GetPathFromFilename()
					local otherThingsInPath = table.Add(file.Find(localPath.."*", "DATA"))
					if table.IsEmpty(otherThingsInPath) and localPath ~= "hacpg_presets/" then
						file.Delete(localPath)
					end
					FileMain:Close()
					ent:FileLoader(callback)
				end
			end, "No")
		else
			Derma_Message("Cannot find preset \""..FileEntry:GetValue().."\".","Load Failed","#GameUI_OK")
		end
	end

	local FileBrowser = vgui.Create("DFileBrowser", FileMain)
	FileBrowser:Dock(FILL)
	FileBrowser:SetPath("DATA")
	FileBrowser:SetBaseFolder("hacpg_presets")
	FileBrowser:SetCurrentFolder("hacpg_presets")
	--FileBrowser:SetOpen(true)
	function FileBrowser:OnSelect(fileName)
		FileEntry:SetText(fileName:sub(15):StripExtension())
	end
	
	function OKButton:DoClick()
		if FileEntry:GetValue()=="" then
			Derma_Message("Please enter a preset name.","Load Failed","#GameUI_OK")
		elseif file.Exists("hacpg_presets/"..FileEntry:GetValue()..".dat", "DATA") then
			callback("hacpg_presets/"..FileEntry:GetValue()..".dat")
			FileMain:Close()
		else
			Derma_Message("Cannot find preset \""..FileEntry:GetValue().."\".","Load Failed","#GameUI_OK")
		end
	end
end

function ENT:CreateExamples()
	local examples = {
		["booster"] = [[{"ParticlesPerBurst":[1.0,1.0],"3D":true,"ParticleVelocity":["[100 0 0]","[100 0 0]"],"EndSize":[50.0,50.0],"AngularVelocity":["[0 0 0]","[0 0 0]"],"BurstDelay":[0.05,0.05],"Orbiting":false,"Bounciness":[0.0,0.0],"CollisionsEnabled":false,"EndAlpha":[0.0,0.0],"AirResistance":[0.0,0.0],"BurstDuration":[0.0,0.0],"Acceleration":["[0 0 0]","[0 0 0]"],"ClockwiseVelocityFromOrigin":[0.0,0.0],"SpawnDistance":[0.0,0.0],"VelocityFromOrigin":[0.0,0.0],"EndLength":[0.0,0.0],"StartLength":[0.0,0.0],"Unlit":true,"LifeTime":[2.0,2.0],"SpawnOffset":["[0 0 0]","[0 0 0]"],"MaterialList":{"2":"effects/select_ring.vmt","3":"","4":"","5":"","6":"","7":"","8":"","9":"","10":"","11":"","12":"","13":"","14":"","15":"","16":"","17":"","18":"","19":"","20":"","21":"","22":"","23":"","24":"","25":"","26":"","27":"","28":"","29":"","30":"","31":""},"Origin":"[8 0 0]","ParticleColor":["[0 0.5 1]","[0 0.5 1]"],"ParticleAngles":["[0 0 0]","[0 0 0]"],"StartSize":[5.0,5.0],"StartAlpha":[255.0,255.0]}]],
		["booster static"] = [[{"ParticlesPerBurst":[1.0,1.0],"3D":true,"ParticleVelocity":["[0 0 0]","[0 0 0]"],"EndSize":[20.0,20.0],"AngularVelocity":["[0 0 0]","[0 0 0]"],"BurstDelay":[0.05,0.05],"Orbiting":false,"Bounciness":[0.0,0.0],"CollisionsEnabled":false,"EndAlpha":[0.0,0.0],"AirResistance":[0.0,0.0],"BurstDuration":[0.0,0.0],"Acceleration":["[0 0 0]","[0 0 0]"],"ClockwiseVelocityFromOrigin":[0.0,0.0],"SpawnDistance":[0.0,0.0],"VelocityFromOrigin":[0.0,0.0],"EndLength":[0.0,0.0],"StartLength":[0.0,0.0],"Unlit":true,"LifeTime":[1.0,1.0],"SpawnOffset":["[0 0 0]","[0 0 0]"],"MaterialList":{"2":"effects/select_ring.vmt","3":"","4":"","5":"","6":"","7":"","8":"","9":"","10":"","11":"","12":"","13":"","14":"","15":"","16":"","17":"","18":"","19":"","20":"","21":"","22":"","23":"","24":"","25":"","26":"","27":"","28":"","29":"","30":"","31":""},"Origin":"[8 0 0]","ParticleColor":["[0 0.5 1]","[0 0.5 1]"],"ParticleAngles":["[0 0 0]","[0 0 0]"],"StartSize":[5.0,5.0],"StartAlpha":[255.0,255.0]}]],
		["fake ball generator"] = [[{"ParticlesPerBurst":[1.0,1.0],"3D":false,"ParticleVelocity":["[-100 -100 200]","[100 100 400]"],"EndSize":[10.0,10.0],"AngularVelocity":["[0 0 0]","[0 0 0]"],"BurstDelay":[0.1,0.1],"Orbiting":false,"Bounciness":[1.0,1.0],"CollisionsEnabled":true,"EndAlpha":[255.0,255.0],"AirResistance":[1.0,1.0],"BurstDuration":[0.0,0.0],"Acceleration":["[0 0 -300]","[0 0 -300]"],"ClockwiseVelocityFromOrigin":[0.0,0.0],"SpawnDistance":[0.0,0.0],"VelocityFromOrigin":[0.0,0.0],"EndLength":[0.0,0.0],"StartLength":[0.0,0.0],"Unlit":true,"LifeTime":[10.0,10.0],"SpawnOffset":["[0 0 0]","[0 0 0]"],"MaterialList":{"2":"sprites/sent_ball.vmt","3":"","4":"","5":"","6":"","7":"","8":"","9":"","10":"","11":"","12":"","13":"","14":"","15":"","16":"","17":"","18":"","19":"","20":"","21":"","22":"","23":"","24":"","25":"","26":"","27":"","28":"","29":"","30":"","31":""},"Origin":"[0 0 0]","ParticleColor":["[0 0 0]","[1 1 1]"],"ParticleAngles":["[0 0 0]","[0 0 0]"],"StartSize":[10.0,10.0],"StartAlpha":[255.0,255.0]}]],
		["purple magic barrier"] = [[{"ParticlesPerBurst":[1.0,1.0],"3D":false,"ParticleVelocity":["[0 0 0]","[0 0 0]"],"EndSize":[5.0,5.0],"AngularVelocity":["[0 0 0]","[0 0 0]"],"BurstDelay":[0.0,0.0],"Orbiting":true,"Bounciness":[0.0,0.0],"CollisionsEnabled":false,"EndAlpha":[0.0,0.0],"AirResistance":[0.0,0.0],"BurstDuration":[0.0,0.0],"Acceleration":["[0 0 -38]","[0 0 -38]"],"ClockwiseVelocityFromOrigin":[100.0,100.0],"SpawnDistance":[40.0,40.0],"VelocityFromOrigin":[0.0,0.0],"EndLength":[0.0,0.0],"StartLength":[0.0,0.0],"Unlit":true,"LifeTime":[10.0,10.0],"SpawnOffset":["[0 0 0]","[0 0 0]"],"MaterialList":{"2":"sprites/glow04_noz_gmod.vmt","3":"","4":"","5":"","6":"","7":"","8":"","9":"","10":"","11":"","12":"","13":"","14":"","15":"","16":"","17":"","18":"","19":"","20":"","21":"","22":"","23":"","24":"","25":"","26":"","27":"","28":"","29":"","30":"","31":""},"Origin":"[0 0 50]","ParticleColor":["[0 0 1]","[1 0 1]"],"ParticleAngles":["[0 0 0]","[0 0 0]"],"StartSize":[5.0,5.0],"StartAlpha":[255.0,255.0]}]],
		["rain maker"] = [[{"ParticlesPerBurst":[20.0,20.0],"3D":false,"ParticleVelocity":["[-10 -10 -500]","[10 10 -500]"],"EndSize":[0.2,0.2],"AngularVelocity":["[0 0 0]","[0 0 0]"],"BurstDelay":[0.0,0.0],"Orbiting":false,"Bounciness":[0.02,0.02],"CollisionsEnabled":true,"EndAlpha":[255.0,255.0],"AirResistance":[0.0,0.0],"BurstDuration":[0.0,0.0],"Acceleration":["[0 0 -500]","[0 0 -500]"],"ClockwiseVelocityFromOrigin":[0.0,0.0],"SpawnDistance":[0.0,0.0],"VelocityFromOrigin":[0.0,0.0],"EndLength":[10.0,10.0],"StartLength":[10.0,10.0],"Unlit":true,"LifeTime":[1.3,1.3],"SpawnOffset":["[-500 -500 500]","[500 500 500]"],"MaterialList":{"2":"effects/laser_tracer","3":"","4":"","5":"","6":"","7":"","8":"","9":"","10":"","11":"","12":"","13":"","14":"","15":"","16":"","17":"","18":"","19":"","20":"","21":"","22":"","23":"","24":"","25":"","26":"","27":"","28":"","29":"","30":"","31":""},"Origin":"[0 0 500]","ParticleColor":["[0 0 0.5]","[0 0.5 1]"],"ParticleAngles":["[0 0 0]","[0 0 0]"],"StartSize":[10.0,10.0],"StartAlpha":[0.0,0.0]}]],
		["rainbow fountain"] = [[{"ParticlesPerBurst":[4.0,4.0],"3D":false,"ParticleVelocity":["[0 0 0]","[0 0 0]"],"EndSize":[0.0,0.0],"AngularVelocity":["[0 0 0]","[0 0 0]"],"BurstDelay":[0.0,0.0],"Orbiting":false,"Bounciness":[0.0,0.5],"CollisionsEnabled":true,"EndAlpha":[255.0,255.0],"AirResistance":[20.0,30.0],"BurstDuration":[0.0,0.0],"Acceleration":["[0 0 -200]","[0 0 -150]"],"ClockwiseVelocityFromOrigin":[0.0,0.0],"SpawnDistance":[0.1,0.1],"VelocityFromOrigin":[150.0,200.0],"EndLength":[0.0,0.0],"StartLength":[0.0,0.0],"Unlit":true,"LifeTime":[3.0,3.0],"SpawnOffset":["[0 0 1]","[0 0 1]"],"MaterialList":{"2":"sprites/blueflare1_noz_gmod.vmt","3":"","4":"","5":"","6":"","7":"","8":"","9":"","10":"","11":"","12":"","13":"","14":"","15":"","16":"","17":"","18":"","19":"","20":"","21":"","22":"","23":"","24":"","25":"","26":"","27":"","28":"","29":"","30":"","31":""},"Origin":"[0 0 8]","ParticleColor":["[0 0 0]","[1 1 1]"],"ParticleAngles":["[0 0 0]","[0 0 0]"],"StartSize":[3.0,3.0],"StartAlpha":[255.0,255.0]}]],
		["rainbow star field"] = [[{"ParticlesPerBurst":[1.0,1.0],"3D":false,"ParticleVelocity":["[0 0 0]","[0 0 0]"],"EndSize":[5.0,5.0],"AngularVelocity":["[0 0 0]","[0 0 0]"],"BurstDelay":[0.0,0.0],"Orbiting":false,"Bounciness":[0.0,0.0],"CollisionsEnabled":false,"EndAlpha":[0.0,0.0],"AirResistance":[0.0,0.0],"BurstDuration":[0.0,0.0],"Acceleration":["[0 0 0]","[0 0 0]"],"ClockwiseVelocityFromOrigin":[0.0,0.0],"SpawnDistance":[0.0,1000.0],"VelocityFromOrigin":[0.0,0.0],"EndLength":[0.0,0.0],"StartLength":[0.0,0.0],"Unlit":true,"LifeTime":[10.0,10.0],"SpawnOffset":["[-500 -500 -500]","[500 500 500]"],"MaterialList":{"2":"effects/yellowflare.vmt","3":"","4":"","5":"","6":"","7":"","8":"","9":"","10":"","11":"","12":"","13":"","14":"","15":"","16":"","17":"","18":"","19":"","20":"","21":"","22":"","23":"","24":"","25":"","26":"","27":"","28":"","29":"","30":"","31":""},"Origin":"[0 0 0]","ParticleColor":["[0.5 0.5 0.5]","[1 1 1]"],"ParticleAngles":["[0 0 -180]","[0 0 180]"],"StartSize":[5.0,5.0],"StartAlpha":[255.0,255.0]}]],
		["rainbow star field ignore walls"] = [[{"ParticlesPerBurst":[1.0,1.0],"3D":false,"ParticleVelocity":["[0 0 0]","[0 0 0]"],"EndSize":[5.0,5.0],"AngularVelocity":["[0 0 0]","[0 0 0]"],"BurstDelay":[0.0,0.0],"Orbiting":false,"Bounciness":[0.0,0.0],"CollisionsEnabled":false,"EndAlpha":[0.0,0.0],"AirResistance":[0.0,0.0],"BurstDuration":[0.0,0.0],"Acceleration":["[0 0 0]","[0 0 0]"],"ClockwiseVelocityFromOrigin":[0.0,0.0],"SpawnDistance":[0.0,1000.0],"VelocityFromOrigin":[0.0,0.0],"EndLength":[0.0,0.0],"StartLength":[0.0,0.0],"Unlit":true,"LifeTime":[10.0,10.0],"SpawnOffset":["[-500 -500 -500]","[500 500 500]"],"MaterialList":{"2":"effects/yellowflare_noz.vmt","3":"","4":"","5":"","6":"","7":"","8":"","9":"","10":"","11":"","12":"","13":"","14":"","15":"","16":"","17":"","18":"","19":"","20":"","21":"","22":"","23":"","24":"","25":"","26":"","27":"","28":"","29":"","30":"","31":""},"Origin":"[0 0 0]","ParticleColor":["[0.5 0.5 0.5]","[1 1 1]"],"ParticleAngles":["[0 0 -180]","[0 0 180]"],"StartSize":[5.0,5.0],"StartAlpha":[255.0,255.0]}]],
		["red bouncing laser"] = [[{"ParticlesPerBurst":[1.0,1.0],"3D":false,"ParticleVelocity":["[500 0 0]","[500 0 0]"],"EndSize":[2.0,2.0],"AngularVelocity":["[0 0 -180]","[0 0 -180]"],"BurstDelay":[0.0,0.0],"Orbiting":false,"Bounciness":[1.0,1.0],"CollisionsEnabled":true,"EndAlpha":[255.0,255.0],"AirResistance":[0.0,0.0],"BurstDuration":[0.0,0.0],"Acceleration":["[0 0 0]","[0 0 0]"],"ClockwiseVelocityFromOrigin":[0.0,0.0],"SpawnDistance":[0.0,0.0],"VelocityFromOrigin":[0.0,0.0],"EndLength":[50.0,50.0],"StartLength":[50.0,50.0],"Unlit":true,"LifeTime":[1.0,1.0],"SpawnOffset":["[0 0 0]","[0 0 0]"],"MaterialList":{"2":"effects/laser_tracer","3":"","4":"","5":"","6":"","7":"","8":"","9":"","10":"","11":"","12":"","13":"","14":"","15":"","16":"","17":"","18":"","19":"","20":"","21":"","22":"","23":"","24":"","25":"","26":"","27":"","28":"","29":"","30":"","31":""},"Origin":"[-15 0 0]","ParticleColor":["[1 0 0]","[1 0.0938 0.0938]"],"ParticleAngles":["[0 0 0]","[0 0 0]"],"StartSize":[2.0,2.0],"StartAlpha":[255.0,255.0]}]],
		["red laser"] = [[{"ParticlesPerBurst":[1.0,1.0],"3D":false,"ParticleVelocity":["[500 0 0]","[500 0 0]"],"EndSize":[2.0,2.0],"AngularVelocity":["[0 0 -180]","[0 0 -180]"],"BurstDelay":[0.0,0.0],"Orbiting":false,"Bounciness":[0.0,0.0],"CollisionsEnabled":true,"EndAlpha":[255.0,255.0],"AirResistance":[0.0,0.0],"BurstDuration":[0.0,0.0],"Acceleration":["[0 0 0]","[0 0 0]"],"ClockwiseVelocityFromOrigin":[0.0,0.0],"SpawnDistance":[0.0,0.0],"VelocityFromOrigin":[0.0,0.0],"EndLength":[100.0,100.0],"StartLength":[100.0,100.0],"Unlit":true,"LifeTime":[1.0,1.0],"SpawnOffset":["[0 0 0]","[0 0 0]"],"MaterialList":{"2":"effects/laser_tracer","3":"","4":"","5":"","6":"","7":"","8":"","9":"","10":"","11":"","12":"","13":"","14":"","15":"","16":"","17":"","18":"","19":"","20":"","21":"","22":"","23":"","24":"","25":"","26":"","27":"","28":"","29":"","30":"","31":""},"Origin":"[-15 0 0]","ParticleColor":["[1 0 0]","[1 0.0938 0.0938]"],"ParticleAngles":["[0 0 0]","[0 0 0]"],"StartSize":[2.0,2.0],"StartAlpha":[255.0,255.0]}]],
		["red super long laser"] = [[{"ParticlesPerBurst":[1.0,1.0],"3D":false,"ParticleVelocity":["[500 0 0]","[500 0 0]"],"EndSize":[2.0,2.0],"AngularVelocity":["[0 0 0]","[0 0 0]"],"BurstDelay":[0.0,0.0],"Orbiting":false,"Bounciness":[0.0,0.0],"CollisionsEnabled":true,"EndAlpha":[255.0,255.0],"AirResistance":[0.0,0.0],"BurstDuration":[0.0,0.0],"Acceleration":["[500 0 0]","[500 0 0]"],"ClockwiseVelocityFromOrigin":[0.0,0.0],"SpawnDistance":[0.0,0.0],"VelocityFromOrigin":[0.0,0.0],"EndLength":[100.0,100.0],"StartLength":[100.0,100.0],"Unlit":true,"LifeTime":[10.0,10.0],"SpawnOffset":["[0 0 0]","[0 0 0]"],"MaterialList":{"2":"effects/laser_tracer","3":"","4":"","5":"","6":"","7":"","8":"","9":"","10":"","11":"","12":"","13":"","14":"","15":"","16":"","17":"","18":"","19":"","20":"","21":"","22":"","23":"","24":"","25":"","26":"","27":"","28":"","29":"","30":"","31":""},"Origin":"[-15 0 0]","ParticleColor":["[1 0 0]","[1 0.0938 0.0938]"],"ParticleAngles":["[0 0 0]","[0 0 0]"],"StartSize":[2.0,2.0],"StartAlpha":[255.0,255.0]}]],
		["rotate indicator"] = [[{"ParticlesPerBurst":[1.0,1.0],"3D":true,"ParticleVelocity":["[0 0 0]","[0 0 0]"],"EndSize":[20.0,20.0],"AngularVelocity":["[0 0 -180]","[0 0 -180]"],"BurstDelay":[2.0,2.0],"Orbiting":false,"Bounciness":[0.0,0.0],"CollisionsEnabled":false,"EndAlpha":[255.0,255.0],"AirResistance":[0.0,0.0],"BurstDuration":[0.0,0.0],"Acceleration":["[0 0 0]","[0 0 0]"],"ClockwiseVelocityFromOrigin":[0.0,0.0],"SpawnDistance":[0.0,0.0],"VelocityFromOrigin":[0.0,0.0],"EndLength":[0.0,0.0],"StartLength":[0.0,0.0],"Unlit":true,"LifeTime":[2.05,2.05],"SpawnOffset":["[0 0 0]","[0 0 0]"],"MaterialList":{"2":"effects/wheel_ring","3":"","4":"","5":"","6":"","7":"","8":"","9":"","10":"","11":"","12":"","13":"","14":"","15":"","16":"","17":"","18":"","19":"","20":"","21":"","22":"","23":"","24":"","25":"","26":"","27":"","28":"","29":"","30":"","31":""},"Origin":"[15 0 0]","ParticleColor":["[1 1 1]","[1 1 1]"],"ParticleAngles":["[0 0 0]","[0 0 0]"],"StartSize":[20.0,20.0],"StartAlpha":[255.0,255.0]}]],
		["simple explosion"] = [[{"ParticlesPerBurst":[100.0,100.0],"3D":false,"ParticleVelocity":["[0 0 0]","[0 0 0]"],"EndSize":[100.0,100.0],"AngularVelocity":["[0 0 0]","[0 0 0]"],"BurstDelay":[2.5,2.5],"Orbiting":false,"Bounciness":[0.0,0.0],"CollisionsEnabled":false,"EndAlpha":[0.0,0.0],"AirResistance":[0.0,0.0],"BurstDuration":[0.0,0.0],"Acceleration":["[0 0 0]","[0 0 0]"],"ClockwiseVelocityFromOrigin":[0.0,0.0],"SpawnDistance":[1.0,1.0],"VelocityFromOrigin":[100.0,150.0],"EndLength":[0.0,0.0],"StartLength":[0.0,0.0],"Unlit":true,"LifeTime":[2.5,2.5],"SpawnOffset":["[0 0 0]","[0 0 0]"],"MaterialList":{"2":"sprites/orangecore1_gmod","3":"","4":"","5":"","6":"","7":"","8":"","9":"","10":"","11":"","12":"","13":"","14":"","15":"","16":"","17":"","18":"","19":"","20":"","21":"","22":"","23":"","24":"","25":"","26":"","27":"","28":"","29":"","30":"","31":""},"Origin":"[0 0 0]","ParticleColor":["[1 0.5 0]","[1 0.5 0]"],"ParticleAngles":["[0 0 0]","[0 0 0]"],"StartSize":[10.0,10.0],"StartAlpha":[255.0,255.0]}]],
		["smoke generator"] = [[{"ParticlesPerBurst":[1.0,1.0],"3D":false,"ParticleVelocity":["[0 0 0]","[0 0 0]"],"EndSize":[100.0,100.0],"AngularVelocity":["[0 0 0]","[0 0 0]"],"BurstDelay":[0.0,0.0],"Orbiting":false,"Bounciness":[1.0,1.0],"CollisionsEnabled":true,"EndAlpha":[0.0,0.0],"AirResistance":[100.0,100.0],"BurstDuration":[0.0,0.0],"Acceleration":["[0 0 -20]","[0 0 -20]"],"ClockwiseVelocityFromOrigin":[0.0,0.0],"SpawnDistance":[1.0,1.0],"VelocityFromOrigin":[200.0,500.0],"EndLength":[0.0,0.0],"StartLength":[0.0,0.0],"Unlit":true,"LifeTime":[10.0,10.0],"SpawnOffset":["[0 0 0]","[0 0 0]"],"MaterialList":{"2":"particles/smokey","3":"","4":"","5":"","6":"","7":"","8":"","9":"","10":"","11":"","12":"","13":"","14":"","15":"","16":"","17":"","18":"","19":"","20":"","21":"","22":"","23":"","24":"","25":"","26":"","27":"","28":"","29":"","30":"","31":""},"Origin":"[0 0 8]","ParticleColor":["[1 1 1]","[1 1 1]"],"ParticleAngles":["[0 0 0]","[0 0 0]"],"StartSize":[10.0,10.0],"StartAlpha":[255.0,255.0]}]],
		["snow maker"] = [[{"ParticlesPerBurst":[2.0,2.0],"3D":false,"ParticleVelocity":["[-10 -10 -120]","[10 10 -120]"],"EndSize":[0.0,0.0],"AngularVelocity":["[0 0 0]","[0 0 0]"],"BurstDelay":[0.0,0.0],"Orbiting":false,"Bounciness":[0.0,0.0],"CollisionsEnabled":true,"EndAlpha":[255.0,255.0],"AirResistance":[0.0,0.0],"BurstDuration":[0.0,0.0],"Acceleration":["[0 0 0]","[0 0 0]"],"ClockwiseVelocityFromOrigin":[0.0,0.0],"SpawnDistance":[0.0,0.0],"VelocityFromOrigin":[0.0,0.0],"EndLength":[0.0,0.0],"StartLength":[0.0,0.0],"Unlit":true,"LifeTime":[10.0,10.0],"SpawnOffset":["[-500 -500 500]","[500 500 500]"],"MaterialList":{"2":"sprites/blueflare1_noz_gmod.vmt","3":"","4":"","5":"","6":"","7":"","8":"","9":"","10":"","11":"","12":"","13":"","14":"","15":"","16":"","17":"","18":"","19":"","20":"","21":"","22":"","23":"","24":"","25":"","26":"","27":"","28":"","29":"","30":"","31":""},"Origin":"[0 0 500]","ParticleColor":["[1 1 1]","[1 1 1]"],"ParticleAngles":["[0 0 0]","[0 0 0]"],"StartSize":[5.0,5.0],"StartAlpha":[0.0,0.0]}]],
	}
	
	for k,v in pairs(examples) do
		file.Write("hacpg_presets/examples/"..k..".dat", v)
	end
end