ENT.Base = "isawc_container_base"
ENT.Type = "anim"
ENT.PrintName = "Dumpster"
ENT.Category = "Containers - HL2"

AddCSLuaFile()

ENT.ContainerModel = Model("models/props_junk/TrashDumpster01a.mdl")
ENT.Spawnable = true
ENT.ContainerMassMul = 3
ENT.ContainerConstants = {
	Mass = 1350,
	Volume = 310
}
ENT.OpenSounds = {Sound("doors/vent_open1.wav")}
ENT.CloseSounds = {Sound("doors/vent_open2.wav")}