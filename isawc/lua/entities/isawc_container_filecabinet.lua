ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "File Cabinet"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_lab/filecabinet02.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 3
ENT.ContainerConstants = {
	Mass = 225,
	Volume = 40
}
ENT.OpenSounds = {Sound("doors/door_metal_thin_open1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_thin_close2.wav")}