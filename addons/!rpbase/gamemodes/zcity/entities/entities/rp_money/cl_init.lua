include("shared.lua")

local LocalPlayer = LocalPlayer
local Color = Color
local cam = cam
local draw = draw
local Angle = Angle
local Vector = Vector

local color_white = Color(255,255,255)
local color_black = Color(0,0,0)

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	local ply = LocalPlayer()
	local dist = ply:GetPos():Distance(pos)
	local maxDist = math.sqrt(125000)
	local inView = dist <= maxDist

	if (not inView) then return end

	color_white.a = 255 - (dist/500)
	color_black.a = color_white.a

	cam.Start3D2D(pos + ang:Up() * 0.9, ang, 0.015)
		draw.SimpleTextOutlined(FormatMoney(self:Getamount()), '3d2d', 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	cam.End3D2D()

	ang:RotateAroundAxis(ang:Right(), 180)

	cam.Start3D2D(pos, ang, 0.015)
		draw.SimpleTextOutlined(FormatMoney(self:Getamount()), '3d2d', 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	cam.End3D2D()
end