AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "gBalloon Path Object Base Entity"
ENT.Category = "RotgB: Miscellaneous"
ENT.ScriptedEntityType = "entity"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Base entity for physical path objects, mostly the gBalloon Spawner and gBalloon Target."
ENT.Instructions = "This entity cannot be spawned - it is only a base entity."
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Editable = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.DisableDuplicator = false

function ENT:CheckBoolEDTInput(input,suffix,ter)
	if input=="enable"..suffix then
		self["Set"..ter](self, true)
	elseif input=="disable"..suffix then
		self["Set"..ter](self, false)
	elseif input=="toggle"..suffix then
		self["Set"..ter](self, not self["Get"..ter](self))
	end
end

function ENT:KeyValue(key,value)
	if string.sub(key,1,11) == "next_target" then
		local num = (tonumber("0x"..string.sub(key,-1)) or 0) + 1
		self.TempNextTargets = self.TempNextTargets or {}
		self.TempNextTargets[num] = value
	elseif string.sub(key,1,17) == "next_blimp_target" then
		local num = (tonumber("0x"..string.sub(key,-1)) or 0) + 1
		self.TempNextBlimpTargets = self.TempNextBlimpTargets or {}
		self.TempNextBlimpTargets[num] = value
	elseif key=="unspectatable" then
		self:SetUnSpectatable(tobool(value))
		scripted_ents.GetMember("point_rotgb_spectator", "TransmitChangeToSpectatingPlayers")(self)
	elseif key=="start_frozen" then
		self.TempStartFrozen = tobool(value)
	elseif key=="start_hidden" then
		self.TempIsHidden = tobool(value)
	elseif key=="model" then
		self.Model = value
	elseif key=="skin" then
		self.Skin = value
	end
end

function ENT:AcceptInput(input,activator,caller,data)
	if string.sub(input,1,15) == "setnextwaypoint" then
		local num = (tonumber("0x"..string.sub(input,-1)) or 0) + 1
		self["SetNextTarget"..num](self,data~="" and ents.FindByName(data)[1] or NULL)
	elseif string.sub(input,1,20) == "setnextblimpwaypoint" then
		local num = (tonumber("0x"..string.sub(input,-1)) or 0) + 1
		self["SetNextBlimpTarget"..num](self,data~="" and ents.FindByName(data)[1] or NULL)
	elseif input=="enablespectating" then
		self:SetUnSpectatable(false)
	elseif input=="disablespectating" then
		self:SetUnSpectatable(true)
		scripted_ents.GetMember("point_rotgb_spectator", "TransmitChangeToSpectatingPlayers")(self)
	elseif input=="togglespectating" then
		self:SetUnSpectatable(not self:GetUnSpectatable())
		scripted_ents.GetMember("point_rotgb_spectator", "TransmitChangeToSpectatingPlayers")(self)
	elseif input=="enablemotion" then
		self:EnableMotion(true)
	elseif input=="disablemotion" then
		self:EnableMotion(false)
	elseif input=="hide" then
		self:SetNotSolid(true)
		self:SetNoDraw(true)
		self:SetMoveType(MOVETYPE_NOCLIP)
	elseif input=="unhide" then
		self:SetNotSolid(false)
		self:SetNoDraw(false)
		self:SetMoveType(MOVETYPE_VPHYSICS)
	elseif input=="togglehide" then
		if self:GetNoDraw() then
			self:SetNotSolid(false)
			self:SetNoDraw(false)
			self:SetMoveType(MOVETYPE_VPHYSICS)
		else
			self:SetNotSolid(true)
			self:SetNoDraw(true)
			self:SetMoveType(MOVETYPE_NOCLIP)
		end
	end
end

function ENT:Initialize()
	self:SetModel(self.Model or "models/props_c17/streetsign004e.mdl")
	if self.Skin then
		self:SetSkin(self.Skin)
	end
	if self.TempNextTargets then
		for k,v in pairs(self.TempNextTargets) do
			self[string.format("SetNextTarget%u", k)](self,v~="" and ents.FindByName(v)[1] or NULL)
		end
	end
	if self.TempNextBlimpTargets then
		for k,v in pairs(self.TempNextBlimpTargets) do
			self[string.format("SetNextBlimpTarget%u", k)](self,v~="" and ents.FindByName(v)[1] or NULL)
		end
	end
	self:PhysicsInit(SOLID_VPHYSICS)
	local physobj = self:GetPhysicsObject()
	if IsValid(physobj) then
		if self.TempStartFrozen then
			physobj:EnableMotion(false)
		else
			physobj:Wake()
		end
	end
	if self.TempIsHidden then
		self:SetNotSolid(true)
		self:SetNoDraw(true)
		self:SetMoveType(MOVETYPE_NOCLIP)
	end
	self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS 
end

function ENT:PostEntityPaste()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
end