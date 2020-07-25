ENT.Base = "isawc_backpack_base"
ENT.Type = "anim"
ENT.PrintName = "Briefcase"
ENT.Category = "Backpacks - HL2"

AddCSLuaFile()

ENT.BackpackModel = Model("models/props_c17/BriefCase001a.mdl")
ENT.Spawnable = true
ENT.BackpackMassMul = 2
ENT.BackpackConstants = {
	Mass = 6,
	Volume = 3
}