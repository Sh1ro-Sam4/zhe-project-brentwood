include("shared.lua");

function ENT:Initialize()	

end;

function ENT:Draw()
	self:DrawModel();
	
	local pos = self:GetPos()
	local ang = self:GetAngles()
	local macidColor = Color(160, 221, 99, 255);
	local iodineColor = Color(137, 69, 54, 255);
	local waterColor = Color(133, 202, 219, 255);
	
	local potTime = "Прогресс: "..self:GetNWInt("progress").."% (Тряси!)";
	
	if (self:GetNWInt("status") == 0) then
		potTime = "Прогресс: "..self:GetNWInt("progress").."% (Тряси!)";
	elseif (self:GetNWInt("status") == 1) then	
		potTime = "Готово! Нажми E!";
	end;
	ang:RotateAroundAxis(ang:Up(), 90);
	ang:RotateAroundAxis(ang:Forward(), 90);	
	if LocalPlayer():GetPos():Distance(self:GetPos()) < EML_DrawDistance then
		cam.Start3D2D(pos + ang:Up()*6.9, ang, 0.10)
			surface.SetDrawColor(Color(0, 0, 0, 200));
			surface.DrawRect(-64, -82, 128, 100);		
		cam.End3D2D();
		cam.Start3D2D(pos + ang:Up()*6.9, ang, 0.055)
			draw.SimpleTextOutlined("Йод", "methFont", 0, -128, Color(220, 134, 159, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined("______________", "methFont", 0, -124, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));

			surface.SetDrawColor(Color(0, 0, 0, 200));
			surface.DrawRect(-104, -102, 204, 24);			
			surface.SetDrawColor(Color(220, 134, 159, 255));
			surface.DrawRect(-101.5, -100, math.Round((self:GetNWInt("progress")*198)/100), 20);		
			
			draw.SimpleTextOutlined("Нужно", "methFont", -44, -62, Color(220, 134, 159, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined("______________", "methFont", 0, -58, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));

			if (self:GetNWInt("macid")==0) then
				macidColor = Color(220, 220, 220, 255);
			else
				macidColor = Color(160, 221, 99, 255);
			end;
			
			if (self:GetNWInt("iodine")==0) then
				iodineColor = Color(220, 220, 220, 255);
			else
				iodineColor = Color(137, 69, 54, 255);
			end;

			if (self:GetNWInt("water")==0) then
				waterColor = Color(220, 220, 220, 255);
			else
				waterColor = Color(133, 202, 219, 255);
			end;											
		cam.End3D2D();	
		
		cam.Start3D2D(pos + ang:Up()*7, ang, 0.045)		
			draw.SimpleTextOutlined("Соленая кислота ("..self:GetNWInt("macid")..")", "methFont", -121, -40, macidColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined("Йод ("..self:GetNWInt("iodine")..")", "methFont", -121, -10, iodineColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));	
			draw.SimpleTextOutlined("Вода ("..self:GetNWInt("water")..")", "methFont", -121, 20, waterColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));			
		cam.End3D2D();			
		cam.Start3D2D(pos + ang:Up()*7, ang, 0.035)		
			draw.SimpleTextOutlined(potTime, "methFont", -152, -142, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));		
		cam.End3D2D();		
		
	end;
end;

