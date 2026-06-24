AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/gman_high.mdl");
	self:SetHullType(HULL_HUMAN);
	self:SetHullSizeNormal();
	self:SetNPCState(NPC_STATE_SCRIPT);
	self:SetSolid(SOLID_BBOX);
	self:CapabilitiesAdd(CAP_ANIMATEDFACE);
	self:CapabilitiesAdd(CAP_TURN_HEAD);
	self:DropToFloor()
	self:SetMaxYawSpeed(90)
	self:SetCollisionGroup( 1 )
end

function ENT:AcceptInput( key, ply )

	local EI = self:EntIndex()

	if ( ( self.lastUsed or CurTime() ) <= CurTime() ) and ( key == "Use" && ply:IsPlayer() && IsValid( ply ) ) then
	
		self.lastUsed = CurTime() + 0.25

		for k,v in pairs(ents.FindByClass("the_opium_packed")) do 
			
			if self:GetPos():Distance(v:GetPos()) <= opium.ahshop.BuyDistance then 
					
				ply:addMoney( v:Getprice() )
				ply:ChatPrint("Спасибо вот твои деньги $"..v:Getprice())
				v:Remove()
							
			end
		end	
	end	
end


