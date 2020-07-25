ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Backpack"
ENT.Category = "Containers - FO3"

AddCSLuaFile()

ENT.ContainerModel = Model("models/fallout 3/campish_pack.mdl")
ENT.Spawnable = util.IsValidModel(ENT.ContainerModel)
ENT.ContainerMassMul = 0.1
ENT.ContainerConstants = {
	Mass = 150,
	Volume = 20
}
ENT.OpenSounds = {Sound("physics/cardboard/cardboard_box_shake3.wav")}
ENT.CloseSounds = {Sound("physics/cardboard/cardboard_box_shake2.wav")}