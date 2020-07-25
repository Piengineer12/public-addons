ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Huge Cargo Container"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_wasteland/cargo_container01.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 5
ENT.ContainerConstants = {
	Mass = 40000,
	Volume = 13500
}
ENT.OpenSounds = {Sound("doors/door_metal_gate_move1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_rusty_move1.wav")}