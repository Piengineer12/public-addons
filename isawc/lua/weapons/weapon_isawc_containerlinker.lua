AddCSLuaFile()

SWEP.Base				= "weapon_isawc_linker"
SWEP.Category			= "ISAWC"
--	SWEP.Spawnable			= false
--	SWEP.AdminOnly			= false
SWEP.PrintName			= "Container MultiConnector (DEPRECATED - DO NOT USE)"
--	SWEP.Base				= weapon_base
--	SWEP.m_WeaponDeploySpeed= 1
SWEP.Author				= "Piengineer"
SWEP.Contact			= "http://steamcommunity.com/id/Piengineer12/"
SWEP.Purpose			= "Connects a single container to sync its inventory with other containers."
SWEP.Instructions		= "Follow the on-screen instructions."
--	SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
--	SWEP.ViewModelFlip		= false
--	SWEP.ViewModelFlip1		= false
--	SWEP.ViewModelFlip2		= false
--	SWEP.ViewModelFOV		= 62
--	SWEP.WorldModel			= "models/weapons/w_357.mdl"
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
SWEP.Slot				= 1
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
	Automatic	= false
}
SWEP.UseHands			= true
SWEP.AccurateCrosshair	= true
--	SWEP.DisableDuplicator	= false

local DEFAULT = 0
local CONTAINER_SELECTED = 1

function SWEP:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Entity",0,"Container")
end

function SWEP:LeftClickEntity(ent)
	if (IsValid(ent) and ent.Base=="isawc_container_base") then
		local ply = self:GetOwner()
		local accountID = ply:AccountID() or 0
		if ent:GetOwnerAccountID()==0 then
			ent:SetOwnerAccountID(accountID)
		end
		if ent:GetOwnerAccountID() == accountID then
			local container = self:GetContainer()
			if self:GetState()==DEFAULT then
				self:SetContainer(ent)
				self:SetState(CONTAINER_SELECTED)
				self:EmitSound("buttons/button17.wav")
			elseif self:GetState()==CONTAINER_SELECTED and IsValid(container) then
				if ent:GetEnderInvName()~=container:GetEnderInvName() or container:GetEnderInvName()=='' then
					if ent:GetEnderInvName()==container:GetEnderInvName() then
						container:SetEnderInvName(accountID.."'s "..ent:GetCreationID())
						ent:SetEnderInvName(container:GetEnderInvName())
					elseif container:GetEnderInvName()=='' then
						container:SetEnderInvName(ent:GetEnderInvName())
					else
						ent:SetEnderInvName(container:GetEnderInvName())
					end
					self:EmitSound("buttons/button17.wav")
					ply:PrintMessage(HUD_PRINTTALK, "Container is now synced with "..tostring(ent).."!")
					if not ply:Crouching() then
						self:SetState(DEFAULT)
					end
				end
			end
		else
			ply:PrintMessage(HUD_PRINTTALK, "Only the container's owner can make syncs with this!")
			self:EmitSound("items/medshotno1.wav")
		end
	else
		self:EmitSound("items/medshotno1.wav")
	end
end

function SWEP:RightClickEntity(ent)
	if self:GetState()==DEFAULT then
		if (IsValid(ent) and ent.Base=="isawc_container_base") then
			local ply = self:GetOwner()
			local accountID = ply:AccountID() or 0
			if ent:GetOwnerAccountID()==0 then
				ent:SetOwnerAccountID(accountID)
			end
			if ent:GetOwnerAccountID() == accountID then
				if ent:GetEnderInvName()~='' then
					ent:SetEnderInvName('')
					ply:PrintMessage(HUD_PRINTTALK, "Container unlinked from network!")
					self:EmitSound("buttons/button17.wav")
				end
			else
				ply:PrintMessage(HUD_PRINTTALK, "Only the container's owner can destroy syncs with this!")
				self:EmitSound("items/medshotno1.wav")
			end
		else
			self:EmitSound("items/medshotno1.wav")
		end
	else
		self:SetState(DEFAULT)
		self:EmitSound("buttons/button17.wav")
	end
end

function SWEP:Think()
	if self:GetState()==CONTAINER_SELECTED and not IsValid(self:GetContainer()) and SERVER then
		self:SetState(DEFAULT)
	end
end

function SWEP:Reload()
	if SERVER and self:GetOwner():IsPlayer() and self:GetState()==CONTAINER_SELECTED then
		self:DoFunctionByEntity(self.RightClickEntity)
	end
end

local nextRefresh = 0
local allEnts = {}
function SWEP:DrawHUD()
	local baseX = ScrW()*0.6
	local baseY = ScrH()*0.6
	local fontHeight = draw.GetFontHeight("CloseCaption_Normal")
	
	if self:GetState()==DEFAULT then
		draw.SimpleTextOutlined("Primary: Select Container for Connection", "CloseCaption_Normal", baseX, baseY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
		draw.SimpleTextOutlined("Secondary: Disconnect Container", "CloseCaption_Normal", baseX, baseY+fontHeight, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
	elseif self:GetState()==CONTAINER_SELECTED then
		draw.SimpleTextOutlined("Primary: Connect with Container", "CloseCaption_Normal", baseX, baseY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
		draw.SimpleTextOutlined("(+Crouch: Keep Going with More Containers)", "CloseCaption_Normal", baseX, baseY+fontHeight, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
		draw.SimpleTextOutlined("Secondary: Cancel", "CloseCaption_Normal", baseX, baseY+fontHeight*3, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
		
		if IsValid(self:GetContainer()) then
			local container = self:GetContainer()
			local selfPos = container:WorldSpaceCenter()
			local maxSize = 10000/selfPos:Distance(EyePos())
			local containerPosTable = {}
			
			if nextRefresh < RealTime() then
				nextRefresh = RealTime() + 1
				allEnts = ents.GetAll()
			end
			
			cam.Start3D()
			containerPosTable[1] = selfPos:ToScreen()
			
			if container:GetEnderInvName()~='' then
				for k,v in pairs(allEnts) do
					if (v.Base=="isawc_container_base" and v:GetEnderInvName()==container:GetEnderInvName()) then
						table.insert(containerPosTable, v:WorldSpaceCenter():ToScreen())
					end
				end
			end
			cam.End3D()
			local firstX, firstY = containerPosTable[1].x, containerPosTable[1].y
			if containerPosTable[1].visible then
				surface.DrawCircle(firstX, firstY, math.abs(math.sin(RealTime()*3))*maxSize, 255, 255, 0)
				for k,v in pairs(containerPosTable) do
					if k~=1 and v.visible then
						surface.SetDrawColor(255, 255, 0)
						surface.DrawLine(firstX, firstY, v.x, v.y)
					end
				end
			end
		end
	end
end