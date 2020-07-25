AddCSLuaFile()

ENT.Type 				= "anim"
ENT.Base 				= "base_anim"
ENT.PrintName			= "gBalloon Bestiary"
ENT.Purpose				= "The compendium of knowledge all about Rouge gBalloons."
ENT.Instructions		= ""
ENT.Category			= "RotgB: Miscellaneous"
ENT.Author				= "RandomTNT"
ENT.Contact				= "http://steamcommunity.com/id/RandomTNT12/"
ENT.Spawnable			= false
ENT.AdminOnly			= false
ENT.RenderGroup			= RENDERGROUP_BOTH
ENT.DisableDuplicator	= false

if SERVER then
	util.AddNetworkString("RotgB_Bestiary")
end

function ENT:SpawnFunction(ply,trace,classname)
	if not trace.Hit then return end
	
	local ent = ents.Create(classname)
	ent:SetPos(trace.HitPos+trace.HitNormal*5)
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/props_lab/binderblue.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:Wake()
		end
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:PostEntityPaste(ply,ent,tab)
	ent:Spawn()
	ent:Activate()
end

function ENT:Use(ply,ply2)
	ply = IsValid(ply) and ply or ply2
	if ply:IsPlayer() then
		net.Start("RotgB_Bestiary")
		net.Send(ply)
	end
end

local order = {
	"gballoon_red",
	"gballoon_blue",
	"gballoon_green",
	"gballoon_yellow",
	"gballoon_pink",
	"gballoon_white",
	"gballoon_black",
	"gballoon_purple",
	"gballoon_orange",
	"gballoon_zebra",
	"gballoon_aqua",
	"gballoon_gray",
	"gballoon_error",
	"gballoon_rainbow",
	"gballoon_ceramic",
	"gballoon_blimp_blue",
	"gballoon_brick",
	"gballoon_blimp_red",
	"gballoon_marble",
	"gballoon_blimp_green",
	"gballoon_blimp_gray",
	"gballoon_blimp_purple",
	"gballoon_blimp_magenta",
	"gballoon_blimp_rainbow",
	"gballoon_glass",
	"gballoon_void",
	"gballoon_cfiber",
}

local function AddBalloon(ColumnSheet,class)
	local npcprops = list.GetForEdit("NPC")[class]
	local cvals = npcprops.KeyValues
	local Label = ColumnSheet:Add("RichText")
	local hasimms,haspops
	Label:Dock(FILL)
	Label:SetText("")
	local h1,s1,v1 = ColorToHSV(string.ToColor(cvals.BalloonColor))
	if s1 == 1 then v1 = 1 end
	s1 = s1 / 2
	v1 = (v1 + 1) / 2
	local col2 = HSVToColor(h1,s1,v1)
	Label:InsertColorChange(col2.r,col2.g,col2.b,col2.a)
	Label:AppendText(npcprops.Name.."\n\n")
	Label:InsertColorChange(255,127,127,255)
	Label:AppendText("Hit Points: "..(cvals.BalloonHealth or 1))
	Label:InsertColorChange(255,255,127,255)
	Label:AppendText("\nRgBE: "..baseclass.Get("gballoon_base").rotgb_rbetab[class])
	Label:InsertColorChange(127,255,127,255)
	Label:AppendText("\nSize: "..(cvals.BalloonScale or 1)*(tobool(cvals.BalloonBlimp) and 10 or 1).."x")
	Label:InsertColorChange(127,255,255,255)
	Label:AppendText("\nSpeed: "..(cvals.BalloonMoveSpeed or 100).." Hu/s")
	Label:InsertColorChange(127,127,255,255)
	Label:AppendText("\nOn pop, spawns the following:")
	for k,v in pairs(baseclass.Get("gballoon_base").rotgb_spawns[class] or {}) do
		local npcprops2 = list.GetForEdit("NPC")[k]
		local h1,s1,v1 = ColorToHSV(string.ToColor(npcprops2.KeyValues.BalloonColor))
		if s1 == 1 then v1 = 1 end
		s1 = s1 / 2
		v1 = (v1 + 1) / 2
		local col2 = HSVToColor(h1,s1,v1)
		for i=1,v do
			Label:InsertColorChange(col2.r,col2.g,col2.b,col2.a)
			Label:AppendText("\n\t"..npcprops2.Name)
		end
		haspops = true
	end
	if not haspops then
		Label:InsertColorChange(255,127,127,255)
		Label:AppendText("\n\t-")
	end
	Label:InsertColorChange(255,127,255,255)
	Label:AppendText("\nExtra Properties: ")
	if cvals.BalloonWhite then
		Label:InsertColorChange(255,255,255,255)
		Label:AppendText("\n\tFrost Immunity")
		hasimms = true
	end
	if cvals.BalloonBlimp then
		Label:InsertColorChange(255,255,255,255)
		Label:AppendText("\n\tFrost Immunity")
		Label:InsertColorChange(255,255,127,255)
		Label:AppendText("\n\tGlue Immunity")
		hasimms = true
	end
	if cvals.BalloonBlack then
		Label:InsertColorChange(127,127,127,255)
		Label:AppendText("\n\tExplosion Immunity")
		hasimms = true
	end
	if cvals.BalloonPurple then
		Label:InsertColorChange(191,127,255,255)
		Label:AppendText("\n\tMagic Immunity")
		hasimms = true
	end
	if cvals.BalloonGray then
		Label:InsertColorChange(191,191,191,255)
		Label:AppendText("\n\tBullet Immunity")
		Label:AppendText("\n\tLaceration Immunity")
		hasimms = true
	end
	if cvals.BalloonAqua then
		if not cvals.BalloonBlimp then
			Label:InsertColorChange(255,255,127,255)
			Label:AppendText("\n\tGlue Immunity")
		end
		--[[Label:InsertColorChange(127,255,255,255)
		Label:AppendText("\n\tMelee Immunity")]]
		hasimms = true
	end
	if cvals.BalloonArmor then
		Label:InsertColorChange(255,127,255,255)
		Label:AppendText("\n\tIgnores damage < "..(cvals.BalloonArmor+1).." layers")
		hasimms = true
	end
	if cvals.BalloonMaxDamage then
		Label:InsertColorChange(255,191,127,255)
		Label:AppendText("\n\tIgnores damage > "..cvals.BalloonMaxDamage.." layers")
		hasimms = true
	end
	if class == "gballoon_blimp_rainbow" then
		Label:InsertColorChange(255,255,0,255)
		Label:AppendText("\n\t")
		local text = "Regenerates "..math.Round(GetConVar("rotgb_rainbow_gblimp_regen_rate"):GetFloat()*200/3,2).." Health Per Second"
		for i=1,#text do
			local hue = math.Remap(i-1,0,#text,0,720)
			local color = HSVToColor(hue,0.5,1)
			Label:InsertColorChange(color:Unpack())
			Label:AppendText(text[i])
		end
	end
	if not hasimms then
		Label:InsertColorChange(255,127,127,255)
		Label:AppendText("\n\t-")
	end
	function Label:PerformLayout()
		self:SetBGColor(0,0,0,191)
		self:SetFontInternal("Trebuchet24")
	end
	ColumnSheet:AddSheet(npcprops.Name,Label)
end

--[=[local addonoffers = [[What This Addon Offers:

gBalloons
	17 different types
	4 different modifiers

gBlimps
	7 different types

Anti-gBalloon Towers
	12 different types

gBalloon Targets
	5 different health amounts
	can be set to be waypoints (gBalloons approach, then ignore)
	can be set to be damaged only by gBalloons

gBalloon Spawner
	initial wave can be set
	spawn rate can be set
	can be set to auto-start
	auto-start delay can be set
	auto-start can be forced

gBalloon Bestiary

2 tool gun modes
	RotgB Avoidance Editor
	gBalloon Target Waypoint Editor

PopSave™ system

]]]=]

net.Receive("RotgB_Bestiary",function(length,ply)
	if CLIENT then
		local Main = vgui.Create("DFrame")
		Main:SetSize(ScrW()/2,ScrH()/2)
		Main:SetSizable(true)
		Main:SetTitle("gBalloon Bestiary")
		Main:Center()
		Main:MakePopup()
		
		local ColumnSheet = Main:Add("DColumnSheet")
		ColumnSheet:Dock(FILL)
		
		local RichText = ColumnSheet:Add("RichText")
		RichText:Dock(FILL)
		RichText:SetText("")
		RichText:InsertColorChange(127,127,127,255)
		RichText:AppendText("Introduction\n\n")
		RichText:InsertColorChange(255,255,255,255)
		RichText:AppendText("The purpose of the RotgB Bestiary is to educate its readers about the potential dangers of the gBalloons, \z
		their statistics, immunities and weaknesses. Each gBalloon page describes about a gBalloon as well as its ")
		RichText:InsertColorChange(255,127,127,255)
		RichText:AppendText("Hit Points")
		RichText:InsertColorChange(255,255,255,255)
		RichText:AppendText(", ")
		RichText:InsertColorChange(255,255,127,255)
		RichText:AppendText("Red gBalloon Equivalent (RgBE)")
		RichText:InsertColorChange(255,255,255,255)
		RichText:AppendText(", ")
		RichText:InsertColorChange(127,255,127,255)
		RichText:AppendText("Size")
		RichText:InsertColorChange(255,255,255,255)
		RichText:AppendText(", ")
		RichText:InsertColorChange(127,255,255,255)
		RichText:AppendText("Speed")
		RichText:InsertColorChange(255,255,255,255)
		RichText:AppendText(", ")
		RichText:InsertColorChange(127,127,255,255)
		RichText:AppendText("Pop Products")
		RichText:InsertColorChange(255,255,255,255)
		RichText:AppendText(" and ")
		RichText:InsertColorChange(255,127,255,255)
		RichText:AppendText("Extra Properties")
		RichText:InsertColorChange(255,255,255,255)
		RichText:AppendText(". It should be noted that the statistics shown in the Bestiary are only accurate \z
		if the gBalloon server settings are set to their defaults (see Options > RotgB > Server Settings). \z
		With this book, it is hoped that its readers will have a better understanding on how to defeat each type of gBalloon, \z
		should they start to stir up harm.\n\n")
		RichText:InsertColorChange(127,127,127,255)
		RichText:AppendText("Respectfully,\nPiengineer of RandomTNT")
		function RichText:PerformLayout()
			self:SetBGColor(0,0,0,191)
			self:SetFontInternal("Trebuchet24")
		end
		ColumnSheet:AddSheet("Introduction",RichText)
		
		--[[RichText = ColumnSheet:Add("RichText")
		RichText:Dock(FILL)
		RichText:SetText("")
		RichText:InsertColorChange(255,255,255,255)
		RichText:AppendText(addonoffers)
		RichText:InsertColorChange(127,127,127,255)
		RichText:AppendText("-- if one or more features listed here are not available in this addon, please contact the customer service department of where you received this addon --")
		function RichText:PerformLayout()
			self:SetBGColor(63,63,63,255)
			self:SetFontInternal("Trebuchet24")
		end
		ColumnSheet:AddSheet("Addon Contents",RichText)]]
		
		for i,v in ipairs(order) do
			AddBalloon(ColumnSheet,v)
		end
	end
end)

function ENT:DrawTranslucent()
	self:Draw()
	--self:DrawModel()
	local text1 = "Press 'Use' to read."
	surface.SetFont("DermaLarge")
	local t1x,t1y = surface.GetTextSize(text1)
	local reqang = (self:GetPos()-LocalPlayer():GetShootPos()):Angle()
	reqang.p = 0
	reqang.y = reqang.y-90
	reqang.r = 90
	cam.Start3D2D(self:GetPos()+Vector(0,0,GetConVar("rotgb_hoverover_distance"):GetFloat()+t1y*0.1+self:OBBMaxs().z),reqang,0.2)
		surface.SetDrawColor(0,0,0,127)
		surface.DrawRect(t1x/-2,t1y/-2,t1x,t1y)
		surface.SetTextColor(0,255,0)
		surface.SetTextPos(t1x/-2,t1y/-2)
		surface.DrawText(text1)
	cam.End3D2D()
end

list.Set("NPC","gballoon_bestiary",{
	Name = "gBalloon Bestiary",
	Class = "gballoon_bestiary",
	Category = "RotgB: Miscellaneous"
})
list.Set("SpawnableEntities","gballoon_bestiary",{
	PrintName = "gBalloon Bestiary",
	ClassName = "gballoon_bestiary",
	Category = "RotgB: Miscellaneous"
})