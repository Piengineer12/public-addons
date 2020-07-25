ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Breen's Desk"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_combine/breendesk.mdl")
ENT.Spawnable = true
ENT.ContainerConstants = {
	Mass = 1000,
	Volume = 165
}
ENT.OpenSounds = {Sound("doors/generic_door_open.wav")}
ENT.CloseSounds = {Sound("doors/generic_door_close.wav")}