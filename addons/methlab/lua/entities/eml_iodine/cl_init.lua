include("shared.lua");

function ENT:Initialize()	

end;

function ENT:Draw()
	self:DrawModel();
	
	local pos = self:GetPos()
	local ang = self:GetAngles()

	local iodineColor = EML_Iodine_Color;
	
	if (self:GetNWInt("amount")>0) then
		iodineColor = EML_Iodine_Color;
	else
		iodineColor = Color(100, 100, 100, 255);
	end;	
	
	if (self:GetNWInt("amount")>0) then
		PathosColor = EML_Pathos_Color;
	else
		PathosColor = Color(100, 100, 100, 255);
	end;
	
	if LocalPlayer():GetPos():Distance(self:GetPos()) < EML_DrawDistance then
		ang:RotateAroundAxis(ang:Up(), 90);
		ang:RotateAroundAxis(ang:Forward(), 90);
		ang:RotateAroundAxis(ang:Right(), 0);
		
			cam.Start3D2D(pos + ang:Up()*3.35, ang, 0.10)
				surface.SetDrawColor(Color(20, 40, 220, 255));
				surface.DrawRect(-44, -28, 90, 72);		-- Ширина самого блоку
				
				surface.SetDrawColor(80, 80, 220, 200);
				surface.DrawRect(-42, -26, math.Round((self:GetNWInt("amount")*86)/self:GetNWInt("maxAmount")), 68);
			cam.End3D2D();
			
		cam.Start3D2D(pos+ang:Up()*3.45, ang, 0.08)
			draw.SimpleTextOutlined("Йод", "methFont", 0, -10, iodineColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined(""..self:GetNWInt("amount").."", "methFont", 0, 25, PathosColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
		cam.End3D2D();
	end;
end;


