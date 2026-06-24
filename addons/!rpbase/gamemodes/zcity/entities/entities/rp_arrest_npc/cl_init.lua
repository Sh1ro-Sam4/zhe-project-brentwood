include("shared.lua")

ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Initialize()
end

local color_white = Color(255, 255, 255)
local color_black = Color(0, 0, 0)
local complex_off = Vector(0, 0, 9)
local ang = Angle(0, 90, 90)
local s = shizlib.surface.s
local DTR = shizlib.surface.DTR
local RNDX = include("shizlib/client/rndx_cl.lua")
local mat1 = Material("rpui/check.png", "smooth mips")
local mat2 = Material("rpui/search.png", "smooth mips")

function ENT:Draw()
    self:DrawModel()

    local bone = self:LookupBone('ValveBiped.Bip01_Head1')
    if not bone then return end
    
    local pos = self:GetBonePosition(bone) + complex_off
    ang.y = (LocalPlayer():EyeAngles().y - 90)

    local dist = LocalPlayer():GetPos():Distance(self:GetPos())
    local inView = dist <= 150000

    if (not inView) then return end

    local alpha = 255 - (dist/590)
    color_white.a = alpha
    color_black.a = alpha

    local x = math.sin(CurTime() * math.pi) * 30

    cam.Start3D2D(pos, ang, 0.03)
        draw.SimpleTextOutlined('Тюремщик', '3d2d', 0, x, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
    cam.End3D2D()
end

local frame = nil

net.Receive("OpenArrestMenu", function()
    local npc = net.ReadEntity()
    local players = net.ReadTable()
    local theme = CFG.theme
    if frame and IsValid(frame) then frame:Remove() end
    if not IsValid(npc) then return end

    frame = vgui.Create("EditablePanel")
    frame:SetSize(0, s(300))
    frame:Center()
    frame:MakePopup()
    frame:SizeTo(s(400), s(300), .4, 0)
    frame:MoveTo(shizlib.hud.ScrW / 2 - s(200), shizlib.hud.ScrH / 2 - s(125), .4, 0)
    function frame:Paint(w, h)
        RNDX.Draw(8, 0, 0, w, h, theme.bg, RNDX.SHAPE_FIGMA)
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
    frame.mtitle:SetText("Арест")
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

    local combo = vgui.Create("DComboBox", frame)
    combo:Dock(TOP)
    combo:DockMargin(s(40), s(26), s(40), s(16))
    combo:SetText("Выберите игрока")

    for _, plyData in ipairs(players) do
        local ply = Player(plyData.id)
        if ply == LocalPlayer() then continue end
        combo:AddChoice(plyData.name .. ' (' ..ply:GetNWInt('UniqID', 1) .. ')', plyData.id)
    end

    local slider = vgui.Create("DNumSlider", frame)
    slider:Dock(TOP)
    slider:DockMargin(s(40), s(0), s(40), s(0))
    slider:SetText("Время ареста (сек)")
    slider:SetMin(120)
    slider:SetMax(1800)
    slider:SetDecimals(0)
    slider:SetValue(120)

    local textEntry = vgui.Create("DTextEntry", frame)
    textEntry:Dock(TOP)
    textEntry:DockMargin(s(40), s(16), s(40), s(16))
    textEntry:SetTall(s(20))
    textEntry:SetText("Причина ареста")
    textEntry:SetTooltip("Введите причину ареста")

    local button = vgui.Create("DButton", frame)
    button:Dock(BOTTOM)
    button:DockMargin(s(37), s(37), s(37), s(37))
    button:SetTall(s(60))
    button:SetText("")
    function button:Paint(w, h)
        local isHovered = self:IsHovered()
        local firstColor = isHovered and color_black or color_white
        local secondColor = isHovered and color_white or Color(32,32,32)

        RNDX.Draw(8,0,0,w,h,secondColor)

        RNDX.Draw(4,s(10),s(10),s(40),s(40),Color(24,24,24))
        DTR(s(24),s(26),s(12),s(12), color_white, mat1)

        draw.SimpleText('Арестовать','IB_20',s(69),h/2,firstColor,0,1)
    end
    button.DoClick = function()
        local _, userID = combo:GetSelected()
        local time = math.Round(slider:GetValue())
        local reason = textEntry:GetValue()

        if time < 120 or time > 1800 then
            chat.AddText(Color(255, 0, 0), "Укажите время ареста!")
            return
        end

        if userID == nil then
            chat.AddText(Color(255, 0, 0), "Выберите игрока!")
            return
        end

        if not reason or reason == "" or reason == "Причина ареста" then
            chat.AddText(Color(255, 0, 0), "Напишите причину!")
            return 
        end

        net.Start("RequestArrestPlayer")
            net.WriteEntity(npc)
            net.WriteUInt(userID, 16)
            net.WriteUInt(time, 16)
            net.WriteString(reason)
        net.SendToServer()
        frame:Remove()
    end
end)