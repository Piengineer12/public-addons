ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Scientific Jar"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_lab/jar01a.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 2
ENT.ContainerConstants = {
	Mass = 2.5,
	Volume = 2
}
ENT.OpenSounds = {Sound("physics/plastic/plastic_barrel_impact_soft6.wav")}
ENT.CloseSounds = {Sound("physics/plastic/plastic_barrel_impact_soft5.wav")}