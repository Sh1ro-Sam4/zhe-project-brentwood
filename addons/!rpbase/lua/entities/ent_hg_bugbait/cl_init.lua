include("shared.lua")

local ScreenOffset = Vector(1.2, 39.2, 29.2) 
local ScreenScale = 0.098 

function ENT:Initialize()
    self.LastURL = ""
    self.LastVolume = -1
    self.LastPausedState = false
end

local function ProcessURL(url)
    if not url or url == "" then return "" end

    if not url:find("^http") then
        url = "https://" .. url
    end

    local yt_id = url:match("v=([%w_-]+)") or url:match("youtu%.be/([%w_-]+)") or url:match("embed/([%w_-]+)")
    if yt_id then
        return "https://yewtu.be/embed/" .. yt_id .. "?autoplay=1"
    end

    local twitch_channel = url:match("twitch%.tv/([%w_]+)")
    if twitch_channel then
        return "https://player.twitch.tv/?channel=" .. twitch_channel .. "&parent=localhost&autoplay=true"
    end

    return url
end

function ENT:UpdateHTML(raw_url)
    if not raw_url or raw_url == "" then
        if IsValid(self.HTML) then
            self.HTML:Remove()
            self.HTML = nil
        end
        return
    end

    if not IsValid(self.HTML) then
        self.HTML = vgui.Create("DHTML")
        self.HTML:SetSize(800, 600)
        self.HTML:SetPaintedManually(true)
    end

    local final_url = ProcessURL(raw_url)
    self.HTML:OpenURL(final_url)
    self.LastPausedState = false
end

function ENT:Think()
    local currentUrl = self:GetCurrentURL()
    if self.LastURL ~= currentUrl then
        self.LastURL = currentUrl
        self:UpdateHTML(currentUrl)
    end

    if IsValid(self.HTML) and self:GetIsPlaying() then
        -- 1. Логика Паузы
        local isPaused = self:GetIsPaused()
        if self.LastPausedState ~= isPaused then
            self.LastPausedState = isPaused
            
            -- JS код, который пытается поставить на паузу любые плееры (HTML5, iframe YT/Twitch)
            local action = isPaused and "pause()" or "play()"
            local ytAction = isPaused and "pauseVideo" or "playVideo"
            
            local js = string.format([[
                // Стандартные HTML5 плееры (Invidious, MP4)
                var media = document.querySelectorAll('video, audio');
                for(var i=0; i<media.length; i++) { media[i].%s; }
                
                // YouTube Iframe (на случай если вставлен обычный ютуб)
                var iframes = document.querySelectorAll('iframe');
                for(var i=0; i<iframes.length; i++) {
                    iframes[i].contentWindow.postMessage('{"event":"command","func":"%s","args":""}', '*');
                }
            ]], action, ytAction)
            
            self.HTML:RunJavascript(js)
        end

        -- 2. Логика затухания звука
        local ply = LocalPlayer()
        if IsValid(ply) then
            local dist = self:GetPos():Distance(ply:GetPos())
            local maxDist = 800 
            local vol = math.Clamp(100 - (dist / maxDist) * 100, 0, 100) / 100 

            if math.abs(self.LastVolume - vol) > 0.02 then
                self.LastVolume = vol
                local js = string.format([[
                    var media = document.querySelectorAll('video, audio');
                    for(var i=0; i<media.length; i++) { media[i].volume = %f; }
                ]], vol)
                self.HTML:RunJavascript(js)
            end
        end
    end
end

local function DrawNoSignalScreen()
    surface.SetDrawColor(0, 0, 120, 255)
    surface.DrawRect(0, 0, 800, 600)

    surface.SetDrawColor(255, 255, 255, 5)
    surface.DrawOutlinedRect(20, 20, 760, 560, 4)

    draw.SimpleText("НЕТ СИГНАЛА", "DermaLarge", 400, 260, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("Нажмите [ E ] чтобы включить", "DermaDefault", 400, 320, Color(200, 200, 200, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function ENT:Draw()
    self:DrawModel()

    local pos = self:LocalToWorld(ScreenOffset)
    local ang = self:GetAngles()
    ang:RotateAroundAxis(self:GetUp(), -90)
    ang:RotateAroundAxis(self:GetForward(), 90)

    cam.Start3D2D(pos, ang, ScreenScale)
        if self:GetIsPlaying() and IsValid(self.HTML) then
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, 800, 600)
            
            self.HTML:PaintManual()

            -- Рисуем значок паузы поверх экрана, если стоит на паузе
            if self:GetIsPaused() then
                surface.SetDrawColor(0, 0, 0, 150)
                surface.DrawRect(0, 0, 800, 600)
                
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawRect(350, 250, 30, 100)
                surface.DrawRect(420, 250, 30, 100)
            end
        else
            DrawNoSignalScreen()
        end
    cam.End3D2D()
end

function ENT:OnRemove()
    if IsValid(self.HTML) then
        self.HTML:Remove()
    end
end

net.Receive("TV_OpenMenu", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Пульт управления телевизором")
    frame:SetSize(400, 460)
    frame:Center()
    frame:MakePopup()

    local label = vgui.Create("DLabel", frame)
    label:SetText("Ссылка (YouTube, Twitch, .mp4):")
    label:Dock(TOP)
    label:DockMargin(10, 5, 10, 5)

    local textEntry = vgui.Create("DTextEntry", frame)
    textEntry:Dock(TOP)
    textEntry:DockMargin(10, 0, 10, 10)
    textEntry:SetPlaceholderText("https://...")

    local playBtn = vgui.Create("DButton", frame)
    playBtn:SetText("▶ Запустить видео")
    playBtn:Dock(TOP)
    playBtn:DockMargin(10, 0, 10, 5)
    playBtn.DoClick = function()
        local val = textEntry:GetValue()
        if val ~= "" then
            net.Start("TV_ChangeURL")
            net.WriteEntity(ent)
            net.WriteString(val)
            net.SendToServer()
            frame:Close()
        end
    end

    -- КНОПКА ПАУЗЫ
    local pauseBtn = vgui.Create("DButton", frame)
    local isPaused = ent.GetIsPaused and ent:GetIsPaused() or false
    pauseBtn:SetText(isPaused and "▶ Продолжить" or "⏸ Поставить на паузу")
    pauseBtn:Dock(TOP)
    pauseBtn:DockMargin(10, 0, 10, 10)
    pauseBtn.DoClick = function()
        net.Start("TV_TogglePause")
        net.WriteEntity(ent)
        net.SendToServer()
        frame:Close()
    end

    local stopBtn = vgui.Create("DButton", frame)
    stopBtn:SetText("⏹ Выключить телевизор")
    stopBtn:Dock(TOP)
    stopBtn:DockMargin(10, 0, 10, 10)
    stopBtn.DoClick = function()
        net.Start("TV_ChangeURL")
        net.WriteEntity(ent)
        net.WriteString("")
        net.SendToServer()
        frame:Close()
    end

    local listLabel = vgui.Create("DLabel", frame)
    listLabel:SetText("Избранные каналы:")
    listLabel:Dock(TOP)
    listLabel:DockMargin(10, 5, 10, 5)

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 0, 10, 10)

    local presets = {
        { name = "YouTube: Lofi Radio", url = "https://www.youtube.com/watch?v=jfKfPfyJRdk" },
        { name = "YouTube: GMod OST", url = "https://www.youtube.com/watch?v=p_S-m97v6QA" },
        { name = "Twitch: GDQ", url = "https://www.twitch.tv/gamesdonequick" },
        { name = "Файл: Big Buck Bunny (Кино)", url = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" }
    }

    for _, preset in ipairs(presets) do
        local btn = scroll:Add("DButton")
        btn:SetText(preset.name)
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, 5)
        btn.DoClick = function()
            net.Start("TV_ChangeURL")
            net.WriteEntity(ent)
            net.WriteString(preset.url)
            net.SendToServer()
            frame:Close()
        end
    end
end)