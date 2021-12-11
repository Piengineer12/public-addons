AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Builder"
PLAYER.WalkSpeed			= 200
PLAYER.RunSpeed				= 400

function PLAYER:Loadout()
	self.Player:Give("rotgb_control")
	if hook.Run("GetSkillAmount", "physgun") then
		self.Player:Give("weapon_physgun")
	end
end

player_manager.RegisterClass("Builder", PLAYER, "player_default")