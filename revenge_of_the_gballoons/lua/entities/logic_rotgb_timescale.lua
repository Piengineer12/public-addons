ENT.Type = "point"
ENT.PrintName = "RotgB Timescale Logic"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Sets or gets the current timescale multiplier."
ENT.Instructions = "Hook this entity's inputs and outputs to something."

function ENT:KeyValue(key,value)
	key = key:lower()
	if key=="monitor_timescale" then
		self.MonitorTimescale = tobool(value)
	elseif key=="ongettimescale" then
		self.OnGetTimescale = key
		self:StoreOutput(key,value)
	elseif key=="onpretimescalechanged" then
		self.OnPreTimescaleChanged = key
		self:StoreOutput(key,value)
	elseif key=="onposttimescalechanged" then
		self.OnPostTimescaleChanged = key
		self:StoreOutput(key,value)
	elseif key=="onquartertimescale" then
		self.OnQuarterTimescale = key
		self:StoreOutput(key,value)
	elseif key=="onhalftimescale" then
		self.OnHalfTimescale = key
		self:StoreOutput(key,value)
	elseif key=="onnormaltimescale" then
		self.OnNormalTimescale = key
		self:StoreOutput(key,value)
	elseif key=="ondoubletimescale" then
		self.OnDoubleTimescale = key
		self:StoreOutput(key,value)
	elseif key=="onquadrupletimescale" then
		self.OnQuadrupleTimescale = key
		self:StoreOutput(key,value)
	elseif key=="onoctupletimescale" then
		self.OnOctupleTimescale = key
		self:StoreOutput(key,value)
	end
end

function ENT:AcceptInput(input,activator,caller,data)
	input = input:lower()
	if input=="setquartertimescale" then
		game.SetTimeScale(0.25)
	elseif input=="sethalftimescale" then
		game.SetTimeScale(0.5)
	elseif input=="setnormaltimescale" then
		game.SetTimeScale(1)
	elseif input=="setdoubletimescale" then
		game.SetTimeScale(2)
	elseif input=="setquadrupletimescale" then
		game.SetTimeScale(4)
	elseif input=="setoctupletimescale" then
		game.SetTimeScale(8)
	elseif input=="settimescale" then
		game.SetTimeScale(tonumber(data) or 1)
	elseif input=="gettimescale" then
		self:TriggerOutput(self.OnGetTimescale or "OnGetTimescale",activator,game.GetTimeScale())
	end
end

function ENT:Think()
	if self.MonitorTimescale then
		if self.OldTimescale ~= game.GetTimeScale() then
			if self.OldTimescale then
				local logNewTS = math.Round(math.log(game.GetTimeScale(), 2))
				if logNewTS == -2 then
					self:TriggerOutput(self.OnQuarterTimescale or "OnQuarterTimescale", self, game.GetTimeScale())
				elseif logNewTS == -1 then
					self:TriggerOutput(self.OnHalfTimescale or "OnHalfTimescale", self, game.GetTimeScale())
				elseif logNewTS == 0 then
					self:TriggerOutput(self.OnNormalTimescale or "OnNormalTimescale", self, game.GetTimeScale())
				elseif logNewTS == 1 then
					self:TriggerOutput(self.OnDoubleTimescale or "OnDoubleTimescale", self, game.GetTimeScale())
				elseif logNewTS == 2 then
					self:TriggerOutput(self.OnQuadrupleTimescale or "OnQuadrupleTimescale", self, game.GetTimeScale())
				elseif logNewTS == 3 then
					self:TriggerOutput(self.OnOctupleTimescale or "OnOctupleTimescale", self, game.GetTimeScale())
				end
				self:TriggerOutput(self.OnPreTimescaleChanged or "OnPreTimescaleChanged", self, self.OldTimescale)
				self:TriggerOutput(self.OnPostTimescaleChanged or "OnPostTimescaleChanged", self, game.GetTimeScale())
			end
			self.OldTimescale = game.GetTimeScale()
		end
	end
end