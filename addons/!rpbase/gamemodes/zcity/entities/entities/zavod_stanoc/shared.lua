ENT.Type 		= 'anim'
ENT.Base 		= 'base_gmodentity'
ENT.PrintName 	= 'Заводской станок'
ENT.Spawnable 	= true
ENT.Category 	= 'RP'

function ENT:SetupDataTables()
	self:NetworkVar('Int', 1, 'LastPrint')
	self:NetworkVar('Bool', 1, 'Enabled')
end