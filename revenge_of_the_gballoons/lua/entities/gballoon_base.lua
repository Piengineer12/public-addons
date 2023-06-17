AddCSLuaFile()

local base_nextbot = baseclass.Get("base_nextbot")
ENT.PrintName = "gBalloon"
ENT.Category = "#rotgb.category.gballoon"
-- ENT.ScriptedEntityType = "entity"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.gballoon.purpose"
ENT.Instructions = "#rotgb.gballoon.instructions"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Editable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.DisableDuplicator = false
ENT.rotgb_rbetab = {
	gballoon_red=1,
	gballoon_blue=2,
	gballoon_green=3,
	gballoon_yellow=4,
	gballoon_pink=5,
	gballoon_black=11,
	gballoon_white=11,
	gballoon_purple=11,
	gballoon_orange=11,
	gballoon_zebra=23,
	gballoon_gray=23,
	gballoon_aqua=23,
	gballoon_error=23,
	gballoon_rainbow=93,
	gballoon_ceramic=196,
	gballoon_brick=427,
	gballoon_marble=974,
	
	gballoon_blimp_blue=984,
	gballoon_blimp_red=4636,
	gballoon_blimp_green=22544,
	gballoon_blimp_gray=4296,
	gballoon_blimp_purple=73680,
	gballoon_blimp_magenta=18684,
	gballoon_blimp_rainbow=284727,
	
	gballoon_glass=1,
	gballoon_void=1,
	gballoon_cfiber=999999999,
	gballoon_hidden=11,
	
	gballoon_melon=1000,
	gballoon_melon_super=20000,
	gballoon_mossman=5000,
	gballoon_mossman_super=100000,
	gballoon_gman=25000,
	gballoon_gman_super=500000,
	gballoon_blimp_ggos=103928,
	gballoon_blimp_ggos_super=2007856,
	gballoon_hot_air=500000,
	gballoon_hot_air_super=10000000,
	gballoon_blimp_long_rainbow=2.5e6,
	gballoon_blimp_long_rainbow_super=50e6,
	gballoon_garrydecal=10e6,
	gballoon_garrydecal_super=200e6
}
ENT.rotgb_spawns = {
	gballoon_blue={gballoon_red=1},
	gballoon_green={gballoon_blue=1},
	gballoon_yellow={gballoon_green=1},
	gballoon_pink={gballoon_yellow=1},
	gballoon_black={gballoon_pink=2},
	gballoon_white={gballoon_pink=2},
	gballoon_purple={gballoon_pink=2},
	gballoon_orange={gballoon_pink=2},
	gballoon_gray={gballoon_black=2},
	gballoon_zebra={gballoon_white=2},
	gballoon_aqua={gballoon_white=2},
	gballoon_error={gballoon_purple=1,gballoon_orange=1},
	gballoon_rainbow={gballoon_gray=1,gballoon_zebra=1,gballoon_aqua=1,gballoon_error=1},
	gballoon_ceramic={gballoon_rainbow=2},
	gballoon_brick={gballoon_ceramic=2},
	gballoon_marble={gballoon_brick=2},
	
	gballoon_blimp_blue={gballoon_ceramic=4},
	gballoon_blimp_red={gballoon_blimp_blue=4},
	gballoon_blimp_green={gballoon_blimp_red=4},
	gballoon_blimp_gray={gballoon_marble=4},
	gballoon_blimp_purple={gballoon_blimp_green=2,gballoon_hidden_regen_blimp_gray=2},
	gballoon_blimp_magenta={gballoon_hidden_regen_blimp_gray=4},
	gballoon_blimp_rainbow={gballoon_blimp_purple=2,gballoon_fast_blimp_magenta=2},
	
	gballoon_hidden={gballoon_pink=2},
	
	gballoon_blimp_ggos={gballoon_marble=4},
	gballoon_blimp_ggos_super={gballoon_fast_hidden_regen_shielded_marble=4},
}

function ENT:Log(message,attrib)
	ROTGB_EntityLog(self,message,attrib)
end

function ENT:LogError(message,attrib)
	ROTGB_EntityLogError(self,message,attrib)
end

local entitiestoconsider = {}
local savedKeyValueTables = {}
local registeredBossEffects = {}

function ENT:KeyValue(key,value)
	self.Properties = self.Properties or {}
	self.Properties[key] = value
end

function ENT:AcceptInput(input,activator,caller,data)
	if input:lower()=="pop" then
		self:Pop(data or 0)
	elseif input:lower()=="stun" then
		self:Stun(data or 1)
	elseif input:lower()=="unstun" then
		self:UnStun()
	elseif input:lower()=="freeze" then
		self:Freeze(data or 1)
	elseif input:lower()=="unfreeze" then
		self:UnFreeze()
	end
end

function ENT:SetBalloonProperty(key, value)
	if self.Properties[key] ~= value then
		self.Properties[key] = value
		self:ApplyBalloonProperty(key, value)
	end
end

function ENT:GetBalloonProperty(key)
	self.Properties = self.Properties or {}
	if not self.PropertyConverted then
		self:ConvertProperties()
	end
	return tonumber(self.Properties[key]) or self.Properties[key]
end

function ENT:ConvertProperties()
	local useLegacy = ROTGB_GetConVarValue("rotgb_legacy_gballoons")
	local noTrails = ROTGB_GetConVarValue("rotgb_notrails")
	self.Properties.BalloonFast = tobool(self.Properties.BalloonFast)
	self.Properties.BalloonMoveSpeed = self.Properties.BalloonMoveSpeed or 100
	self.Properties.BalloonScale = self.Properties.BalloonScale or 1
	self.Properties.BalloonShielded = tobool(self.Properties.BalloonShielded)
	self.Properties.BalloonHealth = self.Properties.BalloonHealth or 1
	self.Properties.BalloonRainbow = tobool(self.Properties.BalloonRainbow)
	self.Properties.BalloonHidden = tobool(self.Properties.BalloonHidden)
	self.Properties.BalloonColor = self.Properties.BalloonColor or "255 255 255 127"
	self.Properties.BalloonMaterial = self.Properties.BalloonMaterial
		or useLegacy and self.Properties.BalloonShielded and "models/balloon/balloon_star"
		or self.Properties.BalloonRegen and "models/balloon/balloon_classicheart"
		or (useLegacy or noTrails) and self.Properties.BalloonFast and "models/balloon/balloon_dog"
		or "maxofs2d/models/balloon_classic_01"
	self.Properties.BalloonModel = self.Properties.BalloonModel
		or useLegacy and self.Properties.BalloonShielded and "models/balloons/balloon_star.mdl"
		or self.Properties.BalloonRegen and "models/balloons/balloon_classicheart.mdl"
		or (useLegacy or noTrails) and self.Properties.BalloonFast and "models/balloons/balloon_dog.mdl"
		or "models/maxofs2d/balloon_classic.mdl"
	self.Properties.BalloonPopSound = self.Properties.BalloonPopSound or "garrysmod/balloon_pop_cute.wav"
	self.Properties.BalloonType = self.Properties.BalloonType or "gballoon_red"
	self.Properties.BalloonBlack = tobool(self.Properties.BalloonBlack)
	self.Properties.BalloonWhite = tobool(self.Properties.BalloonWhite)
	self.Properties.BalloonPurple = tobool(self.Properties.BalloonPurple)
	self.Properties.BalloonGray = tobool(self.Properties.BalloonGray)
	self.Properties.BalloonAqua = tobool(self.Properties.BalloonAqua)
	self.Properties.BalloonBlimp = tobool(self.Properties.BalloonBlimp)
	self.Properties.BalloonRegen = tobool(self.Properties.BalloonRegen)
	self.Properties.BalloonVoid = tobool(self.Properties.BalloonVoid)
	self.Properties.BalloonGlass = tobool(self.Properties.BalloonGlass)
	self.Properties.BalloonCashBonus = self.Properties.BalloonCashBonus or 0
	self.Properties.BalloonBoss = tobool(self.Properties.BalloonBoss)
	self.Properties.BalloonHealthSegments = self.Properties.BalloonHealthSegments or 1
	self.Properties.BalloonBossEffect = self.Properties.BalloonBossEffect or ""
	self.Properties.BalloonSuperRegen = self.Properties.BalloonSuperRegen or 0
	self.Properties.BalloonArmor = self.Properties.BalloonArmor or 0
	
	self.PropertyConverted = true
end

function ENT:ApplyBalloonProperty(key, value)
	if not value then
		value = self:GetBalloonProperty(key)
	end
	local useOldStyle = ROTGB_GetConVarValue("rotgb_legacy_gballoons") and not ROTGB_GetConVarValue("rotgb_pertain_effects")
	
	if key == "BalloonModel" then
		self:SetModel(value)
	elseif key == "BalloonScale" then
		self:SetModelScale(value*ROTGB_GetConVarValue("rotgb_scale"))
	elseif key == "BalloonColor" then
		local desiredCol = string.ToColor(self:GetBalloonProperty("BalloonColor"))
		if self:GetBalloonProperty("BalloonHidden") then
			desiredCol.a = 0
		end
		self:SetColor(desiredCol)
		if IsValid(self.FastTrail) then
			self:RebuildFastTrail()
		end
	elseif key == "BalloonHidden" then
		self:SetNWBool("BalloonHidden",value)
		if value then
			local desiredCol = self:GetColor()
			desiredCol.a = 0
			self:SetColor(desiredCol)
			self:SetRenderFX(kRenderFxHologram)
		else
			self:SetColor(string.ToColor(self:GetBalloonProperty("BalloonColor")))
			self:SetRenderFX(kRenderFxNone)
		end
		if IsValid(self.FastTrail) then
			self:RebuildFastTrail()
		end
	elseif key == "BalloonMaterial" then
		self:SetMaterial(value)
	elseif key == "BalloonHealth" then
		local hp = value
		*(self.OldBalloonShielded and 2 or 1)
		*(self:GetBalloonProperty("BalloonBlimp") and ROTGB_GetConVarValue("rotgb_blimp_health_multiplier") or 1)
		*ROTGB_GetConVarValue("rotgb_health_multiplier")
		hp = hook.Run("GetgBalloonHealth", self:GetBalloonProperty("BalloonType"), hp) or hp
		
		self:SetHealth(hp)
		self:SetMaxHealth(hp)
		if self:GetBalloonProperty("BalloonBoss") then
			self:SetStatusSendRequired(true)
		end
	elseif key == "BalloonShielded" and self.OldBalloonShielded ~= value then
		self.OldBalloonShielded = value
		self:SetHealth(self:Health() * (value and 2 or 0.5))
		self:SetMaxHealth(self:GetMaxHealth() * (value and 2 or 0.5))
		self:SetNWBool("RenderShield", value and not useOldStyle)
		if self:GetBalloonProperty("BalloonBoss") then
			self:SetStatusSendRequired(true)
		end
	elseif key == "BalloonPurple" and not (useOldStyle or self:GetBalloonProperty("BalloonHidden")) then
		self:SetNWBool("BalloonPurple",value)
	elseif key == "BalloonRainbow" then
		self:SetNWBool("BalloonRainbow",value)
	elseif key == "BalloonFast" then
		if value then
			self:Slowdown("BalloonFast",2,9999)
			if not (useOldStyle or ROTGB_GetConVarValue("rotgb_notrails")) then
				self:RebuildFastTrail()
			end
		else
			self:UnSlowdown("BalloonFast")
			if IsValid(self.FastTrail) then
				self.FastTrail:Remove()
			end
		end
	elseif key == "BalloonBoss" and value then
		self:SetStatusSendRequired(true)
	end
end

-- applies all properties at once, far more efficient than calling the above for each property
-- should be able to be invoked multiple times without causing errors
function ENT:ApplyAllBalloonProperties()
	self:ConvertProperties()
	local useOldStyle = ROTGB_GetConVarValue("rotgb_legacy_gballoons") and not ROTGB_GetConVarValue("rotgb_pertain_effects")
	
	self:SetModel(self:GetBalloonProperty("BalloonModel"))
	self:SetModelScale(self:GetBalloonProperty("BalloonScale")*ROTGB_GetConVarValue("rotgb_scale"))
	self:SetMaterial(self:GetBalloonProperty("BalloonMaterial"))
	local desiredCol = string.ToColor(self:GetBalloonProperty("BalloonColor"))
	if self:GetBalloonProperty("BalloonHidden") then
		desiredCol.a = 0
		self:SetNWBool("BalloonHidden",true)
		self:SetRenderFX(kRenderFxHologram)
	end
	self:SetColor(desiredCol)
	
	local hp = self:GetBalloonProperty("BalloonHealth")
	*(self:GetBalloonProperty("BalloonBlimp") and ROTGB_GetConVarValue("rotgb_blimp_health_multiplier") or 1)
	*ROTGB_GetConVarValue("rotgb_health_multiplier")
	
	if self:GetBalloonProperty("BalloonShielded") then
		self.OldBalloonShielded = true
		hp = hp * 2
		self:SetNWBool("RenderShield", true)
	end
	hp = hook.Run("GetgBalloonHealth", self:GetBalloonProperty("BalloonType"), hp) or hp
	
	self:SetHealth(hp)
	self:SetMaxHealth(hp)
	if self:GetBalloonProperty("BalloonBoss") then
		self:SetStatusSendRequired(true)
	end
	
	if self:GetBalloonProperty("BalloonPurple") and not (useOldStyle or self:GetBalloonProperty("BalloonHidden")) then
		self:SetNWBool("BalloonPurple",true)
	end
	if self:GetBalloonProperty("BalloonRainbow") then
		self:SetNWBool("BalloonRainbow",true)
	end
	
	if self:GetBalloonProperty("BalloonFast") then 
		self:Slowdown("BalloonFast",2,9999)
		if not (useOldStyle or ROTGB_GetConVarValue("rotgb_notrails")) then
			self:RebuildFastTrail()
		end
	else
		if IsValid(self.FastTrail) then
			self.FastTrail:Remove()
		end
		self:UnSlowdown("BalloonFast")
	end
end

function ENT:RebuildFastTrail()
	if IsValid(self.FastTrail) then self.FastTrail:Remove() end
	local col = string.ToColor(self:GetBalloonProperty("BalloonColor"))
	col.a = self:GetBalloonProperty("BalloonHidden") and col.a/4 or col.a
	self.FastTrail = util.SpriteTrail(self,0,col,false,self:BoundingRadius()*2,0,1,0.125,self:GetBalloonProperty("BalloonRainbow") and "beams/rainbow1.vmt" or "effects/beam_generic01.vmt")
end

function ENT:SpawnFunction(ply,trace,classname)
	if not trace.Hit then return end

	local ent = ents.Create(classname)
	ent:SetPos(trace.HitPos+self:GetBalloonProperty("BalloonScale")*10*trace.HitNormal)
	ent:SetCreator(ply)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:RegistergBalloon()
	ROTGB_GBALLOONS[self:EntIndex()] = self
end

function ROTGB_GetBalloons()
	for k,v in pairs(ROTGB_GBALLOONS) do
		if not IsValid(v) then ROTGB_GBALLOONS[k] = nil end
	end
	return table.ClearKeys(ROTGB_GBALLOONS)
end

function ROTGB_GetBalloonCount()
	for k,v in pairs(ROTGB_GBALLOONS) do
		if not IsValid(v) then ROTGB_GBALLOONS[k] = nil end
	end
	return table.Count(ROTGB_GBALLOONS)
end

function ROTGB_BalloonsExist()
	for k,v in pairs(ROTGB_GBALLOONS) do
		if IsValid(v) then return true
		else
			ROTGB_GBALLOONS[k] = nil
		end
	end
end

--local notifshown

if SERVER then
	AccessorFunc(ENT, "StatusSendRequired", "StatusSendRequired", FORCE_BOOL)
end

function ENT:CurTime()
	self.rotgb_PhasedTime = self.rotgb_PhasedTime or 0
	return CurTime() - self.rotgb_PhasedTime
end

function ENT:Initialize()
	self.Properties = self.Properties or {}
	self:RegistergBalloon()
	if SERVER then
		hook.Run("gBalloonKeyValuesApply", self.Properties)
		local failslist
		for k,v in pairs(ROTGB_BLACKLIST) do
			if v[1] == "gballoon_*" or self:GetBalloonProperty("BalloonBlimp") and v[1] == "gballoon_blimp_*" or self:GetBalloonProperty("BalloonType") == v[1] then
				local bitcondition = Either(self:GetBalloonProperty("BalloonFast"), ROTGB_HasAllBits(v[2],1), ROTGB_HasAllBits(v[2],2))
				bitcondition = bitcondition or Either(self:GetBalloonProperty("BalloonHidden"), ROTGB_HasAllBits(v[2],4), ROTGB_HasAllBits(v[2],8))
				bitcondition = bitcondition or Either(self:GetBalloonProperty("BalloonRegen"), ROTGB_HasAllBits(v[2],16), ROTGB_HasAllBits(v[2],32))
				bitcondition = bitcondition or Either(self:GetBalloonProperty("BalloonShielded"), ROTGB_HasAllBits(v[2],64), ROTGB_HasAllBits(v[2],128))
				
				if bitcondition then
					failslist = true
				end
			end
		end
		if failslist then
			for k,v in pairs(ROTGB_WHITELIST) do
				if v[1] == "gballoon_*" or self:GetBalloonProperty("BalloonBlimp") and v[1] == "gballoon_blimp_*" or self:GetBalloonProperty("BalloonType") == v[1] then
					local bitcondition = Either(self:GetBalloonProperty("BalloonFast"), ROTGB_HasAllBits(v[2],1), ROTGB_HasAllBits(v[2],2))
					bitcondition = bitcondition or Either(self:GetBalloonProperty("BalloonHidden"), ROTGB_HasAllBits(v[2],4), ROTGB_HasAllBits(v[2],8))
					bitcondition = bitcondition or Either(self:GetBalloonProperty("BalloonRegen"), ROTGB_HasAllBits(v[2],16), ROTGB_HasAllBits(v[2],32))
					bitcondition = bitcondition or Either(self:GetBalloonProperty("BalloonShielded"), ROTGB_HasAllBits(v[2],64), ROTGB_HasAllBits(v[2],128))
					
					if bitcondition then
						failslist = false
					end
				end
			end
			if failslist then
				return self:Remove()
			end
		end
		--[[if not (navmesh.IsLoaded() or notifshown) and game.SinglePlayer() then
			ROTGB_CauseNotification(ROTGB_NOTIFY_NAVMESHMISSING, ROTGB_NOTIFYTYPE_ERROR)
			notifshown = true
		end]]
		hook.Run("gBalloonPreInitialize", self)
		
		self:ApplyAllBalloonProperties()
		
		local difficultySpeedModifier = 1 + (ROTGB_GetConVarValue("rotgb_difficulty") - 1)/10
		self:Slowdown("rotgb_difficulty",difficultySpeedModifier,9999)
		
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetBloodColor(ROTGB_GetConVarValue("rotgb_bloodtype")<7 and ROTGB_GetConVarValue("rotgb_bloodtype") or DONT_BLEED)
		local mask = ROTGB_GetConVarValue("rotgb_target_choice")
		for k,v in pairs(ents.GetAll()) do
			if v:IsNPC() then
				if mask<0 and v:Health()>0 and v:GetClass()~="gballoon_base" then
					v:AddEntityRelationship(self,D_HT,99)
				elseif self:MaskFilter(mask,v) then
					v:AddEntityRelationship(self,D_HT,99)
				end
			end
		end
		self:AddFlags(FL_OBJECT)
		local physobj = self:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:AddGameFlag(FVPHYSICS_CONSTRAINT_STATIC)
		end
		self.BuffIdentifiers = {}
		hook.Run("gBalloonPostInitialize", self)
		--self.BeaconsReached = {}
	end
	if CLIENT then
		local matrix = Matrix()
		self.VModelScale = Vector(1,1,1)
		self.VModelScale:Mul(ROTGB_GetConVarValue("rotgb_visual_scale"))
		matrix:Scale(self.VModelScale)
		self:EnableMatrix("RenderMultiply",matrix)
	end
end

function ENT:PreEntityCopy()
	self.rotgb_DuplicatorTimeOffset = CurTime()
	-- the duplicator system will incorrectly assign self.loco on the new entity to *this* entity
	self.ourLoco = self.loco
	self.loco = nil
end

function ENT:PostEntityCopy()
	self.loco = self.ourLoco
end

function ENT:PostEntityPaste(ply,ent,tab)
	self.rotgb_PhasedTime = (self.rotgb_PhasedTime or 0) + CurTime() - (self.rotgb_DuplicatorTimeOffset or CurTime())
	self:ApplyAllBalloonProperties()
end

--[=[start of custom pathfinding

local MAX_CORNER_DISTANCE = 64

function ENT:GenerateDotsFromArea(area)
	-- Generates a vector table, a corners table and an attributes number from a CNavArea.
	local vectors, corners = {}, {}
	table.insert(vectors, area:GetCenter())
	for i=0,3 do
		table.insert(vectors, area:GetCorner(i))
		table.insert(corners, area:GetCorner(i))
	end
	-- table has 1+4
	for i=2,5 do
		if i==5 then
			table.insert(vectors, (vectors[5] + vectors[2])/2)
		else
			table.insert(vectors, (vectors[i] + vectors[i+1])/2)
		end
	end
	-- table has 1+4+4
	local maxcornerdist_sqr, corner_dist_sqr = MAX_CORNER_DISTANCE*MAX_CORNER_DISTANCE
	if IsValid(area) then -- it is rectangular
		corner_dist_sqr = vectors[1]:DistToSqr(vectors[2])
	else
		for i=2,5 do
			corner_dist_sqr = math.max( corner_dist_sqr, vectors[1]:DistToSqr(vector[i]) )
		end
	end
	if corner_dist_sqr>maxcornerdist_sqr then
		local partitions = math.ceil( math.sqrt(corner_dist_sqr/maxcornerdist_sqr) )
		for i=2,9 do
			for j=1,partitions-1 do
				table.insert(vectors, ((partitions-j)*vectors[1] + j*vectors[i])/partitions)
			end
		end
	end
	return vectors, corners, area:GetAttributes()
end

function ENT:MakeDotStruct(dotstoattribs,dotsfrom,dotsto)
	local dotstruct = {}
	if not dotsto then dotsto = dotsfrom end
	for k,v in pairs(dotsfrom) do
		dotstruct[v] = {}
		for k2,v2 in pairs(dotsto) do
			if v ~= v2 then
				dotstruct[v][v2] = {v:Distance(v2),dotstoattribs}
			end
		end
	end
	return dotstruct
end

function ENT:GetVectorsOnBorder(vecs,corners)
	local dirs = {}
	local newvectors = {}
	for i=1,4 do
		local newvec
		if i==4 then
			newvec = corners[4] - corners[1]
			newvec:Normalize()
		else
			newvec = corners[i] - corners[i+1]
			newvec:Normalize()
		end
		table.insert(dirs, newvec)
		table.insert(dirs, -newvec)
	end
	for k,v in pairs(vecs) do
		for i=1,7,2 do
			local dir = v - corners[(i+1)/2]
			dir:Normalize()
			if dir == dirs[i] then
				if i==7 then
					dir = v - corners[1]
				else
					dir = v - corners[(i+3)/2]
				end
				dir:Normalize()
				if dir == dirs[i+1] then
					table.insert(newvectors, v)
				end
			end
		end
	end
	return newvectors
end

function ENT:GetClosestVectorPair(dotstruct1,dotstruct2)
	local data = {}
	for vec,_ in pairs(dotstruct1) do
		for vec2,_ in pairs(dotstruct2) do
			if vec ~= vec2 then
				table.insert(data, {vec,vec2,vec:DistToSqr(vec2)})
			end
		end
	end
	table.SortByMember(data, 3, true)
	return data[1][1], data[1][2]
end

function ENT:BuildDotMesh()
	dotmeshes, dotmesh = {}, {}
	local navspecificmeshes = {}
	local navspecificcorners = {}
	for k,v in pairs(navmesh.GetAllNavAreas()) do
		local vectors, corners, attribs = self:GenerateDotsFromArea(v)
		navspecificmeshes[v:GetID()] = self:MakeDotStruct(attribs, vectors)
		navspecificcorners[v:GetID()] = corners
		table.insert(dotmeshes, navspecificmeshes[v:GetID()])
	end
	for k,v in pairs(navmesh.GetAllNavAreas()) do
		for k2,v2 in pairs(v:GetAdjacentAreas()) do
			local directjoinvectors = self:GetVectorsOnBorder(table.GetKeys(navspecificmeshes[v:GetID()]), navspecificcorners[v2:GetID()])
			if table.IsEmpty(directjoinvectors) then
				local dot1, dot2 = self:GetClosestVectorPair(navspecificmeshes[v:GetID()], navspecificmeshes[v2:GetID()])
				table.insert(dotmeshes, self:MakeDotStruct(v2:GetAttributes(), {dot1}, {dot2}))
			else
				table.insert(dotmeshes, self:MakeDotStruct(v2:GetAttributes(), directjoinvectors, navspecificmeshes[v2:GetID()]))
			end
		end
	end
	for k,v in pairs(dotmeshes) do
		table.Merge(dotmesh,v)
	end
	return dotmesh
end

function ENT:CreatePathFromPrecedents(pathPrecedents, pathProperties, last)
	local path_points = {}
	table.insert(path_points, last)
	while pathPrecedents[last] do
		local next_node = pathPrecedents[last]
		pathPrecedents[last] = nil
		table.insert(path_points, next_node)
		last = next_node
	end
	path_points = table.Reverse(path_points)
	path_points.checks = pathProperties
	return path_points
end

local NAV_MESH_PREFER = 1048576
function ENT:CalculatePath(dotmesh,first,last)
	local pathPrecedents, pathBlocks = {}, {}
	local distancecosts,totalcosts = {[first]=0},{[first]=first:DistToSqr(last)}
	local openSet = {[first]=-totalcosts[first]}
	local supptab = {}
	while next(openSet) do
		local current = table.GetWinningKey(openSet)
		openSet[current] = nil
		if current == last then
			return self:CreatePathFromPrecedents(pathPrecedents, pathBlocks, last)
		else
			for k,v in pairs(dotmesh[current] or {}) do
				local distancecost = v[1]
				if pathBlocks[k]~=NAV_MESH_TRANSIENT and bit.band(v[2],bit.bor(NAV_MESH_TRANSIENT,NAV_MESH_HAS_ELEVATOR))~=0 then
					util.TraceLine({
						start = k,
						endpos = k+vector_up*self:BoundingRadius(),
						filter = self,
						mask = MASK_NPCSOLID,
						ignoreworld = true,
						output = supptab
					})
					if supptab.Hit then
						pathBlocks[k] = NAV_MESH_TRANSIENT
						continue
					end
				end
				if bit.band(v[2],bit.bor(NAV_MESH_AVOID))~=0 then
					distancecost = distancecost * 1e6
				end
				for k2,v2 in pairs(entitiestoconsider) do
					if IsValid(k2) then
						self:Log(tostring(k2).." sensed. Position: "..tostring(k)..", Vector1:"..tostring(v2[1])..", Vector2:"..tostring(v2[2])..", InPosition="..tostring(pos:WithinAABox(v2[1],v2[2])),"func_nav_detection")
						if k:WithinAABox(v2[1],v2[2]) and k2.Enabled then
							if k2:GetClass()=="func_nav_avoid" then
								distancecost = distancecost * 1e6
								pathBlocks[k] = NAV_MESH_AVOID
								self:Log("Detected "..tostring(k2).." and avoiding, cost to cross is now "..distancecost,"func_nav_detection") break
							elseif k2:GetClass()=="func_nav_prefer" then
								distancecost = distancecost * 1e-6
								pathBlocks[k] = NAV_MESH_PREFER
								self:Log("Detected "..tostring(k2).." and preferring, cost to cross is now "..distancecost,"func_nav_detection") break
							end
						end
					else
						entitiestoconsider[k2] = nil
					end
				end
				local totaldistancecost = distancecosts[current] + distancecost
				if not (distancecosts[k] and totaldistancecost >= distancecosts[k]) then
					pathPrecedents[k] = current
					--pathProperties[k] = v[2]
					distancecosts[k] = totaldistancecost
					totalcosts[k] = totaldistancecost + k:DistToSqr(last)
					openSet[k] = -totalcosts[k]
				end
			end
		end
	end
	return {checks=pathBlocks}
end

function ENT:BlocksStillPresent(navs_to_check)
	for vec,property in pairs(navs_to_check) do
		if property == NAV_MESH_TRANSIENT then
			util.TraceLine({
				start = vec,
				endpos = vec+vector_up*self:BoundingRadius(),
				filter = self,
				mask = MASK_NPCSOLID,
				ignoreworld = true,
				output = supptab
			})
			if not supptab.Hit then return false end
		elseif property == NAV_MESH_AVOID or property == NAV_MESH_PREFER then
			for k2,v2 in pairs(entitiestoconsider) do
				if (IsValid(k2) and k2.Enabled) then
					if vec:WithinAABox(v2[1],v2[2]) then
						if k2:GetClass()=="func_nav_avoid" and property==NAV_MESH_AVOID then break
						elseif k2:GetClass()=="func_nav_prefer" and property==NAV_MESH_PREFER then break
						else return false
						end
					end
				else
					if not IsValid(k2) then
						entitiestoconsider[k2] = nil
					end
					return false
				end
			end
		end
	end
	return true
end

function ENT:CopyPathCarbon(original_path)
	local new_path = {}
	for i,v in ipairs(original_path) do
		new_path[i] = v
	end
	return new_path
end

function ENT:GetSavedPath(actualfirst,actuallast)
	return ((ROTGB_SAVEDPATHS or {})[actualfirst] or {})[actuallast]
end

function ENT:SavePath(new_path,actualfirst,actuallast)
	ROTGB_SAVEDPATHS = ROTGB_SAVEDPATHS or {}
	ROTGB_SAVEDPATHS[actualfirst] = ROTGB_SAVEDPATHS[actualfirst] or {}
	ROTGB_SAVEDPATHS[actualfirst][actuallast] = new_path
end

function ENT:GeneratePath(dotmesh,first,last)
	local actualfirst, min_distance = first, math.huge
	for k,v in pairs(dotmesh) do
		if k:DistToSqr(first) < min_distance then
			min_distance = k:DistToSqr(first)
			actualfirst = k
		end
	end
	min_distance = math.huge
	local actuallast = last
	for k,v in pairs(dotmesh) do
		if k:DistToSqr(last) < min_distance then
			min_distance = k:DistToSqr(last)
			actuallast = k
		end
	end
	local saved_path = self:GetSavedPath(actualfirst,actuallast)
	if saved_path and self:BlocksStillPresent(saved_path.checks) then
		self.GeneratedPath = self:CopyPathCarbon(saved_path)
		self.GeneratedPathTimestamp = self:CurTime()
	else
		local new_path = self:CalculatePath(dotmesh,actualfirst,actuallast)
		self:SavePath(new_path,actualfirst,actuallast)
		self.GeneratedPath = self:CopyPathCarbon(new_path)
		self.GeneratedPathTimestamp = self:CurTime()
	end
end

function ENT:InchCloser()
	if self:GetPos():DistToSqr(self.GeneratedPath[1]) < MAX_CORNER_DISTANCE*MAX_CORNER_DISTANCE then
		table.remove(self.GeneratedPath,1)
		if table.IsEmpty(self.GeneratedPath) then
			self.GeneratedPath = nil return
		end
	end
	local movdir = self.GeneratedPath[1]-self:GetPos()
	movdir:Normalize()
	self.loco:Approach(self.GeneratedPath[1],1)
	self.loco:SetVelocity(movdir*self.DesiredSpeed)
end

function ENT:MoveToTargetNew()
	--coroutine.wait(0.05*ROTGB_GetConVarValue("rotgb_path_delay")*ROTGB_GetBalloonCount())
	--[[local path = Path("Chase")
	local position = self:GetTarget():GetPos()
	path:SetGoalTolerance(ROTGB_GetConVarValue("rotgb_target_tolerance"))
	path:SetMinLookAheadDistance(ROTGB_GetConVarValue("rotgb_setminlookaheaddistance"))]]
	if not ROTGB_DOT_MESH then
		local waitamt = SysTime()
		ROTGB_DOT_MESH = self:BuildDotMesh()
		self:Log("Generated DotMesh in "..SysTime()-waitamt.." seconds.","pathfinding")
	end
	local position = self:GetTarget():GetPos()
	local waitamt = SysTime()
	self:GeneratePath(ROTGB_DOT_MESH,self:GetPos(),position)
	waitamt = SysTime()-waitamt
	waitamt = math.max(waitamt*ROTGB_GetBalloonCount()*ROTGB_GetConVarValue("rotgb_path_delay"),0.5)
	self:Log("Regenerated pathway. Recomputing in "..waitamt.." seconds...","pathfinding")
	--self.RecheckPath = true
	if not self.GeneratedPath then return "Failed to find a path." end
	--local supptab = {}
	--[[for k,v in pairs(path:GetAllSegments()) do
		if v.area:HasAttributes(NAV_MESH_TRANSIENT) then
			util.TraceLine({
				start = v.area:GetCenter(),
				endpos = v.area:GetCenter()+vector_up*self:BoundingRadius(),
				filter = self,
				mask = MASK_NPCSOLID,
				ignoreworld = true,
				output = supptab
			})
			if supptab.Hit then
				return "Transient NavMesh #"..v.area:GetID().." should not be crossed! Abort!"
			end
		end
	end]]
	while self.GeneratedPath and IsValid(self:GetTarget()) and not GetConVar("ai_disabled"):GetBool() do
		--[[if self:GetTarget():GetPos():DistToSqr(position)>ROTGB_GetConVarValue("rotgb_target_tolerance")^2 or self:CurTime()-self.GeneratedPathTimestamp>waitamt then
			self.RecheckPath = nil
			position = self:GetTarget():GetPos()
			waitamt = SysTime()
			self:ComputePathWrapper(path,position)
			waitamt = SysTime()-waitamt
			waitamt = math.max(waitamt*ROTGB_GetBalloonCount()*ROTGB_GetConVarValue("rotgb_path_delay"),0.5)
			self:Log("Regenerated pathway. Recomputing in "..waitamt.." seconds...","pathfinding")
		end]]
		if string.find(ROTGB_GetConVarValue("rotgb_debug"),"pathfinding") then
			--path:Draw()
		end
		local firstPos = self:GetPos()
		if not self:IsStunned() then
			self:InchCloser()
			--path:Chase(self,self:GetTarget())
		end
		--[[if not self.GeneratedPath and (IsValid(self:GetTarget()) and not navmesh.GetNearestNavArea(self:GetPos()):HasAttributes(NAV_MESH_STOP) and self:GetTarget():GetPos():DistToSqr(self:GetPos()) > ROTGB_GetConVarValue("rotgb_target_tolerance")^2*2.25) then
			self:LogError("Temporarily lost track! Using stock pathfinding...","pathfinding")
			self.correcting = true
			path = Path("Chase")
			path:SetGoalTolerance(ROTGB_GetConVarValue("rotgb_target_tolerance"))
			path:SetMinLookAheadDistance(ROTGB_GetConVarValue("rotgb_setminlookaheaddistance"))
			path:Compute(self,self:GetTarget():GetPos())
			path:Chase(self,self:GetTarget())
		end]]
		if --[[self.loco:IsStuck() or]] self.GeneratedPath and (self.WallStuck or 0)>=4 and not self:IsStunned() then
			self.WallStuck = nil
			if (self.ResetStuck or 0) < self:CurTime() then
				self.UnstuckAttempts = 0
			end
			self.UnstuckAttempts = self.UnstuckAttempts + 1
			self.ResetStuck = self:CurTime() + 30
			if self.UnstuckAttempts == 1 then
				self.loco:Jump()
			elseif self.UnstuckAttempts == 2 then
				self:SetPos(self:GetPos()+vector_up*20)
			else -- If not, just teleport us ahead on the path. (Sanic method)
				self.LastStuck = self:CurTime()
				local dir = self.GeneratedPath[1]-self:GetPos()
				local deltasqr = 2^self.UnstuckAttempts
				local lengthsqr = dir:LengthSqr()
				if lengthsqr <= deltasqr then
					self:SetPos(self.GeneratedPath[1])
				else
					dir:Mul(math.sqrt(deltasqr/lengthsqr))
					self:SetPos(self:GetPos()+dir)
				end
			end
			return "Got stuck for the "..self.UnstuckAttempts..STNDRD(self.UnstuckAttempts).." time!"
		end
		self:CheckForRegenAndFire()
		self:CheckForSpeedMods()
		self:PerformPops()
		coroutine.yield()
		firstPos:Sub(self:GetPos())
		local cdd = firstPos:Length()
		self.TravelledDistance = (self.TravelledDistance or 0) + cdd
		local nearestNavArea = navmesh.GetNearestNavArea(self:GetPos())
		if cdd==0 and not (self:IsStunned() or IsValid(nearestNavArea) and nearestNavArea:HasAttributes(NAV_MESH_STOP)) then
			self.WallStuck = (self.WallStuck or 0) + 1
			self:LogError("Stuck in a wall, "..self.WallStuck*25 .."% sure.","pathfinding")
			if self.WallStuck>=4 then
				self:LogError("Definitely stuck! Waiting for HandleStuck...","pathfinding")
			end
		else
			self.WallStuck = nil
		end
	end
	if not IsValid(self:GetTarget()) then
		return "Lost its target."
	end
	return "Completely lost track!!"
end

end
--end of custom pathfinding]=]

function ENT:SetTarget(ent)
	if isentity(ent) then
		self.Target = ent
	else
		self.Target = NULL
	end
end

function ENT:GetTarget()
	if self:CanTarget(self.Target) then
		return self.Target
	else return NULL
	end
end

function ENT:MaskFilter(mask,ent)
	if ent:IsNPC() then
		local entclass = ent:Classify()
		if ROTGB_HasAllBits(mask,2) and (entclass==CLASS_PLAYER_ALLY or entclass==CLASS_PLAYER_ALLY_VITAL or entclass==CLASS_CITIZEN_PASSIVE or entclass==CLASS_CITIZEN_REBEL or entclass==CLASS_VORTIGAUNT or entclass==CLASS_HACKED_ROLLERMINE) then return true
		elseif ROTGB_HasAllBits(mask,4) and (entclass==CLASS_COMBINE or entclass==CLASS_COMBINE_GUNSHIP or entclass==CLASS_MANHACK or entclass==CLASS_METROPOLICE or entclass==CLASS_MILITARY or entclass==CLASS_SCANNER or entclass==CLASS_STALKER or entclass==CLASS_PROTOSNIPER or entclass==CLASS_COMBINE_HUNTER) then return true
		elseif ROTGB_HasAllBits(mask,8) and (entclass==CLASS_HEADCRAB or entclass==CLASS_ZOMBIE) then return true
		elseif ROTGB_HasAllBits(mask,16) and (entclass==CLASS_ANTLION) then return true
		elseif ROTGB_HasAllBits(mask,32) and (entclass==CLASS_BARNACLE or entclass==CLASS_BULLSEYE or entclass==CLASS_CONSCRIPT or entclass==CLASS_MISSILE or entclass==CLASS_FLARE or entclass==CLASS_EARTH_FAUNA or entclass>25) then return true
		elseif ROTGB_HasAllBits(mask,64) and ent:IsScripted() then return true
		end
	elseif ROTGB_HasAllBits(mask,1) and ent:IsPlayer() and (ent:OnGround() or math.abs(ent:GetPos().z - (navmesh.GetGroundHeight(ent:GetPos()) or math.huge))<ROTGB_GetConVarValue("rotgb_target_tolerance")*0.9) and not GetConVar("ai_ignoreplayers"):GetBool() then return true
	elseif ROTGB_HasAllBits(mask,128) and ent:Health()>0 and ent.RunBehaviour and ent:GetClass()~="gballoon_base" then return true
	elseif ROTGB_HasAllBits(mask,256) and ent:Health()>0 and not ent.RunBehaviour then return true
	end
	return false
end

function ENT:CanTarget(ent)
	if not (isentity(ent) and IsValid(ent)) then return false end
	if ent:GetClass()=="gballoon_target" then return not (ent:GetIsBeacon() and self.LastBeacon == ent) end
	local mask = ROTGB_GetConVarValue("rotgb_target_choice")
	if mask<0 and ent:Health()>0 and ent:GetClass()~="gballoon_base" then return true end
	return self:MaskFilter(mask,ent)
end

function ENT:FindTarget()
	local ourPos = self:GetPos()
	local searchSize = ROTGB_GetConVarValue("rotgb_search_size")
	local entis = searchSize<0 and ents.GetAll() or ents.FindInSphere(ourPos,searchSize)
	local resulttabs = {}
	if ROTGB_LoggingEnabled("targeting") then
		self:Log("We are considering the following: "..util.TableToJSON(table.Sanitise(entis),true),"targeting")
	end
	for k,v in pairs(entis) do
		if self:CanTarget(v) then
			--self:Log("We can target "..tostring(v)..". Attempting to build a path...","targeting")
			--[[local path = Path("Chase")
			local position = v:GetPos()
			path:SetGoalTolerance(ROTGB_GetConVarValue("rotgb_target_tolerance"))
			path:SetMinLookAheadDistance(ROTGB_GetConVarValue("rotgb_setminlookaheaddistance"))
			if ROTGB_GetConVarValue("rotgb_use_custom_pathfinding") then
				self:ComputePathWrapper(path,position)
			else
				path:Compute(self,position)
			end
			if IsValid(path) then]]
				local isTarget = v:GetClass()=="gballoon_target"
				local targetSorting = ROTGB_GetConVarValue("rotgb_target_sort")
				--[[if IsValid(self.Attractor) and v:IsNPC() then
					self.Attractor:AddEntityRelationship(v,D_HT,4)
					v:AddEntityRelationship(self.Attractor,D_HT,4)
					v:AddEntityRelationship(self,D_HT,4)
				end]]
				if targetSorting==-1 then
					resulttabs[v] = math.random()
				elseif targetSorting==0 then
					resulttabs[v] = -v:GetPos():DistToSqr(ourPos)+math.random()
				elseif targetSorting==1 then
					resulttabs[v] = v:GetPos():DistToSqr(ourPos)+math.random()
				elseif targetSorting==2 then
					resulttabs[v] = v:Health()+math.random()
				elseif targetSorting==3 then
					resulttabs[v] = -v:Health()+math.random()
				end
				if isTarget then resulttabs[v] = resulttabs[v] + 1e10 * (v:GetWeight() + 1) end
				self:Log("Targeted "..tostring(v).." with priority "..resulttabs[v]..".","targeting")
			--[[else
				self:LogError("Couldn't build a path! Discarding current target.","targeting")
			end]]
		--[[elseif IsValid(self.Attractor) and v:IsNPC() then
			self.Attractor:AddEntityRelationship(v,D_LI,4)
			v:AddEntityRelationship(self.Attractor,D_LI,4)
			v:AddEntityRelationship(self,D_LI,4)]]
		end
	end
	if next(resulttabs) then
		self:SetTarget(table.GetWinningKey(resulttabs))
		self:Log("Set our target to "..tostring(self:GetTarget()),"targeting")
		return true
	else return false
	end
end

function ENT:ComputePathWrapper(path,pos)
	local sttime = SysTime()
	self:Log("Path Computation Started!","pathfinding")
	local supptab,igids = {},{}
	for k,v in pairs(navmesh.GetAllNavAreas()) do
		if v:HasAttributes(NAV_MESH_TRANSIENT) then
			util.TraceLine({
				start = v:GetCenter(),
				endpos = v:GetCenter()+vector_up*self:BoundingRadius(),
				filter = self,
				mask = MASK_NPCSOLID,
				ignoreworld = true,
				output = supptab
			})
			if supptab.Hit then
				self:Log("Transient NavMesh #"..v:GetID().." should not be crossed!","pathfinding")
				igids[v:GetID()] = true
			end
		end
	end
	local function ComputePath(nextArea,prevArea,ladder,elevator,length)
		if not IsValid(prevArea) then return 0
		else
			local isJump = nextArea:HasAttributes(NAV_MESH_JUMP)
			if not self.loco:IsAreaTraversable(nextArea) then
				return -1
			else
				local height = prevArea:ComputeAdjacentConnectionHeightChange(nextArea)
				if height > self.loco:GetStepHeight() then
					if height <= self.loco:GetMaxJumpHeight() then
						isJump = true
					else
						return -1
					end
				elseif height <= -self.loco:GetDeathDropHeight() then
					return -1
				end
			end
			if nextArea:HasAttributes(NAV_MESH_TRANSIENT) and igids[nextArea:GetID()] then
				return -1
			end

			local dist = 0
			if IsValid(ladder) then
				dist = ladder:GetLength()
			elseif length > 0 then
				dist = length
			elseif nextArea:GetCenter() and prevArea:GetCenter() then
				dist = (nextArea:GetCenter()-prevArea:GetCenter()):Length()
			end
			if nextArea:HasAttributes(NAV_MESH_AVOID) then
				dist = dist * 1000000
			elseif isJump and not nextArea:HasAttributes(NAV_MESH_STAIRS) then
				dist = dist * 1000
			end
			--local brushStat
			--local obeyCount = 0
			--[[ for i=0,3 do
				local pos = nextArea:GetCorner(i)
				for k,v in pairs(ents.FindInSphere(pos,30)) do
					if i==0 then
						if v:GetClass()=="func_nav_avoid" and v.Enabled then
							-- print("AVOID: 0")
							brushStat = "avoid" break
						elseif v:GetClass()=="func_nav_prefer" and v.Enabled then
							-- print("PREFER: 0")
							brushStat = "prefer" break
						end
					else
						if brushStat=="avoid" and v:GetClass()=="func_nav_avoid" and v.Enabled then
							-- print("AVOID: "..obeyCount + 1)
							obeyCount = obeyCount + 1 break
						elseif brushStat=="prefer" and v:GetClass()=="func_nav_prefer" and v.Enabled then
							-- print("PREFER: "..obeyCount + 1)
							obeyCount = obeyCount + 1 break
						end
					end
				end
			end
			if obeyCount>=2 then
				if brushStat=="avoid" then
					-- print("Avoiding")
					return -1-- dist = dist * 1000000
				elseif brushStat=="prefer" then
					dist = dist * 0.01
					-- print("Preferring, dist is now",dist)
				end
			end]]
			local pos = nextArea:GetCenter()
			for k,v in pairs(entitiestoconsider) do
				if IsValid(k) then
					self:Log(tostring(k).." sensed. Position: "..tostring(pos)..", Vector1:"..tostring(v[1])..", Vector2:"..tostring(v[2])..", InPosition="..tostring(pos:WithinAABox(v[1],v[2])),"func_nav_detection")
					if pos:WithinAABox(v[1],v[2]) and k.Enabled then
						if k:GetClass()=="func_nav_avoid" then
							dist = dist * 1000000
							self:Log("Detected "..tostring(k).." and avoiding, cost to cross is now "..dist,"func_nav_detection") break
						elseif k:GetClass()=="func_nav_prefer" then
							dist = dist * 0.000001
							self:Log("Detected "..tostring(k).." and preferring, cost to cross is now "..dist,"func_nav_detection") break
						end
					end
				else
					entitiestoconsider[k] = nil
				end
			end
			return (prevArea:GetCostSoFar()+dist)
		end
	end
	if ROTGB_GetConVarValue("rotgb_use_custom_pathfinding") then
		path:Compute(self,pos,ComputePath)
	else
		path:Compute(self,pos)
	end
	self:Log("Path Computation Time: "..(SysTime()-sttime)*1000 .." ms","pathfinding")
end

function ENT:MoveToTarget()
	--[[
	steps:
	
	try to make a path
		if unsuccessful, stop or follow a straight line, then go back to (1)
		if successful, follow the path, then check again
			if path still exists, go to (3)
			if path does not exist, stop or try again with stock pathfinding
				if path exists, go to (3)
				if path does not exist, stop or follow a straight line, then go back to (1)
	]]
	
	local isBalloonTarget = self:GetTarget():GetClass()=="gballoon_target"
	if isBalloonTarget and self:GetTarget():GetTeleport() then
		self:SetPos(self:GetTarget():GetPos())
	elseif isBalloonTarget and self:GetTarget():GetStraightPath() then
		self:Log("Moving straight to target...","pathfinding")
		self:MoveToTargetStraight()
	else
		--coroutine.wait(0.05*ROTGB_GetConVarValue("rotgb_path_delay")*ROTGB_GetBalloonCount())
		local path = Path("Chase")
		local position = self:GetTarget():GetPos()
		path:SetGoalTolerance(ROTGB_GetConVarValue("rotgb_target_tolerance"))
		path:SetMinLookAheadDistance(ROTGB_GetConVarValue("rotgb_setminlookaheaddistance"))
		local waitamt = SysTime()
		self:ComputePathWrapper(path,position)
		waitamt = SysTime()-waitamt
		waitamt = math.max(waitamt*ROTGB_GetBalloonCount()*ROTGB_GetConVarValue("rotgb_path_delay"),0.5)
		self:Log("Regenerated pathway. Recomputing in "..waitamt.." seconds...","pathfinding")
		self.RecheckPath = true
		
		if not IsValid(path) then
			local nearestNavArea = navmesh.GetNearestNavArea(self:GetPos())
			local navStop = IsValid(nearestNavArea) and nearestNavArea:HasAttributes(NAV_MESH_STOP)
			
			if not navStop then
				self:Log("Path is invalid. Moving straight to target...","pathfinding")
				self:MoveToTargetStraight(waitamt)
			end
		end
		--local supptab = {}
		--[[for k,v in pairs(path:GetAllSegments()) do
			if v.area:HasAttributes(NAV_MESH_TRANSIENT) then
				util.TraceLine({
					start = v.area:GetCenter(),
					endpos = v.area:GetCenter()+vector_up*self:BoundingRadius(),
					filter = self,
					mask = MASK_NPCSOLID,
					ignoreworld = true,
					output = supptab
				})
				if supptab.Hit then
					return "Transient NavMesh #"..v.area:GetID().." should not be crossed! Abort!"
				end
			end
		end]]
		while IsValid(path) and IsValid(self:GetTarget()) and not GetConVar("ai_disabled"):GetBool() do
			local curTime = self:CurTime()
			-- "position" here is where we expect the target to be
			if self:GetTarget():GetPos():DistToSqr(position)>ROTGB_GetConVarValue("rotgb_target_tolerance")^2 or path:GetAge()>(self.RecheckPath and 0.5 or waitamt) then
				self.RecheckPath = nil
				position = self:GetTarget():GetPos()
				waitamt = SysTime()
				self:ComputePathWrapper(path,position)
				waitamt = SysTime()-waitamt
				waitamt = math.max(waitamt*ROTGB_GetBalloonCount()*ROTGB_GetConVarValue("rotgb_path_delay"),0.5)
				self:Log("Regenerated pathway. Recomputing in "..waitamt.." seconds...","pathfinding")
			end
			if string.find(ROTGB_GetConVarValue("rotgb_debug"),"pathfinding") then
				path:Draw()
			end
			local firstPos = self:GetPos()
			if not self:IsStunned() then
				path:Chase(self,self:GetTarget())
			end
			local nearestNavArea = navmesh.GetNearestNavArea(self:GetPos())
			local navStop = IsValid(nearestNavArea) and nearestNavArea:HasAttributes(NAV_MESH_STOP)
			if not IsValid(path) and (IsValid(self:GetTarget()) and not navStop and self:GetTarget():GetPos():DistToSqr(self:GetPos()) > ROTGB_GetConVarValue("rotgb_target_tolerance")^2*2.25) then
				self:LogError("Temporarily lost track! Using stock pathfinding...","pathfinding")
				path:Compute(self,self:GetTarget():GetPos())
				if IsValid(path) then
					self.correcting = true
					path:Chase(self,self:GetTarget())
				else
					self:Log("Path is invalid. Moving straight to target...","pathfinding")
					self:MoveToTargetStraight(waitamt)
				end
			end
			if self.loco:IsStuck() or (self.WallStuck or 0)>=4 and not self:IsStunned() then
				self.WallStuck = nil
				if (self.ResetStuck or 0) < curTime then
					self.UnstuckAttempts = 0
				end
				self.UnstuckAttempts = self.UnstuckAttempts + 1
				self.ResetStuck = curTime + 10
				if self.UnstuckAttempts == 1 then -- A simple jump should fix it.
					self:ComputePathWrapper(path,position)
					self.loco:Jump()
					self.loco:ClearStuck()
				elseif self.UnstuckAttempts == 2 then -- That didn't fix it, try to teleport slightly upwards instead.
					self:SetPos(self:GetPos()+vector_up*20)
					self.loco:ClearStuck()
				elseif self.UnstuckAttempts == 3 then -- If not, ask GMod kindly to free us.
					self:HandleStuck()
				else -- If not, just teleport us ahead on the path. (Sanic method)
					self.LastStuck = curTime
					self:SetPos(path:GetPositionOnPath(path:GetCursorPosition()+2^self.UnstuckAttempts))
					self.loco:ClearStuck()
				end
				return "Got stuck for the "..self.UnstuckAttempts..STNDRD(self.UnstuckAttempts).." time!"
			end
			self:CheckForRegenAndFire()
			self:CheckForStatusBroadcasting()
			self:CheckForSpeedMods()
			self:CheckForBossEffects()
			--self:CheckForBuffs()
			self:PerformPops()
			coroutine.yield()
			nearestNavArea = navmesh.GetNearestNavArea(self:GetPos())
			navStop = IsValid(nearestNavArea) and nearestNavArea:HasAttributes(NAV_MESH_STOP)
			if self.correcting and navStop then
				self.correcting = nil
				self:ComputePathWrapper(path,position)
			end
			firstPos:Sub(self:GetPos())
			local cdd = firstPos:Length()
			self.TravelledDistance = (self.TravelledDistance or 0) + cdd
			if cdd==0 and not (self:IsStunned() or navStop) then
				self.WallStuck = (self.WallStuck or 0) + 1
				self:LogError("Stuck in a wall, "..self.WallStuck*25 .."% sure.","pathfinding")
				if self.WallStuck>=4 then
					self:LogError("Definitely stuck! Waiting for HandleStuck...","pathfinding")
				end
			else
				self.WallStuck = nil
			end
		end
		if not IsValid(self:GetTarget()) then
			return "Lost its target."
		end
	end
	return "Failed to find a path."
end

function ENT:MoveToTargetStraight(waitamt)
	local endTime = CurTime() + (waitamt or math.huge)
	self.StraightMovement = true
	
	while self.StraightMovement
	and endTime > CurTime()
	and not GetConVar("ai_disabled"):GetBool()
	and (
		IsValid(self:GetTarget())
		and self:GetTarget():GetPos():DistToSqr(self:GetPos()) >= ROTGB_GetConVarValue("rotgb_target_tolerance")^2
	)
	do
		local curTime = CurTime()
		if self.loco:IsStuck() or (self.WallStuck or 0)>=4 and not self:IsStunned() then
			self.WallStuck = nil
			if (self.ResetStuck or 0) < curTime then
				self.UnstuckAttempts = 0
			end
			self.UnstuckAttempts = self.UnstuckAttempts + 1
			self.ResetStuck = curTime + 10
			if self.UnstuckAttempts == 1 then -- A simple jump should fix it.
				--self:ComputePathWrapper(path,position)
				self.loco:Jump()
				self.loco:ClearStuck()
			elseif self.UnstuckAttempts == 2 then -- That didn't fix it, try to teleport slightly upwards instead.
				self:SetPos(self:GetPos()+vector_up*20)
				self.loco:ClearStuck()
			elseif self.UnstuckAttempts == 3 then -- If not, ask GMod kindly to free us.
				self:HandleStuck()
			else -- If not, just teleport us ahead on the path. (Sanic method)
				local position = self:GetTarget():GetPos()
				local dir = position - self:GetPos()
				local maxDist = dir:Length()
				
				dir:Normalize()
				dir:Mul(math.min(2^self.UnstuckAttempts, maxDist))
				dir:Add(self:GetPos())
				
				self.LastStuck = curTime
				self:SetPos(dir)
				self.loco:ClearStuck()
			end
			return "Got stuck for the "..self.UnstuckAttempts..STNDRD(self.UnstuckAttempts).." time!"
		end
		self:CheckForRegenAndFire()
		self:CheckForStatusBroadcasting()
		self:CheckForSpeedMods()
		self:CheckForBossEffects()
		--self:CheckForBuffs()
		self:PerformPops()
		
		local oldPos = self:GetPos()
		coroutine.yield()
		local difference = self:GetPos() - oldPos
		local moved = difference:Length()
		self.TravelledDistance = (self.TravelledDistance or 0) + moved
		difference:Add(self:GetPos())
		self.loco:FaceTowards(difference)
		
		local nearestNavArea = navmesh.GetNearestNavArea(self:GetPos())
		local navStop = IsValid(nearestNavArea) and nearestNavArea:HasAttributes(NAV_MESH_STOP)
		if moved==0 and not (self:IsStunned() or navStop) then
			self.WallStuck = (self.WallStuck or 0) + 1
			self:LogError("Stuck in a wall, "..self.WallStuck*25 .."% sure.","pathfinding")
			if self.WallStuck>=4 then
				self:LogError("Definitely stuck! Waiting for HandleStuck...","pathfinding")
			end
		else
			self.WallStuck = nil
		end
	end
	self.StraightMovement = false
end

function ENT:MoveStraightThink()
	if IsValid(self:GetTarget()) and not self:IsStunned() then
		self.loco:Approach(self:GetTarget():GetPos(), 1)
	end
end

function ENT:ChooseNextTargetWeighted(current, targets)
	local targetWeightSelectionZones = {}
	local totalWeights = 0
	
	for i,v in ipairs(targets) do
		if v:GetWeight() > 0 then
			table.insert(targetWeightSelectionZones, {totalWeights, v})
			totalWeights = totalWeights + v:GetWeight()
		end
	end
	
	if totalWeights > 0 then
		current = current % totalWeights
		for i,v in ipairs(table.Reverse(targetWeightSelectionZones)) do
			if current >= v[1] then return v[2] end
		end
	end
	
	return targets[math.random(#targets)]
end

function ENT:RunBehaviour()
	while true do
		if not self.FirstRunBehaviour then
			self.FirstRunBehaviour = true
			if self:Health() <= 0 then
				self:SetHealth(1)
				self:Log("Took fatal damage WHILE spawning. Health set to 1.", "damage")
			end
		end
		self:CheckForRegenAndFire()
		self:CheckForStatusBroadcasting()
		self:CheckForBossEffects()
		--self:CheckForBuffs()
		self:PerformPops()
		if GetConVar("ai_disabled"):GetBool() then
			self:Log("ai_disabled is set, waiting...","pathfinding")
			coroutine.wait(1)
		elseif ROTGB_GetConVarValue("rotgb_init_rate")>=0 and not self.AIEnabled then
			self:Log("AI disabled, waiting...","pathfinding")
			coroutine.wait(1)
		else
			if IsValid(self:GetTarget()) then
				self.loco:SetAcceleration(self:GetBalloonProperty("BalloonMoveSpeed")*(self:GetBalloonProperty("BalloonFast") and 2 or 1)*5)
				self.loco:SetDesiredSpeed(self.loco:GetAcceleration()/5)
				self.loco:SetDeceleration(self.loco:GetAcceleration())
				self.loco:SetJumpHeight(58)
				self.loco:SetStepHeight(18)
				local result = ROTGB_GetConVarValue("rotgb_use_custom_pathfinding") and ROTGB_GetConVarValue("rotgb_use_custom_ai") and self:MoveToTargetNew() or self:MoveToTarget()
				local selftarg = self:GetTarget()
				if (IsValid(selftarg) and not GetConVar("ai_disabled"):GetBool() and selftarg:GetPos():DistToSqr(self:GetPos()) <= ROTGB_GetConVarValue("rotgb_target_tolerance")^2*2.25) then
					if (selftarg:GetClass()=="gballoon_target" and selftarg:GetIsBeacon()) and self.LastBeacon ~= selftarg then
						self.LastBeacon = selftarg
						local nextTargs = {}
						if self:GetBalloonProperty("BalloonBlimp") then
							selftarg.rotgb_TimesBlimpWaypointed = (selftarg.rotgb_TimesBlimpWaypointed or 0) + 1
							selftarg:TriggerOutput("OnWaypointedBlimp",self,selftarg.rotgb_TimesBlimpWaypointed)
							for i=1,16 do
								local gTarg = selftarg["GetNextBlimpTarget"..i](selftarg)
								if IsValid(gTarg) then
									table.insert(nextTargs,gTarg)
								end
							end
						else
							selftarg.rotgb_TimesWaypointed = (selftarg.rotgb_TimesWaypointed or 0) + 1
							selftarg:TriggerOutput("OnWaypointedNonBlimp",self,selftarg.rotgb_TimesWaypointed)
						end
						selftarg:TriggerOutput("OnWaypointed",self,(selftarg.rotgb_TimesWaypointed or 0)+(selftarg.rotgb_TimesBlimpWaypointed or 0))
						if next(nextTargs) then
							--[[ local nextTargetNum = selftarg.rotgb_TimesBlimpWaypointed % #nextTargs
							if nextTargetNum == 0 then nextTargetNum = #nextTargs end
							self:SetTarget(nextTargs[nextTargetNum]) ]]
							self:SetTarget(self:ChooseNextTargetWeighted(selftarg.rotgb_TimesBlimpWaypointed, nextTargs))
						else
							for i=1,16 do
								local gTarg = selftarg["GetNextTarget"..i](selftarg)
								if IsValid(gTarg) then
									table.insert(nextTargs,gTarg)
								end
							end
							if next(nextTargs) then
								local times = self:GetBalloonProperty("BalloonBlimp") and (selftarg.rotgb_TimesWaypointed or 0)+selftarg.rotgb_TimesBlimpWaypointed or selftarg.rotgb_TimesWaypointed
								--[[ local nextTargetNum = times % #nextTargs
								if nextTargetNum == 0 then nextTargetNum = #nextTargs end
								self:SetTarget(nextTargs[nextTargetNum]) ]]
								self:SetTarget(self:ChooseNextTargetWeighted(times, nextTargs))
							end
						end
					else
						self:Pop(nil,selftarg)
					end
				else
					self:LogError(tostring(result),"pathfinding")
				end
			else
				self.loco:SetDesiredSpeed(0)
				if not self:FindTarget() then
					coroutine.wait(1)
				end
			end
		end
		coroutine.yield()
	end
end

function ENT:CheckForStatusBroadcasting(forceAccept)
	if self:GetStatusSendRequired() then
		self:SetStatusSendRequired(false)
		
		local flags = bit.bor(
			(self:GetBalloonProperty("BalloonFast") and 1 or 0),
			(self:GetBalloonProperty("BalloonHidden") and 2 or 0),
			(self:GetBalloonProperty("BalloonRegen") and 4 or 0),
			(self:GetBalloonProperty("BalloonShielded") and 8 or 0),
			(self:GetBalloonProperty("BalloonRainbow") and 16 or 0)
		)
		
		net.Start("rotgb_generic", not forceAccept)
		net.WriteUInt(ROTGB_OPERATION_BOSS, 8)
		net.WriteUInt(self:EntIndex(), 16)
		net.WriteString(self:GetBalloonProperty("BalloonType"))
		net.WriteUInt(flags, 8)
		net.WriteInt(self:Health(), 32)
		net.WriteInt(self:GetMaxHealth(), 32)
		net.WriteUInt(self:GetBalloonProperty("BalloonHealthSegments"), 8)
		net.Broadcast()
	end
end

function ENT:CheckForBossEffects()
	if self:GetBalloonProperty("BalloonBoss") then
		local bossEffects = registeredBossEffects[self:GetBalloonProperty("BalloonBossEffect")]
		if (bossEffects and bossEffects.PerSecond) and (self.NextPerSecondEffect or 0) < self:CurTime() then
			bossEffects.PerSecond(self)
			self.NextPerSecondEffect = self:CurTime() + 1
		end
	end
end

function ENT:Stun(tim)
	if not self:GetBalloonProperty("BalloonBoss") then
		self.StunUntil = math.max(self:CurTime() + tim,self.StunUntil or 0)
	
		local effdata = EffectData()
		effdata:SetEntity(self)
		effdata:SetMagnitude(tim)
		util.Effect("rotgb_stunned", effdata, true, true)
	end
end

function ENT:UnStun()
	self.StunUntil = nil
end

function ENT:Freeze(tim)
	if not self:GetBalloonProperty("BalloonBoss") then
		self:SetNWFloat("rotgb_FreezeTime",self:CurTime()+tim)
		self.FreezeUntil = math.max(self:CurTime() + tim,self.FreezeUntil or 0)
	end
end

function ENT:UnFreeze()
	self:SetNWFloat("rotgb_FreezeTime",0)
	self.FreezeUntil = nil
end

function ENT:Freeze2(tim)
	if not self:GetBalloonProperty("BalloonBoss") then
		self:SetNWFloat("rotgb_FreezeTime",self:CurTime()+tim)
		self.FreezeUntil2 = math.max(self:CurTime() + tim,self.FreezeUntil2 or 0)
	end
end

function ENT:UnFreeze2()
	self:SetNWFloat("rotgb_FreezeTime",0)
	self.FreezeUntil2 = nil
end

function ENT:IsStunned()
	local curTime = self:CurTime()
	return self.StunUntil and self.StunUntil>curTime or self.FreezeUntil and self.FreezeUntil>curTime or self.FreezeUntil2 and self.FreezeUntil2>curTime or false
end

function ENT:IsFrozen()
	return (self.FreezeUntil or 0)>self:CurTime() or (self.FreezeUntil2 or 0)>self:CurTime()
end

function ENT:CheckForSpeedMods()
	local mul = 5
	local curTime = self:CurTime()
	for k,v in pairs(self.rotgb_SpeedMods or {}) do
		if v[1] > curTime then
			mul = mul * v[2]
		else
			self.rotgb_SpeedMods[k] = nil
		end
	end
	mul = mul*ROTGB_GetConVarValue("rotgb_speed_mul")*(self:GetBalloonProperty("BalloonFast") and 2 or 1)
	self.loco:SetAcceleration(self:GetBalloonProperty("BalloonMoveSpeed")*mul)
	self.loco:SetDesiredSpeed(self.loco:GetAcceleration()/5)
	self.loco:SetDeceleration(self.loco:GetAcceleration())
end

-- "Slowdown" isn't accurate anymore as multipliers > 1 are now accepted
function ENT:Slowdown(id,amt,tim)
	if not self:GetBalloonProperty("BalloonBoss") or amt > 1 then
		self.rotgb_SpeedMods = self.rotgb_SpeedMods or {}
		if self.rotgb_SpeedMods[id] then
			tim = math.max(tim,self.rotgb_SpeedMods[id][1]-self:CurTime())
			amt = math.min(amt,self.rotgb_SpeedMods[id][2])
		end
		self.rotgb_SpeedMods[id] = {self:CurTime() + tim,amt}
	end
end

function ENT:UnSlowdown(id)
	self.rotgb_SpeedMods = self.rotgb_SpeedMods or {}
	self.rotgb_SpeedMods[id] = nil
end

function ENT:GetSlowdown(id)
	return self.rotgb_SpeedMods[id]
end

function ENT:GetAndApplyValueMultipliers(value)
	local total = value
	local curTime = self:CurTime()
	for k,v in pairs(self.rotgb_ValueMultipliers or {}) do
		if v[1] > curTime then
			local increment = v[2]*value
			total = total + increment
			if IsValid(v[3]) then
				v[3]:SetCashGenerated((v[3]:GetCashGenerated() or 0)+increment)
			end
		else
			self.rotgb_ValueMultipliers[k] = nil
		end
	end
	return total
end

function ENT:MultiplyValue(id,tower,amt,tim)
	self.rotgb_ValueMultipliers = self.rotgb_ValueMultipliers or {}
	if self.rotgb_ValueMultipliers[id] then
		tim = math.max(tim,self.rotgb_ValueMultipliers[id][1]-self:CurTime())
		amt = math.max(amt,self.rotgb_ValueMultipliers[id][2])
	end
	self.rotgb_ValueMultipliers[id] = {self:CurTime() + tim,amt,tower}
end

function ENT:CreateFire(tim)
	self.RotgBFireEnt = ents.Create("env_fire")
	self.RotgBFireEnt:SetPos(self:GetPos())
	self.RotgBFireEnt:SetParent(self)
	self.RotgBFireEnt:SetKeyValue("spawnflags",bit.bor(2,32,128))
	self.RotgBFireEnt:SetKeyValue("firesize",64)
	self.RotgBFireEnt:SetKeyValue("health",tim)
	self.RotgBFireEnt:Spawn()
	self.RotgBFireEnt:Fire("StartFire")
end

local lastFireRender = 0

function ENT:RotgB_Ignite(dmg, atk, inflictor, tim)
	-- dmg is applied per second
	
	--self:Extinguish()
	--self:Ignite(tim)
	local curTime = self:CurTime()
	if (self.FireData and self.FireData.damage >= dmg) then
		if self.FireData.dietime < curTime+tim then
			self.FireData.attacker = atk
			self.FireData.inflictor = inflictor
			self.FireData.dietime = curTime+tim
			
			if IsValid(self.RotgBFireEnt) then
				self.RotgBFireEnt:SetKeyValue("health",tim)
				self.RotgBFireEnt:Fire("StartFire")
			end
		end
	else
		self.FireData = {
			damage = dmg,
			attacker = atk,
			inflictor = inflictor,
			dietime = curTime+tim
		}
		self:Log("Caught on fire by "..tostring(inflictor).."!","fire")
		if IsValid(self.RotgBFireEnt) then
			self.RotgBFireEnt:SetKeyValue("health",tim)
			self.RotgBFireEnt:Fire("StartFire")
		elseif lastFireRender<CurTime() then
			local fireRenderDelay = 1/ROTGB_GetConVarValue("rotgb_max_fires_per_second")
			if lastFireRender+fireRenderDelay<CurTime() then
				lastFireRender = CurTime()
			end
			lastFireRender = lastFireRender+fireRenderDelay
			self:Log("Visually caught on fire!","fire")
			self:CreateFire(tim)
		end
	end
end

function ENT:InflictRotgBStatusEffect(typ,tim)
	--ROTGB_EntityLogError(self, "DEPRECATION WARNING: ENT.InflictRotgBStatusEffect is now unused and will be deleted in the future. Use ENT.ApplyBuff instead.", "")
	self["rotgb_SE_"..typ] = math.max(self["rotgb_SE_"..typ] or 0,self:CurTime() + tim)
end

function ENT:HasRotgBStatusEffect(typ)
	--ROTGB_EntityLogError(self, "DEPRECATION WARNING: ENT.HasRotgBStatusEffect is now unused and will be deleted in the future. Use ENT.GetBuff instead.", "")
	return (self["rotgb_SE_"..typ] or 0) >= self:CurTime()
end

function ENT:GetRotgBStatusEffectDuration(typ)
	--ROTGB_EntityLogError(self, "DEPRECATION WARNING: ENT.GetRotgBStatusEffectDuration is now unused and will be deleted in the future. Use ENT.GetBuff instead.", "")
	return (self["rotgb_SE_"..typ] or 0) - self:CurTime()
end

--[[function ENT:ApplyBuff(tower, identifier, duration, applyFunc, unapplyFunc)
	identifier = identifier or #self.BuffIdentifiers+1
	duration = duration or math.huge
	
	local buffInfo = self:GetBuff(identifier)
	
	if buffInfo then
		buffInfo.expiry = math.max(buffInfo.expiry, self:CurTime() + duration)
	else
		self.BuffIdentifiers[identifier] = {tower = tower, expiry = self:CurTime() + duration, unapplyFunc = unapplyFunc}
		if applyFunc then
			applyFunc(self)
		end
	end
end

function ENT:CheckForBuffs()
	for identifier, info in pairs(self.BuffIdentifiers) do
		if not IsValid(info.tower) or info.expiry < self:CurTime() then
			if info.unapplyFunc then
				info.unapplyFunc(self)
			end
			self.BuffIdentifiers[identifier] = nil
		end
	end
end

function ENT:GetBuff(identifier)
	local info = self.BuffIdentifiers[identifier]
	if (info and (not IsValid(info.tower) or info.expiry < self:CurTime())) then
		if info.unapplyFunc then
			info.unapplyFunc(self)
		end
		self.BuffIdentifiers[identifier] = nil
	end
	
	return self.BuffIdentifiers[identifier]
end]]

function ENT:GetRgBE()
	return self.rotgb_rbetab[self:GetBalloonProperty("BalloonType")]*self:GetMaxHealth()/self:GetBalloonProperty("BalloonHealth")+math.max(self:Health(), 1)-self:GetMaxHealth()
end

function ENT:GetRgBEByType(typ)
	return self.rotgb_rbetab[typ]
end

function ENT:GetDistanceTravelled()
	return self.TravelledDistance or 0
end

function ENT:GetBitflagPropertyState(fast, hidden, regen, shielded)
	return bit.bor(
		(regen or self:GetBalloonProperty("BalloonRegen")) and 1 or 0,
		(fast or self:GetBalloonProperty("BalloonFast")) and 2 or 0,
		(shielded or self:GetBalloonProperty("BalloonShielded")) and 4 or 0,
		(hidden or self:GetBalloonProperty("BalloonHidden")) and 8 or 0
	)
end

function ENT:ShowResistEffect(typ)
	local effectDelay = ROTGB_GetConVarValue("rotgb_resist_effect_delay")
	if effectDelay>=0 and (ROTGB_LASTSHOW or 0) + effectDelay<=CurTime() then
		local effdata = EffectData()
		effdata:SetOrigin(self:GetPos())
		effdata:SetColor(typ)
		util.Effect("rotgb_resist",effdata)
		ROTGB_LASTSHOW = CurTime()
	end
end

function ENT:ShowCritEffect()
	local effectDelay = ROTGB_GetConVarValue("rotgb_crit_effect_delay")
	if effectDelay>=0 and (ROTGB_LASTSHOW2 or 0) + effectDelay<=CurTime() then
		local effdata = EffectData()
		effdata:SetOrigin(self:GetPos())
		util.Effect("rotgb_crit",effdata)
		ROTGB_LASTSHOW2 = CurTime()
		self:EmitSound(string.format("^phx/epicmetal_hard%i.wav", math.random(7)))
	end
end

local function TestDamageResistances(properties,dmgbits,frozen)
	if properties.BalloonGlass and dmgbits then return 8
	elseif ROTGB_GetConVarValue("rotgb_ignore_damage_resistances") then return false
	elseif frozen and ROTGB_HasAnyBits(dmgbits,DMG_BULLET,DMG_SLASH,DMG_BUCKSHOT) then return 6
	elseif properties.BalloonBlack and ROTGB_HasAnyBits(dmgbits,DMG_BLAST,DMG_BLAST_SURFACE) then return 2
	elseif properties.BalloonWhite and ROTGB_HasAnyBits(dmgbits,DMG_VEHICLE,DMG_DROWN,DMG_DROWNRECOVER) then return 1
	elseif properties.BalloonPurple and ROTGB_HasAnyBits(dmgbits,DMG_BURN,DMG_SHOCK,DMG_ENERGYBEAM,DMG_SLOWBURN,
	DMG_REMOVENORAGDOLL,DMG_PLASMA,DMG_DIRECT) then return 3
	elseif properties.BalloonGray and ROTGB_HasAnyBits(dmgbits,DMG_BULLET,DMG_SLASH,DMG_BUCKSHOT) then return 4 end
	--if properties.BalloonAqua and (ROTGB_HasAnyBits(dmgbits,DMG_CRUSH+DMG_FALL+DMG_CLUB+DMG_PHYSGUN)) then return 6 end
end

function ENT:DamageTypeCanDamage(dmgbits)
	local resistresults = TestDamageResistances(self.Properties,dmgbits,self:IsFrozen())
	return not resistresults or self:HasRotgBStatusEffect("unimmune")
end

game.AddDecal("InkWhite","decals/decal_paintsplattergreen001")
function ENT:PerformPops()
	local health = self:Health()
	if health<=0 then
		if self:GetBalloonProperty("BalloonBoss") then
			self:SetStatusSendRequired(true)
			self:CheckForStatusBroadcasting(true)
		end
		local attacker = self.LastAttacker
		local bloodType = ROTGB_GetConVarValue("rotgb_bloodtype")
		if bloodType>=16 then
			util.Decal(ROTGB_GetConVarValue("rotgb_blooddecal"),self:GetPos()+vector_up,self:GetPos()-vector_up*self:BoundingRadius()*self:GetModelScale(),self)
		elseif bloodType>=8 then
			local inkproj = ents.Create("splashootee")
			if IsValid(inkproj) then
				local CNames = {"Orange","Pink","Purple","Blue","Cyan","Green",[0]="White"}
				--local CCodes = {30,300,270,240,180,120,360}
				--inkproj:SetNoDraw(true)
				inkproj:Setscale(Vector(1,1,1))
				inkproj:SetModel("models/spitball_small.mdl")
				inkproj:SetPos(self:WorldSpaceCenter())
				inkproj:SetOwner(attacker)
				inkproj:SetPhysicsAttacker(attacker)
				inkproj:SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
				inkproj.InkColor = CNames[bloodType-8]
				inkproj.Dmg = 0
				inkproj:Spawn()
				inkproj:GetPhysicsObject():ApplyForceCenter(Vector(0,0,-600))
			end
		end
		local damageType = self.LastDamageType
		self:Pop(-health,nil,damageType)
	end
end

function ENT:OnInjured(dmginfo)
	if dmginfo:GetInflictor():GetClass()~="env_fire" then
		hook.Run("gBalloonTakeDamage", self, dmginfo)
		--self.BalloonRegenTime = self:CurTime()+ROTGB_GetConVarValue("rotgb_regen_delay")
		self.LastAttacker = dmginfo:GetAttacker()
		self.LastInflictor = dmginfo:GetInflictor()
		self.LastDamageType = dmginfo:GetDamageType()
		dmginfo:SetDamage(math.ceil(dmginfo:GetDamage()/10*ROTGB_GetConVarValue("rotgb_damage_multiplier")))
		self:Log("About to take "..dmginfo:GetDamage().." damage at "..self:Health().." health!","damage")
		local resistresults = TestDamageResistances(self.Properties,self.LastDamageType,self:IsFrozen())
		local ignoreResistances = ROTGB_GetConVarValue("rotgb_ignore_damage_resistances") or self:HasRotgBStatusEffect("unimmune")
		if resistresults and not ignoreResistances then
			dmginfo:SetDamage(0)
			self:ShowResistEffect(resistresults)
		end
		if self:HasRotgBStatusEffect("shell_shocked") then
			dmginfo:AddDamage(1)
		end
		local armor = self:GetBalloonProperty("BalloonArmor")
		if armor and not ignoreResistances then
			if armor < 0 then
				dmginfo:AddDamage(-armor)
			else
				dmginfo:SubtractDamage(armor)
			end
			if dmginfo:GetDamage()<=0 and not resistresults then
				self:ShowResistEffect(7)
			end
		end
		if self:GetBalloonProperty("BalloonMaxDamage") and not ignoreResistances then
			if dmginfo:GetDamage() > self:GetBalloonProperty("BalloonMaxDamage") then
				local remainingdamage = dmginfo:GetDamage() - self:GetBalloonProperty("BalloonMaxDamage")
				dmginfo:SetDamage(self:GetBalloonProperty("BalloonMaxDamage")+math.floor(remainingdamage*0.9))
			end
		end
		if self:GetBalloonProperty("BalloonShielded") and self:HasRotgBStatusEffect("unshield") then
			dmginfo:ScaleDamage(2)
		end
		--[[if self.FireSusceptibility and (dmginfo:IsDamageType(DMG_BURN) or IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():GetClass()=="env_fire") then
			dmginfo:ScaleDamage(1+self.FireSusceptibility)
			dmginfo:SetDamage(math.ceil(dmginfo:GetDamage()))
		end]]
		local newhealth = self:Health()-math.max(dmginfo:GetDamage(),0)
		local addDamageThisLayer = self:Health()-math.max(newhealth,1)
		self:SetHealth(newhealth)
		self:Log("Took "..dmginfo:GetDamage().." damage! We are now at "..newhealth.." health.","damage")
		if (IsValid(self.LastInflictor) and (self.LastInflictor.Base == "gballoon_tower_base" or self.LastInflictor:GetClass()=="rotgb_shooter")) and addDamageThisLayer > 0 then
			self.LastInflictor:AddPops(addDamageThisLayer)
			self:Log("Credited "..tostring(self.LastInflictor).." "..addDamageThisLayer.." pop(s).","damage")
			hook.Run("gBalloonDamaged", self, self.LastAttacker, self.LastInflictor, addDamageThisLayer, 0, 0, false)
		end
		if self:GetBalloonProperty("BalloonBoss") then
			self.currentHealthSegment = self.currentHealthSegment or self:GetBalloonProperty("BalloonHealthSegments")
			local newHealthSegment = math.max(math.ceil(self:Health() / self:GetMaxHealth() * self:GetBalloonProperty("BalloonHealthSegments")), 1)
			if self.currentHealthSegment > newHealthSegment then
				for i=newHealthSegment,self.currentHealthSegment-1 do
					self:EmitSound("ambient/alarms/warningbell1.wav", 0)
					local bossEffects = registeredBossEffects[self:GetBalloonProperty("BalloonBossEffect")]
					if (bossEffects and bossEffects.HealthSegment) then
						bossEffects.HealthSegment(self)
					end
				end
				self.currentHealthSegment = newHealthSegment
			end
			self:SetStatusSendRequired(true)
		end
	end
	dmginfo:SetDamage(0)
end

function ENT:ShouldPopOnContact(ent)
	if (ent:GetClass()=="gballoon_target" and ent:GetIsBeacon()) then return false end
	local mask = ROTGB_GetConVarValue("rotgb_pop_on_contact")
	if mask==-1 and self:CanTarget(ent) then return true
	elseif mask<-1 and ent:Health()>0 and ent:GetClass()~="gballoon_base" then return true end
	return self:MaskFilter(mask,ent)
end

function ENT:OnContact(ent)
	if IsValid(ent) then
		if self:ShouldPopOnContact(ent) then self:Pop(-1,ent) end
	end
end

function ENT:OnKilled(dmginfo)
	if ROTGB_GetConVarValue("rotgb_use_kill_handler") then
		base_nextbot.OnKilled(self, dmginfo)
	end
end

local lastEffectRender = 0

function ENT:DetermineNextBalloons(blns,dmgbits,damageLeft,instant)
	local pluses = 0
	local pops = 0
	local newspawns = {}
	local oldnv,opls,opop = 0,0,0
	local minimumEffectiveHealthLeft = math.huge
	for k,v in pairs(blns) do
		local class = v.Type
		local keyvals = savedKeyValueTables[class]
		if not keyvals then
			keyvals = list.Get("NPC")[class].KeyValues
			hook.Run("gBalloonKeyValuesApply", keyvals)
			savedKeyValueTables[class] = keyvals
		end
		local effectiveHealth = --[[(v.Armor or 0) +]] v.Health
		
		if TestDamageResistances(keyvals,dmgbits,v.Frozen) and not self:HasRotgBStatusEffect("unimmune") then
			table.insert(newspawns,v)
		elseif effectiveHealth > 1 and not instant then
			--[[if (v.Armor or 0) > 0 then
				v.Armor = v.Armor - 1
			else]]
				v.Health = v.Health - 1
			--end
			minimumEffectiveHealthLeft = math.min(minimumEffectiveHealthLeft, effectiveHealth - 1)
			pops = pops + v.Amount
			table.insert(newspawns,v)
		elseif self.rotgb_spawns[class] then
			for k2,v2 in pairs(self.rotgb_spawns[class]) do
				local keyvals2 = savedKeyValueTables[k2]
				if not keyvals2 then
					keyvals2 = list.Get("NPC")[k2].KeyValues
					hook.Run("gBalloonKeyValuesApply", keyvals2)
					savedKeyValueTables[k2] = keyvals2
				end
				local nextBalloonShielded = tobool(keyvals2.BalloonShielded) or ROTGB_HasAllBits(v.Properties, 4)
				local crt = {
					Type=keyvals2.BalloonType,
					Amount=v2*v.Amount,
					Health=math.Round(
						(keyvals2.BalloonHealth or 1)*(nextBalloonShielded and 2 or 1)
						*(keyvals2.BalloonBlimp and ROTGB_GetConVarValue("rotgb_blimp_health_multiplier") or 1)*ROTGB_GetConVarValue("rotgb_health_multiplier")
					),
					--Armor=(keyvals2.BalloonArmor or 0)*(nextBalloonShielded and 2 or 1),
					Properties=bit.bor(v.Properties, keyvals2.BalloonShielded and 4 or 0)
				}
				crt.Health = hook.Run("GetgBalloonHealth", crt.BalloonType, crt.Health) or crt.Health
				if ROTGB_HasAllBits(v.Properties, 1) and not v.Blimp then
					crt.PrevBalloons=table.Copy(v.PrevBalloons or {})
					table.insert(crt.PrevBalloons,class)
					if ROTGB_LoggingEnabled("regeneration") then
						self:Log("A gBalloon will regenerate, to a maximum of: "..util.TableToJSON(crt.PrevBalloons,true),"regeneration")
					end
				end
				table.insert(newspawns,crt)
			end
			minimumEffectiveHealthLeft = 0
			pluses = pluses + v.Amount * (1+(v.ExtraCash or 0))
			pops = pops + v.Amount * (v.Health --[[+ (v.Armor or 0)]])
		else
			pluses = pluses + v.Amount * (1+(v.ExtraCash or 0))
			pops = pops + v.Amount * (v.Health --[[+ (v.Armor or 0)]])
		end
	end
	damageLeft = damageLeft - 1
	if minimumEffectiveHealthLeft < math.huge and minimumEffectiveHealthLeft > 0 then
		local extraDamage = math.min(damageLeft, minimumEffectiveHealthLeft) - 1
		if extraDamage > 0 then
			for k,v in pairs(newspawns) do
				local class = v.Type
				local keyvals = savedKeyValueTables[class]
				if not keyvals then
					keyvals = list.Get("NPC")[class].KeyValues
					hook.Run("gBalloonKeyValuesApply", keyvals)
					savedKeyValueTables[class] = keyvals
				end
				if not TestDamageResistances(keyvals,dmgbits,v.Frozen) or self:HasRotgBStatusEffect("unimmune") then
					--[[if (v.Armor or 0) > 0 then
						local resisted = math.min(v.Armor, extraDamage)
						extraDamage = extraDamage - resisted
						v.Armor = v.Armor - resisted
					end]]
					v.Health = v.Health - extraDamage
				end
			end
			damageLeft = damageLeft - extraDamage
		end
	end
	return newspawns,pluses,pops,damageLeft
end

function ENT:Pop(damage,target,dmgbits)
	damage = bit.band(dmgbits or 0,DMG_DISSOLVE)==0 and damage or -1
	self:Log("Popping for "..damage.." damage...","damage")
	hook.Run("gBalloonPrePop", self, damage, target, dmgbits)
	-- self:SetNWBool("BalloonPurple",false)
	local maxToExist = ROTGB_GetConVarValue("rotgb_max_to_exist")
	local doAchievement = ROTGB_GetConVarValue("rotgb_use_achievement_handler")
	local nexts = {{
		Type=self:GetBalloonProperty("BalloonType"),
		Amount=1,Health=1,
		Properties=self:GetBitflagPropertyState(),
		PrevBalloons=self.PrevBalloons,
		Blimp=self:GetBalloonProperty("BalloonBlimp"),
		Frozen=(self.FreezeUntil2 or 0)>self:CurTime(),
		ExtraCash=self:GetBalloonProperty("BalloonCashBonus"),
		--[[Armor=IsValid(target) and (self:GetBalloonProperty("BalloonArmor")*(self:GetBalloonProperty("BalloonShielded") and 2 or 1)) or 0]]
	}}
	local cash = 0
	local deductedCash = 0
	local pops = 0
	local balloonnum = ROTGB_GetBalloonCount()
	--local nextsasstring = self:GetPopSaveString(nexts[1],damage,dmgbits or 0)
	if damage < 0 or damage>self:GetRgBE() then damage = math.huge end
	if ROTGB_LoggingEnabled("popping") then
		self:Log("Before Popping: "..util.TableToJSON(nexts,true),"popping")
	end
	local ctime = SysTime()
	local damageLeft = damage+1
	local spawnedBalloonCount = 1
	local overspawned = spawnedBalloonCount+balloonnum > maxToExist
	while damageLeft > 0 or spawnedBalloonCount+balloonnum > maxToExist do
		local addcash,addpops = 0,0
		nexts,addcash,addpops,damageLeft = self:DetermineNextBalloons(nexts,overspawned and 0 or dmgbits,damageLeft,damage == math.huge)
		if ROTGB_LoggingEnabled("popping") then
			self:Log("Taking "..addpops.." damage, total is now "..pops+addpops.." damage.","popping")
			self:Log("Pop #"..damage+1-damageLeft.." of #"..damage+1 ..": "..util.TableToJSON(nexts,true),"popping")
		end
		if (self.DeductCash or 0)>0 then
			self.DeductCash = self.DeductCash - 1
			deductedCash = deductedCash + addcash
		else
			cash = cash + addcash
		end
		pops = pops + addpops
		spawnedBalloonCount = 0
		for k,v in pairs(nexts) do
			spawnedBalloonCount = spawnedBalloonCount + (v.Amount or 1)
		end
		overspawned = spawnedBalloonCount+balloonnum > maxToExist
		if overspawned then
			damage = math.huge
		end
		if spawnedBalloonCount==0 or addpops==0 then break end
	end
	--[[if next(toAdd) then
		self:Log("Values to push:"..util.TableToJSON(toAdd,true),"popping")
		for k,v in pairs(toAdd) do
			table.Add(nexts,v)
		end
	end]]
	if ROTGB_LoggingEnabled("popping") then
		self:Log("After Popping: "..util.TableToJSON(nexts,true),"popping")
		self:Log("Time taken: "..(SysTime()-ctime)*1000 .." ms","popping")
	end
	if (IsValid(self.LastAttacker) and self.LastAttacker:IsPlayer()) then
		if doAchievement then
			self.LastAttacker:SendLua("achievements.BalloonPopped()") -- What? It's a balloon, right?
		end
	end
	if IsValid(target) then
		local data = {
			attacker = self,
			victim = target,
			damage = (pops+math.max(self:Health(), 1)-1)*ROTGB_GetConVarValue("rotgb_afflicted_damage_multiplier")
		}
		local damage = data.damage
		self:Log("Hurting "..tostring(target).." for "..damage.." damage...","damage")
		
		if target:GetClass() == "gballoon_target" and target:GetOSPs() > 0 and self:GetBalloonProperty("BalloonHealthSegments") > 1 then
			local healthPerSegment = self:GetMaxHealth() / self:GetBalloonProperty("BalloonHealthSegments")
			local ospsLost = math.Clamp(math.floor(self:Health() / healthPerSegment), 0, target:GetOSPs())
			
			damage = damage - healthPerSegment*ospsLost
			target:SetOSPs(target:GetOSPs()-ospsLost)
		end
		
		local dir = target:WorldSpaceCenter() - self:GetPos()
		dir:Normalize()
		dir:Mul(damage)
		
		local dmginfo = DamageInfo()
		dmginfo:SetDamage(damage)
		dmginfo:SetReportedPosition(self:GetPos())
		dmginfo:SetDamageForce(dir)
		dmginfo:SetAttacker(self)
		dmginfo:SetInflictor(self)
		target:TakeDamageInfo(dmginfo)
		hook.Run("RotgBBalloonPostDealDamage", data)
	else
		local baseMul = ROTGB_GetConVarValue("rotgb_cash_mul")
		local newcash = self:GetAndApplyValueMultipliers(cash)
		local toAward = newcash*baseMul
		if engine.ActiveGamemode() == "rotgb" then	
			toAward = toAward * (1+hook.Run("GetSkillAmount", "cashFromBalloons")/100)
		end
		self:Log("Awarding "..toAward.." cash (x"..newcash/cash..") after "..pops.." pops...","damage")
		ROTGB_AddCash(toAward)
		if (IsValid(self.LastInflictor) and (self.LastInflictor.Base == "gballoon_tower_base" or self.LastInflictor:GetClass()=="rotgb_shooter")) and pops > 0 then
			self.LastInflictor:AddPops(pops)
			self:Log("Credited "..tostring(self.LastInflictor).." "..pops.." pop(s).","damage")
			hook.Run("gBalloonDamaged", self, self.LastAttacker, self.LastInflictor, pops, cash, deductedCash, true)
		end
	end
	--for i=1,pops do
		self:EmitSound(self:GetBalloonProperty("BalloonPopSound"),75,math.random(80,120),1)
	--end
	if not self:GetBalloonProperty("BalloonBlimp") and lastEffectRender<CurTime() then
		local effectRenderDelay = 1/ROTGB_GetConVarValue("rotgb_max_effects_per_second")
		if lastEffectRender+effectRenderDelay<CurTime() then
			lastEffectRender = CurTime()
		end
		lastEffectRender = lastEffectRender+effectRenderDelay
		local effdata = EffectData()
		effdata:SetStart(string.ToColor(self:GetBalloonProperty("BalloonColor")):ToVector()*255)
		effdata:SetEntity(self)
		effdata:SetRadius(100)
		effdata:SetScale(1)
		effdata:SetMagnitude(1)
		effdata:SetOrigin(self:GetPos())
		util.Effect("balloon_pop",effdata)
	end
	ctime = SysTime()
	for i,v in ipairs(nexts) do
		for j=1,v.Amount do
			if ROTGB_LoggingEnabled("spawning") then
				self:Log("To Spawn: "..util.TableToJSON(v,true),"spawning")
			end
			local tospawn = v.Type
			local spe = ents.Create("gballoon_base")
			spe:SetPos(self:GetPos()+VectorRand()+vector_up)
			spe.Properties = list.Get("NPC")[tospawn].KeyValues
			spe.Properties.BalloonRegen = spe.Properties.BalloonRegen or ROTGB_HasAllBits(v.Properties, 1)
			spe.Properties.BalloonFast = spe.Properties.BalloonFast or ROTGB_HasAllBits(v.Properties, 2)
			spe.Properties.BalloonShielded = spe.Properties.BalloonShielded or ROTGB_HasAllBits(v.Properties, 4)
			spe.Properties.BalloonHidden = spe.Properties.BalloonHidden or ROTGB_HasAllBits(v.Properties, 8)
			spe:Spawn()
			spe:Activate()
			spe.PrevBalloons = v.PrevBalloons
			spe:SetHealth(v.Health or 1) -- FIXME: this was spe:SetHealth(math.max(v.Health or 1, 1)), is there a difference?
			spe.BalloonRegenTime = self.BalloonRegenTime
			spe.StunUntil = self.StunUntil
			spe.FreezeUntil2 = self.FreezeUntil2
			spe.AcidicList = self.AcidicList
			spe.TravelledDistance = self.TravelledDistance
			spe.rotgb_SpeedMods = self.rotgb_SpeedMods
			spe.rotgb_ValueMultipliers = self.rotgb_ValueMultipliers
			if spe.rotgb_ValueMultipliers and spe.rotgb_ValueMultipliers.ROTGB_TOWER_17 then
				local effData = EffectData()
				effData:SetEntity(spe)
				util.Effect("gballoon_tower_17_morecash", effData)
			end
			if not self:HasRotgBStatusEffect("glue_soak") and spe.rotgb_SpeedMods then
				spe.rotgb_SpeedMods.ROTGB_GLUE_TOWER = nil
			elseif spe.rotgb_SpeedMods and spe.rotgb_SpeedMods.ROTGB_GLUE_TOWER then
				local effData = EffectData()
				effData:SetEntity(spe)
				effData:SetFlags(spe.AcidicList and next(spe.AcidicList) and 1 or 0)
				effData:SetHitBox(self:GetRotgBStatusEffectDuration("glue_soak")*10)
				util.Effect("gballoon_tower_9_glued", effData)
				spe:InflictRotgBStatusEffect("glue_soak", self:GetRotgBStatusEffectDuration("glue_soak"))
			end
			spe.DeductCash = self.DeductCash
			--spe.BeaconsReached = table.Copy(self.BeaconsReached)
			if self.FireData then
				spe.FireData = {
					damage = self.FireData.damage,
					attacker = self.FireData.attacker,
					inflictor = self.FireData.inflictor,
					dietime = self.FireData.dietime
				}
				if lastFireRender<CurTime() then
					local fireRenderDelay = 1/ROTGB_GetConVarValue("rotgb_max_fires_per_second")
					if lastFireRender+fireRenderDelay<CurTime() then
						lastFireRender = CurTime()
					end
					lastFireRender = lastFireRender+fireRenderDelay
					spe:CreateFire(self.FireData.dietime-self:CurTime())
				end
				
				spe.LastBurn = self:CurTime()
			end
			--[[if (self.BurnTime or 0)-0.5 >= self:CurTime() then
				local cBurnTime = self.BurnTime
				timer.Simple(0.5,function()
					if IsValid(spe) then
						spe.BurnTime = cBurnTime
						spe:RotgB_Ignite(spe.BurnTime-self:CurTime())
					end
				end)
			end]]
			spe.LastBeacon = self.LastBeacon
			spe:SetTarget(self:GetTarget())
			--[[timer.Simple(0,function()
				if (IsValid(spe) and spe:Health()<=0) then spe:Pop(-spe:Health()) end
			end)]]
		end
	end
	if ROTGB_LoggingEnabled("spawning") then
		self:Log(string.format("Successfully spawned %i gBalloon type(s).", #nexts),"spawning")
		self:Log(string.format("Time taken: %f ms", (SysTime()-ctime)*1000),"spawning")
	end
	SafeRemoveEntity(self.RotgBFireEnt)
	SafeRemoveEntity(self.FastTrail)
	self:Remove()
end

function ENT:CheckForRegenAndFire()
	if SERVER then
		local curTime = self:CurTime()
		if self.FireData then
			if not (IsValid(self.FireData.attacker) and IsValid(self.FireData.inflictor) and self.FireData.dietime > curTime) then
				self.FireData = nil
				SafeRemoveEntity(self.RotgBFireEnt)
				self:Log("Fire expired!","fire")
			elseif not self.LastBurn then
				self.LastBurn = curTime
			elseif self.LastBurn + ROTGB_GetConVarValue("rotgb_fire_delay") < curTime then
				self.LastBurn = curTime
				local dmginfo = DamageInfo()
				dmginfo:SetDamagePosition(self:GetPos())
				dmginfo:SetDamageType(bit.bor(DMG_BURN,DMG_DIRECT))
				dmginfo:SetDamage(self.FireData.damage)
				dmginfo:SetAttacker(self.FireData.attacker)
				dmginfo:SetInflictor(self.FireData.inflictor)
				dmginfo:SetReportedPosition(self.FireData.inflictor:GetPos())
				self:Log("Taking "..self.FireData.damage.." damage from fire!","fire")
				self:TakeDamageInfo(dmginfo)
			end
		end
		if self:GetBalloonProperty("BalloonRegen") then
			local regenDelay = hook.Run("GetgBalloonRegenDelay", self) or ROTGB_GetConVarValue("rotgb_regen_delay")
			local hasPreviousLayer = self.PrevBalloons and next(self.PrevBalloons)
			local lessThanMaxHealth = self:Health() < self:GetMaxHealth()
			self.BalloonRegenTime = self.BalloonRegenTime or curTime+regenDelay
			if hasPreviousLayer or lessThanMaxHealth then
				if self.BalloonRegenTime <= curTime then
					if hasPreviousLayer then
						local prevballoon = table.remove(self.PrevBalloons)
						self:Log("Regenerating to: "..prevballoon,"regeneration")
						local bits = self:GetBitflagPropertyState()
						self.Properties = list.Get("NPC")[prevballoon].KeyValues
						if ROTGB_HasAllBits(bits, 2) then
							self.Properties.BalloonFast = true
						end
						if ROTGB_HasAllBits(bits, 4) then
							self.Properties.BalloonShielded = true
						end
						if ROTGB_HasAllBits(bits, 8) then
							self.Properties.BalloonHidden = true
						end
						self:SetNWBool("BalloonPurple",false)
						self:SetNWBool("BalloonRainbow",false)
						self:SetNWBool("RenderShield",false)
						self.Properties.BalloonRegen = true
						self:Spawn()
						self:Activate()
						self.DeductCash = (self.DeductCash or 0) + 1
						self:Log("Regenerated to: "..prevballoon..". Fast = "..tostring(ROTGB_HasAllBits(bits, 2))..", Shielded = "..tostring(ROTGB_HasAllBits(bits, 4))..", Hidden = "..tostring(ROTGB_HasAllBits(bits, 8)),"regeneration")
						self:Log("This gBalloon will yield "..self.DeductCash.." less cash than usual.","regeneration")
						self.BalloonRegenTime = curTime+regenDelay
					else
						self:SetHealth(self:Health() + 1)
						self.BalloonRegenTime = curTime+regenDelay
						self:Log("Regenerated 1 health.","regeneration")
					end
				end
			else
				self.BalloonRegenTime = curTime+regenDelay
			end
		end
		if self:GetBalloonProperty("BalloonSuperRegen") > 0 then
			local oldHealth = self:Health()
			local rainbowRegen = ROTGB_GetConVarValue("rotgb_rainbow_gblimp_regen_rate")*self:GetBalloonProperty("BalloonSuperRegen")
			self:SetHealth(math.min(oldHealth+rainbowRegen,self:GetMaxHealth()))
			self:Log("Regenerated "..self:Health()-oldHealth.." health.","regeneration")
		end
	end
end

if CLIENT then
	local damageMaterial = CreateMaterial("gBalloonDamage","UnlitGeneric",{
		["$color"] = "[ 1 1 1 ]",
		["$model"] = 1
	})
	local rainbowDamageMaterial = CreateMaterial("gBalloonRainbowDamage","UnlitGeneric",{
		["$basetexture"] = "vgui/hsv-bar",
		["$model"] = 1
	})
	function ENT:Draw()
		local healthDrawFraction = self:GetNWInt("ActualHealth", self:Health()) / self:GetMaxHealth()
		if healthDrawFraction < 1 and healthDrawFraction > 0 then
			local minZ = self:OBBMins().z
			local maxZ = self:OBBMaxs().z
			local addZ = Lerp(healthDrawFraction, maxZ, minZ)
			local clipPoint = self:GetPos()
			clipPoint.z = clipPoint.z + addZ
			
			local up = self:GetUp()
			local positionTop = up:Dot(clipPoint)
			local down = -up
			local positionBottom = down:Dot(clipPoint)

			local oldClipping = render.EnableClipping(true)
			
			render.PushCustomClipPlane(up, positionTop)
			self:DrawModel()
			render.PopCustomClipPlane()
			
			render.PushCustomClipPlane(down, positionBottom)
			render.MaterialOverride(self:GetNWBool("BalloonRainbow") and rainbowDamageMaterial or damageMaterial)
			self:DrawModel()
			render.MaterialOverride(nil)
			render.PopCustomClipPlane()
			
			render.EnableClipping(oldClipping)
		else
			self:DrawModel()
		end
	end

	local shieldcolor = Color(0,255,255,31)
	function ENT:DrawTranslucent()
		self:Draw()
		if self:GetNWBool("RenderShield") then
			render.SetColorMaterial()
			render.DrawSphere(self:WorldSpaceCenter(),self:BoundingRadius()*self.VModelScale.x,8,5,shieldcolor)
		end
	end
end

function ENT:GetRelationship(ent)
	if SERVER then
		local mask = ROTGB_GetConVarValue("rotgb_target_choice")
		for k,v in pairs(ents.GetAll()) do
			if v:IsNPC() then
				if mask<0 and v:Health()>0 and v:GetClass()~="gballoon_base" then
					v:AddEntityRelationship(self,D_HT,99)
					return D_HT
				elseif self:MaskFilter(mask,v) then
					v:AddEntityRelationship(self,D_HT,99)
					return D_HT
				end
			end
		end
	end
end

function ENT:Think()
	if SERVER then
		self:SetNWInt("ActualHealth", self:Health())
		--[[local shouldRenderShield = self:GetBalloonProperty("BalloonShielded") and self:Health()*2>self:GetMaxHealth() and (not ROTGB_GetConVarValue("rotgb_legacy_gballoons") or ROTGB_GetConVarValue("rotgb_pertain_effects"))
		self:SetNWBool("RenderShield",shouldRenderShield)]]
		if self.StraightMovement then
			self:MoveStraightThink()
		end
	end
	--[[if self:GetBalloonProperty("BalloonHidden") then
		local mgh = CurTime()%2<1.5
		if mgh and not self:GetNoDraw() then
			self:SetNoDraw(true)
		elseif not mgh and self:GetNoDraw() then
			self:SetNoDraw(false)
		end
	end]]
end

hook.Add("EntityKeyValue","RotgB",function(ent,key,value)
	if ent:GetClass()=="func_nav_avoid" or ent:GetClass()=="func_nav_prefer" then
		ent.Enabled = nil
		if not tobool(ent:GetKeyValues().start_disabled) then
			ent.Enabled = true
		end
	end
end)

hook.Add("AcceptInput","RotgB",function(ent,inputname)
	local FNT = ROTGB_GetConVarValue("rotgb_func_nav_expand")
	if ent:GetClass()=="func_nav_avoid" or ent:GetClass()=="func_nav_prefer" then
		if inputname:lower()=="enable" then
			entitiestoconsider[ent] = {ent:GetPos()+ent:OBBMins()+Vector(-FNT,-FNT,-FNT),ent:GetPos()+ent:OBBMaxs()+Vector(FNT,FNT,FNT)}
			ent.Enabled = true
		elseif inputname:lower()=="disable" then
			ent.Enabled = nil
		elseif inputname:lower()=="toggle" then
			ent.Enabled = not ent.Enabled
		end
	elseif ent:GetName()=="wave_finished_relay" and inputname:lower()=="trigger" then
		for k,v in pairs(ents.GetAll()) do
			if ent:GetClass()=="func_nav_avoid" or ent:GetClass()=="func_nav_prefer" then
				ent.Enabled = nil
			end
		end
	end
end)

local drawtable = {}
--local drawtable2 = {}
local visibles = {}
local nextsee = 0
hook.Add("PreDrawHalos","RotgB",function()
	if not ROTGB_GetConVarValue("rotgb_no_glow") then
		local showfrozen = ROTGB_GetConVarValue("rotgb_freeze_effect")
		if nextsee < CurTime() then
			visibles = ROTGB_GetBalloons()
			nextsee = CurTime() + 0.1
		end
		table.Empty(drawtable)
		--table.Empty(drawtable2)
		for k,v in pairs(visibles) do
			if IsValid(v) then
				if v:GetNWFloat("rotgb_FreezeTime")>CurTime() and showfrozen and not v.rotgb_IsFrozen then
					v.rotgb_IsFrozen = true
					local effdata = EffectData()
					effdata:SetEntity(v)
					util.Effect("phys_freeze",effdata)
					--v.rotgb_FreezeTime = CurTime() + 0.5
				elseif v:GetNWFloat("rotgb_FreezeTime")<=CurTime() and v.rotgb_IsFrozen then
					v.rotgb_IsFrozen = nil
					local effdata = EffectData()
					effdata:SetEntity(v)
					util.Effect("phys_unfreeze",effdata)
					--v.rotgb_FreezeTime = CurTime() + 0.5
				end
				--[[if (v.rotgb_FreezeTime and v.rotgb_FreezeTime>CurTime()) and showfrozen then
					table.insert(drawtable2,{{v},(v.rotgb_FreezeTime-CurTime())*4,v.rotgb_IsFrozen})
				end]]
				if v:GetNWBool("BalloonPurple") then
					table.insert(drawtable,v)
				end
			end
		end
		if #drawtable>0 then
			halo.Add(drawtable,Color(0,255,255),2,2,1,true,false)
		end
		--[[for k,v in pairs(drawtable2) do
			local col = v[3] and Color(0,255,0) or Color(255,0,0)
			halo.Add(v[1],col,v[2],v[2],1,true,false)
		end]]
	end
end)



if CLIENT then
	CreateMaterial("gBalloonZebra","VertexLitGeneric",{
		["$basetexture"] = "effects/flashlight/bars",
		["$model"] = 1
	})
	CreateMaterial("gBalloonError","VertexLitGeneric",{
		["$basetexture"] = "___error",
		["$model"] = 1
	})
	CreateMaterial("gBalloonRainbow","VertexLitGeneric",{
		["$basetexture"] = "vgui/hsv-bar",
		["$model"] = 1
	})
	CreateMaterial("gBalloonMonochrome","VertexLitGeneric",{
		["$basetexture"] = "vgui/hsv-brightness",
		["$model"] = 1
	})
end

local minuteclass = {Base = "base_anim", Type = "anim"}

local registerkeys = {
	red = {
		KeyValues = {
			BalloonMoveSpeed = "100",
			BalloonScale = "1",
			BalloonColor = "255 0 0 255",
			BalloonType = "gballoon_red"
		}
	},
	blue = {
		KeyValues = {
			BalloonMoveSpeed = "125",
			BalloonScale = "1.25",
			BalloonColor = "0 127 255 255",
			BalloonType = "gballoon_blue"
		}
	},
	green = {
		KeyValues = {
			BalloonMoveSpeed = "150",
			BalloonScale = "1.5",
			BalloonColor = "127 255 0 255",
			BalloonType = "gballoon_green"
		}
	},
	yellow = {
		KeyValues = {
			BalloonMoveSpeed = "175",
			BalloonScale = "1.75",
			BalloonColor = "255 255 0 255",
			BalloonType = "gballoon_yellow"
		}
	},
	pink = {
		KeyValues = {
			BalloonMoveSpeed = "200",
			BalloonScale = "2",
			BalloonColor = "255 127 127 255",
			BalloonType = "gballoon_pink"
		}
	},
	white = {
		KeyValues = {
			BalloonMoveSpeed = "150",
			BalloonScale = "0.75",
			BalloonColor = "255 255 255 255",
			BalloonType = "gballoon_white",
			BalloonWhite = "1"
		}
	},
	black = {
		KeyValues = {
			BalloonMoveSpeed = "150",
			BalloonScale = "0.75",
			BalloonColor = "0 0 0 255",
			BalloonType = "gballoon_black",
			BalloonBlack = "1"
		}
	},
	purple = {
		KeyValues = {
			BalloonMoveSpeed = "150",
			BalloonScale = "1.5",
			BalloonColor = "127 0 255 255",
			BalloonType = "gballoon_purple",
			BalloonPurple = "1"
		}
	},
	orange = {
		KeyValues = {
			BalloonMoveSpeed = "250",
			BalloonScale = "2.5",
			BalloonColor = "255 127 0 255",
			BalloonType = "gballoon_orange"
		}
	},
	gray = {
		KeyValues = {
			BalloonMoveSpeed = "175",
			BalloonScale = "1.75",
			BalloonColor = "127 127 127 255",
			BalloonType = "gballoon_gray",
			BalloonMaterial = "phoenix_storms/side",
			BalloonGray = "1"
		}
	},
	zebra = {
		KeyValues = {
			BalloonMoveSpeed = "175",
			BalloonScale = "1.75",
			BalloonColor = "255 255 255 255",
			BalloonType = "gballoon_zebra",
			BalloonMaterial = "!gBalloonZebra",
			BalloonWhite = "1",
			BalloonBlack = "1"
		}
	},
	aqua = {
		KeyValues = {
			BalloonMoveSpeed = "175",
			BalloonScale = "1.75",
			BalloonColor = "0 255 255 255",
			BalloonType = "gballoon_aqua",
			BalloonAqua = "1"
		}
	},
	error = {
		KeyValues = {
			BalloonMoveSpeed = "175",
			BalloonScale = "1.75",
			BalloonColor = "255 0 255 255",
			BalloonType = "gballoon_error",
			BalloonMaterial = "!gBalloonError",
			BalloonArmor = "1",
			BalloonBlack = "1"
		}
	},
	rainbow = {
		KeyValues = {
			BalloonMoveSpeed = "200",
			BalloonScale = "2",
			BalloonColor = "255 255 255 255",
			BalloonType = "gballoon_rainbow",
			BalloonMaterial = "!gBalloonRainbow",
			BalloonRainbow = "1"
		}
	},
	ceramic = {
		KeyValues = {
			BalloonMoveSpeed = "225",
			BalloonScale = "2.25",
			BalloonColor = "127 63 0 255",
			BalloonType = "gballoon_ceramic",
			BalloonMaterial = "models/props_debris/plasterceiling008a",
			BalloonHealth = "10"
		}
	},
	brick = {
		KeyValues = {
			BalloonMoveSpeed = "250",
			BalloonScale = "2.5",
			BalloonColor = "255 63 63 255",
			BalloonType = "gballoon_brick",
			BalloonMaterial = "brick/brick_model",
			BalloonHealth = "35",
			--BalloonMaxDamage = "4"
		}
	},
	marble = {
		KeyValues = {
			BalloonMoveSpeed = "275",
			BalloonScale = "2.75",
			BalloonColor = "255 255 255 255",
			BalloonType = "gballoon_marble",
			BalloonMaterial = "phoenix_storms/plastic",
			BalloonHealth = "120",
			--BalloonMaxDamage = "4"
		}
	},
	blimp_blue = {
		KeyValues = {
			BalloonMoveSpeed = "100",
			BalloonScale = "2",
			BalloonColor = "0 127 255 255",
			BalloonType = "gballoon_blimp_blue",
			BalloonMaterial = "models/debug/debugwhite",
			BalloonModel = "models/props_phx/ww2bomb.mdl",
			BalloonHealth = "200",
			BalloonBlimp = "1",
			BalloonPopSound = "ambient/explosions/explode_5.wav"
		}
	},
	blimp_red = {
		KeyValues = {
			BalloonMoveSpeed = "50",
			BalloonScale = "2.25",
			BalloonColor = "255 0 0 255",
			BalloonType = "gballoon_blimp_red",
			BalloonMaterial = "models/debug/debugwhite",
			BalloonModel = "models/props_phx/ww2bomb.mdl",
			BalloonHealth = "700",
			BalloonBlimp = "1",
			BalloonPopSound = "ambient/explosions/explode_5.wav"
		}
	},
	blimp_green = {
		KeyValues = {
			BalloonMoveSpeed = "25",
			BalloonScale = "2.5",
			BalloonColor = "0 255 0 255",
			BalloonType = "gballoon_blimp_green",
			BalloonMaterial = "models/debug/debugwhite",
			BalloonModel = "models/props_phx/ww2bomb.mdl",
			BalloonHealth = "4000",
			BalloonBlimp = "1",
			BalloonPopSound = "ambient/explosions/explode_5.wav"
		}
	},
	blimp_gray = {
		KeyValues = {
			BalloonMoveSpeed = "200",
			BalloonScale = "2",
			BalloonColor = "127 127 127 255",
			BalloonType = "gballoon_blimp_gray",
			BalloonMaterial = "!gBalloonMonochrome",
			BalloonModel = "models/props_phx/ww2bomb.mdl",
			BalloonHealth = "400",
			BalloonBlack = "1",
			BalloonGray = "1",
			BalloonBlimp = "1",
			BalloonPopSound = "ambient/explosions/explode_5.wav"
		}
	},
	blimp_purple = {
		KeyValues = {
			BalloonMoveSpeed = "25",
			BalloonScale = "2.75",
			BalloonColor = "127 0 255 255",
			BalloonType = "gballoon_blimp_purple",
			BalloonMaterial = "models/debug/debugwhite",
			BalloonModel = "models/props_phx/ww2bomb.mdl",
			BalloonHealth = "20000",
			BalloonBlimp = "1",
			BalloonPopSound = "ambient/explosions/explode_5.wav"
		}
	},
	blimp_magenta = {
		KeyValues = {
			BalloonMoveSpeed = "300",
			BalloonScale = "2.25",
			BalloonColor = "255 0 255 255",
			BalloonType = "gballoon_blimp_magenta",
			BalloonMaterial = "models/shiny",
			BalloonModel = "models/props_phx/ww2bomb.mdl",
			BalloonHealth = "1500",
			BalloonBlimp = "1",
			BalloonArmor = "15",
			BalloonPopSound = "ambient/explosions/explode_5.wav"
		}
	},
	blimp_rainbow = {
		KeyValues = {
			BalloonMoveSpeed = "50",
			BalloonScale = "3",
			BalloonColor = "255 255 255 255",
			BalloonType = "gballoon_blimp_rainbow",
			BalloonMaterial = "!gBalloonRainbow",
			BalloonModel = "models/props_phx/ww2bomb.mdl",
			BalloonHealth = "99999",
			BalloonPurple = "1",
			BalloonAqua = "1",
			BalloonRainbow = "1",
			BalloonBlimp = "1",
			BalloonArmor = "15",
			BalloonSuperRegen = "1",
			BalloonPopSound = "ambient/explosions/explode_5.wav"
		}
	}
}

local tokenKeys = {
	"gballoon",
	"gballoon_fast",
	"gballoon_hidden",
	"gballoon_fast_hidden",
	"gballoon_regen",
	"gballoon_fast_regen",
	"gballoon_hidden_regen",
	"gballoon_fast_hidden_regen",
	"gballoon_shielded",
	"gballoon_fast_shielded",
	"gballoon_hidden_shielded",
	"gballoon_fast_hidden_shielded",
	"gballoon_regen_shielded",
	"gballoon_fast_regen_shielded",
	"gballoon_hidden_regen_shielded",
	"gballoon_fast_hidden_regen_shielded",
	"gballoon_blimp",
	"gballoon_blimp_fast",
	"gballoon_blimp_hidden",
	"gballoon_blimp_fast_hidden",
	"gballoon_blimp_regen",
	"gballoon_blimp_fast_regen",
	"gballoon_blimp_hidden_regen",
	"gballoon_blimp_fast_hidden_regen",
	"gballoon_blimp_shielded",
	"gballoon_blimp_fast_shielded",
	"gballoon_blimp_hidden_shielded",
	"gballoon_blimp_fast_hidden_shielded",
	"gballoon_blimp_regen_shielded",
	"gballoon_blimp_fast_regen_shielded",
	"gballoon_blimp_hidden_regen_shielded",
	"gballoon_blimp_fast_hidden_regen_shielded"
}

for i=0,15 do
	for k,v in pairs(table.Copy(registerkeys)) do
		local isBlimp = tobool(v.KeyValues.BalloonBlimp)
		local prefix = "gballoon_"
		if bit.band(i,1)==1 then
			v.KeyValues.BalloonFast = "1"
			prefix = prefix.."fast_"
		end
		if bit.band(i,2)==2 then
			v.KeyValues.BalloonHidden = "1"
			prefix = prefix.."hidden_"
		end
		if bit.band(i,4)==4 then
			v.KeyValues.BalloonRegen = "1"
			prefix = prefix.."regen_"
		end
		if bit.band(i,8)==8 then
			v.KeyValues.BalloonShielded = "1"
			prefix = prefix.."shielded_"
		end
		v.Name = "#rotgb.gballoon.gballoon_"..k
		v.Class = "gballoon_base"
		v.Category = "#rotgb.category."..tokenKeys[i+(isBlimp and 17 or 1)]
		list.Set("NPC",prefix..k,v)
		scripted_ents.Register(minuteclass,prefix..k)
	end
end

-- bosses
local SPAWN_OFFSET = Vector(0,0,10)
function ROTGB_RegisterBossEffect(effectNum, data)
	registeredBossEffects[effectNum] = data
end

list.Set("NPC","gballoon_melon",{
	Name = "#rotgb.gballoon.gballoon_melon",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_boss",
	KeyValues = {
		BalloonMoveSpeed = "25",
		BalloonScale = "1",
		BalloonColor = "127 255 0 255",
		BalloonType = "gballoon_melon",
		BalloonMaterial = "models/props_junk/fruit_objects01",
		BalloonModel = "models/props_junk/watermelon01.mdl",
		BalloonHealth = "1000",
		BalloonBoss = "1",
		BalloonHealthSegments = "5",
		BalloonBossEffect = "earliness",
		BalloonPopSound = "ambient/explosions/citadel_end_explosion1.wav"
	}
})
ROTGB_RegisterBossEffect("earliness", {
	HealthSegment = function(boss)
		for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
			local oldAllowMultiStart = v:GetAllowMultiStart()
			v:SetAllowMultiStart(true)
			v:Use(boss,boss,USE_ON,1)
			v:SetAllowMultiStart(oldAllowMultiStart)
		end
	end
})
list.Set("NPC","gballoon_melon_super",{
	Name = "#rotgb.gballoon.gballoon_melon_super",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_boss_super",
	KeyValues = {
		BalloonMoveSpeed = "25",
		BalloonScale = "1",
		BalloonColor = "127 255 0 255",
		BalloonType = "gballoon_melon_super",
		BalloonMaterial = "models/props_junk/fruit_objects01",
		BalloonModel = "models/props_junk/watermelon01.mdl",
		BalloonHealth = "20000",
		BalloonBoss = "1",
		BalloonHealthSegments = "10",
		BalloonBossEffect = "earliness_super",
		BalloonPopSound = "ambient/explosions/citadel_end_explosion1.wav"
	}
})
ROTGB_RegisterBossEffect("earliness_super", {
	HealthSegment = function(boss)
		for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
			local oldAllowMultiStart = v:GetAllowMultiStart()
			v:SetAllowMultiStart(true)
			v:Use(boss,boss,USE_ON,1)
			v:Use(boss,boss,USE_ON,1)
			v:SetAllowMultiStart(oldAllowMultiStart)
		end
	end
})

list.Set("NPC","gballoon_mossman",{
	Name = "#rotgb.gballoon.gballoon_mossman",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_boss",
	KeyValues = {
		BalloonMoveSpeed = "25",
		BalloonScale = "3",
		BalloonColor = "255 127 0 255",
		BalloonType = "gballoon_mossman",
		BalloonMaterial = "maxofs2d/models/balloon_mossman",
		BalloonModel = "models/maxofs2d/balloon_mossman.mdl",
		BalloonHealth = "5000",
		BalloonBoss = "1",
		BalloonHealthSegments = "5",
		BalloonBossEffect = "ceramicity",
		BalloonPopSound = "ambient/explosions/citadel_end_explosion1.wav"
	}
})
ROTGB_RegisterBossEffect("ceramicity", {
	HealthSegment = function(boss)
		local SpawnPos = boss:GetPos()+SPAWN_OFFSET
		local keyValues = list.GetForEdit("NPC")["gballoon_ceramic"].KeyValues
		for i=1,5 do
			local bln = ents.Create("gballoon_base")
			if IsValid(bln) then
				bln:SetPos(SpawnPos)
				for k,v in pairs(keyValues) do
					bln:SetKeyValue(k,v)
				end
				hook.Run("gBalloonSpawnerPreSpawn", boss, bln, keyValues)
				bln:Spawn()
				bln.TravelledDistance = boss.TravelledDistance
				bln.LastBeacon = boss.LastBeacon
				bln:SetTarget(boss:GetTarget())
				hook.Run("gBalloonSpawnerPostSpawn", boss, bln, keyValues)
				bln:Activate()
			end
		end
	end
})
list.Set("NPC","gballoon_mossman_super",{
	Name = "#rotgb.gballoon.gballoon_mossman_super",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_boss_super",
	KeyValues = {
		BalloonMoveSpeed = "25",
		BalloonScale = "3",
		BalloonColor = "255 127 0 255",
		BalloonType = "gballoon_mossman_super",
		BalloonMaterial = "maxofs2d/models/balloon_mossman",
		BalloonModel = "models/maxofs2d/balloon_mossman.mdl",
		BalloonHealth = "100000",
		BalloonBoss = "1",
		BalloonHealthSegments = "10",
		BalloonBossEffect = "ceramicity_super",
		BalloonPopSound = "ambient/explosions/citadel_end_explosion1.wav"
	}
})
ROTGB_RegisterBossEffect("ceramicity_super", {
	HealthSegment = function(boss)
		local SpawnPos = boss:GetPos()+SPAWN_OFFSET
		local keyValues = list.GetForEdit("NPC")["gballoon_fast_hidden_regen_shielded_ceramic"].KeyValues
		for i=1,5 do
			local bln = ents.Create("gballoon_base")
			if IsValid(bln) then
				bln:SetPos(SpawnPos)
				for k,v in pairs(keyValues) do
					bln:SetKeyValue(k,v)
				end
				hook.Run("gBalloonSpawnerPreSpawn", boss, bln, keyValues)
				bln:Spawn()
				bln.TravelledDistance = boss.TravelledDistance
				bln.LastBeacon = boss.LastBeacon
				bln:SetTarget(boss:GetTarget())
				hook.Run("gBalloonSpawnerPostSpawn", boss, bln, keyValues)
				bln:Activate()
			end
		end
	end
})

list.Set("NPC","gballoon_gman",{
	Name = "#rotgb.gballoon.gballoon_gman",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_boss",
	KeyValues = {
		BalloonMoveSpeed = "25",
		BalloonScale = "3",
		BalloonColor = "255 255 255 255",
		BalloonType = "gballoon_gman",
		BalloonMaterial = "maxofs2d/models/balloon_gman",
		BalloonModel = "models/maxofs2d/balloon_gman.mdl",
		BalloonHealth = "25000",
		BalloonBoss = "1",
		BalloonHealthSegments = "5",
		BalloonBossEffect = "stasis",
		BalloonPopSound = "ambient/explosions/citadel_end_explosion1.wav"
	}
})
ROTGB_RegisterBossEffect("stasis", {
	HealthSegment = function(boss)
		local minDistance = math.huge
		local closestTower = NULL
		for k,v in pairs(ents.GetAll()) do
			if v.Base == "gballoon_tower_base" then
				local sqrDist = v:GetShootPos():DistToSqr(boss:GetPos())
				if not v:IsStunned() and sqrDist < minDistance then
					minDistance = sqrDist
					closestTower = v
				end
			end
		end
		
		if IsValid(closestTower) then
			closestTower:Stun(10)
		end
	end
})
list.Set("NPC","gballoon_gman_super",{
	Name = "#rotgb.gballoon.gballoon_gman_super",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_boss_super",
	KeyValues = {
		BalloonMoveSpeed = "25",
		BalloonScale = "3",
		BalloonColor = "255 255 255 255",
		BalloonType = "gballoon_gman_super",
		BalloonMaterial = "maxofs2d/models/balloon_gman",
		BalloonModel = "models/maxofs2d/balloon_gman.mdl",
		BalloonHealth = "500000",
		BalloonBoss = "1",
		BalloonHealthSegments = "10",
		BalloonBossEffect = "stasis_super",
		BalloonPopSound = "ambient/explosions/citadel_end_explosion1.wav"
	}
})
ROTGB_RegisterBossEffect("stasis_super", {
	HealthSegment = function(boss)
		local highestPrice = 0
		local mostExpensiveTower = NULL
		for k,v in pairs(ents.GetAll()) do
			if (v.Base == "gballoon_tower_base" and not v:IsStunned()) and (v.SellAmount or 0) > highestPrice then
				highestPrice = v.SellAmount
				mostExpensiveTower = v
			end
		end
		
		if IsValid(mostExpensiveTower) then
			mostExpensiveTower:Stun(10)
		end
	end
})

list.Set("NPC","gballoon_blimp_ggos",{
	Name = "#rotgb.gballoon.gballoon_blimp_ggos",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_boss",
	KeyValues = {
		BalloonMoveSpeed = "25",
		BalloonScale = "1",
		BalloonColor = "127 127 127 255",
		BalloonType = "gballoon_blimp_ggos",
		BalloonMaterial = "!gBalloonMonochrome",
		BalloonModel = "models/props_phx/mk-82.mdl",
		BalloonHealth = "100000",
		BalloonBoss = "1",
		BalloonBlimp = "1",
		BalloonGray = "1",
		BalloonBlack = "1",
		BalloonHealthSegments = "5",
		BalloonBossEffect = "shielding",
		BalloonPopSound = "ambient/explosions/citadel_end_explosion1.wav"
	}
})
ROTGB_RegisterBossEffect("shielding", {
	HealthSegment = function(boss)
		boss:SetBalloonProperty("BalloonShielded", true)
		boss.BossShields = (boss.BossShields or 0) + 1
		timer.Simple(10, function()
			if IsValid(boss) then
				boss.BossShields = boss.BossShields - 1
				if boss.BossShields <= 0 then
					boss:SetBalloonProperty("BalloonShielded", false)
				end
			end
		end)
	end
})
list.Set("NPC","gballoon_blimp_ggos_super",{
	Name = "#rotgb.gballoon.gballoon_blimp_ggos_super",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_boss_super",
	KeyValues = {
		BalloonMoveSpeed = "25",
		BalloonScale = "1",
		BalloonColor = "127 127 127 255",
		BalloonType = "gballoon_blimp_ggos_super",
		BalloonMaterial = "!gBalloonMonochrome",
		BalloonModel = "models/props_phx/mk-82.mdl",
		BalloonHealth = "2000000",
		BalloonBoss = "1",
		BalloonBlimp = "1",
		BalloonGray = "1",
		BalloonBlack = "1",
		BalloonHealthSegments = "10",
		BalloonBossEffect = "shielding_super",
		BalloonPopSound = "ambient/explosions/citadel_end_explosion1.wav"
	}
})
ROTGB_RegisterBossEffect("shielding_super", {
	HealthSegment = function(boss)
		boss:SetBalloonProperty("BalloonShielded", true)
		boss:SetHealth(boss:Health()*2)
		boss:SetMaxHealth(boss:GetMaxHealth()*2)
		boss.BossShields = (boss.BossShields or 0) + 1
		timer.Simple(10, function()
			if IsValid(boss) then
				boss:SetHealth(boss:Health()/2)
				boss:SetMaxHealth(boss:GetMaxHealth()/2)
				boss.BossShields = boss.BossShields - 1
				if boss.BossShields <= 0 then
					boss:SetBalloonProperty("BalloonShielded", false)
				end
			end
		end)
	end
})

list.Set("NPC","gballoon_hot_air",{
	Name = "#rotgb.gballoon.gballoon_hot_air",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_boss",
	KeyValues = {
		BalloonMoveSpeed = "25",
		BalloonScale = "0.2",
		BalloonColor = "255 255 255 255",
		BalloonType = "gballoon_hot_air",
		BalloonMaterial = "!gBalloonRainbow",
		BalloonModel = "models/balloons/hot_airballoon.mdl",
		BalloonHealth = "500000",
		BalloonBoss = "1",
		BalloonRainbow = "1",
		BalloonHealthSegments = "5",
		BalloonBossEffect = "slow_intangible",
		BalloonPopSound = "ambient/explosions/citadel_end_explosion1.wav"
	}
})
ROTGB_RegisterBossEffect("slow_intangible", {
	PerSecond = function(boss)
		if not boss:GetBalloonProperty("BalloonVoid") then
			boss.BossSlowTick = ((boss.BossSlowTick or 0) + 1) % 8
			if boss.BossSlowTick == 0 then
				for k,v in pairs(ents.GetAll()) do
					if v.Base == "gballoon_tower_base" then
						v:Stun(1)
					end
				end
			end
		end
	end,
	HealthSegment = function(boss)
		boss:SetBalloonProperty("BalloonVoid", true)
		boss:SetNoDraw(true)
		boss.BossShields = (boss.BossShields or 0) + 1
		timer.Simple(5, function()
			if IsValid(boss) then
				boss.BossShields = boss.BossShields - 1
				if boss.BossShields <= 0 then
					boss:SetBalloonProperty("BalloonVoid", false)
					boss:SetNoDraw(false)
				end
			end
		end)
	end
})
list.Set("NPC","gballoon_hot_air_super",{
	Name = "#rotgb.gballoon.gballoon_hot_air_super",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_boss_super",
	KeyValues = {
		BalloonMoveSpeed = "25",
		BalloonScale = "0.2",
		BalloonColor = "255 255 255 255",
		BalloonType = "gballoon_hot_air_super",
		BalloonMaterial = "!gBalloonRainbow",
		BalloonModel = "models/balloons/hot_airballoon.mdl",
		BalloonHealth = "10000000",
		BalloonBoss = "1",
		BalloonRainbow = "1",
		BalloonHealthSegments = "10",
		BalloonBossEffect = "slow_intangible_super",
		BalloonPopSound = "ambient/explosions/citadel_end_explosion1.wav"
	}
})
ROTGB_RegisterBossEffect("slow_intangible_super", {
	PerSecond = function(boss)
		boss.BossSlowTick = ((boss.BossSlowTick or 0) + 1) % 8
		if boss.BossSlowTick == 0 then
			for k,v in pairs(ents.GetAll()) do
				if v.Base == "gballoon_tower_base" then
					v:Stun(2)
				end
			end
		end
	end,
	HealthSegment = function(boss)
		boss:SetBalloonProperty("BalloonVoid", true)
		boss:SetNoDraw(true)
		boss.BossShields = (boss.BossShields or 0) + 1
		timer.Simple(5, function()
			if IsValid(boss) then
				boss.BossShields = boss.BossShields - 1
				if boss.BossShields <= 0 then
					boss:SetBalloonProperty("BalloonVoid", false)
					boss:SetNoDraw(false)
				end
			end
		end)
	end
})

list.Set("NPC","gballoon_blimp_long_rainbow",{
	Name = "#rotgb.gballoon.gballoon_blimp_long_rainbow",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_boss",
	KeyValues = {
		BalloonMoveSpeed = "50",
		BalloonScale = "1",
		BalloonColor = "255 255 255 255",
		BalloonType = "gballoon_blimp_long_rainbow",
		BalloonMaterial = "!gBalloonRainbow",
		BalloonModel = "models/xqm/panel180.mdl",
		BalloonHealth = "2500000",
		BalloonBoss = "1",
		BalloonPurple = "1",
		BalloonAqua = "1",
		BalloonRainbow = "1",
		BalloonArmor = "15",
		BalloonSuperRegen = "1",
		BalloonHealthSegments = "5",
		BalloonBossEffect = "long_rainbow",
		BalloonPopSound = "ambient/explosions/citadel_end_explosion1.wav"
	}
})
ROTGB_RegisterBossEffect("long_rainbow", {
	HealthSegment = function(boss)
		boss.RainbowMult = (boss.RainbowMult or 1) + 1
		boss:SetBalloonProperty("BalloonArmor", 15*boss.RainbowMult)
		boss:SetBalloonProperty("BalloonSuperRegen", boss.RainbowMult)
		timer.Simple(10, function()
			if IsValid(boss) then
				boss.RainbowMult = boss.RainbowMult - 1
				boss:SetBalloonProperty("BalloonArmor", 15*boss.RainbowMult)
				boss:SetBalloonProperty("BalloonSuperRegen", boss.RainbowMult)
			end
		end)
		
		local SpawnPos = boss:GetPos()+SPAWN_OFFSET
		local keyValues = list.GetForEdit("NPC")["gballoon_blimp_rainbow"].KeyValues
		for i=1,2 do
			local bln = ents.Create("gballoon_base")
			if IsValid(bln) then
				bln:SetPos(SpawnPos)
				for k,v in pairs(keyValues) do
					bln:SetKeyValue(k,v)
				end
				hook.Run("gBalloonSpawnerPreSpawn", boss, bln, keyValues)
				bln:Spawn()
				bln.TravelledDistance = boss.TravelledDistance
				bln.LastBeacon = boss.LastBeacon
				bln:SetTarget(boss:GetTarget())
				hook.Run("gBalloonSpawnerPostSpawn", boss, bln, keyValues)
				bln:Activate()
			end
		end
	end
})
list.Set("NPC","gballoon_blimp_long_rainbow_super",{
	Name = "#rotgb.gballoon.gballoon_blimp_long_rainbow_super",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_boss_super",
	KeyValues = {
		BalloonMoveSpeed = "50",
		BalloonScale = "1",
		BalloonColor = "255 255 255 255",
		BalloonType = "gballoon_blimp_long_rainbow_super",
		BalloonMaterial = "!gBalloonRainbow",
		BalloonModel = "models/xqm/panel180.mdl",
		BalloonHealth = "50000000",
		BalloonBoss = "1",
		BalloonPurple = "1",
		BalloonAqua = "1",
		BalloonRainbow = "1",
		BalloonArmor = "30",
		BalloonSuperRegen = "2",
		BalloonHealthSegments = "10",
		BalloonBossEffect = "long_rainbow_super",
		BalloonPopSound = "ambient/explosions/citadel_end_explosion1.wav"
	}
})
ROTGB_RegisterBossEffect("long_rainbow_super", {
	HealthSegment = function(boss)
		boss.RainbowMult = (boss.RainbowMult or 1) + 1
		boss:SetBalloonProperty("BalloonArmor", 30*boss.RainbowMult)
		boss:SetBalloonProperty("BalloonSuperRegen", 2*boss.RainbowMult)
		timer.Simple(10, function()
			if IsValid(boss) then
				boss.RainbowMult = boss.RainbowMult - 1
				boss:SetBalloonProperty("BalloonArmor", 30*boss.RainbowMult)
				boss:SetBalloonProperty("BalloonSuperRegen", 2*boss.RainbowMult)
			end
		end)
		
		local SpawnPos = boss:GetPos()+SPAWN_OFFSET
		local keyValues = list.GetForEdit("NPC")["gballoon_fast_hidden_regen_shielded_blimp_rainbow"].KeyValues
		for i=1,2 do
			local bln = ents.Create("gballoon_base")
			if IsValid(bln) then
				bln:SetPos(SpawnPos)
				for k,v in pairs(keyValues) do
					bln:SetKeyValue(k,v)
				end
				hook.Run("gBalloonSpawnerPreSpawn", boss, bln, keyValues)
				bln:Spawn()
				bln.TravelledDistance = boss.TravelledDistance
				bln.LastBeacon = boss.LastBeacon
				bln:SetTarget(boss:GetTarget())
				hook.Run("gBalloonSpawnerPostSpawn", boss, bln, keyValues)
				bln:Activate()
			end
		end
	end
})

list.Set("NPC","gballoon_garrydecal",{
	Name = "#rotgb.gballoon.gballoon_garrydecal",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_boss",
	KeyValues = {
		BalloonMoveSpeed = "25",
		BalloonScale = "3",
		BalloonColor = "255 255 0 255",
		BalloonType = "gballoon_garrydecal",
		BalloonMaterial = "maxofs2d/models/balloon_classic_04",
		BalloonHealth = "10000000",
		BalloonBoss = "1",
		BalloonHealthSegments = "5",
		BalloonBossEffect = "kicker",
		BalloonPopSound = "ambient/explosions/citadel_end_explosion1.wav"
	}
})
ROTGB_RegisterBossEffect("kicker", {
	HealthSegment = function(boss)
		local minDistance = math.huge
		local closestTower = NULL
		for k,v in pairs(ents.GetAll()) do
			if v.Base == "gballoon_tower_base" then
				local sqrDist = v:GetShootPos():DistToSqr(boss:GetPos())
				if not v:IsStunned() and sqrDist < minDistance then
					minDistance = sqrDist
					closestTower = v
				end
			end
		end
		
		if IsValid(closestTower) then
			constraint.RemoveAll(closestTower)
			closestTower:SetNotSolid(true)
			closestTower:SetMoveType(MOVETYPE_NONE)
			closestTower:SetNoDraw(true)
			local effdata = EffectData()
			effdata:SetEntity(closestTower)
			util.Effect("entity_remove",effdata,true,true)
			SafeRemoveEntityDelayed(closestTower,1)
			PrintMessage(HUD_PRINTTALK,tostring(closestTower).." has been kicked from the server!")
		end
	end
})
list.Set("NPC","gballoon_garrydecal_super",{
	Name = "#rotgb.gballoon.gballoon_garrydecal_super",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_boss_super",
	KeyValues = {
		BalloonMoveSpeed = "25",
		BalloonScale = "3",
		BalloonColor = "255 255 0 255",
		BalloonType = "gballoon_garrydecal_super",
		BalloonMaterial = "maxofs2d/models/balloon_classic_04",
		BalloonHealth = "200000000",
		BalloonBoss = "1",
		BalloonHealthSegments = "10",
		BalloonBossEffect = "kicker_super",
		BalloonPopSound = "ambient/explosions/citadel_end_explosion1.wav"
	}
})
ROTGB_RegisterBossEffect("kicker_super", {
	PerSecond = function(boss)
		for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
			if v:GetWave() > v:GetLastWave() then
				v:SetLastWave(v:GetWave())
			end
		end
	end,
	HealthSegment = function(boss)
		local highestPrice = 0
		local mostExpensiveTower = NULL
		for k,v in pairs(ents.GetAll()) do
			if (v.Base == "gballoon_tower_base" and not v:IsStunned()) and (v.SellAmount or 0) > highestPrice then
				highestPrice = v.SellAmount
				mostExpensiveTower = v
			end
		end
		
		if IsValid(mostExpensiveTower) then
			constraint.RemoveAll(mostExpensiveTower)
			mostExpensiveTower:SetNotSolid(true)
			mostExpensiveTower:SetMoveType(MOVETYPE_NONE)
			mostExpensiveTower:SetNoDraw(true)
			local effdata = EffectData()
			effdata:SetEntity(mostExpensiveTower)
			util.Effect("entity_remove",effdata,true,true)
			SafeRemoveEntityDelayed(mostExpensiveTower,1)
			PrintMessage(HUD_PRINTTALK,tostring(mostExpensiveTower).." has been kicked from the server!")
		end
	end
})

-- special
list.Set("NPC","gballoon_void",{
	Name = "#rotgb.gballoon.gballoon_void",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_miscellaneous",
	KeyValues = {
		BalloonMoveSpeed = "500",
		BalloonScale = "3",
		BalloonType = "gballoon_void",
		BalloonMaterial = "models/wireframe",
		BalloonColor = "255 255 255 255",
		BalloonVoid = "1"
	}
})
list.Set("NPC","gballoon_glass",{
	Name = "#rotgb.gballoon.gballoon_glass",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_miscellaneous",
	KeyValues = {
		BalloonMoveSpeed = "100",
		BalloonScale = "3",
		BalloonColor = "255 255 255 255",
		BalloonType = "gballoon_glass",
		BalloonMaterial = "phoenix_storms/glass",
		BalloonGlass = "1"
	}
})
list.Set("NPC","gballoon_cfiber",{
	Name = "#rotgb.gballoon.gballoon_cfiber",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_miscellaneous",
	KeyValues = {
		BalloonMoveSpeed = "100",
		BalloonScale = "3",
		BalloonColor = "127 127 127 255",
		BalloonType = "gballoon_cfiber",
		BalloonMaterial = "phoenix_storms/mat/mat_phx_carbonfiber2",
		BalloonHealth = "999999999",
		BalloonBoss = "1",
		BalloonHealthSegments = "111"
	}
})
list.Set("NPC","gballoon_hidden",{
	Name = "#rotgb.gballoon.gballoon_hidden",
	Class = "gballoon_base",
	Category = "#rotgb.category.gballoon_miscellaneous",
	KeyValues = {
		BalloonMoveSpeed = "150",
		BalloonScale = "1.5",
		BalloonColor = "0 255 0 255",
		BalloonType = "gballoon_hidden",
		BalloonMaterial = "models/xqm/cellshadedcamo_diffuse",
		BalloonHidden = "1"
	}
})
scripted_ents.Register(minuteclass,"gballoon_void")
scripted_ents.Register(minuteclass,"gballoon_glass")
scripted_ents.Register(minuteclass,"gballoon_cfiber")
scripted_ents.Register(minuteclass,"gballoon_hidden")