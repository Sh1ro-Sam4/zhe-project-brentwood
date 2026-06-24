if not CLIENT then return end

iPhoneOS = iPhoneOS or {}

local targetMusicHudY = -100
local currentMusicHudY = -100

hook.Add("HUDPaint", "iPhone_CallHUD", function()
    if iPhoneOS.iPhone_MusicData.active then
        if IsValid(iPhoneOS.iPhone_MusicStream) then
            -- Привязываем звук к игроку, чтобы 3D аудио BASS работало!
            iPhoneOS.iPhone_MusicStream:SetPos(LocalPlayer():GetPos()) 
            
            local st = iPhoneOS.iPhone_MusicStream:GetState()
            if st == GMOD_CHANNEL_PLAYING or st == GMOD_CHANNEL_PAUSED then
                iPhoneOS.iPhone_MusicData.startedPlaying = true
                iPhoneOS.iPhone_MusicData.cur = iPhoneOS.iPhone_MusicStream:GetTime() or 0
                iPhoneOS.iPhone_MusicData.dur = iPhoneOS.iPhone_MusicStream:GetLength() or 0
                iPhoneOS.iPhone_MusicData.isPaused = (st == GMOD_CHANNEL_PAUSED)
                iPhoneOS.iPhone_MusicData.isLive = iPhoneOS.iPhone_MusicData.forceLive or iPhoneOS.iPhone_MusicStream:IsBlockStreamed()
            elseif st == 0 then
                if iPhoneOS.iPhone_MusicData.startedPlaying then 
                    iPhoneOS.iPhone_MusicData.active = false 
                end
            end
        elseif not IsValid(iPhoneOS.iPhone_YouTubePlayer) then
            iPhoneOS.iPhone_MusicData.active = false
        end
    end

    targetMusicHudY = -100
    if iPhoneOS.iPhone_MusicData.active and not IsValid(_G.iPhoneFrame_Global) then 
        targetMusicHudY = (iPhoneOS.CallData.state ~= "none") and 70 or 20 
    end
    currentMusicHudY = Lerp(FrameTime() * 10, currentMusicHudY, targetMusicHudY)

    if currentMusicHudY > -50 then
        local w, h = 320, 50
        local x = ScrW() / 2 - w / 2
        local y = currentMusicHudY
        
        iPhoneOS.DrawRounded(20, x, y, w, h, Color(25, 25, 25, 245))
        iPhoneOS.DrawRounded(12, x + 10, y + h/2 - 15, 30, 30, Color(255, 45, 85))
        iPhoneOS.DrawRounded(6, x + 17, y + h/2 - 8, 16, 16, color_white)

        draw.SimpleText(iPhoneOS.SafeSub(iPhoneOS.iPhone_MusicData.title, 25), "iOS_Text", x + 50, y + 14, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        if iPhoneOS.iPhone_MusicData.isLive then
            draw.SimpleText("Прямой эфир", "iOS_IconList", x + 50, y + 34, Color(160, 160, 165), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            local curStr = string.format("%d:%02d", math.floor(iPhoneOS.iPhone_MusicData.cur / 60), math.floor(iPhoneOS.iPhone_MusicData.cur % 60))
            local durStr = string.format("%d:%02d", math.floor(iPhoneOS.iPhone_MusicData.dur / 60), math.floor(iPhoneOS.iPhone_MusicData.dur % 60))
            draw.SimpleText(curStr .. " / " .. durStr, "iOS_IconList", x + w - 15, y + 14, Color(160, 160, 165), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            
            local barW = w - 65
            local barX = x + 50
            local barY = y + 32
            iPhoneOS.DrawRounded(2, barX, barY, barW, 4, Color(50, 50, 55))
            
            local progress = math.Clamp(iPhoneOS.iPhone_MusicData.cur / math.max(iPhoneOS.iPhone_MusicData.dur, 1), 0, 1)
            iPhoneOS.DrawRounded(2, barX, barY, barW * progress, 4, color_white)
        end
    end

    if iPhoneOS.CallData.state == "none" or IsValid(_G.iPhoneFrame_Global) then return end
    if iPhoneOS.CallData.state == "incoming" and not iPhoneOS.PhoneData.Sounds then return end

    local nameText = iPhoneOS.SafeSub(iPhoneOS.CallData.targetName, 12)
    local text = ""
    local glowColor = Color(46, 204, 113)

    if iPhoneOS.CallData.state == "incoming" then 
        text = "Входящий: " .. nameText
        local pulse = math.abs(math.sin(CurTime() * 5)) * 155
        glowColor = Color(46, 204, 113, 100 + pulse)
    elseif iPhoneOS.CallData.state == "calling" then 
        text = "Дозвон: " .. nameText
        local pulse = math.abs(math.sin(CurTime() * 5)) * 155
        glowColor = Color(241, 196, 15, 100 + pulse)
    elseif iPhoneOS.CallData.state == "active" then 
        local dur = math.floor(CurTime() - iPhoneOS.CallData.startTime)
        text = string.format("%02d:%02d - %s", math.floor(dur / 60), dur % 60, nameText)
        glowColor = Color(46, 204, 113, 200) 
    end

    surface.SetFont("iOS_AppTitle")
    local txtW, txtH = surface.GetTextSize(text)
    local w, h = txtW + 60, 40
    local x, y = ScrW() / 2 - w / 2, 20

    iPhoneOS.DrawRounded(20, x - 2, y - 2, w + 4, h + 4, glowColor)
    iPhoneOS.DrawRounded(18, x, y, w, h, Color(25, 25, 25, 245))
    iPhoneOS.DrawRounded(4, x + 15, y + h/2 - 8, 12, 16, Color(46, 204, 113))
    iPhoneOS.DrawRounded(2, x + 17, y + h/2 - 5, 8, 10, Color(25, 25, 25, 245))
    iPhoneOS.DrawRounded(2, x + 19, y + h/2 + 4, 4, 2, Color(25, 25, 25, 245))
    
    draw.SimpleText(text, "iOS_AppTitle", x + 35, y + h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end)
