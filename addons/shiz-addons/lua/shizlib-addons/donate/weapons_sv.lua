local meta = FindMetaTable( 'Player' )
local entity = FindMetaTable( 'Entity' )

function meta:GetPermaWep()
    local data = self:GetOnyxData('OnyxPermaWep')
    return util.JSONToTable(data)
end

function meta:SetPermaWep(class)

    local old = self:GetPermaWep()
    old[class] = 'on'
    local new = util.TableToJSON(old)

    self:SetOnyxData('OnyxPermaWep', new)
    print(self:GetPermaWep())
end

function meta:SendPermaWepToCL()
    local send = self:GetPermaWep()
    net.Start('OnyxPermaWep')
        net.WriteTable(send)
    net.Send(self)
end

netstream.Hook('shiz-donate', function(ply)
    ply:SendPermaWepToCL()
end)

function meta:ToggleSpawnWeapon(class)
    local data = self:GetPermaWep()
    if not data[class] then return end
    
    if data[class] == 'on' then
        data[class] = 'off'
    elseif data[class] == 'off' then
        data[class] = 'on'
    end

    local new = util.TableToJSON(data)
    self:SetOnyxData('OnyxPermaWep', new)
end

net.Receive('OnyxToggleWep', function(len, ply)
    local data = ply:GetPermaWep()
    local class = net.ReadString()
    if not data[class] then ply:ChatPrint('У вас нет этого оружия') return end

    ply:ToggleSpawnWeapon(class)
    ply:ChatPrint( ('%s %s выдаватья при спавне'):format(onyx.Donate[class].name, data[class] == 'on' and 'будет' or 'не будет') )
end)

hook.Add('PlayerSpawn', 'givedongun', function(ply)

    if ply:GetOnyxData('OnyxPermaWep') == nil then ply:SetOnyxData('OnyxPermaWep', '{}') end
    local guns = ply:GetPermaWep()

    for k,v in pairs(guns) do
        if v == 'on' then
            timer.Simple(.1, function()
                local wep = ply:Give(tostring(k))
                wep.NoDrop = true
            end)
        end
    end

    if ply:GetOnyxData('ammo_bag') then
        timer.Simple(.1, function()
            ply:GiveAmmo(500, "ar2", true)
            ply:GiveAmmo(500, "Pistol", true)
            ply:GiveAmmo(500, "Buckshot", true)
            ply:GiveAmmo(500, "smg1", true)
            ply:GiveAmmo(500, "Uranium", true)
            ply:GiveAmmo(500, 11, true) // S.L.A.M.
        end)
    end
end)

hook.Remove('EntityTakeDamage', 'shizlib.Donate.Weapons', function(target, dmginfo)
    local inflictor = dmginfo:GetAttacker()
    if not target:IsValidPlayer() or not inflictor:IsValidPlayer() then return end
    if inflictor:Alive() and inflictor:GetActiveWeapon() and inflictor:GetActiveWeapon():GetClass() == 'weapon_gauss' then
        dmginfo:ScaleDamage(.5)
    end
end)