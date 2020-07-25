ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Chest (Old)"
ENT.Category = "Containers - MC"

AddCSLuaFile()

ENT.ContainerModel = Model("models/mcmodelpack/blocks/chest.mdl")
ENT.Spawnable = util.IsValidModel("models/mcmodelpack/blocks/chest.mdl")
ENT.ContainerMassMul = 3
ENT.ContainerConstants = {
	Mass = 90,
	Volume = 100
}
ENT.OpenSounds = {Sound("chest/open.wav")}
ENT.CloseSounds = {Sound("chest/close.wav"),Sound("chest/close2.wav"),Sound("chest/close3.wav")}