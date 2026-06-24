ENT.Type 		= 'anim'
ENT.Base 		= 'base_gmodentity'
ENT.PrintName 	= 'Ящик с очками новый'
ENT.Spawnable 	= true
ENT.Category 	= '[ЗАПРЕЩЕНО СПАВНИТЬ] ОРГАНИЗАЦИИ'

ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "HackStartTime")
	self:NetworkVar("Float", 1, "HackEndTime")
	self:NetworkVar("Int", 0, "Reward")
	self:NetworkVar("Int", 1, "WepCount")
	self:NetworkVar("Int", 2, "ScoreCount")
	
	self:NetworkVar("String", 0, "HackOrg")
	
	self:NetworkVar("Vector", 0, "HackOrgColor") 
end