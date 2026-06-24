include("shared.lua")

local color_white = Color(255, 255, 255)

function ENT:Draw()

	self:DrawModel()

	local ang = self:GetAngles()
	local pos = self:GetPos()

	local textAnim = (math.sin(CurTime() * 2.8) * 5)

	local donetime = self:GetCookingProgress()
	local Water = self:GetHasWater()
	local extract = self:GetHasWeedSeed() and self:GetHasWater() and self:GetHasDirt()

	ang:RotateAroundAxis(self:GetAngles():Right(), -90)
	ang:RotateAroundAxis(self:GetAngles():Forward(), 90)

	if (self:GetCookingProgress() == 100) then
		cam.Start3D2D(pos + ang:Up(), Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.05)
			draw.SimpleTextOutlined("Нажмите "..string.upper(input.LookupBinding("use")).." чтобы собрать.", "pickupfont", 0, -900, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		cam.End3D2D()
	end

	cam.Start3D2D(pos + (ang:Up() * 10) + (ang:Right() * -5), ang, 0.1)
			draw.RoundedBox(2, -63, -65, 100, 30, Color(140, 0, 0, 100))
			if (self:GetCookingProgress() > 0) then
				draw.RoundedBox(2, -63, -65, self:GetCookingProgress(), 30, Color(0, 225, 0, 100))
			end
			draw.SimpleText("Прогрес", "ui.26", -55, -64, Color(255, 255, 255, 255))
			if (self:GetCookingProgress() > 0) then
				draw.WordBox(2, -43, -30, "Трава", "ui.26", Color(0, 225, 0, 100), Color(255, 255, 255, 255))
			else
				draw.WordBox(2, -43, -30, "Трава", "ui.26", Color(255, 0, 0, 100), Color(255, 255, 255, 255))
			end

			local waterAmount = self:GetWaterAmount() or 100
			local maxWater = 100
			local waterBarWidth = 100 * (waterAmount / maxWater)
			draw.RoundedBox(2, -63, -100, 100, 20, Color(0, 0, 10, 160))
			draw.RoundedBox(2, -63, -100, waterBarWidth, 20, Color(0, 100, 255, 150))
			draw.SimpleText("Вода: "..tostring(waterAmount), "ui.20", -40, -100, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	cam.End3D2D()
end