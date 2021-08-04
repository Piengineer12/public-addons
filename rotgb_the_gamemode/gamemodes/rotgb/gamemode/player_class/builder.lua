AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Builder"
PLAYER.WalkSpeed			= 200
PLAYER.RunSpeed				= 400

function PLAYER:Loadout()
	self.Player:Give("rotgb_control")
end

player_manager.RegisterClass("Builder", PLAYER, "player_default")