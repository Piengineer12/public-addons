ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Item Crate"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/items/item_item_crate.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 3
ENT.ContainerConstants = {
	Mass = 45,
	Volume = 50
}
ENT.OpenSounds = {Sound("doors/door1_move.wav")}
ENT.CloseSounds = {Sound("doors/door1_stop.wav")}