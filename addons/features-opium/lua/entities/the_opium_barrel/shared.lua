ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Бочка"
ENT.Author = "kas"
ENT.Category = "SHZ | Opium"
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("Int", 0, "HP")
	self:NetworkVar("Int", 1, "CookTime")
	self:NetworkVar("Int", 2, "Premium")
	self:NetworkVar("Int", 3, "codeine")
	self:NetworkVar("Int", 4, "papaverine")
	self:NetworkVar("Int", 5, "sulfate")
	self:NetworkVar("Int", 6, "water")
	self:NetworkVar("Int", 7, "bottle")
	self:NetworkVar("Bool", 0, "Cooked")
	self:NetworkVar("Bool", 1, "Cooking")
end 
