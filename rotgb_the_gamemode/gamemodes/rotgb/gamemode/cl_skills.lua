concommand.Add("rotgb_tg_skill_web", function()
	hook.Run("ShowSkillWeb")
end, nil, "#command.rotgb_tg_skill_web.help")

function GM:PlayerAddSkills(ply, skillIDs)
	local skillsMenu = hook.Run("GetSkillWebMenu")
	if IsValid(skillsMenu) then
		for k,v in pairs(skillIDs) do
			skillsMenu:ActivatePerk(k)
		end
	end
end