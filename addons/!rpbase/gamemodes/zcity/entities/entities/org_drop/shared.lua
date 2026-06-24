ENT.Type 		= 'anim'
ENT.Base 		= 'base_gmodentity'
ENT.PrintName 	= 'Ящик с очками'
ENT.Spawnable 	= true
ENT.Category 	= '[ЗАПРЕЩЕНО СПАВНИТЬ] ОРГАНИЗАЦИИ'

function ENT:SetupDataTables()
	self:NetworkVar('Entity', 1, 'owning_ent')
	self:NetworkVar('Int', 1, 'LastTake')
end