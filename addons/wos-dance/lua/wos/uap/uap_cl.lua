hook.Add( "CalcView", "wOS.UAP.ThirdPersonCamera", function( ply, pos, angles, fov )
	if ply:GetNWBool( "wOS.UAP.AnimActive" ) then
		return { origin = pos - ( angles:Forward() * 100 ), angles = angles, fov = fov, drawviewer = true }
	end
end )

hook.Add( "PlayerBindPress", "wOS.UAP.StopAnim", function( ply, bind, pressed )
	if ply:GetNWBool( "wOS.UAP.AnimActive" ) and ( ( bind == "+attack" ) or ( bind == "+attack2" ) or ( bind == "+reload" ) or ( bind == "+jump" ) or ( bind == "+duck" ) or ( bind == "+speed" ) or ( bind == "+walk" ) ) then
		net.Start( "wOS.UAP.Stop" )
		net.WriteEntity( ply )
		net.SendToServer()
	end
end )