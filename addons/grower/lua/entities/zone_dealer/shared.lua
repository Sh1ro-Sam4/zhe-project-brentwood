--[[------------------------------------------------------
--                   ZONE Weed Growing                  --
--              By: height229 (height229.com)           --
--]]------------------------------------------------------

-- DON'T TOUCH THIS UNLESS YOU KNOW WHAT YOU'RE DOING! <ONLY FOR DEVELOPERS!>

ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "Weed Dealer"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "RP"

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"price")
end