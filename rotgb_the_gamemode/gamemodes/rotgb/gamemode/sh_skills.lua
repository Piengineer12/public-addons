GM.BaseSkills = {
	{
		ref = "physgun",
		name = "Physics Gun",
		trait = "physgun",
		amount = 1,
		tier = 2,
		alwaysUnlocked = true
	},
	{
		{
			{
				ref = "fr1",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "physgun",
				links = "parent",
				pos = VectorTable(4,4),
			},
			{
				ref = "fr2",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr1",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "fr3",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr1",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "fr4",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr2",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "fr5",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr3",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "fr6",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr4",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "fr7",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr5",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "fr8",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr6",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "fr9",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr7",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "fr10",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr8",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "fr11",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr9",
				links = "parent",
				pos = VectorTable(1,1),
			},
		},
		{
			{
				ref = "fr12",
				name = "Fire Rate",
				trait = "towerFireRate",
				amount = 1,
				parent = "fr6",
				links = {"fr6","fr7"},
				pos = VectorTable(1,0),
			},
			{
				ref = "extraBatteries",
				name = "Extra Batteries",
				trait = "electrostaticBarrelBounces",
				amount = 1,
				tier = 1,
				parent = "fr12",
				links = "parent",
				pos = VectorTable(-1,-1),
			}
		},
		{
			{
				ref = "fastCaliberTechnique",
				name = "Fast Caliber Technique",
				trait = "sniperQueenFireRate",
				amount = 15,
				tier = 1,
				parent = "fr10",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "bigBombs",
				name = "Bigger Bombs",
				trait = "mortarTowerBombRadius",
				amount = 25,
				tier = 1,
				parent = "fr11",
				links = {"fr11", "fastCaliberTechnique"},
				pos = VectorTable(1,1),
			}
		},
		{
			{
				ref = "range1",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "fastCaliberTechnique",
				links = "parent",
				pos = VectorTable(-1,1),
			},
			{
				ref = "range3",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range1",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "range5",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range3",
				links = "parent",
				pos = VectorTable(-1,1),
			},
			{
				ref = "range2",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "bigBombs",
				links = "parent",
				pos = VectorTable(1,-1),
			},
			{
				ref = "range4",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range2",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "range6",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range4",
				links = "parent",
				pos = VectorTable(1,-1),
			}
		},
		{
			{
				ref = "biggerMines",
				name = "Bigger Mines",
				trait = "proximityMineRange",
				amount = 25,
				tier = 1,
				parent = "range5",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "betterGattlerDesign",
				name = "Better Gattler Design",
				trait = "gatlingGunKnightSpread",
				amount = -15,
				tier = 1,
				parent = "range6",
				links = "parent",
				pos = VectorTable(1,0),
			}
		},
		{
			{
				ref = "range7",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "biggerMines",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "range9",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range7",
				links = "parent",
				pos = VectorTable(1,-1),
			},
			{
				ref = "range11",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range9",
				links = "parent",
				pos = VectorTable(1,-1),
			},
			{
				ref = "range8",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "betterGattlerDesign",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "range10",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range8",
				links = "parent",
				pos = VectorTable(-1,1),
			},
			{
				ref = "range12",
				name = "Range",
				trait = "towerRange",
				amount = 2,
				parent = "range10",
				links = "parent",
				pos = VectorTable(-1,1),
			}
		},
		{
			{
				ref = "strongerSawblades",
				name = "Stronger Sawblades",
				trait = "sawbladeLauncherPierce",
				amount = 1,
				tier = 1,
				parent = "range11",
				links = "parent",
				pos = VectorTable(0,-1),
			},
			{
				ref = "pyroTraining",
				name = "Pyro Training",
				trait = {"fireCubeFireRate", "fireCubeRange"},
				amount = {10, 15},
				tier = 1,
				parent = "range12",
				links = "parent",
				pos = VectorTable(-1,0),
			}
		},
		{
			{
				ref = "motivation1",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "range11",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "motivation2",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "motivation1",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "motivation3",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "motivation2",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "motivation4",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "motivation3",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "motivation5",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "motivation4",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "motivation6",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "motivation5",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "motivation7",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "motivation6",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "motivation8",
				name = "Motivation",
				trait = "towerEarlyFireRate",
				amount = 3,
				parent = "motivation7",
				links = "parent",
				pos = VectorTable(1,1),
			},
		},
		{
			{
				ref = "warHorn1",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "strongerSawblades",
				links = {"strongerSawblades", "pyroTraining"},
				pos = VectorTable(1,0),
			},
			{
				ref = "warHorn2",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "warHorn1",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "warHorn3",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "warHorn2",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "warHorn4",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "warHorn3",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "warHorn5",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "warHorn4",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "warHorn6",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "warHorn5",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "warHorn7",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "warHorn6",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "warHorn8",
				name = "War Horn",
				trait = "towerAbilityD3FireRate",
				amount = 5,
				parent = "warHorn7",
				links = "parent",
				pos = VectorTable(1,1),
			},
		},
		{
			{
				ref = "mip1",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "range12",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "mip2",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "mip1",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "mip3",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "mip2",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "mip4",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "mip3",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "mip5",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "mip4",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "mip6",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "mip5",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "mip7",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "mip6",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "mip8",
				name = "Money Is Power",
				trait = "towerMoneyFireRate",
				amount = 0.15,
				parent = "mip7",
				links = "parent",
				pos = VectorTable(1,1),
			},
		},
		{
			{
				ref = "betterDiffraction",
				name = "Better Diffraction",
				trait = "microwaveGeneratorMicrowaveAngle",
				amount = 25,
				tier = 1,
				parent = "motivation8",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "fasterAssembly",
				name = "Faster Assembly",
				trait = "turretFactoryAbilityCooldown",
				amount = -15,
				tier = 1,
				parent = "warHorn8",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "reshapedPills",
				name = "Reshaped Pills",
				trait = {"pillLobberFlyTime", "pillLobberExploRadius", "pillLobberDirectDamage"},
				amount = {-15, 15, 1},
				tier = 1,
				parent = "mip8",
				links = "parent",
				pos = VectorTable(0,1),
			}
		},
		{
			ref = "twoHanded100",
			name = "Two-Handed 100",
			trait = "allyPawnTargets",
			amount = 100,
			tier = 2,
			parent = "betterDiffraction",
			links = {"betterDiffraction", "fasterAssembly", "reshapedPills"},
			pos = VectorTable(1,0)
		},
	},
	{
		{
			ref = "dr1",
			name = "Defence",
			trait = "targetDefence",
			amount = 2,
			parent = "physgun",
			links = "parent",
			pos = VectorTable(4,4),
			ang = 90
		},
		{
			{
				ref = "dr2",
				name = "Defence",
				trait = "targetDefence",
				amount = 2,
				parent = "dr1",
				links = "parent",
				pos = VectorTable(1.5,0),
			},
			{
				ref = "dr3",
				name = "Defence",
				trait = "targetDefence",
				amount = 2,
				parent = "dr2",
				links = "parent",
				pos = VectorTable(1.5,0),
			},
			{
				ref = "dr4",
				name = "Defence",
				trait = "targetDefence",
				amount = 2,
				parent = "dr3",
				links = "parent",
				pos = VectorTable(1.5,0),
			},
			{
				ref = "dr5",
				name = "Defence",
				trait = "targetDefence",
				amount = 2,
				parent = "dr4",
				links = "parent",
				pos = VectorTable(1.5,0),
			},
			{
				ref = "dr6",
				name = "Defence",
				trait = "targetDefence",
				amount = 2,
				parent = "dr5",
				links = "parent",
				pos = VectorTable(1.5,0),
			},
			{
				ref = "dr7",
				name = "Defence",
				trait = "targetDefence",
				amount = 2,
				parent = "dr1",
				links = "parent",
				pos = VectorTable(0,1.5),
			},
			{
				ref = "dr8",
				name = "Defence",
				trait = "targetDefence",
				amount = 2,
				parent = "dr7",
				links = "parent",
				pos = VectorTable(0,1.5),
			},
			{
				ref = "dr9",
				name = "Defence",
				trait = "targetDefence",
				amount = 2,
				parent = "dr8",
				links = "parent",
				pos = VectorTable(0,1.5),
			},
			{
				ref = "dr10",
				name = "Defence",
				trait = "targetDefence",
				amount = 2,
				parent = "dr9",
				links = "parent",
				pos = VectorTable(0,1.5),
			},
			{
				ref = "dr11",
				name = "Defence",
				trait = "targetDefence",
				amount = 2,
				parent = "dr10",
				links = "parent",
				pos = VectorTable(0,1.5),
			}
		},
		{
			{
				ref = "mh1",
				name = "Maximum Health",
				trait = "targetHealth",
				amount = 2,
				parent = "dr1",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "oneShotProtection1",
				name = "One Shot Protection",
				trait = "targetOSP",
				amount = 1,
				tier = 1,
				parent = "dr6",
				links = "parent",
				pos = VectorTable(1.5,0),
			},
			{
				ref = "regeneration1",
				name = "Regeneration",
				trait = "targetRegeneration",
				amount = 1,
				tier = 1,
				parent = "mh1",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "oneShotProtection2",
				name = "One Shot Protection",
				trait = "targetOSP",
				amount = 1,
				tier = 1,
				parent = "dr11",
				links = "parent",
				pos = VectorTable(0,1.5),
			},
		},
		{
			{
				ref = "es1",
				name = "Energy Shield",
				trait = "targetShield",
				amount = 1,
				parent = "oneShotProtection1",
				links = "parent",
				pos = VectorTable(1,0.5),
			},
			{
				ref = "es2",
				name = "Energy Shield",
				trait = "targetShield",
				amount = 1,
				parent = "es1",
				links = "parent",
				pos = VectorTable(1,0.5),
			},
			{
				ref = "es3",
				name = "Energy Shield",
				trait = "targetShield",
				amount = 1,
				parent = "es2",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "es4",
				name = "Energy Shield",
				trait = "targetShield",
				amount = 1,
				parent = "es3",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "es5",
				name = "Energy Shield",
				trait = "targetShield",
				amount = 1,
				parent = "es4",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "es6",
				name = "Energy Shield",
				trait = "targetShield",
				amount = 1,
				parent = "oneShotProtection2",
				links = "parent",
				pos = VectorTable(0.5,1),
			},
			{
				ref = "es7",
				name = "Energy Shield",
				trait = "targetShield",
				amount = 1,
				parent = "es6",
				links = "parent",
				pos = VectorTable(0.5,1),
			},
			{
				ref = "es8",
				name = "Energy Shield",
				trait = "targetShield",
				amount = 1,
				parent = "es7",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "es9",
				name = "Energy Shield",
				trait = "targetShield",
				amount = 1,
				parent = "es8",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "es10",
				name = "Energy Shield",
				trait = "targetShield",
				amount = 1,
				parent = "es9",
				links = "parent",
				pos = VectorTable(1,1),
			},
		},
		{
			{
				ref = "mh2",
				name = "Maximum Health",
				trait = "targetHealth",
				amount = 2,
				parent = "regeneration1",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "mh3",
				name = "Maximum Health",
				trait = "targetHealth",
				amount = 2,
				parent = "mh2",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "mh4",
				name = "Maximum Health",
				trait = "targetHealth",
				amount = 2,
				parent = "mh3",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "mh5",
				name = "Maximum Health",
				trait = "targetHealth",
				amount = 2,
				parent = "mh4",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "mh6",
				name = "Maximum Health",
				trait = "targetHealth",
				amount = 2,
				parent = "mh5",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "mh7",
				name = "Maximum Health",
				trait = "targetHealth",
				amount = 2,
				parent = "regeneration1",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "mh8",
				name = "Maximum Health",
				trait = "targetHealth",
				amount = 2,
				parent = "mh7",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "mh9",
				name = "Maximum Health",
				trait = "targetHealth",
				amount = 2,
				parent = "mh8",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "mh10",
				name = "Maximum Health",
				trait = "targetHealth",
				amount = 2,
				parent = "mh9",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "mh11",
				name = "Maximum Health",
				trait = "targetHealth",
				amount = 2,
				parent = "mh10",
				links = "parent",
				pos = VectorTable(0,1),
			},
		},
		{
			{
				ref = "targetArmor1",
				name = "Target Armor",
				trait = "targetArmor",
				amount = 1,
				tier = 1,
				parent = "es5",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "targetArmor2",
				name = "Target Armor",
				trait = "targetArmor",
				amount = 1,
				tier = 1,
				parent = "es10",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "regeneration2",
				name = "Regeneration",
				trait = "targetRegeneration",
				amount = 1,
				tier = 1,
				parent = "mh6",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "regeneration3",
				name = "Regeneration",
				trait = "targetRegeneration",
				amount = 1,
				tier = 1,
				parent = "mh11",
				links = "parent",
				pos = VectorTable(0,1),
			},
		},
		{
			{
				ref = "dodge1",
				name = "Desperate Measures",
				trait = "targetDodge",
				amount = 1,
				parent = "targetArmor1",
				links = "parent",
				pos = VectorTable(-1,1),
			},
			{
				ref = "dodge2",
				name = "Desperate Measures",
				trait = "targetDodge",
				amount = 1,
				parent = "dodge1",
				links = "parent",
				pos = VectorTable(-1,0),
			},
			{
				ref = "dodge3",
				name = "Desperate Measures",
				trait = "targetDodge",
				amount = 1,
				parent = "dodge2",
				links = "parent",
				pos = VectorTable(-1,1),
			},
			{
				ref = "dodge4",
				name = "Desperate Measures",
				trait = "targetDodge",
				amount = 1,
				parent = "dodge3",
				links = "parent",
				pos = VectorTable(-1,1),
			},
			{
				ref = "dodge5",
				name = "Desperate Measures",
				trait = "targetDodge",
				amount = 1,
				parent = "dodge4",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "dodge6",
				name = "Desperate Measures",
				trait = "targetDodge",
				amount = 1,
				parent = "dodge5",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "dodge7",
				name = "Desperate Measures",
				trait = "targetDodge",
				amount = 1,
				parent = "targetArmor2",
				links = "parent",
				pos = VectorTable(1,-1),
			},
			{
				ref = "dodge8",
				name = "Desperate Measures",
				trait = "targetDodge",
				amount = 1,
				parent = "dodge7",
				links = "parent",
				pos = VectorTable(0,-1),
			},
			{
				ref = "dodge9",
				name = "Desperate Measures",
				trait = "targetDodge",
				amount = 1,
				parent = "dodge8",
				links = "parent",
				pos = VectorTable(1,-1),
			},
			{
				ref = "dodge10",
				name = "Desperate Measures",
				trait = "targetDodge",
				amount = 1,
				parent = "dodge9",
				links = "parent",
				pos = VectorTable(1,-1),
			},
			{
				ref = "dodge11",
				name = "Desperate Measures",
				trait = "targetDodge",
				amount = 1,
				parent = "dodge10",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "dodge12",
				name = "Desperate Measures",
				trait = "targetDodge",
				amount = 1,
				parent = "dodge11",
				links = "parent",
				pos = VectorTable(1,0),
			},
		},
		{
			{
				ref = "gh1",
				name = "Golden Health",
				trait = "targetGoldenHealth",
				amount = 2,
				parent = "regeneration2",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "gh2",
				name = "Golden Health",
				trait = "targetGoldenHealth",
				amount = 2,
				parent = "gh1",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "gh3",
				name = "Golden Health",
				trait = "targetGoldenHealth",
				amount = 2,
				parent = "gh2",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "gh4",
				name = "Golden Health",
				trait = "targetGoldenHealth",
				amount = 2,
				parent = "gh3",
				links = "parent",
				pos = VectorTable(0,1),
			},
			{
				ref = "gh5",
				name = "Golden Health",
				trait = "targetGoldenHealth",
				amount = 2,
				parent = "gh4",
				links = "parent",
				pos = VectorTable(-1,1),
			},
			{
				ref = "gh6",
				name = "Golden Health",
				trait = "targetGoldenHealth",
				amount = 2,
				parent = "gh5",
				links = "parent",
				pos = VectorTable(-1,0),
			},
			{
				ref = "gh7",
				name = "Golden Health",
				trait = "targetGoldenHealth",
				amount = 2,
				parent = "regeneration3",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "gh8",
				name = "Golden Health",
				trait = "targetGoldenHealth",
				amount = 2,
				parent = "gh7",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "gh9",
				name = "Golden Health",
				trait = "targetGoldenHealth",
				amount = 2,
				parent = "gh8",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "gh10",
				name = "Golden Health",
				trait = "targetGoldenHealth",
				amount = 2,
				parent = "gh9",
				links = "parent",
				pos = VectorTable(1,0),
			},
			{
				ref = "gh11",
				name = "Golden Health",
				trait = "targetGoldenHealth",
				amount = 2,
				parent = "gh10",
				links = "parent",
				pos = VectorTable(1,-1),
			},
			{
				ref = "gh12",
				name = "Golden Health",
				trait = "targetGoldenHealth",
				amount = 2,
				parent = "gh11",
				links = "parent",
				pos = VectorTable(0,-1),
			},
		},
		{
			{
				ref = "queenOfHearts",
				name = "Hail The Heart King",
				trait = "hoverballFactoryHealthAmplifier",
				amount = 20,
				tier = 1,
				parent = "gh6",
				links = {"gh6", "gh12"},
				pos = VectorTable(-1,0),
			},
			{
				ref = "gh13",
				name = "Golden Health",
				trait = "targetGoldenHealth",
				amount = 2,
				parent = "queenOfHearts",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "gh14",
				name = "Golden Health",
				trait = "targetGoldenHealth",
				amount = 2,
				parent = "gh13",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "gh15",
				name = "Golden Health",
				trait = "targetGoldenHealth",
				amount = 2,
				parent = "gh14",
				links = "parent",
				pos = VectorTable(1,1),
			},
		},
		{
			ref = "maximumMaximumHealth",
			name = "Maximum Maximum Health",
			trait = {"targetHealth", "targetHealthEffectiveness"},
			amount = {50, 100},
			tier = 2,
			parent = "dodge6",
			links = {"dodge6", "dodge12", "gh15"},
			pos = VectorTable(0,1),
		},
	},
	{
		{
			{
				ref = "gg1",
				name = "Gold Glitters",
				trait = "cashFromBalloons",
				amount = 1,
				parent = "physgun",
				links = "parent",
				pos = VectorTable(4,4),
				ang = 180
			},
			{
				ref = "gg2",
				name = "Gold Glitters",
				trait = "cashFromBalloons",
				amount = 1,
				parent = "gg1",
				links = "parent",
				pos = VectorTable(1,1)
			},
			{
				ref = "incomeGrower1",
				name = "Income Grower",
				trait = "waveWaveIncome",
				amount = 2,
				tier = 1,
				parent = "gg2",
				links = "parent",
				pos = VectorTable(1,1)
			},
		},
		{
			{
				ref = "wb1",
				name = "Wave Bonus",
				trait = "waveIncome",
				amount = 5,
				parent = "incomeGrower1",
				links = "parent",
				pos = VectorTable(-1,1)
			},
			{
				ref = "wb2",
				name = "Wave Bonus",
				trait = "waveIncome",
				amount = 5,
				parent = "wb1",
				links = {"incomeGrower1", "wb1"},
				pos = VectorTable(1,0)
			},
			{
				ref = "wb3",
				name = "Wave Bonus",
				trait = "waveIncome",
				amount = 5,
				parent = "wb1",
				links = "parent",
				pos = VectorTable(0,1)
			},
			{
				ref = "wb4",
				name = "Wave Bonus",
				trait = "waveIncome",
				amount = 5,
				parent = "wb2",
				links = {"wb2", "wb3"},
				pos = VectorTable(0,1)
			},
			{
				ref = "wb5",
				name = "Wave Bonus",
				trait = "waveIncome",
				amount = 5,
				parent = "wb3",
				links = "parent",
				pos = VectorTable(0,1)
			},
			{
				ref = "wb6",
				name = "Wave Bonus",
				trait = "waveIncome",
				amount = 5,
				parent = "wb4",
				links = {"wb4", "wb5"},
				pos = VectorTable(0,1)
			},
			{
				ref = "wb7",
				name = "Wave Bonus",
				trait = "waveIncome",
				amount = 5,
				parent = "wb5",
				links = "parent",
				pos = VectorTable(0,1)
			},
			{
				ref = "wb8",
				name = "Wave Bonus",
				trait = "waveIncome",
				amount = 5,
				parent = "wb6",
				links = {"wb6", "wb7"},
				pos = VectorTable(0,1)
			},
			{
				ref = "wb9",
				name = "Wave Bonus",
				trait = "waveIncome",
				amount = 5,
				parent = "wb7",
				links = "parent",
				pos = VectorTable(0,1)
			},
			{
				ref = "wb10",
				name = "Wave Bonus",
				trait = "waveIncome",
				amount = 5,
				parent = "wb8",
				links = {"wb8", "wb9"},
				pos = VectorTable(0,1)
			},
		},
		{
			ref = "incomeGrower2",
			name = "Income Grower",
			trait = "waveWaveIncome",
			amount = 2,
			tier = 1,
			parent = "wb10",
			links = {"wb9", "wb10"},
			pos = VectorTable(0,1)
		},
		{
			{
				ref = "sc1",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "incomeGrower1",
				links = {"incomeGrower1", "wb2"},
				pos = VectorTable(1,0)
			},
			{
				ref = "sc2",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc1",
				links = {"incomeGrower1", "sc1"},
				pos = VectorTable(0,-1)
			},
			{
				ref = "sc3",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc1",
				links = "parent",
				pos = VectorTable(1,0)
			},
			{
				ref = "sc4",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc2",
				links = {"sc2", "sc3"},
				pos = VectorTable(1,0)
			},
			{
				ref = "sc5",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc3",
				links = "parent",
				pos = VectorTable(1,0)
			},
			{
				ref = "sc6",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc4",
				links = {"sc4", "sc5"},
				pos = VectorTable(1,0)
			},
			{
				ref = "sc7",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc5",
				links = "parent",
				pos = VectorTable(1,0)
			},
			{
				ref = "sc8",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc6",
				links = {"sc6", "sc7"},
				pos = VectorTable(1,0)
			},
			{
				ref = "sc9",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc7",
				links = "parent",
				pos = VectorTable(1,0)
			},
			{
				ref = "sc10",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc8",
				links = {"sc8", "sc9"},
				pos = VectorTable(1,0)
			},
		},
		{
			ref = "outsourcedHoverballParts",
			name = "Outsourced Hoverball Parts",
			trait = "hoverballFactoryCosts",
			amount = -10,
			tier = 1,
			parent = "sc9",
			links = {"sc9", "sc10"},
			pos = VectorTable(1,0)
		},
		{
			{
				ref = "gg3",
				name = "Gold Glitters",
				trait = "cashFromBalloons",
				amount = 1,
				parent = "incomeGrower1",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "gg4",
				name = "Gold Glitters",
				trait = "cashFromBalloons",
				amount = 1,
				parent = "gg3",
				links = "parent",
				pos = VectorTable(1,1)
			},
			{
				ref = "gg5",
				name = "Gold Glitters",
				trait = "cashFromBalloons",
				amount = 1,
				parent = "gg4",
				links = "parent",
				pos = VectorTable(1,1)
			},
			{
				ref = "gg6",
				name = "Gold Glitters",
				trait = "cashFromBalloons",
				amount = 1,
				parent = "gg5",
				links = "parent",
				pos = VectorTable(1,1)
			},
			{
				ref = "rainbowMassProduction",
				name = "Rainbow Mass Production",
				trait = "rainbowBeamerCosts",
				amount = -10,
				tier = 1,
				parent = "gg6",
				links = "parent",
				pos = VectorTable(1,1)
			},
			{
				ref = "cheaperMines", -- prox mine cost
				name = "Cheaper Mines",
				trait = "proximityMineCosts",
				amount = -10,
				tier = 1,
				parent = "rainbowMassProduction",
				links = "parent",
				pos = VectorTable(1,1)
			},
		},
		{
			{
				ref = "sc11",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "cheaperMines",
				links = {"cheaperMines", "rainbowMassProduction"},
				pos = VectorTable(0,-1)
			},
			{
				ref = "sc12",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc11",
				links = {"cheaperMines", "sc11"},
				pos = VectorTable(1,0)
			},
			{
				ref = "sc13",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc11",
				links = {"sc11", "rainbowMassProduction"},
				pos = VectorTable(0,-1)
			},
			{
				ref = "sc14",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc12",
				links = {"sc12", "sc13"},
				pos = VectorTable(0,-1)
			},
			{
				ref = "sc15",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc13",
				links = "parent",
				pos = VectorTable(0,-1)
			},
			{
				ref = "sc16",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc14",
				links = {"sc14", "sc15"},
				pos = VectorTable(0,-1)
			},
			{
				ref = "sc17",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc15",
				links = "parent",
				pos = VectorTable(0,-1)
			},
			{
				ref = "sc18",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc16",
				links = {"sc16", "sc17"},
				pos = VectorTable(0,-1)
			},
			{
				ref = "sc19",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc17",
				links = {"sc17", "outsourcedHoverballParts", "sc9"},
				pos = VectorTable(0,-1)
			},
			{
				ref = "sc20",
				name = "Starting Cash",
				trait = "startingCash",
				amount = 25,
				parent = "sc18",
				links = {"sc18", "sc19", "outsourcedHoverballParts"},
				pos = VectorTable(0,-1)
			},
		},
		{
			{
				ref = "tcg1",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "rainbowMassProduction",
				links = "parent",
				pos = VectorTable(-1,1)
			},
			{
				ref = "tcg2",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg1",
				links = {"rainbowMassProduction", "tcg1", "cheaperMines"},
				pos = VectorTable(1,0)
			},
			{
				ref = "tcg3",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg1",
				links = "parent",
				pos = VectorTable(0,1)
			},
			{
				ref = "tcg4",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg2",
				links = {"tcg2", "tcg3", "cheaperMines"},
				pos = VectorTable(0,1)
			},
			{
				ref = "tcg5",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg3",
				links = "parent",
				pos = VectorTable(0,1)
			},
			{
				ref = "tcg6",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg4",
				links = {"tcg4", "tcg5"},
				pos = VectorTable(0,1)
			},
			{
				ref = "tcg7",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg5",
				links = "parent",
				pos = VectorTable(0,1)
			},
			{
				ref = "tcg8",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg6",
				links = {"tcg6", "tcg7"},
				pos = VectorTable(0,1)
			},
			{
				ref = "tcg9",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg7",
				links = "parent",
				pos = VectorTable(0,1)
			},
			{
				ref = "tcg10",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg8",
				links = {"tcg8", "tcg9"},
				pos = VectorTable(0,1)
			},
		},
		{
			ref = "valuableHoverballs",
			name = "Valuable Hoverballs",
			trait = "hoverballFactoryIncome",
			amount = 15,
			tier = 1,
			parent = "tcg10",
			links = {"tcg9", "tcg10"},
			pos = VectorTable(0,1)
		},
		{
			{
				ref = "tcg11",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "valuableHoverballs",
				links = "parent",
				pos = VectorTable(1,1)
			},
			{
				ref = "tcg12",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg11",
				links = {"valuableHoverballs", "tcg10", "tcg11"},
				pos = VectorTable(0,-1)
			},
			{
				ref = "tcg13",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg11",
				links = "parent",
				pos = VectorTable(1,0)
			},
			{
				ref = "tcg14",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg12",
				links = {"tcg12", "tcg13"},
				pos = VectorTable(1,0)
			},
			{
				ref = "tcg15",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg13",
				links = "parent",
				pos = VectorTable(1,0)
			},
			{
				ref = "tcg16",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg14",
				links = {"tcg14", "tcg15"},
				pos = VectorTable(1,0)
			},
			{
				ref = "tcg17",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg15",
				links = "parent",
				pos = VectorTable(1,0)
			},
			{
				ref = "tcg18",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg16",
				links = {"tcg16", "tcg17"},
				pos = VectorTable(1,0)
			},
			{
				ref = "tcg19",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg17",
				links = "parent",
				pos = VectorTable(1,0)
			},
			{
				ref = "tcg20",
				name = "Tower Cash Generation",
				trait = "towerIncome",
				amount = 1,
				parent = "tcg18",
				links = {"tcg18", "tcg19"},
				pos = VectorTable(1,0)
			},
		},
		{
			{
				ref = "gg7",
				name = "Gold Glitters",
				trait = "cashFromBalloons",
				amount = 1,
				parent = "cheaperMines",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "gg8",
				name = "Gold Glitters",
				trait = "cashFromBalloons",
				amount = 1,
				parent = "gg7",
				links = "parent",
				pos = VectorTable(1,1)
			},
			{
				ref = "gg9",
				name = "Gold Glitters",
				trait = "cashFromBalloons",
				amount = 1,
				parent = "gg8",
				links = "parent",
				pos = VectorTable(1,1)
			},
			{
				ref = "gg10",
				name = "Gold Glitters",
				trait = "cashFromBalloons",
				amount = 1,
				parent = "gg9",
				links = "parent",
				pos = VectorTable(1,1)
			},
			{
				ref = "freeAllyPawn",
				name = "Free Ally Pawn",
				trait = "allyPawnFirstFree",
				amount = 1,
				tier = 1,
				parent = "gg10",
				links = {"gg10", "tcg19", "tcg20"},
				pos = VectorTable(1,1)
			},
		},
		{
			{
				ref = "tc1",
				name = "Tower Costs",
				trait = "towerCosts",
				amount = -1,
				parent = "freeAllyPawn",
				links = {"freeAllyPawn", "tcg20"},
				pos = VectorTable(0,-1)
			},
			{
				ref = "tc2",
				name = "Tower Costs",
				trait = "towerCosts",
				amount = -1,
				parent = "tc1",
				links = {"tc1", "freeAllyPawn"},
				pos = VectorTable(1,0)
			},
			{
				ref = "tc3",
				name = "Tower Costs",
				trait = "towerCosts",
				amount = -1,
				parent = "tc1",
				links = "parent",
				pos = VectorTable(0,-1)
			},
			{
				ref = "tc4",
				name = "Tower Costs",
				trait = "towerCosts",
				amount = -1,
				parent = "tc2",
				links = {"tc2", "tc3"},
				pos = VectorTable(0,-1)
			},
			{
				ref = "tc5",
				name = "Tower Costs",
				trait = "towerCosts",
				amount = -1,
				parent = "tc3",
				links = "parent",
				pos = VectorTable(0,-1)
			},
			{
				ref = "tc6",
				name = "Tower Costs",
				trait = "towerCosts",
				amount = -1,
				parent = "tc4",
				links = {"tc4", "tc5"},
				pos = VectorTable(0,-1)
			},
			{
				ref = "tc7",
				name = "Tower Costs",
				trait = "towerCosts",
				amount = -1,
				parent = "tc5",
				links = "parent",
				pos = VectorTable(0,-1)
			},
			{
				ref = "tc8",
				name = "Tower Costs",
				trait = "towerCosts",
				amount = -1,
				parent = "tc6",
				links = {"tc6", "tc7"},
				pos = VectorTable(0,-1)
			},
			{
				ref = "tc9",
				name = "Tower Costs",
				trait = "towerCosts",
				amount = -1,
				parent = "tc7",
				links = "parent",
				pos = VectorTable(0,-1)
			},
			{
				ref = "tc10",
				name = "Tower Costs",
				trait = "towerCosts",
				amount = -1,
				parent = "tc8",
				links = {"tc8", "tc9"},
				pos = VectorTable(0,-1)
			},
		},
		{
			ref = "modularMicrowaveEmitters",
			name = "Modular Microwave Emitters",
			trait = "microwaveGeneratorCosts",
			amount = -10,
			tier = 1,
			parent = "tc9",
			links = {"tc9", "tc10"},
			pos = VectorTable(0,-1)
		},
		{
			{
				ref = "gg11",
				name = "Gold Glitters",
				trait = "cashFromBalloons",
				amount = 1,
				parent = "freeAllyPawn",
				links = "parent",
				pos = VectorTable(1,1),
			},
			{
				ref = "gBlimpBounties",
				name = "gBlimp Bounties",
				trait = "gBlimpOuterHealthCash",
				amount = 100,
				tier = 2,
				parent = "gg11",
				links = "parent",
				pos = VectorTable(1,1),
			},
		},
	},
	{
		{
			ref = "gbs1",
			name = "gBalloon Sabotage",
			trait = "gBalloonSpeed",
			amount = -1,
			links = "parent",
			pos = VectorTable(4,4),
			parent = "physgun",
			ang = 270
		},
		{
			ref = "gbs2",
			name = "gBalloon Sabotage",
			trait = "gBalloonSpeed",
			amount = -1,
			links = "parent",
			pos = VectorTable(1,1),
			parent = "gbs1",
		},
		{
			ref = "gbs3",
			name = "gBalloon Sabotage",
			trait = "gBalloonSpeed",
			amount = -1,
			links = "parent",
			pos = VectorTable(1,1),
			parent = "gbs2",
		},
		{
			ref = "gbs4",
			name = "gBalloon Sabotage",
			trait = "gBalloonSpeed",
			amount = -1,
			links = "parent",
			pos = VectorTable(-1,1),
			parent = "gbs3",
		},
		{
			ref = "gbs5",
			name = "gBalloon Sabotage",
			trait = "gBalloonSpeed",
			amount = -1,
			links = "parent",
			pos = VectorTable(-1,1),
			parent = "gbs4",
		},
		{
			ref = "gbs6",
			name = "gBalloon Sabotage",
			trait = "gBalloonSpeed",
			amount = -1,
			links = "parent",
			pos = VectorTable(1,0),
			parent = "gbs5",
		},
		{
			ref = "gbs7",
			name = "gBalloon Sabotage",
			trait = "gBalloonSpeed",
			amount = -1,
			links = "parent",
			pos = VectorTable(1,-1),
			parent = "gbs3",
		},
		{
			ref = "gbs8",
			name = "gBalloon Sabotage",
			trait = "gBalloonSpeed",
			amount = -1,
			links = "parent",
			pos = VectorTable(1,-1),
			parent = "gbs7",
		},
		{
			ref = "gbs9",
			name = "gBalloon Sabotage",
			trait = "gBalloonSpeed",
			amount = -1,
			links = "parent",
			pos = VectorTable(0,1),
			parent = "gbs8",
		},
	}
}
GM.BaseTraitsText = {
	towerPrice = "{0}% tower cost",
	physgun = "Gain the Physics Gun, which can be used to move towers, but only while there are no gBalloons on the map.",
	towerFireRate = "{0}% tower fire rate",
	towerEarlyFireRate = "{0}% tower fire rate, but gradually reduces down to +0.00% after Wave 40.",
	towerAbilityD3FireRate = "{0}% tower fire rate when an activated ability is triggered, for 1/3 of the cooldown duration.",
	towerMoneyFireRate = "{0}% tower fire rate, multiplied by the natural logarithm of the tower's price.",
	sniperQueenFireRate = "{0}% Sniper Queen fire rate",
	allyPawnFireRate = "{0}% Ally Pawn fire rate",
	--bishopOfGlueFireRate = "{0}% Bishop of Glue fire rate",
	fireCubeFireRate = "{0}% Fire Cube fire rate",
	towerRange = "{0}% tower range",
	proximityMineRange = "{0}% Proximity Mine range",
	allyPawnRange = "{0}% Ally Pawn range",
	fireCubeRange = "{0}% Fire Cube range",
	electrostaticBarrelBounces = "{0} Electrostatic Barrel arcs (rounded down)",
	gatlingGunKnightSpread = "{0}% Gatling Gun Knight bullet spread",
	--orbOfColdSpeedPercent = "gBalloons frozen by Orb Of Cold get {0}% speed for 3 seconds",
	mortarTowerBombRadius = "{0}% Mortar Tower explosion radius",
	sawbladeLauncherPierce = "{0} Sawblade Launcher pierce (rounded down)",
	microwaveGeneratorMicrowaveAngle = "{0}% Microwave Generator fire angle",
	turretFactoryAbilityCooldown = "{0}% Turret Factory generation delay",
	pillLobberFlyTime = "{0}% Pill Lobber pill travel time",
	pillLobberExploRadius = "{0}% Pill Lobber pill splash radius",
	pillLobberDirectDamage = "{0} Pill Lobber direct hit damage (rounded down)",
	allyPawnTargets = "{0}% Ally Pawn targets (rounded down)",
	targetDefence = "{0}% gBalloon Target defence. Damage taken is divided by defence (rounding up).",
	targetHealth = "{0}% gBalloon Target health (rounded down)",
	targetOSP = "For {0} times (rounded down), all fatal damage received by gBalloon Targets are negated.",
	targetRegeneration = "All damaged gBalloon Targets gain {0} health at the end of each wave (rounded down).",
	hoverballFactoryHealthAmplifier = "{0}% X-X-4+ Hoverball Factory health generation",
	targetShield = "Damage is prevented each wave, up to {0}% of maximum health (rounded down).",
	targetGoldenHealth = "{0} gBalloon Target golden health (rounded down)",
	targetArmor = "{0} gBalloon Target armor. Damage taken is subtracted by armor (rounding up).",
	targetDodge = "{0}% chance to completely prevent damage",
	targetHealthEffectiveness = "{0}% gBalloon Target health health effects",
	cashFromBalloons = "{0}% cash from gBalloons",
	null = "This perk does nothing.",
	waveIncome = "{0}% bonus cash per wave",
	waveWaveIncome = "{0} bonus cash per wave, per wave",
	startingCash = "{0} starting cash",
	hoverballFactoryCosts = "{0}% Hoverball Factory tower and upgrade costs",
	proximityMineCosts = "{0}% Proximity Mine tower and upgrade costs",
	rainbowBeamerCosts = "{0}% Rainbow Beamer tower and upgrade costs",
	towerCosts = "{0}% tower and upgrade costs",
	microwaveGeneratorCosts = "{0}% Microwave Generator tower and upgrade costs",
	towerIncome = "{0}% tower cash generation",
	allyPawnFirstFree = "The first Ally Pawn placed by one player is absolutely free.",
	hoverballFactoryIncome = "{0}% Hoverball Factory cash generation",
	gBlimpOuterHealthCash = "All spawned gBlimps' outer layer yields extra cash when popped, equal to {0}% of the outer layer's health.",
	gBalloonSpeed = "{0}% gBalloon speed",
}
GM.AppliedSkills = {}

--[[ TODO: skill ideas
health reduction (gBalloons)
speed reduction (gBalloons)
armor reduction (gBalloons)
resistance reduction (gBalloons)
[chance for] missing attribute (gBalloons)
chance to block for each damage point taken (targets)
max health (targets)
shield (targets)
@towers [on certain upgrades] [with certain targeting] [when damage is taken] [increased by damage taken]
fire rate (towers)
damage (towers)
upgrade restriction reduction (towers)
cost reduction (cash<towers)
starting cash (cash)
cash gain [from [gBlimp] pops|from gBlimp hits] [from towers] (cash)
start with pistol (meta)
start with rocket launcher (meta)
start with physgun (meta)
skill effectiveness (meta)
experience gain [from gBlimps] [in freeplay] (meta)
]]

AccessorFunc(GM, "CachedSkillAmounts", "CachedSkillAmounts")
AccessorFunc(GM, "SkillNames", "SkillNames")
AccessorFunc(GM, "Skills", "Skills")
AccessorFunc(GM, "TraitsText", "TraitsText")

function GM:RebuildSkills()
	hook.Run("RTG_Log", "Building skill web...", RTG_LOGGING_INFO)
	local buildTime = SysTime()
	local links = 0
	hook.Run("SetSkills", {})
	hook.Run("SetSkillNames", {})
	local unprocessedSkills = {}
	for k,v in pairs(self.BaseSkills) do
		unprocessedSkills[k] = v
	end
	hook.Run("ROTGB:TG_GatherCustomSkills", unprocessedSkills)
	for k,v in pairs(unprocessedSkills) do
		hook.Run("CompileSkillTable", v)
	end
	-- yes, we have to loop *again*
	local skills = hook.Run("GetSkills")
	for k,v in pairs(skills) do
		if v.parent then
			local lookupName = v.parent
			local parentID = hook.Run("GetSkillNames")[lookupName]
			if parentID then
				v.parent = parentID
			else
				hook.Run("RTG_Log", "Unknown parent skill \""..tostring(lookupName).."\" in skill \""..tostring(v.ref).."\"!", RTG_LOGGING_ERROR)
			end
		end
		if v.links == "parent" then
			v.links = {[v.parent]=true}
		else -- table of refs
			local newLinks = {}
			for k2,v2 in pairs(v.links) do
				local skillID = hook.Run("GetSkillNames")[v2]
				if skillID then
					newLinks[skillID] = true
					links = links + 1
				else
					hook.Run("RTG_Log", "Unknown linked skill \""..tostring(v2).."\" in skill \""..tostring(v.ref).."\"!", RTG_LOGGING_ERROR)
				end
			end
			v.links = newLinks
		end
		for k2,v2 in pairs(v.links) do
			if (skills[k2] and not skills[k2].links[k]) then
				skills[k2].links[k] = true
				links = links + 1
			end
		end
	end
	local skillsText = {}
	for k,v in pairs(self.BaseTraitsText) do
		skillsText[k] = v
	end
	hook.Run("ROTGB:TG_GatherCustomTraitsText", skillsText)
	hook.Run("SetTraitsText", skillsText)
	--PrintTable(hook.Run("GetSkills"))
	hook.Run("RTG_Log", string.format("Finished building skill web in %.4f ms.", (SysTime()-buildTime)*1000), RTG_LOGGING_INFO)
	hook.Run("RTG_Log", string.format("Nodes: %i, Links: %i", #skills, links/2), RTG_LOGGING_INFO)
end

function GM:CompileSkillTable(unprocessedSkill)
	if istable(unprocessedSkill) then
		local skillTable = {}
		local currentSkills = hook.Run("GetSkills")
		local skillNum = #currentSkills+1
		local skillNames = hook.Run("GetSkillNames")
		for k,v in pairs(unprocessedSkill) do
			if k == "ref" then
				if skillNames[v] then
					print("Offending tables:")
					PrintTable(currentSkills[skillNames[v]])
					PrintTable(unprocessedSkill)
					error("Duplicate skill name: "..tostring(v).." (see above tables)")
				else
					skillNames[v] = skillNum
				end
			end
			skillTable[k] = v
		end
		if skillTable.ref then
			if not skillTable.tier then
				skillTable.tier = 0
			end
			if not skillTable.ang then
				skillTable.ang = 0
			end
			if not skillTable.pos then
				skillTable.pos = VectorTable(0,0)
			else
				skillTable.pos[2] = -skillTable.pos[2]
			end
			if not skillTable.links then
				skillTable.links = {}
			end
			hook.Run("GetSkills")[skillNum] = skillTable
		else -- recursive structure
			for k,v in pairs(skillTable) do
				hook.Run("CompileSkillTable", v)
			end
		end
	else
		hook.Run("RTG_Log", "\""..tostring(unprocessedSkill).."\" is not a skill table!", RTG_LOGGING_ERROR)
	end
end

function GM:GatherCustomSkills(skills)
	-- skills can be added here, ideally through a hook (hook.Add("GatherCustomSkills", ...))
end

function GM:CreateSkillAmountsCache(extraTrait)
	local appliedSkills = hook.Run("GetAppliedSkills")
	local skills = hook.Run("GetSkills")
	local traits = {}
	for k,v in pairs(appliedSkills) do
		local skill = skills[k]
		if istable(skill.trait) then
			for k,v in pairs(skill.trait) do
				traits[v] = (traits[v] or 0) + skill.amount[k]
			end
		else
			traits[skill.trait] = (traits[skill.trait] or 0) + skill.amount
		end
	end
	if not traits[extraTrait] then
		traits[extraTrait] = 0
	end
	for k,v in pairs(traits) do
		if k ~= "skillEffectiveness" then
			traits[k] = v*(1+(traits.skillEffectiveness or 0)/100)
		end
	end
	hook.Run("SetCachedSkillAmounts", traits)
end

function GM:GetSkillAmount(trait)
	local cachedSkillTraits = hook.Run("GetCachedSkillAmounts")
	if not cachedSkillTraits[trait] then
		hook.Run("CreateSkillAmountsCache", trait)
		cachedSkillTraits = hook.Run("GetCachedSkillAmounts")
	end
	
	return cachedSkillTraits[trait]
end

function GM:AddAppliedSkills(skills)
	hook.Run("SetAppliedSkills", table.Merge(skills, hook.Run("GetAppliedSkills")))
end

function GM:ClearAppliedSkills(skills)
	table.Empty(self.AppliedSkills)
	table.Empty(hook.Run("GetCachedSkillAmounts"))
end

function GM:SetAppliedSkills(skills)
	self.AppliedSkills = skills
	table.Empty(hook.Run("GetCachedSkillAmounts"))
end

function GM:GetAppliedSkills()
	return self.AppliedSkills or {}
end

function GM:IsAppliedSkill(skillName)
	return hook.Run("GetAppliedSkills")[hook.Run("GetSkillNames")[skillName]]
end

local PLAYER = FindMetaTable("Player")

local experienceNeeded = {
	100, 250, 500, 1e3, 2e3,
	4e3, 7.5e3, 13.5e3, 23e3, 38e3
}
local function getExperienceNeeded(currentLevel)
	currentLevel = math.floor(currentLevel)
	if currentLevel < 1 then return 0
	elseif experienceNeeded[currentLevel] then return experienceNeeded[currentLevel]
	else
		local n = currentLevel-8.7
		return 5e3*(n*n+n+4.61)
	end
end

function PLAYER:RTG_GetLevel()
	if getExperienceNeeded(self.rtg_Level) <= self:RTG_GetExperience() then
		self:RTG_UpdateLevel()
	end
	return self.rtg_Level
end

function PLAYER:RTG_GetLevelFraction()
	return math.Remap(self:RTG_GetExperience(), getExperienceNeeded(self:RTG_GetLevel()-1), getExperienceNeeded(self:RTG_GetLevel()), 0, 1)
end

function PLAYER:RTG_GetExperience()
	-- experience is stored clientside, so it's impossible to completely prevent clients from modifying their experience value
	-- especially with open source code, it's better to not bother about it
	return (self.rtg_PreviousXP or 0) + self.rtg_XP
end

function PLAYER:RTG_GetExperienceNeeded()
	return getExperienceNeeded(self:RTG_GetLevel())
end

function PLAYER:RTG_UpdateLevel()
	while getExperienceNeeded(self.rtg_Level) <= self:RTG_GetExperience() do
		self.rtg_Level = self.rtg_Level + 1
	end
end

function PLAYER:RTG_ClearSkills()
	table.Empty(self.rtg_Skills)
	self.rtg_SkillAmount = 0
	hook.Run("PlayerClearSkills", self, cleared)
end

function PLAYER:RTG_AddSkills(skillIDs)
	for k,v in pairs(skillIDs) do
		self.rtg_Skills[k] = v
	end
	self.rtg_SkillAmount = table.Count(self.rtg_Skills)
	hook.Run("PlayerAddSkills", self, skillIDs)
end

function PLAYER:RTG_GetSkillAmount()
	return self.rtg_SkillAmount
end

function PLAYER:RTG_GetSkills()
	return self.rtg_Skills
end

function PLAYER:RTG_HasSkill(skillID)
	return self.rtg_Skills[skillID] or false
end

function PLAYER:RTG_SkillUnlocked(skillID, skills)
	skills = skills or hook.Run("GetSkills")
	for k,v in pairs(skills[skillID].links) do
		if self:RTG_HasSkill(k) then return true end
	end
	return skills[skillID].alwaysUnlocked
end

local cachedTowers
function PLAYER:RTG_GetSkillPoints()
	if not cachedTowers then
		cachedTowers = ROTGB_GetAllTowers()
	end
	return self:RTG_GetLevel() - self:RTG_GetSkillAmount() - #cachedTowers
end