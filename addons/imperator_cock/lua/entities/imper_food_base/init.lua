AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.FoodModel)
    
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local curHunger = activator:GetHunger()
    local maxHunger = 100

    if curHunger < maxHunger then
        activator:SetHunger(math.min(curHunger + self.HAmount, maxHunger))
    end

    if self.ConsumeSound then
        activator:EmitSound(self.ConsumeSound)
	else
		activator:EmitSound("snd_jack_hmcd_eat"..math.random(4)..".wav")
    end

    self:OnConsumed(activator)

    if self.RemoveOnUse then
        self:Remove()
    end
end

function ENT:OnConsumed(ply)
end