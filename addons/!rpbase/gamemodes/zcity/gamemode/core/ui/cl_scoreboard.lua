local s = shizlib.surface.s
local RNDX = include("shizlib/client/rndx_cl.lua")
local colors = CFG.theme
shizlib.MaxPlayers = shizlib.MaxPlayers or 45

local vignetteMat = Material( "effects/shaders/zb_vignette" )

SCOREBOARD_MENU_OPTIONS = {
    {
        text = function(pl) return "Открыть профиль" end,
        callback = function(pl) pl:ShowProfile() end,
        icon = "icon16/vcard.png"
    },
    {
        text = function(pl) return "Имя: " .. pl:Name() end,
        callback = function(pl) SetClipboardText(pl:Name()) end,
        icon = "icon16/user.png"
    },
    {
        text = function(pl) return "SteamID: " .. pl:SteamID() end,
        callback = function(pl) SetClipboardText(pl:SteamID()) end,
        icon = "icon16/user.png"
    },
    {
        text = function(pl) return "SteamID64: " .. pl:SteamID64() end,
        callback = function(pl) SetClipboardText(pl:SteamID64()) end,
        icon = "icon16/tag_blue.png"
    },
    {
        text = function(pl) 
            local r = pl:GetUserGroup() or "user"
            if pl:GetNWBool("AdminHidden", false) then r = "user" end
            return "Ранг: " .. r 
        end,
        callback = function(pl) 
            local r = pl:GetUserGroup() or "user"
            if pl:GetNWBool("AdminHidden", false) then r = "user" end
            SetClipboardText(r) 
        end,
        icon = "icon16/award_star_gold_3.png"
    },
    {
        text = function(pl) return "Организация: " .. (pl:GetOrg() or "Нет") end,
        callback = function(pl) end,
        icon = "icon16/group.png"
    },
}

SCOREBOARD_JOBS = {
    [TEAM_CITIZEN] = "icon16/user_suit.png",
    [TEAM_MEDIC] = "icon16/heart.png",
    [TEAM_POLICE_PLUS] = "icon16/shield.png",
    [TEAM_POLICE] = "icon16/shield.png",
    [TEAM_SWAT] = "icon16/shield.png",
    [TEAM_FBI] = "icon16/shield_add.png",
}

local function GetIconJob(job)
    if SCOREBOARD_JOBS[job] then
        return SCOREBOARD_JOBS[job]
    else
        return SCOREBOARD_JOBS[TEAM_CITIZEN] or "icon16/user.png"
    end
end

local renderPlayers = function(scrollPanel)
    local sortedPlayer = player.GetAll()

    table.sort(sortedPlayer, function(a, b)
        local classNameA = a:GetPlayerClass() and a:GetPlayerClass().Name or "Гражданский"
        local classNameB = b:GetPlayerClass() and b:GetPlayerClass().Name or "Гражданский"
        
        if classNameA ~= classNameB then
            return classNameA > classNameB
        else
            return a:Nick() < b:Nick()
        end
    end)

    local rowIndex = 0
    for _, pl in pairs(sortedPlayer) do
        if pl:GetNWBool('HideTAB', false) then continue end
        rowIndex = rowIndex + 1
        
        scrollPanel.players[pl] = scrollPanel:Add('DButton')
        local plrpnl = scrollPanel.players[pl]
        plrpnl:Dock(TOP)
        plrpnl:DockMargin(0, 0, s(12), s(8))
        plrpnl:SetTall(s(54))
        plrpnl:SetText("")
        plrpnl.hoverLerp = 0
        plrpnl.animAlpha = 0
        plrpnl.spawnTime = SysTime() + (rowIndex * 0.04)
        
        plrpnl.Paint = function(self, w, h)
            if not IsValid(pl) then return end
            
            if SysTime() > self.spawnTime then
                self.animAlpha = Lerp(FrameTime() * 8, self.animAlpha, 1)
            end
            
            surface.SetAlphaMultiplier(self.animAlpha)
            self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, (self:IsHovered() or self:IsChildHovered(2)) and 1 or 0)
            
            local isPremium = pl.HasPremium and pl:HasPremium()

            local bgColor = ColorAlpha(colors.bg_alt or Color(30, 30, 30), 200 + (40 * self.hoverLerp))
            draw.RoundedBox(8, 0, 0, w, h, bgColor)

            if isPremium then
                local pulse = (math.sin(RealTime() * 4) + 1) / 2
                local rainbowColor = HSVToColor((RealTime() * 40) % 360, 0.6, 1)

                draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(rainbowColor, 10 + (15 * pulse)))

                draw.RoundedBox(8, 0, 0, s(4), h, rainbowColor)
                draw.RoundedBox(8, w - s(4), 0, s(4), h, rainbowColor)
                
                if self.hoverLerp > 0.01 then
                    draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(rainbowColor, 30 * self.hoverLerp))
                end
            elseif self.hoverLerp > 0.01 then
                local accent = colors.accent or Color(100, 150, 255)
                draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(accent, 15 * self.hoverLerp))
                draw.RoundedBox(4, s(4), h/2 - s(12), s(4), s(24), ColorAlpha(accent, 255 * self.hoverLerp))
            end
        end

        plrpnl.DoClick = function()
            if not IsValid(pl) then return end
            local menu = DermaMenu()
            for _, opt in ipairs(SCOREBOARD_MENU_OPTIONS) do
                local item = menu:AddOption(opt.text(pl), function()
                    if IsValid(pl) then opt.callback(pl) end
                end)
                if opt.icon then item:SetIcon(opt.icon) end
            end
            menu:Open(gui.MouseX(), gui.MouseY())
        end

        local avtBg = vgui.Create("DPanel", plrpnl)
        avtBg:Dock(LEFT)
        avtBg:DockMargin(s(12), s(7), s(8), s(7))
        avtBg:SetWide(s(40))
        avtBg.Paint = function(self, w, h)
            if IsValid(pl) and pl.HasPremium and pl:HasPremium() then
                local pulse = (math.sin(RealTime() * 6) + 1) / 2
                local ringColor = HSVToColor((RealTime() * 60) % 360, 0.8, 1)
                draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(ringColor, 150 + (105 * pulse)))
            else
                draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, 150))
            end
        end

        local plravt = vgui.Create("AvatarImage", avtBg)
        plravt:Dock(FILL)
        plravt:DockMargin(s(2), s(2), s(2), s(2))
        plravt:SetPlayer(pl, 64)
        plravt:SetCursor("hand")
        plravt.OnMousePressed = function(self, code)
            if not IsValid(pl) then return end
            if code == MOUSE_LEFT then pl:ShowProfile() end
        end

        local country = pl:GetNWString("country", "ru")
        local flagIcon = vgui.Create('DImage', plrpnl)
        flagIcon:Dock(LEFT)
        flagIcon:DockMargin(s(4), s(19), s(10), s(19))
        flagIcon:SetWide(s(16))
        flagIcon:SetMouseInputEnabled(false)
        flagIcon:SetImage("flags16/" .. string.lower(country) .. ".png")
        if IsValid(pl) and pl:SteamID64() == "76561198966614836" then
            flagIcon:SetImage("flags16/ua.png")
        elseif IsValid(pl) and pl:SteamID64() == "76561198999608745" then
            flagIcon:SetImage("flags16/us.png")
        elseif IsValid(pl) and pl:SteamID64() == "76561198330354988" then
            flagIcon:SetImage("flags16/de.png")
        end

        local namePnl = vgui.Create('DPanel', plrpnl)
        namePnl:Dock(LEFT)
        namePnl:SetWide(s(390)) 
        namePnl:SetMouseInputEnabled(false)
        namePnl.Paint = function(self, w, h)
            if not IsValid(pl) then return end
            
            local rpName = pl:GetPlayerName()
            local isPremium = pl.HasPremium and pl:HasPremium()

            if isPremium then
                local glowColor = HSVToColor((RealTime() * 40) % 360, 0.7, 1)
                draw.SimpleText(rpName, 'ui.20', 0, s(10), ColorAlpha(glowColor, 40), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(rpName, 'ui.20', 0, s(11), ColorAlpha(glowColor, 20), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

                surface.SetFont('ui.20')
                surface.SetTextPos(0, s(10))
                
                local nameLen = utf8.len(rpName)
                for i = 1, nameLen do
                    local char = utf8.sub(rpName, i, i)
                    local hue = ((RealTime() * 60) - i * 15) % 360
                    local shineOffset = (RealTime() * 15) % (nameLen + 15)
                    local shineDistance = math.abs(shineOffset - i)
                    local shineIntensity = math.Clamp(1 - (shineDistance / 2), 0, 1)
                    
                    local charColor = HSVToColor(hue, 0.6 - (shineIntensity * 0.5), 0.8 + (shineIntensity * 0.2))
                    surface.SetTextColor(charColor)
                    surface.DrawText(char)
                end
            else
                draw.SimpleText(rpName, 'ui.20', 0, s(10), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end

            local steamName = pl:Name()
            surface.SetFont('ui.14')
            local steamW = surface.GetTextSize(steamName)
            draw.SimpleText(steamName, 'ui.14', 0, s(32), ColorAlpha(colors.white or color_white, 120), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            
            local curX = steamW + s(10)

            if isPremium then
                local brentText = "BRENTWOOD+"
                surface.SetFont("ui.14")
                local bw = surface.GetTextSize(brentText)
                
                local pulse = (math.sin(RealTime() * 4) + 1) / 2
                draw.RoundedBox(4, curX, s(30), bw + s(12), s(18), Color(255, 170, 0, 30 + (25 * pulse)))
                
                surface.SetTextPos(curX + s(6), s(31))
                for i = 1, utf8.len(brentText) do
                    local char = utf8.sub(brentText, i, i)
                    local shine = math.sin(RealTime() * 4 - i * 0.3)
                    local r = 255
                    local g = Lerp((shine + 1) / 2, 170, 255)
                    local b = Lerp((shine + 1) / 2, 0, 150)
                    
                    surface.SetTextColor(r, g, b, 255)
                    surface.DrawText(char)
                end
                
                curX = curX + bw + s(18)
            end
            
            local rawRank = pl:GetUserGroup() or "user"
            
            if pl:GetNWBool("AdminHidden", false) then
                rawRank = "user"
            end

            local rank = string.upper(rawRank)
            
            if rawRank ~= "user" and rawRank ~= "User" then
                local isSuperAdmin = (string.lower(rawRank) == "superadmin")
                
                surface.SetFont("ui.14")
                local rw = surface.GetTextSize(rank)
                
                local rankBoxColor = isSuperAdmin and ColorAlpha(HSVToColor((RealTime() * 50) % 360, 0.6, 1), 40) or Color(200, 150, 50, 40)
                draw.RoundedBox(4, curX, s(30), rw + s(12), s(18), rankBoxColor)
                
                if isSuperAdmin then
                    surface.SetTextPos(curX + s(6), s(31))
                    for i = 1, utf8.len(rank) do
                        surface.SetTextColor(HSVToColor( ( ( RealTime() * 60 ) - i * 15 ) % 360, 0.6, 1 ))
                        surface.DrawText( utf8.sub(rank, i, i) )
                    end
                else
                    draw.SimpleText(rank, "ui.14", curX + s(6), s(31), Color(250, 200, 100, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
                
                curX = curX + rw + s(18)
            end

            local org = pl:GetOrg()
            if org and org ~= "Нет" and org ~= "" then
                org = string.upper(org)
                local ow = surface.GetTextSize(org)
                
                local orgColor = pl.GetOrgColor and pl:GetOrgColor() or Color(100, 150, 255)
                
                draw.RoundedBox(4, curX, s(30), ow + s(12), s(18), ColorAlpha(orgColor, 40))
                draw.SimpleText(org, "ui.14", curX + s(6), s(31), ColorAlpha(orgColor, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
        end

        local pingPnl = vgui.Create("DPanel", plrpnl)
        pingPnl:Dock(RIGHT)
        pingPnl:SetWide(s(90))
        pingPnl:SetMouseInputEnabled(false)
        pingPnl.Paint = function(self, w, h)
            if not IsValid(pl) then return end
            
            local ping = pl:Ping()
            local pColor = Color(77, 255, 126)
            if ping > 120 then pColor = Color(255, 80, 80)
            elseif ping > 70 then pColor = Color(255, 180, 50) end
            
            draw.RoundedBox(s(14), s(10), h/2 - s(14), s(60), s(28), ColorAlpha(pColor, 20))
            draw.SimpleText(ping .. " ms", "ui.14", s(40), h/2, pColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local timePnl = vgui.Create("DPanel", plrpnl)
        timePnl:Dock(RIGHT)
        timePnl:SetWide(s(120))
        timePnl:SetMouseInputEnabled(false)
        timePnl.Paint = function(self, w, h)
            if not IsValid(pl) then return end
            draw.RoundedBox(s(14), s(10), h/2 - s(14), s(100), s(28), Color(0, 0, 0, 100))
            draw.SimpleText(pl:GetPlayTimeFormatted(), "ui.14", s(68), h/2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        local timeimg = vgui.Create('DImage', timePnl)
        timeimg:SetSize(s(12), s(12))
        timeimg:SetPos(s(20), s(21))
        timeimg:SetImage("icon16/clock.png")
        timeimg:SetAlpha(150)

        local jobPnl = vgui.Create("DPanel", plrpnl)
        jobPnl:Dock(RIGHT)
        jobPnl:SetWide(s(200))
        jobPnl:SetMouseInputEnabled(false)
        jobPnl.Paint = function(self, w, h)
            if not IsValid(pl) then return end
            draw.RoundedBox(s(14), s(10), h/2 - s(14), s(180), s(28), Color(0, 0, 0, 100))
            
            local jobName = pl:GetPlayerClass() and pl:GetPlayerClass().Name or "Гражданский"
            draw.SimpleText(jobName, "ui.14", s(108), h/2, Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            surface.SetAlphaMultiplier(1)
        end
        local jobimg = vgui.Create('DImage', jobPnl)
        jobimg:SetSize(s(14), s(14))
        jobimg:SetPos(s(20), s(20))
        jobimg:SetImage(GetIconJob(pl:GetPlayerClass()))
        jobimg:SetAlpha(200)
    end
end

local getColorTickRate = function(tickRate)
    if tickRate < 15 and tickRate > 10 then return "255, 130, 39"
    elseif tickRate < 10 then return "213, 85, 85"
    else return "77, 255, 126" end
end

hook.Add('ScoreboardShow', 'rp.ScoreBoard', function()
    if IsValid(blurPanel) then blurPanel:Remove() end

    local adminsOnline = 0
    for _, p in ipairs(player.GetAll()) do
        if p:IsAdmin() and not p:GetNWBool("AdminHidden", false) then 
            adminsOnline = adminsOnline + 1
        end
    end

    local acc = colors.accent or Color(100, 150, 255)
    local accentColorStr = acc.r .. ", " .. acc.g .. ", " .. acc.b

    blurPanel = vgui.Create('DPanel')
    blurPanel:SetSize(ScrW(), ScrH())
    blurPanel:SetPos(0, 0)
    blurPanel:MakePopup()
    blurPanel:SetAlpha(0)
    blurPanel.lerpHover = 0
    blurPanel.close = false
    blurPanel.Paint = function(self, w, h)
        self.lerpHover = math.Clamp(not self.close and self.lerpHover + FrameTime()*3 or self.lerpHover - FrameTime()*3, 0, 1)

        vignetteMat:SetFloat("$c2_x", CurTime() + 10000)
        vignetteMat:SetFloat("$c0_z", 5 * self.lerpHover)
        vignetteMat:SetFloat("$c1_y", 10)

        render.SetMaterial(vignetteMat)
        render.DrawScreenQuad()
        render.UpdateScreenEffectTexture()
        
        RNDX.Draw(0, 0, 0, w, h, ColorAlpha(colors.bg or Color(15, 15, 15), 210 * self.lerpHover))

        markup.Parse("<font=ui.25><color=230, 230, 230>Админов онлайн: </color><color=" .. accentColorStr .. ">" .. adminsOnline .. "</color>"):Draw(w - s(30), h - s(65), 2, 4)

        local tickRate = ("%.2f"):format(1 / engine.ServerFrameTime())
        local tickRateColor = getColorTickRate(tonumber(tickRate))
        markup.Parse("<font=ui.25><color=230, 230, 230>Тикрейт: </color><color=" .. tickRateColor .. ">" .. tickRate .. "</color>"):Draw(w - s(30), h - s(30), 2, 4)
    end

    tab = blurPanel:Add('Panel')
    tab:SetSize(s(900), s(850)) 
    tab:Center()
    tab:SetAlpha(0)
    
    blurPanel:AlphaTo(255, 0.3, 0, function()
        tab:AlphaTo(255, 0.3, 0)
    end)

    local header = tab:Add('DPanel')
    header:Dock(TOP)
    header:SetTall(s(70))
    header:DockMargin(0, 0, s(12), s(10))
    header.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, ColorAlpha(colors.bg_alt or Color(25, 25, 25), 240))
        
        draw.SimpleText(GetHostName(), "ui.25", s(20), h/2 + 1, Color(0,0,0, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(GetHostName(), "ui.25", s(20), h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        local playersStr = player.GetCount() .. " / " .. shizlib.MaxPlayers .. " Игроков"
        surface.SetFont("ui.20")
        local pw, ph = surface.GetTextSize(playersStr)
        draw.RoundedBox(ph/2 + s(6), w - pw - s(30), h/2 - ph/2 - s(6), pw + s(20), ph + s(12), ColorAlpha(colors.accent or Color(100, 150, 255), 40))
        draw.SimpleText(playersStr, "ui.20", w - s(20), h/2, colors.accent or Color(150, 200, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    local columns = tab:Add('DPanel')
    columns:Dock(TOP)
    columns:SetTall(s(24))
    columns:DockMargin(0, 0, s(12), s(8))
    columns.Paint = function(self, w, h)
        local lblColor = Color(150, 150, 150, 200)
        draw.SimpleText("ИГРОК", "ui.14", s(20), h/2, lblColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        draw.SimpleText("ПИНГ", "ui.14", w - s(55), h/2, lblColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("ОНЛАЙН", "ui.14", w - s(90) - s(60), h/2, lblColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("ПРОФЕССИЯ", "ui.14", w - s(210) - s(100), h/2, lblColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    blurPanel.sp = tab:Add('DScrollPanel')
    blurPanel.sp:Dock(FILL)
    blurPanel.sp.players = {}

    local sbar = blurPanel.sp:GetVBar()
    sbar:SetWide(s(6))
    sbar:SetHideButtons(true)
    sbar.Paint = function(self, w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(0, 0, 0, 80))
    end
    sbar.btnGrip.Paint = function(self, w, h)
        local a = self:IsHovered() and 220 or 120
        draw.RoundedBox(3, 0, 0, w, h, Color(255, 255, 255, a))
    end

    renderPlayers(blurPanel.sp)

    return false
end)

hook.Add('ScoreboardHide', 'rp.ScoreBoard', function()
    if IsValid(tab) then
        tab:AlphaTo(0, 0.2, 0, function()
            if IsValid(tab) then tab:Remove() end
        end)
    end
    
    if IsValid(blurPanel) then
        blurPanel.close = true
        blurPanel:AlphaTo(0, 0.2, 0, function()
            if IsValid(blurPanel) then blurPanel:Remove() end
        end)
    end
    
    return false
end)

hook.Add("PlayerDisconnected", "TAB.RemovePlayer", function(ply)
    if IsValid(blurPanel) and IsValid(blurPanel.sp) then
        blurPanel.sp:Clear()
        blurPanel.sp.players = {}
        renderPlayers(blurPanel.sp)
    end
end)