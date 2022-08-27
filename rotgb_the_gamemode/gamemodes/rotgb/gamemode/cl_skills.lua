concommand.Add("rotgb_tg_skill_web", function(ply, cmd, args)
	local towerCount = #ROTGB_GetAllTowers()
	if ply:RTG_GetLevel() - towerCount > 0 then
		hook.Run("ShowSkillWeb")
	else
		ROTGB_CauseNotification(ROTGB_LocalizeString("rotgb_tg.skills.level_requirement", ROTGB_Commatize(towerCount+1)), ROTGB_NOTIFYTYPE_ERROR)
	end
end, nil, "Opens the skill web menu.")

function GM:PlayerAddSkills(ply, skillIDs)
	local skillsMenu = hook.Run("GetSkillWebMenu")
	if IsValid(skillsMenu) then
		for k,v in pairs(skillIDs) do
			skillsMenu:ActivatePerk(k)
			LocalPlayer():EmitSound("ambient/fire/gascan_ignite1.wav", 60, 100, 0.0625)
		end
	end
end