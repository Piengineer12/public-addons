ENT.Type = "point"
ENT.PrintName = "RotgB Game Entity"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Special entity used to store some data for saving and loading."
ENT.Instructions = "Do not use this entity directly."

function ENT:Initialize()
	self.PlayerCash = {}
	self:SetName("game_rotgb")
end

function ENT:SetCash(cash, ply)
	cash = tonumber(cash) or 0
	if ROTGB_GetConVarValue("rotgb_individualcash") then
		if ply then
			self.PlayerCash[ply:SteamID()] = cash
			ROTGB_UpdateCash(ply)
		else
			for k,v in pairs(player.GetAll()) do
				self.PlayerCash[v:SteamID()] = cash
				ROTGB_UpdateCash(v)
			end
		end
	else
		self.PlayerCash[""] = cash
		ROTGB_UpdateCash()
	end
end

function ENT:GetCash(ply)
	local startingCash = hook.Run("GetStartingRotgBCash") or ROTGB_GetConVarValue("rotgb_starting_cash")
	if ROTGB_GetConVarValue("rotgb_individualcash") then
		if ply then return self.PlayerCash[ply:SteamID()] or startingCash
		else
			local sum = 0
			for k,v in pairs(player.GetAll()) do
				sum = sum + (self.PlayerCash[v:SteamID()] or startingCash)
			end
			return sum
		end
	else
		return self.PlayerCash[""] or startingCash
	end
end

function ENT:PostEntityPaste()
	if ROTGB_GetConVarValue("rotgb_individualcash") then
		for k,v in pairs(player.GetAll()) do
			ROTGB_UpdateCash(v)
		end
	else
		ROTGB_UpdateCash()
	end
	-- some other game_rotgb might have been initialized while we were away, delete it
	for k,v in pairs(ents.FindByClass("game_rotgb")) do
		if not (v.PlayerCash and next(v.PlayerCash)) then
			v:Remove()
		end
	end
end