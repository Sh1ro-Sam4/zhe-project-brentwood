include("shared.lua")

local color_white = Color(255,255,255)
local color_black = Color(0,0,0)

local complex_off = Vector(0, 0, 9)
local complex_off1 = Vector(0, 0, 70.5)

local ang = Angle(0, 90, 90)
function ENT:DrawInfo()
    local inView, dist = self:InDistance(150000)

    if (not inView) then return end
	local bone = self:LookupBone('ValveBiped.Bip01_Head1')
	if !bone then
	pos = self:GetPos() + complex_off1
	else
	pos = self:GetBonePosition(bone) + complex_off
	end

	ang.y = (LocalPlayer():EyeAngles().y - 90)

	local alpha = 255 - (dist/590)
	color_white.a = alpha
	color_black.a = alpha

	local x = math.sin(CurTime() * math.pi) * 30

    cam.Start3D2D(pos, ang, 0.03)
		draw.SimpleTextOutlined(kas.shop_npc.type[self:GetKasType()].overhead, '3d2d', 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
	cam.End3D2D()
end

function ENT:Draw()
    self:DrawModel()
    self:DrawInfo()
end