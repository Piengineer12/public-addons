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
    daredevil = {
        name = "Daredevil",
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
        desc = "%+.0f%% movement speed while sprinting. On kill, restore +%u Aux Power, up to 100.",
        values = function(level)
            return level * 10, level * 5
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
        name = "Adaptive Shield",
        desc = "Whenever damage would be taken from a mob, gain %+.1f stack(s) of Adaptive Shield. \z
        Each stack gives 1%% more defence, but stacks decay at a rate of -1%%/s. \z
        The Hellish Challenge skill is also +%u%% more effective.",
        values = function(level)
            return level/5, level * 20
        end,
        stackTick = function(state, current, time, ent)
            local nextStacks = current * .99 ^ time
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
        img = "breastplate",
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
        img = "hammer-nails",
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
    crystallized_time = {
        name = "Bending Time And Space",
        desc = "Double tap %s while alive and holding %s to revert position, angles, \z
        health and shield to their values +%u second(s) ago. \z
        However, also gain a player trail with a life time of +%u second(s).",
        values = function(level)
            local slowWalkKey = "the Slow Walk key"
            local speedKey = "the Sprint key"
            if CLIENT then
                local keyName = input.LookupBinding("+walk")
                if keyName then
                    slowWalkKey = keyName:upper()
                end
                keyName = input.LookupBinding("+speed")
                if keyName then
                    speedKey = keyName:upper()
                end
            end

            return slowWalkKey, speedKey, level, level
        end,
        img = "emerald",
        pos = {1, 3},
        minpts = 5
    },
    jumper = {
        name = "Jumper",
        desc = "+%u mid-air jumps",
        values = function(level)
            return level
        end,
        img = "feather",
        pos = {-1, 3},
        minpts = 5
    },
    living_on_the_edge = {
        name = "Living on the Edge",
        desc = "Take less damage on low health, up to %i%%.",
        values = function(level)
            return level * -8
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
        img = "pierced-heart",
        pos = {-3, 1},
        minpts = 5
    },
    watch_your_head = {
        name = "Watch Your Head",
        desc = "%i%% critical damage taken",
        values = function(level)
            return level*-8
        end,
        img = "rear-aura",
        pos = {-3, -1},
        minpts = 5
    },
    kablooey = {
        name = "Kablooey!",
        desc = "+%u%% explosive damage dealt. \z
        Explosive hits towards enemies have a +%u%% chance of spawning a random item.",
        values = function(level)
            return level * 10, level * 2
        end,
        img = "explosion-rays",
        pos = {-2, -2},
        minpts = 5
    },
    a_little_less_gun = {
        name = "A Little Less Gun",
        desc = "+%u%% non-bullet damage dealt",
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
        desc = "Gain +%u stack(s) of Brilliant Behemoth per second, up to %s. \z
        While %s is not held, all bullets and hits against entities consume 1 stack \z
        to create an explosion with %s radii! \z
        Note that these explosions hurt ALL entities in range.",
        values = function(level)
            local slowWalkKey = "the Slow Walk key"
            local maxStacks = level * 100
            local distance = level * 128
            if CLIENT then
                local keyName = input.LookupBinding("+walk")
                if keyName then
                    slowWalkKey = keyName:upper()
                end
                maxStacks = InsaneStats:FormatNumber(maxStacks, {plus = true})
                distance = InsaneStats:FormatNumber(distance, {plus = true, distance = true})
            end
            return level * 5, maxStacks, slowWalkKey, distance, level * 100
        end,
        stackTick = function(state, current, time, ent)
            local values = {ent:InsaneStats_GetEffectiveSkillValues("brilliant_behemoth")}
            local newStacks = math.min(current + time * values[1], values[5])

            return (
                ent:IsPlayer()
                and ent:KeyDown(IN_WALK)
                or ent:InsaneStats_HasStatusEffect("no_spreading_damage")
            ) and -1 or newStacks >= 1 and 1 or 0, newStacks
        end,
        img = "explosive-materials",
        pos = {0, -3},
        minpts = 10,
        max = 1
    },
    youre_approaching_me = {
        name = "You're Approaching Me?",
        desc = "+%u%% damage dealt against entities within %s",
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
        desc = "%i%% ammo consumption",
        values = function(level)
            return level * -8
        end,
        img = "crystal-bars",
        pos = {3, -2},
        minpts = 5
    },
    friendly_fire_off = {
        name = "Friendly Fire OFF",
        desc = "While %s is not held, deal -100%% non-dissolving damage against non-player allies%s%s.",
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
            local extra1 = level > 1 and string.format(". Also, double tapping %s \z
                will cause all squad citizens and rebels that are over %s away \z
                to be teleported closer", slowWalkKey, distance) or ""
            local extra2 = level > 2 and ". Additionally, \z
                gain +100% damage dealt for 10 seconds whenever an enemy hurts any allies" or ""
            return slowWalkKey, extra1, extra2, distance
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
        desc = "+%u%% XP gain from kills by other entities",
        values = function(level)
            return level * 10
        end,
        img = "gift-of-knowledge",
        pos = {3, 2},
        minpts = 5
    },
    super_cold = game.SinglePlayer() and {
        name = "Super Cold",
        desc = "While not in a vehicle, game speed is reduced based on speed. \z
        At normal running speed, time takes +%u%% longer to pass. \z
        However, all damage taken is multiplied by game speed. \n\z
        (This skill is completely different in multiplayer.)",
        values = function(level)
            return level * 5
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
            return slowWalkKey, 240 * 2 ^ -level
        end,
        stackTick = function(state, stacks, time, ent)
            local disabled = ent:InsaneStats_HasStatusEffect("no_movement_modifications")
            if state == 1 then
                stacks = stacks - time
                if stacks < 0 or disabled then
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
            if disabled then
                state = -1
            end

            return state, stacks
        end,
        img = "spectre",
        pos = {0, 3},
        minpts = 10,
        max = 1
    },
    map_sense = {
        name = "Map Sense",
        desc = "See all buttons, doors and breakable brushes within %s!",
        values = function(level, ent)
            level = level * (1 + ent:InsaneStats_GetEffectiveSkillValues("so_heres_the_problem", 4) / 100)
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
        desc = "%+i%% damage taken",
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
            return 240 * 2 ^ -level
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
        desc = "On kill, restore +%u%% of max health. Health gained this way can exceed max health, \z
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
        desc = "+%u%% damage dealt against entities further than %s",
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
        desc = "%+i%% damage dealt",
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
        but stacks decay at a rate of -1%%/s.",
        values = function(level)
            return level/5
        end,
        stackTick = function(state, current, time, ent)
            local nextStacks = current * .99 ^ time
            return nextStacks <= 0 and 0 or 1, nextStacks
        end,
        img = "hot-spices",
        pos = {3, -3},
        minpts = 5
    },
    infusion = {
        name = "Infusion",
        desc = "On kill, gain %s max health.",
        values = function(level, ent)
            local scaleType = ent:IsPlayer() and "player" or "other"
            local effectiveLevel = InsaneStats:GetConVarValue("xp_enabled") and ent:InsaneStats_GetLevel() or 1
            local val = InsaneStats:ScaleValueToLevel(
                level/50,
                InsaneStats:GetConVarValue("xp_"..scaleType.."_health")/100,
                effectiveLevel,
                "xp_"..scaleType.."_health_mode"
            )
            return CLIENT and InsaneStats:FormatNumber(val, {plus = true}) or val, val
        end,
        img = "glass-heart",
        pos = {4, -2},
        minpts = 5
    },
    additional_pylons = {
        name = "Additional Pylons",
        desc = "On kill, gain %s max armor.",
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
            return CLIENT and InsaneStats:FormatNumber(val, {plus = true}) or val, val
        end,
        img = "bordered-shield",
        pos = {4, 2},
        minpts = 5
    },
    jazz_feet = {
        name = "Jazz Feet",
        desc = "Gain more coins and XP based on speed. \z
        At normal running speed, coins and XP gain is increased by +%u%%.",
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
        Also, the softcap and hardcap effects of overhealing are reduced by %.1f%%, \z
        but Coin Shops will no longer offer free healing.",
        values = function(level, ent)
            -- min level above 0: 0.2, max level: 40.8
            level = level * (1 + ent:InsaneStats_GetEffectiveSkillValues("bloodletters_revelation", 2) / 100)
            return 100 - level * 2, math.max(-3 * level, -100)
        end,
        img = "bleeding-heart",
        pos = {2, 4},
        minpts = 5
    },
    aux_aux_battery = {
        name = "Aux Aux Battery",
        desc = "While Aux Power is disabled or at 100%% Aux Power, gain +%u%% more XP. \z
        Aux Power has a +%i%% chance of not being consumed.",
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
        desc = "+%u%% non-dissolving damage absorption chance while shielded. \z
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
        desc = "On kill, restore +%u%% of max shield. Shield gained this way can exceed max shield, \z
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
        Each stack increases defence and ammo efficiency by 1%%, but stacks decay at a rate of -1%%/s. \z
        Additionally, interacting with an Ammo Crate causes all stacks to be removed \z
        and Coin Shops will no longer sell ammo for free.",
        values = function(level)
            return 100 - level * 5
        end,
        stackTick = function(state, current, time, ent)
            local nextStacks = current * .99 ^ time
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
            return level * 10, math.max(level * -10, -100), level * 10,
            zoomKey, 75 - level * 5
        end,
        img = "crossed-pistols",
        pos = {-2, -4},
        minpts = 5
    },

    -- distance 7
    the_red_plague = {
        name = "The Red Plague",
        desc = "On hitting a mob, inflict Bleeding for %u seconds, triggering on-hit effects over time! \z
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
        desc = "+%u%% non-bullet damage dealt. While %s is not held, gain %s bullet penetration.",
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
            return level * 5, slowWalkKey, distance, level * 20
        end,
        stackTick = function(state, current, time, ent)
            return (
                ent:IsPlayer() and ent:KeyDown(IN_WALK)
                or ent:InsaneStats_HasStatusEffect("no_spreading_damage")
            ) and -1 or 1, current
        end,
        img = "supersonic-bullet",
        pos = {2, -5},
        minpts = 5
    },
    increase_the_pressure = {
        name = "Increase the Pressure",
        desc = "On kill, gain %+.1f stack(s) of Increase the Pressure. \z
        Each stack increases most weapons' fire rate by 1%%, but stacks decay at a rate of -1%%/s.",
        values = function(level)
            return level/5
        end,
        stackTick = function(state, current, time, ent)
            local nextStacks = current * .99 ^ time
            return nextStacks <= 0 and 0 or 1, nextStacks
        end,
        img = "hydra-shot",
        pos = {3, -4},
        minpts = 5
    },
    multi_killer = {
        name = "Multi Killer",
        desc = "On kill or prop broken, gain +%u stacks of Multi Killer. \z
        Each stack gives 1%% more coins and XP, \z
        but stacks decay at a rate of %.1f/s plus an additional -50%%/s.",
        values = function(level, ent)
            return level * 10, level / -10
        end,
        stackTick = function(state, current, time, ent)
            local constantDecayRate = ent:InsaneStats_GetEffectiveSkillValues("multi_killer", 2)
            local expDecayRate = 0.5
            local offset = -constantDecayRate / expDecayRate
            local nextStacks = (current + offset) * expDecayRate ^ time - offset
            nextStacks = math.max(nextStacks, 0)
            --local nextStacks = current * 0.5 ^ time
            return nextStacks <= 0 and 0 or 1, nextStacks
        end,
        img = "double-shot",
        pos = {4, -3},
        minpts = 5
    },
    keep_it_fresh = {
        name = "Keep It Fresh",
        desc = "On kill, set the number of Keep It Fresh stacks to +%u \z
        unless the kill was done with the same weapon as the last kill, \z
        in which case the number of stacks is reduced by %i instead. \z
        Each stack gives 1%% more coins and XP, and stacks cannot go below zero.",
        values = function(level, ent)
            return (25 + 5 * level) * (1 + ent:InsaneStats_GetEffectiveSkillValues("the_fourth_dimension", 2) / 100),
            math.min(level*5 - 30, 0)
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
        desc = "The position of the nearest enemy is marked on the HUD! \z
        Towards this entity, damage dealt, coins and XP gained \z
        are all increased by +%u%%, and damage taken from this entity is reduced by %i%%.",
        values = function(level)
            return level * 10, level * -10
        end,
        img = "radar-sweep",
        pos = {4, -1},
        minpts = 10,
        max = 1
    },
    boundless_shield = {
        name = "Boundless Shield",
        desc = "Armor Batteries%s can be picked up%s even while maxed, but with diminishing returns!%s",
        values = function(level)
            if level > 2 then
                return " and Stunsticks",
                " for shield and Suit Chargers can be used",
                " Suit Chargers are also used instantly."
            elseif level > 1 then
                return "",
                " and Suit Chargers can be used",
                " Suit Chargers are also used instantly."
            else
                return "", "", ""
            end
        end,
        img = "shield-echoes",
        pos = {4, 1},
        minpts = 10,
        max = 1
    },
    unseen_killer = {
        name = "Unseen Killer",
        desc = "+%u%% coins and XP gained from kills either happening behind, \z
        or an obstacle is blocking sight to the victim.",
        values = function(level, ent)
            return level * 25
        end,
        img = "owl",
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
    vampiric = {
        name = "Vampiric",
        desc = "Restore +%.1f%% health per hit. However, take %s BASE fire damage per second \z
        while under sunlight or even moonlight.",
        values = function(level, ent)
            local value = level * InsaneStats:DetermineDamageMulPure(
                ent, game.GetWorld()
            )
            return level/5, CLIENT and InsaneStats:FormatNumber(value) or value
        end,
        img = "batwing-emblem",
        pos = {2, 5},
        minpts = 5
    },
    just_breathe = game.SinglePlayer() and {
        name = "Just Breathe",
        desc = "Double tap %s while holding %s to reduce game speed by %i%% \z
        and increase movement rate by %+i%% for 10 seconds! \z
        While this skill is active, Ain't Got Time For This stacks \z
        are gained %+i%% faster. 60 seconds cooldown.\n\z
        (This skill is completely different in multiplayer.)",
        values = function(level)
            local slowWalkKey = "the Slow Walk key"
            local crouchKey = "the Crouch key"
            if CLIENT then
                local keyName = input.LookupBinding("+walk")
                if keyName then
                    slowWalkKey = keyName:upper()
                end
                keyName = input.LookupBinding("+duck")
                if keyName then
                    crouchKey = keyName:upper()
                end
            end
            return slowWalkKey, crouchKey, math.max(-25 - level * 25, -88), -100 + level * 200, -100 + level * 200
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
        desc = "Double tap %s to increase damage dealt by +%u%% and \z
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
            return slowWalkKey, level * 50, math.max(level * -40, -100)
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
        name = "How They Come Together",
        desc = "Interacting with a key will show the door it unlocks on the HUD, and vice versa, for +%u seconds.%s",
        values = function(level, ent)
            if level > 1 then
                return level * 30, " Indicators are also shown at the exact points to slot a key in \z
                and when ANY door / button gets unlocked or moved."
            else return level * 30, ""
            end
        end,
        img = "gears",
        pos = {-1, 4},
        minpts = 10,
        max = 1
    },
    you_all_get_a_car = {
        name = "You All Get A Car",
        desc = "While %s is not held, share up to level %+i of most skills with all allies.",
        values = function(level, ent)
            local slowWalkKey = "the Slow Walk key"
            if CLIENT then
                local keyName = input.LookupBinding("+walk")
                if keyName then
                    slowWalkKey = keyName:upper()
                end
            end
            return slowWalkKey, level
        end,
        stackTick = function(state, current, time, ent)
            return ent:IsPlayer() and ent:KeyDown(IN_WALK) and -1 or 1, current
        end,
        img = "two-shadows",
        pos = {-2, 5},
        minpts = 5
    },
    item_magnet = {
        name = "Reach For The Stars",
        desc = "Attract items and weapons wtihin %s times the number of skill points gained in total (%s at current total skill points). \z
        Random items created within this range are teleported instead of magnetized! \z
        Also, automatically pick up coins that are furthest from any other player after %u seconds.",
        values = function(level, ent)
            local distance1 = level
			local skillPoints = ent:InsaneStats_GetTotalSkillPoints()
			local distance2 = level * skillPoints
            if CLIENT then
                distance1 = InsaneStats:FormatNumber(distance1, {plus = true, distance = true})
                distance2 = InsaneStats:FormatNumber(distance2, {plus = true, distance = true})
            end
            return distance1, distance2, math.max(20 - level * 2, 0)
        end,
        img = "grab",
        pos = {-3, 4},
        minpts = 5
    },
    starlight = {
        name = "Starlight",
        desc = "On kill or prop broken, gain %+.1f stack(s) of Starlight. \z
        Each stack gives 1%% more defence and while %s is not held, %s of night vision. \z
        Stacks decay at a rate of -1%%/s. \z
        Additionally, increase game brightness by +%u%% while the flashlight is enabled.",
        values = function(level)
            local distance = 16
            local slowWalkKey = "the Slow Walk key"
            if CLIENT then
                distance = InsaneStats:FormatNumber(distance, {distance = true})
                local keyName = input.LookupBinding("+walk")
                if keyName then
                    slowWalkKey = keyName:upper()
                end
            end
            return level/5, slowWalkKey, distance, 10 * level, 16
        end,
        stackTick = function(state, current, time, ent)
            local nextStacks = current * .99 ^ time
            return ent:IsPlayer() and ent:KeyDown(IN_WALK) and -1 or nextStacks <= 0 and 0 or 1, nextStacks
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
    --[[fight_for_your_life = {
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
    },]]
    rise_from_your_grave = {
        name = "Rise From Your Grave",
        desc = "Respawn exactly where the last death occured if there is space. %u seconds cooldown.",
        values = function(level)
            return 240 * 2 ^ -level
        end,
        stackTick = function(state, stacks, time, ent)
            stacks = math.max(stacks - time, 0)
            return stacks > 0 and -1 or 1, stacks
        end,
        img = "pirate-grave",
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
        desc = "At low health, critical hits restore up to +%u%% of max health.",
        values = function(level)
            return level
        end,
        img = "bird-claw",
        pos = {-4, -3},
        minpts = 5
    },
    instant_karma = {
        name = "Instant Karma",
        desc = "Whenever damage would be taken while %s is not held, \z
        there is a +%u%% chance to deal %s BASE damage back! \z
        The Hellish Challenge skill is also +%u%% more effective.",
        values = function(level, ent)
            local val = 4 * InsaneStats:DetermineDamageMulPure(
                ent, game.GetWorld()
            )
            local slowWalkKey = "the Slow Walk key"

            if CLIENT then
                val = InsaneStats:FormatNumber(val)

                local keyName = input.LookupBinding("+walk")
                if keyName then
                    slowWalkKey = keyName:upper()
                end
            end

            return slowWalkKey, level * 10, val, level * 20
        end,
        stackTick = function(state, current, time, ent)
            return (
                ent:IsPlayer() and ent:KeyDown(IN_WALK)
                or ent:InsaneStats_HasStatusEffect("no_spreading_damage")
            ) and -1 or 1, current
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
        desc = "Taking damage triples all damage dealt for 10 seconds! %u seconds cooldown. \z
        However, dealing explosive damage to an NPC for the first time creates a live grenade that explodes after 2 seconds, \z
        at most once every %.1f second(s). The Hellish Challenge skill is also +%u%% more effective.",
        values = function(level)
            return math.max(180 - level * 60, 0), 0.5 - level / 10, level * 50
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
        desc = "On kill, gain 1 stack of Killing Spree for 1 minute. \z
        Every power of 5 Killing Spree stacks grants an additional positive status effect on kill, \z
        with status effects randomly selected from a pool of +%u. \z
        Having more Killing Spree stacks will also increase the potency of the positive effects!",
        values = function(level)
            return level * 4
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
        fires a %s BASE damage bullet that deals melee damage, \z
        punting objects with the same force as the Gravity Gun. \z
        Holding down %s with a melee weapon at 1 stack will instead absorb the next damage taken. \z
        Triggering either of these effects consumes 1 stack, but effects that increase fire rate \z
        will reduce the amount of stacks consumed.",
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
            return ent:InsaneStats_HasStatusEffect("no_spreading_damage") and -1
            or newStacks >= 1 and 1 or 0, newStacks
        end,
        img = "spinning-sword",
        pos = {2, -6},
        minpts = 5
    },
    anti_coward_rounds = {
        name = "Shield Inverter",
        desc = "+%u%% damage dealt against props and armored entities. \z
        Shielded entities also take more damage based on shield %%. \z
        Against 100%% shield, damage dealt is increased by +%u%%.",
        values = function(level)
            return level * 10, level * 10
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
            return level * 8, level * -4, level * 8
        end,
        img = "microscope-lens",
        pos = {4, -4},
        minpts = 5
    },
    --[[upward_spiralling = {
        name = "Upward Spiralling",
        desc = "Every skill point gained in total gives +%.2f%% coins and XP \z
        (%s%% coins and XP gain at current total skill points).",
        values = function(level, ent)
            local thirdValue = (
                level/50 --+ level/200
                --* ent:InsaneStats_GetSpentUberSkillPoints()
            ) * ent:InsaneStats_GetTotalSkillPoints()
            return level/50, CLIENT and InsaneStats:FormatNumber(thirdValue, {plus = true}) or thirdValue
        end,
        img = "crown-coin",
        pos = {5, -3},
        minpts = 5
    },]]
    time_is_money = {
        name = "Time Is Money",
        desc = "Pressing a movement key for the first time after spawning \z
        gives +%u stacks of Time Is Money. Each stack gives 1%% more coins and XP, \z
        but stacks decay at a rate of -1%%/s.",
        values = function(level, ent)
            return level * 25
        end,
        stackTick = function(state, current, time, ent)
            local nextStacks = current * .99 ^ time
            return state, nextStacks
        end,
        img = "crown-coin",
        pos = {5, -3},
        minpts = 5
    },
    too_many_items = {
        name = "Too Many Items",
        desc = "Gain +%u stack(s) of Too Many Items whenever an item is picked up. \z
        All skills and modifiers that would create random items \z
        instead grant +%u stacks of this skill, multiplied by all item multipliers. \z
        At 100 stacks, consume 100 to fully restore reserve ammo on all equipped weapons, \z
        health and shield, as well as triggering all skills \z
        related to picking up Health Kits and Armor Batteries. \z
        Health and shield gained this way can exceed max health and max shield, \z
        but with diminishing returns.",
        values = function(level, ent)
            --[[ min level above 0: 0.1, max level: 20
            level = level * (1 + ent:InsaneStats_GetEffectiveSkillValues("productivity", 3) / 100)]]
            return level, level * 2
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
            return math.max(25 - 5 * level, 10)
        end,
        img = "thor-fist",
        pos = {4, 0},
        minpts = 2,
        max = 1
    },
    seasoning = {
        name = "Seasoning",
        desc = "Whenever damage would be dealt, increase coins and XP yielded by the victim for 10 seconds. \z
        This effect can stack, but the number of stacks applied \z
        is proportional to +%u%% of BASE damage dealt \z
        and limited to +%u times the number of skill points gained in total \z
        (maximum %s stacks per hit at current total skill points).",
        values = function(level, ent)
            local skillPoints = ent:InsaneStats_GetTotalSkillPoints()
            local maxStacks = level * skillPoints
            return level * 10, level, CLIENT and InsaneStats:FormatNumber(maxStacks, {plus = true}) or maxStacks
        end,
        img = "salt-shaker",
        pos = {6, 2},
        minpts = 5
    },
    feel_the_energy = {
        name = "Feel The Energy",
        desc = "Having more shield increases coins and XP gained. \z
        At 100%% shield, coins and XP gain is increased by +%u%%.",
        values = function(level)
            return level * 20
        end,
        img = "triple-yin",
        pos = {5, 3},
        minpts = 5
    },
    --[[triple_kill = {
        name = "Triple Kill",
        desc = "Every third kill yields +%u%% coins and XP.",
        values = function(level)
            return level * 15
        end,
        stackTick = function(state, current, time, ent)
            return current >= 2 and 1 or 0, current
        end,
        img = "triple-yin",
        pos = {5, 3},
        minpts = 5
    },]]
    mantreads = {
        name = "Mantreads",
        desc = "Negate all fall damage! All fall damage that would be received \z
        is instead doubled +%u time(s), \z
        then dealt to all other entities within %s and causing them to unburrow. \z
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
    beyond_240_kmph = {
        name = "Beyond 240 km/h",
        desc = "Speed-based skills and modifiers now use effective speed, \z
        which is calculated as being +%u%% higher than actual speed! \z
        For all skills and modifiers that do not dilate time, \z
        an additional +%u%% of normal running speed is always added to effective speed!",
        values = function(level, ent)
            --level = level * ent:InsaneStats_GetEffectiveSkillValues("grandmaster_of_water", 2)
            return level * 10, level * 10
        end,
        img = "afterburn",
        pos = {3, 5},
        minpts = 5
    },
    pyrotheum = {
        name = "Stellar Nodes",
        desc = "Killed enemies create a %s radius stellar node that lasts for +%u second(s). \z
        There can only be at most +%u nodes at once, but \z
        kills that happen inside a node will extend the duration of the node. \z
        Nodes deal fire damage to ALL entities \z
        within range while %s is not held, \z
        with damage scaled based on node duration.",
        values = function(level, ent)
            local distance = 64
            local slowWalkKey = "the Slow Walk key"
            if CLIENT then
                distance = InsaneStats:FormatNumber(distance, {plus = true, distance = true})
                local keyName = input.LookupBinding("+walk")
                if keyName then
                    slowWalkKey = keyName:upper()
                end
            end
            return distance, level * 2, level * 5, slowWalkKey
        end,
        stackTick = function(state, current, time, ent)
            return (
                ent:IsPlayer() and ent:KeyDown(IN_WALK)
                or ent:InsaneStats_HasStatusEffect("no_spreading_damage")
            ) and -1 or current > 0 and 1 or 0, current
        end,
        img = "barbed-sun",

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
            if level > 2 then
                return string.format(" +%u times", level), sprintKey
            elseif level == 2 then
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
        desc = "Gain more damage dealt and ammo consumption \z
        based on the square root of the percentage of ammo left in the current weapon's clip. \z
        At 100%% ammo, damage dealt and ammo consumption are increased by +%u%%!",-- \z
        --The Keep It Ready skill is also more effective based on the percentage of ammo \z
        --left in the current weapon's clip, raised to the power of %.5f times the number of skill points \z
        --gained in total (^%s at current total skill points, %s%% effectiveness at current ammo percentage).",
        values = function(level, ent)
            --[[local skillPoints = ent:InsaneStats_GetTotalSkillPoints()
            local basePower = level * 0.00002
            local power = skillPoints * basePower
            local effectiveBonus = 0

            local wep = ent.GetActiveWeapon and ent:GetActiveWeapon()
            if (IsValid(wep) and wep.Clip1) then
                local clip1 = wep:Clip1()
                local maxClip1 = wep:GetMaxClip1()
                local clip1Fraction = (math.max(clip1, 0) / maxClip1) ^ power
                if maxClip1 <= 0 then
                    clip1Fraction = 1
                end
                effectiveBonus = clip1Fraction * 100
            end]]

            return level * 10
            --return level * 10, basePower, CLIENT and InsaneStats:FormatNumber(power) or power,
            --CLIENT and InsaneStats:FormatNumber(effectiveBonus, {plus = true}) or effectiveBonus, effectiveBonus
        end,
        img = "thunder-skull",
        pos = {-2, 6},
        minpts = 5
    },
    the_fourth_dimension = {
        name = "The Fourth Dimension",
        desc = "Weapons are instantly reloaded %u second(s) after they are fired, \z
        regardless of whether they are the active weapon or not! \z
        Additionally, the number of stacks set on kill for the Keep It Fresh skill is increased by +%u%%.",
        values = function(level)
            return math.max(6 - level, 0), level * 20
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
        desc = "Receiving damage restores +%u%% of max health and max shield. \z
        Health and shield gained this way can exceed max health and max shield, \z
        but with diminishing returns. 60 seconds cooldown. \z
        The Hellish Challenge skill is also +%u%% more effective.",
        values = function(level)
            return level * 10, level * 20
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
            local distance = 32
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
        desc = "Negate all fire%s and physical damage taken! \z
        Additionally, negate ALL damage taken while in a vehicle!",
        values = function(level)
            if level > 2 then
                return ", poison, shock, freeze, melee, sonic, laser, auric, explosive"
            elseif level > 1 then
                return ", poison, shock, freeze"
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
        desc = "Take %i%% explosion damage and reduce attenuation of explosions by %i%%! \z
        Also, holding %s allows picking up props that are up to %s%% heavier \z
        than what could be picked up by hand.",
        values = function(level)
            local slowWalkKey = "the Slow Walk key"
            if CLIENT then
                local keyName = input.LookupBinding("+walk")
                if keyName then
                    slowWalkKey = keyName:upper()
                end
            end
            return math.max(level * -10, -100), level * -5, slowWalkKey,
            CLIENT and InsaneStats:FormatNumber(level * 200, {plus = true}) or level * 200
        end,
        stackTick = function(state, current, time, ent)
            return ent:InsaneStats_HasStatusEffect("no_movement_modifications") and -1
            or ent:IsPlayer() and ent:KeyDown(IN_WALK) and 1 or 0, current
        end,
        img = "robot-golem",
        pos = {-4, -4},
        minpts = 5
    },
    scattershot = {
        name = "Scattershot",
        desc = "Gain %+.1f stack(s) of Scattershot per second, up to %s stacks. \z
        While holding a shotgun, deal an additional %s BASE damage \z
        to each enemy visible from the victim, consuming 1 stack for each enemy.",
        values = function(level, ent)
            --local slowWalkKey = "the Slow Walk key"
            local maxStacks = level * 100
            local value = 4 * InsaneStats:DetermineDamageMulPure(
                ent, game.GetWorld()
            )
            if CLIENT then
                --[[local keyName = input.LookupBinding("+walk")
                if keyName then
                    slowWalkKey = keyName:upper()
                end]]

                maxStacks = InsaneStats:FormatNumber(maxStacks, {plus = true})
                value = InsaneStats:FormatNumber(value)
            end
            return level, maxStacks, value, level * 100
        end,
        stackTick = function(state, current, time, ent)
            local values = {ent:InsaneStats_GetEffectiveSkillValues("scattershot")}
            local newStacks = math.min(current + time * values[1], values[4])
            return ent:InsaneStats_HasStatusEffect("no_spreading_damage") and -1
            or newStacks >= 1 and 1 or 0, newStacks
        end,
        img = "divert",
        pos = {-3, -5},
        minpts = 5
    },
    rain_from_above = {
        name = "Rain From Above",
        desc = "+%u%% damage dealt for every %s above ground",
        values = function(level)
            local distance = 32
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
        minpts = 5
    },
    heads_will_roll = {
        name = "Heads Will Roll",
        desc = "Deal %s%% more damage against enemies at +%u%% health or below. \z
        On gaining control of any func_tank entity with a fire rate of less than +%u per second, \z
        permamently increase its fire rate to that amount.",
        values = function(level, ent)
            local initialValue = level * 10000
            return CLIENT and InsaneStats:FormatNumber(initialValue, {plus = true}) or initialValue, level * 4, level
        end,
        img = "guillotine",
        pos = {3, -6},
        minpts = 5
    },
    kill_aura = {
        name = "Kill Aura",
        desc = "On kill, gain +%u stack(s) of Kill Aura. Enemies within %s times the number of stacks \z
        take %s BASE damage per second while %s is not held, \z
        but stacks decay at a rate of %.1f/s plus an additional -1%%/s.",
        values = function(level, ent)
            local slowWalkKey = "the Slow Walk key"
            local damage = level
            local distance = 4

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

            return level, distance, damage, slowWalkKey, level / -10
        end,
        stackTick = function(state, current, time, ent)
            local constantDecayRate = ent:InsaneStats_GetEffectiveSkillValues("kill_aura", 5)
            local f1, f2 = -100, .99
            local offset = constantDecayRate * f1
            local nextStacks = (current + offset) * f2 ^ time - offset
            nextStacks = math.max(nextStacks, 0)
            --local nextStacks = current * .99 ^ time

            return (
                ent:IsPlayer() and ent:KeyDown(IN_WALK)
                or ent:InsaneStats_HasStatusEffect("no_spreading_damage")
            ) and -1
            or nextStacks <= 0 and 0
            or 1, nextStacks
        end,
        img = "death-zone",
        pos = {4, -5},
        minpts = 5
    },
    adamantite_forge = {
        name = "Adamantite Forge",
        desc = "Reduce the chance of getting curse modifiers when reforging by %i%%. \z
        Reforging also increases the tier by +%.1f, but only once per weapon / armor battery. \z
        If either Coin Drops or WPASS2 is disabled, coins and XP gain is increased by +%u%% instead.",
        values = function(level, ent)
            return math.max(level * -10, -100), level / 2, level * 5
        end,
        img = "anvil-impact",
        pos = {5, -4},
        minpts = 5
    },
    skystrike = {
        name = "Skystrike",
        desc = "+%u%% coins and XP gained for every %s above ground",
        values = function(level)
            local distance = 32
            if CLIENT then
                distance = InsaneStats:FormatNumber(distance, {distance = true})
            end
            return level * 10, distance
        end,
        img = "steelwing-emblem",
        pos = {6, -3},
        minpts = 5
    },
    --[[sick_combo = {
        name = "Sick Combo",
        desc = "On kill, gain +%.3f stack(s) of Sick Combo and extend its duration by %u seconds, up to 60 seconds. \z
        Picking up any item will also extend the duration by half the amount. \z
        Each stack gives 100%% more coins and XP, but stacks are limited to a maximum of 1, \z
        multiplied by 5 for every %u skill points gained in total (%s at current total skill points). \z
        Also, every power of %u Sick Combo stacks grants +100%% more kill skill retriggers on kill!",
        values = function(level, ent)
            local pointsPer5 = 400 - level * 20
            local stackLimit = 5 ^ (ent:InsaneStats_GetTotalSkillPoints() / pointsPer5)
            return level/1000, 2, pointsPer5, CLIENT and InsaneStats:FormatNumber(stackLimit) or stackLimit, 5
        end,
        img = "poker-hand",
        pos = {5, -1},
        minpts = 5
    },]]
    controlled_reaction = {
        name = "Controlled Reaction",
        desc = "+%u%% coins and XP gain for every conditionally active skill \z
        (shown in aqua / red on the skill status indicator). \z
        All skills tick %i%% slower, reducing stack decay but also increasing cooldown times. \z
        The Ain't Got Time For This skill is also +%u%% more effective.",
        values = function(level, ent)
            return level * 2, level * -5, level * 10
        end,
        img = "bubbling-flask",
        pos = {5, -1},
        minpts = 5
    },
    productivity = {
        name = "Productivity",
        desc = "+%u%% chance to duplicate items. Whenever a weapon would be picked up for ammo, \z
        instead gain ammo equal to the weapon's max clips +%u%%. \z
        On kill, add +%u%% ammo into the current weapon's clips.",
        values = function(level)
            return level * 10, level * 10, level * 5
        end,
        img = "dig-dug",
        pos = {5, 1},
        minpts = 5
    },
    um_what = {
        name = "Um, What?",
        desc = "%+i%% coins and XP gained",
        values = function(level)
            --level = 10
            local u = math.sqrt(level) * 3
            local value = level * 5
            local points = {
                Vector(0, 0, 0),
                Vector(-u, 0, 0),
                Vector(u, 0, -u),
                Vector(-u, -u, u),
                Vector(0, 0, -u),
                Vector(u, u, u),
                Vector(-u, -u, -u),
                Vector(0, 0, u),
                Vector(u, u, -u),
                Vector(-u, 0, u),
                Vector(u, 0, 0),
                Vector(0, 0, 0)
            }
            local splinePoint = math.BSplinePoint(CurTime() / math.tau % 1, points, 1)
            value = value + splinePoint.x * splinePoint.y * splinePoint.z
            return value
        end,
        no_cache_values = true,
        img = "spotted-mushroom",
        pos = {6, 3},
        minpts = 5
    },
    --[[the_bigger_they_are = {
        name = "The Bigger They Are",
        desc = "Killing a large mob creates an Item Crate that gives +%u random items when broken. \z
        Coins and XP gained from such kills are also multiplied by the victim's amount of XP \z
        raised to the power of %.5f times the number of skill points gained in total \z
        (^%.4f at current total skill points).",
        values = function(level, ent)
            local exponent = level / 100000
            return level, exponent, exponent * ent:InsaneStats_GetTotalSkillPoints()
        end,
        img = "orb-direction",
        pos = {5, 4},
        minpts = 5
    },]]
    the_bigger_they_are = {
        name = "The Bigger They Are",
        desc = "Killing a large mob creates an Item Crate that gives +%u random items when broken. \z
        Coins and XP gained from such kills are also increased by +%s%%.",
        values = function(level, ent)
            return level, CLIENT and InsaneStats:FormatNumber(level * 500) or level * 500
        end,
        img = "orb-direction",
        pos = {5, 4},
        minpts = 5
    },
    hellish_challenge = {
        name = "Hellish Challenge",
        desc = "Gain +%s%% attack damage, coins and XP. \z
        Whenever damage is taken from a mob, gain +%s stack(s) of Hellish Challenge. \z
        Each stack decreases health and shield gained from skills and modifiers by 1%%. \z
        Stacks decay at a rate of %s per second, and stacks are clamped to between 0 and 100.",
        values = function(level, ent)
            level = level * (1 + ent:InsaneStats_GetEffectiveSkillValues("love_and_tolerate", 2) / 100)
            * (1 + ent:InsaneStats_GetEffectiveSkillValues("instant_karma", 4) / 100)
            * (1 + ent:InsaneStats_GetEffectiveSkillValues("anger", 3) / 100)
            * (1 + ent:InsaneStats_GetEffectiveSkillValues("medic_bag", 2) / 100)
            * (1 + ent:InsaneStats_GetEffectiveSkillValues("self_validation", 2) / 100)
            return CLIENT and InsaneStats:FormatNumber(level * 10) or level * 10,
            CLIENT and InsaneStats:FormatNumber(level) or level,
            CLIENT and InsaneStats:FormatNumber(-level/5) or -level/5
        end,
        stackTick = function(state, current, time, ent)
            local newStacks = math.Clamp(
                current + time * ent:InsaneStats_GetEffectiveSkillValues("hellish_challenge", 3),
                0, 100
            )
            return newStacks > 0 and 2 or 0, newStacks
        end,
        img = "daemon-skull",
        pos = {4, 5},
        minpts = 5
    },
    degeneration = {
        name = "Degeneration",
        desc = "Lose %.1f%% of current health per second, in exchange for +%u%% damage dealt, coins and XP gain.",
        values = function(level, ent)
            return level / -5, level * 10
        end,
        img = "ouroboros",
        pos = {3, 6},
        minpts = 5
    },
    bloodletters_revelation = {
        name = "Bloodletter's Revelation",
        desc = "Gain up to +%u%% movement speed at high health. \z
        The Bloodletter's Pact skill is also +%u%% more effective.",
        values = function(level)
            return level * 6, level * 20
        end,
        img = "dripping-goo",
        pos = {1, 5},
        minpts = 5
    },
    --[[hacked_shield = {
        name = "Hacked Shield",
        desc = "Increase shield gains by shield %% raised to the power of %.5f times the number of skill points \z
        gained in total (^%s at current total skill points, %s%% shield gains at current shield percentage). \z
        However, getting hit PERMANENTLY reduces maximum shield by %.2f%%! \z
        This skill cannot reduce max shield below %s. \z
        Also, gain +%u%% dodge chance against non-disintegrating damage, \z
        but this chance is divided by shield %% when shield is above 100%%.",
        values = function(level, ent)
            local scaleType = ent:IsPlayer() and "player" or "other"
            local baseMult = ent:IsPlayer() and 1 or InsaneStats:GetConVarValue("infhealth_armor_mul")
            local effectiveLevel = InsaneStats:GetConVarValue("xp_enabled") and ent:InsaneStats_GetLevel() or 1
            local skillPoints = ent:InsaneStats_GetTotalSkillPoints()
            local basePower = level * 0.00002
            local power = basePower * skillPoints
            local armorFraction = ent:InsaneStats_GetMaxArmor() > 0
            and ent:InsaneStats_GetArmor() / ent:InsaneStats_GetMaxArmor()
            or 1
            local shieldGainsBoost = armorFraction ^ power * 100
            local val = InsaneStats:ScaleValueToLevel(
                baseMult,
                InsaneStats:GetConVarValue("xp_"..scaleType.."_armor")/100,
                effectiveLevel,
                "xp_"..scaleType.."_armor_mode"
            )

            return basePower,
            CLIENT and InsaneStats:FormatNumber(power) or power,
            CLIENT and InsaneStats:FormatNumber(shieldGainsBoost, {plus = true}) or shieldGainsBoost,
            level/-50, CLIENT and InsaneStats:FormatNumber(val) or val, level*5
        end,
        img = "circuitry",
        pos = {-1, 5},
        minpts = 5
    },]]
    hacked_shield = {
        name = "Hacked Shield",
        desc = "The softcap and hardcap effects of overshielding are reduced by %.2f%% \z
        times the square root of the number of skill points gained in total \z
        (%.2f%% at current total skill points). \z
        However, Insane Stats Coin Shops will no longer sell health nor shield for coins! \z
        Also, gain +%u%% dodge chance against non-disintegrating damage, \z
        but this chance is divided by shield %% when shield is above 100%%.",
        values = function(level, ent)
            local baseEffect = level * -0.16
            local skillPoints = ent:InsaneStats_GetTotalSkillPoints()
            local effect = math.max(baseEffect * math.sqrt(skillPoints), -100)

            --[[local baseMult = ent:IsPlayer() and 1 or InsaneStats:GetConVarValue("infhealth_armor_mul")
            local scaleType = ent:IsPlayer() and "player" or "other"
            local effectiveLevel = InsaneStats:GetConVarValue("xp_enabled") and ent:InsaneStats_GetLevel() or 1
            local val = InsaneStats:ScaleValueToLevel(
                baseMult,
                InsaneStats:GetConVarValue("xp_"..scaleType.."_armor")/100,
                effectiveLevel,
                "xp_"..scaleType.."_armor_mode"
            )]]

            return baseEffect, effect, --level/-50, CLIENT and InsaneStats:FormatNumber(val) or val,
            level*5
        end,
        img = "circuitry",
        pos = {-1, 5},
        minpts = 5
    },
    infestation = {
        name = "Soulcrusher",
        desc = "On hit, inflict a random negative status effect, \z
        such as %i%% damage dealt, +%u%% damage taken, etc. \z
        Upon getting hit, gain a random negative status effect.",
        values = function(level, ent)
            return level * -5, level * 5, level
        end,
        img = "wolf-trap",
        pos = {-3, 6},
        minpts = 5
    },
    aint_got_time_for_this = game.SinglePlayer() and {
        name = "Ain't Got Time For This",
        desc = "While %s is held, gain +%.1f stack(s) of Ain't Got Time For This per second. \z
        Each stack increases attack damage, defence and game speed by 1%%, but all stacks are lost when %s is released.\n\z
        (This skill is completely different in multiplayer.)",
        values = function(level, ent)
            level = level * (1 + ent:InsaneStats_GetEffectiveSkillValues("controlled_reaction", 3) / 100)

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
                add = add * (1 + ent:InsaneStats_GetEffectiveSkillValues("just_breathe", 5) / 100)
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
    shoe_spikes = {
        name = "Shoe Spikes",
        desc = "Take %i%% damage but also increase player friction by +%u%%, \z
        reducing movement speed on the ground.",
        values = function(level, ent)
            return level * -8, level * 10
        end,
        img = "boot-stomp",
        pos = {-6, 3},
        minpts = 5
    },
    bastion_of_flesh = {
        name = "Bastion of Flesh",
        desc = "+%u%% of max shield gained from skills and modifiers is converted into max health instead. \z
        On kill, %+.2f%% of max shield is converted into max health. \z
        Max shield converted by this skill restores health by %u times the amount converted! \z
        Health gained this way can exceed max health, but with diminishing returns! \z
        This skill cannot reduce max shield below %s.",
        values = function(level, ent)
            local scaleType = ent:IsPlayer() and "player" or "other"
            local baseMult = ent:IsPlayer() and 1 or InsaneStats:GetConVarValue("infhealth_armor_mul")
            local effectiveLevel = InsaneStats:GetConVarValue("xp_enabled") and ent:InsaneStats_GetLevel() or 1
            local val = InsaneStats:ScaleValueToLevel(
                baseMult * 10,
                InsaneStats:GetConVarValue("xp_"..scaleType.."_armor")/100,
                effectiveLevel,
                "xp_"..scaleType.."_armor_mode"
            )

            return math.min(level*10, 100), level/50, 20, CLIENT and InsaneStats:FormatNumber(val), val
        end,
        img = "back-forth",
        pos = {-5, 1},
        minpts = 5
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
        minpts = 5
    },
    beep3 = {
        name = "Beep Beep Beeeeeeeeep",
        desc = "Gain +%u stack(s) of Beep Beep Beeeeeeeeep per second, up to 10. \z
        At 10 stacks while %s is not held, the next damage dealt to a mob \z
        stuns it for 2 seconds, consuming all stacks. \z
        Note that after the stun expires, the affected mob becomes immune to all stunning effects \z
        for 2 seconds.",
        values = function(level)
            local slowWalkKey = "the Slow Walk key"
            if CLIENT then
                local keyName = input.LookupBinding("+walk")
                if keyName then
                    slowWalkKey = keyName:upper()
                end
            end
            return level, slowWalkKey
        end,
        stackTick = function(state, current, time, ent)
            local generation = ent:InsaneStats_GetEffectiveSkillValues("beep3")
            local nextStacks = math.min(current + time * generation, 10)

            return ent:IsPlayer() and ent:KeyDown(IN_WALK) and -1
            or nextStacks >= 10 and 1
            or 0, nextStacks
        end,
        img = "coma",
        pos = {-6, -3},
        minpts = 5
    },
    better_healthcare = {
        name = "Better Healthcare",
        desc = "%+.0f%% health, max health, shield and max shield gains from skills and modifiers. \z
        Coins and XP gain is also increased by %s%%, \z
        but this percentage is divided by the number of skill points gained in total \z
        (%s%% at current total skill points).",
        values = function(level, ent)
            local xpBoost = 1000 * level
            local xpBoostEff = xpBoost / math.max(ent:InsaneStats_GetTotalSkillPoints(), 1)
            return level * 5, CLIENT and InsaneStats:FormatNumber(xpBoost, {decimals = 1, plus = true}) or xpBoost,
            CLIENT and InsaneStats:FormatNumber(xpBoostEff, {decimals = 1, plus = true}) or xpBoostEff
        end,
        img = "crowned-heart",
        pos = {-5, -4},
        minpts = 5
    },
    stabilization = {
        name = "Stabilization",
        desc = "Bullets have %+i%% spread. On kill, all recoil from firing weapons is negated for +%u seconds.",
        values = function(level)
            return math.max(level * -10, -100), level * 2
        end,
        stackTick = function(state, current, time, ent)
            local nextStacks = math.max(current - time, 0)
            return nextStacks <= 0 and 0 or 1, nextStacks
        end,
        img = "on-target",
        pos = {-4, -5},
        minpts = 5
    },
    doom = {
        name = "Jaws",
        desc = "+%u%% doom damage dealt after 1s",
        values = function(level, ent)
            return level * 5
        end,
        img = "shark-jaws",
        pos = {-3, -6},
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
            return CLIENT and InsaneStats:FormatNumber(value), math.min(level*0.5 - 3.5, 0)
        end,
        img = "shield-bounces",
        pos = {-1, -5},
        minpts = 5
    },

    -- distance 10
    explosive_arsenal = {
        name = "Explosive Arsenal",
        desc = "While holding a grenade, %s toggles between fused grenades and on-contact grenades. \z
        On-contact grenades explode immediately upon collision, but have +%u%% more radius and BASE damage. \z
        While holding an RPG, %s instantly fires a rocket \z
        while %s toggles rocket invincibility for insta-rockets. \z
        Insta-rockets have a cooldown of %.1f seconds between shots, \z
        with invincible rockets requiring double the amount of time.",
        values = function(level)
            local secondKey = "the Secondary Fire key"
            local reloadKey = "the Reload key"
            if CLIENT then
                local keyName = input.LookupBinding("+reload")
                if keyName then
                    reloadKey = keyName:upper()
                end
                keyName = input.LookupBinding("+attack2")
                if keyName then
                    secondKey = keyName:upper()
                end
            end
            return reloadKey, level * 10, secondKey, reloadKey, 5 - level / 2.5
        end,
        img = "sparky-bomb",
        pos = {4, -6},
        minpts = 5
    },
    bugbait_mastery = {
        name = "Bugbait Mastery",
        desc = "Thrown bugbaits cause all entities within %s from the impact to yield +%u%% more coins and XP, \z
        take +%u%% more damage and deal %i%% less damage for 10 seconds. Pressing %s while holding bugbait \z
        will cause all antlions that are over %s away to be teleported closer. \z
        Gain +%u%% coins and XP while not having bugbait.",
        values = function(level)
            local distance = 64
            local distance2 = 1024 / level
            local reloadKey = "the Reload key"
            if CLIENT then
                distance = InsaneStats:FormatNumber(distance, {distance = true})
                distance2 = InsaneStats:FormatNumber(distance2, {distance = true})
                local keyName = input.LookupBinding("+reload")
                if keyName then
                    reloadKey = keyName:upper()
                end
            end
            return distance, level * 100, level * 100, level * -8, reloadKey, distance2, level * 6
        end,
        img = "infested-mass",
        pos = {5, -5},
        minpts = 5
    },
    lets_do_that_again = {
        name = "Let's Do That Again!",
        desc = "On NPC kill, there is a +%u%% chance to resurrect it 5 seconds after death \z
        if the space they died in remains empty. Large NPCs are resurrected \z
        after 9 seconds instead of 5. Resurrected NPCs cannot resurrect again.",
        values = function(level, ent)
            return level * 8
        end,
        img = "recycle",
        pos = {6, -4},
        minpts = 5,
    },
    bookworm = {
        name = "Bookworm",
        desc = "%i%% movement speed\n+%u%% coins and XP gain",
        values = function(level, ent)
            return level * -5, level * 15
        end,
        img = "book-cover",
        pos = {6, 4},
        minpts = 5,
    },
    keep_it_ready = {
        name = "Keep It Ready",
        desc = "Gain more coins and XP \z
        based on the square root of the percentage of ammo left in the current weapon's clip. \z
        At 100%% ammo, coins and XP gain is increased by %s%%!",
        values = function(level, ent)
            --[[if ent:InsaneStats_EffectivelyHasSkill("dangerous_preparation") then
                level = level * (1 + ent:InsaneStats_GetEffectiveSkillValues("dangerous_preparation", 5) / 100)
            end]]
            return CLIENT and InsaneStats:FormatNumber(level * 10, {plus = true}) or level * 10
        end,
        img = "knapsack",
        pos = {5, 5},
        minpts = 5
    },
    responsive_movement = {
        name = "Responsive Movement",
        desc = "Increase player friction by +%u%%, with movement speed increased by +%u%% to compensate. \z
        Also, weapon switch speed is increased by +%u%%.",
        values = function(level, ent)
            return level * 10, level * 10, level * 50
        end,
        img = "gamepad-cross",
        pos = {4, 6},
        minpts = 5,
    },
    so_heres_the_problem = {
        name = "So Here's The Problem: You're A Gamer",
        desc = "+%u%% damage dealt, coins and XP gain, but \z
        take %s BASE poison damage per second while touching grass, \z
        and %i%% movement speed while in water. \z
        The Map Sense skill is also +%u%% more effective.",
        values = function(level, ent)
            local value = level * InsaneStats:DetermineDamageMulPure(
                ent, game.GetWorld()
            )
            return level * 10, CLIENT and InsaneStats:FormatNumber(value) or value,
            math.max(level * -8, -80), level * 20
        end,
        img = "land-mine",
        pos = {-4, 6},
        minpts = 5,
    },
    slow_recovery = {
        name = "Slow Recovery",
        desc = "All healing from modifiers and skills other than this instead give \z
        Slow Recovery stacks equal to BASE healing %% that would've been received, +%u%%. \z
        Every 0.5 seconds, consume %u%% of all stacks to heal 1%% health for each stack consumed this way.",
        stackTick = function(state, current, time, ent)
            return current <= 0 and 0 or 1, current
        end,
        values = function(level)
            return level * 5, 5
        end,
        img = "bandaged",
        pos = {-5, 5},
        minpts = 5,
    },
    more_and_more = {
        name = "More and More",
        desc = "Having a full bar of shield \z
        boosts all healing and shield gained from skills and modifiers by +%u%%. \z
        Every power of %u bars of shield after grants +%u%% more health and shield gain. \z
        Additionally, defence is increased by %s%%, \z
        but this percentage is divided by the number of skill points gained in total \z
        (%s%% at current total skill points).",
        values = function(level, ent)
            local defBoost = 1000 * level
            local defBoostEff = defBoost / math.max(ent:InsaneStats_GetTotalSkillPoints(), 1)
            return level * 5, 5, level * 5,
            CLIENT and InsaneStats:FormatNumber(defBoost, {decimals = 1, plus = true}) or defBoost,
            CLIENT and InsaneStats:FormatNumber(defBoostEff, {decimals = 1, plus = true}) or defBoostEff
        end,
        img = "mineral-heart",
        pos = {-6, 4},
        minpts = 5,
    },
    solar_power = {
        name = "Solar Power",
        desc = "+%u%%/s health regeneration while under sunlight or moonlight",
        values = function(level)
            return level
        end,
        img = "sun",
        pos = {-6, -4},
        minpts = 5,
    },
    make_like_a_tree = {
        name = "Make Like A Tree And...",
        desc = "+%u%% knockback dealt\n%i%% knockback taken",
        values = function(level)
            return level * 12, level * -8
        end,
        img = "oak",
        pos = {-5, -5},
        minpts = 5,
    },
    --[[ion_cannon = {
        name = "Ion Cannon",
        desc = "Damage that would hit a large enemy inflicts 1 stack of Ion Cannon Target for 6 seconds. \z
        The next +%u hits will double the number of stacks but do not extend the duration. \z
        After 6 seconds elapse, deal %s BASE damage per stack \z
        to the large enemy and all others shootable from it! %u seconds cooldown, \z
        unless the large enemy was killed before the cannon hits.",
        values = function(level, ent)
            local value = 40 * InsaneStats:DetermineDamageMulPure(
                ent, game.GetWorld()
            )
            return level * 2, CLIENT and InsaneStats:FormatNumber(value) or 40, 110 - level * 10
        end,
        stackTick = function(state, current, time, ent)
            local preCooldownTime = ent:InsaneStats_GetEffectiveSkillValues("ion_cannon", 3) - 6
            local nextStacks = math.max(current - time, 0)
            return nextStacks >= preCooldownTime and state > -1 and 1
            or nextStacks <= 0 and not ent:InsaneStats_HasStatusEffect("no_spreading_damage") and 0 or -1, nextStacks
        end,
        img = "laser-warning",
        pos = {-4, -6},
        minpts = 5,
    },]]
    kill_at_first_hit = {
        name = "Kill At First Hit",
        desc = "Extra crowbars and Gravity Guns can be picked up for 25 stacks of Kill At First Hit. \z
        Each stack gives 1%% more damage dealt against entities above 90%% health, but stacks decay at a rate of -1%%/s. \z
        On kill while having any melee weapon, there is a +%u%% chance gain 25 stacks of Kill At First Hit.",
        values = function(level, ent)
            return level
        end,
        stackTick = function(state, current, time, ent)
            local nextStacks = current * .99 ^ time
            return nextStacks > 0 and 1 or 0, nextStacks
        end,
        img = "eclipse",
        pos = {-4, -6},
        minpts = 5,
    },

    -- distance 11
    feel_the_mass = {
        name = "Feel The Mass",
        desc = "Increase damage dealt based on shield %%. \z
        At 100%% shield, damage dealt is increased by +%u%%.",
        values = function(level)
            return level * 20
        end,
        img = "metal-bar",
        pos = {1, -6},
        minpts = 5
    },
    campfire = {
        name = ":fire:",
        desc = "+%u%% damage dealt while within %s from the nearest fire. \z
        Dealing damage to an Item Crate directly sets its health to 1 before the attack connects. \z
        Also, helicopter bombs thrown NOT from the gravity gun gain %s per second velocity.",
        values = function(level)
            local dist1, dist2 = 512, level * 256
            if CLIENT then
                dist1 = InsaneStats:FormatNumber(dist1, {distance = true})
				dist2 = InsaneStats:FormatNumber(dist2, {distance = true, plus = true})
            end
            return level * 25, dist1, dist2
        end,
        img = "campfire",
        pos = {5, -6},
        minpts = 5
    },
    totem_of_wisdom = {
        name = "Doll of Knowledge",
        desc = "Drop a doll that gives ALL entities within %s +%u%% coins and XP gain. \z
        The doll lasts for 120 seconds. There can only be one skill-spawned doll per player.",
        values = function(level)
            local distance = 512
            if CLIENT then
                distance = InsaneStats:FormatNumber(distance, {distance = true})
            end
            return distance, level * 50
        end,
        img = "brain",
        pos = {6, -5},
        minpts = 5
    },
    flex = {
        name = "Flex",
        desc = "On kill while %s is not held, perform a random taunt! \z
        During the taunt, gain invincibility from non-dissolving damage. \z
        Also, gain +%u%% attack damage, \z
        coins and XP gain, which persist for +%u seconds after the taunt finishes. 120 seconds cooldown.",
        values = function(level)
            local slowWalkKey = "the Slow Walk key"
            if CLIENT then
                local keyName = input.LookupBinding("+walk")
                if keyName then
                    slowWalkKey = keyName:upper()
                end
            end
            return slowWalkKey, level * 25, level * 5
        end,
        stackTick = function(state, stacks, time, ent)
            if state == 1 then
                stacks = stacks - time
                if stacks < 0 then
                    state = -1
                    stacks = stacks + 120
                    time = 0
                end
            end
            if state <= 0 then
                if stacks > 0 then
                    stacks = math.max(stacks - time, 0)
                    state = -1
                elseif (ent:IsPlayer() and not ent:KeyDown(IN_WALK) and not ent:InVehicle()) then
                    state = 0
                else
                    state = -1
                end
            end

            return state, stacks
        end,
        img = "minotaur",
        pos = {6, -1},
        minpts = 5
    },
    obligatory_thanks = {
        name = "Obligatory Skill for Thanking the Community",
        desc = "+%.2f%% coins and XP gain for each rating given to Insane Stats \z
        (+%.2f%% coins and XP gain at current total votes, minimum +%u%%)",
        values = function(level)
            if (InsaneStats.obligatory_thanks_cooldown or 0) < RealTime() then
                InsaneStats.obligatory_thanks_cooldown = RealTime() + 30

                steamworks.FileInfo(InsaneStats.WORKSHOP_ID, function(data)
                    if data.total then
                        InsaneStats.obligatory_thanks_votes = data.total
                        InsaneStats.obligatory_thanks_cooldown = RealTime() + 600
                    end
                end)
            end
            local votes = InsaneStats.obligatory_thanks_votes or 0

            return level / 20, level / 20 * votes, level * 5
        end,
        img = "fairy-wand",
        no_cache_values = true,
        pos = {6, 1},
        minpts = 5
    },
    crunch = {
        name = "CRUNCH",
        desc = "While holding a crossbow, pressing %s causes all but one bolt to be consumed, \z
        turning into %s BASE coins and XP for each bolt! This skill is affected \z
        by effects that affect ammo consumption.",
        values = function(level, ent)
            local reloadKey = "the Reload key"
            if CLIENT then
                local keyName = input.LookupBinding("+reload")
                if keyName then
                    reloadKey = keyName:upper()
                end
            end

            local effectiveLevel = InsaneStats:GetConVarValue("xp_enabled") and ent:InsaneStats_GetLevel() or 1
            local xp = level * 10
            local displayXP = InsaneStats:ScaleValueToLevel(
                xp,
                InsaneStats:GetConVarValue("xp_drop_add")/100,
                effectiveLevel,
                "xp_drop_add_mode"
            )
            return reloadKey, CLIENT and InsaneStats:FormatNumber(displayXP, {plus = true}) or xp
        end,
        img = "marrow-drain",
        pos = {6, 5},
        minpts = 5
    },
    electric_crowbar = {
        name = "Electric Crowbar",
        desc = "+%u%% damage dealt against enemies touching water or bleeding\n\z
        +%u%% damage taken while touching water or bleeding",
        values = function(level)
            return level * 75, level * 25
        end,
        img = "lightning-shadow",
        pos = {5, 6},
        minpts = 5
    },
    honorbound = {
        name = "Honorbound",
        desc = "Gain +%u%% health on kill, but reduce current health by %i%% when switching away from a weapon \z
        that didn't kill anything after it was deployed. Health gained this way can exceed max health, \z
        but with diminishing returns.",
        values = function(level)
            return level * 2, level * -4
        end,
        stackTick = function(state, current, time, ent)
            return state ~= 0 and 2 or 0, current
        end,
        img = "prayer",
        pos = {1, 6},
        minpts = 5
    },
    step_it_up = {
        name = "Step It Up",
        desc = "+%u%% knockback dealt. Also, increase step height by +%u%% while not underwater.",
        values = function(level)
            return level * 20, level * 15
        end,
        stackTick = function(state, current, time, ent)
            return ent:WaterLevel() > 1 and 0 or 1, current
        end,
        img = "boxing-glove-surprise",
        pos = {-1, 6},
        minpts = 5
    },
    totem_of_vigor = {
        name = "Doll of Vigor",
        desc = "Drop a doll that gives ALL entities within %s +%u%% attack damage. \z
        The doll lasts for 120 seconds. There can only be one skill-spawned doll per player.",
        values = function(level)
            local distance = 512
            if CLIENT then
                distance = InsaneStats:FormatNumber(distance, {distance = true})
            end
            return distance, level * 50
        end,
        img = "candle-light",
        pos = {-5, 6},
        minpts = 5
    },
    --[[countdown_to_destruction = {
        name = "Countdown To Destruction",
        desc = "All non-status effect damage taken instead apply and extend %u stacks of bleeding, \z
        with duration based on the amount of damage that would've been taken.",
        values = function(level)
            return 15 - level
        end,
        img = "echo-ripples",
        pos = {-6, -1},
        minpts = 5
    },]]
    bloodsapper = {
        name = "Bloodsapper",
        desc = "On hitting an enemy, apply +%.1f stack(s) of Bloodsapped for 10 seconds. \z
        Every stack applied increases self-regeneration by +1%%/s! \z
        Non-enemies are immune to this effect.",
        values = function(level)
            return level / 10
        end,
        img = "leeching-worm",
        pos = {-6, 5},
        minpts = 5
    },
    helm_too_big = {
        name = "Helm Too Big",
        desc = "%i%% damage taken\n\z
        +%u%% bullet spread\n\z
        %i%% non-bullet damage dealt",
        values = function(level)
            return level * -8, level * 10, level * -8
        end,
        img = "heavy-helm",
        pos = {-6, 1},
        minpts = 5
    },
    self_validation = {
        name = "Self-Validation",
        desc = "Restore +%u%% of max health whenever damage is taken. \z
        Health gained this way can exceed max health, but with diminishing returns. \z
        The Hellish Challenge skill is also +%u%% more effective.",
        values = function(level)
            return level, level * 20
        end,
        img = "self-love",
        pos = {-6, -1},
        minpts = 5
    },
    totem_of_courage = {
        name = "Doll of Courage",
        desc = "Drop a doll that gives ALL entities within %s +%u%% defence. \z
        The doll lasts for 120 seconds. There can only be one skill-spawned doll per player.",
        values = function(level)
            local distance = 512
            if CLIENT then
                distance = InsaneStats:FormatNumber(distance, {distance = true})
            end
            return distance, level * 50
        end,
        img = "three-leaves",
        pos = {-6, -5},
        minpts = 5
    },
    critical_crit = {
        name = "Critical Crit",
        desc = "Critical hits have a +%.1f%% chance to deal %s%% damage!",
        values = function(level)
            return level / 10, CLIENT and InsaneStats:FormatNumber(level * 10000, {plus = true}) or level * 10000
        end,
        img = "reticule",
        pos = {-5, -6},
        minpts = 5
    },
    surprise_attack = {
        name = "Surprise Attack",
        desc = "Gain +%u stacks of Surprise Attack per second, up to 10. \z
        At 10 stacks, consume all stacks to increase BASE damage dealt by %s.",
        values = function(level, ent)
            local value = 40 * InsaneStats:DetermineDamageMulPure(
                ent, game.GetWorld()
            )
            return level * 2, CLIENT and InsaneStats:FormatNumber(value)
        end,
        stackTick = function(state, current, time, ent)
            local nextStacks = math.min(current + time * ent:InsaneStats_GetEffectiveSkillValues("surprise_attack"), 10)
            return nextStacks >= 10 and 1 or 0, nextStacks
        end,
        img = "shining-sword",
        pos = {-1, -6},
        minpts = 5
    },

    -- distance X
    master_of_fire = {
        name = "Master of Fire",
        desc = "Double all fire damage dealt and halve all fire damage taken! \z
        All attacks have +%u%% chance to deal fire damage against mobs, and deal +%u%% damage against non-mobs! \z
        Also, %s the number of times kill skills are triggered on kill!",
        values = function(level, ent)
            return level * 25, level * 25, level < 2 and "double" or level < 3 and "triple"
            or string.format("add +%u to", level)
        end,
        img = "ifrit",
        pos = {0, -6},
        minpts = 5,
        max = 1
    },
    grandmaster_of_fire = {
        name = "Grandmaster of Fire",
        desc = "This is a Grandmaster skill. \z
        All kill skills have a 0.5%% chance to retrigger an extra time for each Grandmaster skill, \z
        with the retrigger chance multiplied by the level of each respective skill.",
        --Also, the Synergy (Hot) and Synergy (Dry) skills are more effective by \z
        --+%.3f%% times the number of skill points gained in total (+%.3f%% at current total skill points).",
        values = function(level, ent)
            --local skillPoints = ent:InsaneStats_GetTotalSkillPoints()
            --return level / 1000, level * skillPoints / 1000
        end,
        img = "small-fire-circled",
        pos = {0, -5},
        minpts = 777,
        max = 99
    },
    synergy_1 = {
        name = "Synergy (Hot)",
        desc = "On kill or whenever an item is picked up, gain 0.1 stacks of Synergy. \z
        Each stack increases damage dealt, coins and XP gained by +%s%%, \z
        but stacks decay at a rate of -10%%/s regardless of skills. \z
        Also, reduce the unlock requirement of all Grandmaster skills by %i point(s).",
        values = function(level, ent)
            --[[level = level
            * (1 + ent:InsaneStats_GetEffectiveSkillValues("grandmaster_of_fire", 2) / 100)
            * (1 + ent:InsaneStats_GetEffectiveSkillValues("grandmaster_of_air", 2) / 100)]]

            return CLIENT and InsaneStats:FormatNumber(level) or level, -level
        end,
        stackTick = function(state, current, time, ent)
            local nextStacks = current * .9 ^ time
            return nextStacks <= 0 and 0 or 1, nextStacks
        end,
        img = "jigsaw-box",
        pos = {6, -6},
        minpts = 10,
        max = 99
    },
    master_of_air = {
        name = "Master of Air",
        desc = "Double all shock damage dealt and halve all shock damage taken! \z
        All attacks have a +%u%% chance to deal shock damage against mobs, and deal +%u%% damage against non-mobs! \z
        Also, %sthe first kill after pressing any horizontal movement key after spawning retriggers all kill skills once \z
        for every %u skill point%s gained in total!",
        values = function(level, ent)
            local noShuffleText = level > 1 and "skills cannot be shuffled by any means, and " or ""
            return level * 25, level * 25, noShuffleText, math.max(30 - level * 10, 1), level < 3 and "s" or ""
        end,
        img = "winged-emblem",
        pos = {6, 0},
        minpts = 5,
        max = 1
    },
    grandmaster_of_air = {
        name = "Grandmaster of Air",
        desc = "This is a Grandmaster skill. \z
        On mob kill, gain Grandmaster of Air stacks equal to 0.001%% of the current number \z
        of stacks plus 0.1, unless the next kill would trigger the Master of Air's kill skill retrigger effect. \z
        Each stack increases coins and XP gained from enemies by +1%%, \z
        but each stack also increases enemy effective defense by +1%%. \z
        Stacks decay at a rate of -0.1/s plus an additional -50%%/s, \z
        and are clamped to between 0 and the square root of either the current amount of XP or coins, \z
        whichever is higher. \z
        Moreover, 90%% of all stacks are lost upon hitting an alive enemy afflicted with Air Jolted, \z
        and all stacks are lost on death. The Air Jolted status effect is inflicted on enemy hit if not already applied. \z
        Also, this skill's on kill effect is retriggered once for each level across all Grandmaster skills. \z
        Additionally, when the total level of all Grandmaster skills exceeds 777, \z
        add one to the max level of all skills if the skill allocation would remain valid afterward.",
        --Also, the Synergy (Hot) and Synergy (Wet) skills are more effective by \z
        --+%.3f%% times the number of skill points gained in total (+%.3f%% at current total skill points).",
        values = function(level, ent)
            --local skillPoints = ent:InsaneStats_GetTotalSkillPoints()
            --return level / 1000, level * skillPoints / 1000
        end,
        stackTick = function(state, current, time, ent)
            local constantDecayRate = -0.1
            local expDecayRate = 0.5
            local offset = -constantDecayRate / expDecayRate
            local nextStacks = (current + offset) * expDecayRate ^ time - offset
            nextStacks = math.max(nextStacks, 0)

			local masterOfAirActive = ent:InsaneStats_GetSkillState("master_of_air") == 1
            return masterOfAirActive and -1 or nextStacks <= 0 and 0 or 1, nextStacks
        end,
        img = "gold-shell",
        pos = {5, 0},
        minpts = 777,
        max = 99
    },
    synergy_2 = {
        name = "Synergy (Wet)",
        desc = "Every %s travelled or whenever an item is picked up, gain 0.1 stacks of Synergy. \z
        Each stack increases health, max health, shield and max shield gained from skills and modifiers, \z
        as well as coins and XP gained by +%s%%, \z
        but stacks decay at a rate of -10%%/s regardless of skills. \z
        Distance travelled is computed by multiplying speed and time passed. \z
        Also, reduce the unlock requirement of all Grandmaster skills by %i point(s).",
        values = function(level, ent)
            --[[level = level
            * (1 + ent:InsaneStats_GetEffectiveSkillValues("grandmaster_of_air", 2) / 100)
            * (1 + ent:InsaneStats_GetEffectiveSkillValues("grandmaster_of_water", 2) / 100)]]

            local distance = 8192
            if CLIENT then
                distance = InsaneStats:FormatNumber(distance, {distance = true})
            end
            return distance, CLIENT and InsaneStats:FormatNumber(level) or level, -level
        end,
        stackTick = function(state, current, time, ent)
            local nextStacks = current * .9 ^ time
            local newState = nextStacks <= 0 and 0 or 1

            if ent:InsaneStats_EffectivelyHasSkill("synergy_1") then
                newState = -2
            end

            return newState, nextStacks
        end,
        img = "jigsaw-box",
        pos = {6, 6},
        minpts = 10,
        max = 99
    },
    master_of_water = {
        name = "Master of Water",
        desc = "Double all freeze damage dealt and halve all freeze damage taken! \z
        All attacks have a +%s%% chance to deal freeze damage against mobs, and deal +%s%% damage against non-mobs! \z
        Also, this skill gains stacks based on velocity, with normal running speed granting +%s stack(s) per second! \z
        When this skill reaches 100 stacks, 100 stacks are removed to trigger all kill skills!",
        values = function(level, ent)
            --level = level * ent:InsaneStats_GetEffectiveSkillValues("grandmaster_of_water", 2)
            local value1 = CLIENT and InsaneStats:FormatNumber(level * 25) or level * 25
            local value2 = CLIENT and InsaneStats:FormatNumber(level) or level
            return value1, value1, value2
        end,
        stackTick = function(state, current, time, ent)
            return 0, current
        end,
        img = "wave-crest",
        pos = {0, 6},
        minpts = 5,
        max = 1
    },
    grandmaster_of_water = {
        name = "Grandmaster of Water",
        desc = "This is a Grandmaster skill. \z
        On hit, gain stacks of Grandmaster of Water equal to \z
        1.01 raised to the total level of all Grandmaster skills (%s multiplier at current total level). \z
        At 1.00 M stacks, the next hit while %s is not held consumes 1.00 M stacks \z
        to halve the health of ALL visible entities!",
        --Also, the Synergy (Wet) and Synergy (Cold) skills are more effective by \z
        --+%.3f%% times the number of skill points gained in total (+%.3f%% at current total skill points).",
        values = function(level, ent)
            local totalLevel = ent:InsaneStats_GetEffectiveSkillTier("grandmaster_of_fire")
            + ent:InsaneStats_GetEffectiveSkillTier("grandmaster_of_air")
            + ent:InsaneStats_GetEffectiveSkillTier("grandmaster_of_water")
            + ent:InsaneStats_GetEffectiveSkillTier("grandmaster_of_earth")
            local rawValue = 1.01 ^ totalLevel
            local slowWalkKey = "the Slow Walk key"
            if CLIENT then
                local keyName = input.LookupBinding("+walk")
                if keyName then
                    slowWalkKey = keyName:upper()
                end
            end
            --local skillPoints = ent:InsaneStats_GetTotalSkillPoints()
            return CLIENT and InsaneStats:FormatNumber(rawValue) or rawValue, slowWalkKey
            --return level / 1000, level * skillPoints / 1000
        end,
        stackTick = function(state, current, time, ent)
            return ent:IsPlayer() and ent:KeyDown(IN_WALK) and -1 or 0, current
        end,
        img = "at-sea",
        pos = {0, 5},
        minpts = 777,
        max = 99
    },
    synergy_3 = {
        name = "Synergy (Cold)",
        desc = "Every %s travelled or whenever damage would be taken from a mob, gain 0.1 stacks of Synergy. \z
        Each stack increases health, max health, shield and max shield gained from skills and modifiers, \z
        as well as defence by +%s%%, \z
        but stacks decay at a rate of -10%%/s regardless of skills. \z
        Distance travelled is computed by multiplying speed and time passed. \z
        Also, reduce the unlock requirement of all Grandmaster skills by %i point(s).",
        values = function(level, ent)
            --[[level = level
            * (1 + ent:InsaneStats_GetEffectiveSkillValues("grandmaster_of_water", 2) / 100)
            * (1 + ent:InsaneStats_GetEffectiveSkillValues("grandmaster_of_earth", 3) / 100)]]

            local distance = 8192
            if CLIENT then
                distance = InsaneStats:FormatNumber(distance, {distance = true})
            end
            return distance, CLIENT and InsaneStats:FormatNumber(level) or level, -level
        end,
        stackTick = function(state, current, time, ent)
            local nextStacks = current * .9 ^ time
            local newState = nextStacks <= 0 and 0 or 1

            if ent:InsaneStats_EffectivelyHasSkill("synergy_1") or ent:InsaneStats_EffectivelyHasSkill("synergy_2") then
                newState = -2
            end

            return newState, nextStacks
        end,
        img = "jigsaw-box",
        pos = {-6, 6},
        minpts = 10,
        max = 99
    },
    master_of_earth = {
        name = "Master of Earth",
        desc = "Double all poison damage dealt and halve all poison damage taken! \z
        All attacks have a +%u%% chance to deal poison damage against mobs, and deal +%u%% damage against non-mobs! \z
        Also, breaking a prop has a +%u%% chance to trigger all kill skills, except for Item Crates \z
        which instead are guaranteed to trigger all kill skills%s!",
        values = function(level, ent)
            return level * 25, level * 25, level * 25,
            level < 2 and "" or level < 3 and " twice" or string.format(" +%u times", level)
        end,
        img = "stone-tablet",
        pos = {-6, 0},
        minpts = 5,
        max = 1
    },
    grandmaster_of_earth = {
        name = "Grandmaster of Earth",
        desc = "This is a Grandmaster skill. \z
        The softcap and hardcap effects of overshielding and overhealing are divided by 1.01 \z
        raised to the total level of all Grandmaster skills (%s divisor at current total level).",
        --Also, the Synergy (Cold) and Synergy (Dry) skills are more effective by \z
        --+%.3f%% times the number of skill points gained in total (+%.3f%% at current total skill points).",
        values = function(level, ent)
            local totalLevel = ent:InsaneStats_GetEffectiveSkillTier("grandmaster_of_fire")
            + ent:InsaneStats_GetEffectiveSkillTier("grandmaster_of_air")
            + ent:InsaneStats_GetEffectiveSkillTier("grandmaster_of_water")
            + ent:InsaneStats_GetEffectiveSkillTier("grandmaster_of_earth")
            local rawValue = 1.01 ^ totalLevel
            --local skillPoints = ent:InsaneStats_GetTotalSkillPoints()
            return CLIENT and InsaneStats:FormatNumber(rawValue) or rawValue
            --level / 1000, level * skillPoints / 1000
        end,
        img = "mountains",
        pos = {-5, 0},
        minpts = 777,
        max = 99
    },
    synergy_4 = {
        name = "Synergy (Dry)",
        desc = "On kill or whenever damage would be taken from a mob, gain 0.1 stacks of Synergy. \z
        Each stack increases damage dealt and defence by +%s%%, \z
        but stacks decay at a rate of -10%%/s regardless of skills. \z
        Also, reduce the unlock requirement of all Grandmaster skills by %i point(s).",
        values = function(level, ent)
            --[[level = level
            * (1 + ent:InsaneStats_GetEffectiveSkillValues("grandmaster_of_fire", 2) / 100)
            * (1 + ent:InsaneStats_GetEffectiveSkillValues("grandmaster_of_earth", 3) / 100)]]

            return CLIENT and InsaneStats:FormatNumber(level) or level, -level
        end,
        stackTick = function(state, current, time, ent)
            local nextStacks = current * .9 ^ time
            local newState = nextStacks <= 0 and 0 or 1

            if ent:InsaneStats_EffectivelyHasSkill("synergy_1") or ent:InsaneStats_EffectivelyHasSkill("synergy_2")
            or ent:InsaneStats_EffectivelyHasSkill("synergy_3") then
                newState = -2
            end

            return newState, nextStacks
        end,
        img = "jigsaw-box",
        pos = {-6, -6},
        minpts = 10,
        max = 99
    }
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
    --[[sick_combo = {
        name = "Sick Combo",
        typ = 1,
        img = "poker-hand"
    },]]
    anger_cooldown = {
        name = "Anger Grenade Cooldown",
        typ = -1,
        img = "time-bomb"
    },
    anger_resist = {
        name = "Anger Grenade'd",
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
    crit_defence_up = {
        name = "Critical Defence Up",
        typ = 1,
        img = "rear-aura"
    },
    crit_defence_down = {
        name = "Critical Defence Down",
        typ = -1,
        img = "william-tell-skull"
    },
    crit_xp_up = {
        name = "Critical Loot Up",
        typ = 1,
        img = "william-tell-skull"
    },
    xp_down = {
        name = "Loot Down",
        typ = -1,
        img = "animal-skull"
    },
    accuracy_up = {
        name = "Accuracy Up",
        typ = 1,
        img = "arrow-scope"
    },
    accuracy_down = {
        name = "Accuracy Down",
        typ = -1,
        img = "radial-balance"
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
    knockback_down = {
        name = "Knockback Down",
        typ = -1,
        img = "cut-palm"
    },
    knockback_resistance_up = {
        name = "Knockback Resistance Up",
        typ = 1,
        img = "oak"
    },
    knockback_resistance_down = {
        name = "Knockback Resistance Down",
        typ = -1,
        img = "dead-wood"
    },
    --[[inverted_shield = {
        name = "Inverted Shield",
        typ = -1,
        img = "cracked-disc"
    },]]
    ammo_stealer = {
        name = "Ammo Stealer",
        typ = 1,
        img = "arrow-cluster"
    },
    damage_up_aura = {
        name = "Damage Up Aura",
        typ = 0,
        img = "candle-light",
        overtime = true
    },
    defence_up_aura = {
        name = "Defence Up Aura",
        typ = 0,
        img = "three-leaves",
        overtime = true
    },
    xp_up_aura = {
        name = "Loot Up Aura",
        typ = 0,
        img = "brain",
        overtime = true
    },
    pyrotheum = {
        name = "Stellar Node",
        typ = 0,
        img = "sun",
        overtime = true,
        apply = SERVER and function(ent, level, duration, attacker)
            ent:InsaneStats_SetEntityData("pyrotheum_lastapplied", CurTime())

            if IsValid(attacker) then
                local count = 0
                for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("pyrotheum")) do
                    if v:InsaneStats_GetStatusEffectAttacker("pyrotheum") == attacker then
                        count = count + 1
                    end
                end
                attacker:InsaneStats_SetSkillData(
                    "pyrotheum",
                    attacker:InsaneStats_GetSkillState("pyrotheum"),
                    count
                )
            end
        end,
        expiry = SERVER and function(ent, level, attacker)
            if IsValid(attacker) then
                local count = 0
                for i,v in ipairs(InsaneStats:GetEntitiesByStatusEffect("pyrotheum")) do
                    if v:InsaneStats_GetStatusEffectAttacker("pyrotheum") == attacker then
                        count = count + 1
                    end
                end
                attacker:InsaneStats_SetSkillData(
                    "pyrotheum",
                    attacker:InsaneStats_GetSkillState("pyrotheum"),
                    count
                )
            end

            SafeRemoveEntity(ent)
        end
    },
    no_skill_forced_respawning = {
        name = "No Skill-Forced Respawning",
        typ = 0,
        img = "pirate-grave"
    },
    xp_yield_down = {
        name = "Loot Yielded Down",
        typ = 1,
        img = "acid-blob"
    },
    item_duplicator = {
        name = "Item Duplicator",
        typ = 1,
        img = "dig-dug"
    },
    bloodsapped = {
        name = "Bloodsapped",
        typ = -1,
        img = "leeching-worm",
        overtime = true,
    },
    field_of_shards = {
        name = "Painful Movement",
        typ = -1,
        img = "wolf-trap",
        overtime = true,
        expiry = SERVER and function(ent, level, attacker)
            ent:InsaneStats_SetEntityData("field_of_shards_distance_travelled")
        end
    },
    aura_invincibility = {
        name = "Spreading Damage Invincibility",
        typ = 1,
        img = "scalpel"
    },
    air_jolted = {
        name = "Air Jolted",
        typ = 0,
        img = "lightning-arc"
    },
	jump_height_up = {
		name = "Jump Height Up",
		typ = 1,
		img = "feather"
	}
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

hook.Add("InsaneStatsSkillMaxLevel", "InsaneStatsSkillsDefault", function(data)
    local ent = data.ent
    --[[if ent:InsaneStats_EffectivelyHasSkill("insane_stats_skills_plus") then
        data.max = data.max + 1
    end]]

    local totalLevel = ent:InsaneStats_GetEffectiveSkillTier("grandmaster_of_fire")
    + ent:InsaneStats_GetEffectiveSkillTier("grandmaster_of_air")
    + ent:InsaneStats_GetEffectiveSkillTier("grandmaster_of_water")
    + ent:InsaneStats_GetEffectiveSkillTier("grandmaster_of_earth")
    if ent:InsaneStats_EffectivelyHasSkill("grandmaster_of_air") and totalLevel >= 777 then
        data.max = data.max + 1
    end
end)

hook.Add("InsaneStatsSkillDiffTime", "InsaneStatsSkillsDefault", function(data)
    if data.ent:InsaneStats_EffectivelyHasSkill("controlled_reaction") then
        data.diffTime = data.diffTime * (1 + data.ent:InsaneStats_GetEffectiveSkillValues("controlled_reaction", 2) / 100)
    end
end)

hook.Add("InsaneStatsGetModifierProbabilities", "InsaneStatsSharedWPASS2", function(data)
    local ent = data.ent
    if (IsValid(ent) and ent:InsaneStats_EffectivelyHasSkill("adamantite_forge")) then
        data.negativeWeightMul = data.negativeWeightMul
        * (1 + ent:InsaneStats_GetEffectiveSkillValues("adamantite_forge")/100)
    end
end)

hook.Add("InsaneStatsSkillAdjacentPointsRequired", "InsaneStatsSkillsDefault", function(data)
    local skillName = data.name
    if skillName == "grandmaster_of_fire" or skillName == "grandmaster_of_air"
    or skillName == "grandmaster_of_water" or skillName == "grandmaster_of_earth" then
        local ent = data.ent
        local totalReduction = ent:InsaneStats_GetEffectiveSkillValues("synergy_1", 2)
        + ent:InsaneStats_GetEffectiveSkillValues("synergy_2", 3)
        + ent:InsaneStats_GetEffectiveSkillValues("synergy_3", 3)
        + ent:InsaneStats_GetEffectiveSkillValues("synergy_4", 2)

        data.minpts = data.minpts + totalReduction
    end
end)
