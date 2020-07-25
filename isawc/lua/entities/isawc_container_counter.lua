ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Kitchen Counter"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_wasteland/kitchen_counter001c.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 3
ENT.ContainerConstants = {
	Mass = 900,
	Volume = 350
}
ENT.OpenSounds = {Sound("doors/door_metal_thin_open1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_thin_close2.wav")}