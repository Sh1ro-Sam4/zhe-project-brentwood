if SAM_LOADED then return end

local sam, command, language = sam, sam.command, sam.language

command.set_category("Chat")

-- ===================================================================
-- СЕРВЕРНАЯ ЧАСТЬ
-- ===================================================================
if SERVER then
    util.AddNetworkString("SendCustomAnnouncement_Clean")
end

-- ===================================================================
-- КЛИЕНТСКАЯ ЧАСТЬ
-- ===================================================================
if CLIENT then
    -- Настройки дизайна
    local NOTIFY_DURATION = 5
    local ANIMATION_TIME = 0.6
    local TARGET_Y = 50
    local PANEL_HEIGHT = 75
    local ACCENT_COLOR = Color(0, 175, 255)

    -- Переменные состояния
    local shouldDraw, announceMessage, startTime = false, "", 0
    local panelW = 0

    -- Шрифты
    surface.CreateFont("Clean_Title", { font = "Roboto", size = 20, weight = 700, antialias = true })
    surface.CreateFont("Clean_Message", { font = "Roboto", size = 16, weight = 400, antialias = true })

    -- Локальная функция анимации
    local function easeOutBack(x)
        local c1 = 1.70158
        local c3 = c1 + 1
        return 1 + c3 * (x - 1)^3 + c1 * (x - 1)^2
    end

    -- Главная функция отрисовки
    hook.Add("HUDPaint", "DrawCleanNotification", function()
        if not shouldDraw then return end

        local screenW = ScrW()
        local timePassed = RealTime() - startTime

        -- Анимация
        local currentY, mainAlpha = TARGET_Y, 255
        if timePassed < ANIMATION_TIME then
            local fraction = timePassed / ANIMATION_TIME
            currentY = Lerp(easeOutBack(fraction), -PANEL_HEIGHT, TARGET_Y)
            mainAlpha = Lerp(fraction, 0, 255)
        elseif timePassed > NOTIFY_DURATION - (ANIMATION_TIME * 0.7) then
            local fraction = (timePassed - (NOTIFY_DURATION - (ANIMATION_TIME * 0.7))) / (ANIMATION_TIME * 0.7)
            currentY = Lerp(fraction, TARGET_Y, -PANEL_HEIGHT)
            mainAlpha = Lerp(fraction, 255, 0)
        end

        if timePassed > NOTIFY_DURATION then shouldDraw = false; return end

        local panelX = screenW / 2 - panelW / 2

        -- === ФИНАЛЬНЫЙ ДИЗАЙН ===
        -- 1. Тень для объема
        draw.RoundedBox(6, panelX + 3, currentY + 3, panelW, PANEL_HEIGHT, Color(0, 0, 0, mainAlpha * 0.2))
        -- 2. Основной фон
        draw.RoundedBox(6, panelX, currentY, panelW, PANEL_HEIGHT, Color(45, 48, 54, mainAlpha * 0.98))
        -- 3. Верхняя акцентная полоса (добавлен альфа-канал)
        draw.RoundedBoxEx(6, panelX, currentY, panelW, 4, Color(ACCENT_COLOR.r, ACCENT_COLOR.g, ACCENT_COLOR.b, mainAlpha), true, true, false, false)

        -- 4. Текст (добавлено затухание через mainAlpha)
        local textCenterX = panelX + panelW / 2
        local titleY = currentY + 22
        local messageY = currentY + 46
        draw.DrawText("Админ Уведомление", "Clean_Title", textCenterX, titleY, Color(255, 255, 255, mainAlpha), TEXT_ALIGN_CENTER)
        draw.DrawText(announceMessage, "Clean_Message", textCenterX, messageY, Color(200, 200, 200, mainAlpha), TEXT_ALIGN_CENTER)
    end)

    -- Получаем сообщение от сервера
    net.Receive("SendCustomAnnouncement_Clean", function()
        announceMessage = net.ReadString()
        surface.SetFont("Clean_Message")
        local textW, _ = surface.GetTextSize(announceMessage)
        surface.SetFont("Clean_Title")
        local titleW, _ = surface.GetTextSize("Админ Уведомление")

        panelW = math.max(titleW, textW) + 80

        shouldDraw = true
        startTime = RealTime()
    end)
end

-- ===================================================================
-- ОБЩАЯ ЧАСТЬ (Команда SAM)
-- ===================================================================
command.new("anotify")
    :SetPermission("anotify_use", "admin") -- Исправлено: права по умолчанию выдаются группе "admin"
    :AddArg("text", {hint = "сообщение"})
    :GetRestArgs()
    :Help("Показывает красивое глобальное уведомление всем игрокам.")
    :OnExecute(function(ply, message)
        if not message or message == "" then
            ply:sam_send_message("Вы не ввели сообщение. Используйте: {V}", { V = "!anotify <сообщение>" })
            return
        end

        net.Start("SendCustomAnnouncement_Clean")
            net.WriteString(message)
        net.Broadcast()

        -- Сбор администраторов для отправки оповещения в админ-чат
        local targets = {}
        for _, v in player.Iterator() do
            if v:HasPermission("see_admin_chat") then
                table.insert(targets, v)
            end
        end

        if #targets > 0 then
            sam.player.send_message(targets, "Администратор {A} отправил уведомление: {V}", { A = ply, V = message })
        end
    end)
:End()