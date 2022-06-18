ENT.Type = "point"
ENT.PrintName = "RotgB Difficulty Logic"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Can be used to add custom difficulties and remove existing ones."
ENT.Instructions = "Set this entity's key values to something."

function ENT:KeyValue(key,value)
	local lkey = key:lower()
	if lkey=="difficulty_remove" then
		self.DifficultyRemove = value
	elseif lkey=="difficulty_id" then
		self.DifficultyID = value
	elseif lkey=="difficulty_category" then
		self.DifficultyCategory = value
	elseif lkey=="difficulty_category_place" then
		self.DifficultyCategoryPlace = tonumber(value) or -1
	elseif lkey=="difficulty_place" then
		self.DifficultyPlace = tonumber(value) or 0
	elseif string.match(lkey, "^convar_%d+_name$") then
		if value ~= "" then
			local num = (tonumber(string.match(lkey, "^convar_(%d+)_name$")) or 0) + 1
			self:SetConVarName(num, value)
		end
	elseif string.match(lkey, "^convar_%d+_value$") then
		if value ~= "" then
			local num = (tonumber(string.match(lkey, "^convar_(%d+)_value$")) or 0) + 1
			self:SetConVarValue(num, value)
		end
	end
end

function ENT:SetConVarName(num, value)
	self.ConVars = self.ConVars or {}
	self.ConVars[num] = self.ConVars[num] or {}
	self.ConVars[num].name = value
	self.RequiresResync = true
end

function ENT:SetConVarValue(num, value)
	self.ConVars = self.ConVars or {}
	self.ConVars[num] = self.ConVars[num] or {}
	self.ConVars[num].value = value
	self.RequiresResync = true
end

function ENT:Initialize()
	hook.Run("RemoveDifficulties", self.DifficultyRemove)
	
	if (self.DifficultyID or "") ~= "" then
		--assemble properly
		local difficulty = {
			category = self.DifficultyCategory or "other",
			place = self.DifficultyPlace or 0,
			custom = true,
			convars = {}
		}
		
		for k,v in pairs(self.ConVars) do
			if v.name ~= "" then
				difficulty.convars[v.name] = v.value or ""
			end
		end
		
		hook.Run("AddMapAddedDifficulty", self.DifficultyID, self.DifficultyCategoryPlace, difficulty)
	end
end

--[[
steps:
1. Entity sends difficulty info
2. Server saves difficulty info
3. Client connects to server
4. Server sends over removed difficulties
5. Server sends custom difficulty data
6. Client gets data
]]