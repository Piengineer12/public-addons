AddCSLuaFile()

TOOL.Category = "RotgB"
TOOL.Name = "#tool.rotgb_waypoint_editor.name"
TOOL.Information = {
	{name="left",op=1},
	{name="right",op=1},
	{name="reload",op=1},
	{name="left_2",op=2},
	{name="right_2",op=2},
	{name="left_3",op=3},
	{name="right_3",op=3},
	{name="reload_3",op=3}
}
TOOL.ClientConVar = {
	teleport = "0",
	weight = "0",
	indicator_effect = "sprites/glow04_noz",
	indicator_color = "6",
	indicator_scale = "1",
	indicator_speed = "1",
	indicator_always = "0",
	indicator_bounce = "1",
	indicator_r = "0",
	indicator_g = "0",
	indicator_b = "255",
	indicator_a = "255",
	indicator_boss_r = "255",
	indicator_boss_g = "0",
	indicator_boss_b = "0",
	indicator_boss_a = "255"
}
TOOL.AddToMenu = false

TOOL.BuildCPanel = function(form)
	form:Help("#tool.rotgb_waypoint_editor.desc")
	form:CheckBox("#rotgb.convar.rotgb_waypoint_editor_teleport.name","rotgb_waypoint_editor_teleport")
	form:NumSlider("#rotgb.convar.rotgb_waypoint_editor_weight.name","rotgb_waypoint_editor_weight",0,100,0)
	form:Help(ROTGB_LocalizeString("rotgb.convar.rotgb_waypoint_editor_weight.description"))
	form:CheckBox("#rotgb.convar.rotgb_waypoint_editor_indicator_always.name","rotgb_waypoint_editor_indicator_always")
	local choicelist = form:ComboBox("#rotgb.convar.rotgb_waypoint_editor_indicator_effect.name","rotgb_waypoint_editor_indicator_effect")
	choicelist:SetSortItems(false)
	choicelist:AddChoice("#rotgb.convar.rotgb_waypoint_editor_indicator_effect.sprites.glow04_noz","sprites/glow04_noz")
	choicelist:AddChoice("#rotgb.convar.rotgb_waypoint_editor_indicator_effect.sprites.light_ignorez","sprites/light_ignorez")
	choicelist:AddChoice("#rotgb.convar.rotgb_waypoint_editor_indicator_effect.sprites.physg_glow1","sprites/physg_glow1")
	choicelist:AddChoice("#rotgb.convar.rotgb_waypoint_editor_indicator_effect.sprites.physg_glow2","sprites/physg_glow2")
	choicelist:AddChoice("#rotgb.convar.rotgb_waypoint_editor_indicator_effect.sprites.sent_ball","sprites/sent_ball")
	choicelist:AddChoice("#rotgb.convar.rotgb_waypoint_editor_indicator_effect.effects.select_ring","effects/select_ring")
	choicelist:AddChoice("#rotgb.convar.rotgb_waypoint_editor_indicator_effect.effects.select_dot","effects/select_dot")
	choicelist:AddChoice("#rotgb.convar.rotgb_waypoint_editor_indicator_effect.gui.close_32","gui/close_32")
	choicelist:AddChoice("#rotgb.convar.rotgb_waypoint_editor_indicator_effect.icon16.circlecross.png","icon16/circlecross.png")
	choicelist:AddChoice("#rotgb.convar.rotgb_waypoint_editor_indicator_effect.gui.progress_cog.png","gui/progress_cog.png")
	form:NumSlider("#rotgb.convar.rotgb_waypoint_editor_indicator_scale.name","rotgb_waypoint_editor_indicator_scale",0,10)
	form:NumSlider("#rotgb.convar.rotgb_waypoint_editor_indicator_speed.name","rotgb_waypoint_editor_indicator_speed",0.1,10)
	form:CheckBox("#rotgb.convar.rotgb_waypoint_editor_indicator_bounce.name","rotgb_waypoint_editor_indicator_bounce")
	choicelist = form:ComboBox("#rotgb.convar.rotgb_waypoint_editor_indicator_color.name","rotgb_waypoint_editor_indicator_color")
	for i=0,11 do
		choicelist:AddChoice(string.format("#rotgb.convar.rotgb_waypoint_editor_indicator_color.%i", i), i)
	end
	local mixer = vgui.Create("DColorMixer")
	mixer:SetLabel("#rotgb.convar.rotgb_waypoint_editor_indicator_color.solid_selection")
	mixer:SetConVarR("rotgb_waypoint_editor_indicator_r")
	mixer:SetConVarG("rotgb_waypoint_editor_indicator_g")
	mixer:SetConVarB("rotgb_waypoint_editor_indicator_b")
	mixer:SetConVarA("rotgb_waypoint_editor_indicator_a")
	form:AddItem(mixer)
	mixer = vgui.Create("DColorMixer")
	mixer:SetLabel("#rotgb.convar.rotgb_waypoint_editor_indicator_color.solid_gblimp_selection")
	mixer:SetConVarR("rotgb_waypoint_editor_indicator_boss_r")
	mixer:SetConVarG("rotgb_waypoint_editor_indicator_boss_g")
	mixer:SetConVarB("rotgb_waypoint_editor_indicator_boss_b")
	mixer:SetConVarA("rotgb_waypoint_editor_indicator_boss_a")
	form:AddItem(mixer)
end

TOOL.Deploy = function(self)
	self:SetOperation(1)
end

TOOL.Holster = function(self)
	self:ClearObjects()
end

TOOL.IsValidStartPoint = function(self,ent)
	return IsValid(ent) and (ent:GetClass()=="gballoon_target" and ent:GetIsBeacon() or ent:GetClass()=="gballoon_spawner")
end

TOOL.IsValidEndPoint = function(self,ent)
	return IsValid(ent) and ent:GetClass()=="gballoon_target"
end

TOOL.GenerateNextTargetFunction = function(self,ent,func,blimp)
	local prefix = blimp and "GetNextBlimpTarget" or "GetNextTarget"
	for i=1,16 do
		local ret = func(ent[prefix..i](ent),i)
		if ret then return true end
	end
	if blimp=="both" then
		for i=1,16 do
			local ret = func(ent[string.format("GetNextTarget%i", i)](ent),i,true)
			if ret then return true end
		end
	end
end

TOOL.LeftClick = function(self,trace)
	if self:GetOperation()==1 then
		local ent = trace.Entity
		if self:IsValidStartPoint(ent) then
			return self:GenerateNextTargetFunction(ent,function(target)
				if not IsValid(target) then
					self:SetObject(1,ent,ent:GetPos(),nil,nil,vector_up)
					self:SetOperation(2)
					return true
				end
			end,"both")
		else
			if trace.Hit then
				if SERVER then
					local ent = ents.Create("gballoon_target")
					ent:SetPos(trace.HitPos+trace.HitNormal*5)
					ent:Spawn()
					ent:Activate()
					ent:SetIsBeacon(true)
					ent:SetTeleport(tobool(self:GetClientInfo("teleport")))
					ent:SetWeight(tonumber(self:GetClientInfo("weight")) or 0)
				end
				return true
			end
		end
	elseif self:GetOperation()==2 then
		local ent = trace.Entity
		local start = self:GetEnt(1)
		if self:IsValidEndPoint(ent) and self:IsValidStartPoint(start) and ent~=start then
			local placepos = 17
			if self:GetOwner():KeyDown(IN_DUCK) then
				if not self:GenerateNextTargetFunction(start,function(target,num)
					if not IsValid(target) then
						placepos = math.min(placepos,num)
					elseif target == ent then
						return true
					end
				end,true) then
					if placepos == 17 then
						ROTGB_CauseNotification("#tool.rotgb_waypoint_editor.max_16_waypoints.gblimp", self:GetOwner())
					else
						start[string.format("SetNextBlimpTarget%i", placepos)](start,ent)
						ent:SetTeleport(tobool(self:GetClientInfo("teleport")))
						self:ClearObjects()
						self:SetOperation(1)
						return true
					end
				end
			else
				if not self:GenerateNextTargetFunction(start,function(target,num)
					if not IsValid(target) then
						placepos = math.min(placepos,num)
					elseif target == ent then
						return true
					end
				end) then
					if placepos == 17 then
						ROTGB_CauseNotification("#tool.rotgb_waypoint_editor.max_16_waypoints", self:GetOwner())
					else
						start[string.format("SetNextTarget%i", placepos)](start,ent)
						ent:SetTeleport(tobool(self:GetClientInfo("teleport")))
						self:ClearObjects()
						self:SetOperation(1)
						return true
					end
				end
			end
		end
	elseif self:GetOperation()==3 then
		self:ClearObjects()
		self:SetOperation(1)
		return true
	end
end

TOOL.RightClick = function(self,trace)
	if self:GetOperation()==1 then
		local ent = trace.Entity
		if self:IsValidStartPoint(ent) then
			return self:GenerateNextTargetFunction(ent,function(target)
				if IsValid(target) then
					self:SetObject(1,ent,ent:GetPos(),nil,nil,vector_up)
					self:SetOperation(3)
					return true
				end
			end,"both")
		end
	elseif self:GetOperation()==2 then
		self:ClearObjects()
		self:SetOperation(1)
		return true
	elseif self:GetOperation()==3 then
		local ent = trace.Entity
		local start = self:GetEnt(1)
		if self:IsValidEndPoint(ent) and self:IsValidStartPoint(start) and ent~=start then
			return self:GenerateNextTargetFunction(start,function(target,num,nonblimp)
				if target == ent then
					start[string.format(nonblimp and "SetNextTarget%i" or "SetNextBlimpTarget%i", num)](start,NULL)
					self:ClearObjects()
					self:SetOperation(1)
					return true
				end
			end,"both")
		end
	end
end

TOOL.Reload = function(self,trace)
	if self:GetOperation()==3 then
		local start = self:GetEnt(1)
		if self:IsValidStartPoint(start) then
			self:GenerateNextTargetFunction(start,function(target,num)
				start[string.format("SetNextTarget%i", num)](start,NULL)
				start[string.format("SetNextBlimpTarget%i", num)](start,NULL)
			end)
			self:ClearObjects()
			self:SetOperation(1)
			return true
		end
	else
		local ent = trace.Entity
		if (self:IsValidEndPoint(ent) and ent:GetIsBeacon()) then
			if not gamemode.Call("CanProperty",ply,"remover",ent) then return false end
			if SERVER then
				constraint.RemoveAll(ent)
				ent:SetNotSolid(true)
				ent:SetMoveType(MOVETYPE_NONE)
				ent:SetNoDraw(true)
				local effdata = EffectData()
				effdata:SetEntity(ent)
				util.Effect("entity_remove",effdata,true,true)
				if IsValid(ply) then
					ply:SendLua("achievements.Remover()")
				end
				SafeRemoveEntityDelayed(ent,1)
			end
			return true
		end
	end
end

TOOL.UnpackColor = function(self,color)
	return color.r, color.g, color.b, color.a
end

TOOL.GetEColor = function(self,delta,nonblimp)
	local colmode = tonumber(self:GetClientInfo("indicator_color"))
	if colmode>=6 and colmode<=11 then
		if nonblimp then
			colmode = colmode - 6
		else
			colmode = colmode - (colmode>=9 and 9 or 3)
		end
	end
	if colmode==0 then
		return self:UnpackColor(HSVToColor(delta*360,1,1))
	elseif colmode==1 then
		local col = HSVToColor(delta*360,1,1)
		col.a = math.sin(delta*math.pi)*255
		return self:UnpackColor(col)
	elseif colmode==2 then
		local col = HSVToColor(delta*360,1,1)
		col.a = 255-math.sin(delta*math.pi)*255
		return self:UnpackColor(col)
	else
		local builtcolor
		if nonblimp then
			builtcolor = Color(self:GetClientInfo("indicator_r"),self:GetClientInfo("indicator_g"),self:GetClientInfo("indicator_b"),self:GetClientInfo("indicator_a"))
		else
			builtcolor = Color(self:GetClientInfo("indicator_boss_r"),self:GetClientInfo("indicator_boss_g"),self:GetClientInfo("indicator_boss_b"),self:GetClientInfo("indicator_boss_a"))
		end
		if colmode==4 then
			builtcolor.a = builtcolor.a*(math.sin(delta*math.pi))
		elseif colmode==5 then
			builtcolor.a = builtcolor.a*(1-math.sin(delta*math.pi))
		end
		return self:UnpackColor(builtcolor)
	end
end

local circlemat = {}
TOOL.DrawDedicatedHUD = function(self)
	local veccollection = {}
	cam.Start3D()
	for k,v in pairs(ents.GetAll()) do
		if self:IsValidStartPoint(v) then
			self:GenerateNextTargetFunction(v,function(dest,_,nonblimp)
				if IsValid(dest) then
					local zmul = (tobool(self:GetClientInfo("indicator_bounce")) and math.ceil or tonumber)(v:GetPos():Distance(dest:GetPos())/100/self:GetClientInfo("indicator_speed"))
					local offset = RealTime()*4%1/zmul
					while offset < 1 do
						local desvec = LerpVector(offset,v:GetPos(),dest:GetPos())
						local data = desvec:ToScreen()
						table.insert(veccollection,{
							data.visible,
							data.x,
							data.y,
							desvec:Distance(EyePos()),
							offset,
							nonblimp
						})
						offset = offset + 1/zmul
					end
				end
			end,"both")
		end
	end
	cam.End3D()
	local effect = self:GetClientInfo("indicator_effect")
	if not circlemat[effect] then
		circlemat[effect] = Material(effect)
	end
	surface.SetMaterial(circlemat[effect])
	for k,v in pairs(veccollection) do
		if v[1] then
			surface.SetDrawColor(self:GetEColor(v[5],v[6]))
			local size = 1/v[4]*30000*self:GetClientInfo("indicator_scale")
			surface.DrawTexturedRect(v[2]-size/2,v[3]-size/2,size,size)
		end
	end
	local ent = LocalPlayer():GetEyeTrace().Entity
	if (self:IsValidStartPoint(ent) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon().Mode=="rotgb_waypoint_editor") then
		AddWorldTip(nil,"#tool.rotgb_waypoint_editor.left.hint",nil,vector_origin,ent)
	end
end

TOOL.DrawHUD = function(self)
	if not tobool(self:GetClientInfo("indicator_always")) then
		self:DrawDedicatedHUD()
	end
end

hook.Add("HUDPaint","RotgB_waypoints",function()
	local TOOL = LocalPlayer():GetTool("rotgb_waypoint_editor")
	if (TOOL and GetConVar("rotgb_waypoint_editor_indicator_always"):GetBool()) then
		TOOL:DrawDedicatedHUD()
	end
end)