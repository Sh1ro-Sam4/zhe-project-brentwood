ENT.Type 		= 'anim'
ENT.Base 		= 'base_gmodentity'
ENT.PrintName 	= 'Груз'
ENT.Spawnable 	= true
ENT.Category 	= 'RP'

function ENT:SetupDataTables()
	self:NetworkVar('Entity', 1, 'owning_ent')
end