local playerKills = playerKills or {}

local firstKillMessages = {
    "Я... я его убил.",
    "Мои руки дрожат. Я не хотел этого...",
    "Впервые в жизни... я отнял чью-то жизнь. Мне плохо.",
    "Это был я. Я убил. Не могу в это поверить.",
    "Сердце колотится. Я перешёл черту..."
}

local subsequentKillMessages = {
    "Ещё один труп.",
    "Счёт теряю, но мне всё равно.",
    "Очередной. Ничего нового.",
    "Убивать стало скучно."
}

hook.Remove("HomigradDamage", "killcounter", function(ply, dmgInfo, hitgroup, ent)
    local attacker = dmgInfo:GetAttacker()
    local victim = ply

    if not attacker:IsPlayer() then return end
    if not victim:IsPlayer() then return end
    if attacker == victim then return end
    if attacker == game.GetWorld() then return end
    if IsCop(attacker:GetPlayerClass()) then return end

    timer.Simple(0, function()
        if not victim:Alive() then
            playerKills[attacker] = (playerKills[attacker] or 0) + 1
            local totalKills = playerKills[attacker]
            local message = nil

            if totalKills == 1 then
                message = table.Random(firstKillMessages)
                attacker.organism.adrenalineAdd = attacker.organism.adrenalineAdd + 5
                attacker.organism.heartbeat = attacker.organism.heartbeat + 180
            elseif totalKills > 10 then
                message = table.Random(subsequentKillMessages)
            end

            if message then
                attacker:Notify(message, 20, "kill", 0, nil, color_white)
            end
        end
    end)

    timer.Simple(2, function()
        attacker:ResetNotification("kill")
    end)
end)

hook.Add("PlayerDisconnected", "cleanupKillCounter", function(ply)
    playerKills[ply] = nil
end)