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

			if title == "Miscellaneous" then
				DForm:Button("Reset All ConVars", "insanestats_revert_all_convars", "yes")
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

-- this concommand just tells the server to run this concommand on its end
concommand.Add("insanestats_revert_all_convars", function(ply, cmd, args, argStr)
	if argStr:lower() == "yes" then
		net.Start("insane_stats")
		net.WriteUInt(2, 8)
		net.WriteUInt(1, 8)
		net.WriteString("insanestats_revert_all_convars")
		net.SendToServer()
		InsaneStats:Log("Sent revert request to server!")
	else
		InsaneStats:Log("Reverts all server-side Insane Stats ConVars. You must pass the argument \"yes\" for this command to work.")
	end
end, nil, "Reverts all server-side Insane Stats ConVars. You must pass the argument \"yes\" for this command to work.")

-- CCVCCM compat.
local ccvccmTypes = {
	[InsaneStats.BOOL] = "bool",
	[InsaneStats.INT] = "int",
	[InsaneStats.FLOAT] = "float",
}
hook.Add("InsaneStats_CCVCCMRun", "InsaneStatsOptions", function()
	local categoryOptionData = InsaneStats:ConstructCategoryOptionTables()
	CCVCCM:SetAddon("Insane Stats")
	for k,v in SortedPairs(categoryOptionData) do
		CCVCCM:PushCategory(k, nil, true)
		for k2,v2 in SortedPairs(v) do
			CCVCCM:PushCategory(k2)

			if k == "Server" and k2 == "XP - General" then
				CCVCCM:AddConCommand("player_level_set", {
					realm = "server",
					fullName = "insanestats_xp_player_level_set",
					name = "Set Player Level",
					help = "Sets a player's level. If no player is provided, this command will set your level instead. \z
					Usage: [player] <level>",
					type = "string"
				})
			end

			for i,v3 in ipairs(v2) do
				local conVar = v3[2].conVar
				local realm = conVar:IsFlagSet(FCVAR_REPLICATED) and "shared" or "client"
				local insaneStatsType = v3[2].type
				local ccvccmType = insaneStatsType and ccvccmTypes[insaneStatsType]
				CCVCCM:AddConVar(v3[1], {
					realm = realm, fullName = conVar:GetName(),
					name = v3[2].display or conVar:GetName(),
					help = v3[2].desc,
					type = ccvccmType, default = conVar:GetDefault(),
					min = v3[2].min, max = v3[2].max,
					userInfo = v3[2].userInfo
				})
			end
			
			-- CCVCCM EXCLUSIVE!
			if k == "Server" then
				if k2 == "Miscellaneous" then
					CCVCCM:AddConCommand("revert_all_convars", {
						realm = "server",
						fullName = "insanestats_revert_all_convars",
						name = "Revert All ConVars",
						help = "Reverts all server-side Insane Stats ConVars. You must pass the argument \"yes\" for this command to work.",
						type = "string"
					})
				elseif k2 == "XP - Level Calculations" then
					CCVCCM:AddConCommand("other_level_maps_show", {
						realm = "server",
						fullName = "insanestats_xp_other_level_maps_show",
						name = "Show Factored Maps",
						help = "Dumps into the console all maps that are currently factored into level scaling.",
						type = "none"
					})
					CCVCCM:AddConCommand("other_level_maps_remove", {
						realm = "server",
						fullName = "insanestats_xp_other_level_maps_remove",
						name = "Remove Factored Maps",
						help = "Removes maps from the recorded maps list. * wildcards are allowed. \z
						If a number is given (and no matching map was found), \z
						the number will be interpreted as the number of recent maps to remove. \z
						Note that a map restart is required for the map number to be updated.",
						type = "string"
					})
					CCVCCM:AddConCommand("other_level_maps_reset", {
						realm = "server",
						fullName = "insanestats_xp_other_level_maps_reset",
						name = "Reset Factored Maps",
						help = "Clears the recorded maps list."
					})
				end
			end

			CCVCCM:PopCategory()
		end
		CCVCCM:PopCategory()
	end
end)