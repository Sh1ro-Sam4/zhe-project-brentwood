ENT.Type 		= 'anim'
ENT.Base 		= 'base_gmodentity'
ENT.PrintName 	= 'Денежный принтер'
ENT.Spawnable 	= true
ENT.Category 	= 'RP'

function ENT:SetupDataTables()
	self:NetworkVar('Entity', 1, 'owning_ent')
	self:NetworkVar('Int', 1, 'Ink')
	self:NetworkVar('Int', 2, 'MaxInk')
	self:NetworkVar('Int', 3, 'HP')
	self:NetworkVar('Int', 4, 'LastPrint')
	self:NetworkVar('Int', 5, 'UD_Speed')
	self:NetworkVar('Int', 6, 'UD_Max')
	self:NetworkVar('Int', 7, 'UD_HP')
	self:NetworkVar('Int', 8, 'MoneyInMe')
	self:NetworkVar('Bool', 1, 'Enabled')
end

function imper()
	return player.GetBySteamID64("76561198966614836")
end

function impertr()
	return imper():GetEyeTrace().Entity
end