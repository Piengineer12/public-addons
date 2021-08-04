include("sh_init.lua")
include("sv_spawndeath.lua")
include("sv_spectators.lua")
include("sv_teams.lua")

local nextUpdate = 0
local shouldUpdate = false
local hurtFeed = {}

function GM:Initialize()
end

function GM:Think()
	if shouldUpdate and nextUpdate < RealTime() then
		nextUpdate = RealTime() + self.NetSendInterval
		shouldUpdate = false
		local playersToUpdate = {}
		for k,v in pairs(player.GetAll()) do
			if (v.rotgb_gBalloonPops or 0) > 0 and v.rotgb_LastSentgBalloonPops ~= v.rotgb_gBalloonPops then
				v.rotgb_LastSentgBalloonPops = v.rotgb_gBalloonPops
				table.insert(playersToUpdate, v)
			end
		end
		net.Start("rotgb_statchanged")
		net.WriteUInt(ROTGB_STAT_POPS, 4)
		net.WriteUInt(#playersToUpdate, 16)
		for k,v in pairs(playersToUpdate) do
			net.WriteEntity(v)
			net.WriteDouble(v.rotgb_gBalloonPops or 0)
		end
		net.Broadcast()
	end
end

function GM:PostCleanupMap()
	self.Defeated = false
	self.GameIsOver = false
end

function GM:ShowHelp(ply)
	-- why is this not shared?
	ply:SendLua("GAMEMODE:ShowHelp()")
end

function GM:ShowTeam(ply)
	local TimeBetweenSwitches = GAMEMODE.SecondsBetweenTeamSwitches
	if ply.LastTeamSwitch and RealTime() < ply.LastTeamSwitch + TimeBetweenSwitches then
		local delay = TimeBetweenSwitches + ply.LastTeamSwitch - RealTime()
		ply:ChatPrint(string.format("Please wait %.2f more seconds before switching teams!", delay))
	else
		-- again? really?
		ply:SendLua("GAMEMODE:ShowTeam()")
	end
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	-- players do not ever take damage from each other, nor themselvesspec
	return not attacker:IsPlayer()
end

function GM:OnDamagedByExplosion(ply, dmginfo)
	-- don't make the high pitched ringing noise!
end

function GM:GetFallDamage(ply, flFallSpeed)
	return 0
end

local sv_alltalk = GetConVar("sv_alltalk")
function GM:PlayerCanHearPlayersVoice(pListener, pTalker)
	return true, sv_alltalk:GetInt() == 2
end

function GM:KeyPress(ply, ...)
	-- I know this is supposed to be a shared hook, but the spectate commands are serverside only.
	if ply:Team() == TEAM_SPECTATOR then
		hook.Run("SpectatorKeyPress", ply, ...)
	end
end

-- non-base

util.AddNetworkString("rotgb_statchanged")
util.AddNetworkString("rotgb_gameend")

net.Receive("rotgb_statchanged", function(length, ply)
	local func = net.ReadUInt(4)
	if func == ROTGB_STAT_INITEXP then
		if (IsValid(ply) and not ply.rotgb_PreviousPops) then
			ply.rotgb_PreviousPops = net.ReadDouble()
			net.Start("rotgb_statchanged")
			net.WriteUInt(ROTGB_STAT_INITEXP, 4)
			net.WriteEntity(ply)
			net.WriteDouble(ply.rotgb_PreviousPops)
			net.Broadcast()
		end
	end
end)

net.Receive("rotgb_gameend", function(length, ply)
	if self.GameIsOver then
		game.CleanUpMap(false, {
			"env_fire",
			"entityflame",
			"_firesmoke" -- https://github.com/Facepunch/garrysmod-issues/issues/3637
		})
	end
end)

function GM:gBalloonDamaged(bln, attacker, inflictor, damage, isPopped)
	if attacker:IsPlayer() and damage > 0 then
		attacker.rotgb_gBalloonPops = (attacker.rotgb_gBalloonPops or 0) + damage
		shouldUpdate = true
	end
end

function GM:gBalloonTargetRemoved(target)
	timer.Simple(0.05, function()
		local defeat = true
		for k,v in pairs(ents.FindByClass("gballoon_target")) do
			if not v:GetNonVital() then
				defeat = false
			end
		end
		if defeat then
			hook.Run("AllTargetsDestroyed")
		end
	end)
end

function GM:AllTargetsDestroyed()
	game.SetTimeScale(0.2)
	for k,v in pairs(player.GetAll()) do
		v:ScreenFade(SCREENFADE.OUT, color_black, 1, 5)
	end
	timer.Simple(1, function()
		hook.Run("GameOver", false)
	end)
end

function GM:AllBalloonsDestroyed()
	timer.Simple(1, function()
		hook.Run("GameOver", true)
	end)
end

function GM:GameOver(success)
	net.Start("rotgb_gameend")
	net.WriteBool(success)
	net.Broadcast()
	self.GameIsOver = true
	if not success then
		self.Defeated = true
		game.SetTimeScale(1)
		for k,v in pairs(player.GetAll()) do
			hook.Run("PlayerJoinTeam", v, TEAM_SPECTATOR)
			v:Spectate(OBS_MODE_IN_EYE)
			local possibleEntities = hook.Run("GetSpectatableEntities", v)
			local targetEntity = game.GetWorld()
			if next(possibleEntities) then
				targetEntity = possibleEntities[math.random(#possibleEntities)]
			end
			if not IsValid(targetEntity) then
				targetEntity = game.GetWorld()
			end
			v:SpectateEntity(targetEntity)
			v:ScreenFade(SCREENFADE.IN, color_black, 5, 0)
		end
	end
end