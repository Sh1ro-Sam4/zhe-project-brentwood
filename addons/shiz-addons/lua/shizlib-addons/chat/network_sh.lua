if SERVER then
    util.AddNetworkString('shizlib-Chat')
    util.AddNetworkString('shizlib-Chat1')

    local Player = FindMetaTable('Player')

    function shizlib.Broadcast(...)
        netstream.Start(nil, 'client_lua', {code = "chat.AddText(" .. unpack(...) .. ")"})
    end

    function Player:ChatPrint(a)
        netstream.Start(self, 'client_lua', {code = "chat.AddText(color_white, '" .. a .. "')"})
    end

    local message_tbl = {
        'Правила: https://bit.ly/melonbwrules',
        'Discord: https://discord.gg/a8H9eUTcgR',
        'Есть какие то вопросы/жалобы на игроков? Откройте C Menu -> Вызвать админа -> Опишите вашу проблему',
        'Вы нашли баг? Или у вас есть идея как сделать игру на сервере интереснее? Предлагайте свои идеи в нашем Discord: https://discord.gg/a8H9eUTcgR',
    }

    timer.Remove('Broadcast-SelfProviding:)', 180, 0, function()
        netstream.Start(nil, 'client_lua', {code = "chat.AddText(color_white, '[INFO] " .. table.Random(message_tbl) .. "')"})
    end)
else
    net.Receive('shizlib-Chat', function(len)
        local tbl = net.ReadTable()
        chat.AddText(unpack(tbl))
    end)
    net.Receive('shizlib-Chat1', function(len)
        local tbl = net.ReadString()
        chat.AddText(color_white, net.ReadString())
    end)
end

if SERVER then
    util.AddNetworkString('shizlib.ToggleChat')

    net.Receive('shizlib.ToggleChat', function(len, pl)
        local isTyping = net.ReadBool()
        if pl:GetNWBool('InCall') then
            pl:SetNWBool('IsTyping', true)
        else
            pl:SetNWBool('IsTyping', isTyping)
        end
    end)

    hook.Add('PlayerConnect', 'shizlib-ChatNotifyConnecting', function(name, ip)
        netstream.Start(nil, 'client_lua', {code = [[chat.AddText(color_white, '(CONNECT) ]] .. string.format('%s подключается на сервер! (1/3)', name) .. [[')]]})
        -- shizlib.Broadcast(Color(0,0,0), '(CONNECT) ', string.format('%s подключается на сервер! (1/2)', name))
    end)

    hook.Add('PlayerInitialSpawn', 'shizlib-ChatNotifyConnecting1', function(ply)
        netstream.Start(nil, 'client_lua', {code = [[chat.AddText(color_white, '(CONNECT) ]] .. string.format('%s подключается на сервер (2/3)', ply:Name()) .. [[')]]})
        -- shizlib.Broadcast(Color(0,0,0), '(CONNECT) ', string.format('%s подключился на сервер (2/2)', ply:Name()))
    end)

    hook.Add('LibFuse:PlayerFullyLoad', 'shizlib-ChatNotifyConnecting', function(ply)
        netstream.Start(nil, 'client_lua', {code = [[chat.AddText(color_white, '(CONNECT) ]] .. string.format('%s подключился на сервер (3/3)', ply:Name()) .. [[')]]})
    end)

    hook.Add('PlayerDisconnected', 'shizlib-ChatNotifyDisconnecting', function(ply)
        netstream.Start(nil, 'client_lua', {code = "chat.AddText(color_white, '(DISCONNECT) " .. string.format( '%s вышел с сервера', ply:Name() ) .. "')"})
        -- shizlib.Broadcast(Color(0,0,0), '(DISCONNECT) ', string.format('%s вышел с сервера', ply:Name()))
    end)

    util.AddNetworkString("shizlib.Say")
    net.Receive("shizlib.Say", function(len, ply)
        -- Защита от спам-эксплойтов
        if (ply.NextChatTime or 0) > CurTime() then return end
        ply.NextChatTime = CurTime() + 0.1

        local text = net.ReadString()
        local teamOnly = net.ReadBool()

        text = string.Trim(text)
        if text == "" then return end

        text = string.sub(text, 1, 2000)

        local result = hook.Run("PlayerSay", ply, text, teamOnly)

        if type(result) == "string" and result ~= "" then
            
        end
    end)
end