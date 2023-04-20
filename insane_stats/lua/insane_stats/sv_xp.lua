local mapOrder = {}
local mapNumber = 0
concommand.Add("insanestats_xp_other_level_maps_show", function(ply, cmd, args, argStr)
	print("These are the recorded maps:")
	PrintTable(mapOrder)
	print("You are on map #"..mapNumber..".")
end, nil, "Shows recorded maps.")
concommand.Add("insanestats_xp_other_level_maps_reset", function(ply, cmd, args, argStr)
	mapOrder = {}
end, nil, "Resets recorded maps.")

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
				level,
				InsaneStats:GetConVarValue("xp_player_health")/100,
				"xp_player_health_mode",
				InsaneStats:GetConVarValue("xp_player_health_add")/100,
				"xp_player_health_add_mode"
			))
		else
			newHealth = math.floor(InsaneStats:ScaleValueToLevelQuadratic(
				startingHealth,
				level,
				InsaneStats:GetConVarValue("xp_other_health")/100,
				"xp_other_health_mode",
				InsaneStats:GetConVarValue("xp_other_health_add")/100,
				"xp_other_health_add_mode"
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
		
		if self.SetMaxArmor then
			local currentArmorFrac = self:InsaneStats_GetMaxArmor() == 0 and 0
				or self:InsaneStats_GetArmor() == math.huge and 1
				or self:InsaneStats_GetArmor() / self:InsaneStats_GetMaxArmor()
			local currentArmorAdd = self.insaneStats_CurrentArmorAdd or 1
			local startingArmor = self:InsaneStats_GetMaxArmor() / currentArmorAdd
			local newArmor
			if isPlayer then
				newArmor = math.floor(InsaneStats:ScaleValueToLevelQuadratic(
					startingArmor,
					level,
					InsaneStats:GetConVarValue("xp_player_armor")/100,
					"xp_player_armor_mode",
					InsaneStats:GetConVarValue("xp_player_armor_add")/100,
					"xp_player_armor_add_mode"
				))
			else
				newArmor = math.floor(InsaneStats:ScaleValueToLevelQuadratic(
					startingArmor,
					level,
					InsaneStats:GetConVarValue("xp_other_armor")/100,
					"xp_other_armor_mode",
					InsaneStats:GetConVarValue("xp_other_armor_add")/100,
					"xp_other_armor_add_mode"
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
		data.victim:InsaneStats_GetLevel(),
		InsaneStats:GetConVarValue("xp_drop_add")/100,
		"xp_drop_add_mode",
		InsaneStats:GetConVarValue("xp_drop_add_add")/100,
		"xp_drop_add_add_mode"
	) + (data.victim.insaneStats_DropXP or 0)
	
end)

local function ProcessKillEvent(victim, attacker, inflictor)
	--print(victim, attacker, inflictor, victim.insaneStats_LastAttacker)
	--print(IsValid(attacker), attacker ~= victim, IsValid(victim.insaneStats_LastAttacker))
	if not (IsValid(attacker) and attacker ~= victim) and IsValid(victim.insaneStats_LastAttacker) then
		attacker = victim.insaneStats_LastAttacker
		inflictor = victim.insaneStats_LastAttacker
	end
	--print(victim, attacker, inflictor, victim.insaneStats_LastAttacker)
	if not IsValid(attacker) and IsValid(inflictor) then
		attacker = inflictor
	elseif (not IsValid(inflictor) or inflictor == attacker) and (attacker.GetActiveWeapon and IsValid(attacker:GetActiveWeapon())) then
		inflictor = attacker:GetActiveWeapon()
	end
	
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
					local levelsBack = InsaneStats:ScaleValueToLevel(
						1,
						InsaneStats:GetConVarValue("xp_drop_add_add")/100,
						level,
						"xp_drop_add_add_mode"
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
		local shouldDropMul = {[attacker] = true, [inflictor] = true}
		for k,v in pairs(shouldDropMul) do
			local wep = k.GetActiveWeapon and k:GetActiveWeapon()
			if IsValid(wep) then
				shouldDropMul[wep] = true
			end
		end
	
		for k,v in pairs(data.receivers) do
			local tempExtraXP = (k:IsPlayer() or k:GetOwner():IsPlayer()) and 0 or extraXP * v
			local tempDropMul = shouldDropMul[k] and xpDropMul or 0
			local xp = xpToGive * v
			--print("xp, tempExtraXP, tempDropMul")
			--print(xp, tempExtraXP, tempDropMul)
			--print(k, xp, xpToGive, v, victim.insaneStats_DropXP, tempExtraXP)
			k:InsaneStats_AddXP(xp+tempExtraXP, xp*tempDropMul)
			k.insaneStats_BatteryXP = (k.insaneStats_BatteryXP or 0) + xp
			
			local wep = k.GetActiveWeapon and k:GetActiveWeapon()
			if IsValid(wep) and not data.receivers[wep] then
				--print(wep, xp, xpToGive, victim.insaneStats_DropXP, tempExtraXP)
				wep:InsaneStats_AddXP(xp+tempExtraXP, xp*tempDropMul)
				wep.insaneStats_BatteryXP = (wep.insaneStats_BatteryXP or 0) + xp
			end
		end
		
		--print(attackerXP, attackerXP*xpDropMul)
	end
	
	victim.insaneStats_IsDead = true
	
	if victim:IsPlayer() then
		-- deduct xp %
		local newXP = victim:InsaneStats_GetXP() * (1-InsaneStats:GetConVarValue("xp_player_lose")/100)
		victim:InsaneStats_SetXP(newXP, 0)
	end
	
	hook.Run("InsaneStatsPostScaleXP", data)
end

hook.Add("entity_killed", "InsaneStatsXP", function(data)
	if InsaneStats:GetConVarValue("xp_enabled") then
		local victim = Entity(data.entindex_killed or 0)
		local attacker = Entity(data.entindex_attacker or 0)
		local inflictor = Entity(data.entindex_inflictor or 0)
		
		ProcessKillEvent(victim, attacker, inflictor)
	end
end)

hook.Add("player_activate", "InsaneStatsXP", function(data)
	local ply = Player(data.userid)
	
	if IsValid(ply) then
		local xp = savedPlayerXP[ply:SteamID()]
		
		if xp then
			ply:InsaneStats_SetXP(xp)
		else
			ply:InsaneStats_SetXP(InsaneStats:GetXPRequiredToLevel(InsaneStats:GetConVarValue("xp_player_level_start")))
		end
	end
end)

local needOnDeathClasses = {
	prop_vehicle_apc=true,
	npc_sniper=true,
	npc_helicopter=true,
	npc_combine_camera=true
}

--[[gameevent.Listen("break_prop")
hook.Add("break_prop", "InsaneStatsXP", function(data)
	if InsaneStats:GetConVarValue("xp_enabled") then
		local victim = Entity(data.entindex or 0)
		local attacker = Player(data.userid or 0)
	end
end]]

hook.Add("OnNPCKilled", "InsaneStatsXP", function(victim, attacker, inflictor)
	if InsaneStats:GetConVarValue("xp_enabled") then
		ProcessKillEvent(victim, attacker, inflictor)
	end
end)

function InsaneStats:DetermineEntitySpawnedXP(pos)
	-- get base level
	local level = self:GetConVarValue("xp_other_level_start")
	local allPlayers = player.GetAll()
	local playerCount = #allPlayers
	local hasPlayer = false
	
	for k,v in pairs(allPlayers) do
		if v.insaneStats_XP then
			hasPlayer = true break
		end
	end
	--print(pos, "has base level ", level)
	
	local typ = self:GetConVarValue("xp_other_level_factor")
	if typ >= 1 and typ <= 4 then
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
	elseif typ == 5 then
		local minimum = level + self:GetConVarValue("xp_other_level_maps_minimum") * mapNumber
		local current = self:ScaleValueToLevel(level, self:GetConVarValue("xp_other_level_maps")/100, mapNumber, "xp_other_level_maps_mode", true)
		level = math.max(minimum, current)
	end
	--print(pos, "has factored level ", level)
	
	local playerScalingMode = self:GetConVarValueDefaulted("xp_other_level_players_mode", "xp_mode") > 0
	if playerScalingMode then
		level = level + self:GetConVarValue("xp_other_level_players") * (playerCount - 1)
	else
		level = level * (1+self:GetConVarValue("xp_other_level_players")/100 * (playerCount - 1))
	end
	
	local drift = Lerp(math.random(), -self:GetConVarValue("xp_other_level_drift"), self:GetConVarValue("xp_other_level_drift"))
	drift = drift * math.random() ^ self:GetConVarValue("xp_other_level_drift_harshness")
	
	local driftMode = self:GetConVarValueDefaulted("xp_other_level_drift_mode", "xp_mode") > 0
	if driftMode then
		level = level + drift
	else
		level = level * (1+drift/100)
	end
	
	level = math.max(level, 1)
	
	if self:GetConVarValue("xp_scale_maxlevel") > 0 then
		level = math.min(level, self:GetConVarValue("xp_scale_maxlevel"))
	end
	
	return self:GetXPRequiredToLevel(level)
end

function InsaneStats:DetermineDamageMul(vic, dmginfo)
	if self:GetConVarValue("xp_enabled") then
		local attacker = dmginfo:GetAttacker()
		local inflictor = dmginfo:GetInflictor()
		local damageBonus = 1
		
		--[[if IsValid(inflictor) and inflictor:GetClass()=="entityflame" then
			return 1
		end]]
		
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
				level,
				self:GetConVarValue("xp_player_damage")/100,
				"xp_player_damage_mode",
				self:GetConVarValue("xp_player_damage_add")/100,
				"xp_player_damage_add_mode"
			)
		else
			damageBonus = self:ScaleValueToLevelQuadratic(
				damageBonus,
				level,
				self:GetConVarValue("xp_other_damage")/100,
				"xp_other_damage_mode",
				self:GetConVarValue("xp_other_damage_add")/100,
				"xp_other_damage_add_mode"
			)
		end
	
		level = vic:InsaneStats_GetLevel()
		if vic:IsPlayer() then
			damageBonus = damageBonus / self:ScaleValueToLevelQuadratic(
				1,
				level,
				self:GetConVarValue("xp_player_resistance")/100,
				"xp_player_resistance_mode",
				self:GetConVarValue("xp_player_resistance_add")/100,
				"xp_player_resistance_add_mode"
			)
		else
			damageBonus = damageBonus / self:ScaleValueToLevelQuadratic(
				1,
				level,
				self:GetConVarValue("xp_other_resistance")/100,
				"xp_other_resistance_mode",
				self:GetConVarValue("xp_other_resistance_add")/100,
				"xp_other_resistance_add_mode"
			)
		end
		
		--print(damageBonus)
		return damageBonus
	else
		return 1
	end
end

local toUpdateLevelEntities = {}
hook.Add("InsaneStatsEntityCreated", "InsaneStatsXP", function(ent)
	if not ent.insaneStats_XP then
		local shouldXP = InsaneStats:DetermineEntitySpawnedXP(ent:GetPos())
		--print(ent, "should spawn with ", shouldXP, " xp")
		if shouldXP then
			ent:InsaneStats_SetXP(shouldXP)
		else
			table.insert(toUpdateLevelEntities, ent)
		end
		if needOnDeathClasses[ent:GetClass()] then
			ent:Fire("AddOutput", "OnDeath !activator:InsaneStats_OnNPCKilled")
			if (ent:GetClass()=="prop_vehicle_apc" and IsValid(ent:GetDriver())) then
				ent:Fire("AddOutput", "OnDeath "..ent:GetDriver():GetName()..":SetHealth:0")
			end
		end
	end
end)

timer.Create("InsaneStatsXP", 0.5, 0, function()
	if next(toUpdateLevelEntities) then
		for k,v in pairs(toUpdateLevelEntities) do
			if IsValid(v) or v == game.GetWorld() then
				if v.insaneStats_XP then
					toUpdateLevelEntities[k] = nil
				else
					local shouldXP = InsaneStats:DetermineEntitySpawnedXP(ent)
					--print(shouldXP)
					if shouldXP then
						v:InsaneStats_SetXP(shouldXP)
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
	local fileContent = util.JSONToTable(file.Read("insane_stats.txt") or "") or {}
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
	
	savedPlayerXP = fileContent.playerXP
end

RecordMapAndReloadXP()

hook.Add("InitPostEntity", "InsaneStatsXP", function()
	RecordMapAndReloadXP()
	if InsaneStats:GetConVarValue("xp_enabled") then
		table.insert(toUpdateLevelEntities, game.GetWorld())
	end
end)

hook.Add("AcceptInput", "InsaneStatsXP", function(ent, input, activator, caller, data)
	if InsaneStats:GetConVarValue("xp_enabled") then
		--[[if input == "InsaneStatsHealthChargerPoint" then
			ent:SetHealth(ent:InsaneStats_GetHealth() + ent:InsaneStats_GetMaxHealth() / 100)
			return true
		else]]if input == "InsaneStatsSuitChargerPoint" then
			ent:SetArmor(ent:InsaneStats_GetArmor() + (ent.insaneStats_CurrentArmorAdd or 1))
			return true
		elseif input == "InsaneStatsSuperSuitChargerPoint" then
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
		elseif input == "InsaneStats_OnNPCKilled" and activator:IsPlayer() then
			ProcessKillEvent(caller, activator)
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
	if InsaneStats:GetConVarValue("xp_enabled") then
		if dmginfo:GetAttacker() ~= vic then
			vic.insaneStats_LastAttacker = dmginfo:GetAttacker()
		end
		
		if not vic.insaneStats_Level then return true end
	end
end)

hook.Add("PlayerSpawn", "InsaneStatsXP", function(ply, fromTransition)
	if InsaneStats:GetConVarValue("xp_enabled") then
		if not fromTransition then
			ply.insaneStats_CurrentHealthAdd = 1
			ply.insaneStats_CurrentArmorAdd = 1
		end
		
		timer.Simple(0.2, function()
			ply:InsaneStats_ApplyLevel(ply:InsaneStats_GetLevel())
		end)
	end
end)

local saveThinkCooldown = 0
hook.Add("Think", "InsaneStatsXP", function()
	if saveThinkCooldown < RealTime() and InsaneStats:GetConVarValue("xp_enabled") then
		local data = {}
		data.maps = mapOrder
		
		for k,v in pairs(player.GetAll()) do
			savedPlayerXP[v:SteamID()] = v:InsaneStats_GetXP()
		end
		data.playerXP = savedPlayerXP
		
		file.Write("insane_stats.txt", util.TableToJSON(data))
		
		saveThinkCooldown = RealTime() + 30
	end
end)

hook.Add("PostCleanupMap", "InsaneStatsXP", function()
	if InsaneStats:GetConVarValue("xp_enabled") then
		game.GetWorld():InsaneStats_SetXP(InsaneStats:DetermineEntitySpawnedXP(game.GetWorld()))
	end
end)

hook.Add("PlayerCanPickupWeapon", "InsaneStatsXP", function(ply, wep)
	if wep:GetClass() == "weapon_smg1" then
		if wep.InsaneStats_SetRawClip1 then
			wep:InsaneStats_SetRawClip1(45)
		else
			wep:SetClip1(45)
		end
	end
end)

hook.Add("PlayerCanPickupItem", "InsaneStatsXP", function(ply, item)
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
			if ply:InsaneStats_GetArmor() < ply:InsaneStats_GetMaxArmor() then
				ply:InsaneStats_EquipBattery(item)
				return false
			end
		end
	end
end)
