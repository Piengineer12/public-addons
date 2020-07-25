ENT.Base = "isawc_backpack_base"
ENT.Type = "anim"
ENT.PrintName = "Backpack"
ENT.Category = "Backpacks - FO3"

AddCSLuaFile()

ENT.BackpackModel = Model("models/fallout 3/campish_pack.mdl")
ENT.Spawnable = util.IsValidModel(ENT.BackpackModel)
ENT.BackpackMassMul = 0.1
ENT.BackpackConstants = {
	Mass = 150,
	Volume = 20
}