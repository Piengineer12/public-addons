function GM:InitializeTeams()
	TEAM_BUILDER = 1
	team.SetUp(TEAM_BUILDER, "#rotgb_tg.teams.builder.name", Color(255,255,0))
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
			"#rotgb_tg.teams.builder.description.1",
			"#rotgb_tg.teams.builder.description.2",
			"#rotgb_tg.teams.builder.description.3",
			"#rotgb_tg.teams.builder.description.4",
			"#rotgb_tg.teams.builder.description.5"
		},
		--[[[TEAM_HUNTER] = {
			"You start with the Balloon Shooter and $650 less than normal.",
			"You are unable to build towers.",
			"Use the Balloon Shooter to pop gBalloons."
		},]]
		[TEAM_SPECTATOR] = {
			"#rotgb_tg.teams.spectator.description.1",
			"#rotgb_tg.teams.spectator.description.2",
			"#rotgb_tg.teams.spectator.description.3",
			"#rotgb_tg.teams.spectator.description.4",
			"#rotgb_tg.teams.spectator.description.5"
		}
	}
end