include( 'shared.lua' )

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "IsPlanted" )
	self:NetworkVar( "Int", 1, "GowthStage" )
	self:NetworkVar( "Int", 2, "PlantHealth" )
	self:NetworkVar( "Int", 3, "PlantThirst" )
	self:NetworkVar( "Bool", 4, "IsGrowing" )
	self:NetworkVar( "Bool", 5, "PlantIsDying" )
	self:NetworkVar( "Bool", 6, "HasLight" )

end


function ENT:Draw()

   	self:DrawModel() 

   	local ang = self:GetAngles()
 
   	ang:RotateAroundAxis(ang:Forward(), 90);

   	local isPlanted = self:GetIsPlanted()
   	local growthStage = self:GetGowthStage()
    local plantHealth = self:GetPlantHealth()
    local plantThirst = self:GetPlantThirst()
    local plantIsDying = self:GetPlantIsDying()
    local isGrowing = self:GetIsGrowing()	
 
   	cam.Start3D2D( self:GetPos()+(self:GetAngles():Right()*9.5)+(self:GetAngles():Up()*2), ang, 0.05 )

		surface.SetDrawColor( Color( 0,0,0, 200 ) )
		surface.DrawRect( -6*20, -11*20, 12*20, 12*20 )

		text = "Горшок"

 

		surface.SetDrawColor( Color( 255,255,255, 255 ) )
		surface.SetFont( "font.20" )
		surface.SetTextColor( 255, 255, 255, 255 )
		local TextWidth = surface.GetTextSize(text)
		surface.SetTextPos( -2.5*20,-10.5*20 ) 
		surface.DrawText( text )


		--Is planted

		local color = Color(0,0,0)
		local text = " "
		local OffSet = 0

		if(isPlanted) then

			color = Color(0,200,0,255)
			text = "ПОСАЖЕНО"
			OffSet = 0.5

		else

			color = Color(200,0,0,255)
			text = "НЕ ПОСАЖЕНО"
			OffSet = 0

		end

		local TextWidth = surface.GetTextSize(text)

		surface.SetDrawColor( color )
		surface.DrawRect( -6*20, -8.5*20, 12*20, 2*20 )

		surface.SetDrawColor( Color( 255,255,255, 255 ) )
		surface.SetFont( "font.20" )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( 0-(TextWidth/2),-8.2*20 ) 
		surface.DrawText( text )

		--Growth
		surface.SetDrawColor( Color( 30,30,30, 200 ) )
		surface.DrawRect( -6*20, -5.5*20, 12*20, 2*20 )

		local length = (growthStage/100)*12
		color = Color(255/(growthStage/16),2.55*growthStage,0,255)

		if(growthStage<100) then
			
			text = "Растет"

		else

			text = "Выросло"

		end

		if(self:GetHasLight()) then
			
			text = "Требуется свет!"
			color = Color(255,0,0,255)
			length = 12

		end

		surface.SetDrawColor( color )
		surface.DrawRect( -6*20, -5.5*20,length*20, 2*20 )

		surface.SetDrawColor( Color( 255,255,255, 255 ) )
		surface.SetFont( "font.20" )

		local TextWidth = surface.GetTextSize(text)

		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( 0-(TextWidth/2),-5.2*20 ) 
		surface.DrawText( text )

		--Water
		surface.SetDrawColor( Color( 30,30,30, 255 ) )
		surface.DrawRect( -6*20, -2.5*20, 12*20, 2*20 )


		local length = (plantThirst/100)*12

		text = "Вода"

		surface.SetDrawColor( Color(0,0,255,255) )
		surface.DrawRect( -6*20, -2.5*20,length*20, 2*20 )

		surface.SetDrawColor( Color( 255,255,255, 255 ) )
		surface.SetFont( "font.20" )

		local TextWidth = surface.GetTextSize(text)

		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( 0-(TextWidth/2),-2.1*20 ) 
		surface.DrawText( text )

		--Health
		surface.SetDrawColor( Color( 30,30,30, 255 ) )
		surface.DrawRect( -6*20, 0.5*20, 12*20, 2*20 )

		local length = (plantHealth/100)*12

		text = "Здоровье"

		surface.SetDrawColor( Color(200, 200, 0, 255 ) )
		surface.DrawRect( -6*20, 0.5*20,length*20, 2*20 )

		surface.SetFont( "font.20" )

		local TextWidth = surface.GetTextSize(text)

		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( 0-(TextWidth/2),0.8*20 ) 
		surface.DrawText( text )



	cam.End3D2D()

end

function ENT:Initialize()



end

function ENT:Think()




end

