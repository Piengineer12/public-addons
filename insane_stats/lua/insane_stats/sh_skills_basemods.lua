local skills = {
	quintessence = {
		name = "Quintessence",
		desc = "%+.0f%% damage dealt\n%+.0f%% damage taken\n%+.0f%% movement speed\n%+.0f%% XP gain",
		values = function(level)
			return level * 2, -level * 2, level * 2, level * 2
		end,
		img = "juggler",
		pos = {0, 0}
	},

	-- distance 1
	damage = {
		name = "Strength",
		desc = "%+.0f%% damage dealt",
		values = function(level)
			return level * 5
		end,
		img = "pointy-sword",
		pos = {0, -1},
		minpts = 5
	},
	xp = {
		name = "Eat the Rich",
		desc = "%+.0f%% coins and XP gain",
		values = function(level)
			return level * 5
		end,
		img = "cool-spices",
		pos = {1, 0},
		minpts = 5
	},
	speed = {
		name = "Swiftness",
		desc = "%+.0f%% movement speed",
		values = function(level)
			return level * 5
		end,
		img = "sprint",
		pos = {0, 1},
		minpts = 5
	},
	defence = {
		name = "Resistance",
		desc = "%+.0f%% damage taken",
		values = function(level)
			return level * -5
		end,
		img = "checked-shield",
		pos = {-1, 0},
		minpts = 5
	},

	-- distance 2
	rip_and_tear = {
		name = "Rip and Tear",
		desc = "On kill, gain %+.0f%% damage dealt for 10 seconds.",
		values = function(level)
			return level * 10
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = math.max(current - time, 0)
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "triple-skulls",
		pos = {0, -2},
		minpts = 5
	},
	back_to_back = {
		name = "Back to Back",
		desc = "On kill, gain %+.0f%% more coins and XP for 10 seconds.",
		values = function(level)
			return level * 10
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = math.max(current - time, 0)
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "laser-sparks",
		pos = {1, -1},
		minpts = 5
	},
	guilt = {
		name = "Guilt",
		desc = "Gain %+.0f%% more coins and XP, but ally kills cause XP to be lost.",
		values = function(level)
			return level * 10
		end,
		img = "despair",
		pos = {2, 0},
		minpts = 5
	},
	risk_reward = {
		name = "Risk... Reward...",
		desc = "Gain more coins and XP on low health, up to %+.0f%%.",
		values = function(level)
			return level * 20
		end,
		img = "evil-book",
		pos = {1, 1},
		minpts = 5
	},
	zoomer = {
		name = "Zoomer",
		desc = "%+.0f%% movement speed while sprinting",
		values = function(level)
			return level * 10
		end,
		img = "wingfoot",
		pos = {0, 2},
		minpts = 5
	},
	dodger = {
		name = "Dodger",
		desc = "Gain +%u stack(s) of Dodger per second, up to 10. \z
		At 10 stacks, the next non-disintegrating damage taken is dodged instead, consuming all stacks.",
		values = function(level)
			return level
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = math.min(current + time * ent:InsaneStats_GetEffectiveSkillValues("dodger"), 10)
			return nextStacks >= 10 and 1 or 0, nextStacks
		end,
		img = "journey",
		pos = {-1, 1},
		minpts = 5
	},
	love_and_tolerate = {
		name = "Love And Tolerate",
		desc = "Whenever damage would be taken from a mob, gain %+.1f stack(s) of Love And Tolerate. \z
		Each stack gives 1%% more defence, but stacks decay at a rate of -0.1%%/s. \z
		The Hellish Challenge skill is also +%u%% more effective. ",
		values = function(level)
			return level/5, level * 20
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = current * .999 ^ time
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "arrows-shield",
		pos = {-2, 0},
		minpts = 5
	},
	embolden = {
		name = "Embolden",
		desc = "On kill, reduce all damage taken by %.0f%% for 10 seconds.",
		values = function(level)
			return level * -8
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = math.max(current - time, 0)
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "skull-shield",
		pos = {-1, -1},
		minpts = 5
	},

	-- distance 3
	the_sniper = {
		name = "The Sniper",
		desc = "Critical hits and hits against props deal %+.0f%% more damage.",
		values = function(level)
			return level * 10
		end,
		img = "fast-arrow",
		pos = {1, -2},
		minpts = 5
	},
	skill_sealer = {
		name = "Skill Sealer",
		desc = "Enables skill sealing in the skill menu. \z
		Sealed skills will have all their effects replaced with %+.1f%% coins and XP gain per level. \z
		This skill cannot be sealed, and all seals are removed when skills are reset.",
		values = function(level)
			return level/2
		end,
		img = "cycle",
		pos = {2, -1},
		minpts = 5
	},
	target_practice = {
		name = "Target Practice",
		desc = "Destroying props grant XP, equivalent to %+.0f%% of an enemy.\n\z
		Props also yield %+.0f%% more coins.",
		values = function(level)
			return level * 5, level * 10
		end,
		img = "scarecrow",
		pos = {2, 1},
		minpts = 5
	},
	hunting_spirit = {
		name = "Hunting Spirit",
		desc = "On kill, gain %+.0f%% movement speed for 10 seconds.",
		values = function(level)
			return level * 10
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = math.max(current - time, 0)
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "chained-arrow-heads",
		pos = {1, 2},
		minpts = 5
	},
	skip_the_scenery = {
		name = "Skip the Scenery",
		desc = "%+.0f%% movement speed outside of combat",
		values = function(level)
			return level * 10
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = math.max(current - time, 0)
			return nextStacks <= 0 and 1 or -1, nextStacks
		end,
		img = "cowled",
		pos = {-1, 2},
		minpts = 5
	},
	regeneration = {
		name = "Regeneration",
		desc = "%+.1f%%/s health regeneration",
		values = function(level)
			return level/5
		end,
		img = "heart-bottle",
		pos = {-2, 1},
		minpts = 5
	},
	iron_skin = {
		name = "Iron Skin",
		desc = "%+.0f%% non-bullet damage taken",
		values = function(level)
			return level * -8
		end,
		img = "metal-scales",
		pos = {-2, -1},
		minpts = 5
	},
	pew_pew_pew = {
		name = "Pew Pew Pew",
		desc = "Most weapons fire %+.0f%% faster.",
		values = function(level)
			return level * 5
		end,
		img = "striking-arrows",
		pos = {-1, -2},
		minpts = 5
	},

	-- distance 4
	rage = {
		name = "Rage",
		desc = "Deal more damage on low health, up to %+.0f%%.",
		values = function(level)
			return level * 20
		end,
		img = "wolf-head",
		pos = {1, -3},
		minpts = 5
	},
	be_efficient = {
		name = "Be Efficient",
		desc = "Critical hits yield %+.0f%% more coins and XP on kill.",
		values = function(level)
			return level * 10
		end,
		img = "william-tell-skull",
		pos = {2, -2},
		minpts = 5
	},
	looting = {
		name = "Looting",
		desc = "On kill, there is a %+.0f%% chance for a random item to be spawned.",
		values = function(level)
			return level * 5
		end,
		img = "cogsplosion",
		pos = {3, -1},
		minpts = 5
	},
	fortune = {
		name = "Fortune",
		desc = "%+.0f%% chance for a random item when a prop is broken",
		values = function(level)
			return level * 5
		end,
		img = "diamond-hard",
		pos = {3, 1},
		minpts = 5
	},
	why_is_it_called_kiting = {
		name = "Why is it Called Kiting?",
		desc = "Damage dealt is increased based on speed. At normal running speed, damage dealt is increased by %+.0f%%.",
		values = function(level)
			return level * 10
		end,
		img = "strafe",
		pos = {2, 2},
		minpts = 5
	},
	glass = {
		name = "Glass",
		desc = "%+i%% damage dealt\n%+i%% damage taken\n%+i%% coins and XP gain",
		values = function(level)
			return level * 5, level * 5, level * 5
		end,
		img = "martini",
		pos = {1, 3},
		minpts = 5
	},
	jumper = {
		name = "Jumper",
		desc = "+%u mid-air jumps",
		values = function(level)
			return level
		end,
		img = "fluffy-trefoil",
		pos = {-1, 3},
		minpts = 5
	},
	living_on_the_edge = {
		name = "Living on the Edge",
		desc = "Take less damage on low health, up to %+.0f%%.",
		values = function(level)
			return level * -10
		end,
		img = "life-in-the-balance",
		pos = {-2, 2},
		minpts = 5
	},
	you_are_all_bleeders = {
		name = "You Are All Bleeders",
		desc = "Take less damage from low health entities, down to %i%%.",
		values = function(level)
			return level * -8
		end,
		img = "cut-palm",
		pos = {-3, 1},
		minpts = 5
	},
	watch_your_head = {
		name = "Watch Your Head",
		desc = "%+i%% critical damage taken",
		values = function(level)
			return level*-8
		end,
		img = "rear-aura",
		pos = {-3, -1},
		minpts = 5
	},
	kablooey = {
		name = "Kablooey!",
		desc = "%+.0f%% explosive damage dealt. Explosive hits towards enemies have a +%u%% chance of spawning a random item.",
		values = function(level)
			return level * 10, level * 2
		end,
		img = "explosion-rays",
		pos = {-2, -2},
		minpts = 5
	},
	a_little_less_gun = {
		name = "A Little Less Gun",
		desc = "%+.0f%% non-bullet damage dealt",
		values = function(level)
			return level * 10
		end,
		img = "plain-dagger",
		pos = {-1, -3},
		minpts = 5
	},

	-- distance 5
	brilliant_behemoth = {
		name = "Michael Bay Simulator",
		desc = "While %s is not held, all hits against entities cause explosions with %s radii! Note that these explosions hurt ALL entities in range.",
		values = function(level)
			local slowWalkKey = "the Slow Walk key"
			local distance = level * 128
			if CLIENT then
				local keyName = input.LookupBinding("+walk")
				if keyName then
					slowWalkKey = keyName:upper()
				end
				distance = InsaneStats:FormatNumber(distance, {plus = true, distance = true})
			end
			return slowWalkKey, distance
		end,
		stackTick = function(state, current, time, ent)
			return ent:IsPlayer() and ent:KeyDown(IN_WALK) and -1 or 1, current
		end,
		img = "explosive-materials",
		pos = {0, -3},
		minpts = 10,
		max = 1
	},
	youre_approaching_me = {
		name = "You're Approaching Me?",
		desc = "%+.0f%% damage dealt against entities within %s",
		values = function(level)
			local distance = 512
			if CLIENT then
				distance = InsaneStats:FormatNumber(distance, {distance = true})
			end
			return level * 10, distance
		end,
		img = "boxing-glove",
		pos = {2, -3},
		minpts = 5
	},
	reuse = {
		name = "Reuse",
		desc = "%+.0f%% ammo consumption",
		values = function(level)
			return level * -8
		end,
		img = "crystal-bars",
		pos = {3, -2},
		minpts = 5
	},
	friendly_fire_off = {
		name = "Friendly Fire OFF",
		desc = "While %s is not held, deal -100%% non-dissolving damage against non-player allies! \z
		Also, double tapping %s will cause all squad citizens and rebels that are over %s away to be teleported closer.%s",
		values = function(level)
			local slowWalkKey = "the Slow Walk key"
			local distance = 1024 / level
			if CLIENT then
				local keyName = input.LookupBinding("+walk")
				if keyName then
					slowWalkKey = keyName:upper()
				end
				distance = InsaneStats:FormatNumber(distance, {distance = true})
			end
			if level > 1 then
				return slowWalkKey, slowWalkKey, distance,
				" Additionally, gain +100% damage dealt for 10 seconds whenever an enemy hurts any allies!"
			else
				return slowWalkKey, slowWalkKey, distance, ""
			end
		end,
		stackTick = function(state, current, time, ent)
			local newStacks = math.max(current - time, 0)
			return ent:IsPlayer() and ent:KeyDown(IN_WALK) and 0 or 1, newStacks
		end,
		img = "duality",
		pos = {3, 0},
		minpts = 10,
		max = 1
	},
	consolation_prize = {
		name = "Consolation Prize",
		desc = "%+.0f%% XP gain from kills by other entities",
		values = function(level)
			return level * 10
		end,
		img = "gift-of-knowledge",
		pos = {3, 2},
		minpts = 5
	},
	super_cold = game.SinglePlayer() and {
		name = "Super Cold",
		desc = "While not in a vehicle, game speed is reduced based on speed. At normal running speed, time takes %+.0f%% longer to pass.\n\z
		(This skill is completely different in multiplayer.)",
		values = function(level)
			return level * 10
		end,
		img = "ice-cube",
		pos = {2, 3},
		minpts = 5
	} or {
		name = "Stick With The Team!",
		desc = "For each ally within %s, gain +%u%% coins, XP gain and damage dealt, \z
		as well as %i%% damage taken.\n\z
		(This skill is completely different in singleplayer.)",
		values = function(level)
			local distance = 512
			if CLIENT then
				distance = InsaneStats:FormatNumber(distance, {distance = true})
			end
			return distance, level * 3, level * -3
		end,
		img = "telepathy",
		pos = {2, 3},
		minpts = 5
	},
	sneak_100 = {
		name = "Sneak 100",
		desc = "Double tap %s to become invisible for 10 seconds! %u seconds cooldown.",
		values = function(level)
			local slowWalkKey = "the Slow Walk key"
			if CLIENT then
				local keyName = input.LookupBinding("+walk")
				if keyName then
					slowWalkKey = keyName:upper()
				end
			end
			return slowWalkKey, 180 - level * 60
		end,
		stackTick = function(state, stacks, time, ent)
			if state == 1 then
				stacks = stacks - time
				if stacks < 0 then
					state = -1
					stacks = stacks + ent:InsaneStats_GetEffectiveSkillValues("sneak_100", 2)
					time = 0
				end
			end
			if state < 0 then
				stacks = stacks - time
				if stacks <= 0 then
					stacks = 0
					state = 0
				end
			end

			return state, stacks
		end,
		img = "domino-mask",
		pos = {0, 3},
		minpts = 10,
		max = 1
	},
	map_sense = {
		name = "Map Sense",
		desc = "See all buttons, doors and breakable brushes within %s!",
		values = function(level)
			local distance = level * 128
			if CLIENT then
				distance = InsaneStats:FormatNumber(distance, {plus = true, distance = true})
			end
			return distance, level * 128
		end,
		img = "world",
		pos = {-2, 3},
		minpts = 5
	},
	pulsing_armor = {
		name = "Pulsing Armor",
		desc = "%+.0f%% damage taken",
		values = function(level)
			return math.Remap(math.sin(CurTime()), -1, 1, 50 + level * -5, -50 + level * -5)
		end,
		no_cache_values = true,
		img = "bell-shield",
		pos = {-3, 2},
		minpts = 5
	},
	ubercharge = {
		name = "Übercharge!",
		desc = "Taking damage grants invincibility for 10 seconds! %u seconds cooldown.",
		values = function(level)
			return 180 - level * 60
		end,
		stackTick = function(state, stacks, time, ent)
			if state == 1 then
				stacks = stacks - time
				if stacks < 0 then
					state = -1
					stacks = stacks + ent:InsaneStats_GetEffectiveSkillValues("ubercharge")
					time = 0
				end
			end
			if state < 0 then
				stacks = stacks - time
				if stacks <= 0 then
					stacks = 0
					state = 0
				end
			end

			return state, stacks
		end,
		img = "mesh-ball",
		pos = {-3, 0},
		minpts = 10,
		max = 1
	},
	overheal = {
		name = "Overheal",
		desc = "On kill, restore %+i%% of max health. Health gained this way can exceed max health, \z
		but with diminishing returns. Also, max health gains from skills and modifiers are increased by +%u%%.",
		values = function(level)
			return level, level * 5
		end,
		img = "shining-heart",
		pos = {-3, -2},
		minpts = 5
	},
	you_cant_run = {
		name = "You Can't Run",
		desc = "%+.0f%% damage dealt against entities further than %s",
		values = function(level)
			local distance = 512
			if CLIENT then
				distance = InsaneStats:FormatNumber(distance, {distance = true})
			end
			return level * 10, distance
		end,
		img = "arrow-dunk",
		pos = {-2, -3},
		minpts = 5
	},

	-- distance 6
	ebb_and_flow = {
		name = "Ebb And Flow",
		desc = "%+.0f%% damage dealt",
		values = function(level)
			return math.Remap(math.sin(CurTime()), -1, 1, 50 + level * 5, -50 + level * 5)
		end,
		no_cache_values = true,
		img = "wave-strike",
		pos = {2, -4},
		minpts = 5
	},
	mania = {
		name = "Mania",
		desc = "On kill, gain %+.1f stack(s) of Mania. Each stack gives 1%% more coins and XP, \z
		but stacks decay at a rate of -0.1%%/s.",
		values = function(level)
			return level/5
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = current * .999 ^ time
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "hot-spices",
		pos = {3, -3},
		minpts = 5
	},
	infusion = {
		name = "Infusion",
		desc = "On kill, gain +%s max health.",
		values = function(level, ent)
			local scaleType = ent:IsPlayer() and "player" or "other"
			local effectiveLevel = InsaneStats:GetConVarValue("xp_enabled") and ent:InsaneStats_GetLevel() or 1
			local val = InsaneStats:ScaleValueToLevel(
				level/50,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_health")/100,
				effectiveLevel,
				"xp_"..scaleType.."_health_mode"
			)
			return CLIENT and InsaneStats:FormatNumber(val), val
		end,
		img = "glass-heart",
		pos = {4, -2},
		minpts = 5
	},
	additional_pylons = {
		name = "Additional Pylons",
		desc = "On kill, gain +%s max armor.",
		values = function(level, ent)
			local scaleType = ent:IsPlayer() and "player" or "other"
			local baseMult = ent:IsPlayer() and 1 or InsaneStats:GetConVarValue("infhealth_armor_mul")
			local effectiveLevel = InsaneStats:GetConVarValue("xp_enabled") and ent:InsaneStats_GetLevel() or 1
			local val = InsaneStats:ScaleValueToLevel(
				level/50*baseMult,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_armor")/100,
				effectiveLevel,
				"xp_"..scaleType.."_armor_mode"
			)
			return CLIENT and InsaneStats:FormatNumber(val), val
		end,
		img = "bordered-shield",
		pos = {4, 2},
		minpts = 5
	},
	jazz_feet = {
		name = "Jazz Feet",
		desc = "Gain more coins and XP based on speed. At normal running speed, coins and XP gain is increased by %+.0f%%.",
		values = function(level)
			return level * 10
		end,
		img = "swan-breeze",
		pos = {3, 3},
		minpts = 5
	},
	bloodletter_pact = {
		name = "Bloodletter's Pact",
		desc = "Health above %.1f%% is converted into shield. \z
		Shield gained this way can exceed max shield, but with diminishing returns. \z
		Also, the softcap and hardcap effects of overhealing are reduced by %.1f%%.",
		values = function(level, ent)
			-- min level above 0: 0.2, max level: 30
			level = level * (1 + ent:InsaneStats_GetEffectiveSkillValues("bloodletters_revelation", 2) / 100)
			return 100 - level * 2, -4 * level
		end,
		img = "bleeding-heart",
		pos = {2, 4},
		minpts = 5
	},
	aux_aux_battery = {
		name = "Aux Aux Battery",
		desc = "While Aux Power is disabled or at 100%% Aux Power, gain %+.0f%% more XP. \z
		Aux Power has a %+.0f%% chance of not being consumed.",
		values = function(level)
			return level * 5, level * 10
		end,
		img = "batteries",
		pos = {-2, 4},
		minpts = 5
	},
	four_parallel_universes_ahead = {
		name = "Four Parallel Universes Ahead",
		desc = "Defence is increased based on speed. At normal running speed, defence is increased by %i%%. \z
		Hitbox size is also decreased by %i%%.",
		values = function(level)
			return level * 10, level * -1
		end,
		img = "dodging",
		pos = {-3, 3},
		minpts = 5
	},
	absorption_shield = {
		name = "Absorption Shield",
		desc = "%+.0f%% non-dissolving damage absorption chance while shielded. \z
		Absorbed damage is converted into random ammunition.",
		values = function(level)
			return level * 5
		end,
		img = "rosa-shield",
		pos = {-4, 2},
		minpts = 5
	},
	overshield = {
		name = "Overshield",
		desc = "On kill, restore %+.0f%% of max shield. Shield gained this way can exceed max shield, \z
		but with diminishing returns. Also, max shield gains from skills and modifiers are increased by +%u%%.",
		values = function(level)
			return level, level * 5
		end,
		img = "energise",
		pos = {-4, -2},
		minpts = 5
	},
	more_bullet_per_bullet = {
		name = "More Bullet Per Bullet",
		desc = "Reserve ammo above %u%% is converted into More Bullet Per Bullet stacks. \z
		Each stack increases defence and damage dealt by 1%%, but stacks decay at a rate of -0.1%%/s. \z
		Additionally, interacting with an Ammo Crate causes all stacks to be removed.",
		values = function(level)
			return 100 - level * 5
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = current * .999 ^ time
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "implosion",
		pos = {-3, -3},
		minpts = 5
	},
	one_with_the_gun = {
		name = "One With The G.U.N.",
		desc = "Pistols and revolvers deal +%u%% damage, have %i%% bullet spread \z
		and fire +%u%% more bullets. Additionally, holding down %s with these weapons held \z
		will cause the FOV to shrink to %u.",
		values = function(level, ent)
			local zoomKey = "the Secondary Fire key"
			if CLIENT then
				local keyName = input.LookupBinding("+attack2")
				if keyName then
					zoomKey = keyName:upper()
				end
			end
			return level * 10, level * -10, level * 10,
			zoomKey, 75 - level * 5
		end,
		img = "crossed-pistols",
		pos = {-2, -4},
		minpts = 5
	},

	-- distance 7
	the_red_plague = {
		name = "The Red Plague",
		desc = "On hit, inflict Bleeding for %u seconds on the victim, triggering on-hit effects over time! \z
		Bleeding does not stack.",
		values = function(level)
			return level * 8
		end,
		img = "droplets",
		pos = {1, -4},
		minpts = 10,
		max = 1
	},
	silver_bullets = {
		name = "Silver Bullets",
		desc = "While %s is not held, gain %s bullet penetration \z
		and extra crowbars can be picked up for +%u stacks of Silver Bullets. \z
		Each stack gives 1%% more damage dealt against entities above 80%% health.",
		values = function(level)
			local slowWalkKey = "the Slow Walk key"
			local distance = level * 20
			if CLIENT then
				local keyName = input.LookupBinding("+walk")
				if keyName then
					slowWalkKey = keyName:upper()
				end
				distance = InsaneStats:FormatNumber(distance, {plus = true, distance = true})
			end
			return slowWalkKey, distance, level * 25, level * 20
		end,
		stackTick = function(state, current, time, ent)
			return ent:IsPlayer() and ent:KeyDown(IN_WALK) and -1 or 1, current
		end,
		img = "supersonic-bullet",
		pos = {2, -5},
		minpts = 5
	},
	increase_the_pressure = {
		name = "Increase the Pressure",
		desc = "On kill, gain %+.1f stack(s) of Increase the Pressure. Each stack increases most weapons' fire rate by 1%%, but stacks decay at a rate of -0.1%%/s.",
		values = function(level)
			return level/5
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = current * .999 ^ time
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "hydra-shot",
		pos = {3, -4},
		minpts = 5
	},
	multi_killer = {
		name = "Multi Killer",
		desc = "On kill or prop broken, gain +%.1f stacks of Multi Killer. \z
		Each stack gives 100%% more coins and XP, \z
		but stacks decay at a rate of %.2f/s plus an additional %.2f%%/s.",
		values = function(level, ent)
			local decayMult = 1 --+ ent:InsaneStats_GetEffectiveSkillValues("sick_combo", 2) / 100
			return level * 0.2,
			level * -0.2 * decayMult,
			-0.1 * decayMult
		end,
		stackTick = function(state, current, time, ent)
			local constantDecayRate, expDecayRate = ent:InsaneStats_GetEffectiveSkillValues("multi_killer", 2)
			local f1, f2 = 100 / expDecayRate, 1 + expDecayRate / 100
			local offset = constantDecayRate * f1
			local nextStacks = (current + offset) * f2 ^ time - offset
			nextStacks = math.max(nextStacks, 0)
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "double-shot",
		pos = {4, -3},
		minpts = 5
	},
	keep_it_fresh = {
		name = "Keep It Fresh",
		desc = "On kill, set the number of Keep It Fresh stacks to %u \z
		unless the kill was done with the same weapon as the last kill, \z
		in which case the number of stacks is reduced by %i instead. \z
		Each stack gives 1%% more coins and XP, and stacks cannot go below zero.",
		values = function(level, ent)
			return ent:InsaneStats_GetEffectiveSkillValues("the_fourth_dimension", 2) + 50, math.min(level*5 - 30, 0)
		end,
		stackTick = function(state, current, time, ent)
			return current > 0 and 1 or 0, current
		end,
		img = "three-keys",
		pos = {5, -2},
		minpts = 5
	},
	alert = {
		name = "Alert",
		desc = "The position of the nearest enemy is marked on the HUD! Towards this entity, damage dealt, coins and XP gained \z
		are all increased by %+.0f%%, and damage taken from this entity is reduced by %+.0f%%.",
		values = function(level)
			return level * 25, level * -25
		end,
		img = "radar-sweep",
		pos = {4, -1},
		minpts = 10,
		max = 1
	},
	boundless_shield = {
		name = "Boundless Shield",
		desc = "Armor Batteries can be picked up%s even while maxed, but with diminishing returns!%s",
		values = function(level)
			if level > 1 then
				return " and Suit Chargers can be used", " Suit Chargers are also used instantly."
			else
				return "", ""
			end
		end,
		img = "shield-echoes",
		pos = {4, 1},
		minpts = 10,
		max = 1
	},
	keep_it_ready = {
		name = "Keep It Ready",
		desc = "Gain more coins and XP based on the square root of the percentage of ammo left in the current weapon's clip. At 100%% ammo, coins and XP gain is increased by +%u%%!",
		values = function(level)
			return level * 10
		end,
		img = "knapsack",
		pos = {5, 2},
		minpts = 5
	},
	better_than_ever = {
		name = "Better Than Ever",
		desc = "Health Kits increase max health by +%s, and Armor Batteries increase max armor by +%s!",
		values = function(level, ent)
			local scaleType = ent:IsPlayer() and "player" or "other"
			local baseMult = ent:IsPlayer() and 1 or InsaneStats:GetConVarValue("infhealth_armor_mul")
			local effectiveLevel = InsaneStats:GetConVarValue("xp_enabled") and ent:InsaneStats_GetLevel() or 1

			local value1 = InsaneStats:ScaleValueToLevel(
				level/100,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_health")/100,
				effectiveLevel,
				"xp_"..scaleType.."_health_mode"
			)
			local value2 = InsaneStats:ScaleValueToLevel(
				level/100*baseMult,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_armor")/100,
				effectiveLevel,
				"xp_"..scaleType.."_armor_mode"
			)

			return CLIENT and InsaneStats:FormatNumber(value1), CLIENT and InsaneStats:FormatNumber(value2),
			value1, value2
		end,
		img = "flowers",
		pos = {4, 3},
		minpts = 5
	},
	panic = game.SinglePlayer() and {
		name = "PANIC",
		desc = "Gain up to %+.0f%% movement speed at low health.\n\z
		(This skill is completely different in multiplayer.)",
		values = function(level)
			return level * 20
		end,
		img = "screaming",
		pos = {3, 4},
		minpts = 5
	} or {
		name = "Stay Behind Me",
		desc = "All allies within %s regenerate %+.1f%% of their missing health per second.\n\z
		(This skill is completely different in singleplayer.)",
		values = function(level)
			local distance = 512
			if CLIENT then
				distance = InsaneStats:FormatNumber(distance, {distance = true})
			end
			return distance, level/2.5
		end,
		img = "ghost-ally",
		pos = {3, 4},
		minpts = 5
	},
	reject_humanity = {
		name = "Reject Humanity",
		desc = "On kill, gain %+.1f stack(s) of Reject Humanity. \z
		Each stack gives 1%% more damage dealt, coins and XP, \z
		but each stack also causes 1%% more damage taken and stacks decay at a rate of -0.1%%/s.",
		values = function(level)
			return level/5
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = current * .999 ^ time
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "mad-scientist",
		pos = {2, 5},
		minpts = 5
	},
	just_breathe = game.SinglePlayer() and {
		name = "Just Breathe",
		desc = "Double tap %s to reduce game speed by %+i%% and increase movement rate by %+i%% for 10 seconds! \z
		While this skill is active, Ain't Got Time For This stacks are gained %+i%% faster. 60 seconds cooldown.\n\z
		(This skill is completely different in multiplayer.)",
		values = function(level)
			local slowWalkKey = "the Slow Walk key"
			if CLIENT then
				local keyName = input.LookupBinding("+walk")
				if keyName then
					slowWalkKey = keyName:upper()
				end
			end
			return slowWalkKey, -25 - level * 25, -100 + level * 200, -100 + level * 200
		end,
		stackTick = function(state, stacks, time, ent)
			if state == 1 then
				stacks = stacks - time
				if stacks < 0 then
					state = -1
					stacks = stacks + 60
					time = 0
				end
			end
			if state < 0 then
				stacks = stacks - time
				if stacks <= 0 then
					stacks = 0
					state = 0
				end
			end

			return state, stacks
		end,
		img = "sands-of-time",
		pos = {1, 4},
		minpts = 10,
		max = 1
	} or {
		name = "Charge!",
		desc = "Double tap %s to increase damage dealt by %u%% and \z
		reduce damage taken by %i%% for ALL allies for 10 seconds! 60 seconds cooldown.\n\z
		(This skill is completely different in singleplayer.)",
		values = function(level)
			local slowWalkKey = "the Slow Walk key"
			if CLIENT then
				local keyName = input.LookupBinding("+walk")
				if keyName then
					slowWalkKey = keyName:upper()
				end
			end
			return slowWalkKey, level * 50, level * -40
		end,
		stackTick = function(state, stacks, time, ent)
			if state == 1 then
				stacks = stacks - time
				if stacks < 0 then
					state = -1
					stacks = stacks + 60
					time = 0
				end
			end
			if state < 0 then
				stacks = stacks - time
				if stacks <= 0 then
					stacks = 0
					state = 0
				end
			end

			return state, stacks
		end,
		img = "anthem",
		pos = {1, 4},
		minpts = 10,
		max = 1
	},
	ctrl_f = {
		name = "Ctrl+F",
		desc = "Interacting with a key will show the door it unlocks on the HUD, and vice versa, for 60 seconds.%s",
		values = function(level, ent)
			if level > 1 then
				return " Indicators are also shown at the exact points to slot a key in \z
				and when ANY door / button gets unlocked or moved."
			else return ""
			end
		end,
		img = "magnifying-glass",
		pos = {-1, 4},
		minpts = 10,
		max = 1
	},
	you_all_get_a_car = {
		name = "You All Get A Car",
		desc = "While %s is not held, share up to level %+i of most skills with all allies. Also, weapon switch speed is increased by %+i%%.",
		values = function(level, ent)
			local slowWalkKey = "the Slow Walk key"
			if CLIENT then
				local keyName = input.LookupBinding("+walk")
				if keyName then
					slowWalkKey = keyName:upper()
				end
			end
			return slowWalkKey, level, level*25
		end,
		stackTick = function(state, current, time, ent)
			return ent:IsPlayer() and ent:KeyDown(IN_WALK) and -1 or 1, current
		end,
		img = "two-shadows",
		pos = {-2, 5},
		minpts = 5
	},
	item_magnet = {
		name = "Item Magnet",
		desc = "Items and weapons wtihin %s are magnetized, \z
		with random items created from modifiers / skills within this radius \z
		being teleported instead of magnetized! \z
		Also, automatically pick up coins that are furthest from any other player after %u seconds.",
		values = function(level, ent)
			local distance = level * 256
			if CLIENT then
				distance = InsaneStats:FormatNumber(distance, {plus = true, distance = true})
			end
			return distance, 20 - level * 2
		end,
		img = "magnet",
		pos = {-3, 4},
		minpts = 5
	},
	starlight = {
		name = "Starlight",
		desc = "On kill or prop broken, gain %+.1f stacks of Starlight. \z
		Each stack gives 1%% more defence, coins and XP but also causes glowing \z
		by %s times the square root of the number of stacks. \z
		Stacks decay at a rate of -0.1%%/s.",
		values = function(level)
			local distance = 64
			if CLIENT then
				distance = InsaneStats:FormatNumber(distance, {distance = true})
			end
			return level/5, distance
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = current * .999 ^ time
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "sundial",
		pos = {-4, 3},
		minpts = 5
	},
	spongy = game.SinglePlayer() and {
		name = "Spongy",
		desc = "%i%% damage dealt\n\z
		%i%% fire rate\n\z
		%i%% damage taken\n\z
		+%u%% movement speed\n\z
		(This skill is completely different in multiplayer.)",
		values = function(level, ent)
			return level * -3, level * -3, level * -8, level * 3
		end,
		img = "cheese-wedge",
		pos = {-5, 2},
		minpts = 5
	} or {
		name = "Connection Problem",
		desc = "Defence is increased by +%.1f%% times current ping.\n\z
		(This skill is completely different in singleplayer.)",
		values = function(level, ent)
			return level / 10
		end,
		img = "static",
		pos = {-5, 2},
		minpts = 5
	},
	fight_for_your_life = {
		name = "Fight For Your Life",
		desc = "Whenever lethal damage would be taken, instead become prone. \z
		Killing an enemy while prone grants a Second Wind, restoring 100%% of health!\n\z
		All damage is negated while prone, but death occurs after proning for %u seconds. \z
		This available time is reduced by 2 seconds for each consecutive Second Wind.",
		values = function(level)
			return level * 10
		end,
		stackTick = function(state, current, time, ent)
			if state < 1 then
				local nextStacks = math.min(current + time / 60, 0)
				return 0, nextStacks
			else
				local nextStacks = math.max(current - time, 0)
				return state, nextStacks
			end
		end,
		img = "defibrilate",
		pos = {-4, 1},
		minpts = 10,
		max = 1
	},
	actually_levelling_up = {
		name = "Actually Levelling Up",
		desc = "Every level up increases max health and max shield by +%s and +%s, respectively, \z
		per skill point spent in total (+%s and +%s, respectively, at current total spent skill points)! \z
		Then, restore health and shield by 2 times the amount of max health and max shield gained, respectively! \z
		Health and shield gained this way can exceed max health and max shield, \z
		but with diminishing returns.",
		values = function(level, ent)
			local scaleType = ent:IsPlayer() and "player" or "other"
			local baseMult = ent:IsPlayer() and 1 or InsaneStats:GetConVarValue("infhealth_armor_mul")
			local effectiveLevel = InsaneStats:GetConVarValue("xp_enabled") and ent:InsaneStats_GetLevel() or 1
			local spentSkillPoints = ent:InsaneStats_GetSpentSkillPoints()
			
			local value1 = level
			if InsaneStats:GetConVarValueDefaulted("xp_"..scaleType.."_health_mode", "xp_mode") > 0 then
				value1 = InsaneStats:ScaleValueToLevelPure(
					value1,
					InsaneStats:GetConVarValue("xp_"..scaleType.."_health")/100,
					effectiveLevel,
					true
				)
			end
			local value2 = level*baseMult
			if InsaneStats:GetConVarValueDefaulted("xp_"..scaleType.."_armor_mode", "xp_mode") > 0 then
				value2 = InsaneStats:ScaleValueToLevelPure(
					value2,
					InsaneStats:GetConVarValue("xp_"..scaleType.."_armor")/100,
					effectiveLevel,
					true
				)
			end
			local value3 = value1 * spentSkillPoints
			local value4 = value2 * spentSkillPoints

			return CLIENT and InsaneStats:FormatNumber(value1),
			CLIENT and InsaneStats:FormatNumber(value2),
			CLIENT and InsaneStats:FormatNumber(value3),
			CLIENT and InsaneStats:FormatNumber(value4),
			level * 100, value3, value4
		end,
		img = "deadly-strike",
		pos = {-4, -1},
		minpts = 10,
		max = 1
	},
	impenetrable_shield = {
		name = "Impenetrable Shield",
		desc = "Shield blocks 100%% of damage instead of 80%%, and damage taken is reduced by %+.0f%% while shielded.",
		values = function(level, ent)
			return level * -8
		end,
		img = "crenulated-shield",
		pos = {-5, -2},
		minpts = 5
	},
	desperate_harvest = {
		name = "Desperate Harvest",
		desc = "At low health, critical hits restore up to %+.0f%% of max health.",
		values = function(level)
			return level
		end,
		img = "bird-claw",
		pos = {-4, -3},
		minpts = 5
	},
	instant_karma = {
		name = "Instant Karma",
		desc = "Whenever damage would be taken, there is a %+.0f%% chance to deal %s BASE damage back!",
		values = function(level, ent)
			local val = 4 * InsaneStats:DetermineDamageMulPure(
				ent, game.GetWorld()
			)
			return level * 10, CLIENT and InsaneStats:FormatNumber(val)
		end,
		img = "shield-reflect",
		pos = {-3, -4},
		minpts = 5
	},
	its_high_noon = {
		name = "It's High Noon",
		desc = "Most weapons become fully automatic and fire faster \z
		based on the percentage of ammo left in the current weapon's clip. \z
		At 100%% ammo, fire rate is increased by +%u%%!",
		values = function(level)
			return level * 10
		end,
		img = "lightning-trio",
		pos = {-2, -5},
		minpts = 5
	},
	anger = {
		name = "Anger",
		desc = "Taking damage increases all damage dealt by +200%% for 10 seconds! %u seconds cooldown. \z
		However, dealing explosive damage to an NPC creates a live grenade that explodes after 2 seconds, \z
		at most once per second per NPC.",
		values = function(level)
			return 180 - level * 60
		end,
		stackTick = function(state, stacks, time, ent)
			if state == 1 then
				stacks = stacks - time
				if stacks < 0 then
					state = -1
					stacks = stacks + ent:InsaneStats_GetEffectiveSkillValues("anger")
					time = 0
				end
			end
			if state < 0 then
				stacks = stacks - time
				if stacks <= 0 then
					stacks = 0
					state = 0
				end
			end

			return state, stacks
		end,
		img = "snake-bite",
		pos = {-1, -4},
		minpts = 10,
		max = 1
	},

	-- distance 8
	killing_spree = {
		name = "Killing Spree",
		desc = "On kill, gain %s of Killing Spree for 1 minute. \z
		Every power of 5 Killing Spree stacks grant an additional positive effect on kill! \z
		Having more Killing Spree stacks will also increase the potency of the positive effects!",
		values = function(level)
			if level > 1 then
				return "2 stacks"
			else
				return "1 stack"
			end
		end,
		img = "skull-signet",
		pos = {0, -4},
		minpts = 2,
		max = 1
	},
	melee_arts = {
		name = "Melee Arts",
		desc = "Gain +%u stack(s) of Melee Arts per second, up to 1. \z
		At 1 stack, holding down %s with any melee weapon or the Gravity Gun \z
		consumes all stacks to fire a %s BASE damage bullet that deals melee damage. \z
		Holding down %s with a melee weapon at 1 stack will instead absorb the next damage taken, \z
		also consuming all stacks when damage is absorbed this way.",
		values = function(level, ent)
			local value = 4 * InsaneStats:DetermineDamageMulPure(
				ent, game.GetWorld()
			)
			local defendKey = "the Secondary Fire key"
			local bulletKey = "the Reload key"
			if CLIENT then
				local keyName = input.LookupBinding("+reload")
				if keyName then
					bulletKey = keyName:upper()
				end
				keyName = input.LookupBinding("+attack2")
				if keyName then
					defendKey = keyName:upper()
				end
			end
			return level, bulletKey, CLIENT and InsaneStats:FormatNumber(value), defendKey
		end,
		stackTick = function(state, current, time, ent)
			local newStacks = math.min(
				current + time * ent:InsaneStats_GetEffectiveSkillValues("melee_arts"),
				1
			)
			return newStacks >= 1 and 1 or 0, newStacks
		end,
		img = "spinning-sword",
		pos = {2, -6},
		minpts = 5
	},
	anti_coward_rounds = {
		name = "Anti-Coward Rounds",
		desc = "%+.0f%% damage dealt against props\n\z
		%+.0f%% damage dealt against shielded entities\n\z
		%+.0f%% damage dealt against armored entities",
		values = function(level)
			return level * 10, level * 10, level * 10
		end,
		img = "cracked-disc",
		pos = {3, -5},
		minpts = 5
	},
	aimbot = {
		name = "Aimbot",
		desc = "Fired bullets have %+i%% chance of being redirected to enemy critical hit spots! \z
		These bullets can still miss if the bullet spread is too high. \z
		Additionally, all non-bullet damage dealt is reduced by %+i%%, but have %+i%% chance to critically hit.",
		values = function(level)
			return level * 8, level * -5, level * 10
		end,
		img = "microscope-lens",
		pos = {4, -4},
		minpts = 5
	},
	sick_combo = {
		name = "Sick Combo",
		desc = "On kill, gain +%.1f stack(s) of Sick Combo and extend its duration by 3 seconds. \z
		Picking up any item will also extend the duration by half the amount. \z
		Each stack gives 1%% more coins and XP, but \z
		duration is limited to a maximum of 60 seconds! \z
		Also, every power of %u Sick Combo stacks grant +100%% more kill skill retriggers on kill!",
		values = function(level)
			return level/5, 5
		end,
		img = "poker-hand",
		pos = {5, -3},
		minpts = 5
	},
	too_many_items = {
		name = "Too Many Items",
		desc = "Gain +%.1f stack(s) of Too Many Items whenever an item is picked up. \z
		All skills and modifiers that give random items \z
		instead grant up to +%u stacks of Too Many Items. \z
		At 100 stacks, consume 100 to fully restore all ammo, \z
		health and shield, as well as triggering all skills \z
		related to picking up Health Kits and Armor Batteries. \z
		Health and shield gained this way can exceed max health and max shield, \z
		but with diminishing returns.",
		values = function(level, ent)
			-- min level above 0: 0.1, max level: 20
			level = level * (1 + ent:InsaneStats_GetEffectiveSkillValues("productivity", 3) / 100)
			return level, level * 10
		end,
		stackTick = function(state, current, time, ent)
			return 0, current
		end,
		img = "cubes",
		pos = {6, -2},
		minpts = 5
	},
	when_the_sigma_grind_aint_enough = {
		name = "When The Sigma Grind Ain't Enough",
		desc = "Every %u skill points gained, gain a über skill point! \z
		Über skill points can double the level of skills, but can only be spent on fully upgraded skills!",
		values = function(level)
			return 30 - level*10
		end,
		img = "star-swirl",
		pos = {4, 0},
		minpts = 2,
		max = 1
	},
	seasoning = {
		name = "Seasoning",
		desc = "Whenever damage would be dealt, there is a +%u%% chance \z
		to increase coins and XP yielded by the victim for 10 seconds. \z
		This effect can stack, but the number of stacks applied is proportional to BASE damage dealt.",
		values = function(level, ent)
			--local maxStacks = level / 10 * 2^128
			return level * 10--, CLIENT and InsaneStats:FormatNumber(maxStacks, {plus = true}) or maxStacks
		end,
		img = "salt-shaker",
		pos = {6, 2},
		minpts = 5
	},
	feel_the_energy = {
		name = "Feel The Energy",
		desc = "Having more shield increases coins and XP gained. At 100%% shield, coins and XP gain is increased by %+.0f%%.",
		values = function(level)
			return level * 20
		end,
		img = "triple-yin",
		pos = {5, 3},
		minpts = 5
	},
	mantreads = {
		name = "Mantreads",
		desc = "Negate all fall damage! All fall damage that would be received \z
		is instead doubled +%u time(s), \z
		then dealt to all other entities within %s. \z
		Additionally, stomping can be done by pressing %s twice in mid-air, which on impact \z
		deals the maximum amount of fall damage.",
		values = function(level)
			local crouchKey = "the Crouch key"
			local distance = 256
			if CLIENT then
				local keyName = input.LookupBinding("+duck")
				if keyName then
					crouchKey = keyName:upper()
				end
				distance = InsaneStats:FormatNumber(distance, {distance = true})
			end
			return level, distance, crouchKey
		end,
		img = "quake-stomp",
		pos = {4, 4},
		minpts = 5
	},
	hacked_shield = {
		name = "Hacked Shield",
		desc = "Reduce the softcap and hardcap effects of overcharging the shield by %i%%, \z
		but getting hit PERMANENTLY reduces maximum shield by %.2f%%! This skill cannot reduce max shield below %s. \z
		Also, gain +%u%% dodge chance against non-disintegrating damage, \z
		but this chance is divided by shield %% when shield is above 100%%.",
		values = function(level, ent)
			local scaleType = ent:IsPlayer() and "player" or "other"
			local baseMult = ent:IsPlayer() and 1 or InsaneStats:GetConVarValue("infhealth_armor_mul")
			local effectiveLevel = InsaneStats:GetConVarValue("xp_enabled") and ent:InsaneStats_GetLevel() or 1
			local val = InsaneStats:ScaleValueToLevel(
				baseMult,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_armor")/100,
				effectiveLevel,
				"xp_"..scaleType.."_armor_mode"
			)

			return level*-10, level/-50, CLIENT and InsaneStats:FormatNumber(val), level*5, val
		end,
		img = "circuitry",
		pos = {3, 5},
		minpts = 5
	},
	pyrotheum = {
		name = "Stellar Nodes",
		desc = "Killed enemies create a %s radius stellar node that lasts for +%u second(s). \z
		Kills that happen within %s from a node's center will extend the duration of the node. \z
		Nodes heal allies while damaging all other entities within range, \z
		with healing and damage scaled based on node duration and radius.",
		values = function(level, ent)
			local distance = level * 16
			local dist2 = distance * 2
			if CLIENT then
				distance = InsaneStats:FormatNumber(distance, {plus = true, distance = true})
				dist2 = InsaneStats:FormatNumber(dist2, {plus = true, distance = true})
			end
			return distance, level * 2, dist2
		end,
		img = "sun",
		pos = {2, 6},
		minpts = 5
	},
	celebration = {
		name = "Celebration",
		desc = "All kill skills are triggered%s by non-player kills from ANY entity! \z
		Also, using a manual crank while holding %s causes it to auto-turn.",
		values = function(level)
			local sprintKey = "the Sprint key"
			if CLIENT then
				local keyName = input.LookupBinding("+speed")
				if keyName then
					sprintKey = keyName:upper()
				end
			end
			if level > 1 then
				return " twice", sprintKey
			else
				return "", sprintKey
			end
		end,
		stackTick = function(state, current, time, ent)
			return ent:IsPlayer() and ent:KeyDown(IN_SPEED) and 1 or 0, current
		end,
		img = "rally-the-troops",
		pos = {0, 4},
		minpts = 2,
		max = 1
	},
	dangerous_preparation = {
		name = "Dangerous Preparation",
		desc = "Gain more damage dealt, damage taken, coins and XP \z
		based on the square root of the percentage of ammo left in the current weapon's clip. \z
		At 100%% ammo, damage dealt, damage taken, coins and XP gain are all increased by +%u%%!",
		values = function(level)
			return level * 10
		end,
		img = "thunder-skull",
		pos = {-2, 6},
		minpts = 5
	},
	the_fourth_dimension = {
		name = "The Fourth Dimension",
		desc = "Weapons are instantly reloaded %u second(s) after they are fired, \z
		regardless of whether they are the active weapon or not! \z
		Additionally, the number of stacks set on kill for the Keep It Fresh skill is increased by +%u.",
		values = function(level)
			return math.max(6 - level, 0), level * 10
		end,
		img = "moebius-triangle",
		pos = {-3, 5},
		minpts = 5
	},
	fall_to_rise_up = {
		name = "Fall to Rise Up",
		desc = "Regenerate health at low health, up to %+.0f%%/s!",
		values = function(level)
			return level
		end,
		img = "heart-tower",
		pos = {-4, 4},
		minpts = 5
	},
	medic_bag = {
		name = "Medic Bag",
		desc = "Receiving damage restores %+.0f%% of max health and max shield. \z
		Health and shield gained this way can exceed max health and max shield, \z
		but with diminishing returns. 60 seconds cooldown.",
		values = function(level)
			return level * 10
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = math.max(current - time, 0)
			return nextStacks <= 0 and 0 or -1, nextStacks
		end,
		img = "hospital-cross",
		pos = {-5, 3},
		minpts = 5
	},
	across_the_sky = {
		name = "Across The Sky",
		desc = "+%u%% defence in mid-air for every %s above ground",
		values = function(level)
			local distance = 16
			if CLIENT then
				distance = InsaneStats:FormatNumber(distance, {distance = true})
			end
			return level * 10, distance
		end,
		img = "winged-shield",
		pos = {-6, 2},
		minpts = 5
	},
	rock_solid = {
		name = "Rock Solid",
		desc = "Negate all fire%s damage taken! \z
		Additionally, negate ALL damage taken while in a vehicle!",
		values = function(level)
			if level > 1 then
				return ", poison and shock"
			else
				return ""
			end
		end,
		img = "guarded-tower",
		pos = {-4, 0},
		minpts = 2,
		max = 1
	},
	stuff_in_the_way = {
		name = "Stuff In The Way",
		desc = "Defence against attacks is increased by +%u%% for every %s away from the damage source.",
		values = function(level)
			local distance = 512
			if CLIENT then
				distance = InsaneStats:FormatNumber(distance, {distance = true})
			end
			return level * 10, distance
		end,
		img = "orbital",
		pos = {-6, -2},
		minpts = 5
	},
	suit_up = {
		name = "Suit Up",
		desc = "Take %+i%% damage if either WPASS2 is disabled or the equipped Armor Battery is Tier 0, \z
		otherwise gain %+i%% defence per tier of the equipped Armor Battery!",
		values = function(level)
			return level*-5, level*3
		end,
		img = "mail-shirt",
		pos = {-5, -3},
		minpts = 5
	},
	blast_proof_suit = {
		name = "Blast-Proof Suit",
		desc = "Move -25%% slower, but take -100%% self-explosion damage! \z
		Explosive damage from other sources is reduced by %i%% instead. \z
		Also, holding %s allows picking up props that are up to +%u%% heavier \z
		than what could be picked up by hand.",
		values = function(level)
			local slowWalkKey = "the Slow Walk key"
			if CLIENT then
				local keyName = input.LookupBinding("+walk")
				if keyName then
					slowWalkKey = keyName:upper()
				end
			end
			return level * -10, slowWalkKey, level * 200
		end,
		stackTick = function(state, current, time, ent)
			return ent:IsPlayer() and ent:KeyDown(IN_WALK) and 1 or 0, current
		end,
		img = "robot-golem",
		pos = {-4, -4},
		minpts = 5
	},
	scattershot = {
		name = "Scattershot",
		desc = "Gain %+.1f stack(s) of Scattershot per second, up to 100 stacks. \z
		While holding a shotgun, an additional %s BASE damage is dealt to each enemy visible from the victim. \z
		1 stack is lost for every instance of damage dealt this way.",
		values = function(level, ent)
			local value = 8 * InsaneStats:DetermineDamageMulPure(
				ent, game.GetWorld()
			)
			return level/5, CLIENT and InsaneStats:FormatNumber(value)
		end,
		stackTick = function(state, current, time, ent)
			local newStacks = math.min(current + time * ent:InsaneStats_GetEffectiveSkillValues("scattershot", 1), 100)
			return newStacks > 0 and 1 or 0, newStacks
		end,
		img = "divert",
		pos = {-3, -5},
		minpts = 5
	},
	rain_from_above = {
		name = "Rain From Above",
		desc = "+%u%% mid-air damage dealt for every %s above ground",
		values = function(level)
			local distance = 16
			if CLIENT then
				distance = InsaneStats:FormatNumber(distance, {distance = true})
			end
			return level * 10, distance
		end,
		img = "sunbeams",
		pos = {-2, -6},
		minpts = 5
	},

	-- distance 9
	hateful = {
		name = "Hateful",
		desc = "On crit, add +%u stack(s) of Stacking Defence Down to the victim for 10 seconds, \z
		increasing damage taken by 1%% per stack!",
		values = function(level)
			return level
		end,
		img = "skull-crack",
		pos = {1, -5},
		minpts = 6
	},
	kill_aura = {
		name = "Kill Aura",
		desc = "On kill, gain %+u stack(s) of Kill Aura. Enemies within %s times the number of stacks \z
		take %s BASE damage per second while %s is not held, \z
		but stacks decay at a rate of %.1f/s plus an additional -0.1%%/s.",
		values = function(level, ent)
			local slowWalkKey = "the Slow Walk key"
			local damage = 5
			local distance = 8

			if CLIENT then
				damage = InsaneStats:FormatNumber(damage * InsaneStats:DetermineDamageMulPure(
					ent, game.GetWorld()
				))

				local keyName = input.LookupBinding("+walk")
				if keyName then
					slowWalkKey = keyName:upper()
				end

				distance = InsaneStats:FormatNumber(distance, {distance = true})
			end

			return level * 2, distance, damage, slowWalkKey, level / -5
		end,
		stackTick = function(state, current, time, ent)
			local constantDecayRate = ent:InsaneStats_GetEffectiveSkillValues("kill_aura", 5)
			local f1, f2 = -1000, .999
			local offset = constantDecayRate * f1
			local nextStacks = (current + offset) * f2 ^ time - offset
			nextStacks = math.max(nextStacks, 0)

			return ent:IsPlayer() and ent:KeyDown(IN_WALK) and -1
			or nextStacks <= 0 and 0
			or 1, nextStacks
		end,
		img = "broken-heart-zone",
		pos = {4, -5},
		minpts = 5
	},
	adamantite_forge = {
		name = "Adamantite Forge",
		desc = "Reduce the chance of getting curse modifiers when reforging by %i%%. \z
		Reforging also increases the tier by +%.1f, but only once per weapon / armor battery. \z
		If either Coin Drops or WPASS2 is disabled, coins and XP gain is increased by +%u%% instead.",
		values = function(level, ent)
			return level * -10, level / 2, level * 5
		end,
		img = "anvil-impact",
		pos = {5, -4},
		minpts = 5
	},
	upward_spiralling = {
		name = "Upward Spiralling",
		desc = "Every spent skill point gives +%.2f%% coins and XP, \z
		while every spent über skill point adds +%.3f to the value of the percentage. \z
		(+%.3f%% coins and XP gain at current total spent skill points and über skill points.)",
		values = function(level, ent)
			local thirdValue = (
				level/20 + level/200
				* ent:InsaneStats_GetSpentUberSkillPoints()
			) * ent:InsaneStats_GetSpentSkillPoints()
			return level/20, level/200, thirdValue
		end,
		img = "gold-shell",
		pos = {5, -1},
		minpts = 6
	},
	productivity = {
		name = "Productivity",
		desc = "%+.0f%% chance to duplicate items. On kill, add %+u%% ammo into the current weapon's clips. \z
		The Too Many Items skill is also %+u%% more effective.",
		values = function(level)
			return level * 10, level * 5, level * 10
		end,
		img = "cubeforce",
		pos = {5, 1},
		minpts = 6
	},
	the_bigger_they_are = {
		name = "The Bigger They Are",
		desc = "Killing a large enemy creates an Item Crate that gives +%u random items when broken. \z
		Coins and XP gained from such kills are also multiplied by the victim's amount of XP ^%.2f.",
		values = function(level, ent)
			return level, level / 100
		end,
		img = "orb-direction",
		pos = {5, 4},
		minpts = 5
	},
	hellish_challenge = {
		name = "Hellish Challenge",
		desc = "Gain +%u%% attack damage, coins and XP. \z
		Whenever damage would be taken from a mob, gain %i stack(s) of Hellish Challenge. \z
		Each stack increases health and shield gained from skills and modifiers by 1%% \z
		and stacks are passively gained at a rate of +%.1f per second. Stacks are clamped to between -100 and 0.",
		values = function(level, ent)
			local amplifier = 1 + ent:InsaneStats_GetEffectiveSkillValues("love_and_tolerate", 2) / 100
			return level * 10 * amplifier, -level * amplifier, level/5 * amplifier
		end,
		stackTick = function(state, current, time, ent)
			local newStacks = math.Clamp(
				current + time * ent:InsaneStats_GetEffectiveSkillValues("hellish_challenge", 3),
				-100, 0
			)
			return newStacks ~= 0 and 1 or 0, newStacks
		end,
		img = "daemon-skull",
		pos = {4, 5},
		minpts = 5
	},
	bloodletters_revelation = {
		name = "Bloodletter's Revelation",
		desc = "Gain up to %+.0f%% movement speed at high health. The Bloodletter's Pact skill is also +%u%% more effective.",
		values = function(level)
			return level * 8, level * 20
		end,
		img = "dripping-goo",
		pos = {1, 5},
		minpts = 6
	},
	beyond_240_kmph = {
		name = "Beyond 240 km/h",
		desc = "Speed-based skills and modifiers now use effective speed, \z
		which is calculated as being %+i%% higher than actual speed! \z
		For all skills and modifiers that do not dilate time, \z
		an additional %+i%% of normal running speed is always added to effective speed!",
		values = function(level)
			return level * 10, level * 10
		end,
		img = "afterburn",
		pos = {-1, 5},
		minpts = 6
	},
	aint_got_time_for_this = game.SinglePlayer() and {
		name = "Ain't Got Time For This",
		desc = "While %s is held, gain +%u stack(s) of Ain't Got Time For This per second. \z
		Each stack increases attack damage, defence and game speed by 1%%, but all stacks are lost when %s is released.\n\z
		(This skill is completely different in multiplayer.)",
		values = function(level)
			local crouchKey = "the Crouch key"
			if CLIENT then
				local keyName = input.LookupBinding("+duck")
				if keyName then
					crouchKey = keyName:upper()
				end
			end
			return crouchKey, level, crouchKey
		end,
		stackTick = function(state, current, time, ent)
			local add = (state == 1 and time or 0) * ent:InsaneStats_GetEffectiveSkillValues("aint_got_time_for_this", 2)
			if ent:InsaneStats_EffectivelyHasSkill("just_breathe") and ent:InsaneStats_GetSkillState("just_breathe") == 1 then
				add = add * (1 + ent:InsaneStats_GetEffectiveSkillValues("just_breathe", 4) / 100)
			end
			return state, current + add
		end,
		img = "clockwork",
		pos = {-4, 5},
		minpts = 5
	} or {
		name = "Motivation",
		desc = "Gain +%u%% of XP from ally kills. All allies within %s regenerate health at a rate of %+.1f%%/s.\n\z
		(This skill is completely different in singleplayer.)",
		values = function(level)
			local distance = 512
			if CLIENT then
				distance = InsaneStats:FormatNumber(distance, {distance = true})
			end
			return level * 20, distance, level/5
		end,
		img = "cheerful",
		pos = {-4, 5},
		minpts = 5
	},
	until_the_last_bit = {
		name = "Until The Last Bit",
		desc = "Health Kits and Health Vials restore an additional %+i%% and %+i%% of max health, respectively! \z
		Armor Batteries also restore an additional %+i%% of max shield!",
		values = function(level)
			return level*5, level*2, level*3
		end,
		img = "dripping-honey",
		pos = {-5, 4},
		minpts = 5
	},
	bastion_of_flesh = {
		name = "Bastion of Flesh",
		desc = "+%u%% of max shield gained from skills and modifiers is converted into max health instead. \z
		On kill, %+.2f%% of max shield is converted into max health. \z
		Max shield converted by this skill restores health by %u times the amount converted! \z
		Health gained this way can exceed max health, but with diminishing returns! \z
		This skill cannot reduce max armor below %s.",
		values = function(level, ent)
			local scaleType = ent:IsPlayer() and "player" or "other"
			local baseMult = ent:IsPlayer() and 1 or InsaneStats:GetConVarValue("infhealth_armor_mul")
			local effectiveLevel = InsaneStats:GetConVarValue("xp_enabled") and ent:InsaneStats_GetLevel() or 1
			local val = InsaneStats:ScaleValueToLevel(
				baseMult,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_armor")/100,
				effectiveLevel,
				"xp_"..scaleType.."_armor_mode"
			)

			return level*10, level/50, 20, CLIENT and InsaneStats:FormatNumber(val), val
		end,
		img = "back-forth",
		pos = {-5, 1},
		minpts = 6
	},
	vitality_to_go = {
		name = "Vitality To Go",
		desc = "Health and Suit Chargers can be PERMANENTLY destroyed from melee attacks. \z
		Health and Suit Chargers destroyed this way give Vitality To Go stacks \z
		based on %+i%% of the maximum amount of health and shield that would have been given by them. \z
		Each stack gives 1%%/s health and shield regeneration, and stacks do not decay over time! \z
		Health and shield gained this way can exceed max health and max shield, but with diminishing returns!",
		values = function(level)
			return level
		end,
		stackTick = function(state, current, time, ent)
			return current > 0 and 1 or 0, current
		end,
		img = "chalice-drops",
		pos = {-5, -1},
		minpts = 6
	},
	better_healthcare = {
		name = "Better Healthcare",
		desc = "%+.0f%% health, max health, shield and max shield gains from skills and modifiers. \z
		Coins and XP gain is also increased by +%.1f%%, \z
		but this percentage is divided by the number of skill points gained in total \z
		(+%.1f%% at current total skill points).",
		values = function(level, ent)
			local xpBoost = 1000 * level
			return level * 5, xpBoost, xpBoost / math.max(ent:InsaneStats_GetTotalSkillPoints(), 1)
		end,
		img = "crowned-heart",
		pos = {-5, -4},
		minpts = 5
	},
	stabilization = {
		name = "Stabilization",
		desc = "Bullets have %+i%% spread. On kill, all recoil from firing weapons is negated for +%u seconds.",
		values = function(level)
			return level * -10, level * 2
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = math.max(current - time, 0)
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "on-target",
		pos = {-4, -5},
		minpts = 5
	},
	shield_shell_shots = {
		name = "Shield Shell Shots",
		desc = "While at 100%% shield or above, all BASE damage dealt is increased by %s, \z
		but results in %.1f%% of shield loss!",
		values = function(level, ent)
			local value = 40 * InsaneStats:DetermineDamageMulPure(
				ent, game.GetWorld()
			)
			return CLIENT and InsaneStats:FormatNumber(value), math.min(level/2.5 - 2.4, 0)
		end,
		img = "shield-bounces",
		pos = {-1, -5},
		minpts = 6
	},

	-- distance X
	master_of_fire = {
		name = "Master of Fire",
		desc = "Double all fire damage dealt and halve all fire damage taken! \z
		All attacks have a +%u%% chance to deal fire damage against mobs, and deal +%u%% damage against non-mobs! \z
		Also, %s the number of times kill skills are triggered on kill!",
		values = function(level, ent)
			return level * 25, level * 25, level > 1 and "triple" or "double"
		end,
		img = "ifrit",
		pos = {0, -5},
		minpts = 11,
		max = 1
	},
	synergy_1 = {
		name = "Synergy (Hot)",
		desc = "On kill or whenever an item is picked up, gain %+.2f stack(s) of Synergy. \z
		Each stack increases damage dealt, coins and XP gained by 1%%, \z
		but stacks decay at a rate of -0.1%%/s regardless of skills.",
		values = function(level)
			return level/20
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = current * .999 ^ time
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "jigsaw-box",
		pos = {5, -5},
		minpts = 10,
		max = 100
	},
	master_of_air = {
		name = "Master of Air",
		desc = "Double all shock damage dealt and halve all shock damage taken! \z
		All attacks have a +%u%% chance to deal shock damage against mobs, and deal +%u%% damage against non-mobs! \z
		Also, the number of adjacent skill points required to unlock skills is reduced by %i, %s\z
		and the first kill after spawning retriggers all kill skills once for every %u skill points gained in total!",
		values = function(level, ent)
			local noShuffleText = level > 1 and "skills cannot be shuffled by any means, " or ""
			return level * 25, level * 25, level * -5, noShuffleText, 30 - level * 10
		end,
		img = "winged-emblem",
		pos = {5, 0},
		minpts = 11,
		max = 1
	},
	synergy_2 = {
		name = "Synergy (Wet)",
		desc = "Every %s travelled or whenever an item is picked up, gain %+.2f stack(s) of Synergy. \z
		Each stack increases health and shield gained from skills and modifiers, coins and XP gained by 1%%, \z
		but stacks decay at a rate of -0.1%%/s regardless of skills. \z
		Distance travelled is computed by multiplying speed and time passed.",
		values = function(level)
			local distance = 8192
			if CLIENT then
				distance = InsaneStats:FormatNumber(distance, {distance = true})
			end
			return distance, level/20
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = current * .999 ^ time
			local newState = nextStacks <= 0 and 0 or 1

			if ent:InsaneStats_EffectivelyHasSkill("synergy_1") then
				newState = -2
			end

			return newState, nextStacks
		end,
		img = "jigsaw-box",
		pos = {5, 5},
		minpts = 10,
		max = 100
	},
	master_of_water = {
		name = "Master of Water",
		desc = "Double all freeze damage dealt and halve all freeze damage taken! \z
		All attacks have a +%u%% chance to deal freeze damage against mobs, and deal +%u%% damage against non-mobs! \z
		Also, this skill gains stacks based on velocity, with normal running speed granting +%u stack(s) per second! \z
		When this skill reaches 100 stacks, 100 stacks are removed to trigger all kill skills!",
		values = function(level, ent)
			return level * 25, level * 25, level
		end,
		stackTick = function(state, current, time, ent)
			return 0, current
		end,
		img = "wave-crest",
		pos = {0, 5},
		minpts = 11,
		max = 1
	},
	synergy_3 = {
		name = "Synergy (Cold)",
		desc = "Every %s travelled or whenever damage would be taken from a mob, gain %+.2f stack(s) of Synergy. \z
		Each stack increases health and shield gained from skills and modifiers, and defence by 1%%, \z
		but stacks decay at a rate of -0.1%%/s regardless of skills. \z
		Distance travelled is computed by multiplying speed and time passed.",
		values = function(level)
			local distance = 8192
			if CLIENT then
				distance = InsaneStats:FormatNumber(distance, {distance = true})
			end
			return distance, level/20
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = current * .999 ^ time
			local newState = nextStacks <= 0 and 0 or 1

			if ent:InsaneStats_EffectivelyHasSkill("synergy_1") or ent:InsaneStats_EffectivelyHasSkill("synergy_2") then
				newState = -2
			end

			return newState, nextStacks
		end,
		img = "jigsaw-box",
		pos = {-5, 5},
		minpts = 10,
		max = 100
	},
	master_of_earth = {
		name = "Master of Earth",
		desc = "Double all poison damage dealt and halve all poison damage taken! \z
		All attacks have a +%u%% chance to deal poison damage against mobs, and deal +%u%% damage against non-mobs! \z
		Also, breaking a prop has a +%u%% chance to trigger all kill skills, except for Item Crates \z
		which instead are guaranteed to trigger all kill skills%s!",
		values = function(level, ent)
			return level * 25, level * 25, level * 25,
			level > 1 and " twice" or ""
		end,
		img = "stone-tablet",
		pos = {-5, 0},
		minpts = 11,
		max = 1
	},
	synergy_4 = {
		name = "Synergy (Dry)",
		desc = "On kill or whenever damage would be taken from a mob, gain %+.2f stack(s) of Synergy. \z
		Each stack increases damage dealt and defence by 1%%, \z
		but stacks decay at a rate of -0.1%%/s regardless of skills.",
		values = function(level)
			return level/20
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = current * .999 ^ time
			local newState = nextStacks <= 0 and 0 or 1

			if ent:InsaneStats_EffectivelyHasSkill("synergy_1") or ent:InsaneStats_EffectivelyHasSkill("synergy_2")
			or ent:InsaneStats_EffectivelyHasSkill("synergy_3") then
				newState = -2
			end

			return newState, nextStacks
		end,
		img = "jigsaw-box",
		pos = {-5, -5},
		minpts = 10,
		max = 100
	},
}

hook.Add("InsaneStatsSkillLoad", "InsaneStatsSkillsDefault", function(allSkills)
	local randomSeed = "insanestats_forge_name_for_"..game.GetMap()
	if util.SharedRandom(randomSeed, 0, 1) < 0.5 then
		skills.adamantite_forge.name = "Titanium Forge"
	end
    table.Merge(allSkills, skills)
end)

local statusEffects = {
	skill_bleed = {
		name = "Bleeding",
		typ = -1,
		img = "droplets",
		overtime = true,
	},
	charge = {
		name = "Charge!",
		typ = 2,
		img = "anthem"
	},
	killing_spree = {
		name = "Killing Spree",
		typ = 1,
		img = "skull-signet"
	},
	sick_combo = {
		name = "Sick Combo",
		typ = 1,
		img = "poker-hand"
	},
	anger_resist = {
		name = "Anger Grenade'd Cooldown",
		typ = 1,
		img = "time-bomb"
	},
	kill_skill_triggerer = {
		name = "Kill Skill Triggerer",
		typ = -1,
		img = "triple-skulls"
	},
	crit_damage_up = {
		name = "Critical Damage Up",
		typ = 1,
		img = "fast-arrow"
	},
	accuracy_up = {
		name = "Accuracy Up",
		typ = 1,
		img = "on-target"
	},
	absorption = {
		name = "Absorption",
		typ = 1,
		img = "rosa-shield"
	},
	knockback_up = {
		name = "Knockback Up",
		typ = 1,
		img = "boxing-glove-surprise"
	},
	knockback_resistance_up = {
		name = "Knockback Resistance Up",
		typ = 1,
		img = "breastplate"
	},
	crit_xp_up = {
		name = "Critical Loot Up",
		typ = 1,
		img = "william-tell-skull"
	},
	ammo_stealer = {
		name = "Ammo Stealer",
		typ = 1,
		img = "arrow-cluster"
	},
	pyrotheum = {
		name = "Stellar Node",
		typ = 0,
		img = "sun",
		overtime = true,
		expiry = SERVER and function(ent, level, attacker)
			SafeRemoveEntity(ent)
		end
	},
}

hook.Add("InsaneStatsLoadWPASS", "InsaneStatsSkillsDefault", function(currentModifiers, currentAttributes, currentStatusEffects)
	table.Merge(currentStatusEffects, statusEffects)
end)

hook.Add("InsaneStatsGetSkillTier", "InsaneStatsSkillsDefault", function(ent, skill)
	if skill ~= "you_all_get_a_car" and not ent:InsaneStats_IsSkillSealed(skill) and not InsaneStats:IsSkillDisabled(skill) then
		local highestLevel = ent:InsaneStats_GetSkillTier(skill)
		-- for k,v in pairs(InsaneStats:GetEntitiesWithSkills()) do
		-- FIXME: below only works because non-player entities can't get the you_all_get_a_car skill
		-- otherwise the line above needs to be used, with caching for maps containing 1000s of allies
		for i,v in player.Iterator() do
			--if not (k:IsPlayer() and k:KeyDown(IN_WALK)) then
			if not v:KeyDown(IN_WALK) and v:GetCreationTime() + 10 < CurTime() then
				local theirSkills = v:InsaneStats_GetSkills()
				local maxSkillLevel = v:InsaneStats_GetEffectiveSkillTier("you_all_get_a_car")
				local isAlly = SERVER and v:InsaneStats_IsValidAlly(ent) or ent:IsPlayer() and ent:Team() == v:Team()
				if maxSkillLevel > 0 and isAlly then
					highestLevel = math.max(highestLevel, math.min(v:InsaneStats_GetSkillTier(skill), maxSkillLevel))
					if SERVER then
						InsaneStats:SetEntityAsContainingSkills(ent)
					end
				end
			end
		end
		
		return highestLevel
	end
end)

hook.Add("InsaneStatsCannotSealSkill", "InsaneStatsSkillsDefault", function(skill)
	if skill == "skill_sealer" or InsaneStats:IsSkillDisabled(skill) then return true end
end)

--[[local neverSlowTick = {
	aint_got_time_for_this = true,
	scattershot = true
}

local alwaysSlowTick = {
	friendly_fire_off = true,
	skip_the_scenery = true,
	kill_aura = true,
	synergy_2 = true,
	synergy_3 = true,
	synergy_4 = true
}

hook.Add("InsaneStatsSkillDiffTime", "InsaneStatsSkillsDefault", function(data)
	if data.ent:InsaneStats_EffectivelyHasSkill("slow_spiral") then
		if not neverSlowTick[data.skill] and data.ent:InsaneStats_GetSkillData(data.skill).state == 1
		or alwaysSlowTick[data.skill] then
			data.diffTime = data.diffTime * (1 + data.ent:InsaneStats_GetEffectiveSkillValues("slow_spiral") / 100)
		end
	end
end)]]

hook.Add("InsaneStatsGetModifierProbabilities", "InsaneStatsSharedWPASS2", function(data)
	local ent = data.ent
	if (IsValid(ent) and ent:InsaneStats_EffectivelyHasSkill("adamantite_forge")) then
		data.negativeWeightMul = data.negativeWeightMul
		* (1 + ent:InsaneStats_GetEffectiveSkillValues("adamantite_forge")/100)
	end
end)