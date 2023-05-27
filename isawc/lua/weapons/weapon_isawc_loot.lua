AddCSLuaFile()

--SWEP.Base = "weapon_base"
SWEP.PrintName = "Loot Attacher"
SWEP.Category = "ISAWC"
SWEP.Author = "Piengineer12"
SWEP.Contact = "http://steamcommunity.com/id/Piengineer12/"
SWEP.Purpose = "Attaches a loot table to an ISAWC container, causing it to generate loot when opened."
SWEP.Instructions = "Primary Fire attaches a loot table. Only one loot table can be attached at a time. Secondary Fire removes it. Reload to view options."
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
--SWEP.ViewModelFOV = 62
--SWEP.ViewModelFlip = false
--SWEP.ViewModelFlip1 = false
--SWEP.ViewModelFlip2 = false
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Slot = 2
SWEP.SlotPos = 15
--SWEP.BounceWeaponIcon = true
SWEP.DrawAmmo = false
--SWEP.DrawCrosshair = true
--SWEP.AccurateCrosshair = false
--SWEP.DrawWeaponInfoBox = true
--SWEP.WepSelectIcon = surface.GetTextureID("weapons/swep")
--SWEP.SpeechBubbleLid = surface.GetTextureID("gui/speech_lid")
SWEP.AutoSwitchFrom = false
--SWEP.AutoSwitchTo = true
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
	Ammo = "none",
	ClipSize = -1,
	DefaultClip = -1,
	Automatic = false
}
SWEP.Secondary = {
	Ammo = "none",
	ClipSize = -1,
	DefaultClip = -1,
	Automatic = false
}

function SWEP:SetupDataTables()
	self:NetworkVar("String",0,"LootTable")
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime()+0.2)
	local ply = self:GetOwner()
	if SERVER and ply:IsPlayer() and IsFirstTimePredicted() then
		local ent = ply:GetEyeTrace().Entity
		if (IsValid(ent) and ent.Base == "isawc_container_base") then
			local oldLootTable = ent:GetLootTable()
			local newLootTable = self:GetLootTable()
			ent:SetLootTable(newLootTable)
			
			if oldLootTable == newLootTable and (not ent:GetIsPlayerLocalized() or table.IsEmpty(ent.ISAWC_LootTableLocalizedPlayers)) then
				self:EmitSound("items/medshotno1.wav")
				ply:PrintMessage(HUD_PRINTTALK, "The loot table was unchanged!")
			else
				self:EmitSound("buttons/button17.wav")
				if oldLootTable == "" then
					ply:PrintMessage(HUD_PRINTTALK, "The loot table has been attached!")
				elseif newLootTable == "" then
					ply:PrintMessage(HUD_PRINTTALK, "The loot table has been cleared!")
				else
					ply:PrintMessage(HUD_PRINTTALK, "The loot table has been updated!")
				end
				
				ent.ISAWC_LootTableLocalizedPlayers = {}
			end
		else
			self:EmitSound("items/medshotno1.wav")
			ply:PrintMessage(HUD_PRINTTALK, "That is not a container!")
		end
	end
end

function SWEP:SecondaryAttack()
	local ply = self:GetOwner()
	self.Weapon:SetNextSecondaryFire(CurTime()+0.2)
	if SERVER and ply:IsPlayer() and IsFirstTimePredicted() then
		local ent = ply:GetEyeTrace().Entity
		if (IsValid(ent) and ent.Base == "isawc_container_base") then
			local oldLootTable = ent:GetLootTable()
			local newLootTable = ""
			ent:SetLootTable(newLootTable)
			
			if oldLootTable == newLootTable then
				self:EmitSound("items/medshotno1.wav")
				ply:PrintMessage(HUD_PRINTTALK, "The loot table was unchanged!")
			else
				self:EmitSound("buttons/button17.wav")
				ply:PrintMessage(HUD_PRINTTALK, "The loot table has been cleared!")
			end
		else
			self:EmitSound("items/medshotno1.wav")
			ply:PrintMessage(HUD_PRINTTALK, "That is not a container!")
		end
	end
end

function SWEP:Reload()
	local ply = self:GetOwner()
	if SERVER and ply:IsPlayer() and IsFirstTimePredicted() then
		-- This is kinda bad, but it is still better than most other methods for communicating with the client
		ISAWC:StartNetMessage("send_weapon_data")
		net.WriteEntity(self)
		net.Send(ply)
	end
end

function SWEP:OpenMakerMenu()
	if (self.cooldown or 0) > RealTime() then return end
	
	self.cooldown = RealTime() + 1
	local lootTable = self:GetLootTable()
	local weapon = self
	
	local Main = vgui.Create("DFrame")
	Main:SetSize(640, 480)
	Main:Center()
	Main:MakePopup()
	
	local ScrollPanel = Main:Add("DScrollPanel")
	ScrollPanel:Dock(FILL)
	
	local Label = ScrollPanel:Add("DLabel")
	Label:SetText("Loot Table")
	Label:Dock(TOP)
	
	local LootTableBox = ScrollPanel:Add("DTextEntry")
	LootTableBox:SetText(lootTable)
	LootTableBox:Dock(TOP)
	function LootTableBox:OnChange()
		lootTable = self:GetValue()
	end
	
	local AcceptButton = Main:Add("DButton")
	AcceptButton:SetText("Accept")
	AcceptButton:Dock(BOTTOM)
	function AcceptButton:DoClick()
		if not IsValid(weapon) then
			Main:Close()
			ISAWC:NoPickup("The weapon is missing!",LocalPlayer())
		elseif weapon.cooldown <= RealTime() then
			Main:Close()
			ISAWC:StartNetMessage("send_weapon_data")
			net.WriteString(lootTable)
			net.SendToServer()
			weapon.cooldown = RealTime() + 1
		end
	end
end