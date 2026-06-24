include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH
function ENT:Draw()
	self:DrawModel()
end
function ENT:SetRagdollBones( b )
	self.m_bRagdollSetup = b
end
function ENT:DrawTranslucent()
	self:Draw()
end


function ENT:Initialize()	

end;

function ENT:Draw()
	self:DrawModel()
    	local pos = self:GetPos() + Vector(0, 0, 1) * math.sin(CurTime() * 1) * 1
    local PlayersAngle = LocalPlayer():GetAngles()
    local ang = Angle( 0, PlayersAngle.y - 180, 0 )
    ang:RotateAroundAxis(ang:Right(), -90)
    ang:RotateAroundAxis(ang:Up(), 90)

	if LocalPlayer():GetPos():Distance(self:GetPos()) < 200 then
				cam.Start3D2D(pos + ang:Up() * 1 + ang:Right() * -80, ang, 0.1)
			draw.SimpleText( "Скупщик травки", "font.120", 0,0, Color(255,255,255), 1,1 )
		cam.End3D2D()
	end
end;