util.AddNetworkString 'ccvccm'
import ENUMS from CCVCCM

-- API
CCVCCM.api.clientInfoVars or= {['']: {}}

CCVCCM._SetUserInfoVar = (fullName, ply, value) =>
	@api.clientInfoVars[fullName] or= {}
	@api.clientInfoVars[fullName][ply] = value
	{data: {:func}} = @_GetRegisteredData fullName
	func value, fullName, ply if func

CCVCCM._GetUserInfoVar = (fullName, ply) =>
	@api.clientInfoVars[fullName] or= {}
	@api.clientInfoVars[fullName][ply]

-- NET
CCVCCM.GetSharedValues = =>
	results = {}
	for fullName, registeredData in pairs @api.data
		if registeredData.data.realm == 'shared'
			table.insert results, {
				:fullName
				type: @GetNetSingleAddonType fullName
				value: @_GetAddonVar fullName
			}
			coroutine.yield false, results
	true, results

avRepProcesses = {}
CCVCCM.StartAVRepProcess = (ply) =>
	unless avRepProcesses[ply]
		avRepProcesses[ply] = coroutine.create @\GetSharedValues
		timer.UnPause 'CCVCCM'

timer.Create 'CCVCCM', 0.015, 0, ->
	if next avRepProcesses
		for ply, process in pairs avRepProcesses
			ok, status, results = coroutine.resume process
			-- if results has too many entries, send the data and empty the table
			if not ok
				error status, results
			elseif #results > 64 or status
				CCVCCM\StartNet!
				CCVCCM\AddPayloadToNetMessage {'u8', ENUMS.NET.INIT_REP, 'u8', #results}
				for i, result in ipairs results
					CCVCCM\AddPayloadToNetMessage {'s', result.fullName}
					CCVCCM\AddPayloadToNetMessage {result.type, result.value}
					results[i] = nil
				CCVCCM\FinishNet ply

				avRepProcesses[ply] = nil if status
	else
		-- don't waste processing power
		timer.Pause 'CCVCCM'

net.Receive 'ccvccm', (length, ply) ->
	operation = CCVCCM\ExtractSingleFromNetMessage 'u8'
	switch operation
		when ENUMS.NET.EXEC
			if ply\IsAdmin!
				isLua = CCVCCM\ExtractSingleFromNetMessage 'b'
				if isLua
					fullName = CCVCCM\ExtractSingleFromNetMessage 's'
					unitType = CCVCCM\GetNetSingleAddonType fullName
					if unitType
						value = CCVCCM\ExtractSingleFromNetMessage unitType
						registeredData = CCVCCM\_GetRegisteredData fullName
						if registeredData.type == 'addonvar'
							CCVCCM\SetVarValue fullName, value
						else
							CCVCCM\RunCommand fullName, ply, value
				else
					data = CCVCCM\ExtractSingleFromNetMessage 's'
					game.ConsoleCommand data..'\n'
		when ENUMS.NET.REP
			fullName = CCVCCM\ExtractSingleFromNetMessage 's'
			unitType = CCVCCM\GetNetSingleAddonType fullName
			if unitType
				value = CCVCCM\ExtractSingleFromNetMessage unitType
				CCVCCM\_SetUserInfoVar fullName, ply, value

		when ENUMS.NET.QUERY
			varCount = CCVCCM\ExtractSingleFromNetMessage 'u8'
			varResults = {}

			for i=1, varCount
				fullName = CCVCCM\ExtractSingleFromNetMessage 's'
				registeredData = CCVCCM\_GetRegisteredData fullName
				if registeredData.type == 'addonvar' or registeredData.type == 'addoncommand'
					val = CCVCCM\_GetAddonVar fullName
					if val
						unitType = CCVCCM\GetNetSingleAddonType fullName
						if unitType
							table.insert varResults, {
								's', fullName,
								unitType, val
							}
				else
					conVar = GetConVar fullName
					if (IsValid conVar and not conVar\IsFlagSet FCVAR_PROTECTED)
						table.insert varResults, {
							's', fullName,
							's', conVar\GetString!
						}
			CCVCCM\StartNet!
			CCVCCM\AddPayloadToNetMessage {'u8', ENUMS.NET.QUERY, 'u8', #varResults}
			for varSend in *varResults do CCVCCM\AddPayloadToNetMessage varSend 
			CCVCCM\FinishNet ply

		when ENUMS.NET.INIT_REP
			{shouldReply, userInfoNum} = CCVCCM\ExtractPayloadFromNetMessage {'b', 'u8'}
			for i=1, userInfoNum
				fullName = CCVCCM\ExtractSingleFromNetMessage 's'
				unitType = CCVCCM\GetNetSingleAddonType fullName
				if unitType
					value = CCVCCM\ExtractSingleFromNetMessage unitType
					CCVCCM\_SetUserInfoVar fullName, ply, value
			-- client wants a copy of all replicated server addonvar values
			CCVCCM\StartAVRepProcess ply if shouldReply