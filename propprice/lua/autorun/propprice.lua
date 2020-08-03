if SERVER then
	util.AddNetworkString("PropPrice")
end

local PLAYER = FindMetaTable("Player")

function PLAYER:PP_SetCash(num)
	self.PP_Cash = num
	if SERVER and PROPPRICE_ACTIVE then
		net.Start("PropPrice")
		net.WriteString("cash_change")
		net.WriteDouble(num)
		net.Send(self)
	end
end

function PLAYER:PP_GetCash()
	return self.PP_Cash or 0
end

function PLAYER:PP_SetIncome(num)
	self.PP_Income = num
	if SERVER and PROPPRICE_ACTIVE then
		net.Start("PropPrice")
		net.WriteString("income_change")
		net.WriteDouble(num)
		net.Send(self)
	end
end

function PLAYER:PP_GetIncome(num)
	return self.PP_Income or 0
end

PROPPRICE_ACTIVE = true

if CLIENT then
	net.Receive("PropPrice",function()
		local func = net.ReadString()
		if func == "cash_change" then
			LocalPlayer().PP_Cash = net.ReadDouble()
		elseif func == "income_change" then
			LocalPlayer().PP_Income = net.ReadDouble()
		elseif func == "cash_not_enough" then
			LocalPlayer().PP_ShouldCost = net.ReadDouble()
		elseif func == "send_admin" then
			local amt = net.ReadDouble()
			Derma_Query("Hello there! It seems you have enough money to purchase the entire world!\nWould you like to spend $"..string.Comma(math.Round(amt,2)).." to gain admin privileges for this session?",
			"Buy Admin Privileges?",
			"Yes",function()
				net.Start("PropPrice")
				net.WriteString("rec_admin")
				net.SendToServer()
			end,
			"Remind Me Later",nil,
			"Don't Ask Again",function()
				net.Start("PropPrice")
				net.WriteString("never_admin")
				net.SendToServer()
			end)
		end
	end)
end

-- aliases
PLAYER.PP_SetMoney = PLAYER.PP_SetCash
PLAYER.PP_GetMoney = PLAYER.PP_GetCash

if SERVER then

	local ModelPrice = {}
	local tableOfPPEnts = {} -- needed so that we can process everything before the server shuts down.

	for k,v in pairs(player.GetAll()) do
		v:PP_SetCash(v:PP_GetCash())
		v:PP_SetIncome(v:PP_GetIncome())
	end

	local ConC = CreateConVar("propprice_multiplicative_mul",1,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConV = CreateConVar("propprice_volume_mul",1,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConX = CreateConVar("propprice_meshcomplexity_mul",1,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConM = CreateConVar("propprice_mass_mul",0,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConH = CreateConVar("propprice_sphere_complexity",100,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConA = CreateConVar("propprice_mode",0,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConU = CreateConVar("propprice_custom_formula","v+c+m",FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConD = CreateConVar("propprice_default",10,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConE = CreateConVar("propprice_add",0,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConI = CreateConVar("propprice_initialcash",100000,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConR = CreateConVar("propprice_sell_mul",0.8,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConK = CreateConVar("propprice_kill_mul",10,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConB = CreateConVar("propprice_kill_increment_income_rate_mul",0.1,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConO = CreateConVar("propprice_overdrafting",0,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConS = CreateConVar("propprice_cache_spawnprices",1,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConP = CreateConVar("propprice_packet_delay",60,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConQ = CreateConVar("propprice_packet_amount",10000,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConW = CreateConVar("propprice_save_players_cash_to_file",1,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConY = CreateConVar("propprice_save_prices_to_file",0,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConL = CreateConVar("propprice_strict_selling",0,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConZ = CreateConVar("propprice_enable_admin_purchase",0,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConT = CreateConVar("propprice_non_developer",0,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConF = CreateConVar("propprice_income_on_purchase",0,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	local ConG = CreateConVar("propprice_lost_income_on_sell",1,FCVAR_ARCHIVE+FCVAR_NOTIFY+FCVAR_SERVER_CAN_EXECUTE)
	
	local function GetAllPlayers(cmd,stringargs)
			
		-- Edited from the Garry's Mod Wiki. Thank you Donkie

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
	
	local function CommonToAsk(cmd,ply,argtable,points)
		if #argtable < 2 then
			MsgC(Color(0,255,0),"[PropPrice] ",Color(0,255,255),"Usage: "..cmd.." [player] [amount]","\n")
			return false
		end
		if IsValid(ply) then
			if not ply:IsAdmin() then
				MsgC(Color(0,255,0),"[PropPrice] ",Color(255,127,127),"Access denied.","\n")
				return false
			end
		end
		local actualname = table.concat(argtable," ",1,#argtable-1)
		local points = tonumber(argtable[#argtable])
		local success = false
		if not points then
			MsgC(Color(0,255,0),"[PropPrice] ",Color(255,127,127),"'"..argtable[#argtable].."' is not a number.","\n")
			return false
		end
		return true,actualname,points
	end
	
	concommand.Add("propprice_setcash",function(ply,cmdstr,argtable)
		local done,actualname,points = CommonToAsk("propprice_setcash",ply,argtable)
		if not done then return end
		local success = false
		for k,v in pairs(player.GetAll()) do
			local plynick = v:Nick()
			if string.lower(actualname) == string.lower(plynick) then
				success = true
				v:PP_SetCash(points) break
			end
		end
		MsgC(Color(0,255,0),"[PropPrice] ",success and Color(0,255,255) or Color(255,127,127),success and ("Set "..actualname..(actualname:Right(1) ~= "s" and "'s" or "'").." cash amount to $"..points..".") or ("Couldn't find specified player."),"\n")
	end,GetAllPlayers)
	
	concommand.Add("propprice_addcash",function(ply,cmdstr,argtable,argstr)
		local done,actualname,points = CommonToAsk("propprice_addcash",ply,argtable)
		if not done then return end
		for k,v in pairs(player.GetAll()) do
			local plynick = v:Nick()
			if string.lower(actualname) == string.lower(plynick) then
				success = true
				points = v:PP_GetCash() + points
				v:PP_SetCash(points) break
			end
		end
		MsgC(Color(0,255,0),"[PropPrice] ",success and Color(0,255,255) or Color(255,127,127),success and ("Set "..actualname..(actualname:Right(1) ~= "s" and "'s" or "'").." cash amount to $"..points..".") or ("Couldn't find specified player."),"\n")
	end,GetAllPlayers)
	
	concommand.Add("propprice_subcash",function(ply,cmdstr,argtable,argstr)
		local done,actualname,points = CommonToAsk("propprice_subcash",ply,argtable)
		if not done then return end
		for k,v in pairs(player.GetAll()) do
			local plynick = v:Nick()
			if string.lower(actualname) == string.lower(plynick) then
				success = true
				points = v:PP_GetCash() - points
				v:PP_SetCash(points) break
			end
		end
		MsgC(Color(0,255,0),"[PropPrice] ",success and Color(0,255,255) or Color(255,127,127),success and ("Set "..actualname..(actualname:Right(1) ~= "s" and "'s" or "'").." cash amount to $"..points..".") or ("Couldn't find specified player."),"\n")
	end,GetAllPlayers)
	
	concommand.Add("propprice_setincome",function(ply,cmdstr,argtable)
		local done,actualname,points = CommonToAsk("propprice_setincome",ply,argtable)
		if not done then return end
		local success = false
		for k,v in pairs(player.GetAll()) do
			local plynick = v:Nick()
			if string.lower(actualname) == string.lower(plynick) then
				success = true
				v:PP_SetIncome(points) break
			end
		end
		MsgC(Color(0,255,0),"[PropPrice] ",success and Color(0,255,255) or Color(255,127,127),success and ("Set "..actualname..(actualname:Right(1) ~= "s" and "'s" or "'").." income amount to $"..points..".") or ("Couldn't find specified player."),"\n")
	end,GetAllPlayers)
	
	concommand.Add("propprice_addincome",function(ply,cmdstr,argtable,argstr)
		local done,actualname,points = CommonToAsk("propprice_addincome",ply,argtable)
		if not done then return end
		for k,v in pairs(player.GetAll()) do
			local plynick = v:Nick()
			if string.lower(actualname) == string.lower(plynick) then
				success = true
				points = v:PP_GetIncome() + points
				v:PP_SetIncome(points) break
			end
		end
		MsgC(Color(0,255,0),"[PropPrice] ",success and Color(0,255,255) or Color(255,127,127),success and ("Set "..actualname..(actualname:Right(1) ~= "s" and "'s" or "'").." income amount to $"..points..".") or ("Couldn't find specified player."),"\n")
	end,GetAllPlayers)
	
	concommand.Add("propprice_subincome",function(ply,cmdstr,argtable,argstr)
		local done,actualname,points = CommonToAsk("propprice_subincome",ply,argtable)
		if not done then return end
		for k,v in pairs(player.GetAll()) do
			local plynick = v:Nick()
			if string.lower(actualname) == string.lower(plynick) then
				success = true
				points = v:PP_GetIncome() - points
				v:PP_SetIncome(points) break
			end
		end
		MsgC(Color(0,255,0),"[PropPrice] ",success and Color(0,255,255) or Color(255,127,127),success and ("Set "..actualname..(actualname:Right(1) ~= "s" and "'s" or "'").." income amount to $"..points..".") or ("Couldn't find specified player."),"\n")
	end,GetAllPlayers)
	
	concommand.Add("propprice_clearcache",function(ply)
		if IsValid(ply) then
			if not ply:IsAdmin() then
				MsgC(Color(0,255,0),"[PropPrice] ",Color(255,127,127),"Access denied.","\n")
				return
			end
		end
		ModelPrice = {}
		file.Delete("propprice/prices.dat")
		file.Delete("propprice")
		MsgC(Color(0,255,0),"[PropPrice] ",Color(0,255,255),"Cached model prices have been deleted.","\n")
	end)
	
	concommand.Add("propprice_resetplayers",function(ply)
		if IsValid(ply) then
			if not ply:IsAdmin() then
				MsgC(Color(0,255,0),"[PropPrice] ",Color(255,127,127),"Access denied.","\n")
				return
			end
		end
		file.Delete("propprice/players.dat")
		file.Delete("propprice")
		for k,v in pairs(player.GetAll()) do
			v:PP_SetCash(ConI:GetFloat())
			v:PP_SetIncome(ConQ:GetFloat())
		end
		MsgC(Color(0,255,0),"[PropPrice] ",Color(0,255,255),"All player save files have been deleted. Players' cash and income have been reset.","\n")
		
	end)
	
	local callcooldown = 0
	concommand.Add("propprice_summary",function(ply)
		if callcooldown<=RealTime() then
			local builttab = {}
			for k,v in pairs(player.GetAll()) do
				builttab[v:Nick()] = {cash=v:PP_GetCash(),income=v:PP_GetIncome()}
			end
			MsgC(Color(0,255,0),"[PropPrice] ",Color(0,255,255),ply:Nick().." has asked for a summary.\n","The summary is as follows:\n",util.TableToJSON(builttab,true),"\n")
			if not ply:IsAdmin() then callcooldown = RealTime() + 10 end
		end
	end)
	
	local pi43 = math.pi*4/3 -- important variable
	
	local function HandleError(str)
		if not ConT:GetBool() then
			str = str or "<no error trace available>"
			MsgC(Color(0,255,0),"[PropPrice] ",Color(255,127,127),"An error occurred:\n",str,"\nUsing default value of "..ConD:GetFloat().." instead.\n")
		end
	end
	
	local function GetCostFromPhysobj(physobj)
		local vmul = ConV:GetFloat()/100
		local cmul = ConX:GetFloat()/400
		local mmul = ConM:GetFloat()/100
		local ov,oc,om = v,c,m
		v,c,m = 0,0,0
		local cost = 0
		if IsValid(physobj) then
			local vol,cmp,mas = physobj:GetVolume(),physobj:GetMesh(),physobj:GetMass()
			if vol then
				v = vmul~= 0 and vol * vmul or ConA:GetInt()
			else -- Assume it's a sphere
				local mins,maxs = physobj:GetEntity():OBBMins(),physobj:GetEntity():OBBMaxs()
				local radius = math.sqrt(maxs:DistToSqr(mins)/12)
				v = vmul~= 0 and radius^3*pi43*vmul or ConA:GetInt()
			end
			if cmp then
				c = cmul ~= 0 and #cmp*cmul or ConA:GetInt()
			else
				c = cmul ~= 0 and ConH:GetFloat()*cmul or ConA:GetInt()
			end
			if mas then
				m = mmul ~= 0 and mas*mmul or ConA:GetInt()
			end
			local formula = ConA:GetInt()==0 and "v+c+m" or ConA:GetInt()==1 and "v*c*m" or ConU:GetString()
			local func,errstr = CompileString("return "..formula,"ApplyCostFormula",false)
			if not func then
				HandleError(errstr)
				cost = ConD:GetFloat()
			else
				cost = func()
			end
		else
			if ConS:GetBool() then
				if ModelPrice._effect then
					cost = ModelPrice._effect
				else
					HandleError("No physics object found, but we can handle this problem.\nWe'll use the default price first for overdraft prevention, then after generation, we calculate the actual price.")
					cost = ConD:GetFloat()
				end
			else
				HandleError("Physics object not generated yet!\nWe'll use the default price, but if the physics object is generated after, the sell price might fluctuate!")
				cost = ConD:GetFloat()
			end
		end
		v,c,m = ov,oc,om
		cost = cost * ConC:GetFloat()
		cost = cost + ConE:GetFloat()
		return cost
	end

	concommand.Add("propprice_getworldcost",function()
		if ConZ:GetInt()<2 then
			print("$"..string.Comma(GetCostFromPhysobj(game.GetWorld():GetPhysicsObject())))
		else
			local cost = 0
			for k,v in pairs(ents.GetAll()) do
				cost = cost + GetCostFromPhysobj(v:GetPhysicsObject())
			end
			print("$"..string.Comma(cost))
		end
	end)

	local function CanSpawnModel(ply,model)
		local cost = 0
		if ply:PP_GetCash()<0 then
			net.Start("PropPrice")
			net.WriteString("cash_not_enough")
			net.WriteDouble(0)
			net.Send(ply)
			return false
		end
		if ConS:GetBool() and ModelPrice[model] then
			cost = ModelPrice[model]
		else
			local bufferent = ents.Create("prop_physics")
			if IsValid(bufferent) then
				bufferent:SetModel(model)
				bufferent:PhysicsInit(SOLID_VPHYSICS)
				cost = GetCostFromPhysobj(bufferent:GetPhysicsObject())
				bufferent:Remove()
			end
		end
		if not ConO:GetBool() and cost>ply:PP_GetCash() then
			net.Start("PropPrice")
			net.WriteString("cash_not_enough")
			net.WriteDouble(cost)
			net.Send(ply)
			return false
		end
		if not ConS:GetBool() then
			tableOfPPEnts[ply:SteamID()]=(tableOfPPEnts[ply:SteamID()] or 0) + cost
			-- ply.PropCost = (ply.PropCost or 0) + cost
			ply:PP_SetCash(ply:PP_GetCash()-cost)
			ply:PP_SetIncome(ply:PP_GetIncome()+cost*ConF:GetFloat())
		end
	end

	local function CanSpawnClassname(ply,class)
		local cost = 0
		if ply:PP_GetCash()<0 then
			net.Start("PropPrice")
			net.WriteString("cash_not_enough")
			net.WriteDouble(0)
			net.Send(ply)
			return false
		end
		local bufferent = ents.Create(class)
		if IsValid(bufferent) then
			bufferent:Spawn()
			cost = ConS:GetBool() and ModelPrice[bufferent:GetModel() or ""] or GetCostFromPhysobj(bufferent:GetPhysicsObject())
			bufferent:Remove()
		end
		if not ConO:GetBool() and cost>ply:PP_GetCash() then
			net.Start("PropPrice")
			net.WriteString("cash_not_enough")
			net.WriteDouble(cost)
			net.Send(ply)
			return false
		end
		if not ConS:GetBool() then
			tableOfPPEnts[ply:SteamID()]=(tableOfPPEnts[ply:SteamID()] or 0) + cost
			-- ply.PropCost = (ply.PropCost or 0) + cost
			ply:PP_SetCash(ply:PP_GetCash()-cost)
			ply:PP_SetIncome(ply:PP_GetIncome()+cost*ConF:GetFloat())
		end
	end
	
	local function MarkEnt(ply,ent)
		ent.PropPrice_Owner = ply:SteamID()
		if ConS:GetBool() then
			local cost = ModelPrice[ent:GetModel() or ""]
			if not (ConY:GetBool() and cost) then
				cost = GetCostFromPhysobj(ent:GetPhysicsObject())
				ModelPrice[ent:GetModel() or ""] = cost
				if ConY:GetBool() then
					if not file.IsDir("propprice","DATA") then
						file.CreateDir("propprice")
					end
					file.Write("propprice/prices.dat",util.TableToJSON(ModelPrice))
				end
			end
			tableOfPPEnts[ent.PropPrice_Owner]=(tableOfPPEnts[ent.PropPrice_Owner] or 0) + cost
			-- ply.PropCost = (ply.PropCost or 0) + cost
			ply:PP_SetCash(ply:PP_GetCash()-cost)
			ply:PP_SetIncome(ply:PP_GetIncome()+cost*ConF:GetFloat())
		end
	end
	
	local function MarkModelEnt(ply,model,ent)
		ent.PropPrice_Owner = ply:SteamID()
		if ConS:GetBool() then
			local isEffect = ent:GetClass()=="prop_effect"
			local cost = ModelPrice[model] or isEffect and ModelPrice._effect
			if not (ConY:GetBool() and cost) then
				cost = GetCostFromPhysobj(ent:GetPhysicsObject())
				if isEffect then
					ModelPrice._effect = cost
				else
					ModelPrice[model] = cost
				end
				if ConY:GetBool() then
					if not file.IsDir("propprice","DATA") then
						file.CreateDir("propprice")
					end
					file.Write("propprice/prices.dat",util.TableToJSON(ModelPrice))
				end
			end
			tableOfPPEnts[ent.PropPrice_Owner]=(tableOfPPEnts[ent.PropPrice_Owner] or 0) + cost
			-- ply.PropCost = (ply.PropCost or 0) + cost
			ply:PP_SetCash(ply:PP_GetCash()-cost)
			ply:PP_SetIncome(ply:PP_GetIncome()+cost*ConF:GetFloat())
		end
	end
	
	table.Empty(tableOfPPEnts)
	for k,ent in pairs(ents.GetAll()) do -- very expensive function - this is only run once.
		if ent.PropPrice_Owner then
			local cost = ConS:GetBool() and (ModelPrice[ent:GetModel()] or isEffect and ModelPrice._effect) or GetCostFromPhysobj(ent:GetPhysicsObject())
			tableOfPPEnts[ent.PropPrice_Owner]=(tableOfPPEnts[ent.PropPrice_Owner] or 0)+cost
		end
	end
	
	hook.Add("InitPostEntity","PropPrice",function()
		if ConY:GetBool() then
			ModelPrice = util.JSONToTable(file.Read("propprice/prices.dat") or "") or {}
		end
	end)
	
	hook.Add("PlayerInitialSpawn","PropPrice",function(ply)
		if ConW:GetBool() then
			local data = util.JSONToTable(file.Read("propprice/players.dat") or "") or {}
			local steamID = ply:SteamID()
			ply:PP_SetCash(data[steamID] and data[steamID][1] or ConI:GetFloat())
			ply:PP_SetIncome(data[steamID] and data[steamID][2] or ConQ:GetFloat())
		end
	end)

	hook.Add("PlayerSpawnEffect","PropPrice",CanSpawnModel)
	hook.Add("PlayerSpawnNPC","PropPrice",CanSpawnClassname)
	hook.Add("PlayerSpawnProp","PropPrice",CanSpawnModel)
	hook.Add("PlayerSpawnRagdoll","PropPrice",CanSpawnModel)
	hook.Add("PlayerSpawnSENT","PropPrice",CanSpawnClassname)
	hook.Add("PlayerSpawnSWEP","PropPrice",CanSpawnClassname)
	--hook.Add("PlayerGiveSWEP","PropPrice",CanSpawnClassname)
	hook.Add("PlayerSpawnVehicle","PropPrice",CanSpawnModel)
	
	hook.Add("PlayerSpawnedEffect","PropPrice",MarkModelEnt)
	hook.Add("PlayerSpawnedNPC","PropPrice",MarkEnt)
	hook.Add("PlayerSpawnedProp","PropPrice",MarkModelEnt)
	hook.Add("PlayerSpawnedRagdoll","PropPrice",MarkModelEnt)
	hook.Add("PlayerSpawnedSENT","PropPrice",MarkEnt)
	hook.Add("PlayerSpawnedSWEP","PropPrice",MarkEnt)
	hook.Add("PlayerSpawnedVehicle","PropPrice",MarkEnt)
	
	hook.Add("EntityRemoved","PropPrice",function(ent)
		if ent.PropPrice_Owner then
			local cost = ConS:GetBool() and (ModelPrice[ent:GetModel()] or isEffect and ModelPrice._effect) or GetCostFromPhysobj(ent:GetPhysicsObject())
			local ply = player.GetBySteamID(ent.PropPrice_Owner)
			if ply then
				ply:PP_SetCash(ply:PP_GetCash()+cost*ConR:GetFloat())
				ply:PP_SetIncome(ply:PP_GetIncome()-cost*ConF:GetFloat()*ConG:GetFloat())
			elseif ConW:GetBool() then
				if not file.IsDir("propprice","DATA") then
					file.CreateDir("propprice")
				end
				local data = util.JSONToTable(file.Read("propprice/players.dat") or "") or {}
				local cc,ci = unpack(data[ent.PropPrice_Owner])
				data[ent.PropPrice_Owner] = {cc+cost*ConR:GetFloat(),ci-cost*ConF:GetFloat()*ConG:GetFloat()}
				file.Write("propprice/players.dat",util.TableToJSON(data))
			end
			tableOfPPEnts[ent.PropPrice_Owner]=(tableOfPPEnts[ent.PropPrice_Owner] or 0) - cost
			--ply.PropCost = (ply.PropCost or 0) - cost
		end
	end)
	
	hook.Add("AcceptInput","PropPrice",function(ent,input)
		if ConL:GetBool() then
			if ent:Health()>0 and (input:lower()=="break" or input:lower()=="explode") then
				ent.PropPrice_Owner = nil
			end
		end
	end)
	
	--[=[hook.Add("ShutDown","PropPrice",function() -- Server will be down in about 100ms, I hope this is fast enough...
		if ConW:GetBool() then
			local ct = {}
			local cstR,cstFG = ConR:GetFloat(),ConF:GetFloat()*ConG:GetFloat()
			local data = util.JSONToTable(file.Read("propprice/players.dat") or "") or {}
			if not file.IsDir("propprice","DATA") then
				file.CreateDir("propprice")
			end
			for steamid,cost in pairs(tableOfPPEnts) do
				local cc,ci = unpack(data[steamid])
				print(steamid,cc,ci,cost,cc+cost*cstR,ci-cost*cstFG)
				data[steamid] = {cc+cost*cstR,ci-cost*cstFG}
			end
			--[[for k,v in pairs(player.GetAll()) do
				ct[v:SteamID()] = v.PropCost or 0
			end
			for steamid,cost in pairs(ct) do
				local cc,ci = unpack(data[game.SinglePlayer() and STEAM_ID_PENDING or steamid])
				data[steamid] = {cc+cost*cstR,ci-cost*cstFG}
			end]]
			file.Write("propprice/players.dat",util.TableToJSON(data))
			PROPPRICE_ACTIVE = nil
			MsgC(Color(0,255,0),"[PropPrice] ",Color(0,255,255),"Goodbye, world!\n")
		end
	end)]=]
	
	gameevent.Listen("entity_killed")
	
	hook.Add("entity_killed","PropPrice",function(data)
		local attacker = Entity(data.entindex_attacker or 0)
		local victim = Entity(data.entindex_killed or 0)
		if attacker:IsPlayer() and victim ~= attacker then
			attacker:PP_SetCash(attacker:PP_GetCash()+victim:GetMaxHealth()*ConK:GetFloat())
			attacker:PP_SetIncome(attacker:PP_GetIncome()+victim:GetMaxHealth()*ConB:GetFloat())
		end
	end)
	
	local function RecreateTimer()
		timer.Create("PropPrice_Cash",ConP:GetFloat(),0,function()
			for k,v in pairs(player.GetAll()) do
				v:PP_SetCash(v:PP_GetCash()+v:PP_GetIncome())
			end
		end)
	end
	
	cvars.RemoveChangeCallback("propprice_packet_delay","PropPrice")
	cvars.RemoveChangeCallback("propprice_packet_amount","PropPrice")
	cvars.AddChangeCallback("propprice_packet_delay",RecreateTimer,"PropPrice")
	cvars.AddChangeCallback("propprice_packet_amount",RecreateTimer,"PropPrice")
	
	local ticks = 0
	local runperiodically = coroutine.create(function()
		while true do
			local cost = 0
			for k,v in pairs(ents.GetAll()) do
				coroutine.yield()
				local timereq = SysTime()
				if IsValid(v) then
					cost = cost + GetCostFromPhysobj(v:GetPhysicsObject())
				end
				coroutine.wait((SysTime()-timereq)*19) -- 5% processing, 95% rest.
			end
			coroutine.yield(cost)
		end
	end)
	local totalworldcost
	
	hook.Add("Think","PropPrice",function()
		if not timer.Exists("PropPrice_Cash") then
			RecreateTimer()
		end
		if ConZ:GetInt()>1 then
			local success,cost = coroutine.resume(runperiodically)
			if not success then
				HandleError(cost)
			elseif cost then
				totalworldcost = cost
			end
		end
		if ticks < CurTime() then
			ticks = CurTime() + 10
			--[[table.Empty(tableOfPPEnts)
			for k,ent in pairs(ents.GetAll()) do    -- TOO EXPENSIVE!
				if ent.PropPrice_Owner then
					local cost = ConS:GetBool() and (ModelPrice[ent:GetModel()] or isEffect and ModelPrice._effect) or GetCostFromPhysobj(ent:GetPhysicsObject())
					tableOfPPEnts[ent.PropPrice_Owner]=(tableOfPPEnts[ent.PropPrice_Owner] or 0)+cost
				end
			end]]
			if ConZ:GetInt()<=1 and not (totalworldcost and totalworldcost > 1) then
				totalworldcost = GetCostFromPhysobj(game.GetWorld():GetPhysicsObject())
			end
			if ConW:GetBool() then
				if not file.IsDir("propprice","DATA") then
					file.CreateDir("propprice")
				end
				local data = util.JSONToTable(file.Read("propprice/players.dat") or "") or {}
				for k,v in pairs(player.GetAll()) do
					data[v:SteamID()] = {v:PP_GetCash(),v:PP_GetIncome()}
				end
				file.Write("propprice/players.dat",util.TableToJSON(data))
			end
			if ConZ:GetInt()>0 then
				for k,v in pairs(player.GetAll()) do
					v.PP_Asked = v.PP_Asked or 0
					if v.PP_Asked<CurTime() and totalworldcost then
						if v:PP_GetCash()>=totalworldcost then
							net.Start("PropPrice")
							net.WriteString("send_admin")
							net.WriteDouble(totalworldcost)
							net.Send(v)
							v.PP_Asked = CurTime() + 120
						end
					end
				end
			end
		end
	end)
	
	net.Receive("PropPrice",function(length,ply)
		local func = net.ReadString()
		if ply:IsAdmin() then
			if func=="options_server" then
				local allvars = net.ReadTable()
				for k,v in pairs(allvars) do
					if k=="g_mul" then
						ConC:SetFloat(v)
					elseif k=="v_mul" then
						ConV:SetFloat(v)
					elseif k=="c_mul" then
						ConX:SetFloat(v)
					elseif k=="sphere_c" then
						ConH:SetFloat(v)
					elseif k=="m_mul" then
						ConM:SetFloat(v)
					elseif k=="def_val" then
						ConD:SetFloat(v)
					elseif k=="mode" then
						ConA:SetInt(v)
					elseif k=="formula" then
						ConU:SetString(v)
					elseif k=="add_price" then
						ConE:SetFloat(v)
					elseif k=="do_cache" then
						ConS:SetBool(v)
					elseif k=="s_mul" then
						ConR:SetFloat(v)
					elseif k=="overdrafting" then
						ConO:SetBool(v)
					elseif k=="i_c" then
						ConI:SetFloat(v)
					elseif k=="i_i" then
						ConQ:SetFloat(v)
					elseif k=="sav_p" then
						ConW:SetBool(v)
					elseif k=="sav_r" then
						ConY:SetBool(v)
					elseif k=="p_del" then
						ConP:SetFloat(v)
					elseif k=="k_c" then
						ConK:SetFloat(v)
					elseif k=="k_i" then
						ConB:SetFloat(v)
					elseif k=="strict_selling" then
						ConL:SetBool(v)
					elseif k=="buy_admin" then
						ConZ:SetInt(v)
					elseif k=="dont_msg" then
						ConT:SetBool(v)
					elseif k=="i_p" then
						ConF:SetFloat(v)
					elseif k=="s_p" then
						ConG:SetFloat(v)
					end
				end
				if not ConY:GetBool() then
					ModelPrice = {}
				end
			end
		elseif ConZ:GetInt()>0 and func=="rec_admin" and totalworldcost then
			if ply:PP_GetCash()>=totalworldcost then
				ply:PP_SetCash(ply:PP_GetCash()-totalworldcost)
				ply:SetUserGroup("admin")
				PrintMessage(HUD_PRINTTALK,ply:Nick().." has bought admin privileges! God help us ALL!")
			end
		elseif func=="never_admin" then
			ply.PP_Asked = math.huge
		end		
	end)

end

if CLIENT then

	local ConE = CreateClientConVar("propprice_hud_enable",1)
	local ConS = CreateClientConVar("propprice_show_s",1)
	local ConX = CreateClientConVar("propprice_hud_x",.1)
	local ConY = CreateClientConVar("propprice_hud_y",.1)
	local ConA = CreateClientConVar("propprice_hud_income_x",0)
	local ConB = CreateClientConVar("propprice_hud_income_y",-0.05)
	local ConW = CreateClientConVar("propprice_hud_slide_x",0)
	local ConH = CreateClientConVar("propprice_hud_slide_y",0.05)
	local ConC = CreateClientConVar("propprice_hud_income_slide_x",0)
	local ConD = CreateClientConVar("propprice_hud_income_slide_y",-0.05)
	local ConF = CreateClientConVar("propprice_hud_change_lifetime",2)
	local ConL = CreateClientConVar("propprice_hud_income_change_lifetime",5)
	local ConZ = CreateClientConVar("propprice_option_complexity",0)

	local function nullfunc()
	end
	
	hook.Add("AddToolMenuTabs","PropPrice",function()
		spawnmenu.AddToolTab("Options")
	end)
	
	hook.Add("AddToolMenuCategories","PropPrice",function()
		spawnmenu.AddToolCategory("Options","PropPrice","PropPrice")
	end)
	
	hook.Add("PopulateToolMenu","PropPrice",function()
		spawnmenu.AddToolMenuOption("Options","PropPrice","PropPrice_Options","Options","propprice_open_gui","",nullfunc)
	end)
	
	local function StandardSkin(self,w,h)
		draw.RoundedBox(8,0,0,w,h,Color(0,0,0,191))
	end
	
	local function BaseInitLabel(label)
		label:SetWrap(true)
		label:SetAutoStretchVertical(true)
		label:Dock(TOP)
	end
	
	local function PaintAsH1(label,noinit)
		label:SetFont("DermaDefaultBold")
		label:SetTextColor(Color(0,255,255))
		if not noinit then
			BaseInitLabel(label)
		end
	end
	
	local function PaintAsH2(label,noinit)
		label:SetTextColor(Color(0,255,0))
		if not noinit then
			BaseInitLabel(label)
		end
	end
	
	local function PaintAsWarning(label,noinit)
		label:SetFont("DermaDefaultBold")
		label:SetTextColor(Color(255,0,0))
		if not noinit then
			BaseInitLabel(label)
		end
	end
	
	local function PaintAsBody(label,noinit)
		label:SetTextColor(color_white)
		if not noinit then
			BaseInitLabel(label)
		end
	end
	
	local function PaintAsQuote(label,noinit)
		label:SetTextColor(Color(127,127,127))
		if not noinit then
			BaseInitLabel(label)
		end
	end
	
	local PaintWComplexity
	local Vars={}
	
	PaintWComplexity = function(Base)
		local control = ConZ:GetInt()
		if IsValid(Base.Scroller) then
			Base.Scroller:Remove()
		end
		Base.Scroller = vgui.Create("DScrollPanel",Base)
		Base.Scroller:Dock(FILL)
		Base.Scroller.OptChildren = {}
		Base.Scroller.CreateSpace = function(self)
			local pnl = self:Add("DPanel")
			pnl:SetSize(16,16)
			pnl:Dock(TOP)
			pnl.Paint = nullfunc
		end
		Base.Scroller.CreateNewLabel = function(self,text)
			local pnl = self:Add("DLabel")
			pnl:SetText(text)
			return pnl
		end
		Base.Scroller.CreateComboBox = function(self,tab,cvar)
			local pnl = self:Add("DComboBox")
			for k,v in pairs(tab) do
				if k=="noSort" then
					pnl:SetSortItems(not v)
				elseif k=="default" and v then
					pnl:SetValue(v)
				elseif k=="onselect" then
					pnl.OnSelect = v
				elseif k=="choices" then
					for i,v2 in ipairs(v) do
						pnl:AddChoice(unpack(v2))
					end
				end
			end
			if cvar then
				pnl:SetValue(pnl:GetOptionTextByData(GetConVar(cvar):GetInt()))
			end
			--PaintAsH2(pnl,true)
			--pnl.Paint = nullfunc
			pnl:Dock(TOP)
			return pnl
		end
		Base.Scroller.CreateNumSlider = function(self,text,mn,mx,func,cvar,dec)
			local pnl = self:Add("DNumSlider")
			pnl:SetText(text)
			pnl:SetMinMax(mn,mx)
			pnl:SetDecimals(dec or 3)
			PaintAsBody(pnl.TextArea,true)
			pnl.TextArea:SetCursorColor(color_white)
			PaintAsH2(pnl.Label,true)
			pnl.OnValueChanged = func
			if cvar then
				pnl:SetValue(GetConVar(cvar):GetFloat())
				pnl:SetDefaultValue(GetConVar(cvar):GetDefault())
			end
			pnl:Dock(TOP)
			return pnl
		end
		Base.Scroller.CreateTextEntry = function(self,text,func,cvar)
			local pnl = self:Add("DTextEntry")
			pnl:SetPlaceholderText(text)
			pnl:SetCursorColor(color_white)
			pnl.OnChange = func
			if cvar then
				pnl:SetValue(GetConVar(cvar):GetString())
			end
			pnl:Dock(TOP)
			return pnl
		end
		Base.Scroller.CreateCheckBox = function(self,text,func,cvar)
			local pnl = self:Add("DCheckBoxLabel")
			pnl:SetText(text)
			PaintAsH2(pnl,true)
			pnl.OnChange = func
			if cvar then
				pnl:SetValue(GetConVar(cvar):GetBool())
			end
			pnl:Dock(TOP)
			return pnl
		end
		local Scroller = Base.Scroller
		
		
		
		local PPV = {}
		PaintAsH1(Scroller:CreateNewLabel("Server Options"))
		Scroller:CreateSpace()
		PaintAsWarning(Scroller:CreateNewLabel("Note that only Administrators can access this tab."))
		if not LocalPlayer():IsAdmin() then return end
		Scroller:CreateSpace()
		PaintAsQuote(Scroller:CreateNewLabel("Hint: You can reset a Number Slider to its default value by middle mouse clicking."))
		Scroller:CreateSpace()
		PaintAsH1(Scroller:CreateNewLabel("UI Complexity"))
		PaintAsBody(Scroller:CreateNewLabel("A higher complexity means more options are available."))
		PaintAsBody(Scroller:CreateNewLabel("Note that changes are lost if this option is changed without saving."))
		Scroller:CreateComboBox({
			default=control==0 and "Select an option...",
			choices={
				{"1 - Novice",1,control==1},
				{"2 - Veteran",2,control==2},
				{"3 - Expert",3,control==3},
				{"4 - Master",4,control==4},
			},
			onselect=function(self,index,text,data)
				ConZ:SetInt(data)
				if IsValid(Base) then
					PaintWComplexity(Base)
				end
			end
		})
		
		Scroller:CreateSpace()
		if control>0 then
		
			if control>1 then
				
				Scroller:CreateCheckBox("Suppress Developer Messages",function(self,val)
					PPV.dont_msg = val
				end,"propprice_non_developer")
				PaintAsBody(Scroller:CreateNewLabel("Hides the annoying developer messages."))
				Scroller:CreateSpace()
			
			end
		
			Scroller:CreateSpace()
			Scroller:CreateSpace()
			PaintAsH1(Scroller:CreateNewLabel("Multipliers"))
			Scroller:CreateSpace()
			
			Scroller:CreateNumSlider("General Multiplier",0,100,function(self,val)
				PPV.g_mul = val
			end,"propprice_multiplicative_mul")
			PaintAsBody(Scroller:CreateNewLabel("All cost values are multiplied by this value after the formula is applied."))
			Scroller:CreateSpace()
			
			if control>1 then
			
				Scroller:CreateNumSlider("Volume Multiplier",0,100,function(self,val)
					PPV.v_mul = val
				end,"propprice_volume_mul")
				PaintAsQuote(Scroller:CreateNewLabel("\"Huge objects aren't hard to simulate, they are just very annoying in large amounts.\""))
				PaintAsBody(Scroller:CreateNewLabel("The object's volume, in Hu³, is multiplied by this value before the formula is applied."))
				PaintAsBody(Scroller:CreateNewLabel("A value of 0 means that it will be ignored in Multiplicative mode."))
				Scroller:CreateSpace()
				
				Scroller:CreateNumSlider("Complexity Multiplier",0,100,function(self,val)
					PPV.c_mul = val
				end,"propprice_meshcomplexity_mul")
				PaintAsQuote(Scroller:CreateNewLabel("\"Complex collision models are one of the key reasons why Garry's Mod crashes so much.\""))
				PaintAsBody(Scroller:CreateNewLabel("The object's mesh count is multiplied by this value before the formula is applied."))
				PaintAsBody(Scroller:CreateNewLabel("A value of 0 means that it will be ignored in Multiplicative mode."))
				Scroller:CreateSpace()
				
				if control>2 then
				
					Scroller:CreateNumSlider("Sphere Complexity",0,1000,function(self,val)
						PPV.sphere_c = val
					end,"propprice_sphere_complexity")
					PaintAsBody(Scroller:CreateNewLabel("Perfect spheres have an infinite amount of points, and therefore would have infinite complexity."))
					PaintAsBody(Scroller:CreateNewLabel("This value allows you to override the complexity value of spheres."))
					PaintAsBody(Scroller:CreateNewLabel("Note that this value is affected by the Complexity Multiplier."))
					Scroller:CreateSpace()
					
				end
				
				Scroller:CreateNumSlider("Mass Multiplier",0,100,function(self,val)
					PPV.m_mul = val
				end,"propprice_mass_mul")
				PaintAsQuote(Scroller:CreateNewLabel("\"Again, massive objects aren't hard to simulate, it's just that they are always misused.\""))
				PaintAsBody(Scroller:CreateNewLabel("The object's mass, in kg, is multiplied by this value before the formula is applied."))
				PaintAsBody(Scroller:CreateNewLabel("A value of 0 means that it will be ignored in Multiplicative mode."))
				Scroller:CreateSpace()
				
			end
			
			if control>1 then
			
				Scroller:CreateSpace()
				Scroller:CreateSpace()
				PaintAsH1(Scroller:CreateNewLabel("Calculations"))
				Scroller:CreateSpace()
				
				if control>2 then
			
					Scroller:CreateNumSlider("Default Value",0,10000,function(self,val)
						PPV.def_val = val
					end,"propprice_default",2)
					PaintAsBody(Scroller:CreateNewLabel("If the price of an object can't be computed, due to the lack of a Physics Object or a syntax error in the Custom formula, the default value is used instead."))
					PaintAsBody(Scroller:CreateNewLabel("Note that it is affected by the Global Multiplier."))
					Scroller:CreateSpace()
				
				end
				
				PaintAsH2(Scroller:CreateNewLabel("Calculation Mode"))
				PaintAsBody(Scroller:CreateNewLabel("This option determines the mode to calculate total cost."))
				if control<3 then
				
					Scroller:CreateComboBox({
						choices={
							{"Additive (v+c+m)",0,true},
							{"Multiplicative (v*c*m)",1}
						},
						onselect=function(self,index,text,data)
							PPV.mode = data
						end
					},"propprice_mode")
					Scroller:CreateSpace()
					
				else
				
					Scroller:CreateComboBox({
						noSort=true,
						choices={
							{"Additive (v+c+m)",0,true},
							{"Multiplicative (v*c*m)",1},
							{"Custom",2}
						},
						onselect=function(self,index,text,data)
							PPV.mode = data
						end
					},"propprice_mode")
					Scroller:CreateSpace()
					
					PaintAsH2(Scroller:CreateNewLabel("Formula To Use"))
					PaintAsBody(Scroller:CreateNewLabel("If Custom is selected as the calculation mode, the formula typed below is used, with the following variables:"))
					PaintAsBody(Scroller:CreateNewLabel("v - Volume Of Object, in Hu³"))
					PaintAsBody(Scroller:CreateNewLabel("c - Complexity Of Object"))
					PaintAsBody(Scroller:CreateNewLabel("m - Mass Of Object, in kg"))
					PaintAsBody(Scroller:CreateNewLabel(""))
					PaintAsQuote(Scroller:CreateNewLabel("(Leave out any variables you do not wish to use.)"))
					PaintAsBody(Scroller:CreateNewLabel(""))
					PaintAsBody(Scroller:CreateNewLabel("Examples:"))
					PaintAsBody(Scroller:CreateNewLabel("v+c*m^2 - Adds v with the product of c and the square of m."))
					PaintAsBody(Scroller:CreateNewLabel("v^-c/m^(1/2) - Divides v to the power of -c with the square root of m."))
					PaintAsBody(Scroller:CreateNewLabel("v^(1/3)%c-m - Divides the cube root of v with c, gets its remainder, then subtracts it by m."))
					local fEntry = Scroller:CreateTextEntry("Enter Formula Here",function(self)
						PPV.formula = self:GetValue()
					end,"propprice_custom_formula")
					Scroller:CreateSpace()
					
				end
				
				Scroller:CreateNumSlider("Additional Price",0,10000,function(self,val)
					PPV.add_price = val
				end,"propprice_add",2)
				PaintAsBody(Scroller:CreateNewLabel("The price of any object is added by this value after all price modifiers has been applied."))
				PaintAsBody(Scroller:CreateNewLabel("Note that this variable is still affected by the Sell Multiplier."))
				Scroller:CreateSpace()
				
				if control>3 then
				
					Scroller:CreateCheckBox("Cache Prices",function(self,val)
						PPV.do_cache = val
					end,"propprice_cache_spawnprices")
					PaintAsBody(Scroller:CreateNewLabel("Determines whether or not prices are cached after calculation."))
					PaintAsBody(Scroller:CreateNewLabel("If this option is enabled, cash is deducted AFTER objects have spawned, not before."))
					PaintAsBody(Scroller:CreateNewLabel("Best with Enable Overdraft enabled."))
					Scroller:CreateSpace()
					
				end
				
			end
			
			Scroller:CreateSpace()
			Scroller:CreateSpace()
			PaintAsH1(Scroller:CreateNewLabel("Buying and Selling"))
			Scroller:CreateSpace()
			
			if control>3 then
			
				Scroller:CreateNumSlider("Users Can Buy Admin Privileges",0,2,function(self,val)
					PPV.buy_admin = val
				end,"propprice_enable_admin_purchase",0)
				PaintAsBody(Scroller:CreateNewLabel("While this is active, users can purchase administrator privileges of the server if they can buy the entire map."))
				PaintAsBody(Scroller:CreateNewLabel("1: Excluding Props In The Map"))
				PaintAsBody(Scroller:CreateNewLabel("2: Including Props In The Map (Experimental!)"))
				PaintAsBody(Scroller:CreateNewLabel("They will be given a prompt if they aren't an administrator and if they have enough money to do so."))
				PaintAsBody(Scroller:CreateNewLabel("You can check the cost of the map by the console command \"propprice_getworldcost\". It is usually in the trillions and affected by the multipliers above."))
				PaintAsWarning(Scroller:CreateNewLabel("This option is EXTREMELY dangerous. Enable at your own risk."))
				Scroller:CreateSpace()
			
			end
			
			Scroller:CreateNumSlider("Sell Multiplier",0,1,function(self,val)
				PPV.s_mul = val
			end,"propprice_sell_mul")
			PaintAsBody(Scroller:CreateNewLabel("Whenever an object has been sold, the user gains cash equal to its full price multiplied by this value."))
			Scroller:CreateSpace()
			
			if control>1 then
			
				if control>3 then
			
					Scroller:CreateCheckBox("Strict Selling Rules",function(self,val)
						PPV.strict_selling = val
					end,"propprice_strict_selling")
					PaintAsBody(Scroller:CreateNewLabel("While this is active, broken props are NOT considered sold."))
					PaintAsBody(Scroller:CreateNewLabel("This option is highly experimental and may not do anything at all."))
					Scroller:CreateSpace()
				
				end
				
				Scroller:CreateCheckBox("Enable Overdraft",function(self,val)
					PPV.overdrafting = val
				end,"propprice_overdrafting")
				PaintAsBody(Scroller:CreateNewLabel("Allow players to keep spawning props until their cash becomes negative."))
				Scroller:CreateSpace()
				
			end
			
			Scroller:CreateSpace()
			Scroller:CreateSpace()
			PaintAsH1(Scroller:CreateNewLabel("Saving Options"))
			Scroller:CreateSpace()
			
			Scroller:CreateNumSlider("Initial Cash",0,1000000,function(self,val)
				PPV.i_c = val
			end,"propprice_initialcash",2)
			PaintAsBody(Scroller:CreateNewLabel("How much cash should new players start with."))
			Scroller:CreateSpace()
			
			Scroller:CreateNumSlider("Initial Income Amount",0,100000,function(self,val)
				PPV.i_i = val
			end,"propprice_packet_amount",2)
			PaintAsBody(Scroller:CreateNewLabel("How much income should new players start with."))
			Scroller:CreateSpace()
			
			if control>1 then
			
				Scroller:CreateCheckBox("Save Player Cash And Income",function(self,val)
					PPV.sav_p = val
				end,"propprice_save_players_cash_to_file")
				PaintAsBody(Scroller:CreateNewLabel("Write all players' cash and income into data/propprice/players.dat so that it can be loaded later."))
				PaintAsBody(Scroller:CreateNewLabel("You can use the console command \"propprice_resetplayers\" to delete the file and reset all players' cash and income amounts."))
				Scroller:CreateSpace()
			
				if control>3 then
				
					Scroller:CreateCheckBox("Save Model Prices",function(self,val)
						PPV.sav_r = val
					end,"propprice_save_prices_to_file")
					PaintAsBody(Scroller:CreateNewLabel("Write prices for models into data/propprice/prices.dat so that it can be loaded later. Requires Cache Prices to be enabled."))
					PaintAsBody(Scroller:CreateNewLabel("You can manually modify this file while the server is down to adjust the price of a certain model."))
					PaintAsBody(Scroller:CreateNewLabel("Note that while this option is active, all models retain their prices according to the file, meaning any price changes to a model won't have any effect if the model exists within the file."))
					PaintAsBody(Scroller:CreateNewLabel("You can use the console command \"propprice_clearcache\" to delete the cache and the file."))
					Scroller:CreateSpace()
					
				end
				
			end
			
			Scroller:CreateSpace()
			Scroller:CreateSpace()
			PaintAsH1(Scroller:CreateNewLabel("Cash Earnings"))
			Scroller:CreateSpace()
			
			Scroller:CreateNumSlider("Packet Delay",0,600,function(self,val)
				PPV.p_del = val
			end,"propprice_packet_delay")
			PaintAsBody(Scroller:CreateNewLabel("Sets the delay in-between income packets."))
			Scroller:CreateSpace()
			
			Scroller:CreateNumSlider("Cash On Kill Multiplier",0,100,function(self,val)
				PPV.k_c = val
			end,"propprice_kill_mul")
			PaintAsBody(Scroller:CreateNewLabel("Players that kill NPCs gain cash equal to the NPC's maximum health times this value."))
			Scroller:CreateSpace()
			
			Scroller:CreateNumSlider("Income On Kill Multiplier",0,100,function(self,val)
				PPV.k_i = val
			end,"propprice_kill_increment_income_rate_mul")
			PaintAsBody(Scroller:CreateNewLabel("Players that kill NPCs gain income equal to the NPC's maximum health times this value."))
			Scroller:CreateSpace()
			
			if control>1 then
			
				Scroller:CreateNumSlider("Income On Purchase",0,1,function(self,val)
					PPV.i_p = val
				end,"propprice_income_on_purchase")
				PaintAsBody(Scroller:CreateNewLabel("Players that place entities gain income equal to the entity's cost times this value."))
				Scroller:CreateSpace()
			
				if control>2 then
			
					Scroller:CreateNumSlider("Income Lost On Sell",0,1,function(self,val)
						PPV.s_p = val
					end,"propprice_lost_income_on_sell")
					PaintAsBody(Scroller:CreateNewLabel("Players that remove entities lose income equal to the entity's income from Income On Purchase times this value."))
					Scroller:CreateSpace()
				
				end
			
			end
			
			PaintAsBody(Scroller:CreateNewLabel("There are also several commands to change the amount of a certain player's cash or income:"))
			PaintAsBody(Scroller:CreateNewLabel("propprice_setcash / propprice_addcash / propprice_subcash : Modifies a player's cash."))
			PaintAsBody(Scroller:CreateNewLabel("propprice_setincome / propprice_addincome / propprice_subincome : Modifies a player's income."))
			PaintAsBody(Scroller:CreateNewLabel("propprice_summary : Get everyone's income. Can be used by non-admins, but only once every 10 seconds."))
		
			local SaveButton = Scroller:Add("DButton")
			PaintAsH1(SaveButton,true)
			SaveButton.DoClick = function()
				net.Start("PropPrice")
				net.WriteString("options_server")
				net.WriteTable(PPV)
				net.SendToServer()
				chat.AddText(Color(0,255,255),"Options sent to server.")
			end
			SaveButton:SetText("Save Changes")
			SaveButton.Paint = function(self,w,h)
				draw.RoundedBox(8,0,0,w,h,self:IsDown() and Color(127,127,127,191) or self:IsHovered() and Color(63,63,63,191) or Color(0,0,0,191))
			end
			SaveButton:Dock(TOP)
			
		end
		
	end
	
	local function PaintSlider(slider)
		PaintAsH2(slider.Label,true)
		PaintAsBody(slider.TextArea,true)
		slider.TextArea:SetCursorColor(color_white)
	end
	
	local LoadPPGUI
	
	LoadPPGUI = function()
		local Main = vgui.Create("DFrame")
		Main:SetSize(ScrW()/3,ScrH()/1.5)
		Main:Center()
		Main:SetTitle("")
		Main:MakePopup()
		Main.Paint = function(self,w,h)
			StandardSkin(self,w,h)
			if self:HasFocus() then
				draw.RoundedBox(8,0,0,w,24,Color(0,0,0,127))
			end
			draw.SimpleText("PropPrice Options","DermaDefaultBold")
		end
		
		local ClientPanel = vgui.Create("DScrollPanel",Main)
		ClientPanel.Paint = StandardSkin
		ClientPanel:Dock(FILL)
		
		local Form = vgui.Create("DForm",ClientPanel)
		Form:SetName("Client Options")
		Form:Dock(FILL)
		Form.Paint = nullfunc
		PaintAsH1(Form.Header,true)
		local SaveText = Label("Unlike settings in the Server tab, changes to these settings are saved immediately.",Form)
		PaintAsH2(SaveText,true)
		SaveText:SizeToContents()
		Form:AddItem(SaveText)
		local Blank = vgui.Create("DPanel",Form)
		Blank:SetSize(16,16)
		Blank.Paint = nullfunc
		Form:AddItem(Blank)
		PaintAsH2((Form:CheckBox("Enable HUD","propprice_hud_enable")).Label,true)
		PaintAsH2((Form:CheckBox("Show $ Sign","propprice_show_s")).Label,true)
		PaintSlider(Form:NumSlider("X Position","propprice_hud_x",0,1,3))
		PaintSlider(Form:NumSlider("Y Position","propprice_hud_y",0,1,3))
		
		local Blank = vgui.Create("DPanel",Form)
		Blank:SetSize(16,16)
		Blank.Paint = nullfunc
		Form:AddItem(Blank)
		local AnimText = Label("Cash Changed Animations",Form)
		PaintAsH1(AnimText,true)
		AnimText:SizeToContents()
		Form:AddItem(AnimText)
		
		PaintSlider(Form:NumSlider("Text Slide By X","propprice_hud_slide_x",-1,1,3))
		PaintSlider(Form:NumSlider("Text Slide By Y","propprice_hud_slide_y",-1,1,3))
		PaintSlider(Form:NumSlider("Animation Time","propprice_hud_change_lifetime",0,10,3))
		
		local Blank = vgui.Create("DPanel",Form)
		Blank:SetSize(16,16)
		Blank.Paint = nullfunc
		Form:AddItem(Blank)
		local AnimText = Label("Income Positioning",Form)
		PaintAsH1(AnimText,true)
		AnimText:SizeToContents()
		Form:AddItem(AnimText)
		
		PaintSlider(Form:NumSlider("Income X Position","propprice_hud_income_x",-1,1,3))
		PaintSlider(Form:NumSlider("Income Y Position","propprice_hud_income_y",-1,1,3))
		
		local Blank = vgui.Create("DPanel",Form)
		Blank:SetSize(16,16)
		Blank.Paint = nullfunc
		Form:AddItem(Blank)
		local AnimText = Label("Income Changed Animations",Form)
		PaintAsH1(AnimText,true)
		AnimText:SizeToContents()
		Form:AddItem(AnimText)
		
		PaintSlider(Form:NumSlider("Income Text Slide By X","propprice_hud_income_slide_x",-1,1,3))
		PaintSlider(Form:NumSlider("Income Text Slide By Y","propprice_hud_income_slide_y",-1,1,3))
		PaintSlider(Form:NumSlider("Income Animation Time","propprice_hud_income_change_lifetime",0,10,3))
		
		local Tabs = vgui.Create("DPropertySheet",Main)
		Tabs:Dock(FILL)
		Tabs.Paint = nullfunc
		local CSheet = Tabs:AddSheet("Client",ClientPanel,"icon16/computer.png")
		CSheet.Tab.Paint = function(self,w,h)
			if self:IsActive() then
				draw.RoundedBoxEx(8,0,0,w,h,Color(0,0,0,191),true,true)
			end
		end
		
		local ServerPanel = vgui.Create("DPanel",Main)
		ServerPanel.Paint = StandardSkin
		ServerPanel:Dock(FILL)
		local SSheet = Tabs:AddSheet("Server",ServerPanel,"icon16/server.png")
		SSheet.Tab.Paint = function(self,w,h)
			if self:IsActive() then
				draw.RoundedBoxEx(8,0,0,w,h,Color(0,0,0,191),true,true)
			end
		end
		
		PaintWComplexity(ServerPanel,0)
	end
	
	concommand.Add("propprice_open_gui",LoadPPGUI)
	
	

	local fontsize = 32
	local iconsize = 32
	local money_mat = Material"icon16/money.png"
	local money_add = Material"icon16/money_add.png"
	local money_sub = Material"icon16/money_delete.png"
	local inc_mat = Material"icon16/package.png"
	local inc_add = Material"icon16/package_add.png"
	local inc_sub = Material"icon16/package_delete.png"
	local oldcash = 0
	local oldcash2 = 0
	local oldinc = 0
	local oldinc2 = 0
	local trigtime = 0
	local trigtime2 = 0
	local trigtime3 = 0

	surface.CreateFont("PropPrice_Cash",{
		font="Luckiest Guy",
		size=fontsize
	})
	
	hook.Add("HUDPaint","PropPrice",function()
		if ConE:GetBool() then
			local realtime = RealTime()
			local scrW,scrH = ScrW(),ScrH()
			local newcash =  math.Round(LocalPlayer():PP_GetCash(),2)
			local newinc =  math.Round(LocalPlayer():PP_GetIncome(),2)
			local posx,posy = scrW*ConX:GetFloat(),scrH*ConY:GetFloat()
			local posx2,posy2 = posx+scrW*ConA:GetFloat(),posy+scrH*ConB:GetFloat()
			local dropfactX = ConW:GetFloat()
			local dropfact = ConH:GetFloat()
			local dropfactX2 = ConC:GetFloat()
			local dropfact2 = ConD:GetFloat()
			local holdtime = ConF:GetFloat()
			local holdtime2 = ConL:GetFloat()
			local s_sign = ConS:GetBool() and "$" or ""
			local function CalcTextDisp(num)
				return s_sign..string.Comma(math.floor(num))..string.format(".%02u",math.floor(num%1*100))
			end
			if oldcash2 ~= newcash or trigtime > realtime then
				if oldcash2 ~= newcash then
					trigtime = realtime + holdtime
					oldcash2 = newcash
				end
				local delta = 1 - (trigtime-realtime) / holdtime
				local curEase = math.EaseInOut(delta,0,1)
				local desX = posx-iconsize+curEase*scrW*dropfactX
				local desX2 = posx+curEase*scrW*dropfactX
				local desY = posy+fontsize/2-iconsize/2+curEase*scrH*dropfact
				local desY2 = posy+curEase*scrH*dropfact
				if oldcash < newcash then
					surface.SetMaterial(money_add)
					surface.SetDrawColor(color_white)
					surface.DrawTexturedRect(desX,desY,iconsize,iconsize)
					draw.SimpleTextOutlined("+"..CalcTextDisp(newcash-oldcash),"PropPrice_Cash",desX2,desY2,Color(0,255,0),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
				else
					surface.SetMaterial(money_sub)
					surface.SetDrawColor(color_white)
					surface.DrawTexturedRect(desX,desY,iconsize,iconsize)
					draw.SimpleTextOutlined("-"..CalcTextDisp(oldcash-newcash),"PropPrice_Cash",desX2,desY2,Color(255,0,0),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
				end
			elseif trigtime <= realtime then
				oldcash = newcash
			end
			if oldinc2 ~= newinc or trigtime2 > realtime then
				if oldinc2 ~= newinc then
					trigtime2 = realtime + holdtime2
					oldinc2 = newinc
				end
				local delta = 1 - (trigtime2-realtime) / holdtime2
				local curEase = math.EaseInOut(delta,0,1)
				local desX = posx2-iconsize+curEase*scrW*dropfactX2
				local desX2 = posx2+curEase*scrW*dropfactX2
				local desY = posy2+fontsize/2-iconsize/2+curEase*scrH*dropfact2
				local desY2 = posy2+curEase*scrH*dropfact2
				if oldinc < newinc then
					surface.SetMaterial(inc_add)
					surface.SetDrawColor(color_white)
					surface.DrawTexturedRect(desX,desY,iconsize,iconsize)
					draw.SimpleTextOutlined("+"..CalcTextDisp(newinc-oldinc),"PropPrice_Cash",desX2,desY2,Color(0,255,0),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
				else
					surface.SetMaterial(inc_sub)
					surface.SetDrawColor(color_white)
					surface.DrawTexturedRect(desX,desY,iconsize,iconsize)
					draw.SimpleTextOutlined("-"..CalcTextDisp(oldinc-newinc),"PropPrice_Cash",desX2,desY2,Color(255,0,0),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
				end
			elseif trigtime2 <= realtime then
				oldinc = newinc
			end
			if LocalPlayer().PP_ShouldCost then
				if LocalPlayer().PP_ShouldCost == 0 then
					chat.AddText(Color(255,127,127),"You need pay off your debt before you buy that!")
				else
					chat.AddText(Color(255,127,127),"You need an additional ",CalcTextDisp(LocalPlayer().PP_ShouldCost-newcash)," to buy that!")
				end
				LocalPlayer().PP_ShouldCost = nil
				trigtime3 = realtime + holdtime
			end
			local doflash = (1-(trigtime3-realtime)/holdtime)*8%2<1
			local desiredColCos = newcash>=0 and color_white or Color(255,0,0)
			if trigtime3>realtime then
				desiredColCos = doflash and color_white or Color(255,0,0)
			end
			surface.SetDrawColor(color_white)
			surface.SetMaterial(money_mat)
			surface.DrawTexturedRect(posx-iconsize,posy+fontsize/2-iconsize/2,iconsize,iconsize)
			draw.SimpleTextOutlined(CalcTextDisp(newcash),"PropPrice_Cash",posx,posy,desiredColCos,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
			surface.SetMaterial(inc_mat)
			surface.DrawTexturedRect(posx2-iconsize,posy2+fontsize/2-iconsize/2,iconsize,iconsize)
			draw.SimpleTextOutlined(CalcTextDisp(newinc),"PropPrice_Cash",posx2,posy2,newinc>=0 and color_white or Color(255,0,0),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,color_black)
		end
	end)
	
end