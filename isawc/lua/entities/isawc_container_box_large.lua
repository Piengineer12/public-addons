ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Large Crate"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_junk/wood_crate002a.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 3
ENT.ContainerConstants = {
	Mass = 180,
	Volume = 220
}
ENT.OpenSounds = {Sound("doors/door1_move.wav")}
ENT.CloseSounds = {Sound("doors/door1_stop.wav")}