plogs.Register('Чат', false)

plogs.AddHook('PlayerSay', function(pl, text)
	if (text ~= '') then
		plogs.PlayerLog(pl, 'Чат', '[ЧАТ]' .. pl:NameID() .. ' сказал ' .. string.Trim(text), {
			['Name'] 	= pl:Name(),
			['SteamID']	= pl:SteamID()
		})
	end
end)