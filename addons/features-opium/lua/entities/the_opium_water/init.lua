AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/garbage_plasticbottle003a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():Wake()
	self:SetHP(opium.ahshop.WaterHealth)
end

function ENT:OnTakeDamage( dmg )
	self:SetHP( ( self:GetHP() or 100 ) - dmg:GetDamage() )
    if ( self:GetHP() <= 0 ) then
		self:Remove()
  	end
end
