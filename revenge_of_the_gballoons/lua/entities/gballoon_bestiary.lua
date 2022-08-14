AddCSLuaFile()

ENT.Type 				= "anim"
ENT.Base 				= "base_anim"
ENT.PrintName			= "#rotgb.guide"
ENT.Purpose				= "#rotgb.guide.purpose"
ENT.Instructions		= "#rotgb.guide.instructions"
ENT.Category			= "#rotgb.category.miscellaneous"
ENT.Author				= "Piengineer12"
ENT.Contact				= "http://steamcommunity.com/id/Piengineer12/"
ENT.Spawnable			= false
ENT.AdminOnly			= false
ENT.RenderGroup			= RENDERGROUP_BOTH
ENT.DisableDuplicator	= false

if SERVER then
	util.AddNetworkString("RotgB_Bestiary")
end

if CLIENT then
	concommand.Add("rotgb_guide_book", function()
		net.Start("RotgB_Bestiary", true)
		net.SendToServer()
	end)
	
	surface.CreateFont("RotgBGuideBook", {
		font = "Trebuchet MS",
		extended = true,
		size = 24
	})
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

local function AddBalloon(Label,class)
	local npcprops = list.GetForEdit("NPC")[class]
	local cvals = npcprops.KeyValues
	local typ = cvals.BalloonType
	local hasimms,haspops
	local h1,s1,v1 = ColorToHSV(string.ToColor(cvals.BalloonColor))
	if s1 == 1 then v1 = 1 end
	s1 = s1 / 2
	v1 = (v1 + 1) / 2
	local col2 = HSVToColor(h1,s1,v1)
	Label:InsertColorChange(col2.r,col2.g,col2.b,col2.a)
	Label:AppendText("\n\n"..language.GetPhrase("rotgb.gballoon."..typ))
	Label:InsertColorChange(255,127,127,255)
	Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.health", cvals.BalloonHealth or 1))
	Label:InsertColorChange(255,255,127,255)
	Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.rgbe", scripted_ents.Get("gballoon_base").rotgb_rbetab[class]))
	Label:InsertColorChange(127,255,127,255)
	Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.size", cvals.BalloonScale or 1))
	Label:InsertColorChange(127,255,255,255)
	Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.speed", cvals.BalloonMoveSpeed or 100))
	Label:InsertColorChange(127,127,255,255)
	Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.children"))
	for k,v in pairs(baseclass.Get("gballoon_base").rotgb_spawns[class] or {}) do
		local keyValues = list.GetForEdit("NPC")[k].KeyValues
		local h1,s1,v1 = ColorToHSV(string.ToColor(keyValues.BalloonColor))
		if s1 == 1 then v1 = 1 end
		s1 = s1 / 2
		v1 = (v1 + 1) / 2
		local col2 = HSVToColor(h1,s1,v1)
		for i=1,v do
			Label:InsertColorChange(col2.r,col2.g,col2.b,col2.a)
			Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.children.entry", ROTGB_GetBalloonName(keyValues.BalloonType, keyValues.BalloonFast, keyValues.BalloonHidden, keyValues.BalloonRegen, keyValues.BalloonShielded)))
		end
		haspops = true
	end
	if not haspops then
		Label:InsertColorChange(255,127,127,255)
		Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.children.no_entries"))
	end
	Label:InsertColorChange(255,127,255,255)
	Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.extra_properties"))
	if cvals.BalloonWhite then
		Label:InsertColorChange(255,255,255,255)
		Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.extra_properties.white"))
		hasimms = true
	end
	if cvals.BalloonBlimp then
		Label:InsertColorChange(255,255,255,255)
		Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.extra_properties.white"))
		Label:InsertColorChange(255,255,127,255)
		Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.extra_properties.aqua"))
		hasimms = true
	end
	if cvals.BalloonBlack then
		Label:InsertColorChange(127,127,127,255)
		Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.extra_properties.black"))
		hasimms = true
	end
	if cvals.BalloonPurple then
		Label:InsertColorChange(191,127,255,255)
		Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.extra_properties.purple"))
		hasimms = true
	end
	if cvals.BalloonGray then
		Label:InsertColorChange(191,191,191,255)
		Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.extra_properties.gray"))
		hasimms = true
	end
	if cvals.BalloonAqua then
		if not cvals.BalloonBlimp then
			Label:InsertColorChange(255,255,127,255)
			Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.extra_properties.aqua"))
		end
		--[[Label:InsertColorChange(127,255,255,255)
		Label:AppendText("\n\tMelee Immunity")]]
		hasimms = true
	end
	if cvals.BalloonArmor then
		Label:InsertColorChange(255,127,255,255)
		Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.extra_properties.armor", cvals.BalloonArmor+1))
		hasimms = true
	end
	if cvals.BalloonMaxDamage then
		Label:InsertColorChange(255,191,127,255)
		Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.extra_properties.max_damage", cvals.BalloonMaxDamage))
		hasimms = true
	end
	if cvals.BalloonGlass then
		Label:AppendText("\n")
		local text = ROTGB_LocalizeString("rotgb.guide.gballoon.extra_properties.glass")
		local size = utf8.len(text) or #text
		for i=1,size do
			local hue = math.Remap(i,1,size,0,360)
			local color = HSVToColor(hue,0.5,1)
			Label:InsertColorChange(color.r, color.g, color.b, color.a)
			Label:AppendText(text[i])
		end
		hasimms = true
	end
	if cvals.BalloonVoid then
		Label:AppendText("\n")
		local text = ROTGB_LocalizeString("rotgb.guide.gballoon.extra_properties.void")
		local size = utf8.len(text) or #text
		for i=1,size do
			local lum = math.Remap(i,1,size,1,0.5)
			local color = HSVToColor(0,0,lum)
			Label:InsertColorChange(color.r, color.g, color.b, color.a)
			Label:AppendText(text[i])
		end
		hasimms = true
	end
	if cvals.BalloonSuperRegen then
		Label:AppendText("\n")
		local text = ROTGB_LocalizeString("rotgb.guide.gballoon.extra_properties.super_regen", string.format("%.2f", 200*cvals.BalloonSuperRegen))
		local size = utf8.len(text) or #text
		for i=1,size do
			local hue = math.Remap(i,1,size,0,720)%360
			local color = HSVToColor(hue,0.5,1)
			Label:InsertColorChange(color.r, color.g, color.b, color.a)
			Label:AppendText(text[i])
		end
	end
	if not hasimms then
		Label:InsertColorChange(255,127,127,255)
		Label:AppendText("\n"..ROTGB_LocalizeString("rotgb.guide.gballoon.extra_properties.none"))
	end
	function Label:PerformLayout()
		self:SetBGColor(0,0,0,191)
		self:SetFontInternal("RotgBGuideBook")
	end
end

local credits = {
	{"Piengineer12", "76561198144438879"},
	{"zorich_michael", "76561198196764081"},
	{"Sergius", "76561198293518598"},
	{"DreamySaeneryth", "76561198102225296"},
	{"Bluu_Luna", "76561198348095161"},
	{"Platless", "76561198822619008"},
	{"Sir. Vapenation", "76561198143774099"},
	{"liptard", "76561198337193083"},
	{"Devro", "76561198363697889"},
	{"itachi209", "76561198352896173"},
	{"PDA Expert", "76561198024198604"},
	{"Conga Dispenser", "76561198361428640"},
	{"SkyanUltra", "76561198147466564"},
	{"BFR2005", "76561198089249743"},
	{"gormless minger", "76561198274942231"},
	{"fansided", "76561198117057248"},
	{"PuggleLeDog", "76561198120548061"},
	{"The Bender™", "76561198004803429"},
	{"FallenVoid", "76561198178506377"},
	{"berry", "76561198158864042"},
	{"glamrock neon plushtrap", "76561198804430511"},
	{"#rotgb.guide.contributors.person.various"}
}

local creditsUnimplemented = {
	{"Xtrah962", "76561198853380897"},
	{"SarnieMuncher", "76561198154658331"},
	{"ziggyevolved", "76561198218939972"},
	{"Ralsei smoking a fat doobie", "76561198857378000"},
	{"Dr. Science guy dude", "76561199014467773"},
	{"#rotgb.guide.contributors.person.various"}
}

net.Receive("RotgB_Bestiary",function(length,ply)
	if SERVER then
		net.Start("RotgB_Bestiary", true)
		net.Send(ply)
	end
	
	if CLIENT then
		local Main = vgui.Create("DFrame")
		Main:SetSize(ScrW()/2,ScrH()/2)
		Main:SetSizable(true)
		Main:SetTitle("#rotgb.guide")
		Main:Center()
		Main:MakePopup()
		
		local ColumnSheet = Main:Add("DColumnSheet")
		ColumnSheet:Dock(FILL)
		
		local RichText = ColumnSheet:Add("RichText")
		RichText:Dock(FILL)
		RichText:SetText("")
		RichText:InsertColorChange(127,127,127,255)
		RichText:AppendText(ROTGB_LocalizeString("rotgb.guide.introduction"))
		RichText:InsertColorChange(255,255,255,255)
		RichText:AppendText(ROTGB_LocalizeString("rotgb.guide.description"))
		RichText:InsertColorChange(127,127,127,255)
		RichText:AppendText("- Piengineer12")
		function RichText:PerformLayout()
			self:SetBGColor(0,0,0,191)
			self:SetFontInternal("RotgBGuideBook")
		end
		ColumnSheet:AddSheet("#rotgb.guide.page.introduction",RichText)
		
		RichText = ColumnSheet:Add("RichText")
		RichText:Dock(FILL)
		RichText:SetText("")
		RichText:InsertColorChange(255,255,255,255)
		RichText:AppendText(ROTGB_LocalizeString("rotgb.guide.page.core_concepts"))
		local i = 1
		local headerToken = "rotgb.guide.core_concepts.1.header"
		while ROTGB_HasLocalization(headerToken) do
			RichText:InsertColorChange(255,255,0,255)
			RichText:AppendText("\n\n"..ROTGB_LocalizeString(headerToken))
			
			local descriptionToken = string.format("rotgb.guide.core_concepts.%u.description", i)
			RichText:InsertColorChange(255,255,255,255)
			RichText:AppendText('\n'..ROTGB_LocalizeString(descriptionToken))
			
			i = i + 1
			headerToken = string.format("rotgb.guide.core_concepts.%u.header", i)
		end
		RichText:InsertColorChange(255,255,255,255)
		RichText:AppendText("\n\n"..ROTGB_LocalizeString("rotgb.guide.core_concepts.extra"))
		function RichText:PerformLayout()
			self:SetBGColor(0,0,0,191)
			self:SetFontInternal("RotgBGuideBook")
		end
		ColumnSheet:AddSheet("#rotgb.guide.page.core_concepts",RichText)
		
		RichText = ColumnSheet:Add("RichText")
		RichText:Dock(FILL)
		RichText:SetText("")
		RichText:InsertColorChange(255,255,255,255)
		RichText:AppendText(ROTGB_LocalizeString("rotgb.guide.what_this_addon_offers"))
		RichText:InsertColorChange(127,127,127,255)
		RichText:AppendText(ROTGB_LocalizeString("rotgb.guide.what_this_addon_offers.customer_support"))
		function RichText:PerformLayout()
			self:SetBGColor(0,0,0,191)
			self:SetFontInternal("RotgBGuideBook")
		end
		ColumnSheet:AddSheet("#rotgb.guide.page.what_this_addon_offers",RichText)
		
		RichText = ColumnSheet:Add("RichText")
		RichText:Dock(FILL)
		RichText:SetText("")
		RichText:InsertColorChange(255,255,255,255)
		RichText:AppendText(ROTGB_LocalizeString("rotgb.guide.page.gballoons"))
		for i,v in ipairs(order) do
			AddBalloon(RichText,v)
		end
		function RichText:PerformLayout()
			self:SetBGColor(0,0,0,191)
			self:SetFontInternal("RotgBGuideBook")
		end
		ColumnSheet:AddSheet("#rotgb.guide.page.gballoons",RichText)
		
		local CreditsPanel = ColumnSheet:Add("DScrollPanel")
		CreditsPanel:Dock(FILL)
		local Canvas = CreditsPanel:GetCanvas()
		function Canvas:Paint(w,h)
			surface.SetDrawColor(0,0,0,191)
			surface.DrawRect(0,0,w,h)
		end
		function CreditsPanel:CreateCredit(tab, creditString)
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
			ContributionText:SetText(ROTGB_LocalizeString(creditString))
			ContributionText:SetTextColor(color_white)
			ContributionText:SetWrap(true)
			ContributionText:Dock(FILL)
		end
		ColumnSheet:AddSheet("#rotgb.guide.page.contributors",CreditsPanel)
		
		local CreditsText = CreditsPanel:Add("DLabel")
		CreditsText:SetText("#rotgb.guide.contributors")
		CreditsText:SetTextColor(color_white)
		CreditsText:SetFont("RotgBGuideBook")
		CreditsText:SizeToContentsY()
		CreditsText:Dock(TOP)
		
		for i,v in ipairs(credits) do
			CreditsPanel:CreateCredit(v, string.format("rotgb.guide.contributors.%i", i))
		end
		
		CreditsText = CreditsPanel:Add("DLabel")
		CreditsText:DockMargin(0,12,0,0)
		CreditsText:SetText("#rotgb.guide.contributors.unimplemented")
		CreditsText:SetTextColor(color_white)
		CreditsText:SetFont("RotgBGuideBook")
		CreditsText:SizeToContentsY()
		CreditsText:Dock(TOP)
		
		for i,v in ipairs(creditsUnimplemented) do
			CreditsPanel:CreateCredit(v, string.format("rotgb.guide.contributors.unimplemented.%i", i))
		end
	end
end)

function ENT:DrawTranslucent()
	self:Draw()
	--self:DrawModel()
	local text1 = "#rotgb.guide.instructions"
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
	Name = "#rotgb.guide",
	Class = "gballoon_bestiary",
	Category = "#rotgb.category.miscellaneous"
})
list.Set("SpawnableEntities","gballoon_bestiary",{
	PrintName = "#rotgb.guide",
	ClassName = "gballoon_bestiary",
	Category = "#rotgb.category.miscellaneous"
})