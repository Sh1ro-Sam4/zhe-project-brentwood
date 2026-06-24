if not CLIENT then return end
iPhoneOS = iPhoneOS or {}
iPhoneOS.Apps = iPhoneOS.Apps or {}

iPhoneOS.Apps["music"] = function(appID)
    local theme = iPhoneOS.GetTheme()
        -- === iMUSIC (v10.6 BASS & FFT ENABLED, CLEAN UI) ===
        iPhoneOS.CurrentApp.bgColor = theme.bg
        local header = vgui.Create("DPanel", iPhoneOS.CurrentApp)
        header:SetSize(iPhoneOS.SCREEN_W, 80)
        header.Paint = function(self, w, h) 
            iPhoneOS.DrawRounded(32, 0, 0, w, 64, theme.bg2)
            iPhoneOS.DrawRounded(0, 0, 32, w, h - 32, theme.bg2)
            draw.SimpleText("iMusic", "iOS_Title", 20, 45, theme.text, TEXT_ALIGN_LEFT)
            surface.SetDrawColor(theme.line)
            surface.DrawLine(0, 79, w, 79) 
        end

        local isDraggingSeek = false
        local seekFraction = 0
        local topArea = vgui.Create("DPanel", iPhoneOS.CurrentApp)
        topArea:SetPos(15, 95)
        topArea:SetSize(iPhoneOS.SCREEN_W - 30, 200)
        
        topArea.Paint = function(self, w, h)
            iPhoneOS.DrawRounded(16, 0, 0, w, h, theme.bg2)
            local artSize = 64
            local artX = w/2 - artSize/2
            local artY = 35 -- Опущено ниже, чтобы не накладывалось на текст "ИГРАЕТ СЕЙЧАС"
            
            if iPhoneOS.iPhone_MusicData.active then
                -- Эквалайзер (FFT)
                if IsValid(iPhoneOS.iPhone_MusicStream) and iPhoneOS.iPhone_MusicStream:GetState() == GMOD_CHANNEL_PLAYING then
                    iPhoneOS.iPhone_MusicStream:FFT(iPhoneOS.FFT_Data, FFT_2048)
                    local barWidth = 4
                    local gap = 2
                    local numBars = math.floor((w - 40) / (barWidth + gap))
                    local startX = 20
                    local baseY = 110 -- Эквалайзер теперь по бокам от пластинки
                    for i=1, numBars do 
                        local val = math.min((iPhoneOS.FFT_Data[i] or 0) * 200, 30)
                        if val > 1 then 
                            iPhoneOS.DrawRounded(2, startX + (i-1)*(barWidth+gap), baseY - val, barWidth, val, ColorAlpha(theme.accent, 150)) 
                        end 
                    end
                end

                -- Пульс
                local pulse = (iPhoneOS.iPhone_MusicData.isLive or iPhoneOS.iPhone_MusicData.startedPlaying) and math.abs(math.sin(CurTime() * 4)) * 6 or 0
                iPhoneOS.DrawRounded(12, artX - pulse/2, artY - pulse/2, artSize + pulse, artSize + pulse, ColorAlpha(theme.accent, 40))
                
                -- Виниловый диск
                iPhoneOS.DrawRounded(12, artX, artY, artSize, artSize, theme.accent)
                iPhoneOS.DrawRounded(10, w/2 - 10, artY + 22, 20, 20, theme.bg2)
                iPhoneOS.DrawRounded(3, w/2 - 3, artY + 29, 6, 6, theme.accent)

                -- Тексты с правильным позиционированием (без наслоений)
                draw.SimpleText("ИГРАЕТ СЕЙЧАС", "iOS_IconList", w/2, 15, theme.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(iPhoneOS.SafeSub(iPhoneOS.iPhone_MusicData.title, 26), "iOS_AppTitle", w/2, 120, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Прогресс бар
                local barW = w - 40
                local barX = 20
                local barY = 155
                iPhoneOS.DrawRounded(3, barX, barY, barW, 6, theme.line)

                if iPhoneOS.iPhone_MusicData.isLive then
                    iPhoneOS.DrawRounded(3, barX, barY, barW, 6, theme.accent)
                    draw.SimpleText("Прямой эфир (Радио)", "iOS_IconList", w/2, 175, theme.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    local progress = isDraggingSeek and seekFraction or math.Clamp(iPhoneOS.iPhone_MusicData.cur / math.max(iPhoneOS.iPhone_MusicData.dur, 1), 0, 1)
                    iPhoneOS.DrawRounded(3, barX, barY, barW * progress, 6, theme.accent)
                    iPhoneOS.DrawRounded(6, barX + barW * progress - 6, barY - 3, 12, 12, color_white)
                    
                    local timeToShow = isDraggingSeek and (seekFraction * iPhoneOS.iPhone_MusicData.dur) or iPhoneOS.iPhone_MusicData.cur
                    local curStr = string.format("%d:%02d", math.floor(timeToShow / 60), math.floor(timeToShow % 60))
                    local durStr = string.format("%d:%02d", math.floor(iPhoneOS.iPhone_MusicData.dur / 60), math.floor(iPhoneOS.iPhone_MusicData.dur % 60))
                    
                    draw.SimpleText(curStr, "iOS_IconList", 20, 175, theme.subText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(durStr, "iOS_IconList", w - 20, 175, theme.subText, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
            else
                iPhoneOS.DrawRounded(12, artX, artY, artSize, artSize, theme.line)
                draw.SimpleText("Плеер остановлен", "iOS_AppTitle", w/2, 120, theme.subText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                local barW = w - 40; local barX = 20; local barY = 155
                iPhoneOS.DrawRounded(3, barX, barY, barW, 6, theme.line)
                draw.SimpleText("0:00", "iOS_IconList", 20, 175, theme.subText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText("0:00", "iOS_IconList", w - 20, 175, theme.subText, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end

        local seekArea = vgui.Create("DButton", topArea)
        seekArea:SetPos(15, 145)
        seekArea:SetSize(iPhoneOS.SCREEN_W - 60, 26)
        seekArea:SetText("")
        seekArea.Paint = function() end
        seekArea.OnMousePressed = function(self, btn) 
            if btn == MOUSE_LEFT and iPhoneOS.iPhone_MusicData.active and not iPhoneOS.iPhone_MusicData.isLive then 
                isDraggingSeek = true 
            end 
        end
        seekArea.OnMouseReleased = function(self, btn) 
            if btn == MOUSE_LEFT and isDraggingSeek then 
                isDraggingSeek = false
                local x, _ = self:CursorPos()
                iPhoneOS.SeekMusic(math.Clamp(x / self:GetWide(), 0, 1)) 
            end 
        end
        seekArea.Think = function(self) 
            if isDraggingSeek then 
                if not input.IsMouseDown(MOUSE_LEFT) then 
                    isDraggingSeek = false
                    local x, _ = self:CursorPos()
                    iPhoneOS.SeekMusic(math.Clamp(x / self:GetWide(), 0, 1)) 
                end
                local x, _ = self:CursorPos()
                seekFraction = math.Clamp(x / self:GetWide(), 0, 1) 
            end 
        end

        local volDownLbl = vgui.Create("DLabel", iPhoneOS.CurrentApp)
        volDownLbl:SetPos(25, 310)
        volDownLbl:SetSize(20,20)
        volDownLbl:SetText("-")
        volDownLbl:SetFont("iOS_Title")
        volDownLbl:SetTextColor(theme.subText)
        volDownLbl:SetContentAlignment(5)
        
        local volUpLbl = vgui.Create("DLabel", iPhoneOS.CurrentApp)
        volUpLbl:SetPos(iPhoneOS.SCREEN_W - 45, 310)
        volUpLbl:SetSize(20,20)
        volUpLbl:SetText("+")
        volUpLbl:SetFont("iOS_Title")
        volUpLbl:SetTextColor(theme.subText)
        volUpLbl:SetContentAlignment(5)

        local volSlider = vgui.Create("DSlider", iPhoneOS.CurrentApp)
        volSlider:SetPos(55, 310)
        volSlider:SetSize(iPhoneOS.SCREEN_W - 110, 20)
        volSlider:SetSlideX(iPhoneOS.iPhone_MusicVolume)
        volSlider.Paint = function(self, w, h) 
            iPhoneOS.DrawRounded(4, 0, h/2 - 2, w, 4, theme.line)
            iPhoneOS.DrawRounded(4, 0, h/2 - 2, w * self:GetSlideX(), 4, theme.accent) 
        end
        volSlider.Knob.Paint = function(self, w, h) 
            iPhoneOS.DrawRounded(w/2, 0, 0, w, h, color_white)
            iPhoneOS.DrawRounded(w/2-2, 2, 2, w-4, h-4, theme.accent) 
        end
        volSlider.OnValueChanged = function(self, val) 
            iPhoneOS.iPhone_MusicVolume = val
            if IsValid(iPhoneOS.iPhone_MusicStream) then iPhoneOS.iPhone_MusicStream:SetVolume(val) end
            if IsValid(iPhoneOS.iPhone_YouTubePlayer) then iPhoneOS.iPhone_YouTubePlayer:RunJavascript("setVol(" .. math.floor(val * 100) .. ");") end 
        end

        local controlsPanel = vgui.Create("DPanel", iPhoneOS.CurrentApp)
        controlsPanel:SetPos(0, 345)
        controlsPanel:SetSize(iPhoneOS.SCREEN_W, 60)
        controlsPanel.Paint = function() end

        local txtEntry = vgui.Create("DTextEntry", iPhoneOS.CurrentApp)

        local function PlayFromURL(rawUrl)
            local url = string.Trim(rawUrl)
            if url == "" then return end
            iPhoneOS.PlayUISound("Click")
            iPhoneOS.StopMusic()
            
            local ytID = iPhoneOS.GetYouTubeID(url)
            if ytID then
                iPhoneOS.iPhone_YouTubePlayer = vgui.Create("DHTML")
                iPhoneOS.iPhone_YouTubePlayer:SetSize(100, 100)
                iPhoneOS.iPhone_YouTubePlayer:SetPos(-500, -500)
                iPhoneOS.iPhone_YouTubePlayer:SetMouseInputEnabled(false)
                iPhoneOS.iPhone_YouTubePlayer.ConsoleMessage = function() end 
                
                iPhoneOS.iPhone_YouTubePlayer:AddFunction("gmod", "updateTime", function(cur, dur, pausedStr) 
                    iPhoneOS.iPhone_MusicData.cur = tonumber(cur) or 0
                    iPhoneOS.iPhone_MusicData.dur = tonumber(dur) or 0
                    iPhoneOS.iPhone_MusicData.isLive = iPhoneOS.iPhone_MusicData.forceLive or (iPhoneOS.iPhone_MusicData.dur <= 0)
                    iPhoneOS.iPhone_MusicData.isPaused = (pausedStr == "true") 
                end)
                iPhoneOS.iPhone_YouTubePlayer:AddFunction("gmod", "onEnded", function() 
                    iPhoneOS.StopMusic()
                    iPhoneOS.ShowPhoneNotification("iMusic", "Видео завершено", theme.subText) 
                end)
                iPhoneOS.iPhone_YouTubePlayer:AddFunction("gmod", "updateTitle", function(title) 
                    if title and title ~= "" and title ~= "undefined" then iPhoneOS.iPhone_MusicData.title = title end 
                end)
                iPhoneOS.iPhone_YouTubePlayer:AddFunction("gmod", "playbackError", function() 
                    iPhoneOS.ShowPhoneNotification("Ошибка", "Блокировка YouTube", Color(231, 76, 60))
                    iPhoneOS.StopMusic() 
                end)
                iPhoneOS.iPhone_YouTubePlayer:AddFunction("gmod", "playbackStarted", function() 
                    iPhoneOS.ShowPhoneNotification("iMusic", "Играет YouTube", theme.accent, "music") 
                end)
                
                iPhoneOS.iPhone_MusicData.active = true
                iPhoneOS.iPhone_MusicData.isPaused = false
                iPhoneOS.iPhone_MusicData.title = "Загрузка YouTube..."
                iPhoneOS.iPhone_MusicData.cur = 0
                iPhoneOS.iPhone_MusicData.dur = 0
                iPhoneOS.iPhone_MusicData.isLive = false
                iPhoneOS.iPhone_MusicData.forceLive = false
                
                local html = [[
                    <!DOCTYPE html><html><body style="margin:0;padding:0;"><div id="player"></div><script>
                    var tag = document.createElement('script'); tag.src = "https://www.youtube.com/iframe_api";
                    var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
                    var player; function onYouTubeIframeAPIReady() {
                        player = new YT.Player('player', { height: '100', width: '100', videoId: ']] .. ytID .. [[', playerVars: { 'autoplay': 1, 'controls': 0 },
                            events: { 'onReady': function(event) { event.target.setVolume(]] .. math.floor(iPhoneOS.iPhone_MusicVolume * 100) .. [[); event.target.playVideo(); gmod.playbackStarted();
                                    setInterval(function(){ if(player && player.getCurrentTime) { try { var c = player.getCurrentTime() || 0; var d = player.getDuration() || 0;
                                                var state = player.getPlayerState ? player.getPlayerState() : -1; var data = player.getVideoData ? player.getVideoData() : null;
                                                var t = (data && data.title) ? data.title : "YouTube Видео"; gmod.updateTime(String(c), String(d), String(state == 2)); gmod.updateTitle(t);
                                            } catch(e) {} } }, 500); },
                                'onStateChange': function(event) { if(event.data == 0) { gmod.onEnded(); } }, 'onError': function(event) { gmod.playbackError(); } } }); }
                    function setVol(v) { if(player && player.setVolume) player.setVolume(v); } function cmdPlay() { if(player && player.playVideo) player.playVideo(); } function cmdPause() { if(player && player.pauseVideo) player.pauseVideo(); } function cmdSeek(t) { if(player && player.seekTo) player.seekTo(t, true); }
                    </script></body></html>
                ]]
                iPhoneOS.iPhone_YouTubePlayer:SetHTML(html)
            else
                local playUrl = url
                if string.find(url, "dropbox%.com") then 
                    playUrl = string.Replace(url, "dl=0", "dl=1") 
                end

                -- ИСПОЛЬЗУЕМ 3D BASS КАК В ТВОЕМ РАДИО (БЕЗ noplay ДЛЯ HITMOZ)
                sound.PlayURL(playUrl, "3d noblock", function(station, errCode, errName)
                    if IsValid(station) then
                        iPhoneOS.iPhone_MusicStream = station
                        station:SetPos(LocalPlayer():GetPos())
                        station:SetVolume(iPhoneOS.iPhone_MusicVolume)
                        station:Play()
                        
                        iPhoneOS.ShowPhoneNotification("iMusic", "Играет трек", theme.accent, "music")
                        
                        iPhoneOS.iPhone_MusicData.active = true
                        iPhoneOS.iPhone_MusicData.startedPlaying = false
                        iPhoneOS.iPhone_MusicData.isPaused = false
                        
                        local fallbackTitle = string.match(playUrl, ".+/([^/]+)%.%w+") or "Неизвестный трек"
                        fallbackTitle = string.Replace(fallbackTitle, "%20", " ")
                        iPhoneOS.iPhone_MusicData.title = fallbackTitle
                        iPhoneOS.iPhone_MusicData.forceLive = false
                        
                        for _, st in ipairs(iPhoneOS.presetRadios) do 
                            if st.url == rawUrl or st.url == playUrl then 
                                iPhoneOS.iPhone_MusicData.title = st.name
                                iPhoneOS.iPhone_MusicData.forceLive = true 
                                break 
                            end 
                        end
                        for _, st in ipairs(iPhoneOS.PhoneData.CustomPlaylist) do 
                            if st.url == rawUrl or st.url == playUrl then 
                                iPhoneOS.iPhone_MusicData.title = st.name 
                                break 
                            end 
                        end
                        
                        iPhoneOS.iPhone_MusicData.cur = 0
                        iPhoneOS.iPhone_MusicData.dur = 0
                        iPhoneOS.iPhone_MusicData.isLive = iPhoneOS.iPhone_MusicData.forceLive or station:IsBlockStreamed()
                    else
                        LocalPlayer():ChatPrint("[iMusic] Ошибка BASS: " .. tostring(errName))
                    end
                end)
            end
        end

        local playBtn = vgui.Create("DButton", controlsPanel)
        playBtn:SetPos(iPhoneOS.SCREEN_W/2 - 30, 0)
        playBtn:SetSize(60, 60)
        playBtn:SetText("")
        playBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(theme.accent.r+20, theme.accent.g+20, theme.accent.b+20) or theme.accent
            iPhoneOS.DrawRounded(w/2, 0, 0, w, h, col)
            surface.SetDrawColor(color_white)
            
            if iPhoneOS.iPhone_MusicData.active and not iPhoneOS.iPhone_MusicData.isPaused then 
                surface.DrawRect(w/2 - 6, h/2 - 8, 4, 16)
                surface.DrawRect(w/2 + 2, h/2 - 8, 4, 16) 
            else 
                surface.DrawPoly({{x=w/2-4, y=h/2-8}, {x=w/2+8, y=h/2}, {x=w/2-4, y=h/2+8}}) 
            end
        end
        playBtn.DoClick = function() 
            if iPhoneOS.iPhone_MusicData.active then 
                iPhoneOS.TogglePause() 
            else 
                PlayFromURL(txtEntry:GetValue()) 
            end 
        end

        local stopBtn = vgui.Create("DButton", controlsPanel)
        stopBtn:SetPos(iPhoneOS.SCREEN_W/2 - 80, 10)
        stopBtn:SetSize(40, 40)
        stopBtn:SetText("")
        stopBtn.Paint = function(self, w, h) 
            iPhoneOS.DrawRounded(w/2, 0, 0, w, h, theme.bg2)
            surface.SetDrawColor(self:IsHovered() and Color(255, 100, 100) or theme.text)
            surface.DrawRect(w/2-6, h/2-6, 12, 12) 
        end
        stopBtn.DoClick = function() 
            iPhoneOS.PlayUISound("Click")
            iPhoneOS.StopMusic()
            iPhoneOS.ShowPhoneNotification("iMusic", "Остановлено", theme.subText) 
        end

        local addTrackBtn = vgui.Create("DButton", controlsPanel)
        addTrackBtn:SetPos(iPhoneOS.SCREEN_W/2 + 40, 10)
        addTrackBtn:SetSize(40, 40)
        addTrackBtn:SetText("+")
        addTrackBtn:SetFont("iOS_Title")
        addTrackBtn:SetTextColor(theme.text)
        addTrackBtn.Paint = function(self, w, h) 
            iPhoneOS.DrawRounded(w/2, 0, 0, w, h, self:IsHovered() and theme.line or theme.bg2) 
        end

        txtEntry:SetPos(15, 420)
        txtEntry:SetSize(iPhoneOS.SCREEN_W - 75, 35)
        txtEntry:SetFont("iOS_Text")
        txtEntry:SetPlaceholderText("URL трека (MP3 или YouTube)...")
        txtEntry.Paint = function(self, w, h) 
            iPhoneOS.DrawRounded(12, 0, 0, w, h, theme.bg2)
            self:DrawTextEntryText(theme.text, theme.accent, theme.text) 
        end
        txtEntry.OnGetFocus = function() if IsValid(_G.iPhoneFrame_Global) then _G.iPhoneFrame_Global:SetKeyboardInputEnabled(true) end end
        txtEntry.OnLoseFocus = function() if IsValid(_G.iPhoneFrame_Global) then _G.iPhoneFrame_Global:SetKeyboardInputEnabled(false) end end

        local playUrlBtn = vgui.Create("DButton", iPhoneOS.CurrentApp)
        playUrlBtn:SetPos(iPhoneOS.SCREEN_W - 55, 420)
        playUrlBtn:SetSize(40, 35)
        playUrlBtn:SetText("")
        playUrlBtn.Paint = function(self, w, h) 
            iPhoneOS.DrawRounded(12, 0, 0, w, h, self:IsHovered() and ColorAlpha(theme.accent, 200) or theme.accent)
            surface.SetDrawColor(color_white)
            surface.DrawPoly({{x=w/2-4, y=h/2-6}, {x=w/2+6, y=h/2}, {x=w/2-4, y=h/2+6}}) 
        end
        playUrlBtn.DoClick = function() PlayFromURL(txtEntry:GetValue()) end

        local radioScroll = vgui.Create("DScrollPanel", iPhoneOS.CurrentApp)
        radioScroll:SetPos(0, 465)
        radioScroll:SetSize(iPhoneOS.SCREEN_W, iPhoneOS.SCREEN_H - 465)
        iPhoneOS.StyleScrollbar(radioScroll, theme)

        local function RefreshPlaylist()
            radioScroll:Clear()
            local lblRadio = radioScroll:Add("DLabel")
            lblRadio:Dock(TOP)
            lblRadio:DockMargin(15, 5, 15, 5)
            lblRadio:SetFont("iOS_AppTitle")
            lblRadio:SetText("Радиостанции")
            lblRadio:SetTextColor(theme.text)
            
            for _, st in ipairs(iPhoneOS.presetRadios) do
                local btn = radioScroll:Add("DButton")
                btn:Dock(TOP)
                btn:DockMargin(15, 0, 15, 8)
                btn:SetTall(50)
                btn:SetText("")
                btn.Paint = function(self, w, h)
                    iPhoneOS.DrawRounded(12, 0, 0, w, h, theme.bg2)
                    if self:IsHovered() then 
                        iPhoneOS.DrawRounded(12, 0, 0, w, h, ColorAlpha(theme.accent, 20))
                        surface.SetDrawColor(theme.accent)
                        surface.DrawPoly({{x=22, y=h/2-6}, {x=32, y=h/2}, {x=22, y=h/2+6}}) 
                    else 
                        iPhoneOS.DrawRounded(4, 20, h/2 - 6, 12, 12, theme.accent) 
                    end
                    draw.SimpleText(st.name, "iOS_Text", 45, h/2, theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
                btn.DoClick = function() 
                    txtEntry:SetValue(st.url)
                    PlayFromURL(st.url) 
                end
            end
            
            local lblMy = radioScroll:Add("DLabel")
            lblMy:Dock(TOP)
            lblMy:DockMargin(15, 10, 15, 5)
            lblMy:SetFont("iOS_AppTitle")
            lblMy:SetText("Мой плейлист")
            lblMy:SetTextColor(theme.text)

            if #iPhoneOS.PhoneData.CustomPlaylist == 0 then
                local empty = radioScroll:Add("DLabel")
                empty:Dock(TOP)
                empty:DockMargin(15, 0, 15, 0)
                empty:SetFont("iOS_Text")
                empty:SetText("Плейлист пуст. Вставьте ссылку и нажмите +")
                empty:SetTextColor(theme.subText)
            else
                for i, track in ipairs(iPhoneOS.PhoneData.CustomPlaylist) do
                    local row = radioScroll:Add("DPanel")
                    row:Dock(TOP)
                    row:DockMargin(15, 0, 15, 8)
                    row:SetTall(50)
                    row.Paint = function(self, w, h) iPhoneOS.DrawRounded(12, 0, 0, w, h, theme.bg2) end
                    
                    local btnListPlay = vgui.Create("DButton", row)
                    btnListPlay:SetPos(0, 0)
                    btnListPlay:SetSize(iPhoneOS.SCREEN_W - 75, 50)
                    btnListPlay:SetText("")
                    btnListPlay.Paint = function(self, w, h)
                        if self:IsHovered() then 
                            iPhoneOS.DrawRounded(12, 0, 0, w, h, ColorAlpha(theme.accent, 20))
                            surface.SetDrawColor(theme.accent)
                            surface.DrawPoly({{x=22, y=h/2-6}, {x=32, y=h/2}, {x=22, y=h/2+6}}) 
                        else 
                            iPhoneOS.DrawRounded(4, 20, h/2 - 6, 12, 12, theme.accent) 
                        end
                        draw.SimpleText(iPhoneOS.SafeSub(track.name, 22), "iOS_Text", 45, h/2, theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end
                    btnListPlay.DoClick = function() 
                        txtEntry:SetValue(track.url)
                        PlayFromURL(track.url) 
                    end

                    local btnDel = vgui.Create("DButton", row)
                    btnDel:SetPos(iPhoneOS.SCREEN_W - 70, 10)
                    btnDel:SetSize(30, 30)
                    btnDel:SetText("✕")
                    btnDel:SetFont("iOS_AppTitle")
                    btnDel:SetTextColor(theme.subText)
                    btnDel.Paint = function(self, w, h) 
                        if self:IsHovered() then 
                            iPhoneOS.DrawRounded(8, 0, 0, w, h, ColorAlpha(Color(231, 76, 60), 30))
                            self:SetTextColor(Color(231, 76, 60)) 
                        else 
                            self:SetTextColor(theme.subText) 
                        end 
                    end
                    btnDel.DoClick = function() 
                        table.remove(iPhoneOS.PhoneData.CustomPlaylist, i)
                        iPhoneOS.SavePhoneData()
                        RefreshPlaylist() 
                    end
                end
            end
        end

        addTrackBtn.DoClick = function()
            local url = string.Trim(txtEntry:GetValue())
            if url == "" then return end
            iPhoneOS.PlayUISound("Click")
            Derma_StringRequest("Новый трек", "Введите название для этого трека:", "Мой трек", function(text) 
                table.insert(iPhoneOS.PhoneData.CustomPlaylist, {name = text, url = url})
                iPhoneOS.SavePhoneData()
                RefreshPlaylist()
                iPhoneOS.ShowPhoneNotification("iMusic", "Трек сохранен!", theme.accent, "music") 
            end)
        end
        
        RefreshPlaylist()
end
