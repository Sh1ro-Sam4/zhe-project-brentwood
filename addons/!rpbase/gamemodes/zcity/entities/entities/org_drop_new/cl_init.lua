include('shared.lua')

local color_bg = Color(5, 10, 5, 245)
local color_main = Color(0, 255, 60)
local color_dark_green = Color(0, 60, 15)
local color_red = Color(255, 40, 40)
local color_dark_red = Color(80, 10, 10)
local color_yellow = Color(255, 200, 0)
local color_white = Color(255, 255, 255)
local color_gray = Color(100, 120, 100)

surface.CreateFont('Term_Huge', {font = "Hitmarker Normal", size = 50, weight = 300, scanlines = 2, antialias = true})
surface.CreateFont('Term_Header', {font = "Hitmarker Normal", size = 32, weight = 300, scanlines = 2, antialias = true})
surface.CreateFont('Term_Main', {font = "Hitmarker Normal", size = 22, weight = 300, scanlines = 2, antialias = true})
surface.CreateFont('Term_Small', {font = "Hitmarker Normal", size = 16, weight = 300, scanlines = 2, antialias = true})

local matBeam = Material("cable/redlaser")
local matGlow = Material("sprites/light_glow02_add")
local matGrad = Material("gui/gradient_up")

local function GlitchText(realText, progress, requiredProgress)
    if progress >= requiredProgress then return tostring(realText) end
    local chars = "01!@#$%&?X#*"
    local str = ""
    for i = 1, #tostring(realText) + 2 do
        str = str .. string.char(string.byte(chars, math.random(1, #chars)))
    end
    return str
end

local function DrawTerminalFrame(x, y, w, h, isHacking)
    local mainCol = isHacking and color_main or color_red
    local darkCol = isHacking and color_dark_green or color_dark_red

    draw.RoundedBox(0, x, y, w, h, color_bg)
    
    surface.SetDrawColor(mainCol.r, mainCol.g, mainCol.b, 15)
    for i = 0, h, 20 do surface.DrawRect(x, y + i, w, 1) end
    for i = 0, w, 20 do surface.DrawRect(x + i, y, 1, h) end

    surface.SetDrawColor(0, 0, 0, 100)
    for i = 0, h, 4 do surface.DrawRect(x, y + i, w, 2) end

    surface.SetDrawColor(darkCol)
    surface.DrawOutlinedRect(x + 2, y + 2, w - 4, h - 4, 1)
    
    local cl = 25 
    surface.SetDrawColor(mainCol)
    surface.DrawRect(x, y, cl, 3) surface.DrawRect(x, y, 3, cl)
    surface.DrawRect(x + w - cl, y, cl, 3) surface.DrawRect(x + w - 3, y, 3, cl)
    surface.DrawRect(x, y + h - 3, cl, 3) surface.DrawRect(x, y + h - cl, 3, cl)
    surface.DrawRect(x + w - cl, y + h - 3, cl, 3) surface.DrawRect(x + w - 3, y + h - cl, 3, cl)
end

function ENT:Draw()
    self:DrawModel()

    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 500000 then return end

    local time = CurTime()
    local endTime = self:GetHackEndTime()
    local isHacking = (endTime > time)

    local zoneCol = color_red
    if isHacking then
        local cVec = self:GetHackOrgColor()
        zoneCol = Color(cVec.x * 255, cVec.y * 255, cVec.z * 255)
    end

    local tr = util.TraceLine({
        start = self:GetPos() + Vector(0,0,10),
        endpos = self:GetPos() - Vector(0,0,100),
        filter = self
    })
    
    local floorPos = tr.HitPos + Vector(0, 0, 1)
    local radius = 100
    local segments = 32
    local height = 120 + math.sin(time * 2) * 10

    --render.SetMaterial(matGlow)
    --render.DrawSprite(floorPos, radius * 2.5, radius * 2.5, ColorAlpha(zoneCol, 40))

    render.SetMaterial(matGrad)
    local wallAlpha = isHacking and (20 + math.sin(time * 6) * 10) or 10
    local wallCol = Color(zoneCol.r, zoneCol.g, zoneCol.b, wallAlpha)

    for i = 1, segments do
        local a1 = math.rad((i / segments) * 360 + (time * 0.5))
        local a2 = math.rad(((i + 1) / segments) * 360 + (time * 0.5))
        
        local p1 = floorPos + Vector(math.cos(a1) * radius, math.sin(a1) * radius, 0)
        local p2 = floorPos + Vector(math.cos(a2) * radius, math.sin(a2) * radius, 0)
        local p3 = p2 + Vector(0, 0, height)
        local p4 = p1 + Vector(0, 0, height)
        
        render.DrawQuad(p4, p3, p2, p1, wallCol)
        render.DrawQuad(p1, p2, p3, p4, wallCol)
    end

    local attachment = self:GetAttachment(2)
    if not attachment then return end

    local ComPos = attachment.Pos
    local ComAng = attachment.Ang

    local screenW, screenH = 450, 268 
    local x, y = -(screenW / 128), -(screenH / 64) 
    local blink = math.sin(time * 8) > 0

    cam.Start3D2D(ComPos, ComAng, 0.035)
        
        DrawTerminalFrame(x, y, screenW, screenH, isHacking)

        if isHacking then
            local startTime = self:GetHackStartTime()
            local hackOrg = self:GetHackOrg()
            
            local hackCol = zoneCol

            local timeLeft = math.max(0, endTime - time)
            local totalTime = math.max(1, endTime - startTime)
            local progress = 1 - (timeLeft / totalTime)

            local headerH = 40
            draw.RoundedBox(0, x + 10, y + 10, screenW - 20, headerH, blink and color_dark_red or color_bg)
            surface.SetDrawColor(color_red)
            surface.DrawOutlinedRect(x + 10, y + 10, screenW - 20, headerH, 1)
            
            draw.SimpleText("[ SYSTEM COMPROMISED ]", "Term_Header", x + screenW/2, y + 10 + headerH/2, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            draw.SimpleText("OVERRIDE AUTH: " .. hackOrg, "Term_Main", x + 20, y + 65, hackCol)
            
            local ms = math.floor((timeLeft % 1) * 100)
            local timeText = string.format("TIME REMAINING: %02d:%02d:%02d", math.floor(timeLeft / 60), timeLeft % 60, ms)
            draw.SimpleText(timeText, "Term_Main", x + 20, y + 90, color_main)

            local barX, barY, barW, barH = x + 20, y + 120, screenW - 40, 25
            surface.SetDrawColor(color_dark_green)
            surface.DrawOutlinedRect(barX, barY, barW, barH, 1)

            local segmentsBar = 25
            local segW = (barW / segmentsBar) - 2
            for i = 1, segmentsBar do
                local fillCol = (i / segmentsBar <= progress) and color_main or Color(0,0,0,0)
                draw.RoundedBox(0, barX + 1 + (i-1)*(segW+2), barY + 2, segW, barH - 4, fillCol)
            end

            local startY = y + 160
            draw.SimpleText("> DECRYPTING DATABASE...", "Term_Small", x + 20, startY, color_main)
            draw.SimpleText("{", "Term_Main", x + 20, startY + 20, color_gray)
            
            local valWeap = GlitchText(self:GetWepCount(), progress, 0.3)
            local valMoney = GlitchText(self:GetReward(), progress, 0.6)
            local valPoints = GlitchText(self:GetScoreCount(), progress, 0.9)

            draw.SimpleText("\"Weapons\": " .. valWeap .. ",", "Term_Main", x + 40, startY + 40, color_yellow)
            draw.SimpleText("\"Money\": " .. valMoney .. ",", "Term_Main", x + 40, startY + 60, color_yellow)
            draw.SimpleText("\"Score\"  : " .. valPoints, "Term_Main", x + 40, startY + 80, color_yellow)
            draw.SimpleText("}", "Term_Main", x + 20, startY + 100, color_gray)

            local pct = string.format("STATUS: %02d%%", progress * 100)
            draw.SimpleText(pct, "Term_Main", x + screenW - 20, y + screenH - 30, color_main, TEXT_ALIGN_RIGHT)

        else
            local cy = y + screenH / 2

            local rot = time * 45
            surface.SetDrawColor(color_red)
            surface.DrawTexturedRectRotated(x + screenW/2, cy - 20, 60, 60, rot)
            surface.SetDrawColor(color_bg)
            surface.DrawTexturedRectRotated(x + screenW/2, cy - 20, 50, 50, -rot)
            
            draw.SimpleText("!", "Term_Huge", x + screenW/2, cy - 20, blink and color_red or color_dark_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            draw.SimpleText("Terminal is blocked", "Term_Huge", x + screenW/2, cy + 30, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("MULTI HACKING IS NOT AVAILABLE", "Term_Main", x + screenW/2, cy + 65, color_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            local randCode1 = "0x" .. string.format("%04X", math.random(1000, 9999))
            local randCode2 = "0x" .. string.format("%04X", math.random(1000, 9999))
            draw.SimpleText(randCode1, "Term_Small", x + 15, y + 15, color_dark_red)
            draw.SimpleText(randCode2, "Term_Small", x + screenW - 15, y + screenH - 25, color_dark_red, TEXT_ALIGN_RIGHT)
        end

    cam.End3D2D()
end