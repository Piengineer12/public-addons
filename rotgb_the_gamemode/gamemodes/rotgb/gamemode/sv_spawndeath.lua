function GM:PlayerInitialSpawn(ply, fromTransition)
	ply:SetTeam(TEAM_UNASSIGNED)
	hook.Run("ShowHelp", ply) -- doing ply:ConCommand("gm_showhelp") is stupid because that way
	-- at least two more network packets will need to be sent between the client and the server
end

function GM:PlayerSpawn(ply, fromTransition)
	if not ply.rtg_XP then
		hook.Run("InitializePlayer", ply)
	end
	if ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED then
		self:PlayerSpawnAsSpectator(ply) -- see sv_spectators.lua
	else
		ply:UnSpectate()
		ply:SetupHands()
		player_manager.OnPlayerSpawn(ply, fromTransition)
		player_manager.RunClass(ply, "Spawn")
		
		ply:StripWeapons()
		hook.Run("PlayerLoadout", ply)
		hook.Run("PlayerSetModel", ply)
	end
end

function GM:PlayerSilentDeath(ply)
	ply.NextSpawnTime = CurTime() + self.SpawnDelay
	ply.DeathTime = CurTime()
end

function GM:PlayerDeath(ply, inflictor, attacker)
	ply.NextSpawnTime = CurTime() + self.SpawnDelay
	ply.DeathTime = CurTime()
	
	if IsValid(attacker) and attacker:IsVehicle() and IsValid(attacker:GetDriver()) then
		inflictor = attacker
		attacker = attacker:GetDriver()
	end
	
	if not IsValid(inflictor) and IsValid(attacker) then
		inflictor = attacker
	end
	
	if IsValid(inflictor) and inflictor == attacker and (inflictor:IsPlayer() or inflictor:IsNPC()) then
		inflictor = inflictor:GetActiveWeapon()
		if not IsValid(inflictor) then inflictor = attacker end
	end
	
	player_manager.RunClass(ply, "Death", inflictor, attacker)
	
	-- copied from base gamemode, but don't ask me why this is like this.
	if attacker == ply then
		net.Start("PlayerKilledSelf")
		net.WriteEntity(ply)
		net.Broadcast()
		MsgAll(attacker:Nick().." suicided!\n")
	elseif attacker:IsPlayer() then
		net.Start("PlayerKilledByPlayer")
		net.WriteEntity(ply)
		net.WriteString(inflictor:GetClass())
		net.WriteEntity(attacker)
		net.Broadcast()
		MsgAll(attacker:Nick().." killed "..ply:Nick().." using "..inflictor:GetClass().."\n")
	else
		net.Start("PlayerKilled")
		net.WriteEntity(ply)
		net.WriteString(inflictor:GetClass())
		net.WriteString(attacker:GetClass())
		net.Broadcast()
		MsgAll(ply:Nick().." was killed by "..attacker:GetClass().."\n")
	end
end

function GM:PlayerDeathThink(ply)
	if ply.NextSpawnTime and ply.NextSpawnTime > CurTime() then return false
	else
		ply:Spawn()
		return true
	end
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	ply:CreateRagdoll()
end