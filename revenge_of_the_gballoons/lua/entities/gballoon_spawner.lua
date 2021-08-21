AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
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
--ENT.CustomWaveData = {}
ENT.CustomWaveName = ""

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

ROTGB_WAVES = {
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
		rbe=80--(1+2+3+4)*8
	},
	{ ---- 9
		{"gballoon_pink",8,4},
		{"gballoon_yellow",8,4,4},
		{"gballoon_red",18,2,8},
		duration=10,
		rbe=90--8*5+8*4+18
	},
	{
		{"gballoon_regen_pink",20,10},
		duration=10,
		rbe=100
	},
	{ -- 11
		{"gballoon_white",10,10},
		duration=10,
		rbe=110--10*11
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
		rbe=130--(11+2)*10
	},
	{
		{"gballoon_red",20,10},
		{"gballoon_white",5,5},
		{"gballoon_black",5,5,5},
		duration=10,
		rbe=140--20+10*11
	},
	{ -- 15
		{"gballoon_regen_white",3,3},
		{"gballoon_regen_black",3,3,3},
		{"gballoon_purple",4,2,6},
		{"gballoon_fast_pink",8,2,8},
		duration=10,
		rbe=150--10*11+8*5
	},
	{
		{"gballoon_red",10,5},
		{"gballoon_blue",20,5},
		{"gballoon_purple",10,5,5},
		duration=10,
		rbe=160--10+10*11+20*2
	},
	{ ---- 17
		{"gballoon_red",40,2.5},
		{"gballoon_yellow",5,2.5,2.5},
		{"gballoon_orange",10,5,5},
		duration=10,
		rbe=170--40+5*4+10*11
	},
	{
		{"gballoon_white",10,5},
		{"gballoon_black",5,5,5},
		{"gballoon_regen_green",5,5,5},
		duration=10,
		rbe=180--20+10*11
	},
	{ -- 19
		{"gballoon_gray",5,5},
		{"gballoon_green",25,5,5},
		duration=10,
		rbe=190--5*23+25*3
	},
	{
		{"gballoon_hidden_green",5,5},
		{"gballoon_fast_white",9,4.5,4.5},
		{"gballoon_orange",8,1,9},
		duration=10,
		rbe=202--(8+9)*11+5*3
	},
	{ ---- 21
		{"gballoon_white",4,8},
		{"gballoon_zebra",4,8,0.5},
		{"gballoon_black",4,8,1},
		{"gballoon_pink",7,1,9},
		duration=10,
		rbe=215--4*(11+11+23)+35
	},
	{
		{"gballoon_gray",10,10},
		duration=10,
		rbe=230
	},
	{ -- 23
		{"gballoon_white",5,5},
		{"gballoon_white",5,5},
		{"gballoon_aqua",5,5,5},
		{"gballoon_regen_green",5,5,5},
		duration=10,
		rbe=240--5*23+10*11+15
	},
	{
		{"gballoon_red",32,2},
		{"gballoon_orange",4,2,2},
		{"gballoon_yellow",8,2,4},
		{"gballoon_green",32,2,6},
		{"gballoon_aqua",2,2,8},
		duration=10,
		rbe=250--32*(1+3)+2*23+4*11+8*4
	},
	{ ---- 25
		{"gballoon_error",4,4},
		{"gballoon_shielded_aqua",2,2,4},
		{"gballoon_fast_white",6,3,6},
		{"gballoon_fast_orange",2,1,9},
		duration=10,
		rbe=272--4*23+2*46+6*11+2*11
	},
	{
		{"gballoon_pink",40,10},
		{"gballoon_regen_purple",8,8,2},
		duration=10,
		rbe=288--40*5+8*11
	},
	{ -- 27
		{"gballoon_red",30,3},
		{"gballoon_blue",30,3,3},
		{"gballoon_green",30,3,5},
		{"gballoon_yellow",30,3,7},
		duration=10,
		rbe=300--30*(1+2+3+4)
	},
	{
		{"gballoon_zebra",10,10},
		{"gballoon_zebra",4,1,9},
		duration=10,
		rbe=322--14*23
	},
	{
		{"gballoon_gray",10,10},
		{"gballoon_orange",10,10},
		duration=10,
		rbe=340--10*(23+11)
	},
	{ ---- 30
		{"gballoon_rainbow",2,6},
		{"gballoon_regen_zebra",4,4,6},
		duration=10,
		rbe=370--2*93+4*46
	},---- 30
	{
		{"gballoon_orange",5,2.5},
		{"gballoon_orange",10,2,4},
		{"gballoon_orange",20,2,8},
		duration=10,
		rbe=385--(5+10+20)*11
	},
	{
		{"gballoon_shielded_white",16,8},
		{"gballoon_fast_white",5,1,9},
		duration=10,
		rbe=407--16*22+5*11
	},
	{
		{"gballoon_rainbow",4,8},
		{"gballoon_pink",12,2,8},
		duration=10,
		rbe=432--4*93+12*5
	},
	{
		{"gballoon_regen_red",100,4},
		{"gballoon_gray",12,4,4},
		{"gballoon_pink",16,2,8},
		duration=10,
		rbe=458
	},
	{ -- 35
		{"gballoon_ceramic",4,8},
		{"gballoon_hidden_aqua",3,1,9},
		duration=10,
		rbe=481--4*103+3*23
	},-- 35
	{
		{"gballoon_black",20,4},
		{"gballoon_zebra",10,4,4},
		{"gballoon_shielded_yellow",8,2,8},
		duration=10,
		rbe=514--20*11+10*23+8*8
	},
	{
		{"gballoon_purple",50,10},
		duration=10,
		rbe=550--50*11
	},
	{
		{"gballoon_regen_orange",20,4},
		{"gballoon_regen_pink",40,4,4},
		{"gballoon_regen_green",50,2,8},
		duration=10,
		rbe=570--20*11+40*5+50*3
	},
	{
		{"gballoon_ceramic",4,8},
		{"gballoon_shielded_ceramic",1,2,8},
		duration=10,
		rbe=618--6*103
	},
	{ ---- 40
		{"gballoon_blimp_blue"},
		duration=10,
		rbe=612
	},---- 40
	{
		{"gballoon_orange",48,8},
		{"gballoon_gray",7,1,9},
		duration=10,
		rbe=689--48*11+7*23
	},
	{
		{"gballoon_rainbow",3,9},
		{"gballoon_gray",3,9},
		{"gballoon_zebra",3,9},
		{"gballoon_aqua",3,9},
		{"gballoon_error",3,9},
		{"gballoon_white",3,9},
		{"gballoon_black",3,9},
		{"gballoon_purple",3,9},
		{"gballoon_orange",3,9},
		{"gballoon_pink",3,9},
		{"gballoon_yellow",3,9},
		{"gballoon_green",3,9},
		{"gballoon_blue",3,9},
		{"gballoon_red",2,6},
		{"gballoon_red",1,3,7},
		duration=10,
		rbe=732--3*(93+23*4+11*4+15)
	},
	{
		{"gballoon_ceramic",6,6},
		{"gballoon_hidden_white",14,7,3},
		duration=10,
		rbe=772--6*103+14*11
	},
	{
		{"gballoon_aqua",16,4},
		{"gballoon_rainbow",4,4,4},
		{"gballoon_fast_shielded_pink",8,2,8},
		duration=10,
		rbe=820--16*23+4*93+8*10
	},
	{ -- 45
		{"gballoon_hidden_black",16,4},
		{"gballoon_ceramic",4,2,4},
		{"gballoon_hidden_purple",24,2,6},
		{"gballoon_fast_hidden_shielded_red",8,2,8},
		duration=10,
		rbe=868--(16+24)*11+4*103+8*2
	},-- 45
	{
		{"gballoon_rainbow",10,10},
		duration=10,
		rbe=930
	},
	{
		{"gballoon_error",24,6},
		{"gballoon_black",2,2,4},
		{"gballoon_shielded_purple",18,6,4},
		duration=10,
		rbe=970--24*23+2*11+18*22
	},
	{
		{"gballoon_red",24,2},
		{"gballoon_orange",24,2,2},
		{"gballoon_yellow",24,2,4},
		{"gballoon_green",32,2,6},
		{"gballoon_aqua",24,2,8},
		duration=10,
		rbe=1032--24*(1+11+4+23)+32*3
	},
	{
		{"gballoon_ceramic",10,10},
		{"gballoon_fast_hidden_regen_zebra",3},
		duration=10,
		rbe=1099--10*103+3*23
	},
	{ ---- 50
		{"gballoon_blimp_blue"},
		{"gballoon_brick",2,2,6},
		{"gballoon_shielded_brick",1,2,8},
		duration=10,
		rbe=1144--612+4*133
	},---- 50
	{
		{"gballoon_zebra",10,10},
		{"gballoon_black",9,0.9},
		{"gballoon_white",9,0.9,1},
		{"gballoon_black",9,0.9,2},
		{"gballoon_white",9,0.9,3},
		{"gballoon_black",9,0.9,4},
		{"gballoon_white",9,0.9,5},
		{"gballoon_black",9,0.9,6},
		{"gballoon_white",9,0.9,7},
		{"gballoon_black",9,0.9,8},
		{"gballoon_white",9,0.9,9},
		duration=10,
		rbe=1220--10*23+90*11
	},
	{
		{"gballoon_fast_shielded_orange",60,10},
		duration=10,
		rbe=1320--60*22
	},
	{
		{"gballoon_rainbow",5,5},
		{"gballoon_shielded_rainbow",5,5,5},
		duration=10,
		rbe=1395--15*93
	},
	{
		{"gballoon_brick"},
		{"gballoon_brick",10,10},
		duration=10,
		rbe=1463--11*133
	},
	{ -- 55
		{"gballoon_hidden_gray",15,3},
		{"gballoon_blimp_blue",1,6},
		{"gballoon_blimp_blue",1,10},
		duration=10,
		rbe=1569--15*23+2*612
	},-- 55
	{
		{"gballoon_ceramic",10,5},
		{"gballoon_shielded_purple",24,4,5},
		{"gballoon_fast_regen_rainbow",1,1,9},
		duration=10,
		rbe=1651--10*103+24*22+93
	},
	{
		{"gballoon_hidden_black"},
		{"gballoon_hidden_black",32,4},
		{"gballoon_regen_error",60,6,4},
		duration=10,
		rbe=1743--33*11+60*23
	},
	{
		{"gballoon_blimp_blue"},
		{"gballoon_blimp_blue",1,5},
		{"gballoon_blimp_blue",1,10},
		duration=10,
		rbe=1836--3*612
	},
	{
		{"gballoon_regen_shielded_ceramic",10,10},
		duration=10,
		rbe=2060--10*206
	},
	{ ---- 60
		{"gballoon_blimp_red"},
		duration=10,
		rbe=3148
	},---- 60
	{
		{"gballoon_brick",16,8},
		{"gballoon_fast_hidden_regen_shielded_pink",8,2,8},
		duration=10,
		rbe=2208--16*133+8*10
	},
	{
		{"gballoon_regen_rainbow",20,5},
		{"gballoon_regen_gray",21,3.5,6.5},
		duration=10,
		rbe=2343--20*93+21*23
	},
	{
		{"gballoon_fast_ceramic",4,8},
		{"gballoon_ceramic",20,0.5,9.5},
		duration=10,
		rbe=2472--24*103
	},
	{
		{"gballoon_rainbow",20,4},
		{"gballoon_white",10,0.5,5},
		{"gballoon_black",10,0.5,6},
		{"gballoon_purple",10,0.5,7},
		{"gballoon_orange",10,0.5,8},
		{"gballoon_fast_hidden_purple",30,1,9},
		duration=10,
		rbe=2630--20*93+70*11
	},
	{ -- 65
		{"gballoon_shielded_blimp_blue"},
		{"gballoon_fast_hidden_regen_shielded_ceramic",8,8,2},
		duration=10,
		rbe=2872--8*206+612*2
	},-- 65
	{
		{"gballoon_fast_regen_rainbow",20,10},
		{"gballoon_aqua",48,6,4},
		duration=10,
		rbe=2964--20*93+48*23
	},
	{
		{"gballoon_blimp_blue",5,10},
		duration=10,
		rbe=3060--5*612
	},
	{
		{"gballoon_fast_brick",20,10},
		{"gballoon_fast_regen_pink",120,10},
		{"gballoon_fast_hidden_regen_red",60,10},
		duration=10,
		rbe=3320--20*133+120*5+60
	},
	{
		{"gballoon_blimp_blue",5,5},
		{"gballoon_fast_regen_pink",50,5,5},
		{"gballoon_fast_hidden_regen_yellow",50,5,5},
		duration=10,
		rbe=3510--5*612+50*(4+5)
	},
	{ ---- 70
		{"gballoon_ceramic",8,2},
		{"gballoon_brick",8,2,2},
		{"gballoon_marble",8,2,4},
		{"gballoon_hidden_regen_error",12,4,6},
		{"gballoon_fast_hidden_regen_error",1,10},
		duration=10,
		rbe=3731--8*(103+133+193)+13*23
	},---- 70
	{
		{"gballoon_blimp_red"},
		{"gballoon_shielded_brick",3,6,4},
		duration=10,
		rbe=3946--3148+3*266
	},
	{
		{"gballoon_fast_red",100,2},
		{"gballoon_fast_orange",100,2,2},
		{"gballoon_fast_yellow",100,2,4},
		{"gballoon_fast_green",100,2,6},
		{"gballoon_fast_aqua",100,2,8},
		duration=10,
		rbe=4200--100*(1+11+4+3+23)
	},
	{
		{"gballoon_marble",17,8.5},
		{"gballoon_shielded_marble",3,1.5,8.5},
		duration=10,
		rbe=4439--23*193
	},
	{
		{"gballoon_blimp_blue",5,10},
		{"gballoon_ceramic",1,0,1},
		{"gballoon_ceramic",2,0,3},
		{"gballoon_ceramic",3,0,5},
		{"gballoon_ceramic",4,0,7},
		{"gballoon_ceramic",6,0,9},
		duration=10,
		rbe=4708--5*612+16*103
	},
	{ -- 75
		{"gballoon_fast_hidden_regen_shielded_ceramic",10,10},
		{"gballoon_fast_hidden_regen_shielded_ceramic",14,0.5,9.5},
		duration=10,
		rbe=4944--24*206
	},-- 75
	{
		{"gballoon_fast_ceramic",3},
		{"gballoon_blimp_blue",3,6,2},
		{"gballoon_blimp_red",1,10},
		duration=10,
		rbe=5293--3148+3*612+3*103
	},
	{
		{"gballoon_regen_rainbow",60,10},
		duration=10,
		rbe=5580--60*93
	},
	{
		{"gballoon_fast_regen_shielded_error",100,10},
		{"gballoon_shielded_blimp_blue",1,10},
		duration=10,
		rbe=5824--100*46+2*612
	},
	{
		{"gballoon_fast_hidden_regen_shielded_rainbow"},
		{"gballoon_fast_regen_blimp_blue",10,10},
		duration=10,
		rbe=6306--186+10*612
	},
	{ ---- 80
		{"gballoon_blimp_green"},
		duration=10,
		rbe=16592
	},---- 80
	{
		{"gballoon_fast_regen_shielded_brick",20,1},
		{"gballoon_fast_regen_shielded_brick",20,1,4},
		{"gballoon_fast_hidden_regen_shielded_orange",80,2,8},
		duration=10,
		rbe=7080--40*133+80*22
	},
	{
		{"gballoon_fast_blimp_blue",2,10},
		{"gballoon_blimp_red",1,2.5},
		{"gballoon_blimp_red",1,7.5},
		duration=10,
		rbe=7520--2*(612+3148)
	},
	{
		{"gballoon_fast_hidden_regen_purple",40,1},
		{"gballoon_fast_regen_shielded_rainbow",24,4,1},
		{"gballoon_regen_blimp_blue",5,5,5},
		duration=10,
		rbe=7964--5*612+24*186+40*11
	},
	{
		{"gballoon_fast_regen_rainbow",90,10},
		duration=10,
		rbe=8370--90*93
	},
	{ -- 85
		{"gballoon_fast_shielded_blimp_red"},
		{"gballoon_fast_regen_blimp_blue",4,8},
		{"gballoon_fast_hidden_regen_marble",1,10},
		duration=10,
		rbe=8937--2*3148+4*612+193
	},-- 85
	{
		{"gballoon_blimp_red"},
		{"gballoon_blimp_red",2,10},
		duration=10,
		rbe=9444--3148*3
	},
	{
		{"gballoon_regen_marble",48,6},
		{"gballoon_fast_hidden_regen_shielded_white",35,3.5,6.5},
		duration=10,
		rbe=10034--48*193+35*22
	},
	{
		{"gballoon_fast_hidden_regen_shielded_error",5,5},
		{"gballoon_blimp_blue",5,5,5},
		{"gballoon_blimp_blue",12,1,9},
		duration=10,
		rbe=10634--17*612+5*46
	},
	{
		{"gballoon_fast_regen_rainbow"},
		{"gballoon_fast_regen_rainbow",120,10},
		duration=10,
		rbe=11253--121*93
	},
	{ ---- 90
		{"gballoon_hidden_regen_gray",100,5},
		{"gballoon_hidden_regen_blimp_gray",10,5,5},
		duration=10,
		rbe=12020--100*23+10*972
	},---- 90
	{
		{"gballoon_shielded_blimp_red"},
		{"gballoon_fast_hidden_regen_rainbow",1,5},
		{"gballoon_shielded_blimp_red",1,10},
		duration=10,
		rbe=12685--4*3148+93
	},
	{
		{"gballoon_blimp_blue",20,10},
		{"gballoon_fast_regen_shielded_blimp_blue",1,10},
		duration=10,
		rbe=13464--22*612
	},
	{
		{"gballoon_fast_regen_shielded_brick",17,3.4},
		{"gballoon_hidden_regen_blimp_gray",10,5,5},
		duration=10,
		rbe=14242--10*972+17*266
	},
	{
		{"gballoon_fast_regen_shielded_rainbow",81,9,1},
		duration=10,
		rbe=15066--81*186
	},
	{ -- 95
		{"gballoon_fast_hidden_regen_shielded_marble",5,1},
		{"gballoon_fast_hidden_regen_shielded_marble",9,1,4},
		{"gballoon_fast_hidden_regen_shielded_marble",19,1,8},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",5,5,5},
		duration=10,
		rbe=16007--33*193+5*1944
	},-- 95
	{
		{"gballoon_fast_hidden_regen_shielded_ceramic",6,0.5},
		{"gballoon_fast_regen_blimp_red",5,10},
		duration=10,
		rbe=16976--5*3148+6*206
	},
	{
		{"gballoon_fast_hidden_regen_zebra",37,1},
		{"gballoon_fast_regen_shielded_blimp_blue",14,7,3},
		duration=10,
		rbe=17987--14*1224+37*23
	},
	{
		{"gballoon_fast_regen_blimp_green"},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",2,10},
		duration=10,
		rbe=20480--16592+2*1944
	},
	{
		{"gballoon_rainbow",200,10},
		{"gballoon_fast_hidden_regen_rainbow",21,1,9},
		duration=10,
		rbe=20553--221*93
	},
	{ ---- 100
		{"gballoon_blimp_purple"},
		duration=10,
		rbe=55128
	},---- 100
	{
		{"gballoon_fast_marble",100,5},
		{"gballoon_blimp_red",1,6},
		{"gballoon_fast_hidden_regen_shielded_brick",1,10},
		duration=10,
		rbe=22714--100*193+3148+266
	},
	{
		{"gballoon_blimp_green"},
		{"gballoon_shielded_blimp_red",1,5},
		{"gballoon_fast_regen_shielded_blimp_blue",1,10},
		duration=10,
		rbe=24112--16592+2*3148+2*612
	},
	{
		{"gballoon_hidden_regen_blimp_gray",24,6},
		{"gballoon_fast_hidden_regen_shielded_ceramic",10,2,6},
		{"gballoon_fast_hidden_regen_pink",25,2.5,7.5},
		duration=10,
		rbe=25513--24*972+20*103+25*5
	},
	{
		{"gballoon_regen_marble",100,10},
		{"gballoon_fast_hidden_regen_shielded_marble",20,1,9},
		duration=10,
		rbe=27020--140*193
	},
	{ -- 105
		{"gballoon_fast_hidden_regen_blimp_gray",2,1},
		{"gballoon_fast_hidden_regen_blimp_gray",4,1,4.5},
		{"gballoon_fast_hidden_regen_blimp_gray",9,1,9},
		duration=10,
		rbe=29160--(2+4+9)*2*972
	},-- 105
	{
		{"gballoon_fast_regen_blimp_blue",50,10},
		duration=10,
		rbe=30600--50*612
	},
	{
		{"gballoon_fast_regen_blimp_red",10,10},
		{"gballoon_fast_hidden_regen_ceramic",7,0.5,4.5},
		duration=10,
		rbe=32201--10*3148+7*103
	},
	{
		{"gballoon_regen_blimp_green",2,10},
		{"gballoon_fast_hidden_regen_marble",5,1,9},
		duration=10,
		rbe=34149--2*16592+5*193
	},
	{
		{"gballoon_fast_hidden_regen_shielded_rainbow",50,2},
		{"gballoon_fast_hidden_regen_shielded_rainbow",50,2,4},
		{"gballoon_fast_hidden_regen_shielded_rainbow",95,2,8},
		duration=10,
		rbe=36270--195*186
	},
	{ ---- 110
		{"gballoon_fast_marble",60,5},
		{"gballoon_fast_blimp_magenta",5,5,5},
		duration=10,
		rbe=38520--60*193+5*5388
	},---- 110
	{
		{"gballoon_fast_blimp_magenta",5,10},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray"},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",2,1},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",4,8,1},
		duration=10,
		rbe=40548--5*5388+7*1944
	},
	{
		{"gballoon_fast_regen_blimp_red",10,5},
		{"gballoon_fast_regen_blimp_blue",10,5,5},
		{"gballoon_fast_regen_blimp_blue",9,1,9},
		duration=10,
		rbe=43108--10*3148+19*612
	},
	{
		{"gballoon_fast_hidden_regen_blimp_gray",40,10},
		{"gballoon_fast_hidden_regen_blimp_gray",7,1,9},
		duration=10,
		rbe=45684--47*972
	},
	{
		{"gballoon_marble",250,10},
		duration=10,
		rbe=48250--250*193
	},
	{ -- 115
		{"gballoon_fast_regen_shielded_blimp_green"},
		{"gballoon_fast_regen_blimp_magenta",3,0.5,9.5},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",1,10},
		duration=10,
		rbe=51292--2*16592+3*5388+1944
	},-- 115
	{
		{"gballoon_fast_hidden_regen_shielded_marble",12,6},
		{"gballoon_regen_blimp_green",3,9,1},
		duration=10,
		rbe=54408--3*16592+12*2*193
	},
	{
		{"gballoon_blimp_purple"},
		{"gballoon_fast_hidden_regen_error",111,5.55,4.45},
		duration=10,
		rbe=57681--55128+111*23
	},
	{
		{"gballoon_fast_regen_shielded_blimp_blue",5,10},
		{"gballoon_blimp_purple",1,5},
		duration=10,
		rbe=61248--55128+5*2*612
	},
	{
		{"gballoon_fast_hidden_regen_shielded_rainbow",50,10},
		{"gballoon_fast_hidden_regen_shielded_rainbow",2,0.5,9.5},
		{"gballoon_blimp_purple",1,10},
		duration=10,
		rbe=64800--55128+52*2*93
	},
	{ ---- 120
		{"gballoon_blimp_rainbow"},
		duration=10,
		rbe=221031
	},---- 120
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
	self:NetworkVar("Bool", 0, "AutoStart", {KeyName="auto_start", Edit={title="Auto-Start", type="Boolean", order=6}})
	self:NetworkVar("Bool", 1, "ForceNextWave", {KeyName="force_next", Edit={title="Force Auto-Start", type="Boolean", order=8}})
	self:NetworkVar("Bool", 2, "StartAll", {KeyName="start_all", Edit={title="Start All Others", type="Boolean", order=9}})
	self:NetworkVar("Bool", 3, "UnSpectatable")
	self:NetworkVar("Bool", 4, "HideWave", {KeyName="hide_wave", Edit={title="Don't Show In HUD", type="Boolean", order=11}})
	self:NetworkVar("Float", 0, "AutoStartDelay", {KeyName="auto_start_delay", Edit={title="Auto-Start Delay", type="Float", min=0, max=60, order=7}})
	self:NetworkVar("Float", 1, "SpeedMul", {KeyName="spawn_speed_mul", Edit={title="Spawn Rate", type="Float", min=0.1, max=10, order=3}})
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
	--[[elseif lkey=="auto_start" then
		self:SetAutoStart(tobool(value))]]
	elseif lkey=="no_auto_start" then
		self.NoAutoStart = true
	elseif lkey=="start_all" then
		self:SetStartAll(tobool(value))
	elseif lkey=="unspectatable" then
		self:SetUnSpectatable(tobool(value))
		scripted_ents.GetMember("point_rotgb_spectator", "TransmitChangeToSpectatingPlayers")(self)
	elseif lkey=="force_next" then
		self:SetForceNextWave(tobool(value))
	elseif lkey=="auto_start_delay" then
		self:SetAutoStartDelay(tonumber(value) or 0)
	elseif lkey=="spawn_speed_mul" then
		self:SetSpeedMul(tonumber(value) or 1)
	elseif lkey=="spawn_divider" then
		self:SetSpawnDivider(tonumber(value) or 1)
	elseif lkey=="divider_delay" then
		self:SetDividerDelay(tonumber(value) or 1)
	elseif string.sub(lkey,1,11) == "next_target" then
		local num = (tonumber("0x"..string.sub(lkey,-1)) or 0) + 1
		self.TempNextTargets = self.TempNextTargets or {}
		self.TempNextTargets[num] = value
	elseif string.sub(lkey,1,17) == "next_blimp_target" then
		local num = (tonumber("0x"..string.sub(lkey,-1)) or 0) + 1
		self.TempNextBlimpTargets = self.TempNextBlimpTargets or {}
		self.TempNextBlimpTargets[num] = value
	elseif lkey=="model" then
		self.Model = value
	elseif lkey=="skin" then
		self.Skin = value
	elseif lkey=="finished_shortly_threshold" then
		self.OutputShortlyThreshold = value
	elseif lkey=="wave_preset" then
		self:SetWaveFile(value)
	elseif lkey=="is_hidden" then
		self.TempIsHidden = tobool(value)
	elseif lkey=="hide_wave" then
		self:SetHideWave(tobool(value))
	elseif lkey=="onwavestart" then
		self:StoreOutput(key,value)
	elseif lkey=="onwavefinished" then
		self:StoreOutput(key,value)
	elseif lkey=="onwavefinishedshortly" then
		self:StoreOutput(key,value)
	elseif lkey=="dont_trigger_wave_relays" then
		self.DontTriggerWaveRelays = value
	elseif lkey=="no_messages" then
		self.NoMessages = tobool(value)
	end
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
	elseif input=="setautostart" then
		self:SetAutoStart(tobool(data))
	elseif input=="setstartall" then
		self:SetStartAll(tobool(data))
	elseif input=="setforcenext" then
		self:SetForceNextWave(tobool(data))
	elseif string.sub(input,1,15) == "setnextwaypoint" then
		local num = (tonumber("0x"..string.sub(input,-1)) or 0) + 1
		self["SetNextTarget"..num](self,data~="" and ents.FindByName(data)[1] or NULL)
	elseif string.sub(input,1,20) == "setnextblimpwaypoint" then
		local num = (tonumber("0x"..string.sub(input,-1)) or 0) + 1
		self["SetNextBlimpTarget"..num](self,data~="" and ents.FindByName(data)[1] or NULL)
	elseif input=="setspawndivider" then
		self:SetSpawnDivider(tonumber(data) or 1)
	elseif input=="setdividerdelay" then
		self:SetDividerDelay(tonumber(data) or 1)
	elseif input=="setwavepreset" then
		self:SetWaveFile(data)
	elseif input=="enablespectating" then
		self:SetUnSpectatable(false)
	elseif input=="disablespectating" then
		self:SetUnSpectatable(true)
		scripted_ents.GetMember("point_rotgb_spectator", "TransmitChangeToSpectatingPlayers")(self)
	elseif input=="togglespectating" then
		self:SetUnSpectatable(not self:GetUnSpectatable())
		scripted_ents.GetMember("point_rotgb_spectator", "TransmitChangeToSpectatingPlayers")(self)
	elseif input=="enablewavehiding" then
		self:SetHideWave(true)
	elseif input=="disablewavehiding" then
		self:SetHideWave(false)
	elseif input=="togglewavehiding" then
		self:SetHideWave(not self:GetHideWave())
	elseif input=="hide" then
		self:SetNotSolid(true)
		self:SetNoDraw(true)
		self:SetMoveType(MOVETYPE_NOCLIP)
	elseif input=="unhide" then
		self:SetNotSolid(false)
		self:SetNoDraw(false)
		self:SetMoveType(MOVETYPE_VPHYSICS)
	elseif input=="togglehide" then
		if self:GetNoDraw() then
			self:SetNotSolid(false)
			self:SetNoDraw(false)
			self:SetMoveType(MOVETYPE_VPHYSICS)
		else
			self:SetNotSolid(true)
			self:SetNoDraw(true)
			self:SetMoveType(MOVETYPE_NOCLIP)
		end
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
		self:SetModel(self.Model or "models/props_c17/streetsign004e.mdl")
		if self:GetWaveFile() == "" then
			self:SetWaveFile(ROTGB_GetConVarValue("rotgb_default_wave_preset"))
		end
		if self.Skin then
			self:SetSkin(self.Skin)
		end
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
		self:PhysicsInit(SOLID_VPHYSICS)
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:Wake()
		end
		self:SetUseType(SIMPLE_USE)
		if not self.NoAutoStart then
			self.NoAutoStart = true
			self:SetAutoStart(true)
		end
		if self.TempIsHidden then
			self:SetNotSolid(true)
			self:SetNoDraw(true)
			self:SetMoveType(MOVETYPE_NOCLIP)
		end
	end
end

function ENT:PostEntityPaste(ply,ent,tab)
	ent:Spawn()
	ent:Activate()
end

function ENT:Use(activator)
	--if input:lower()=="balloon_start_wave" then
		local cwave = self:GetWave()
		if cwave == self:GetLastWave() + 1 and (self.EnableBalloonChecking or self:GetNextWaveTime() <= CurTime()) then return end
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
		self:TriggerOutput("OnWaveStart",activator,cwave)
		if not self.NoMessages then
			PrintMessage(HUD_PRINTTALK,"Wave "..cwave.." started!")
		end
		local creaid = self:GetCreationID()
		for k,v in pairs(self:GetWaveTable()[cwave] or {}) do
			if k=="rbe" and not self.NoMessages then
				PrintMessage(HUD_PRINTTALK,"RgBE: "..v)
			elseif tonumber(k) then
				local balloontype,amount,timeframe,delay = unpack(v)
				local timername = "BalloonSpawner_"..creaid.."_"..cwave.."_"..k
				timeframe = (timeframe or 0) / self:GetSpeedMul()
				local function layer1()
					if IsValid(self) then
						self.TimesSpawned = (self.TimesSpawned or -1) + 1
						if (self.TimesSpawned - self:GetDividerDelay()) % self:GetSpawnDivider() == 0 then
							local SpawnPos = self:GetPos()+Vector(0,0,10)
							local bln = ents.Create("gballoon_base")
							if IsValid(bln) then
								bln:SetPos(SpawnPos)
								for k,v in pairs(list.GetForEdit("NPC")[balloontype].KeyValues) do
									bln:SetKeyValue(k,v)
								end
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
								--timer.Simple(0,function()
									if bln.loco then
										bln.loco:SetAcceleration(bln.loco:GetAcceleration()*1.02^math.max(0,cwave-(self.WinWave or math.huge)))
									end
								--end)
							end
						end
					else
						timer.Remove(timername)
					end
				end
				local function layer2()
					timer.Create(timername,timeframe/(amount or 1),amount or 1,layer1)
				end
				timer.Simple((delay or 0)/self:GetSpeedMul(),layer2)
			end
		end
		self.EnableBalloonChecking = true
		self:SetWave(cwave+1)
	--end
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
	local factors = {120,60,40,30,24,20,15,12,10,8,6,5,4,3,2,1}
	while true do
		if trbe > (self:GetWaveTable()[cwave-1].assumerbe or self:GetWaveTable()[cwave-1].rbe) then break end
		local genval = util.SharedRandom("ROTGB_WAVEGEN_"..self:GetWaveFile().."_"..cwave,0,7,trbe)
		local choice = choices[math.floor(genval)+1]
		local crbe = scripted_ents.GetStored("gballoon_base").t.rotgb_rbetab[choice]
		local amount = math.Clamp((erbe-trbe)/crbe,1,120)
		for i,v in ipairs(factors) do
			if amount>=v then amount=v break end
		end
		table.insert(wavetab,{choice,amount,60})
		trbe = trbe + crbe * amount
	end
	wavetab.rbe = math.Round(trbe)
	wavetab.duration = 60
	--wavetab.unnatural = true
	self:GetWaveTable()[cwave] = wavetab
end

function ENT:TriggerWaveEnded()
	local cwave = self:GetWave()
	local inFreeplay = cwave > self:GetLastWave()
	if (self.lastEndWaveTriggered or 1) ~= cwave then
		self.lastEndWaveTriggered = cwave
		ROTGB_AddCash(100/self:GetSpawnDivider()*ROTGB_GetConVarValue("rotgb_cash_mul"))
		if not self.NoMessages then
			if inFreeplay and not self.WinWave then
				self.WinWave = cwave
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

function ENT:Think()
	if self.EnableBalloonChecking and self:GetNextWaveTime() <= CurTime() and SERVER and self:GetWave()>1 then
		if self:GetForceNextWave() then
			self.EnableBalloonChecking = nil
			self:SpawnNextWave()
		else
			if ROTGB_GetBalloonCount()==0 then
				self.EnableBalloonChecking = nil
				self:SpawnNextWave()
			end
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
end

-- this is disabled now, what was the point of this?
--[[hook.Add("PlayerInitialSpawn","RotgB",function(ply)
	ROTGB_SetCash(ROTGB_GetConVarValue("rotgb_starting_cash"), ply)
	for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
		if file.Exists("rotgb_wavedata/"..v:GetWaveFile()..".dat", "DATA") then
			local rawdata = util.JSONToTable(util.Decompress(file.Read("rotgb_wavedata/"..v:GetWaveFile()..".dat","DATA") or ""))
			if rawdata then
				local packetlength = 60000
				local textdata = file.Read("rotgb_wavedata/"..v:GetWaveFile()..".dat","DATA")
				local datablocks = math.ceil(#textdata/packetlength)
				for i=1,datablocks do
					net.Start("rotgb_generic")
					net.WriteUInt(ROTGB_OPERATION_WAVE_TRANSFER, 8)
					net.WriteString(v:GetWaveFile())
					net.WriteUInt(datablocks, 16)
					net.WriteUInt(i, 16)
					local datafrac = textdata:sub(packetlength*(i-1)+1, packetlength*i)
					net.WriteUInt(#datafrac, 16)
					net.WriteData(datafrac, #datafrac)
					net.Send(ply)
				end
			end
		end
	end
end)]]

local function DrawCircle(x,y,r,percent,...)
	local SEGMENTS = GetConVar("rotgb_circle_segments"):GetInt()
	local seoul = -360/SEGMENTS
	percent = math.Clamp(percent*SEGMENTS,0,SEGMENTS)
	local vertices = {{x=x,y=y}}
	local pi = math.pi
	for i=0,math.floor(percent) do
		local compx = x+math.sin(math.rad(i*seoul)+pi)*r
		local compy = y+math.cos(math.rad(i*seoul)+pi)*r
		table.insert(vertices,{x=compx,y=compy})
	end
	if math.floor(percent)~=percent then
		local compx = x+math.sin(math.rad(percent*seoul)+pi)*r
		local compy = y+math.cos(math.rad(percent*seoul)+pi)*r
		table.insert(vertices,{x=compx,y=compy})
	end
	draw.NoTexture()
	surface.SetDrawColor(...)
	surface.DrawPoly(vertices)
	table.insert(vertices,table.remove(vertices,1))
	surface.DrawPoly(table.Reverse(vertices))
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
	--if cwave <= self:GetLastWave() or ROTGB_GetConVarValue("rotgb_freeplay") then
		local text1 = "Next Wave: "..cwave
		local text2 = "RgBE: "..self:GetWaveTable()[cwave].rbe
		local text3 = "Press 'Use' on this entity to start the wave."
		surface.SetFont("DermaLarge")
		local t1x,t1y = surface.GetTextSize(text1)
		local t2x,t2y = surface.GetTextSize(text2)
		local t3x,t3y = surface.GetTextSize(text3)
		local panelw = math.max(t1x,t2x)
		local panelh = t1y+t2y
		cam.Start3D2D(self:GetPos()+Vector(0,0,GetConVar("rotgb_hoverover_distance"):GetFloat()+panelh*0.2+self:OBBMaxs().z),reqang,0.2)
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
			DrawCircle(0,panelh/-2-32,16,percent,HSVToColor(percent*120,1,1))
		cam.End3D2D()
	--[[else]]if self:GetNextWaveTime()>CurTime() then
		local percent = math.Clamp((self:GetNextWaveTime()-CurTime())/self:GetWaveDuration(cwave-1)*self:GetSpeedMul()+0.02,0,1)
		cam.Start3D2D(self:GetPos()+Vector(0,0,GetConVar("rotgb_hoverover_distance"):GetFloat()+draw.GetFontHeight("DermaLarge")*0.4+self:OBBMaxs().z),reqang,0.2)
			DrawCircle(0,-draw.GetFontHeight("DermaLarge")-32,16,percent,HSVToColor(percent*120,1,1))
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