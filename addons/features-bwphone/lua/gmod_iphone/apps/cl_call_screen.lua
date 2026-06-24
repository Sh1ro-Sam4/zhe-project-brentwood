if not CLIENT then return end
iPhoneOS = iPhoneOS or {}
iPhoneOS.Apps = iPhoneOS.Apps or {}

iPhoneOS.Apps["call_screen"] = function(appID)
    local theme = iPhoneOS.GetTheme()
        iPhoneOS.CurrentApp.bgColor = theme.bg

        local ava = vgui.Create("AvatarImage", iPhoneOS.CurrentApp)
        ava:SetPos(iPhoneOS.SCREEN_W/2 - 50, 120)
        ava:SetSize(100, 100)
        if IsValid(iPhoneOS.CallData.targetEnt) then 
            ava:SetPlayer(iPhoneOS.CallData.targetEnt, 128) 
        end

        local nameLbl = vgui.Create("DLabel", iPhoneOS.CurrentApp)
        nameLbl:SetPos(0, 240)
        nameLbl:SetSize(iPhoneOS.SCREEN_W, 40)
        nameLbl:SetFont("iOS_CallName")
        nameLbl:SetTextColor(theme.text)
        nameLbl:SetText(iPhoneOS.CallData.targetName)
        nameLbl:SetContentAlignment(5)

        local statusLbl = vgui.Create("DLabel", iPhoneOS.CurrentApp)
        statusLbl:SetPos(0, 280)
        statusLbl:SetSize(iPhoneOS.SCREEN_W, 30)
        statusLbl:SetFont("iOS_AppTitle")
        statusLbl:SetTextColor(theme.subText)
        statusLbl:SetContentAlignment(5)

        local btnY = iPhoneOS.SCREEN_H - 160

        if iPhoneOS.CallData.state == "incoming" then
            statusLbl:SetText("Входящий вызов...")
            local btnDecline = vgui.Create("DButton", iPhoneOS.CurrentApp)
            btnDecline:SetSize(74, 74)
            btnDecline:SetPos(40, btnY)
            btnDecline:SetText("Сброс")
            btnDecline:SetFont("iOS_Text")
            btnDecline:SetTextColor(color_white)
            btnDecline.Paint = function(self, w, h) iPhoneOS.DrawRounded(w/2, 0, 0, w, h, Color(231, 76, 60)) end
            btnDecline.DoClick = function(self)
                self:SetEnabled(false)
                iPhoneOS.PlayUISound("Click")
                iPhoneOS.CallData.state = "none"
                timer.Remove("iPhone_Ringtone")
                net.Start("iPhone_CallResponse")
                net.WriteBool(false)
                net.SendToServer()
                iPhoneOS.LaunchApp("home")
            end

            local btnAccept = vgui.Create("DButton", iPhoneOS.CurrentApp)
            btnAccept:SetSize(74, 74)
            btnAccept:SetPos(iPhoneOS.SCREEN_W - 114, btnY)
            btnAccept:SetText("Принять")
            btnAccept:SetFont("iOS_Text")
            btnAccept:SetTextColor(color_white)
            btnAccept.Paint = function(self, w, h) iPhoneOS.DrawRounded(w/2, 0, 0, w, h, Color(46, 204, 113)) end
            btnAccept.DoClick = function(self)
                self:SetEnabled(false)
                iPhoneOS.PlayUISound("Click")
                iPhoneOS.CallData.state = "active"
                iPhoneOS.CallData.startTime = CurTime()
                timer.Remove("iPhone_Ringtone")
                net.Start("iPhone_CallResponse")
                net.WriteBool(true)
                net.SendToServer()
                iPhoneOS.LaunchApp("call_screen")
            end

        elseif iPhoneOS.CallData.state == "calling" then
            statusLbl:SetText("Вызов...")
            local btnEnd = vgui.Create("DButton", iPhoneOS.CurrentApp)
            btnEnd:SetSize(74, 74)
            btnEnd:SetPos(iPhoneOS.SCREEN_W/2 - 37, btnY)
            btnEnd:SetText("Отмена")
            btnEnd:SetFont("iOS_Text")
            btnEnd:SetTextColor(color_white)
            btnEnd.Paint = function(self, w, h) iPhoneOS.DrawRounded(w/2, 0, 0, w, h, Color(231, 76, 60)) end
            btnEnd.DoClick = function(self)
                self:SetEnabled(false)
                iPhoneOS.PlayUISound("Click")
                iPhoneOS.CallData.state = "none"
                net.Start("iPhone_EndCall")
                net.SendToServer()
                iPhoneOS.LaunchApp("home")
            end

        elseif iPhoneOS.CallData.state == "active" then
            statusLbl.Think = function(self)
                local dur = math.floor(CurTime() - iPhoneOS.CallData.startTime)
                self:SetText(string.format("%02d:%02d", math.floor(dur / 60), dur % 60))
            end
            local btnEnd = vgui.Create("DButton", iPhoneOS.CurrentApp)
            btnEnd:SetSize(74, 74)
            btnEnd:SetPos(iPhoneOS.SCREEN_W/2 - 37, btnY)
            btnEnd:SetText("Сброс")
            btnEnd:SetFont("iOS_Text")
            btnEnd:SetTextColor(color_white)
            btnEnd.Paint = function(self, w, h) iPhoneOS.DrawRounded(w/2, 0, 0, w, h, Color(231, 76, 60)) end
            btnEnd.DoClick = function(self)
                self:SetEnabled(false)
                iPhoneOS.PlayUISound("Click")
                iPhoneOS.CallData.state = "none"
                net.Start("iPhone_EndCall")
                net.SendToServer()
                iPhoneOS.LaunchApp("home")
            end
        else
            iPhoneOS.LaunchApp("home")
        end
end
