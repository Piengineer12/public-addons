ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Fridge"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_c17/FurnitureFridge001a.mdl")
ENT.Spawnable = true
ENT.ContainerConstants = {
	Mass = 250,
	Volume = 98
}
ENT.OpenSounds = {Sound("doors/door_metal_medium_open1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_medium_close1.wav")}