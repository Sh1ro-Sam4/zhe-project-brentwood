AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props/cs_assault/money.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    self.nodupe = true

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    timer.Simple(300, function()
        if not IsValid(self) then return end
        self:Remove()
    end)
end

function ENT:Use(activator, caller)
    if self.USED or self.hasMerged then return end

    local canUse, reason = hook.Call("canDarkRPUse", nil, activator, self, caller)
    if canUse == false then
        if reason then end
        return
    end

    self.USED = true
    local amount = self:Getamount()

    hook.Call("playerPickedUpMoney", nil, activator, amount or 0, self)

    timer.Simple(1, function()
        activator:AddMoney(amount or 0)
    end)

    notif(activator, "+" .. FormatMoney(self:Getamount()), 'ok')
    self:Remove()
end

function ENT:StartTouch(ent)
    if ent:GetClass() ~= "rp_money" or self.USED or ent.USED or self.hasMerged or ent.hasMerged then return end

    ent.USED = true
    ent.hasMerged = true

    ent:Remove()
    self:Setamount(self:Getamount() + ent:Getamount())
end