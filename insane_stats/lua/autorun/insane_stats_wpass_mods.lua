local modifiers = {
	damaging = {
		prefix = "Damaging",
		modifiers = {
			damage = 1.1
		},
		weight = 2
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
			knockback = 1.21
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
	accurate = {
		prefix = "Accurate",
		suffix = "Accuracy",
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
		flags = 2
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
	
	crit = {
		prefix = "Critical",
		suffix = "Criticality",
		modifiers = {
			crit_chance = 1.1
		},
		weight = 0.5,
		max = 7
	},
	long = {
		prefix = "Long",
		suffix = "Range",
		modifiers = {
			longrange_damage = 1.21,
			melee_damage = 1.1
		},
		weight = 0.5
	},
	short = {
		prefix = "Short",
		suffix = "Scattering",
		modifiers = {
			shortrange_damage = 1.21
		},
		weight = 0.5
	},
	arc = {
		prefix = "Arcing",
		modifiers = {
			arc_chance = 1/1.21
		},
		weight = 0.5
	},
	anger = {
		prefix = "Angry",
		suffix = "Anger",
		modifiers = {
			lowhealth_damage = 1.4641
		},
		weight = 0.5
	},
	death = {
		prefix = "Deadly",
		suffix = "Death",
		modifiers = {
			lowhealth_victim_damage = 1.21
		},
		weight = 0.5
	},
	surprise = {
		prefix = "Surprising",
		suffix = "Surprise",
		modifiers = {
			high90health_victim_damage = 1.4641
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
	chain = {
		prefix = "Chaining",
		modifiers = {
			kill5s_damage = 1.1,
			kill5s_speed = 1.1
		},
		weight = 0.5,
		max = 10
	},
	hold = {
		prefix = "Holding",
		modifiers = {
			clip = 1.21,
			lastammo_damage = 1.1
		},
		max = 10,
		weight = 0.5,
		flags = 4
	},
	frenzy = {
		prefix = "Frenzying",
		suffix = "Frenziness",
		modifiers = {
			kill5s_damage = 1.1,
			kill5s_firerate = 1.1
		},
		weight = 0.5,
		max = 10
	},
	kinetic = {
		prefix = "Kinetic",
		suffix = "Kinesis",
		modifiers = {
			speed_damage = 1.21
		},
		weight = 0.5
	},
	bloodbath = {
		prefix = "Bloodbathing",
		modifiers = {
			lifesteal = 1.1
		},
		weight = 0.5,
		max = 7
	},
	amplify = {
		prefix = "Amplifying",
		modifiers = {
			amp_armorloss = 1/1.1,
			amp_damage = 1.21
		},
		weight = 0.5,
	},
	
	savage = {
		prefix = "Savage",
		suffix = "Savageness",
		modifiers = {
			combat5s_damage = 1.331,
		},
		weight = 0.5,
		cost = 2
	},
	gatling = {
		prefix = "Gatling",
		modifiers = {
			combat5s_firerate = 1.331,
		},
		weight = 0.5,
		max = 5,
		cost = 2
	},
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
			melee_damage = 1.1
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
	slow = {
		prefix = "Slowing",
		modifiers = {
			victim_speed = 1/1.331
		},
		weight = 0.5,
		max = 10,
		cost = 2
	},
	wound = {
		prefix = "Wounding",
		modifiers = {
			victim_damagetaken = 1.331
		},
		weight = 0.5,
		cost = 2
	},
	demon = {
		prefix = "Demonic",
		suffix = "Demons",
		modifiers = {
			victim_damage = 1/1.331
		},
		weight = 0.5,
		cost = 2
	},
	intimidate = {
		prefix = "Intimidating",
		suffix = "Intimidation",
		modifiers = {
			victim_firerate = 1/1.331
		},
		weight = 0.5,
		max = 5,
		cost = 2
	},
	ruthless = {
		prefix = "Ruthless",
		suffix = "Ruthlessness",
		modifiers = {
			knockback = 1/1.21,
			damage = 1.331
		},
		weight = 0.5,
		max = 10,
		cost = 2
	},
	blunt = {
		prefix = "Blunt",
		suffix = "Bluntness",
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
			knockback = 1.21,
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
		max = 10,
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
		max = 10,
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
	lazy = {
		prefix = "Lazy",
		suffix = "Laziness",
		modifiers = {
			clip = 1/1.21,
			lastammo_damage = 1/1.1,
			damage = 1.331
		},
		weight = 0.5,
		max = 10,
		cost = 2,
		flags = 4
	},
	practical = {
		prefix = "Practical",
		suffix = "Practicality",
		modifiers = {
			prop_xp = 1.1
		},
		weight = 0.5,
		max = 7,
		cost = 2,
		flags = 2
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
		flags = 2
	},
	rejuvenate = {
		prefix = "Rejuvenating",
		suffix = "Rejuvenation",
		modifiers = {
			kill_lifesteal = 1.1
		},
		weight = 0.5,
		max = 7,
		cost = 2
	},
	charge = {
		prefix = "Charging",
		modifiers = {
			kill_armorsteal = 1.1
		},
		weight = 0.5,
		max = 7,
		cost = 2
	},
	
	defend = {
		prefix = "Defensive",
		suffix = "Defending",
		modifiers = {
			damagetaken = 1/1.1
		},
		flags = 1
	},
	immove = {
		prefix = "Immovable",
		suffix = "Immoving",
		modifiers = {
			knockbacktaken = 1/1.21
		},
		flags = 1,
		max = 10
	},
	bunk = {
		prefix = "Bunk",
		suffix = "Bunking",
		modifiers = {
			crit_damagetaken = 1/1.21
		},
		flags = 1
	},
	health = {
		prefix = "Healthy",
		suffix = "Health",
		modifiers = {
			health = 1.21
		},
		flags = 1
	},
	armor = {
		prefix = "Armored",
		suffix = "Armoring",
		modifiers = {
			armor = 1.21
		},
		flags = 1
	},
	dodge = {
		prefix = "Dodgy",
		suffix = "Dodging",
		modifiers = {
			dodge = 1/1.1
		},
		flags = 1,
		max = 10
	},
	speed = {
		prefix = "Speedy",
		suffix = "Speed",
		modifiers = {
			speed = 1.1
		},
		flags = 1,
		max = 10
	},
	blast_proof = {
		prefix = "Blast-Proof",
		suffix = "Blast-Proofing",
		modifiers = {
			explode_damagetaken = 1.1^-4
		},
		flags = 1
	},
	fire_proof = {
		prefix = "Fire-Proof",
		suffix = "Fire-Proofing",
		modifiers = {
			fire_damagetaken = 1.1^-4
		},
		flags = 1
	},
	respiration = {
		prefix = "Respirational",
		suffix = "Respiration",
		modifiers = {
			freeze_damagetaken = 1.1^-4
		},
		flags = 1
	},
	volatile = {
		prefix = "Volatile",
		suffix = "Volatility",
		modifiers = {
			explode_damage = 1.1^4
		},
		flags = 1
	},
	thorn = {
		prefix = "Thorny",
		suffix = "Thorns",
		modifiers = {
			retaliation_damage = 1.1
		},
		flags = 1
	},
	supplying = {
		prefix = "Supplying",
		modifiers = {
			supplying = 1.21
		},
		flags = 1,
		max = 10
	},
	
	dampening = {
		prefix = "Dampening",
		modifiers = {
			longrange_damagetaken = 1/1.21
		},
		flags = 1,
		weight = 0.5
	},
	blanking = {
		prefix = "Blanking",
		modifiers = {
			shortrange_damagetaken = 1/1.21
		},
		flags = 1,
		weight = 0.5
	},
	rash = {
		prefix = "Rash",
		suffix = "Rashness",
		modifiers = {
			perdebuff_damage = 1.1
		},
		flags = 1,
		weight = 0.5
	},
	caution = {
		prefix = "Cautious",
		suffix = "Caution",
		modifiers = {
			noncombat_damagetaken = 1/1.21
		},
		flags = 1,
		weight = 0.5
	},
	brisk = {
		prefix = "Brisk",
		suffix = "Briskiness",
		modifiers = {
			noncombat_speed = 1.21
		},
		flags = 1,
		weight = 0.5,
		max = 10
	},
	panic = {
		prefix = "Panicking",
		modifiers = {
			lowhealth_speed = 1.331
		},
		flags = 1,
		weight = 0.5,
		max = 10
	},
	brave = {
		prefix = "Brave",
		suffix = "Bravery",
		modifiers = {
			lowhealth_damagetaken = 1/1.331
		},
		flags = 1,
		weight = 0.5
	},
	haste = {
		prefix = "Hasty",
		suffix = "Haste",
		modifiers = {
			sprint_speed = 1.21
		},
		flags = 1,
		weight = 0.5,
		max = 10
	},
	chemical_proof = {
		prefix = "Hazmat",
		suffix = "Chemical-Proofing",
		modifiers = {
			poison_damagetaken = 1.1^-8
		},
		flags = 1,
		weight = 0.5
	},
	shock_proof = {
		prefix = "Shock-Proof",
		suffix = "Shock-Proofing",
		modifiers = {
			shock_damagetaken = 1.1^-8
		},
		flags = 1,
		weight = 0.5
	},
	bandaging = {
		prefix = "Bandaging",
		modifiers = {
			bleed_damagetaken = 1.1^-8
		},
		flags = 1,
		weight = 0.5
	},
	oiling = {
		prefix = "Oiled",
		suffix = "Oiling",
		modifiers = {
			fire_damage = 1.1^8
		},
		flags = 1,
		weight = 0.5
	},
	catalyzing = {
		prefix = "Catalyzing",
		modifiers = {
			poison_damage = 1.1^8
		},
		flags = 1,
		weight = 0.5
	},
	choking = {
		prefix = "Choking",
		modifiers = {
			freeze_damage = 1.1^8
		},
		flags = 1,
		weight = 0.5
	},
	surging = {
		prefix = "Surging",
		modifiers = {
			shock_damage = 1.1^8
		},
		flags = 1,
		weight = 0.5
	},
	jagged = {
		prefix = "Jagged",
		suffix = "Jaggedness",
		modifiers = {
			bleed_damage = 1.1^8
		},
		flags = 1,
		weight = 0.5
	},
	precise = {
		prefix = "Precise",
		suffix = "Precision",
		modifiers = {
			crit_damage = 1.1
		},
		flags = 1,
		weight = 0.5
	},
	bloodletting = {
		prefix = "Bloodletting",
		modifiers = {
			bloodletting = 0.99
		},
		flags = 1,
		weight = 0.5
	},
	buckle = {
		prefix = "Buckling",
		modifiers = {
			speed_damagetaken = 1/1.21
		},
		flags = 1,
		weight = 0.5
	},
	empower = {
		prefix = "Empowering",
		modifiers = {
			killstack_damage = 1.002
		},
		flags = 1,
		weight = 0.5
	},
	resist = {
		prefix = "Resisting",
		modifiers = {
			killstack_resistance = 1.002
		},
		flags = 1,
		weight = 0.5
	},
	pace = {
		prefix = "Pacing",
		modifiers = {
			killstack_speed = 1.002
		},
		flags = 1,
		weight = 0.5,
		max = 10
	},
	manic = {
		prefix = "Manic",
		suffix = "Mania",
		modifiers = {
			killstack_xp = 1.002
		},
		flags = 3,
		weight = 0.5
	},
	ward = {
		prefix = "Warding",
		modifiers = {
			debuff_damagetaken = 1/1.21
		},
		flags = 1,
		weight = 0.5
	},
	fleeting = {
		prefix = "Fleeting",
		modifiers = {
			kill5s_damagetaken = 1/1.1,
			kill5s_speed = 1.1
		},
		flags = 1,
		weight = 0.5
	},
	acknowledge = {
		prefix = "Acknowledging",
		suffix = "Acknowledgement",
		modifiers = {
			else_xp = 1.1
		},
		flags = 3,
		weight = 0.5,
		max = 7
	},
	cloaking = {
		prefix = "Cloaking",
		modifiers = {
			alt_invisible = 1.21
		},
		flags = 1,
		weight = 0.5,
		max = 10
	},
	
	overbear = {
		prefix = "Overbearing",
		modifiers = {
			damage = 1/1.1,
			damagetaken = 1/1.331
		},
		flags = 1,
		weight = 0.5,
		cost = 2
	},
	aggravate = {
		prefix = "Aggravating",
		suffix = "Aggravation",
		modifiers = {
			damagetaken = 1.1,
			damage = 1.331,
		},
		flags = 1,
		weight = 0.5,
		cost = 2
	},
	harden = {
		prefix = "Hardening",
		modifiers = {
			combat5s_damagetaken = 1/1.331
		},
		flags = 1,
		weight = 0.5,
		cost = 2
	},
	warm = {
		prefix = "Warming",
		modifiers = {
			combat5s_dodge = 1/1.331
		},
		flags = 1,
		weight = 0.5,
		cost = 2,
		max = 10
	},
	chunk = {
		prefix = "Chunky",
		suffix = "Chunkiness",
		modifiers = {
			speed = 1/1.1,
			damagetaken = 1/1.331
		},
		flags = 1,
		weight = 0.5,
		cost = 2,
		max = 10
	},
	light = {
		prefix = "Light",
		suffix = "Lightness",
		modifiers = {
			damagetaken = 1.1,
			speed = 1.331
		},
		flags = 1,
		weight = 0.5,
		cost = 2,
		max = 10
	},
	jump = {
		prefix = "Jumpy",
		suffix = "Jumping",
		modifiers = {
			jumps = 1
		},
		flags = 1,
		weight = 0.5,
		cost = 2,
		max = 3
	},
	regen = {
		prefix = "Regenerating",
		suffix = "Regeneration",
		modifiers = {
			combat5s_regen = 1.1^0.5
		},
		flags = 1,
		weight = 0.5,
		cost = 2,
		max = 10
	},
	
}

local attributes = {
	damage = {
		display = "%s damage dealt",
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
	nonbullet_damage = {
		display = "%s non-bullet damage dealt",
	},
	clip = {
		display = "%s clip size",
	},
	lastammo_damage = {
		display = "%s last clip shot damage dealt",
	},
	xp = {
		display = "%s XP gain",
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
	longrange_damage = {
		display = "%s long range damage dealt",
	},
	shortrange_damage = {
		display = "%s short range damage dealt",
	},
	melee_damage = {
		display = "%s melee damage dealt",
	},
	arc_chance = {
		display = "%s arc damage chance",
		mode = 2
	},
	lowhealth_damage = {
		display = "Up to %s damage dealt at low health",
	},
	lowhealth_victim_damage = {
		display = "Up to %s damage dealt against low health entities",
	},
	high90health_victim_damage = {
		display = "%s damage dealt against entities above 90%% health",
	},
	lowxhealth_victim_doubledamage = {
		display = "Doubled damage dealt against entities below %s health",
	},
	repeat1s_damage = {
		display = "%s doom damage dealt after 1 to 1.5s",
	},
	kill5s_damage = {
		display = "%s damage dealt for 5s after kill",
	},
	kill5s_firerate = {
		display = "%s fire rate for 5s after kill",
	},
	kill5s_speed = {
		display = "%s movement speed for 5s after kill",
	},
	speed_damage = {
		display = "%s damage dealt, scaled by velocity",
	},
	lifesteal = {
		display = "Up to %s life steal based on squared victim distance",
	},
	amp_armorloss = {
		display = "At full armor, %s armor converted to amp damage",
		start = 1.1,
		mode = 1,
		invert = true
	},
	amp_damage = {
		display = "%s amp damage",
		start = 5
	},
	combat5s_damage = {
		display = "Up to %s damage dealt over 5s in combat",
	},
	combat5s_firerate = {
		display = "Up to %s fire rate over 5s in combat",
	},
	speed = {
		display = "%s movement speed",
	},
	longrange_nonbullet_damage = {
		display = "%s long range non-bullet damage dealt",
	},
	shortrange_nonbullet_damage = {
		display = "%s short range non-bullet damage dealt",
	},
	victim_speed = {
		display = "%s victim movement speed for 2s",
		invert = true
	},
	victim_damagetaken = {
		display = "%s victim damage taken for 2s",
	},
	victim_damage = {
		display = "%s victim damage dealt for 2s",
		invert = true
	},
	victim_firerate = {
		display = "%s victim fire rate for 2s",
		invert = true
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
	},
	ally_xp = {
		display = "%s XP gain from allies",
		start = 0,
		mode = 3
	},
	kill_lifesteal = {
		display = "%s healing on kill",
	},
	kill_armorsteal = {
		display = "%s armor on kill, reduced above full armor",
	},
	
	damagetaken = {
		display = "%s damage taken",
		invert = true
	},
	crit_damagetaken = {
		display = "%s critical damage taken",
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
	knockbacktaken = {
		display = "%s knockback taken",
		invert = true
	},
	health = {
		display = "%s health",
	},
	armor = {
		display = "%s armor",
	},
	dodge = {
		display = "%s dodge chance",
		mode = 2
	},
	crit_damage = {
		display = "%s critical damage dealt",
	},
	retaliation_damage = {
		display = "%s retaliation damage"
	},
	perdebuff_damage = {
		display = "%s damage dealt per Insane Stats victim debuff"
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
	supplying = {
		display = "%s item pickups"
	},
	noncombat_damagetaken = {
		display = "%s damage taken out of combat",
		invert = true
	},
	noncombat_speed = {
		display = "%s movement speed out of combat",
	},
	lowhealth_damagetaken = {
		display = "Up to %s damage taken at low health",
		invert = true
	},
	lowhealth_speed = {
		display = "Up to %s movement speed at low health",
	},
	sprint_speed = {
		display = "%s sprint speed",
	},
	bloodletting = {
		display = "Health above %s turned into armor, reduced above full armor",
		start = 2,
		mode = 1
	},
	speed_damagetaken = {
		display = "%s damage taken, scaled by velocity",
		invert = true
	},
	killstack_damage = {
		display = "%s damage dealt per kill, decays over time",
	},
	killstack_resistance = {
		display = "%s damage resistance per kill, decays over time",
	},
	killstack_speed = {
		display = "%s movement speed per kill, decays over time",
	},
	killstack_xp = {
		display = "%s XP gain per kill, decays over time",
	},
	debuff_damagetaken = {
		display = "%s damage taken from Insane Stats debuffs",
		invert = true
	},
	kill5s_damagetaken = {
		display = "%s damage taken for 5s after kill",
		invert = true
	},
	else_xp = {
		display = "%s XP gain from other's kills",
	},
	alt_invisible = {
		display = "%ss invisibility after Alt double tap, 60s cooldown",
		start = 5,
		nopercent = true
	},
	combat5s_damagetaken = {
		display = "Up to %s damage taken over 5s in combat",
		invert = true
	},
	combat5s_dodge = {
		display = "Up to %s dodge chance over 5s in combat",
		mode = 2
	},
	jumps = {
		display = "%s extra jumps",
		mode = 3,
		nopercent = true
	},
	combat5s_regen = {
		display = "Up to %s health regen over 5s in combat"
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
		img = Material("insane_stats/status_effects/cold-heart.png", "mips smooth")
	},
	shock = {
		name = "Shocked",
		typ = -1,
		img = Material("insane_stats/status_effects/focused-lightning.png", "mips smooth")
	},
	bleed = {
		name = "Bleeding",
		typ = -1,
		img = Material("insane_stats/status_effects/droplets.png", "mips smooth")
	},
	doom = {
		name = "Doomed",
		typ = -1,
		img = Material("insane_stats/status_effects/shark-jaws.png", "mips smooth")
	},
	invisible = {
		name = "Invisible",
		typ = 1,
		img = Material("insane_stats/status_effects/ninja_mask.png", "mips smooth")
	},
	invisible_cooldown = {
		name = "Invisibility Cooldown",
		typ = -1,
		img = Material("insane_stats/status_effects/one-eyed.png", "mips smooth")
	},
	
	damage_down = {
		name = "Damage Down",
		typ = -1,
		img = Material("insane_stats/status_effects/shattered-sword.png", "mips smooth")
	},
	defence_down = {
		name = "Defence Down",
		typ = -1,
		img = Material("insane_stats/status_effects/slashed-shield.png", "mips smooth")
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
		img = Material("insane_stats/status_effects/dripping-sword.png", "mips smooth")
	},
	defence_up = {
		name = "Defence Up",
		typ = 1,
		img = Material("insane_stats/status_effects/bordered-shield.png", "mips smooth")
	},
	speed_up = {
		name = "Speed Up",
		typ = 1,
		img = Material("insane_stats/status_effects/dodging.png", "mips smooth")
	},
	firerate_up = {
		name = "Fire Rate Up",
		typ = 1,
		img = Material("insane_stats/status_effects/striking-arrows.png", "mips smooth")
	},
	stack_damage_up = {
		name = "Stacking Damage Up",
		typ = 2,
		img = Material("insane_stats/status_effects/dripping-sword.png", "mips smooth")
	},
	stack_defence_up = {
		name = "Stacking Defence Up",
		typ = 2,
		img = Material("insane_stats/status_effects/bordered-shield.png", "mips smooth")
	},
	stack_speed_up = {
		name = "Stacking Speed Up",
		typ = 2,
		img = Material("insane_stats/status_effects/dodging.png", "mips smooth")
	},
	stack_xp_up = {
		name = "Stacking XP Up",
		typ = 2,
		img = Material("insane_stats/status_effects/brain.png", "mips smooth")
	}
}

local isStatusEffectDamage = false
local isArcingDamage = false
local blastDamageTypes = bit.bor(DMG_BLAST, DMG_BLAST_SURFACE)
local fireDamageTypse = bit.bor(DMG_BURN, DMG_SLOWBURN)
local poisonDamageTypes = bit.bor(DMG_PARALYZE, DMG_NERVEGAS, DMG_POISON, DMG_RADIATION, DMG_ACID)
local shockDamageTypes = bit.bor(DMG_FALL, DMG_SHOCK)

local function CalculateDamage(vic, attacker, dmginfo)
	local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon()
	if math.random() < attacker:InsaneStats_GetAttributeValue("misschance") - 1 then return true end
	if math.random() < vic:InsaneStats_GetAttributeValue("dodge") - 1 then return true end
	
	local totalMul = attacker:InsaneStats_GetAttributeValue("damage")
	local knockbackMul = attacker:InsaneStats_GetAttributeValue("knockback")
	
	totalMul = totalMul * vic:InsaneStats_GetAttributeValue("damagetaken")
	knockbackMul = knockbackMul * vic:InsaneStats_GetAttributeValue("knockbacktaken")
	
	local isNotBulletDamage = not dmginfo:IsBulletDamage()
	local attackerHealthFraction = 1-math.Clamp(attacker:InsaneStats_GetFractionalHealth() / attacker:InsaneStats_GetFractionalMaxHealth(), 0, 1)
	local attackerArmorFraction = attacker:InsaneStats_GetFractionalArmor() > 0
		and 1-math.Clamp(attacker:InsaneStats_GetFractionalArmor() / attacker:InsaneStats_GetFractionalMaxArmor(), 0, 1) or 0
	local victimHealthFraction = 1-math.Clamp(vic:InsaneStats_GetFractionalHealth() / vic:InsaneStats_GetFractionalMaxHealth(), 0, 1)
	local attackerSpeedFraction = attacker:GetVelocity():Length() / 400
	local victimSpeedFraction = vic:GetVelocity():Length() / 400
	local attackerCombatFraction = math.Clamp(attacker:InsaneStats_GetCombatTime()/5, 0, 1)
	local victimCombatFraction = math.Clamp(vic:InsaneStats_GetCombatTime()/5, 0, 1)
	
	local combatDodgeChance = (vic:InsaneStats_GetAttributeValue("combat5s_dodge") - 1) * victimCombatFraction
	if math.random() < combatDodgeChance then return true end
	
	if isNotBulletDamage then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("nonbullet_damage")
		if math.random() < attacker:InsaneStats_GetAttributeValue("nonbullet_misschance") - 1 then return true end
	end
	if dmginfo:IsDamageType(blastDamageTypes) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("explode_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("explode_damagetaken")
	end
	if dmginfo:IsDamageType(fireDamageTypse) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("fire_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("fire_damagetaken")
	end
	if dmginfo:IsDamageType(poisonDamageTypes) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("poison_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("poison_damagetaken")
	end
	if dmginfo:IsDamageType(DMG_DROWN) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("freeze_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("freeze_damagetaken")
	end
	if dmginfo:IsDamageType(shockDamageTypes) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("shock_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("shock_damagetaken")
	end
	if dmginfo:IsDamageType(DMG_SLASH) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("bleed_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("bleed_damagetaken")
	end
	if dmginfo:IsDamageType(DMG_CLUB) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("melee_damage")
	end
	if (IsValid(wep) and wep:Clip1() < 2) then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("lastammo_damage")
	end
	if attacker:GetPos():DistToSqr(vic:GetPos()) > 65536 then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("longrange_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("longrange_damagetaken")
		if isNotBulletDamage then
			totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("longrange_nonbullet_damage")
		end
	else
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("shortrange_damage")
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("shortrange_damagetaken")
		if isNotBulletDamage then
			totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("shortrange_nonbullet_damage")
		end
	end
	totalMul = totalMul * (1 + (attacker:InsaneStats_GetAttributeValue("lowhealth_damage") - 1) * attackerHealthFraction)
	totalMul = totalMul * (1 + (attacker:InsaneStats_GetAttributeValue("lowhealth_victim_damage") - 1) * victimHealthFraction)
	totalMul = totalMul * (1 + (vic:InsaneStats_GetAttributeValue("lowhealth_damagetaken") - 1) * victimHealthFraction)
	if victimHealthFraction > 0.9 then
		totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("high90health_victim_damage")
	end
	if victimHealthFraction < attacker:InsaneStats_GetAttributeValue("lowxhealth_victim_doubledamage") - 1 then
		totalMul = totalMul * 2
	end
	totalMul = totalMul * (1 + (attacker:InsaneStats_GetAttributeValue("speed_damage") - 1) * attackerSpeedFraction)
	totalMul = totalMul * (1 + (vic:InsaneStats_GetAttributeValue("speed_damagetaken") - 1) * victimSpeedFraction)
	totalMul = totalMul * (1 + (attacker:InsaneStats_GetAttributeValue("combat5s_damage") - 1) * attackerCombatFraction)
	totalMul = totalMul * (1 + (vic:InsaneStats_GetAttributeValue("combat5s_damagetaken") - 1) * victimCombatFraction)
	
	if attackerCombatFraction <= 0 then
		totalMul = totalMul * vic:InsaneStats_GetAttributeValue("noncombat_damagetaken")
	end
	
	totalMul = totalMul / 1.1^attacker:InsaneStats_GetStatusEffectLevel("damage_down")
	totalMul = totalMul * 1.1^attacker:InsaneStats_GetStatusEffectLevel("damage_up")
	totalMul = totalMul * 1.1^vic:InsaneStats_GetStatusEffectLevel("defence_down")
	totalMul = totalMul / 1.1^vic:InsaneStats_GetStatusEffectLevel("defence_up")
	
	totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("perdebuff_damage")^vic:InsaneStats_GetStatusEffectCountByType(-1)
	--print(attacker:InsaneStats_GetAttributeValue("perdebuff_damage"), vic:InsaneStats_GetStatusEffectCountByType(-1))
	
	totalMul = totalMul * (1 + attacker:InsaneStats_GetStatusEffectLevel("stack_damage_up") / 100)
	totalMul = totalMul / (1 + vic:InsaneStats_GetStatusEffectLevel("stack_defence_up") / 100)
	
	if vic:IsPlayer() or vic:IsNPC() then
		if attackerArmorFraction >= 1 then
			local conversionRate = attacker:InsaneStats_GetAttributeValue("amp_armorloss") - 1
			attacker:SetArmor(attacker:InsaneStats_GetFractionalArmor() * (1-conversionRate))
			local convertedArmor = attackerArmorFraction * conversionRate * 100
			dmginfo:AddDamage(convertedArmor * attacker:InsaneStats_GetAttributeValue("amp_damage"))
		end
	end
	
	print(totalMul)
	dmginfo:ScaleDamage(totalMul)
	
	--local knockback = dmginfo:GetDamageForce() * (knockbackMul - 1)
	--vic:SetVelocity(knockback)
	dmginfo:SetDamageForce(dmginfo:GetDamageForce() * knockbackMul)
end

local function CauseDelayedDamage(data)
	--{damagePos,attacker,victim,damage,shouldExplode,shouldShock}
	local damagePos = data.pos
	local attacker = data.attacker
	local victim = data.victim
	local damage = data.damage
	local shouldExplode = data.shouldExplode
	local shouldShock = data.shouldShock
	local localPos
	
	if IsValid(victim) then
		localPos = victim:WorldToLocal(damagePos)
	end
	
	timer.Simple(0.5, function()
		if IsValid(attacker) then
			local forceDir = vector_up
			local halfDamage = damage/2
			--local explosionDamage = halfDamage * attacker:InsaneStats_GetAttributeValue("explode_damage") --this isn't status effect damage
			--print(halfDamage)
			
			-- translate local pos if possible, else use world pos
			if IsValid(victim) then
				damagePos = victim:LocalToWorld(localPos)
				forceDir = damagePos - victim:GetPos()
				
				if shouldShock then
					local effectDamage = halfDamage
					effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("shock_damage")
					effectDamage = effectDamage * victim:InsaneStats_GetAttributeValue("shock_damagetaken")
					victim:InsaneStats_ApplyStatusEffect("shock", 0, 5, {damage = effectDamage, attacker = attacker})
					
					local effdata = EffectData()
					effdata:SetOrigin(victim:GetPos())
					effdata:SetNormal(vector_up)
					effdata:SetAngles(angle_zero)
					--effdata:SetEntity(victim)
					--effdata:SetStart(damagePos)
					util.Effect("ManhackSparks", effdata)
					
					victim:EmitSound("ambient/energy/weld1.wav", 75, 100, 1, CHAN_WEAPON)
				end
			end
			
			if shouldExplode then
				isArcingDamage = true
				
				local dmginfo = DamageInfo()
				dmginfo:SetAmmoType(8)
				dmginfo:SetAttacker(attacker)
				dmginfo:SetBaseDamage(halfDamage)
				dmginfo:SetDamage(halfDamage)
				dmginfo:SetDamageForce(forceDir)
				dmginfo:SetDamagePosition(damagePos)
				dmginfo:SetDamageType(DMG_BLAST)
				dmginfo:SetInflictor(attacker)
				dmginfo:SetMaxDamage(damage)
				dmginfo:SetReportedPosition(attacker:GetPos())
				util.BlastDamageInfo(dmginfo, damagePos, 64)
				
				local effdata = EffectData()
				effdata:SetOrigin(damagePos)
				effdata:SetMagnitude(1)
				effdata:SetScale(1)
				effdata:SetFlags(0)
				util.Effect("Explosion", effdata)
				
				isArcingDamage = false
			end
		end
	end)
end

hook.Add("EntityTakeDamage", "InsaneStatsWPASS", function(vic, dmginfo)
	if GetConVar("insanestats_wpass2_enabled"):GetBool() then
		vic.insaneStats_DamageTicks = (vic.insaneStats_DamageTicks or 0) + 1
		if vic.insaneStats_DamageTicks > 1000 then
			print("Something caused an infinite loop!")
			debug.Trace()
			return true
		end
		
		local attacker = dmginfo:GetAttacker()
		local tempStatusEffectDamage = false
		if IsValid(attacker) or attacker == game.GetWorld() then
			if dmginfo:IsExplosionDamage() then
				vic.insaneStats_FireAttacker = attacker
			end
			
			if attacker:GetClass() == "entityflame" then 
				if vic:InsaneStats_GetStatusEffectLevel("fire") > 0 and vic:InsaneStats_GetFractionalHealth() > 0 then
					return true
				end
			end
			
			if vic == attacker then
				if isStatusEffectDamage or tempStatusEffectDamage or isArcingDamage then return true end
			end
			if vic:InsaneStats_GetFractionalHealth() > 0 and not (isStatusEffectDamage or tempStatusEffectDamage) then
				-- -- calculate damage if not from arc damage
				--if not isArcingDamage thsen
					--print(vic, attacker, dmginfo:GetDamage())
					local shouldBreak = CalculateDamage(vic, attacker, dmginfo)
					--print(vic, attacker, dmginfo:GetDamage())
					if shouldBreak then
						print(vic, "BLOCKED")
						return true
					end
				--end
			end
		end
	end
end)

hook.Add("PostEntityTakeDamage", "InsaneStatsWPASS", function(vic, dmginfo, notImmune)
	if GetConVar("insanestats_wpass2_enabled"):GetBool() and notImmune then
		local attacker = dmginfo:GetAttacker()
		if IsValid(attacker) then
			if (vic:IsNPC() or vic:IsPlayer() or vic:IsNextBot()) and (attacker:IsNPC() or attacker:IsPlayer() or attacker:IsNextBot()) then
				vic:InsaneStats_UpdateCombatTime()
				attacker:InsaneStats_UpdateCombatTime()
			end
			
			local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon()
			
			if not isStatusEffectDamage and not dmginfo:IsDamageType(DMG_BURN) then
				-- non-damage based effects
				local speedDownLevel = -math.log(attacker:InsaneStats_GetAttributeValue("victim_speed"), 1.1)
				if speedDownLevel > 0.5 then
					vic:InsaneStats_ApplyStatusEffect("speed_down", speedDownLevel, 2)
				end
				local defenceDownLevel = math.log(attacker:InsaneStats_GetAttributeValue("victim_damagetaken"), 1.1)
				if defenceDownLevel > 0.5 then
					vic:InsaneStats_ApplyStatusEffect("defence_down", defenceDownLevel, 2)
				end
				local damageDownLevel = -math.log(attacker:InsaneStats_GetAttributeValue("victim_damage"), 1.1)
				if damageDownLevel > 0.5 then
					vic:InsaneStats_ApplyStatusEffect("damage_down", damageDownLevel, 2)
				end
				local fireRateDownLevel = -math.log(attacker:InsaneStats_GetAttributeValue("victim_firerate"), 1.1)
				if fireRateDownLevel > 0.5 then
					vic:InsaneStats_ApplyStatusEffect("firerate_down", fireRateDownLevel, 2)
				end
				
				-- non-over time / delayed effects
				local damage = dmginfo:GetDamage()
				local shouldExplode = not isArcingDamage
					and not dmginfo:IsBulletDamage()
					and math.random() < attacker:InsaneStats_GetAttributeValue("explode") - 1
				local shouldShock = math.random() < attacker:InsaneStats_GetAttributeValue("shock") - 1
				
				if attacker:InsaneStats_GetFractionalHealth() < attacker:InsaneStats_GetFractionalMaxHealth() then
					local lifeSteal = damage == math.huge and attacker:InsaneStats_GetAttributeValue("lifesteal") ~= 1 and 0
						or damage*(attacker:InsaneStats_GetAttributeValue("lifesteal") - 1)
					lifeSteal = lifeSteal * 16384 / math.max(vic:GetPos():DistToSqr(attacker:GetPos()), 16384)
					attacker:SetHealth(math.min(attacker:InsaneStats_GetFractionalHealth() + lifeSteal, attacker:InsaneStats_GetFractionalMaxHealth()))
				end
				
				if not isArcingDamage and math.random() < attacker:InsaneStats_GetAttributeValue("arc_chance") - 1 then
					-- get a random nearby entity
					local randomEntity = NULL
					for k,v in RandomPairs(ents.FindInSphere(vic:GetPos(), 128)) do
						if v ~= attacker and v:InsaneStats_GetFractionalHealth() > 0 then
							randomEntity = v break
						end
					end
					
					if IsValid(randomEntity) then
						randomEntity:TakeDamageInfo(dmginfo)
					end
				end
				
				local debuffDamageMul = vic:InsaneStats_GetAttributeValue("debuff_damagetaken")
				local worldPos = dmginfo:GetDamagePosition()
				worldPos = worldPos:IsZero() and vic:GetPos() or worldPos
				
				if shouldExplode or shouldShock then
					CauseDelayedDamage({
						pos = worldPos,
						attacker = attacker,
						victim = vic,
						damage = damage * debuffDamageMul,
						shouldExplode = shouldExplode,
						shouldShock = shouldShock
					})
					
					if shouldExplode then
						local effdata = EffectData()
						effdata:SetOrigin(worldPos)
						effdata:SetScale(1)
						effdata:SetMagnitude(1)
						util.Effect("StunstickImpact", effdata)
					end
				end
				
				-- over time effects
				
				if math.random() < attacker:InsaneStats_GetAttributeValue("poison") - 1 then
					local effectDamage = damage * debuffDamageMul
					effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("poison_damage")
					effectDamage = effectDamage * vic:InsaneStats_GetAttributeValue("poison_damagetaken")
					vic:InsaneStats_ApplyStatusEffect("poison", 0, 5, {damage = effectDamage, attacker = attacker})
					
					vic:EmitSound(string.format("weapons/bugbait/bugbait_squeeze%u.wav", math.random(3)), 75, 100, 1, CHAN_WEAPON)
					local effdata = EffectData()
					effdata:SetOrigin(worldPos)
					effdata:SetScale(0.5)
					effdata:SetMagnitude(0.5)
					util.Effect("AntlionGib", effdata)
				end
				
				if math.random() < attacker:InsaneStats_GetAttributeValue("fire") - 1 then
					local effectDamage = damage * debuffDamageMul
					effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("fire_damage")
					effectDamage = effectDamage * vic:InsaneStats_GetAttributeValue("fire_damagetaken")
					vic:InsaneStats_ApplyStatusEffect("fire", 0, 5, {damage = effectDamage, attacker = attacker})
					vic:Ignite(5)
				end
				
				if math.random() < attacker:InsaneStats_GetAttributeValue("freeze") - 1 then
					local effectDamage = damage/2 * debuffDamageMul
					effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("freeze_damage")
					effectDamage = effectDamage * vic:InsaneStats_GetAttributeValue("freeze_damagetaken")
					vic:InsaneStats_ApplyStatusEffect("freeze", 0, 5, {damage = effectDamage, attacker = attacker})
					if vic:IsNPC() then
						vic:SetSchedule(SCHED_NPC_FREEZE)
					end
					
					vic:EmitSound(string.format("physics/glass/glass_sheet_break%u.wav", math.random(3)), 75, 100, 1, CHAN_WEAPON)
					local effdata = EffectData()
					effdata:SetOrigin(worldPos)
					effdata:SetScale(1)
					effdata:SetMagnitude(1)
					util.Effect("GlassImpact", effdata)
				end
				
				if math.random() < attacker:InsaneStats_GetAttributeValue("bleed") - 1 then
					local effectDamage = damage/2 * debuffDamageMul
					effectDamage = effectDamage * attacker:InsaneStats_GetAttributeValue("bleed_damage")
					effectDamage = effectDamage * vic:InsaneStats_GetAttributeValue("bleed_damagetaken")
					vic:InsaneStats_ApplyStatusEffect("bleed", 0, 5, {damage = effectDamage, attacker = attacker})
					
					vic:EmitSound(string.format("npc/manhack/grind_flesh%u.wav", math.random(3)), 75, 100, 1, CHAN_WEAPON)
					local effdata = EffectData()
					effdata:SetOrigin(worldPos)
					effdata:SetEntity(vic)
					effdata:SetStart(attacker:GetPos())
					effdata:SetHitBox(0)
					effdata:SetFlags(3)
					effdata:SetColor(3)
					effdata:SetScale(6)
					effdata:SetMagnitude(1)
					util.Effect("bloodspray", effdata)
				end
				
				local effectDamage = damage*(attacker:InsaneStats_GetAttributeValue("repeat1s_damage")-1)*debuffDamageMul
				vic:InsaneStats_ApplyStatusEffect("doom", 0, 1, {damage = effectDamage, attacker = attacker})
				
				-- redamage effects
				if vic:InsaneStats_GetAttributeValue("retaliation_damage") ~= 1 then
					isStatusEffectDamage = true
					
					local scaleFactor = vic:InsaneStats_GetAttributeValue("retaliation_damage") - 1
					local oldAttacker = dmginfo:GetAttacker()
					
					dmginfo:SetAttacker(vic)
					dmginfo:ScaleDamage(scaleFactor)
					oldAttacker:TakeDamageInfo(dmginfo)
					dmginfo:ScaleDamage(1/scaleFactor)
					dmginfo:SetAttacker(oldAttacker)
					
					isStatusEffectDamage = false
				end
			end
		end
	end
end)

hook.Add("ScaleNPCDamage", "InsaneStatsWPASS", function(vic, hitgroup, dmginfo)
	if GetConVar("insanestats_wpass2_enabled"):GetBool() then
		local attacker = dmginfo:GetAttacker()
		if IsValid(attacker) then 
			if math.random() < attacker:InsaneStats_GetAttributeValue("crit_chance") - 1 then
				hitgroup = HITGROUP_HEAD
				dmginfo:ScaleDamage(2)
			end
			
			if hitgroup == HITGROUP_HEAD then
				local totalMul = 1
				totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("crit_damage")
				totalMul = totalMul * vic:InsaneStats_GetAttributeValue("crit_damagetaken")
				dmginfo:ScaleDamage(totalMul)
			end
		end
	end
end)

hook.Add("ScalePlayerDamage", "InsaneStatsWPASS", function(vic, hitgroup, dmginfo)
	if GetConVar("insanestats_wpass2_enabled"):GetBool() then
		local attacker = dmginfo:GetAttacker()
		if IsValid(attacker) then
			if math.random() < attacker:InsaneStats_GetAttributeValue("crit_chance") - 1 then
				hitgroup = HITGROUP_HEAD
				dmginfo:ScaleDamage(2)
			end
			
			if hitgroup == HITGROUP_HEAD then
				local totalMul = 1
				totalMul = totalMul * attacker:InsaneStats_GetAttributeValue("crit_damage")
				totalMul = totalMul * vic:InsaneStats_GetAttributeValue("crit_damagetaken")
				dmginfo:ScaleDamage(totalMul)
			end
		end
	end
end)

hook.Add("InsaneStatsModifyNextFire", "InsaneStatsWPASS", function(data)
	local attacker = data.wep:GetOwner()
	if IsValid(attacker) then
		local combatFraction = math.Clamp(attacker:InsaneStats_GetCombatTime()/5, 0, 1)
		local totalMul = attacker:InsaneStats_GetAttributeValue("firerate")
		totalMul = totalMul * (1 + (attacker:InsaneStats_GetAttributeValue("combat5s_firerate") - 1) * combatFraction)
		
		if SERVER then
			totalMul = totalMul * 1.1^attacker:InsaneStats_GetStatusEffectLevel("firerate_up")
			totalMul = totalMul / 1.1^attacker:InsaneStats_GetStatusEffectLevel("firerate_down")
			if attacker:InsaneStats_GetStatusEffectLevel("shock") > 0 then
				totalMul = totalMul / 4
			end
		end
		
		data.next = (data.next - CurTime()) / totalMul + CurTime()
	end
end)

hook.Add("InsaneStatsMoveSpeed", "InsaneStatsWPASS", function(data)
	local ent = data.ent
	if IsValid(ent) then
		local combatFraction = math.Clamp(ent:InsaneStats_GetCombatTime()/5, 0, 1)
		local healthFraction = 1-math.Clamp(ent:InsaneStats_GetFractionalHealth() / ent:InsaneStats_GetFractionalMaxHealth(), 0, 1)
		local speedMul = ent:InsaneStats_GetAttributeValue("speed")
		
		if combatFraction <= 0 then
			speedMul = speedMul * ent:InsaneStats_GetAttributeValue("noncombat_speed")
		end
		speedMul = speedMul * (1 + (ent:InsaneStats_GetAttributeValue("lowhealth_speed") - 1) * healthFraction)
		
		speedMul = speedMul * (1 + ent:InsaneStats_GetStatusEffectLevel("stack_speed_up") / 100)
	
		if SERVER then
			speedMul = speedMul * 1.1^ent:InsaneStats_GetStatusEffectLevel("speed_up")
			speedMul = speedMul / 1.1^ent:InsaneStats_GetStatusEffectLevel("speed_down")
			
			if ent:InsaneStats_GetStatusEffectLevel("freeze") > 0 then
				speedMul = speedMul / 4
			end
		end
		
		data.speed = data.speed * speedMul
		data.sprintSpeed = data.sprintSpeed * ent:InsaneStats_GetAttributeValue("sprint_speed")
	end
end)

hook.Add("EntityFireBullets", "InsaneStatsWPASS", function(attacker, data)
	if GetConVar("insanestats_wpass2_enabled"):GetBool() then
		local newNum = data.Num * attacker:InsaneStats_GetAttributeValue("bullets")
		local numFrac = newNum%1
		newNum = math.floor(newNum)
		if math.random() < numFrac then
			newNum = newNum + 1
		end
		data.Num = newNum
		if data.Num == 0 then return false end
		
		data.Spread:Mul(attacker:InsaneStats_GetAttributeValue("spread"))
		
		local shouldExplode = not isArcingDamage and math.random() < attacker:InsaneStats_GetAttributeValue("explode") - 1
		local shouldShock = math.random() < attacker:InsaneStats_GetAttributeValue("shock") - 1
		
		if shouldExplode or shouldShock then
			local oldCallback = data.Callback
			data.Callback = function(attacker, trace, dmginfo, ...)
				if oldCallback then
					oldCallback(attacker, trace, dmginfo, ...)
				end
				
				if trace.Hit then
					CauseDelayedDamage({
						pos = trace.HitPos,
						attacker = attacker,
						victim = trace.Entity,
						damage = dmginfo:GetDamage(),
						shouldExplode = shouldExplode,
						shouldShock = shouldShock
					})
				
					if shouldExplode then
						local effdata = EffectData()
						effdata:SetOrigin(trace.HitPos)
						effdata:SetScale(1)
						effdata:SetMagnitude(1)
						util.Effect("StunstickImpact", effdata)
					end
				end
			end
		end
		
		return true
	end
end)

local entities = {}
hook.Add("InsaneStatsScaleXP", "InsaneStatsWPASS", function(data)
	if GetConVar("insanestats_wpass2_enabled"):GetBool() then
		local attacker = data.attacker
		local victim = data.victim
		data.xp = data.xp * attacker:InsaneStats_GetAttributeValue("xp")
		
		if victim:IsNPC() then
			if victim:Disposition(data.attacker) == D_LI then
				data.xp = data.xp * attacker:InsaneStats_GetAttributeValue("ally_xp")
			end
		elseif not victim:IsPlayer() then -- prop
			data.xp = data.xp * (attacker:InsaneStats_GetAttributeValue("prop_xp") - 1)
		end
		
		data.xp = data.xp * (1 + attacker:InsaneStats_GetStatusEffectLevel("stack_xp_up") / 100)
		
		for k,v in pairs(entities) do
			if (IsValid(v) and v:InsaneStats_GetAttributeValue("else_xp") ~= 1 and not data.receivers[v]) then
				data.receivers[v] = v:InsaneStats_GetAttributeValue("else_xp") - 1
			end
		end
	end
end)

local function AttemptDupeEntity(ply, item)
	local itemHasModifiers = item:InsaneStats_IsWPASS2Able() and item.insaneStats_Modifiers and next(item.insaneStats_Modifiers)
	if not item.insaneStats_Duplicated and not itemHasModifiers and ply:InsaneStats_GetAttributeValue("supplying") ~= 1 then
		item.insaneStats_Duplicated = true
		
		local duplicates = ply:InsaneStats_GetAttributeValue("supplying") - 1
		if math.random() < duplicates % 1 then
			duplicates = math.ceil(duplicates)
		else
			duplicates = math.floor(duplicates)
		end
		
		for i=1,duplicates do
			local itemDuplicate = ents.Create(item:GetClass())
			itemDuplicate:SetPos(item:GetPos())
			itemDuplicate:SetAngles(item:GetAngles())
			itemDuplicate:Spawn()
			itemDuplicate.insaneStats_Duplicated = true
			itemDuplicate.insaneStats_NextPickup = CurTime() + 1
		end
	end
end

hook.Add("InsaneStatsPlayerCanPickupItem", "InsaneStatsWPASS", AttemptDupeEntity)
hook.Add("InsaneStatsPlayerCanPickupWeapon", "InsaneStatsWPASS", AttemptDupeEntity)

hook.Add("InsaneStatsArmorBatteryChanged", "InsaneStatsWPASS", function(ent, item)
	local entHealthMod = ent.insaneStats_Attributes and ent.insaneStats_Attributes.health or 1
	local entArmorMod = ent.insaneStats_Attributes and ent.insaneStats_Attributes.armor or 1
	local itemHealthMod = item.insaneStats_Attributes and item.insaneStats_Attributes.health or 1
	local itemArmorMod = item.insaneStats_Attributes and item.insaneStats_Attributes.armor or 1
	
	local entNewMaxHealth = math.floor(ent:InsaneStats_GetFractionalMaxHealth()) * itemHealthMod / entHealthMod
	local entNewHealth = entNewMaxHealth * ent:InsaneStats_GetFractionalHealth() / ent:InsaneStats_GetFractionalMaxHealth()
	local entNewMaxArmor = ent.GetMaxArmor and math.floor(ent:InsaneStats_GetFractionalMaxArmor()) * itemArmorMod / entArmorMod
	local entNewArmor = entNewMaxArmor and entNewMaxArmor * ent:InsaneStats_GetFractionalArmor() / ent:InsaneStats_GetFractionalMaxArmor()
	
	ent:SetMaxHealth(entNewMaxHealth)
	ent:SetHealth(entNewHealth)
	if entNewMaxArmor then
		ent:SetMaxArmor(entNewMaxArmor)
		ent:SetArmor(entNewArmor)
	end
	
	item.insaneStats_Duplicated = true
	
	--print(ent, item)
	--print(itemHealthMod, entHealthMod, itemArmorMod, entArmorMod)
	--print(entNewHealth, entNewMaxHealth, entNewArmor, entNewMaxArmor)
end)

local function CauseStatusEffectDamage(data)
	local victim = data.victim
	local stat = data.stat
	if victim:InsaneStats_GetStatusEffectLevel(stat) > 0 then
		isStatusEffectDamage = true
		--PrintTable(data)
		local attacker = victim:InsaneStats_GetStatusEffectAttacker(stat)
		if not IsValid(attacker) then
			attacker = victim
		end
		local percentageToInflict = math.Clamp(1-victim:InsaneStats_GetStatusEffectDuration(stat)/5, 0, 1)
		if data.expiryOnly and percentageToInflict < 1 then
			percentageToInflict = 0
		end
		local levelsToRemove = victim:InsaneStats_GetStatusEffectLevel(stat) * percentageToInflict
		local damage = levelsToRemove * victim:InsaneStats_GetFractionalMaxHealth() / 100
		--print(damage)
		
		--print(damage)
		local dmginfo = DamageInfo()
		dmginfo:SetAmmoType(data.ammoType or -1)
		dmginfo:SetAttacker(attacker)
		dmginfo:SetBaseDamage(damage)
		dmginfo:SetDamage(damage)
		dmginfo:SetDamageForce(vector_up)
		dmginfo:SetDamagePosition(victim:GetPos())
		dmginfo:SetDamageType(data.damageType)
		dmginfo:SetInflictor(attacker)
		dmginfo:SetMaxDamage(damage)
		dmginfo:SetReportedPosition(attacker:GetPos())
		victim:TakeDamageInfo(dmginfo)
		
		victim:InsaneStats_SetStatusEffectLevel(stat, victim:InsaneStats_GetStatusEffectLevel(stat) - levelsToRemove)
		isStatusEffectDamage = false
	end
end

if SERVER then
	timer.Create("InsaneStatsWPASS", 0.5, 0, function()
		if GetConVar("insanestats_wpass2_enabled"):GetBool() then
			entities = ents.GetAll()
			for k,v in pairs(entities) do
				if v:InsaneStats_GetAttributeValue("combat5s_regen") ~= 1 and v:InsaneStats_GetFractionalHealth() < v:InsaneStats_GetFractionalMaxHealth() then
					local combatFraction = math.Clamp(v:InsaneStats_GetCombatTime()/5, 0, 1)
					local healthRestoredFrac = (v:InsaneStats_GetAttributeValue("combat5s_regen") - 1) * combatFraction
					local healthRestored = healthRestoredFrac * v:InsaneStats_GetFractionalMaxHealth()
					v:SetHealth(math.min(v:InsaneStats_GetFractionalMaxHealth(), v:InsaneStats_GetFractionalHealth()+healthRestored))
				end
				
				CauseStatusEffectDamage({
					victim = v,
					stat = "poison",
					damageType = DMG_POISON
				})
				
				CauseStatusEffectDamage({
					victim = v,
					stat = "fire",
					ammoType = 8,
					damageType = DMG_BURN
				})
				
				CauseStatusEffectDamage({
					victim = v,
					stat = "freeze",
					damageType = DMG_DROWN
				})
					
				if v:IsNPC() and (v:InsaneStats_GetStatusEffectLevel("freeze") == 0 or v:InsaneStats_GetFractionalHealth() <= 0) then
					v:SetCondition(68)
				end
				
				CauseStatusEffectDamage({
					victim = v,
					stat = "shock",
					ammoType = 17,
					damageType = DMG_SHOCK
				})
				
				CauseStatusEffectDamage({
					victim = v,
					stat = "bleed",
					damageType = DMG_SLASH
				})
				
				CauseStatusEffectDamage({
					victim = v,
					stat = "doom",
					expiryOnly = true,
					damageType = DMG_GENERIC
				})
				
				if v:InsaneStats_GetStatusEffectLevel("stack_damage_up") > 0 then
					v:InsaneStats_SetStatusEffectLevel("stack_damage_up", v:InsaneStats_GetStatusEffectLevel("stack_damage_up") * 0.99609375)
				end
				if v:InsaneStats_GetStatusEffectLevel("stack_defence_up") > 0 then
					v:InsaneStats_SetStatusEffectLevel("stack_defence_up", v:InsaneStats_GetStatusEffectLevel("stack_defence_up") * 0.99609375)
				end
				if v:InsaneStats_GetStatusEffectLevel("stack_speed_up") > 0 then
					v:InsaneStats_SetStatusEffectLevel("stack_speed_up", v:InsaneStats_GetStatusEffectLevel("stack_speed_up") * 0.99609375)
				end
				if v:InsaneStats_GetStatusEffectLevel("stack_xp_up") > 0 then
					v:InsaneStats_SetStatusEffectLevel("stack_xp_up", v:InsaneStats_GetStatusEffectLevel("stack_xp_up") * 0.99609375)
				end
			end
		end
	end)
end

hook.Add("Think", "InsaneStatsWPASS2", function()
	if GetConVar("insanestats_wpass2_enabled"):GetBool() then
		for k,v in pairs(entities) do
			if IsValid(v) then
				v.insaneStats_DamageTicks = 0
				local wep = v.GetActiveWeapon and v:GetActiveWeapon()
				
				if v:IsPlayer() or v:IsNPC() or v:IsNextBot() then
					v.insaneStats_OldMoveMul = v.insaneStats_OldMoveMul or 1
					v.insaneStats_OldSprintMoveMul = v.insaneStats_OldSprintMoveMul or 1
					local data = {ent = v, speed = 1, sprintSpeed = 1}
					hook.Run("InsaneStatsMoveSpeed", data)
					local newMoveSpeed = data.speed
					local newSprintSpeed = data.sprintSpeed
					if v.insaneStats_OldMoveMul ~= newMoveSpeed or v.insaneStats_OldSprintMoveMul ~= newSprintSpeed then
						local applyMul = newMoveSpeed / v.insaneStats_OldMoveMul
						local sprintApplyMul = applyMul * newSprintSpeed / v.insaneStats_OldSprintMoveMul
						if v:IsPlayer() then
							v:SetLadderClimbSpeed(v:GetLadderClimbSpeed()*applyMul)
							v:SetMaxSpeed(v:GetMaxSpeed()*applyMul)
							v:SetRunSpeed(v:GetRunSpeed()*sprintApplyMul)
							v:SetWalkSpeed(v:GetWalkSpeed()*applyMul)
							v:SetSlowWalkSpeed(v:GetSlowWalkSpeed()*math.sqrt(applyMul))
						elseif SERVER then
							if v:IsNPC() then
							-- TODO: test if this actually works
							v:SetMoveInterval(v:GetMoveInterval()/applyMul)
							elseif v:IsNextBot() then
								v.loco:SetDesiredSpeed(v.loco:GetDesiredSpeed()*applyMul)
							end
						end
						
						v.insaneStats_OldMoveMul = newMoveSpeed
						v.insaneStats_OldSprintMoveMul = newSprintSpeed
					end
				end
				
				if v:InsaneStats_GetAttributeValue("bloodletting") ~= 1 and v.SetArmor then
					local minimumHealth = v:InsaneStats_GetFractionalMaxHealth() * (v:InsaneStats_GetAttributeValue("bloodletting") - 1)
					local lostHealth = math.ceil(v:InsaneStats_GetFractionalHealth() - minimumHealth)
					--print(v:InsaneStats_GetFractionalHealth(), minimumHealth)
					if lostHealth > 0 then
						v:InsaneStats_AddArmorNerfed(lostHealth)
						v:SetHealth(v:InsaneStats_GetFractionalHealth() - lostHealth)
					end
				end
				
				if (IsValid(wep) and not wep:IsScripted()) then
					wep.insaneStats_LastPrimaryFire = wep.insaneStats_LastPrimaryFire or wep:GetNextPrimaryFire()
					if wep.insaneStats_LastPrimaryFire ~= wep:GetNextPrimaryFire() then
						wep:SetNextPrimaryFire(wep:GetNextPrimaryFire())
						wep.insaneStats_LastPrimaryFire = wep:GetNextPrimaryFire()
					end
					
					wep.insaneStats_LastSecondaryFire = wep.insaneStats_LastSecondaryFire or wep:GetNextSecondaryFire()
					if wep.insaneStats_LastSecondaryFire ~= wep:GetNextSecondaryFire() then
						wep:SetNextSecondaryFire(wep:GetNextSecondaryFire())
						wep.insaneStats_LastSecondaryFire = wep:GetNextSecondaryFire()
					end
				end
			end
		end
	end
end)

hook.Add("PlayerSpawn", "InsaneStatsWPASS", function(ply)
	if GetConVar("insanestats_wpass2_enabled"):GetBool() then
		timer.Simple(0, function()
			local entHealthMod = ply.insaneStats_Attributes and ply.insaneStats_Attributes.health or 1
			local entArmorMod = ply.insaneStats_Attributes and ply.insaneStats_Attributes.armor or 1
			
			local entNewMaxHealth = math.floor(ply:InsaneStats_GetFractionalMaxHealth()) * entHealthMod
			local entNewHealth = entNewMaxHealth * ply:InsaneStats_GetFractionalHealth() / ply:InsaneStats_GetFractionalMaxHealth()
			local entNewMaxArmor = math.floor(ply:InsaneStats_GetFractionalMaxArmor()) * entArmorMod
			local entNewArmor = entNewMaxArmor * ply:InsaneStats_GetFractionalArmor() / ply:InsaneStats_GetFractionalMaxArmor()
			
			ply:SetMaxHealth(entNewMaxHealth)
			ply:SetHealth(entNewHealth)
			ply:SetMaxArmor(entNewMaxArmor)
			ply:SetArmor(entNewArmor)
			
			--print(entNewHealth, entNewMaxHealth, entNewArmor, entNewMaxArmor)
		end)
	end
end)

hook.Add("EntityEmitSound","InsaneStatsWPASS",function(sound)
	local ent = sound.Entity
	if (IsValid(ent) and ent:InsaneStats_GetAttributeValue("alt_invisible") ~= 1 and ent:GetNoDraw()) then
		return false
	end
	--if sound.SoundName ~= SM_UpgradeSound then
	sound.Flags = bit.bor(sound.Flags, SND_SHOULDPAUSE)
	return true
	--end
end)

hook.Add("SetupMove", "InsaneStatsWPASS", function(ply, movedata, usercmd)
	if movedata:KeyPressed(IN_WALK) then
		if (ply.insaneStats_LastAltPress or 0) + 1 > CurTime() then
			ply.insaneStats_LastAltPress = 0
			
			local invisibilityDuration = ply:InsaneStats_GetAttributeValue("alt_invisible") - 1
			if ply:InsaneStats_GetStatusEffectDuration("invisible_cooldown") <= 0 and invisibilityDuration ~= 0 and not ply:IsFlagSet(FL_NOTARGET) then
				ply:AddFlags(FL_NOTARGET)
				ply:RemoveFlags(FL_AIMTARGET)
				ply:AddEffects(bit.bor(EF_NOSHADOW, EF_NODRAW, EF_NORECEIVESHADOW))
				ply:InsaneStats_ApplyStatusEffect("invisible", 1, invisibilityDuration)
				ply:InsaneStats_ApplyStatusEffect("invisible_cooldown", 1, invisibilityDuration + 60)
				timer.Simple(invisibilityDuration, function()
					if IsValid(ply) then
						ply:RemoveFlags(FL_NOTARGET)
						ply:AddFlags(FL_AIMTARGET)
						ply:RemoveEffects(bit.bor(EF_NOSHADOW, EF_NODRAW, EF_NORECEIVESHADOW))
					end
				end)
			else
				print(ply:InsaneStats_GetStatusEffectDuration("invisible_cooldown"))
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
end)

hook.Add("PostPlayerDeath", "InsaneStatsWPASS", function(ply)
	ply:InsaneStats_ClearStatusEffectsByType(-1)
	ply.insaneStats_PoisonRemaining = 0
	ply.insaneStats_FireRemaining = 0
	ply.insaneStats_FreezeRemaining = 0
	ply.insaneStats_ShockRemaining = 0
	ply.insaneStats_BleedRemaining = 0
	ply.insaneStats_DoomRemaining = 0
end)

local function ProcessKillEvent(victim, attacker, inflictor)
	if not IsValid(attacker) and IsValid(inflictor) then
		attacker = inflictor
	end
	
	if IsValid(attacker) then
		if victim ~= attacker then
			if attacker:InsaneStats_GetFractionalHealth() < attacker:InsaneStats_GetFractionalMaxHealth() then
				local healthRestored = attacker:InsaneStats_GetFractionalMaxHealth() * (attacker:InsaneStats_GetAttributeValue("kill_lifesteal") - 1)
				attacker:SetHealth(math.min(attacker:InsaneStats_GetFractionalHealth() + healthRestored, attacker:InsaneStats_GetFractionalMaxHealth()))
			end
			--print(attacker:InsaneStats_GetFractionalHealth(), healthRestored, attacker:InsaneStats_GetFractionalMaxHealth())
			
			if attacker.GetMaxArmor then
				local armorRestored = attacker:InsaneStats_GetFractionalMaxArmor() * (attacker:InsaneStats_GetAttributeValue("kill_armorsteal") - 1)
				attacker:InsaneStats_AddArmorNerfed(armorRestored)
			end
			
			local newStackLevel = attacker:InsaneStats_GetStatusEffectLevel("stack_damage_up") + (attacker:InsaneStats_GetAttributeValue("killstack_damage") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("stack_damage_up", newStackLevel, math.huge)
			newStackLevel = attacker:InsaneStats_GetStatusEffectLevel("stack_defence_up") + (attacker:InsaneStats_GetAttributeValue("killstack_resistance") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("stack_defence_up", newStackLevel, math.huge)
			newStackLevel = attacker:InsaneStats_GetStatusEffectLevel("stack_speed_up") + (attacker:InsaneStats_GetAttributeValue("killstack_speed") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("stack_speed_up", newStackLevel, math.huge)
			newStackLevel = attacker:InsaneStats_GetStatusEffectLevel("stack_xp_up") + (attacker:InsaneStats_GetAttributeValue("killstack_xp") - 1) * 100
			attacker:InsaneStats_ApplyStatusEffect("stack_xp_up", newStackLevel, math.huge)
			
			if attacker:InsaneStats_GetAttributeValue("kill5s_damage") ~= 1 then
				local stacks = math.log(attacker:InsaneStats_GetAttributeValue("kill5s_damage"), 1.1)
				attacker:InsaneStats_ApplyStatusEffect("damage_up", stacks, 5)
			end
			if attacker:InsaneStats_GetAttributeValue("kill5s_damagetaken") ~= 1 then
				local stacks = -math.log(attacker:InsaneStats_GetAttributeValue("kill5s_damagetaken"), 1.1)
				attacker:InsaneStats_ApplyStatusEffect("defence_up", stacks, 5)
			end
			if attacker:InsaneStats_GetAttributeValue("kill5s_firerate") ~= 1 then
				local stacks = math.log(attacker:InsaneStats_GetAttributeValue("kill5s_firerate"), 1.1)
				attacker:InsaneStats_ApplyStatusEffect("firerate_up", stacks, 5)
			end
			if attacker:InsaneStats_GetAttributeValue("kill5s_speed") ~= 1 then
				local stacks = math.log(attacker:InsaneStats_GetAttributeValue("kill5s_speed"), 1.1)
				attacker:InsaneStats_ApplyStatusEffect("speed_up", stacks, 5)
			end
		end
	end
end

local function ProcessBreakEvent(victim, attacker)
	if IsValid(attacker) and not victim.insaneStats_IsDead then
		victim.insaneStats_IsDead = true
		
		local inflictor = attacker:GetActiveWeapon()
		local xpMul = GetConVar("insanestats_xp_other_mul"):GetFloat()
		local currentHealthAdd = victim.insaneStats_CurrentHealthAdd or 1
		local startingHealth = victim:InsaneStats_GetFractionalMaxHealth() / currentHealthAdd
		local xpToGive = InsaneStats_ScaleValueToLevel(
			startingHealth * xpMul / 5,
			GetConVar("insanestats_xp_drop_add"):GetFloat()/100,
			victim:InsaneStats_GetLevel(),
			GetConVar("insanestats_xp_drop_addmode"):GetBool()
		) + (victim.insaneStats_DropXP or 0)
		
		local data = {
			xp = xpToGive,
			attacker = attacker, inflictor = inflictor, victim = victim,
			receivers = {[attacker] = 1, [inflictor] = 1}
		}
		hook.Run("InsaneStatsScaleXP", data)
		
		xpToGive = data.xp
		local xpDropMul = GetConVar("insanestats_xp_other_yieldmul"):GetFloat()
		
		for k,v in pairs(data.receivers) do
			local xp = xpToGive * v
			k:InsaneStats_AddXP(xp, xp*xpDropMul)
			
			local wep = k.GetActiveWeapon and k:GetActiveWeapon()
			if IsValid(wep) and wep ~= inflictor then
				wep:InsaneStats_AddXP(xp, xp*xpDropMul)
			end
		end
	end
end

hook.Add("entity_killed", "InsaneStatsXP", function(data)
	if GetConVar("insanestats_wpass2_enabled"):GetBool() then
		local victim = Entity(data.entindex_killed or 0)
		local attacker = Entity(data.entindex_attacker or 0)
		local inflictor = Entity(data.entindex_inflictor or 0)
		
		ProcessKillEvent(victim, attacker, inflictor)
	end
end)

hook.Add("break_prop", "InsaneStatsWPASS", function(data)
	if GetConVar("insanestats_wpass2_enabled"):GetBool() then
		local victim = Entity(data.entindex or 0)
		local attacker = Player(data.userid or 0)
		
		ProcessBreakEvent(victim, attacker)
	end
end)

hook.Add("break_breakable", "InsaneStatsWPASS", function(data)
	if GetConVar("insanestats_wpass2_enabled"):GetBool() then
		local victim = Entity(data.entindex or 0)
		local attacker = Player(data.userid or 0)
		
		ProcessBreakEvent(victim, attacker)
	end
end)

hook.Add("InsaneStatsLoadWPASS", "InsaneStatsWPASS", function(currentModifiers, currentAttributes, currentStatusEffects)
	table.Merge(currentModifiers, modifiers)
	table.Merge(currentAttributes, attributes)
	table.Merge(currentStatusEffects, statusEffects)
end)