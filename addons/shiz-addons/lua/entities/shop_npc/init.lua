AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel( "models/mossman.mdl" )
    self:SetHullType( HULL_HUMAN )
    self:SetHullSizeNormal()
    self:SetSolid( SOLID_BBOX )
    self:SetMoveType( MOVETYPE_STEP )
    self:SetUseType( SIMPLE_USE )

    self:SetHealth(1)

    self:SetKasType('default')

    self.oldKasType = self:GetKasType()
end

function ENT:Think()
    if kas.shop_npc.type[self:GetKasType()].sequence then
        self:SetSequence(kas.shop_npc.type[self:GetKasType()].sequence)
    end
    if self.oldKasType ~= self:GetKasType() then
        hook.Run('OnKasTypeChanged', self)
        self.oldKasType = self:GetKasType()
    end
end

function ENT:Use( ply )
    kas.shop_npc.type[self:GetKasType()].use(self, ply)
end

hook.Add('OnKasTypeChanged', 'shop-npc.KasTypeChanged', function(self)
    if kas.shop_npc.type[self:GetKasType()].model then
        self:SetModel(kas.shop_npc.type[self:GetKasType()].model)
    end
end)