ENT.Type = "point"
ENT.PrintName = "RotgB Spectator Point"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "A spectator viewing point. Only used in RotgB: The Gamemode."
ENT.Instructions = "Hook this entity's inputs and outputs to something."

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"Disabled")
	self:NetworkVar("Bool",1,"RotationLocked")
	self:NetworkVar("Int",0,"UsageFlags")
	self:NetworkVar("Int",1,"FOV")
end

function ENT:KeyValue(key,value)
	key = key:lower()
	if key=="startdisabled" then
		self:SetDisabled(tobool(value))
	elseif key=="welcome_point" then
		self.WelcomePoint = tonumber(value) or 0
	elseif key=="finish_point" then
		self.EndingPoint = tonumber(value) or 0
	elseif key=="fov" then
		self:SetFOV(tonumber(value) or 0)
	elseif key=="lock_rotation" then
		self:SetRotationLocked(tobool(value))
	end
	self:TransmitChangeToSpectatingPlayers()
end

function ENT:AcceptInput(input,activator,caller,data)
	input = input:lower()
	if input=="enable" then
		self:SetDisabled(false)
	elseif input=="disable" then
		self:SetDisabled(true)
	elseif input=="toggle" then
		self:SetDisabled(not self:GetDisabled())
	elseif input=="setwelcomepoint" then
		self.WelcomePoint = tonumber(data) or 0
		self:UpdateUsageFlags()
	elseif input=="setfinishingpoint" then
		self.EndingPoint = tonumber(data) or 0
		self:UpdateUsageFlags()
	elseif input=="setfov" then
		self:SetFOV(tonumber(data) or 0)
	elseif input=="setlockrotation" then
		self:SetRotationLocked(tobool(data))
	end
	self:TransmitChangeToSpectatingPlayers()
end

function ENT:Initialize()
	self.WelcomePoint = self.WelcomePoint or 0
	self.EndingPoint = self.EndingPoint or 0
	self:UpdateUsageFlags()
end

function ENT:UpdateUsageFlags()
	local bit1 = self.WelcomePoint < 2 and self.EndingPoint < 2
	local bit2 = self.WelcomePoint > 0
	local bit3 = self.EndingPoint > 0
	self:SetUsageFlags(bit.bor(bit1 and 1 or 0, bit2 and 2 or 0, bit3 and 4 or 0))
end

function ENT:TransmitChangeToSpectatingPlayers()
	for k,v in pairs(player.GetAll()) do
		if v:GetObserverTarget() == self then
			hook.Run("ApplyEntitySpectateProperties", ply, v, false)
		end
	end
end

function ENT:PlayerCanSpectate(ply, defeated)
	if self:GetDisabled() then return false
	elseif ply:Team()==TEAM_UNASSIGNED then return bit.band(self:GetUsageFlags(), 2) ~= 0
	elseif defeated then return bit.band(self:GetUsageFlags(), 4) ~= 0
	else return bit.band(self:GetUsageFlags(), 1) ~= 0
	end
end