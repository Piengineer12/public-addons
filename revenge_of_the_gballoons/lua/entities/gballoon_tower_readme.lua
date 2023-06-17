--[[																			-- delete this line.

-- This file shows how you can implement your own tower.						-- delete this line.

AddCSLuaFile() 																	-- don't touch this.
ENT.Base = "gballoon_tower_base"												-- don't touch this.
ENT.Type = "anim"																-- don't touch this.
ENT.PrintName = "Custom Tower"													-- tower name, can't be a localization string as the spawnmenu isn't dynamic.
ENT.Category = "#rotgb.category.tower"											-- optional: specify a string as the custom category.
ENT.Author = "Piengineer12"														-- replace "Piengineer12" with yourself.
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"						-- replace this string with your own contact link.
ENT.Purpose = "#rotgb.tower.gballoon_tower_readme.purpose"						-- replace gballoon_tower_readme with your tower class.
ENT.Instructions = ""															-- optional: specify a string as the instructions.
ENT.Spawnable = false															-- don't touch this, the addon will add your entity to the spawnmenu automatically.
ENT.AdminOnly = false															-- don't touch this.
ENT.RenderGroup = RENDERGROUP_BOTH												-- don't touch this.
ENT.Model = Model("models/props_phx/empty_barrel.mdl")							-- replace "models/props_phx/empty_barrel.mdl" with another model if you want to.
ENT.IsChessPiece = false														-- whether this tower qualifies as a chess tower or not. default: false
ENT.IsWaterTower = false														-- whether this tower can only be placed over water. default: false
ENT.FireRate = 1																-- tower fire rate (how often ENT:FireFunction() gets called). default: 1
ENT.MaxFireRate = math.huge														-- maximum tower fire rate, useful in cases where very rapid ENT:FireFunction() calls would cause a crash. default: math.huge
ENT.Cost = 125																	-- base tower cost. default: 0
ENT.DetectionRadius = 256														-- tower radius.
ENT.InfiniteRange = false														-- whether the tower has infinite range or not. The tower's range will be displayed in blue instead of aqua. default: false
ENT.InfiniteRange2 = false														-- similar, except range display color is not affected. default: false
ENT.AttackDamage = 10															-- tower attack damage, may be increased by other towers. 10 = 1 layer, 20 = 2 layers, and so on.
ENT.ProjectileSize = 0															-- tower projectile size, may be increased by other towers. Meaningless on hitscan towers. default: 0
ENT.UseLOS = true																-- only gBalloons visible via line-of-sight are passed to ENT:FireFunction(). default: false
ENT.LOSOffset = Vector(0,0,24)													-- relative offset for line-of-sight checks, ideally should be the same as firing position. default: vector_origin
ENT.UserTargeting = true														-- allows the user to set the tower's targeting. default: false
ENT.FireWhenNoEnemies = false													-- The tower will still fire and run ENT:FireFunction() even when there are no enemies. Use table.IsEmpty(tableOfBalloons) to check if an enemy is present. default: false
ENT.SeeCamo = false																-- whether ENT:FireFunction() will also pass Hidden gBalloons or not. default: false
ENT.HasAbility = false															-- whether the tower has an active ability or not. The active ability is activated by shooting at the tower, which calls ENT:TriggerAbility(). default: false
ENT.AbilityCooldown = 30														-- delay between active ability activations, this includes the duration of the active ability iself. default: 0
ENT.AbilityDuration = 15														-- how long the active ability lasts. default: 0
ENT.rotgb_Var2 = true															-- optional: additional variables. Prefixing with rotgb_ is recommended.
ENT.rotgb_BeamTime = 1															-- optional: additional variables. Prefixing with rotgb_ is recommended.
ENT.UpgradeReference = {
	{																			-- each table specifies an upgrade path
		Prices = {100},
		Funcs = {
			function(ent)
				ent.DetectionRadius = ent.DetectionRadius*2						-- you can modify basic tower properties here - it will work as expected.
				ent.rotgb_Var2 = false											-- you need to specify what the additional variables do in your code. They will be available and updated on both client and server.
			end
		}
	},
	{
		Prices = {100,200,500,900},												-- make sure #Prices == #Funcs!
		Funcs = {																-- one for each upgrade in the path.
			function(ent)
				ent.FireRate = ent.FireRate*2
			end,
			function(ent)
				ent.AttackDamage = ent.AttackDamage + 10
			end,
			function(ent)
				ent.SeeCamo = true
			end,
			function(ent)
				ent.HasAbility = true
			end
		},
		FusionRequirements = {[4] = true}										-- FusionRequirements specifies that this path has a fusion upgrade. [4] means that the fourth upgrade requires Infinity Fusion.
	}
}
ENT.UpgradeLimits = {4,0}														-- upgrade limit ({4,2} in BTD5 and {5,2,0} in BTD6). {4,0} means that only one path can be upgraded up to four times. Make sure to sort from highest to lowest!

function ENT:FireFunction(tableOfBalloons, excessFireRateMultiplier)			-- since self.SeeCamo is false, only non-hidden gBalloons will be passed here, unless the tower is an X-3.
	tableOfBalloons[1]:TakeDamage(												-- edit the body of ENT:FireFunction() however you want.
		self.AttackDamage,														-- tableOfBalloons is all gBalloons in its radius, order of entries is determined by the player.
		self:GetTowerOwner(),													-- ENT:GetTowerOwner() returns the player that owns this tower.
		self																	-- excessFireRateMultiplier should be used to multiply damage dealt - it will either be ENT.FireRate / ENT.MaxFireRate or 1, whichever is greater.
	)																			-- returning true in this function will cause it to be called again in the next frame, which is useful for cancelling attacks.
end	

function ENT:TriggerAbility()													-- called when the tower's active ability is activated.
	self:AddDelayedActions(self, "ROTGB_TOWER_README", 0, function(tower)		-- ENT:AddDelayedActions() takes the tower giving the actions, unique identifier (to prevent buff stacking), then every odd argument is the time and every even argument is the action to apply.
		tower.FireRate = tower.FireRate * 5 * (1 + tower.FusionPower / 100)		-- returning true in ENT.TriggerAbility will skip ability recharging, which is useful for cancelling ability activations.
		tower.AttackDamage = tower.AttackDamage + 20 * tower.FusionPower / 100	-- Infinity Power is stored in self.FusionPower. self.FusionPower is always 0 until tower fusion happens.
	end, 15, function(tower)
		tower.FireRate = tower.FireRate / 5 * (1 + tower.FusionPower / 100)
		tower.AttackDamage = tower.AttackDamage - 20 * tower.FusionPower / 100
	end)
end

]]																				-- delete this line.

--[[
ADDITIONAL NOTES:

You must also have .properties localization files, see https://wiki.facepunch.com/gmod/Addon_Localization for an introduction.
You can find a sample under `revenge_of_the_gballoons/resource/localization/en/rotgb_tower_readme.properties`.
]]