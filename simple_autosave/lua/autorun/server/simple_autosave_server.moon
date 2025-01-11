ConEnabled = CreateConVar 'simple_autosave_enabled', 1, FCVAR_ARCHIVE,
	'Enables Simple Autosave.'
ConInterval = CreateConVar 'simple_autosave_interval', 900, FCVAR_ARCHIVE,
	'Sets the amount of seconds between each autosave. Minimum autosave interval is 10 seconds.'
ConWarning = CreateConVar 'simple_autosave_warning_duration', 10, FCVAR_ARCHIVE,
	'If above 0, displays a message when the game is about to be saved.'
--ConPrefix = CreateConVar 'simple_autosave_prefix', '', FCVAR_ARCHIVE,
--	'Prefix applied to all save files created by Simple Autosave.'

util.AddNetworkString 'simple_autosave'

nextSave = math.huge
warningTriggered = false
nonSandboxWarningTriggered = false
manual = false

concommand.Add 'simple_autosave_trigger', ((ply, cmd, args, argStr) ->
	manual = true
	nextSave = if args[1] == 'now' then 0 else CurTime! + ConWarning\GetFloat!
	warningTriggered = args[1] == 'now'
), nil, 'Sets the next autosave time to the warning interval. Use the argument "now" to autosave immediately.'

SandboxWarn = ->
	unless nonSandboxWarningTriggered
		nonSandboxWarningTriggered = true

		print 'GAMEMODE.IsSandboxDerived =', GAMEMODE.IsSandboxDerived
		print '[Simple Autosave] Simple Autosave is currently broken outside of Sandbox, sorry!'
		print '[Simple Autosave] I\'ll add non-Sandbox support if I receive enough requests for it.'
		net.Start 'simple_autosave'
		net.WriteUInt 2, 4
		net.Broadcast!

hook.Add 'InitPostEntity', 'SimpleAutoSave', ->
	nextSave = CurTime! + math.max 10, ConInterval\GetFloat!
	return

hook.Add 'Think', 'SimpleAutoSave', ->
	curTime = CurTime!
	if ConEnabled\GetBool! or manual
		warningDuration = ConWarning\GetFloat!
		if nextSave < curTime and warningTriggered
			nextSave = curTime + math.max 10, ConInterval\GetFloat!
			warningTriggered = false
			manual = false
			if GAMEMODE.IsSandboxDerived
				-- find the listen server host
				writeOnto = [ply for i,ply in player.Iterator! when ply\IsListenServerHost!]
				writeOnto = [ply for i,ply in player.Iterator! when ply\IsSuperAdmin!] unless next writeOnto

				if next writeOnto
					net.Start 'simple_autosave'
					net.WriteUInt 5, 4
					net.Send writeOnto

					timer.Simple 0, ->
						print '[Simple Autosave] Your game has been saved.'
						
						net.Start 'simple_autosave'
						net.WriteUInt 1, 4
						net.Broadcast!
				else
					print '[Simple Autosave] Failed to write save file as neither the listen server host nor any superadmins were in the server!'
					net.Start 'simple_autosave'
					net.WriteUInt 4, 4
					net.Broadcast!
			else SandboxWarn!
		elseif nextSave < curTime + warningDuration and not warningTriggered
			warningTriggered = true
			nextSave = curTime + warningDuration -- in case autosaving was enabled after elapse
			if GAMEMODE.IsSandboxDerived
				print "[Simple Autosave] Autosaving in #{warningDuration} seconds."
				net.Start 'simple_autosave'
				net.WriteUInt 3, 4
				net.WriteFloat warningDuration
				net.Broadcast!
			else SandboxWarn!
	else
		warningTriggered = false
	return