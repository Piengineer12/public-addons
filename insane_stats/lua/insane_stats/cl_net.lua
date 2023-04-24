local ENT = FindMetaTable("Entity")

local nextEntityUpdateTimestamp = 0
function ENT:InsaneStats_MarkForUpdate()
	if nextEntityUpdateTimestamp < RealTime() then
		nextEntityUpdateTimestamp = RealTime() + 0.1
		
		-- probe the server for status update
		net.Start("insane_stats")
		net.WriteUInt(1, 8)
		net.WriteEntity(self)
		net.SendToServer()
	end
end

net.Receive("insane_stats", function()
	local func = net.ReadUInt(8)
	if func == 1 then
		local count = net.ReadUInt(8)
		--print(count)
		for i=1,count do
			local entIndex = net.ReadUInt(16)
			local ent = Entity(entIndex)
			
			if IsValid(ent) and entIndex == ent:EntIndex() then
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
					local modifierChangeReason = net.ReadBool()
					ent.insaneStats_Tier = net.ReadUInt(16)
					local modifiers = {}
					for i=1, net.ReadUInt(16) do
						local key = net.ReadString()
						local value = net.ReadUInt(16)+1
						modifiers[key] = value
					end
					
					hook.Run("InsaneStatsModifiersChanging", ent, ent.insaneStats_Modifiers, modifiers, modifierChangeReason)
					
					ent.insaneStats_Modifiers = modifiers
					InsaneStats:ApplyWPASS2Attributes(ent)
					ent.insaneStats_WPASS2Name = nil
				end
				
				if bit.band(flags, 16) ~= 0 then
					ent.insaneStats_StatusEffects = ent.insaneStats_StatusEffects or {}
					
					for i=1, net.ReadUInt(16) do
						local id = net.ReadUInt(16)
						local level = net.ReadDouble()
						local expiry = net.ReadFloat()
						
						-- decode the id to a named one
						local idStr = InsaneStats:GetStatusEffectName(id)
						
						if idStr then
							ent.insaneStats_StatusEffects[idStr] = {level = level, expiry = expiry}
						end
					end
				end
				
				hook.Run("InsaneStatsEntityUpdated", ent, flags)
			--[[else -- oh no
				return]]
			end
		end
	elseif func == 2 then
		hook.Run("HUDItemPickedUp", net.ReadString())
	elseif func == 3 then
		local count = net.ReadUInt(8)
		--print(count)
		for i=1,count do
			local entIndex = net.ReadUInt(16)
			local attacker = net.ReadEntity()
			local damage = net.ReadDouble()
			local types = net.ReadUInt(32)
			local hitgroup = net.ReadInt(8)
			local position = net.ReadVector()
			local flags = net.ReadUInt(8)
			hook.Run("InsaneStatsHUDDamageTaken", entIndex, attacker, damage, types, hitgroup, position, flags)
		end
	elseif func == 4 then
		-- the server will send the entity index, but also the entity position, class, health and armor (if any)
		-- since we can't see entities outside our PVS
		local entIndex = net.ReadUInt(16)
		local pos = net.ReadVector()
		local class = net.ReadString()
		local health = net.ReadDouble()
		local maxHealth = net.ReadDouble()
		local armor = net.ReadDouble()
		local maxArmor = net.ReadDouble()
		
		hook.Run("InsaneStatsWPASS2EntityMarked", entIndex, pos, class, health, maxHealth, armor, maxArmor)
	end
end)