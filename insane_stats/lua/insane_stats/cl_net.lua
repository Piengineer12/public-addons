local ENT = FindMetaTable("Entity")
local entitiesRequireUpdate = {}
local nextEntityUpdateTimestamp = 0

function ENT:InsaneStats_MarkForUpdate()
	entitiesRequireUpdate[self] = true
end

local function BroadcastEntityUpdates()
	if nextEntityUpdateTimestamp < RealTime() then
		nextEntityUpdateTimestamp = RealTime() + 0.1

		local rolledUpEntities = {}
		local count = 0
		for k,v in pairs(entitiesRequireUpdate) do
			if IsValid(k) then
				table.insert(rolledUpEntities, k)
				entitiesRequireUpdate[k] = nil

				count = count + 1
				if count >= 255 then break end
			end
		end
		
		-- probe the server for status updates
		net.Start("insane_stats")
		net.WriteUInt(1, 8)
		net.WriteUInt(count, 8)
		for i,v in ipairs(rolledUpEntities) do
			net.WriteEntity(v)
		end
		net.SendToServer()
	end
end

hook.Add("Think", "InsaneStatsNet", function()
	if next(entitiesRequireUpdate) then
		BroadcastEntityUpdates()
	end
end)

local rechargerClasses = {
	func_healthcharger = true,
	item_healthcharger = true,
	func_recharge = true,
	item_suitcharger = true
}

net.Receive("insane_stats", function()
	local func = net.ReadUInt(8)
	if func == 1 then
		local count = net.ReadUInt(8)
		--print(count)
		for i=1,count do
			local entIndex = net.ReadUInt(16)
			local flags = net.ReadInt(32)
			local health, maxHealth, armor, maxArmor
			local xp, class, name, isAlpha, disposition
			local batteryXP, modifierChangeReason, tier
			local modifiers, statusEffects, coins
			local lastCoinTier--, wpLevel, wpDangerous
			local citizenFlags, skills, sealedSkills
			local clipAdj1, clipAdj2
			
			if bit.band(flags, 1) ~= 0 then
				health = net.ReadDouble()
				maxHealth = net.ReadDouble()
				armor = net.ReadDouble()
				maxArmor = net.ReadDouble()
			end
				
			if bit.band(flags, 2) ~= 0 then
				xp = net.ReadDouble()
			end
				
			if bit.band(flags, 4) ~= 0 then
				class = net.ReadString()
				name = net.ReadString()
				isAlpha = net.ReadBool()
			end
			
			if bit.band(flags, 8) ~= 0 then
				batteryXP = net.ReadDouble()
				modifierChangeReason = net.ReadBool()
				tier = net.ReadInt(16)
				
				modifiers = {}
				for i=1, net.ReadUInt(16) do
					local key = net.ReadString()
					local value = net.ReadUInt(16)+1
					
					if key == "" then
						InsaneStats:Log("Received an empty string for modifier, is the network toasted?")
						InsaneStats:Log("This occured while processing entity %u.", entIndex)
					else
						modifiers[key] = value
					end
				end
			end
			
			if bit.band(flags, 16) ~= 0 then
				statusEffects = {}
				
				for i=1, net.ReadUInt(16) do
					local id = net.ReadUInt(16)
					local level = net.ReadDouble()
					local expiry = net.ReadFloat()
					
					-- decode the id to a named one
					local idStr = InsaneStats:GetStatusEffectName(id)
					
					if idStr then
						statusEffects[idStr] = {level = level, expiry = expiry}
					else
						InsaneStats:Log("Received unknown status effect ID %u, is the network toasted?", id)
						InsaneStats:Log("This occured while processing entity %u.", entIndex)
					end
				end
			end
			
			if bit.band(flags, 32) ~= 0 then
				disposition = net.ReadInt(4)
			end
				
			if bit.band(flags, 64) ~= 0 then
				coins = net.ReadDouble()
				lastCoinTier = net.ReadUInt(8)
			end
			
			if bit.band(flags, 128) ~= 0 then
				skills, sealedSkills = {}, {}
				for i=1, net.ReadUInt(8) do
					local skillName = InsaneStats:GetSkillName(net.ReadUInt(8))
					skills[skillName] = net.ReadUInt(16)
				end
				for i=1, net.ReadUInt(8) do
					local skillName = InsaneStats:GetSkillName(net.ReadUInt(8))
					sealedSkills[skillName] = true
				end
			end

			if bit.band(flags, 256) ~= 0 then
				citizenFlags = net.ReadUInt(4)
			end

			if bit.band(flags, 512) ~= 0 then
				clipAdj1 = net.ReadDouble()
				clipAdj2 = net.ReadDouble()
			end
			
			local ent = Entity(entIndex)
			if IsValid(ent) and entIndex == ent:EntIndex() then
				if health then
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
				
				if xp then
					ent:InsaneStats_SetXP(xp)
				end
				
				if class then
					ent.insaneStats_Class = class
					ent.insaneStats_Name = name
					ent:InsaneStats_SetIsAlpha(isAlpha)
				end
				
				if batteryXP then
					ent:InsaneStats_SetBatteryXP(batteryXP)
					ent.insaneStats_Tier = tier
					
					hook.Run("InsaneStatsModifiersChanging", ent, ent.insaneStats_Modifiers, modifiers, modifierChangeReason)
					
					ent.insaneStats_Modifiers = modifiers
					InsaneStats:ApplyWPASS2Attributes(ent)
					ent.insaneStats_WPASS2Name = nil
				end
				
				if statusEffects then
					--ent.insaneStats_StatusEffects = ent.insaneStats_StatusEffects or {}
					
					for k,v in pairs(statusEffects) do
						--ent.insaneStats_StatusEffects[k] = v
						if v.level == 0 then
							ent:InsaneStats_ClearStatusEffect(k)
						else
							ent:InsaneStats_ApplyStatusEffect(k, v.level, v.expiry - CurTime(), {replace = true})
						end
					end
				end
				
				if disposition then
					ent.insaneStats_Disposition = disposition
				end
				
				if coins then
					ent:InsaneStats_SetCoins(coins)
					ent:InsaneStats_SetLastCoinTier(lastCoinTier - 1)
				end

				if skills then
					ent:InsaneStats_SetSkills(skills)
					ent:InsaneStats_SetSealedSkills(sealedSkills)
				end

				if citizenFlags then
					ent.insaneStats_CitizenFlags = citizenFlags
				end

				if clipAdj1 then
					ent.insaneStats_Clip1Adj = clipAdj1
					ent.insaneStats_Clip2Adj = clipAdj2
				end
				
				hook.Run("InsaneStatsEntityUpdated", ent, flags)
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
		local isForCtrlF = net.ReadBool()
		if isForCtrlF then
			local highlights = {}
			local count = net.ReadUInt(8)
			for i=1, count do
				local entIndex = net.ReadUInt(16)
				local pos = net.ReadVector()
				local class = net.ReadString()
				local indicator = net.ReadUInt(2)
				local start = CurTime()
				table.insert(highlights, {
					index = entIndex, pos = pos, class = class, start = start, indicator = indicator
				})
			end

			hook.Run("InsaneStatsWPASS2EntitiesHighlighted", highlights)
		else
			-- the server will send the entity index, but also the entity position, class, health and armor (if any)
			-- since we can't see entities outside our PVS
			local entIndex = net.ReadUInt(16)
			if entIndex == 0 then
				hook.Run("InsaneStatsWPASS2EntityMarked", 0, vector_origin, "", 0, 0, 0, 0, false)
			else
				local pos = net.ReadVector()
				local class = net.ReadString()
				local health = net.ReadDouble()
				local maxHealth = net.ReadDouble()
				local armor = net.ReadDouble()
				local maxArmor = net.ReadDouble()
				local lie = net.ReadBool()
				hook.Run("InsaneStatsWPASS2EntityMarked", entIndex, pos, class, health, maxHealth, armor, maxArmor, lie)
			end
		end
	elseif func == 5 then
		local text = language.GetPhrase(net.ReadString())
		local color = net.ReadColor()

		text = string.gsub(text, "%%([^%%]+)%%", function(bind)
			local keyName = input.LookupBinding(bind)
			if keyName then return "<"..keyName:upper()..">"
			else return bind
			end
		end)
		
		chat.AddText(color, text)
	elseif func == 6 then
		local ent = net.ReadEntity()
		local soldWeapons = {}
		for i=1, net.ReadUInt(16) do
			table.insert(soldWeapons, net.ReadUInt(16))
		end
		local modifierBlacklist = {}
		for i=1, net.ReadUInt(16) do
			modifierBlacklist[net.ReadString()] = true
		end
		InsaneStats:CreateShopMenu(ent, soldWeapons, modifierBlacklist)
	elseif func == 7 then
		if net.ReadBool() then
			-- disabled skill set
			local skills = {}
			for i=1, net.ReadUInt(8) do
				local skillName = InsaneStats:GetSkillName(net.ReadUInt(8))
				skills[skillName] = true
			end
			InsaneStats:SetDisabledSkills(skills)
		else
			-- disabled single skill
			local skillName = InsaneStats:GetSkillName(net.ReadUInt(8))
			local newState = net.ReadBool() or nil
			InsaneStats:DisableSkill(skillName, newState)
		end
	elseif func == 8 then
		local ply = LocalPlayer()
		ply.insaneStats_SkillData = ply.insaneStats_SkillData or {}
		
		if IsValid(ply) then
			for i=1, net.ReadUInt(16) do
				local id = net.ReadUInt(16)
				local state = net.ReadInt(4)
				local stacks = net.ReadDouble()
				local updateTime = net.ReadFloat()
				
				-- decode the id to a named one
				local idStr = InsaneStats:GetSkillName(id)
				
				if idStr then
					ply.insaneStats_SkillData[idStr] = {state = state, stacks = stacks, updateTime = updateTime}
				else
					InsaneStats:Log("Received unknown skill ID %u, is the network toasted?", id)
					InsaneStats:Log("This occured while processing entity %s.", tostring(ply))
				end
			end
		end
	elseif func == 9 then
		local lookPositions = {}
		for i=1, net.ReadUInt(8) do
			table.insert(lookPositions, net.ReadVector())
		end

		hook.Run("InsaneStatsLookPositionsRecieved", lookPositions)
	elseif func == 10 then
		local expiry = net.ReadFloat()
		local color = net.ReadFloat()
		InsaneStats.PointCommanderTimer = {expiry = expiry, color = color}
	elseif func == 11 then
		local toAddChat = {}
		for i=1, net.ReadUInt(16) do
			local isColor = net.ReadBool()
			if isColor then
				table.insert(toAddChat, net.ReadColor())
			else
				table.insert(toAddChat, net.ReadString())
			end
		end

		chat.AddText(unpack(toAddChat))
	elseif func == 12 then
		local ent = net.ReadEntity()
		if IsValid(ent) then
			local class = ent:GetClass()
			if ent:IsWeapon() then
				ent:SetDeploySpeed(net.ReadFloat())
			elseif rechargerClasses[class] then
				ent:SetNoDraw(true)
				ent.insaneStats_NoTargetID = true
			elseif class == "prop_vehicle_jeep" then
				local charge = net.ReadFloat()
				local curTime = net.ReadFloat()
				ent:InsaneStats_SetEntityData("buggy_charge_rate", charge > 0 and 10 or -10)
				ent:InsaneStats_SetEntityData("buggy_charge", math.abs(charge))
				ent:InsaneStats_SetEntityData("buggy_charge_updated", curTime)
			end
		end
	elseif func == 13 then
		local fullDrop = net.ReadBool()
		local ply = LocalPlayer()
		if fullDrop then
			ply.insaneStats_AmmoAdjs = nil
		else
			ply.insaneStats_AmmoAdjs = ply.insaneStats_AmmoAdjs or {}
			for i=1, net.ReadUInt(16) do
				local ammoType = net.ReadUInt(16)
				local ammoAdj = net.ReadDouble()
				ply.insaneStats_AmmoAdjs[ammoType] = ammoAdj
			end
		end
	elseif func == 14 then
		local toSwitchTo = net.ReadEntity()
		if IsValid(toSwitchTo) then
			input.SelectWeapon(toSwitchTo)
		end
	end
end)

hook.Add("NotifyShouldTransmit", "InsaneStatsNet", function(ent, shouldtransmit)
	if ent.insaneStats_NoTargetID and shouldtransmit then
		ent:SetNoDraw(true)
	end
end)