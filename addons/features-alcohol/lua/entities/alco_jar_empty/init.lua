AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()

	self:SetModel("models/props_junk/glassjug01.mdl")

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
end

function ENT:PhysicsCollide(data, phys)
	local ent = data.HitEntity
	if data.Speed > 500 and ent:GetClass() != "alco_povovarna" then
		self:EmitSound("physics/glass/glass_bottle_break"..math.random(1, 2)..".wav")
		self:Remove()
	end
end