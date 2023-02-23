local ConEnabled = CreateConVar("insanestats_xp_enabled", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
"Enables the experience system.")

local ConNPCDropMul = CreateConVar("insanestats_xp_other_mul", "1", FCVAR_ARCHIVE,
"Multiplier for experience dropped by enemies. The amount of experience dropped is based on max starting health and level.")
local ConPlayerDropMul = CreateConVar("insanestats_xp_player_mul", "0", FCVAR_ARCHIVE,
"Multiplier for experience dropped by players. The amount of experience dropped is based on max starting health and level.")
local ConPlayerLoseMul = CreateConVar("insanestats_xp_player_losepercent", "0", FCVAR_ARCHIVE,
"Experience % lost when a player dies.")
local ConNPCDropGainMul = CreateConVar("insanestats_xp_other_yieldmul", "3", FCVAR_ARCHIVE,
"Multiplier for added experience dropped when an entity kills an NPC.")
local ConPlayerDropGainMul = CreateConVar("insanestats_xp_player_yieldmul", "0", FCVAR_ARCHIVE,
"Multiplier for added experience dropped when an entity kills a player.")
local ConNPCGainMul = CreateConVar("insanestats_xp_other_extrapercent", "100", FCVAR_ARCHIVE,
"Experience % added when NPCs kill other NPCs, scaled by the difference between levels.")
local ConDropAdd = CreateConVar("insanestats_xp_drop_add", "10", FCVAR_ARCHIVE,
"Additional % experience dropped per level.")
local ConDropAddMode = CreateConVar("insanestats_xp_drop_addmode", "1", FCVAR_ARCHIVE,
"If enabled, experience dropped is applied multiplicatively rather than additively.")
local ConDropAddExponent = CreateConVar("insanestats_xp_drop_exponent", "1", FCVAR_ARCHIVE,
"Effective level for experience drops is raised to this power. Use with care.")
local ConDamageCause = CreateConVar("insanestats_xp_inflictor", "1", FCVAR_ARCHIVE,
[[Determines whether the damage inflictor should determine damage scaling, instead of the attacker.
0: Never base damage on damage inflictor
1: When inflictor is a thrown prop
2: When inflictor is a weapon
3: Both
Note that the inflictor will always receive the same XP as the attacker, regardless of circumstance.]])

local mapOrder = {}
local mapNumber = 0
local ConXPScalingCause = CreateConVar("insanestats_xp_other_levelfactor", "0", FCVAR_ARCHIVE,
[[Determines factor for increasing the XP of spawned entities.
0: No Scaling
1: Scale based on average level across players
2: Scale based on geometric average level across players
3: Scale based on highest level across players
4: Scale based on level of activator / nearest player
5: Scale based on maps played since insanestats_xp_other_scaleresetmaps was called]])
local ConXPScalingBase = CreateConVar("insanestats_xp_other_levelstart", "1", FCVAR_ARCHIVE,
"Starting level for spawned entities. A decimal value can be specified, which gives the entity progress to the next level.")
local ConXPScalingDrift = CreateConVar("insanestats_xp_other_leveldrift", "10", FCVAR_ARCHIVE,
"Randomly alters NPC levels by +/- this value.")
local ConXPScalingDriftMode = CreateConVar("insanestats_xp_other_leveldriftmode", "0", FCVAR_ARCHIVE,
"If enabled, the level drift is interpreted as a percentage instead.")
local ConXPScalingDriftHarshness = CreateConVar("insanestats_xp_other_leveldriftharshness", "1", FCVAR_ARCHIVE,
"Reduces the chance for high deviances of level drift. At 0, the drift distribution is uniform (every possible drift amount is equally likely).")
local ConLevelStart = CreateConVar("insanestats_xp_player_levelstart", "1", FCVAR_ARCHIVE,
"Starting level for spawned players. A decimal value can be specified, which gives the entity progress to the next level.")
local ConXPScalingPlayerAdd = CreateConVar("insanestats_xp_other_levelplayers", "5", FCVAR_ARCHIVE,
[[Level increase of spawned entities per extra player in the server.]])
local ConXPScalingPlayerAddMode = CreateConVar("insanestats_xp_other_levelplayersmode", "0", FCVAR_ARCHIVE,
"If enabled, insanestats_xp_other_playercountadd is interpreted as a percentage instead.")
local ConXPScalingMapAdd = CreateConVar("insanestats_xp_other_levelmaps", "50", FCVAR_ARCHIVE,
[[% level increase of spawned entities per map. Only relevant when insanestats_xp_other_scalecause is 4.]])
local ConXPScalingMapAddMode = CreateConVar("insanestats_xp_other_levelmapsmode", "0", FCVAR_ARCHIVE,
"If enabled, insanestats_xp_other_mapcountaddmode is applied multiplicatively rather than additively.")
concommand.Add("insanestats_xp_other_levelmapsreset", function()
	mapOrder = {}
end, nil, "Resets recorded maps.")

local ConReqStart = CreateConVar("insanestats_xp_scale_start", "100", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
"Experience required to reach level 2.")
local ConLevelEnd = CreateConVar("insanestats_xp_scale_maxlevel", "-1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
"Maximum level. At this level, it takes an infinite amount of experience to level up. Set to -1 for no limit.")
local ConReqAdd = CreateConVar("insanestats_xp_scale_add", "20", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
"Additional % experience required per level.")
local ConReqAddMode = CreateConVar("insanestats_xp_scale_addmode", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
"If enabled, experience required is applied multiplicatively rather than additively.")

local ConPlayerHealthAdd = CreateConVar("insanestats_xp_player_health", "10", FCVAR_ARCHIVE,
"% max health gained per level.")
local ConPlayerHealthAddMode = CreateConVar("insanestats_xp_player_healthmode", "1", FCVAR_ARCHIVE,
"If enabled, max health gained is applied multiplicatively rather than additively.")
local ConPlayerArmorAdd = CreateConVar("insanestats_xp_player_armor", "10", FCVAR_ARCHIVE,
"% max armor gained per level.")
local ConPlayerArmorAddMode = CreateConVar("insanestats_xp_player_armormode", "1", FCVAR_ARCHIVE,
"If enabled, max armor gained is applied multiplicatively rather than additively.")

local ConPlayerDamageAdd = CreateConVar("insanestats_xp_player_damage", "10", FCVAR_ARCHIVE,
"% damage dealt gained per level.")
local ConPlayerDamageAddMode = CreateConVar("insanestats_xp_player_damagemode", "1", FCVAR_ARCHIVE,
"If enabled, damage dealt gained is applied multiplicatively rather than additively.")
local ConPlayerDamageResistanceAdd = CreateConVar("insanestats_xp_player_resistance", "0", FCVAR_ARCHIVE,
"% damage resistance gained per level.")
local ConPlayerDamageResistanceAddMode = CreateConVar("insanestats_xp_player_resistancemode", "0", FCVAR_ARCHIVE,
"If enabled, damage resistance gained is applied multiplicatively rather than additively.")

local ConNPCHealthAdd = CreateConVar("insanestats_xp_other_health", "10", FCVAR_ARCHIVE,
"% max health gained per level.")
local ConNPCHealthAddMode = CreateConVar("insanestats_xp_other_healthmode", "1", FCVAR_ARCHIVE,
"If enabled, max health gained is applied multiplicatively rather than additively.")
local ConNPCArmorAdd = CreateConVar("insanestats_xp_other_armor", "10", FCVAR_ARCHIVE,
"% max armor gained per level.")
local ConNPCArmorAddMode = CreateConVar("insanestats_xp_other_armormode", "1", FCVAR_ARCHIVE,
"If enabled, max armor gained is applied multiplicatively rather than additively.")

local ConNPCDamageAdd = CreateConVar("insanestats_xp_other_damage", "10", FCVAR_ARCHIVE,
"% damage dealt gained per level.")
local ConNPCDamageAddMode = CreateConVar("insanestats_xp_other_damagemode", "1", FCVAR_ARCHIVE,
"If enabled, damage dealt gained is applied multiplicatively rather than additively.")
local ConNPCDamageResistanceAdd = CreateConVar("insanestats_xp_other_resistance", "0", FCVAR_ARCHIVE,
"% damage resistance gained per level.")
local ConNPCDamageResistanceAddMode = CreateConVar("insanestats_xp_other_resistancemode", "0", FCVAR_ARCHIVE,
"If enabled, damage resistance gained is applied multiplicatively rather than additively.")

local ConHUDMode = CreateConVar("insanestats_xp_hud_showcumulative", "1", FCVAR_ARCHIVE,
"Shows cumulative XP instead of XP for current level.")

function InsaneStats_ScaleValueToLevel(value, mul, level, multiplicative)
	if math.abs(level) == math.huge and (mul == 0 or value == 0) then
		return value
	elseif multiplicative then
		return value*(1+mul)^(level-1)
	else
		return value*(1+mul*(level-1))
	end
end

local function ScaleTotalValueToLevel(value, mul, level, multiplicative)
	if multiplicative then
		return -value/mul*(1-(mul+1)^(level-1))
	else
		return value*(level-1+(level^2-3*level+2)*mul/2)
	end
end

local function ScaleLevelToTotalValue(value, mul, start, multiplicative)
	if multiplicative then
		-- value = -start/mul*(1-(mul+1)^(level-1))
		-- log(value/start*mul+1)/log((mul+1))+1 = level
		
		return math.log(value/start*mul+1, mul+1)+1
	else
		--[[ value = start*(level-1+(level^2-3*level+2)*mul/2)
		value/start+1 = level+(level^2-3*level+2)*mul/2
		value/start+1 = level+level^2*mul/2-3*level*mul/2+2*mul/2
		value/start+1 = level^2*mul/2+level*(1-mul/3*2)+2*mul/2
		value/start+1 = level^2*(mul/2)+level*(1-mul/3*2)/2+level*(1-mul/3*2)/2+2*mul/2
		
		sqrt(mul/2) * ? = (1-mul/3*2)/2
		? = (1-mul/3*2)/2/sqrt(mul/2)
		
		(1-mul/3*2)^2/2^2/sqrt(mul/2)^2
		= (1-mul/3*4+mul^2*2/3)/4/(mul/2)
		= (1/4-mul/3*4/4+mul^2*2/3/4)/mul*2
		= (1/4-mul/3+mul^2*2/3/4)/mul*2
		= 1/4/mul*2-mul/3/mul*2+mul^2*2/3/4/mul*2
		= 1/2/mul-2/3+mul/3
		= mul/3 - 2/3 + 1/2/mul
		
		value/start+1 = (level*sqrt(mul/2) + (1-mul/3*2)/2/sqrt(mul/2))^2 - mul/3 - 2/3 + 1/2/mul + mul
		value/start+1 - mul*2/3 + 2/3 - 1/2/mul = (level*sqrt(mul/2) + (1-mul/3*2)/2/sqrt(mul/2))^2
		sqrt(value/start+1 - mul*2/3 + 2/3 - 1/2/mul) = level*sqrt(mul/2) + (1-mul/3*2)/2/sqrt(mul/2)
		sqrt(value/start+1 - mul*2/3 + 2/3 - 1/2/mul) - (1-mul/3*2)/2/sqrt(mul/2) = level*sqrt(mul/2)
		sqrt(value/start+1 - mul*2/3 + 2/3 - 1/2/mul)/sqrt(mul/2) - (1-mul/3*2)/2/sqrt(mul/2)/sqrt(mul/2) = level
		level = sqrt((value/start + 1 - mul*2/3 + 2/3 - 1/2/mul)/(mul/2)) - (1-mul/3*2)/2/(mul/2)
		level = sqrt((value/start/mul*2 - mul*2/3/mul*2 + 5/3/mul*2 - 1/2/mul/mul*2)) - (1-mul/3*2)/2/mul*2
		level = sqrt(value/start/mul*2 - 4/3 + 10/3/mul - 1/mul^2) - (1/mul-2/3)
		level = sqrt(value/start/mul*2 - 4/3 + 10/3/mul - 1/mul^2) - 1/mul + 2/3
		
		the above is wrong - need another approach
		
		if c = a*(x-1+(x^2-3*x+2)*b/2)
		then x = (sqrt(a (b - 2)^2 + 8 b c) + sqrt(a) (3 b - 2))/(2 sqrt(a) b) and a b!=0, courtesy of WolframAlpha
		]]
		
		local part = math.sqrt(start*(mul - 2)^2 + 8*mul*value)
		local sqrtStart = math.sqrt(start)
		
		return (part + sqrtStart*(3*mul - 2))/(2*sqrtStart*mul)
	end
end

function InsaneStats_GetXPRequiredToLevel(level)
	if level <= ConLevelEnd:GetFloat() or ConLevelEnd:GetFloat() <= 0 then
		return ScaleTotalValueToLevel(ConReqStart:GetFloat(), ConReqAdd:GetFloat()/100, level, ConReqAddMode:GetBool())
	else return math.huge
	end
end

function InsaneStats_GetXPRequiredToSingleLevel(level)
	local currentXP = InsaneStats_GetXPRequiredToLevel(level)
	local previousXP = InsaneStats_GetXPRequiredToLevel(level-1)
	if currentXP == math.huge then return math.huge
	else return currentXP - previousXP
	end
end

function InsaneStats_GetLevelByXPRequired(xp)
	if xp == math.huge then return math.huge end
	local rawValue = ScaleLevelToTotalValue(xp, ConReqAdd:GetFloat()/100, ConReqStart:GetFloat(), ConReqAddMode:GetBool())
	if ConLevelEnd:GetFloat() > 0 then
		return math.min(rawValue, ConLevelEnd:GetFloat())
	else
		return rawValue
	end
end

local order = {"M", "B", "T", "Q", "Qt", "S", "Sp", "O", "N", "D", "U", "Du", "Te"}
function InsaneStats_FormatNumber(number, data)
	data = data or {}
	local plusStr = data.plus and number > 0 and "+" or ""
	
	local absNumber = math.abs(number)
	if absNumber < 1e6 then
		return plusStr..string.Comma(number)
	elseif absNumber < 1e42 then
		local orderNeeded = math.floor(math.log10(absNumber)/3)-1
		number = number / 1e3^(orderNeeded+1)
		return (string.format("%"..plusStr..".3f %s", number, order[orderNeeded]))
	elseif absNumber < math.huge then
		return (string.format("%"..plusStr..".3e", number))
	elseif number == math.huge then
		return '∞'
	elseif number == -math.huge then
		return '-∞'
	else
		return '?'
	end
end

local ENTITY = FindMetaTable("Entity")

function ENTITY:InsaneStats_GetLevel()
	return self.insaneStats_Level or 1
end

function ENTITY:InsaneStats_GetLevelFraction()
	local currentLevel = self:InsaneStats_GetLevel()
	local prevXP = InsaneStats_GetXPRequiredToLevel(currentLevel)
	local nextXP = InsaneStats_GetXPRequiredToLevel(currentLevel+1)
	if nextXP == math.huge then
		nextXP = 2^(1024-2^-43)
	end
	if self:InsaneStats_GetXP() == math.huge then
		return 1
	else
		return math.Clamp(math.Remap(self:InsaneStats_GetXP(), prevXP, nextXP, 0, 1), 0, 1)
	end
end

function ENTITY:InsaneStats_GetXP()
	return self.insaneStats_XP or 0
end

function ENTITY:InsaneStats_SetXP(xp, dropValue)
	self.insaneStats_XP = xp
	
	if dropValue then
		self.insaneStats_DropXP = dropValue
	end
	
	local newLevel = math.floor(InsaneStats_GetLevelByXPRequired(self.insaneStats_XP))
	if self:InsaneStats_GetLevel() ~= newLevel then
		self:InsaneStats_ApplyLevel(newLevel)
	end
	
	self:InsaneStats_MarkForUpdate(2)
end

function ENTITY:InsaneStats_AddXP(xp, addDropValue)
	return self:InsaneStats_SetXP((self.insaneStats_XP or 0) + xp, (self.insaneStats_DropXP or 0) + addDropValue)
end

function ENTITY:InsaneStats_GetXPToNextLevel()
	return InsaneStats_GetXPRequiredToLevel(self:InsaneStats_GetLevel()+1)
end

local blacklistedClasses = {
	ambient_generic = true,
	weapon_smg1 = true
}
function ENTITY:InsaneStats_ApplyLevel(level)
	if ConEnabled:GetBool() and SERVER and not blacklistedClasses[self:GetClass()] then
		local isPlayer = self:IsPlayer()
		
		local currentHealthFrac = self:InsaneStats_GetFractionalMaxHealth() == 0 and 0 or self:InsaneStats_GetFractionalHealth() / self:InsaneStats_GetFractionalMaxHealth()
		local currentHealthAdd = self.insaneStats_CurrentHealthAdd or 1
		local startingHealth = self:InsaneStats_GetFractionalMaxHealth() / currentHealthAdd
		--print(startingHealth)
		local newHealth
		if isPlayer then
			newHealth = math.floor(InsaneStats_ScaleValueToLevel(startingHealth, ConPlayerHealthAdd:GetFloat()/100, level, ConPlayerHealthAddMode:GetBool()))
		else
			newHealth = math.floor(InsaneStats_ScaleValueToLevel(startingHealth, ConNPCHealthAdd:GetFloat()/100, level, ConNPCHealthAddMode:GetBool()))
		end
		--print(newHealth)
		self:SetMaxHealth(newHealth)
		self:SetHealth(currentHealthFrac * newHealth)
		self.insaneStats_CurrentHealthAdd = newHealth / startingHealth
		
		if newHealth == math.huge then
			self.insaneStats_CurrentHealthAdd = 1
		end
		
		if self.SetMaxArmor then
			local currentArmorFrac = self:InsaneStats_GetFractionalMaxArmor() == 0 and 0 or self:InsaneStats_GetFractionalArmor() / self:InsaneStats_GetFractionalMaxArmor()
			local currentArmorAdd = self.insaneStats_CurrentArmorAdd or 1
			local startingArmor = self:InsaneStats_GetFractionalMaxArmor() / currentArmorAdd
			local newArmor
			if isPlayer then
				newArmor = math.floor(InsaneStats_ScaleValueToLevel(startingArmor, ConPlayerArmorAdd:GetFloat()/100, level, ConPlayerArmorAddMode:GetBool()))
			else
				newArmor = math.floor(InsaneStats_ScaleValueToLevel(startingArmor, ConNPCArmorAdd:GetFloat()/100, level, ConNPCArmorAddMode:GetBool()))
			end
			self:SetMaxArmor(newArmor)
			self:SetArmor(currentArmorFrac * newArmor)
			if newArmor == math.huge then
				self.insaneStats_CurrentArmorAdd = 1
			else
				self.insaneStats_CurrentArmorAdd = newArmor / startingArmor
			end
		end
		
		--[[if isPlayer then
			print(newHealth)
		end]]
	end

	self.insaneStats_Level = level
end

if SERVER then
	local savedPlayerXP = {}
	gameevent.Listen("player_activate")
	
	local function ProcessKillEvent(victim, attacker, inflictor)
		--print(victim, attacker, inflictor, victim.insaneStats_LastAttacker)
		--print(IsValid(attacker), attacker ~= victim, IsValid(victim.insaneStats_LastAttacker))
		if not (IsValid(attacker) and attacker ~= victim) and IsValid(victim.insaneStats_LastAttacker) then
			attacker = victim.insaneStats_LastAttacker
			inflictor = victim.insaneStats_LastAttacker
		end
		--print(victim, attacker, inflictor, victim.insaneStats_LastAttacker)
		if not IsValid(attacker) and IsValid(inflictor) then
			attacker = inflictor
		elseif (not IsValid(inflictor) or inflictor == attacker) and (attacker.GetActiveWeapon and IsValid(attacker:GetActiveWeapon())) then
			inflictor = attacker:GetActiveWeapon()
		end
		
		if IsValid(attacker) and victim ~= attacker then
			local xpMul = victim:IsPlayer() and ConPlayerDropMul:GetFloat() or ConNPCDropMul:GetFloat()
			local currentHealthAdd = victim.insaneStats_CurrentHealthAdd or 1
			local startingHealth = victim:InsaneStats_GetFractionalMaxHealth() / currentHealthAdd
			local startXPToGive = victim.insaneStats_IsDead and 0 or startingHealth * xpMul / 5
			local xpToGive = InsaneStats_ScaleValueToLevel(
				startXPToGive,
				ConDropAdd:GetFloat()/100,
				victim:InsaneStats_GetLevel()^ConDropAddExponent:GetFloat(),
				ConDropAddMode:GetBool()
			)
			--print(xpToGive)
			xpToGive = xpToGive + (victim.insaneStats_DropXP or 0)
			--print(xpToGive)
			
			local data = {
				xp = xpToGive,
				attacker = attacker, inflictor = inflictor, victim = victim,
				receivers = {[attacker] = 1, [inflictor] = 1}
			}
			hook.Run("InsaneStatsScaleXP", data)
			
			xpToGive = data.xp
			local extraXP = 0
			
			local xpDropMul = 1
			if victim:IsPlayer() then
				xpDropMul = ConPlayerDropGainMul:GetFloat()
			else
				xpDropMul = ConNPCDropGainMul:GetFloat()
				
				if xpToGive > 0 then
					-- give xp % based on NPC level
					local toLevelUp = InsaneStats_GetXPRequiredToSingleLevel(victim:InsaneStats_GetLevel())
					extraXP = toLevelUp * ConNPCGainMul:GetFloat()/100
					--print(toLevelUp)
					--attackerXP = attackerXP + extraXP
					--inflictorXP = inflictorXP + extraXP
				end
			end
			
			--[[print(
				xpToGive,
				startXPToGive,
				ConDropAdd:GetFloat()/100,
				victim:InsaneStats_GetLevel(),
				ConDropAddMode:GetBool()
			)]]
			
			--print(xpToGive, xpDropMul)
			
			data.receivers[victim] = nil
			local shouldDropMul = {[attacker] = true, [inflictor] = true}
			for k,v in pairs(shouldDropMul) do
				local wep = k.GetActiveWeapon and k:GetActiveWeapon()
				if IsValid(wep) then
					shouldDropMul[wep] = true
				end
			end
		
			for k,v in pairs(data.receivers) do
				local tempExtraXP = (k:IsPlayer() or k:GetOwner():IsPlayer()) and 0 or extraXP * v
				local tempDropMul = shouldDropMul[k] and xpDropMul or 0
				local xp = xpToGive * v
				--print(k, xp, xpToGive, victim.insaneStats_DropXP, tempExtraXP)
				k:InsaneStats_AddXP(xp+tempExtraXP, xp*tempDropMul)
				
				local wep = k.GetActiveWeapon and k:GetActiveWeapon()
				if IsValid(wep) and not data.receivers[wep] then
					--print(wep, xp, xpToGive, victim.insaneStats_DropXP, tempExtraXP)
					wep:InsaneStats_AddXP(xp+tempExtraXP, xp*tempDropMul)
				end
			end
			
			victim.insaneStats_DropXP = 0
			
			--print(attackerXP, attackerXP*xpDropMul)
		end
		
		victim.insaneStats_IsDead = true
		
		if victim:IsPlayer() then
			-- deduct xp %
			local newXP = victim:InsaneStats_GetXP() * (1-ConPlayerLoseMul:GetFloat()/100)
			victim:InsaneStats_SetXP(newXP, 0)
		end
	end
	
	hook.Add("entity_killed", "InsaneStatsXP", function(data)
		if ConEnabled:GetBool() then
			local victim = Entity(data.entindex_killed or 0)
			local attacker = Entity(data.entindex_attacker or 0)
			local inflictor = Entity(data.entindex_inflictor or 0)
			
			ProcessKillEvent(victim, attacker, inflictor)
		end
	end)
	
	hook.Add("player_activate", "InsaneStatsXP", function(data)
		local ply = Player(data.userid)
		
		if IsValid(ply) then
			local xp = savedPlayerXP[ply:SteamID()]
			
			if xp then
				ply:InsaneStats_SetXP(xp)
			else
				ply:InsaneStats_SetXP(InsaneStats_GetXPRequiredToLevel(ConLevelStart:GetFloat()))
			end
		end
	end)
	
	--[[gameevent.Listen("break_prop")
	hook.Add("break_prop", "InsaneStatsXP", function(data)
		if ConEnabled:GetBool() then
			local victim = Entity(data.entindex or 0)
			local attacker = Player(data.userid or 0)
		end
	end]]
	
	hook.Add("OnNPCKilled", "InsaneStatsXP", function(victim, attacker, inflictor)
		if ConEnabled:GetBool() then
			ProcessKillEvent(victim, attacker, inflictor)
		end
	end)
	
	function InsaneStats_DetermineEntitySpawnedXP(pos)
		-- get base level
		local level = ConXPScalingBase:GetFloat()
		local allPlayers = player.GetAll()
		local playerCount = #allPlayers
		local hasPlayer = false
		
		for k,v in pairs(allPlayers) do
			if v.insaneStats_XP then
				hasPlayer = true break
			end
		end
		
		local typ = ConXPScalingCause:GetInt()
		if typ >= 1 and typ <= 4 then
			if hasPlayer then
				if typ == 1 then
					-- get average level
					local totalLevel = 0
					for k,v in pairs(allPlayers) do
						if v.insaneStats_XP then
							totalLevel = totalLevel + v:InsaneStats_GetLevel()
						end
					end
					
					level = level + totalLevel / playerCount
				elseif typ == 2 then
					-- get geometric average level
					local totalLevel = 1
					local inversePlayerCount = 1/playerCount
					for k,v in pairs(allPlayers) do
						if v.insaneStats_XP then
							totalLevel = totalLevel * v:InsaneStats_GetLevel() ^ inversePlayerCount
						end
					end
					
					level = level + totalLevel
				elseif typ == 3 then
					-- get highest level
					local highestLevel = 1
					for k,v in pairs(allPlayers) do
						highestLevel = math.max(highestLevel, v:InsaneStats_GetLevel())
					end
					
					level = level + highestLevel
				elseif typ == 4 then
					-- get nearest player
					local closestPlayer = game.GetWorld()
					local closestSqrDist = math.huge
					for k,v in pairs(allPlayers) do
						local sqrDist = pos:DistToSqr(v:GetPos())
						if sqrDist < closestSqrDist and v.insaneStats_XP then
							closestPlayer = v
							closestSqrDist = sqrDist
						end
					end
					
					level = level + closestPlayer:InsaneStats_GetLevel()
				end
			else return
			end
		elseif typ == 5 then
			level = InsaneStats_ScaleValueToLevel(level, ConXPScalingMapAdd:GetFloat()/100, mapNumber, ConXPScalingMapAddMode:GetBool())
		end
		
		if ConXPScalingPlayerAddMode:GetBool() then
			level = level * (1+ConXPScalingPlayerAdd:GetFloat()/100 * (playerCount - 1))
		else
			level = level + ConXPScalingPlayerAdd:GetFloat() * (playerCount - 1)
		end
		
		local drift = Lerp(math.random(), -ConXPScalingDrift:GetFloat(), ConXPScalingDrift:GetFloat())
		drift = drift * math.random() ^ ConXPScalingDriftHarshness:GetFloat()
		
		if ConXPScalingDriftMode:GetBool() then
			level = level * (1+drift/100)
		else
			level = level + drift
		end
		
		level = math.max(level, 1)
		
		if ConLevelEnd:GetFloat() > 0 then
			level = math.min(level, ConLevelEnd:GetFloat())
		end
		
		return InsaneStats_GetXPRequiredToLevel(level)
	end
	
	local toUpdateLevelEntities = {}
	hook.Add("InsaneStatsEntityCreated", "InsaneStatsXP", function(ent)
		if ConEnabled:GetBool() and not ent.insaneStats_XP then
			class = ent:GetClass()
			if class == "npc_strider" then
				ent:SetHealth(ent:InsaneStats_GetFractionalHealth()*2.5)
				ent:SetMaxHealth(ent:InsaneStats_GetFractionalMaxHealth()*2.5)
			elseif class == "npc_combinegunship" then
				ent:SetHealth(ent:InsaneStats_GetFractionalHealth()*7.5)
				ent:SetMaxHealth(ent:InsaneStats_GetFractionalMaxHealth()*7.5)
			elseif class == "item_suitcharger" then
				if ent:HasSpawnFlags(8192) then
					ent:Fire("AddOutput","OutRemainingCharge !activator:InsaneStatsSuperSuitChargerPoint::0:-1")
				else
					ent:Fire("AddOutput","OutRemainingCharge !activator:InsaneStatsSuitChargerPoint::0:-1")
				end
			elseif class == "item_healthcharger" then
				ent:Fire("AddOutput","OutRemainingCharge !activator:InsaneStatsHealthChargerPoint::0:-1")
			end
			
			local shouldXP = InsaneStats_DetermineEntitySpawnedXP(ent:GetPos())
			if shouldXP then
				ent:InsaneStats_SetXP(shouldXP)
			else
				table.insert(toUpdateLevelEntities, ent)
			end
		end
	end)
	
	timer.Create("InsaneStatsXP", 0.5, 0, function()
		if next(toUpdateLevelEntities) then
			for k,v in pairs(toUpdateLevelEntities) do
				if IsValid(v) or v == game.GetWorld() then
					if v.insaneStats_XP then
						toUpdateLevelEntities[k] = nil
					else
						local shouldXP = InsaneStats_DetermineEntitySpawnedXP(ent)
						--print(shouldXP)
						if shouldXP then
							v:InsaneStats_SetXP(shouldXP)
							toUpdateLevelEntities[k] = nil
						end
					end
				end
			end
		end
	end)
	
	hook.Add("Initialize", "InsaneStatsXP", function()
		local fileContent = util.JSONToTable(file.Read("insane_stats.txt") or "") or {}
		local currentMap = game.GetMap()
		
		mapOrder = fileContent.maps or {}
		for k,v in pairs(mapOrder) do
			if v == currentMap then
				mapNumber = k break
			end
		end
		
		if mapNumber == 0 then
			mapNumber = table.insert(mapOrder, currentMap)
		end
		
		savedPlayerXP = fileContent.playerXP
	end)
	
	hook.Add("InitPostEntity", "InsaneStatsXP", function()
		if ConEnabled:GetBool() then
			table.insert(toUpdateLevelEntities, game.GetWorld())
		end
	end)
	
	hook.Add("AcceptInput", "InsaneStatsXP", function(ent, input, activator, caller, data)
		if input == "InsaneStatsHealthChargerPoint" then
			ent:SetHealth(ent:InsaneStats_GetFractionalHealth() + ent:InsaneStats_GetFractionalMaxHealth() / 100)
			return true
		elseif input == "InsaneStatsSuitChargerPoint" then
			ent:SetArmor(ent:InsaneStats_GetFractionalArmor() + ent:InsaneStats_GetFractionalMaxArmor() / 100)
			return true
		elseif input == "InsaneStatsSuperSuitChargerPoint" then
			ent:SetArmor(ent:InsaneStats_GetFractionalArmor() + ent:InsaneStats_GetFractionalMaxArmor() / 10)
			if ent:InsaneStats_GetFractionalHealth() < ent:InsaneStats_GetFractionalMaxHealth() then
				ent:SetHealth(math.min(ent:InsaneStats_GetFractionalHealth() + ent:InsaneStats_GetFractionalMaxHealth() / 20, ent:InsaneStats_GetFractionalMaxHealth()))
			end
			return true
		end
	end)
	
	hook.Add("EntityTakeDamage", "InsaneStatsXP", function(vic, dmginfo)
		if dmginfo:GetAttacker() ~= vic and ConEnabled:GetBool() then
			vic.insaneStats_LastAttacker = dmginfo:GetAttacker()
		end
	end)
	
	hook.Add("PostPlayerDeath", "InsaneStatsXP", function(ply)
		if ConEnabled:GetBool() then
			ply.insaneStats_CurrentHealthAdd = 1
			ply.insaneStats_CurrentArmorAdd = 1
		end
	end)
	
	hook.Add("PlayerSpawn", "InsaneStatsXP", function(ply)
		if ConEnabled:GetBool() then
			timer.Simple(0, function()
				ply:InsaneStats_ApplyLevel(ply:InsaneStats_GetLevel())
			end)
		end
	end)
	
	local saveThinkCooldown = 0
	hook.Add("Think", "InsaneStatsXP", function()
		if saveThinkCooldown < RealTime() and ConEnabled:GetBool() then
			local data = {}
			data.maps = mapOrder
			
			for k,v in pairs(player.GetAll()) do
				savedPlayerXP[v:SteamID()] = v:InsaneStats_GetXP()
			end
			data.playerXP = savedPlayerXP
			
			file.Write("insane_stats.txt", util.TableToJSON(data))
			
			saveThinkCooldown = RealTime() + 30
		end
	end)
	
	hook.Add("PostCleanupMap", "InsaneStatsXP", function()
		if ConEnabled:GetBool() then
			game.GetWorld():InsaneStats_SetXP(InsaneStats_DetermineEntitySpawnedXP(game.GetWorld()))
		end
	end)
	
	hook.Add("PlayerCanPickupItem", "InsaneStatsWPASS", function(ply, item)
		hook.Run("InsaneStatsPlayerCanPickupItem", ply, item)
		local class = item:GetClass()
		if class == "item_healthvial" then
			if ply:InsaneStats_GetFractionalHealth() < ply:InsaneStats_GetFractionalMaxHealth() then
				local newHealth = math.min(ply:InsaneStats_GetFractionalMaxHealth(), ply:InsaneStats_GetFractionalHealth()+ply:InsaneStats_GetFractionalMaxHealth()*GetConVar("sk_healthvial"):GetFloat()/100)
				ply:SetHealth(newHealth)
				ply:EmitSound("HealthVial.Touch")
				item:Remove()
			
				net.Start("insane_stats")
				net.WriteUInt(2, 8)
				net.WriteString(class)
				net.Send(ply)
			end
			
			return false
		elseif class == "item_healthkit" then
			if ply:InsaneStats_GetFractionalHealth() < ply:InsaneStats_GetFractionalMaxHealth() then
				local newHealth = math.min(ply:InsaneStats_GetFractionalMaxHealth(), ply:InsaneStats_GetFractionalHealth()+ply:InsaneStats_GetFractionalMaxHealth()*GetConVar("sk_healthkit"):GetFloat()/100)
				ply:SetHealth(newHealth)
				ply:EmitSound("HealthKit.Touch")
				item:Remove()
			
				net.Start("insane_stats")
				net.WriteUInt(2, 8)
				net.WriteString(class)
				net.Send(ply)
			end
			
			return false
		elseif class == "item_battery" then
			-- this is complicated - if the player already has a modified armor battery and the to-be-picked-up battery is also modified
			-- don't auto pickup
			
			local entModified = ply.insaneStats_Modifiers and next(ply.insaneStats_Modifiers)
			local itemModified = item.insaneStats_Modifiers and next(item.insaneStats_Modifiers)
			if ply:InsaneStats_GetFractionalArmor() < ply:InsaneStats_GetFractionalMaxArmor() and not (entModified and itemModified) then
				ply:InsaneStats_EquipBattery(item)
			end
			
			return false
		end
	end)
	
	function InsaneStats_DetermineDamageMul(vic, dmginfo)
		if ConEnabled:GetBool() then
			local attacker = dmginfo:GetAttacker()
			local inflictor = dmginfo:GetInflictor()
			local damageBonus = 1
			
			--[[if IsValid(inflictor) and inflictor:GetClass()=="entityflame" then
				return 1
			end]]
			
			if not IsValid(attacker) and IsValid(inflictor) then
				attacker = inflictor
			elseif (not IsValid(inflictor) or inflictor == attacker) and (attacker.GetActiveWeapon and IsValid(attacker:GetActiveWeapon())) then
				inflictor = attacker:GetActiveWeapon()
			end
			
			if IsValid(inflictor) then
				local inflictorFlags = ConDamageCause:GetInt()
				if bit.band(inflictorFlags, 1) ~= 0 and inflictor:GetClass() == "prop_physics" then
					attacker = inflictor
				elseif bit.band(inflictorFlags, 2) ~= 0 and inflictor:IsWeapon() then
					attacker = inflictor
				end
			end
		
			local level = attacker:InsaneStats_GetLevel()
			if attacker:IsPlayer() then
				damageBonus = InsaneStats_ScaleValueToLevel(damageBonus, ConPlayerDamageAdd:GetFloat()/100, level, ConPlayerDamageAddMode:GetBool())
			else
				damageBonus = InsaneStats_ScaleValueToLevel(damageBonus, ConNPCDamageAdd:GetFloat()/100, level, ConNPCDamageAddMode:GetBool())
			end
		
			if damageBonus < math.huge then
				level = vic:InsaneStats_GetLevel()
				if vic:IsPlayer() then
					damageBonus = damageBonus / InsaneStats_ScaleValueToLevel(1, ConPlayerDamageResistanceAdd:GetFloat()/100, level, ConPlayerDamageResistanceAddMode:GetBool())
				else
					damageBonus = damageBonus / InsaneStats_ScaleValueToLevel(1, ConNPCDamageResistanceAdd:GetFloat()/100, level, ConNPCDamageResistanceAddMode:GetBool())
				end
			end
			
			--print(damageBonus)
			return damageBonus
		else
			return 1
		end
	end
end

if CLIENT then
	surface.CreateFont("InsaneStats_Regular", {
		font = "WillowBody",
		size = 24
	})
	
	surface.CreateFont("InsaneStats_Big", {
		font = "WillowBody",
		size = 36
	})
	
	local oldLevel = -1
	local oldXP = -1
	local oldXPDelayed = -1
	local levelDisplayExpiryTimestamp = 0
	local xpDisplayExpiryTimestamp = 0
	local xpFlashDisplayExpiryTimestamp = 0
	local nextEntityUpdateTimestamp = 0
	local lookEntityInfo = {}
	
	local function UpdateLookEntityInfo(ent)
		local realTime = RealTime()
		
		-- do we know its real class?
		if ent.insaneStats_Class then
			-- set the data for lookEntityInfo
			lookEntityInfo = {
				health = ent:InsaneStats_GetFractionalHealth(),
				maxHealth = ent:InsaneStats_GetFractionalMaxHealth(),
				armor = ent:InsaneStats_GetFractionalArmor(),
				maxArmor = ent:InsaneStats_GetFractionalMaxArmor(),
				level = ent:InsaneStats_GetLevel(),
				decayTimestamp = realTime + 2,
				isPlayer = false,
				teamColor = color_white,
				startingHue = 60,
				ent = ent
			}
			
			-- figure out class color
			if ent:IsPlayer() then
				lookEntityInfo.teamColor = team.GetColor(ent:Team())
				lookEntityInfo.name = ent:Nick()
				lookEntityInfo.isPlayer = true
				
				if LocalPlayer():Team() == ent:Team() then
					lookEntityInfo.startingHue = 120
				else
					lookEntityInfo.startingHue = 0
				end
			else
				local class = ent.insaneStats_Class
				lookEntityInfo.name = language.GetPhrase(class)
				
				if ent:IsNPC() then
					local disposition = ent.insaneStats_Disposition
					
					if disposition == 1 then
						lookEntityInfo.startingHue = 0
					elseif disposition == 3 then
						lookEntityInfo.startingHue = 120
					end
				end
			end
		elseif nextEntityUpdateTimestamp < realTime then
			nextEntityUpdateTimestamp = realTime + 0.25
			
			-- probe the server for status update
			net.Start("insane_stats")
			net.WriteEntity(ent)
			net.SendToServer()
		end
	end
	
	hook.Add("HUDPaint", "InsaneStatsXP", function()
		if ConEnabled:GetBool() then
			local ply = LocalPlayer()
			local barHeight = 12
			local barWidth = ScrW() / 3
			local realTime = RealTime()
			
			local barX = (ScrW() - barWidth)/2
			local barY = ScrH() - barHeight*2
			local maxSaturation = 0.875
			
			local level = ply:InsaneStats_GetLevel()
			local xp = math.floor(ply:InsaneStats_GetXP())
			local levelHue = (level*5+60) % 360
			if ply:InsaneStats_GetXP() == math.huge then
				levelHue = realTime*60 % 360
			end
			local fgColor = HSVToColor(levelHue, maxSaturation, 1)
			local bgColor = HSVToColor(levelHue, maxSaturation, 0.5)
			
			local barFGColor = fgColor
			local barBGColor = bgColor
			
			if level ~= oldLevel then
				if oldLevel > 0 and levelDisplayExpiryTimestamp < realTime then
					levelDisplayExpiryTimestamp = realTime + 5
					surface.PlaySound("ambient/levels/canals/windchime2.wav")
				end
				oldLevel = level
			end
			
			if xp ~= oldXP then
				if oldXP >= 0 then
					xpDisplayExpiryTimestamp = realTime + 1.5
				else
					oldXPDelayed = xp
				end
				
				oldXP = xp
			end
			
			if xpDisplayExpiryTimestamp <= realTime and oldXPDelayed ~= xp then
				oldXPDelayed = xp
				xpFlashDisplayExpiryTimestamp = realTime + 0.5
			end
			
			local levelDisplayExpiryDuration = levelDisplayExpiryTimestamp - realTime
			local xpDisplayExpiryDuration = xpDisplayExpiryTimestamp - realTime
			local xpFlashDisplayExpiryDuration = xpFlashDisplayExpiryTimestamp - realTime
			
			if xpFlashDisplayExpiryDuration > 0 then
				local saturation = Lerp(xpFlashDisplayExpiryDuration*2, maxSaturation, 0)
				barFGColor = HSVToColor(levelHue, saturation, 1)
				barBGColor = HSVToColor(levelHue, saturation, 0.5)
			end
			
			surface.SetDrawColor(0,0,0)
			surface.DrawRect(barX-2, barY-2, barWidth+4, barHeight+4)
			surface.SetDrawColor(barBGColor.r, barBGColor.g, barBGColor.b)
			surface.DrawRect(barX, barY, barWidth, barHeight)
			surface.SetDrawColor(barFGColor.r, barFGColor.g, barFGColor.b)
			surface.DrawRect(barX, barY, barWidth * ply:InsaneStats_GetLevelFraction(), barHeight)
			
			draw.SimpleTextOutlined("Level ".. InsaneStats_FormatNumber(level), "InsaneStats_Regular", barX, barY, fgColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, color_black)
			if levelDisplayExpiryDuration < 0 then
				local previousLevelXP = ConHUDMode:GetBool() and 0 or InsaneStats_GetXPRequiredToLevel(level)
				local xpString = InsaneStats_FormatNumber(xp - previousLevelXP)
				local requiredXp = InsaneStats_FormatNumber(math.ceil(ply:InsaneStats_GetXPToNextLevel() - previousLevelXP))
				local experienceText = xpString .. " / " .. requiredXp
				draw.SimpleTextOutlined(experienceText, "InsaneStats_Regular", barX+barWidth, barY, fgColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
			else
				local color = HSVToColor(levelHue, (math.cos(levelDisplayExpiryDuration*math.pi)+1)/2*maxSaturation, 1)
				draw.SimpleTextOutlined("Level up!", "InsaneStats_Regular", barX+barWidth, barY, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
			end
			
			if xpDisplayExpiryDuration > 0 then
				local textY = ScrH()*0.625
				
				if xpDisplayExpiryDuration <= 0.5 then
					local frac = 1-xpDisplayExpiryDuration*2
					local eased = math.ease.InQuad(frac)
					textY = Lerp(eased, textY, barY)
				end
				
				local outlineLum = 0
				if xpDisplayExpiryDuration > 1 then
					outlineLum = (xpDisplayExpiryDuration*2-2) * 255
				end
				
				local outlineColor = Color(outlineLum, outlineLum, outlineLum)
				local experienceText = InsaneStats_FormatNumber(xp - oldXPDelayed) .. " xp"
				
				draw.SimpleTextOutlined(experienceText, "InsaneStats_Regular", ScrW()/2, textY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, outlineColor)
			end
			
			local lookEntity = ply:GetEyeTrace().Entity
			if IsValid(lookEntity) then
				UpdateLookEntityInfo(lookEntity)
			end
			
			if next(lookEntityInfo) then
				if lookEntityInfo.decayTimestamp <= realTime then
					lookEntityInfo = {}
				else
					local infoW = 2
					local infoY = ScrH()*0.25
					local infoAlpha = math.Clamp(lookEntityInfo.decayTimestamp - realTime, 0, 1) * 255
					local outlineColor = Color(0, 0, 0, infoAlpha)
					
					-- calculate strength of entity based on its level compared to us
					local theirLevel = lookEntityInfo.level
					local theirStrength = InsaneStats_ScaleValueToLevel(1, ConDropAdd:GetFloat()/100, theirLevel, ConDropAddMode:GetBool())
					local ourStrength = InsaneStats_ScaleValueToLevel(1, ConDropAdd:GetFloat()/100, level, ConDropAddMode:GetBool())
					local strengthMul = theirStrength / ourStrength
					if theirStrength == ourStrength then
						strengthMul = 1
					end
					
					-- determine color based on strengthMul
					-- e^-0.5 -> aqua, e^0 -> green, e^0.5 -> yellow, e^1 -> red
					local strengthMod = math.log(strengthMul)
					local levelColorHue = math.Remap(math.Clamp(strengthMod, -0.5, 1), -0.5, 1, 180, 0)
					local levelColor = HSVToColor(levelColorHue, 1, 1)
					levelColor.a = infoAlpha
					
					surface.SetFont("InsaneStats_Big")
					local theirLevelString = InsaneStats_FormatNumber(theirLevel)
					infoW = infoW + surface.GetTextSize(theirLevelString)
					
					-- calculate properties for name display
					local name = lookEntityInfo.name
					surface.SetFont("InsaneStats_Regular")
					local nameWidth = surface.GetTextSize(name)
					
					local teamColor = lookEntityInfo.teamColor
					local nameColorAlpha = teamColor.a * infoAlpha / 255
					local nameColor = Color(teamColor.r, teamColor.g, teamColor.b, nameColorAlpha)
					
					-- calculate properties for health and armor display
					local ourAttack = InsaneStats_ScaleValueToLevel(384, ConPlayerDamageAdd:GetFloat()/100, level, ConPlayerDamageAddMode:GetBool())
					-- maxHealthBarWidth would be a full-width bar at 1
					local maxHealthBarWidthPercent = math.min(lookEntityInfo.maxHealth / ourAttack, 1)
					--[[if lookEntityInfo.maxHealth == 0 and ourAttack == math.huge then
						maxHealthBarWidthPercent = 0
					end]]
					local maxHealthBarWidth = maxHealthBarWidthPercent * 384
					local health = IsValid(lookEntityInfo.ent) and lookEntityInfo.health or 0
					local healthBars = math.max(health / math.min(lookEntityInfo.maxHealth, ourAttack), 0)
					if health == math.huge then
						healthBars = math.huge
					end
					infoW = infoW + math.max(nameWidth, maxHealthBarWidth)
					
					-- now actually draw the text
					local infoX = (ScrW() - infoW) / 2
					--surface.DrawRect(infoX, infoY, 36, 36)
					infoX = infoX + draw.SimpleTextOutlined(theirLevelString, "InsaneStats_Big", infoX, infoY, levelColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, outlineColor)
					infoX = infoX + 2
					if lookEntityInfo.maxHealth > 0 then
						draw.SimpleTextOutlined(name, "InsaneStats_Regular", infoX, infoY, nameColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, outlineColor)
					else
						draw.SimpleTextOutlined(name, "InsaneStats_Regular", infoX, infoY + 18, nameColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, outlineColor)
					end
					
					-- health bar
					if lookEntityInfo.maxHealth > 0 then
						local barX = math.ceil(infoX)
						local barY = infoY + 24
						local barW = maxHealthBarWidth
						local barH = 6
						local currentHueUncycled = math.ceil(healthBars)*30+lookEntityInfo.startingHue-30
						if currentHueUncycled == math.huge then
							currentHueUncycled = realTime * 60
						end
						local currentHealthBarColor = HSVToColor(currentHueUncycled % 360, 0.875, 1)
						local nextHealthBarColor = HSVToColor((currentHueUncycled-30) % 360, 0.875, 1)
						currentHealthBarColor.a = infoAlpha
						if healthBars > 1 then
							draw.SimpleTextOutlined("x"..InsaneStats_FormatNumber(math.ceil(healthBars)), "InsaneStats_Regular", infoX + maxHealthBarWidth, infoY, currentHealthBarColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, outlineColor)
						else
							nextHealthBarColor = Color(127, 127, 127)
						end
						
						local barFrac = healthBars % 1
						if barFrac % 1 == 0 and healthBars > 0 then barFrac = barFrac + 1 end
						local currentHealthBarWidth = healthBars > 0 and math.ceil(barW * barFrac) or -2
						
						surface.SetDrawColor(0,0,0,infoAlpha)
						surface.DrawRect(barX-2, barY-2, barW+4, barH+4)
						surface.SetDrawColor(nextHealthBarColor.r, nextHealthBarColor.g, nextHealthBarColor.b, infoAlpha)
						surface.DrawRect(barX, barY, barW, barH)
						surface.SetDrawColor(currentHealthBarColor.r, currentHealthBarColor.g, currentHealthBarColor.b, infoAlpha)
						surface.DrawRect(barX, barY, currentHealthBarWidth, barH)
						surface.SetDrawColor(0,0,0,infoAlpha)
						surface.DrawLine(barX + currentHealthBarWidth, barY, barX + currentHealthBarWidth, barY + barH)
					end
				end
			end
		end
	end)
	
	hook.Add("InsaneStatsEntityUpdated", "InsaneStatsXP", function(ent, flags)
		if ent == lookEntityInfo.ent then
			UpdateLookEntityInfo(ent)
		end
	end)
	
	--[[hook.Add("InsaneStatsInvalidEntityUpdated", "InsaneStatsXP", function(entIndex, data)
		print(entIndex, lookEntityInfo.entIndex)
		if entIndex == lookEntityInfo.entIndex then
			local realTime = RealTime()
			
			-- update lookEntityInfo with whatever info we get
			lookEntityInfo.health = data.health
			lookEntityInfo.maxHealth = data.maxHealth
			lookEntityInfo.armor = data.armor
			lookEntityInfo.maxArmor = data.maxArmor
			lookEntityInfo.health = data.health
			lookEntityInfo.level = InsaneStats_GetLevelByXPRequired(data.xp)
			lookEntityInfo.decayTimestamp = realTime + 2
		end
	end)]]
end