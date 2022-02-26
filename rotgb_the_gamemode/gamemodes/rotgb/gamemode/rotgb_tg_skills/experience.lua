local experienceSkills = {}
local distance = 26

local function GetSXPName(branch, index)
	return string.format("sxp%u", branch*26+index)
end

for i=0,3 do
	table.insert(experienceSkills, {
		{
			ref = GetSXPName(i, 1),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = "physgun",
			links = {string.format("se%u", i*25+12), string.format("se%u", i*25+13)},
			pos = {distance,0},
			ang = i*90
		},
		{
			ref = GetSXPName(i, 2),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 1),
			links = "parent",
			pos = {-1, 1}
		},
		{
			ref = GetSXPName(i, 3),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 2),
			links = "parent",
			pos = {-1, 1}
		},
		{
			ref = GetSXPName(i, 4),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 3),
			links = "parent",
			pos = {-1, 1}
		},
		{
			ref = GetSXPName(i, 5),
			name = "greater_insight",
			trait = "skillExperience",
			amount = 20,
			tier = 1,
			parent = GetSXPName(i, 4),
			links = "parent",
			pos = {-1, 1}
		},
		{
			ref = GetSXPName(i, 6),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 5),
			links = "parent",
			pos = {-1, -1}
		},
		{
			ref = GetSXPName(i, 7),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 6),
			links = "parent",
			pos = {-1, -1}
		},
		{
			ref = GetSXPName(i, 8),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 7),
			links = "parent",
			pos = {-1, -1}
		},
		{
			ref = GetSXPName(i, 9),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 1),
			links = "parent",
			pos = {-1, -1}
		},
		{
			ref = GetSXPName(i, 10),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 9),
			links = "parent",
			pos = {-1, -1}
		},
		{
			ref = GetSXPName(i, 11),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 10),
			links = "parent",
			pos = {-1, -1}
		},
		{
			ref = GetSXPName(i, 12),
			name = "greater_insight",
			trait = "skillExperience",
			amount = 20,
			tier = 1,
			parent = GetSXPName(i, 11),
			links = "parent",
			pos = {-1, -1}
		},
		{
			ref = GetSXPName(i, 13),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 12),
			links = "parent",
			pos = {-1, 1}
		},
		{
			ref = GetSXPName(i, 14),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 13),
			links = "parent",
			pos = {-1, 1}
		},
		{
			ref = GetSXPName(i, 15),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 14),
			links = "parent",
			pos = {-1, 1}
		},
		{
			ref = GetSXPName(i, 16),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 15),
			links = {GetSXPName(i, 8), GetSXPName(i, 15)},
			pos = {-1, 1}
		},
		{
			ref = GetSXPName(i, 17),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 16),
			links = "parent",
			pos = {1, 0}
		},
		{
			ref = GetSXPName(i, 18),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 17),
			links = "parent",
			pos = {1, 0}
		},
		{
			ref = GetSXPName(i, 19),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 18),
			links = "parent",
			pos = {1, 1}
		},
		{
			ref = GetSXPName(i, 20),
			name = "greater_insight",
			trait = "skillExperience",
			amount = 20,
			tier = 1,
			parent = GetSXPName(i, 19),
			links = "parent",
			pos = {1, 1}
		},
		{
			ref = GetSXPName(i, 21),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 20),
			links = "parent",
			pos = {1, -1}
		},
		{
			ref = GetSXPName(i, 22),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 18),
			links = "parent",
			pos = {1, -1}
		},
		{
			ref = GetSXPName(i, 23),
			name = "greater_insight",
			trait = "skillExperience",
			amount = 20,
			tier = 1,
			parent = GetSXPName(i, 22),
			links = "parent",
			pos = {1, -1}
		},
		{
			ref = GetSXPName(i, 24),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 23),
			links = "parent",
			pos = {1, 1}
		},
		{
			ref = GetSXPName(i, 25),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 24),
			links = {GetSXPName(i, 21), GetSXPName(i, 24)},
			pos = {1, 1}
		},
		{
			ref = GetSXPName(i, 26),
			name = "insight",
			trait = "skillExperience",
			amount = 2,
			parent = GetSXPName(i, 25),
			links = "parent",
			pos = {-1, 0}
		}
	})
end

table.insert(experienceSkills, {
	{
		ref = "curseOfTheHand",
		name = "curse_of_the_hand",
		trait = {"towerFiveOnly", "skillExperiencePerWave"},
		amount = {1, 2},
		tier = 2,
		parent = GetSXPName(0, 26),
		links = "parent",
		pos = {-1, 0}
	},
	{
		ref = "curseOfTheMind",
		name = "curse_of_the_mind",
		trait = {"towerHalfIncome", "skillExperiencePerWave"},
		amount = {1, 2},
		tier = 2,
		parent = GetSXPName(1, 26),
		links = "parent",
		pos = {-1, 0}
	},
	{
		ref = "curseOfTheBody",
		name = "curse_of_the_body",
		trait = {"gBalloonDoubleHealth", "skillExperienceEffectiveness", "skillExperiencePerWaveEffectiveness"},
		amount = {1, 100, 100},
		tier = 2,
		parent = GetSXPName(2, 26),
		links = "parent",
		pos = {-1, 0}
	},
	{
		ref = "curseOfTheFoot",
		name = "curse_of_the_foot",
		trait = {"gBalloonDoubleSpeed", "skillExperienceEffectiveness", "skillExperiencePerWaveEffectiveness"},
		amount = {1, 100, 100},
		tier = 2,
		parent = GetSXPName(3, 26),
		links = "parent",
		pos = {-1, 0}
	}
})

return experienceSkills