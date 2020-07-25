ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Small Drawer"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_c17/FurnitureDrawer002a.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 1.5
ENT.ContainerConstants = {
	Mass = 20,
	Volume = 8.5
}
ENT.OpenSounds = {Sound("doors/generic_door_open.wav")}
ENT.CloseSounds = {Sound("doors/generic_door_close.wav")}