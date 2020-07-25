-- Pretty much everything here is dangerous. Possibly life-threatening.

local FIXED

local function FixAllErrors()
	if FIXED then return end
	
	local NIL = getmetatable(nil) or {}
	local NUMBER = getmetatable(0) or {}
	local STRING = getmetatable("")
	local VECTOR = FindMetaTable("Vector")
	local NULL_META = getmetatable(NULL)
	table.Merge(NIL,{
		__add = function(a,b)
			return a or b
		end,
		__sub = function(a,b)
			return a or b
		end,
		__mul = function(a,b)
			return a or b
		end,
		__div = function(a,b)
			return a
		end,
		__pow = function(a,b)
			if not b then return 1 else return 0 end
		end,
		__unm = function(a)
			return a
		end,
		__concat = function(a,b)
			return tostring(a) .. tostring(b)
		end,
		__len = function()
			return 0
		end,
		__lt = function(a,b)
			if isnumber(a) or isnumber(b) then
				return (a or 0) < (b or 0)
			else
				return tostring(a) < tostring(b)
			end
		end,
		__le = function(a,b)
			if isnumber(a) or isnumber(b) then
				return (a or 0) <= (b or 0)
			else
				return tostring(a) <= tostring(b)
			end
		end,
		__index = function()
		end,
		__newindex = function()
		end,
		__call = function()
		end
	})
	NUMBER.__lt = NIL.__lt
	NUMBER.__le = NIL.__le
	STRING.__lt = NIL.__lt
	STRING.__le = NIL.__le
	STRING.__add = function(a,b)
		return tostring(a)..tostring(b)
	end
	STRING.__concat = function(a,b)
		return tostring(a)..tostring(b)
	end
	STRING.IsValid = function()
		return true
	end
	local oldadd,oldsub = VECTOR.__add,VECTOR.__sub
	local oldmul,olddiv = VECTOR.__mul,VECTOR.__div
	VECTOR.__add = function(a,b)
		return oldadd(isvector(a) and a or Vector(a),isvector(b) and b or Vector(b))
	end
	VECTOR.__sub = function(a,b)
		return oldsub(isvector(a) and a or Vector(a),isvector(b) and b or Vector(b))
	end
	VECTOR.__mul = function(a,b)
		return oldmul(a or 1,b or 1)
	end
	VECTOR.__div = function(a,b)
		return olddiv(a or 1,b or 1)
	end
	local oldGC = NULL_META.GetClass
	NULL_META.GetClass = function(ent,...)
		if not IsValid(ent) then
			return ent.__tostring(ent,...)
		else return oldGC(ent,...)
		end
	end
	local oldPos = NULL_META.GetPos
	NULL_META.GetPos = function(ent,...)
		if not IsValid(ent) then
			return vector_origin
		else return oldPos(ent,...)
		end
	end
	--[[local oldindex = NULL_META.__index
	NULL_META.__index = function(ent,key)
		if rawget() then
			local args = {pcall(oldindex,ent,key)}
			if not args[1] then
				error("Attempt to call \""..key.."\" on a NULL entity (tell the owner of \"Lua and Model Error Fixers\" about it!)")
			end
		else return oldindex(ent,key)
		end
	end]]
	
	debug.setmetatable(nil,NIL)
	debug.setmetatable(0,NUMBER)
	
	FIXED = true
end

if SERVER then util.AddNetworkString("error_fixer_tool") end

local EnabledVar = CreateConVar("lua_errfixer_auto","1",FCVAR_ARCHIVE)

if CLIENT then
	concommand.Add("lua_errfixer_run",function(ply,cmd,args,str)
		FixAllErrors()
		net.Start("error_fixer_tool")
		net.SendToServer()
	end)
end

net.Receive("error_fixer_tool",function()
	FixAllErrors()
end)

hook.Add("AddToolMenuCategories","error_fixer_tool",function()
	spawnmenu.AddToolCategory("Main","error_fixers","Error Fixers")
end)

hook.Add("OnReloaded","error_fixer_tool",function()
	if FIXED and CLIENT then
		chat.AddText(Color(255,0,0),"Make sure to turn off the Lua Error Fixer first before editing any Lua files! Make sure Automatically Run On Initialization is disabled, then restart the map.")
	end
end)

hook.Add("PopulateToolMenu","error_fixer_tool",function()
	spawnmenu.AddToolMenuOption("Main","error_fixers","model_error_fixer","Model Error Fixer","gmod_tool model_errfixer","",function(DForm)
		DForm:Help("You can use Left Click to select an ERROR model, or you can input it manually.")
		DForm:TextEntry("ERROR Model","model_errfixer_old_model")
		DForm:Button("Get Info About ERROR Model","model_errfixer_info","model_errfixer_old_model")
		DForm:Help("You can use Right Click to select a model to use to replace the ERROR model, or you can input it manually.")
		DForm:Help("Right Click on the world to make this field blank. Leave this field blank if you wish to delete the ERROR model.")
		DForm:TextEntry("New Model","model_errfixer_new_model")
		DForm:Button("Get Info About New Model","model_errfixer_info","model_errfixer_new_model")
		DForm:Help("ERROR models can't be hit directly with a Tool Gun. This value determines the radius to check for ERROR models.")
		local NS = DForm:NumSlider("Sphere Radius","model_errfixer_sphere_radius",0,300)
		NS:SetDefaultValue(100)
		DForm:CheckBox("Draw Sphere","model_errfixer_draw_sphere")
	end)
	spawnmenu.AddToolMenuOption("Main","error_fixers","lua_error_fixer","Lua Error Fixer","","",function(DForm)
		local DLabel = DForm:Help("WARNING: If you are a Lua developer, make sure that this feature is OFF before testing your code! \z
		Otherwise, those who don't have this addon may receive numerous errors from your code!\n\n\z
		Note that this functionality might cause slight performance issues.")
		DLabel:SetTextColor(Color(255,0,0))
		DForm:Button("Loosen Lua Rules","lua_errfixer_run")
		DForm:CheckBox("Automatically Run On Initialization","lua_errfixer_auto")
	end)
end)

hook.Add("Initialize","error_fixer_tool",function()
	if EnabledVar:GetBool() then
		FixAllErrors()
	end
end)