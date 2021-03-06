ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Vending Machine"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_interiors/VendingMachineSoda01a.mdl")
ENT.Spawnable = true
ENT.ContainerConstants = {
	Mass = 600,
	Volume = 400
}
ENT.OpenSounds = {Sound("doors/door_metal_medium_open1.wav")}
ENT.CloseSounds = {Sound("doors/door_metal_medium_close1.wav")}