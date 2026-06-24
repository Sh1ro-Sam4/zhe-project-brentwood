ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Terracotta Pot"
ENT.Category = "RP"

ENT.Spawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "CookingProgress")
	self:NetworkVar("Bool", 0, "HasWeedSeed")
	self:NetworkVar("Bool", 1, "HasWater")
	self:NetworkVar("Bool", 2, "HasDirt")
	self:NetworkVar("Int", 3, "WaterAmount") -- Добавляем переменную для отслеживания количества воды

end