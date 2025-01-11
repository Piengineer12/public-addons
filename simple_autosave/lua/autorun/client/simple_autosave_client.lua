net.Receive('simple_autosave', function()
  local msgType = net.ReadUInt(4)
  local _exp_0 = msgType
  if 1 == _exp_0 then
    local message = language.GetPhrase('simple_autosave.game_saved')
    notification.AddLegacy("[Simple Autosave] " .. tostring(message), NOTIFY_GENERIC, 10)
    return surface.PlaySound('garrysmod/content_downloaded.wav')
  elseif 2 == _exp_0 then
    chat.AddText('[Simple Autosave] ', language.GetPhrase('simple_autosave.sandbox_only.1'), '\n[Simple Autosave] ', language.GetPhrase('simple_autosave.sandbox_only.2'))
    return surface.PlaySound('buttons/button10.wav')
  elseif 3 == _exp_0 then
    local message = string.Replace(language.GetPhrase('simple_autosave.in_x'), '%1', string.format('%.1f', net.ReadFloat()))
    notification.AddLegacy("[Simple Autosave] " .. tostring(message), NOTIFY_GENERIC, 10)
    return surface.PlaySound('common/warning.wav')
  elseif 4 == _exp_0 then
    chat.AddText('[Simple Autosave] ', language.GetPhrase('simple_autosave.no_players_to_save_to'))
    return surface.PlaySound('buttons/button10.wav')
  elseif 5 == _exp_0 then
    return RunConsoleCommand('gm_save')
  end
end)
hook.Add('AddToolMenuCategories', 'SimpleAutoSave', function()
  spawnmenu.AddToolCategory('Utilities', 'simple_autosave', '#simple_autosave')
end)
return hook.Add('PopulateToolMenu', 'SimpleAutoSave', function()
  spawnmenu.AddToolMenuOption('Utilities', 'simple_autosave', 'simple_autosave_options', '#simple_autosave.options', '', '', function(DForm)
    do
      local _with_0 = DForm
      _with_0:Help('')
      _with_0:ControlHelp('#simple_autosave')
      _with_0:CheckBox('#simple_autosave.options.enabled', 'simple_autosave_enabled')
      _with_0:NumSlider('#simple_autosave.options.interval', 'simple_autosave_interval', 10, 3600, 0)
      _with_0:Help('#simple_autosave.options.interval.help')
      _with_0:NumSlider('#simple_autosave.options.warning_duration', 'simple_autosave_warning_duration', 0, 600, 0)
      _with_0:Help('#simple_autosave.options.warning_duration.help')
      _with_0:Button('#simple_autosave.trigger', 'simple_autosave_trigger')
      _with_0:Help('#simple_autosave.trigger.help')
      _with_0:Button('#simple_autosave.trigger.now', 'simple_autosave_trigger', 'now')
      _with_0:Help('#simple_autosave.trigger.now.help')
      return _with_0
    end
  end)
end)
