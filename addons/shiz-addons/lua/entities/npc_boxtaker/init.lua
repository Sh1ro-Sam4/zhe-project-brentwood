AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
 
function ENT:Initialize()
 
	self:SetModel( "models/Characters/Hostage_02.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetHullSizeNormal()

	self:CapabilitiesAdd(bit.bor(CAP_ANIMATEDFACE, CAP_TURN_HEAD))
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()

	self:SetMaxYawSpeed(90)
	self:SetSequence("idle")
end

function ENT:AcceptInput(ply, caller)
	local sell = math.random( 150, 300 )
    if IsValid( caller ) and caller:IsPlayer() then
		if(caller:GetNWBool("MRPJobBoxSystem") == true) then
			caller:SetNWBool("MRPJobBoxSystem",false)
			caller:AddMoney(sell)
			DarkRP.notify(caller, 1, 4, "Кладовщик дал вам за эту коробку "..shizlib.FormatMoney(sell))
		end
	end
end
 
function ENT:Think()

end
 