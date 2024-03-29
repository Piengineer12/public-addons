function GM:CreateTeams()
	hook.Run("InitializeTeams")
end

function GM:PhysgunPickup(ply, ent)
	if self.DebugMode then return true
	elseif ent.Base == "gballoon_tower_base" then return hook.Run("GetSkillAmount", "physgun") > 0 and not ROTGB_BalloonsExist()
	end
	return false
end

function GM:PlayerNoClip(ply, desired)
	return self.DebugMode
end

function GM:OnPlayerHitGround(ply, intoWater, onFloating, fallSpeed)
	-- players do not take fall damage
	return true
end

function GM:CanProperty(ply, property, ent)
	if property == "remover" then
		return ent.Base == "gballoon_tower_base"
	end
	return false
end

function GM:PostCleanupMap()
	hook.Run("SetGameIsOver", false)
	for k,v in pairs(player.GetAll()) do
		v.rotgb_allyPawnFirstFreeDone = nil
	end
	if SERVER then
		hook.Run("PostCleanupMapServer")
	end
end

-- non-base

AccessorFunc(GM, "CurrentVote", "CurrentVote")
AccessorFunc(GM, "GameIsOver", "GameIsOver", FORCE_BOOL)

function GM:SharedInitialize()
	hook.Run("SetGameIsOver", false)
	hook.Run("RebuildSkills")
	hook.Run("SetCachedSkillAmounts", {})
	hook.Run("SetStatisticAmounts", {})
	hook.Run("InitializeDifficulties")
end

function GM:ShouldConVarOverride(cvar)
	local currentDifficulty = hook.Run("GetDifficulty")
	local difficulties = hook.Run("GetDifficulties")
	
	if difficulties then
		return difficulties[currentDifficulty] and difficulties[currentDifficulty].convars[cvar] or difficulties.__common.convars[cvar]
	end
end