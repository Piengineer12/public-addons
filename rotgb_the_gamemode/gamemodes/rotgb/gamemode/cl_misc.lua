AccessorFunc(GM, "StartupState", "StartupState", FORCE_NUMBER)
AccessorFunc(GM, "NextSave", "NextSave", FORCE_NUMBER)
AccessorFunc(GM, "MapTable", "MapTable")
AccessorFunc(GM, "CompletedDifficulties", "CompletedDifficulties")

function GM:Initialize()
	--[[local creationNeeded = not sql.TableExists("rotgb_data")
	if not creationNeeded then
		local result = sql.Query("SELECT version FROM rotgb_data;")
		if result then
			local version = result[1].version
			if version ~= self.DatabaseFormatVersion then
				-- there are no future versions at the moment, database must be broken
				hook.Run("DoSQLiteQuery", "DROP TABLE rotgb_data;")
				creationNeeded = true
			end
		else
			hook.Run("DoSQLiteQuery", "DROP TABLE rotgb_data;")
			creationNeeded = true
		end
	end
	
	if creationNeeded then
		-- we only need to keep the local player's data, so having only a single row is OK
		-- no primary keys required
		hook.Run("DoSQLiteQuery", "CREATE TABLE rotgb_data (version INTEGER NOT NULL, xp NUMERIC);")
		hook.Run("DoSQLiteQuery", string.format("INSERT INTO rotgb_data (version) VALUES (%u);", self.DatabaseFormatVersion))
	end]]
	hook.Run("SetStartupState", 0)
	hook.Run("SetNextSave", 0)
	hook.Run("SharedInitialize")
	hook.Run("SetCompletedDifficulties", {})
	hook.Run("SetUnlockedAchievements", {})
	
	-- taken from base gamemode, wtf does this do?
	GAMEMODE.ShowScoreboard = false
end

function GM:InitPostEntity()
	hook.Run("InitializePlayer", LocalPlayer())
	hook.Run("LoadClient", LocalPlayer())
end

local nextNetAttempt = 0
local lastUIThink = 0
function GM:Think()
	local localPlayer = LocalPlayer()
	if IsValid(localPlayer) then
		local realTime = RealTime()
		local startupState = hook.Run("GetStartupState")
		if hook.Run("GetNextSave") > 0 and hook.Run("GetNextSave") <= realTime then
			hook.Run("SetNextSave", realTime + self.DatabaseSaveInterval)
			hook.Run("SaveClient", LocalPlayer())
		end
		if lastUIThink + 0.5 < realTime then
			lastUIThink = realTime
			if startupState<1 then
				if not IsValid(hook.Run("GetStartupMenu")) then
					hook.Run("ShowHelp")
				end
			elseif (localPlayer:IsAdmin() or (self:GetDifficulty() or "") == "") and startupState<2 then
				if not IsValid(hook.Run("GetDifficultySelectionMenu")) then
					hook.Run("ShowDifficultySelection")
				end
			elseif startupState<3 and not IsValid(hook.Run("GetTeamSelectionMenu")) then
				hook.Run("ShowTeam", true)
			end
		end
	end
end

function GM:ShutDown()
	hook.Run("SaveClient")
end

function GM:PostCleanupMap()
	if IsValid(self.GameOverMenu) then
		self.GameOverMenu:Close()
	end
end

-- non-base

function GM:StartVote(voteInfo)
	hook.Run("SetCurrentVote", voteInfo)
	hook.Run("ShowVoterMenu")
end

function GM:GameOver(success)
	if success then
		surface.PlaySound("rotgb_the_gamemode/victory.wav")
		self.GameOverMenu = hook.Run("CreateSuccessMenu")
		hook.Run("AddCompletedDifficulties", game.GetMap(), hook.Run("GetDifficulty"), 1)
	else
		surface.PlaySound("rotgb_the_gamemode/defeat.wav")
		self.GameOverMenu = hook.Run("CreateFailureMenu")
	end
	hook.Run("SaveClient", LocalPlayer())
end