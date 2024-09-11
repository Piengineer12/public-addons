AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Insane Stats Coin Shop"
ENT.Purpose			= "You can purchase items from the shop."
ENT.Instructions	= "Press the Use key on this thing."
ENT.Category		= "Insane Stats"
ENT.Author			= "Piengineer12"
ENT.Contact			= "https://steamcommunity.com/id/Piengineer12"
ENT.Spawnable		= true
ENT.AdminOnly		= true
ENT.Model			= Model("models/items/ammocrate_rockets.mdl")
ENT.Material		= "insane_stats/ammocrate_coins"

function ENT:SpawnFunction(ply, traceResult, class)
	if traceResult.Hit then
		local ent = ents.Create(class)
		if IsValid(ent) then
			local spawnPos = traceResult.HitPos
			local spawnAng = Angle(0, ply:GetAngles().y - 180, 0)
			spawnAng:SnapTo("y", 45)
			ent:SetPos(spawnPos)
			ent:SetAngles(spawnAng)
			ent:Spawn()
			return ent
		end
	end
end

function ENT:Initialize()
	if SERVER then
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMaterial(self.Material)
		self:SetUseType(SIMPLE_USE)
		
		local physObj = self:GetPhysicsObject()
		if IsValid(physObj) then
			physObj:EnableMotion(false)
		end
	end
end

function ENT:Use(activator, caller)
	if activator:IsPlayer() then
		if not self.insaneStats_WeaponIndexes then
			self.insaneStats_WeaponIndexes = self:SelectSoldWeapons()
		end
		local modifierBlacklist = activator:InsaneStats_GetReforgeBlacklist()
		
		net.Start("insane_stats", true)
		net.WriteUInt(6, 8)
		net.WriteEntity(self)
		net.WriteUInt(#self.insaneStats_WeaponIndexes, 16)
		for i, v in ipairs(self.insaneStats_WeaponIndexes) do
			net.WriteUInt(v, 16)
		end
		net.WriteUInt(table.Count(modifierBlacklist), 16)
		for k, v in pairs(modifierBlacklist) do
			net.WriteString(k)
		end
		net.Send(activator)
	end
end

function ENT:SelectSoldWeapons()
	local choices = {}
	for i=1, #InsaneStats.ShopItemsAutomaticPrice do
		choices[i] = i
	end

	local maxPrice = InsaneStats:GetConVarValue("coins_weapon_max_price")
	if InsaneStats:GetConVarValue("xp_enabled") then
		maxPrice = InsaneStats:ScaleValueToLevelQuadratic(
			maxPrice,
			InsaneStats:GetConVarValue("coins_weapon_max_price_level_add")/100,
			self:InsaneStats_GetLevel(),
			"coins_weapon_max_price_level_add_mode",
			false,
			InsaneStats:GetConVarValue("coins_weapon_max_price_level_add_add")/100
		)
	end

	local selected = {}
	local requiredSelected = math.min(InsaneStats:GetConVarValue("coins_weapon_max"), #choices)
	while #selected < requiredSelected do
		local choice = table.remove(choices, math.random(#choices))
		-- just test *every* entry
		if InsaneStats:GetWeaponCost(choice) <= maxPrice or #choices <= requiredSelected - 1 then
			table.insert(selected, choice)
		end
	end

	table.sort(selected)
	return selected
end