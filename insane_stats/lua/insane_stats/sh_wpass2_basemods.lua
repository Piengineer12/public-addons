local modifiers = {
	-- damage
	strong = {
		prefix = "Strong",
		suffix = "Strength",
		modifiers = {
			damage = 1.1
		}
	},
	rapid = {
		prefix = "Rapid",
		suffix = "Rapidity",
		modifiers = {
			firerate = 1.1
		},
		max = 10
	},
	force = {
		prefix = "Forceful",
		suffix = "Forcefulness",
		modifiers = {
			knockback = 1.4641
		},
		max = 10
	},
	split = {
		prefix = "Splitting",
		modifiers = {
			bullets = 1.1,
			nonbullet_damage = 1.1
		},
		max = 10
	},
	adept = {
		prefix = "Adept",
		suffix = "Adeptivity",
		modifiers = {
			spread = 1/1.21,
			nonbullet_damage = 1.1
		},
		max = 10
	},
	inspire = {
		prefix = "Inspiring",
		suffix = "Inspiration",
		modifiers = {
			xp = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.XP
	},
	explode = {
		prefix = "Explosive",
		suffix = "Explosions",
		modifiers = {
			explode = 1.1
		},
		max = 7
	},
	earth = {
		prefix = "Earthen",
		suffix = "Earth",
		modifiers = {
			poison = 1.1
		},
		max = 7
	},
	fire = {
		prefix = "Firey",
		suffix = "Fire",
		modifiers = {
			fire = 1.1
		},
		max = 7
	},
	water = {
		prefix = "Watery",
		suffix = "Water",
		modifiers = {
			freeze = 1.1
		},
		max = 7
	},
	air = {
		prefix = "Airy",
		suffix = "Air",
		modifiers = {
			shock = 1.1
		},
		max = 7
	},
	blood = {
		prefix = "Bloody",
		suffix = "Blood",
		modifiers = {
			bleed = 1.1
		},
		max = 7
	},
	perserve = {
		prefix = "Perserving",
		modifiers = {
			ammo_savechance = 1/1.21,
			melee_damage = 1.1
		},
		max = 10
	},
	
	-- damage, half weight
	luck = {
		prefix = "Lucky",
		suffix = "Luck",
		modifiers = {
			crit_chance = 1.1
		},
		weight = 0.5,
		max = 7
	},
	ranged = {
		prefix = "Ranged",
		suffix = "Range",
		modifiers = {
			longrange_damage = 1.21,
			melee_damage = 1.1
		},
		weight = 0.5
	},
	derange = {
		prefix = "Deranged",
		suffix = "Derangement",
		modifiers = {
			shortrange_damage = 1.21,
			melee_damage = 1/1.1
		},
		weight = 0.5
	},
	arc = {
		prefix = "Arcing",
		modifiers = {
			arc_chance = 1/1.1
		},
		weight = 0.5
	},
	anger = {
		prefix = "Angry",
		suffix = "Anger",
		modifiers = {
			lowhealth_damage = 1.1
		},
		weight = 0.5
	},
	death = {
		prefix = "Deadly",
		suffix = "Death",
		modifiers = {
			lowhealth_victim_damage = 1.1
		},
		weight = 0.5
	},
	keen = {
		prefix = "Keen",
		suffix = "Keenness",
		modifiers = {
			high90health_victim_damage = 1.1
		},
		weight = 0.5
	},
	execution = {
		prefix = "Executing",
		suffix = "Execution",
		modifiers = {
			lowxhealth_victim_doubledamage = 1.1
		},
		weight = 0.5,
		max = 7
	},
	doom = {
		prefix = "Dooming",
		suffix = "Doom",
		modifiers = {
			repeat1s_damage = 1.1
		},
		weight = 0.5
	},
	--[[chain = {
		prefix = "Chaining",
		modifiers = {
			kill5s_damage = 1.1,
			kill5s_speed = 1.1
		},
		weight = 0.5,
		max = 12
	},
	hold = {
		prefix = "Holding",
		modifiers = {
			clip = 1.21,
			lastammo_damage = 1.1
		},
		max = 10,
		weight = 0.5,
		flags = InsaneStats.WPASS2_FLAGS.SCRIPTED_ONLY
	},]]
	murderous = {
		prefix = "Murderous",
		suffix = "Murder",
		modifiers = {
			kill5s_damage = 1.1
		},
		weight = 0.5
	},
	frenzy = {
		prefix = "Frenzied",
		suffix = "Frenzying",
		modifiers = {
			kill5s_firerate = 1.1
		},
		weight = 0.5,
		max = 10
	},
	kinetic = {
		prefix = "Kinetic",
		suffix = "Kinesis",
		modifiers = {
			speed_damage = 1.1
		},
		weight = 0.5
	},
	amplify = {
		prefix = "Amplifying",
		modifiers = {
			amp_armorloss = 1/1.1,
			amp_damage = 1.21
		},
		weight = 0.5,
	},
	bloodbath = {
		prefix = "Bloodbathing",
		modifiers = {
			lifesteal = 0.2
		},
		weight = 0.5
	},
	heal = {
		prefix = "Healing",
		modifiers = {
			kill_lifesteal = 1
		},
		weight = 0.5
	},
	rejuvenate = {
		prefix = "Rejuvenating",
		suffix = "Rejuvenation",
		modifiers = {
			kill5s_regen = 0.25
		},
		weight = 0.5
	},
	charge = {
		prefix = "Charging",
		modifiers = {
			kill_armorsteal = 1
		},
		weight = 0.5
	},
	build = {
		prefix = "Building",
		modifiers = {
			kill5s_armorregen = 0.25
		},
		weight = 0.5
	},
	unpleasant = {
		prefix = "Unpleasant",
		suffix = "Unpleasantness",
		modifiers = {
			hit10s_damage = 1.1,
		},
		weight = 0.5,
		max = 10
	},
	hurt = {
		prefix = "Hurtful",
		suffix = "Hurt",
		modifiers = {
			perhit_victim_damagetaken = 1.1
		},
		weight = 0.5,
	},
	godly = {
		prefix = "Godly",
		suffix = "Godliness",
		modifiers = {
			hit100_damage = 1.1
		},
		weight = 0.5,
	},
	--[[menace = {
		prefix = "Menacing",
		modifiers = {
			kill_victim_damage = 1/1.1
			kill_victim_firerate = 1/1.1
		},
		weight = 0.5,
	},]]
	savage = {
		prefix = "Savage",
		suffix = "Savageness",
		modifiers = {
			combat5s_damage = 1.1,
		},
		weight = 0.5,
	},
	gatling = {
		prefix = "Gatling",
		modifiers = {
			combat5s_firerate = 1.1,
		},
		weight = 0.5,
		max = 10
	},
	lethargic = {
		prefix = "Lethargic",
		suffix = "Lethargy",
		modifiers = {
			victim_speed = 1/1.1
		},
		weight = 0.5,
		max = 10
	},
	wound = {
		prefix = "Wounding",
		modifiers = {
			victim_damagetaken = 1.1
		},
		weight = 0.5
	},
	demon = {
		prefix = "Demonic",
		suffix = "Demons",
		modifiers = {
			victim_damage = 1/1.1
		},
		max = 10,
		weight = 0.5
	},
	intimidate = {
		prefix = "Intimidating",
		suffix = "Intimidation",
		modifiers = {
			victim_firerate = 1/1.1
		},
		weight = 0.5,
		max = 10
	},
	empower = {
		prefix = "Empowering",
		modifiers = {
			killstack_damage = 1.1
		},
		weight = 0.5
	},
	nimble = {
		prefix = "Nimble",
		suffix = "Nimbility",
		modifiers = {
			killstack_firerate = 1.1
		},
		weight = 0.5
	},
	manic = {
		prefix = "Manic",
		suffix = "Mania",
		modifiers = {
			killstack_xp = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.XP,
		weight = 0.5
	},
	ruthless = {
		prefix = "Ruthless",
		suffix = "Ruthlessness",
		modifiers = {
			hit3_damage = 1.1
		},
		weight = 0.5
	},
	practical = {
		prefix = "Practical",
		suffix = "Practicality",
		modifiers = {
			prop_xp = 1.1
		},
		weight = 0.5,
		max = 10,
		flags = InsaneStats.WPASS2_FLAGS.XP
	},
	wild = {
		prefix = "Wild",
		suffix = "Wilderness",
		modifiers = {
			kill_clipsteal = 0.1,
			melee_damage = 1.1
		},
		weight = 0.5,
		max = 10
	},
	unreal = {
		prefix = "Unreal",
		suffix = "Unreality",
		modifiers = {
			aimbot = 1.1,
			nonbullet_damage = 1.1
		},
		weight = 0.5,
		max = 7
	},
	mystic = {
		prefix = "Mystic",
		suffix = "Mysticality",
		modifiers = {
			hit10s_firerate = 1.1
		},
		weight = 0.5,
		max = 10
	},
	intense = {
		prefix = "Intense",
		suffix = "Intensity",
		modifiers = {
			hitstack_damage = 1.1
		},
		weight = 0.5
	},
	celestial = {
		prefix = "Celestial",
		suffix = "Celestiality",
		modifiers = {
			kill5s_damageaura = 1.1
		},
		weight = 0.5
	},
	
	-- damage, half weight doubled cost
	heavy = {
		prefix = "Heavy",
		suffix = "Heaviness",
		modifiers = {
			speed = 1/1.1,
			damage = 1.331,
		},
		weight = 0.5,
		max = 10,
		cost = 2
	},
	sniper = {
		prefix = "Sniping",
		modifiers = {
			firerate = 1/1.1,
			spread = 1/1.21,
			nonbullet_damage = 1.1,
			longrange_damage = 1.21,
			melee_damage = 1.21
		},
		weight = 0.5,
		max = 10,
		cost = 2
	},
	shotgun = {
		prefix = "Shotgunning",
		modifiers = {
			spread = 1.21,
			bullets = 1.331,
			shortrange_nonbullet_damage = 1.21,
		},
		weight = 0.5,
		max = 5,
		cost = 2
	},
	weak = {
		prefix = "Weak",
		suffix = "Weakness",
		modifiers = {
			knockback = 1/1.4641,
			damage = 1.331
		},
		weight = 0.5,
		max = 10,
		cost = 2
	},
	dull = {
		prefix = "Dull",
		suffix = "Dullness",
		modifiers = {
			damage = 1/1.1,
			firerate = 1.331
		},
		weight = 0.5,
		max = 5,
		cost = 2
	},
	annoy = {
		prefix = "Annoying",
		suffix = "Annoyance",
		modifiers = {
			damage = 1/1.1,
			knockback = 1.4641,
			firerate = 1.21
		},
		weight = 0.5,
		max = 5,
		cost = 2
	},
	curse = {
		prefix = "Cursed",
		suffix = "Curses",
		modifiers = {
			bullets = 1/1.1,
			nonbullet_misschance = 1/1.1,
			damage = 1.331
		},
		weight = 0.5,
		max = 5,
		cost = 2
	},
	shoddy = {
		prefix = "Shoddy",
		suffix = "Shoddiness",
		modifiers = {
			misschance = 1/1.1,
			damage = 1.331
		},
		weight = 0.5,
		max = 5,
		cost = 2
	},
	power = {
		prefix = "Powerful",
		suffix = "Power",
		modifiers = {
			firerate = 1/1.1,
			damage = 1.331
		},
		weight = 0.5,
		max = 10,
		cost = 2
	},
	zealous = {
		prefix = "Zealous",
		suffix = "Zealousness",
		modifiers = {
			spread = 1.21,
			nonbullet_damage = 1/1.1,
			damage = 1.331
		},
		weight = 0.5,
		max = 10,
		cost = 2
	},
	conscious = {
		prefix = "Conscious",
		suffix = "Consciousness",
		modifiers = {
			xp = 1.331,
			ally_xp = -1
		},
		weight = 0.5,
		cost = 2,
		flags = InsaneStats.WPASS2_FLAGS.XP
	},
	broken = {
		prefix = "Broken",
		suffix = "Breaking",
		modifiers = {
			damage = 1.21,
			random_damage = -0.2
		},
		weight = 0.5,
		max = 5,
		cost = 2
	},
	sluggish = {
		prefix = "Sluggish",
		suffix = "Sluggishness",
		modifiers = {
			firerate = 1/1.1,
			combat5s_damage = 1.331
		},
		weight = 0.5,
		max = 5,
		cost = 2
	},
	lazy = {
		prefix = "Lazy",
		suffix = "Laziness",
		modifiers = {
			damage = 1/1.1,
			combat5s_firerate = 1.331,
		},
		weight = 0.5,
		max = 5,
		cost = 2
	},
	shame = {
		prefix = "Shameful",
		suffix = "Shame",
		modifiers = {
			damage = 1.331,
			kill5s_ally_damage = 1/1.1
		},
		weight = 0.5,
		max = 2,
		cost = 2
	},
	terrible = {
		prefix = "Terrible",
		suffix = "Terribleness",
		modifiers = {
			evenlevel_damage = 1.331,
			oddlevel_damage = 1/1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.XP,
		weight = 0.5,
		cost = 2
	},
	danger = {
		prefix = "Dangerous",
		suffix = "Danger",
		modifiers = {
			damage = 1.331,
			hit100_self_damage = 1.1
		},
		weight = 0.5,
		cost = 2
	},
	awkward = {
		prefix = "Awkward",
		suffix = "Awkwardness",
		modifiers = {
			damage = 1.331,
			spread = 1.21,
			nonbullet_damage = 1/1.1
		},
		weight = 0.5,
		cost = 2
	},
	taboo = {
		prefix = "Taboo",
		suffix = "Tabooness",
		modifiers = {
			oddlevel_damage = 1.331,
			evenlevel_damage = 1/1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.XP,
		weight = 0.5,
		cost = 2
	},
	
	-- damage inaccessible
	frostfire = {
		prefix = "Frostfirey",
		suffix = "Frostfire",
		modifiers = {
			frostfire = 1.1^(1/3),
			fire_damage = 1.1^(1/3),
			freeze_damage = 1.1^(1/3),
		},
		merge = {
			"fire", "water"
		},
		flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.SCRIPTED_ONLY),
		max = 21
	},
	electroblast = {
		prefix = "Electroblasting",
		modifiers = {
			electroblast = 1.1^(1/3),
			shock_damage = 1.1^(1/3),
			explode_damage = 1.1^(1/3),
		},
		merge = {
			"explode", "air"
		},
		flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.SCRIPTED_ONLY),
		max = 21
	},
	hemotoxic = {
		prefix = "Hemotoxic",
		suffix = "Hemotoxicity",
		modifiers = {
			hemotoxic = 1.1^(1/3),
			poison_damage = 1.1^(1/3),
			bleed_damage = 1.1^(1/3),
		},
		merge = {
			"earth", "blood"
		},
		flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.SCRIPTED_ONLY),
		max = 21
	},
	cosmicurse = {
		prefix = "Cosmicursing",
		modifiers = {
			cosmicurse = 1.1
		},
		merge = {
			"frostfire", "electroblast", "hemotoxic"
		},
		flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.SCRIPTED_ONLY),
	},
	
	-- utility
	speed = {
		prefix = "Speedy",
		suffix = "Speed",
		modifiers = {
			speed = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		max = 12
	},
	supplying = {
		prefix = "Supplying",
		modifiers = {
			supplying = 1.21
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		max = 10
	},
	precise = {
		prefix = "Precise",
		suffix = "Precision",
		modifiers = {
			crit_damage = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR
	},
	
	-- utility, half weight
	volatile = {
		prefix = "Volatile",
		suffix = "Volatility",
		modifiers = {
			explode_damage = 1.331,
			explode_damagetaken = 1/1.331
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5
	},
	pyro = {
		prefix = "Pyrogenic",
		suffix = "Pyromancy",
		modifiers = {
			fire_damage = 1.331,
			fire_damagetaken = 1/1.331
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5
	},
	cryo = {
		prefix = "Cryogenic",
		suffix = "Cryomancy",
		modifiers = {
			freeze_damage = 1.331,
			freeze_damagetaken = 1/1.331
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5
	},
	geo = {
		prefix = "Geologic",
		suffix = "Geomancy",
		modifiers = {
			poison_damage = 1.331,
			poison_damagetaken = 1/1.331
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5
	},
	electro = {
		prefix = "Electronic",
		suffix = "Electromancy",
		modifiers = {
			shock_damage = 1.331,
			shock_damagetaken = 1/1.331
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5
	},
	jagged = {
		prefix = "Jagged",
		suffix = "Jaggedness",
		modifiers = {
			bleed_damage = 1.331,
			bleed_damagetaken = 1/1.331
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5
	},
	violent = {
		prefix = "Violent",
		suffix = "Violence",
		modifiers = {
			perdebuff_damage = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5
	},
	brisk = {
		prefix = "Brisk",
		suffix = "Brisking",
		modifiers = {
			noncombat_speed = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		max = 10
	},
	quick = {
		prefix = "Quick",
		suffix = "Quickness",
		modifiers = {
			sprint_speed = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		max = 10
	},
	buckle = {
		prefix = "Buckling",
		modifiers = {
			speed_damagetaken = 1/1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		max = 5
	},
	rash = {
		prefix = "Rash",
		suffix = "Rashness",
		modifiers = {
			debuff_damage = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5
	},
	nasty = {
		prefix = "Nasty",
		suffix = "Nastiness",
		modifiers = {
			alt_damage = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5
	},
	haste = {
		prefix = "Hasty",
		suffix = "Hastiness",
		modifiers = {
			alt_firerate = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		max = 10
	},
	agile = {
		prefix = "Agile",
		suffix = "Agility",
		modifiers = {
			alt_speed = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		max = 10
	},
	acknowledge = {
		prefix = "Acknowledging",
		suffix = "Acknowledgement",
		modifiers = {
			else_xp = 1.1
		},
		flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.XP),
		weight = 0.5,
		max = 7
	},
	cloaking = {
		prefix = "Cloaking",
		modifiers = {
			alt_invisible = 1.21
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		max = 10
	},
	spike = {
		prefix = "Spiked",
		suffix = "Spikyness",
		modifiers = {
			retaliation10_damage = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
	},
	arcane = {
		prefix = "Arcane",
		suffix = "Arcanity",
		modifiers = {
			toggle_damage = 1.1
		},
		weight = 0.5,
		flags = InsaneStats.WPASS2_FLAGS.ARMOR
	},
	point = {
		prefix = "Pointy",
		suffix = "Pointiness",
		modifiers = {
			lowhealth_victim_melee_damage = 1.1
		},
		weight = 0.5,
		flags = InsaneStats.WPASS2_FLAGS.ARMOR
	},
	staunch = {
		prefix = "Staunch",
		suffix = "Staunchiness",
		modifiers = {
			crit_xp = 1.1
		},
		weight = 0.5,
		flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.XP)
	},
	master = {
		prefix = "Masterful",
		suffix = "Mastery",
		modifiers = {
			simul_xp = 1.1
		},
		weight = 0.5,
		flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.XP)
	},
	fury = {
		prefix = "Furious",
		suffix = "Fury",
		modifiers = {
			hittaken_damage = 1.1
		},
		weight = 0.5,
		flags = InsaneStats.WPASS2_FLAGS.ARMOR
	},
	empathy = {
		prefix = "Empathetic",
		suffix = "Empathy",
		modifiers = {
			ally_damage = 0
		},
		weight = 0.5,
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		max = 1
	},
	
	-- utility, half weight doubled cost
	aggravate = {
		prefix = "Aggravating",
		suffix = "Aggravation",
		modifiers = {
			damagetaken = 1.1,
			damage = 1.331,
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		cost = 2
	},
	light = {
		prefix = "Light",
		suffix = "Lightness",
		modifiers = {
			damagetaken = 1.1,
			speed = 1.331
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		cost = 2,
		max = 4
	},
	jump = {
		prefix = "Jumpy",
		suffix = "Jumping",
		modifiers = {
			jumps = 1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		cost = 2,
		max = 10
	},
	superior = {
		prefix = "Superior",
		suffix = "Superiority",
		modifiers = {
			highlevel_damage = 1.331,
			lowlevel_damagetaken = 1.1
		},
		weight = 0.5,
		cost = 2,
		flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.XP)
	},
	damaged = {
		prefix = "Damaged",
		suffix = "Damagedness",
		modifiers = {
			damage = 1.331,
			damagetaken = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		cost = 2
	},
	sight = {
		prefix = "Sighted",
		suffix = "Sight",
		modifiers = {
			mark = 2,
			mark_damage = 1.1,
			mark_damagetaken = 1/1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		cost = 2
	},
	glass = {
		prefix = "Glass",
		modifiers = {
			health = 1/1.1,
			armor = 1/1.1,
			damage = 1.331
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		cost = 2
	},
	
	-- defensive
	defend = {
		prefix = "Defensive",
		suffix = "Defending",
		modifiers = {
			damagetaken = 1/1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR
	},
	immove = {
		prefix = "Immovable",
		suffix = "Immoving",
		modifiers = {
			knockbacktaken = 1/1.4641,
			self_knockbacktaken = 1.4641,
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		max = 5
	},
	bulk = {
		prefix = "Bulky",
		suffix = "Bulkiness",
		modifiers = {
			crit_damagetaken = 1/1.1
		},
		max = 5,
		flags = InsaneStats.WPASS2_FLAGS.ARMOR
	},
	health = {
		prefix = "Healthy",
		suffix = "Health",
		modifiers = {
			health = 1.21
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR
	},
	armor = {
		prefix = "Armored",
		suffix = "Armoring",
		modifiers = {
			armor = 1.21
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR
	},
	
	-- defensive, half weight
	dodge = {
		prefix = "Dodgy",
		suffix = "Dodging",
		modifiers = {
			dodge = 1/1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		max = 5
	},
	dampening = {
		prefix = "Dampening",
		modifiers = {
			longrange_damagetaken = 1/1.21
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5
	},
	menace = {
		prefix = "Menacing",
		modifiers = {
			shortrange_damagetaken = 1/1.21
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5
	},
	hard = {
		prefix = "Hard",
		suffix = "Hardness",
		modifiers = {
			perdebuff_resistance = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5
	},
	caution = {
		prefix = "Cautious",
		suffix = "Caution",
		modifiers = {
			noncombat_damagetaken = 1/1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		max = 2
	},
	intrepid = {
		prefix = "Intrepid",
		suffix = "Intrepidity",
		modifiers = {
			lowhealth_damagetaken = 1/1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		max = 2,
		weight = 0.5
	},
	bloodletting = {
		prefix = "Bloodletting",
		modifiers = {
			bloodletting = -0.02
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		max = 25
	},
	glutton = {
		prefix = "Gluttony",
		modifiers = {
			armor_fullpickup = 0.15
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5e3,
		max = 5
	},
	resist = {
		prefix = "Resisting",
		modifiers = {
			killstack_resistance = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5
	},
	ward = {
		prefix = "Warding",
		modifiers = {
			debuff_damagetaken = 1/1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		max = 5,
		weight = 0.5
	},
	fleeting = {
		prefix = "Fleeting",
		modifiers = {
			kill5s_speed = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		max = 10
	},
	regen = {
		prefix = "Regenerating",
		suffix = "Regeneration",
		modifiers = {
			combat5s_regen = 0.2
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5
	},
	shield = {
		prefix = "Shielding",
		modifiers = {
			combat5s_armorregen = 0.2
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5
	},
	sharp = {
		prefix = "Sharp",
		suffix = "Sharpness",
		modifiers = {
			hittaken_invincible = 2
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		max = 1
	},
	ignorant = {
		prefix = "Ignorant",
		suffix = "Ignorance",
		modifiers = {
			bullet_damagetaken = 1/1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		max = 5
	},
	harden = {
		prefix = "Hardening",
		modifiers = {
			combat5s_damagetaken = 1/1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		max = 5
	},
	
	-- defensive, half weight double cost
	unhappy = {
		prefix = "Unhappy",
		suffix = "Unhappiness",
		modifiers = {
			damage = 1/1.1,
			damagetaken = 1/1.331
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		cost = 2
	},
	--[[warm = {
		prefix = "Warming",
		modifiers = {
			combat5s_dodge = 1/1.331
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		cost = 2,
		max = 10
	},]]
	slow = {
		prefix = "Slow",
		suffix = "Slowing",
		modifiers = {
			speed = 1/1.1,
			damagetaken = 1/1.331
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		cost = 2,
		max = 12
	},
	guard = {
		prefix = "Guarding",
		modifiers = {
			armor_trueblock = 2
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		cost = 2,
		max = 1
	},
	tiny = {
		prefix = "Tiny",
		suffix = "Tinyness",
		modifiers = {
			armor = 1/1.1,
			health = 1.331
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		cost = 2
	},
	small = {
		prefix = "Small",
		suffix = "Smallness",
		modifiers = {
			armor = 1/1.1,
			health = 1.1,
			speed = 1.1,
			firerate = 1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		cost = 2,
		max = 10
	},
	large = {
		prefix = "Large",
		suffix = "Largeness",
		modifiers = {
			health = 1/1.1,
			armor = 1.1,
			damage = 1.1,
			damagetaken = 1/1.1
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		cost = 2
	},
	massive = {
		prefix = "Massive",
		suffix = "Massiveness",
		modifiers = {
			health = 1/1.1,
			armor = 1.331,
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		cost = 2
	},
	awful = {
		prefix = "Awful",
		suffix = "Awfulness",
		modifiers = {
			oddlevel_damagetaken = 1.1,
			evenlevel_damagetaken = 1/1.331,
		},
		flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.XP),
		weight = 0.5,
		cost = 2
	},
	inept = {
		prefix = "Inept",
		suffix = "Ineptivity",
		modifiers = {
			evenlevel_damagetaken = 1.1,
			oddlevel_damagetaken = 1/1.331,
		},
		flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.XP),
		weight = 0.5,
		cost = 2
	},
}

local attributes = {
	-- pure damage
	damage = {
		display = "%s damage dealt",
	},
	nonbullet_damage = {
		display = "%s non-bullet damage dealt",
	},
	longrange_damage = {
		display = "%s long range damage dealt",
	},
	shortrange_damage = {
		display = "%s short range damage dealt",
	},
	longrange_nonbullet_damage = {
		display = "%s long range non-bullet damage dealt",
	},
	shortrange_nonbullet_damage = {
		display = "%s short range non-bullet damage dealt",
	},
	melee_damage = {
		display = "%s melee damage dealt",
	},
	lowhealth_damage = {
		display = "Up to %s damage dealt at low health",
		mul = 5
	},
	lowhealth_victim_damage = {
		display = "Up to %s damage dealt against low health entities",
		mul = 2
	},
	lowhealth_victim_melee_damage = {
		display = "Up to %s melee damage dealt against low health entities",
		mul = 5
	},
	high90health_victim_damage = {
		display = "%s damage dealt against entities above 90%% health",
		mul = 5
	},
	lowxhealth_victim_doubledamage = {
		display = "Doubled damage dealt against entities below %s health",
	},
	speed_damage = {
		display = "%s damage dealt, scaled by velocity",
		mul = 2
	},
	crit_damage = {
		display = "%s critical damage dealt",
		mul = 2
	},
	highlevel_damage = {
		display = "%s damage dealt to higher-level entities",
		mul = 2
	},
	oddlevel_damage = {
		display = "%s damage dealt against odd-levelled entities"
	},
	evenlevel_damage = {
		display = "%s damage dealt against even-levelled entities"
	},
	mark_damage = {
		display = "%s damage dealt against marked entities"
	},
	ally_damage = {
		display = "%s damage dealt against allies unless Alt is held",
		invert = true
	},
	random_damage = {
		display = "Damage dealt randomly altered by +/%s",
		mode = 3
	},
	perdebuff_damage = {
		display = "%s damage dealt per Insane Stats victim debuff"
	},
	debuff_damage = {
		display = "%s Insane Stats debuff damage dealt",
		mul = 2
	},
	explode_damage = {
		display = "%s explosive damage dealt"
	},
	fire_damage = {
		display = "%s fire damage dealt"
	},
	poison_damage = {
		display = "%s poison, chemical and radiation damage dealt"
	},
	freeze_damage = {
		display = "%s freeze and drowning damage dealt"
	},
	shock_damage = {
		display = "%s shock and fall damage dealt"
	},
	bleed_damage = {
		display = "%s laceration and bleed damage dealt"
	},
	
	-- pure damage taken
	damagetaken = {
		display = "%s damage taken",
		invert = true
	},
	bullet_damagetaken = {
		display = "%s bullet damage taken",
		mul = 2,
		invert = true
	},
	crit_damagetaken = {
		display = "%s critical damage taken",
		mul = 2,
		invert = true
	},
	longrange_damagetaken = {
		display = "%s long range damage taken",
		invert = true
	},
	shortrange_damagetaken = {
		display = "%s short range damage taken",
		invert = true
	},
	lowhealth_damagetaken = {
		display = "Up to %s damage taken at low health",
		mul = 5,
		invert = true
	},
	lowlevel_damagetaken = {
		display = "%s damage taken from lower-level entities",
		invert = true,
		mul = 2
	},
	noncombat_damagetaken = {
		display = "%s damage taken out of combat",
		mul = 5,
		invert = true
	},
	speed_damagetaken = {
		display = "%s damage taken, scaled by velocity",
		invert = true,
		mul = 2
	},
	mark_damagetaken = {
		display = "%s damage taken from marked entities",
		invert = true
	},
	oddlevel_damagetaken = {
		display = "%s damage taken while odd-levelled",
		invert = true
	},
	evenlevel_damagetaken = {
		display = "%s damage taken while even-levelled",
		invert = true
	},
	perdebuff_resistance = {
		display = "%s defence per Insane Stats debuff"
	},
	debuff_damagetaken = {
		display = "%s damage taken from Insane Stats debuffs",
		mul = 2,
		invert = true
	},
	explode_damagetaken = {
		display = "%s explosive damage taken",
		invert = true
	},
	fire_damagetaken = {
		display = "%s fire damage taken",
		invert = true
	},
	poison_damagetaken = {
		display = "%s poison, chemical and radiation damage taken",
		invert = true
	},
	freeze_damagetaken = {
		display = "%s freeze and drowning damage taken",
		invert = true
	},
	shock_damagetaken = {
		display = "%s shock and fall damage taken",
		invert = true
	},
	bleed_damagetaken = {
		display = "%s laceration and bleed damage taken",
		invert = true
	},
	
	crit_chance = {
		display = "%s random critical hit chance",
	},
	firerate = {
		display = "%s fire rate",
	},
	knockback = {
		display = "%s knockback",
	},
	bullets = {
		display = "%s bullets",
	},
	spread = {
		display = "%s bullet spread",
		invert = true
	},
	--[[clip = {
		display = "%s clip size",
	},
	lastammo_damage = {
		display = "%s last clip shot damage dealt",
	},]]
	ammo_savechance = {
		display = "%s chance to not consume ammo",
		mode = 2
	},
	xp = {
		display = "%s XP gain",
	},
	crit_xp = {
		display = "%s XP gain on critical kills",
		mul = 2
	},
	simul_xp = {
		display = "%s XP gain per additional multikilled entity",
		mul = 10
	},
	explode = {
		display = "%s explosion chance after 0.5s",
	},
	poison = {
		display = "%s poison chance",
	},
	fire = {
		display = "%s fire chance",
	},
	freeze = {
		display = "%s freeze chance",
	},
	shock = {
		display = "%s shock chance after 0.5s",
	},
	bleed = {
		display = "%s bleed chance",
	},
	frostfire = {
		display = "%s frostfire chance",
	},
	electroblast = {
		display = "%s electroblast chance",
	},
	hemotoxic = {
		display = "%s hemotoxin chance",
	},
	cosmicurse = {
		display = "%s cosmicurse damage dealt",
	},
	arc_chance = {
		display = "%s arc damage chance",
		mode = 2
	},
	repeat1s_damage = {
		display = "%s doom damage dealt after 1s",
	},
	kill5s_damage = {
		display = "%s damage dealt for 5s after kill",
		mul = 2
	},
	kill5s_ally_damage = {
		display = "%s damage dealt for 5s after ally kill",
		mul = 5
	},
	kill5s_firerate = {
		display = "%s fire rate for 5s after kill",
		mul = 2
	},
	kill5s_speed = {
		display = "%s movement speed for 5s after kill",
		mul = 2
	},
	kill5s_regen = {
		display = "%s health regen for 5s after kill",
		mode = 3,
		nopercent = true
	},
	kill5s_armorregen = {
		display = "%s armor regen for 5s after kill, reduced above full armor",
		mode = 3,
		nopercent = true
	},
	kill5s_damagetaken = {
		display = "%s damage taken for 5s after kill",
		mul = 2,
		invert = true
	},
	kill5s_damageaura = {
		display = "%s damage aura for 5s after kill",
		nopercent = true,
		mul = 10,
	},
	killstack_damage = {
		display = "%s damage dealt per kill, decays over time",
		mul = 0.25
	},
	killstack_firerate = {
		display = "%s fire rate per kill, decays over time",
		mul = 0.25
	},
	killstack_resistance = {
		display = "%s defence per kill, decays over time",
		mul = 0.25
	},
	--[[killstack_speed = {
		display = "%s movement speed per kill, decays over time",
	},]]
	killstack_xp = {
		display = "%s XP gain per kill, decays over time",
		mul = 0.25
	},
	hit10s_damage = {
		display = "%s damage dealt for 10s, 60s cooldown",
		mul = 7
	},
	hit10s_firerate = {
		display = "%s fire rate for 10s, 60s cooldown",
		mul = 7
	},
	hit3_damage = {
		display = "%s damage dealt every third hit",
		mul = 3
	},
	hit100_damage = {
		display = "%s damage dealt every 100th hit",
		mul = 100
	},
	hit100_self_damage = {
		display = "%s damage dealt to self every 100th hit",
		mul = 100,
		invert = true
	},
	hitstack_damage = {
		display = "%s damage dealt per hit, decays over time",
		mul = 0.03125
	},
	hittaken_damage = {
		display = "%s damage dealt after taking damage for 10s, 60s cooldown",
		mul = 7
	},
	hittaken_invincible = {
		display = "Become invincible when below 70%% health after taking damage, for 10s, 60s cooldown"
	},
	lifesteal = {
		display = "Up to %s life steal based on squared victim distance",
		mode = 3,
		nopercent = true
	},
	amp_armorloss = {
		display = "At full armor, %s armor converted to amp damage",
		start = math.sqrt(1.1),
		mode = 1,
		invert = true
	},
	amp_damage = {
		display = "%s amp damage",
		start = 10
	},
	combat5s_damage = {
		display = "Up to %s damage dealt over 5s in combat",
		mul = 2
	},
	combat5s_firerate = {
		display = "Up to %s fire rate over 5s in combat",
		mul = 2
	},
	speed = {
		display = "%s movement speed",
	},
	victim_speed = {
		display = "%s victim movement speed for 5s",
		invert = true,
		mul = 1.5
	},
	victim_damagetaken = {
		display = "%s victim damage taken for 5s",
		mul = 1.5
	},
	victim_damage = {
		display = "%s victim damage dealt for 5s",
		invert = true,
		mul = 1.5
	},
	victim_firerate = {
		display = "%s victim fire rate for 5s",
		invert = true,
		mul = 1.5
	},
	nonbullet_misschance = {
		display = "%s non-bullet miss chance",
		mode = 2,
		invert = true
	},
	misschance = {
		display = "%s miss chance",
		mode = 2,
		invert = true
	},
	prop_xp = {
		display = "%s XP gain from props",
		mul = 0.5
	},
	ally_xp = {
		display = "%s XP gain from allies",
		mode = 3
	},
	kill_lifesteal = {
		display = "%s healing on kill",
		mode = 3,
		nopercent = true
	},
	kill_armorsteal = {
		display = "%s armor on kill, reduced above full armor",
		mode = 3,
		nopercent = true
	},
	kill_clipsteal = {
		display = "%s clip refilled on kill",
		mode = 3
	},
	--[[kill_victim_damage = {
		display = "%s damage dealt by nearby enemies on kill",
		invert = true
	},
	kill_victim_firerate = {
		display = "%s fire rate of nearby enemies on kill",
		invert = true
	},]]
	perhit_victim_damagetaken = {
		display = "%s victim damage taken per hit",
		mul = 0.1
	},
	aimbot = {
		display = "%s bullet aimbot chance"
	},
	
	toggle_damage = {
		display = "%s damage dealt or defence, switched every 5s"
	},
	knockbacktaken = {
		display = "%s knockback taken",
		invert = true
	},
	self_knockbacktaken = {
		display = "%s self-knockback taken"
	},
	health = {
		display = "%s health",
	},
	armor = {
		display = "%s armor",
	},
	armor_trueblock = {
		display = "Armor blocks all health damage",
	},
	dodge = {
		display = "%s dodge chance",
		mode = 2
	},
	retaliation10_damage = {
		display = "%s retaliation damage when hurt 10 times",
		mul = 10
	},
	supplying = {
		display = "%s item pickups"
	},
	noncombat_speed = {
		display = "%s movement speed out of combat",
		mul = 2
	},
	sprint_speed = {
		display = "%s sprint speed",
		mul = 2
	},
	bloodletting = {
		display = "Health above %s turned into armor, reduced above full armor",
		start = 2,
		mode = 3
	},
	armor_fullpickup = {
		display = "Armor batteries can overcharge armor at %s efficiency, reduced further above full armor",
		start = 0,
		invert = true,
		mode = 3
	},
	else_xp = {
		display = "%s XP gain from other's kills",
	},
	alt_invisible = {
		display = "%ss invisibility after Alt double tap, 60s cooldown",
		start = 5,
		nopercent = true
	},
	alt_damage = {
		display = "%s damage dealt after Alt double tap, 60s cooldown",
		mul = 2
	},
	alt_firerate = {
		display = "%s fire rate after Alt double tap, 60s cooldown",
		mul = 2
	},
	alt_speed = {
		display = "%s movement speed after Alt double tap, 60s cooldown",
		mul = 2
	},
	combat5s_damagetaken = {
		display = "Up to %s damage taken over 5s in combat",
		mul = 2,
		invert = true
	},
	--[[combat5s_dodge = {
		display = "Up to %s dodge chance over 5s in combat",
		mode = 2
	},]]
	jumps = {
		display = "%s extra jumps",
		mode = 3,
		nopercent = true
	},
	combat5s_regen = {
		display = "Up to %s health regen over 5s in combat",
		mode = 3,
		nopercent = true
	},
	combat5s_armorregen = {
		display = "Up to %s armor regen over 5s in combat",
		mode = 3,
		nopercent = true
	},
	mark = {
		display = "Closest enemy is marked on HUD"
	},
}

local statusEffects = {
	poison = {
		name = "Poisoned",
		typ = -1,
		img = Material("insane_stats/status_effects/poison-bottle.png", "mips smooth")
	},
	fire = {
		name = "On Fire",
		typ = -1,
		img = Material("insane_stats/status_effects/small-fire.png", "mips smooth")
	},
	freeze = {
		name = "Freezing",
		typ = -1,
		img = Material("insane_stats/status_effects/snowflake-2.png", "mips smooth")
	},
	shock = {
		name = "Shocked",
		typ = -1,
		img = Material("insane_stats/status_effects/lightning-frequency.png", "mips smooth")
	},
	bleed = {
		name = "Bleeding",
		typ = -1,
		img = Material("insane_stats/status_effects/bleeding-wound.png", "mips smooth")
	},
	hemotoxin = {
		name = "Hemotoxicated",
		typ = -1,
		img = Material("insane_stats/status_effects/spotted-wound.png", "mips smooth")
	},
	frostfire = {
		name = "Frostfire",
		typ = -1,
		img = Material("insane_stats/status_effects/frostfire.png", "mips smooth")
	},
	electroblast = {
		name = "Electroblasted",
		typ = -1,
		img = Material("insane_stats/status_effects/sonic-lightning.png", "mips smooth")
	},
	cosmicurse = {
		name = "Cosmicurse",
		typ = -1,
		img = Material("insane_stats/status_effects/cursed-star.png", "mips smooth")
	},
	doom = {
		name = "Doomed",
		typ = -1,
		img = Material("insane_stats/status_effects/shark-jaws.png", "mips smooth"),
		expiry = SERVER and function(ent, level, attacker)
			hook.Run("InsaneStatsWPASS2Doom", ent, level, attacker)
		end
	},
	
	stunned = {
		name = "Stunned",
		typ = -1,
		img = Material("insane_stats/status_effects/coma.png", "mips smooth"),
		expiry = SERVER and function(ent, level, attacker)
			if ent:IsNPC() and level > 0 then
				ent:SetCondition(68)
				ent:InsaneStats_ApplyStatusEffect("stun_immune", 1, 2)
			end
		end
	},
	stun_immune = {
		name = "Stun Immunity",
		typ = 1,
		img = Material("insane_stats/status_effects/extra-lucid.png", "mips smooth")
	},
	retaliation10_buildup = {
		name = "Retaliation Buildup",
		typ = 1,
		img = Material("insane_stats/status_effects/shield-reflect.png", "mips smooth")
	},
	hit100_selfdamage_stacks = {
		name = "Dangerous Buildup",
		typ = -1,
		img = Material("insane_stats/status_effects/dread-skull.png", "mips smooth")
	},
	perhit_defence_down = {
		name = "Ruthless Defence Down",
		typ = -1,
		img = Material("insane_stats/status_effects/skull-crack.png", "mips smooth")
	},
	hit3_damage_stacks = {
		name = "Strong Buildup",
		typ = 1,
		img = Material("insane_stats/status_effects/blade-fall.png", "mips smooth")
	},
	hit100_damage_stacks = {
		name = "Godly Buildup",
		typ = 1,
		img = Material("insane_stats/status_effects/blade-fall.png", "mips smooth")
	},
	hit10s_damage_up = {
		name = "Unpleasant Damage Up",
		typ = 2,
		img = Material("insane_stats/status_effects/pointy-sword.png", "mips smooth"),
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("hit10s_damage_cooldown", 1, 60)
		end
	},
	hit10s_damage_cooldown = {
		name = "Unpleasancy Cooldown",
		typ = -1,
		img = Material("insane_stats/status_effects/sword-in-stone.png", "mips smooth")
	},
	hit10s_firerate_up = {
		name = "Mystical Fire Rate Up",
		typ = 2,
		img = Material("insane_stats/status_effects/striking-arrows.png", "mips smooth"),
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("hit10s_firerate_cooldown", 1, 60)
		end
	},
	hit10s_firerate_cooldown = {
		name = "Mystical Cooldown",
		typ = -1,
		img = Material("insane_stats/status_effects/hand.png", "mips smooth")
	},
	hittaken_invincible = {
		name = "Sharp Invincibility",
		typ = 2,
		img = Material("insane_stats/status_effects/mesh-ball.png", "mips smooth"),
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("hittaken_invincible_cooldown", 1, 60)
		end
	},
	hittaken_invincible_cooldown = {
		name = "Sharp Invincibility Cooldown",
		typ = -2,
		img = Material("insane_stats/status_effects/caged-ball.png", "mips smooth")
	},
	hittaken_damage_up = {
		name = "Fury Damage Up",
		typ = 2,
		img = Material("insane_stats/status_effects/pointy-sword.png", "mips smooth"),
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("hittaken_damage_cooldown", 1, 60)
		end
	},
	hittaken_damage_cooldown = {
		name = "Fury Cooldown",
		typ = -1,
		img = Material("insane_stats/status_effects/sword-in-stone.png", "mips smooth")
	},
	
	damage_down = {
		name = "Damage Down",
		typ = -1,
		img = Material("insane_stats/status_effects/shattered-sword.png", "mips smooth")
	},
	defence_down = {
		name = "Defence Down",
		typ = -1,
		img = Material("insane_stats/status_effects/cracked-shield.png", "mips smooth")
	},
	speed_down = {
		name = "Speed Down",
		typ = -1,
		img = Material("insane_stats/status_effects/snail.png", "mips smooth")
	},
	firerate_down = {
		name = "Fire Rate Down",
		typ = -1,
		img = Material("insane_stats/status_effects/handcuffs.png", "mips smooth")
	},
	damage_up = {
		name = "Damage Up",
		typ = 1,
		img = Material("insane_stats/status_effects/pointy-sword.png", "mips smooth")
	},
	defence_up = {
		name = "Defence Up",
		typ = 1,
		img = Material("insane_stats/status_effects/checked-shield.png", "mips smooth")
	},
	speed_up = {
		name = "Speed Up",
		typ = 1,
		img = Material("insane_stats/status_effects/sprint.png", "mips smooth")
	},
	firerate_up = {
		name = "Fire Rate Up",
		typ = 1,
		img = Material("insane_stats/status_effects/striking-arrows.png", "mips smooth")
	},
	arcane_damage_up = {
		name = "Arcane Damage Up",
		typ = 2,
		img = Material("insane_stats/status_effects/pointy-sword.png", "mips smooth"),
		expiry = function(ent, level, attacker)
			if ent:InsaneStats_GetAttributeValue("toggle_damage") ~= 1 then
				local stacks = (ent:InsaneStats_GetAttributeValue("toggle_damage")-1)*100
				ent:InsaneStats_ApplyStatusEffect("arcane_defence_up", stacks, 5)
			end
		end
	},
	arcane_defence_up = {
		name = "Arcane Defence Up",
		typ = 2,
		img = Material("insane_stats/status_effects/checked-shield.png", "mips smooth"),
		expiry = function(ent, level, attacker)
			if ent:InsaneStats_GetAttributeValue("toggle_damage") ~= 1 then
				local stacks = (ent:InsaneStats_GetAttributeValue("toggle_damage")-1)*100
				ent:InsaneStats_ApplyStatusEffect("arcane_damage_up", stacks, 5)
			end
		end
	},
	regen = {
		name = "Regeneration",
		typ = 1,
		img = Material("insane_stats/status_effects/heart-bottle.png", "mips smooth")
	},
	armor_regen = {
		name = "Armor Regeneration",
		typ = 1,
		img = Material("insane_stats/status_effects/energy-shield.png", "mips smooth")
	},
	damage_aura = {
		name = "Damage Aura",
		typ = 1,
		img = Material("insane_stats/status_effects/broken-heart-zone.png", "mips smooth")
	},
	
	invisible = {
		name = "Invisible",
		typ = 2,
		img = Material("insane_stats/status_effects/domino-mask.png", "mips smooth"),
		expiry = SERVER and function(ent, level, attacker)
			ent:RemoveFlags(FL_NOTARGET)
			ent:AddFlags(FL_AIMTARGET)
			ent:RemoveEffects(bit.bor(EF_NOSHADOW, EF_NODRAW, EF_NORECEIVESHADOW))
			ent:InsaneStats_ApplyStatusEffect("invisible_cooldown", 1, 60)
		end
	},
	invisible_cooldown = {
		name = "Invisibility Cooldown",
		typ = -1,
		img = Material("insane_stats/status_effects/one-eyed.png", "mips smooth")
	},
	alt_damage_up = {
		name = "Nasty Damage Up",
		typ = 2,
		img = Material("insane_stats/status_effects/pointy-sword.png", "mips smooth"),
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("alt_damage_cooldown", 1, 60)
		end
	},
	alt_damage_cooldown = {
		name = "Nasty Cooldown",
		typ = -1,
		img = Material("insane_stats/status_effects/sword-in-stone.png", "mips smooth")
	},
	alt_firerate_up = {
		name = "Haste Fire Rate Up",
		typ = 2,
		img = Material("insane_stats/status_effects/striking-arrows.png", "mips smooth"),
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("alt_firerate_cooldown", 1, 60)
		end
	},
	alt_firerate_cooldown = {
		name = "Haste Cooldown",
		typ = -1,
		img = Material("insane_stats/status_effects/hand.png", "mips smooth")
	},
	alt_speed_up = {
		name = "Agility Speed Up",
		typ = 2,
		img = Material("insane_stats/status_effects/sprint.png", "mips smooth"),
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("alt_speed_cooldown", 1, 60)
		end
	},
	alt_speed_cooldown = {
		name = "Agility Cooldown",
		typ = -1,
		img = Material("insane_stats/status_effects/barefoot.png", "mips smooth")
	},
	stack_damage_up = {
		name = "Stacking Damage Up",
		typ = 2,
		img = Material("insane_stats/status_effects/pointy-sword.png", "mips smooth")
	},
	stack_firerate_up = {
		name = "Stacking Fire Rate Up",
		typ = 2,
		img = Material("insane_stats/status_effects/striking-arrows.png", "mips smooth")
	},
	stack_defence_up = {
		name = "Stacking Defence Up",
		typ = 2,
		img = Material("insane_stats/status_effects/checked-shield.png", "mips smooth")
	},
	--[[stack_speed_up = {
		name = "Stacking Speed Up",
		typ = 2,
		img = Material("insane_stats/status_effects/sprint.png", "mips smooth")
	},]]
	stack_xp_up = {
		name = "Stacking XP Up",
		typ = 2,
		img = Material("insane_stats/status_effects/brain.png", "mips smooth")
	},
}

hook.Add("InsaneStatsModifyNextFire", "InsaneStatsSharedWPASS2", function(data)
	local attacker = data.attacker
	if IsValid(attacker) then
		local combatFraction = SERVER and math.Clamp(attacker:InsaneStats_GetCombatTime()/5, 0, 1) or 0
		local totalMul = attacker:InsaneStats_GetAttributeValue("firerate")
		totalMul = totalMul * (1 + (attacker:InsaneStats_GetAttributeValue("combat5s_firerate") - 1) * combatFraction)
		
		totalMul = totalMul * (1 + attacker:InsaneStats_GetStatusEffectLevel("firerate_up")/100)
		totalMul = totalMul * (1 + attacker:InsaneStats_GetStatusEffectLevel("alt_firerate_up")/100)
		totalMul = totalMul * (1 + attacker:InsaneStats_GetStatusEffectLevel("hit10s_firerate_up")/100)
		totalMul = totalMul * (1 + attacker:InsaneStats_GetStatusEffectLevel("stack_firerate_up")/100)
		totalMul = totalMul * (1 - attacker:InsaneStats_GetStatusEffectLevel("firerate_down")/100)
		totalMul = totalMul * (1 - attacker:InsaneStats_GetStatusEffectLevel("menacing_firerate_down")/100)
		
		if attacker:InsaneStats_GetStatusEffectLevel("shock") > 0
		or attacker:InsaneStats_GetStatusEffectLevel("electroblast") > 0
		or attacker:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
			totalMul = totalMul / 2
		end
		
		data.next = (data.next - CurTime()) / totalMul + CurTime()
	end
end)

hook.Add("InsaneStatsMoveSpeed", "InsaneStatsSharedWPASS2", function(data)
	local ent = data.ent
	if IsValid(ent) then
		local combatFraction = SERVER and math.Clamp(ent:InsaneStats_GetCombatTime()/5, 0, 1) or 0
		local healthFraction = 1-math.Clamp(ent:InsaneStats_GetHealth() / ent:InsaneStats_GetMaxHealth(), 0, 1)
		local speedMul = ent:InsaneStats_GetAttributeValue("speed")
		
		if combatFraction <= 0 then
			speedMul = speedMul * ent:InsaneStats_GetAttributeValue("noncombat_speed")
		end
		
		--speedMul = speedMul * (1 + ent:InsaneStats_GetStatusEffectLevel("stack_speed_up") / 100)
	
		speedMul = speedMul * (1+ent:InsaneStats_GetStatusEffectLevel("speed_up")/100)
		speedMul = speedMul * (1+ent:InsaneStats_GetStatusEffectLevel("alt_speed_up")/100)
		speedMul = speedMul * (1-ent:InsaneStats_GetStatusEffectLevel("speed_down")/100)
		
		if ent:InsaneStats_GetStatusEffectLevel("freeze") > 0
		or ent:InsaneStats_GetStatusEffectLevel("frostfire") > 0
		or ent:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
			speedMul = speedMul / 2
		end
		
		data.speed = data.speed * speedMul
		data.sprintSpeed = data.sprintSpeed * ent:InsaneStats_GetAttributeValue("sprint_speed")
	end
end)

hook.Add("EntityEmitSound","InsaneStatsSharedWPASS2",function(sound)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		local ent = sound.Entity
		if (IsValid(ent) and ent:InsaneStats_GetAttributeValue("alt_invisible") ~= 1 and ent:GetNoDraw()) then
			return false
		end
	end
	--if sound.SoundName ~= SM_UpgradeSound then
	--sound.Flags = bit.bor(sound.Flags, SND_SHOULDPAUSE)
	--return true
	--end
end)

hook.Add("StartCommand", "InsaneStatsSharedWPASS2", function(ply, usercmd)
	if usercmd:KeyDown(IN_RELOAD) and IsValid(ply:GetActiveWeapon()) then
		local wep = ply:GetActiveWeapon()
		if wep:Clip1() > wep:GetMaxClip1() and wep:GetMaxClip1() > 0 then
			usercmd:RemoveKey(IN_RELOAD)
		end
	end
end)

hook.Add("SetupMove", "InsaneStatsSharedWPASS2", function(ply, movedata, usercmd)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		if movedata:KeyPressed(IN_WALK) then
			if (ply.insaneStats_LastAltPress or 0) + 1 > CurTime() then
				ply.insaneStats_LastAltPress = 0
				
				local invisibilityDuration = ply:InsaneStats_GetAttributeValue("alt_invisible") - 1
				if ply:InsaneStats_GetStatusEffectDuration("invisible_cooldown") <= 0 and invisibilityDuration ~= 0 and not ply:IsFlagSet(FL_NOTARGET) then
					ply:AddFlags(FL_NOTARGET)
					ply:RemoveFlags(FL_AIMTARGET)
					ply:AddEffects(bit.bor(EF_NOSHADOW, EF_NODRAW, EF_NORECEIVESHADOW))
					ply:InsaneStats_ApplyStatusEffect("invisible", 1, invisibilityDuration)
				end
				
				local stacks = (ply:InsaneStats_GetAttributeValue("alt_damage") - 1) * 100
				if ply:InsaneStats_GetStatusEffectDuration("alt_damage_cooldown") <= 0
				and ply:InsaneStats_GetStatusEffectDuration("alt_damage_up") <= 0
				and stacks ~= 0 then
					ply:InsaneStats_ApplyStatusEffect("alt_damage_up", stacks, 10)
				end
				
				stacks = (ply:InsaneStats_GetAttributeValue("alt_firerate") - 1) * 100
				if ply:InsaneStats_GetStatusEffectDuration("alt_firerate_cooldown") <= 0
				and ply:InsaneStats_GetStatusEffectDuration("alt_firerate_up") <= 0
				and stacks ~= 0 then
					ply:InsaneStats_ApplyStatusEffect("alt_firerate_up", stacks, 10)
				end
				
				stacks = (ply:InsaneStats_GetAttributeValue("alt_speed") - 1) * 100
				if ply:InsaneStats_GetStatusEffectDuration("alt_speed_cooldown") <= 0
				and ply:InsaneStats_GetStatusEffectDuration("alt_speed_up") <= 0
				and stacks ~= 0 then
					ply:InsaneStats_ApplyStatusEffect("alt_speed_up", stacks, 10)
				end
			else
				ply.insaneStats_LastAltPress = CurTime()
			end
		end
		if ply:OnGround() then
			ply.insaneStats_Jumps = ply:InsaneStats_GetAttributeValue("jumps")
		end
		if movedata:KeyPressed(IN_JUMP) then
			if ply.insaneStats_Jumps > 0 then
				ply.insaneStats_Jumps = ply.insaneStats_Jumps - 1
				local jumppower = ply:GetJumpPower() - ply:GetVelocity().z
				local desiredVector = vector_up * jumppower
				
				local buttons = usercmd:GetButtons()
				local shuntStrength = (bit.band(buttons,IN_SPEED)~=0 and ply:GetRunSpeed()/2 or ply:GetWalkSpeed()/2)
				local Forward = (bit.band(buttons,IN_FORWARD)~=0 and 1 or 0) + (bit.band(buttons,IN_BACK)~=0 and -1 or 0)
				if Forward~=0 then
					desiredVector:Add(ply:GetForward() * shuntStrength)
				end
				local Right = (bit.band(buttons,IN_RIGHT)~=0 and 1 or 0) + (bit.band(buttons,IN_LEFT)~=0 and -1 or 0)
				if Right~=0 then
					desiredVector:Add(ply:GetRight() * shuntStrength)
				end
				desiredVector:Add(movedata:GetVelocity())
				
				movedata:SetVelocity(desiredVector)
			end
		end
	end
end)

local function ProcessKillEvent(victim, attacker, inflictor)
	if not IsValid(attacker) and IsValid(inflictor) then
		attacker = inflictor
	end
	
	if IsValid(attacker) then
		if victim ~= attacker then
			if attacker:InsaneStats_GetHealth() < attacker:InsaneStats_GetMaxHealth() then
				local healthRestored = (attacker:InsaneStats_GetAttributeValue("kill_lifesteal") - 1) * (attacker.insaneStats_CurrentHealthAdd or 1)
				if attacker:InsaneStats_GetStatusEffectLevel("bleed") > 0
				or attacker:InsaneStats_GetStatusEffectLevel("hemotoxin") > 0
				or attacker:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
					healthRestored = healthRestored / 2
				end
				attacker:SetHealth(math.min(attacker:InsaneStats_GetHealth() + healthRestored, attacker:InsaneStats_GetMaxHealth()))
			end
			--print(attacker:InsaneStats_GetHealth(), healthRestored, attacker:InsaneStats_GetMaxHealth())
			
			if attacker.GetMaxArmor then
				local armorRestored = (attacker:InsaneStats_GetAttributeValue("kill_armorsteal") - 1)* (attacker.insaneStats_CurrentArmorAdd or 1)
				attacker:InsaneStats_AddArmorNerfed(armorRestored)
			end
			
			local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon() or NULL
			local clipSteal = attacker:InsaneStats_GetAttributeValue("kill_clipsteal") - 1
			if IsValid(wep) and SERVER and clipSteal ~= 0 then
				local ammoToGive1 = wep:GetMaxClip1() * clipSteal
				local ammoToGive2 = wep:GetMaxClip2() * clipSteal
				local clip1Used = wep:GetMaxClip1() > 0
				local clip2Used = wep:GetMaxClip2() > 0
				
				local isPlayer = attacker:IsPlayer()
				if not clip1Used and isPlayer and wep:GetPrimaryAmmoType() > 0 then
					ammoToGive1 = game.GetAmmoMax(wep:GetPrimaryAmmoType()) / 5 * clipSteal
				end
				if not clip2Used and isPlayer and wep:GetSecondaryAmmoType() > 0 then
					ammoToGive2 = game.GetAmmoMax(wep:GetSecondaryAmmoType()) / 5 * clipSteal
				end
				
				ammoToGive1 = ((math.random() < ammoToGive1 % 1) and math.ceil or math.floor)(ammoToGive1)
				ammoToGive2 = ((math.random() < ammoToGive2 % 1) and math.ceil or math.floor)(ammoToGive2)
				
				if clip1Used then
					wep:SetClip1(wep:Clip1()+ammoToGive1)
				elseif isPlayer then
					attacker:GiveAmmo(ammoToGive1, wep:GetPrimaryAmmoType())
				end
				
				if clip2Used then
					wep:SetClip2(wep:Clip2()+ammoToGive2)
				elseif isPlayer then
					attacker:GiveAmmo(ammoToGive2, wep:GetSecondaryAmmoType())
				end
			end
			
			local stacks = (attacker:InsaneStats_GetAttributeValue("killstack_damage") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("stack_damage_up", stacks, math.huge, {amplify = true})
			stacks = (attacker:InsaneStats_GetAttributeValue("killstack_resistance") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("stack_defence_up", stacks, math.huge, {amplify = true})
			--[[stacks = (attacker:InsaneStats_GetAttributeValue("killstack_speed") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("stack_speed_up", stacks, math.huge, {amplify = true})]]
			stacks = (attacker:InsaneStats_GetAttributeValue("killstack_xp") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("stack_xp_up", stacks, math.huge, {amplify = true})
			stacks = (attacker:InsaneStats_GetAttributeValue("killstack_firerate") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("stack_firerate_up", stacks, math.huge, {amplify = true})
			
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill5s_damage") - 1) * 100
			if stacks < 0 then
				attacker:InsaneStats_ApplyStatusEffect("damage_down", -stacks, 5, {extend = true})
			else
				attacker:InsaneStats_ApplyStatusEffect("damage_up", stacks, 5, {extend = true})
			end
			
			stacks = (1 / attacker:InsaneStats_GetAttributeValue("kill5s_damagetaken") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("defence_up", stacks, 5, {extend = true})
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill5s_firerate") - 1) * 100
			if stacks < 0 then
				attacker:InsaneStats_ApplyStatusEffect("firerate_down", -stacks, 5, {extend = true})
			else
				attacker:InsaneStats_ApplyStatusEffect("firerate_up", stacks, 5, {extend = true})
			end
			
			stacks = (attacker:InsaneStats_GetAttributeValue("kill5s_speed") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("speed_up", stacks, 5, {extend = true})
			
			stacks = attacker:InsaneStats_GetAttributeValue("kill5s_regen") - 1
			attacker:InsaneStats_ApplyStatusEffect("regen", stacks, 5, {extend = true})
			
			stacks = attacker:InsaneStats_GetAttributeValue("kill5s_armorregen") - 1
			attacker:InsaneStats_ApplyStatusEffect("armor_regen", stacks, 5, {extend = true})
			
			stacks = attacker:InsaneStats_GetAttributeValue("kill5s_damageaura") - 1
			attacker:InsaneStats_ApplyStatusEffect("damage_aura", stacks, 5, {extend = true})
			
			if SERVER then
				local isAlly = victim:IsNPC() and victim:Disposition(attacker) == D_LI
				if attacker:InsaneStats_GetAttributeValue("kill5s_ally_damage") ~= 1 and isAlly then
					local stacks = (1 - attacker:InsaneStats_GetAttributeValue("kill5s_ally_damage")) * 100
					attacker:InsaneStats_ApplyStatusEffect("damage_down", stacks, 5, {extend = true})
				end
			end
			
			--[[if SERVER then
				for k,v in pairs(ents.FindInSphere(victim:GetPos(), 512)) do
					if (v:IsNPC() and v:Disposition(attacker) == D_HT) then
						local stacks = (1-attacker:InsaneStats_GetAttributeValue("kill_victim_damage"))*100
						if stacks ~= 0 then
							v:InsaneStats_ApplyStatusEffect("menacing_damage_down", stacks, 5, {extend = true})
						end
						
						stacks = (1-attacker:InsaneStats_GetAttributeValue("kill_victim_firerate"))*100
						if stacks ~= 0 then
							v:InsaneStats_ApplyStatusEffect("menacing_firerate_down", stacks, 5, {extend = true})
						end
					end
				end
			end]]
		end
	end
end

hook.Add("entity_killed", "InsaneStatsSharedWPASS2", function(data)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		local victim = Entity(data.entindex_killed or 0)
		local attacker = Entity(data.entindex_attacker or 0)
		local inflictor = Entity(data.entindex_inflictor or 0)
		
		ProcessKillEvent(victim, attacker, inflictor)
	end
end)

hook.Add("InsaneStatsLoadWPASS", "InsaneStatsSharedWPASS2", function(currentModifiers, currentAttributes, currentStatusEffects)
	table.Merge(currentModifiers, modifiers)
	table.Merge(currentAttributes, attributes)
	table.Merge(currentStatusEffects, statusEffects)
end)

hook.Add("EntityFireBullets", "InsaneStatsSharedWPASS2", function(attacker, data)
	if InsaneStats:GetConVarValue("wpass2_enabled") then
		local newNum = data.Num * attacker:InsaneStats_GetAttributeValue("bullets")
		data.Num = ((math.random() < newNum % 1) and math.ceil or math.floor)(newNum)
		if data.Num <= 0 then return false end
		
		data.Spread:Mul(attacker:InsaneStats_GetAttributeValue("spread"))
		
		return true
	end
end)