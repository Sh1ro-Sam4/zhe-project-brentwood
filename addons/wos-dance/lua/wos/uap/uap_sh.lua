hook.Add( "CalcMainActivity", "wOS.UAP.Anim", function( ply )
	if ply:GetNWBool( "wOS.UAP.AnimActive" ) then
		if ply:GetNWBool( "wOS.UAP.ResetSequence" ) == false then
			ply:AnimRestartMainSequence()
		end
		local sequence_id = ply:LookupSequence( ply:GetNWString( "wOS.UAP.SequenceID" ) )
		return -1, sequence_id
	end
end )

hook.Add( "UpdateAnimation", "wOS.UAP.AnimSpeed", function( ply )
	if ply:GetNWBool( "wOS.UAP.AnimActive" ) then
		ply:SetPlaybackRate( 1 )
		return true
	end
end )

hook.Add( "StartCommand", "wOS.UAP.AnimMoveSpeed", function( ply, cmd )
	if ply:GetNWBool( "wOS.UAP.AnimActive" ) then
		if cmd:GetForwardMove() ~= 0 then
			cmd:SetForwardMove( 0.075 * cmd:GetForwardMove() )
		end
		if cmd:GetSideMove() ~= 0 then
			cmd:SetSideMove( 0.075 * cmd:GetSideMove() )
		end
	return cmd
	end
end )
