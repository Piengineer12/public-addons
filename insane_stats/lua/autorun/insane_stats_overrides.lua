--[[NEXT:
status effect + stacks displays
figure out how to change NPC speed
ability to reposition weapon infos

damage numbers
DPS meter
toggle for DPS meter
]]

local ConEnabled = CreateConVar("insanestats_morehealtharmor_enabled", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
[[If enabled, health and armor limits are removed. Entities are also able to have armor.]])
--[=[local ConMaxClipOverrideEnabled = CreateConVar("insanestats_adjustablemaxclip", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
[[If enabled, maximum weapon clips can be altered.]])]=]

local entitiesRequireUpdate = {}
local ENT = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")

function ENT:InsaneStats_GetFractionalHealth()
	return ConEnabled:GetBool() and self.insaneStats_Health or self:Health()
end
	
function ENT:InsaneStats_GetFractionalMaxHealth()
	return ConEnabled:GetBool() and self.insaneStats_MaxHealth or self:GetMaxHealth()
end
	
function ENT:InsaneStats_GetFractionalArmor()
	return ConEnabled:GetBool() and self.insaneStats_Armor or self.Armor and self:Armor() or 0
end
	
function ENT:InsaneStats_GetFractionalMaxArmor()
	return ConEnabled:GetBool() and self.insaneStats_MaxArmor or self.GetMaxArmor and self:GetMaxArmor() or 0
end

function ENT:InsaneStats_MarkForUpdate(flag)
	entitiesRequireUpdate[self] = bit.bor(entitiesRequireUpdate[self] or 0, flag)
end

local function OverrideHealth()
	if not ENT.InsaneStats_GetRawHealth then
		ENT.InsaneStats_SetRawHealth = ENT.SetHealth
		ENT.InsaneStats_GetRawHealth = ENT.Health
		ENT.InsaneStats_SetRawMaxHealth = ENT.SetMaxHealth
		ENT.InsaneStats_GetRawMaxHealth = ENT.GetMaxHealth
	end

	function ENT:SetHealth(newHealth)
		self.insaneStats_Health = newHealth
		
		if self.InsaneStats_SetRawHealth then
			local scaledHealth = newHealth
			if self:InsaneStats_GetFractionalMaxHealth() > 999999999 then
				scaledHealth = scaledHealth / self:InsaneStats_GetFractionalMaxHealth() * 999999999
			end
			
			scaledHealth = math.Clamp(math.ceil(scaledHealth), -999999999, 999999999)
			self:InsaneStats_SetRawHealth(scaledHealth)
			self.insaneStats_OldRawHealth = scaledHealth
		end
		
		self:InsaneStats_MarkForUpdate(1)
	end
	
	function ENT:Health()
		return math.ceil(self.insaneStats_Health or self:InsaneStats_GetRawHealth())
	end
	
	function ENT:SetMaxHealth(newHealth)
		self.insaneStats_MaxHealth = newHealth
		
		if self.InsaneStats_SetRawMaxHealth then
			local scaledMaxHealth = math.Clamp(math.ceil(newHealth), -999999999, 999999999)
			self:InsaneStats_SetRawMaxHealth(scaledMaxHealth)
			self.insaneStats_OldRawMaxHealth = scaledMaxHealth
		
			if newHealth > 999999999 then
				local scaledHealth = self:InsaneStats_GetFractionalHealth() / newHealth * 999999999
				scaledHealth = math.Clamp(math.ceil(scaledHealth), -999999999, 999999999)
				self:InsaneStats_SetRawHealth(scaledHealth)
				self.insaneStats_OldRawHealth = scaledHealth
			end
		end
		
		self:InsaneStats_MarkForUpdate(1)
	end
	
	function ENT:GetMaxHealth()
		return math.ceil(self.insaneStats_MaxHealth or self:InsaneStats_GetRawMaxHealth())
	end
end

local function DeOverrideHealth()
	if ENT.InsaneStats_GetRawHealth then
		ENT.SetHealth = ENT.InsaneStats_SetRawHealth
		ENT.Health = ENT.InsaneStats_GetRawHealth
		ENT.SetMaxHealth = ENT.InsaneStats_SetRawMaxHealth
		ENT.GetMaxHealth = ENT.InsaneStats_GetRawMaxHealth
		
		ENT.InsaneStats_SetRawHealth = nil
		ENT.InsaneStats_GetRawHealth = nil
		ENT.InsaneStats_SetRawMaxHealth = nil
		ENT.InsaneStats_GetRawMaxHealth = nil
	end
end

local function OverrideArmor()
	if not PLAYER.InsaneStats_GetRawArmor then
		PLAYER.InsaneStats_SetRawArmor = PLAYER.SetArmor
		PLAYER.InsaneStats_GetRawArmor = PLAYER.Armor
		PLAYER.InsaneStats_SetRawMaxArmor = PLAYER.SetMaxArmor
		PLAYER.InsaneStats_GetRawMaxArmor = PLAYER.GetMaxArmor
	end
	
	function ENT:SetArmor(newArmor)
		self.insaneStats_Armor = newArmor
		self:InsaneStats_MarkForUpdate(1)
	end

	function ENT:Armor()
		return math.ceil(self.insaneStats_Armor or 0)
	end

	function ENT:SetMaxArmor(newArmor)
		self.insaneStats_MaxArmor = newArmor
		self:InsaneStats_MarkForUpdate(1)
	end
	
	function ENT:GetMaxArmor()
		return math.ceil(self.insaneStats_MaxArmor or 0)
	end
	
	function PLAYER:SetArmor(newArmor)
		self.insaneStats_Armor = newArmor
		
		if self.InsaneStats_SetRawArmor then
			local scaledArmor = newArmor
			if self:InsaneStats_GetFractionalMaxArmor() > 999999999 then
				scaledArmor = scaledArmor / self:InsaneStats_GetFractionalMaxArmor() * 999999999
			end
			
			scaledArmor = math.Clamp(math.ceil(scaledArmor), -999999999, 999999999)
			self:InsaneStats_SetRawArmor(scaledArmor)
			self.insaneStats_OldRawArmor = scaledArmor
		end
		
		self:InsaneStats_MarkForUpdate(1)
	end
	
	function PLAYER:Armor()
		return math.ceil(self.insaneStats_Armor or self:InsaneStats_GetRawArmor())
	end
	
	function PLAYER:SetMaxArmor(newArmor)
		self.insaneStats_MaxArmor = newArmor
		
		if self.InsaneStats_SetRawMaxArmor then
			local scaledMaxArmor = math.Clamp(math.ceil(newArmor), -999999999, 999999999)
			self:InsaneStats_SetRawMaxArmor(scaledMaxArmor)
			self.insaneStats_OldRawMaxArmor = scaledMaxArmor
		
			if newArmor > 999999999 then
				local scaledArmor = self:InsaneStats_GetFractionalArmor() / newArmor * 999999999
				scaledArmor = math.Clamp(math.ceil(scaledArmor), -999999999, 999999999)
				self:InsaneStats_SetRawArmor(scaledArmor)
				self.insaneStats_OldRawArmor = scaledArmor
			end
		end
		
		self:InsaneStats_MarkForUpdate(1)
	end
	
	function PLAYER:GetMaxArmor()
		return math.ceil(self.insaneStats_MaxArmor or self:InsaneStats_GetRawMaxArmor())
	end
end

local function DeOverrideArmor()
	local PLAYER = FindMetaTable("Player")
	
	if PLAYER.InsaneStats_GetRawArmor then
		PLAYER.SetArmor = PLAYER.InsaneStats_SetRawArmor
		PLAYER.Armor = PLAYER.InsaneStats_GetRawArmor
		PLAYER.SetMaxArmor = PLAYER.InsaneStats_SetRawMaxArmor
		PLAYER.GetMaxArmor = PLAYER.InsaneStats_GetRawMaxArmor
		
		PLAYER.InsaneStats_SetRawArmor = nil
		PLAYER.InsaneStats_GetRawArmor = nil
		PLAYER.InsaneStats_SetRawMaxArmor = nil
		PLAYER.InsaneStats_GetRawMaxArmor = nil
		
		ENT.SetArmor = nil
		ENT.GetArmor = nil
		ENT.SetMaxArmor = nil
		ENT.GetMaxArmor = nil
	end
end

--[[local function OverrideMaxClips()
	local WEAPON = FindMetaTable("Weapon")
	
	if not WEAPON.InsaneStats_GetRawMaxClip1 then
		WEAPON.InsaneStats_GetRawMaxClip1 = WEAPON.GetMaxClip1
		WEAPON.InsaneStats_GetRawMaxClip2 = WEAPON.GetMaxClip2
	end
	
	function WEAPON:SetMaxClip1(newClip1)
		self.insaneStats_MaxClip1 = newClip1
		entitiesRequireUpdate[self] = true
	end
	
	function WEAPON:GetMaxClip1()
		return self.insaneStats_MaxClip1 or self:InsaneStats_GetRawMaxClip1()
	end
	
	function WEAPON:SetMaxClip2(newClip2)
		self.insaneStats_MaxClip2 = newClip2
		entitiesRequireUpdate[self] = true
	end
	
	function WEAPON:GetMaxClip2()
		return self.insaneStats_MaxClip2 or self:InsaneStats_GetRawMaxClip2()
	end
end

local function DeOverrideMaxClips()
	local WEAPON = FindMetaTable("Weapon")
	
	if WEAPON.InsaneStats_GetRawMaxClip1 then
		WEAPON.GetMaxClip1 = WEAPON.InsaneStats_GetRawMaxClip1
		WEAPON.GetMaxClip2 = WEAPON.InsaneStats_GetRawMaxClip2
		
		WEAPON.InsaneStats_GetRawMaxClip1 = nil
		WEAPON.InsaneStats_GetRawMaxClip1 = nil
	end
end

hook.Add("InsaneStatsEntityCreated", "InsaneStats", function(ent)
	ent.insaneStats_Health = ent:InsaneStats_GetRawHealth()
	ent.insaneStats_MaxHealth = ent:InsaneStats_GetRawMaxHealth()
end)]]

local function BroadcastEntityUpdates()
	for k,v in pairs(entitiesRequireUpdate) do
		if not (IsValid(k) and k:EntIndex() > 0) then
			entitiesRequireUpdate[k] = nil
		end
	end
	
	net.Start("insane_stats")
	net.WriteUInt(1, 8)
	local count = math.min(table.Count(entitiesRequireUpdate), 255)
	net.WriteUInt(count, 8)
	--print(count)
	
	for k,v in pairs(entitiesRequireUpdate) do
		net.WriteEntity(k)
		net.WriteUInt(v, 8)
		--print(k)
		--print(v)
		
		if bit.band(v, 1) ~= 0 then
			net.WriteDouble(k:InsaneStats_GetFractionalHealth())
			net.WriteDouble(k:InsaneStats_GetFractionalMaxHealth())
			net.WriteDouble(k:InsaneStats_GetFractionalArmor() or 0)
			net.WriteDouble(k:InsaneStats_GetFractionalMaxArmor() or 0)
			--[[net.WriteDouble(k.GetMaxClip1 and k:GetMaxClip1() or 0)
			net.WriteDouble(k.GetMaxClip2 and k:GetMaxClip2() or 0)]]
		end
		
		if bit.band(v, 2) ~= 0 then
			net.WriteDouble(k:InsaneStats_GetXP())
		end
		
		-- bitflag 4 is for entity name, class and disposition, which usually don't change
		
		if bit.band(v, 8) ~= 0 then
			net.WriteDouble(k.insaneStats_BatteryXP or 0)
			net.WriteUInt(k.insaneStats_Tier, 16)
			local modifiers = k.insaneStats_Modifiers
			net.WriteUInt(table.Count(modifiers), 16)
			for k2,v2 in pairs(modifiers) do
				net.WriteString(k2)
				net.WriteUInt(v2-1, 16)
			end
		end
		
		if bit.band(v, 16) ~= 0 then
			local toNetworkStatusEffects = self.insaneStats_StatusEffectsToNetwork or {}
			local data = {}
			
			for k,v in pairs(toNetworkStatusEffects) do
				local statusEffectData = self.insaneStats_StatusEffects[k]
				if statusEffectData then
					table.insert(data, {
						id = InsaneStats_GetStatusEffectID(k),
						expiry = statusEffectData.expiry,
						level = statusEffectData.level
					})
				else
					table.insert(data, {
						id = InsaneStats_GetStatusEffectID(k),
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
		end
		
		entitiesRequireUpdate[k] = nil
		count = count - 1
		if count == 0 then break end
	end
	
	net.Broadcast()
end

local expensiveThinkCooldown = 0
local doHealthOverride = false
local dLibbed = false
--local doMaxClipOverride = false
local entities = {}
InsaneStats_nop = function()end
hook.Add("Think", "InsaneStats", function()
	if doHealthOverride ~= ConEnabled:GetBool() then
		doHealthOverride = ConEnabled:GetBool()
		if doHealthOverride then
			OverrideHealth()
			OverrideArmor()
		else
			DeOverrideHealth()
			DeOverrideArmor()
		end
	end
	
	--[[if doMaxClipOverride ~= ConMaxClipOverrideEnabled:GetBool() then
		doMaxClipOverride = ConMaxClipOverrideEnabled:GetBool()
		if doMaxClipOverride then
			OverrideMaxClips()
		else
			DeOverrideMaxClips()
		end
	end]]
	
	if SERVER then
		for k,v in pairs(entities) do
			if IsValid(v) then
				if doHealthOverride then
					v.insaneStats_OldRawHealth = v.insaneStats_OldRawHealth or v:InsaneStats_GetRawHealth()
					
					if v.insaneStats_OldRawHealth ~= v:InsaneStats_GetRawHealth() then
						local difference = v:InsaneStats_GetRawHealth() - v.insaneStats_OldRawHealth
						--print(difference)
						if difference < 0 and v:IsOnFire() then -- getting set on fire resets the entity's health. Valve, pls fix.
							difference = 0
						end
						v:SetHealth(v:InsaneStats_GetFractionalHealth() + difference)
					end
				end
				
				if v:IsPlayer() then
					if doHealthOverride then
						v.insaneStats_OldRawArmor = v.insaneStats_OldRawArmor or v:InsaneStats_GetRawArmor()
						if v.insaneStats_OldRawArmor ~= v:InsaneStats_GetRawArmor() then
							local difference = v:InsaneStats_GetRawArmor() - v.insaneStats_OldRawArmor
							v:SetArmor(v:InsaneStats_GetFractionalArmor() + difference)
						end
					end
					
					--[=[if doMaxClipOverride then
						local wep = v:GetActiveWeapon()
						if IsValid(wep) then
							wep.insaneStats_OldClip1 = wep.insaneStats_OldClip1 or wep:Clip1()
							if wep.insaneStats_OldClip1 ~= wep:Clip1() then
								if wep.insaneStats_OldClip1 < wep:Clip1() and wep:Clip1() == wep:InsaneStats_GetRawMaxClip1() then
									local clipType = wep:GetPrimaryAmmoType()
									local clipDifference = wep:GetMaxClip1() - wep:InsaneStats_GetRawMaxClip1()
									
									if clipType ~= -1 then
										local currentAmmo = v:GetAmmoCount(clipType)
										clipDifference = math.min(clipDifference, currentAmmo)
										v:SetAmmo(currentAmmo - clipDifference, clipType)
									end
									
									wep:SetClip1(wep:GetMaxClip1())
									if wep:GetClass() == "weapon_crossbow" then
										timer.Simple(20e-6, function()
											wep:SetClip1(wep:GetMaxClip1())
										end)
									end
								end
								
								wep.insaneStats_OldClip1 = wep:Clip1()
							end
							
							wep.insaneStats_OldClip2 = wep.insaneStats_OldClip2 or wep:Clip2()
							if wep.insaneStats_OldClip2 ~= wep:Clip2() then
								if wep.insaneStats_OldClip2 < wep:Clip2() and wep:Clip2() == wep:InsaneStats_GetRawMaxClip2() then
									local clipType = wep:GetSecondaryAmmoType()
									local clipDifference = wep:GetMaxClip2() - wep:InsaneStats_GetRawMaxClip2()
									
									if clipType ~= -1 then
										local currentAmmo = v:GetAmmoCount(clipType)
										clipDifference = math.min(clipDifference, currentAmmo)
										v:SetAmmo(currentAmmo - clipDifference, clipType)
									end
									
									wep:SetClip2(wep:GetMaxClip2())
									if wep:GetClass() == "weapon_crossbow" then
										timer.Simple(20e-6, function()
											wep:SetClip2(wep:GetMaxClip2())
										end)
									end
								end
								
								wep.insaneStats_OldClip2 = wep:Clip2()
							end
						end
					end]=]
				end
				
				hook.Run("InsaneStatsEntityThink", v)
			end
		end
		
		if next(entitiesRequireUpdate) then
			BroadcastEntityUpdates()
		end
		
		if expensiveThinkCooldown < RealTime() then
			expensiveThinkCooldown = RealTime() + 1
			entities = ents.GetAll()
			
			if not DLib then
				local hookTable = hook.GetTable()
				local etdHooks = hookTable.EntityTakeDamage
				local nisetdHooks = hookTable.NonInsaneStatsEntityTakeDamage or {}
				local petdHooks = hookTable.PostEntityTakeDamage
				local nispetdHooks = hookTable.NonInsaneStatsPostEntityTakeDamage or {}
				
				if etdHooks and doHealthOverride then
					for k,v in pairs(etdHooks) do
						if tostring(InsaneStats_nop) ~= tostring(v) and k ~= "InsaneStats" then
							hook.Add("NonInsaneStatsEntityTakeDamage", k, v)
							hook.Add("EntityTakeDamage", k, InsaneStats_nop)
						end
					end
				end
				
				if nisetdHooks then
					for k,v in pairs(nisetdHooks) do
						if not etdHooks[k] then -- it's gone!
							hook.Remove("NonInsaneStatsEntityTakeDamage", k)
						elseif not doHealthOverride then -- put it back!
							hook.Add("EntityTakeDamage", k, v)
							hook.Remove("NonInsaneStatsEntityTakeDamage", k)
						end
					end
				end
				
				if petdHooks and doHealthOverride then
					for k,v in pairs(petdHooks) do
						if tostring(InsaneStats_nop) ~= tostring(v) and k ~= "InsaneStats" then
							hook.Add("NonInsaneStatsPostEntityTakeDamage", k, v)
							hook.Add("PostEntityTakeDamage", k, InsaneStats_nop)
						end
					end
				end
				
				if nispetdHooks then
					for k,v in pairs(nispetdHooks) do
						if not petdHooks[k] then -- it's gone!
							hook.Remove("NonInsaneStatsPostEntityTakeDamage", k)
						elseif not doHealthOverride then -- put it back!
							hook.Add("EntityTakeDamage", k, v)
							hook.Remove("NonInsaneStatsPostEntityTakeDamage", k)
						end
					end
				end
			elseif not dLibbed then
				-- turn the hook overrides off and just use DLib's integrated stuff
				dLibbed = true
				local hookTable = hook.GetTable()
				local nisetdHooks = hookTable.NonInsaneStatsEntityTakeDamage or {}
				local nispetdHooks = hookTable.NonInsaneStatsPostEntityTakeDamage or {}
				
				if nisetdHooks then
					for k,v in pairs(nisetdHooks) do
						-- put it back!
						hook.Add("EntityTakeDamage", k, v)
						hook.Remove("NonInsaneStatsEntityTakeDamage", k)
					end
				end
				
				if nispetdHooks then
					for k,v in pairs(nispetdHooks) do
						-- put it back!
						hook.Add("PostEntityTakeDamage", k, v)
						hook.Remove("NonInsaneStatsPostEntityTakeDamage", k)
					end
				end
				
				hook.Add("EntityTakeDamage", "InsaneStats", hookTable.EntityTakeDamage.InsaneStats, 1)
				hook.Add("PostEntityTakeDamage", "InsaneStats", hookTable.PostEntityTakeDamage.InsaneStats, -1)
			end
		end
	end
end)

if SERVER then
	gameevent.Listen("entity_killed")
	gameevent.Listen("break_prop")
	gameevent.Listen("break_breakable")
	
	hook.Add("EntityTakeDamage", "InsaneStats", function(vic, dmginfo, ...)
		-- run the others first
		-- print(vic, dmginfo:GetAttacker(), dmginfo:GetDamage())
		--print(vic, dmginfo:GetAttacker(), dmginfo:GetInflictor(), dmginfo:GetDamage(), "P")
		local shouldNegate = hook.Run("NonInsaneStatsEntityTakeDamage", vic, dmginfo, ...)
		if shouldNegate then return shouldNegate end
		--print(vic, dmginfo:GetAttacker(), dmginfo:GetInflictor(), dmginfo:GetDamage(), "Q")
		
		--if attacker == vic and not attacker:IsPlayer() then return true end
		--print(attacker, vic)
		--print(dmginfo:GetDamage(), vic:InsaneStats_GetRawHealth(), vic:InsaneStats_GetFractionalHealth())
		local multiplier = InsaneStats_DetermineDamageMul(vic, dmginfo, ...)
		--print(multiplier)
		--print(vic, dmginfo:GetAttacker(), dmginfo:GetInflictor(), dmginfo:GetDamage()*multiplier, "R")
		
		if ConEnabled:GetBool() then
			-- nerf damage to make sure high damage attacks aren't directly lethal
			if vic:InsaneStats_GetFractionalHealth() > 0 then
				multiplier = multiplier * vic:InsaneStats_GetRawHealth() / vic:InsaneStats_GetFractionalHealth()
			end
			vic.insaneStats_OldRawHealth = vic:InsaneStats_GetRawHealth()
			vic.insaneStats_OldRawArmor = vic.InsaneStats_GetRawArmor and vic:InsaneStats_GetRawArmor() or 0
			dmginfo:ScaleDamage(multiplier)
			
			--[[if vic:InsaneStats_GetFractionalArmor() > 0 then
				if vic:InsaneStats_GetFractionalHealth() <= 0 then
					vic:SetArmor(0)
				else
					local armorDamage = math.max(math.min(vic:InsaneStats_GetFractionalArmor(), dmginfo:GetDamage()*multiplier), 0)
					vic:SetArmor(vic:InsaneStats_GetFractionalArmor()-armorDamage)
					if armorDamage == math.huge then
						vic:SetArmor(0)
					end
					
					local addedVelocity = dmginfo:GetDamageForce()
					local physObj = vic:GetPhysicsObject()
					
					if IsValid(physObj) then
						addedVelocity:Div(physObj:GetMass())
					end
					
					vic:SetVelocity(addedVelocity)
					if vic.loco then
						vic.loco:SetVelocity(addedVelocity)
					end
					return true
				end
			end
			
			if vic:InsaneStats_GetFractionalHealth() > 999999999 and multiplier < math.huge then
				local estimatedPercent = dmginfo:GetDamage() * multiplier / vic:InsaneStats_GetFractionalHealth()
				multiplier = estimatedPercent * 999999999
				local addedVelocity = dmginfo:GetDamageForce()
				local physObj = vic:GetPhysicsObject()
				
				if IsValid(physObj) then	
					addedVelocity:Div(physObj:GetMass())
				end
				
				vic:SetVelocity(addedVelocity)
				if vic.loco then
					vic.loco:SetVelocity(addedVelocity)
				end
			end]]
		end
		
		--print(vic, dmginfo:GetDamage(), vic:InsaneStats_GetRawHealth(), vic:InsaneStats_GetFractionalHealth())
		--print(multiplier)
		--[[ multiply dmginfo ONLY IF we have lethal damage
		local predictedHealth = vic:InsaneStats_GetFractionalHealth() - multiplier * dmginfo:GetDamage()
		--print(predictedHealth)
		if predictedHealth <= 0 or multiplier == math.huge then
			dmginfo:ScaleDamage(multiplier)
		end]]
		
		-- reduce damage if there's a discrepancy between real health and Lua health
		--[[if multiplier ~= math.huge then
			dmginfo:ScaleDamage(vic:InsaneStats_GetRawHealth()/vic:InsaneStats_GetFractionalHealth())
		end]]
		
		--print(vic, dmginfo:GetDamage(), vic:InsaneStats_GetRawHealth(), vic:InsaneStats_GetFractionalHealth())
	end)
	
	hook.Add("PostEntityTakeDamage", "InsaneStats", function(vic, dmginfo, notImmune, ...)
		--print(vic, dmginfo:GetDamage(), vic:InsaneStats_GetRawHealth(), vic:InsaneStats_GetFractionalHealth())
		if notImmune and vic:GetClass() ~= "npc_turret_floor" and ConEnabled:GetBool() then
			local healthDamage = dmginfo:GetDamage()
			local armorDamage = 0
			
			if vic:InsaneStats_GetFractionalArmor() > 0 then -- it gets complicated
				armorDamage = math.min(vic:InsaneStats_GetFractionalArmor(), healthDamage*0.8)
				healthDamage = healthDamage - armorDamage
			end
			
			if healthDamage == 0 and armorDamage == 0 then -- calculate damage from HP and armor lost
				healthDamage = vic.insaneStats_OldRawHealth - vic:InsaneStats_GetRawHealth()
				armorDamage = vic.InsaneStats_GetRawArmor and vic.insaneStats_OldRawArmor - vic:InsaneStats_GetRawArmor() or 0
			end
			
			-- reverse damage nerf
			local antiNerf = vic:InsaneStats_GetFractionalHealth() / vic.insaneStats_OldRawHealth
			healthDamage = healthDamage * antiNerf
			armorDamage = armorDamage * antiNerf
			dmginfo:ScaleDamage(antiNerf)
			--[[local oldRawHealth = vic:InsaneStats_GetRawHealth() + dmginfo:GetDamage()
			if oldRawHealth ~= math.huge then
				dmginfo:ScaleDamage(vic:InsaneStats_GetFractionalHealth()/oldRawHealth)
			end]]
			
			--print(notImmune)
			--local multiplier = InsaneStats_DetermineDamageMul(vic, dmginfo, ...)
			--local damage = multiplier * dmginfo:GetDamage()
			vic:SetHealth(vic:InsaneStats_GetFractionalHealth() - healthDamage)
			vic:SetArmor(vic:InsaneStats_GetFractionalArmor() - armorDamage)
		end
		
		dmginfo:ScaleDamage(1/InsaneStats_DetermineDamageMul(vic, dmginfo, ...))
		--print(vic, dmginfo:GetDamage(), vic:InsaneStats_GetRawHealth(), vic:InsaneStats_GetFractionalHealth())
		--[[if notImmune and ConEnabled:GetBool() then
			local damage = dmginfo:GetDamage()
			
			if vic:InsaneStats_GetFractionalMaxHealth() == math.huge and damage < math.huge then
				damage = 0
			elseif vic:InsaneStats_GetFractionalMaxHealth() > 999999999 then
				damage = damage * vic:InsaneStats_GetFractionalMaxHealth() / 999999999
			end
			
			vic:SetHealth(vic:InsaneStats_GetFractionalHealth() - damage)
			
			damage = damage / InsaneStats_DetermineDamageMul(vic, dmginfo)
			dmginfo:SetDamage(damage)
		end]]
		
		hook.Run("NonInsaneStatsPostEntityTakeDamage", vic, dmginfo, notImmune, ...)
	end)
	
	hook.Add("OnEntityCreated", "InsaneStats", function(ent)
		timer.Simple(0, function()
			if (IsValid(ent) and not ent:IsPlayer()) then
				hook.Run("InsaneStatsEntityCreated", ent)
			end
		end)
	end)
end