include( 'shared.lua' )

function ENT:SetupDataTables()
 
	self:NetworkVar( "Bool", 0, "IsBatOn" )
	self:NetworkVar( "Int", 1, "BatLevel" )
	self:NetworkVar( "Int", 2, "ConnectedDevices" )

end

function ENT:Draw()

   	self:DrawModel() 
 	
	cam.Start3D2D( self:GetPos()+(self:GetAngles():Up()*7), self:GetAngles(), 0.05 )

		local textToDraw = " "


		surface.SetDrawColor( Color( 0,0,0, 200 ) )
		surface.DrawRect( -5*20, -8*20, 10*20, 16*20 )

		surface.SetDrawColor( Color( 255,255,255, 255 ) )
		surface.SetFont( "font.20" )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( -4*20,-7*20 ) 
		surface.DrawText( "Подзарядник" )

		local offSet = 0

		if(self:GetIsBatOn()==true)then
			surface.SetDrawColor( Color( 0,200,0, 200 ) )
			textToDraw="Вкл"
			offSet = 0.5*20
		else
			surface.SetDrawColor( Color( 200,0,0, 200 ) )
			textToDraw="Выкл"
			offSet = 0
		end
		surface.DrawRect( -4*20, -5*20, 8*20, 3*20 )

		surface.SetFont( "font.20" )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( (-2.5*20)+offSet,-4.65*20 ) 
		surface.DrawText( textToDraw )

		local batLevel = self:GetBatLevel()

		surface.SetDrawColor( Color( 255/((batLevel/75)+1),2.55*batLevel,0, 255 ) )
		surface.DrawRect( -4*20, -1*20, 8*20, 3*20 )

		textToDraw=tostring(batLevel).."%"

		surface.SetFont( "font.20" )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( (-2.2*20),-0.85*20 ) 
		surface.DrawText( textToDraw )


		surface.SetDrawColor( Color( 0,0,190, 255 ) )
		surface.DrawRect( -4*20, 3*20, 8*20, 4*20 )

		surface.SetFont( "font.20" )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( (-4*20),3.2*20 ) 
		surface.DrawText("Устройство")

		surface.SetFont( "font.20" )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( (-4*20),4.5*20 ) 
		surface.DrawText(tostring(self:GetConnectedDevices()))


	cam.End3D2D()

end

function ENT:Initialize()



end

function ENT:Think()




end


