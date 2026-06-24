--[[
addons/lgos/lua/plogs_hooks/tools.lua
--]]
plogs.Register('Тулган', false)

plogs.AddHook('CanTool', function(pl, trace, tool) -- Shame there isn't a better hook
	if (not plogs.cfg.ToolBlacklist[tool]) then
		plogs.PlayerLog(pl, 'Тулган', pl:NameID() .. ' использовал ' .. tool, {
			['Name'] 	= pl:Name(),
			['SteamID']	= pl:SteamID()
		})
	end
end)

