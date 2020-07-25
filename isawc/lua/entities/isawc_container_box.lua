ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Crate"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_junk/wood_crate001a.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 3
ENT.ContainerConstants = {
	Mass = 90,
	Volume = 130
}
ENT.OpenSounds = {Sound("doors/door1_move.wav")}
ENT.CloseSounds = {Sound("doors/door1_stop.wav")}