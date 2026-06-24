AddCSLuaFile("autorun/config.lua")
include("autorun/config.lua")

include("shared.lua")

surface.CreateFont( "pickupfont", {
	font = "roboto",
	size = 64,
	weight = 500,
	shadow = true,
    antialias = true
})

surface.CreateFont("methFont", {
	font = "roboto",
	size = 30,
	weight = 500,
	shadow = true,
    antialias = true
})

AddCSLuaFile("autorun/config.lua")
include("autorun/config.lua")

include("shared.lua")

local color_white = Color(255, 255, 255)

local complex_off = Vector(0, 0, 10)

local ang = Angle(0, 90, 90)
function ENT:Draw()
    self:DrawModel()

    local bone = self:LookupBone('ValveBiped.Bip01_Head1')
    if not bone then return end
    
    local pos = self:GetBonePosition(bone) + complex_off
    ang.y = (LocalPlayer():EyeAngles().y - 90)

    local dist = LocalPlayer():GetPos():Distance(self:GetPos())
    local inView = dist <= 150000

    if (not inView) then return end

    local alpha = 255 - (dist/590)
    color_white.a = alpha
    color_black.a = alpha

    local x = math.sin(CurTime() * math.pi) * 30

    cam.Start3D2D(pos, ang, 0.02)
    	draw.SimpleTextOutlined('Джеймс', '3d2d', 0, x - 75, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		draw.SimpleTextOutlined("Нажмите " .. string.upper(input.LookupBinding("use")) .. " для продажи.", "pickupfont", 0, x, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
    cam.End3D2D()
end