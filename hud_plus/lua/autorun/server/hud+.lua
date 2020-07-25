HUD_PLUS = {}
HUD_PLUS.signal_rate = 20
HUD_PLUS.last_signal = 0
HUD_PLUS.classname_assigns = util.JSONToTable(file.Read("hud+_classassigns.txt","DATA") or "") or {}

util.AddNetworkString("HUD+")

concommand.Add("hud_plus_classname_assign",function(ply,cmdStr,args)
	if (not IsValid(ply) or ply:IsAdmin()) then
		if #args==0 then
			MsgC(Color(0,255,0), "[HUD+] ", color_white, "Current classname name assignments are the following:\n",
				util.TableToJSON(HUD_PLUS.classname_assigns,true), "\nUsage: hud_plus_classname_assign <classname> <displayName> <classname> <displayName> ...\n",
				"If display name / classname contains spaces, surround it with double quotation marks (\"Display Name\").\n",
				"If display name is * the entry is removed instead.\n"
			)
		elseif #args%2==0 then
			for i=1,#args-1,2 do
				if args[i+1] == "*" then
					HUD_PLUS.classname_assigns[args[i]] = nil
					MsgC(Color(0,255,0), "[HUD+] ", color_white, "Removed ", args[i], " from the classname assignment table.\n")
				else
					HUD_PLUS.classname_assigns[args[i]] = args[i+1]
					MsgC(Color(0,255,0), "[HUD+] ", color_white, "Added ", args[i], " with value ", args[i+1], " into the classname assignment table.\n")
				end
			end
			net.Start("HUD+")
			net.WriteString("class-name-assignment")
			net.WriteUInt(table.Count(HUD_PLUS.classname_assigns),16)
			for k,v in pairs(HUD_PLUS.classname_assigns) do
				net.WriteString(k)
				net.WriteString(v)
			end
			net.Broadcast()
			file.Write("hud+_classassigns.txt",util.TableToJSON(HUD_PLUS.classname_assigns))
		else
			MsgC(Color(0,255,0), "[HUD+] ", color_white, "Usage: hud_plus_classname_assign <classname> <displayName> <classname> <displayName> ...\n")
		end
	else
		MsgC(Color(0,255,0), "[HUD+] ", color_white, "Access denied - you don't have admin privileges!\n")
	end
end)

local ConS = CreateConVar("hud_plus_server_mem_update_rate","20",FCVAR_ARCHIVE)

timer.Create("HUD+KEEPSsendingCLIENTnames",20,0,function()
	if next(HUD_PLUS.classname_assigns) then
		net.Start("HUD+")
		net.WriteString("class-name-assignment")
		net.WriteUInt(table.Count(HUD_PLUS.classname_assigns),16)
		for k,v in pairs(HUD_PLUS.classname_assigns) do
			net.WriteString(k)
			net.WriteString(v)
		end
		net.Broadcast()
	end
end)

--hook.Add("PlayerSpawn","HUD+",)

HUD_PLUS.entities = {}

hook.Add("OnEntityCreated","HUD+",function(ent)
	table.insert(HUD_PLUS.entities, ent)
end)

hook.Add("Think","HUD+",function()
	if HUD_PLUS.last_signal < CurTime() then
		for k,target in pairs(HUD_PLUS.entities) do
			if IsValid(target) then
				target:SetNWInt("HUD_PLUS.HEALTH",target:Health())
				target:SetNWInt("HUD_PLUS.MAX_HEALTH",target:GetMaxHealth())
				if target.Armor then
					if (isfunction(target.Armor) and tonumber(target:Armor()) and target:Armor()>0) then
						target:SetNWInt("HUD_PLUS.ARMOR",target:Armor())
					elseif (tonumber(target.Armor) or 0) > 0 then
						target:SetNWInt("HUD_PLUS.ARMOR",target.Armor)
					end
				end
			else
				HUD_PLUS.entities[k] = nil
			end
		end
		HUD_PLUS.last_signal = CurTime() + 1/HUD_PLUS.signal_rate
		net.Start("HUD+",true)
		net.WriteString("mem-server")
		net.WriteString(string.format("%u",collectgarbage("count")))
		net.Broadcast()
	end
	HUD_PLUS.signal_rate = ConS:GetFloat()
end)

--[[hook.Add("EntityTakeDamage","HUD+",function(target)
	timer.Simple(0,function()
		if IsValid(target) then
		end
	end)
end)]]