include('shared.lua')   

function ENT:Draw()
	self:DrawModel()
	local pos = self:GetPos() + Vector(50,0,50)

	local ang = Angle(0,90,90)
	local inView, dist = self:InDistance(150000)
	if (not inView) then return end
	local alpha = 255
	color_white.a = alpha
	color_black.a = alpha
	local x = math.sin(CurTime() * math.pi) * 30 // трясет текст туда сюда да вот
	cam.Start3D2D(pos, ang, 0.05)
		surface.SetDrawColor(255, 255, 255, alpha)
		draw.SimpleTextOutlined('Скупщик сигарет', '3d2d', 0, x, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
	cam.End3D2D()
end