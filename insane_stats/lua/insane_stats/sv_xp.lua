local mapOrder = {}
local mapNumber = 0
concommand.Add("insanestats_xp_other_level_maps_show", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		print("These are the recorded maps:")
		PrintTable(mapOrder)
		print("You are on map #"..mapNumber..".")
	end
end, nil, "Shows all maps that are currently factored into level scaling.")
concommand.Add("insanestats_xp_other_level_maps_reset", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		mapOrder = {}
	end
end, nil, "Clears the recorded maps list.")
concommand.Add("insanestats_xp_other_level_maps_remove", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		-- use a search pattern
		local success = false
		local searchStr = argStr:PatternSafe():Replace('%*', '.*')
		local i = 1
		local v = mapOrder[i]
		while v do
			if string.match(v, '^'..searchStr..'$') then
				table.remove(mapOrder, i)
				InsaneStats:Log("Removed map "..v..".")
				success = true
			else
				i = i + 1
			end
			v = mapOrder[i]
		end
		if success then return InsaneStats:PerformSave() end
		
		if tonumber(argStr) then
			local toRemove = math.min(#mapOrder, tonumber(argStr) or 0)
			for i=1, toRemove do
				local value = table.remove(mapOrder)
				InsaneStats:Log("Removed map "..value..".")
			end
			InsaneStats:PerformSave()
		elseif argStr == "" then
			InsaneStats:Log("Removes a map from the map record list. If a number is given (and no matching map was found), the number will be interpreted as the number of recent maps to remove. * wildcards are allowed. Note that a map restart is required for the map number to be updated.")
		else
			InsaneStats:Log("Could not find map "..argStr..".")
		end
	end
end, nil, "Removes maps from the recorded maps list. * wildcards are allowed. \z
If a number is given (and no matching map was found), the number will be interpreted as the number of recent maps to remove. \z
Note that a map restart is required for the map number to be updated.")

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
				for k,v in pairs(player.GetAll()) do
					if v:Nick() == plyStr then
						ply = v
						foundPlayer = true
						break
					end
				end
				
				if not foundPlayer then
					InsaneStats:Log("Could not find player \""..plyStr.."\".")
					return
				end
			end
			
			local level = tonumber(levelStr)
			if level then
				ply:InsaneStats_SetXP(InsaneStats:GetXPRequiredToLevel(level))
			else
				InsaneStats:Log("\""..levelStr.."\" is not a valid number.")
			end
		end
	end
end, function(cmd, argStr)
	local suggestions = {}
	argStr = argStr:Trim()
	
	for k,v in pairs(player.GetAll()) do
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
		
		local currentHealthFrac = (self:InsaneStats_GetMaxHealth() == 0
			or self:InsaneStats_GetHealth() == math.huge) and 1
			or self:InsaneStats_GetHealth() / self:InsaneStats_GetMaxHealth()
		local currentHealthAdd = self.insaneStats_CurrentHealthAdd or 1
		local startingHealth = self:InsaneStats_GetMaxHealth() / currentHealthAdd
		--print(self:InsaneStats_GetMaxHealth(), currentHealthAdd)
		local newHealth
		if isPlayer then
			newHealth = math.floor(InsaneStats:ScaleValueToLevelQuadratic(
				startingHealth,
				InsaneStats:GetConVarValue("xp_player_health")/100,
				level,
				"xp_player_health_mode",
				false,
				InsaneStats:GetConVarValue("xp_player_health_add")/100
			))
		else
			newHealth = math.floor(InsaneStats:ScaleValueToLevelQuadratic(
				startingHealth,
				InsaneStats:GetConVarValue("xp_other_health")/100,
				level,
				"xp_other_health_mode",
				false,
				InsaneStats:GetConVarValue("xp_other_health_add")/100
			))
		end
		if newHealth == math.huge then
			currentHealthFrac = 1
		end
		self:SetMaxHealth(newHealth)
		self:SetHealth(currentHealthFrac * newHealth)
		if newHealth == math.huge or startingHealth == 0 then
			self.insaneStats_CurrentHealthAdd = 1
		else
			self.insaneStats_CurrentHealthAdd = newHealth / startingHealth
		end
		self.insaneStats_CurrentHealthAddRoot8 = InsaneStats:CalculateRoot8(self.insaneStats_CurrentHealthAdd)
		
		if self:InsaneStats_GetMaxArmor() > 0 then
			local currentArmorFrac = self:InsaneStats_GetMaxArmor() == 0 and 0
				or self:InsaneStats_GetArmor() == math.huge and 1
				or self:InsaneStats_GetArmor() / self:InsaneStats_GetMaxArmor()
			local currentArmorAdd = self.insaneStats_CurrentArmorAdd or 1
			local startingArmor = self:InsaneStats_GetMaxArmor() / currentArmorAdd
			local newArmor
			if isPlayer then
				newArmor = math.floor(InsaneStats:ScaleValueToLevelQuadratic(
					startingArmor,
					InsaneStats:GetConVarValue("xp_player_armor")/100,
					level,
					"xp_player_armor_mode",
					false,
					InsaneStats:GetConVarValue("xp_player_armor_add")/100
				))
			else
				newArmor = math.floor(InsaneStats:ScaleValueToLevelQuadratic(
					startingArmor,
					InsaneStats:GetConVarValue("xp_other_armor")/100,
					level,
					"xp_other_armor_mode",
					false,
					InsaneStats:GetConVarValue("xp_other_armor_add")/100
				))
			end
			if newArmor == math.huge then
				currentArmorFrac = 1
			end
			self:SetMaxArmor(newArmor)
			self:SetArmor(currentArmorFrac * newArmor)
			if newArmor == math.huge or startingArmor == 0 then
				self.insaneStats_CurrentArmorAdd = 1
			else
				self.insaneStats_CurrentArmorAdd = newArmor / startingArmor
			end
			self.insaneStats_CurrentArmorAddRoot8 = InsaneStats:CalculateRoot8(self.insaneStats_CurrentArmorAdd)
		end
		
		hook.Run("InsaneStatsApplyLevel", self, level)
		
		--[[if isPlayer then
			print(newHealth)
		end]]
	end
end

local savedPlayerXP = {}

hook.Add("InsaneStatsScaleXP", "InsaneStatsXP", function(data)
	data.xp = InsaneStats:ScaleValueToLevelQuadratic(
		data.xp,
		InsaneStats:GetConVarValue("xp_drop_add")/100,
		data.victim:InsaneStats_GetLevel(),
		"xp_drop_add_mode",
		false,
		InsaneStats:GetConVarValue("xp_drop_add_add")/100
	) + (data.victim.insaneStats_DropXP or 0)
	
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
		
		-- we WANT this to be called multiple times, in case the victim gained XP after being revived
		if InsaneStats:GetConVarValue("xp_enabled") then
			if IsValid(attacker) and victim ~= attacker then
				local xpMul = InsaneStats:GetConVarValue(victim:IsPlayer() and "xp_player_mul" or "xp_other_mul")
				local currentHealthAdd = victim.insaneStats_CurrentHealthAdd or 1
				local startingHealth = victim:InsaneStats_GetMaxHealth() / currentHealthAdd
				local startXPToGive = victim.insaneStats_IsDead and 0 or startingHealth * xpMul / 5
				
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
				
				local xpToGive = data.xp
				--print(xpToGive)
				local extraXP = 0
				
				local xpDropMul = 1
				if victim:IsPlayer() then
					xpDropMul = InsaneStats:GetConVarValue("xp_player_kill")
				else
					xpDropMul = InsaneStats:GetConVarValue("xp_other_kill")
					
					if xpToGive > 0 then
						-- give xp % based on NPC level
						local level = victim:InsaneStats_GetLevel()
						local currentXP = InsaneStats:GetXPRequiredToLevel(level)
						if currentXP ~= math.huge then
							local levelsBack = InsaneStats:ScaleValueToLevelPure(
								1,
								InsaneStats:GetConVarValue("xp_drop_add_add")/100,
								level,
								false
							)
							local previousXP = InsaneStats:GetXPRequiredToLevel(level-levelsBack)
							extraXP = (currentXP - previousXP) * InsaneStats:GetConVarValue("xp_other_mul")/100
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
				
				local wepMul = InsaneStats:GetConVarValue("xp_weapon_mul")
				for k,v in pairs(data.receivers) do
					local tempExtraXP = (k:IsPlayer() or k:GetOwner():IsPlayer()) and 0 or extraXP * v
					local tempDropMul = shouldDropMul[k] and xpDropMul or 0
					local xp = xpToGive * v
					if k:IsWeapon() then xp = xp * wepMul end
					--print("xp, tempExtraXP, tempDropMul")
					--print(xp, tempExtraXP, tempDropMul)
					--print(k, xp, xpToGive, v, victim.insaneStats_DropXP, tempExtraXP)
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
						--print(wep, xp, xpToGive, victim.insaneStats_DropXP, tempExtraXP)
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

			victim.insaneStats_DropXP = 0
		end
		
		hook.Run("InsaneStatsEntityKilledPostXP", victim, attacker, inflictor)
		if not victim.insaneStats_IsDead then
			hook.Run("InsaneStatsEntityKilledOnce", victim, attacker, inflictor)
			victim.insaneStats_IsDead = true
		end
	end
end

local needCorrectiveDeathClasses = {
	npc_combine_camera=true,
	npc_turret_ceiling=true,
}

hook.Add("InsaneStatsEntityKilled", "InsaneStatsXP", function(victim, attacker, inflictor)
	ProcessKillEvent(victim, attacker, inflictor)

	--print(victim, attacker, inflictor, victim.insaneStats_LastAttacker)
	--print(IsValid(attacker), attacker ~= victim, IsValid(victim.insaneStats_LastAttacker))
	if InsaneStats:GetConVarValue("xp_enabled") then
		local wep = victim.GetActiveWeapon and victim:GetActiveWeapon()
		if victim:IsNPC() and (IsValid(wep) and wep:GetClass() == "weapon_smg1") then
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
	local allPlayers = player.GetAll()
	local playerCount = math.max(#allPlayers, 1)
	local hasPlayer = false
	
	for k,v in pairs(allPlayers) do
		if v.insaneStats_XP then
			hasPlayer = true break
		end
	end
	
	local typ = self:GetConVarValue("xp_other_level_factor")
	if typ > 0 then
		if hasPlayer then
			if typ == 1 then
				-- get average level
				local totalLevel = 0
				for k,v in pairs(allPlayers) do
					if v.insaneStats_XP then
						totalLevel = totalLevel + v:InsaneStats_GetLevel()
					end
				end
				
				level = level + totalLevel / playerCount
			elseif typ == 2 then
				-- get geometric average level
				local totalLevel = 1
				local inversePlayerCount = 1/playerCount
				for k,v in pairs(allPlayers) do
					if v.insaneStats_XP then
						totalLevel = totalLevel * v:InsaneStats_GetLevel() ^ inversePlayerCount
					end
				end
				
				level = level + totalLevel
			elseif typ == 3 then
				-- get highest level
				local highestLevel = 1
				for k,v in pairs(allPlayers) do
					highestLevel = math.max(highestLevel, v:InsaneStats_GetLevel())
				end
				
				level = level + highestLevel
			elseif typ == 4 then
				-- get nearest player
				local closestPlayer = game.GetWorld()
				local closestSqrDist = math.huge
				for k,v in pairs(allPlayers) do
					local sqrDist = pos:DistToSqr(v:GetPos())
					if sqrDist < closestSqrDist and v.insaneStats_XP then
						closestPlayer = v
						closestSqrDist = sqrDist
					end
				end
				
				level = level + closestPlayer:InsaneStats_GetLevel()
			end
		else return
		end
	end

	local minimum = level + self:GetConVarValue("xp_other_level_maps_minimum") * mapNumber
	local current = self:ScaleValueToLevel(level, self:GetConVarValue("xp_other_level_maps")/100, mapNumber, "xp_other_level_maps_mode", true)
	level = math.max(minimum, current)

	local curMinutes = CurTime() / 60
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
	if isAlpha then
		alphaXPMul = self:GetConVarValue("xp_other_alpha_mul")
	end
	return self:GetXPRequiredToLevel(level) * playerXPMul * driftXPFactor * alphaXPMul, isAlpha
end

function InsaneStats:DetermineDamageMul(vic, dmginfo)
	if self:GetConVarValue("xp_enabled") then
		local attacker = dmginfo:GetAttacker()
		local inflictor = dmginfo:GetInflictor()
		local damageBonus = 1
		
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
			if bit.band(inflictorFlags, 1) ~= 0 and inflictor:GetClass() == "prop_physics" then
				attacker = inflictor
			elseif bit.band(inflictorFlags, 2) ~= 0 and inflictor:IsWeapon() then
				attacker = inflictor
			end
		end
	
		local level = attacker:InsaneStats_GetLevel()
		if attacker:IsPlayer() then
			damageBonus = self:ScaleValueToLevelQuadratic(
				damageBonus,
				self:GetConVarValue("xp_player_damage")/100,
				level,
				"xp_player_damage_mode",
				false,
				self:GetConVarValue("xp_player_damage_add")/100
			)
		else
			damageBonus = self:ScaleValueToLevelQuadratic(
				damageBonus,
				self:GetConVarValue("xp_other_damage")/100,
				level,
				"xp_other_damage_mode",
				false,
				self:GetConVarValue("xp_other_damage_add")/100
			)
		end
	
		level = vic:InsaneStats_GetLevel()
		if vic:IsPlayer() then
			damageBonus = damageBonus / self:ScaleValueToLevelQuadratic(
				1,
				self:GetConVarValue("xp_player_resistance")/100,
				level,
				"xp_player_resistance_mode",
				false,
				self:GetConVarValue("xp_player_resistance_add")/100
			)
		else
			damageBonus = damageBonus / self:ScaleValueToLevelQuadratic(
				1,
				self:GetConVarValue("xp_other_resistance")/100,
				level,
				"xp_other_resistance_mode",
				false,
				self:GetConVarValue("xp_other_resistance_add")/100
			)
		end
		
		--print(damageBonus)
		return damageBonus
	else
		return 1
	end
end

local toUpdateLevelEntities = {}
--local loadedData = {}
hook.Add("InsaneStatsEntityCreated", "InsaneStatsXP", function(ent)
	if not ent.insaneStats_XP then
		local shouldXP, isAlpha = InsaneStats:DetermineEntitySpawnedXP(ent)
		--print(ent, "should spawn with ", shouldXP, " xp")
		if shouldXP then
			ent:InsaneStats_SetXP(shouldXP)
			ent:InsaneStats_SetIsAlpha(isAlpha)
		else
			table.insert(toUpdateLevelEntities, ent)
		end
	end
end)

hook.Add("InsaneStatsTransitionCompat", "InsaneStatsXP", function(ent)
	if ent.insaneStats_HealthRoot8 then
		ent.insaneStats_Health = ent.insaneStats_HealthRoot8 ^ 8
	end
	if ent.insaneStats_MaxHealthRoot8 then
		ent.insaneStats_MaxHealth = ent.insaneStats_MaxHealthRoot8 ^ 8
	end
	if ent.insaneStats_ArmorRoot8 then
		ent.insaneStats_Armor = ent.insaneStats_ArmorRoot8 ^ 8
	end
	if ent.insaneStats_MaxArmorRoot8 then
		ent.insaneStats_MaxArmor = ent.insaneStats_MaxArmorRoot8 ^ 8
	end
	if ent.insaneStats_CurrentHealthAddRoot8 then
		ent.insaneStats_CurrentHealthAdd = ent.insaneStats_CurrentHealthAddRoot8 ^ 8
	end
	if ent.insaneStats_CurrentArmorAddRoot8 then
		ent.insaneStats_CurrentArmorAdd = ent.insaneStats_CurrentArmorAddRoot8 ^ 8
	end
	if ent.insaneStats_XPRoot8 then
		ent:InsaneStats_SetXP(ent.insaneStats_XPRoot8 ^ 8)
	end
	if ent.insaneStats_DropXPRoot8 then
		ent.insaneStats_DropXP = ent.insaneStats_DropXPRoot8 ^ 8
	end
end)

timer.Create("InsaneStatsXP", 0.5, 0, function()
	if next(toUpdateLevelEntities) then
		for k,v in pairs(toUpdateLevelEntities) do
			if IsValid(v) or v == game.GetWorld() then
				if v.insaneStats_XP then
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
		
		if ent:InsaneStats_GetMaxHealth() < health then
			ent:SetMaxHealth(health)
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
			ent:SetArmor(ent:InsaneStats_GetArmor() + (ent.insaneStats_CurrentArmorAdd or 1))
			return true
		elseif input == "insanestatssupersuitchargerpoint" then
			if ent:InsaneStats_GetArmor() * 100 < ent:InsaneStats_GetMaxArmor() * GetConVar("sk_suitcharger_citadel_maxarmor"):GetFloat() then
				ent:SetArmor(ent:InsaneStats_GetArmor() + 10 * (ent.insaneStats_CurrentArmorAdd or 1))
			end
			
			if ent:InsaneStats_GetHealth() < ent:InsaneStats_GetMaxHealth() then
				ent:SetHealth(math.min(
					ent:InsaneStats_GetHealth() + 5 * (ent.insaneStats_CurrentHealthAdd or 1),
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
		local healthMul = ent.insaneStats_CurrentHealthAdd or 1
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
		local healthMul = ent.insaneStats_CurrentHealthAdd or 1
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
		local healthMul = ent.insaneStats_CurrentHealthAdd or 1
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
			for k,v in pairs(player.GetAll()) do
				local healthMul = v.insaneStats_CurrentHealthAdd or 1
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
	local healthMul = ent.insaneStats_CurrentHealthAdd or 1
	
	if healthMul ~= 1 and value then
		key = key:lower()
		
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
	-- striders will make a desperate attempt at deleting their target when they fail to
	-- it makes sense for map logic, but what if it's the player?
	local attacker = dmginfo:GetAttacker()
	if vic:IsPlayer() and dmginfo:GetDamageType() == 0
	and (IsValid(attacker) and attacker:GetClass() == "npc_strider") then
		InsaneStats:Log("@NASTYGRAM I REFUSE!")
		return true
	end
	
	if InsaneStats:GetConVarValue("xp_enabled") then
		if (IsValid(attacker) and attacker:GetClass() ~= "entityflame") and attacker ~= vic then
			vic.insaneStats_LastAttacker = attacker
		end
		
		if not vic.insaneStats_Level then return true end
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
		ply.insaneStats_XPLoaded = nil
	end
	
	if not ply.insaneStats_XPLoaded then
		local xp = InsaneStats:GetConVarValue("xp_player_save") and savedPlayerXP[ply:SteamID()]
		
		if xp then
			ply:InsaneStats_SetXP(xp)
		else
			ply:InsaneStats_SetXP(InsaneStats:GetXPRequiredToLevel(InsaneStats:GetConVarValue("xp_player_level_start")))
		end
		
		ply.insaneStats_XPLoaded = true
	end
	
	if not fromTransition then
		ply.insaneStats_CurrentHealthAdd = 1
		ply.insaneStats_CurrentArmorAdd = 1
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
		
		for k,v in pairs(player.GetAll()) do
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

	if InsaneStats:GetConVarValue("xp_enabled") then
		local class = item:GetClass()
		if class == "item_healthvial" then
			if ply:InsaneStats_GetHealth() < ply:InsaneStats_GetMaxHealth() then
				local newHealth = math.min(
					ply:InsaneStats_GetMaxHealth(),
					ply:InsaneStats_GetHealth()+GetConVar("sk_healthvial"):GetFloat()*(ply.insaneStats_CurrentHealthAdd or 1)
				)
				ply:SetHealth(newHealth)
				ply:EmitSound("HealthVial.Touch")
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
					ply:InsaneStats_GetHealth()+GetConVar("sk_healthkit"):GetFloat()*(ply.insaneStats_CurrentHealthAdd or 1)
				)
				ply:SetHealth(newHealth)
				ply:EmitSound("HealthKit.Touch")
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
					ply:InsaneStats_GetHealth()+affectedConVar:GetFloat()*(ply.insaneStats_CurrentHealthAdd or 1)
				)
				ply:SetHealth(newHealth)
				ply:EmitSound("HealthKit.Touch")
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
				item.insaneStats_Modifiers = nil
				ply:InsaneStats_EquipBattery(item)
				return false
			end
		end
	end
end)