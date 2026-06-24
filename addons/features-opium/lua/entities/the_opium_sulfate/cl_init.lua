include("shared.lua")

local image1 = Material("materials/simple_opium/stuff/sulfate.png")

function ENT:Draw()
	self:DrawModel()

	if self:GetPos():Distance(EyePos()) > 1000 then return end	
	
	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	Ang:RotateAroundAxis(Ang:Up(), 90)

	cam.Start3D2D(Pos + Ang:Up() * 4.3, Ang, 0.11)
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial(image1)
		surface.DrawTexturedRect( -124, -48, 273, 195 )
	
	cam.End3D2D()
	
end	