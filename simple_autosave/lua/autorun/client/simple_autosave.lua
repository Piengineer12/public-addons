local ConEnabled = CreateClientConVar("simple_autosave_enabled", 1, true, false, "Enables Simple Autosave.")
local ConInterval = CreateClientConVar("simple_autosave_interval", 900, true, false, "Sets the amount of seconds between each autosave. Minimum autosave interval is 10 seconds.")
local ConWarning = CreateClientConVar("simple_autosave_warning_duration", 10, true, false, "If above 0, displays a message when the game is about to be saved.")

local nextSave = math.huge
local warningTriggered = false
local nonSandboxWarningTriggered = false
local manual = false

concommand.Add("simple_autosave_trigger", function(ply, cmd, args, argStr)
	if args[1] == "now" then
		nextSave = 0
	else
		nextSave = CurTime() + ConWarning:GetFloat()
	end
	manual = true
end, nil, "Sets the next autosave time to the warning interval. Use the argument \"now\" to autosave immediately.")

hook.Add("InitPostEntity", "SimpleAutoSave", function()
	nextSave = CurTime() + math.max(ConInterval:GetFloat(), 10)
end)

hook.Add("Think", "SimpleAutoSave", function()
	if ConEnabled:GetBool() or manual then
		if nextSave < CurTime() then
			nextSave = CurTime() + math.max(ConInterval:GetFloat(), 10)
			warningTriggered = false
			manual = false
			if GAMEMODE.IsSandboxDerived then
				RunConsoleCommand("gm_save")
				notification.AddLegacy("#simple_autosave.game_saved", NOTIFY_GENERIC, 5)
			elseif not nonSandboxWarningTriggered then
				nonSandboxWarningTriggered = true
				notification.AddLegacy("#simple_autosave.sandbox_only.2", NOTIFY_ERROR, 10)
				notification.AddLegacy("#simple_autosave.sandbox_only.1", NOTIFY_ERROR, 10)
			end
		elseif nextSave < CurTime() + ConWarning:GetFloat() and not warningTriggered then
			warningTriggered = true
			if GAMEMODE.IsSandboxDerived then
				notification.AddLegacy(
					string.Replace(
						language.GetPhrase("simple_autosave.in_x"),
						"%1",
						string.format(
							"%.1f",
							nextSave - CurTime()
						)
					),
					NOTIFY_GENERIC,
					7.5
				)
			elseif not nonSandboxWarningTriggered then
				nonSandboxWarningTriggered = true
				notification.AddLegacy("#simple_autosave.sandbox_only.2", NOTIFY_ERROR, 10)
				notification.AddLegacy("#simple_autosave.sandbox_only.1", NOTIFY_ERROR, 10)
			end
		end
	else
		nextSave = math.max(nextSave, CurTime() + ConWarning:GetFloat())
	end
end)

hook.Add("AddToolMenuCategories", "SimpleAutoSave", function()
	spawnmenu.AddToolCategory("Utilities", "simple_autosave", "#simple_autosave")
end)

hook.Add("PopulateToolMenu", "SimpleAutoSave", function()
	spawnmenu.AddToolMenuOption("Utilities", "simple_autosave", "simple_autosave_options", "#simple_autosave.options", "", "", function(DForm)
		DForm:Help("") -- newline
		DForm:ControlHelp("#simple_autosave")
		DForm:CheckBox("#simple_autosave.options.enabled","simple_autosave_enabled")
		DForm:NumSlider("#simple_autosave.options.interval","simple_autosave_interval",10,3600,0)
		DForm:Help("#simple_autosave.options.interval.help")
		DForm:NumSlider("#simple_autosave.options.warning_duration","simple_autosave_warning_duration",0,600,0)
		DForm:Help("#simple_autosave.options.warning_duration.help")
		DForm:Button("#simple_autosave.trigger", "simple_autosave_trigger")
		DForm:Help("#simple_autosave.trigger.help")
		DForm:Button("#simple_autosave.trigger.now", "simple_autosave_trigger", "now")
		DForm:Help("#simple_autosave.trigger.now.help")
	end)
end)