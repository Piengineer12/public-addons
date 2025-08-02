util.AddNetworkString("insane_stats")

local ENT = FindMetaTable("Entity")
local players = {}
local entitiesRequireUpdate = {}
--local entityDispositionsRequireUpdate = {}
local damageInfosRequireUpdate = {}

function ENT:InsaneStats_MarkForUpdate(flag)
	if IsValid(self) then
		entitiesRequireUpdate[self] = bit.bor(entitiesRequireUpdate[self] or 0, flag)
	end
end

--[[function ENT:InsaneStats_MarkForDispositionUpdate()
	if self:IsNPC() then
		entityDispositionsRequireUpdate[self] = true
	end
end]]

function ENT:InsaneStats_DamageNumber(attacker, damage, types, hitgroup, wasHealthyWhenDamaged)
	if (IsValid(self) and (self:GetClass() ~= "prop_physics" or self:GetCollisionGroup() ~= COLLISION_GROUP_DEBRIS)) then
		local entIndex = self:EntIndex()
		
		damageInfosRequireUpdate[entIndex] = damageInfosRequireUpdate[entIndex]
			or {damage = 0, types = 0, flags = 0, hitgroup = 10, position = self:WorldSpaceCenter()}
		
		local currentDamageInfo = damageInfosRequireUpdate[entIndex]
		currentDamageInfo.attacker = IsValid(attacker) and attacker or currentDamageInfo.attacker
		if tonumber(damage) then
			currentDamageInfo.damage = currentDamageInfo.damage + damage
		elseif damage == "immune" then
			currentDamageInfo.flags = bit.bor(currentDamageInfo.flags, 2)
		elseif damage == "miss" then
			currentDamageInfo.flags = bit.bor(currentDamageInfo.flags, 1)
		end
		if wasHealthyWhenDamaged and self:GetCollisionGroup() ~= COLLISION_GROUP_DEBRIS then
			currentDamageInfo.flags = bit.bor(currentDamageInfo.flags, 8)
		end
		if self:InsaneStats_IsMob() then
			currentDamageInfo.flags = bit.bor(currentDamageInfo.flags, 16)
		end
		currentDamageInfo.types = bit.bor(currentDamageInfo.types, types or 0)
						
		-- generic hitgroup has value 8 for our purposes
		local hitgroup = hitgroup or 0
		if hitgroup == 0 then
			hitgroup = 8
		end
		currentDamageInfo.hitgroup = math.min(currentDamageInfo.hitgroup, hitgroup)
	end
end

local function BroadcastEntityUpdates()
	for k,v in pairs(entitiesRequireUpdate) do
		if not (IsValid(k) and k:EntIndex() > 0) then
			entitiesRequireUpdate[k] = nil
		end
	end
	
	local sentEntities = {}
	
	net.Start("insane_stats")
	net.WriteUInt(1, 8)
	local count = math.min(table.Count(entitiesRequireUpdate), 16)
	net.WriteUInt(count, 8)
	
	for k,v in pairs(entitiesRequireUpdate) do
		net.WriteUInt(k:EntIndex(), 16)
		net.WriteInt(v, 32)
		--print(k)
		--print(v)
		
		if bit.band(v, 1) ~= 0 then
			net.WriteDouble(k:InsaneStats_GetHealth())
			net.WriteDouble(k:InsaneStats_GetMaxHealth())
			net.WriteDouble(k:InsaneStats_GetArmor() or 0)
			net.WriteDouble(k:InsaneStats_GetMaxArmor() or 0)
			--[[net.WriteDouble(k.GetMaxClip1 and k:GetMaxClip1() or 0)
			net.WriteDouble(k.GetMaxClip2 and k:GetMaxClip2() or 0)]]
			--print(k)
		end
		
		if bit.band(v, 2) ~= 0 then
			net.WriteDouble(k:InsaneStats_GetXP())
		end
		
		-- bitflag 4 is for entity name and class, which usually don't change
		
		if bit.band(v, 8) ~= 0 then
			net.WriteDouble(k:InsaneStats_GetBatteryXP())
			net.WriteBool(k.insaneStats_ModifierChangeReason == 1)
			net.WriteInt(k.insaneStats_Tier or 1, 16)
			local modifiers = k.insaneStats_Modifiers or {}
			net.WriteUInt(table.Count(modifiers), 16)
			for k2,v2 in pairs(modifiers) do
				net.WriteString(k2)
				net.WriteUInt(v2-1, 16)
			end
		end
		
		if bit.band(v, 16) ~= 0 then
			local toNetworkStatusEffects = k.insaneStats_StatusEffectsToNetwork or {}
			local data = {}
			
			for k2,v2 in pairs(toNetworkStatusEffects) do
				local statusEffectData = k.insaneStats_StatusEffects and k.insaneStats_StatusEffects[k2]
				if statusEffectData then
					table.insert(data, {
						id = InsaneStats:GetStatusEffectID(k2),
						expiry = statusEffectData.expiry,
						level = statusEffectData.level
					})
				else
					table.insert(data, {
						id = InsaneStats:GetStatusEffectID(k2),
						expiry = 0,
						level = 0
					})
				end
			end
			
			net.WriteUInt(#data, 16)
			for i,v2 in ipairs(data) do
				net.WriteUInt(v2.id or 0, 16)
				net.WriteDouble(v2.level)
				net.WriteFloat(v2.expiry)
			end
			
			k.insaneStats_StatusEffectsToNetwork = {}
		end
		
		-- bitflag 32 is for disposition, but that works on a per player basis, so broadcasting isn't suitable
		
		if bit.band(v, 64) ~= 0 then
			net.WriteDouble(k:InsaneStats_GetCoins())
			net.WriteUInt(k:InsaneStats_GetLastCoinTier() + 1, 8)
		end

		if bit.band(v, 128) ~= 0 then
			net.WriteUInt(table.Count(k:InsaneStats_GetSkills()), 8)
			for k2,v2 in pairs(k:InsaneStats_GetSkills()) do
				net.WriteUInt(InsaneStats:GetSkillID(k2), 8)
				net.WriteUInt(v2, 16)
			end
			net.WriteUInt(table.Count(k:InsaneStats_GetSealedSkills()), 8)
			for k2,v2 in pairs(k:InsaneStats_GetSealedSkills()) do
				net.WriteUInt(InsaneStats:GetSkillID(k2), 8)
			end
		end
		
		if bit.band(v, 256) ~= 0 then
			net.WriteUInt(k.insaneStats_CitizenFlags, 4)
		end

		if bit.band(v, 512) ~= 0 then
			net.WriteDouble(k.insaneStats_Clip1Adj or 0)
			net.WriteDouble(k.insaneStats_Clip2Adj or 0)
		end
		
		--print(k, v)
		entitiesRequireUpdate[k] = nil
		table.insert(sentEntities, k)
		count = count - 1
		if count == 0 then break end
	end
	
	--[[local bytesWritten = net.BytesWritten()
	if bytesWritten > 2048 then
		InsaneStats:Log("WARNING: A "..string.Comma(bytesWritten).." byte entity broadcast packet in a single tick?! At this rate we'd be sending "..string.NiceSize(bytesWritten*200/3).."/s to everyone!")
		InsaneStats:Log("Sent entities: ")
		PrintTable(sentEntities)
	end]]
	
	net.Broadcast()
end

local function BroadcastDamageUpdates()
	net.Start("insane_stats", true)
	net.WriteUInt(3, 8)
	local count = math.min(table.Count(damageInfosRequireUpdate), 255)
	net.WriteUInt(count, 8)
	
	for k,v in pairs(damageInfosRequireUpdate) do
		net.WriteUInt(k, 16)
		net.WriteEntity(v.attacker or NULL)
		net.WriteDouble(v.damage or 0)
		net.WriteUInt(v.types or 0, 32)
		if v.hitgroup == 8 then
			net.WriteInt(0, 8)
		else
			net.WriteInt(v.hitgroup or 0, 8)
		end
		net.WriteVector(v.position)
		
		local isAlly = false
		local ent = Entity(k)
		if (IsValid(ent) and ent:IsNPC()) then
			isAlly = ent:InsaneStats_GetEntityData("is_ally")
		end
		net.WriteUInt(bit.bor(
			v.flags,
			isAlly and 4 or 0
		), 8)
		
		damageInfosRequireUpdate[k] = nil
		count = count - 1
		if count == 0 then break end
	end
	
	net.Broadcast()
end

-- this coroutine thread is to deal with dispositions
local npcs = ents.GetAll()
local dispositionScanner = coroutine.create(function()
	while true do
		local i = 1
		while npcs[i] do
			local ent = npcs[i]
			
			if (IsValid(ent) and ent:IsNPC()) then
				local isAlly, isEnemy = false, false
				
				for i,v in player.Iterator() do
					if IsValid(ent) and IsValid(v) then
						local disposition = ent:Disposition(v)
						if disposition == D_LI then
							isAlly = true
						elseif disposition == D_HT then
							isEnemy = true
						end
					end

					if isAlly and isEnemy then break end
					coroutine.yield()
				end

				if (IsValid(ent) and ent:GetClass() == "npc_citizen") then
					if (ent:GetInternalVariable("squadname") == "player_squad")
					== (bit.band(ent.insaneStats_CitizenFlags or 0, 4) == 0) then
						ent.insaneStats_CitizenFlags = bit.band(
							ent.insaneStats_CitizenFlags or 0,
							bit.bnot(ent:GetInternalVariable("squadname") == "player_squad" and 0 or 4)
						)
						ent:InsaneStats_MarkForUpdate(256)
					end
				end
				
				ent:InsaneStats_SetEntityData("is_ally", isAlly)
				ent:InsaneStats_SetEntityData("is_enemy", isEnemy)
				
				i = i + 1
			else
				table.remove(npcs, i)
			end
			coroutine.yield()
		end
		coroutine.yield(true)
	end
end)

hook.Add("InsaneStatsEntityCreated", "InsaneStatsNet", function(ent)
	if ent:IsNPC() then
		table.insert(npcs, ent)
	end
end)

hook.Add("Think", "InsaneStatsNet", function()
	if next(entitiesRequireUpdate) then
		BroadcastEntityUpdates()
	end
	
	--[[if next(entityDispositionsRequireUpdate) then
		BroadcastEntityDispositionUpdates()
	end]]
	
	if next(damageInfosRequireUpdate) then
		BroadcastDamageUpdates()
	end

	for i=1,66 do
		local success, ret = coroutine.resume(dispositionScanner)
		if success then
			if ret then break end
		else
			error(ret)
		end
	end
end)

local nextEntityUpdatePlayers = {}
net.Receive("insane_stats", function(length, ply)
	local func = net.ReadUInt(8)
	if func == 1 then
		local entities = {}
		local entityCount = net.ReadUInt(8)
		for i=1, entityCount do
			table.insert(entities, net.ReadEntity())
		end
		for _, updateEntity in ipairs(entities) do
			local steamID = ply:SteamID()
			nextEntityUpdatePlayers[steamID] = nextEntityUpdatePlayers[steamID] or {}
			
			if IsValid(updateEntity) then
				local creationID = updateEntity:GetCreationID()
				
				if (nextEntityUpdatePlayers[steamID][creationID] or 0) <= RealTime() then
					nextEntityUpdatePlayers[steamID][creationID] = RealTime() + 0.5
					local flags = 63
					if updateEntity.insaneStats_CitizenFlags then
						flags = bit.bor(flags, 256)
					end
					--[[if updateEntity.npcLVL then
						flags = bit.bor(flags, 128)
					end]]
					
					net.Start("insane_stats")
					net.WriteUInt(1, 8)
					net.WriteUInt(1, 8)
					net.WriteUInt(updateEntity:EntIndex(), 16)
					
					net.WriteInt(flags, 32)
					
					net.WriteDouble(updateEntity:InsaneStats_GetHealth())
					net.WriteDouble(updateEntity:InsaneStats_GetMaxHealth())
					net.WriteDouble(updateEntity:InsaneStats_GetArmor())
					net.WriteDouble(updateEntity:InsaneStats_GetMaxArmor())
					
					net.WriteDouble(updateEntity:InsaneStats_GetXP())
					
					net.WriteString(updateEntity:GetClass())
					net.WriteString(updateEntity:GetName())
					net.WriteBool(updateEntity:InsaneStats_GetIsAlpha())
						
					net.WriteDouble(updateEntity:InsaneStats_GetBatteryXP())
					net.WriteBool(updateEntity.insaneStats_ModifierChangeReason == 1)
					net.WriteUInt(updateEntity.insaneStats_Tier or 0, 16)
					local modifiers = updateEntity.insaneStats_Modifiers or {}
					--print(updateEntity, modifiers)
					net.WriteUInt(table.Count(modifiers), 16)
					for k2,v2 in pairs(modifiers) do
						net.WriteString(k2)
						net.WriteUInt(v2-1, 16)
					end
					
					local allStatusEffectData = {}
					for k,v in pairs(updateEntity.insaneStats_StatusEffects or {}) do
						table.insert(allStatusEffectData, {
							id = InsaneStats:GetStatusEffectID(k),
							expiry = v.expiry,
							level = v.level
						})
					end
					
					net.WriteUInt(#allStatusEffectData, 16)
					for k,v in pairs(allStatusEffectData) do
						net.WriteUInt(v.id, 16)
						net.WriteDouble(v.level)
						net.WriteFloat(v.expiry)
					end
					
					if updateEntity:IsNPC() then
						net.WriteInt(updateEntity:Disposition(ply), 4)
					else
						net.WriteInt(-1, 4)
					end

					--print(flags)
					--[[if bit.band(flags, 128) ~= 0 then
						local npcLevelToWrite = updateEntity.npcLVL
						local dangerous = false

						-- SUPER HACK: get the world level and prestige by reading the first upvalue of NPCInit
						-- this is an absolutely catastrophic thing to do but there'd be
						-- literally no way otherwise to get the world level
						-- also debug.getupvalue seems to be pending removal so check if it exists
						if debug.getupvalue then
							local _, worldLevel = debug.getupvalue(NPCInit, 1)
							local _2, worldPrestige = debug.getupvalue(NPCInit, 2)
							dangerous = npcLevelToWrite >= worldLevel + 5 * worldPrestige
						end

						net.WriteInt(npcLevelToWrite, 32)
						net.WriteBool(dangerous)
					end]]

					if bit.band(flags, 256) ~= 0 then
						net.WriteUInt(updateEntity.insaneStats_CitizenFlags, 4)
					end
					
					net.Send(ply)
				end
			end
		end
	elseif func == 2 and ply:IsAdmin() then
		for i=1, net.ReadUInt(8) do
			local conVarName = net.ReadString()
			if conVarName == "insanestats_revert_all_server_convars" then
				RunConsoleCommand("insanestats_revert_all_server_convars", "yes")
			else
				local typ = InsaneStats:GetConVarData(conVarName).type
				
				if typ == InsaneStats.BOOL then
					InsaneStats:GetConVarData(conVarName).conVar:SetBool(net.ReadBool())
				elseif typ == InsaneStats.INT then
					InsaneStats:GetConVarData(conVarName).conVar:SetInt(net.ReadInt(32))
				elseif typ == InsaneStats.FLOAT then
					InsaneStats:GetConVarData(conVarName).conVar:SetFloat(net.ReadDouble())
				else
					InsaneStats:GetConVarData(conVarName).conVar:SetString(net.ReadString())
				end
			end
		end
	elseif func == 3 then
		ply:InsaneStats_AttemptEquipItem(ply:GetUseEntity())
	elseif func == 4 then
		ply.insaneStats_HoldingCtrl = net.ReadBool()
		hook.Run("InsaneStatsCtrlStateChanged", ply, ply.insaneStats_HoldingCtrl)
	elseif func == 5 then
		local shopEntity = net.ReadEntity()
		if (IsValid(shopEntity) and shopEntity:GetClass() == "insanestats_shop"
		and shopEntity:WorldSpaceCenter():DistToSqr(ply:GetShootPos()) < 32768) then
			local subFunc = net.ReadUInt(4)
			if subFunc == 1 then
				local wepIndex = net.ReadUInt(16)
				local price = InsaneStats:GetWeaponCost(wepIndex)
				if ply:InsaneStats_GetCoins() >= price then
					local class = InsaneStats.ShopItemsAutomaticPrice[wepIndex]
					local wep = ply:Give(class)
					if IsValid(wep) then
						ply:InsaneStats_RemoveCoins(price)
					end
				end
			elseif subFunc == 2 then
				local itemIndex = net.ReadUInt(16)
				local price = InsaneStats:GetItemCost(itemIndex, ply)
				if ply:InsaneStats_GetCoins() >= price then
					local itemName = InsaneStats.ShopItems[itemIndex][1]
					local item = ply:Give(itemName)
					if IsValid(item) then
						ply:InsaneStats_RemoveCoins(price)
					end
				end
			elseif subFunc == 3 then
				local ent = net.ReadEntity()
				if (IsValid(ent) and ent:GetOwner() == ply) or ent == ply then
					local tier = ent.insaneStats_Tier or 0
					local reforgeBlacklist = ply:InsaneStats_GetReforgeBlacklist()
					local price = InsaneStats:GetReforgeCost(ent, reforgeBlacklist)
					if ply:InsaneStats_GetCoins() >= price and tier ~= 0 then
						hook.Run("InsaneStatsPreReforge", ent, ply)
						ent.insaneStats_Modifiers = {}
						InsaneStats:ApplyWPASS2Modifiers(ent, reforgeBlacklist)
						ent.insaneStats_ModifierChangeReason = 2
						ply:InsaneStats_RemoveCoins(price)
					end
				end
			elseif subFunc == 4 and bit.band(InsaneStats:GetConVarValue("skills_allow_reset"), 2) ~= 0 then
				local price = InsaneStats:GetRespecCost(ply)
				if ply:InsaneStats_GetCoins() >= InsaneStats:GetRespecCost(ply) then
					ply:InsaneStats_SetSkills({})
					ply:InsaneStats_SetSealedSkills({})
					ply:InsaneStats_RemoveCoins(price)
					
					ply:InsaneStats_MarkForUpdate(128)
				end
			elseif subFunc == 5 then
				-- update the user's modifier blacklist
				local modifierBlacklist = {}
				for i=1, net.ReadUInt(16) do
					modifierBlacklist[net.ReadString()] = true
				end
				ply:InsaneStats_SetReforgeBlacklist(modifierBlacklist)
			elseif subFunc == 6 then
				ammoType = net.ReadUInt(9)
				level = ply:InsaneStats_GetLevel()
				if ammoType == 257 then
					local qty = net.ReadDouble()
					local unitPrice = InsaneStats:ScaleValueToLevel(
						InsaneStats:GetConVarValue("coins_health_cost"),
						InsaneStats:GetConVarValue("coins_health_cost_add")/100,
						level,
						"coins_health_cost_mode"
					)
					local price = qty * unitPrice
					local missingHealth = ply:InsaneStats_GetMaxHealth() - ply:InsaneStats_GetHealth()
					if not hook.Run("InsaneStatsBlockFreebie", ply, shopEntity, ammoType) and missingHealth > 0 then
						price = math.max(0, price - missingHealth * unitPrice)
					end
					if ply:InsaneStats_GetCoins() >= price then
						local linearAdd = math.Clamp(missingHealth, 0, qty)
						qty = (qty - linearAdd) / InsaneStats:GetConVarValue("coins_health_cost_overmul") + linearAdd
						ply:InsaneStats_AddHealthNerfed(qty, true)
						ply:InsaneStats_RemoveCoins(price)
					end
				elseif ammoType == 258 then
					local qty = net.ReadDouble()
					local unitPrice = InsaneStats:ScaleValueToLevel(
						InsaneStats:GetConVarValue("coins_armor_cost"),
						InsaneStats:GetConVarValue("coins_armor_cost_add")/100,
						level,
						"coins_armor_cost_mode"
					)
					local price = qty * unitPrice
					local missingArmor = ply:InsaneStats_GetMaxArmor() - ply:InsaneStats_GetArmor()
					if not hook.Run("InsaneStatsBlockFreebie", ply, shopEntity, ammoType) and missingArmor > 0 then
						price = math.max(0, price - missingArmor * unitPrice)
					end
					if ply:InsaneStats_GetCoins() >= price then
						local linearAdd = math.Clamp(missingArmor, 0, qty)
						qty = (qty - linearAdd) / InsaneStats:GetConVarValue("coins_armor_cost_overmul") + linearAdd
						ply:InsaneStats_AddArmorNerfed(qty, true)
						ply:InsaneStats_RemoveCoins(price)
					end
				elseif ammoType == 259 then
					local qty = net.ReadDouble()
					local unitPrice = InsaneStats:GetConVarValue("coins_xp_cost")
					local price = qty * unitPrice
					if ply:InsaneStats_GetCoins() >= price then
						ply:InsaneStats_SetXP(ply:InsaneStats_GetXP() + qty)
						ply:InsaneStats_RemoveCoins(price)
					end
				else
					local qty = net.ReadDouble()
					local unitPrice = InsaneStats:ScaleValueToLevel(
						InsaneStats:GetConVarValue("coins_ammo_cost") / game.GetAmmoMax(ammoType),
						InsaneStats:GetConVarValue("coins_ammo_cost_add")/100,
						level, "coins_ammo_cost_mode"
					)
					local price = qty * unitPrice
					if not hook.Run("InsaneStatsBlockFreebie", ply, shopEntity, ammoType) then
						price = 0
					end
					if ply:InsaneStats_GetCoins() >= price then
						ply:GiveAmmo(qty, ammoType)
						ply:InsaneStats_RemoveCoins(price)

						if ammoType == 10 and not ply:HasWeapon("weapon_frag") then
							ply:Give("weapon_frag")
						end
					end
				end
			end
		end
	elseif func == 6 then
		--[[
			operations:
			0: add 1
			1: add max
			2: seal
			3: disable (admin only)
			4: use skill ID for extended operation codes
		]]
		local operation = net.ReadUInt(4)
		if operation == 0 then
			local skillID = net.ReadUInt(8) + 1
			local skillName = InsaneStats:GetSkillName(skillID)
			if skillName then
				local max = ply:InsaneStats_GetSkillMaxLevel(skillName)
				local currentTier = ply:InsaneStats_GetSkillTier(skillName)
				if currentTier < max and ply:InsaneStats_GetSkillPoints() >= 1 then
					ply:InsaneStats_SetSkillTier(skillName, currentTier+1)
				elseif currentTier == max and ply:InsaneStats_GetUberSkillPoints() >= 1 then
					ply:InsaneStats_SetSkillTier(skillName, currentTier*2)
				elseif currentTier > max and currentTier < max * 2 and ply:InsaneStats_GetSkillPoints() >= 1 then
					ply:InsaneStats_SetSkillTier(skillName, currentTier+2)
				end
			end
		elseif operation == 1 then
			local skillID = net.ReadUInt(8) + 1
			local skillName = InsaneStats:GetSkillName(skillID)
			if skillName then
				local max = ply:InsaneStats_GetSkillMaxLevel(skillName)
				local currentTier = ply:InsaneStats_GetSkillTier(skillName)
				local div = currentTier > max and 2 or 1
				local spend = math.min(ply:InsaneStats_GetSkillPoints(), max - currentTier / div)
				
				ply:InsaneStats_SetSkillTier(skillName, currentTier + spend * div)
			end
		elseif operation == 2 and ply:InsaneStats_CanSealSkills() then
			local skillID = net.ReadUInt(8) + 1
			local skillName = InsaneStats:GetSkillName(skillID)
			if skillName and (ply:InsaneStats_IsSkillSealed(skillName) or not hook.Run("InsaneStatsCannotSealSkill", skillName)) then
				ply:InsaneStats_SealSkill(skillName)
			end
		elseif operation == 3 and ply:InsaneStats_CanDisableSkills() then
			local skillID = net.ReadUInt(8) + 1
			local skillName = InsaneStats:GetSkillName(skillID)
			if skillName then
				local newState = not InsaneStats:IsSkillDisabled(skillName)
				InsaneStats:DisableSkill(skillName, newState or nil)

				for i,v in ents.Iterator() do
					v:InsaneStats_MarkForUpdate(128)
				end

				net.Start("insane_stats")
				net.WriteUInt(7, 8)
				net.WriteBool(false)
				net.WriteUInt(skillID, 8)
				net.WriteBool(newState)
				net.Broadcast()
			end
		elseif operation == 4 then
			local suboperation = net.ReadUInt(8)
			if suboperation == 0 then
				for i,v in ents.Iterator() do
					v:InsaneStats_MarkForUpdate(128)
				end

				local skills = InsaneStats:GetDisabledSkills()
				net.Start("insane_stats")
				net.WriteUInt(7, 8)
				net.WriteBool(true)
				net.WriteUInt(table.Count(skills), 8)
				for k2,v2 in pairs(skills) do
					net.WriteUInt(InsaneStats:GetSkillID(k2), 8)
				end
				net.Send(ply)
			elseif suboperation == 1 then
				ply:InsaneStats_MaxAllSkills(false)
			elseif suboperation == 2 then
				ply:InsaneStats_MaxAllSkills(true)
			elseif suboperation == 3 and bit.band(InsaneStats:GetConVarValue("skills_allow_reset"), 1) ~= 0 then
				ply:InsaneStats_SetSkills({})
				ply:InsaneStats_SetSealedSkills({})
			end
		end
		
		-- send to players
		ply:InsaneStats_MarkForUpdate(128)
	elseif func == 7 then
		local lookPositions = {}
		for i,v in ipairs(ents.FindByClass("trigger_look")) do
			local targetEnts = ents.FindByName(v:GetInternalVariable("target"))
			for j,v2 in ipairs(targetEnts) do
				table.insert(lookPositions, v2:GetPos())
			end
		end

		net.Start("insane_stats", true)
		net.WriteUInt(9, 8)
		net.WriteUInt(#lookPositions, 8)
		for i,v in ipairs(lookPositions) do
			net.WriteVector(v)
		end
		net.Send(ply)
	end
end)
