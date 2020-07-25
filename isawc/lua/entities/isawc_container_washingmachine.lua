ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Washing Machine"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_c17/FurnitureWashingmachine001a.mdl")
ENT.Spawnable = true
ENT.ContainerVolumeMul = 1/2
ENT.ContainerConstants = {
	Mass = 275,
	Volume = 30
}
ENT.OpenSounds = {Sound("doors/door_metal_thin_open1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_thin_close2.wav")}