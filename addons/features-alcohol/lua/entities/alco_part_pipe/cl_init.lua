include('shared.lua')
function ENT:Draw()
	self:DrawModel()
	local pos = self:GetPos() + Vector(0,0,15)
	local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
	local dist = LocalPlayer():GetPos():Distance(self:GetPos())
    if (dist > 500) then return end

	cam.Start3D2D(pos, ang, 0.05)
		draw.SimpleTextOutlined('Трубка (Деталь)', 'methFont', 0, 0, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0,0,0))
	cam.End3D2D()
end