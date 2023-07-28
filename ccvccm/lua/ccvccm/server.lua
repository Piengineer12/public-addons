util.AddNetworkString('ccvccm')
return net.Receive('ccvccm', function(length, ply)
  if ply:IsAdmin() then
    local data = CCVCCM:ExtractPayloadFromNetMessage({
      's'
    })
    return game.ConsoleCommand(data[1] .. '\n')
  end
end)