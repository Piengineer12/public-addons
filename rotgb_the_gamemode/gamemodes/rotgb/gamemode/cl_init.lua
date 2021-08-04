include("sh_init.lua")
include("cl_ui.lua")

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
	
	-- taken from base gamemode, wtf does this do?
	GAMEMODE.ShowScoreboard = false
end

local nextNetAttempt = 0
local nextSave = -1
function GM:Think()
	if IsValid(LocalPlayer()) then
		local realTime = RealTime()
		if not LocalPlayer().rotgb_PreviousPops and nextNetAttempt <= realTime then
			nextNetAttempt = realTime + self.NetSendInterval
			nextSave = realTime + self.DatabaseSaveInterval
			net.Start("rotgb_statchanged", false)
			net.WriteUInt(ROTGB_STAT_INITEXP, 4)
			net.WriteDouble(hook.Run("LoadClientExperience"))
			net.SendToServer()
		end
		if nextSave > 0 and nextSave <= realTime then
			nextSave = realTime + self.DatabaseSaveInterval
			hook.Run("SaveClientExperience")
		end
		if not self.HasReadHelp then
			if not IsValid(self.StartupMenu) then
				self:ShowHelp()
			end
		elseif not (self.HasSeenTeams or IsValid(self.TeamSelectFrame)) then
			self:ShowTeam()
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
	self.HasSeenTeams = false
end

-- non-base

net.Receive("rotgb_statchanged", function()
	local func = net.ReadUInt(4)
	if func == ROTGB_STAT_POPS then
		for i=1,net.ReadUInt(16) do
			local player = net.ReadEntity()
			if IsValid(player) then
				player.rotgb_gBalloonPops = net.ReadDouble()
			end
		end
	elseif func == ROTGB_STAT_INITEXP then
		local player = net.ReadEntity()
		if IsValid(player) then
			player.rotgb_PreviousPops = net.ReadDouble()
		end
	end
end)

net.Receive("rotgb_gameend", function()
	hook.Run("GameOver", net.ReadBool())
end)

function GM:LoadClientExperience()
	--[[local result = hook.Run("DoSQLiteQuery", "SELECT xp FROM rotgb_data;")
	return result and tonumber(result[1].xp) or 0]]
	
	local data = file.Read("rotgb_data.dat", "DATA")
	if data then
		local tabl = util.JSONToTable(data)
		return tabl and tonumber(tabl.xp) or 0
	end
	
	return 0
end

function GM:SaveClientExperience()
	--[[local xpStr = tostring(LocalPlayer():ROTGB_GetExperience())
	hook.Run("DoSQLiteQuery", string.format("UPDATE rotgb_data SET xp = %s;", xpStr))]]
	
	local tabl = {}
	local data = file.Read("rotgb_data.dat", "DATA")
	if data then tabl = util.JSONToTable(data) or tabl end
	
	tabl.xp = LocalPlayer().rotgb_gBalloonPops
	file.Write("rotgb_data.dat", util.TableToJSON(tabl))
end