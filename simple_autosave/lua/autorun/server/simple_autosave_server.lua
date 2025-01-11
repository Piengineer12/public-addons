local ConEnabled = CreateConVar('simple_autosave_enabled', 1, FCVAR_ARCHIVE, 'Enables Simple Autosave.')
local ConInterval = CreateConVar('simple_autosave_interval', 900, FCVAR_ARCHIVE, 'Sets the amount of seconds between each autosave. Minimum autosave interval is 10 seconds.')
local ConWarning = CreateConVar('simple_autosave_warning_duration', 10, FCVAR_ARCHIVE, 'If above 0, displays a message when the game is about to be saved.')
util.AddNetworkString('simple_autosave')
local nextSave = math.huge
local warningTriggered = false
local nonSandboxWarningTriggered = false
local manual = false
concommand.Add('simple_autosave_trigger', (function(ply, cmd, args, argStr)
  manual = true
  if args[1] == 'now' then
    nextSave = 0
  else
    nextSave = CurTime() + ConWarning:GetFloat()
  end
  warningTriggered = args[1] == 'now'
end), nil, 'Sets the next autosave time to the warning interval. Use the argument "now" to autosave immediately.')
local SandboxWarn
SandboxWarn = function()
  if not (nonSandboxWarningTriggered) then
    nonSandboxWarningTriggered = true
    print('GAMEMODE.IsSandboxDerived =', GAMEMODE.IsSandboxDerived)
    print('[Simple Autosave] Simple Autosave is currently broken outside of Sandbox, sorry!')
    print('[Simple Autosave] I\'ll add non-Sandbox support if I receive enough requests for it.')
    net.Start('simple_autosave')
    net.WriteUInt(2, 4)
    return net.Broadcast()
  end
end
hook.Add('InitPostEntity', 'SimpleAutoSave', function()
  nextSave = CurTime() + math.max(10, ConInterval:GetFloat())
end)
return hook.Add('Think', 'SimpleAutoSave', function()
  local curTime = CurTime()
  if ConEnabled:GetBool() or manual then
    local warningDuration = ConWarning:GetFloat()
    if nextSave < curTime and warningTriggered then
      nextSave = curTime + math.max(10, ConInterval:GetFloat())
      warningTriggered = false
      manual = false
      if GAMEMODE.IsSandboxDerived then
        local writeOnto
        do
          local _accum_0 = { }
          local _len_0 = 1
          for i, ply in player.Iterator() do
            if ply:IsListenServerHost() then
              _accum_0[_len_0] = ply
              _len_0 = _len_0 + 1
            end
          end
          writeOnto = _accum_0
        end
        if not (next(writeOnto)) then
          do
            local _accum_0 = { }
            local _len_0 = 1
            for i, ply in player.Iterator() do
              if ply:IsSuperAdmin() then
                _accum_0[_len_0] = ply
                _len_0 = _len_0 + 1
              end
            end
            writeOnto = _accum_0
          end
        end
        if next(writeOnto) then
          net.Start('simple_autosave')
          net.WriteUInt(5, 4)
          net.Send(writeOnto)
          timer.Simple(0, function()
            print('[Simple Autosave] Your game has been saved.')
            net.Start('simple_autosave')
            net.WriteUInt(1, 4)
            return net.Broadcast()
          end)
        else
          print('[Simple Autosave] Failed to write save file as neither the listen server host nor any superadmins were in the server!')
          net.Start('simple_autosave')
          net.WriteUInt(4, 4)
          net.Broadcast()
        end
      else
        SandboxWarn()
      end
    elseif nextSave < curTime + warningDuration and not warningTriggered then
      warningTriggered = true
      nextSave = curTime + warningDuration
      if GAMEMODE.IsSandboxDerived then
        print("[Simple Autosave] Autosaving in " .. tostring(warningDuration) .. " seconds.")
        net.Start('simple_autosave')
        net.WriteUInt(3, 4)
        net.WriteFloat(warningDuration)
        net.Broadcast()
      else
        SandboxWarn()
      end
    end
  else
    warningTriggered = false
  end
end)
