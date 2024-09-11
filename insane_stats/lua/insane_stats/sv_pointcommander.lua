local inputNumberOfTimes = {}
InsaneStats.PointCommandCustomEvents = {}
hook.Add("AcceptInput", "InsaneStatsPointCommand", function(ent, input, activator, caller, value)
	if InsaneStats:GetConVarValue("pointcmder_enabled") then
		input = input:lower()

		local class = IsValid(ent) and ent:GetClass() or ''
		local name = IsValid(ent) and ent:GetName() or ''
		if input == "command" and (
			class == "point_servercommand"
			or class == "point_clientcommand"
			or class == "point_broadcastclientcommand"
		) then
			for i, command in ipairs(string.Explode(";", value:lower())) do
				local mainCommand, restCommand = string.match(command, "^%s*(%S+)%s*(.*)$")
				local developer = InsaneStats:IsDebugLevel(1)

				if mainCommand == "disconnect" or mainCommand == "startupmenu"
				or mainCommand == "quit" or mainCommand == "exit" or mainCommand == "killserver"
				or mainCommand == "map_background" then
					mainCommand = "disconnect"

					local retValue = InsaneStats:CheckEvents(InsaneStats.EVENTS.DISC, restCommand)
					if retValue then return retValue end
				elseif mainCommand == "restart" or mainCommand == "retry" then
					local retValue = InsaneStats:CheckEvents(InsaneStats.EVENTS.RESTART)
					if retValue then return retValue end
				elseif mainCommand == "map" or mainCommand == "changelevel"
				or mainCommand == "changelevel2" then
					-- TODO: allow player to override
					if mainCommand == "map" then
						mainCommand = "changelevel"
					end

					if restCommand == game.GetMap() then
						local retValue = InsaneStats:CheckEvents(InsaneStats.EVENTS.RESTART)
						if retValue then return retValue end
					else
						local retValue = InsaneStats:CheckEvents(InsaneStats.EVENTS.CHANGE, restCommand)
						if retValue then return retValue end
					end
				elseif mainCommand == "cl_forwardspeed" or mainCommand == "cl_sidespeed" or mainCommand == "cl_backspeed" then
					if (tonumber(restCommand) or 0) >= 320 then
						restCommand = "10000"
					end
				elseif mainCommand == "cl_playermodel" or mainCommand and IsConCommandBlocked(mainCommand) then
					if developer then
						InsaneStats:Log("Command \"%s\" from \"%s\" was blocked!", command, tostring(ent))
					end
					mainCommand = nil
				end

				if mainCommand then
					command = mainCommand..' '..restCommand
					if developer then
						InsaneStats:Log("Running command \"%s\" from \"%s\"...", command, tostring(ent))
					end
					if class == "point_servercommand" then
						local success, ret = pcall(game.ConsoleCommand, command.."\n")
						if not success then
							InsaneStats:Log("Error: %s", ret)
						end
					else
						for j, ply in player.Iterator() do
							local success, ret = pcall(ply.ConCommand, ply, command)
							if not success then
								InsaneStats:Log("Error: %s", ret)
							end
						end
					end
				end
			end
		elseif input == "endgame" and class == "game_end" then
			local retValue = InsaneStats:CheckEvents(InsaneStats.EVENTS.END)
			if retValue then return retValue end
		end

		local retValue = InsaneStats:CheckEvents(
			InsaneStats.EVENTS.INPUT, name, input,
			value or "", class, ent:GetModel()
		)
		if retValue then return retValue end
	end

	local inputReports = InsaneStats:GetConVarValue("pointcmder_reportinput")
	if inputReports ~= 0 then
		inputNumberOfTimes[name] = inputNumberOfTimes[name] or {}
		inputNumberOfTimes[name][input] = (inputNumberOfTimes[name][input] or 0) + 1

		local times = inputNumberOfTimes[name][input]
		if inputReports < 0 or times <= inputReports then
			InsaneStats:Log(
				"Entity \"%s\" received input \"%s\" for the %u%s time!",
				name, input, times, STNDRD(times)
			)
		end
	end
end)

local function GetWildcardMatchEntities(name, class, model)
	local inputEntities = {}
	for j,v2 in ents.Iterator() do
		if InsaneStats:WildcardMatches(name, v2:GetName())
		and InsaneStats:WildcardMatches(class, v2:GetClass())
		and InsaneStats:WildcardMatches(model, v2:GetModel()) then
			table.insert(inputEntities, v2)
		end
	end

	return inputEntities
end

function InsaneStats:DoActions(actions)
	if InsaneStats:IsDebugLevel(2) then
		InsaneStats:Log("Insane Stats Actions Fired:")
		PrintTable(actions)
	end

	for i,v in ipairs(actions) do
		if v[4] ~= 0 then
			local delay = tonumber(v[3] or 0) or 0
			local action = v[1]

			if action == InsaneStats.ACTIONS.CANCEL then return true
			elseif action == InsaneStats.ACTIONS.INPUT then
				local filterName = v[2][1][1]
				local filterClass = v[2][4] and v[2][4][1] or '*'
				local filterModel = v[2][5] and v[2][5][1] or '*'
				local inputEntities = GetWildcardMatchEntities(filterName, filterClass, filterModel)

				local inputName = v[2][2][1]
				local inputValue = v[2][3] and v[2][3][1] or nil
				for j,v2 in ipairs(inputEntities) do
					v2:Fire(inputName, inputValue, delay)
				end
			else
				if action == InsaneStats.ACTIONS.CHANGE then
					-- set delay to allow CurTime to have passed at least 60 seconds
					delay = math.max(delay, 60 - CurTime())

					local newMap = v[2][1] and v[2][1][1] or game.GetMap()
					if newMap == "" then
						newMap = game.GetMap()
					end

					local sameMap = newMap == game.GetMap()
					PrintMessage(HUD_PRINTTALK,
						sameMap and string.format("Map is restarting in %.1f seconds!", delay)
						or string.format("Map is changing to %s in %.1f seconds!", newMap, delay)
					)

					local color = sameMap and 4 or 1
					net.Start("insane_stats")
					net.WriteUInt(10, 8)
					net.WriteFloat(CurTime() + delay)
					net.WriteFloat(color)
					net.Broadcast()
				end

				timer.Simple(delay, function()
					if action == InsaneStats.ACTIONS.CHANGE then
						local newMap = v[2][1] and v[2][1][1] or game.GetMap()
						if newMap == "" then
							newMap = game.GetMap()
						end

						RunConsoleCommand("changelevel", newMap)
					elseif action == InsaneStats.ACTIONS.TIMER then
						local duration = tonumber(v[2][1][1])
						local color = (v[2][2] and tonumber(v[2][2][1]) or -1) % 6
						net.Start("insane_stats")
						net.WriteUInt(10, 8)
						net.WriteFloat(CurTime() + duration)
						net.WriteFloat(color)
						net.Broadcast()
					elseif action == InsaneStats.ACTIONS.APPLY_STATUS then
						local filterName = v[2][1][1]
						local filterClass = v[2][5] and v[2][5][1] or '*'
						local filterModel = v[2][6] and v[2][6][1] or '*'
						local inputEntities = GetWildcardMatchEntities(filterName, filterClass, filterModel)

						local effectName = v[2][2][1]
						local effectLevel = v[2][3] and tonumber(v[2][3][1] or 1) or 1
						local effectDuration = v[2][4] and tonumber(v[2][4][1] or 10) or 10
						for j,v2 in ipairs(inputEntities) do
							v2:InsaneStats_ApplyStatusEffect(effectName, effectLevel, effectDuration, {attacker = game.GetWorld()})
						end
					elseif action == InsaneStats.ACTIONS.CLEAR_STATUS then
						local filterName = v[2][1] and v[2][1][1] or '*'
						local filterClass = v[2][3] and v[2][3][1] or '*'
						local filterModel = v[2][4] and v[2][4][1] or '*'
						local inputEntities = GetWildcardMatchEntities(filterName, filterClass, filterModel)

						local effectName = v[2][2] and v[2][2][1] or '*'
						for j,v2 in ipairs(inputEntities) do
							for k,v3 in pairs(v2.insaneStats_StatusEffects) do
								if InsaneStats:WildcardMatches(effectName, k) then
									v2:InsaneStats_ClearStatusEffect(k)
								end
							end
						end
					elseif action == InsaneStats.ACTIONS.NO_WEPS then
						for j,v2 in player.Iterator() do
							v2:StripWeapons()
						end
					elseif action == InsaneStats.ACTIONS.NO_SUIT then
						for j,v2 in player.Iterator() do
							v2:RemoveSuit()
						end
					elseif action == InsaneStats.ACTIONS.PLAY then
						local filterName = v[2][1][1]
						local filterClass = v[2][3] and v[2][3][1] or '*'
						local filterModel = v[2][4] and v[2][4][1] or '*'
						local inputEntities = GetWildcardMatchEntities(filterName, filterClass, filterModel)

						local soundName = v[2][2][1]
						local soundLevel = v[2][5] and tonumber(v[2][5][1] or 75) or 75
						local soundPitch = v[2][6] and tonumber(v[2][6][1] or 100) or 100
						local soundVolume = v[2][7] and tonumber(v[2][7][1] or 1) or 1
						for j,v2 in ipairs(inputEntities) do
							v2:EmitSound(soundName, soundLevel, soundPitch, soundVolume)
						end
					elseif action == InsaneStats.ACTIONS.RUN_COMMAND then
						local reshaped = {}
						for j,v2 in ipairs(v[2]) do
							reshaped[i] = v2[1]
						end
						RunConsoleCommand(unpack(reshaped))
					elseif action == InsaneStats.ACTIONS.TOGGLE_CVAR then
						local val = GetConVar(v[2][1][1]):GetBool()
						RunConsoleCommand(v[2][1][1], val and '0' or '1')
					elseif action == InsaneStats.ACTIONS.ADD_CVAR then
						local val = GetConVar(v[2][1][1]):GetFloat()
						RunConsoleCommand(v[2][1][1], val + tonumber(v[2][2][1]))
					elseif action == InsaneStats.ACTIONS.MULT_CVAR then
						local val = GetConVar(v[2][1][1]):GetFloat()
						RunConsoleCommand(v[2][1][1], val * tonumber(v[2][2][1]))
					elseif action == InsaneStats.ACTIONS.CHAT then
						local send = {}
						for j,v2 in ipairs(v[2]) do
							local piece = v2[1]
							local r, g, b, a = piece:match("^&(%d+)%D+(%d+)%D+(%d+)%D+(%d+)%D*$")
							if not r then
								r, g, b = piece:match("^&(%d+)%D+(%d+)%D+(%d+)%D*$")
								if r then
									a = 255
								end
							end
							if r then
								table.insert(send, {true, Color(r, g, b, a)})
							else
								piece = piece:gsub("\\.", {
									["\\n"] = '\n',
									["\\t"] = '\t'
								})
								table.insert(send, {false, piece})
							end
						end

						net.Start("insane_stats")
						net.WriteUInt(11, 8)
						net.WriteUInt(#send, 16)
						for j,v2 in ipairs(send) do
							net.WriteBool(v2[1])
							if v2[1] then
								net.WriteColor(v2[2])
							else
								net.WriteString(v2[2])
							end
						end
						net.Broadcast()
					elseif action == InsaneStats.ACTIONS.LUA then
						local reshaped = {}
						for j,v2 in ipairs(v[2]) do
							reshaped[i] = v2[1]
						end
						RunString(table.concat(reshaped, '\n'), "Insane Stats Point Commander")
					end
				end)
			end
	
			v[4] = v[4] - 1
		end
	end
end

local function ScanPlayerSpheres()
	while true do
		local stops = 50
		local scanPositions = {}
		local scanEvents = {}

		for i,v in ipairs(InsaneStats.LocalMapEvents or {}) do
			if v[1] == InsaneStats.EVENTS.TRIGGER then
				table.insert(scanPositions, v[2])
				table.insert(scanEvents, v[3])
			end
		end

		for i,v in ipairs(scanPositions) do
			local pos = Vector(
				tonumber(v[1]),
				tonumber(v[2]),
				tonumber(v[3])
			)
			local squaredRadius = tonumber(v[4] or 0) or 0
			squaredRadius = squaredRadius * squaredRadius

			local satisfied = 0
			for j,v2 in player.Iterator() do
				if IsValid(v2) then
					local squaredDistance = v2:WorldSpaceCenter():DistToSqr(pos)
					if squaredDistance <= squaredRadius then
						satisfied = satisfied + 1
					end
				end
				stops = stops - 1
				coroutine.yield()
			end

			if satisfied / player.GetCount() * 100 >= tonumber(v[5] or 1) or 1 then
				InsaneStats:DoActions(scanEvents[i])
			end
		end

		for i=1, stops do
			coroutine.yield()
		end
	end
end
local scanThread = coroutine.create(ScanPlayerSpheres)

function InsaneStats:CheckEvents(eventType, ...)
	if not self.LocalMapEvents then
		self.LocalMapEvents = {}
		local currentMap = game.GetMap()
		for i,v in ipairs(self.PointCommandCustomEvents) do
			if v[1] == currentMap then
				table.Add(self.LocalMapEvents, v[2])
			end
		end
	end

	for i,v in ipairs(self.LocalMapEvents) do
		if v[1] == eventType then
			local arguments = {...}
			local filters = v[2] or {}
			local matchesFilters = true

			if eventType == InsaneStats.EVENTS.DISC then
				matchesFilters = InsaneStats:WildcardMatches(filters[1] and filters[1][1] or '*', arguments[1] or '')
			elseif eventType == InsaneStats.EVENTS.CHANGE then
				matchesFilters = InsaneStats:WildcardMatches(filters[1] and filters[1][1] or '*', arguments[1] or '')
			elseif eventType == InsaneStats.EVENTS.CREATE then
				matchesFilters = InsaneStats:WildcardMatches(filters[1] and filters[1][1] or '*', arguments[1] or '')
				and InsaneStats:WildcardMatches(filters[2] and filters[2][1] or '*', arguments[2] or '')
				and InsaneStats:WildcardMatches(filters[3] and filters[3][1] or '*', arguments[3] or '')
			elseif eventType == InsaneStats.EVENTS.INPUT then
				matchesFilters = InsaneStats:WildcardMatches(filters[1] and filters[1][1] or '*', arguments[1])
				and InsaneStats:WildcardMatches(filters[2] and filters[2][1] or '*', arguments[2])
				and InsaneStats:WildcardMatches(filters[3] and filters[3][1] or '*', arguments[3])
				and InsaneStats:WildcardMatches(filters[4] and filters[4][1] or '*', arguments[4])
				and InsaneStats:WildcardMatches(filters[5] and filters[5][1] or '*', arguments[5] or '')
			end

			if matchesFilters then
				local retValue = self:DoActions(v[3])
				if retValue then return retValue end
			end
		end
	end
end

hook.Add("Initialize", "InsaneStatsPointCommand", function()
	InsaneStats:CheckEvents(InsaneStats.EVENTS.INIT)
end)

local killScanData
hook.Add("Think", "InsaneStatsPointCommand", function()
	coroutine.resume(scanThread)

	if killScanData then
		for i,v in ents.Iterator() do
			local class = v:GetClass()
			local name = v:GetName()
			local model = v:GetModel()

			for j,v2 in ipairs(killScanData) do
				if v2.limit >= 0
				and InsaneStats:WildcardMatches(v2.class, class)
				and InsaneStats:WildcardMatches(v2.name, name)
				and InsaneStats:WildcardMatches(v2.model, model) then
					v2.limit = v2.limit - 1
				end
			end
		end

		for i,v in ipairs(killScanData) do
			if v.limit >= 0 then
				InsaneStats:DoActions(v.actions)
			end
		end

		killScanData = nil
	end
end)

hook.Add("InsaneStatsEntityCreated", "InsaneStatsPointCommand", function(ent)
	InsaneStats:CheckEvents(InsaneStats.EVENTS.CREATE, ent:GetName(), ent:GetClass(), ent:GetModel())
end)

hook.Add("EntityRemoved", "InsaneStatsPointCommand", function(ent)
	if not killScanData then
		killScanData = {}

		for i,v in ipairs(InsaneStats.LocalMapEvents or {}) do
			if v[1] == InsaneStats.EVENTS.KILL then
				table.insert(killScanData, {
					class = v[2][3][1] or '*',
					name = v[2][1][1] or '*',
					model = v[2][4][1] or '*',
					limit = tonumber(v[2][2][1]) or 0,
					actions = v[3]
				})
			end
		end
	end
end)