function GM:LoadClient()
	local data = util.JSONToTable(file.Read("rotgb_tg_data.dat", "DATA") or "")
	if data then
		local xp = tonumber(data.xp) or 0
		local skills = data.skills
		net.Start("rotgb_statchanged")
		
		net.WriteUInt(RTG_STAT_INIT, 4)
		net.WriteDouble(xp)
		
		if (skills and next(skills)) then
			local validatedSkills = {}
			local skillNames = hook.Run("GetSkillNames")
			for k,v in pairs(skills) do
				if skillNames[k] then
					table.insert(validatedSkills, skillNames[k]-1)
				end
			end
			
			net.WriteUInt(RTG_SKILL_MULTIPLE, 2)
			net.WriteUInt(#validatedSkills-1, 12)
			
			for k,v in pairs(validatedSkills) do
				net.WriteUInt(v, 12)
			end
		else
			net.WriteUInt(RTG_SKILL_CLEAR, 2)
		end
		
		net.SendToServer()
	end
end

function GM:SaveClient()
	local ply = LocalPlayer()
	local plySkills = ply:RTG_GetSkills()
	local data = {}
	data.xp = ply:RTG_GetExperience()
	data.skills = {}
	for k,v in pairs(hook.Run("GetSkillNames")) do
		if ply:RTG_HasSkill(v) then
			data.skills[k] = plySkills[v]
		end
	end
	file.Write("rotgb_tg_data.dat", util.TableToJSON(data))
end
