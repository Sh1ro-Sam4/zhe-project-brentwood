if not CLIENT then return end
iPhoneOS = iPhoneOS or {}
iPhoneOS.Apps = iPhoneOS.Apps or {}

iPhoneOS.Apps["home"] = function(appID)
    local theme = iPhoneOS.GetTheme()
    iPhoneOS.CurrentApp.bgColor = Color(0,0,0,0)
    local dockH = 86
    local dockY = iPhoneOS.SCREEN_H - dockH - 10
    local dock = vgui.Create("DPanel", iPhoneOS.CurrentApp)
    dock:SetSize(iPhoneOS.SCREEN_W - 20, dockH)
    dock:SetPos(10, dockY)
    dock.Paint = function(self, w, h) iPhoneOS.DrawRounded(28, 0, 0, w, h, ColorAlpha(theme.bg2, 200)) end

    local apps = {
        {id="contacts", name="Контакты", isDock=true, pos=1},
        {id="sms", name="СМС", isDock=true, pos=2},
        {id="settings", name="Настройки", isDock=true, pos=3},
        {id="notes", name="Заметки", isDock=false, row=0, col=0},
        {id="paint", name="Paint", isDock=false, row=0, col=1},
        {id="calc", name="Кальк", isDock=false, row=0, col=2},
        {id="music", name="iMusic", isDock=false, row=1, col=0},
        {id="snake", name="Змейка", isDock=false, row=1, col=1},
        {id="files", name="Проводник", color=Color(52, 152, 219), isDock=false, row=1, col=2},
        {id="bank", name="Банк", color=Color(46, 204, 113), isDock=false, row=2, col=0}
    }
    
    if iPhoneOS.CallData.state ~= "none" then
        table.insert(apps, {id="call_screen", name="Звонок", isDock=false, row=2, col=0})
    end

    local spaceX = (iPhoneOS.SCREEN_W - 40 - (iPhoneOS.ICON_SIZE * 3)) / 2

    for _, app in ipairs(apps) do
        local btn = vgui.Create("DButton", iPhoneOS.CurrentApp)
        btn:SetSize(iPhoneOS.ICON_SIZE, iPhoneOS.ICON_SIZE)
        btn:SetText("")
        
        if app.isDock then
            local space = (dock:GetWide() - (iPhoneOS.ICON_SIZE * 3)) / 4
            btn:SetPos(dock:GetX() + space * app.pos + iPhoneOS.ICON_SIZE * (app.pos - 1), dockY + (dockH - iPhoneOS.ICON_SIZE)/2)
        else
            btn:SetPos(20 + app.col * (iPhoneOS.ICON_SIZE + spaceX), 40 + app.row * (iPhoneOS.ICON_SIZE + 25))
            local lbl = vgui.Create("DLabel", iPhoneOS.CurrentApp)
            lbl:SetText(app.name)
            lbl:SetFont("iOS_IconList")
            lbl:SetTextColor(theme.text)
            lbl:SetSize(iPhoneOS.ICON_SIZE + 20, 15)
            lbl:SetPos(btn:GetX() - 10, btn:GetY() + iPhoneOS.ICON_SIZE + 5)
            lbl:SetContentAlignment(5)
        end

        btn.Paint = function(self, w, h)
            local customIcon = iPhoneOS.GetCustomImage(app.id)
            if customIcon then
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(customIcon)
                surface.DrawTexturedRect(0, 0, w, h)
                if self:IsHovered() then iPhoneOS.DrawRounded(18, 0, 0, w, h, Color(0, 0, 0, 50)) end
            else
                iPhoneOS.DrawRounded(18, 0, 0, w, h, app.color or theme.accent)
                if self:IsHovered() then iPhoneOS.DrawRounded(18, 0, 0, w, h, Color(0, 0, 0, 50)) end
                if app.id == "call_screen" then
                    iPhoneOS.DrawRounded(4, w/2 - 8, h/2 - 10, 16, 20, color_white)
                    iPhoneOS.DrawRounded(2, w/2 - 6, h/2 - 7, 12, 12, theme.accent)
                    iPhoneOS.DrawRounded(2, w/2 - 3, h/2 + 6, 6, 2, theme.accent)
                else
                    iPhoneOS.DrawAppIcon(app.id, w, h, theme, self:IsHovered())
                end
            end
        end
        btn.DoClick = function() iPhoneOS.PlayUISound("Click"); iPhoneOS.LaunchApp(app.id) end
    end
end
