include("shared.lua")

function ENT:Initialize()

end

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	local potTime = "Прогресс: "..self:GetNWInt("progress").."% (Тряси!)"

	if (self:GetNWInt("status") == 0) then
		potTime = "Прогресс: "..self:GetNWInt("progress").."% (Тряси!)"
	elseif (self:GetNWInt("status") == 1) then
		potTime = "Готово! Нажми E!"
	end
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 90)
	if LocalPlayer():GetPos():Distance(self:GetPos()) < EML_DrawDistance then
		cam.Start3D2D(pos + ang:Up()*6.9, ang, 0.10)
			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(-64, -82, 128, 100)
		cam.End3D2D()
		cam.Start3D2D(pos + ang:Up()*6.9, ang, 0.055)
			draw.SimpleTextOutlined("Брага", "methFont", 0, -132, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
			draw.SimpleTextOutlined("______________", "methFont", 0, -124, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))

			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(-104, -102, 204, 24)
			surface.SetDrawColor(Color(182, 88, 0))
			surface.DrawRect(-101.5, -100, math.Round((self:GetNWInt("progress")*198)/100), 20)

			draw.SimpleTextOutlined("Нужно", "methFont", -44, -65, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
			draw.SimpleTextOutlined("______________", "methFont", 0, -58, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))

		cam.End3D2D()

		cam.Start3D2D(pos + ang:Up()*7, ang, 0.045)
			draw.SimpleTextOutlined("Вода - "..self:GetWater().."/4", "methFont", -121, -40, Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
			draw.SimpleTextOutlined("Дрожжи - "..self:GetYeast().."/3", "methFont", -121, -10, Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
			draw.SimpleTextOutlined("Спирт - "..self:GetAlcohol().."/2", "methFont", -121, 20, Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
		cam.End3D2D()
		cam.Start3D2D(pos + ang:Up()*7, ang, 0.035)
			draw.SimpleTextOutlined(potTime, "methFont", -152, -142, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
		cam.End3D2D()

	end
end