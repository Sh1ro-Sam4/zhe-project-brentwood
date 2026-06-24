include('shared.lua')

local color_white = Color(255,255,255)
local color_black = Color(0,0,0)
local color_bg = Color(10,10,10)

local ang = Angle(0, 90, 90)

local complex_off = Vector(0, 0, 12)

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos() + complex_off
	ang.y = (LocalPlayer():EyeAngles().y - 90)

	local dist = LocalPlayer():GetPos():Distance(self:GetPos())
    local inView = dist <= 150000

    if (not inView) then return end

	color_white.a = 255 - (dist/500)
	color_black.a = color_white.a

	local x = math.sin(CurTime() * math.pi) * 30

	cam.Start3D2D((pos + self:GetForward() * (self:OBBMaxs().y - 4.25)), ang, 0.03)
		draw.SimpleTextOutlined('Чернила', '3d2d', 0, x, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	cam.End3D2D()
end