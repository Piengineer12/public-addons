function InsaneStats:ConstructCategoryOptionTables()
	local categoryOptions = {}
	
	for k,v in SortedPairsByMemberValue(self.conVars, "id") do
		local categoryString = v.conVar:IsFlagSet(FCVAR_REPLICATED) and "Server" or "Client"
		local optionString = v.category
		
		categoryOptions[categoryString] = categoryOptions[categoryString] or {}
		categoryOptions[categoryString][optionString] = categoryOptions[categoryString][optionString] or {}
		table.insert(categoryOptions[categoryString][optionString], {k, v})
	end
	
	return categoryOptions
end

function InsaneStats:CreateAppropriateDFormPanel(DForm, data)
	local conVar = data[2].conVar
	local mustSendValueToServer = conVar:IsFlagSet(FCVAR_REPLICATED)
	local conVarName = data[1]
	local conVarValue = self:GetConVarValue(conVarName)
	local displayName = data[2].display or conVar:GetName()
	
	if data[2].type == self.BOOL then
		if mustSendValueToServer then
			local left = vgui.Create("DCheckBoxLabel", DForm)
			left:SetText(displayName)
			left:SetDark(true)
			left:SetValue(conVarValue)
			function left:OnChange(value)
				DForm:UpdateConVarValue(conVarName, value)
			end

			DForm:AddItem(left, nil)
		else
			DForm:CheckBox(displayName, conVar:GetName())
		end
	elseif data[2].type == self.INT then
		if mustSendValueToServer then
			local left = vgui.Create("DLabel", DForm)
			left:SetText(displayName)
			left:SetDark(true)

			local right = vgui.Create("DNumberWang", DForm)
			right:SetMinMax(data[2].min, data[2].max)
			right:SetDecimals(0)
			right:SetValue(conVarValue)
			function right:OnValueChanged(value)
				DForm:UpdateConVarValue(conVarName, value)
			end
			right:SizeToContents()
			
			DForm:AddItem(left, right)
		else
			DForm:NumberWang(displayName, conVar:GetName(), data[2].min, data[2].max, 0)
		end
	elseif data[2].type == self.FLOAT then
		-- think about number of decimals
		local decimals = data[2].decimals or math.max(math.Round(4 - math.log10(data[2].max - data[2].min)), 0)
		local left 
		
		if mustSendValueToServer then
			left = vgui.Create("DNumSlider", DForm)
			left:SetText(displayName)
			left:SetMinMax(data[2].min, data[2].max)
			left:SetDark(true)
			left:SetDecimals(decimals)
			left:SetValue(conVarValue)
			function left:OnValueChanged(value)
				DForm:UpdateConVarValue(conVarName, value)
			end
			left:SizeToContents()

			DForm:AddItem(left, nil)
		else
			left = DForm:NumSlider(displayName, conVar:GetName(), data[2].min, data[2].max, decimals)
		end
		
		left:SetDefaultValue(conVar:GetDefault())
	else
		if mustSendValueToServer then
			local left = vgui.Create("DLabel", DForm)
			left:SetText(displayName)
			left:SetDark(true)

			local right = vgui.Create("DTextEntry", DForm)
			right:SetValue(conVarValue)
			right:SetUpdateOnType(true)
			right:Dock(TOP)
			function right:OnValueChange(value)
				DForm:UpdateConVarValue(conVarName, value)
			end

			DForm:AddItem(left, right)
		else
			DForm:TextEntry(displayName, conVar:GetName())
		end
	end
	
	DForm:Help(conVar:GetHelpText())
end

function InsaneStats:GetDFormGenerator(title, conVarsData)
	return function(DForm)
		if LocalPlayer():IsAdmin() then
			DForm:ControlHelp(title)
			DForm.conVarsUpdatedValues = {}
			function DForm:UpdateConVarValue(k, v)
				self.conVarsUpdatedValues[k] = v
			end
			
			-- capture the old think
			DForm.oldThink = DForm.Think
			function DForm:Think(...)
				self:oldThink(...)
				if (self.insaneStats_LastUpdate or 0) + 0.1 < RealTime() and next(self.conVarsUpdatedValues) then
					self.insaneStats_LastUpdate = RealTime()
					
					net.Start("insane_stats")
					net.WriteUInt(2, 8)
					net.WriteUInt(table.Count(self.conVarsUpdatedValues), 8)
					
					for k,v in pairs(self.conVarsUpdatedValues) do
						local typ = InsaneStats:GetConVarData(k).type
						
						net.WriteString(k)
						
						if typ == InsaneStats.BOOL then
							net.WriteBool(v)
						elseif typ == InsaneStats.INT then
							net.WriteInt(v, 32)
						elseif typ == InsaneStats.FLOAT then
							net.WriteDouble(v)
						else
							net.WriteString(v)
						end
					end
					
					net.SendToServer()
					
					self.conVarsUpdatedValues = {}
				end
			end
			
			for i,v in ipairs(conVarsData) do
				self:CreateAppropriateDFormPanel(DForm, v)
				--panel:SetZPos(i)
			end
		else
			DForm:ControlHelp("You must be an admin to use this menu.")
		end
	end
end

function InsaneStats:ConstructToolMenuOptionTables()
	--[[
	DATA FORMAT:
	{
		[category = string] = {
			[option = string] = {
				{conVarName, conVarData},
				...
			},
			...
		},
		...
	}
	]]
	local categoryOptionData = self:ConstructCategoryOptionTables()
	
	local toolMenuOptionTables = {}
	for k,v in pairs(categoryOptionData) do
		for k2,v2 in pairs(v) do
			table.insert(toolMenuOptionTables, {
				"InsaneStats",
				k,
				k2..k,
				k2,
				"",
				"",
				self:GetDFormGenerator(k2, v2)
			})
		end
	end
	
	return toolMenuOptionTables
end

hook.Add("AddToolMenuTabs", "InsaneStatsOptions", function()
	spawnmenu.AddToolTab("InsaneStats", "Insane Stats")
end)

hook.Add("AddToolMenuCategories", "InsaneStatsOptions", function()
	spawnmenu.AddToolCategory("InsaneStats", "Client", "Client")
	spawnmenu.AddToolCategory("InsaneStats", "Server", "Server")
end)

hook.Add("AddToolMenuCategories", "InsaneStatsOptions", function()
	spawnmenu.AddToolCategory("InsaneStats", "Client", "Client")
	spawnmenu.AddToolCategory("InsaneStats", "Server", "Server")
end)

hook.Add("PopulateToolMenu", "InsaneStatsOptions", function()
	local items = InsaneStats:ConstructToolMenuOptionTables()
	for k,v in pairs(items) do
		spawnmenu.AddToolMenuOption(unpack(v))
	end
end)