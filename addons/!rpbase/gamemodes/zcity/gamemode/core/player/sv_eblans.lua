shizlib.MaxPlayers = 45

getNotDonaters = function()
    local list = player.GetAll()
    for i,ply in pairs(list) do
		if ply:GetUserGroup() ~= "user" or ply:HasPremium() then list[i] = nil end
	end
	return list
end

getDonaters = function()
    local list = {}
    for i,ply in pairs(player.GetAll()) do
		if ply:GetUserGroup() ~= "user" or ply:HasPremium() then list[#list + 1] = ply end
	end
	return list
end

hook.Add("CheckPassword", "Homigrad-Paste", function(steamID)
    if GetGlobalBool("NoLimitSlots", false) then return end
    if #player.GetAll() > 50 then
        return false, "limit players\nСервер заполнен!\nНаш Discord: https://discord.gg/cSmhecewkY"
    end
    local steamID64 = steamID
    steamID = util.SteamIDFrom64(steamID)

    local group = sql.Query("SELECT rank FROM sam_players WHERE steamid = " .. sql.SQLStr(steamID))
    group = group and group[1].rank or "user"

    local hasPremium = tonumber(util.GetDRPData(steamID64, "premium", 0)) > os.time()

    local isPremium = (group ~= "user") or hasPremium
    local totalPlayers = #player.GetAll()

    if totalPlayers >= 50 and not isPremium then
        return false, "Сервер заполнен!\nНаш Discord: https://discord.gg/cSmhecewkY"
    end

    if isPremium then
        RunConsoleCommand("sv_visiblemaxplayers", tostring(math.min(53, shizlib.MaxPlayers + #getDonaters())))
        return
    end

    if timer.Exists("PlayerSpawnCD_" .. steamID64) then
        return false, "Кажется вы решили не дожидаться респавна...?\nПридется подождать"
    end

    if #getNotDonaters() + 1 > shizlib.MaxPlayers then
        return false, "limit players\nСервер заполнен!\nНаш Discord: https://discord.gg/cSmhecewkY"
    end
end)

local createTimer = function()
    timer.Create("SyncSlots??", 20, 0, function()
        BroadcastLua( ("shizlib.MaxPlayers = %s or 0"):format(math.min(53, shizlib.MaxPlayers + #getDonaters())) )
    end)
end

hook.Add("InitPostEntity", "RemoveShitHook", function()
    timer.Simple(0, function()
        hook.Remove("IGS.PlayerPurchasesLoaded", "BalanceRemember")
        createTimer()
    end)
end)
createTimer()