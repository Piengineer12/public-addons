local mapOrder = {}
local mapNumber = 0
local mapTimeOffset = CurTime() / 60
concommand.Add("insanestats_xp_other_level_maps_show", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		if argStr == "unrecorded" then
			local recordedMaps = {}
			for i,v in ipairs(mapOrder) do
				recordedMaps[v] = true
			end
	
			local unrecordedMaps = {}
			for i,v in ipairs(file.Find("maps/*.bsp", "GAME")) do
				local mapName = v:StripExtension()
				if not recordedMaps[mapName] then
					table.insert(unrecordedMaps, mapName)
				end
			end
	
			print("These are the unrecorded maps:")
			PrintTable(unrecordedMaps)
		elseif argStr == "nonexistent" then
			local existentMaps = {}
			for i,v in ipairs(file.Find("maps/*.bsp", "GAME")) do
				local mapName = v:StripExtension()
				existentMaps[mapName] = true
			end

			local neMapOrder = {}
			for i,v in ipairs(mapOrder) do
				if not existentMaps[v] then
					table.insert(neMapOrder, v)
				end
			end
			print("These are the nonexistent maps:")
			PrintTable(neMapOrder)
		else
			print("These are the recorded maps:")
			PrintTable(mapOrder)
			print("You are on map #"..mapNumber..".")
		end
	end
end, function(cmd, argStr)
	local suggestions = {}
	argStr = argStr:Trim()
	if ("nonexistent"):find(argStr) then
		table.insert(suggestions, cmd.." nonexistent")
	end
	if ("unrecorded"):find(argStr) then
		table.insert(suggestions, cmd.." unrecorded")
	end
	return suggestions
end, "Shows all maps that are currently factored into level scaling.\n\z
Passing in \"unrecorded\" will show all maps that are NOT currently factored, \z
while \"nonexistent\" will show all maps that are factored but non-existent.")
concommand.Add("insanestats_xp_other_level_maps_reset", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		mapOrder = {}
		InsaneStats:Log("All maps removed.")
		InsaneStats:Log("Run the command insanestats_save to save the current map list!")
	end
end, nil, "Clears the recorded maps list. \z
Note that a map restart is required for the map number to be updated.")
concommand.Add("insanestats_xp_other_level_maps_remove", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		-- use a search pattern
		local success = false
		local i = 1
		local v = mapOrder[i]
		while v do
			if InsaneStats:WildcardMatches(argStr, v) then
				table.remove(mapOrder, i)
				InsaneStats:Log("Removed map %s.", v)
				success = true
			else
				i = i + 1
			end
			v = mapOrder[i]
		end
		if success then
			return InsaneStats:Log("Run the command insanestats_save to save the current map list!")
		end
		
		if tonumber(argStr) then
			local toRemove = math.min(#mapOrder, tonumber(argStr) or 0)
			for i=1, toRemove do
				local value = table.remove(mapOrder)
				InsaneStats:Log("Removed map %s.", value)
			end
			InsaneStats:Log("Run the command insanestats_save to save the current map list!")
		elseif argStr == "@" then
			local toRemove = game.GetMap()
			local success = table.RemoveByValue(mapOrder, toRemove)
			if success then
				InsaneStats:Log("Removed map %s.", toRemove)
				InsaneStats:Log("Run the command insanestats_save to save the current map list!")
			else
				InsaneStats:Log("Could not find map %s.", toRemove)
			end
		elseif argStr == "" then
			InsaneStats:Log("Removes maps from the recorded maps list. * and ? wildcards are allowed. \z
			If a number is given (and no matching map was found), the number will be interpreted as the number of recent maps to remove. \z
			Note that a map restart is required for the map number to be updated.")
		else
			InsaneStats:Log("Could not find map %s.", argStr)
		end
	end
end, nil, "Removes maps from the recorded maps list. * and ? wildcards are allowed. \z
If a number is given (and no matching map was found), the number will be interpreted as the number of recent maps to remove. \z
If @ is given (and no matching map was found), the current map will be removed. \z
Note that a map restart is required for the map number to be updated.")
concommand.Add("insanestats_xp_other_level_maps_add", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		if argStr:find("[%*%?]") then
			-- use a search pattern
			local recordedMaps = {}
			for i,v in ipairs(mapOrder) do
				recordedMaps[v] = true
			end

			local success = false
			for i,v in ipairs(file.Find("maps/*.bsp", "GAME")) do
				local mapName = v:StripExtension()
				if not recordedMaps[mapName] and InsaneStats:WildcardMatches(argStr, mapName) then
					table.insert(mapOrder, mapName)
					InsaneStats:Log("Added map %s.", mapName)
					success = true
				end
			end

			if success then
				return InsaneStats:Log("Run the command insanestats_save to save the current map list!")
			end
			
			if argStr == "" then
				InsaneStats:Log("Adds maps to the recorded maps list. * and ? wildcards are allowed. \z
				Note that a map restart is required for the map number to be updated.")
			else
				InsaneStats:Log("Could not find map %s.", argStr)
			end
		elseif table.HasValue(mapOrder, argStr) then
			InsaneStats:Log("%s is already in the recorded maps list.", argStr)
		elseif mapOrder == "" then
			InsaneStats:Log("Adds maps to the recorded maps list. * and ? wildcards are allowed. \z
			Note that a map restart is required for the map number to be updated.")
		else
			table.insert(mapOrder, argStr)
			InsaneStats:Log("Added map %s.", argStr)
			InsaneStats:Log("Run the command insanestats_save to save the current map list!")
		end
	end
end, nil, "Adds maps to the recorded maps list. * and ? wildcards are allowed. \z
Note that a map restart is required for the map number to be updated.")
concommand.Add("insanestats_xp_other_level_time_show", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		InsaneStats:Log("%g minutes have passed.", CurTime() / 60 - mapTimeOffset)
	end
end, nil, "Shows the number of minutes passed regarding time-based level scaling.")
concommand.Add("insanestats_xp_other_level_time_set", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		if #args == 0 then
			InsaneStats:Log(
				"Sets time-based level scaling back to the specified number of minutes. \z
				Usage: insanestats_xp_other_level_time_set <minutes>"
			)
		elseif tonumber(argStr) then
			local minutes = tonumber(argStr)
			mapTimeOffset = CurTime() / 60 - minutes
			InsaneStats:Log("Time-based level scaling set to %g minutes.", minutes)
		else
			InsaneStats:Log("\"%s\" is not a valid number.", argStr)
		end
	end
end, nil, "Sets time-based level scaling back to the specified number of minutes. \z
Usage: insanestats_xp_other_level_time_set <minutes>")

concommand.Add("insanestats_xp_player_level_set", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		if #args == 0 then
			InsaneStats:Log("Sets a player's level. Usage: insanestats_xp_player_level_set [player] <level>")
		else
			local plyStr = table.concat(args, ' ', 1, #args-1)
			local levelStr = args[#args]
			
			if plyStr ~= "" then
				-- scan for player
				local foundPlayer = false
				for i,v in player.Iterator() do
					if v:Nick() == plyStr then
						ply = v
						foundPlayer = true
						break
					end
				end
				
				if not foundPlayer then
					InsaneStats:Log("Could not find player \"%s\".", plyStr)
					return
				end
			end
			
			local level = tonumber(levelStr)
			if level then
				ply:InsaneStats_SetXP(InsaneStats:GetXPRequiredToLevel(level))
			else
				InsaneStats:Log("\"%s\" is not a valid number.", levelStr)
			end
		end
	end
end, function(cmd, argStr)
	local suggestions = {}
	argStr = argStr:Trim()
	
	for i,v in player.Iterator() do
		if string.StartsWith(v:Nick():Trim(), argStr) then
			table.insert(suggestions, cmd.." \""..v:Nick().."\"")
		end
	end
	
	return suggestions
end, "Sets a player's level. Usage: insanestats_xp_player_level_set [player] <level>")

local ENT = FindMetaTable("Entity")

function ENT:InsaneStats_ApplyLevel(level)
	if InsaneStats:GetConVarValue("xp_enabled") and (self:GetModel() or "") ~= "" then
		local isPlayer = self:IsPlayer()
		
		--[[local currentHealthFrac = (self:InsaneStats_GetMaxHealth() <= 0
			or self:InsaneStats_GetHealth() == math.huge) and 1
			or self:InsaneStats_GetHealth() / self:InsaneStats_GetMaxHealth()]]
		local currentHealthFrac = self:InsaneStats_GetHealth() / self:InsaneStats_GetMaxHealth()
		local currentHealthAdd = self:InsaneStats_GetCurrentHealthAdd()
		local startingHealth = self:InsaneStats_GetMaxHealth() / currentHealthAdd
		--print(self:InsaneStats_GetMaxHealth(), currentHealthAdd)
		local newHealth
		if isPlayer then
			newHealth = math.floor(InsaneStats:ScaleValueToLevel(
				startingHealth,
				InsaneStats:GetConVarValue("xp_player_health")/100,
				level,
				"xp_player_health_mode"
			))
		else
			newHealth = math.floor(InsaneStats:ScaleValueToLevel(
				startingHealth,
				InsaneStats:GetConVarValue("xp_other_health")/100,
				level,
				"xp_other_health_mode"
			))
		end
		if not (newHealth >= -math.huge) then
			print(
				self:InsaneStats_GetMaxHealth(), currentHealthAdd, InsaneStats:GetConVarValue("xp_other_health")/100,
				level
			)
		end
		self:SetMaxHealth(newHealth)
		if math.abs(currentHealthFrac) < math.huge then
			self:SetHealth(currentHealthFrac * newHealth)
		end
		if newHealth == math.huge or startingHealth == 0 then
			self:InsaneStats_SetCurrentHealthAdd(1)
		else
			self:InsaneStats_SetCurrentHealthAdd(newHealth / startingHealth)
		end
		
		if self:InsaneStats_GetMaxArmor() > 0 then
			local currentArmorFrac = self:InsaneStats_GetMaxArmor() == 0 and 0
				or self:InsaneStats_GetArmor() == math.huge and 1
				or self:InsaneStats_GetArmor() / self:InsaneStats_GetMaxArmor()
			local currentArmorAdd = self:InsaneStats_GetCurrentArmorAdd()
			local startingArmor = self:InsaneStats_GetMaxArmor() / currentArmorAdd
			local newArmor
			local scaleType = isPlayer and "player" or "other"
			newArmor = math.floor(InsaneStats:ScaleValueToLevel(
				startingArmor,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_armor")/100,
				level,
				"xp_"..scaleType.."_armor_mode"
			))
			if newArmor == math.huge then
				currentArmorFrac = 1
			elseif not (newArmor >= -math.huge) then
				print(
					self:InsaneStats_GetMaxArmor(), currentArmorAdd, InsaneStats:GetConVarValue("xp_other_armor")/100,
					level
				)
			end
			self:SetMaxArmor(newArmor)
			self:SetArmor(currentArmorFrac * newArmor)
			if newArmor == math.huge or startingArmor == 0 then
				self:InsaneStats_SetCurrentArmorAdd(1)
			else
				self:InsaneStats_SetCurrentArmorAdd(newArmor / startingArmor)
			end
		end

		if InsaneStats:IsDebugLevel(3) then
			InsaneStats:Log("%s level updated, health = %g, max health = %g", tostring(self), self:Health(), self:GetMaxHealth())
		end
		
		hook.Run("InsaneStatsApplyLevel", self, level)
	end
end

function ENT:InsaneStats_SetCurrentHealthAdd(mul)
	if mul == math.huge then
		mul = 1
		InsaneStats:Log("Something tried to set starting health of %s to inf.", tostring(self))
		debug.Trace()
	end
	self:InsaneStats_SetEntityData("xp_health_mul", mul)
	self.insaneStats_CurrentHealthAddRoot8 = InsaneStats:CalculateRoot8(mul)
end

function ENT:InsaneStats_GetCurrentHealthAdd()
	local currentAdd = self:InsaneStats_GetEntityData("xp_health_mul") or 1
	if not (currentAdd > 0) then currentAdd = 1 end
	return currentAdd
end

function ENT:InsaneStats_SetCurrentArmorAdd(mul)
	if mul == math.huge then
		mul = 1
		InsaneStats:Log("Something tried to set starting armor of %s to inf.", tostring(self))
		debug.Trace()
	end
	self:InsaneStats_SetEntityData("xp_armor_mul", mul)
	self.insaneStats_CurrentArmorAddRoot8 = InsaneStats:CalculateRoot8(mul)
end

function ENT:InsaneStats_GetCurrentArmorAdd()
	local currentAdd = self:InsaneStats_GetEntityData("xp_armor_mul") or 1
	if not (currentAdd > 0) then currentAdd = 1 end
	return currentAdd
end

function ENT:InsaneStats_SetDropXP(xp)
	self:InsaneStats_SetEntityData("xp_drop", xp)
end

function ENT:InsaneStats_GetDropXP()
	return self:InsaneStats_GetEntityData("xp_drop") or 0
end

local savedPlayerXP = {}

hook.Add("InsaneStatsScaleXP", "InsaneStatsXP", function(data)
	local attacker = data.attacker
	local inflictor = data.inflictor
	local victim = data.victim

	data.xp = InsaneStats:ScaleValueToLevel(
		data.xp,
		InsaneStats:GetConVarValue("xp_drop_add")/100,
		victim:InsaneStats_GetLevel(),
		"xp_drop_add_mode"
	)

	if attacker:IsPlayer() then
		local shareFactor = InsaneStats:GetConVarValue("xp_player_share") / 100
		for i,v in ipairs(team.GetPlayers(attacker:Team())) do
			if v ~= attacker and v ~= inflictor then
				data.receivers[v] = (data.receivers[v] or 0) + shareFactor
			end
		end
	end

	local dayOfTheWeek = tonumber(os.date("%w")) or -1
	local weekdayFactors = InsaneStats:GetConVarValue(
		victim:IsPlayer() and "xp_player_weekday_mul" or "xp_other_weekday_mul"
	)
	local weekdayFactor = ""
	local i = 0
	for factor in string.gmatch(weekdayFactors, "%S+") do
		if i == dayOfTheWeek then
			weekdayFactor = factor break
		end
		i = i + 1
	end
	if tonumber(weekdayFactor) then
		weekdayFactor = tonumber(weekdayFactor)
	else
		weekdayFactor = 1
		InsaneStats:Log(
			"Failed to parse weekday drop multiplier \"%s\" for %s!",
			weekdayFactor, os.date("%A")
		)
	end

	data.xp = data.xp * weekdayFactor
end)

local function ProcessKillEvent(victim, attacker, inflictor)
	if IsValid(victim) then
		-- determine attacker and inflictor
		if IsValid(victim.insaneStats_LastAttacker) then
			if (IsValid(attacker) and attacker:GetClass() == "entityflame") then
				inflictor = attacker
				attacker = victim.insaneStats_LastAttacker
			elseif not (IsValid(attacker) and attacker ~= victim) then
				attacker = victim.insaneStats_LastAttacker
				inflictor = victim.insaneStats_LastAttacker
			end
		end
		
		if not IsValid(attacker) and IsValid(inflictor) then
			attacker = inflictor
		elseif (not IsValid(inflictor) or inflictor == attacker) and (attacker.GetActiveWeapon and IsValid(attacker:GetActiveWeapon())) then
			inflictor = attacker:GetActiveWeapon()
		end
		
		inflictor = IsValid(inflictor) and inflictor or attacker
		if InsaneStats:IsDebugLevel(2) then
			InsaneStats:Log("%s killed %s with %s", tostring(attacker), tostring(victim), tostring(inflictor))
		end
		
		-- we WANT this to be called multiple times, in case the victim gained XP after being revived
		if InsaneStats:GetConVarValue("xp_enabled") then
			if IsValid(attacker) and victim ~= attacker then
				local xpMul = InsaneStats:GetConVarValue(victim:IsPlayer() and "xp_player_mul" or "xp_other_mul")
				local currentHealthAdd = victim:InsaneStats_GetCurrentHealthAdd()
				local startingHealth = victim:InsaneStats_GetMaxHealth() / currentHealthAdd
				local currentArmorAdd = victim:InsaneStats_GetCurrentArmorAdd()
				local startingArmor = victim:InsaneStats_GetMaxArmor() / currentArmorAdd

				local startXPToGive = victim.insaneStats_IsDead and 0
				or (startingHealth + startingArmor) * xpMul / 5
				
				if InsaneStats:IsDebugLevel(2) then
					InsaneStats:Log("%s should drop %g base XP", tostring(victim), startXPToGive)
					if victim.insaneStats_IsDead then
						InsaneStats:Log("because the victim was dead before")
					end
				end
				
				--print(startXPToGive)
				-- do not add XP on nan
				if not (startXPToGive >= -math.huge) then
					startXPToGive = 0
				end
				
				local data = {
					xp = startXPToGive,
					attacker = attacker, inflictor = inflictor, victim = victim,
					receivers = {[attacker] = 1, [inflictor] = 1}
				}
				hook.Run("InsaneStatsScaleXP", data)
				
				local xpToGive = data.xp + victim:InsaneStats_GetDropXP()
				--print(xpToGive)
				local extraXP = 0
				
				local xpDropMul = 1
				if victim:IsPlayer() then
					xpDropMul = InsaneStats:GetConVarValue("xp_player_kill")
				else
					xpDropMul = InsaneStats:GetConVarValue("xp_other_kill")
					
					if xpToGive > 0 then
						-- give extra xp based on xp required by victim
						-- to get from current level to next level
						-- plus xp required to get to current level
						local level = victim:InsaneStats_GetLevel()
						local currentXP = InsaneStats:GetXPRequiredToLevel(level)
						if currentXP ~= math.huge then
							local toLevelUp = currentXP - InsaneStats:GetXPRequiredToLevel(level-1)
							local victimGiveXP = victim:InsaneStats_GetXP() * InsaneStats:GetConVarValue("xp_other_extra")/100
							extraXP = toLevelUp + victimGiveXP
							if InsaneStats:IsDebugLevel(2) then
								InsaneStats:Log("%s, who needs %g xp to level up received a bonus of %g xp", tostring(attacker), toLevelUp, extraXP)
							end
							--print(currentXP, extraXP)
						else
							extraXP = math.huge
						end
					end
				end
				
				--print(xpToGive, xpDropMul)
				
				data.receivers[victim] = nil
				-- shouldDropMul contains entities that DIRECTLY caused the entity to drop EXP, not other receivers
				-- else we get an infinite loop
				local shouldDropMul = {[attacker] = true, [inflictor] = true}
				for k,v in pairs(shouldDropMul) do
					local wep = k.GetActiveWeapon and k:GetActiveWeapon()
					if IsValid(wep) then
						shouldDropMul[wep] = true
					end
					
					local driver = k.GetDriver and k:GetDriver()
					if IsValid(driver) then
						shouldDropMul[driver] = true
					end
				end
				
				if InsaneStats:IsDebugLevel(2) then
					InsaneStats:Log("Distributing %g XP to the following entities:", xpToGive)
					PrintTable(data.receivers)
				end
				local wepMul = InsaneStats:GetConVarValue("xp_weapon_mul")
				for k,v in pairs(data.receivers) do
					local tempExtraXP = (k:IsPlayer() or k:GetOwner():IsPlayer()) and 0 or extraXP-- * v
					local tempDropMul = shouldDropMul[k] and xpDropMul or 0
					local xp = xpToGive * v
					if k:IsWeapon() then xp = xp * wepMul end
					if xp+tempExtraXP < -k:InsaneStats_GetXP() then
						xp = -k:InsaneStats_GetXP() - tempExtraXP
					end
					--print("k, xp, extraXP, tempExtraXP, tempDropMul")
					--print(k, xp, extraXP, tempExtraXP, tempDropMul)
					--print(k, xp, xpToGive, v, victim:InsaneStats_GetDropXP(), tempExtraXP)
					k:InsaneStats_AddXP(xp+tempExtraXP, xp*tempDropMul)
					k:InsaneStats_AddBatteryXP(xp)
					
					local driver = k.GetDriver and k:GetDriver()
					if IsValid(driver) and not data.receivers[driver] then
						driver:InsaneStats_AddXP(xp+tempExtraXP, xp*tempDropMul)
						driver:InsaneStats_AddBatteryXP(xp)
					end
					
					local wep = k.GetActiveWeapon and k:GetActiveWeapon()
					if IsValid(wep) and not data.receivers[wep] then
						if wep:IsWeapon() then xp = xp * wepMul end
						--print(wep, xp, xpToGive, victim:InsaneStats_GetDropXP(), tempExtraXP)
						wep:InsaneStats_AddXP((xp+tempExtraXP)*wepMul, xp*tempDropMul)
						wep:InsaneStats_AddBatteryXP(xp*wepMul)
					end
				end
				
				--print(attackerXP, attackerXP*xpDropMul)
			end
			
			if victim:IsPlayer() then
				-- deduct xp %
				local newXP = victim:InsaneStats_GetXP() * (1-InsaneStats:GetConVarValue("xp_player_lose")/100)
				victim:InsaneStats_SetXP(newXP, 0)
			end

			victim:InsaneStats_SetDropXP(0)
		end
		
		hook.Run("InsaneStatsEntityKilledPostXP", victim, attacker, inflictor)
		if not victim.insaneStats_IsDead then
			hook.Run("InsaneStatsEntityKilledOnce", victim, attacker, inflictor)
			victim.insaneStats_IsDead = true
		end
	end
end

hook.Add("InsaneStatsEntityKilled", "InsaneStatsXP", function(victim, attacker, inflictor)
	ProcessKillEvent(victim, attacker, inflictor)

	if InsaneStats:GetConVarValue("xp_enabled") then
		local wep = victim.GetActiveWeapon and victim:GetActiveWeapon()
		if victim:IsNPC() and (IsValid(wep) and wep:GetClass() == "weapon_smg1") then
			-- FIXME: what exactly is affecting the number of bullets in the clip?
			timer.Simple(0, function()
				if IsValid(wep) then
					if wep.InsaneStats_SetRawClip1 then
						wep:InsaneStats_SetRawClip1(45)
					else
						wep:SetClip1(45)
					end
				end
			end)
		end
	end
end)

function InsaneStats:DetermineEntitySpawnedXP(ent)
	local owner = ent:GetOwner()
	if IsValid(owner) and owner:InsaneStats_GetXP() >= 0 then return owner:InsaneStats_GetXP() end

	-- get base level
	local level = self:GetConVarValue("xp_other_level_start")
	local playerCount = math.max(player.GetCount(), 1)
	local hasPlayer = false
	
	for i,v in player.Iterator() do
		if v:InsaneStats_GetEntityData("xp") then
			hasPlayer = true break
		end
	end
	
	local typ = self:GetConVarValue("xp_other_level_factor")
	if typ > 0 then
		if hasPlayer then
			if typ == 1 then
				-- get average level
				local totalLevel = 0
				for i,v in player.Iterator() do
					if v:InsaneStats_GetEntityData("xp") then
						totalLevel = totalLevel + v:InsaneStats_GetLevel()
					end
				end
				
				level = level + totalLevel / playerCount
			elseif typ == 2 then
				-- get geometric average level
				local totalLevel = 1
				local inversePlayerCount = 1/playerCount
				for i,v in player.Iterator() do
					if v:InsaneStats_GetEntityData("xp") then
						totalLevel = totalLevel * v:InsaneStats_GetLevel() ^ inversePlayerCount
					end
				end
				
				level = level + totalLevel
			elseif typ == 3 then
				-- get highest level
				local highestLevel = 1
				for i,v in player.Iterator() do
					highestLevel = math.max(highestLevel, v:InsaneStats_GetLevel())
				end
				
				level = level + highestLevel
			elseif typ == 4 then
				-- get nearest player
				local pos = ent:GetPos()
				local closestPlayer = game.GetWorld()
				local closestSqrDist = math.huge
				for i,v in player.Iterator() do
					local sqrDist = pos:DistToSqr(v:GetPos())
					if sqrDist < closestSqrDist and v:InsaneStats_GetEntityData("xp") then
						closestPlayer = v
						closestSqrDist = sqrDist
					end
				end
				
				level = level + closestPlayer:InsaneStats_GetLevel()
			end
		else return
		end
	end

	local minimum = level + self:GetConVarValue("xp_other_level_maps_minimum") * (mapNumber - 1)
	local current = self:ScaleValueToLevel(
		level,
		self:GetConVarValue("xp_other_level_maps")/100,
		mapNumber - 1,
		"xp_other_level_maps_mode",
		true
	)
	level = math.max(minimum, current)

	local curMinutes = CurTime() / 60 - mapTimeOffset
	minimum = level + self:GetConVarValue("xp_other_level_time_minimum") * curMinutes
	current = self:ScaleValueToLevel(level, self:GetConVarValue("xp_other_level_time")/100, curMinutes, "xp_other_level_time_mode", true)
	level = math.max(minimum, current)
	--print(pos, "has time scaled level", math.max(minimum, current))
	--print(pos, "has player count scaled level", level)
	
	level = math.max(level, 1)

	local playerXPMul = 1 + self:GetConVarValue("xp_other_level_players")/100 * (playerCount - 1)

	local driftXPFactor = math.random()*2-1
	driftXPFactor = driftXPFactor * math.random() ^ self:GetConVarValue("xp_other_level_drift_harshness")
	driftXPFactor = self:GetConVarValue("xp_other_level_drift") ^ driftXPFactor

	local alphaXPMul = 1
	local isAlpha = math.random()*100 < self:GetConVarValue("xp_other_alpha_chance")
	isAlpha = hook.Run("InsaneStatsEntityShouldBeAlpha", ent) or isAlpha
	if isAlpha then
		alphaXPMul = self:GetConVarValue("xp_other_alpha_mul")
	end

	local totalXP = self:GetXPRequiredToLevel(level) * playerXPMul * driftXPFactor * alphaXPMul
	--[[local maxXP = -1
	if hasPlayer and self:GetConVarValue("xp_other_max_mul") >= 0 then
		for i,v in player.Iterator() do
			maxXP = math.max(maxXP, v:InsaneStats_GetEntityData("xp") or -1)
		end
	end
	if maxXP >= 0 then
		maxXP = maxXP * self:GetConVarValue("xp_other_max_mul")
		if maxXP < totalXP then
			totalXP = maxXP
		end
	end]]

	return totalXP, isAlpha
end

function InsaneStats:DetermineDamageMul(vic, dmginfo)
	if self:GetConVarValue("xp_enabled") then
		local attacker = dmginfo:GetAttacker()
		local inflictor = dmginfo:GetInflictor()

		if InsaneStats:IsDebugLevel(4) then
			InsaneStats:Log(
				"Victim is %s, attacker is %s and inflictor is %s",
				tostring(vic), tostring(attacker), tostring(inflictor)
			)
		end
		
		if not (IsValid(attacker) and attacker:GetClass()~="entityflame") and IsValid(vic.insaneStats_LastAttacker) then
			inflictor = attacker
			attacker = vic.insaneStats_LastAttacker
		end
		
		if not IsValid(attacker) and IsValid(inflictor) then
			attacker = inflictor
		elseif (not IsValid(inflictor) or inflictor == attacker) and (attacker.GetActiveWeapon and IsValid(attacker:GetActiveWeapon())) then
			inflictor = attacker:GetActiveWeapon()
		end
		
		if IsValid(inflictor) then
			local inflictorFlags = self:GetConVarValue("xp_damagemode")
			if bit.band(inflictorFlags, 1) ~= 0 and (inflictor:GetPhysicsAttacker() == attacker
		 	or inflictor:GetClass() == "grenade_helicopter") or inflictor:GetClass() == "prop_combine_ball" then
				attacker = inflictor
			elseif bit.band(inflictorFlags, 2) ~= 0 and inflictor:IsWeapon() then
				attacker = inflictor
			end
		end

		if InsaneStats:IsDebugLevel(3) then
			InsaneStats:Log(
				"Levelled damage will be based on %s", tostring(attacker)
			)
		end
		
		return InsaneStats:DetermineDamageMulPure(attacker, vic)
	else
		return 1
	end
end

function InsaneStats:GetRecordedMaps()
	return mapOrder
end

local toUpdateLevelEntities = {}
--local loadedData = {}
hook.Add("InsaneStatsEntityCreated", "InsaneStatsXP", function(ent)
	if ent:InsaneStats_GetXP() == 0 then
		local shouldXP, isAlpha = InsaneStats:DetermineEntitySpawnedXP(ent)
		--print(ent, "should spawn with ", shouldXP, " xp")
		if shouldXP then
			ent:InsaneStats_SetXP(shouldXP)
			ent:InsaneStats_SetIsAlpha(isAlpha)

			if InsaneStats:IsDebugLevel(3) then
				InsaneStats:Log("%s should spawn with %g XP", tostring(ent), shouldXP)
			end
		else
			table.insert(toUpdateLevelEntities, ent)
			
			if InsaneStats:IsDebugLevel(3) then
				InsaneStats:Log("Could not determine XP for %s", tostring(ent))
			end
		end
	end
end)

timer.Create("InsaneStatsXP", 0.5, 0, function()
	if next(toUpdateLevelEntities) then
		for k,v in pairs(toUpdateLevelEntities) do
			if IsValid(v) or v == game.GetWorld() then
				if v:InsaneStats_GetEntityData("xp") then
					toUpdateLevelEntities[k] = nil
				else
					local shouldXP, isAlpha = InsaneStats:DetermineEntitySpawnedXP(v)
					--print(shouldXP)
					if shouldXP then
						v:InsaneStats_SetXP(shouldXP)
						v:InsaneStats_SetIsAlpha(isAlpha)
						toUpdateLevelEntities[k] = nil
					end
				end
			else
				toUpdateLevelEntities[k] = nil
			end
		end
	end
end)

local function RecordMapAndReloadXP()
	local fileContent = InsaneStats:Load()
	local currentMap = game.GetMap()
	
	mapNumber = 0
	mapOrder = fileContent.maps or {}
	for k,v in pairs(mapOrder) do
		if v == currentMap then
			mapNumber = k break
		end
	end
	
	if mapNumber == 0 then
		mapNumber = table.insert(mapOrder, currentMap)
	end
	
	savedPlayerXP = fileContent.playerXP or {}
end

RecordMapAndReloadXP()

hook.Add("InitPostEntity", "InsaneStatsXP", function()
	RecordMapAndReloadXP()
	if InsaneStats:GetConVarValue("xp_enabled") then
		table.insert(toUpdateLevelEntities, game.GetWorld())
	end
end)

local function DoSetHealth(ent, health)
	if IsValid(ent) then
		ent:SetHealth(health)
		
		if --[[ent:InsaneStats_GetMaxHealth() < health and]] not ent:IsPlayer() then
			ent:SetMaxHealth(health)
		end

		if health <= 0 then
			ent:TakeDamage(math.huge)
		end
	end
end
hook.Add("AcceptInput", "InsaneStatsXP", function(ent, input, activator, caller, data)
	input = input:lower()
	data = data or ""
	
	if InsaneStats:GetConVarValue("xp_enabled") then
		--[[if input == "InsaneStatsHealthChargerPoint" then
			ent:SetHealth(ent:InsaneStats_GetHealth() + ent:InsaneStats_GetMaxHealth() / 100)
			return true
		else]]if input == "insanestatssuitchargerpoint" then
			ent:SetArmor(ent:InsaneStats_GetArmor() + ent:InsaneStats_GetCurrentArmorAdd())
			return true
		elseif input == "insanestatssupersuitchargerpoint" then
			if ent:InsaneStats_GetArmor() * 100 < ent:InsaneStats_GetMaxArmor() * GetConVar("sk_suitcharger_citadel_maxarmor"):GetFloat() then
				ent:SetArmor(ent:InsaneStats_GetArmor() + 10 * ent:InsaneStats_GetCurrentArmorAdd())
			end
			
			if ent:InsaneStats_GetHealth() < ent:InsaneStats_GetMaxHealth() then
				ent:SetHealth(math.min(
					ent:InsaneStats_GetHealth() + 5 * ent:InsaneStats_GetCurrentHealthAdd(),
					ent:InsaneStats_GetMaxHealth()
				))
			end
			
			if ent:InsaneStats_GetArmor() > ent:InsaneStats_GetMaxArmor() + GetConVar("sk_suitcharger_citadel_maxarmor"):GetFloat() - 100 then
				caller:SetSaveValue("m_iJuice", caller:GetInternalVariable("m_iJuice")-10)
			end
			
			return true
		end
	end
	
	if input == "sethealth" then
		local healthMul = ent:InsaneStats_GetCurrentHealthAdd()
		if tonumber(data) then
			local newHealth = healthMul * tonumber(data)
			-- if health is 0, DO NOT return true, and set the new health on the next tick
			-- otherwise func_breakables that start at 0 health will still retain their unbreakability
			if ent:InsaneStats_GetHealth() > 0 then
				DoSetHealth(ent, newHealth)
			
				if ent:InsaneStats_GetRawHealth() > 1 then
					return true
				end
			else
				timer.Simple(0, function()
					DoSetHealth(ent, newHealth)
				end)
			end
		end
	elseif input == "addhealth" then
		local healthMul = ent:InsaneStats_GetCurrentHealthAdd()
		if tonumber(data) then
			local oldHealth = ent:InsaneStats_GetHealth()
			local newHealth = oldHealth + healthMul * tonumber(data)
			if oldHealth > 0 then
				DoSetHealth(ent, newHealth)
			
				if ent:InsaneStats_GetRawHealth() > 1 then
					return true
				end
			else
				timer.Simple(0, function()
					DoSetHealth(ent, newHealth)
				end)
			end
		end
	elseif input == "removehealth" then
		local healthMul = ent:InsaneStats_GetCurrentHealthAdd()
		if tonumber(data) then
			local oldHealth = ent:InsaneStats_GetHealth()
			local newHealth = oldHealth - healthMul * tonumber(data)
			if oldHealth > 0 then
				DoSetHealth(ent, newHealth)
			
				if ent:InsaneStats_GetRawHealth() > 1 then
					return true
				end
			else
				timer.Simple(0, function()
					DoSetHealth(ent, newHealth)
				end)
			end
		end
	elseif input == "sethealthfraction" then
		local dataNumber = tonumber(data)
		if dataNumber then
			local newHealth = ent:InsaneStats_GetMaxHealth() * dataNumber / 100
			if ent:InsaneStats_GetHealth() > 0 then
				DoSetHealth(ent, newHealth)
			
				if ent:InsaneStats_GetRawHealth() > 1 then
					return true
				end
			else
				timer.Simple(0, function()
					DoSetHealth(ent, newHealth)
				end)
			end
		end
	elseif input == "setplayerhealth" and ent:GetClass() == "logic_playerproxy" then
		if tonumber(data) then
			for i,v in player.Iterator() do
				local healthMul = v:InsaneStats_GetCurrentHealthAdd()
				local newHealth = healthMul * tonumber(data)
				v:SetHealth(newHealth)
				
				if v:InsaneStats_GetMaxHealth() < newHealth then
					v:SetMaxHealth(newHealth)
				end
			end
			
			if tonumber(data) > 0 then
				return true
			end
		end
	elseif input == "addoutput" then
		local key, value = data:lower():match("(%w*health)%s+(%w*)$")
		
		if key then
			hook.Run("EntityKeyValue", ent, key, value)
			return true
		end
	end
end)

hook.Add("EntityKeyValue", "InsaneStatsXP", function(ent, key, value)
	value = tonumber(value)
	key = key:lower()
	local healthMul = ent:InsaneStats_GetCurrentHealthAdd()
	
	if healthMul ~= 1 and value then
		
		if key == "health" then
			local newHealth = healthMul * value
			-- if health is 0, DO NOT return true, and set the new health on the next tick
			-- otherwise func_breakables that start at 0 health will still retain their unbreakability
			if ent:InsaneStats_GetHealth() > 0 then
				DoSetHealth(ent, newHealth)

				return true
			else
				timer.Simple(0, function()
					DoSetHealth(ent, newHealth)
				end)
			end
		elseif key == "max_health" then
			local newHealth = healthMul * value
			ent:SetMaxHealth(newHealth)
			
			return true
		end
	end

	if key == "onplayertouch" then
		ent.insaneStats_NoCustomItemProcessing = true
	end
end)

--[[hook.Add("PlayerUse", "InsaneStatsXP", function(ply, ent)
	if InsaneStats:GetConVarValue("xp_enabled") then
		local class = ent:GetClass()
		if class == "item_healthcharger" or class == "func_healthcharger" then
			ply.insaneStats_TempHealthChargerFixExpiry = CurTime() + 0.1
		end
	end
end)]]

hook.Add("EntityTakeDamage", "InsaneStatsXP", function(vic, dmginfo)
	if (IsValid(attacker) and attacker:GetClass() ~= "entityflame") and attacker ~= vic then
		vic.insaneStats_LastAttacker = attacker
	end

	-- striders will make a desperate attempt at deleting their target when they fail to
	-- it makes sense for map logic, but what if it's the player?
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	if vic:IsPlayer() and dmginfo:GetDamageType() == 0
	and (IsValid(attacker) and attacker:GetClass() == "npc_strider") then
		InsaneStats:Log("@NASTYGRAM I REFUSE!")
		return true
	end
	
	-- ignore damage dealt to uninitiated entities
	if InsaneStats:GetConVarValue("xp_enabled") and not vic:InsaneStats_GetEntityData("level") then
		table.insert(toUpdateLevelEntities, vic)
		return true
	end
end)

hook.Add("OnPlayerPhysicsPickup", "InsaneStatsXP", function(ply, ent)
	ent.insaneStats_LastAttacker = ply
end)

hook.Add("OnPhysgunPickup", "InsaneStatsXP", function(ply, ent)
	ent.insaneStats_LastAttacker = ply
end)

hook.Add("GravGunOnPickedUp", "InsaneStatsXP", function(ply, ent)
	ent.insaneStats_LastAttacker = ply
end)

hook.Add("PlayerSpawn", "InsaneStatsXP", function(ply, fromTransition)
	if fromTransition then
		hook.Run("InsaneStatsTransitionCompat", ply)
	end
	
	ply.insaneStats_IsDead = false
	
	if fromTransition then
		ply:InsaneStats_SetEntityData("xp_loaded", nil)
	end
	
	if not ply:InsaneStats_GetEntityData("xp_loaded") then
		local xp = InsaneStats:GetConVarValue("xp_player_save") and savedPlayerXP[ply:SteamID()]
		
		if xp then
			ply:InsaneStats_SetXP(xp)
		else
			ply:InsaneStats_SetXP(InsaneStats:GetXPRequiredToLevel(InsaneStats:GetConVarValue("xp_player_level_start")))
		end
		
		ply:InsaneStats_SetEntityData("xp_loaded", true)
	end
	
	if not fromTransition then
		ply:InsaneStats_SetCurrentHealthAdd(1)
		ply:InsaneStats_SetCurrentArmorAdd(1)
	end
	
	if InsaneStats:GetConVarValue("xp_enabled") then
		timer.Simple(0, function()
			ply:InsaneStats_ApplyLevel(ply:InsaneStats_GetLevel())
		end)
	end
end)

hook.Add("InsaneStatsSave", "InsaneStatsXP", function(data)
	if InsaneStats:GetConVarValue("xp_enabled") and InsaneStats:GetConVarValue("xp_player_save") then
		data.maps = mapOrder
		
		for i,v in player.Iterator() do
			local steamID = v:SteamID()
			if steamID then
				savedPlayerXP[steamID] = v:InsaneStats_GetXP()
			end
		end
		data.playerXP = savedPlayerXP
	end
end)

hook.Add("PostCleanupMap", "InsaneStatsXP", function()
	if InsaneStats:GetConVarValue("xp_enabled") then
		local xp = InsaneStats:DetermineEntitySpawnedXP(game.GetWorld())
		if xp then
			game.GetWorld():InsaneStats_SetXP(xp)
		end
	end
end)

hook.Add("PlayerCanPickupItem", "InsaneStatsXP", function(ply, item)
	-- this hook has the possibility to be run multiple times on accident
	if item:IsEFlagSet(EFL_CHECK_UNTOUCH) then return false end

	local ret = hook.Run("InsaneStatsPlayerCanPickupItem", ply, item)
	if ret == false then return false end

	local doCustomHandling = InsaneStats:GetConVarValue("xp_enabled") and not item.insaneStats_NoCustomItemProcessing
	if doCustomHandling then
		local class = item:GetClass()
		if class == "item_healthvial" then
			if ply:InsaneStats_GetHealth() < ply:InsaneStats_GetMaxHealth() then
				local newHealth = math.min(
					ply:InsaneStats_GetMaxHealth(),
					ply:InsaneStats_GetHealth() + GetConVar("sk_healthvial"):GetFloat() * ply:InsaneStats_GetCurrentHealthAdd()
				)
				ply:SetHealth(newHealth)
				ply:EmitSound("HealthVial.Touch")

				hook.Run("InsaneStatsPlayerPickedUpItem", ply, item)
				item:Remove()
			
				net.Start("insane_stats")
				net.WriteUInt(2, 8)
				net.WriteString(class)
				net.Send(ply)
			end
			
			return false
		elseif class == "item_healthkit" then
			if ply:InsaneStats_GetHealth() < ply:InsaneStats_GetMaxHealth() then
				local newHealth = math.min(
					ply:InsaneStats_GetMaxHealth(),
					ply:InsaneStats_GetHealth() + GetConVar("sk_healthkit"):GetFloat() * ply:InsaneStats_GetCurrentHealthAdd()
				)
				ply:SetHealth(newHealth)
				ply:EmitSound("HealthKit.Touch")

				hook.Run("InsaneStatsPlayerPickedUpItem", ply, item)
				item:Remove()
			
				net.Start("insane_stats")
				net.WriteUInt(2, 8)
				net.WriteString(class)
				net.Send(ply)
			end
			
			return false
		elseif class == "item_grubnugget" then
			local tier = item:GetInternalVariable("m_nDenomination")
			local affectedConVar
			
			if tier < 2 then
				affectedConVar = GetConVar("sk_grubnugget_health_small")
			elseif tier == 2 then
				affectedConVar = GetConVar("sk_grubnugget_health_medium")
			else
				affectedConVar = GetConVar("sk_grubnugget_health_large")
			end
			
			if ply:InsaneStats_GetHealth() < ply:InsaneStats_GetMaxHealth() then
				local newHealth = math.min(
					ply:InsaneStats_GetMaxHealth(),
					ply:InsaneStats_GetHealth() + affectedConVar:GetFloat() * ply:InsaneStats_GetCurrentHealthAdd()
				)
				ply:SetHealth(newHealth)
				ply:EmitSound("HealthVial.Touch")

				hook.Run("InsaneStatsPlayerPickedUpItem", ply, item)
				item:Remove()
				
				net.Start("insane_stats")
				net.WriteUInt(2, 8)
				net.WriteString(class)
				net.Send(ply)
			end
			
			return false
		elseif class == "item_battery" then
			local ignoreWPASS2Pickup = (item.insaneStats_DisableWPASS2Pickup or 0) > RealTime()
			
			if ply:InsaneStats_GetArmor() < ply:InsaneStats_GetMaxArmor() and not ignoreWPASS2Pickup then
				hook.Run("InsaneStatsPlayerPickedUpItem", ply, item)

				item.insaneStats_Modifiers = nil
				ply:InsaneStats_EquipBattery(item)
				return false
			end
		end
	else
		hook.Run("InsaneStatsPlayerPickedUpItem", ply, item)
	end
end)