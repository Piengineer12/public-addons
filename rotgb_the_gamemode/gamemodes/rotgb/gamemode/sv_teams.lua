function GM:PlayerCanJoinTeam(ply, teamID)
	local TimeBetweenSwitches = self.SecondsBetweenTeamSwitches
	if ply.LastTeamSwitch and RealTime() < ply.LastTeamSwitch + TimeBetweenSwitches then
		local delay = TimeBetweenSwitches + ply.LastTeamSwitch - RealTime()
		net.Start("rotgb_gamemode")
		net.WriteUInt(RTG_OPERATION_TEAM, 4)
		net.WriteUInt(RTG_TEAM_WAIT, 4)
		net.WriteFloat(delay)
		net.Send(ply)
		return false
	end
	
	if ply:Team() == teamID then
		net.Start("rotgb_gamemode")
		net.WriteUInt(RTG_OPERATION_TEAM, 4)
		net.WriteUInt(RTG_TEAM_SAME, 4)
		net.Send(ply)
		return false
	end
	
	return true
end

function GM:PlayerRequestTeam(ply, teamID)
	if not team.Valid(teamID) then
		net.Start("rotgb_gamemode")
		net.WriteUInt(RTG_OPERATION_TEAM, 4)
		net.WriteUInt(RTG_TEAM_INVALID, 4)
		net.Send(ply)
	elseif not team.Joinable(teamID) then
		net.Start("rotgb_gamemode")
		net.WriteUInt(RTG_OPERATION_TEAM, 4)
		net.WriteUInt(RTG_TEAM_REJECTED, 4)
		net.Send(ply)
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
	--[[elseif teamID == TEAM_HUNTER then
		player_manager.SetPlayerClass(ply, "Hunter")]]
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
	
	net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_TEAM, 4)
	net.WriteUInt(RTG_TEAM_CHANGED, 4)
	net.WriteUInt(ply:UserID(), 16)
	net.WriteInt(oldTeam, 32)
	net.WriteInt(newTeam, 32)
	net.Broadcast()
end