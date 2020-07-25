ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Laundry Tumbler"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_wasteland/laundry_washer003.mdl")
ENT.Spawnable = true
ENT.ContainerConstants = {
	Mass = 5500,
	Volume = 500
}
ENT.OpenSounds = {Sound("doors/door_metal_thin_open1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_thin_close2.wav")}