/*
    C0NFUSE NET-SPAM
*/

local concommand_Add = concommand.Add
local IsValid = IsValid
local print = print
local string_format = string.format
local timer_Create = timer.Create
local ipairs = ipairs
local player_GetHumans = player.GetHumans
local hook_Add = hook.Add

libfuse = libfuse or {}
libfuse.NetLimit = 300
libfuse.NetLogger = true

concommand_Add('libfuse_netlogger', function(ply)
    if not IsValid(ply) or ply:IsSuperAdmin() then // проверка на то игрок супер админ или консоль!
        libfuse.NetLogger = not libfuse.NetLogger
    end
end)

function net.Incoming( len, ply )
    if ply.libfuse_net_kick then return end
    ply.libfuse_net_sec = ply.libfuse_net_sec ~= nil and ply.libfuse_net_sec + 1 or 1

    local name = util.NetworkIDToString(net.ReadHeader())
    
    if libfuse.NetLogger and name ~= "NetStreamDS" then
        -- print(string_format('%s (%s) запустил net [%s]', ply:Name(), ply:SteamID(), name or "unknown"))
        shizlib.msg( ("%s(%s) start network [%s]"):format(ply:Name(), ply:SteamID(), name or "unknown") )
        PlayerSendNetDS(ply,("%s(%s) start network [%s]"):format(ply:Name(), ply:SteamID(), name or "unknown"))
    end

    if ply.libfuse_net_sec > libfuse.NetLimit then

        ply:Kick( string_format('Вы были кикнуты за спам NET\'ом [%s]', name) ) // анти сын шлюхи!
        shizlib.msg( ("Player %s(%s) was kicked for net spam"):format(ply:Name(), ply:SteamID()) )
        -- gmnetwork.DisconnectClientSilent(ply:UserID()) -- ВЕСЕЛУХА ХЭППИ ХАУС

        ply.libfuse_net_kick = true
    end

    if not name then return end
    local func = net.Receivers[ name:lower() ]
    if not func then return end

    len = len - 16
    func( len, ply )
end

timer_Create("LibFuse:NWDead", 1, 0, function()
    for _, ply in ipairs(player_GetHumans()) do
        ply.libfuse_net_sec = 0
    end
end)

hook_Add("PlayerInitialSpawn", "LibFuse:SetToZeroOnSpawn", function(ply)
    ply.libfuse_net_sec = 0
    ply.libfuse_net_kick = false
end)
