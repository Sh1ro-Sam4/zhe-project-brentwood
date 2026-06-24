if SERVER then return end

hook.Remove("OnPauseMenuShow", "OpenMainMenu")
hook.Remove("OnPauseMenuShow", "BrentwoodEscape")
hook.Remove("Think", "MainMenu_MenuLerpCalc")
hook.Remove("Think", "Brentwood_MenuLerpCalc")
hook.Remove("StartCommand", "MainMenu_BlockMovement")
hook.Remove("StartCommand", "Brentwood_BlockMovement")
hook.Remove("HUDShouldDraw", "MainMenu_HideHUD")
hook.Remove("HUDShouldDraw", "Brentwood_HideHUD")
hook.Remove("PreDrawViewModel", "MainMenu_HideVM")
hook.Remove("PreDrawViewModel", "Brentwood_HideVM")
hook.Remove("CalcView", "MainMenu_CinematicView")
hook.Remove("PostHGCalcView", "MainMenu_CinematicView")
hook.Remove("ShouldDrawLocalPlayer", "MainMenu_DrawPlayer")
hook.Remove("RenderScreenspaceEffects", "MainMenu_CinematicColor")
hook.Remove("RenderScreenspaceEffects", "Brentwood_CinematicColor")

if IsValid(MainMenu) then
    MainMenu:Remove()
    MainMenu = nil
end

local ipairs = ipairs
local IsValid = IsValid
local LocalPlayer = LocalPlayer
local ScrW = ScrW
local ScrH = ScrH
local Vector = Vector
local Angle = Angle
local Lerp = Lerp
local FrameTime = FrameTime
local CurTime = CurTime
local math = math
local gui = gui
local draw = draw
local surface = surface
local RunConsoleCommand = RunConsoleCommand
local vgui = vgui
local hook = hook
local render = render
local Color = Color
local ScreenScaleH = ScreenScaleH
local LerpVector = LerpVector
local LerpAngle = LerpAngle
local util = util

MainMenuOpen = false
MainMenuLerp = 0

local THEME_ACCENT = Color(255, 77, 119)
local THEME_BG = Color(22, 22, 22)

local function UpdateThemeColors()
    THEME_ACCENT = (CFG and CFG.theme and CFG.theme.accent) or Color(255, 77, 119)
    THEME_BG = (CFG and CFG.theme and CFG.theme.bg) or Color(22, 22, 22)
end

local Selects = {
    {Title = "Продолжить",      Func = function(luaMenu) luaMenu:Close() end},
    {Title = "Одежда",  Func = function(luaMenu) luaMenu:Close() RunConsoleCommand("hg_appearance_menu") end},
    {Title = "Правила",     Func = function(luaMenu) luaMenu:Close() gui.OpenURL("https://docs.google.com/document/d/1bKF7lr-u2FvWsw_Z5iQH7KtEhkORszVJ33g2FT7TCf4/edit?usp=sharing") end},
    {Title = "Дискорд",     Func = function(luaMenu) luaMenu:Close() gui.OpenURL("https://discord.gg/cSmhecewkY") end},
    {Title = "Настройки",    Func = function(luaMenu) luaMenu:Close() RunConsoleCommand("hg_settings") end},
    {Title = "Главное меню",   Func = function(luaMenu) gui.ActivateGameUI() luaMenu:Close() end},
    {Title = "Переподключиться", Func = function(luaMenu)
        if not LocalPlayer():GetPos():WithinAABox(Vector(-3847, 3237, 211), Vector(-3216, 2354, -100)) then
            shizlib.request.bool("Выход", "Вы уверены что хотите переподключиться тут?\nЕсли вы переподключитесь тут, то ваш персонаж умрет\nи вы потеряете все вещи из инвентаря!\n\nВернитесь на вокзал чтобы этого избежать!", function()
                RunConsoleCommand("retry")
            end)
        else
            RunConsoleCommand("retry")
        end
    end},
    {Title = "Отключится", Func = function(luaMenu)
        if not LocalPlayer():GetPos():WithinAABox(Vector(-3847, 3237, 211), Vector(-3216, 2354, -100)) then
            shizlib.request.bool("Выход", "Вы уверены что хотите покинуть сервер тут?\nЕсли вы покините сервер тут, то ваш персонаж умрет\nи вы потеряете все вещи из инвентаря!\n\nВернитесь на вокзал чтобы этого избежать!", function()
                RunConsoleCommand("disconnect")
            end)
        else
            RunConsoleCommand("disconnect")
        end
    end},
}

local PANEL = {}
local cached_tw1, cached_th
local color_black_200 = Color(0, 0, 0, 200)

local function drawShadowText(text, font, x, y, col, xalign, yalign)
    draw.SimpleText(text, font, x + 2, y + 2, color_black_200, xalign, yalign)
    draw.SimpleText(text, font, x, y, col, xalign, yalign)
end

function PANEL:InitializeMarkup()
    local colorText = "255,77,119"
    local text = "<font=ZC_MM_Title><colour=" .. colorText .. ">BRENT</colour>WOOD</font>"
    return markup.Parse(text)
end

function PANEL:Init()
    UpdateThemeColors()
    self:SetSize(ScrW(), ScrH())
    self:Center()
    self:MakePopup()
    self:SetKeyboardInputEnabled(false) 
    self:SetAlpha(0)
    self:AlphaTo(255, 0.2, 0)

    MainMenuOpen = true
    
    surface.SetFont("ZC_MM_Title")
    cached_tw1, cached_th = surface.GetTextSize("BRENT")

    self.ButtonList = vgui.Create("DPanel", self)
    self.ButtonList:SetSize(ScrW() * 0.25, ScrH() * 0.6)
    self.ButtonList:SetPos(-self.ButtonList:GetWide(), ScrH() * 0.28) 
    self.ButtonList.Paint = shizlib.func.zero

    self.Buttons = {}
    for _, v in ipairs(Selects) do
        self:AddSelect(self.ButtonList, v.Title, v)
    end

    self.SubAuthors = vgui.Create("DLabel", self)
    self.SubAuthors:Dock(BOTTOM)
    self.SubAuthors:SetFont("ui.14")
    self.SubAuthors:SetText("Reducted by: Kasanov")
    self.SubAuthors:SetContentAlignment(5)
    self.SubAuthors:DockMargin(0, 0, 0, 2)

    self.Git = vgui.Create("DLabel", self)
    self.Git:Dock(BOTTOM)
    self.Git:SetFont("ui.14")
    self.Git:SetText("GitHub: https://github.com/Sh1ro-Sam4/z-project-brentwood")
    self.Git:SetContentAlignment(5)
    self.Git:DockMargin(0, 0, 0, 2)

    self.Authors = vgui.Create("DLabel", self)
    self.Authors:Dock(BOTTOM)
    self.Authors:SetFont("ui.14")
    self.Authors:SetText("Authors: uzelezz, Sadsalat, Mr.Point, Zac90, Deka, Mannytko")
    self.Authors:SetContentAlignment(5)
    self.Authors:DockMargin(0, 0, 0, 4)
end

-- Вся логика плавности теперь тут и работает только при открытом меню
function PANEL:Think()
    local ft = FrameTime() * 5
    if MainMenuOpen then
        MainMenuLerp = math.Approach(MainMenuLerp, 1, ft)
    else
        MainMenuLerp = math.Approach(MainMenuLerp, 0, ft)
    end

    local ease = math.ease.OutExpo(MainMenuLerp) 
    if IsValid(self.ButtonList) then
        self.ButtonList:SetPos(Lerp(ease, -self.ButtonList:GetWide(), ScrW() * 0.015), ScrH() * 0.28)
    end

    local alpha = 25 * MainMenuLerp
    local clr_gray = Color(255, 255, 255, alpha)
    
    if IsValid(self.Authors) then self.Authors:SetTextColor(clr_gray) end
    if IsValid(self.Git) then self.Git:SetTextColor(clr_gray) end
    if IsValid(self.SubAuthors) then self.SubAuthors:SetTextColor(clr_gray) end
end

local col_white = Color(255, 255, 255, 0)
local col_accent = Color(0, 0, 0, 0)

function PANEL:Paint(w, h)
    local ease = math.ease.OutExpo(MainMenuLerp)
    local panelWidth = w * 0.38 

    if MainMenuLerp > 0.01 and hg and hg.DrawBlur then
        render.SetScissorRect(0, 0, panelWidth, h, true)
            hg.DrawBlur(self, 5 * MainMenuLerp)
        render.SetScissorRect(0, 0, 0, 0, false)
    end

    surface.SetDrawColor(THEME_BG.r, THEME_BG.g, THEME_BG.b, 210 * MainMenuLerp)
    surface.DrawRect(0, 0, panelWidth, h)

    surface.SetDrawColor(THEME_ACCENT.r, THEME_ACCENT.g, THEME_ACCENT.b, 180 * MainMenuLerp)
    surface.DrawRect(panelWidth, 0, shizlib.surface.s(1), h) 

    surface.SetDrawColor(0, 0, 0, 30 * MainMenuLerp)
    surface.DrawRect(panelWidth + shizlib.surface.s(1), 0, w - panelWidth, h)
    
    local barHeight = math.ceil((h * 0.08) * ease)
    surface.SetDrawColor(0, 0, 0, 255 * MainMenuLerp)
    surface.DrawRect(0, 0, w, barHeight) 
    surface.DrawRect(0, h - barHeight, w, barHeight) 

    local titleX = Lerp(ease, -w * 0.2, w * 0.015) 
    local titleY = h * 0.17 
    local alpha = 255 * ease

    col_white.a = alpha
    col_accent.r, col_accent.g, col_accent.b, col_accent.a = THEME_ACCENT.r, THEME_ACCENT.g, THEME_ACCENT.b, alpha

    drawShadowText("BRENT", "ZC_MM_Title", titleX, titleY, col_accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    drawShadowText("WOOD", "ZC_MM_Title", titleX + cached_tw1, titleY, col_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:AddSelect(pParent, strTitle, tbl)
    local id = #self.Buttons + 1

    local btn = vgui.Create("DButton", pParent)
    self.Buttons[id] = btn

    btn:SetText("")
    btn:SetTall(math.max(ScreenScaleH(24), 28))
    btn:Dock(TOP)
    btn:DockMargin(0, 0, 0, ScreenScaleH(4))

    btn.btnColorCache = Color(225, 225, 225, 255)
    btn.hoverLerp = 0
    btn.hoveredState = false

    local luaMenu = self

    btn.Func = tbl.Func
    btn.HoveredFunc = tbl.HoveredFunc
    if tbl.CreatedFunc then tbl.CreatedFunc(btn, self, luaMenu) end

    btn.DoClick = function()
        surface.PlaySound("garrysmod/ui_click.wav")
        if btn.Func then 
            btn.Func(luaMenu) 
        end
    end

    btn.Paint = function(s, w, h)
        s.hoverLerp = Lerp(FrameTime() * 12, s.hoverLerp or 0, s:IsHovered() and 1 or 0)
        
        s.btnColorCache.r = Lerp(s.hoverLerp, 225, THEME_ACCENT.r)
        s.btnColorCache.g = Lerp(s.hoverLerp, 225, THEME_ACCENT.g)
        s.btnColorCache.b = Lerp(s.hoverLerp, 225, THEME_ACCENT.b)
        s.btnColorCache.a = Lerp(s.hoverLerp, 200, 255)

        if s:IsHovered() then
            if not s.hoveredState then
                s.hoveredState = true
                surface.PlaySound("garrysmod/ui_hover.wav")
            end
        else
            s.hoveredState = false
        end

        local textOffset = Lerp(s.hoverLerp, 0, shizlib.surface.s(6)) + shizlib.surface.s(10)
        local barHeight = h * 0.5

        surface.SetDrawColor(THEME_ACCENT.r, THEME_ACCENT.g, THEME_ACCENT.b, s.hoverLerp * 255)
        surface.DrawRect(0, (h / 2) - (barHeight / 2), shizlib.surface.s(1.5), barHeight)

        drawShadowText(strTitle, "ZCity_Small", textOffset, h/2, s.btnColorCache, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    return btn
end

function PANEL:Close()
    MainMenuOpen = false
    self:AlphaTo(0, 0.2, 0, function() 
        self:Remove() 
        MainMenuLerp = 0 -- Сбрасываем значение при удалении
    end)
    gui.EnableScreenClicker(false)
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(false)
end

vgui.Register("MainMenu", PANEL, "EditablePanel")

hook.Add("StartCommand", "MainMenu_BlockMovement", function(ply, cmd)
    if MainMenuOpen then
        cmd:ClearMovement()
        cmd:ClearButtons()
    end
end)

hook.Add("HUDShouldDraw", "MainMenu_HideHUD", function(name)
    if MainMenuLerp > 0.01 then return false end
end)

hook.Add("PreDrawViewModel", "MainMenu_HideVM", function()
    if MainMenuLerp > 0.01 then return true end
end)

local viewData = { origin = Vector(), angles = Angle(), fov = 0, drawviewer = true }
local trace_config = { mins = Vector(-10, -10, -10), maxs = Vector(10, 10, 10) }

local function GetCinematicView(ply, pos, angles, fov)
    if ply:Alive() then
        if IsValid(ply.FakeRagdoll) or IsValid(ply:GetNWEntity("FakeRagdoll")) or ply:IsRagdoll() then
            return
        end

        local flatAng = Angle(0, ply:EyeAngles().y, 0)
        local targetPos = ply:GetPos() + Vector(0, 0, 45) + flatAng:Forward() * 110
        local lookAtPos = ply:GetPos() + Vector(0, 0, 45)
        local targetAng = (lookAtPos - targetPos):Angle()
        
        targetAng.y = targetAng.y + 25 
        targetPos.z = targetPos.z + math.sin(CurTime() * 0.5) * 2
        
        trace_config.start = pos
        trace_config.endpos = targetPos
        trace_config.filter = ply
        local tr = util.TraceHull(trace_config)
        targetPos = tr.HitPos + tr.HitNormal * 5 

        local ease = math.ease.InOutCubic(MainMenuLerp)
        viewData.origin = LerpVector(ease, pos, targetPos)
        viewData.angles = LerpAngle(ease, angles, targetAng)
        viewData.fov = fov - (15 * MainMenuLerp)
        viewData.drawviewer = true 
        return viewData
    end
end

-- Изменено: Модифицируем вид после хуков Homigrad
hook.Add("PostHGCalcView", "MainMenu_CinematicView", function(ply, view)
    if MainMenuLerp > 0.01 then
        local cinematicView = GetCinematicView(ply, view.origin, view.angles, view.fov)
        if cinematicView then
            view.origin = cinematicView.origin
            view.angles = cinematicView.angles
            view.fov = cinematicView.fov
            view.drawviewer = true
        end
    end
end)

hook.Add("ShouldDrawLocalPlayer", "MainMenu_DrawPlayer", function(ply)
    if MainMenuLerp > 0.01 and not (IsValid(ply.FakeRagdoll) or IsValid(ply:GetNWEntity("FakeRagdoll")) or ply:IsRagdoll()) then
        return true
    end
end)

local color_mod = { ["$pp_colour_addr"] = 0, ["$pp_colour_addg"] = 0, ["$pp_colour_addb"] = 0, ["$pp_colour_brightness"] = 0, ["$pp_colour_contrast"] = 1, ["$pp_colour_colour"] = 1, ["$pp_colour_mulr"] = 0, ["$pp_colour_mulg"] = 0, ["$pp_colour_mulb"] = 0 }
hook.Add("RenderScreenspaceEffects", "MainMenu_CinematicColor", function()
    if MainMenuLerp > 0.01 then
        color_mod["$pp_colour_addb"] = 0.01 * MainMenuLerp
        color_mod["$pp_colour_brightness"] = -0.01 * MainMenuLerp
        color_mod["$pp_colour_contrast"] = 1 + (0.05 * MainMenuLerp)
        color_mod["$pp_colour_colour"] = 1 - (0.15 * MainMenuLerp)
        DrawColorModify(color_mod)
    end
end)

local function CanOpenEscapeMenu()
    local ply = LocalPlayer()
    if not IsValid(ply) then return false end
    if ply:IsTyping() then return false end

    if IsValid(zpan) then return false end
    if IsValid(plyMenu) then return false end
    if IsValid(hg.armorMenuPanel) then return false end
    if IsValid(hg_getanim) then return false end

    if vgui.CursorVisible() and not IsValid(MainMenu) then
        return false
    end

    return true
end

hook.Add("OnPauseMenuShow", "OpenMainMenu", function()
    local run = hook.Run("OnShowZCityPause")
    if run then
        return run
    end

    if MainMenu and IsValid(MainMenu) then
        MainMenu:Close()
        MainMenu = nil
        return false
    end

    if not CanOpenEscapeMenu() then
        return 
    end

    MainMenu = vgui.Create("MainMenu")
    MainMenu:MakePopup()
    return false
end)