AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


function ENT:Initialize()
    self:SetModel( self.NpcModel )
    self:SetHullType( HULL_HUMAN )
    self:SetHullSizeNormal()
    self:SetNPCState( NPC_STATE_SCRIPT )
    self:SetSolid( SOLID_BBOX )
    self:CapabilitiesAdd( CAP_ANIMATEDFACE + CAP_TURN_HEAD )
    self:SetUseType( SIMPLE_USE )
    self:DropToFloor()
    self:SetMaxYawSpeed( 90 )

    local sequences = self:GetSequenceList()
    local idleSequences = {}

    for k, v in pairs(sequences) do
        if string.find(string.lower(v), "idle") then
            table.insert(idleSequences, v)
        end
    end

    --PrintTable(idleSequences)
    
    timer.Simple(0.1, function()
        if self:IsValid() then
            local seq = self:LookupSequence('idle_all_02')
            if seq > 0 then
                self:ResetSequence(seq)
                self:SetPlaybackRate(1)
            else
                self:ResetSequence(0)
            end
        end
    end)
end

function ENT:Think()
    if self:GetSequence() == 0 then
        local seq = self:LookupSequence('idle_all_02')
        if seq > 0 then
            self:ResetSequence(seq)
        end
    end
end