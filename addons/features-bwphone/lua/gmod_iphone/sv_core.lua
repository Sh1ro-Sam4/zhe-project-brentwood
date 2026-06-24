if not SERVER then return end

print("[iPhone] Серверная часть успешно загружена! Регистрирую сеть...")

-- === СЕТЕВЫЕ СТРОКИ ===
util.AddNetworkString("iPhone_SendSMS")
util.AddNetworkString("iPhone_Call")
util.AddNetworkString("iPhone_CallResponse")
util.AddNetworkString("iPhone_EndCall")
util.AddNetworkString("iPhone_StateChange")

-- Сетевые строки для банка
util.AddNetworkString("iPhone_BankRequestBalance")
util.AddNetworkString("iPhone_BankReceiveBalance")
util.AddNetworkString("iPhone_BankTransfer")
util.AddNetworkString("iPhone_BankSync")

local ActiveCalls = {}  
local RingingCalls = {} 

-- === ЗВОНКИ И ГОЛОС ===
hook.Add("PlayerCanHearPlayersVoice", "iPhone_CallVoice", function(listener, talker)
    if ActiveCalls[listener] == talker or ActiveCalls[talker] == listener then
        return true, false 
    end
end)

net.Receive("iPhone_SendSMS", function(len, ply)
    local targetName = net.ReadString()
    local msgType = net.ReadString()
    local msgData = net.ReadType()

    for _, target in ipairs(player.GetAll()) do
        if target:Nick() == targetName then
            net.Start("iPhone_SendSMS")
            net.WriteString(ply:Nick())
            net.WriteString(msgType)
            net.WriteType(msgData)
            net.Send(target)
            break
        end
    end
end)

net.Receive("iPhone_Call", function(len, ply)
    local targetName = net.ReadString()
    local targetPly = nil
    for _, v in ipairs(player.GetAll()) do
        if v:Nick() == targetName then 
            targetPly = v 
            break 
        end
    end
    if not IsValid(targetPly) or targetPly == ply then return end
    
    if ActiveCalls[targetPly] or RingingCalls[targetPly] then 
        net.Start("iPhone_EndCall")
        net.Send(ply)
        return 
    end
    
    RingingCalls[targetPly] = ply
    RingingCalls[ply] = targetPly
    
    net.Start("iPhone_Call")
    net.WriteEntity(ply)
    net.WriteString(ply:Nick())
    net.Send(targetPly)
end)

net.Receive("iPhone_CallResponse", function(len, ply)
    local accepted = net.ReadBool()
    local callerEnt = RingingCalls[ply]
    if IsValid(callerEnt) then
        net.Start("iPhone_CallResponse")
        net.WriteEntity(ply)
        net.WriteBool(accepted)
        net.Send(callerEnt)
        if accepted then
            ActiveCalls[ply] = callerEnt
            ActiveCalls[callerEnt] = ply
            ply:SetNWBool("InCall", true)
            ply:SetNWBool("IsTyping", true)
            callerEnt:SetNWBool("InCall", true)
            callerEnt:SetNWBool("IsTyping", true)
        end
        RingingCalls[callerEnt] = nil
    end
    RingingCalls[ply] = nil
end)

net.Receive("iPhone_EndCall", function(len, ply)
    local other = ActiveCalls[ply] or RingingCalls[ply]
    if IsValid(other) then
        net.Start("iPhone_EndCall")
        net.Send(other)
        ActiveCalls[other] = nil
        RingingCalls[other] = nil
        other:SetNWBool("InCall", false)
        other:SetNWBool("IsTyping", false)
    end
    ActiveCalls[ply] = nil
    RingingCalls[ply] = nil
    ply:SetNWBool("InCall", false)
    ply:SetNWBool("IsTyping", false)
end)

hook.Add("PlayerDisconnected", "iPhone_CallDisconnect", function(ply)
    local other = ActiveCalls[ply] or RingingCalls[ply]
    if IsValid(other) then
        net.Start("iPhone_EndCall")
        net.Send(other)
        ActiveCalls[other] = nil
        RingingCalls[other] = nil
        other:SetNWBool("InCall", false)
        other:SetNWBool("IsTyping", false)
    end
    ActiveCalls[ply] = nil
    RingingCalls[ply] = nil
end)

hook.Add("PlayerDeath", "iPhone_CallDeath", function(ply)
    local other = ActiveCalls[ply] or RingingCalls[ply]
    if IsValid(other) then
        net.Start("iPhone_EndCall")
        net.Send(other)
        ActiveCalls[other] = nil
        RingingCalls[other] = nil
        other:SetNWBool("InCall", false)
        other:SetNWBool("IsTyping", false)
    end
    ActiveCalls[ply] = nil
    RingingCalls[ply] = nil
    ply:SetNWBool("InCall", false)
    ply:SetNWBool("IsTyping", false)
end)

net.Receive("iPhone_BankRequestBalance", function(len, ply)
    if (ply.NextBankRequest or 0) > CurTime() then return end
    ply.NextBankRequest = CurTime() + 1 

    BraxBank.PlayerMoney(ply, function(money)
        if not IsValid(ply) then return end
        net.Start("iPhone_BankReceiveBalance")
        net.WriteInt(money, 32)
        net.Send(ply)
    end)
end)

net.Receive("iPhone_BankTransfer", function(len, ply)
    if (ply.NextBankTransfer or 0) > CurTime() then return end
    ply.NextBankTransfer = CurTime() + 2

    local targetName = net.ReadString()
    local amount = net.ReadInt(32)
    if not amount or amount <= 0 then return end

    BraxBank.PlayerMoney(ply, function(senderMoney)
        if not IsValid(ply) then return end
        if senderMoney < amount then
            net.Start("iPhone_BankSync")
            net.WriteInt(0, 8) 
            net.Send(ply)
            return
        end

        local targetPly = nil
        for _, v in ipairs(player.GetAll()) do
            if v:Nick() == targetName then 
                targetPly = v 
                break 
            end
        end
        if not IsValid(targetPly) or targetPly == ply then return end

        BraxBank.PlayerMoney(targetPly, function(targetMoney)
            if not IsValid(ply) or not IsValid(targetPly) then return end

            BraxBank.UpdateMoney(ply, senderMoney - amount, function()
                if not IsValid(ply) or not IsValid(targetPly) then return end

                BraxBank.UpdateMoney(targetPly, targetMoney + amount, function()
                    if not IsValid(ply) or not IsValid(targetPly) then return end

                    net.Start("iPhone_BankSync")
                    net.WriteInt(1, 8)
                    net.WriteString(targetPly:Nick())
                    net.WriteInt(amount, 32)
                    net.Send(ply)

                    net.Start("iPhone_BankSync")
                    net.WriteInt(2, 8)
                    net.WriteString(ply:Nick())
                    net.WriteInt(amount, 32)
                    net.Send(targetPly)

                    BraxBankAtmUpdate(ply)
                    BraxBankAtmUpdate(targetPly)

                    BraxBank.PlayerMoney(ply, function(newSenderBalance)
                        if IsValid(ply) then
                            net.Start("iPhone_BankReceiveBalance")
                            net.WriteInt(newSenderBalance, 32)
                            net.Send(ply)
                        end
                    end)

                    BraxBank.PlayerMoney(targetPly, function(newTargetBalance)
                        if IsValid(targetPly) then
                            net.Start("iPhone_BankReceiveBalance")
                            net.WriteInt(newTargetBalance, 32)
                            net.Send(targetPly)
                        end
                    end)
                end)
            end)
        end)
    end)
end)

net.Receive("iPhone_StateChange", function(len, ply)
    if not IsValid(ply) then return end
    if (ply.NextiPhoneStateChange or 0) > CurTime() then return end
    ply.NextiPhoneStateChange = CurTime() + 2

    local opened = net.ReadBool()
    local playerName = ply:GetNWString("PlayerName", ply:Name())
    local color = Color(255, 255, 255)
    local chatdist = (cfg and cfg.chatdist) or 450
    
    local actionText = opened and "достал(а) телефон" or "убрал(а) телефон"
    
    for _, target in ipairs(player.GetAll()) do
        if IsValid(target) and target:GetPos():Distance(ply:GetPos()) <= chatdist then
            sendMessageCustom(target, color, playerName .. " " .. actionText)
        end
    end
end)