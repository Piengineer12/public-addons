AddCSLuaFile()

SWEP.Category			= "RotgB"
SWEP.Spawnable			= true
--	SWEP.AdminOnly			= false
SWEP.PrintName			= "RotgB Multitool"
--	SWEP.Base				= weapon_base
SWEP.m_WeaponDeploySpeed= 1
SWEP.Author				= "Piengineer"
SWEP.Contact			= "http://steamcommunity.com/id/Piengineer12/"
SWEP.Purpose			= "A gun that can do several things."
SWEP.Instructions		= "See on-screen HUD for instructions."
SWEP.ViewModel			= "models/weapons/cstrike/c_c4.mdl"
--	SWEP.ViewModelFlip		= false
--	SWEP.ViewModelFlip1		= false
--	SWEP.ViewModelFlip2		= false
SWEP.ViewModelFOV		= 30
SWEP.WorldModel			= "models/weapons/w_c4.mdl"
SWEP.AutoSwitchFrom		= false
SWEP.AutoSwitchTo		= false
--	SWEP.Weight				= 5
--	SWEP.BobScale			= 1
--	SWEP.SwayScale			= 1
--	SWEP.BounceWeaponIcon	= true
--	SWEP.DrawWeaponInfoBox	= true
--	SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= false
--	SWEP.RenderGroup		= RENDERGROUP_OPAQUE
SWEP.Slot				= 1
--	SWEP.SlotPos			= 10
--	SWEP.SpeechBubbleLid	= surface.GetTextureID("gui/speech_lid")
--	SWEP.WepSelectIcon		= surface.GetTextureID("weapons/swep")
--	SWEP.CSMuzzleFlashes	= false
--	SWEP.CSMuzzleX			= false
SWEP.Primary			= {
	Ammo		= "Battery",
	ClipSize	= 8,
	DefaultClip	= 8,
	Automatic	= false
}
SWEP.Secondary			= {
	Ammo		= "none",
	ClipSize	= -1,
	DefaultClip	= -1,
	Automatic	= false
}
SWEP.UseHands			= true
--	SWEP.AccurateCrosshair	= false
--	SWEP.DisableDuplicator	= false
--	SWEP.m_bPlayPickupSound	= true
SWEP.CommonTraceData = {}
SWEP.TraceResult = {}

function SWEP:GetCashText(amount)
	if amount == math.huge then return "∞"
	elseif amount == -math.huge then return "-∞"
	elseif not (amount < 0 or amount >= 0) then return "☠"
	else return string.Comma(math.Round(amount,0))
	end
end

function SWEP:BuildTowerTable()
	local towertable = {}
	for k,v in pairs(scripted_ents.GetList()) do
		if v.Base == "gballoon_tower_base" then
			table.insert(towertable, {class=v.t.ClassName, name=v.t.PrintName, cost=v.t.Cost, model=v.t.Model, infinite=v.t.InfiniteRange, range=v.t.DetectionRadius,
			damage=v.t.AttackDamage, firerate=v.t.FireRate, losoffset=v.t.LOSOffset or vector_origin, material=Material("vgui/entities/"..v.t.ClassName)})
		end
	end
	table.sort(towertable, function(a,b)
		if a.cost == b.cost then
			return a.name < b.name
		else
			return a.cost < b.cost
		end
	end)
	return towertable
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int",0,"Mode")
	self:NetworkVar("Int",1,"CurrentTower")
	self:NetworkVar("Bool",0,"ServerMentionBlock")
end

function SWEP:BuildTraceData(ent)
	self.CommonTraceData.start = ent:GetShootPos()
	self.CommonTraceData.endpos = ent:GetShootPos() + ent:GetAimVector() * 32767
	self.CommonTraceData.filter = ent
	self.CommonTraceData.output = self.TraceResult
	util.TraceLine(self.CommonTraceData)
	return self.CommonTraceData.output
end

function SWEP:OnReloaded()
	self.TowerTable = nil
end

function SWEP:CapabilitiesGet()
	return bit.bor(CAP_MOVE_GROUND, CAP_MOVE_JUMP, CAP_MOVE_CLIMB, CAP_MOVE_CRAWL,
	CAP_MOVE_SHOOT, CAP_USE, CAP_AUTO_DOORS, CAP_OPEN_DOORS, CAP_TURN_HEAD,
	CAP_WEAPON_RANGE_ATTACK1, CAP_WEAPON_MELEE_ATTACK1, CAP_INNATE_RANGE_ATTACK1,
	CAP_INNATE_MELEE_ATTACK1, CAP_USE_WEAPONS, CAP_ANIMATEDFACE, CAP_SQUAD,
	CAP_DUCK, CAP_AIM_GUN)
end

local ReadyTime = -1
local Readys = 0
local IsolatedStartTimer, IsolatedStopTimer

IsolatedStartTimer = function(ent)
	if ent then
		PrintMessage(HUD_PRINTTALK, ent:Nick().." is ready.")
	end
	Readys = Readys + 1
	local remaining = player.GetCount() - Readys
	local nextReadyTime = remaining*(remaining+1)*5
	if nextReadyTime < ReadyTime and ReadyTime > 0 then
		ReadyTime = remaining*(remaining+1)*5
		PrintMessage(HUD_PRINTTALK, "Wave 1 will begin in "..ReadyTime.." seconds!")
		timer.Create("ROTGB_STARTER", remaining*10, 1, IsolatedStartTimer)
	else
		Readys = 0
		for k,v in pairs(player.GetAll()) do
			v.rotgb_Ready = nil
		end
		for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
			v:Fire("AddOutput","OnWaveFinished !self:SpawnerFinished::0:1")
			v:Fire("AddOutput","OnWaveFinishedShortly !self:SpawnerFinished::0:1")
			v:Fire("Use")
		end
	end
end

IsolatedStopTimer = function(ent)
	if ent then
		PrintMessage(HUD_PRINTTALK, ent:Nick().." is no longer ready.")
	end
	Readys = Readys - 1
	local remaining = player.GetCount() - Readys
	if remaining >= player.GetCount() then
		ReadyTime = -1
		PrintMessage(HUD_PRINTTALK, "Wave 1 is now on hold.")
		timer.Remove("ROTGB_STARTER")
	--[[else
		ReadyTime = remaining*(remaining+1)*5
		PrintMessage(HUD_PRINTTALK, "Wave 1 will begin in "..ReadyTime.." seconds!")
		timer.Create("ROTGB_STARTER", remaining*10, 1, IsolatedStartTimer)]]
	end
end

function SWEP:AcceptInput(input, activator, caller, data)
	if input == "SpawnerFinished" then
		for k,v in pairs(ents.FindByClass("rotgb_multitool")) do
			v:SetClip1(v:GetMaxClip1())
		end
	end
end

function SWEP:Think()
	if self.Weapon:Clip1() < self.Weapon:GetMaxClip1() and (self.Weapon.NextCharge or 0) < RealTime() and SERVER then
		self.Weapon.NextCharge = (self.Weapon.NextCharge or RealTime()) + 1
		self.Weapon:SetClip1(self.Weapon:Clip1()+1)
	end
	if not self.TowerTable then
		self.TowerTable = self:BuildTowerTable()
		--self:SetSubMaterial(0,"phoenix_storms/stripes")
		self:SetHoldType("slam")
	end
	if SERVER and IsValid(self.Owner) then
		if self:GetMode()==1 then
			local tower3 = self.TowerTable[self:GetCurrentTower()+1]
			if not IsValid(self.ServersideModel) then
				self.ServersideModel = ents.Create("prop_dynamic")
				self.ServersideModel:SetModel(tower3.model)
				self.ServersideModel:Spawn()
				--self.ServersideModel:PhysicsInit(SOLID_BBOX)
				--self.ServersideModel:SetCollisionGroup(COLLISION_GROUP_DISSOLVING)
				self.ServersideModel:SetNWBool("rotgb_isDetector", true)
				self.ServersideModel:SetNoDraw(true)
			elseif self.ServersideModel:GetModel() ~= tower3.model then
				self.ServersideModel:SetModel(tower3.model)
			end
			
			local trace = self:BuildTraceData(self.Owner)
			self.ServersideModel:SetPos(trace.HitPos)
			local tempang = self.Owner:GetAngles()
			tempang.p = 0
			tempang.r = 0
			self.ServersideModel:SetAngles(tempang)
			--self:SetServerMentionBlock(self.ServersideModel:GetNWBool("rotgb_isDetected"))
			
			--[[local not_nobuilds = ents.GetAll()
			for k,v in pairs(not_nobuilds) do
				if v:GetClass()=="func_rotgb_nobuild" then
					not_nobuilds[k] = nil
				end
			end]]
			local p1, p2 = self.ServersideModel:WorldSpaceAABB()
			--p1:Add(trace.HitPos)
			--p2:Add(trace.HitPos)
			
			local tempvar = false
			--debugoverlay.Line(p1, p2, 0.05)
			for k,v in pairs(ents.FindInSphere(p1,1)) do
				if v:GetClass()=="func_rotgb_nobuild" and not v:GetDisabled() then
					tempvar = true break 
				end
			end
			for k,v in pairs(ents.FindInSphere(p2,1)) do
				if v:GetClass()=="func_rotgb_nobuild" and not v:GetDisabled() then
					tempvar = true break 
				end
			end
			--[[local tracedata = {
				start = trace.HitPos + self.ServersideModel:GetCollisionBounds(),
				endpos = trace.HitPos + select(2,self.ServersideModel:GetCollisionBounds()),
				filter = table.ClearKeys(not_nobuilds),
				ignoreworld = true,
				mask = MASK_ALL
			}
			local trace2 = util.TraceLine(tracedata)]]
			--PrintTable(trace2)
			self:SetServerMentionBlock(tempvar)
		elseif IsValid(self.ServersideModel) then
			self.ServersideModel:Remove()
		end
	end
end

local color_black_semiopaque = Color(0,0,0,191)
local color_blue = Color(0,0,255)
local color_aqua = Color(0,255,255)
local color_red = Color(255,0,0)
local color_red_dark = Color(127,0,0)
local color_gray = Color(127,127,127)

local modes = {"Nothing", "Tower Placement", "Cash Giver", "Wave Starter"}

local ConR = GetConVar("rotgb_range_enable_indicators")
local ConH = GetConVar("rotgb_range_hold_time")
local ConT = GetConVar("rotgb_range_fade_time")
local ConA = GetConVar("rotgb_range_alpha")

function SWEP:DrawHUD()
	local anchorx, anchory
	local scrW, scrH = ScrW(), ScrH()
	local height = draw.GetFontHeight("CloseCaption_Normal")
	local ply = LocalPlayer()
	if self:GetMode()==1 then
		if not self.TowerTable then
			self.TowerTable = self:BuildTowerTable()
		end
		self.rotgb_Offset = self.rotgb_Offset or 0
		local cash = ROTGB_GetCash(LocalPlayer())
		--local tower1 = self.TowerTable[ self:GetCurrentTower()-1 ]
		--local tower2 = self.TowerTable[ self:GetCurrentTower()   ]
		local tower3 = self.TowerTable[ self:GetCurrentTower()+1 ]
		--local tower4 = self.TowerTable[ self:GetCurrentTower()+2 ]
		--local tower5 = self.TowerTable[ self:GetCurrentTower()+3 ]
		
		if not self.IsInVote then
			self.IsInVote = true
			self.rotgb_Show = false
			self:DoTowerSelector()
		end
		
		if self.rotgb_Show then
			if not IsValid(self.ClientsideModel) then
				self.ClientsideModel = ClientsideModel(tower3.model, RENDERGROUP_BOTH)
				self.ClientsideModel:SetMaterial("models/wireframe")
			elseif self.ClientsideModel:GetModel() ~= tower3.model then
				self.ClientsideModel:SetModel(tower3.model)
			end
			
			local statustext = "Cost: $"..self:GetCashText(tower3.cost)
			
			local trace = self:BuildTraceData(LocalPlayer())
			if trace.Hit then
				self.ClientsideModel:SetPos(trace.HitPos)
				self.ClientsideModel.RenderOverride = function(self)
					self:DrawModel()
					if tower3.range < 16384 and ConR:GetBool() then
						local fadeout = ConT:GetFloat()
						self.DrawFadeNext = RealTime()+fadeout+ConH:GetFloat()
						if (self.DrawFadeNext or 0)>RealTime() then
							local scol = self:GetColor() == color_aqua and tower3.infinite and color_blue or self:GetColor()
							local alpha = math.Clamp(math.Remap(self.DrawFadeNext-RealTime(),fadeout,0,ConA:GetFloat(),0),0,ConA:GetFloat())
							scol = Color(scol.r,scol.g,scol.b,alpha)
							render.DrawWireframeSphere(self:LocalToWorld(tower3.losoffset),-tower3.range,32,17,scol,true)
						end
					end
				end
				local tempang = EyeAngles()
				tempang.p = 0
				tempang.r = 0
				self.ClientsideModel:SetAngles(tempang)
				
				if self:GetServerMentionBlock() then
					self.ClientsideModel:SetColor(color_red)
					statustext = "Placement is illegal!"
				elseif (ply:GetShootPos():DistToSqr(trace.HitPos) <= 65536 and tower3.cost <= cash) and self.ClientsideModel:GetColor() ~= color_aqua then
					self.ClientsideModel:SetColor(color_aqua)
				elseif tower3.cost > cash and self.ClientsideModel:GetColor() ~= color_red then
					self.ClientsideModel:SetColor(color_red)
				elseif ply:GetShootPos():DistToSqr(trace.HitPos) > 65536 and self.ClientsideModel:GetColor() ~= color_red then
					self.ClientsideModel:SetColor(color_red)
					statustext = "Too far!"
				end
			end
			
			local font1 = "CloseCaption_Normal"
			--[[anchorx, anchory = scrW/3, scrH/2
			draw.SimpleTextOutlined(tower3.name, font1, anchorx, anchory, tower3.cost > cash and color_red or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
			if tower1 then
				draw.SimpleTextOutlined(tower1.name, font1, anchorx, anchory-height*2, tower1.cost > cash and color_red_dark or color_gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
			end
			if tower2 then
				draw.SimpleTextOutlined(tower2.name, font1, anchorx, anchory-height, tower2.cost > cash and color_red_dark or color_gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
			end
			if tower4 then
				draw.SimpleTextOutlined(tower4.name, font1, anchorx, anchory+height, tower4.cost > cash and color_red_dark or color_gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
			end
			if tower5 then
				draw.SimpleTextOutlined(tower5.name, font1, anchorx, anchory+height*2, tower5.cost > cash and color_red_dark or color_gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
			end
			
			anchorx, anchory = scrW/2, scrH/4
			draw.SimpleTextOutlined("Sprint+Secondary: Backward", font1, anchorx, anchory, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
			draw.SimpleTextOutlined("Secondary: Forward", font1, anchorx, anchory-height, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)]]
			
			anchorx, anchory = scrW/3, scrH/2
			draw.SimpleTextOutlined("Secondary: Cancel Placement", font1, anchorx, anchory, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
			
			anchorx, anchory = scrW/2, scrH*3/4
			draw.SimpleTextOutlined(statustext, font1, anchorx, anchory, self.ClientsideModel:GetColor().r==255 and color_red or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
			
			anchorx, anchory = scrW*2/3, scrH/2
			draw.SimpleTextOutlined("Damage: "..tower3.damage/10, font1, anchorx, anchory-height, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
			draw.SimpleTextOutlined("Fire Rate: "..math.Round(tower3.firerate,2).."/s", font1, anchorx, anchory, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
			draw.SimpleTextOutlined("Range: "..tower3.range.." Hu", font1, anchorx, anchory+height, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
		end
	elseif self.IsInVote then
		if IsValid(self.ClientsideModel) then
			self.ClientsideModel:Remove()
		end
		self.IsInVote = false
		self.Owner:AddPlayerOption("RotgB_TowerSelect", 0)
	end
	if self:GetMode()==2 then
		anchorx, anchory = scrW/2, scrH/4
		if GetConVar("rotgb_individualcash"):GetBool() then
			local bestplayer = self:GetBestPlayer()
			local playertext = bestplayer and "Targeting: "..bestplayer:Nick() or "Targeting: no one"
			local playercolor = bestplayer and color_white or color_red
			draw.SimpleTextOutlined(playertext, "CloseCaption_Normal", anchorx, anchory, playercolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
			
			anchorx, anchory = scrW/2, scrH*3/4
			local cash = ROTGB_GetCash(LocalPlayer())*0.1
			local costtext = "Sending: $"..self:GetCashText(cash)
			if cash < 1 then
				costtext = "You need $10 first!"
			end
			draw.SimpleTextOutlined(costtext, "CloseCaption_Normal", anchorx, anchory, cash < 1 and color_red or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		else
			draw.SimpleTextOutlined("This mode is useless unless the rotgb_individualcash ConVar is set to 1!", "CloseCaption_Normal", anchorx, anchory, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		end
	elseif self:GetMode()==3 then
		anchorx, anchory = scrW*2/3, scrH/2
		local ourtimescale = game.GetTimeScale()
		draw.SimpleTextOutlined("Secondary: Double Speed", "CloseCaption_Normal", anchorx, anchory, ourtimescale < 8 and color_white or color_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
		draw.SimpleTextOutlined("Sprint+Secondary: Halve Speed", "CloseCaption_Normal", anchorx, anchory+height, ourtimescale > 1 and color_white or color_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
		
		local dispcolor = color_red
		for k,v in pairs(ents.GetAll()) do
			if v:GetClass()=="gballoon_base" then
				dispcolor = color_red break
			elseif v:GetClass()=="gballoon_spawner" then
				if v:GetNextWaveTime() > CurTime() then
					dispcolor = color_red break
				else
					dispcolor = color_white
				end
			end
		end
		draw.SimpleTextOutlined("Primary: Ready/Unready", "CloseCaption_Normal", anchorx, anchory-height, dispcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, color_black)
	end
	anchorx, anchory = scrW*2/3, scrH*3/4
	draw.SimpleTextOutlined("Current Mode: "..modes[self:GetMode()+1], "CloseCaption_Normal", anchorx, anchory, dispcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
	draw.SimpleTextOutlined("Reload: Switch to "..modes[(self:GetMode()+1)%4+1], "CloseCaption_Normal", anchorx, anchory+height, dispcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
	draw.SimpleTextOutlined("Sprint+Reload: Switch to "..modes[(self:GetMode()-1)%4+1], "CloseCaption_Normal", anchorx, anchory+height*2, dispcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
end

function SWEP:DrawTowerSelector()
	local fontheight = GetConVar("rotgb_hud_size"):GetInt()
	local tower_size = fontheight*4
	local space = fontheight*0.5
	local totalwidth = space*5+tower_size*4
	local totalheight = fontheight*5+space*3+tower_size*2
	local basex = (ScrW()-totalwidth)/2
	local basey = (ScrH()-totalheight)/2
	draw.RoundedBoxEx(8, basex, basey, totalwidth, totalheight, color_black_semiopaque, true, true, true)
	
	local x_offset = basex + space
	local y_offset = basey + space + fontheight
	for i=self.rotgb_Offset+1,self.rotgb_Offset+8 do
		if self.TowerTable[i] then
			surface.SetMaterial(self.TowerTable[i].material)
			surface.SetDrawColor(color_white:Unpack())
			surface.DrawTexturedRect(x_offset, y_offset, tower_size, tower_size)
			local tx, ty = x_offset+tower_size/2, y_offset+tower_size
			draw.SimpleTextOutlined(self.TowerTable[i].name, "Default", tx, ty, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, color_black)
			draw.SimpleTextOutlined("$"..self:GetCashText(self.TowerTable[i].cost), "RotgB_font", tx, ty, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, color_black)
			
			ty = ty+fontheight
			draw.RoundedBox(8, tx-fontheight/2, ty, fontheight, fontheight, color_white)
			draw.SimpleText(i-self.rotgb_Offset, "RotgB_font", tx, ty, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			
			if i==self.rotgb_Offset+4 then
				x_offset = x_offset - (space + tower_size) * 3
				y_offset = y_offset + tower_size + fontheight * 2 + space
			else
				x_offset = x_offset + space + tower_size
			end
		end
	end
	
	local next_text = self.TowerTable[self.rotgb_Offset+9] and "Next >" or "Return"
	surface.SetFont("RotgB_font")
	local tw = surface.GetTextSize(next_text)
	local next_w = space * 3 + fontheight + tw
	local next_h = space + fontheight
	local next_x = basex + totalwidth - next_w
	local next_y = basey + totalheight
	draw.RoundedBoxEx(8, next_x, next_y, next_w, next_h, color_black_semiopaque, false, false, true, true)
	draw.RoundedBox(8, next_x + space, next_y, fontheight, fontheight, color_white)
	draw.SimpleText("9", "RotgB_font", next_x + space + fontheight / 2, next_y, color_black, TEXT_ALIGN_CENTER)
	draw.SimpleTextOutlined(next_text, "RotgB_font", next_x + space*2 + fontheight, next_y + fontheight / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, color_black)
end

function SWEP:DoTowerSelector()
	self.Owner:AddPlayerOption("RotgB_TowerSelect", 999999, function(number)
		if IsValid(self) and self.Owner:IsPlayer() then
			if number==9 then
				self.rotgb_Offset = self.rotgb_Offset + 8
				if not self.TowerTable[self.rotgb_Offset + 1] then
					self.rotgb_Offset = 0
				end
			elseif self.TowerTable[self.rotgb_Offset + number] then
				self.Owner:AddPlayerOption("RotgB_TowerSelect", 0)
				self.rotgb_Show = true
				net.Start("rotgb_generic")
				net.WriteString("settower")
				net.WriteUInt(number-1+self.rotgb_Offset,8)
				net.SendToServer()
			end
		end
	end, function()
		if IsValid(self) then
			self:DrawTowerSelector()
		end
	end)
end

function SWEP:Holster()
	if IsValid(self.ClientsideModel) then
		self.ClientsideModel:Remove()
	end
	if IsValid(self.ServersideModel) then
		self.ServersideModel:Remove()
	end
	if CLIENT and IsValid(self.Owner) and self.Owner:IsPlayer() then
		self.IsInVote = false
		self.Owner:AddPlayerOption("RotgB_TowerSelect", 0)
	end
	return true
end

function SWEP:OnRemove()
	if IsValid(self.ClientsideModel) then
		self.ClientsideModel:Remove()
	end
	if IsValid(self.ServersideModel) then
		self.ServersideModel:Remove()
	end
	if CLIENT and IsValid(self.Owner) and self.Owner:IsPlayer() then
		self.IsInVote = false
		self.Owner:AddPlayerOption("RotgB_TowerSelect", 0)
	end
end

function SWEP:GetBestPlayer()
	local localdir = self.Owner:GetAimVector()
	local bestscore, bestplayer = 0
	for k,v in pairs(player.GetAll()) do
		if v~=self.Owner then
			local dir = v:GetShootPos() - self.Owner:GetShootPos()
			local score = localdir:Dot(dir)
			if bestscore < score then
				bestscore = score
				bestplayer = v
			end
		end
	end
	return bestplayer
end

function SWEP:CanPrimaryAttack()
	if not GetConVar("rotgb_individualcash"):GetBool() and self:GetMode()==2 then
		self.Owner:EmitSound("items/medshotno1.wav",60,100,1,CHAN_WEAPON)
		return false
	elseif self.Weapon:Clip1() <= 0 and SERVER then
		self.Owner:EmitSound("items/medshotno1.wav",60,100,1,CHAN_WEAPON)
		if self:GetMode()==2 then
			self.Owner:PrintMessage(HUD_PRINTTALK, "You're transferring too fast!")
		elseif self:GetMode()==3 then
			self.Owner:PrintMessage(HUD_PRINTTALK, "You can't vote until the wave ends!")
		end
		return false
	end
	return true
end

function SWEP:PrimaryAttack()
	--self.Weapon:SetNextPrimaryFire(RealTime()+1)
	if not IsFirstTimePredicted() then return end
	if IsValid(self.Owner) and SERVER then
		if self.Owner:IsNPC() then self:SetMode(1) end
		if self:GetMode()==1 then
			local ply = self.Owner
			local trace = self:BuildTraceData(ply)
			if (trace.Hit and ply:GetShootPos():DistToSqr(trace.HitPos) <= 65536) then
				if not self.TowerTable then
					self.TowerTable = self:BuildTowerTable()
				end
				local tempang = ply:GetAngles()
				tempang.p = 0
				tempang.r = 0
				if ply:IsNPC() then
					self:SetCurrentTower(math.random(#self.TowerTable)-1)
				end
				local tower = ents.Create(self.TowerTable[self:GetCurrentTower()+1].class)
				tower:SetPos(trace.HitPos)
				tower:SetAngles(tempang)
				tower:SetTowerOwner(self.Owner)
				tower:Spawn()
				--util.ScreenShake(self.Owner:GetShootPos(), 4, 20, 0.5, 64)
				tower:EmitSound("phx/epicmetal_soft"..math.random(7)..".wav",60,100,0.5,CHAN_WEAPON)
			else
				self.Owner:EmitSound("items/medshotno1.wav",60,100,1,CHAN_WEAPON)
			end
		elseif self:GetMode()==2 and self:CanPrimaryAttack() then
			local ply = self:GetBestPlayer()
			local cashtransfer = ROTGB_GetCash(self.Owner)*0.1
			if cashtransfer < 1 or not ply then
				self.Owner:EmitSound("items/medshotno1.wav",60,100,1,CHAN_WEAPON)
			else
				ROTGB_RemoveCash(cashtransfer, self.Owner)
				ROTGB_AddCash(cashtransfer, ply)
				self.Owner:EmitSound("items/medshot4.wav",60,100,1,CHAN_WEAPON)
				ply:PrintMessage(HUD_PRINTTALK, "You gained $"..math.Round(cashtransfer,0).." from "..self.Owner:Nick().."!")
				self:TakePrimaryAmmo(1)
				self.Weapon.NextCharge = RealTime() + 1
				--util.ScreenShake(self.Owner:GetShootPos(), 4, 20, 0.5, 64)
			end
		elseif self:GetMode()==3 and not self.Owner:IsNPC() then
			local spawners = ents.FindByClass("gballoon_spawner")
			if table.IsEmpty(spawners) then
				self.Owner:EmitSound("items/medshotno1.wav",60,100,1,CHAN_WEAPON)
				return self.Owner:PrintMessage(HUD_PRINTTALK, "Place one gBalloon Spawner first!")
			elseif #ents.FindByClass("gballoon_base") > 0 then
				self.Owner:EmitSound("items/medshotno1.wav",60,100,1,CHAN_WEAPON)
				return self.Owner:PrintMessage(HUD_PRINTTALK, "You can't vote until the wave ends!")
			else
				for k,v in pairs(spawners) do
					if v:GetNextWaveTime() > RealTime() then
						self.Owner:EmitSound("items/medshotno1.wav",60,100,1,CHAN_WEAPON)
						return self.Owner:PrintMessage(HUD_PRINTTALK, "You can't vote until the wave ends!")
					end
				end
			end
			if self:CanPrimaryAttack() then
				self.Owner.rotgb_Ready = not self.Owner.rotgb_Ready
				self:TakePrimaryAmmo(1)
				self.Weapon.NextCharge = RealTime() + 1
				if self.Owner.rotgb_Ready then
					IsolatedStartTimer(self.Owner)
				else
					IsolatedStopTimer(self.Owner)
				end
			end
		end
	end
end

function SWEP:CanSecondaryAttack()
	if self.Weapon:Clip1() <= 0 then
		self.Owner:EmitSound("buttons/combine_button_locked.wav",60,100,1,CHAN_WEAPON)
		self.Owner:PrintMessage(HUD_PRINTTALK, "You're changing the game speed too much!")
		return false
	end
	return true
end

function SWEP:SecondaryAttack()
	if game.SinglePlayer() then self:CallOnClient("SecondaryAttack") end
	if self:GetMode()==1 and CLIENT and self.Owner == LocalPlayer() then
		--[[local shft = self.Owner:IsNPC() and 1 or self.Owner:KeyDown(IN_SPEED) and -1 or 1
		self:SetCurrentTower( (self:GetCurrentTower()+shft) % #self.TowerTable)]]
		self.IsInVote = false
		if IsValid(self.ClientsideModel) then
			self.ClientsideModel:Remove()
		end
		--self.Weapon:EmitSound("weapons/pistol/pistol_empty.wav",60,100,1,CHAN_WEAPON)
	elseif self:GetMode()==3 and self:CanSecondaryAttack() and IsFirstTimePredicted() and SERVER then
		local shft = self.Owner:IsNPC() and 1 or self.Owner:KeyDown(IN_SPEED) and 0.5 or 2
		local newscale = game.GetTimeScale()*shft
		if 1 <= newscale and newscale <= 8 then
			self.Owner:EmitSound(self.Owner:KeyDown(IN_SPEED) and "buttons/combine_button3.wav" or "buttons/combine_button5.wav",60,100+5*newscale,1,CHAN_WEAPON)
			game.SetTimeScale(newscale)
			self:TakePrimaryAmmo(1)
			self.Weapon.NextCharge = RealTime() + 1
		end
	end
end

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end
	if (self.NextReload or 0) < RealTime() and SERVER then
		self.NextReload = RealTime() + 0.25
		local shft = self.Owner:IsNPC() and 0 or self.Owner:KeyDown(IN_SPEED) and -1 or 1
		self:SetMode((self:GetMode()+shft)%4)
		self.Weapon:EmitSound("weapons/shotgun/shotgun_empty.wav",60,100,1,CHAN_WEAPON)
	end
end