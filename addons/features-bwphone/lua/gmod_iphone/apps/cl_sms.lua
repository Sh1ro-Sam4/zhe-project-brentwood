if not CLIENT then return end
iPhoneOS = iPhoneOS or {}
iPhoneOS.Apps = iPhoneOS.Apps or {}

local function CheckTTTWin(b)
    local lines = {
        {1,2,3}, {4,5,6}, {7,8,9},
        {1,4,7}, {2,5,8}, {3,6,9},
        {1,5,9}, {3,5,7}
    }
    for _, l in ipairs(lines) do
        if b[l[1]] ~= 0 and b[l[1]] == b[l[2]] and b[l[2]] == b[l[3]] then
            return b[l[1]]
        end
    end
    for i=1, 9 do
        if b[i] == 0 then return 0 end
    end
    return 3
end

iPhoneOS.Apps["sms"] = function(appID)
    local theme = iPhoneOS.GetTheme()
        -- === СООБЩЕНИЯ ===
        iPhoneOS.CurrentApp.bgColor = theme.bg
        local currentRecipient = nil
        for i = #iPhoneOS.PhoneData.Sms, 1, -1 do 
            local msg = iPhoneOS.PhoneData.Sms[i]
            if msg.from then currentRecipient = msg.from break end
            if msg.to then currentRecipient = msg.to break end 
        end

        local header = vgui.Create("DPanel", iPhoneOS.CurrentApp)
        header:SetSize(iPhoneOS.SCREEN_W, 85)
        header.Paint = function(self, w, h)
            iPhoneOS.DrawRounded(32, 0, 0, w, 64, theme.bg2)
            iPhoneOS.DrawRounded(0, 0, 32, w, h - 32, theme.bg2)
            draw.SimpleText("Сообщения", "iOS_AppTitle", w/2, 45, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            surface.SetDrawColor(theme.line)
            surface.DrawLine(0, h-1, w, h-1) 
        end

        local recBtn = vgui.Create("DButton", header)
        recBtn:SetPos(iPhoneOS.SCREEN_W/2 - 85, 62)
        recBtn:SetSize(170, 20)
        recBtn:SetText("Кому: " .. (currentRecipient and iPhoneOS.SafeSub(currentRecipient, 10) or "Выберите") .. " v")
        recBtn:SetFont("iOS_IconList")
        recBtn:SetTextColor(theme.accent)
        
        local scroll = vgui.Create("DScrollPanel", iPhoneOS.CurrentApp)
        scroll:SetPos(0, 85)
        scroll:SetSize(iPhoneOS.SCREEN_W, iPhoneOS.SCREEN_H - 145)
        iPhoneOS.StyleScrollbar(scroll, theme)

        local function RefreshMessages()
            scroll:Clear()
            local curY = 10
            if not currentRecipient then 
                local lbl = scroll:Add("DLabel")
                lbl:Dock(TOP)
                lbl:SetTall(60)
                lbl:SetText("Выберите контакт для чата")
                lbl:SetFont("iOS_Text")
                lbl:SetTextColor(theme.subText)
                lbl:SetContentAlignment(5)
                return 
            end
            
            local latestTTTIndex = -1
            for i, msg in ipairs(iPhoneOS.PhoneData.Sms) do 
                if (msg.from == currentRecipient or msg.to == currentRecipient) and msg.type == "ttt" then 
                    latestTTTIndex = i 
                end 
            end

            for i, msg in ipairs(iPhoneOS.PhoneData.Sms) do
                if msg.from ~= currentRecipient and msg.to ~= currentRecipient then continue end
                local bg = scroll:Add("DPanel")
                local isSent = (msg.from == nil)
                local bubbleColor = isSent and theme.accent or theme.bubbleRecv
                local textColor = isSent and color_white or theme.text
                local subColor = isSent and ColorAlpha(color_white, 150) or theme.subText

                if msg.type == "text" or msg.type == "note" then
                    surface.SetFont("iOS_Text")
                    local txtW, txtH = 0, 0
                    local lines = string.Explode("\n", msg.data)
                    for _, line in ipairs(lines) do 
                        local lw, lh = surface.GetTextSize(line)
                        if lw > txtW then txtW = lw end
                        txtH = txtH + lh 
                    end
                    
                    local isNote = (msg.type == "note")
                    local extraH = isNote and 22 or 0
                    local bubbleW = math.Clamp(txtW + 20, isNote and 90 or 40, iPhoneOS.SCREEN_W - 60)
                    local bubbleH = txtH + 16 + extraH
                    
                    bg:SetSize(bubbleW, bubbleH)
                    bg:SetPos(isSent and (iPhoneOS.SCREEN_W - bubbleW - 15) or 15, curY)
                    
                    bg.Paint = function(self, w, h)
                        iPhoneOS.DrawRounded(16, 0, 0, w, h, bubbleColor)
                        if isNote then 
                            draw.SimpleText("Заметка", "iOS_IconList", 10, 8, subColor, TEXT_ALIGN_LEFT)
                            surface.SetDrawColor(ColorAlpha(subColor, 50))
                            surface.DrawLine(10, 24, w - 10, 24)
                            draw.DrawText(msg.data, "iOS_Text", 10, 28, textColor, TEXT_ALIGN_LEFT)
                        else 
                            draw.DrawText(msg.data, "iOS_Text", 10, 8, textColor, TEXT_ALIGN_LEFT) 
                        end
                    end
                elseif msg.type == "drawing" then
                    local bSize = 140
                    bg:SetSize(bSize, bSize)
                    bg:SetPos(isSent and (iPhoneOS.SCREEN_W - bSize - 15) or 15, curY)
                    bg.Paint = function(self, w, h)
                        iPhoneOS.DrawRounded(16, 0, 0, w, h, theme.bubbleRecv)
                        surface.SetDrawColor(theme.text)
                        local scale = bSize / iPhoneOS.SCREEN_W
                        for _, line in ipairs(msg.data) do 
                            for j=1, #line-1 do 
                                surface.DrawLine(line[j].x * scale, line[j].y * scale, line[j+1].x * scale, line[j+1].y * scale) 
                            end 
                        end
                    end
                elseif msg.type == "ttt" then
                    local bSize = 160
                    bg:SetSize(bSize, bSize + 30)
                    bg:SetPos(isSent and (iPhoneOS.SCREEN_W - bSize - 15) or 15, curY)
                    local board = msg.data.board
                    local winner = msg.data.winner
                    local am_I_X = msg.data.starter_is_me
                    local is_my_turn = false
                    local moves = 0
                    
                    for k=1, 9 do if board[k] ~= 0 then moves = moves + 1 end end
                    
                    if winner == 0 and i == latestTTTIndex then 
                        if am_I_X and moves % 2 == 0 then is_my_turn = true end
                        if not am_I_X and moves % 2 == 1 then is_my_turn = true end 
                    end
                    
                    bg.Paint = function(self, w, h)
                        iPhoneOS.DrawRounded(16, 0, 0, w, h, theme.bubbleRecv)
                        local statTxt = "Игра завершена"
                        local statCol = theme.subText
                        if winner == 0 then 
                            statTxt = is_my_turn and "Ваш ход!" or "Ожидание хода..."
                            statCol = is_my_turn and theme.accent or theme.subText
                        elseif winner == 3 then 
                            statTxt = "Ничья!" 
                        elseif (winner == 1 and am_I_X) or (winner == 2 and not am_I_X) then 
                            statTxt = "Вы победили!"
                            statCol = Color(46, 204, 113) 
                        else 
                            statTxt = "Вы проиграли :("
                            statCol = Color(231, 76, 60) 
                        end
                        draw.SimpleText(statTxt, "iOS_IconList", w/2, 10, statCol, TEXT_ALIGN_CENTER)
                        surface.SetDrawColor(theme.line)
                        surface.DrawLine(55, 30, 55, h-10)
                        surface.DrawLine(105, 30, 105, h-10)
                        surface.DrawLine(10, 30 + 46, w-10, 30 + 46)
                        surface.DrawLine(10, 30 + 92, w-10, 30 + 92)
                    end
                    for row=0, 2 do 
                        for col=0, 2 do
                            local idx = row * 3 + col + 1
                            local btn = vgui.Create("DButton", bg)
                            btn:SetPos(10 + col * 50, 30 + row * 46)
                            btn:SetSize(40, 40)
                            btn:SetText("")
                            btn.Paint = function(self, w, h)
                                local val = board[idx]
                                if val == 1 then 
                                    draw.SimpleText("X", "iOS_BigIcon", w/2, h/2, theme.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
                                elseif val == 2 then 
                                    draw.SimpleText("O", "iOS_BigIcon", w/2, h/2, Color(231, 76, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
                                elseif is_my_turn and self:IsHovered() then 
                                    iPhoneOS.DrawRounded(8, 0, 0, w, h, ColorAlpha(theme.accent, 30)) 
                                end
                            end
                            btn.DoClick = function()
                                if is_my_turn and board[idx] == 0 then
                                    local newBoard = table.Copy(board)
                                    newBoard[idx] = am_I_X and 1 or 2
                                    local newWinner = CheckTTTWin(newBoard)
                                    if newWinner ~= 0 then iPhoneOS.PlayUISound("Win") else iPhoneOS.PlayUISound("Rollover") end
                                    table.insert(iPhoneOS.PhoneData.Sms, {type="ttt", data={ board = newBoard, winner = newWinner, starter_is_me = am_I_X }, to=currentRecipient})
                                    iPhoneOS.SavePhoneData()
                                    net.Start("iPhone_SendSMS")
                                    net.WriteString(currentRecipient)
                                    net.WriteString("ttt")
                                    net.WriteType({ board = newBoard, winner = newWinner, starter_is_me = not am_I_X })
                                    net.SendToServer()
                                    RefreshMessages()
                                end
                            end
                        end 
                    end
                end
                curY = curY + bg:GetTall() + 10
            end
            timer.Simple(0.01, function() 
                if IsValid(scroll) then 
                    local canvas = scroll:GetCanvas()
                    if IsValid(canvas) then scroll:GetVBar():SetScroll(canvas:GetTall()) end 
                end 
            end)
        end

        recBtn.Paint = function() end
        recBtn.DoClick = function()
            local menu = DermaMenu()
            local recentContacts = {}
            local added = {}
            for i = #iPhoneOS.PhoneData.Sms, 1, -1 do 
                local c = iPhoneOS.PhoneData.Sms[i].from or iPhoneOS.PhoneData.Sms[i].to
                if c and not added[c] then table.insert(recentContacts, c); added[c] = true end 
            end
            local hasPlayers = false
            for _, ply in ipairs(player.GetAll()) do 
                if ply ~= LocalPlayer() then 
                    hasPlayers = true
                    menu:AddOption(ply:Nick(), function() 
                        currentRecipient = ply:Nick()
                        recBtn:SetText("Кому: " .. iPhoneOS.SafeSub(ply:Nick(), 10) .. " v")
                        RefreshMessages() 
                    end) 
                end 
            end
            for _, c in ipairs(recentContacts) do
                local isOnline = false
                for _, ply in ipairs(player.GetAll()) do 
                    if ply:Nick() == c then isOnline = true break end 
                end
                if not isOnline then 
                    hasPlayers = true
                    menu:AddOption(c .. " (Оффлайн)", function() 
                        currentRecipient = c
                        recBtn:SetText("Кому: " .. iPhoneOS.SafeSub(c, 10) .. " v")
                        RefreshMessages() 
                    end) 
                end
            end
            if not hasPlayers then menu:AddOption("Нет контактов", function() end) end
            menu:Open()
        end
        
        if IsValid(_G.iPhoneFrame_Global) then _G.iPhoneFrame_Global.RefreshSMS = RefreshMessages end
        RefreshMessages()

        local entryBg = vgui.Create("DPanel", iPhoneOS.CurrentApp)
        entryBg:SetPos(0, iPhoneOS.SCREEN_H - 60)
        entryBg:SetSize(iPhoneOS.SCREEN_W, 60)
        entryBg.Paint = function(self, w, h) 
            surface.SetDrawColor(theme.line)
            surface.DrawLine(0, 0, w, 0)
            iPhoneOS.DrawRounded(16, 0, 0, w, h, theme.bg2)
        end

        local txtEntry = vgui.Create("DTextEntry", entryBg)
        txtEntry:SetPos(45, 10)
        txtEntry:SetSize(iPhoneOS.SCREEN_W - 100, 35)
        txtEntry:SetFont("iOS_Text")
        txtEntry:SetPlaceholderText("Сообщение...")
        txtEntry.Paint = function(self, w, h) 
            iPhoneOS.DrawRounded(16, 0, 0, w, h, theme.bg)
            self:DrawTextEntryText(theme.text, theme.accent, theme.text) 
        end
        txtEntry.OnGetFocus = function() if IsValid(_G.iPhoneFrame_Global) then _G.iPhoneFrame_Global:SetKeyboardInputEnabled(true) end end
        txtEntry.OnLoseFocus = function() if IsValid(_G.iPhoneFrame_Global) then _G.iPhoneFrame_Global:SetKeyboardInputEnabled(false) end end

        local sendBtn = vgui.Create("DButton", entryBg)
        sendBtn:SetPos(iPhoneOS.SCREEN_W - 50, 10)
        sendBtn:SetSize(40, 35)
        sendBtn:SetText("")
        sendBtn.Paint = function(self, w, h) 
            surface.SetDrawColor(iPhoneOS.PhoneData.AirplaneMode and Color(100,100,100) or theme.accent)
            surface.DrawPoly({{x=w/2-5, y=h/2-8}, {x=w/2+8, y=h/2}, {x=w/2-5, y=h/2+8}}) 
        end
        sendBtn.DoClick = function()
            if iPhoneOS.PhoneData.AirplaneMode then iPhoneOS.ShowPhoneNotification("Ошибка", "Авиарежим включен", Color(231, 76, 60)); return end
            if not currentRecipient then iPhoneOS.ShowPhoneNotification("Ошибка", "Выберите кому отправить!", Color(231, 76, 60)); return end
            local text = txtEntry:GetValue()
            if text ~= "" then
                table.insert(iPhoneOS.PhoneData.Sms, {type="text", data=text, to=currentRecipient})
                iPhoneOS.SavePhoneData()
                net.Start("iPhone_SendSMS")
                net.WriteString(currentRecipient)
                net.WriteString("text")
                net.WriteType(text)
                net.SendToServer()
                txtEntry:SetValue("")
                iPhoneOS.PlayUISound("SendSMS")
                RefreshMessages()
            end
        end
        txtEntry.OnEnter = sendBtn.DoClick

        local attachBtn = vgui.Create("DButton", entryBg)
        attachBtn:SetPos(10, 10)
        attachBtn:SetSize(30, 35)
        attachBtn:SetText("+")
        attachBtn:SetFont("iOS_Title")
        attachBtn:SetTextColor(theme.subText)
        attachBtn.Paint = function() end
        attachBtn.DoClick = function()
            if iPhoneOS.PhoneData.AirplaneMode then iPhoneOS.ShowPhoneNotification("Ошибка", "Авиарежим включен", Color(231, 76, 60)); return end
            if not currentRecipient then iPhoneOS.ShowPhoneNotification("Ошибка", "Выберите кому отправить!", Color(231, 76, 60)); return end
            local menu = DermaMenu()
            menu:AddOption("Игра: Крестики-Нолики", function()
                table.insert(iPhoneOS.PhoneData.Sms, {type="ttt", data={ board = {0,0,0,0,0,0,0,0,0}, winner = 0, starter_is_me = true }, to=currentRecipient})
                iPhoneOS.SavePhoneData()
                net.Start("iPhone_SendSMS")
                net.WriteString(currentRecipient)
                net.WriteString("ttt")
                net.WriteType({ board = {0,0,0,0,0,0,0,0,0}, winner = 0, starter_is_me = false })
                net.SendToServer()
                RefreshMessages()
                iPhoneOS.PlayUISound("SendSMS")
            end)
            local drawSub, _ = menu:AddSubMenu("Отправить рисунок")
            if #iPhoneOS.PhoneData.Drawings == 0 then 
                drawSub:AddOption("Нет рисунков", function() end) 
            else
                for i, drawing in ipairs(iPhoneOS.PhoneData.Drawings) do
                    drawSub:AddOption("Рисунок #" .. i, function()
                        table.insert(iPhoneOS.PhoneData.Sms, {type="drawing", data=drawing, to=currentRecipient})
                        iPhoneOS.SavePhoneData()
                        net.Start("iPhone_SendSMS")
                        net.WriteString(currentRecipient)
                        net.WriteString("drawing")
                        net.WriteType(drawing)
                        net.SendToServer()
                        RefreshMessages()
                        iPhoneOS.PlayUISound("SendSMS")
                    end)
                end
            end
            local noteSub, _ = menu:AddSubMenu("Отправить заметку")
            if #iPhoneOS.PhoneData.Notes == 0 then 
                noteSub:AddOption("Нет заметок", function() end) 
            else
                for i, note in ipairs(iPhoneOS.PhoneData.Notes) do
                    noteSub:AddOption(iPhoneOS.SafeSub(note, 15) .. "...", function()
                        table.insert(iPhoneOS.PhoneData.Sms, {type="note", data=note, to=currentRecipient})
                        iPhoneOS.SavePhoneData()
                        net.Start("iPhone_SendSMS")
                        net.WriteString(currentRecipient)
                        net.WriteString("note")
                        net.WriteType(note)
                        net.SendToServer()
                        RefreshMessages()
                        iPhoneOS.PlayUISound("SendSMS")
                    end)
                end
            end
            menu:Open()
        end
end
