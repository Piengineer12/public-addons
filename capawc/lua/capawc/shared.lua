return hook.Add('CCVCCMRun', 'capawc', function()
  do
    local _with_0 = CCVCCM
    _with_0:SetAddon('capawc', 'CAPAWC')
    _with_0:PushCategory('sv', 'Server', true)
    _with_0:AddConVar('minimum_blend_time', {
      realm = 'server',
      default = 0,
      name = 'Minimum Blend Time',
      help = 'Minimum time between color blends. This is ignored when "blending" two colors that are the same.',
      type = 'float',
      min = 0,
      max = 2,
      interval = 0.001
    })
    _with_0:AddConVar('bots', {
      realm = 'server',
      default = true,
      name = 'Bot Colors',
      help = 'Should bots be affected? Note that bots will simply have rainbow colors.',
      type = 'bool'
    })
    _with_0:AddConVar('gamemode_blacklist', {
      realm = 'server',
      default = '',
      name = 'Gamemode Blacklist',
      help = 'Player colors will never be animated in these gamemodes. This has no effect on weapon colors.',
      type = 'string',
      sep = ' '
    })
    _with_0:AddConVar('gamemode_whitelist_enabled', {
      realm = 'server',
      default = true,
      name = 'Gamemode Whitelist Enabled',
      help = 'Player colors will only be animated in the gamemodes specified by capawc_sv_gamemode_whitelist.',
      type = 'bool'
    })
    _with_0:AddConVar('gamemode_whitelist', {
      realm = 'server',
      default = {
        'base',
        'sandbox',
        'cinema',
        'elevator',
        'jazztronauts'
      },
      name = 'Gamemode Whitelist',
      help = 'Player colors will be animated in these gamemodes when the gamemode whitelist is enabled.',
      type = 'string',
      sep = ' '
    })
    return _with_0
  end
end)
