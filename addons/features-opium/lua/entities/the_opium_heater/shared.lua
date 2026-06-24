ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Теплодуховка"
ENT.Author = "kas"
ENT.Category = "SHZ | Opium"
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("Int", 0, "Health")
	self:NetworkVar("Int", 1, "Gas")
	self:NetworkVar("Bool", 1, "Cooking")
end 

