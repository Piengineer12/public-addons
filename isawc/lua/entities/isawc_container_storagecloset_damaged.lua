ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Damaged Storage Closet"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_wasteland/controlroom_storagecloset001b.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 3
ENT.ContainerConstants = {
	Mass = 2400,
	Volume = 270
}
ENT.OpenSounds = {Sound("doors/metal_move1.wav")}
ENT.CloseSounds = {Sound("doors/metal_stop1.wav")}