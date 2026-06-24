DoorSys = DoorSys or {}

util.AddNetworkString("DoorSys.BuyMenu")
util.AddNetworkString("DoorSys.OpenMenu")
util.AddNetworkString("DoorSys.Action")

local function setDoorLocked(ent, locked)
    if not IsValid(ent) then return end
    if locked then
        ent:Fire("Lock", "", 0)
        ent:Fire("Close", "", 0)
    else
        ent:Fire("Unlock", "", 0)
    end
    ent:SetNWBool("DoorSys.Locked", locked and true or false)
end

local function setOwner(ent, sid64)
    ent:SetNWString("DoorSys.Owner", sid64 or "")
end

hook.Add("InitPostEntity", "DoorSys.InitDoors", function()
    for _, ent in ipairs(ents.GetAll()) do
        if ent.IsManagedDoor and ent:IsManagedDoor() then
            local d = ent:GetDoorCfg()
            if d and d.Locked ~= nil then
                setDoorLocked(ent, d.Locked)
            end
        end
    end
end)

hook.Add("PlayerButtonDown", "DoorSys.PlayerF2", function(ply, button)
    if button ~= KEY_F2 then return end
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    local tr = ply:GetEyeTrace()
    local ent = tr.Entity
    
    if not IsValid(ent) or not ent.IsManagedDoor or not ent:IsManagedDoor() then return end

    local d = ent:GetDoorCfg()
    if not d then return end

    if ent:IsDoorForTeamsOnly() then
        if ent:TeamHasAccess(ply:GetPlayerClass()) then
            return
        end
        return
    end

    local owner = ent:GetDoorOwnerSID64()
    local sid64 = ply:SteamID64()

    if owner == "" or owner == sid64 or ent:IsDoorCoOwner(sid64) then
        net.Start("DoorSys.OpenMenu")
            net.WriteEntity(ent)
        net.Send(ply)
    end
end)

net.Receive("DoorSys.Action", function(_, ply)
    local ent = net.ReadEntity()
    local action = net.ReadString()
    local targetSid64 = net.ReadString()

    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not IsValid(ent) or not ent.IsManagedDoor or not ent:IsManagedDoor() then return end

    local d = ent:GetDoorCfg()
    if not d then return end

    if ent:IsDoorForTeamsOnly() then return end

    local price = ent:GetDoorPrice()
    local owner = ent:GetDoorOwnerSID64()
    local sid64 = ply:SteamID64()

    if action == "add_coowner" then
        if owner ~= sid64 then return end
        if not targetSid64 or targetSid64 == "" or targetSid64 == sid64 then return end

        local target = player.GetBySteamID64(targetSid64)
        if not IsValid(target) then return end

        local doorCfg = ent:GetDoorCfg()
        local doorsToUpdate = {}
        for _, e in ipairs(ents.GetAll()) do
            if e:IsManagedDoor() then
                local e_cfg = e:GetDoorCfg()
                if e_cfg and e_cfg.Name == doorCfg.Name and e:GetDoorOwnerSID64() == sid64 then
                    table.insert(doorsToUpdate, e)
                end
            end
        end

        for _, door in ipairs(doorsToUpdate) do
            local coowners = door:GetDoorCoOwners() or {}
            if not table.HasValue(coowners, targetSid64) then
                table.insert(coowners, targetSid64)
                door:SetDoorCoOwners(coowners)
            end
        end

        for _, wep in ipairs(cfg.dooritems) do
            local wepEnt = target:Give(wep)
            if IsValid(wepEnt) then wepEnt.UnDroppable = true end
        end

        notif(ply, "Вы добавили " .. target:Nick() .. " в совладельцы.")
        notif(target, "Вы стали совладельцем " .. ent:GetDoorDisplayName() .. ".")
        return
    end

    if action == "remove_coowner" then
        if owner ~= sid64 then return end
        if not targetSid64 or targetSid64 == "" or targetSid64 == sid64 then return end
    
        local doorCfg = ent:GetDoorCfg()
        local doorsToUpdate = {}
        for _, e in ipairs(ents.GetAll()) do
            if e:IsManagedDoor() then
                local e_cfg = e:GetDoorCfg()
                if e_cfg and e_cfg.Name == doorCfg.Name and e:GetDoorOwnerSID64() == sid64 then
                    table.insert(doorsToUpdate, e)
                end
            end
        end
    
        for _, door in ipairs(doorsToUpdate) do
            local coowners = door:GetDoorCoOwners() or {}
            local newCoowners = {}
            for _, v in ipairs(coowners) do
                if v ~= targetSid64 then
                    table.insert(newCoowners, v)
                end
            end
            door:SetDoorCoOwners(newCoowners)
        end
    
        local target = player.GetBySteamID64(targetSid64)

        if IsValid(target) then
            for _, wep in ipairs(cfg.dooritems) do
                target:StripWeapon(wep)
            end
            notif(target, "Вы больше не совладелец " .. ent:GetDoorDisplayName() .. ".")
        end
        
        notif(ply, "Вы убрали игрока из совладельцев.")
        return
    end

    if action == "buy" then
        if owner ~= "" then return end
        if price <= 0 then return end
        if not ply:CanAfford(price) then return end
        if ply:OwnsAnyHouseDoor() then notif(ply, 'У вас уже есть купленный дом!') return end

        local doorCfg = ent:GetDoorCfg()

        local doorsToBuy = {}
        for _, e in ipairs(ents.GetAll()) do
            if e:IsManagedDoor() then
                local e_cfg = e:GetDoorCfg()
                if e_cfg and e_cfg.Name == doorCfg.Name and not e:HasDoorOwner() then
                    table.insert(doorsToBuy, e)
                end
            end
        end

        if #doorsToBuy == 0 then return end

        for _, door in ipairs(doorsToBuy) do
            setOwner(door, sid64)
            door:SetDoorCoOwners({})
            setDoorLocked(door, false)
        end

        ply:SubtractMoney(price)

        for _, wep in ipairs(cfg.dooritems) do
            local wepEnt = ply:Give(wep)
            if IsValid(wepEnt) then wepEnt.UnDroppable = true end
        end

        notif(ply, "Вы купили " .. ent:GetDoorDisplayName() .. " за " .. FormatMoney(price) .. ".")
        hook.Run("playerBoughtDoor", ply, ent, price)
        return
    end

    if action == "sell" then
        if owner == "" then return end
        if owner ~= sid64 then return end

        local doorCfg = ent:GetDoorCfg()

        -- Забираем предметы у всех совладельцев
        local coowners = ent:GetDoorCoOwners() or {}
        for _, coownerSid in ipairs(coowners) do
            local target = player.GetBySteamID64(coownerSid)
            if IsValid(target) then
                for _, wep in ipairs(cfg.dooritems) do
                    target:StripWeapon(wep)
                end
                notif(target, "Владелец продал " .. ent:GetDoorDisplayName() .. ", вы больше не совладелец.")
            end
        end

        local doorsToSell = {}
        for _, e in ipairs(ents.GetAll()) do
            if e:IsManagedDoor() and e:GetDoorOwnerSID64() == sid64 then
                local e_cfg = e:GetDoorCfg()
                if e_cfg and e_cfg.Name == doorCfg.Name then
                    table.insert(doorsToSell, e)
                end
            end
        end

        for _, door in ipairs(doorsToSell) do
            setOwner(door, "")
            door:SetDoorCoOwners({})
            local dCfg = door:GetDoorCfg()
            if dCfg and dCfg.Locked ~= nil then
                setDoorLocked(door, dCfg.Locked)
            end
        end

        local refund = math.floor((ent:GetDoorPrice() > 0 and ent:GetDoorPrice() or doorCfg.defaultprice) * 0.5)

        ply:AddMoney(refund)

        for _, wep in ipairs(cfg.dooritems) do
            ply:StripWeapon(wep)
        end

        notif(ply, "Вы продали " .. ent:GetDoorDisplayName() .. " за " .. FormatMoney(refund) .. ".")
        hook.Run("playerSellDoor", ply, ent)
        return
    end
end)

hook.Add("PlayerDisconnected", "DoorSys.DisconnectSell", function(ply)
    local sid64 = ply:SteamID64()
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent.IsManagedDoor and ent:IsManagedDoor() then
            local owner = ent:GetDoorOwnerSID64()
            if owner == sid64 then
                local d = ent:GetDoorCfg()
                
                local coowners = ent:GetDoorCoOwners() or {}
                for _, coownerSid in ipairs(coowners) do
                    local target = player.GetBySteamID64(coownerSid)
                    if IsValid(target) then
                        if cfg and cfg.dooritems then
                            for _, wep in ipairs(cfg.dooritems) do
                                target:StripWeapon(wep)
                            end
                        end
                        notif(target, "Владелец покинул сервер. Дом продан, вы больше не совладелец.")
                    end
                end

                setOwner(ent, "")
                ent:SetDoorCoOwners({})
                
                if d and d.Locked ~= nil then
                    setDoorLocked(ent, d.Locked)
                end
            end
        end
    end
end)

concommand.Add("sellhouse", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    local sid64 = ply:SteamID64()
    local targetEnt = nil
    local doorCfg = nil
    for _, e in ipairs(ents.GetAll()) do
        if IsValid(e) and e.IsManagedDoor and e:IsManagedDoor() then
            if e:GetDoorOwnerSID64() == sid64 then
                targetEnt = e
                doorCfg = e:GetDoorCfg()
                break
            end
        end
    end
    if not targetEnt or not doorCfg then return end

    local coowners = targetEnt:GetDoorCoOwners() or {}
    for _, coownerSid in ipairs(coowners) do
        local target = player.GetBySteamID64(coownerSid)
        if IsValid(target) then
            for _, wep in ipairs(cfg.dooritems) do
                target:StripWeapon(wep)
            end
            notif(target, "Владелец продал дом через консоль. Вы больше не совладелец.")
        end
    end

    local doorsToSell = {}
    for _, e in ipairs(ents.GetAll()) do
        if e:IsManagedDoor() and e:GetDoorOwnerSID64() == sid64 then
            local e_cfg = e:GetDoorCfg()
            if e_cfg and e_cfg.Name == doorCfg.Name then
                table.insert(doorsToSell, e)
            end
        end
    end
    for _, door in ipairs(doorsToSell) do
        setOwner(door, "")
        door:SetDoorCoOwners({})
        local d = door:GetDoorCfg()
        if d and d.Locked ~= nil then
            setDoorLocked(door, d.Locked)
        end
    end
    local refund = math.floor((targetEnt:GetDoorPrice() > 0 and targetEnt:GetDoorPrice() or doorCfg.defaultprice) * 0.5)
    ply:AddMoney(refund)
    
    for _, wep in ipairs(cfg.dooritems) do
        ply:StripWeapon(wep)
    end

    notif(ply, "Вы продали " .. targetEnt:GetDoorDisplayName() .. " за " .. FormatMoney(refund) .. ".")
    hook.Run("playerSellDoor", ply, targetEnt)
end)