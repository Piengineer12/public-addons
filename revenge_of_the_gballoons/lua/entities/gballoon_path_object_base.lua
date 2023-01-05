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

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "NextTarget1")
	self:NetworkVar("Entity", 1, "NextTarget2")
	self:NetworkVar("Entity", 2, "NextTarget3")
	self:NetworkVar("Entity", 3, "NextTarget4")
	self:NetworkVar("Entity", 4, "NextTarget5")
	self:NetworkVar("Entity", 5, "NextTarget6")
	self:NetworkVar("Entity", 6, "NextTarget7")
	self:NetworkVar("Entity", 7, "NextTarget8")
	self:NetworkVar("Entity", 8, "NextTarget9")
	self:NetworkVar("Entity", 9, "NextTarget10")
	self:NetworkVar("Entity", 10, "NextTarget11")
	self:NetworkVar("Entity", 11, "NextTarget12")
	self:NetworkVar("Entity", 12, "NextTarget13")
	self:NetworkVar("Entity", 13, "NextTarget14")
	self:NetworkVar("Entity", 14, "NextTarget15")
	self:NetworkVar("Entity", 15, "NextTarget16")
	self:NetworkVar("Entity", 16, "NextBlimpTarget1")
	self:NetworkVar("Entity", 17, "NextBlimpTarget2")
	self:NetworkVar("Entity", 18, "NextBlimpTarget3")
	self:NetworkVar("Entity", 19, "NextBlimpTarget4")
	self:NetworkVar("Entity", 20, "NextBlimpTarget5")
	self:NetworkVar("Entity", 21, "NextBlimpTarget6")
	self:NetworkVar("Entity", 22, "NextBlimpTarget7")
	self:NetworkVar("Entity", 23, "NextBlimpTarget8")
	self:NetworkVar("Entity", 24, "NextBlimpTarget9")
	self:NetworkVar("Entity", 25, "NextBlimpTarget10")
	self:NetworkVar("Entity", 26, "NextBlimpTarget11")
	self:NetworkVar("Entity", 27, "NextBlimpTarget12")
	self:NetworkVar("Entity", 28, "NextBlimpTarget13")
	self:NetworkVar("Entity", 29, "NextBlimpTarget14")
	self:NetworkVar("Entity", 30, "NextBlimpTarget15")
	self:NetworkVar("Entity", 31, "NextBlimpTarget16")
end

function ENT:KeyValue(lkey,value)
	-- key is already lowercased here
	if lkey=="unspectatable" then
		self:SetUnSpectatable(tobool(value))
		scripted_ents.GetMember("point_rotgb_spectator", "TransmitChangeToSpectatingPlayers")(self)
	elseif lkey=="start_frozen" then
		self.TempStartFrozen = tobool(value)
	elseif lkey=="start_hidden" then
		self.TempIsHidden = tobool(value)
	elseif lkey=="solid" then
		self:SetCollisionGroup(tobool(value) and COLLISION_GROUP_WORLD or COLLISION_GROUP_NONE)
	elseif lkey=="model" then
		self.Model = value
	elseif lkey=="skin" then
		self.Skin = value
	elseif value ~= "" then
		if string.match(lkey, "^target_%d+$") then
			local num = tonumber(string.match(lkey, "^target_(%d+)$"))
			if num then
				self.TempNextTargets = self.TempNextTargets or {}
				self.TempNextTargets[num] = value
			end
		elseif string.match(lkey, "^blimp_target_%d+$") then
			local num = tonumber(string.match(lkey, "^blimp_target_(%d+)$"))
			if num then
				self.TempNextBlimpTargets = self.TempNextBlimpTargets or {}
				self.TempNextBlimpTargets[num] = value
			end
		elseif string.sub(lkey,1,11) == "next_target" then
			local num = (tonumber("0x"..string.sub(lkey,-1)) or 0) + 1
			self.TempNextTargets = self.TempNextTargets or {}
			self.TempNextTargets[num] = value
			
			local name = self:GetName() ~= "" and self:GetName() or self:GetClass()
			ROTGB_LogError("DEPRECATION WARNING: The map tried to use next_target_* KeyValues on \""..name.."\", which are now deprecated. Please use target_* instead.", "")
			debug.Trace()
		elseif string.sub(lkey,1,17) == "next_blimp_target" then
			local num = (tonumber("0x"..string.sub(lkey,-1)) or 0) + 1
			self.TempNextBlimpTargets = self.TempNextBlimpTargets or {}
			self.TempNextBlimpTargets[num] = value
			
			local name = self:GetName() ~= "" and self:GetName() or self:GetClass()
			ROTGB_LogError("DEPRECATION WARNING: The map tried to use next_blimp_target* KeyValues on \""..name.."\", which are now deprecated. Please use blimp_target_* instead.", "")
			debug.Trace()
		end
	end
end

function ENT:AcceptInput(input,activator,caller,data)
	if string.sub(input,1,15) == "setnextwaypoint" then
		local num = (tonumber("0x"..string.sub(input,-1)) or 0) + 1
		self["SetNextTarget"..num](self,data~="" and ents.FindByName(data)[1] or NULL)
		
		local name = self:GetName() ~= "" and self:GetName() or self:GetClass()
		ROTGB_LogError("DEPRECATION WARNING: The map tried to use SetNextWaypoint* inputs on \""..name.."\", which are now deprecated. Please use SetNextTarget* instead.", "")
		debug.Trace()
	elseif string.sub(input,1,20) == "setnextblimpwaypoint" then
		local num = (tonumber("0x"..string.sub(input,-1)) or 0) + 1
		self["SetNextBlimpTarget"..num](self,data~="" and ents.FindByName(data)[1] or NULL)
		
		local name = self:GetName() ~= "" and self:GetName() or self:GetClass()
		ROTGB_LogError("DEPRECATION WARNING: The map tried to use SetNextBlimpWaypoint* inputs on \""..name.."\", which are now deprecated. Please use SetBlimpNextTarget* instead.", "")
		debug.Trace()
	elseif string.match(input, "^setnexttarget%d+$") then
		local num = tonumber(string.match(lkey, "^setnexttarget(%d+)$"))
		if num then
			self[string.format("SetNextTarget%u", num)](self,data~="" and ents.FindByName(data)[1] or NULL)
		end
	elseif string.match(input, "^setblimpnexttarget%d+$") then
		local num = tonumber(string.match(lkey, "^setblimpnexttarget(%d+)$"))
		if num then
			self[string.format("SetNextBlimpTarget%u", num)](self,data~="" and ents.FindByName(data)[1] or NULL)
		end
	elseif input=="enablespectating" then
		self:SetUnSpectatable(false)
	elseif input=="disablespectating" then
		self:SetUnSpectatable(true)
		scripted_ents.GetMember("point_rotgb_spectator", "TransmitChangeToSpectatingPlayers")(self)
	elseif input=="togglespectating" then
		self:SetUnSpectatable(not self:GetUnSpectatable())
		scripted_ents.GetMember("point_rotgb_spectator", "TransmitChangeToSpectatingPlayers")(self)
	elseif input=="enablemotion" then
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:EnableMotion(true)
			physobj:Wake()
		end
	elseif input=="disablemotion" then
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:EnableMotion(false)
		end
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
	elseif input=="enablecollisions" then
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
	elseif input=="disablecollisions" then
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	elseif input=="togglecollisions" then
		self:SetCollisionGroup(self:GetCollisionGroup() == COLLISION_GROUP_WORLD and COLLISION_GROUP_NONE or COLLISION_GROUP_WORLD)
	end
end

function ENT:Initialize()
	-- FIXME: This is a horrible way to generate a unique ID.
	self.UniqueID = self.UniqueID or util.MD5(tostring(self:GetCreationID()+math.random()))
	self:SetModel(self.Model or "models/props_c17/streetsign004e.mdl")
	if self.Skin then
		self:SetSkin(self.Skin)
	end
	if self.TempNextTargets then
		for k,v in pairs(self.TempNextTargets) do
			self[string.format("SetNextTarget%u", k)](self,ents.FindByName(v)[1])
		end
	end
	if self.TempNextBlimpTargets then
		for k,v in pairs(self.TempNextBlimpTargets) do
			self[string.format("SetNextBlimpTarget%u", k)](self,ents.FindByName(v)[1])
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
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetNoDraw(true)
	end
	self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS 
end

function ENT:PreEntityCopy()
	-- take note which targets we're connected to, in terms of UUIDs
	self.TempTargetUIDs = {
		to = {},
		bossTo = {}
	}
	
	for i=1, 16 do
		local targetFuncName = string.format("GetNextTarget%u", i)
		local ent = self[targetFuncName](self)
		
		if IsValid(ent) then
			self.TempTargetUIDs.to[i] = ent.UniqueID
		end
		
		targetFuncName = string.format("GetNextBlimpTarget%u", i)
		ent = self[targetFuncName](self)
		
		if IsValid(ent) then
			self.TempTargetUIDs.bossTo[i] = ent.UniqueID
		end
	end
end

function ENT:PostEntityPaste()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	
	if self.TempTargetUIDs then
		timer.Simple(0, function()
			-- make a list of UIDs present on the world
			local UIDTargets = {}
			local targets = ents.FindByClass("gballoon_target")
			for k,v in pairs(targets) do
				if v.UniqueID then
					UIDTargets[v.UniqueID] = v
				end
			end
			
			for i,uid in pairs(self.TempTargetUIDs.to) do
				local ent = UIDTargets[uid]
				if IsValid(ent) then
					local targetFuncName = string.format("SetNextTarget%u", i)
					self[targetFuncName](self, ent)
				else
					ROTGB_EntityLogError(self, "Failed to find and connect to target with UID "..uid.."!", "pathfinding")
				end
			end
			
			for i,uid in pairs(self.TempTargetUIDs.bossTo) do
				local ent = UIDTargets[uid]
				if IsValid(ent) then
					local targetFuncName = string.format("SetNextBlimpTarget%u", i)
					self[targetFuncName](self, ent)
				else
					ROTGB_EntityLogError(self, "Failed to find and connect to target with UID "..uid.."!", "pathfinding")
				end
			end
		end)
	end
end