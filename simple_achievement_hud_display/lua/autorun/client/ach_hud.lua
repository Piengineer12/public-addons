local ConE = CreateClientConVar("achievement_hud_enabled","1",true,false,"Enables or disables the achievement HUD display.")
local ConX = CreateClientConVar("achievement_hud_x_pos","0",true,false,"Sets the horizontal position of the HUD.")
local ConY = CreateClientConVar("achievement_hud_y_pos","0.1",true,false,"Sets the vertical position of the HUD.")
local ConS = CreateClientConVar("achievement_hud_spacing","20",true,false,"Sets the spacing between achievements.")
local ConM = CreateClientConVar("achievement_hud_max","5",true,false,"Sets the maximum number of achievements to show.")
local ConC = CreateClientConVar("achievement_hud_sorting_method","1",true,false,"Determines the sorting method.\n - 0: Sort by ID\n - 1: Sort by difficulty\n - 2: Sort by progress")
local ConA = CreateClientConVar("achievement_hud_opacity","255",true,false,"Sets translucency of the HUD.")
local ConG = CreateClientConVar("achievement_hud_align","0",true,false,"Sets the drawing method of the HUD.\n - 1: Invert horizontally\n - 2: Invert vertically\n - 3: Invert horizontally and vertically")
local ConP = CreateClientConVar("achievement_hud_show_plus","1",true,false,"Shows progression towards the achievement during the session.")
local ConO = CreateClientConVar("achievement_hud_show_colors","1",true,false,"Sets whether achievements are colored or not. Also enables difficulty text.\n - 0: All white\n - 1: Default Colors\n - 2: Custom Colors")
local achdata = {}

local difficulties = {
	--[[
	Achievement IDs, in order:
	1: Play Singleplayer
	2: Play Multiplayer
	3: Startup Millenium
	4: Secret Phrase
	5: Addict
	6: Map Loader
	7: Play Around
	8: War Zone
	9: Friendly
	10: Yes, I am the real garry!
	11: Marathon
	12: One Day
	13: One Week
	14: One Month
	15: Half Marathon
	16: Innocent Bystander
	17: Bad Friend
	18: Ball Eater
	19: Creator
	20: Popper
	21: Destroyer
	22: Menu User
	23: Bad Coder
	24: Procreator
	25: Dollhouse
	26: 10 Thumbs
	27: 100 Thumbs
	28: 1000 Thumbs
	29: Mega Upload
	]]
	-- Easy, Medium, Hard, Insane, Impossible
	1,1,4,2,5,
	2,1,2,3,5,
	4,2,3,4,3,
	3,2,2,3,3,
	2,4,1,2,3,
	2,3,4,5
}

local difficultyColors = {
	Color(127,255,127),
	Color(255,255,127),
	Color(255,127,127),
	Color(255,127,255),
	Color(255,255,255),
	Color(127,127,127)
}

local difficultyNames = {"Easy","Medium","Hard","Insane","Impossible","Undefined"}

-- Some achievements that SHOULD have progress bars

local upvotes = 0
local upvotes2 = 0
local highvotes = 0
local highvotes2 = 0
local firstrefresh = true
local firstrefresh2 = true
local Nextrefresh = RealTime() + 5
local retrieved = 0
local function CheckUpvotes()
	if Nextrefresh > RealTime() then
		if retrieved == 0 then
			if upvotes2 ~= 0 then
				upvotes = upvotes2
				upvotes2 = 0
				if firstrefresh then
					for k,v in pairs(achdata) do -- only run once
						if v.ID == 3026 or v.ID == 3027 or v.ID == 3028 then
							v.OldCount = upvotes
						end
					end
					firstrefresh = false
				end
			elseif highvotes2 ~= 0 then
				highvotes = highvotes2
				highvotes2 = 0
				if firstrefresh2 then
					for k,v in pairs(achdata) do -- only run once
						if v.ID == 3029 then
							v.OldCount = highvotes
						end
					end
					firstrefresh2 = false
				end
			end
		end
	else
		upvotes2 = 0
		highvotes2 = 0
		steamworks.GetList("",nil,0,1000,30,1,function(hugetable)
			if hugetable then
				retrieved = #hugetable.results
				for k,v in pairs(hugetable.results) do
					steamworks.FileInfo(v,function(votetable)
						if votetable then
							upvotes2 = upvotes2 + votetable.up
							highvotes2 = math.max(votetable.up,highvotes2)
							retrieved = retrieved - 1
						end
					end)
				end
			end
		end)
		Nextrefresh = RealTime() + 10
	end
end
CheckUpvotes()

local GetCount1 = {}

local serverAchs = serverAchs or {}

local function RecheckAchs()
	GetCount1 = {}
	--print("Divider")
	--achdata = {}
	for i=1,achievements.Count()-1 do
		if not achievements.IsAchieved(i) then
			table.insert(achdata,{
				ID=i+3000,
				Name=achievements.GetName(i),
				Desc=achievements.GetDesc(i),
				Goal=achievements.GetGoal(i),
				OldCount=achievements.GetCount(i),
				GetCount=function()
					return achievements.GetCount(i)
				end,
				Diff=difficulties[i]
			})
		end
	end
	local IDStr = 2001
	if istable(SimpleAchievements) then
		for k,v in pairs(SimpleAchievements.Achievements or {}) do
			if istable(v) then
				local localTable = {}
				localTable.ID = IDStr
				IDStr = IDStr + 1
				localTable.Name = v.Name and "(Unofficial) "..v.Name
				localTable.Desc = v.Desc
				localTable.Diff = v.Diff
				localTable.Goal = v.GoalCount
				localTable.GetCount = CompileString(v.CountFunction,"CountFunction")
				localTable.OldCount = isfunction(localTable.GetCount) and localTable.GetCount() or 0
				--PrintTable(localTable)
				if localTable.OldCount < localTable.Goal then
					table.insert(achdata,localTable)
				end
			end
		end
	end
	IDStr = 1001
	for k,v in pairs(serverAchs) do
		if istable(v) then
			local localTable = {}
			localTable.ID = IDStr
			IDStr = IDStr + 1
			localTable.Name = v.Name and "(Unofficial) "..v.Name
			localTable.Desc = v.Desc
			localTable.Diff = v.Diff
			localTable.Goal = v.GoalCount
			localTable.GetCount = CompileString(v.CountFunction,"CountFunction")
			localTable.OldCount = isfunction(localTable.GetCount) and localTable.GetCount() or 0
			if localTable.OldCount < localTable.Goal then
				table.insert(achdata,localTable)
			end
		end
	end
	for k,v in pairs(achdata) do
		if not v.ID then v.ID = 0 end
		if not isstring(v.Name) then v.Name = "Unnamed Achievement" end
		if not isstring(v.Desc) then v.Desc = "No description provided" end
		if not isnumber(v.Goal) then v.Goal = 1 end
		if not isnumber(v.Diff) then v.Diff = 6 end
		if not isfunction(v.GetCount) then v.GetCount = function() return 0 end end
		if not isnumber(v.OldCount) then v.OldCount = v.GetCount() or 0 end
		if v.ID == 3015 then
			v.Goal = 240
			v.OldCount = math.floor(RealTime()/60)
			v.GetCount = function()
				return math.floor(RealTime()/60)
			end
		elseif v.ID == 3011 then
			v.Goal = 480
			v.OldCount = math.floor(RealTime()/60)
			v.GetCount = function()
				return math.floor(RealTime()/60)
			end
		elseif v.ID == 3012 then
			v.Goal = 1440
			v.OldCount = achievements.GetCount(5)
			v.GetCount = function()
				return achievements.GetCount(5)
			end
		elseif v.ID == 3013 then
			v.Goal = 10080
			v.OldCount = achievements.GetCount(5)
			v.GetCount = function()
				return achievements.GetCount(5)
			end
		elseif v.ID == 3014 then
			v.Goal = 43829
			v.OldCount = achievements.GetCount(5)
			v.GetCount = function()
				return achievements.GetCount(5)
			end
		elseif v.ID == 3026 then
			v.Goal = 10
			v.OldCount = upvotes
			v.GetCount = function()
				CheckUpvotes()
				return upvotes
			end
		elseif v.ID == 3027 then
			v.Goal = 100
			v.OldCount = upvotes
			v.GetCount = function()
				CheckUpvotes()
				return upvotes
			end
		elseif v.ID == 3028 then
			v.Goal = 1000
			v.OldCount = upvotes
			v.GetCount = function()
				CheckUpvotes()
				return upvotes
			end
		elseif v.ID == 3029 then
			v.Goal = 1000
			v.OldCount = highvotes
			v.GetCount = function()
				CheckUpvotes()
				return highvotes
			end
		elseif v.ID == 3004 then
			v.Desc = achievements.GetDesc(4) --This line used to contain the phrase. It's gone now.
		elseif v.ID == 3009 then
			v.Goal = 10
			v.GetCount = function()
				local plys = 0
				for k,v in pairs(player.GetHumans()) do
					if v:GetFriendStatus() == "friend" then
						plys = plys + 1
					end
				end
				return plys
			end
		end
		--print(v.ID,isfunction(GetCount1[v.ID]))
		if GetCount1[v.ID] then achdata[k] = nil
		else GetCount1[v.ID] = v.GetCount end -- install functions via ID for simplicity and perf
	end
	-- Table is not sequential yet
	achdata = table.ClearKeys(achdata)
	--PrintTable(achdata)
	-- Phase 1
	--[[table.sort(achdata,function(a,b)
		return a.__key < b.__key
	end)]]
	-- Phase 2
	table.sort(achdata,function(a,b)
		if not (istable(a) and istable(b)) then return end
		if ConC:GetInt()==1 then
			local firstd = a.Diff or 6
			local second = b.Diff or 6
			if firstd ~= second then
				return firstd < second
			else
				firstd = a.ID or 0
				second = b.ID or 0
				return firstd < second
			end
		elseif ConC:GetInt()==2 then
			local firstd, second = 0,0
			if isfunction(a.GetCount) and isnumber(a.Goal) then
				firstd = a.GetCount()/a.Goal
			end
			if isfunction(b.GetCount) and isnumber(b.Goal) then
				second = b.GetCount()/b.Goal
			end
			if firstd ~= second then
				return firstd > second
			else
				firstd = a.Diff or 6
				second = b.Diff or 6
				if firstd ~= second then
					return firstd < second
				else
					firstd = a.ID or 0
					second = b.ID or 0
					return firstd < second
				end
			end
		else
			local firstd = a.ID or 0
			local second = b.ID or 0
			return firstd < second
		end
	end)
end
RecheckAchs()

local function GetCount2(id)
	if not id then return 0 end
	local toRun = GetCount1[id]
	if toRun and id ~= 0 then
		return toRun() or 0
	else
		return 0
	end
end

net.Receive("SimpleCustomAchievements",function()
	serverAchs = net.ReadTable()
	--[[local colors = net.ReadTable()
	if #colors > 0 then
		table.Merge(difficultyColors,colors)
	end
	local names = net.ReadTable()
	if #names > 0 then
		table.Merge(difficultyNames,names)
	end]]
	RecheckAchs()
end)

cvars.AddChangeCallback("achievement_hud_sorting_method",RecheckAchs,"SimpleAchievementHUD")

hook.Add("AddToolMenuCategories", "SimpleAchievementHUD", function() -- Add category
	spawnmenu.AddToolCategory("Utilities", "SimpleAchievementHUD", "Achievement HUD")
end)

hook.Add("PopulateToolMenu", "SimpleAchievementHUD", function() -- Add option
	spawnmenu.AddToolMenuOption("Utilities", "SimpleAchievementHUD", "Options", "Options", "", "", function(DForm) -- Add panel
		DForm:Help("") --whitespace
		DForm:ControlHelp("Simple Achievement HUD")
		DForm:CheckBox("Enable","achievement_hud_enabled")
		DForm:NumSlider("X-Position","achievement_hud_x_pos",0,1,3)
		DForm:NumSlider("Y-Position","achievement_hud_y_pos",0,1,3)
		DForm:NumberWang("Align","achievement_hud_align",0,3)
		DForm:Help("0 - No inversion\n1 - Invert horizontally\n2 - Invert vertically\n3 - Invert horizontally and vertically")
		DForm:NumSlider("Max To Show","achievement_hud_max",0,30,0)
		DForm:NumSlider("Space Between Achievements","achievement_hud_spacing",0,200,0)
		DForm:NumberWang("Sorting Method","achievement_hud_sorting_method",0,2)
		DForm:Help("0 - By ID\n1 - By Difficulty\n2 - By Progress")
		DForm:CheckBox("Show Difficulty","achievement_hud_show_colors")
		DForm:CheckBox("Show Progression","achievement_hud_show_plus")
		DForm:NumSlider("Visibility","achievement_hud_opacity",0,255,0)
	end)
end)

hook.Add("OnAchievementAchieved","SimpleAchievementHUD",function(ply,id)
	local toStore
	if ply == LocalPlayer() then
		for k,v in pairs(achdata) do
			if v.ID == id then
				toStore = k
			end
		end
	end
	if toStore then
		table.remove(achdata,toStore)
	end
	RecheckAchs()
end)

hook.Add("SimpleCustomAchieved","SimpleAchievementHUD",function(ply,id)
	local toStore
	if ply == LocalPlayer() then
		for k,v in pairs(achdata) do
			if v.ID == id then
				toStore = k
			end
		end
	end
	if toStore then
		table.remove(achdata,toStore)
	end
	RecheckAchs()
end)

local nextCheck = RealTime()

hook.Add("HUDPaint","SimpleAchievementHUD",function()
	if ConC:GetInt()==2 and nextCheck <= RealTime() then
		RecheckAchs()
		nextCheck = RealTime() + 1
	end
	if ConE:GetBool() then
		local x2 = ScrW()*ConX:GetFloat()
		local y2 = ScrH()*ConY:GetFloat()
		local spaceY = ConS:GetInt()
		local alignVal = ConG:GetInt()
		local borderX = ScrW()/10
		local borderY = 5
		local count = 1
		local alignX = bit.band(alignVal,1)==1 and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT
		local alignY = bit.band(alignVal,2)==2 and TEXT_ALIGN_BOTTOM or TEXT_ALIGN_TOP
		local align_Y = bit.band(alignVal,2)==2 and TEXT_ALIGN_TOP or TEXT_ALIGN_BOTTOM
		local plX = bit.band(alignVal,1)==1 and 1 or 0
		local pl_X = bit.band(alignVal,1)==1 and -1 or 1
		local plY = bit.band(alignVal,2)==2 and -1 or 1
		local pl_Y = bit.band(alignVal,2)==2 and 1 or 0
		local maxcount = ConM:GetInt()
		for i,v in ipairs(achdata) do
			if count > maxcount then break end
			if v then
				local from = v.OldCount
				local color = ColorAlpha(ConO:GetInt()==1 and difficultyColors[v.Diff] or color_white,ConA:GetInt())
				local dispX, dispY = draw.SimpleText(v.Name..(ConO:GetBool() and " ("..difficultyNames[v.Diff]..")" or ""),"HudHintTextLarge",x2,y2,color,alignX,alignY)
				y2 = y2 + dispY*plY
				dispX, dispY = draw.SimpleText(v.Desc,"HudHintTextSmall",x2,y2,color,alignX,alignY)
				y2 = y2 + dispY*plY
				local mins = math.min(GetCount2(v.ID),v.Goal)
				local maxs = v.Goal
				if maxs > 1 then
					local prog = mins/maxs
					surface.SetDrawColor(0,0,0,ConA:GetInt())
					surface.DrawRect(x2-borderX*plX+borderX*prog*(1-plX),y2-borderY*pl_Y,borderX*(1-prog),borderY)
					surface.SetDrawColor(color)
					surface.DrawRect(x2-(borderX-borderX*(1-prog))*plX,y2-borderY*pl_Y,borderX*prog,borderY)
					y2 = y2 + borderY*plY
					dispX, dispY = draw.SimpleText(mins.." / "..maxs.." ("..math.floor(prog*10000)/100 .."%)","Trebuchet18",x2,y2,color,alignX,alignY)
					y2 = y2 + dispY*plY
					if mins-from > 0 and ConP:GetBool() then
						draw.SimpleText("+"..mins-from,"Trebuchet24",x2+(borderX+borderY)*pl_X,y2,color,alignX,align_Y)
					end
				end
				y2 = y2 + spaceY*plY
				count = count + 1
			end
		end
	end
end)