local s, DTR = shizlib.surface.s, shizlib.surface.DTR
local RNDX = include("shizlib/client/rndx_cl.lua")

shizlib.request = shizlib.request or {}

local mat1 = Material("rpui/check.png", "smooth mips")
local mat2 = Material("rpui/warning.png", "smooth")
shizlib.request.string = function(title, text, default, cback)
    if IsValid(LocalPlayer().__stringRequest) then LocalPlayer().__stringRequest:Remove() end
    if not title then title = "nil" end
    if not text then text = "nil" end
    if not default then default = "nil" end
    if not cback then
        cback = function(t)
            RunConsoleCommand("say", "i need to print", t)
        end
    end
    LocalPlayer().__stringRequest = vgui.Create("EditablePanel")
    local err, erpanel
    local pnl = LocalPlayer().__stringRequest
    pnl:SetSize(0, s(350))
    pnl:Center()
    pnl:MakePopup()
    pnl:SizeTo(s(600), s(350), .4, 0)
    pnl:MoveTo(shizlib.hud.ScrW / 2 - s(300), shizlib.hud.ScrH / 2 - s(175), .4, 0)
    pnl.Paint = function(self, w, h)
        RNDX.Draw(8, 0, 0, w, h, Color(22, 22, 22), RNDX.SHAPE_FIGMA)
    end

    pnl.cls = pnl:Add("DButton")
    local cls = pnl.cls
    cls:SetPos(s(600 - 20 - 95), s(20))
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
        pnl:SizeTo(0, s(350), .4, 0)
        pnl:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(175), .4, 0, -1, function()
            pnl:Remove()
        end)
    end
    cls.DoRightClick = cls.DoClick
    cls.Think = function(self)
        if(input.IsKeyDown(KEY_ESCAPE) || gui.IsGameUIVisible()) then
            pnl:SizeTo(0, s(350), .4, 0)
            pnl:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(175), .4, 0, -1, function()
                pnl:Remove()
            end)
        end
    end

    pnl.mtitle = pnl:Add("DLabel")
    pnl.mtitle:Dock(TOP)
    pnl.mtitle:DockMargin(s(40), s(20), 0, s(12))
    pnl.mtitle:SetTall(s(30))
    pnl.mtitle:SetText(title)
    pnl.mtitle:SetFont("IB_25")
    pnl.mtitle:SetTextColor(color_white)
    pnl.mtitle:SizeToContents()

    local txt = string.Wrap('IB_14', text, s(600 - 30))
    for _, _text in pairs(txt) do
        local lbl = vgui.Create('DLabel', pnl)
        lbl:Dock(TOP)
        lbl:DockMargin(s(40),0,0,0)
        lbl:SetText(_text)
        lbl:SetFont('IB_14')
        lbl:SetTextColor(Color(255,255,255,127))
        lbl:SizeToContents()
    end

    local line = pnl:Add("Panel")
    line:Dock(TOP)
    line:DockMargin(s(52), s(26), s(55), 0)
    line:SetTall(s(2))
    line.Paint = function(self, w, h)
        draw.RoundedBox(0,0,0,w,h,Color(40,40,40))
    end

    local entry = pnl:Add("Panel")
    entry:Dock(TOP)
    entry:DockMargin(s(31),s(19),s(44),0)
    entry:SetTall(s(70))
    entry.clr1 = Color(29,29,29)
    entry.clr2 = Color(19,19,19)
    entry.clr3 = Color(242,47,47)
    entry.clr4 = Color(24,16,16)
    function entry:Paint(w,h)
        draw.RoundedBox(8,0,0,w,h,err and self.clr3 or self.clr1)
        draw.RoundedBox(8,1,1,w-2,h-2,err and self.clr4 or self.clr2)
    end

    local tentry = entry:Add("DTextEntry")
    tentry:Dock(FILL)
    tentry:DockMargin(s(26), s(12), s(26), s(11))
    tentry:SetWide(s(462))
    tentry:SetValue(default and default or "Введите значение" .. "...")
    tentry:SetFont("IB_14")
    tentry.OnMousePressed = function(self)
        self:SetValue("")
    end
    tentry.Paint = function(self, w, h)
        self:DrawTextEntryText(err and entry.clr3 or Color(255,255,255,127), Color(255,255,255,127), color_white)
    end
    tentry.OnChange = function(self)
        err = false 
        if IsValid(erpanel) then erpanel:Remove() end
    end
    tentry.OnEnter = function(self)
        if tentry:GetValue() == default or tentry:GetValue() == 'Введите значение...' then merror('Ошибка','Вы не изменили значение!') return end
        if tentry:GetValue() == nil or tentry:GetValue() == '' then merror('Ошибка','Пустое значение!') return end
        pnl:SizeTo(0, s(350), .4, 0)
        pnl:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(175), .4, 0, -1, function()
            pnl:Remove()
        end)
        cback(tentry:GetValue())
    end

    local accetppanel = pnl:Add("Panel")
    accetppanel:Dock(BOTTOM)
    accetppanel:DockMargin(s(37), s(37), s(37), s(37))
    accetppanel:SetTall(s(60))

    local accept = vgui.Create('DButton', accetppanel)
    accept:Dock(LEFT)
    accept:SetWide(s(249))
    accept:SetText('')
    function accept:Paint(w,h)
        local isHovered = self:IsHovered()
        local firstColor = isHovered and color_black or color_white
        local secondColor = isHovered and color_white or Color(32,32,32)

        draw.RoundedBox(8,0,0,w,h,secondColor)

        draw.RoundedBox(4,s(10),s(10),s(40),s(40),Color(24,24,24))
        surface.SetMaterial(mat1)
        surface.SetDrawColor(255,255,255)
        surface.DrawTexturedRect(s(24),s(26),s(12),s(12))

        draw.SimpleText('Готово','IB_20',s(69),h/2,firstColor,0,1)
    end
    function accept:DoClick()
        if tentry:GetValue() == default or tentry:GetValue() == 'Введите значение...' then merror('Ошибка','Вы не изменили значение!') return end
        if tentry:GetValue() == nil or tentry:GetValue() == '' then merror('Ошибка','Пустое значение!') return end
        pnl:SizeTo(0, s(350), .4, 0)
        pnl:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(175), .4, 0, -1, function()
            pnl:Remove()
        end)
        cback(tentry:GetValue())
    end

    function merror(tit,text)
        if IsValid(erpanel) then erpanel:Remove() end
        err = true
        erpanel = vgui.Create('Panel', accetppanel)
        erpanel:Dock(LEFT)
        erpanel:DockMargin(s(19), 0, 0, 0)
        erpanel:SetAlpha(0)
        erpanel:AlphaTo(255,0.2)
        erpanel:SetWide(s(209))
        function erpanel:Paint(w,h)
            surface.SetMaterial(mat2)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(s(-5),s(10),s(40),s(40))
        end

        local ertitle = vgui.Create('DLabel', erpanel)
        ertitle:Dock(TOP)
        ertitle:DockMargin(s(40),s(8),0,0)
        ertitle:SetText(tit)
        ertitle:SetFont('IB_14')
        ertitle:SetTextColor(Color(242,47,47))
        ertitle:SizeToContentsX()

        local txt = string.Wrap('IB_14', text, erpanel:GetWide())
        for k, v in ipairs(txt) do
            local lbl = vgui.Create('DLabel', erpanel)
            lbl:Dock(TOP)
            lbl:DockMargin(s(40),s(4),0,0)
            lbl:SetText(v)
            lbl:SetFont('IB_14')
            lbl:SetTextColor(Color(242,47,47))
            lbl:SizeToContents()
        end
    end

    return pnl
end

shizlib.request.number = function(title, text, default, cback)
    if IsValid(LocalPlayer().__stringRequest) then LocalPlayer().__stringRequest:Remove() end
    if not title then title = "nil" end
    if not text then text = "nil" end
    if not default then default = "nil" end
    if not cback then
        cback = function(t)
            RunConsoleCommand("say", "i need to print", t)
        end
    end
    LocalPlayer().__stringRequest = vgui.Create("EditablePanel")
    local err, erpanel
    local pnl = LocalPlayer().__stringRequest
    pnl:SetSize(0, s(350))
    pnl:Center()
    pnl:MakePopup()
    pnl:SizeTo(s(600), s(350), .4, 0)
    pnl:MoveTo(shizlib.hud.ScrW / 2 - s(300), shizlib.hud.ScrH / 2 - s(175), .4, 0)
    pnl.Paint = function(self, w, h)
        RNDX.Draw(8, 0, 0, w, h, Color(22, 22, 22), RNDX.SHAPE_FIGMA)
    end

    pnl.cls = pnl:Add("DButton")
    local cls = pnl.cls
    cls:SetPos(s(600 - 20 - 95), s(20))
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
        pnl:SizeTo(0, s(350), .4, 0)
        pnl:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(175), .4, 0, -1, function()
            pnl:Remove()
        end)
    end
    cls.DoRightClick = cls.DoClick
    cls.Think = function(self)
        if(input.IsKeyDown(KEY_ESCAPE) || gui.IsGameUIVisible()) then
            pnl:SizeTo(0, s(350), .4, 0)
            pnl:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(175), .4, 0, -1, function()
                pnl:Remove()
            end)
        end
    end

    pnl.mtitle = pnl:Add("DLabel")
    pnl.mtitle:Dock(TOP)
    pnl.mtitle:DockMargin(s(40), s(20), 0, s(12))
    pnl.mtitle:SetTall(s(30))
    pnl.mtitle:SetText(title)
    pnl.mtitle:SetFont("IB_25")
    pnl.mtitle:SetTextColor(color_white)
    pnl.mtitle:SizeToContents()

    local txt = string.Wrap('IB_14', text, s(600 - 30))
    for _, _text in pairs(txt) do
        local lbl = vgui.Create('DLabel', pnl)
        lbl:Dock(TOP)
        lbl:DockMargin(s(40),0,0,0)
        lbl:SetText(_text)
        lbl:SetFont('IB_14')
        lbl:SetTextColor(Color(255,255,255,127))
        lbl:SizeToContents()
    end

    local line = pnl:Add("Panel")
    line:Dock(TOP)
    line:DockMargin(s(52), s(26), s(55), 0)
    line:SetTall(s(2))
    line.Paint = function(self, w, h)
        draw.RoundedBox(0,0,0,w,h,Color(40,40,40))
    end

    local entry = pnl:Add("Panel")
    entry:Dock(TOP)
    entry:DockMargin(s(31),s(19),s(44),0)
    entry:SetTall(s(70))
    entry.clr1 = Color(29,29,29)
    entry.clr2 = Color(19,19,19)
    entry.clr3 = Color(242,47,47)
    entry.clr4 = Color(24,16,16)
    function entry:Paint(w,h)
        draw.RoundedBox(8,0,0,w,h,err and self.clr3 or self.clr1)
        draw.RoundedBox(8,1,1,w-2,h-2,err and self.clr4 or self.clr2)
    end

    local tentry = entry:Add("DTextEntry")
    tentry:Dock(FILL)
    tentry:DockMargin(s(26), s(12), s(26), s(11))
    tentry:SetWide(s(462))
    tentry:SetValue(default and default or "Введите значение" .. "...")
    tentry:SetFont("IB_14")
    tentry:SetNumeric(true)
    tentry.OnMousePressed = function(self)
        self:SetValue("")
    end
    tentry.Paint = function(self, w, h)
        self:DrawTextEntryText(err and entry.clr3 or Color(255,255,255,127), Color(255,255,255,127), color_white)
    end
    tentry.OnChange = function(self)
        err = false 
        if IsValid(erpanel) then erpanel:Remove() end
    end
    tentry.OnEnter = function(self)
        if tentry:GetValue() == default or tentry:GetValue() == 'Введите значение...' then merror('Ошибка','Вы не изменили значение!') return end
        if tentry:GetValue() == nil or tentry:GetValue() == '' then merror('Ошибка','Пустое значение!') return end
        pnl:SizeTo(0, s(350), .4, 0)
        pnl:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(175), .4, 0, -1, function()
            pnl:Remove()
        end)
        cback(tentry:GetValue())
    end

    local accetppanel = pnl:Add("Panel")
    accetppanel:Dock(BOTTOM)
    accetppanel:DockMargin(s(37), s(37), s(37), s(37))
    accetppanel:SetTall(s(60))

    local accept = vgui.Create('DButton', accetppanel)
    accept:Dock(LEFT)
    accept:SetWide(s(249))
    accept:SetText('')
    function accept:Paint(w,h)
        local isHovered = self:IsHovered()
        local firstColor = isHovered and color_black or color_white
        local secondColor = isHovered and color_white or Color(32,32,32)

        draw.RoundedBox(8,0,0,w,h,secondColor)

        draw.RoundedBox(4,s(10),s(10),s(40),s(40),Color(24,24,24))
        surface.SetMaterial(mat1)
        surface.SetDrawColor(255,255,255)
        surface.DrawTexturedRect(s(24),s(26),s(12),s(12))

        draw.SimpleText('Готово','IB_20',s(69),h/2,firstColor,0,1)
    end
    function accept:DoClick()
        if tentry:GetValue() == default or tentry:GetValue() == 'Введите значение...' then merror('Ошибка','Вы не изменили значение!') return end
        if tentry:GetValue() == nil or tentry:GetValue() == '' then merror('Ошибка','Пустое значение!') return end
        pnl:SizeTo(0, s(350), .4, 0)
        pnl:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(175), .4, 0, -1, function()
            pnl:Remove()
        end)
        cback(tentry:GetValue())
    end

    function merror(tit,text)
        if IsValid(erpanel) then erpanel:Remove() end
        err = true
        erpanel = vgui.Create('Panel', accetppanel)
        erpanel:Dock(LEFT)
        erpanel:DockMargin(s(19), 0, 0, 0)
        erpanel:SetAlpha(0)
        erpanel:AlphaTo(255,0.2)
        erpanel:SetWide(s(209))
        function erpanel:Paint(w,h)
            surface.SetMaterial(mat2)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(s(-5),s(10),s(40),s(40))
        end

        local ertitle = vgui.Create('DLabel', erpanel)
        ertitle:Dock(TOP)
        ertitle:DockMargin(s(40),s(8),0,0)
        ertitle:SetText(tit)
        ertitle:SetFont('IB_14')
        ertitle:SetTextColor(Color(242,47,47))
        ertitle:SizeToContentsX()

        local txt = string.Wrap('IB_14', text, erpanel:GetWide())
        for k, v in ipairs(txt) do
            local lbl = vgui.Create('DLabel', erpanel)
            lbl:Dock(TOP)
            lbl:DockMargin(s(40),s(4),0,0)
            lbl:SetText(v)
            lbl:SetFont('IB_14')
            lbl:SetTextColor(Color(242,47,47))
            lbl:SizeToContents()
        end
    end

    return pnl
end

shizlib.request.bool = function(title, text, cback)
    if IsValid(LocalPlayer().__boolRequest) then LocalPlayer().__boolRequest:Remove() end
    if not title then title = "nil" end
    if not text then text = "nil" end
    if not cback then
        cback = function(t)
            RunConsoleCommand("say", "i need to print", t)
        end
    end
    LocalPlayer().__boolRequest, err, erpanel = vgui.Create("EditablePanel")
    local err, erpanel
    local pnl = LocalPlayer().__boolRequest
    pnl:SetSize(0, s(323))
    pnl:Center()
    pnl:MakePopup()
    pnl:SizeTo(s(556), s(323), .4, 0)
    pnl:MoveTo(shizlib.hud.ScrW / 2 - s(278), shizlib.hud.ScrH / 2 - s(161.5), .4, 0)
    pnl:DockPadding(s(28), 0, s(28), s(31))
    pnl.Paint = function(self, w, h)
        RNDX.Draw(8, 0, 0, w, h, Color(22, 22, 22), RNDX.SHAPE_FIGMA)
    end

    pnl.cls = pnl:Add("DButton")
    local cls = pnl.cls
    cls:SetPos(s(556 - 20 - 95), s(20))
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
        pnl:SizeTo(0, s(323), .4, 0)
        pnl:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(175), .4, 0, -1, function()
            pnl:Remove()
        end)
    end
    cls.DoRightClick = cls.DoClick
    cls.Think = function(self)
        if(input.IsKeyDown(KEY_ESCAPE) || gui.IsGameUIVisible()) then
            pnl:SizeTo(0, s(350), .4, 0)
            pnl:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(175), .4, 0, -1, function()
                pnl:Remove()
            end)
        end
    end

    pnl.mtitle = pnl:Add("DLabel")
    pnl.mtitle:Dock(TOP)
    pnl.mtitle:DockMargin(s(40), s(20), 0, s(12))
    pnl.mtitle:SetTall(s(30))
    pnl.mtitle:SetText(title)
    pnl.mtitle:SetFont("IB_25")
    pnl.mtitle:SetTextColor(color_white)
    pnl.mtitle:SizeToContents()

    local txt = string.Wrap('IB_14', text, s(600 - 30))
    for _, _text in pairs(txt) do
        local lbl = vgui.Create('DLabel', pnl)
        lbl:Dock(TOP)
        lbl:DockMargin(s(40),0,0,0)
        lbl:SetText(_text)
        lbl:SetFont('IB_14')
        lbl:SetTextColor(Color(255,255,255,127))
        lbl:SizeToContents()
    end

    local line = pnl:Add("Panel")
    line:Dock(TOP)
    line:DockMargin(s(52), s(26), s(55), 0)
    line:SetTall(s(2))
    line.Paint = function(self, w, h)
        draw.RoundedBox(0,0,0,w,h,Color(40,40,40))
    end

    pnl.btn = pnl:Add("DPanel")
    local btn = pnl.btn
    btn:SetSize(s(200), s(60))
    btn:SetPos(s(41), s(323)-s(60)-s(38))
    btn:SetCursor("hand")
    local margin, size, leftmargin = s(10), s(38), s(65)
    btn.Paint = function(self,w,h)
        local isHovered = self:IsHovered()
        local firstColor = isHovered and color_black or color_white
        local secondColor = isHovered and color_white or Color(32,32,32)

        draw.RoundedBox(8,0,0,w,h,secondColor)

        surface.SetMaterial(Material("rpui/check.png"))
        surface.SetDrawColor(firstColor)
        surface.DrawTexturedRect(s(24),s(26),s(12),s(12))

        draw.SimpleText("Продолжить", "IB_20", leftmargin, h*.5, firstColor, 0, 1)
    end
    btn.OnMousePressed = function()
        cback(true)
        if(IsValid(pnl)) then pnl:Remove() end
    end
end

local check_text_match = function(text, ply, rpname)
    if rpname then
        if ply:Nick():lower():find(text, 1, true) then return true end
    else
        if ply:Name():lower():find(text, 1, true) then return true end
    end
    if ply:SteamID():lower():find(text, 1, true) then return true end
    if ply:SteamID64():lower():find(text, 1, true) then return true end
    return false
end

shizlib.request.playerRequest = function(players, cback, rpname)
    if IsValid(LocalPlayer().__playerRequest) then LocalPlayer().__playerRequest:Remove() end

    LocalPlayer().__playerRequest = vgui.Create("EditablePanel")
    local fr = LocalPlayer().__playerRequest
    fr:SetSize(s(639),s(606))
    fr:Center()
    fr:MakePopup()
    fr:SetAlpha(0)
    fr:AlphaTo(255,0.2)
    fr.lines = {}
    function fr:Paint(w,h)
        RNDX.Draw(8, 0, 0, w, h, Color(22, 22, 22), RNDX.SHAPE_FIGMA)
    end
    function fr:Think()
        if input.IsKeyDown(KEY_ESCAPE) then
            self:Remove()
            gui.HideGameUI()
        end
    end

    local mtitle = fr:Add('DLabel')
    mtitle:Dock(TOP)
    mtitle:DockMargin(s(40),s(36),0,s(12))
    mtitle:SetTall(s(29))
    mtitle:SetText('Выбор игрока')
    mtitle:SetFont('font.24')
    mtitle:SetTextColor(Color(230, 230, 230))
    mtitle:SizeToContents()

    local close = fr:Add("EditablePanel")
    close:SetSize( s(90)+s(5), s(26) )
    close:SetPos( fr:GetWide()-s(29)-s(90), s(35) )
    close:SetCursor("hand")
    local _w, rM = s(38), s(7)
    close.lerpHover = 0

    close.Paint = function(self, w, h)
        self.lerpHover = math.Clamp(self:IsHovered() and self.lerpHover + FrameTime()*3 or self.lerpHover - FrameTime()*3, 0, 1)
        draw.RoundedBox(6,0,0,w,h, shizlib.surface.LerpColor(self.lerpHover,Color(255,255,255,0),color_white) )
        draw.RoundedBox(5,w-s(38),0,s(38),h,color_white)
        draw.SimpleText("Выход", "IB_14", s(5), h*.5, shizlib.surface.LerpColor(self.lerpHover,color_white,color_black), 0, 1)
        draw.SimpleText("Esc", "IB_14", w-s(7), h*.5, color_black, 2, 1)
    end
    close.OnMousePressed = function()
        fr:Remove()
    end

    do
        local line = fr:Add('Panel')
        line:Dock(TOP)
        line:DockMargin(s(42),s(26),s(44),0)
        line:SetTall(s(2))
        function line:Paint(w,h)
            draw.RoundedBox(0,0,0,w,h,Color(40, 40, 40))
        end
    end

    do
        local searchRight = fr:Add('Panel')
        searchRight:Dock(TOP)
        searchRight:DockMargin(s(31),s(19),s(38),0)
        searchRight:SetTall(s(70))
        function searchRight:Paint(w,h)
            draw.RoundedBox(0,0,0,w,h,Color(32, 32, 32))
        end

        searchRight.search = searchRight:Add('DTextEntry')
        searchRight.search:Dock(LEFT)
        searchRight.search:DockMargin(s(26),s(26),0,s(26))
        searchRight.search:SetWide(s(462))
        searchRight.search:SetValue('Поиск...')
        searchRight.search:SetFont('font.14')
        searchRight.search:SetDrawLanguageID(false)
        function searchRight.search:OnMousePressed() 
            self:SetValue("")
        end
        function searchRight.search:Paint(w,h)
            draw.RoundedBox(6,0,0,w,h,Color(32, 32, 32))
            self:DrawTextEntryText(Color(230, 230, 230, 127), Color(230, 230, 230, 127), color_white)
        end
        function searchRight.search.OnChange(self, text)
            if text == nil then
                text = self:GetValue()
            end

            if text ~= "" then
                scroll:ClearSelection()
            end
            text = text:lower()
            for i, line in ipairs(fr.lines) do
                local ply = line.ply
                if not check_text_match(text, ply, rpname) then
                    line:SetVisible(false)
                else
                    line:SetVisible(true)
                    line:SetTall(s(70))
                end
            end
            scroll:InvalidateLayout(true)
        end

        searchRight.seatchinfo = searchRight:Add('Panel')
        searchRight.seatchinfo:Dock(LEFT)
        searchRight.seatchinfo:DockMargin(s(26),s(15),s(16),s(15))
        searchRight.seatchinfo:SetWide(s(40))
        function searchRight.seatchinfo:Paint(w,h)
            draw.RoundedBox(4,0,0,w,h,Color(24, 24, 24))
            surface.SetMaterial(Material("rpui/search.png", "smooth mips"))
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(s(12),s(12),s(16),s(16))
        end
    end
    do
        local line = fr:Add('Panel')
        line:Dock(TOP)
        line:DockMargin(s(42),s(19),s(44),0)
        line:SetTall(s(2))
        function line:Paint(w,h)
            draw.RoundedBox(0,0,0,w,h,Color(40, 40, 40))
        end
    end

    do
        local sharedPlayers = fr:Add('Panel')
        sharedPlayers:Dock(TOP)
        sharedPlayers:DockMargin(s(31),s(26),s(16),0)
        sharedPlayers:SetTall(s(316))

        scroll = sharedPlayers:Add('DScrollPanel')
        scroll:Dock(FILL)
        function scroll.GetSelected()
            local ret = {}
            for _, v in ipairs(fr.lines) do
                if v.Selected then
                    table.insert(ret, v)
                end
            end
            return ret
        end
        function scroll.ClearSelection(s)
            for _, line in ipairs(fr.lines) do
                if IsValid(line) then
                    line.Selected = false
                end
            end
            s:OnRowSelected()
        end
        function scroll:OnRowSelected()
            local plys = {}
            for k, v in ipairs(self:GetSelected()) do
                plys[k] = v.ply:EntIndex()
            end
        end
    end

    do
        for k,v in ipairs(players) do
            if v == LocalPlayer() then continue end

            scroll.ply = vgui.Create('DButton', scroll)
            scroll.ply:Dock(TOP)
            scroll.ply:DockMargin(0,0,s(15),s(12))
            scroll.ply:SetTall(s(70))
            scroll.ply:SetText('')
            scroll.ply.ply = v
            scroll.ply.line = ply
            scroll.ply.id = table.insert(fr.lines, scroll.ply)
            function scroll.ply.Paint(self,w,h)
                local isHovered = self:IsHovered()
                local firstColor = isHovered and color_black or color_white
                local secondColor = isHovered and color_white or Color(32, 32, 32)

                draw.RoundedBox(6,0,0,w,h,secondColor)
                draw.SimpleText(rpname and v:Nick() or v:Name(),'font.14',s(74),h/2,firstColor,0,1)
            end
            function scroll.ply:DoClick()
                cback(v)
                fr:Remove()
            end
            function scroll.ply:Think()
                if not IsValid(v) then 
                    self:Remove() 
                    table.remove(fr.lines, scroll.ply)
                end
            end
            
            do
                scroll.ply.avatar = vgui.Create('AvatarImage', scroll.ply)
                scroll.ply.avatar:Dock(LEFT)
                scroll.ply.avatar:DockMargin(s(14),s(15),0,s(15))
                scroll.ply.avatar:SetWide(s(40))
                scroll.ply.avatar:SetPlayer(v,64)
                scroll.ply.avatar.rounded = 4
            end
        end
    end
    
    return fr
end



local VoteVGUI = VoteVGUI or {}
local QuestionVGUI = QuestionVGUI or {}
local PanelNum = PanelNum or 0
local LetterWritePanel

local function KillVoteVGUI(msg)
	local id = net.ReadShort()

	if VoteVGUI[id .. "vote"] and VoteVGUI[id .. "vote"]:IsValid() then
		VoteVGUI[id .. "vote"]:Close()
	end
end

net.Receive("KillVoteVGUI", KillVoteVGUI)

local s = shizlib.surface.s
local DTR = shizlib.surface.DTR
local melon = include("shizlib/client/masks_cl.lua")
local RNDX = include("shizlib/client/rndx_cl.lua")

net.Receive("DoQuestion", function()
    local question = net.ReadString()
	local quesid = net.ReadString()
	local timeleft = net.ReadFloat()

    if timeleft == 0 then
		timeleft = 100
	end

    
    local chatx, chaty = chat.GetChatBoxPos()
	local chatw, chath = chat.GetChatBoxSize()
	local x = chatx + chatw + 5

    local OldTime = CurTime()
	LocalPlayer():EmitSound("Town.d1_town_02_elevbell1", 100, 100)
	local panel = vgui.Create("DFrame")
	panel:SetPos(s(10), -s(400))
	panel:MoveTo(s(10), s(10) + PanelNum, 0.3, 0, 1)
	panel:SetSize(s(300), s(140))
	panel:SetSizable(false)
	panel:SetKeyboardInputEnabled(false)
	panel:SetMouseInputEnabled(true)
	panel:SetVisible(true)
	panel:ShowCloseButton(false)
    panel:SetTitle("")
    panel.Paint = function(self, w, h)
        RNDX.Draw(8, 0, 0, w, h, Color(22, 22, 22, 220), RNDX.SHAPE_FIGMA)
        RNDX.Draw(8, 0, 0, w, h, nil, RNDX.BLUR + RNDX.SHAPE_FIGMA)
        melon.Start()
            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(Color(255,77,119))
            surface.SetMaterial(Material("vgui/gradient-r"))
            surface.DrawTexturedRectRotated((w*.8), (h*.8), w * 2, h * 2, 0)
        melon.Source()
            RNDX.Draw(16, 0, 0, w, h, nil, RNDX.SHAPE_FIGMA)
        melon.And(melon.KIND_CUT)
            RNDX.Draw(16, s(3), s(3), w - s(6), h - s(6), nil, RNDX.SHAPE_FIGMA)
        melon.End(melon.KIND_STAMP)
        draw.SimpleText("Время: " .. tostring(math.Clamp(math.ceil(timeleft - (CurTime() - OldTime)), 0, 9999)), "font.18", s(5), s(5), color_white, 0, 0)
    end

    function panel:Close()
		PanelNum = PanelNum - s(150)
		QuestionVGUI[quesid .. "ques"] = nil
		local num = 5

		for k, v in SortedPairs(VoteVGUI) do
			v:SetPos(num, ScrH() - 145)
			num = num + 142.5
		end

		for k, v in SortedPairs(QuestionVGUI) do
			v:SetPos(num, ScrH() - 145)
			num = num + 302.5
		end

		self:Remove()
	end
	function panel:Think()
		if timeleft - (CurTime() - OldTime) <= 0 then
			panel:Close()
		end
	end

    local label = panel:Add("DLabel")
	label:SetPos(5, 35)
	label:SetText(question)
	label:SetFont('font.14')
	label:SizeToContents()

	local ybutton = panel:Add("DButton")
	ybutton:SetPos(5, panel:GetTall() - 30)
	ybutton:SetSize(panel:GetWide() / 2 - 7.5, 25)
	ybutton:SetText("")
	ybutton:SetVisible(true)
    ybutton.lerpHover = 0
    ybutton.Paint = function(self, w, h)
        self.lerpHover = math.Clamp(self:IsHovered() and self.lerpHover + FrameTime()*3 or self.lerpHover - FrameTime()*3, 0, 1)
        RNDX.Draw(4, 0, 0, w, h, shizlib.surface.LerpColor(self.lerpHover,Color(40,40,40,200),Color(255,77,119,200)), RNDX.SHAPE_FIGMA)
        draw.SimpleText("Да(F1)", "font.16", w/2, h/2, shizlib.surface.LerpColor(self.lerpHover,Color(255,77,119,200),Color(40,40,40,200)), 1, 1)
    end

	ybutton.DoClick = function()
		LocalPlayer():ConCommand("__shizlib_question_answer " .. quesid .. " 1\n")
		panel:Close()
	end
	ybutton.Think = function()
		if input.IsKeyDown(KEY_F1) then
		LocalPlayer():ConCommand("__shizlib_question_answer " .. quesid .. " 1\n")
		panel:Close()
		end
	end
	local nbutton = panel:Add("DButton")
	nbutton:SetPos(panel:GetWide() / 2 + 2.5, panel:GetTall() - 30)
	nbutton:SetSize(panel:GetWide() / 2 - 7.5, 25)
	nbutton:SetText("")
	nbutton:SetVisible(true)
    nbutton.lerpHover = 0
    nbutton.Paint = function(self, w, h)
        self.lerpHover = math.Clamp(self:IsHovered() and self.lerpHover + FrameTime()*3 or self.lerpHover - FrameTime()*3, 0, 1)
        RNDX.Draw(4, 0, 0, w, h, shizlib.surface.LerpColor(self.lerpHover,Color(40,40,40,200),Color(255,77,119,200)), RNDX.SHAPE_FIGMA)
        draw.SimpleText("Нет(F2)", "font.16", w/2, h/2, shizlib.surface.LerpColor(self.lerpHover,Color(255,77,119,200),Color(40,40,40,200)), 1, 1)
    end

	nbutton.DoClick = function()
		LocalPlayer():ConCommand("__shizlib_question_answer " .. quesid .. " 2\n")
		panel:Close()
	end
	nbutton.Think = function()
		if input.IsKeyDown(KEY_F2) then
		LocalPlayer():ConCommand("__shizlib_question_answer " .. quesid .. " 2\n")
		panel:Close()
		end
	end
	PanelNum = PanelNum + s(150)
	QuestionVGUI[quesid .. "ques"] = panel
end)