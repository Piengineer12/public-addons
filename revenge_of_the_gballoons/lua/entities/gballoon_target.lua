AddCSLuaFile()

local gballoon_pob = baseclass.Get("gballoon_path_object_base") -- internally sets ENT.Base and ENT.Type too
ENT.PrintName = "#rotgb.gballoon_target"
ENT.Category = "#rotgb.category.miscellaneous"
ENT.ScriptedEntityType = "entity"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "#rotgb.gballoon_target.purpose"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Editable = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.DisableDuplicator = false

if SERVER then
	util.AddNetworkString("rotgb_target_received_damage")
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"GBOnly",{KeyName="gballoon_damage_only",Edit={title="#rotgb.gballoon_target.properties.gballoon_damage_only",type="Boolean"}})
	self:NetworkVar("Bool",1,"IsBeacon",{KeyName="is_beacon",Edit={title="#rotgb.gballoon_target.properties.is_beacon",type="Boolean"}})
	self:NetworkVar("Bool",2,"Teleport",{KeyName="teleport_to",Edit={title="#rotgb.gballoon_target.properties.teleport_to",type="Boolean"}})
	self:NetworkVar("Bool",3,"UnSpectatable")
	self:NetworkVar("Bool",4,"NonVital")
	self:NetworkVar("Bool",5,"HideHealth")
	self:NetworkVar("Bool",6,"StraightPath",{KeyName="straight_path",Edit={title="#rotgb.gballoon_target.properties.straight_path",type="Boolean"}})
	self:NetworkVar("Int",0,"Weight",{KeyName="weight",Edit={title="#rotgb.gballoon_target.properties.weight",type="Int",min=0,max=100}})
	self:NetworkVar("Int",1,"GoldenHealth",{KeyName="golden_health",Edit={title="#rotgb.gballoon_target.properties.golden_health",type="Int",min=0,max=100}})
	self:NetworkVar("Int",2,"OSPs",{KeyName="fatal_damage_negations",Edit={title="#rotgb.gballoon_target.properties.fatal_damage_negations",type="Int",min=0,max=100}})
	self:NetworkVar("Int",4,"PerWaveShield")
	self:NetworkVar("Float",0,"NaturalHealthMultiplier")
	self:NetworkVar("Float",1,"PerWaveShieldPercent",{KeyName="per_wave_shield_percent",Edit={title="#rotgb.gballoon_target.properties.per_wave_shield_percent",type="Float",min=0,max=100}})
	return gballoon_pob.SetupDataTables(self)
end

function ENT:KeyValue(key,value)
	local lkey = key:lower()
	if lkey=="natural_health_multiplier" then
		self:SetNaturalHealthMultiplier(tonumber(value) or 0)
	elseif lkey=="gballoon_damage_only" then
		self:SetGBOnly(tobool(value))
	elseif lkey=="hide_health" then
		self:SetHideHealth(tobool(value))
	elseif lkey=="non_vital" then
		self:SetNonVital(tobool(value))
	elseif lkey=="is_waypoint" then
		self:SetIsBeacon(tobool(value))
	elseif lkey=="teleport_to" then
		self:SetTeleport(tobool(value))
	elseif lkey=="straight_path" then
		self:SetStraightPath(tobool(value))
	elseif lkey=="weight" then
		self:SetWeight(tonumber(value) or 0)
	elseif lkey=="onbreak" then
		self:StoreOutput(key,value)
	elseif lkey=="onhealthchanged" then
		self:StoreOutput(key,value)
	elseif lkey=="onmaxhealthchanged" then
		self:StoreOutput(key,value)
	elseif lkey=="onkilled" then
		self:StoreOutput(key,value)
	elseif lkey=="ontakedamage" then
		self:StoreOutput(key,value)
	elseif lkey=="onwaypointed" then
		self:StoreOutput(key,value)
	elseif lkey=="onwaypointedblimp" then
		self:StoreOutput(key,value)
	elseif lkey=="onwaypointednonblimp" then
		self:StoreOutput(key,value)
	elseif lkey=="health" or lkey=="max_health" then
		if (tonumber(value) or 0) <= 0 then return true end
	end
	return gballoon_pob.KeyValue(self,lkey,value)
end

function ENT:AcceptInput(input,activator,caller,data)
	input = input:lower()
	if input=="setnaturalhealthmultiplier" then
		local newMul = tonumber(data) or 0
		if self:GetNaturalHealthMultiplier() == 0 then
			local naturalHealth = ROTGB_GetConVarValue("rotgb_target_natural_health") * newMul
			self:SetMaxHealth(naturalHealth)
			self:SetHealth(naturalHealth)
		else
			local multiplier = newMul / self:GetNaturalHealthMultiplier()
			self:SetMaxHealth(self:GetMaxHealth() * multiplier)
			self:SetHealth(self:Health() * multiplier)
		end
		self:SetNaturalHealthMultiplier(newMul)
	elseif input=="setweight" then
		self:SetWeight(tonumber(data) or 0)
	elseif input=="sethealth" then
		self:SetHealth(tonumber(data) or 0)
		self:TriggerOnHealthChanged()
		if self:Health()<=0 then
			self:TriggerOutput("OnBreak",activator)
			self:Input("Kill",activator,self,data)
		end
	elseif input=="addhealth" then
		self:SetHealth(self:Health()+(tonumber(data) or 0))
		self:TriggerOnHealthChanged()
	elseif input=="removehealth" then
		self:SetHealth(self:Health()-(tonumber(data) or 0))
		self:TriggerOnHealthChanged()
		if self:Health()<=0 then
			self:TriggerOutput("OnBreak",activator)
			self:Input("Kill",activator,self,data)
		end
	elseif input=="healhealth" then
		self:SetHealth(math.min(self:Health()+(tonumber(data) or 0), self:GetMaxHealth()))
		self:TriggerOnHealthChanged()
	elseif input=="setmaxhealth" then
		self:SetMaxHealth(tonumber(data) or 0)
		self:TriggerOnMaxHealthChanged()
	elseif input=="addmaxhealth" then
		self:SetMaxHealth(self:GetMaxHealth()+(tonumber(data) or 0))
		self:TriggerOnMaxHealthChanged()
	elseif input=="removemaxhealth" then
		self:SetMaxHealth(self:GetMaxHealth()-(tonumber(data) or 0))
		self:TriggerOnMaxHealthChanged()
	elseif input=="healmaxhealth" then
		self:SetHealth(math.min(self:Health()+(tonumber(data) or 1)*self:GetMaxHealth(), self:GetMaxHealth()))
		self:TriggerOnHealthChanged()
	elseif input=="break" then
		self:SetHealth(0)
		self:TriggerOnHealthChanged()
		self:TriggerOutput("OnBreak",activator)
		self:Input("Kill",activator,self,data)
	end
	self:CheckBoolEDTInput(input, "balloondamageonly", "GBOnly")
	self:CheckBoolEDTInput(input, "nonvitality", "NonVital")
	self:CheckBoolEDTInput(input, "hidehealth", "HideHealth")
	self:CheckBoolEDTInput(input, "waypointing", "IsBeacon")
	self:CheckBoolEDTInput(input, "teleporting", "Teleport")
	self:CheckBoolEDTInput(input, "straightpath", "StraightPath")
	return gballoon_pob.AcceptInput(self,input,activator,caller,data)
end

function ENT:SpawnFunction(ply,trace,classname)
	if not trace.Hit then return end
	
	local ent = ents.Create(classname)
	ent:SetPos(trace.HitPos+trace.HitNormal*5)
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:Initialize()
	if SERVER then
		local healthOverride = ROTGB_GetConVarValue("rotgb_target_health_override")
		if healthOverride > 0 then
			self:SetHealth(healthOverride)
			self:SetMaxHealth(healthOverride)
		elseif self.CurHealth then
			self:SetHealth(self.CurHealth)
			self:SetMaxHealth(self.CurMaxHealth)
		elseif self:GetNaturalHealthMultiplier() ~= 0 then
			local naturalHealth = ROTGB_GetConVarValue("rotgb_target_natural_health") * self:GetNaturalHealthMultiplier()
			self.notYetCorrectedNaturalHealth = naturalHealth
			self:SetHealth(naturalHealth)
			self:SetMaxHealth(naturalHealth)
		end
		gballoon_pob.Initialize(self)
	end
end

function ENT:Think()
	self.oldHealth = self.oldHealth or self:Health()
	self.oldMaxHealth = self.oldMaxHealth or self:GetMaxHealth()
	if self.notYetCorrectedNaturalHealth then
		local naturalHealth = hook.Run("gBalloonTargetHealthAdjust", self, self.notYetCorrectedNaturalHealth)
		if naturalHealth then
			self:SetHealth(naturalHealth)
			self:SetMaxHealth(naturalHealth)
		end
		self.notYetCorrectedNaturalHealth = nil
	end
	self:TriggerOnHealthChanged()
	self:TriggerOnMaxHealthChanged()
end

function ENT:PreEntityCopy(...)
	self.CurHealth = self:Health()
	self.CurMaxHealth = self:GetMaxHealth()
	gballoon_pob.PreEntityCopy(self,...)
end

function ENT:PostEntityPaste(ply,ent,tab)
	if self.CurHealth then
		self:SetHealth(self.CurHealth)
	end
	if self.CurMaxHealth then
		self:SetMaxHealth(self.CurMaxHealth)
	end
	gballoon_pob.PostEntityPaste(self,ply,ent,tab)
end

function ENT:TriggerOnHealthChanged()
	if self:Health()~=self.oldHealth then
		if SERVER then
			self:TriggerOutput("OnHealthChanged",activator,self:Health()/self:GetMaxHealth())
			--[[net.Start("rotgb_target_received_damage")
			net.WriteEntity(self)
			net.WriteInt(self:Health(), 32)
			net.WriteInt(self:GetGoldenHealth(), 32)
			net.WriteUInt(3, 8)
			net.Broadcast()]]
		end
		
		self.oldHealth = self:Health()
	end
end

function ENT:TriggerOnMaxHealthChanged(oldMaxHealth)
	if self:GetMaxHealth()~=self.oldMaxHealth then
		if SERVER then
			self:TriggerOutput("OnMaxHealthChanged",activator,self:GetMaxHealth())
			--[[net.Start("rotgb_target_received_damage")
			net.WriteEntity(self)
			net.WriteInt(self:GetMaxHealth(), 32)
			net.WriteInt(self:GetGoldenHealth(), 32)
			net.WriteUInt(7, 8)
			net.Broadcast()]]
		end
		
		self.oldMaxHealth = self:GetMaxHealth()
	end
end

function ENT:OnTakeDamage(dmginfo)
	if not self:GetGBOnly() or (IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():GetClass()=="gballoon_base") then
		self:TriggerOutput("OnTakeDamage",dmginfo:GetAttacker(),dmginfo:GetDamage())
		self:EmitSound("physics/metal/metal_box_break"..math.random(1,2)..".wav",60)
		local oldNonGoldenHealth = self:Health()
		local oldHealth = oldNonGoldenHealth+self:GetGoldenHealth()+self:GetPerWaveShield()
		hook.Run("gballoonTargetTakeDamage", self, dmginfo)
		
		local shieldReduction = math.ceil(math.min(self:GetPerWaveShield(), dmginfo:GetDamage()))
		self:SetPerWaveShield(self:GetPerWaveShield()-shieldReduction)
		dmginfo:SubtractDamage(shieldReduction)
		
		if self:GetOSPs() > 0 and math.ceil(dmginfo:GetDamage()) >= oldHealth then
			dmginfo:SetDamage(0)
			self:SetOSPs(self:GetOSPs()-1)
		end
		
		local goldenHealthReduction = math.ceil(math.min(self:GetGoldenHealth(), dmginfo:GetDamage()))
		self:SetGoldenHealth(self:GetGoldenHealth()-goldenHealthReduction)
		ROTGB_AddCash(goldenHealthReduction*ROTGB_GetConVarValue("rotgb_cash_mul"))
		dmginfo:SubtractDamage(goldenHealthReduction)
		
		self:SetHealth(oldNonGoldenHealth-dmginfo:GetDamage())
		self.oldHealth = self:Health()
		dmginfo:SetDamage(0)
		
		local attacker = dmginfo:GetAttacker()
		local flags = bit.bor(
			IsValid(attacker) and attacker:GetClass()=="gballoon_base" and 1 or 0,
			attacker:IsPlayer() and 2 or 0
		)
		if bit.band(flags, 1)==1 then
			flags = bit.bor(
				flags,
				attacker:GetBalloonProperty("BalloonFast") and 4 or 0,
				attacker:GetBalloonProperty("BalloonHidden") and 8 or 0,
				attacker:GetBalloonProperty("BalloonRegen") and 16 or 0,
				attacker:GetBalloonProperty("BalloonShielded") and 32 or 0
			)
		end
		
		hook.Run("PostgballoonTargetTakeDamage", self, dmginfo)
		
		local label = bit.band(flags, 2)==2 and attacker:UserID() or bit.band(flags, 1)==1 and attacker:GetBalloonProperty("BalloonType") or IsValid(attacker) and attacker:GetClass() or "<unknown>"
		net.Start("rotgb_target_received_damage", true)
		net.WriteEntity(self)
		--net.WriteInt(self:Health(), 32)
		--net.WriteInt(self:GetGoldenHealth(), 32)
		net.WriteUInt(flags, 8)
		net.WriteString(label)
		net.WriteInt(oldHealth-self:Health()-self:GetGoldenHealth()-self:GetPerWaveShield(), 32)
		net.Broadcast()
		if oldNonGoldenHealth~=self:Health() then
			self:TriggerOutput("OnHealthChanged",dmginfo:GetAttacker(),self:Health()/self:GetMaxHealth())
		end
		if self:Health()<=0 then
			self:TriggerOutput("OnBreak",dmginfo:GetAttacker())
			self:Input("Kill",dmginfo:GetAttacker(),dmginfo:GetInflictor())
		end
	end
end

function ENT:OnRemove()
	if SERVER then
		hook.Run("gBalloonTargetRemoved", self)
		self:TriggerOutput("OnKilled")
	end
end

function ENT:DrawTranslucent()
	--self:Draw()
	if not (self:GetIsBeacon() or self:GetHideHealth()) then
		--self:DrawModel()
		local actualHealth = --[[self.rotgb_ActualHealth or]] self:Health()
		local actualMaxHealth = --[[self.rotgb_ActualMaxHealth or]] self:GetMaxHealth()
		local text1 = ROTGB_LocalizeString("rotgb.gballoon_target.health", actualHealth)
		surface.SetFont("DermaLarge")
		local t1x,t1y = surface.GetTextSize(text1)
		local reqang = (self:GetPos()-LocalPlayer():GetShootPos()):Angle()
		reqang.p = 0
		reqang.y = reqang.y-90
		reqang.r = 90
		cam.Start3D2D(self:GetPos()+Vector(0,0,ROTGB_GetConVarValue("rotgb_hoverover_distance")+t1y*0.1+self:OBBMaxs().z),reqang,0.2)
			surface.SetDrawColor(0,0,0,127)
			surface.DrawRect(t1x/-2,t1y/-2,t1x,t1y)
			surface.SetTextColor(HSVToColor(math.Clamp(actualHealth/actualMaxHealth*120,0,120),1,1))
			surface.SetTextPos(t1x/-2,t1y/-2)
			surface.DrawText(text1)
		cam.End3D2D()
	end
end

if engine.ActiveGamemode() == "rotgb" then
	hook.Add("gBalloonSpawnerWaveEnded", "ROTGB_TARGET", function(target, endedWave)
		if hook.Run("GetSkillAmount", "targetRegeneration") > 0 then
			for k,v in pairs(ents.FindByClass("gballoon_target")) do
				v:SetPerWaveShield(v:GetMaxHealth()*v:GetPerWaveShieldPercent()/100)
				local healing = math.max(math.min(v:GetMaxHealth()-v:Health(), math.floor(hook.Run("GetSkillAmount", "targetRegeneration"))), 0)
				v:SetHealth(v:Health()+healing)
				if healing > 0 then
					net.Start("rotgb_target_received_damage")
					net.WriteEntity(v)
					--net.WriteInt(v:Health(), 32)
					--net.WriteInt(v:GetGoldenHealth(), 32)
					net.WriteUInt(0, 8)
					net.WriteString("rotgb_tg.skills.names.regeneration")
					net.WriteInt(-healing, 32)
					net.Broadcast()
				end
			end
		end
	end)
end

local function CreateHealthManipulationOption(amt,subOperation,ent)
	return function()
		if IsValid(ent) then
			net.Start("rotgb_generic")
			net.WriteUInt(ROTGB_OPERATION_HEALTH_EDIT,8)
			net.WriteEntity(ent)
			net.WriteUInt(subOperation, 4)
			net.WriteInt(amt, 32)
			net.SendToServer()
		end
	end
end

local function PopulateHealthMenu(menu,data,ent)
	menu:AddOption("1", CreateHealthManipulationOption(1,data,ent))
	menu:AddOption("2", CreateHealthManipulationOption(2,data,ent))
	menu:AddOption("5", CreateHealthManipulationOption(5,data,ent))
	menu:AddOption("10", CreateHealthManipulationOption(10,data,ent))
	menu:AddOption("20", CreateHealthManipulationOption(20,data,ent))
	menu:AddOption("50", CreateHealthManipulationOption(50,data,ent))
	menu:AddOption("100", CreateHealthManipulationOption(100,data,ent))
	menu:AddOption("150", CreateHealthManipulationOption(150,data,ent))
	menu:AddOption("200", CreateHealthManipulationOption(200,data,ent))
	menu:AddOption("500", CreateHealthManipulationOption(500,data,ent))
	menu:AddOption("999,999,999", CreateHealthManipulationOption(999999999,data,ent))
end

properties.Add("rotgb_modhealth", {
	MenuLabel = "#rotgb.gballoon_target.health.modify",
	StructureField = 3000,
	Filter = function(tab,ent) return ent:GetClass()=="gballoon_target" and LocalPlayer():IsAdmin() end,
	MenuOpen = function(tab,menuOpt,ent,trace)
		local modOpt = menuOpt:AddSubMenu()
		PopulateHealthMenu(modOpt:AddSubMenu("#rotgb.gballoon_target.health.set"), ROTGB_HEALTH_SET, ent)
		PopulateHealthMenu(modOpt:AddSubMenu("#rotgb.gballoon_target.health.heal"), ROTGB_HEALTH_HEAL, ent)
		PopulateHealthMenu(modOpt:AddSubMenu("#rotgb.gballoon_target.health.add"), ROTGB_HEALTH_ADD, ent)
		PopulateHealthMenu(modOpt:AddSubMenu("#rotgb.gballoon_target.health.sub"), ROTGB_HEALTH_SUB, ent)
	end
})

properties.Add("rotgb_modmaxhealth", {
	MenuLabel = "#rotgb.gballoon_target.max_health.modify",
	StructureField = 3001,
	Filter = function(tab,ent) return ent:GetClass()=="gballoon_target" and LocalPlayer():IsAdmin() end,
	MenuOpen = function(tab,menuOpt,ent,trace)
		local modOpt = menuOpt:AddSubMenu()
		PopulateHealthMenu(modOpt:AddSubMenu("#rotgb.gballoon_target.max_health.set"), ROTGB_MAXHEALTH_SET, ent)
		PopulateHealthMenu(modOpt:AddSubMenu("#rotgb.gballoon_target.max_health.add"), ROTGB_MAXHEALTH_ADD, ent)
		PopulateHealthMenu(modOpt:AddSubMenu("#rotgb.gballoon_target.max_health.sub"), ROTGB_MAXHEALTH_SUB, ent)
	end
})

list.Set("NPC","gballoon_target_100",{
	Name = "#rotgb.gballoon_target",
	Class = "gballoon_target",
	Category = "#rotgb.category.miscellaneous",
	KeyValues = {
		natural_health_multiplier = "1"
	}
})
list.Set("NPC","gballoon_target_op",{
	Name = "#rotgb.gballoon_target.sandbox",
	Class = "gballoon_target",
	Category = "#rotgb.category.miscellaneous",
	KeyValues = {
		health = "999999999",
		max_health = "999999999"
	}
})
list.Set("SpawnableEntities","gballoon_target_100",{
	PrintName = "#rotgb.gballoon_target",
	ClassName = "gballoon_target",
	Category = "#rotgb.category.miscellaneous",
	KeyValues = {
		natural_health_multiplier = "1"
	}
})
list.Set("SpawnableEntities","gballoon_target_op",{
	PrintName = "#rotgb.gballoon_target.sandbox",
	ClassName = "gballoon_target",
	Category = "#rotgb.category.miscellaneous",
	KeyValues = {
		health = "999999999",
		max_health = "999999999"
	}
})