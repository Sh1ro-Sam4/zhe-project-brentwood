include("shared.lua");

function ENT:Initialize()	
end;

function ENT:Draw()
	self:DrawModel();
	
	local pos = self:GetPos()
	local ang = self:GetAngles()

	local sulfurColor = EML_Sulfur_Color;
	
	if (self:GetNWInt("amount")>0) then
		sulfurColor = EML_Sulfur_Color;
	else
		sulfurColor = Color(100, 100, 100, 255);
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
		
			cam.Start3D2D(pos + ang:Up()*2.70, ang, 0.10)
				surface.SetDrawColor(Color(20, 40, 220, 255));
				surface.DrawRect(-34, -18, 70, 62);		-- Ширина самого блоку
				
				surface.SetDrawColor(80, 80, 220, 200);
				surface.DrawRect(-32, -16, math.Round((self:GetNWInt("amount")*66)/self:GetNWInt("maxAmount")), 58);
			cam.End3D2D();
			
		cam.Start3D2D(pos+ang:Up()*2.75, ang, 0.07)
			draw.SimpleTextOutlined("", "methFont", 0, -14, sulfurColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined("Сера", "methFont", 0, 0, sulfurColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined(""..self:GetNWInt("amount").."", "methFont", 0, 32, PathosColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
		cam.End3D2D();

	--ang:RotateAroundAxis(ang:Up(), 0);
	--ang:RotateAroundAxis(ang:Forward(), -90);
	--ang:RotateAroundAxis(ang:Right(), 90);		
		--cam.Start3D2D(pos+ang:Up()*2.75, ang, 0.13)
			--surface.SetDrawColor(0, 0, 0, 200);
			--surface.DrawRect(-40, -8, 64, 16);
			
			--surface.SetDrawColor(EML_Sulfur_Color);
			--surface.DrawRect(-38, -6, math.Round((self:GetNWInt("amount")*60)/self:GetNWInt("maxAmount")), 12);				
		--cam.End3D2D();
	end;
end;

