local PoliceCodes = {
    ["10-коды"] = {
        { "10-1", "Слабый/плохой приём" },
        { "10-4", "Принято / Копия" },
        { "10-6", "Занят" },
        { "10-7", "Вышел из строя (оффлайн)" },
        { "10-8", "В службе" },
        { "10-9", "Повторите" },
        { "10-10", "Остановка отдыха" },
        { "10-12", "Посетитель/гость" },
        { "10-13", "Неблагоприятные погодные условия" },
        { "10-15", "Принятие подозреваемого" },
        { "10-17", "Запрос на подачу топлива" },
        { "10-18", "Срочная поездка" },
        { "10-19", "Возвращение в (указать место)" },
        { "10-20", "Местоположение" },
        { "10-21", "Позвоните по телефону" },
        { "10-22", "Вызов с использованием (транспорта)" },
        { "10-23", "Прибытие на место" },
        { "10-24", "Задание выполнено" },
        { "10-25", "Сообщение от (указать кого)" },
        { "10-26", "Следуйте за вызовом" },
        { "10-27", "Подозрительная личность" },
        { "10-28", "Автомобиль подозреваемого" },
        { "10-29", "Проверка на кражу" },
        { "10-30", "Беспокойство / беспокойство" },
        { "10-31", "Грабеж" },
        { "10-32", "Стрельба" },
        { "10-33", "Пожар" },
        { "10-34", "Драка" },
        { "10-35", "Взрыв" },
        { "10-36", "Смертельный исход" },
        { "10-37", "Преследование" },
        { "10-38", "Преследование с оружием" },
        { "10-41", "Начало смены" },
        { "10-42", "Конец смены" },
        { "10-43", "Медицинская помощь" },
        { "10-44", "Проблемы с лекарствами" },
        { "10-45", "Врач" },
        { "10-46", "Адвокат" },
        { "10-47", "Пожарный" },
        { "10-50", "ДТП" },
        { "10-51", "ДТП с участием (подозреваемого)" },
        { "10-52", "Скорая помощь" },
        { "10-55", "Подозреваемый в вождении в нетрезвом виде" },
        { "10-56", "Домашнее насилие" },
        { "10-57", "Расследование" },
        { "10-58", "Блокпост" },
        { "10-59", "Подозрительный объект" },
        { "10-60", "Преследование" },
        { "10-61", "Медицинская помощь" },
        { "10-62", "Заменить офицера" },
        { "10-63", "Описание" },
        { "10-64", "Личность" },
        { "10-65", "Пропавший человек" },
        { "10-66", "Заложник" },
        { "10-67", "Без охраны" },
        { "10-68", "Огнестрельное оружие" },
        { "10-69", "Оружие" },
        { "10-70", "Вооружённый" },
        { "10-71", "Раненый" },
        { "10-72", "Требуется помощь" },
        { "10-73", "Подозреваемый вооружён" },
        { "10-74", "Помощь в чрезвычайной ситуации" },
        { "10-75", "В поиске" },
        { "10-76", "Сопровождение" },
        { "10-77", "Задержание" },
        { "10-78", "Требуется помощь" },
        { "10-79", "Связь с (указать кого)" },
        { "10-80", "Преследование" },
        { "10-81", "Спокойный район" },
        { "10-82", "Подозреваемый" },
        { "10-83", "Преследование прекращена" },
        { "10-84", "Угрозы" },
        { "10-85", "Преследование" },
        { "10-86", "Служба полиции" },
        { "10-88", "Без происшествий" },
        { "10-89", "Потерянный" },
        { "10-91", "Неправильное направление" },
        { "10-92", "Задержание" },
        { "10-93", "Преследование" },
        { "10-94", "Подозреваемый пойман" },
        { "10-95", "Проблема с оружием" },
        { "10-97", "В хорошем состоянии" },
        { "10-98", "Вне службы" },
        { "10-99", "Связь с диспетчером" }
    },
    ["11-коды"] = {
        { "11-10", "Прибытие на место" },
        { "11-12", "Нарушение общественного порядка" },
        { "11-20", "ДТП" },
        { "11-24", "Пожар" },
        { "11-25", "Взрыв" },
        { "11-27", "Подозрительная личность" },
        { "11-28", "Автомобиль подозреваемого" },
        { "11-30", "Нарушение правил" },
        { "11-33", "Стрельба" },
        { "11-34", "Драка" },
        { "11-35", "Взрыв" },
        { "11-37", "Преследование" },
        { "11-50", "ДТП" },
        { "11-55", "Вождение в нетрезвом виде" },
        { "11-56", "Домашнее насилие" },
        { "11-57", "Расследование" },
        { "11-58", "Блокпост" },
        { "11-59", "Подозрительный объект" },
        { "11-60", "Преследование" },
        { "11-65", "Пропавший человек" },
        { "11-66", "Заложник" },
        { "11-68", "Огнестрельное оружие" },
        { "11-70", "Вооружённый" },
        { "11-71", "Раненый" },
        { "11-75", "В поиске" },
        { "11-77", "Задержание" },
        { "11-80", "Преследование" },
        { "11-85", "Преследование" },
        { "11-88", "Без происшествий" },
        { "11-92", "Задержание" },
        { "11-99", "Связь с диспетчером" }
    }
}

local s = shizlib.surface.s
local DTR = shizlib.surface.DTR
local RNDX = include("shizlib/client/rndx_cl.lua")

local function OpenPoliceCodesMenu()
    local theme = CFG.theme
    if frame_codes and IsValid(frame_codes) then frame_codes:Remove() end

    frame_codes = vgui.Create("EditablePanel")
    frame_codes:SetSize(0, s(600))
    frame_codes:Center()
    
    frame_codes:SizeTo(s(500), s(600), .4, 0)
    frame_codes:MoveTo(shizlib.hud.ScrW / 2 - s(250), shizlib.hud.ScrH / 2 - s(300), .4, 0)
    
    local dragging = false
    local dragX, dragY = 0, 0

    local resizing = false
    local resizemode = ""
    local initialW, initialH = 0, 0
    local initialMouseX, initialMouseY = 0, 0

    function frame_codes:OnMousePressed(key)
        if key ~= MOUSE_LEFT then return end

        local mouseX, mouseY = gui.MousePos()
        local frameX, frameY = self:GetPos()
        local w, h = self:GetSize()

        local localX, localY = mouseX - frameX, mouseY - frameY
        local edge = 10

        local onRight = localX >= w - edge
        local onBottom = localY >= h - edge

        if onRight and onBottom then
            resizing = true
            resizemode = "SE"
        elseif onRight then
            resizing = true
            resizemode = "W"
        elseif onBottom then
            resizing = true
            resizemode = "H"
        else
            dragging = true
            dragX, dragY = localX, localY
        end

        if resizing then
            initialW, initialH = w, h
            initialMouseX, initialMouseY = mouseX, mouseY
        end

        self:MouseCapture(true)
    end

    function frame_codes:OnMouseReleased(key)
        dragging = false
        resizing = false
        resizemode = ""
        self:MouseCapture(false)
        self:SetCursor("arrow")
    end

    function frame_codes:Think()
        local mouseX, mouseY = gui.MousePos()
        local w, h = self:GetSize()

        if not dragging and not resizing then
            local frameX, frameY = self:GetPos()
            local localX, localY = mouseX - frameX, mouseY - frameY
            local edge = 10

            local onRight = localX >= w - edge and localX <= w
            local onBottom = localY >= h - edge and localY <= h

            if onRight and onBottom then
                self:SetCursor("sizenwse")
            elseif onRight then
                self:SetCursor("sizewe")
            elseif onBottom then
                self:SetCursor("sizens")
            else
                self:SetCursor("arrow")
            end
        end

        if resizing then
            local deltaX = mouseX - initialMouseX
            local deltaY = mouseY - initialMouseY

            local newW = initialW
            local newH = initialH

            if resizemode == "W" or resizemode == "SE" then
                newW = math.max(s(350), initialW + deltaX)
            end
            if resizemode == "H" or resizemode == "SE" then
                newH = math.max(s(300), initialH + deltaY)
            end

            self:SetSize(newW, newH)
        elseif dragging then
            self:SetPos(mouseX - dragX, mouseY - dragY)
        end
    end

    function frame_codes:Paint(w, h)
        RNDX.Draw(8, 0, 0, w, h, theme.bg, RNDX.SHAPE_FIGMA)
    end

    frame_codes.cls = frame_codes:Add("DButton")
    local cls = frame_codes.cls
    cls:SetSize(s(95), s(26))
    cls:SetText("")
    cls.lerpHover = 0
    cls.Paint = function(me, w, h)
        me.lerpHover = math.Approach(me.lerpHover, me:IsHovered() and 1 or 0, FrameTime()*5)
        draw.RoundedBox(6, 0, 0, w, h, shizlib.surface.LerpColor(me.lerpHover, Color(255,255,255,0), color_white))
        draw.RoundedBox(5, w - s(38), 0, s(38), h, color_white)
        draw.SimpleText("Выход", "IB_14", s(5), h*.5, shizlib.surface.LerpColor(me.lerpHover, color_white, color_black), 0, 1)
        draw.SimpleText("Esc", "IB_14", w - s(7), h*.5, color_black, 2, 1)
    end
    cls.DoClick = function() frame_codes:AlphaTo(0, 0.2, 0, function() frame_codes:Remove() end) end

    function cls:Think()
        local parentW = self:GetParent():GetWide()
        self:SetPos(parentW - s(20) - s(95), s(20))
    end

    frame_codes.mtitle = frame_codes:Add("DLabel")
    frame_codes.mtitle:Dock(TOP)
    frame_codes.mtitle:DockMargin(s(40), s(20), 0, s(12))
    frame_codes.mtitle:SetTall(s(30))
    frame_codes.mtitle:SetText("Полицейские коды")
    frame_codes.mtitle:SetFont("IB_25")
    frame_codes.mtitle:SetTextColor(color_white)
    frame_codes.mtitle:SetMouseInputEnabled(false)

    local line = frame_codes:Add("Panel")
    line:Dock(TOP)
    line:DockMargin(s(40), s(5), s(40), s(10))
    line:SetTall(s(2))
    line:SetMouseInputEnabled(false)
    function line:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(40,40,40))
    end

    local scroll = vgui.Create("DScrollPanel", frame_codes)
    scroll:Dock(FILL)
    scroll:DockMargin(s(20), 0, s(20), s(20))
    local sbar = scroll:GetVBar()
    sbar:SetWide(s(4))
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 30))
    end

    for category, codes in pairs(PoliceCodes) do
        local catLabel = scroll:Add("DLabel")
        catLabel:Dock(TOP)
        catLabel:SetText(category)
        catLabel:SetFont("IB_16")
        catLabel:SetTextColor(Color(200, 200, 200))
        catLabel:DockMargin(s(20), s(15), 0, s(15))
        
        for _, codeData in pairs(codes) do
            local code, desc = codeData[1], codeData[2]
            
            local item = scroll:Add("DPanel")
            item:Dock(TOP)
            item:SetTall(s(40))
            item:DockMargin(s(15), s(2), s(15), 0)

            surface.SetFont("IB_14")
            local tw, th = surface.GetTextSize(code)
            local boxW = math.max(s(34), tw + s(15))

            function item:Paint(w, h)
                RNDX.Draw(6, 0, 0, w, h, Color(32, 32, 32))
                RNDX.Draw(4, s(4), s(4), boxW, h - s(8), Color(24, 24, 24))

                draw.SimpleText(code, "IB_14", s(4) + boxW/2, h/2, color_white, 1, 1)
                draw.SimpleText(desc, "IB_14", s(12) + boxW, h/2, Color(200, 200, 200), 0, 1)
            end
        end
    end
end

concommand.Add("policecodes", OpenPoliceCodesMenu)