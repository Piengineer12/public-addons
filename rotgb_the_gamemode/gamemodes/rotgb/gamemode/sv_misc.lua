local nextUpdate = 0
local nextFullUpdate = 0

AccessorFunc(GM, "GameIsOver", "GameIsOver", FORCE_BOOL)
AccessorFunc(GM, "Defeated", "Defeated", FORCE_BOOL)
AccessorFunc(GM, "StatRebroadcastRequired", "StatRebroadcastRequired", FORCE_BOOL)
AccessorFunc(GM, "PreventPlayerPhysgun", "PreventPlayerPhysgun", FORCE_BOOL)

function GM:Initialize()
	hook.Run("SetGameIsOver", false)
	hook.Run("SetDefeated", false)
	game.SetGlobalState("rotgb_gamemode_enabled", GLOBAL_ON)
	hook.Run("SharedInitialize")
end

function GM:Think()
	if nextUpdate < RealTime() then
		nextUpdate = RealTime() + self.NetSendInterval
		if hook.Run("GetStatRebroadcastRequired") then
			hook.Run("SetStatRebroadcastRequired", false)
			local playersToUpdate = {}
			for k,v in pairs(player.GetAll()) do
				if v.rotgb_LastSentgBalloonPops ~= v.rtg_gBalloonPops then
					v.rotgb_LastSentgBalloonPops = v.rtg_gBalloonPops
					table.insert(playersToUpdate, v)
				end
			end
			net.Start("rotgb_statchanged", true)
			net.WriteUInt(RTG_STAT_POPS, 4)
			net.WriteUInt(#playersToUpdate, 12)
			for k,v in pairs(playersToUpdate) do
				net.WriteEntity(v)
				net.WriteDouble(v.rtg_gBalloonPops or 0)
				net.WriteDouble(v.rtg_XP)
			end
			net.Broadcast()
		end
		
		hook.Run("CurrentVoteThink")
	end
	if nextFullUpdate < RealTime() then
		nextFullUpdate = RealTime() + self.NetFullUpdateInterval
		local playersToUpdate = player.GetAll()
		net.Start("rotgb_statchanged", true)
		net.WriteUInt(RTG_STAT_FULLUPDATE, 4)
		net.WriteUInt(#playersToUpdate, 12)
		for k,v in pairs(playersToUpdate) do
			net.WriteInt(v:UserID(), 16)
			net.WriteDouble(v.rtg_gBalloonPops or 0)
			net.WriteDouble(v.rtg_PreviousXP or 0)
			net.WriteDouble(v.rtg_XP)
		end
		net.Broadcast()
	end
	if hook.Run("GetPreventPlayerPhysgun") then
		hook.Run("SetPreventPlayerPhysgun", false)
		for k,v in pairs(ents.GetAll()) do
			if v.Base == "gballoon_tower_base" then
				v:ForcePlayerDrop()
			end
		end
	end
end

function GM:AcceptInput(ent, input, activator, caller, data)
	if input:lower()=="use" and (activator:IsPlayer() and activator:Team() == TEAM_SPECTATOR) then return true end
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

function GM:PostCleanupMapServer()
	hook.Run("SetGameIsOver", false)
	hook.Run("SetDefeated", false)
	hook.Run("UpdateAppliedSkills")
	for k,v in pairs(player.GetAll()) do
		v:UnSpectate()
		v:Spawn()
		v.rtg_gBalloonPops = 0
		net.Start("rotgb_statchanged", true)
		net.WriteUInt(RTG_STAT_POPS, 4)
		net.WriteUInt(1, 12)
		net.WriteEntity(v)
		net.WriteDouble(v.rtg_gBalloonPops or 0)
		net.WriteDouble(v.rtg_XP)
		net.Send(v)
	end
	hook.Run("SetStatRebroadcastRequired", true)
end

-- non-base

function GM:gBalloonDamaged(bln, attacker, inflictor, damage, deductedCash, isPopped)
	if attacker:IsPlayer() and damage > 0 then
		local scoreAdd = (damage - deductedCash) * hook.Run("GetScoreMultiplier")
		local xpAdd = (damage - deductedCash) * hook.Run("GetXPMultiplier")
		attacker.rtg_gBalloonPops = (attacker.rtg_gBalloonPops or 0) + scoreAdd
		attacker.rtg_XP = (attacker.rtg_XP or 0) + xpAdd
		net.Start("rotgb_statchanged", true)
		net.WriteUInt(RTG_STAT_POPS, 4)
		net.WriteUInt(1, 12)
		net.WriteEntity(attacker)
		net.WriteDouble(attacker.rtg_gBalloonPops or 0)
		net.WriteDouble(attacker.rtg_XP)
		net.Send(attacker)
		hook.Run("SetStatRebroadcastRequired", true)
	end
end

function GM:GetScoreMultiplier()
	if hook.Run("GetDefeated") then return 0 end
	return 1
end

function GM:GetXPMultiplier()
	if hook.Run("GetGameIsOver") and not self.DebugMode then return 0 end
	
	local multiplier = hook.Run("GetScoreMultiplier")
	local currentDifficulty = hook.Run("GetDifficulty")
	if currentDifficulty and self.Modes[currentDifficulty] then
		multiplier = multiplier * (self.Modes[currentDifficulty].xpmul or 1)
	end
	return multiplier
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
	game.SetTimeScale(0.5)
	for k,v in pairs(player.GetAll()) do
		v:ScreenFade(SCREENFADE.OUT, color_black, 0.9, 1)
	end
	for k,v in pairs(ents.FindByClass("gballoon_spawner")) do
		v:SetAutoStart(false)
	end
	timer.Simple(1, function()
		hook.Run("GameOver", false)
	end)
end

function GM:AllBalloonsDestroyed()
	timer.Simple(1, function()
		if not hook.Run("GetGameIsOver") then
			hook.Run("GameOver", true)
		end
	end)
end

function GM:GameOver(success)
	game.SetTimeScale(1)
	net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_GAMEOVER, 4)
	net.WriteBool(success)
	net.Broadcast()
	hook.Run("SetGameIsOver", true)
	if not success then
		hook.Run("SetDefeated", true)
		for k,v in pairs(player.GetAll()) do
			v:ROTGB_StartSpectateRandomEntity()
			v:StripWeapons()
			v:ScreenFade(SCREENFADE.IN, color_black, 5, 0)
		end
	end
end

function GM:ChangeDifficulty(difficulty)
	-- set the current gamemode for the ShouldConVarOverride hook to refer to, then clean up the map
	hook.Run("SetDifficulty", difficulty)
	net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_DIFFICULTY, 4)
	net.WriteString(difficulty)
	net.Broadcast()
	hook.Run("CleanUpMap")
end

function GM:CleanUpMap()
	game.CleanUpMap(false, {
		"env_fire", -- https://github.com/Facepunch/garrysmod-issues/issues/3637
		"entityflame",
		"_firesmoke"
	})
end