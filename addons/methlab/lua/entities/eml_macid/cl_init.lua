include("shared.lua");

function ENT:Initialize()	

end;

function ENT:Draw()
	self:DrawModel();
	
	local pos = self:GetPos()
	local ang = self:GetAngles()

	local macidColor = EML_MuriaticAcid_Color;
	
	if (self:GetNWInt("amount")>0) then
		macidColor = EML_MuriaticAcid_Color;
	else
		macidColor = Color(100, 100, 100, 255);
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
		
			cam.Start3D2D(pos + ang:Up()*4.8, ang, 0.10)
				surface.SetDrawColor(Color(20, 40, 220, 255));
				surface.DrawRect(-59, -18, 118, 82);		-- Ширина самого блоку
				--Тень
				surface.SetDrawColor(80, 80, 220, 200);
				surface.DrawRect(-57, -16, math.Round((self:GetNWInt("amount")*114)/self:GetNWInt("maxAmount")), 78);
			cam.End3D2D();
	
		cam.Start3D2D(pos+ang:Up()*4.9, ang, 0.1)
			draw.SimpleTextOutlined("Соляная", "methFont", 0, 0, macidColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined("кислота", "methFont", 0, 24, macidColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined(""..self:GetNWInt("amount").."", "methFont", 0, 48, PathosColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
		cam.End3D2D();

	--ang:RotateAroundAxis(ang:Up(), 0);
	--ang:RotateAroundAxis(ang:Forward(), -90);
	--ang:RotateAroundAxis(ang:Right(), 90);		
		--cam.Start3D2D(pos+ang:Up()*5, ang, 0.1)
			--surface.SetDrawColor(0, 0, 0, 200);
			--surface.DrawRect(-100, -8, 128, 22);
			
			--surface.SetDrawColor(EML_MuriaticAcid_Color);
			--surface.DrawRect(-98, -6, math.Round((self:GetNWInt("amount")*124)/self:GetNWInt("maxAmount")), 18);				
		--cam.End3D2D();
	end;
		
end;