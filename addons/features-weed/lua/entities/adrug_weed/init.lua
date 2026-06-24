AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" ) 

include( 'shared.lua' )

hook.Add("PlayerDeath", "ResetWeedAmountOnDeath", function(victim, inflictor, attacker)
    if victim.weedAmount and victim.weedAmount > 0 then
        victim.weedAmount = 0
        victim:ChatPrint("Вы погибли и потеряли всю собранную травку!")
    end
end)

function ENT:Initialize()
	
	self:SetUseType( SIMPLE_USE )
	self:SetModel( "models/props_junk/rock001a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetColor(Color(0,120,0,255))

    local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then

		phys:Wake()

	end

end

function ENT:Use(ply)

	if(ply.weedAmount!=nil) then
	
		ply.weedAmount = ply.weedAmount+1	

	else

		ply.weedAmount = 1

	end

	self:Remove()

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