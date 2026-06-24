ENT.Type 		= 'anim'
ENT.Base 		= 'base_gmodentity'
ENT.PrintName 	= 'Стеллаж для продажи'
ENT.Spawnable 	= true
ENT.Category 	= '[ЗАПРЕЩЕНО СПАВНИТЬ] ОРГАНИЗАЦИИ'

function ENT:SetupDataTables()
	self:NetworkVar('Int', 0, 'ContainerID')
end