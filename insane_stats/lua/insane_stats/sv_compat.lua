local function SelectSpawn(ply)
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
end

hook.Add("PlayerSelectSpawn", "InsaneStatsCompat", function(ply, transition)
    local override = hook.Run("InsaneStatsPlayerSelectSpawn", ply, transition)
    if IsValid(override) then return override end

    if InsaneStats:GetConVarValue("spawn_master") and not transition then
        local selected = SelectSpawn(ply)
        if IsValid(selected) then
			return selected
		elseif InsaneStats:IsDebugLevel(1) then
			InsaneStats:Log("Could not find valid spawn point for %s!", tostring(ply))
		end
    end
end)

hook.Add("InitPostEntity", "InsaneStatsCompat", function()
    if InsaneStats:GetConVarValue("transition_delay") then
        for k,v in pairs(ents.FindByClass("trigger_changelevel")) do
            local oldSolidFlags = v:GetSolidFlags()
            if InsaneStats:GetConVarValue("transition_delay_forcesolid") then
                oldSolidFlags = bit.bor(oldSolidFlags, FSOLID_TRIGGER)
            end
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

    if InsaneStats:GetConVarValue("lego_softcap") and CalculateStuds then
        InsaneStats.originalCalculateStuds = InsaneStats.originalCalculateStuds or CalculateStuds
        function CalculateStuds(worth, ...)
            worth = InsaneStats:ComputeNerfedIncrement(0, worth/10000, 1.875) * 10000
            return InsaneStats.originalCalculateStuds(worth, ...)
        end
    end
end)

hook.Add("PostCleanupMap", "InsaneStatsCompat", function()
	timer.Simple(0.5, function()
		if InsaneStats:GetConVarValue("lego_softcap") and CalculateStuds then
			InsaneStats.originalCalculateStuds = InsaneStats.originalCalculateStuds or CalculateStuds
			function CalculateStuds(worth, ...)
				worth = InsaneStats:ComputeNerfedIncrement(0, worth/10000, 1.875) * 10000
				return InsaneStats.originalCalculateStuds(worth, ...)
			end
		end
	end)
end)

hook.Add("InsaneStatsAmmoCrateInteracted", "InsaneStatsCompat", function(ply, ent)
    if InsaneStats:GetConVarValue("ammocrate_maxammo") then
        local class = ent:GetClass()
        if class == "item_ammo_crate" then
            local crateAmmoType = tonumber(ent:GetInternalVariable("AmmoType"))
            local ammoType = InsaneStats:TranslateAmmoCrateTypeToAmmoType(crateAmmoType)

            ply:GiveAmmo(9999, ammoType)
        elseif class == "prop_vehicle_jeep" then
            ply:GiveAmmo(9999, 4)
        end
    end
end)

local pendingGameTexts = {}
local nextPhysSleep = 0
local lagBuildup = 0
hook.Add("Think", "InsaneStatsCompat", function()
    local buildupCount = InsaneStats:GetConVarValue("sleepphys_lagamount")
    if buildupCount > 0 then
        if engine.AbsoluteFrameTime() >= 0.5 and nextPhysSleep < RealTime() and CurTime() > 10 then
            lagBuildup = lagBuildup + 1
            if lagBuildup >= buildupCount then
                for i,v in InsaneStats:GetEntityIterator() do
                    local physObj = v:GetPhysicsObject()
                    if IsValid(physObj) then
                        physObj:Sleep()
                    end
                    if v:GetClass() == "prop_physics" and v:GetCollisionGroup() == COLLISION_GROUP_DEBRIS
                    and not v:GetNWBool("insanestats_use") and not v:GetNWBool("insanestats_vital")
                    and not v:GetNWBool("insanestats_break") and ents.GetCount() > 4096 then
                        SafeRemoveEntity(v)
                    end
                end
                nextPhysSleep = RealTime() + InsaneStats:GetConVarValue("sleepphys_cooldown")
            end
        else
            lagBuildup = 0
        end
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

local replaceAllGunships
local gunshipSpecificOutputs = {
    onfirecannon = true,
    onfirstdamage = true,
    onseconddamage = true,
    onthirddamage = true,
    onfourthdamage = true,
    oncrashed = true
}
hook.Add("EntityKeyValue", "InsaneStatsCompat", function(ent, key, value)
    key = key:lower()
    local class = ent:GetClass()
    if class == "info_player_coop" and key == "startdisabled" then
        ent.insaneStats_Disabled = tobool(value)
    elseif class == "npc_combinegunship" then
        ent.insaneStats_KVs = ent.insaneStats_KVs or {}
        table.insert(ent.insaneStats_KVs, {key, value})

        if key == "spawnflags" and bit.band(tonumber(value), 2048) ~= 0 then
            if not replaceAllGunships then
                InsaneStats:Log("A template gunship has been detected, all gunships might be replaced with helicopters!")
                replaceAllGunships = "yes"
            end
        end

        if gunshipSpecificOutputs[key] then
            replaceAllGunships = "never"
            InsaneStats:Log("Gunship-specific output has been detected, all gunships will not be replaced with helicopters!")
        end
    elseif class == "info_target_gunshipcrash" and key == "oncrashed" then
        replaceAllGunships = "never"
        InsaneStats:Log("info_target_gunshipcrash entity with OnCrashed output has been detected, all gunships will not be replaced with helicopters!")
    elseif class == "logic_choreographed_scene" and key ~= "oncanceled"
    or class == "prop_dynamic" and key == "onanimationdone" then
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
    elseif class == "game_text" and key == "color" then
        -- For some reason "color" isn't included under game_text:GetKeyValues(). Why?
        ent.insaneStats_TextColor = string.ToColor(value.." 255")
    elseif value == "!rndplayer" and InsaneStats:GetConVarValue("other_game_entities") then
        return "!player"
    elseif class == "filter_activator_team" then
        if key == "filterteam" then
            for w in string.gmatch(
                InsaneStats:GetConVarValue("unfiltered_teams"),
                "%S+"
            ) do
                local alwaysPassTeam = tonumber(w)
                if alwaysPassTeam and tonumber(value) == alwaysPassTeam then
                    local negated = ent:GetInternalVariable("Negated") and 0 or 1
                    ent:SetKeyValue("Negated", negated)
                    if InsaneStats:IsDebugLevel(1) then
                        InsaneStats:Log("Filter %s now %s any team", tostring(ent), negated == 0 and "DISALLOWS" or "ALLOWS")
                    end
                    return 12058
                end
            end
        elseif key == "negated" then
            if tonumber(ent:GetInternalVariable("filterteam")) == 12058 then
                -- FGD shenanigans
                if value == "Allow entities that match criteria" then value = 0 end
                local negated = tobool(value) and 0 or 1
                if InsaneStats:IsDebugLevel(1) then
                    InsaneStats:Log("Filter %s now %s any team due to original value %s", tostring(ent), negated == 0 and "DISALLOWS" or "ALLOWS", value)
                end
                return negated
            end
        end
	elseif class == "prop_vehicle_jeep" and key == "model" then
		if not util.IsValidModel(value) then
			return "models/buggy.mdl"
		end
    end
end)

hook.Add("InsaneStatsEntityCreated", "InsaneStatsCompat", function(ent)
    local class = ent:GetClass()
    if class=="npc_combinegunship" then
        -- all gunships have children, the key is instead to look for what's not usually part of a gunship
        if #ent:GetChildren() > 2 and not replaceAllGunships then
            InsaneStats:Log("A gunship with children has been detected, all gunships will be replaced with helicopters!")
            replaceAllGunships = "yes"
        end
        if InsaneStats:GetConVarValue("prevent_gunship_death_crash") and replaceAllGunships == "yes" then
            local keyValues = ent.insaneStats_KVs or {}
            local children = ent:GetChildren()
            local pos = ent:GetPos()

            for i,v in ipairs(ents.FindByClass("info_target_helicopter_crash")) do
                if not v.insaneStats_Replacement then
                    v:Fire("Kill")
                end
            end

            ent:InsaneStats_ApplyStatusEffect("stunned", 1, math.huge)
            ent:SetNoDraw(true)
            ent:Fire("Kill")

            local heli = ents.Create("npc_helicopter")
            heli:SetPos(pos)
            for i,v in ipairs(keyValues) do
                local key, value = unpack(v)
                if key == "spawnflags" then
                    heli:SetKeyValue(key, bit.band(tonumber(value), bit.bnot(2048)))
                elseif key ~= "classname" then
                    heli:SetKeyValue(key, value)
                end
            end
            for i,v in ipairs(children) do
                v:SetParent(heli)
            end
            heli:Spawn()
        end
    elseif (class=="npc_combinedropship" or class=="prop_dropship_container")
        and InsaneStats:GetConVarValue("nonsolid_combine_dropship") then
        ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
    elseif ent.Base == "legocoin" then
        -- secretly clip on extra code to show our pickup notifs c:
        local oldCollect = ent.Collect
        ent.Collect = function(self, ply, ...)
            net.Start("insane_stats")
            net.WriteUInt(2, 8)
            net.WriteString("legocoin")
            net.WriteUInt(math.Round(math.log10(self.Worth) - 1), 2)
            net.Send(ply)
            oldCollect(self, ply, ...)
        end
    end
end)

local activeCamera = NULL
local activeTime = 0
hook.Add("AcceptInput", "InsaneStatsCompat", function(ent, input, activator, caller, value)
    input = input:lower()
    local class = ent:GetClass()
    if (input == "start" and class == "logic_choreographed_scene")
    or (input == "setanimation" and class == "prop_dynamic")
    and InsaneStats:GetConVarValue("skip_missing_scenes") then
        -- see if the file even exists
        local sceneFile = class == "prop_dynamic" and ent:GetModel() or ent:GetInternalVariable("SceneFile")
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
        elseif input == "disable" and ent ~= activeCamera and activeTime + 0.15 > CurTime() then
            return true
        elseif input == "enable" then
            activeCamera = ent
            activeTime = CurTime()
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
                c = color,
                target = not ent:HasSpawnFlags(1) and activator:IsPlayer() and activator
            })
            ent.insaneStats_DisplayedInChat = true
        end
    elseif input == "endgame" and class == "game_end" and InsaneStats:GetConVarValue("gametext_tochat")
    and not (InsaneStats:GetConVarValue("gametext_tochat_once") and ent.insaneStats_DisplayedInChat) then
        table.insert(pendingGameTexts, {
            order = 1,
            t = "[GAME END]",
            c = Color(255, 0, 0)
        })
        ent.insaneStats_DisplayedInChat = true
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
    elseif input == "spawn" and (
        class == "npc_antlion_template_maker"
        or class == "npc_template_maker"
        or class == "npc_maker"
    ) and not ent:HasSpawnFlags(32) then
        local spawnDelay = InsaneStats:GetConVarValue("maker_spawn_enable")
        --[[local lastSpawn = ent.insaneStats_SpawnedTime or 0
        if lastSpawn + spawnDelay > CurTime() then
            --local cooldown = lastSpawn + spawnDelay - CurTime() + engine.TickInterval()
            --ent:Fire("Spawn", value, cooldown, activator, caller)
            ent:Fire("Enable")
            ent:Fire("SetSpawnFrequency", spawnDelay)
            --return true
        else
            ent.insaneStats_SpawnedTime = CurTime()
        end]]
        if spawnDelay >= -1.5 then
            ent:Fire("Enable")
            local currentDelay = ent:GetInternalVariable("SpawnFrequency")
            if currentDelay > spawnDelay then
                ent:Fire("SetSpawnFrequency", spawnDelay)
            end
        end
    end
end)

local createdCrossbowCollisions = {}
hook.Add("InsaneStatsCrossbowBoltLanded", "InsaneStatsCompat", function(bolt, attacker, landed)
    if landed and InsaneStats:GetConVarValue("solid_bolts") > 0 then
        createdCrossbowCollisions[attacker] = createdCrossbowCollisions[attacker] or {}
        local attackerCreatedCrossbowCollisions = createdCrossbowCollisions[attacker]

        local desiredAng = bolt:GetAngles()
        desiredAng:RotateAroundAxis(bolt:GetUp(), 90)
        local collide = ents.Create("prop_physics")
        collide:SetModel("models/hunter/plates/plate05.mdl")
        collide:SetPos(bolt:WorldSpaceCenter() - bolt:GetUp())
        collide:SetAngles(desiredAng)
        --collide:SetNoDraw(true)
        collide:SetMaterial("models/wireframe")
        collide:SetColor(Color(255, 127, 0, 31))
        collide:SetRenderMode(RENDERMODE_TRANSCOLOR)
        collide:Spawn()
        --bolt:SetParent(collide)
        --collide:SetMoveType(MOVETYPE_NONE)

        local physObj = collide:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:EnableMotion(false)
        end

        table.insert(attackerCreatedCrossbowCollisions, collide)
        if #attackerCreatedCrossbowCollisions > InsaneStats:GetConVarValue("solid_bolts") then
            SafeRemoveEntity(table.remove(attackerCreatedCrossbowCollisions, 1))
        end
    end
end)

timer.Create("InsaneStatsCompat", 5, 0, function()
    if InsaneStats:GetConVarValue("void_rescue") then
        for i,v in player.Iterator() do
            if v:GetPos():LengthSqr() > 805306368 then
                local spawnpoint = hook.Run("PlayerSelectSpawn", v, false)
                if IsValid(spawnpoint) then
                    v:SetPos(spawnpoint:GetPos())
                end
            end
        end
    end
end)

local color_light_red = Color(255, 127, 127)
hook.Add("PlayerSwitchFlashlight", "InsaneStatsCompat", function(ply, newState)
    if newState and ply.insaneStats_FlashlightDisabled and InsaneStats:GetConVarValue("flashlight_disable_fix") then
        net.Start("insane_stats")
        net.WriteUInt(5, 8)
        net.WriteString("Your flashlight won't turn on...")
        net.WriteColor(color_light_red)
        net.Send(ply)
        return false
    end
end)

hook.Add("PlayerSpawn", "InsaneStatsCompat", function(ply, transition)
    if transition then ply.insaneStats_FlashlightDisabled = nil end
end)

hook.Add("PlayerLoadout", "InsaneStatsCompat", function(ply)
    for i,v in ipairs(ents.FindByClass("info_player_equip")) do
        if not v.insaneStats_Disabled then
            v:EquipPlayer(ply)
        end
    end

	for i,v in ipairs(ents.FindByClass("synergy_gameinfo")) do
		if v.insaneStats_Mode == 0 then
			-- default sandbox guns loadout
			ply:GiveAmmo(256, "Pistol", true)
			ply:GiveAmmo(256, "SMG1", true)
			ply:GiveAmmo(5, "grenade", true)
			ply:GiveAmmo(64, "Buckshot", true)
			ply:GiveAmmo(32, "357", true)
			ply:GiveAmmo(32, "XBowBolt", true)
			ply:GiveAmmo(6, "AR2AltFire", true)
			ply:GiveAmmo(100, "AR2", true)
			ply:Give("weapon_crowbar")
			ply:Give("weapon_pistol")
			ply:Give("weapon_smg1")
			ply:Give("weapon_frag")
			ply:Give("weapon_physcannon")
			ply:Give("weapon_crossbow")
			ply:Give("weapon_shotgun")
			ply:Give("weapon_357")
			ply:Give("weapon_rpg")
			ply:Give("weapon_ar2")
			ply:Give("weapon_stunstick")
		end
	end
end)

hook.Add("IsSpawnpointSuitable", "InsaneStatsCompat", function(ply, spawn, force)
    local entsFound = ents.FindInSphere(spawn:GetPos(), 1)
    for i,v in ipairs(entsFound) do
        local class = v:GetClass()
        if (class == "trigger_hurt" or class == "trigger_physics_trap") then
            local targetsPlayers = bit.band(v:GetSpawnFlags(), 65) ~= 0 and not tobool(v:GetInternalVariable("StartDisabled"))
            local filter = v:GetInternalVariable("filtername")
            if filter then
                local entFilter = ents.FindByName(filter)[1]
                if IsValid(entFilter) then
                    filter = entFilter:PassesFilter(v, ply)
                end
            else
                filter = true
            end
            if targetsPlayers and filter then
                if InsaneStats:IsDebugLevel(1) then
                    InsaneStats:Log("%s is dangerous to spawn in due to %s!", tostring(spawn), tostring(v))
                end
                return false
            end
        end
    end
end)

hook.Add("EntityTakeDamage", "InsaneStatsCompat", function(vic, dmginfo)
    if vic:GetClass() == "npc_combinegunship" and replaceAllGunships == "yes"
    and InsaneStats:GetConVarValue("prevent_gunship_death_crash") then
        return true
    end
end)

hook.Add("Initialize", "InsaneStatsCompat", function()
    if InsaneStats:GetConVarValue("skip_missing_scenes") then
        hook.Remove("InitPostEntity", "FixMap_DMI_deadman_island_IPE")
    end
    if InsaneStats:GetConVarValue("spawn_master") then
        hook.Remove("PlayerSpawn", "FixMap_DMI_deadman_island_IPE")
    end
end)
