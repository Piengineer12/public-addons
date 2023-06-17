ENT.Type = "brush"
ENT.Base = "base_brush"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Defines an area where towers can't be placed."
ENT.Instructions = "Cover a volume up and go. Has start_disabled KeyValue and EnableDisable inputs."

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"Disabled")
end

function ENT:KeyValue(key,value)
	if key:lower()=="start_disabled" then
		self.TempDisabled = tobool(value)
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

function ENT:Initialize()
	self:SetDisabled(tobool(self.TempDisabled))
end

function ENT:Touch(ent)
	if not self:GetDisabled() then
		if ent.Base=="gballoon_tower_base" or ent.rotgb_isDetector then
			ent:Stun2(self)
		end
	end
end

function ENT:EndTouch(ent)
	if ent.Base=="gballoon_tower_base" or ent.rotgb_isDetector then
		ent:UnStun2(self)
	end
end