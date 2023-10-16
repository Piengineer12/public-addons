--[[
	idea for user configuration:
	<map> <command type> <command param> <action type> <action param>

	<command type> is one of disconnect / background map, changelevel, input, init
	<action type> is one of changelevel, incrementvar, multvar, toggle,
		play, ent_fire, insanestats_wpass2_statuseffect, <cancel>, <command>
]]

local inputNumberOfTimes = {}
InsaneStats.PointCommandCustomEvents = {}
hook.Add("AcceptInput", "InsaneStatsPointCommand", function(ent, input, activator, caller, value)
	if InsaneStats:GetConVarValue("pointcmder_enabled") then
		input = input:lower()

		local class = IsValid(ent) and ent:GetClass()
		if input == "command" and (
			class == "point_servercommand"
			or class == "point_clientcommand"
			or class == "point_broadcastclientcommand"
		) then
			for i, command in ipairs(string.Explode(";", value:lower())) do
				local mainCommand, restCommand = string.match(command, "^%s*(%S+)(.*)$")

				if mainCommand == "disconnect" or mainCommand == "startupmenu"
				or mainCommand == "quit" or mainCommand == "exit" or mainCommand == "killserver"
				or mainCommand == "map_background" then
					-- TODO: allow player to override
					mainCommand = "disconnect"
				elseif mainCommand == "map" or mainCommand == "changelevel"
				or mainCommand == "changelevel2" then
					-- TODO: allow player to override
					if mainCommand == "map" then
						mainCommand = "changelevel"
					end
				elseif mainCommand == "cl_playermodel" then
					InsaneStats:Log("Command \""..command.."\" from \""..tostring(ent).."\" was blocked!")
					mainCommand = nil
				end

				if mainCommand and not IsConCommandBlocked(mainCommand) then
					command = mainCommand..restCommand
					InsaneStats:Log("Running command \""..command.."\" from \""..tostring(ent).."\"...")
					if class == "point_servercommand" then
						local success, ret = pcall(game.ConsoleCommand, command.."\n")
						if not success then
							InsaneStats:Log("Error: "..ret)
						end
					else
						for j, ply in ipairs(player.GetAll()) do
							local success, ret = pcall(ply.ConCommand, ply, command)
							if not success then
								InsaneStats:Log("Error: "..ret)
							end
						end
					end
				end
			end
		end
	end

	local inputReports = InsaneStats:GetConVarValue("pointcmder_reportinput")
	if inputReports ~= 0 then
		local name = IsValid(ent) and ent:GetName() or ''
		inputNumberOfTimes[name] = inputNumberOfTimes[name] or {}
		inputNumberOfTimes[name][input] = (inputNumberOfTimes[name][input] or 0) + 1

		local times = inputNumberOfTimes[name][input]
		if inputReports < 0 or times <= inputReports then
			InsaneStats:Log(string.format(
				"Entity \"%s\" received input \"%s\" for the %u%s time!",
				name, input, times, STNDRD(times)
			))
		end
	end
end)