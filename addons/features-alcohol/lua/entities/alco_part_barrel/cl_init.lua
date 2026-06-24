include('shared.lua')
function ENT:Draw()
	self:DrawModel()
	local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
	local selfang = self:GetAngles()
	local pos = self:GetPos() + selfang:Up() * 75
	local dist = LocalPlayer():GetPos():Distance(self:GetPos())
    if (dist > 500) then return end

	cam.Start3D2D(pos, ang, 0.075)
		draw.SimpleTextOutlined('Бочка (Поставь на стол)', 'methFont', 0, 0, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0,0,0))
	cam.End3D2D()
end