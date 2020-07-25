ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Lockers"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_c17/Lockers001a.mdl")
ENT.Spawnable = true
ENT.ContainerConstants = {
	Mass = 500,
	Volume = 105
}
ENT.OpenSounds = {Sound("doors/door_metal_large_open1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_large_close2.wav")}