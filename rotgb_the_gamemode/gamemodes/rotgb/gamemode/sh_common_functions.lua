-- Checks if the table has value duplicates
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
function table.GetValuesCount(tab)
	local encountered = {}
	for k,v in pairs(tab) do
		encountered[v] = (encountered[v] or 0) + 1
	end
	return encountered
end

-- Returns a table containing value-count pairs, indicating the number of times the values
-- appeared for a specific member across all tables within the given table
function table.GetMemberValuesCount(tab, member)
	local encountered = {}
	for k,v in pairs(tab) do
		encountered[v[member]] = (encountered[v[member]] or 0) + 1
	end
	return encountered
end