include("shared.lua");
local colors = {Color(1, 241, 249, 255), Color(25, 25, 25, 100)}
function ENT:Draw()
	self:DrawModel();
    local inView = self:InDistance(40000)
    if (not inView) then return end
	local pos = self:GetPos()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 90);
	ang:RotateAroundAxis(ang:Forward(), 90);	
	cam.Start3D2D(pos + ang:Up(), Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.03)
		draw.SimpleTextOutlined("Кристальный Мет ("..self:GetNWInt("amount").." грамм)", "3d2d", 32, -350, colors[1], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, colors[2]);			
	cam.End3D2D()	
end;