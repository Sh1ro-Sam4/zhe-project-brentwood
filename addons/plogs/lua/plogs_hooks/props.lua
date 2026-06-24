--[[
addons/lgos/lua/plogs_hooks/props.lua
--]]
plogs.Register('Пропы', true, Color(50,175,255))

plogs.AddHook('PlayerSpawnProp', function(pl, mdl)
	plogs.PlayerLog(pl, 'Пропы', pl:NameID() .. ' поставил ' .. mdl, {
		['Name'] 	= pl:Name(),
		['SteamID']	= pl:SteamID()
	})
end)

