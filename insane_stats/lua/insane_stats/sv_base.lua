gameevent.Listen("entity_killed")
gameevent.Listen("break_prop")
gameevent.Listen("break_breakable")

local currentSaveFile = InsaneStats:GetConVarValue("save_file") or "default"

function InsaneStats:Save(data)
	if not file.IsDir("insane_stats", "DATA") then
		file.CreateDir("insane_stats")
	end
	local saveFileName = "insane_stats/"..currentSaveFile..".json"
	if InsaneStats:IsDebugLevel(3) then
		InsaneStats:Log("Saved data:")
		PrintTable(data)
	end
	file.Write(saveFileName, util.TableToJSON(data))
end

function InsaneStats:Load()
	local saveFileName = "insane_stats/"..currentSaveFile..".json"
	if file.Exists("insane_stats.txt", "DATA") then
		file.Rename("insane_stats.txt", saveFileName)
	end
	return util.JSONToTable(file.Read(saveFileName) or "") or {}
end

function InsaneStats:WildcardMatches(wildcard, subject)
	if wildcard == '*' then return true end
	local searchStr = wildcard:lower():PatternSafe():gsub('(%%.)', {
		['%*'] = '.*',
		['%?'] = '.'
	})
	return (subject:lower():match('^'..searchStr..'$'))
end

hook.Add("OnEntityCreated", "InsaneStats", function(ent)
	timer.Simple(0, function()
		if (IsValid(ent) and not ent:IsPlayer()) then
			hook.Run("InsaneStatsTransitionCompat", ent)
			hook.Run("InsaneStatsEntityCreated", ent)
		end
	end)
end)

hook.Add("entity_killed", "InsaneStats", function(data)
	local victim = Entity(data.entindex_killed or 0)
	local attacker = Entity(data.entindex_attacker or 0)
	local inflictor = Entity(data.entindex_inflictor or 0)
	
	hook.Run("InsaneStatsEntityKilled", victim, attacker, inflictor)
end)

hook.Add("OnNPCKilled", "InsaneStats", function(victim, attacker, inflictor)
	hook.Run("InsaneStatsEntityKilled", victim, attacker, inflictor)
end)

hook.Add("LambdaOnKilled", "InsaneStats", function(victim, dmginfo)
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	hook.Run("InsaneStatsEntityKilled", victim, attacker, inflictor)
end)

-- AcceptInput and InsaneStatsEntityCreated: see MISC section

local needCorrectiveDeathClasses = {
	npc_combine_camera=true,
	npc_turret_ceiling=true,
}

hook.Add("PostEntityTakeDamage", "InsaneStats", function(victim, dmginfo, took)
	if needCorrectiveDeathClasses[victim:GetClass()] and victim:InsaneStats_GetHealth() <= 0 then
		local attacker = dmginfo:GetAttacker()
		local inflictor = dmginfo:GetInflictor()
		hook.Run("InsaneStatsEntityKilled", victim, attacker, inflictor)
	end
end)

-- MISC

concommand.Add("insanestats_save", function(ply, cmd, args, argStr)
	if ply:IsAdmin() then
		local data = InsaneStats:Load()
		hook.Run("InsaneStatsSave", data)
		InsaneStats:Save(data)

		InsaneStats:Log("Data saved!")
	else
		InsaneStats:Log("This command can only be run by admins!")
	end
end, nil, "Saves all Insane Stats data immediately.")

concommand.Add("insanestats_revert_all_convars", function(ply, cmd, args, argStr)
	if argStr:lower() == "yes" then
		for name, data in pairs(InsaneStats.conVars) do
			if data.conVar then
				data.conVar:Revert()
			end
		end
		InsaneStats:Log("All server-side Insane Stats ConVars have been reverted!")
	else
		InsaneStats:Log("Reverts all server-side Insane Stats ConVars. You must pass the argument \"yes\" for this command to work.")
	end
end, nil, "Reverts all server-side Insane Stats ConVars. You must pass the argument \"yes\" for this command to work.")

-- For some reason "color" isn't included under game_text:GetKeyValues(). Why?
hook.Add("EntityKeyValue", "InsaneStats", function(ent, key, value)
	if ent:GetClass() == "game_text" and key == "color" then
		ent.insaneStats_TextColor = string.ToColor(value.." 255")
	elseif ent:GetClass() == "info_player_coop" and key == "StartDisabled" then
		ent.insaneStats_Disabled = tobool(value)
	end
end)

local pendingGameTexts = {}
local activeCamera = NULL
hook.Add("AcceptInput", "InsaneStats", function(ent, input, activator, caller, value)
	input = input:lower()
	data = data or ""
	local class = ent:GetClass()
	if input == "insanestats_onnpckilled" then
		hook.Run("InsaneStatsEntityKilled", caller, activator, activator)
	elseif input == "deactivate" and class == "func_tank_combine_cannon" then
		hook.Run("InsaneStatsEntityKilled", ent, activator, activator)
	elseif input == "insanestats_onjoinedplayersquad" then
		ent.insaneStats_CitizenFlags = bit.bor(ent.insaneStats_CitizenFlags or 0, 4)
		ent:InsaneStats_MarkForUpdate(256)
	elseif input == "insanestats_onleftplayersquad" then
		ent.insaneStats_CitizenFlags = bit.band(ent.insaneStats_CitizenFlags or 0, bit.bnot(4))
		ent:InsaneStats_MarkForUpdate(256)
	elseif input == "display" then
		if class == "game_text" and InsaneStats:GetConVarValue("gametext_tochat")
		and not (InsaneStats:GetConVarValue("gametext_tochat_once") and ent.insaneStats_DisplayedInChat) then
			local keyValues = ent:GetKeyValues()
			local xPos = tonumber(keyValues.x)
			local yPos = tonumber(keyValues.y)
			local color = ent.insaneStats_TextColor
			if not IsColor(color) then -- oh come on
				color = Color(color.r, color.g, color.b, color.a)
			end
			
			table.insert(pendingGameTexts, {
				order = (xPos < 0 and 0.5 or xPos) + (yPos < 0 and 0.5 or yPos),
				t = keyValues.message,
				c = ent.insaneStats_TextColor,
				target = not ent:HasSpawnFlags(1) and activator:IsPlayer() and activator
			})
			ent.insaneStats_DisplayedInChat = true
		end
	elseif input == "disableflashlight" and ent:IsPlayer() then
		ent.insaneStats_FlashlightDisabled = true
	elseif input == "enableflashlight" and ent:IsPlayer() then
		ent.insaneStats_FlashlightDisabled = nil
	elseif input == "modifyspeed" and class == "player_speedmod"
	and InsaneStats:GetConVarValue("flashlight_disable_fix_modifyspeed") then
		for i,v in player.Iterator() do
			v.insaneStats_FlashlightDisabled = tonumber(value) ~= 1 or nil
		end
	elseif class == "point_viewcontrol" and InsaneStats:GetConVarValue("camera_no_kill") then
		if input == "kill" then
			ent:Fire("Disable")
			return true
		elseif input == "disable" and ent ~= activeCamera then
			return true
		elseif input == "enable" then
			activeCamera = ent
		end
	elseif class == "npc_citizen" then
		if input == "setmedicon" then
			ent.insaneStats_CitizenFlags = bit.bor(ent.insaneStats_CitizenFlags or 0, 1)
			ent:InsaneStats_MarkForUpdate(256)
		elseif input == "setmedicoff" then
			ent.insaneStats_CitizenFlags = bit.band(ent.insaneStats_CitizenFlags or 0, bit.bnot(1))
			ent:InsaneStats_MarkForUpdate(256)
		elseif input == "setammoresupplieron" then
			ent.insaneStats_CitizenFlags = bit.bor(ent.insaneStats_CitizenFlags or 0, 2)
			ent:InsaneStats_MarkForUpdate(256)
		elseif input == "setammoresupplieroff" then
			ent.insaneStats_CitizenFlags = bit.band(ent.insaneStats_CitizenFlags or 0, bit.bnot(2))
			ent:InsaneStats_MarkForUpdate(256)
		end
	end
end)

hook.Add("InsaneStatsEntityCreated", "InsaneStats", function(ent)
	if ent:IsNPC() then
		ent:Fire("AddOutput", "OnDeath !activator:InsaneStats_OnNPCKilled")
		if ent:GetClass()=="npc_helicopter" then
			ent:Fire("AddOutput", "OnShotDown !activator:InsaneStats_OnNPCKilled")
		elseif ent:GetClass()=="npc_turret_floor" then
			ent:Fire("AddOutput", "OnTipped !self:InsaneStats_OnNPCKilled")
		elseif ent:GetClass()=="npc_citizen" then
			ent.insaneStats_CitizenFlags = 0
			if ent:HasSpawnFlags(SF_CITIZEN_MEDIC) then
				ent.insaneStats_CitizenFlags = bit.bor(ent.insaneStats_CitizenFlags, 1)
			end
			if ent:HasSpawnFlags(SF_CITIZEN_AMMORESUPPLIER) then
				ent.insaneStats_CitizenFlags = bit.bor(ent.insaneStats_CitizenFlags, 2)
			end
			ent:Fire("AddOutput", "OnJoinedPlayerSquad !self:InsaneStats_OnJoinedPlayerSquad")
			ent:Fire("AddOutput", "OnLeftPlayerSquad !self:InsaneStats_OnLeftPlayerSquad")
			ent:InsaneStats_MarkForUpdate(256)
		end
	elseif ent:GetClass()=="prop_vehicle_apc" then
		ent:Fire("AddOutput", "OnDeath !activator:InsaneStats_OnNPCKilled")
		if IsValid(ent:GetDriver()) then
			ent:Fire("AddOutput","OnDeath "..ent:GetDriver():GetName()..":Kill")
		end
	end
end)

function InsaneStats:PerformSave()
	-- do not save within the first 20 seconds, as this can cause data loss
	if CurTime() > 20 then
		local data = self:Load()
		hook.Run("InsaneStatsSave", data)
		self:Save(data)
		--[[if GetConVar("developer"):GetInt() > 0 then
			print("Save data:")
			PrintTable(data)
		end]]
	end
end

local function SaveData()
	InsaneStats:PerformSave()
end

local saveThinkCooldown = 0
hook.Add("Think", "InsaneStats", function()
	if saveThinkCooldown < RealTime() then
		InsaneStats:PerformSave()
		saveThinkCooldown = RealTime() + 30
	end

	if next(pendingGameTexts) then
		for k,v in SortedPairsByMemberValue(pendingGameTexts, "order") do
			if not IsColor(v.c) then
				v.c = Color(v.c.r, v.c.g, v.c.b, v.c.a)
			end
			net.Start("insane_stats")
			net.WriteUInt(5, 8)
			net.WriteString(v.t)
			net.WriteColor(v.c)
			if v.target then
				net.Send(v.target)
			else
				net.Broadcast()
			end
		end
		
		pendingGameTexts = {}
	end
end)

hook.Add("PlayerDisconnected", "InsaneStatsWPASS", SaveData)
hook.Add("ShutDown", "InsaneStatsWPASS", SaveData)

local ammoCrateTypes = {
	-- Valve can't count.
	
	3, -- pistol
	4, -- smg
	1, -- ar2
	8, -- rpg
	7, -- shotgun
	10, -- grenade
	5, -- 357
	6, -- crossbow
	2, -- ar2 alt
	9, -- smg alt
}
hook.Add("PlayerUse", "InsaneStats", function(ply, ent)
	if ent:GetClass() == "item_ammo_crate" then
		local crateType = tonumber(ent:GetKeyValues().AmmoType)
		local ammoType = ammoCrateTypes[crateType+1]
		timer.Simple(0.8, function()
			if IsValid(ply) and IsValid(ent) then
				if InsaneStats:GetConVarValue("ammocrate_maxammo") then
					ply:GiveAmmo(9999, ammoType)
				end
				hook.Run("InsaneStatsAmmoCrateInteracted", ply, ent)
			end
		end)
	elseif ent:GetClass() == "prop_vehicle_jeep" then
		if ply:GetEyeTrace().HitGroup == 5 then
			if InsaneStats:GetConVarValue("ammocrate_maxammo") then
				ply:GiveAmmo(9999, 4)
			end
			hook.Run("InsaneStatsAmmoCrateInteracted", ply, ent)
		end
	end
end)

local color_light_red = Color(255, 127, 127)
hook.Add("PlayerSwitchFlashlight", "InsaneStats", function(ply, newState)
	if newState and ply.insaneStats_FlashlightDisabled and InsaneStats:GetConVarValue("flashlight_disable_fix") then
		net.Start("insane_stats")
		net.WriteUInt(5, 8)
		net.WriteString("Your flashlight won't turn on...")
		net.WriteColor(color_light_red)
		net.Send(ply)
		return false
	end
end)

hook.Add("Initialize", "InsaneStats", function()
	currentSaveFile = InsaneStats:GetConVarValue("save_file")
end)

hook.Add("InitPostEntity", "InsaneStats", function()
	if InsaneStats:GetConVarValue("transition_delay") then
		for k,v in pairs(ents.FindByClass("trigger_changelevel")) do
			local oldSolidFlags = v:GetSolidFlags()
			if bit.band(oldSolidFlags, FSOLID_TRIGGER) ~= 0 and InsaneStats:GetConVarValue("transition_delay") then
				local newSolidFlags = bit.bxor(oldSolidFlags, FSOLID_TRIGGER)
				v:SetSolidFlags(newSolidFlags)
				timer.Simple(15, function()
					if IsValid(v) then
						v:SetSolidFlags(oldSolidFlags)
					end
				end)
			end
		end
	end
end)

hook.Add("PlayerSelectSpawn", "InsaneStats", function(ply, transition)
	if InsaneStats:GetConVarValue("spawn_master") and not transition then
		local developer = InsaneStats:IsDebugLevel(1)
		local spawnPoints = ents.FindByClass("info_player_deathmatch")
		for i, v in ipairs(spawnPoints) do
			if hook.Run("IsSpawnpointSuitable", ply, v, true) then
				if developer then
					InsaneStats:Log("Spawning %s at %s!", tostring(ply), tostring(v))
				end
				return v
			end
		end

		spawnPoints = ents.FindByClass("info_player_coop")
		for i, v in ipairs(spawnPoints) do
			if not v.insaneStats_Disabled and hook.Run("IsSpawnpointSuitable", ply, v, true) then
				if developer then
					InsaneStats:Log("Spawning %s at %s!", tostring(ply), tostring(v))
				end
				return v
			end
		end

		spawnPoints = ents.FindByClass("info_player_start")
		for i, v in ipairs(spawnPoints) do
			if v:HasSpawnFlags(1) and hook.Run("IsSpawnpointSuitable", ply, v, true) then
				if developer then
					InsaneStats:Log("Spawning %s at %s!", tostring(ply), tostring(v))
				end
				return v
			end
		end
		for i, v in ipairs(spawnPoints) do
			if hook.Run("IsSpawnpointSuitable", ply, v, true) then
				if developer then
					InsaneStats:Log("Spawning %s at %s!", tostring(ply), tostring(v))
				end
				return v
			end
		end
		if developer then
			InsaneStats:Log("Could not find valid spawn point for %s!", tostring(ply))
		end
	end
end)

hook.Add("PlayerSpawn", "InsaneStats", function(ply, transition)
	if transition then ply.insaneStats_FlashlightDisabled = nil end
end)