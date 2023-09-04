util.AddNetworkString('ccvccm')
local ENUMS
ENUMS = CCVCCM.ENUMS
return net.Receive('ccvccm', function(length, ply)
  local operation = CCVCCM:ExtractSingleFromNetMessage('u8')
  local _exp_0 = operation
  if ENUMS.NET.EXEC == _exp_0 then
    if ply:IsAdmin() then
      local isLua = CCVCCM:ExtractSingleFromNetMessage('b')
      if isLua then
        local addon, categoryPath, name
        do
          local _obj_0 = CCVCCM:ExtractPayloadFromNetMessage({
            's',
            'ts',
            's'
          })
          addon, categoryPath, name = _obj_0[1], _obj_0[2], _obj_0[3]
        end
        local unitType = CCVCCM:GetNetSingleAddonType(addon, categoryPath, name)
        if unitType then
          local value = CCVCCM:ExtractSingleFromNetMessage(unitType)
          return CCVCCM:SetVarValue(addon, categoryPath, name, value)
        end
      else
        local data = CCVCCM:ExtractSingleFromNetMessage('s')
        return game.ConsoleCommand(data .. '\n')
      end
    end
  elseif ENUMS.NET.REP == _exp_0 then
    local addon, categoryPath, name
    do
      local _obj_0 = CCVCCM:ExtractPayloadFromNetMessage({
        's',
        'ts',
        's'
      })
      addon, categoryPath, name = _obj_0[1], _obj_0[2], _obj_0[3]
    end
    local unitType = CCVCCM:GetNetSingleAddonType(addon, categoryPath, name)
    if unitType then
      local value = CCVCCM:ExtractSingleFromNetMessage(unitType)
      local _update_0 = addon
      CCVCCM.api.clientInfoVars[_update_0] = CCVCCM.api.clientInfoVars[_update_0] or { }
      local currentTable = CCVCCM.api.clientInfoVars[addon]
      for _index_0 = 1, #categoryPath do
        local category = categoryPath[_index_0]
        local _update_1 = category
        currentTable[_update_1] = currentTable[_update_1] or { }
        currentTable = currentTable[category]
      end
      local _update_1 = name
      currentTable[_update_1] = currentTable[_update_1] or { }
      currentTable[name][ply] = value
    end
  elseif ENUMS.NET.QUERY == _exp_0 then
    local varCount = CCVCCM:ExtractSingleFromNetMessage('u8')
    local varResults = { }
    for i = 1, varCount do
      local isLua = CCVCCM:ExtractSingleFromNetMessage('b')
      if isLua then
        local addon, categoryPath, name
        do
          local _obj_0 = CCVCCM:ExtractPayloadFromNetMessage({
            's',
            'ts',
            's'
          })
          addon, categoryPath, name = _obj_0[1], _obj_0[2], _obj_0[3]
        end
        local val = CCVCCM:_GetAddonVar(name, addon, categoryPath)
        if val then
          local unitType = CCVCCM:GetNetSingleAddonType(addon, categoryPath, name)
          if unitType then
            table.insert(varResults, {
              'b',
              true,
              's',
              addon,
              'ts',
              categoryPath,
              's',
              name,
              unitType,
              val
            })
          end
        end
      else
        local varName = CCVCCM:ExtractSingleFromNetMessage('s')
        local conVar = GetConVar(varName)
        if (IsValid(conVar and not conVar:IsFlagSet(FCVAR_PROTECTED))) then
          table.insert(varResults, {
            'b',
            false,
            's',
            varName,
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
  end
end)