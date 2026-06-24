include("shared.lua")

if CLIENT then
    local COLORS = {
        BG        = Color(15, 15, 20),
        HEADER    = Color(20, 40, 80),
        ACCENT    = Color(0, 100, 200),
        RED       = Color(200, 50, 50),
        GREEN     = Color(50, 180, 50),
        BLUE      = Color(50, 100, 200),
        ORANGE    = Color(200, 150, 50),
        YELLOW    = Color(255, 255, 0),
        TEXT      = Color(255, 255, 255),
        TEXT_DIM  = Color(200, 200, 200),
        BORDER    = Color(40, 40, 50),
        PANEL     = Color(25, 25, 30),
        ROW_BG    = Color(30, 30, 40),
        ROW_HOVER = Color(50, 50, 60)
    }

    SWEP.MouseHasControl = false
    SWEP.LastPrimaryClick = 0
    SWEP.PrimaryClickCooldown = 0.2
    
    SWEP.CitizenLookupData = {
        uniqid = "—", name = "—", license = "—", 
        beslicense = "—", wanted = "—", wantedreas = "—", 
        status = "Введите ID паспорта"
    }
    SWEP.WantedListData = {}
    SWEP.CurrentLookupID = nil

    surface.CreateFont('pda_font_16',{font = "Roboto",size = 16 + 5,extended = true,scanlines = 2,  weight = 600,shadow = true, antialias = true})
    surface.CreateFont('pda_font_15',{font = "Roboto",size = 15 + 5,extended = true,scanlines = 2,  weight = 600,shadow = true, antialias = true})
    surface.CreateFont('pda_font_14',{font = "Roboto",size = 14 + 5,extended = true,scanlines = 2,  weight = 600,shadow = true, antialias = true})
    surface.CreateFont('pda_font_13',{font = "Roboto",size = 13 + 5,extended = true,scanlines = 2,  weight = 600,shadow = true, antialias = true})
    surface.CreateFont('pda_font_12',{font = "Roboto",size = 12 + 5,extended = true,scanlines = 2,  weight = 600,shadow = true, antialias = true})
    surface.CreateFont('pda_font_11',{font = "Roboto",size = 11 + 5,extended = true,scanlines = 2,  weight = 600,shadow = true, antialias = true})
    surface.CreateFont('pda_font_10',{font = "Roboto",size = 10 + 5,extended = true,scanlines = 2,  weight = 600,shadow = true, antialias = true})
    surface.CreateFont('pda_font_9',{ font = "Roboto",size = 9  + 5,extended = true,scanlines = 2,  weight = 600,shadow = true, antialias = true})

    net.Receive("PolicePDA_SendCitizenInfo", function()
        local found = net.ReadBool()
        local uniqId = net.ReadUInt(32)
        local name = net.ReadString()
        local license = net.ReadString()
        local beslicense = net.ReadString()
        local wanted = net.ReadString()
        local wantedreas = net.ReadString()

        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local wep = ply:GetWeapon("rp_police_pda")
        if not IsValid(wep) then
            wep = ply:GetActiveWeapon()
            if not IsValid(wep) or wep:GetClass() ~= "rp_police_pda" then return end
        end

        wep.CitizenLookupData = wep.CitizenLookupData or {}

        if found then
            wep.CitizenLookupData.uniqid = tostring(uniqId)
            wep.CitizenLookupData.name = name ~= "" and name or "—"
            wep.CitizenLookupData.license = license ~= "" and license or "—"
            wep.CitizenLookupData.beslicense = beslicense ~= "" and beslicense or "—"
            wep.CitizenLookupData.wanted = wanted ~= "" and wanted or "—"
            wep.CitizenLookupData.wantedreas = wantedreas ~= "" and wantedreas or "—"
            wep.CitizenLookupData.status = "Запрос выполнен"
            wep.CurrentLookupID = uniqId
        else
            wep.CitizenLookupData.uniqid = tostring(uniqId)
            wep.CitizenLookupData.name = "Игрок не найден"
            wep.CitizenLookupData.license = "—"
            wep.CitizenLookupData.beslicense = "—"
            wep.CitizenLookupData.wanted = "—"
            wep.CitizenLookupData.wantedreas = "—"
            wep.CitizenLookupData.status = "Совпадений нет"
            wep.CurrentLookupID = nil
        end
    end)

    net.Receive("PolicePDA_SendWantedList", function()
        local count = net.ReadUInt(8)
        local data = {}

        for i = 1, count do
            data[i] = {
                uniqid = net.ReadUInt(32),
                name = net.ReadString(),
                reason = net.ReadString()
            }
        end

        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local wep = ply:GetWeapon("rp_police_pda")
        if not IsValid(wep) then
            wep = ply:GetActiveWeapon()
            if not IsValid(wep) or wep:GetClass() ~= "rp_police_pda" then return end
        end

        wep.WantedListData = data

        if IsValid(wep.WantedScrollPanel) then
            wep:PopulateWantedList()
        end
    end)

    hook.Add("PlayerButtonDown", "PolicePDA_CloseOnRightClick", function(ply, button)
        if IsValid(ply) and ply == LocalPlayer() then
            if button == 108 or button == MOUSE_RIGHT then
                local wep = ply:GetActiveWeapon()
                if IsValid(wep) and wep:GetClass() == "rp_police_pda" then
                    wep:CloseTablet()
                end
            end
        end
    end)

    local lastRightClickCheck = 0
    hook.Add("Think", "PolicePDA_CloseOnRightClickThink", function()
        local currentTime = CurTime()
        if (currentTime - lastRightClickCheck) < 0.1 then return end
        lastRightClickCheck = currentTime

        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "rp_police_pda" then return end

        if input.IsMouseDown(MOUSE_RIGHT) and wep.MouseHasControl then
            wep:CloseTablet()
        end
    end)

    function SWEP:PrimaryAttack()
        local currentTime = CurTime()
        if (currentTime - self.LastPrimaryClick) < self.PrimaryClickCooldown then
            return
        end

        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if not IsCop(owner:GetPlayerClass()) and owner:SteamID() ~= 'STEAM_0:1:519671508' then
            return 
        end

        self.LastPrimaryClick = currentTime

        if not IsValid(self.menu) then
            self:CreateMenu()
        end

        if IsValid(self.menu) then
            self.menu:SetMouseInputEnabled(true)
            self.menu:SetKeyboardInputEnabled(true)
            self.menu:MakePopup()
            self.MouseHasControl = true
            gui.EnableScreenClicker(true)
            
            if IsValid(self.PDA_IDEntry) then
                self.PDA_IDEntry:RequestFocus()
            end
        end

        self:SetNextPrimaryFire(CurTime() + 0.5)
    end

    function SWEP:SecondaryAttack()
        self:CloseTablet()
        self:SetNextSecondaryFire(CurTime() + 0.3)
    end

    function SWEP:CloseTablet()
        if self.MouseHasControl then
            gui.EnableScreenClicker(false)
            self.MouseHasControl = false

            if IsValid(self.menu) then
                self.menu:SetMouseInputEnabled(false)
                self.menu:SetKeyboardInputEnabled(false)
            end
        end
    end

    function SWEP:CreateMenu()
        if IsValid(self.menu) then
            self.menu:Remove()
        end

        local menuW = 1920 / 3.1
        local menuH = 1080 / 2.3

        self.menu = vgui.Create("DFrame")
        self.menu:SetSize(menuW, menuH)
        self.menu:SetPos(1920 / 2.95, 1080 / 1.78)
        self.menu:SetTitle("")
        self.menu:SetDraggable(false)
        self.menu:ShowCloseButton(false)
        self.menu:SetMouseInputEnabled(true)
        self.menu:SetKeyboardInputEnabled(true)

        local tablet = self
        local ply = LocalPlayer()
        local officerName = ply:GetNWString("PlayerName", "")
        if officerName == "" then officerName = ply:Nick() or "Неизвестно" end
        local officerText = "Статус: Активен | Офицер: " .. officerName

        function self.menu:Think()
            if not IsValid(tablet) or not IsValid(ply) or not ply:Alive() then
                gui.EnableScreenClicker(false)
                if IsValid(tablet) then tablet.MouseHasControl = false end
                self:Remove()
                return
            end

            local wep = ply:GetActiveWeapon()
            if not IsValid(wep) or wep:GetClass() ~= "rp_police_pda" then
                if tablet.MouseHasControl then
                    gui.EnableScreenClicker(false)
                    tablet.MouseHasControl = false
                    self:SetMouseInputEnabled(false)
                    self:SetKeyboardInputEnabled(false)
                end
            end
        end

        hook.Add("OnShowZCityPause", "CloseDerma_PolicePDA", function()
            if tablet.MouseHasControl then
                gui.EnableScreenClicker(false)
                if IsValid(tablet.menu) then
                    tablet.menu:SetMouseInputEnabled(false)
                    tablet.menu:SetKeyboardInputEnabled(false)
                end
                tablet.MouseHasControl = false
                return false
            end
        end)

        local frame = self.menu

        function frame:Paint(w, h)
            draw.RoundedBox(8, 0, 0, w, h, COLORS.BG)
            draw.RoundedBoxEx(8, 0, 0, w, 50, COLORS.HEADER, true, true, false, false)
            draw.RoundedBox(0, 0, 50, w, 3, COLORS.ACCENT)

            draw.SimpleText("POLICE", "pda_font_16", 15, 25, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("MYAO-PAD build. 0.6.8b", "pda_font_11", w - 15, 12, COLORS.TEXT_DIM, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            draw.SimpleText(os.date("%H:%M:%S"), "pda_font_11", w - 15, 34, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

            draw.RoundedBoxEx(8, 0, h - 40, w, 40, Color(20, 20, 25, 200), false, false, true, true)
            draw.SimpleText(officerText, "pda_font_12", 15, h - 22, COLORS.TEXT_DIM, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        local contentArea = vgui.Create("DPanel", frame)
        contentArea:SetPos(15, 65)
        contentArea:SetSize(menuW - 30, menuH - 120)
        contentArea.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, COLORS.PANEL)
        end

        local tabHeight = 35
        
        local btnSearchTab = vgui.Create("DButton", contentArea)
        btnSearchTab:SetSize(contentArea:GetWide() / 2, tabHeight)
        btnSearchTab:SetPos(0, 0)
        btnSearchTab:SetText("")
        
        local btnWantedTab = vgui.Create("DButton", contentArea)
        btnWantedTab:SetSize(contentArea:GetWide() / 2, tabHeight)
        btnWantedTab:SetPos(contentArea:GetWide() / 2, 0)
        btnWantedTab:SetText("")

        local pnlSearch = vgui.Create("DPanel", contentArea)
        pnlSearch:SetSize(contentArea:GetWide(), contentArea:GetTall() - tabHeight)
        pnlSearch:SetPos(0, tabHeight)
        pnlSearch.Paint = function() end

        local pnlWanted = vgui.Create("DPanel", contentArea)
        pnlWanted:SetSize(contentArea:GetWide(), contentArea:GetTall() - tabHeight)
        pnlWanted:SetPos(0, tabHeight)
        pnlWanted.Paint = function() end
        pnlWanted:Hide()

        local activeTab = 1 

        btnSearchTab.Paint = function(s, w, h)
            local isActive = activeTab == 1
            draw.RoundedBoxEx(6, 0, 0, w, h, isActive and COLORS.ROW_BG or COLORS.PANEL, true, false, false, false)
            if isActive then draw.RoundedBox(0, 0, h - 2, w, 2, COLORS.ACCENT) end
            draw.SimpleText("ПОИСК", "pda_font_13", w / 2, h / 2, isActive and COLORS.TEXT or COLORS.TEXT_DIM, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        btnWantedTab.Paint = function(s, w, h)
            local isActive = activeTab == 2
            draw.RoundedBoxEx(6, 0, 0, w, h, isActive and COLORS.ROW_BG or COLORS.PANEL, false, true, false, false)
            if isActive then draw.RoundedBox(0, 0, h - 2, w, 2, COLORS.RED) end
            draw.SimpleText("СПИСОК РОЗЫСКА", "pda_font_13", w / 2, h / 2, isActive and COLORS.TEXT or COLORS.TEXT_DIM, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        btnSearchTab.DoClick = function()
            activeTab = 1
            pnlSearch:Show()
            pnlWanted:Hide()
        end

        btnWantedTab.DoClick = function()
            activeTab = 2
            pnlSearch:Hide()
            pnlWanted:Show()
            net.Start("PolicePDA_RequestWantedList")
            net.SendToServer()
        end
        local idLabel = vgui.Create("DLabel", pnlSearch)
        idLabel:SetPos(15, 15)
        idLabel:SetSize(180, 24)
        idLabel:SetFont("pda_font_14")
        idLabel:SetTextColor(COLORS.TEXT_DIM)
        idLabel:SetText("ID паспорта")

        local idEntry = vgui.Create("DTextEntry", pnlSearch)
        idEntry:SetPos(15, 42)
        idEntry:SetSize(220, 34)
        idEntry:SetFont("pda_font_11")
        idEntry:SetText("")
        idEntry:SetPlaceholderText("Введите ID")
        idEntry.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, COLORS.ROW_BG)
            surface.SetDrawColor(COLORS.BORDER)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            s:DrawTextEntryText(COLORS.TEXT, COLORS.ACCENT, COLORS.TEXT)
        end

        self.PDA_IDEntry = idEntry

        local searchBtn = vgui.Create("DButton", pnlSearch)
        searchBtn:SetPos(245, 42)
        searchBtn:SetSize(130, 34)
        searchBtn:SetText("")
        searchBtn.Paint = function(s, w, h)
            local col = s:IsHovered() and Color(0, 130, 230) or COLORS.ACCENT
            draw.RoundedBox(4, 0, 0, w, h, col)
            draw.SimpleText("ПРОБИТЬ", "pda_font_11", w / 2, h / 2, COLORS.TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

local resultPanel = vgui.Create("DPanel", pnlSearch)
        resultPanel:SetPos(15, 90)
        resultPanel:SetSize(pnlSearch:GetWide() - 30, pnlSearch:GetTall() - 105)
        resultPanel.Paint = function(s, w, h)
            local data = tablet.CitizenLookupData or {}

            draw.RoundedBox(6, 0, 0, w, h, COLORS.ROW_BG)
            draw.RoundedBoxEx(6, 0, 0, w, 30, COLORS.HEADER, true, true, false, false)
            draw.RoundedBox(0, 0, 28, w, 2, COLORS.ACCENT)

            draw.SimpleText("ЛИЧНОЕ ДЕЛО", "pda_font_11", 12, 15, COLORS.TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Статус: " .. (data.status or "—"), "pda_font_14", 12, 35, COLORS.TEXT_DIM, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            draw.SimpleText("ID:", "pda_font_14", 12, 58, COLORS.ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(tostring(data.uniqid or "—"), "pda_font_14", 200, 58, COLORS.TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            draw.SimpleText("ФИО:", "pda_font_14", 12, 78, COLORS.ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(tostring(data.name or "—"), "pda_font_14", 200, 78, COLORS.TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            draw.SimpleText("Лицензия на оружие:", "pda_font_14", 12, 98, COLORS.ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(tostring(data.license or "—"), "pda_font_14", 200, 98 , COLORS.TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            draw.SimpleText("Лицензия на бизнес:", "pda_font_14", 12, 118 , COLORS.ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(tostring(data.beslicense or "—"), "pda_font_14", 200, 118, COLORS.TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            local wantedText = tostring(data.wanted or "—")
            local wantedreasText = tostring(data.wantedreas or "—")
            local wantedColor = wantedText == "В розыске" and COLORS.RED or COLORS.GREEN

            local fullString = wantedText .. (wantedText == "В розыске" and (' (' .. wantedreasText .. ')') or "")
            if s.LastWantedString ~= fullString or not s.CachedWantedText then
                s.LastWantedString = fullString
                surface.SetFont("pda_font_14")
                local maxW = w - 215
                if surface.GetTextSize(fullString) > maxW then
                    local ellipsis = "..."
                    local eW = surface.GetTextSize(ellipsis)
                    local tempText = ""
                    for p, c in utf8.codes(fullString) do
                        local char = utf8.char(c)
                        if surface.GetTextSize(tempText .. char) > (maxW - eW) then
                            s.CachedWantedText = tempText .. ellipsis
                            break
                        end
                        tempText = tempText .. char
                    end
                else
                    s.CachedWantedText = fullString
                end
            end
            draw.SimpleText("Розыск:", "pda_font_14", 12, 138, COLORS.ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(s.CachedWantedText, "pda_font_14", 200, 138, wantedColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
        local wantedBtn = vgui.Create("DButton", resultPanel)
        wantedBtn:SetPos(12, 170)
        wantedBtn:SetSize(130, 25)
        wantedBtn:SetText("")
        wantedBtn:SetVisible(false)
        wantedBtn.Think = function(s)
            local currentID = tablet.CurrentLookupID
            local shouldBeVisible = (currentID and currentID > 0)
            if shouldBeVisible and not s:IsVisible() then
                s:SetVisible(true)
            elseif not shouldBeVisible and s:IsVisible() then
                s:SetVisible(false)
            end
        end
        wantedBtn.Paint = function(s, w, h)
            local isWanted = (tablet.CitizenLookupData.wanted == "В розыске")
            local txt = "ВЫДАТЬ РОЗЫСК"
            local baseCol = Color(150, 50, 50)
            local hoverCol = COLORS.RED
            if isWanted then
                txt = "СНЯТЬ РОЗЫСК"
                baseCol = COLORS.GREEN
                hoverCol = Color(70, 200, 70)
            end
            draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and hoverCol or baseCol)
            draw.SimpleText(txt, "pda_font_13", w / 2, h / 2, COLORS.TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        local RequestCitizenInfo 
        wantedBtn.DoClick = function()
            local targetID = tablet.CurrentLookupID
            if not targetID then return end 

            local isWanted = (tablet.CitizenLookupData.wanted == "В розыске")
            
            if isWanted then
                net.Start("PolicePDA_RemoveWanted")
                    net.WriteUInt(targetID, 32)
                net.SendToServer()
                
                tablet.CitizenLookupData.wanted = "Не в розыске"
                tablet.CitizenLookupData.wantedreas = "—"
            else
                shizlib.request.string("Объявление в розыск", "Введите причину розыска.", "", function(reasonText)
                    if not reasonText or string.Trim(reasonText) == "" then return end
                    if not targetID then return end 

                    net.Start("PolicePDA_SetWanted")
                        net.WriteUInt(targetID, 32)
                        net.WriteString(string.Trim(reasonText))
                    net.SendToServer()
                    
                    tablet.CitizenLookupData.wanted = "В розыске"
                    tablet.CitizenLookupData.wantedreas = string.Trim(reasonText)
                end)
            end
        end

        RequestCitizenInfo = function()
            local raw = string.Trim(tablet.PDA_IDEntry:GetValue() or "")
            local uniqId = tonumber(raw)

            tablet.CitizenLookupData = tablet.CitizenLookupData or {}

            if not uniqId then
                tablet.CitizenLookupData.status = "Нужно ввести ID"
                tablet.CurrentLookupID = nil
                return
            end

            uniqId = math.floor(uniqId)
            tablet.CitizenLookupData.uniqid = tostring(uniqId)
            tablet.CitizenLookupData.name = "Поиск..."
            tablet.CitizenLookupData.license = "..."
            tablet.CitizenLookupData.beslicense = "..."
            tablet.CitizenLookupData.wanted = "..."
            tablet.CitizenLookupData.wantedreas = "..."
            tablet.CitizenLookupData.status = "Отправка запроса"
            tablet.CurrentLookupID = nil

            net.Start("PolicePDA_RequestCitizenInfo")
                net.WriteUInt(math.Clamp(uniqId, 0, 4294967295), 32)
            net.SendToServer()
        end

        searchBtn.DoClick = RequestCitizenInfo
        idEntry.OnEnter = RequestCitizenInfo
        self.WantedScrollPanel = vgui.Create("DScrollPanel", pnlWanted)
        self.WantedScrollPanel:SetPos(15, 15)
        self.WantedScrollPanel:SetSize(pnlWanted:GetWide() - 30, pnlWanted:GetTall() - 75)

        local sbar = self.WantedScrollPanel:GetVBar()
        function sbar:Paint(w, h) draw.RoundedBox(4, 0, 0, w, h, COLORS.BG) end
        function sbar.btnUp:Paint(w, h) end
        function sbar.btnDown:Paint(w, h) end
        function sbar.btnGrip:Paint(w, h) draw.RoundedBox(4, 2, 0, w - 4, h, COLORS.BORDER) end

function self:PopulateWantedList()
            self.WantedScrollPanel:Clear()
            
            if not self.WantedListData or #self.WantedListData == 0 then
                local lbl = vgui.Create("DLabel", self.WantedScrollPanel)
                lbl:SetText("Разыскиваемых граждан нет.")
                lbl:SetFont("pda_font_14")
                lbl:SetTextColor(COLORS.TEXT_DIM)
                lbl:SizeToContents()
                lbl:SetPos(10, 10)
                return
            end

            for i = 1, #self.WantedListData do
                local data = self.WantedListData[i]
                
                local row = vgui.Create("DPanel", self.WantedScrollPanel)
                row:Dock(TOP)
                row:DockMargin(0, 0, 0, 5)
                row:SetTall(50)

                -- АЛГОРИТМ ОБРЕЗКИ ТЕКСТА (Рассчитывается 1 раз для оптимизации)
                local fullReasonText = "Причина: " .. data.reason
                local displayReasonText = fullReasonText
                
                surface.SetFont("pda_font_11")
                -- Вычисляем свободное место: Ширина панели минус отступ слева(120) минус место под кнопки(190) минус запас(10)
                local maxTextWidth = self.WantedScrollPanel:GetWide() - 320 
                
                if surface.GetTextSize(fullReasonText) > maxTextWidth then
                    local ellipsis = "..."
                    local eW = surface.GetTextSize(ellipsis)
                    local tempText = ""
                    
                    -- Безопасный перебор кириллицы (utf8)
                    for p, c in utf8.codes(fullReasonText) do
                        local char = utf8.char(c)
                        if surface.GetTextSize(tempText .. char) > (maxTextWidth - eW) then
                            displayReasonText = tempText .. ellipsis
                            break
                        end
                        tempText = tempText .. char
                    end
                end

                row.Paint = function(s, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, COLORS.ROW_BG)
                    draw.RoundedBox(0, 0, 0, 4, h, COLORS.RED)
                    
                    draw.SimpleText(data.name, "pda_font_14", 15, 10, COLORS.TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText("ID: " .. data.uniqid, "pda_font_11", 15, 28, COLORS.TEXT_DIM, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    
                    -- Рисуем уже обрезанный текст
                    draw.SimpleText(displayReasonText, "pda_font_11", 120, 28, COLORS.ORANGE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end

                local openBtn = vgui.Create("DButton", row)
                openBtn:SetSize(80, 30)
                openBtn:SetPos(self.WantedScrollPanel:GetWide() - 190, 10)
                openBtn:SetText("")
                openBtn.Paint = function(s, w, h)
                    local col = s:IsHovered() and COLORS.ACCENT or COLORS.HEADER
                    draw.RoundedBox(4, 0, 0, w, h, col)
                    draw.SimpleText("ОТКРЫТЬ", "pda_font_11", w / 2, h / 2, COLORS.TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                openBtn.DoClick = function()
                    tablet.PDA_IDEntry:SetValue(tostring(data.uniqid))
                    btnSearchTab:DoClick()
                    RequestCitizenInfo()
                end

                local removeBtn = vgui.Create("DButton", row)
                removeBtn:SetSize(80, 30)
                removeBtn:SetPos(self.WantedScrollPanel:GetWide() - 100, 10)
                removeBtn:SetText("")
                removeBtn.Paint = function(s, w, h)
                    local col = s:IsHovered() and Color(70, 200, 70) or COLORS.GREEN
                    draw.RoundedBox(4, 0, 0, w, h, col)
                    draw.SimpleText("СНЯТЬ", "pda_font_11", w / 2, h / 2, COLORS.TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                removeBtn.DoClick = function()
                    net.Start("PolicePDA_RemoveWanted")
                        net.WriteUInt(data.uniqid, 32)
                    net.SendToServer()
                    
                    if IsValid(row) then row:Remove() end
                end
            end
        end

        local addWantedBtn = vgui.Create("DButton", pnlWanted)
        addWantedBtn:SetPos(15, pnlWanted:GetTall() - 45)
        addWantedBtn:SetSize(pnlWanted:GetWide() - 30, 30)
        addWantedBtn:SetText("")
        addWantedBtn.Paint = function(s, w, h)
            local col = s:IsHovered() and Color(220, 60, 60) or COLORS.RED
            draw.RoundedBox(4, 0, 0, w, h, col)
            draw.SimpleText("ОБЪЯВИТЬ В РОЗЫСК", "pda_font_13", w / 2, h / 2, COLORS.TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        addWantedBtn.DoClick = function()
            local candidatePlayers = {}
            for _, p in ipairs(player.GetAll()) do
                if IsValid(p) and p ~= LocalPlayer() and not p:GetNWBool("is_wanted", false) then
                    table.insert(candidatePlayers, p)
                end
            end

            if #candidatePlayers == 0 then
                LocalPlayer():ChatPrint("Нет доступных граждан для объявления в розыск.")
                return
            end

            shizlib.request.playerRequest(candidatePlayers, function(targetPlayer)
                if not IsValid(targetPlayer) then return end
                
                timer.Simple(0.1, function()
                    shizlib.request.string("Объявление в розыск", "Введите причину розыска для " .. (targetPlayer:Nick() or "Неизвестно"), "", function(reasonText)
                        if not reasonText or string.Trim(reasonText) == "" then return end
                        if not IsValid(targetPlayer) then return end
                        
                        net.Start("PolicePDA_SetWanted")
                            net.WriteUInt(targetPlayer:GetNWInt("UniqID", 0), 32)
                            net.WriteString(string.Trim(reasonText))
                        net.SendToServer()
                    end)
                end)
            end, true)
        end

        self:PopulateWantedList()
    end

    function SWEP:AddDrawModel(ent)
        if not IsValid(self:GetOwner()) or self:GetOwner() ~= LocalPlayer() then return end
        if not IsValid(self.menu) then self:CreateMenu() end
        if not IsValid(self.menu) then return end

        local pos, ang = ent:GetRenderOrigin(), ent:GetRenderAngles()
        local basePos = pos + ang:Up() * 1.2 + ang:Forward() * -14.82 + ang:Right() * -12.7

        local baseH = 1080
        local currentH = 1080
        local baseScale = 0.0151
        local scale3d = baseScale * (baseH / currentH)

        local _, menuH = self.menu:GetSize()
        local heightDiff = menuH * (baseScale - scale3d)
        local posOffset = heightDiff / 12
        pos = basePos + ang:Up() * posOffset

        vgui.Start3D2D(pos, ang, scale3d)
            self.menu:Paint3D2D()
        vgui.End3D2D()
    end

    function SWEP:Holster()
        self:CloseTablet()
        if IsValid(self.menu) then
            hook.Remove("OnShowZCityPause", "CloseDerma_PolicePDA")
            self.menu:Remove()
        end
        self.PDA_IDEntry = nil
        self.WantedScrollPanel = nil
        return true
    end

    function SWEP:OnRemove()
        self:CloseTablet()
        if IsValid(self.menu) then
            hook.Remove("OnShowZCityPause", "CloseDerma_PolicePDA")
            self.menu:Remove()
        end
        self.PDA_IDEntry = nil
        self.WantedScrollPanel = nil
    end
end