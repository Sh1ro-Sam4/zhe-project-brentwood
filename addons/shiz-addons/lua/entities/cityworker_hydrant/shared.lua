ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName       = "Bouche d'incendie"
ENT.Category        = "City Worker"
ENT.Author          = "Silhouhat"
ENT.Contact 	    = ""

ENT.Spawnable   	= false

function ENT:SetupDataTables()
    self:NetworkVar( "Bool", 0, "Leaking" )
end