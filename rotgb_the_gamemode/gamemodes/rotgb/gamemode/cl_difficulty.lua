function GM:ReceiveMapDifficulties()
	if not hook.Run("GetDifficulties") then
		hook.Run("InitializeDifficulties")
	end
	local difficulties = hook.Run("GetDifficulties")
	local difficultyCategories = hook.Run("GetDifficultyCategories")
	
	local elements = net.ReadUInt(16)
	for i=1,elements do
		local id = net.ReadString()
		if id == "*" and elements == 1 then
			for k,v in pairs(difficulties) do
				if not v.custom and k ~= "__common" then
					difficulties[k] = nil
				end
			end
		else
			if (difficulties[id] and not difficulties[id].custom and id ~= "__common") then
				difficulties[id] = nil
			end
		end
	end
	
	for i=1,net.ReadUInt(16) do
		local difficultyTable = {}
		local customID = net.ReadString()
		
		difficultyTable.category = net.ReadString()
		difficultyTable.position = net.ReadFloat()
		difficultyTable.convars = {}
		
		for i=1,net.ReadUInt(16) do
			local key = net.ReadString()
			difficultyTable.convars[key] = net.ReadString()
		end
		
		difficulties[customID] = difficultyTable
	end
	
	for i=1,net.ReadUInt(16) do
		local category = net.ReadString()
		difficultyCategories[category] = net.ReadFloat()
	end
end