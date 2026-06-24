if not CLIENT then return end

iPhoneOS = iPhoneOS or {}
iPhoneOS.Apps = iPhoneOS.Apps or {}


-- АНТИ-АВТОРЕФРЕШ: Удаляем все старые интерфейсы при перезагрузке файла
for _, pnl in ipairs(vgui.GetWorldPanel():GetChildren()) do
    if pnl:GetClassName() == "DFrame" and pnl:GetWide() == 340 then 
        pnl:Remove() 
    end
    if pnl:GetClassName() == "DButton" and pnl:GetWide() == ScrW() and pnl:GetText() == "" then 
        pnl:Remove() 
    end
end

print("[iPhone] Клиентская часть телефона инициализирована (Clean Mode)!")

-- Оставляем создание папки для кастомных файлов игроков, если они захотят туда что-то кинуть
file.CreateDir("iphone_icons")

iPhoneOS.PhoneData = {
    Notes = {}, 
    ReceivedNotes = {}, 
    Drawings = {}, 
    Sms = {}, 
    Transactions = {},
    CustomPlaylist = {}, 
    Notifications = {}, 
    ThemeIdx = 1, 
    Sounds = true, 
    SnakeHighScore = 0, 
    Brightness = 1, 
    AirplaneMode = false, 
    Wifi = true,
    Steps = 0
}

iPhoneOS.CallData = { 
    state = "none", 
    targetEnt = NULL, 
    targetName = "", 
    startTime = 0 
}

iPhoneOS.iPhone_YouTubePlayer = nil
iPhoneOS.iPhone_MusicStream = nil
iPhoneOS.iPhone_MusicVolume = 0.5
iPhoneOS.iPhone_MusicData = { 
    active = false, 
    startedPlaying = false, 
    isPaused = false, 
    title = "", 
    cur = 0, 
    dur = 0, 
    isLive = true, 
    forceLive = false 
}
iPhoneOS.FFT_Data = {}

iPhoneOS.CustomImagesCache = {}
function iPhoneOS.GetCustomImage(id)
    if iPhoneOS.CustomImagesCache[id] ~= nil then 
        return iPhoneOS.CustomImagesCache[id] 
    end
    
    local pathPng = "iphone_icons/" .. id .. ".png"
    local pathJpg = "iphone_icons/" .. id .. ".jpg"
    
    -- 1. Сначала ищем в контенте аддона/игры (materials/iphone_icons/...)
    if file.Exists("materials/" .. pathPng, "GAME") then
        iPhoneOS.CustomImagesCache[id] = Material(pathPng, "noclamp smooth")
        return iPhoneOS.CustomImagesCache[id]
    elseif file.Exists("materials/" .. pathJpg, "GAME") then
        iPhoneOS.CustomImagesCache[id] = Material(pathJpg, "noclamp smooth")
        return iPhoneOS.CustomImagesCache[id]
    end
    
    -- 2. Если в аддоне нет, ищем в папке DATA (garrysmod/data/iphone_icons/...)
    if file.Exists(pathPng, "DATA") then 
        iPhoneOS.CustomImagesCache[id] = Material("../data/" .. pathPng, "noclamp smooth")
    elseif file.Exists(pathJpg, "DATA") then 
        iPhoneOS.CustomImagesCache[id] = Material("../data/" .. pathJpg, "noclamp smooth")
    else 
        iPhoneOS.CustomImagesCache[id] = false 
    end
    
    return iPhoneOS.CustomImagesCache[id]
end

-- presetRadios определены в sh_config.lua

function iPhoneOS.SavePhoneData() 
    file.Write("iphone_os_data.txt", util.TableToJSON(iPhoneOS.PhoneData)) 
end

function iPhoneOS.LoadPhoneData()
    if file.Exists("iphone_os_data.txt", "DATA") then
        local data = util.JSONToTable(file.Read("iphone_os_data.txt", "DATA"))
        if data then 
            iPhoneOS.PhoneData.Notes = data.Notes or {}
            iPhoneOS.PhoneData.Transactions = data.Transactions or {}
            iPhoneOS.PhoneData.ReceivedNotes = data.ReceivedNotes or {}
            iPhoneOS.PhoneData.Drawings = data.Drawings or {}
            iPhoneOS.PhoneData.Sms = data.Sms or {}
            iPhoneOS.PhoneData.CustomPlaylist = data.CustomPlaylist or {}
            iPhoneOS.PhoneData.Notifications = data.Notifications or {}
            iPhoneOS.PhoneData.ThemeIdx = data.ThemeIdx or 1
            iPhoneOS.PhoneData.SnakeHighScore = data.SnakeHighScore or 0
            iPhoneOS.PhoneData.Brightness = data.Brightness or 1
            if data.AirplaneMode ~= nil then iPhoneOS.PhoneData.AirplaneMode = data.AirplaneMode end
            if data.Wifi ~= nil then iPhoneOS.PhoneData.Wifi = data.Wifi end
            if data.Sounds ~= nil then iPhoneOS.PhoneData.Sounds = data.Sounds end
            iPhoneOS.PhoneData.Steps = data.Steps or 0
        end
    end
end
iPhoneOS.LoadPhoneData()

function iPhoneOS.SafeSub(str, maxChars)
    if not str then return "" end
    local res = ""
    local count = 0
    for uchar in string.gmatch(str, "([%z\1-\127\194-\244][\128-\191]*)") do 
        res = res .. uchar
        count = count + 1
        if count >= maxChars then break end 
    end
    return res
end

function iPhoneOS.GetYouTubeID(url)
    local id = string.match(url, "v=([%w-_]+)")
    if not id then id = string.match(url, "youtu%.be/([%w-_]+)") end
    if not id then id = string.match(url, "embed/([%w-_]+)") end
    return id
end

function iPhoneOS.StopMusic()
    iPhoneOS.iPhone_MusicData.active = false
    iPhoneOS.iPhone_MusicData.startedPlaying = false
    iPhoneOS.iPhone_MusicData.isPaused = false
    if IsValid(iPhoneOS.iPhone_MusicStream) then 
        iPhoneOS.iPhone_MusicStream:Stop()
        iPhoneOS.iPhone_MusicStream = nil 
    end
    if IsValid(iPhoneOS.iPhone_YouTubePlayer) then 
        iPhoneOS.iPhone_YouTubePlayer:Remove()
        iPhoneOS.iPhone_YouTubePlayer = nil 
    end
end

function iPhoneOS.TogglePause()
    if not iPhoneOS.iPhone_MusicData.active then return end
    if IsValid(iPhoneOS.iPhone_MusicStream) then
        if iPhoneOS.iPhone_MusicStream:GetState() == GMOD_CHANNEL_PLAYING then 
            iPhoneOS.iPhone_MusicStream:Pause()
            iPhoneOS.iPhone_MusicData.isPaused = true
        elseif iPhoneOS.iPhone_MusicStream:GetState() == GMOD_CHANNEL_PAUSED then 
            iPhoneOS.iPhone_MusicStream:Play()
            iPhoneOS.iPhone_MusicData.isPaused = false 
        end
    elseif IsValid(iPhoneOS.iPhone_YouTubePlayer) then
        if iPhoneOS.iPhone_MusicData.isPaused then 
            iPhoneOS.iPhone_YouTubePlayer:RunJavascript("cmdPlay();")
            iPhoneOS.iPhone_MusicData.isPaused = false
        else 
            iPhoneOS.iPhone_YouTubePlayer:RunJavascript("cmdPause();")
            iPhoneOS.iPhone_MusicData.isPaused = true 
        end
    end
end

-- Themes и GetTheme определены в sh_config.lua

surface.CreateFont("iOS_Time", { font = "Roboto", size = 16, weight = 600, antialias = true })
surface.CreateFont("iOS_Title", { font = "Roboto", size = 28, weight = 600, antialias = true })
surface.CreateFont("iOS_AppTitle", { font = "Roboto", size = 18, weight = 600, antialias = true })
surface.CreateFont("iOS_IconList", { font = "Roboto", size = 14, weight = 600, antialias = true })
surface.CreateFont("iOS_DialerNum", { font = "Roboto", size = 48, weight = 300, antialias = true })
surface.CreateFont("iOS_Text", { font = "Roboto", size = 16, weight = 400, antialias = true })
surface.CreateFont("iOS_Note", { font = "Roboto", size = 15, weight = 400, antialias = true })
surface.CreateFont("iOS_CallName", { font = "Roboto", size = 32, weight = 400, antialias = true })
surface.CreateFont("iOS_BigIcon", { font = "Roboto", size = 38, weight = 600, antialias = true })

iPhoneOS.PhoneScreen = nil
iPhoneOS.CurrentApp = nil
iPhoneOS.ActiveNotif = nil
iPhoneOS.PhoneBG = nil
iPhoneOS.CCPanel = nil
iPhoneOS.NCPanel = nil
iPhoneOS.isCCOpen = false
iPhoneOS.isNCOpen = false

-- ВАЖНО: Предварительное объявление локальных функций, чтобы они "видели" друг друга!
iPhoneOS.OpeniPhone = nil
iPhoneOS.LaunchApp = nil
iPhoneOS.ToggleControlCenter = nil
iPhoneOS.ToggleNotifCenter = nil
function iPhoneOS.PlayUISound(sndKey) 
    if iPhoneOS.PhoneData.Sounds and iPhoneOS.PhoneSounds[sndKey] then 
        surface.PlaySound(iPhoneOS.PhoneSounds[sndKey]) 
    end 
end

function iPhoneOS.StopCallSounds() 
    timer.Remove("iPhone_Ringtone")
    timer.Remove("iPhone_Dialtone")
    if IsValid(LocalPlayer()) then 
        LocalPlayer():StopSound(iPhoneOS.PhoneSounds.Ringtone)
        LocalPlayer():StopSound(iPhoneOS.PhoneSounds.DialTone) 
    end 
end

function iPhoneOS.DrawRounded(radius, x, y, w, h, col) 
    draw.RoundedBox(radius, x, y, w, h, col) 
end

function iPhoneOS.StyleScrollbar(scroll, theme) 
    local sbar = scroll:GetVBar()
    sbar:SetHideButtons(true)
    sbar.Paint = function() end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    sbar.btnGrip.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(3, w/2 - 2, 0, 4, h, ColorAlpha(theme.subText, 100)) 
    end 
end

function iPhoneOS.AddNotification(title, text, color, appID)
    table.insert(iPhoneOS.PhoneData.Notifications, 1, { title = title, text = text, color = color, time = os.time(), app = appID })
    if #iPhoneOS.PhoneData.Notifications > 30 then 
        table.remove(iPhoneOS.PhoneData.Notifications) 
    end
    iPhoneOS.SavePhoneData()
end

function iPhoneOS.ShowPhoneNotification(title, text, customColor, targetApp)
    iPhoneOS.AddNotification(title, text, customColor, targetApp)
    if iPhoneOS.PhoneData.AirplaneMode then return end
    if IsValid(iPhoneOS.ActiveNotif) then iPhoneOS.ActiveNotif:Remove() end
    
    iPhoneOS.PlayUISound("Notification")
    local theme = iPhoneOS.GetTheme()
    local dotColor = customColor or theme.accent
    
    iPhoneOS.ActiveNotif = vgui.Create("DButton")
    iPhoneOS.ActiveNotif:SetText("")
    iPhoneOS.ActiveNotif:SetSize(320, 65)
    iPhoneOS.ActiveNotif:SetPos(ScrW()/2 - 160, -80)
    iPhoneOS.ActiveNotif:MoveTo(ScrW()/2 - 160, 40, 0.5, 0, 0.2)
    iPhoneOS.ActiveNotif.Paint = function(self, w, h)
        iPhoneOS.DrawRounded(32, 0, 0, w, h, ColorAlpha(theme.bg2, 245))
        iPhoneOS.DrawRounded(8, 20, h/2 - 8, 16, 16, dotColor)
        draw.SimpleText(title, "iOS_AppTitle", 45, 12, theme.text, TEXT_ALIGN_LEFT)
        draw.SimpleText(text, "iOS_Text", 45, 32, theme.subText, TEXT_ALIGN_LEFT)
    end
    iPhoneOS.ActiveNotif.DoClick = function() 
        if targetApp then 
            if not IsValid(_G.iPhoneFrame_Global) then 
                iPhoneOS.OpeniPhone(targetApp) 
            else 
                iPhoneOS.LaunchApp(targetApp) 
            end 
        end
        if IsValid(iPhoneOS.ActiveNotif) then iPhoneOS.ActiveNotif:Remove() end 
    end
    timer.Simple(3.5, function() 
        if IsValid(iPhoneOS.ActiveNotif) then iPhoneOS.ActiveNotif:Remove() end 
    end)
end

-- Реализация вызовов шторки
iPhoneOS.ToggleControlCenter = function()
    if iPhoneOS.isNCOpen then iPhoneOS.ToggleNotifCenter() end
    iPhoneOS.isCCOpen = not iPhoneOS.isCCOpen
    if IsValid(iPhoneOS.CCPanel) then 
        iPhoneOS.CCPanel:MoveTo(iPhoneOS.Config.SCREEN_PADDING, iPhoneOS.isCCOpen and iPhoneOS.Config.SCREEN_PADDING or -iPhoneOS.Config.SCREEN_H, 0.3, 0, 0.5) 
    end
end

iPhoneOS.ToggleNotifCenter = function()
    if iPhoneOS.isCCOpen then iPhoneOS.ToggleControlCenter() end
    iPhoneOS.isNCOpen = not iPhoneOS.isNCOpen
    if IsValid(iPhoneOS.NCPanel) then 
        iPhoneOS.NCPanel:MoveTo(iPhoneOS.Config.SCREEN_PADDING, iPhoneOS.isNCOpen and iPhoneOS.Config.SCREEN_PADDING or -iPhoneOS.Config.SCREEN_H, 0.3, 0, 0.5)
        if iPhoneOS.isNCOpen and iPhoneOS.NCPanel.Refresh then iPhoneOS.NCPanel.Refresh() end 
    end
end

iPhoneOS.OpeniPhone = function(startApp)
    if IsValid(_G.iPhoneFrame_Global) then
        if not startApp then
            if (iPhoneOS.NextToggleTime or 0) > CurTime() then return end
            iPhoneOS.NextToggleTime = CurTime() + 2

            _G.iPhoneFrame_Global:MoveTo(ScrW() - iPhoneOS.Config.PHONE_WIDTH - 30, ScrH() + 50, 0.4, 0, 0.5, function() 
                if IsValid(_G.iPhoneFrame_Global) then _G.iPhoneFrame_Global:Remove() end 
            end)
            if IsValid(iPhoneOS.PhoneBG) then iPhoneOS.PhoneBG:Remove() end
            gui.EnableScreenClicker(false)
            iPhoneOS.isCCOpen = false
            iPhoneOS.isNCOpen = false
        else 
            iPhoneOS.LaunchApp(startApp) 
        end
        return
    end

    if (iPhoneOS.NextToggleTime or 0) > CurTime() then return end
    iPhoneOS.NextToggleTime = CurTime() + 1.0

    gui.EnableScreenClicker(true)
    
    net.Start("iPhone_StateChange")
    net.WriteBool(true)
    net.SendToServer()
    
    iPhoneOS.PhoneBG = vgui.Create("DButton")
    iPhoneOS.PhoneBG:SetSize(ScrW(), ScrH())
    iPhoneOS.PhoneBG:SetText("")
    iPhoneOS.PhoneBG.Paint = function() end
    iPhoneOS.PhoneBG.DoClick = function() iPhoneOS.OpeniPhone() end

    local PhoneFrame = vgui.Create("DFrame")
    _G.iPhoneFrame_Global = PhoneFrame
    function PhoneFrame:OnRemove()
        net.Start("iPhone_StateChange")
        net.WriteBool(false)
        net.SendToServer()
    end
    PhoneFrame:SetSize(iPhoneOS.Config.PHONE_WIDTH, iPhoneOS.Config.PHONE_HEIGHT)
    PhoneFrame:SetTitle("")
    PhoneFrame:ShowCloseButton(false)
    PhoneFrame:SetDraggable(false)
    PhoneFrame:MakePopup()
    PhoneFrame:SetKeyboardInputEnabled(false)
    PhoneFrame:SetPos(ScrW() - iPhoneOS.Config.PHONE_WIDTH - 30, ScrH() + 50)
    PhoneFrame:MoveTo(ScrW() - iPhoneOS.Config.PHONE_WIDTH - 30, ScrH() - iPhoneOS.Config.PHONE_HEIGHT - 30, 0.5, 0, 0.2)
    PhoneFrame.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(42, 0, 0, w, h, Color(160, 160, 165))
        iPhoneOS.DrawRounded(38, 2, 2, w-4, h-4, Color(10, 10, 10)) 
    end

    local powerBtn = vgui.Create("DButton", PhoneFrame)
    powerBtn:SetSize(4, 50)
    powerBtn:SetPos(iPhoneOS.Config.PHONE_WIDTH - 4, 120)
    powerBtn:SetText("")
    powerBtn.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(2, 0, 0, w, h, self:IsHovered() and Color(231, 76, 60) or Color(40, 40, 40)) 
    end
    powerBtn.DoClick = function() iPhoneOS.OpeniPhone() end

    local silentSwitch = vgui.Create("DButton", PhoneFrame)
    silentSwitch:SetSize(4, 20)
    silentSwitch:SetPos(0, 65)
    silentSwitch:SetText("")
    silentSwitch.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(2, 0, 0, w, h, iPhoneOS.PhoneData.Sounds and Color(40, 40, 40) or Color(231, 76, 60)) 
    end
    silentSwitch.DoClick = function() 
        iPhoneOS.PhoneData.Sounds = not iPhoneOS.PhoneData.Sounds
        iPhoneOS.SavePhoneData()
        if iPhoneOS.PhoneData.Sounds then 
            iPhoneOS.PlayUISound("Click")
            iPhoneOS.ShowPhoneNotification("Режим звука", "Звонок включен", Color(52, 199, 89), "settings") 
        else 
            iPhoneOS.StopCallSounds()
            iPhoneOS.ShowPhoneNotification("Режим звука", "Беззвучный режим", Color(231, 76, 60), "settings") 
        end 
    end

    local volUp = vgui.Create("DPanel", PhoneFrame)
    volUp:SetSize(4, 35)
    volUp:SetPos(0, 100)
    volUp.Paint = function(self, w, h) iPhoneOS.DrawRounded(2, 0, 0, w, h, Color(40, 40, 40)) end
    
    local volDown = vgui.Create("DPanel", PhoneFrame)
    volDown:SetSize(4, 35)
    volDown:SetPos(0, 145)
    volDown.Paint = function(self, w, h) iPhoneOS.DrawRounded(2, 0, 0, w, h, Color(40, 40, 40)) end

    iPhoneOS.PhoneScreen = vgui.Create("DPanel", PhoneFrame)
    iPhoneOS.PhoneScreen:SetPos(iPhoneOS.Config.SCREEN_PADDING, iPhoneOS.Config.SCREEN_PADDING)
    iPhoneOS.PhoneScreen:SetSize(iPhoneOS.Config.SCREEN_W, iPhoneOS.Config.SCREEN_H)
    iPhoneOS.PhoneScreen.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(32, 0, 0, w, h, iPhoneOS.GetTheme().bg) 
        local wallpaper = iPhoneOS.GetCustomImage("wallpaper")
        if wallpaper then 
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(wallpaper)
            surface.DrawTexturedRect(0, 0, w, h) 
        end
    end

    local brightnessOverlay = vgui.Create("DPanel", PhoneFrame)
    brightnessOverlay:SetPos(iPhoneOS.Config.SCREEN_PADDING, iPhoneOS.Config.SCREEN_PADDING)
    brightnessOverlay:SetSize(iPhoneOS.Config.SCREEN_W, iPhoneOS.Config.SCREEN_H)
    brightnessOverlay:SetMouseInputEnabled(false)
    brightnessOverlay.Paint = function(self, w, h) 
        if iPhoneOS.PhoneData.Brightness < 1 then 
            iPhoneOS.DrawRounded(32, 0, 0, w, h, Color(0, 0, 0, 255 * (1 - iPhoneOS.PhoneData.Brightness))) 
        end 
    end

    -- ШТОРКА (Центр управления)
    iPhoneOS.CCPanel = vgui.Create("DPanel", PhoneFrame)
    iPhoneOS.CCPanel:SetPos(iPhoneOS.Config.SCREEN_PADDING, -iPhoneOS.Config.SCREEN_H)
    iPhoneOS.CCPanel:SetSize(iPhoneOS.Config.SCREEN_W, iPhoneOS.Config.SCREEN_H)
    iPhoneOS.CCPanel.Paint = function(self, w, h)
        render.ClearStencil()
        render.SetStencilEnable(true)
        render.SetStencilReferenceValue(1)
        render.SetStencilCompareFunction(STENCIL_NEVER)
        render.SetStencilFailOperation(STENCIL_REPLACE)
        iPhoneOS.DrawRounded(32, 0, 0, w, h, color_white)
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        iPhoneOS.DrawRounded(32, 0, 0, w, h, Color(20, 20, 25, 230))
    end
    iPhoneOS.CCPanel.PaintOver = function() render.SetStencilEnable(false) end
    
    local netBlock = vgui.Create("DPanel", iPhoneOS.CCPanel)
    netBlock:SetPos(20, 50)
    netBlock:SetSize(iPhoneOS.Config.SCREEN_W/2 - 30, 120)
    netBlock.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(20, 0, 0, w, h, Color(40, 40, 45, 200)) 
    end
    
    local btnAir = vgui.Create("DButton", netBlock)
    btnAir:SetPos(15, 15)
    btnAir:SetSize(40, 40)
    btnAir:SetText("")
    btnAir.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(w/2, 0, 0, w, h, iPhoneOS.PhoneData.AirplaneMode and Color(255, 150, 0) or Color(80, 80, 85))
        surface.SetDrawColor(color_white)
        surface.DrawPoly({{x=w/2, y=h/2-8}, {x=w/2-10, y=h/2+8}, {x=w/2+10, y=h/2+8}}) 
    end
    btnAir.DoClick = function() 
        iPhoneOS.PlayUISound("Click")
        iPhoneOS.PhoneData.AirplaneMode = not iPhoneOS.PhoneData.AirplaneMode
        iPhoneOS.SavePhoneData() 
    end
    
    local btnWifi = vgui.Create("DButton", netBlock)
    btnWifi:SetPos(65, 15)
    btnWifi:SetSize(40, 40)
    btnWifi:SetText("")
    btnWifi.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(w/2, 0, 0, w, h, iPhoneOS.PhoneData.Wifi and Color(10, 132, 255) or Color(80, 80, 85))
        draw.SimpleText("W", "iOS_AppTitle", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
    end
    btnWifi.DoClick = function() 
        iPhoneOS.PlayUISound("Click")
        iPhoneOS.PhoneData.Wifi = not iPhoneOS.PhoneData.Wifi
        iPhoneOS.SavePhoneData() 
    end

    local mediaBlock = vgui.Create("DPanel", iPhoneOS.CCPanel)
    mediaBlock:SetPos(iPhoneOS.Config.SCREEN_W/2 + 10, 50)
    mediaBlock:SetSize(iPhoneOS.Config.SCREEN_W/2 - 30, 120)
    mediaBlock.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(20, 0, 0, w, h, Color(40, 40, 45, 200))
        draw.SimpleText(iPhoneOS.iPhone_MusicData.active and iPhoneOS.SafeSub(iPhoneOS.iPhone_MusicData.title, 12) or "Не играет", "iOS_Text", w/2, 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
    end
    
    local btnCCPlay = vgui.Create("DButton", mediaBlock)
    btnCCPlay:SetPos(mediaBlock:GetWide()/2 - 25, 55)
    btnCCPlay:SetSize(50, 50)
    btnCCPlay:SetText("")
    btnCCPlay.Paint = function(self, w, h)
        iPhoneOS.DrawRounded(w/2, 0, 0, w, h, self:IsHovered() and Color(60,60,65) or Color(80,80,85))
        surface.SetDrawColor(color_white)
        if iPhoneOS.iPhone_MusicData.active and not iPhoneOS.iPhone_MusicData.isPaused then 
            surface.DrawRect(w/2 - 6, h/2 - 8, 4, 16)
            surface.DrawRect(w/2 + 2, h/2 - 8, 4, 16) 
        else 
            surface.DrawPoly({{x=w/2-4, y=h/2-8}, {x=w/2+8, y=h/2}, {x=w/2-4, y=h/2+8}}) 
        end
    end
    btnCCPlay.DoClick = function() 
        iPhoneOS.PlayUISound("Click")
        iPhoneOS.TogglePause() 
    end

    local brightBlock = vgui.Create("DPanel", iPhoneOS.CCPanel)
    brightBlock:SetPos(20, 190)
    brightBlock:SetSize(iPhoneOS.Config.SCREEN_W - 40, 50)
    brightBlock.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(16, 0, 0, w, h, Color(40, 40, 45, 200))
        iPhoneOS.DrawRounded(10, 15, h/2 - 10, 20, 20, color_white) 
    end
    
    local brightSlider = vgui.Create("DSlider", brightBlock)
    brightSlider:SetPos(50, 0)
    brightSlider:SetSize(iPhoneOS.Config.SCREEN_W - 100, 50)
    brightSlider:SetSlideX(iPhoneOS.PhoneData.Brightness)
    brightSlider.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(6, 0, h/2 - 6, w, 12, Color(20, 20, 25))
        iPhoneOS.DrawRounded(6, 0, h/2 - 6, w * self:GetSlideX(), 12, color_white) 
    end
    brightSlider.Knob.Paint = function() end
    brightSlider.OnValueChanged = function(self, val) 
        iPhoneOS.PhoneData.Brightness = val
        iPhoneOS.SavePhoneData() 
    end

    local funcBlock = vgui.Create("DPanel", iPhoneOS.CCPanel)
    funcBlock:SetPos(20, 260)
    funcBlock:SetSize(iPhoneOS.Config.SCREEN_W - 40, 70)
    funcBlock.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(16, 0, 0, w, h, Color(40, 40, 45, 200)) 
    end
    
    local btnFlash = vgui.Create("DButton", funcBlock)
    btnFlash:SetPos(15, 10)
    btnFlash:SetSize(50, 50)
    btnFlash:SetText("")
    btnFlash.Paint = function(self, w, h)
        local isOn = LocalPlayer():FlashlightIsOn()
        iPhoneOS.DrawRounded(12, 0, 0, w, h, isOn and Color(255, 255, 255) or Color(80, 80, 85))
        surface.SetDrawColor(isOn and Color(0,0,0) or color_white)
        surface.DrawRect(w/2-4, h/2-10, 8, 14)
        surface.DrawRect(w/2-6, h/2+4, 12, 6)
    end
    btnFlash.DoClick = function() 
        iPhoneOS.PlayUISound("Click")
        RunConsoleCommand("impulse", "100") 
    end

    local btnCloseCC = vgui.Create("DButton", iPhoneOS.CCPanel)
    btnCloseCC:SetPos(0, iPhoneOS.Config.SCREEN_H - 100)
    btnCloseCC:SetSize(iPhoneOS.Config.SCREEN_W, 100)
    btnCloseCC:SetText("")
    btnCloseCC.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(3, w/2 - 60, h - 20, 120, 5, Color(255,255,255, 200)) 
    end
    btnCloseCC.DoClick = function() iPhoneOS.ToggleControlCenter() end

    -- ЦЕНТР УВЕДОМЛЕНИЙ
    iPhoneOS.NCPanel = vgui.Create("DPanel", PhoneFrame)
    iPhoneOS.NCPanel:SetPos(iPhoneOS.Config.SCREEN_PADDING, -iPhoneOS.Config.SCREEN_H)
    iPhoneOS.NCPanel:SetSize(iPhoneOS.Config.SCREEN_W, iPhoneOS.Config.SCREEN_H)
    iPhoneOS.NCPanel.Paint = function(self, w, h)
        render.ClearStencil()
        render.SetStencilEnable(true)
        render.SetStencilReferenceValue(1)
        render.SetStencilCompareFunction(STENCIL_NEVER)
        render.SetStencilFailOperation(STENCIL_REPLACE)
        iPhoneOS.DrawRounded(32, 0, 0, w, h, color_white)
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        iPhoneOS.DrawRounded(32, 0, 0, w, h, Color(20, 20, 25, 240))
        draw.SimpleText("Уведомления", "iOS_Title", 20, 50, color_white, TEXT_ALIGN_LEFT)
    end
    iPhoneOS.NCPanel.PaintOver = function() render.SetStencilEnable(false) end
    
    local ncScroll = vgui.Create("DScrollPanel", iPhoneOS.NCPanel)
    ncScroll:SetPos(0, 90)
    ncScroll:SetSize(iPhoneOS.Config.SCREEN_W, iPhoneOS.Config.SCREEN_H - 150)
    iPhoneOS.StyleScrollbar(ncScroll, iPhoneOS.GetTheme())
    
    iPhoneOS.NCPanel.Refresh = function()
        ncScroll:Clear()
        if #iPhoneOS.PhoneData.Notifications == 0 then
            local l = ncScroll:Add("DLabel")
            l:Dock(TOP)
            l:SetTall(60)
            l:SetText("Нет новых уведомлений")
            l:SetFont("iOS_Text")
            l:SetTextColor(Color(150,150,150))
            l:SetContentAlignment(5)
        else
            for _, notif in ipairs(iPhoneOS.PhoneData.Notifications) do
                local p = ncScroll:Add("DButton")
                p:Dock(TOP)
                p:DockMargin(15, 0, 15, 10)
                p:SetTall(70)
                p:SetText("")
                p.Paint = function(self, w, h)
                    iPhoneOS.DrawRounded(16, 0, 0, w, h, Color(40, 40, 45))
                    iPhoneOS.DrawRounded(6, 15, 15, 12, 12, notif.color or Color(100,100,100))
                    draw.SimpleText(notif.title, "iOS_AppTitle", 35, 12, color_white, TEXT_ALIGN_LEFT)
                    draw.SimpleText(iPhoneOS.SafeSub(notif.text, 30), "iOS_Text", 15, 40, Color(180,180,185), TEXT_ALIGN_LEFT)
                end
                p.DoClick = function() 
                    if notif.app then 
                        iPhoneOS.ToggleNotifCenter()
                        iPhoneOS.LaunchApp(notif.app) 
                    end 
                end
            end
        end
    end
    
    local btnCloseNC = vgui.Create("DButton", iPhoneOS.NCPanel)
    btnCloseNC:SetPos(0, iPhoneOS.Config.SCREEN_H - 60)
    btnCloseNC:SetSize(iPhoneOS.Config.SCREEN_W, 60)
    btnCloseNC:SetText("")
    btnCloseNC.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(3, w/2 - 60, h - 20, 120, 5, Color(255,255,255, 200)) 
    end
    btnCloseNC.DoClick = function() iPhoneOS.ToggleNotifCenter() end

    -- ВЕРХНЯЯ ПАНЕЛЬ (Notch)
    local notchOverlay = vgui.Create("DPanel", PhoneFrame)
    notchOverlay:SetPos(iPhoneOS.Config.SCREEN_PADDING, iPhoneOS.Config.SCREEN_PADDING)
    notchOverlay:SetSize(iPhoneOS.Config.SCREEN_W, 35)
    notchOverlay.Paint = function(self, w, h)
        iPhoneOS.DrawRounded(14, w/2 - 50, 5, 100, 24, Color(0, 0, 0))
        local topColor = iPhoneOS.isCCOpen and color_white or (iPhoneOS.isNCOpen and color_white or iPhoneOS.GetTheme().text)
        draw.SimpleText(os.date("%H:%M"), "iOS_Time", 25, 8, topColor, TEXT_ALIGN_LEFT)
        if iPhoneOS.CallData.state == "active" then 
            draw.SimpleText("ВЫЗОВ", "iOS_Time", w - 25, 8, Color(46, 204, 113), TEXT_ALIGN_RIGHT)
        elseif iPhoneOS.PhoneData.AirplaneMode then 
            surface.SetDrawColor(topColor)
            surface.DrawPoly({{x=w-35, y=8}, {x=w-40, y=20}, {x=w-25, y=20}})
        else 
            draw.SimpleText(iPhoneOS.PhoneData.Wifi and "Wi-Fi" or "LTE", "iOS_Time", w - 25, 8, topColor, TEXT_ALIGN_RIGHT) 
        end
    end
    
    local btnNotchLeft = vgui.Create("DButton", notchOverlay)
    btnNotchLeft:SetPos(0,0)
    btnNotchLeft:SetSize(iPhoneOS.Config.SCREEN_W/2 - 50, 35)
    btnNotchLeft:SetText("")
    btnNotchLeft.Paint = function() end
    btnNotchLeft.DoClick = function() iPhoneOS.ToggleNotifCenter() end
    
    local btnNotchRight = vgui.Create("DButton", notchOverlay)
    btnNotchRight:SetPos(iPhoneOS.Config.SCREEN_W/2 + 50, 0)
    btnNotchRight:SetSize(iPhoneOS.Config.SCREEN_W/2 - 50, 35)
    btnNotchRight:SetText("")
    btnNotchRight.Paint = function() end
    btnNotchRight.DoClick = function() iPhoneOS.ToggleControlCenter() end

    local homeOverlay = vgui.Create("DPanel", PhoneFrame)
    homeOverlay:SetPos(iPhoneOS.Config.SCREEN_PADDING, iPhoneOS.Config.PHONE_HEIGHT - iPhoneOS.Config.SCREEN_PADDING - 20)
    homeOverlay:SetSize(iPhoneOS.Config.SCREEN_W, 20)
    homeOverlay.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(3, w/2 - 60, h - 8, 120, 5, ColorAlpha(iPhoneOS.GetTheme().text, 200)) 
    end
    
    local homeBtn = vgui.Create("DButton", homeOverlay)
    homeBtn:Dock(FILL)
    homeBtn:SetText("")
    homeBtn.Paint = function() end
    homeBtn.DoClick = function() iPhoneOS.LaunchApp("home") end

    if iPhoneOS.CallData.state ~= "none" then iPhoneOS.LaunchApp("call_screen") else iPhoneOS.LaunchApp(startApp or "home") end
end


-- === ИКОНКИ ===
iPhoneOS.AppIconsCache = {}
function iPhoneOS.DrawAppIcon(id, w, h, theme, isHovered)
    -- 1. Сначала пробуем загрузить иконку из контента вашего аддона (materials/iphone_icons/...png)
    if iPhoneOS.AppIconsCache[id] == nil then
        local matPath = "iphone_icons/" .. id .. ".png"
        if file.Exists("materials/" .. matPath, "GAME") then
            iPhoneOS.AppIconsCache[id] = Material(matPath, "noclamp smooth")
        else
            iPhoneOS.AppIconsCache[id] = false
        end
    end

    -- Если материал существует, отрисовываем его
    if iPhoneOS.AppIconsCache[id] then
        surface.SetDrawColor(255, 255, 255, isHovered and 200 or 255)
        surface.SetMaterial(iPhoneOS.AppIconsCache[id])
        surface.DrawTexturedRect(0, 0, w, h)
        return
    end

    -- 2. Запасной вариант (векторные иконки, если файла нет)
    local bgCol = theme.accent
    if isHovered then bgCol = Color(math.max(bgCol.r * 0.8, 0), math.max(bgCol.g * 0.8, 0), math.max(bgCol.b * 0.8, 0)) end
    
    if id == "contacts" then
        iPhoneOS.DrawRounded(12, w/2 - 12, h/2 - 16, 24, 24, theme.bg)
        iPhoneOS.DrawRounded(16, w/2 - 20, h/2 + 10, 40, 20, theme.bg)
    elseif id == "sms" then
        iPhoneOS.DrawRounded(14, w/2 - 18, h/2 - 14, 36, 28, theme.bg)
        surface.SetDrawColor(theme.bg)
        surface.DrawPoly({{x=w/2-10, y=h/2+10}, {x=w/2-18, y=h/2+20}, {x=w/2-2, y=h/2+14}})
    elseif id == "settings" then
        iPhoneOS.DrawRounded(8, w/2 - 12, h/2 - 12, 24, 24, theme.bg)
        iPhoneOS.DrawRounded(4, w/2 - 15, h/2 - 5, 30, 10, theme.bg)
        iPhoneOS.DrawRounded(4, w/2 - 5, h/2 - 15, 10, 30, theme.bg)
        surface.SetDrawColor(theme.bg)
        surface.DrawPoly({{x = w/2 - 7, y = h/2 - 14}, {x = w/2 + 14, y = h/2 + 7}, {x = w/2 + 7, y = h/2 + 14}, {x = w/2 - 14, y = h/2 - 7}})
        surface.DrawPoly({{x = w/2 + 7, y = h/2 - 14}, {x = w/2 + 14, y = h/2 - 7}, {x = w/2 - 7, y = h/2 + 14}, {x = w/2 - 14, y = h/2 + 7}})
        iPhoneOS.DrawRounded(7, w/2-7, h/2-7, 14, 14, bgCol)
    elseif id == "calc" then
        draw.SimpleText("=", "iOS_Title", w/2, h/2, theme.bg, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif id == "notes" then
        iPhoneOS.DrawRounded(2, w/2 - 14, h/2 - 10, 28, 4, theme.bg)
        iPhoneOS.DrawRounded(2, w/2 - 14, h/2, 28, 4, theme.bg)
        iPhoneOS.DrawRounded(2, w/2 - 14, h/2 + 10, 20, 4, theme.bg)
    elseif id == "paint" then
        iPhoneOS.DrawRounded(14, w/2 - 16, h/2 - 16, 32, 32, theme.bg)
        iPhoneOS.DrawRounded(6, w/2 - 10, h/2 - 10, 12, 12, theme.accent)
        iPhoneOS.DrawRounded(4, w/2 + 4, h/2 + 4, 8, 8, theme.accent)
    elseif id == "snake" then
        iPhoneOS.DrawRounded(4, w/2 - 14, h/2 + 2, 28, 8, theme.bg)
        iPhoneOS.DrawRounded(4, w/2 - 14, h/2 - 14, 8, 24, theme.bg)
        iPhoneOS.DrawRounded(4, w/2 - 14, h/2 - 14, 20, 8, theme.bg)
        iPhoneOS.DrawRounded(2, w/2 - 2, h/2 - 12, 4, 4, theme.accent)
    elseif id == "music" then
        iPhoneOS.DrawRounded(12, w/2 - 16, h/2 - 16, 32, 32, theme.bg)
        iPhoneOS.DrawRounded(4, w/2 - 8, h/2 - 4, 8, 10, theme.accent)
        iPhoneOS.DrawRounded(4, w/2 + 2, h/2 - 8, 8, 10, theme.accent)
        iPhoneOS.DrawRounded(2, w/2 - 5, h/2 - 12, 12, 4, theme.accent)
    elseif id == "call_screen" then
        iPhoneOS.DrawRounded(6, w/2 - 10, h/2 - 12, 20, 24, color_white)
        iPhoneOS.DrawRounded(2, w/2 - 8, h/2 - 9, 16, 14, theme.accent)
        iPhoneOS.DrawRounded(2, w/2 - 4, h/2 + 7, 8, 3, theme.accent)
elseif id == "bank" then
        iPhoneOS.DrawRounded(14, w/2 - 14, h/2 - 14, 28, 28, theme.bg)
        draw.SimpleText("$", "iOS_Title", w/2, h/2, bgCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif id == "files" then
        iPhoneOS.DrawRounded(14, w/2 - 16, h/2 - 16, 32, 32, theme.bg)
        iPhoneOS.DrawRounded(4, w/2 - 10, h/2 - 4, 20, 16, color_white)
        iPhoneOS.DrawRounded(3, w/2 - 10, h/2 - 10, 10, 8, color_white)
    end
end

-- === ЗАПУСК ПРИЛОЖЕНИЙ ===
iPhoneOS.LaunchApp = function(appID)
    if IsValid(iPhoneOS.CurrentApp) then
        if _G.iPhoneFrame_Global then 
            _G.iPhoneFrame_Global.RefreshSMS = nil 
        end 
        iPhoneOS.CurrentApp:AlphaTo(0, 0.15, 0, function() 
            if IsValid(iPhoneOS.CurrentApp) then iPhoneOS.CurrentApp:Remove() end 
            iPhoneOS.LaunchApp(appID) 
        end)
        return
    end

    iPhoneOS.CurrentApp = vgui.Create("DPanel", iPhoneOS.PhoneScreen)
    iPhoneOS.CurrentApp.appID = appID
    iPhoneOS.CurrentApp:SetSize(iPhoneOS.Config.SCREEN_W, iPhoneOS.Config.SCREEN_H)
    iPhoneOS.CurrentApp:SetAlpha(0)
    iPhoneOS.CurrentApp:AlphaTo(255, 0.2, 0)
    iPhoneOS.CurrentApp.Paint = function(self, w, h)
        render.ClearStencil()
        render.SetStencilEnable(true)
        render.SetStencilReferenceValue(1)
        render.SetStencilCompareFunction(STENCIL_NEVER)
        render.SetStencilFailOperation(STENCIL_REPLACE)
        iPhoneOS.DrawRounded(32, 0, 0, w, h, color_white)
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        if self.bgColor then 
            iPhoneOS.DrawRounded(32, 0, 0, w, h, self.bgColor) 
        end
    end
    iPhoneOS.CurrentApp.PaintOver = function() render.SetStencilEnable(false) end

    if iPhoneOS.Apps and iPhoneOS.Apps[appID] then
        iPhoneOS.Apps[appID](appID)
    else
        if appID ~= "home" then
            iPhoneOS.LaunchApp("home")
        end
    end
end

concommand.Remove("open_phone", function() iPhoneOS.OpeniPhone() end)

-- Разрешаем двигать камерой при зажатии ПКМ (а для голосового чата игроку достаточно просто нажать свою кнопку бинда)
local isLooking = false
local restoreX, restoreY = ScrW() / 2, ScrH() / 2
hook.Add("Think", "iPhone_LookAround", function()
    if not IsValid(_G.iPhoneFrame_Global) then
        if isLooking then
            isLooking = false
            gui.EnableScreenClicker(false)
        end
        return 
    end

    if input.IsMouseDown(MOUSE_RIGHT) then
        if not isLooking then
            isLooking = true
            restoreX, restoreY = input.GetCursorPos()
            gui.EnableScreenClicker(false)
            _G.iPhoneFrame_Global:SetMouseInputEnabled(false)
        end
    else
        if isLooking then
            isLooking = false
            gui.EnableScreenClicker(true)
            _G.iPhoneFrame_Global:SetMouseInputEnabled(true)
            input.SetCursorPos(restoreX, restoreY)
        end
    end
end)

-- Блокируем движения (бинды), когда игрок пишет сообщение
hook.Add("PlayerBindPress", "iPhone_BlockBinds", function(ply, bind, pressed)
    if not IsValid(_G.iPhoneFrame_Global) then return end
    
    local focus = vgui.GetKeyboardFocus()
    local isTyping = IsValid(focus) and (focus:GetClassName() == "TextEntry" or focus:GetClassName() == "DTextEntry")
    
    if isTyping then
        return true
    end
end)

concommand.Add("iphone_open", function()
    iPhoneOS.OpeniPhone()
end)