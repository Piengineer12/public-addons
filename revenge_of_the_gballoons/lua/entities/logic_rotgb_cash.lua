ENT.Type = "point"
ENT.PrintName = "RotgB Cash Logic"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Sets or gets the current cash amount. Can also detect if a player has enough cash or not."
ENT.Instructions = "Hook this entity's inputs and outputs to something."

function ENT:KeyValue(key,value)
	if key:lower()=="fire_on_changed" then
		self.AlwaysThink = tobool(value)
	elseif key:lower()=="oncanafford" then
		self.OnCanAfford = key
		self:StoreOutput(key,value)
	elseif key:lower()=="oncantafford" then
		self.OnCantAfford = key
		self:StoreOutput(key,value)
	elseif key:lower()=="ongetcash" then
		self.OnTestCash = key
		self:StoreOutput(key,value)
	elseif key:lower()=="ongetcashmin" then
		self.OnTestCashMin = key
		self:StoreOutput(key,value)
	elseif key:lower()=="ongetcashmax" then
		self.OnTestCashMax = key
		self:StoreOutput(key,value)
	elseif key:lower()=="onprecashchanged" then
		self.OnPreCashChanged = key
		self:StoreOutput(key,value)
	elseif key:lower()=="onpostcashchanged" then
		self.OnPostCashChanged = key
		self:StoreOutput(key,value)
	elseif key:lower()=="altermode" then
		self.SetMode = tonumber(value)
	--[[elseif key:lower()=="setmode" then
		self.SetMode = self.SetMode or value]]
	elseif key:lower()=="onaltercash" then
		self.OnCashSet = key
		self:StoreOutput(key,value)
	--[[elseif key:lower()=="onsetcash" then
		self.OnCashSet = self.OnCashSet or key
		self:StoreOutput(key,value)]]
	end
end

function ENT:AcceptInput(input,activator,caller,data)
	if input:lower()=="setfireonchanged" then
		self.AlwaysThink = tobool(data)
	else
		data = tonumber(data) or 0
		if input:lower()=="altermode" --[[or input:lower()=="setmode"]] then
			self.SetMode = data
		elseif input:lower()=="canafford" then
			local cash = ROTGB_GetCash(activator)
			if cash < data then
				self:TriggerOutput(self.OnCantAfford,activator,data-cash)
			else
				self:TriggerOutput(self.OnCanAfford,activator,cash-data)
			end
		elseif input:lower()=="getcash" then
			self:TriggerOutput(self.OnTestCash,activator,ROTGB_GetCash(activator))
		elseif input:lower()=="getcashmin" or input:lower()=="getcashmax" then
			local cashtable,isMin = {},input:lower()=="getcashmin"
			for k,v in pairs(player.GetAll()) do
				table.insert(cashtable,{v,ROTGB_GetCash(v)})
			end
			table.SortByMember(cashtable,2,isMin)
			local amt = cashtable[math.Clamp(data or 1,1,#cashtable)]
			if isMin then
				self:TriggerOutput(self.OnTestCashMin,activator,amt)
			else
				self:TriggerOutput(self.OnTestCashMax,activator,amt)
			end
		elseif input:lower()=="altercash" --[[or input:lower()=="setcash"]] then
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
		end
	end
end

function ENT:Think()
	if self.AlwaysThink then
		local cash = 0
		if GetConVar("rotgb_individualcash"):GetBool() then -- why are we still here, just to suffer?
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