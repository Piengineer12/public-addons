ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Large Chest (Old)"
ENT.Category = "Containers - MC"

AddCSLuaFile()

ENT.ContainerModel = Model("models/mcmodelpack/other_blocks/bigchest.mdl")
ENT.Spawnable = util.IsValidModel("models/mcmodelpack/other_blocks/bigchest.mdl")
ENT.ContainerMassMul = 3
ENT.ContainerConstants = {
	Mass = 150,
	Volume = 200
}
ENT.OpenSounds = {Sound("chest/open.wav")}
ENT.CloseSounds = {Sound("chest/close.wav"),Sound("chest/close2.wav"),Sound("chest/close3.wav")}