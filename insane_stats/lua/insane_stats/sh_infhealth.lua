InsaneStats:SetDefaultConVarCategory("Infinite Health and Armor")

InsaneStats:RegisterConVar("infhealth_enabled", "insanestats_infhealth_enabled", "1", {
	display = "Infinite Health", desc = "Health and armor limits are removed. NPCs are also able to spawn with armor.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("infhealth_knockback", "insanestats_infhealth_knockback", "1", {
	display = "Custom Knockback", desc = "Enables custom knockback handling, allowing damage to significantly push NPCs. \z
	If disabled, WPASS2 modifiers that affect knockback will become unobtainable.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("infhealth_decimals", "insanestats_infhealth_decimals", "0", {
	display = "Health and Shield Decimals", desc = "Show this number of decimals for health, \z
	shield and their maximums on non-Insane Stats HUDs.",
	type = InsaneStats.FLOAT, min = 0, max = 3
})
InsaneStats:RegisterConVar("infhealth_spawn_invincibility", "insanestats_infhealth_spawn_invincibility", "10", {
	display = "Spawn Invincible Seconds", desc = "Spawned players are given this many seconds of invincibility.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("infhealth_armor_chance", "insanestats_infhealth_armor_chance", "100", {
	display = "Armor Chance", desc = "Chance for NPCs to have armor.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("infhealth_armor_sensible", "insanestats_infhealth_armor_sensible", "1", {
	display = "Sensible NPCs Only", desc = "Only humanoid and Combine entities are able to spawn with armor.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("infhealth_armor_healthcost", "insanestats_infhealth_armor_healthcost", "50", {
	display = "Armor Health % Cost", desc = "NPCs that receive armor lose this % of their max health. \z
	This penalty applies before \"insanestats_infhealth_armor_mul\".",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("infhealth_armor_mul", "insanestats_infhealth_armor_mul", "1", {
	display = "Armor Multiplier", desc = "NPC armor will be this many times their max health.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("infhealth_armor_regen", "insanestats_infhealth_armor_regen", "5", {
	display = "Armor Regen", desc = "% of NPC armor regenerated per second.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("infhealth_armor_regen_delay", "insanestats_infhealth_armor_regen_delay", "20", {
	display = "Armor Regen Delay", desc = "Amount of time before NPCs are able to regenerate their armor.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})

InsaneStats.entityData = {}

AccessorFunc(InsaneStats, "currentDamage", "Damage")

local ENT = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")

function ENT:InsaneStats_SetEntityData(k, v)
	InsaneStats.entityData[self] = InsaneStats.entityData[self] or {}
	InsaneStats.entityData[self][k] = v
end

function ENT:InsaneStats_GetEntityData(k)
	InsaneStats.entityData[self] = InsaneStats.entityData[self] or {}
	return InsaneStats.entityData[self][k]
end

function ENT:InsaneStats_GetHealth()
	return InsaneStats:GetConVarValue("infhealth_enabled") and self:InsaneStats_GetEntityData("health")
	or self:Health()
end
	
function ENT:InsaneStats_GetMaxHealth()
	return InsaneStats:GetConVarValue("infhealth_enabled") and self:InsaneStats_GetEntityData("max_health")
	or self:GetMaxHealth()
end
	
function ENT:InsaneStats_GetArmor()
	return InsaneStats:GetConVarValue("infhealth_enabled") and tonumber(self:InsaneStats_GetEntityData("armor"))
	or self.Armor and tonumber(self:Armor()) or 0
end
	
function ENT:InsaneStats_GetMaxArmor()
	return InsaneStats:GetConVarValue("infhealth_enabled") and tonumber(self:InsaneStats_GetEntityData("max_armor"))
	or self.GetMaxArmor and tonumber(self:GetMaxArmor()) or 0
end

local function OverrideHealth()
	if not ENT.InsaneStats_GetRawHealth then
		ENT.InsaneStats_SetRawHealth = ENT.SetHealth
		ENT.InsaneStats_GetRawHealth = ENT.Health
		ENT.InsaneStats_SetRawMaxHealth = ENT.SetMaxHealth
		ENT.InsaneStats_GetRawMaxHealth = ENT.GetMaxHealth
	end
	
	function ENT:SetHealth(newHealth)
		newHealth = tonumber(newHealth)
		assert(CLIENT or newHealth >= -math.huge, "Something tried to set health on "..tostring(self).." to nan!")
		self:InsaneStats_SetEntityData("health", newHealth)
		if newHealth > 0 then
			self.insaneStats_HealthRoot8 = InsaneStats:CalculateRoot8(newHealth)
		end
		
		if self.InsaneStats_SetRawHealth then
			local scaledHealth = newHealth
			if self:InsaneStats_GetMaxHealth() > 999999999 and self:InsaneStats_GetMaxHealth() < math.huge then
				scaledHealth = scaledHealth / self:InsaneStats_GetMaxHealth() * 999999999
			end
			
			scaledHealth = math.Clamp(math.ceil(scaledHealth), -999999999, 999999999)
			self:InsaneStats_SetRawHealth(scaledHealth)
			self.insaneStats_OldRawHealth = scaledHealth
		end
		
		if SERVER then
			self:InsaneStats_MarkForUpdate(1)
		end
	end
	
	function ENT:Health()
		local actual = self:InsaneStats_GetEntityData("health") or self:InsaneStats_GetRawHealth()
		local int, frac = math.modf(actual)
		local mult = 10 ^ InsaneStats:GetConVarValue("infhealth_decimals")
		frac = math.ceil(frac * mult) / mult
		return int + frac
	end
	
	function ENT:SetMaxHealth(newHealth)
		newHealth = tonumber(newHealth)
		assert(CLIENT or newHealth >= -math.huge, "Something tried to set max health on "..tostring(self).." to nan!")
		self:InsaneStats_SetEntityData("max_health", newHealth)
		if newHealth > 0 then
			self.insaneStats_MaxHealthRoot8 = InsaneStats:CalculateRoot8(newHealth)
		elseif newHealth < 0 then
			InsaneStats:Log("Max health on %s was set to %g, is this intentional?", tostring(self), newHealth)
			debug.Trace()
		end
		
		if self.InsaneStats_SetRawMaxHealth then
			local scaledMaxHealth = math.Clamp(math.ceil(newHealth), -999999999, 999999999)
			self:InsaneStats_SetRawMaxHealth(scaledMaxHealth)
			self.insaneStats_OldRawMaxHealth = scaledMaxHealth
		
			if newHealth > 999999999 then
				local scaledHealth = self:InsaneStats_GetHealth() / newHealth * 999999999
				scaledHealth = math.Clamp(math.ceil(scaledHealth), -999999999, 999999999)
				self:InsaneStats_SetRawHealth(scaledHealth)
				self.insaneStats_OldRawHealth = scaledHealth
			end
		end
		
		if SERVER then
			self:InsaneStats_MarkForUpdate(1)
		end
		if SERVER and self:IsPlayer() and InsaneStats:IsDebugLevel(2) then
			InsaneStats:Log("%s max health set to %g", tostring(self), newHealth)
			debug.Trace()
		end
	end
	
	function ENT:GetMaxHealth()
		local actual = self:InsaneStats_GetEntityData("max_health") or self:InsaneStats_GetRawMaxHealth()
		local int, frac = math.modf(actual)
		local mult = 10 ^ InsaneStats:GetConVarValue("infhealth_decimals")
		frac = math.ceil(frac * mult) / mult
		return int + frac
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
		assert(CLIENT or newArmor >= -math.huge, "Something tried to set armor on "..tostring(self).." to nan!")
		self:InsaneStats_SetEntityData("armor", newArmor)
		if newArmor > 0 then
			self.insaneStats_ArmorRoot8 = InsaneStats:CalculateRoot8(newArmor)
		elseif newArmor < 0 then
			InsaneStats:Log("Armor on %s was set to %g, is this intentional?", tostring(self), newArmor)
			debug.Trace()
		end
		if SERVER then
			self:InsaneStats_MarkForUpdate(1)
		end
	end

	function ENT:Armor()
		local actual = tonumber(self:InsaneStats_GetEntityData("armor")) or 0
		local int, frac = math.modf(actual)
		local mult = 10 ^ InsaneStats:GetConVarValue("infhealth_decimals")
		frac = math.ceil(frac * mult) / mult
		return int + frac
	end

	function ENT:SetMaxArmor(newArmor)
		assert(CLIENT or newArmor >= -math.huge, "Something tried to set max armor on "..tostring(self).." to nan!")
		self:InsaneStats_SetEntityData("max_armor", newArmor)
		if newArmor > 0 then
			self.insaneStats_MaxArmorRoot8 = InsaneStats:CalculateRoot8(newArmor)
		elseif newArmor < 0 then
			InsaneStats:Log("Max armor on %s was set to %g, is this intentional?", tostring(self), newArmor)
			debug.Trace()
		end
		if SERVER then
			self:InsaneStats_MarkForUpdate(1)

			if newArmor > 2147483647 then
				timer.Simple(0, function()
					if (IsValid(self) and self:InsaneStats_GetCurrentArmorAdd() == 1) then
						InsaneStats:Log(
							"Warning! Max armor on %s set to above 2147483647 without using the XP system!",
							tostring(self)
						)
						debug.Trace()
					end
				end)
			end
		end
	end
	
	function ENT:GetMaxArmor()
		local actual = tonumber(self:InsaneStats_GetEntityData("max_armor")) or 0
		local int, frac = math.modf(actual)
		local mult = 10 ^ InsaneStats:GetConVarValue("infhealth_decimals")
		frac = math.ceil(frac * mult) / mult
		return int + frac
	end
	
	function PLAYER:SetArmor(newArmor)
		assert(CLIENT or newArmor >= -math.huge, "Something tried to set armor on "..tostring(self).." to nan!")
		self:InsaneStats_SetEntityData("armor", newArmor)
		if newArmor > 0 then
			self.insaneStats_ArmorRoot8 = InsaneStats:CalculateRoot8(newArmor)
		end
		
		if self.InsaneStats_SetRawArmor then
			local scaledArmor = newArmor
			if self:InsaneStats_GetMaxArmor() > 999999999 and self:InsaneStats_GetMaxArmor() < math.huge then
				scaledArmor = scaledArmor / self:InsaneStats_GetMaxArmor() * 999999999
			end
			
			scaledArmor = math.Clamp(math.ceil(scaledArmor), -999999999, 999999999)
			self:InsaneStats_SetRawArmor(scaledArmor)
			self.insaneStats_OldRawArmor = scaledArmor
		end
		
		if SERVER then
			self:InsaneStats_MarkForUpdate(1)
		end
	end
	
	function PLAYER:Armor()
		local actual = tonumber(self:InsaneStats_GetEntityData("armor")) or self:InsaneStats_GetRawArmor()
		local int, frac = math.modf(actual)
		local mult = 10 ^ InsaneStats:GetConVarValue("infhealth_decimals")
		frac = math.ceil(frac * mult) / mult
		return int + frac
	end
	
	function PLAYER:SetMaxArmor(newArmor)
		assert(CLIENT or newArmor >= -math.huge, "Something tried to set max armor on "..tostring(self).." to nan!")
		self:InsaneStats_SetEntityData("max_armor", newArmor)
		if newArmor > 0 then
			self.insaneStats_MaxArmorRoot8 = InsaneStats:CalculateRoot8(newArmor)
		elseif newArmor < 0 then
			InsaneStats:Log("Max armor on %s was set to %g, is this intentional?", tostring(self), newArmor)
			debug.Trace()
		elseif newArmor == 0 and self:IsPlayer() then
			InsaneStats:Log("Max armor on %s was set to %g, is this intentional?", tostring(self), newArmor)
			debug.Trace()
		end
		
		if self.InsaneStats_SetRawMaxArmor then
			local scaledMaxArmor = math.Clamp(math.ceil(newArmor), -999999999, 999999999)
			self:InsaneStats_SetRawMaxArmor(scaledMaxArmor)
			self.insaneStats_OldRawMaxArmor = scaledMaxArmor
		
			if newArmor > 999999999 then
				local scaledArmor = self:InsaneStats_GetArmor() / newArmor * 999999999
				scaledArmor = math.Clamp(math.ceil(scaledArmor), -999999999, 999999999)
				self:InsaneStats_SetRawArmor(scaledArmor)
				self.insaneStats_OldRawArmor = scaledArmor
			end
		end
		
		if SERVER then
			self:InsaneStats_MarkForUpdate(1)
		end
	end
	
	function PLAYER:GetMaxArmor()
		local actual = tonumber(self:InsaneStats_GetEntityData("max_armor")) or self:InsaneStats_GetRawMaxArmor()
		local int, frac = math.modf(actual)
		local mult = 10 ^ InsaneStats:GetConVarValue("infhealth_decimals")
		frac = math.ceil(frac * mult) / mult
		return int + frac
	end
end

local function DeOverrideArmor()
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

local function OverrideDamage()
	local DMGINFO = FindMetaTable("CTakeDamageInfo")
	if not DMGINFO.InsaneStats_SetRawDamage then
		DMGINFO.InsaneStats_SetRawDamage = DMGINFO.SetDamage
		DMGINFO.InsaneStats_AddRawDamage = DMGINFO.AddDamage
		DMGINFO.InsaneStats_SubtractRawDamage = DMGINFO.SubtractDamage
		DMGINFO.InsaneStats_ScaleRawDamage = DMGINFO.ScaleDamage
		DMGINFO.InsaneStats_GetRawDamage = DMGINFO.GetDamage
	end
	
	function DMGINFO:SetDamage(num)
		InsaneStats:SetDamage(num)
		self:InsaneStats_SetRawDamage(num)

		--[[if not (self:InsaneStats_GetRawDamage() >= -math.huge) then
			self:InsaneStats_SetRawDamage(0)
			error("Something tried to set damage to nan!")
		end]]
	end
	
	function DMGINFO:AddDamage(num)
		InsaneStats:SetDamage(self:GetDamage() + num)
		self:InsaneStats_AddRawDamage(num)
		self:SetMaxDamage(math.min(self:GetMaxDamage() + num, math.huge))

		--[[if not (self:InsaneStats_GetRawDamage() >= -math.huge) then
			self:InsaneStats_SetRawDamage(0)
			error("Something tried to set damage to nan!")
		end]]
	end
	
	function DMGINFO:SubtractDamage(num)
		InsaneStats:SetDamage(self:GetDamage() - num)
		self:InsaneStats_SubtractRawDamage(num)
		self:SetMaxDamage(math.min(self:GetMaxDamage() - num, math.huge))

		--[[if not (self:InsaneStats_GetRawDamage() >= -math.huge) then
			self:InsaneStats_SetRawDamage(0)
			error("Something tried to set damage to nan!")
		end]]
	end
	
	function DMGINFO:ScaleDamage(num)
		local damage = self:GetDamage()
		if damage == 0 then
			-- if num = inf and damage = 0, damage * num = nan, which can cause crashes
			InsaneStats:SetDamage(0)
			self:InsaneStats_ScaleRawDamage(0)
			self:SetMaxDamage(0)
		else
			InsaneStats:SetDamage(damage * num)
			self:InsaneStats_ScaleRawDamage(num)
			self:SetMaxDamage(math.min(self:GetMaxDamage() * num, math.huge))
		end

		--[[if not (self:InsaneStats_GetRawDamage() >= -math.huge) then
			self:InsaneStats_SetRawDamage(0)
			error("Something tried to set damage to nan!")
		end]]
	end
	
	function DMGINFO:GetDamage()
		return InsaneStats:GetDamage() or self:InsaneStats_GetRawDamage()
	end
end

local function DeOverrideDamage()
	local DMGINFO = FindMetaTable("CTakeDamageInfo")
	if DMGINFO.InsaneStats_SetRawDamage then
		DMGINFO.SetDamage = DMGINFO.InsaneStats_SetRawDamage
		DMGINFO.AddDamage = DMGINFO.InsaneStats_AddRawDamage
		DMGINFO.SubtractDamage = DMGINFO.InsaneStats_SubtractRawDamage
		DMGINFO.ScaleDamage = DMGINFO.InsaneStats_ScaleRawDamage
		DMGINFO.GetDamage = DMGINFO.InsaneStats_GetRawDamage
		
		DMGINFO.InsaneStats_SetRawDamage = nil
		DMGINFO.InsaneStats_AddRawDamage = nil
		DMGINFO.InsaneStats_SubtractRawDamage = nil
		DMGINFO.InsaneStats_ScaleRawDamage = nil
		DMGINFO.InsaneStats_GetRawDamage = nil
	end
end

local doHealthOverride = false
hook.Add("Think", "InsaneStatsShared", function()
	if doHealthOverride ~= InsaneStats:GetConVarValue("infhealth_enabled") then
		doHealthOverride = InsaneStats:GetConVarValue("infhealth_enabled")
		if doHealthOverride then
			OverrideHealth()
			OverrideArmor()
			OverrideDamage()
		else
			DeOverrideHealth()
			DeOverrideArmor()
			DeOverrideDamage()
		end
	end
end)

hook.Add("Initialize", "InsaneStatsUnlimitedHealth", function()
	if doHealthOverride ~= InsaneStats:GetConVarValue("infhealth_enabled") then
		doHealthOverride = InsaneStats:GetConVarValue("infhealth_enabled")
		if doHealthOverride then
			OverrideHealth()
			OverrideArmor()
			OverrideDamage()
		else
			DeOverrideHealth()
			DeOverrideArmor()
			DeOverrideDamage()
		end
	end
end)

local statusEffects = {
	-- these status effects are required for maps to not break
	pheonix = {
		name = "Pheonix's Intervention",
		typ = 1,
		img = "condor-emblem",
		apply = SERVER and function(ent, level, duration, attacker)
			ent.insaneStats_PreventOverdamage = true
		end
	},
	undying = {
		name = "Undying",
		typ = 1,
		img = "magic-palm",
		apply = SERVER and function(ent, level, duration, attacker)
			ent.insaneStats_PreventOverdamage = true
		end
	},
	helibomber = {
		name = "Helibomber Damage Up",
		typ = 1,
		img = "hypersonic-melon"
	}
}
hook.Add("InsaneStatsLoadWPASS", "InsaneStatsUnlimitedHealth", function(currentModifiers, currentAttributes, currentStatusEffects)
	table.Merge(currentStatusEffects, statusEffects)
end)