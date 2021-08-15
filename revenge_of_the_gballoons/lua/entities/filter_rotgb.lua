ENT.Type = "filter"
ENT.Base = "base_filter"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Special filter / damage filter for RotgB."
ENT.Instructions = ""

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"Inverted")
	self:NetworkVar("Int",0,"Type")
end

--[[Types:
0 - (Damage Filter) gBalloon Damage
1 - (Damage Filter) Tower Damage
2 - gBalloon Entities
3 - Tower Entities
]]

function ENT:KeyValue(key,value)
	if key:lower()=="type" then
		self:SetType(tonumber(value))
	elseif key:lower()=="negated" then
		self:SetInverted(tobool(value))
	end
end

function ENT:AcceptInput(input,activator,caller,data)
	if input:lower()=="setnegated" then
		self:SetInverted(tobool(data))
	elseif input:lower()=="settype" then
		self:SetType(tonumber(data))
	end
end

function ENT:PassesFilter(caller, ent)
	if self:GetType()==2 then
		if IsValid(ent) then
			return (ent:GetClass() == "gballoon_base") ~= self:GetInverted()
		else return self:GetInverted()
		end
	elseif self:GetType()==3 then
		if IsValid(ent) then
			return (ent.Base == "gballoon_tower_base") ~= self:GetInverted()
		else return self:GetInverted()
		end
	else return not self:GetInverted() end
end


function ENT:PassesDamageFilter(dmg)
	if self:GetType()==0 then
		if IsValid(dmg:GetInflictor()) then
			return (dmg:GetInflictor():GetClass() == "gballoon_base") ~= self:GetInverted()
		else return self:GetInverted()
		end
	elseif self:GetType()==1 then
		if IsValid(dmg:GetInflictor()) then
			return (dmg:GetInflictor().Base == "gballoon_tower_base") ~= self:GetInverted()
		else return self:GetInverted()
		end
	else return not self:GetInverted() end
end
