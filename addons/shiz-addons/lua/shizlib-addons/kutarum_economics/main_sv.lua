util.AddNetworkString( "KutEcon_Sync" )
util.AddNetworkString( "KutEcon_SyncLicenses" )

function ECONOMICS.Sync()
    local ent = ents.FindByClass("rob_bank_vault_money")[1]
    if IsValid(ent) then
        ent:SetHeldMoney(ECONOMICS.BUDGET.amount)
    end
    --ent.SessionStolen = 250000
    timer.Simple( 0, function()
        net.Start( "KutEcon_Sync" )
            net.WriteFloat( ECONOMICS.BUDGET.amount )
            net.WriteTable( ECONOMICS.Licenses )
            net.WriteTable( ECONOMICS.Taxes )
        net.Broadcast()
    end )
end

-- concommand.Add( "econ_set_budget", function( ply, cmd, args )
--     ECONOMICS.BUDGET.Set( args[1] )
-- end )

local BUDGET = ECONOMICS.BUDGET
util.AddNetworkString("MayorMenu_Action")
util.AddNetworkString("MayorMenu_UpdateTaxes")

local function IsMayor(ply)
    return ply:GetPlayerClass() == TEAM_MAYOR
end

local function IsPolice(ply)
    local policeTeams = {
        [TEAM_POLICE] = true,
        [TEAM_POLICE_PLUS] = true,
        [TEAM_SWAT] = true,
        [TEAM_FBI] = true
    }
    return policeTeams[ply:GetPlayerClass()]
end

local function IsMedic(ply)
    return ply:GetPlayerClass() == TEAM_MEDIC
end

local lastWithdraw = 0
net.Receive("MayorMenu_Action", function(len, ply)
    if not IsMayor(ply) then return end

    local action = net.ReadString()
    local amount = net.ReadUInt(32)

    if amount <= 0 then return end

    if action == "deposit" then
        if ply:CanAfford(amount) then
            ply:AddMoney(-amount)
            ECONOMICS.BUDGET.Add(amount)
            DarkRP.notify(ply, 0, 4, "Вы пополнили казну на " .. amount .. "$")
        else
            DarkRP.notify(ply, 1, 4, "У вас недостаточно средств!")
        end

    elseif action == "withdraw" then
        if lastWithdraw > CurTime() then
            DarkRP.notify(ply, 1, 4, ("Нужно подождать еще %s секунд"):format(math.floor(lastWithdraw - CurTime())))
            return
        end
        if ECONOMICS.BUDGET.Get() >= amount then
            lastWithdraw = CurTime() + 300
            ECONOMICS.BUDGET.Add(-amount)
            ply:AddMoney(amount)
            DarkRP.notify(ply, 0, 4, "Вы взяли из казны " .. amount .. "$")
        else
            DarkRP.notify(ply, 1, 4, "В казне недостаточно средств!")
        end

    elseif action == "bonus_police" or action == "bonus_medic" or action == "bonus_everyone" then
        local receivers = {}
        
        for _, v in ipairs(player.GetAll()) do
            if action == "bonus_police" and IsPolice(v) then
                table.insert(receivers, v)
            elseif action == "bonus_medic" and IsMedic(v) then
                table.insert(receivers, v)
            elseif action == "bonus_everyone" then
                table.insert(receivers, v)
            end
        end

        local totalCost = amount * #receivers

        if totalCost == 0 then
            DarkRP.notify(ply, 1, 4, "Нет сотрудников онлайн для выдачи премии.")
            return
        end

        if ECONOMICS.BUDGET.Get() >= totalCost then
            ECONOMICS.BUDGET.Add(-totalCost)
            
            for _, receiver in ipairs(receivers) do
                hook_Run("playerGetSalary", receiver, amount)
                DarkRP.notify(receiver, 0, 5, "Мэр выдал вам премию: " .. amount .. "$!")
            end
            
            DarkRP.notify(ply, 0, 4, "Вы выдали премию! Из казны списано " .. totalCost .. "$")
        else
            DarkRP.notify(ply, 1, 4, "В казне недостаточно денег! Требуется: " .. totalCost .. "$")
        end
    end
end)

net.Receive("MayorMenu_UpdateTaxes", function(len, ply)
    if not IsMayor(ply) then return end

    local newTaxes = net.ReadTable()

    for k, v in pairs(newTaxes) do
        if ECONOMICS.Taxes[k] ~= nil then
            ECONOMICS.Taxes[k] = math.Clamp(tonumber(v) or 0, 0, 1)
        end
    end

    ECONOMICS.Sync()
    
    DarkRP.notify(ply, 0, 4, "Налоговые ставки успешно обновлены!")
    
    for _, v in ipairs(player.GetAll()) do
        DarkRP.notify(v, 0, 5, "Мэр изменил налоговые ставки!")
    end
end)

-- Костыли кутарума

local attsOnSpawn = {
    "grip2",
    "supressor2",
    "laser4",
    "holo14",
    "holo17",
    "optic2",
    "supressor7",
    "laser2",
    "holo16",
    "holo11",
}

hook.Remove( "PlayerSpawn", "MisterKostylevsky", function( plyv )
	if IsValid(plyv) and CanUseArsenal(plyv:GetPlayerClass()) then
		for i, att in ipairs( attsOnSpawn ) do
            plyv.inventory = plyv:GetNetVar("Inventory") or plyv.inventory
            plyv.inventory.Attachments[#plyv.inventory.Attachments + 1] = att
            plyv:SetNetVar("Inventory",plyv.inventory)
        end
	end
end )