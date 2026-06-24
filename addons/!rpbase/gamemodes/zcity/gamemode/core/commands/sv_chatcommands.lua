util.AddNetworkString("ChatMessageCool")

function sendMessageCustom(pl, ...)
    args = {...}
    net.Start("ChatMessageCool")
    net.WriteTable(args)
    net.Send(pl)
end

local function processChat(pl, str, team)
    local args = string.Split(str, " ")
    local commandname = args[1]:sub(2, #str)
    commandname = string.lower(commandname)
    if not commands[commandname] then return false end
    
    table.remove(args, 1)
    
    if #args == 0 then
        return false
    end
    
    commands[commandname].cb(pl, args)
    return true
end

hook.Add("PlayerSay", "rp.ChatCommandsRun", function(pl, str, team)
    str = string.Trim(str)
    
    if str == "" then
        return ""
    end
    
    if string.StartWith(str, "/") or string.StartWith(str, "!") then
        local found = processChat(pl, str, team)
        if found then
            return ""
        end
    else
        if string.Trim(str) == "" then
            return ""
        end
    end
end)