local playerAnimationPlayerData = { }
local weaponAnimationPlayerData = { }
local minBlendTimeConVar = CreateConVar('capawc_sv_minimum_blend_time', '0', FCVAR_ARCHIVE, 'Minimum time between color blends. This is ignored when "blending" two colors that are the same.', 0, 2)
local botConVar = CreateConVar('capawc_sv_bots', '1', FCVAR_ARCHIVE, 'Should bots be affected? Note that bots will simply have rainbow colors.', 0, 1)
local gamemodeBlacklistConVar = CreateConVar('capawc_sv_gamemode_blacklist', '', FCVAR_ARCHIVE, 'Player colors will never be animated in these gamemodes. This has no effect on weapon colors.')
local gamemodeWhitelistConVar = CreateConVar('capawc_sv_gamemode_whitelist', 'base sandbox cinema elevator jazztronauts', FCVAR_ARCHIVE, 'Player colors will be animated in these gamemodes when the gamemode whitelist is enabled.')
local gamemodeWhitelistEnabledConVar = CreateConVar('capawc_sv_gamemode_whitelist_enabled', 0, FCVAR_ARCHIVE, 'Player colors will only be animated in the gamemodes specified by capawc_sv_gamemode_whitelist.')
local gamemodeEnables = false
local RecheckGamemodeEnabledState
RecheckGamemodeEnabledState = function()
  timer.Simple(0, function()
    local gamemode = engine.ActiveGamemode():lower()
    local _list_0 = string.Explode('%s+', gamemodeBlacklistConVar:GetString(), true)
    for _index_0 = 1, #_list_0 do
      local blacklistedGamemode = _list_0[_index_0]
      if gamemode == blacklistedGamemode:lower() then
        gamemodeEnables = false
        return 
      end
    end
    if gamemodeWhitelistEnabledConVar:GetBool() then
      gamemodeEnables = false
      local _list_1 = string.Explode('%s+', gamemodeWhitelistConVar:GetString(), true)
      for _index_0 = 1, #_list_1 do
        local whitelistedGamemode = _list_1[_index_0]
        if gamemode == whitelistedGamemode:lower() then
          gamemodeEnables = true
          return 
        end
      end
    else
      gamemodeEnables = true
    end
  end)
end
cvars.AddChangeCallback('capawc_sv_minimum_blend_time', (function(name, oldValue, newValue)
  for ply, animationData in pairs(playerAnimationPlayerData) do
    animationData[3] = nil
  end
  for ply, animationData in pairs(weaponAnimationPlayerData) do
    animationData[3] = nil
  end
end), 'capawc')
cvars.AddChangeCallback('capawc_sv_gamemode_blacklist', RecheckGamemodeEnabledState, 'capawc')
cvars.AddChangeCallback('capawc_sv_gamemode_whitelist', RecheckGamemodeEnabledState, 'capawc')
cvars.AddChangeCallback('capawc_sv_gamemode_whitelist_enabled', RecheckGamemodeEnabledState, 'capawc')
hook.Add('InitPostEntity', 'capawc', RecheckGamemodeEnabledState)
local TranslateAndOptimize
TranslateAndOptimize = function(animationColors)
  local phases = { }
  local animationDuration = 0
  for i = 1, #animationColors / 2 do
    table.insert(phases, {
      animationDuration,
      animationColors[i * 2 - 1]
    })
    animationDuration = animationDuration + animationColors[i * 2]
  end
  return {
    animationDuration,
    phases
  }
end
util.AddNetworkString('capawc')
net.Receive('capawc', function(len, ply)
  local operation = net.ReadUInt(4)
  local colorCount = net.ReadUInt(8)
  local receivedColors = { }
  local receivedDurations = { }
  for i = 1, colorCount do
    local r, g, b = net.ReadFloat(), net.ReadFloat(), net.ReadFloat()
    table.insert(receivedColors, Vector(r, g, b))
    table.insert(receivedDurations, math.max(net.ReadFloat(), 0))
  end
  local _exp_0 = operation
  if 1 == _exp_0 then
    playerAnimationPlayerData[ply] = {
      receivedDurations,
      receivedColors
    }
  elseif 2 == _exp_0 then
    weaponAnimationPlayerData[ply] = {
      receivedDurations,
      receivedColors
    }
  end
end)
local GetCurrentColorByAnimationData
GetCurrentColorByAnimationData = function(animationData)
  local animationColors = animationData[2]
  local timings, totalDuration
  if animationData[3] then
    do
      local _obj_0 = animationData[3]
      totalDuration, timings = _obj_0[1], _obj_0[2]
    end
  else
    timings = { }
    totalDuration = 0
    for i, duration in ipairs(animationData[1]) do
      timings[i] = totalDuration
      local currentColor = animationColors[i]
      local nextColor = animationColors[i + 1] or animationColors[1]
      if currentColor == nextColor then
        totalDuration = totalDuration + duration
      else
        totalDuration = totalDuration + math.max(duration, minBlendTimeConVar:GetFloat())
      end
    end
    animationData[3] = {
      totalDuration,
      timings
    }
  end
  local animationTime = CurTime() % totalDuration
  local frame = 0
  for i, timing in ipairs(timings) do
    if animationTime >= timing then
      frame = i
    else
      break
    end
  end
  local animationFrameDuration = (timings[frame + 1] or totalDuration) - timings[frame]
  local animationFrameDelta = (animationTime - timings[frame]) / animationFrameDuration
  local currentColor = animationColors[frame]
  local nextColor = animationColors[frame + 1] or animationColors[1]
  return LerpVector(animationFrameDelta, currentColor, nextColor)
end
return hook.Add('Think', 'capawc', function()
  local _list_0 = player.GetAll()
  for _index_0 = 1, #_list_0 do
    local ply = _list_0[_index_0]
    if not ply:IsBot() or botConVar:GetBool() then
      local animationData = playerAnimationPlayerData[ply]
      if animationData and gamemodeEnables and tobool(ply:GetInfo('capawc_cl_player_colors_enabled')) then
        local color = GetCurrentColorByAnimationData(animationData)
        ply:SetPlayerColor(color)
      end
      animationData = weaponAnimationPlayerData[ply]
      if animationData and tobool(ply:GetInfo('capawc_cl_weapon_colors_enabled')) then
        local color = GetCurrentColorByAnimationData(animationData)
        ply:SetWeaponColor(color)
      end
    end
  end
end)
