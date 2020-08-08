AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Firework Launcher"
ENT.Author			= "Piengineer"
ENT.Contact			= "http://steamcommunity.com/id/RandomTNT12/"
ENT.Purpose			= "\"You can keep your eyes closed. Just listen. Ah - here it comes! In five... four... three... two... ONE...!\""
ENT.Instructions	= "Set up a rocket then use. Has wire inputs too."
ENT.Category		= "Minecraft"
ENT.Spawnable		= true
ENT.AdminOnly		= false



if SERVER then
	util.AddNetworkString("minecraft_firework")
end

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "LaunchVelocity")
end

function ENT:SpawnFunction(ply, trace, class)
	if not trace.Hit then return end
	
	local SpawnPos = trace.HitPos + trace.HitNormal * 20
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180
	
	local ent = ents.Create(class)
	ent:SetPos(SpawnPos)
	ent:SetAngles(SpawnAng)
	ent:Spawn()
	ent:Activate()
	ent:SetLaunchVelocity(500)
	
	return ent
end

function ENT:Initialize()
	if not self.Initialized then
		self.Initialized = true
		self:SetModel("models/maxofs2d/cube_tool.mdl")
		self:SetMaterial("models/minecraft_firework_shooter")
		self:SetBodygroup(1, 1)
		if SERVER then
			self:SetUseType(SIMPLE_USE)
			self:PhysicsInit(SOLID_VPHYSICS)
			self:PhysWake()
			
			-- Had to scrape code from other addons for Wiremod functionality.
			-- Where on earth is the official API documentation anyway?!
			if WireLib then
				self.Inputs = WireLib.CreateSpecialInputs(self, {"Fire", "LaunchVelocity"}, {"NORMAL", "NORMAL"})
				
				local baseClass = baseclass.Get("base_wire_entity")
				self.OnRemove = baseClass.OnRemove
				self.OnRestore = baseClass.OnRestore
				self.BuildDupeInfo = baseClass.BuildDupeInfo
				self.ApplyDupeInfo = baseClass.ApplyDupeInfo
				self.PreEntityCopy = baseClass.PreEntityCopy
				self.OnEntityCopyTableFinish = baseClass.OnEntityCopyTableFinish
				self.OnDuplicated = baseClass.OnDuplicated
				self.PostEntityPaste = baseClass.PostEntityPaste
			end
		end
	end
end

function ENT:Think()
	if not self.Initialized then
		self:Initialize()
	end
end

function ENT:AcceptInput(inputname, activator, caller, data)
	if inputname:lower() == "launch" then
		self:Trigger()
	elseif inputname:lower() == "setlaunchvelocity" then
	end
end

function ENT:TriggerInput(input, value)
	if input == "Fire" and tobool(value) then
		self:CreateFirework()
	elseif input == "LaunchVelocity" then
		self:SetLaunchVelocity(value)
	end
end

function ENT:Use(activator, caller, typ, value)
	local crouchState = activator:IsPlayer() and activator:Crouching()
	if self.Firework and not crouchState then
		self:CreateFirework()
	elseif activator:IsPlayer() then
		net.Start("minecraft_firework", true)
		net.WriteString("prompt")
		net.WriteEntity(self)
		net.Send(activator)
		self.SelectingPlayer = activator
	end
end

function ENT:CreateFirework()
	if self.Firework then
		local firework = ents.Create("minecraft_firework_rocket")
		local angs = self:GetAngles()
		local velocityDir = angs:Forward()
		firework:SetPos(self:WorldSpaceCenter() + velocityDir * 24)
		angs.y = angs.y - 90
		firework:SetAngles(angs)
		firework:SetCreator(self:GetCreator())
		firework:SetLifeTime(self.Firework.Duration+1)
		firework.FireworkStars = self.Firework.FireworkStars
		firework:Spawn()
		local physobj = firework:GetPhysicsObject()
		if IsValid(physobj) then
			velocityDir:Mul(self:GetLaunchVelocity())
			physobj:SetVelocity(velocityDir)
		end
	else
		timer.Simple(0.2, function()
			if IsValid(self) then
				for i=1,2 do
					self:EmitSound("minecraft/click.wav", 75, 120)
				end
			end
		end)
	end
end

net.Receive("minecraft_firework", function(length, ply)
	local func = net.ReadString()
	if func == "prompt" and CLIENT then
		local proxEntity = net.ReadEntity()
		MFR_SelectFireworkRocket(function(rocket, velocity)
			if IsValid(proxEntity) then
				proxEntity.Firework = rocket
				local resStr = util.Compress(util.TableToJSON(rocket))
				net.Start("minecraft_firework")
				net.WriteString("receive")
				net.WriteUInt(#resStr, 16)
				net.WriteData(resStr, #resStr)
				net.WriteEntity(proxEntity)
				net.WriteUInt(math.Round(velocity), 32)
				net.SendToServer()
			end
		end, proxEntity:GetLaunchVelocity())
	elseif func == "receive" and SERVER then
		local bytes = net.ReadUInt(16)
		local data = net.ReadData(bytes)
		local ent = net.ReadEntity()
		local velocity = net.ReadUInt(32)
		if (IsValid(ent) and ent:GetClass()=="minecraft_firework_shooter" and ent.SelectingPlayer == ply) then
			ent.Firework = util.JSONToTable(util.Decompress(data))
			ent:SetLaunchVelocity(velocity)
			ent.SelectingPlayer = nil
		end
	end
end)