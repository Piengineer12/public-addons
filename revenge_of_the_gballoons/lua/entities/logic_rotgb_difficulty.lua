ENT.Type = "point"
ENT.PrintName = "RotgB Difficulty Logic"
ENT.Author = "Piengineer12"
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose = "Can be used to add custom difficulties and remove existing ones."
ENT.Instructions = "Set this entity's key values to something."
ENT.BaseDifficulties = {
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
		place = 1,
		convars = {
			rotgb_difficulty = 0,
			rotgb_default_last_wave = 40,
			rotgb_target_natural_health = 200
		}
	},
	easy_chessonly = {
		place = 2,
		convars = {
			rotgb_difficulty = 0,
			rotgb_default_last_wave = 40,
			rotgb_target_natural_health = 200,
			rotgb_tower_chess_only = 1
		}
	},
	easy_halfcash = {
		place = 3,
		convars = {
			rotgb_difficulty = 0,
			rotgb_default_last_wave = 40,
			rotgb_target_natural_health = 200,
			rotgb_starting_cash = 325,
			rotgb_cash_mul = 0.5
		}
	},
	medium_regular = {
		place = 4,
		convars = {
			rotgb_difficulty = 1,
			rotgb_default_last_wave = 60,
			rotgb_target_natural_health = 150
		}
	},
	medium_rainstorm = {
		place = 5,
		convars = {
			rotgb_difficulty = 1,
			rotgb_default_last_wave = 60,
			rotgb_target_natural_health = 150,
			rotgb_spawner_force_auto_start = 1,
		}
	},
	medium_strategic = {
		place = 6,
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
		place = 7,
		convars = {
			rotgb_difficulty = 2,
			rotgb_default_last_wave = 80,
			rotgb_target_natural_health = 100
		}
	},
	hard_doublehpblimps = {
		place = 8,
		convars = {
			rotgb_difficulty = 2,
			rotgb_default_last_wave = 80,
			rotgb_target_natural_health = 100,
			rotgb_blimp_health_multiplier = 2
		}
	},
	hard_legacy = {
		place = 9,
		convars = {
			rotgb_difficulty = 2,
			rotgb_default_last_wave = 120,
			rotgb_target_natural_health = 100,
			rotgb_default_wave_preset = "?LEGACY_10S",
			rotgb_spawner_force_auto_start = 1
		}
	},
	insane_regular = {
		place = 10,
		convars = {
			rotgb_difficulty = 3,
			rotgb_default_last_wave = 100,
			rotgb_target_natural_health = 50
		}
	},
	insane_doublehp = {
		place = 11,
		convars = {
			rotgb_difficulty = 3,
			rotgb_default_last_wave = 100,
			rotgb_target_natural_health = 50,
			rotgb_health_multiplier = 2
		}
	},
	insane_bosses = {
		place = 12,
		convars = {
			rotgb_difficulty = 3,
			rotgb_default_last_wave = 100,
			rotgb_target_natural_health = 50,
			rotgb_default_wave_preset = "?BOSSES",
			rotgb_spawner_force_auto_start = 1
		}
	},
	impossible_regular = {
		place = 13,
		convars = {
			rotgb_difficulty = 4,
			rotgb_default_last_wave = 120,
			rotgb_target_natural_health = 1
		}
	},
	impossible_speed = {
		place = 14,
		convars = {
			rotgb_difficulty = 4,
			rotgb_default_last_wave = 120,
			rotgb_target_natural_health = 1,
			rotgb_spawner_spawn_rate = 2,
			rotgb_speed_mul = 2
		}
	},
	impossible_monsoon = {
		place = 15,
		convars = {
			rotgb_difficulty = 4,
			rotgb_default_last_wave = 120,
			rotgb_target_natural_health = 1,
			rotgb_default_wave_preset = "?2S",
			rotgb_spawner_force_auto_start = 1
		}
	}
}

function ENT:KeyValue(key,value)
	local lkey = key:lower()
	if lkey=="difficulty_remove" then
		self.DifficultyRemove = value
	elseif lkey=="difficulty_id" then
		self.DifficultyID = value
	elseif lkey=="difficulty_category" then
		self.DifficultyCategory = value
	elseif lkey=="difficulty_category_place" then
		self.DifficultyCategoryPlace = tonumber(value) or -1
	elseif lkey=="difficulty_place" then
		self.DifficultyPlace = tonumber(value) or 0
	elseif value ~= "" then
		if string.match(lkey, "^convar_%d+_name$") then
			local num = tonumber(string.match(lkey, "^convar_(%d+)_name$"))
			if num then
				self:SetConVarName(num, value)
				if num == 0 then
					ROTGB_LogError("DEPRECATION WARNING: The convar_0_name KeyValue is now deprecated. Please use convar_1_name and above instead.", "")
					debug.Trace()
				end
			end
		elseif string.match(lkey, "^convar_%d+_value$") then
			local num = tonumber(string.match(lkey, "^convar_(%d+)_value$"))
			if num then
				self:SetConVarValue(num, value)
				if num == 0 then
					ROTGB_LogError("DEPRECATION WARNING: The convar_0_value KeyValue is now deprecated. Please use convar_1_value and above instead.", "")
					debug.Trace()
				end
			end
		end
	end
end

function ENT:SetConVarName(num, value)
	self.ConVars = self.ConVars or {}
	self.ConVars[num] = self.ConVars[num] or {}
	self.ConVars[num].name = value
	self.RequiresResync = true
end

function ENT:SetConVarValue(num, value)
	self.ConVars = self.ConVars or {}
	self.ConVars[num] = self.ConVars[num] or {}
	self.ConVars[num].value = value
	self.RequiresResync = true
end

function ENT:Initialize()
	hook.Run("RemoveDifficulties", self.DifficultyRemove or "")
	
	if (self.DifficultyID or "") ~= "" then
		--assemble properly
		local difficulty = {
			category = self.DifficultyCategory or "other",
			place = self.DifficultyPlace or 0,
			custom = true,
			convars = {}
		}
		
		for k,v in pairs(self.ConVars) do
			if v.name ~= "" then
				difficulty.convars[v.name] = v.value or ""
			end
		end
		
		hook.Run("AddMapAddedDifficulty", self.DifficultyID, self.DifficultyCategoryPlace, difficulty)
	end
end

--[[
steps:
1. Entity sends difficulty info
2. Server saves difficulty info
3. Client connects to server
4. Server sends over removed difficulties
5. Server sends custom difficulty data
6. Client gets data
]]