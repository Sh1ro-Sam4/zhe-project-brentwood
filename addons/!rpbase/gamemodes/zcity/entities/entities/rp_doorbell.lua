AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Category 			= "RP"
ENT.PrintName       = "Дверной звонок"
ENT.Contact			= "Steam"
ENT.Spawnable			= true
ENT.AdminSpawnable		= true

local delay = 1
local shouldOccur = true

function ENT:Use( activator, caller )
	if shouldOccur then
		activator:EmitSound("House/doorbell2.wav", 100, 100)
		shouldOccur = false
		timer.Simple( delay, function() shouldOccur = true end )
	else
	end
end

function ENT:Initialize()

	self.Entity:SetModel("models/Doorbell/doorbell1.mdl")
 
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	
	self.Index = self.Entity:EntIndex()
	
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

