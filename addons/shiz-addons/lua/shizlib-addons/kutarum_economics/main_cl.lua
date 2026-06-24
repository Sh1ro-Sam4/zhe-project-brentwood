net.Receive( "KutEcon_Sync", function()
    ECONOMICS.BUDGET.amount = net.ReadFloat()
    ECONOMICS.Licenses = net.ReadTable()
    ECONOMICS.Taxes = net.ReadTable()
end )

local RNDX = include("shizlib/client/rndx_cl.lua")
local s = shizlib.surface.s

local colors = {
    bg = Color(15, 15, 15, 240),
    bg_alt = Color(25, 25, 25, 240),
    accent = Color(100, 150, 255),
    white = color_white,
    text_dark = Color(150, 150, 150),
    green = Color(77, 255, 126),
    red = Color(255, 80, 80)
}

surface.CreateFont("Mayor.Title", { font = "Roboto", size = s(25), weight = 500, extended = true })
surface.CreateFont("Mayor.Normal", { font = "Roboto", size = s(20), weight = 400, extended = true })
surface.CreateFont("Mayor.Small", { font = "Roboto", size = s(16), weight = 400, extended = true })

local draw_RoundedBox = draw.RoundedBox
local draw_RoundedBoxEx = draw.RoundedBoxEx
local draw_SimpleText = draw.SimpleText
local ColorAlpha = ColorAlpha
local Lerp = Lerp
local FrameTime = FrameTime
local tonumber = tonumber
local IsValid = IsValid

local function CreateStyledButton(parent, text, color, onClick)
    local btn = parent:Add("DButton")
    btn:SetTall(s(40))
    btn:Dock(TOP)
    btn:DockMargin(0, 0, 0, s(10))
    btn:SetText("")
    btn.hoverLerp = 0
    
    btn.Paint = function(self, w, h)
        self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
        
        local bgColor = ColorAlpha(color, 150 + (105 * self.hoverLerp))
        RNDX.Draw(s(8), 0, 0, w, h, bgColor)
        
        if self.hoverLerp > 0.01 then
            RNDX.Draw(s(8), 0, 0, w, h, ColorAlpha(colors.white, 20 * self.hoverLerp))
        end
        
        draw_SimpleText(text, "Mayor.Normal", w/2, h/2, colors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    btn.DoClick = onClick
    return btn
end

local function IsMayor(ply)
    return ply and IsValid(ply) and ply:GetPlayerClass() == TEAM_MAYOR
end

function OpenMayorMenu()
    if IsValid(MayorMenuFrame) then MayorMenuFrame:Remove() end

    MayorMenuFrame = vgui.Create("DFrame")
    local f = MayorMenuFrame
    f:SetSize(s(800), s(600))
    f:Center()
    f:SetTitle("")
    f:MakePopup()
    f:ShowCloseButton(false)
    f:SetAlpha(0)
    f:AlphaTo(255, 0.3, 0)
    
    f.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, self.m_fCreateTime)
        RNDX.Draw(s(12), 0, 0, w, h, colors.bg)
        draw_RoundedBoxEx(s(12), 0, 0, w, s(60), colors.bg_alt, true, true, false, false)
        
        draw_SimpleText("ПАНЕЛЬ УПРАВЛЕНИЯ МЭРА", "Mayor.Title", s(20), s(30), colors.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        local budget = math.floor(ECONOMICS.BUDGET.Get() or 0)
        draw_SimpleText("Казна: " .. budget .. "$", "Mayor.Title", w - s(20), s(30), colors.green, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    local closeBtn = f:Add("DButton")
    closeBtn:SetSize(s(40), s(40))
    closeBtn:SetPos(f:GetWide() - s(40), s(10))
    closeBtn:SetText("✕")
    closeBtn:SetFont("Mayor.Title")
    closeBtn:SetTextColor(colors.text_dark)
    closeBtn.Paint = function(self, w, h) end
    closeBtn.DoClick = function()
        f:AlphaTo(0, 0.2, 0, function() if IsValid(f) then f:Remove() end end)
    end

    local content = f:Add("DPanel")
    content:Dock(FILL)
    content:DockMargin(s(20), s(20), s(20), s(20))
    content.Paint = function() end

    local leftPanel = content:Add("DPanel")
    leftPanel:Dock(LEFT)
    leftPanel:SetWide(s(350))
    leftPanel.Paint = function() end

    local treasuryPanel = leftPanel:Add("DPanel")
    treasuryPanel:Dock(TOP)
    treasuryPanel:SetTall(s(180))
    treasuryPanel:DockMargin(0, 0, 0, s(20))
    treasuryPanel.Paint = function(self, w, h)
        RNDX.Draw(s(8), 0, 0, w, h, colors.bg_alt)
        draw_SimpleText("УПРАВЛЕНИЕ КАЗНОЙ", "Mayor.Normal", w/2, s(20), colors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local amountEntry = treasuryPanel:Add("DTextEntry")
    amountEntry:Dock(TOP)
    amountEntry:DockMargin(s(20), s(40), s(20), s(10))
    amountEntry:SetTall(s(35))
    amountEntry:SetFont("Mayor.Normal")
    amountEntry:SetNumeric(true)
    amountEntry:SetPlaceholderText("Введите сумму...")

    CreateStyledButton(treasuryPanel, "Пополнить из своего кармана", colors.green, function()
        local val = tonumber(amountEntry:GetValue())
        if val and val > 0 then
            net.Start("MayorMenu_Action")
            net.WriteString("deposit")
            net.WriteUInt(val, 32)
            net.SendToServer()
        end
    end):DockMargin(s(20), 0, s(20), s(5))

    CreateStyledButton(treasuryPanel, "Взять из казны", colors.red, function()
        local val = tonumber(amountEntry:GetValue())
        if val and val > 0 then
            net.Start("MayorMenu_Action")
            net.WriteString("withdraw")
            net.WriteUInt(val, 32)
            net.SendToServer()
        end
    end):DockMargin(s(20), 0, s(20), 0)

    local bonusPanel = leftPanel:Add("DPanel")
    bonusPanel:Dock(FILL)
    bonusPanel.Paint = function(self, w, h)
        RNDX.Draw(s(8), 0, 0, w, h, colors.bg_alt)
        draw_SimpleText("ВЫПЛАТЫ", "Mayor.Normal", w/2, s(20), colors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local bonusEntry = bonusPanel:Add("DTextEntry")
    bonusEntry:Dock(TOP)
    bonusEntry:DockMargin(s(20), s(40), s(20), s(10))
    bonusEntry:SetTall(s(35))
    bonusEntry:SetFont("Mayor.Normal")
    bonusEntry:SetNumeric(true)
    bonusEntry:SetPlaceholderText("Сумма на одного человека...")

    CreateStyledButton(bonusPanel, "Выдать премию Полиции", colors.accent, function()
        local val = tonumber(bonusEntry:GetValue())
        if val and val > 0 then
            net.Start("MayorMenu_Action")
            net.WriteString("bonus_police")
            net.WriteUInt(val, 32)
            net.SendToServer()
        end
    end):DockMargin(s(20), 0, s(20), s(5))

    CreateStyledButton(bonusPanel, "Выдать премию Медикам", Color(255, 100, 150), function()
        local val = tonumber(bonusEntry:GetValue())
        if val and val > 0 then
            net.Start("MayorMenu_Action")
            net.WriteString("bonus_medic")
            net.WriteUInt(val, 32)
            net.SendToServer()
        end
    end):DockMargin(s(20), 0, s(20), s(5))

    CreateStyledButton(bonusPanel, "Сделать социальную выплату", Color(103, 238, 110), function()
        local val = tonumber(bonusEntry:GetValue())
        if val and val > 0 then
            net.Start("MayorMenu_Action")
            net.WriteString("bonus_everyone")
            net.WriteUInt(val, 32)
            net.SendToServer()
        end
    end):DockMargin(s(20), 0, s(20), 0)

    local rightPanel = content:Add("DPanel")
    rightPanel:Dock(FILL)
    rightPanel:DockMargin(s(20), 0, 0, 0)
    rightPanel.Paint = function(self, w, h)
        RNDX.Draw(s(8), 0, 0, w, h, colors.bg_alt)
        draw_SimpleText("НАЛОГООБЛОЖЕНИЕ", "Mayor.Normal", w/2, s(20), colors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local taxList = rightPanel:Add("DScrollPanel")
    taxList:Dock(FILL)
    taxList:DockMargin(s(20), s(50), s(20), s(20))
    
    local sbar = taxList:GetVBar()
    sbar:SetWide(s(6))
    sbar:SetHideButtons(true)
    sbar.Paint = function(self, w, h) RNDX.Draw(s(3), 0, 0, w, h, Color(0, 0, 0, 80)) end
    sbar.btnGrip.Paint = function(self, w, h)
        RNDX.Draw(s(3), 0, 0, w, h, Color(255, 255, 255, self:IsHovered() and 220 or 120))
    end

    local taxNames = {
        Sell = "Налог на продажу",
        Purchase = "Налог на покупку",
        Salary = "Налог на зарплату",
        Estate = "Налог на недвижимость"
    }

    local sliders = {}

    for taxType, taxValue in pairs(ECONOMICS.Taxes or {}) do
        local pnl = taxList:Add("DPanel")
        pnl:Dock(TOP)
        pnl:SetTall(s(60))
        pnl:DockMargin(0, 0, 0, s(10))
        pnl.Paint = function(self, w, h)
            RNDX.Draw(s(6), 0, 0, w, h, Color(40, 40, 40, 200))
        end

        local lbl = pnl:Add("DLabel")
        lbl:SetText(taxNames[taxType] or taxType)
        lbl:SetFont("Mayor.Small")
        lbl:Dock(TOP)
        lbl:DockMargin(s(10), s(5), 0, 0)
        lbl:SetTextColor(colors.white)

        local slider = pnl:Add("DNumSlider")
        slider:Dock(FILL)
        slider:DockMargin(s(10), 0, s(10), 0)
        slider:SetMin(0)
        slider:SetMax(100)
        slider:SetDecimals(0)
        slider:SetValue(taxValue * 100)
        slider:GetTextArea():SetTextColor(colors.white)
        
        sliders[taxType] = slider
    end

    local saveTaxesBtn = CreateStyledButton(rightPanel, "Сохранить налоги", colors.accent, function()
        local newTaxes = {}
        for taxType, slider in pairs(sliders) do
            newTaxes[taxType] = slider:GetValue() / 100
        end
        
        net.Start("MayorMenu_UpdateTaxes")
        net.WriteTable(newTaxes)
        net.SendToServer()
    end)
    saveTaxesBtn:Dock(BOTTOM)
    saveTaxesBtn:DockMargin(s(20), 0, s(20), s(20))
end

concommand.Add("mayor_menu", function(ply)
    if not IsMayor(ply) then return end
    OpenMayorMenu()
end)
hook.Add("OnPlayerChat", "MayorMenuChat", function(ply, text)
    if not IsMayor(ply) then return end
    if text == "/mayor" or text == "!mayor"  then
        if !ply:GetPlayerClass() == TEAM_MAYOR then return end
        if ply == LocalPlayer() then OpenMayorMenu() end
        return true
    end
end)