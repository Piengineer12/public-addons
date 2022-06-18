local nextUpdate = 0
local nextFullUpdate = 0

AccessorFunc(GM, "GameIsOver", "GameIsOver", FORCE_BOOL)
AccessorFunc(GM, "Defeated", "Defeated", FORCE_BOOL)
AccessorFunc(GM, "StatRebroadcastRequired", "StatRebroadcastRequired", FORCE_BOOL)
AccessorFunc(GM, "PreventPlayerPhysgun", "PreventPlayerPhysgun", FORCE_BOOL)
AccessorFunc(GM, "MaxWaveReached", "MaxWaveReached", FORCE_NUMBER)

function GM:Initialize()
	hook.Run("SetGameIsOver", false)
	hook.Run("SetDefeated", false)
	hook.Run("SetPlayerStatsRequireUpdates", {})
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
	hook.Run("StatisticsThink")
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
	hook.Run("SetMaxWaveReached", 0)
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

function GM:gBalloonDamaged(bln, attacker, inflictor, damage, cash, deductedCash, isPopped)
	if attacker:IsPlayer() and damage > 0 then
		local scoreAdd = (damage - deductedCash) * hook.Run("GetScoreMultiplier")
		local xpAdd = (damage - deductedCash) * hook.Run("GetXPMultiplier")
		attacker.rtg_gBalloonPops = (attacker.rtg_gBalloonPops or 0) + scoreAdd
		attacker.rtg_XP = (attacker.rtg_XP or 0) + xpAdd
		attacker:RTG_AddStat("damage", damage)
		attacker:RTG_AddStat("pops", cash)
		attacker:RTG_SetStat("level", attacker:RTG_GetLevel())
		net.Start("rotgb_statchanged", true)
		net.WriteUInt(RTG_STAT_POPS, 4)
		net.WriteUInt(1, 12)
		net.WriteEntity(attacker)
		net.WriteDouble(attacker.rtg_gBalloonPops or 0)
		net.WriteDouble(attacker.rtg_XP)
		net.Send(attacker)
		hook.Run("SetStatRebroadcastRequired", true)
		
		if bln:GetBalloonProperty("BalloonType") == "gballoon_blimp_rainbow" and isPopped then
			attacker:RTG_AddStat("pops.gballoon_blimp_rainbow", 1)
		end
	end
	for k,v in pairs(player.GetAll()) do
		v:RTG_SetStat("cash", ROTGB_GetCash(v))
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
	local difficulties = hook.Run("GetDifficulties")
	
	if currentDifficulty and difficulties[currentDifficulty] then
		local difficultyTable = difficulties[currentDifficulty]
		
		multiplier = multiplier * (difficultyTable.custom and 0 or difficultyTable.xpmul or 1)
	end
	multiplier = multiplier * (1+hook.Run("GetSkillAmount", "skillExperience")/100)
	if hook.Run("GetMaxWaveReached") then
		multiplier = multiplier * (1+hook.Run("GetSkillAmount", "skillExperiencePerWave")*hook.Run("GetMaxWaveReached")/100)
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
	if success then
		local plys = player.GetAll()
		local flawless, zeroScore = true, true
		
		for k,v in pairs(ents.FindByClass("gballoon_target")) do
			if v:Health() < v:GetMaxHealth() then
				flawless = false break
			end
		end
		
		for k,v in pairs(plys) do
			if v.rtg_gBalloonPops > 0 then
				zeroScore = false break
			end
		end
		
		local difficulty = hook.Run("GetDifficulty")
		for k,v in pairs(plys) do
			if v:Team() == TEAM_BUILDER or v:Team() == TEAM_HUNTER then
				v:RTG_AddStat("success", 1)
				if flawless then
					v:RTG_AddStat("success.no_damage", 1)
				end
				if zeroScore then
					v:RTG_AddStat("success.no_score", 1)
				end
				
				if difficulty == "insane_bosses" then
					v:RTG_AddStat("success.insane_bosses", 1)
				elseif difficulty == "impossible_bosses" then
					v:RTG_AddStat("success.impossible_bosses", 1)
				end
			end
		end
	else
		hook.Run("SetDefeated", true)
		local plys = player.GetAll()
		local zeroScore = true
		
		for k,v in pairs(plys) do
			v:RTG_AddStat("fail", 1)
			v:ROTGB_StartSpectateRandomEntity()
			v:StripWeapons()
			v:ScreenFade(SCREENFADE.IN, color_black, 5, 0)
			if v.rtg_gBalloonPops > 0 then
				zeroScore = false break
			end
		end
		
		for k,v in pairs(plys) do
			if zeroScore then
				v:RTG_AddStat("fail.no_score", 1)
			end
		end
	end
	hook.Run("SetGameIsOver", true)
end

function GM:CleanUpMap()
	game.CleanUpMap(false, {
		"env_fire", -- https://github.com/Facepunch/garrysmod-issues/issues/3637
		"entityflame",
		"_firesmoke"
	})
end

hook.Add("RotgBTowerPlaced", "ROTGB_TG_SERVER", function(tower, cost)
	tower:GetTowerOwner():RTG_AddStat("cash.towers", cost)
	tower:GetTowerOwner():RTG_AddStat("towers", 1)
end)

function GM:RotgBTowerUpgraded(tower, path, tier, cost)
	if tower:GetClass()=="gballoon_tower_08" and tower:GetTowerOwner():IsPlayer() then
		tower:GetTowerOwner():RTG_SetStat("towers.upgrades.max_tier.gballoon_tower_08", tier)
	end
	tower:GetTowerOwner():RTG_AddStat("cash.towers", cost)
	tower:GetTowerOwner():RTG_AddStat("towers.upgrades", 1)
	tower:GetTowerOwner():RTG_SetStat("towers.upgrades.max_price", cost)
end