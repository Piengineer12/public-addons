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

function InsaneStats:ClampInfinities(tab)
	for k,v in pairs(tab) do
		if istable(v) then
			InsaneStats:ClampInfinities(v)
		elseif v == math.huge then
			tab[k] = 2^1023
		end
	end
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
	local delay = InsaneStats:GetConVarValue("spawn_delay")
	timer.Simple(delay, function()
        if IsValid(ent) and not ent:IsPlayer() then
			hook.Run("InsaneStatsTransitionCompat", ent)
			if not ent:InsaneStats_GetEntityData("entity_created_hook_called") then
				ent:InsaneStats_SetEntityData("entity_created_hook_called", true)
				hook.Run("InsaneStatsEntityCreated", ent)
			end
		end
	end)
end)

hook.Add("entity_killed", "InsaneStats", function(data)
	local victim = Entity(data.entindex_killed or 0)
	local attacker = Entity(data.entindex_attacker or 0)
	local inflictor = Entity(data.entindex_inflictor or 0)

	hook.Run("InsaneStatsEntityKilled", victim, attacker, inflictor)

	--[[if IsValid(victim.insaneStats_Handler) then
		victim.insaneStats_Handler:TriggerOutput("OnDeath", attacker)
	end]]
end)

hook.Add("OnNPCKilled", "InsaneStats", function(victim, attacker, inflictor)
	hook.Run("InsaneStatsEntityKilled", victim, attacker, inflictor)
end)

hook.Add("LambdaOnKilled", "InsaneStats", function(victim, dmginfo)
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	hook.Run("InsaneStatsEntityKilled", victim, attacker, inflictor)
end)

hook.Add("OnZombieKilled", "InsaneStats", function(victim, dmginfo)
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	hook.Run("InsaneStatsEntityKilled", victim, attacker, inflictor)
end)

hook.Add("OnBossKilled", "InsaneStats", function(victim, dmginfo)
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
	local class = victim:GetClass()
	if needCorrectiveDeathClasses[class] and victim:InsaneStats_GetHealth() <= 0 then
		local attacker = dmginfo:GetAttacker()
		local inflictor = dmginfo:GetInflictor()
		hook.Run("InsaneStatsEntityKilled", victim, attacker, inflictor)
	end
end)

-- MISC

concommand.Add("insanestats_save", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		local data = InsaneStats:Load()
		hook.Run("InsaneStatsSave", data)
		InsaneStats:ClampInfinities(data)

		local oldSaveFile = currentSaveFile
		argStr = string.Trim(argStr)
		if #argStr ~= 0 then
			currentSaveFile = argStr
		end
		InsaneStats:Save(data)
		InsaneStats:Log("Data saved to \"%s\"!", currentSaveFile)

		currentSaveFile = oldSaveFile
	else
		InsaneStats:Log("This command can only be run by admins!")
	end
end, nil, "Saves all Insane Stats data immediately. A save file name can be supplied, \z
which will cause save data to be written into that save file \z
instead of the name specified by \"insanestats_save_file\".")

concommand.Add("insanestats_save_delete", function(ply, cmd, args, argStr)
	if (not IsValid(ply) or ply:IsAdmin()) then
		if next(args) then
			local saveFileName = "insane_stats/"..argStr..".json"
			if argStr == currentSaveFile then
				InsaneStats:Log(
					"Save file \"%s\" is in use, please first set \"insanestats_save_file\" to \z
					a new save file name, then restart the map!",
					argStr
				)
			elseif file.Exists(saveFileName, "DATA") then
				file.Delete(saveFileName)
				InsaneStats:Log("Deleted save file \"%s\"!", argStr)
			else
				InsaneStats:Log("Could not find save file \"%s\"!", argStr)
			end
		else
			InsaneStats:Log("Usage: %s <save file name>", cmd)
		end
	else
		InsaneStats:Log("This command can only be run by admins!")
	end
end, nil, "Deletes the specified Insane Stats save file.")

concommand.Add("insanestats_revert_all_server_convars", function(ply, cmd, args, argStr)
	if (IsValid(ply) and not ply:IsAdmin()) then
		InsaneStats:Log("This command can only be run by admins!")
	elseif argStr:lower() == "yes" then
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

hook.Add("AcceptInput", "InsaneStats", function(ent, input, activator, caller, value)
	input = input:lower()
	data = data or ""
	local class = ent:GetClass()
	if input == "insanestats_onnpckilled" then
		hook.Run("InsaneStatsEntityKilled", caller, activator, activator)
	elseif (input == "deactivate" or input == "kill") and class == "func_tank_combine_cannon"
	and IsValid(activator) then
		-- find the npc_enemyfinder_combinecannon controlling it
		local closest = NULL
		local bestDistance = math.huge
		local targetPos = ent:GetPos()
		for i,v in ipairs(ents.FindByClass("npc_enemyfinder_combinecannon")) do
			local distance = v:GetPos():DistToSqr(targetPos)
			if distance < bestDistance then
				closest = v
				bestDistance = distance
			end
		end
		if IsValid(closest) and bestDistance <= 4096 then
			hook.Run("InsaneStatsEntityKilled", closest, activator, activator)
		end
	elseif input == "insanestats_onjoinedplayersquad" then
		ent.insaneStats_CitizenFlags = bit.bor(ent.insaneStats_CitizenFlags or 0, 4)
		ent:InsaneStats_MarkForUpdate(256)
	elseif input == "insanestats_onleftplayersquad" then
		ent.insaneStats_CitizenFlags = bit.band(ent.insaneStats_CitizenFlags or 0, bit.bnot(4))
		ent:InsaneStats_MarkForUpdate(256)
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

local crossbowBolts = {}
hook.Add("InsaneStatsEntityCreated", "InsaneStats", function(ent)
	local class = ent:GetClass()
	if class == "prop_vehicle_apc" then
		ent:Fire("AddOutput", "OnDeath !activator:InsaneStats_OnNPCKilled")
		if IsValid(ent:GetDriver()) then
			ent:Fire("AddOutput","OnDeath "..ent:GetDriver():GetName()..":Kill")
		end
	elseif class == "crossbow_bolt" then
		ent.insaneStats_FiredBy = ent:GetOwner()
		crossbowBolts[ent] = true
		hook.Run("InsaneStatsCrossbowBoltCreated", ent, ent.insaneStats_FiredBy)
	elseif ent:IsNPC() then
		ent:Fire("AddOutput", "OnDeath !activator:InsaneStats_OnNPCKilled")
		if class=="npc_helicopter" then
			ent:Fire("AddOutput", "OnShotDown !activator:InsaneStats_OnNPCKilled")
		elseif class=="npc_turret_floor" then
			ent:Fire("AddOutput", "OnTipped !self:InsaneStats_OnNPCKilled")
		elseif class=="npc_citizen" then
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
	end
end)

hook.Add("EntityRemoved", "InsaneStats", function(ent)
	local class = ent:GetClass()
	if class == "crossbow_bolt" and not ent.insaneStats_Landed then
		hook.Run("InsaneStatsCrossbowBoltLanded", ent, ent.insaneStats_FiredBy, false)
	end
end)

function InsaneStats:PerformSave()
	-- do not save within the first 20 seconds, as this can cause data loss
	if CurTime() > 20 then
		local data = self:Load()
		hook.Run("InsaneStatsSave", data)
		self:ClampInfinities(data)
		self:Save(data)
	end
end

local function SaveData()
	InsaneStats:PerformSave()
end

local saveThinkCooldown = 0
local lastCurTime, lastRealTime = CurTime(), RealTime()
local buggys = ents.FindByClass("prop_vehicle_jeep*")
local lastCheckedEntities = ents.GetAll()
hook.Add("Think", "InsaneStats", function()
	if saveThinkCooldown < RealTime() then
		InsaneStats:PerformSave()
		saveThinkCooldown = RealTime() + 30
	end

    if InsaneStats.LuaEntityHandlingIsBusted then
        -- do the loop ourselves
        local rollup = {}
        for i,ent in InsaneStats:GetEntityIterator() do
            if not lastCheckedEntities[ent] then
                local delay = InsaneStats:GetConVarValue("spawn_delay")
                timer.Simple(delay, function()
                    if (IsValid(ent) and not ent:IsPlayer() and not ent:InsaneStats_GetEntityData("entity_created_hook_called")) then
                        ent:InsaneStats_SetEntityData("entity_created_hook_called", true)
                        hook.Run("InsaneStatsTransitionCompat", ent)
                        hook.Run("InsaneStatsEntityCreated", ent)
                    end
                end)
            end
            rollup[ent] = true
        end

        lastCheckedEntities = rollup
    end

	for i,v in ipairs(buggys) do
		if (IsValid(v) and v:GetDriver():IsPlayer()) then
			local maxAmmo = game.GetAmmoMax(18)
			-- positive numbers mean that charge is positive and increasing by 10/s
			-- while negative numbers mean that charge is positive but decreasing by -10/s
			local charge

			-- if m_flCannonChargeStartTime or m_flCannonTime resets, network it
			-- m_flCannonChargeStartTime always returns a negated value for some reason
			local chargingTime = -v:GetInternalVariable("m_flCannonChargeStartTime")
			local oldChargingTime = v.insaneStats_OldChargingTime or chargingTime
			local cannonDelay = v:GetInternalVariable("m_flCannonTime")
			local oldCannonDelay = v.insaneStats_OldCannonDelay or cannonDelay
			if oldChargingTime > chargingTime then
				charge = math.min(chargingTime * 10 - maxAmmo, 0)
			elseif oldCannonDelay < cannonDelay then
				charge = maxAmmo - math.max(cannonDelay, 0) * 10
			end

			v.insaneStats_OldChargingTime = chargingTime
			v.insaneStats_OldCannonDelay = cannonDelay

			if charge then
				net.Start("insane_stats")
				net.WriteUInt(12, 8)
				net.WriteEntity(v)
				net.WriteFloat(charge)
				net.WriteFloat(CurTime())
				net.Send(v:GetDriver())
			end
		end
	end

	for k,v in pairs(crossbowBolts) do
		if IsValid(k) then
			if k:GetMoveCollide() == MOVECOLLIDE_DEFAULT and not k.insaneStats_Landed then
				k.insaneStats_Landed = true

				hook.Run("InsaneStatsCrossbowBoltLanded", k, k:GetOwner(), true)
			end
		else
			crossbowBolts[k] = nil
		end
	end
end)

timer.Create("InsaneStats", 5, 0, function()
	buggys = ents.FindByClass("prop_vehicle_jeep*")
end)

hook.Add("PlayerDisconnected", "InsaneStats", SaveData)
hook.Add("ShutDown", "InsaneStats", SaveData)

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
function InsaneStats:TranslateAmmoCrateTypeToAmmoType(crateAmmoType)
	return ammoCrateTypes[crateAmmoType+1] or -1
end
hook.Add("PlayerUse", "InsaneStats", function(ply, ent)
	if ent:GetClass() == "item_ammo_crate" then
		timer.Simple(0.8, function()
			if IsValid(ply) and IsValid(ent) then
				hook.Run("InsaneStatsAmmoCrateInteracted", ply, ent)
			end
		end)
	elseif ent:GetClass() == "prop_vehicle_jeep" then
		if ply:GetEyeTrace().HitGroup == 5 then
			hook.Run("InsaneStatsAmmoCrateInteracted", ply, ent)
		end
	end
end)

hook.Add("Initialize", "InsaneStats", function()
	currentSaveFile = InsaneStats:GetConVarValue("save_file")
	if InsaneStats:GetConVarValue("resource_addworkshop") then
		resource.AddWorkshop(InsaneStats.WORKSHOP_ID)
	end
end)
