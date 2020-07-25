ENT.Base = "isawc_backpack_base"
ENT.Type = "anim"
ENT.PrintName = "Suitcase"
ENT.Category = "Backpacks - HL2"

AddCSLuaFile()

ENT.BackpackModel = Model("models/props_c17/SuitCase001a.mdl")
ENT.Spawnable = true
ENT.BackpackMassMul = 3
ENT.BackpackConstants = {
	Mass = 9,
	Volume = 10
}