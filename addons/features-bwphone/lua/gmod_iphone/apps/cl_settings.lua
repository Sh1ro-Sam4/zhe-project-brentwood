if not CLIENT then return end
iPhoneOS = iPhoneOS or {}
iPhoneOS.Apps = iPhoneOS.Apps or {}

iPhoneOS.Apps["settings"] = function(appID)
    local theme = iPhoneOS.GetTheme()
        -- === НАСТРОЙКИ ===
        iPhoneOS.CurrentApp.bgColor = theme.bg
        local header = vgui.Create("DPanel", iPhoneOS.CurrentApp)
        header:SetSize(iPhoneOS.SCREEN_W, 100)
        header.Paint = function(self, w, h) 
            iPhoneOS.DrawRounded(32, 0, 0, w, 64, theme.bg)
            iPhoneOS.DrawRounded(0, 0, 32, w, h - 32, theme.bg)
            draw.SimpleText("Настройки", "iOS_Title", 20, 50, theme.text, TEXT_ALIGN_LEFT) 
        end

        local function CreateSettingMenu(y, title, valueText, onClick)
            local btn = vgui.Create("DButton", iPhoneOS.CurrentApp)
            btn:SetPos(15, y)
            btn:SetSize(iPhoneOS.SCREEN_W - 30, 50)
            btn:SetText("")
            btn.Paint = function(self, w, h)
                iPhoneOS.DrawRounded(12, 0, 0, w, h, theme.bg2)
                if self:IsHovered() then 
                    iPhoneOS.DrawRounded(12, 0, 0, w, h, Color(0,0,0,30)) 
                end
                draw.SimpleText(title, "iOS_Text", 15, h/2, theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(valueText(), "iOS_Text", w - 15, h/2, theme.subText, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER) 
            end
            btn.DoClick = function() 
                iPhoneOS.PlayUISound("Click")
                onClick() 
            end
        end

        CreateSettingMenu(100, "Тема оформления", function() return iPhoneOS.Themes[iPhoneOS.PhoneData.ThemeIdx].name end, function() 
            iPhoneOS.PhoneData.ThemeIdx = iPhoneOS.PhoneData.ThemeIdx + 1
            if iPhoneOS.PhoneData.ThemeIdx > #iPhoneOS.Themes then iPhoneOS.PhoneData.ThemeIdx = 1 end
            iPhoneOS.SavePhoneData()
            iPhoneOS.LaunchApp("settings") 
        end)
        
        CreateSettingMenu(160, "Режим звука", function() return iPhoneOS.PhoneData.Sounds and "Включен" or "Без звука" end, function() 
            iPhoneOS.PhoneData.Sounds = not iPhoneOS.PhoneData.Sounds
            iPhoneOS.SavePhoneData()
            iPhoneOS.LaunchApp("settings") 
        end)
        
        CreateSettingMenu(220, "Очистить данные", function() return "" end, function()
            local oldTheme = iPhoneOS.PhoneData.ThemeIdx
            local oldSnd = iPhoneOS.PhoneData.Sounds
            iPhoneOS.PhoneData = { Notes = {}, ReceivedNotes = {}, Drawings = {}, Sms = {}, CustomPlaylist = {}, Notifications = {}, ThemeIdx = oldTheme, Sounds = oldSnd, SnakeHighScore = 0, Brightness = 1, AirplaneMode = false, Wifi = true }
            iPhoneOS.SavePhoneData()
            if IsValid(_G.iPhoneFrame_Global) and _G.iPhoneFrame_Global.RefreshSMS then _G.iPhoneFrame_Global.RefreshSMS() end
            iPhoneOS.ShowPhoneNotification("Система", "Данные удалены", Color(231, 76, 60), "settings")
        end)
        
        CreateSettingMenu(280, "Обновить свои иконки", function() return "" end, function() 
            iPhoneOS.CustomImagesCache = {}
            iPhoneOS.PlayUISound("Click")
            iPhoneOS.ShowPhoneNotification("Система", "Иконки обновлены", Color(46, 204, 113), "settings") 
        end)
end
