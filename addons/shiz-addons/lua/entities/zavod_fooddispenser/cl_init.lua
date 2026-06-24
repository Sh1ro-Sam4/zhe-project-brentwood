include("shared.lua")

function ENT:Initialize() end
function ENT:Think() end

function ENT:Draw()
	self:DrawModel()

	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	Ang:RotateAroundAxis(Ang:Forward(), 90)
	Ang:RotateAroundAxis(Ang:Right(), -90)

	cam.Start3D2D(Pos + Ang:Up() * 23.8, Ang, 0.11)
		draw.SimpleText("Раздатчик Еды", "font.30", 2, -100, Color(255,255,255,255), 1, 1)
	cam.End3D2D()
end
