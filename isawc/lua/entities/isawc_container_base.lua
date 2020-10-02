ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Base Container"
ENT.Category = "Containers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Base container for the Inventory System."
ENT.Instructions = "Link this container to something."
ENT.AutomaticFrameAdvance = true
ENT.Editable = true

ENT.ContainerModel = Model("models/props_junk/watermelon01.mdl")
ENT.OpenAnimTime = 1
ENT.CloseAnimTime = 1
ENT.ContainerMassMul = 1
ENT.ContainerVolumeMul = 1
ENT.OpenSounds = {}
ENT.CloseSounds = {}

ENT.ISAWC_Inventory = {}
ENT.ISAWC_Openers = {}

AddCSLuaFile()

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"IsPublic",{KeyName="is_public",Edit={type="Boolean",title="Anyone Can Use",order=1}})
	self:NetworkVar("Float",0,"MassMul",{KeyName="isawc_mass_mul",Edit={type="Float",category="Multipliers",title="Mass Mul.",min=0,max=10,order=5}})
	self:NetworkVar("Float",1,"VolumeMul",{KeyName="isawc_volume_mul",Edit={type="Float",category="Multipliers",title="Volume Mul.",min=0,max=10,order=6}})
	self:NetworkVar("Int",0,"ContainerHealth",{KeyName="isawc_volume_mul",Edit={type="Int",title="Container Health",min=0,max=1000,order=2}})
	self:NetworkVar("Int",1,"OwnerAccountID")
	self:NetworkVar("String",1,"FileID")
	self:NetworkVar("String",2,"EnderInvName",{KeyName="enderchest_inv_name",Edit={type="Generic",title="Inv. ID (for EnderChests)",order=3}})
end

function ENT:SpawnFunction(ply,trace,classname)
	if not trace.Hit then return end
	
	local ent = ents.Create(classname)
	ent:Spawn()
	ent:Activate()
	ent:SetPos(trace.HitPos-trace.HitNormal*ent:OBBMins().z)
	local ang = ply:GetAngles()
	ang.p = 0
	ang.y = ang.y + 180
	ent:SetAngles(ang)
	
	return ent
end

function ENT:ISAWC_Initialize()
end

function ENT:Initialize()
	self:SetModel(self.ContainerModel)
	if SERVER then
		self:SetTrigger(true)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:Wake()
			if ISAWC.ConAutoHealth:GetFloat() > 0 and self:GetContainerHealth()==0 then
				self:SetContainerHealth(math.max(math.Round(physobj:GetVolume()*0.001*ISAWC.ConAutoHealth:GetFloat(),-1),10))
			end
		end
		self:PrecacheGibs()
	end
	self:SetMassMul(1)
	self:SetVolumeMul(1)
	self:ISAWC_Initialize()
	if SERVER and (IsValid(self:GetCreator()) and self:GetCreator():IsPlayer()) then
		self:SetOwnerAccountID(self:GetCreator():AccountID() or 0)
	end
	local endername = self:GetEnderInvName()
	if (endername or "")~="" and table.IsEmpty(self.ISAWC_Inventory) then
		for k,v in pairs(ents.GetAll()) do
			if (IsValid(v) and v.Base=="isawc_container_base" and v:GetEnderInvName()==endername and not table.IsEmpty(v.ISAWC_Inventory)) then
				self.ISAWC_Inventory = v.ISAWC_Inventory break
			end
		end
	end
	if (self:GetFileID() or "")=="" and SERVER then
		local container_ents = {}
		for k,v in pairs(ents.GetAll()) do
			if v.Base == "isawc_container_base" then
				container_ents[v:GetFileID()] = v
			end
		end
		local function GenStringFile()
			local str = ""
			for i=1,8 do
				str = str .. string.char(math.random(32, 126))
			end
			return str
		end
		while self:GetFileID()=="" or file.Exists("isawc_containers/"..self:GetFileID()..".dat","DATA") or container_ents[self:GetFileID()] do
			self:SetFileID(GenStringFile())
		end
	end
	if ISAWC.ConSaveIntoFile:GetBool() then
		if file.Exists("isawc_containers/"..self:GetFileID()..".dat","DATA") then
			self.ISAWC_Inventory = table.DeSanitise(util.JSONToTable(util.Decompress(file.Read("isawc_containers/"..self:GetFileID()..".dat"))))
		end
	end
	self.NextRegenThink = CurTime()
end

function ENT:Touch(ent)
	if ISAWC.ConDragAndDropOntoContainer:GetInt()==1 then
		if ISAWC:CanProperty(self,ent) then
			ISAWC:PropPickup(self,ent)
			--self:SendInventoryUpdate()
		end
	end
end

function ENT:StartTouch(ent)
	if ISAWC.ConDragAndDropOntoContainer:GetInt()==2 then
		if ISAWC:CanProperty(self,ent) then
			ISAWC:PropPickup(self,ent)
			--self:SendInventoryUpdate()
		end
	end
end

function ENT:Use(activator,caller,typ,data)
	if activator:IsPlayer() then
		if not self:GetOwnerAccountID() or self:GetOwnerAccountID()==0 then
			self:SetOwnerAccountID(activator:AccountID() or 0)
		end
		if self:GetOwnerAccountID()==(activator:AccountID() or 0) or self:GetIsPublic() or ISAWC.ConAlwaysPublic:GetBool() then
			for k,v in pairs(self.ISAWC_Openers) do
				if not IsValid(k) then self.ISAWC_Openers[k] = nil end
			end
			if not next(self.ISAWC_Openers) then
				net.Start("isawc_general")
				net.WriteString("container_open")
				net.WriteEntity(self)
				net.SendPAS(self:GetPos())
			end
			self.ISAWC_Openers[activator] = true
			net.Start("isawc_general")
			net.WriteString("inv_container")
			net.WriteEntity(self)
			net.Send(activator)
		else
			ISAWC:NoPickup("Only the container's owner can open this!",activator)
		end
	end
end

function ENT:OpenAnim()
end

function ENT:CloseAnim()
end

function ENT:OnTakeDamage(dmginfo)
	local physobj = self:GetPhysicsObject()
	if IsValid(physobj) then
		physobj:AddVelocity(dmginfo:GetDamageForce()/physobj:GetMass())
	end
	if self:GetMaxHealth() > 0 then
		self:SetHealth(self:Health()-dmginfo:GetDamage())
		if self:Health() <= 0 then
			if IsValid(physobj) then
				self:GibBreakServer(dmginfo:GetDamageForce()*physobj:GetMass())
			else
				self:GibBreakServer(dmginfo:GetDamageForce())
			end
			self:Remove()
		end
	end
end

function ENT:OnRemove()
	if SERVER and self.ISAWC_Inventory and ISAWC.ConDropOnDeathContainer:GetBool() and IsValid(self:GetCreator()) then
		ISAWC:SetSuppressUndo(true)
		for i=1,#self.ISAWC_Inventory do
			local dupe = self.ISAWC_Inventory[i]
			if dupe then
				ISAWC:SpawnDupe2(dupe,true,true,i,self:GetCreator(),self)
			end
		end
		ISAWC:SetSuppressUndo(false)
		table.Empty(self.ISAWC_Inventory)
		ISAWC:SaveContainerInventory(self)
	end
end

function ENT:Think()
	if SERVER then 
		if self.CHealth~=self:GetContainerHealth() then
			self.CHealth = self:GetContainerHealth()
			self:SetHealth(self.CHealth)
			self:SetMaxHealth(self.CHealth)
		end
		if not self.NextRegenThink then
			self.NextRegenThink = CurTime()
		end
		if self.NextRegenThink <= CurTime() and ISAWC.ConContainerRegen:GetFloat() ~= 0 then
			while self.NextRegenThink <= CurTime() do
				self.NextRegenThink = self.NextRegenThink + math.abs(1/ISAWC.ConContainerRegen:GetFloat())
				if ISAWC.ConContainerRegen:GetFloat() > 0 and self:Health() < self:GetMaxHealth() then
					self:SetHealth(self:Health()+1)
				elseif ISAWC.ConContainerRegen:GetFloat() < 0 then
					self:TakeDamage(1,self,self)
				end
			end
		end
	end
	if CLIENT then
		if (self.FinishOpenAnimTime or 0) >= CurTime() then
			self.ContainerState="opening"
			self:OpenAnim(1-(self.FinishOpenAnimTime-CurTime())/self.OpenAnimTime)
		elseif self.ContainerState=="opening" then
			self.ContainerState="opened"
			self:OpenAnim(1)
		end
		if (self.FinishCloseAnimTime or 0) >= CurTime() then
			self.ContainerState="closing"
			self:CloseAnim(1-(self.FinishCloseAnimTime-CurTime())/self.CloseAnimTime)
		elseif self.ContainerState=="closing" then
			self.ContainerState="closed"
			self:CloseAnim(1)
		end
	end
end

--[[function ENT:SendInventoryUpdate()
	for k,v in pairs(self.ISAWC_Openers) do
		if IsValid(k) then
			ISAWC:SendInventory2(k, self)
		else
			self.ISAWC_Openers[k] = nil
		end
	end
end]]