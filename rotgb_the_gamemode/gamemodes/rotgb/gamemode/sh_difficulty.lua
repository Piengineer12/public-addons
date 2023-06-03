GM.BaseDifficulties = {
	__common = {
		convars = {
			rotgb_regen_delay = true,
			rotgb_func_nav_expand = true,
			rotgb_max_to_exist = true,
			rotgb_ignore_damage_resistances = true,
			rotgb_damage_multiplier = true,
			rotgb_scale = true,
			rotgb_target_choice = true,
			rotgb_target_sort = true,
			rotgb_search_size = true,
			rotgb_target_tolerance = true,
			rotgb_cash_mul = true,
			rotgb_speed_mul = true,
			rotgb_health_multiplier = true,
			rotgb_blimp_health_multiplier = true,
			rotgb_pop_on_contact = true,
			rotgb_use_custom_pathfinding = true,
			rotgb_freeplay = true,
			rotgb_rainbow_gblimp_regen_rate = true,
			rotgb_afflicted_damage_multiplier = true,
			rotgb_tower_range_multiplier = true,
			rotgb_ignore_upgrade_limits = true,
			rotgb_fire_delay = true,
			rotgb_init_rate = true,
			rotgb_starting_cash = true,
			rotgb_tower_income_mul = true,
			rotgb_target_health_override = true,
			rotgb_default_first_wave = true,
			rotgb_tower_ignore_physgun = true,
			rotgb_spawner_force_auto_start = true,
			rotgb_spawner_no_multi_start = 1,
			rotgb_individualcash = 1,
			rotgb_tower_force_charge = true,
			rotgb_tower_charge_rate = true,
			rotgb_tower_maxcount = true,
			
			rotgb_difficulty = true,
			rotgb_default_wave_preset = true,
			rotgb_default_last_wave = true,
			rotgb_target_natural_health = true
		}
	},
	easy_regular = {
		category = "easy",
		place = 1,
		xpmul = 1,
		convars = {
			rotgb_difficulty = 0,
			rotgb_default_last_wave = 40,
			rotgb_target_natural_health = 200
		}
	},
	easy_chessonly = {
		category = "easy",
		place = 2,
		xpmul = 1.25,
		prerequisites = {"easy_regular"},
		convars = {
			rotgb_difficulty = 0,
			rotgb_default_last_wave = 40,
			rotgb_target_natural_health = 200,
			rotgb_tower_chess_only = 1
		}
	},
	easy_halfcash = {
		category = "easy",
		place = 3,
		xpmul = 3,
		prerequisites = {"easy_chessonly"},
		convars = {
			rotgb_difficulty = 0,
			rotgb_default_last_wave = 40,
			rotgb_target_natural_health = 200,
			rotgb_starting_cash = 325,
			rotgb_cash_mul = 0.5
		}
	},
	medium_regular = {
		category = "medium",
		place = 1,
		xpmul = 0.5,
		prerequisites = {"easy_regular"},
		convars = {
			rotgb_difficulty = 1,
			rotgb_default_last_wave = 60,
			rotgb_target_natural_health = 150
		}
	},
	medium_rainstorm = {
		category = "medium",
		place = 2,
		xpmul = 0.5*1.25,
		prerequisites = {"medium_regular"},
		convars = {
			rotgb_difficulty = 1,
			rotgb_default_last_wave = 60,
			rotgb_target_natural_health = 150,
			rotgb_spawner_force_auto_start = 1,
		}
	},
	medium_strategic = {
		category = "medium",
		place = 3,
		xpmul = 0.5*1.5,
		prerequisites = {"medium_rainstorm"},
		convars = {
			rotgb_difficulty = 1,
			rotgb_default_first_wave = 51,
			rotgb_default_last_wave = 60,
			rotgb_target_natural_health = 150,
			rotgb_starting_cash = 20000,
			rotgb_cash_mul = 0,
		}
	},
	hard_regular = {
		category = "hard",
		place = 1,
		xpmul = 0.25,
		prerequisites = {"medium_regular"},
		convars = {
			rotgb_difficulty = 2,
			rotgb_default_last_wave = 80,
			rotgb_target_natural_health = 100
		}
	},
	hard_doublehpblimps = {
		category = "hard",
		place = 2,
		xpmul = 0.25*1.25,
		prerequisites = {"hard_regular"},
		convars = {
			rotgb_difficulty = 2,
			rotgb_default_last_wave = 80,
			rotgb_target_natural_health = 100,
			rotgb_blimp_health_multiplier = 2
		}
	},
	hard_legacy = {
		category = "hard",
		place = 3,
		xpmul = 0.25*2^-5,
		prerequisites = {"hard_doublehpblimps"},
		convars = {
			rotgb_difficulty = 2,
			rotgb_default_last_wave = 120,
			rotgb_target_natural_health = 100,
			rotgb_default_wave_preset = "?LEGACY_10S",
			rotgb_spawner_force_auto_start = 1
		}
	},
	insane_regular = {
		category = "insane",
		place = 1,
		xpmul = 0.125,
		prerequisites = {"hard_regular"},
		convars = {
			rotgb_difficulty = 3,
			rotgb_default_last_wave = 100,
			rotgb_target_natural_health = 50
		}
	},
	insane_doublehp = {
		category = "insane",
		place = 2,
		xpmul = 0.125*1.25,
		prerequisites = {"insane_regular"},
		convars = {
			rotgb_difficulty = 3,
			rotgb_default_last_wave = 100,
			rotgb_target_natural_health = 50,
			rotgb_health_multiplier = 2
		}
	},
	insane_bosses = {
		category = "insane",
		place = 3,
		xpmul = 0.125*1.5,
		prerequisites = {"insane_doublehp"},
		convars = {
			rotgb_difficulty = 3,
			rotgb_default_last_wave = 100,
			rotgb_target_natural_health = 50,
			rotgb_default_wave_preset = "?BOSSES",
			rotgb_spawner_force_auto_start = 1
		}
	},
	impossible_regular = {
		category = "impossible",
		place = 1,
		xpmul = 0.0625,
		prerequisites = {"insane_regular"},
		convars = {
			rotgb_difficulty = 4,
			rotgb_default_last_wave = 120,
			rotgb_target_natural_health = 1
		}
	},
	impossible_speed = {
		category = "impossible",
		place = 2,
		xpmul = 0.0625*1.25,
		prerequisites = {"impossible_regular"},
		convars = {
			rotgb_difficulty = 4,
			rotgb_default_last_wave = 120,
			rotgb_target_natural_health = 1,
			rotgb_spawner_spawn_rate = 2,
			rotgb_speed_mul = 2
		}
	},
	impossible_monsoon = {
		category = "impossible",
		place = 3,
		xpmul = 0.0625*1.5,
		prerequisites = {"impossible_speed"},
		convars = {
			rotgb_difficulty = 4,
			rotgb_default_last_wave = 120,
			rotgb_target_natural_health = 1,
			rotgb_default_wave_preset = "?2S",
			rotgb_spawner_force_auto_start = 1
		}
	},
	icu_regular = {
		category = "icu",
		place = 1,
		extra = true,
		xpmul = 0.03125,
		condition = function()
			return hook.Run("GetSkillAmount", "icu_regular") > 0
		end,
		convars = {
			rotgb_difficulty = 5,
			rotgb_default_last_wave = 140,
			rotgb_target_natural_health = 1
		}
	},
	icu_carbonfiber = {
		category = "icu",
		place = 2,
		extra = true,
		xpmul = 0.03125*0.25*1.25,
		condition = function()
			return hook.Run("GetSkillAmount", "icu_carbonfiber") > 0
		end,
		convars = {
			rotgb_difficulty = 5,
			rotgb_default_last_wave = 140,
			rotgb_target_natural_health = 1,
			rotgb_default_wave_preset = "?CARBON_FIBER",
		}
	},
	icu_200xhpblimps = {
		category = "icu",
		place = 3,
		extra = true,
		xpmul = 0.03125*0.25*1.5,
		condition = function()
			return hook.Run("GetSkillAmount", "icu_200xhpblimps") > 0
		end,
		convars = {
			rotgb_difficulty = 5,
			rotgb_default_last_wave = 140,
			rotgb_target_natural_health = 1,
			rotgb_blimp_health_multiplier = 200
		}
	},
	icu_ramp = {
		category = "icu",
		place = 4,
		extra = true,
		xpmul = 0.03125*0.25*1.75,
		condition = function()
			return hook.Run("GetSkillAmount", "icu_ramp") > 0
		end,
		convars = {
			rotgb_difficulty = 5,
			rotgb_default_last_wave = 120,
			rotgb_target_natural_health = 1,
			rotgb_default_wave_preset = "?RAMP",
		}
	},
	icu_bosses = {
		category = "icu",
		place = 5,
		extra = true,
		xpmul = 0.03125*0.25*2,
		condition = function()
			return hook.Run("GetSkillAmount", "icu_bosses") > 0
		end,
		convars = {
			rotgb_difficulty = 5,
			rotgb_default_last_wave = 140,
			rotgb_target_natural_health = 1,
			rotgb_default_wave_preset = "?BOSSES_SUPER",
			rotgb_spawner_force_auto_start = 1
		}
	},
	special_nightmare = {
		category = "special",
		place = 1,
		extra = true,
		xpmul = 0.5/256,
		prerequisites = {"special_nightmare"},
		convars = {
			rotgb_difficulty = 1,
			rotgb_default_first_wave = 666,
			rotgb_default_last_wave = 666,
			rotgb_cash_mul = 13,
			rotgb_starting_cash = 8450,
			rotgb_target_natural_health = 150
		}
	}
}

GM.BaseDifficultyCategories = {easy = 1, medium = 2, hard = 3, insane = 4, impossible = 5, icu = 6, special = 7}

AccessorFunc(GM, "Difficulties", "Difficulties")
AccessorFunc(GM, "Difficulty", "Difficulty", FORCE_STRING)
AccessorFunc(GM, "DifficultyCategories", "DifficultyCategories")
AccessorFunc(GM, "DifficultyCategoriesCustom", "DifficultyCategoriesCustom")
AccessorFunc(GM, "CustomRemovedDifficulties", "CustomRemovedDifficulties")

function GM:InitializeDifficulties()
	if not hook.Run("GetDifficulty") then
		hook.Run("SetDifficulty", "")
	end
	
	local difficulties = table.Copy(self.BaseDifficulties)
	hook.Run("GatherCustomDifficulties", difficulties)
	hook.Run("SetDifficulties", difficulties)
	
	local categories = table.Copy(self.BaseDifficultyCategories)
	hook.Run("GatherCustomDifficultyCategories", categories)
	hook.Run("SetDifficultyCategories", categories)
	
	if not hook.Run("GetDifficultyCategoriesCustom") then
		hook.Run("SetDifficultyCategoriesCustom", {})
	end
	if not hook.Run("GetCustomRemovedDifficulties") then
		hook.Run("SetCustomRemovedDifficulties", {})
	end
end

function GM:AddMapAddedDifficulty(difficultyID, difficultyPlace, difficultyData)
	if not hook.Run("GetDifficulties") then
		hook.Run("InitializeDifficulties")
	end
	
	local difficulties = hook.Run("GetDifficulties")
	difficulties[difficultyID] = difficultyData
	
	if difficultyPlace then
		local category = difficultyData.category
		
		hook.Run("GetDifficultyCategories")[category] = difficultyPlace
		hook.Run("GetDifficultyCategoriesCustom")[category] = difficultyPlace
	end
end

function GM:RemoveDifficulties(difficultyIDsString)
	if not hook.Run("GetDifficulties") then
		hook.Run("InitializeDifficulties")
	end
	local difficulties = hook.Run("GetDifficulties")
	local customRemovedDifficulties = hook.Run("GetCustomRemovedDifficulties")
	
	if difficultyIDsString == "*" then
		for k,v in pairs(difficulties) do
			if not v.custom and k ~= "__common" then
				difficulties[k] = nil
			end
		end
		table.insert(customRemovedDifficulties, "*")
	else
		for k,v in pairs(string.Explode(",", difficultyIDsString)) do
			local id = v:Trim()
			
			if (difficulties[id] and not difficulties[id].custom and id ~= "__common") then
				difficulties[id] = nil
				table.insert(customRemovedDifficulties, id)
			end
		end
	end
end

function GM:IsDifficultyUnlocked(difficultyID)
	if not hook.Run("GetDifficulties") then
		hook.Run("InitializeDifficulties")
	end
	
	local difficulty = hook.Run("GetDifficulties")[difficultyID]
	if difficulty then 
		return not difficulty.condition or difficulty:condition()
	end
	return false
end