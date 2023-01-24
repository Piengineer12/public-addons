ENT.Type = "point"
ENT.PrintName = "RotgB Environment Text"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Displays text."
ENT.Instructions = "Hook this entity's inputs and outputs to something."

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"ActivatorOnly")
	self:NetworkVar("Bool",1,"IgnoreColor")
	self:NetworkVar("Int",0,"MessageType")
	self:NetworkVar("Float",0,"HoldTime")
	self:NetworkVar("String",0,"Text")
end

function ENT:KeyValue(key,value)
	local lkey = key:lower()
	
	if lkey == "message" then
		self:SetText(value)
	elseif lkey == "level" then
		self:SetMessageType(tonumber(value))
	elseif lkey == "rendercolor" then
		self:SetIgnoreColor(value == "-1 -1 -1 -1")
		self:SetColor(string.ToColor(value))
		return true
	elseif lkey == "holdtime" then
		self:SetHoldTime(tonumber(value))
	elseif lkey == "activator_only" then
		self:SetActivatorOnly(tobool(value))
	end
end

function ENT:AcceptInput(input,activator,caller,value)
	local linput = input:lower()
	
	if linput == "display" then
		self:Display(activator)
	elseif linput == "settext" then
		self:SetText(value)
	elseif linput == "setmessagetypeinfo" then
		self:SetMessageType(0)
	elseif linput == "setmessagetypechat" then
		self:SetMessageType(1)
	elseif linput == "setmessagetypeerror" then
		self:SetMessageType(2)
	elseif linput == "color" then
		self:SetIgnoreColor(value == "-1 -1 -1 -1")
		self:SetColor(string.ToColor(value))
	elseif linput == "setholdtime" then
		self:SetHoldTime(tonumber(value))
	elseif linput == "enableactivatoronly" then
		self:SetActivatorOnly(true)
	elseif linput == "disableactivatoronly" then
		self:SetActivatorOnly(false)
	elseif linput == "toggleactivatoronly" then
		self:SetActivatorOnly(not self:GetActivatorOnly())
	end
end

function ENT:Display(activator)	
	local messageLevel = -1
	local messageType = self:GetMessageType()
	if messageType == 0 then
		messageLevel = ROTGB_NOTIFYTYPE_INFO
	elseif messageType == 1 then
		messageLevel = ROTGB_NOTIFYTYPE_CHAT
	elseif messageType == 2 then
		messageLevel = ROTGB_NOTIFYTYPE_ERROR
	end
	
	ROTGB_CauseNotification(self:GetText(), messageLevel, self:GetActivatorOnly() and activator, {
		color = messageType == 1 and not self:GetIgnoreColor() and self:GetColor(),
		holdtime = (messageType == 0 or messageType == 2) and self:GetHoldTime()>0 and self:GetHoldTime()
	})
end