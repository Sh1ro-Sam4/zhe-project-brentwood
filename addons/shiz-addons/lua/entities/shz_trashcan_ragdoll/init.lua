AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/props_junk/TrashDumpster01a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Use(ply)
    if not IsValid(ply) or not ply:Alive() or IsValid(ply.FakeRagdoll) then return end

    local i = 0
    for idx, entities in pairs(ents.FindInSphere(self:GetPos(), 100)) do
        if entities:GetClass() ~= "prop_ragdoll" then continue end
        if entities.organism.alive == true then continue end

        entities:Remove()
        local randomMoney = math.random(15, 50)
        ply:AddMoney(randomMoney, "Чистка трупов")
        notif( ply, ("Вы получили %s"):format(shizlib.FormatMoney(randomMoney)) )
        i = i + 1
    end
    if i == 0 then
        notif( ply, "Приноси трупы чтобы получать денежное вознаграждение" )
    end
end