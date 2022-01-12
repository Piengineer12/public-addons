ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Base Container"
ENT.Category = "ISAWC"
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
ENT.ContainerCountMul = 1
ENT.OpenSounds = {}
ENT.CloseSounds = {}

ENT.ISAWC_Openers = {}

AddCSLuaFile()

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"IsPublic",{KeyName="is_public",Edit={type="Boolean",title="Anyone Can Use",order=1}})
	self:NetworkVar("Bool",1,"IsPlayerLocalized",{KeyName="is_player_localized",Edit={type="Boolean",title="Player-Specific Inventories",order=2}})
	self:NetworkVar("Int",0,"ContainerHealth",{KeyName="isawc_health",Edit={type="Int",title="Container Health",min=0,max=1000,order=4}})
	self:NetworkVar("Int",1,"OwnerAccountID")
	self:NetworkVar("Int",2,"PlayerTeam")
	self:NetworkVar("Float",0,"MassMul",{KeyName="isawc_mass_mul",Edit={type="Float",category="Multipliers",title="Mass Mult.",min=0,max=10,order=5}})
	self:NetworkVar("Float",1,"VolumeMul",{KeyName="isawc_volume_mul",Edit={type="Float",category="Multipliers",title="Volume Mult.",min=0,max=10,order=6}})
	self:NetworkVar("Float",2,"CountMul",{KeyName="isawc_count_mul",Edit={type="Float",category="Multipliers",title="Count Mult.",min=0,max=10,order=7}})
	self:NetworkVar("Float",3,"LockMul",{KeyName="isawc_lock_mul",Edit={type="Float",category="Multipliers",title="(DarkRP) Lock Mult.",min=0,max=10,order=8}})
	self:NetworkVar("String",1,"FileID")
	self:NetworkVar("String",2,"EnderInvName",{KeyName="enderchest_inv_name",Edit={type="Generic",title="Inv. ID (for EnderChests)",order=3}})
	
	self:SetMassMul(1)
	self:SetVolumeMul(1)
	self:SetCountMul(1)
	self:SetLockMul(1)
end

if SERVER then
	AccessorFunc(ENT, "Team", "Team", FORCE_NUMBER)
end

function ENT:SpawnFunction(ply,trace,classname)
	if not trace.Hit then return end
	
	local ent = ents.Create(classname)
	ent:SetCreator(ply)
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
	self.ISAWC_Inventory = self.ISAWC_Inventory or {}
	self.ISAWC_PlayerLocalizedInventories = self.ISAWC_PlayerLocalizedInventories or {}
	if SERVER then
		ISAWC:SQL([[CREATE TABLE IF NOT EXISTS "isawc_container_data" (
			"containerID" TEXT NOT NULL UNIQUE ON CONFLICT REPLACE,
			"data" TEXT NOT NULL
		);]])
		self:SetModel(self.ContainerModel)
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
		self:SendInventoryUpdate()
		if WireLib then
			self.Inputs = WireLib.CreateSpecialInputs(self,
				{"Disable"},
				{"NORMAL"}
			)
			self.Outputs = WireLib.CreateSpecialOutputs(self,
				{"Mass", "Volume", "Count", "MaxMass", "MaxVolume", "MaxCount"},
				{"NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL"}
			)
			local baseClass = scripted_ents.Get("base_wire_entity")
			self.ISAWC_OnRemove = baseClass.OnRemove
			self.OnRestore = baseClass.OnRestore
			self.BuildDupeInfo = baseClass.BuildDupeInfo
			self.ApplyDupeInfo = baseClass.ApplyDupeInfo
			self.PreEntityCopy = baseClass.PreEntityCopy
			self.OnEntityCopyTableFinish = baseClass.OnEntityCopyTableFinish
			self.OnDuplicated = baseClass.OnDuplicated
		end
		self:SetTrigger(true)
	end
	self:ISAWC_Initialize()
	
	if SERVER then
		local creator = self:GetCreator()
		if creator:IsPlayer() and self:GetOwnerAccountID()==0 then
			self:SetOwnerAccountID(creator:AccountID() or 0)
		end
		-- compatibility, remove for version 5.0.0+
		if self:GetPlayerTeam()~=0 then
			self:SetTeam(self:GetPlayerTeam())
		end
	end
	
	local endername = self:GetEnderInvName()
	if (endername or "")~="" then
		local invNeedsLoad = table.IsEmpty(self.ISAWC_Inventory)
		local inv2NeedsLoad = table.IsEmpty(self.ISAWC_PlayerLocalizedInventories)
		if invNeedsLoad or inv2NeedsLoad then
			for k,v in pairs(ents.GetAll()) do
				if (IsValid(v) and v.Base=="isawc_container_base" and v:GetEnderInvName()==endername) then
					if invNeedsLoad and not table.IsEmpty(v.ISAWC_Inventory) then
						self.ISAWC_Inventory = v.ISAWC_Inventory break
					end
					if inv2NeedsLoad and not table.IsEmpty(v.ISAWC_PlayerLocalizedInventories) then
						self.ISAWC_PlayerLocalizedInventories = v.ISAWC_PlayerLocalizedInventories break
					end
				end
			end
		end
	end
	self.MagnetScale = self:BoundingRadius()
	self.NextRegenThink = CurTime()
	self.MagnetTraceResult = {}
end

function ENT:InterpretAdditionalAccess(accessStr, ply)
	local permissionsObject = ISAWC:CreatePermissionsObject()
	
	for keyValue in string.gmatch(accessStr, "[^|]+") do
		local option, value = string.match(keyValue, "^([^=]+)=([^=]+)$")
		if option == "player" then
			permissionsObject:AddPermittedUsername(value)
		elseif option == "team" then
			local team = tonumber(value)
			if team then
				permissionsObject:AddPermittedTeam(team)
			else
				ISAWC:NoPickup("\""..value.."\" is not a valid team number!", ply)
			end
		elseif option == "darkrp_category" then
			permissionsObject:AddPermittedDarkRPCategory(value)
		elseif option == "darkrp_command" then
			permissionsObject:AddPermittedDarkRPCommand(value)
		elseif option == "darkrp_doorgroup" then
			permissionsObject:AddPermittedDarkRPDoorGroup(value)
		elseif option then
			ISAWC:NoPickup("\""..option.."\" is not a valid option!", ply)
		else
			ISAWC:NoPickup("\""..keyValue.."\" is not a valid key-value pair!", ply)
		end
	end
	
	self.ISAWC_PermittedPlayersObject = permissionsObject
end

function ENT:PostEntityPaste(ply,ent,entities)
	self:SetModel(self.ContainerModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self.ISAWC_PermittedPlayersObject = ISAWC:CreatePermissionsObject(self.ISAWC_PermittedPlayersObject)
	
	local baseClass = scripted_ents.Get("base_wire_entity")
	baseClass.PostEntityPaste(self,ply,ent,entities)
end

function ENT:Touch(ent)
	if ISAWC.ConDragAndDropOntoContainer:GetInt()==1 then
		self:PickUpTouchedProp(ent)
	end
end

function ENT:StartTouch(ent) -- no longer works?
	if ISAWC.ConDragAndDropOntoContainer:GetInt()==2 then
		self:PickUpTouchedProp(ent)
	end
end

function ENT:PhysicsCollide(data)
	local ent = data.HitEntity
	if ISAWC.ConDragAndDropOntoContainer:GetInt()==3 then
		self:PickUpTouchedProp(ent)
	end
end

function ENT:PickUpTouchedProp(ent)
	if not self.ISAWC_Disabled then
		if ISAWC:CanProperty(self,ent) then
			local pickupPlayer = (
				IsValid(ent:GetPhysicsAttacker(5)) and ent:GetPhysicsAttacker(5)
				or IsValid(ent:GetOwner()) and ent:GetOwner()
				or IsValid(ent:GetCreator()) and ent:GetCreator()
				or player.GetByAccountID(self:GetOwnerAccountID())
			)
			ISAWC:PropPickup(self,ent,pickupPlayer)
			ISAWC:SaveContainerInventory(self)
		end
	end
end

function ENT:TriggerInput(input, value)
	if input == "Disable" then
		self.ISAWC_Disabled = tobool(value)
	end
end

function ENT:Use(activator,caller,typ,data)
	if activator:IsPlayer() then
		if self:GetOwnerAccountID()==0 then
			self:SetOwnerAccountID(activator:AccountID() or 0)
		end
		if SERVER and ISAWC.ConSaveIntoFile:GetBool() and (table.IsEmpty(self.ISAWC_Inventory) or table.IsEmpty(self.ISAWC_PlayerLocalizedInventories)) then
			local chosenFileID = self:GetFileID()
			local result = ISAWC:SQL("SELECT \"containerID\", \"data\" FROM \"isawc_container_data\" WHERE \"containerID\" = %s;", chosenFileID)
			if (result and result[1]) then
				local data = util.JSONToTable(result[1].data or "")
				if not data then
					data = util.JSONToTable(util.Decompress(util.Base64Decode(result[1].data or "") or "") or "") or {}
				end
				
				if table.IsEmpty(self.ISAWC_Inventory) then
					self.ISAWC_Inventory = data.ISAWC_Inventory or data
				end
				if table.IsEmpty(self.ISAWC_PlayerLocalizedInventories) then
					self.ISAWC_PlayerLocalizedInventories = data.ISAWC_PlayerLocalizedInventories or {}
				end
			elseif file.Exists("isawc_containers/"..chosenFileID..".dat","DATA") then
				self.ISAWC_Inventory = util.JSONToTable(util.Decompress(file.Read("isawc_containers/"..chosenFileID..".dat") or "")) or {}
			end
		end
		if ISAWC:IsLegalContainer(self, activator, true) then
			for k,v in pairs(self.ISAWC_Openers) do
				if not IsValid(k) then self.ISAWC_Openers[k] = nil end
			end
			if not next(self.ISAWC_Openers) then
				ISAWC:StartNetMessage("open_container")
				net.WriteEntity(self)
				if self.ISAWC_Template then -- This is a really bad way to make sure clients know the sounds this container makes... I can't be bothered to make this better though.
					net.WriteString(table.concat(self.OpenSounds,'|'))
					net.WriteString(table.concat(self.CloseSounds,'|'))
				end
				net.SendPAS(self:GetPos())
			end
			self.ISAWC_Openers[activator] = true
			ISAWC:StartNetMessage("inventory_l")
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
	if SERVER and self.ISAWC_Inventory and ISAWC.ConDropOnDeathContainer:GetBool() then
		local ply = player.GetByAccountID(self:GetOwnerAccountID())
		if IsValid(ply) then
			ISAWC:SetSuppressUndo(true)
			for i=1,#self.ISAWC_Inventory do
				local dupe = self.ISAWC_Inventory[i]
				if dupe then
					ISAWC:SpawnDupe2(dupe,true,true,i,ply,self)
				end
			end
			ISAWC:SetSuppressUndo(false)
			table.Empty(self.ISAWC_Inventory)
			ISAWC:SaveContainerInventory(self)
		else
			ISAWC:Log(string.format("Warning! Owner of container %s was missing, so items couldn't be dropped!", tostring(self)))
		end
		if self.ISAWC_OnRemove then
			self:ISAWC_OnRemove()
		end
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
		if self:GetFileID()=="" and SERVER then
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
			local invalid = true
			while invalid do
				local chosenFileID = GenStringFile()
				local result = ISAWC:SQL("SELECT \"containerID\" FROM \"isawc_container_data\" WHERE \"containerID\" = %s;", chosenFileID)
				invalid = file.Exists("isawc_containers/"..chosenFileID..".dat","DATA") or container_ents[chosenFileID] or (result and next(result))
				if not invalid then
					self:SetFileID(chosenFileID)
				end
			end
		end
		if ISAWC.ConMagnet:GetFloat() > 0 and ISAWC:SatisfiesBWLists(self:GetClass(), "ContainerMagnetContainer") and not self.ISAWC_IsDeathDrop then
			self:FindMagnetablesInSphere()
		elseif self.ISAWC_IsDeathDrop and not self.ISAWC_Inventory[1] then
			local delay = self.ISAWC_IsDropAll and ISAWC.ConDropAllTime:GetFloat() or ISAWC.ConDeathRemoveDelay:GetFloat()
			timer.Simple(delay-4.24, function()
				if IsValid(self) then
					self:SetRenderMode(RENDERMODE_GLOW)
					self:SetRenderFX(kRenderFxFadeSlow)
					timer.Simple(4.24,function()
						SafeRemoveEntity(self)
					end)
				end
			end)
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

function ENT:FindMagnetablesInSphere()
	self.MagnetScale = self.MagnetScale or self:BoundingRadius()
	for k,v in pairs(ents.FindInSphere(self:LocalToWorld(self:OBBCenter()), ISAWC.ConMagnet:GetFloat()*self.MagnetScale)) do
		if v ~= self then
			if ISAWC:SatisfiesBWLists(v:GetClass(), "ContainerMagnet") then
				self:Magnetize(v)
			end
		end
	end
end

function ENT:Magnetize(ent)
	if not IsValid(ent:GetParent()) and ISAWC:CanPickup(self,ent,true) then
		local trace = util.TraceLine({
			start = self:GetPos(),
			endpos = ent:GetPos(),
			filter = self,
			mask = MASK_SOLID,
			output = self.MagnetTraceResult
		})
		local result = self.MagnetTraceResult
		if not result.Hit or result.HitNonWorld and result.Entity == ent then
			if IsValid(ent:GetPhysicsObject()) and ent:GetMoveType()==MOVETYPE_VPHYSICS then
				local dir = self:GetPos()-ent:GetPos()
				local nDir = dir:GetNormalized()
				nDir:Mul(math.min(self.MagnetScale*5e4*ISAWC.ConMagnet:GetFloat()/dir:LengthSqr(), 1000))
				ent:GetPhysicsObject():AddVelocity(nDir)
			else
				self:Touch(ent)
				self:StartTouch(ent)
			end
		end
	end
end

function ENT:SendInventoryUpdate()
	--[[for k,v in pairs(self.ISAWC_Openers) do
		if IsValid(k) then
			ISAWC:SendInventory2(k, self)
		else
			self.ISAWC_Openers[k] = nil
		end
	end]]
	if WireLib then
		local stats = ISAWC:GetClientStats(self)
		Wire_TriggerOutput(self, "Mass", stats[1])
		Wire_TriggerOutput(self, "MaxMass", stats[2])
		Wire_TriggerOutput(self, "Volume", stats[3] * ISAWC.dm3perHu)
		Wire_TriggerOutput(self, "MaxVolume", stats[4] * ISAWC.dm3perHu)
		Wire_TriggerOutput(self, "Count", stats[5])
		Wire_TriggerOutput(self, "MaxCount", stats[6])
	end
end

function ENT:PlayerPermitted(ply)
	if self:GetIsPublic() then return true end
	if ISAWC.ConAlwaysPublic:GetBool() then return true end
	if ply:AccountID() == self:GetOwnerAccountID() then return true end
	
	if self.ISAWC_PermittedPlayersObject then
		if self.ISAWC_PermittedPlayersObject:PlayerPermitted(ply) then return true end
	end
	
	return false
end

function ENT:SetInventory(inv, ply)
	if self:GetIsPlayerLocalized() then
		self.ISAWC_PlayerLocalizedInventories[ply:SteamID()] = inv
	else
		self.ISAWC_Inventory = inv
	end
end

function ENT:GetInventory(ply)
	if self:GetIsPlayerLocalized() then
		if ply:IsPlayer() then
			local steamID = ply:SteamID()
			if not self.ISAWC_PlayerLocalizedInventories[steamID] then
				self.ISAWC_PlayerLocalizedInventories[steamID] = {}
			end
			return self.ISAWC_PlayerLocalizedInventories[steamID]
		else
			ISAWC:Log(string.format(
				"Warning! Failed to access player-specific inventory of container %s with player %s! Falling back to general inventory...",
				tostring(self), tostring(ply)
			))
			return self.ISAWC_Inventory
		end
	else
		return self.ISAWC_Inventory
	end
end

hook.Add("canLockpick", "ISAWC X DarkRP", function(ply, ent, trace)
	if ent.Base == "isawc_container_base" then
		return ISAWC.ConLockpickTime:GetFloat() >= 0 and ent:GetLockMul() > 0 and not ent:GetIsPublic()
	end
end)

hook.Add("lockpickTime", "ISAWC X DarkRP", function(ply, ent)
	if ent.Base == "isawc_container_base" then
		local averageTime = ISAWC.ConLockpickTime:GetFloat()
		
		-- I'm surprised the devs didn't rename the lockpick class to something less likely to cause addon collisions
		local wep = ply:GetWeapon("lockpick")
		if IsValid(wep) then
			local driftTime = ISAWC.ConLockpickTimeBump:GetFloat()
			return util.SharedRandom("DarkRP_Lockpick" .. wep:EntIndex() .. "_" .. wep:GetTotalLockpicks(), averageTime - driftTime, averageTime + driftTime)
		end
		
		ISAWC:Log(string.format("%s is trying to lockpick %s with a non-existent lockpick. Assuming ISAWC is incorrect and returning %.2f for lockpick time.", tostring(ply), tostring(ent), averageTime))
		return averageTime
	end
end)

hook.Add("onLockpickCompleted", "ISAWC X DarkRP", function(ply, success, ent)
	if ent.Base == "isawc_container_base" and success then
		ent:SetIsPublic(true)
	end
end)