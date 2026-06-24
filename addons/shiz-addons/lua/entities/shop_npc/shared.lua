ENT.Type = 'ai'
ENT.Base = 'base_ai'

ENT.PrintName = 'Продавец NPC'
ENT.Author = 'kas'
ENT.Category = 'Developer'

ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar('String', 0, 'KasType')
end