ENT.Type = "anim"
ENT.Author = "Mannytko"
ENT.Category = "ZCity Other"
ENT.PrintName = "Универсальный Телевизор"
ENT.Spawnable = false
ENT.AdminOnly = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "CurrentURL")
    self:NetworkVar("Bool", 0, "IsPlaying")
    self:NetworkVar("Bool", 1, "IsPaused") -- Новая переменная для паузы
end