ENT.Base = "base_gmodentity"
ENT.Type = "anim"

ENT.PrintName		= "Банка для смешивания"
ENT.Category 		= "SHZ | Alco"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true

function ENT:SetupDataTables()
	self:NetworkVar('Int', 1, 'Water')
	self:NetworkVar('Int', 2, 'MaxWater')
    self:NetworkVar('Int', 3, 'Alcohol')
	self:NetworkVar('Int', 4, 'MaxAlcohol')
    self:NetworkVar('Int', 5, 'Yeast')
	self:NetworkVar('Int', 6, 'MaxYeast')
end