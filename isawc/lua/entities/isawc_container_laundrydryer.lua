ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Laundry Dryer"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_wasteland/laundry_dryer001.mdl")
ENT.Spawnable = true
ENT.ContainerVolumeMul = 0.5
ENT.ContainerConstants = {
	Mass = 3500,
	Volume = 400
}
ENT.OpenSounds = {Sound("doors/door_metal_medium_open1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_medium_close1.wav")}