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
local buttonlabs = {"First","Last","Strong","Weak","Close","Far","Fast","Slow"}
local icns = {"shape_move_front","shape_move_back","award_star_gold_3","award_star_bronze_1","connect","disconnect","control_fastforward_blue","control_play"}

local color_black_translucent = Color(0,0,0,127)
local color_gray_translucent = Color(127,127,127,127)
local color_dark_red = Color(127,0,0)
local color_red = Color(255,0,0)
local color_yellow = Color(255,255,0)
local color_green = Color(0,255,0)
local color_aqua = Color(0,255,255)
local color_blue = Color(0,0,255)
local color_gray = Color(127,127,127)
local ConR,ConH,ConT,ConA

local ROTGB_TOWER_MENU = 0
local ROTGB_TOWER_UPGRADE = 1

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

if CLIENT then
	ConR = CreateClientConVar("rotgb_range_enable_indicators","1",true,false,
	[[Hovering over a tower shows its range.
	 - An aqua range means that its range is finite.
	 - A blue range means that its range is infinite.
	 - A red range means that its placement is invalid.]])

	ConH = CreateClientConVar("rotgb_range_hold_time","0.25",true,false,
	[[Time to hold the range indicator before it fades out.]])

	ConT = CreateClientConVar("rotgb_range_fade_time","0.25",true,false,
	[[Time to fade out the range indicator.]])

	ConA = CreateClientConVar("rotgb_range_alpha","15",true,false,
	[[Sets how visible the range indicator is, in the range of 0-255.]])
end

if SERVER then
	util.AddNetworkString("rotgb_openupgrademenu")
end

local function CauseNotification(msg)
	notification.AddLegacy(msg,NOTIFY_ERROR,5)
	surface.PlaySound("buttons/button10.wav")
end

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"UpgradeStatus")
	-- Path1 + Path2 << 4 + Path3 << 8 + Path4 << 12 + ...
	self:NetworkVar("Float",0,"AbilityNextFire")
	self:NetworkVar("Int",1,"Targeting")
	self:NetworkVar("Entity",0,"TowerOwner")
	self:NetworkVar("Int",2,"Pops")
	self:NetworkVar("Float",1,"CashGenerated")
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

function ENT:ROTGB_Initialize()
end

function ENT:Initialize()
	local cost = ROTGB_ScaleBuyCost(self.Cost or 0)
	local maxCount = ROTGB_GetConVarValue("rotgb_tower_maxcount")
	self:ROTGB_Initialize()
	if not IsValid(self:GetTowerOwner()) then
		self:SetTowerOwner(player.GetAll()[math.random(player.GetCount())])
	end
	self.LOSOffset = self.LOSOffset or vector_origin
	if SERVER then
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:Wake()
			physobj:EnableMotion(false)
		end
		self:SetUseType(SIMPLE_USE)
		if maxCount>=0 then
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
		end
	end
	self.LocalCost = cost
	self.DetectionRadius = self.DetectionRadius * ROTGB_GetConVarValue("rotgb_tower_range_multiplier")
	if self:GetUpgradeStatus()>0 then
		for i,v in ipairs(self.UpgradeReference) do
			local tier = bit.rshift(self:GetUpgradeStatus(),(i-1)*4)%16
			for i=1,tier do
				if (v.Funcs and v.Funcs[tier]) then
					v.Funcs[tier](self)
					self.LocalCost = self.LocalCost + ROTGB_ScaleBuyCost(v.Prices[tier])
				elseif (v.Functions and v.Functions[tier]) then
					v.Functions[tier](v,self)
					self.LocalCost = self.LocalCost + ROTGB_ScaleBuyCost(v.Prices[tier])
				end
			end
		end
	end
	if CLIENT and LocalPlayer()==self:GetTowerOwner() then
		local localPlayer = LocalPlayer()
		local levelLocked, towerIndex = false, 0
		if engine.ActiveGamemode() == "rotgb" then
			-- get a sorted-by-price list of all towers, then return our index from the list
			local towers = ROTGB_GetAllTowers()
			for k,v in pairs(towers) do
				if v.ClassName == self:GetClass() then
					towerIndex = k break
				end
			end
			levelLocked = localPlayer:ROTGB_GetLevel() < towerIndex
		end
		if levelLocked then
			CauseNotification("You need to be level "..string.Comma(towerIndex).." to buy this tower!")
		elseif self.LocalCost>ROTGB_GetCash(localPlayer) then
			CauseNotification("You need $"..string.Comma(math.ceil(self.LocalCost-ROTGB_GetCash(localPlayer))).." more to buy this tower!")
		elseif maxCount>=0 then
			local count = 0
			for k,v in pairs(ents.GetAll()) do
				if v.Base=="gballoon_tower_base" then
					count = count + 1
				end
			end
			if count > maxCount then
				CauseNotification("You are not allowed to place any more towers!")
			end
		end
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
	self.IsEnabled = nil
end

function ENT:PostEntityCopy()
	self.IsEnabled = true
end

function ENT:OnReloaded()
	self:Spawn()
	self:Activate()
end

function ENT:PostEntityPaste(ply,ent,tab)
	ent:Spawn()
	ent:Activate()
end

ENT.FireFunction = function() end
ENT.ROTGB_AcceptInput = ENT.FireFunction

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

ENT.ROTGB_Think = function()end

function ENT:Think()
	if SERVER then
		self:ROTGB_Think()
		local towerCost = self.LocalCost
		if not self.IsEnabled and towerCost then
			self.IsEnabled = true
			--[[for k,v in pairs(ents.FindInBox(self:GetCollisionBounds())) do
				if v:GetClass()=="func_rotgb_nobuild" and not v.Disabled then
					return SafeRemoveEntity(self)
				end
			end]] -- already done in func_rotgb_nobuild
			if engine.ActiveGamemode() == "rotgb" and self:GetTowerOwner():IsPlayer() then
				local towerIndex = 0
				local towers = ROTGB_GetAllTowers()
				for k,v in pairs(towers) do
					if v.ClassName == self:GetClass() then
						towerIndex = k break
					end
				end
				if self:GetTowerOwner():ROTGB_GetLevel() < towerIndex then
					ROTGB_Log("Removed tower "..tostring(self).." placed by "..tostring(self:GetTowerOwner()).." due to level requirement.", "towers")
					return SafeRemoveEntity(self)
				end
			end
			local maxCount = ROTGB_GetConVarValue("rotgb_tower_maxcount")
			if towerCost>ROTGB_GetCash(self:GetTowerOwner()) then
				ROTGB_Log("Removed tower "..tostring(self).." placed by "..tostring(self:GetTowerOwner()).." due to insufficient cash.", "towers")
				return SafeRemoveEntity(self)
			elseif maxCount>=0 then
				local count = 0
				for k,v in pairs(ents.GetAll()) do
					if v.Base=="gballoon_tower_base" then
						count = count + 1
					end
				end
				if count > maxCount then
					ROTGB_Log("Removed tower "..tostring(self).." placed by "..tostring(self:GetTowerOwner()).." due to excess towers.", "towers")
					return SafeRemoveEntity(self)
				end
			end
			ROTGB_RemoveCash(towerCost,self:GetTowerOwner())
			self.SellAmount = (self.SellAmount or 0) + towerCost
		end
		if not self:IsStunned() then
			local shouldExpensiveThink = false
			for k,v in pairs(ROTGB_GetBalloons()) do
				if self:ValidTarget(v) then
					shouldExpensiveThink = true break
				end
			end
			if shouldExpensiveThink then
				self.ExpensiveThinkDelay = self.ExpensiveThinkDelay or CurTime()
				if self.ExpensiveThinkDelay <= CurTime() then
					self.ExpensiveThinkDelay = CurTime() + math.min(0.5, 1/(self.FireRate or 1))
					self:ExpensiveThink()
					if not IsValid(self:GetTowerOwner()) then
						self:SetTowerOwner(player.GetAll()[math.random(player.GetCount())])
					end
				end
			end
			if (self.NextFire or 0) < CurTime() and (self.DetectedEnemy or self.FireWhenNoEnemies) then
				self.NextFire = CurTime() + 1/(self.FireRate or 1)
				self:ExpensiveThink(true)
				if self.gBalloons[1]--[[IsValid(self.SolicitedgBalloon)]] or self.FireWhenNoEnemies then
					local nofire = self:FireFunction(--[[self.SolicitedgBalloon,]]self.gBalloons or {})
					if nofire then
						self.NextFire = 0
					end
				end
				self.ExpensiveThinkDelay = 0
			end
			self:NextThink(CurTime())
			return true
		end
	end
end

function ENT:GetShootPos()
	return self:LocalToWorld(self.LOSOffset)
end

function ENT:IsBalloon(ent)
	return ent:GetClass()=="gballoon_base"
end

--[[function ENT:MaskFilter(mask,ent)
	if mask<0 and ent:Health()>0 then return true end
	if ent:IsNPC() then
		local entclass = ent:Classify()
		if HasAllBits(mask,2) and (entclass==CLASS_PLAYER_ALLY or entclass==CLASS_PLAYER_ALLY_VITAL or entclass==CLASS_CITIZEN_PASSIVE or entclass==CLASS_CITIZEN_REBEL or entclass==CLASS_VORTIGAUNT or entclass==CLASS_HACKED_ROLLERMINE) then return true
		elseif HasAllBits(mask,4) and (entclass==CLASS_COMBINE or entclass==CLASS_COMBINE_GUNSHIP or entclass==CLASS_MANHACK or entclass==CLASS_METROPOLICE or entclass==CLASS_MILITARY or entclass==CLASS_SCANNER or entclass==CLASS_STALKER or entclass==CLASS_PROTOSNIPER or entclass==CLASS_COMBINE_HUNTER) then return true
		elseif HasAllBits(mask,8) and (entclass==CLASS_HEADCRAB or entclass==CLASS_ZOMBIE) then return true
		elseif HasAllBits(mask,16) and (entclass==CLASS_ANTLION) then return true
		elseif HasAllBits(mask,32) and (entclass==CLASS_BARNACLE or entclass==CLASS_BULLSEYE or entclass==CLASS_CONSCRIPT or entclass==CLASS_MISSILE or entclass==CLASS_FLARE or entclass==CLASS_EARTH_FAUNA or entclass>25) then return true
		elseif HasAllBits(mask,64) and ent:IsScripted() then return true
		end
	elseif HasAllBits(mask,1) and ent:IsPlayer() and not GetConVar("ai_ignoreplayers"):GetBool() then return true
	elseif HasAllBits(mask,128) and ent:Health()>0 and ent.RunBehaviour then return true
	elseif HasAllBits(mask,256) and ent:Health()>0 and not ent.RunBehaviour then return true
	end
	return false
end]]

function ENT:ValidTarget(v)
	return self:ValidTargetIgnoreRange(v) and (v:LocalToWorld(v:OBBCenter()):DistToSqr(self:GetShootPos()) <= self.DetectionRadius * self.DetectionRadius or self.InfiniteRange or self.InfiniteRange2)
end

function ENT:ValidTargetIgnoreRange(v)
	return (IsValid(v) and v:GetClass()=="gballoon_base" and not v:GetBalloonProperty("BalloonVoid")
	and (not v:GetBalloonProperty("BalloonHidden") or self.SeeCamo or v:HasRotgBStatusEffect("unhide")))
end

function ENT:ExpensiveThink(bool)
	self.gBalloons = self.gBalloons or {}
	self.balloonTable = self.balloonTable or {}
	self.lastBalloonTrace = self.lastBalloonTrace or {}
	--self.SolicitedgBalloon = NULL
	self.DetectedEnemy = nil
	table.Empty(self.gBalloons) -- saves memory
	table.Empty(self.balloonTable)
	local selfpos = self:GetShootPos()
	self.gBTraceData = self.gBTraceData or {
		filter = self,
		mask = MASK_SHOT,
		output = self.lastBalloonTrace
	}
	self.gBTraceData.start = selfpos
	local mode = self:GetTargeting()
	for k,v in pairs(ROTGB_GetBalloons()) do
		if self:ValidTarget(v) then
			local LosOK = not self.UseLOS
			if not LosOK then
				self.gBTraceData.endpos = v:GetPos()+v:OBBCenter()
				util.TraceLine(self.gBTraceData)
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

local function DrawCircle(x,y,r,percent,...)
	local SEGMENTS = GetConVar("rotgb_circle_segments"):GetInt()
	local seoul = -360/SEGMENTS
	percent = math.Clamp(percent*SEGMENTS,0,SEGMENTS)
	local vertices = {{x=x,y=y}}
	local pi = math.pi
	for i=0,math.floor(percent) do
		local compx = x+math.sin(math.rad(i*seoul)+pi)*r
		local compy = y+math.cos(math.rad(i*seoul)+pi)*r
		table.insert(vertices,{x=compx,y=compy})
	end
	if math.floor(percent)~=percent then
		local compx = x+math.sin(math.rad(percent*seoul)+pi)*r
		local compy = y+math.cos(math.rad(percent*seoul)+pi)*r
		table.insert(vertices,{x=compx,y=compy})
	end
	draw.NoTexture()
	surface.SetDrawColor(...)
	surface.DrawPoly(vertices)
	table.insert(vertices,table.remove(vertices,1))
	surface.DrawPoly(table.Reverse(vertices))
end

function ENT:ROTGB_Draw()
end

function ENT:DrawTranslucent()
	if self.DetectionRadius < 16384 and ConR:GetBool() then
		local fadeout = ConT:GetFloat()
		local cond1 = LocalPlayer():GetEyeTrace().Entity==self and self:LocalToWorld(self.LOSOffset):DistToSqr(EyePos())<=self.DetectionRadius*self.DetectionRadius
		if cond1 then
			self.DrawFadeNext = RealTime()+fadeout+ConH:GetFloat()
		end
		if (self.DrawFadeNext or 0)>RealTime() then
			local scol = self:GetNWBool("ROTGB_Stun2") and color_red or self.InfiniteRange and color_blue or color_aqua
			local alpha = math.Clamp(math.Remap(self.DrawFadeNext-RealTime(),fadeout,0,ConA:GetFloat(),0),0,ConA:GetFloat())
			scol = Color(scol.r,scol.g,scol.b,alpha)
			render.SetColorMaterial()
			render.DrawSphere(self:LocalToWorld(self.LOSOffset),-self.DetectionRadius,16,9,scol)
		end
	end
	self:ROTGB_Draw()
	if self.HasAbility then
		local selfpos = self:LocalToWorld(Vector(0,0,GetConVar("rotgb_hoverover_distance"):GetFloat()+self:OBBMaxs().z))
		local reqang = (selfpos-LocalPlayer():GetShootPos()):Angle()
		reqang.p = 0
		reqang.y = reqang.y-90
		reqang.r = 90
		cam.Start3D2D(selfpos,reqang,0.2)
			surface.SetDrawColor(0,0,0,127)
			local percent = math.Clamp(1-(self:GetAbilityNextFire()-CurTime())/self.AbilityCooldown,0,1)
			DrawCircle(0,0,16,percent,HSVToColor(percent*120,1,1))
			DrawCircle(0,0,16,percent,HSVToColor(percent*120,1,1))
		cam.End3D2D()
	end
end

function ENT:OnTakeDamage(dmginfo)
	if (self.HasAbility and self:GetAbilityNextFire()>CurTime()+self.AbilityCooldown) then self:SetAbilityNextFire(0) end
	if (self.HasAbility and IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() and self:GetAbilityNextFire()<CurTime()) then
		self:SetAbilityNextFire(CurTime() + self.AbilityCooldown)
		local failed = self:TriggerAbility()
		if failed then
			self:SetAbilityNextFire(0)
		end
	end
end

function ENT:AddPops(pops)
	self:SetPops(self:GetPops()+pops)
end

function ENT:AddCash(cash, ply)
	local incomeCash = cash * ROTGB_GetConVarValue("rotgb_tower_income_mul") * ROTGB_GetConVarValue("rotgb_cash_mul")
	ROTGB_AddCash(incomeCash, ply)
	self:SetCashGenerated(self:GetCashGenerated()+incomeCash)
end

local function UpgradeMenu(ent)

	if not IsValid(ent) then return end
	if not ent.SellAmount then
		ent.SellAmount = ent.Cost and ROTGB_ScaleBuyCost(ent.Cost) or 0
	end
	
	local Main = vgui.Create("DFrame")
	Main:SetSize(ScrH()/2,ScrH()/2)
	Main:Center()
	Main:SetTitle("Upgrades List")
	Main:SetSizable(true)
	Main:MakePopup()
	function Main:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_translucent)
		if self:HasFocus() then
			draw.RoundedBox(8,0,0,w,24,color_black)
		end
	end
	Main.SetOfUpgrades = {}
	function Main:Refresh(bool)
		--[[ this is kinda complicated
		first, order the bought upgrades so that the highest tier is first in the table, then the second highest, etc.
		so 0-3-0-3 becomes 3-3-0-0
		
		then, calculate upgrade limits
		4 <= 5 -> 5
		4 <= 4 -> 5
		1 <= 3 -> 3
		0 <= 0 -> 0
		]]
		local ctiers = {}
		for k,v in pairs(self.SetOfUpgrades) do
			table.insert(ctiers,{v.Tier-1,v})
		end
		table.SortByMember(ctiers,1)
		--[[for i,v in ipairs(ctiers) do
			local pathLevel = v[1]
			local prevPath = ctiers[i-1] or {}
			local prevPathLevel, prevPathUpgrade = prevPath[1], prevPath[2]
			local prevPathUpgradeEnabled = not prevPathUpgrade or prevPathUpgrade:IsEnabled()
			local dontLock = pathLevel < ent.UpgradeLimits[i] or (prevPathUpgradeEnabled and prevPathLevel == pathLevel)
			local enabled = dontLock or ROTGB_GetConVarValue("rotgb_ignore_upgrade_limits") or ent:GetNWFloat("rotgb_noupgradelimit") >= CurTime()
			v[2]:SetEnabled(enabled)
		end]]
		local slot = 1
		for i,v in ipairs(ctiers) do
			v[2].MaxTier = ent.UpgradeLimits[slot]
			if v[1] > (ent.UpgradeLimits[i+1] or 0) then slot = i + 1 end
		end
		for k,v in pairs(ctiers) do
			v[2]:SetEnabled(v[1] < v[2].MaxTier or ROTGB_GetConVarValue("rotgb_ignore_upgrade_limits") or ent:GetNWFloat("rotgb_noupgradelimit") >= CurTime())
		end
		if bool then
			for k,v in pairs(self.SetOfUpgrades) do
				v:Refresh()
			end
		end
	end
	
	local ListOfUpgrades = vgui.Create("DScrollPanel",Main)
	ListOfUpgrades:Dock(FILL)
	
	local reference = ent.UpgradeReference
	
	local SellButton = vgui.Create("DButton",Main)
	SellButton:SetText("Sell / Remove ($"..string.Comma(math.floor(ent.SellAmount*0.8))..")")
	SellButton:SetTextColor(color_red)
	SellButton:SetFont("DermaLarge")
	SellButton:SetTall(32)
	SellButton:Dock(BOTTOM)
	function SellButton:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,self:IsHovered() and color_gray_translucent or color_black_translucent)
	end
	function SellButton:DoClick()
		if not IsValid(ent) then
			Main:Close()
			return CauseNotification("Tower is invalid!")
		end
		Derma_Query("Are you sure you want to sell this tower?","Are you sure?",
		"Yes",function()
			if IsValid(ent) then
				if IsValid(Main) then Main:Close() end
				net.Start("rotgb_openupgrademenu")
				net.WriteEntity(ent)
				net.WriteUInt(11,4)
				net.SendToServer()
			end
		end,"No")
	end
	
	for i=0,#reference-1 do -- make this zero-indexed
		
		local curcash = ROTGB_GetCash(LocalPlayer())
		local reftab = reference[i+1]
		local upgradenum = #reftab.Prices
		local UpgradeStatement = ListOfUpgrades:Add("DButton")
		UpgradeStatement:SetSize(128,128)
		UpgradeStatement:DockMargin(0,0,0,5)
		UpgradeStatement:Dock(TOP)
		UpgradeStatement:SetContentAlignment(7)
		UpgradeStatement:SetWrap(true)
		UpgradeStatement:SetDoubleClickingEnabled(false)
		function UpgradeStatement:Refresh(bool)
			if not IsValid(ent) then
				Main:Close()
				return CauseNotification("Tower is invalid!")
			end
			self.Tier = self.Tier or bit.rshift(ent:GetUpgradeStatus(),i*4)%16+1
			self:SetText(not reftab.Descs[self.Tier] and "\n\nThis path has been fully upgraded!" or not self:IsEnabled() and "\n\nThis path is locked due to the purchase of a certain upgrade!" or ("\n\n"..reftab.Descs[self.Tier]))
			self:SetTextColor(not reftab.Descs[self.Tier] and color_green or not self:IsEnabled() and color_red or color_white)
			Main:Refresh(bool)
			SellButton:SetText("Sell / Remove ($"..string.Comma(math.floor(ent.SellAmount*0.8))..")")
		end
		function UpgradeStatement:Paint(w,h)
			curcash = ROTGB_GetCash(LocalPlayer())
			draw.RoundedBox(8,0,0,w,h,self:IsHovered() and color_gray_translucent or color_black_translucent)
			draw.SimpleText(not reftab.Names[self.Tier] and "Fully Upgraded!" or not self:IsEnabled() and "Path Locked!" or reftab.Names[self.Tier],"DermaLarge",0,0,not reftab.Names[self.Tier] and color_green or not self:IsEnabled() and color_red or color_white)
			if reftab.Prices[self.Tier] and self:IsEnabled() then
				local price = ROTGB_ScaleBuyCost(reftab.Prices[self.Tier])
				draw.SimpleText("Price: "..string.Comma(math.ceil(price)),"DermaLarge",w,0,price>curcash and color_red or color_green,TEXT_ALIGN_RIGHT)
			end
		end
		function UpgradeStatement:DoClick()
			if not IsValid(ent) then
				Main:Close()
				return CauseNotification("Tower is invalid!")
			end
			if not reftab.Prices[self.Tier] then return CauseNotification("Upgrade is invalid!") end
			local price = ROTGB_ScaleBuyCost(reftab.Prices[self.Tier])
			if curcash<price then return CauseNotification("You need $"..string.Comma(math.ceil(price-curcash)).." more to buy this upgrade!") end
			if (reftab.Funcs and reftab.Funcs[self.Tier]) then
				reftab.Funcs[self.Tier](ent)
			end
			net.Start("rotgb_openupgrademenu")
			net.WriteEntity(ent)
			net.WriteUInt(i,4)
			net.WriteUInt(0,4)
			net.SendToServer()
			ent.SellAmount = (ent.SellAmount or 0) + price
			self.Tier = self.Tier + 1
			self:Refresh(true)
		end
		
		local UpgradeIndicatorPanel = UpgradeStatement:Add("DPanel")
		UpgradeIndicatorPanel:SetTall(24)
		UpgradeIndicatorPanel:Dock(BOTTOM)
		function UpgradeIndicatorPanel:Paint() end
		
		for j=1,upgradenum do
			local HoverButton = UpgradeIndicatorPanel:Add("DButton")
			HoverButton:SetWide(24)
			HoverButton:SetText("")
			HoverButton:SetTooltip(reftab.Names[j].." ($"..string.Comma(math.ceil(reftab.Prices[j]))..")\n"..reftab.Descs[j])
			HoverButton:DockMargin(0,0,8,0)
			HoverButton:Dock(LEFT)
			HoverButton.RequiredAmount = 0
			function HoverButton:Paint(w,h)
				if self.Tier ~= UpgradeStatement.Tier then
					self.Tier = UpgradeStatement.Tier
					self.RequiredAmount = self:GetRequiredAmount()
				end
				local canAfford = curcash >= self.RequiredAmount
				local drawColor
				local pulser = math.sin(CurTime()*math.pi*2)/2+0.5
				if j==self.Tier then
					if j>UpgradeStatement.MaxTier then
						drawColor = color_red
					elseif canAfford then
						drawColor = HSVToColor(60, 1-pulser, 1)
					else
						drawColor = color_yellow
					end
				else
					if j>UpgradeStatement.MaxTier then
						drawColor = color_dark_red
					elseif j>self.Tier then
						drawColor = canAfford and HSVToColor(0, 0, pulser/2+0.5) or color_gray
					else
						drawColor = color_green
					end
				end
				draw.RoundedBox(8,0,0,w,h,drawColor)
			end
			function HoverButton:GetRequiredAmount()
				if not self.Tier then return math.huge end
				if j < self.Tier then return 0 end
				local cost = 0
				for k=self.Tier,j do
					cost = cost + ROTGB_ScaleBuyCost(reftab.Prices[k])
				end
				return cost
			end
			function HoverButton:DoClick()
				if not IsValid(ent) then
					Main:Close()
					return CauseNotification("Tower is invalid!")
				end
				if UpgradeStatement.MaxTier < j then return end
				local moreCashNeeded = self.RequiredAmount - curcash
				if moreCashNeeded>0 then return CauseNotification("You need "..ROTGB_FormatCash(moreCashNeeded, true).." more to buy this upgrade!") end
				for k=self.Tier,j do
					if (reftab.Funcs and reftab.Funcs[k]) then
						reftab.Funcs[k](ent)
					end
					UpgradeStatement.Tier = UpgradeStatement.Tier + 1
				end
				net.Start("rotgb_openupgrademenu")
				net.WriteEntity(ent)
				net.WriteUInt(i,4)
				net.WriteUInt(j-self.Tier,4)
				net.SendToServer()
				ent.SellAmount = (ent.SellAmount or 0) + self.RequiredAmount
				UpgradeStatement:Refresh(true)
			end
		end
		
		UpgradeStatement:Refresh()
		table.insert(Main.SetOfUpgrades,UpgradeStatement)
		
	end
	
	local TargetButton = vgui.Create("DButton",Main)
	TargetButton.CurSetting = ent:GetTargeting()
	TargetButton:SetText(ent.UserTargeting and "Targeting: "..buttonlabs[TargetButton.CurSetting+1] or "Targeting: Ambiguous")
	TargetButton:SetTextColor(ent.UserTargeting and color_white or color_gray)
	TargetButton:SetFont("DermaLarge")
	TargetButton:SetContentAlignment(5)
	TargetButton:SetTall(32)
	TargetButton:Dock(BOTTOM)
	function TargetButton:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,self:IsHovered() and ent.UserTargeting and color_gray_translucent or color_black_translucent)
	end
	function TargetButton:DoClick()
		if not IsValid(ent) then
			Main:Close()
			return CauseNotification("Tower is invalid!")
		end
		if input.IsShiftDown() then
			self.CurSetting = (self.CurSetting-1)%#buttonlabs
			net.Start("rotgb_openupgrademenu")
			net.WriteEntity(ent)
			net.WriteUInt(9,4)
			net.SendToServer()
		else
			self.CurSetting = (self.CurSetting+1)%#buttonlabs
			net.Start("rotgb_openupgrademenu")
			net.WriteEntity(ent)
			net.WriteUInt(8,4)
			net.SendToServer()
		end
		self:SetText(ent.UserTargeting and "Targeting: "..buttonlabs[self.CurSetting+1] or "Targeting: Ambiguous")
		self:SetTextColor(ent.UserTargeting and color_white or color_gray)
	end
	function TargetButton:DoRightClick()
		if not IsValid(ent) then
			Main:Close()
			return CauseNotification("Tower is invalid!")
		end
		if not ent.UserTargeting then return end
		local TargetMenu = DermaMenu(self)
		for i=1,#buttonlabs do
			local Option = TargetMenu:AddOption(buttonlabs[i],function()
				self.CurSetting = i-1
				net.Start("rotgb_openupgrademenu")
				net.WriteEntity(ent)
				net.WriteUInt(10,4)
				net.WriteUInt(i-1,4)
				net.SendToServer()
				self:SetText(ent.UserTargeting and "Targeting: "..buttonlabs[self.CurSetting+1] or "Targeting: Ambiguous")
				self:SetTextColor(ent.UserTargeting and color_white or color_gray)
			end)
			Option:SetIcon("icon16/"..icns[i]..".png")
		end
		TargetMenu:Open()
	end
	
	local InfoButton = vgui.Create("DButton",Main)
	InfoButton.CurrentPops = ent:GetPops()
	InfoButton.CurrentCash = ent:GetCashGenerated()
	if InfoButton.CurrentCash > 0 then
		InfoButton:SetText("Damage: "..string.Comma(InfoButton.CurrentPops).." | Cash: "..string.Comma(math.floor(InfoButton.CurrentCash)))
	else
		InfoButton:SetText("Damage: "..string.Comma(InfoButton.CurrentPops))
	end
	InfoButton:SetTextColor(color_white)
	InfoButton:SetFont("DermaLarge")
	InfoButton:SetContentAlignment(5)
	InfoButton:SetTall(32)
	InfoButton:Dock(BOTTOM)
	function InfoButton:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_translucent)
		if (IsValid(ent) and (self.CurrentPops ~= ent:GetPops() or self.CurrentCash ~= ent:GetCashGenerated())) then
			self.CurrentPops = ent:GetPops()
			self.CurrentCash = ent:GetCashGenerated()
			if self.CurrentCash > 0 then
				self:SetText("Damage: "..string.Comma(self.CurrentPops).." | Cash: "..string.Comma(math.floor(self.CurrentCash)))
			else
				self:SetText("Damage: "..string.Comma(self.CurrentPops))
			end
		end
	end
	
	Main:Refresh(true)
	
end

ENT.ROTGB_OnRemove = ENT.ROTGB_Initialize

function ENT:OnRemove()
	self:ROTGB_OnRemove()
	if SERVER then
		ROTGB_AddCash((self.SellAmount or 0)*0.8,self:GetTowerOwner())
	end
end

net.Receive("rotgb_openupgrademenu",function(length,ply)
	if CLIENT then
		local ent = net.ReadEntity()
		if IsValid(ent) then
			local op = net.ReadUInt(2)
			if op == ROTGB_TOWER_MENU then
				UpgradeMenu(ent)
			elseif op == ROTGB_TOWER_UPGRADE then
				-- get path number and upgrade amount
				local path = net.ReadUInt(4)
				local upgradeAmount = net.ReadUInt(4)+1
				
				local reference = ent.UpgradeReference[path+1]
				if not reference then return end
				local tier = bit.rshift(ent:GetUpgradeStatus(),path*4)%16+1
				for i=1,upgradeAmount do
					local price = ROTGB_ScaleBuyCost(reference.Prices[tier])
					ent.SellAmount = (ent.SellAmount or 0) + price
					if (reference.Funcs and reference.Funcs[tier]) then
						reference.Funcs[tier](ent)
					end
					tier = tier + 1
				end
				ent:SetUpgradeStatus(ent:GetUpgradeStatus()+bit.lshift(upgradeAmount,path*4))
			end
		else
			CauseNotification("You can't tamper with someone else's tower!")
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
			local price = ROTGB_ScaleBuyCost(reference.Prices[tier])
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
		if caller == self:GetTowerOwner() then
			net.Start("rotgb_openupgrademenu")
			net.WriteEntity(self)
			net.WriteUInt(ROTGB_TOWER_MENU, 2)
			net.Send(caller)
		else
			net.Start("rotgb_openupgrademenu")
			net.Send(caller)
		end
	end	
end

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