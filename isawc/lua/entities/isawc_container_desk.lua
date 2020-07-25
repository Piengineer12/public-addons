ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Desk"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_interiors/Furniture_Desk01a.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 1.5
ENT.ContainerConstants = {
	Mass = 150,
	Volume = 65
}
ENT.OpenSounds = {Sound("doors/generic_door_open.wav")}
ENT.CloseSounds = {Sound("doors/generic_door_close.wav")}