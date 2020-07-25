AddCSLuaFile()

if not PS then return end
if PS.Config.DataProvider == 'mysql' then require('mysqloo') end

ENT.Model			= "models/props_c17/cashregister01a.mdl"
ENT.BankStorage 	= ENT.BankStorage or {}
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Bank"
ENT.Author			= "RandomTNT"
ENT.Contact			= "http://steamcommunity.com/id/RandomTNT12/"
ENT.Purpose			= "Store cash inside it!"
ENT.Instructions	= "Press 'Use' to open up the menu."
ENT.Category		= "Pointshop"
ENT.Spawnable		= true
ENT.AdminOnly		= false

BankStorage = BankStorage or {}

if SERVER then
	local database
	util.AddNetworkString("OpenBankMenu")
	util.AddNetworkString("BankInput")
	util.AddNetworkString("BankInputModel")
	util.AddNetworkString("VerifyPointshop")
	--resource.AddFile("materials/vgui/entities/ps_bank.vmt")
		-- The above just wastes space at this point.
	if mysqloo ~= nil then
		local cvar_hostname = CreateConVar("banks_mysql_hostname","localhost",FCVAR_PROTECTED+FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE,"MySQL server address to store in.")
		local cvar_username = CreateConVar("banks_mysql_username","root",FCVAR_PROTECTED+FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE,"MySQL username to store in.")
		local cvar_password = CreateConVar("banks_mysql_password","",FCVAR_PROTECTED+FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE,"MySQL password to store in.")
		local cvar_database = CreateConVar("banks_mysql_database","pointshop_banks",FCVAR_PROTECTED+FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE,"MySQL database to store in.")
		local cvar_port = CreateConVar("banks_mysql_port","3306",FCVAR_PROTECTED+FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE,"MySQL port to store in. Most likely is 3306.")
		database = mysqloo.connect(cvar_hostname:GetString(), cvar_username:GetString(), cvar_password:GetString(), cvar_database:GetString(), cvar_port:GetInt())
		function database:onConnected()
			MsgC(Color(0,255,0),"[PSBanks] ",Color(0,127,255),"MySQL connection successful.","\n")
		end
		function database:onConnectionFailed(err)
			MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"MySQL connection failed: "..err,"\n")
		end
		database:connect()
		local first_light_query = [[
			CREATE TABLE IF NOT EXISTS `pointshop_banks_data` (
			`steamid` VARCHAR(30) NOT NULL,
			`points` DOUBLE(64) NOT NULL,
			PRIMARY KEY (`steamid`)
			) ENGINE=MyISAM DEFAULT CHARSET=latin1
		]]
		local queryString = database:query(first_light_query)
		function queryString:onError(err, sql)
			if database:status() ~= mysqloo.DATABASE_CONNECTED then
				database:connect()
				database:wait()
				if database:status() ~= mysqloo.DATABASE_CONNECTED then
					MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"Re-connection to server failed!","\n")
					return
				end
			end
			MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"First light MySQL query failed: "..err.." ("..sql..")","\n")
			queryString:start()
		end
		queryString:start()
	end
end

-- Points read/writing.

function PSBanks_StorePoints(id,pts)
	if not PS then return end
	if player.GetBySteamID(id) then
		player.GetBySteamID(id):SetNWInt("PSBank",pts)
	end
	for k,v in pairs(ents.FindByClass("ps_bank")) do
		v.BankStorage[id] = pts
	end
	BankStorage[id] = pts
	if PS.Config.DataProvider == 'pdata' then
		util.SetPData(id,"PS_BankPoints",pts)
	elseif PS.Config.DataProvider == 'flatfile' or PS.Config.DataProvider == 'json' then -- What the **** is the difference?
		local storage = {}
		if not file.IsDir('pointshop', 'DATA') then
			file.CreateDir('pointshop')
		end
		if file.Exists('pointshop/pointshop_banks.txt', 'DATA') then
			storage = util.JSONToTable(file.Read('pointshop/pointshop_banks.txt', 'DATA')) or storage
		end
		storage[id] = pts
		file.Write('pointshop/pointshop_banks.txt', util.TableToJSON(storage))
	elseif PS.Config.DataProvider == 'mysql' then
		local qu = [[
			INSERT INTO `pointshop_banks_data` (steamid, points)
			VALUES ('%s', '%s')
			ON DUPLICATE KEY UPDATE 
				points = VALUES(points)
		]]
		string.format(qu,id,tostring(pts))
		local queryString = database:query(qu)
		function queryString:onError(err, sql)
			if database:status() ~= mysqloo.DATABASE_CONNECTED then
				database:connect()
				database:wait()
				if database:status() ~= mysqloo.DATABASE_CONNECTED then
					MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"Re-connection to server failed!","\n")
					return
				end
			end
			MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"MySQL query failed: "..err.." ("..sql..")","\n")
			queryString:start()
		end
		queryString:start()
	end
end

function PSBanks_ReadPoints(id)
	if not PS then return 0 end
	local TrackCash = 0
	for i=1,#ents.FindByClass("ps_bank") do
		if ents.FindByClass("ps_bank")[i].BankStorage ~= {} then
			if ents.FindByClass("ps_bank")[i].BankStorage[id] ~= nil then
				TrackCash = math.max(ents.FindByClass("ps_bank")[i].BankStorage[id],TrackCash) --More reliable, persists over saves
			end
		end
	end
	if BankStorage[id] ~= nil then
		TrackCash = BankStorage[id]
	end
	if PS.Config.DataProvider == 'pdata' then
		TrackCash = util.GetPData(id,"PS_BankPoints",nil) or TrackCash
	elseif PS.Config.DataProvider == 'flatfile' or PS.Config.DataProvider == 'json' then
		local storage = {}
		if not file.IsDir('pointshop', 'DATA') then
			file.CreateDir('pointshop')
		end
		if file.Exists('pointshop/pointshop_banks.txt', 'DATA') then
			storage = util.JSONToTable(file.Read('pointshop/pointshop_banks.txt', 'DATA')) or storage
		end
		TrackCash = storage and storage[id] or TrackCash
	elseif PS.Config.DataProvider == 'mysql' then
		local qu = [[
			SELECT *
			FROM `pointshop_banks_data`
			WHERE uniqueid = '%s'
		]]
		string.format(qu,id)
		local queryString = database:query(qu)
		function queryString:onSuccess(data)
			if #data > 0 then
				local row = data[1]
				TrackCash = tonumber(row.points) or TrackCash
			end
		end
		function queryString:onError(err, sql)
			if database:status() ~= mysqloo.DATABASE_CONNECTED then
				database:connect()
				database:wait()
				if database:status() ~= mysqloo.DATABASE_CONNECTED then
					MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"Re-connection to server failed!","\n")
					return
				end
			end
			MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"MySQL query failed: "..err.." ("..sql..")","\n")
			queryString:start()
		end
		queryString:start()
	end
	return TrackCash
end

-- Completion options

local function GetAllPlayers(cmd,stringargs)
		
	-- Garry's Mod wiki. Thank you Donkie

	stringargs = string.Trim( stringargs ) -- Remove any spaces before or after.
	stringargs = string.lower( stringargs )

	local tbl = {}


	for k, v in pairs( player.GetAll() ) do
		local nick = v:Nick()
		if string.find( string.lower( nick ), stringargs ) then
			--nick = "\"" .. nick .. "\"" -- We put quotes around it in case players have spaces in their names.
			nick = cmd .. " " .. nick -- We also need to put the cmd before for it to work properly.

			table.insert( tbl, nick )
		end
	end

	return tbl
	
end

-- Actual code.

function ENT:SpawnFunction( ply, tr, class )

	if ( !tr.Hit ) then return end
	
	-- include(autorun/pointshop.lua)

	local SpawnPos = tr.HitPos + tr.HitNormal * 30
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 90

	local ent = ents.Create( class )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:SetupDataTables()
	self:NetworkVar("String",0,"BankModel")
end

function ENT:Initialize()
	self:SetModel( self:GetBankModel() ~= nil and util.IsValidModel(self:GetBankModel()) and self:GetBankModel() or self.Model )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	-- Init physics only on server, so it doesn't mess up physgun beam
	if SERVER then self:PhysicsInit( SOLID_VPHYSICS ) end

	-- Make prop to fall on spawn
	local phys = self:GetPhysicsObject()
	if ( IsValid( phys ) ) then phys:Wake() end
	if SERVER then self:SetUseType(SIMPLE_USE) end
end

function ENT:Use(activator, ply)
	if IsValid(ply) and ply:IsPlayer() then
		if not PS then net.Start("VerifyPointshop",true); net.Send(ply); return end
		if not mysqloo and PS.Config.DataProvider == 'mysql' then net.Start("VerifyPointshop",true); net.Send(ply); return end
			-- mysqloo is always nil until I actually take the time to understand it. Which I have now.
		local TrackCash = PSBanks_ReadPoints(ply:SteamID())
		if TrackCash ~= 0 then
			ply:SetNWInt("PSBank",TrackCash)
		end
		net.Start("OpenBankMenu",true)
			net.WriteEntity(self)
		net.Send(ply)
	end
end

function ENT:Draw()
	self.Entity:DrawModel()
end

-- Server concommands

if SERVER and PS then
	
	--[[concommand.Add("resetbank",function(ply)
		ply:SetNWInt("PSBank",0)
		for k,v in pairs(ents.FindByClass("ps_bank")) do
			v.BankStorage[sender:SteamID()] = 0
		end
		ply:ChatPrint("Reset successful.")
	end,nil,"Sets your bank account to 0 "..PS.Config.PointsName..".")]]
	concommand.Add("banks_reset",function(ply,cmdstr,argtable,argstr)
		local success = argstr == ""
		if IsValid(ply) then
			if not ( ( ply:IsSuperAdmin() and PS.Config.SuperAdminCanAccessAdminTab ) or ( ply:IsAdmin() and PS.Config.AdminCanAccessAdminTab ) ) then
				MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"Access denied.","\n")
				return
			end
		end
		for k,v in pairs(player.GetAll()) do
			local plynick = v:Nick()
			if string.lower(argstr) == string.lower(plynick) or argstr == "" then
				success = true
				PSBanks_StorePoints(v:SteamID(),0)
				v:ChatPrint("Your bank account has been deleted!")
			end
		end
		if argstr == "" then
			if PS.Config.DataProvider == 'pdata' then
				-- *shrug*
			elseif PS.Config.DataProvider == 'flatfile' or PS.Config.DataProvider == 'json' then
				if not file.IsDir('pointshop', 'DATA') then
					file.CreateDir('pointshop')
				end
				file.Write('pointshop/pointshop_banks.txt', util.TableToJSON({}))
			elseif PS.Config.DataProvider == 'mysql' then
				-- D-d-d-drop the bass
				local re_query = [[
					DROP TABLE IF EXISTS `pointshop_banks_data`;
					CREATE TABLE IF NOT EXISTS `pointshop_banks_data` (
					`steamid` VARCHAR(30) NOT NULL,
					`points` DOUBLE(64) NOT NULL,
					PRIMARY KEY (`steamid`)
					) ENGINE=MyISAM DEFAULT CHARSET=latin1
				]]
				local queryString = database:query(re_query)
				function queryString:onError(err, sql)
					if database:status() ~= mysqloo.DATABASE_CONNECTED then
						database:connect()
						database:wait()
						if database:status() ~= mysqloo.DATABASE_CONNECTED then
							MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"Re-connection to server failed!","\n")
							return
						end
					end
					MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"MySQL query failed: "..err.." ("..sql..")","\n")
					queryString:start()
				end
				queryString:start()
			end
			for k,v in pairs(ents.FindByClass("ps_bank")) do
				v.BankStorage = {}
			end
			BankStorage = {}
		end
		
		MsgC(Color(0,255,0),"[PSBanks] ",success and Color(0,127,255) or Color(255,127,127),success and ("Reset successful.") or ("Reset failed."),"\n")
	end,GetAllPlayers,"Only those who have access to the admin tab may use this command.\n - Sets bank account to 0 "..PS.Config.PointsName.." for some or all players.\n - Leave blank for all.")
	
	concommand.Add("banks_add",function(ply,cmdstr,argtable,argstr)
		if #argtable < 2 then
			MsgC(Color(0,255,0),"[PSBanks] ",Color(0,127,255),"Usage: banks_add [player] [amount]","\n")
			return
		end
		local actualname = table.concat(argtable," ",1,#argtable-1)
		local points = tonumber(argtable[#argtable])
		local success = false
		if IsValid(ply) then
			if not ( ( ply:IsSuperAdmin() and PS.Config.SuperAdminCanAccessAdminTab ) or ( ply:IsAdmin() and PS.Config.AdminCanAccessAdminTab ) ) then
				MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"Access denied.","\n")
				return
			end
		end
		if not points then
			MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"'"..points.."' is not a number.","\n")
			return
		end
		for k,v in pairs(player.GetAll()) do
			local plynick = v:Nick()
			if string.lower(actualname) == string.lower(plynick) then
				success = true
				local result = math.max(PSBanks_ReadPoints(v:SteamID()) + points,0)
				PSBanks_StorePoints(v:SteamID(),result)
				v:ChatPrint("Your bank account has been given "..points.." "..PS.Config.PointsName.."!")
			end
		end
		MsgC(Color(0,255,0),"[PSBanks] ",success and Color(0,127,255) or Color(255,127,127),success and ("Added "..points.." "..PS.Config.PointsName.." to "..actualname..(actualname:Right(1) ~= "s" and "'s" or "'").." bank account.") or ("Addition failed."),"\n")
	end,GetAllPlayers,"Only those who have access to the admin tab may use this command.\n - Adds the amount of "..PS.Config.PointsName.." for someone's bank account.")
	
	concommand.Add("banks_remove",function(ply,cmdstr,argtable,argstr)
		if #argtable < 2 then
			MsgC(Color(0,255,0),"[PSBanks] ",Color(0,127,255),"Usage: banks_remove [player] [amount]","\n")
			return
		end
		local actualname = table.concat(argtable," ",1,#argtable-1)
		local points = tonumber(argtable[#argtable])
		local success = false
		if IsValid(ply) then
			if not ( ( ply:IsSuperAdmin() and PS.Config.SuperAdminCanAccessAdminTab ) or ( ply:IsAdmin() and PS.Config.AdminCanAccessAdminTab ) ) then
				MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"Access denied.","\n")
				return
			end
		end
		if not points then
			MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"'"..points.."' is not a number.","\n")
			return
		end
		for k,v in pairs(player.GetAll()) do
			local plynick = v:Nick()
			if string.lower(actualname) == string.lower(plynick) then
				success = true
				local result = math.max(PSBanks_ReadPoints(v:SteamID()) - points,0)
				PSBanks_StorePoints(v:SteamID(),result)
				v:ChatPrint("Your bank account has been taken away "..points.." "..PS.Config.PointsName.."!")
			end
		end
		MsgC(Color(0,255,0),"[PSBanks] ",success and Color(0,127,255) or Color(255,127,127),success and ("Removed "..points.." "..PS.Config.PointsName.." from "..actualname..(actualname:Right(1) ~= "s" and "'s" or "'").." bank account.") or ("Subtraction failed."),"\n")
	end,GetAllPlayers,"Only those who have access to the admin tab may use this command.\n - Reduces the amount of "..PS.Config.PointsName.." for someone's bank account.")
	
	concommand.Add("banks_set",function(ply,cmdstr,argtable,argstr)
		if #argtable < 2 then
			MsgC(Color(0,255,0),"[PSBanks] ",Color(0,127,255),"Usage: banks_set [player] [amount]","\n")
			return
		end
		local actualname = table.concat(argtable," ",1,#argtable-1)
		local points = tonumber(argtable[#argtable])
		local success = false
		if IsValid(ply) then
			if not ( ( ply:IsSuperAdmin() and PS.Config.SuperAdminCanAccessAdminTab ) or ( ply:IsAdmin() and PS.Config.AdminCanAccessAdminTab ) ) then
				MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"Access denied.","\n")
				return
			end
		end
		if not points then
			MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"'"..points.."' is not a number.","\n")
			return
		end
		for k,v in pairs(player.GetAll()) do
			local plynick = v:Nick()
			if string.lower(actualname) == string.lower(plynick) then
				success = true
				local result = math.max(points,0)
				PSBanks_StorePoints(v:SteamID(),result)
				v:ChatPrint("Your bank account has been set to "..points.." "..PS.Config.PointsName.."!")
			end
		end
		MsgC(Color(0,255,0),"[PSBanks] ",success and Color(0,127,255) or Color(255,127,127),success and ("Set "..actualname..(actualname:Right(1) ~= "s" and "'s" or "'").." bank account to "..points.." "..PS.Config.PointsName..".") or ("Set failed."),"\n")
	end,GetAllPlayers,"Only those who have access to the admin tab may use this command.\n - Sets the amount of "..PS.Config.PointsName.." for someone's bank account.")
	
	concommand.Add("banks_subtract",function(ply,cmdstr,argtable,argstr)
		if #argtable < 2 then
			MsgC(Color(0,255,0),"[PSBanks] ",Color(0,127,255),"Usage: banks_subtract [player] [amount]","\n")
			return
		end
		if IsValid(ply) then
			ply:ConCommand("banks_remove "..argstr)
		else
			RunConsoleCommand("banks_remove",unpack(argtable))
		end
	end,GetAllPlayers,"Only those who have access to the admin tab may use this command.\n - Reduces the amount of "..PS.Config.PointsName.." for someone's bank account.\n - Alias of banks_remove.")
	
	local ConA = CreateConVar("banks_display_adminonly","0",FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE,"Only executable from server console.\n - Sets permissions for banks_display:\n - 0: Anyone\n - 1: Admin only\n - 2: Superadmin only\n - 3: Server console only\n - 4: No one")
	
	concommand.Add("banks_display",function(ply,cmdstr,argtable,argstr)
		local success = false
		local permitted = not IsValid(ply) and ConA:GetInt() == 3
		if not permitted and IsValid(ply) then 
			permitted = ( ConA:GetInt() == 2 and ply:IsSuperAdmin() ) or ( ConA:GetInt() == 1 and ply:IsAdmin() ) or ConA:GetInt() < 1
		end
		if permitted then
			for k,v in pairs(player.GetAll()) do
				local plynick = v:Nick()
				if string.lower(argstr) == string.lower(plynick) or argstr == "" then
					local cached = PSBanks_ReadPoints(v:SteamID())
					MsgC(Color(0,255,0),"[PSBanks] ",Color(0,127,255),plynick..": "..cached.."\n")
					success = true
				end
			end
			if not success then MsgC(Color(0,255,0),"[PSBanks] ",Color(0,127,255),argstr..": nil".."\n") end
		else
			MsgC(Color(0,255,0),"[PSBanks] ",Color(255,127,127),"Access denied.".."\n")
		end
	end,GetAllPlayers," - Prints amounts of cash for each player on the server.")
end

-- Client UI

local panelx = 500
local panely = 250
local funclen = 200
local inputw = 0
local inputd = 0
local modelname = ""

net.Receive("VerifyPointshop", function()
	local mysqlerror = PS and PS.Config.DataProvider == 'mysql' or false
	Derma_Message("Error: Missing addon\nMake sure you have 'Pointshop' installed."..Either(mysqlerror,"\nIf you intend to use MySQL, please make sure it is installed.",""),"Warning","Okay")
end)

net.Receive("OpenBankMenu", function()
	if not CLIENT then return end
	
	local target = net.ReadEntity()
	
	local points = LocalPlayer():PS_GetPoints() ~= nil and LocalPlayer():PS_GetPoints() or 0
	local banked = LocalPlayer():GetNWInt("PSBank",0)
	
	local Main = vgui.Create("DFrame")
	--Main:SetPos( ScrW()/2-panelx/2, ScrH()/2-panely/2 )
	Main:SetSize( panelx, panely )
	Main:Center()
	Main:SetTitle( "Bank" )
	Main:SetVisible( true )
	Main:SetDraggable( true )
	Main:ShowCloseButton( true )
	Main:MakePopup()
	Main.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
		points = LocalPlayer():PS_GetPoints() ~= nil and LocalPlayer():PS_GetPoints() or 0
		banked = LocalPlayer():GetNWInt("PSBank",0)
		local digits = math.floor(math.log10(banked)+1)
		local letters = {
		[15]="Q",
		[12]="T",
		[9]="B",
		[6]="M",
		[3]="k"
		}
		local disp = banked
		local index = ""
		for k,v in pairs(letters) do
			if digits >= k+1 and digits < k+4 then
				index = v
				local decimals = (k+3-digits)
				disp = string.format("%."..decimals.."f",math.floor((banked / 10^k)*10^decimals)/10^decimals)
			end
		end
		if digits >= 18 then
			index = ""
			disp = string.format("%.3G",banked)
		end
		draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 127, 0, 255 ) ) -- Draw a box instead of the frame
		if Main:IsActive() then draw.RoundedBox( 4, 0, 0, w, 24, Color( 0, 191, 0, 255 ) ) end
		draw.SimpleText("You currently have "..points.." "..PS.Config.PointsName,"PS_ButtonText1",w/2,30,Color(255,255,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
		draw.SimpleText("You have "..disp..index.." "..PS.Config.PointsName.." in store","PS_ButtonText1",w/2,50,Color(0,255,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
	end
	
	--[[Money statement.
	local Money = vgui.Create("DLabel",Main)
	Money:SetFont("PS_ButtonText1")
	Money:SetText("You currently have "..LocalPlayer():PS_GetPoints().." points")
	Money:SetTextColor(Color(255,255,0,255))
	Money:SizeToContents()
	Money:SetPos(-1,30)
	Money:CenterHorizontal()
	
	--Inside bank statement.
	local Banked = vgui.Create("DLabel",Main)
	Banked:SetFont("PS_ButtonText1")
	Banked:SetText("You have "..LocalPlayer():GetNWInt("PSBank",0).." points in store")
	Banked:SetTextColor(Color(0,255,0,255))
	Banked:SizeToContents()
	Banked:SetPos(-1,35+fontsize)
	Banked:CenterHorizontal()]]
	
	--Withdraw entry.
	local Withdraw = vgui.Create( "DTextEntry",Main)
	Withdraw:SetPos(-1,panely/2+10)
	Withdraw:SetSize(funclen, 20)
	Withdraw:CenterHorizontal()
	Withdraw:SetNumeric(true)
	Withdraw:SetText(inputw ~= 0 and inputw or "")
	Withdraw.OnChange = function(self)
		inputw = tonumber(self:GetValue()) or 0
	end
	
	--Withdraw amount button.
	local Withdraw1 = vgui.Create( "DButton", Main )
	Withdraw1:SetText( "Withdraw" )
	Withdraw1:SetPos(panelx/2-funclen/2,panely/2+30)
	Withdraw1:SetSize(funclen/2, 20)
	Withdraw1.DoClick = function()
		if inputw <= 0 then notification.AddLegacy( "Value can't be zero!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
		inputw = math.min(2147483647,inputw)
		net.Start("BankInput",true)
			net.WriteInt(-inputw,32)
		net.SendToServer()
	end
	
	--Withdraw all button.
	local Withdraw2 = vgui.Create( "DButton", Main )
	Withdraw2:SetText( "Withdraw All" )
	Withdraw2:SetPos(panelx/2,panely/2+30)
	Withdraw2:SetSize(funclen/2, 20)
	Withdraw2.DoClick = function()
		net.Start("BankInput",true)
			net.WriteInt(-math.min(banked,2147483647),32)
		net.SendToServer()
	end
	
	--Deposit entry.
	local Deposit = vgui.Create( "DTextEntry",Main)
	Deposit:SetPos(-1,panely/2-50)
	Deposit:SetSize(funclen, 20)
	Deposit:CenterHorizontal()
	Deposit:SetNumeric(true)
	Deposit:SetText(inputd ~= 0 and inputd or "")
	Deposit.OnChange = function(self)
		inputd = tonumber(self:GetValue()) or 0
	end
	
	--Deposit amount button.
	local Deposit1 = vgui.Create( "DButton", Main )
	Deposit1:SetText( "Deposit" )
	Deposit1:SetPos(panelx/2-funclen/2,panely/2-30)
	Deposit1:SetSize(funclen/2, 20)
	Deposit1.DoClick = function()
		if inputd <= 0 then notification.AddLegacy( "Value can't be zero!", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
		inputd = math.min(points,inputd)
		net.Start("BankInput",true)
			net.WriteInt(inputd,32)
		net.SendToServer()
	end
	
	--Deposit all button.
	local Deposit2 = vgui.Create( "DButton", Main )
	Deposit2:SetText( "Deposit All" )
	Deposit2:SetPos(panelx/2,panely/2-30)
	Deposit2:SetSize(funclen/2, 20)
	Deposit2.DoClick = function()
		net.Start("BankInput",true)
			net.WriteInt(points,32)
		net.SendToServer()
	end
	
	if LocalPlayer():IsAdmin() then
	
		--Model validation indicator.
		local ModelCheck = vgui.Create( "DImage",Main)
		ModelCheck:SetPos(panelx/2+funclen/2+2,panely/2+70+2)
		ModelCheck:SetSize(16,16)
	
		--Model entry.
		local Model = vgui.Create( "DTextEntry",Main)
		Model:SetPos(-1,panely/2+70)
		Model:SetSize(funclen, 20)
		Model:CenterHorizontal()
		Model:SetText(modelname)
		if util.IsValidModel(modelname) or modelname == "" then
			ModelCheck:SetImage("icon16/tick.png")
		else
			ModelCheck:SetImage("icon16/cross.png")
		end
		Model.OnChange = function(self)
			modelname = self:GetValue()
			if util.IsValidModel(modelname) or modelname == "" then
				ModelCheck:SetImage("icon16/tick.png")
			else
				ModelCheck:SetImage("icon16/cross.png")
			end
		end
	
		--Model revalidation button.
		local ModelRecheck = vgui.Create( "DButton",Main)
		ModelRecheck:SetText("Verify Model")
		ModelRecheck:SetPos(panelx/2+funclen/2+20,panely/2+70)
		ModelRecheck:SetSize(80, 20)
		ModelRecheck.DoClick = function()
			net.Start("RevalidModel",true)
				net.WriteString(modelname)
			net.SendToServer()
			timer.Simple(RealFrameTime(),function()
				if IsValid(ModelCheck) then
					if util.IsValidModel(modelname) or modelname == "" then
						ModelCheck:SetImage("icon16/tick.png")
					else
						ModelCheck:SetImage("icon16/cross.png")
					end
				end
			end)
		end
		
		--Model button.
		local Model1 = vgui.Create( "DButton", Main )
		Model1:SetText( "Set Model" )
		Model1:SetTextColor(Color(255,0,0,255))
		Model1:SetPos(panelx/2-funclen/2,panely/2+90)
		Model1:SetSize(funclen/2, 20)
		Model1.DoClick = function()
			if not util.IsValidModel(modelname) and modelname ~= "" then notification.AddLegacy( "Invalid model! Leave blank for default model.", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" ); return end
			net.Start("BankInputModel",true)
				net.WriteString(modelname)
				net.WriteEntity(target)
			net.SendToServer()
			Main:Close()
		end
		
		--Model restore button.
		local Model2 = vgui.Create( "DButton", Main )
		Model2:SetText( "Reset Model" )
		Model2:SetTextColor(Color(255,0,0,255))
		Model2:SetPos(panelx/2,panely/2+90)
		Model2:SetSize(funclen/2, 20)
		Model2.DoClick = function()
			net.Start("BankInputModel",true)
				net.WriteString("")
				net.WriteEntity(target)
			net.SendToServer()
			Main:Close()
		end
	
	end
end)

-- Server UI

net.Receive("BankInput", function(bits,sender)
	if not sender:IsPlayer() or not SERVER then return end
	local input = net.ReadInt(32)
	local points = sender:PS_GetPoints() ~= nil and sender:PS_GetPoints() or 0
	local bank = sender:GetNWInt("PSBank",0)
	if bank < -input then
		input = -bank
	elseif -input + points > 2147483647 then
		input = points - 2147483647
	elseif input > points then
		input = points
	elseif input + bank > 2147483647 then
		--input = 2147483647 - bank
	end
	if input == 0 then return end
	if input < 0 then sender:PS_GivePoints(-input) else sender:PS_TakePoints(input) end
	PSBanks_StorePoints(sender:SteamID(),bank+input)
end)

net.Receive("BankInputModel", function(bits,sender)
	if not sender:IsPlayer() or not SERVER then return end
	local model = net.ReadString()
	if not util.IsValidModel(model) and model ~= "" or not sender:IsAdmin() then return end
	local target = net.ReadEntity()
	if not IsValid(target) then return end --It *might* have been deleted after the player sent it idk
	if model == "" then model = target.Model end
	if model ~= target:GetModel() then
		target:SetModel(model)
		target:SetBankModel(model)
		target:PhysicsInit( SOLID_VPHYSICS )
		local phys = target:GetPhysicsObject()
		if ( IsValid( phys ) ) then phys:Wake() end
	end
end)