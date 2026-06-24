salePrice = 18000


ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "Скупщик травки"
ENT.Author = "kas"
ENT.Category = "SHZ | ADrugs"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true




function ENT:SetAutomaticFrameAdvance( anim )
	self.AutomaticFrameAdvance = anim
end 