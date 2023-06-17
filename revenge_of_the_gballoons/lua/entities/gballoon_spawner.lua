AddCSLuaFile()

local gballoon_pob = baseclass.Get("gballoon_path_object_base") -- internally sets ENT.Base and ENT.Type too
ENT.PrintName = "gBalloon Spawner"
ENT.Category = "#rotgb.category.miscellaneous"
ENT.ScriptedEntityType = "entity"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.gballoon_spawner.purpose"
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

ROTGB_WAVES_LEGACY = {
	-- format: { balloon_type, amount=1, timespan=0, delay=0 }
	-- RgBE must be included
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
		rbe=30--10*(1+2)
	},
	{
		{"gballoon_blue",10,10},
		{"gballoon_red",20,10},
		duration=10,
		rbe=40--10*2+20
	},
	{ ---- 5
		{"gballoon_green",15,15},
		duration=15,
		rbe=45--15*3
	},
	{
		{"gballoon_green",10,5},
		{"gballoon_blue",10,5,5},
		{"gballoon_red",10,5,10},
		duration=15,
		rbe=60--10*(1+2+3)
	},
	{ -- 7
		{"gballoon_red",6,3},
		{"gballoon_blue",6,3,3},
		{"gballoon_green",6,3,6},
		{"gballoon_yellow",12,6,9},
		duration=15,
		rbe=84--6*6+12*4
	},
	{
		{"gballoon_green",15,15},
		{"gballoon_yellow",15,15,0.5},
		duration=15.5,
		rbe=105--15*(3+4)
	},
	{ ---- 9
		{"gballoon_red",80,20},
		{"gballoon_pink",10,1,19},
		duration=20,
		rbe=130--60+10*5
	},
	{
		{"gballoon_regen_red",15,5},
		{"gballoon_regen_blue",15,5,5},
		{"gballoon_regen_green",15,5,10},
		{"gballoon_regen_yellow",15,5,15},
		duration=20,
		rbe=150--15*(1+2+3+4)
	},
	{ -- 11
		{"gballoon_white"},
		{"gballoon_white",10,20},
		{"gballoon_white",5,20},
		duration=20,
		rbe=176--16*11
	},
	{
		{"gballoon_blue",40,20},
		{"gballoon_white",10,5,15},
		duration=20,
		rbe=190--40*2+10*11
	},
	{ ---- 13
		{"gballoon_black",5,25},
		{"gballoon_black",5,25},
		{"gballoon_black",5,25},
		{"gballoon_green",5,25},
		{"gballoon_green",5,25},
		{"gballoon_green",5,25},
		{"gballoon_red",5,25},
		{"gballoon_red",5,25},
		{"gballoon_red",5,25},
		duration=25,
		rbe=225--15*(11+3+1)
	},
	{
		{"gballoon_regen_pink",50,25},
		duration=25,
		rbe=250--25*5
	},
	{ -- 15
		{"gballoon_purple",25,25},
		duration=25,
		rbe=275--25*11
	},
	{
		{"gballoon_white"},
		{"gballoon_white",5,5},
		{"gballoon_black",5,5,5},
		{"gballoon_purple",5,5,10},
		{"gballoon_black",5,5,15},
		{"gballoon_white",5,5,20},
		{"gballoon_white",nil,nil,25},
		duration=25,
		rbe=297--27*11
	},
	{ ---- 17
		{"gballoon_orange",30,30},
		duration=30,
		rbe=330--30*11
	},
	{
		{"gballoon_red",60,30},
		{"gballoon_blue",60,30},
		{"gballoon_fast_green",60,30},
		duration=30,
		rbe=360--60*(1+2+3)
	},
	{ -- 19
		{"gballoon_zebra",15,30},
		{"gballoon_yellow",15,30},
		duration=30,
		rbe=405--15*(23+4)
	},
	{
		{"gballoon_white",10,30},
		{"gballoon_black",10,30,0.75},
		{"gballoon_purple",10,30,1.5},
		{"gballoon_orange",10,30,2.25},
		duration=32.25,
		rbe=440--40*11
	},
	{ ---- 21
		{"gballoon_aqua",7,7},
		{"gballoon_aqua",7,7,14},
		{"gballoon_aqua",7,7,28},
		duration=35,
		rbe=483--21*23
	},
	{
		{"gballoon_zebra",5,5},
		{"gballoon_black",5,5,5},
		{"gballoon_white",5,5,5},
		{"gballoon_pink",10,5,10},
		{"gballoon_yellow",15,5,15},
		{"gballoon_green",20,5,20},
		{"gballoon_blue",30,5,25},
		{"gballoon_red",60,5,30},
		duration=35,
		rbe=515--5*23+10*11+10*5+15*4+20*3+30*2+60
	},
	{ -- 23
		{"gballoon_gray",2,1},
		{"gballoon_gray",4,2,10},
		{"gballoon_gray",8,4,20},
		{"gballoon_gray",10,5,30},
		duration=35,
		rbe=552--24*23
	},
	{
		{"gballoon_fast_regen_yellow",70,35},
		{"gballoon_shielded_gray",7,35},
		duration=35,
		rbe=602--70*4+7*46
	},
	{ ---- 25
		{"gballoon_gray",8,40},
		{"gballoon_zebra",8,40,1},
		{"gballoon_aqua",8,40,2},
		{"gballoon_error",8,40,3},
		duration=43,
		rbe=736--32*23
	},
	{
		{"gballoon_pink",40,40},
		{"gballoon_white",13,nil,10},
		{"gballoon_black",13,nil,20},
		{"gballoon_purple",13,nil,30},
		{"gballoon_orange",13,nil,40},
		duration=40,
		rbe=772--40*5+52*11
	},
	{ -- 27
		{"gballoon_rainbow",8,40},
		{"gballoon_rainbow"},
		duration=40,
		rbe=837--9*93
	},
	{
		{"gballoon_hidden_orange",3,3},
		{"gballoon_shielded_red",24,8},
		{"gballoon_shielded_blue",24,8,8},
		{"gballoon_shielded_green",24,8,16},
		{"gballoon_shielded_yellow",24,8,24},
		{"gballoon_shielded_pink",24,8,32},
		duration=40,
		rbe=971--32*2*(1+2+3+4+5)+11
	},
	{ ---- 29
		{"gballoon_rainbow",9,45},
		{"gballoon_orange",2,nil,9},
		{"gballoon_pink",2,nil,9},
		{"gballoon_orange",2,nil,18},
		{"gballoon_pink",2,nil,18},
		{"gballoon_orange",2,nil,27},
		{"gballoon_pink",2,nil,27},
		{"gballoon_orange",2,nil,36},
		{"gballoon_pink",2,nil,36},
		{"gballoon_orange",2,nil,45},
		{"gballoon_pink",2,nil,45},
		duration=45,
		rbe=997--10*(5+11)+9*93
	},
	{
		{"gballoon_shielded_rainbow"},
		{"gballoon_shielded_rainbow",5,45},
		duration=45,
		rbe=1116--6*186
	},
	{ -- 31
		{"gballoon_regen_white",15,45},
		{"gballoon_regen_black",15,45},
		{"gballoon_regen_white",15,15,30},
		{"gballoon_regen_black",15,15,30},
		{"gballoon_regen_white",25,5,40},
		{"gballoon_regen_black",25,5,40},
		duration=45,
		rbe=1210--110*11
	},
	{
		{"gballoon_fast_rainbow"},
		{"gballoon_fast_rainbow",nil,nil,9},
		{"gballoon_fast_rainbow",2,nil,18},
		{"gballoon_fast_rainbow",3,nil,27},
		{"gballoon_fast_rainbow",3,nil,36},
		{"gballoon_fast_rainbow",4,nil,45},
		duration=45,
		rbe=1302--14*93
	},
	{ ---- 33
		{"gballoon_white",10,50,2.5},
		{"gballoon_black",10,50,2.5},
		{"gballoon_purple",10,50,2.5},
		{"gballoon_orange",10,50,2.5},
		{"gballoon_gray",10,50},
		{"gballoon_zebra",10,50},
		{"gballoon_aqua",10,50},
		{"gballoon_error",10,50},
		duration=52.5,
		rbe=1360--40*(11+23)
	},
	{
		{"gballoon_fast_regen_pink",250,25},
		{"gballoon_regen_shielded_green",25,25,25},
		{"gballoon_hidden_regen_shielded_red",25,25},
		{"gballoon_fast_hidden_regen_shielded_red",25,25,25},
		duration=50,
		rbe=1500--250*5+50*6+50*2
	},
	{ -- 35
		{"gballoon_ceramic",10,50},
		{"gballoon_ceramic",5,50},
		duration=50,
		rbe=2940--15*196
	},
	{
		{"gballoon_regen_shielded_blue",150,50},
		{"gballoon_aqua",25,50},
		{"gballoon_shielded_white",25,50},
		duration=50,
		rbe=1725--25*(23+22)+600
	},
	{ ---- 37
		{"gballoon_fast_red",1925,55},
		duration=55,
		rbe=1925
	},
	{
		{"gballoon_fast_hidden_regen_shielded_green",55,55},
		{"gballoon_fast_hidden_regen_shielded_green",55,44,11},
		{"gballoon_fast_hidden_regen_shielded_green",55,33,22},
		{"gballoon_fast_hidden_regen_shielded_green",55,22,33},
		{"gballoon_fast_hidden_regen_shielded_green",55,11,44},
		{"gballoon_fast_hidden_regen_shielded_green",55,nil,55},
		duration=55,
		rbe=1980--330*6
	},
	{
		{"gballoon_shielded_ceramic",11,55},
		duration=55,
		rbe=4312--11*392
	},
	{ -- 40
		{"gballoon_blimp_blue"},
		duration=0,
		rbe=984
	},-- 40
	{
		{"gballoon_red",120,60},
		{"gballoon_orange",120,60,0.125},
		{"gballoon_yellow",120,60,0.25},
		{"gballoon_ceramic",6,60},
		duration=60.25,
		rbe=3096--120*(1+11+4)+6*196
	},
	{
		{"gballoon_rainbow",12,60},
		{"gballoon_gray",12,60},
		{"gballoon_zebra",12,60},
		{"gballoon_aqua",12,60},
		{"gballoon_error",12,60},
		{"gballoon_white",12,60},
		{"gballoon_black",12,60},
		{"gballoon_purple",12,60},
		{"gballoon_orange",12,60},
		{"gballoon_pink",12,60},
		{"gballoon_yellow",12,60},
		{"gballoon_green",12,60},
		{"gballoon_blue",12,60},
		{"gballoon_red",12,60},
		duration=60,
		rbe=2928--12*(93+23*4+11*4+15)
	},
	{
		{"gballoon_regen_purple",120,60},
		{"gballoon_shielded_white",60,60},
		{"gballoon_fast_hidden_pink",120,60},
		duration=60,
		rbe=3240--120*(11+11+5)
	},
	{
		{"gballoon_blimp_blue",5,60},
		{"gballoon_pink",120,60},
		duration=60,
		rbe=5520--5*984+600
	},
	{ -- 45
		{"gballoon_hidden_gray",180,60},
		duration=60,
		rbe=4140--180*23
	},-- 45
	{
		{"gballoon_hidden_zebra",60,60},
		{"gballoon_fast_gray",60,60},
		{"gballoon_regen_white",60,60},
		{"gballoon_shielded_black",60,60},
		duration=60,
		rbe=4740--60*(23+23+11+22)
	},
	{
		{"gballoon_zebra",58,58,1},
		{"gballoon_white",29,58},
		{"gballoon_white",29,58,0.2},
		{"gballoon_white",29,58,0.4},
		{"gballoon_white",29,58,0.6},
		{"gballoon_white",29,58,0.8},
		{"gballoon_black",29,58,1.0},
		{"gballoon_black",29,58,1.2},
		{"gballoon_black",29,58,1.4},
		{"gballoon_black",29,58,1.6},
		{"gballoon_black",29,58,1.8},
		{"gballoon_blimp_blue",nil,nil,60},
		duration=60,
		rbe=5508--290*11+58*23+984
	},
	{
		{"gballoon_zebra",15,15},
		{"gballoon_zebra",15,15,0.2},
		{"gballoon_zebra",15,15,0.4},
		{"gballoon_zebra",15,15,0.6},
		{"gballoon_hidden_zebra",15,15,0.8},
		{"gballoon_fast_ceramic",15,15},
		{"gballoon_regen_orange",15,15,15},
		{"gballoon_fast_yellow",75,15,15},
		{"gballoon_fast_shielded_black",15,15,30},
		{"gballoon_fast_shielded_red",75,15,30},
		{"gballoon_blimp_blue",3,15,45},
		{"gballoon_rainbow",2,nil,50},
		{"gballoon_rainbow",2,nil,55},
		{"gballoon_rainbow",2,nil,60},
		duration=60,
		rbe=8220--75*11+15*196+15*11+75*4+15*22+150+3*984+6*93
	},
	{
		{"gballoon_error",60,60},
		{"gballoon_fast_error",30,60},
		{"gballoon_hidden_error",30,60},
		{"gballoon_regen_error",30,60},
		{"gballoon_shielded_error",30,60},
		{"gballoon_fast_hidden_error",15,60},
		{"gballoon_fast_regen_error",15,60},
		{"gballoon_fast_shielded_error",15,60},
		{"gballoon_hidden_regen_error",15,60},
		{"gballoon_hidden_shielded_error",15,60},
		{"gballoon_regen_shielded_error",15,60},
		duration=60,
		rbe=6210--(60+120+90)*23
	},
	{ -- 50
		{"gballoon_ceramic",30,30},
		{"gballoon_brick",30,30,30},
		duration=60,
		rbe=18690--30*196+30*427
	},-- 50
	{
		{"gballoon_ceramic",15,60},
		{"gballoon_ceramic",15,60},
		{"gballoon_ceramic",15,60},
		{"gballoon_ceramic",15,60},
		{"gballoon_ceramic",15,60},
		duration=60,
		rbe=14700--75*196
	},
	{
		{"gballoon_blimp_blue",10,60},
		{"gballoon_regen_gray",120,60},
		duration=60,
		rbe=12600--10*984+120*23
	},
	{
		{"gballoon_regen_rainbow",60,60},
		{"gballoon_fast_aqua",180,60},
		duration=60,
		rbe=9720--60*93+180*23
	},
	{
		{"gballoon_fast_hidden_regen_shielded_pink",300,60},
		{"gballoon_brick",50,25,35},
		{"gballoon_white",50,25,35},
		duration=60,
		rbe=24900--300*10+50*(427+11)
	},
	{ -- 55
		{"gballoon_blimp_blue",15,60},
		{"gballoon_white",60,60},
		{"gballoon_white",60,60},
		{"gballoon_fast_pink",120,60},
		{"gballoon_fast_yellow",120,60},
		duration=60,
		rbe=17160--120*(5+4)+60*22+15*984
	},-- 55
	{
		{"gballoon_brick",60,60},
		{"gballoon_regen_purple",120,60},
		{"gballoon_hidden_black",120,60},
		{"gballoon_hidden_white",120,60},
		{"gballoon_shielded_pink",120,60},
		duration=60,
		rbe=30780--120*(10+11+11+11)+60*427
	},
	{
		{"gballoon_shielded_white",240,60},
		{"gballoon_shielded_purple",120,60},
		{"gballoon_blimp_blue",10,20,40},
		duration=60,
		rbe=17760--240*22+120*22+10*984
	},
	{
		{"gballoon_fast_orange",300,60},
		{"gballoon_yellow",60,60},
		{"gballoon_shielded_brick",30,60},
		{"gballoon_fast_yellow",30,10,50},
		{"gballoon_fast_red",30,10,50},
		{"gballoon_fast_red",30,10,50},
		{"gballoon_brick",30,10,50},
		duration=60,
		rbe=42150--300*11+60*4+30*854+30*6+30*427
	},
	{
		{"gballoon_blimp_blue",20,60},
		{"gballoon_blimp_blue",3,3,57},
		{"gballoon_blimp_blue",2,2,58},
		{"gballoon_blimp_blue",nil,nil,60},
		{"gballoon_blimp_blue",nil,nil,60},
		duration=60,
		rbe=26568--27*984
	},
	{ -- 60
		{"gballoon_blimp_red"},
		duration=0,
		rbe=4636
	},-- 60
	{
		{"gballoon_blimp_blue",10,60},
		{"gballoon_ceramic",120,60},
		duration=60,
		rbe=33360--120*196+10*984
	},
	{
		{"gballoon_brick",15,60},
		{"gballoon_brick",15,60},
		{"gballoon_brick",15,60},
		{"gballoon_brick",15,60},
		{"gballoon_brick",15,60},
		{"gballoon_brick",15,60},
		{"gballoon_brick",15,60},
		{"gballoon_brick",15,60},
		{"gballoon_brick",15,60},
		{"gballoon_brick",15,60},
		duration=60,
		rbe=64050--150*427
	},
	{
		{"gballoon_ceramic",60,60},
		{"gballoon_ceramic",10,nil,30},
		{"gballoon_ceramic",10,nil,30},
		{"gballoon_ceramic",10,nil,30},
		{"gballoon_ceramic",10,nil,30},
		{"gballoon_ceramic",10,nil,30},
		{"gballoon_ceramic",10,nil,60},
		{"gballoon_ceramic",10,nil,60},
		{"gballoon_ceramic",10,nil,60},
		{"gballoon_ceramic",10,nil,60},
		{"gballoon_ceramic",10,nil,60},
		{"gballoon_ceramic",10,nil,60},
		{"gballoon_ceramic",10,nil,60},
		{"gballoon_ceramic",10,nil,60},
		{"gballoon_ceramic",10,nil,60},
		{"gballoon_ceramic",10,nil,60},
		duration=60,
		rbe=41160--(60+10*15)*196
	},
	{
		{"gballoon_blimp_blue",10,5},
		{"gballoon_blimp_blue",15,5,25},
		{"gballoon_blimp_blue",15,5,55},
		duration=60,
		rbe=39360--40*984
	},
	{ -- 65
		{"gballoon_brick",80,40},
		{"gballoon_ceramic",80,40,0.25},
		{"gballoon_blimp_blue",10,10,50},
		{"gballoon_blimp_blue",nil,nil,60},
		{"gballoon_blimp_blue",nil,nil,60},
		{"gballoon_blimp_blue",nil,nil,60},
		duration=60,
		rbe=62632--80*(427+196)+13*984
	},-- 65
	{
		{"gballoon_blimp_red",6,60},
		{"gballoon_blimp_red",3,60},
		{"gballoon_blimp_blue",nil,60},
		duration=60,
		rbe=42708--9*4636+984
	},
	{
		{"gballoon_blimp_blue",30,60},
		{"gballoon_blimp_blue",15,30,30},
		{"gballoon_blimp_blue",7,14,46},
		{"gballoon_blimp_blue",2,4,56},
		duration=60,
		rbe=53136--54*984
	},
	{
		{"gballoon_regen_shielded_ceramic",180,60},
		duration=60,
		rbe=70560--180*392
	},
	{
		{"gballoon_blimp_red",10,60},
		{"gballoon_blimp_blue",10,60,3},
		{"gballoon_ceramic",6,1,59},
		{"gballoon_ceramic",6,1,59},
		{"gballoon_ceramic",6,1,59},
		{"gballoon_ceramic",6,1,59},
		{"gballoon_ceramic",6,1,59},
		duration=60,
		rbe=62080--10*(4636+984)+30*196
	},
	{ -- 70
		{"gballoon_ceramic",100,20},
		{"gballoon_brick",100,20,20},
		{"gballoon_marble",100,20,40},
		duration=60,
		rbe=159700--100*(196+427+974)
	},-- 70
	{
		{"gballoon_blimp_red",10,60},
		{"gballoon_blimp_red",5,60},
		duration=60,
		rbe=69540--15*4636
	},
	{
		{"gballoon_fast_hidden_regen_shielded_ceramic",120,60},
		{"gballoon_blimp_blue",20,60},
		{"gballoon_blimp_blue",20,60},
		duration=60,
		rbe=86400--120*392+40*984
	},
	{
		{"gballoon_shielded_marble",60,60},
		{"gballoon_shielded_brick",60,60},
		{"gballoon_shielded_ceramic",60,60},
		duration=60,
		rbe=191640--60*(196+427+974)*2
	},
	{
		{"gballoon_fast_hidden_regen_shielded_orange",120,60},
		{"gballoon_blimp_red",15,60},
		{"gballoon_blimp_blue",15,60},
		duration=60,
		rbe=86940--120*22+15*4636+15*984
	},
	{ -- 75
		{"gballoon_fast_marble",30,60},
		{"gballoon_fast_marble",30,60},
		{"gballoon_fast_marble",30,60},
		{"gballoon_fast_marble",30,60},
		{"gballoon_fast_marble",30,60},
		{"gballoon_fast_marble",30,60},
		{"gballoon_fast_marble",30,60},
		{"gballoon_fast_marble",30,60},
		{"gballoon_fast_marble",30,60},
		{"gballoon_fast_marble",30,60},
		{"gballoon_fast_marble",30,60},
		duration=60,
		rbe=321420--330*974
	},-- 75
	{
		{"gballoon_blimp_red",6,60},
		{"gballoon_blimp_red",6,60},
		{"gballoon_blimp_red",6,60},
		{"gballoon_blimp_red",6,60},
		duration=60,
		rbe=111264--24*4636
	},
	{
		{"gballoon_blimp_blue",120,60},
		{"gballoon_ceramic",60,60},
		duration=60,
		rbe=129840--120*984+60*196
	},
	{
		{"gballoon_blimp_red",2,60},
		{"gballoon_blimp_red",2,60},
		{"gballoon_blimp_red",2,60},
		{"gballoon_blimp_red",2,60},
		{"gballoon_blimp_red",2,60},
		{"gballoon_blimp_red",2,60},
		{"gballoon_blimp_red",2,60},
		{"gballoon_blimp_red",2,60},
		{"gballoon_blimp_blue",60,60},
		duration=60,
		rbe=133216--16*4636+60*984
	},
	{
		{"gballoon_shielded_marble",240,60},
		duration=60,
		rbe=467520--240*1948
	},
	{ -- 80
		{"gballoon_blimp_green"},
		duration=0,
		rbe=22544
	},-- 80
	{
		{"gballoon_blimp_blue",120,60},
		{"gballoon_blimp_blue",60,60},
		duration=60,
		rbe=177120--180*984
	},
	{
		{"gballoon_blimp_red",30,60},
		{"gballoon_marble",120,60},
		duration=60,
		rbe=255960--120*974+30*4636
	},
	{
		{"gballoon_blimp_blue",20,20},
		{"gballoon_blimp_red",10,20,20},
		{"gballoon_blimp_green",5,20,40},
		duration=60,
		rbe=178760--20*984+10*4636+5*22544
	},
	{
		{"gballoon_blimp_red",20,60},
		{"gballoon_blimp_red",4,60},
		{"gballoon_blimp_blue",20,60},
		{"gballoon_blimp_blue",20,60},
		{"gballoon_blimp_blue",20,60},
		{"gballoon_blimp_blue",20,60},
		{"gballoon_blimp_blue",4,60},
		{"gballoon_blimp_blue",4,60},
		{"gballoon_blimp_blue",4,60},
		{"gballoon_blimp_blue",4,60},
		duration=60,
		rbe=205278--24*(4*984+4636)
	},
	{ -- 85
		{"gballoon_blimp_green",6,60},
		{"gballoon_blimp_green",3,60},
		duration=60,
		rbe=202896--9*22544
	},-- 85
	{
		{"gballoon_blimp_red",30,60},
		{"gballoon_blimp_blue",60,60},
		{"gballoon_blimp_blue",30,60},
		{"gballoon_blimp_blue",15,60},
		duration=60,
		rbe=242400--30*4636+105*984
	},
	{
		{"gballoon_blimp_red",30,30},
		{"gballoon_blimp_blue",120,30,30},
		duration=60,
		rbe=257160--120*984+30*4636
	},
	{
		{"gballoon_blimp_green",10,60},
		{"gballoon_blimp_green"},
		duration=60,
		rbe=247984--11*22544
	},
	{
		{"gballoon_blimp_blue",300,60},
		duration=60,
		rbe=295200--300*984
	},
	{ -- 90
		{"gballoon_fast_hidden_regen_shielded_blimp_gray"},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",100,50,10},
		duration=60,
		rbe=867792--101*8592
	},-- 90
	{
		{"gballoon_red",9,nil},
		{"gballoon_blue",9,nil,3},
		{"gballoon_green",9,nil,6},
		{"gballoon_yellow",9,nil,9},
		{"gballoon_pink",9,nil,12},
		{"gballoon_white",9,nil,15},
		{"gballoon_black",9,nil,18},
		{"gballoon_purple",9,nil,21},
		{"gballoon_orange",9,nil,24},
		{"gballoon_gray",9,nil,27},
		{"gballoon_zebra",9,nil,30},
		{"gballoon_aqua",9,nil,33},
		{"gballoon_error",9,nil,36},
		{"gballoon_rainbow",9,nil,39},
		{"gballoon_ceramic",9,nil,42},
		{"gballoon_brick",9,nil,45},
		{"gballoon_marble",9,nil,48},
		{"gballoon_blimp_blue",9,nil,51},
		{"gballoon_blimp_red",9,nil,54},
		{"gballoon_blimp_green",9,nil,57},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",9,nil,60},
		duration=60,
		rbe=347373--9*(8592+22544+4636+984+974+427+196+93+23*4+11*4+15)
	},
	{
		{"gballoon_blimp_blue",60,60},
		{"gballoon_blimp_blue",30,60,0.25},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",60,60,0.5},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",30,60,0.75},
		duration=60,
		rbe=861840--90*(984+8592)
	},
	{
		{"gballoon_blimp_green",6,60},
		{"gballoon_blimp_green",6,60},
		{"gballoon_blimp_green"},
		{"gballoon_blimp_green"},
		duration=60,
		rbe=315616--14*22544
	},
	{
		{"gballoon_blimp_green",15,60},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",15,60},
		duration=60,
		rbe=467040--15*(8592+22544)
	},
	{ -- 95
		{"gballoon_blimp_blue",14,7,13},
		{"gballoon_green",120,60},
		{"gballoon_blue",40,20},
		{"gballoon_red",80,40},
		{"gballoon_blimp_red",14,7,33},
		{"gballoon_blimp_green",14,7,53},
		duration=60,
		rbe=394816--14*(984+4636+22544)+120*3+40*2+80
	},-- 95
	{
		{"gballoon_blimp_red",60,60},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",30,60},
		{"gballoon_marble",240,60},
		duration=60,
		rbe=769680--60*(8592/2+4636+974*4)
	},
	{
		{"gballoon_blimp_green",15,30},
		{"gballoon_blimp_red",15,60},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",15,15,45},
		duration=60,
		rbe=536580--15*(8592+22544+4636)
	},
	{
		{"gballoon_blimp_green",20,60},
		{"gballoon_shielded_marble",6,nil,60},
		{"gballoon_shielded_marble",6,nil,60},
		{"gballoon_shielded_marble",6,nil,60},
		{"gballoon_shielded_marble",6,nil,60},
		{"gballoon_shielded_marble",6,nil,60},
		duration=60,
		rbe=509320--20*22544+30*1948
	},
	{
		{"gballoon_blimp_blue",30,15},
		{"gballoon_blimp_red",15,15,15},
		{"gballoon_blimp_green",15,15,30},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",30,15,45},
		duration=60,
		rbe=694980--30*984+15*4636+15*22544+30*8592
	},
	{ -- 100
		{"gballoon_blimp_purple"},
		duration=0,
		rbe=73680
	},-- 100
	{
		{"gballoon_blimp_green",15,60},
		{"gballoon_blimp_green",10,60},
		{"gballoon_blimp_green",2,60},
		duration=60,
		rbe=608688--27*22544
	},
	{
		{"gballoon_blimp_red",60,60},
		{"gballoon_blimp_red",20,60},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",120,60,0.25},
		duration=60.25,
		rbe=1243680--120*4636+80*8592
	},
	{
		{"gballoon_blimp_green",30,30},
		{"gballoon_blimp_red",10,30,15},
		{"gballoon_blimp_blue",3,30,30},
		duration=60,
		rbe=725632--30*22544+10*4636+3*984
	},
	{
		{"gballoon_blimp_red",20,60},
		{"gballoon_blimp_green",20,60,1},
		{"gballoon_blimp_blue",20,60,2},
		{"gballoon_blimp_red",8,48,10},
		{"gballoon_blimp_green",8,48,11},
		{"gballoon_blimp_blue",8,48,12},
		duration=60,
		rbe=788592--28*(22544+4636+984)
	},
	{ -- 105
		{"gballoon_blimp_red",180,60},
		{"gballoon_blimp_red",17,nil,60},
		duration=60,
		rbe=913292--197*4636
	},-- 105
	{
		{"gballoon_blimp_green",30,60},
		{"gballoon_blimp_green",10,60},
		duration=60,
		rbe=901760--40*22544
	},
	{
		{"gballoon_blimp_red",240,60},
		duration=60,
		rbe=1112640--240*4636
	},
	{
		{"gballoon_blimp_red",10,60},
		{"gballoon_blimp_green",10,60},
		{"gballoon_blimp_purple",10,60},
		duration=60,
		rbe=1008600--10*(22544+73680+4636)
	},
	{
		{"gballoon_blimp_red",60,30},
		{"gballoon_blimp_blue",180,30},
		{"gballoon_blimp_purple",10,30,30},
		duration=60,
		rbe=1192080--180*984+60*4636+10*73680
	},
	{ -- 110
		{"gballoon_fast_blimp_magenta",60,60},
		{"gballoon_fast_blimp_magenta",20,20,40},
		{"gballoon_fast_blimp_magenta",20,20,40},
		duration=60,
		rbe=1869900--100*18699
	},-- 110
	{
		{"gballoon_blimp_purple",15,60},
		{"gballoon_blimp_green",6,60},
		{"gballoon_blimp_red",10,60},
		{"gballoon_blimp_blue",20,60},
		{"gballoon_ceramic",6,60},
		{"gballoon_gray",nil,60},
		{"gballoon_pink",nil,60},
		{"gballoon_blue",nil,60},
		duration=60,
		rbe=1307710--15*73680+6*22544+10*4636+20*984+6*196+23+5+2
	},
	{
		{"gballoon_blimp_green",10,30},
		{"gballoon_blimp_green",10,30},
		{"gballoon_blimp_green",10,30},
		{"gballoon_blimp_green",10,30},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",10,30},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",10,30},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",10,30},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",10,30},
		{"gballoon_blimp_purple",6,30,30},
		duration=60,
		rbe=1687520--40*(22544+8592)+6*73680
	},
	{
		{"gballoon_blimp_purple",20,60},
		{"gballoon_blimp_green",5,60},
		{"gballoon_blimp_red",3,60},
		{"gballoon_blimp_blue",nil,60},
		{"gballoon_fast_hidden_regen_ceramic",nil,60},
		{"gballoon_fast_hidden_regen_pink",nil,60},
		{"gballoon_fast_hidden_regen_green",nil,60},
		duration=60,
		rbe=1601416--20*73680+5*22544+3*4636+984+196+5+3
	},
	{
		{"gballoon_fast_blimp_magenta",120,60},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",120,60},
		duration=60,
		rbe=3274920--120*(18699+8592)
	},
	{ -- 115
		{"gballoon_blimp_purple",5,60},
		{"gballoon_blimp_purple",5,60},
		{"gballoon_blimp_purple",5,60},
		{"gballoon_blimp_purple",5,60},
		{"gballoon_blimp_purple",5,60},
		duration=60,
		rbe=1842000--25*73680
	},-- 115
	{
		{"gballoon_fast_blimp_magenta",180,60},
		duration=60,
		rbe=3365820--180*18699
	},
	{
		{"gballoon_blimp_purple",30,60},
		duration=60,
		rbe=2210400--30*73680
	},
	{
		{"gballoon_blimp_green",120,60},
		duration=60,
		rbe=2705280--120*22544
	},
	{
		{"gballoon_red",25,5},
		{"gballoon_blue",25,5,5},
		{"gballoon_green",25,5,10},
		{"gballoon_yellow",25,5,15},
		{"gballoon_pink",25,5,20},
		{"gballoon_white",25,5,25},
		{"gballoon_black",25,5,30},
		{"gballoon_purple",25,5,35},
		{"gballoon_orange",25,5,40},
		{"gballoon_gray",25,5,45},
		{"gballoon_zebra",25,5,50},
		{"gballoon_aqua",25,5,55},
		{"gballoon_error",25,5,60},
		{"gballoon_rainbow",25,5,65},
		{"gballoon_ceramic",25,5,70},
		{"gballoon_brick",25,5,75},
		{"gballoon_marble",25,5,80},
		{"gballoon_blimp_blue",25,5,85},
		{"gballoon_blimp_red",25,5,90},
		{"gballoon_blimp_green",25,5,95},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",25,5,100},
		{"gballoon_blimp_purple",25,5,105},
		{"gballoon_fast_blimp_magenta",50,10,110},
		duration=120,
		rbe=3741875--25*(18699*2+73680+8592+22544+4636+984+974+427+196+93+23*4+11*4+15)
	},
	{ -- 120
		{"gballoon_blimp_rainbow"},
		{"gballoon_red",600,300},
		{"gballoon_fast_blimp_magenta",50,10,60},
		{"gballoon_blimp_purple",50,10,70},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",50,10,80},
		{"gballoon_blimp_green",50,10,90},
		{"gballoon_blimp_red",50,10,100},
		{"gballoon_blimp_blue",50,10,110},
		{"gballoon_fast_hidden_regen_shielded_marble",50,10,120},
		{"gballoon_hidden_regen_shielded_brick",50,10,130},
		{"gballoon_fast_regen_shielded_ceramic",50,10,140},
		{"gballoon_regen_shielded_rainbow",50,10,150},
		{"gballoon_fast_hidden_shielded_error",50,10,160},
		{"gballoon_hidden_shielded_aqua",50,10,170},
		{"gballoon_fast_shielded_zebra",50,10,180},
		{"gballoon_shielded_gray",50,10,190},
		{"gballoon_fast_hidden_regen_orange",50,10,200},
		{"gballoon_hidden_regen_purple",50,10,210},
		{"gballoon_fast_regen_black",50,10,220},
		{"gballoon_regen_white",50,10,230},
		{"gballoon_fast_hidden_pink",50,10,240},
		{"gballoon_hidden_yellow",50,10,250},
		{"gballoon_fast_green",50,10,260},
		{"gballoon_blue",50,10,270},
		{"gballoon_blimp_rainbow",10,10,290},
		duration=300,
		assumerbe=2.5e6,
		rbe=9770942--284772+50*(18699+73680+8592+22544+4636+984+974*2+427*2+196*2+93*2+23*4*2+11*4+14)+600+10*284772
	}
}

ROTGB_WAVES = { -- format: { balloon_type, amount=1, timespan=0, delay=0 }
	{ -- 1
		{"gballoon_red",10,10},
		duration=10,
		rbe=10
	}, -- 1
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
	}, -- 3
	{
		{"gballoon_blue",20,10},
		duration=10,
		rbe=40--20*2
	},
	{
		{"gballoon_blue",20,5},
		{"gballoon_red",10,5,5},
		duration=10,
		rbe=50--20*2+10
	},
	{ -- 6
		{"gballoon_green",20,10},
		duration=10,
		rbe=60
	}, -- 6
	{
		{"gballoon_green",10,5},
		{"gballoon_blue",20,5,5},
		duration=10,
		rbe=70--20*2+10*3
	},
	{
		{"gballoon_green",10,10},
		{"gballoon_blue",10,10},
		{"gballoon_red",30,10},
		duration=10,
		rbe=80--10*3+10*2+30
	},
	{
		{"gballoon_red",30,5},
		{"gballoon_green",20,5,5},
		duration=10,
		rbe=90
	},
	{ -- 10
		{"gballoon_red",10,2.5},
		{"gballoon_blue",10,2.5,2.5},
		{"gballoon_green",10,2.5,5},
		{"gballoon_yellow",10,2.5,7.5},
		duration=10,
		rbe=100
	}, -- 10
	{
		{"gballoon_yellow",20,10},
		{"gballoon_green",10,5,5},
		duration=10,
		rbe=110
	},
	{
		{"gballoon_green",40,10},
		duration=10,
		rbe=120
	},
	{
		{"gballoon_green",10,10},
		{"gballoon_blue",50,10},
		duration=10,
		rbe=130
	},
	{
		{"gballoon_yellow",20,5},
		{"gballoon_green",20,5,5},
		duration=10,
		rbe=140
	},
	{ -- 15
		{"gballoon_red"},
		{"gballoon_pink",5,5},
		{"gballoon_pink",25,5,5},
		duration=10,
		rbe=151--30*5+1
	}, -- 15
	{
		{"gballoon_yellow",40,10},
		{"gballoon_red",3,nil,10},
		duration=10,
		rbe=163
	},
	{
		{"gballoon_green",50,10},
		{"gballoon_blue",13,1.3,8.7},
		duration=10,
		rbe=176--50*3+13*2
	},
	{
		{"gballoon_pink",30,10},
		{"gballoon_yellow",10,nil,10},
		duration=10,
		rbe=190--30*5+10*4
	},
	{
		{"gballoon_pink",38,7.2},
		{"gballoon_yellow",4,nil,10},
		duration=10,
		rbe=206--38*5+4*4
	},
	{ -- 20
		{"gballoon_regen_yellow",8,4},
		{"gballoon_regen_pink",38,7.6,2.4},
		duration=10,
		rbe=222--8*4+38*5
	}, -- 20
	{ -- 21
		{"gballoon_white",20,10},
		{"gballoon_regen_blue",10,nil,10},
		duration=10,
		rbe=240--20*11+10*2
	}, -- 21
	{
		{"gballoon_black",20,10},
		{"gballoon_regen_red",39,nil,10},
		duration=10,
		rbe=259--20*11+39
	},
	{
		{"gballoon_purple",20,10},
		{"gballoon_yellow",15,1.5,8.5},
		duration=10,
		rbe=280--20*11+15*4
	},
	{
		{"gballoon_orange",25,7.5},
		{"gballoon_regen_green",9,1.8,8.2},
		duration=10,
		rbe=302--25*11+9*3
	},
	{ -- 25
		{"gballoon_fast_green",20,2},
		{"gballoon_orange",20,5,2},
		{"gballoon_regen_white",4,2,7},
		{"gballoon_fast_regen_blue",nil,10},
		duration=10,
		rbe=326--24*11+20*3+1*2
	}, -- 25
	{
		{"gballoon_purple",20,10},
		{"gballoon_black",10,10},
		{"gballoon_fast_blue",10,10},
		{"gballoon_regen_green",nil,10},
		duration=10,
		rbe=353--30*11+10*2+3
	},
	{
		{"gballoon_white",8,8},
		{"gballoon_black",8,8},
		{"gballoon_purple",8,8},
		{"gballoon_orange",8,8},
		{"gballoon_fast_red",29,2.9,7.1},
		duration=10,
		rbe=381--32*11+29
	},
	{ -- 28
		{"gballoon_zebra",15,5},
		{"gballoon_white",3,3,7},
		{"gballoon_black",3,3,7},
		duration=10,
		rbe=411--15*23+6*11
	}, -- 28
	{
		{"gballoon_gray",2,2},
		{"gballoon_zebra",15,5,2},
		{"gballoon_regen_black",4,2,7},
		{"gballoon_fast_regen_red",9,nil,10},
		duration=10,
		rbe=444--(2+15)*23+4*11+9
	},
	{ -- 30
		{"gballoon_hidden_white",4,4},
		{"gballoon_aqua",15,3,4},
		{"gballoon_purple",8,2,7},
		{"gballoon_fast_hidden_regen_green",nil,10},
		duration=10,
		rbe=480--(4+8)*11+15*23+10*3
	}, -- 30
	{
		{"gballoon_error",2,2},
		{"gballoon_aqua",20,5,2},
		{"gballoon_fast_regen_yellow",3,3,7},
		duration=10,
		rbe=518--(2+20)*23+3*4
	},
	{
		{"gballoon_zebra",20,5},
		{"gballoon_fast_white",9,4.5,5.5},
		duration=10,
		rbe=559--20*23+9*11
	},
	{
		{"gballoon_gray",2,1},
		{"gballoon_black",50,5,1},
		{"gballoon_fast_regen_yellow",2,4,6},
		duration=10,
		rbe=604--2*23+50*11+2*4
	},
	{
		{"gballoon_aqua",25,7.5},
		{"gballoon_regen_orange",5,2.5,6.5},
		{"gballoon_hidden_orange",2,1,9},
		{"gballoon_fast_hidden_regen_red",nil,10},
		duration=10,
		rbe=653--25*23+(5+2)*11+1
	},
	{ -- 35
		{"gballoon_error",2,1},
		{"gballoon_shielded_purple",25,5,1},
		{"gballoon_fast_regen_pink",20,4,6},
		{"gballoon_fast_regen_green",3,nil,10},
		duration=10,
		rbe=705--2*23+25*22+20*5+3*3
	}, -- 35
	{ -- 36
		{"gballoon_rainbow",8,8},
		{"gballoon_fast_red",17,1.7,8.3},
		duration=10,
		rbe=761--8*93+17
	}, -- 36
	{
		{"gballoon_rainbow",8,4},
		{"gballoon_zebra",nil,4.5},
		{"gballoon_hidden_white",5,5,5},
		duration=10,
		rbe=822--8*93+23+5*11
	},
	{
		{"gballoon_ceramic",4,4},
		{"gballoon_regen_black",5,2.5,4},
		{"gballoon_shielded_error",nil,6.5},
		{"gballoon_fast_hidden_regen_green",nil,10},
		duration=10,
		rbe=888--4*196+5*11+46+3
	},
	{
		{"gballoon_shielded_rainbow",5,5},
		{"gballoon_fast_hidden_regen_red",7,3.5,5},
		{"gballoon_fast_hidden_regen_shielded_white",nil,10},
		duration=10,
		rbe=959--5*186+7+22
	},
	{ -- 40
		{"gballoon_blimp_blue"},
		duration=10,
		rbe=984
	}, -- 40
	{
		{"gballoon_regen_zebra",40,8},
		{"gballoon_ceramic",nil,9},
		{"gballoon_fast_hidden_regen_shielded_red",nil,10},
		duration=10,
		rbe=1118--40*23+196+2
	},
	{
		{"gballoon_red",2},
		{"gballoon_blue",2,nil,1},
		{"gballoon_green",2,nil,2},
		{"gballoon_yellow",2,nil,3},
		{"gballoon_pink",3,nil,4},
		{"gballoon_white",2,nil,4.5},
		{"gballoon_black",2,nil,5},
		{"gballoon_purple",2,nil,5.5},
		{"gballoon_orange",3,nil,6},
		{"gballoon_zebra",2,nil,6.5},
		{"gballoon_gray",2,nil,7},
		{"gballoon_aqua",2,nil,7.5},
		{"gballoon_error",3,nil,8},
		{"gballoon_rainbow",3,nil,9},
		{"gballoon_ceramic",3,nil,10},
		duration=10,
		rbe=1208--(1+2+3+4)*2+15+9*11+9*23+3*93+3*196
	},
	{
		{"gballoon_red",33},
		{"gballoon_orange",31,nil,2.5},
		{"gballoon_yellow",31,nil,5},
		{"gballoon_green",31,nil,7.5},
		{"gballoon_aqua",31,nil,10},
		duration=10,
		rbe=1304--33+31*(11+4+3+23)
	},
	{
		{"gballoon_ceramic",7,7},
		{"gballoon_fast_hidden_regen_shielded_white",nil,8},
		{"gballoon_fast_hidden_regen_shielded_pink",nil,9},
		{"gballoon_fast_hidden_regen_pink",nil,10},
		duration=10,
		rbe=1409--7*196+22+10+5
	},
	{ -- 45
		{"gballoon_shielded_gray",30,5},
		{"gballoon_hidden_shielded_purple",5,2,5},
		{"gballoon_fast_hidden_regen_shielded_pink",3,3,7},
		{"gballoon_fast_hidden_regen_red",nil,10},
		duration=10,
		rbe=1521--30*46+5*22+3*10+1
	}, -- 45
	{
		{"gballoon_ceramic",8,8},
		{"gballoon_fast_hidden_regen_pink",15,1.5,8.5},
		duration=10,
		rbe=1643--8*196+15*5
	},
	{
		{"gballoon_shielded_zebra"},
		{"gballoon_shielded_zebra",10,5},
		
		{"gballoon_shielded_white",nil,0.1},
		{"gballoon_shielded_white",nil,0.2},
		{"gballoon_shielded_white",nil,0.3},
		{"gballoon_shielded_white",nil,0.4},
		{"gballoon_shielded_white",4,4,0.1},
		{"gballoon_shielded_white",4,4,0.2},
		{"gballoon_shielded_white",4,4,0.3},
		{"gballoon_shielded_white",4,4,0.4},
		
		{"gballoon_shielded_black",nil,0.6},
		{"gballoon_shielded_black",nil,0.7},
		{"gballoon_shielded_black",nil,0.8},
		{"gballoon_shielded_black",nil,0.9},
		{"gballoon_shielded_black",4,4,0.6},
		{"gballoon_shielded_black",4,4,0.7},
		{"gballoon_shielded_black",4,4,0.8},
		{"gballoon_shielded_black",4,4,0.9},
		
		{"gballoon_regen_rainbow",4,4,5},
		{"gballoon_fast_hidden_regen_red",17,nil,10},
		duration=10,
		rbe=1775--11*46+(5*4*2)*22+4*93+17
	},
	{
		{"gballoon_rainbow",20,10},
		{"gballoon_fast_hidden_regen_shielded_zebra",nil,5},
		{"gballoon_fast_hidden_regen_purple",nil,10},
		duration=10,
		rbe=1917--20*93+46+11
	},
	{
		{"gballoon_blimp_blue"},
		{"gballoon_blimp_blue",nil,3},
		{"gballoon_fast_regen_rainbow",nil,6},
		{"gballoon_fast_hidden_regen_green",3,1,9},
		duration=10,
		rbe=2070--2*984+93+3*3
	},
	{ -- 50
		{"gballoon_ceramic",3,3},
		{"gballoon_brick",3,3,3},
		{"gballoon_rainbow",3,3,6},
		{"gballoon_fast_hidden_regen_shielded_black",4,1,9},
		duration=10,
		rbe=2236--3*(196+427+93)+4*22
	}, -- 50
	{
		{"gballoon_fast_aqua",20,10},
		{"gballoon_rainbow",20,10},
		{"gballoon_rainbow"},
		{"gballoon_fast_hidden_regen_red",nil,10},
		duration=10,
		rbe=2414--20*(93+23)+93+1
	},
	{
		{"gballoon_brick",5,10},
		{"gballoon_fast_regen_shielded_pink",5,10},
		{"gballoon_fast_regen_pink"},
		{"gballoon_fast_regen_shielded_white",5,10},
		{"gballoon_fast_regen_shielded_white"},
		{"gballoon_fast_regen_shielded_red",5,10},
		{"gballoon_fast_regen_shielded_error",5,10},
		{"gballoon_fast_regen_shielded_error"},
		duration=10,
		rbe=2608--5*427+11*5+6*22+10+6*46
	},
	{
		{"gballoon_blimp_blue",2},
		{"gballoon_fast_hidden_regen_shielded_pink",45,9},
		{"gballoon_fast_hidden_regen_shielded_yellow",45,9},
		{"gballoon_fast_hidden_regen_blue",19,nil,10},
		duration=10,
		rbe=2816--2*984+45*(10+8)+19*2
	},
	{
		{"gballoon_blimp_blue",3,6},
		{"gballoon_fast_hidden_regen_shielded_white",4,4,6},
		{"gballoon_fast_hidden_regen_red"},
		duration=10,
		rbe=3041--3*984+4*22+1
	},
	{ -- 55
		{"gballoon_ceramic",15,7.5},
		{"gballoon_hidden_regen_gray",15,2.5,7.5},
		duration=10,
		rbe=3285--15*196+15*23
	}, -- 55
	{
		{"gballoon_shielded_rainbow",19,9.5},
		{"gballoon_fast_hidden_regen_shielded_red",7,nil,10},
		duration=10,
		rbe=3548--38*93+7*2
	},
	{
		{"gballoon_fast_hidden_regen_error"},
		{"gballoon_brick",8,8},
		{"gballoon_shielded_ceramic",2,2,8},
		duration=10,
		rbe=3831--23+8*427+2*196
	},
	{
		{"gballoon_fast_hidden_regen_shielded_rainbow"},
		{"gballoon_blimp_blue",4,8},
		{"gballoon_fast_hidden_regen_shielded_yellow",2,2,8},
		duration=10,
		rbe=4138--2*93+4*984+2*8
	},
	{
		{"gballoon_rainbow",48,9.6},
		{"gballoon_fast_hidden_regen_pink",nil,10},
		duration=10,
		rbe=4469--48*93+5
	},
	{ -- 60
		{"gballoon_blimp_red"},
		duration=10,
		rbe=4636
	}, -- 60
	{
		{"gballoon_brick",12,6},
		{"gballoon_fast_hidden_regen_shielded_white",4,4,6},
		duration=10,
		rbe=5212--12*427+4*22
	},
	{
		{"gballoon_blimp_blue",5,5},
		{"gballoon_fast_ceramic",3,3,5},
		{"gballoon_fast_hidden_regen_rainbow",nil,9},
		{"gballoon_fast_hidden_regen_shielded_blue",7,nil,10},
		duration=10,
		rbe=5629--5*984+196*3+93+7*4
	},
	{
		{"gballoon_regen_ceramic",5},
		{"gballoon_regen_ceramic",5,nil,5},
		{"gballoon_regen_ceramic",20,nil,10},
		{"gballoon_fast_hidden_regen_shielded_pink",20,nil,10},
		duration=10,
		rbe=6080--30*196+200
	},
	{
		{"gballoon_fast_hidden_regen_shielded_yellow",4},
		{"gballoon_fast_regen_purple",14,7},
		{"gballoon_fast_regen_error",14,7},
		{"gballoon_fast_regen_white",14,7},
		{"gballoon_blimp_blue",6,3,7},
		duration=10,
		rbe=6566--4*8+14*(11+23+11)+6*984
	},
	{ -- 65
		{"gballoon_shielded_blimp_blue"},
		{"gballoon_shielded_blimp_blue",2,4},
		{"gballoon_fast_regen_shielded_purple",27,3,7},
		{"gballoon_fast_regen_shielded_white",27,3,7},
		duration=10,
		rbe=7092--3*1968+27*(22+22)
	}, -- 65
	{
		{"gballoon_brick",15,5},
		{"gballoon_orange",48,4,5},
		{"gballoon_yellow",48,4,5},
		{"gballoon_white",48,4,5},
		{"gballoon_fast_hidden_regen_shielded_green",nil,10},
		duration=10,
		rbe=7659--15*427+48*(11+4+11)+6
	},
	{
		{"gballoon_fast_hidden_regen_shielded_error",10,5},
		
		{"gballoon_fast_hidden_regen_shielded_purple",nil,0.1},
		{"gballoon_fast_hidden_regen_shielded_purple",nil,0.2},
		{"gballoon_fast_hidden_regen_shielded_purple",nil,0.3},
		{"gballoon_fast_hidden_regen_shielded_purple",nil,0.4},
		{"gballoon_fast_hidden_regen_shielded_purple",4,4,0.1},
		{"gballoon_fast_hidden_regen_shielded_purple",4,4,0.2},
		{"gballoon_fast_hidden_regen_shielded_purple",4,4,0.3},
		{"gballoon_fast_hidden_regen_shielded_purple",4,4,0.4},
		
		{"gballoon_fast_hidden_regen_shielded_black",nil,0.6},
		{"gballoon_fast_hidden_regen_shielded_black",nil,0.7},
		{"gballoon_fast_hidden_regen_shielded_black",nil,0.8},
		{"gballoon_fast_hidden_regen_shielded_black",nil,0.9},
		{"gballoon_fast_hidden_regen_shielded_black",4,4,0.6},
		{"gballoon_fast_hidden_regen_shielded_black",4,4,0.7},
		{"gballoon_fast_hidden_regen_shielded_black",4,4,0.8},
		{"gballoon_fast_hidden_regen_shielded_black",4,4,0.9},
		
		{"gballoon_blimp_blue",7,3.5,5},
		{"gballoon_fast_hidden_regen_shielded_white",2,2,8},
		duration=10,
		rbe=8272--10*46+(5*4*2)*22+7*984+44
	},
	{
		{"gballoon_fast_hidden_regen_red"},
		{"gballoon_fast_hidden_regen_shielded_pink",2},
		{"gballoon_fast_hidden_regen_shielded_rainbow",2},
		{"gballoon_brick",20,10},
		duration=10,
		rbe=8933--1+2*10+2*186+20*427
	},
	{
		{"gballoon_blimp_red",2,10},
		{"gballoon_hidden_regen_ceramic"},
		{"gballoon_fast_hidden_regen_shielded_pink",18},
		duration=10,
		rbe=9648--2*4636+196+18*10
	},
	{ -- 70
		{"gballoon_marble",10,10},
		{"gballoon_regen_brick"},
		{"gballoon_fast_hidden_regen_ceramic"},
		{"gballoon_fast_hidden_regen_shielded_zebra"},
		{"gballoon_fast_hidden_regen_purple"},
		duration=10,
		rbe=10420--10*974+427+196+46+11
	}, -- 70
	{
		{"gballoon_blimp_blue"},
		{"gballoon_blimp_blue",10,10},
		{"gballoon_regen_brick",nil,5},
		{"gballoon_fast_hidden_regen_shielded_red",nil,10},
		duration=10,
		rbe=11253--11*984+427+2
	},
	{
		{"gballoon_marble",10,10},
		{"gballoon_ceramic",10,10},
		{"gballoon_fast_hidden_regen_shielded_gray",9,9},
		{"gballoon_fast_hidden_regen_shielded_pink",4,8},
		duration=10,
		rbe=12154--10*(974+196)+46*9+4*10
	},
	{
		{"gballoon_fast_hidden_ceramic"},
		{"gballoon_fast_brick",30,10},
		{"gballoon_fast_hidden_regen_shielded_blue",30,10},
		duration=10,
		rbe=13126--30*427+196+30*4
	},
	{
		{"gballoon_blimp_red",3,9},
		{"gballoon_fast_hidden_regen_aqua",10,10},
		{"gballoon_fast_hidden_regen_shielded_red",19,9.5},
		duration=10,
		rbe=14176--3*4636+10*23+19*2
	},
	{ -- 75
		{"gballoon_fast_blimp_blue",10,10},
		{"gballoon_blimp_red",nil,2},
		{"gballoon_regen_shielded_ceramic",2,2,2},
		{"gballoon_fast_hidden_regen_pink",10,5,4},
		duration=10,
		rbe=15310--10*984+4636+2*392+10*5
	}, -- 75
	{
		{"gballoon_marble",16,8},
		{"gballoon_fast_hidden_regen_shielded_error",20,4,6},
		{"gballoon_fast_hidden_regen_orange"},
		{"gballoon_fast_hidden_regen_shielded_pink",2},
		duration=10,
		rbe=16535--16*974+20*46+11+2*10
	},
	{
		{"gballoon_shielded_brick",20,10},
		{"gballoon_fast_hidden_regen_shielded_purple",35,7,3},
		{"gballoon_fast_hidden_regen_shielded_yellow"},
		duration=10,
		rbe=17858--20*854+35*22+8
	},
	{
		{"gballoon_blimp_red",4,8},
		{"gballoon_fast_hidden_regen_shielded_orange",33,9.9,0.1},
		{"gballoon_fast_hidden_regen_shielded_yellow",2},
		duration=10,
		rbe=19286--4*4636+33*22+2*8
	},
	{
		{"gballoon_fast_regen_brick",48,9.6},
		{"gballoon_fast_hidden_regen_ceramic",nil,10},
		{"gballoon_fast_hidden_regen_rainbow",nil,10},
		{"gballoon_fast_hidden_regen_shielded_orange",2,nil,10},
		duration=10,
		rbe=20829--48*427+196+93+2*22
	},
	{ -- 80
		{"gballoon_blimp_green"},
		duration=10,
		rbe=22544
	}, -- 80
	{
		{"gballoon_blimp_red",5,10},
		{"gballoon_fast_regen_shielded_rainbow",5,10},
		{"gballoon_fast_hidden_regen_shielded_zebra",8},
		{"gballoon_fast_hidden_regen_red"},
		duration=10,
		rbe=24295--5*4636+5*186+4*46+1
	},
	{
		{"gballoon_fast_shielded_blimp_blue",3},
		{"gballoon_shielded_blimp_blue",10,10},
		{"gballoon_fast_hidden_regen_shielded_gray",14,1.4,2.6},
		{"gballoon_fast_hidden_regen_orange"},
		duration=10,
		rbe=26239--13*1968+14*46+11
	},
	{
		{"gballoon_hidden_marble",29,8.7},
		{"gballoon_fast_hidden_regen_shielded_aqua",2,nil,10},
		duration=10,
		rbe=28338--29*974+2*46
	},
	{
		{"gballoon_regen_shielded_brick",35,7},
		{"gballoon_fast_hidden_regen_shielded_error",15,3,7},
		{"gballoon_fast_hidden_regen_pink",5,10},
		duration=10,
		rbe=30605--35*854+15*46+5*5
	},
	{ -- 85
		{"gballoon_blimp_green"},
		{"gballoon_shielded_blimp_red",nil,2},
		{"gballoon_fast_blimp_blue",nil,4},
		{"gballoon_fast_hidden_regen_ceramic",nil,6},
		{"gballoon_fast_hidden_regen_shielded_zebra",nil,8},
		{"gballoon_fast_hidden_regen_purple",nil,10},
		duration=10,
		rbe=33053--22544+9272+984+196+46+11
	}, -- 85
	{
		{"gballoon_fast_blimp_red",7,7},
		{"gballoon_fast_hidden_regen_marble",3,3,7},
		{"gballoon_fast_hidden_regen_rainbow",3,3,7},
		{"gballoon_fast_hidden_regen_shielded_white",2,2,7},
		{"gballoon_fast_hidden_regen_red",nil,10},
		duration=10,
		rbe=35698--7*4636+3*974+3*93+2*22+1
	},
	{
		{"gballoon_regen_marble",25,5},
		{"gballoon_fast_regen_brick",25,5},
		{"gballoon_fast_hidden_regen_rainbow",25,5,5},
		{"gballoon_fast_hidden_regen_shielded_gray",25,5,5},
		{"gballoon_fast_hidden_regen_shielded_red",25,5,5},
		{"gballoon_fast_hidden_regen_red",3},
		duration=10,
		rbe=38553--25*(974+427+93+46+2)+3
	},
	{
		{"gballoon_hidden_shielded_brick",48,9.6,0.4},
		{"gballoon_fast_hidden_regen_shielded_aqua",14,7,3},
		{"gballoon_fast_hidden_regen_shielded_red"},
		duration=10,
		rbe=41638--48*854+14*46+2
	},
	{
		{"gballoon_fast_blimp_blue",45,9},
		{"gballoon_fast_hidden_regen_brick",nil,10},
		{"gballoon_fast_hidden_regen_ceramic",nil,10},
		{"gballoon_fast_hidden_regen_shielded_orange",3,nil,10},
		duration=10,
		rbe=44969--45*984+427+196+3*22
	},
	{ -- 90
		{"gballoon_fast_hidden_regen_shielded_marble",3},
		{"gballoon_fast_hidden_regen_shielded_rainbow",3},
		{"gballoon_fast_hidden_regen_shielded_blue"},
		{"gballoon_fast_hidden_marble",8,4,2},
		{"gballoon_hidden_regen_blimp_gray",8,4,6},
		duration=10,
		rbe=48566--3*(1948+186)+8*(974+4296)+4
	}, -- 90
	{
		{"gballoon_blimp_green",2,4,6},
		{"gballoon_blimp_red",nil,6},
		{"gballoon_fast_shielded_blimp_blue",nil,3},
		{"gballoon_fast_hidden_regen_shielded_ceramic"},
		{"gballoon_fast_hidden_regen_shielded_rainbow"},
		{"gballoon_fast_hidden_regen_shielded_error",3},
		{"gballoon_fast_hidden_regen_shielded_purple"},
		{"gballoon_fast_hidden_regen_shielded_pink",2},
		{"gballoon_fast_hidden_regen_red",2},
		duration=10,
		rbe=52451--2*22544+4636+1968+392+186+3*46+22+2*10+1
	},
	{
		{"gballoon_shielded_blimp_red",6,6},
		{"gballoon_fast_blimp_blue"},
		{"gballoon_fast_hidden_regen_shielded_yellow",4,4,6},
		duration=10,
		rbe=56648--6*9272+984+4*8
	},
	{
		{"gballoon_hidden_regen_blimp_gray",14,7},
		{"gballoon_fast_blimp_blue"},
		{"gballoon_fast_hidden_regen_shielded_zebra"},
		{"gballoon_fast_hidden_regen_pink"},
		duration=10,
		rbe=61179--14*4296+984+46+5
	},
	{
		{"gballoon_fast_shielded_blimp_blue",33,9.9,0.1},
		{"gballoon_fast_hidden_regen_shielded_gray",24,9.6,0.4},
		{"gballoon_fast_hidden_regen_shielded_red",13,6.5,3.5},
		duration=10,
		rbe=66074--33*1968+24*46+13*2
	},
	{ -- 95
		{"gballoon_blimp_green"},
		{"gballoon_hidden_regen_blimp_gray",10,10},
		{"gballoon_fast_hidden_regen_brick",10,10},
		{"gballoon_fast_hidden_regen_shielded_aqua",30,10},
		{"gballoon_fast_hidden_regen_shielded_pink",20,10},
		{"gballoon_fast_hidden_regen_shielded_red",3},
		duration=10,
		rbe=71360--22544+10*(4296+427)+30*46+20*10+3*2
	}, -- 95
	{
		{"gballoon_blimp_green",3,9,1},
		{"gballoon_fast_shielded_blimp_red"},
		{"gballoon_fast_hidden_regen_shielded_error",3},
		{"gballoon_fast_hidden_regen_shielded_white"},
		{"gballoon_fast_hidden_regen_shielded_blue"},
		duration=10,
		rbe=77068--3*22544+9272+3*46+22+4
	},
	{
		{"gballoon_hidden_regen_blimp_gray",19,9.5,0.5},
		{"gballoon_fast_hidden_regen_shielded_ceramic",4},
		{"gballoon_fast_hidden_regen_shielded_red",21},
		duration=10,
		rbe=83234--19*4296+4*392+21*2
	},
	{
		{"gballoon_fast_hidden_regen_shielded_marble",46,9.2,0.8},
		{"gballoon_fast_hidden_regen_rainbow",3},
		{"gballoon_fast_hidden_regen_green"},
		duration=10,
		rbe=89893--46*1948+3*93+6
	},
	{
		{"gballoon_blimp_green",4,8,2},
		{"gballoon_fast_hidden_regen_rainbow",74,7.4},
		{"gballoon_fast_hidden_regen_shielded_red",13},
		duration=10,
		rbe=97084--4*22544+74*93+13*2
	},
	{ -- 100
		{"gballoon_blimp_purple"},
		duration=10,
		rbe=73680
	}, -- 100
	{
		{"gballoon_hidden_regen_shielded_blimp_gray",13,6.5},
		{"gballoon_fast_hidden_regen_shielded_rainbow",8,8,2},
		{"gballoon_fast_hidden_regen_black",5},
		duration=10,
		rbe=113239--13*8592+8*186+5*11
	},
	{
		{"gballoon_blimp_green",5,10},
		{"gballoon_fast_shielded_blimp_red"},
		{"gballoon_fast_hidden_regen_rainbow",3},
		{"gballoon_fast_hidden_regen_green",9},
		duration=10,
		rbe=122298--5*22544+9272+3*93+9*3
	},
	{
		{"gballoon_hidden_regen_blimp_gray",30,10},
		{"gballoon_fast_hidden_regen_shielded_ceramic",8,8,2},
		{"gballoon_fast_hidden_regen_shielded_orange",3},
		duration=10,
		rbe=132082--30*4296+8*392+3*22
	},
	{
		{"gballoon_fast_shielded_blimp_red",14,7},
		{"gballoon_fast_shielded_blimp_blue",6,6,4},
		{"gballoon_fast_hidden_regen_shielded_zebra",22},
		{"gballoon_fast_hidden_regen_shielded_pink",2},
		duration=10,
		rbe=142648--14*9272+6*1968+22*46+2*10
	},
	{ -- 105
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",16,8},
		{"gballoon_fast_hidden_regen_shielded_brick",18,9,1},
		{"gballoon_fast_hidden_regen_shielded_gray",26},
		{"gballoon_fast_hidden_regen_shielded_pink",2},
		duration=10,
		rbe=154060--16*8592+18*854+26*46+2*10
	}, -- 105
	{
		{"gballoon_fast_blimp_green",7,7},
		{"gballoon_fast_hidden_regen_shielded_brick",10,10},
		{"gballoon_fast_hidden_regen_purple",3},
		{"gballoon_fast_hidden_regen_shielded_blue"},
		duration=10,
		rbe=166385--7*22544+10*854+33+4
	},
	{
		{"gballoon_hidden_regen_shielded_blimp_gray",20,10},
		{"gballoon_fast_hidden_regen_shielded_ceramic",20,10},
		{"gballoon_fast_hidden_regen_shielded_yellow",2},
		duration=10,
		rbe=179696--20*8592+20*392+2*8
	},
	{
		{"gballoon_fast_shielded_blimp_red",20,10},
		{"gballoon_fast_hidden_regen_shielded_brick",10,10},
		{"gballoon_fast_hidden_regen_shielded_pink",9},
		{"gballoon_fast_hidden_regen_red"},
		duration=10,
		rbe=194071--20*9272+10*854+9*10+1
	},
	{
		{"gballoon_fast_hidden_regen_shielded_marble",60,10},
		{"gballoon_shielded_blimp_green",2,8},
		{"gballoon_fast_shielded_blimp_blue"},
		{"gballoon_fast_hidden_regen_shielded_ceramic"},
		{"gballoon_fast_hidden_regen_shielded_aqua",3},
		{"gballoon_fast_hidden_regen_shielded_purple"},
		{"gballoon_fast_hidden_regen_shielded_red",10},
		{"gballoon_fast_hidden_regen_red"},
		duration=10,
		rbe=209597--60*1948+2*45088+1968+392+3*46+22+10*2+1
	},
	{ -- 110
		{"gballoon_blimp_magenta",10,10},
		{"gballoon_fast_shielded_blimp_blue",20,10},
		{"gballoon_fast_hidden_regen_pink",3},
		duration=10,
		rbe=226365--10*18699+20*1968+3*5
	}, -- 110
	{
		{"gballoon_fast_shielded_blimp_green",5,10},
		{"gballoon_fast_hidden_regen_shielded_brick",20,10},
		{"gballoon_fast_hidden_regen_rainbow",21},
		{"gballoon_fast_hidden_regen_red"},
		duration=10,
		rbe=244474--5*45088+20*854+21*93+1
	},
	{
		{"gballoon_blimp_purple",3,9,1},
		{"gballoon_blimp_magenta",2,10},
		{"gballoon_fast_hidden_regen_shielded_ceramic",14},
		{"gballoon_fast_hidden_regen_rainbow"},
		{"gballoon_fast_hidden_regen_red",13},
		duration=10,
		rbe=264032--3*73680+2*18699+14*392+93+13
	},
	{
		{"gballoon_fast_shielded_blimp_red",30,10},
		{"gballoon_fast_hidden_regen_shielded_rainbow",35,7},
		{"gballoon_fast_hidden_regen_shielded_white",22},
		duration=10,
		rbe=285154--30*9272+35*186+22*22
	},
	{
		{"gballoon_blimp_purple",4,8,2},
		{"gballoon_fast_hidden_regen_shielded_brick",15,5,5},
		{"gballoon_fast_hidden_regen_brick",nil,10},
		{"gballoon_fast_hidden_regen_shielded_pink",nil,10},
		duration=10,
		rbe=307967--4*73680+15*854+427+10
	},
	{ -- 115
		{"gballoon_fast_blimp_magenta",16,8,2},
		{"gballoon_fast_blimp_green"},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray"},
		{"gballoon_fast_shielded_blimp_blue"},
		{"gballoon_fast_hidden_regen_shielded_pink",30,nil,10},
		{"gballoon_fast_hidden_regen_shielded_yellow",2,nil,10},
		duration=10,
		rbe=332604--16*18699+22544+8592+1968+30*10+2*8
	}, -- 115
	{
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_shielded_blimp_blue",9,10},
		{"gballoon_fast_blimp_red"},
		{"gballoon_fast_hidden_regen_shielded_aqua",7},
		{"gballoon_fast_hidden_regen_shielded_red",7},
		duration=10,
		rbe=359212--180*1968+4636+7*46+7*2
	},
	{
		{"gballoon_fast_shielded_blimp_green",8,4},
		{"gballoon_fast_blimp_magenta"},
		{"gballoon_fast_shielded_blimp_blue",4,4,6},
		{"gballoon_fast_hidden_regen_shielded_black",30,5},
		{"gballoon_fast_hidden_regen_shielded_red",7},
		duration=10,
		rbe=387949--8*45088+18699+4*1968+30*22+2*7
	},
	{
		{"gballoon_fast_shielded_blimp_magenta",11,5.5,4.5},
		{"gballoon_fast_hidden_regen_shielded_rainbow",40,8},
		{"gballoon_fast_hidden_regen_shielded_pink",16},
		{"gballoon_fast_hidden_regen_red",7},
		duration=10,
		rbe=418985--11*37398+40*186+16*10+7
	},
	{
		{"gballoon_fast_shielded_blimp_purple",3},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",nil,10},
		{"gballoon_fast_hidden_regen_shielded_brick",2,nil,10},
		{"gballoon_fast_hidden_regen_shielded_pink",12,nil,10},
		{"gballoon_fast_hidden_regen_shielded_blue",nil,10},
		duration=10,
		rbe=452504--3*147360+8592+2*854+12*10+4
	},
	{ -- 120
		{"gballoon_blimp_rainbow"},
		duration=10,
		assumerbe=488704,
		rbe=284772
	}, -- 120
}

ROTGB_WAVES[666] = {
	{"gballoon_pink",512,64},
	{"gballoon_fast_white",128,64,64},
	{"gballoon_hidden_black",128,64,64},
	{"gballoon_regen_purple",128,64,64},
	{"gballoon_shielded_orange",128,64,64},
	{"gballoon_fast_hidden_zebra",128,64,128},
	{"gballoon_hidden_regen_gray",128,64,128},
	{"gballoon_regen_shielded_aqua",128,64,128},
	{"gballoon_fast_shielded_error",128,64,128},
	{"gballoon_fast_regen_rainbow",256,64,192},
	{"gballoon_hidden_shielded_rainbow",256,64,192},
	{"gballoon_mossman_super",nil,nil,256},
	{"gballoon_fast_hidden_regen_ceramic",128,64,256},
	{"gballoon_hidden_regen_shielded_ceramic",128,64,256},
	{"gballoon_fast_regen_shielded_ceramic",128,64,256},
	{"gballoon_fast_hidden_shielded_ceramic",128,64,256},
	{"gballoon_fast_regen_shielded_blimp_blue",512,64,320},
	{"gballoon_gman_super",nil,nil,384},
	{"gballoon_fast_hidden_regen_shielded_brick",512,64,384},
	{"gballoon_fast_hidden_regen_shielded_blimp_red",512,64,448},
	{"gballoon_blimp_ggos_super",nil,nil,512},
	{"gballoon_fast_hidden_regen_shielded_marble",512,64,512},
	{"gballoon_fast_hidden_regen_shielded_blimp_green",512,64,576},
	{"gballoon_hot_air_super",nil,nil,640},
	{"gballoon_fast_hidden_regen_shielded_blimp_gray",512,64,640},
	{"gballoon_fast_hidden_regen_shielded_blimp_purple",512,64,704},
	{"gballoon_blimp_long_rainbow_super",nil,nil,768},
	{"gballoon_fast_hidden_regen_shielded_blimp_magenta",512,64,768},
	{"gballoon_fast_hidden_regen_shielded_blimp_rainbow",512,64,832},
	{"gballoon_garrydecal",nil,nil,896},
	{"gballoon_void",16,64,896},
	{"gballoon_glass",16,64,960},
	{"gballoon_cfiber",nil,nil,960},
	
	duration=1024,
	rbe=128*(
		5*4
		+11+11+11+11*2
		+23+23+23*2+24*2
		+94*2+94*2*2
		+198+198*2*3
		+992*2*4
		+431*2*4
		+4668*2*4
		+982*2*4
		+22672*2*4
		+4328*2*4
		+74000*2*4
		+18827*2*4
		+285668*2*4
	)+100000+500000+2007856+10000000+50e6+30+10e6+16+16+999999999
}

ROTGB_WAVES_2S = {}
ROTGB_WAVES_BOSSES = {}
ROTGB_WAVES_BOSSES_SUPER = {}
ROTGB_WAVES_LEGACY_10S = {}
ROTGB_WAVES_CARBON_FIBER = {}

for k,v in pairs(ROTGB_WAVES) do
	ROTGB_WAVES_CARBON_FIBER[k] = v
	
	local waveTable2S = {}
	for k2,v2 in pairs(v) do
		if k2 == "duration" then
			waveTable2S.duration = 2
		else
			waveTable2S[k2] = v2
		end
	end
	ROTGB_WAVES_2S[k] = waveTable2S
	
	if k == 20 then
		ROTGB_WAVES_BOSSES[k] = {
			{"gballoon_melon"},
			rbe = 1000,
			duration = 10
		}
		ROTGB_WAVES_BOSSES_SUPER[k] = {
			{"gballoon_melon_super"},
			rbe = 20000,
			duration = 10
		}
	elseif k == 40 then
		ROTGB_WAVES_BOSSES[k] = {
			{"gballoon_mossman"},
			rbe = 8920,
			duration = 10
		}
		ROTGB_WAVES_BOSSES_SUPER[k] = {
			{"gballoon_mossman_super"},
			rbe = 117640,
			duration = 10
		}
	elseif k == 60 then
		ROTGB_WAVES_BOSSES[k] = {
			{"gballoon_gman"},
			rbe = 25000,
			duration = 10
		}
		ROTGB_WAVES_BOSSES_SUPER[k] = {
			{"gballoon_gman_super"},
			rbe = 500000,
			duration = 10
		}
	elseif k == 80 then
		ROTGB_WAVES_BOSSES[k] = {
			{"gballoon_blimp_ggos"},
			rbe = 103896,
			duration = 10
		}
		ROTGB_WAVES_BOSSES_SUPER[k] = {
			{"gballoon_blimp_ggos_super"},
			rbe = 2007792,
			duration = 10
		}
	elseif k == 100 then
		ROTGB_WAVES_BOSSES[k] = {
			{"gballoon_hot_air"},
			rbe = 500000,
			duration = 10
		}
		ROTGB_WAVES_BOSSES_SUPER[k] = {
			{"gballoon_hot_air_super"},
			rbe = 10000000,
			duration = 10
		}
	elseif k == 120 then
		ROTGB_WAVES_BOSSES[k] = {
			{"gballoon_blimp_long_rainbow"},
			rbe = 4778176,
			assumerbe=452504,
			duration = 10
		}
		ROTGB_WAVES_BOSSES_SUPER[k] = {
			{"gballoon_blimp_long_rainbow_super"},
			rbe = 54556352,
			assumerbe=452504,
			duration = 10
		}
	else
		ROTGB_WAVES_BOSSES[k] = v
		ROTGB_WAVES_BOSSES_SUPER[k] = v
	end
end

for k,v in pairs(ROTGB_WAVES_LEGACY) do
	local waveTable10S = {}
	for k2,v2 in pairs(v) do
		if k2 == "duration" then
			waveTable10S.duration = 10
		else
			waveTable10S[k2] = v2
		end
	end
	ROTGB_WAVES_LEGACY_10S[k] = waveTable10S
end

ROTGB_WAVES_BOSSES[140] = {
	{"gballoon_garrydecal"},
	rbe = 10e6,
	assumerbe=2109101,
	duration=10
}
ROTGB_WAVES_BOSSES_SUPER[140] = {
	{"gballoon_garrydecal_super"},
	rbe = 200e6,
	assumerbe=2109101,
	duration=10
}
ROTGB_WAVES_CARBON_FIBER[140] = {
	{"gballoon_cfiber"},
	rbe = 999999999,
	assumerbe=2109101,
	duration=10
}

ROTGB_CUSTOM_WAVES = {
	["?RAMP"]=ROTGB_WAVES_RAMP, ["?LEGACY"]=ROTGB_WAVES_LEGACY, ["?LEGACY_10S"]=ROTGB_WAVES_LEGACY_10S, ["?2S"]=ROTGB_WAVES_2S,
	["?BOSSES"]=ROTGB_WAVES_BOSSES, ["?BOSSES_SUPER"]=ROTGB_WAVES_BOSSES_SUPER, ["?CARBON_FIBER"]=ROTGB_WAVES_CARBON_FIBER
}

function ENT:GetWaveDuration(wave)
	return (self:GetWaveTable()[wave] or {}).duration or 0
end

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Wave", {KeyName="start_wave", Edit={title="#rotgb.gballoon_spawner.properties.start_wave", type="Int", min=1, max=200, order=1}})
	self:NetworkVar("Int", 1, "SpawnDivider", {KeyName="spawn_divider", Edit={title="#rotgb.gballoon_spawner.properties.spawn_divider", type="Int", min=1, max=100, order=5}})
	self:NetworkVar("Int", 2, "DividerDelay", {KeyName="divider_delay", Edit={title="#rotgb.gballoon_spawner.properties.divider_delay", type="Int", min=0, max=100, order=6}})
	self:NetworkVar("Int", 3, "LastWave", {KeyName="end_wave", Edit={title="#rotgb.gballoon_spawner.properties.end_wave", type="Int", min=1, max=200, order=2}})
	self:NetworkVar("Bool", 0, "AutoStartInternal", {KeyName="auto_start", Edit={title="#rotgb.gballoon_spawner.properties.auto_start", type="Boolean", order=7}})
	self:NetworkVar("Bool", 1, "ForceNextWave", {KeyName="force_next", Edit={title="#rotgb.gballoon_spawner.properties.force_next", type="Boolean", order=9}})
	self:NetworkVar("Bool", 2, "StartAll", {KeyName="start_all", Edit={title="#rotgb.gballoon_spawner.properties.start_all", type="Boolean", order=10}})
	self:NetworkVar("Bool", 3, "UnSpectatable")
	self:NetworkVar("Bool", 4, "HideWave", {KeyName="hide_wave", Edit={title="#rotgb.gballoon_spawner.properties.hide_wave", type="Boolean", order=12}})
	self:NetworkVar("Bool", 5, "AllowMultiStart", {KeyName="allow_multi_start", Edit={title="#rotgb.gballoon_spawner.properties.allow_multi_start", type="Boolean", order=3}})
	self:NetworkVar("Float", 0, "AutoStartDelay", {KeyName="auto_start_delay", Edit={title="#rotgb.gballoon_spawner.properties.auto_start_delay", type="Float", min=0, max=60, order=8}})
	self:NetworkVar("Float", 1, "SpeedMul", {KeyName="spawn_rate_mul", Edit={title="#rotgb.gballoon_spawner.properties.spawn_rate_mul", type="Float", min=0.1, max=10, order=4}})
	self:NetworkVar("Float", 2, "NextWaveTime")
	self:NetworkVar("String", 0, "WaveFile", {KeyName="wave_preset", Edit={title="#rotgb.gballoon_spawner.properties.wave_preset", type="Generic", order=11}})
	self:NetworkVar("String", 1, "MusicString", {KeyName="music_string", Edit={title="#rotgb.gballoon_spawner.properties.music_string", type="Generic", order=13}})
	return gballoon_pob.SetupDataTables(self)
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
	elseif lkey=="no_multi_start" then
		self:SetAllowMultiStart(not tobool(value))
	elseif lkey=="finished_shortly_threshold" then
		self.OutputShortlyThreshold = value
	elseif lkey=="dont_trigger_wave_relays" then
		self.DontTriggerWaveRelays = value
	elseif lkey=="no_messages" then
		self.NoMessages = tobool(value)
	elseif string.match(lkey, "^music_%d+$") then
		local num = tonumber(string.match(lkey, "^music_(%d+)$"))
		if value ~= "" and num then
			self:GetSingleMusicData(num).file = value
			self.MusicRequiresResync = true
		end
	elseif string.match(lkey, "^music_%d+_wave$") then
		local num = tonumber(string.match(lkey, "^music_(%d+)_wave$"))
		if num then
			self:GetSingleMusicData(num).wave = tonumber(value) or 0
			self.MusicRequiresResync = true
		end
	elseif string.match(lkey, "^music_%d+_text_%d+$") then
		local num, line = string.match(lkey, "^music_(%d+)_text_(%d+)$")
		num = tonumber(num)
		line = tonumber(line)
		if value ~= "" and num and line then
			data = self:GetSingleMusicData(num)
			data.texts = data.texts or {}
			data.texts[line] = value
			self.MusicRequiresResync = true
		end
	elseif string.match(lkey, "^music_file_%d+$") then
		if value ~= "" then
			local num = (tonumber(string.match(lkey, "^music_file_(%d+)$")) or 0) + 1
			self:GetSingleMusicData(num).file = value
		end
		self.MusicRequiresResync = true
		
		local name = self:GetName() ~= "" and self:GetName() or self:GetClass()
		ROTGB_LogError("DEPRECATION WARNING: The map tried to use music_file_* KeyValues on \""..name.."\", which are now deprecated. Please use music_* instead.", "")
		debug.Trace()
	elseif string.match(lkey, "^music_wave_%d+$") then
		local num = (tonumber(string.match(lkey, "^music_wave_(%d+)$")) or 0) + 1
		self:GetSingleMusicData(num).wave = tonumber(value) or 0
		self.MusicRequiresResync = true
		
		local name = self:GetName() ~= "" and self:GetName() or self:GetClass()
		ROTGB_LogError("DEPRECATION WARNING: The map tried to use music_wave_* KeyValues on \""..name.."\", which are now deprecated. Please use music_*_wave instead.", "")
		debug.Trace()
	elseif string.match(lkey, "^music_text_%d+_%d+$") then
		if value ~= "" then
			local num, line = string.match(lkey, "^music_text_(%d+)_(%d+)$")
			num = (tonumber(num) or 0) + 1
			line = (tonumber(line) or 0) + 1
			
			data = self:GetSingleMusicData(num)
			data.texts = data.texts or {}
			data.texts[line] = value
		end
		self.MusicRequiresResync = true
		
		local name = self:GetName() ~= "" and self:GetName() or self:GetClass()
		ROTGB_LogError("DEPRECATION WARNING: The map tried to use music_text_*_* KeyValues on \""..name.."\", which are now deprecated. Please use music_*_text_* instead.", "")
		debug.Trace()
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
	elseif input=="setspawnratemultiplier" then
		self:SetSpeedMul(tonumber(data) or 1)
	elseif input=="setspawndivider" then
		self:SetSpawnDivider(tonumber(data) or 1)
	elseif input=="setdividerdelay" then
		self:SetDividerDelay(tonumber(data) or 1)
	elseif input=="setautostartdelay" then
		self:SetAutoStartDelay(tonumber(data) or 0)
	elseif input=="setshortnessthreshold" then
		self.OutputShortlyThreshold = tonumber(data) or 0
	elseif input=="enablenomessages" then
		self.NoMessages = true
	elseif input=="disablenomessages" then
		self.NoMessages = false
	elseif input=="togglenomessages" then
		self.NoMessages = not self.NoMessages
	elseif input=="enablemusic" then
		for k,v in pairs(self.MusicData or {}) do
			v.disabled = false
		end
		self.MusicRequiresResync = true
	elseif input=="disablemusic" then
		for k,v in pairs(self.MusicData or {}) do
			v.disabled = true
		end
		self.MusicRequiresResync = true
	elseif input=="togglemusic" then
		for k,v in pairs(self.MusicData or {}) do
			v.disabled = not v.disabled
		end
		self.MusicRequiresResync = true
	elseif string.match(input, "^setmusic%d+wave$") then
		local num = (tonumber(string.match(input, "^setmusic(%d+)wave$")) or 1)
		self:GetSingleMusicData(num).wave = tonumber(data) or -1
		self.MusicRequiresResync = true
	elseif string.match(input, "^enablemusic%d+$") then
		local num = (tonumber(string.match(input, "^enablemusic(%d+)$")) or 1)
		data = self:GetSingleMusicData(num)
		data.disabled = false
		self.MusicRequiresResync = true
	elseif string.match(input, "^disablemusic%d+$") then
		local num = (tonumber(string.match(input, "^disablemusic(%d+)$")) or 1)
		data = self:GetSingleMusicData(num)
		data.disabled = true
		self.MusicRequiresResync = true
	elseif string.match(input, "^togglemusic%d+$") then
		local num = (tonumber(string.match(input, "^togglemusic(%d+)$")) or 1)
		data = self:GetSingleMusicData(num)
		data.disabled = not data.disabled
		self.MusicRequiresResync = true
	end
	self:CheckBoolEDTInput(input, "hidewave", "HideWave")
	self:CheckBoolEDTInput(input, "startall", "StartAll")
	self:CheckBoolEDTInput(input, "autostart", "AutoStart")
	self:CheckBoolEDTInput(input, "allowmultistart", "AllowMultiStart")
	return gballoon_pob.AcceptInput(self,input,activator,caller,data)
end

function ENT:GetSingleMusicData(index)
	self.MusicData = self.MusicData or {}
	self.MusicData[index] = self.MusicData[index] or {}
	return self.MusicData[index]
end

function ENT:SyncEntity(ply)
	net.Start("rotgb_generic")
	net.WriteUInt(ROTGB_OPERATION_SYNCENTITY, 8)
	net.WriteEntity(self)
	
	-- Already updated?
	if ply and self.rotgb_SyncedPlayers[ply] then
		net.WriteInt(-1,16)
	else
		self.MusicData = self.MusicData or {}
		net.WriteInt(table.Count(self.MusicData),16)
		for k,v in pairs(self.MusicData) do
			net.WriteInt(v.wave or -1, 32)
			net.WriteString(not v.disabled and v.file or "")
			
			local textAmount = not v.disabled and v.texts and table.maxn(v.texts) or 0
			net.WriteUInt(textAmount, 8)
			for i=1,textAmount do
				net.WriteString(v.texts[i] or "")
			end
		end
		if ply then
			self.rotgb_SyncedPlayers[ply] = true
		else
			self.rotgb_SyncedPlayers = {}
		end
	end
	
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
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

--local notifshown

function ENT:Initialize()
	if SERVER then
		--[[if not (navmesh.IsLoaded() or notifshown) and game.SinglePlayer() then
			ROTGB_CauseNotification(ROTGB_NOTIFY_NAVMESHMISSING, ROTGB_NOTIFYTYPE_ERROR)
			notifshown = true
		end]]
		self.OutputShortlyThreshold = tonumber(self.OutputShortlyThreshold) or 7.5
		if self:GetWave()<=0 then
			self:SetWave(ROTGB_GetConVarValue("rotgb_default_first_wave"))
		end
		if self:GetLastWave()<=0 then
			self:SetLastWave(ROTGB_GetConVarValue("rotgb_default_last_wave"))
		end
		
		if ROTGB_GetConVarValue("rotgb_spawner_force_auto_start") >= 0 then
			self:SetForceNextWave(tobool(ROTGB_GetConVarValue("rotgb_spawner_force_auto_start")))
		end
		
		if ROTGB_GetConVarValue("rotgb_spawner_no_multi_start") >= 0 then
			self:SetAllowMultiStart(not tobool(ROTGB_GetConVarValue("rotgb_spawner_no_multi_start")))
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
		if self.MusicData then
			local assembledStrings = {}
			for k,v in pairs(self.MusicData) do
				if v.wave then
					if v.file then
						table.insert(assembledStrings, string.format(
							"%u,%s", v.wave or 0, v.file
						))
					else
						table.insert(assembledStrings, string.format(
							"%u", v.wave or 0
						))
					end
				end
			end
			self:SetMusicString(table.concat(assembledStrings, ";"))
			self.OldMusicString = self:GetMusicString()
		end
		self.rotgb_SyncedPlayers = {}
		gballoon_pob.Initialize(self)
	end
	if CLIENT then
		self.CurrentMusic = -1
		self.NewMusic = -1
		net.Start("rotgb_generic")
		net.WriteUInt(ROTGB_OPERATION_SYNCENTITY, 8)
		net.WriteEntity(self)
		net.SendToServer()
		
		if self:GetNWString("rotgb_validwave","") == "" and self:GetWave() == 1 and not self.waveZeroMessaged and IsValid(LocalPlayer()) and not ROTGB_GetConVarValue("rotgb_no_wave_hints") then
			self.waveZeroMessaged = true
			ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb.wave_hints.0"), ROTGB_NOTIFYTYPE_CHAT, nil, {holdtime=10})
		end
	end
end

function ENT:PreEntityCopy(...)
	self.rotgb_DuplicatorTimeOffset = CurTime()
	self.rotgb_CopiedToSpawn = table.Copy(self.rotgb_ToSpawn)
	gballoon_pob.PreEntityCopy(self,...)
end

function ENT:PostEntityPaste(ply,ent,tab)
	self.rotgb_ToSpawn = self.rotgb_CopiedToSpawn
	self:AddTimePhase(CurTime() - (self.rotgb_DuplicatorTimeOffset or CurTime()))
	gballoon_pob.PostEntityPaste(self,ply,ent,tab)
end

function ENT:AddTimePhase(timeToAdd)
	self:SetNextWaveTime(self:GetNextWaveTime()+timeToAdd)
	self.LastTimePushed = (self.LastTimePushed or 0) + timeToAdd
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
		if self.EnableBalloonChecking then
			if cwave == self:GetLastWave() + 1 then return
			elseif not self:GetAllowMultiStart() then
				if activator:IsPlayer() then
					ROTGB_CauseNotification(ROTGB_NOTIFY_NOMULTISTART, ROTGB_NOTIFYTYPE_ERROR, activator)
				end
				return
			end
		end
		if ((IsValid(activator) and activator:GetClass()~="gballoon_spawner" or activator == self) and self:GetStartAll() and not self.LoopPrevent) then
			self.LoopPrevent = true
			for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
				if v ~= self and v:GetWave() == cwave then
					v:Use(self,self,USE_ON,1)
				end
			end
			self.LoopPrevent = false
		end
		if self:TriggerWaveEnded() then return self:Remove() end
		
		self.rotgb_ReadyPlayers = {}
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
		
		self:SetNextWaveTime(CurTime()+self:GetWaveDuration(cwave)/self:GetSpeedMul()/ROTGB_GetConVarValue("rotgb_spawner_spawn_rate"))
		hook.Run("gBalloonSpawnerWaveStarted",self,cwave)
		self:TriggerOutput("OnWaveStart",activator,cwave)
		self:SpawnWave(cwave)
		self.EnableBalloonChecking = true
		self:SetWave(cwave+1)
	--end
end

function ENT:AddReadyPlayer(ply)
	if self.EnableBalloonChecking then
		-- we're in the middle of a wave...
		if cwave == self:GetLastWave() + 1 then return
		elseif not self:GetAllowMultiStart() then
			return ROTGB_CauseNotification(ROTGB_NOTIFY_NOMULTISTART, ROTGB_NOTIFYTYPE_ERROR, ply)
		end
	end
	
	self.rotgb_ReadyPlayers = self.rotgb_ReadyPlayers or {}
	self.rotgb_ReadyPlayers[ply] = true
	
	local readyCount = 0
	for k, v in pairs(self.rotgb_ReadyPlayers) do
		if not IsValid(k) then
			self.rotgb_ReadyPlayers[k] = nil
		else
			readyCount = readyCount + 1
		end
	end
	
	if not self.NoMessages then
		ROTGB_CauseNotification(ROTGB_NOTIFY_PLAYERREADY, ROTGB_NOTIFYTYPE_CHAT, nil, 
			{"e", ply, "u8", readyCount, color = Color(0, 255, 0)}
		)
	end
	
	if readyCount*2 >= ROTGB_GetActivePlayerCount() then
		self:Use(self,self,USE_ON,1)
	end
end

function ENT:SpawnWave(cwave)
	local curTime = CurTime()
	local totalAmount, tablesToInsert = 0, {}
	for k,v in pairs(self:GetWaveTable()[cwave] or {}) do
		if k=="rbe" and not self.NoMessages then
			ROTGB_CauseNotification(ROTGB_NOTIFY_WAVESTART, ROTGB_NOTIFYTYPE_INFO, nil, {"i32", cwave, "d", v})
		elseif tonumber(k) then
			local balloontype,amount,timeframe,delay = unpack(v)
			totalAmount = totalAmount + (amount or 1)
			delay = (delay or 0) / self:GetSpeedMul() / ROTGB_GetConVarValue("rotgb_spawner_spawn_rate")
			timeframe = (timeframe or 0) / self:GetSpeedMul() / ROTGB_GetConVarValue("rotgb_spawner_spawn_rate")
			local spawnTable = {type = balloontype, amount = amount or 1, current = 0, startTime = curTime + delay}
			spawnTable.endTime = spawnTable.startTime + timeframe
			table.insert(tablesToInsert, spawnTable)
		end
	end
	if totalAmount == 1 then
		for k,v in pairs(tablesToInsert) do
			v.boss = true
		end
	end
	for k,v in pairs(tablesToInsert) do
		table.insert(self.rotgb_ToSpawn, v)
	end
end

function ENT:GetWaveTable()
	return ROTGB_CUSTOM_WAVES[self:GetWaveFile()] or self:GetWaveFile()~="" and self.CustomWaveData or ROTGB_WAVES
end

function ENT:GenerateNextWave(cwave)
	if not self:GetWaveTable()[cwave-1] then
		self:GenerateNextWave(cwave-1)
	end
	local lastRBE = self:GetWaveTable()[cwave-1].assumerbe or self:GetWaveTable()[cwave-1].rbe
	local targetRBE = math.min(lastRBE*1.08, lastRBE+2.5e6)
	local currentRBE = 0
	local wavetab = {}
	local choices = {"gballoon_blimp_blue","gballoon_blimp_red","gballoon_blimp_green","gballoon_fast_hidden_regen_shielded_blimp_gray","gballoon_blimp_purple","gballoon_fast_blimp_magenta","gballoon_blimp_rainbow"}
	local factors = {40,20,10,5,2,1}
	local maxFactor = 100
	local missingChoices = 0
	local duration = 10
	while true do
		if currentRBE > (self:GetWaveTable()[cwave-1].assumerbe or self:GetWaveTable()[cwave-1].rbe) then break end
		local genval = util.SharedRandom("ROTGB_WAVEGEN__"..self:GetWaveFile().."_"..cwave,0,#choices,currentRBE)
		local choice = table.remove(choices, math.floor(genval)+1)
		local typeRBE, amount = 0, 0
		if choice then
			local keyValues = list.Get("NPC")[choice].KeyValues
			typeRBE = scripted_ents.GetStored("gballoon_base").t.rotgb_rbetab[keyValues.BalloonType]
			if tobool(keyValues.BalloonShielded) then
				typeRBE = typeRBE * 2
			end
			amount = math.floor((targetRBE-currentRBE)/typeRBE)
			if amount <= maxFactor then
				for i,v in ipairs(factors) do
					if amount>=v then amount=v break end
				end
			else
				amount = 0
			end
		elseif missingChoices < 2 then
			if missingChoices == 0 then
				if targetRBE-currentRBE > 999999999 then
					choice = "gballoon_cfiber"
				elseif targetRBE-currentRBE > 50e6 then
					choice = "gballoon_blimp_long_rainbow_super"
				end
				if choice then
					local keyValues = list.Get("NPC")[choice].KeyValues
					typeRBE = scripted_ents.GetStored("gballoon_base").t.rotgb_rbetab[keyValues.BalloonType]
					if tobool(keyValues.BalloonShielded) then
						typeRBE = typeRBE * 2
					end
					amount = 1
				end
			elseif missingChoices == 1 then
				choice = "gballoon_fast_hidden_regen_shielded_blimp_rainbow"
				local keyValues = list.Get("NPC")[choice].KeyValues
				typeRBE = scripted_ents.GetStored("gballoon_base").t.rotgb_rbetab[keyValues.BalloonType]
				if tobool(keyValues.BalloonShielded) then
					typeRBE = typeRBE * 2
				end
				amount = math.ceil((targetRBE-currentRBE)/typeRBE)
			end
			missingChoices = missingChoices + 1
		else break
		end
		if amount > 0 then
			if amount > 100 then
				if amount > 1000 then
					duration = math.max(duration, math.sqrt(1000)*amount/1000)
				else
					duration = math.max(duration, math.sqrt(amount))
				end
			end
			table.insert(wavetab,{choice,amount,amount == 1 and 0 or duration})
			currentRBE = currentRBE + typeRBE * amount
		end
	end
	wavetab.rbe = math.Round(currentRBE)
	wavetab.duration = duration
	--wavetab.unnatural = true
	self:GetWaveTable()[cwave] = wavetab
end

function ENT:TriggerWaveEnded()
	local cwave = self:GetWave()
	local inFreeplay = cwave > self:GetLastWave()
	if (self.lastEndWaveTriggered or 1) ~= cwave then
		self.lastEndWaveTriggered = cwave
		local income = hook.Run("gBalloonSpawnerIncome",self,cwave-1) or 100
		ROTGB_AddCash(income/self:GetSpawnDivider()*ROTGB_GetConVarValue("rotgb_cash_mul"))
		
		hook.Run("gBalloonSpawnerWaveEnded",self,cwave-1)
		if self:GetNWString("rotgb_validwave","") == "" then
			ROTGB_CauseNotification(ROTGB_NOTIFY_WAVEEND, ROTGB_NOTIFYTYPE_CHAT, nil, {"i32", cwave-1})
		end
		if inFreeplay and not self.WinWave then
			self.WinWave = cwave
			if not self.NoMessages then
				hook.Run("AllBalloonsDestroyed")
				ROTGB_CauseNotification(ROTGB_NOTIFY_WIN, ROTGB_NOTIFYTYPE_CHAT)
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
			if (IsValid(self) and (self:GetAutoStart() or self:GetForceNextWave())) then
				self:Use(self,self,USE_ON,1)
			end
		end)
	elseif self:GetAutoStart() or self:GetForceNextWave() then
		self:Use(self,self,USE_ON,1)
	end
end

local function SpawnTableNotDoneFilter(k,v)
	return v.current ~= v.amount
end

function ENT:Think()
	if SERVER then
		if self.EnableBalloonChecking then
			local shouldSpawnNextWave = self:GetNextWaveTime() <= CurTime()
			if shouldSpawnNextWave and self:GetForceNextWave() and self:GetWave() ~= self:GetLastWave() + 1 then
				self.EnableBalloonChecking = nil
				self:SpawnNextWave()
			elseif next(self.rotgb_ToSpawn) then
				self.LastTimePushed = self.LastTimePushed or 0
				
				if self.LastTimePushed > CurTime() + 1 then
					self.LastTimePushed = 0
				end
				
				if ROTGB_GetBalloonCount() >= ROTGB_GetConVarValue("rotgb_spawner_max_to_exist") and self.LastTimePushed < CurTime() then
					self:AddTimePhase(1)
					self.LastTimePushed = CurTime() + 1
				end
				
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
			elseif shouldSpawnNextWave and not ROTGB_BalloonsExist() then
				self.EnableBalloonChecking = nil
				self:SpawnNextWave()
			end
		end
		
		if self.CustomWaveName ~= self:GetWaveFile() then
			self.CustomWaveName = self:GetWaveFile()
			if ROTGB_CUSTOM_WAVES[self.CustomWaveName] then
				self:SetNWString("rotgb_validwave",self.CustomWaveName)
				if not self.NoMessages then
					ROTGB_CauseNotification(ROTGB_NOTIFY_WAVELOADED, ROTGB_NOTIFYTYPE_CHAT, nil, {"s", self:GetWaveFile()})
				end
			elseif file.Exists("rotgb_wavedata/"..self:GetWaveFile()..".dat", "DATA") then
				local rawdata = util.JSONToTable(util.Decompress(file.Read("rotgb_wavedata/"..self:GetWaveFile()..".dat","DATA") or ""))
				if rawdata then
					if not self.NoMessages then
						ROTGB_CauseNotification(ROTGB_NOTIFY_WAVELOADED, ROTGB_NOTIFYTYPE_CHAT, nil, {"s", self:GetWaveFile()})
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
		
		if self.OldMusicString ~= self:GetMusicString() then
			self.OldMusicString = self:GetMusicString()
			self.MusicData = {}
			
			for wave,file in string.gmatch(self.OldMusicString.."\0", "([^;]+),([^%z;]*)") do
				table.insert(self.MusicData, {wave = tonumber(wave) or -1, file = file})
			end
			
			table.SortByMember(self.MusicData, "wave")
			self.MusicRequiresResync = true
		end
		if self.MusicRequiresResync then
			self.MusicRequiresResync = false
			self:SyncEntity()
		end
	end
	if CLIENT then
		if self:GetNWString("rotgb_validwave")~=self.CustomWaveName then
			if ROTGB_CUSTOM_WAVES[self:GetNWString("rotgb_validwave")] then
				self.CustomWaveName = self:GetNWString("rotgb_validwave")
			elseif ((ROTGB_CLIENTWAVES[self:GetWaveFile()] or {})[1] or {}).rbe then
				self.CustomWaveName = self:GetNWString("rotgb_validwave")
				self.CustomWaveData = ROTGB_CLIENTWAVES[self:GetWaveFile()]
			end
		end
		self:MusicThink()
	end
	
	self:NextThink(CurTime())
	return true
end

function ENT:CheckForMusicPlay(cwave)
	self.NewMusic = -1
	if ROTGB_GetConVarValue("rotgb_music_volume") > 0 then
		for i,v in ipairs(self.MusicData or {}) do
			if v.wave < 0 then break
			elseif cwave >= v.wave then
				self.NewMusic = i break
			end
		end
	end
	ROTGB_EntityLog(self, string.format("Determined new music index to be %i for wave %i...", self.NewMusic, cwave), "music")
end

function ENT:MusicThink()
	local currentMusic = self.CurrentMusicString or ""
	local newMusic = self:GetWave() == 667 and "barzoom_halloween_panic.mp3" or self:GetWave() ~= 666 and self:GetSingleMusicData(self.NewMusic).file or ""
	local volume = ROTGB_GetConVarValue("rotgb_music_volume")
	local streamPlaying = IsValid(self.MusicStream) and self.MusicStream:GetState()==GMOD_CHANNEL_PLAYING
	if self.NewMusic ~= self.CurrentMusic or currentMusic ~= newMusic or not streamPlaying and currentMusic ~= "" then
		if streamPlaying then
			if self.MusicStream:GetVolume()>0.001 then
				self.MusicStream:SetVolume(math.max(self.MusicStream:GetVolume()-RealFrameTime(), 0))
				ROTGB_EntityLog(self, string.format("%i ~= %i or \"%s\" ~= \"%s\", stopping music!", self.CurrentMusic, self.NewMusic, currentMusic, newMusic), "music")
			else
				self.MusicStream:Stop()
				ROTGB_EntityLog(self, string.format("%i ~= %i or \"%s\" ~= \"%s\", stopped music!", self.CurrentMusic, self.NewMusic, currentMusic, newMusic), "music")
			end
		elseif not self.MusicStreamLoading then
			local data = self:GetSingleMusicData(self.NewMusic)
			if newMusic ~= "" then
				ROTGB_EntityLog(self, string.format("Loading stream for file \"%s\"...", newMusic), "music")
				local startTime = SysTime()
				sound.PlayFile("sound/"..newMusic, "", function(stream, err, errStr)
					if IsValid(self) then
						if stream then
							ROTGB_EntityLog(self, string.format("Received stream from BASS library in %.2fms.", (SysTime()-startTime)*1e3), "music")
							stream:SetVolume(volume)
							self.MusicStream = stream
						else
							ROTGB_EntityLogError(self, string.format("BASS Error! %i - %s", err, errStr), "music")
							ROTGB_EntityLog(self, string.format("Transaction time: %.2fms", (SysTime()-startTime)*1e3), "music")
						end
					else
						if stream then
							stream:Stop()
						end
						ROTGB_LogError(string.format("Stream %s loaded, but gBalloon Spawner is gone?", tostring(stream)), "music")
						ROTGB_Log(string.format("Transaction time: %.2fms", (SysTime()-startTime)*1e3), "music")
					end
					self.MusicStreamLoading = nil
				end)
				self.MusicStreamLoading = true
			end
			ROTGB_EntityLog(self, string.format("%i ~= %i or \"%s\" ~= \"%s\", music switched!", self.CurrentMusic, self.NewMusic, currentMusic, newMusic), "music")
			
			local texts = self:GetWave() == 667 and {
				"Now Playing:",
				"Barzoom - Halloween Panic",
				"from the Newgrounds Audio Portal",
				"http://www.newgrounds.com/audio/listen/649375"
			} or self:GetWave() ~= 666 and data.texts or {}
			if next(texts) then
				local textsToDisplay = {}
				for i,v in ipairs(texts) do
					table.insert(textsToDisplay, language.GetPhrase(v))
				end
				
				chat.AddText(table.concat(textsToDisplay, "\n"))
			end
			self.CurrentMusic = self.NewMusic
			self.CurrentMusicString = newMusic
		end
	elseif streamPlaying then
		local currentVolume = self.MusicStream:GetVolume()
		if currentVolume+0.001<=volume or currentVolume>=volume+0.001 then
			ROTGB_EntityLog(self, string.format("%i == %i but %.4f ~= %.4f, changing volume!", self.CurrentMusic, self.NewMusic, currentVolume, volume), "music")
			self.MusicStream:SetVolume(math.Approach(currentVolume, volume, RealFrameTime()))
		end
		if volume <= 0 then self:CheckForMusicPlay(self.OldMusicWave-1) end
	end
	if self.OldMusicVolume ~= volume then
		self.OldMusicVolume = volume
		self:CheckForMusicPlay(self:GetWave()-1)
	elseif self.OldMusicWave ~= self:GetWave() then
		self.OldMusicWave = self:GetWave()
		self:CheckForMusicPlay(self.OldMusicWave-1)
		
		net.Start("rotgb_generic", false)
		net.WriteUInt(ROTGB_OPERATION_SYNCENTITY, 8)
		net.WriteEntity(self)
		net.SendToServer()
	end
end

function ENT:DetermineNextTarget(bln)
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
				if spawnTable.boss then
					bln:SetKeyValue("BalloonBoss", "1")
				end
				hook.Run("gBalloonSpawnerPreSpawn", self, bln, keyValues)
				bln:Spawn()
				hook.Run("gBalloonSpawnerPostSpawn", self, bln, keyValues)
				bln:Activate()
				self:DetermineNextTarget(bln)
				local waveSpeedAmp = self:GetWave()-(self.WinWave or math.huge)-1
				if waveSpeedAmp > 0 then
					bln:Slowdown("Freeplay", 1.05^waveSpeedAmp, 9999)
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
		local rbe = self:GetWaveTable()[cwave].rbe
		local text1 = ROTGB_LocalizeString("rotgb.gballoon_spawner.hologram.1", cwave, rbe)
		local text2 = ROTGB_LocalizeString("rotgb.gballoon_spawner.hologram.2", cwave, rbe)
		local text3 = ROTGB_LocalizeString("rotgb.gballoon_spawner.hologram.3", cwave, rbe)
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
			local percent = math.Clamp((self:GetNextWaveTime()-CurTime())/self:GetWaveDuration(cwave-1)*self:GetSpeedMul()*ROTGB_GetConVarValue("rotgb_spawner_spawn_rate")+0.02,0,1)
			ROTGB_DrawCircle(0,panelh/-2-32,16,percent,HSVToColor(percent*120,1,1))
		cam.End3D2D()
	else
		local percent = math.Clamp((self:GetNextWaveTime()-CurTime())/self:GetWaveDuration(cwave-1)*self:GetSpeedMul()*ROTGB_GetConVarValue("rotgb_spawner_spawn_rate")+0.02,0,1)
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
	Name = "#rotgb.gballoon_spawner",
	Class = "gballoon_spawner",
	Category = "#rotgb.category.miscellaneous"
})
list.Set("SpawnableEntities","gballoon_spawner",{
	PrintName = "#rotgb.gballoon_spawner",
	ClassName = "gballoon_spawner",
	Category = "#rotgb.category.miscellaneous"
})