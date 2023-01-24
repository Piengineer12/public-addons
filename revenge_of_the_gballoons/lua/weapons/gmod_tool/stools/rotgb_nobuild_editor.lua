AddCSLuaFile()

TOOL.Category = "RotgB"
TOOL.Name = "#tool.rotgb_nobuild_editor.name"
TOOL.Information = {
	{name="left"},
	{name="right"},
	{name="reload"}
}
TOOL.ClientConVar = {
	scale = "1"
}
TOOL.AddToMenu = false

TOOL.LeftClick = function(self,trace)
	local ent = trace.Entity
	if ent:GetClass() == "prop_physics" then
		if SERVER then
			local nobuild = ents.Create("prop_rotgb_nobuild")
			nobuild:SetModel(ent:GetModel())
			nobuild:SetPos(ent:GetPos())
			nobuild:SetAngles(ent:GetAngles())
			nobuild:SetModelScale(tonumber(self:GetClientInfo("scale")) or 1)
			nobuild:Spawn()
			nobuild:Activate()
			ent:Remove()
		end
		
		return true
	end
end

TOOL.RightClick = function(self,trace)
	local ent = trace.Entity
	if ent:GetClass() == "prop_rotgb_nobuild" then
		if SERVER then
			local nobuild = ents.Create("prop_physics")
			nobuild:SetModel(ent:GetModel())
			nobuild:SetPos(ent:GetPos())
			nobuild:SetAngles(ent:GetAngles())
			nobuild:Spawn()
			ent:Remove()
		end
		
		return true
	end
end

TOOL.Reload = function(self,trace)
	if SERVER then
		for k,v in pairs(ents.FindByClass("prop_rotgb_nobuild")) do
			v:ToggleSolidity()
		end
	end
	
	return true
end