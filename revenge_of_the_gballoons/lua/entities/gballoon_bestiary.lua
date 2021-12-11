AddCSLuaFile()

ENT.Type 				= "anim"
ENT.Base 				= "base_anim"
ENT.PrintName			= "RotgB Guide Book"
ENT.Purpose				= "The compendium of knowledge all about RotgB."
ENT.Instructions		= ""
ENT.Category			= "RotgB: Miscellaneous"
ENT.Author				= "Piengineer"
ENT.Contact				= "http://steamcommunity.com/id/Piengineer12/"
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
	if cvals.BalloonGlass then
		Label:AppendText("\n\t")
		local text = "Complete Immunity"
		for i=1,#text do
			local hue = math.Remap(i,1,#text,0,360)
			local color = HSVToColor(hue,0.5,1)
			Label:InsertColorChange(color.r, color.g, color.b, color.a)
			Label:AppendText(text[i])
		end
		hasimms = true
	end
	if cvals.BalloonVoid then
		Label:AppendText("\n\t")
		local text = "Cannot be detected by towers"
		for i=1,#text do
			local lum = math.Remap(i,1,#text,1,0.5)
			local color = HSVToColor(0,0,lum)
			Label:InsertColorChange(color.r, color.g, color.b, color.a)
			Label:AppendText(text[i])
		end
		hasimms = true
	end
	if class == "gballoon_blimp_rainbow" then
		Label:AppendText("\n\t")
		local text = "Regenerates "..math.Round(ROTGB_GetConVarValue("rotgb_rainbow_gblimp_regen_rate")*200/3,2).." Health Per Second"
		for i=1,#text do
			local hue = math.Remap(i,1,#text,0,720)
			local color = HSVToColor(hue,0.5,1)
			Label:InsertColorChange(color.r, color.g, color.b, color.a)
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

local addonoffers = [[What This Addon Offers:

RotgB Guide Book (Entities > RotgB: Miscellaneous)

1 weapon (Weapons > RotgB)
	RotgB Game SWEP

gBalloons (NPCs > RotgB)
	17 basic types (NPCs > RotgB: gBalloons)
	7 blimp types (NPCs > RotgB: gBlimps)
	4 miscellaneous types (NPCs > RotgB: gBalloons Miscellaneous)
	4 different modifiers (non-misc. only)

Anti-gBalloon Towers (Entities > RotgB: Towers)
	16 different types

gBalloon Spawner (Entities > RotgB: Miscellaneous)
	Can be set to spawn a custom wave (see rotgb_waveeditor ConCommand)
	Can be set to also start all other spawners
	Initial wave can be adjusted
	Spawn rate can be set
	Can be set to auto-start

gBalloon Targets (Entities > RotgB: Miscellaneous)
	5 different health amounts
	Can be set to be waypoints (gBalloons approach, then ignore)
	Can be linked to other waypoints
	Waypoint links can be set as gBlimp-only
	Can be set as teleportation waypoints
	Can be set to be damaged only by gBalloons

2 tool gun modes (Options > RotgB)
	RotgB Avoidance Editor
	gBalloon Target Waypoint Editor
]]

local credits = {
	{"Piengineer", "76561198144438879", "Creating most parts of the addon."},
	{"zorich_michael", "76561198196764081", "Suggested the waypoint system (2019-01-16)."},
	{"Sergius", "76561198293518598", "Suggested the Ally Pawn (2019-01-19)."},
	{"Fifu the Random Tribal Idiot", "76561198102225296", "Suggested the Orb of Cold (2019-01-28) and Microwave Tower (2019-02-10)."},
	{"Obsidian_The_Tempered", "76561198348095161", "Suggested the Ally Pawn (2019-02-07) and waypoint system (2019-03-03)."},
	{"Platless", "76561198822619008", "Suggested the Rainbow Beamer (2019-02-13)."},
	{"Sir. Vapenation", "76561198143774099", "Suggested the waypoint system (2019-03-18), Hoverball Factory (2019-03-18) and Turret Factory (2019-03-18)."},
	{"mushroom", "76561198337193083", "Suggested the Bishop of Glue (2019-05-06)."},
	{"Devro", "76561198363697889", "Suggested the Mortar Tower (2019-05-06)."},
	{"itachi209", "76561198352896173", "Suggested the Glass gBalloon (2019-05-29)."},
	{"PDA Expert", "76561198024198604", "Suggested the Sawblade Launcher (2019-07-12), Turret Factory (2020-02-13) and Pill Lobber (2020-12-26)."},
	{"Conga Dispenser", "76561198361428640", "Suggested the Mortar Tower (2019-07-17), waypoint multi-path system (2019-09-01), individual cash system (2019-09-01), custom wave editor (2019-09-24) and gBalloon Target instant teleportation (2020-10-29)."},
	{"SkyanUltra", "76561198147466564", "Suggested option to bypass upgrade path restrictions (2019-07-21)."},
	{"BFR2005", "76561198089249743", "Suggested the Fire Cube (2019-07-30)."},
	{"PoopStomp9000", "76561198274942231", "Suggested the custom wave editor (2019-09-24)."},
	{"fansided", "76561198117057248", "Suggested multi-gBalloon Spawner activation (2020-03-03)."},
	{"PuggleLeDog", "76561198120548061", "Suggested BTD4 Camo gBalloon (2020-10-04) and gBlimps with attributes (2020-10-04)."},
	{"Ryankz11", "76561198004803429", "Suggested removal of annoying NavMesh missing message (2020-10-04)."},
	{"Fatal Error Sans", "id/legosilverking", "Suggested many, many bug fixes, balance changes and ideas, as well as playtesting experimental addon versions (2021-08-02)."},
	{"<various people>", nil, "For reporting many of the other bugs and balance changes with this addon."}
}

local creditsUnimplemented = {
	{"Xtrah962", "76561198853380897", "Suggested a crowbar / melee tower (2019-01-28)."},
	{"SarnieMuncher", "76561198154658331", "Suggested for holdable gBalloons (2019-08-29)."},
	{"[WLS] Ziggy Gaming", "id/ziggyevolved", "Suggested many, many more gBalloon types (2020-04-21)."},
	{"dogethedoggo", "76561198857378000", "Suggested the Gravity Blaster (2020-08-11)."},
	{"Goat Child", "76561199014467773", "Suggested for gBalloons to be availble for the Balloon tool (2020-12-12)."},
	{"<various people>", nil, "Many other suggestions that ultimately did not make it."}
}

net.Receive("RotgB_Bestiary",function(length,ply)
	if CLIENT then
		local Main = vgui.Create("DFrame")
		Main:SetSize(ScrW()/2,ScrH()/2)
		Main:SetSizable(true)
		Main:SetTitle("RotgB Guide Book")
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
		RichText:AppendText("This is the guide book for RotgB, which aims to tell about how to use the addon effectively,\z
		as well as listing the gBalloons statistics, immunities and weaknesses.\n\n\z
		Each gBalloon page describes about a gBalloon as well as its Hit Points, Red gBalloon Equivalent (RgBE), Size, Speed, Pop Products and Extra Properties. \z
		It should be noted that the gBalloons' statistics shown in the Guide Book are only accurate \z
		if the gBalloon server settings are set to their defaults (see Options > RotgB > Server Settings).\n\n\z
		More information will be added to this book if deemed neccessary.\n\n")
		RichText:InsertColorChange(127,127,127,255)
		RichText:AppendText("- Piengineer")
		function RichText:PerformLayout()
			self:SetBGColor(0,0,0,191)
			self:SetFontInternal("Trebuchet24")
		end
		ColumnSheet:AddSheet("Introduction",RichText)
		
		RichText = ColumnSheet:Add("RichText")
		RichText:Dock(FILL)
		RichText:SetText("")
		RichText:InsertColorChange(255,255,255,255)
		RichText:AppendText(addonoffers)
		RichText:InsertColorChange(127,127,127,255)
		RichText:AppendText("\n-- if one or more features listed here are not available in this addon, please contact the customer service department of where you received this addon --")
		function RichText:PerformLayout()
			self:SetBGColor(0,0,0,191)
			self:SetFontInternal("Trebuchet24")
		end
		ColumnSheet:AddSheet("Addon Contents",RichText)
		
		local CreditsPanel = ColumnSheet:Add("DScrollPanel")
		CreditsPanel:Dock(FILL)
		local Canvas = CreditsPanel:GetCanvas()
		function Canvas:Paint(w,h)
			surface.SetDrawColor(0,0,0,191)
			surface.DrawRect(0,0,w,h)
		end
		function CreditsPanel:CreateCredit(tab)
			local CreditPanel = CreditsPanel:Add("DPanel")
			CreditPanel:SetTall(36)
			CreditPanel:Dock(TOP)
			function CreditPanel:Paint(w,h)
				--surface.SetDrawColor(0,0,0)
				--surface.DrawOutlinedRect(0,0,w,h,1)
			end
			local AuthorButton = CreditPanel:Add("DButton")
			AuthorButton:SetWide(160)
			AuthorButton:SetText(tab[1])
			function AuthorButton:DoClick()
				if tab[2] then
					if tab[2]:StartWith("id/") then
						gui.OpenURL("https://steamcommunity.com/"..tab[2])
					else
						gui.OpenURL("https://steamcommunity.com/profiles/"..tab[2])
					end
				end
			end
			AuthorButton:Dock(LEFT)
			
			local ContributionText = CreditPanel:Add("DLabel")
			ContributionText:DockMargin(8,0,0,0)
			ContributionText:SetText(tab[3])
			ContributionText:SetTextColor(color_white)
			ContributionText:SetWrap(true)
			ContributionText:Dock(FILL)
		end
		ColumnSheet:AddSheet("Credits",CreditsPanel)
		
		local CreditsText = CreditsPanel:Add("DLabel")
		CreditsText:SetText("Credits:")
		CreditsText:SetTextColor(color_white)
		CreditsText:SetFont("Trebuchet24")
		CreditsText:SizeToContentsY()
		CreditsText:Dock(TOP)
		
		for i,v in ipairs(credits) do
			CreditsPanel:CreateCredit(v)
		end
		
		CreditsText = CreditsPanel:Add("DLabel")
		CreditsText:DockMargin(0,12,0,0)
		CreditsText:SetText("Honourable mentions, who's suggestions I liked but are not present in the addon:")
		CreditsText:SetTextColor(color_white)
		CreditsText:SetFont("Trebuchet24")
		CreditsText:SizeToContentsY()
		CreditsText:Dock(TOP)
		
		for i,v in ipairs(creditsUnimplemented) do
			CreditsPanel:CreateCredit(v)
		end
		
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
	cam.Start3D2D(self:GetPos()+Vector(0,0,ROTGB_GetConVarValue("rotgb_hoverover_distance")+t1y*0.1+self:OBBMaxs().z),reqang,0.2)
		surface.SetDrawColor(0,0,0,127)
		surface.DrawRect(t1x/-2,t1y/-2,t1x,t1y)
		surface.SetTextColor(0,255,0)
		surface.SetTextPos(t1x/-2,t1y/-2)
		surface.DrawText(text1)
	cam.End3D2D()
end

list.Set("NPC","gballoon_bestiary",{
	Name = "RotgB Guide Book",
	Class = "gballoon_bestiary",
	Category = "RotgB: Miscellaneous"
})
list.Set("SpawnableEntities","gballoon_bestiary",{
	PrintName = "RotgB Guide Book",
	ClassName = "gballoon_bestiary",
	Category = "RotgB: Miscellaneous"
})