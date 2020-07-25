AddCSLuaFile()

TOOL.Category = "Error Fixer"
TOOL.Name = "#tool.model_errfixer.name"
TOOL.ClientConVar = {
	old_model="",
	new_model="",
	sphere_radius=100,
	draw_sphere=1
}
TOOL.Information = {
	{name="left"},
	{name="right",op=1},
	{name="right_delete",op=2},
	{name="reload",op=1},
	{name="reload_delete",op=2}
}
TOOL.AddToMenu = false -- We'll do this ourselves.

if CLIENT then
	language.Add("tool.model_errfixer.name","Model Fixer")
	language.Add("tool.model_errfixer.desc","Replace ERROR models with functional ones")
	language.Add("tool.model_errfixer.left","Select ERROR Model")
	language.Add("tool.model_errfixer.right","Select New Model / Deselect")
	language.Add("tool.model_errfixer.right_delete","Select New Model")
	language.Add("tool.model_errfixer.reload","Replace ERROR Model With New Model")
	language.Add("tool.model_errfixer.reload_delete","Delete ERROR Model")
end

TOOL.BuildCPanel = function(form)
end

if CLIENT then
	concommand.Add("model_errfixer_info",function(ply,cmd,args,argStr)
		if not GetConVar(args[1]) then return end
		local model = GetConVar(args[1]):GetString()
		local function IsInHay(ref)
			for k,v in pairs(ref) do
				if string.find(model,v) then return true end
			end
			return false
		end
		local css = IsInHay({"props/cs_","props/de_","props_foliage"})
		local prt = IsInHay({"props_animsigns","props_bts","props_junk","props/"})
		local tf2 = IsInHay({"props_","models/pickups"}) and not IsInHay({"props/"})
		local hl2 = IsInHay({"\\humans","combine","props_c17"})
		local ep2 = IsInHay({"models/magnusson","props_silo","props_wasteland","strider_parts","magnade","props_hive"})
		local libdct = "an addon"
		if file.Exists(model,"MOD") then
			libdct = "base game"
		elseif tobool(ep2) then
			libdct = "Half-Life 2: Episode 2"
		elseif tobool(hl2) then
			libdct = "Half-Life 2"
		elseif tobool(css) then
			libdct = "Counter-Strike: Source"
		elseif tobool(prt) then
			libdct = "Portal"
		elseif tobool(tf2) then
			libdct = "Team Fortress 2 / Portal 2"
		end
		if CLIENT then
			chat.AddText(Color(0,255,255),"Model: "..model)
			chat.AddText(Color(0,255,255),"Probably from "..libdct.." (this is just an estimation, may be very wrong)")
		end
	end)
end

TOOL.DrawHUD = function(self)
	if tobool(self:GetClientInfo("draw_sphere")) then
		local sphrad = self:GetClientNumber("sphere_radius")
		if sphrad > 0 then
			local HitPos = LocalPlayer():GetEyeTrace().HitPos
			local cdelta = math.Remap(math.sin(RealTime()*2),-1,1,0,255)
			cam.Start3D()
			render.DrawWireframeSphere(HitPos,sphrad,16,16,Color(255,cdelta,cdelta,255),true)
			cam.End3D()
		end
	end
end

TOOL.Think = function(self)
	if self:GetClientInfo("new_model")=="" and self:GetOperation()~=2 then
		self:SetOperation(2)
	elseif self:GetClientInfo("new_model")~="" and self:GetOperation()~=1 then
		self:SetOperation(1)
	end
end

TOOL.LeftClick = function(self,trace)
	if GetConVar("model_errfixer_old_model") then
		for k,v in pairs(ents.FindInSphere(trace.HitPos,self:GetClientNumber("sphere_radius"))) do
			if (v.GetModel and v:GetModel() and v:GetModel():Left(1)~="*" and not util.IsValidModel(v:GetModel())) then
				RunConsoleCommand("model_errfixer_old_model",v:GetModel())
				return true
			end
		end
	end
end

TOOL.RightClick = function(self,trace)
	if GetConVar("model_errfixer_new_model") then
		local ent = trace.Entity
		if trace.HitWorld then
			RunConsoleCommand("model_errfixer_new_model","")
			return true
		elseif IsValid(ent) then
			if ent:GetClass()=="prop_effect" then
				ent = ent.AttachedEntity
			end
			if ent.GetModel then
				RunConsoleCommand("model_errfixer_new_model",ent:GetModel() or "")
				return true
			end
		end
	end
end

TOOL.Reload = function(self,trace)
	for k,v in pairs(ents.FindByModel(self:GetClientInfo("old_model"))) do
		if self:GetClientInfo("new_model")=="" then
			SafeRemoveEntity(v)
		elseif v.SetModel then
			v:SetModel(self:GetClientInfo("new_model"))
			v:SetMoveType(MOVETYPE_VPHYSICS)
			v:PhysicsInit(SOLID_VPHYSICS)
		end
	end
	return true
end