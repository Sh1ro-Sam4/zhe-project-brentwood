if SERVER then
    function ScrW() return 1920 end
    function ScrH() return 1080 end
end

cats = cats or {}
cats.config = {}

cats.config.spawnSize = { 380, 220 }
cats.config.spawnPosAdmin = { ScrW() - 400, 50 }
cats.config.spawnPosUser = { ScrW() - 400, ScrH() - 250 }
cats.config.defaultRating = 3
cats.config.ratingTimeout = 60
cats.config.newTicketSound = 'report/reportsound.wav'

cats.lang = {
    openTickets = "Открытые жалобы",
    myTicket = "Моя жалоба",
    userDisconnected = "Пользователь вышел",
    claimedBy = "Разбирается",
    sendMessage = "Написать сообщение...",
    typeYourMessage = "Введите сообщение:",
    actions = "Действия",
    action_claim = "Взять жалобу",
    action_unclaim = "Передать жалобу",
    action_spectate = "Наблюдать",
    action_goto = "К нему",
    action_bring = "К себе",
    action_return = "Вернуть на место",
    action_returnself = "Вернуться на место",
    action_copySteamID = "Скопировать SteamID",
    action_callon = "Включить просьбу о помощи",
    action_calloff = "Выключить просьбу о помощи",
    action_close = "Закрыть жалобу",
    error_wait = "Тихо-тихо... Куда так разогнался?",
    error_noAccess = "Ошибка доступа",
    error_playerNotFound = "Игрок не найден",
    error_ticketNotEnded = "Жалоба не закрыта",
    error_ticketNotFound = "Жалоба не найдена",
    error_ticketEnded = "Жалоба уже решена",
    error_ticketNotClaimed = "Жалоба никем не взята",
    error_ticketAlreadyClaimed = "Жалоба уже взята",
    error_needToRate = "Ты должен оценить прошлую жалобу!",
    error_cantCancelHasAdmin = "Нельзя отменить жалобу, которую рассматривают",
    ticketClaimed = "Жалоба взята",
    ticketUnclaimed = "Жалоба отдана",
    ticketClaimedBy = "Твою жалобу принял %s",
    ticketUnclaimedBy = "Твоя жалоба передана",
    ticketClosed = "Жалоба закрыта",
    ticketClosedBy = "%s закрыл жалобу. Оцени его работу!",
    ticketRatedForAdmin = "Оценка по твоей жалобе: %s",
    ticketRatedForUser = "Ты оценил решение жалобы на %s",
    ticketUserLeft = "Пользователь, чью жалобу ты решал, вышел",
    rateAdmin = "Нажми ниже, чтобы выбрать оценку",
    ok = "Готово",
    cancel = "Отмена",
    ticket_noAdmins = "На сервере нет администраторов",
    dow = { "ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС" },
}

cats.config.serverID = "Cats"

cats.config.getPlayerName = function(ply)
    return ply:Nick() .. " (" .. ply:SteamName() .. ")"
end

cats.config.playerCanSeeTicket = function(ply, ticketSteamID)
    return ply:IsAdmin() or ply:SteamID() == ticketSteamID
end

cats.config.triggerText = function(ply, text)
    if cats.config.playerCanSeeTicket(ply, "") then return false end

    text = text:Trim()
    if text:sub(1, 1) == '@' then
        return true, text:sub(2):Trim()
    elseif text:sub(1, 3) == '///' then
        return true, text:sub(4):Trim()
    elseif text:sub(1, 4) == '/rep' then
		return true, text:sub(5):Trim()
	elseif text:sub(1, 4) == '!rep' then
		return true, text:sub(5):Trim()
    end
    return false
end

cats.config.notify = function(ply, msg, type, duration)
    if IsValid(ply) then
        DarkRP.notify(ply, type, duration, msg)
    else
        DarkRP.notifyAll(type, duration, msg)
    end
end

cats.config.commands = {
    {
        text = cats.lang.action_spectate,
        icon = 'camera_go',
        click = function(ply)
            RunConsoleCommand('FSpectate', ply:SteamID())
        end
    },
    {
        text = cats.lang.action_bring,
        icon = 'user_go',
        click = function(ply)
            RunConsoleCommand('sam', 'bring', ply:Name())
        end
    },
    {
        text = cats.lang.action_return,
        icon = 'arrow_undo',
        click = function(ply)
            RunConsoleCommand('sam', 'return', ply:Name())
        end
    },
    {
        text = cats.lang.action_goto,
        icon = 'arrow_right',
        click = function(ply)
            RunConsoleCommand('sam', 'goto', ply:Name())
        end
    },
    {
        text = cats.lang.action_returnself,
        icon = 'arrow_rotate_clockwise',
        click = function(ply)
            RunConsoleCommand('sam', 'return', LocalPlayer():Name())
        end
    },
    {
        text = cats.lang.action_copySteamID,
        icon = 'key_go',
        click = function(ply)
            SetClipboardText(ply:SteamID())
        end
    },
}

surface.CreateFont("cats.small", { font = "Roboto", extended = true, size = 16, weight = 500 })
surface.CreateFont("cats.xlarge", { font = "Roboto", extended = true, size = 52, weight = 800 })
surface.CreateFont("cats.large", { font = "Roboto", extended = true, size = 32, weight = 600 })
surface.CreateFont("cats.medium", { font = "Roboto", extended = true, size = 20, weight = 600 })

local c
local function n(t, e, a)
    local e = c[e]
    if not e then
        e = { tooltip = 'error', icon = Material('icon16/error.png'), click = function() end }
    end
    t:SetToolTip(e.tooltip)
    t.icon = e.icon
    t.DoClick = function(t)
        e.click(t, a)
    end
end

local a = {
    action_claim = Material('icon16/accept.png'),
    action_unclaim = Material('icon16/delete.png'),
    actions = Material('icon16/wand.png'),
    action_callon = Material('icon16/lightbulb_off.png'),
    action_calloff = Material('icon16/lightbulb.png'),
    action_close = Material('icon16/report_delete.png'),
    noStar = Material('icon16/bullet_white.png'),
    star = Material('icon16/star.png'),
}

c = {
    action_claim = {
        tooltip = cats.lang.action_claim,
        icon = a.action_claim,
        click = function(t, e)
            net.Start('cats.claimTicket')
            net.WriteString(e:SteamID())
            net.WriteBool(true)
            net.SendToServer()
            n(t, 'action_unclaim', e)
        end
    },
    action_unclaim = {
        tooltip = cats.lang.action_unclaim,
        icon = a.action_unclaim,
        click = function(t, e)
            net.Start('cats.claimTicket')
            net.WriteString(e:SteamID())
            net.WriteBool(false)
            net.SendToServer()
            n(t, 'action_claim', e)
        end
    },
    actions = {
        tooltip = cats.lang.actions,
        icon = a.actions,
        click = function(e, a)
            local e = DermaMenu()
            for n, t in ipairs(cats.config.commands) do
                e:AddOption(t.text, function() t.click(a) end):SetIcon('icon16/' .. (t.icon or 'wand') .. '.png')
            end
            e:SetPos(input.GetCursorPos())
            e:Open()
        end
    },
    action_callon = {
        tooltip = cats.lang.action_callon,
        icon = a.action_callon,
        click = function(t, e)
            n(t, 'action_calloff', e)
        end
    },
    action_calloff = {
        tooltip = cats.lang.action_calloff,
        icon = a.action_calloff,
        click = function(e, t)
            n(e, 'action_callon', t)
        end
    },
    action_close = {
        tooltip = cats.lang.action_close,
        icon = a.action_close,
        click = function(t, e)
            net.Start('cats.closeTicket')
            net.WriteString(e:SteamID())
            net.SendToServer()
        end
    },
}

local l = { 'action_claim', 'actions', 'action_close' }
local t

local function i(c)
    surface.PlaySound(cats.config.newTicketSound)
    local e = cats.ticketContainer:Add("DButton")
    if not IsValid(e) then return end
    e:SetSize(cats.config.spawnSize[1], 240)
    e:SetText('')
    e.expanded = false
    e.ticket = c

    e.Paint = function(n, w, h)
        local plyUser, plyAdmin = n.ticket.user, n.ticket.admin
        
        if not IsValid(plyUser) then 
            n:Remove() 
            return 
        end
        draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 35, 240))
        
        if n.Hovered then
            draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 10))
        end

        local timeStr = '(' .. os.date("%M:%S", CurTime() - n.ticket.created) .. ')'
        local userName = cats.config.getPlayerName(plyUser)
        local userRating = math.Round(plyUser:GetNWFloat("cats_averageRating", 0), 1)
        
        if IsValid(plyAdmin) then
            draw.SimpleText(timeStr .. ' ★' .. userRating .. ' ' .. userName, 'cats.small', 10, 12, Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            local adminRating = math.Round(plyAdmin:GetNWFloat("cats_adminRating", 0), 1)
            draw.SimpleText('Разбирает: ★' .. adminRating .. ' ' .. cats.config.getPlayerName(plyAdmin), 'cats.small', 10, 28, Color(255,154,177), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(timeStr .. ' ★' .. userRating .. ' ' .. userName, 'cats.small', 10, 20, Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    e.DoClick = function(t)
        t.expanded = not t.expanded
        for _, child in ipairs(cats.ticketContainer:GetChildren()) do
            child:InvalidateLayout(true)
        end
        cats.ticketContainer:Layout()
        timer.Simple(0, function() t.chatLog:GotoTextEnd() end)
    end

    e.PerformLayout = function(self)
        self:SetSize(self:GetParent():GetWide(), self.expanded and 240 or 40)
        self.controls:SetVisible(self.expanded)
    end

    local controls = vgui.Create("DPanel", e)
    controls:DockMargin(10, 0, 10, 10)
    controls:Dock(BOTTOM)
    controls:SetTall(190)
    controls.Paint = function() end
    e.controls = controls
    e.controls.buttons = {}
    for k, actionName in pairs(l) do
        local btn = vgui.Create("DButton", controls)
        btn:SetSize(32, 32)
        btn:SetPos(0, (k - 1) * 36)
        btn:SetText('')
        btn.Paint = function(self, w, h)
            if self.Hovered then
                draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 10))
            end
            surface.SetMaterial(self.icon)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawTexturedRect(8, 8, 16, 16)
        end
        n(btn, actionName, e.ticket.user)
        e.controls.buttons[actionName] = btn
    end
    local chatPanel = vgui.Create("DPanel", e.controls)
    chatPanel:Dock(FILL)
    chatPanel:DockMargin(42, 0, 0, 0)
    chatPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 20, 200))
    end
    e.chat = chatPanel
    local inputBtn = vgui.Create("DButton", e.chat)
    inputBtn:Dock(BOTTOM)
    inputBtn:DockMargin(10, 5, 10, 10)
    inputBtn:SetText('')
    inputBtn:SetTall(24)
    inputBtn:SetCursor('beam')
    inputBtn.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 255))
        if self.Hovered then
            draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 255))
            draw.RoundedBoxEx(4, 0, h - 2, w, 2, Color(52, 152, 219, 155), false, false, true, true)
        end
        draw.SimpleText(cats.lang.sendMessage, 'cats.small', 8, h / 2, Color(200, 200, 200, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    inputBtn.DoClick = function(self)
        Derma_StringRequest(cats.lang.sendMessage, cats.lang.typeYourMessage, '', function(text)
            net.Start("cats.dispatchMessage")
            net.WriteString(c.userID)
            net.WriteString(text)
            net.SendToServer()
        end, function() end, cats.lang.ok, cats.lang.cancel)
    end
    local log = vgui.Create("RichText", e.chat)
    log:Dock(FILL)
    log:DockMargin(10, 10, 10, 5)
    log.Paint = function(self)
        self.m_FontName = "cats.small"
        self:SetFontInternal("cats.small")
        self:SetBGColor(Color(0, 0, 0, 0))
        self.Paint = nil
    end
    e.chatLog = log
    cats.ticketContainer[c.userID] = e
    cats.ticketFrame:PerformLayout()
end

local function c(e, a, n, t)
    local e = cats.ticketContainer[e].chatLog
    if not IsValid(e) then return end
    if !t then
        e:InsertColorChange(50, 120, 180, 255)
    else
        e:InsertColorChange(255,154,177, 255)
    end
    e:AppendText("\n" .. a)
    e:InsertColorChange(220, 220, 220, 255)
    e:AppendText(":" .. n)
end

hook.Add("Think", "cats", function()
    if IsValid(cats.ticketFrame) then
        cats.ticketFrame:Remove()
    end

    local t_w, a_h = cats.config.spawnSize[1], cats.config.spawnSize[2]
    local n_x, o_y = cats.config.spawnPosAdmin[1], cats.config.spawnPosAdmin[2]
    
    local e = vgui.Create("DFrame")
    e:SetSize(t_w, a_h)
    e:SetPos(n_x, o_y)
    e:DockPadding(10, 50, 10, 10)
    e:SetTitle('')
    e:ShowCloseButton(false)
    cats.ticketFrame = e

    local scroll = vgui.Create("DScrollPanel", e)
    scroll:Dock(FILL)
    local origLayout = scroll.PerformLayout
    scroll.PerformLayout = function(self)
        origLayout(self)
        for _, child in ipairs(cats.ticketContainer:GetChildren()) do
            child:InvalidateLayout()
        end
    end
    local sbar = scroll:GetVBar()
    sbar:SetWide(6)
    sbar.Paint = function() end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    sbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(60, 60, 60, 200))
    end

    local container = vgui.Create("DIconLayout", scroll)
    container:Dock(FILL)
    container:SetSpaceX(0)
    container:SetSpaceY(5)
    cats.ticketContainer = container

    local frameLayout = e.PerformLayout
    e.PerformLayout = function(self)
        frameLayout(self)
        self:SetTall(math.min(container:GetTall() + 60, ScrH() - 100, 600))
        self:SetVisible(#container:GetChildren() > 0)
    end
    e.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(25, 25, 25, 250))
        draw.RoundedBoxEx(8, 0, 0, w, 40, Color(15, 15, 15, 255), true, true, false, false)
        draw.SimpleText(cats.lang.openTickets .. ' (' .. #container:GetChildren() .. ')', 'cats.medium', 15, 20, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    hook.Remove("Think", "cats")
end)

if IsValid(cats.myTicketFrame) then
    cats.myTicketFrame:Remove()
end

local function d(e)
    t = e
    local c, h = cats.config.spawnSize[1], 240
    local o, n = cats.config.spawnPosUser[1], cats.config.spawnPosUser[2]
    local e = vgui.Create("DFrame")
    e:ShowCloseButton(false)
    e:SetSize(c, h)
    e:SetPos(o, n)
    e:DockPadding(10, 50, 10, 10)
    e:SetTitle('')
    e.ticket = t
    e.Paint = function(self, w, h)
        local t = self.ticket.admin
        draw.RoundedBox(8, 0, 0, w, h, Color(25, 25, 25, 250))
        draw.RoundedBoxEx(8, 0, 0, w, 40, Color(15, 15, 15, 255), true, true, false, false)
        local timeStr = '(' .. os.date("%M:%S", CurTime() - self.ticket.created) .. ')'
        if IsValid(t) then
            draw.SimpleText(timeStr .. ' ' .. cats.lang.myTicket, 'cats.medium', 10, 12, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            local adminRating = math.Round(t:GetNWFloat("cats_adminRating", 0), 1)
            draw.SimpleText('Разбирает: ★' .. adminRating .. ' ' .. cats.config.getPlayerName(t), 'cats.small', 10, 30, Color(255,154,177), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(timeStr .. ' ' .. cats.lang.myTicket, 'cats.medium', 10, 20, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
    surface.SetFont('cats.small')
    local o_w, n_w = surface.GetTextSize(cats.lang.action_close)
    local n = vgui.Create("DButton", e)
    n:SetText('')
    n:SetSize(o_w + 16, 24)
    n:SetPos(c - (o_w + 16) - 8, 8)
    n.Paint = function(self, w, h)
        if self.Hovered then
            draw.RoundedBox(4, 0, 0, w, h, Color(231, 76, 60, 255))
        else
            draw.RoundedBox(4, 0, 0, w, h, Color(231, 76, 60, 100))
        end
        draw.SimpleText(cats.lang.action_close, 'cats.small', w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    n.DoClick = function(t)
        net.Start('cats.closeTicket')
        net.WriteString(LocalPlayer():SteamID())
        net.SendToServer()
    end
    e.closeBut = n
    local chatPanel = vgui.Create("DPanel", e)
    chatPanel:Dock(FILL)
    chatPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 20, 200))
    end
    e.chat = chatPanel
    local o = vgui.Create("DButton", e.chat)
    o:Dock(BOTTOM)
    o:DockMargin(10, 5, 10, 10)
    o:SetText('')
    o:SetTall(24)
    o:SetCursor('beam')
    o.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 255))
        if self.Hovered then
            draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 255))
            draw.RoundedBoxEx(4, 0, h - 2, w, 2, Color(52, 152, 219, 155), false, false, true, true)
        end
        draw.SimpleText(cats.lang.sendMessage, 'cats.small', 8, h / 2, Color(200, 200, 200, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    o.DoClick = function(e)
        Derma_StringRequest(cats.lang.sendMessage, cats.lang.typeYourMessage, '', function(e)
            net.Start("cats.dispatchMessage")
            net.WriteString(LocalPlayer():SteamID())
            net.WriteString(e)
            net.SendToServer()
        end, function() end, cats.lang.ok, cats.lang.cancel)
    end
    local log = vgui.Create("RichText", e.chat)
    log:Dock(FILL)
    log:DockMargin(10, 10, 10, 5)
    log.Paint = function(self)
        self.m_FontName = "cats.small"
        self:SetFontInternal("cats.small")
        self:SetBGColor(Color(0, 0, 0, 0))
        self.Paint = nil
    end
    e.chatLog = log
    e.SwitchToRating = function(self)
        chatPanel:Clear()
        chatPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 20, 200))
            draw.SimpleText(cats.lang.rateAdmin, "cats.medium", w / 2, 30, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        local okBtn = vgui.Create('DButton', chatPanel)
        okBtn:SetTall(30)
        okBtn:Dock(BOTTOM)
        okBtn:DockMargin(10, 10, 10, 10)
        okBtn:SetText('')
        okBtn:SetEnabled(false)
        okBtn.Paint = function(self, w, h)
            if self:IsEnabled() then
                draw.RoundedBox(4, 0, 0, w, h, self.Hovered and Color(46, 204, 113, 255) or Color(39, 174, 96, 255))
                draw.SimpleText(cats.lang.ok, "cats.small", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 255))
                draw.SimpleText(cats.lang.ok, "cats.small", w / 2, h / 2, Color(100, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        okBtn.DoClick = function()
            net.Start('cats.setRating')
            net.WriteUInt(math.Clamp(t.rating or cats.config.defaultRating, 1, 5), 8)
            net.SendToServer()
            cats.myTicketFrame:Remove()
            t = nil
        end

        for i = 1, 5 do
            local offset = i - 3
            local starBtn = vgui.Create('DButton', chatPanel)
            starBtn:SetText('')
            starBtn:SetSize(64, 64)
            starBtn:SetPos((c - 20) / 2 + offset * 64 - 32, 70)
            starBtn.Paint = function(self, w, h)
                if self.Hovered then
                    draw.RoundedBox(8, 8, 8, 48, 48, Color(255, 255, 255, 10))
                end
                
                if not t.rating then
                    surface.SetDrawColor(255, 255, 255, 50)
                    surface.SetMaterial(a.star)
                    surface.DrawTexturedRect(16, 16, 32, 32)
                elseif t.rating and i <= t.rating then
                    surface.SetDrawColor(241, 196, 15)
                    surface.SetMaterial(a.star)
                    surface.DrawTexturedRect(16, 16, 32, 32)
                else
                    surface.SetDrawColor(255, 255, 255, 20)
                    surface.SetMaterial(a.noStar)
                    surface.DrawTexturedRect(24, 24, 16, 16)
                end
            end
            starBtn.DoClick = function()
                okBtn:SetEnabled(true)
                t.rating = i
            end
        end
    end
    cats.myTicketFrame = e
end

local function l(a, t, n)
    local e = cats.myTicketFrame.chatLog
    if not IsValid(e) then return end
    if !n then
        e:InsertColorChange(50, 120, 180, 255)
    else
        e:InsertColorChange(255, 154, 177, 255)
    end
    e:AppendText("\n" .. a)
    e:InsertColorChange(220, 220, 220, 255)
    e:AppendText(":" .. t)
end

net.Receive('cats.dispatchMessage', function(e)
    local e = net.ReadString()
    local a = net.ReadEntity()
    local o = net.ReadString()
    local n = cats.config.getPlayerName(a)
    if not IsValid(a) then return end

    if e == LocalPlayer():SteamID() then
        if t then
            l(n, o, a:SteamID() ~= LocalPlayer():SteamID())
        else
            d({ created = CurTime() })
            l(n, o, a:SteamID() ~= LocalPlayer():SteamID())
        end
    elseif IsValid(cats.ticketContainer[e]) then
        c(e, n, o, a:SteamID() ~= e)
    else
        local t = player.GetBySteamID(e)
        if not IsValid(t) then return end
        i({ user = t, userID = e, created = CurTime() })
        c(e, n, o, a:SteamID() ~= e)
    end
end)

net.Receive('cats.claimTicket', function(e)
    local o = net.ReadString()
    local a = net.ReadEntity()
    local e = net.ReadBool()
    if not IsValid(a) then return end

    if o == LocalPlayer():SteamID() and t then
        t.admin = e and a or nil
        t.adminID = e and a:SteamID() or nil
        cats.myTicketFrame.closeBut:SetVisible(not e)
    elseif IsValid(cats.ticketContainer[o]) then
        local t = cats.ticketContainer[o].ticket
        t.admin = e and a or nil
        t.adminID = e and a:SteamID() or nil
        if t.adminID ~= LocalPlayer():SteamID() then
            local a = cats.ticketContainer[o].controls.buttons['action_claim']
            if e then
                n(a, 'action_unclaim', t.user)
                a:SetEnabled(false)
            else
                n(a, 'action_claim', t.user)
                a:SetEnabled(true)
            end
        end
    end
end)

net.Receive('cats.closeTicket', function(e)
    local e = net.ReadString()
    if e == LocalPlayer():SteamID() and t then
        if IsValid(t.admin) then
            cats.myTicketFrame:SwitchToRating()
        else
            cats.myTicketFrame:Remove()
            t = nil
        end
    elseif IsValid(cats.ticketContainer[e]) then
        cats.ticketContainer[e].ticket = nil
        cats.ticketContainer[e]:Remove()
        cats.ticketFrame:PerformLayout()
    end
end)

net.Receive('cats.setRating', function(e)
    local e = net.ReadString()
    local t = net.ReadUInt(8)
    if e == LocalPlayer():SteamID() then
        cats.myTicketFrame:Remove()
    end
end)

net.Receive('cats.syncTickets', function(e)
    local e = net.ReadTable()
    for t, e in pairs(e) do
        local a = player.GetBySteamID(t)
        if IsValid(a) then
            i({ user = a, userID = t, created = e.createdGameTime, admin = e.admin, adminID = e.adminID })
            if IsValid(e.admin) then
                local t = cats.ticketContainer[t].controls.buttons['action_claim']
                n(t, 'action_unclaim', e.user)
                t:SetEnabled(false)
            end
            for a, e in pairs(e.chatLog) do
                c(t, e[1], e[2], e[3])
            end
        end
    end
end)

local function OpenAnalytics()
    
    if IsValid(cats.analyticsFrame) then
        cats.analyticsFrame:Remove()
    end

    local e = vgui.Create('DFrame')
    e:SetSize(800, 400)
    e:SetTitle('')
    e:Center()
    e:MakePopup()
    e:ShowCloseButton(false)
    e.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(25, 25, 25, 250))
        draw.RoundedBoxEx(8, 0, 0, w, 40, Color(15, 15, 15, 255), true, true, false, false)
        draw.SimpleText("Аналитика Администрации", "cats.medium", 15, 20, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    cats.analyticsFrame = e

    local closeBtn = vgui.Create("DButton", e)
    closeBtn:SetSize(40, 40)
    closeBtn:SetPos(e:GetWide() - 40, 0)
    closeBtn:SetText("✕")
    closeBtn:SetFont("cats.medium")
    closeBtn:SetTextColor(Color(200, 200, 200))
    closeBtn.Paint = function(self, w, h)
        if self.Hovered then
            draw.RoundedBoxEx(8, 0, 0, w, h, Color(231, 76, 60, 255), false, true, false, false)
        end
    end
    closeBtn.DoClick = function() e:Close() end

   if LocalPlayer():IsSuperAdmin() or LocalPlayer():GetUserGroup() == "curator" then
        local clearBtn = vgui.Create("DButton", e)
        clearBtn:SetSize(120, 24)
         clearBtn:SetPos(280, 8) 
        clearBtn:SetText("Обнулить всех")
        clearBtn:SetFont("cats.small")
        clearBtn:SetTextColor(Color(255, 100, 100))
        clearBtn.Paint = function(self, w, h)
            if self.Hovered then draw.RoundedBox(4, 0, 0, w, h, Color(255, 0, 0, 30)) end
        end
        clearBtn.DoClick = function()
            Derma_Query("Вы уверены, что хотите ОБНУЛИТЬ СТАТИСТИКУ ВСЕМ админам?\nСами админы останутся в списке, но их жалобы и рейтинг станут 0.", "Осторожно!",
                "Да, обнулить", function() net.Start("cats.clearAllAdmins") net.SendToServer() e.pnl:Clear() end,
                "Отмена", function() end)
        end
    end

    local t = vgui.Create('DListView', e)
    t:Dock(LEFT)
    t:DockMargin(10, 10, 10, 10)
    t:SetWide(220)
    t:SetMultiSelect(false)
    t:AddColumn('Рейтинг'):SetFixedWidth(65)
    t:AddColumn('Админ')
    t.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 20, 200))
    end
    t.OnRowSelected = function(t, t, a)
        e.pnl:Clear()
        local t = vgui.Create('DLabel', e.pnl)
        t:SetText('Загрузка...')
        t:SetFont("cats.medium")
        t:SizeToContents()
        t:Center()
        net.Start('cats.getAdminData')
        net.WriteString(a.steamID)
        net.SendToServer()
    end
    t.OnRowRightClick = function(list, lineID, line)
        if not LocalPlayer():IsSuperAdmin() and LocalPlayer():GetUserGroup() ~= "curator" then return end
        local steamID = line.steamID
        local menu = DermaMenu()

        menu:AddOption("Изменить кол-во жалоб", function()
            Derma_StringRequest(
                "Изменение статистики",
                "Введите новое количество разобраных жалоб для " .. line:GetColumnText(2),
                "",
                function(text)
                    local val = tonumber(text)
                    if not val or val < 0 then
                        Derma_Message("Введите корректное число", "Ошибка", "OK")
                        return
                    end
                    net.Start("cats.setClaimsTotal")
                    net.WriteString(steamID)
                    net.WriteUInt(val, 32)
                    net.SendToServer()
                end,
                function() end,
                "Сохранить",
                "Отмена"
            )
        end):SetIcon("icon16/pencil.png")

        menu:AddSpacer()

        menu:AddOption("Обнулить статистику", function()
            Derma_Query("Обнулить статистику для " .. line:GetColumnText(2) .. "?\nВсе его жалобы будут удалены.", "Подтверждение",
                "Обнулить", function() net.Start("cats.resetAdmin") net.WriteString(steamID) net.SendToServer() e.pnl:Clear() end,
                "Отмена", function() end)
        end):SetIcon("icon16/arrow_refresh.png")

        menu:AddSpacer()

        menu:AddOption("Удалить админа", function()
            Derma_Query("Удалить " .. line:GetColumnText(2) .. " из базы?", "Подтверждение",
                "Удалить", function() net.Start("cats.deleteAdmin") net.WriteString(steamID) net.SendToServer() e.pnl:Clear() end,
                "Отмена", function() end)
        end):SetIcon("icon16/user_delete.png")

        menu:Open()
    end
    e.list = t


    local pnl = vgui.Create('DPanel', e)
    pnl:DockMargin(0, 10, 10, 10)
    pnl:Dock(FILL)
    pnl.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 20, 200))
    end
    e.pnl = pnl

    net.Start('cats.getAdminList')
    net.SendToServer()
end

concommand.Add('cats_analytics', OpenAnalytics)

net.Receive('cats.getAdminList', function()
    local e = net.ReadTable()
    if not IsValid(cats.analyticsFrame) then return end
    cats.analyticsFrame.list:Clear()
    for a, e in pairs(e) do
        local t = '★ ' .. math.Round(e.ratingTotal, 1)
        local e = cats.analyticsFrame.list:AddLine(t, e.lastNick)
        e.steamID = a
    end
    cats.analyticsFrame.list:SortByColumn(1, true)
end)

net.Receive('cats.getAdminData', function()
    local e = net.ReadTable()
    if not IsValid(cats.analyticsFrame) or not IsValid(cats.analyticsFrame.pnl) then return end
    cats.analyticsFrame:SetTall(480) 
    cats.analyticsFrame:Center()

    local a = cats.analyticsFrame.pnl
    a:Clear()

    local timeCard = e.timeCard and util.JSONToTable(e.timeCard) or {}
    local claimCard = e.claimCard and util.JSONToTable(e.claimCard) or {}

    for d = 1, 7 do
        timeCard[d] = timeCard[d] or {}
        claimCard[d] = claimCard[d] or {}
        for h = 1, 24 do
            timeCard[d][h] = timeCard[d][h] or 0
            claimCard[d][h] = claimCard[d][h] or 0
        end
    end
    local header = vgui.Create('DPanel', a)
    header:Dock(TOP)
    header:SetTall(80)
    header.Paint = function(self, w, h)
        draw.RoundedBox(4, 15, 15, w - 30, h - 15, Color(35, 35, 35, 255))
        draw.SimpleText(e.lastNick or "Неизвестно", 'cats.large', 35, h / 2 + 7, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(e.steamID or "", 'cats.small', w - 35, h / 2 + 7, Color(150, 150, 150), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    local statsContainer = vgui.Create('DPanel', a)
    statsContainer:Dock(TOP)
    statsContainer:SetTall(110)
    statsContainer:DockMargin(15, 15, 15, 0)
    statsContainer.Paint = function() end

    local w_stat = (a:GetWide() - 75) / 4

    local function addStat(title, value, color, onClick)
        local p = vgui.Create(onClick and 'DButton' or 'DPanel', statsContainer)
        p:Dock(LEFT)
        p:DockMargin(0, 0, 15, 0)
        p:SetWide(w_stat)
        if onClick then
            p:SetText("")
            p.DoClick = onClick
        end
        p.Paint = function(self, pw, ph)
            draw.RoundedBox(6, 0, 0, pw, ph, (onClick and self.Hovered) and Color(40, 40, 40, 255) or Color(30, 30, 30, 255))
            draw.RoundedBoxEx(6, 0, 0, pw, 5, color, true, true, false, false)
            draw.SimpleText(title, "cats.small", pw / 2, 35, Color(180, 180, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(value, "cats.large", pw / 2, 70, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            if onClick then
                draw.SimpleText("(изменить)", "cats.small", pw / 2, ph - 15, Color(120, 120, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end

    local onClickClaims = nil
    if LocalPlayer():IsSuperAdmin() or LocalPlayer():GetUserGroup() == "curator" then
        onClickClaims = function()
            Derma_StringRequest(
                "Изменение статистики",
                "Введите новое количество разобраных жалоб для " .. (e.lastNick or "админа"),
                tostring(e.claimsTotal or 0),
                function(text)
                    local val = tonumber(text)
                    if not val or val < 0 then
                        Derma_Message("Введите корректное число", "Ошибка", "OK")
                        return
                    end
                    net.Start("cats.setClaimsTotal")
                    net.WriteString(e.steamID)
                    net.WriteUInt(val, 32)
                    net.SendToServer()
                    
                    timer.Simple(0.5, function()
                        if IsValid(cats.analyticsFrame) and IsValid(cats.analyticsFrame.pnl) then
                            net.Start('cats.getAdminData')
                            net.WriteString(e.steamID)
                            net.SendToServer()
                        end
                    end)
                end,
                function() end,
                "Сохранить",
                "Отмена"
            )
        end
    end

    addStat("ПРИНЯТО ЖАЛОБ", e.claimsTotal or 0, Color(52, 152, 219), onClickClaims)
    addStat("СРЕДНЯЯ ОЦЕНКА", "★ " .. math.Round(e.ratingTotal or 0, 1), Color(241, 196, 15))
    addStat("ПОЛОЖИТЕЛЬНЫЕ (>3)", e.positiveClaims or 0, Color(46, 204, 113))
    addStat("ОТРИЦАТЕЛЬНЫЕ (<=3)", e.negativeClaims or 0, Color(231, 76, 60))
    local periodContainer = vgui.Create("DPanel", a)
    periodContainer:Dock(FILL)
    periodContainer:DockMargin(15, 15, 15, 15)
    periodContainer.Paint = function() end

    local topBar = vgui.Create("DPanel", periodContainer)
    topBar:Dock(TOP)
    topBar:SetTall(30)
    topBar.Paint = function() end

    local combo = vgui.Create("DComboBox", topBar)
    combo:SetFont("cats.small")
    combo:SetTextColor(Color(220, 220, 220))
    if IsValid(combo.DropButton) then
        combo.DropButton.Paint = function() end
    end

    combo.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 255))
        if self:IsHovered() then
            draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 255))
        end
        draw.SimpleText("▼", "cats.small", w - 15, h / 2, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    topBar.PerformLayout = function(self, w, h)
        combo:SetSize(250, 30)
        combo:SetPos((w - 250) / 2, 0)
    end

    combo:SetValue("За неделю")
    combo:AddChoice("За всё время", -1)
    combo:AddChoice("За неделю", 0)

    local fullDays = {"Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"}
    for i, dName in ipairs(fullDays) do
        combo:AddChoice(dName, i)
    end

    local displayPanel = vgui.Create("DPanel", periodContainer)
    displayPanel:Dock(FILL)
    displayPanel:DockMargin(0, 15, 0, 0)
    displayPanel.Paint = function(self, pw, ph)
        draw.RoundedBox(6, 0, 0, pw, ph, Color(25, 25, 25, 255))
    end

    local function UpdatePeriodStats(dayIndex)
        displayPanel:Clear()
        
        local totalTickets = 0
        local hours = 0

        if dayIndex == -1 then
            totalTickets = e.claimsTotal or 0
            hours = math.Round((tonumber(e.playTimeTotal) or 0) / 3600, 1)
        elseif dayIndex == 0 then 
            for d = 1, 7 do
                for h = 1, 24 do
                    totalTickets = totalTickets + claimCard[d][h]
                    hours = hours + (timeCard[d][h] / 6)
                end
            end
            hours = math.Round(hours, 1)
        else 
            for h = 1, 24 do
                totalTickets = totalTickets + claimCard[dayIndex][h]
                hours = hours + (timeCard[dayIndex][h] / 6)
            end
            hours = math.Round(hours, 1)
        end

        local halfW = (a:GetWide() - 30) / 2
        
        local p1 = vgui.Create("DPanel", displayPanel)
        p1:Dock(LEFT)
        p1:SetWide(halfW)
        p1.Paint = function(self, pw, ph)
            draw.SimpleText("РАЗОБРАНО ЖАЛОБ", "cats.medium", pw/2, ph/2 - 15, Color(180,180,180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(totalTickets, "cats.xlarge", pw/2, ph/2 + 20, Color(46, 204, 113), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local p2 = vgui.Create("DPanel", displayPanel)
        p2:Dock(FILL)
        p2.Paint = function(self, pw, ph)
            draw.SimpleText("ОТЫГРАНО ЧАСОВ", "cats.medium", pw/2, ph/2 - 15, Color(180,180,180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(hours .. " ч.", "cats.xlarge", pw/2, ph/2 + 20, Color(155, 89, 182), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    combo.OnSelect = function(self, index, text, data)
        UpdatePeriodStats(data)
    end

    UpdatePeriodStats(0)
end)