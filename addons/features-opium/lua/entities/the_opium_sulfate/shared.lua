ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Сульфат"
ENT.Author = "kas"
ENT.Category = "SHZ | Opium"
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("Int", 0, "HP")
	self:NetworkVar("Bool", 0, "Cooked")
end 
