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
	hook.Run("SetStatRebroadcastRequired", true)
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	-- players do not ever take damage from each other, nor themselves
	return not attacker:IsPlayer()
end

function GM:OnDamagedByExplosion(ply, dmginfo)
	-- don't make the high pitched ringing noise!
end

function GM:GetFallDamage(ply, flFallSpeed)
	return 0
end

function GM:PlayerSay(ply, message, forTeam)
	local loweredMessage = message:lower()
	if loweredMessage == "!options" or loweredMessage == "!rtg_options" then
		ply:ConCommand("rotgb_config_menu_client")
		return ""
	elseif loweredMessage == "!skills" or loweredMessage == "!rtg_skills" then
		ply:ConCommand("rotgb_tg_skill_web")
		return ""
	elseif loweredMessage == "!difficulty" or loweredMessage == "!rtg_difficulty" then
		ply:ConCommand("rotgb_tg_difficulty_menu")
		return ""
	elseif loweredMessage == "!vote" or loweredMessage == "!rtg_vote" then
		ply:ConCommand("rotgb_tg_vote")
		return ""
	elseif loweredMessage == "!guide" or loweredMessage == "!rtg_guide" then
		ply:ConCommand("rotgb_guide_book")
		return ""
	elseif loweredMessage == "!achievements" or loweredMessage == "!rtg_achievements" then
		ply:ConCommand("rotgb_tg_achievements")
		return ""
	elseif loweredMessage == "!teams" or loweredMessage == "!rtg_teams" then
		ply:ConCommand("gm_showteam")
		return ""
	end
	return message
end

function GM:PlayerSilentDeath(ply)
	ply.NextSpawnTime = CurTime() + self.SpawnDelay
	ply.DeathTime = CurTime()
end

function GM:PlayerDeath(ply, inflictor, attacker)
	ply.NextSpawnTime = CurTime() + self.SpawnDelay
	ply.DeathTime = CurTime()
	hook.Run("SetBLIMPSConditionsViolated", true)
	
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
	
	-- copied from base gamemode, don't ask me why this is like this.
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