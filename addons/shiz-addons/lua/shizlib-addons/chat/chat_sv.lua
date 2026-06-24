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