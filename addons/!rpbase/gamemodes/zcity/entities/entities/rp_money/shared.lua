ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Spawned Money"
ENT.Spawnable = false
ENT.IsSpawnedMoney = true

function ENT:SetupDataTables()
    self:NetworkVar("Int",0,"amount")
end