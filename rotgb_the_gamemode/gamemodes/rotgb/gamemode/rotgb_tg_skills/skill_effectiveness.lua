local skillEffectivenessSkills = {}
local distance = math.sqrt(722) -- same as 19*sqrt(2)
for i=1,99 do
	if i ~= 50 then
		local angle = math.pi/4 + i/50*math.pi
		local xPos = math.sin(angle)*distance
		local yPos = math.cos(angle)*distance
		local skill = {
			ref = string.format("se%i", i),
			name = "skill_effectiveness",
			trait = "skillEffectiveness",
			amount = 1,
			links = {string.format("se%i", i-1)},
			pos = {xPos,yPos},
			parent = "physgun"
		}
		if i == 1 then
			skill.links[1] = "rcmb"
		elseif i == 49 then
			skill.links[2] = "atgig"
		elseif i == 51 then
			skill.links[1] = "atgig"
		elseif i == 99 then
			skill.links[2] = "rcmb"
		end
		table.insert(skillEffectivenessSkills, skill)
	end
end
table.insert(skillEffectivenessSkills, {
	ref = "se50",
	name = "skill_effectiveness",
	trait = "skillEffectiveness",
	amount = 1,
	links = {"se25", "mh13"},
	pos = {1,1},
	parent = "mh13"
})
table.insert(skillEffectivenessSkills, {
	ref = "se100",
	name = "skill_effectiveness",
	trait = "skillEffectiveness",
	amount = 1,
	links = {"se75", "hdtgpqa"},
	pos = {1,1},
	parent = "hdtgpqa"
})

return skillEffectivenessSkills