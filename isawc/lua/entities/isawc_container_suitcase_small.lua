ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Small Suitcase"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_c17/SuitCase_Passenger_Physics.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 3
ENT.ContainerConstants = {
	Mass = 30,
	Volume = 5
}
ENT.OpenSounds = {Sound("doors/generic_door_open.wav")}
ENT.CloseSounds = {Sound("doors/generic_door_close.wav")}