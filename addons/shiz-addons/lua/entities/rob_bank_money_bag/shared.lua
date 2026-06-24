ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Money Bag"
ENT.Spawnable = false
ENT.Category = "Three's Bank Robberies"

//76561198092742034

function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "VaultPos")
    self:NetworkVar("Int", 0, "Distance")
    self:NetworkVar("Int", 1, "Money")
end