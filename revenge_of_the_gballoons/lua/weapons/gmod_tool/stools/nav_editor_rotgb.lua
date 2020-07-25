AddCSLuaFile()

TOOL.Category = "RotgB"
TOOL.Name = "#tool.nav_editor_rotgb.name"
TOOL.Information = {
	{name="left"},
	{name="right"},
	{name="reload"},
	{name="use"}
}
TOOL.AddToMenu = false

if CLIENT then
	language.Add("tool.nav_editor_rotgb.name","RotgB Avoidance Editor")
	language.Add("tool.nav_editor_rotgb.desc","Makes gBalloons avoid certain areas. Can be used to route gBalloons to use another path.")
	language.Add("tool.nav_editor_rotgb.left","Mark Area To Be Avoided")
	language.Add("tool.nav_editor_rotgb.right","Unmark Area To Be Avoided")
	language.Add("tool.nav_editor_rotgb.reload","Save NavMesh Changes")
	language.Add("tool.nav_editor_rotgb.use","While Held, LMB And RMB Affect ALL Areas")
end

TOOL.BuildCPanel = function(form)
	if game.SinglePlayer() then
		form:Help("#tool.nav_editor_rotgb.desc")
		local label = form:Help("This tool is only available in single player.")
		label:SetTextColor(Color(255,0,0))
		form:ControlHelp("NOTE: You can also mark the area to be avoided using the Easy Navmesh Editor by adding the AVOID attribute.")
		form:Button("Equip the Easy Navmesh Editor (if available)","gmod_tool","rb655_easy_navedit")
		local Button = form:Button("Get The Easy Navmesh Editor On Workshop")
		Button.DoClick = function() gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=527885257") end
	else
		local label = form:Help("This tool is only available in single player.")
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