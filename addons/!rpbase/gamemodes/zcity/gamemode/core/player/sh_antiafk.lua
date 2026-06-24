if (SERVER) then
    local AfkPlayers = {}
    
    hook.Remove("PlayerInitialSpawn", "AfkKickInit", function(ply)
        AfkPlayers[ply] = {
            time = 0,
            lastPos = ply:GetPos()
        }
    end)
    
    hook.Remove("PlayerDisconnected", "AfkKickCleanup", function(ply)
        AfkPlayers[ply] = nil
    end)
    
    timer.Remove("afk_kick_check", 1, 0, function()
        for ply, data in pairs(AfkPlayers) do
            if IsValid(ply) then
                local currentPos = ply:GetPos()
                local distSqr = data.lastPos:DistToSqr(currentPos)
                
                if distSqr <= 25 then
                    data.time = data.time + 1
                    
                    if data.time >= 600 then
                        ply:Kick("Вы были кикнуты за бездействие!")
                        AfkPlayers[ply] = nil
                    end
                else
                    data.time = 0
                    data.lastPos = currentPos
                end
            else
                AfkPlayers[ply] = nil
            end
        end
    end)
end