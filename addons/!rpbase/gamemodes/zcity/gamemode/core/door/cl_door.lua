DoorSys = DoorSys or {}

local s = shizlib.surface.s or function(v) return v end
local RNDX = include("shizlib/client/rndx_cl.lua")
local theme = CFG and CFG.theme or {
    bg = Color(22, 22, 22),
    bg_alt = Color(40, 40, 40),
    red = Color(222,91,73, 255),
    accent = Color(255,77,119),
    focus = Color(245, 245, 245, 25),
    black = Color(12, 12, 12),
    black2 = Color(24, 24, 24),
    black3 = Color(30, 30, 30),
    black4 = Color(17, 17, 17, 200),
    white = Color(230, 230, 230),
    hvr = Color(22, 22, 22, 100),
}

-- [ UTILS & EFFECTS ]
local function DrawShadow(x, y, w, h, passes, opac)
    for i = 1, passes do
        draw.RoundedBox(16, x - i, y - i, w + (i * 2), h + (i * 2), Color(0, 0, 0, opac / i))
    end
end

local function PlayHover() surface.PlaySound("ui/buttonrollover.wav") end
local function PlayClick() 
    if shizlib and shizlib.surface and shizlib.surface.clickSound then shizlib.surface.clickSound() else surface.PlaySound("ui/buttonclick.wav") end 
end

local function sendAction(ent, action, target)
    net.Start("DoorSys.Action")
        net.WriteEntity(ent)
        net.WriteString(action)
        net.WriteString(target or "")
    net.SendToServer()
end

net.Receive("DoorSys.OpenMenu", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    if not ent.IsManagedDoor or not ent:IsManagedDoor() then return end
    
    local client = LocalPlayer()
    if ent:GetPos():Distance(client:GetPos()) > CFG.useDist then return end
    
    local owner = ent:GetDoorOwnerSID64()
    local sid64 = LocalPlayer():SteamID64()
    local coowners = ent:GetDoorCoOwners() or {}
    local isCoOwner = table.HasValue(coowners, sid64)
    
    -- Блокируем открытие только в том случае, если у двери ЕСТЬ владелец, и это НЕ мы
    if owner ~= "" and owner ~= sid64 and not isCoOwner then return end

    -- Динамическая высота панели в зависимости от статуса владения
    local targetHeight = (owner == sid64) and s(450) or s(220)

    local pnl = vgui.Create("EditablePanel")
    pnl:SetSize(s(500), targetHeight)
    pnl:Center()
    pnl:MakePopup()
    
    -- Плавное появление (Slide Up + Fade In)
    pnl:SetAlpha(0)
    pnl:AlphaTo(255, 0.25)
    local startY = pnl:GetY()
    pnl:SetPos(pnl:GetX(), startY + s(20))
    pnl:MoveTo(pnl:GetX(), startY, 0.4, 0, -1)

    pnl.Paint = function(self, w, h)
        if not IsValid(self) then return end
        
        -- Используем RNDX вместо старого DrawBlur
        RNDX.Draw(16, 0, 0, w, h, nil, RNDX.BLUR)
        DrawShadow(0, 0, w, h, 6, 80)
        
        -- Основа
        draw.RoundedBox(16, 0, 0, w, h, theme.black2)
        -- Шапка
        draw.RoundedBoxEx(16, 0, 0, w, s(70), theme.black, true, true, false, false)
        
        -- Текст заголовка
        draw.SimpleText("УПРАВЛЕНИЕ ДВЕРЬЮ", "IB_25", s(30), s(25), theme.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(ent:GetDoorDisplayName() or "Неизвестная дверь", "IB_14", s(30), s(45), theme.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    -- Кнопка закрытия
    local clsBtn = vgui.Create("DButton", pnl)
    clsBtn:SetSize(s(40), s(40))
    clsBtn:SetPos(pnl:GetWide() - s(50), s(15))
    clsBtn:SetText("✕")
    clsBtn:SetFont("IB_25")
    clsBtn:SetTextColor(Color(140, 140, 140))
    clsBtn.OnCursorEntered = PlayHover
    clsBtn.Paint = function() end
    local function CloseMenu()
        if IsValid(pnl) then
            PlayClick()
            pnl:AlphaTo(0, 0.2, 0, function() if IsValid(pnl) then pnl:Remove() end end)
        end
    end
    clsBtn.DoClick = CloseMenu
    
    pnl.Think = function(self)
        if input.IsKeyDown(KEY_ESCAPE) or gui.IsGameUIVisible() then
            if not self.closing then
                self.closing = true
                CloseMenu()
            end
        end
    end

    -- Контейнер контента
    local content = vgui.Create("Panel", pnl)
    content:Dock(FILL)
    content:DockMargin(s(30), s(90), s(30), s(30))

    -- [ 1. МЕНЮ ПОКУПКИ (Ничья дверь) ]
    if owner == "" then
        local price = ent:GetDoorPrice()
        
        local buyBtn = vgui.Create("DButton", content)
        buyBtn:Dock(TOP)
        buyBtn:SetTall(s(55))
        buyBtn:SetText("")
        buyBtn.hoverLerp = 0
        buyBtn.OnCursorEntered = PlayHover
        buyBtn.Paint = function(self, w, h)
            if not IsValid(self) then return end
            self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
            
            draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(theme.accent, 220 + (35 * self.hoverLerp)))
            
            -- Внутренний градиент
            surface.SetDrawColor(255, 255, 255, 15)
            surface.SetMaterial(Material("gui/gradient_down"))
            surface.DrawTexturedRect(0, 0, w, h)
            
            draw.SimpleText("ПРИОБРЕСТИ ЗА " .. string.Comma(price) .. " ₽", "IB_20", w/2, h/2, theme.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        buyBtn.DoClick = function()
            PlayClick()
            sendAction(ent, "buy", "")
            CloseMenu()
        end
        
        local infoLabel = vgui.Create("DLabel", content)
        infoLabel:Dock(TOP)
        infoLabel:DockMargin(0, s(15), 0, 0)
        infoLabel:SetText("После покупки вы станете владельцем и сможете приглашать друзей.")
        infoLabel:SetFont("IB_14")
        infoLabel:SetTextColor(Color(150, 150, 150))
        infoLabel:SetContentAlignment(5)
    end

    -- [ 2. МЕНЮ ВЛАДЕЛЬЦА (Продажа и совладельцы) ]
    if owner == sid64 then
        local sellBtn = vgui.Create("DButton", content)
        sellBtn:Dock(TOP)
        sellBtn:SetTall(s(45))
        sellBtn:SetText("")
        sellBtn.hoverLerp = 0
        sellBtn.OnCursorEntered = PlayHover
        sellBtn.Paint = function(self, w, h)
            if not IsValid(self) then return end
            self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
            
            draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(theme.red, 160 + (60 * self.hoverLerp)))
            draw.SimpleText("ПРОДАТЬ НЕДВИЖИМОСТЬ", "IB_20", w/2, h/2, theme.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        sellBtn.DoClick = function()
            PlayClick()
            sendAction(ent, "sell", "")
            CloseMenu()
        end

        local coLabel = vgui.Create("DLabel", content)
        coLabel:Dock(TOP)
        coLabel:DockMargin(0, s(25), 0, s(10))
        coLabel:SetFont("IB_20")
        coLabel:SetText("СОВЛАДЕЛЬЦЫ")
        coLabel:SetTextColor(theme.white)

        -- Панель добавления
        local addPnl = vgui.Create("Panel", content)
        addPnl:Dock(TOP)
        addPnl:SetTall(s(40))

        local combo = vgui.Create("DComboBox", addPnl)
        combo:Dock(FILL)
        combo:DockMargin(0, 0, s(10), 0)
        combo:SetValue("Выберите игрока поблизости...")
        combo:SetFont("IB_14")
        combo:SetTextColor(theme.white)
        combo.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, theme.black3)
            if self:IsHovered() then
                draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 5))
            end
        end

        -- Кастомный скролл для комбобокса
        combo.DoClick = function(self)
            if self:IsMenuOpen() then return self:CloseMenu() end
            self:OpenMenu()
            if IsValid(self.Menu) then
                self.Menu.Paint = function(pnl, w, h) draw.RoundedBox(0, 0, 0, w, h, theme.black3) end
            end
        end

        for _, p in ipairs(player.GetAll()) do
            local pSid = p:SteamID64()
            if pSid ~= sid64 and not table.HasValue(coowners, pSid) then
                combo:AddChoice(p:Nick(), pSid)
            end
        end

        local addBtn = vgui.Create("DButton", addPnl)
        addBtn:Dock(RIGHT)
        addBtn:SetWide(s(120))
        addBtn:SetText("")
        addBtn.hoverLerp = 0
        addBtn.OnCursorEntered = PlayHover
        addBtn.Paint = function(self, w, h)
            if not IsValid(self) then return end
            self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
            
            draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(theme.accent, 40 + (40 * self.hoverLerp)))
            draw.SimpleText("ДОБАВИТЬ", "IB_14", w/2, h/2, theme.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        addBtn.DoClick = function()
            local selID = combo:GetSelectedID()
            if not selID then return end
            local targetSid = combo:GetOptionData(selID)
            if not targetSid then return end
            
            PlayClick()
            sendAction(ent, "add_coowner", targetSid)
            CloseMenu()
        end

        -- Список текущих совладельцев
        local listScroll = vgui.Create("DScrollPanel", content)
        listScroll:Dock(FILL)
        listScroll:DockMargin(0, s(15), 0, 0)
        
        local sbar = listScroll:GetVBar()
        sbar:SetWide(s(4))
        sbar:SetHideButtons(true)
        sbar.Paint = function() end
        sbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(2, 0, 0, w, h, Color(255, 255, 255, 20)) end

        if #coowners == 0 then
            local empty = listScroll:Add("DLabel")
            empty:Dock(TOP)
            empty:SetText("У вас пока нет совладельцев.")
            empty:SetFont("IB_14")
            empty:SetTextColor(Color(120, 120, 120))
            empty:SetContentAlignment(5)
        else
            for _, coSid in ipairs(coowners) do
                local row = listScroll:Add("DPanel")
                row:Dock(TOP)
                row:DockMargin(0, 0, s(10), s(8))
                row:SetTall(s(36))
                row.Paint = function(self, w, h)
                    draw.RoundedBox(6, 0, 0, w, h, theme.black3)
                end

                local p = player.GetBySteamID64(coSid)
                local name = IsValid(p) and p:Nick() or "Неизвестный игрок"

                local nameLabel = row:Add("DLabel")
                nameLabel:Dock(FILL)
                nameLabel:DockMargin(s(15), 0, 0, 0)
                nameLabel:SetText(name)
                nameLabel:SetFont("IB_14")
                nameLabel:SetTextColor(theme.white)

                local removeBtn = row:Add("DButton")
                removeBtn:Dock(RIGHT)
                removeBtn:DockMargin(s(5), s(5), s(5), s(5))
                removeBtn:SetWide(s(80))
                removeBtn:SetText("")
                removeBtn.hoverLerp = 0
                removeBtn.OnCursorEntered = PlayHover
                removeBtn.Paint = function(self, w, h)
                    if not IsValid(self) then return end
                    self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
                    draw.RoundedBox(4, 0, 0, w, h, ColorAlpha(theme.red, 30 + (50 * self.hoverLerp)))
                    draw.SimpleText("УБРАТЬ", "IB_14", w/2, h/2, Color(255, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                removeBtn.DoClick = function()
                    PlayClick()
                    sendAction(ent, "remove_coowner", coSid)
                    CloseMenu()
                end
            end
        end
    end
end)