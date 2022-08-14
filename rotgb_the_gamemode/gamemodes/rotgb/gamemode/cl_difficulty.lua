concommand.Add("rotgb_tg_difficulty_menu", function()
	hook.Run("ShowDifficultySelection")
end, nil, "Opens the Difficulty Selection Menu. Only works for admins.")

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

function GM:GetGamemodeDifficultyNodes()
	local nodesByCategory = {}
	local completedDifficulties = {}
	
	for map,difficulties in pairs(hook.Run("GetCompletedDifficulties")) do
		for difficulty,state in pairs(difficulties) do
			completedDifficulties[difficulty] = bit.bor(state, completedDifficulties[difficulty] or 0)
		end
	end
	
	for k,v in pairs(hook.Run("GetDifficulties")) do
		if v.category and hook.Run("IsDifficultyUnlocked", k) then
			-- check prerequisites
			local prerequisitesMet = true
			for k2,v2 in pairs(v.prerequisites or {}) do
				if (completedDifficulties[v2] or 0) == 0 then
					prerequisitesMet = false break
				end
			end
			if prerequisitesMet then
				local subnode = {
					name = k,
					place = v.place
				}
				nodesByCategory[v.category] = nodesByCategory[v.category] or {}
				table.insert(nodesByCategory[v.category], subnode)
			end
		end
	end
	
	for k,v in pairs(nodesByCategory) do
		table.SortByMember(v, "place", true)
	end
	
	local nodes = {}
	for k,v in pairs(nodesByCategory) do
		local node = {
			name = k,
			place = hook.Run("GetDifficultyCategories")[k],
			subnodes = nodesByCategory[k]
		}
		table.insert(nodes, node)
	end
	
	table.SortByMember(nodes, "place", true)
	return nodes
end

function GM:AddCompletedDifficulties(map, difficulty, state)
	local completedDifficulties = hook.Run("GetCompletedDifficulties")
	local difficulties = hook.Run("GetDifficulties")
	completedDifficulties[map] = completedDifficulties[map] or {}
	local completedMapDifficulties = completedDifficulties[map]
	completedMapDifficulties[difficulty] = bit.bor(completedMapDifficulties[difficulty] or 0, state)
	
	local allComplete = true
	for k,v in pairs(difficulties) do
		if k ~= "__common" and (completedMapDifficulties[k] or 0) == 0 and not v.extra then
			allComplete = false break
		end
		
		if not allComplete then break end
	end
	
	if allComplete then
		net.Start("rotgb_gamemode")
		net.WriteUInt(RTG_OPERATION_ACHIEVEMENT, 4)
		net.WriteUInt(hook.Run("GetStatisticID", "success.all")-1, 16)
		net.SendToServer()
	end
end