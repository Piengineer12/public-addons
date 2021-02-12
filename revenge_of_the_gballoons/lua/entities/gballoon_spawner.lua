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

ROTGB_WAVES = {
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
		rbe=30--10*3
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
		rbe=1545--15*103
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
		rbe=2266--11*206
	},
	{ -- 40
		{"gballoon_blimp_blue"},
		duration=0,
		rbe=612
	},-- 40
	{
		{"gballoon_red",120,60},
		{"gballoon_orange",120,60,0.125},
		{"gballoon_yellow",120,60,0.25},
		{"gballoon_ceramic",6,60},
		duration=60.25,
		rbe=2538--120*(1+11+4)+6*103
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
		rbe=3660--5*612+600
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
		rbe=5136--290*11+58*23+612
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
		rbe=5709--75*11+15*103+15*11+75*4+15*22+150+3*612+6*93
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
		rbe=7080--30*103+30*133
	},-- 50
	{
		{"gballoon_ceramic",15,60},
		{"gballoon_ceramic",15,60},
		{"gballoon_ceramic",15,60},
		{"gballoon_ceramic",15,60},
		{"gballoon_ceramic",15,60},
		duration=60,
		rbe=7765--75*103
	},
	{
		{"gballoon_blimp_blue",10,60},
		{"gballoon_regen_gray",120,60},
		duration=60,
		rbe=8880--10*612+120*23
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
		rbe=10200--300*10+50*(133+11)
	},
	{ -- 55
		{"gballoon_blimp_blue",15,60},
		{"gballoon_white",60,60},
		{"gballoon_white",60,60},
		{"gballoon_fast_pink",120,60},
		{"gballoon_fast_yellow",120,60},
		duration=60,
		rbe=11580--120*(5+4)+60*22+15*612
	},-- 55
	{
		{"gballoon_brick",60,60},
		{"gballoon_regen_purple",120,60},
		{"gballoon_hidden_black",120,60},
		{"gballoon_hidden_white",120,60},
		{"gballoon_shielded_pink",120,60},
		duration=60,
		rbe=13140--120*(10+11+11+11)+60*133
	},
	{
		{"gballoon_shielded_white",240,60},
		{"gballoon_shielded_purple",120,60},
		{"gballoon_blimp_blue",10,20,40},
		duration=60,
		rbe=14040--240*22+120*22+10*612
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
		rbe=15690--300*11+60*4+30*266+30*6+30*133
	},
	{
		{"gballoon_blimp_blue",20,60},
		{"gballoon_blimp_blue",3,3,57},
		{"gballoon_blimp_blue",2,2,58},
		{"gballoon_blimp_blue",nil,nil,60},
		{"gballoon_blimp_blue",nil,nil,60},
		duration=60,
		rbe=16524--27*612
	},
	{ -- 60
		{"gballoon_blimp_red"},
		duration=0,
		rbe=3148
	},-- 60
	{
		{"gballoon_blimp_blue",10,60},
		{"gballoon_ceramic",120,60},
		duration=60,
		rbe=18480--120*103+10*612
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
		rbe=19950--150*133
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
		rbe=21630--(60+10*15)*103
	},
	{
		{"gballoon_blimp_blue",10,5},
		{"gballoon_blimp_blue",15,5,25},
		{"gballoon_blimp_blue",15,5,55},
		duration=60,
		rbe=24480--40*612
	},
	{ -- 65
		{"gballoon_brick",80,40},
		{"gballoon_ceramic",80,40,0.25},
		{"gballoon_blimp_blue",10,10,50},
		{"gballoon_blimp_blue",nil,nil,60},
		{"gballoon_blimp_blue",nil,nil,60},
		{"gballoon_blimp_blue",nil,nil,60},
		duration=60,
		rbe=26836--80*(133+103)+13*612
	},-- 65
	{
		{"gballoon_blimp_red",6,60},
		{"gballoon_blimp_red",3,60},
		{"gballoon_blimp_blue",nil,60},
		duration=60,
		rbe=28944--9*3148+612
	},
	{
		{"gballoon_blimp_blue",30,60},
		{"gballoon_blimp_blue",15,30,30},
		{"gballoon_blimp_blue",7,14,46},
		{"gballoon_blimp_blue",2,4,56},
		duration=60,
		rbe=33048--54*612
	},
	{
		{"gballoon_regen_shielded_ceramic",180,60},
		duration=60,
		rbe=37080--180*206
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
		rbe=40690--10*(3148+612)+30*103
	},
	{ -- 70
		{"gballoon_ceramic",100,20},
		{"gballoon_brick",100,20,20},
		{"gballoon_marble",100,20,40},
		duration=60,
		rbe=42900--100*(103+133+193)
	},-- 70
	{
		{"gballoon_blimp_red",10,60},
		{"gballoon_blimp_red",5,60},
		duration=60,
		rbe=47220--15*3148
	},
	{
		{"gballoon_fast_hidden_regen_shielded_ceramic",120,60},
		{"gballoon_blimp_blue",20,60},
		{"gballoon_blimp_blue",20,60},
		duration=60,
		rbe=49200--120*206+40*612
	},
	{
		{"gballoon_shielded_marble",60,60},
		{"gballoon_shielded_brick",60,60},
		{"gballoon_shielded_ceramic",60,60},
		duration=60,
		rbe=51480--60*(103+133+193)*2
	},
	{
		{"gballoon_fast_hidden_regen_shielded_orange",120,60},
		{"gballoon_blimp_red",15,60},
		{"gballoon_blimp_blue",15,60},
		duration=60,
		rbe=59040--120*22+15*3148+15*612
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
		rbe=63690--330*193
	},-- 75
	{
		{"gballoon_blimp_red",6,60},
		{"gballoon_blimp_red",6,60},
		{"gballoon_blimp_red",6,60},
		{"gballoon_blimp_red",6,60},
		duration=60,
		rbe=75552--24*3148
	},
	{
		{"gballoon_blimp_blue",120,60},
		{"gballoon_ceramic",60,60},
		duration=60,
		rbe=79620--120*612+60*103
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
		rbe=87088--16*3148+60*612
	},
	{
		{"gballoon_shielded_marble",240,60},
		duration=60,
		rbe=92640--240*386
	},
	{ -- 80
		{"gballoon_blimp_green"},
		duration=0,
		rbe=16592
	},-- 80
	{
		{"gballoon_blimp_blue",120,60},
		{"gballoon_blimp_blue",60,60},
		duration=60,
		rbe=110160--180*612
	},
	{
		{"gballoon_blimp_red",30,60},
		{"gballoon_marble",120,60},
		duration=60,
		rbe=117600--120*193+30*3148
	},
	{
		{"gballoon_blimp_blue",20,20},
		{"gballoon_blimp_red",10,20,20},
		{"gballoon_blimp_green",5,20,40},
		duration=60,
		rbe=126680--20*612+10*3148+5*16592
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
		rbe=134304--24*(4*612+3148)
	},
	{ -- 85
		{"gballoon_blimp_green",6,60},
		{"gballoon_blimp_green",3,60},
		duration=60,
		rbe=149328--9*16592
	},-- 85
	{
		{"gballoon_blimp_red",30,60},
		{"gballoon_blimp_blue",60,60},
		{"gballoon_blimp_blue",30,60},
		{"gballoon_blimp_blue",15,60},
		duration=60,
		rbe=158700--30*3148+105*612
	},
	{
		{"gballoon_blimp_red",30,30},
		{"gballoon_blimp_blue",120,30,30},
		duration=60,
		rbe=167880--120*612+30*3148
	},
	{
		{"gballoon_blimp_green",10,60},
		{"gballoon_blimp_green"},
		duration=60,
		rbe=182512--11*16592
	},
	{
		{"gballoon_blimp_blue",300,60},
		duration=60,
		rbe=183600--300*612
	},
	{ -- 90
		{"gballoon_fast_hidden_regen_shielded_blimp_gray"},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",100,50,10},
		duration=60,
		rbe=196344--101*1944
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
		rbe=206721--9*(1944+16592+3148+612+193+133+103+93+23*4+11*4+15)
	},
	{
		{"gballoon_blimp_blue",60,60},
		{"gballoon_blimp_blue",30,60,0.25},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",60,60,0.5},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",30,60,0.75},
		duration=60,
		rbe=230040--90*612+90*1944
	},
	{
		{"gballoon_blimp_green",6,60},
		{"gballoon_blimp_green",6,60},
		{"gballoon_blimp_green"},
		{"gballoon_blimp_green"},
		duration=60,
		rbe=232288--14*16592
	},
	{
		{"gballoon_blimp_green",15,60},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",15,60},
		duration=60,
		rbe=278040--15*(1944+16592)
	},
	{ -- 95
		{"gballoon_blimp_blue",14,7,13},
		{"gballoon_green",120,60},
		{"gballoon_blue",40,20},
		{"gballoon_red",80,40},
		{"gballoon_blimp_red",14,7,33},
		{"gballoon_blimp_green",14,7,53},
		duration=60,
		rbe=285448--14*(612+3148+16592)+120*3+40*2+80
	},-- 95
	{
		{"gballoon_blimp_red",60,60},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",30,60},
		{"gballoon_marble",240,60},
		duration=60,
		rbe=293520--60*(1944/2+3148+193*4)
	},
	{
		{"gballoon_blimp_green",15,30},
		{"gballoon_blimp_red",15,60},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",15,15,45},
		duration=60,
		rbe=325260--15*(1944+16592+3148)
	},
	{
		{"gballoon_blimp_green",20,60},
		{"gballoon_shielded_marble",6,nil,60},
		{"gballoon_shielded_marble",6,nil,60},
		{"gballoon_shielded_marble",6,nil,60},
		{"gballoon_shielded_marble",6,nil,60},
		{"gballoon_shielded_marble",6,nil,60},
		duration=60,
		rbe=343420--20*16592+30*386
	},
	{
		{"gballoon_blimp_blue",30,15},
		{"gballoon_blimp_red",15,15,15},
		{"gballoon_blimp_green",15,15,30},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",30,15,45},
		duration=60,
		rbe=372780--30*612+15*3148+15*16592+30*1944
	},
	{ -- 100
		{"gballoon_blimp_purple"},
		duration=0,
		rbe=57072
	},-- 100
	{
		{"gballoon_blimp_green",15,60},
		{"gballoon_blimp_green",10,60},
		{"gballoon_blimp_green",2,60},
		duration=60,
		rbe=447984--27*16592
	},
	{
		{"gballoon_blimp_red",60,60},
		{"gballoon_blimp_red",20,60},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",120,60,0.25},
		duration=60.25,
		rbe=485120--120*1944+80*3148
	},
	{
		{"gballoon_blimp_green",30,30},
		{"gballoon_blimp_red",10,30,15},
		{"gballoon_blimp_blue",3,30,30},
		duration=60,
		rbe=531076--30*16592+10*3148+3*612
	},
	{
		{"gballoon_blimp_red",20,60},
		{"gballoon_blimp_green",20,60,1},
		{"gballoon_blimp_blue",20,60,2},
		{"gballoon_blimp_red",8,48,10},
		{"gballoon_blimp_green",8,48,11},
		{"gballoon_blimp_blue",8,48,12},
		duration=60,
		rbe=569856--28*(16592+3148+612)
	},
	{ -- 105
		{"gballoon_blimp_red",180,60},
		{"gballoon_blimp_red",17,nil,60},
		duration=60,
		rbe=620156--197*3148
	},-- 105
	{
		{"gballoon_blimp_green",30,60},
		{"gballoon_blimp_green",10,60},
		duration=60,
		rbe=663680--40*16592
	},
	{
		{"gballoon_blimp_red",240,60},
		duration=60,
		rbe=755520--240*3148
	},
	{
		{"gballoon_blimp_red",10,60},
		{"gballoon_blimp_green",10,60},
		{"gballoon_blimp_purple",10,60},
		duration=60,
		rbe=768120--10*(16592+57072+3148)
	},
	{
		{"gballoon_blimp_red",60,30},
		{"gballoon_blimp_blue",180,30},
		{"gballoon_blimp_purple",10,30,30},
		duration=60,
		rbe=869760--180*612+60*3148+10*57072
	},
	{ -- 110
		{"gballoon_fast_blimp_magenta",60,60},
		{"gballoon_fast_blimp_magenta",20,20,40},
		{"gballoon_fast_blimp_magenta",20,20,40},
		duration=60,
		rbe=927600--100*9276
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
		rbe=1000000--15*57072+6*16592+10*3148+20*612+6*103+23+5+2
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
		rbe=1083872--40*(16592+1944)+6*57072
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
		rbe=1234567--20*57072+5*16592+3*3148+612+103+5+3
	},
	{
		{"gballoon_fast_blimp_magenta",120,60},
		{"gballoon_fast_hidden_regen_shielded_blimp_gray",120,60},
		duration=60,
		rbe=1346400--120*(9276+1944)
	},
	{ -- 115
		{"gballoon_blimp_purple",5,60},
		{"gballoon_blimp_purple",5,60},
		{"gballoon_blimp_purple",5,60},
		{"gballoon_blimp_purple",5,60},
		{"gballoon_blimp_purple",5,60},
		duration=60,
		rbe=1426800--25*57072
	},-- 115
	{
		{"gballoon_fast_blimp_magenta",180,60},
		duration=60,
		rbe=1669680--180*9276
	},
	{
		{"gballoon_blimp_purple",30,60},
		duration=60,
		rbe=1712160--30*57072
	},
	{
		{"gballoon_blimp_green",120,60},
		duration=60,
		rbe=1991040--120*16592
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
		rbe=2464825--25*(9276*2+57072+1944+16592+3148+612+193+133+103+93+23*4+11*4+15)
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
		rbe=7056745--232695+50*(9276+57072+1944+16592+3148+612+193*2+133*2+103*2+93*2+23*4*2+11*4+14)+600+10*232695
	}
}

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

ROTGB_WAVES_10S = {
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

ROTGB_CUSTOM_WAVES = {["?RAMP"]=ROTGB_WAVES_RAMP, ["?10S"]=ROTGB_WAVES_10S}

function ENT:GetWaveDuration(wave)
	return (self:GetWaveTable()[wave] or {}).duration or 0
	--[[if wave>120 then return 60
	elseif wave < 40 then return math.ceil(wave/4)*5+5
	elseif wave==120 then return 300
	elseif wave==119 then return 120
	elseif wave%20==0 then return 0
	else return 60
	end]]
end

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"Wave",{KeyName="start_wave",Edit={title="Wave To Spawn",type="Int",min=1,max=120,order=1}})
	self:NetworkVar("Bool",0,"AutoStart",{KeyName="auto_start",Edit={title="Auto-Start",type="Boolean",order=3}})
	self:NetworkVar("Bool",1,"ForceNextWave",{KeyName="force_next",Edit={title="Force Auto-Start",type="Boolean",order=5}})
	self:NetworkVar("Bool",2,"StartAll",{KeyName="start_all",Edit={title="Start All Others",type="Boolean",order=6}})
	self:NetworkVar("Float",0,"AutoStartDelay",{KeyName="auto_start_delay",Edit={title="Auto-Start Delay",type="Float",min=0,max=60,order=4}})
	self:NetworkVar("Float",1,"SpeedMul",{KeyName="spawn_speed_mul",Edit={title="Spawn Rate",type="Float",min=0.1,max=10,order=2}})
	self:NetworkVar("Float",2,"NextWaveTime")
	self:NetworkVar("String",0,"WaveFile",{KeyName="wave_file",Edit={title="Custom Wave Name",type="Generic",order=7}})
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
	if lkey=="start_wave" then
		self:SetWave(tonumber(value) or 1)
	--[[elseif lkey=="auto_start" then
		self:SetAutoStart(tobool(value))]]
	elseif lkey=="no_auto_start" then
		self.NoAutoStart = true
	elseif lkey=="force_next" then
		self:SetForceNextWave(tobool(value))
	elseif lkey=="auto_start_delay" then
		self:SetAutoStartDelay(tonumber(value) or 0)
	elseif lkey=="spawn_speed_mul" then
		self:SetSpeedMul(tonumber(value) or 1)
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
	if input=="setautostart" then
		self:SetAutoStart(tobool(data))
	elseif input=="setforcenext" then
		self:SetForceNextWave(tobool(data))
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

local notifshown
local gBalloonTable = baseclass.Get("gballoon_base")

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
		self:SetWave(self:GetWave()>0 and self:GetWave() or 1)
		self:SetSpeedMul(self:GetSpeedMul()>0 and self:GetSpeedMul() or 1)
		self:SetModel(self.Model or "models/props_c17/streetsign004e.mdl")
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
	end
end

function ENT:PostEntityPaste(ply,ent,tab)
	ent:Spawn()
	ent:Activate()
end

function ENT:Use(activator)
	--if input:lower()=="balloon_start_wave" then
		if (IsValid(activator) and activator:GetClass()~="gballoon_spawner" and self:GetStartAll()) then
			for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
				v:Use(self,self,USE_ON,1)
			end
		end
		if self:GetNextWaveTime()>CurTime() or not self:GetForceNextWave() and gBalloonTable:GetgBalloonCount()>0 then
			ROTGB_AddCash(100*GetConVar("rotgb_cash_mul"):GetFloat())
		end
		self:SetNWBool("HasShownUsage",true)
		local cwave = self:GetWave() or 1
		if not self:GetWaveTable()[cwave] and GetConVar("rotgb_freeplay"):GetBool() then
			self:GenerateNextWave(cwave)
		end
		self:SetNextWaveTime(CurTime()+self:GetWaveDuration(cwave)/self:GetSpeedMul())
		local trigent = ents.FindByName("wave_start_relay")[1]
		if IsValid(trigent) and not tobool(self.DontTriggerWaveRelays) then
			if not trigent.RotgB_HasFired then
				trigent:Fire("Trigger")
				trigent.RotgB_HasFired = true
			elseif trigent.RotgB_HasFired and not self:GetWaveTable()[cwave] then
				trigent.RotgB_HasFired = nil
				trigent = ents.FindByName("wave_finished_relay")[1]
				if IsValid(trigent) then
					trigent:Fire("Trigger")
				end
			end
		end
		self:TriggerOutput("OnWaveStart",activator,cwave)
		if not self.NoMessages then
			if (not self:GetWaveTable()[cwave] or self:GetWaveTable()[cwave].unnatural) and not self.WinMessage then
				self.WinMessage = true
				PrintMessage(HUD_PRINTTALK,"All standard waves cleared! Congratulations, you win!")
				PrintMessage(HUD_PRINTTALK,"If you want a harder challenge, try doubling the gBalloons' health, spawn rate or halving the cash multiplier.")
				if GetConVar("rotgb_freeplay"):GetBool() then
					PrintMessage(HUD_PRINTTALK,"BEWARE! The gBalloons become exponentially faster and faster after each wave!")
				end
			end
			if (self:GetWaveTable()[cwave] and not self:GetWaveTable()[cwave].unnatural) or GetConVar("rotgb_freeplay"):GetBool() then
				PrintMessage(HUD_PRINTTALK,"Wave "..cwave.." started!")
			end
		end
		if not (self:GetWaveTable()[cwave] and not self:GetWaveTable()[cwave].unnatural) and not GetConVar("rotgb_freeplay"):GetBool() then return self:Remove() end
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
						--if gBalloonTable:GetgBalloonCount() < GetConVar("rotgb_max_to_exist"):GetInt() then
							local SpawnPos = self:GetPos()+Vector(0,0,10)
							local bln = ents.Create("gballoon_base")
							if IsValid(bln) then
								bln:SetPos(SpawnPos)
								for k,v in pairs(list.GetForEdit("NPC")[balloontype].KeyValues) do
									bln:SetKeyValue(k,v)
								end
								bln:Spawn()
								bln:Activate()
								--[[if IsValid(self:GetNextTarget()) then
									self:SetNextTarget1(self:GetNextTarget())
									self:SetNextTarget(NULL)
								end]]
								local nextTargs = {}
								if bln:GetBalloonProperty("BalloonBlimp") then
									for i=1,16 do
										local gTarg = self["GetNextBlimpTarget"..i](self)
										if IsValid(gTarg) then
											table.insert(nextTargs,gTarg)
										end
									end
								end
								if next(nextTargs) then
									bln:SetTarget(nextTargs[math.random(#nextTargs)])
								else
									for i=1,16 do
										local gTarg = self["GetNextTarget"..i](self)
										if IsValid(gTarg) then
											table.insert(nextTargs,gTarg)
										end
									end
									if next(nextTargs) then
										bln:SetTarget(nextTargs[math.random(#nextTargs)])
									end
								end
								--timer.Simple(0,function()
									if bln.loco then
										bln.loco:SetAcceleration(bln.loco:GetAcceleration()*1.02^math.max(0,cwave-120))
									end
								--end)
							end
						--[[else
							self:SetNextWaveTime(self:GetNextWaveTime()+1)
							timer.Pause(timername)
							timer.Simple(1,function()
								timer.UnPause(timername)
							end)
						end]]
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
	local gballoon_base = baseclass.Get("gballoon_base")
	local choices = {"gballoon_blimp_blue","gballoon_blimp_red","gballoon_blimp_green","gballoon_fast_hidden_regen_shielded_blimp_gray","gballoon_blimp_purple","gballoon_fast_blimp_magenta","gballoon_blimp_rainbow"}
	local factors = {120,60,40,30,24,20,15,12,10,8,6,5,4,3,2,1}
	while true do
		if trbe > (self:GetWaveTable()[cwave-1].assumerbe or self:GetWaveTable()[cwave-1].rbe) then break end
		local genval = util.SharedRandom("ROTGB_WAVEGEN_"..self:GetWaveFile().."_"..cwave,0,7,trbe)
		local choice = choices[math.floor(genval)+1]
		local crbe = gballoon_base.rotgb_rbetab[choice]
		local amount = math.Clamp((erbe-trbe)/crbe,1,120)
		for i,v in ipairs(factors) do
			if amount>=v then amount=v break end
		end
		table.insert(wavetab,{choice,amount,60})
		trbe = trbe + crbe * amount
	end
	wavetab.rbe = math.Round(trbe)
	wavetab.duration = 60
	wavetab.unnatural = true
	self:GetWaveTable()[cwave] = wavetab
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
	ROTGB_AddCash(100*GetConVar("rotgb_cash_mul"):GetFloat())
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
			if gBalloonTable:GetgBalloonCount()==0 then
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
					net.WriteString("wave_transfer")
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
		--PrintTable(ROTGB_CLIENTWAVES[self:GetWaveFile()])
		if ROTGB_CUSTOM_WAVES[self:GetNWString("rotgb_validwave")] then
			self.CustomWaveName = self:GetNWString("rotgb_validwave")
		elseif ((ROTGB_CLIENTWAVES[self:GetWaveFile()] or {})[1] or {}).rbe then
			self.CustomWaveName = self:GetNWString("rotgb_validwave")
			self.CustomWaveData = ROTGB_CLIENTWAVES[self:GetWaveFile()]
		end
	end
end

hook.Add("PlayerSpawn","RotgB",function(ply)
	ply.ROTGB_CASH = GetConVar("rotgb_starting_cash"):GetFloat()
	for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
		if file.Exists("rotgb_wavedata/"..v:GetWaveFile()..".dat", "DATA") then
			local rawdata = util.JSONToTable(util.Decompress(file.Read("rotgb_wavedata/"..v:GetWaveFile()..".dat","DATA") or ""))
			if rawdata then
				local packetlength = 60000
				local textdata = file.Read("rotgb_wavedata/"..v:GetWaveFile()..".dat","DATA")
				local datablocks = math.ceil(#textdata/packetlength)
				for i=1,datablocks do
					net.Start("rotgb_generic")
					net.WriteString("wave_transfer")
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
end)

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
	self:Draw()
	--self:DrawModel()
	if not self:GetWaveTable()[self:GetWave()] and GetConVar("rotgb_freeplay"):GetBool() then
		self:GenerateNextWave(self:GetWave())
	end
	if self:GetWaveTable()[self:GetWave()] then
		local cwave = self:GetWave()
		local text1 = "Next Wave: "..cwave
		local text2 = "RgBE: "..self:GetWaveTable()[cwave].rbe
		local text3 = "Press 'Use' on this entity to start the wave."
		surface.SetFont("DermaLarge")
		local t1x,t1y = surface.GetTextSize(text1)
		local t2x,t2y = surface.GetTextSize(text2)
		local t3x,t3y = surface.GetTextSize(text3)
		local panelw = math.max(t1x,t2x)
		local panelh = t1y+t2y
		local reqang = (self:GetPos()-LocalPlayer():GetShootPos()):Angle()
		reqang.p = 0
		reqang.y = reqang.y-90
		reqang.r = 90
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
	elseif self:GetNextWaveTime()>CurTime() then
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