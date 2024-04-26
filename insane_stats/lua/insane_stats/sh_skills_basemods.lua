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
	four_parallel_universes_ahead = {
		name = "Four Parallel Universes Ahead",
		desc = "Damage taken is reduced based on velocity. At normal running velocity, damage taken is reduced by %.0f%%.",
		values = function(level)
			return level * -8
		end,
		img = "dodging",
		pos = {-1, 1},
		minpts = 5
	},
	dodger = {
		name = "Dodger",
		desc = "%+.0f%% dodge chance. Note that disintegrating damage can't be dodged.",
		values = function(level)
			return level * 5
		end,
		img = "journey",
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
		img = "arrow-scope",
		pos = {1, -2},
		minpts = 5
	},
	productivity = {
		name = "Productivity",
		desc = "%+.0f%% item pickups",
		values = function(level)
			return level * 20
		end,
		img = "cubeforce",
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
			return level * 10
		end,
		img = "cogsplosion",
		pos = {3, -1},
		minpts = 5
	},
	fortune = {
		name = "Fortune",
		desc = "%+.0f%% chance for a random item when a prop is broken",
		values = function(level)
			return level * 10
		end,
		img = "diamond-hard",
		pos = {3, 1},
		minpts = 5
	},
	why_is_it_called_kiting = {
		name = "Why is it Called Kiting?",
		desc = "Damage dealt is increased based on velocity. At normal running velocity, damage dealt is increased by %+.0f%%.",
		values = function(level)
			return level * 10
		end,
		img = "strafe",
		pos = {2, 2},
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
		pos = {1, 3},
		minpts = 5
	} or {
		name = "Stay Behind Me",
		desc = "All allies within 512 Hu regenerate %+.1f%% of their missing health per second.\n\z
		(This skill is completely different in singleplayer.)",
		values = function(level)
			return level/2.5
		end,
		img = "ghost-ally",
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
	medic_bag = {
		name = "Medic Bag",
		desc = "When you would receive damage, restore %+.0f%% of max health and max shield. \z
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
		pos = {-3, 1},
		minpts = 5
	},
	overheal = {
		name = "Overheal",
		desc = "On kill, restore %+.0f%% of max health. Health gained this way can exceed max health, but with diminishing returns.",
		values = function(level)
			return level
		end,
		img = "shining-heart",
		pos = {-3, -1},
		minpts = 5
	},
	kablooey = {
		name = "Kablooey!",
		desc = "%+.0f%% explosive damage dealt. Explosive hits towards enemies also restores %+.0f%% of max health.",
		values = function(level)
			return level * 10, level
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
		name = "Brilliant Behemoth",
		desc = "While %s is not held, all hits against entities cause explosions with %u Hu radii! Note that these explosions hurt ALL entities in range.",
		values = function(level)
			local slowWalkKey = "the Slow Walk key"
			if CLIENT then
				local keyName = input.LookupBinding("+walk")
				if keyName then
					slowWalkKey = keyName:upper()
				end
			end
			return slowWalkKey, level * 128
		end,
		stackTick = function(state, current, time, ent)
			return ent:IsPlayer() and ent:KeyDown(IN_WALK) and -1 or 1, current
		end,
		img = "explosive-materials",
		pos = {0, -3},
		minpts = 10,
		max = 1
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
		pos = {2, -3},
		minpts = 5
	},
	reuse = {
		name = "Reuse",
		desc = "%+.0f%% chance to not consume ammo",
		values = function(level)
			return level * 8
		end,
		img = "crystal-bars",
		pos = {3, -2},
		minpts = 5
	},
	friendly_fire_off = {
		name = "Friendly Fire OFF",
		desc = "While %s is not held, deal -100%% non-dissolving damage against allies%s",
		values = function(level)
			local slowWalkKey = "the Slow Walk key"
			if CLIENT then
				local keyName = input.LookupBinding("+walk")
				if keyName then
					slowWalkKey = keyName:upper()
				end
			end
			if level > 1 then
				return slowWalkKey, " and share most skills with them!"
			else
				return slowWalkKey, "!"
			end
		end,
		stackTick = function(state, current, time, ent)
			return ent:IsPlayer() and ent:KeyDown(IN_WALK) and -1 or 1, current
		end,
		img = "two-shadows",
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
	aint_got_time_for_this = game.SinglePlayer() and {
		name = "Ain't Got Time For This",
		desc = "While %s is held, gain %+.1f stack(s) of Ain't Got Time For This per second. \z
		Stacks are gained 1%% faster per stack, but stack gains are divided by game speed. \z
		Each stack increases defence and game speed by 1%%, but all stacks are lost when %s is released.\n\z
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
			local add = (state == 1 and time or 0)
			/ game.GetTimeScale()
			* ent:InsaneStats_GetSkillValues("aint_got_time_for_this", 2)
			* (1 + current/100)
			return state, current + add
		end,
		img = "clockwork",
		pos = {2, 3},
		minpts = 5
	} or {
		name = "Motivation",
		desc = "Gain +%u%% of XP from ally kills. All allies within 512 Hu regenerate health at a rate of %+.1f%%/s.\n\z
		(This skill is completely different in singleplayer.)",
		values = function(level)
			return level * 20, level/5
		end,
		img = "cheerful",
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
		stackTick = function(state, current, time, ent)
			local nextStacks = math.max(current - time, 0)
			return state < 0 and current <= 0 and 0 or state, nextStacks
		end,
		img = "domino-mask",
		pos = {0, 3},
		minpts = 10,
		max = 1
	},
	super_cold = game.SinglePlayer() and {
		name = "Super Cold",
		desc = "While not in a vehicle, game speed is reduced based on velocity. At normal running velocity, time takes %+.0f%% longer to pass.\n\z
		(This skill is completely different in multiplayer.)",
		values = function(level)
			return level * 10
		end,
		img = "ice-cube",
		pos = {-2, 3},
		minpts = 5
	} or {
		name = "Stick With The Team!",
		desc = "For each ally within 512 Hu, gain +%u%% coins, XP gain and damage dealt, \z
		as well as %i%% damage taken.\n\z
		(This skill is completely different in singleplayer.)",
		values = function(level)
			return level * 3, level * -3
		end,
		img = "telepathy",
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
		stackTick = function(state, current, time, ent)
			local nextStacks = math.max(current - time, 0)
			return state < 0 and current <= 0 and 0 or state, nextStacks
		end,
		img = "mesh-ball",
		pos = {-3, 0},
		minpts = 10,
		max = 1
	},
	overcharge = {
		name = "Overcharge",
		desc = "On kill, restore %+.0f%% of max shield. Shield gained this way can exceed max shield, but with diminishing returns.",
		values = function(level)
			return level
		end,
		img = "energise",
		pos = {-3, -2},
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
		pos = {-2, -3},
		minpts = 5
	},

	-- distance 6
	one_with_the_gun = {
		name = "One With The G.U.N.",
		desc = "Pistols and revolvers deal %+.0f%% damage and have %+.0f%% bullet spread.",
		values = function(level)
			return level * 20, math.max(level * -20, -100)
		end,
		img = "crossed-pistols",
		pos = {2, -4},
		minpts = 5
	},
	mania = {
		name = "Mania",
		desc = "On kill, gain %+.1f stack(s) of Mania. Each stack gives 1%% more coins and XP, but stacks decay at a rate of -0.1%%/s.",
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
			local val = InsaneStats:ScaleValueToLevelQuadratic(
				level/50,
				InsaneStats:GetConVarValue("xp_player_health")/100,
				InsaneStats:GetConVarValue("xp_enabled") and ent:InsaneStats_GetLevel() or 1,
				"xp_player_health_mode",
				false,
				InsaneStats:GetConVarValue("xp_player_health_add")/100
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

			local val = InsaneStats:ScaleValueToLevelQuadratic(
				level/50*baseMult,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_armor")/100,
				effectiveLevel,
				"xp_"..scaleType.."_armor_mode",
				false,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_armor_add")/100
			)
			return CLIENT and InsaneStats:FormatNumber(val), val
		end,
		img = "bordered-shield",
		pos = {4, 2},
		minpts = 5
	},
	jazz_feet = {
		name = "Jazz Feet",
		desc = "Gain more XP based on current velocity. At normal running velocity, XP gain is increased by %+.0f%%.",
		values = function(level)
			return level * 10
		end,
		img = "swan-breeze",
		pos = {3, 3},
		minpts = 5
	},
	aux_aux_battery = {
		name = "Aux Aux Battery",
		desc = "While at 100%% Aux Power, gain %+.0f%% more XP. Aux Power has a %+.0f%% chance of not being consumed.",
		values = function(level)
			return level * 5, level * 10
		end,
		img = "batteries",
		pos = {2, 4},
		minpts = 5
	},
	bloodletter_pact = {
		name = "Bloodletter's Pact",
		desc = "Health above %.1f%% is converted into shield. Shield gained this way can exceed max shield, but with diminishing returns.",
		values = function(level, ent)
			return 100 - level * 2 * (1 + ent:InsaneStats_GetSkillValues("bloodletters_revelation", 2) / 100)
		end,
		img = "bleeding-heart",
		pos = {-2, 4},
		minpts = 5
	},
	love_and_tolerate = {
		name = "Love And Tolerate",
		desc = "Whenever damage would be taken, gain %+.1f stack(s) of Love And Tolerate. Each stack gives 1%% more defence, but stacks decay at a rate of -0.1%%/s.",
		values = function(level)
			return level/5
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = current * .999 ^ time
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "arrows-shield",
		pos = {-3, 3},
		minpts = 5
	},
	absorption_shield = {
		name = "Absorption Shield",
		desc = "%+.0f%% non-dissolving damage absorption chance while shielded. Absorbed damage is converted into random ammunition.",
		values = function(level)
			return level * 5
		end,
		img = "rosa-shield",
		pos = {-4, 2},
		minpts = 5
	},
	impenetrable_shield = {
		name = "Impenetrable Shield",
		desc = "Shield blocks 100%% of damage instead of 80%%, and damage taken is reduced by %+.0f%% while shielded.",
		values = function(level, ent)
			return level * -8
		end,
		img = "crenulated-shield",
		pos = {-4, -2},
		minpts = 5
	},
	more_bullet_per_bullet = {
		name = "More Bullet Per Bullet",
		desc = "Reserve ammo above %u%% is converted into More Bullet Per Bullet stacks. \z
		Each stack increases defence and damage dealt by 1%%, but stacks are capped to a maximum of +%u \z
		and decay at a rate of -0.1%%/s.",
		values = function(level)
			return 100 - level * 5, level * 200
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = current * .999 ^ time
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "implosion",
		pos = {-3, -3},
		minpts = 5
	},
	silver_bullets = {
		name = "Silver Bullets",
		desc = "Fired bullets deal %+.0f%% damage, have a %+.0f%% chance to be doubled and have %+.0f%% spread.",
		values = function(level)
			return level * 5, level * 5, level * -5
		end,
		img = "supersonic-bullet",
		pos = {-2, -4},
		minpts = 5
	},

	-- distance 7
	the_red_plague = {
		name = "The Red Plague",
		desc = "On hit, inflict Bleeding for %u seconds on the victim, triggering on-hit effects over time!",
		values = function(level)
			return level * 5
		end,
		img = "droplets",
		pos = {1, -4},
		minpts = 10,
		max = 1
	},
	instant_karma = {
		name = "Instant Karma",
		desc = "Whenever damage would be taken, there is a %+.0f%% chance to deal %s BASE damage back!",
		values = function(level, ent)
			local val = 40 * InsaneStats:DetermineDamageMulPure(
				ent, game.GetWorld()
			)
			return level * 10, CLIENT and InsaneStats:FormatNumber(val)
		end,
		img = "shield-reflect",
		pos = {3, -4},
		minpts = 5
	},
	multi_killer = {
		name = "Multi Killer",
		desc = "For every NPC killed or prop broken within 1 second, gain up to %+.0f%% more coins and XP! "
		..(game.SinglePlayer() and "Time also takes longer to pass," or "Damage dealt is also increased")
		.." by the square root of the amount.\n(This skill is slightly different in "
		..(game.SinglePlayer() and "multiplayer" or "singleplayer")
		..".)",
		values = function(level)
			return level * 50
		end,
		img = "double-shot",
		pos = {4, -3},
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
		img = "winged-shield",
		pos = {4, 1},
		minpts = 10,
		max = 1
	},
	better_than_ever = {
		name = "Better Than Ever",
		desc = "Health Kits increase max health by +%s, and Armor Batteries increase max armor by +%s!",
		values = function(level, ent)
			local scaleType = ent:IsPlayer() and "player" or "other"
			local baseMult = ent:IsPlayer() and 1 or InsaneStats:GetConVarValue("infhealth_armor_mul")
			local effectiveLevel = InsaneStats:GetConVarValue("xp_enabled") and ent:InsaneStats_GetLevel() or 1

			local value1 = InsaneStats:ScaleValueToLevelQuadratic(
				level/100,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_health")/100,
				effectiveLevel,
				"xp_"..scaleType.."_health_mode",
				false,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_health_add")/100
			)
			local value2 = InsaneStats:ScaleValueToLevelQuadratic(
				level/100*baseMult,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_armor")/100,
				effectiveLevel,
				"xp_"..scaleType.."_armor_mode",
				false,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_armor_add")/100
			)

			return CLIENT and InsaneStats:FormatNumber(value1), CLIENT and InsaneStats:FormatNumber(value2),
			value1, value2
		end,
		img = "flowers",
		pos = {4, 3},
		minpts = 5
	},
	item_magnet = {
		name = "Item Magnet",
		desc = "Items and weapons wtihin +%u Hu are magnetized! Also automatically pick up coins that are furthest from any other player after %u seconds.",
		values = function(level, ent)
			return level * 256, 20 - level * 2
		end,
		img = "magnet",
		pos = {3, 4},
		minpts = 5
	},
	map_sense = {
		name = "Map Sense",
		desc = "See all buttons, doors and breakable brushes within +%u Hu!",
		values = function(level)
			return level * 512
		end,
		img = "world",
		pos = {1, 4},
		minpts = 10,
		max = 1
	},
	just_breathe = game.SinglePlayer() and {
		name = "Just Breathe",
		desc = "Double tap %s to reduce game speed by %i%% and increase movement rate by +%u%% for 10 seconds! 60 seconds cooldown.\n\z
		(This skill is completely different in multiplayer.)",
		values = function(level)
			local slowWalkKey = "the Slow Walk key"
			if CLIENT then
				local keyName = input.LookupBinding("+walk")
				if keyName then
					slowWalkKey = keyName:upper()
				end
			end
			return slowWalkKey, -25 - level * 25, -100 + level * 200
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = math.max(current - time, 0)
			return state < 0 and current <= 0 and 0 or state, nextStacks
		end,
		img = "sands-of-time",
		pos = {-1, 4},
		minpts = 10,
		max = 1
	} or {
		name = "Charge!",
		desc = "Double tap %s to increase damage dealt by %u%% and reduce damage taken by %i%% for ALL allies for 10 seconds! 60 seconds cooldown.\n\z
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
		stackTick = function(state, current, time, ent)
			local nextStacks = math.max(current - time, 0)
			return state < 0 and current <= 0 and 0 or state, nextStacks
		end,
		img = "anthem",
		pos = {-1, 4},
		minpts = 10,
		max = 1
	},
	bloodletters_revelation = {
		name = "Bloodletter's Revelation",
		desc = "Gain up to %+.0f%% movement speed at high health. The Bloodletter's Pact skill is also %+.0f%% more effective.",
		values = function(level)
			return level * 8, level * 20
		end,
		img = "dripping-goo",
		pos = {-3, 4},
		minpts = 5
	},
	starlight = {
		name = "Starlight",
		desc = "On kill, gain %+.0f stacks of Starlight. Each stack increases defence by 1%% but also causes glowing by 4 Hu. Stacks have a maximum limit of 1,000 and decay at a rate of 1/s.",
		values = function(level)
			return level * 2
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = math.max(current - time, 0)
			return nextStacks <= 0 and 0 or 1, nextStacks
		end,
		img = "sundial",
		pos = {-4, 3},
		minpts = 5
	},
	fight_for_your_life = {
		name = "Fight For Your Life",
		desc = "Whenever lethal damage would be taken, instead become prone. \z
		Killing an enemy while prone grants a Second Wind, restoring 100%% of health!\n\z
		All damage is negated while prone, but you die after proning for %u seconds. \z
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
		desc = "Levelling up increases max health and max shield by +%s and +%s, respectively, \z
		per skill point gained in total! Additionally, levelling up also restores 100%% of health and shield! \z
		Health and shield gained this way can exceed max health and max shield, \z
		but with diminishing returns.",
		values = function(level, ent)
			local scaleType = ent:IsPlayer() and "player" or "other"
			local baseMult = ent:IsPlayer() and 1 or InsaneStats:GetConVarValue("infhealth_armor_mul")
			local effectiveLevel = InsaneStats:GetConVarValue("xp_enabled") and ent:InsaneStats_GetLevel() or 1

			local value1 = InsaneStats:ScaleValueToLevel(
				level,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_health")/100,
				effectiveLevel,
				"xp_"..scaleType.."_health_mode",
				false
			)
			local value2 = InsaneStats:ScaleValueToLevel(
				level*baseMult,
				InsaneStats:GetConVarValue("xp_"..scaleType.."_armor")/100,
				effectiveLevel,
				"xp_"..scaleType.."_armor_mode",
				false
			)

			return CLIENT and InsaneStats:FormatNumber(value1), CLIENT and InsaneStats:FormatNumber(value2), value1, value2
		end,
		img = "deadly-strike",
		pos = {-4, -1},
		minpts = 10,
		max = 1
	},
	desperate_harvest = {
		name = "Desperate Harvest",
		desc = "At low health, critical hits restore up to %+.0f%% of health.",
		values = function(level)
			return level
		end,
		img = "bird-claw",
		pos = {-4, -3},
		minpts = 5
	},
	shield_shell_shots = {
		name = "Shield Shell Shots",
		desc = "While at 100%% shield and above, all BASE damage dealt is increased by %s, but results in %.1f%% of shield loss! \z
		Having more shield will reduce the shield consumption of this skill.",
		values = function(level, ent)
			local value = 40 * InsaneStats:DetermineDamageMulPure(
				ent, game.GetWorld()
			)
			return CLIENT and InsaneStats:FormatNumber(value), math.min(level/2.5 - 2.4, 0)
		end,
		img = "shield-bounces",
		pos = {-3, -4},
		minpts = 5
	},
	anger = {
		name = "Anger",
		desc = "Taking damage from an NPC doubles all damage dealt for %u seconds! 60 seconds cooldown.",
		values = function(level)
			return level * 10
		end,
		stackTick = function(state, current, time, ent)
			local nextStacks = math.max(current - time, 0)
			return state < 0 and current <= 0 and 0 or state, nextStacks
		end,
		img = "snake-bite",
		pos = {-1, -4},
		minpts = 10,
		max = 1
	},

	-- distance 8+
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
	aimbot = {
		name = "Aimbot",
		desc = "Fired bullets have %+.0f%% chance of being redirected to enemy critical hit spots! \z
		These bullets can still miss if the bullet spread is too high. \z
		Additionally, non-bullet damage has a %+.0f%% chance to critically hit.",
		values = function(level)
			return level * 8, level * 8
		end,
		img = "microscope-lens",
		pos = {4, -4},
		minpts = 5
	},
	when_the_sigma_grind_aint_enough = {
		name = "When The Sigma Grind Ain't Enough",
		desc = "Every %u skill points gained, gain a über skill point! Über skill points can double the level of skills, but can only be spent on fully upgraded skills!",
		values = function(level)
			return 30 - level*10
		end,
		img = "star-swirl",
		pos = {4, 0},
		minpts = 2,
		max = 1
	},
	mantreads = {
		name = "Mantreads",
		desc = "Negate all fall damage! All fall damage that would be received is instead doubled +%u time(s), then dealt to all other entities within 256 Hu.",
		values = function(level)
			return level
		end,
		img = "quake-stomp",
		pos = {4, 4},
		minpts = 5
	},
	celebration = {
		name = "Celebration",
		desc = "All kill skills are triggered%s by non-player kills from ANY entity!",
		values = function(level)
			if level > 1 then
				return " twice"
			else
				return ""
			end
		end,
		img = "celebration-fire",
		pos = {0, 4},
		minpts = 2,
		max = 1
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
	blast_proof_suit = {
		name = "Blast-Proof Suit",
		desc = "%+.0f%% explosive damage taken!%s",
		values = function(level)
			if level <= 5 then
				return level * -20, ""
			else
				return -100, " Taking explosive damage also restores +1% of max health."
			end
		end,
		img = "robot-golem",
		pos = {-4, -4},
		minpts = 5
	}
}

hook.Add("InsaneStatsSkillLoad", "InsaneStatsSkillsDefault", function(allSkills)
    table.Merge(allSkills, skills)
end)

local statusEffects = {
	skill_bleed = {
		name = "Bleeding",
		typ = -1,
		img = "droplets"
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
	multi_killer = {
		name = "Multi Killer",
		typ = 1,
		img = "double-shot"
	},

	skill_damage_up = {
		name = "Damage Up",
		typ = 1,
		img = "pointy-sword"
	},
	skill_crit_damage_up = {
		name = "Critical Damage Up",
		typ = 1,
		img = "fast-arrow"
	},
	skill_firerate_up = {
		name = "Fire Rate Up",
		typ = 1,
		img = "striking-arrows"
	},
	skill_accuracy_up = {
		name = "Accuracy Up",
		typ = 1,
		img = "on-target"
	},

	skill_defence_up = {
		name = "Defence Up",
		typ = 1,
		img = "checked-shield"
	},
	skill_regen = {
		name = "Regeneration",
		typ = 1,
		img = "heart-bottle"
	},
	skill_armor_regen = {
		name = "Armor Regeneration",
		typ = 1,
		img = "bolt-shield"
	},
	skill_absorption = {
		name = "Absorption",
		typ = 1,
		img = "rosa-shield"
	},

	skill_knockback_resistance_up = {
		name = "Knockback Resistance Up",
		typ = 1,
		img = "breastplate"
	},

	skill_xp_up = {
		name = "Loot Up",
		typ = 1,
		img = "cool-spices"
	},
	skill_crit_xp_up = {
		name = "Critical Loot Up",
		typ = 1,
		img = "william-tell-skull"
	},
	skill_ammo_efficiency_up = {
		name = "Ammo Efficiency Up",
		typ = 1,
		img = "crystal-bars"
	},
}

hook.Add("InsaneStatsLoadWPASS", "InsaneStatsSkillsDefault", function(currentModifiers, currentAttributes, currentStatusEffects)
	table.Merge(currentStatusEffects, statusEffects)
end)

hook.Add("InsaneStatsGetSkillTier", "InsaneStatsSkillsDefault", function(ent, skill)
	if SERVER and skill ~= "friendly_fire_off" then
		local highestLevel = ent:InsaneStats_GetSkills()[skill] or 0
		for k,v in pairs(InsaneStats:GetEntitiesWithSkills()) do
			if not (k:IsPlayer() and k:KeyDown(IN_WALK)) then
				local theirSkills = k:InsaneStats_GetSkills()
				if (theirSkills.friendly_fire_off or 0) > 1 and k:InsaneStats_IsValidAlly(ent) then
					highestLevel = math.max(highestLevel, theirSkills[skill] or 0)
					InsaneStats:SetEntityAsContainingSkills(ent)
				end
			end
		end
		return highestLevel
	end
end)