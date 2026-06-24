AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" ) 

include( 'shared.lua' )


function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "IsWired" )
	self:NetworkVar( "Bool", 0, "IsOn" )

end

function ENT:Initialize()

	self:SetUseType( SIMPLE_USE )
	self:SetModel( "models/props_c17/light_floodlight02_off.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then

		phys:Wake()

	end

end

function ENT:Use( ply)


end

function ENT:Think()

	if(self:GetAngles().x < -4) then
		
		self:SetAngles(Angle(-4, self:GetAngles().y, self:GetAngles().z));

	end

	if(self:GetAngles().x >4) then
		
		self:SetAngles(Angle(4, self:GetAngles().y, self:GetAngles().z));

	end

	if(self:GetAngles().z < -4) then
		
		self:SetAngles(Angle(self:GetAngles().x, self:GetAngles().y, -4));
		
	end

	if(self:GetAngles().z > 4) then
		
		self:SetAngles(Angle(self:GetAngles().x, self:GetAngles().y, 4));

	end

	IS_WIRED = self:GetIsWired()

end


function findropes(ent)



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