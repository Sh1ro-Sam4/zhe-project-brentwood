include("shared.lua");

function ENT:Initialize()	

end;

function ENT:Draw()
	self:DrawModel();
	
	local pos = self:GetPos()
	local ang = self:GetAngles()

	local waterColor = EML_Salt_Color;
	
	if (self:GetNWInt("amount")>0) then
		saltColor = EML_Salt_Color;
	else
		saltColor = Color(100, 100, 100, 255);
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
				surface.DrawRect(-34, -28, 70, 72);
				
				surface.SetDrawColor(80, 80, 220, 200);
				surface.DrawRect(-32, -26, math.Round((self:GetNWInt("amount")*66)/self:GetNWInt("maxAmount")), 68);
			cam.End3D2D();
			
		cam.Start3D2D(pos+ang:Up()*3.40, ang, 0.08)
			draw.SimpleTextOutlined("Соль", "methFont", 0, -5, saltColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined(""..self:GetNWInt("amount").."", "methFont", 0, 24, PathosColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
		cam.End3D2D();
	end;
		
end;