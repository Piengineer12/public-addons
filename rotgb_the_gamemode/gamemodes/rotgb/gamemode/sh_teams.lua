function GM:InitializeTeams()
	TEAM_BUILDER = 1
	team.SetUp(TEAM_BUILDER, "Builder", Color(255,255,0))
	team.SetClass(TEAM_BUILDER, "Builder")
	team.SetSpawnPoint(TEAM_BUILDER, "info_player_start")
	
	--[[TEAM_HUNTER = 2
	team.SetUp(TEAM_HUNTER, "Hunter", Color(255,127,0))
	team.SetClass(TEAM_HUNTER, "Hunter")
	team.SetSpawnPoint(TEAM_HUNTER, "info_player_start")]]
	
	team.SetColor(TEAM_CONNECTING, Color(127,127,127))
	team.SetColor(TEAM_UNASSIGNED, Color(127,127,127))
	
	team.SetColor(TEAM_SPECTATOR, Color(191,191,191))
	team.SetSpawnPoint(TEAM_SPECTATOR, "info_player_start")
	
	TEAM_DESCRIPTIONS = {
		[TEAM_BUILDER] = {
			"You start with the RotgB Game Tool.",
			"Use the RotgB Game Tool to build towers that pop gBalloons.",
			"You are unable to pop gBalloons yourself."
		},
		--[[[TEAM_HUNTER] = {
			"You start with the Balloon Shooter and $650 less than normal.",
			"You are unable to build towers.",
			"Use the Balloon Shooter to pop gBalloons."
		},]]
		[TEAM_SPECTATOR] = {
			"You start with nothing and do not gain any cash nor experience.",
			"You are invisible and can freely roam around the map.",
			"Press the Primary Fire key to cycle forward between views. Most views disable free roaming.",
			"Press the Secondary Fire key to cycle backward.",
			"While spectating a player, press the Crouch key to toggle between first person mode and third person mode."
		}
	}
end