-- Checks if the table has value duplicates
-- This assumes that all values in the table can be compared for equality to one another
-- bool <- table tab
function table.HasDuplicates(tab)
	local encountered = {}
	for k,v in pairs(tab) do
		if encountered[v] then return true
		else
			encountered[v] = true
		end
	end
	return false
end

-- Checks if any two tables within the provided table have the same value for a given member
-- This assumes that all member values in the tables can be compared for equality to one another
-- bool <- table tab, any member
function table.HasMemberDuplicates(tab, member)
	local encountered = {}
	for k,v in pairs(tab) do
		if encountered[v[member]] then return true
		else
			encountered[v[member]] = true
		end
	end
	return false
end

-- Returns a table containing value-count pairs, indicating the number of times the values
-- appeared in the given table
-- This assumes that all values in the table can be compared for equality to one another
-- table <- table tab
function table.GetValuesCount(tab)
	local encountered = {}
	for k,v in pairs(tab) do
		encountered[v] = (encountered[v] or 0) + 1
	end
	return encountered
end

-- Returns a table containing value-count pairs, indicating the number of times the values
-- appeared for a specific member across all tables within the given table
-- This assumes that all member values in the tables can be compared for equality to one another
-- table <- table tab, any member
function table.GetMemberValuesCount(tab, member)
	local encountered = {}
	for k,v in pairs(tab) do
		encountered[v[member]] = (encountered[v[member]] or 0) + 1
	end
	return encountered
end

-- Interweaves all passed sequential tables into a new table and returns it
-- The values that are inserted are tab1[1], then tab2[1], then tab3[1], etc.,
-- followed by tab1[2], then tab2[2], then tab3[2], etc., and so on until a nil is encountered in any table
-- table <- table tab1, table tab2, ...
function table.Interweave(tab1, ...)
	local returnTable = {}
	local tablesToWeave = {tab1, ...}
	local index = 1
	for i=1,#tab1 do
		for j,tableToWeave in ipairs(tablesToWeave) do
			local element = tableToWeave[i]
			if element then
				table.insert(returnTable, element)
			else
				return returnTable
			end
		end
	end
	return returnTable
end

-- Linearly interpolates between two Colors, constructs and returns a new Color object
-- every time this function is called
-- Color <- number t, Color firstColor, Color secondColor
function LerpColor(t, firstColor, secondColor)
	return Color(
		Lerp(t, firstColor.r, secondColor.r),
		Lerp(t, firstColor.g, secondColor.g),
		Lerp(t, firstColor.b, secondColor.b),
		Lerp(t, firstColor.a, secondColor.a)
	)
end

-- Creates a new Color object based on the passed hexadecimal string
-- Color, bool <- string colorStr
--[[function util.ConvertHexToColor(colorStr)
	local isGood = true
	local colorAsNumber = tonumber("0x"..colorStr)
	if not colorAsNumber then
		colorAsNumber = 0
		isGood = false
	elseif colorAsNumber > 0xFFFFFFFF or colorAsNumber < 0 then
		isGood = false
	end
	colorAsNumber = bit.tobit(colorAsNumber)
	local newColor = Color(255, 255, 255, 255)
	-- the following might be TOO performance optimized, haha
	local strLen = #colorStr
	if strLen > 6 then
		-- 8-bit + alpha
		newColor.r = bit.rshift(bit.band(colorAsNumber, bit.tobit(0xFF000000)), 24)
		newColor.g = bit.rshift(bit.band(colorAsNumber, 0xFF0000), 16)
		newColor.b = bit.rshift(bit.band(colorAsNumber, 0xFF00), 8)
		newColor.a = bit.band(colorAsNumber, 0xFF)
	elseif strLen > 4 then
		-- 8-bit
		newColor.r = bit.rshift(bit.band(colorAsNumber, 0xFF0000), 16)
		newColor.g = bit.rshift(bit.band(colorAsNumber, 0xFF00), 8)
		newColor.b = bit.band(colorAsNumber, 0xFF)
	elseif strLen > 3 then
		-- 4-bit + alpha
		newColor.r = bit.bor(bit.rshift(bit.band(colorAsNumber, 0xF000), 8), bit.rshift(bit.band(colorAsNumber, 0xF000), 12))
		newColor.g = bit.bor(bit.rshift(bit.band(colorAsNumber, 0xF00), 4), bit.rshift(bit.band(colorAsNumber, 0xF00), 8))
		newColor.b = bit.bor(bit.band(colorAsNumber, 0xF0), bit.rshift(bit.band(colorAsNumber, 0xF0), 4))
		newColor.a = bit.bor(bit.lshift(bit.band(colorAsNumber, 0xF), 4), bit.band(colorAsNumber, 0xF))
	else
		-- 4-bit
		newColor.r = bit.bor(bit.rshift(bit.band(colorAsNumber, 0xF00), 4), bit.rshift(bit.band(colorAsNumber, 0xF00), 8))
		newColor.g = bit.bor(bit.band(colorAsNumber, 0xF0), bit.rshift(bit.band(colorAsNumber, 0xF0), 4))
		newColor.b = bit.bor(bit.lshift(bit.band(colorAsNumber, 0xF), 4), bit.band(colorAsNumber, 0xF))
	end
	return newColor, isGood
end]]

-- Same as string.Explode, except that the seperators are included in the resulting table
-- table <- string seperator, string toExplode, bool withpattern = false
function string.ExplodeIncludeSeperators(seperator, toExplode, withpattern)
	if seperator == "" then return totable(toExplode) end
	withpattern = withpattern or false
	
	local ret = {}
	local current_pos = 1
	
	for i=1,#toExplode do
		local start_pos, end_pos = string.find(toExplode, seperator, current_pos, not withpattern)
		if not start_pos then break end
		table.insert(ret, string.sub(toExplode, current_pos, start_pos-1))
		table.insert(ret, string.sub(toExplode, start_pos, end_pos))
		current_pos = end_pos + 1
	end
	
	table.insert(ret, string.sub(toExplode, current_pos))
	return ret
end

VectorTable = VectorTable or {}

local VECTORTABLE_META_INDEX = {
	-- Sets the VectorTable's elements to another VectorTable's elements
	-- This can change the VectorTable's shape
	-- Both tables remain fully independent
	-- nil <- VectorTable vectorTable, VectorTable vectorTable2
	Set = function(vectorTable, vectorTable2)
		for k,v in pairs(vectorTable) do
			if vectorTable[k] ~= vectorTable2[k] then
				vectorTable[k] = vectorTable2[k]
			end
		end
		for k,v in pairs(vectorTable2) do
			if vectorTable[k] ~= vectorTable2[k] then
				vectorTable[k] = vectorTable2[k]
			end
		end
	end,
	
	-- Same as Set but accepts a series of numbers to set the X, Y, Z, etc. to
	-- nil <- VectorTable vectorTable, number x, number y = nil, ...
	SetUnpacked = function(vectorTable, x, ...)
		local scalars = {x, ...}
		for k,v in pairs(vectorTable) do
			vectorTable[k] = scalars[k]
		end
	end,
	
	-- Adds the VectorTable's elements by another VectorTable's elements
	-- nil <- VectorTable vectorTable, VectorTable vectorTable2
	Add = function(vectorTable, vectorTable2)
		for k,v in pairs(vectorTable) do
			vectorTable[k] = v + vectorTable2[k]
		end
	end,
	
	-- Same as Add but accepts a series of numbers to add the X, Y, Z, etc. by
	-- nil <- VectorTable vectorTable, number x, number y = nil, ...
	AddUnpacked = function(vectorTable, x, ...)
		local scalars = {x, ...}
		for k,v in pairs(vectorTable) do
			vectorTable[k] = v + scalars[k]
		end
	end,
	
	-- Adds all of the VectorTable's elements by a number
	-- nil <- VectorTable vectorTable, number scalar
	AddDistributed = function(vectorTable, scalar)
		for k,v in pairs(vectorTable) do
			vectorTable[k] = v + scalar
		end
	end,
	
	-- Subtracts the VectorTable's elements by another VectorTable's elements
	-- nil <- VectorTable vectorTable, VectorTable vectorTable2
	Subtract = function(vectorTable, vectorTable2)
		for k,v in pairs(vectorTable) do
			vectorTable[k] = v - vectorTable2[k]
		end
	end,
	
	-- Same as Subtract but accepts a series of numbers to subtract the X, Y, Z, etc. by
	-- nil <- VectorTable vectorTable, number x, number y = nil, ...
	SubtractUnpacked = function(vectorTable, x, ...)
		local scalars = {x, ...}
		for k,v in pairs(vectorTable) do
			vectorTable[k] = v + scalars[k]
		end
	end,
	
	-- Subtracts all of the VectorTable's elements by a number
	-- nil <- VectorTable vectorTable, number scalar
	SubtractDistributed = function(vectorTable, scalar)
		for k,v in pairs(vectorTable) do
			vectorTable[k] = v - scalar
		end
	end,
	
	-- Multiplies all of the VectorTable's elements by a number
	-- nil <- VectorTable vectorTable, number scalar
	Multiply = function(vectorTable, scalar)
		for k,v in pairs(vectorTable) do
			vectorTable[k] = v * scalar
		end
	end,
	
	-- Divides all of the VectorTable's elements by a number
	-- nil <- VectorTable vectorTable, number scalar
	Divide = function(vectorTable, scalar)
		for k,v in pairs(vectorTable) do
			vectorTable[k] = v / scalar
		end
	end,
	
	-- Rotates the VectorTable clockwise around its origin, only rotates around x and y
	-- nil <- VectorTable vectorTable, number radians
	Rotate = function(vectorTable, radians)
		local sinAng = math.sin(radians)
		local cosAng = math.cos(radians)
		local x, y = unpack(vectorTable)
		vectorTable[1] = x*cosAng-y*sinAng
		vectorTable[2] = x*sinAng+y*cosAng
	end,
	
	-- Same as Rotate but returns a new VectorTable without changing the original VectorTable
	-- VectorTable <- VectorTable vectorTable, number radians
	GetRotated = function(vectorTable, radians)
		local sinAng = math.sin(radians)
		local cosAng = math.cos(radians)
		local x, y = unpack(vectorTable)
		return vectorTable(x*cosAng-y*sinAng, x*sinAng+y*cosAng)
	end,
	
	Bearing = function(vectorTable, vectorTable2)
		return math.atan2(vectorTable2[1] - vectorTable[1], vectorTable2[2] - vectorTable[2])
	end,
	
	-- Creates a new VectorTable, where its elements are a fraction of the distance to another VectorTable
	-- nil <- VectorTable vectorTable, number frac, VectorTable vectorTable2
	Lerp = function(vectorTable, frac, vectorTable2)
		local diff = vectorTable2 - vectorTable
		diff:Multiply(frac)
		return vectorTable + diff
	end,
	
	-- Returns the distance between two VectorTables
	-- Internally uses the DistanceSquared method
	-- number <- VectorTable vectorTable, VectorTable vectorTable2
	Distance = function(vectorTable, vectorTable2)
		return math.sqrt(vectorTable:DistanceSquared(vectorTable2))
	end,
	
	-- Returns the squared distance between two VectorTables
	-- This is way faster than (vectorTable:Distance(vectorTable2))^2
	-- number <- VectorTable vectorTable, VectorTable vectorTable2
	DistanceSquared = function(vectorTable, vectorTable2)
		local distance = 0
		for k,v in pairs(vectorTable) do
			distance = distance + (v - vectorTable2[k])^2
		end
		return distance
	end,
	
	-- Checks if the VectorTable has its X, Y, Z, etc. within a range of values
	-- bool <- VectorTable vectorTable, number minX, number maxX, number minY = nil, number maxY = nil, ...
	WithinBox = function(vectorTable, minX, maxX, ...)
		local bounds = {{minX, maxX}}
		for i,v in ipairs({...}) do
			if i%2==1 then
				table.insert(bounds, {v})
			else
				table.insert(bounds[#bounds], v)
			end
		end
		
		for k,v in pairs(bounds) do
			local vectorTableValue = vectorTable[k]
			if vectorTableValue < v[1] or vectorTableValue > v[2] then return false end
		end
		return true
	end,
	
	-- Copies and returns a new VectorTable
	-- VectorTable <- VectorTable vectorTable
	Copy = function(vectorTable)
		return VectorTable(unpack(vectorTable))
	end,
	
	-- Returns the VectorTable's X, Y, Z, etc. values, starting from element i and ending at j
	-- vararg(number) <- VectorTable vectorTable, number i = 1, number j = #vectorTable
	Unpack = function(...)
		return unpack(...)
	end
}

local VECTORTABLE_META = {
	__index = VECTORTABLE_META_INDEX,
	
	-- Same as VectorTable (the function), the original VectorTable (first argument) is ignored 
	-- VectorTable <- VectorTable vectorTable, number x = nil, number y = nil, ...
	__call = function(vectorTable, ...)
		return VectorTable(...)
	end,
	
	-- Same as Add but returns a new VectorTable
	-- VectorTable <- VectorTable vectorTable, VectorTable vectorTable2
	__add = function(vectorTable, vectorTable2)
		local newVectorTable = VectorTable()
		for k,v in pairs(vectorTable) do
			newVectorTable[k] = v + vectorTable2[k]
		end
		return newVectorTable
	end,
	
	-- Same as Sub but returns a new VectorTable
	-- VectorTable <- VectorTable vectorTable, VectorTable vectorTable2
	__sub = function(vectorTable, vectorTable2)
		local newVectorTable = VectorTable()
		for k,v in pairs(vectorTable) do
			newVectorTable[k] = v - vectorTable2[k]
		end
		return newVectorTable
	end,
	
	__tostring = function(vectorTable)
		local builtString = "("
		for i,v in ipairs(vectorTable) do
			builtString = builtString..string.format("%.2f", v)..","
		end
		builtString = string.sub(builtString, 1, -2)
		return builtString
	end
	
	-- Returns the number of elements in the VectorTable
	-- number <- VectorTable vectorTable
	-- __len = function(vectorTable)
		-- same as default implementation
	-- end
}

-- Creates a new VectorTable, number of elements is equal to the number of arguments
-- VectorTable <- number x = nil, number y = nil, ...
function VectorTable(...)
	local vectorTable = {...}
	setmetatable(vectorTable, VECTORTABLE_META)
	return vectorTable
end