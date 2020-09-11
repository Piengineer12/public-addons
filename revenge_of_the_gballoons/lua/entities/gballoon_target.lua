AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "gBalloon Target"
ENT.Category = "RotgB: Miscellaneous"
ENT.ScriptedEntityType = "entity"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "As a target for rouge gBalloons."
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Editable = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.DisableDuplicator = false

ROTGB_CASH = ROTGB_CASH or 0

function ROTGB_SetCash(num,ply)
	if GetConVar("rotgb_individualcash"):GetBool() then
		if ply then
			ply.ROTGB_CASH = tonumber(num) or 0
			ply:SetNWInt("ROTGB_CASH",num)
		else
			for k,v in pairs(player.GetAll()) do
				v.ROTGB_CASH = tonumber(num) or 0
				v:SetNWInt("ROTGB_CASH",num)
			end
		end
	else
		ROTGB_CASH = tonumber(num) or 0
		SetGlobalInt("ROTGB_CASH",ROTGB_CASH)
	end
end

function ROTGB_GetCash(ply)
	if GetConVar("rotgb_individualcash"):GetBool() then
		ply = ply or CLIENT and LocalPlayer()
		if ply then
			if ply:GetNWInt("ROTGB_CASH",-1) ~= -1 then ply.ROTGB_CASH = ply:GetNWInt("ROTGB_CASH") end
			return ply.ROTGB_CASH or 0
		else
			local average = 0
			for k,v in pairs(player.GetAll()) do
				if v:GetNWInt("ROTGB_CASH",-1) ~= -1 then v.ROTGB_CASH = v:GetNWInt("ROTGB_CASH") end
				average = average + v.ROTGB_CASH
			end
			return average
		end
	else
		if GetGlobalInt("ROTGB_CASH",-1) ~= -1 then ROTGB_CASH = GetGlobalInt("ROTGB_CASH") end
		return ROTGB_CASH or 0
	end
end

function ROTGB_AddCash(num,ply)
	num = tonumber(num) or 0
	if GetConVar("rotgb_individualcash"):GetBool() then
		if ply then
			ROTGB_SetCash(ROTGB_GetCash(ply)+num,ply)
		else
			local count = player.GetCount()
			for k,v in pairs(player.GetAll()) do
				ROTGB_SetCash(ROTGB_GetCash(v)+num/count,v)
			end
		end
	else
		ROTGB_SetCash(ROTGB_GetCash()+num)
	end
end

function ROTGB_RemoveCash(num,ply)
	num = tonumber(num) or 0
	if GetConVar("rotgb_individualcash"):GetBool() then
		if ply then
			ROTGB_SetCash(ROTGB_GetCash(ply)-num,ply)
		else
			local count = player.GetCount()
			for k,v in pairs(player.GetAll()) do
				ROTGB_SetCash(ROTGB_GetCash(v)-num/count,v)
			end
		end
	else
		ROTGB_SetCash(ROTGB_GetCash()-num)
	end
end

local ConH,ConE,ConX,ConY,ConS,ConF,ConG,ConQ

if SERVER then
	hook.Add("Think","RotgB2",function()
		if ROTGB_GetCash()==0 and GetConVar("rotgb_starting_cash"):GetFloat()~=0 then
			ROTGB_SetCash(GetConVar("rotgb_starting_cash"):GetFloat())
		elseif player.GetCount() > 0 then
			hook.Remove("Think","RotgB2")
		end
	end)
	
	hook.Add("PlayerSpawn","RotgB2",function(ply)
		if GetConVar("rotgb_individualcash"):GetBool() and GetConVar("rotgb_starting_cash"):GetFloat()~=0 then
			ROTGB_SetCash(GetConVar("rotgb_starting_cash"):GetFloat(), ply)
		end
	end)
end

if CLIENT then -- START CLIENT

ConH = CreateClientConVar("rotgb_hoverover_distance","15",true,false,
[[Determines the height of the text hovering above the gBalloon Spawner and gBalloon Targets.]])

ConE = CreateClientConVar("rotgb_hud_enabled","1",true,false,
[[Determines the visibility of the cash display.]])

ConX = CreateClientConVar("rotgb_hud_x","0.1",true,false,
[[Determines the horizontal position of the cash display.]])

ConY = CreateClientConVar("rotgb_hud_y","0.1",true,false,
[[Determines the vertical position of the cash display.]])

ConS = CreateClientConVar("rotgb_hud_size","32",true,false,
[[Determines the size of the cash display. Requires restart to take effect.]])

ConF = CreateClientConVar("rotgb_freeze_effect","0",true,false,
[[Shows the freezing effect when a gBalloon is frozen.
 - Only enable this if you have a high-end PC.]])

ConG = CreateClientConVar("rotgb_no_glow","0",true,false,
[[Disable all halo effects, including the turquoise halo around purple gBalloons.
 - Only enable this if you have a low-end PC.]])

ConQ = CreateClientConVar("rotgb_circle_segments","24",true,false,
[[Sets the number of sides each drawn "circle" has.
 - Lowering this value can improve performance.]])

local function CreateGBFont(cv,ov,fontsize)
surface.CreateFont("RotgB_font",{
	font="Luckiest Guy",
	size=fontsize
})
end

CreateGBFont(nil,nil,ConS:GetFloat())

hook.Add("InitPostEntity","RotgB",function()
	CreateGBFont(nil,nil,ConS:GetFloat())
end)

local coinmat = Material("icon16/coins.png")
hook.Add("HUDPaint","RotgB",function()
	if ConE:GetBool() then
		surface.SetDrawColor(color_white)
		surface.SetMaterial(coinmat)
		surface.DrawTexturedRect(ConX:GetFloat()*ScrW(),ConY:GetFloat()*ScrH(),ConS:GetFloat(),ConS:GetFloat())
		local cash = ROTGB_GetCash(LocalPlayer())
		if cash==math.huge then -- number is inf
			draw.SimpleTextOutlined("$∞","RotgB_font",ConX:GetFloat()*ScrW()+ConS:GetFloat(),ConY:GetFloat()*ScrH(),color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
		elseif cash==-math.huge then -- number is negative inf
			draw.SimpleTextOutlined("$-∞","RotgB_font",ConX:GetFloat()*ScrW()+ConS:GetFloat(),ConY:GetFloat()*ScrH(),color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
		elseif cash<math.huge and cash>-math.huge then -- number is real
			draw.SimpleTextOutlined("$"..math.floor(cash),"RotgB_font",ConX:GetFloat()*ScrW()+ConS:GetFloat(),ConY:GetFloat()*ScrH(),color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
		else -- number isn't a number. Caused by inf minus inf
			draw.SimpleTextOutlined("$☠","RotgB_font",ConX:GetFloat()*ScrW()+ConS:GetFloat(),ConY:GetFloat()*ScrH(),color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
		end
	end
end)

hook.Add("AddToolMenuTabs","RotgB",function()
	spawnmenu.AddToolTab("Options")
end)

hook.Add("AddToolMenuCategories","RotgB",function()
	spawnmenu.AddToolCategory("Options","RotgB","RotgB")
end)

--[[local order = {
	"gballoon_red",
	"gballoon_blue",
	"gballoon_green",
	"gballoon_yellow",
	"gballoon_pink",
	"gballoon_white",
	"gballoon_black",
	"gballoon_purple",
	"gballoon_orange",
	"gballoon_gray",
	"gballoon_zebra",
	"gballoon_aqua",
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
}

local function AddBalloon(CategoryList,class)
	local npcprops = list.GetForEdit("NPC")[class]
	local cvals = npcprops.KeyValues
	local Category = CategoryList:Add(npcprops.Name)
	Category:SetHeight(256)
	local Label = vgui.Create("RichText",Category)
	local hasimms,haspops
	Label:Dock(FILL)
	Label:SetText("")
	Label:InsertColorChange(255,127,127,255)
	Label:AppendText("Health: "..(cvals.BalloonHealth or 1))
	Label:InsertColorChange(255,255,127,255)
	Label:AppendText("\nRgBE: "..baseclass.Get("gballoon_base").rotgb_rbetab[class])
	Label:InsertColorChange(127,255,127,255)
	Label:AppendText("\nSize: "..(cvals.BalloonScale or 1))
	Label:InsertColorChange(127,255,255,255)
	Label:AppendText("\nSpeed: "..(cvals.BalloonMoveSpeed or 100))
	Label:InsertColorChange(127,127,255,255)
	Label:AppendText("\nOn pop, spawns the following:")
	for k,v in pairs(baseclass.Get("gballoon_base").rotgb_spawns[class] or {}) do
		local npcprops2 = list.GetForEdit("NPC")[v]
		local h1,s1,v1 = ColorToHSV(string.ToColor(npcprops2.KeyValues.BalloonColor))
		if s1 == 1 then v1 = 1 end
		s1 = s1 / 2
		v1 = (v1 + 1) / 2
		local col2 = HSVToColor(h1,s1,v1)
		Label:InsertColorChange(col2.r,col2.g,col2.b,col2.a)
		Label:AppendText("\n\t"..npcprops2.Name)
		haspops = true
	end
	if not haspops then
		Label:InsertColorChange(255,127,127,255)
		Label:AppendText("\n\tNone")
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
		hasimms = true
	end
	if cvals.BalloonAqua then
		Label:InsertColorChange(127,255,255,255)
		Label:AppendText("\n\tMelee Immunity")
		hasimms = true
	end
	if cvals.BalloonArmor then
		Label:InsertColorChange(255,127,255,255)
		Label:AppendText("\n\tIgnores damage < "..cvals.BalloonArmor.." layers")
		hasimms = true
	end
	if not hasimms then
		Label:InsertColorChange(255,127,127,255)
		Label:AppendText("\n\tNone")
	end
	function Label:PerformLayout()
		self:SetBGColor(63,63,63,255)
	end
	Category:DoExpansion(false)
end]]

hook.Add("PopulateToolMenu","RotgB",function()
	spawnmenu.AddToolMenuOption("Options","RotgB","RotgB_Options_Server","Server + Cash Options","","",function(DForm) -- Add panel
		DForm:Help("") --whitespace
		DForm:ControlHelp("Addon not working as intended?")
		local dangerbutton = DForm:Button("Set All ConVars To Default","rotgb_reset_convars")
		dangerbutton:SetTextColor(Color(255,0,0))
		local DTextEntry = DForm:TextEntry("Debug Parameters","rotgb_debug")
		function DTextEntry:GetAutoComplete(text)
			local dbags = baseclass.Get("gballoon_base").DebugArgs
			local last = string.match(text,"[%w_]+$") or ""
			if last==text then
				text=""
			else
				text = text:sub(1,-#last-1)
			end
			local adctab = {}
			for i,v in ipairs(dbags) do
				if string.find(v,"^"..last) and not string.match(text," ?"..v.." ?") then
					table.insert(adctab,text..v)
				end
			end
			return adctab
		end
		DForm:Help(" - "..GetConVar("rotgb_debug"):GetHelpText().."\n")
		
		DForm:Help("") --whitespace
		DForm:ControlHelp("Cash Settings")
		DForm:TextEntry("Cash Value","rotgb_cash_param")
		DForm:Help(" - "..GetConVar("rotgb_cash_param"):GetHelpText().."\n")
		DForm:Button("Set Cash","rotgb_setcash","*")
		DForm:Button("Add Cash","rotgb_addcash","*")
		DForm:Button("Subtract Cash","rotgb_subcash","*")
		DForm:Help("Preset Values:")
		DForm:Button("Set Value to 0","rotgb_cash_param_internal","0")
		DForm:Button("Set Value to 650","rotgb_cash_param_internal","650")
		DForm:Button("Set Value to 850","rotgb_cash_param_internal","850")
		DForm:Button("Set Value to 20000","rotgb_cash_param_internal","20000")
		DForm:Button("Set Value to ∞","rotgb_cash_param_internal","0x1p128")
		DForm:Help("You can use the ConCommmands rotgb_setcash, rotgb_addcash and rotgb_subcash to modify the cash value.\n")
		DForm:NumSlider("Cash Multiplier","rotgb_cash_mul",0,10,3)
		DForm:Help(" - "..GetConVar("rotgb_cash_mul"):GetHelpText().."\n")
		DForm:CheckBox("Split Cash Between Players","rotgb_individualcash")
		DForm:Help(" - "..GetConVar("rotgb_individualcash"):GetHelpText().."\n")
		DForm:NumSlider("Starting Cash","rotgb_starting_cash",0,1000,0)
		DForm:Help(" - "..GetConVar("rotgb_starting_cash"):GetHelpText().."\n")
		
		DForm:Help("") --whitespace
		DForm:ControlHelp("Tower Settings")
		DForm:CheckBox("Ignore Upgrade Limits","rotgb_ignore_upgrade_limits")
		DForm:Help(" - "..GetConVar("rotgb_ignore_upgrade_limits"):GetHelpText().."\n")
		DForm:NumSlider("Damage Multiplier","rotgb_damage_multiplier",0,10,3)
		DForm:Help(" - "..GetConVar("rotgb_damage_multiplier"):GetHelpText().."\n")
		DForm:NumSlider("Range Multiplier","rotgb_tower_range_multiplier",0,10,3)
		DForm:Help(" - "..GetConVar("rotgb_tower_range_multiplier"):GetHelpText().."\n")
		--[[DForm:NumSlider("Targets","rotgb_extratargets",-1,511,0)
		DForm:Help(" - "..GetConVar("rotgb_extratargets"):GetHelpText().."\n")]]
		
		DForm:Help("") --whitespace
		DForm:ControlHelp("gBalloon Settings")
		DForm:CheckBox("Enable Freeplay","rotgb_freeplay")
		DForm:Help(" - "..GetConVar("rotgb_freeplay"):GetHelpText().."\n")
		DForm:NumSlider("Fire Damage Delay","rotgb_fire_delay",0,10,3)
		DForm:Help(" - "..GetConVar("rotgb_fire_delay"):GetHelpText().."\n")
		DForm:NumSlider("Regen Delay","rotgb_regen_delay",0,10,3)
		DForm:Help(" - "..GetConVar("rotgb_regen_delay"):GetHelpText().."\n")
		DForm:NumSlider("Rainbow Rate","rotgb_rainbow_gblimp_regen_rate",0,10,3)
		DForm:Help(" - "..GetConVar("rotgb_rainbow_gblimp_regen_rate"):GetHelpText().."\n")
		DForm:NumSlider("gBalloon Scale","rotgb_scale",0,10,3)
		DForm:Help(" - "..GetConVar("rotgb_scale"):GetHelpText().."\n")
		DForm:NumSlider("Health Multiplier","rotgb_health_multiplier",0,10,3)
		DForm:Help(" - "..GetConVar("rotgb_health_multiplier"):GetHelpText().."\n")
		DForm:NumSlider("Blimp Health Multiplier","rotgb_blimp_health_multiplier",0,10,3)
		DForm:Help(" - "..GetConVar("rotgb_blimp_health_multiplier"):GetHelpText().."\n")
		DForm:NumSlider("Aff. Damage Multiplier","rotgb_afflicted_damage_multiplier",0,10,3)
		DForm:Help(" - "..GetConVar("rotgb_afflicted_damage_multiplier"):GetHelpText().."\n")
		DForm:CheckBox("Ignore Damage Resistances","rotgb_ignore_damage_resistances")
		DForm:Help(" - "..GetConVar("rotgb_ignore_damage_resistances"):GetHelpText().."\n")
		DForm:NumSlider("Speed Multiplier","rotgb_speed_mul",0,10,3)
		DForm:Help(" - "..GetConVar("rotgb_speed_mul"):GetHelpText().."\n")
		DForm:CheckBox("Use Legacy Models","rotgb_legacy_gballoons")
		DForm:Help(" - "..GetConVar("rotgb_legacy_gballoons"):GetHelpText().."\n")
		DForm:CheckBox("Pertain New Model Effects","rotgb_pertain_effects")
		DForm:Help(" - "..GetConVar("rotgb_pertain_effects"):GetHelpText().."\n")
		DForm:NumSlider("Blood Effect","rotgb_bloodtype",-1,16,0)
		DForm:Help(" - "..GetConVar("rotgb_bloodtype"):GetHelpText().."\n")
		DForm:TextEntry("Blood Decal","rotgb_blooddecal")
		DForm:Help(" - "..GetConVar("rotgb_blooddecal"):GetHelpText().."\n")
		DForm:Button("Blacklist Editor (Admin Only)","rotgb_blacklist")
		DForm:Button("Wave Editor","rotgb_waveeditor")
		
		DForm:Help("") --whitespace
		DForm:ControlHelp("AI Settings")
		DForm:CheckBox("Custom Pathfinding","rotgb_use_custom_pathfinding")
		DForm:Help(" - "..GetConVar("rotgb_use_custom_pathfinding"):GetHelpText().."\n")
		--[[DForm:CheckBox("Custom AI","rotgb_use_custom_ai")
		DForm:Help(" - "..GetConVar("rotgb_use_custom_ai"):GetHelpText().."\n")]]
		DForm:NumSlider("Targets","rotgb_target_choice",-1,511,0)
		DForm:Help(" - "..GetConVar("rotgb_target_choice"):GetHelpText().."\n")
		DForm:NumberWang("Target Sorting","rotgb_target_sort",-1,3)
		DForm:Help(" - "..GetConVar("rotgb_target_sort"):GetHelpText().."\n")
		DForm:NumSlider("Search Size","rotgb_search_size",-1,2048,0)
		DForm:Help(" - "..GetConVar("rotgb_search_size"):GetHelpText().."\n")
		DForm:NumSlider("Tolerance","rotgb_target_tolerance",0,1000,1)
		DForm:Help(" - "..GetConVar("rotgb_target_tolerance"):GetHelpText().."\n")
		DForm:NumSlider("Pop On Contact","rotgb_pop_on_contact",-2,511,0)
		DForm:Help(" - "..GetConVar("rotgb_pop_on_contact"):GetHelpText().."\n")
		DForm:NumSlider("MinLookAheadDistance","rotgb_setminlookaheaddistance",0,1000,1)
		DForm:Help(" - "..GetConVar("rotgb_setminlookaheaddistance"):GetHelpText().."\n")
		
		--[[DForm:Help("") --whitespace
		DForm:ControlHelp("PopSave™*")
		DForm:Button("Save PopSave™ Cache","rotgb_popsave_save")
		DForm:CheckBox("Store Pop Results","rotgb_popsave")
		DForm:Help(" - "..GetConVar("rotgb_popsave"):GetHelpText().."\n")
		DForm:NumSlider("Autosave Interval","rotgb_popsave_autosave_interval",5,300,2)
		DForm:Help(" - "..GetConVar("rotgb_popsave_autosave_interval"):GetHelpText().."\n")
		DForm:Button("Clear PopSave™ Cache","rotgb_popsave_clearcache")]]
		
		--[[DForm:Help("") --whitespace
		DForm:ControlHelp("Hit Optimization Settings")
		DForm:NumSlider("Max Pops/Hit","rotgb_max_pops_per_hit",0,10000,0)
		DForm:Help(" - "..GetConVar("rotgb_max_pops_per_hit"):GetHelpText().."\n")
		DForm:NumSlider("Max Time/Hit (ms)","rotgb_max_pop_ms",0,1000,1)
		DForm:Help(" - "..GetConVar("rotgb_max_pop_ms"):GetHelpText().."\n")
		DForm:NumSlider("Max Spawn/Hit","rotgb_max_spawn_per_hit",0,256,0)
		DForm:Help(" - "..GetConVar("rotgb_max_spawn_per_hit"):GetHelpText().."\n")
		DForm:NumSlider("Max Total/Hit","rotgb_max_to_exist",0,4096,0)
		DForm:Help(" - "..GetConVar("rotgb_max_to_exist"):GetHelpText().."\n")]]
		
		DForm:Help("") --whitespace
		DForm:ControlHelp("Optimization Settings")
		DForm:CheckBox("No gBalloon Trails","rotgb_notrails")
		DForm:Help(" - "..GetConVar("rotgb_notrails"):GetHelpText().."\n")
		DForm:NumSlider("Max gBalloons","rotgb_max_to_exist",0,1024,0)
		DForm:Help(" - "..GetConVar("rotgb_max_to_exist"):GetHelpText().."\n")
		DForm:NumSlider("Max Pop Effects/Second","rotgb_max_effects_per_second",0,100,2)
		DForm:Help(" - "..GetConVar("rotgb_max_effects_per_second"):GetHelpText().."\n")
		DForm:NumSlider("Resist Effect Delay","rotgb_resist_effect_delay",-1,10,3)
		DForm:Help(" - "..GetConVar("rotgb_resist_effect_delay"):GetHelpText().."\n")
		DForm:NumSlider("Critical Effect Delay","rotgb_crit_effect_delay",-1,10,3)
		DForm:Help(" - "..GetConVar("rotgb_crit_effect_delay"):GetHelpText().."\n")
		DForm:NumSlider("Path Computation Delay","rotgb_path_delay",0,100,2)
		DForm:Help(" - "..GetConVar("rotgb_path_delay"):GetHelpText().."\n")
		DForm:NumSlider("Max Towers","rotgb_tower_maxcount",-1,64,0)
		DForm:Help(" - "..GetConVar("rotgb_tower_maxcount"):GetHelpText().."\n")
		DForm:NumSlider("Initialization Rate","rotgb_init_rate",-1,100,2)
		DForm:Help(" - "..GetConVar("rotgb_init_rate"):GetHelpText().."\n")
		
		DForm:Help("") --whitespace
		DForm:ControlHelp("Miscellaneous")
		DForm:NumSlider("gBalloon Visual Scale","rotgb_visual_scale",0,10,3)
		DForm:Help(" - "..GetConVar("rotgb_visual_scale"):GetHelpText().."\n")
		DForm:NumSlider("func_nav_* Tolerance","rotgb_func_nav_expand",0,100,2)
		DForm:Help(" - "..GetConVar("rotgb_func_nav_expand"):GetHelpText().."\n")
		
		--[[DForm:Help("") --whitespace
		DForm:Help("* not a real trademark")]]
	end)
	spawnmenu.AddToolMenuOption("Options","RotgB","RotgB_Options_Client","Client Options","","",function(DForm) -- Add panel
		DForm:Help("") --whitespace
		DForm:ControlHelp("Cash Display")
		DForm:CheckBox("Enable HUD Display","rotgb_hud_enabled")
		DForm:Help(" - "..ConE:GetHelpText().."\n")
		DForm:NumSlider("X-Position","rotgb_hud_x",0,1,3)
		DForm:Help(" - "..ConX:GetHelpText().."\n")
		DForm:NumSlider("Y-Position","rotgb_hud_y",0,1,3)
		DForm:Help(" - "..ConY:GetHelpText().."\n")
		DForm:NumSlider("HUD Size","rotgb_hud_size",0,128,0)
		DForm:Help(" - "..ConS:GetHelpText().."\n")
		DForm:Help("") --whitespace
		DForm:ControlHelp("Tower Ranges")
		DForm:CheckBox("Show Tower Ranges","rotgb_range_enable_indicators")
		DForm:Help(" - "..GetConVar("rotgb_range_enable_indicators"):GetHelpText().."\n")
		DForm:NumSlider("Hold Time","rotgb_range_hold_time",0,10,3)
		DForm:Help(" - "..GetConVar("rotgb_range_hold_time"):GetHelpText().."\n")
		DForm:NumSlider("Fade Time","rotgb_range_fade_time",0,10,3)
		DForm:Help(" - "..GetConVar("rotgb_range_fade_time"):GetHelpText().."\n")
		DForm:NumSlider("Visibility","rotgb_range_alpha",0,255,0)
		DForm:Help(" - "..GetConVar("rotgb_range_alpha"):GetHelpText().."\n")
		DForm:Help("") --whitespace
		DForm:ControlHelp("Other")
		DForm:NumSlider("Circle Side Count","rotgb_circle_segments",3,200,0)
		DForm:Help(" - "..ConQ:GetHelpText().."\n")
		DForm:NumSlider("Text Hover Distance","rotgb_hoverover_distance",0,100,1)
		DForm:Help(" - "..ConH:GetHelpText().."\n")
		DForm:CheckBox("Enable Freeze Effect","rotgb_freeze_effect")
		DForm:Help(" - "..ConF:GetHelpText().."\n")
		DForm:CheckBox("Disable Halo Effects","rotgb_no_glow")
		DForm:Help(" - "..ConG:GetHelpText().."\n")
	end)
	--[[spawnmenu.AddToolMenuOption("Options","RotgB","RotgB_Bestiary","Bestiary","","",function(DForm) -- Add panel
		local CategoryList = vgui.Create("DCategoryList",DForm)
		for i,v in ipairs(order) do
			AddBalloon(CategoryList,v)
		end
		CategoryList:SetHeight(768)
		CategoryList:Dock(FILL)
		DForm:AddItem(CategoryList)
	end)]]
	spawnmenu.AddToolMenuOption("Options","RotgB","RotgB_NavEditorTool","#tool.nav_editor_rotgb.name",game.SinglePlayer() and "gmod_tool nav_editor_rotgb" or "","",function(form)
		if game.SinglePlayer() then
			form:Help("#tool.nav_editor_rotgb.desc")
			local label = form:Help("This tool is only available in single player.")
			label:SetTextColor(Color(255,0,0))
			form:ControlHelp("NOTE: You can also mark the area to be avoided using the Easy Navmesh Editor by adding the AVOID attribute.")
			form:Button("Equip the Easy Navmesh Editor (if available)","gmod_tool","rb655_easy_navedit")
			local Button = form:Button("Get The Easy Navmesh Editor On Workshop")
			Button.DoClick = function() gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=527885257") end
		else
			local label = form:Help("This tool is only available in single player.")
			label:SetTextColor(Color(255,0,0))
		end
	end)
	spawnmenu.AddToolMenuOption("Options","RotgB","RotgB_WaypointEditorTool","#tool.waypoint_editor_rotgb.name","gmod_tool waypoint_editor_rotgb","",function(form)
		form:Help("#tool.waypoint_editor_rotgb.desc")
		form:CheckBox("Always Show Paths","waypoint_editor_rotgb_indicator_always")
		local choicelist = form:ComboBox("Path Sprite","waypoint_editor_rotgb_indicator_effect")
		choicelist:SetSortItems(false)
		choicelist:AddChoice("Glow","sprites/glow04_noz")
		choicelist:AddChoice("Glow 2","sprites/light_ignorez")
		choicelist:AddChoice("PhysGun Glow","sprites/physg_glow1")
		choicelist:AddChoice("PhysGun Glow 2","sprites/physg_glow2")
		choicelist:AddChoice("Comic Balls","sprites/sent_ball")
		choicelist:AddChoice("Rings","effects/select_ring")
		choicelist:AddChoice("Crosses","effects/select_dot")
		choicelist:AddChoice("Circled Crosses","gui/close_32")
		choicelist:AddChoice("Circled Crosses 2","icon16/circlecross.png")
		choicelist:AddChoice("Cogs","gui/progress_cog.png")
		form:NumSlider("Sprite Scale","waypoint_editor_rotgb_indicator_scale",0,10)
		form:NumSlider("Sprite Speed","waypoint_editor_rotgb_indicator_speed",0.1,10)
		form:CheckBox("Target-to-Target Sprite Bounce","waypoint_editor_rotgb_indicator_bounce")
		choicelist = form:ComboBox("Path Colour","waypoint_editor_rotgb_indicator_color")
		choicelist:AddChoice("Rainbow",0)
		choicelist:AddChoice("Rainbow (Fade In Out)",1)
		choicelist:AddChoice("Rainbow (Fade Middle)",2)
		choicelist:AddChoice("Solid",3)
		choicelist:AddChoice("Solid (Fade In Out)",4)
		choicelist:AddChoice("Solid (Fade Middle)",5)
		choicelist:AddChoice("Rainbow, Solid for Blimps",6)
		choicelist:AddChoice("Rainbow, Solid for Blimps (Fade In Out)",7)
		choicelist:AddChoice("Rainbow, Solid for Blimps (Fade Middle)",8)
		choicelist:AddChoice("Solid, Rainbow for Blimps",9)
		choicelist:AddChoice("Solid, Rainbow for Blimps (Fade In Out)",10)
		choicelist:AddChoice("Solid, Rainbow for Blimps (Fade Middle)",11)
		local mixer = vgui.Create("DColorMixer")
		mixer:SetLabel("Solid Colour")
		mixer:SetConVarR("waypoint_editor_rotgb_indicator_r")
		mixer:SetConVarG("waypoint_editor_rotgb_indicator_g")
		mixer:SetConVarB("waypoint_editor_rotgb_indicator_b")
		mixer:SetConVarA("waypoint_editor_rotgb_indicator_a")
		form:AddItem(mixer)
		mixer = vgui.Create("DColorMixer")
		mixer:SetLabel("Solid Colour for Blimps")
		mixer:SetConVarR("waypoint_editor_rotgb_indicator_boss_r")
		mixer:SetConVarG("waypoint_editor_rotgb_indicator_boss_g")
		mixer:SetConVarB("waypoint_editor_rotgb_indicator_boss_b")
		mixer:SetConVarA("waypoint_editor_rotgb_indicator_boss_a")
		form:AddItem(mixer)
	end)
end)

end -- END CLIENT

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"GBOnly",{KeyName="gballoon_damage_only",Edit={title="Only gBalloon Damage",type="Boolean"}})
	self:NetworkVar("Bool",1,"IsBeacon",{KeyName="is_beacon",Edit={title="Is Waypoint",type="Boolean"}})
	self:NetworkVar("Entity",0,"NextTarget1")
	self:NetworkVar("Entity",1,"NextTarget2")
	self:NetworkVar("Entity",2,"NextTarget3")
	self:NetworkVar("Entity",3,"NextTarget4")
	self:NetworkVar("Entity",4,"NextTarget5")
	self:NetworkVar("Entity",5,"NextTarget6")
	self:NetworkVar("Entity",6,"NextTarget7")
	self:NetworkVar("Entity",7,"NextTarget8")
	self:NetworkVar("Entity",8,"NextTarget9")
	self:NetworkVar("Entity",9,"NextTarget10")
	self:NetworkVar("Entity",10,"NextTarget11")
	self:NetworkVar("Entity",11,"NextTarget12")
	self:NetworkVar("Entity",12,"NextTarget13")
	self:NetworkVar("Entity",13,"NextTarget14")
	self:NetworkVar("Entity",14,"NextTarget15")
	self:NetworkVar("Entity",15,"NextTarget16")
	self:NetworkVar("Entity",16,"NextBlimpTarget1")
	self:NetworkVar("Entity",17,"NextBlimpTarget2")
	self:NetworkVar("Entity",18,"NextBlimpTarget3")
	self:NetworkVar("Entity",19,"NextBlimpTarget4")
	self:NetworkVar("Entity",20,"NextBlimpTarget5")
	self:NetworkVar("Entity",21,"NextBlimpTarget6")
	self:NetworkVar("Entity",22,"NextBlimpTarget7")
	self:NetworkVar("Entity",23,"NextBlimpTarget8")
	self:NetworkVar("Entity",24,"NextBlimpTarget9")
	self:NetworkVar("Entity",25,"NextBlimpTarget10")
	self:NetworkVar("Entity",26,"NextBlimpTarget11")
	self:NetworkVar("Entity",27,"NextBlimpTarget12")
	self:NetworkVar("Entity",28,"NextBlimpTarget13")
	self:NetworkVar("Entity",29,"NextBlimpTarget14")
	self:NetworkVar("Entity",30,"NextBlimpTarget15")
	self:NetworkVar("Entity",31,"NextBlimpTarget16")
end

function ENT:KeyValue(key,value)
	local lkey = key:lower()
	if lkey=="gballoon_damage_only" then
		self:SetGBOnly(tobool(value))
	elseif lkey=="model" then
		self.Model = value
	elseif lkey=="skin" then
		self.Skin = value
	elseif lkey=="is_beacon" then
		self:SetIsBeacon(tobool(value))
	elseif string.sub(lkey,1,11) == "next_target" then
		local num = (tonumber("0x"..string.sub(lkey,-1)) or 0) + 1
		self.TempNextTargets = self.TempNextTargets or {}
		self.TempNextTargets[num] = value
	elseif string.sub(lkey,1,17) == "next_blimp_target" then
		local num = (tonumber("0x"..string.sub(lkey,-1)) or 0) + 1
		self.TempNextBlimpTargets = self.TempNextBlimpTargets or {}
		self.TempNextBlimpTargets[num] = value
	elseif lkey=="is_visible" then
		self.TempIsHidden = not tobool(value)
	elseif lkey=="onbreak" then
		self:StoreOutput(key,value)
	elseif lkey=="onhealthchanged" then
		self:StoreOutput(key,value)
	elseif lkey=="onkilled" then
		self:StoreOutput(key,value)
	elseif lkey=="ontakedamage" then
		self:StoreOutput(key,value)
	elseif lkey=="onwaypointed" then
		self:StoreOutput(key,value)
	end
end

function ENT:AcceptInput(input,activator,caller,data)
	input = input:lower()
	if input=="sethealth" then
		local oldhealth = self:Health()
		self:SetHealth(data)
		if self:Health()~=oldhealth then
			self:TriggerOutput("OnHealthChanged",activator,self:Health()/self:GetMaxHealth())
		end
		if self:Health()<=0 then
			self:TriggerOutput("OnBreak",activator)
			self:Input("Kill",activator,self,data)
		end
	elseif input=="addhealth" then
		local oldhealth = self:Health()
		self:SetHealth(self:Health()+data)
		if self:Health()~=oldhealth then
			self:TriggerOutput("OnHealthChanged",activator,self:Health()/self:GetMaxHealth())
		end
	elseif input=="removehealth" then
		local oldhealth = self:Health()
		self:SetHealth(self:Health()-data)
		if self:Health()~=oldhealth then
			self:TriggerOutput("OnHealthChanged",activator,self:Health()/self:GetMaxHealth())
		end
		if self:Health()<=0 then
			self:TriggerOutput("OnBreak",activator)
			self:Input("Kill",activator,self,data)
		end
	elseif input=="break" then
		local oldhealth = self:Health()
		self:SetHealth(0)
		if self:Health()~=oldhealth then
			self:TriggerOutput("OnHealthChanged",activator,self:Health()/self:GetMaxHealth())
		end
		self:TriggerOutput("OnBreak",activator)
		self:Input("Kill",activator,self,data)
	elseif input=="setiswaypoint" then
		self:SetIsBeacon(tobool(data))
	elseif string.sub(input,1,15) == "setnextwaypoint" then
		local num = (tonumber("0x"..string.sub(input,-1)) or 0) + 1
		self["SetNextTarget"..num](self,data~="" and ents.FindByName(data)[1] or NULL)
	elseif string.sub(input,1,20) == "setnextblimpwaypoint" then
		local num = (tonumber("0x"..string.sub(input,-1)) or 0) + 1
		self["SetNextBlimpTarget"..num](self,data~="" and ents.FindByName(data)[1] or NULL)
	end
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
		self:SetModel(self.Model or "models/props_c17/streetsign004e.mdl")
		if self.Skin then
			self:SetSkin(self.Skin)
		end
		self:PhysicsInit(SOLID_VPHYSICS)
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:Wake()
		end
		if self.CurHealth then
			self:SetHealth(self.CurHealth)
			self:SetMaxHealth(self.CurMaxHealth)
		end
		--[[if self.TmepNextTarget then
			self:SetNextTarget(ents.FindByName(self.TmepNextTarget)[1] or NULL)
			self.TmepNextTarget = nil
		end
		if IsValid(self:GetNextTarget()) then
			self:SetNextTarget1(self:GetNextTarget())
			self:SetNextTarget(NULL)
		end]]
		if self.TempNextTargets then
			for k,v in pairs(self.TempNextTargets) do
				self["SetNextTarget"..k](self,v~="" and ents.FindByName(v)[1] or NULL)
			end
		end
		if self.TempNextBlimpTargets then
			for k,v in pairs(self.TempNextBlimpTargets) do
				self["SetNextBlimpTarget"..k](self,v~="" and ents.FindByName(v)[1] or NULL)
			end
		end
		if self.TempIsHidden then
			self:SetNotSolid(true)
			self:SetNoDraw(true)
			self:SetMoveType(MOVETYPE_NOCLIP)
		end
	end
end

function ENT:PreEntityCopy()
	self.CurHealth = self:Health()
	self.CurMaxHealth = self:GetMaxHealth()
end

function ENT:PostEntityPaste(ply,ent,tab)
	ent:Spawn()
	ent:Activate()
end

function ENT:OnTakeDamage(dmginfo)
	self:TriggerOutput("OnTakeDamage",dmginfo:GetAttacker(),dmginfo:GetDamage())
	if not self:GetGBOnly() or (IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():GetClass()=="gballoon_base") then
		self:EmitSound("physics/metal/metal_box_break"..math.random(1,2)..".wav",60)
		self:SetHealth(self:Health()-dmginfo:GetDamage())
		if dmginfo:GetDamage()~=0 then
			self:TriggerOutput("OnHealthChanged",dmginfo:GetAttacker(),self:Health()/self:GetMaxHealth())
		end
		if self:Health()<=0 then
			self:TriggerOutput("OnBreak",dmginfo:GetAttacker())
			self:Input("Kill",dmginfo:GetAttacker(),dmginfo:GetInflictor())
		end
	end
end

function ENT:OnRemove()
	if SERVER then
		self:TriggerOutput("OnKilled")
	end
end

function ENT:DrawTranslucent()
	--self:Draw()
	if not self:GetIsBeacon() then
		--self:DrawModel()
		local text1 = "Health: "..self:Health()
		surface.SetFont("DermaLarge")
		local t1x,t1y = surface.GetTextSize(text1)
		local reqang = (self:GetPos()-LocalPlayer():GetShootPos()):Angle()
		reqang.p = 0
		reqang.y = reqang.y-90
		reqang.r = 90
		cam.Start3D2D(self:GetPos()+Vector(0,0,ConH:GetFloat()+t1y*0.1+self:OBBMaxs().z),reqang,0.2)
			surface.SetDrawColor(0,0,0,127)
			surface.DrawRect(t1x/-2,t1y/-2,t1x,t1y)
			surface.SetTextColor(HSVToColor(math.Clamp(self:Health()/self:GetMaxHealth()*120,0,120),1,1))
			surface.SetTextPos(t1x/-2,t1y/-2)
			surface.DrawText(text1)
		cam.End3D2D()
	end
end

list.Set("NPC","gballoon_target_100",{
	Name = "100HP gBalloon Target",
	Class = "gballoon_target",
	Category = "RotgB: Miscellaneous",
	KeyValues = {
		health = "100",
		max_health = "100"
	}
})
list.Set("NPC","gballoon_target_150",{
	Name = "150HP gBalloon Target",
	Class = "gballoon_target",
	Category = "RotgB: Miscellaneous",
	KeyValues = {
		health = "150",
		max_health = "150"
	}
})
list.Set("NPC","gballoon_target_200",{
	Name = "200HP gBalloon Target",
	Class = "gballoon_target",
	Category = "RotgB: Miscellaneous",
	KeyValues = {
		health = "200",
		max_health = "200"
	}
})
list.Set("NPC","gballoon_target_050",{
	Name = "50HP gBalloon Target",
	Class = "gballoon_target",
	Category = "RotgB: Miscellaneous",
	KeyValues = {
		health = "50",
		max_health = "50"
	}
})
list.Set("NPC","gballoon_target_op",{
	Name = "999999999HP gBalloon Target",
	Class = "gballoon_target",
	Category = "RotgB: Miscellaneous",
	KeyValues = {
		health = "999999999",
		max_health = "999999999"
	}
})
list.Set("SpawnableEntities","gballoon_target_100",{
	PrintName = "100HP gBalloon Target",
	ClassName = "gballoon_target",
	Category = "RotgB: Miscellaneous",
	KeyValues = {
		health = "100",
		max_health = "100"
	}
})
list.Set("SpawnableEntities","gballoon_target_150",{
	PrintName = "150HP gBalloon Target",
	ClassName = "gballoon_target",
	Category = "RotgB: Miscellaneous",
	KeyValues = {
		health = "150",
		max_health = "150"
	}
})
list.Set("SpawnableEntities","gballoon_target_200",{
	PrintName = "200HP gBalloon Target",
	ClassName = "gballoon_target",
	Category = "RotgB: Miscellaneous",
	KeyValues = {
		health = "200",
		max_health = "200"
	}
})
list.Set("SpawnableEntities","gballoon_target_050",{
	PrintName = "50HP gBalloon Target",
	ClassName = "gballoon_target",
	Category = "RotgB: Miscellaneous",
	KeyValues = {
		health = "50",
		max_health = "50"
	}
})
list.Set("SpawnableEntities","gballoon_target_op",{
	PrintName = "999999999HP gBalloon Target",
	ClassName = "gballoon_target",
	Category = "RotgB: Miscellaneous",
	KeyValues = {
		health = "999999999",
		max_health = "999999999"
	}
})