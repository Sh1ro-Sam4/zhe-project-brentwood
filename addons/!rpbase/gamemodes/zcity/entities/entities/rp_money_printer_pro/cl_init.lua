include('shared.lua')

local color_bg          = Color(8, 10, 5, 250)
local color_main        = Color(255, 215, 0)
local color_dark_gold   = Color(184, 134, 11)
local color_red         = Color(255, 40, 40)
local color_dark_red    = Color(80, 10, 10)
local color_yellow      = Color(255, 200, 0)
local color_gray        = Color(160, 150, 130)
local color_platinum    = Color(229, 228, 226)
local color_prem_bg     = Color(5, 8, 3, 250)

surface.CreateFont('Prn_Huge', {font = "Roboto", size = 150, weight = 800, scanlines = 3, antialias = true})
surface.CreateFont('Prn_Header', {font = "Roboto", size = 75, weight = 800, scanlines = 2, antialias = true})
surface.CreateFont('Prn_Main', {font = "Roboto", size = 55, weight = 600, scanlines = 2, antialias = true})
surface.CreateFont('Prn_GlitchBig', {font = "Roboto", size = 130, weight = 900, scanlines = 4, antialias = true})
surface.CreateFont('Prn_ScanLine', {font = "Courier New", size = 18, weight = 500, antialias = false})
surface.CreateFont('Prn_Matrix', {font = "Courier New", size = 14, weight = 100, antialias = false})

local matrix_chars = {}
for i = 32, 126 do matrix_chars[#matrix_chars+1] = string.char(i) end
local matrix_cols = 40
local matrix_streams = {}
for i = 1, matrix_cols do
    matrix_streams[i] = {y = math.random(-1000, 0), speed = math.random(80, 150)}
end

netstream.Hook("imperator_printer_used", function()
    -- local opts = {
    --     {
    --         "Переключить питание",
    --         "sprinter/repair.png",
    --         function()
    --             netstream.Start("imperator_printer_choose", {idx = 1})
    --         end,
    --     },
    --     {
    --         "Забрать деньги",
    --         "sprinter/withdraw.png",
    --         function()
    --             netstream.Start("imperator_printer_choose", {idx = 2})
    --         end,
    --     }
    -- }
    -- shizlib.circularMenu(opts)
    local tbl = {}
		tbl[#tbl + 1] = {function()
			netstream.Start("imperator_printer_choose", {idx = 1})
		end, "Переключить питание"}
		tbl[#tbl + 1] = {function()
			netstream.Start("imperator_printer_choose", {idx = 2})
		end, "Забрать деньги"}
		hg.CreateRadialMenu(tbl)
end)

local ox, oy, ow, oh = -2282, -384, 1890, 785

local function DrawTerminalFrame(x, y, w, h, isEnabled)
    local mainCol = isEnabled and color_main or color_red
    local darkCol = isEnabled and color_dark_gold or color_dark_red
    local bg = isEnabled and color_prem_bg or color_bg

    draw.RoundedBox(0, x, y, w, h, bg)
    
    surface.SetDrawColor(mainCol.r, mainCol.g, mainCol.b, 15)
    for i = 0, h, 50 do surface.DrawRect(x, y + i, w, 2) end
    for i = 0, w, 50 do surface.DrawRect(x + i, y, 2, h) end

    surface.SetDrawColor(0, 0, 0, 100)
    for i = 0, h, 10 do surface.DrawRect(x, y + i, w, 4) end

    surface.SetDrawColor(darkCol)
    surface.DrawOutlinedRect(x + 2, y + 2, w - 4, h - 4, 4)
    
    local cl = 60 
    surface.SetDrawColor(color_platinum)
    surface.DrawRect(x, y, cl, 6) surface.DrawRect(x, y, 6, cl)
    surface.DrawRect(x + w - cl, y, cl, 6) surface.DrawRect(x + w - 6, y, 6, cl)
    surface.DrawRect(x, y + h - 6, cl, 6) surface.DrawRect(x, y + h - cl, 6, cl)
    surface.DrawRect(x + w - cl, y + h - 6, cl, 6) surface.DrawRect(x + w - 6, y + h - cl, 6, cl)
end

local function DrawSegmentedBar(x, y, w, h, progress, title, valText, colorMain, colorDark)
    draw.SimpleText(title, "Prn_Main", x, y - 60, colorMain, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    if valText then
        draw.SimpleText(valText, "Prn_Main", x + w, y - 60, colorMain, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end

    surface.SetDrawColor(colorDark)
    surface.DrawOutlinedRect(x, y, w, h, 4)

    local segments = 25
    local segW = (w / segments) - 6
    for i = 1, segments do
        local fillCol = (i / segments <= progress) and colorMain or Color(0,0,0,0)
        draw.RoundedBox(0, x + 3 + (i-1)*(segW+6), y + 4, segW, h - 8, fillCol)
    end
end

local vault_max = 1000000
local last_money = 0

local coin_particles = {}
local coin_radius = 100
local gravity = 400
local bounce_factor = 0.6
local max_coins = 50

local function DrawCyberVault(x, y, w, h, money, enabled)
    if enabled then
        for i = 1, #matrix_streams do
            local stream = matrix_streams[i]
            local char_x = x + (i - 1) * (w / matrix_cols)
            local char_y = stream.y
            for j = 1, 5 do
                local c = matrix_chars[math.random(#matrix_chars)]
                local alpha = math.Clamp(100 - j * 20, 10, 100)
                local col = math.random() < 0.35 and Color(255, 215, 0, alpha) or Color(0, 255, 60, alpha)
                draw.SimpleText(c, "Prn_Matrix", char_x, char_y - j*14, col, TEXT_ALIGN_LEFT)
            end
            stream.y = stream.y + stream.speed * FrameTime()
            if stream.y > y + h + 100 then stream.y = y - 50 end
        end
    end

    DrawTerminalFrame(x, y, w, h, enabled)

    local markColor = enabled and color_main or color_platinum
    draw.SimpleText("IMP-MK7-CV-88X PRO ♛", "Prn_Header", x + w/64, y + h - 940, markColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    draw.SimpleText("FW 3.1.5-rc2 (сборка 452)", "Prn_Header", x + w/64, y + h - 880, markColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

    if not enabled then
        local blink = math.sin(CurTime() * 4) > 0
        draw.SimpleText("[ ХРАНИЛИЩЕ ОТКЛЮЧЕНО ]", "Prn_Huge", x + w/2, y + h/2 - 30, blink and color_platinum or color_dark_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("АКТИВИРУЙТЕ ПИТАНИЕ", "Prn_Header", x + w/2, y + h/2 + 80, color_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return
    end

    local t = CurTime()
    local dt = FrameTime()

    local glitch_text = ""
    local money_str = tostring(money)
    local formatted = ""
    local len = #money_str
    for i = 1, len do
        formatted = formatted .. money_str[i]
        if (len - i) % 3 == 0 and i ~= len then
            formatted = formatted .. ","
        end
    end
    for i = 1, #formatted do
        if math.random() < 0.15 and t % 0.1 < 0.05 then
            glitch_text = glitch_text .. string.char(math.random(48, 57))
        else
            glitch_text = glitch_text .. formatted[i]
        end
    end
    draw.SimpleText("$" .. glitch_text, "Prn_GlitchBig", x + w - 70, y + 60, color_main, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

    local crownX = x + w - 200
    local crownY = y + 120

    local target = math.floor(money / 100)
    if target > max_coins then target = max_coins end

    while #coin_particles < target do
        local margin = coin_radius + 15
        local nx = x + margin + math.random() * (w - margin * 2)
        local ny = y + margin + math.random() * (h - margin * 2)
        table.insert(coin_particles, {
            x = nx,
            y = ny,
            vx = math.random(-100, 100),
            vy = math.random(-200, -50),
            rot = math.random() * 360
        })
    end
    while #coin_particles > target do
        table.remove(coin_particles)
    end

    local left = x + coin_radius + 10
    local right = x + w - coin_radius - 10
    local top = y + coin_radius + 10
    local bottom = y + h - coin_radius - 10

    for i = 1, #coin_particles do
        local p = coin_particles[i]
        p.vy = p.vy + gravity * dt
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt

        local maxSpeed = 300
        local speed = math.sqrt(p.vx * p.vx + p.vy * p.vy)
        if speed > maxSpeed then
            p.vx = p.vx * (maxSpeed / speed)
            p.vy = p.vy * (maxSpeed / speed)
        end

        if p.x < left then
            p.x = left
            p.vx = -p.vx * bounce_factor
        elseif p.x > right then
            p.x = right
            p.vx = -p.vx * bounce_factor
        end
        if p.y < top then
            p.y = top
            p.vy = -p.vy * bounce_factor
        elseif p.y > bottom then
            p.y = bottom
            p.vy = -p.vy * bounce_factor
        end

        if math.random() < 0.01 then
            p.vy = p.vy - math.random(50, 150)
            p.vx = p.vx + math.random(-50, 50)
        end
    end

    local minDist = coin_radius * 2
    for i = 1, #coin_particles do
        for j = i + 1, #coin_particles do
            local p1 = coin_particles[i]
            local p2 = coin_particles[j]
            local dx = p2.x - p1.x
            local dy = p2.y - p1.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist < minDist and dist > 0.001 then
                local overlap = minDist - dist
                local nx = dx / dist
                local ny = dy / dist
                p1.x = p1.x - nx * overlap * 0.5
                p1.y = p1.y - ny * overlap * 0.5
                p2.x = p2.x + nx * overlap * 0.5
                p2.y = p2.y + ny * overlap * 0.5
                local v1x, v1y = p1.vx, p1.vy
                local v2x, v2y = p2.vx, p2.vy
                local dvx = v1x - v2x
                local dvy = v1y - v2y
                local dv_dot_n = dvx * nx + dvy * ny
                if dv_dot_n > 0 then
                    p1.vx = v1x - dv_dot_n * nx
                    p1.vy = v1y - dv_dot_n * ny
                    p2.vx = v2x + dv_dot_n * nx
                    p2.vy = v2y + dv_dot_n * ny
                end
                p1.vx = p1.vx * 0.98
                p1.vy = p1.vy * 0.98
                p2.vx = p2.vx * 0.98
                p2.vy = p2.vy * 0.98
            end
        end
    end

    for i = 1, #coin_particles do
        local p = coin_particles[i]
        p.rot = p.rot + dt * 200

        surface.SetDrawColor(229, 228, 226, 30)
        surface.DrawCircle(p.x, p.y, coin_radius + 8)

        surface.SetDrawColor(0, 0, 0, 50)
        surface.DrawCircle(p.x + 2, p.y + 2, coin_radius)

        surface.SetDrawColor(255, 215, 0, 255)
        surface.DrawCircle(p.x, p.y, coin_radius)

        surface.SetDrawColor(229, 228, 226, 255)
        surface.DrawCircle(p.x, p.y, coin_radius - 3)

        draw.SimpleText("$", "Prn_Header", p.x, p.y - 8, Color(180, 160, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local fillPerc = math.Clamp(money / vault_max, 0, 1)
    local status = money >= vault_max and "ПЕРЕПОЛНЕНИЕ!" or "НАКОПЛЕНИЕ"
    local status_col = money >= vault_max and color_red or color_main
    draw.SimpleText(status, "Prn_Header", x + w/2, y + h - 480, status_col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    draw.SimpleText(string.format("ЗАПОЛНЕНО: %.1f%%", fillPerc * 100), "Prn_Main", x + w/2, y + h - 420, color_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end

function ENT:Draw()
    self:DrawModel()

    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 7000 then return end

    local pos = self:GetPos()
    local ang = self:GetAngles()
    local isEnabled = self:GetEnabled()

    ang:RotateAroundAxis(ang:Up(), 0)
    ang:RotateAroundAxis(ang:Forward(), 90)
    
    cam.Start3D2D(pos + ang:Up() * 0.1, ang, 0.01)
        
        DrawTerminalFrame(ox, oy, ow, oh, isEnabled)

        if isEnabled then
            local barX, barW, barH = ox + 70, 850, 50

            local printSpeed = math.max(1, self:GetUD_Speed())
            local printPerc = math.Clamp((CurTime() - self:GetLastPrint()) / (60 / printSpeed), 0, 1)
            DrawSegmentedBar(barX, oy + 180, barW, barH, printPerc, "> ПРОЦЕСС ПЕЧАТИ:", string.format("%d%%", printPerc * 100), color_main, color_dark_gold)

            local maxInk = self:GetUD_Max() * 15
            local curInk = self:GetInk()
            local inkPerc = math.Clamp(curInk / maxInk, 0, 1)
            local inkCol = inkPerc > 0.2 and color_yellow or color_red
            DrawSegmentedBar(barX, oy + 400, barW, barH, inkPerc, "> УРОВЕНЬ ЧЕРНИЛ:", curInk .. " / " .. maxInk, inkCol, Color(80, 60, 0))

            local hpPerc = math.Clamp(self:GetHP() / 100, 0, 1)
            local hpCol = hpPerc > 0.3 and color_main or color_red
            local hpDark = hpPerc > 0.3 and color_dark_gold or color_dark_red
            DrawSegmentedBar(barX, oy + 620, barW, barH, hpPerc, "> ЦЕЛОСТНОСТЬ СИСТЕМЫ:", self:GetHP() .. "%", hpCol, hpDark)

            local statsX = ox + 1020
            local statsY = oy + 180

            draw.SimpleText("> МОДУЛИ СИСТЕМЫ:", "Prn_Header", statsX, statsY - 50, color_main)
            draw.SimpleText("{", "Prn_Header", statsX, statsY + 30, color_gray)
            
            draw.SimpleText(string.format("\"Качество деталей\" : %02d ур.", self:GetUD_Speed()), "Prn_Main", statsX + 50, statsY + 110, color_yellow)
            draw.SimpleText(string.format("\"Прочность узла\"   : %02d ур.", self:GetUD_HP()), "Prn_Main", statsX + 50, statsY + 190, color_yellow)
            draw.SimpleText(string.format("\"Ёмкость бака\"     : %02d ур.", self:GetUD_Max()), "Prn_Main", statsX + 50, statsY + 270, color_yellow)

            draw.SimpleText("}", "Prn_Header", statsX, statsY + 350, color_gray)

            if math.sin(CurTime() * 8) > 0 then
                draw.RoundedBox(0, ox + ow - 80, oy + 30, 30, 30, color_main)
            end
            draw.SimpleText("SYS. ONLINE", "Prn_Main", ox + ow - 100, oy + 20, color_main, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
        else
            local cx, cy = ox + ow / 2, oy + oh / 2
            local blink = math.sin(CurTime() * 4) > 0

            draw.SimpleText("[ ПИТАНИЕ ОТКЛЮЧЕНО ]", "Prn_Huge", cx, cy - 60, blink and color_platinum or color_dark_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("ОЖИДАНИЕ ЗАПУСКА СИСТЕМЫ...", "Prn_Header", cx, cy + 80, color_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

    cam.End3D2D()

    ang:RotateAroundAxis(ang:Up(), 360)
    ang:RotateAroundAxis(ang:Forward(), -90)

    cam.Start3D2D(pos + ang:Up() * 4.4, ang, 0.01)
        local money = self:GetMoneyInMe()
        DrawCyberVault(-2282, -1100, 1890, 1045, money, isEnabled)
    cam.End3D2D()
end