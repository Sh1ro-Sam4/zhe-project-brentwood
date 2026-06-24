hook.Add("PlayerDeath", "MRPJobBoxSystemDeath", function(ply)
	ply:SetNWBool("MRPJobBoxSystem", false)
end)

hook.Add('KeyPress', 'shz-BoxSystem', function(ply, key)
	if ply:GetNWBool("MRPJobBoxSystem") and (key == IN_SPEED or key == IN_JUMP) then
		ply:SetNWBool("MRPJobBoxSystem", false)
		ply:ConCommand( "say /me уронил коробку")
	end
end)