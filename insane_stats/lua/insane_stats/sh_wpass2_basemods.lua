local modifiers = {
	{-- damage
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
		explode = {
			prefix = "Explosive",
			suffix = "Explosions",
			modifiers = {
				explode = 1.1
			},
			weight = 1,
			max = 7
		},
		earth = {
			prefix = "Earthen",
			suffix = "Earth",
			modifiers = {
				poison = 1.1
			},
			weight = 1,
			max = 7
		},
		fire = {
			prefix = "Firey",
			suffix = "Fire",
			modifiers = {
				fire = 1.1
			},
			weight = 1,
			max = 7
		},
		water = {
			prefix = "Watery",
			suffix = "Water",
			modifiers = {
				freeze = 1.1
			},
			weight = 1,
			max = 7
		},
		air = {
			prefix = "Airy",
			suffix = "Air",
			modifiers = {
				shock = 1.1
			},
			weight = 1,
			max = 7
		},
		blood = {
			prefix = "Bloody",
			suffix = "Blood",
			modifiers = {
				bleed = 1.1
			},
			weight = 1,
			max = 7
		},
		arc = {
			prefix = "Arcing",
			modifiers = {
				arc_chance = 1/1.1
			}
		},
		luck = {
			prefix = "Lucky",
			suffix = "Luck",
			modifiers = {
				crit_chance = 1.1
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
		hold = {
			prefix = "Holding",
			modifiers = {
				clip = 1.21,
				lastammo_damage = 1.1
			},
			weight = 1,
			max = 10,
			flags = InsaneStats.WPASS2_FLAGS.SCRIPTED_ONLY
		},
	},
	
	{-- damage, half weight
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
		energetic = {
			prefix = "Energetic",
			suffix = "Energy",
			modifiers = {
				armor_damage = 1.1,
			},
			weight = 0.5,
		},
		unpleasant = {
			prefix = "Unpleasant",
			suffix = "Unpleasantness",
			modifiers = {
				hit1s_damage = 1.1,
			},
			weight = 0.5
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
				hit100_damagepulse = 1.1
			},
			weight = 0.5,
		},
		savage = {
			prefix = "Savage",
			suffix = "Savageness",
			modifiers = {
				lowhealth_firerate = 1.1,
			},
			weight = 0.5,
			max = 10
		},
		gatling = {
			prefix = "Gatling",
			modifiers = {
				critstack_firerate = 1.1,
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
			weight = 0.5,
			max = 10
		},
		ruthless = {
			prefix = "Ruthless",
			suffix = "Ruthlessness",
			modifiers = {
				hit3_damage = 1.1
			},
			weight = 0.5
		},
		wild = {
			prefix = "Wild",
			suffix = "Wilderness",
			modifiers = {
				kill_clipsteal = 1.1,
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
		celestial = {
			prefix = "Celestial",
			suffix = "Celestiality",
			modifiers = {
				kill5s_damageaura = 1.1
			},
			weight = 0.5
		},
		violent = {
			prefix = "Violent",
			suffix = "Violence",
			modifiers = {
				armored_victim_damage = 1.21,
				--nonliving_damage = 1.21
			},
			weight = 0.5
		},
		shoddy = {
			prefix = "Shoddy",
			suffix = "Shoddiness",
			modifiers = {
				unarmored_victim_damage = 1.21
			},
			weight = 0.5
		},
		terrible = {
			prefix = "Terrible",
			suffix = "Terribleness",
			modifiers = {
				back_damage = 1.21
			},
			weight = 0.5
		},
		taboo = {
			prefix = "Taboo",
			suffix = "Tabooness",
			modifiers = {
				front_damage = 1.21
			},
			weight = 0.5
		},
		pressure = {
			prefix = "Pressurized",
			suffix = "Pressure",
			modifiers = {
				clip_firerate = 1.1
			},
			weight = 0.5,
			max = 10
		},
		penetrate = {
			prefix = "Penetrative",
			suffix = "Penetrating",
			modifiers = {
				penetrate = 1.1,
				nonbullet_damage = 1.1
			},
			weight = 0.5,
			max = 10
		},
		power = {
			prefix = "Powerful",
			suffix = "Power",
			modifiers = {
				highlevel_damage = 1.1
			},
			weight = 0.5,
			flags = InsaneStats.WPASS2_FLAGS.XP
		},
	},
	
	{-- damage, half weight doubled cost
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
	},

	{-- damage, negative cost
		broken = {
			prefix = "Broken",
			suffix = "Breaking",
			modifiers = {
				damage = 1/1.1,
				random_damage = -0.2
			},
			max = 5,
			cost = -1
		},
		dull = {
			prefix = "Dull",
			suffix = "Dullness",
			modifiers = {
				damage = 1/1.1
			},
			cost = -1
		},
		slow = {
			prefix = "Slow",
			suffix = "Slowness",
			modifiers = {
				firerate = 1/1.1
			},
			max = 10,
			cost = -1
		},
		curse = {
			prefix = "Cursed",
			suffix = "Curses",
			modifiers = {
				bullets = 1/1.1,
				nonbullet_damage = 1/1.1
			},
			max = 10,
			cost = -1
		},
		zealous = {
			prefix = "Zealous",
			suffix = "Zealousness",
			modifiers = {
				spread = 1.21,
				nonbullet_damage = 1/1.1
			},
			max = 10,
			cost = -1
		},
		small = {
			prefix = "Small",
			suffix = "Smallness",
			modifiers = {
				clip = 1/1.21,
				lastammo_damage = 1/1.1
			},
			cost = -1,
			max = 10,
			flags = InsaneStats.WPASS2_FLAGS.SCRIPTED_ONLY
		},
	},

	{-- damage, half weight negative cost
		shame = {
			prefix = "Shameful",
			suffix = "Shame",
			modifiers = {
				kill5s_ally_damage = 1/1.1
			},
			weight = 0.5,
			max = 2,
			cost = -1
		},
		lazy = {
			prefix = "Lazy",
			suffix = "Laziness",
			modifiers = {
				highhealth_firerate = 1/1.1,
			},
			weight = 0.5,
			max = 10,
			cost = -1
		},
		demotivate = {
			prefix = "Demotivating",
			suffix = "Demotivation",
			modifiers = {
				kill5s_damage = 1/1.1
			},
			weight = 0.5,
			cost = -1,
			max = 7
		},
		annoy = {
			prefix = "Annoying",
			suffix = "Annoyance",
			modifiers = {
				kill5s_firerate = 1/1.1
			},
			weight = 0.5,
			cost = -1,
			max = 7
		},
		danger = {
			prefix = "Dangerous",
			suffix = "Danger",
			modifiers = {
				hit100_self_damage = 1.1
			},
			weight = 0.5,
			cost = -1
		},
		sluggish = {
			prefix = "Sluggish",
			suffix = "Sluggishness",
			modifiers = {
				lowlevel_damage = 1/1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.XP,
			weight = 0.5,
			max = 7,
			cost = -1
		},
	},

	{-- damage inaccessible
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
			prefix = "Judgemental",
			suffix = "Judgement",
			modifiers = {
				cosmicurse = 1.1
			},
			merge = {
				"frostfire", "electroblast", "hemotoxic", "doom"
			},
			flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.SCRIPTED_ONLY),
		},
	},
	
	{-- damage utility, doubled weight
		force = {
			prefix = "Forceful",
			suffix = "Forcefulness",
			modifiers = {
				knockback = 1.4641
			},
			flags = InsaneStats.WPASS2_FLAGS.KNOCKBACK,
			weight = 2,
			max = 5
		},
		inspire = {
			prefix = "Inspiring",
			suffix = "Inspiration",
			modifiers = {
				xp = 1.1
			},
			weight = 2,
			flags = InsaneStats.WPASS2_FLAGS.XP
		},
		chaining = {
			prefix = "Chaining",
			modifiers = {
				kill5s_xp = 1.1
			},
			weight = 2,
			flags = InsaneStats.WPASS2_FLAGS.XP
		},
		heal = {
			prefix = "Healing",
			modifiers = {
				kill_lifesteal = 1.21
			},
			max = 10,
			weight = 2
		},
		charge = {
			prefix = "Charging",
			modifiers = {
				kill_armorsteal = 1.21,
				armor_full = 1.1,
				armor_full2 = 1.1
			},
			weight = 2
		},
	},
	
	{-- damage utility
		bolster = {
			prefix = "Bolstering",
			modifiers = {
				kill5s_damagetaken = 1/1.1
			},
			max = 7
		},
		rejuvenate = {
			prefix = "Rejuvenating",
			suffix = "Rejuvenation",
			modifiers = {
				kill5s_regen = 1.21
			},
			max = 10,
			weight = 1
		},
		build = {
			prefix = "Building",
			modifiers = {
				kill5s_armorregen = 1.21,
				armor_full = 1.1,
				armor_full2 = 1.1
			},
			weight = 1
		},
		lethargic = {
			prefix = "Lethargic",
			suffix = "Lethargy",
			modifiers = {
				victim_speed = 1/1.1
			},
			max = 5
		},
		demon = {
			prefix = "Demonic",
			suffix = "Demons",
			modifiers = {
				victim_damage = 1/1.1
			},
			max = 10,
			weight = 1
		},
		intimidate = {
			prefix = "Intimidating",
			suffix = "Intimidation",
			modifiers = {
				victim_firerate = 1/1.1
			},
			max = 10
		},
		manic = {
			prefix = "Manic",
			suffix = "Mania",
			modifiers = {
				killstack_xp = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.XP,
			weight = 1
		},
		practical = {
			prefix = "Practical",
			suffix = "Practicality",
			modifiers = {
				prop_xp = 1.1
			},
			max = 10,
			flags = InsaneStats.WPASS2_FLAGS.XP
		},
		glimmer = {
			prefix = "Glimmering",
			modifiers = {
				armor_xp = 1.1,
			},
			weight = 1
		},
		resist = {
			prefix = "Resisting",
			modifiers = {
				killstack_defence = 1.1
			},
			weight = 1
		},
		supply = {
			prefix = "Supplying",
			modifiers = {
				kill_supplychance = 1.21
			},
			max = 3
		},
		scavenge = {
			prefix = "Scavenging",
			modifiers = {
				prop_supplychance = 1.21
			},
			max = 3
		},
		empathy = {
			prefix = "Empathetic",
			suffix = "Empathy",
			modifiers = {
				ally_damage = 0
			},
			max = 1
		},
		surge = {
			prefix = "Surgical",
			suffix = "Surging",
			modifiers = {
				clip_xp = 1.1
			}
		},
	},
	
	{-- damage utility doubled cost
		starlight = {
			prefix = "Starlit",
			suffix = "Starlight",
			modifiers = {
				starlight = 1.1,
				starlight_defence = 1.1,
				starlight_glow = 1.1
			},
			cost = 2,
			max = 4
		},
	},
	
	{-- damage utility, doubled weight negative cost
		weak = {
			prefix = "Weak",
			suffix = "Weakness",
			modifiers = {
				knockback = 1/1.4641
			},
			flags = InsaneStats.WPASS2_FLAGS.KNOCKBACK,
			weight = 2,
			max = 5,
			cost = -1
		},
		heavy = {
			prefix = "Heavy",
			suffix = "Heaviness",
			modifiers = {
				speed = 1/1.1
			},
			weight = 2,
			max = 5,
			cost = -1
		},
		conscious = {
			prefix = "Conscious",
			suffix = "Consciousness",
			modifiers = {
				ally_xp = -1
			},
			weight = 2,
			cost = -1,
			flags = InsaneStats.WPASS2_FLAGS.XP
		},
	},
	
	{-- damage utility, negative cost
		aggravate = {
			prefix = "Aggravating",
			suffix = "Aggravation",
			modifiers = {
				kill5s_damagetaken = 1.1
			},
			cost = -1
		},
	},
	
	{-- utility
		quick = {
			prefix = "Quick",
			suffix = "Quickness",
			modifiers = {
				speed = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			max = 10
		},
		copy = {
			prefix = "Copycat",
			suffix = "Copying",
			modifiers = {
				copying = 1.21
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
		brisk = {
			prefix = "Brisk",
			suffix = "Brisking",
			modifiers = {
				speed_dilation = 1.1
			},
			max = 5,
			flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.SP_ONLY),
		},
		auxiliary = {
			prefix = "Auxiliary",
			suffix = "Capacity",
			modifiers = {
				aux_drain = 1/1.1
			},
			max = 8,
			flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.SUIT_POWER),
		},
	},
	
	{-- utility, half weight
		sprint = {
			prefix = "Sprinting",
			modifiers = {
				sprint_speed = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			max = 5
		},
		buckle = {
			prefix = "Buckling",
			modifiers = {
				speed_defence = 1.1
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
		respite = {
			prefix = "Respiteful",
			suffix = "Respite",
			modifiers = {
				alt_damagetaken = 1/1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			max = 1
		},
		adrenaline = {
			prefix = "Adrenal",
			suffix = "Adrenaline",
			modifiers = {
				alt_gamespeed = 1/1.1
			},
			flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.SP_ONLY),
			weight = 0.5,
			max = 1
		},
		agile = {
			prefix = "Agile",
			suffix = "Agility",
			modifiers = {
				alt_speed = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			max = 3
		},
		acknowledge = {
			prefix = "Acknowledging",
			suffix = "Acknowledgement",
			modifiers = {
				else_xp = 1.1
			},
			flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.XP),
			weight = 0.5,
			max = 10
		},
		cloaking = {
			prefix = "Cloaking",
			modifiers = {
				alt_invisible = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			max = 2
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
				kill1s_xp = 1.1,
				kill1s_xp2 = 1.1
				--simul_xp = 1.1
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
		rash = {
			prefix = "Rash",
			suffix = "Rashness",
			modifiers = {
				mark = 1.1,
				killstackmarked_damage = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5
		},
		detect = {
			prefix = "Detective",
			suffix = "Detection",
			modifiers = {
				reveal = 1.4641
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			max = 5
		},
		attract = {
			prefix = "Attractive",
			suffix = "Attractiveness",
			modifiers = {
				magnet = 1.4641
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			max = 5
		},
		intense = {
			prefix = "Intense",
			suffix = "Intensity",
			modifiers = {
				critstack_damage = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5
		},
	},
	
	{-- utility, half weight doubled cost
		volatile = {
			prefix = "Volatile",
			suffix = "Volatility",
			modifiers = {
				explode_damage = 1.1,
				explode_damagetaken = 1/1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			cost = 2,
			max = 2
		},
		pyro = {
			prefix = "Pyrogenic",
			suffix = "Pyromancy",
			modifiers = {
				fire_damage = 1.1,
				fire_damagetaken = 1/1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			cost = 2,
			max = 2
		},
		cryo = {
			prefix = "Cryogenic",
			suffix = "Cryomancy",
			modifiers = {
				freeze_damage = 1.1,
				freeze_damagetaken = 1/1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			cost = 2,
			max = 2
		},
		geo = {
			prefix = "Geologic",
			suffix = "Geomancy",
			modifiers = {
				poison_damage = 1.1,
				poison_damagetaken = 1/1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			cost = 2,
			max = 2
		},
		electro = {
			prefix = "Electronic",
			suffix = "Electromancy",
			modifiers = {
				shock_damage = 1.1,
				shock_damagetaken = 1/1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			cost = 2,
			max = 2
		},
		jagged = {
			prefix = "Jagged",
			suffix = "Jaggedness",
			modifiers = {
				bleed_damage = 1.1,
				bleed_damagetaken = 1/1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			cost = 2,
			max = 2
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
		fleeting = {
			prefix = "Fleeting",
			modifiers = {
				ctrl_gamespeed = 1.1,
				ctrl_defence = 1.1
			},
			flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.SP_ONLY),
			weight = 0.5,
			cost = 2,
			max = 1
		},
		sight = {
			prefix = "Sighted",
			suffix = "Sight",
			modifiers = {
				mark = 1.1,
				mark_damage = 1.1,
				mark_damagetaken = 1/1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			cost = 2,
			max = 7
		},
		fester = {
			prefix = "Festering",
			modifiers = {
				ammo_convert = 1/1.1,
				death_promise_damage = 1.1
			},
			flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR),
			weight = 0.5,
			cost = 2,
			max = 10
		},
	},

	{-- utility, negative cost
		massive = {
			prefix = "Massive",
			suffix = "Massiveness",
			modifiers = {
				speed = 1/1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			cost = -1,
			max = 10
		},
		sloppy = {
			prefix = "Sloppy",
			suffix = "Sloppiness",
			modifiers = {
				crit_damage = 1/1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			cost = -1,
			max = 7
		},
	},

	{-- utility, half weight negative cost
		point = {
			prefix = "Pointy",
			suffix = "Pointiness",
			modifiers = {
				sprint_speed = 1/1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			cost = -1,
			max = 5
		},
		mundane = {
			prefix = "Mundane",
			suffix = "Mundanity",
			modifiers = {
				toggle_damage = 1/1.1
			},
			weight = 0.5,
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			cost = -1
		},
	},
	
	{-- defensive
		defend = {
			prefix = "Defensive",
			suffix = "Defending",
			modifiers = {
				damagetaken = 1/1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR
		},
		large = {
			prefix = "Large",
			suffix = "Largeness",
			modifiers = {
				knockbacktaken = 1/1.4641,
				self_knockbacktaken = 1.4641,
			},
			flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.KNOCKBACK),
			max = 5
		},
		bulk = {
			prefix = "Bulky",
			suffix = "Bulkiness",
			modifiers = {
				crit_damagetaken = 1/1.1
			},
			max = 7,
			flags = InsaneStats.WPASS2_FLAGS.ARMOR
		},
		health = {
			prefix = "Healthy",
			suffix = "Health",
			modifiers = {
				health = 1.21
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			max = 10
		},
		armor = {
			prefix = "Armored",
			suffix = "Armoring",
			modifiers = {
				armor = 1.21
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			max = 10
		},
	},
	
	{-- defensive, half weight
		dodge = {
			prefix = "Dodgy",
			suffix = "Dodging",
			modifiers = {
				dodge = 1/1.1,
				dissolvewarning = 1.1
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
				mark = 1.1,
				killstackmarked_defence = 1.1
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
				bloodletting = 1.02,
				armor_full = 1.1,
				armor_full2 = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			max = 25
		},
		glutton = {
			prefix = "Gluttony",
			modifiers = {
				armor_fullpickup = 1.1,
				charger_fullpickup = 1.1,
				armor_full = 1.1,
				armor_full2 = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			max = 7
		},
		ward = {
			prefix = "Warding",
			modifiers = {
				hittakenstack_defence = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5
		},
		revital = {
			prefix = "Revitalizing",
			suffix = "Revitalization",
			modifiers = {
				hittaken_regen = 1.21
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			max = 10,
			weight = 0.5
		},
		shield = {
			prefix = "Shielding",
			modifiers = {
				hittaken_armorregen = 1.21,
				armor_full = 1.1,
				armor_full2 = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5
		},
		sharp = {
			prefix = "Sharp",
			suffix = "Sharpness",
			modifiers = {
				hittaken_invincible = 1.1,
				hittaken_invincible_meleebreak = 1.1,
				dissolvewarning = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			max = 2
		},
		ignorant = {
			prefix = "Ignorant",
			suffix = "Ignorance",
			modifiers = {
				bullet_damagetaken = 1/1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			max = 7
		},
		brave = {
			prefix = "Brave",
			suffix = "Bravery",
			modifiers = {
				highlevel_damagetaken = 1/1.1,
			},
			flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.XP),
			weight = 0.5,
			max = 7
		},
		mystic = {
			prefix = "Mystic",
			suffix = "Mysticality",
			modifiers = {
				hittaken1s_damagetaken = 1/1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			max = 7
		},
		bloodbath = {
			prefix = "Bloodbathing",
			modifiers = {
				crit_lifesteal = 1.21
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			max = 10,
			weight = 0.5
		},
		sap = {
			prefix = "Sapping",
			modifiers = {
				crit_armorsteal = 1.21,
				armor_full = 1.1,
				armor_full2 = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5
		},
		awful = {
			prefix = "Awful",
			suffix = "Awfulness",
			modifiers = {
				back_damagetaken = 1/1.21,
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			max = 2,
		},
		inept = {
			prefix = "Inept",
			suffix = "Ineptivity",
			modifiers = {
				front_damagetaken = 1/1.21,
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			weight = 0.5,
			max = 2,
		},
	},
	
	{-- defensive, half weight doubled cost
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
	},
	
	{-- defensive, negative cost
		tiny = {
			prefix = "Tiny",
			suffix = "Tinyness",
			modifiers = {
				knockbacktaken = 1.4641,
				self_knockbacktaken = 1/1.4641
			},
			flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.KNOCKBACK),
			cost = -1,
			max = 5
		},
		unhappy = {
			prefix = "Unhappy",
			suffix = "Unhappiness",
			modifiers = {
				damagetaken = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			cost = -1
		},
		light = {
			prefix = "Light",
			suffix = "Lightness",
			modifiers = {
				crit_damagetaken = 1.1
			},
			cost = -1,
			flags = InsaneStats.WPASS2_FLAGS.ARMOR
		},
		damaged = {
			prefix = "Damaged",
			suffix = "Damagedness",
			modifiers = {
				armor = 1/1.21
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			cost = -1,
			max = 10
		},
		glass = {
			prefix = "Glass",
			modifiers = {
				health = 1/1.21
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			cost = -1,
			max = 10
		},
	},
	
	{-- defensive, half weight negative cost
		myopia = {
			prefix = "Myopic",
			suffix = "Myopia",
			modifiers = {
				longrange_damagetaken = 1.21
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			cost = -1,
			weight = 0.5
		},
		hypermetropia = {
			prefix = "Hypermetropic",
			suffix = "Hypermetropia",
			modifiers = {
				shortrange_damagetaken = 1.21
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			cost = -1,
			weight = 0.5
		},
		fear = {
			prefix = "Fearful",
			suffix = "Fear",
			modifiers = {
				lowhealth_damagetaken = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			cost = -1,
			weight = 0.5
		},
		boast = {
			prefix = "Boastful",
			suffix = "Boastfulness",
			modifiers = {
				bullet_damagetaken = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			cost = -1,
			weight = 0.5,
		},
		fragile = {
			prefix = "Fragile",
			suffix = "Fragility",
			modifiers = {
				perhittaken_damagetaken = 1.1
			},
			flags = InsaneStats.WPASS2_FLAGS.ARMOR,
			cost = -1,
			weight = 0.5,
		},
		awkward = {
			prefix = "Awkward",
			suffix = "Awkwardness",
			modifiers = {
				lowlevel_damagetaken = 1.1
			},
			weight = 0.5,
			cost = -1,
			flags = bit.bor(InsaneStats.WPASS2_FLAGS.ARMOR, InsaneStats.WPASS2_FLAGS.XP)
		},
	},

	--[[ retired
	point = {
		prefix = "Pointy",
		suffix = "Pointiness",
		modifiers = {
			lowhealth_victim_melee_damage = 1.1
		},
		weight = 0.5,
		flags = InsaneStats.WPASS2_FLAGS.ARMOR
	},
	amplify = {
		prefix = "Amplifying",
		modifiers = {
			amp_armorloss = 1/1.1,
			amp_damage = 1.21
		},
		weight = 0.5,
	},
	menace2 = {
		prefix = "Menacing",
		modifiers = {
			kill_victim_damage = 1/1.1
			kill_victim_firerate = 1/1.1
		},
		weight = 0.5,
		max = 10
	},
	warm = {
		prefix = "Warming",
		modifiers = {
			combat5s_dodge = 1/1.331
		},
		flags = InsaneStats.WPASS2_FLAGS.ARMOR,
		weight = 0.5,
		cost = 2,
		max = 10
	},
	]]
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
	lowhealth_firerate = {
		display = "Up to %s fire rate at low health",
		mul = 5
	},
	highhealth_firerate = {
		display = "Up to %s fire rate at high health",
		mul = 1.25
	},
	lowhealth_victim_damage = {
		display = "Up to %s damage dealt vs. low health",
		mul = 2
	},
	--[[lowhealth_victim_melee_damage = {
		display = "Up to %s melee damage dealt vs. low health",
		mul = 5
	},]]
	high90health_victim_damage = {
		display = "%s damage dealt vs. above 90%% health",
		mul = 5
	},
	lowxhealth_victim_doubledamage = {
		display = "Doubled damage dealt vs. below %s health",
	},
	speed_damage = {
		display = "%s damage dealt, scaled by speed",
		mul = 2
	},
	armor_damage = {
		display = "%s damage dealt, scaled by armor %%",
		mul = 2
	},
	armored_victim_damage = {
		display = "%s damage dealt vs. armored"
	},
	unarmored_victim_damage = {
		display = "%s damage dealt vs. unarmored"
	},
	--[[nonliving_damage = {
		display = "%s damage dealt vs. non-living entities",
		mul = 2
	},]]
	back_damage = {
		display = "%s damage dealt from behind",
		mul = 2.5
	},
	front_damage = {
		display = "%s damage dealt from front",
		mul = 0.625
	},
	crit_damage = {
		display = "%s crit damage dealt",
		mul = 2
	},
	highlevel_damage = {
		display = "%s damage dealt vs. higher levels",
		mul = 2
	},
	lowlevel_damage = {
		display = "%s damage dealt vs. lower levels",
		mul = 2
	},
	--[[oddlevel_damage = {
		display = "%s damage dealt vs. odd levels"
	},
	evenlevel_damage = {
		display = "%s damage dealt vs. even levels"
	},]]
	mark_damage = {
		display = "%s damage dealt vs. marked",
		mul = 2
	},
	ally_damage = {
		display = "%s damage dealt vs. allies unless slow walking",
		invert = true
	},
	random_damage = {
		display = "+/%s random damage dealt",
		mode = 3
	},
	death_promise_damage = {
		display = "%s Corpse Exploder stacks gained",
	},
	--[[perdebuff_damage = {
		display = "%s damage dealt per Insane Stats victim debuff"
	},
	debuff_damage = {
		display = "%s Insane Stats debuff damage dealt",
		mul = 2
	},]]
	explode_damage = {
		display = "%s explosive damage dealt",
		mul = 5
	},
	fire_damage = {
		display = "%s fire damage dealt",
		mul = 10
	},
	poison_damage = {
		display = "%s poison, chemical and radiation damage dealt",
		mul = 10
	},
	freeze_damage = {
		display = "%s freeze and drowning damage dealt",
		mul = 10
	},
	shock_damage = {
		display = "%s shock and fall damage dealt",
		mul = 10
	},
	bleed_damage = {
		display = "%s laceration and bleed damage dealt",
		mul = 10
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
		display = "%s crit damage taken",
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
	highlevel_damagetaken = {
		display = "%s damage taken from higher levels",
		invert = true,
		mul = 2
	},
	lowlevel_damagetaken = {
		display = "%s damage taken from lower levels",
		invert = true,
		mul = 2
	},
	noncombat_damagetaken = {
		display = "%s damage taken out of combat",
		mul = 5,
		invert = true
	},
	back_damagetaken = {
		display = "%s damage taken from behind",
		invert = true,
		mul = 2.5
	},
	front_damagetaken = {
		display = "%s damage taken from front",
		invert = true,
		mul = 0.625
	},
	speed_defence = {
		display = "%s defence, scaled by speed",
		mul = 2
	},
	mark_damagetaken = {
		display = "%s damage taken from marked entities",
		invert = true,
		mul = 2
	},
	--[[oddlevel_damagetaken = {
		display = "%s damage taken on odd levels",
		invert = true
	},
	evenlevel_damagetaken = {
		display = "%s damage taken on even levels",
		invert = true
	},
	perdebuff_defence = {
		display = "%s defence per Insane Stats debuff"
	},
	debuff_damagetaken = {
		display = "%s damage taken from Insane Stats debuffs",
		mul = 2,
		invert = true
	},]]
	explode_damagetaken = {
		display = "%s explosive damage taken",
		mul = 5,
		invert = true
	},
	fire_damagetaken = {
		display = "%s fire damage taken",
		mul = 5,
		invert = true
	},
	poison_damagetaken = {
		display = "%s poison, chemical and radiation damage taken",
		mul = 5,
		invert = true
	},
	freeze_damagetaken = {
		display = "%s freeze and drowning damage taken",
		mul = 5,
		invert = true
	},
	shock_damagetaken = {
		display = "%s shock and fall damage taken",
		mul = 5,
		invert = true
	},
	bleed_damagetaken = {
		display = "%s laceration and bleed damage taken",
		mul = 5,
		invert = true
	},
	
	-- kills and hits
	starlight = {
		display = "%ss starlit from kills and props",
		mul = 30,
		nopercent = true
	},
	starlight_defence = {
		display = "+1%% defence, scaled by starlit duration",
		mul = 30
	},
	starlight_glow = {
		display = "+1 glow power, scaled by starlit duration",
		mul = 30,
		invert = true
	},
	kill_lifesteal = {
		display = "%s healing on kill",
		mul = 0.125
	},
	kill_armorsteal = {
		display = "%s armor recharged on kill",
		mul = 0.125
	},
	kill_clipsteal = {
		display = "%s clip refilled on kill"
	},
	kill_supplychance = {
		display = "%s chance for random item on kill",
	},
	--[[kill_victim_damage = {
		display = "%s damage dealt by nearby enemies on kill",
		invert = true
	},
	kill_victim_firerate = {
		display = "%s fire rate of nearby enemies on kill",
		invert = true
	},]]
	kill5s_damage = {
		display = "%s damage dealt for +5s after kill",
		mul = 2
	},
	kill5s_damagetaken = {
		display = "%s damage taken for +5s after kill",
		mul = 2,
		invert = true
	},
	kill5s_ally_damage = {
		display = "%s damage dealt for +5s after ally kill",
		mul = 5
	},
	kill5s_firerate = {
		display = "%s fire rate for +5s after kill",
		mul = 2
	},
	kill5s_speed = {
		display = "%s movement speed for +5s after kill",
		mul = 2
	},
	kill5s_xp = {
		display = "%s coins and XP gain for +5s after kill",
		mul = 2
	},
	kill5s_regen = {
		display = "%s health regen for +5s after kill",
		mul = 0.03125
	},
	kill5s_armorregen = {
		display = "%s armor regen for +5s after kill",
		mul = 0.03125
	},
	kill5s_damageaura = {
		display = "%s damage aura for +5s after kill",
		nopercent = true,
		mul = 10,
	},
	kill1s_xp = {
		display = "%s coins and XP gain for +1s after kill, scaled by square root of duration",
		mul = 4
	},
	kill1s_xp2 = {
		display = "%s coins and XP gain for +1s from props, scaled by square root of duration",
		mul = 4
	},
	killstack_damage = {
		display = "%s damage dealt per kill, decays over time",
		mul = 0.1
	},
	killstack_firerate = {
		display = "%s fire rate per kill, decays over time",
		mul = 0.1
	},
	killstack_defence = {
		display = "%s defence per kill, decays over time",
		mul = 0.1
	},
	--[[killstack_speed = {
		display = "%s decaying movement speed per kill",
	},]]
	killstack_xp = {
		display = "%s coins and XP gain per kill, decays over time",
		mul = 0.1
	},
	killstackmarked_damage = {
		display = "%s damage dealt per marked kill, decays over time",
		mul = 0.2
	},
	killstackmarked_defence = {
		display = "%s defence per marked kill, decays over time",
		mul = 0.2
	},
	critstack_damage = {
		display = "%s damage dealt per crit, decays over time",
		mul = 0.1
	},
	critstack_firerate = {
		display = "%s fire rate per crit, decays over time",
		mul = 0.1
	},
	hit1s_damage = {
		display = "%s damage dealt, 1s cooldown",
		mul = 2
	},
	hittaken1s_damagetaken = {
		display = "%s damage taken, 1s cooldown",
		mul = 2,
		invert = true
	},
	hit3_damage = {
		display = "%s damage dealt every third hit",
		mul = 3
	},
	hit100_damagepulse = {
		display = "%s damage to visible enemies every 100th hit",
		mul = 10000,
		nopercent = true
	},
	hit100_self_damage = {
		display = "%s damage dealt to self every 100th hit",
		mul = 100,
		invert = true
	},
	hittaken_damage = {
		display = "%s damage dealt for 10s on hit taken, 60s cooldown",
		mul = 8
	},
	hittaken_invincible = {
		display = "%ss invincibility on hit taken, 60s cooldown",
		mul = 60,
		nopercent = true,
		noplus = true
	},
	hittaken_invincible_meleebreak = {
		display = "%ss invincibility per melee hit taken",
		mul = -20,
		nopercent = true
	},
	hittaken_regen = {
		display = "%s health regen for 10s on hit taken, 60s cooldown",
		mul = 0.125
	},
	hittaken_armorregen = {
		display = "%s armor regen for 10s on hit taken, 60s cooldown",
		mul = 0.125
	},
	hittakenstack_defence = {
		display = "%s defence per hit taken, decays over time",
		mul = 0.1
	},
	perhit_victim_damagetaken = {
		display = "%s victim damage taken per hit for 5s",
		mul = 0.1
	},
	perhittaken_damagetaken = {
		display = "%s damage taken per hit taken for 5s",
		mul = 0.1,
		invert = true
	},
	dissolvewarning = {
		display = "Dissolving damage taken ignores invincibility and cannot miss",
		mul = 60,
		invert = true
	},
	
	crit_chance = {
		display = "%s random crit chance",
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
	clip = {
		display = "%s clip size",
	},
	clip_firerate = {
		display = "%s fire rate, scaled by clip %%",
		mul = 2
	},
	lastammo_damage = {
		display = "%s last clip shot damage dealt",
	},
	--[[lastammo_firerate = {
		display = "%s last clip shot fire rate",
	},]]
	ammo_savechance = {
		display = "%s chance to not consume ammo",
		mode = 2
	},
	ammo_convert = {
		display = "Reserve ammo above max %s turned into Corpse Exploder stacks"
	},
	xp = {
		display = "%s coins and XP gain",
	},
	crit_xp = {
		display = "%s coins and XP gain on crit kills",
		mul = 2
	},
	armor_xp = {
		display = "%s XP gain, scaled by armor %%",
		mul = 2
	},
	clip_xp = {
		display = "%s XP gain, scaled by square root of clip %%",
		mul = 2
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
		display = "%s cosmic damage dealt",
		mul = 9
	},
	arc_chance = {
		display = "%s arc damage chance",
		mode = 2
	},
	repeat1s_damage = {
		display = "%s doom damage dealt after 1s",
		mul = 2
	},
	--[[amp_armorloss = {
		display = "At full armor, %s armor converted to amp damage",
		start = math.sqrt(1.1),
		mode = 1,
		invert = true
	},
	amp_damage = {
		display = "%s amp damage",
		start = 10
	},]]
	--[[combat5s_damage = {
		display = "Up to %s damage dealt over 5s in combat",
		mul = 2
	},
	combat5s_firerate = {
		display = "Up to %s fire rate over 5s in combat",
		mul = 2
	},
	combat5s_damagetaken = {
		display = "Up to %s damage taken over 5s in combat",
		mul = 2,
		invert = true
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
	},]]
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
	--[[nonbullet_misschance = {
		display = "%s non-bullet miss chance",
		mode = 2,
		invert = true
	},
	misschance = {
		display = "%s miss chance",
		mode = 2,
		invert = true
	},]]
	prop_xp = {
		display = "%s coins and XP gain from props",
		mul = 0.5
	},
	ally_xp = {
		display = "%s coins and XP gain from allies",
		mode = 3
	},
	crit_lifesteal = {
		display = "%s healing on crit",
		mul = 0.125
	},
	crit_armorsteal = {
		display = "%s armor recharged on crit",
		mul = 0.125
	},
	aimbot = {
		display = "%s bullet aimbot chance"
	},
	prop_supplychance = {
		display = "%s chance for random item from props",
		--mul = 0.5
	},
	penetrate = {
		display = "%s Hu bullet penetration",
		mul = 80,
		nopercent = true
	},
	
	speed_dilation = {
		display = "%s time dilation, scaled by square root of speed"
	},
	--[[dilation = {
		display = "%s time dilation on movement"
	},]]
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
	armor_full = {
		display = "Insane Stats armor gains can exceed full armor",
	},
	armor_full2 = {
		display = "Insane Stats armor gains reduced above full armor",
		invert = true
	},
	dodge = {
		display = "%s dodge chance",
		mode = 2
	},
	retaliation10_damage = {
		display = "%s retaliation damage when hurt 10 times",
		mul = 10
	},
	copying = {
		display = "%s item pickups"
	},
	--[[noncombat_speed = {
		display = "%s movement speed out of combat",
		mul = 2
	},]]
	sprint_speed = {
		display = "%s sprint speed",
		mul = 2
	},
	--[[crouch_speed = {
		display = "%s speed while crouched",
		mul = 2
	},]]
	bloodletting = {
		display = "Health above max %s turned into armor",
		invert = true,
		mode = 2
	},
	armor_fullpickup = {
		display = "Armor batteries overcharge at %s efficiency",
		invert = true,
		mode = 4
	},
	charger_fullpickup = {
		display = "Suit chargers overcharge at %s efficiency",
		invert = true,
		mode = 4
	},
	else_xp = {
		display = "%s XP gain from other's kills",
	},
	alt_invisible = {
		display = "%ss invisibility after slow walk double tap, 60s cooldown",
		mul = 60,
		nopercent = true,
		noplus = true
	},
	alt_damage = {
		display = "%s damage dealt after slow walk double tap, 60s cooldown",
		mul = 8
	},
	alt_firerate = {
		display = "%s fire rate after slow walk double tap, 60s cooldown",
		mul = 8
	},
	alt_speed = {
		display = "%s movement rate after slow walk double tap, 60s cooldown",
		mul = 8
	},
	alt_damagetaken = {
		display = "%s damage taken after slow walk double tap, 60s cooldown",
		invert = true,
		mul = 8
	},
	alt_gamespeed = {
		display = "%s game speed after slow walk double tap, 60s cooldown",
		invert = true,
		mul = 8
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
	mark = {
		display = "Closest enemy is marked on HUD"
	},
	aux_drain = {
		display = "%s aux power drain rate",
		invert = true,
		mul = 2
	},
	ctrl_gamespeed = {
		display = "%s game speed per second while crouch key held",
		invert = true,
		mul = 0.5
	},
	ctrl_defence = {
		display = "%s defence per second while crouch key held",
		mul = 0.5
	},
	reveal = {
		display = "%s button, breakable and door reveal radius",
		mul = 250,
		nopercent = true
	},
	magnet = {
		display = "%s item pull radius",
		mul = 400,
		nopercent = true
	},
}

local canPlayPoisonSound = true
local canPlayFreezeSound = true
local canPlayShockSound = true
local canPlayBleedSound = true
local statusEffects = {
	poison = {
		name = "Poisoned",
		typ = -1,
		img = "poison-bottle",
		apply = SERVER and function(ent, level, duration, attacker)
			if canPlayPoisonSound then
				canPlayPoisonSound = false
				ent:EmitSound(string.format("weapons/bugbait/bugbait_squeeze%u.wav", math.random(3)), 75, 100, 1, CHAN_WEAPON)
				
				local effdata = EffectData()
				effdata:SetOrigin(ent:GetPos())
				effdata:SetEntity(ent)
				effdata:SetScale(1)
				effdata:SetMagnitude(1)
				effdata:SetRadius(16)
				effdata:SetNormal(vector_up)
				util.Effect("StriderBlood", effdata)
			end
		end
	},
	fire = {
		name = "On Fire",
		typ = -1,
		img = "small-fire",
		apply = SERVER and function(ent, level, duration, attacker)
			ent:Ignite(duration)
		end
	},
	freeze = {
		name = "Freezing",
		typ = -1,
		img = "snowflake-2",
		apply = SERVER and function(ent, level, duration, attacker)
			if canPlayFreezeSound then
				canPlayFreezeSound = false
				ent:EmitSound(string.format("physics/glass/glass_sheet_break%u.wav", math.random(3)), 75, 100, 1, CHAN_WEAPON)
				
				local effdata = EffectData()
				effdata:SetOrigin(ent:GetPos())
				effdata:SetScale(1)
				effdata:SetMagnitude(1)
				util.Effect("GlassImpact", effdata)
			end
			
			if ent:IsNPC()
			and ent:InsaneStats_GetStatusEffectLevel("stun_immune") <= 0
			and ent:InsaneStats_GetStatusEffectLevel("stunned") <= 0
			and ent:InsaneStats_GetHealth() > 0 then
				ent:InsaneStats_ApplyStatusEffect("stunned", 1, 2)
			end
		end
	},
	shock = {
		name = "Shocked",
		typ = -1,
		img = "lightning-frequency",
		apply = SERVER and function(ent, level, duration, attacker)
			if canPlayShockSound then
				canPlayShockSound = false
				ent:EmitSound("ambient/energy/weld1.wav", 75, 100, 1, CHAN_WEAPON)

				local effdata = EffectData()
				effdata:SetOrigin(ent:GetPos())
				effdata:SetNormal(vector_up)
				effdata:SetAngles(angle_zero)
				util.Effect("ManhackSparks", effdata)
			end
		end
	},
	bleed = {
		name = "Bleeding",
		typ = -1,
		img = "droplets",
		apply = SERVER and function(ent, level, duration, attacker)
			if canPlayBleedSound then
				canPlayBleedSound = false
				ent:EmitSound(string.format("npc/manhack/grind_flesh%u.wav", math.random(3)), 75, 100, 1, CHAN_WEAPON)

				local effdata = EffectData()
				effdata:SetOrigin(ent:GetPos())
				effdata:SetEntity(ent)
				effdata:SetStart(attacker:GetPos())
				effdata:SetHitBox(0)
				effdata:SetFlags(3)
				effdata:SetColor(0)
				effdata:SetScale(10)
				effdata:SetMagnitude(1)
				util.Effect("bloodspray", effdata)
			end
		end
	},
	hemotoxin = {
		name = "Hemotoxicated",
		typ = -1,
		img = "spotted-wound",
		apply = SERVER and function(ent, level, duration, attacker)
			if canPlayPoisonSound then
				canPlayPoisonSound = false
				ent:EmitSound(string.format("weapons/bugbait/bugbait_squeeze%u.wav", math.random(3)), 75, 100, 1, CHAN_WEAPON)
				
				local effdata = EffectData()
				effdata:SetOrigin(ent:GetPos())
				effdata:SetEntity(ent)
				effdata:SetScale(1)
				effdata:SetMagnitude(1)
				effdata:SetRadius(16)
				effdata:SetNormal(vector_up)
				util.Effect("StriderBlood", effdata)
			end
			if canPlayBleedSound then
				canPlayBleedSound = false
				ent:EmitSound(string.format("npc/manhack/grind_flesh%u.wav", math.random(3)), 75, 100, 1, CHAN_WEAPON)
				
				local effdata = EffectData()
				effdata:SetOrigin(ent:GetPos())
				effdata:SetEntity(ent)
				effdata:SetStart(attacker:GetPos())
				effdata:SetHitBox(0)
				effdata:SetFlags(3)
				effdata:SetColor(0)
				effdata:SetScale(10)
				effdata:SetMagnitude(1)
				util.Effect("bloodspray", effdata)
			end
		end
	},
	frostfire = {
		name = "Frostfire",
		typ = -1,
		img = "frostfire",
		apply = SERVER and function(ent, level, duration, attacker)
			ent:Ignite(duration)
			if canPlayFreezeSound then
				canPlayFreezeSound = false
				ent:EmitSound(string.format("physics/glass/glass_sheet_break%u.wav", math.random(3)), 75, 100, 1, CHAN_WEAPON)
				
				local effdata = EffectData()
				effdata:SetOrigin(ent:GetPos())
				effdata:SetScale(1)
				effdata:SetMagnitude(1)
				util.Effect("GlassImpact", effdata)
			end
			
			if ent:IsNPC()
			and ent:InsaneStats_GetStatusEffectLevel("stun_immune") <= 0
			and ent:InsaneStats_GetStatusEffectLevel("stunned") <= 0
			and ent:InsaneStats_GetHealth() > 0 then
				ent:InsaneStats_ApplyStatusEffect("stunned", 1, 2)
			end
		end
	},
	electroblast = {
		name = "Electroblasted",
		typ = -1,
		img = "sonic-lightning",
		apply = SERVER and function(ent, level, duration, attacker)
			if canPlayShockSound then
				canPlayShockSound = false
				ent:EmitSound("ambient/energy/weld1.wav", 75, 100, 1, CHAN_WEAPON)

				local effdata = EffectData()
				effdata:SetOrigin(ent:GetPos())
				effdata:SetNormal(vector_up)
				effdata:SetAngles(angle_zero)
				util.Effect("ManhackSparks", effdata)
			end
		end
	},
	cosmicurse = {
		name = "Cosmic Annihilation",
		typ = -1,
		img = "black-hole-bolas",
		apply = SERVER and function(ent, level, duration, attacker)
			ent:Ignite(duration)
			if canPlayPoisonSound then
				canPlayPoisonSound = false
				ent:EmitSound(string.format("weapons/bugbait/bugbait_squeeze%u.wav", math.random(3)), 75, 100, 1, CHAN_WEAPON)

				local effdata = EffectData()
				effdata:SetOrigin(ent:GetPos())
				effdata:SetEntity(ent)
				effdata:SetScale(1)
				effdata:SetMagnitude(1)
				effdata:SetRadius(16)
				effdata:SetNormal(vector_up)
				util.Effect("StriderBlood", effdata)
			end
			if canPlayFreezeSound then
				canPlayFreezeSound = false
				ent:EmitSound(string.format("physics/glass/glass_sheet_break%u.wav", math.random(3)), 75, 100, 1, CHAN_WEAPON)
				
				local effdata = EffectData()
				effdata:SetOrigin(ent:GetPos())
				effdata:SetScale(1)
				effdata:SetMagnitude(1)
				util.Effect("GlassImpact", effdata)
			end
			if canPlayBleedSound then
				canPlayBleedSound = false
				ent:EmitSound(string.format("npc/manhack/grind_flesh%u.wav", math.random(3)), 75, 100, 1, CHAN_WEAPON)
				
				local effdata = EffectData()
				effdata:SetOrigin(ent:GetPos())
				effdata:SetEntity(ent)
				effdata:SetStart(attacker:GetPos())
				effdata:SetHitBox(0)
				effdata:SetFlags(3)
				effdata:SetColor(0)
				effdata:SetScale(10)
				effdata:SetMagnitude(1)
				util.Effect("bloodspray", effdata)
			end
			if canPlayShockSound then
				canPlayShockSound = false
				ent:EmitSound("ambient/energy/weld1.wav", 75, 100, 1, CHAN_WEAPON)

				local effdata = EffectData()
				effdata:SetOrigin(ent:GetPos())
				effdata:SetNormal(vector_up)
				effdata:SetAngles(angle_zero)
				util.Effect("ManhackSparks", effdata)
			end
			
			if ent:IsNPC()
			and ent:InsaneStats_GetStatusEffectLevel("stun_immune") <= 0
			and ent:InsaneStats_GetStatusEffectLevel("stunned") <= 0
			and ent:Health() > 0 then
				ent:InsaneStats_ApplyStatusEffect("stunned", 1, 2)
			end
		end
	},
	doom = {
		name = "Doomed",
		typ = -1,
		img = "shark-jaws",
		expiry = SERVER and function(ent, level, attacker)
			hook.Run("InsaneStatsWPASS2Doom", ent, level, attacker)
		end
	},
	
	stunned = {
		name = "Stunned",
		typ = -1,
		img = "coma",
		apply = SERVER and function(ent, level, duration, attacker)
			if ent:IsNPC() then
				ent:SetSchedule(SCHED_NPC_FREEZE)
			elseif ent:IsPlayer() then
				ent:Freeze(true)
			end
		end,
		expiry = SERVER and function(ent, level, attacker)
			if ent:IsNPC() and level > 0 then
				ent:SetCondition(68)
			elseif ent:IsPlayer() then
				ent:Freeze(false)
			end
			ent:InsaneStats_ApplyStatusEffect("stun_immune", 1, 2)
		end
	},
	stun_immune = {
		name = "Stun Immunity",
		typ = 1,
		img = "surprised"
	},
	retaliation10_buildup = {
		name = "Retaliation Buildup",
		typ = 1,
		img = "shield-reflect"
	},
	hit100_selfdamage_stacks = {
		name = "Dangerous Buildup",
		typ = -1,
		img = "dread-skull"
	},
	perhit_defence_down = {
		name = "Hurtful Defence Down",
		typ = -1,
		img = "skull-crack"
	},
	hit3_damage_stacks = {
		name = "Strong Buildup",
		typ = 2,
		img = "hatchets"
	},
	hit100_damagepulse_stacks = {
		name = "Godly Buildup",
		typ = 2,
		img = "orbital-rays"
	},
	--[[hit10s_damage_up = {
		name = "Unpleasant Damage Up",
		typ = 2,
		img = "pointy-sword",
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("hit10s_damage_cooldown", 1, 60)
		end
	},]]
	hit1s_damage_cooldown = {
		name = "Unpleasancy Cooldown",
		typ = -1,
		img = "shattered-sword"
	},
	--[[hit10s_firerate_up = {
		name = "Mystical Fire Rate Up",
		typ = 2,
		img = "striking-arrows",
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("hit10s_firerate_cooldown", 1, 60)
		end
	},]]
	hittaken1s_damagetaken_cooldown = {
		name = "Mystical Cooldown",
		typ = -1,
		img = "cracked-shield"
	},
	hittaken_invincible = {
		name = "Sharp Invincibility",
		typ = 2,
		img = "mesh-ball",
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("hittaken_invincible_cooldown", 1, 60)
		end
	},
	hittaken_invincible_cooldown = {
		name = "Sharp Invincibility Cooldown",
		typ = -2,
		img = "caged-ball"
	},
	hittaken_damage_up = {
		name = "Fury Damage Up",
		typ = 2,
		img = "pointy-sword",
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("hittaken_damage_cooldown", 1, 60)
		end
	},
	hittaken_damage_cooldown = {
		name = "Fury Cooldown",
		typ = -1,
		img = "sword-in-stone"
	},
	hittaken_regen = {
		name = "Revitalizing Regeneration",
		typ = 2,
		img = "heart-bottle",
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("hittaken_regen_cooldown", 1, 60)
		end
	},
	hittaken_regen_cooldown = {
		name = "Revitalization Cooldown",
		typ = -1,
		img = "square-bottle"
	},
	hittaken_armorregen = {
		name = "Shielding Armor Regeneration",
		typ = 2,
		img = "bolt-shield",
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("hittaken_armorregen_cooldown", 1, 60)
		end
	},
	hittaken_armorregen_cooldown = {
		name = "Shielding Cooldown",
		typ = -1,
		img = "bottled-bolt"
	},
	
	damage_down = {
		name = "Damage Down",
		typ = -1,
		img = "shattered-sword"
	},
	defence_down = {
		name = "Defence Down",
		typ = -1,
		img = "cracked-shield"
	},
	speed_down = {
		name = "Speed Down",
		typ = -1,
		img = "snail"
	},
	firerate_down = {
		name = "Fire Rate Down",
		typ = -1,
		img = "spoon"
	},
	damage_up = {
		name = "Damage Up",
		typ = 1,
		img = "pointy-sword"
	},
	defence_up = {
		name = "Defence Up",
		typ = 1,
		img = "checked-shield"
	},
	speed_up = {
		name = "Speed Up",
		typ = 1,
		img = "sprint"
	},
	firerate_up = {
		name = "Fire Rate Up",
		typ = 1,
		img = "striking-arrows"
	},
	xp_up = {
		name = "Loot Up",
		typ = 1,
		img = "cool-spices"
	},
	arcane_damage_up = {
		name = "Arcane Damage Up",
		typ = 1,
		img = "pointy-sword",
		expiry = SERVER and function(ent, level, attacker)
			local value = ent:InsaneStats_GetAttributeValue("toggle_damage")
			if value > 1 then
				ent:InsaneStats_ApplyStatusEffect("arcane_defence_up", value * 100 - 100, 5)
			elseif value < 1 then
				ent:InsaneStats_ApplyStatusEffect("mundane_defence_down", 100 / value - 100, 5)
			end
		end
	},
	arcane_defence_up = {
		name = "Arcane Defence Up",
		typ = 1,
		img = "checked-shield",
		expiry = SERVER and function(ent, level, attacker)
			local stacks = (ent:InsaneStats_GetAttributeValue("toggle_damage")-1)*100
			if stacks > 0 then
				ent:InsaneStats_ApplyStatusEffect("arcane_damage_up", stacks, 5)
			elseif stacks < 0 then
				ent:InsaneStats_ApplyStatusEffect("mundane_damage_down", -stacks, 5)
			end
		end
	},
	mundane_damage_down = {
		name = "Mundane Damage Down",
		typ = -1,
		img = "shattered-sword",
		expiry = SERVER and function(ent, level, attacker)
			local value = ent:InsaneStats_GetAttributeValue("toggle_damage")
			if value > 1 then
				ent:InsaneStats_ApplyStatusEffect("arcane_defence_up", value * 100 - 100, 5)
			elseif value < 1 then
				ent:InsaneStats_ApplyStatusEffect("mundane_defence_down", 100 / value - 100, 5)
			end
		end
	},
	mundane_defence_down = {
		name = "Mundane Defence Down",
		typ = -1,
		img = "cracked-shield",
		expiry = SERVER and function(ent, level, attacker)
			local stacks = (ent:InsaneStats_GetAttributeValue("toggle_damage")-1)*100
			if stacks > 0 then
				ent:InsaneStats_ApplyStatusEffect("arcane_damage_up", stacks, 5)
			elseif stacks < 0 then
				ent:InsaneStats_ApplyStatusEffect("mundane_damage_down", -stacks, 5)
			end
		end
	},
	regen = {
		name = "Regeneration",
		typ = 1,
		img = "heart-bottle"
	},
	armor_regen = {
		name = "Armor Regeneration",
		typ = 1,
		img = "bolt-shield"
	},
	damage_aura = {
		name = "Damage Aura",
		typ = 1,
		img = "broken-heart-zone"
	},
	masterful_xp = {
		name = "Loot Power",
		typ = 1,
		img = "crystal-shine"
	},
	air_jumped = {
		name = "Extra Jump Used",
		typ = -1,
		img = "fluffy-trefoil"
	},
	death_promise = {
		name = "Corpse Exploder",
		typ = 2,
		img = "death-note"
	},
	
	starlight = {
		name = "Starlit",
		typ = 0,
		img = "sundial",
		expiry = SERVER and function(ent, level, attacker)
			for i,v in ipairs(ent:GetChildren()) do
				if v.insaneStats_IsStarlight then
					SafeRemoveEntityDelayed(v, 1)
				end
			end
		end
	},
	invincible = {
		name = "Invincible",
		typ = 1,
		img = "mesh-ball"
	},
	invisible = {
		name = "Invisible",
		typ = 2,
		img = "domino-mask",
		apply = function(ent, level, duration, attacker)
			ent:AddFlags(FL_NOTARGET)
			ent:RemoveFlags(FL_AIMTARGET)
			ent:AddEffects(bit.bor(EF_NOSHADOW, EF_NODRAW, EF_NORECEIVESHADOW))
		end,
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
		img = "one-eyed"
	},
	alt_damage_up = {
		name = "Nasty Damage Up",
		typ = 2,
		img = "pointy-sword",
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("alt_damage_cooldown", 1, 60)
		end
	},
	alt_damage_cooldown = {
		name = "Nasty Cooldown",
		typ = -1,
		img = "sword-in-stone"
	},
	alt_defence_up = {
		name = "Respite Defence Up",
		typ = 2,
		img = "checked-shield",
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("alt_defence_cooldown", 1, 60)
		end
	},
	alt_defence_cooldown = {
		name = "Respite Cooldown",
		typ = -1,
		img = "zebra-shield"
	},
	alt_firerate_up = {
		name = "Haste Fire Rate Up",
		typ = 2,
		img = "striking-arrows",
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("alt_firerate_cooldown", 1, 60)
		end
	},
	alt_firerate_cooldown = {
		name = "Haste Cooldown",
		typ = -1,
		img = "hand"
	},
	alt_gamespeed_down = {
		name = "Adrenaline Game Speed Down",
		typ = 2,
		img = "sands-of-time",
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("alt_gamespeed_cooldown", 1, 60)
		end
	},
	alt_gamespeed_cooldown = {
		name = "Adrenaline Cooldown",
		typ = -1,
		img = "life-support"
	},
	alt_speed_up = {
		name = "Agility Movement Rate Up",
		typ = 2,
		img = "pentarrows-tornado",
		expiry = SERVER and function(ent, level, attacker)
			ent:InsaneStats_ApplyStatusEffect("alt_speed_cooldown", 1, 60)
		end
	},
	alt_speed_cooldown = {
		name = "Agility Cooldown",
		typ = -1,
		img = "twirly-flower"
	},
	ctrl_gamespeed_up = {
		name = "Fleeting Game Speed Up",
		typ = -1,
		img = "clockwork"
	},
	ctrl_defence_up = {
		name = "Fleeting Defence Up",
		typ = 1,
		img = "checked-shield"
	},
	stack_damage_up = {
		name = "Stacking Damage Up",
		typ = 2,
		img = "pointy-sword"
	},
	stack_firerate_up = {
		name = "Stacking Fire Rate Up",
		typ = 2,
		img = "striking-arrows"
	},
	stack_defence_up = {
		name = "Stacking Defence Up",
		typ = 2,
		img = "checked-shield"
	},
	--[[stack_speed_up = {
		name = "Stacking Speed Up",
		typ = 2,
		img = "sprint"
	},]]
	stack_xp_up = {
		name = "Stacking Loot Up",
		typ = 2,
		img = "cool-spices"
	},
}


hook.Add("InsaneStatsWPASS2AttributesChanged", "InsaneStatsSharedWPASS2", function(ent)
	if ent:IsWeapon() and ent:IsScripted() then
		local oldClipMul = ent.insaneStats_WPASS2ClipMul or 1
		local newClipMul = ent:InsaneStats_GetAttributes().clip or 1
		
		local weaponTable = ent:GetTable()
		local entNewMaxClip1 = weaponTable.Primary
			and tonumber(weaponTable.Primary.ClipSize)
			and weaponTable.Primary.ClipSize * newClipMul / oldClipMul or -1
		local entNewMaxClip2 = weaponTable.Secondary
			and tonumber(weaponTable.Secondary.ClipSize)
			and weaponTable.Secondary.ClipSize * newClipMul / oldClipMul or -1
		
		if entNewMaxClip1 > 0 then
			weaponTable.Primary.ClipSize = math.ceil(entNewMaxClip1)
			--print(entNewMaxClip1)
		end
		if entNewMaxClip2 > 0 then
			weaponTable.Secondary.ClipSize = math.ceil(entNewMaxClip2)
			--print(entNewMaxClip2)
		end

		-- disabled, as addons that override weapon giving break this functionality
		--[[if SERVER then
			local entNewClip1 = ent:Clip1() * newClipMul / oldClipMul
			local entNewClip2 = ent:Clip2() * newClipMul / oldClipMul
			ent:SetClip1(entNewClip1)
			ent:SetClip2(entNewClip2)
		end]]
		
		ent.insaneStats_WPASS2ClipMul = newClipMul
		ent.insaneStats_WPASS2SpreadMul = ent:InsaneStats_GetAttributes().spread
		ent.insaneStats_WPASS2BulletsMul = ent:InsaneStats_GetAttributes().bullets
		
		--[[if wepAttributes.clip and wep:IsScripted() then
			if weaponTable.Primary then
				weaponTable.Primary.ClipSize = math.ceil(weaponTable.Primary.ClipSize * wepAttributes.clip)
			end
			if weaponTable.Secondary then
				weaponTable.Secondary.ClipSize = math.ceil(weaponTable.Secondary.ClipSize * wepAttributes.clip)
			end
		end]]
	end
end)

-- ArcCW compatibility.
-- FIXME: We're hogging this hook all for ourselves... wouldn't there exist other addons that use this hook too?
hook.Add("Hook_GetCapacity", "InsaneStatsSharedWPASS2", function(wep, value)
	if wep.insaneStats_WPASS2ClipMul then
		return math.ceil(value * wep.insaneStats_WPASS2ClipMul)
	end
end)
hook.Add("Hook_ModDispersion", "InsaneStatsSharedWPASS2", function(wep, value)
	if wep.insaneStats_WPASS2SpreadMul then
		return value * wep.insaneStats_WPASS2SpreadMul
	end
end)
hook.Add("M_Hook_Mult_Num", "InsaneStatsSharedWPASS2", function(wep, data)
	local value = wep.insaneStats_WPASS2BulletsMul or 1
	if not (CLIENT and value < 2) then
		data.mult = data.mult * ((math.random() < value % 1) and math.ceil or math.floor)(value)
	end
end)

-- ARC9 compatibility.
-- FIXME: ditto
hook.Add("ARC9_SpreadHook", "InsaneStatsSharedWPASS2", function(wep, value)
	if wep.insaneStats_WPASS2SpreadMul then
		return value * wep.insaneStats_WPASS2SpreadMul
	end
end)
hook.Add("ARC9_ClipSizeHook", "InsaneStatsSharedWPASS2", function(wep, value)
	if wep.insaneStats_WPASS2ClipMul then
		return math.ceil(value * wep.insaneStats_WPASS2ClipMul)
	end
end)
hook.Add("ARC9_UBGLClipSizeHook", "InsaneStatsSharedWPASS2", function(wep, value)
	if wep.insaneStats_WPASS2ClipMul then
		return math.ceil(value * wep.insaneStats_WPASS2ClipMul)
	end
end)
hook.Add("ARC9_NumHook", "InsaneStatsSharedWPASS2", function(wep, value)
	if wep.insaneStats_WPASS2BulletsMul then
		value = value * wep.insaneStats_WPASS2BulletsMul
		return ((math.random() < value % 1) and math.ceil or math.floor)(value)
	end
end)

-- TFA compatibility. They said it couldn't be done!
-- FIXME: ditto
hook.Add("TFA_GetStat", "InsaneStatsSharedWPASS2", function(wep, stat, value)
	if value then
		if wep.insaneStats_WPASS2ClipMul and (stat == "Primary.ClipSize" or stat == "Secondary.ClipSize") then
			return math.ceil(value * wep.insaneStats_WPASS2ClipMul)
		elseif wep.insaneStats_WPASS2SpreadMul and (stat == "Primary.Spread" or stat == "Secondary.Spread" or stat == "Primary.Accuracy" or stat == "Secondary.Accuracy") then
			return value * wep.insaneStats_WPASS2SpreadMul
		--[[elseif wep.insaneStats_WPASS2BulletsMul and (stat == "Primary.NumShots" or stat == "Secondary.NumShots") then
			value = value * wep.insaneStats_WPASS2BulletsMul
			return ((math.random() < value % 1) and math.ceil or math.floor)(value)]]
		end
	end
end)

hook.Add("InsaneStatsModifyNextFire", "InsaneStatsSharedWPASS2", function(data)
	local attacker = data.attacker
	if IsValid(attacker) and data.next > CurTime() then
		--local combatFraction = SERVER and math.Clamp(attacker:InsaneStats_GetCombatTime()/5, 0, 1) or 0
		local wep = data.wep
		local totalMul = attacker:InsaneStats_GetAttributeValue("firerate")
	
		if IsValid(wep) then
			if wep:GetClass() == "weapon_physcannon" then return end
			if wep.Clip1 then
				local clip1 = wep:Clip1()
				local maxClip1 = wep:GetMaxClip1()
				local clip1Fraction = clip1 / maxClip1
				if maxClip1 <= 0 then
					clip1Fraction = 1
				end
				totalMul = totalMul * (1 + (attacker:InsaneStats_GetAttributeValue("clip_firerate") - 1) * clip1Fraction)
				
				--[[if clip1 < 2 then
					totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("lastammo_firerate")
				end]]
			end

			wep:InsaneStats_SetEntityData("last_fired_t4d", CurTime())
		end

		local healthFraction = 1-math.Clamp(attacker:InsaneStats_GetHealth() / attacker:InsaneStats_GetMaxHealth(), 0, 1)
		--totalMul = totalMul * (1 + (attacker:InsaneStats_GetAttributeValue("combat5s_firerate") - 1) * combatFraction)
		totalMul = totalMul * (1 + (attacker:InsaneStats_GetAttributeValue("lowhealth_firerate") - 1) * healthFraction)
		totalMul = totalMul * (1 + (attacker:InsaneStats_GetAttributeValue("highhealth_firerate") - 1) * (1 - healthFraction))
		
		totalMul = totalMul * (1 + attacker:InsaneStats_GetStatusEffectLevel("firerate_up")/100)
		totalMul = totalMul * (1 + attacker:InsaneStats_GetStatusEffectLevel("alt_firerate_up")/100)
		--totalMul = totalMul * (1 + attacker:InsaneStats_GetStatusEffectLevel("hit10s_firerate_up")/100)
		totalMul = totalMul * (1 + attacker:InsaneStats_GetStatusEffectLevel("stack_firerate_up")/100)
		totalMul = totalMul * (1 - attacker:InsaneStats_GetStatusEffectLevel("firerate_down")/100)
		--totalMul = totalMul * (1 - attacker:InsaneStats_GetStatusEffectLevel("menacing_firerate_down")/100)

		-- SKILLS

		if attacker:IsPlayer() and attacker:InsaneStats_GetSkillStacks("stabilization") > 0 then
			timer.Simple(0, function()
				if IsValid(attacker) then
					attacker:ViewPunchReset()
				end
			end)
		end

		totalMul = totalMul * (1 + attacker:InsaneStats_GetEffectiveSkillValues("pew_pew_pew")/100)
		totalMul = totalMul * (1 + attacker:InsaneStats_GetSkillStacks("increase_the_pressure")/100)
		totalMul = totalMul * (1 + attacker:InsaneStats_GetStatusEffectLevel("skill_firerate_up")/100)

		if game.SinglePlayer() then
			totalMul = totalMul * (1 + attacker:InsaneStats_GetEffectiveSkillValues("spongy", 2)/100)
		end
	
		if IsValid(wep) then
			if wep.Clip1 then
				local clip1 = wep:Clip1()
				local maxClip1 = wep:GetMaxClip1()
				local clip1Fraction = clip1 / maxClip1
				if maxClip1 <= 0 then
					clip1Fraction = 1
				end
				totalMul = totalMul * (1 + attacker:InsaneStats_GetEffectiveSkillValues("its_high_noon")/100 * clip1Fraction)
			end

			wep:InsaneStats_SetEntityData("last_fired_t4d", CurTime())

			if attacker:InsaneStats_EffectivelyHasSkill("its_high_noon") then
				if wep.Primary then
					wep.Primary.Automatic = true
				end
				if wep.Secondary then
					wep.Secondary.Automatic = true
				end
			end
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
		
		--[[if combatFraction <= 0 then
			speedMul = speedMul * ent:InsaneStats_GetAttributeValue("noncombat_speed")
		end]]
		
		--speedMul = speedMul * (1 + ent:InsaneStats_GetStatusEffectLevel("stack_speed_up") / 100)
	
		speedMul = speedMul
		* (1+ent:InsaneStats_GetStatusEffectLevel("speed_up")/100)
		--* (1+ent:InsaneStats_GetStatusEffectLevel("alt_speed_up")/100)
		* (1-ent:InsaneStats_GetStatusEffectLevel("speed_down")/100)
		
		if ent:InsaneStats_GetStatusEffectLevel("freeze") > 0
		or ent:InsaneStats_GetStatusEffectLevel("frostfire") > 0
		or ent:InsaneStats_GetStatusEffectLevel("cosmicurse") > 0 then
			speedMul = speedMul / 2
		end

		local laggedSpeedMul = 1 + ent:InsaneStats_GetStatusEffectLevel("alt_speed_up")/100

		-- SKILLS

		speedMul = speedMul * (1 + ent:InsaneStats_GetEffectiveSkillValues("quintessence", 3) / 100)
		* (1 + ent:InsaneStats_GetEffectiveSkillValues("speed") / 100)
		* (1 + ent:InsaneStats_GetEffectiveSkillValues("bloodletters_revelation") / 100 * (1 - healthFraction))
		--* (1 + ent:InsaneStats_GetEffectiveSkillValues("super_cold") / 100 * ent:InsaneStats_GetSkillStacks("super_cold"))
		--* (1 + ent:InsaneStats_GetEffectiveSkillValues("fast_er") / 100)

		if ent:InsaneStats_GetSkillStacks("hunting_spirit") > 0 then
			speedMul = speedMul * (1 + ent:InsaneStats_GetEffectiveSkillValues("hunting_spirit") / 100)
		end
		if ent:InsaneStats_GetSkillState("skip_the_scenery") == 1 then
			speedMul = speedMul * (1 + ent:InsaneStats_GetEffectiveSkillValues("skip_the_scenery") / 100)
		end
		if ent:InsaneStats_EffectivelyHasSkill("blast_proof_suit") then
			speedMul = speedMul * 0.75
		end
		--laggedSpeedMul = laggedSpeedMul * (1 + ent:InsaneStats_GetEffectiveSkillValues("fast_er", 2) / 100)
		if game.SinglePlayer() then
			speedMul = speedMul * (1 + ent:InsaneStats_GetEffectiveSkillValues("panic") / 100 * healthFraction)
			* (1 + ent:InsaneStats_GetEffectiveSkillValues("spongy", 4)/100)

			if ent:InsaneStats_GetSkillState("just_breathe") == 1 then
				laggedSpeedMul = laggedSpeedMul * (1 + ent:InsaneStats_GetEffectiveSkillValues("just_breathe", 3) / 100)
			end
		end
		
		data.speed = data.speed * speedMul
		data.sprintSpeed = data.sprintSpeed * ent:InsaneStats_GetAttributeValue("sprint_speed")
		data.sprintSpeed = data.sprintSpeed * (1 + ent:InsaneStats_GetEffectiveSkillValues("zoomer") / 100)
		--data.crouchedSpeed = data.crouchedSpeed * ent:InsaneStats_GetAttributeValue("crouch_speed")
		data.laggedSpeed = data.laggedSpeed * laggedSpeedMul
	end
end)

hook.Add("EntityEmitSound","InsaneStatsSharedWPASS2",function(sound)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		local ent = sound.Entity
		if (IsValid(ent) and (
			ent:InsaneStats_GetAttributeValue("alt_invisible") ~= 1
			or ent:InsaneStats_EffectivelyHasSkill("sneak_100")
		) and ent:GetNoDraw()) then
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
		if not wep:IsScripted() and wep:Clip1() > wep:GetMaxClip1() and wep:GetMaxClip1() > 0 then
			usercmd:RemoveKey(IN_RELOAD)
		end
	end
end)

hook.Add("SetupMove", "InsaneStatsSharedWPASS2", function(ply, movedata, usercmd)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		if ply:InsaneStats_GetSkillState("fight_for_your_life") == 1 then
			local newbuttons = bit.bor(IN_DUCK, bit.band(
				movedata:GetButtons(),
				bit.bnot(bit.bor(IN_JUMP, IN_SPEED))
			))
			movedata:SetButtons(newbuttons)
		end
		if movedata:KeyPressed(IN_WALK) then
			if (ply.insaneStats_LastAltPress or 0) + 0.5 > CurTime() and (ply.insaneStats_LastAltPress or 0) < CurTime() then
				ply.insaneStats_LastAltPress = 0
				
				local duration = ply:InsaneStats_GetAttributeValue("alt_invisible") - 1
				if ply:InsaneStats_GetStatusEffectLevel("invisible_cooldown") <= 0 and duration ~= 0 and not ply:GetNoDraw() then
					ply:InsaneStats_ApplyStatusEffect("invisible", 1, duration)
				end
				
				local stacks = (ply:InsaneStats_GetAttributeValue("alt_damage") - 1) * 100
				if ply:InsaneStats_GetStatusEffectLevel("alt_damage_cooldown") <= 0
				and ply:InsaneStats_GetStatusEffectLevel("alt_damage_up") <= 0
				and stacks ~= 0 then
					ply:InsaneStats_ApplyStatusEffect("alt_damage_up", stacks, 10)
				end
				
				stacks = (ply:InsaneStats_GetAttributeValue("alt_speed") - 1) * 100
				if ply:InsaneStats_GetStatusEffectLevel("alt_speed_cooldown") <= 0
				and ply:InsaneStats_GetStatusEffectLevel("alt_speed_up") <= 0
				and stacks ~= 0 then
					ply:InsaneStats_ApplyStatusEffect("alt_speed_up", stacks, 10)
				end
				
				stacks = 100 / ply:InsaneStats_GetAttributeValue("alt_damagetaken") - 100
				if ply:InsaneStats_GetStatusEffectLevel("alt_defence_cooldown") <= 0
				and ply:InsaneStats_GetStatusEffectLevel("alt_defence_up") <= 0
				and stacks ~= 0 then
					ply:InsaneStats_ApplyStatusEffect("alt_defence_up", stacks, 10)
				end
				
				stacks = (ply:InsaneStats_GetAttributeValue("alt_firerate") - 1) * 100
				if ply:InsaneStats_GetStatusEffectLevel("alt_firerate_cooldown") <= 0
				and ply:InsaneStats_GetStatusEffectLevel("alt_firerate_up") <= 0
				and stacks ~= 0 then
					ply:InsaneStats_ApplyStatusEffect("alt_firerate_up", stacks, 10)
				end
				
				stacks = (1 - ply:InsaneStats_GetAttributeValue("alt_gamespeed")) * 100
				if ply:InsaneStats_GetStatusEffectLevel("alt_gamespeed_cooldown") <= 0
				and ply:InsaneStats_GetStatusEffectLevel("alt_gamespeed_down") <= 0
				and stacks ~= 0 then
					ply:InsaneStats_ApplyStatusEffect("alt_gamespeed_down", stacks, 10)
				end

				if ply:InsaneStats_GetSkillState("sneak_100") == 0
				and not ply:GetNoDraw()
				and ply:InsaneStats_EffectivelyHasSkill("sneak_100") then
					ply:AddFlags(FL_NOTARGET)
					ply:RemoveFlags(FL_AIMTARGET)
					ply:AddEffects(bit.bor(EF_NOSHADOW, EF_NODRAW, EF_NORECEIVESHADOW))
					ply:InsaneStats_SetSkillData("sneak_100", 1, 10)
				end

				if ply:InsaneStats_GetSkillState("just_breathe") == 0
				and ply:InsaneStats_EffectivelyHasSkill("just_breathe") then
					if not game.SinglePlayer() and SERVER then
						local skillTier = ply:InsaneStats_GetEffectiveSkillTier("just_breathe")
						for i,v in ents.Iterator() do
							if ply:InsaneStats_IsValidAlly(v) then
								v:InsaneStats_ApplyStatusEffect("charge", skillTier, 10)
							end
						end
					end

					ply:InsaneStats_SetSkillData("just_breathe", 1, 10)
				end
			else
				ply.insaneStats_LastAltPress = CurTime()
			end
		end
		if ply:OnGround() then
			ply:InsaneStats_ClearStatusEffect("air_jumped")
			if ply:InsaneStats_GetSkillState("jumper") ~= 0 and ply:InsaneStats_EffectivelyHasSkill("jumper") then
				ply:InsaneStats_SetSkillData("jumper", 0, ply:InsaneStats_GetEffectiveSkillValues("jumper"))
			end
		else
			if ply:InsaneStats_GetSkillState("jumper") == 0 and ply:InsaneStats_EffectivelyHasSkill("jumper") then
				ply:InsaneStats_SetSkillData("jumper", 1, ply:InsaneStats_GetEffectiveSkillValues("jumper"))
			end
			if movedata:KeyPressed(IN_JUMP) then
				local canWPASS2Jump = ply:InsaneStats_GetStatusEffectLevel("air_jumped") + 1 < ply:InsaneStats_GetAttributeValue("jumps")
				local canSkillJump = ply:InsaneStats_GetSkillStacks("jumper") > 0
				if canWPASS2Jump or canSkillJump then
					if canSkillJump then
						local newStacks = ply:InsaneStats_GetSkillStacks("jumper") - 1
						ply:InsaneStats_SetSkillData("jumper", newStacks <= 0 and -1 or 1, newStacks)
					elseif canWPASS2Jump then
						ply:InsaneStats_ApplyStatusEffect("air_jumped", 1, 5, {amplify = true})
					end

					-- vertical
					local currentVel = movedata:GetVelocity()
					local jumppower = ply:GetJumpPower() -- - currentVel.z
					local desiredVector = vector_up * jumppower
					
					-- horizontal
					local horizontalVector = Vector(currentVel.x, currentVel.y, 0)
					local buttons = usercmd:GetButtons()
					local shuntStrength = (bit.band(buttons,IN_SPEED)~=0 and ply:GetRunSpeed() or ply:GetWalkSpeed())
					local Forward = (bit.band(buttons,IN_FORWARD)~=0 and 1 or 0) + (bit.band(buttons,IN_BACK)~=0 and -1 or 0)
					if Forward~=0 then
						horizontalVector:Add(ply:GetForward() * shuntStrength * Forward)
					end
					local Right = (bit.band(buttons,IN_MOVERIGHT)~=0 and 1 or 0) + (bit.band(buttons,IN_MOVELEFT)~=0 and -1 or 0)
					if Right~=0 then
						horizontalVector:Add(ply:GetRight() * shuntStrength * Right)
					end
					local maxSpeed = movedata:GetMaxSpeed() * 1.5
					if horizontalVector:LengthSqr() > maxSpeed^2 then
						horizontalVector:Normalize()
						horizontalVector:Mul(maxSpeed)
					end

					desiredVector:Add(horizontalVector)
					movedata:SetVelocity(desiredVector)
				end
			end
		end
	end
end)

local penetrations = 0
local shouldAddBullets = true
local commonTraceData = {
	mask = MASK_SHOT
}
hook.Add("EntityFireBullets", "InsaneStatsSharedWPASS2", function(attacker, data)
	if InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled") then
		if shouldAddBullets then
			local newNum = data.Num * attacker:InsaneStats_GetAttributeValue("bullets")
			if data.AmmoType == "Pistol" or data.AmmoType == "357" then
				newNum = newNum * (1 + attacker:InsaneStats_GetEffectiveSkillValues("one_with_the_gun", 3) / 100)
			end

			data.Num = ((math.random() < newNum % 1) and math.ceil or math.floor)(newNum)
			if data.Num <= 0 then return false end
		end

		local spreadMult = attacker:InsaneStats_GetAttributeValue("spread")

		spreadMult = spreadMult * (1 + attacker:InsaneStats_GetEffectiveSkillValues("stabilization") / 100)
		spreadMult = spreadMult / (1 + attacker:InsaneStats_GetStatusEffectLevel("skill_accuracy_up") / 100)
		if data.AmmoType == "Pistol" or data.AmmoType == "357" then
			spreadMult = spreadMult * (1 + attacker:InsaneStats_GetEffectiveSkillValues("one_with_the_gun", 2) / 100)
		end
		
		data.Spread:Mul(spreadMult)

		local developer = InsaneStats:IsDebugLevel(1)
		local penetrationPower = attacker:InsaneStats_GetAttributeValue("penetrate") - 1
		if attacker:InsaneStats_GetSkillState("silver_bullets") == 1 then
			penetrationPower = penetrationPower + attacker:InsaneStats_GetEffectiveSkillValues("silver_bullets", 2)
		end
		if penetrationPower > 0 and penetrations < 100 then
			-- FIXME: in some cases, bullet penetration will incorrectly pierce
			-- hollow objects as if they were completely solid
			local oldCallback = data.Callback
			local newBullet = {
				Force = data.Force,
				Distance = data.Distance,
				HullSize = data.HullSize,
				Num = 1,
				Tracer = data.Tracer,
				AmmoType = data.AmmoType,
				TracerName = data.TracerName,
				Dir = data.Dir
			}
			data.Callback = function(attacker, trace, dmginfo, ...)
				if oldCallback then
					oldCallback(attacker, trace, dmginfo, ...)
				end

				if trace.Hit then
					-- make a new trace that is in the entity
					local push = 1
					commonTraceData.start = trace.HitPos + data.Dir * push
					commonTraceData.endpos = data.Dir * penetrationPower
					commonTraceData.endpos:Add(commonTraceData.start)
					if trace.HitNonWorld then
						commonTraceData.filter = trace.Entity
						--commonTraceData.ignoreworld = false
					else
						commonTraceData.filter = nil
						--commonTraceData.ignoreworld = true
					end
					--commonTraceData.ignoreworld = true
					if developer then
						debugoverlay.Cross(commonTraceData.start, 5, 10, color_red, true)
						debugoverlay.Cross(commonTraceData.endpos, 6, 10, color_green, true)
					end
					local lastTraceResults = util.TraceLine(commonTraceData)

					if lastTraceResults.Hit or util.IsInWorld(lastTraceResults.HitPos) then
						if developer then
							debugoverlay.Cross(lastTraceResults.HitPos, 7, 10, color_yellow, true)
							debugoverlay.Text(
								lastTraceResults.HitPos,
								tostring(lastTraceResults.Entity)..", "..lastTraceResults.FractionLeftSolid,
								10
							)
						end

						local wallThickness
						if lastTraceResults.FractionLeftSolid > 0 then
							wallThickness = push + penetrationPower * lastTraceResults.FractionLeftSolid
						else
							-- determine thickness of the penetrated object by making a reverse trace
							wallThickness = push + penetrationPower * lastTraceResults.Fraction
							-- wallThickness is currently the length of the original penetration trace
							commonTraceData.start = lastTraceResults.HitPos
							commonTraceData.endpos = trace.HitPos
							commonTraceData.filter = nil
							--commonTraceData.ignoreworld = false
							--commonTraceData.ignoreworld = false
							--debugoverlay.Line(commonTraceData.start, commonTraceData.endpos, 5, color_red, true)
							lastTraceResults = util.TraceLine(commonTraceData)
							wallThickness = wallThickness * (1 - lastTraceResults.Fraction)
						end

						if wallThickness > push and wallThickness < penetrationPower then
							local powerMult = 1 - wallThickness / penetrationPower
							-- create a new bullet that doesn't travel as far and deals less damage
							newBullet.Force = newBullet.Force * powerMult
							newBullet.Distance = newBullet.Distance * powerMult
							newBullet.Damage = dmginfo:GetDamage() * powerMult
							newBullet.Src = trace.HitPos + data.Dir * (wallThickness + push)
							--debugoverlay.Line(trace.HitPos, newBullet.Src, 5, color_aqua, true)
							debugoverlay.Cross(newBullet.Src, 8, 10, color_white, true)

							shouldAddBullets = false
							attacker:FireBullets(newBullet, true)
							shouldAddBullets = true
						end
					end
				end
			end
		end
	end
end)

hook.Add("Think", "InsaneStatsSharedWPASS2", function()
	penetrations = 0
	if SERVER then
		canPlayPoisonSound = true
		canPlayFreezeSound = true
		canPlayBleedSound = true
		canPlayShockSound = true
	end
end)

hook.Add("InsaneStatsLoadWPASS", "InsaneStatsSharedWPASS2", function(currentModifiers, currentAttributes, currentStatusEffects)
	for i,v in ipairs(modifiers) do
		table.Merge(currentModifiers, v)
	end
	table.Merge(currentAttributes, attributes)
	table.Merge(currentStatusEffects, statusEffects)
end)

hook.Add("InsaneStatsEffectiveSpeed", "InsaneStatsSharedWPASS2", function(data)
	local ent = data.ent
	if ent:InsaneStats_EffectivelyHasSkill("beyond_240_kmph") then
		local mult, add = ent:InsaneStats_GetEffectiveSkillValues("beyond_240_kmph")
		mult = (1 + mult / 100)
		add = add * 4
		data.speed = (data.speed + add) * mult
	end
end)