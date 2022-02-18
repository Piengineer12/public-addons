ENT.Type = "brush"
ENT.Base = "base_brush"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Defines an area where towers can't be placed."
ENT.Instructions = "Cover a volume up and go. Has start_disabled KeyValue and EnableDisable inputs."

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"Disabled")
end

function ENT:KeyValue(key,value)
	if key:lower()=="start_disabled" then
		self:SetDisabled(tobool(value))
	end
end

function ENT:AcceptInput(input,activator,caller,data)
	input = input:lower()
	if input=="enable" then
		self:SetDisabled(false)
	elseif input=="disable" then
		self:SetDisabled(true)
	elseif input=="toggle" then
		self:SetDisabled(not self:GetDisabled())
	end
end

function ENT:Touch(ent)
	if ent.Base=="gballoon_tower_base" and not ent.StunUntil2 and not self:GetDisabled() then
		ent:SetNWBool("ROTGB_Stun2",true)
		ent:Stun2()
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		net.Start("rotgb_generic")
		net.WriteUInt(ROTGB_OPERATION_NOTIFYCHAT, 8)
		net.WriteUInt(ROTGB_NOTIFYCHAT_PLACEMENTILLEGAL, 8)
		net.WriteEntity(ent)
		net.Broadcast()
	elseif ent.rotgb_isDetector and not ent.rotgb_isDetected then
		--print("A", ent)
		ent.rotgb_isDetected = true
		ent:NoBuildTriggered(true)
	end
end

function ENT:EndTouch(ent)
	if ent.Base=="gballoon_tower_base" then
		ent:SetNWBool("ROTGB_Stun2",false)
		ent:UnStun2()
		ent:SetCollisionGroup(COLLISION_GROUP_NONE)
		net.Start("rotgb_generic")
		net.WriteUInt(ROTGB_OPERATION_NOTIFYCHAT, 8)
		net.WriteUInt(ROTGB_NOTIFYCHAT_PLACEMENTILLEGALOFF, 8)
		net.WriteEntity(ent)
		net.Broadcast()
	elseif ent.rotgb_isDetector and ent.rotgb_isDetected then
		--print("B", ent)
		ent.rotgb_isDetected = false
		ent:NoBuildTriggered(false)
	end
end