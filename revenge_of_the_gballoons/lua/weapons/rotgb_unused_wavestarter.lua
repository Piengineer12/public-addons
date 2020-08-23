AddCSLuaFile()

SWEP.Category			= "RotgB"
--	SWEP.Spawnable			= false
--	SWEP.AdminOnly			= false
SWEP.PrintName			= "Wave Starter"
--	SWEP.Base				= weapon_base
SWEP.m_WeaponDeploySpeed= 1
SWEP.Author				= "Piengineer"
SWEP.Contact			= "http://steamcommunity.com/id/Piengineer12/"
SWEP.Purpose			= "This weapon can activate all gBalloon Spawners and change the game speed."
SWEP.Instructions		= "Primary: Activate all spawners.\nSecondary: Increase game speed.\nSprint + Secondary: Decrease game speed."
SWEP.ViewModel			= "models/weapons/c_arms.mdl"
--	SWEP.ViewModelFlip		= false
--	SWEP.ViewModelFlip1		= false
--	SWEP.ViewModelFlip2		= false
SWEP.ViewModelFOV		= 90
SWEP.WorldModel			= ""
SWEP.AutoSwitchFrom		= false
SWEP.AutoSwitchTo		= false
--	SWEP.Weight				= 5
--	SWEP.BobScale			= 1
--	SWEP.SwayScale			= 1
--	SWEP.BounceWeaponIcon	= true
--	SWEP.DrawWeaponInfoBox	= true
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
--	SWEP.RenderGroup		= RENDERGROUP_OPAQUE
--	SWEP.Slot				= 0
--	SWEP.SlotPos			= 10
--	SWEP.SpeechBubbleLid	= surface.GetTextureID("gui/speech_lid")
--	SWEP.WepSelectIcon		= surface.GetTextureID("weapons/swep")
--	SWEP.CSMuzzleFlashes	= false
--	SWEP.CSMuzzleX			= false
SWEP.Primary			= {
	Ammo		= "Battery",
	ClipSize	= 5,
	DefaultClip	= 5,
	Automatic	= false
}
SWEP.Secondary			= {
	Ammo		= "HelicopterGun",
	ClipSize	= -1,
	DefaultClip	= -1,
	Automatic	= false
}
SWEP.UseHands			= true
--	SWEP.AccurateCrosshair	= false
--	SWEP.DisableDuplicator	= false
SWEP.m_bPlayPickupSound	= false
SWEP.CommonTraceData = {}
SWEP.TraceResult = {}

local ReadyTime = -1
local Readys = 0
local IsolatedStartTimer, IsolatedStopTimer

IsolatedStartTimer = function(ent)
	if ent then
		PrintMessage(HUD_PRINTTALK, ent:Nick().." is ready.")
	end
	Readys = Readys + 1
	local remaining = player.GetCount() - Readys
	ReadyTime = remaining*(remaining+1)*5
	if ReadyTime > 0 then
		PrintMessage(HUD_PRINTTALK, "Wave 1 will begin in "..ReadyTime.." seconds!")
		timer.Create("ROTGB_STARTER", remaining*10, 1, IsolatedStartTimer)
	else
		Readys = 0
		for k,v in pairs(player.GetAll()) do
			v.rotgb_Ready = nil
		end
		for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
			v:Fire("AddOutput","OnWaveFinished !self:SpawnerFinished::0:1")
			v:Fire("AddOutput","OnWaveFinishedShortly !self:SpawnerFinished::0:1")
			v:Fire("Use")
		end
	end
end

IsolatedStopTimer = function(ent)
	if ent then
		PrintMessage(HUD_PRINTTALK, ent:Nick().." is no longer ready.")
	end
	Readys = Readys - 1
	local remaining = player.GetCount() - Readys
	if remaining < player.GetCount() then
		ReadyTime = remaining*(remaining+1)*5
		PrintMessage(HUD_PRINTTALK, "Wave 1 will begin in "..ReadyTime.." seconds!")
		timer.Create("ROTGB_STARTER", remaining*10, 1, IsolatedStartTimer)
	else
		ReadyTime = -1
		PrintMessage(HUD_PRINTTALK, "Wave 1 is now on hold.")
		timer.Remove("ROTGB_STARTER")
	end
end

local color_red = Color(255, 0, 0)

function SWEP:Initialize()
	self:SetHoldType("normal")
end

function SWEP:DrawHUD()
	local ax, ay = ScrW()*2/3, ScrH()/2
	local ourtimescale = game.GetTimeScale()
	local width, height = draw.SimpleTextOutlined("Secondary: Double Speed", "CloseCaption_Normal", ax, ay, ourtimescale < 8 and color_white or color_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
	draw.SimpleTextOutlined("Sprint+Secondary: Halve Speed", "CloseCaption_Normal", ax, ay+height, ourtimescale > 1 and color_white or color_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
	
	local dispcolor = color_red
	for k,v in pairs(ents.GetAll()) do
		if v:GetClass()=="gballoon_base" then
			dispcolor = color_red break
		elseif v:GetClass()=="gballoon_spawner" then
			if v:GetNextWaveTime() > CurTime() then
				dispcolor = color_red break
			else
				dispcolor = color_white
			end
		end
	end
	draw.SimpleTextOutlined("Primary: Ready/Unready", "CloseCaption_Normal", ax, ay-height, dispcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, color_black)
end

function SWEP:AcceptInput(input, activator, caller, data)
	if input == "SpawnerFinished" then
		for k,v in pairs(ents.FindByClass("rotgb_wavestarter")) do
			v:SetClip1(v:GetMaxClip1())
		end
	end
end

function SWEP:CanPrimaryAttack()
	if self.Weapon:Clip1() <= 0 then
		self.Owner:EmitSound("buttons/button10.wav",60,100,1,CHAN_WEAPON)
		self.Owner:PrintMessage(HUD_PRINTTALK, "You can't vote until the wave ends!")
		return false
	end
	return true
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() or self.Owner:IsNPC() then return end
	local spawners = ents.FindByClass("gballoon_spawner")
	if SERVER then
		if table.IsEmpty(spawners) then
			self.Owner:EmitSound("buttons/button10.wav",60,100,1,CHAN_WEAPON)
			return self.Owner:PrintMessage(HUD_PRINTTALK, "Place one gBalloon Spawner first!")
		elseif #ents.FindByClass("gballoon_base") > 0 then
			self.Owner:EmitSound("buttons/button10.wav",60,100,1,CHAN_WEAPON)
			return self.Owner:PrintMessage(HUD_PRINTTALK, "You can't vote until the wave ends!")
		else
			for k,v in pairs(spawners) do
				if v:GetNextWaveTime() > CurTime() then
					self.Owner:EmitSound("buttons/button10.wav",60,100,1,CHAN_WEAPON)
					return self.Owner:PrintMessage(HUD_PRINTTALK, "You can't vote until the wave ends!")
				end
			end
		end
		if self:CanPrimaryAttack() then
			self.Owner.rotgb_Ready = not self.Owner.rotgb_Ready
			self:TakePrimaryAmmo(1)
			if self.Owner.rotgb_Ready then
				IsolatedStartTimer(self.Owner)
			else
				IsolatedStopTimer(self.Owner)
			end
		end
	end
end

function SWEP:Think()
	if self.Weapon:Clip1() < self.Weapon:GetMaxClip1() and (self.Weapon.NextCharge or 0) < CurTime() and SERVER then
		self.Weapon.NextCharge = CurTime() + 5
		self.Weapon:SetClip1(self.Weapon:Clip1()+1)
	end
	if self.Owner:GetAmmoCount("HelicopterGun") < 5 and (self.Weapon.NextCharge or 0) < RealTime() and SERVER then
		self.Weapon.NextCharge = RealTime() + 5
		self.Owner:GiveAmmo(1, "HelicopterGun", true)
	end
	if not self.Initialized then
		self:Initialize()
	end
end

function SWEP:CanSecondaryAttack()
	if self.Owner:GetAmmoCount("HelicopterGun") <= 0 then
		self.Owner:EmitSound("buttons/combine_button_locked.wav",60,100,1,CHAN_WEAPON)
		self.Owner:PrintMessage(HUD_PRINTTALK, "You're changing the game speed too much!")
		return false
	end
	return true
end

function SWEP:SecondaryAttack()
	if not (IsFirstTimePredicted() and SERVER) then return end
	if self:CanSecondaryAttack() then
		local shft = self.Owner:KeyDown(IN_SPEED) and 0.5 or 2
		local newscale = game.GetTimeScale()*shft
		if 1 <= newscale and newscale <= 8 then
			self.Owner:EmitSound(self.Owner:KeyDown(IN_SPEED) and "buttons/combine_button3.wav" or "buttons/combine_button5.wav",60,100+3*newscale,1,CHAN_WEAPON)
			game.SetTimeScale(newscale)
			self:TakeSecondaryAmmo(1)
		end
	end
end