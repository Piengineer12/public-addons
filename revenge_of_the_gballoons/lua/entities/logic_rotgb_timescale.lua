ENT.Type = "point"
ENT.PrintName = "RotgB Timescale Logic"
ENT.Author = "Piengineer"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Sets or gets the current timescale multiplier."
ENT.Instructions = "Hook this entity's inputs and outputs to something."

function ENT:KeyValue(key,value)
	if key:lower()=="ongettimescale" then
		self.OnGetTimescale = key
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
	else
		if input=="settimescale" then
			game.SetTimeScale(tonumber(data) or 1)
		elseif input=="gettimescale" then
			self:TriggerOutput(self.OnGetTimescale or "OnGetTimescale",activator,game.GetTimeScale())
		end
	end
end