commonHelpText = 'Format: <color1> <duration1> <color2> <duration2> <color3> <duration3> ...
Colors must be specified in RGB or RRGGBB hexadecimal formats, or be one of (without quotes) "r", "g", "b", "c", "m", "y", "k", "u" or "w". \z
The RRRRGGGGBBBB hexadecimal format is also accepted for color overclocking. Note that values above 32767 are subtracted by 65536, leading to color underclocking.
"+" is also accepted, which uses the previous color.
Duration specifies how many seconds it takes to blend between colors. Decimal values are allowed.'

playerEnabledConVar = CreateClientConVar 'capawc_cl_player_colors_enabled', '1', true, true,
	'Enables player color animation.', 0, 1

weaponEnabledConVar = CreateClientConVar 'capawc_cl_weapon_colors_enabled', '1', true, true,
	'Enables weapon color animation.', 0, 1

playerColorConVar = CreateClientConVar 'capawc_cl_player_colors', 'F00 2 FF0 2 0F0 2 0FF 2 00F 2 F0F 2', true, false,
	'Sets your player colors.\n'..commonHelpText

weaponColorConVar = CreateClientConVar 'capawc_cl_weapon_colors', 'F11 4 1F1 4 11F 4', true, false,
	'Sets your weapon colors.\n'..commonHelpText

WriteColorAnimation = (animatedColors) ->
	halfNumAC = #animatedColors / 2
	net.WriteUInt halfNumAC, 8
	for i=1, halfNumAC
		r, g, b = animatedColors[i*2-1]\Unpack!
		net.WriteFloat r
		net.WriteFloat g
		net.WriteFloat b
		net.WriteFloat animatedColors[i*2]

InterpretColorDurationString = (colorDurationString) ->
	animatedColors = {}

	components = string.Explode '%s+', colorDurationString, true
	return false, 'Number of arguments must be even and non-zero!' if #components < 1 or 1 == bit.band #components, 1
	for i, component in ipairs components
		if 0 == bit.band i, 1
			-- duration
			duration = tonumber component
			return false, "\"#{component}\" at argument ##{i} is not a valid number!" unless duration
			return false, "\"#{component}\" at argument ##{i} must be positive!" if duration < 0
			table.insert animatedColors, duration
		else
			-- color
			switch component
				when 'r'
					table.insert animatedColors, Vector 1, 0, 0
				when 'g'
					table.insert animatedColors, Vector 0, 1, 0
				when 'b'
					table.insert animatedColors, Vector 0, 0, 1
				when 'c'
					table.insert animatedColors, Vector 0, 1, 1
				when 'm'
					table.insert animatedColors, Vector 1, 0, 1
				when 'y'
					table.insert animatedColors, Vector 1, 1, 0
				when 'k'
					table.insert animatedColors, Vector 0, 0, 0
				when 'u'
					table.insert animatedColors, Vector .5, .5, .5
				when 'w'
					table.insert animatedColors, Vector 1, 1, 1
				when '+'
					prevVector = animatedColors[i-2]
					if prevVector
						table.insert animatedColors, Vector prevVector
					else
						return false, "\"#{component}\" at argument ##{i} is not pointing to a previous color!"
				else
					if component\match '^%x%x%x%x%x%x%x%x%x%x%x%x$'
						-- direct conversion to number will exceed 0xFFFFFFFF
						r = (tonumber component\sub(1, 4), 16)
						g = (tonumber component\sub(5, 8), 16)
						b = (tonumber component\sub(9, 12), 16)
						r = r - 0x10000 if r > 0x7FFF
						g = g - 0x10000 if g > 0x7FFF
						b = b - 0x10000 if b > 0x7FFF
						table.insert animatedColors, Vector r / 0xFF, g / 0xFF, b / 0xFF
					elseif component\match '^%x%x%x%x%x%x$'
						number = tonumber component, 16
						r = bit.band(number, 0xFF0000) / 0xFF0000
						g = bit.band(number, 0x00FF00) / 0x00FF00
						b = bit.band(number, 0x0000FF) / 0x0000FF
						table.insert animatedColors, Vector r, g, b
					elseif component\match '^%x%x%x$'
						number = tonumber component, 16
						r = bit.band(number, 0xF00) / 0xF00
						g = bit.band(number, 0x0F0) / 0x0F0
						b = bit.band(number, 0x00F) / 0x00F
						table.insert animatedColors, Vector r, g, b
					else
						return false, "\"#{component}\" at argument ##{i} is not a valid color format!"
	
	true, animatedColors

cvars.AddChangeCallback 'capawc_cl_player_colors', ((name, oldValue, newValue) ->
	success, animatedColors = InterpretColorDurationString newValue
	if success
		net.Start 'capawc'
		net.WriteUInt 1, 4
		WriteColorAnimation animatedColors
		net.SendToServer!
	else chat.AddText Color(255, 63, 63), animatedColors
), 'capawc'
cvars.AddChangeCallback 'capawc_cl_weapon_colors', ((name, oldValue, newValue) ->
	success, animatedColors = InterpretColorDurationString newValue
	if success
		halfNumAC = #animatedColors / 2

		net.Start 'capawc'
		net.WriteUInt 2, 4
		WriteColorAnimation animatedColors
		net.SendToServer!
	else chat.AddText Color(255, 63, 63), animatedColors
), 'capawc'

ReloadColorAnimations = ->
	success, animatedColors = InterpretColorDurationString playerColorConVar\GetString!
	if success
		net.Start 'capawc'
		net.WriteUInt 1, 4
		WriteColorAnimation animatedColors
		net.SendToServer!
	success, animatedColors = InterpretColorDurationString weaponColorConVar\GetString!
	if success
		net.Start 'capawc'
		net.WriteUInt 2, 4
		WriteColorAnimation animatedColors
		net.SendToServer!

ReloadColorAnimations!

hook.Add 'InitPostEntity', 'capawc', ->
	ReloadColorAnimations!
	return

hook.Add 'CCVCCMRun', 'capawc', ->
	with CCVCCM
		\SetAddon 'capawc', 'CAPAWC'
		\PushCategory 'cl', 'Client', true
		\AddConVar 'player_colors_enabled', {
			realm: 'client'
			default: true
			name: 'Enable Player Color Animation'
			type: 'bool'
			userInfo: true
		}
		\AddAddonVar 'player_colors', {
			realm: 'client'
			default: {
				{'F00', 2}
				{'FF0', 2}
				{'0F0', 2}
				{'0FF', 2}
				{'00F', 2}
				{'F0F', 2}
			}
			typeInfo: {
				help: 'Sets your player colors.\nColor '..commonHelpText
				{
					name: 'Color'
					type: 'string'
				}
				{
					name: 'Blend Duration'
					type: 'number'
					min: 0
					max: 60
				}
			}
			name: 'Player Colors'
			func: (value) ->
				playerColorConVar\SetString table.concat ["#{valueParts[1]} #{valueParts[2]}" for valueParts in *value], ' '
		}
		\AddConVar 'weapon_colors_enabled', {
			realm: 'client'
			default: true
			name: 'Enable Weapon Color Animation'
			type: 'bool'
			userInfo: true
		}
		\AddAddonVar 'weapon_colors', {
			realm: 'client'
			default: {
				{'F11', 4}
				{'1F1', 4}
				{'11F', 4}
			}
			typeInfo: {
				help: 'Sets your weapon colors.\nColor '..commonHelpText
				{
					name: 'Color'
					type: 'string'
				}
				{
					name: 'Blend Duration'
					type: 'number'
					min: 0
					max: 60
				}
			}
			name: 'Weapon Colors'
			func: (value) ->
				weaponColorConVar\SetString table.concat ["#{valueParts[1]} #{valueParts[2]}" for valueParts in *value], ' '
		}