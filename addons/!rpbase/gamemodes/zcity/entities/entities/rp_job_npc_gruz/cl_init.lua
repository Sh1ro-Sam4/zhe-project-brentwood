include("shared.lua")

local color_white = Color(255, 255, 255)
local color_black = Color(0, 0, 0)
local complex_off = Vector(0, 0, 9)
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

    cam.Start3D2D(pos, ang, 0.03)
        draw.SimpleTextOutlined(self.NpcName, '3d2d', 0, x, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
    cam.End3D2D()
end