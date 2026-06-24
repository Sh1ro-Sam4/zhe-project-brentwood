include("shared.lua")

local image1 = Material("materials/simple_opium/packer/background.png")
local image2 = Material("materials/simple_opium/packer/sides2.png")
local image3 = Material("materials/simple_opium/packer/bottle1.png")
local image4 = Material("materials/simple_opium/packer/bottle2.png")
local image5 = Material("materials/simple_opium/packer/bottle3.png")
local image6 = Material("materials/simple_opium/packer/bottle4.png")
local image7 = Material("materials/simple_opium/packer/bottle5.png")
local image8 = Material("materials/simple_opium/packer/sides.png")
local image9 = Material("materials/simple_opium/packer/1.png")
local image10 = Material("materials/simple_opium/packer/2.png")
local image11 = Material("materials/simple_opium/packer/3.png")
local image12 = Material("materials/simple_opium/packer/4.png")
local image13 = Material("materials/simple_opium/packer/5.png")

function ENT:Draw()
	self:DrawModel()

	if self:GetPos():Distance(EyePos()) > 1000 then return end	
	
	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	Ang:RotateAroundAxis(Ang:Up(), 90)

	cam.Start3D2D(Pos + Ang:Up() * 23.8, Ang, 0.11)
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial(image2)
		surface.DrawTexturedRect( -216, -216, 432, 324 )
		
	cam.End3D2D()

	Ang:RotateAroundAxis(self:GetAngles():Up(), 360)
	Ang:RotateAroundAxis(self:GetAngles():Right(), 270)
	Ang:RotateAroundAxis(self:GetAngles():Up(), 360)

	cam.Start3D2D(Pos + Ang:Up() * 11.9, Ang, 0.11)
				
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(image1)
			surface.DrawTexturedRect( -216, -216, 432, 324)
			-- the second image is for a update when ahshop 3 is out
			if self:Getbottle() >= 1 then 
				surface.SetMaterial(image3)
				surface.DrawTexturedRect( -216, -216, 432, 324)
				--surface.SetMaterial(image9)
				--surface.DrawTexturedRect( -216, -216, 432, 324)
			end
			if self:Getbottle() >= 2 then 
				surface.SetMaterial(image4)
				surface.DrawTexturedRect( -216, -216, 432, 324)
				--surface.SetMaterial(image10)
				--surface.DrawTexturedRect( -216, -216, 432, 324)
			end
			if self:Getbottle() >= 3 then 
				surface.SetMaterial(image5)
				surface.DrawTexturedRect( -216, -216, 432, 324)
				--surface.SetMaterial(image11)
				--surface.DrawTexturedRect( -216, -216, 432, 324)
			end
			if self:Getbottle() >= 4 then 
				surface.SetMaterial(image6)
				surface.DrawTexturedRect( -216, -216, 432, 324)
				--surface.SetMaterial(image12)
				--surface.DrawTexturedRect( -216, -216, 432, 324)
			end
			if self:Getbottle() >= 5 then 
				surface.SetMaterial(image7)
				surface.DrawTexturedRect( -216, -216, 432, 324)
				--surface.SetMaterial(image13)
				--surface.DrawTexturedRect( -216, -216, 432, 324)
			end
			
	cam.End3D2D()

	Ang:RotateAroundAxis(self:GetAngles():Up(), 360)
	Ang:RotateAroundAxis(self:GetAngles():Right(), 180)
	Ang:RotateAroundAxis(self:GetAngles():Up(), 360)

	cam.Start3D2D(Pos + Ang:Up() * 23.8, Ang, 0.11)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(image2)
			surface.DrawTexturedRect( -216, -108, 432, 324)
	cam.End3D2D()
	
	Ang:RotateAroundAxis(self:GetAngles():Up(), 360)
	Ang:RotateAroundAxis(self:GetAngles():Right(), 180)
	Ang:RotateAroundAxis(self:GetAngles():Up(), 90)

	cam.Start3D2D(Pos + Ang:Up() * 23.8, Ang, 0.11)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(image8)
			surface.DrawTexturedRect( -108, -215, 324, 324)
	cam.End3D2D()

	Ang:RotateAroundAxis(self:GetAngles():Up(), 360)
	Ang:RotateAroundAxis(self:GetAngles():Right(), 180)
	Ang:RotateAroundAxis(self:GetAngles():Up(), 180)

	cam.Start3D2D(Pos + Ang:Up() * 23.8, Ang, 0.11)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(image8)
			surface.DrawTexturedRect( -108, -108, 324, 324)
	cam.End3D2D()
end