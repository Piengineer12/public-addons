local tutorialState = 0
local maxTutorial = 10
local color_aqua = Color(0, 255, 255)

hook.Add("PostCleanupMap", "rotgb_aquatic", function()
	tutorialState = 0
	maxTutorial = 10
end)

hook.Add("PlayerSpawn", "rotgb_aquatic", function(ply, typ)
	-- check if a player has really spawned, the tutorial state is 0 and the difficulty is "special_tutorial"
	if ply:Team() == TEAM_BUILDER and hook.Run("GetDifficulty") == "special_tutorial" and tutorialState == 0 then
		tutorialState = 1
		ROTGB_CauseNotification(ROTGB_NOTIFY_TUTORIAL,ROTGB_NOTIFYTYPE_CHAT,ply,{"u8",1})
		
		local tutorialTrigger = ents.FindByName("rotgb_special_tutorial_1_relay")[1]
		if IsValid(tutorialTrigger) then
			tutorialTrigger:Fire("Trigger")
		end
	end
end)

hook.Add("KeyPress", "rotgb_aquatic", function(ply, key)
	if key == IN_JUMP then
		if tutorialState > 0 and tutorialState < maxTutorial then
			tutorialState = tutorialState + 1
			local shouldHighlight = tutorialState == 10 or tutorialState >= 13
			ROTGB_CauseNotification(ROTGB_NOTIFY_TUTORIAL,ROTGB_NOTIFYTYPE_CHAT,ply,{"u8",tutorialState,color=shouldHighlight and color_aqua})
			
			local tutorialTrigger = ents.FindByName(string.format("rotgb_special_tutorial_%i_relay", tutorialState))[1]
			if IsValid(tutorialTrigger) then
				tutorialTrigger:Fire("Trigger")
			end
		end
	end
end)

hook.Add("RotgBSWEPTowerSelected", "rotgb_aquatic", function(ply, class, wep)
	maxTutorial = math.max(maxTutorial, 13)
	if tutorialState == 10 then
		tutorialState = 11
		ROTGB_CauseNotification(ROTGB_NOTIFY_TUTORIAL,ROTGB_NOTIFYTYPE_CHAT,ply,{"u8",tutorialState})
	end
end)

hook.Add("RotgBSWEPTowerPlaced", "rotgb_aquatic", function(ply, class, wep)
	maxTutorial = math.max(maxTutorial, 14)
	if tutorialState == 13 then
		tutorialState = 14
		ROTGB_CauseNotification(ROTGB_NOTIFY_TUTORIAL,ROTGB_NOTIFYTYPE_CHAT,ply,{"u8",tutorialState,color=color_aqua})
		
		local tutorialTrigger = ents.FindByName("rotgb_special_tutorial_14_relay")[1]
		if IsValid(tutorialTrigger) then
			tutorialTrigger:Fire("Trigger")
		end
	end
end)

hook.Add("RotgBSWEPStartWave", "rotgb_aquatic", function(ply, wep)
	if tutorialState > 0 and tutorialState < 14 then return false end
end)