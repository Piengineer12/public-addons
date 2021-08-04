function GM:PlayerSpawnAsSpectator(ply)
	ply:StripWeapons()
	if ply:Team() == TEAM_UNASSIGNED then
		ply:Spectate(OBS_MODE_IN_EYE)
		local possibleEntities = hook.Run("GetSpectatableEntities", ply)
		local targetEntity = game.GetWorld()
		if next(possibleEntities) then
			targetEntity = possibleEntities[math.random(#possibleEntities)]
		end
		if not IsValid(targetEntity) then
			targetEntity = game.GetWorld()
		end
		ply:SpectateEntity(targetEntity)
	else
		ply:Spectate(OBS_MODE_ROAMING)
	end
end

function GM:SpectatorKeyPress(ply, action)
	local spectatables = hook.Run("GetSpectatableEntities", ply)
	local specIndex = table.KeyFromValue(spectatables, ply:GetObserverTarget()) or 1
	
	if action == IN_ATTACK then
		specIndex = specIndex % #spectatables + 1
		local entityToSpectate = spectatables[specIndex]
		ply:SpectateEntity(entityToSpectate)
		hook.Run("ApplyEntitySpectateProperties", ply, entityToSpectate, false)
	elseif action == IN_ATTACK2 then
		specIndex = (specIndex - 2) % #spectatables + 1
		local entityToSpectate = spectatables[specIndex]
		ply:SpectateEntity(entityToSpectate)
		hook.Run("ApplyEntitySpectateProperties", ply, entityToSpectate, false)
	elseif action == IN_DUCK then
		hook.Run("ApplyEntitySpectateProperties", ply, ply:GetObserverTarget(), true)
	end
end

function GM:GetSpectatableEntities(ply)
	self.rotgb_SpectatorEntities = self.rotgb_SpectatorEntities or {}
	table.Empty(self.rotgb_SpectatorEntities)
	
	for i,v in ipairs(ents.GetAll()) do
		local class = v:GetClass()
		if (class == "point_rotgb_spectator" and v:PlayerCanSpectate(ply, self.Defeated)) then
			table.insert(self.rotgb_SpectatorEntities, v)
		elseif ply:Team()~=TEAM_UNASSIGNED then
			if class == "gballoon_spawner" or class == "gballoon_target" then
				if not v:GetUnSpectatable() then
					table.insert(self.rotgb_SpectatorEntities, v)
				end
			elseif class == "player" then
				local team = v:Team()
				if team~=TEAM_CONNECTING and team~=TEAM_UNASSIGNED and team~=TEAM_SPECTATOR then
					table.insert(self.rotgb_SpectatorEntities, v)
				end
			elseif class == "worldspawn" then
				table.insert(self.rotgb_SpectatorEntities, v)
			end
		end
	end
	
	return self.rotgb_SpectatorEntities
end

function GM:ApplyEntitySpectateProperties(ply, ent, modChange)
	if IsValid(ent) then
		local class = ent:GetClass()
		if class == "point_rotgb_spectator" then
			ply:SetFOV(ent:GetFOV(), 0, ent)
			ply:SetObserverMode(OBS_MODE_IN_EYE)
		else
			ply:SetFOV(0)
			if class == "player" then
				if modChange then
					ply:ToggleFirstPersonPlayerSpectating()
				end
				local newObsMode = ply:IsFirstPersonPlayerSpectating() and OBS_MODE_IN_EYE or OBS_MODE_CHASE
				ply:SetObserverMode(newObsMode)
			elseif class == "worldspawn" then
				ply:SetObserverMode(OBS_MODE_ROAMING)
			else
				ply:SetObserverMode(OBS_MODE_CHASE)
			end
		end
	end
end