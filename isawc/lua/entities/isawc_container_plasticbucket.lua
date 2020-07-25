ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Plastic Bucket"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_junk/plasticbucket001a.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 2
ENT.ContainerConstants = {
	Mass = 40,
	Volume = 6
}
ENT.OpenSounds = {Sound("physics/plastic/plastic_barrel_impact_soft6.wav")}
ENT.CloseSounds = {Sound("physics/plastic/plastic_barrel_impact_soft5.wav")}