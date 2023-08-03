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

CCVCCM.Send = (sendTable) =>
	net.Start 'ccvccm'
	CCVCCM\AddPayloadToNetMessage sendTable
	net.SendToServer!

CCVCCM.CountTablesRecursive = (items, acc = {}, fillAccOnly = false) =>
	-- returns the number of tables within tab
	acc[items] = true
	for k, v in pairs items
		if istable(k) and not acc[k]
			@CountTablesRecursive k, acc, true
		if istable(v) and not acc[v]
			@CountTablesRecursive v, acc, true
	
	unless fillAccOnly then table.Count acc

local ^

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
	@COLORS: {
		GREEN: Color(0, 255, 0)
		AQUA: Color(0, 255, 255)
	}

	Log: (...) =>
		if GetConVar('developer')\GetInt! > 0
			texts = {...}
			table.insert texts, '\n'
			MsgC @@COLORS.AQUA, '[CCVCCM] ',
				string.format('%#.2f ', RealTime!),
				color_white, unpack texts
	
	SetPanel: (panel) => @panel = panel
	GetPanel: => @panel

	SortPanelsByPosition: (panels) =>
		table.sort panels, (a, b) ->
			ax, ay = a\LocalToScreen 0, 0
			bx, by = b\LocalToScreen 0, 0

			if ay != by then ay < by else ax < bx

	CreateButton: (parent, name, zPos, icon) =>
		with vgui.Create 'DButton', parent
			\SetText name
			if icon
				\SetImage "icon16/#{icon}.png"
				\SizeToContentsX 44
			else
				\SizeToContentsX 22
			if zPos then \SetZPos zPos
	
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
				unless post then callback ...
				oldFunc ...
				if post then callback ...
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
				if value
					--debug.Trace!
					-- if @clamp
					-- 	value = math.Clamp value, numSlider\GetMin!, numSlider\GetMax!

					if numSlider\GetValue! != value
						numSlider.Scratch\SetValue value

					-- wouldn't numSlider.Scratch\SetValue already call numSlider\ValueChanged? what spaghetti monster were they avoiding?
					-- numSlider\ValueChanged numSlider\GetValue!
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
				if @callback then @callback value
			@SetPanel panel

	GetTextValue: => @GetPanel!.Scratch\GetTextValue!
	SetClamp: (clamp) => @clamp = clamp
	
	SetText: (text) =>
		panel = @GetPanel!
		if text
			panel\SetText text
		panel\SetVisible text != nil
	
	SetMinMax: (...) =>
		@GetPanel!\SetMinMax ...
	
	SetInterval: (interval) =>
		@GetPanel!\SetDecimals math.log10 math.abs interval
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
			unless IsValid panel then SavablePanel.panelClasses[panel] = nil
	RemoveClassAndPanel: =>
		@UnregisterAsSavable!
		@GetPanel!\Remove!
	GetSavableClassFromPanel: (panel = @GetPanel!) => SavablePanel.panelClasses[panel]
	PromptDelete: => Derma_Query 'Are you sure?', 'Delete', 'Yes', @\RemoveClassAndPanel, 'No'
	-- all instances of this class MUST implement @SaveToTable themselves
	SaveToClipboard: =>
		SavablePanel.lastCopied = util.TableToJSON @SaveToTable!
		SetClipboardText SavablePanel.lastCopied
		Derma_Message 'Element copied!', 'Copy', 'OK'
	GetLastCopiedPanel: => SavablePanel.lastCopied

class ContentPanel extends SavablePanel
	new: (contentType, window) =>
		super!
		@window = window
		panel = with vgui.Create 'DPanel'
			-- CenterVertical gets called in DPropertySheet\PerformLayout
			.CenterVertical = -> -- make it do nothing, it doesn't align to how I want it
		@SetPanel panel
		@RegisterAsSavable!
		
		@controlPanel = with vgui.Create 'DPanel', panel
			\SetTall 22
			\Dock TOP
			.Paint = nil
		
		@WrapFunc panel, 'PerformLayout', false, (w, h) =>
			@SizeToChildren false, true
			BasePanel\Log 'PerformLayout', @
		
		with @CreateButton @controlPanel, 'Add Element', 1, 'add'
			\Dock LEFT
			.DoClick = @\PromptAddElement
		
		if contentType == 'tab'
			with @CreateButton @controlPanel, 'Rename Tab', 2, 'pencil'
				\Dock LEFT
				.DoClick = @\PromptRenameTab
			
			with @CreateButton @controlPanel, 'Edit Icon', 3, 'image_edit'
				\Dock LEFT
				.DoClick = ->
					if IsValid @addUI then @addUI\Close!
					tab, container = @GetTabAndParent!
					icon = if tab.Image then tab.Image\GetImage! else ''

					@addUI = with EditIconUI 0.5, 0.5, icon
						\SetCallback (classData, newImage = '') ->
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
		
		with @CreateButton @controlPanel, 'Paste Contents', 4, 'page_white_paste'
			\Dock LEFT
			.DoClick = ->
				pasteText = @GetLastCopiedPanel!
				if pasteText == ''
					Derma_StringRequest 'Paste', 'Enter panel data:', '', (pasteText) -> @LoadFromClipboard pasteText
				else
					@LoadFromClipboard pasteText
		
		if contentType == 'tab'
			with @CreateButton @controlPanel, 'Delete Tab', 5, 'delete'
				\Dock LEFT
				.DoClick = @\PromptDeleteTab
		
		@items = with vgui.Create 'DIconLayout', panel
			\Dock TOP
			\SetDropPos '28'
			\SetUseLiveDrag true
			\MakeDroppable 'ccvccm_content', true
	
	GetControlPanel: => @controlPanel
	
	AddElement: (data = {}) =>
		ETYPES = AddElementUI.ELEMENT_TYPES

		local createdPanel
		switch data.elementType
			when ETYPES.TEXT
				classPanel = TextPanel @items, data, @window
				createdPanel = classPanel\GetPanel!

			when ETYPES.CATEGORY
				classPanel = CategoryPanel @items, data, @window
				createdPanel = classPanel\GetPanel!

			when ETYPES.TABS
				classPanel = TabPanel @items, data, @window
				createdPanel = classPanel\GetPanel!

			when ETYPES.CLIENT_CCMD, ETYPES.CLIENT_CVAR, ETYPES.SERVER_CCMD, ETYPES.SERVER_CVAR
				classPanel = CCVCCPanel @items, data, @window
				createdPanel = classPanel\GetPanel!
				
		createdPanel

	AddControlPanel: (panel) => @window\AddControlPanel panel
	
	GetTabAndParent: =>
		panel = @GetPanel!
		parent = panel\GetParent!
		for {:Tab, :Panel} in *parent\GetItems!
			if Panel == panel then return Tab, parent
	
	PromptAddElement: =>
		if IsValid @addUI then @addUI\Close!
		
		@addUI = with AddElementUI 0.5, 0.5
			\SetCallback (classData, ...) ->
				@AddElement ...

	PromptRenameTab: =>
		tab, container = @GetTabAndParent!
		Derma_StringRequest 'Rename', 'Enter new tab name:', tab\GetText!, (newName) ->
			tab\SetText newName
			container\InvalidateChildren!

	PromptDeleteTab: => Derma_Query 'Are you sure?', 'Delete', 'Yes', @\DeleteTab, 'No'
	
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
		
		switch data.dataType
			when 'none'
				data.dataType = DTYPES.NONE
			when 'bool'
				data.dataType = DTYPES.BOOL
			when 'choices'
				data.dataType = DTYPES.CHOICE
			when 'number'
				data.dataType = DTYPES.NUMBER
			when 'string'
				data.dataType = DTYPES.STRING
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
	new: (parent, data, window) =>
		super!
		@window = window

		-- DSizeToContents can't be dragged!
		panel = with vgui.Create 'DPanel', parent
			\SetCursor 'sizeall'
			\Dock TOP
			.Paint = nil
		@SetPanel panel
		@WrapFunc panel, 'PerformLayout', false, (w, h) =>
			@SizeToChildren false, true
			BasePanel\Log 'PerformLayout', @
		@RegisterAsSavable!
		
		with controlPanel = vgui.Create 'DPanel', panel
			\SetTall 22
			\SetZPos 1
			\DockMargin 0, 22, 0, 0
			\Dock TOP
			.Paint = nil --(w, h) => draw.RoundedBox 8, 0, 0, w, h, Color(191, 0, 0, 127)
			
			with @CreateButton controlPanel, 'Edit', 1, 'pencil'
				\Dock LEFT
				.DoClick = -> @PromptRenameDisplay!
			
			with @CreateButton controlPanel, 'Copy Element', 2, 'page_white_copy'
				\Dock LEFT
				.DoClick = -> @SaveToClipboard!
			
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
			.DoDoubleClick = ->
				if @window\GetControlPanelVisibility! then @PromptRenameDisplay!
	
	PromptRenameDisplay: =>
		Derma_StringRequest 'Rename', 'Enter new display name:', @label\GetText!, (newName) ->
			@label\SetText newName
	
	SaveToTable: => {
		elementType: "text"
        displayName: @label\GetText!
	}

class CategoryPanel extends SavablePanel
	new: (parent, data, window) =>
		super!
		@window = window

		panel = with vgui.Create 'DPanel', parent
			\SetCursor 'sizeall'
			\Dock TOP
			.Paint = nil
		@SetPanel panel
		@WrapFunc panel, 'PerformLayout', false, (w, h) =>
			@SizeToChildren false, true
			BasePanel\Log 'PerformLayout', @
		@RegisterAsSavable!
		
		with controlPanel = vgui.Create 'DPanel', panel
			\SetTall 22
			\SetZPos 1
			\DockMargin 0, 22, 0, 0
			\Dock TOP
			.Paint = nil --(w, h) => draw.RoundedBox 8, 0, 0, w, h, Color(191, 0, 0, 127)
			
			with @CreateButton controlPanel, 'Rename', 1, 'pencil'
				\Dock LEFT
				.DoClick = -> @PromptRenameDisplay!
			
			with @CreateButton controlPanel, 'Copy Element', 2, 'page_white_copy'
				\Dock LEFT
				.DoClick = -> @SaveToClipboard!
			
			with @CreateButton controlPanel, 'Delete', 3, 'delete'
				\Dock LEFT
				.DoClick = -> @PromptDelete!
			
			window\AddControlPanel controlPanel
		
		hostPanel = with vgui.Create 'DSizeToContents', panel
			\SetSizeX false
			\SetZPos 2
			\DockPadding 4, 0, 4, 0
			\Dock TOP
		
		@contentPanel = ContentPanel 'category', window
		@category = with vgui.Create 'DCollapsibleCategory', hostPanel
			\SetCursor 'sizeall'
			\SetLabel data.displayName or 'New Category'
			\SetContents @contentPanel\GetPanel!
			\SetList parent
			\Dock TOP
			.Header.DoDoubleClick = -> if window\GetControlPanelVisibility! then @PromptRenameDisplay!
		@WrapFunc @category, 'OnRemove', false, -> @UpdateSavables!
		@contentPanel\LoadFromTable data.content
		
		window\AddControlPanel @contentPanel\GetControlPanel!
	
	PromptRenameDisplay: =>
		categoryHeader = @category.Header
		Derma_StringRequest 'Rename', 'Enter new category name:', categoryHeader\GetText!, (newName) ->
			categoryHeader\SetText newName
	
	SaveToTable: => {
		elementType: "category"
		displayName: @category.Header\GetText!
        content: @contentPanel\SaveToTable!
	}

class TabPanel extends SavablePanel
	new: (parent, data, window) =>
		super!
		@window = window

		-- create a movable proxy DPanel - I need this so that the Add Tab button
		-- follows the DPropertySheet to wherever it is dragged to
		panel = with vgui.Create 'DPanel', parent
			\SetCursor 'sizeall'
			\Dock TOP
			.Paint = nil
			--\Droppable 'CCVCCM.ElementDrag'
		@SetPanel panel
		@WrapFunc panel, 'PerformLayout', false, (w, h) =>
			@SizeToChildren false, true
			BasePanel\Log 'PerformLayout', @
		@RegisterAsSavable!

		with controlPanel = vgui.Create 'DPanel', panel
			\SetTall 22
			\SetZPos 1
			\DockMargin 0, 22, 0, 0
			\Dock TOP
			.Paint = nil --(w, h) => draw.RoundedBox 8, 0, 0, w, h, Color(191, 0, 0, 127)
			
			with @CreateButton controlPanel, 'Add Tab', 1, 'add'
				\Dock LEFT
				.DoClick = -> @AddTab!
			
			with @CreateButton controlPanel, 'Copy Element', 2, 'page_white_copy'
				\Dock LEFT
				.DoClick = -> @SaveToClipboard!
			
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
			BasePanel\Log 'PerformLayout', @
		
		if data.tabs
			for tabData in *data.tabs
				@AddTab tabData.displayName, tabData.icon, tabData.content
		else
			@AddTab!
	
	AddTab: (displayName = 'New Tab', icon, content) =>
		contentPanel = ContentPanel 'tab', @window

		{Tab: tab} = @sheet\AddSheet displayName, contentPanel\GetPanel!, icon, false, true
		tab.DoDoubleClick = -> if @window\GetControlPanelVisibility! then contentPanel\PromptRenameTab!
		@window\AddControlPanel contentPanel\GetControlPanel!
		contentPanel\LoadFromTable content
	
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
			if tab.Image then tabSaveTable.icon = tab.Image\GetImage!

			saveTable[i] = tabSaveTable
			coroutine.yield!
		
		generalSaveTable.tabs = saveTable
		generalSaveTable

class CCVCCPanel extends SavablePanel
	arguments: ''

	new: (parent, data, window) =>
		super!
		@data = data
		if data.arguments
			@arguments = data.arguments
		@window = window
		panel = with vgui.Create 'DPanel', parent
			\SetCursor 'sizeall'
			\Dock TOP
			.Paint = nil
		@SetPanel panel
		@RegisterAsSavable!

		@WrapFunc panel, 'PerformLayout', false, (w, h) =>
			@SizeToChildren false, true
			BasePanel\Log 'PerformLayout', @
		
		@PopulatePanel!
	
	SetArgs: (arguments) => @arguments = arguments
	SendToServer: => CCVCCM\Send {'s', @data.internalName..' '..@arguments}

	PopulatePanel: =>
		data = @data
		panel = @GetPanel!
		{:displayName, :dataType, :elementType, :internalName, :manual} = data
		DTYPES = AddElementUI.DATA_TYPES
		ETYPES = AddElementUI.ELEMENT_TYPES
		isClient = elementType == ETYPES.CLIENT_CCMD or elementType == ETYPES.CLIENT_CVAR
		isConVar = elementType == ETYPES.CLIENT_CVAR or elementType == ETYPES.SERVER_CVAR

		with controlPanel = vgui.Create 'DPanel', panel
			\SetTall 22
			\SetZPos 1
			\DockMargin 0, 22, 0, 0
			\Dock TOP
			.Paint = nil --(w, h) => draw.RoundedBox 8, 0, 0, w, h, Color(191, 0, 0, 127)
			
			with @CreateButton controlPanel, 'Edit', 1, 'pencil'
				\Dock LEFT
				.DoClick = -> @PromptEditPanel!
			
			with @CreateButton controlPanel, 'Copy Element', 2, 'page_white_copy'
				\Dock LEFT
				.DoClick = -> @SaveToClipboard!
			
			with @CreateButton controlPanel, 'Delete', 3, 'delete'
				\Dock LEFT
				.DoClick = -> @PromptDelete!
			
			@window\AddControlPanel controlPanel
		
		if not isConVar
			buttonText = if dataType == DTYPES.NONE then displayName else 'Run ConCommand'
			with @CreateButton panel, buttonText, 3
				\Dock TOP
				.DoClick = ->
					if isClient
						LocalPlayer!\ConCommand internalName..' '..@arguments
					else
						@SendToServer!
		elseif manual
			with @CreateButton panel, 'Apply Changes', 3
				\Dock TOP
				.DoClick = ->
					if isClient
						LocalPlayer!\ConCommand internalName..' '..@arguments
					else
						@SendToServer!
		
		switch dataType
			when DTYPES.BOOL
				hostPanel = with vgui.Create 'DSizeToContents', panel
					\SetSizeX false
					\SetZPos 2
					\DockPadding 4, 0, 0, 0
					\Dock TOP

				with vgui.Create 'DCheckBoxLabel', hostPanel
					\SetValue @arguments
					\SetZPos 2
					\Dock TOP
					\SetText displayName
					\SetDark true
					.OnChange = (panel, checked) ->
						@SetArgs checked and '1' or '0'
						unless isClient or manual then @SendToServer!
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

				comboBox = with vgui.Create 'DComboBox', hostPanel
					.OnSelect = (panel, index, value, selectedData) ->
						@SetArgs tostring selectedData or value
						if panel.m_strConVar
							LocalPlayer!\ConCommand panel.m_strConVar..' '..tostring(selectedData or value)
						elseif not (isClient or manual) then @SendToServer!
					if elementType == ETYPES.CLIENT_CVAR and not manual
						\SetConVar internalName
				
				for i, choicesInfo in ipairs data.choices
					{k, v} = choicesInfo
					comboBox\AddChoice k, v, @arguments == v

			when DTYPES.NUMBER
				with CustomNumSlider panel
					\SetText displayName
					\SetMinMax tonumber(data.minimum), tonumber(data.maximum)
					if data.interval
						\SetInterval tonumber data.interval
					\SetLogarithmic data.logarithmic
					with \GetPanel!
						\SetValue @arguments
						\SetDark true
						.Label\SetTextInset 4, 0
						\SetZPos 2
						\Dock TOP
						if elementType == ETYPES.CLIENT_CVAR and not manual
							\SetConVar internalName
					\SetCallback (classData, value) ->
						@SetArgs classData\GetTextValue!
						unless isClient or manual then @SendToServer!
					
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

				with vgui.Create 'DTextEntry', hostPanel
					\SetValue @arguments
					.GetAutoComplete = (value) =>
						possibilities = concommand.AutoComplete internalName, value
						if possibilities
							startPos = #internalName+2
							[string.sub item, startPos for item in *possibilities]
					.OnChange = (textEntry) ->
						@SetArgs textEntry\GetValue!
						unless isClient or manual then @SendToServer!
					.OnValueChange = .OnChange
					if elementType == ETYPES.CLIENT_CVAR and not manual
						\SetConVar internalName
			
			when DTYPES.STRING_LIST
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
							if conVar then conVarValue = conVar\GetString!
						
						listValues = [{str} for str in *string.Explode(listSeparator, conVarValue)]
						
						listInputUI = ListInputUI 0.5, 0.5, {
							header: 'Enter texts:'
							types: {
								{
									dataType: DTYPES.STRING
								}
							}
						}, listValues
						
						listInputUI\SetCallback (classData, values) ->
							flattenedValues = [value[1] for value in *values]
							strValue = table.concat(flattenedValues, listSeparator)
							@SetArgs strValue
							
							if elementType == ETYPES.CLIENT_CVAR and not manual
								LocalPlayer!\ConCommand internalName..' '..strValue
							elseif not (isClient or manual) then @SendToServer!
	
	PromptEditPanel: =>
		with AddElementUI 0.5, 0.5, @data
			\SetCallback (classData, newData) ->
				@data = newData
				-- clear ourselves out and regenerate
				for panel in *@GetPanel!\GetChildren! do panel\Remove!
				@arguments = ''
				@PopulatePanel!
	
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
			when DTYPES.NUMBER
				dataTypeStr = 'number'
				with saveTable
					.minimum = data.minimum
					.maximum = data.maximum
					.interval = data.interval
					.logarithmic = data.logarithmic
			when DTYPES.STRING
				dataTypeStr = 'string'
			when DTYPES.STRING_LIST
				dataTypeStr = 'stringList'
		saveTable.dataType = dataTypeStr
		saveTable

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
	@conVarAutoload: CreateClientConVar 'ccvccm_autoload', '', true, false, 'Save file to automatically load when the CCVCCM is opened.'
	controlPanelVisibility: true
	
	new: (w, h) =>
		if IsValid @@managerWindow
			@@managerWindow\Show!
		else
			super w, h
			
			window = @GetPanel!
			window\SetTitle 'Console ConVar and ConCommand Manager'
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

			saveFile = @@conVarAutoload\GetString!
			if saveFile != '' then @LoadFromFile saveFile
	
	AddControlPanel: (panel) =>
		table.insert @controlPanels, panel
		unless @controlPanelVisibility
			panel\Hide!
	
	SetControlPanelVisibility: (menu, bool) =>
		@controlPanelVisibility = bool
		
		for panel in *@controlPanels do
			if IsValid panel
				panel\SetVisible bool
				
				-- FIXME: the TF2 devs aren't kidding, even I don't want to know why
				panel\GetParent!\InvalidateLayout!
				panel\GetParent!\GetParent!\InvalidateLayout!
	
	GetControlPanelVisibility: => @controlPanelVisibility

	AddMenuOption: (menuBar, menuName, menuOptions) =>
		menu = menuBar\AddMenu menuName
		
		for {:name, :func, :icon, :value, :toggle} in *menuOptions
			with menu\AddOption name
				if icon then \SetIcon "icon16/#{icon}.png"
				if toggle
					\SetIsCheckable toggle 
					\SetChecked(value or false)
					.OnChecked = func or .OnChecked
				else
					.DoClick = func or .DoClick
		
		menu
	
	AddRootTab: (displayName = 'New Tab', icon, content) =>
		unless IsValid @sheet then @CreateSheet!
		
		-- I'm passing @ here because content panels sometimes need to receive / give info to the main window
		contentPanel = ContentPanel 'tab', @
		
		{Tab: tab} = @sheet\AddSheet displayName, contentPanel\GetPanel!, icon, false, true
		tab.DoDoubleClick = -> if @controlPanelVisibility then contentPanel\PromptRenameTab!
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
			BasePanel\Log 'PerformLayout', @
	
	PromptClear: =>
		Derma_Query 'Are you sure?', 'New File', 'Yes', (->
			@@saveName = ''
			if IsValid @sheet then @sheet\Remove!
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
				'Set As Autoloaded File', 'Yes', (-> @@conVarAutoload\SetString @@saveName), 'No'
	
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
		-- first, get all the tabs and sort by position
		if IsValid @sheet
			-- first, get all the tabs and sort by position
			tabs = @sheet.tabScroller\GetCanvas!\GetChildren!
			@SortPanelsByPosition tabs

			-- now assemble [tab] = class
			tabContentClasses = {tab, SavablePanel.panelClasses[panel] for {Tab: tab, Panel: panel} in *@sheet\GetItems!}
			
			-- finally,
			saveTable = {}
			for i, tab in ipairs tabs
				tabSaveTable = {
					displayName: tab\GetText!
					content: tabContentClasses[tab]\SaveToTable!
				}
				if tab.Image then tabSaveTable.icon = tab.Image\GetImage!

				saveTable[i] = tabSaveTable
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
		if file.Exists fileName, 'DATA'
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
		fileText = file.Read fileName, 'DATA'
		data = if fileText then util.JSONToTable fileText
		coroutine.yield data
		if data
			if IsValid @sheet then @sheet\Remove!
			@LoadFromTable data
			"Successfully loaded from \"data/#{fileName}\"!"
		else
			"\"data/#{fileName}\" is corrupted!"
	
	LoadFromTable: (data) =>
		for {:displayName, :icon, :content} in *data
			@AddRootTab displayName, icon, content
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
	
	@DATA_TYPES:
		NONE: 0 -- only for ConCommands
		BOOL: 1
		CHOICE: 2
		NUMBER: 3
		STRING: 4
		STRING_LIST: 5
		COMPLEX_LIST: 6 -- only for addons / ListInputUI

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
					if @callback then @callback @data
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
			if @data.displayName then \SetText @data.displayName
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
			if @data.internalName then \SetText @data.internalName
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
			\AddChoice 'Numeric', DTYPES.NUMBER, dataTypeSelected == DTYPES.NUMBER
			\AddChoice 'Text', DTYPES.STRING, dataTypeSelected == DTYPES.STRING
			\AddChoice 'Text List', DTYPES.STRING_LIST, dataTypeSelected == DTYPES.STRING_LIST
			\SetZPos 8
			\Dock TOP
			.OnSelect = (selector, index, name, value) -> @OnDTypeSelect value
			@elementPanelDisplayFlags[panel] = commDisplayFlags
		


		with panel = @CreateButton scrollPanel, 'Set Choices', 9
			\Dock TOP
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.CHOICE
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
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.NUMBER
		
		with panel = vgui.Create 'DTextEntry', scrollPanel
			if @data.minimum then \SetText @data.minimum
			\SetZPos 10
			\Dock TOP
			.OnChange = -> @data.minimum = panel\GetValue!
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.NUMBER
		


		with panel = @CreateLabel scrollPanel, 'Maximum Value', 11
			\Dock TOP
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.NUMBER
		
		with panel = vgui.Create 'DTextEntry', scrollPanel
			if @data.maximum then \SetText @data.maximum
			\SetZPos 12
			\Dock TOP
			.OnChange = -> @data.maximum = panel\GetValue!
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.NUMBER
		


		with panel = @CreateLabel scrollPanel, 'Interval Between Values (blank = 0.01)', 13
			\Dock TOP
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.NUMBER
		
		with panel = vgui.Create 'DTextEntry', scrollPanel
			if @data.interval then \SetText @data.interval
			\SetZPos 14
			\Dock TOP
			.OnChange = -> @data.interval = panel\GetValue!
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.NUMBER
		


		with panel = @CreateLabel scrollPanel, 'List Separator', 15
			\Dock TOP
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.STRING_LIST
		
		with panel = vgui.Create 'DTextEntry', scrollPanel
			if @data.listSeparator then \SetText @data.listSeparator
			\SetZPos 16
			\Dock TOP
			.OnChange = -> @data.listSeparator = panel\GetValue!
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.STRING_LIST
		


		with panel = vgui.Create 'DCheckBoxLabel', scrollPanel
			if @data.logarithmic then \SetValue @data.logarithmic
			\SetText 'Logarithmic'
			\SetZPos 17
			\Dock TOP
			.OnChange = (panel, value) -> @data.logarithmic = value
			@elementPanelDisplayFlags[panel] = commDisplayFlags
			@dataPanelDisplayFlags[panel] = GetBitflagFromIndices DTYPES.NUMBER
		
		with panel = vgui.Create 'DCheckBoxLabel', scrollPanel
			if @data.manual then \SetValue @data.manual
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

			if name == ''
				dataValid = false
				invalidReason = "\"#{name}\" is not a valid ConCommand / ConVar!"
			elseif IsConCommandBlocked name
				dataValid = false
				invalidReason = "\"#{name}\" can't be altered / used by CCVCCM!"
			else
				switch @data.dataType
					when DTYPES.NONE
						if isCVar
							dataValid = false
							invalidReason = "None data type is only valid for ConCommands!"

					when DTYPES.NUMBER
						minValue = tonumber @data.minimum
						unless minValue
							dataValid = false
							invalidReason = "Minimum value \"#{minValue}\" is not a number!"
						
						maxValue = tonumber @data.maximum
						unless maxValue
							dataValid = false
							invalidReason = "Maximum value \"#{maxValue}\" is not a number!"
						
						stepValue = @data.interval or ''
						if stepValue == ''
							stepValue = 0.01
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
					
					when DTYPES.CHOICE
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
	new: (w, h, selectedIcon = '') =>
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
			\SetPlaceholderText 'Filter...'
			\SetZPos 2
			\Dock TOP
			.OnChange = => browser\FilterByText @GetValue!
		
		with @CreateButton window, 'OK'
			\Dock BOTTOM
			.DoClick = ->
				window\Close!
				if @callback then @callback browser\GetSelectedIcon!
	
	SetCallback: (func) => @callback = func

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
		
		if data.names
			rowPanel = with vgui.Create 'DPanel', window
				\SetTall 22
				\Dock TOP
				\SetZPos 2
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
				if @callback
					-- get all children of panels added... in the correct order.
					sortedRowPanels = [rowClass\GetPanel! for rowClass, _ in pairs @rowPanels]
					@SortPanelsByPosition sortedRowPanels

					values = {}
					for i, rowPanel in ipairs sortedRowPanels
						childrenPanels = rowPanel\GetChildren!
						@SortPanelsByPosition childrenPanels

						values[i] = [childPanel\GetValue! for childPanel in *childrenPanels]
					
					@callback values
		
		scrollPanel = with vgui.Create 'DScrollPanel', window
			\Dock FILL
		
		@listPanel = with vgui.Create 'DIconLayout', scrollPanel
			\SetZPos 1
			\Dock TOP
			\SetDropPos '28'
			\SetUseLiveDrag true

		@MakeDraggable @listPanel

		with vgui.Create 'DImageButton', scrollPanel
			\SetImage 'icon16/add.png'
			\SetStretchToFit false
			\SetTall 22
			\SetZPos 2
			\Dock TOP
			.DoClick = -> @AddRow!
		
		for rowValues in *values do @AddRow rowValues
	
	SetCallback: (callback) => @callback = callback
	
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
					with vgui.Create 'DCheckBox', rowElementPanel
						if currentValue then \SetValue currentValue
				when DTYPES.CHOICE
					comboBox = vgui.Create 'DComboBox', rowElementPanel
					for display, value in pairs dataTypeInfo.choices
						comboBox\AddChoice display, value, currentValue == value
				when DTYPES.NUMBER
					{:min, :max, :interval, :logarithmic} = dataTypeInfo
					slider = with CustomNumSlider rowElementPanel
						\SetText nil
						\SetMinMax min, max
						\SetInterval interval
						\SetLogarithmic logarithmic
						if currentValue then \GetPanel!\SetValue currentValue
				when DTYPES.STRING
					with vgui.Create 'DTextEntry', rowElementPanel
						if currentValue then \SetValue currentValue

		@rowPanels[rowClass] = true
		rowClass

class ProgressUI extends BaseUI
	-- @ELEMENT_FPS: 10
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
				-- stopTime = SysTime! + 1/@@ELEMENT_FPS
				-- while SysTime! < stopTime
				ok, @stopped = coroutine.resume routine
				@resumes += 1
				if ok
					if @stopped
						@button\SetText 'OK'
						@button\SizeToContentsX 22
						@progressBar\SetFraction 1
						@progressLabel\SetText @stopped
						-- break
					else @RecomputeFraction!
				elseif @stopped
					error @stopped
				else
					@stopped = true
				-- break


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
					if @callback then @callback textEntryValue
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