ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Oil Drum"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_c17/oildrum001.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 3
ENT.ContainerConstants = {
	Mass = 90,
	Volume = 55
}
ENT.OpenSounds = {Sound("doors/door_screen_move1.wav")}
ENT.CloseSounds = {Sound("doors/door_squeek1.wav")}