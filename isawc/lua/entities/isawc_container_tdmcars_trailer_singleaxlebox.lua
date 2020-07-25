ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Single-Axle Box"
ENT.Category = "Containers - TDMCars"

AddCSLuaFile()

ENT.ContainerModel = Model("models/tdmcars/trailers/singleaxlebox.mdl")
ENT.Spawnable = util.IsValidModel(ENT.ContainerModel)
ENT.ContainerMassMul = 5
ENT.ContainerConstants = {
	Mass = 7500,
	Volume = 5000
}
ENT.OpenSounds = {Sound("doors/door_metal_gate_move1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_rusty_move1.wav")}