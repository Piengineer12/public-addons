ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Vanity Table"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_interiors/Furniture_Vanity01a.mdl")
ENT.Spawnable = true
ENT.ContainerVolumeMul = 0.5
ENT.ContainerConstants = {
	Mass = 100,
	Volume = 9
}
ENT.OpenSounds = {Sound("doors/generic_door_open.wav")}
ENT.CloseSounds = {Sound("doors/generic_door_close.wav")}