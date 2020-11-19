--[[															// delete this line.

// Implementation Tutorial:										// delete this line.

AddCSLuaFile() 													// don't touch this.
ENT.Base = "gballoon_tower_base"								// don't touch this.
ENT.Type = "anim"												// don't touch this.
ENT.PrintName = "Custom Tower ($100)"							// specify a string as the tower name.
ENT.Category = "RotgB: Towers"									// optional: specify a string as the custom category.
ENT.Author = "Piengineer"										// replace "Piengineer" with yourself.
ENT.Contact = "http://steamcommunity.com/id/Piengineer12/"		// replace this string with your own contact link.
ENT.Purpose = ""												// optional: specify a string as the purpose.
ENT.Instructions = ""											// optional: specify a string as the instructions.
ENT.Spawnable = true											// don't touch this.
ENT.AdminOnly = false											// don't touch this.
ENT.RenderGroup = RENDERGROUP_BOTH								// don't touch this.
ENT.Model = Model("models/props_phx/empty_barrel.mdl")			// replace "models/props_phx/empty_barrel.mdl" with another model if you want to.
ENT.FireRate = 1												// tower fire rate (how often ENT:FireFunction() gets called). default: 1
ENT.Cost = 100													// base tower cost. default: 0
ENT.DetectionRadius = 256										// tower radius. 
ENT.InfiniteRange = false										// whether the tower has infinite range or not. The tower's range will be displayed in blue instead of aqua. default: false
ENT.InfiniteRange2 = false										// similar, except range display color is not affected. default: false
ENT.AttackDamage = 10											// tower attack damage (may be increased by other towers), should be 10 damage per layer in your code.
ENT.UseLOS = true												// only visible gBalloons are passed to ENT:FireFunction(). default: false
ENT.LOSOffset = Vector(0,0,0)									// offset for line-of-sight checks, passed as argument to ENT:LocalToWorld(), therefore should be the same as firing position. default: vector_origin
ENT.UserTargeting = true										// enables the user to set the tower's targeting (visual UI change only). default: false
ENT.FireWhenNoEnemies = false									// The tower will still fire and run ENT:FireFunction() even when there are no enemies. Use table.IsEmpty(tableOfBalloons) to check if an enemy is present. default: false
ENT.SeeCamo = false												// whether ENT:FireFunction() will also pass hidden balloons or not. default: false
ENT.HasAbility = false											// whether the tower has an active ability or not. The active ability is activated by shooting at the tower, which calls ENT:TriggerAbility(). default: false
ENT.AbilityCooldown = 30										// delay between active ability activations.
ENT.rotgb_Var2 = true											// optional: additional variables. Prefixing with rotgb_ is recommended.
ENT.rotgb_BeamTime = 1											// optional: additional variables. Prefixing with rotgb_ is recommended.
ENT.UpgradeReference = {
	{															// each table specifies an upgrade path
		Names = {"Range Up"},
		Descs = {
			"Increases the tower's range."
		},
		Prices = {200},
		Funcs = {
			function(self)
				self.DetectionRadius = self.DetectionRadius*2	// you can modify basic tower properties here - it will still work as expected.
			end
		}
	},
	{
		Names = {"Speed Up","Damage Up","Good Eyes"},			// make sure #Names == #Descs == #Prices == #Functions!
		Descs = {
			"Increases the tower's fire rate.",					// one for each upgrade in the path.
			"Increases damage dealt the by tower.",
			"Allows the tower to see Hidden gBalloons."
		},
		Prices = {300,500,600},
		Funcs = {
			function(self)
				self.FireRate = self.FireRate*2
			end,
			function(self)
				self.AttackDamage = self.AttackDamage*2
			end,
			function(self)
				self.SeeCamo = true
			end
		}
	}
}
ENT.UpgradeLimits = {2,0}										// upgrade limit ({4,2} in BTD5 and {5,2,0} in BTD6). {2,0} means that only one path can be upgraded up to twice. Make sure to sort from highest to lowest!

function ENT:FireFunction(tableOfBalloons)						// since self.SeeCamo is false, only non-hidden gBalloons will be passed here, unless the tower is an X-3.
	tableOfBalloons[1]:TakeDamage(self.AttackDamage,self,self)	// edit the body of the function however you want.
end																// tableOfBalloons is all balloons in its radius, sorted by the player.

list.Set("NPC","gballoon_tower_readme",{						// replace "gballoon_tower_readme" with your tower class.
	Name = ENT.PrintName,										// don't touch this.
	Class = "gballoon_tower_readme",							// replace "gballoon_tower_readme" with your tower class.
	Category = ENT.Category										// don't touch this.
})																// don't touch this.

]]																// delete this line.