ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Box 4"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_junk/cardboard_box002b.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 3
ENT.ContainerConstants = {
	Mass = 15,
	Volume = 68
}
ENT.OpenSounds = {Sound("physics/cardboard/cardboard_box_impact_soft5.wav")}
ENT.CloseSounds = {Sound("physics/cardboard/cardboard_box_impact_soft7.wav")}