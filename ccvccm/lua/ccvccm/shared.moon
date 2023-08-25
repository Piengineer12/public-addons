-- there must be a better way than polluting the global table...
CCVCCM.ENUMS = {
	NET: {
		REP: 1
		EXEC: 2
		QUERY: 3
	}
}

CCVCCM.StartNetMessage = =>
	net.Start 'ccvccm'
CCVCCM.SendNetMessage = (recipients) =>
	if CLIENT then net.SendToServer!
	if SERVER
		if recipients then net.Send recipients else net.Broadcast!

CCVCCM.Send = (sendData, recipients) =>
	@StartNet!
	@AddPayloadToNetMessage sendData
	@FinishNet recipients

CCVCCM.AddPayloadToNetMessage = (sendData) =>
	local currentType
	for i, sendUnit in ipairs sendData
		if i % 2 == 0
			switch currentType
				when 'b'
					net.WriteBool sendUnit
				when 'u8'
					net.WriteUInt sendUnit, 8
				when 'i16'
					net.WriteInt sendUnit, 16
				when 'd'
					net.WriteDouble sendUnit
				when 's'
					net.WriteString sendUnit
				when 't'
					net.WriteTable sendUnit
				when 'ts'
					-- sendUnit is a sequential table of strings
					net.WriteUInt #sendUnit, 16
					for str in *sendUnit do net.WriteString str
		else
			currentType = sendUnit

CCVCCM.ExtractSingleFromNetMessage = (dataType) =>
	switch dataType
		when 'b'
			net.ReadBool!
		when 'u8'
			net.ReadUInt 8
		when 'd'
			net.ReadDouble!
		when 's'
			net.ReadString!
		when 't'
			net.ReadTable!
		when 'ts'
			[net.ReadString! for i=1, net.ReadUInt 16]

CCVCCM.ExtractPayloadFromNetMessage = (dataTypes) =>
	if istable dataTypes
		[@ExtractSingleFromNetMessage dataType for dataType in *dataTypes]
	else
		{@ExtractSingleFromNetMessage dataTypes}

-- API
class CCVCCMPointer
	new: (name, addon = CCVCCM.api.addon, categoryPath = CCVCCM.api.categoryPath) =>
		@addon = addon
		@categoryPath = categories
		@name = name

	Get: => CCVCCM\GetVarValue @addon, @categoryPath, @name
	Set: (value) => CCVCCM\SetVarValue @addon, @categoryPath, @name, value
	Revert: => CCVCCM\RevertVarValue @addon, @categoryPath, @name
	Run: (value) => CCVCCM\RunCommand @addon, @categoryPath, @name, value

CCVCCM.api = CCVCCM.api or {
	data: {
		['']: {
			name: 'Other'
			categories: {}
			categoriesOrder: {}
			categoriesUseTab: false
			registered: {}
			registeredOrder: {}
		}
	}
	-- cacheRegisteredData: {}
	addonVars: {['']: {}}
	addon: ''
	categoryPath: {}
}
CCVCCM.api.clientInfoVars = {['']: {}} if SERVER
hook.Add 'CCVCCMDataLoad', 'CCVCCM', (data) ->
	table.Add data, CCVCCM\_CreateElementData!
hook.Add 'Initialize', 'CCVCCM', -> hook.Run 'CCVCCMRun'
hook.Add 'CCVCCMRun', 'CCVCCM', ->
	-- add clientside ccvccm_autoload convar
	CCVCCM\SetAddon 'ccvccm', 'CCVCCM'
	CCVCCM\AddConVar 'autoload', {
		realm: 'client'
		name: 'Autoloaded File'
		help: 'Layout to automatically load when CCVCCM is opened.'
	}
	CCVCCM\AddConVar 'test', {
		realm: 'client'
		name: 'TESTING ONLY'
		type: 'string'
		sep: ' '
		choices: {
			{"Display Name 1", "value1"},
			{"Display Name 2", "value2"}
		}
	}

-- internal portion
CCVCCM._ConstructCategory = =>
	{
		categories: {}
		categoriesOrder: {}
		categoriesUseTab: false
		registered: {}
		registeredOrder: {}
	}
CCVCCM._GetCategoryTable = (addon = @api.addon, categoryPath = @api.categoryPath) =>
	currentTable = @api.data[addon]
	for category in *categoryPath
		unless currentTable.categories[category]
			table.insert currentTable.categoriesOrder, category
			currentTable.categories[category] = @_ConstructCategory!
		currentTable = currentTable.categories[category]
	currentTable

CCVCCM._GetRegisteredData = (name, addon = @api.addon, categoryPath = @api.categoryPath) =>
	-- cacheKey = name
	-- if next categoryPath then cacheKey = table.concat(categoryPath, '_')..'_'..cacheKey
	-- if addon then cacheKey = addon..'_'..cacheKey

	-- cacheRegisteredData = @api.cacheRegisteredData
	-- unless cacheRegisteredData[cacheKey]
	-- 	categoryTable = @_GetCategoryTable addon, categoryPath
	-- 	cacheRegisteredData[cacheKey] = categoryTable.registered[name]
	-- cacheRegisteredData[cacheKey]
	categoryTable = @_GetCategoryTable addon, categoryPath
	categoryTable.registered[name]

CCVCCM._GetCheatsEnabled = => GetConVar('sv_cheats')\GetBool!

CCVCCM._RegisterIntoCategory = (internal, data, typ) =>
	{:registered, :registeredOrder} = @_GetCategoryTable!
	if not registered[internal] then table.insert registeredOrder, internal
	if data.hide then data.hide = {str, true for str in *string.Explode('%s+', data.hide or '', true)}
	if data.flags then data.flags = {str, true for str in *string.Explode('%s+', data.flags or '', true)}
	registered[internal] = type: typ, :data

CCVCCM._AssembleVarName = (name, addon = @api.addon, categoryPath = @api.categoryPath) =>
	nameFragments = {addon}
	for category in *categoryPath do table.insert nameFragments, category
	table.insert nameFragments, name
	table.concat nameFragments, '_'

CCVCCM._GenerateConVar = (internal, data) =>
	realm = data.realm or 'server'
	if realm == 'shared' or realm == 'server' and SERVER or realm == 'client' and CLIENT
		{:help, :default, :hide, :flags, :min, :max, :clamp} = data
		archiveFlags = bit.bor FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX
		conFlags = bit.bor archiveFlags, FCVAR_PRINTABLEONLY

		if data.userInfo
			conFlags = bit.bor conFlags, FCVAR_USERINFO
		if data.notify
			conFlags = bit.bor conFlags, FCVAR_NOTIFY
		switch realm
			when 'shared'
				conFlags = bit.bor conFlags, FCVAR_REPLICATED

		if hide
			if hide.client
				conFlags = bit.bor conFlags, FCVAR_PROTECTED
			if hide.server
				conFlags = bit.bor conFlags, FCVAR_SERVER_CANNOT_QUERY
			if hide.console
				conFlags = bit.bor conFlags, FCVAR_UNREGISTERED
			if hide.log
				conFlags = bit.bor conFlags, FCVAR_UNLOGGED

		if flags
			if flags.cheat
				conFlags = bit.bor conFlags, FCVAR_CHEAT
			if flags.nosave
				conFlags = bit.band conFlags, bit.bnot archiveFlags
			if flags.sp
				conFlags = bit.bor conFlags, FCVAR_SPONLY
			if flags.control
				if realm == 'shared' or data.userInfo or data.notify then error('control flag cannot be used in shared realm, .userInfo or .notify')
				conFlags = bit.band conFlags, bit.bnot FCVAR_PRINTABLEONLY
				conFlags = bit.bor conFlags, FCVAR_NEVER_AS_STRING
			if flags.demo
				conFlags = bit.bor conFlags, FCVAR_DEMO
			if flags.nodemo
				if flags.demo then error('demo and nodemo flags cannot be on the same ConVar!')
				conFlags = bit.bor conFlags, FCVAR_DONTRECORD

		help or= ''
		default or= ''
		unless clamp
			min = nil
			max = nil
		CreateConVar @_AssembleVarName(internal), default, conFlags, help, min, max

CCVCCM._GenerateConCommand = (internal, data) =>
	realm = data.realm
	if realm == 'shared' or realm == 'server' and SERVER or realm == 'client' and CLIENT
		{:help, :func, :autoComplete, :choices, :hide, :flags} = data
		-- if no auto-complete is specified yet choices are given,
		-- create our own auto-complete function that sends those choices
		unless autoComplete
			choiceValuesLowercase = [string.lower v for k,v in pairs choices]
			autoComplete = (cmd, argStr) ->
				lowercaseArgStr = string.lower string.Trim argStr
				[cmd..' '..choice for choice in *choiceValuesLowercase when string.StartsWith choice, lowercaseArgStr]

		conFlags = 0

		if hide.console
			conFlags = bit.bor conFlags, FCVAR_UNREGISTERED
		if hide.log
			conFlags = bit.bor conFlags, FCVAR_UNLOGGED

		if flags.cheat
			conFlags = bit.bor conFlags, FCVAR_CHEAT
		if flags.sp
			conFlags = bit.bor conFlags, FCVAR_SPONLY
		if flags.demo
			conFlags = bit.bor conFlags, FCVAR_DEMO
		if flags.nodemo
			if flags.demo then error('demo and nodemo flags cannot be on the same ConVar!')
			conFlags = bit.bor conFlags, FCVAR_DONTRECORD

		concommand.Add @_AssembleVarName(internal), func, autoComplete, help, conFlags

CCVCCM._SetAddonVar = (internal, value, addon = @api.addon, categoryPath = @api.categoryPath) =>
	-- internal method for setting the addonvar and do nothing else
	currentTable = @api.addonVars[addon]
	for category in *categoryPath do
		currentTable[category] or= {}
		currentTable = currentTable[category]
	currentTable[internal] = value

CCVCCM._GetAddonVar = (internal, addon = @api.addon, categoryPath = @api.categoryPath) =>
	-- internal method for getting the addonvar and do nothing else
	currentTable = @api.addonVars[addon]
	for category in *categoryPath do
		currentTable[category] or= {}
		currentTable = currentTable[category]
	currentTable[internal]

CCVCCM._CreateCategoryData = (addon, categoryPath, categoryTable) =>
	{:categoryName, :categories, :categoriesOrder, :categoriesUseTab, :registeredOrder, :registered} = categoryTable
	saveTable = {}
	for registeredName in *registeredOrder
		elementData = registered[registeredName]
		{
			:name,
			:help,
			:realm,
			:manual,
			type: dataType,
			:sep,
			:choices,
			:min,
			:max,
			:interval,
			:logarithmic
		} = elementData.data
		switch elementData.type
			-- insert two elements - a CCVCCPanel and help TextPanel
			when 'convar'
				newDataType = dataType or 'string'

				if choices
					newDataType = if sep then 'choiceList' else 'choice'
				elseif dataType == 'int'
					newDataType = if sep then 'numberList' else 'number'
					interval = math.max math.Round(interval or 1), 1
				elseif dataType == 'float'
					newDataType = if sep then 'numberList' else 'number'
				elseif newDataType == 'string' and sep
					newDataType = 'stringList'

				internalName = @_AssembleVarName registeredName, addon, categoryPath
				table.insert saveTable, {
					elementType: if realm == 'client' then 'clientConVar' else 'serverConVar'
					:internalName
					displayName: name or internalName
					:manual
					dataType: newDataType
					listSeparator: sep
					:choices
					:min
					:max
					:interval
					:logarithmic
				}

			when 'concommand'
				newDataType = dataType or 'none'

				if choices
					newDataType = if sep then 'choiceList' else 'choice'
				elseif dataType == 'int'
					newDataType = if sep then 'numberList' else 'number'
					interval = math.max math.Round(interval or 1), 1
				elseif dataType == 'float'
					newDataType = if sep then 'numberList' else 'number'
				elseif dataType == 'string' and sep
					newDataType = 'stringList'

				internalName = @_AssembleVarName registeredName, addon, categoryPath
				table.insert saveTable, {
					elementType: if realm == 'client' then 'clientConCommand' else 'serverConCommand'
					:internalName
					displayName: name or internalName
					dataType: newDataType
					listSeparator: sep
					:choices
					:min
					:max
					:interval
					:logarithmic
				}

		if help
			table.insert saveTable, {
				elementType: 'text'
				displayName: help
			}

	tabsTable = {}
	for category in *categoriesOrder
		table.insert categoryPath, category
		tabData = categories[category]
		tabTable = {
			displayName: tabData.name or category
			icon: tabData.icon
			content: @_CreateCategoryData addon, categoryPath, tabData
		}
		table.remove categoryPath
		table.insert tabsTable, tabTable
	
	if categoriesUseTab
		table.insert saveTable, {
			type: "tabs"
			tabs: tabsTable
		}
	else
		for tabTable in *tabsTable
			table.insert saveTable, {
				type: "category"
				displayName: tabTable.displayName
				content: tabTable.content
			}
	saveTable

CCVCCM._CreateElementData = =>
	saveTable = {}
	for addon, addonTable in SortedPairs @api.data
		if next addonTable.registered or next addonTable.categories
			table.insert saveTable, {
				displayName: addonTable.name or addon
				icon: addonTable.icon
				content: @_CreateCategoryData addon, {}, addonTable
				static: true
			}
	saveTable

CCVCCM._RevertDataByRegistered = (registeredData, addon, categoryPath, name) =>
	{
		type: registeredType,
		data: {
			type: dataType, :default
		}
	} = registeredData
	switch registeredType
		when 'convar'
			conVar = GetConVar @_AssembleVarName name, addon, categoryPath
			if conVar then conVar\Revert!
		when 'addonvar'
			@SetVarValue addon, categoryPath, name, default

-- public portion
CCVCCM.Pointer = (addon, categoryPath, name) => CCVCCMPointer name, addon, categoryPath
CCVCCM.SetAddon = (addon = '', display, icon) =>
	data = @api.data
	data[addon] or= @_ConstructCategory!
	@api.addon = addon
	@api.categoryPath = {}

	if addon != ''
		data[addon].name or= display
		data[addon].icon or= icon

CCVCCM.PushCategory = (internal, display, tabs, icon) =>
	@_GetCategoryTable!.categoriesUseTab or= tabs

	table.insert @api.categoryPath, internal
	categoryTable = @_GetCategoryTable!

	categoryTable.name or= display
	categoryTable.icon or= display

CCVCCM.PopCategory = (num = 1) =>
	categoryPath = @api.categoryPath

	if num < 0 then categoryPath = {}
	else
		for i=1, num do table.remove categoryPath

CCVCCM.NextCategory = (internal, display, tabs) =>
	if next @api.categoryPath then @PopCategory!
	@PushCategory internal, display, tabs

CCVCCM.AddConVar = (internal, data) =>
	unless data.realm == 'client' and data.userInfo and SERVER
		@_RegisterIntoCategory internal, data, 'convar'
		@_GenerateConVar internal, data unless data.uiOnly
		CCVCCMPointer internal

CCVCCM.AddConCommand = (internal, data) =>
	unless data.realm == 'client' and SERVER
		@_RegisterIntoCategory internal, data, 'concommand'
		@_GenerateConCommand internal, data unless data.uiOnly
		CCVCCMPointer internal

CCVCCM.AddAddonVar = (internal, data) =>
	unless data.realm == 'client' and SERVER
		@_RegisterIntoCategory internal, data, 'addonvar'
		@_SetAddonVar internal, data.default
		CCVCCMPointer internal

CCVCCM.AddAddonCommand = (internal, data) =>
	unless data.realm == 'client' and SERVER
		@_RegisterIntoCategory internal, data, 'addoncommand'
		CCVCCMPointer internal

CCVCCM.GetVarValue = (addon, categoryPath, name) =>
	-- figure out the variable type
	registeredData = @_GetRegisteredData name, addon, categoryPath
	if registeredData
		{type: registeredType, data: {type: dataType, :sep}} = registeredData
		switch registeredType
			when 'convar'
				conVar = GetConVar @_AssembleVarName name, addon, categoryPath
				if conVar
					if sep
						values = string.Explode sep, conVar\GetString!
						switch dataType
							when 'bool'
								[tobool v for v in *values]
							when 'int'
								numbers = {}
								for v in *values
									if tonumber v
										table.insert numbers, math.floor v
									else
										table.insert numbers, 0
								numbers
							when 'float'
								[tonumber(v) or 0 for v in *values]
							else
								values
					else
						switch dataType
							when 'bool'
								conVar\GetBool!
							when 'int'
								conVar\GetInt!
							when 'float'
								conVar\GetFloat!
							else
								conVar\GetString!
			when 'addonvar'
				CCVCCM\_GetAddonVar name, addon, categoryPath

CCVCCM.SetVarValue = (addon, categoryPath, name, value) =>
	registeredData = @_GetRegisteredData name, addon, categoryPath
	if registeredData
		{
			type: registeredType,
			data: {
				type: dataType,
				:sep, :userInfo,
				:typeInfo, :realm,
				:notify, :flags
			}
		} = registeredData
		switch registeredType
			when 'convar'
				conVar = GetConVar @_AssembleVarName name, addon, categoryPath
				if conVar
					if sep
						local processedValues
						switch dataType
							when 'bool'
								processedValues = [(if v then '1' or '0') for v in *value]
							else
								processedValues = [tostring(v) for v in *value]
						conVar\SetString table.concat processedValues, ' '
						processedValues
					else
						switch dataType
							when 'bool'
								conVar\SetBool value
							when 'int'
								conVar\SetInt value
							when 'float'
								conVar\SetFloat value
							else
								conVar\SetString value
			when 'addonvar'
				oldValue = @_GetAddonVar name, addon, categoryPath
				if oldValue ~= value
					@_SetAddonVar name, value, addon, categoryPath
					if CLIENT and userInfo
						payload = {
							'u8', @ENUMS.NET.REP,
							's', addon,
							't', categoryPath,
							's', name
						}
						switch typeInfo.type
							when 'bool'
								table.insert payload, 'b'
								table.insert payload, value
							when 'number'
								table.insert payload, 'd'
								table.insert payload, value
							when 'string'
								table.insert payload, 's'
								table.insert payload, value
							else
								table.insert payload, 't'
								table.insert payload, value
						@Send payload
					if SERVER
						if notify
							varName = @_AssembleVarName name, addon, categoryPath
							PrintMessage HUD_PRINTTALK, "Server addon var \"#{varName}\" changed value to \"#{tostring(value)}\""
						if realm == 'shared'
							payload = {
								'u8', @ENUMS.NET.REP,
								's', addon,
								't', categoryPath,
								's', name
							}
							switch typeInfo.type
								when 'bool'
									table.insert payload, 'b'
									table.insert payload, value
								when 'number'
									table.insert payload, 'd'
									table.insert payload, value
								when 'string'
									table.insert payload, 's'
									table.insert payload, value
								else
									table.insert payload, 't'
									table.insert payload, value
							@Send payload

CCVCCM.RevertVarValue = (addon, categoryPath = {}, name) =>
	if name
		registeredData = @_GetRegisteredData name, addon, categoryPath
		if registeredData
			@_RevertDataByRegistered registeredData, addon, categoryPath, name
	else
		-- purging time
		categoryTable = @_GetCategoryTable addon, categoryPath
		for name, registeredData in pairs categoryTable.registered
			@_RevertDataByRegistered registeredData, addon, categoryPath, name

		for category, subCategoryTable in pairs categoryTable.categories
			table.insert categoryPath, category
			@RevertVarValue addon, categoryPath
			table.remove categoryPath

CCVCCM.RunCommand = (addon, categoryPath, name, value) =>
	registeredData = @_GetRegisteredData name, addon, categoryPath
	if registeredData
		{
			type: registeredType,
			data: {
				type: dataType,
				:sep, :func
			}
		} = registeredData
		switch registeredType
			when 'concommand'
				varName = @_AssembleVarName name, addon, categoryPath
				if sep
					if dataType == 'bool'
						value = [(if v then '1' or '0') for v in *value]
					else
						value = [tostring v for v in *value]
					RunConsoleCommand varName, unpack value
				else
					if dataType == 'bool'
						RunConsoleCommand varName, if value then '1' or '0'
					else
						RunConsoleCommand varName, tostring value
				
			when 'addoncommand'
				func NULL, {addon, categoryPath, name}, value


hook.Run 'CCVCCMRun'