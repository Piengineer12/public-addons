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
local ACTI_INFINITE = 0x40000
local ACTI_CONTINUE = 0x80000
local ACTI_SPECIAL_ALL = 0xF0000

local ACTI_MASS_FIRST = 0x1000000
local ACTI_MASS_LAST = 0x2000000
local ACTI_VOLUME_FIRST = 0x3000000
local ACTI_VOLUME_LAST = 0x4000000
local ACTI_COUNT_FIRST = 0x5000000
local ACTI_COUNT_LAST = 0x6000000
local ACTI_SORT_ALL = 0xF000000

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"OwnerAccountID")
	self:NetworkVar("Int",1,"ActiFlags")
	self:NetworkVar("Int",2,"CurrentFileIDs")
	self:NetworkVar("Entity",0,"StorageEntity1")
	self:NetworkVar("Entity",1,"StorageEntity2")
	self:NetworkVar("Entity",2,"StorageEntity3")
	self:NetworkVar("Entity",3,"StorageEntity4")
	self:NetworkVar("Entity",4,"StorageEntity5")
	self:NetworkVar("Entity",5,"StorageEntity6")
	self:NetworkVar("Entity",6,"StorageEntity7")
	self:NetworkVar("Entity",7,"StorageEntity8")
	self:NetworkVar("Entity",8,"StorageEntity9")
	self:NetworkVar("Entity",9,"StorageEntity10")
	self:NetworkVar("Entity",10,"StorageEntity11")
	self:NetworkVar("Entity",11,"StorageEntity12")
	self:NetworkVar("Entity",12,"StorageEntity13")
	self:NetworkVar("Entity",13,"StorageEntity14")
	self:NetworkVar("Entity",14,"StorageEntity15")
	self:NetworkVar("Entity",15,"StorageEntity16")
	self:NetworkVar("String",0,"FileIDComposite")
	self:NetworkVar("Float",0,"SpawnDelay") -- minimum spawn delay is 0.05, no matter what.
	self:NetworkVar("Float",1,"ActiMass")
	self:NetworkVar("Float",2,"ActiVolume")
	self:NetworkVar("Float",3,"ActiCount")
end

local function ConfigureBits(input, cfgMask, cfgSet)
	local demaskedInput = bit.band(input, bit.bnot(cfgMask))
	return bit.bor(demaskedInput, cfgSet)
end

-- these assume file name length is always 8!

function ENT:SetFileID(index, id)
	if string.len(id)==8 then
		local oldFileIDComp = self:GetFileIDComposite()
		self:SetFileIDComposite(oldFileIDComp:sub(1, index*8-8)..id..oldFileIDComp:sub(index*8+1))
		self:SetCurrentFileIDs(bit.bor(self:GetCurrentFileIDs(), bit.lshift(1, index-1)))
	else
		self:SetCurrentFileIDs(ConfigureBits(self:GetCurrentFileIDs(), bit.lshift(1, index-1), 0))
	end
end

function ENT:GetFileID(index)
	if bit.band(self:GetCurrentFileIDs(), bit.lshift(1, index-1))~=0 then
		return string.sub(self:GetFileIDComposite(), index*8-7, index*8)
	else return ''
	end
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
				{"Spawn", "SpawnDelay"},
				{"NORMAL", "NORMAL"}
			)
			--[[self.Outputs = WireLib.CreateSpecialOutputs(self,
				{"ContainerMass", "ContainerVolume", "ContainerCount", "ContainerMaxMass", "ContainerMaxVolume", "ContainerMaxCount"},
				{"NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL"}
			)]]
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
		--self:UpdateWireOutputs()
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
	--[[elseif input == "MassThreshold" then
		self:SetActiMass(tonumber(value) or 0)
	elseif input == "VolumeThreshold" then
		self:SetActiVolume(tonumber(value) or 0)
	elseif input == "ContainerThreshold" then
		self:SetActiCount(tonumber(value) or 0)]]
	end
end

function ENT:MakeContainerTable()
	for i=1,16 do
		print(i, self:GetContainer(i))
	end
end

function ENT:AcceptInput(input, activator, caller, data)
	if input:lower()=="printdebug" then
		self:MakeContainerTable()
	end
end

--[[function ENT:UpdateWireOutputs()
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
end]]

function ENT:GetContainer(index)
	if not IsValid(self["GetStorageEntity"..index](self)) and self:GetFileID(index)~='' then
		for k,v in pairs(ents.GetAll()) do
			if (v.Base == "isawc_container_base" and v:GetFileID() == self:GetFileID(index)) then
				self["SetStorageEntity"..index](self, v) break
			end
		end
	end
	return self["GetStorageEntity"..index](self)
end

function ENT:HasContainer(container)
	for i=1,16 do
		if self:GetContainer(i)==container or not container and IsValid(self:GetContainer(i)) then return true end
	end
	return false
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
		if IsValid(ply) and SERVER then
			self:SetCreator(ply)
		end
	end
	return ply
end

function ENT:LinkEntity(ent)
	local alreadyConnected = false
	local availableSpace
	
	for i=1,16 do
		local storageEntity = self:GetContainer(i)
		if storageEntity == ent then
			alreadyConnected = true break
		elseif not IsValid(storageEntity) then
			availableSpace = math.min(availableSpace or 99, i)
		end
	end
	
	if not alreadyConnected then
		local message = "Device linked to "..tostring(ent).."!"
		local message2 = nil
		if not availableSpace then
			message = "This exporter can't be connected to any more containers!"
		elseif ISAWC.ConAllowInterConnection:GetBool() or self:GetOwnerAccountID() == ent:GetOwnerAccountID() then
			self["SetStorageEntity"..availableSpace](self, ent)
			self:SetFileID(availableSpace, ent:GetFileID())
			if self:GetCollisionGroup()==COLLISION_GROUP_NONE then
				self:SetCollisionGroup(COLLISION_GROUP_WORLD)
				message2 = "Be careful! The Inventory Exporter's collisions have been disabled to allow it to spawn big props."
			end
			--self:UpdateWireOutputs()
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

function ENT:UnlinkEntity(ent)
	if isnumber(ent) then
		self["SetStorageEntity"..ent](self, NULL)
		self:SetFileID(ent, '')
	else
		for i=1,16 do
			if self:GetContainer(i)==ent then
				self["SetStorageEntity"..i](self, NULL)
				self:SetFileID(i, '') break
			end
		end
	end
end

function ENT:ClearStorageEntities()
	for i=1,16 do
		self:UnlinkEntity(i)
	end
end

function ENT:Touch(ent)
	if ISAWC.ConDragAndDropOntoContainer:GetInt()==1 then
		if ent.Base == "isawc_container_base" then
			self:LinkEntity(ent)
		end
	end
end

function ENT:StartTouch(ent)
	if ISAWC.ConDragAndDropOntoContainer:GetInt()==2 then
		if ent.Base == "isawc_container_base" then
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

function ENT:WhitelistedDupe(dupe)
	if not ISAWC.ConUseExportWhitelist:GetBool() then return true end
	local allLegal = true
	for k,v in pairs(dupe.Entities) do
		if not ISAWC.WhiteExtractList[v.Class] then
			allLegal = false break
		end
	end
	return allLegal
end

function ENT:IsExtractableContainer(container)
	if IsValid(container) then
		if ISAWC.ConUseExportWhitelist:GetBool() then
			for k,v in pairs(container.ISAWC_Inventory) do
				if self:WhitelistedDupe(v) then return true end
			end
			return false
		else return tobool(container.ISAWC_Inventory[1])
		end
	else return false
	end
end

function ENT:SpawnProp(forcedSpawn)
	local spawnDelay = math.max(self:GetSpawnDelay(), ISAWC.ConMinExportDelay:GetFloat(), 0.05)
	local validContainer = false
	for i=1,16 do
		local container = self:GetContainer(i)
		if self:IsExtractableContainer(container) then
			validContainer = true break
		end
	end
	if validContainer then
		self.ISAWC_NextSpawn = CurTime() + spawnDelay
		local spawnPlayer = self:GetFuzzyCreator()
		if IsValid(spawnPlayer) then
			local actiFlags = self:GetActiFlags()
			if not forcedSpawn then
				if bit.band(actiFlags, ACTI_CONTINUE)==ACTI_CONTINUE and self.ISAWC_SpawnStreak then
					forcedSpawn = true
				else
					local totalMass, totalVolume, totalCount = 0, 0, 0
					for i=1,16 do
						local container = self:GetContainer(i)
						if IsValid(container) then
							local data = ISAWC:GetClientStats(container)
							totalMass = totalMass + math.max(data[1], 0)
							totalVolume = totalVolume + math.max(data[3], 0)
							totalCount = totalCount + math.max(data[5], 0)
							if bit.band(actiFlags, ACTI_TRIGGER)==ACTI_TRIGGER then
								forcedSpawn = (container.ISAWC_ExportFullTimestamp or 0) + spawnDelay > CurTime()
								if forcedSpawn then break end
							end
						end
					end
					if not forcedSpawn then
						local andMode = bit.band(actiFlags, ACTI_AND)==ACTI_AND
						-- {cw,mw,cv,mv,cc,mc}
						local massMet = self:CheckThreshold(totalMass, self:GetActiMass(), BitAndWithOffset(actiFlags, ACTI_EVERY, ACTI_MASS_OFFSET), andMode)
						local volumeMet = self:CheckThreshold(totalVolume, self:GetActiVolume(), BitAndWithOffset(actiFlags, ACTI_EVERY, ACTI_VOLUME_OFFSET), andMode)
						local countMet = self:CheckThreshold(totalCount, self:GetActiCount(), BitAndWithOffset(actiFlags, ACTI_EVERY, ACTI_COUNT_OFFSET), andMode)
						
						if andMode then
							forcedSpawn = massMet and volumeMet and countMet
						else
							forcedSpawn = massMet or volumeMet or countMet
						end
					end
				end
			end
			
			if forcedSpawn then
				local invnum, container
				local sortFlags = bit.band(actiFlags, ACTI_SORT_ALL)
				
				if sortFlags == 0 then
					local possibleContainers = {}
					for i=1,16 do
						local possibleContainer = self:GetContainer(i)
						if self:IsExtractableContainer(possibleContainer) then
							table.insert(possibleContainers, possibleContainer)
						end
					end
					container = possibleContainers[math.random(#possibleContainers)]
					if ISAWC.ConUseExportWhitelist:GetBool() then
						for k,v in RandomPairs(container.ISAWC_Inventory) do
							if self:WhitelistedDupe(v) then
								invnum = k break
							end
						end
					else
						invnum = math.random(#container.ISAWC_Inventory)
					end
				elseif sortFlags == ACTI_COUNT_FIRST then
					for i=1,16 do
						local possibleContainer = self:GetContainer(i)
						if self:IsExtractableContainer(possibleContainer) then
							if ISAWC.ConUseExportWhitelist:GetBool() then
								for j,v in ipairs(possibleContainer.ISAWC_Inventory) do
									if self:WhitelistedDupe(v) then
										invnum = j
										container = possibleContainer break
									end
								end
							else
								invnum = 1
								container = possibleContainer break
							end
						end
						if container then break end
					end
				elseif sortFlags == ACTI_COUNT_LAST then
					for i=16,1,-1 do
						local possibleContainer = self:GetContainer(i)
						if self:IsExtractableContainer(possibleContainer) then
							if ISAWC.ConUseExportWhitelist:GetBool() then
								for j,v in SortedPairs(possibleContainer.ISAWC_Inventory, true) do
									if self:WhitelistedDupe(v) then
										invnum = j
										container = possibleContainer break
									end
								end
							else
								invnum = #possibleContainer.ISAWC_Inventory
								container = possibleContainer break
							end
						end
						if container then break end
					end
				else
					local maxvalue = -math.huge
					for i=1,16 do
						local checkContainer = self:GetContainer(i)
						if self:IsExtractableContainer(checkContainer) then
							for k,v in pairs(checkContainer.ISAWC_Inventory or {}) do
								if not ISAWC.ConUseExportWhitelist:GetBool() or self:WhitelistedDupe(v) then
									local dm, dv, dc = ISAWC:GetStatsFromDupeTable(v)
									local compareNum
									
									if sortFlags == ACTI_MASS_FIRST then
										compareNum = dm
									elseif sortFlags == ACTI_MASS_LAST then
										compareNum = -dm
									elseif sortFlags == ACTI_VOLUME_FIRST then
										compareNum = dv
									elseif sortFlags == ACTI_VOLUME_LAST then
										compareNum = -dv
									else
										--ISAWC:Log(tostring(self).." can't sort via data value "..sortFlags.."! Were you using a newer version of the addon?")
										compareNum = 0
									end
									
									if compareNum > maxvalue then
										maxvalue = compareNum
										invnum = k
										container = checkContainer
									end
								end
							end
						end
					end
				end
				
				if invnum and IsValid(container) then
					self.ISAWC_SpawnStreak = true
					if bit.band(actiFlags, ACTI_INFINITE)==ACTI_INFINITE and spawnPlayer:IsAdmin() then
						ISAWC:SpawnDupeWeak(container.ISAWC_Inventory[invnum], self:WorldSpaceCenter(), self:GetAngles(), spawnPlayer)
					else
						ISAWC:SpawnDupeWeak(table.remove(container.ISAWC_Inventory, invnum), self:WorldSpaceCenter(), self:GetAngles(), spawnPlayer)
					end
				end
				--container:SendInventoryUpdate()
				--self:UpdateWireOutputs(data)
			end
		end
	else
		self.ISAWC_SpawnStreak = false
	end
end

function ENT:Think()
	if (self.ISAWC_NextSpawn or 0) < CurTime() then
		self:SpawnProp()
	end
	if (self.ISAWC_NextInventoryCheck or 0) < CurTime() then
		self.ISAWC_NextInventoryCheck = CurTime() + 1
		--self:UpdateWireOutputs()
	end
	self:NextThink(CurTime())
	return true
end

function ENT:DrawTranslucent()
	--self:DrawModel()
	local noConnections = true
	for i=1,16 do
		if self:GetFileID(i)~='' then
			noConnections = false break
		end
	end
	if (self:GetOwnerAccountID()==LocalPlayer():AccountID() or game.SinglePlayer()) and noConnections then
		local selfPos = self:WorldSpaceCenter()
		local pointScreenData = selfPos:ToScreen()
		local lineSize = 5000/selfPos:Distance(EyePos())
		local drawX, drawY = pointScreenData.x, pointScreenData.y
		
		cam.Start2D()
		surface.SetDrawColor(0, 255, 0)
		surface.DrawLine(drawX - lineSize, drawY - lineSize, drawX + lineSize, drawY + lineSize)
		surface.DrawLine(drawX - lineSize, drawY + lineSize, drawX + lineSize, drawY - lineSize)
		if lineSize > 48 then
			surface.SetFont("HudHintTextLarge")
			surface.SetTextColor(0, 255, 0)
			surface.SetTextPos(drawX + lineSize, drawY + lineSize)
			surface.DrawText("Prop Spawn Position")
		end
		cam.End2D()
	end
end

-- UI stuff

local UIHeight = 32
local nullfunc = function() end

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
	Panel.Paint = nullfunc
	Panel:DockMargin(0,0,0,16)
	
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
	local extraFlags = bit.band(actiFlags, bit.bor(ACTI_SPECIAL_ALL, ACTI_SORT_ALL))
	
	local Main = vgui.Create("DFrame")
	Main:SetSize(640, 480)
	Main:SetSizable(true)
	Main:SetDraggable(true)
	Main:Center()
	Main:MakePopup()
	Main:SetTitle("Inventory Exporter")
	
	local hasConnections = false
	for i=1,16 do
		if self:GetFileID(i)~='' then
			hasConnections = true break
		end
	end
	if hasConnections then
		local ClearButton = vgui.Create("DButton", Main)
		ClearButton:SetTall(UIHeight)
		ClearButton:SetText("Remove All Connections (will re-enable collisions!)")
		ClearButton:SetTextColor(Color(255,0,0))
		ClearButton:Dock(TOP)
		function ClearButton:DoClick()
			net.Start("isawc_general")
			net.WriteString("exporter_disconnect")
			net.WriteEntity(extractor)
			net.SendToServer()
			
			self:SetText("All Connections Removed")
			self:SetEnabled(false)
		end
	else
		local ConnectionText = vgui.Create("DLabel", Main)
		ConnectionText:SetTall(UIHeight)
		ConnectionText:SetText("Collide this entity with another container to link, or use the ISAWC MultiConnector SWEP. This GUI will not be visible for other players, except admins.")
		ConnectionText:SetWrap(true)
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
	
	local ExtractionPanel = vgui.Create("DPanel", Main)
	ExtractionPanel:SetTall(16)
	ExtractionPanel:DockMargin(0,0,0,16)
	ExtractionPanel:Dock(TOP)
	ExtractionPanel.Paint = nullfunc
	
	local ExtractionLabel = vgui.Create("DLabel", ExtractionPanel)
	ExtractionLabel:SetText("Extraction Mode")
	ExtractionLabel:SizeToContentsX()
	ExtractionLabel:DockMargin(0,0,16,0)
	ExtractionLabel:Dock(LEFT)
	
	local dataCondFlags = bit.band(actiFlags, ACTI_SORT_ALL)
	local ExtractionSelector = vgui.Create("DComboBox", ExtractionPanel)
	ExtractionSelector:SetWide(200)
	ExtractionSelector:AddChoice("Random", 0, dataCondFlags==0)
	ExtractionSelector:AddChoice("Mass, Biggest First", ACTI_MASS_FIRST, dataCondFlags==ACTI_MASS_FIRST)
	ExtractionSelector:AddChoice("Mass, Smallest First", ACTI_MASS_LAST, dataCondFlags==ACTI_MASS_LAST)
	ExtractionSelector:AddChoice("Volume, Biggest First", ACTI_VOLUME_FIRST, dataCondFlags==ACTI_VOLUME_FIRST)
	ExtractionSelector:AddChoice("Volume, Smallest First", ACTI_VOLUME_LAST, dataCondFlags==ACTI_VOLUME_LAST)
	ExtractionSelector:AddChoice("Order, Leftmost", ACTI_COUNT_FIRST, dataCondFlags==ACTI_COUNT_FIRST)
	ExtractionSelector:AddChoice("Order, Rightmost", ACTI_COUNT_LAST, dataCondFlags==ACTI_COUNT_LAST)
	ExtractionSelector:Dock(LEFT)
	function ExtractionSelector:OnSelect(index, text, value)
		extraFlags = ConfigureBits(extraFlags, ACTI_SORT_ALL, value)
	end
	
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
	
	if LocalPlayer():IsAdmin() then
		local InfCheck = vgui.Create("DCheckBoxLabel", Main)
		InfCheck:SetText("[Admin Only] Don't remove items (can be used to pull infinite items from a container)")
		InfCheck:SetChecked(bit.band(actiFlags, ACTI_INFINITE)~=0)
		InfCheck:Dock(TOP)
		function InfCheck:OnChange(checked)
			extraFlags = ConfigureBits(extraFlags, ACTI_INFINITE, checked and ACTI_INFINITE or 0)
		end
	end
	
	local ContinueCheck = vgui.Create("DCheckBoxLabel", Main)
	ContinueCheck:SetText("When thresholds are met, continue until container is empty (unchecked = until below thresholds)")
	ContinueCheck:SetChecked(bit.band(actiFlags, ACTI_CONTINUE)~=0)
	ContinueCheck:Dock(TOP)
	function ContinueCheck:OnChange(checked)
		extraFlags = ConfigureBits(extraFlags, ACTI_CONTINUE, checked and ACTI_CONTINUE or 0)
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