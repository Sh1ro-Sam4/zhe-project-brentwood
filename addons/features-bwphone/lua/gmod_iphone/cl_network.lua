if not CLIENT then return end

iPhoneOS = iPhoneOS or {}

-- === СЕТЬ ===
net.Receive("iPhone_SendSMS", function()
    local senderName = net.ReadString()
    local msgType = net.ReadString()
    local msgData = net.ReadType()
    
    table.insert(iPhoneOS.PhoneData.Sms, {type = msgType, data = msgData, from = senderName})
    if msgType == "note" then 
        table.insert(iPhoneOS.PhoneData.ReceivedNotes, 1, msgData) 
    end
    iPhoneOS.SavePhoneData()
    
    if IsValid(_G.iPhoneFrame_Global) and _G.iPhoneFrame_Global.RefreshSMS then 
        _G.iPhoneFrame_Global.RefreshSMS() 
    end
    
    local title = msgType == "ttt" and "Крестики-Нолики" or "Новое сообщение"
    iPhoneOS.ShowPhoneNotification(title, "От: " .. iPhoneOS.SafeSub(senderName, 12), Color(10, 132, 255), "sms")
end)

net.Receive("iPhone_Call", function()
    local callerEnt = net.ReadEntity()
    local callerName = net.ReadString()
    
    if iPhoneOS.PhoneData.AirplaneMode then 
        net.Start("iPhone_CallResponse")
        net.WriteEntity(callerEnt)
        net.WriteBool(false)
        net.SendToServer()
        iPhoneOS.AddNotification("Пропущенный", callerName, Color(231, 76, 60), "call_screen")
        return 
    end
    
    iPhoneOS.CallData.state = "incoming"
    iPhoneOS.CallData.targetEnt = callerEnt
    iPhoneOS.CallData.targetName = callerName
    
    if IsValid(_G.iPhoneFrame_Global) then iPhoneOS.LaunchApp("call_screen") end
    
    if iPhoneOS.PhoneData.Sounds then
        LocalPlayer():EmitSound(iPhoneOS.PhoneSounds.Ringtone, 75, 100, 1, CHAN_AUTO)
        timer.Create("iPhone_Ringtone", iPhoneOS.PhoneSounds.RingtoneDuration, 0, function() 
            if iPhoneOS.CallData.state == "incoming" then 
                LocalPlayer():EmitSound(iPhoneOS.PhoneSounds.Ringtone, 75, 100, 1, CHAN_AUTO) 
            else 
                timer.Remove("iPhone_Ringtone") 
            end 
        end)
    end
end)

net.Receive("iPhone_CallResponse", function()
    local responderEnt = net.ReadEntity()
    local accepted = net.ReadBool()
    iPhoneOS.StopCallSounds()
    
    if accepted then 
        iPhoneOS.CallData.state = "active"
        iPhoneOS.CallData.startTime = CurTime()
        if iPhoneOS.CurrentApp and iPhoneOS.CurrentApp.appID == "call_screen" then iPhoneOS.LaunchApp("call_screen") end
    else 
        iPhoneOS.CallData.state = "none"
        iPhoneOS.ShowPhoneNotification("Звонок", "Абонент отклонил вызов", Color(231, 76, 60), "home")
        if iPhoneOS.CurrentApp and iPhoneOS.CurrentApp.appID == "call_screen" then iPhoneOS.LaunchApp("home") end 
    end
end)

net.Receive("iPhone_EndCall", function()
    iPhoneOS.CallData.state = "none"
    iPhoneOS.StopCallSounds()
    iPhoneOS.ShowPhoneNotification("Звонок", "Вызов завершен", Color(150, 150, 150), "home")
    if iPhoneOS.CurrentApp and iPhoneOS.CurrentApp.appID == "call_screen" then iPhoneOS.LaunchApp("home") end
end)

iPhoneOS.BankBalance = 0
net.Receive("iPhone_BankReceiveBalance", function()
    iPhoneOS.BankBalance = net.ReadInt(32)
    if IsValid(_G.iPhoneFrame_Global) and _G.iPhoneFrame_Global.RefreshBankBalance then
        _G.iPhoneFrame_Global.RefreshBankBalance()
    end
end)
net.Receive("iPhone_BankSync", function()
    local type = net.ReadInt(8)
    
    if type == 0 then
        iPhoneOS.ShowPhoneNotification("Банк", "Недостаточно средств!", Color(231, 76, 60), "bank")
        return
    end
    local otherName = net.ReadString()
    local amount = net.ReadInt(32)

    if type == 1 then
        table.insert(iPhoneOS.PhoneData.Transactions, 1, { type = "out", name = otherName, amount = amount, time = os.time() })
        iPhoneOS.ShowPhoneNotification("Банк", "Перевод " .. amount .. "$ выполнен", Color(46, 204, 113), "bank")
    elseif type == 2 then
        table.insert(iPhoneOS.PhoneData.Transactions, 1, { type = "in", name = otherName, amount = amount, time = os.time() })
        iPhoneOS.ShowPhoneNotification("Банк", "Поступление " .. amount .. "$", Color(46, 204, 113), "bank")
        iPhoneOS.PlayUISound("Notification")
    end
    if #iPhoneOS.PhoneData.Transactions > 50 then table.remove(iPhoneOS.PhoneData.Transactions) end
    iPhoneOS.SavePhoneData()
    if IsValid(_G.iPhoneFrame_Global) and _G.iPhoneFrame_Global.RefreshBankHistory then
        _G.iPhoneFrame_Global.RefreshBankHistory()
    end
end)