include("sh_init.lua")
include("cl_hud.lua")
include("cl_net.lua")
include("cl_skills.lua")
include("cl_ui.lua")

AccessorFunc(GM, "StartupState", "StartupState", FORCE_NUMBER)

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
	hook.Run("SharedInitialize")
	
	-- taken from base gamemode, wtf does this do?
	GAMEMODE.ShowScoreboard = false
end

function GM:InitPostEntity()
	hook.Run("InitializePlayer", LocalPlayer())
end

local nextNetAttempt = 0
local lastUIThink = 0
local nextSave = -1
function GM:Think()
	local localPlayer = LocalPlayer()
	if IsValid(localPlayer) then
		local realTime = RealTime()
		local startupState = hook.Run("GetStartupState")
		if not localPlayer.rtg_PreviousXP and nextNetAttempt <= realTime then
			nextNetAttempt = realTime + self.NetSendInterval
			nextSave = realTime + self.DatabaseSaveInterval
			net.Start("rotgb_statchanged")
			net.WriteUInt(RTG_STAT_INITEXP, 4)
			net.WriteDouble(hook.Run("LoadClientExperience"))
			net.SendToServer()
		end
		if nextSave > 0 and nextSave <= realTime then
			nextSave = realTime + self.DatabaseSaveInterval
			hook.Run("SaveClientExperience")
		end
		if lastUIThink + 0.5 < realTime then
			lastUIThink = realTime
			if startupState<1 then
				if not IsValid(hook.Run("GetStartupMenu")) then
					hook.Run("ShowHelp")
				end
			elseif localPlayer:IsAdmin() and (self:GetDifficulty() or "") == "" and startupState<2 then
				if not IsValid(hook.Run("GetDifficultySelectionMenu")) then
					hook.Run("ShowDifficultySelection", true)
				end
			elseif startupState<3 and not IsValid(hook.Run("GetTeamSelectionMenu")) then
				hook.Run("ShowTeam")
			end
		end
	end
end

function GM:ShutDown()
	hook.Run("SaveClientExperience")
end

function GM:PostCleanupMap()
	if IsValid(self.GameOverMenu) then
		self.GameOverMenu:Close()
	end
end

-- non-base

concommand.Add("rotgb_tg_difficulty_menu", function()
	hook.Run("ShowDifficultySelection")
end, nil, "Opens the Difficulty Selection Menu. Only works for admins.")

concommand.Add("rotgb_tg_vote", function()
	hook.Run("ShowVoteMenu")
end, nil, "Opens the vote selection menu.")

concommand.Add("rotgb_tg_skill_tree", function()
	hook.Run("ShowSkillTree")
end, nil, "Opens the skill tree menu.")

function GM:LoadClientExperience()
	local data = file.Read("rotgb_tg_data.dat", "DATA")
	if data then
		local tabl = util.JSONToTable(data)
		return tabl and tonumber(tabl.xp) or 0
	end
	
	return 0
end

function GM:SaveClientExperience()
	local tabl = {}
	local data = file.Read("rotgb_tg_data.dat", "DATA")
	if data then tabl = util.JSONToTable(data) or tabl end
	
	tabl.xp = LocalPlayer():RTG_GetExperience()
	file.Write("rotgb_tg_data.dat", util.TableToJSON(tabl))
end

function GM:StartVote(voteInfo)
	hook.Run("SetCurrentVote", voteInfo)
	hook.Run("ShowVoterMenu")
end