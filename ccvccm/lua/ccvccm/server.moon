util.AddNetworkString 'ccvccm'
import ENUMS from CCVCCM

net.Receive 'ccvccm', (length, ply) ->
	operation = CCVCCM\ExtractSingleFromNetMessage 'u8'
	switch operation
		when ENUMS.NET.EXEC
			if ply\IsAdmin!
				isLua = CCVCCM\ExtractSingleFromNetMessage 'b'
				if isLua
					{addon, categoryPath, name} = CCVCCM\ExtractPayloadFromNetMessage {'s', 'ts', 's'}
					unitType = CCVCCM\GetNetSingleAddonType addon, categoryPath, name
					if unitType
						value = CCVCCM\ExtractSingleFromNetMessage unitType
						CCVCCM\SetVarValue addon, categoryPath, name, value
				else
					data = CCVCCM\ExtractSingleFromNetMessage 's'
					game.ConsoleCommand data..'\n'
		when ENUMS.NET.REP
			{addon, categoryPath, name} = CCVCCM\ExtractPayloadFromNetMessage {'s', 'ts', 's'}
			unitType = CCVCCM\GetNetSingleAddonType addon, categoryPath, name
			if unitType
				value = CCVCCM\ExtractSingleFromNetMessage unitType
				
				CCVCCM.api.clientInfoVars[addon] or= {}
				currentTable = CCVCCM.api.clientInfoVars[addon]
				for category in *categoryPath
					currentTable[category] or= {}
					currentTable = currentTable[category]
				currentTable[name] or= {}
				currentTable[name][ply] = value
		when ENUMS.NET.QUERY
			varCount = CCVCCM\ExtractSingleFromNetMessage 'u8'
			varResults = {}

			for i=1, varCount
				isLua = CCVCCM\ExtractSingleFromNetMessage 'b'
				if isLua
					{addon, categoryPath, name} = CCVCCM\ExtractPayloadFromNetMessage {'s', 'ts', 's'}
					val = CCVCCM\_GetAddonVar name, addon, categoryPath
					if val
						unitType = CCVCCM\GetNetSingleAddonType addon, categoryPath, name
						if unitType
							table.insert varResults, {
								'b', true,
								's', addon,
								'ts', categoryPath,
								's', name,
								unitType, val
							}
				else
					varName = CCVCCM\ExtractSingleFromNetMessage 's'
					conVar = GetConVar varName
					if (IsValid conVar and not conVar\IsFlagSet FCVAR_PROTECTED)
						table.insert varResults, {
							'b', false,
							's', varName,
							's', conVar\GetString!
						}
			CCVCCM\StartNet!
			CCVCCM\AddPayloadToNetMessage {'u8', ENUMS.NET.QUERY, 'u8', #varResults}
			for varSend in *varResults do CCVCCM\AddPayloadToNetMessage varSend 
			CCVCCM\FinishNet ply