iPhoneOS = iPhoneOS or {}
iPhoneOS.Apps = iPhoneOS.Apps or {}

iPhoneOS.Apps["bank"] = function(appID)
    local theme = iPhoneOS.GetTheme()
    iPhoneOS.CurrentApp.bgColor = theme.bg
    
    -- Запрашиваем баланс с сервера при открытии приложения
    net.Start("iPhone_BankRequestBalance")
    net.SendToServer()

    local currentTab = "history"
    local header = vgui.Create("DPanel", iPhoneOS.CurrentApp)
    header:SetSize(iPhoneOS.SCREEN_W, 160)
    header.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(32, 0, 0, w, 64, theme.bg2)
        iPhoneOS.DrawRounded(0, 0, 32, w, h - 32, theme.bg2)
        
        -- Полоска снизу
        surface.SetDrawColor(theme.line)
        surface.DrawLine(0, h-1, w, h-1)
        
        draw.SimpleText("Мобильный Банк", "iOS_AppTitle", w/2, 40, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Текущий баланс", "iOS_IconList", w/2, 75, theme.subText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("$ " .. string.Comma(iPhoneOS.BankBalance), "iOS_CallName", w/2, 105, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Контейнер для вкладок
    local contentArea = vgui.Create("DPanel", iPhoneOS.CurrentApp)
    contentArea:SetPos(0, 210)
    contentArea:SetSize(iPhoneOS.SCREEN_W, iPhoneOS.SCREEN_H - 210)
    contentArea.Paint = function() end

    local historyScroll, transferPanel
    local RefreshHistory

    -- === ВКЛАДКА ИСТОРИИ ===
    historyScroll = vgui.Create("DScrollPanel", contentArea)
    historyScroll:Dock(FILL)
    iPhoneOS.StyleScrollbar(historyScroll, theme)

    RefreshHistory = function()
        historyScroll:Clear()
        
        if not iPhoneOS.PhoneData.Transactions or #iPhoneOS.PhoneData.Transactions == 0 then
            local lbl = historyScroll:Add("DLabel")
            lbl:Dock(TOP)
            lbl:SetTall(60)
            lbl:SetText("История транзакций пуста")
            lbl:SetFont("iOS_Text")
            lbl:SetTextColor(theme.subText)
            lbl:SetContentAlignment(5)
            return
        end

        for _, tr in ipairs(iPhoneOS.PhoneData.Transactions) do
            local pnl = historyScroll:Add("DPanel")
            pnl:Dock(TOP)
            pnl:SetTall(65)
            pnl.Paint = function(self, w, h)
                iPhoneOS.DrawRounded(12, 10, 5, w - 20, 55, theme.bg2)
                
                local isOut = (tr.type == "out")
                local icon = isOut and "↑" or "↓"
                local color = isOut and Color(231, 76, 60) or Color(46, 204, 113)
                
                -- Иконка
                iPhoneOS.DrawRounded(8, 20, 17, 30, 30, ColorAlpha(color, 30))
                draw.SimpleText(icon, "iOS_Title", 35, 32, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Текст
                draw.SimpleText(isOut and "Перевод кому:" or "Перевод от:", "iOS_IconList", 60, 20, theme.subText, TEXT_ALIGN_LEFT)
                draw.SimpleText(iPhoneOS.SafeSub(tr.name, 12), "iOS_Text", 60, 38, theme.text, TEXT_ALIGN_LEFT)

                -- Сумма
                local sign = isOut and "-" or "+"
                draw.SimpleText(sign .. " $" .. string.Comma(tr.amount), "iOS_AppTitle", w - 25, 32, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
    end

    -- === ВКЛАДКА ПЕРЕВОДА ===
    transferPanel = vgui.Create("DPanel", contentArea)
    transferPanel:Dock(FILL)
    transferPanel:SetVisible(false)
    transferPanel.Paint = function() end

    local lblWho = vgui.Create("DLabel", transferPanel)
    lblWho:SetPos(15, 10)
    lblWho:SetText("Выберите получателя:")
    lblWho:SetFont("iOS_Text")
    lblWho:SetTextColor(theme.subText)
    lblWho:SizeToContents()

    local comboPly = vgui.Create("DComboBox", transferPanel)
    comboPly:SetPos(15, 35)
    comboPly:SetSize(iPhoneOS.SCREEN_W - 30, 40)
    comboPly:SetFont("iOS_Text")
    comboPly:SetValue("Нажмите для выбора...")
    comboPly:SetTextColor(theme.text)
    comboPly.Paint = function(self, w, h)
        iPhoneOS.DrawRounded(12, 0, 0, w, h, theme.bg2)
    end
    for _, ply in ipairs(player.GetAll()) do
        if ply ~= LocalPlayer() then comboPly:AddChoice(ply:Nick()) end
    end

    local lblAmount = vgui.Create("DLabel", transferPanel)
    lblAmount:SetPos(15, 90)
    lblAmount:SetText("Сумма перевода:")
    lblAmount:SetFont("iOS_Text")
    lblAmount:SetTextColor(theme.subText)
    lblAmount:SizeToContents()

    local entryAmount = vgui.Create("DTextEntry", transferPanel)
    entryAmount:SetPos(15, 115)
    entryAmount:SetSize(iPhoneOS.SCREEN_W - 30, 40)
    entryAmount:SetFont("iOS_AppTitle")
    entryAmount:SetNumeric(true)
    entryAmount:SetPlaceholderText("0")
    entryAmount.Paint = function(self, w, h)
        iPhoneOS.DrawRounded(12, 0, 0, w, h, theme.bg2)
        self:DrawTextEntryText(theme.text, theme.accent, theme.text)
    end
    entryAmount.OnGetFocus = function() if IsValid(_G.iPhoneFrame_Global) then _G.iPhoneFrame_Global:SetKeyboardInputEnabled(true) end end
    entryAmount.OnLoseFocus = function() if IsValid(_G.iPhoneFrame_Global) then _G.iPhoneFrame_Global:SetKeyboardInputEnabled(false) end end

    local btnSend = vgui.Create("DButton", transferPanel)
    btnSend:SetPos(15, 175)
    btnSend:SetSize(iPhoneOS.SCREEN_W - 30, 50)
    btnSend:SetText("Отправить деньги")
    btnSend:SetFont("iOS_AppTitle")
    btnSend:SetTextColor(color_white)
    btnSend.Paint = function(self, w, h)
        -- Кнопка теперь цвета текущей темы
        local col = self:IsHovered() and ColorAlpha(theme.accent, 200) or theme.accent
        iPhoneOS.DrawRounded(16, 0, 0, w, h, col)
    end
    btnSend.DoClick = function()
        if iPhoneOS.PhoneData.AirplaneMode then 
            iPhoneOS.ShowPhoneNotification("Ошибка", "Авиарежим включен", Color(231, 76, 60)) 
            return 
        end
        
        local target = comboPly:GetValue()
        local amt = tonumber(entryAmount:GetValue())

        if target == "Нажмите для выбора..." or target == "" then
            iPhoneOS.ShowPhoneNotification("Ошибка", "Выберите игрока!", Color(231, 76, 60))
            return
        end
        if not amt or amt <= 0 then
            iPhoneOS.ShowPhoneNotification("Ошибка", "Введите корректную сумму!", Color(231, 76, 60))
            return
        end
        if amt > iPhoneOS.BankBalance then
            iPhoneOS.ShowPhoneNotification("Ошибка", "Недостаточно средств!", Color(231, 76, 60))
            return
        end

        iPhoneOS.PlayUISound("Click")
        net.Start("iPhone_BankTransfer")
        net.WriteString(target)
        net.WriteInt(amt, 32)
        net.SendToServer()
        
        entryAmount:SetValue("")
    end

    -- Кнопки переключения вкладок
    local tabHistory = vgui.Create("DButton", iPhoneOS.CurrentApp)
    tabHistory:SetPos(20, 170)
    tabHistory:SetSize((iPhoneOS.SCREEN_W-40)/2, 30)
    tabHistory:SetText("История")
    tabHistory:SetFont("iOS_IconList")
    
    local tabTransfer = vgui.Create("DButton", iPhoneOS.CurrentApp)
    tabTransfer:SetPos(20 + (iPhoneOS.SCREEN_W-40)/2, 170)
    tabTransfer:SetSize((iPhoneOS.SCREEN_W-40)/2, 30)
    tabTransfer:SetText("Перевод")
    tabTransfer:SetFont("iOS_IconList")

    local function UpdateTabs()
        tabHistory:SetTextColor(currentTab == "history" and theme.text or theme.subText)
        tabTransfer:SetTextColor(currentTab == "transfer" and theme.text or theme.subText)
        
        historyScroll:SetVisible(currentTab == "history")
        transferPanel:SetVisible(currentTab == "transfer")
        
        if currentTab == "history" then RefreshHistory() end
    end

    tabHistory.Paint = function(self, w, h)
        if currentTab == "history" then
            surface.SetDrawColor(theme.accent) -- Полоска активной вкладки цветом темы
            surface.DrawLine(0, h-2, w, h-2)
        end
    end
    tabHistory.DoClick = function() 
        currentTab = "history" 
        UpdateTabs() 
        iPhoneOS.PlayUISound("Click") 
    end
    
    tabTransfer.Paint = function(self, w, h)
        if currentTab == "transfer" then
            surface.SetDrawColor(theme.accent) -- Полоска активной вкладки цветом темы
            surface.DrawLine(0, h-2, w, h-2)
        end
    end
    tabTransfer.DoClick = function() 
        currentTab = "transfer" 
        UpdateTabs() 
        iPhoneOS.PlayUISound("Click") 
    end

    UpdateTabs()

    if IsValid(_G.iPhoneFrame_Global) then
        _G.iPhoneFrame_Global.RefreshBankBalance = function()
            header:SetTooltip("update") 
        end
        _G.iPhoneFrame_Global.RefreshBankHistory = function()
            if currentTab == "history" then RefreshHistory() end
        end
    end
end