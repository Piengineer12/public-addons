ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Kitchen Stoves"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_wasteland/kitchen_stove001a.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 10
ENT.ContainerConstants = {
	Mass = 850,
	Volume = 180
}
ENT.OpenSounds = {Sound("doors/door_metal_thin_open1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_thin_close2.wav")}