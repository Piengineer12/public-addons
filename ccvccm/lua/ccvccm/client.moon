-- menu bar at the top:
	-- clear, save and load layouts
	-- toggle layout editing mode
	-- add root tab
-- both users and addons can add tabs at root
	-- tabs added by addons cannot be modified and are always placed after all user tabs
-- within a user root tab, there will be options to copy, paste, rename or delete the tab
	-- only copy option is available within an addon tab
-- within a user root tab, there will be options to add several element types
	-- Client ConVar
		-- has sub-options for convar name, type, and other sub-options depending on convar type
			-- bool
			-- choice: choices
			-- number: min, max, logarithmic, decimals
			-- string
			-- string list
		-- has name and description sub-option
			-- convar name will disallow blocked convars
		-- has eyedropper button to automatically fill in fields, eyedropper is only escaped when LMB is pressed
		-- has confirm sub-option, which adds a button to actually make the change
		-- in layout editing mode, copy, paste, edit and delete buttons will be visible below each convar element
	-- Client ConCommand
		-- same sub-options as above and creates similar panels
			-- has another type: none
			-- if type is string, autocomplete will be invoked
		-- also adds a send button to actually call the concommand
	-- Server ConVar
		-- admin only
	-- Server ConCommand
		-- admin only
	-- Tabs
		-- adds a set of tabs, very similar concept to root tabs
	-- Categories
		-- adds a new category, with controls for deleting / renaming the category inside at the top of the category
	-- elements must be draggable

import ENUMS from CCVCCM
local ^

CreateClientConVar 'ccvccm_layout_editing', 1, true, false, 'Layout editing mode when CCVCCM is launched.', 0, 1

CCVCCM.GetUserInfoValues = =>
	results = {}
	for fullName, registeredData in pairs @api.data
		{:userInfo, :realm} = registeredData.data
		if userInfo and realm == 'client'
			table.insert results, {
				:fullName
				type: @GetNetSingleAddonType fullName
				value: @_GetAddonVar fullName
			}
			coroutine.yield false, results
	true, results

local avuiProcess
CCVCCM.StartAVUIProcess = =>
	avuiProcess = coroutine.create @\GetUserInfoValues
	timer.UnPause 'CCVCCM'

timer.Create 'CCVCCM', 0.015, 0, ->
	if avuiProcess
		ok, status, results = coroutine.resume avuiProcess
		-- if results has too many entries, send the data and empty the table
		if not ok
			error status, results
		elseif #results > 64 or status
			CCVCCM\StartNet!
			CCVCCM\AddPayloadToNetMessage {'u8', ENUMS.NET.INIT_REP, 'b', status, 'u8', #results}
			for i, result in ipairs results
				CCVCCM\AddPayloadToNetMessage {'s', result.fullName}
				CCVCCM\AddPayloadToNetMessage {result.type, result.value}
				results[i] = nil
			CCVCCM\FinishNet!

			avuiProcess = nil if status
	else
		-- don't waste processing power
		timer.Pause 'CCVCCM'

hook.Add 'InitPostEntity', 'CCVCCM', ->
	CCVCCM\StartAVUIProcess!

net.Receive 'ccvccm', (length) ->
	operation = CCVCCM\ExtractSingleFromNetMessage 'u8'
	switch operation
		when CCVCCM.ENUMS.NET.REP
			fullName = CCVCCM\ExtractSingleFromNetMessage 's'
			unitType = CCVCCM\GetNetSingleAddonType fullName
			value = CCVCCM\ExtractSingleFromNetMessage unitType
			CCVCCM\Log 'Received value of ', fullName, ':'
			PrintTable value if CCVCCM\ShouldLog!
			CCVCCM\SetVarValue fullName, value
		when CCVCCM.ENUMS.NET.QUERY
			cls = ManagerUI\GetInstance!
			if cls
				for i=1, CCVCCM\ExtractSingleFromNetMessage 'u8'
					fullName = CCVCCM\ExtractSingleFromNetMessage 's'
					registeredData = CCVCCM\_GetRegisteredData fullName
					if registeredData.type == 'addonvar' or registeredData.type == 'addoncommand'
						unitType = CCVCCM\GetNetSingleAddonType fullName
						value = CCVCCM\ExtractSingleFromNetMessage unitType
						cls\ReceiveServerVarQueryResult fullName, value
					else
						value = CCVCCM\ExtractSingleFromNetMessage 's'
						cls\ReceiveServerVarQueryResult name, value
		when CCVCCM.ENUMS.NET.INIT_REP
			for i=1, CCVCCM\ExtractSingleFromNetMessage 'u8'
				fullName = CCVCCM\ExtractSingleFromNetMessage 's'
				unitType = CCVCCM\GetNetSingleAddonType fullName
				value = CCVCCM\ExtractSingleFromNetMessage unitType
				CCVCCM\SetVarValue fullName, value

CCVCCM.CountTablesRecursive = (items, acc = {}, fillAccOnly = false) =>
	-- returns the number of tables within tab
	acc[items] = true
	for k, v in pairs items
		if istable(k) and not acc[k]
			@CountTablesRecursive k, acc, true
		if istable(v) and not acc[v]
			@CountTablesRecursive v, acc, true
	
	table.Count acc unless fillAccOnly

GetBitflagFromIndices = (...) ->
	result = 0

	for i in *{...}
		result = bit.bor result, bit.lshift(1, i)
	
	result

concommand.Add 'ccvccm_open', -> ManagerUI 0.5, 0.5

-- I don't want to add variables to Panels and risk accidentally overwriting something in the panel,
-- that has happened too many times by this point
class BasePanel
	@accumulator: 0

	Log: (...) => CCVCCM\Log @GetPanel!, ...
	
	SetPanel: (panel) => @panel = panel
	GetPanel: => @panel

	SortPanelsByPosition: (panels) =>
		table.sort panels, (a, b) ->
			ax, ay = a\LocalToScreen 0, 0
			bx, by = b\LocalToScreen 0, 0

			ax + ay < bx + by

	CreateButton: (parent, name, zPos, icon) =>
		with vgui.Create 'DButton', parent
			\SetText name
			if icon
				\SetImage "icon16/#{icon}.png"
				\SizeToContentsX 44
			else
				\SizeToContentsX 22
			\SetZPos zPos if zPos
	
	CreateLabel: (parent, label, zPos) =>
		with Label label, parent
			\SetWrap true
			\SetAutoStretchVertical true
			\SetZPos zPos
	
	WrapFunc: (tbl, funcname, post, callback) =>
		-- in an ideal world, I'd never have to override functions like this
		oldFunc = tbl[funcname]
		if oldFunc
			tbl[funcname] = (...) ->
				callback ... unless post
				oldFunc ...
				callback ... if post
		else
			tbl[funcname] = callback

	MakeDraggable: (panel) =>
		dragSystemName = string.format 'ccvccm_%u', BasePanel.accumulator
		panel\MakeDroppable dragSystemName
		BasePanel.accumulator += 1

class CustomNumSlider extends BasePanel
	clamp: false
	logarithmic: false
	negative: false
	interval: 0.01

	new: (parent) =>
		super!
		with panel = vgui.Create 'DNumSlider', parent
			-- "You really shouldn't be messing with the internals of these controls from outside"
			-- and? your code doesn't achieve what I need.
			.TextArea\SetNumeric false
			.Scratch.SetValue = (scratch, val) ->
				-- ConVarNumberThink calls this with a translated value
				val = tonumber val
				if val != nil
					val = @UntranslateValue val
					if val != scratch\GetFloatValue!
						scratch\SetFloatValue val
						scratch\OnValueChanged val
						scratch\UpdateConVar!
			.Scratch.GetTextValue = (scratch) ->
				decimals = @DetermineDecimals @interval
				string.format "%.#{decimals}f", @TranslateValue(scratch\GetFloatValue!)
			.TranslateSliderValues = (numSlider, x, y) ->
				numSlider\SetValue @TranslateValue numSlider.Scratch\GetMin! + x * numSlider.Scratch\GetRange!
				numSlider.Scratch\GetFraction!, y

			.SetValue = (numSlider, value) ->
				-- SetText calls this with a translated value
				value = tonumber value
				if value and numSlider\GetValue! != value
					numSlider.Scratch\SetValue value

					-- wouldn't numSlider.Scratch\SetValue already call numSlider\ValueChanged? what spaghetti monster were they avoiding?
					-- numSlider\ValueChanged numSlider\GetValue!
			.GetValue = (numSlider) -> @TranslateValue numSlider.Scratch\GetFloatValue!
			.ValueChanged = (numSlider, value) ->
				value = tonumber value
				--debug.Trace!
				if value
					if @clamp
						value = math.Clamp value, numSlider\GetMin!, numSlider\GetMax!
				
					numSlider.TextArea\SetValue numSlider.Scratch\GetTextValue!
					numSlider.Slider\SetSlideX numSlider.Scratch\GetFraction value
					numSlider\OnValueChanged @TranslateValue value
			.OnValueChanged = (numSlider, value) ->
				@callback value if @callback
			@SetPanel panel

	GetTextValue: => @GetPanel!.Scratch\GetTextValue!
	SetClamp: (clamp) => @clamp = clamp
	
	SetText: (text) =>
		panel = @GetPanel!
		if text
			panel\SetText text
		panel.Label\SetVisible text != nil
	
	SetMinMax: (...) =>
		@GetPanel!\SetMinMax ...
	
	SetInterval: (interval) =>
		@GetPanel!\SetDecimals -(math.log10 math.abs interval)
		@interval = interval
	
	SetLogarithmic: (logarithmic) =>
		-- more overrides probably also need to be applied to DNumberScratch, but that's really painful
		panel = @GetPanel!
		if @logarithmic != logarithmic
			if logarithmic
				@logarithmic = logarithmic
				@negative = panel\GetMin! < 0
				panel\SetMin @UntranslateValue panel\GetMin!
				panel\SetMax @UntranslateValue panel\GetMax!
			else
				panel\SetMin @TranslateValue panel\GetMin!
				panel\SetMax @TranslateValue panel\GetMax!
				@logarithmic = logarithmic

	SetCallback: (callback) => @callback = callback
	
	DetermineDecimals: (interval) =>
		-- take the nice-float string, then count the number of numbers after the decimal point
		-- this unfortunately limits the interval to a minimum of 0.000000001
		-- but surely no one needs THAT much precision... right?
		floatStr = string.format '%.9f', interval
		floatStr = string.TrimRight floatStr, '0'
		#(string.match floatStr, '%.(.*)')
	
	TranslateValue: (value) =>
		if @logarithmic
			if @negative
				value = -(10 ^ value)
			else
				value = 10 ^ value
		if @interval
			value = math.floor(value / @interval + 0.5) * @interval
		
		value
	
	UntranslateValue: (value) =>
		if @logarithmic
			return math.log10 math.abs value
		
		value

class CustomPanelContainer extends BasePanel
	stretchW: false
	stretchH: false
	vertical: false
	space: 0

	new: (parent) =>
		super!
		@stretchRatio = {}
		panel = with vgui.Create 'DPanel', parent
			.Paint = nil
		@SetPanel panel
		@WrapFunc panel, 'PerformLayout', false, (panel, w, h) ->
			children = panel\GetChildren!
			totalLength = if @vertical then h else w
			stretchOnLength = if @vertical then @stretchH else @stretchW
			stretchOnWidth = if @vertical then @stretchW else @stretchH

			local childOffset
			if stretchOnLength
				-- determine the space available for children
				childrenSpace = totalLength - @space * (#children - 1)
				-- calculate the total weighted length
				totalWeightedLength = 0
				for i=1, #children
					totalWeightedLength += @stretchRatio[i] or 1
				-- calculate the length of each child, then resize the child to that
				for i, child in ipairs children
					childWeightedLength = @stretchRatio[i] or 1
					childLength = childrenSpace * childWeightedLength / totalWeightedLength
					if @vertical
						child\SetTall childLength
					else
						child\SetWide childLength
				
				childOffset = 0
			else
				childrenLength = -@space
				for child in *children
					childLength = if @vertical then child\GetTall! else child\GetWide!
					childrenLength += childLength + @space
				childrenLength = math.max childrenLength, 0

				childOffset = (totalLength - childrenLength) / 2
			
			if stretchOnWidth
				for child in *children
					if @vertical
						child\SetWide w
					else
						child\SetTall h
			
			for child in *children
				if @vertical
					child\SetY childOffset
					child\CenterHorizontal!
					childOffset += child\GetTall!
				else
					child\SetX childOffset
					child\CenterVertical!
					childOffset += child\GetWide!

		@WrapFunc panel, 'OnChildAdded', false, (child) =>
			@InvalidateLayout!
	
	SetSpace: (space) =>
		@space = space
		@GetPanel!\InvalidateLayout!
	
	SetVertical: (vertical) =>
		@vertical = vertical
		@GetPanel!\InvalidateLayout!
	
	SetStretch: (stretchW = false, stretchH = false) =>
		@stretchW = stretchW
		@stretchH = stretchH
		@GetPanel!\InvalidateLayout!
	
	SetStretchRatio: (ratio) =>
		@stretchRatio = ratio
		@GetPanel!\InvalidateLayout!

class SavablePanel extends BasePanel
	-- this will hold all panel -> class associations
	-- we have to do this because panels can be dragged between ContentPanels
	@panelClasses: {}
	@lastCopied: ''

	RegisterAsSavable: => SavablePanel.panelClasses[@GetPanel!] = @
	UnregisterAsSavable: => SavablePanel.panelClasses[@GetPanel!] = nil
	UpdateSavables: =>
		for panel, cls in pairs SavablePanel.panelClasses
			SavablePanel.panelClasses[panel] = nil unless IsValid panel
	RemoveClassAndPanel: =>
		@UnregisterAsSavable!
		@GetPanel!\Remove!
	GetSavableClassFromPanel: (panel = @GetPanel!) => SavablePanel.panelClasses[panel]
	InitializeElementPanel: (parent, static) =>
		-- DSizeToContents can't be dragged!
		panel = with vgui.Create 'DPanel', parent
			\SetCursor 'sizeall' unless static
			\Dock TOP
			.Paint = nil
		@SetPanel panel
		@WrapFunc panel, 'PerformLayout', false, (w, h) =>
			@SizeToChildren false, true
			CCVCCM\Log @, 'PerformLayout'
		@RegisterAsSavable!
		panel

	PromptDelete: => Derma_Query 'Are you sure?', 'Delete', 'Yes', @\RemoveClassAndPanel, 'No'
	-- all instances of this class MUST implement @SaveToTable themselves
	SaveToClipboard: =>
		SavablePanel.lastCopied = util.TableToJSON @SaveToTable!
		SetClipboardText SavablePanel.lastCopied
		Derma_Message 'Element copied!', 'Copy', 'OK'
	GetLastCopiedPanel: => SavablePanel.lastCopied

class ContentPanel extends SavablePanel
	new: (contentType, window, static = false) =>
		super!
		@window = window
		panel = with vgui.Create 'DPanel'
			-- CenterVertical gets called in DPropertySheet\PerformLayout
			.CenterVertical = -> -- make it do nothing, it doesn't align to how I want it
		@SetPanel panel
		@RegisterAsSavable!
		@static = static
		
		@WrapFunc panel, 'PerformLayout', false, (w, h) =>
			@SizeToChildren false, true
			CCVCCM\Log @, 'PerformLayout'

		with vgui.Create 'DTextEntry', panel
			\SetZPos 2
			\Dock TOP
			\SetPlaceholderText 'Search...'
			.OnChange = (textEntry) -> @FilterElements string.lower textEntry\GetValue!
			.OnValueChange = .OnChange
		
		@items = with vgui.Create 'DIconLayout', panel
			\SetZPos 3
			\Dock TOP
			unless static
				\SetDropPos '28'
				\SetUseLiveDrag true
				\MakeDroppable 'ccvccm_content', true
		
		unless static
			@controlPanel = with vgui.Create 'DPanel', panel
				\SetTall 22
				\SetZPos 1
				\Dock TOP
				.Paint = nil

			with @CreateButton @controlPanel, 'Add Element', 1, 'add'
				\Dock LEFT
				.DoClick = @\PromptAddElement
			
			with @CreateButton @controlPanel, 'Paste Contents', 4, 'page_white_paste'
				\Dock LEFT
				.DoClick = ->
					pasteText = @GetLastCopiedPanel!
					if pasteText == ''
						Derma_StringRequest 'Paste', 'Enter panel data:', '', (pasteText) -> @LoadFromClipboard pasteText
					else
						@LoadFromClipboard pasteText

			if contentType == 'tab'
				with @CreateButton @controlPanel, 'Rename Tab', 2, 'pencil'
					\Dock LEFT
					.DoClick = @\PromptRenameTab
					
				with @CreateButton @controlPanel, 'Edit Icon', 3, 'image_edit'
					\Dock LEFT
					.DoClick = ->
						@addUI\Close! if IsValid @addUI
						tab, container = @GetTabAndParent!
						icon = if tab.Image then tab.Image\GetImage! else ''

						@addUI = EditIconUI 0.5, 0.5, icon, (newImage = '') ->
							if newImage != ''
								unless IsValid tab.Image
									tab.Image = vgui.Create 'DImage', tab
								
								with tab.Image
									\SetImage newImage
									\SizeToContents!
							elseif IsValid tab.Image
								tab.Image\Remove!
								tab.Image = nil
							
							tab\InvalidateLayout!
							container\InvalidateChildren!

				with @CreateButton @controlPanel, 'Delete Tab', 5, 'delete'
					\Dock LEFT
					.DoClick = @\PromptDeleteTab
	
	GetControlPanel: => @controlPanel
	GetStatic: => @static
	
	AddElement: (data = {}) =>
		ETYPES = AddElementUI.ELEMENT_TYPES

		local createdPanel
		switch data.elementType
			when ETYPES.TEXT
				classPanel = TextPanel @items, data, @window, @static
				createdPanel = classPanel\GetPanel!

			when ETYPES.CATEGORY
				classPanel = CategoryPanel @items, data, @window, @static
				createdPanel = classPanel\GetPanel!

			when ETYPES.TABS
				classPanel = TabPanel @items, data, @window, @static
				createdPanel = classPanel\GetPanel!

			when ETYPES.CLIENT_CCMD, ETYPES.CLIENT_CVAR, ETYPES.SERVER_CCMD, ETYPES.SERVER_CVAR
				classPanel = CCVCCPanel @items, data, @window, @static
				createdPanel = classPanel\GetPanel!
			
			when ETYPES.ADDON
				classPanel = CAVACPanel @items, data, @window, @static
				createdPanel = classPanel\GetPanel!
			
			else
				for k,v in pairs data do print k,v
				error "#{data.elementType} is not a valid element type!"
				
		createdPanel

	AddControlPanel: (panel) => @window\AddControlPanel panel
	
	GetTabAndParent: =>
		panel = @GetPanel!
		parent = panel\GetParent!
		for {:Tab, :Panel} in *parent\GetItems!
			return Tab, parent if Panel == panel
	
	PromptAddElement: =>
		@addUI\Close! if IsValid @addUI
		
		@addUI = with AddElementUI 0.5, 0.5
			\SetCallback (classData, ...) ->
				@AddElement ...

	PromptRenameTab: =>
		tab, container = @GetTabAndParent!
		Derma_StringRequest 'Rename', 'Enter new tab name:', tab\GetText!, (newName) ->
			tab\SetText newName
			container\InvalidateChildren!

	PromptDeleteTab: => Derma_Query 'Are you sure?', 'Delete', 'Yes', @\DeleteTab, 'No'
	FilterElements: (text) =>
		children = @items\GetChildren!

		for child in *children
			cls = @GetSavableClassFromPanel(child)
			cls\FilterElements text
	
	DeleteTab: =>
		@UnregisterAsSavable!
		
		tab, container = @GetTabAndParent!
		items = container\GetItems!
		
		-- frustratingly, DPropertySheet\CloseTab will error upon deleting the final tab
		if #items == 1
			container\Remove!
		else
			container\CloseTab tab, true
		
		@UpdateSavables!

	SaveToTable: =>
		children = @items\GetChildren!
		@SortPanelsByPosition children
		
		saveTable = {}
		for child in *children
			cls = @GetSavableClassFromPanel(child)
			table.insert saveTable, cls\SaveToTable!
			coroutine.yield!
		saveTable
	
	ReformatData: (data) =>
		ETYPES = AddElementUI.ELEMENT_TYPES
		DTYPES = AddElementUI.DATA_TYPES

		switch data.elementType
			when 'text'
				data.elementType = ETYPES.TEXT
			when 'category'
				data.elementType = ETYPES.CATEGORY
			when 'tabs'
				data.elementType = ETYPES.TABS
			when 'clientConVar'
				data.elementType = ETYPES.CLIENT_CVAR
			when 'clientConCommand'
				data.elementType = ETYPES.CLIENT_CCMD
			when 'serverConVar'
				data.elementType = ETYPES.SERVER_CVAR
			when 'serverConCommand'
				data.elementType = ETYPES.SERVER_CCMD
			when 'addon'
				data.elementType = ETYPES.ADDON
			else
				CCVCCM\Log "Couldn't translate unsupported element type #{data.elementType}!"
		
		switch data.dataType
			when 'none'
				data.dataType = DTYPES.NONE
			when 'bool'
				data.dataType = DTYPES.BOOL
			when 'choices'
				data.dataType = DTYPES.CHOICE
			when 'keybind'
				data.dataType = DTYPES.KEYBIND
			when 'number'
				data.dataType = DTYPES.NUMBER
			when 'string'
				data.dataType = DTYPES.STRING
			when 'choiceList'
				data.dataType = DTYPES.CHOICE_LIST
			when 'numberList'
				data.dataType = DTYPES.NUMBER_LIST
			when 'stringList'
				data.dataType = DTYPES.STRING_LIST

		data
	
	LoadFromTable: (contentsData = {}) =>
		for rawData in *contentsData
			-- I need to reparse some of the save data into the format returned by AddElementUI
			-- Most of it is the same, thankfully
			data = table.Copy rawData
			@ReformatData data
			@AddElement data
			coroutine.yield!

	LoadFromClipboard: (text) =>
		data = util.JSONToTable text
		if data
			@ReformatData data
			@AddElement data
		else
			Derma_Message 'Couldn\'t parse decoded element!', 'Paste Error', 'OK'

class TextPanel extends SavablePanel
	new: (parent, data, window, static) =>
		super!
		@window = window
		panel = @InitializeElementPanel parent, static
		
		with controlPanel = vgui.Create 'DPanel', panel
			\SetTall 22
			\SetZPos 1
			\DockMargin 0, 22, 0, 0
			\Dock TOP
			.Paint = nil --(w, h) => draw.RoundedBox 8, 0, 0, w, h, Color(191, 0, 0, 127)
			
			with @CreateButton controlPanel, 'Copy Element', 2, 'page_white_copy'
				\Dock LEFT
				.DoClick = -> @SaveToClipboard!
		
			unless static
				with @CreateButton controlPanel, 'Edit', 1, 'pencil'
					\Dock LEFT
					.DoClick = -> @PromptRenameDisplay!
				
				with @CreateButton controlPanel, 'Delete', 3, 'delete'
					\Dock LEFT
					.DoClick = -> @PromptDelete!
			
			window\AddControlPanel controlPanel
		
		-- this part won't be draggable - this is intentional
		labelParent = with vgui.Create 'DSizeToContents', panel
			\SetSizeX false
			\SetZPos 2
			\DockPadding 4, 4, 4, 4
			\Dock TOP
			--.Paint = (w, h) => draw.RoundedBox 8, 0, 0, w, h, Color(191, 0, 0, 127)
		
		@label = with @CreateLabel labelParent, (data.displayName or '')
			\Dock TOP
			\SetDark true
			\SetMouseInputEnabled true
			unless static
				.DoDoubleClick = -> @PromptRenameDisplay! if @window\GetControlPanelVisibility!
	
	PromptRenameDisplay: =>
		MultilineTextUI 0.5, 0.5, @label\GetText!, (newName) ->
			@label\SetText newName
	
	FilterElements: (text) =>
		with @GetPanel!
			\SetVisible tobool string.find string.lower(@label\GetText!), text, 1, true
			\GetParent!\InvalidateLayout!
			\GetParent!\GetParent!\InvalidateLayout!
	
	SaveToTable: => {
		elementType: "text"
        displayName: @label\GetText!
	}

class CategoryPanel extends SavablePanel
	new: (parent, data, window, static) =>
		super!
		@window = window
		panel = @InitializeElementPanel parent, static
		
		with controlPanel = vgui.Create 'DPanel', panel
			\SetTall 22
			\SetZPos 1
			\DockMargin 0, 22, 0, 0
			\Dock TOP
			.Paint = nil --(w, h) => draw.RoundedBox 8, 0, 0, w, h, Color(191, 0, 0, 127)
			
			with @CreateButton controlPanel, 'Copy Element', 2, 'page_white_copy'
				\Dock LEFT
				.DoClick = -> @SaveToClipboard!
		
			unless static
				with @CreateButton controlPanel, 'Rename', 1, 'pencil'
					\Dock LEFT
					.DoClick = -> @PromptRenameDisplay!
				
				with @CreateButton controlPanel, 'Delete', 3, 'delete'
					\Dock LEFT
					.DoClick = -> @PromptDelete!
			
			window\AddControlPanel controlPanel
		
		hostPanel = with vgui.Create 'DSizeToContents', panel
			\SetSizeX false
			\SetZPos 2
			\DockPadding 4, 0, 4, 0
			\Dock TOP
		
		@contentPanel = ContentPanel 'category', window, static
		@category = with vgui.Create 'DCollapsibleCategory', hostPanel
			\SetCursor 'sizeall'
			\SetLabel data.displayName or 'New Category'
			\SetContents @contentPanel\GetPanel!
			\SetList parent
			\SetExpanded false
			\Dock TOP
			unless static
				.Header.DoDoubleClick = -> @PromptRenameDisplay! if window\GetControlPanelVisibility!
				window\AddControlPanel @contentPanel\GetControlPanel!
		@WrapFunc @category, 'OnRemove', false, -> @UpdateSavables!
		@contentPanel\LoadFromTable data.content
	
	PromptRenameDisplay: =>
		categoryHeader = @category.Header
		Derma_StringRequest 'Rename', 'Enter new category name:', categoryHeader\GetText!, (newName) ->
			categoryHeader\SetText newName
	
	FilterElements: (text) =>
		@category\DoExpansion true
		@contentPanel\FilterElements text
	
	SaveToTable: => {
		elementType: "category"
		displayName: @category.Header\GetText!
        content: @contentPanel\SaveToTable!
	}

class TabPanel extends SavablePanel
	new: (parent, data, window, static) =>
		super!
		@window = window
		panel = @InitializeElementPanel parent, static
		@static = static

		with controlPanel = vgui.Create 'DPanel', panel
			\SetTall 22
			\SetZPos 1
			\DockMargin 0, 22, 0, 0
			\Dock TOP
			.Paint = nil --(w, h) => draw.RoundedBox 8, 0, 0, w, h, Color(191, 0, 0, 127)
			
			with @CreateButton controlPanel, 'Copy Element', 2, 'page_white_copy'
				\Dock LEFT
				.DoClick = -> @SaveToClipboard!
			
			unless static
				with @CreateButton controlPanel, 'Add Tab', 1, 'add'
					\Dock LEFT
					.DoClick = -> @AddTab!
			
			window\AddControlPanel controlPanel
		
		@sheet = with vgui.Create 'DPropertySheet', panel
			\SetZPos 2
			\Dock TOP
			.tabScroller\SetUseLiveDrag true
			-- I don't want tabs to be moved to an entirely different tab panel, as that breaks so many things!
			@MakeDraggable .tabScroller
		@WrapFunc @sheet, 'OnRemove', false, -> @RemoveClassAndPanel!
		@WrapFunc @sheet, 'PerformLayout', true, (w, h) =>
			padding = @GetPadding!
			panel = @GetActiveTab!\GetPanel!
			
			@SetTall panel\GetTall! + 20 + padding * 2
			CCVCCM\Log @, 'PerformLayout'
		
		if data.tabs
			for tabData in *data.tabs
				@AddTab tabData.displayName, tabData.icon, tabData.content
		else
			@AddTab!
	
	AddTab: (displayName = 'New Tab', icon, content) =>
		contentPanel = ContentPanel 'tab', @window, @static

		{Tab: tab} = @sheet\AddSheet displayName, contentPanel\GetPanel!, icon, false, true
		unless @static
			tab.DoDoubleClick = -> contentPanel\PromptRenameTab! if @window\GetControlPanelVisibility!
			@window\AddControlPanel contentPanel\GetControlPanel!
		contentPanel\LoadFromTable content
	
	FilterElements: (text) =>
		for {Panel: panel} in *@sheet\GetItems!
			@GetSavableClassFromPanel(panel)\FilterElements text
	
	SaveToTable: =>
		generalSaveTable = {elementType: 'tabs'}

		-- first, get all the tabs and sort by position
		tabs = @sheet.tabScroller\GetCanvas!\GetChildren!
		@SortPanelsByPosition tabs

		-- now assemble [tab] = class
		tabContentClasses = {tab, @GetSavableClassFromPanel(panel) for {Tab: tab, Panel: panel} in *@sheet\GetItems!}
		
		-- finally,
		saveTable = {}
		for i, tab in ipairs tabs
			tabSaveTable = {
				displayName: tab\GetText!
				content: tabContentClasses[tab]\SaveToTable!
			}
			tabSaveTable.icon = tab.Image\GetImage! if tab.Image

			saveTable[i] = tabSaveTable
			coroutine.yield!
		
		generalSaveTable.tabs = saveTable
		generalSaveTable

class CAVACPanel extends SavablePanel
	-- this element must be savable as this element can be copied and pasted into custom tabs
	-- it just can't be edited
	new: (parent, data, window, static) =>
		super!
		@data = data
		@window = window
		@InitializeElementPanel parent, static
		panel = @GetPanel!

		with controlPanel = vgui.Create 'DPanel', panel
			\SetTall 22
			\SetZPos 1
			\DockMargin 0, 22, 0, 0
			\Dock TOP
			.Paint = nil --(w, h) => draw.RoundedBox 8, 0, 0, w, h, Color(191, 0, 0, 127)
			
			with @CreateButton controlPanel, 'Copy Element', nil, 'page_white_copy'
				\Dock LEFT
				.DoClick = -> @SaveToClipboard!

			unless static
				with @CreateButton controlPanel, 'Delete', 3, 'delete'
					\Dock LEFT
					.DoClick = -> @PromptDelete!
			
			@window\AddControlPanel controlPanel

		-- unlike CCVCCPanels, the variables displayName, dataType, elementType and even manual
		-- is derived from data returned by CCVCCM\_GetRegisteredData
		{:arguments, :fullName} = data
		registeredData = CCVCCM\_GetRegisteredData fullName
		CCVCCM\Log "Creating CAVACPanel from \"#{fullName}\" data:"
		unless registeredData
			CCVCCM\Log 'Failed to get registered data!'
		
			-- make a text panel instead
			labelParent = with vgui.Create 'DSizeToContents', panel
				\SetSizeX false
				\SetZPos 2
				\DockPadding 4, 4, 4, 4
				\Dock TOP
			
			with @CreateLabel labelParent, "Could not find control \"#{fullName}\", please check your addons!"
				\Dock TOP
				\SetDark true
			
			return
		PrintTable registeredData if CCVCCM\ShouldLog!
		{
			type: apiType,
			data: {
				:realm,
				name: displayName,
				:default,
				:manual,
				:typeInfo
			}
		} = registeredData

		-- ListInputUI requires data to be in terms of DTYPES
		DTYPES = AddElementUI.DATA_TYPES
		dataType = @TranslateTypeInfo typeInfo
		@Log 'TranslateTypeInfo'
		PrintTable dataType if CCVCCM\ShouldLog!
		
		-- this isn't applicable
		-- ETYPES = AddElementUI.ELEMENT_TYPES

		isClient = realm == 'client'
		isVar = apiType == 'addonvar'
		@arguments = if not isVar and arguments ~= nil then arguments else CCVCCM\_GetAddonVar fullName
		manual or= not isVar

		if manual
			local buttonText
			if isVar
				buttonText = 'Apply Changes'
			elseif dataType.dataType == DTYPES.NONE
				buttonText = displayName
			else
				buttonText = 'Run ConCommand'
			with @CreateButton panel, buttonText, 3
				\Dock TOP
				.DoClick = @\UpdateAddonVar

		switch dataType.dataType
			when DTYPES.BOOL
				hostPanel = with vgui.Create 'DSizeToContents', panel
					\SetSizeX false
					\SetZPos 2
					\DockPadding 4, 0, 0, 0
					\Dock TOP

				@rawPanel = with vgui.Create 'DCheckBoxLabel', hostPanel
					\SetValue @arguments
					\Dock TOP
					\SetText displayName
					\SetDark true
					.OnChange = (panel, checked) ->
						@SetArgs checked
						@UpdateAddonVar! unless manual

			when DTYPES.CHOICE
				hostPanelClass = with CustomPanelContainer panel
					\SetStretch true, true
					\SetStretchRatio {1, 1.4}
				hostPanel = with hostPanelClass\GetPanel!
					\SetTall 22
					\SetZPos 2
					\Dock TOP
					.Paint = nil
				
				with @CreateLabel hostPanel, displayName
					\SetTextInset 4, 0
					\SetContentAlignment 4
					\SetDark true

				@rawPanel = with vgui.Create 'DComboBox', hostPanel
					.OnSelect = (panel, index, value, selectedData) ->
						returnVal = if selectedData ~= nil then selectedData else value
						@SetArgs returnVal
						@UpdateAddonVar! unless manual
				
				for i, choicesInfo in ipairs dataType.choices
					{k, v} = choicesInfo
					@rawPanel\AddChoice k, v, @arguments == v

			when DTYPES.KEYBIND
				hostPanelClass = with CustomPanelContainer panel
					\SetStretch true, true
					\SetStretchRatio {1, 1.4}
				hostPanel = with hostPanelClass\GetPanel!
					\SetTall 22
					\SetZPos 2
					\Dock TOP
					.Paint = nil
				
				with @CreateLabel hostPanel, displayName
					\SetTextInset 4, 0
					\SetContentAlignment 4
					\SetDark true

				@rawPanel = with vgui.Create 'DBinder', hostPanel
					\SetSelectedNumber input.GetKeyCode (@arguments or '')
					.OnChange = (panel, value) ->
						@SetArgs input.GetKeyName value
						@UpdateAddonVar! unless manual
			
			when DTYPES.NUMBER
				with CustomNumSlider panel
					\SetText displayName
					\SetMinMax tonumber(dataType.min), tonumber(dataType.max)
					\SetInterval tonumber dataType.interval if dataType.interval
					\SetLogarithmic dataType.logarithmic
					\SetCallback (classData, value) ->
						@SetArgs value
						@UpdateAddonVar! unless manual
						
					@rawPanel = \GetPanel!
					with @rawPanel
						\SetValue @arguments
						\SetDark true
						.Label\SetTextInset 4, 0
						\SetZPos 2
						\Dock TOP
			
			when DTYPES.STRING
				hostPanelClass = with CustomPanelContainer panel
					\SetStretch true, true
					\SetStretchRatio {1, 1.4}
				hostPanel = with hostPanelClass\GetPanel!
					\SetTall 22
					\SetZPos 2
					\Dock TOP
					.Paint = nil
				
				with @CreateLabel hostPanel, displayName
					\SetTextInset 4, 0
					\SetContentAlignment 4
					\SetDark true

				@rawPanel = with vgui.Create 'DTextEntry', hostPanel
					\SetValue @arguments
					.OnChange = (textEntry) ->
						@SetArgs textEntry\GetValue!
						@UpdateAddonVar! unless manual
					.OnValueChange = .OnChange
			
			when DTYPES.COMPLEX_LIST
				hostPanelClass = with CustomPanelContainer panel
					\SetStretch true, true
					\SetStretchRatio {1, 1.4}
				hostPanel = with hostPanelClass\GetPanel!
					\SetTall 22
					\SetZPos 2
					\Dock TOP
					.Paint = nil
				
				with @CreateLabel hostPanel, displayName
					\SetTextInset 4, 0
					\SetContentAlignment 4
					\SetDark true
				
				with @CreateButton hostPanel, dataType.name or 'Edit List', 2
					.DoClick = ->
						listInputUI = ListInputUI 0.5, 0.5, dataType, @arguments
						listInputUI\SetCallback (classData, values) ->
							@SetArgs values
							@UpdateAddonVar! unless manual
		
		if (realm or 'server') == 'server'
			-- ask ManagerUI to poll the server
			@window\AddServerVarQueryRequest fullName, @

	SetArgs: (arguments) => @arguments = arguments
	SendToServer: =>
		fullName = @data.fullName
		payload = {
			'u8', CCVCCM.ENUMS.NET.EXEC,
			'b', true,
			's', fullName
		}
		table.insert payload, CCVCCM\GetNetSingleAddonType fullName
		table.insert payload, @arguments
		CCVCCM\Send payload
	UpdateAddonVar: =>
		{:elementType, :fullName} = @data
		registeredData = CCVCCM\_GetRegisteredData fullName
		if registeredData
			{type: apiType, data: {:realm, :flags, :func}} = registeredData
			if flags
				if flags.cheat and not CCVCCM\_GetCheatsEnabled!
					return Derma_Message 'sv_cheats must be enabled!', 'Runtime Error', 'OK'
				elseif flags.sp and not game.SinglePlayer!
					return Derma_Message 'Game must be singleplayer!', 'Runtime Error', 'OK'
			
			if realm == 'client'
				if apiType == 'addonvar'
					CCVCCM\SetVarValue fullName, @arguments
				else
					CCVCCM\RunCommand fullName, LocalPlayer!, @arguments
			else @SendToServer!
	
	TranslateTypeInfo: (component = {}, parentTable) =>
		DTYPES = AddElementUI.DATA_TYPES
		{:name, :help, type: compType, :choices, :min, :max, :interval, :logarithmic} = component

		if parentTable
			parentTable.names or= {}
			table.insert parentTable.names, name

		dataType = {
			name: name
			header: help
			:choices
			:min
			:max
			:interval
			:logarithmic
		}

		if choices
			dataType.dataType = DTYPES.CHOICE
		else
			switch compType
				when 'bool'
					dataType.dataType = DTYPES.BOOL
				when 'keybind'
					dataType.dataType = DTYPES.KEYBIND
				when 'number'
					dataType.dataType = DTYPES.NUMBER
				when 'string'
					dataType.dataType = DTYPES.STRING
				else
					if component[1]
						dataType.dataType = DTYPES.COMPLEX_LIST
						dataType.types = [@TranslateTypeInfo(v, dataType) for v in *component]
					else
						dataType.dataType = DTYPES.NONE

		dataType
	
	FilterElements: (text) =>
		{:fullName} = @data
		{data: {name: displayName}} = CCVCCM\_GetRegisteredData fullName
		haystack = string.lower fullName..'\n'..displayName
		with @GetPanel!
			\SetVisible tobool string.find haystack, text, 1, true
			\GetParent!\InvalidateLayout!
			\GetParent!\GetParent!\InvalidateLayout!
	
	SaveToTable: =>
		{
			fullName: @data.fullName
			elementType: 'addon'
			arguments: @arguments
		}
	
	SetValue: (value) =>
		@arguments = value
		if IsValid @rawPanel
			if @rawPanel.SetSelectedNumber
				@rawPanel\SetSelectedNumber input.GetKeyCode value
			else
				@rawPanel\SetValue value
			if @rawPanel.Data
				-- SetValue will not set the correct display name for DComboBox
				for choiceIndex, data in pairs @rawPanel.Data
					if data == value
						@rawPanel\ChooseOptionID choiceIndex
						break

class CCVCCPanel extends SavablePanel
	arguments: ''

	new: (parent, data, window, static) =>
		super!
		@data = data
		if data.arguments
			@arguments = data.arguments
		@window = window
		@InitializeElementPanel parent, static
		@static = static
		
		@PopulatePanel!
	
	SetArgs: (arguments) => @arguments = arguments
	SendToServer: => CCVCCM\Send {'u8', CCVCCM.ENUMS.NET.EXEC, 'b', false, 's', @data.internalName..' '..@arguments}

	PopulatePanel: =>
		data = @data
		panel = @GetPanel!
		{:displayName, :dataType, :elementType, :internalName, :manual} = data
		DTYPES = AddElementUI.DATA_TYPES
		ETYPES = AddElementUI.ELEMENT_TYPES

		isClient = elementType == ETYPES.CLIENT_CCMD or elementType == ETYPES.CLIENT_CVAR
		isVar = elementType == ETYPES.CLIENT_CVAR or elementType == ETYPES.SERVER_CVAR
		manual or= not isVar

		if isVar and not isClient and GetConVar internalName
			@SetArgs GetConVar(internalName)\GetString!

		with controlPanel = vgui.Create 'DPanel', panel
			\SetTall 22
			\SetZPos 1
			\DockMargin 0, 22, 0, 0
			\Dock TOP
			.Paint = nil --(w, h) => draw.RoundedBox 8, 0, 0, w, h, Color(191, 0, 0, 127)
			
			with @CreateButton controlPanel, 'Copy Element', 2, 'page_white_copy'
				\Dock LEFT
				.DoClick = -> @SaveToClipboard!

			unless @static
				with @CreateButton controlPanel, 'Edit', 1, 'pencil'
					\Dock LEFT
					.DoClick = -> @PromptEditPanel!
				
				with @CreateButton controlPanel, 'Delete', 3, 'delete'
					\Dock LEFT
					.DoClick = -> @PromptDelete!
			
			@window\AddControlPanel controlPanel
		
		clickFunc = ->
			if isClient
				LocalPlayer!\ConCommand internalName..' '..@arguments
			else @SendToServer!

		if manual
			local buttonText
			if isVar
				buttonText = 'Apply Changes'
			elseif dataType == DTYPES.NONE
				buttonText = displayName
			else
				buttonText = 'Run ConCommand'
			with @CreateButton panel, buttonText, 3
				\Dock TOP
				.DoClick = clickFunc
		
		switch dataType
			when DTYPES.BOOL
				hostPanel = with vgui.Create 'DSizeToContents', panel
					\SetSizeX false
					\SetZPos 2
					\DockPadding 4, 0, 0, 0
					\Dock TOP

				@rawPanel = with vgui.Create 'DCheckBoxLabel', hostPanel
					\SetValue @arguments
					\Dock TOP
					\SetText displayName
					\SetDark true
					.OnChange = (panel, checked) ->
						@SetArgs checked and '1' or '0'
						@SendToServer! unless isClient or manual
					if elementType == ETYPES.CLIENT_CVAR and not manual
						\SetConVar internalName

			when DTYPES.CHOICE
				hostPanelClass = with CustomPanelContainer panel
					\SetStretch true, true
					\SetStretchRatio {1, 1.4}
				hostPanel = with hostPanelClass\GetPanel!
					\SetTall 22
					\SetZPos 2
					\Dock TOP
					.Paint = nil
				
				with @CreateLabel hostPanel, displayName
					\SetTextInset 4, 0
					\SetContentAlignment 4
					\SetDark true

				@rawPanel = with vgui.Create 'DComboBox', hostPanel
					.OnSelect = (panel, index, value, selectedData) ->
						returnVal = tostring(if selectedData ~= nil then selectedData else value)
						@SetArgs returnVal
						if panel.m_strConVar
							LocalPlayer!\ConCommand panel.m_strConVar..' '..returnVal
						elseif not (isClient or manual) then @SendToServer!
					if elementType == ETYPES.CLIENT_CVAR and not manual
						\SetConVar internalName
				
				for i, choicesInfo in ipairs data.choices
					{k, v} = choicesInfo
					@rawPanel\AddChoice k, v, @arguments == v
			
			when DTYPES.KEYBIND
				hostPanelClass = with CustomPanelContainer panel
					\SetStretch true, true
					\SetStretchRatio {1, 1.4}
				hostPanel = with hostPanelClass\GetPanel!
					\SetTall 22
					\SetZPos 2
					\Dock TOP
					.Paint = nil
				
				with @CreateLabel hostPanel, displayName
					\SetTextInset 4, 0
					\SetContentAlignment 4
					\SetDark true

				@rawPanel = with vgui.Create 'DBinder', hostPanel
					\SetSelectedNumber input.GetKeyCode @arguments
					.OnChange = (panel, value) ->
						@SetArgs input.GetKeyName value
						@SendToServer! unless isClient or manual
					if elementType == ETYPES.CLIENT_CVAR and not manual
						\SetConVar internalName

			when DTYPES.NUMBER
				with CustomNumSlider panel
					\SetText displayName
					\SetMinMax tonumber(data.min), tonumber(data.max)
					\SetInterval tonumber data.interval if data.interval
					\SetLogarithmic data.logarithmic
					\SetCallback (classData, value) ->
						@SetArgs classData\GetTextValue!
						@SendToServer! unless isClient or manual
						
					@rawPanel = \GetPanel!
					with @rawPanel
						\SetValue @arguments
						\SetDark true
						.Label\SetTextInset 4, 0
						\SetZPos 2
						\Dock TOP
						if elementType == ETYPES.CLIENT_CVAR and not manual
							\SetConVar internalName
					
			when DTYPES.STRING
				hostPanelClass = with CustomPanelContainer panel
					\SetStretch true, true
					\SetStretchRatio {1, 1.4}
				hostPanel = with hostPanelClass\GetPanel!
					\SetTall 22
					\SetZPos 2
					\Dock TOP
					.Paint = nil
				
				with @CreateLabel hostPanel, displayName
					\SetTextInset 4, 0
					\SetContentAlignment 4
					\SetDark true

				@rawPanel = with vgui.Create 'DTextEntry', hostPanel
					\SetValue @arguments
					.GetAutoComplete = (value) =>
						possibilities = concommand.AutoComplete internalName, value
						if possibilities
							startPos = #internalName+2
							[string.sub item, startPos for item in *possibilities]
					.OnChange = (textEntry) ->
						@SetArgs textEntry\GetValue!
						@SendToServer! unless isClient or manual
					.OnValueChange = .OnChange
					if elementType == ETYPES.CLIENT_CVAR and not manual
						\SetConVar internalName
			
			when DTYPES.CHOICE_LIST, DTYPES.NUMBER_LIST, DTYPES.STRING_LIST
				hostPanelClass = with CustomPanelContainer panel
					\SetStretch true, true
					\SetStretchRatio {1, 1.4}
				hostPanel = with hostPanelClass\GetPanel!
					\SetTall 22
					\SetZPos 2
					\Dock TOP
					.Paint = nil
				
				with @CreateLabel hostPanel, displayName
					\SetTextInset 4, 0
					\SetContentAlignment 4
					\SetDark true
				
				listSeparator = data.listSeparator or ' '
				with @CreateButton hostPanel, 'Edit List', 2
					.DoClick = ->
						conVarValue = @arguments
						if elementType == ETYPES.CLIENT_CVAR and not manual
							conVar = GetConVar internalName
							conVarValue = conVar\GetString! if conVar
						
						listValues = [{str} for str in *string.Explode(listSeparator, conVarValue)]

						local individualDataType
						switch dataType
							when DTYPES.CHOICE_LIST
								individualDataType = DTYPES.CHOICE
							when DTYPES.NUMBER_LIST
								individualDataType = DTYPES.NUMBER
							when DTYPES.STRING_LIST
								individualDataType = DTYPES.STRING
						
						listInputUI = ListInputUI 0.5, 0.5, {
							header: 'Enter values:'
							types: {
								{
									dataType: individualDataType
									choices: data.choices
									min: data.min
									max: data.max
									interval: data.interval
									logarithmic: data.logarithmic
								}
							}
						}, listValues
						
						listInputUI\SetCallback (classData, values) ->
							flattenedValues = [tostring value[1] for value in *values]
							strValue = table.concat(flattenedValues, listSeparator)
							@SetArgs strValue
							
							if elementType == ETYPES.CLIENT_CVAR and not manual
								LocalPlayer!\ConCommand internalName..' '..strValue
							elseif not (isClient or manual) then @SendToServer!
		
		if elementType == ETYPES.SERVER_CVAR and not GetConVar internalName
			-- ask ManagerUI to poll the server
			@window\AddServerVarQueryRequest internalName, @
	
	PromptEditPanel: =>
		with AddElementUI 0.5, 0.5, @data
			\SetCallback (classData, newData) ->
				@data = newData
				-- clear ourselves out and regenerate
				for panel in *@GetPanel!\GetChildren! do panel\Remove!
				@arguments = ''
				@PopulatePanel!
	
	FilterElements: (text) =>
		haystack = string.lower @data.internalName..'\n'..@data.displayName
		with @GetPanel!
			\SetVisible tobool string.find haystack, text, 1, true
			\GetParent!\InvalidateLayout!
			\GetParent!\GetParent!\InvalidateLayout!
	
	SaveToTable: =>
		data = @data
		saveTable = {
			internalName: data.internalName
			displayName: data.displayName
			arguments: @arguments
			manual: data.manual
		}
		
		local elementTypeStr
		ETYPES = AddElementUI.ELEMENT_TYPES
		switch data.elementType
			when ETYPES.CLIENT_CVAR
				elementTypeStr = 'clientConVar'
			when ETYPES.CLIENT_CCMD
				elementTypeStr = 'clientConCommand'
			when ETYPES.SERVER_CVAR
				elementTypeStr = 'serverConVar'
			when ETYPES.SERVER_CCMD
				elementTypeStr = 'serverConCommand'
			else
				error "#{data.elementType} is not a valid element type!"
		saveTable.elementType = elementTypeStr
		
		local dataTypeStr
		DTYPES = AddElementUI.DATA_TYPES
		switch data.dataType
			when DTYPES.NONE
				dataTypeStr = 'none'
			when DTYPES.BOOL
				dataTypeStr = 'bool'
			when DTYPES.CHOICE
				dataTypeStr = 'choice'
				saveTable.choices = data.choices
			when DTYPES.KEYBIND
				dataTypeStr = 'keybind'
			when DTYPES.NUMBER
				dataTypeStr = 'number'
				with saveTable
					.min = data.min
					.max = data.max
					.interval = data.interval
					.logarithmic = data.logarithmic
			when DTYPES.STRING
				dataTypeStr = 'string'
			when DTYPES.CHOICE_LIST
				data.dataType = 'choiceList'
			when DTYPES.NUMBER_LIST
				data.dataType = 'numberList'
			when DTYPES.STRING_LIST
				dataTypeStr = 'stringList'
			else
				CCVCCM\Log "Failed to serialize data type #{data.dataType}!"
		saveTable.dataType = dataTypeStr
		saveTable
	
	SetValue: (value) =>
		@arguments = value
		if IsValid @rawPanel
			if @rawPanel.SetSelectedNumber
				@rawPanel\SetSelectedNumber input.GetKeyCode value
			else
				@rawPanel\SetValue value
			if @rawPanel.Data
				-- SetValue will not set the correct display name for DComboBox
				for choiceIndex, data in pairs @rawPanel.Data
					if data == value
						@rawPanel\ChooseOptionID choiceIndex
						break

class BaseUI extends BasePanel
	new: (w,h) =>
		super!
		@scrW = ScrW!
		@scrH = ScrH!
		
		panel = with vgui.Create 'DFrame'
			\SetSize @scrW * w, @scrH * h
			\SetSizable true
			\Center!
			\MakePopup!
		
		@SetPanel panel

class ManagerUI extends BaseUI
	@saveName: ''
	
	new: (w, h) =>
		if IsValid @@managerWindow
			@@managerWindow\Show!
		else
			super w, h
			
			window = @GetPanel!
			window\SetTitle 'Console ConVar and ConCommand Manager'
			@WrapFunc window, 'Think', false, ->
				if (@nextQueryTime or 0) < RealTime!
					@nextQueryTime = RealTime! + 0.25
					@FulfillServerVarQueryRequests!
			with window.btnClose
				.DoClick = ->
					Derma_Query 'Are you sure you want to delete this window? Consider using the Minimize button instead.',
						'Close', 'Yes', (-> window\Close!), 'No'
				
			with window.btnMinim
				\SetDisabled false
				.DoClick = -> window\Hide!
			with window.btnMaxim
				\SetDisabled false
				.DoClick = ->
					if window\GetSizable!
						@oldBounds = {window\GetBounds!}
						-- make the panel fill the entire screen
						window\SetPos 0, 0
						window\SetSize ScrW!, ScrH!
						window\SetSizable false
						window\SetDraggable false
					else
						{x, y, w, h} = @oldBounds
						window\SetPos x, y
						window\SetSize w, h
						window\SetSizable true
						window\SetDraggable true
				.Paint = (panel, w, h) ->
					if window\GetSizable!
						derma.SkinHook 'Paint', 'WindowMaximizeButton', panel, w, h
					else
						-- hope that the skin has specified the 'WindowRestoreButton'
						skinData = panel\GetSkin!
						if skinData.PaintWindowRestoreButton
							derma.SkinHook 'Paint', 'WindowRestoreButton', panel, w, h
						elseif panel.m_bBackground
							-- THERE IS NO 'WindowRestoreButton' HOOK
							-- Do I have to do everything by myself?!
							if panel\GetDisabled!
								return skinData.tex.Window.Restore 0, 0, w, h, Color 255, 255, 255, 50

							if panel.Depressed or panel\IsSelected!
								return skinData.tex.Window.Restore_Down 0, 0, w, h

							if panel.Hovered
								return skinData.tex.Window.Restore_Hover 0, 0, w, h

							skinData.tex.Window.Restore 0, 0, w, h
			@@managerWindow = window
			@@managerClass = @

			@controlPanelVisibility = GetConVar('ccvccm_layout_editing')\GetBool!
			menuBar = vgui.Create 'DMenuBar', window
			@AddMenuOption menuBar, 'File', {
				{name: 'New', icon: 'page_add', func: @\PromptClear},
				{name: 'Open', icon: 'folder_page', func: @\PromptLoad},
				{name: 'Save', icon: 'disk', func: @\PromptSave},
				{name: 'Save As', icon: 'page_save', func: @\PromptSaveAs},
				{name: 'Set As Autoloaded File', icon: 'page_link', func: @\PromptAutoLoad}
			}
			@AddMenuOption menuBar, 'Edit', {
				{name: 'Toggle Layout Editing Mode', toggle: true, value: @controlPanelVisibility, func: @\SetControlPanelVisibility},
				{name: 'Add Root Tab', icon: 'tab_add', func: -> @AddRootTab!}
			}
			
			@scrollPanel = with vgui.Create 'DScrollPanel', window
				\Dock FILL
			@controlPanels = {}
			@serverVarClass = {}
			@serverVarQueryRequests = {}

			saveFile = CCVCCM\GetVarValue 'ccvccm_autoload'
			@LoadFromFile saveFile
	
	GetInstance: => @@managerClass
	
	AddControlPanel: (panel) =>
		table.insert @controlPanels, panel
		unless @controlPanelVisibility
			panel\Hide!
	
	SetControlPanelVisibility: (menu, bool) =>
		@controlPanelVisibility = bool
		GetConVar('ccvccm_layout_editing')\SetBool bool
		
		for panel in *@controlPanels do
			if IsValid panel
				panel\SetVisible bool
				
				-- FIXME: the TF2 devs aren't kidding, even I don't want to know why
				panel\GetParent!\InvalidateLayout!
				panel\GetParent!\GetParent!\InvalidateLayout!
	
	GetControlPanelVisibility: => @controlPanelVisibility
	AddServerVarQueryRequest: (var, cls) =>
		@serverVarClass[var] or= {}
		table.insert @serverVarClass[var], cls
		@serverVarQueryRequests[var] = true
	FulfillServerVarQueryRequests: =>
		if next @serverVarQueryRequests
			varSendTable = {}
			for k,v in pairs @serverVarQueryRequests
				table.insert varSendTable, 's'
				table.insert varSendTable, k
				@serverVarQueryRequests[k] = nil
				@Log "FulfillServerVarQueryRequests: #{k}"
				break if #varSendTable >= 127
			CCVCCM\StartNet!
			CCVCCM\AddPayloadToNetMessage {'u8', CCVCCM.ENUMS.NET.QUERY, 'u8', #varSendTable / 2}
			CCVCCM\AddPayloadToNetMessage varSendTable
			CCVCCM\FinishNet!
	
	ReceiveServerVarQueryResult: (var, val) =>
		@Log "ReceiveServerVarQueryResult: #{var} = #{val}"
		for cls in *@serverVarClass[var] do cls\SetValue val

	AddMenuOption: (menuBar, menuName, menuOptions) =>
		menu = menuBar\AddMenu menuName
		
		for {:name, :func, :icon, :value, :toggle} in *menuOptions
			with menu\AddOption name
				\SetIcon "icon16/#{icon}.png" if icon
				if toggle
					\SetIsCheckable toggle 
					\SetChecked(value or false)
					.OnChecked = func or .OnChecked
				else
					.DoClick = func or .DoClick
		
		menu
	
	AddRootTab: (displayName = 'New Tab', icon, content, static) =>
		@CreateSheet! unless IsValid @sheet
		
		-- I'm passing @ here because content panels sometimes need to receive / give info to the main window
		contentPanel = ContentPanel 'tab', @, static
		
		{Tab: tab} = @sheet\AddSheet displayName, contentPanel\GetPanel!, icon, false, true
		unless static
			tab.DoDoubleClick = -> contentPanel\PromptRenameTab! if @controlPanelVisibility
			@AddControlPanel contentPanel\GetControlPanel!
		contentPanel\LoadFromTable content
	
	CreateSheet: =>
		@sheet = with vgui.Create 'DPropertySheet', @scrollPanel
			\Dock TOP
			.tabScroller\SetUseLiveDrag true
			@MakeDraggable .tabScroller
		@WrapFunc @sheet, 'PerformLayout', true, (w, h) =>
			padding = @GetPadding!
			panel = @GetActiveTab!\GetPanel!
			
			@SetTall panel\GetTall! + 20 + padding * 2
			CCVCCM\Log @, 'PerformLayout'
	
	PromptClear: =>
		Derma_Query 'Are you sure?', 'New File', 'Yes', (->
			@@saveName = ''
			@sheet\Remove! if IsValid @sheet
			@LoadFromFile ''
		), 'No'
	
	PromptSave: => if @@saveName != '' then @SaveToFile @@saveName else @PromptSaveAs!
	
	PromptSaveAs: =>
		Derma_StringRequest 'Save', 'Enter file name:', @@saveName, (saveName) ->
			if file.Exists "ccvccm/#{saveName}.json", 'DATA'
				Derma_Query 'Overwrite existing file?', 'Overwrite', 'Yes', (-> @SaveToFile saveName), 'No'
			else
				@SaveToFile saveName
	
	PromptAutoLoad: =>
		if @@saveName == ''
			Derma_Message 'Save your current layout first!', 'Load Error', 'OK'
		else
			Derma_Query "This will set the current save file (ccvccm/#{@@saveName}.json) to be automatically loaded when the CCVCCM is opened. Are you sure?",
				'Set As Autoloaded File', 'Yes', (-> CCVCCM\SetVarValue 'ccvccm_autoload', @@saveName), 'No'
	
	SaveToFile: (saveName) =>
		@@saveName = saveName
		fileName = "ccvccm/#{saveName}.json"
		routine = coroutine.create @\SaveToFileRoutine
		coroutine.resume routine, fileName
		SavablePanel\UpdateSavables!
		ProgressUI 0.25, 0.25, {
			:routine
			expectedRuns: table.Count(SavablePanel.panelClasses),
			headerText: 'Your data is being saved, please wait!'
		}
	
	SaveToFileRoutine: (fileName) =>
		unless file.IsDir 'ccvccm', 'DATA'
			file.CreateDir 'ccvccm'
		
		coroutine.yield!
		data = @SaveToTable!

		file.Write fileName, util.TableToJSON data
		"Successfully saved to \"data/#{fileName}\"!"

	SaveToTable: =>
		-- this and its related functions are probably by far the hardest methods I've had to write for this
		if IsValid @sheet
			-- first, get all the tabs and sort by position
			tabs = @sheet.tabScroller\GetCanvas!\GetChildren!
			@SortPanelsByPosition tabs

			-- now assemble [tab] = class
			tabContentClasses = {tab, SavablePanel.panelClasses[panel] for {Tab: tab, Panel: panel} in *@sheet\GetItems!}
			
			-- finally,
			saveTable = {}
			for i, tab in ipairs tabs
				unless tabContentClasses[tab]\GetStatic!
					tabSaveTable = {
						displayName: tab\GetText!
						content: tabContentClasses[tab]\SaveToTable!
					}
					tabSaveTable.icon = tab.Image\GetImage! if tab.Image

					table.insert saveTable, tabSaveTable
				coroutine.yield!
			saveTable
		else
			{}
	
	PromptLoad: => with LoadUI 0.5, 0.5
		\SetCallback (classData, saveName) -> @LoadFromFile saveName
	
	LoadFromFile: (saveName) =>
		@@saveName = saveName
		fileName = "ccvccm/#{saveName}.json"
		-- I have to check for existence here due to auto-load
		if saveName == '' or file.Exists fileName, 'DATA'
			routine = coroutine.create @\LoadFromFileRoutine
			ok, data = coroutine.resume routine, fileName
			if ok
				ProgressUI 0.25, 0.25, {
					:routine
					expectedRuns: if data then CCVCCM\CountTablesRecursive data else 1
					headerText: 'Your data is being loaded, please wait!'
				}
			else
				error data
		else Derma_Message "Couldn't load file \"data/#{fileName}\"!", 'Load Error', 'OK'
	
	LoadFromFileRoutine: (fileName) =>
		data = {}
		if fileName ~= 'ccvccm/.json'
			fileText = file.Read fileName, 'DATA'
			data = util.JSONToTable fileText if fileText
		hook.Run 'CCVCCMDataLoad', data
		coroutine.yield data
		if data
			@sheet\Remove! if IsValid @sheet
			@LoadFromTable data
			"Successfully loaded from \"data/#{fileName}\"!"
		else
			"\"data/#{fileName}\" is corrupted!"
	
	LoadFromTable: (data) =>
		for {:displayName, :icon, :content, :static} in *data
			@AddRootTab displayName, icon, content, static
			coroutine.yield!

class AddElementUI extends BaseUI
	@ELEMENT_TYPES:
		TEXT: 0
		CATEGORY: 1
		TABS: 2
		CLIENT_CVAR: 3
		CLIENT_CCMD: 4
		SERVER_CVAR: 5
		SERVER_CCMD: 6
		ADDON: 7
	
	@DATA_TYPES:
		NONE: 0 -- only for ConCommands
		BOOL: 1
		CHOICE: 2
		KEYBIND: 3
		NUMBER: 4
		STRING: 5
		CHOICE_LIST: 6
		NUMBER_LIST: 7
		STRING_LIST: 8
		COMPLEX_LIST: 9 -- only for addons / ListInputUI

	new: (w, h, defaultData) =>
		super w, h
		
		window = @GetPanel!
		scrollPanel = with vgui.Create 'DScrollPanel', window
			\Dock FILL
		
		with @CreateButton window, 'OK'
			\Dock BOTTOM
			.DoClick = ->
				dataValid, invalidReason = @CheckDataValidity!
				if dataValid
					window\Close!
					@callback @data if @callback
				else
					Derma_Message invalidReason, 'Invalid Arguments', 'OK'
		
		@elementPanelDisplayFlags = {}
		@dataPanelDisplayFlags = {}
		if defaultData
			@data = table.Copy defaultData
			unless @data.elementType
				@data.elementType = @@ELEMENT_TYPES.TEXT
			unless @data.dataType
				@data.dataType = @@DATA_TYPES.BOOL
			@data.elementTypeLocked = true
		else
			@data = 
				elementType: @@ELEMENT_TYPES.TEXT
				dataType: @@DATA_TYPES.BOOL

		@AddElementPanels scrollPanel
		@OnETypeSelect @data.elementType
		@OnDTypeSelect @data.dataType
	
	AddElementPanels: (scrollPanel) =>
		elementTypeSelected = @data.elementType
		dataTypeSelected = @data.dataType
		ETYPES = @@ELEMENT_TYPES
		cvarDisplayFlags = GetBitflagFromIndices ETYPES.CLIENT_CVAR, ETYPES.SERVER_CVAR
		ccmdDisplayFlags = GetBitflagFromIndices ETYPES.CLIENT_CCMD, ETYPES.SERVER_CCMD
		textDisplayFlags = GetBitflagFromIndices ETYPES.TEXT, ETYPES.CATEGORY
		commDisplayFlags = bit.bor cvarDisplayFlags, ccmdDisplayFlags

		with @CreateLabel scrollPanel, 'Element Type', 1
			\Dock TOP
		
		with vgui.Create 'DComboBox', scrollPanel
			\AddChoice 'Text', ETYPES.TEXT, elementTypeSelected == ETYPES.TEXT
			\AddChoice 'Category', ETYPES.CATEGORY, elementTypeSelected == ETYPES.CATEGORY
			\AddChoice 'Tabs', ETYPES.TABS, elementTypeSelected == ETYPES.TABS
			\AddChoice 'Client ConVar', ETYPES.CLIENT_CVAR, elementTypeSelected == ETYPES.CLIENT_CVAR
			\AddChoice 'Client ConCommand', ETYPES.CLIENT_CCMD, elementTypeSelected == ETYPES.CLIENT_CCMD
			\AddChoice 'Server ConVar (Admin Only)', ETYPES.SERVER_CVAR, elementTypeSelected == ETYPES.SERVER_CVAR
			\AddChoice 'Server ConCommand (Admin Only)', ETYPES.SERVER_CCMD, elementTypeSelected == ETYPES.SERVER_CCMD
			\SetZPos 2
			\Dock TOP
			.OnSelect = (selector, index, name, value) -> @OnETypeSelect value
			if @data.elementTypeLocked
				\SetEnabled false 
		

		
		with panel = @CreateLabel scrollPanel, 'Display Name', 3
			\Dock TOP
			@elementPanelDisplayFlags[panel] = bit.bor commDisplayFlags, textDisplayFlags
		
		with panel = vgui.Create 'DTextEntry', scrollPanel
			\SetText @data.displayName if @data.displayName
			\SetZPos 4
			\Dock TOP
			.OnChange = -> @data.displayName = panel\GetValue!
			@elementPanelDisplayFlags[panel] = bit.bor commDisplayFlags, textDisplayFlags
		


		with panel = @CreateLabel scrollPanel, 'ConVar', 5
			\Dock TOP
			@elementPanelDisplayFlags[panel] = cvarDisplayFlags
		
		with panel = @CreateLabel scrollPanel, 'ConCommand', 5
			\Dock TOP
			@elementPanelDisplayFlags[panel] = ccmdDisplayFlags
		
		with panel = vgui.Create 'DTextEntry', scrollPanel
			\SetText @data.internalName if @data.internalName
			\SetZPos 6
			\Dock TOP
			.OnChange = -> @data.internalName = panel\GetValue!
			@elementPanelDisplayFlags[panel] = commDisplayFlags
		


		with panel = @CreateLabel scrollPanel, 'ConVar Type', 7
			\Dock TOP
			@elementPanelDisplayFlags[panel] = cvarDisplayFlags
		
		with panel = @CreateLabel scrollPanel, 'ConCommand Type', 7
			\Dock TOP
			@elementPanelDisplayFlags[panel] = ccmdDisplayFlags
		
		DTYPES = @@DATA_TYPES
		with panel = vgui.Create 'DComboBox', scrollPanel
			\AddChoice 'None (ConCommands only)', DTYPES.NONE, dataTypeSelected == DTYPES.NONE
			\AddChoice 'Boolean', DTYPES.BOOL, dataTypeSelected == DTYPES.BOOL
			\AddChoice 'Choices', DTYPES.CHOICE, dataTypeSelected == DTYPES.CHOICE
			\AddChoice 'Keybind', DTYPES.KEYBIND, dataTypeSelected == DTYPES.KEYBIND
			\AddChoice 'Numeric', DTYPES.NUMBER, dataTypeSelected == DTYPES.NUMBER
			\AddChoice 'Text', DTYPES.STRING, dataTypeSelected == DTYPES.STRING
			\AddChoice 'Choices List', DTYPES.CHOICE_LIST, dataTypeSelected == DTYPES.CHOICE_LIST
			\AddChoice 'Numeric List', DTYPES.NUMBER_LIST, dataTypeSelected == DTYPES.NUMBER_LIST
			\AddChoice 'Text List', DTYPES.STRING_LIST, dataTypeSelected == DTYPES.STRING_LIST
			\SetZPos 8
			\Dock TOP
			.OnSelect = (selector, index, name, value) -> @OnDTypeSelect value
			@elementPanelDisplayFlags[panel] = commDisplayFlags
		


		with panel = @CreateButton scrollPanel, 'Set Choices', 9
			\Dock TOP
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.CHOICE, DTYPES.CHOICE_LIST
			.DoClick = ->
				with ListInputUI 0.5, 0.5, {
					names: {'Display Name', 'Value'}
					types: {
						{
							dataType: DTYPES.STRING
						},
						{
							dataType: DTYPES.STRING
						}
					}
				}, @data.choices
					\SetCallback (classData, values) ->
						@data.choices = values

		


		with panel = @CreateLabel scrollPanel, 'Minimum Value', 9
			\Dock TOP
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.NUMBER, DTYPES.NUMBER_LIST
		
		with panel = vgui.Create 'DTextEntry', scrollPanel
			\SetValue @data.min if @data.min
			\SetZPos 10
			\Dock TOP
			.OnChange = -> @data.min = panel\GetValue!
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.NUMBER, DTYPES.NUMBER_LIST
		


		with panel = @CreateLabel scrollPanel, 'Maximum Value', 11
			\Dock TOP
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.NUMBER, DTYPES.NUMBER_LIST
		
		with panel = vgui.Create 'DTextEntry', scrollPanel
			\SetValue @data.max if @data.max
			\SetZPos 12
			\Dock TOP
			.OnChange = -> @data.max = panel\GetValue!
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.NUMBER, DTYPES.NUMBER_LIST
		


		with panel = @CreateLabel scrollPanel, 'Interval Between Values (blank = 0.01)', 13
			\Dock TOP
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.NUMBER, DTYPES.NUMBER_LIST
		
		with panel = vgui.Create 'DTextEntry', scrollPanel
			\SetValue @data.interval if @data.interval
			\SetZPos 14
			\Dock TOP
			.OnChange = -> @data.interval = panel\GetValue!
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.NUMBER, DTYPES.NUMBER_LIST
		


		with panel = vgui.Create 'DCheckBoxLabel', scrollPanel
			\SetValue @data.logarithmic if @data.logarithmic
			\SetText 'Logarithmic'
			\SetZPos 15
			\Dock TOP
			.OnChange = (panel, value) -> @data.logarithmic = value
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.NUMBER, DTYPES.NUMBER_LIST



		with panel = @CreateLabel scrollPanel, 'List Separator', 16
			\Dock TOP
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.CHOICE_LIST, DTYPES.NUMBER_LIST, DTYPES.STRING_LIST
		
		with panel = vgui.Create 'DTextEntry', scrollPanel
			\SetValue @data.listSeparator if @data.listSeparator
			\SetZPos 17
			\Dock TOP
			.OnChange = -> @data.listSeparator = panel\GetValue!
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.CHOICE_LIST, DTYPES.NUMBER_LIST, DTYPES.STRING_LIST



		with panel = vgui.Create 'DCheckBoxLabel', scrollPanel
			\SetValue @data.manual if @data.manual
			\SetText 'Update ConVar Manually'
			\SetZPos 18
			\Dock TOP
			.OnChange = (panel, value) -> @data.manual = value
			@elementPanelDisplayFlags[panel] = cvarDisplayFlags
	
	CheckDataValidity: =>
		dataValid = true
		invalidReason = 'One of the entered values is invalid!'

		ETYPES = @@ELEMENT_TYPES
		DTYPES = @@DATA_TYPES
		elementType = @data.elementType
		isCVar = elementType == ETYPES.CLIENT_CVAR or elementType == ETYPES.SERVER_CVAR
		isCCmd = elementType == ETYPES.CLIENT_CCMD or elementType == ETYPES.SERVER_CCMD

		if isCVar or isCCmd
			name = @data.internalName or ''

			if elementType == ETYPES.CLIENT_CVAR 
				-- get data about the CVar
				conVar = GetConVar name
				if (conVar and conVar\IsFlagSet FCVAR_REPLICATED)
					dataValid = false
					invalidReason = "\"#{name}\" is a replicated ConVar and must be added as a Server ConVar!"

			if name == ''
				dataValid = false
				invalidReason = "\"#{name}\" is not a valid ConCommand / ConVar!"
			elseif IsConCommandBlocked name
				dataValid = false
				invalidReason = "\"#{name}\" can't be altered / used by CCVCCM!"
			elseif dataValid
				switch @data.dataType
					when DTYPES.NONE
						if isCVar
							dataValid = false
							invalidReason = "None data type is only valid for ConCommands!"

					when DTYPES.NUMBER, DTYPES.NUMBER_LIST
						minValue = tonumber @data.min
						unless minValue
							dataValid = false
							invalidReason = "Minimum value \"#{minValue}\" is not a number!"
						
						maxValue = tonumber @data.max
						unless maxValue
							dataValid = false
							invalidReason = "Maximum value \"#{maxValue}\" is not a number!"
						
						stepValue = @data.interval or ''
						if stepValue == ''
							stepValue = 10 ^ -(math.Round 4 - math.log10 math.abs maxValue - minValue)
						else
							stepValue = tonumber stepValue
						
						unless stepValue
							dataValid = false
							invalidReason = "Step value \"#{stepValue}\" is not a number!"
						elseif not (stepValue > 0)
							dataValid = false
							invalidReason = "Step value \"#{stepValue}\" must be positive!"
						
						if @data.logarithmic and not (minValue * maxValue > 0)
							dataValid = false
							invalidReason = "Minimum value times maximum value must be positive in logarithmic mode!"
					
					when DTYPES.CHOICE, DTYPES.CHOICE_LIST
						choices = if @data.choices then #@data.choices else 0
						unless choices > 0
							dataValid = false
							invalidReason = "You must specify at least one choice!"
			
		dataValid, invalidReason

	SetCallback: (func) => @callback = func

	UpdatePanelVisibilities: =>
		elementDisplayFlag = bit.lshift 1, @data.elementType
		dataDisplayFlag = bit.lshift 1, @data.dataType
		
		for panel, flags in pairs @elementPanelDisplayFlags
			shouldDisplay = (bit.band flags, elementDisplayFlag) != 0

			dataRequiredFlags = @dataPanelDisplayFlags[panel]
			if dataRequiredFlags
				shouldDisplay and= (bit.band dataRequiredFlags, dataDisplayFlag) != 0
			
			panel\SetVisible(shouldDisplay)
	
	OnETypeSelect: (value) =>
		@data.elementType = value
		displayFlag = bit.lshift 1, value
		@UpdatePanelVisibilities!
		
	OnDTypeSelect: (value) =>
		@data.dataType = value
		displayFlag = bit.lshift 1, value
		@UpdatePanelVisibilities!

class EditIconUI extends BaseUI
	new: (w, h, selectedIcon = '', callback = ->) =>
		super w, h
		window = @GetPanel!

		browser = with vgui.Create 'DIconBrowser', window
			\Dock FILL
			\SelectIcon selectedIcon
			if selectedIcon == ''
				.m_pSelectedIcon = NULL

		with @CreateButton window, 'Clear Icon', 1
			\Dock TOP
			.DoClick = ->
				browser\SelectIcon ''
				browser.m_pSelectedIcon = NULL

		with vgui.Create 'DTextEntry', window
			\SetPlaceholderText 'Search...'
			\SetZPos 2
			\Dock TOP
			.OnChange = => browser\FilterByText @GetValue!
		
		with @CreateButton window, 'OK'
			\Dock BOTTOM
			.DoClick = ->
				window\Close!
				callback browser\GetSelectedIcon!

class MultilineTextUI extends BaseUI
	new: (w, h, text = '', callback = ->) =>
		super w, h
		window = @GetPanel!

		with @CreateLabel window, 'You can enter multiple lines in this text box.'
			\Dock TOP

		textEntry = with vgui.Create 'DTextEntry', window
			\Dock FILL
			\SetMultiline true
			\SetValue text
		
		with @CreateButton window, 'OK'
			\Dock BOTTOM
			.DoClick = ->
				window\Close!
				callback textEntry\GetValue!

class ListInputUI extends BaseUI
	new: (w, h, data = {}, values = {}) =>
		super w, h
		window = @GetPanel!
		@dataTypes = data.types
		@rowPanels = {}

		if data.header
			with @CreateLabel window, data.header
				\SetZPos 1
				\Dock TOP
		
		findPanel = with vgui.Create 'DPanel', window
			\SetTall 22
			\Dock TOP
			\SetZPos 2
			.Paint = nil
		
		findEntry = with vgui.Create 'DTextEntry', findPanel
			\SetPlaceholderText 'Find... (must be exact value!)'
			\Dock FILL
		
		with @CreateButton findPanel, 'Paste JSON', 1, 'paste_plain'
			\Dock RIGHT
			.DoClick = ->
				Derma_StringRequest 'Paste', 'Enter JSON - note that all values will be overwritten!', '', (jsonData) ->
					tab = util.JSONToTable jsonData
					if tab
						@SetValue tab
					else
						Derma_Message 'Entered text isn\'t valid JSON!', 'Paste Error', 'OK'
		
		with @CreateButton findPanel, 'Copy JSON', 2, 'page_white_text'
			\Dock RIGHT
			.DoClick = ->
				SetClipboardText util.TableToJSON @GetValues!, true
				Derma_Message 'Copied as JSON!', 'Copy', 'OK'
		
		with @CreateButton findPanel, 'Find', 3, 'magnifier'
			\Dock RIGHT
			.DoClick = ->
				findValue = findEntry\GetValue!
				result = @FindValue findValue
				unless result
					Derma_Message "Couldn't find value #{findValue}!", 'Find Failed', 'OK'
		
		if data.names
			rowPanel = with vgui.Create 'DPanel', window
				\SetTall 22
				\Dock TOP
				\SetZPos 3
				.Paint = nil
			
			local rowElementPanel
			with CustomPanelContainer rowPanel
				\SetStretch true, false
				rowElementPanel = \GetPanel!
			with rowElementPanel
				\DockMargin 22, 0, 22, 0
				\Dock FILL
			
			for i, name in ipairs data.names
				@CreateLabel rowElementPanel, name, i
		
		with @CreateButton window, 'OK'
			\Dock BOTTOM
			.DoClick = ->
				window\Close!
				@callback @GetValues! if @callback
		
		@scrollPanel = with vgui.Create 'DScrollPanel', window
			\Dock FILL
		
		@listPanel = with vgui.Create 'DIconLayout', @scrollPanel
			\SetZPos 1
			\Dock TOP
			\SetDropPos '28'
			\SetUseLiveDrag true

		@MakeDraggable @listPanel

		with vgui.Create 'DImageButton', @scrollPanel
			\SetImage 'icon16/add.png'
			\SetStretchToFit false
			\SetTall 22
			\SetZPos 2
			\Dock TOP
			.DoClick = -> @AddRow!
		
		@SetValue values
	
	SetCallback: (callback) => @callback = callback

	SetValue: (values) =>
		@rowPanels = {}
		@listPanel\Clear!
		for rowValues in *values do @AddRow rowValues
	
	AddRow: (rowValues = {}) =>
		rowPanel = with vgui.Create 'DPanel', @listPanel
			\SetTall 22
			\Dock TOP
			\SetCursor 'sizeall'
			.Paint = nil
		
		local rowClass
		with vgui.Create 'DImageButton', rowPanel
			\SetStretchToFit false
			\SetImage 'icon16/delete.png'
			\SetWide 22
			\Dock RIGHT
			.DoClick = ->
				@rowPanels[rowClass] = nil
				rowPanel\Remove!
		
		-- FIXME: using a CustomPanelContainer here is stupidly overkill
		local dragImageParent
		with CustomPanelContainer rowPanel
			dragImageParent = \GetPanel!
		with dragImageParent
			\SetMouseInputEnabled false
			\SetWide 22
			\Dock LEFT
		
		with vgui.Create 'DImage', dragImageParent
			\SetImage 'icon16/shape_handles.png'
			\SizeToContents!

		rowClass = CustomPanelContainer rowPanel
		rowClass\SetStretch true, false
		rowElementPanel = rowClass\GetPanel!
		rowElementPanel\Dock FILL
		
		DTYPES = AddElementUI.DATA_TYPES
		for i, dataTypeInfo in ipairs @dataTypes
			currentValue = rowValues[i]

			switch dataTypeInfo.dataType
				when DTYPES.BOOL
					hostPanel = CustomPanelContainer rowElementPanel
					with vgui.Create 'DCheckBox', hostPanel\GetPanel!
						\SetPos 3, 3
						\SetValue currentValue if currentValue
				when DTYPES.CHOICE
					comboBox = vgui.Create 'DComboBox', rowElementPanel
					for {display, value} in *dataTypeInfo.choices
						comboBox\AddChoice display, value, currentValue == value
				when DTYPES.NUMBER
					{:min, :max, :interval, :logarithmic} = dataTypeInfo
					with CustomNumSlider rowElementPanel
						\SetText nil
						\SetMinMax min, max if min and max
						\SetInterval interval if interval
						\SetLogarithmic logarithmic if logarithmic
						\GetPanel!\SetValue currentValue if currentValue
				when DTYPES.STRING
					with vgui.Create 'DTextEntry', rowElementPanel
						\SetValue currentValue if currentValue
				when DTYPES.COMPLEX_LIST
					button = @CreateButton rowElementPanel, dataTypeInfo.name or 'Edit List'
					button.DoClick = ->
						with ListInputUI 0.5, 0.5, dataTypeInfo, currentValue
							\SetCallback (classData, values) ->
								currentValue = values
					button.GetValue = -> currentValue
				else
					error "#{dataTypeInfo.dataType} is not a valid data type!"

		@rowPanels[rowClass] = true
		rowClass
	
	GetValues: =>
		-- get all children of panels added... in the correct order.
		sortedRowPanels = [rowClass\GetPanel! for rowClass, _ in pairs @rowPanels]
		@SortPanelsByPosition sortedRowPanels

		DTYPES = AddElementUI.DATA_TYPES
		values = {}

		for i, rowPanel in ipairs sortedRowPanels
			childrenPanels = rowPanel\GetChildren!
			@SortPanelsByPosition childrenPanels
			
			rowValues = {}

			for j, dataTypeInfo in ipairs @dataTypes
				switch dataTypeInfo.dataType
					when DTYPES.BOOL
						rowValues[j] = childrenPanels[j]\GetChild(0)\GetChecked! or false
					when DTYPES.CHOICE
						rowValues[j] = select 2, childrenPanels[j]\GetSelected!
					when DTYPES.NUMBER
						rowValues[j] = childrenPanels[j]\GetValue!
					when DTYPES.STRING
						rowValues[j] = childrenPanels[j]\GetText!
					when DTYPES.COMPLEX_LIST
						rowValues[j] = childrenPanels[j]\GetValue!
					else
						error "#{dataTypeInfo.dataType} is not a valid data type!"

			values[i] = rowValues
		values
	
	FindValue: (findValue) =>
		DTYPES = AddElementUI.DATA_TYPES
		for rowClass, _ in pairs @rowPanels
			rowPanel = rowClass\GetPanel!
			childrenPanels = rowPanel\GetChildren!

			for j, dataTypeInfo in ipairs @dataTypes
				valueMatched = false
				switch dataTypeInfo.dataType
					when DTYPES.BOOL
						value = childrenPanels[j]\GetChild(0)\GetChecked! or false
						valueMatched = value == tobool findValue
					when DTYPES.CHOICE
						valueMatched = childrenPanels[j]\GetSelected! == findValue
					when DTYPES.NUMBER
						valueMatched = childrenPanels[j]\GetValue! == tonumber findValue
					when DTYPES.STRING
						valueMatched = childrenPanels[j]\GetText! == findValue
					when DTYPES.COMPLEX_LIST
						valueMatched = false
					else
						error "#{dataTypeInfo.dataType} is not a valid data type!"
				if valueMatched
					@scrollPanel\ScrollToChild rowPanel
					return true

class ProgressUI extends BaseUI
	@ELEMENT_FPS: 30
	stopped: false
	resumes: 0

	new: (w, h, data) =>
		super w, h
		window = @GetPanel!
		@startProgressTime = SysTime!

		{:routine, :expectedRuns, :headerText} = data
		@expectedRuns = expectedRuns

		@WrapFunc window, 'Think', false, ->
			if not @stopped
				stopTime = SysTime! + 1/@@ELEMENT_FPS
				while SysTime! < stopTime
					ok, @stopped = coroutine.resume routine
					@resumes += 1
					if ok
						if @stopped
							@button\SetText 'OK'
							@button\SizeToContentsX 22
							@progressBar\SetFraction 1
							@progressLabel\SetText @stopped
							break
						else @RecomputeFraction!
					elseif @stopped
						error @stopped
					else
						@stopped = true
						break

		with @CreateLabel window, headerText
			\SetZPos 1
			\Dock TOP
		
		@progressBar = with vgui.Create 'DProgress', window
			\SetZPos 2
			\Dock TOP

		@progressLabel = with @CreateLabel window, '0.00%'
			\SetContentAlignment 8
			\SetZPos 3
			\Dock TOP
		
		-- FIXME: Again, wasting perf by using this for only one panel
		containerClass = with CustomPanelContainer window
			\SetStretch false, true
		containerPanel = with containerClass\GetPanel!
			\SetTall 22
			\Dock BOTTOM

		@button = with @CreateButton containerPanel, 'Cancel'
			.DoClick = ->
				@GetPanel!\Close!
	
	RecomputeFraction: =>
		fraction = math.Clamp @resumes / @expectedRuns, 0, 1
		@progressBar\SetFraction fraction

		if fraction == 0
			@progressLabel\SetText '0.00%'
		else
			timeTaken = SysTime! - @startProgressTime
			timeLeft = timeTaken / fraction - timeTaken
			@progressLabel\SetText string.format '%#.2f%% (%s estimated time left)', fraction*100, @GetTimeString timeLeft
	
	GetTimeString: (rawTime) =>
		mins, minFrac = math.modf rawTime / 60
		secs, secFrac = math.modf minFrac * 60
		millis = secFrac * 1000

		string.format '%02u:%02u.%03u', mins, secs, millis

class LoadUI extends BaseUI
	new: (w, h) =>
		super w, h
		@window = @GetPanel!

		controlPanel = with vgui.Create 'DPanel', @window
			\SetTall 22
			\Dock BOTTOM
		
		with @CreateButton controlPanel, 'Delete', 1, 'delete'
			\Dock RIGHT
			.DoClick = -> @PromptAction 3
		
		with @CreateButton controlPanel, 'Rename', 2, 'pencil'
			\Dock RIGHT
			.DoClick = -> @PromptAction 2
		
		with @CreateButton controlPanel, 'Load', 3, 'folder_page'
			\Dock RIGHT
			.DoClick = -> @PromptAction 1
		
		@textEntry = with vgui.Create 'DTextEntry', controlPanel
			\Dock FILL
		
		@listView = with vgui.Create 'DListView', @window
			\Dock FILL
			\SetMultiSelect false
			\AddColumn 'Name'
			\AddColumn 'Size'
			\AddColumn 'Modified'
			.OnRowSelected = (listView, rowIndex, rowPanel) ->
				@textEntry\SetValue string.StripExtension rowPanel\GetValue 1
		
		fileNames = file.Find 'ccvccm/*.json', 'DATA'
		if fileNames
			for fileName in *fileNames
				moreQualifiedFileName = 'ccvccm/'..fileName

				displayedName = string.StripExtension fileName
				fileSize = string.NiceSize file.Size moreQualifiedFileName, 'DATA'
				fileModified = os.date '%Y-%m-%dT%X%z', file.Time moreQualifiedFileName, 'DATA'
				@listView\AddLine displayedName, fileSize, fileModified
	
	SetCallback: (callback) => @callback = callback

	PromptAction: (action) =>
		-- check if the file is valid
		textEntryValue = @textEntry\GetValue!
		fileName = "ccvccm/#{textEntryValue}.json"
		if file.Exists fileName, 'DATA'
			switch action
				when 1
					@window\Close!
					@callback textEntryValue if @callback
				when 2
					Derma_StringRequest 'Rename', 'Enter new file name:', textEntryValue, (saveName) ->
						newFileName = "ccvccm/#{saveName}.json"
						if file.Exists newFileName, 'DATA'
							Derma_Message "File \"data/#{newFileName}\" already exists!", 'Rename Error', 'OK'
						else
							file.Rename fileName, newFileName
						-- figure out which row should be renamed
						for i, line in ipairs @listView\GetLines!
							if line\GetValue(1) == textEntryValue
								line\SetColumnText 1, saveName
								-- FIXME: are these two lines really necessary?
								@listView\SetDirty true
								@listView\InvalidateLayout!
								break
				when 3
					Derma_Query 'Are you sure?', 'Delete File', 'Yes', (->
						file.Delete fileName
						-- figure out which row should be deleted
						for i, line in ipairs @listView\GetLines!
							if line\GetValue(1) == textEntryValue
								@listView\RemoveLine i
								break
					), 'No'
		else
			Derma_Message "Couldn't load file \"data/#{fileName}\"!", 'Load Error', 'OK'