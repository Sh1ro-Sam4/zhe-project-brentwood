-- я взял из воркшопа(https://steamcommunity.com/sharedfiles/filedetails/?id=3663526213)
hook.Add("PlayerUse", "IsUsing", function (ply, ent)
local getdoor = ply:GetUseEntity()
	if (string.find(tostring(getdoor), "prop_door_rotating") and getdoor:GetInternalVariable("m_eDoorState") == 2) then
		if (getdoor:GetInternalVariable("m_hMaster") != NULL) then
			getdoor:GetInternalVariable("m_hMaster"):Fire("close")
			return false
		else
			getdoor:Fire("close")
			return false
		end
	end
end)