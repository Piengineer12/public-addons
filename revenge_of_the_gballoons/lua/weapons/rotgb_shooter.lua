AddCSLuaFile()

--SWEP.Base = "weapon_base"
SWEP.PrintName = "Balloon Shooter ($650)"
SWEP.Category = "RotgB"
SWEP.Author = "Piengineer"
SWEP.Contact = "http://steamcommunity.com/id/Piengineer12/"
SWEP.Purpose = "A SWEP for shooting down gBalloons. Can be upgraded."
--SWEP.Instructions = ""
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.ViewModel = "models/weapons/v_irifle.mdl"
--SWEP.ViewModelFOV = 62
--SWEP.ViewModelFlip = false
--SWEP.ViewModelFlip1 = false
--SWEP.ViewModelFlip2 = false
SWEP.Spawnable = true
--SWEP.AdminOnly = false
SWEP.Slot = 1
--SWEP.SlotPos = 10
--SWEP.BounceWeaponIcon = true
--SWEP.DrawAmmo = true
--SWEP.DrawCrosshair = true
--SWEP.AccurateCrosshair = false
--SWEP.DrawWeaponInfoBox = true
--SWEP.WepSelectIcon = surface.GetTextureID("weapons/swep")
--SWEP.SpeechBubbleLid = surface.GetTextureID("gui/speech_lid")
SWEP.AutoSwitchFrom = false
SWEP.AutoSwitchTo = false
--SWEP.Weight = 5
--SWEP.CSMuzzleFlashes = false
--SWEP.CSMuzzleX = false
--SWEP.BobScale = 1
--SWEP.SwayScale = 1
SWEP.UseHands = true
--SWEP.m_WeaponDeploySpeed = 1
--SWEP.m_bPlayPickupSound = true
--SWEP.RenderGroup = RENDERGROUP_OPAQUE
--SWEP.ScriptedEntityType = "weapon"
--SWEP.IconOverride = "materials/entities/base.png"
--SWEP.DisableDuplicator = false
SWEP.Primary = {
	Ammo = "AR2",
	ClipSize = 100,
	DefaultClip = 0,
	Automatic = true
}
SWEP.Secondary = {
	Ammo = "none",
	ClipSize = -1,
	DefaultClip = -1,
	Automatic = false
}
SWEP.CustomAmmo = {
	Draw = true,
	PrimaryAmmo = 100,
	SecondaryAmmo = 0
}
SWEP.FireRate = 4
SWEP.AttackDamage = 10
SWEP.Spread = 0
SWEP.BulletNum = 1
SWEP.SpeedMultiplier = 1
SWEP.OldSpeedMultiplier = 1
SWEP.rotgb_AutoTargets = 0
SWEP.rotgb_Explode = 0
SWEP.rotgb_BulletPairs = 0
SWEP.rotgb_BlimpMul = 1
SWEP.rotgb_CritChance = 0
SWEP.rotgb_CritMul = 2
SWEP.rotgb_FireRate = 1
SWEP.rotgb_HomingBullets = 0
SWEP.PartOrder = {"case", "ammo", "grip"}
SWEP.TargetingOptions = {"First","Last","Strong","Weak","Close","Far","Fast","Slow"}
SWEP.TargetingIcons = {"shape_move_front","shape_move_back","award_star_gold_3","award_star_bronze_1","connect","disconnect","control_fastforward_blue","control_play"}
SWEP.UpgradeReference = {
	majorLevels = {[10]=1,[20]=2,[35]=3,[50]=4,[75]=5,[100]=6},
	case = {
		desc = {
			"+1% movement speed",
			"x2 fire rate",
			"x2 fire rate",
			"+1 auto-pop target",
			"x2 auto-pop targets",
			"x2 auto-pop targets",
			"x4 damage"
		},
		func = {
			function(self, level)
				self.SpeedMultiplier = 1+level/100
			end,
			function(self)
				self.rotgb_FireRate = self.rotgb_FireRate * 2
			end,
			function(self)
				self.rotgb_FireRate = self.rotgb_FireRate * 2
			end,
			function(self)
				self.rotgb_AutoTargets = self.rotgb_AutoTargets + 1
			end,
			function(self)
				self.rotgb_AutoTargets = self.rotgb_AutoTargets * 2
			end,
			function(self)
				self.rotgb_AutoTargets = self.rotgb_AutoTargets * 2
			end,
			function(self)
				self.SpeedMultiplier = 1
				self.rotgb_AutoTargets = self.rotgb_AutoTargets / 4 - 1
				self.rotgb_FireRate = self.rotgb_FireRate / 4
				self.AttackDamage = self.AttackDamage * 4
			end
		}
	},
	ammo = {
		desc = {
			"+1% fire rate",
			"+Gray gBalloon poppage",
			"x2 damage",
			"x3 non-homing bullets",
			"x3 non-homing bullets",
			"+Redirectional bullets",
			"x4 gBlimp damage"
		},
		func = {
			function(self, level)
				self.FireRate = 4+level/25
			end,
			function(self)
				self.rotgb_GrayPop = true
			end,
			function(self)
				self.AttackDamage = self.AttackDamage * 2
			end,
			function(self)
				self.rotgb_BulletPairs = self.rotgb_BulletPairs + 1
			end,
			function(self)
				self.rotgb_BulletPairs = self.rotgb_BulletPairs + 3
			end,
			function(self)
				self.rotgb_BulletPairHoming = true
			end,
			function(self)
				self.FireRate = 4
				self.rotgb_GrayPop = false
				self.rotgb_BulletPairs = self.rotgb_BulletPairs - 4
				self.rotgb_BulletPairHoming = false
				self.rotgb_BlimpMul = self.rotgb_BlimpMul * 4
			end
		}
	},
	grip = {
		desc = {
			"+1% crit chance",
			"x2 crit damage",
			"x2 crit damage",
			"+1 homing bullet",
			"x2 homing bullets",
			"x2 homing bullets",
			"x4 crit damage"
		},
		func = {
			function(self, level)
				self.rotgb_CritChance = level/100
			end,
			function(self)
				self.rotgb_CritMul = self.rotgb_CritMul * 2
			end,
			function(self)
				self.rotgb_CritMul = self.rotgb_CritMul * 2
			end,
			function(self)
				self.rotgb_HomingBullets = self.rotgb_HomingBullets + 1
			end,
			function(self)
				self.rotgb_HomingBullets = self.rotgb_HomingBullets * 2
			end,
			function(self)
				self.rotgb_HomingBullets = self.rotgb_HomingBullets * 2
			end,
			function(self)
				self.rotgb_CritChance = 0
				self.rotgb_HomingBullets = self.rotgb_HomingBullets / 4 - 1
			end
		}
	}
}

local ROTGB_UPGRADE = 1
local ROTGB_TARGETING = 2
local ROTGB_SELL = 3

if SERVER then
	net.Receive("rotgb_shooter", function(length, ply)
		local wep = ply:GetActiveWeapon()
		if (IsValid(wep) and wep:GetClass()=="rotgb_shooter") then
			local operation = net.ReadUInt(4)
			if operation == ROTGB_UPGRADE then
				local part = wep.PartOrder[net.ReadUInt(2)]
				if part then
					local reftab = wep.UpgradeReference
					local level = wep:GetPartLevel(part)
					local cost = wep:GetCost(level)
					if ROTGB_GetCash(ply) < cost then return end
					wep.SellAmount = (wep.SellAmount or 0) + cost
					
					local effectiveNextLevel = level % 100 + 1
					local majorLevel = reftab.majorLevels[effectiveNextLevel]
					if majorLevel then
						reftab[part].func[majorLevel+1](wep)
						if effectiveNextLevel~=100 then
							reftab[part].func[1](wep, effectiveNextLevel)
						end
					else
						reftab[part].func[1](wep, effectiveNextLevel)
					end
					
					ROTGB_RemoveCash(cost, ply)
					wep:AddPartLevel(part)
				end
			elseif operation == ROTGB_TARGETING then
				local mode = net.ReadUInt(2)
				if mode == 0 then
					local nextTargeting = (wep:GetTargeting()+1) % #wep.TargetingOptions
					wep:SetTargeting(nextTargeting)
				elseif mode == 1 then
					local nextTargeting = (wep:GetTargeting()-1) % #wep.TargetingOptions
					wep:SetTargeting(nextTargeting)
				elseif mode == 2 then
					local targeting = net.ReadUInt(4)
					local nextTargeting = targeting % #wep.TargetingOptions
					wep:SetTargeting(nextTargeting)
				end
			elseif operation == ROTGB_SELL then
				wep:Remove()
			end
		end
	end)
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "CaseLevel")
	self:NetworkVar("Int", 1, "AmmoLevel")
	self:NetworkVar("Int", 2, "GripLevel")
	self:NetworkVar("Int", 3, "Pops")
	self:NetworkVar("Int", 4, "Targeting")
end

function SWEP:Initialize()
	self.Initialized = true
	self:SetHoldType("ar2")
	self.Levels = {case = self:GetCaseLevel(), ammo = self:GetAmmoLevel(), grip = self:GetGripLevel()}
end

function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		local ply = self:GetOwner()
		if SERVER then
			local isCrit = math.random() < self.rotgb_CritChance
			local damage = self.AttackDamage * (isCrit and self.rotgb_CritMul or 1)
			local direction = ply:GetAimVector()
			local bullet = {
				Num = self.BulletNum,
				Src = ply:GetShootPos(),
				Dir = direction,
				Spread = Vector(self.Spread, self.Spread, 0),
				Tracer = 1,
				TracerName = "AR2Tracer",
				Force = damage,
				Damage = damage,
				AmmoType = "AR2",
				Callback = function(atk, trace, dmginfo)
					if IsValid(self) then 
						dmginfo:SetInflictor(self)
						local ent = trace.Entity
						if ent:IsPlayer() then
							dmginfo:ScaleDamage(0)
						elseif (IsValid(ent) and ent:GetClass()=="gballoon_base" and ent:GetBalloonProperty("BalloonBlimp")) then
							dmginfo:ScaleDamage(self.rotgb_BlimpMul)
						end
						if self.rotgb_GrayPop then
							dmginfo:SetDamageType(DMG_GENERIC)
						end
						if trace.Hit then
							self:TriggerHitEffects(trace.HitPos, isCrit)
						end
					end
				end
			}
			
			if self.rotgb_BulletPairHoming then
				self:RedirectBullet(bullet)
			end
			ply:FireBullets(bullet)
			
			for i=1,self.rotgb_BulletPairs do
				for j=i*-2.5,i*2.5,i*5 do
					bullet.Dir = Vector(direction.x, direction.y, direction.z)
					bullet.Dir:Rotate(Angle(0,j,0))
					if self.rotgb_BulletPairHoming then
						self:RedirectBullet(bullet)
					end
					ply:FireBullets(bullet)
				end
			end
			
			if self.rotgb_HomingBullets > 0 then
				self:DoHomingShot(bullet)
			end
		end
		
		self:EmitSound("Weapon_AR2.Single")
		ply:MuzzleFlash()
		ply:SetAnimation(PLAYER_ATTACK1)
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		
		self:ROTGB_SetLastShootTime()
		self:CallOnClient("ROTGB_SetLastShootTime")
		local fireDelay = 1/(self.FireRate*self.rotgb_FireRate)
		if self:GetNextPrimaryFire() + fireDelay/2 < CurTime() then
			self:SetNextPrimaryFire(CurTime() + fireDelay)
		else
			self:SetNextPrimaryFire(self:GetNextPrimaryFire() + fireDelay)
		end
	end
end

function SWEP:CanPrimaryAttack()
	return tobool(self.SellAmount)
end

function SWEP:ROTGB_SetLastShootTime()
	self:SetLastShootTime(CurTime())
end

function SWEP:CanSecondaryAttack()
	return CLIENT and self:GetOwner() == LocalPlayer()
end

function SWEP:SecondaryAttack()
	if game.SinglePlayer() then self:CallOnClient("SecondaryAttack") end
	if self:CanSecondaryAttack() then
		if IsValid(self.UpgradeMenu) then
			if self.UpgradeMenu:IsVisible() then
				self.UpgradeMenu:Hide()
			else
				self.UpgradeMenu:Show()
				self.UpgradeMenu:MakePopup()
			end
		else
			self:CreateUpgradeMenu()
		end
	end
end

local function CauseNotification(msg)
	notification.AddLegacy(msg,NOTIFY_ERROR,5)
	surface.PlaySound("buttons/button10.wav")
end

function SWEP:Think()
	local delta = math.Remap(CurTime(), self:LastShootTime(), self:GetNextPrimaryFire(), 0, 100)
	self:SetClip1(math.Clamp(delta, 0, 100))
	
	if not self.Initialized then
		self:Initialize()
	end
	
	if self.rotgb_OwnerTemp ~= self:GetOwner() and IsValid(self:GetOwner()) then
		self.rotgb_OwnerTemp = self:GetOwner()
		if not self.SellAmount then
			local cost = ROTGB_ScaleBuyCost(650)
			if ROTGB_GetCash(self.rotgb_OwnerTemp) >= cost then
				if SERVER then
					ROTGB_RemoveCash(cost, self.rotgb_OwnerTemp)
				end
				self.SellAmount = cost
			elseif SERVER then
				self:Remove()
			elseif not self.NotifiedNotEnough then
				self.NotifiedNotEnough = true
				CauseNotification("You need "..ROTGB_FormatCash(cost-ROTGB_GetCash(self.rotgb_OwnerTemp), true).." more to buy this weapon!")
			end
		end
	end
	
	if self.OldSpeedMultiplier ~= self.SpeedMultiplier then
		local owner = self:GetOwner()
		local mul = self.SpeedMultiplier / self.OldSpeedMultiplier
		
		owner:SetWalkSpeed(owner:GetWalkSpeed()*mul)
		owner:SetRunSpeed(owner:GetRunSpeed()*mul)
		owner:SetSlowWalkSpeed(owner:GetSlowWalkSpeed()*mul)
		owner:SetLadderClimbSpeed(owner:GetLadderClimbSpeed()*mul)
		
		self.OldSpeedMultiplier = self.SpeedMultiplier
	end
	
	self:DoAutoPop()
end

function SWEP:Reload()
end

function SWEP:OnRemove()
	if IsValid(self.UpgradeMenu) then
		self.UpgradeMenu:Close()
	end
	if IsValid(self.rotgb_OwnerTemp) then
		if self.OldSpeedMultiplier ~= 1 then
			local owner = self.rotgb_OwnerTemp
			local mul = 1 / self.OldSpeedMultiplier
			
			owner:SetWalkSpeed(owner:GetWalkSpeed()*mul)
			owner:SetRunSpeed(owner:GetRunSpeed()*mul)
			owner:SetSlowWalkSpeed(owner:GetSlowWalkSpeed()*mul)
			owner:SetLadderClimbSpeed(owner:GetLadderClimbSpeed()*mul)
			self.OldSpeedMultiplier = 1
		end
		
		ROTGB_AddCash((self.SellAmount or 0) * 0.8 * GetConVar("rotgb_cash_mul"):GetFloat(), owner)
		
	end
end

function SWEP:Holster()
	if IsValid(self.UpgradeMenu) then
		self.UpgradeMenu:Hide()
	end
	if self.OldSpeedMultiplier ~= 1 and IsValid(self.rotgb_OwnerTemp) then
		local owner = self.rotgb_OwnerTemp
		local mul = 1 / self.OldSpeedMultiplier
		
		owner:SetWalkSpeed(owner:GetWalkSpeed()*mul)
		owner:SetRunSpeed(owner:GetRunSpeed()*mul)
		owner:SetSlowWalkSpeed(owner:GetSlowWalkSpeed()*mul)
		owner:SetLadderClimbSpeed(owner:GetLadderClimbSpeed()*mul)
		
		self.OldSpeedMultiplier = 1
	end
	return true
end

function SWEP:CustomAmmoDisplay()
	self.CustomAmmo.PrimaryClip = self:Clip1()
	return self.CustomAmmo
end

function SWEP:DoDrawCrosshair(x, y)
	local barWidth = ScrW()/256
	local barHeight = ScrH()/16
	local thickness = 1
	
	local firstBarX = x - barHeight*2 - barWidth
	local secondBarX = x + barHeight*2
	local barY = y - barHeight/2
	
	surface.SetDrawColor(0,127,255)
	surface.DrawOutlinedRect(firstBarX, barY, barWidth, barHeight, thickness)
	if self:HasUserTargeting() then
		local delta = math.Clamp(math.Remap(CurTime(), self.rotgb_LastAutoPop or CurTime(), self.rotgb_NextAutoPop or CurTime() + 1/(self.FireRate*self.rotgb_FireRate), 0, 1), 0, 1)
		local newHeight = math.floor(delta * (barHeight-thickness*2))
		local hue = delta * 120
		surface.SetDrawColor(HSVToColor(hue, 1, 1))
		surface.DrawRect(firstBarX+thickness, barY+barHeight-thickness-newHeight, barWidth-thickness*2, newHeight)
	end
	
	surface.SetDrawColor(255,127,0)
	surface.DrawOutlinedRect(secondBarX, barY, barWidth, barHeight, thickness)
	local delta = math.Clamp(math.Remap(CurTime(), self:LastShootTime(), self:GetNextPrimaryFire(), 0, 1), 0, 1)
	local newHeight = math.floor(delta * (barHeight-thickness*2))
	local hue = delta * 120
	surface.SetDrawColor(HSVToColor(hue, 1, 1))
	surface.DrawRect(secondBarX+thickness, barY+barHeight-thickness-newHeight, barWidth-thickness*2, newHeight)
end

local gballoonTable = scripted_ents.Get("gballoon_base")
function SWEP:GetgBalloonScores()
	self.rotgb_balloonTable = self.rotgb_balloonTable or {}
	table.Empty(self.rotgb_balloonTable)
	gballoonTable = gballoonTable or scripted_ents.Get("gballoon_base")
	local mode = self:GetTargeting()
	local selfpos = IsValid(self:GetOwner()) and self:GetOwner():GetPos() or self:GetPos()
	for k,v in pairs(gballoonTable:GetgBalloons()) do
		if mode==0 then
			self.rotgb_balloonTable[v] = v:GetDistanceTravelled()
		elseif mode==1 then
			self.rotgb_balloonTable[v] = -v:GetDistanceTravelled()
		elseif mode==2 then
			self.rotgb_balloonTable[v] = v:GetRgBE()
		elseif mode==3 then
			self.rotgb_balloonTable[v] = -v:GetRgBE()
		elseif mode==4 then
			self.rotgb_balloonTable[v] = v:BoundingRadius()^2/v:GetPos():DistToSqr(selfpos)
		elseif mode==5 then
			self.rotgb_balloonTable[v] = -v:BoundingRadius()^2/v:GetPos():DistToSqr(selfpos)
		elseif mode==6 then
			self.rotgb_balloonTable[v] = v.loco:GetAcceleration()
		elseif mode==7 then
			self.rotgb_balloonTable[v] = -v.loco:GetAcceleration()
		end
	end
	
	return self.rotgb_balloonTable
end

function SWEP:DoAutoPop()
	if (self.rotgb_NextAutoPop or 0) <= CurTime() and self.rotgb_AutoTargets > 0 then
		self.rotgb_LastAutoPop = self.rotgb_NextAutoPop
		self.rotgb_NextAutoPop = CurTime() + 1/(self.FireRate*self.rotgb_FireRate)
		
		if SERVER then
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(self:GetOwner())
			dmginfo:SetInflictor(self)
			dmginfo:SetDamage(self.AttackDamage)
			dmginfo:SetDamageType(self.rotgb_GrayPop and DMG_GENERIC or DMG_BULLET)
			dmginfo:SetAmmoType(game.GetAmmoID("AR2"))
			dmginfo:SetReportedPosition(self:GetOwner():GetPos())
			
			local targeted = 0
			for k,v in SortedPairsByValue(self:GetgBalloonScores(),true) do
				local isCrit = math.random() < self.rotgb_CritChance
				
				if isCrit then
					dmginfo:ScaleDamage(self.rotgb_CritMul)
				end
				if k:GetBalloonProperty("BalloonBlimp") then
					dmginfo:ScaleDamage(self.rotgb_BlimpMul)
				end
				
				dmginfo:SetDamagePosition(k:GetPos())
				k:TakeDamageInfo(dmginfo)
				self:TriggerHitEffects(k:GetPos(), isCrit)
				
				if isCrit then
					dmginfo:ScaleDamage(1/self.rotgb_CritMul)
				end
				if k:GetBalloonProperty("BalloonBlimp") then
					dmginfo:ScaleDamage(1/self.rotgb_BlimpMul)
				end
				
				targeted = targeted + 1
				if targeted >= self.rotgb_AutoTargets then break end
			end
		end
	end
end

function SWEP:DoHomingShot(bullet)
	local ply = self:GetOwner()
	self.lastBalloonTrace = self.lastBalloonTrace or {}
	self.gBTraceData = self.gBTraceData or {
		filter = ply,
		mask = MASK_SHOT,
		output = self.lastBalloonTrace
	}
	self.gBTraceData.start = bullet.Src
	
	local targeted = 0
	for k,v in SortedPairsByValue(self:GetgBalloonScores(),true) do
		self.gBTraceData.endpos = k:GetPos()+k:OBBCenter()
		util.TraceLine(self.gBTraceData)
		if IsValid(self.lastBalloonTrace.Entity) and self.lastBalloonTrace.Entity:GetClass()=="gballoon_base" then
			local direction = self.gBTraceData.endpos
			direction:Sub(bullet.Src)
			direction:Normalize()
			bullet.Dir = direction
			ply:FireBullets(bullet)
			
			targeted = targeted + 1
			if targeted >= self.rotgb_HomingBullets then break end
		end
	end
end

function SWEP:RedirectBullet(bullet)
	self.lastBalloonTrace = self.lastBalloonTrace or {}
	self.gBTraceData = self.gBTraceData or {
		filter = ply,
		mask = MASK_SHOT,
		output = self.lastBalloonTrace
	}
	self.gBTraceData.start = bullet.Src
	self.gBTraceData.endpos = bullet.Dir * 56755
	self.gBTraceData.endpos:Add(bullet.Src)
	util.TraceLine(self.gBTraceData)
	if not (IsValid(self.lastBalloonTrace.Entity) and self.lastBalloonTrace.Entity:GetClass()=="gballoon_base") then
		-- scan through all gBalloons, see which one matches the vector the closest
		self.rotgb_balloonTable = self.rotgb_balloonTable or {}
		table.Empty(self.rotgb_balloonTable)
		for k,v in pairs(gballoonTable:GetgBalloons()) do
			self.gBTraceData.endpos = v:GetPos()+v:OBBCenter()
			util.TraceLine(self.gBTraceData)
			if IsValid(self.lastBalloonTrace.Entity) and self.lastBalloonTrace.Entity:GetClass()=="gballoon_base" then
				local direction = self.gBTraceData.endpos
				direction:Sub(bullet.Src)
				direction:Normalize()
				
				self.rotgb_balloonTable[v] = direction:Dot(bullet.Dir)
			end
		end
		
		if next(self.rotgb_balloonTable) then
			local bestgBalloon = table.GetWinningKey(self.rotgb_balloonTable)
			local direction = bestgBalloon:GetPos()+bestgBalloon:OBBCenter()
			direction:Sub(bullet.Src)
			direction:Normalize()
			bullet.Dir = direction
		end
	end
end

function SWEP:TriggerHitEffects(pos, isCrit)
	if isCrit then
		local effdata = EffectData()
		effdata:SetOrigin(pos)
		util.Effect("rotgb_crit", effdata)
	end
	
	--[[if self.rotgb_Explode > 0 then
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker(self:GetOwner())
		dmginfo:SetInflictor(self)
		dmginfo:SetDamage(self.AttackDamage * (isCrit and self.rotgb_CritMul or 1))
		dmginfo:SetDamageType(isCrit and DMG_GENERIC or DMG_BLAST)
		dmginfo:SetReportedPosition(self:GetOwner():GetPos())
		
		for k,v in pairs(ents.FindInSphere(pos, self.rotgb_Explode*8)) do
			if v:GetClass()=="gballoon_base" then
				if v:GetBalloonProperty("BalloonBlack") then
					v:ShowResistEffect(2)
				else
					if v:GetBalloonProperty("BalloonBlimp") then
						dmginfo:ScaleDamage(self.rotgb_BlimpMul)
					end
					
					v:TakeDamageInfo(dmginfo)
					
					if v:GetBalloonProperty("BalloonBlimp") then
						dmginfo:ScaleDamage(1/self.rotgb_BlimpMul)
					end
				end
			end
		end
		
		local effdata = EffectData()
		effdata:SetOrigin(pos)
		util.Effect("HelicopterMegaBomb", effdata)
	end]]
end

function SWEP:AddPops(pops)
	self:SetPops(self:GetPops()+pops)
end

function SWEP:AddPartLevel(part, amt)
	self.Levels[part] = self.Levels[part] + (amt or 1)
	if SERVER then
		if part == "case" then
			self:SetCaseLevel(self.Levels[part])
		elseif part == "ammo" then
			self:SetAmmoLevel(self.Levels[part])
		elseif part == "grip" then
			self:SetGripLevel(self.Levels[part])
		end
	end
end

function SWEP:GetPartLevel(part)
	return self.Levels[part] or 0
end

function SWEP:GetCost(level)
	local resets, localLevel = math.modf(level/100)
	localLevel = math.Round(localLevel*100 + 1)
	local cost = localLevel*5*10^resets
	if self.UpgradeReference.majorLevels[localLevel] then
		cost = cost * 10
	end
	
	return ROTGB_ScaleBuyCost(cost)
end

function SWEP:HasUserTargeting()
	return self.rotgb_HomingBullets > 0 or self.rotgb_AutoTargets > 0
end

local padding = 8
local buttonHeight = 48
local color_black_semiopaque = Color(0,0,0,191)
local color_black_translucent = Color(0,0,0,127)
local color_gray = Color(127,127,127)
local color_gray_translucent = Color(127,127,127,127)
local color_red = Color(255,0,0)
local color_light_red = Color(255,127,127)
local color_yellow = Color(255,255,0)
local color_green = Color(0,255,0)

local function PaintUpgradeBackground(self, w, h)
	draw.RoundedBox(8, 0, 0, w, h, color_black_translucent)
end

local function PaintBackground(self, w, h)
	draw.RoundedBox(8, 0, 0, w, h, color_black_semiopaque)
end

local function PaintButton(self, w, h)
	draw.RoundedBox(8,0,0,w,h,self:IsHovered() and color_gray_translucent or color_black_translucent)
end

function SWEP:DoNothing()
	-- needed for UI
end

function SWEP:CreateUpgradeMenu()
	self.Levels = {case = self:GetCaseLevel(), ammo = self:GetAmmoLevel(), grip = self:GetGripLevel()}
	
	local Main = vgui.Create("DFrame")
	Main:SetPos(0,0)
	Main:SetSize(ScrW(),ScrH())
	Main:DockPadding(padding,padding,padding,padding)
	Main.Paint = self.DoNothing
	Main:SetSizable(false)
	Main:SetDraggable(false)
	Main:MakePopup()
	function Main:CreateButton(text, parent, color1, color2, color3)
		local Button = vgui.Create("DButton", parent)
		Button:SetFont("Trebuchet24")
		Button:SetText(text)
		Button:SetColor(color_black)
		Button:SetTall(buttonHeight)
		
		function Button:Paint(w, h)
			draw.RoundedBox(8, 0, 0, w, h, not self:IsEnabled() and color_gray or self:IsDown() and color3 or self:IsHovered() and color2 or color1)
		end
		
		return Button
	end
	self.UpgradeMenu = Main
	
	local LeftDivider = vgui.Create("DHorizontalDivider", Main)
	LeftDivider:Dock(FILL)
	LeftDivider:SetDividerWidth(padding)
	LeftDivider:SetLeftWidth(ScrW()*0.2-padding/2)
	
	local RightDivider = vgui.Create("DHorizontalDivider")
	LeftDivider:SetRight(RightDivider)
	RightDivider:SetDividerWidth(padding)
	RightDivider:SetLeftWidth(ScrW()*0.6-padding/2)
	
	local InfoPanel, RightPanel = self:CreateRightPanel(Main)
	RightDivider:SetRight(RightPanel)
	LeftDivider:SetLeft(self:CreateLeftPanel(Main, InfoPanel))
	
	local MiddlePanel = vgui.Create("DPanel")
	RightDivider:SetLeft(MiddlePanel)
	MiddlePanel.Paint = self.DoNothing
	MiddlePanel:SetWorldClicker(true)
	
	local CloseButton = Main:CreateButton("Hide Menu", MiddlePanel, color_red, color_light_red, color_white)
	CloseButton:SizeToContentsX(buttonHeight-24)
	function CloseButton:DoClick()
		Main:Hide()
	end
	function MiddlePanel:PerformLayout(w, h)
		CloseButton:SetPos(w/2-CloseButton:GetWide()/2, h-CloseButton:GetTall())
	end
	
	Main:SetTitle("")
	Main:ShowCloseButton(false)
end

function SWEP:CreateLeftPanel(Main, InfoPanel)
	local wep = self
	local LeftPanel = vgui.Create("DPanel")
	LeftPanel.Paint = PaintUpgradeBackground
	LeftPanel:DockPadding(padding,padding,padding,padding)
	local OtherPanel = vgui.Create("DPanel", LeftPanel)
	
	local reftab = self.UpgradeReference
	function Main:GetUpgradeDescription(part, level)
		level = (level - 1) % 100 + 1
		if IsValid(wep) then
			local majorNum = reftab.majorLevels[level]
			if majorNum then
				if level == 100 then
					return "Reset this upgrade tree:\n"..reftab[part].desc[majorNum+1].."\nx10 upgrade costs"
				else return reftab[part].desc[1].."\n"..reftab[part].desc[majorNum+1]
				end
			else
				return reftab[part].desc[1]
			end
		else
			CauseNotification("Shooter is invalid!")
			Main:Close()
			return "<no description>"
		end
	end
	
	for i=1,3 do
		local part = self.PartOrder[i]
		local partNiceName = part:sub(1,1):upper()..part:sub(2)
		local level = self:GetPartLevel(part)
		local cost = self:GetCost(level)
		local curcash = ROTGB_GetCash(LocalPlayer())
		local UpgradeButton = vgui.Create("DButton", LeftPanel)
		local UpgradeIndicatorPanel = UpgradeButton:Add("DPanel")
		
		UpgradeButton:SetTall((ScrH()-padding*7)/4)
		UpgradeButton:SetContentAlignment(7)
		UpgradeButton:SetWrap(true)
		UpgradeButton:SetTextColor(color_white)
		UpgradeButton:SetDoubleClickingEnabled(false)
		UpgradeButton.Tier = 0
		for k,v in pairs(reftab.majorLevels) do
			if level % 100 >= k then
				UpgradeButton.Tier = math.max(UpgradeButton.Tier, v)
			end
		end
		UpgradeButton:DockMargin(0,0,0,padding)
		UpgradeButton:Dock(TOP)
		function UpgradeButton:Refresh()
			if not IsValid(wep) then
				Main:Close()
				return CauseNotification("Shooter is invalid!")
			end
			self:SetText("\n\n"..Main:GetUpgradeDescription(part, level+1))
			UpgradeIndicatorPanel:Refresh()
		end
		function UpgradeButton:Paint(w, h)
			PaintButton(self, w, h)
			if not IsValid(wep) then
				Main:Close()
				return CauseNotification("Shooter is invalid!")
			end
			curcash = ROTGB_GetCash(LocalPlayer())
			level = wep:GetPartLevel(part)
			local text = string.format("Level %u %s", level+1, partNiceName)
			if cost ~= wep:GetCost(level) then
				cost = wep:GetCost(level)
				UpgradeIndicatorPanel:Refresh()
			end
			
			draw.SimpleText(text,"DermaLarge",0,0,color_white)
			draw.SimpleText("Price: "..string.Comma(math.ceil(cost)),"DermaLarge",w,0,cost>curcash and color_red or color_green,TEXT_ALIGN_RIGHT)
		end
		function UpgradeButton:DoClick()
			if not IsValid(wep) then
				Main:Close()
				return CauseNotification("Shooter is invalid!")
			end
			if curcash<cost then return CauseNotification("You need "..ROTGB_FormatCash(cost-curcash, true).." more to buy this upgrade!") end
			
			local minorLevel = level % 100 + 1
			local majorLevel = reftab.majorLevels[minorLevel]
			if majorLevel then
				reftab[part].func[majorLevel+1](wep)
				self.Tier = self.Tier + 1
			end
			if minorLevel == 100 then
				self.Tier = 0
			else
				reftab[part].func[1](wep, minorLevel)
			end
			net.Start("rotgb_shooter")
			net.WriteUInt(ROTGB_UPGRADE,4)
			net.WriteUInt(i,2)
			net.SendToServer()
			wep.SellAmount = (wep.SellAmount or 0) + cost
			wep:AddPartLevel(part)
			level = level + 1
			self:Refresh()
			InfoPanel:Refresh()
			OtherPanel:Refresh()
		end
		UpgradeButton:Refresh()
		
		UpgradeIndicatorPanel:SetTall(24)
		UpgradeIndicatorPanel:Dock(BOTTOM)
		UpgradeIndicatorPanel.Paint = self.DoNothing
		UpgradeIndicatorPanel.HoverPanels = {}
		for j=1,6 do
			local minorLevel = level % 100 + 1
			local resets = math.floor(level/100)
			local majorLevel = table.KeyFromValue(reftab.majorLevels, j)
			local title = string.format("Level %u %s", majorLevel + resets*100, partNiceName)
			local upgradeCost = self:GetCost(majorLevel - 1 + resets*100)
			local desc = Main:GetUpgradeDescription(part, majorLevel)
			local HoverButton = UpgradeIndicatorPanel:Add("DPanel")
			HoverButton:SetWide(24)
			HoverButton:SetTooltip(string.format("%s (%s)\n%s", title, ROTGB_FormatCash(upgradeCost, true), desc))
			HoverButton:DockMargin(0,0,8,0)
			HoverButton:Dock(LEFT)
			HoverButton.DrawColor = j <= UpgradeButton.Tier and color_green or reftab.majorLevels[minorLevel] == j and color_yellow or color_gray
			function HoverButton:Paint(w,h)
				draw.RoundedBox(8,0,0,w,h,self.DrawColor)
			end
			UpgradeIndicatorPanel.HoverPanels[j] = HoverButton
		end
		
		function UpgradeIndicatorPanel:Refresh()
			for j,v in ipairs(self.HoverPanels) do
				local minorLevel = level % 100 + 1
				local resets = math.floor(level/100)
				local majorLevel = table.KeyFromValue(reftab.majorLevels, j)
				local title = string.format("Level %u %s", majorLevel + resets*100, partNiceName)
				local upgradeCost = wep:GetCost(majorLevel - 1 + resets*100)
				local desc = Main:GetUpgradeDescription(part, majorLevel)
				v:SetTooltip(string.format("%s (%s)\n%s", title, ROTGB_FormatCash(upgradeCost, true), desc))
				v.DrawColor = j <= UpgradeButton.Tier and color_green or reftab.majorLevels[minorLevel] == j and color_yellow or color_gray
			end
		end
		UpgradeIndicatorPanel:Refresh()
	end
	
	local SellButton = vgui.Create("DButton", OtherPanel)
	local TargetButton = vgui.Create("DButton", OtherPanel)
	local DamageButton = vgui.Create("DButton", OtherPanel)
	OtherPanel:Dock(FILL)
	OtherPanel.Paint = self.DoNothing
	function OtherPanel:Refresh()
		SellButton:UpdateText()
	end
	
	SellButton:SetTall(32)
	SellButton:SetFont("DermaLarge")
	SellButton:SetTextColor(color_red)
	SellButton:SetContentAlignment(5)
	SellButton:Dock(BOTTOM)
	SellButton.Paint = PaintButton
	function SellButton:UpdateText()
		self:SetText("Sell / Remove ("..ROTGB_FormatCash((wep.SellAmount or 0)*0.8*GetConVar("rotgb_cash_mul"):GetFloat())..")")
	end
	function SellButton:DoClick()
		if not IsValid(wep) then
			Main:Close()
			return CauseNotification("Shooter is invalid!")
		end
		Derma_Query("Are you sure you want to sell this weapon?","Are you sure?",
		"Yes",function()
			if IsValid(wep) then
				if IsValid(Main) then Main:Close() end
				net.Start("rotgb_shooter")
				net.WriteUInt(ROTGB_SELL,4)
				net.SendToServer()
			end
		end,"No")
	end
	SellButton:UpdateText()
	
	TargetButton:SetTall(32)
	TargetButton:SetFont("DermaLarge")
	TargetButton:SetText("Homing Targeting: None")
	TargetButton:SetTextColor(color_gray)
	TargetButton:SetContentAlignment(5)
	TargetButton:Dock(BOTTOM)
	function TargetButton:Paint(w,h)
		if not IsValid(wep) then
			Main:Close()
			return CauseNotification("Tower is invalid!")
		end
		local hasTargeting = wep:HasUserTargeting()
		draw.RoundedBox(8,0,0,w,h,self:IsHovered() and hasTargeting and color_gray_translucent or color_black_translucent)
		
		if self.CurrentSetting ~= wep:GetTargeting() or ((self.CurrentSetting or 0) < 0) == hasTargeting then
			self.CurrentSetting = hasTargeting and wep:GetTargeting() or -1
			self:SetText(self.CurrentSetting < 0 and "Homing Targeting: None" or "Homing Targeting: "..wep.TargetingOptions[self.CurrentSetting+1])
			self:SetTextColor(self.CurrentSetting < 0 and color_gray or color_white)
		end
	end
	function TargetButton:DoClick()
		if not IsValid(wep) then
			Main:Close()
			return CauseNotification("Tower is invalid!")
		end
		if input.IsShiftDown() then
			net.Start("rotgb_shooter")
			net.WriteUInt(ROTGB_TARGETING,4)
			net.WriteUInt(1,2)
			net.SendToServer()
		else
			net.Start("rotgb_shooter")
			net.WriteUInt(ROTGB_TARGETING,4)
			net.WriteUInt(0,2)
			net.SendToServer()
		end
	end
	function TargetButton:DoRightClick()
		if not IsValid(wep) then
			Main:Close()
			return CauseNotification("Tower is invalid!")
		end
		if not wep:HasUserTargeting() then return end
		local TargetMenu = DermaMenu(self)
		for i=1,#wep.TargetingOptions do
			local Option = TargetMenu:AddOption(wep.TargetingOptions[i],function()
				net.Start("rotgb_shooter")
				net.WriteUInt(ROTGB_TARGETING,4)
				net.WriteUInt(2,2)
				net.WriteUInt(i-1,4)
				net.SendToServer()
			end)
			Option:SetIcon("icon16/"..wep.TargetingIcons[i]..".png")
		end
		TargetMenu:Open()
	end
	
	DamageButton.CurrentPops = self:GetPops()
	DamageButton:SetTall(32)
	DamageButton:SetFont("DermaLarge")
	DamageButton:SetText("Damage: "..string.Comma(DamageButton.CurrentPops))
	DamageButton:SetTextColor(color_white)
	DamageButton:SetContentAlignment(5)
	DamageButton:Dock(BOTTOM)
	function DamageButton:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_translucent)
		if (IsValid(wep) and self.CurrentPops ~= wep:GetPops()) then
			self.CurrentPops = wep:GetPops()
			self:SetText("Damage: "..string.Comma(self.CurrentPops))
		end
	end
	
	return LeftPanel
end

function SWEP:CreateRightPanel(Main)
	local rotgb_control = weapons.Get("rotgb_control")
	local wep = self
	local RightDivider = vgui.Create("DVerticalDivider")
	RightDivider:SetDividerHeight(padding)
	RightDivider:SetTopHeight(ScrH()*0.8)
	
	local InfoPanel = vgui.Create("DPanel")
	local InfoLabel = vgui.Create("DLabel", InfoPanel)
	RightDivider:SetTop(InfoPanel)
	InfoPanel:DockPadding(0,0,0,padding)
	InfoPanel.AttributeInfo = {
		{"SpeedMultiplier", function(value)
			if value > 1 then
				return string.format("+%u%% movement speed", value*100-100)
			end
		end},
		{"FireRate", function(value)
			if value > 4 then
				return string.format("+%u%% fire rate", value*25-100)
			end
		end},
		{"rotgb_CritChance", function(value)
			if value > 0 then
				return string.format("+%u%% crit chance", value*100)
			end
		end},
		{"rotgb_FireRate", function(value)
			if value > 1 then
				return string.format("x%u fire rate", value)
			end
		end},
		{"rotgb_AutoTargets", function(value)
			if value > 0 then
				if value > 1 then
					return string.format("+%u auto-pop targets", value)
				else return "+1 auto-pop target"
				end
			end
		end},
		{"rotgb_GrayPop", function(value)
			if value then
				return "+Gray gBalloon poppage"
			end
		end},
		{"AttackDamage", function(value)
			if value > 10 then
				return string.format("x%u damage", value/10)
			end
		end},
		{"rotgb_BulletPairs", function(value)
			if value > 0 then
				return string.format("x%u non-homing bullets", value*2+1)
			end
		end},
		{"rotgb_BulletPairHoming", function(value)
			if value then
				return "+Redirectional bullets"
			end
		end},
		{"rotgb_BlimpMul", function(value)
			if value > 1 then
				return string.format("x%u gBlimp damage", value)
			end
		end},
		{"rotgb_CritMul", function(value)
			if value > 2 then
				return string.format("x%u crit damage", value/2)
			end
		end},
		{"rotgb_HomingBullets", function(value)
			if value > 0 then
				if value > 1 then
					return string.format("+%u homing bullets", value)
				else return "+1 homing bullet"
				end
			end
		end}
	}
	function InfoPanel:Paint(w, h)
		if not IsValid(wep) then
			Main:Close()
			return CauseNotification("Shooter is invalid!")
		end
		PaintBackground(self, w, h)
		draw.SimpleText("Current Bonuses","DermaLarge",0,0,color_white)
	end
	function InfoPanel:Refresh()
		if not IsValid(wep) then
			Main:Close()
			return CauseNotification("Shooter is invalid!")
		end
		local text = '\n'
		for i,v in ipairs(self.AttributeInfo) do
			local appendText = v[2](wep[v[1]])
			if appendText then
				text = text..'\n'..appendText
			end
		end
		
		InfoLabel:SetText(text)
	end
	InfoPanel:Refresh()
	
	InfoLabel:SetContentAlignment(7)
	InfoLabel:SetTextColor(color_white)
	InfoLabel:Dock(FILL)
	
	-- just use what we already defined in rotgb_control, no need to copy and paste code
	RightDivider:SetBottom(rotgb_control.CreateBottomRightPanel(self, Main))
	
	return InfoPanel, RightDivider
end