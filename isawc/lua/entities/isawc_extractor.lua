ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Inventory Exporter"
ENT.Category = "ISAWC"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Ejects items out of an inventory, spawning them inside itself."
ENT.Instructions = "Link this Exporter to something."
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Spawnable = true

AddCSLuaFile()

local ACTI_NEEDS = 0x1
local ACTI_BELOW = 0x2
local ACTI_EQUAL = 0x4
local ACTI_BELOW_AND_EQUAL = 0x6
local ACTI_EVERY = 0xF
local ACTI_MASS_OFFSET = 4
local ACTI_VOLUME_OFFSET = 8
local ACTI_COUNT_OFFSET = 12
local ACTI_AND = 0x10000
local ACTI_TRIGGER = 0x20000

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"OwnerAccountID")
	self:NetworkVar("Int",1,"ActiFlags")
	self:NetworkVar("Entity",0,"StorageEntity")
	self:NetworkVar("String",0,"FileID")
	self:NetworkVar("Float",0,"SpawnDelay") -- minimum spawn delay is 0.05, no matter what.
	self:NetworkVar("Float",1,"ActiMass")
	self:NetworkVar("Float",2,"ActiVolume")
	self:NetworkVar("Float",3,"ActiCount")
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
	if self:GetSpawnDelay()==0 then
		self:SetSpawnDelay(1)
	end
	self:SetModel("models/props_phx/construct/metal_wire1x1x1.mdl")
	self:SetMaterial("metal2t")
	if SERVER then
		self:SetTrigger(true)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:SetMass(100)
			physobj:Wake()
		end
		if WireLib then
			self.Inputs = WireLib.CreateSpecialInputs(self,
				{"Spawn", "SpawnDelay", "MassThreshold", "VolumeThreshold", "ContainerThreshold"},
				{"NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL"}
			)
			self.Outputs = WireLib.CreateSpecialOutputs(self,
				{"ContainerMass", "ContainerVolume", "ContainerCount", "ContainerMaxMass", "ContainerMaxVolume", "ContainerMaxCount"},
				{"NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL"}
			)
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
		self:UpdateWireOutputs()
	end
	if SERVER and (IsValid(self:GetCreator()) and self:GetCreator():IsPlayer()) then
		self:SetOwnerAccountID(self:GetCreator():AccountID() or 0)
	end
end

function ENT:TriggerInput(input, value)
	if input == "Spawn" and tobool(value) then
		self:SpawnProp(true)
	elseif input == "SpawnDelay" then
		self:SetSpawnDelay(tonumber(value) or 0)
	elseif input == "MassThreshold" then
		self:SetActiMass(tonumber(value) or 0)
	elseif input == "VolumeThreshold" then
		self:SetActiVolume(tonumber(value) or 0)
	elseif input == "ContainerThreshold" then
		self:SetActiCount(tonumber(value) or 0)
	end
end

function ENT:UpdateWireOutputs()
	if WireLib and SERVER then
		local container = self:GetContainer()
		if IsValid(container) then
			local data = ISAWC:GetClientStats(container)
			Wire_TriggerOutput(self, "ContainerMass", data[1])
			Wire_TriggerOutput(self, "ContainerMaxMass", data[2])
			Wire_TriggerOutput(self, "ContainerVolume", data[3] * ISAWC.dm3perHu)
			Wire_TriggerOutput(self, "ContainerMaxVolume", data[4] * ISAWC.dm3perHu)
			Wire_TriggerOutput(self, "ContainerCount", data[5])
			Wire_TriggerOutput(self, "ContainerMaxCount", data[6])
		else
			Wire_TriggerOutput(self, "ContainerMass", 0)
			Wire_TriggerOutput(self, "ContainerMaxMass", 0)
			Wire_TriggerOutput(self, "ContainerVolume", 0)
			Wire_TriggerOutput(self, "ContainerMaxVolume", 0)
			Wire_TriggerOutput(self, "ContainerCount", 0)
			Wire_TriggerOutput(self, "ContainerMaxCount", 0)
		end
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
		if self:GetOwnerAccountID()==0 then
			self:SetOwnerAccountID(activator:AccountID() or 0)
		end
		if self:GetOwnerAccountID() == activator:AccountID() or activator:IsAdmin() then
			net.Start("isawc_general")
			net.WriteString("exporter")
			net.WriteEntity(self)
			net.Send(activator) -- calls ENT:BuildConfigGUI()
		else
			activator:PrintMessage(HUD_PRINTTALK, "Only the owner or an admin can use this Inventory Exporter!")
		end
	end
end

function ENT:GetFuzzyCreator()
	local ply = SERVER and self:GetCreator()
	if not IsValid(ply) then
		ply = player.GetByAccountID(self:GetOwnerAccountID())
		if IsValid(ply) then
			self:SetCreator(ply)
		end
	end
	return ply
end

function ENT:LinkEntity(ent)
	if self:GetStorageEntity() ~= ent then
		local message = "Device linked to "..tostring(ent).."!"
		local message2 = nil
		if ISAWC.ConAllowInterConnection:GetBool() or self:GetOwnerAccountID() == ent:GetOwnerAccountID() then
			self:SetStorageEntity(ent)
			self:SetFileID(ent:GetFileID())
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			message2 = "Be careful! The Inventory Exporter's collisions have been disabled to allow it to spawn big props."
			self:UpdateWireOutputs()
		else
			message = "That container does not belong to you!"
		end
		
		local plyToMessage = self:GetFuzzyCreator()
		if IsValid(plyToMessage) then
			plyToMessage:PrintMessage(HUD_PRINTTALK, message)
			if message2 then
				plyToMessage:PrintMessage(HUD_PRINTTALK, message2)
			end
		end
	end
end

function ENT:Touch(ent)
	local container = self:GetContainer()
	if ISAWC.ConDragAndDropOntoContainer:GetInt()==1 then
		if not IsValid(container) and ent.Base == "isawc_container_base" then
			self:LinkEntity(ent)
		end
	end
end

function ENT:StartTouch(ent)
	local container = self:GetContainer()
	if ISAWC.ConDragAndDropOntoContainer:GetInt()==2 then
		if not IsValid(container) and ent.Base == "isawc_container_base" then
			self:LinkEntity(ent)
		end
	end
end

local function BitAndWithOffset(input, mask, maskOffset)
	return bit.rshift( bit.band(input, bit.lshift(mask, maskOffset)), maskOffset)
end

function ENT:CheckThreshold(current, threshold, flags, bAnd)
	local compareMode = bit.band(flags, ACTI_BELOW_AND_EQUAL)
	
	if bit.band(flags, ACTI_NEEDS)==0 then return bAnd end
	if compareMode==ACTI_BELOW_AND_EQUAL then return current <= threshold
	elseif compareMode==ACTI_BELOW then return current < threshold
	elseif compareMode==ACTI_EQUAL then return current >= threshold
	else return current > threshold
	end
end

function ENT:SpawnProp(forcedSpawn)
	local container = self:GetContainer()
	local spawnDelay = math.max(self:GetSpawnDelay(), ISAWC.ConMinExportDelay:GetFloat(), 0.05)
	local spawnPlayer = self:GetFuzzyCreator()
	if (IsValid(container) and #container.ISAWC_Inventory > 0) and IsValid(spawnPlayer) then
		self.ISAWC_NextSpawn = CurTime() + spawnDelay
		
		if not forcedSpawn then
			local data = ISAWC:GetClientStats(container)
			local actiFlags = self:GetActiFlags()
			local andMode = bit.band(actiFlags, ACTI_AND)==ACTI_AND
			-- {cw,mw,cv,mv,cc,mc}
			local massMet = self:CheckThreshold(data[1], self:GetActiMass(), BitAndWithOffset(actiFlags, ACTI_EVERY, ACTI_MASS_OFFSET), andMode)
			local volumeMet = self:CheckThreshold(data[3], self:GetActiMass(), BitAndWithOffset(actiFlags, ACTI_EVERY, ACTI_VOLUME_OFFSET), andMode)
			local countMet = self:CheckThreshold(data[5], self:GetActiMass(), BitAndWithOffset(actiFlags, ACTI_EVERY, ACTI_COUNT_OFFSET), andMode)
			
			if andMode then
				forcedSpawn = massMet and volumeMet and countMet
			else
				forcedSpawn = massMet or volumeMet or countMet
			end
			if bit.band(actiFlags, ACTI_TRIGGER)==ACTI_TRIGGER and not forcedSpawn then
				forcedSpawn = (container.ISAWC_ExportFullTimestamp or 0) + spawnDelay > CurTime()
			end
		end
		
		if forcedSpawn then
			ISAWC:SpawnDupeWeak(table.remove(container.ISAWC_Inventory, #container.ISAWC_Inventory), self:WorldSpaceCenter(), self:GetAngles(), spawnPlayer)
			container:SendInventoryUpdate()
			self:UpdateWireOutputs(data)
		end
	end
end

function ENT:Think()
	if (self.ISAWC_NextSpawn or 0) < CurTime() then
		self:SpawnProp()
	end
	if (self.ISAWC_NextInventoryCheck or 0) < CurTime() then
		self.ISAWC_NextInventoryCheck = CurTime() + 1
		self:UpdateWireOutputs()
	end
	self:NextThink(CurTime())
	return true
end

function ENT:DrawTranslucent()
	--self:DrawModel()
	if (self:GetOwnerAccountID()==LocalPlayer():AccountID() or game.SinglePlayer()) and self:GetFileID()=='' then
		local selfPos = self:WorldSpaceCenter()
		local pointScreenData = selfPos:ToScreen()
		local lineSize = 5000/selfPos:Distance(EyePos())
		local drawX, drawY = pointScreenData.x, pointScreenData.y
		
		cam.Start2D()
		surface.SetDrawColor(0, 255, 0)
		surface.DrawLine(drawX - lineSize, drawY - lineSize, drawX + lineSize, drawY + lineSize)
		surface.DrawLine(drawX - lineSize, drawY + lineSize, drawX + lineSize, drawY - lineSize)
		if lineSize > 48 then
			surface.SetFont("CloseCaption_Bold")
			surface.SetTextColor(0, 255, 0)
			surface.SetTextPos(drawX + lineSize, drawY + lineSize)
			surface.DrawText("Prop Spawn Position")
		end
		cam.End2D()
	end
end

-- UI stuff

local UIHeight = 32

local function ConfigureBits(input, cfgMask, cfgSet)
	local demaskedInput = bit.band(input, bit.bnot(cfgMask))
	return bit.bor(demaskedInput, cfgSet)
end

function ENT:TripleSetGUI(parent, message, data, quantity)
	local dataCondFlags = bit.band(data, ACTI_BELOW_AND_EQUAL)
	local activated = bit.band(data, ACTI_NEEDS)~=0
	
	local Label = vgui.Create("DLabel", parent)
	Label:SetText(message)
	Label:SetTall(UIHeight)
	Label:Dock(TOP)
	
	local Panel = vgui.Create("DPanel", parent)
	Panel:SetTall(UIHeight)
	Panel:Dock(TOP)
	Panel.actiFlags = data
	Panel.actiQuan = quantity
	Panel.Paint = function() end
	Panel:DockMargin(0,0,0,UIHeight/2)
	
	local CheckBox = vgui.Create("DCheckBox", Panel)
	CheckBox:SetSize(UIHeight, UIHeight)
	CheckBox:Dock(LEFT)
	CheckBox:SetChecked(activated)
	
	local CompareSelections = vgui.Create("DComboBox", Panel)
	CompareSelections:SetFontInternal("DermaLarge")
	CompareSelections:SetWide(UIHeight * 2)
	CompareSelections:AddChoice(">", 0, dataCondFlags==0)
	CompareSelections:AddChoice("<", ACTI_BELOW, dataCondFlags==ACTI_BELOW)
	CompareSelections:AddChoice(">=", ACTI_EQUAL, dataCondFlags==ACTI_EQUAL)
	CompareSelections:AddChoice("<=", ACTI_BELOW_AND_EQUAL, dataCondFlags==ACTI_BELOW_AND_EQUAL)
	CompareSelections:SetEnabled(activated)
	CompareSelections:Dock(LEFT)
	function CompareSelections:OnSelect(index, text, value)
		Panel.actiFlags = ConfigureBits(Panel.actiFlags, ACTI_BELOW_AND_EQUAL, value)
	end
	
	local NumberQuantity = vgui.Create("DTextEntry", Panel)
	NumberQuantity:SetNumeric(true)
	NumberQuantity:SetFont("DermaLarge")
	NumberQuantity:SetText(tostring(quantity or 0))
	NumberQuantity:SetEnabled(activated)
	NumberQuantity:Dock(FILL)
	function NumberQuantity:OnChange()
		if tonumber(self:GetValue()) then
			Panel.actiQuan = tonumber(self:GetValue())
		end
	end
	
	function CheckBox:OnChange(checked)
		CompareSelections:SetEnabled(checked)
		NumberQuantity:SetEnabled(checked)
		Panel.actiFlags = ConfigureBits(Panel.actiFlags, ACTI_NEEDS, checked and ACTI_NEEDS or 0)
	end
	
	return Panel
end

function ENT:BuildConfigGUI()
	local extractor = self
	local actiFlags = self:GetActiFlags()
	local extraFlags = bit.band(actiFlags, bit.bor(ACTI_AND, ACTI_TRIGGER))
	
	local Main = vgui.Create("DFrame")
	Main:SetSize(640, 480)
	Main:Center()
	Main:MakePopup()
	Main:SetTitle("Inventory Exporter")
	
	if self:GetFileID()~='' then
		local ClearButton = vgui.Create("DButton", Main)
		ClearButton:SetTall(UIHeight)
		ClearButton:SetText("Remove Connection (will re-enable collisions!)")
		ClearButton:SetTextColor(Color(255,0,0))
		ClearButton:Dock(TOP)
		function ClearButton:DoClick()
			net.Start("isawc_general")
			net.WriteString("exporter_disconnect")
			net.WriteEntity(extractor)
			net.SendToServer()
			
			self:SetText("Connection Removed")
			self:SetEnabled(false)
		end
	else
		local ConnectionText = vgui.Create("DLabel", Main)
		ConnectionText:SetTall(UIHeight)
		ConnectionText:SetText("Collide this entity with another container to link. This GUI will not be visible for other players, except admins.")
		ConnectionText:Dock(TOP)
	end
	
	local SpawnRateSlider = vgui.Create("DNumSlider", Main)
	SpawnRateSlider:SetText("Spawn Delay")
	SpawnRateSlider:SetDecimals(2)
	SpawnRateSlider:SetMinMax(ISAWC.ConMinExportDelay:GetFloat(), 5)
	SpawnRateSlider:SetValue(self:GetSpawnDelay())
	SpawnRateSlider:Dock(TOP)
	
	local MassPanel = self:TripleSetGUI(Main, "Mass Threshold (kg)", BitAndWithOffset(actiFlags, ACTI_EVERY, ACTI_MASS_OFFSET), self:GetActiMass())
	local VolumePanel = self:TripleSetGUI(Main, "Volume Threshold (dm³)", BitAndWithOffset(actiFlags, ACTI_EVERY, ACTI_VOLUME_OFFSET), self:GetActiVolume())
	local CountPanel = self:TripleSetGUI(Main, "Count Threshold", BitAndWithOffset(actiFlags, ACTI_EVERY, ACTI_COUNT_OFFSET), self:GetActiCount())
	
	local AndCheck = vgui.Create("DCheckBoxLabel", Main)
	AndCheck:SetText("Only output when ALL ticked thresholds above are met (unchecked = any ticked threshold above)")
	AndCheck:SetChecked(bit.band(actiFlags, ACTI_AND)~=0)
	AndCheck:Dock(TOP)
	function AndCheck:OnChange(checked)
		extraFlags = ConfigureBits(extraFlags, ACTI_AND, checked and ACTI_AND or 0)
	end
	
	local FillCheck = vgui.Create("DCheckBoxLabel", Main)
	FillCheck:SetText("Also output when connected container fails to pick up an item due to being too full")
	FillCheck:SetChecked(bit.band(actiFlags, ACTI_TRIGGER)~=0)
	FillCheck:Dock(TOP)
	function FillCheck:OnChange(checked)
		extraFlags = ConfigureBits(extraFlags, ACTI_TRIGGER, checked and ACTI_TRIGGER or 0)
	end
	
	local ConfirmButton = vgui.Create("DButton", Main)
	ConfirmButton:SetTall(UIHeight)
	ConfirmButton:SetText("Save Changes")
	ConfirmButton:SetTextColor(Color(0,127,0))
	ConfirmButton:Dock(BOTTOM)
	function ConfirmButton:DoClick()
		Main:Close()
		
		local totalFlags = bit.bor(extraFlags, bit.lshift(MassPanel.actiFlags, ACTI_MASS_OFFSET),
		bit.lshift(VolumePanel.actiFlags, ACTI_VOLUME_OFFSET), bit.lshift(CountPanel.actiFlags, ACTI_COUNT_OFFSET))
		if not IsValid(extractor) then ISAWC:NoPickup("The entity doesn't exist!") return end
		
		net.Start("isawc_general")
		net.WriteString("exporter")
		net.WriteEntity(extractor)
		net.WriteInt(totalFlags, 32)
		net.WriteFloat(SpawnRateSlider:GetValue())
		net.WriteFloat(MassPanel.actiQuan)
		net.WriteFloat(VolumePanel.actiQuan)
		net.WriteFloat(CountPanel.actiQuan)
		net.SendToServer()
	end
end