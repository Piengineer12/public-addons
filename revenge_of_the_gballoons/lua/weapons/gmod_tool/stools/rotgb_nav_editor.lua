AddCSLuaFile()

TOOL.Category = "RotgB"
TOOL.Name = "#tool.rotgb_nav_editor.name"
TOOL.Information = {
	{name="left"},
	{name="right"},
	{name="reload"},
	{name="use"}
}
TOOL.AddToMenu = false

TOOL.BuildCPanel = function(form)
	if game.SinglePlayer() then
		form:Help("#tool.rotgb_nav_editor.desc")
		local label = form:Help("#tool.rotgb_nav_editor.singleplayer")
		label:SetTextColor(Color(255,0,0))
		form:ControlHelp("#tool.rotgb_nav_editor.rb655_easy_navedit.hint")
		form:Button("#tool.rotgb_nav_editor.rb655_easy_navedit.equip","gmod_tool","rb655_easy_navedit")
		local Button = form:Button("#tool.rotgb_nav_editor.rb655_easy_navedit.get")
		Button.DoClick = function() gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=527885257") end
	else
		local label = form:Help("#tool.rotgb_nav_editor.singleplayer")
		label:SetTextColor(Color(255,0,0))
	end
end

TOOL.EditorEnabled = function()
	return SERVER and (game.SinglePlayer() or GetConVar("sv_cheats"):GetBool())
end

TOOL.Deploy = function(self)
	if self:EditorEnabled() then
		game.ConsoleCommand("nav_edit 1\n")
	end
end

TOOL.Holster = function(self)
	if self:EditorEnabled() then
		game.ConsoleCommand("nav_edit 0\n")
	end
end

TOOL.LeftClick = function(self,trace)
	if self:EditorEnabled() then
		if self:GetOwner():KeyDown(IN_USE) then
			for k,v in pairs(navmesh.GetAllNavAreas()) do
				v:SetAttributes(bit.bor(v:GetAttributes(),NAV_MESH_AVOID))
			end
		else
			game.ConsoleCommand("nav_mark_attribute AVOID\n")
		end
	end
	return true
end

TOOL.RightClick = function(self,trace)
	if self:EditorEnabled() then
		if self:GetOwner():KeyDown(IN_USE) then
			for k,v in pairs(navmesh.GetAllNavAreas()) do
				v:SetAttributes(bit.band(v:GetAttributes(),bit.bnot(NAV_MESH_AVOID)))
			end
		else
			game.ConsoleCommand("nav_clear_attribute AVOID\n")
		end
	end
	return true
end

TOOL.Reload = function(self,trace)
	if self:EditorEnabled() then
		game.ConsoleCommand("nav_save\n")
	end
	return true
end