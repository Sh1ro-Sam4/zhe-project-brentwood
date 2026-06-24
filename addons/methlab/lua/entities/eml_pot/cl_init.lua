include("shared.lua");

function ENT:Initialize()	

end;

function ENT:Draw()
	self:DrawModel();
	
	local pos = self:GetPos()
	local ang = self:GetAngles()
	local macidColor = Color(160, 221, 99, 255);
	local sulfurColor = Color(243, 213, 19, 255);
	local waterColor = Color(243, 213, 19, 255);
	
	local potTime = "Время: "..self:GetNWInt("time").."с";
	
	if (self:GetNWInt("status") == 0) then
		potTime = "Время: "..self:GetNWInt("time").."с";
	elseif (self:GetNWInt("status") == 1) then	
		potTime = "Готово! Нажмите E!";
	end;
	ang:RotateAroundAxis(ang:Up(), 90);
	ang:RotateAroundAxis(ang:Forward(), 90);	
	if LocalPlayer():GetPos():Distance(self:GetPos()) < EML_DrawDistance then
		cam.Start3D2D(pos + ang:Up()*8, ang, 0.10)
			surface.SetDrawColor(Color(0, 0, 0, 200));
			surface.DrawRect(-64, -40, 128, 102);		
		cam.End3D2D();
		cam.Start3D2D(pos + ang:Up()*8, ang, 0.055)
			draw.SimpleTextOutlined("Красынй фосфор", "methFont", 0, -56, Color(175, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined("______________", "methFont", 0, -54, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));

			surface.SetDrawColor(Color(0, 0, 0, 200));
			surface.DrawRect(-104, -32, 204, 24);			
			surface.SetDrawColor(Color(175, 0, 0, 200));
			surface.DrawRect(-101.5, -30, math.Round((self:GetNWInt("time")*198)/self:GetNWInt("maxTime")), 20);		
			
			draw.SimpleTextOutlined("Нужно", "methFont", -45, 6, Color(175, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined("______________", "methFont", 0, 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));

			if (self:GetNWInt("macid")==0) then
				macidColor = Color(220, 220, 220, 255);
			else
				macidColor = Color(160, 221, 99, 255);
			end;
			
			if (self:GetNWInt("sulfur")==0) then
				sulfurColor = Color(220, 220, 220, 255);
			else
				sulfurColor = Color(243, 213, 19, 255);
			end;	
			
			if (self:GetNWInt("water")==0) then
				waterColor = Color(220, 220, 220, 255);
			else
				waterColor = Color(133, 202, 219, 255);
			end;	
			
			draw.SimpleTextOutlined("Соляная кислота ("..self:GetNWInt("macid")..")", "methFont", -101, 38, macidColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined("Сера ("..self:GetNWInt("sulfur")..")", "methFont", -101, 64, sulfurColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));				
			draw.SimpleTextOutlined("Вода ("..self:GetNWInt("water")..")", "methFont", -101, 90, waterColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));				
		cam.End3D2D();	
		cam.Start3D2D(pos + ang:Up()*8, ang, 0.035)		
			draw.SimpleTextOutlined(potTime, "methFont", -152, -32, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));		
		cam.End3D2D();		
		
	end;
end;

