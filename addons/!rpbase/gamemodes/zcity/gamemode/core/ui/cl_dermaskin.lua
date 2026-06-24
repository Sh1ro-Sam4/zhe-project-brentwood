hg.VGUI = hg.VGUI or {}
hg.VGUI.MainColor = CFG.theme.accent

hook.Add("ForceDermaSkin", "rp-skin", function()
	return "RP"
end)

local zw_font = ConVarExists("zw_font") and GetConVar("zw_font") or CreateClientConVar("zw_font", "Suboleya", true, false, "")
local font = function()
    local usefont = "Suboleya"
    if zw_font:GetString() != "" then
        usefont = zw_font:GetString()
    end
    return usefont
end

surface.CreateFont("ZCity_VerySuperTiny", { font = font(), size = ScreenScale(5), weight = 200, antialias = true, extended = true })
surface.CreateFont("ZCity_SuperTiny", { font = font(), size = ScreenScale(6), weight = 200, antialias = true, extended = true })
surface.CreateFont("ZCity_Fixed_SuperTiny", { font = 18, weight = 200, antialias = true, extended = true })
surface.CreateFont("ZCity_Tiny", { font = font(), size = ScreenScale(8), weight = 200, antialias = true, extended = true })
surface.CreateFont("ZCity_Fixed_Tiny", { font = font(), size = 25, weight = 200, antialias = true, extended = true })
surface.CreateFont("ZCity_Small", { font = font(), size = ScreenScale(15), weight = 200, antialias = true, extended = true })
surface.CreateFont("ZCity_Medium", { font = font(), size = ScreenScale(25), weight = 200, antialias = true, extended = true })
surface.CreateFont("ZCity_Fixed_Medium", { font = font(), size = 55, weight = 200, antialias = true, extended = true })
surface.CreateFont("ZCity_Big", { font = font(), size = ScreenScale(35), weight = 200, antialias = true, extended = true })
surface.CreateFont("ZCity_Fixed_Big", { font = font(), size = 300, weight = 200, antialias = true, extended = true })
surface.CreateFont("ZCity_Fixed_Medium_Light", { font = font(), size = 25, weight = 200, antialias = true, extended = true })
surface.CreateFont("ZCity_Fixed_Medium_Light_Blur", { font = font(), size = 25, weight = 200, blursize = 4, antialias = true, extended = true })
surface.CreateFont("ZCity_Fixed_Icons_Small", { font = font(), size = 22, weight = 500, antialias = true, extended = true })

local THEME = CFG.theme or {}
local COLOR_BG = THEME.bg or Color(20, 20, 20)
local COLOR_ACCENT = THEME.accent or Color(255, 77, 119)
local COLOR_TEXT = THEME.white or Color(220, 220, 220)
local COLOR_ALT = Color(25, 25, 30, 200)

local blurMat = Material("pp/blurscreen")
local function DrawBlur(panel, amount, passes)
    local x, y = panel:LocalToScreen(0, 0)
    local sw, sh = ScrW(), ScrH()
    surface.SetMaterial(blurMat)
    surface.SetDrawColor(255, 255, 255, 255)
    for i = 1, (passes or 3) do
        blurMat:SetFloat("$blur", (i / (passes or 3)) * (amount or 6))
        blurMat:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, sw, sh)
    end
end

local SKIN = {}
derma.DefineSkin("RP", "Modern RP skin based on F4.", SKIN)

SKIN.fontCategory = "ZCity_Fixed_Medium_Light"
SKIN.fontCategoryBlur = "ZCity_Fixed_Medium_Light_Blur"
SKIN.fontSegmentedProgress = "ZCity_Fixed_Medium_Light"

SKIN.Colours = table.Copy(derma.SkinList.Default.Colours)

SKIN.Colours.Outline = COLOR_ACCENT
SKIN.Colours.Background = COLOR_BG

SKIN.Colours.Label.Default = color_white
SKIN.Colours.Label.Highlight = color_white
SKIN.Colours.Label.Dark = color_white
SKIN.Colours.Label.Bright = color_white

SKIN.Colours.Button.Normal = color_white
SKIN.Colours.Button.Hover = color_white
SKIN.Colours.Button.Down = color_white
SKIN.Colours.Button.Disabled = Color(150, 150, 150)

SKIN.Colours.Tab.Active.Normal = color_white
SKIN.Colours.Tab.Active.Hover = color_white
SKIN.Colours.Tab.Active.Down = color_white
SKIN.Colours.Tab.Active.Disabled = color_white

SKIN.Colours.Tab.Inactive.Normal = color_white
SKIN.Colours.Tab.Inactive.Hover = color_white
SKIN.Colours.Tab.Inactive.Down = color_white
SKIN.Colours.Tab.Inactive.Disabled = color_white

SKIN.Colours.Tree.Normal = color_white
SKIN.Colours.Tree.Hover = color_white
SKIN.Colours.Tree.Selected = color_white

SKIN.Colours.Window.TitleActive = color_white
SKIN.Colours.Window.TitleInactive = color_white

SKIN.Colours.Category = SKIN.Colours.Category or {}
SKIN.Colours.Category.Header = color_white
SKIN.Colours.Category.Header_Closed = color_white

SKIN.Colours.Category.Line.Text = color_white
SKIN.Colours.Category.Line.Text_Hover = color_white
SKIN.Colours.Category.Line.Text_Selected = color_white

SKIN.Colours.Category.LineAlt.Text = color_white
SKIN.Colours.Category.LineAlt.Text_Hover = color_white
SKIN.Colours.Category.LineAlt.Text_Selected = color_white

SKIN.Colours.TooltipText = color_black

function SKIN:PaintFrame(panel, w, h)
	if not panel.bNoBackgroundBlur then hg.DrawBlur(panel, 6, 3) end
	draw.RoundedBox(12, 0, 0, w, h, COLOR_BG)
    draw.RoundedBox(12, 0, 0, w, h, Color(255, 255, 255, 5))
end

function SKIN:PaintBaseFrame(panel, w, h)
	if not panel.bNoBackgroundBlur then hg.DrawBlur(panel, 6, 3) end
	draw.RoundedBox(12, 0, 0, w, h, COLOR_BG)
end

function SKIN:PaintPanel(panel, w, h)
	if panel.m_bBackground then draw.RoundedBox(8, 0, 0, w, h, panel.m_bgColor or COLOR_ALT) end
end

function SKIN:PaintButton(panel, w, h)
	if not panel.m_bBackground then return end

    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, panel:IsHovered() and 1 or 0)

    local offset = panel:GetDisabled() and 0 or (panel:IsDown() and 2 or 0)

    draw.RoundedBox(8, 0, offset, w, h - offset, COLOR_ALT)
    
    if panel.lerpHover > 0 and not panel:GetDisabled() then
        draw.RoundedBox(8, 0, offset, w, h - offset, ColorAlpha(COLOR_ACCENT, 20 * panel.lerpHover))
    end
end

function SKIN:PaintWindowCloseButton(panel, w, h)
	if not panel.m_bBackground then return end
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 10, panel.lerpHover, panel:IsHovered() and 1 or 0)

    local col = Color(
        Lerp(panel.lerpHover, 255, 255),
        Lerp(panel.lerpHover, 255, 80),
        Lerp(panel.lerpHover, 255, 80)
    )
	draw.SimpleText("✕", "ZCity_Fixed_Icons_Small", w / 2, h / 2, col, 1, 1)
end

function SKIN:PaintTextEntry(panel, w, h)
	if panel.m_bBackground then
        draw.RoundedBox(8, 0, 0, w, h, COLOR_ALT)
		if panel:HasFocus() then
            draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(COLOR_ACCENT, 10))
		end
	end
	panel:DrawTextEntryText(color_white, COLOR_ACCENT, color_white)
end

function SKIN:PaintComboBox(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 10, panel.lerpHover, panel:IsHovered() and 1 or 0)

    draw.RoundedBox(8, 0, 0, w, h, COLOR_ALT)
    if panel.lerpHover > 0 then
        draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(COLOR_ACCENT, 15 * panel.lerpHover))
    end
end

function SKIN:PaintComboDownArrow(panel, w, h)
	surface.SetDrawColor(color_white)
    draw.NoTexture()
    surface.DrawPoly({
        {x = 0, y = w * 0.4},
        {x = h, y = 0},
        {x = h, y = w * 0.8}
    })
end

function SKIN:PaintCheckBox(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, panel:IsHovered() and 1 or 0)

    draw.RoundedBox(6, 0, 0, w, h, COLOR_ALT)
    
    if panel.lerpHover > 0 then
        draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(COLOR_ACCENT, 30 * panel.lerpHover))
    end

    if panel:GetChecked() then
        draw.RoundedBox(4, 4, 4, w - 8, h - 8, COLOR_ACCENT)
    end
end

function SKIN:PaintRadioButton(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, panel:IsHovered() and 1 or 0)

    draw.RoundedBox(w/2, 0, 0, w, h, COLOR_ALT)
    
    if panel.lerpHover > 0 then
        draw.RoundedBox(w/2, 0, 0, w, h, ColorAlpha(COLOR_ACCENT, 30 * panel.lerpHover))
    end

    if panel:GetChecked() then
        draw.RoundedBox((w-8)/2, 4, 4, w - 8, h - 8, COLOR_ACCENT)
    end
end

function SKIN:PaintSliderKnob(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, panel:IsHovered() and 1 or 0)

    draw.RoundedBox(w/2, 0, 0, w, h, COLOR_ALT)
    draw.RoundedBox((w-4)/2, 2, 2, w-4, h-4, COLOR_ACCENT)
    
    if panel.lerpHover > 0 then
        draw.RoundedBox((w-4)/2, 2, 2, w-4, h-4, Color(255,255,255, 40 * panel.lerpHover))
    end
end

function SKIN:PaintNumSlider(panel, w, h)
    draw.RoundedBox(2, 0, h/2 - 2, w, 4, COLOR_ALT)
end

function SKIN:PaintVScrollBar(panel, w, h) end

function SKIN:PaintScrollBarGrip(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 10, panel.lerpHover, panel:IsHovered() and 1 or 0)

    local alpha = 150 + (105 * panel.lerpHover)
    draw.RoundedBox(4, 2, 0, w - 4, h, ColorAlpha(COLOR_ACCENT, alpha))
end

function SKIN:PaintButtonUp(panel, w, h) 
    draw.RoundedBox(4, 0, 0, w, h, COLOR_ALT)
    draw.SimpleText("▲", "ZCity_SuperTiny", w/2, h/2, color_white, 1, 1)
end

function SKIN:PaintButtonDown(panel, w, h)
    draw.RoundedBox(4, 0, 0, w, h, COLOR_ALT)
    draw.SimpleText("▼", "ZCity_SuperTiny", w/2, h/2, color_white, 1, 1)
end

function SKIN:PaintListView(panel, w, h)
    draw.RoundedBox(8, 0, 0, w, h, COLOR_BG)
end

function SKIN:PaintListViewLine(panel, w, h)
    if panel:IsSelected() then
        draw.RoundedBox(4, 2, 0, w - 4, h, ColorAlpha(COLOR_ACCENT, 150))
    elseif panel:IsHovered() then
        draw.RoundedBox(4, 2, 0, w - 4, h, ColorAlpha(COLOR_ACCENT, 20))
    elseif panel.m_bAlt then
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 5))
    end
end

function SKIN:PaintListViewColumn(panel, w, h)
    draw.RoundedBox(0, 0, 0, w, h, COLOR_ALT)
    surface.SetDrawColor(COLOR_ACCENT)
    surface.DrawRect(0, h - 2, w, 2)
end

function SKIN:PaintPropertySheet(panel, w, h)
	draw.RoundedBox(12, 0, 0, w, h, COLOR_BG)
end

function SKIN:PaintTab(panel, w, h)
	local isActive = panel:IsActive()
    
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, panel:IsHovered() and 1 or 0)

    if isActive then
        draw.RoundedBox(0, 10, h - 4, w - 20, 4, COLOR_ACCENT)
    else
        if panel.lerpHover > 0 then
            draw.RoundedBox(8, 5, 5, w - 10, h - 10, Color(255, 255, 255, 8 * panel.lerpHover))
        end
    end
end

function SKIN:PaintActiveTab(panel, w, h) end

function SKIN:PaintCategoryList(panel, w, h) draw.RoundedBox(8, 0, 0, w, h, COLOR_ALT) end
function SKIN:PaintCollapsibleCategory(panel, w, h) draw.RoundedBox(8, 0, 0, w, h, COLOR_BG) end
function SKIN:PaintTree(panel, w, h) draw.RoundedBox(8, 0, 0, w, h, COLOR_ALT) end
function SKIN:PaintDTree(panel, w, h) draw.RoundedBox(8, 0, 0, w, h, COLOR_ALT) end

function SKIN:PaintCategoryButton(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 10, panel.lerpHover, panel:IsHovered() and 1 or 0)
    
    draw.RoundedBox(0, 0, 0, w, h, COLOR_ALT)
    if panel.lerpHover > 0 then
        draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(COLOR_ACCENT, 20 * panel.lerpHover))
    end
end

function SKIN:PaintExpandButton(panel, w, h)
    if not panel:GetExpanded() then
        draw.SimpleText("+", "ZCity_Fixed_Icons_Small", w/2, h/2 - 2, color_white, 1, 1)
    else
        draw.SimpleText("-", "ZCity_Fixed_Icons_Small", w/2, h/2 - 2, color_white, 1, 1)
    end
end

function SKIN:PaintTooltipBackground(panel, w, h)
    DrawBlur(panel, 4, 2)
	draw.RoundedBox(8, 0, 0, w, h, Color(15, 15, 15, 220))
end

function SKIN:PaintMenu(panel, w, h)
    DrawBlur(panel, 4, 2)
	draw.RoundedBox(8, 0, 0, w, h, COLOR_BG)
end

function SKIN:PaintMenuOption(panel, w, h)
	if panel.m_bBackground and (panel.Hovered or panel.Highlight) then
		draw.RoundedBox(4, 2, 0, w - 4, h, ColorAlpha(COLOR_ACCENT, 150))
	end
end

function SKIN:PaintFileBrowser(panel, w, h)
    draw.RoundedBox(8, 0, 0, w, h, COLOR_BG)
end

function SKIN:PaintTreeNodeButton(panel, w, h)
    if not panel.m_bSelectable then return end
    
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, panel:IsHovered() and 1 or 0)
    
    if panel:IsSelected() then
        draw.RoundedBox(4, 0, 0, w, h, ColorAlpha(COLOR_ACCENT, 150))
    elseif panel.lerpHover > 0 then
        draw.RoundedBox(4, 0, 0, w, h, ColorAlpha(COLOR_ACCENT, 20 * panel.lerpHover))
    end
end

function SKIN:PaintSelection(panel, w, h)
    draw.RoundedBox(4, 0, 0, w, h, ColorAlpha(COLOR_ACCENT, 150))
end

function SKIN:PaintDivider(panel, w, h)
    panel.lerpHover = panel.lerpHover or 0
    panel.lerpHover = Lerp(FrameTime() * 15, panel.lerpHover, panel:IsHovered() and 1 or 0)
    
    draw.RoundedBox(0, 0, 0, w, h, COLOR_BG)
    
    local dW = w > h and 30 or 4
    local dH = w > h and 4 or 30
    local dX = w / 2 - dW / 2
    local dY = h / 2 - dH / 2
    
    draw.RoundedBox(2, dX, dY, dW, dH, COLOR_ALT)
    
    if panel.lerpHover > 0 then
        draw.RoundedBox(2, dX, dY, dW, dH, ColorAlpha(COLOR_ACCENT, 150 * panel.lerpHover))
    end
end

derma.RefreshSkins()