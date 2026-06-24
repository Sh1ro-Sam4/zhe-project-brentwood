include("shared.lua")

local mainplate10 = Material("materials/simple_opium/packer/sides2.png")

function ENT:Draw()

	self:DrawModel()
	
	if self:GetPos():Distance(EyePos()) > 400 then return end
	
	local ahAngle = self:GetAngles()
	local AhEyes = LocalPlayer():EyeAngles()
	
	ahAngle:RotateAroundAxis(ahAngle:Forward(), 90)
	ahAngle:RotateAroundAxis(ahAngle:Right(), -90)		
	
	cam.Start3D2D(self:GetPos()+self:GetUp()*62, Angle(0, AhEyes.y-90, 90), 0.175)

		surface.SetDrawColor( 0,0,0,200 )
		surface.SetMaterial( mainplate10 )
		surface.DrawTexturedRect( -50,-15,100,20 )
		
		draw.SimpleTextOutlined(self:Getsulfate().."% Сульфат", "font.14", 0, -12, Color(255,255,255), 1, 0, 1, Color(25, 25, 25, 255))
		surface.SetDrawColor( Color(0,0,0,0) )
		surface.DrawOutlinedRect( -50,-15,100,20 )
	
		surface.SetDrawColor( 0,0,0,200 )
		surface.SetMaterial( mainplate10 )
		surface.DrawTexturedRect( -50,10,100,20 )
		
		draw.SimpleTextOutlined(self:Getcodeine().."% Мекстура", "font.14", 0, 13, Color(255,255,255), 1, 0, 1, Color(25, 25, 25, 255))
		surface.SetDrawColor( Color(0,0,0,0) )
		surface.DrawOutlinedRect( -50,10,100,20 )
		
		surface.SetDrawColor( 0,0,0,200 )
		surface.SetMaterial( mainplate10 )
		surface.DrawTexturedRect( -50,35,100,20 )
		
		draw.SimpleTextOutlined(self:Getpapaverine().."% Паравельден", "font.14", 0, 38, Color(255,255,255), 1, 0, 1, Color(25, 25, 25, 255))
		surface.SetDrawColor( Color(0,0,0,0) )
		surface.DrawOutlinedRect( -50,35,100,20 )
		
		surface.SetDrawColor( 0,0,0,200 )
		surface.SetMaterial( mainplate10 )
		surface.DrawTexturedRect( -50,60,100,20 )
		
		draw.SimpleTextOutlined(self:Getwater().."% Вода", "font.14", 0, 63, Color(255,255,255), 1, 0, 1, Color(25, 25, 25, 255))
		surface.SetDrawColor( Color(0,0,0,0) )
		surface.DrawOutlinedRect( -50,60,100,20 )
		
	cam.End3D2D()	
	
end	