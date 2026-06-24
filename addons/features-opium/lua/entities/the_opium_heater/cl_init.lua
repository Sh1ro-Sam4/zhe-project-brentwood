include("shared.lua")

local image1 = Material("materials/simple_opium/plate.png")
local image2 = Material("materials/simple_opium/plate3.png")
local image3 = Material("materials/simple_opium/plate1.png")

function ENT:Draw()
	self:DrawModel()

	if self:GetPos():Distance(EyePos()) > 1000 then return end	
	
	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	Ang:RotateAroundAxis(Ang:Up(), 90)

	cam.Start3D2D(Pos + Ang:Up() * 6.1, Ang, 0.11)

		if self:GetCooking() then		
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(image3)
			surface.DrawTexturedRect( -161, -161, 324, 322 )
		else
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(image1)
			surface.DrawTexturedRect( -161, -161, 324, 322 )
		end
		
	cam.End3D2D()

	Ang:RotateAroundAxis(self:GetAngles():Up(), 360)
	Ang:RotateAroundAxis(self:GetAngles():Right(), 270)
	Ang:RotateAroundAxis(self:GetAngles():Up(), 450)

	cam.Start3D2D(Pos + Ang:Up() * 18, Ang, 0.11)
				
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(image2)
			surface.DrawTexturedRect( -161, -56, 322, 111)
			draw.SimpleText(self:GetGas().." - Температура","font.20",45.5,3,Color(255,255,255),1,1)
	cam.End3D2D()
	
end