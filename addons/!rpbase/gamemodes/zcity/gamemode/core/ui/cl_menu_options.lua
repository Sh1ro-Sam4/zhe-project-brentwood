local PANEL = {}

hg.settings = hg.settings or {}
hg.settings.tbl = hg.settings.tbl or {}

function hg.settings:AddOpt( strCategory, strConVar, strTitle, strDesc, bDecimals, bString )
    self.tbl[strCategory] = self.tbl[strCategory] or {}
    self.tbl[strCategory][strConVar] = { 
        strCategory, 
        strConVar, 
        strTitle, 
        strDesc or "",
        bDecimals or false, 
        bString or false,
    }
end


hg.settings:AddOpt("Оптимизация","hg_anims_draw_distance", "Дистанция отрисовки анимаций", '')
hg.settings:AddOpt("Оптимизация","hg_anim_fps", "FPS анимаций", '')
hg.settings:AddOpt("Оптимизация","hg_attachment_draw_distance", "Дистанция отрисовки обвесов", '')
hg.settings:AddOpt("Оптимизация","hg_maxsmoketrails", "Макс. количество дымовых следов", '')
hg.settings:AddOpt("Оптимизация","hg_tpik_distance", "Дистанция рендера TPIK", '')

hg.settings:AddOpt("Оптимизация","hg_blood_draw_distance", "Дистанция отрисовки крови", '')
hg.settings:AddOpt("Оптимизация","hg_blood_fps", "FPS эффектов крови", '')
hg.settings:AddOpt("Оптимизация","hg_old_blood", "Старая текстура крови", '')

hg.settings:AddOpt("Оружие","hg_weaponshotblur_enable", "Размытие при стрельбе", '')
hg.settings:AddOpt("Оружие","hg_dynamic_mags", "Динамический осмотр патронов", '')
hg.settings:AddOpt("Оружие","hg_zoomsensitivity", "Чувствительность прицела", '')

hg.settings:AddOpt("Интерфейс","zw_font", "Сменить шрифт", '', false, true)
hg.settings:AddOpt("Интерфейс","hg_ws_mode", "Новый селектор оружия", '')

hg.settings:AddOpt("Вид","hg_firstperson_death", "Смерть от первого лица", '')
hg.settings:AddOpt("Вид","hg_fov", "Угол обзора (FOV)", '')
hg.settings:AddOpt("Вид","hg_nofovzoom", "Зум при изменении FOV", '')
hg.settings:AddOpt("Вид","hg_leancam_mul", "Множитель наклона камеры", '')
hg.settings:AddOpt("Вид","hg_eyes_enabled", "Вкл./Выкл. моргание", '')
hg.settings:AddOpt("Вид","hg_gopro", "Вкл./Выкл. GoPro", '')

--hg.settings:AddOpt("Sound","hg_dmusic", "Dynamic Music", '')


local s = shizlib.surface.s
local DTR = shizlib.surface.DTR
local RNDX = include("shizlib/client/rndx_cl.lua") or RNDX
local theme = CFG.theme
local color_white = Color(255, 255, 255)
local color_black = Color(0, 0, 0)

function PANEL:Init()
    self:SetAlpha( 0 )
    self:SetSize( ScrW()*1, ScrH()*1 )
    self:SetY( ScrH() )
    self:SetX( ScrW() / 2 - self:GetWide() / 2 )
    
    self.Options = {}

    timer.Simple(0, function()
        if IsValid(self) then self:First() end
    end)

    self.mtitle = self:Add("DLabel")
    self.mtitle:SetPos(s(50), s(30))
    self.mtitle:SetText("Настройки")
    self.mtitle:SetFont("IB_25")
    self.mtitle:SetTextColor(color_white)
    self.mtitle:SizeToContents()

    self.cls = self:Add("DButton")
    self.cls:SetPos(self:GetWide() - s(120), s(30))
    self.cls:SetSize(s(95), s(26))
    self.cls:SetText("")
    self.cls.lerpHover = 0
    self.cls.Paint = function(me, w, h)
        me.lerpHover = math.Approach(me.lerpHover, me:IsHovered() and 1 or 0, FrameTime()*5)
        draw.RoundedBox(6, 0, 0, w, h, shizlib.surface.LerpColor(me.lerpHover, Color(255,255,255,0), color_white))
        draw.RoundedBox(5, w - s(38), 0, s(38), h, color_white)
        draw.SimpleText("Выход", "IB_14", s(5), h*.5, shizlib.surface.LerpColor(me.lerpHover, color_white, color_black), 0, 1)
        draw.SimpleText("Esc", "IB_14", w - s(7), h*.5, color_black, 2, 1)
    end
    self.cls.DoClick = function() self:AlphaTo(0, 0.2, 0, function() self:Remove() end) end

    self.fDock = vgui.Create("DScrollPanel", self)
    self.fDock:Dock( FILL )
    self.fDock:DockMargin(s(40), s(100), s(40), s(40))

    local sbar = self.fDock:GetVBar()
    sbar:SetWide(s(4))
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 30))
    end
    
    for k,t in SortedPairs(hg.settings.tbl) do
        for _,tbl in SortedPairs(t) do
            local convar = GetConVar(tbl[2])
            if convar then
                self:CreateOption(
                    tbl[1],
                    convar:GetMax() == 1,
                    convar,
                    tbl[5],
                    tbl[3] or convar:GetName(),
                    tbl[4],
                    tbl[6]
                )
            end
        end
    end
end

function PANEL:First( ply )
    self:MoveTo(self:GetX(), ScrH() / 2 - self:GetTall() / 2, 0.4, 0, 0.2)
    self:AlphaTo( 255, 0.2, 0.1 )
end

function PANEL:Paint(w, h)
    RNDX.Draw(0, 0, 0, w, h, theme.bg, RNDX.SHAPE_FIGMA)
end

function PANEL:CreateCategory( strCategory )
    if not self.Options[strCategory] then
        local category = vgui.Create("DLabel", self.fDock)
        category:Dock( TOP )
        category:SetTall(s(40))
        category:SetText(strCategory:upper())
        category:SetFont("IB_25")
        category:SetTextColor(Color(255, 255, 255, 150))
        category:DockMargin(s(15), s(20), s(15), s(5))
        
        self.Options[strCategory] = true
    end
end

function PANEL:CreateOption( strCategory, bType, cConVar, bDecimals, strTitle, strDesc, bString )
    self:CreateCategory( strCategory )
    
    local hasDesc = strDesc and strDesc != ""
    local opt = vgui.Create("DPanel", self.fDock)
    opt:Dock( TOP )
    opt:SetTall( hasDesc and s(65) or s(50))
    opt:DockMargin(s(10), s(2), s(10), s(2))
    
    opt.lerp = 0
    function opt:Paint(w, h)
        local hovered = self:IsHovered() or self:IsChildHovered()
        self.lerp = math.Approach(self.lerp, hovered and 1 or 0, FrameTime()*5)
        local col = shizlib.surface.LerpColor(self.lerp, Color(32, 32, 32), Color(45, 45, 45))
        RNDX.Draw(8, 0, 0, w, h, col, RNDX.SHAPE_FIGMA)
    end

    local txtContainer = vgui.Create("DPanel", opt)
    txtContainer:Dock(FILL)
    txtContainer:SetPaintBackground(false)
    txtContainer:DockMargin(s(20), hasDesc and s(10) or s(15), 0, 0)

    local NLbl = vgui.Create("DLabel", txtContainer)
    NLbl:SetText( strTitle )
    NLbl:SetFont("IB_16")
    NLbl:Dock(TOP)
    NLbl:SetTextColor(color_white)
    NLbl:SizeToContents()

    if hasDesc then
        local DLbl = vgui.Create("DLabel", txtContainer)
        DLbl:SetText( strDesc )
        DLbl:SetFont("IB_12")
        DLbl:Dock(TOP)
        DLbl:SetTextColor(Color(180, 180, 180))
        DLbl:SizeToContents()
    end

    if bString then
        local TextInput = vgui.Create("DTextEntry", opt)
        TextInput:SetSize( s(150), s(30) )
        TextInput:Dock( RIGHT )
        TextInput:DockMargin( 0, s(12), s(20), s(12) )
        TextInput:SetFont("IB_14")
        TextInput:SetText(cConVar:GetString())
        function TextInput:OnEnter(val) cConVar:SetString(val) end

    elseif bType then
        local btn = vgui.Create("DButton", opt)
        btn:SetSize( s(50), s(26) )
        btn:Dock( RIGHT )
        btn:DockMargin( 0, s(12), s(20), s(12) )
        btn:SetText("")
        
        btn.lerp = cConVar:GetBool() and 1 or 0
        function btn:Paint(w, h)
            local on = cConVar:GetBool()
            self.lerp = math.Approach(self.lerp, on and 1 or 0, FrameTime()*8)
            draw.RoundedBox(h/2, 0, 0, w, h, Color(20, 20, 20))
            local dotSize = h - 6
            local xPos = Lerp(self.lerp, 3, w - dotSize - 3)
            local dotCol = shizlib.surface.LerpColor(self.lerp, Color(200, 60, 60), Color(60, 200, 60))
            draw.RoundedBox(dotSize/2, xPos, 3, dotSize, dotSize, dotCol)
        end
        function btn:DoClick()
            cConVar:SetBool(!cConVar:GetBool())
        end
    else
        local Slid = vgui.Create( "DNumSlider", opt )
        Slid:SetSize( s(250), 0 )
        Slid:Dock( RIGHT )
        Slid:DockMargin( 0, 0, s(20), 0 )
        Slid:SetMin( cConVar:GetMin() or 0 )
        Slid:SetMax( cConVar:GetMax() or 100 )
        Slid:SetDecimals( bDecimals and 2 or 0 )
        Slid:SetConVar( cConVar:GetName() )
        Slid.Label:SetVisible(false)
        Slid.TextArea:SetFont("IB_14")
        Slid.TextArea:SetTextColor(color_white)
    end
end

function PANEL:IsChildHovered()
    for _, child in ipairs(self:GetChildren()) do
        if child:IsHovered() then return true end
        for _, subchild in ipairs(child:GetChildren()) do
            if subchild:IsHovered() then return true end
        end
    end
    return false
end

vgui.Register( "ZOptions", PANEL, "EditablePanel")

concommand.Add("hg_settings", function()
    if hg_options and IsValid(hg_options) then hg_options:Remove() end
    hg_options = vgui.Create("ZOptions") 
    hg_options:MakePopup()
end)