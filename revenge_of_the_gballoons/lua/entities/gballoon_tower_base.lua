AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Anti-gBalloon Tower"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
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

local buttonlabs = {"First","Last","Strong","Weak","Close","Far","Fast","Slow"}

local color_red = Color(255,0,0)
local color_aqua = Color(0,255,255)
local color_blue = Color(0,0,255)

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

function ENT:SetupDataTables()
	--self:NetworkVar("Bool",0,"SpawnerActive")
	self:NetworkVar("Int",0,"UpgradeStatus")
	-- Path1 + Path2 << 4 + Path3 << 8 + Path4 << 12 + ...
	self:NetworkVar("Int",1,"Targeting")
	self:NetworkVar("Int",2,"Pops")
	self:NetworkVar("Int",3,"OwnerUserID")
	self:NetworkVar("Float",0,"AbilityCharge")
	self:NetworkVar("Float",1,"CashGenerated")
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
	
	if not IsValid(self:GetTowerOwner()) then
		if IsValid(Player(self:GetOwnerUserID())) then -- duplication always fails to copy entities properly
			self:SetTowerOwner(Player(self:GetOwnerUserID()))
		elseif IsValid(self:GetCreator()) then
			self:SetTowerOwner(self:GetCreator())
		else
			local bestPlayer = NULL
			local bestDistance = math.huge
			for k,v in pairs(player.GetAll()) do
				local distance = v:GetPos():DistToSqr(self:GetShootPos())
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
				if v:GetNextWaveTime() > CurTime() then
					self:SetSpawnerActive(true) break
				end
			end
		end
	end
	
	hook.Run("RotgBTowerPlaced", self)
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
	local laser = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	if (IsValid(laser) and laser.rotgb_UseLaser) then
		if (IsValid(laser.rotgb_Owner) and laser.rotgb_Owner.Base == "gballoon_tower_base") then
			dmginfo:SetAttacker(laser.rotgb_Owner:GetTowerOwner())
			dmginfo:SetInflictor(laser.rotgb_Owner)
		end
		if laser.rotgb_UseLaser==2 then
			dmginfo:SetDamageType(DMG_GENERIC)
			if dmginfo:GetDamage()>=vic:Health() and vic:GetClass()=="gballoon_base" and laser.rotgb_NoChildren then
				dmginfo:SetDamage(vic:GetRgBE() * 1000)
			end
		end
	elseif (IsValid(inflictor) and inflictor.rotgb_Owner) then
		dmginfo:SetInflictor(inflictor.rotgb_Owner)
	end
	if not ROTGB_GetConVarValue("rotgb_tower_damage_others") and vic:GetClass()~="gballoon_base" and IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor().Base == "gballoon_tower_base" then return true end
end)

hook.Add("PhysgunPickup", "ROTGB_TOWERS", function(ply, ent)
	if ent.Base == "gballoon_tower_base" and ROTGB_GetConVarValue("rotgb_tower_ignore_physgun") then return false end
end)

function ENT:PreEntityCopy()
	self.rotgb_DuplicatorTimeOffset = CurTime()
end

function ENT:PostEntityPaste(ply,ent,tab)
	self:AddTimePhase(CurTime() - (self.rotgb_DuplicatorTimeOffset or CurTime()))
end

function ENT:AddTimePhase(timeToAdd)
	self.NextFire = (self.NextFire or 0) + timeToAdd
	self.ExpensiveThinkDelay = (self.ExpensiveThinkDelay or 0) + timeToAdd
	self.StunUntil = (self.StunUntil or 0) + timeToAdd
	self:SetNWFloat("rotgb_noupgradelimit", self:GetNWFloat("rotgb_noupgradelimit") + timeToAdd)
	for identifier,info in pairs(self.BuffIdentifiers) do
		info.expiry = info.expiry + timeToAdd
	end
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
	self.StunUntil = math.max(CurTime() + tim,self.StunUntil or 0)
end

function ENT:UnStun()
	self.StunUntil = 0
end

function ENT:Stun2()
	self.StunUntil2 = true
end

function ENT:UnStun2()
	self.StunUntil2 = nil
end

function ENT:IsStunned()
	return self.StunUntil and self.StunUntil>CurTime() or self.StunUntil2 or false
end

ENT.ROTGB_Think = ENT.ROTGB_Initialize

hook.Add("gBalloonSpawnerWaveStarted", "ROTGB_TOWER_BASE", function(spawner,cwave)
	local maxWave = 0
	for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
		maxWave = math.max(maxWave, cwave)
	end
	for k,v in pairs(ents.GetAll()) do
		if v.Base=="gballoon_tower_base" then
			v:SetSpawnerActive(true)
			v.MaxWaveReached = maxWave
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
	if not self.LocalCost then
		local amount = ROTGB_ScaleBuyCost(self.Cost or 0, self, {type = ROTGB_TOWER_PURCHASE})
		if self:GetUpgradeStatus()>0 then
			for i,v in ipairs(self.UpgradeReference) do
				local tier = bit.rshift(self:GetUpgradeStatus(),(i-1)*4)%16
				for j=1,tier do
					if (v.Funcs and v.Funcs[j]) then
						v.Funcs[j](self)
						amount = amount + ROTGB_ScaleBuyCost(v.Prices[j], self, {type = ROTGB_TOWER_UPGRADE, path = i, tier = j})
					end
				end
			end
		end
		self.LocalCost = amount
		if CLIENT then
			self.SellAmount = self.LocalCost
		end
	end
	if SERVER then
		self:ROTGB_Think()
		if not self.IsEnabled and self.LocalCost then
			local towerOwner = self:GetTowerOwner()
			local towerCost = self.LocalCost
			self.IsEnabled = true
			if engine.ActiveGamemode() == "rotgb" and towerOwner:IsPlayer() then
				local towerIndex = 0
				local towers = ROTGB_GetAllTowers()
				for k,v in pairs(towers) do
					if v.ClassName == self:GetClass() then
						towerIndex = k break
					end
				end
				if towerOwner:RTG_GetLevel() < towerIndex then
					ROTGB_CauseNotification(string.format("You need to be level %i to buy this tower!", towerIndex), towerOwner)
					ROTGB_Log("Removed tower "..tostring(self).." placed by "..tostring(towerOwner).." due to level requirement.", "towers")
					return SafeRemoveEntity(self)
				end
			end
			local maxCount = ROTGB_GetConVarValue("rotgb_tower_maxcount")
			for entry in string.gmatch(ROTGB_GetConVarValue("rotgb_tower_blacklist"), "%S+") do
				if self:GetClass() == entry then
					ROTGB_CauseNotification("That tower is blacklisted from being placed!", towerOwner)
					ROTGB_Log("Removed tower "..tostring(self).." placed by "..tostring(towerOwner).." due to blacklist.", "towers")
					return SafeRemoveEntity(self)
				end
			end
			local chessOnly = ROTGB_GetConVarValue("rotgb_tower_chess_only")
			if chessOnly ~= 0 then
				if chessOnly > 0 and not self.IsChessPiece then
					ROTGB_CauseNotification("Only chess towers can be placed!", towerOwner)
					ROTGB_Log("Removed tower "..tostring(self).." placed by "..tostring(towerOwner).." due to not being a chess tower.", "towers")
				elseif chessOnly < 0 and self.IsChessPiece then
					ROTGB_CauseNotification("Only non-chess towers can be placed!", towerOwner)
					ROTGB_Log("Removed tower "..tostring(self).." placed by "..tostring(towerOwner).." due to being a chess tower.", "towers")
				end
			end
			if towerCost>ROTGB_GetCash(towerOwner) then
				ROTGB_CauseNotification("You need $"..string.Comma(math.ceil(towerCost-ROTGB_GetCash(towerOwner))).." more to buy this tower!", towerOwner)
				ROTGB_Log("Removed tower "..tostring(self).." placed by "..tostring(towerOwner).." due to insufficient cash.", "towers")
				return SafeRemoveEntity(self)
			elseif maxCount>=0 then
				local count = 0
				for k,v in pairs(ents.GetAll()) do
					if v.Base=="gballoon_tower_base" then
						count = count + 1
					end
				end
				if count > maxCount then
					ROTGB_CauseNotification("You are not allowed to place any more towers!", towerOwner)
					ROTGB_Log("Removed tower "..tostring(self).." placed by "..tostring(towerOwner).." due to excess towers.", "towers")
					return SafeRemoveEntity(self)
				end
			end
			ROTGB_RemoveCash(towerCost,towerOwner)
			self.SellAmount = self.LocalCost
		end
		local curTime = CurTime()
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
		if self.HasAbility and self:GetAbilityCharge() < 1 and self:GetSpawnerActive() then
			self:SetAbilityCharge(math.min(1, self:GetAbilityCharge()+FrameTime()/self.AbilityCooldown))
		end
		self:BuffThink()
		self:NextThink(curTime)
		return true
	end
end

function ENT:DoFireFunction()
	self:ExpensiveThink(true)
	if self.gBalloons[1]--[[IsValid(self.SolicitedgBalloon)]] or self.FireWhenNoEnemies then
		if engine.ActiveGamemode() == "rotgb" then
			local bonusMultiplier = 1
			if hook.Run("GetSkillAmount", "towerEarlyFireRate") ~= 0 then
				local waveFireRateFractionBonus = math.max(math.Remap(self.MaxWaveReached or 0, 1, 41, 1, 0), 0)
				local mul = 1+hook.Run("GetSkillAmount", "towerEarlyFireRate")/100*waveFireRateFractionBonus
				--print("A", mul)
				bonusMultiplier = bonusMultiplier * mul
			end
			if hook.Run("GetSkillAmount", "towerAbilityD3FireRate") ~= 0 and (self.OtherTowerAbilityActivatedTime or 0) >= CurTime() then
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
		local fireDelay = 1/(self.FireRate or 1)/self.BonusFireRate
		self.NextFire = CurTime() + fireDelay
		if not IsValid(self:GetTowerOwner()) then
			local bestPlayer = NULL
			local bestDistance = math.huge
			for k,v in pairs(player.GetAll()) do
				local distance = v:GetPos():DistToSqr(self:GetPos())
				if distance < bestDistance then
					bestPlayer = v
					bestDistance = distance
				end
			end
			self:SetTowerOwner(bestPlayer)
		end
		local nofire = self:FireFunction(--[[self.SolicitedgBalloon,]]self.gBalloons or {})
		if nofire then
			self.NextFire = 0
		end
	end
	self.ExpensiveThinkDelay = 0
end

function ENT:BuffThink()
	for identifier,info in pairs(self.BuffIdentifiers) do
		if not IsValid(info.tower) or info.expiry < CurTime() then
			info.unapplyFunc(self)
			self.BuffIdentifiers[identifier] = nil
		end
	end
end

function ENT:GetShootPos()
	return self:LocalToWorld(self.LOSOffset)
end

function ENT:ApplyBuff(tower, identifier, duration, applyFunc, unapplyFunc)
	identifier = identifier or #self.BuffIdentifiers+1
	if not self.BuffIdentifiers[identifier] then
		duration = duration or math.huge
		self.BuffIdentifiers[identifier] = {tower = tower, expiry = CurTime() + duration, unapplyFunc = unapplyFunc}
		applyFunc(self)
	end
end

function ENT:TowerBuffed(identifier)
	return IsValid(self.BuffIdentifiers[identifier])
end

function ENT:TowerBuffedBy(identifier)
	return self:TowerBuffed(identifier) and self.BuffIdentifiers[identifier]
end

function ENT:ValidTarget(v)
	return self:ValidTargetIgnoreRange(v) and (v:LocalToWorld(v:OBBCenter()):DistToSqr(self:GetShootPos()) <= self.DetectionRadius * self.DetectionRadius or self.InfiniteRange or self.InfiniteRange2)
end

function ENT:ValidTargetIgnoreRange(v)
	return (IsValid(v) and v:GetClass()=="gballoon_base" and not v:GetBalloonProperty("BalloonVoid")
	and (not v:GetBalloonProperty("BalloonHidden") or self.SeeCamo or v:HasRotgBStatusEffect("unhide")))
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
				traceData.endpos = v:GetPos()+v:OBBCenter()
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
						self.balloonTable[v] = v:BoundingRadius()^2/v:GetPos():DistToSqr(selfpos)
					elseif mode==5 then
						self.balloonTable[v] = -v:BoundingRadius()^2/v:GetPos():DistToSqr(selfpos)
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
	if self.DetectionRadius < 16384 and ROTGB_GetConVarValue("rotgb_range_enable_indicators") then
		local fadeout = ROTGB_GetConVarValue("rotgb_range_fade_time")
		local cond1 = LocalPlayer():GetEyeTrace().Entity==self and self:LocalToWorld(self.LOSOffset):DistToSqr(EyePos())<=self.DetectionRadius*self.DetectionRadius
		if cond1 then
			self.DrawFadeNext = RealTime()+fadeout+ROTGB_GetConVarValue("rotgb_range_hold_time")
		end
		if (self.DrawFadeNext or 0)>RealTime() then
			local scol = self:GetNWBool("ROTGB_Stun2") and color_red or self.InfiniteRange and color_blue or color_aqua
			local maxAlpha = ROTGB_GetConVarValue("rotgb_range_alpha")
			local alpha = math.Clamp(math.Remap(self.DrawFadeNext-RealTime(),fadeout,0,maxAlpha,0),0,maxAlpha)
			scol = Color(scol.r,scol.g,scol.b,alpha)
			render.SetColorMaterial()
			render.DrawSphere(self:LocalToWorld(self.LOSOffset),-self.DetectionRadius,16,9,scol)
		end
	end
	self:ROTGB_Draw()
	if self.HasAbility then
		local selfpos = self:LocalToWorld(Vector(0,0,ROTGB_GetConVarValue("rotgb_hoverover_distance")+self:OBBMaxs().z))
		local reqang = (selfpos-LocalPlayer():GetShootPos()):Angle()
		reqang.p = 0
		reqang.y = reqang.y-90
		reqang.r = 90
		cam.Start3D2D(selfpos,reqang,0.2)
			surface.SetDrawColor(0,0,0,127)
			local percent = math.Clamp(self:GetAbilityCharge(),0,1)
			ROTGB_DrawCircle(0,0,16,percent,HSVToColor(percent*120,1,1))
			ROTGB_DrawCircle(0,0,16,percent,HSVToColor(percent*120,1,1))
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
			if engine.ActiveGamemode() == "rotgb" then
				for k,v in pairs(ents.GetAll()) do
					if v.Base == "gballoon_tower_base" then
						v.OtherTowerAbilityActivatedTime = math.max(v.OtherTowerAbilityActivatedTime or 0, self.AbilityCooldown/3)
					end
				end
			end
		end
	end
end

function ENT:AddPops(pops)
	self:SetPops(self:GetPops()+pops)
end

function ENT:AddCash(cash, ply)
	local incomeCash = cash * ROTGB_GetConVarValue("rotgb_tower_income_mul") * ROTGB_GetConVarValue("rotgb_cash_mul")
	if engine.ActiveGamemode() == "rotgb" then
		incomeCash = incomeCash * (1+hook.Run("GetSkillAmount", "towerIncome")/100)
	end
	ROTGB_AddCash(incomeCash, ply)
	self:SetCashGenerated(self:GetCashGenerated()+incomeCash)
end

ENT.ROTGB_OnRemove = ENT.ROTGB_Initialize

function ENT:OnRemove()
	self:ROTGB_OnRemove()
	if SERVER then
		ROTGB_AddCash((self.SellAmount or 0)*0.8,IsValid(self:GetTowerOwner()) and self:GetTowerOwner())
	end
end

net.Receive("rotgb_openupgrademenu",function(length,ply)
	if CLIENT then
		local ent = net.ReadEntity()
		if IsValid(ent) then
			local op = net.ReadUInt(2)
			if op == ROTGB_TOWER_MENU then
				ROTGB_UpgradeMenu(ent)
			elseif op == ROTGB_TOWER_UPGRADE then
				-- get path number and upgrade amount
				local path = net.ReadUInt(4)
				local upgradeAmount = net.ReadUInt(4)+1
				
				local reference = ent.UpgradeReference[path+1]
				if not reference then return end
				local tier = bit.rshift(ent:GetUpgradeStatus(),path*4)%16+1
				for i=1,upgradeAmount do
					local price = ROTGB_ScaleBuyCost(reference.Prices[tier], ent, {type = ROTGB_TOWER_UPGRADE, path = path+1, tier = tier})
					ent.SellAmount = (ent.SellAmount or 0) + price
					if (reference.Funcs and reference.Funcs[tier]) then
						reference.Funcs[tier](ent)
					end
					tier = tier + 1
				end
			end
		else
			ROTGB_CauseNotification("You can't tamper with someone else's tower!")
		end
	end
	if SERVER then
		local ent = net.ReadEntity()
		if not IsValid(ent) then return end
		if ent.Base ~= "gballoon_tower_base" then return end
		local path = net.ReadUInt(4) -- we actually only use 0-7; 8-10 are for targeting, 11 is for deletion and 12-15 are for other special cases.
		if path==8 then
			return ent:SetTargeting((ent:GetTargeting()+1)%#buttonlabs)
		elseif path==9 then
			return ent:SetTargeting((ent:GetTargeting()-1)%#buttonlabs)
		elseif path==10 then
			return ent:SetTargeting(net.ReadUInt(4)%#buttonlabs)
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
		end
		
		local reference = ent.UpgradeReference[path+1]
		if not reference then return end
		local upgradeAmount = net.ReadUInt(4)+1
		if not (ROTGB_GetConVarValue("rotgb_ignore_upgrade_limits") or ent:GetNWFloat("rotgb_noupgradelimit") >= CurTime()) then
			-- check if the upgrade is valid and not locked
			local pathUpgrades = {}
			for i=1,#ent.UpgradeReference do
				table.insert(pathUpgrades, bit.rshift(ent:GetUpgradeStatus(),i*4-4)%16)
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
		local tier = bit.rshift(ent:GetUpgradeStatus(),path*4)%16+1
		for i=1,upgradeAmount do
			local price = ROTGB_ScaleBuyCost(reference.Prices[tier], ent, {type = ROTGB_TOWER_UPGRADE, path = path+1, tier = tier})
			if ROTGB_GetCash(ply)<price then return end
			ent.SellAmount = (ent.SellAmount or 0) + price
			if (reference.Funcs and reference.Funcs[tier]) then
				reference.Funcs[tier](ent)
			end
			ROTGB_RemoveCash(price,ply)
			tier = tier + 1
		end
		ent:SetUpgradeStatus(ent:GetUpgradeStatus()+bit.lshift(upgradeAmount,path*4))
		net.Start("rotgb_openupgrademenu")
		net.WriteEntity(ent)
		net.WriteUInt(ROTGB_TOWER_UPGRADE, 2)
		net.WriteUInt(path, 4)
		net.WriteUInt(upgradeAmount-1, 4)
		net.SendOmit(ply)
	end
end)

function ENT:Use(activator,caller,...)
	if (IsValid(caller) and caller:IsPlayer()) then
		if not IsValid(self:GetTowerOwner()) then
			self:SetTowerOwner(caller)
		end
		net.Start("rotgb_openupgrademenu")
		net.WriteEntity(self)
		net.WriteUInt(ROTGB_TOWER_MENU, 2)
		net.Send(caller)
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