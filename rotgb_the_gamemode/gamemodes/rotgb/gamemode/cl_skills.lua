function GM:PlayerAddSkills(ply, skillIDs)
	local skillsMenu = hook.Run("GetSkillTreeMenu")
	if IsValid(skillsMenu) then
		for k,v in pairs(skillIDs) do
			skillsMenu:ActivatePerk(k)
		end
	end
end
