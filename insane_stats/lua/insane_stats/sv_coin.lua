local function SpawnCoins(victim, value)
	local pos = victim:WorldSpaceCenter()
	local coins = ents.FindByClass("insanestats_coin")
	local denomDist = InsaneStats:GetConVarValue("coins_denomination_mul")
	local coinDrop = InsaneStats:GetConVarValue("coins_drop_count")
	local coinMax = InsaneStats:GetConVarValue("coins_drop_max") - coinDrop
	for i=1, coinDrop do
		if #coins > coinMax then
			local plys = player.GetAll()
			local randomPlayer = plys[math.random(#plys)]
			if IsValid(randomPlayer) then
				table.remove(coins, math.random(#coins)):Pickup(randomPlayer)
			end
		end
		if not (value >= 1) then break end
		local ent = ents.Create("insanestats_coin")
		if IsValid(ent) then
			local valueExponent = math.floor(math.log(value, denomDist))
			ent:SetValueExponent(bit.tobit(valueExponent))
			ent:Spawn()
			local spawnPos = pos + vector_up * 6 * ent:GetSizeMultiplier()
			ent:SetPos(spawnPos)
			local physobj = ent:GetPhysicsObject()
			if IsValid(physobj) then
				local initialVel = VectorRand(-128, 128)
				initialVel:Add(physenv.GetGravity() / 4)
				physobj:SetVelocity(initialVel)
			end
			value = value - denomDist^valueExponent
		end
	end
end

hook.Add("InsaneStatsEntityKilledPostXP", "InsaneStatsCoins", function(victim, attacker, inflictor)
	if InsaneStats:GetConVarValue("coins_enabled") then
		local value = 0
		if not victim.insaneStats_IsDead then
			local mul = InsaneStats:GetConVarValue(victim:IsPlayer() and "coins_player_mul" or "coins_other_mul")
			local currentHealthAdd = victim:InsaneStats_GetCurrentHealthAdd()
			local startingHealth = victim:InsaneStats_GetMaxHealth() / currentHealthAdd
			value = startingHealth * math.random() / 16 * mul
			if InsaneStats:GetConVarValue("xp_enabled") then
				value = InsaneStats:ScaleValueToLevelQuadratic(
					value,
					InsaneStats:GetConVarValue("coins_level_add")/100,
					victim:InsaneStats_GetLevel(),
					"coins_level_add_mode",
					false,
					InsaneStats:GetConVarValue("coins_level_add_add")/100
				)
			end
		end
		
		local data = {victim = victim, attacker = attacker, inflictor = inflictor, coins = value}
		hook.Run("InsaneStatsScaleCoins", data)
		value = data.coins

		local extraValue = victim:InsaneStats_GetCoins()
		if victim:IsPlayer() then
			local lost = extraValue * InsaneStats:GetConVarValue("coins_player_lose")/100
			if lost == math.huge then
				victim:InsaneStats_SetCoins(0)
			else
				victim:InsaneStats_SetCoins(extraValue - lost)
			end
			extraValue = lost
		end
		value = value + extraValue
		
		SpawnCoins(victim, value)
	end
end)

hook.Add("InsaneStatsPropBroke", "InsaneStatsCoins", function(victim, attacker)
	local inflictor = attacker.GetActiveWeapon and attacker:GetActiveWeapon() or attacker
	local mul = InsaneStats:GetConVarValue("coins_breakable_mul")
	local currentHealthAdd = victim:InsaneStats_GetCurrentHealthAdd()
	local startingHealth = victim:InsaneStats_GetMaxHealth() / currentHealthAdd
	local value = startingHealth * math.random() / 16 * mul
	if InsaneStats:GetConVarValue("xp_enabled") then
		value = InsaneStats:ScaleValueToLevelQuadratic(
			value,
			InsaneStats:GetConVarValue("coins_level_add")/100,
			victim:InsaneStats_GetLevel(),
			"coins_level_add_mode",
			false,
			InsaneStats:GetConVarValue("coins_level_add_add")/100
		)
	end
	
	local data = {victim = victim, attacker = attacker, inflictor = inflictor, coins = value}
	hook.Run("InsaneStatsScaleCoins", data)
	value = data.coins

	local extraValue = victim:InsaneStats_GetCoins()
	value = value + extraValue

	SpawnCoins(victim, value)
end)

local savedPlayerCoins
hook.Add("InsaneStatsSave", "InsaneStatsCoins", function(data)
	if InsaneStats:GetConVarValue("coins_enabled") and InsaneStats:GetConVarValue("coins_player_save") and savedPlayerCoins then
		for k,v in pairs(player.GetAll()) do
			local steamID = v:SteamID()
			if steamID and v:InsaneStats_GetEntityData("coins_loaded") then
				savedPlayerCoins[steamID] = v:InsaneStats_GetCoins()
			end
		end
		data.playerCoins = savedPlayerCoins
	end
end)

local function ReloadCoins()
	local fileContent = InsaneStats:Load()
	savedPlayerCoins = fileContent.playerCoins or {}
end

ReloadCoins()

hook.Add("InitPostEntity", "InsaneStatsCoins", function()
	ReloadCoins()
end)

hook.Add("PlayerSpawn", "InsaneStatsCoins", function(ply, fromTransition)
	if fromTransition then
		ply:InsaneStats_SetEntityData("coins_loaded", nil)
	end
	
	if not ply:InsaneStats_GetEntityData("coins_loaded") then
		local coins = InsaneStats:GetConVarValue("coins_player_save") and savedPlayerCoins[ply:SteamID()]
		if coins then
			ply:InsaneStats_SetCoins(coins)
		end
		
		ply:InsaneStats_SetEntityData("coins_loaded", true)
	end
end)

hook.Add("AllowPlayerPickup", "InsaneStatsCoins", function(ply, ent)
	if IsValid(ent) and ent:GetCollisionGroup() == COLLISION_GROUP_DEBRIS then
		ent.insaneStats_SuppressCoinDrops = true
	end
end)

local function CheckWeaponsAndItems()
	local missing = {}
	local scriptedEntsList = scripted_ents.GetList()
	local weaponsList = {}
	for i,v in ipairs(weapons.GetList()) do
		weaponsList[v.ClassName] = true
	end
	for i,v in ipairs(InsaneStats.ShopItemsAutomaticPrice) do
		if not (scriptedEntsList[v] or weaponsList[v]) then
			missing[v] = true
		end
	end
	for i,v in ipairs(InsaneStats.ShopItems) do
		local itemName = v[1]
		if not (scriptedEntsList[itemName] or weaponsList[itemName]) then
			missing[itemName] = true
		end
	end
	return missing
end

concommand.Add("insanestats_coins_check", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		local results = CheckWeaponsAndItems()
		if next(results) then
			InsaneStats:Log("The following shop weapons / items are either invalid or are in C++:")
			for k,v in SortedPairs(results) do
				InsaneStats:Log(k)
			end
		end
	end
end, nil, "Checks that all weapons and items sellable by Insane Stats Coin Shops are valid.\
Note that C++ entities will be considered invalid even if they really do exist, due to technical limitations.")