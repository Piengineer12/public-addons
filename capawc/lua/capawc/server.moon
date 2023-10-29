playerAnimationPlayerData = {}
weaponAnimationPlayerData = {}

minBlendTimeConVar = CreateConVar 'capawc_minimum_blend_time', '0', FCVAR_ARCHIVE,
	'Minimum time between color blends. This is ignored when "blending" two colors that are the same.', 0, 2
botConVar = CreateConVar 'capawc_bots', '1', FCVAR_ARCHIVE,
	'Should bots be affected? Note that bots will simply have rainbow colors.', 0, 1
gamemodeBlacklistConVar = CreateConVar 'capawc_gamemode_blacklist', '', FCVAR_ARCHIVE,
	'Player colors will never be animated in these gamemodes. This has no effect on weapon colors.'
gamemodeWhitelistConVar = CreateConVar 'capawc_gamemode_whitelist', 'base sandbox cinema elevator jazztronauts', FCVAR_ARCHIVE,
	'Player colors will be animated in these gamemodes when the gamemode whitelist is enabled.'
gamemodeWhitelistEnabledConVar = CreateConVar 'capawc_gamemode_whitelist_enabled', 0, FCVAR_ARCHIVE,
	'Player colors will only be animated in the gamemodes specified by capawc_gamemode_whitelist.'

gamemodeEnables = false
RecheckGamemodeEnabledState = ->
	timer.Simple 0, ->
		gamemode = engine.ActiveGamemode!\lower!
		for blacklistedGamemode in *string.Explode '%s+', gamemodeBlacklistConVar\GetString!, true
			if gamemode == blacklistedGamemode\lower!
				gamemodeEnables = false
				return
		
		if gamemodeWhitelistEnabledConVar\GetBool!
			gamemodeEnables = false
			for whitelistedGamemode in *string.Explode '%s+', gamemodeWhitelistConVar\GetString!, true
				if gamemode == whitelistedGamemode\lower!
					gamemodeEnables = true
					return
		else
			gamemodeEnables = true
	return

cvars.AddChangeCallback 'capawc_minimum_blend_time', ((name, oldValue, newValue) ->
	for ply, animationData in pairs playerAnimationPlayerData
		animationData[3] = nil
	for ply, animationData in pairs weaponAnimationPlayerData
		animationData[3] = nil
), 'capawc'
cvars.AddChangeCallback 'capawc_gamemode_blacklist', RecheckGamemodeEnabledState, 'capawc'
cvars.AddChangeCallback 'capawc_gamemode_whitelist', RecheckGamemodeEnabledState, 'capawc'
cvars.AddChangeCallback 'capawc_gamemode_whitelist_enabled', RecheckGamemodeEnabledState, 'capawc'
hook.Add 'InitPostEntity', 'capawc', RecheckGamemodeEnabledState

TranslateAndOptimize = (animationColors) ->
	phases = {}
	animationDuration = 0
	for i=1, #animationColors / 2
		table.insert phases, {animationDuration, animationColors[i*2-1]}
		animationDuration += animationColors[i*2]
	{animationDuration, phases}

util.AddNetworkString 'capawc'
net.Receive 'capawc', (len, ply) ->
	operation = net.ReadUInt 4
	colorCount = net.ReadUInt 8
	receivedColors = {}
	receivedDurations = {}
	for i=1, colorCount
		r, g, b = net.ReadFloat!, net.ReadFloat!, net.ReadFloat!
		table.insert receivedColors, Vector r, g, b
		table.insert receivedDurations, math.max net.ReadFloat!, 0
	
	switch operation
		when 1
			playerAnimationPlayerData[ply] = {receivedDurations, receivedColors}
		when 2
			weaponAnimationPlayerData[ply] = {receivedDurations, receivedColors}

GetCurrentColorByAnimationData = (animationData) ->
	animationColors = animationData[2]

	local timings, totalDuration
	if animationData[3]
		{totalDuration, timings} = animationData[3]
	else
		timings = {}
		totalDuration = 0

		for i, duration in ipairs animationData[1]
			timings[i] = totalDuration

			-- check if animationColors[i] == animationColors[i+1], don't enforce minimum if true
			currentColor = animationColors[i]
			nextColor = animationColors[i+1] or animationColors[1]
			if currentColor == nextColor
				totalDuration += duration
			else
				totalDuration += math.max duration, minBlendTimeConVar\GetFloat!
		
		animationData[3] = {totalDuration, timings}
	
	-- figure out where in the cycle we're at
	animationTime = CurTime! % totalDuration
	frame = 0

	for i, timing in ipairs timings
		if animationTime >= timing
			frame = i
		else break
	
	animationFrameDuration = (timings[frame+1] or totalDuration) - timings[frame]
	animationFrameDelta = (animationTime - timings[frame]) / animationFrameDuration

	-- finally, animate the weapon color
	currentColor = animationColors[frame]
	nextColor = animationColors[frame+1] or animationColors[1]
	LerpVector animationFrameDelta, currentColor, nextColor

hook.Add 'Think', 'capawc', ->
	for ply in *player.GetAll!
		if not ply\IsBot! or botConVar\GetBool!
			animationData = playerAnimationPlayerData[ply]
			if animationData and gamemodeEnables and tobool ply\GetInfo 'capawc_player_colors_enabled'
				color = GetCurrentColorByAnimationData animationData
				ply\SetPlayerColor color
			animationData = weaponAnimationPlayerData[ply]
			if animationData and tobool ply\GetInfo 'capawc_weapon_colors_enabled'
				color = GetCurrentColorByAnimationData animationData
				ply\SetWeaponColor color
	return