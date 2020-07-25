ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Stove"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_c17/furnitureStove001a.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 3
ENT.ContainerVolumeMul = 1/3
ENT.ContainerConstants = {
	Mass = 4500,
	Volume = 44
}
ENT.OpenSounds = {Sound("doors/door_metal_thin_open1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_thin_close2.wav")}