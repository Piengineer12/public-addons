InsaneStats.BOOL = 1
InsaneStats.INT = 2
InsaneStats.FLOAT = 3
InsaneStats.NOP = function()end

InsaneStats.numConVars = 0
InsaneStats.conVars = {}
InsaneStats._defaultConVarCategory = ""
--defaultConVarCategoryDisplay = ""

-- this is on the shared side, because the client needs to know
-- the server's ConVars for the GUI menu, but at the same time
-- the server doesn't need to know about the client's ConVars
AccessorFunc(InsaneStats, "_defaultConVarCategory", "DefaultConVarCategory", FORCE_STRING)

--[[function InsaneStats:SetDefaultConVarCategory(name, display)
	self.defaultConVarCategory = name
	self.defaultConVarCategoryDisplay = display
end]]

function InsaneStats:RegisterConVar(name, internal, default, data)
	local conVar
	
	-- if it is of boolean type, only 0 and 1 values are allowed
	if data.type == self.BOOL then
		data.min = 0
		data.max = 1
	end
	
	if data.type == self.FLOAT then
		conVar = CreateConVar(
			internal,
			default,
			bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
			data.desc
		)
	else
		conVar = CreateConVar(
			internal,
			default,
			bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
			data.desc,
			data.min,
			data.max
		)
	end
	
	self.numConVars = self.numConVars + 1
	
	local conVarData = {
		conVar = conVar,
		internal = internal,
		default = default,
		id = self.numConVars
	}
	table.Merge(conVarData, data)
	
	if not conVarData.category then
		conVarData.category = self:GetDefaultConVarCategory()
		--conVarData.category, conVarData.categoryDisplay = self:GetDefaultConVarCategory()
	end
	
	self.conVars[name] = conVarData
	
	return conVar
end

function InsaneStats:GetConVarValue(name)
	local valueType = self.conVars[name].type
	local conVar = self.conVars[name].conVar
	
	if valueType == self.BOOL then
		return conVar:GetBool()
	elseif valueType == self.INT then
		return conVar:GetInt()
	elseif valueType == self.FLOAT then
		return conVar:GetFloat()
	else
		return conVar:GetString()
	end
end

function InsaneStats:GetConVarValueDefaulted(...)
	local vars = {...}
	
	if istable(vars[1]) then
		vars = vars[1]
	end
	
	for i,v in ipairs(vars) do
		if v then
			local value = self:GetConVarValue(v)
			if value >= 0 then
				return value
			end
		end
	end
	
	return self:GetConVarValue(vars[#vars])
end

function InsaneStats:GetConVarData(name)
	return self.conVars[name]
end