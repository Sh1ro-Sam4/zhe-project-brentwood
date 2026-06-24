function rp.AddChatCommand(command, deistvie)
    hook.Add("PlayerSay", "rp_" .. command, function(ply, text, team)
        local lowerText = string.lower(text)
        if string.StartWith(lowerText, "!" .. command .. " ") or string.StartWith(lowerText, "/" .. command .. " ") 
        or lowerText == "!" .. command or lowerText == "/" .. command then
            deistvie(ply, text, team)
            return ""
        end
    end)
end

commands = {}
function rp.AddChatCommandd(name, func)
    commands[name] = {
         cb = func,
         aliases = {name}
        }
    return commands[name]
end