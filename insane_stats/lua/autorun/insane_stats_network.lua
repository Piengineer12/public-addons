if SERVER then
	util.AddNetworkString("insane_stats")
	local nextEntityUpdatePlayers = {}
	
	net.Receive("insane_stats", function(length, ply)
		local steamID = ply:SteamID()
		local updateEntity = net.ReadEntity()
		
		nextEntityUpdatePlayers[steamID] = nextEntityUpdatePlayers[steamID] or {}
		
		if IsValid(updateEntity) then
			local creationID = updateEntity:GetCreationID()
			
			if (nextEntityUpdatePlayers[steamID][creationID] or 0) < RealTime() then
				nextEntityUpdatePlayers[steamID][creationID] = RealTime() + 0.25
				
				net.Start("insane_stats")
				net.WriteUInt(1, 8)
				net.WriteUInt(1, 8)
				net.WriteEntity(updateEntity)
				net.WriteUInt(15, 8)
				net.WriteDouble(updateEntity:InsaneStats_GetFractionalHealth())
				net.WriteDouble(updateEntity:InsaneStats_GetFractionalMaxHealth())
				net.WriteDouble(updateEntity:InsaneStats_GetFractionalArmor())
				net.WriteDouble(updateEntity:InsaneStats_GetFractionalMaxArmor())
				net.WriteDouble(updateEntity:InsaneStats_GetXP())
				net.WriteString(updateEntity:GetClass())
				net.WriteString(updateEntity:GetName())
				if updateEntity:IsNPC() then
					net.WriteInt(updateEntity:Disposition(ply), 4)
				else
					net.WriteInt(-1, 4)
				end
				--if updateEntity:InsaneStats_IsWPASS2Able() then
					if not updateEntity.insaneStats_Modifiers and updateEntity:InsaneStats_IsWPASS2Able() or updateEntity == ply then
						-- quickly fill it in
						InsaneStats_ApplyWPASS2Modifiers(updateEntity)
						-- PrintTable(updateEntity.insaneStats_Modifiers)
					end
					
					net.WriteDouble(updateEntity.insaneStats_BatteryXP or 0)
					net.WriteUInt(updateEntity.insaneStats_Tier or 0, 16)
					local modifiers = updateEntity.insaneStats_Modifiers or {}
					net.WriteUInt(table.Count(modifiers), 16)
					for k2,v2 in pairs(modifiers) do
						net.WriteString(k2)
						net.WriteUInt(v2-1, 16)
					end
				--[[else
					net.WriteUInt(0, 16)
					net.WriteUInt(0, 16)
				end]]
				net.Send(ply)
			end
		end
	end)
end

if CLIENT then
	net.Receive("insane_stats", function()
		local func = net.ReadUInt(8)
		if func == 1 then
			local count = net.ReadUInt(8)
			--print(count)
			for i=1,count do
				local ent = net.ReadEntity()
				--print(ent)
				
				if IsValid(ent) then
					local flags = net.ReadUInt(8)
					--print(flags)
					
					if bit.band(flags, 1) ~= 0 then
						local health = net.ReadDouble()
						local maxHealth = net.ReadDouble()
						local armor = net.ReadDouble()
						local maxArmor = net.ReadDouble()
						
						ent:SetHealth(health)
						if ent.SetMaxHealth then
							ent:SetMaxHealth(maxHealth)
						end
						if ent.SetArmor then
							ent:SetArmor(armor)
						end
						if ent.SetMaxArmor then
							ent:SetMaxArmor(maxArmor)
						end
					end
					
					if bit.band(flags, 2) ~= 0 then
						ent:InsaneStats_SetXP(net.ReadDouble())
						--print(ent, ent:InsaneStats_GetXP())
					end
					
					if bit.band(flags, 4) ~= 0 then
						ent.insaneStats_Class = net.ReadString()
						ent.insaneStats_Name = net.ReadString()
						ent.insaneStats_Disposition = net.ReadInt(4)
					end
					
					if bit.band(flags, 8) ~= 0 then
						ent.insaneStats_BatteryXP = net.ReadDouble()
						ent.insaneStats_Tier = net.ReadUInt(16)
						local modifiers = {}
						for i=1, net.ReadUInt(16) do
							local key = net.ReadString()
							local value = net.ReadUInt(16)+1
							modifiers[key] = value
						end
						
						ent.insaneStats_Modifiers = modifiers
						InsaneStats_ApplyWPASS2Attributes(ent)
						ent.insaneStats_WPASS2Name = nil
					end
					
					if bit.band(flags, 16) ~= 0 then
						ent.insaneStats_StatusEffects = ent.insaneStats_StatusEffects or {}
						
						for i=1, net.ReadUInt(16) do
							local id = net.ReadUInt(16)
							local level = net.ReadDouble()
							local expiry = net.ReadFloat()
							
							-- decode the id to a named one
							local idStr = InsaneStats_GetStatusEffectName(id)
							
							ent.insaneStats_StatusEffects[id] = {level = level, expiry = expiry}
						end
					end
					
					hook.Run("InsaneStatsEntityUpdated", ent, flags)
				else -- oh no
					return
					--[[local flags = net.ReadUInt(8)
					local data = {}
					
					if bit.band(flags, 1) ~= 0 then
						data.health = net.ReadDouble()
						data.maxHealth = net.ReadDouble()
						data.armor = net.ReadDouble()
						data.maxArmor = net.ReadDouble()
					end
					
					if bit.band(flags, 2) ~= 0 then
						data.xp = net.ReadDouble()
					end
					
					if bit.band(flags, 4) ~= 0 then
						data.class = net.ReadString()
						data.name = net.ReadString()
						data.disposition = net.ReadInt(4)
					end
					
					hook.Run("InsaneStatsInvalidEntityUpdated", entIndex, data)]]
				end
			end
		elseif func == 2 then
			hook.Run("HUDItemPickedUp", net.ReadString())
		end
	end)
end