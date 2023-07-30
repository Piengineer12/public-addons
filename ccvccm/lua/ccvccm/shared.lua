CCVCCM.AddPayloadToNetMessage = function(self, sendData)
  local currentType
  for i, sendUnit in ipairs(sendData) do
    if i % 2 == 0 then
      local _exp_0 = currentType
      if 's' == _exp_0 then
        net.WriteString(sendUnit)
      end
    else
      currentType = sendUnit
    end
  end
end
CCVCCM.ExtractPayloadFromNetMessage = function(self, typeData)
  local extracted = { }
  for _index_0 = 1, #typeData do
    local typ = typeData[_index_0]
    local _exp_0 = typ
    if 's' == _exp_0 then
      table.insert(extracted, net.ReadString())
    end
  end
  return extracted
end