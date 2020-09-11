-- Are you *sure* Ellpeck won't mind?!

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Inventory Importer"
ENT.Category = "ISAWC"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Items that touch this are put into a connected inventory if possible."
ENT.Instructions = "Link this Importer to something."
ENT.Spawnable = true

AddCSLuaFile()

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"OwnerAccountID")
	self:NetworkVar("Entity",0,"StorageEntity")
	self:NetworkVar("String",0,"FileID")
end

function ENT:SpawnFunction(ply,trace,classname)
	if not trace.Hit then return end
	
	local ent = ents.Create(classname)
	ent:Spawn()
	ent:Activate()
	ent:SetPos(trace.HitPos-trace.HitNormal*ent:OBBMins().z)
	local ang = ply:GetAngles()
	ang.p = 0
	ent:SetAngles(ang)
	
	return ent
end

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube1x1x1.mdl")
	self:SetMaterial("models/block_phantomface")
	if SERVER then
		self:SetTrigger(true)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:SetMass(100)
			physobj:Wake()
		end
	end
	if SERVER and (IsValid(self:GetCreator()) and self:GetCreator():IsPlayer()) then
		self:SetOwnerAccountID(self:GetCreator():AccountID() or 0)
	end
end

function ENT:GetContainer()
	if not IsValid(self:GetStorageEntity()) and self:GetFileID()~="" and SERVER then
		for k,v in pairs(ents.GetAll()) do
			if (v.Base == "isawc_container_base" and v:GetFileID() == self:GetFileID()) then
				self:SetStorageEntity(v) break
			end
		end
	end
	return self:GetStorageEntity()
end

function ENT:Use(activator, caller)
	if (IsValid(activator) and activator:IsPlayer()) then
		if not self:GetOwnerAccountID() or self:GetOwnerAccountID()==0 then
			self:SetOwnerAccountID(activator:AccountID() or 0)
		end
		if player.GetByAccountID(self:GetOwnerAccountID()) == activator or activator:IsAdmin() then
			if self:GetFileID()~="" or IsValid(self:GetStorageEntity()) then
				self:SetStorageEntity(NULL)
				self:SetFileID("")
				activator:PrintMessage(HUD_PRINTTALK, "Connection cleared!")
			else
				activator:PrintMessage(HUD_PRINTTALK, "Collide this entity with another container to link.")
				activator:PrintMessage(HUD_PRINTTALK, "Using this entity afterwards will clear out the connection, but only for you and admins. Using it does nothing for other players.")
				--activator:PrintMessage(HUD_PRINTTALK, "Note that you can collide with this entity to connect it to yourself!")
			end
		else
			activator:PrintMessage(HUD_PRINTTALK, "Only the owner or an admin can reset this Inventory Importer!")
		end
	end
end

function ENT:LinkEntity(ent)
	if self:GetStorageEntity() ~= ent then
		local message = "Device linked to "..tostring(ent).."!"
		if ISAWC.ConAllowInterConnection:GetBool() or self:GetOwnerAccountID() == ent:GetOwnerAccountID() then
			self:SetStorageEntity(ent)
			self:SetFileID(ent:GetFileID())
		else
			message = "That container does not belong to you!"
		end
		
		local plyToMessage = self:GetCreator()
		if not IsValid(plyToMessage) then
			plyToMessage = player.GetByAccountID(self:GetOwnerAccountID())
		end
		if IsValid(plyToMessage) then
			plyToMessage:PrintMessage(HUD_PRINTTALK, message)
		end
	end
end

function ENT:Touch(ent)
	local container = self:GetContainer()
	if ISAWC.ConDragAndDropOntoContainer:GetInt()==1 then
		if IsValid(container) then
			if ISAWC:CanProperty(container,ent) then
				ISAWC:PropPickup(container,ent)
				container:SendInventoryUpdate()
			end
		elseif ent.Base == "isawc_container_base" --[[or ent:IsPlayer()]] then
			self:LinkEntity(ent)
		end
	end
end

function ENT:StartTouch(ent)
	local container = self:GetContainer()
	if ISAWC.ConDragAndDropOntoContainer:GetInt()==2 then
		if IsValid(container) then
			if ISAWC:CanProperty(container,ent) then
				ISAWC:PropPickup(container,ent)
				container:SendInventoryUpdate()
			end
		elseif ent.Base == "isawc_container_base" --[[or ent:IsPlayer()]] then
			self:LinkEntity(ent)
		end
	end
end