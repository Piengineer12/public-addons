util.AddNetworkString 'ccvccm'

net.Receive 'ccvccm', (length, ply) ->
    if ply\IsAdmin!
        data = CCVCCM\ExtractPayloadFromNetMessage {'s'}
        game.ConsoleCommand data[1]..'\n'