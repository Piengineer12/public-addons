AccessorFunc(GM, "NightmareBeatenPlayers", "NightmareBeatenPlayers")

function GM:SendMapDifficulties()
	local toSend = {}
	local allDifficulties = hook.Run("GetDifficulties")
	local customCategories = hook.Run("GetDifficultyCategoriesCustom")
	local customRemovedDifficulties = hook.Run("GetCustomRemovedDifficulties")
	
	for k,v in pairs(allDifficulties) do
		if v.custom and hook.Run("IsDifficultyUnlocked", k) then
			table.insert(toSend, k)
		end
	end
	
	net.WriteUInt(#customRemovedDifficulties, 16)
	for k,v in pairs(customRemovedDifficulties) do
		net.WriteString(v)
	end
	
	net.WriteUInt(#toSend, 16)
	for k,v in pairs(toSend) do
		local diff = allDifficulties[v]
		
		net.WriteString(v)
		net.WriteString(diff.category)
		net.WriteFloat(diff.place)
		
		net.WriteUInt(table.Count(diff.convars), 16)
		for k2,v2 in pairs(diff.convars) do
			net.WriteString(k2)
			net.WriteString(v2)
		end
	end
	
	net.WriteUInt(table.Count(customCategories), 16)
	for k,v in pairs(customCategories) do
		net.WriteString(k)
		net.WriteFloat(v)
	end
end

function GM:ChangeDifficulty(difficulty)
	-- if it is October and no players have beaten it, have a 5% chance to switch the difficulty to Special - Nightmare
	if os.date("%m") == "10" and math.random() < 0.05 then
		local cancel = false
		for k,v in pairs(hook.Run("GetNightmareBeatenPlayers")) do
			if IsValid(k) then
				cancel = true break
			end
		end
		if not cancel then
			difficulty = "special_nightmare"
		end
	end
	
	-- set the current difficulty for the ShouldConVarOverride hook to refer to, then clean up the map
	hook.Run("SetDifficulty", difficulty)
	net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_DIFFICULTY, 4)
	net.WriteString(difficulty)
	net.Broadcast()
	hook.Run("CleanUpMap")
end