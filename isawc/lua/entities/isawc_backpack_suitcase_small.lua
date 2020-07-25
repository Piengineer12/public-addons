ENT.Base = "isawc_backpack_base"
ENT.Type = "anim"
ENT.PrintName = "Small Suitcase"
ENT.Category = "Backpacks - HL2"

AddCSLuaFile()

ENT.BackpackModel = Model("models/props_c17/SuitCase_Passenger_Physics.mdl")
ENT.Spawnable = true
ENT.BackpackMassMul = 3
ENT.BackpackConstants = {
	Mass = 6,
	Volume = 5
}