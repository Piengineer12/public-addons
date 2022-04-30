AddCSLuaFile()

SWEP.Category			= "ISAWC"
SWEP.Spawnable			= true
--	SWEP.AdminOnly			= false
SWEP.PrintName			= "Pickup SWEP"
--	SWEP.Base				= weapon_base
SWEP.m_WeaponDeploySpeed= 4
SWEP.Author				= "Piengineer12"
SWEP.Contact			= "http://steamcommunity.com/id/Piengineer12/"
SWEP.Purpose			= "Pick up objects and add it to your inventory!"
SWEP.Instructions		= "Hover your cursor over an object, then click to pick it up.\nLeft Click: Semi-Auto\nRight Click: Full-Auto"
SWEP.ViewModel			= "models/weapons/c_arms.mdl"
--	SWEP.ViewModelFlip		= false
--	SWEP.ViewModelFlip1		= false
--	SWEP.ViewModelFlip2		= false
--	SWEP.ViewModelFOV		= 62
SWEP.WorldModel			= "models/weapons/w_spade.mdl"
SWEP.AutoSwitchFrom		= false
SWEP.AutoSwitchTo		= false
--	SWEP.Weight				= 5
--	SWEP.BobScale			= 1
--	SWEP.SwayScale			= 1
--	SWEP.BounceWeaponIcon	= true
--	SWEP.DrawWeaponInfoBox	= true
SWEP.DrawAmmo			= false
--	SWEP.DrawCrosshair		= true
SWEP.RenderGroup		= RENDERGROUP_OTHER
SWEP.Slot				= 0
SWEP.SlotPos			= 7
--	SWEP.SpeechBubbleLid	= surface.GetTextureID("gui/speech_lid")
--	SWEP.WepSelectIcon		= surface.GetTextureID("weapons/swep")
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
	Automatic	= true
}
SWEP.UseHands			= true
SWEP.AccurateCrosshair	= true
--	SWEP.DisableDuplicator	= false

function SWEP:Initialize()
	self.Weapon:SetHoldType("normal")
end

--[[function SWEP:Think()
	if CLIENT then
		local model = ISAWC.ConPickupViewModel:GetString()
		local vm = LocalPlayer():GetViewModel()
		if (IsValid(vm) and vm:GetModel()~=model) then
			vm:SetModel(model)
		end
	end
	local model = ISAWC.ConPickupWorldModel:GetString()
	if self:GetModel() ~= model then
		self:SetModel(model)
	end
end]]

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime())
	if SERVER and game.SinglePlayer() then self:CallOnClient("PrimaryAttack") end
	if CLIENT and (IsFirstTimePredicted() or game.SinglePlayer()) then
		local ent = LocalPlayer():GetEyeTrace().Entity
		if IsValid(ent) then
			ISAWC:StartNetMessage("pickup")
			net.WriteEntity(ent)
			net.SendToServer()
		else
			local tracedata = {
				start = LocalPlayer():GetShootPos(),
				endpos = LocalPlayer():GetAimVector()*32768,
				filter = LocalPlayer(),
				mask = MASK_ALL
			}
			local traceresult = util.TraceLine(tracedata)
			if traceresult.HitWorld then
				table.Empty(tracedata)
				local hitpos = traceresult.HitPos
				for k,v in pairs(ents.FindInSphere(hitpos,16)) do
					tracedata[v] = -v:GetPos():DistToSqr(hitpos)
				end
				ent = table.GetWinningKey(tracedata)
			else
				ent = traceresult.Entity
			end
			if IsValid(ent) and not (ent:IsWeapon() and IsValid(ent:GetOwner())) then
				ISAWC:StartNetMessage("pickup")
				net.WriteEntity(ent)
				net.SendToServer()
			end
		end
	end
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime())
	if SERVER and game.SinglePlayer() then self:CallOnClient("SecondaryAttack") end
	if CLIENT then
		local ent = LocalPlayer():GetEyeTrace().Entity
		if IsValid(ent) then
			ISAWC:StartNetMessage("pickup")
			net.WriteEntity(ent)
			net.SendToServer()
		else
			local tracedata = {
				start = LocalPlayer():GetShootPos(),
				endpos = LocalPlayer():GetAimVector()*32768,
				filter = LocalPlayer(),
				mask = MASK_ALL
			}
			local traceresult = util.TraceLine(tracedata)
			if traceresult.HitWorld then
				table.Empty(tracedata)
				local hitpos = traceresult.HitPos
				for k,v in pairs(ents.FindInSphere(hitpos,16)) do
					tracedata[v] = -v:GetPos():DistToSqr(hitpos)
				end
				ent = table.GetWinningKey(tracedata)
			else
				ent = traceresult.Entity
			end
			if IsValid(ent) and not (ent:IsWeapon() and IsValid(ent:GetOwner())) then
				ISAWC:StartNetMessage("pickup")
				net.WriteEntity(ent)
				net.SendToServer()
			end
		end
	end
end