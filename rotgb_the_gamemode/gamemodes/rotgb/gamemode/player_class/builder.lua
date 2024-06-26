AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "#rotgb_tg.teams.builder.name"
PLAYER.WalkSpeed			= 200
PLAYER.RunSpeed				= 400

function PLAYER:Loadout()
	self.Player:Give("rotgb_control")
	if hook.Run("GetSkillAmount", "physgun") > 0 then
		self.Player:Give("weapon_physgun")
	end
end

player_manager.RegisterClass("Builder", PLAYER, "player_default")