include('shared.lua')

local color_white = Color(255,255,255)
local color_black = Color(0,0,0)
local color_bg = Color(10,10,10)

local ang = Angle(0, 90, 90)

local complex_off = Vector(0, 0, 20)

function ENT:Draw()
	self:DrawModel()

	local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
	local pos = self:GetPos() + self:GetAngles():Up() * 15
	local dist = LocalPlayer():GetPos():Distance(self:GetPos())
    if (dist > 500) then return end

	-- cam.Start3D2D(pos, ang, 0.05)
	-- 	draw.SimpleTextOutlined(self.PrintName, 'methFont', 0, 0, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0,0,0))
	-- cam.End3D2D()
end