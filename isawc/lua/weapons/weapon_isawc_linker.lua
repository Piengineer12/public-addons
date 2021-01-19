AddCSLuaFile()

SWEP.Category			= "ISAWC"
SWEP.Spawnable			= true
--	SWEP.AdminOnly			= false
SWEP.PrintName			= "ISAWC MultiConnector"
--	SWEP.Base				= weapon_base
--	SWEP.m_WeaponDeploySpeed= 1
SWEP.Author				= "Piengineer"
SWEP.Contact			= "http://steamcommunity.com/id/Piengineer12/"
SWEP.Purpose			= "Connects a single Inventory Exporter or container to multiple containers."
SWEP.Instructions		= "Follow the on-screen instructions."
--	SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
--	SWEP.ViewModelFlip		= false
--	SWEP.ViewModelFlip1		= false
--	SWEP.ViewModelFlip2		= false
--	SWEP.ViewModelFOV		= 62
SWEP.WorldModel			= "models/weapons/w_pistol.mdl" -- because someone asked
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
local EXPORTER_SELECTED = 1
local color_gray = Color(127, 127, 127)

function SWEP:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Int",1,"ConnectionDisplays") -- this value tends to be wrong on client, so we need to network it
	self:NetworkVar("Entity",0,"Exporter")
end

function SWEP:Initialize()
	self.Weapon:SetHoldType("normal")
end

function SWEP:UpdateConnectionDisplays()
	local exporter = self:GetExporter()
	if exporter:GetClass()=="isawc_extractor" then
		local displays = 0
		for i=1,32 do
			local storageEntity = exporter:GetContainer(i)
			if IsValid(storageEntity) then
				displays = displays + 1
			end
		end
		self:SetConnectionDisplays(displays)
	end
end

function SWEP:LeftClickEntity(ent)
	if IsValid(ent) then
		local ply = self:GetOwner()
		local accountID = ply:AccountID() or 0
		if self:GetState()==DEFAULT and (ent:GetClass()=="isawc_extractor" or ent.Base=="isawc_container_base") then
			if ent:GetOwnerAccountID()==0 then
				ent:SetOwnerAccountID(accountID)
			end
			if ent:GetOwnerAccountID() == (accountID) then
				self:SetExporter(ent)
				self:UpdateConnectionDisplays()
				self:SetState(EXPORTER_SELECTED)
				self:EmitSound("buttons/button17.wav")
			else
				self:EmitSound("items/medshotno1.wav")
				ply:PrintMessage(HUD_PRINTTALK, "Only the owner can interact with this!")
			end
		elseif self:GetState()==EXPORTER_SELECTED and IsValid(self:GetExporter()) and ent.Base=="isawc_container_base" then
			local target = self:GetExporter()
			if target:GetClass()=="isawc_extractor" then
				target:LinkEntity(ent)
				self:UpdateConnectionDisplays()
			else
				if ent:GetEnderInvName()~=target:GetEnderInvName() or target:GetEnderInvName()=='' then
					if ent:GetEnderInvName()==target:GetEnderInvName() then
						target:SetEnderInvName(accountID.."'s "..ent:GetCreationID())
						ent:SetEnderInvName(target:GetEnderInvName())
					elseif target:GetEnderInvName()=='' then
						target:SetEnderInvName(ent:GetEnderInvName())
					else
						ent:SetEnderInvName(target:GetEnderInvName())
					end
					ply:PrintMessage(HUD_PRINTTALK, "Container is now synced with "..tostring(ent).."!")
				end
			end
			if not ply:Crouching() then
				self:SetState(DEFAULT)
			end
			self:EmitSound("buttons/button17.wav")
		else
			self:EmitSound("items/medshotno1.wav")
		end
	else
		self:EmitSound("items/medshotno1.wav")
	end
end

function SWEP:RightClickEntity(ent)
	if IsValid(self:GetExporter()) then
		if self:GetState()==EXPORTER_SELECTED and self:GetExporter().Base=="isawc_container_base" then
			self:SetState(DEFAULT)
			self:EmitSound("buttons/button17.wav")
		elseif IsValid(ent) then
			local ply = self:GetOwner()
			if self:GetState()==DEFAULT and ent.Base=="isawc_container_base" then
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
					ply:PrintMessage(HUD_PRINTTALK, "Only the owner can interact with this!")
					self:EmitSound("items/medshotno1.wav")
				end
			elseif self:GetState()==EXPORTER_SELECTED and ent.Base=="isawc_container_base" then
				if self:GetExporter():HasContainer(ent) then
					self:GetExporter():UnlinkEntity(ent)
					self:UpdateConnectionDisplays()
					self:EmitSound("buttons/button17.wav")
					ply:PrintMessage(HUD_PRINTTALK, "Device unlinked from "..tostring(ent).."!")
					if not ply:Crouching() then
						self:SetState(DEFAULT)
					end
				end
			else
				self:EmitSound("items/medshotno1.wav")
			end
		else
			self:EmitSound("items/medshotno1.wav")
		end
	else
		self:EmitSound("items/medshotno1.wav")
	end
end

function SWEP:Think()
	if self:GetState()==EXPORTER_SELECTED and not IsValid(self:GetExporter()) and SERVER then
		self:SetState(DEFAULT)
	end
end

function SWEP:DoFunctionByEntity(func)
	local ply = self:GetOwner()
	local ent = ply:GetEyeTrace().Entity
	if IsValid(ent) then
		func(self, ent)
	else
		local tracedata = {
			start = ply:GetShootPos(),
			endpos = ply:GetAimVector()*32768,
			filter = ply,
			mask = MASK_ALL
		}
		local traceresult = util.TraceLine(tracedata)
		if traceresult.HitWorld then
			table.Empty(tracedata)
			local hitpos = traceresult.HitPos
			for k,v in pairs(ents.FindInSphere(hitpos,16)) do
				tracedata[v] = -v:GetPos():DistToSqr(hitpos)
			end
			func(self, table.GetWinningKey(tracedata))
		else
			func(self, traceresult.Entity)
		end
	end
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime()+0.2)
	if SERVER and self:GetOwner():IsPlayer() then
		self:DoFunctionByEntity(self.LeftClickEntity)
	end
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime()+0.2)
	if SERVER and self:GetOwner():IsPlayer() then
		self:DoFunctionByEntity(self.RightClickEntity)
	end
end

function SWEP:Reload()
	if SERVER and self:GetOwner():IsPlayer() and self:GetState()==EXPORTER_SELECTED then
		if self:GetExporter().Base == "isawc_container_base" then
			self:DoFunctionByEntity(self.RightClickEntity)
		else
			self:EmitSound("buttons/button17.wav")
			self:SetState(DEFAULT)
		end
	end
end

local nextRefresh = 0
local allEnts = {}
local function DrawLinks(exporter, active)
	local isContainer = exporter.Base == "isawc_container_base"
	local selfPos = exporter:WorldSpaceCenter()
	local maxSize = 10000/selfPos:Distance(EyePos())
	local containerPosTable = {}
	
	if nextRefresh < RealTime() then
		nextRefresh = RealTime() + 1
		allEnts = ents.GetAll()
	end
	
	cam.Start3D()
	containerPosTable[1] = selfPos:ToScreen()
	
	if isContainer then
		if exporter:GetEnderInvName()~='' then
			for k,v in pairs(allEnts) do
				if (v.Base=="isawc_container_base" and v:GetEnderInvName()==exporter:GetEnderInvName()) then
					table.insert(containerPosTable, v:WorldSpaceCenter():ToScreen())
				end
			end
		end
	else
		for i=1,32 do
			local dEnt = exporter["GetStorageEntity"..i](exporter)
			if IsValid(dEnt) then
				table.insert(containerPosTable, dEnt:WorldSpaceCenter():ToScreen())
			end
		end
	end
	cam.End3D()
	local firstX, firstY = containerPosTable[1].x, containerPosTable[1].y
	if containerPosTable[1].visible then
		if active then
			surface.DrawCircle(firstX, firstY, math.abs(math.sin(RealTime()*3))*maxSize, 255, 255, 0)
		end
		for k,v in pairs(containerPosTable) do
			if k~=1 and v.visible then
				surface.SetDrawColor(255, 255, 0)
				surface.DrawLine(firstX, firstY, v.x, v.y)
			end
		end
	end
end

function SWEP:DrawHUD()
	local baseX = ScrW()*0.6
	local baseY = ScrH()*0.6
	local fontHeight = draw.GetFontHeight("CloseCaption_Normal")
	
	if self:GetState()==DEFAULT then
		draw.SimpleTextOutlined("Primary: Select Inventory Exporter / Container", "CloseCaption_Normal", baseX, baseY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
		draw.SimpleTextOutlined("Secondary: Unsync Container", "CloseCaption_Normal", baseX, baseY+fontHeight, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
	elseif self:GetState()==EXPORTER_SELECTED then
		local isContainer = IsValid(self:GetExporter()) and self:GetExporter().Base == "isawc_container_base"
		if isContainer then
			draw.SimpleTextOutlined("Primary: Sync with Container", "CloseCaption_Normal", baseX, baseY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
			draw.SimpleTextOutlined("Secondary: Cancel", "CloseCaption_Normal", baseX, baseY+fontHeight, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
		else
			draw.SimpleTextOutlined(string.format("Primary: Connect with Container (%u/32)", self:GetConnectionDisplays()), "CloseCaption_Normal", baseX, baseY, self:GetConnectionDisplays() < 32 and color_white or color_gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
			draw.SimpleTextOutlined("Secondary: Disconnect with Container", "CloseCaption_Normal", baseX, baseY+fontHeight, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
		end
		draw.SimpleTextOutlined("Reload: Cancel", "CloseCaption_Normal", baseX, baseY+fontHeight*2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
		draw.SimpleTextOutlined("(+Crouch: Keep Going with More Containers)", "CloseCaption_Normal", baseX, baseY+fontHeight*4, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
		
		if IsValid(self:GetExporter()) then
			DrawLinks(self:GetExporter(), true)
		end
	end
end

hook.Add("HUDPaint", "ISAWC_Connector_PermaHUD", function()
	if ISAWC.ConPermaConnectorHUD:GetBool() then
		if nextRefresh < RealTime() then
			nextRefresh = RealTime() + 1
			allEnts = ents.GetAll()
		end
		for k,v in pairs(allEnts) do
			if (IsValid(v) and (v:GetClass()=="isawc_extractor" or v.Base=="isawc_container_base")) then
				local accountID = v:GetOwnerAccountID() or 0
				if accountID == LocalPlayer():AccountID() or accountID == 0 then
					DrawLinks(v)
				end
			end
		end
	end
end)