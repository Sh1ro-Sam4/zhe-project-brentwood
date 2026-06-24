include( 'shared.lua' )

function ENT:SetupDataTables()
 
	self:NetworkVar( "Bool", 0, "IsWired" )
	self:NetworkVar( "Bool", 0, "IsOn" )

end

function ENT:Draw()

   	self:DrawModel() 

end

function ENT:Think()

	if(self:GetIsWired()==true and self:GetIsOn()==true) then

		if(self:GetPos():Distance(LocalPlayer():GetPos())<1250) then

			local dlight = DynamicLight( self:EntIndex() )

			if ( dlight ) then

				dlight.pos = self:GetPos() + (self:GetAngles():Forward() * 50) + Vector(0, 0, 50)
				dlight.r = 255
				dlight.g = 0
				dlight.b = 0
				dlight.brightness = 4
				dlight.Decay = 1000
				dlight.Size = 512
				dlight.DieTime = CurTime() + 1

			end

		end

	end

end