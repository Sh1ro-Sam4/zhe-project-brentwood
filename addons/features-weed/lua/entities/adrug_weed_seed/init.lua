AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" ) 

include( 'shared.lua' ) 



function ENT:Initialize()
	
	self:SetUseType( SIMPLE_USE )
	self:SetModel( "models/props/de_inferno/crate_fruit_break_gib2.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetColor(Color(0,60,0,255))

    local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then

		phys:Wake()

	end



end

function ENT:VisualEffect()
	local effectData = EffectData()
	effectData:SetStart(self:GetPos())
	effectData:SetOrigin(self:GetPos())
	effectData:SetScale(8);
	util.Effect("GlassImpact", effectData, true, true)
end

function ENT:OnTakeDamage(dmginfo)
	self:VisualEffect()
	self:Remove()
end