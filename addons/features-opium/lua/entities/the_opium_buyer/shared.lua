ENT.Base = "base_ai" 
ENT.Type = "ai"
ENT.PrintName = "Скупщик опиума"
ENT.Author = "kas"
ENT.Category = "SHZ | Opium"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
	self.AutomaticFrameAdvance = bUsingAnim
end

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "WeedValue")
	self:NetworkVar("Int", 2, "WeedCountShop")
	self:NetworkVar("Int", 3, "WeedGramShop")
	self:NetworkVar("Int", 4, "EntIndexs")
	self:NetworkVar("Int", 5, "TotalGram")
	self:NetworkVar("Bool", 0, "SpamCoolDown")
end 

