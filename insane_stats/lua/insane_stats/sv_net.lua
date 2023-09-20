util.AddNetworkString("insane_stats")

local ENT = FindMetaTable("Entity")
local players = {}
local entitiesRequireUpdate = {}
--local entityDispositionsRequireUpdate = {}
local damageInfosRequireUpdate = {}

function ENT:InsaneStats_MarkForUpdate(flag)
	if (self:GetModel() or "") ~= "" and IsValid(self) then
		entitiesRequireUpdate[self] = bit.bor(entitiesRequireUpdate[self] or 0, flag)
	end
end

--[[function ENT:InsaneStats_MarkForDispositionUpdate()
	if self:IsNPC() then
		entityDispositionsRequireUpdate[self] = true
	end
end]]

function ENT:InsaneStats_DamageNumber(attacker, damage, types, hitgroup)
	local entIndex = self:EntIndex()
	
	damageInfosRequireUpdate[entIndex] = damageInfosRequireUpdate[entIndex]
		or {damage = 0, types = 0, flags = 0, hitgroup = 10, position = self:LocalToWorld(self:OBBCenter())}
	
	local currentDamageInfo = damageInfosRequireUpdate[entIndex]
	currentDamageInfo.attacker = IsValid(attacker) and attacker or currentDamageInfo.attacker
	if tonumber(damage) then
		currentDamageInfo.damage = currentDamageInfo.damage + damage
	elseif damage == "immune" then
		currentDamageInfo.flags = bit.bor(currentDamageInfo.flags, 2)
	elseif damage == "miss" then
		currentDamageInfo.flags = bit.bor(currentDamageInfo.flags, 1)
	end
	currentDamageInfo.types = bit.bor(currentDamageInfo.types, types or 0)
					
	-- generic hitgroup has value 8 for our purposes
	local hitgroup = hitgroup or 0
	if hitgroup == 0 then
		hitgroup = 8
	end
	currentDamageInfo.hitgroup = math.min(currentDamageInfo.hitgroup, hitgroup)
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
	local count = math.min(table.Count(entitiesRequireUpdate), 32)
	net.WriteUInt(count, 8)
	
	for k,v in pairs(entitiesRequireUpdate) do
		net.WriteUInt(k:EntIndex(), 16)
		net.WriteUInt(v, 8)
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
			net.WriteUInt(k.insaneStats_Tier, 16)
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
			for k,v in pairs(data) do
				net.WriteUInt(v.id, 16)
				net.WriteDouble(v.level)
				net.WriteFloat(v.expiry)
			end
			
			k.insaneStats_StatusEffectsToNetwork = {}
		end
		
		-- bitflag 32 is for disposition, but that works on a per player basis, so broadcasting isn't suitable
		
		if bit.band(v, 64) ~= 0 then
			net.WriteDouble(k:InsaneStats_GetCoins())
			net.WriteUInt(k:InsaneStats_GetLastCoinTier() + 1, 8)
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

--[[local function BroadcastEntityDispositionUpdates()
	for k,v in pairs(entityDispositionsRequireUpdate) do
		if not IsValid(k) then
			entityDispositionsRequireUpdate[k] = nil
		end
	end
	
	if next(entityDispositionsRequireUpdate) then
		for k,v in pairs(player.GetAll()) do
			net.Start("insane_stats")
			net.WriteUInt(1, 8)
			local count = math.min(table.Count(entityDispositionsRequireUpdate), 127)
			net.WriteUInt(count, 8)
			
			for k2,v2 in pairs(entityDispositionsRequireUpdate) do
				net.WriteUInt(k2:EntIndex(), 16)
				net.WriteUInt(32, 8)
				
				-- bitflag 32 is for disposition, but that works on a per player basis, so broadcasting isn't suitable
				
				--print(k, v)
				entityDispositionsRequireUpdate[k2] = nil
				count = count - 1
				if count == 0 then break end
			end
			
			net.Send(v)
		end
	end
end]]

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
			isAlly = ent.insaneStats_IsAlly
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

local npcs = ents.GetAll()
timer.Create("InsaneStatsNet", 0.5, 0, function()
	players = player.GetAll()
	
	local i = 1
	while npcs[i] do
		local ent = npcs[i]
		
		if (IsValid(ent) and ent:IsNPC()) then
			local isAlly, isEnemy = false, false
			
			for i,v in ipairs(players) do
				if ent:Disposition(v) == D_LI then
					isAlly = true
				elseif ent:Disposition(v) == D_HT then
					isEnemy = true
				end
			end
			
			ent.insaneStats_IsAlly = isAlly
			ent.insaneStats_IsEnemy = isEnemy
			--print("ent.insaneStats_IsAlly, ent.insaneStats_IsEnemy", isAlly, isEnemy)
			
			i = i + 1
		else
			table.remove(npcs, i)
		end
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
end)

local nextEntityUpdatePlayers = {}
net.Receive("insane_stats", function(length, ply)
	local func = net.ReadUInt(8)
	if func == 1 then
		local steamID = ply:SteamID()
		local updateEntity = net.ReadEntity()
		
		nextEntityUpdatePlayers[steamID] = nextEntityUpdatePlayers[steamID] or {}
		
		if IsValid(updateEntity) then
			local creationID = updateEntity:GetCreationID()
			
			if (nextEntityUpdatePlayers[steamID][creationID] or 0) < RealTime() then
				nextEntityUpdatePlayers[steamID][creationID] = RealTime() + 1
				
				net.Start("insane_stats")
				net.WriteUInt(1, 8)
				net.WriteUInt(1, 8)
				net.WriteUInt(updateEntity:EntIndex(), 16)
				
				net.WriteUInt(63, 8)
				
				net.WriteDouble(updateEntity:InsaneStats_GetHealth())
				net.WriteDouble(updateEntity:InsaneStats_GetMaxHealth())
				net.WriteDouble(updateEntity:InsaneStats_GetArmor())
				net.WriteDouble(updateEntity:InsaneStats_GetMaxArmor())
				
				net.WriteDouble(updateEntity:InsaneStats_GetXP())
				
				net.WriteString(updateEntity:GetClass())
				net.WriteString(updateEntity:GetName())
					
				net.WriteDouble(updateEntity:InsaneStats_GetBatteryXP())
				net.WriteBool(updateEntity.insaneStats_ModifierChangeReason == 1)
				net.WriteUInt(updateEntity.insaneStats_Tier or 0, 16)
				local modifiers = updateEntity.insaneStats_Modifiers or {}
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
				
				net.Send(ply)
			end
		end
	elseif func == 2 and ply:IsAdmin() then
		for i=1, net.ReadUInt(8) do
			local conVarName = net.ReadString()
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
	elseif func == 3 then
		ply:InsaneStats_AttemptEquipItem(ply:GetUseEntity())
	elseif func == 4 then
		ply.insaneStats_HoldingCtrl = net.ReadBool()
	end
end)