ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Laundry Washer"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_wasteland/laundry_washer001a.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 2
ENT.ContainerConstants = {
	Mass = 3000,
	Volume = 1200
}
ENT.OpenSounds = {Sound("doors/door_metal_medium_open1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_medium_close1.wav")}