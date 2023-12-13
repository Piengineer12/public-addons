-- there must be a better way than polluting the global table...
CCVCCM.ENUMS = {
	NET: {
		REP: 1
		EXEC: 2
		QUERY: 3
		INIT_REP: 4
	}
	COLORS: {
		GREEN: Color(0, 255, 0)
		AQUA: Color(0, 255, 255)
	}
}

CCVCCM.ShouldLog = => GetConVar('developer')\GetInt! > 0
CCVCCM.Log = (...) =>
	if @ShouldLog!
		displayTable = {}
		for i, element in ipairs {...}
			if istable element
				displayTable[i] = util.TableToJSON(element, true) or ''
			else
				displayTable[i] = tostring element
		texts = table.concat displayTable, '\t'
		MsgC @ENUMS.COLORS.AQUA, '[CCVCCM] ',
			string.format('%#.2f ', RealTime!),
			color_white, texts, '\n'

CCVCCM.StartNet = =>
	net.Start 'ccvccm'
CCVCCM.FinishNet = (recipients) =>
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
					net.WriteBool tobool sendUnit
				when 'u8'
					net.WriteUInt tonumber(sendUnit), 8
				when 'i16'
					net.WriteInt tonumber(sendUnit), 16
				when 'd'
					net.WriteDouble tonumber sendUnit
				when 's'
					net.WriteString tostring sendUnit
				when 't'
					net.WriteTable sendUnit
				-- when 'ts'
				-- 	-- sendUnit is a sequential table of strings
				-- 	net.WriteUInt #sendUnit, 16
				-- 	for str in *sendUnit do net.WriteString str
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
		-- when 'ts'
		-- 	[net.ReadString! for i=1, net.ReadUInt 16]

CCVCCM.ExtractPayloadFromNetMessage = (dataTypes) =>
	if istable dataTypes
		[@ExtractSingleFromNetMessage dataType for dataType in *dataTypes]
	else
		{@ExtractSingleFromNetMessage dataTypes}

CCVCCM.GetNetSingleAddonType = (fullName) =>
	registeredData = CCVCCM\_GetRegisteredData fullName
	if registeredData
		typeInfo = registeredData.data.typeInfo or {}
		switch typeInfo.type
			when 'bool'
				'b'
			-- when 'keybind'
			-- 	'i16'
			when 'number'
				'd'
			when 'keybind', 'string'
				's'
			else
				if typeInfo[1] then 't' else ''

CCVCCM.SQL = (query, params = {}) =>
	params = [sql.SQLStr(param) for param in *params]
	queryString = if next params then string.format query, unpack params else query
	result = sql.Query queryString
	if result == false
		err = sql.LastError!
		if err then error(err, 2)
	
	result

-- API
class CCVCCMPointer
	new: (fullName, ply = NULL) =>
		fullName = table.concat fullName, '_' if istable fullName
		@name = fullName

	Get: (ply) => CCVCCM\GetVarValue @name, ply
	Set: (value) => CCVCCM\SetVarValue @name, value
	Revert: => CCVCCM\RevertVarValue @name
	Run: (value, ply = NULL) => CCVCCM\RunCommand @name, ply, value

CCVCCM.api or= {
	layout: {
		['']: {
			name: 'Other'
			useTab: false
			layoutOrder: {}
			layoutData: {}
		}
	}
	aliases: {
		-- [string]: string
	}
	data: {
		-- [string]: registeredData
	}
	addonVars: {
		-- [string]: value
	}
	addon: ''
	categoryPath: {}
}

-- saving: CCVCCM.api.addonVars is stored into *.db files
-- 'ccvccm' table, one line of JSON per value
-- this provides lower risk of corruption than text files
CCVCCM\SQL 'CREATE TABLE IF NOT EXISTS "ccvccm" (
	"var" TEXT NOT NULL UNIQUE ON CONFLICT REPLACE,
	"value" TEXT NOT NULL
)'

loadedData = CCVCCM\SQL 'SELECT "value" FROM "ccvccm"'
if loadedData
	CCVCCM.api.addonVars = util.JSONToTable loadedData[1].value

CCVCCM.SaveData = =>
	@Log 'Saving data...'
	data = {k,v for k,v in pairs @api.addonVars}
	@SQL 'BEGIN'
	@SQL 'INSERT INTO "ccvccm" ("var", "value") VALUES (%s, %s)', {'', util.TableToJSON data}
	@SQL 'COMMIT'
	@Log 'Saved!'

timer.Create 'ccvccm_autosave', 120, 0, CCVCCM\SaveData

hook.Add 'ShutDown', 'CCVCCM', CCVCCM\SaveData

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
		generate: true
	}
	CCVCCM\AddConVar 'autosave_interval_client', {
		realm: 'client'
		name: 'Autosave Interval (Client)'
		help: 'Time between saves.'
		type: 'int'
		min: 30
		max: 3600
		generate: true
	}
	CCVCCM\AddConVar 'autosave_interval_server', {
		realm: 'server'
		name: 'Autosave Interval (Server)'
		help: 'Time between saves.'
		type: 'int'
		min: 30
		max: 3600
		generate: true
	}
	cvars.AddChangeCallback 'ccvccm_autosave_interval_client', ((conVarName, oldValue, newValue) ->
		timer.Adjust 'ccvccm_autosave', tonumber(newValue)
	), 'ccvccm_autosave'
	cvars.AddChangeCallback 'ccvccm_autosave_interval_server', ((conVarName, oldValue, newValue) ->
		timer.Adjust 'ccvccm_autosave', tonumber(newValue)
	), 'ccvccm_autosave'
	CCVCCM\PushCategory 'test', 'API Tests'
	CCVCCM\AddAddonVar 'addonvar', {
		realm: 'client'
		name: 'Test AddonVar'
		help: 'This is a test AddonVar to demonstrate the capabilities of CCVCCM\'s API.'
		default: {}
		typeInfo: {
			help: 'You can insert any number of items in this list. Here, every list item also comes with their own list.',
			{
				name: 'Boolean Value'
				type: 'bool'
			},
			{
				name: 'Edit List',
				help: 'This is a sub-list within a list item. Note that the numeric slider is logarithmic.',
				{
					name: 'Text Value'
					type: 'string'
				},
				{
					name: 'Boolean Value'
					type: 'bool'
				},
				{
					name: 'Numeric Value'
					type: 'number'
					min: 1
					max: 1e6
					interval: 1
					logarithmic: true
				}
			}
		}
		userInfo: true
		notify: true
		func: (value, fullName, ply) ->
			if CCVCCM\ShouldLog!
				print "#{fullName} on client:" if CLIENT
				print "#{fullName} from #{ply} on server:" if SERVER
				PrintTable value
	}
	CCVCCM\AddAddonCommand 'addoncommand', {
		realm: 'server'
		name: 'Test AddonCommand'
		help: 'This is a test AddonCommand to demonstrate the capabilities of CCVCCM\'s API.'
		func: (ply, value, fullName) ->
			print "#{ply} has invoked ccvccm_addoncommand!" if CCVCCM\ShouldLog!
	}
	return -- otherwise this will stop other hooks

-- internal portion
-- CCVCCM._ValidConVarTypes = {
-- 	bool: true,
-- 	keybind: true,
-- 	int: true,
-- 	float: true,
-- 	string: true
-- }
-- CCVCCM._ConVarTypeIsValid = (typ) => @_ValidConVarTypes[typ]

CCVCCM._ConstructCategory = (displayName, icon) =>
	{
		name: displayName
		icon: icon
		useTab: false
		layoutOrder: {}
		layoutData: {}
	}

CCVCCM._GenerateAndGetCategoryTable = (category, categoryName) =>
	currentTable = @_GetCategoryTable!
	newCategoryTable = currentTable.layoutData[category]

	unless newCategoryTable
		table.insert currentTable.layoutOrder, category
		newCategoryTable = @_ConstructCategory categoryName
		currentTable.layoutData[category] = newCategoryTable
	
	newCategoryTable

CCVCCM._GetCategoryTable = (addon = @api.addon, categoryPath = @api.categoryPath) =>
	currentTable = @api.layout[addon]
	for category in *categoryPath
		assert currentTable.layoutData[category], "failed to find #{table.concat categoryPath, '_'} under #{addon}!"
		currentTable = currentTable.layoutData[category]
	currentTable

CCVCCM._GetRegisteredData = (fullName) => @api.data[fullName]
CCVCCM._GetCheatsEnabled = => GetConVar('sv_cheats')\GetBool!

CCVCCM._RegisterIntoCategory = (name, registeredData, registeredType) =>
	category = @_GetCategoryTable!
	categoryFullName = @_AssembleVarName name
	realFullName = registeredData.fullName or categoryFullName
	table.insert category.layoutOrder, name unless @_GetRegisteredData categoryFullName
	
	registeredData.hide = {str, true for str in *string.Explode('%s+', registeredData.hide or '', true)}
	registeredData.flags = {str, true for str in *string.Explode('%s+', registeredData.flags or '', true)}
	@api.data[realFullName] = type: registeredType, data: registeredData
	@api.aliases[categoryFullName] = realFullName if categoryFullName ~= realFullName

CCVCCM._AssembleVarName = (name, addon = @api.addon, categoryPath = @api.categoryPath) =>
	nameFragments = {addon}
	for category in *categoryPath
		table.insert nameFragments, category if category ~= ""
	table.insert nameFragments, name
	table.concat nameFragments, '_'

CCVCCM._GenerateConVar = (name, data) =>
	realm = data.realm or 'server'
	if realm == 'shared' or realm == 'server' and SERVER or realm == 'client' and CLIENT
		{:help, :default, :hide, :flags, :min, :max, :clamp, :fullName} = data
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
		fullName or= @_AssembleVarName name
		CreateConVar fullName, default, conFlags, help, min, max

CCVCCM._GenerateConCommand = (name, data) =>
	realm = data.realm
	if realm == 'shared' or realm == 'server' and SERVER or realm == 'client' and CLIENT
		{:help, :func, :autoComplete, :choices, :hide, :flags, :fullName} = data
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

		fullName or= @_AssembleVarName name
		concommand.Add fullName, func, autoComplete, help, conFlags

CCVCCM._SetAddonVar = (fullName, value) =>
	-- internal method for setting the addonvar and do nothing else
	@api.addonVars[fullName] = value

CCVCCM._GetAddonVar = (fullName) =>
	-- internal method for getting the addonvar and do nothing else
	@api.addonVars[fullName]

CCVCCM._RevertDataByRegistered = (registeredData, fullName) =>
	{
		type: registeredType,
		data: {
			type: dataType, :default
		}
	} = registeredData
	switch registeredType
		when 'convar'
			conVar = GetConVar fullName
			conVar\Revert! if conVar
		when 'addonvar'
			@SetVarValue fullName, default

CCVCCM._CreateCategoryData = (addon, categoryPath, categoryTable) =>
	{:useTab, :layoutOrder, :layoutData} = categoryTable
	saveTable = {}
	tabsTable = {}
	for layoutKey in *layoutOrder
		if layoutData[layoutKey]
			table.insert categoryPath, layoutKey
			tabData = layoutData[layoutKey]
			tabTable = {
				displayName: tabData.name or layoutKey
				icon: tabData.icon
				content: @_CreateCategoryData addon, categoryPath, tabData
			}
			table.remove categoryPath
			table.insert tabsTable, tabTable
		else
			fullName = @_AssembleVarName layoutKey, addon, categoryPath
			fullName = @api.aliases[fullName] or fullName
			registeredData = @_GetRegisteredData fullName
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
			} = registeredData.data
			switch registeredData.type
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

					table.insert saveTable, {
						elementType: if realm == 'client' then 'clientConVar' else 'serverConVar'
						internalName: fullName
						displayName: name or fullName
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

					table.insert saveTable, {
						elementType: if realm == 'client' then 'clientConCommand' else 'serverConCommand'
						internalName: fullName
						displayName: name or fullName
						dataType: newDataType
						listSeparator: sep
						:choices
						:min
						:max
						:interval
						:logarithmic
					}
				
				when 'addonvar', 'addoncommand'
					table.insert saveTable, {
						elementType: 'addon',
						:fullName
					}

			if help
				table.insert saveTable, {
					elementType: 'text'
					displayName: help..'\n'
				}
	
	if next tabsTable
		if useTab
			table.insert saveTable, {
				elementType: 'tabs'
				tabs: tabsTable
			}
		else
			for tabTable in *tabsTable
				table.insert saveTable, {
					elementType: 'category'
					displayName: tabTable.displayName
					content: tabTable.content
				}
	saveTable

CCVCCM._CreateElementData = =>
	saveTable = {}
	@Log 'Layout stored by CCVCCM API:'
	PrintTable @api.layout if @ShouldLog!
	for addon, addonTable in SortedPairs @api.layout
		if next addonTable.layoutOrder
			table.insert saveTable, {
				displayName: addonTable.name or addon
				icon: addonTable.icon
				content: @_CreateCategoryData addon, {}, addonTable
				static: true
			}
	@Log 'Resulting save table:'
	PrintTable saveTable if @ShouldLog!
	saveTable

-- public portion
CCVCCM.Pointer = (fullName, ply) => CCVCCMPointer fullName, ply
CCVCCM.SetAddon = (addon = '', display, icon) =>
	@api.addon = addon
	@api.categoryPath = {}

	if addon != ''
		layout = @api.layout
		layout[addon] or= @_ConstructCategory display, icon

CCVCCM.PushCategory = (name, display, tabs, icon) =>
	@_GetCategoryTable!.useTab or= tabs

	@_GenerateAndGetCategoryTable name, display
	table.insert @api.categoryPath, name

CCVCCM.PopCategory = (num = 1) =>
	categoryPath = @api.categoryPath

	if num < 0 then categoryPath = {}
	else
		for i=1, num do table.remove categoryPath

CCVCCM.NextCategory = (name, display, tabs) =>
	if next @api.categoryPath then @PopCategory!
	@PushCategory name, display, tabs

CCVCCM.AddConVar = (name, registeredData) =>
	unless registeredData.realm == 'client' and not registeredData.userInfo and SERVER
		@_RegisterIntoCategory name, registeredData, 'convar'
		@_GenerateConVar name, registeredData if registeredData.generate
		CCVCCMPointer(registeredData.fullName or @_AssembleVarName name)

CCVCCM.AddConCommand = (name, registeredData) =>
	unless registeredData.realm == 'client' and SERVER
		@_RegisterIntoCategory name, registeredData, 'concommand'
		@_GenerateConCommand name, registeredData if registeredData.generate
		CCVCCMPointer(registeredData.fullName or @_AssembleVarName name)

CCVCCM.AddAddonVar = (name, registeredData) =>
	noValue = registeredData.userInfo and SERVER
	unless registeredData.realm == 'client' and not registeredData.userInfo and SERVER
		@_RegisterIntoCategory name, registeredData, 'addonvar'
		fullName = registeredData.fullName or @_AssembleVarName name

		-- FIXME: this save-first-ask-later approach might cause issues!
		unless noValue
			@_SetAddonVar fullName, registeredData.default if @_GetAddonVar(fullName) == nil or registeredData.flags.nosave
			registeredData.func @_GetAddonVar(fullName), fullName if registeredData.func
		CCVCCMPointer fullName

CCVCCM.AddAddonCommand = (name, registeredData) =>
	unless registeredData.realm == 'client' and SERVER
		@_RegisterIntoCategory name, registeredData, 'addoncommand'
		CCVCCMPointer(registeredData.fullName or @_AssembleVarName name)

CCVCCM.GetVarValue = (fullName, ply) =>
	-- figure out the variable type
	fullName = table.concat fullName, '_' if istable fullName
	fullName = @api.aliases[fullName] or fullName
	registeredData = @_GetRegisteredData fullName
	if registeredData
		{type: registeredType, data: {type: dataType, :sep, :userInfo}} = registeredData
		switch registeredType
			when 'convar'
				conVar = GetConVar fullName
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
								retValue = conVar\GetString!
								retValue == '#empty' and '' or retValue
			when 'addonvar'
				if userInfo and SERVER
					CCVCCM\_GetUserInfoVar fullName, ply
				else
					CCVCCM\_GetAddonVar fullName

CCVCCM.SetVarValue = (fullName, value) =>
	fullName = table.concat fullName, '_' if istable fullName
	fullName = @api.aliases[fullName] or fullName
	registeredData = @_GetRegisteredData fullName
	if registeredData
		{
			type: registeredType,
			data: {
				type: dataType,
				:sep, :userInfo,
				:typeInfo, :realm,
				:notify, :flags,
				:func
			}
		} = registeredData
		switch registeredType
			when 'convar'
				conVar = GetConVar fullName
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
				@_SetAddonVar fullName, value
				func value, fullName if func
				if CLIENT and userInfo
					payload = {
						'u8', @ENUMS.NET.REP,
						's', fullName
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
						PrintMessage HUD_PRINTTALK, "Server addon var '#{fullName}' changed to '#{value}'"
					if realm == 'shared'
						payload = {
							'u8', @ENUMS.NET.REP,
							's', fullName
						}
						table.insert payload, @GetNetSingleAddonType fullName
						table.insert payload, value
						@Send payload

CCVCCM.RevertVarValue = (fullName) =>
	fullName = table.concat fullName, '_' if istable fullName
	fullName = @api.aliases[fullName] or fullName
	registeredData = @_GetRegisteredData fullName
	if registeredData
		@_RevertDataByRegistered registeredData, fullName

CCVCCM.RevertByAddonAndCategory = (addon, ...) =>
	categoryPath = {...}
	categoryTable = @_GetCategoryTable addon, categoryPath
	for layoutKey in *categoryTable.layoutOrder
		if categoryTable.layoutData[layoutKey]
			table.insert categoryPath, layoutKey
			@RevertByAddonAndCategory addon, categoryPath
			table.remove categoryPath
		else
			fullName = @_AssembleVarName layoutKey, addon, categoryPath
			fullName = @api.aliases[fullName] or fullName
			registeredData = @_GetRegisteredData fullName
			@_RevertDataByRegistered registeredData, fullName

CCVCCM.RunCommand = (fullName, ply, value) =>
	fullName = table.concat fullName, '_' if istable fullName
	registeredData = @_GetRegisteredData fullName
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
				if sep
					if dataType == 'bool'
						value = [(if v then '1' or '0') for v in *value]
					else
						value = [tostring v for v in *value]
					RunConsoleCommand fullName, unpack value
				else
					if dataType == 'bool'
						RunConsoleCommand fullName, if value then '1' else '0'
					else
						RunConsoleCommand fullName, if value then tostring value else ''
				
			when 'addoncommand'
				func ply, value, fullName


hook.Run 'CCVCCMRun'