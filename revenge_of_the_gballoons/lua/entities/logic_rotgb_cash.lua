ENT.Type = "point"
ENT.PrintName = "RotgB Cash Logic"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Sets or gets the current cash amount. Can also detect if a player has enough cash or not."
ENT.Instructions = "Hook this entity's inputs and outputs to something."

function ENT:KeyValue(key,value)
	key = key:lower()
	if key=="fire_on_changed" then
		self.AlwaysThink = tobool(value)
	elseif key=="altermode" then
		self.SetMode = tonumber(value)
	elseif key=="onprecashchanged" then
		self.OnPreCashChanged = key
		self:StoreOutput(key,value)
	elseif key=="onpostcashchanged" then
		self.OnPostCashChanged = key
		self:StoreOutput(key,value)
	elseif key=="onaltercash" then
		self.OnCashSet = key
		self:StoreOutput(key,value)
	elseif key=="ongetcash" then
		self.OnTestCash = key
		self:StoreOutput(key,value)
	elseif key=="ongetcashmin" then
		self.OnTestCashMin = key
		self:StoreOutput(key,value)
	elseif key=="ongetcashmax" then
		self.OnTestCashMax = key
		self:StoreOutput(key,value)
	elseif key=="oncanafford" then
		self.OnCanAfford = key
		self:StoreOutput(key,value)
	elseif key=="oncantafford" then
		self.OnCantAfford = key
		self:StoreOutput(key,value)
	end
end

function ENT:AcceptInput(input,activator,caller,data)
	input = input:lower()
	if input=="setfireonchanged" then -- DEPRECATED
		self.AlwaysThink = tobool(data)
	elseif input=="enablefireonchanged" then
		self.AlwaysThink = true
	elseif input=="disablefireonchanged" then
		self.AlwaysThink = false
	elseif input=="togglefireonchanged" then
		self.AlwaysThink = not self.AlwaysThink
	else
		data = tonumber(data) or 0
		if input=="altermode" then
			self.SetMode = data
		elseif input=="altercash" then
			if self.SetMode == 0 then
				ROTGB_SetCash(data,activator)
				self:TriggerOutput(self.OnCashSet,activator,ROTGB_GetCash(activator))
			elseif self.SetMode == 1 then
				ROTGB_AddCash(data,activator)
				self:TriggerOutput(self.OnCashSet,activator,ROTGB_GetCash(activator))
			elseif self.SetMode == 2 then
				ROTGB_RemoveCash(data,activator)
				self:TriggerOutput(self.OnCashSet,activator,ROTGB_GetCash(activator))
			elseif self.SetMode == 3 then
				ROTGB_SetCash(data*player.GetCount())
				self:TriggerOutput(self.OnCashSet,activator,ROTGB_GetCash(activator))
			elseif self.SetMode == 4 then
				ROTGB_AddCash(data*player.GetCount())
				self:TriggerOutput(self.OnCashSet,activator,ROTGB_GetCash(activator))
			elseif self.SetMode == 5 then
				ROTGB_RemoveCash(data*player.GetCount())
				self:TriggerOutput(self.OnCashSet,activator,ROTGB_GetCash(activator))
			elseif self.SetMode == 6 then
				ROTGB_SetCash(data)
				self:TriggerOutput(self.OnCashSet,activator,ROTGB_GetCash(activator))
			elseif self.SetMode == 7 then
				ROTGB_AddCash(data)
				self:TriggerOutput(self.OnCashSet,activator,ROTGB_GetCash(activator))
			elseif self.SetMode == 8 then
				ROTGB_RemoveCash(data)
				self:TriggerOutput(self.OnCashSet,activator,ROTGB_GetCash(activator))
			end
		elseif input=="getcash" then
			self:TriggerOutput(self.OnTestCash,activator,ROTGB_GetCash(activator))
		elseif input=="getcashmin" or input=="getcashmax" then
			local cashtable,isMax = {},input=="getcashmax"
			for k,v in pairs(player.GetAll()) do
				table.insert(cashtable,ROTGB_GetCash(v))
			end
			table.sort(cashtable, function(a,b)
				return isMax == a > b
			end)
			local amt = cashtable[math.Clamp(data or 1,1,#cashtable)]
			if isMax then
				self:TriggerOutput(self.OnTestCashMax,activator,amt)
			else
				self:TriggerOutput(self.OnTestCashMin,activator,amt)
			end
		elseif input=="canafford" or input=="canaffordandsubtract" then
			local cash = ROTGB_GetCash(activator)
			if cash < data then
				self:TriggerOutput(self.OnCantAfford,activator,data-cash)
			else
				self:TriggerOutput(self.OnCanAfford,activator,cash-data)
				if input=="canaffordandsubtract" then
					ROTGB_RemoveCash(data,activator)
				end
			end
		end
	end
end

function ENT:Think()
	if self.AlwaysThink then
		local cash = 0
		if ROTGB_GetConVarValue("rotgb_individualcash") then -- this is really, really bad imo
			if (self.LastPlayerRefresh or 0) <= CurTime() then
				self.LastPlayerRefresh = CurTime() + 3
				self.CurrentPlayers = player.GetAll()
			end
			for k,v in pairs(self.CurrentPlayers) do
				if IsValid(v) then
					cash = math.min(cash,ROTGB_GetCash(v))
				end
			end
		else
			cash = ROTGB_GetCash()
		end
		if self.OldCashValue ~= cash then
			self:TriggerOutput(self.OnPreCashChanged,self,self.OldCashValue)
			self:TriggerOutput(self.OnPostCashChanged,self,cash)
			self.OldCashValue = cash
		end
		self:NextThink(CurTime())
		return true
	end
end