ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Large Fridge"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_wasteland/kitchen_fridge001a.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 10
ENT.ContainerConstants = {
	Mass = 2040,
	Volume = 700
}
ENT.OpenSounds = {Sound("doors/door_metal_large_open1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_large_close2.wav")}