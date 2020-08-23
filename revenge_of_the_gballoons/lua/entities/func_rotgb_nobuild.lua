ENT.Type = "brush"
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
	if input:lower()=="enable" then
		self:SetDisabled(false)
	elseif input:lower()=="disable" then
		self:SetDisabled(true)
	elseif input:lower()=="toggle" then
		self:SetDisabled(not self:GetDisabled())
	end
end

function ENT:Touch(ent)
	if ent.Base=="gballoon_tower_base" and not ent.StunUntil2 and not self:GetDisabled() then
		ent:SetNWBool("ROTGB_Stun2",true)
		ent:Stun2()
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		PrintMessage(HUD_PRINTTALK,"Warning! A "..tostring(ent.PrintName).." is placed illegally! Move it out now or else it won't fire!")
	elseif ent:GetNWBool("rotgb_isDetector") then
		ent:SetNWBool("rotgb_isDetected", true)
	end
end

function ENT:EndTouch(ent)
	if ent.Base=="gballoon_tower_base" then
		ent:SetNWBool("ROTGB_Stun2",false)
		ent:UnStun2()
		ent:SetCollisionGroup(COLLISION_GROUP_NONE)
		PrintMessage(HUD_PRINTTALK,"The "..tostring(ent.PrintName).." has moved out of the illegal zone.")
	elseif ent:GetNWBool("rotgb_isDetector") then
		ent:SetNWBool("rotgb_isDetected", false)
	end
end