iPhoneOS = iPhoneOS or {}
iPhoneOS.Apps = iPhoneOS.Apps or {}

function open911()
    local s = shizlib.surface.s
    local DTR = shizlib.surface.DTR
    local RNDX = include("shizlib/client/rndx_cl.lua")
    local mat1 = Material("rpui/check.png", "smooth mips")
    local mat2 = Material("rpui/search.png", "smooth mips")
    local colors = CFG.theme
    local frame = vgui.Create('EditablePanel')
    frame:Center()
    frame:MakePopup()
    frame:SetSize(s(200), s(200))
    frame:SizeTo(s(400), s(250), .4, 0)
    frame:MoveTo(shizlib.hud.ScrW / 2 - s(200), shizlib.hud.ScrH / 2 - s(125), .4, 0)
    function frame:Paint(w, h)
        RNDX.Draw(8, 0, 0, w, h, colors.bg, RNDX.SHAPE_FIGMA)
    end

    frame.cls = frame:Add("DButton")
    local cls = frame.cls
    cls:SetPos(s(400 - 20 - 95), s(20))
    cls:SetSize(s(95), s(26))
    cls:SetCursor("hand")
    cls:SetText("")
    cls.lerpHover = 0
    cls.Paint = function(self, w, h)
        self.lerpHover = math.Clamp(self:IsHovered() and self.lerpHover + FrameTime()*3 or self.lerpHover - FrameTime()*3, 0, 1)
        draw.RoundedBox(6,0,0,w,h, shizlib.surface.LerpColor(self.lerpHover,Color(255,255,255,0),color_white) )
        draw.RoundedBox(5,w-s(38),0,s(38),h,color_white)
        draw.SimpleText("Выход", "IB_14", s(5), h*.5, shizlib.surface.LerpColor(self.lerpHover,color_white,color_black), 0, 1)
        draw.SimpleText("Esc", "IB_14", w-s(7), h*.5, color_black, 2, 1)
    end
    cls.DoClick = function(self)
        frame:SizeTo(0, s(250), .4, 0)
        frame:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(125), .4, 0, -1, function()
            frame:Remove()
        end)
    end
    cls.DoRightClick = cls.DoClick
    cls.Think = function(self)
        if(input.IsKeyDown(KEY_ESCAPE) || gui.IsGameUIVisible()) then
            frame:SizeTo(0, s(250), .4, 0)
            frame:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(125), .4, 0, -1, function()
                frame:Remove()
            end)
        end
    end

    frame.mtitle = frame:Add("DLabel")
    frame.mtitle:Dock(TOP)
    frame.mtitle:DockMargin(s(40), s(20), 0, s(12))
    frame.mtitle:SetTall(s(30))
    frame.mtitle:SetText("Служба 911")
    frame.mtitle:SetFont("IB_25")
    frame.mtitle:SetTextColor(color_white)
    frame.mtitle:SizeToContents()

    local line = frame:Add("Panel")
    line:Dock(TOP)
    line:DockMargin(s(52), s(5), s(55), 0)
    line:SetTall(s(2))
    function line:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,Color(40,40,40))
    end

    local spanel = vgui.Create("DScrollPanel", frame)
    spanel:Dock(FILL)
    spanel:DockMargin(s(10), s(10), s(10), s(10))

    local button = vgui.Create("DButton", spanel)
    button:Dock(TOP)
    button:DockMargin(s(37), s(17), s(37), s(0))
    button:SetTall(s(60))
    button:SetText("")
    function button:Paint(w, h)
        local isHovered = self:IsHovered()
        local firstColor = isHovered and color_black or color_white
        local secondColor = isHovered and color_white or Color(32,32,32)

        RNDX.Draw(8,0,0,w,h,secondColor)

        RNDX.Draw(4,s(10),s(10),s(40),s(40),Color(24,24,24))
        DTR(s(24),s(26),s(12),s(12), color_white, mat1)

        draw.SimpleText('Полиция','IB_20',s(69),h/2,firstColor,0,1)
    end
    button.DoClick = function()
        shizlib.request.string("Вызов полиции", "Введите причину.", "", function(a)
            net.Start("rp.GovernmentRequare")
                net.WriteString(a)
            net.SendToServer()
        end)
        frame:SizeTo(0, s(250), .4, 0)
        frame:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(125), .4, 0, -1, function()
            frame:Remove()
        end)
    end

    local buttonmed = vgui.Create("DButton", spanel)
    buttonmed:Dock(TOP)
    buttonmed:DockMargin(s(37), s(17), s(37), s(0))
    buttonmed:SetTall(s(60))
    buttonmed:SetText("")
    function buttonmed:Paint(w, h)
        local isHovered = self:IsHovered()
        local firstColor = isHovered and color_black or color_white
        local secondColor = isHovered and color_white or Color(32,32,32)

        RNDX.Draw(8,0,0,w,h,secondColor)

        RNDX.Draw(4,s(10),s(10),s(40),s(40),Color(24,24,24))
        DTR(s(24),s(26),s(12),s(12), color_white, mat1)

        draw.SimpleText('Врачи','IB_20',s(69),h/2,firstColor,0,1)
    end
    buttonmed.DoClick = function()
        shizlib.request.string("Вызов врачей", "Введите причину.", "", function(a)
            net.Start("rp.GovernmentRequareMed")
                net.WriteString(a)
            net.SendToServer()
        end)
        frame:SizeTo(0, s(250), .4, 0)
        frame:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(125), .4, 0, -1, function()
            frame:Remove()
        end)
    end
end

iPhoneOS.Apps["contacts"] = function(appID)
    local theme = iPhoneOS.GetTheme()
    -- === КОНТАКТЫ ===
    iPhoneOS.CurrentApp.bgColor = theme.bg
    local header = vgui.Create("DPanel", iPhoneOS.CurrentApp)
    header:SetSize(iPhoneOS.SCREEN_W, 80)
    header.Paint = function(self, w, h)
        iPhoneOS.DrawRounded(32, 0, 0, w, 64, theme.bg2)
        iPhoneOS.DrawRounded(0, 0, 32, w, h - 32, theme.bg2)
        draw.SimpleText("Контакты", "iOS_AppTitle", w/2, 50, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(theme.line)
        surface.DrawLine(0, 79, w, 79)
    end

    local scroll = vgui.Create("DScrollPanel", iPhoneOS.CurrentApp)
    scroll:SetPos(0, 80)
    scroll:SetSize(iPhoneOS.SCREEN_W, iPhoneOS.SCREEN_H - 80)
    iPhoneOS.StyleScrollbar(scroll, theme)

    -- === 911 ===
    local pnl911 = vgui.Create("DPanel", scroll)
    pnl911:Dock(TOP)
    pnl911:SetTall(60)
    pnl911.Paint = function(self, w, h) 
        surface.SetDrawColor(theme.line)
        surface.DrawLine(20, h-1, w, h-1) 
    end

    local title911 = vgui.Create("DLabel", pnl911)
    title911:SetPos(70, 0)
    title911:SetSize(iPhoneOS.SCREEN_W - 130, 60)
    title911:SetFont("iOS_Text")
    title911:SetTextColor(theme.text)
    title911:SetText("Служба 911")

    local img911 = vgui.Create('DImage', pnl911)
    img911:SetPos(15, 10)
    img911:SetSize(40, 40)
    img911:SetImage('icon16/shield.png')

    local callBtn911 = vgui.Create("DButton", pnl911)
    callBtn911:SetSize(60, 30)
    callBtn911:SetPos(iPhoneOS.SCREEN_W - 75, 15)
    callBtn911:SetText("Вызов")
    callBtn911:SetFont("iOS_IconList")
    callBtn911:SetTextColor(theme.accent)
    callBtn911.Paint = function(self, w, h) 
        iPhoneOS.DrawRounded(15, 0, 0, w, h, ColorAlpha(theme.accent, 30)) 
    end

    callBtn911.DoClick = function()
        if iPhoneOS.PhoneData.Sounds then
            LocalPlayer():EmitSound("phone/gudok.wav", 60)

            timer.Simple(3, function()
                if IsValid(LocalPlayer()) then
                    LocalPlayer():EmitSound("phone/911.wav", 60)
                end
            end)
        end

        timer.Simple(5, function()
            open911()
        end)
    end

    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) then continue end
        local pnl = scroll:Add("DPanel")
        pnl:Dock(TOP)
        pnl:SetTall(60)
        pnl.Paint = function(self, w, h) 
            surface.SetDrawColor(theme.line)
            surface.DrawLine(20, h-1, w, h-1) 
        end

        local ava = vgui.Create("AvatarImage", pnl)
        ava:SetPos(15, 10)
        ava:SetSize(40, 40)
        ava:SetPlayer(ply, 64)

        local name = vgui.Create("DLabel", pnl)
        name:SetPos(70, 0)
        name:SetSize(iPhoneOS.SCREEN_W - 130, 60)
        name:SetFont("iOS_Text")
        name:SetTextColor(theme.text)
        name:SetText(ply:Nick())

        local callBtn = vgui.Create("DButton", pnl)
        callBtn:SetSize(60, 30)
        callBtn:SetPos(iPhoneOS.SCREEN_W - 75, 15)
        callBtn:SetText("Вызов")
        callBtn:SetFont("iOS_IconList")
        callBtn:SetTextColor(theme.accent)
        callBtn.Paint = function(self, w, h) 
            iPhoneOS.DrawRounded(15, 0, 0, w, h, ColorAlpha(theme.accent, 30)) 
        end
        callBtn.DoClick = function(self)
            if iPhoneOS.PhoneData.AirplaneMode then 
                iPhoneOS.ShowPhoneNotification("Ошибка", "Авиарежим включен", Color(231, 76, 60))
                return 
            end
            if iPhoneOS.CallData.state ~= "none" then return end 
            
            if iPhoneOS.PhoneData.Sounds then
                LocalPlayer():StopSound(iPhoneOS.PhoneSounds.DialTone)
                LocalPlayer():EmitSound(iPhoneOS.PhoneSounds.DialTone, 50, 100, 1, CHAN_AUTO)
                
                timer.Create("iPhone_Dialtone", iPhoneOS.PhoneSounds.DialToneDuration, 0, function() 
                    if iPhoneOS.CallData.state == "calling" and iPhoneOS.PhoneData.Sounds then 
                        LocalPlayer():StopSound(iPhoneOS.PhoneSounds.DialTone)
                        LocalPlayer():EmitSound(iPhoneOS.PhoneSounds.DialTone, 50, 100, 1, CHAN_AUTO) 
                    else 
                        iPhoneOS.StopCallSounds() 
                    end 
                end)
            end
            
            iPhoneOS.CallData.state = "calling"
            iPhoneOS.CallData.targetEnt = ply
            iPhoneOS.CallData.targetName = ply:Nick()
            iPhoneOS.LaunchApp("call_screen")
            
            net.Start("iPhone_Call")
            net.WriteString(ply:Nick())
            net.SendToServer()
        end
    end
end
