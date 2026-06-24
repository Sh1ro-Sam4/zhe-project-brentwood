AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
local zOffset = -7
local xWidth = 4.8
local yLength = 8.0
local bottlePositions = {
    Vector(-xWidth, -yLength, zOffset), 
    Vector(-xWidth, 0, zOffset), 
    Vector(-xWidth, yLength, zOffset),
    Vector(xWidth, -yLength, zOffset),  
    Vector(xWidth, 0, zOffset),  
    Vector(xWidth, yLength, zOffset)
}
function ENT:UpdateVisuals()
    if self.bottleModels then
        for _, mdl in pairs(self.bottleModels) do
            if IsValid(mdl) then mdl:Remove() end
        end
    end
    self.bottleModels = {}
    local count = self:GetNWInt("BeersCount")
    if count <= 0 then return end
    for i = 1, count do
        if not bottlePositions[i] then break end
        local bottle = ents.Create("prop_dynamic")
        if not IsValid(bottle) then continue end
        bottle:SetModel("models/props_junk/glassjug01.mdl") 
        bottle:SetPos(self:LocalToWorld(bottlePositions[i]))
        local angleOffset = Angle(0, 0, 0) 
        bottle:SetAngles(self:LocalToWorldAngles(angleOffset))
        
        bottle:SetParent(self)
        bottle:Spawn()
        bottle:SetSolid(SOLID_NONE) 
        
        table.insert(self.bottleModels, bottle)
    end
end
function ENT:Initialize()
    self:SetModel("models/props_junk/plasticcrate01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE) 
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
    self:SetNWInt("BeersCount", 0)
    self.MaxBeers = 6
    self.bottleModels = {}
end
function ENT:PhysicsCollide(data, phys)
    local ent = data.HitEntity 
    if not IsValid(ent) then return end
    if ent:GetClass() == "alco_moonshine" and not ent.UsedInCrate then
        local current = self:GetNWInt("BeersCount")
        if current < self.MaxBeers then
            ent.UsedInCrate = true 
            timer.Simple(0, function() 
                if IsValid(ent) then ent:Remove() end
                if IsValid(self) then 
                    self:SetNWInt("BeersCount", current + 1)
                    self:UpdateVisuals()
                    self:EmitSound("physics/glass/glass_bottle_impact_hard2.wav", 65, math.random(95, 105))
                end
            end)
        end
    end
end
function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if (self.NextUse or 0) > CurTime() then return end
    self.NextUse = CurTime() + 0.3
    local current = self:GetNWInt("BeersCount")
    if current > 0 then
        self:SetNWInt("BeersCount", current - 1)
        self:UpdateVisuals()
        self:EmitSound("physics/glass/glass_bottle_impact_hard1.wav", 65, 120)

        local beer = ents.Create("alco_moonshine")
        if IsValid(beer) then 
            beer:SetPos(self:LocalToWorld(Vector(0, 0, 15))) 
            beer:SetAngles(self:GetAngles()) 
            beer:Spawn() 
            local phys = beer:GetPhysicsObject()
            if IsValid(phys) then 
                local dir = (activator:GetPos() - self:GetPos()):GetNormalized()
                phys:SetVelocity(dir * 80 + Vector(0, 0, 100)) 
            end
        end
    else
        self:EmitSound("player/suit_denydevice.wav", 50, 100)
    end
end
function ENT:OnRemove()
    if self.bottleModels then
        for _, mdl in pairs(self.bottleModels) do
            if IsValid(mdl) then mdl:Remove() end
        end
    end
end