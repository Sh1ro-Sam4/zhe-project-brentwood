include("shared.lua")

local mainplate10 = Material("materials/simple_opium/packer/sides2.png")

function ENT:Draw()

	self:DrawModel()
	
	if self:GetPos():Distance(EyePos()) > 400 then return end
		
	local ahAngle = self:GetAngles()
	local AhEyes = LocalPlayer():EyeAngles()
	
	ahAngle:RotateAroundAxis(ahAngle:Forward(), 90)
	ahAngle:RotateAroundAxis(ahAngle:Right(), -90)		
	
	cam.Start3D2D(self:GetPos()+self:GetUp()*16.5, Angle(0, AhEyes.y-90, 90), 0.175)
	
		surface.SetDrawColor( 0, 0, 0, 200 )
		surface.SetMaterial( mainplate10 )
		surface.DrawTexturedRect( -35,10,70,18 )
		draw.SimpleTextOutlined("Вода", "font.16", 0, 11.5, Color(255,255,255), 1, 0, 1, Color(25, 25, 25, 255))
		surface.SetDrawColor( Color(0,0,0,0) )
		surface.DrawOutlinedRect( -35,10,70,18 )
		
	cam.End3D2D()	
	
end		