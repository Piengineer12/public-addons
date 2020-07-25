ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Big Drawer"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_c17/FurnitureDrawer001a.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 2
ENT.ContainerConstants = {
	Mass = 40,
	Volume = 80
}
ENT.OpenSounds = {Sound("doors/generic_door_open.wav")}
ENT.CloseSounds = {Sound("doors/generic_door_close.wav")}