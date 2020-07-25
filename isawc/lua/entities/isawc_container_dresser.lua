ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Dresser"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_c17/FurnitureDresser001a.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 2.5
ENT.ContainerConstants = {
	Mass = 375,
	Volume = 230
}
ENT.OpenSounds = {Sound("doors/wood_move1.wav")}
ENT.CloseSounds = {Sound("doors/wood_stop1.wav")}