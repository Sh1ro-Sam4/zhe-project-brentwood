AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
 
function ENT:Initialize()
 
	self:SetModel( "models/props_junk/cardboard_box003b.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:AcceptInput(ply, caller)
    if IsValid( caller ) and caller:IsPlayer() then
		if(caller:GetNWBool("MRPJobBoxSystem") == false) then
			caller:SetNWBool("MRPJobBoxSystem",true)
			DarkRP.notify(caller, 1, 4, "Вы взяли коробку.")
		end
	end
end
 
function ENT:Think()

end
 