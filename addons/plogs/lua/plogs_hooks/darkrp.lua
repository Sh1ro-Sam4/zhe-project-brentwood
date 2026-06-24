plogs.Register('Деньги', false, Color(51, 128, 255))

plogs.AddHook('playerPickedUpMoney', function(pl, amout, ent)
	if IsValid(pl) then
		plogs.PlayerLog(pl, 'Деньги', pl:NameID() .. ' поднял ' .. amout ..  '$' , {
			['Ник'] 	= pl:Name(),
			['Стимид']	= pl:SteamID()
		})
	end
end)

plogs.AddHook('playerGiveMoney', function(pl, pl2, amout)
	if IsValid(pl) then
		plogs.PlayerLog(pl,'Деньги', pl:NameID()..' дал '..amout..'$ игроку '..pl2:NameID(), {
			['Ник'] 	= pl:Name(),
			['Стимид']	= pl:SteamID(),
			['Ник кому дали денег'] = pl2:Name(),
			['Стим ид кому дали денег'] = pl2:SteamID()
		})
	end
end)

plogs.AddHook('playerDropMoney', function(pl,amout)
	if IsValid(pl) then
		plogs.PlayerLog(pl,'Деньги', pl:NameID()..' скинул на землю '..amout..'$',{
			['Ник'] 	= pl:Name(),
			['Стимид']	= pl:SteamID(),
		})
	end
end)

plogs.AddHook('playerGetSalary', function(pl,amout)
	if IsValid(pl) then
		plogs.PlayerLog(pl,'Деньги', pl:NameID()..' получил зарплату: '..amout..'$',{
			['Ник'] 	= pl:Name(),
			['Стимид']	= pl:SteamID(),
		})
	end
end)

-- Job changes
plogs.Register('Работы', true, Color(51, 128, 255))

plogs.AddHook('OnPlayerChangedClass', function(pl, old, new)
	if IsValid(pl) then
		plogs.PlayerLog(pl, 'Работы', pl:NameID() .. ' сменил профессию c ' .. (old or 'NULL') .. ' на ' .. new, {
			['Name'] 	= pl:Name(),
			['SteamID']	= pl:SteamID()
		})
	end
end)

-- Police logs
plogs.Register('Полиция', true, Color(51, 128, 255))

plogs.AddHook('playerArrested', function(target, time, reason, officer)
	if IsValid(officer) then
		plogs.PlayerLog(officer, 'Полиция', officer:NameID() .. ' арестовал ' .. target:NameID() .. ' по причине ' .. reason .. ' на срок ' .. time .. ' сек.', {
			['Target Name'] 	= target:Name(),
			['Target SteamID']	= target:SteamID(),
			['Officer Name'] 	= officer:Name(),
			['Officer SteamID']	= officer:SteamID(),
		})
	end
end)

plogs.AddHook('playerUnArrested', function(target)
	plogs.Log('Полиция', target:NameID() .. ' вышел из тюрьмы.', {
		['Name'] 	= target:Name(),
		['SteamID']	= target:SteamID(),
	})
end)

plogs.AddHook('playerWanted', function(target, officer, reason)
	if IsValid(officer) then
		plogs.PlayerLog(officer, 'Полиция', officer:NameID() .. ' розыск ' .. target:NameID() .. ' причина ' .. reason, {
			['Target Name'] 	= target:Name(),
			['Target SteamID']	= target:SteamID(),
			['Officer Name'] 	= officer:Name(),
			['Officer SteamID']	= officer:SteamID(),
		})
	end
end)

plogs.AddHook('playerUnWanted', function(target, officer)
	plogs.Log('Полиция', target:NameID() .. ' Пропал розыск', {
		['Name'] 	= target:Name(),
		['SteamID']	= target:SteamID(),
	})
end)

-- Lockpicks
plogs.Register('Взломы', false)

plogs.AddHook('lockpickStarted', function(pl)
	plogs.PlayerLog(pl, 'Взломы', pl:NameID() .. ' Начал взлом', {
		['Name'] 	= pl:Name(),
		['SteamID']	= pl:SteamID()
	})
end)

plogs.AddHook('onLockpickCompleted', function(pl, succ)
	plogs.PlayerLog(pl, 'Взломы', pl:NameID() .. ' Закончил взлом ' .. (succ and 'Успешно' or 'Неудачно'), {
		['Name'] 	= pl:Name(),
		['SteamID']	= pl:SteamID()
	})
end)


-- Door buys
plogs.Register('Дома', false)

plogs.AddHook('playerBoughtDoor', function(pl, ent, cost)
	plogs.PlayerLog(pl, 'Дома', pl:NameID() .. ' купил дом за $' .. cost, {
		['Name'] 	= pl:Name(),
		['SteamID']	= pl:SteamID()
	})
end)

plogs.AddHook('playerSellDoor', function(pl, ent)
	plogs.PlayerLog(pl, 'Дома', pl:NameID() .. ' продал дом', {
		['Name'] 	= pl:Name(),
		['SteamID']	= pl:SteamID()
	})
end)

timer.Simple(0, function()
	-- DarkRP.log = function() end
end)

