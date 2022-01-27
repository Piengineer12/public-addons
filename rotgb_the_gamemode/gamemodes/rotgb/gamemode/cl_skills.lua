concommand.Add("rotgb_tg_skill_web", function()
	hook.Run("ShowSkillWeb")
end, nil, "Opens the skill web menu.")

function GM:PlayerAddSkills(ply, skillIDs)
	local skillsMenu = hook.Run("GetSkillWebMenu")
	if IsValid(skillsMenu) then
		for k,v in pairs(skillIDs) do
			skillsMenu:ActivatePerk(k)
		end
	end
end