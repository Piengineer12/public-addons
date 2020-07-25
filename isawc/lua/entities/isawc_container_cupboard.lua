ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Cupboard"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_c17/FurnitureCupboard001a.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 0.1
ENT.ContainerConstants = {
	Mass = 50,
	Volume = 28
}
ENT.OpenSounds = {Sound("doors/door1_move.wav")}
ENT.CloseSounds = {Sound("doors/door1_stop.wav")}