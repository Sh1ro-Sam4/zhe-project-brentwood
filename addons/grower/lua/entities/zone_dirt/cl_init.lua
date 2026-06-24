--[[------------------------------------------------------
--                   ZONE Weed Growing                  --
--              By: height229 (height229.com)           --
--]]------------------------------------------------------

-- DON'T TOUCH THIS UNLESS YOU KNOW WHAT YOU'RE DOING! <ONLY FOR DEVELOPERS!>

include("shared.lua")

local color_white = Color(255, 255, 255)

local complex_off = Vector(0, 0, 30)

local ang = Angle(0, 90, 90)

function ENT:Draw()
    self:DrawModel()

    pos = self:GetPos() + Vector(0, 0, 10)

    ang.y = (LocalPlayer():EyeAngles().y - 90)

    local dist = LocalPlayer():GetPos():Distance(self:GetPos())
    local inView = dist <= 500

    if (not inView) then return end

    local alpha = 255 - (dist / 2)
    color_white.a = alpha
    color_black.a = alpha

    local x = math.sin(CurTime() * math.pi) * 30

    cam.Start3D2D(pos, ang, 0.03)
        draw.SimpleTextOutlined('Почва', '3d2d', 0, x, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
    cam.End3D2D()
end