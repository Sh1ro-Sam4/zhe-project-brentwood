-- concommand.Add("testdo", function(_,_,_, item)
--     for k, v in pairs(onyx.items) do
--         if k == "killme" then
--             net.Start("OnyxDonate")
--                 net.WriteString(k)
--             net.SendToServer()
--         end
--     end
-- end)
print"onyx.Donate.CLIENT | Loaded"


-- net.Receive("OnyxPermaWep", function()
--     local data = net.ReadTable()
--     local info = util.TableToJSON(data)
--     for k, v in pairs(data) do
--         print(string.format('Оружие %s в состоянии %s', k, v))
--     end
-- end)


function ChangeWepTogg(class)
    net.Start("OnyxToggleWep")
        net.WriteString(class)
    net.SendToServer()
end