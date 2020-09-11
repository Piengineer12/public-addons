AddCSLuaFile()

ENT.Base = "gballoon_tower_base"
ENT.Type = "anim"
ENT.PrintName = "Multipurpose Engine"
ENT.Category = "RotgB: Towers"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Discourage those gBalloons!"
ENT.Instructions = ""
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model("models/maxofs2d/hover_propeller.mdl")
ENT.FireRate = 1
ENT.Cost = 600
ENT.AbilityCooldown = 60
ENT.LOSOffset = Vector(0,0,25)
ENT.rotgb_HoverballWorth = 0
ENT.rotgb_HoverballDelay = 10
ENT.AttackDamage = 0
ENT.DetectionRadius = 512
ENT.SeeCamo = true
ENT.InfiniteRange2 = true
ENT.rotgb_Buff = 0
ENT.rotgb_Towers = {}
ENT.UpgradeReference = {
	{
		Names = {"Hoverball Factory","Advanced Hoverballs","Faster Generation","Auto-Sell","Garry's Bank","Automatic Trading Service"},
		Descs = {
			"Generates hoverballs per round, which can be sold (removed) for $100 each. You can simply touch them to remove them. Only works while gBalloons are present.",
			"Hoverballs last three times longer and are sold for 50% more.",
			"Hoverballs are made significantly faster.",
			"Hoverballs are now automatically removed.",
			"For each player, generates cash equal to 0.1% of their current cash per second, up to $100 per second. Only works while gBalloons are present.",
			"The tower no longer generates hoverballs. Instead, it performs (fake) trades, with payoffs ranging from $250 to $500 per second!",
		},
		Prices = {500,1500,2500,3000,10000,100000},
		Funcs = {
			function(self)
				self.rotgb_HoverballWorth = 100
			end,
			function(self)
				self.rotgb_HoverballLife = true
				self.rotgb_HoverballWorth = self.rotgb_HoverballWorth * 1.5
			end,
			function(self)
				self.rotgb_HoverballDelay = self.rotgb_HoverballDelay / 2
			end,
			function(self)
				self.rotgb_AutoHoverball = true
			end,
			function(self)
				self.rotgb_Bank = true
			end,
			function(self)
				self.rotgb_HoverballDelay = self.rotgb_HoverballDelay / 5
				self.rotgb_HoverballWorth = self.rotgb_HoverballWorth * 5
				self.rotgb_Trading = true
			end
		}
	},
	{
		Names = {"Ultrasound Annoyance","Speed Traps","Radar Pulsar","Unfastening Dust","Immunity Shatter","Total Meltdown"},
		Descs = {
			"Prevents gBalloons in the tower's radius from regenerating health.",
			"All Fast gBalloons within this tower's radius move 50% slower.",
			"All Hidden gBalloons within this tower's radius become visible to all towers.",
			"All Shielded gBalloons within this tower's radius take double damage from all sources.",
			"All gBalloons within the tower's range lose all immunities. gBalloon armour is not affected.",
			"Once every 60 seconds, shooting at this tower causes all towers to deal 400% more damage for 15 seconds.",
		},
		Prices = {500,1000,2000,4000,30000,35000},
		Funcs = {
			function(self)
				self.rotgb_NoRegen = true
			end,
			function(self)
				self.rotgb_NoFast = true
			end,
			function(self)
				self.rotgb_NoHidden = true
			end,
			function(self)
				self.rotgb_NoShielded = true
			end,
			function(self)
				self.rotgb_NoImmunities = true
			end,
			function(self)
				self.HasAbility = true
			end
		}
	},
	{
		Names = {"Violent Blades","Faster Blades","Heated Blades","Super Blades","Unstable Blades","Tyrant Blades"},
		Descs = {
			"This tower can now instantly pop Green gBalloons and lower, even if they are hidden.",
			"This tower can now instantly pop Pink gBalloons and lower.",
			"This tower can now instantly pop Gray, Zebra, Aqua and Error gBalloons.",
			"This tower can now instantly pop Ceramic gBalloons and anything lower!",
			"This tower can now instantly pop Blue gBlimps, Marble gBalloons and anything lower!",
			"This tower can now instantly pop Red gBlimps and anything lower!",
		},
		Prices = {3000,5000,20000,100000,600000,3000000},
		Funcs = {
			function(self)
				self.AttackDamage = self.AttackDamage + 30
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 50
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 230
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 1030
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 6120
			end,
			function(self)
				self.AttackDamage = self.AttackDamage + 31480
			end
		}
	},
	{
		Names = {"Morale Boost","Premium Incentive","Jungle Drumming","Health Insurance","Trusted Partnerships","Maximum Potential"},
		Descs = {
			"All towers in this tower's radius fire 20% faster.",
			"Whenever a tower is placed, you gain a 20% rebate. This upgrade does not stack at all.",
			"All towers within the range of this tower pop one extra layer per attack, and have 20% more range.",
			"Whenever a gBalloon reaches its target and pops, each player gains $1000 for each damage point taken by the target.",
			"Whenever a tower fires within this tower's range, there is a chance that another tower within this tower's range will also fire! \z
				The chance is reduced if the firing tower fires more than once per second.",
			"All towers in this tower's radius no longer have upgrade path restrictions!",
		},
		Prices = {400,500,2500,5000,15000,1000000},
		Funcs = {
			function(self)
				self.rotgb_Buff = 1
			end,
			function(self)
				self.rotgb_Buff = 2
			end,
			function(self)
				self.rotgb_Buff = 3
			end,
			function(self)
				self.rotgb_Buff = 4
			end,
			function(self)
				self.rotgb_Buff = 5
			end,
			function(self)
				self.rotgb_Buff = 6
			end
		}
	}
}
ENT.UpgradeLimits = {6,4,2,0}

function ENT:FireFunction(gBalloons)
	local cmul = GetConVar("rotgb_cash_mul"):GetFloat()
	self.rotgb_HoverballCharge = (self.rotgb_HoverballCharge or 0) + 1
	if self.rotgb_HoverballCharge >= self.rotgb_HoverballDelay and self.rotgb_HoverballWorth > 0 then
		self.rotgb_HoverballCharge = 0
		if self.rotgb_AutoHoverball then
			ROTGB_AddCash(self.rotgb_HoverballWorth*(self.rotgb_Trading and math.random()+0.5 or 1)*cmul, self:GetTowerOwner())
		else
			local hoverball = ents.Create("gmod_hoverball")
			hoverball:SetPos(self:LocalToWorld(self.LOSOffset*2))
			hoverball:SetModel(self.rotgb_HoverballLife and "models/maxofs2d/hover_rings.mdl" or "models/maxofs2d/hover_classic.mdl")
			hoverball:Spawn()
			hoverball:Activate()
			hoverball:AddEffects(EF_ITEM_BLINK)
			local physobj = hoverball:GetPhysicsObject()
			if IsValid(physobj) then
				physobj:Wake()
				physobj:SetVelocity(VectorRand()*10)
			end
			hoverball.rotgb_Value = self.rotgb_HoverballWorth
			hoverball:SetTrigger(true)
			hoverball:UseTriggerBounds(true,64)
			function hoverball:StartTouch(ent)
				if (IsValid(ent) and ent:IsPlayer()) then
					hoverball:SetTrigger(false)
					hoverball:SetNotSolid(true)
					hoverball:SetMoveType(MOVETYPE_NONE)
					hoverball:SetNoDraw(true)
					local effdata = EffectData()
					effdata:SetEntity(hoverball)
					util.Effect("entity_remove",effdata,true,true)
					return SafeRemoveEntityDelayed(hoverball,1)
				end
			end
			hoverball:CallOnRemove("RotgB.Hoverball",function()
				ROTGB_AddCash(hoverball.rotgb_Value*cmul, IsValid(self) and self:GetTowerOwner())
			end)
			timer.Simple(self.rotgb_HoverballLife and 60 or 20,function()
				if IsValid(hoverball) then
					hoverball.rotgb_Value = 0
					hoverball:Remove()
				end
			end)
		end
	end
	if self.rotgb_Bank then
		for k,v in pairs(player.GetAll()) do
			ROTGB_AddCash(math.min(100,ROTGB_GetCash(v)*.001*cmul),v)
		end
	end
	--[[if self.rotgb_Buff > 4 then
		self.rotgb_TowerCharge = (self.rotgb_TowerCharge or 0) + 1
		if self.rotgb_TowerCharge >= 60 then
			self.rotgb_TowerCharge = 0
			for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
				if v:GetClass()=="gballoon_tower_base" then
					v.FireRate = v.FireRate * 1.05
					v.DetectionRadius = v.DetectionRadius * 1.05
				end
			end
		end
	end]]
end

function ENT:ROTGB_Think()
	local anotherfired
	for k,v in pairs(self.rotgb_Towers) do
		if (IsValid(k) and k.rotgb_AffectedBy == self) then
			local effect = k.rotgb_Effect or 0
			if effect > 0 then
				k.FireRate = k.FireRate / 1.2
			end
			if effect > 2 then
				k.AttackDamage = (k.AttackDamage or 0) - 10
				k.DetectionRadius = k.DetectionRadius / 1.2
			end
			if effect > 4 and k.NextFire~=k.rotgb_BuffTrack then
				k.rotgb_BuffTrack = k.NextFire
				if math.random()<1/k.FireRate then
					anotherfired = true
				end
			end
			k.rotgb_AffectedBy = nil
		else
			self.rotgb_Towers[k] = nil
		end
	end
	for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
		if v:GetClass()=="gballoon_base" then
			if self.rotgb_NoRegen then
				v.BalloonRegenTime = CurTime()+GetConVar("rotgb_regen_delay"):GetFloat()
			end
			if self.rotgb_NoFast and v:GetBalloonProperty("BalloonFast") then
				v:Slowdown("ROTGB_FASTLESS",0.5,0.25)
			end
			if self.rotgb_NoHidden and v:GetBalloonProperty("BalloonHidden") then
				v:InflictRotgBStatusEffect("unhide",0.25)
			end
			if self.rotgb_NoShielded and v:GetBalloonProperty("BalloonShielded") then
				v:InflictRotgBStatusEffect("unshield",0.25)
			end
			if self.rotgb_NoImmunities then
				v:InflictRotgBStatusEffect("unimmune",0.25)
			end
			if v:GetRgBE() <= self.AttackDamage/10 and self.AttackDamage>=30 then
				v:Pop(-1)
			end
		elseif v.Base=="gballoon_tower_base" then
			if not IsValid(v.rotgb_AffectedBy) then
				self.rotgb_Towers[v] = true
				v.rotgb_AffectedBy = self
				v.rotgb_Effect = self.rotgb_Buff
				if v.rotgb_Effect > 0 then
					v.FireRate = v.FireRate * 1.2
				end
				if v.rotgb_Effect > 2 then
					v.AttackDamage = (v.AttackDamage or 0) + 10
					v.DetectionRadius = v.DetectionRadius * 1.2
				end
			end
			if self.rotgb_Buff > 5 then
				v:SetNWFloat("rotgb_noupgradelimit", CurTime()+2)
			end
		end
	end
	if anotherfired then
		local tower = select(2,table.Random(self.rotgb_Towers))
		tower:ExpensiveThink(true)
		if IsValid(tower.SolicitedgBalloon) then
			tower:FireFunction(tower.SolicitedgBalloon,tower.gBalloons or {})
		end
	end
end

function ENT:TriggerAbility()
	for k,v in pairs(ents.FindInSphere(self:GetShootPos(),self.DetectionRadius)) do
		if v.Base=="gballoon_tower_base" and v.AttackDamage then
			v.AttackDamage = v.AttackDamage * 5
			timer.Simple(5,function()
				if IsValid(v) then
					v.AttackDamage = v.AttackDamage / 5
				end
			end)
		end
	end
end

hook.Add("OnEntityCreated","ROTGB_TOWER_06",function(ent)
	timer.Simple(0,function()
		if IsValid(ent) then
			if ent.Base=="gballoon_tower_base" then
				local rebate = nil
				for k,v in pairs(ents.FindByClass("gballoon_tower_06")) do
					if v.rotgb_Buff > 1 then rebate = true break end
				end
				if rebate then
					timer.Simple(0.1,function()
						if IsValid(ent) then
							ROTGB_AddCash((ent.Cost or 0)*0.2*GetConVar("rotgb_cash_mul"):GetFloat())
						end
					end)
				end
			end
		end
	end)
end)

hook.Add("EntityTakeDamage","ROTGB_TOWER_06",function(ent,dmginfo)
	local caller = dmginfo:GetInflictor()
	if (IsValid(caller) and caller:GetClass()=="gballoon_base") then
		local insure = 0
		for k,v in pairs(ents.FindByClass("gballoon_tower_06")) do
			if v.rotgb_Buff > 3 then insure = insure + 1 end
		end
		if insure > 0 then
			ROTGB_AddCash(dmginfo:GetDamage()*insure*1000*GetConVar("rotgb_cash_mul"):GetFloat()*player.GetCount())
		end
	end
end)

list.Set("NPC","gballoon_tower_06",{
	Name = ENT.PrintName,
	Class = "gballoon_tower_06",
	Category = ENT.Category
})