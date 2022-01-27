function GM:PlayerCanJoinTeam(ply, teamID)
	local TimeBetweenSwitches = self.SecondsBetweenTeamSwitches
	if ply.LastTeamSwitch and RealTime() < ply.LastTeamSwitch + TimeBetweenSwitches then
		local delay = TimeBetweenSwitches + ply.LastTeamSwitch - RealTime()
		ply:ChatPrint(string.format("Please wait %.2f more seconds before switching teams!", delay))
		return false
	end
	
	if ply:Team() == teamID then
		ply:ChatPrint("You're already on that team!")
		return false
	end
	
	return true
end

function GM:PlayerRequestTeam(ply, teamID)
	if not team.Valid(teamID) then
		ply:ChatPrint("That team does not exist!")
	elseif not team.Joinable(teamID) then
		ply:ChatPrint("You can't join that team!")
	elseif hook.Run("PlayerCanJoinTeam", ply, teamID) then
		hook.Run("PlayerJoinTeam", ply, teamID)
	end
end

function GM:PlayerJoinTeam(ply, teamID)
	local oldTeam = ply:Team()
	
	if ply:Alive() then
		if oldTeam == TEAM_SPECTATOR or oldTeam == TEAM_UNASSIGNED then
			ply:KillSilent()
		else
			ply:Kill()
		end
	end
	
	ply:SetTeam(teamID)
	ply.LastTeamSwitch = RealTime()
	
	if teamID == TEAM_BUILDER then
		player_manager.SetPlayerClass(ply, "Builder")
	elseif teamID == TEAM_HUNTER then
		player_manager.SetPlayerClass(ply, "Hunter")
	end
	
	hook.Run("OnPlayerChangedTeam", ply, oldTeam, teamID)
end

function GM:OnPlayerChangedTeam(ply, oldTeam, newTeam)
	hook.Run("RecreateSpectatorTable")
	
	if newTeam == TEAM_SPECTATOR then
		local pos = ply:EyePos()
		ply:Spawn()
		ply:SetPos(pos)
	elseif oldTeam == TEAM_SPECTATOR or oldTeam == TEAM_UNASSIGNED then
		ply:Spawn()
	end
	
	if oldTeam == TEAM_UNASSIGNED then
		PrintMessage(HUD_PRINTTALK, string.format("%s has joined the %s team", ply:Nick(), team.GetName(newTeam)))
	else
		PrintMessage(HUD_PRINTTALK, string.format("%s has switched from the %s team to the %s team", ply:Nick(), team.GetName(oldTeam), team.GetName(newTeam)))
	end
end