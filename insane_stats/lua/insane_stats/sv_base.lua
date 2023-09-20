gameevent.Listen("entity_killed")
gameevent.Listen("break_prop")
gameevent.Listen("break_breakable")

local currentSaveFile = InsaneStats:GetConVarValue("save_file") or "default"

function InsaneStats:Save(data)
	if not file.IsDir("insane_stats", "DATA") then
		file.CreateDir("insane_stats")
	end
	local saveFileName = "insane_stats/"..currentSaveFile..".json"
	file.Write(saveFileName, util.TableToJSON(data))
end

function InsaneStats:Load()
	local saveFileName = "insane_stats/"..currentSaveFile..".json"
	if file.Exists("insane_stats.txt", "DATA") then
		file.Rename("insane_stats.txt", saveFileName)
	end
	return util.JSONToTable(file.Read(saveFileName) or "") or {}
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

-- AcceptInput: see MISC section

hook.Add("InsaneStatsEntityCreated", "InsaneStats", function(ent)
	if ent:IsNPC() then
		ent:Fire("AddOutput", "OnDeath !activator:InsaneStats_OnNPCKilled")
		if ent:GetClass()=="npc_helicopter" then
			ent:Fire("AddOutput", "OnShotDown !activator:InsaneStats_OnNPCKilled")
		elseif ent:GetClass()=="npc_turret_floor" then
			ent:Fire("AddOutput", "OnTipped !self:InsaneStats_OnNPCKilled")
		end
	elseif ent:GetClass()=="prop_vehicle_apc" then
		ent:Fire("AddOutput", "OnDeath !activator:InsaneStats_OnNPCKilled")
		if IsValid(ent:GetDriver()) then
			ent:Fire("AddOutput","OnDeath "..ent:GetDriver():GetName()..":Kill")
		end
	end
end)

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

-- For some reason "color" isn't included under game_text:GetKeyValues(). Why?
hook.Add("EntityKeyValue", "InsaneStats", function(ent, key, value)
	if ent:GetClass() == "game_text" and key == "color" then
		ent.insaneStats_TextColor = string.ToColor(value.." 255")
	end
end)

local pendingGameTexts = {}
hook.Add("AcceptInput", "InsaneStats", function(ent, input, activator, caller, value)
	input = input:lower()
	data = data or ""
	if input == "insanestats_onnpckilled" then
		hook.Run("InsaneStatsEntityKilled", caller, activator, activator)
	elseif input == "display" then
		if ent:GetClass() == "game_text" and InsaneStats:GetConVarValue("gametext_tochat")
		and not (InsaneStats:GetConVarValue("gametext_tochat_once") and ent.insaneStats_DisplayedInChat) then
			local keyValues = ent:GetKeyValues()
			local xPos = tonumber(keyValues.x)
			local yPos = tonumber(keyValues.y)
			
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
	elseif input == "modifyspeed" and ent:GetClass() == "player_speedmod"
	and InsaneStats:GetConVarValue("flashlight_disable_fix_modifyspeed") then
		for i,v in ipairs(player.GetAll()) do
			v.insaneStats_FlashlightDisabled = true
		end
	end
end)

local function SaveData()
	local data = InsaneStats:Load()
	hook.Run("InsaneStatsSave", data)
	InsaneStats:Save(data)
end

local saveThinkCooldown = 0
hook.Add("Think", "InsaneStats", function()
	if saveThinkCooldown < RealTime() then
		SaveData()
		saveThinkCooldown = RealTime() + 30
	end

	if next(pendingGameTexts) then
		for k,v in SortedPairsByMemberValue(pendingGameTexts, "order") do
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
	if InsaneStats:GetConVarValue("ammocrate_maxammo") then
		if ent:GetClass() == "item_ammo_crate" then
			local crateType = tonumber(ent:GetKeyValues().AmmoType)
			local ammoType = ammoCrateTypes[crateType+1]
			timer.Simple(0.8, function()
				if IsValid(ply) and (IsValid(ent) and ent:GetSequence() ~= 0) then
					ply:GiveAmmo(9999, ammoType)
				end
			end)
		elseif ent:GetClass() == "prop_vehicle_jeep" then
			if ply:GetEyeTrace().HitGroup == 5 then
				ply:GiveAmmo(9999, 4)
			end
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
		local spawnPoints = ents.FindByClass("info_player_start")
		for i, v in ipairs(spawnPoints) do
			if v:HasSpawnFlags(1) and hook.Run("IsSpawnpointSuitable", ply, v, true) then
				return v
			end
		end
		for i, v in ipairs(spawnPoints) do
			if v:IsInWorld() then
				if hook.Run("IsSpawnpointSuitable", ply, v, true) then
					return v
				end
			end
		end
	end
end)

hook.Add("PlayerSpawn", "InsaneStats", function(ply, transition)
	if transition then ply.insaneStats_FlashlightDisabled = nil end
end)