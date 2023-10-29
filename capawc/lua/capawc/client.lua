local commonHelpText = 'Format: <color1> <duration1> <color2> <duration2> <color3> <duration3> ...\nColors must be specified in RGB or RRGGBB hexadecimal formats, or be one of (without quotes) "r", "g", "b", "c", "m", "y", "k", "u" or "w". \z\nThe RRRRGGGGBBBB hexadecimal format is also accepted for color overclocking. Note that values above 32767 are subtracted by 65536, leading to color underclocking.\n"+" is also accepted, which uses the previous color.\nDuration specifies how many seconds it takes to blend between colors. Decimal values are allowed.'
local playerEnabledConVar = CreateClientConVar('capawc_player_colors_enabled', '1', true, true, 'Enables player color animation.', 0, 1)
local weaponEnabledConVar = CreateClientConVar('capawc_weapon_colors_enabled', '1', true, true, 'Enables weapon color animation.', 0, 1)
local playerColorConVar = CreateClientConVar('capawc_player_colors', 'F00 2 FF0 2 0F0 2 0FF 2 00F 2 F0F 2', true, false, 'Sets your player colors.\n' .. commonHelpText)
local weaponColorConVar = CreateClientConVar('capawc_weapon_colors', 'F11 4 1F1 4 11F 4', true, false, 'Sets your weapon colors.\n' .. commonHelpText)
local WriteColorAnimation
WriteColorAnimation = function(animatedColors)
  local halfNumAC = #animatedColors / 2
  net.WriteUInt(halfNumAC, 8)
  for i = 1, halfNumAC do
    local r, g, b = animatedColors[i * 2 - 1]:Unpack()
    net.WriteFloat(r)
    net.WriteFloat(g)
    net.WriteFloat(b)
    net.WriteFloat(animatedColors[i * 2])
  end
end
local InterpretColorDurationString
InterpretColorDurationString = function(colorDurationString)
  local animatedColors = { }
  local components = string.Explode('%s+', colorDurationString, true)
  if #components < 1 or 1 == bit.band(#components, 1) then
    return false, 'Number of arguments must be even and non-zero!'
  end
  for i, component in ipairs(components) do
    if 0 == bit.band(i, 1) then
      local duration = tonumber(component)
      if not (duration) then
        return false, "\"" .. tostring(component) .. "\" at argument #" .. tostring(i) .. " is not a valid number!"
      end
      if duration < 0 then
        return false, "\"" .. tostring(component) .. "\" at argument #" .. tostring(i) .. " must be positive!"
      end
      table.insert(animatedColors, duration)
    else
      local _exp_0 = component
      if 'r' == _exp_0 then
        table.insert(animatedColors, Vector(1, 0, 0))
      elseif 'g' == _exp_0 then
        table.insert(animatedColors, Vector(0, 1, 0))
      elseif 'b' == _exp_0 then
        table.insert(animatedColors, Vector(0, 0, 1))
      elseif 'c' == _exp_0 then
        table.insert(animatedColors, Vector(0, 1, 1))
      elseif 'm' == _exp_0 then
        table.insert(animatedColors, Vector(1, 0, 1))
      elseif 'y' == _exp_0 then
        table.insert(animatedColors, Vector(1, 1, 0))
      elseif 'k' == _exp_0 then
        table.insert(animatedColors, Vector(0, 0, 0))
      elseif 'u' == _exp_0 then
        table.insert(animatedColors, Vector(.5, .5, .5))
      elseif 'w' == _exp_0 then
        table.insert(animatedColors, Vector(1, 1, 1))
      elseif '+' == _exp_0 then
        local prevVector = animatedColors[i - 2]
        if prevVector then
          table.insert(animatedColors, Vector(prevVector))
        else
          return false, "\"" .. tostring(component) .. "\" at argument #" .. tostring(i) .. " is not pointing to a previous color!"
        end
      else
        if component:match('^%x%x%x%x%x%x%x%x%x%x%x%x$') then
          local r = (tonumber(component:sub(1, 4), 16))
          local g = (tonumber(component:sub(5, 8), 16))
          local b = (tonumber(component:sub(9, 12), 16))
          if r > 0x7FFF then
            r = r - 0x10000
          end
          if g > 0x7FFF then
            g = g - 0x10000
          end
          if b > 0x7FFF then
            b = b - 0x10000
          end
          table.insert(animatedColors, Vector(r / 0xFF, g / 0xFF, b / 0xFF))
        elseif component:match('^%x%x%x%x%x%x$') then
          local number = tonumber(component, 16)
          local r = bit.band(number, 0xFF0000) / 0xFF0000
          local g = bit.band(number, 0x00FF00) / 0x00FF00
          local b = bit.band(number, 0x0000FF) / 0x0000FF
          table.insert(animatedColors, Vector(r, g, b))
        elseif component:match('^%x%x%x$') then
          local number = tonumber(component, 16)
          local r = bit.band(number, 0xF00) / 0xF00
          local g = bit.band(number, 0x0F0) / 0x0F0
          local b = bit.band(number, 0x00F) / 0x00F
          table.insert(animatedColors, Vector(r, g, b))
        else
          return false, "\"" .. tostring(component) .. "\" at argument #" .. tostring(i) .. " is not a valid color format!"
        end
      end
    end
  end
  return true, animatedColors
end
cvars.AddChangeCallback('capawc_player_colors', (function(name, oldValue, newValue)
  local success, animatedColors = InterpretColorDurationString(newValue)
  if success then
    net.Start('capawc')
    net.WriteUInt(1, 4)
    WriteColorAnimation(animatedColors)
    return net.SendToServer()
  else
    return chat.AddText(Color(255, 63, 63), animatedColors)
  end
end), 'capawc')
cvars.AddChangeCallback('capawc_weapon_colors', (function(name, oldValue, newValue)
  local success, animatedColors = InterpretColorDurationString(newValue)
  if success then
    local halfNumAC = #animatedColors / 2
    net.Start('capawc')
    net.WriteUInt(2, 4)
    WriteColorAnimation(animatedColors)
    return net.SendToServer()
  else
    return chat.AddText(Color(255, 63, 63), animatedColors)
  end
end), 'capawc')
local ReloadColorAnimations
ReloadColorAnimations = function()
  local success, animatedColors = InterpretColorDurationString(playerColorConVar:GetString())
  if success then
    net.Start('capawc')
    net.WriteUInt(1, 4)
    WriteColorAnimation(animatedColors)
    net.SendToServer()
  end
  success, animatedColors = InterpretColorDurationString(weaponColorConVar:GetString())
  if success then
    net.Start('capawc')
    net.WriteUInt(2, 4)
    WriteColorAnimation(animatedColors)
    return net.SendToServer()
  end
end
ReloadColorAnimations()
return hook.Add('InitPostEntity', 'capawc', function()
  ReloadColorAnimations()
end)
