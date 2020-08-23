AddCSLuaFile()

SWEP.Category			= "RotgB"
--	SWEP.Spawnable			= false
--	SWEP.AdminOnly			= false
SWEP.PrintName			= "Cash Giver"
--	SWEP.Base				= weapon_base
SWEP.m_WeaponDeploySpeed= 1
SWEP.Author				= "Piengineer"
SWEP.Contact			= "http://steamcommunity.com/id/Piengineer12/"
SWEP.Purpose			= "A gun that gives cash to other players. Basically a better version of that gun from ROBLOX."
SWEP.Instructions		= "Primary: Send 10% of your cash to target player."
SWEP.ViewModel			= "models/weapons/c_medkit.mdl"
--	SWEP.ViewModelFlip		= false
--	SWEP.ViewModelFlip1		= false
--	SWEP.ViewModelFlip2		= false
SWEP.ViewModelFOV		= 30
SWEP.WorldModel			= "models/weapons/w_medkit.mdl"
SWEP.AutoSwitchFrom		= false
SWEP.AutoSwitchTo		= false
--	SWEP.Weight				= 5
--	SWEP.BobScale			= 1
--	SWEP.SwayScale			= 1
--	SWEP.BounceWeaponIcon	= true
--	SWEP.DrawWeaponInfoBox	= true
--	SWEP.DrawAmmo			= true
--	SWEP.DrawCrosshair		= true
--	SWEP.RenderGroup		= RENDERGROUP_OPAQUE
SWEP.Slot				= 2
--	SWEP.SlotPos			= 10
--	SWEP.SpeechBubbleLid	= surface.GetTextureID("gui/speech_lid")
--	SWEP.WepSelectIcon		= surface.GetTextureID("weapons/swep")
--	SWEP.CSMuzzleFlashes	= false
--	SWEP.CSMuzzleX			= false
SWEP.Primary			= {
	Ammo		= "Battery",
	ClipSize	= 10,
	DefaultClip	= 10,
	Automatic	= false
}
SWEP.Secondary			= {
	Ammo		= "none",
	ClipSize	= -1,
	DefaultClip	= -1,
	Automatic	= false
}
SWEP.UseHands			= true
SWEP.AccurateCrosshair	= true
--	SWEP.DisableDuplicator	= false
SWEP.m_bPlayPickupSound	= false
SWEP.CommonTraceData = {}
SWEP.TraceResult = {}

function SWEP:GetCashText(amount)
	if amount == math.huge then return "∞"
	elseif not (amount < 0 or amount >= 0) then return "☠"
	else return math.Round(amount,0)
	end
end

function SWEP:Think()
	if self.Weapon:Clip1() < self.Weapon:GetMaxClip1() and (self.Weapon.NextCharge or 0) < CurTime() and SERVER then
		self.Weapon.NextCharge = CurTime() + 1
		self.Weapon:SetClip1(self.Weapon:Clip1()+1)
	end
end

local color_red = Color(255,0,0)

function SWEP:DrawHUD()
	local ax, ay = ScrW()/2, ScrH()/4
	if GetConVar("rotgb_individualcash"):GetBool() then
		local bestplayer = self:GetBestPlayer()
		local playertext = bestplayer and "Targeting: "..bestplayer:Nick() or "Targeting: no one"
		local playercolor = bestplayer and color_white or color_red
		draw.SimpleTextOutlined(playertext, "CloseCaption_Normal", ax, ay, playercolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		
		ax, ay = ScrW()/2, ScrH()*3/4
		local cash = ROTGB_GetCash(LocalPlayer())*0.1
		local costtext = "Sending: $"..self:GetCashText(cash)
		if cash < 1 then
			costtext = "You need $10 first!"
		end
		draw.SimpleTextOutlined(costtext, "CloseCaption_Normal", ax, ay, cash < 1 and color_red or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	else
		draw.SimpleTextOutlined("This weapon is useless unless the rotgb_individualcash ConVar is set to 1!", "CloseCaption_Normal", ax, ay, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
	end
end

function SWEP:GetBestPlayer()
	local localdir = self.Owner:GetAimVector()
	local bestscore, bestplayer = 0
	for k,v in pairs(player.GetAll()) do
		if v~=self.Owner then
			local dir = v:GetShootPos() - self.Owner:GetShootPos()
			local score = localdir:Dot(dir)
			if bestscore < score then
				bestscore = score
				bestplayer = v
			end
		end
	end
	return bestplayer
end

function SWEP:CanPrimaryAttack()
	if not GetConVar("rotgb_individualcash"):GetBool() then
		self.Owner:EmitSound("items/medshotno1.wav",60,100,1,CHAN_WEAPON)
		return false
	elseif self.Weapon:Clip1() <= 0 and SERVER then
		self.Owner:EmitSound("items/medshotno1.wav",60,100,1,CHAN_WEAPON)
		self.Owner:PrintMessage(HUD_PRINTTALK, "You're transferring too fast!")
		return false
	end
	return true
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if self:CanPrimaryAttack() and IsValid(self.Owner) and SERVER then
		local ply = self:GetBestPlayer()
		local cashtransfer = ROTGB_GetCash(self.Owner)*0.1
		if cashtransfer < 1 or not ply then
			self.Owner:EmitSound("items/medshotno1.wav",60,100,1,CHAN_WEAPON)
		else
			ROTGB_RemoveCash(cashtransfer, self.Owner)
			ROTGB_AddCash(cashtransfer, ply)
			self.Owner:EmitSound("items/medshot4.wav",60,100,1,CHAN_WEAPON)
			ply:PrintMessage(HUD_PRINTTALK, "You gained $"..math.Round(cashtransfer,0).." from "..self.Owner:Nick().."!")
			self:TakePrimaryAmmo(1)
			--util.ScreenShake(self.Owner:GetShootPos(), 4, 20, 0.5, 64)
		end
	end
end

function SWEP:SecondaryAttack()
end