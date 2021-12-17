AddCSLuaFile()

local gballoon_pob = baseclass.Get("gballoon_path_object_base") -- internally sets ENT.Base and ENT.Type too
ENT.PrintName = "gBalloon Spawner"
ENT.Category = "RotgB: Miscellaneous"
ENT.ScriptedEntityType = "entity"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Spawns gBalloons in a nostalgic way."
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Editable = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.DisableDuplicator = false
ENT.CustomWaveName = ""
local SPAWN_OFFSET = Vector(0,0,10)

ROTGB_WAVES_RAMP = {
	-- format: { balloon_type, amount=1, timespan=0, delay=0 }
	{ -- 1
		{"gballoon_red",10,5},
		{"gballoon_red",8,2,5},
		duration=7,
		rbe=18
	},
	{
		{"gballoon_red",10,5},
		{"gballoon_red",12,3,5},
		{"gballoon_red",8,1,8},
		{"gballoon_blue",8,1,9},
		duration=10,
		rbe=46--30+8*2
	},
	{ -- 3
		{"gballoon_red",6,3},
		{"gballoon_red",8,2,3},
		{"gballoon_blue",6,3,5},
		{"gballoon_blue",8,2,8},
		{"gballoon_blue",8,1,10},
		{"gballoon_green",4,0.5,11},
		{"gballoon_regen_green",4,0.5,11.5},
		duration=12,
		rbe=82--14+22*2+8*3
	},
	{
		{"gballoon_red",12,3},
		{"gballoon_blue",2,1,3},
		{"gballoon_blue",12,3,4},
		{"gballoon_blue",8,1,7},
		{"gballoon_green",6,3,8},
		{"gballoon_green",8,1,11},
		{"gballoon_green",8,0.5,12},
		{"gballoon_regen_yellow",8,0.5,12.5},
		duration=13,
		rbe=146--12+22*2+22*3+8*4
	},
	{ -- 5
		{"gballoon_red",4,1},
		{"gballoon_red",8,1,1},
		{"gballoon_blue",4,1,2},
		{"gballoon_blue",8,1,3},
		{"gballoon_green",20,5,4},
		{"gballoon_regen_green",8,1,9},
		{"gballoon_yellow",4,1,10},
		{"gballoon_regen_yellow",8,1,11},
		{"gballoon_fast_pink",8,1,12},
		duration=13,
		rbe=208--12+12*2+28*3+12*4+8*5
	},
	{
		{"gballoon_blue",40,5},
		{"gballoon_green",40,5,5},
		{"gballoon_yellow",40,10,10},
		{"gballoon_regen_yellow",8,1,20},
		{"gballoon_pink",10,5,21},
		{"gballoon_regen_pink",4,1,26},
		{"gballoon_fast_pink",8,1,27},
		{"gballoon_white",8,2,28},
		duration=30,
		rbe=590--40*2+40*3+48*4+22*5+8*11
	},
	{ -- 7
		{"gballoon_shielded_blue",40,10},
		{"gballoon_fast_pink",8,1,10},
		{"gballoon_white",4,1,11},
		{"gballoon_black",4,1,12},
		duration=13,
		rbe=288--40*4+8*5+8*11
	},
	{
		{"gballoon_green",40,10},
		{"gballoon_yellow",16,1,10},
		{"gballoon_pink",40,10,11},
		{"gballoon_white",8,1,21},
		{"gballoon_black",8,1,22},
		{"gballoon_shielded_purple",8,1,23},
		duration=24,
		rbe=736--40*3+16*4+40*5+16*11+8*22
	},
	{ -- 9
		{"gballoon_red",12,3},
		{"gballoon_fast_hidden_regen_shielded_red",16,1,3},
		{"gballoon_blue",2,1,4},
		{"gballoon_green",2,1,5},
		{"gballoon_yellow",2,1,6},
		{"gballoon_pink",6,3,7},
		{"gballoon_pink",4,1,10},
		{"gballoon_pink",8,1,11},
		{"gballoon_fast_white",8,1,12},
		{"gballoon_fast_black",8,1,13},
		{"gballoon_fast_purple",8,1,14},
		{"gballoon_fast_orange",8,1,15},
		duration=16,
		rbe=504--12*1+16*2+2*2+2*3+2*4+18*5+32*11
	},
	{
		{"gballoon_pink",80,10},
		{"gballoon_white",2,1,10},
		{"gballoon_white",16,1,11},
		{"gballoon_black",2,1,12},
		{"gballoon_black",16,1,13},
		{"gballoon_purple",2,1,14},
		{"gballoon_purple",16,1,15},
		{"gballoon_orange",2,1,16},
		{"gballoon_orange",16,1,17},
		{"gballoon_gray",4,2,18},
		duration=20,
		rbe=1284--80*5+72*11+4*23
	},
	{ -- 11
		{"gballoon_fast_regen_shielded_pink",20,5},
		{"gballoon_white",8,0.5,5},
		{"gballoon_black",8,0.5,5.5},
		{"gballoon_purple",8,0.5,6},
		{"gballoon_orange",8,0.5,6.5},
		{"gballoon_gray",8,2,7},
		{"gballoon_regen_zebra",16,1,9},
		duration=10,
		rbe=1104--20*10+32*11+24*23
	},
	{
		{"gballoon_white",16,4},
		{"gballoon_black",16,4,4},
		{"gballoon_purple",16,4,8},
		{"gballoon_orange",16,4,12},
		{"gballoon_gray",16,2,16},
		{"gballoon_zebra",16,2,18},
		{"gballoon_aqua",16,2,20},
		{"gballoon_aqua",16,1,22},
		duration=23,
		rbe=2176--64*11+64*23
	},
	{ -- 13
		{"gballoon_fast_hidden_regen_shielded_white",16,2},
		{"gballoon_fast_hidden_regen_shielded_black",16,2,2},
		{"gballoon_fast_hidden_regen_shielded_purple",16,2,4},
		{"gballoon_fast_hidden_regen_shielded_orange",16,2,6},
		{"gballoon_shielded_gray",2,1,8},
		{"gballoon_shielded_zebra",4,1,9},
		{"gballoon_shielded_aqua",8,1,10},
		{"gballoon_shielded_error",16,1,11},
		duration=12,
		rbe=2788--64*22+30*46
	},
	{
		{"gballoon_fast_pink",160,10},
		{"gballoon_white",16,4,10},
		{"gballoon_black",16,4,14},
		{"gballoon_purple",16,4,18},
		{"gballoon_orange",16,4,22},
		{"gballoon_gray",16,1,24},
		{"gballoon_zebra",16,1,25},
		{"gballoon_aqua",16,1,26},
		{"gballoon_error",16,1,27},
		{"gballoon_rainbow",1,2,28},
		duration=30,
		rbe=4329--160*10+64*11+84*23+93
	},
	{ -- 15
		{"gballoon_regen_rainbow",16,1},
		{"gballoon_regen_rainbow",16,1,5},
		{"gballoon_regen_rainbow",16,1,10},
		duration=11,
		rbe=4464--48*93
	},
	{
		{"gballoon_regen_gray",32,4},
		{"gballoon_fast_zebra",32,4,4},
		{"gballoon_shielded_aqua",32,4,8},
		{"gballoon_hidden_error",32,4,12},
		{"gballoon_rainbow",24,12,16},
		{"gballoon_fast_rainbow",16,2,28},
		duration=30,
		rbe=7400--96*23+32*46+40*93
	},
	{ -- 17
		{"gballoon_shielded_rainbow",48,12},
		duration=12,
		rbe=8928--48*186
	},
	{
		{"gballoon_gray",32,4},
		{"gballoon_zebra",32,4,4},
		{"gballoon_aqua",32,4,8},
		{"gballoon_error",32,4,12},
		{"gballoon_rainbow",24,12,16},
		{"gballoon_fast_rainbow",8,1,28},
		{"gballoon_ceramic",8,1,29},
		duration=30,
		rbe=7480--96*23+32*46+32*93+8*103
	},
	{ -- 19
		{"gballoon_ceramic",16,1},
		{"gballoon_ceramic",16,1,5},
		{"gballoon_ceramic",32,2,10},
		{"gballoon_blimp_blue",1,0,15},
		duration=15,
		rbe=7204--64*103+612
	},
	{
		{"gballoon_fast_hidden_regen_shielded_gray",32,4},
		{"gballoon_fast_hidden_regen_shielded_zebra",32,4,4},
		{"gballoon_fast_hidden_regen_shielded_aqua",32,4,8},
		{"gballoon_fast_hidden_regen_shielded_error",32,4,12},
		{"gballoon_fast_regen_rainbow",16,8,16},
		{"gballoon_ceramic",20,5,24},
		{"gballoon_brick",16,1,29},
		duration=30,
		rbe=11564--128*46+16*93+20*103+16*133
	},
	{ -- 21
		{"gballoon_fast_regen_ceramic",30,15},
		{"gballoon_blimp_blue",4,1,15},
		{"gballoon_blimp_red",1,1,16},
		duration=17,
		rbe=8686--30*103+4*612+3148
	},
	{
		{"gballoon_fast_hidden_regen_shielded_orange",160,20},
		{"gballoon_shielded_ceramic",16,8,20},
		{"gballoon_brick",16,4,28},
		{"gballoon_brick",16,1,32},
		{"gballoon_marble",16,1,33},
		duration=34,
		rbe=14160--160*22+16*206+32*133+16*193
	},
	{ -- 23
		{"gballoon_fast_hidden_regen_shielded_ceramic",20,5},
		{"gballoon_shielded_blimp_blue",5,5,10},
		{"gballoon_blimp_red",2,4,15},
		{"gballoon_blimp_green",1,1,19},
		duration=20,
		rbe=26832--20*206+5*1224+16592
	},
	{
		{"gballoon_ceramic",40,10},
		{"gballoon_brick",40,5,10},
		{"gballoon_shielded_marble",40,5,15},
		{"gballoon_blimp_blue",2,4,20},
		{"gballoon_blimp_blue",8,1,24},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",8,1,25},
		duration=26,
		rbe=46552--40*103+40*133+40*386+10*612+8*1944
	},
	{ -- 25
		{"gballoon_shielded_blimp_red",2,8},
		{"gballoon_blimp_green",2,8,8},
		{"gballoon_blimp_purple",1,1,16},
		duration=17,
		rbe=100904--2*3148*2+2*16592+55128
	},
	{
		{"gballoon_fast_ceramic",40,5},
		{"gballoon_hidden_ceramic",40,5,5},
		{"gballoon_regen_ceramic",40,5,10},
		{"gballoon_shielded_ceramic",40,5,15},
		{"gballoon_fast_brick",40,5,20},
		{"gballoon_hidden_brick",40,5,25},
		{"gballoon_regen_brick",40,5,30},
		{"gballoon_shielded_brick",40,5,35},
		{"gballoon_fast_marble",40,5,40},
		{"gballoon_hidden_marble",40,5,45},
		{"gballoon_regen_marble",40,5,50},
		{"gballoon_shielded_marble",40,5,55},
		{"gballoon_blimp_green",5,5,60},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",32,2,65},
		{"gballoon_fast_blimp_magenta",16,1,67},
		duration=68,
		rbe=317176--200*103+200*133+200*193+5*16592+32*1944+16*5388
	},
	{ -- 27
		{"gballoon_blimp_purple",8,16},
		{"gballoon_blimp_rainbow",1,16,16},
		duration=32,
		rbe=541023--8*55128+99999
	},
}

ROTGB_WAVES = { -- format: { balloon_type, amount=1, timespan=0, delay=0 }
	{ ---- 1
		{"gballoon_red",10,10},
		duration=10,
		rbe=10
	},
	{
		{"gballoon_red",20,10},
		duration=10,
		rbe=20
	},
	{ -- 3
		{"gballoon_red",10,5},
		{"gballoon_blue",10,5,5},
		duration=10,
		rbe=30--10*3
	},
	{
		{"gballoon_blue",20,10},
		duration=10,
		rbe=40--20*2
	},
	{ ---- 5
		{"gballoon_blue",10,10},
		{"gballoon_green",10,2.5,7.5},
		duration=10,
		rbe=50
	},
	{
		{"gballoon_red",10,10},
		{"gballoon_blue",10,10},
		{"gballoon_green",10,10},
		duration=10,
		rbe=60
	},
	{ -- 7
		{"gballoon_yellow",10,10},
		{"gballoon_green",10,10},
		duration=10,
		rbe=70
	},
	{
		{"gballoon_red",8,2},
		{"gballoon_blue",8,2,2},
		{"gballoon_green",8,2,4},
		{"gballoon_yellow",8,4,6},
		duration=10,
		rbe=80
	},
	{ ---- 9
		{"gballoon_pink",8,4},
		{"gballoon_yellow",8,4,4},
		{"gballoon_red",18,2,8},
		duration=10,
		rbe=90
	},
	{
		{"gballoon_regen_pink",20,10},
		duration=10,
		rbe=100
	},
	{ -- 11
		{"gballoon_white",10,10},
		duration=10,
		rbe=110
	},
	{
		{"gballoon_green",40,10},
		duration=10,
		rbe=120
	},
	{ ---- 13
		{"gballoon_black",10,10},
		{"gballoon_blue",10,10},
		duration=10,
		rbe=130
	},
	{
		{"gballoon_red",20,10},
		{"gballoon_white",5,5},
		{"gballoon_black",5,5,5},
		duration=10,
		rbe=140
	},
	{ -- 15
		{"gballoon_regen_white",3,3},
		{"gballoon_regen_black",3,3,3},
		{"gballoon_purple",4,2,6},
		{"gballoon_fast_pink",8,2,8},
		duration=10,
		rbe=150
	},
	{
		{"gballoon_green",10,10},
		{"gballoon_purple",10,10},
		{"gballoon_regen_green",7,3.5,6.5},
		duration=10,
		rbe=161
	},
	{ ---- 17
		{"gballoon_fast_blue",20,5},
		{"gballoon_orange",10,5,5},
		{"gballoon_orange",2,nil,10},
		duration=10,
		rbe=172
	},
	{
		{"gballoon_orange",10,5},
		{"gballoon_fast_red",10,5,5},
		{"gballoon_yellow",10,5,5},
		{"gballoon_orange",2,nil,10},
		duration=10,
		rbe=182
	},
	{ -- 19
		{"gballoon_yellow",4,2},
		{"gballoon_white",3,3,2},
		{"gballoon_black",3,3,2},
		{"gballoon_zebra",5,5},
		duration=10,
		rbe=197
	},
	{
		{"gballoon_hidden_pink",5,5},
		{"gballoon_fast_regen_pink",4,2,5},
		{"gballoon_regen_orange",15,3,7},
		duration=10,
		rbe=210
	},
	{ ---- 21
		{"gballoon_gray",2,2},
		{"gballoon_zebra",3,3,2},
		{"gballoon_purple",10,5,5},
		duration=10,
		rbe=225
	},
	{
		{"gballoon_zebra",10,10},
		{"gballoon_fast_orange",nil,nil,10},
		duration=10,
		rbe=241
	},
	{ -- 23
		{"gballoon_aqua",5,5},
		{"gballoon_white",10,10},
		{"gballoon_white",3,nil,10},
		duration=10,
		rbe=258
	},
	{
		{"gballoon_aqua",10,10},
		{"gballoon_gray",2,2,8},
		duration=10,
		rbe=276
	},
	{ ---- 25
		{"gballoon_error",4,4},
		{"gballoon_shielded_zebra",2,1},
		{"gballoon_fast_regen_pink",20,5},
		{"gballoon_fast_hidden_orange",nil,nil,10},
		duration=10,
		rbe=295
	}, -- 25
	{
		{"gballoon_zebra",10,5},
		{"gballoon_yellow",20,4,5},
		{"gballoon_fast_hidden_regen_shielded_red",3,9,1},
		duration=10,
		rbe=316
	},
	{
		{"gballoon_aqua",5},
		{"gballoon_aqua",5,nil,5},
		{"gballoon_aqua",4,nil,10},
		{"gballoon_fast_regen_yellow",4,nil,10},
		duration=10,
		rbe=338
	},
	{
		{"gballoon_fast_regen_shielded_blue",90,10},
		{"gballoon_fast_hidden_regen_red",nil,nil,10},
		duration=10,
		rbe=361
	},
	{
		{"gballoon_zebra",4,8},
		{"gballoon_gray",4,8,0.5},
		{"gballoon_aqua",4,8,1},
		{"gballoon_error",4,8,1.5},
		{"gballoon_zebra",nil,nil,10},
		duration=10,
		rbe=391
	},
	{ ---- 30
		{"gballoon_rainbow"},
		{"gballoon_regen_rainbow",nil,3},
		{"gballoon_shielded_rainbow",nil,6},
		{"gballoon_fast_hidden_regen_shielded_red",20,1,9},
		{"gballoon_fast_hidden_regen_shielded_red",nil,nil,9},
		duration=10,
		rbe=414
	}, ---- 30
	{
		{"gballoon_regen_yellow",110,10},
		{"gballoon_regen_green",nil,nil,10},
		duration=10,
		rbe=443
	},
	{
		{"gballoon_aqua",20,10},
		{"gballoon_fast_regen_blue",7,nil,5},
		duration=10,
		rbe=474
	},
	{
		{"gballoon_zebra",20,10},
		{"gballoon_fast_shielded_white",nil,nil,10},
		{"gballoon_fast_shielded_black",nil,nil,10},
		{"gballoon_fast_hidden_regen_red",3,nil,10},
		duration=10,
		rbe=507
	},
	{
		{"gballoon_gray",20,10},
		{"gballoon_error",3,nil,10},
		{"gballoon_hidden_red",13,nil,5},
		duration=10,
		rbe=542
	},
	{ -- 35
		{"gballoon_ceramic",3,6},
		{"gballoon_shielded_ceramic",nil,8},
		{"gballoon_fast_regen_pink",13,nil,10},
		duration=10,
		rbe=580
	}, -- 35
	{
		{"gballoon_regen_gray",20,10},
		{"gballoon_regen_error",7,nil,10},
		duration=10,
		rbe=621
	},
	{
		{"gballoon_ceramic",6,6},
		{"gballoon_regen_pink",9,3,6},
		{"gballoon_shielded_red",nil,1,9},
		duration=10,
		rbe=665
	},
	{
		{"gballoon_zebra"},
		{"gballoon_zebra",10,10},
		{"gballoon_black",nil,0.2},
		{"gballoon_black",nil,0.4},
		{"gballoon_black",nil,0.6},
		{"gballoon_black",nil,0.8},
		{"gballoon_white",nil,1.2},
		{"gballoon_white",nil,1.4},
		{"gballoon_white",nil,1.6},
		{"gballoon_white",nil,1.8},
		{"gballoon_black",4,8,0.2},
		{"gballoon_black",4,8,0.4},
		{"gballoon_black",4,8,0.6},
		{"gballoon_black",4,8,0.8},
		{"gballoon_white",4,8,1.2},
		{"gballoon_white",4,8,1.4},
		{"gballoon_white",4,8,1.6},
		{"gballoon_white",4,8,1.8},
		{"gballoon_purple",nil,10},
		{"gballoon_regen_pink",nil,10},
		{"gballoon_fast_regen_shielded_red",nil,10},
		duration=10,
		rbe=711
	},
	{
		{"gballoon_rainbow",8,8},
		{"gballoon_fast_regen_shielded_yellow",2,1,8},
		{"gballoon_fast_hidden_regen_red",nil,1,9},
		duration=10,
		rbe=761
	},
	{ ---- 40
		{"gballoon_blimp_blue"},
		duration=10,
		rbe=612
	}, ---- 40
	{
		{"gballoon_aqua",30,10},
		{"gballoon_regen_aqua",8,4,6},
		duration=10,
		rbe=874 -- +3
	},
	{
		{"gballoon_red",21},
		{"gballoon_orange",21,nil,2},
		{"gballoon_yellow",20,nil,4},
		{"gballoon_green",20,nil,6},
		{"gballoon_aqua",20,nil,8},
		{"gballoon_blue",20,nil,10},
		duration=10,
		rbe=932
	},
	{
		{"gballoon_fast_shielded_pink",7,7},
		{"gballoon_ceramic",9,9,1},
		duration=10,
		rbe=997
	},
	{
		{"gballoon_aqua",2},
		{"gballoon_yellow",2},
		{"gballoon_error"},
		{"gballoon_aqua",20,10},
		{"gballoon_yellow",20,10},
		{"gballoon_error",20,10},
		duration=10,
		rbe=1077 -- +10 (+13)
	},
	{ -- 45
		{"gballoon_hidden_shielded_purple",50,10},
		{"gballoon_hidden_shielded_orange",2,10},
		duration=10,
		rbe=1144 -- +2 (+15)
	}, -- 45
	{
		{"gballoon_orange",9,9},
		{"gballoon_rainbow",9,9,0.25},
		{"gballoon_aqua",9,9,0.5},
		{"gballoon_fast_regen_orange",7,nil,10},
		duration=10,
		rbe=1220 -- -2 (+13)
	},
	{
		{"gballoon_ceramic",10,10},
		{"gballoon_ceramic",2,nil,10},
		{"gballoon_hidden_error",3,nil,10},
		duration=10,
		rbe=1305 -- -2 (+11)
	},
	{
		{"gballoon_fast_rainbow",10,10},
		{"gballoon_fast_rainbow",5,5,5},
		duration=10,
		rbe=1395 -- -4 (+7)
	},
	{
		{"gballoon_shielded_ceramic",5,5},
		{"gballoon_gray",20,5,5},
		duration=10,
		rbe=1490 -- -7 (0)
	},
	{ ---- 50
		{"gballoon_blimp_blue"},
		{"gballoon_blimp_blue",nil,5},
		{"gballoon_fast_shielded_brick",nil,10},
		{"gballoon_ceramic",nil,10},
		duration=10,
		rbe=1596 -- -3 (-3)
	}, ---- 50
	{
		{"gballoon_brick",10,10},
		{"gballoon_brick",3,nil,10},
		duration=10,
		rbe=1729 -- +15 (+12)
	},
	{
		{"gballoon_error",80,10},
		duration=10,
		rbe=1840 -- +6 (+18)
	},
	{
		{"gballoon_blimp_blue",3,9},
		{"gballoon_fast_shielded_green"},
		{"gballoon_fast_shielded_green",20,10},
		duration=10,
		rbe=1962
	},
	{
		{"gballoon_shielded_ceramic",10,10},
		{"gballoon_fast_gray",nil,10},
		duration=10,
		rbe=2083 -- -16 (+2)
	},
	{ -- 55
		{"gballoon_hidden_gray",18,4.5},
		{"gballoon_blimp_blue",2,4,6},
		{"gballoon_fast_blimp_blue",nil,10},
		duration=10,
		rbe=2248 -- +4 (+6)
	}, -- 55
	{
		{"gballoon_rainbow",20,10},
		{"gballoon_rainbow",5,5,5},
		{"gballoon_rainbow",nil,10},
		duration=10,
		rbe=2418 -- +15 (+21)
	},
	{
		{"gballoon_blimp_blue",4,8},
		{"gballoon_fast_ceramic",nil,10},
		duration=10,
		rbe=2551 -- -21 (0)
	},
	{
		{"gballoon_brick",20,10},
		{"gballoon_fast_hidden_regen_rainbow",nil,10},
		duration=10,
		rbe=2753 -- +1 (+1)
	},
	{
		{"gballoon_fast_rainbow"},
		{"gballoon_fast_rainbow",30,10},
		{"gballoon_fast_hidden_pink",10,10},
		{"gballoon_fast_hidden_regen_shielded_orange",nil,5},
		duration=10,
		rbe=2944
	},
	{ ---- 60
		{"gballoon_blimp_red"},
		duration=10,
		rbe=3148
	}, ---- 60
	{
		{"gballoon_rainbow",30,10},
		{"gballoon_rainbow",6,nil,10},
		{"gballoon_fast_regen_error",nil,nil,10},
		duration=10,
		rbe=3371
	},
	{
		{"gballoon_blimp_blue",5,5},
		{"gballoon_brick",4,4,5},
		{"gballoon_fast_hidden_regen_shielded_pink",nil,5},
		duration=10,
		rbe=3602 -- -5 (-4)
	},
	{
		{"gballoon_ceramic",5},
		{"gballoon_ceramic",5,nil,5},
		{"gballoon_ceramic",27,nil,10},
		{"gballoon_fast_hidden_regen_shielded_aqua",nil,10},
		duration=10,
		rbe=3857 -- -2 (-6)
	},
	{
		{"gballoon_zebra",45,5},
		{"gballoon_aqua",45,5},
		{"gballoon_gray",45,5,5},
		{"gballoon_error",45,5,5},
		duration=10,
		rbe=4140 -- +11 (+5)
	},
	{ -- 65
		{"gballoon_blimp_blue",3,6},
		{"gballoon_shielded_blimp_blue",2,4,6},
		{"gballoon_hidden_regen_brick",nil,nil,10},
		duration=10,
		rbe=4417 -- -2 (+3)
	}, -- 65
	{
		{"gballoon_fast_regen_shielded_orange",94,9.4},
		{"gballoon_brick",20,10},
		duration=10,
		rbe=4728
	},
	{
		{"gballoon_blimp_blue",8,8},
		{"gballoon_brick",nil,9},
		{"gballoon_fast_hidden_error",nil,10},
		duration=10,
		rbe=5052 -- -7 (-4)
	},
	{
		{"gballoon_regen_rainbow",50,10},
		{"gballoon_regen_rainbow",8,1.6,8.4},
		{"gballoon_fast_hidden_regen_gray",nil,10},
		duration=10,
		rbe=5417 -- +4 (0)
	},
	{
		{"gballoon_blimp_red",nil,10},
		{"gballoon_blimp_blue",4,6,4},
		{"gballoon_brick",nil,6},
		{"gballoon_gray",nil,5},
		{"gballoon_error",nil,4},
		{"gballoon_purple",nil,3},
		{"gballoon_pink",nil,2},
		{"gballoon_red",nil,1},
		duration=10,
		rbe=5792
	},
	{ ---- 70
		{"gballoon_marble",15,5},
		{"gballoon_shielded_marble",5,5,5},
		{"gballoon_fast_shielded_blimp_blue",nil,6},
		{"gballoon_fast_hidden_brick",nil,9},
		{"gballoon_fast_hidden_regen_shielded_pink",nil,10},
		duration=10,
		rbe=6192 -- -5 (-5)
	}, ---- 70
	{
		{"gballoon_blimp_red"},
		{"gballoon_blimp_red",nil,5},
		{"gballoon_ceramic",3,3,5},
		{"gballoon_fast_hidden_regen_shielded_orange",nil,9},
		{"gballoon_fast_hidden_regen_shielded_blue",nil,10},
		duration=10,
		rbe=6631
	},
	{
		{"gballoon_marble",27,9},
		{"gballoon_shielded_brick",7,1,9},
		duration=10,
		rbe=7073 -- -22 (-27)
	},
	{
		{"gballoon_blimp_blue",10,10},
		{"gballoon_fast_brick",10,10},
		{"gballoon_fast_brick"},
		duration=10,
		rbe=7583 -- -9 (-36)
	},
	{
		{"gballoon_blimp_red",2,10},
		{"gballoon_ceramic",10,10},
		{"gballoon_ceramic",8,nil,5},
		duration=10,
		rbe=8150 -- +27 (-9)
	},
	{ -- 75
		{"gballoon_shielded_blimp_red"},
		{"gballoon_fast_shielded_marble",5,10},
		{"gballoon_fast_hidden_regen_rainbow",5,10},
		duration=10,
		rbe=8691 -- -1 (-10)
	}, -- 75
	{
		{"gballoon_rainbow",10,10},
		{"gballoon_fast_rainbow",10,10},
		{"gballoon_rainbow",10,10},
		{"gballoon_regen_rainbow",10,10},
		{"gballoon_rainbow",10,10},
		{"gballoon_hidden_rainbow",10,10},
		{"gballoon_rainbow",10,10},
		{"gballoon_shielded_rainbow",10,10},
		{"gballoon_rainbow",10,10},
		duration=10,
		rbe=9300
	},
	{
		{"gballoon_blimp_blue",10,10},
		{"gballoon_blimp_blue",5,5},
		{"gballoon_fast_hidden_regen_shielded_white",35,5,5},
		duration=10,
		rbe=9951 -- -1 (-11)
	},
	{
		{"gballoon_blimp_red",3,6},
		{"gballoon_blimp_blue",2,4,6},
		duration=10,
		rbe=10668 -- +20 (+9)
	},
	{
		{"gballoon_rainbow",120,10},
		{"gballoon_rainbow",3},
		duration=10,
		rbe=11439 -- +46 (+55)
	},
	{ ---- 80
		{"gballoon_blimp_green"},
		duration=10,
		rbe=16592
	}, ---- 80
	{
		{"gballoon_blimp_blue",20,10},
		{"gballoon_fast_hidden_regen_shielded_rainbow",4,nil,10},
		duration=10,
		rbe=12984 -- -60 (-5)
	},
	{
		{"gballoon_blimp_red",4,8},
		{"gballoon_blimp_blue",2,4,1},
		{"gballoon_fast_hidden_regen_shielded_error",3,6,4},
		duration=10,
		rbe=13954 -- -3 (-8)
	},
	{
		{"gballoon_regen_ceramic",100,10},
		{"gballoon_regen_shielded_ceramic",45,9,1},
		duration=10,
		rbe=14935 -- +1 (-7)
	},
	{
		{"gballoon_marble",80,10},
		{"gballoon_hidden_shielded_brick",2,8,2},
		duration=10,
		rbe=15972 -- -8 (-15)
	},
	{ -- 85
		{"gballoon_fast_blimp_blue",20,10},
		{"gballoon_fast_shielded_blimp_blue",4,8,2},
		duration=10,
		rbe=17136 -- +138 (+123)
	}, -- 85
	{
		{"gballoon_blimp_red",5,10},
		{"gballoon_shielded_blimp_blue",2,10},
		duration=10,
		rbe=18188 -- -107 (+16)
	},
	{
		{"gballoon_blimp_blue",10},
		{"gballoon_blimp_blue",10,nil,5},
		{"gballoon_shielded_blimp_blue",6,nil,10},
		duration=10,
		rbe=19584 -- +8 (+24)
	},
	{
		{"gballoon_marble",100,10},
		{"gballoon_regen_shielded_brick",6,nil,10},
		duration=10,
		rbe=20896 -- -50 (-26)
	},
	{
		{"gballoon_fast_regen_shielded_rainbow",200,10},
		{"gballoon_fast_regen_shielded_rainbow",40,10},
		{"gballoon_rainbow",nil,10},
		duration=10,
		rbe=22413
	},
	{ ---- 90
		{"gballoon_fast_hidden_regen_shielded_gray",100,5},
		{"gballoon_fast_hidden_regen_blimp_gray",20,5,5},
		duration=10,
		rbe=24040 -- +59 (+33)
	}, ---- 90
	{
		{"gballoon_blimp_blue",40,10},
		{"gballoon_fast_shielded_blue",nil,10},
		duration=10,
		rbe=25704 -- +44 (+77)
	},
	{
		{"gballoon_blimp_green"},
		{"gballoon_blimp_red",3,9},
		{"gballoon_fast_shielded_blue",nil,10},
		duration=10,
		rbe=27260 -- -196 (-119)
	},
	{
		{"gballoon_hidden_regen_blimp_gray",10,5,5},
		{"gballoon_blimp_green",nil,7.5},
		{"gballoon_blimp_red",nil,10},
		duration=10,
		rbe=29378
	},
	{
		{"gballoon_shielded_marble",80,10},
		{"gballoon_hidden_regen_brick",5,nil,10},
		duration=10,
		rbe=31545 -- +110 (-9)
	},
	{ -- 95
		{"gballoon_fast_shielded_green"},
		{"gballoon_fast_hidden_regen_shielded_marble",nil,10},
		duration=10,
		rbe=33570 -- -65 (-74)
	}, -- 95
	{
		{"gballoon_hidden_regen_blimp_gray",30,10},
		{"gballoon_fast_shielded_blimp_red",nil,5},
		{"gballoon_fast_blimp_blue",nil,10},
		duration=10,
		rbe=36068 -- +78 (+4)
	},
	{
		{"gballoon_blimp_red",10,10},
		{"gballoon_blimp_blue",10,10},
		{"gballoon_fast_hidden_regen_rainbow",10,10},
		duration=10,
		rbe=38530 -- +21 (+25)
	},
	{
		{"gballoon_blimp_green"},
		{"gballoon_blimp_green",nil,5},
		{"gballoon_fast_blimp_blue",10,10},
		{"gballoon_fast_blimp_blue",3,9},
		duration=10,
		rbe=41140 -- -65 (-40)
	},
	{
		{"gballoon_fast_hidden_regen_rainbow",400,10},
		{"gballoon_fast_hidden_regen_rainbow",74,nil,10},
		duration=10,
		rbe=44082 -- -7 (-47)
	},
	{ ---- 100
		{"gballoon_blimp_purple"},
		duration=10,
		rbe=55128
	}, ---- 100
	{
		{"gballoon_shielded_blimp_blue",40,10},
		{"gballoon_fast_hidden_regen_shielded_marble",4,nil,10},
		duration=10,
		rbe=50504 -- +27 (-20)
	},
	{
		{"gballoon_blimp_green",3,9},
		{"gballoon_fast_blimp_red",nil,10},
		{"gballoon_fast_blimp_blue",nil,10},
		{"gballoon_fast_hidden_regen_shielded_marble",nil,10},
		{"gballoon_fast_hidden_regen_error",3,9},
		{"gballoon_fast_hidden_regen_orange",nil,10},
		{"gballoon_fast_hidden_regen_pink",nil,10},
		{"gballoon_fast_hidden_regen_yellow",nil,10},
		duration=10,
		rbe=54011
	},
	{
		{"gballoon_shielded_blimp_red",9,9},
		{"gballoon_fast_shielded_blimp_blue",1,1,9},
		duration=10,
		rbe=57888 -- +97 (+77)
	},
	{
		{"gballoon_hidden_regen_blimp_gray",60,10},
		{"gballoon_fast_hidden_regen_shielded_marble",9,9,1},
		duration=10,
		rbe=61794 -- -43 (+34)
	},
	{ -- 105
		{"gballoon_fast_shielded_blimp_green"},
		{"gballoon_fast_shielded_blimp_green",nil,10},
		duration=10,
		rbe=66368 -- +203 (+237)
	}, -- 105
	{
		{"gballoon_fast_blimp_blue",100,10},
		{"gballoon_fast_blimp_blue",16,nil,10},
		duration=10,
		rbe=70992 -- +195 (+432)
	},
	{
		{"gballoon_hidden_regen_shielded_blimp_gray",30,10},
		{"gballoon_blimp_green",nil,10},
		{"gballoon_fast_blimp_blue",nil,10},
		duration=10,
		rbe=75524 -- -229 (+203)
	},
	{
		{"gballoon_blimp_green",4,4},
		{"gballoon_fast_blimp_blue",24,6,4},
		duration=10,
		rbe=81056
	},
	{
		{"gballoon_hidden_regen_blimp_gray",80,10},
		{"gballoon_hidden_regen_blimp_gray",9,nil,10},
		duration=10,
		rbe=86508 -- -221 (-18)
	},
	{ ---- 110
		{"gballoon_blimp_purple"},
		{"gballoon_fast_blimp_magenta",7,7,3},
		duration=10,
		rbe=92844 -- +44 (+26)
	}, ---- 110
	{
		{"gballoon_fast_shielded_blimp_blue",4,4},
		{"gballoon_fast_shielded_blimp_red",15,7.5,2.5},
		duration=10,
		rbe=99336 -- +40 (+66)
	},
	{
		{"gballoon_blimp_green",6,6},
		{"gballoon_fast_blimp_blue",11,5.5,4.5},
		duration=10,
		rbe=106284 -- +37 (+103)
	},
	{
		{"gballoon_blimp_purple"},
		{"gballoon_fast_blimp_red",nil,5},
		{"gballoon_blimp_purple",nil,10},
		duration=10,
		rbe=113404 -- -281 (-178)
	},
	{
		{"gballoon_fast_blimp_magenta",20,10},
		{"gballoon_fast_blimp_blue",23,nil,10},
		duration=10,
		rbe=121836 -- +194 (+16)
	},
	{ -- 115
		{"gballoon_fast_shielded_blimp_magenta",12,6},
		{"gballoon_fast_hidden_regen_rainbow",9,3,7},
		duration=10,
		rbe=130149 -- -8 (+8)
	}, -- 115
	{
		{"gballoon_blimp_purple",2,10},
		{"gballoon_fast_blimp_blue",47},
		duration=10,
		rbe=139020 -- -248 (-240)
	},
	{
		{"gballoon_blimp_green",5,5},
		{"gballoon_shielded_blimp_green",2,4,6},
		duration=10,
		rbe=149328 -- +311 (+71)
	},
	{
		{"gballoon_fast_hidden_regen_shielded_blimp_gray"},
		{"gballoon_fast_shielded_blimp_red",5,10},
		{"gballoon_fast_shielded_blimp_red",5,10},
		{"gballoon_fast_shielded_blimp_red",5,10},
		{"gballoon_fast_shielded_blimp_red",5,10},
		{"gballoon_fast_shielded_blimp_red",5,10},
		duration=10,
		rbe=159344 -- -104 (-33)
	},
	{
		{"gballoon_fast_hidden_regen_rainbow",1830,10},
		{"gballoon_fast_hidden_regen_rainbow",5,10},
		duration=10,
		rbe=170655 -- +45 (+12)
	},
	{ ---- 120
		{"gballoon_blimp_rainbow"},
		duration=10,
		rbe=232695
	}, ---- 120
}

ROTGB_CUSTOM_WAVES = {["?RAMP"]=ROTGB_WAVES_RAMP}

function ENT:GetWaveDuration(wave)
	return (self:GetWaveTable()[wave] or {}).duration or 0
end

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Wave", {KeyName="start_wave", Edit={title="Wave To Spawn", type="Int", min=1, max=1000, order=1}})
	self:NetworkVar("Int", 1, "SpawnDivider", {KeyName="spawn_divider", Edit={title="Spawn Divider", type="Int", min=1, max=100, order=4}})
	self:NetworkVar("Int", 2, "DividerDelay", {KeyName="divider_delay", Edit={title="Divider Delay", type="Int", min=0, max=100, order=5}})
	self:NetworkVar("Int", 3, "LastWave", {KeyName="end_wave", Edit={title="Last Wave", type="Int", min=1, max=1000, order=2}})
	self:NetworkVar("Bool", 0, "AutoStartInternal", {KeyName="auto_start", Edit={title="Auto-Start", type="Boolean", order=6}})
	self:NetworkVar("Bool", 1, "ForceNextWave", {KeyName="force_next", Edit={title="Force Auto-Start", type="Boolean", order=8}})
	self:NetworkVar("Bool", 2, "StartAll", {KeyName="start_all", Edit={title="Start All Others", type="Boolean", order=9}})
	self:NetworkVar("Bool", 3, "UnSpectatable")
	self:NetworkVar("Bool", 4, "HideWave", {KeyName="hide_wave", Edit={title="Hide Wave", type="Boolean", order=11}})
	self:NetworkVar("Float", 0, "AutoStartDelay", {KeyName="auto_start_delay", Edit={title="Auto-Start Delay", type="Float", min=0, max=60, order=7}})
	self:NetworkVar("Float", 1, "SpeedMul", {KeyName="spawn_rate_mul", Edit={title="Spawn Rate", type="Float", min=0.1, max=10, order=3}})
	self:NetworkVar("Float", 2, "NextWaveTime")
	self:NetworkVar("String", 0, "WaveFile", {KeyName="wave_preset", Edit={title="Wave Preset", type="Generic", order=10}})
	self:NetworkVar("Entity", 0, "NextTarget1")
	self:NetworkVar("Entity", 1, "NextTarget2")
	self:NetworkVar("Entity", 2, "NextTarget3")
	self:NetworkVar("Entity", 3, "NextTarget4")
	self:NetworkVar("Entity", 4, "NextTarget5")
	self:NetworkVar("Entity", 5, "NextTarget6")
	self:NetworkVar("Entity", 6, "NextTarget7")
	self:NetworkVar("Entity", 7, "NextTarget8")
	self:NetworkVar("Entity", 8, "NextTarget9")
	self:NetworkVar("Entity", 9, "NextTarget10")
	self:NetworkVar("Entity", 10, "NextTarget11")
	self:NetworkVar("Entity", 11, "NextTarget12")
	self:NetworkVar("Entity", 12, "NextTarget13")
	self:NetworkVar("Entity", 13, "NextTarget14")
	self:NetworkVar("Entity", 14, "NextTarget15")
	self:NetworkVar("Entity", 15, "NextTarget16")
	self:NetworkVar("Entity", 16, "NextBlimpTarget1")
	self:NetworkVar("Entity", 17, "NextBlimpTarget2")
	self:NetworkVar("Entity", 18, "NextBlimpTarget3")
	self:NetworkVar("Entity", 19, "NextBlimpTarget4")
	self:NetworkVar("Entity", 20, "NextBlimpTarget5")
	self:NetworkVar("Entity", 21, "NextBlimpTarget6")
	self:NetworkVar("Entity", 22, "NextBlimpTarget7")
	self:NetworkVar("Entity", 23, "NextBlimpTarget8")
	self:NetworkVar("Entity", 24, "NextBlimpTarget9")
	self:NetworkVar("Entity", 25, "NextBlimpTarget10")
	self:NetworkVar("Entity", 26, "NextBlimpTarget11")
	self:NetworkVar("Entity", 27, "NextBlimpTarget12")
	self:NetworkVar("Entity", 28, "NextBlimpTarget13")
	self:NetworkVar("Entity", 29, "NextBlimpTarget14")
	self:NetworkVar("Entity", 30, "NextBlimpTarget15")
	self:NetworkVar("Entity", 31, "NextBlimpTarget16")
end

function ENT:KeyValue(key,value)
	local lkey = key:lower()
	if lkey=="start_wave" then
		value = tonumber(value) or 0
		if value ~= 0 then
			self:SetWave(value)
		else
			self:SetWave(ROTGB_GetConVarValue("rotgb_default_first_wave"))
		end
	elseif lkey=="end_wave" then
		value = tonumber(value) or 0
		if value ~= 0 then
			self:SetLastWave(value)
		else
			self:SetLastWave(ROTGB_GetConVarValue("rotgb_default_last_wave"))
		end
	elseif lkey=="wave_preset" then
		self:SetWaveFile(value)
	elseif lkey=="hide_wave" then
		self:SetHideWave(tobool(value))
	elseif lkey=="start_all" then
		self:SetStartAll(tobool(value))
	elseif lkey=="spawn_speed_mul" then -- TODO: DEPRECATED
		self:SetSpeedMul(tonumber(value) or 1)
	elseif lkey=="spawn_rate_mul" then
		self:SetSpeedMul(tonumber(value) or 1)
	elseif lkey=="spawn_divider" then
		self:SetSpawnDivider(tonumber(value) or 1)
	elseif lkey=="divider_delay" then
		self:SetDividerDelay(tonumber(value) or 1)
	elseif lkey=="no_auto_start" then
		self.NoAutoStart = tobool(value)
	elseif lkey=="auto_start_delay" then
		self:SetAutoStartDelay(tonumber(value) or 0)
	elseif lkey=="force_next" then
		self:SetForceNextWave(tobool(value))
	elseif lkey=="finished_shortly_threshold" then
		self.OutputShortlyThreshold = value
	elseif lkey=="dont_trigger_wave_relays" then
		self.DontTriggerWaveRelays = value
	elseif lkey=="no_messages" then
		self.NoMessages = tobool(value)
	elseif lkey=="onwavestart" then
		self:StoreOutput(key,value)
	elseif lkey=="onwavefinished" then
		self:StoreOutput(key,value)
	elseif lkey=="onwavefinishedshortly" then
		self:StoreOutput(key,value)
	elseif lkey=="onautostartenabled" then
		self:StoreOutput(key,value)
	elseif lkey=="onautostartdisabled" then
		self:StoreOutput(key,value)
	end
	return gballoon_pob.KeyValue(self,lkey,value)
end

function ENT:AcceptInput(input,activator,caller,data)
	input = input:lower()
	if input=="setnextwave" then
		local value = tonumber(data) or 0
		if value > 0 then
			self:SetWave(value)
		else
			self:SetWave(ROTGB_GetConVarValue("rotgb_default_first_wave"))
		end
	elseif input=="setlastwave" then
		local value = tonumber(data) or 0
		if value > 0 then
			self:SetLastWave(value)
		else
			self:SetLastWave(ROTGB_GetConVarValue("rotgb_default_last_wave"))
		end
	elseif input=="setwavepreset" then
		self:SetWaveFile(data)
	elseif input=="setstartall" then -- TO DO: DEPRECATED
		self:SetStartAll(tobool(data))
	elseif input=="setspawnratemultiplier" then
		self:SetSpeedMul(tonumber(data) or 1)
	elseif input=="setspawndivider" then
		self:SetSpawnDivider(tonumber(data) or 1)
	elseif input=="setdividerdelay" then
		self:SetDividerDelay(tonumber(data) or 1)
	elseif input=="setautostart" then -- TO DO: DEPRECATED
		self:SetAutoStart(tobool(data), activator)
	elseif input=="setautostartdelay" then
		self:SetAutoStartDelay(tonumber(data) or 0)
	elseif input=="setforcenext" then -- TO DO: DEPRECATED
		self:SetForceNextWave(tobool(data))
	elseif input=="setshortnessthreshold" then
		self.OutputShortlyThreshold = tonumber(data) or 0
	elseif input=="enablenomessages" then
		self.NoMessages = true
	elseif input=="disablenomessages" then
		self.NoMessages = false
	elseif input=="togglenomessages" then
		self.NoMessages = not self.NoMessages
	end
	self:CheckBoolEDTInput(input, "hidewave", "HideWave")
	self:CheckBoolEDTInput(input, "startall", "StartAll")
	self:CheckBoolEDTInput(input, "autostart", "AutoStart")
	self:CheckBoolEDTInput(input, "forceautostart", "ForceNextWave")
	return gballoon_pob.AcceptInput(self,input,activator,caller,data)
end

function ENT:SpawnFunction(ply,trace,classname)
	if not trace.Hit then return end
	
	local ent = ents.Create(classname)
	ent:SetPos(trace.HitPos+trace.HitNormal*5)
	ent:Spawn()
	ent:Activate()
	
	return ent
end

local notifshown

function ENT:Initialize()
	if SERVER then
		if not (navmesh.IsLoaded() or notifshown) and game.SinglePlayer() then
			PrintMessage(HUD_PRINTTALK, "No NavMesh found! Please generate one first!")
			--[[net.Start("NavmeshMissing")
			net.WriteBool(false)
			net.Broadcast()]]
			notifshown = true
		end
		self.OutputShortlyThreshold = tonumber(self.OutputShortlyThreshold) or 7.5
		if self:GetWave()<=0 then
			self:SetWave(ROTGB_GetConVarValue("rotgb_default_first_wave"))
		end
		if self:GetLastWave()<=0 then
			self:SetLastWave(ROTGB_GetConVarValue("rotgb_default_last_wave"))
		end
		self:SetSpeedMul(self:GetSpeedMul()>0 and self:GetSpeedMul() or 1)
		self:SetSpawnDivider(self:GetSpawnDivider()>0 and self:GetSpawnDivider() or 1)
		if self:GetWaveFile() == "" then
			self:SetWaveFile(ROTGB_GetConVarValue("rotgb_default_wave_preset"))
		end
		self:SetUseType(SIMPLE_USE)
		if not self.NoAutoStart then
			self.NoAutoStart = true
			self:SetAutoStart(true)
		end
		self.rotgb_ToSpawn = {}
		gballoon_pob.Initialize(self)
	end
end

function ENT:PreEntityCopy()
	self.rotgb_DuplicatorTimeOffset = CurTime()
	self.rotgb_CopiedToSpawn = table.Copy(self.rotgb_ToSpawn)
end

function ENT:PostEntityPaste(ply,ent,tab)
	self.rotgb_ToSpawn = self.rotgb_CopiedToSpawn
	self:AddTimePhase(CurTime() - (self.rotgb_DuplicatorTimeOffset or CurTime()))
end

function ENT:AddTimePhase(timeToAdd)
	self:SetNextWaveTime(self:GetNextWaveTime()+timeToAdd)
	for k,v in pairs(self.rotgb_ToSpawn) do
		v.startTime = v.startTime + timeToAdd
		v.endTime = v.endTime + timeToAdd
	end
end

function ENT:SetAutoStart(bool, activator)
	self:SetAutoStartInternal(bool)
	if bool then
		self:TriggerOutput("OnAutoStartEnabled", activator)
	else
		self:TriggerOutput("OnAutoStartDisabled", activator)
	end
end

function ENT:GetAutoStart()
	return self:GetAutoStartInternal()
end

function ENT:Use(activator)
	--if input:lower()=="balloon_start_wave" then
		local cwave = self:GetWave()
		if cwave == self:GetLastWave() + 1 and (self.EnableBalloonChecking or self:GetNextWaveTime() > CurTime()) then return end
		if ((IsValid(activator) and activator:GetClass()~="gballoon_spawner" or activator == self) and self:GetStartAll() and not self.LoopPrevent) then
			self.LoopPrevent = true
			for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
				if v ~= self and v:GetWave() == cwave then
					v:Use(self,self,USE_ON,1)
				end
			end
			self.LoopPrevent = false
		end
		self:SetNWBool("HasShownUsage",true)
		if not self:GetWaveTable()[cwave] then
			self:GenerateNextWave(cwave)
		end
		local trigent = ents.FindByName("wave_start_relay")[1]
		if IsValid(trigent) and not tobool(self.DontTriggerWaveRelays) then
			if not trigent.RotgB_HasFired then
				trigent:Fire("Trigger")
				trigent.RotgB_HasFired = true
			end
		end
		if self:TriggerWaveEnded() then return self:Remove() end
		self:SetNextWaveTime(CurTime()+self:GetWaveDuration(cwave)/self:GetSpeedMul())
		hook.Run("gBalloonSpawnerWaveStarted",self,cwave)
		self:TriggerOutput("OnWaveStart",activator,cwave)
		if not self.NoMessages then
			PrintMessage(HUD_PRINTTALK,"Wave "..cwave.." started!")
		end
		self:SpawnWave(cwave)
		self.EnableBalloonChecking = true
		self:SetWave(cwave+1)
	--end
end

function ENT:SpawnWave(cwave)
	local curTime = CurTime()
	for k,v in pairs(self:GetWaveTable()[cwave] or {}) do
		if k=="rbe" and not self.NoMessages then
			PrintMessage(HUD_PRINTTALK,"RgBE: "..v)
		elseif tonumber(k) then
			local balloontype,amount,timeframe,delay = unpack(v)
			delay = (delay or 0) / self:GetSpeedMul()
			timeframe = (timeframe or 0) / self:GetSpeedMul()
			local spawnTable = {type = balloontype, amount = amount or 1, current = 0, startTime = curTime + delay}
			spawnTable.endTime = spawnTable.startTime + timeframe
			table.insert(self.rotgb_ToSpawn, spawnTable)
		end
	end
end

function ENT:GetWaveTable()
	return ROTGB_CUSTOM_WAVES[self:GetWaveFile()] or self:GetWaveFile()~="" and self.CustomWaveData or ROTGB_WAVES
end

function ENT:GenerateNextWave(cwave)
	if not self:GetWaveTable()[cwave-1] then
		self:GenerateNextWave(cwave-1)
	end
	local erbe = self:GetWaveTable()[cwave-1].assumerbe and self:GetWaveTable()[cwave-1].assumerbe*1.1 or self:GetWaveTable()[cwave-1].rbe*1.1
	local trbe = 0
	local wavetab = {}
	local choices = {"gballoon_blimp_blue","gballoon_blimp_red","gballoon_blimp_green","gballoon_fast_hidden_regen_shielded_blimp_gray","gballoon_blimp_purple","gballoon_fast_blimp_magenta","gballoon_blimp_rainbow"}
	local factors = {100,50,20,10,5,2,1}
	while true do
		if trbe > (self:GetWaveTable()[cwave-1].assumerbe or self:GetWaveTable()[cwave-1].rbe) then break end
		local genval = util.SharedRandom("ROTGB_WAVEGEN__"..self:GetWaveFile().."_"..cwave,0,7,trbe)
		local choice = choices[math.floor(genval)+1]
		local crbe = scripted_ents.GetStored("gballoon_base").t.rotgb_rbetab[choice]
		local amount = math.Clamp((erbe-trbe)/crbe,1,120)
		for i,v in ipairs(factors) do
			if amount>=v then amount=v break end
		end
		table.insert(wavetab,{choice,amount,10})
		trbe = trbe + crbe * amount
	end
	wavetab.rbe = math.Round(trbe)
	wavetab.duration = 10
	--wavetab.unnatural = true
	self:GetWaveTable()[cwave] = wavetab
end

function ENT:TriggerWaveEnded()
	local cwave = self:GetWave()
	local inFreeplay = cwave > self:GetLastWave()
	if (self.lastEndWaveTriggered or 1) ~= cwave then
		self.lastEndWaveTriggered = cwave
		local income = 100/self:GetSpawnDivider()*ROTGB_GetConVarValue("rotgb_cash_mul")
		if engine.ActiveGamemode() == "rotgb" then
			income = income + hook.Run("GetSkillAmount", "waveWaveIncome")*(cwave-1)
			income = income * (1+hook.Run("GetSkillAmount", "waveIncome")/100)
		end
		print(income)
		ROTGB_AddCash(income)
		hook.Run("gBalloonSpawnerWaveEnded",self,cwave-1)
		if inFreeplay and not self.WinWave then
			self.WinWave = cwave
			if not self.NoMessages then
				hook.Run("AllBalloonsDestroyed")
				PrintMessage(HUD_PRINTTALK,"All standard waves cleared! Congratulations, you win!")
				PrintMessage(HUD_PRINTTALK,"If you want a harder challenge, try doubling the gBalloons' health, spawn rate or halving the cash multiplier.")
				if ROTGB_GetConVarValue("rotgb_freeplay") then
					PrintMessage(HUD_PRINTTALK,"BEWARE! The gBalloons become exponentially faster and faster after each wave!")
				end
			end
		end
	end
	return inFreeplay and not ROTGB_GetConVarValue("rotgb_freeplay")
end

function ENT:TriggerWaveFinished()
	self:TriggerOutput("OnWaveFinished",nil,self:GetWave()-1)
	if not tobool(self.DontTriggerWaveRelays) then
		local trigent = ents.FindByName("wave_start_relay")[1]
		if IsValid(trigent) then
			if trigent.RotgB_HasFired then
				trigent.RotgB_HasFired = nil
				trigent = ents.FindByName("wave_finished_relay")[1]
				if IsValid(trigent) then
					trigent:Fire("Trigger")
				end
			end
		end
	end
end

function ENT:TriggerWaveFinishedShortly()
	self:TriggerOutput("OnWaveFinishedShortly",nil,self:GetWave()-1)
	if not tobool(self.DontTriggerWaveRelays) then
		local trigent = ents.FindByName("wave_intermission_relay")[1]
		if IsValid(trigent) then
			trigent:Fire("Trigger")
		end
	end
end

function ENT:SpawnNextWave()
	if self.OutputShortlyThreshold < self:GetAutoStartDelay() then
		self:TriggerWaveFinished()
	else
		self:TriggerWaveFinishedShortly()
	end
	if self:TriggerWaveEnded() then return self:Remove() end
	if self:GetWave() == self:GetLastWave() + 1 then return end
	if self:GetAutoStartDelay()>0 then
		timer.Simple(self:GetAutoStartDelay(),function()
			if (IsValid(self) and self:GetAutoStart()) then
				self:Use(self,self,USE_ON,1)
			end
		end)
	elseif self:GetAutoStart() then
		self:Use(self,self,USE_ON,1)
	end
end

local function SpawnTableNotDoneFilter(k,v)
	return v.current ~= v.amount
end

function ENT:Think()
	if self.EnableBalloonChecking and SERVER then
		if next(self.rotgb_ToSpawn) then
			local filterRequired = false
			for i,v in ipairs(self.rotgb_ToSpawn) do
				if v.current == v.amount then
					filterRequired = true
				else
					self:SpawnByTable(v)
				end
			end
			if filterRequired then
				self.rotgb_ToSpawn = ROTGB_FilterSequential(self.rotgb_ToSpawn, SpawnTableNotDoneFilter)
			end
		elseif self:GetForceNextWave() or not ROTGB_BalloonsExist() then
			self.EnableBalloonChecking = nil
			self:SpawnNextWave()
		end
	end
	
	if SERVER and self.CustomWaveName ~= self:GetWaveFile() then
		self.CustomWaveName = self:GetWaveFile()
		if ROTGB_CUSTOM_WAVES[self.CustomWaveName] then
			self:SetNWString("rotgb_validwave",self.CustomWaveName)
			PrintMessage(HUD_PRINTTALK, "\""..self:GetWaveFile().."\" loaded successfully.")
		elseif SERVER and file.Exists("rotgb_wavedata/"..self:GetWaveFile()..".dat", "DATA") then
			local rawdata = util.JSONToTable(util.Decompress(file.Read("rotgb_wavedata/"..self:GetWaveFile()..".dat","DATA") or ""))
			if rawdata then
				if not self.NoMessages then
					PrintMessage(HUD_PRINTTALK, "\""..self:GetWaveFile().."\" loaded successfully.")
				end
				local packetlength = 60000
				local textdata = file.Read("rotgb_wavedata/"..self:GetWaveFile()..".dat","DATA")
				local datablocks = math.ceil(#textdata/packetlength)
				for i=1,datablocks do
					net.Start("rotgb_generic")
					net.WriteUInt(ROTGB_OPERATION_WAVE_TRANSFER, 8)
					net.WriteString(self:GetWaveFile())
					net.WriteUInt(datablocks, 16)
					net.WriteUInt(i, 16)
					local datafrac = textdata:sub(packetlength*(i-1)+1, packetlength*i)
					net.WriteUInt(#datafrac, 16)
					net.WriteData(datafrac, #datafrac)
					net.Broadcast()
				end
				self.CustomWaveData = rawdata
				self:SetNWString("rotgb_validwave",self.CustomWaveName)
			end
		end
	end
	if CLIENT and self:GetNWString("rotgb_validwave")~=self.CustomWaveName then
		if ROTGB_CUSTOM_WAVES[self:GetNWString("rotgb_validwave")] then
			self.CustomWaveName = self:GetNWString("rotgb_validwave")
		elseif ((ROTGB_CLIENTWAVES[self:GetWaveFile()] or {})[1] or {}).rbe then
			self.CustomWaveName = self:GetNWString("rotgb_validwave")
			self.CustomWaveData = ROTGB_CLIENTWAVES[self:GetWaveFile()]
		end
	end
	
	self:NextThink(CurTime())
	return true
end

function ENT:SpawnByTable(spawnTable)
	local nextSpawnTime = math.Remap(spawnTable.current+1, 0, spawnTable.amount, spawnTable.startTime, spawnTable.endTime)
	if nextSpawnTime <= CurTime() then
		spawnTable.current = spawnTable.current+1
		self.TimesSpawned = (self.TimesSpawned or -1) + 1
		if (self.TimesSpawned - self:GetDividerDelay()) % self:GetSpawnDivider() == 0 then
			local SpawnPos = self:GetPos()+SPAWN_OFFSET
			local bln = ents.Create("gballoon_base")
			if IsValid(bln) then
				bln:SetPos(SpawnPos)
				local keyValues = list.GetForEdit("NPC")[spawnTable.type].KeyValues
				for k,v in pairs(keyValues) do
					bln:SetKeyValue(k,v)
				end
				hook.Run("gBalloonSpawnerPrespawn", self, bln, keyValues)
				bln:Spawn()
				bln:Activate()
				local nextTargs = {}
				if bln:GetBalloonProperty("BalloonBlimp") then
					self.rotgb_TimesBlimpSpawned = (self.rotgb_TimesBlimpSpawned or 0) + 1
					for i=1,16 do
						local gTarg = self["GetNextBlimpTarget"..i](self)
						if IsValid(gTarg) then
							table.insert(nextTargs,gTarg)
						end
					end
				else
					self.rotgb_TimesSpawned = (self.rotgb_TimesSpawned or 0) + 1
				end
				if next(nextTargs) then
					bln:SetTarget(bln:ChooseNextTargetWeighted(self.rotgb_TimesBlimpSpawned, nextTargs))
				else
					for i=1,16 do
						local gTarg = self["GetNextTarget"..i](self)
						if IsValid(gTarg) then
							table.insert(nextTargs,gTarg)
						end
					end
					if next(nextTargs) then
						local times = bln:GetBalloonProperty("BalloonBlimp") and (self.rotgb_TimesSpawned or 0)+self.rotgb_TimesBlimpSpawned or self.rotgb_TimesSpawned
						bln:SetTarget(bln:ChooseNextTargetWeighted(times, nextTargs))
					end
				end
				if bln.loco then
					bln.loco:SetAcceleration(bln.loco:GetAcceleration()*1.05^math.max(0,(self:GetWave()-1)-(self.WinWave or math.huge)))
				end
			end
		end
	end
end

function ENT:DrawTranslucent()
	if not self:GetWaveTable()[self:GetWave()] then
		self:GenerateNextWave(self:GetWave())
	end
	local cwave = self:GetWave()
	local reqang = (self:GetPos()-LocalPlayer():GetShootPos()):Angle()
	reqang.p = 0
	reqang.y = reqang.y-90
	reqang.r = 90
	if not self:GetHideWave() then
		local text1 = "Next Wave: "..cwave
		local text2 = "RgBE: "..self:GetWaveTable()[cwave].rbe
		local text3 = "Press 'Use' on this entity to start the wave."
		surface.SetFont("DermaLarge")
		local t1x,t1y = surface.GetTextSize(text1)
		local t2x,t2y = surface.GetTextSize(text2)
		local t3x,t3y = surface.GetTextSize(text3)
		local panelw = math.max(t1x,t2x)
		local panelh = t1y+t2y
		cam.Start3D2D(self:GetPos()+Vector(0,0,ROTGB_GetConVarValue("rotgb_hoverover_distance")+panelh*0.2+self:OBBMaxs().z),reqang,0.2)
			surface.SetDrawColor(0,0,0,127)
			surface.DrawRect(panelw/-2,panelh/-2,panelw,panelh)
			surface.SetTextColor(color_white)
			surface.SetTextPos(t1x/-2,panelh/-2)
			surface.DrawText(text1)
			surface.SetTextPos(t2x/-2,panelh/-2+t1y)
			surface.DrawText(text2)
			if not self:GetNWBool("HasShownUsage") then
				surface.SetTextColor(0,255,0)
				surface.SetTextPos(t3x/-2,panelh/-2+t1y+t2y)
				surface.DrawText(text3)
			end
			local percent = math.Clamp((self:GetNextWaveTime()-CurTime())/self:GetWaveDuration(cwave-1)*self:GetSpeedMul()+0.02,0,1)
			ROTGB_DrawCircle(0,panelh/-2-32,16,percent,HSVToColor(percent*120,1,1))
		cam.End3D2D()
	else
		local percent = math.Clamp((self:GetNextWaveTime()-CurTime())/self:GetWaveDuration(cwave-1)*self:GetSpeedMul()+0.02,0,1)
		cam.Start3D2D(self:GetPos()+Vector(0,0,ROTGB_GetConVarValue("rotgb_hoverover_distance")+draw.GetFontHeight("DermaLarge")*0.4+self:OBBMaxs().z),reqang,0.2)
			ROTGB_DrawCircle(0,-draw.GetFontHeight("DermaLarge")-32,16,percent,HSVToColor(percent*120,1,1))
		cam.End3D2D()
	end
end

--[[properties.Add("balloon_start_wave",{
	MenuLabel = "#GameUI_Start",
	MenuIcon = "icon16/flag_green.png",
	Order = 134,
	Filter = function(self,ent)
		return hook.Run("CanProperty",LocalPlayer(),"balloon_start_wave",ent)
	end,
	Action = function(self,ent,trace)
		self:MsgStart()
		net.WriteEntity(ent)
		self:MsgEnd()
	end,
	Receive = function(self,len,ply)
		local ent = net.ReadEntity()
		if hook.Run("CanProperty",ply,"balloon_start_wave",ent) then
			ent:Fire("balloon_start_wave")
		end
	end,
	MenuOpen = function(self,panel,ent)
		panel.PaintOver = function(self2,w,h)
			surface.SetDrawColor(0,255,0,63)
			surface.DrawRect(0,0,w,h)
		end
	end
})

hook.Add("CanProperty","RotgB",function(ply,event,ent)
	if event=="balloon_start_wave" and ent:GetClass()~="gballoon_spawner" then return false end
end)]]

list.Set("NPC","gballoon_spawner",{
	Name = "gBalloon Spawner",
	Class = "gballoon_spawner",
	Category = "RotgB: Miscellaneous"
})
list.Set("SpawnableEntities","gballoon_spawner",{
	PrintName = "gBalloon Spawner",
	ClassName = "gballoon_spawner",
	Category = "RotgB: Miscellaneous"
})