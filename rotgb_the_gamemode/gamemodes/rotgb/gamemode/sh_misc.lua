function GM:CreateTeams()
	hook.Run("InitializeTeams")
end

function GM:PhysgunPickup(ply, ent)
	if self.DebugMode then return true
	elseif ent.Base == "gballoon_tower_base" then return hook.Run("GetSkillAmount", "physgun") > 0 and not ROTGB_BalloonsExist()
	end
	return false
end

function GM:PhysgunDrop(ply, ent)
	if ent.Base == "gballoon_tower_base" then
		local physObj = ent:GetPhysicsObject()
		if IsValid(physObj) then
			physObj:EnableMotion(false)
		end
	end
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
	for k,v in pairs(player.GetAll()) do
		v.rotgb_allyPawnFirstFreeDone = nil
	end
	if SERVER then
		hook.Run("PostCleanupMapServer")
	end
end

-- non-base

function GM:SharedInitialize()
	hook.Run("RebuildSkills")
	hook.Run("SetCachedSkillAmounts", {})
	hook.Run("SetStatisticAmounts", {})
	hook.Run("InitializeDifficulties")
end

AccessorFunc(GM, "CurrentVote", "CurrentVote")

function GM:ShouldConVarOverride(cvar)
	local currentDifficulty = hook.Run("GetDifficulty")
	local difficulties = hook.Run("GetDifficulties")
	
	if difficulties then
		return difficulties[currentDifficulty] and difficulties[currentDifficulty].convars[cvar] or difficulties.__common.convars[cvar]
	end
end
