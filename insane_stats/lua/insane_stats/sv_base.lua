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
	local delay = InsaneStats:GetConVarValue("spawn_delay")
	timer.Simple(delay, function()
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

local hlsAliases = {
	npc_gargantua = "monster_gargantua",
	npc_alien_grunt = "monster_alien_grunt",
	npc_houndeye = "monster_houndeye",
	npc_bullsquid = "monster_bullchicken",
}
--[[local npcMakerPreventCrashOn = {
	npc_combinegunship = true
}
local keyValuesOnCrashableEntities = {}
local targetnamesToPreventCrashes = {}]]
local replaceAllGunships = false
-- For some reason "color" isn't included under game_text:GetKeyValues(). Why?
hook.Add("EntityKeyValue", "InsaneStats", function(ent, key, value)
	key = key:lower()
	local class = ent:GetClass()
	if class == "game_text" and key == "color" then
		ent.insaneStats_TextColor = string.ToColor(value.." 255")
	elseif class == "info_player_coop" and key == "startdisabled" then
		ent.insaneStats_Disabled = tobool(value)
	elseif (key == "classname" or key == "npctype") and hlsAliases[value]
	and InsaneStats:GetConVarValue("gargantua_is_monster") then
		local replaceClass = hlsAliases[value]
		if InsaneStats:IsDebugLevel(1) then
			InsaneStats:Log("Changing class of %s to %s!", tostring(ent), replaceClass)
		end
		return replaceClass
	--[[elseif key == "templatename" then
		targetnamesToPreventCrashes[value] = true
	elseif key == "spawnflags" and npcMakerPreventCrashOn[class]
	and bit.band(tonumber(value), 2048) ~= 0 then
		ent:SetKeyValue("classname", "npc_helicopter")
		keyValuesOnCrashableEntities[ent] = keyValuesOnCrashableEntities[ent] or {}
		table.insert(keyValuesOnCrashableEntities[ent], {key, value})

		if key == "targetname" then
			keyValuesOnCrashableEntities[value] = keyValuesOnCrashableEntities[ent]
		end]]
	elseif class == "logic_choreographed_scene" and key ~= "oncanceled" then
		ent.insaneStats_ChoreographedOutputs = ent.insaneStats_ChoreographedOutputs or {}

		local rawData = string.Explode("\x1B", value)
		if #rawData < 2 then
			rawData = string.Explode(",", value)
		end

		if #rawData > 1 then
			local initialDelay = tonumber(rawData[4]) or 0
			if key == "oncompletion" then
				initialDelay = initialDelay + 2
			elseif key ~= "onstart" then
				initialDelay = initialDelay + 1
			end
			table.insert(ent.insaneStats_ChoreographedOutputs, {
				entities = rawData[1] or "",
				input = rawData[2] or "",
				param = rawData[3] or "",
				delay = initialDelay,
				times = tonumber(rawData[5]) or -1
			})
		end
	elseif class == "npc_combinegunship" then
		ent.insaneStats_KVs = ent.insaneStats_KVs or {}
		table.insert(ent.insaneStats_KVs, {key, value})

		if key == "spawnflags" and bit.band(tonumber(value), 2048) ~= 0 then
			if not replaceAllGunships then
				InsaneStats:Log("A template gunship has been detected, all gunships will be replaced with helicopters!")
			end
			replaceAllGunships = true
		end
	end
end)
--InsaneStats.KeyValuesOnCrashableEntities = keyValuesOnCrashableEntities
--InsaneStats.TargetnamesToPreventCrashes = targetnamesToPreventCrashes

local pendingGameTexts = {}
local activeCamera = NULL
local activeTime = 0
hook.Add("AcceptInput", "InsaneStats", function(ent, input, activator, caller, value)
	input = input:lower()
	data = data or ""
	local class = ent:GetClass()
	if input == "insanestats_onnpckilled" then
		hook.Run("InsaneStatsEntityKilled", caller, activator, activator)
	--[[elseif input == "insanestats_onnpctemplatemade" and IsValid(activator) then
		local name = activator:GetName()
		if targetnamesToPreventCrashes[name] and keyValuesOnCrashableEntities[name] then
			local replacementEnt = ents.Create(activator:GetClass())
			replacementEnt:SetPos(activator:GetPos())
			replacementEnt:SetAngles(activator:GetAngles())
			for i,v in ipairs(keyValuesOnCrashableEntities[name]) do
				if v[1] == "spawnflags" then
					replacementEnt:SetKeyValue(
						"spawnflags",
						string.format(
							"%i",
							bit.band(
								tonumber(v[2]),
								bit.bnot(2048)
							)
						)
					)
				else
					replacementEnt:SetKeyValue(v[1], v[2])
				end
			end
			replacementEnt:Spawn()
			replacementEnt:Activate()
			if InsaneStats:IsDebugLevel(1) then
				InsaneStats:Log("Replaced %s named %s with %s!", tostring(activator), name, tostring(replacementEnt))
			end
			SafeRemoveEntityDelayed(activator, 0)
		end]]
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
	elseif input == "display" or input == "use" then
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
	elseif input == "showhudhint" and class == "env_hudhint" and InsaneStats:GetConVarValue("hudhint_tochat") then
		local message = ent.insaneStats_Text or ent:GetInternalVariable("message")
		if message then
			table.insert(pendingGameTexts, {
				order = 0,
				t = message,
				c = Color(255, 255, 0),
				target = not ent:HasSpawnFlags(1) and activator:IsPlayer() and activator
			})
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
	elseif input == "start" and class == "logic_choreographed_scene"
	and InsaneStats:GetConVarValue("skip_missing_scenes") then
		-- see if the scene even exists
		local sceneFile = ent:GetInternalVariable("SceneFile")
		if file.Exists(sceneFile, "GAME") then
			ent.insaneStats_ChoreographedOutputs = nil
		else
			local outputs = ent.insaneStats_ChoreographedOutputs or {}
			for i,v in ipairs(outputs) do
				local entities = v.entities
				local times = v.times

				if times ~= 0 then
					local entitiesToFire = {}
				
					if entities == "!activator" then
						entitiesToFire = {attacker}
					elseif entities == "!self" then
						entitiesToFire = {ent}
					elseif entities == "!player" then
						entitiesToFire = player.GetAll()
					else
						entitiesToFire = ents.FindByName(entities)
					end
				
					for _, ent in ipairs(entitiesToFire) do
						ent:Fire(v.input, v.param, v.delay, attacker, ent)
					end
				
					if times > 0 then
						v.times = times - 1
					end
				end
			end
		end
	elseif class == "point_viewcontrol" and InsaneStats:GetConVarValue("camera_no_kill") then
		-- this is where it gets stupid
		-- in ep1, the disable input should disable *all* cameras and is how it works by default in gmod
		-- but certain custom campaigns send the enable input to another camera then disable the previous
		-- one *right after*, while assuming the second camera would be active
		-- solution: if a disable input is sent right after an enable input, ignore it
		if input == "kill" then
			ent:Fire("Disable")
			return true
		elseif input == "disable" and ent ~= activeCamera and activeTime + 0.5 > CurTime() then
			return true
		elseif input == "enable" then
			activeCamera = ent
			activeTime = CurTime()
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
	elseif (class == "npc_maker" or class == "npc_template_maker")
	--[[and InsaneStats:GetConVarValue("minimum_spawn_delay") >= 0]] then
		--[[local current = ent:GetInternalVariable("spawnfrequency")
		local minimum = InsaneStats:GetConVarValue("minimum_spawn_delay")
		ent:Fire("SetSpawnFrequency", math.max(tonumber(current) or -1, minimum))]]

		if class == "npc_template_maker" then
			ent:Fire("AddOutput", "OnSpawnNPC !activator:InsaneStats_OnNPCTemplateMade")
		end
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
		elseif (class=="npc_combinedropship" or class=="prop_dropship_container")
		and InsaneStats:GetConVarValue("nonsolid_combine_dropship") then
			ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		elseif class=="npc_combinegunship" and InsaneStats:GetConVarValue("prevent_gunship_death_crash")
		and replaceAllGunships then
			local keyValues = ent.insaneStats_KVs or {}
			local pos = ent:GetPos()
			
			for i,v in ipairs(ents.FindByClass("info_target_helicopter_crash")) do
				if not v.insaneStats_Replacement then
					v:Fire("Kill")
				end
			end
			
			for i,v in ipairs(ents.FindByClass("info_target_gunshipcrash")) do
				local replacement = ents.Create("info_target_helicopter_crash")
				replacement:SetName(v:GetName())
				replacement:SetPos(v:GetPos())
				replacement:Spawn()
				replacement:Activate()
				replacement.insaneStats_Replacement = true
			end

			ent:InsaneStats_ApplyStatusEffect("invincible", 1, math.huge)
			ent:InsaneStats_ApplyStatusEffect("stunned", 1, math.huge)
			ent:SetNoDraw(true)
			ent:Fire("Kill")

			local heli = ents.Create("npc_helicopter")
			heli:SetPos(pos)
			for i,v in ipairs(keyValues) do
				local key, value = v[1],v[2]
				if key == "spawnflags" then
					heli:SetKeyValue(key, bit.band(tonumber(value), bit.bnot(2048)))
				elseif key ~= "classname" then
					heli:SetKeyValue(key, value)
				end
			end
			heli:Spawn()
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
		self:Save(data)
	end
end

local function SaveData()
	InsaneStats:PerformSave()
end

local saveThinkCooldown = 0
local lagBuildup = 0
local nextPhysSleep = 0
local lastCurTime, lastRealTime = CurTime(), RealTime()
local buggys = ents.FindByClass("prop_vehicle_jeep*")
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

	local buildupCount = InsaneStats:GetConVarValue("sleepphys_lagamount")
	if buildupCount > 0 then
		if engine.AbsoluteFrameTime() >= 0.5 and nextPhysSleep < RealTime() and CurTime() > 10 then
			lagBuildup = lagBuildup + 1
			if lagBuildup >= buildupCount then
				for i,v in ents.Iterator() do
					local physObj = v:GetPhysicsObject()
					if IsValid(physObj) then
						physObj:Sleep()
					end
				end
				nextPhysSleep = RealTime() + InsaneStats:GetConVarValue("sleepphys_cooldown")
			end
		else
			lagBuildup = 0
		end
	end
end)

local createdCrossbowCollisions = {}
hook.Add("InsaneStatsCrossbowBoltLanded", "InsaneStats", function(bolt, attacker, landed)
	if landed and bolt:GetCreationTime() + 0.05 < CurTime() and InsaneStats:GetConVarValue("solid_bolts") > 0 then
		createdCrossbowCollisions[attacker] = createdCrossbowCollisions[attacker] or {}
		local attackerCreatedCrossbowCollisions = createdCrossbowCollisions[attacker]

		local desiredAng = bolt:GetAngles()
		desiredAng:RotateAroundAxis(bolt:GetUp(), 90)
		local collide = ents.Create("prop_physics")
		collide:SetModel("models/hunter/plates/plate075.mdl")
		collide:SetPos(bolt:WorldSpaceCenter())
		collide:SetAngles(desiredAng)
		collide:SetNoDraw(true)
		collide:Spawn()
		collide:SetMoveType(MOVETYPE_NONE)

		table.insert(attackerCreatedCrossbowCollisions, collide)
		if #attackerCreatedCrossbowCollisions > InsaneStats:GetConVarValue("solid_bolts") then
			SafeRemoveEntity(table.remove(attackerCreatedCrossbowCollisions, 1))
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
	return ammoCrateTypes[crateAmmoType+1]
end
hook.Add("PlayerUse", "InsaneStats", function(ply, ent)
	if ent:GetClass() == "item_ammo_crate" then
		local crateAmmoType = tonumber(ent:GetInternalVariable("AmmoType"))
		local ammoType = InsaneStats:TranslateAmmoCrateTypeToAmmoType(crateAmmoType)
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
	if InsaneStats:GetConVarValue("resource_addworkshop") then
		resource.AddWorkshop(InsaneStats.WORKSHOP_ID)
	end
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
		local spawnPoints = ents.FindByClass("info_player_rebel")
		for i, v in ipairs(spawnPoints) do
			if hook.Run("IsSpawnpointSuitable", ply, v, true) then
				if developer then
					InsaneStats:Log("Spawning %s at %s!", tostring(ply), tostring(v))
				end
				return v
			end
		end

		spawnPoints = ents.FindByClass("info_player_deathmatch")
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