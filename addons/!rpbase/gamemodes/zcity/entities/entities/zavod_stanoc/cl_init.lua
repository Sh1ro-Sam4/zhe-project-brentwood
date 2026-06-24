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

local function drawFilledArc(cx, cy, radius, startAngle, endAngle, color)
    local segments = 100
    local vertices = {}

    table.insert(vertices, { x = cx, y = cy })

    for i = 0, segments do
        local t = i / segments
        local angle = startAngle + (endAngle - startAngle) * t
        local rad = math.rad(angle)
        local px = cx + radius * math.cos(rad)
        local py = cy - radius * math.sin(rad)
        table.insert(vertices, { x = px, y = py })
    end

    surface.SetDrawColor(color)
    surface.DrawPoly(vertices)
end

local function drawRadialBar(x, y, w, h, perc, text)
    local cx = x + w / 1.2
    local cy = y + h / 2
    local radius = math.min(w, h) / 0.9

    drawFilledArc(cx + 50, cy, radius, 0, 360, color_grey)

    if perc > 0 then
        local startAngle = 90
        local endAngle = startAngle - (perc * 360)
        drawFilledArc(cx + 50, cy, radius, startAngle, endAngle, Color(255, 255, 255))
    end

    draw.SimpleText(
        text or string.format("%.0f%%", perc * 100),
        font,
        cx - w / 1.85, cy,
        Color(255, 255, 255),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )
end
local function predict(timeValue, value)
	return math_Clamp(math_Round((CurTime() - timeValue)/value, 2), 0, 1)
end

surface.CreateFont('StanocFont_Name',{font = "Roboto",size = 180,weight = 1700,shadow = true, antialias = true})
function ENT:Draw()
	self:DrawModel()
	local screen_color = Color(4,0,53)
	local pos = self:GetPos()
	local ang = self:GetAngles()
	local dist = LocalPlayer():GetPos():Distance(self:GetPos())
	local inView = dist <= 150000

    if (not inView) then return end

	ang:RotateAroundAxis(ang:Up(), 180)
	ang:RotateAroundAxis(ang:Forward(), 42)

	
	cam_Start3D2D(pos + ang:Up() * 19.5 + ang:Forward() * 1.55 + ang:Right() * -12.55, ang, 0.01)
		draw_RoundedBox(0, -1000, -250, 5000, 2305, screen_color)
		draw_SimpleText('Зубофрезерный станок модели 53А11', "StanocFont_Name", 1450, 0, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		local printperc = predict(self:GetLastPrint(), 30)
		--drawRadialBar(900, 500, 532, 532, printperc, '')
		if self:GetEnabled() then
		draw_SimpleText('Обработка заготовки...', "StanocFont_Name", 1450, 1700, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw_RoundedBox(0, -150, 1800, 3180 * printperc, 300, Color(255,255,255))
		end
	cam_End3D2D()
end