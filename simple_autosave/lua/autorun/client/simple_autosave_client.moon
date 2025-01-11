net.Receive 'simple_autosave', ->
	msgType = net.ReadUInt 4
	switch msgType
		when 1
			message = language.GetPhrase 'simple_autosave.game_saved'
			notification.AddLegacy "[Simple Autosave] #{message}", NOTIFY_GENERIC, 10
			surface.PlaySound 'garrysmod/content_downloaded.wav'
		when 2
			chat.AddText(
				'[Simple Autosave] ',
				language.GetPhrase('simple_autosave.sandbox_only.1'),
				'\n[Simple Autosave] ',
				language.GetPhrase('simple_autosave.sandbox_only.2')
			)
			surface.PlaySound 'buttons/button10.wav'
		when 3
			message = string.Replace(
				language.GetPhrase('simple_autosave.in_x'),
				'%1',
				string.format('%.1f', net.ReadFloat!)
			)
			notification.AddLegacy "[Simple Autosave] #{message}", NOTIFY_GENERIC, 10
			surface.PlaySound 'common/warning.wav'
		when 4
			chat.AddText(
				'[Simple Autosave] ',
				language.GetPhrase('simple_autosave.no_players_to_save_to')
			)
			surface.PlaySound 'buttons/button10.wav'
		when 5
			RunConsoleCommand 'gm_save'

hook.Add 'AddToolMenuCategories', 'SimpleAutoSave', ->
	spawnmenu.AddToolCategory 'Utilities', 'simple_autosave', '#simple_autosave'
	return

hook.Add 'PopulateToolMenu', 'SimpleAutoSave', ->
	spawnmenu.AddToolMenuOption 'Utilities', 'simple_autosave', 'simple_autosave_options', '#simple_autosave.options', '', '', (DForm) ->
		with DForm
			\Help '' -- newline
			\ControlHelp '#simple_autosave'
			\CheckBox '#simple_autosave.options.enabled', 'simple_autosave_enabled'
			\NumSlider '#simple_autosave.options.interval','simple_autosave_interval', 10, 3600, 0
			\Help '#simple_autosave.options.interval.help'
			\NumSlider '#simple_autosave.options.warning_duration', 'simple_autosave_warning_duration', 0, 600, 0
			\Help '#simple_autosave.options.warning_duration.help'
			--\TextEntry '#simple_autosave.options.prefix', 'simple_autosave_prefix'
			--\Help '#simple_autosave.options.prefix.help'
			\Button '#simple_autosave.trigger', 'simple_autosave_trigger'
			\Help '#simple_autosave.trigger.help'
			\Button '#simple_autosave.trigger.now', 'simple_autosave_trigger', 'now'
			\Help '#simple_autosave.trigger.now.help'
	return