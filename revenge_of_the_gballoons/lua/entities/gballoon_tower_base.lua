AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Anti-gBalloon Tower"
ENT.Category = "#rotgb.category.tower"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "AN ACTUAL TOWER! FINALLY!"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_c17/streetsign004e.mdl"
ENT.UpgradeReference = {}
ENT.UpgradeLimits = {}
ENT.LOSOffset = vector_origin
ENT.BonusFireRate = 1
ENT.ProjectileSize = 0
ENT.FusionPower = 0
ENT.LaserInterval = 0.115

local targetings = 8

local color_red = Color(255, 0, 0)
local color_green = Color(0, 255, 0)
local color_aqua = Color(0, 255, 255)
local color_blue = Color(0, 0, 255)

function ROTGB_GetAllTowers()
	local towertable = {}
	for k,v in pairs(scripted_ents.GetList()) do
		if v.Base == "gballoon_tower_base" then
			table.insert(towertable, v.t)
		end
	end
	table.sort(towertable, function(a,b)
		if a.Cost == b.Cost then
			return a.PrintName < b.PrintName
		else
			return a.Cost < b.Cost
		end
	end)
	return towertable
end

if SERVER then
	util.AddNetworkString("rotgb_openupgrademenu")
	AccessorFunc(ENT, "SpawnerActive", "SpawnerActive", FORCE_BOOL)
end

AccessorFunc(ENT, "Pops", "Pops", FORCE_NUMBER)
AccessorFunc(ENT, "CashGenerated", "CashGenerated", FORCE_NUMBER)

function ENT:SetupDataTables()
	--self:NetworkVar("Bool",0,"SpawnerActive")
	self:NetworkVar("Int",0,"UpgradeStatus")
	-- Path1 + Path2 << 4 + Path3 << 8 + Path4 << 12 + ...
	self:NetworkVar("Int",1,"Targeting")
	--self:NetworkVar("Int",2,"Pops")
	self:NetworkVar("Int",3,"OwnerUserID")
	self:NetworkVar("Float",0,"AbilityCharge")
	--self:NetworkVar("Float",1,"CashGenerated")
	self:NetworkVar("Float",2,"AbilityFraction")
	self:NetworkVar("Entity",0,"TowerOwner")
end

function ENT:SpawnFunction(ply,trace,classname)
	if not trace.Hit then return end
	
	local ent = ents.Create(classname)
	ent:SetPos(trace.HitPos)
	ent:SetTowerOwner(ply)
	ent:Spawn()
	ent:Activate()
	
	return ent
end

ENT.ROTGB_Initialize = function()end

function ENT:Initialize()
	if SERVER then
		self:SetAbilityCharge(0.75)
		self:NextThink(CurTime())
	end
	self:ApplyPerks()
	self:ROTGB_Initialize()
	
	self.LOSOffset = self.LOSOffset or vector_origin
	self.DetectionRadius = self.DetectionRadius * ROTGB_GetConVarValue("rotgb_tower_range_multiplier")
	self.BuffIdentifiers = {}
	
	if SERVER and not IsValid(self:GetTowerOwner()) then
		if IsValid(Player(self:GetOwnerUserID())) then -- duplication always fails to copy entities properly
			self:SetTowerOwner(Player(self:GetOwnerUserID()))
		elseif IsValid(self:GetCreator()) then
			self:SetTowerOwner(self:GetCreator())
		else
			local bestPlayer = NULL
			local bestDistance = math.huge
			for k,v in pairs(player.GetAll()) do
				local distance = v:GetShootPos():DistToSqr(self:GetShootPos())
				if distance < bestDistance then
					bestPlayer = v
					bestDistance = distance
				end
			end
			self:SetTowerOwner(bestPlayer)
		end
	end
	if self:GetTowerOwner():IsPlayer() then
		self:SetOwnerUserID(self:GetTowerOwner():UserID())
	end
	self:SetModel(self.Model)
	
	if SERVER then
		self:EmitSound(string.format("^phx/epicmetal_soft%i.wav", math.random(7)))
		self:PhysicsInit(SOLID_VPHYSICS)
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:Wake()
			physobj:EnableMotion(false)
		end
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		--[[if maxCount>=0 then
			local count = 0
			for k,v in pairs(ents.GetAll()) do
				if v.Base=="gballoon_tower_base" then
					count = count + 1
				end
			end
			if count > maxCount then
				self:SetNoDraw(true)
			end
		end
		if cost>ROTGB_GetCash(self:GetTowerOwner()) then
			self:SetNoDraw(true)
		end]]
		if ROTGB_BalloonsExist() then
			self:SetSpawnerActive(true)
		else
			for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
				if v:GetNextWaveTime() > self:CurTime() then
					self:SetSpawnerActive(true) break
				end
			end
		end
	end
end

ENT.ROTGB_ApplyPerks = ENT.ROTGB_Initialize

function ENT:ApplyPerks()
	if engine.ActiveGamemode() == "rotgb" then
		self:ROTGB_ApplyPerks()
		self.FireRate = self.FireRate * (1+hook.Run("GetSkillAmount", "towerFireRate")/100)
		self.DetectionRadius = self.DetectionRadius * (1+hook.Run("GetSkillAmount", "towerRange")/100)
	end
end

hook.Add("EntityTakeDamage","ROTGB_TOWERS",function(vic,dmginfo)
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	
	if IsValid(attacker) then
		if (IsValid(attacker.rotgb_Owner) and attacker.rotgb_Owner.Base == "gballoon_tower_base" and IsValid(attacker.rotgb_Owner:GetTowerOwner())) then
			local projectile = attacker
			attacker = projectile.rotgb_Owner:GetTowerOwner()
			inflictor = projectile.rotgb_Owner
			dmginfo:SetAttacker(attacker)
			dmginfo:SetInflictor(inflictor)
			
			if projectile.rotgb_DamageType then
				dmginfo:SetDamageType(projectile.rotgb_DamageType)
			elseif projectile.rotgb_UseLaser==2 then
				dmginfo:SetDamageType(projectile.rotgb_NoChildren and DMG_DISSOLVE or DMG_GENERIC)
			end
			
			local projectileClass = projectile:GetClass()
			if inflictor:ValidTargetIgnoreRange(vic) and (projectileClass == "env_laser" or projectileClass == "env_beam") then
				--print(vic, attacker, inflictor, projectile)
				hook.Run("gBalloonDamagedByLaser", vic, attacker, inflictor, projectile, dmginfo:GetDamage())
			end
		end
	end
	
	if IsValid(inflictor) then
		if (IsValid(inflictor.rotgb_Owner) and inflictor.rotgb_Owner.Base == "gballoon_tower_base" and IsValid(inflictor.rotgb_Owner:GetTowerOwner())) then
			inflictor = inflictor.rotgb_Owner
			dmginfo:SetInflictor(inflictor)
		end
	
		if inflictor.Base == "gballoon_tower_base" then
			hook.Run("RotgBTowerDealDamage", vic, dmginfo)
			if not ROTGB_GetConVarValue("rotgb_tower_damage_others") and vic:GetClass()~="gballoon_base" then
				return true
			end
		end
	end
end)

hook.Add("PhysgunPickup", "ROTGB_TOWERS", function(ply, ent)
	if ent.Base == "gballoon_tower_base" and ROTGB_GetConVarValue("rotgb_tower_ignore_physgun") then return false end
end)

hook.Add("PreDrawHalos", "ROTGB_TOWERS", function()
	if not ROTGB_GetConVarValue("rotgb_no_glow") then
		local ours = {}
		local unknown = {}
		local invalidPlacement = {}
		
		for k,v in pairs(ents.GetAll()) do
			if v.Base=="gballoon_tower_base" and player.GetCount() > 1 then
				if v:GetTowerOwner() == LocalPlayer() then
					table.insert(v:GetNWBool("ROTGB_Stun2") and invalidPlacement or ours, v)
				elseif not IsValid(v:GetTowerOwner()) then
					table.insert(unknown, v)
				end
			end
		end
		
		halo.Add(invalidPlacement, color_red)
		halo.Add(ours, color_green)
		halo.Add(unknown, color_white)
	end
end)

function ENT:PreEntityCopy()
	self.rotgb_DuplicatorTimeOffset = CurTime()
end

function ENT:PostEntityPaste(ply,ent,tab)
	self:AddTimePhase(CurTime() - (self.rotgb_DuplicatorTimeOffset or CurTime()))
end

function ENT:AddTimePhase(timeToAdd)
	self.CurTimeOffset = (self.CurTimeOffset or 0) + timeToAdd
	for identifier,info in pairs(self.BuffIdentifiers) do
		if info.expiry then
			info.expiry = info.expiry + timeToAdd
		end
	end
end

function ENT:CurTime()
	return CurTime() - (self.CurTimeOffset or 0)
end

ENT.FireFunction = ENT.ROTGB_Initialize
ENT.ROTGB_AcceptInput = ENT.ROTGB_Initialize

function ENT:AcceptInput(input,activator,caller,data)
	if input:lower()=="stun" then
		self:Stun(data or 1)
	elseif input:lower()=="unstun" then
		self:UnStun()
	else
		self:ROTGB_AcceptInput(input,activator,caller,data)
	end
	-- inputs: Pop, Stun, UnStun
end

function ENT:Stun(tim)
	self.StunUntil = math.max(self:CurTime() + tim,self.StunUntil or 0)
	
	local effdata = EffectData()
	effdata:SetEntity(self)
	effdata:SetMagnitude(tim)
	util.Effect("rotgb_stunned", effdata, true, true)
end

function ENT:UnStun()
	self.StunUntil = 0
end

function ENT:Stun2(reason)
	if not reason then
		ROTGB_EntityLogError(self, "DEPRECATION WARNING: ENT.Stun2 requires an entity argument in the future.", "")
	end
	reason = reason or self
	self.StunUntil2 = istable(self.StunUntil2) and self.StunUntil2 or {}
	if not self.StunUntil2[reason] then
		if table.IsEmpty(self.StunUntil2) then
			self:SetNWBool("ROTGB_Stun2", true)
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			
			local owner = IsValid(self:GetTowerOwner()) and self:GetTowerOwner()
			ROTGB_CauseNotification(ROTGB_NOTIFY_PLACEMENTILLEGAL, ROTGB_NOTIFYTYPE_INFO, owner, {"e", self})
		end
		self.StunUntil2[reason] = true
		
		ROTGB_EntityLog(self, "Tower stunned due to "..tostring(reason)..".", "towers")
	end
end

function ENT:UnStun2(reason)
	if not reason then
		ROTGB_EntityLogError(self, "DEPRECATION WARNING: ENT.UnStun2 requires an entity argument in the future.", "")
	end
	reason = reason or self
	self.StunUntil2 = istable(self.StunUntil2) and self.StunUntil2 or {}
	if self.StunUntil2[reason] then
		self.StunUntil2[reason] = nil
		if table.IsEmpty(self.StunUntil2) then
			self:SetNWBool("ROTGB_Stun2", false)
			self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		
			local owner = IsValid(self:GetTowerOwner()) and self:GetTowerOwner()
			ROTGB_CauseNotification(ROTGB_NOTIFYCHAT_PLACEMENTILLEGALOFF, ROTGB_NOTIFYTYPE_INFO, owner, {"e", self})
		end
		
		ROTGB_EntityLog(self, "Tower unstunned from "..tostring(reason)..".", "towers")
	end
end

function ENT:IsStunned()
	self.StunUntil2 = istable(self.StunUntil2) and self.StunUntil2 or {}
	return self.StunUntil and self.StunUntil>self:CurTime() or next(self.StunUntil2) or false
end

function ENT:CanPerformFusion(path, tier)
	local fusionRequirements = self.UpgradeReference[path].FusionRequirements
	if not fusionRequirements then return true end
	
	fusionRequirements = fusionRequirements[tier]
	if not fusionRequirements then return true end
	
	if fusionRequirements == true then
		-- compute it ourselves
		fusionRequirements = {}
		for i,v in ipairs(self.UpgradeReference) do
			if not v.FusionRequirements then
				fusionRequirements[i] = #v.Funcs
			end
		end
	else
		fusionRequirements = table.Copy(fusionRequirements)
	end
	
	-- get all towers of the same type and owner
	for i,v in ipairs(ents.FindByClass(self:GetClass())) do
		if v:GetTowerOwner() == self:GetTowerOwner() then
			local upgradeStatus = v:GetUpgradeStatus()
			
			-- look through the upgrade paths we need
			for k,v2 in pairs(fusionRequirements) do
				local tier = bit.band(bit.rshift(upgradeStatus, k*4-4), 15)
				if tier >= v2 then
					-- mark requirement as met
					fusionRequirements[k] = nil
				end
			end
			
			if table.IsEmpty(fusionRequirements) then return true end
		end
	end
	
	return false
end

local function FusionFunction(tower)
	local newSellAmount = 0
	for i,v in ipairs(ents.FindByClass(tower:GetClass())) do
		if v:GetTowerOwner() == tower:GetTowerOwner() then
			newSellAmount = newSellAmount + (v.SellAmount or 0)
			if v ~= tower then
				v.SellAmount = 0
				v:Remove()
			end
		end
	end
	
	-- get the total price needed for upgrading to max on each path (for OURSELVES)
	local minimumCostRequired = 0
	for i,v in ipairs(tower.UpgradeReference) do
		minimumCostRequired = minimumCostRequired + ROTGB_ScaleBuyCost(
			tower.Cost or 0,
			tower,
			{type = ROTGB_TOWER_PURCHASE, ply = tower:GetTowerOwner()}
		)
		
		for j,v2 in ipairs(v.Prices or {}) do
			minimumCostRequired = minimumCostRequired + ROTGB_ScaleBuyCost(
				v2,
				tower,
				{type = ROTGB_TOWER_UPGRADE, path = i, tier = j}
			)
		end
		
		local mask = bit.lshift(15, i*4-4)
		local newUpgradeValue = bit.lshift(#v.Funcs, i*4-4)
		tower:SetUpgradeStatus(
			bit.bor(
				bit.band(
					tower:GetUpgradeStatus(),
					bit.bnot(mask) -- remove the bits not specified in mask
				),
				newUpgradeValue -- add in the new bits
			)
		)
	end
	
	tower.FusionPower = math.ceil(math.Clamp(math.sqrt(newSellAmount / minimumCostRequired) * 200 - 199, 1, 999))
	tower.SellAmount = newSellAmount
	tower:EmitSound("mechweapons_huge_pulse_01.wav")
	
	ROTGB_EntityLog(tower, string.format("Upgrade status is now %x with %u Infinity Power!", tower:GetUpgradeStatus(), tower.FusionPower), "towers")
	
	local effdata = EffectData()
	effdata:SetOrigin(tower:WorldSpaceCenter())
	effdata:SetFlags(1)
	util.Effect("rotgb_fusion", effdata, true, true)
end

function ENT:DoTowerFusion()
	if SERVER then
		self:AddDelayedActions(self, "ROTGB_FUSION", 0, function(tower)
			-- here, we only play the effects
			for i,v in ipairs(ents.FindByClass(tower:GetClass())) do
				if v:GetTowerOwner() == tower:GetTowerOwner() and v ~= tower then
					constraint.RemoveAll(v)
					v:SetNotSolid(true)
					v:SetMoveType(MOVETYPE_NONE)
					v:SetNoDraw(true)
					
					local effdata = EffectData()
					effdata:SetEntity(v)
					util.Effect("entity_remove", effdata, true, true)
					if IsValid(ply) then
						ply:SendLua("achievements.Remover()")
					end
					
					effdata = EffectData()
					effdata:SetOrigin(tower:WorldSpaceCenter())
					effdata:SetStart(v:WorldSpaceCenter())
					effdata:SetFlags(0)
					util.Effect("rotgb_fusion", effdata, true, true)
				end
			end
		end, 1, FusionFunction)
	end
end

ENT.ROTGB_Think = ENT.ROTGB_Initialize

hook.Add("gBalloonSpawnerWaveStarted", "ROTGB_TOWER_BASE", function(spawner,cwave)
	for k,v in pairs(ents.GetAll()) do
		if v.Base=="gballoon_tower_base" then
			v:SetSpawnerActive(true)
		end
	end
end)

hook.Add("gBalloonSpawnerWaveEnded", "ROTGB_TOWER_BASE", function(spawner,cwave)
	for k,v in pairs(ents.GetAll()) do
		if v.Base=="gballoon_tower_base" then
			v:SetSpawnerActive(false)
		end
	end
end)

function ENT:Think()
	local trackPlacementCost = false
	
	if not self.SellAmount then
		trackPlacementCost = true
		self.SellAmount = ROTGB_ScaleBuyCost(self.Cost or 0, self, {type = ROTGB_TOWER_PURCHASE, ply = self:GetTowerOwner()})
	end
	if self.OldUpgradeStatus ~= self:GetUpgradeStatus() then
		ROTGB_EntityLog(self, string.format("Upgrade status changed on %s! Old: %x, New: %x", SERVER and "server" or "client", self.OldUpgradeStatus or 0, self:GetUpgradeStatus()), "towers")
		self.OldUpgradeStatus = self.OldUpgradeStatus or 0
		local newUpgradeStatus = self:GetUpgradeStatus()
		--local addAmount = 0
		
		for i,v in ipairs(self.UpgradeReference) do
			local bitpos = (i-1)*4
			local currentTier = bit.band(bit.rshift(self.OldUpgradeStatus,bitpos),15)
			local newTier = bit.band(bit.rshift(newUpgradeStatus,bitpos),15)
			for j=currentTier+1,newTier do
				if (v.Funcs and v.Funcs[j]) then
					ROTGB_EntityLog(self, string.format("Applied upgrade on %s on path %u tier %u!", SERVER and "server" or "client", i, j), "towers")
					v.Funcs[j](self)
					if (v.FusionRequirements and v.FusionRequirements[j]) then
						self:DoTowerFusion()
					end
				end
			end
		end
		
		self.OldUpgradeStatus = newUpgradeStatus
		--self.SellAmount = self.SellAmount + addAmount
	end
	
	if trackPlacementCost then
		hook.Run("RotgBTowerPlaced", self, self.SellAmount)
	end
	
	if SERVER then
		if not self.IsEnabled then
			self.IsEnabled = true
			
			local towerOwner = self:GetTowerOwner()
			if engine.ActiveGamemode() == "rotgb" and towerOwner:IsPlayer() then
				local towerIndex = 0
				local towers = ROTGB_GetAllTowers()
				for k,v in pairs(towers) do
					if v.ClassName == self:GetClass() then
						towerIndex = k break
					end
				end
				if towerOwner:RTG_GetLevel() < towerIndex then
					ROTGB_CauseNotification(ROTGB_NOTIFY_TOWERLEVEL, ROTGB_NOTIFYTYPE_ERROR, towerOwner, {"u8", towerIndex})
					ROTGB_Log("Removed tower "..tostring(self).." placed by "..tostring(towerOwner).." due to level requirement.", "towers")
					return SafeRemoveEntity(self)
				end
			end
			for entry in string.gmatch(ROTGB_GetConVarValue("rotgb_tower_blacklist"), "%S+") do
				if self:GetClass() == entry then
					ROTGB_CauseNotification(ROTGB_NOTIFY_TOWERBLACKLISTED, ROTGB_NOTIFYTYPE_ERROR, towerOwner)
					ROTGB_Log("Removed tower "..tostring(self).." placed by "..tostring(towerOwner).." due to blacklist.", "towers")
					return SafeRemoveEntity(self)
				end
			end
			local chessOnly = ROTGB_GetConVarValue("rotgb_tower_chess_only")
			if chessOnly ~= 0 then
				if chessOnly > 0 and not self.IsChessPiece then
					ROTGB_CauseNotification(ROTGB_NOTIFY_TOWERCHESSONLY, ROTGB_NOTIFYTYPE_ERROR, towerOwner, {"b", true})
					ROTGB_Log("Removed tower "..tostring(self).." placed by "..tostring(towerOwner).." due to not being a chess tower.", "towers")
				elseif chessOnly < 0 and self.IsChessPiece then
					ROTGB_CauseNotification(ROTGB_NOTIFY_TOWERCHESSONLY, ROTGB_NOTIFYTYPE_ERROR, towerOwner, {"b", false})
					ROTGB_Log("Removed tower "..tostring(self).." placed by "..tostring(towerOwner).." due to being a chess tower.", "towers")
				end
			end
			local maxCount = hook.Run("GetMaxRotgBTowerCount") or ROTGB_GetConVarValue("rotgb_tower_maxcount")
			
			local towerCost = self.SellAmount
			if towerCost>ROTGB_GetCash(towerOwner) then
				if towerOwner:IsPlayer() then
					ROTGB_CauseNotification(ROTGB_NOTIFY_TOWERCASH, ROTGB_NOTIFYTYPE_ERROR, towerOwner, {"f", towerCost-ROTGB_GetCash(towerOwner)})
				end
				ROTGB_Log("Removed tower "..tostring(self).." placed by "..tostring(towerOwner).." due to insufficient cash.", "towers")
				self.SellAmount = 0
				return SafeRemoveEntity(self)
			elseif maxCount>=0 then
				local count = 0
				for k,v in pairs(ents.GetAll()) do
					if (v.Base=="gballoon_tower_base" and v:GetTowerOwner() == towerOwner) then
						count = count + 1
					end
				end
				if count > maxCount then
					ROTGB_CauseNotification(ROTGB_NOTIFY_TOWERMAX, ROTGB_NOTIFYTYPE_ERROR, towerOwner)
					ROTGB_Log("Removed tower "..tostring(self).." placed by "..tostring(towerOwner).." due to excess towers.", "towers")
					self.SellAmount = 0
					return SafeRemoveEntity(self)
				end
			end
			ROTGB_RemoveCash(towerCost,towerOwner)
		end
		self:ROTGB_Think()
		local curTime = self:CurTime()
		if not self:IsStunned() then
			self.ExpensiveThinkDelay = self.ExpensiveThinkDelay or curTime
			if self.ExpensiveThinkDelay <= curTime then
				local shouldExpensiveThink = false
				for k,v in pairs(ROTGB_GetBalloons()) do
					if self:ValidTarget(v) then
						shouldExpensiveThink = true break
					end
				end
				if shouldExpensiveThink then
					self.ExpensiveThinkDelay = curTime + math.min(0.5, 1/(self.FireRate or 1))
					self:ExpensiveThink()
				end
			end
			if (self.NextFire or 0) < curTime and (self.DetectedEnemy or self.FireWhenNoEnemies) then
				self:DoFireFunction()
			end
		end
		if self.HasAbility and self:GetAbilityCharge() < 1 and (self:GetSpawnerActive() or ROTGB_GetConVarValue("rotgb_tower_force_charge")) then
			if self.AbilityCooldown == 0 then
				self:SetAbilityCharge(1)
			else
				self:SetAbilityCharge(math.min(1, self:GetAbilityCharge()+FrameTime()/self.AbilityCooldown*ROTGB_GetConVarValue("rotgb_tower_charge_rate")))
			end
		end
		self:BuffThink()
		self:DelayedActionsThink()
		self:StatThink()
		self:PlacementThink()
		self:NextThink(curTime)
		return true
	end
	if CLIENT then
		if self.OldDetectionRadius ~= self.DetectionRadius then
			local renderRadius = math.max(self.DetectionRadius, self:BoundingRadius())
			local minVector = Vector(-renderRadius, -renderRadius, -renderRadius)
			local maxVector = -minVector
			--[[local minVector2, maxVector2 = self:GetRenderBounds()
			
			-- figure out which box points are bigger
			OrderVectors(minVector, minVector2)
			OrderVectors(maxVector, maxVector2)
			-- minVector will now hold the lowest point and maxVector2 the highest]]
			
			self:SetRenderBounds(minVector, maxVector, self.LOSOffset)
			self.OldDetectionRadius = self.DetectionRadius
		end
	end
end

function ENT:PlacementThink()
	if (self.PlacementThinkTicks or 0) > 9 then
		self.PlacementThinkTicks = 0
		
		for k,v in pairs(self.StunUntil2) do
			if (not IsValid(k) or k.GetDisabled and k:GetDisabled()) then
				self:UnStun2(k)
			end
		end
		
		local traceHitWater = self:CheckForWater(self:GetShootPos())
		
		if traceHitWater == tobool(self.IsWaterTower) then
			self:UnStun2(self)
		else
			self:Stun2(self)
		end
	else
		self.PlacementThinkTicks = (self.PlacementThinkTicks or 0) + 1
	end
end

local downDistance = vector_up * -32768
-- this is meant to be a STATIC method, as it is called in rotgb_control
function ENT:CheckForWater(pos)
	self.lastBalloonTrace = self.lastBalloonTrace or {}
	
	-- check for water
	local traceData = {
		filter = self,
		mask = ALL_VISIBLE_CONTENTS,
		output = self.lastBalloonTrace,
		start = pos,
		endpos = pos + downDistance
	}
	util.TraceLine(traceData)
	
	local totalFlags = bit.bor(self.lastBalloonTrace.Contents, util.PointContents(pos))
	return bit.band(totalFlags, MASK_WATER) ~= 0
end

function ENT:DoFireFunction()
	self:ExpensiveThink(true)
	if self.gBalloons[1]--[[IsValid(self.SolicitedgBalloon)]] or self.FireWhenNoEnemies then
		if engine.ActiveGamemode() == "rotgb" then
			local bonusMultiplier = 1
			if hook.Run("GetSkillAmount", "towerEarlyFireRate") ~= 0 then
				local waveFireRateFractionBonus = math.max(math.Remap(hook.Run("GetMaxWaveReached") or 0, 1, 41, 1, 0), 0)
				local mul = 1+hook.Run("GetSkillAmount", "towerEarlyFireRate")/100*waveFireRateFractionBonus
				--print("A", mul)
				bonusMultiplier = bonusMultiplier * mul
			end
			if hook.Run("GetSkillAmount", "towerAbilityD3FireRate") ~= 0 and (self.OtherTowerAbilityActivatedTime or 0) >= self:CurTime() then
				local mul = 1+hook.Run("GetSkillAmount", "towerAbilityD3FireRate")/100
				--print("B", mul)
				bonusMultiplier = bonusMultiplier * mul
			end
			if hook.Run("GetSkillAmount", "towerMoneyFireRate") ~= 0 and self.SellAmount then
				local logMul = self.SellAmount > 0 and math.max(math.log(self.SellAmount), 1) or 1
				local mul = 1+hook.Run("GetSkillAmount", "towerMoneyFireRate")/100*logMul
				--print("C", mul)
				bonusMultiplier = bonusMultiplier * mul
			end
			self.BonusFireRate = bonusMultiplier
		end
		-- FIXME: This differs from the code used in the Turret Factory's turrets, when it really has no reason to.
		local fireDelay = 1/(self.FireRate or 1)/self.BonusFireRate
		local firePowerExpectedMultiplier = 1
		local minFireDelay = self.MaxFireRate and 1/self.MaxFireRate or 0
		if fireDelay < minFireDelay then
			firePowerExpectedMultiplier = minFireDelay/fireDelay
			fireDelay = minFireDelay
		end
		self.NextFire = self:CurTime() + fireDelay
		if not IsValid(self:GetTowerOwner()) then
			local bestPlayer = NULL
			local bestDistance = math.huge
			for k,v in pairs(player.GetAll()) do
				local distance = v:GetShootPos():DistToSqr(self:GetShootPos())
				if distance < bestDistance then
					bestPlayer = v
					bestDistance = distance
				end
			end
			self:SetTowerOwner(bestPlayer)
		end
		local nofire = self:FireFunction(--[[self.SolicitedgBalloon,]]self.gBalloons or {}, firePowerExpectedMultiplier)
		if nofire then
			self.NextFire = 0
		end
	end
	self.ExpensiveThinkDelay = 0
end

function ENT:BuffThink()
	if self:GetSpawnerActive() or ROTGB_GetConVarValue("rotgb_tower_force_charge") then
		local frameTime = FrameTime()
		
		for identifier,info in pairs(self.BuffIdentifiers) do
			if info.expiry then -- DEPRECATED
				info.duration = info.expiry - self:CurTime()
				info.expiry = nil
			end
			if not IsValid(info.tower) or info.duration < 0 then
				if info.unapplyFunc then
					info.unapplyFunc(self)
				end
				self.BuffIdentifiers[identifier] = nil
			else
				info.duration = info.duration - frameTime
			end
		end
	end
end

function ENT:GetShootPos()
	return self:LocalToWorld(self.LOSOffset)
end

function ENT:ApplyBuff(tower, identifier, duration, applyFunc, unapplyFunc)
	ROTGB_EntityLogError(self, "DEPRECATION WARNING: ENT.ApplyBuff will be removed in the future. Use ENT.AddDelayedActions instead.", "")
	identifier = identifier or #self.BuffIdentifiers+1
	
	local buffInfo = self:GetBuff(identifier)
	
	if buffInfo then
		buffInfo.duration = math.max(buffInfo.duration, duration)
	else
		self.BuffIdentifiers[identifier] = {tower = tower, duration = duration or math.huge, unapplyFunc = unapplyFunc}
		if applyFunc then
			applyFunc(self)
		end
	end
end

function ENT:TowerBuffed(identifier)
	ROTGB_EntityLogError(self, "DEPRECATION WARNING: ENT.TowerBuffed and ENT.TowerBuffedBy will be removed in the future. Use tower delayed actions instead.", "")
	debug.Trace()
	return IsValid(self.BuffIdentifiers[identifier])
end

function ENT:TowerBuffedBy(identifier)
	return self:TowerBuffed(identifier) and self.BuffIdentifiers[identifier]
end

function ENT:GetBuff(identifier)
	ROTGB_EntityLogError(self, "DEPRECATION WARNING: ENT.GetBuff will be removed in the future. Use tower delayed actions instead.", "")
	return self.BuffIdentifiers[identifier]
end

function ENT:AddDelayedActions(tower, identifier, ...)
	self.DelayedActions = self.DelayedActions or {}
	identifier = identifier or #self.DelayedActions+1
	
	local info = self:GetDelayedActions(identifier)
	if info then
		info.elapsed = 0
		ROTGB_EntityLog(self, "Refreshed delayed actions \""..identifier.."\"!", "towers")
	else
		local args = {...}
		local actions = {}
		local thinkFunction = nil
		
		for i = 1, #args, 2 do
			local duration = args[i]
			if duration < 0 then
				thinkFunction = args[i+1]
			else
				table.insert(actions, {duration, args[i+1]})
			end
		end
		
		self.DelayedActions[identifier] = {
			tower = tower,
			elapsed = 0,
			actions = actions,
			think = thinkFunction
		}
		
		ROTGB_EntityLog(self, "Applied delayed actions \""..identifier.."\"!", "towers")
	end
end

function ENT:DelayedActionsThink()
	if self:GetSpawnerActive() or ROTGB_GetConVarValue("rotgb_tower_force_charge") then
		local frameTime = FrameTime()
		
		self.DelayedActions = self.DelayedActions or {}
		for identifier,info in pairs(self.DelayedActions) do
			info.elapsed = info.elapsed + frameTime
			local tower = info.tower
			
			if info.think then
				info.think(self)
			end
			
			local index = 1
			while info.actions[index] do
				local action = info.actions[index]
				
				if action[1] <= info.elapsed or not IsValid(tower) then
					if action[2] then
						action[2](self)
					end
					table.remove(info.actions, index)
				else
					index = index + 1
				end
			end
			
			if table.IsEmpty(info.actions) then
				self.DelayedActions[identifier] = nil
			end
		end
	end
end

function ENT:GetDelayedActions(identifier)
	self.DelayedActions = self.DelayedActions or {}
	return self.DelayedActions[identifier]
end

function ENT:ValidTarget(v)
	return self:ValidTargetIgnoreRange(v) and (v:LocalToWorld(v:OBBCenter()):DistToSqr(self:GetShootPos()) <= self.DetectionRadius * self.DetectionRadius or self.InfiniteRange or self.InfiniteRange2)
end

function ENT:ValidTargetIgnoreRange(v)
	return (IsValid(v) and v:GetClass()=="gballoon_base" and not v:GetBalloonProperty("BalloonVoid")
	and (not v:GetBalloonProperty("BalloonHidden") or self.SeeCamo or v:HasRotgBStatusEffect("unhide")))
end

function ENT:CreateDamage(damage, damageType)
	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(self:GetTowerOwner())
	dmginfo:SetInflictor(self)
	if damage then
		dmginfo:SetDamage(damage)
	end
	if damageType then
		dmginfo:SetDamageType(damageType)
	end
	dmginfo:SetReportedPosition(self:GetShootPos())
	return dmginfo
end

function ENT:DealDamage(ent, damage, damageType)
	local dmginfo = damage
	
	if isnumber(dmginfo) then
		dmginfo = DamageInfo()
		dmginfo:SetAttacker(self:GetTowerOwner())
		dmginfo:SetInflictor(self)
		dmginfo:SetDamage(damage)
		dmginfo:SetDamageType(damageType or DMG_GENERIC)
		dmginfo:SetReportedPosition(self:GetShootPos())
	end
	
	dmginfo:SetDamagePosition(ent:WorldSpaceCenter())
	ent:TakeDamageInfo(dmginfo)
end

function ENT:BulletAttack(ent, damage, data)
	-- data fields: callback, spread, amount, tracerDivide, ammoType, tracer, damageType,
	-- startPos, inflictor
	local shooter = data.inflictor or self
	local startPos = data.startPos or self:GetShootPos()
	local direction = ent:WorldSpaceCenter()-startPos
	local callback = data.callback
	
	if data.damageType then
		callback = function(attacker, trace, dmginfo)
			dmginfo:SetDamageType(data.damageType)
			if data.callback then
				data.callback(attacker, trace, dmginfo)
			end
		end
	end
	
	local bullet = {
		Src = startPos,
		Dir = direction,
		Spread = data.spread,
		HullSize = 1,
		Distance = self.DetectionRadius,
		
		Damage = damage,
		Num = data.amount,
		
		Tracer = data.tracerDiv,
		TracerName = data.tracer or "Tracer",
		
		Attacker = self:GetTowerOwner(),
		IgnoreEntity = shooter,
		Callback = callback,
	}
	shooter:FireBullets(bullet)
end

function ENT:LaserAttack(ent, damage, width, data)
	-- data fields: noise, color, texture, scroll, sparksStart,
	-- sparks, decal, fadeIn, fadeOut, shrink, damageType, laser
	
	local hookData = {
		startPos = data.startPos or self:GetShootPos(),
		color = data.color or color_white,
		endPos = ent:WorldSpaceCenter(),
		damage = damage,
		width = width
	}
	table.Merge(hookData, data)
	hook.Run("RotgBTowerFireLaser", self, ent, hookData)
	
	local startPos = self.rotgb_StartPos
	local endPos = ent.rotgb_EndPos
	
	if IsValid(hookData.startEntity) then
		startPos = hookData.startEntity
		startPos:SetName("ROTGB_LASERSTART_"..startPos:GetCreationID())
	elseif not IsValid(self.rotgb_StartPos) then
		startPos = ents.Create("info_target")
		startPos:SetName("ROTGB_LASERSTART_"..startPos:GetCreationID())
		startPos:SetPos(hookData.startPos)
		startPos:SetParent(self)
		startPos:Spawn()
		self.rotgb_StartPos = startPos
		self:DeleteOnRemove(startPos)
	end
	
	if not IsValid(ent.rotgb_EndPos) then
		endPos = ents.Create("info_target")
		endPos:SetName("ROTGB_LASEREND_"..endPos:GetCreationID())
		endPos:SetPos(hookData.endPos)
		endPos:SetParent(ent)
		endPos:Spawn()
		ent.rotgb_EndPos = endPos
		ent:DeleteOnRemove(endPos)
	end
	
	if ROTGB_LoggingEnabled("towers") then
		debugoverlay.Cross(startPos:GetPos(), 16, self.LaserInterval, color_green, true)
		debugoverlay.Cross(endPos:GetPos(), 16, self.LaserInterval, color_red, true)
	end
	
	local laser = ents.Create(hookData.laser and "env_laser" or "env_beam")
	laser:SetPos(startPos:GetPos())
	laser:SetKeyValue("LightningStart", startPos:GetName())
	laser:SetKeyValue("LaserTarget", endPos:GetName())
	laser:SetKeyValue("LightningEnd", endPos:GetName())
	
	laser:SetKeyValue("damage", hookData.damage)
	laser:SetKeyValue("width", hookData.width)
	laser:SetKeyValue("BoltWidth", hookData.width)
	laser:SetKeyValue("NoiseAmplitude", hookData.noise or 0)
	
	laser:SetKeyValue("renderamt", string.format("%u", hookData.color.a or 255))
	laser:SetKeyValue("rendercolor", string.format("%u %u %u", hookData.color.r or 255, hookData.color.g or 255, hookData.color.b or 255))
	laser:SetKeyValue("HDRColorScale", "0.7")
	
	laser:SetKeyValue("texture", hookData.texture or hookData.rainbow and "beams/rainbow1.vmt" or "sprites/laserbeam.spr")
	laser:SetKeyValue("TextureScroll", hookData.scroll or 0)
	
	local spawnflags = 0
	if hookData.sparksStart then
		spawnflags = bit.bor(spawnflags, 16)
	end
	if hookData.sparks then
		spawnflags = bit.bor(spawnflags, 32)
	end
	if hookData.decal then
		spawnflags = bit.bor(spawnflags, 64)
		laser:SetKeyValue("decalname", hookData.decal)
	end
	if hookData.fadeIn then
		spawnflags = bit.bor(spawnflags, 128)
	end
	if hookData.fadeOut then
		spawnflags = bit.bor(spawnflags, 256)
	end
	if hookData.shrink then
		spawnflags = bit.bor(spawnflags, 512)
	end
	laser:SetKeyValue("spawnflags", spawnflags)
	
	laser:Spawn()
	laser:Activate()
	laser:Fire("TurnOn")
	laser.rotgb_Owner = self
	laser.rotgb_DamageType = hookData.damageType
	laser.rotgb_Rainbow = hookData.rainbow
	
	self:DeleteOnRemove(laser)
	endPos:DeleteOnRemove(laser)
	
	SafeRemoveEntityDelayed(laser, self.LaserInterval)
	SafeRemoveEntityDelayed(endPos, self.LaserInterval)
end

function ENT:ExpensiveThink(bool)
	self.gBalloons = {}
	self.balloonTable = {}
	self.lastBalloonTrace = self.lastBalloonTrace or {}
	--self.SolicitedgBalloon = NULL
	self.DetectedEnemy = nil
	local selfpos = self:GetShootPos()
	local traceData = {
		filter = self,
		mask = MASK_SHOT,
		output = self.lastBalloonTrace,
		start = selfpos
	}
	local mode = self:GetTargeting()
	for k,v in pairs(ROTGB_GetBalloons()) do
		if self:ValidTarget(v) then
			local LosOK = not self.UseLOS
			if not LosOK then
				traceData.endpos = v:WorldSpaceCenter()
				util.TraceLine(traceData)
				if IsValid(self.lastBalloonTrace.Entity) and self.lastBalloonTrace.Entity:GetClass()=="gballoon_base" then
					LosOK = true
				end
			end
			if LosOK then
				if bool then
					if mode==0 then
						self.balloonTable[v] = v:GetDistanceTravelled()
					elseif mode==1 then
						self.balloonTable[v] = -v:GetDistanceTravelled()
					elseif mode==2 then
						self.balloonTable[v] = v:GetRgBE()
					elseif mode==3 then
						self.balloonTable[v] = -v:GetRgBE()
					elseif mode==4 then
						self.balloonTable[v] = v:BoundingRadius()^2/(v:WorldSpaceCenter():DistToSqr(selfpos))
					elseif mode==5 then
						self.balloonTable[v] = -v:BoundingRadius()^2/(v:WorldSpaceCenter():DistToSqr(selfpos))
					elseif mode==6 then
						self.balloonTable[v] = v.loco:GetAcceleration()
					elseif mode==7 then
						self.balloonTable[v] = -v.loco:GetAcceleration()
					end
				else
					self.DetectedEnemy = true return
				end
			end
		end
	end
	for k,v in SortedPairsByValue(self.balloonTable,true) do
		table.insert(self.gBalloons,k)
	end
	--self.SolicitedgBalloon = self.gBalloons[1]
end

function ENT:ROTGB_Draw()
end

function ENT:DrawTranslucent()
	local cond1 = LocalPlayer():GetEyeTrace().Entity==self
	if self.DetectionRadius < 16384 and ROTGB_GetConVarValue("rotgb_range_enable_indicators") then
		local fadeout = ROTGB_GetConVarValue("rotgb_range_fade_time")
		local cond2 = self:GetShootPos():DistToSqr(EyePos())<=self.DetectionRadius*self.DetectionRadius
		if cond1 and cond2 then
			self.DrawFadeNext = RealTime()+fadeout+ROTGB_GetConVarValue("rotgb_range_hold_time")
		end
		if (self.DrawFadeNext or 0)>RealTime() then
			local scol = self:GetNWBool("ROTGB_Stun2") and color_red or self.InfiniteRange and color_blue or color_aqua
			local maxAlpha = ROTGB_GetConVarValue("rotgb_range_alpha")
			local alpha = math.Clamp(math.Remap(self.DrawFadeNext-RealTime(),fadeout,0,maxAlpha,0),0,maxAlpha)
			scol = Color(scol.r,scol.g,scol.b,alpha)
			render.SetColorMaterial()
			render.DrawSphere(self:GetShootPos(),-self.DetectionRadius,16,9,scol)
		end
	end
	self:ROTGB_Draw()
	if self.HasAbility or cond1 then
		local selfpos = self:LocalToWorld(Vector(0,0,ROTGB_GetConVarValue("rotgb_hoverover_distance")+self:OBBMaxs().z))
		local reqang = (selfpos-LocalPlayer():GetShootPos()):Angle()
		reqang.p = 0
		reqang.y = reqang.y-90
		reqang.r = 90
		cam.Start3D2D(selfpos,reqang,0.2)
			if cond1 and LocalPlayer():GetUseEntity() == self then
				local fontSize = ROTGB_GetConVarValue("rotgb_hud_size")
				draw.RoundedBox(4, -fontSize/2, -fontSize/2, fontSize, fontSize, color_black)
				--draw.RoundedBox(4, fontSize/2, -fontSize/2, -fontSize, fontSize, color_black)
				draw.SimpleText(input.LookupBinding("+use"):upper(), "RotgB_font", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			elseif self.HasAbility then
				local percent = math.Clamp(self:GetAbilityCharge(),0,1)
				local color = HSVToColor(percent*120,1,1)
				ROTGB_DrawCircle(0,0,16,percent,color.r,color.g,color.b,color.a)
				
				if self:GetAbilityFraction() > 0 then
					percent = math.Clamp(self:GetAbilityFraction(),0,1)
					color = color_aqua
					ROTGB_DrawCircle(0,0,12,percent,color.r,color.g,color.b,color.a)
				end
			end
		cam.End3D2D()
	end
end

function ENT:OnTakeDamage(dmginfo)
	if IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() then
		self:DoAbility()
	end
end

function ENT:DoAbility()
	if self.HasAbility and self:GetAbilityCharge()>=1 then
		local failed = self:TriggerAbility()
		if not failed then
			self:SetAbilityCharge(0)
			self:SetAbilityFraction(1)
			if engine.ActiveGamemode() == "rotgb" then
				for k,v in pairs(ents.GetAll()) do
					if v.Base == "gballoon_tower_base" then
						v.OtherTowerAbilityActivatedTime = math.max(v.OtherTowerAbilityActivatedTime or 0, self.AbilityCooldown/3)
					end
				end
			end
			
			self:AddDelayedActions(self, "ROTGB_ABILITY", -1, function(tower)
				local abilityInfo = tower:GetDelayedActions("ROTGB_ABILITY")
				
				if abilityInfo and (tower.AbilityDuration or 0) > 0 then
					tower:SetAbilityFraction(1 - abilityInfo.elapsed / tower.AbilityDuration)
				elseif tower:GetAbilityFraction() > 0 then
					tower:SetAbilityFraction(0)
				end
			end, self.AbilityDuration, function(tower)
				tower:SetAbilityFraction(0)
			end)
		end
	end
end

function ENT:AddPops(pops)
	self:SetPops((self:GetPops() or 0) + pops)
end

function ENT:AddCash(cash, ply)
	local incomeCash = cash * ROTGB_GetConVarValue("rotgb_tower_income_mul") * ROTGB_GetConVarValue("rotgb_cash_mul")
	incomeCash = hook.Run("TowerAddCash", self, cash, ply) or incomeCash
	ROTGB_AddCash(incomeCash, ply)
	self:SetCashGenerated((self:GetCashGenerated() or 0) + incomeCash)
end

function ENT:StatThink()
	if self.OldCashGenerated ~= self:GetCashGenerated() or self.OldPops ~= self:GetPops() then
		self.OldPops = self:GetPops()
		self.OldCashGenerated = self:GetCashGenerated()
		
		net.Start("rotgb_openupgrademenu", true)
		net.WriteEntity(self)
		net.WriteUInt(ROTGB_TOWER_STAT, 2)
		net.WriteDouble(self.OldPops or 0)
		net.WriteDouble(self.OldCashGenerated or 0)
		net.Broadcast()
	end
end

function ENT:GetUpgradeName(path, tier)
	return ROTGB_LocalizeString(string.format("rotgb.tower.%s.upgrades.%i.%i.name", self:GetClass(), path, tier))
end

function ENT:GetUpgradeDescription(path, tier)
	return ROTGB_LocalizeString(string.format("rotgb.tower.%s.upgrades.%i.%i.description", self:GetClass(), path, tier))
end

ENT.ROTGB_OnRemove = ENT.ROTGB_Initialize

function ENT:OnRemove()
	self:ROTGB_OnRemove()
	local sellPrice = (self.SellAmount or 0)*0.8
	if SERVER then
		ROTGB_AddCash(sellPrice, IsValid(self:GetTowerOwner()) and self:GetTowerOwner())
	end
	hook.Run("TowerSold", self, sellPrice, self:GetTowerOwner())
end

net.Receive("rotgb_openupgrademenu",function(length,ply)
	if CLIENT then
		local ent = net.ReadEntity()
		if IsValid(ent) and ent.SellAmount then
			local op = net.ReadUInt(2)
			if op == ROTGB_TOWER_MENU then
				ent.SellAmount = net.ReadDouble()
				ent.FusionPower = net.ReadUInt(16)
				ROTGB_UpgradeMenu(ent)
			elseif op == ROTGB_TOWER_STAT then
				ent:SetPops(net.ReadDouble())
				ent:SetCashGenerated(net.ReadDouble())
			end
		end
	end
	if SERVER then
		local ent = net.ReadEntity()
		if not IsValid(ent) then return end
		if ent.Base ~= "gballoon_tower_base" then return end
		if ent:GetTowerOwner() ~= ply then return end
		local path = net.ReadUInt(4) -- we actually only use 0-7; 8-10 are for targeting, 11-12 are for deletion and 13-15 are for other special cases.
		if path==8 then
			return ent:SetTargeting((ent:GetTargeting()+1)%targetings)
		elseif path==9 then
			return ent:SetTargeting((ent:GetTargeting()-1)%targetings)
		elseif path==10 then
			return ent:SetTargeting(net.ReadUInt(4)%targetings)
		elseif path==11 then
			constraint.RemoveAll(ent)
			ent:SetNotSolid(true)
			ent:SetMoveType(MOVETYPE_NONE)
			ent:SetNoDraw(true)
			local effdata = EffectData()
			effdata:SetEntity(ent)
			util.Effect("entity_remove",effdata,true,true)
			if IsValid(ply) then
				ply:SendLua("achievements.Remover()")
			end
			return SafeRemoveEntityDelayed(ent,1)
		elseif path==12 then
			for k,v in pairs(ents.FindByClass(ent:GetClass())) do
				if v:GetTowerOwner() == ply then
					constraint.RemoveAll(v)
					v:SetNotSolid(true)
					v:SetMoveType(MOVETYPE_NONE)
					v:SetNoDraw(true)
					local effdata = EffectData()
					effdata:SetEntity(v)
					util.Effect("entity_remove",effdata,true,true)
					if IsValid(ply) then
						ply:SendLua("achievements.Remover()")
					end
					SafeRemoveEntityDelayed(v,1)
				end
			end
			return
		end
		
		local reference = ent.UpgradeReference[path+1]
		if not reference then return end
		local upgradeAmount = net.ReadUInt(4)+1
		if not (ROTGB_GetConVarValue("rotgb_ignore_upgrade_limits") or ent:GetNWBool("rotgb_noupgradelimit")) then
			-- check if the upgrade is valid and not locked
			local pathUpgrades = {}
			for i=1,#ent.UpgradeReference do
				table.insert(pathUpgrades, bit.band(bit.rshift(ent:GetUpgradeStatus(),i*4-4),15))
			end
			pathUpgrades[path+1] = pathUpgrades[path+1] + upgradeAmount
			table.sort(pathUpgrades, function(a,b) return a>b end)
			local slot = 1
			for i,v in ipairs(pathUpgrades) do
				if v > ent.UpgradeLimits[slot] then return end
				if v > (ent.UpgradeLimits[i+1] or 0) then slot = i + 1 end
			end
		end
		-- it's valid
		local oldTiers = bit.band(bit.rshift(ent:GetUpgradeStatus(),path*4),15)+1
		local tier = oldTiers
		for i=1,upgradeAmount do
			if ent:CanPerformFusion(path+1, tier) then
				local price = reference.Prices and reference.Prices[tier] or 0
				price = ROTGB_ScaleBuyCost(price, ent, {type = ROTGB_TOWER_UPGRADE, path = path+1, tier = tier})
				if ROTGB_GetCash(ply)>=price then
					ent.SellAmount = (ent.SellAmount or 0) + price
					--[[if (reference.Funcs and reference.Funcs[tier]) then
						reference.Funcs[tier](ent)
					end]]
					ROTGB_RemoveCash(price,ply)
					hook.Run("RotgBTowerUpgraded", ent, path+1, tier, price)
					tier = tier + 1
				end
			end
		end
		
		local difference = tier-oldTiers
		if difference ~= 0 then
			ent:SetUpgradeStatus(ent:GetUpgradeStatus()+bit.lshift(tier-oldTiers,path*4))
			ROTGB_EntityLog(ent, string.format("Upgrade status is now %x!", ent:GetUpgradeStatus()), "towers")
			ent:EmitSound("interactions_pickup_retro_01.wav")
			local effdata = EffectData()
			effdata:SetEntity(ent)
			util.Effect("entity_remove",effdata,true,true)
			--[[net.Start("rotgb_openupgrademenu")
			net.WriteEntity(ent)
			net.WriteUInt(ROTGB_TOWER_UPGRADE, 2)
			net.WriteUInt(path, 4)
			net.WriteUInt(upgradeAmount-1, 4)
			net.SendOmit(ply)]]
		end
	end
end)

function ENT:Use(activator,caller,...)
	if (IsValid(activator) and activator:IsPlayer()) and not self:GetDelayedActions("ROTGB_FUSION") then
		if not IsValid(self:GetTowerOwner()) then
			self:SetTowerOwner(activator)
			self:SetOwnerUserID(activator:UserID())
		end
		if self:GetTowerOwner() == activator then
			net.Start("rotgb_openupgrademenu")
			net.WriteEntity(self)
			net.WriteUInt(ROTGB_TOWER_MENU, 2)
			net.WriteDouble(self.SellAmount or 0)
			net.WriteUInt(self.FusionPower or 0, 16)
			net.Send(activator)
		else
			ROTGB_CauseNotification(ROTGB_NOTIFY_TOWERNOTOWNER, ROTGB_NOTIFYTYPE_ERROR, activator, {"s", self:GetTowerOwner():Nick()})
		end
	end
end

timer.Simple(0, function()
	for k,v in pairs(scripted_ents.GetList()) do
		if v.Base == "gballoon_tower_base" then
			list.Set("NPC",k,{
				Name = string.format("%s ($%i)", v.t.PrintName, v.t.Cost),
				Class = k,
				Category = v.t.Category
			})
			list.Set("SpawnableEntities",k,{
				PrintName = string.format("%s ($%i)", v.t.PrintName, v.t.Cost),
				ClassName = k,
				Category = v.t.Category
			})
		end
	end
end)