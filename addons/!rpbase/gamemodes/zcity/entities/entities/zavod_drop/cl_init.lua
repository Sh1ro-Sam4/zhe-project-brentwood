include('shared.lua')

local color_red 	= Color(255,50,50)
local color_yellow 	= Color(255,255,50)
local color_green 	= Color(50,255,50)
local color_grey 	= Color(50,50,50)
local color_black 	= Color(0,0,0)
local color_white 	= Color(245,245,245)

local draw_SimpleText 			= draw.SimpleText
local draw_Box 					= draw.Box
local draw_RoundedBox 			= draw.RoundedBox
local cam_Start3D2D 			= cam.Start3D2D
local cam_End3D2D 				= cam.End3D2D
local math_Clamp 				= math.Clamp
local math_Round 				= math.Round
local CurTime 					= CurTime
local IsValid 					= IsValid

surface.CreateFont('StanocFont_Name',{font = "Roboto",size = 180,weight = 1700,shadow = true, antialias = true})
function ENT:Draw()
	self:DrawModel()
	local screen_color = Color(4,0,53)
	local pos = self:GetPos()
	local ang = self:GetAngles()
	local dist = LocalPlayer():GetPos():Distance(self:GetPos())
	local inView = dist <= 150000

    if (not inView) then return end

	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 90)

	
	cam_Start3D2D(pos + ang:Up() * 24.5 + ang:Forward() * -28.55 + ang:Right() * -12.55, ang, 0.02)
		--draw_RoundedBox(0, -1000, -250, 5000, 2305, screen_color)
		draw_SimpleText('[E] - Распаковать брекет', "StanocFont_Name", 1450, 0, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam_End3D2D()
end