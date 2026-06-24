include("shared.lua")

local color_white = Color(255, 255, 255)
local color_black = Color(0, 0, 0)
local complex_off = Vector(0, 0, 9)

function ENT:CalculateRenderPos()
    local vec = self:GetAngles():Forward() * 9 + self:GetAngles():Right() * -1 + self:GetAngles():Up() * 20
    local pos = self:GetPos() + vec
    return pos
end

function ENT:CalculateRenderAng()
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)
    return ang
end

function ENT:Draw()
    self:DrawModel()

    local pos, ang = self:CalculateRenderPos(), self:CalculateRenderAng()
    local dist = LocalPlayer():GetPos():Distance(self:GetPos())
    local inView = dist <= 500
    if not inView then return end

    local alpha = 255 - (dist / 2)
    color_white.a = alpha
    color_black.a = alpha

    local x = math.sin(CurTime() * math.pi) * 0

    cam.Start3D2D(pos, ang, 0.03)
        draw.SimpleTextOutlined('Арсенал', '3d2d', 0, x, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
    cam.End3D2D()
end

local s = shizlib.surface.s
local DTR = shizlib.surface.DTR
local RNDX = include("shizlib/client/rndx_cl.lua")
local mat1 = Material("rpui/check.png", "smooth mips")
local mat2 = Material("rpui/search.png", "smooth mips")

local frame = nil

net.Receive("OpenPoliceArsenal", function()
    local ent = net.ReadEntity()
    if ent:GetPos():Distance(LocalPlayer():GetPos()) > CFG.useDist then return end
    local theme = CFG.theme
    if frame and IsValid(frame) then frame:Remove() end

    frame = vgui.Create("EditablePanel")
    frame:SetSize(0, s(520))
    frame:Center()
    frame:MakePopup()
    frame:SizeTo(s(400), s(480), .4, 0)
    frame:MoveTo(shizlib.hud.ScrW / 2 - s(200), shizlib.hud.ScrH / 2 - s(240), .4, 0)
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
    frame.mtitle:SetText("Арсенал")
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

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)

    for idx, wep in pairs(ent.TableToGive) do
        local getString = ""
        for k, v in pairs(wep) do
            if k ~= "Category" then
                getString = getString .. " " .. v
            end
        end

        local button = vgui.Create("DButton", scroll)
        button:Dock(TOP)
        button:DockMargin(s(37), s(12), s(37), s(0))
        button:SetTall(s(50))
        button:SetText("")
        function button:Paint(w, h)
            local isHovered = self:IsHovered()
            local firstColor = isHovered and color_black or color_white
            local secondColor = isHovered and color_white or Color(32,32,32)

            RNDX.Draw(8,0,0,w,h,secondColor)

            RNDX.Draw(4,s(8),s(8),s(34),s(34),Color(24,24,24))
            DTR(s(19),s(20),s(12),s(12), color_white, mat1)

            draw.SimpleText(getString,'IB_16',s(55),h/2,firstColor,0,1)
        end
        button.DoClick = function()
            if ent:GetPos():Distance(LocalPlayer():GetPos()) > CFG.useDist then return end
            net.Start("SpawnWeapon")
                net.WriteUInt(idx, 8)
                net.WriteEntity(ent)
            net.SendToServer()
            frame:Remove()
        end
    end

    local clearBtn = vgui.Create("DButton", frame)
    clearBtn:Dock(BOTTOM)
    clearBtn:DockMargin(s(37), s(5), s(37), s(15))
    clearBtn:SetTall(s(45))
    clearBtn:SetText("")
    function clearBtn:Paint(w, h)
        local isHovered = self:IsHovered()
        local firstColor = isHovered and color_black or color_white
        local secondColor = isHovered and color_white or Color(32,32,32)
        RNDX.Draw(8,0,0,w,h,secondColor)
        draw.SimpleText('Сдать тяжелое оружие','IB_16',w/2,h/2,firstColor,1,1)
    end
    clearBtn.DoClick = function()
        net.Start("ClearArsenalWeapons")
        net.SendToServer()
        frame:Remove()
    end

    local medkitBtn = vgui.Create("DButton", frame)
    medkitBtn:Dock(BOTTOM)
    medkitBtn:DockMargin(s(37), s(5), s(37), s(5))
    medkitBtn:SetTall(s(45))
    medkitBtn:SetText("")
    function medkitBtn:Paint(w, h)
        local isHovered = self:IsHovered()
        local firstColor = isHovered and color_black or color_white
        local secondColor = isHovered and color_white or Color(32,32,32)
        RNDX.Draw(8,0,0,w,h,secondColor)
        draw.SimpleText('Пополнить медкомплект','IB_16',w/2,h/2,firstColor,1,1)
    end
    medkitBtn.DoClick = function()
        net.Start("RefillMedkit")
        net.SendToServer()
        frame:Remove()
    end

    local ammoBtn = vgui.Create("DButton", frame)
    ammoBtn:Dock(BOTTOM)
    ammoBtn:DockMargin(s(37), s(5), s(37), s(5))
    ammoBtn:SetTall(s(45))
    ammoBtn:SetText("")
    function ammoBtn:Paint(w, h)
        local isHovered = self:IsHovered()
        local firstColor = isHovered and color_black or color_white
        local secondColor = isHovered and color_white or Color(32,32,32)
        RNDX.Draw(8,0,0,w,h,secondColor)
        draw.SimpleText('Пополнить патроны','IB_16',w/2,h/2,firstColor,1,1)
    end
    ammoBtn.DoClick = function()
        net.Start("RefillAmmo")
        net.SendToServer()
        frame:Remove()
    end
end)