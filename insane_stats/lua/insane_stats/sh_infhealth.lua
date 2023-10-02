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
InsaneStats:RegisterConVar("infhealth_armor_chance", "insanestats_infhealth_armor_chance", "100", {
	display = "Armor Chance", desc = "Chance for NPCs to have armor.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("infhealth_armor_sensible", "insanestats_infhealth_armor_sensible", "1", {
	display = "Sensible NPCs Only", desc = "Only humanoid and Combine entities are able to spawn with armor.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("infhealth_armor_mul", "insanestats_infhealth_armor_mul", "1", {
	display = "Armor Multiplier", desc = "Multiplier of NPC armor.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("infhealth_armor_regen", "insanestats_infhealth_armor_regen", "5", {
	display = "Armor Regen", desc = "% of NPC armor regenerated per second.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("infhealth_armor_regen_delay", "insanestats_infhealth_armor_regen_delay", "10", {
	display = "Armor Regen Delay", desc = "Amount of time before NPCs are able to regenerate their armor.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})

AccessorFunc(InsaneStats, "currentDamage", "Damage")

local ENT = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")

function ENT:InsaneStats_GetHealth()
	return InsaneStats:GetConVarValue("infhealth_enabled") and self.insaneStats_Health or self:Health()
end
	
function ENT:InsaneStats_GetMaxHealth()
	return InsaneStats:GetConVarValue("infhealth_enabled") and self.insaneStats_MaxHealth or self:GetMaxHealth()
end
	
function ENT:InsaneStats_GetArmor()
	return InsaneStats:GetConVarValue("infhealth_enabled") and tonumber(self.insaneStats_Armor) or self.Armor and tonumber(self:Armor()) or 0
end
	
function ENT:InsaneStats_GetMaxArmor()
	return InsaneStats:GetConVarValue("infhealth_enabled") and tonumber(self.insaneStats_MaxArmor) or self.GetMaxArmor and tonumber(self:GetMaxArmor()) or 0
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
		if not (newHealth >= -math.huge) then -- nan
			error("Something tried to set health on "..tostring(self).." to nan!")
		end
		self.insaneStats_Health = newHealth
		if newHealth > 0 then
			self.insaneStats_HealthRoot8 = newHealth^0.125
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
		
		self:InsaneStats_MarkForUpdate(1)
		--[[if self:IsPlayer() then
			print(newHealth)
			debug.Trace()
		end]]
	end
	
	function ENT:Health()
		return math.ceil(self.insaneStats_Health or self:InsaneStats_GetRawHealth())
	end
	
	function ENT:SetMaxHealth(newHealth)
		newHealth = tonumber(newHealth)
		if not (newHealth >= -math.huge) then -- nan
			error("Something tried to set max health on "..tostring(self).." to nan!")
		end
		self.insaneStats_MaxHealth = newHealth
		if newHealth > 0 then
			self.insaneStats_MaxHealthRoot8 = newHealth^0.125
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
		
		self:InsaneStats_MarkForUpdate(1)
		--[[if SERVER and self:IsPlayer() then
			print(newHealth)
			debug.Trace()
		end]]
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
		if not (newArmor >= -math.huge) then -- nan
			error("Something tried to set armor on "..tostring(self).." to nan!")
		end
		self.insaneStats_Armor = newArmor
		if newArmor > 0 then
			self.insaneStats_ArmorRoot8 = newArmor^0.125
		end
		self:InsaneStats_MarkForUpdate(1)
	end

	function ENT:Armor()
		return math.ceil(self.insaneStats_Armor or 0)
	end

	function ENT:SetMaxArmor(newArmor)
		if not (newArmor >= -math.huge) then -- nan
			error("Something tried to set max armor on "..tostring(self).." to nan!")
		end
		self.insaneStats_MaxArmor = newArmor
		if newArmor > 0 then
			self.insaneStats_MaxArmorRoot8 = newArmor^0.125
		end
		self:InsaneStats_MarkForUpdate(1)
	end
	
	function ENT:GetMaxArmor()
		return math.ceil(self.insaneStats_MaxArmor or 0)
	end
	
	function PLAYER:SetArmor(newArmor)
		if not (newArmor >= -math.huge) then -- nan
			error("Something tried to set armor on "..tostring(self).." to nan!")
		end
		self.insaneStats_Armor = newArmor
		if newArmor > 0 then
			self.insaneStats_ArmorRoot8 = newArmor^0.125
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
		
		self:InsaneStats_MarkForUpdate(1)
	end
	
	function PLAYER:Armor()
		return math.ceil(self.insaneStats_Armor or self:InsaneStats_GetRawArmor())
	end
	
	function PLAYER:SetMaxArmor(newArmor)
		if not (newArmor >= -math.huge) then -- nan
			error("Something tried to set max armor on "..tostring(self).." to nan!")
		end
		self.insaneStats_MaxArmor = newArmor
		if newArmor > 0 then
			self.insaneStats_MaxArmorRoot8 = newArmor^0.125
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
		
		self:InsaneStats_MarkForUpdate(1)
	end
	
	function PLAYER:GetMaxArmor()
		return math.ceil(self.insaneStats_MaxArmor or self:InsaneStats_GetRawMaxArmor())
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
	end
	
	function DMGINFO:AddDamage(num)
		InsaneStats:SetDamage(self:GetDamage() + num)
		self:InsaneStats_AddRawDamage(num)
		self:SetMaxDamage(self:GetMaxDamage() + num)
	end
	
	function DMGINFO:SubtractDamage(num)
		InsaneStats:SetDamage(self:GetDamage() - num)
		self:InsaneStats_SubtractRawDamage(num)
		self:SetMaxDamage(self:GetMaxDamage() - num)
	end
	
	function DMGINFO:ScaleDamage(num)
		InsaneStats:SetDamage(self:GetDamage() * num)
		self:InsaneStats_ScaleRawDamage(num)
		self:SetMaxDamage(self:GetMaxDamage() * num)
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