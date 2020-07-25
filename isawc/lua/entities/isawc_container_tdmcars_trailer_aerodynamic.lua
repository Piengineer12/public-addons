ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Aerodynamic Trailer"
ENT.Category = "Containers - TDMCars"

AddCSLuaFile()

ENT.ContainerModel = Model("models/tdmcars/trailers/aerodynamic.mdl")
ENT.Spawnable = util.IsValidModel(ENT.ContainerModel)
ENT.ContainerMassMul = 4
ENT.ContainerConstants = {
	Mass = 6000,
	Volume = 30000
}
ENT.OpenSounds = {Sound("doors/door_metal_gate_move1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_rusty_move1.wav")}