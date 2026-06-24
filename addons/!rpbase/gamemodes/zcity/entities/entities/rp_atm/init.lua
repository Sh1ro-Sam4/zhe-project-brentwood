AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

function ENT:BreakOpen(ply)
	local m = ents.Create("rp_money")
	m:SetPos(self:GetPos() + (self:GetForward()*35) + (self:GetUp()*30) )
	m:Spawn()
	m:Setamount(math.random(500,1250))
end

function ENT:Initialize()
	self.BreakOpenHealthMax = 10
	self.BreakOpenHealth = 10
	self.BreakOpenBroken = false

	self:SetModel("models/props_unique/atm01.mdl")
	
	self:PhysicsInit(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end