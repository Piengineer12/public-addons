AddCSLuaFile()

SWEP.Category			= "Minecraft"
SWEP.Spawnable			= true
--	SWEP.AdminOnly			= false
SWEP.PrintName			= "Handheld Rocket [BETA]"
--	SWEP.Base				= weapon_base
SWEP.m_WeaponDeploySpeed= 1
SWEP.Author				= "Piengineer"
SWEP.Contact			= "http://steamcommunity.com/id/Piengineer12/"
SWEP.Purpose			= "A launchable firework. Be careful not to let it explode in your face."
SWEP.Instructions		= "Primary: Light fuse and release rocket.\nSecondary: Light fuse without releasing, use Primary Fire after to release."
SWEP.ViewModel			= ""--"models/weapons/c_stunstick.mdl"
--	SWEP.ViewModelFlip		= false
--	SWEP.ViewModelFlip1		= false
--	SWEP.ViewModelFlip2		= false
--	SWEP.ViewModelFOV		= 62
SWEP.WorldModel			= "models/weapons/w_crowbar.mdl"
SWEP.AutoSwitchFrom		= false
SWEP.AutoSwitchTo		= false
--	SWEP.Weight				= 5
--	SWEP.BobScale			= 1
--	SWEP.SwayScale			= 1
SWEP.BounceWeaponIcon	= false
--	SWEP.DrawWeaponInfoBox	= true
SWEP.DrawAmmo			= false
--	SWEP.DrawCrosshair		= true
--	SWEP.RenderGroup		= RENDERGROUP_OPAQUE
SWEP.Slot				= 2
--	SWEP.SlotPos			= 10
--	SWEP.SpeechBubbleLid	= surface.GetTextureID("gui/speech_lid")
SWEP.WepSelectIcon		= CLIENT and surface.GetTextureID("weapons/weapon_minecraft_firework")
--	SWEP.CSMuzzleFlashes	= false
--	SWEP.CSMuzzleX			= false
SWEP.Primary			= {
	Ammo		= "none",
	ClipSize	= -1,
	DefaultClip	= -1,
	Automatic	= false
}
SWEP.Secondary			= {
	Ammo		= "none",
	ClipSize	= -1,
	DefaultClip	= -1,
	Automatic	= false
}
SWEP.UseHands			= true
--	SWEP.AccurateCrosshair	= false
--	SWEP.DisableDuplicator	= false
SWEP.m_bPlayPickupSound	= false

local fireworkModel = "models/mcitems3d_mariro/firework_rocket.mdl"
local altFireworkModel = false
if not util.IsValidModel(fireworkModel) then
	fireworkModel = "models/mcmodelpack/items/rocket.mdl"
	altFireworkModel = true
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int",0,"LaunchVelocity")
end

function SWEP:CreateFirework()
	local firework = ents.Create("minecraft_firework_rocket")
	local angs = self.Owner:EyeAngles()
	firework:SetPos(self.Owner:EyePos() + angs:Forward() * 24)
	angs.y = angs.y - 90
	firework:SetAngles(angs)
	firework:SetCreator(self.Owner)
	firework:SetLifeTime(self.Firework.Duration+1)
	firework.FireworkStars = self.Firework.FireworkStars
	firework:Spawn()
	return firework
end

function SWEP:ApplyFireworkForce(firework)
	local physobj = firework:GetPhysicsObject()
	if IsValid(physobj) then
		local angs = self.Owner:EyeAngles()
		local velocityDir = angs:Forward()
		velocityDir:Mul(self:GetLaunchVelocity())
		physobj:SetVelocity(velocityDir)
	end
end

function SWEP:ThrowFirework()
	if IsValid(self.FireworkEntity) then
		self.FireworkEntity:SetParent(NULL)
		self.FireworkEntity:SetMoveType(MOVETYPE_VPHYSICS)
		if (PPM2 and self.Owner:IsPlayer() and self.Owner:IsPonyCached()) then -- this may get interesting!
			local data = self.Owner:GetPonyData()
			if (data and data:GetFly()) then -- don't spawn the firework in front of the player, as it can be very painful!
				self.FireworkEntity:SetPos(self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * -64)
			else
				self.FireworkEntity:SetPos(self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 32)
			end
		else
			self.FireworkEntity:SetPos(self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 32)
		end
		self.FireworkEntity:SetTrigger(true)
		self.FireworkEntity:SetNotSolid(false)
		self:ApplyFireworkForce(self.FireworkEntity)
		self.FireworkEntity = nil
	else
		local firework = self:CreateFirework()
		self:ApplyFireworkForce(firework)
	end
end

function SWEP:LightFirework()
	if not IsValid(self.FireworkEntity) then
		self.FireworkEntity = self:CreateFirework()
		self.FireworkEntity:SetPos(self:GetPos())
		self.FireworkEntity:SetMoveType(MOVETYPE_NONE)
		self.FireworkEntity:SetParent(self.Owner)
		self.FireworkEntity:SetTrigger(false)
		self.FireworkEntity:SetNotSolid(true)
	end
end

function SWEP:ClientFire()
	if CLIENT and self:GetNextPrimaryFire() < CurTime() then
		self:SetNextPrimaryFire(CurTime() + 1)
		if (not self.Firework or self.Owner:IsFlagSet(FL_DUCKING)) and self.Owner:IsPlayer() then
			MFR_SelectFireworkRocket(function(rocket, velocity)
				if IsValid(self) then
					self.Firework = rocket
					local resStr = util.Compress(util.TableToJSON(rocket))
					net.Start("minecraft_firework")
					net.WriteString("receive")
					net.WriteUInt(#resStr, 16)
					net.WriteData(resStr, #resStr)
					net.WriteEntity(self)
					net.WriteUInt(math.Round(velocity), 32)
					net.SendToServer()
				end
			end, self:GetLaunchVelocity())
		end
	end
end

function SWEP:CheckProxyModel()
	if (self.RegenerateNextClientModelTime or 0) > RealTime() then return false end
	if not IsValid(self.ClientModel) then
		self.ClientModel = ClientsideModel(fireworkModel, RENDERGROUP_OPAQUE)
		self.ClientModel:SetNoDraw(true)
	end
	return IsValid(self.ClientModel)
end

function SWEP:Initialize()
	self:SetLaunchVelocity(500)
end

function SWEP:PostDrawViewModel()
	if (CLIENT and self:CheckProxyModel()) then
		local pos = self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand") or -1)
		if pos == self.Owner:GetPos() then
			pos = self.Owner:GetBoneMatrix(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand") or -1):GetTranslation()
		end
		if pos and not self.Owner:IsDormant() then
			self.ClientModel:SetPos(pos)
			local fAng = self.Owner:GetAngles()
			fAng.p = 0
			if altFireworkModel then
				fAng.y = fAng.y - 90
				fAng.r = 0
			else
				fAng.r = -180
			end
			self.ClientModel:SetAngles(fAng)
			self.ClientModel:SetupBones()
			self.ClientModel:DrawModel()
		else
			self.RegenerateNextClientModelTime = RealTime() + 1
			self.ClientModel:Remove()
		end
	end
end

SWEP.DrawWorldModel = SWEP.PostDrawViewModel

--[[function SWEP:ViewModelDrawn(vm)
	if self:CheckProxyModel() and IsValid(vm) then
		if not self.ClientModel.NoCrowbar then
			self.ClientModel.NoCrowbar = true
			vm:SetMaterial("models/effects/vol_light001")
		end
		local pos = vm:GetBonePosition(vm:LookupBone("ValveBiped.Bip01_R_Hand"))
		if pos == vm:GetPos() then
			pos = vm:GetBoneMatrix(vm:LookupBone("ValveBiped.Bip01_R_Hand")):GetTranslation()
		end
		self.ClientModel:SetPos(pos)
		local fAng = vm:GetAngles()
		fAng.p = 0
		if altFireworkModel then
			fAng.y = fAng.y - 90
			fAng.r = 0
		else
			fAng.r = -180
		end
		self.ClientModel:SetAngles(fAng)
	end
end]]

function SWEP:Holster()
	if IsValid(self.ClientModel) then
		self.ClientModel:Remove()
	end
	return true
end

function SWEP:OnRemove()
	if IsValid(self.ClientModel) then
		self.ClientModel:Remove()
	end
end

function SWEP:CanPrimaryAttack()
	return self.Firework and IsValid(self.Owner) and not self.Owner:IsFlagSet(FL_DUCKING)
end

function SWEP:PrimaryAttack()
	self:ClientFire()
	if SERVER and (IsFirstTimePredicted() or game.SinglePlayer()) then
		if game.SinglePlayer() then
			self:CallOnClient("PrimaryAttack")
		end
		if self:CanPrimaryAttack() then
			self:ThrowFirework()
		end
	end
end

function SWEP:SecondaryAttack()
	self:ClientFire()
	if SERVER and (IsFirstTimePredicted() or game.SinglePlayer()) then
		if game.SinglePlayer() then
			self:CallOnClient("PrimaryAttack")
		end
		if self:CanPrimaryAttack() then
			self:LightFirework()
		end
	end
end