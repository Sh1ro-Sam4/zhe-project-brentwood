if not CLIENT then return end
iPhoneOS = iPhoneOS or {}
iPhoneOS.Apps = iPhoneOS.Apps or {}

iPhoneOS.Apps["snake"] = function(appID)
    local theme = iPhoneOS.GetTheme()
    iPhoneOS.CurrentApp.bgColor = theme.bg

    -- Заголовок
    local header = vgui.Create("DPanel", iPhoneOS.CurrentApp)
    header:SetSize(iPhoneOS.SCREEN_W, 80)
    header.Paint = function(self, w, h)
        iPhoneOS.DrawRounded(32, 0, 0, w, 64, theme.bg2)
        iPhoneOS.DrawRounded(0, 0, 32, w, h - 32, theme.bg2)
        draw.SimpleText("Змейка", "iOS_Title", 20, 45, theme.text, TEXT_ALIGN_LEFT)
        surface.SetDrawColor(theme.line)
        surface.DrawLine(0, h-1, w, h-1)
    end

    -- Параметры игры
    local gridSize = 14
    local cellSize = math.floor((iPhoneOS.SCREEN_W - 40) / gridSize)
    local boardW = cellSize * gridSize
    local boardH = cellSize * gridSize
    local boardX = math.floor((iPhoneOS.SCREEN_W - boardW) / 2)
    local boardY = 90

    -- Состояние
    local snake = {{x=7, y=7}, {x=6, y=7}, {x=5, y=7}}
    local dir = {x=1, y=0}
    local nextDir = {x=1, y=0}
    local food = {x=10, y=7}
    local score = 0
    local gameOver = false
    local gamePaused = false
    local lastTick = CurTime()
    local speed = 0.22
    local eatEffects = {} -- {x, y, time, color}
    local gameOverAlpha = 0

    -- Счёт
    local scoreLbl = vgui.Create("DLabel", header)
    scoreLbl:SetPos(iPhoneOS.SCREEN_W - 120, 45)
    scoreLbl:SetSize(100, 30)
    scoreLbl:SetFont("iOS_AppTitle")
    scoreLbl:SetTextColor(theme.accent)
    scoreLbl:SetContentAlignment(6)

    -- Спавн еды
    local function SpawnFood()
        local empty = {}
        for x = 0, gridSize - 1 do
            for y = 0, gridSize - 1 do
                local isSnake = false
                for i = 1, #snake do
                    if snake[i].x == x and snake[i].y == y then isSnake = true break end
                end
                if not isSnake then table.insert(empty, {x = x, y = y}) end
            end
        end
        if #empty > 0 then food = empty[math.random(1, #empty)] end
    end

    -- Игровое поле
    local board = vgui.Create("DPanel", iPhoneOS.CurrentApp)
    board:SetPos(boardX, boardY)
    board:SetSize(boardW, boardH)
    board.Paint = function(self, w, h)
        -- Фон поля
        iPhoneOS.DrawRounded(12, 0, 0, w, h, theme.bg2)

        -- Сетка (тонкая)
        for i = 1, gridSize - 1 do
            surface.SetDrawColor(ColorAlpha(theme.line, 30))
            surface.DrawLine(i * cellSize, 0, i * cellSize, h)
            surface.DrawLine(0, i * cellSize, w, i * cellSize)
        end

        -- Еда с пульсацией
        local pulse = 0.8 + math.sin(CurTime() * 6) * 0.2
        local foodSize = math.floor((cellSize - 4) * pulse)
        local foodOffset = math.floor((cellSize - foodSize) / 2)
        iPhoneOS.DrawRounded(cellSize/3, food.x * cellSize + foodOffset, food.y * cellSize + foodOffset, foodSize, foodSize, Color(231, 76, 60))
        -- Свечение еды
        iPhoneOS.DrawRounded(cellSize/2, food.x * cellSize + 2, food.y * cellSize + 2, cellSize - 4, cellSize - 4, Color(231, 76, 60, 30 + math.sin(CurTime() * 4) * 25))

        -- Змейка
        for i = #snake, 1, -1 do
            local part = snake[i]
            local frac = 1 - ((i - 1) / math.max(#snake, 1))
            local alpha = 120 + math.floor(frac * 135)
            local size = math.floor((cellSize - 2) * (0.7 + frac * 0.3))
            local offset = math.floor((cellSize - size) / 2)
            local col

            if i == 1 then
                -- Голова — ярче, с лёгким свечением
                col = theme.accent
                iPhoneOS.DrawRounded(cellSize/3, part.x * cellSize + 1, part.y * cellSize + 1, cellSize - 2, cellSize - 2, ColorAlpha(theme.accent, 40))
                iPhoneOS.DrawRounded(cellSize/3, part.x * cellSize + offset, part.y * cellSize + offset, size, size, col)
                
                -- Глазки
                local eyeSize = math.max(3, math.floor(cellSize / 6))
                local cx = part.x * cellSize + cellSize / 2
                local cy = part.y * cellSize + cellSize / 2
                if dir.x == 1 then
                    iPhoneOS.DrawRounded(eyeSize, cx + 2, cy - 4, eyeSize, eyeSize, color_white)
                    iPhoneOS.DrawRounded(eyeSize, cx + 2, cy + 2, eyeSize, eyeSize, color_white)
                elseif dir.x == -1 then
                    iPhoneOS.DrawRounded(eyeSize, cx - 4, cy - 4, eyeSize, eyeSize, color_white)
                    iPhoneOS.DrawRounded(eyeSize, cx - 4, cy + 2, eyeSize, eyeSize, color_white)
                elseif dir.y == -1 then
                    iPhoneOS.DrawRounded(eyeSize, cx - 4, cy - 4, eyeSize, eyeSize, color_white)
                    iPhoneOS.DrawRounded(eyeSize, cx + 2, cy - 4, eyeSize, eyeSize, color_white)
                else
                    iPhoneOS.DrawRounded(eyeSize, cx - 4, cy + 2, eyeSize, eyeSize, color_white)
                    iPhoneOS.DrawRounded(eyeSize, cx + 2, cy + 2, eyeSize, eyeSize, color_white)
                end
            else
                col = Color(theme.accent.r, theme.accent.g, theme.accent.b, alpha)
                iPhoneOS.DrawRounded(cellSize/4, part.x * cellSize + offset, part.y * cellSize + offset, size, size, col)
            end
        end

        -- Эффекты поедания
        for i = #eatEffects, 1, -1 do
            local e = eatEffects[i]
            local age = CurTime() - e.time
            if age > 0.5 then
                table.remove(eatEffects, i)
            else
                local frac = age / 0.5
                local radius = cellSize * (1 + frac * 2)
                local alpha = math.floor(180 * (1 - frac))
                iPhoneOS.DrawRounded(radius/2, e.x * cellSize + cellSize/2 - radius/2, e.y * cellSize + cellSize/2 - radius/2, radius, radius, Color(e.color.r, e.color.g, e.color.b, alpha))
                
                -- +1 текст
                local textAlpha = math.floor(255 * (1 - frac))
                local yOff = math.floor(frac * -20)
                draw.SimpleText("+1", "iOS_AppTitle", e.x * cellSize + cellSize/2, e.y * cellSize + yOff, Color(255, 255, 255, textAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        -- Экран Game Over
        if gameOver then
            gameOverAlpha = math.min(gameOverAlpha + FrameTime() * 400, 200)
            iPhoneOS.DrawRounded(12, 0, 0, w, h, Color(0, 0, 0, gameOverAlpha))
            
            if gameOverAlpha > 100 then
                draw.SimpleText("ИГРА ОКОНЧЕНА", "iOS_Title", w/2, h/2 - 30, Color(231, 76, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("Счёт: " .. score, "iOS_AppTitle", w/2, h/2 + 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("Рекорд: " .. iPhoneOS.PhoneData.SnakeHighScore, "iOS_AppTitle", w/2, h/2 + 30, theme.subText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("Нажми ▶ для рестарта", "iOS_IconList", w/2, h/2 + 60, ColorAlpha(theme.subText, 100 + math.sin(CurTime() * 3) * 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end

    -- Логика игры
    board.Think = function()
        scoreLbl:SetText("⭐ " .. score)
        if gameOver or gamePaused then return end
        if CurTime() - lastTick > speed then
            lastTick = CurTime()
            dir = nextDir
            local head = snake[1]
            local newHead = {x = head.x + dir.x, y = head.y + dir.y}

            -- Стены = смерть
            if newHead.x < 0 or newHead.x >= gridSize or newHead.y < 0 or newHead.y >= gridSize then
                gameOver = true
                gameOverAlpha = 0
                iPhoneOS.PlayUISound("Error")
                if score > iPhoneOS.PhoneData.SnakeHighScore then
                    iPhoneOS.PhoneData.SnakeHighScore = score
                    iPhoneOS.SavePhoneData()
                    iPhoneOS.ShowPhoneNotification("Змейка", "Новый рекорд: " .. score .. "!", Color(255, 215, 0), "snake")
                end
                return
            end

            -- Столкновение с собой
            for i = 1, #snake do
                if snake[i].x == newHead.x and snake[i].y == newHead.y then
                    gameOver = true
                    gameOverAlpha = 0
                    iPhoneOS.PlayUISound("Error")
                    if score > iPhoneOS.PhoneData.SnakeHighScore then
                        iPhoneOS.PhoneData.SnakeHighScore = score
                        iPhoneOS.SavePhoneData()
                        iPhoneOS.ShowPhoneNotification("Змейка", "Новый рекорд: " .. score .. "!", Color(255, 215, 0), "snake")
                    end
                    return
                end
            end

            table.insert(snake, 1, newHead)
            if newHead.x == food.x and newHead.y == food.y then
                score = score + 1
                speed = math.max(0.08, speed - 0.005)
                iPhoneOS.PlayUISound("Notification")
                table.insert(eatEffects, {x = food.x, y = food.y, time = CurTime(), color = theme.accent})
                SpawnFood()
            else
                table.remove(snake)
            end
        end
    end

    -- Кнопки управления (D-Pad)
    local btnSize = 55
    local cx = iPhoneOS.SCREEN_W / 2 - btnSize / 2
    local cy = boardY + boardH + 65

    local directions = {
        {x = cx, y = cy - 62, dx = 0, dy = -1, icon = "▲"},
        {x = cx, y = cy + 62, dx = 0, dy = 1, icon = "▼"},
        {x = cx - 62, y = cy, dx = -1, dy = 0, icon = "◀"},
        {x = cx + 62, y = cy, dx = 1, dy = 0, icon = "▶"}
    }

    for _, d in ipairs(directions) do
        local btn = vgui.Create("DButton", iPhoneOS.CurrentApp)
        btn:SetPos(d.x, d.y)
        btn:SetSize(btnSize, btnSize)
        btn:SetText("")
        btn.Paint = function(self, w, h)
            local isActive = (dir.x == d.dx and dir.y == d.dy)
            local bgCol = isActive and ColorAlpha(theme.accent, 60) or theme.bg2
            if self:IsHovered() then bgCol = ColorAlpha(theme.accent, 100) end
            iPhoneOS.DrawRounded(w/2, 0, 0, w, h, bgCol)
            
            -- Стрелка
            local arrowCol = isActive and theme.accent or theme.text
            draw.SimpleText(d.icon, "iOS_AppTitle", w/2, h/2, arrowCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        btn.DoClick = function()
            if gameOver then
                -- Рестарт
                snake = {{x=7, y=7}, {x=6, y=7}, {x=5, y=7}}
                dir = {x=1, y=0}
                nextDir = {x=1, y=0}
                score = 0
                speed = 0.22
                gameOver = false
                gameOverAlpha = 0
                eatEffects = {}
                SpawnFood()
                return
            end
            if dir.x ~= -d.dx or dir.y ~= -d.dy then
                nextDir = {x = d.dx, y = d.dy}
            end
        end
    end

    -- Кнопка назад
    local backBtn = vgui.Create("DButton", header)
    backBtn:SetPos(iPhoneOS.SCREEN_W - 50, 40)
    backBtn:SetSize(40, 30)
    backBtn:SetText("←")
    backBtn:SetFont("iOS_AppTitle")
    backBtn:SetTextColor(theme.accent)
    backBtn.Paint = function() end
    backBtn.DoClick = function()
        iPhoneOS.PlayUISound("Click")
        iPhoneOS.LaunchApp("home")
    end
end
