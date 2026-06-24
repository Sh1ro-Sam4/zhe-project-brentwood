include("shared.lua")

function ENT:CalculateRenderPos()
    return self:LocalToWorld(Vector(-33.5, 0, 5))
end

function ENT:CalculateRenderAng()

    return self:LocalToWorldAngles(Angle(0, 270, 90))
end

local mod1 = ClientsideModel( "models/props_c17/FurnitureShelf002a.mdl" )
mod1:SetNoDraw( true )
local mod2 = {}
for i = 1, 4 do
	mod2[i] = ClientsideModel( "models/props_junk/glassjug01.mdl" )
	mod2[i]:SetNoDraw( true )
end
local mod3 = ClientsideModel( "models/props_wasteland/prison_pipefaucet001a.mdl" )
mod3:SetNoDraw( true )

local mod4 = ClientsideModel( "models/props_citizen_tech/firetrap_propanecanister01a.mdl" )
mod4:SetNoDraw( true )

local mod2positions = {
    Vector(-22, -35, 7),
	Vector(-10, -35, 7),
	Vector(2, -35, 7),
	Vector(14, -35, 7)
}
function ENT:DrawWElements()
	mod1:SetPos( self:LocalToWorld( Vector( -5, -37, -1 ) ) )
	mod1:SetAngles( self:LocalToWorldAngles( Angle( 0, 270, 0 ) ) )
	mod1:DrawModel()

	for i = 1, self:GetNWInt("EmptyJars") do
        mod2[i]:SetPos( self:LocalToWorld( mod2positions[i] ) )
        mod2[i]:SetAngles( self:GetAngles() )
		mod2[i]:DrawModel()
    end

	if self:GetHasBarrel() then
		mod4:SetPos( self:LocalToWorld( Vector( 0, 0, 20 ) ) )
		mod4:SetAngles( self:GetAngles() )
		mod4:DrawModel()
	end

	if self:GetHasPipe() then
		mod3:SetPos( self:LocalToWorld( Vector( -16, -35, 21 ) ) )
		local ang = self:GetAngles()
		ang:RotateAroundAxis( ang:Up(), 90 )
		mod3:SetAngles( ang )
		mod3:DrawModel()
	end
end

local potTimeTable = {
	[0] = function( self )
		local braga = self:GetBraga()

		if braga > 0 then
			return "НАЖМИ Е (СТАРТ)"
		end

		return "Прогресс: 0%"
	end,
	[1] = function( self )
		return "Прогресс: "..math.floor( self:GetNWInt("progress") ).."%"
	end,
	[2] = function( self )
		return "ГОТОВО! НАЖМИ Е"
	end,
	[3] = function( self )
		return "Прогресс: "..math.floor( self:GetNWInt("fill_progress") ).."%"
	end,
}
function ENT:Draw()
	self:DrawModel()

	self:DrawWElements()

	local pos, ang = self:CalculateRenderPos(), self:CalculateRenderAng()

	local status = self:GetNWInt("status")
	local braga = self:GetBraga()
	local potTime = "Прогресс: 0%"

	potTime = potTimeTable[status]( self )

	if LocalPlayer():GetPos():Distance(self:GetPos()) < (EML_DrawDistance or 300) then
		cam.Start3D2D(pos, ang, 0.10)
			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(-64, -82, 128, 80)
		cam.End3D2D()

		cam.Start3D2D(pos, ang, 0.055)
			if not self:GetHasBarrel() then
				draw.SimpleTextOutlined("ЖДЕТ СБОРКИ", "methFont", 0, -132, Color(255, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
				draw.SimpleTextOutlined("Поставьте бочку", "methFont", 0, -100, Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
				draw.SimpleTextOutlined("на этот стол", "methFont", 0, -75, Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
			elseif not self:GetHasPipe() then
				draw.SimpleTextOutlined("ЖДЕТ СБОРКИ", "methFont", 0, -132, Color(255, 180, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
				draw.SimpleTextOutlined("Прикрепите трубку", "methFont", 0, -100, Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
				draw.SimpleTextOutlined("к бочке", "methFont", 0, -75, Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
			else
				draw.SimpleTextOutlined("Самогон", "methFont", 0, -132, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
				draw.SimpleTextOutlined("______________", "methFont", 0, -124, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))

				surface.SetDrawColor(Color(0, 0, 0, 200))
				surface.DrawRect(-104, -102, 204, 24)

				surface.SetDrawColor(Color(182, 88, 0))

				local displayProgress = self:GetNWInt("progress")
				if status == 3 then displayProgress = self:GetNWInt("fill_progress") end
				surface.DrawRect(-101.5, -100, math.Round((displayProgress*198)/100), 20)

				draw.SimpleTextOutlined("Нужно", "methFont", 0, -63, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
				draw.SimpleTextOutlined("______________", "methFont", 0, -53, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
			end
		cam.End3D2D()

		if self:GetHasBarrel() and self:GetHasPipe() then
			cam.Start3D2D(pos, ang, 0.045)
				draw.SimpleTextOutlined("Брага - "..braga.."/4", "methFont", 0, -35, Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
			cam.End3D2D()

			cam.Start3D2D(pos, ang, 0.035)
				draw.SimpleTextOutlined(potTime, "methFont", -152, -142, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
			cam.End3D2D()
		end
	end
end