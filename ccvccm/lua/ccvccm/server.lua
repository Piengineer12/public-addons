util.AddNetworkString('ccvccm')
local ENUMS
ENUMS = CCVCCM.ENUMS
CCVCCM.api.clientInfoVars = CCVCCM.api.clientInfoVars or {
  [''] = { }
}
CCVCCM._SetUserInfoVar = function(self, fullName, ply, value)
  local _update_0 = fullName
  self.api.clientInfoVars[_update_0] = self.api.clientInfoVars[_update_0] or { }
  self.api.clientInfoVars[fullName][ply] = value
  local func
  func = self:_GetRegisteredData(fullName).data.func
  if func then
    return func(value, fullName, ply)
  end
end
CCVCCM._GetUserInfoVar = function(self, fullName, ply)
  local _update_0 = fullName
  self.api.clientInfoVars[_update_0] = self.api.clientInfoVars[_update_0] or { }
  return self.api.clientInfoVars[fullName][ply]
end
CCVCCM.GetSharedValues = function(self)
  local results = { }
  for fullName, registeredData in pairs(self.api.data) do
    if registeredData.data.realm == 'shared' then
      table.insert(results, {
        fullName = fullName,
        type = self:GetNetSingleAddonType(fullName),
        value = self:_GetAddonVar(fullName)
      })
      coroutine.yield(false, results)
    end
  end
  return true, results
end
local avRepProcesses = { }
CCVCCM.StartAVRepProcess = function(self, ply)
  if not (avRepProcesses[ply]) then
    avRepProcesses[ply] = coroutine.create((function()
      local _base_0 = self
      local _fn_0 = _base_0.GetSharedValues
      return function(...)
        return _fn_0(_base_0, ...)
      end
    end)())
    return timer.UnPause('CCVCCM')
  end
end
timer.Create('CCVCCM', 0.015, 0, function()
  if next(avRepProcesses) then
    for ply, process in pairs(avRepProcesses) do
      local ok, status, results = coroutine.resume(process)
      if not ok then
        error(status, results)
      elseif #results > 64 or status then
        CCVCCM:StartNet()
        CCVCCM:AddPayloadToNetMessage({
          'u8',
          ENUMS.NET.INIT_REP,
          'u8',
          #results
        })
        for i, result in ipairs(results) do
          CCVCCM:AddPayloadToNetMessage({
            's',
            result.fullName
          })
          CCVCCM:AddPayloadToNetMessage({
            result.type,
            result.value
          })
          results[i] = nil
        end
        CCVCCM:FinishNet(ply)
        if status then
          avRepProcesses[ply] = nil
        end
      end
    end
  else
    return timer.Pause('CCVCCM')
  end
end)
return net.Receive('ccvccm', function(length, ply)
  local operation = CCVCCM:ExtractSingleFromNetMessage('u8')
  local _exp_0 = operation
  if ENUMS.NET.EXEC == _exp_0 then
    if ply:IsAdmin() then
      local isLua = CCVCCM:ExtractSingleFromNetMessage('b')
      if isLua then
        local fullName = CCVCCM:ExtractSingleFromNetMessage('s')
        local unitType = CCVCCM:GetNetSingleAddonType(fullName)
        if unitType then
          local value = CCVCCM:ExtractSingleFromNetMessage(unitType)
          local registeredData = CCVCCM:_GetRegisteredData(fullName)
          if registeredData.type == 'addonvar' then
            return CCVCCM:SetVarValue(fullName, value)
          else
            return CCVCCM:RunCommand(fullName, ply, value)
          end
        end
      else
        local data = CCVCCM:ExtractSingleFromNetMessage('s')
        return game.ConsoleCommand(data .. '\n')
      end
    end
  elseif ENUMS.NET.REP == _exp_0 then
    local fullName = CCVCCM:ExtractSingleFromNetMessage('s')
    local unitType = CCVCCM:GetNetSingleAddonType(fullName)
    if unitType then
      local value = CCVCCM:ExtractSingleFromNetMessage(unitType)
      return CCVCCM:_SetUserInfoVar(fullName, ply, value)
    end
  elseif ENUMS.NET.QUERY == _exp_0 then
    local varCount = CCVCCM:ExtractSingleFromNetMessage('u8')
    local varResults = { }
    for i = 1, varCount do
      local fullName = CCVCCM:ExtractSingleFromNetMessage('s')
      local registeredData = CCVCCM:_GetRegisteredData(fullName)
      if registeredData.type == 'addonvar' or registeredData.type == 'addoncommand' then
        local val = CCVCCM:_GetAddonVar(fullName)
        if val then
          local unitType = CCVCCM:GetNetSingleAddonType(fullName)
          if unitType then
            table.insert(varResults, {
              's',
              fullName,
              unitType,
              val
            })
          end
        end
      else
        local conVar = GetConVar(fullName)
        if (IsValid(conVar and not conVar:IsFlagSet(FCVAR_PROTECTED))) then
          table.insert(varResults, {
            's',
            fullName,
            's',
            conVar:GetString()
          })
        end
      end
    end
    CCVCCM:StartNet()
    CCVCCM:AddPayloadToNetMessage({
      'u8',
      ENUMS.NET.QUERY,
      'u8',
      #varResults
    })
    for _index_0 = 1, #varResults do
      local varSend = varResults[_index_0]
      CCVCCM:AddPayloadToNetMessage(varSend)
    end
    return CCVCCM:FinishNet(ply)
  elseif ENUMS.NET.INIT_REP == _exp_0 then
    local shouldReply, userInfoNum
    do
      local _obj_0 = CCVCCM:ExtractPayloadFromNetMessage({
        'b',
        'u8'
      })
      shouldReply, userInfoNum = _obj_0[1], _obj_0[2]
    end
    for i = 1, userInfoNum do
      local fullName = CCVCCM:ExtractSingleFromNetMessage('s')
      local unitType = CCVCCM:GetNetSingleAddonType(fullName)
      if unitType then
        local value = CCVCCM:ExtractSingleFromNetMessage(unitType)
        CCVCCM:_SetUserInfoVar(fullName, ply, value)
      end
    end
    if shouldReply then
      return CCVCCM:StartAVRepProcess(ply)
    end
  end
end)