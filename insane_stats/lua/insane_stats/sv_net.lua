util.AddNetworkString("insane_stats")

local ENT = FindMetaTable("Entity")
local players = {}
local entitiesRequireUpdate = {}
local damageInfosRequireUpdate = {}

function ENT:InsaneStats_MarkForUpdate(flag)
	if (self:GetModel() or "") ~= "" then
		entitiesRequireUpdate[self] = bit.bor(entitiesRequireUpdate[self] or 0, flag)
	end
end

function ENT:InsaneStats_DamageNumber(attacker, damage, types, hitgroup)
	local entIndex = self:EntIndex()
	
	damageInfosRequireUpdate[entIndex] = damageInfosRequireUpdate[entIndex]
		or {damage = 0, types = 0, hitgroup = 10, position = self:LocalToWorld(self:OBBCenter())}
	
	local currentDamageInfo = damageInfosRequireUpdate[entIndex]
	currentDamageInfo.attacker = IsValid(attacker) and attacker or currentDamageInfo.attacker
	if damage == "miss" then
		currentDamageInfo.miss = true
	else
		currentDamageInfo.damage = currentDamageInfo.damage + damage
	end
	currentDamageInfo.types = bit.bor(currentDamageInfo.types, types)
					
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
	
	net.Start("insane_stats")
	net.WriteUInt(1, 8)
	local count = math.min(table.Count(entitiesRequireUpdate), 127)
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
		
		-- bitflag 4 is for entity name, class and disposition, which usually don't change
		
		if bit.band(v, 8) ~= 0 then
			net.WriteDouble(k.insaneStats_BatteryXP or 0)
			net.WriteBool(k.insaneStats_ModifierChangeReason == 1)
			net.WriteUInt(k.insaneStats_Tier, 16)
			local modifiers = k.insaneStats_Modifiers
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
		
		--print(k, v)
		entitiesRequireUpdate[k] = nil
		count = count - 1
		if count == 0 then break end
	end
	
	net.Broadcast()
end

local function BroadcastDamageUpdates()
	net.Start("insane_stats")
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
		net.WriteVector(v.position or v:LocalToWorld(v:OBBCenter()))
		
		local isAlly = false
		local ent = Entity(k)
		if (IsValid(ent) and ent:IsNPC()) then
			for k,v in pairs(players) do
				if ent:Disposition(v) == D_LI then
					isAlly = true break
				end
			end
		end
		net.WriteUInt(bit.bor(
			v.miss and 1 or 0,
			isAlly and 2 or 0
		), 8)
		
		damageInfosRequireUpdate[k] = nil
		count = count - 1
		if count == 0 then break end
	end
	
	net.Broadcast()
end

timer.Create("InsaneStatsNet", 0.5, 0, function()
	players = player.GetAll()
end)

hook.Add("Think", "InsaneStatsNet", function()
	if next(entitiesRequireUpdate) then
		BroadcastEntityUpdates()
	end
	
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
				net.WriteUInt(31, 8)
				net.WriteDouble(updateEntity:InsaneStats_GetHealth())
				net.WriteDouble(updateEntity:InsaneStats_GetMaxHealth())
				net.WriteDouble(updateEntity:InsaneStats_GetArmor())
				net.WriteDouble(updateEntity:InsaneStats_GetMaxArmor())
				
				net.WriteDouble(updateEntity:InsaneStats_GetXP())
				
				net.WriteString(updateEntity:GetClass())
				net.WriteString(updateEntity:GetName())
				if updateEntity:IsNPC() then
					net.WriteInt(updateEntity:Disposition(ply), 4)
				else
					net.WriteInt(-1, 4)
				end
					
				net.WriteDouble(updateEntity.insaneStats_BatteryXP or 0)
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
				InsaneStats:GetConVarData(conVarName).conVar:SetInt(net.ReadInt(8))
			elseif typ == InsaneStats.FLOAT then
				InsaneStats:GetConVarData(conVarName).conVar:SetFloat(net.ReadDouble())
			end
		end
	end
end)