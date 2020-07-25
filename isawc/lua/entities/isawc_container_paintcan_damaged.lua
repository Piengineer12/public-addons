ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Damaged Paint Can"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_junk/metal_paintcan001b.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 5
ENT.ContainerConstants = {
	Mass = 35,
	Volume = 2
}
ENT.OpenSounds = {Sound("doors/door_metal_thin_open1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_thin_close2.wav")}