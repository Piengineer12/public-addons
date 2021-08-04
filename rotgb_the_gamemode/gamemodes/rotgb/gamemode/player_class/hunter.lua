AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Hunter"
PLAYER.WalkSpeed			= 200
PLAYER.RunSpeed				= 400

function PLAYER:Loadout()
	self.Player:Give("rotgb_shooter")
end

player_manager.RegisterClass("Hunter", PLAYER, "player_default")