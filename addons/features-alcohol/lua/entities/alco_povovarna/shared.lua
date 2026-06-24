ENT.Base = "base_gmodentity"
ENT.Type = "anim"

ENT.PrintName		= "Кухонный стол (Самогон)"
ENT.Category 		= "SHZ | Alco"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true

function ENT:SetupDataTables()
	self:NetworkVar('Int', 1, 'Braga')
	self:NetworkVar('Int', 2, 'Beer')
	self:NetworkVar('Bool', 0, 'HasBarrel')
	self:NetworkVar('Bool', 1, 'HasPipe')
end