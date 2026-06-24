--[[
addons/lgos/lua/plogs_hooks/ulx.lua
--]]
plogs.Register('Админка', false)

plogs.AddHook('SAM.RanCommand', function(pl, cmd, args)
	if not IsValid(pl) then
		adminID = "CONSOLE"
		adminName = "CONSOLE"
		adminSID = "CONSOLE"
	else
		adminID = pl:NameID()
		adminName = pl:Name()
		adminSID = pl:SteamID()
	end
	-- if pl:IsPlayer() then 
		plogs.PlayerLog(pl, 'Админка', adminID .. ' выполнил "' .. cmd .. '" аргумент "' .. table.concat(args, ' ') .. '"', {
			['Name']	= adminName,
			['SteamID']	= adminSID,
		})
	-- end
end)


