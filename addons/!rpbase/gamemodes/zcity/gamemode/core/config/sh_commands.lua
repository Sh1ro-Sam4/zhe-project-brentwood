--- [[ RP ACTS ]] ---

rp.AddChatCommand("ds", function(ply, text, team)
    ply:SendLua([[gui.OpenURL("https://discord.com/invite/cSmhecewkY")]])
end)

rp.AddChatCommand("acceptorg", function(ply, text, team)
    ply:ConCommand("acceptorg")
end)

local function dropmoney(ply, text, team)
    local amount = tonumber(string.match(text, "%d+"))
    if not amount or amount <= 0 then
        ply:ChatPrint("Используйте: /dropmoney [сумма]")
        return
    end

    if amount > 2147483647 then
        ply:ChatPrint("Вы не можете выбросить так много денег за один раз!")
        return
    end

    if not ply:CanAfford(amount) then return end

    ply:DelayedAction('dropmoney', 'Выбрасывание денег', {
        time = 1.5,
        check = function() return true end,
        succ = function()
            if not ply:CanAfford(amount) then return end
            ply:SubtractMoney(amount)

            hook.Run("playerDropMoney", ply, tonumber(string.match(text, "%d+")))
            notif(ply, "-" .. FormatMoney(amount), 'fail')


            local trace = {}
            trace.start = ply:EyePos()
            trace.endpos = trace.start + ply:GetAimVector() * 85
            trace.filter = ply

            local tr = util.TraceLine(trace)
            rp.SpawnMoney(tr.HitPos, amount)
        end,
    }, {
        time = 1.5,
        inst = true,
        action = function()
            ply:DoAnimationEvent((ACT_GMOD_GESTURE_ITEM_DROP + math.random(0,1)))
            ply:EmitSound("player/clothes_generic_foley_0" .. math.random(1,5) .. ".wav")
        end,
    })
end
rp.AddChatCommand("dropmoney", dropmoney)

local function givemoney(ply, text, team)
	local tr = hg.eyeTrace(ply).Entity
    local ragowner = hg.RagdollOwner(tr) or tr

	if (tr:IsPlayer() or tr:IsRagdoll()) and tr:GetPos():DistToSqr(ply:GetPos()) < 22500 then
		local amount = tonumber(string.match(text, "%d+"))
        if not amount or amount <= 0 then
            ply:ChatPrint("Используйте: /give [сумма]")
            return
        end

		if not ply:CanAfford(amount) then return end

        ply:DelayedAction('givemoney', 'Передача денег', {
            time = 1.5,
            check = function() return true end,
            succ = function()
                if not ply:CanAfford(amount) then return end
                rp.PayPlayer(ply, ragowner, amount)

                hook.Run('playerGiveMoney', ply, ragowner, amount)

                notif(ply, "Вы дали " .. ragowner:GetNWString("PlayerName") .. ' ' .. FormatMoney(amount), 'ok')
                notif(ragowner, ply:GetNWString("PlayerName") .. ' дал вам ' .. FormatMoney(amount), 'ok')
            end,
        }, {
            time = 1.5,
            inst = true,
            action = function()
                ply:DoAnimationEvent((ACT_GMOD_GESTURE_ITEM_GIVE + math.random(0,1)))
                ply:EmitSound("player/clothes_generic_foley_0" .. math.random(1,5) .. ".wav")
            end,
        })
	else
		notif(ply, "Вы должны смотреть на игрока!", 'fail')
	end
end
rp.AddChatCommand("give", givemoney)
rp.AddChatCommand("givemoney", givemoney)


--rp.AddChatCommand("addswat", function(ply, args)
--    if not ply:GetDRPData("SWAT.Leader") then notif(ply, "Вы не лидер SWAT!") return end
--    args = utf8.sub(args, 10, #args)
--    local target = plogs.FindPlayer(args)
--    if not target then notif(ply, "Игрок не найден!") return end
--
--    target:Notify("Вы были добавлены в SWAT!")
--    target:SetDRPData("SWAT.User", true)
--end)
--
--rp.AddChatCommand("addswatid", function(ply, args)
--    if not ply:GetDRPData("SWAT.Leader") then notif(ply, "Вы не лидер SWAT!") return end
--    args = utf8.sub(args, 12, #args)
--
--    util.SetDRPData(args, "SWAT.User", true)
--end)
--
--rp.AddChatCommand("removeswat", function(ply, args)
--    if not ply:GetDRPData("SWAT.Leader") then notif(ply, "Вы не лидер SWAT!") return end
--    args = utf8.sub(args, 13, #args)
--    local target = plogs.FindPlayer(args)
--    if not target then notif(ply, "Игрок не найден!") return end
--
--    target:SetDRPData("SWAT.User", false)
--end)
--

rp.AddChatCommand("demote", function(ply, args)
    if not ply:GetDRPData("SWAT.Leader") and not ply:GetDRPData("FBI.Leader") and not ply:GetDRPData("POLICE.Leader") and not ply:GetDRPData("FBI.User") and ply:GetPlayerClass() ~= TEAM_MAYOR then
        DarkRP.notify(ply, 1, 4, "Вы не можете пользоваться данной командой!")
        return
    end
    args = utf8.sub(args, 9, #args)

--    local target = plogs.FindPlayer(args)
    if not target then
        DarkRP.notify(ply, 1, 4, "Игрок не найден!")
        return
    end
    if target:GetPlayerClass() == TEAM_MAYOR then
        DarkRP.notify(ply, 1, 4, "Серьезно? Уволить Мэра города?")
        return
    end
    if not IsGov(ply:GetPlayerClass()) then
        DarkRP.notify(ply, 1, 4, "Вы не Гос. служащий")
        return
    end
    if not IsGov(target:GetPlayerClass()) then
        DarkRP.notify(ply, 1, 4, "Вы не можете уволь этого игрока!")
        DarkRP.notify(ply, 1, 4, "Вы можете увольнять только Гос. служащих!")
        return
    end

    target:SetNWInt("LastClassChangeTime", 0)
    rp.SetPlayerClass(target, TEAM_CITIZEN)
end)

rp.AddChatCommand("srt", function(ply)
    if not ply:GetDRPData("SWAT.User") and not ply:GetDRPData("SWAT.Leader") then notif(ply, "Вы не состоите в SWAT!") return end
    if IsSWAT(ply:GetPlayerClass()) then
        rp.SetPlayerClass(ply, TEAM_CITIZEN)
    else
        rp.SetPlayerClass(ply, TEAM_SWAT)
        ply:Spawn()
    end
end)

rp.AddChatCommand("fbi", function(ply)
    if not ply:GetDRPData("FBI.User") and not ply:GetDRPData("FBI.Leader") then notif(ply, "Вы не состоите в FBI!") return end
    if IsFBI(ply:GetPlayerClass()) then
        rp.SetPlayerClass(ply, TEAM_CITIZEN)
    else
        rp.SetPlayerClass(ply, TEAM_FBI)
        ply:Spawn()
    end
end)

rp.AddChatCommand("police", function(ply)
    if not ply:GetDRPData("POLICE.User") and not ply:GetDRPData("POLICE.Leader") then notif(ply, "Вы не состоите в полиции!") return end
    if IsFBI(ply:GetPlayerClass()) then
        rp.SetPlayerClass(ply, TEAM_CITIZEN)
    else
        rp.SetPlayerClass(ply, TEAM_POLICE_PLUS)
        ply:Spawn()
    end
end)



rp.AddChatCommand("job", function(ply, args)
    local tbl
    local i = 0
    args = utf8.sub(args, 6, #args)

    for idx, data in pairs(rp.Classes) do
        if string.find(data.Command, args) then
            tbl = data
            i = idx
            break
        end
    end

    if not tbl or not i then ply:Notify("fatal error") return end
    if tbl.CustomCheck and not tbl.CustomCheck(ply) then return end
    if ply:IsHandcuffed() then ply:Notify("Эхххх бля я не могу поменять профессию в наручниках....") return end
    rp.SetPlayerClass(ply, rp.Classes[i])
end)

rp.AddChatCommand("shit", function(ply)
    if ply:HasFullSpawnMenu() then
        local wep = ply:GetActiveWeapon()
        wep:Remove()
    end
end)

--- [[ RP CHAT ]] ---

local looccol = Color(128,0,0)
local ooccol = Color(100,255,150)
local rollcol = Color(245,120,120)
local colred = Color(245,0,0)
local colw = Color(0,140,255)

local function localrp(pl, args)
    local message = table.concat(args, " ")
    local playerName = pl:GetNWString("PlayerName")
    local color = pl:GetNWVector("PlayerColor"):ToColor()
    if SERVER then
        for _, target in pairs(player.GetAll()) do
            if target:GetPos():Distance(pl:GetPos()) <= cfg.chatdist then
                sendMessageCustom(target, looccol, "[LOOC] ", color, playerName, Color(255,255,255), ": " .. message)
            end
        end
    end
end
rp.AddChatCommandd("looc", localrp)
rp.AddChatCommandd("", localrp)

local function ooc(pl, args)
    if #args == 0 then return end

    if SERVER then
        local currentTime = CurTime()
        
        if pl.OOC_Cooldown and pl.OOC_Cooldown > currentTime then
            pl:ChatPrint("Подождите " .. math.ceil(pl.OOC_Cooldown - currentTime) .. " сек. перед отправкой!")
            return
        end

        pl.OOC_Cooldown = currentTime + 30

        local message = table.concat(args, " ")
        local playerName = pl:GetNWString("PlayerName")
        
        for _, target in pairs(player.GetAll()) do
            sendMessageCustom(target, ooccol, "[OOC] ", pl:GetNWVector("PlayerColor"):ToColor(), playerName, Color(255,255,255), ": " .. message)
        end
    end
end

rp.AddChatCommandd("ooc", ooc)
rp.AddChatCommandd("a", ooc)
rp.AddChatCommandd("/", ooc)

local function rpact(pl, args)
    local message = table.concat(args, " ")
    local playerName = pl:GetNWString("PlayerName")
    local color = Color(255,255,255)
    if SERVER then
        for _, target in pairs(player.GetAll()) do
            if target:GetPos():Distance(pl:GetPos()) <= cfg.chatdist then
                sendMessageCustom(target, color, playerName .. " " .. message)
            end
        end
    end
end
rp.AddChatCommandd("me", rpact)

local function orgchat(pl, args)
    local message = table.concat(args, " ")
    if message == "" then return end
    
    local orgName = pl:GetOrg()
    
    if not orgName then
        if SERVER then pl:ChatPrint("Вы не состоите в организации.") end
        return ""
    end
    
    local orgData = pl:GetOrgData()
    local rank = orgData and orgData.Rank or "Member"
    
    local orgColor = pl:GetOrgColor()
    local playerName = pl:GetNWString("PlayerName", pl:Name())
    local displayMessage = string.format("[%s | %s] %s: %s", orgName, rank, playerName, message)

    if SERVER then
        for _, target in ipairs(player.GetAll()) do
            if target:GetOrg() == orgName then
                sendMessageCustom(target,Color(255,255,255), "[ORG] ", orgColor, displayMessage)
            end
        end
    end
end

rp.AddChatCommandd("org", orgchat)

local function doitrp(pl, args)
    local message = table.concat(args, " ")
    local color = pl:GetNWVector("PlayerColor"):ToColor()
    if SERVER then
        for _, target in pairs(player.GetAll()) do
            if target:GetPos():Distance(pl:GetPos()) <= cfg.chatdist then
                sendMessageCustom(target, color, message)
            end
        end
    end
end
rp.AddChatCommandd("do", doitrp)
rp.AddChatCommandd("it", doitrp)

local function advertrp(pl, args)
    local message = table.concat(args, " ")
    local playerName = pl:GetNWString("PlayerName")
    local color = pl:GetNWVector("PlayerColor"):ToColor()
    if SERVER then
        if not pl:CanAfford(cfg.advertcost) then return end
        pl:SubtractMoney(cfg.advertcost)
        notif(pl, 'Вы купили рекламу за ' .. FormatMoney(cfg.advertcost), 'ok')
        for _, target in pairs(player.GetAll()) do
            sendMessageCustom(target, colred, "[Реклама] ", color, playerName, Color(255,255,255), ": " .. message)
        end
    end
end
rp.AddChatCommandd("advert", advertrp)
rp.AddChatCommandd("ad", advertrp)

local function rproll(pl, args)
    local max = 100
    if args and args[1] and tonumber(args[1]) then
        local num = math.floor(tonumber(args[1]))
        if num > 1 then
            max = num
        end
    end
    
    local result = math.random(1, max)

    local playerName = pl:GetNWString("PlayerName")
    local color = pl:GetNWVector("PlayerColor"):ToColor()
    
    if SERVER then
        for _, target in pairs(ents.FindInSphere(pl:GetPos(), cfg.chatdist)) do
            if target:IsPlayer() and target:Alive() then
                sendMessageCustom(target, rollcol, '[ROLL] ', color, playerName .. " ", color_white, "кинул и выпало ", rollcol, tostring(result), color_white, " из " .. max .. ".")
            end
        end
    end
end
rp.AddChatCommandd("roll", rproll)

local function tryrp(pl, args)
    local message = table.concat(args, " ")
    local playerName = pl:GetNWString("PlayerName")
    local result = table.Random({"УСПЕШНО", "НЕУСПЕШНО"})
    local color = pl:GetNWVector("PlayerColor"):ToColor()
    if SERVER then
        for _, target in pairs(player.GetAll()) do
            if target:GetPos():Distance(pl:GetPos()) <= cfg.chatdist then
                sendMessageCustom(target, rollcol, '[Попытка] ', color, playerName, color_white, ':', rollcol, ' ' .. result, color_white, " " .. message)
            end
        end
    end
end
rp.AddChatCommandd("try", tryrp)

local function wrp(pl, args)
    local message = table.concat(args, " ")
    local playerName = pl:GetNWString("PlayerName")
    local color = pl:GetNWVector("PlayerColor"):ToColor()
    if SERVER then
        for _, target in pairs(player.GetAll()) do
            if target:GetPos():Distance(pl:GetPos()) <= cfg.chatdist - 150 then
                sendMessageCustom(target, colw, "[Шёпот] ", color, playerName, Color(255,255,255), ": " .. message)
            end
        end
    end
end
rp.AddChatCommandd("w", wrp)

local function yrp(pl, args)
    local message = table.concat(args, " ")
    local playerName = pl:GetNWString("PlayerName")
    local color = pl:GetNWVector("PlayerColor"):ToColor()
    if SERVER then
        for _, target in pairs(player.GetAll()) do
            if target:GetPos():Distance(pl:GetPos()) <= cfg.chatdist + 150 then
                sendMessageCustom(target, colw, "[Крик] ", color, playerName, Color(255,255,255), ": " .. message)
            end
        end
    end
end
rp.AddChatCommandd("y", yrp)

local function darkwebrp(pl, args)
    if #args == 0 then return end

    if SERVER then
        local currentTime = CurTime()
        
        if pl.DarkWeb_Cooldown and pl.DarkWeb_Cooldown > currentTime then
            pl:ChatPrint("Подождите " .. math.ceil(pl.DarkWeb_Cooldown - currentTime) .. " сек. перед отправкой в DarkWeb!")
            return
        end

        pl.DarkWeb_Cooldown = currentTime + 30

        local message = table.concat(args, " ")
        
        for _, target in pairs(player.GetAll()) do
            sendMessageCustom(target, looccol, "[DarkWeb] ", pl:GetNWVector("PlayerColor"):ToColor(), 'Аноним', Color(255,255,255), ": " .. message)
        end
    end
end

rp.AddChatCommandd("darkweb", darkwebrp)
rp.AddChatCommandd("dark", darkwebrp)