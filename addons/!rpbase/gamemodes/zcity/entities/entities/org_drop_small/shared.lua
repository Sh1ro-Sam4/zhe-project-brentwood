ENT.Type = 'anim'
ENT.Base = 'base_gmodentity'
ENT.PrintName = 'Шкаф с дата фермой'
ENT.Spawnable = true
ENT.Category = '[ЗАПРЕЩЕНО СПАВНИТЬ] ОРГАНИЗАЦИИ'
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	self:NetworkVar('Entity', 1, 'owning_ent')
	self:NetworkVar('Int', 0, 'Level')
	self:NetworkVar('Int', 1, 'HP')
	self:NetworkVar('Bool', 0, 'IsPowered')
	self:NetworkVar('Float', 0, 'Bank')
	self:NetworkVar('String', 0, 'ORGIANAME')
end