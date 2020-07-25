ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Cash Register"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_c17/cashregister01a.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 2
ENT.ContainerConstants = {
	Mass = 25,
	Volume = 9.5
}
ENT.OpenSounds = {Sound("doors/door_metal_thin_open1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_thin_close2.wav")}