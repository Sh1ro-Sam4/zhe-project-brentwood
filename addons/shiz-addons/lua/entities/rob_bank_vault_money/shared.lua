ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Vault Money"
ENT.Spawnable = true
ENT.Category = "Three's Bank Robberies"

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "HeldMoney")
    self:NetworkVar("Int", 1, "Delay")
    self:NetworkVar("Float", 0, "Cooldown")
end

//76561198092742034