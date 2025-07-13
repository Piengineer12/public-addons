InsaneStats.WPASS2_FLAGS = {
	ARMOR = 1,
	XP = 2,
	SCRIPTED_ONLY = 4,
	SP_ONLY = 8,
	SUIT_POWER = 16,
	KNOCKBACK = 32,
	MP_ONLY = 64
	
	-- non-obvious combinations:
	-- 5: NEVER
}

InsaneStats:SetDefaultConVarCategory("WPASS2 - General")

InsaneStats:RegisterConVar("wpass2_enabled", "insanestats_wpass2_enabled", "1", {
	display = "Enable WPASS2", desc = "Enables WPASS2, allowing weapons / armor batteries to gain prefixes and suffixes.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("wpass2_autopickup", "insanestats_wpass2_autopickup", "1", {
	display = "Auto Pickup Mode", desc = "Determines whether weapons / armor batteries will be automatically picked up for ammo / armor.\n\z
	0: Never auto pickup weapons and armor batteries.\n\z
	1: Auto pickup weapons and armor batteries that are tier 0.\n\z
	2: Auto pickup weapons and armor batteries that have lower tiers than current.\n\z
	3: Auto pickup weapons and armor batteries that have lower tiers than current, and always swap for higher tiers.\n\z
	4: Auto pickup weapons and armor batteries that have equal or lower tiers than current.\n\z
	5: Auto pickup weapons and armor batteries that have equal or lower tiers than current, and always swap for higher tiers.\n\z
	6: Always auto pickup weapons and armor batteries.",
	type = InsaneStats.INT, min = 0, max = 6
})
InsaneStats:RegisterConVar("wpass2_autopickup_battery", "insanestats_wpass2_autopickup_battery", "-1", {
	display = "Auto Battery Pickup Mode", desc = "If 0 or above, overrides insanestats_wpass2_autopickup for armor batteries.",
	type = InsaneStats.INT, min = -1, max = 6
})
InsaneStats:RegisterConVar("wpass2_dropship_invincible", "insanestats_wpass2_dropship_invincible", "1", {
	display = "Invincible Dropship Containers", desc = "Combine dropship containers can't be damaged. This has been known to break maps if disabled!",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("wpass2_burrowed_invincible", "insanestats_wpass2_burrowed_invincible", "1", {
	display = "Invincible Burrowed NPCs", desc = "Burrowed antlions can't be damaged.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("wpass2_no_aiscripted_schedule_interrupt", "insanestats_wpass2_no_aiscripted_schedule_interrupt", "1", {
	display = "Disable aiscripted_schedule Interrupt",
	desc = "Stops NPCs from forgetting what they were supposed to be doing when combat is nearby. \z
	If 1, they can still be interrupted by taking damage.",
	type = InsaneStats.INT, min = 0, max = 2
})
InsaneStats:RegisterConVar("wpass2_no_fractional_clips", "insanestats_wpass2_no_fractional_clips", "0", {
	display = "Disable Fractional Clips", desc = "Stops clips within weapons from becoming fractional. \z
	Requires a map restart to fully take effect. \z
	Effects that grant ammo efficiency instead have a chance to prevent ammo from being consumed.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("wpass2_item_limit", "insanestats_wpass2_item_limit", "-1", {
	display = "Item Limit", desc = "If there are more than this number of items in the map, \z
	all items will be teleported to random players to prevent lag. A negative number disables this feature.",
	type = InsaneStats.FLOAT, min = -1, max = 1000
})

InsaneStats:SetDefaultConVarCategory("WPASS2 - Modifiers & Saving")

InsaneStats:RegisterConVar("wpass2_modifiers_player_save", "insanestats_wpass2_modifiers_player_save", "2", {
	display = "Save Player Modifiers Across Maps", desc = "If 1, modifiers on player weapons / armor batteries will be saved across maps. \z
	Consequently, all weapons and ammo are also perserved across maps. \z
	Health, armor and suit status are perserved if armor batteries are perserved.\n\z
	In addition, disconnected players will also have their loadouts perserved even if the map has changed.\n\z
	If 2, only WPASS2 modifiers are perserved, to avoid interference with other addons that already save the player's loadout.\n\z
	Note that Half-Life 2 level transitions already carry these across the transitioned levels, even when this ConVar is off.",
	type = InsaneStats.INT, min = 0, max = 2
})
InsaneStats:RegisterConVar("wpass2_modifiers_player_save_battery", "insanestats_wpass2_modifiers_player_save_battery", "-1", {
	display = "Save Player Battery Modifiers Across Maps", desc = "If 0 or above, overrides insanestats_wpass2_modifiers_player_save for armor batteries.",
	type = InsaneStats.INT, min = -1, max = 2
})
InsaneStats:RegisterConVar("wpass2_modifiers_player_save_death", "insanestats_wpass2_modifiers_player_save_death", "2", {
	display = "Save Player Modifiers Across Deaths", desc = "If 1, modifiers on player weapons / armor batteries will be saved across deaths. \z
	Consequently, all weapons and ammo are also perserved across deaths.\n\z
	In addition, disconnected players will also have their loadouts perserved as long as they rejoin in the same session.\n\z
	If 2, only WPASS2 modifiers are perserved, to avoid interference with other addons that already save the player's loadout.",
	type = InsaneStats.INT, min = 0, max = 2
})
InsaneStats:RegisterConVar("wpass2_modifiers_player_save_death_battery", "insanestats_wpass2_modifiers_player_save_death_battery", "-1", {
	display = "Save Player Battery Modifiers Across Deaths", desc = "If 0 or above, overrides insanestats_wpass2_modifiers_player_save_death for armor batteries.",
	type = InsaneStats.INT, min = -1, max = 2
})
InsaneStats:RegisterConVar("wpass2_modifiers_other_create", "insanestats_wpass2_modifiers_other_create", "2", {
	display = "Create Weapon for Non-players", desc = "If 1, NPCs and NextBots will still get weapon modifiers even while not carrying a weapon. \z
	This works by creating an invisible and intangible weapon_base that is tied to the entity.\n\z
	If 2, only humanoid and Combine entities are able to get weapon modifiers. \n\z
	If 3, ALL entities will gain weapon modifiers in the same way. Setting this to 3 is NOT RECOMMENDED.",
	type = InsaneStats.INT, min = 0, max = 3
})
InsaneStats:RegisterConVar("wpass2_modifiers_blacklist", "insanestats_wpass2_modifiers_blacklist", "", {
	display = "Modifier Blacklist", desc = "Modifiers in this list will never appear on weapons nor armor batteries.\n\z
	Note that you must specify the internal name of modifiers, not the display name. You can find the internal name \z
	of item modifiers by typing \"insanestats_wpass2_modifiers_show\" in the (client) console.\n\z
	You can also specify \"!curse\", which will cause unlisted negative modifiers to be blacklisted \z
	and listed negative modifiers to NOT be blacklisted.",
	type = InsaneStats.STRING
})
InsaneStats:RegisterConVar("wpass2_modifiers_negativeweight", "insanestats_wpass2_modifiers_negativeweight", "0.25", {
	display = "Negative Modifier Weight Multiplier", desc = "Weight multiplier for negative modifiers.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("wpass2_modifiers_negativeweight_battery", "insanestats_wpass2_modifiers_negativeweight_battery", "-1", {
	display = "Negative Battery Modifier Weight Multiplier", desc = "If 0 or above, overrides insanestats_wpass2_modifiers_negativeweight for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 10
})
InsaneStats:RegisterConVar("wpass2_modifiers_switched", "insanestats_wpass2_modifiers_switched", "0", {
	display = "Switched Modifier Weight Multiplier", desc = "If above 0, modifiers meant for armor batteries can be applied to weapons and vice versa, with higher values making this more likely.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterConVar("wpass2_modifiers_switched_battery", "insanestats_wpass2_modifiers_switched_battery", "-1", {
	display = "Switched Battery Modifier Weight Multiplier", desc = "If 0 or above, overrides insanestats_wpass2_modifiers_switched for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 10
})

InsaneStats:SetDefaultConVarCategory("WPASS2 - Attribute Effects")

InsaneStats:RegisterConVar("wpass2_attributes_player_constant_speed", "insanestats_wpass2_attributes_player_constant_speed", "0", {
	display = "Use Precalculated Player Speeds", desc = "Whenever player speeds are changed by WPASS2, non-WPASS2 speed modifiers are removed. \z
	This fixes the issue of weapons with speed attributes that also set the player's speed causing players to infinitely stack speed multipliers.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("wpass2_attributes_player_constant_timescale", "insanestats_wpass2_attributes_player_constant_timescale", "0", {
	display = "Use Precalculated Time Scale", desc = "Whenever the time scale is changed by WPASS2, non-WPASS2 time scale modifiers are removed. \z
	This fixes the issue of time scale modifiers being stacked infinitely due to other addons.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("wpass2_attributes_player_enabled", "insanestats_wpass2_attributes_player_enabled", "1", {
	display = "Player Attribute Effects", desc = "If disabled, modified weapons / armor batteries will have no effect on players.",
	type = InsaneStats.INT, min = 0, max = 1
})
InsaneStats:RegisterConVar("wpass2_attributes_player_enabled_battery", "insanestats_wpass2_attributes_player_enabled_battery", "-1", {
	display = "Player Battery Attribute Effects", desc = "If 0 or above, overrides insanestats_wpass2_effects_player_enabled for armor batteries.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("wpass2_attributes_other_enabled", "insanestats_wpass2_attributes_other_enabled", "1", {
	display = "Non-player Attribute Effects", desc = "If disabled, modified weapons / armor batteries will have no effect on NPCs.",
	type = InsaneStats.INT, min = 0, max = 1
})
InsaneStats:RegisterConVar("wpass2_attributes_other_enabled_battery", "insanestats_wpass2_attributes_other_enabled_battery", "-1", {
	display = "Non-player Battery Attribute Effects", desc = "If 0 or above, overrides insanestats_wpass2_effects_other_enabled for armor batteries.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("wpass2_attributes_ally_enabled", "insanestats_wpass2_attributes_ally_enabled", "-1", {
	display = "Ally Attribute Effects", desc = "If 0 or above, overrides insanestats_wpass2_attributes_other_enabled for ally NPCs.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("wpass2_attributes_ally_enabled_battery", "insanestats_wpass2_attributes_ally_enabled_battery", "-1", {
	display = "Ally Battery Attribute Effects", desc = "If 0 or above, overrides insanestats_wpass2_attributes_ally_enabled for armor batteries.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("wpass2_attributes_enemy_enabled", "insanestats_wpass2_attributes_enemy_enabled", "-1", {
	display = "Enemy Attribute Effects", desc = "If 0 or above, overrides insanestats_wpass2_attributes_other_enabled for enemy NPCs.",
	type = InsaneStats.INT, min = -1, max = 1
})
InsaneStats:RegisterConVar("wpass2_attributes_enemy_enabled_battery", "insanestats_wpass2_attributes_enemy_enabled_battery", "-1", {
	display = "Enemy Battery Attribute Effects", desc = "If 0 or above, overrides insanestats_wpass2_attributes_enemy_enabled for armor batteries.",
	type = InsaneStats.INT, min = -1, max = 1
})

InsaneStats:SetDefaultConVarCategory("WPASS2 - Tier Calculation")

InsaneStats:RegisterConVar("wpass2_tier_start", "insanestats_wpass2_tier_start", "1", {
	display = "Starting Tier", desc = "Starting tier for weapons / armor batteries.",
	type = InsaneStats.FLOAT, min = 0, max = 10000
})
InsaneStats:RegisterConVar("wpass2_tier_start_battery", "insanestats_wpass2_tier_start_battery", "-1", {
	display = "Battery Starting Tier", desc = "If 0 or above, overrides insanestats_wpass2_tier_start for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 10000
})
InsaneStats:RegisterConVar("wpass2_tier_max", "insanestats_wpass2_tier_max", "999", {
	display = "Maximum Tier", desc = "Maximum possible weapon / armor battery tier.",
	type = InsaneStats.INT, min = -10000, max = 10000
})
InsaneStats:RegisterConVar("wpass2_tier_min", "insanestats_wpass2_tier_min", "-8", {
	display = "Minimum Tier", desc = "Minimum possible weapon / armor battery tier.",
	type = InsaneStats.INT, min = -10000, max = 10000
})
InsaneStats:RegisterConVar("wpass2_tier_upchance", "insanestats_wpass2_tier_upchance", "50", {
	display = "Tier Up Chance", desc = "% chance for a weapon / armor battery to have its tier increased by 1. This is rolled for continuously until the roll fails.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_tier_upchance_battery", "insanestats_wpass2_tier_upchance_battery", "-1", {
	display = "Battery Tier Up Chance", desc = "If 0 or above, overrides insanestats_wpass2_tier_upchance for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_tier_downchance", "insanestats_wpass2_tier_downchance", "25", {
	display = "Tier Down Chance", desc = "% chance for a weapon / armor battery to have its tier decreased by 1. This is rolled for continuously until the roll fails.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_tier_downchance_battery", "insanestats_wpass2_tier_downchance_battery", "-1", {
	display = "Battery Tier Down Chance", desc = "If 0 or above, overrides insanestats_wpass2_tier_downchance for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_tier_newmodifiercost", "insanestats_wpass2_tier_newmodifier_cost", "2", {
	display = "New Modifier Cost", desc = "Number of tiers before another weapon / armor battery modifier is attached. Tier 1 weapons / armor batteries will always have one modifier.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_tier_newmodifiercost_battery", "insanestats_wpass2_tier_newmodifier_cost_battery", "-1", {
	display = "New Battery Modifier Cost", desc = "If 0 or above, overrides insanestats_wpass2_tier_newmodifiercost for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_tier_raritycost", "insanestats_wpass2_tier_raritycost", "2", {
	display = "Tiers Per Rarity", desc = "Number of tiers per rarity.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_tier_raritycost_battery", "insanestats_wpass2_tier_raritycost_battery", "-1", {
	display = "Battery Tiers Per Rarity", desc = "If 0 or above, overrides insanestats_wpass2_tier_raritycost for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_tier_blacklist", "insanestats_wpass2_tier_blacklist", "weapon_physgun gmod_tool gmod_camera", {
	display = "Weapon Blacklist", desc = "Weapon classes in this list will always remain at tier 0, preventing them from gaining modifiers.",
	type = InsaneStats.STRING
})

InsaneStats:RegisterConVar("wpass2_tier_xp_enable", "insanestats_wpass2_tier_xp_enable", "0", {
	display = "Experience Integration", desc = "Allows the weapon's / armor battery's level to influence its tier. Only relevant when Insane Stats XP is enabled.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("wpass2_tier_xp_level_start", "insanestats_wpass2_tier_xp_level_start", "3", {
	display = "Starting Level", desc = "Level before weapons / armor batteries are guaranteed to be tier 1. Below this, weapons / armor batteries may sometimes spawn at tier 0 even after passing the insanestats_wpass2_chance_* check.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("wpass2_tier_xp_level_start_battery", "insanestats_wpass2_tier_xp_level_start_battery", "-1", {
	display = "Battery Starting Level", desc = "If 0 or above, overrides insanestats_wpass2_xp_tier_levelstart for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 1000
})
InsaneStats:RegisterConVar("wpass2_tier_xp_level_add", "insanestats_wpass2_tier_xp_level_add", "50", {
	display = "Level Scaling", desc = "% additional levels needed per tier up.",
	type = InsaneStats.FLOAT, min = 0, max = 1000
})
InsaneStats:RegisterConVar("wpass2_tier_xp_level_add_battery", "insanestats_wpass2_tier_xp_level_add_battery", "-1", {
	display = "Battery Level Scaling", desc = "If 0 or above, overrides insanestats_wpass2_tier_xp_level_add for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 1000
})
InsaneStats:RegisterConVar("wpass2_tier_xp_level_add_mode", "insanestats_wpass2_tier_xp_level_add_mode", "-1", {
	display = "Level Mode", desc = "If enabled, the level tier up % is applied additively rather than multiplicatively. \z
		-1 causes this ConVar to use the value of insanestats_xp_mode.",
	type = InsaneStats.INT, min = -1, max = 1
})

InsaneStats:SetDefaultConVarCategory("WPASS2 - Chances")

InsaneStats:RegisterConVar("wpass2_chance_unowned", "insanestats_wpass2_chance_unowned", "100", {
	display = "Unowned Chance", desc = "Chance for an unowned weapon / armor battery to be above tier 0, creating at least a tier 1 weapon / armor battery. \z
		Note that Sprint needs to be held in order for weapons / armor batteries above tier 0 to be picked up normally.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_unowned_battery", "insanestats_wpass2_chance_unowned_battery", "-1", {
	display = "Unowned Battery Chance", desc = "If 0 or above, overrides insanestats_wpass2_chance_unowned for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_player", "insanestats_wpass2_chance_player", "100", {
	display = "Player Chance", desc = "Chance for a player-owned weapon / armor battery to be above tier 0.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_player_battery", "insanestats_wpass2_chance_player_battery", "-1", {
	display = "Player Battery Chance", desc = "If 0 or above, overrides insanestats_wpass2_chance_player for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_player_drop", "insanestats_wpass2_chance_player_drop", "100", {
	display = "Player Drop Chance", desc = "Chance for dead players to drop their weapon / armor battery. Note that other addons can still force players to drop their weapon on death.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_player_drop_battery", "insanestats_wpass2_chance_player_drop_battery", "0", {
	display = "Player Battery Drop Chance", desc = "If 0 or above, overrides insanestats_wpass2_chance_player_drop for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_other", "insanestats_wpass2_chance_other", "25", {
	display = "Non-player Chance", desc = "Chance for an NPC owned weapon / armor battery to be above tier 0.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_other_battery", "insanestats_wpass2_chance_other_battery", "-1", {
	display = "Non-player Battery Chance", desc = "If 0 or above, overrides insanestats_wpass2_chance_other for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_other_battery_sensible", "insanestats_wpass2_chance_other_battery_sensible", "1", {
	display = "Sensible NPCs Only", desc = "If enabled, only humanoid and Combine entities are able to spawn with a modified armor battery.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("wpass2_chance_ally", "insanestats_wpass2_chance_ally", "-1", {
	display = "Ally Chance", desc = "If 0 or above, overrides insanestats_wpass2_chance_other for ally NPCs.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_ally_battery", "insanestats_wpass2_chance_ally_battery", "-1", {
	display = "Ally Battery Chance", desc = "If 0 or above, overrides insanestats_wpass2_chance_other_ally for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_enemy", "insanestats_wpass2_chance_enemy", "-1", {
	display = "Enemy Chance", desc = "If 0 or above, overrides insanestats_wpass2_chance_other for enemy NPCs.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_enemy_battery", "insanestats_wpass2_chance_enemy_battery", "-1", {
	display = "Enemy Battery Chance", desc = "If 0 or above, overrides insanestats_wpass2_chance_other_enemy for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_other_drop", "insanestats_wpass2_chance_other_drop", "0", {
	display = "Non-player Drop Chance", desc = "Chance for NPCs to drop their weapon / armor battery. For weapons, this only applies in maps where NPCs do not normally drop their weapons.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterConVar("wpass2_chance_other_drop_battery", "insanestats_wpass2_chance_other_drop_battery", "100", {
	display = "Non-player Battery Drop Chance", desc = "If 0 or above, overrides insanestats_wpass2_chance_other_drop for armor batteries.",
	type = InsaneStats.FLOAT, min = -1, max = 100
})

local doWeaponOverride = false
local doEFBOverride = true
local function PerformHookOverrides(hookName, suppressed)
	local hookTable = hook.GetTable()
	local originalHooks = hookTable[hookName]
	local overrideHooks = hookTable["NonInsaneStats"..hookName]
	local override = doWeaponOverride and not suppressed

	if override then
		local nopString = tostring(InsaneStats.NOP)
		if originalHooks then
			for k,v in pairs(originalHooks) do
				if nopString ~= tostring(v) and k ~= "InsaneStats" then
					hook.Add("NonInsaneStats"..hookName, k, v)
					hook.Add(hookName, k, InsaneStats.NOP)
				end
			end
		end
	end

	if overrideHooks then
		for k,v in pairs(overrideHooks) do
			if not overrideHooks[k] then -- it's gone!
				hook.Remove("NonInsaneStats"..hookName, k)
			elseif not override then -- put it back!
				hook.Add(hookName, k, v)
				hook.Remove("NonInsaneStats"..hookName, k)
			end
		end
	end
end

timer.Create("InsaneStatsSharedWPASS", 5, 0, function()
	-- the reason we don't alter for DLib is to prevent functions from returning true, which would break our bullets
	-- some addons also mistakenly return true on PlayerCanPickup* hooks as well
	-- exception to EntityFireBullets: if we see GetConVar("rnpct_weaponproficiency_support"), BAIL! that addon is already doing our job!
	local cVar_WP_Support = GetConVar("rnpct_weaponproficiency_support")
	doEFBOverride = not (cVar_WP_Support and cVar_WP_Support:GetBool())
	PerformHookOverrides("EntityFireBullets", not doEFBOverride)
	PerformHookOverrides("PlayerCanPickupWeapon")
	PerformHookOverrides("PlayerCanPickupItem")

	if SERVER then
		for i,v in ipairs(ents.FindByClass("weapon_base")) do
			if v.insaneStats_IsProxyWeapon then
				v:SetMoveType(MOVETYPE_NONE)
				v:SetNotSolid(true)
				v:SetNoDraw(true)
			end
		end
	end

	-- -- these ones too, since we want to change the argument value
	-- PerformHookOverrides("ScaleNPCDamage")
	-- PerformHookOverrides("ScalePlayerDamage")
end)

local WEAPON = FindMetaTable("Weapon")
local PLAYER = FindMetaTable("Player")
local playerAmmosToUpdateAdjs = {}

local function OverrideWeapons()
	if not WEAPON.InsaneStats_SetRawNextPrimaryFire then
		WEAPON.InsaneStats_SetRawNextPrimaryFire = WEAPON.SetNextPrimaryFire
		WEAPON.InsaneStats_SetRawNextSecondaryFire = WEAPON.SetNextSecondaryFire
		WEAPON.InsaneStats_RawClip1 = WEAPON.Clip1
		WEAPON.InsaneStats_RawClip2 = WEAPON.Clip2
		WEAPON.InsaneStats_SetRawClip1 = WEAPON.SetClip1
		WEAPON.InsaneStats_SetRawClip2 = WEAPON.SetClip2
		
		PLAYER.InsaneStats_GetRawAmmoCount = PLAYER.GetAmmoCount
		PLAYER.InsaneStats_GetRawAmmo = PLAYER.GetAmmo
		PLAYER.InsaneStats_GiveRawAmmo = PLAYER.GiveAmmo
		PLAYER.InsaneStats_RemoveRawAmmo = PLAYER.RemoveAmmo
		PLAYER.InsaneStats_RemoveAllRawAmmo = PLAYER.RemoveAllAmmo
		PLAYER.InsaneStats_StripRawAmmo = PLAYER.StripAmmo
		PLAYER.InsaneStats_SetRawAmmo = PLAYER.SetAmmo
	end
	
	function WEAPON:SetNextPrimaryFire(nextTime)
		local data = {next = nextTime, wep = self, attacker = self:GetOwner()}
		hook.Run("InsaneStatsModifyNextFire", data)
		
		return self:InsaneStats_SetRawNextPrimaryFire(data.next)
	end
	
	function WEAPON:SetNextSecondaryFire(nextTime)
		local data = {next = nextTime, wep = self, attacker = self:GetOwner()}
		hook.Run("InsaneStatsModifyNextFire", data)
		
		return self:InsaneStats_SetRawNextSecondaryFire(data.next)
	end

	if not InsaneStats:GetConVarValue("wpass2_no_fractional_clips") then
		function WEAPON:Clip1()
			return self:InsaneStats_RawClip1() - (self.insaneStats_Clip1Adj or 0)
		end

		function WEAPON:Clip2()
			return self:InsaneStats_RawClip2() - (self.insaneStats_Clip2Adj or 0)
		end
	end

	function WEAPON:SetClip1(num)
		local data = {
			new = num, old = self.insaneStats_LastClip1 or self:Clip1(),
			wep = self
		}
		hook.Run("InsaneStatsModifyWeaponClip", data)
		if InsaneStats:GetConVarValue("wpass2_no_fractional_clips") then
			data.new = (data.new % 1 > math.random() and math.ceil or math.floor)(data.new)
		end
		self.insaneStats_Clip1Adj = math.Round(1 - data.new, 3) % 1
		if SERVER then
			self:InsaneStats_MarkForUpdate(512)
		end
		
		return self:InsaneStats_SetRawClip1(math.ceil(data.new))
	end
	
	function WEAPON:SetClip2(num)
		local data = {
			new = num, old = self.insaneStats_LastClip2 or self:Clip2(),
			wep = self, secondary = true
		}
		hook.Run("InsaneStatsModifyWeaponClip", data)
		if InsaneStats:GetConVarValue("wpass2_no_fractional_clips") then
			data.new = (data.new % 1 > math.random() and math.ceil or math.floor)(data.new)
		end
		self.insaneStats_Clip2Adj = math.Round(1 - data.new, 3) % 1
		if SERVER then
			self:InsaneStats_MarkForUpdate(512)
		end
		
		return self:InsaneStats_SetRawClip2(math.ceil(data.new))
	end

	function PLAYER:GetAmmoCount(ammoType)
		self.insaneStats_AmmoAdjs = self.insaneStats_AmmoAdjs or {}
		local ammoTypeNum = isstring(ammoType) and game.GetAmmoID(ammoType) or ammoType
		return self:InsaneStats_GetRawAmmoCount(ammoType) - (self.insaneStats_AmmoAdjs[ammoTypeNum] or 0)
	end

	function PLAYER:GetAmmo()
		self.insaneStats_AmmoAdjs = self.insaneStats_AmmoAdjs or {}
		local rawData = self:InsaneStats_GetRawAmmo()
		local returnedData = {}
		for k,v in pairs(rawData) do
			returnedData[k] = v - (self.insaneStats_AmmoAdjs[k] or 0)
		end
		return returnedData
	end

	function PLAYER:GiveAmmo(num, ammoType, hidePopup)
		local data = {num = num, type = ammoType, ply = self}
		hook.Run("InsaneStatsPlayerAddAmmo", data)
		
		ammoType = data.type
		local ammoTypeNum = isstring(ammoType) and game.GetAmmoID(ammoType) or ammoType
		local newAmmo = math.Round(self:GetAmmoCount(ammoType) + data.num, 3)
		local rawAmmo = math.ceil(newAmmo)
		self.insaneStats_AmmoAdjs[ammoTypeNum] = rawAmmo - newAmmo

		playerAmmosToUpdateAdjs[self] = playerAmmosToUpdateAdjs[self] or {}
		playerAmmosToUpdateAdjs[self][ammoTypeNum] = true
		
		return self:InsaneStats_GiveRawAmmo(
			rawAmmo
			- self:InsaneStats_GetRawAmmoCount(ammoType),
			ammoType, hidePopup
		)
	end
	
	function PLAYER:RemoveAmmo(num, ammoType)
		local data = {num = num, type = ammoType, ply = self}
		hook.Run("InsaneStatsPlayerRemoveAmmo", data)

		ammoType = data.type
		local ammoTypeNum = isstring(ammoType) and game.GetAmmoID(ammoType) or ammoType
		local newAmmo = math.Round(self:GetAmmoCount(ammoType) - data.num, 3)
		local rawAmmo = math.ceil(newAmmo)
		self.insaneStats_AmmoAdjs[ammoTypeNum] = rawAmmo - newAmmo
		
		playerAmmosToUpdateAdjs[self] = playerAmmosToUpdateAdjs[self] or {}
		playerAmmosToUpdateAdjs[self][ammoTypeNum] = true
		
		return self:InsaneStats_RemoveRawAmmo(
			self:InsaneStats_GetRawAmmoCount(ammoType)
			- rawAmmo,
			ammoType
		)
	end
	
	function PLAYER:RemoveAllAmmo()
		self.insaneStats_AmmoAdjs = nil
		
		playerAmmosToUpdateAdjs[self] = playerAmmosToUpdateAdjs[self] or {}
		playerAmmosToUpdateAdjs[self].clear = true

		return self:InsaneStats_RemoveAllRawAmmo()
	end
	
	function PLAYER:StripAmmo()
		self.insaneStats_AmmoAdjs = nil
		
		playerAmmosToUpdateAdjs[self] = playerAmmosToUpdateAdjs[self] or {}
		playerAmmosToUpdateAdjs[self].clear = true

		return self:InsaneStats_StripRawAmmo()
	end
	
	function PLAYER:SetAmmo(num, ammoType)
		local data = {new = num, old = self.insaneStats_OldSetAmmoValue or self:GetAmmoCount(ammoType), type = ammoType, ply = self}
		hook.Run("InsaneStatsPlayerSetAmmo", data)

		ammoType = data.type
		local ammoTypeNum = isstring(ammoType) and game.GetAmmoID(ammoType) or ammoType
		local newAmmo = math.Round(data.new, 3)
		local rawAmmo = math.ceil(newAmmo)
		self.insaneStats_AmmoAdjs[ammoTypeNum] = rawAmmo - newAmmo
		
		playerAmmosToUpdateAdjs[self] = playerAmmosToUpdateAdjs[self] or {}
		playerAmmosToUpdateAdjs[self][ammoTypeNum] = true
		
		return self:InsaneStats_SetRawAmmo(rawAmmo, ammoType)
	end
end

local function DeOverrideWeapons()
	if WEAPON.InsaneStats_SetRawNextPrimaryFire then
		WEAPON.SetNextPrimaryFire = WEAPON.InsaneStats_SetRawNextPrimaryFire
		WEAPON.SetNextSecondaryFire = WEAPON.InsaneStats_SetRawNextSecondaryFire
		WEAPON.Clip1 = WEAPON.InsaneStats_RawClip1
		WEAPON.Clip2 = WEAPON.InsaneStats_RawClip2
		WEAPON.SetClip1 = WEAPON.InsaneStats_SetRawClip1
		WEAPON.SetClip2 = WEAPON.InsaneStats_SetRawClip2
		
		PLAYER.GetAmmoCount = PLAYER.InsaneStats_GetRawAmmoCount
		PLAYER.GetAmmo = PLAYER.InsaneStats_GetRawAmmo
		PLAYER.GiveAmmo = PLAYER.InsaneStats_GiveRawAmmo
		PLAYER.RemoveAmmo = PLAYER.InsaneStats_RemoveRawAmmo
		PLAYER.RemoveAllAmmo = PLAYER.InsaneStats_RemoveAllRawAmmo
		PLAYER.StripAmmo = PLAYER.InsaneStats_StripRawAmmo
		PLAYER.SetAmmo = PLAYER.InsaneStats_SetRawAmmo
		
		WEAPON.InsaneStats_SetRawNextPrimaryFire = nil
		WEAPON.InsaneStats_SetRawNextSecondaryFire = nil
		WEAPON.InsaneStats_RawClip1 = nil
		WEAPON.InsaneStats_RawClip2 = nil
		WEAPON.InsaneStats_SetRawClip1 = nil
		WEAPON.InsaneStats_SetRawClip2 = nil
		
		PLAYER.InsaneStats_GetRawAmmoCount = nil
		PLAYER.InsaneStats_GetRawAmmo = nil
		PLAYER.InsaneStats_GiveRawAmmo = nil
		PLAYER.InsaneStats_RemoveRawAmmo = nil
		PLAYER.InsaneStats_RemoveAllRawAmmo = nil
		PLAYER.InsaneStats_StripRawAmmo = nil
		PLAYER.InsaneStats_SetRawAmmo = nil
	end
end

local function CheckOverrideWeapons()
	local shouldWeaponOverride = InsaneStats:GetConVarValue("wpass2_enabled") or InsaneStats:GetConVarValue("skills_enabled")
	if doWeaponOverride ~= shouldWeaponOverride then
		doWeaponOverride = shouldWeaponOverride
		if doWeaponOverride then
			OverrideWeapons()
		else
			DeOverrideWeapons()
		end
	end
end

local function JoinBulletCallbacks(funcs)
	return function(...)
		local effects, damage = true, true
		for i,v in ipairs(funcs) do
			local tab = v(...)
			if istable(tab) then
				effects = effects and tab.effects
				damage = damage and tab.damage
			end
		end

		if not (effects and damage) then
			local tab = {}
			if not effects then tab.effects = false end
			if not damage then tab.damage = false end
			return tab
		end
	end
end

hook.Add("EntityFireBullets", "InsaneStats", function(ent, data, ...)
	if doWeaponOverride and doEFBOverride then
		-- run the others first, but in a more roundabout way
		local nonInsaneStatsHooks = hook.GetTable().NonInsaneStatsEntityFireBullets or {}
		local bulletCallbacks = {}
		
		if data.Callback then
			table.insert(bulletCallbacks, data.Callback)
			data.Callback = nil
		end

		for k,v in pairs(nonInsaneStatsHooks) do
			local ret = v(ent, data, ...)
			if data.Callback then
				table.insert(bulletCallbacks, data.Callback)
				data.Callback = nil
			end
			if ret == false then return false end
		end

		data.Callback = JoinBulletCallbacks(bulletCallbacks)
	end
end)
hook.Add("PlayerCanPickupWeapon", "InsaneStats", function(...)
	if doWeaponOverride then
		-- run the others first, but in a more roundabout way
		local nonInsaneStatsHooks = hook.GetTable().NonInsaneStatsPlayerCanPickupWeapon or {}
		local shouldAlter = false
		for k,v in pairs(nonInsaneStatsHooks) do
			local ret = v(...)
			if ret == false then return false end
		end
	end
end)
hook.Add("PlayerCanPickupItem", "InsaneStats", function(ply, item, ...)
	if doWeaponOverride then
		-- run the others first, but in a more roundabout way
		local nonInsaneStatsHooks = hook.GetTable().NonInsaneStatsPlayerCanPickupItem or {}
		local shouldAlter = false
		for k,v in pairs(nonInsaneStatsHooks) do
			local ret = v(ply, item, ...)
			if ret == false then
				if InsaneStats:IsDebugLevel(4) then
					InsaneStats:Log("%s denied pickup of %s by %s", k, item, ply)
				end
				return false
			end
		end
	end
end)
--[[hook.Add("ScaleNPCDamage", "InsaneStats", function(...)
	if doWeaponOverride then
		local hookTable = hook.GetTable()
		local nonInsaneStatsHooks = hookTable.NonInsaneStatsScaleNPCDamage or {}
		local insaneStatsHooks = hookTable.InsaneStatsPreScaleNPCDamage or {}
		local sendValues = {...}
		for k,v in pairs(insaneStatsHooks) do
			local ret = v(sendValues)
			if ret then return ret end
		end
		for k,v in pairs(nonInsaneStatsHooks) do
			local ret = v(unpack(sendValues))
			if ret then return ret end
		end
	end
end)
hook.Add("ScalePlayerDamage", "InsaneStats", function(...)
	if doWeaponOverride then
		local hookTable = hook.GetTable()
		local nonInsaneStatsHooks = hookTable.NonInsaneStatsScalePlayerDamage or {}
		local insaneStatsHooks = hookTable.InsaneStatsPreScalePlayerDamage or {}
		local sendValues = {...}
		for k,v in pairs(insaneStatsHooks) do
			local ret = v(sendValues)
			if ret then return ret end
		end
		for k,v in pairs(nonInsaneStatsHooks) do
			local ret = v(unpack(sendValues))
			if ret then return ret end
		end
	end
end)]]

local registeredEffects, modifiers, attributes = {}, {}, {}
local effectNamesToIDs = {}
local effectIDsToNames = {}
local expiryEffects = {}
local entitiesByStatusEffect = {} -- used for optimization purposes
local function MapStatusEffectNamesToIDs()
	effectNamesToIDs = {}
	effectIDsToNames = {}
	
	for k,v in SortedPairs(registeredEffects) do
		effectNamesToIDs[k] = table.insert(effectIDsToNames, k)
		expiryEffects[k] = v.expiry
	end
	
	--print("Client: ", CLIENT)
	--PrintTable(effectNamesToIDs)
end

hook.Add("InsaneStatsLoadWPASS", "InsaneStatsSharedWPASS", function(modifiers, attributes, registeredEffects)
	attributes.reverse_xp = {
		display = "%s coins and XP yielded on death",
		invert = true
	}
end)

hook.Add("Initialize", "InsaneStatsSharedWPASS", function()
	modifiers, attributes, registeredEffects = {}, {}, {}
	hook.Run("InsaneStatsLoadWPASS", modifiers, attributes, registeredEffects)
	MapStatusEffectNamesToIDs()
	hook.Run("InsaneStatsPostLoadWPASS", modifiers, attributes, registeredEffects)
end)

hook.Add("InitPostEntity", "InsaneStatsSharedWPASS", function()
	for i,v in ents.Iterator() do
		for k,v2 in pairs(v.insaneStats_StatusEffects or {}) do
			entitiesByStatusEffect[k] = entitiesByStatusEffect[k] or {}
			entitiesByStatusEffect[k][v] = v2
		end
	end
end)

hook.Run("InsaneStatsLoadWPASS", modifiers, attributes, registeredEffects)
MapStatusEffectNamesToIDs()
hook.Run("InsaneStatsPostLoadWPASS", modifiers, attributes, registeredEffects)
	
for i,v in ents.Iterator() do
	for k,v2 in pairs(v.insaneStats_StatusEffects or {}) do
		entitiesByStatusEffect[k] = entitiesByStatusEffect[k] or {}
		entitiesByStatusEffect[k][v] = v2
	end
end

function InsaneStats:GetAllModifiers()
	return modifiers or {}
end

function InsaneStats:GetAllAttributes()
	return attributes or {}
end

function InsaneStats:GetAllStatusEffects()
	return registeredEffects
end

function InsaneStats:GetStatusEffectID(name)
	return effectNamesToIDs[name]
end

function InsaneStats:GetStatusEffectNames()
	return effectIDsToNames
end

function InsaneStats:GetStatusEffectName(id)
	return effectIDsToNames[id]
end

function InsaneStats:GetStatusEffectInfo(id)
	return registeredEffects[id]
end

function InsaneStats:DetermineWPASS2Attributes(currentModifiers)
	local wepAttributes = {}
	for k,v in pairs(currentModifiers or {}) do
		for k2,v2 in pairs(modifiers[k] and modifiers[k].modifiers or {}) do
			local startValue = wepAttributes[k2] or attributes[k2].start or 1
			if attributes[k2].mode == 1 then
				wepAttributes[k2] = 1 - (1-startValue) * v2 ^ v
			elseif attributes[k2].mode == 3 then
				wepAttributes[k2] = startValue + v2 * v
			else
				wepAttributes[k2] = startValue * v2 ^ v
			end
		end
	end
	
	for k,v in pairs(wepAttributes) do
		local startValue = attributes[k].start or 1
		local mulValue = attributes[k].mul or 1
		if attributes[k].mode == 2 then
			v = 1 - mulValue * (v - 1)
		elseif attributes[k].mode == 4 then
			v = mulValue * (v - 1)
		else
			-- v = log(1 - 1 / mul) / log(base)
			v = mulValue * (v - 1) + 1
		end

		if v == 1 then -- remove
			wepAttributes[k] = nil
		else
			wepAttributes[k] = v
		end
	end

	return wepAttributes
end

function InsaneStats:ApplyWPASS2Attributes(wep)
	local wepAttributes = self:DetermineWPASS2Attributes(wep.insaneStats_Modifiers)
	local tier = wep.insaneStats_Tier or 0
	if tier ~= 0 then
		wepAttributes.reverse_xp = 1.1 ^ (tier / 2)
	end
	wep:InsaneStats_SetAttributes(wepAttributes)
	hook.Run("InsaneStatsWPASS2AttributesChanged", wep)
end

function InsaneStats:GetEntitiesByStatusEffect(id)
	if id then
		entitiesByStatusEffect[id] = entitiesByStatusEffect[id] or {}
		local entities = {}
		
		for k,v in pairs(entitiesByStatusEffect[id]) do
			if v.expiry >= CurTime() and IsValid(k) then
				table.insert(entities, k)
			else
				entitiesByStatusEffect[id][k] = nil
			end
		end
		
		return entities
	else
		return entitiesByStatusEffect
	end
end

function InsaneStats:GetModifierProbabilities(wep)
	-- the resulting probabilities are used for determining reforge cost when modifiers are blacklisted
	-- by the client, so the client needs to know what modifiers can even be applied!
	local modifiers = self:GetAllModifiers()
	local inclusiveFlags = 0
	local isWep = wep:IsWeapon()
	if not isWep then
		inclusiveFlags = bit.bor(inclusiveFlags, self.WPASS2_FLAGS.ARMOR)
	elseif wep:IsScripted() then
		inclusiveFlags = bit.bor(inclusiveFlags, self.WPASS2_FLAGS.SCRIPTED_ONLY)
	end
	if self:GetConVarValue("xp_enabled") then
		inclusiveFlags = bit.bor(inclusiveFlags, self.WPASS2_FLAGS.XP)
	end
	if game.SinglePlayer() then
		inclusiveFlags = bit.bor(inclusiveFlags, self.WPASS2_FLAGS.SP_ONLY)
	else
		inclusiveFlags = bit.bor(inclusiveFlags, self.WPASS2_FLAGS.MP_ONLY)
	end
	if GetConVar("gmod_suit"):GetBool() then
		inclusiveFlags = bit.bor(inclusiveFlags, self.WPASS2_FLAGS.SUIT_POWER)
	end
	if self:GetConVarValue("infhealth_knockback") then
		inclusiveFlags = bit.bor(inclusiveFlags, self.WPASS2_FLAGS.KNOCKBACK)
	end
	
	local modifierProbabilities = {}
	local blacklistedModifiers = {}
	local invertNegative = false
	for w in string.gmatch(InsaneStats:GetConVarValue("wpass2_modifiers_blacklist"), "%S+") do
		blacklistedModifiers[w] = true
		if w == "!curse" then
			invertNegative = not invertNegative
		end
	end

	local data = {
		negativeWeightMul = InsaneStats:GetConVarValueDefaulted(
			not isWep and "wpass2_modifiers_negativeweight_battery",
			"wpass2_modifiers_negativeweight"
		),
		wep = wep,
		ent = wep:GetOwner()
	}
	hook.Run("InsaneStatsGetModifierProbabilities", data)

	local switchedWeightMul = InsaneStats:GetConVarValueDefaulted(
		not isWep and "wpass2_modifiers_switched_battery",
		"wpass2_modifiers_switched"
	)

	for k,v in pairs(modifiers) do
		local isNegative = (v.cost or 1) < 0
		local flags = v.flags or 0

		local matchesBlacklist = (not blacklistedModifiers[k]) ~= (isNegative and invertNegative)
		local matchesFlags = bit.band(bit.bor(inclusiveFlags, 1), flags) == flags
		local matchesTier = isNegative or (wep.insaneStats_Tier or 0) >= 0
		-- if a modifier DOES NOT have bitflag WPASS2_FLAGS.ARMOR and inclusiveFlags DOES,
		-- do not consider it, and vice versa
		local matchesArmorFlags = bit.band(flags, self.WPASS2_FLAGS.ARMOR) == bit.band(inclusiveFlags, self.WPASS2_FLAGS.ARMOR)

		if matchesBlacklist and matchesFlags and matchesTier then
			local weight = v.weight or 1
			if isNegative then
				weight = weight * data.negativeWeightMul
			end
			if not matchesArmorFlags then
				weight = weight * switchedWeightMul
			end
			modifierProbabilities[k] = weight
		end
	end

	for k,v in pairs(modifierProbabilities) do
		if v <= 0 then modifierProbabilities[k] = nil end
	end

	return modifierProbabilities
end

local ENTITY = FindMetaTable("Entity")

function ENTITY:InsaneStats_SetBatteryXP(xp)
	if isstring(xp) then
		InsaneStats:Log("Battery XP for %s attempted to be set to a string value \"%s\"!", tostring(self), xp)
		InsaneStats:Log("This is a bug, report this if you see this message!")
		debug.Trace()
		xp = tonumber(xp) or math.huge
	end
	self:InsaneStats_SetEntityData("battery_xp", xp)
	if xp then
		self.insaneStats_BatteryXPRoot8 = InsaneStats:CalculateRoot8(xp)
	end
end

function ENTITY:InsaneStats_GetBatteryXP()
	return self:InsaneStats_GetEntityData("battery_xp") or 0
end

function ENTITY:InsaneStats_SetAttributes(attributes)
	return self:InsaneStats_SetEntityData("attributes", attributes)
end

function ENTITY:InsaneStats_GetAttributes()
	return self:InsaneStats_GetEntityData("attributes") or {}
end

local storePos = Vector(16000, 16000, 16000)
function ENTITY:InsaneStats_GetAttributeValue(attribute)
	if InsaneStats:GetConVarValue("wpass2_enabled") and IsValid(self) then
		local totalMul = 1
		local weaponEffectVars = {"wpass2_attributes_other_enabled"}
		local batteryEffectVars = {"wpass2_attributes_other_enabled_battery", "wpass2_attributes_other_enabled"}
		
		if self:IsPlayer() then
			weaponEffectVars = {"wpass2_attributes_player_enabled"}
			batteryEffectVars = {"wpass2_attributes_player_enabled_battery", "wpass2_attributes_player_enabled"}
		elseif self:InsaneStats_GetEntityData("is_ally") ~= self:InsaneStats_GetEntityData("is_enemy") or self.insaneStats_Disposition then
			if self:InsaneStats_GetEntityData("is_ally") or self.insaneStats_Disposition == 3 then
				weaponEffectVars = {"wpass2_attributes_ally_enabled", "wpass2_attributes_other_enabled"}
				batteryEffectVars = {"wpass2_attributes_ally_enabled_battery", "wpass2_attributes_ally_enabled",
				"wpass2_attributes_other_enabled_battery", "wpass2_attributes_other_enabled"}
			elseif self:InsaneStats_GetEntityData("is_enemy") or self.insaneStats_Disposition == 1 then
				weaponEffectVars = {"wpass2_attributes_enemy_enabled", "wpass2_attributes_other_enabled"}
				batteryEffectVars = {"wpass2_attributes_enemy_enabled_battery", "wpass2_attributes_enemy_enabled",
				"wpass2_attributes_other_enabled_battery", "wpass2_attributes_other_enabled"}
			end
		end
		
		local weaponHasEffect = InsaneStats:GetConVarValueDefaulted(weaponEffectVars)
		local armorBatteryHasEffect = InsaneStats:GetConVarValueDefaulted(batteryEffectVars)
		
		if armorBatteryHasEffect > 0 then
			totalMul = totalMul * (self:InsaneStats_GetAttributes()[attribute] or 1)
		end
		
		if weaponHasEffect > 0 then
			local wep = self.GetActiveWeapon and self:GetActiveWeapon()

			if not IsValid(wep) then
				wep = self.insaneStats_ProxyWeapon
			end

			if IsValid(wep) then
				totalMul = totalMul * (wep:InsaneStats_GetAttributes()[attribute] or 1)
			elseif SERVER and self.insaneStats_ProxyWeaponLastTick ~= engine.TickCount() then
				local shouldGive = InsaneStats:GetConVarValue("wpass2_modifiers_other_create")
				if shouldGive < 1 then
					shouldGive = false
				elseif shouldGive < 3 and not self:InsaneStats_IsMob() then
					shouldGive = false
				elseif shouldGive > 1 and not self:InsaneStats_ArmorSensible() then
					shouldGive = false
				end

				if shouldGive then
					local existingProxyWeapons = ents.FindByClass("weapon_base")
					if #existingProxyWeapons > 1000 then
						InsaneStats:Log("WARNING: Over 1000 proxy weapons have been created.")
						InsaneStats:Log("Either insanestats_wpass2_modifiers_other_create is 3, \z
						or there are too many mobs.")

						local copiedProxyWeaponRefs = {}
						for k,v in pairs(existingProxyWeapons) do copiedProxyWeaponRefs[k] = v end
						repeat
							if not next(copiedProxyWeaponRefs) then
								wep = NULL
								break
							end
							local randomIndex = math.random(#copiedProxyWeaponRefs)
							wep = table.remove(copiedProxyWeaponRefs, randomIndex)
						until wep.insaneStats_IsProxyWeapon

						self.insaneStats_ProxyWeapon = wep
						InsaneStats:Log(
							"Binding a random existing proxy weapon (%s) to %s.",
							tostring(wep),
							tostring(self)
						)
					else
						wep = ents.Create("weapon_base")
						wep:SetKeyValue("spawnflags", 3)
						wep:SetPos(storePos)
						wep:Spawn()
						wep:SetMoveType(MOVETYPE_NONE)
						wep:SetNotSolid(true)
						wep:SetNoDraw(true)
						wep.insaneStats_IsProxyWeapon = true
						wep.insaneStats_ProxyWeaponTo = self
						self.insaneStats_ProxyWeapon = wep
					end
				end
				self.insaneStats_ProxyWeaponLastTick = engine.TickCount()
			end
		end
		
		return totalMul
	else return 1
	end
end

function ENTITY:InsaneStats_IsWPASS2Pickup()
	return self:IsWeapon() or self:GetClass() == "item_battery"
end

local healthClasses = {
	item_healthkit = true,
	item_healthvial = true,
	item_grubnugget = true
}
local ammoClasses = {
	item_ammo_357 = true,
	item_ammo_357_large = true,
	item_ammo_ar2 = true,
	item_ammo_ar2_large = true,
	item_ammo_ar2_altfire = true,
	item_ammo_crossbow = true,
	item_ammo_pistol = true,
	item_ammo_pistol_large = true,
	item_ammo_smg1 = true,
	item_ammo_smg1_large = true,
	item_ammo_smg1_grenade = true,
	item_box_buckshot = true,
	item_rpg_round = true,
}
function ENTITY:InsaneStats_IsItem()
	local class = self:GetClass()
	return self:InsaneStats_IsWPASS2Pickup() or healthClasses[class] or ammoClasses[class]
end

local function EntityInitStatusEffects(ent)
	ent.insaneStats_StatusEffects = ent.insaneStats_StatusEffects or {}
	if SERVER then
		ent.insaneStats_StatusEffectsToNetwork = ent.insaneStats_StatusEffectsToNetwork or {}
	end
end

local function DoExpiryEffect(ent, statName)
	if entitiesByStatusEffect[statName] then
		entitiesByStatusEffect[statName][ent] = nil
	end
	local statusData = ent.insaneStats_StatusEffects and ent.insaneStats_StatusEffects[statName]
	if expiryEffects[statName] and statusData then
		expiryEffects[statName](ent, statusData.level or 0, statusData.attacker)
	end
end

function ENTITY:InsaneStats_ApplyStatusEffect(id, level, duration, data)
	if level == 0 then return end
	-- debris cannot get status effects, as it very frequently causes net buffer overflow
	-- FIXME: is there a better solution?
	if self:GetCollisionGroup() == COLLISION_GROUP_DEBRIS and self:GetClass() == "prop_physics" then return end

	EntityInitStatusEffects(self)
	local effectTable = self.insaneStats_StatusEffects[id]
	local changeOccured = false
	local curTime = CurTime()
	
	entitiesByStatusEffect[id] = entitiesByStatusEffect[id] or {}
	
	data = data or {}
	if (effectTable and effectTable.expiry > curTime) and not data.replace then
		if data.amplify then level = level + effectTable.level end
		
		if data.extend and duration ~= 0 then
			local maxDuration = tonumber(data.extend) or math.huge
			local maxExpiry = curTime + maxDuration
			local newExpiry = effectTable.expiry + duration
			if maxExpiry < newExpiry then
				-- amplify effect, multiplied by % of duration lost
				level = effectTable.level + (newExpiry - maxExpiry) / maxDuration * level
				newExpiry = maxExpiry
			end
			effectTable.expiry = newExpiry
			changeOccured = true
		elseif curTime + duration > effectTable.expiry then
			effectTable.expiry = curTime + duration
			changeOccured = true
		end
		
		if level > effectTable.level then
			effectTable.level = level
			changeOccured = true
		end
		
		effectTable.attacker = IsValid(data.attacker) and data.attacker or effectTable.attacker
		
		-- we do this after setting the attacker and level since those as passed as part of DoExpiryEffect
		if effectTable.expiry <= curTime then
			DoExpiryEffect(self, id)
			self.insaneStats_StatusEffects[id] = nil
			changeOccured = true
		end
	else
		local maxDuration = tonumber(data.extend) or math.huge
		if duration > maxDuration then
			level = level * duration / maxDuration
			duration = maxDuration
		end
		self.insaneStats_StatusEffects[id] = {
			expiry = curTime + duration,
			level = level,
			attacker = data.attacker
		}
		entitiesByStatusEffect[id][self] = self.insaneStats_StatusEffects[id]
		changeOccured = true
	end
	
	if SERVER and changeOccured then
		local effectData = registeredEffects[id] or {}
		effectTable = self.insaneStats_StatusEffects[id]
		if effectTable then
			if effectData.apply then
				effectData.apply(
					self, effectTable.level or 0,
					(effectTable.expiry or curTime) - curTime,
					effectTable.attacker
				)
			end
			if effectData.overtime then
				self:InsaneStats_ApplyDoT(id)
			end
		end
		self.insaneStats_StatusEffectsToNetwork[id] = true
		self:InsaneStats_MarkForUpdate(16)
	end
end

function ENTITY:InsaneStats_SetStatusEffectLevel(id, level)
	EntityInitStatusEffects(self)
	local effectTable = self.insaneStats_StatusEffects[id]
	local changeOccured = false
	
	if (effectTable and effectTable.expiry > CurTime()) then
		if level == 0 then
			DoExpiryEffect(self, id)
			self.insaneStats_StatusEffects[id] = nil
			changeOccured = true
		elseif effectTable.level ~= level then
			effectTable.level = level
			changeOccured = true
		end
	end
	
	if SERVER and changeOccured then
		self.insaneStats_StatusEffectsToNetwork[id] = true
		self:InsaneStats_MarkForUpdate(16)
	end
end

function ENTITY:InsaneStats_ClearStatusEffect(id)
	EntityInitStatusEffects(self)
	local effectTable = self.insaneStats_StatusEffects[id]
	
	if (effectTable and effectTable.expiry > CurTime()) then
		DoExpiryEffect(self, id)
		self.insaneStats_StatusEffects[id] = nil
		
		if SERVER then
			self.insaneStats_StatusEffectsToNetwork[id] = true
			self:InsaneStats_MarkForUpdate(16)
		end
	end
end

function ENTITY:InsaneStats_ClearAllStatusEffects()
	EntityInitStatusEffects(self)
	for k,v in pairs(self.insaneStats_StatusEffects) do
		if v.expiry > CurTime() then
			DoExpiryEffect(self, k)
			self.insaneStats_StatusEffects[k] = nil
			if SERVER then
				self.insaneStats_StatusEffectsToNetwork[k] = true
				self:InsaneStats_MarkForUpdate(16)
			end
		end
	end
end

function ENTITY:InsaneStats_GetStatusEffectLevel(id)
	EntityInitStatusEffects(self)
	return self.insaneStats_StatusEffects[id]
	and self.insaneStats_StatusEffects[id].expiry >= CurTime()
	and self.insaneStats_StatusEffects[id].level
	or 0
end

function ENTITY:InsaneStats_GetStatusEffectDuration(id)
	EntityInitStatusEffects(self)
	return self.insaneStats_StatusEffects[id]
	and self.insaneStats_StatusEffects[id].expiry >= CurTime()
	and self.insaneStats_StatusEffects[id].expiry - CurTime()
	or 0
end

function ENTITY:InsaneStats_GetStatusEffectAttacker(id)
	EntityInitStatusEffects(self)
	return self.insaneStats_StatusEffects[id]
	and self.insaneStats_StatusEffects[id].expiry >= CurTime()
	and self.insaneStats_StatusEffects[id].attacker
end

--[[function ENTITY:InsaneStats_GetStatusEffectCountByType(typ)
	EntityInitStatusEffects(self)
	local count = 0
	for k,v in pairs(self.insaneStats_StatusEffects) do
		if v.typ == typ then
			count = count + 1
		end
	end
	return count
end]]

function ENTITY:InsaneStats_ClearStatusEffectsByType(typ)
	EntityInitStatusEffects(self)
	for k,v in pairs(self.insaneStats_StatusEffects) do
		local statusEffectInfo = registeredEffects[k]
		if statusEffectInfo.typ == typ and v.expiry > CurTime() then
			DoExpiryEffect(self, k)
			self.insaneStats_StatusEffects[k] = nil
			if SERVER then
				self.insaneStats_StatusEffectsToNetwork[k] = true
				self:InsaneStats_MarkForUpdate(16)
			end
		end
	end
end

hook.Add("Think", "InsaneStatsSharedWPASS", function()
	CheckOverrideWeapons()
	
	for stat, expiryFunc in pairs(expiryEffects) do
		for k,v in pairs(entitiesByStatusEffect[stat] or {}) do
			if IsValid(k) and v.expiry <= CurTime() then
				DoExpiryEffect(k, stat)
				k.insaneStats_StatusEffects[stat] = nil
			end
		end
	end

	if SERVER then
		for ply, ammoAdjsToUpdate in pairs(playerAmmosToUpdateAdjs) do
			net.Start("insane_stats")
			net.WriteUInt(13, 8)
			net.WriteBool(ammoAdjsToUpdate.clear or false)
			if not ammoAdjsToUpdate.clear then
				local toSend = {}
				for k,v in pairs(ammoAdjsToUpdate) do
					table.insert(toSend, {k, ply.insaneStats_AmmoAdjs[k]})
				end
				net.WriteUInt(#toSend, 16)
				for i,v in ipairs(toSend) do
					net.WriteUInt(v[1], 16)
					net.WriteDouble(v[2])
				end
			end
			net.Send(ply)
		end
	end

	playerAmmosToUpdateAdjs = {}
end)

hook.Add("PlayerSpawn", "InsaneStatsSharedWPASS", function(ply)
	playerAmmosToUpdateAdjs[ply] = {}
	for k,v in pairs(ply.insaneStats_AmmoAdjs or {}) do
		playerAmmosToUpdateAdjs[ply][k] = true
	end
end)