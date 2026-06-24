local s = shizlib.surface.s
local DTR = shizlib.surface.DTR
local melon = include("shizlib/client/masks_cl.lua")
local RNDX = include("shizlib/client/rndx_cl.lua")

local THEME = CFG.theme or {
    bg = Color(20, 20, 20),
    accent = Color(255, 77, 119),
    white = Color(220, 220, 220),
    hover = Color(35, 35, 35)
}
THEME.bg = THEME.bg or Color(20, 20, 20)
THEME.accent = THEME.accent or Color(255, 77, 119)
THEME.white = THEME.white or Color(220, 220, 220)
THEME.hover = THEME.hover or Color(35, 35, 35)

local COLOR_BG = THEME.bg
local COLOR_ACCENT = THEME.accent
local COLOR_HOVER = THEME.hover
local COLOR_TEXT = THEME.white
local COLOR_ALT = Color(25, 25, 30, 200)

CreateConVar("shizlib_f4_close_tabs", 0, FCVAR_ARCHIVE, "Would you like to close category tabs in F4 menu (shop only)")

shizlib.f4 = shizlib.f4 or {}

shizlib.f4.DataCache = shizlib.f4.DataCache or {
    AllOrgs = nil,
    MyOrg = nil,
    LastAllReq = 0,
    LastMyReq = 0
}

local function SafeRequestAllOrgs()
    if CurTime() - shizlib.f4.DataCache.LastAllReq < 2 then return end
    shizlib.f4.DataCache.LastAllReq = CurTime()
    net.Start("Org_RequestAllOrgs")
    net.SendToServer()
end

local function SafeRequestMyOrg()
    if CurTime() - shizlib.f4.DataCache.LastMyReq < 2 then return end
    shizlib.f4.DataCache.LastMyReq = CurTime()
    net.Start("Org_RequestMyOrgData")
    net.SendToServer()
end

local baseW, baseH = 1920, 1080
surface.CreateFont('org_60', { font = 'Montserrat', extended = true, weight = 800, size = math.max(30, 60 * (ScrH() / baseH)), antialias = true })
surface.CreateFont('org_40', { font = 'Montserrat', extended = true, weight = 700, size = math.max(20, 40 * (ScrH() / baseH)), antialias = true })
surface.CreateFont('org_30', { font = 'Montserrat', extended = true, weight = 700, size = math.max(16, 30 * (ScrH() / baseH)), antialias = true })
surface.CreateFont('org_25', { font = 'Montserrat', extended = true, weight = 600, size = math.max(14, 25 * (ScrH() / baseH)), antialias = true })
surface.CreateFont('org_22', { font = 'Montserrat', extended = true, weight = 600, size = math.max(14, 22 * (ScrH() / baseH)), antialias = true })
surface.CreateFont('org_20', { font = 'Montserrat', extended = true, weight = 600, size = math.max(14, 20 * (ScrH() / baseH)), antialias = true })
surface.CreateFont('org_18', { font = 'Montserrat', extended = true, weight = 500, size = math.max(12, 18 * (ScrH() / baseH)), antialias = true })
surface.CreateFont('org_14', { font = 'Montserrat', extended = true, weight = 600, size = math.max(10, 14 * (ScrH() / baseH)), antialias = true })

local gradUp = Material("gui/gradient_up")
local gradDown = Material("gui/gradient_down")
local gradRight = Material("vgui/gradient-r")
local blurMat = Material("pp/blurscreen")

local function GetMaxSlots(slotLevel)
    if ORG_CONFIG and ORG_CONFIG.SlotUpgrades and ORG_CONFIG.SlotUpgrades[slotLevel] then
        return ORG_CONFIG.SlotUpgrades[slotLevel].slots
    end
    return 10 + ((slotLevel or 0) * 5)
end

local function GetUpgradePrice(slotLevel)
    if ORG_CONFIG and ORG_CONFIG.SlotUpgrades and ORG_CONFIG.SlotUpgrades[slotLevel] then
        return ORG_CONFIG.SlotUpgrades[slotLevel].price
    end
    return 50000
end

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

local function ApplySpawnAnimation(pnl, index)
    pnl:SetAlpha(0)
    pnl:AlphaTo(255, 0.3, (index or 1) * 0.05)
end

local function GetBadgeWidth(text)
    surface.SetFont("org_14")
    local tw, th = surface.GetTextSize(text)
    return tw + s(24)
end

local function DrawBadge(x, y, text, color)
    surface.SetFont("org_14")
    local tw, th = surface.GetTextSize(text)
    local paddingX, paddingY = s(12), s(6)
    local w, h = tw + paddingX * 2, th + paddingY * 2
    
    RNDX.Draw(h/2, x, y, w, h, ColorAlpha(color, 30), RNDX.SHAPE_FIGMA)
    RNDX.Draw(h/2, x, y, w, h, ColorAlpha(color, 20), RNDX.SHAPE_FIGMA)
    draw.SimpleText(text, "org_14", x + w/2, y + h/2, color, 1, 1)
    return w
end

local function OpenColorPickerModal(currentColor)
    local f = vgui.Create("EditablePanel")
    f:SetSize(ScrW(), ScrH())
    f:MakePopup()
    f:SetAlpha(0)
    f:AlphaTo(255, 0.3, 0)
    f.Paint = function(self, w, h)
        DrawBlur(self, 8, 4)
        surface.SetDrawColor(0, 0, 0, 180)
        surface.DrawRect(0, 0, w, h)
    end

    local pnl = vgui.Create("DPanel", f)
    pnl:SetSize(s(350), s(450))
    pnl:Center()
    pnl:SetPos(pnl:GetX(), pnl:GetY() + s(50))
    pnl:MoveTo(pnl:GetX(), pnl:GetY() - s(50), 0.5, 0, 0.1)
    pnl.Paint = function(self, w, h)
        RNDX.Draw(16, 0, 0, w, h, COLOR_BG, RNDX.SHAPE_FIGMA)
        RNDX.Draw(16, 0, 0, w, h, Color(255, 255, 255, 5), RNDX.SHAPE_FIGMA)
        draw.SimpleText("ВЫБОР ЦВЕТА", "org_30", w/2, s(25), COLOR_TEXT, 1, 0)
    end

    local cls = vgui.Create("DButton", pnl)
    cls:SetPos(pnl:GetWide() - s(45), s(20))
    cls:SetSize(s(30), s(30))
    cls:SetText("X")
    cls:SetFont("org_20")
    cls:SetTextColor(Color(150, 150, 150))
    cls.Paint = function(self) if self:IsHovered() then self:SetTextColor(COLOR_TEXT) else self:SetTextColor(Color(150, 150, 150)) end end
    cls.DoClick = function() f:AlphaTo(0, 0.2, 0, function() f:Remove() end) end

    local mixer = vgui.Create("DColorMixer", pnl)
    mixer:Dock(FILL)
    mixer:DockMargin(s(25), s(75), s(25), s(15))
    mixer:SetPalette(false)
    mixer:SetAlphaBar(false)
    mixer:SetWangs(true)
    mixer:SetColor(currentColor or Color(255, 255, 255))

    local saveBtn = vgui.Create("DButton", pnl)
    saveBtn:Dock(BOTTOM)
    saveBtn:DockMargin(s(25), 0, s(25), s(25))
    saveBtn:SetTall(s(45))
    saveBtn:SetText("")
    saveBtn.lerp = 0
    saveBtn.Paint = function(self, w, h)
        self.lerp = Lerp(FrameTime()*10, self.lerp, self:IsHovered() and 1 or 0)
        local curCol = mixer:GetColor()
        
        RNDX.Draw(8, 0, 0, w, h, curCol, RNDX.SHAPE_FIGMA)
        if self.lerp > 0 then RNDX.Draw(8, 0, 0, w, h, Color(255, 255, 255, 40 * self.lerp), RNDX.SHAPE_FIGMA) end
        
        local brightness = (curCol.r * 299 + curCol.g * 587 + curCol.b * 114) / 1000
        local txtCol = brightness > 125 and Color(20, 20, 20) or Color(240, 240, 240)
        draw.SimpleText("СОХРАНИТЬ", "org_20", w/2, h/2, txtCol, 1, 1)
    end
    saveBtn.DoClick = function()
        local c = mixer:GetColor()
        net.Start("Org_UpdateColor")
        net.WriteUInt(c.r, 8)
        net.WriteUInt(c.g, 8)
        net.WriteUInt(c.b, 8)
        net.SendToServer()
        
        f:AlphaTo(0, 0.2, 0, function() f:Remove() end)
        timer.Simple(0.2, function() SafeRequestMyOrg() SafeRequestAllOrgs() end)
    end
end

local function OpenRoleCreateModal()
    local f = vgui.Create("EditablePanel")
    f:SetSize(ScrW(), ScrH())
    f:MakePopup()
    f:SetAlpha(0)
    f:AlphaTo(255, 0.3, 0)
    f.Paint = function(self, w, h)
        DrawBlur(self, 8, 4)
        surface.SetDrawColor(0, 0, 0, 180)
        surface.DrawRect(0, 0, w, h)
    end

    local pnl = vgui.Create("DPanel", f)
    pnl:SetSize(s(400), s(520))
    pnl:Center()
    pnl:SetPos(pnl:GetX(), pnl:GetY() + s(50))
    pnl:MoveTo(pnl:GetX(), pnl:GetY() - s(50), 0.5, 0, 0.1)
    pnl.Paint = function(self, w, h)
        RNDX.Draw(16, 0, 0, w, h, COLOR_BG, RNDX.SHAPE_FIGMA)
        RNDX.Draw(16, 0, 0, w, h, Color(255,255,255, 5), RNDX.SHAPE_FIGMA)
        draw.SimpleText("НОВАЯ РОЛЬ", "org_30", w/2, s(25), COLOR_TEXT, 1, 0)
    end

    local cls = vgui.Create("DButton", pnl)
    cls:SetPos(pnl:GetWide() - s(45), s(20))
    cls:SetSize(s(30), s(30))
    cls:SetText("X")
    cls:SetFont("org_20")
    cls:SetTextColor(Color(150, 150, 150))
    cls.Paint = function(self) if self:IsHovered() then self:SetTextColor(COLOR_TEXT) else self:SetTextColor(Color(150, 150, 150)) end end
    cls.DoClick = function() f:AlphaTo(0, 0.2, 0, function() f:Remove() end) end

    local nameEntry = vgui.Create("DTextEntry", pnl)
    nameEntry:Dock(TOP)
    nameEntry:DockMargin(s(25), s(80), s(25), s(15))
    nameEntry:SetTall(s(45))
    nameEntry:SetFont("org_18")
    nameEntry:SetPlaceholderText("Название роли...")
    nameEntry.Paint = function(self, w, h)
        RNDX.Draw(8, 0, 0, w, h, COLOR_ALT, RNDX.SHAPE_FIGMA)
        self:DrawTextEntryText(COLOR_TEXT, COLOR_ACCENT, COLOR_TEXT)
    end

    local weightEntry = vgui.Create("DTextEntry", pnl)
    weightEntry:Dock(TOP)
    weightEntry:DockMargin(s(25), 0, s(25), s(15))
    weightEntry:SetTall(s(45))
    weightEntry:SetFont("org_18")
    weightEntry:SetNumeric(true)
    weightEntry:SetPlaceholderText("Вес иерархии (1-100)")
    weightEntry.Paint = function(self, w, h)
        RNDX.Draw(8, 0, 0, w, h, COLOR_ALT, RNDX.SHAPE_FIGMA)
        self:DrawTextEntryText(COLOR_TEXT, COLOR_ACCENT, COLOR_TEXT)
    end

    local permsList = vgui.Create("DScrollPanel", pnl)
    permsList:Dock(FILL)
    permsList:DockMargin(s(25), s(5), s(25), s(10))

    local permStates = {}
    local permNames = {
        {id="Invite", name="Приглашать"},
        {id="Kick", name="Исключать"},
        {id="Rank", name="Управлять ролями"},
        {id="MoTD", name="Описание"},
        {id="ChangeColor", name="Цвет"},
        {id="ManageMiners", name="Управление дата-центром"}
    }

    for _, pData in ipairs(permNames) do
        permStates[pData.id] = false
        local btn = vgui.Create("DButton", permsList)
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, s(8))
        btn:SetTall(s(40))
        btn:SetText("")
        btn.lerp = 0
        btn.Paint = function(self, w, h)
            self.lerp = Lerp(FrameTime()*12, self.lerp, permStates[pData.id] and 1 or 0)
            RNDX.Draw(8, 0, 0, w, h, COLOR_ALT, RNDX.SHAPE_FIGMA)
            if self.lerp > 0 then RNDX.Draw(8, 0, 0, w, h, ColorAlpha(COLOR_ACCENT, 40 * self.lerp), RNDX.SHAPE_FIGMA) end
            
            RNDX.Draw(6, s(12), h/2 - s(10), s(20), s(20), ColorAlpha(COLOR_TEXT, 10 + 20 * self.lerp), RNDX.SHAPE_FIGMA)
            if permStates[pData.id] then 
                RNDX.Draw(4, s(15), h/2 - s(7), s(14), s(14), COLOR_ACCENT, RNDX.SHAPE_FIGMA) 
            end
            draw.SimpleText(pData.name, "org_18", s(45), h/2, COLOR_TEXT, 0, 1)
        end
        btn.DoClick = function() permStates[pData.id] = not permStates[pData.id] end
    end

    local createBtn = vgui.Create("DButton", pnl)
    createBtn:Dock(BOTTOM)
    createBtn:DockMargin(s(25), 0, s(25), s(25))
    createBtn:SetTall(s(45))
    createBtn:SetText("")
    createBtn.lerp = 0
    createBtn.Paint = function(self, w, h)
        self.lerp = Lerp(FrameTime()*10, self.lerp, self:IsHovered() and 1 or 0)
        RNDX.Draw(8, 0, 0, w, h, COLOR_ACCENT, RNDX.SHAPE_FIGMA)
        if self.lerp > 0 then RNDX.Draw(8, 0, 0, w, h, Color(255,255,255, 40 * self.lerp), RNDX.SHAPE_FIGMA) end
        draw.SimpleText("СОЗДАТЬ", "org_20", w/2, h/2, COLOR_TEXT, 1, 1)
    end
    createBtn.DoClick = function()
        local name = nameEntry:GetText():Trim()
        local wgh = tonumber(weightEntry:GetText()) or 10
        if name == "" then return end
        
        net.Start("Org_AddRank") 
        net.WriteString(name) 
        net.WriteUInt(math.Clamp(wgh, 1, 100), 7) 
        net.WriteBool(false)
        net.WriteBool(permStates["Invite"]) 
        net.WriteBool(permStates["Kick"]) 
        net.WriteBool(permStates["Rank"])
        net.WriteBool(permStates["MoTD"]) 
        net.WriteBool(permStates["ChangeColor"]) 
        net.WriteBool(permStates["ManageMiners"])
        net.SendToServer()
        
        f:AlphaTo(0, 0.2, 0, function() f:Remove() end)
        timer.Simple(0.2, function() SafeRequestMyOrg() end)
    end
end

local whiteMat = Material("vgui/white")

local function CreateMemberEntry(member, parent, isOwner, ranks, orgName, index)
    local pnl = vgui.Create("DPanel", parent)
    pnl:Dock(TOP)
    pnl:DockMargin(0, 0, s(15), s(8))
    pnl:SetTall(s(55))
    ApplySpawnAnimation(pnl, index)
    
    local avatar = vgui.Create("AvatarImage", pnl)
    avatar:SetSize(s(40), s(40))
    avatar:SetPos(s(10), s(7.5))
    if member.SteamID then avatar:SetSteamID(util.SteamIDTo64(member.SteamID), 64) end

    local rightContainer = vgui.Create("DPanel", pnl)
    rightContainer:Dock(RIGHT)
    rightContainer:SetWide(0) 
    rightContainer:DockMargin(0, 0, s(15), 0)
    rightContainer.Paint = function() end

    local function AddRightElement(childPanel, topBottomMargin)
        childPanel:SetParent(rightContainer)
        childPanel:Dock(RIGHT)
        childPanel:DockMargin(0, topBottomMargin or 0, s(8), topBottomMargin or 0)
        rightContainer:SetWide(rightContainer:GetWide() + childPanel:GetWide() + s(8))
    end

    if isOwner and member.SteamID ~= LocalPlayer():SteamID() and ranks then
        local kickBtn = vgui.Create("DButton")
        kickBtn:SetText("")
        surface.SetFont("org_18")
        kickBtn:SetWide(surface.GetTextSize("Кик") + s(24))
        kickBtn.lerp = 0
        kickBtn.Paint = function(self, w, h)
            self.lerp = Lerp(FrameTime()*12, self.lerp, self:IsHovered() and 1 or 0)
            RNDX.Draw(6, 0, 0, w, h, ColorAlpha(Color(255, 80, 80), 20 + 40 * self.lerp), RNDX.SHAPE_FIGMA)
            draw.SimpleText("Кик", "org_18", w/2, h/2, shizlib.surface.LerpColor(self.lerp, ColorAlpha(Color(255, 80, 80), 180), color_white), 1, 1)
        end
        kickBtn.DoClick = function() 
            Derma_Query("Исключить " .. member.Name .. "?", "Подтверждение", "Да", function() 
                net.Start("Org_Kick") net.WriteString(member.SteamID) net.SendToServer() 
                timer.Simple(0.2, function() SafeRequestMyOrg() end) 
            end, "Нет") 
        end
        AddRightElement(kickBtn, s(12))

        local roleBtn = vgui.Create("DButton")
        roleBtn:SetText("")
        surface.SetFont("org_18")
        roleBtn:SetWide(surface.GetTextSize("Роль") + s(24))
        roleBtn.lerp = 0
        roleBtn.Paint = function(self, w, h)
            self.lerp = Lerp(FrameTime()*12, self.lerp, self:IsHovered() and 1 or 0)
            RNDX.Draw(6, 0, 0, w, h, ColorAlpha(Color(70, 160, 255), 20 + 40 * self.lerp), RNDX.SHAPE_FIGMA)
            draw.SimpleText("Роль", "org_18", w/2, h/2, shizlib.surface.LerpColor(self.lerp, ColorAlpha(Color(70, 160, 255), 180), color_white), 1, 1)
        end
        roleBtn.DoClick = function()
            local menu = DermaMenu()
            for _, r in ipairs(ranks) do
                if r.Name ~= "Owner" then 
                    menu:AddOption(r.Name, function() 
                        net.Start("Org_SetRank") net.WriteString(member.SteamID) net.WriteString(r.Name) net.SendToServer() 
                        timer.Simple(0.2, function() SafeRequestMyOrg() end) 
                    end) 
                end
            end
            menu:Open()
        end
        AddRightElement(roleBtn, s(12))
    end

    local function formatPlaytime(seconds)
        seconds = seconds or 0
        local h = math.floor(seconds / 3600)
        local m = math.floor((seconds % 3600) / 60)
        if h > 0 then return h .. "ч " .. m .. "м" else return m .. "м" end
    end
    
    local playtimeStr = formatPlaytime(member.Playtime)
    
    local ptBadgePnl = vgui.Create("DPanel")
    local pTimeText = "Онлайн " .. playtimeStr
    ptBadgePnl:SetWide(GetBadgeWidth(pTimeText))
    ptBadgePnl.Paint = function(self, w, h)
        surface.SetFont("org_14")
        local _, th = surface.GetTextSize(pTimeText)
        local badgeH = th + s(12)
        DrawBadge(0, h/2 - badgeH/2, pTimeText, Color(150, 200, 255))
    end
    AddRightElement(ptBadgePnl, 0)

    local safeRank = member.Rank or "Unknown"
    local rankCol = safeRank == "Owner" and Color(255, 200, 50) or Color(200, 200, 200)
    
    local badgePnl = vgui.Create("DPanel")
    badgePnl:SetWide(GetBadgeWidth(safeRank))
    badgePnl.Paint = function(self, w, h)
        surface.SetFont("org_14")
        local tw, th = surface.GetTextSize(safeRank)
        local badgeH = th + s(12)
        DrawBadge(0, h/2 - badgeH/2, safeRank, rankCol)
    end
    AddRightElement(badgePnl, 0)

    pnl.lerpHover = 0
pnl.Paint = function(self, w, h)
        self.lerpHover = Lerp(FrameTime() * 8, self.lerpHover, self:IsHovered() and 1 or 0)
        RNDX.Draw(8, 0, 0, w, h, COLOR_ALT, RNDX.SHAPE_FIGMA)
        if self.lerpHover > 0 then RNDX.Draw(8, 0, 0, w, h, ColorAlpha(COLOR_ACCENT, 15 * self.lerpHover), RNDX.SHAPE_FIGMA) end
        
        local isOnline = member.Online
        draw.SimpleText(member.Name or "Unknown", "org_20", s(65), h/2 - s(9), isOnline and COLOR_TEXT or Color(120, 120, 120), 0, 1)
        
        local lastSeenStr = "Никогда"
        if member.LastSeen and member.LastSeen > 0 then
            lastSeenStr = os.date("%d.%m.%Y %H:%M", member.LastSeen)
        end
        
        local statusText = isOnline and "В сети" or ("Был: " .. lastSeenStr)
        local statusColor = isOnline and Color(100, 255, 100) or Color(150, 150, 150)
        
        draw.SimpleText(statusText, "org_14", s(65), h/2 + s(9), statusColor, 0, 1)
    end

    return pnl
end

local function ShowOrgMembersList(orgName)
    local f = vgui.Create("EditablePanel")
    f:SetSize(ScrW(), ScrH())
    f:MakePopup()
    f:SetAlpha(0)
    f:AlphaTo(255, 0.3, 0)
    f.Paint = function(self, w, h)
        DrawBlur(self, 8, 4)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, w, h)
    end

    local pnl = vgui.Create("DPanel", f)
    pnl:SetSize(s(600), s(550))
    pnl:Center()
    pnl:SetPos(pnl:GetX(), pnl:GetY() + s(50))
    pnl:MoveTo(pnl:GetX(), pnl:GetY() - s(50), 0.5, 0, 0.1)
    pnl.Paint = function(self, w, h)
        RNDX.Draw(16, 0, 0, w, h, COLOR_BG, RNDX.SHAPE_FIGMA)
        RNDX.Draw(2, s(30), s(65), w - s(60), 2, ColorAlpha(COLOR_TEXT, 10), RNDX.SHAPE_FIGMA)
        draw.SimpleText("УЧАСТНИКИ", "org_20", w/2, s(15), ColorAlpha(COLOR_TEXT, 150), 1, 0)
        draw.SimpleText(orgName:upper(), "org_30", w/2, s(35), COLOR_ACCENT, 1, 0)
    end

    local cls = vgui.Create("DButton", pnl)
    cls:SetSize(s(40), s(40))
    cls:SetPos(pnl:GetWide() - s(50), s(15))
    cls:SetText("")
    cls.lerp = 0
    cls.Paint = function(self, w, h)
        self.lerp = Lerp(FrameTime() * 10, self.lerp, self:IsHovered() and 1 or 0)
        if self.lerp > 0 then RNDX.Draw(w/2, 0, 0, w, h, ColorAlpha(COLOR_ACCENT, 30 * self.lerp), RNDX.SHAPE_FIGMA) end

        local center = w/2
        local size = s(10) 
        local thickness = s(2) > 1 and s(2) or 2
        
        surface.SetMaterial(whiteMat)
        surface.SetDrawColor(shizlib.surface.LerpColor(self.lerp, Color(150, 150, 150), COLOR_TEXT))
        local angle = 45 + (self.lerp * 90) 
        
        surface.DrawTexturedRectRotated(center, center, size * 2, thickness, angle)
        surface.DrawTexturedRectRotated(center, center, thickness, size * 2, angle)
    end
    cls.DoClick = function() f:AlphaTo(0, 0.2, 0, function() f:Remove() end) end

    local scroll = vgui.Create("SHZScrollPanel", pnl)
    scroll:Dock(FILL)
    scroll:DockMargin(s(20), s(85), s(20), s(20))
    
    shizlib.f4.OrgMembersScroll = scroll 

    net.Start("Org_RequestOrgMembers") net.WriteString(orgName) net.SendToServer()
end

local function CreateOrgEntry(org, parent, index)
    local pnl = vgui.Create("DButton", parent)
    pnl:Dock(TOP)
    pnl:SetText("")
    pnl:DockMargin(0, 0, s(15), s(10))
    pnl:SetTall(s(85))
    ApplySpawnAnimation(pnl, index)
    
    local orgColor = org.Color or Color(200,200,200)
    local orgName = org.Name or "Неизвестная"
    local orgPoints = org.Points or 0
    local orgMembers = org.MemberCount or 0
    local orgMotd = org.MotD or ""
    
    local orgBank = org.Bank or 0
    local orgSlotLevel = org.SlotLevel or 0
    local extraSlots = org.ExtraSlots or 0
    local maxSlots = GetMaxSlots(orgSlotLevel)
    
    local slotStr = orgMembers .. "/" .. maxSlots
    if extraSlots > 0 then slotStr = slotStr .. " + " .. extraSlots end
    
    local orgActiveMiners = org.ActiveMiners or 0

    pnl.lerpHover = 0
    pnl.Paint = function(self, w, h)
        self.lerpHover = Lerp(FrameTime() * 8, self.lerpHover, self:IsHovered() and 1 or 0)
        RNDX.Draw(12, 0, 0, w, h, COLOR_ALT, RNDX.SHAPE_FIGMA)
        RNDX.Draw(12, 0, 0, s(6), h, orgColor, RNDX.SHAPE_FIGMA)
        
        if self.lerpHover > 0 then
            RNDX.Draw(12, 0, 0, w, h, ColorAlpha(orgColor, 10 * self.lerpHover), RNDX.SHAPE_FIGMA)
            RNDX.Draw(12, s(6), 0, s(4), h, ColorAlpha(orgColor, 255 * self.lerpHover), RNDX.SHAPE_FIGMA)
        end

        local textX = s(25) + (s(8) * self.lerpHover)
        draw.SimpleText(orgName, "org_30", textX, h/2 - s(14), COLOR_TEXT, 0, 1)
        
        local bx = textX
        bx = bx + DrawBadge(bx, h/2 + s(4), "Очки: " .. string.Comma(orgPoints), Color(150, 200, 255)) + s(8)
        
        bx = bx + DrawBadge(bx, h/2 + s(4), "Банк: " .. string.Comma(orgBank) .. "$", Color(100, 255, 100)) + s(8)
        
        bx = bx + DrawBadge(bx, h/2 + s(4), "Участники: " .. slotStr, Color(200, 200, 200)) + s(8)
        
        if orgActiveMiners > 0 then
            bx = bx + DrawBadge(bx, h/2 + s(4), "Майнеры: " .. orgActiveMiners, Color(255, 150, 50)) + s(8)
        end
        
        draw.SimpleText(orgMotd, "org_14", bx, h/2 + s(15), Color(150, 150, 150), 0, 1)
        
        if index <= 3 then
            local medalCol = index == 1 and Color(255, 215, 0) or index == 2 and Color(192, 192, 192) or Color(205, 127, 50)
            draw.SimpleText("#"..index, "org_40", w - s(25), h/2, ColorAlpha(medalCol, 80 + (170 * self.lerpHover)), 2, 1)
        end
    end
    pnl.DoClick = function() ShowOrgMembersList(orgName) end
    return pnl
end

local function BuildMyOrgPanel(parent)
    local panel = vgui.Create("DPanel", parent)
    panel:Dock(FILL)
    panel:SetPaintBackground(false)

    local header = vgui.Create("DPanel", panel)
    header:Dock(TOP)
    header:DockMargin(0, 0, s(15), s(15))
    header:SetTall(s(180))
    header.orgColor = Color(100, 100, 100)
    header.Paint = function(self, w, h)
        RNDX.Draw(16, 0, 0, w, h, COLOR_ALT, RNDX.SHAPE_FIGMA)
        surface.SetDrawColor(ColorAlpha(self.orgColor, 60))
        surface.SetMaterial(gradRight)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetDrawColor(ColorAlpha(self.orgColor, 40))
        surface.SetMaterial(gradDown)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    local titleLabel = header:Add("DLabel")
    titleLabel:Dock(TOP)
    titleLabel:DockMargin(s(30), s(30), s(30), 0)
    titleLabel:SetFont("org_60")
    titleLabel:SetTextColor(COLOR_TEXT)
    titleLabel:SetText("ЗАГРУЗКА...")

    local infoRow = header:Add("DPanel")
    infoRow:Dock(TOP)
    infoRow:DockMargin(s(30), s(10), s(30), 0)
    infoRow:SetTall(s(24))
    infoRow:SetPaintBackground(false)
    infoRow.points, infoRow.bank, infoRow.slots = 0, 0, "..."
    infoRow.Paint = function(self, w, h)
        local bx = 0
        bx = bx + DrawBadge(bx, 0, "Очки: " .. string.Comma(self.points), Color(255, 200, 50)) + s(10)
        bx = bx + DrawBadge(bx, 0, "Банк: " .. string.Comma(self.bank) .. "$", Color(100, 255, 100)) + s(10)
        bx = bx + DrawBadge(bx, 0, "Слоты: " .. self.slots, Color(150, 200, 255))
        --if self.ActiveMiners > 0 then
        --    bx = bx + DrawBadge(bx, h/2 + s(4), "Майнеры: " .. self.ActiveMiners, Color(255, 150, 50)) + s(8)
        --end
    end

    local motdLabel = header:Add("DLabel")
    motdLabel:Dock(FILL)
    motdLabel:DockMargin(s(30), s(15), s(30), s(15))
    motdLabel:SetFont("org_18")
    motdLabel:SetTextColor(Color(220, 220, 220))
    motdLabel:SetWrap(true)
    motdLabel:SetContentAlignment(7)
    motdLabel:SetText("Ожидание данных от сервера...")

    local headerBtns = vgui.Create("DPanel", panel)
    headerBtns:Dock(TOP)
    headerBtns:SetTall(s(45))
    headerBtns:DockMargin(0, 0, s(15), s(15))
    headerBtns:SetPaintBackground(false)
    
    local memberScroll = vgui.Create("SHZScrollPanel", panel)
    memberScroll:Dock(FILL)

    local ctrlPanel = vgui.Create("DPanel", panel)
    ctrlPanel:Dock(BOTTOM)
    ctrlPanel:SetTall(s(55))
    ctrlPanel:SetPaintBackground(false)
    ctrlPanel:DockPadding(0, s(10), s(15), 0)

    local function CreateJuicyBtn(parentRow, txt, callback, visible, dockMode, colorAccent)
        if visible == false then return end
        local btn = vgui.Create("DButton", parentRow)
        btn:SetText("")
        btn:Dock(dockMode or LEFT)
        btn:DockMargin(0, 0, dockMode == RIGHT and 0 or s(10), 0)
        surface.SetFont("org_18")
        local tw, _ = surface.GetTextSize(txt)
        btn:SetWide(tw + s(40))
        btn.col = colorAccent or COLOR_TEXT
        btn.lerp = 0
        btn.Paint = function(self, w, h)
            self.lerp = Lerp(FrameTime()*15, self.lerp, self:IsHovered() and 1 or 0)
            local offset = self:IsDown() and 2 or 0
            RNDX.Draw(8, 0, offset, w, h - offset, COLOR_ALT, RNDX.SHAPE_FIGMA)
            if self.lerp > 0 then RNDX.Draw(8, 0, offset, w, h - offset, ColorAlpha(self.col, 20 * self.lerp), RNDX.SHAPE_FIGMA) end
            draw.SimpleText(txt, "org_18", w/2, h/2 + offset, shizlib.surface.LerpColor(self.lerp, Color(200,200,200), self.col), 1, 1)
        end
        btn.DoClick = callback
        return btn
    end

    panel.SetData = function(self, orgName, isOwner, members, ranks, motd, color, points, bank, slotLevel, extraSlots)
        ranks = ranks or {}
        members = members or {}

        header.orgColor = color or Color(100, 100, 100)
        titleLabel:SetText((orgName or "Ошибка"):upper())
        titleLabel:SizeToContents()
        local maxSlots = GetMaxSlots(slotLevel)
        local slotStr = #(members) .. "/" .. maxSlots
        if (extraSlots or 0) > 0 then slotStr = slotStr .. " + " .. extraSlots end
        
        infoRow.points, infoRow.bank, infoRow.slots = points or 0, bank or 0, slotStr
        motdLabel:SetText((not motd or motd == "") and "Описание организации не установлено." or motd)

        headerBtns:Clear()
        CreateJuicyBtn(headerBtns, "Пополнить банк", function() Derma_StringRequest("Банк", "Внести:", "", function(v) net.Start("Org_BankOp") net.WriteBool(true) net.WriteUInt(tonumber(v) or 0, 32) net.SendToServer() end) end, true, LEFT, Color(100, 255, 100))
        CreateJuicyBtn(headerBtns, "Снять деньги", function() Derma_StringRequest("Банк", "Снять:", "", function(v) net.Start("Org_BankOp") net.WriteBool(false) net.WriteUInt(tonumber(v) or 0, 32) net.SendToServer() end) end, isOwner, LEFT, Color(255, 100, 100))
        
        local nLvl = (slotLevel or 0) + 1
        local upgradePrice = GetUpgradePrice(nLvl)
        local btnText = (ORG_CONFIG and ORG_CONFIG.SlotUpgrades and ORG_CONFIG.SlotUpgrades[nLvl]) and ("Улучшить (" .. string.Comma(upgradePrice) .. "$)") or "Макс. уровень"
        CreateJuicyBtn(headerBtns, btnText, function() net.Start("Org_UpgradeSlots") net.SendToServer() end, isOwner, LEFT, Color(255, 200, 50))
        
        CreateJuicyBtn(headerBtns, "Настройки ролей", function()
            local menu = DermaMenu()
            menu:AddOption("Создать новую роль", function() OpenRoleCreateModal() end)
            local delSub, _ = menu:AddSubMenu("Удалить роль")
            local hasCustomRoles = false
            for _, r in ipairs(ranks) do
                if r.Name ~= "Owner" and r.Name ~= "Member" then
                    hasCustomRoles = true
                    delSub:AddOption(r.Name, function() Derma_Query("Удалить роль '" .. r.Name .. "'?", "Удаление", "Да", function() net.Start("Org_RemoveRank") net.WriteString(r.Name) net.SendToServer() timer.Simple(0.2, function() SafeRequestMyOrg() end) end, "Нет") end)
                end
            end
            if not hasCustomRoles then delSub:AddOption("Нет ролей", function() end) end
            menu:Open()
        end, isOwner, LEFT, COLOR_ACCENT)

        CreateJuicyBtn(headerBtns, "Изменить описание", function() Derma_StringRequest("Описание", "Введите:", motd, function(t) net.Start("Org_UpdateMotD") net.WriteString(t) net.SendToServer() end) end, isOwner or (LocalPlayer():GetOrgData() and LocalPlayer():GetOrgData().Perms.MoTD))

        CreateJuicyBtn(headerBtns, "Изменить цвет", function() 
            OpenColorPickerModal(header.orgColor) 
        end, isOwner or (LocalPlayer():GetOrgData() and LocalPlayer():GetOrgData().Perms.ChangeColor), LEFT, header.orgColor)
        local canManageMiners = isOwner or (LocalPlayer():GetOrgData() and LocalPlayer():GetOrgData().Perms and LocalPlayer():GetOrgData().Perms.ManageMiners)
        
        CreateJuicyBtn(headerBtns, "Установка Дата-Центра", function() 
            Derma_Query(
                "Вы уверены, что хотите установить Дата-Центр?\nЭто спишет 10,000$ ИЗ БАНКА организации.", 
                "Покупка Дата-Центра", 
                "Купить (10,000$)", function() 
                    net.Start("Org_SpawnMiner")
                    net.SendToServer()
                    
                    if IsValid(shizlib.f4.Menu) then
                        shizlib.f4.Menu:SetVisible(false)
                        gui.HideGameUI()
                    end
                end, 
                "Отмена", function() end
            )
        end, canManageMiners, LEFT, Color(50, 200, 255))
        -- =========================================
        ctrlPanel:Clear()
        CreateJuicyBtn(ctrlPanel, "Пригласить игрока", function()
            local menu = DermaMenu()
            local f = false
            for _, pl in ipairs(player.GetAll()) do if pl ~= LocalPlayer() and not pl:GetOrg() then f = true menu:AddOption(pl:Nick(), function() net.Start("Org_Invite") net.WriteString(pl:SteamID()) net.SendToServer() end) end end
            if not f then menu:AddOption("Нет доступных", function() end) end
            menu:Open()
        end, isOwner or (LocalPlayer():GetOrgData() and LocalPlayer():GetOrgData().Perms.Invite), LEFT, COLOR_ACCENT)

        if isOwner then CreateJuicyBtn(ctrlPanel, "Расформировать", function() Derma_Query("Удалить?", "Внимание", "Да", function() net.Start("Org_Disband") net.SendToServer() end, "Нет") end, true, RIGHT, Color(255, 80, 80))
        else CreateJuicyBtn(ctrlPanel, "Покинуть", function() Derma_Query("Выйти?", "Подтверждение", "Да", function() net.Start("Org_Leave") net.SendToServer() end, "Нет") end, true, RIGHT, Color(255, 150, 80)) end

        memberScroll:Clear()
        for i, m in ipairs(members) do CreateMemberEntry(m, memberScroll, isOwner, ranks, orgName, i) end
        panel.MotD = motd
    end

    panel.UpdateMotD = function(self, newMotD) motdLabel:SetText(newMotD) self.MotD = newMotD end
    return panel
end

local function BuildOrgMenuInsideF4(parent)
    parent:Clear()

    local tabContainer = vgui.Create("DPanel", parent)
    tabContainer:Dock(TOP)
    tabContainer:SetTall(s(50))
    tabContainer:DockMargin(0, 0, s(15), s(15))
    
    local contentPanel = vgui.Create("DPanel", parent)
    contentPanel:Dock(FILL)
    contentPanel.Paint = function() end

    local allPanel = vgui.Create("DPanel", contentPanel)
    allPanel:Dock(FILL)
    allPanel:SetPaintBackground(false)

    local myPanel = BuildMyOrgPanel(contentPanel)
    myPanel:SetVisible(false)

    local shopPanel = vgui.Create("DPanel", contentPanel)
    shopPanel:Dock(FILL)
    shopPanel:SetPaintBackground(false)
    shopPanel:SetVisible(false)

    local shopHeader = vgui.Create("DPanel", shopPanel)
    shopHeader:Dock(TOP)
    shopHeader:SetTall(s(95))
    shopHeader:DockMargin(s(15), 0, s(15), s(15))
    shopHeader.Paint = function(self, w, h)
        RNDX.Draw(12, 0, 0, w, h, COLOR_ALT, RNDX.SHAPE_FIGMA)
        RNDX.Draw(12, 0, 0, s(6), h, COLOR_ACCENT, RNDX.SHAPE_FIGMA)
        surface.SetDrawColor(ColorAlpha(COLOR_ACCENT, 10))
        surface.SetMaterial(Material("vgui/gradient-r"))
        surface.DrawTexturedRect(0, 0, w, h)
    end

    local shopTitle = vgui.Create("DLabel", shopHeader)
    shopTitle:Dock(TOP)
    shopTitle:SetFont("org_30")
    shopTitle:SetText("МАГАЗИН ОЧКОВ")
    shopTitle:SetTextColor(COLOR_TEXT)
    shopTitle:SizeToContents()
    shopTitle:DockMargin(s(25), s(20), 0, 0)

    local shopDesc = vgui.Create("DLabel", shopHeader)
    shopDesc:Dock(TOP)
    shopDesc:SetFont("org_18")
    shopDesc:SetText("Тратьте очки организации на уникальные улучшения. Покупки доступны только лидеру.")
    shopDesc:SetTextColor(Color(180, 180, 180))
    shopDesc:SizeToContents()
    shopDesc:DockMargin(s(25), s(5), 0, 0)

    local shopScroll = vgui.Create("SHZScrollPanel", shopPanel)
    shopScroll:Dock(FILL)
    shopScroll:DockMargin(s(15), 0, s(10), 0)

    local RARITY = {
        NORMAL = { name = "ОБЫЧНЫЙ", color = Color(150, 150, 150) },
        RARE = { name = "РЕДКИЙ", color = Color(70, 160, 255) },
        EPIC = { name = "ЭПИЧЕСКИЙ", color = Color(180, 70, 255) },
        LEGENDARY = { name = "ЛЕГЕНДАРНЫЙ", color = Color(255, 200, 50) }
    }

    local shopItems = {
        --{
        --    id = "ad_anon",
        --    name = "Анонимное объявление",
        --    desc = "Отправляет скрытое глобальное уведомление на весь сервер.",
        --    price = 1,
        --    rarity = RARITY.NORMAL
        --},
        {
            id = "airdrop",
            name = "Вызов аирдропа",
            desc = "Вызывает аирдроп с ценным лутом на случайную точку карты.",
            price = 3,
            --rarity = RARITY.RARE
            rarity = RARITY.NORMAL
        },
        {
            id = "extra_slots",
            name = "Расширение слотов",
            desc = "Добавляет дополнительные слоты для участников. Требуется полная прокачка слотов за деньги.",
            price = 10,
            rarity = RARITY.EPIC,
            canBuy = function() return false end,
        },
        {
            id = "brentwood_plus",
            name = "BRENTWOOD+ всей организации",
            desc = "Выдает привилегию BRENTWOOD+ всем участникам вашей организации на 7 дней.",
            price = 150,
            rarity = RARITY.LEGENDARY
        }
    }

    table.sort(shopItems, function(a, b) return a.price > b.price end)

    for _, item in ipairs(shopItems) do
        local pnl = vgui.Create("DPanel", shopScroll)
        pnl:Dock(TOP)
        pnl:DockMargin(0, 0, s(5), s(15))
        pnl:SetTall(s(110))
        pnl.Paint = function(self, w, h)
            local pulse = math.abs(math.sin(CurTime() * 2))
            local rCol = item.rarity.color
            
            RNDX.Draw(12, 0, 0, w, h, COLOR_ALT, RNDX.SHAPE_FIGMA)
            
            local stripeAlpha = item.rarity.name == "ЛЕГЕНДАРНЫЙ" and (150 + 105 * pulse) or 255
            RNDX.Draw(12, 0, 0, s(6), h, ColorAlpha(rCol, stripeAlpha), RNDX.SHAPE_FIGMA)
            
            surface.SetDrawColor(ColorAlpha(rCol, item.rarity.name == "ЛЕГЕНДАРНЫЙ" and (10 + 20 * pulse) or 15))
            surface.SetMaterial(Material("vgui/gradient-r"))
            surface.DrawTexturedRect(0, 0, w, h)

            draw.SimpleText(item.name, "org_25", s(25), s(15), COLOR_TEXT, 0, 0)
            
            surface.SetFont("org_25")
            local titleWidth = surface.GetTextSize(item.name)
            DrawBadge(s(25) + titleWidth + s(15), s(11), item.rarity.name, rCol)
        end
        
        local descLabel = vgui.Create("DLabel", pnl)
        descLabel:SetPos(s(25), s(45))
        descLabel:SetFont("org_18")
        descLabel:SetTextColor(Color(180, 180, 180))
        descLabel:SetText(item.desc)
        descLabel:SetWrap(true)
        descLabel:SetAutoStretchVertical(true)
        
        pnl.PerformLayout = function(self, w, h)
            descLabel:SetWide(w - s(200))
        end
        
        local buyBtn = vgui.Create("DButton", pnl)
        buyBtn:Dock(RIGHT)
        buyBtn:DockMargin(0, s(25), s(25), s(25))
        buyBtn:SetWide(s(160))
        buyBtn:SetText("")
        
        buyBtn.Paint = function(self, w, h)
            local cache = shizlib.f4.DataCache.MyOrg
            local orgPoints = cache and cache.points or 0
            
            self.lerp = Lerp(FrameTime()*10, self.lerp or 0, self:IsHovered() and 1 or 0)
            RNDX.Draw(8, 0, 0, w, h, Color(30, 30, 35, 200), RNDX.SHAPE_FIGMA)
            if self.lerp > 0 then RNDX.Draw(8, 0, 0, w, h, ColorAlpha(item.rarity.color, 30 * self.lerp), RNDX.SHAPE_FIGMA) end
            
            local topText = "КУПИТЬ"
            local topCol = Color(150, 255, 150)
            
            if not cache or not cache.isOwner then
                topText = "ТОЛЬКО ЛИДЕР"
                topCol = Color(255, 100, 100)
            elseif orgPoints < item.price then
                topText = "МАЛО ОЧКОВ"
                topCol = Color(255, 100, 100)
            end

            if item.id == "airdrop" then
                local cd = GetGlobalInt("Org_AirdropCD", 0) - os.time()
                local plyCount = player.GetCount()

                if cd > 0 then
                    topText = string.format("КД: %02d:%02d", math.floor(cd / 60), cd % 60)
                    topCol = Color(255, 150, 50)
                elseif plyCount < 30 then
                    topText = "ИГРОКОВ: " .. plyCount .. "/30"
                    topCol = Color(255, 100, 100)
                end
            end
            
            draw.SimpleText(topText, "org_14", w/2, h/2 - s(10), topCol, 1, 1)
            draw.SimpleText(string.Comma(item.price) .. " Очков", "org_22", w/2, h/2 + s(10), ColorAlpha(item.rarity.color, 150), 1, 1)
        end
        
        buyBtn.DoClick = function()
            local cache = shizlib.f4.DataCache.MyOrg
            if not cache or not cache.isOwner then return end
            
            if item.id == "airdrop" then
                local cd = GetGlobalInt("Org_AirdropCD", 0) - os.time()
                if cd > 0 then
                    surface.PlaySound("bobby/pop.mp3")
                    return
                end
                if player.GetCount() < 30 then
                    surface.PlaySound("bobby/pop.mp3")
                    return
                end
            end

            surface.PlaySound("bobby/pop.mp3")
            Derma_Query("Вы уверены, что хотите купить '" .. item.name .. "' за " .. string.Comma(item.price) .. " очков?", "Магазин", "Купить", function()
                net.Start("Org_BuyShopItem")
                net.WriteString(item.id)
                net.SendToServer()
            end, "Отмена")
        end
    end

    local activeTab = 1
    local lerpTabX, lerpTabW = 0, 0
    
    tabContainer.Paint = function(self, w, h)
        RNDX.Draw(12, 0, 0, w, h, Color(15, 15, 20, 180), RNDX.SHAPE_FIGMA)
        RNDX.Draw(6, lerpTabX + s(10), h - s(4), lerpTabW - s(20), s(4), COLOR_ACCENT, RNDX.SHAPE_FIGMA)
        RNDX.Draw(2, s(10), h - s(2), w - s(20), s(2), ColorAlpha(COLOR_TEXT, 10), RNDX.SHAPE_FIGMA)
    end

    local function SwitchTab(id, btnW, btnX)
        activeTab = id
        allPanel:SetVisible(id == 1)
        myPanel:SetVisible(id == 2)
        shopPanel:SetVisible(id == 3)
    end

    local function CreateTabBtn(id, text, x)
        local btn = vgui.Create("DButton", tabContainer)
        btn:SetPos(x, 0)
        surface.SetFont("org_20")
        local tw = surface.GetTextSize(text)
        btn:SetSize(tw + s(40), s(50))
        btn:SetText("")
        btn.lerpHover = 0
        btn.DoClick = function() SwitchTab(id, btn:GetWide(), btn:GetX()) end
        btn.Paint = function(self, w, h)
            local isActive = (activeTab == id)
            self.lerpHover = Lerp(FrameTime() * 10, self.lerpHover, self:IsHovered() and 1 or 0)
            
            if self.lerpHover > 0 and not isActive then
                RNDX.Draw(8, s(10), s(5), w - s(20), h - s(10), Color(255, 255, 255, 8 * self.lerpHover), RNDX.SHAPE_FIGMA)
            end

            local col = isActive and COLOR_TEXT or shizlib.surface.LerpColor(self.lerpHover, Color(120, 120, 120), Color(220, 220, 220))
            
            draw.SimpleText(text, "org_20", w/2 + 1, h/2 - s(2) + 1, Color(0, 0, 0, 200), 1, 1)
            draw.SimpleText(text, "org_20", w/2, h/2 - s(2), col, 1, 1)
            
            if isActive then
                lerpTabX = Lerp(FrameTime() * 15, lerpTabX, self:GetX())
                lerpTabW = Lerp(FrameTime() * 15, lerpTabW, w)
            end
        end
        return btn
    end

    local btn1 = CreateTabBtn(1, "СЕРВЕРНЫЕ ОРГАНИЗАЦИИ", 0)
    local btn2 = CreateTabBtn(2, "МОЯ ОРГАНИЗАЦИЯ", btn1:GetWide())
    local btn3 = CreateTabBtn(3, "МАГАЗИН ОЧКОВ", btn2:GetX() + btn2:GetWide())
    
    local allScroll = vgui.Create("SHZScrollPanel", allPanel)
    allScroll:Dock(FILL)
    allScroll:DockMargin(0, 0, s(10), 0)

    function allPanel:Populate(orgs)
        allScroll:Clear()
        
        if orgs == nil then
            local loadLabel = vgui.Create("DLabel", allScroll)
            loadLabel:Dock(TOP)
            loadLabel:DockMargin(0, s(20), 0, 0)
            loadLabel:SetFont("org_20")
            loadLabel:SetText("Загрузка списка организаций...")
            loadLabel:SetTextColor(Color(150, 150, 150))
            loadLabel:SetContentAlignment(5)
            return
        end

        if table.Count(orgs) == 0 then
            local emptyLabel = vgui.Create("DLabel", allScroll)
            emptyLabel:Dock(TOP)
            emptyLabel:DockMargin(0, s(20), 0, 0)
            emptyLabel:SetFont("org_20")
            emptyLabel:SetText("Организаций пока нет. Станьте первым!")
            emptyLabel:SetTextColor(Color(150, 150, 150))
            emptyLabel:SetContentAlignment(5)
            return
        end
        for k, org in pairs(orgs) do CreateOrgEntry(org, allScroll, k) end
    end

    local createOrgBtn = vgui.Create("DButton", allPanel)
    createOrgBtn:Dock(BOTTOM)
    createOrgBtn:DockMargin(0, s(15), s(25), s(15))
    createOrgBtn:SetTall(s(55))
    createOrgBtn:SetText("")
    createOrgBtn.lerp = 0
    createOrgBtn.Paint = function(self, w, h)
        self.lerp = Lerp(FrameTime()*10, self.lerp, self:IsHovered() and 1 or 0)
        RNDX.Draw(10, 0, 0, w, h, COLOR_ACCENT, RNDX.SHAPE_FIGMA)
        if self.lerp > 0 then RNDX.Draw(10, 0, 0, w, h, Color(255,255,255, 30 * self.lerp), RNDX.SHAPE_FIGMA) end
        draw.SimpleText("СОЗДАТЬ ОРГАНИЗАЦИЮ", "org_20", w/2, h/2, COLOR_TEXT, 1, 1)
    end
    createOrgBtn.DoClick = function()
        Derma_StringRequest("Создание", "Название:", "", function(t)
            local maxLength = (ORG_CONFIG and ORG_CONFIG.MaxNameLength) or 32
            if #t > maxLength then return end
            net.Start("Org_ConfirmCreate") net.WriteString(t) net.SendToServer()
        end)
    end

    local function UpdateVisibility()
        if not IsValid(parent) or not IsValid(btn2) or not IsValid(btn3) or not IsValid(createOrgBtn) then return end
        local hasOrg = LocalPlayer():GetOrg() ~= nil
        btn2:SetVisible(hasOrg)
        createOrgBtn:SetVisible(not hasOrg)
        
        if not hasOrg and activeTab == 2 then SwitchTab(1) end
        
        if hasOrg then
            btn3:SetPos(btn2:GetX() + btn2:GetWide(), 0)
        else
            btn3:SetPos(btn1:GetX() + btn1:GetWide(), 0)
        end
    end

    UpdateVisibility()
    
    local timerName = "Org_UpdateTabVis_" .. tostring(parent)
    timer.Create(timerName, 1, 0, function()
        if not IsValid(parent) or not IsValid(btn2) or not IsValid(createOrgBtn) then 
            timer.Remove(timerName) 
            return 
        end
        
        if btn2:IsVisible() ~= (LocalPlayer():GetOrg() ~= nil) then 
            UpdateVisibility() 
            if LocalPlayer():GetOrg() then SafeRequestMyOrg() end 
        end
    end)

    shizlib.f4.OrgAllPanel = allPanel
    shizlib.f4.OrgMyPanel = myPanel

    if shizlib.f4.DataCache.AllOrgs then
        allPanel:Populate(shizlib.f4.DataCache.AllOrgs)
    else
        allPanel:Populate(nil)
    end
    
    SafeRequestAllOrgs()

    if LocalPlayer():GetOrg() then
        if shizlib.f4.DataCache.MyOrg then
            local d = shizlib.f4.DataCache.MyOrg
            myPanel:SetData(d.orgName, d.isOwner, d.members, d.ranks, d.motd, d.color, d.points, d.bank, d.slotLevel)
        end
        SafeRequestMyOrg()
        SwitchTab(2)
    end
end

local function BuildDonateMenuInsideF4(parent)
    parent:Clear()

    local tabContainer = vgui.Create("DPanel", parent)
    tabContainer:Dock(TOP)
    tabContainer:SetTall(s(50))
    tabContainer:DockMargin(0, 0, s(15), s(15))
    
    local headerBtns = vgui.Create("DPanel", parent)
    headerBtns:Dock(TOP)
    headerBtns:SetTall(s(45))
    headerBtns:DockMargin(0, 0, s(15), s(15))
    headerBtns:SetPaintBackground(false)
    
    local contentPanel = vgui.Create("DPanel", parent)
    contentPanel:Dock(FILL)
    contentPanel.Paint = function() end

    local activeTab = 1
    local lerpTabX, lerpTabW = 0, 0
    
    tabContainer.Paint = function(self, w, h)
        RNDX.Draw(12, 0, 0, w, h, Color(15, 15, 20, 180), RNDX.SHAPE_FIGMA)
        RNDX.Draw(6, lerpTabX + s(10), h - s(4), lerpTabW - s(20), s(4), COLOR_ACCENT, RNDX.SHAPE_FIGMA)
        RNDX.Draw(2, s(10), h - s(2), w - s(20), s(2), ColorAlpha(COLOR_TEXT, 10), RNDX.SHAPE_FIGMA)
    end

    local panels = {}
    local tabBtns = {}

    local function SwitchTab(id, btnW, btnX)
        activeTab = id
        for i, pnl in ipairs(panels) do
            if IsValid(pnl) then pnl:SetVisible(i == id) end
        end
    end

    local function CreateTabBtn(id, text, x)
        local btn = vgui.Create("DButton", tabContainer)
        btn:SetPos(x, 0)
        surface.SetFont("org_20")
        local tw = surface.GetTextSize(text)
        btn:SetSize(tw + s(40), s(50))
        btn:SetText("")
        btn.lerpHover = 0
        btn.DoClick = function() SwitchTab(id, btn:GetWide(), btn:GetX()) end
        btn.Paint = function(self, w, h)
            local isActive = (activeTab == id)
            self.lerpHover = Lerp(FrameTime() * 10, self.lerpHover, self:IsHovered() and 1 or 0)
            
            if self.lerpHover > 0 and not isActive then
                RNDX.Draw(8, s(10), s(5), w - s(20), h - s(10), Color(255, 255, 255, 8 * self.lerpHover), RNDX.SHAPE_FIGMA)
            end

            local col = isActive and COLOR_TEXT or shizlib.surface.LerpColor(self.lerpHover, Color(120, 120, 120), Color(220, 220, 220))
            
            draw.SimpleText(text, "org_20", w/2 + 1, h/2 - s(2) + 1, Color(0, 0, 0, 200), 1, 1)
            draw.SimpleText(text, "org_20", w/2, h/2 - s(2), col, 1, 1)
            
            if isActive then
                lerpTabX = Lerp(FrameTime() * 15, lerpTabX, self:GetX())
                lerpTabW = Lerp(FrameTime() * 15, lerpTabW, w)
            end
        end
        return btn
    end

    local function DrawShadowText(text, font, x, y, color, ax, ay)
        draw.SimpleText(text, font, x + s(2), y + s(2), Color(0, 0, 0, 200), ax, ay)
        draw.SimpleText(text, font, x, y, color, ax, ay)
    end

    local categories = {
        { name = "Топ Дня", id = "Top" },
        { name = "Привилегии", id = "Привилегии" },
        { name = "Деньги", id = "Деньги" },
        { name = "Оружие", id = "Оружие" },
        { name = "Инвентарь", id = "Inventory" },
    }

    local curX = 0
    for i, catData in ipairs(categories) do
        local tabBtn = CreateTabBtn(i, catData.name:upper(), curX)
        curX = curX + tabBtn:GetWide()
        
        local scroll = vgui.Create("SHZScrollPanel", contentPanel)
        scroll:Dock(FILL)
        scroll:DockMargin(0, 0, s(10), 0)
        scroll:SetVisible(false)
        
        if catData.id == "Top" then
            local matGlow = Material("sprites/light_glow02_add")
            
            local topContainer = vgui.Create("DPanel", scroll)
            topContainer:Dock(TOP)
            topContainer:SetTall(s(600)) 
            topContainer.Paint = function(self, w, h)
                local pulse = math.abs(math.sin(CurTime() * 2))
                surface.SetDrawColor(255, 180, 0, 10 + 10 * pulse)
                surface.SetMaterial(matGlow)
                surface.DrawTexturedRectRotated(w/2, s(280), s(800), s(600), CurTime() * 5)
                
                DrawShadowText("ТОП ДОНАТЕРОВ ЗА СЕГОДНЯ", "org_40", w/2, s(20), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                
                local str1 = "Топ 1 получает "
                local str2 = "BRENTWOOD+"
                local str3 = " до смещения другим игроком"
                
                surface.SetFont("org_22") 
                local w1 = surface.GetTextSize(str1)
                local w2 = surface.GetTextSize(str2)
                local w3 = surface.GetTextSize(str3)
                
                local totalW = w1 + w2 + w3 
                local startX = w/2 - totalW/2
                
                local rainbowColor = HSVToColor((CurTime() * 120) % 360, 0.75, 1)

                DrawShadowText(str1, "org_22", startX, s(70), Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                DrawShadowText(str2, "org_22", startX + w1, s(70), rainbowColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                DrawShadowText(str3, "org_22", startX + w1 + w2, s(70), Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
            
            local pedestalArea = vgui.Create("DPanel", topContainer)
            pedestalArea:Dock(TOP)
            pedestalArea:SetTall(s(400))
            pedestalArea:DockMargin(0, s(110), 0, 0)
            pedestalArea.Paint = function(self, w, h) end

            local listArea = vgui.Create("DPanel", topContainer)
            listArea:Dock(TOP)
            listArea:DockMargin(0, s(10), 0, 0)
            listArea.Paint = function() end

            local function CreatePremiumAvatar(parent, steamid, size, col)
                local avaFrame = vgui.Create("DPanel", parent)
                avaFrame:SetSize(size, size)
                avaFrame.Paint = function(self, w, h)
                    local pulse = math.abs(math.sin(CurTime() * 3))
                    RNDX.Draw(8, 0, 0, w, h, ColorAlpha(col, 150 + 100 * pulse), RNDX.SHAPE_FIGMA)
                    RNDX.Draw(6, s(3), s(3), w-s(6), h-s(6), Color(15, 15, 20), RNDX.SHAPE_FIGMA)
                end
                
                local ava = vgui.Create("AvatarImage", avaFrame)
                ava:Dock(FILL)
                ava:DockMargin(s(4), s(4), s(4), s(4))
                ava:SetSteamID(steamid, 128)
                
                return avaFrame
            end

            local function BuildTopUI(data)
                if not IsValid(pedestalArea) then return end
                pedestalArea:Clear()
                listArea:Clear()

                if #data == 0 then
                    local noData = vgui.Create("DLabel", pedestalArea)
                    noData:Dock(FILL)
                    noData:SetText("Сегодня пока нет покупок. Стань первым!")
                    noData:SetFont("org_30")
                    noData:SetTextColor(Color(150, 150, 150))
                    noData:SetContentAlignment(5)
                    return
                end

                local topColors = {
                    [1] = {col = Color(255, 215, 0), h = s(260), w = s(220), ava = s(90)},
                    [2] = {col = Color(200, 200, 200), h = s(210), w = s(190), ava = s(70)},
                    [3] = {col = Color(205, 127, 50), h = s(190), w = s(190), ava = s(70)}
                }
                
                local order = {2, 1, 3}
                local peds = {}
                local spacing = s(30)

                for _, posIndex in ipairs(order) do
                    local row = data[posIndex]
                    if not row then continue end
                    
                    local cfg = topColors[posIndex]
                    local ped = vgui.Create("DPanel", pedestalArea)
                    ped:SetSize(cfg.w, cfg.h)
                    
                    ped.baseY = s(350) - cfg.h 
                    ped.targetX = 0 
                    ped.animProgress = 0
                    ped.delay = (posIndex == 1 and 0.1 or (posIndex == 2 and 0.3 or 0.5))
                    
                    ped.Think = function(self)
                        if self.delay > 0 then
                            self.delay = self.delay - FrameTime()
                            self:SetAlpha(0)
                            return
                        end
                        
                        self.animProgress = Lerp(FrameTime() * 6, self.animProgress, 1)
                        self:SetAlpha(255 * self.animProgress)
                        
                        local floatY = math.sin(CurTime() * 2.5 + posIndex) * s(6)
                        local entranceY = (1 - self.animProgress) * s(60) 
                        
                        self:SetPos(self.targetX, self.baseY + floatY + entranceY)
                    end
                    
                    ped.Paint = function(self, w, h)
                        local pulse = math.abs(math.sin(CurTime() * 3 + posIndex))
                        local borderAlpha = posIndex == 1 and (120 + 80 * pulse) or 60
                        
                        RNDX.Draw(12, 0, 0, w, h, Color(18, 18, 23, 255), RNDX.SHAPE_FIGMA)
                        
                        RNDX.Draw(12, 0, 0, w, h, ColorAlpha(cfg.col, borderAlpha), RNDX.SHAPE_FIGMA)
                        RNDX.Draw(12, s(2), s(2), w-s(4), h-s(4), Color(22, 22, 28, 255), RNDX.SHAPE_FIGMA)
                        
                        surface.SetDrawColor(ColorAlpha(cfg.col, 10 + 15 * pulse))
                        surface.SetMaterial(Material("gui/gradient_down"))
                        surface.DrawTexturedRect(s(2), s(2), w-s(4), h-s(4))

                        DrawShadowText("#" .. posIndex, "org_60", w/2, h/2 + s(10), ColorAlpha(cfg.col, 20), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        
                        local rb = posIndex == 1 and HSVToColor((CurTime() * 100) % 360, 0.75, 1) or cfg.col
                        
                        DrawShadowText(row.name, posIndex == 1 and "org_25" or "org_22", w/2, h - s(80), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        DrawShadowText(string.Comma(row.amount) .. " ₽", posIndex == 1 and "org_30" or "org_25", w/2, h - s(45), rb, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end

                    local ava = CreatePremiumAvatar(ped, row.steamid64, cfg.ava, cfg.col)
                    ava:SetPos(cfg.w/2 - cfg.ava/2, s(25))
                    
                    table.insert(peds, ped)
                end

                pedestalArea.PerformLayout = function(self, w, h)
                    local totalW = 0
                    for _, p in ipairs(peds) do totalW = totalW + p:GetWide() end
                    totalW = totalW + ((#peds - 1) * spacing)
                    
                    local curX = w / 2 - totalW / 2
                    for _, p in ipairs(peds) do
                        p.targetX = curX
                        curX = curX + p:GetWide() + spacing
                    end
                end

                local listY = 0
                for rank = 4, #data do
                    local row = data[rank]
                    local pnl = listArea:Add("DPanel")
                    pnl:Dock(TOP)
                    pnl:SetTall(s(65))
                    pnl:DockMargin(s(100), 0, s(100), s(10))
                    
                    pnl.animProgress = 0
                    pnl.lerp = 0
                    pnl.delay = 0.5 + (rank * 0.05)
                    
                    pnl.Paint = function(self, w, h)
                        if self.delay > 0 then
                            self.delay = self.delay - FrameTime()
                            return
                        end
                        self.animProgress = Lerp(FrameTime() * 8, self.animProgress, 1)
                        self.lerp = Lerp(FrameTime() * 10, self.lerp, self:IsHovered() and 1 or 0)
                        
                        surface.SetAlphaMultiplier(self.animProgress)
                        
                        RNDX.Draw(8, 0, 0, w, h, Color(22, 22, 28, 255), RNDX.SHAPE_FIGMA)
                        
                        if self.lerp > 0 then
                            RNDX.Draw(8, 0, 0, w, h, ColorAlpha(COLOR_ACCENT, 20 * self.lerp), RNDX.SHAPE_FIGMA)
                            RNDX.Draw(8, 0, 0, s(5), h, COLOR_ACCENT, RNDX.SHAPE_FIGMA)
                        end
                        
                        RNDX.Draw(6, s(15), s(12), s(40), s(40), ColorAlpha(color_white, 5 + 10 * self.lerp), RNDX.SHAPE_FIGMA)
                        DrawShadowText("#" .. rank, "org_22", s(35), h/2, Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        
                        DrawShadowText(row.name, "org_22", s(130), h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        
                        local priceCol = shizlib.surface.LerpColor(self.lerp, COLOR_ACCENT, color_white)
                        DrawShadowText(string.Comma(row.amount) .. " ₽", "org_22", w - s(25), h/2, priceCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        
                        surface.SetAlphaMultiplier(1)
                    end
                    
                    local ava = CreatePremiumAvatar(pnl, row.steamid64, s(40), Color(100, 100, 100))
                    ava:SetPos(s(70), s(12))
                    
                    listY = listY + s(75)
                end
                listArea:SetTall(listY)

                topContainer:SetTall(s(520) + listY)
            end

            local oldClick = tabBtn.DoClick
            tabBtn.DoClick = function()
                oldClick()
                net.Start("OnyxRequestTop")
                net.SendToServer()
            end

            net.Receive("OnyxSendTop", function()
                local count = net.ReadUInt(4)
                local data = {}
                for j = 1, count do
                    table.insert(data, {
                        steamid64 = net.ReadString(),
                        name = net.ReadString(),
                        amount = net.ReadUInt(32)
                    })
                end
                BuildTopUI(data)
            end)

        elseif catData.id == "Inventory" then
            local layout = vgui.Create("DIconLayout", scroll)
            layout:Dock(FILL)
            layout:SetSpaceX(s(15))
            layout:SetSpaceY(s(15))

            onyx.InventoryScroll = scroll

            local noItemsPanel

            local function BuildInventoryUI()
                if not IsValid(layout) then return end
                layout:Clear()
                if IsValid(noItemsPanel) then noItemsPanel:Remove() end

                local inv = LocalPlayer().DonateInventory or {}
                local hasItems = false

                for itemKey, amt in SortedPairs(inv) do
                    local DatItem = onyx.Donate[itemKey]
                    if not DatItem or amt <= 0 then continue end
                    hasItems = true

                    local card = layout:Add("DPanel")
                    card:SetSize(s(226), s(284))
                    card.hoverLerp = 0
                    card.shimmerPos = -s(300)

                    if DatItem.model ~= nil then
                        card.model = vgui.Create("DModelPanel", card)
                        card.model:SetSize(s(160), s(160))
                        card.model:SetPos(card:GetWide()/2 - s(80), s(50))
                        card.model:SetModel(DatItem.model)
                        card.model:SetMouseInputEnabled(false)
                        card.model:SetDirectionalLight(BOX_TOP, Color(200, 200, 200))
                        card.model:SetDirectionalLight(BOX_FRONT, Color(150, 150, 150))
                        card.model:SetAmbientLight(Color(40, 40, 40))
                        card.model.LayoutEntity = function(s_panel, ent)
                            if not IsValid(ent) then return end
                            local levitate = math.sin(RealTime() * 2) * 2
                            ent:SetAngles(Angle(0, RealTime() * 30, 0))
                            ent:SetPos(Vector(0, 0, levitate))
                        end
                        if IsValid(card.model.Entity) then
                            local mn, mx = card.model.Entity:GetRenderBounds()
                            local size = math.max(math.abs(mn.x) + math.abs(mx.x), math.abs(mn.y) + math.abs(mx.y), math.abs(mn.z) + math.abs(mx.z))
                            card.model:SetFOV(45)
                            card.model:SetCamPos(Vector(size, size, size * 0.5))
                            card.model:SetLookAt((mn + mx) * 0.5)
                        end
                    end

                    card.Paint = function(self, w, h)
                        self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
                        local itemColor = DatItem.col or COLOR_ACCENT

                        local outlineColor = ColorAlpha(itemColor, 30 + (130 * self.hoverLerp))
                        RNDX.Draw(12, 0, 0, w, h, outlineColor, RNDX.SHAPE_FIGMA)
                        RNDX.Draw(11, s(1), s(1), w-s(2), h-s(2), COLOR_BG, RNDX.SHAPE_FIGMA)

                        surface.SetMaterial(gradUp)
                        surface.SetDrawColor(ColorAlpha(itemColor, 8 + (30 * self.hoverLerp)))
                        surface.DrawTexturedRect(0, h/2, w, h/2)

                        if self:IsHovered() then
                            self.shimmerPos = self.shimmerPos + (FrameTime() * s(500))
                            if self.shimmerPos > w + s(100) then self.shimmerPos = -s(200) end
                        else
                            self.shimmerPos = -s(300)
                        end
                        if self.shimmerPos > -s(100) then
                            surface.SetMaterial(gradRight)
                            surface.SetDrawColor(250, 240, 230, 8 * self.hoverLerp)
                            surface.DrawTexturedRectRotated(self.shimmerPos, h/2, s(150), h * 2, 25)
                        end

                        if not DatItem.model and DatItem.icon ~= nil then
                            surface.SetMaterial(Material(DatItem.icon, 'smooth'))
                            local pulse = math.sin(RealTime() * 2) * 4 * self.hoverLerp
                            surface.SetDrawColor(255, 255, 255, 255)
                            surface.DrawTexturedRect(w/2 - s(56) - pulse/2, s(60) - pulse/2, s(112) + pulse, s(112) + pulse)
                        end

                        draw.SimpleText(DatItem.name, "org_22", w/2, s(20), COLOR_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                        draw.SimpleText(DatItem.category or "Инвентарь", "org_14", w/2, s(45), Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

                        local amtText = "x" .. amt
                        surface.SetFont("org_18")
                        local textW, textH = surface.GetTextSize(amtText)
                        local pillW = textW + s(16)
                        local pillH = s(24)
                        RNDX.Draw(pillH/2, w - pillW - s(10), s(10), pillW, pillH, itemColor, RNDX.SHAPE_FIGMA)
                        draw.SimpleText(amtText, "org_18", w - pillW/2 - s(10), s(10) + pillH/2, COLOR_BG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end

                    local useBtn = vgui.Create("DButton", card)
                    useBtn:SetSize(s(160), s(38))
                    useBtn:SetPos(card:GetWide()/2 - s(80), card:GetTall() - s(50))
                    useBtn:SetText("")
                    useBtn.hoverLerp = 0
                    useBtn.Paint = function(self, w, h)
                        self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
                        local c = DatItem.col or COLOR_ACCENT
                        RNDX.Draw(10, 0, 0, w, h, ColorAlpha(c, 210 + (45 * self.hoverLerp)), RNDX.SHAPE_FIGMA)
                        draw.SimpleText("АКТИВИРОВАТЬ", "org_18", w/2, h/2, COLOR_BG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                    useBtn.DoClick = function()
                        surface.PlaySound("ui/buttonclick.wav")
                        
                        local confirm = vgui.Create("EditablePanel")
                        confirm:SetSize(ScrW(), ScrH())
                        confirm:MakePopup()
                        confirm:SetAlpha(0)
                        confirm:AlphaTo(255, 0.25)
                        confirm.Paint = function(self_p, w, h)
                            DrawBlur(self_p, 6, 3)
                            surface.SetDrawColor(0, 0, 0, 240)
                            surface.DrawRect(0, 0, w, h)
                        end

                        local modal = vgui.Create("DPanel", confirm)
                        modal:SetSize(s(480), s(240))
                        modal:Center()
                        modal.Paint = function(self_m, w, h)
                            RNDX.Draw(16, 0, 0, w, h, COLOR_ALT, RNDX.SHAPE_FIGMA)
                            RNDX.Draw(16, 0, 0, w, s(70), COLOR_BG, RNDX.SHAPE_FIGMA)
                            draw.SimpleText("АКТИВАЦИЯ ПРЕДМЕТА", "org_22", w/2, s(35), COLOR_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                            draw.SimpleText("Вы действительно хотите активировать услугу", "org_18", w/2, s(100), Color(180, 180, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                            draw.SimpleText(DatItem.name, "org_25", w/2, s(140), DatItem.col or COLOR_ACCENT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end

                        local function CloseConfirm()
                            if IsValid(confirm) then
                                confirm:AlphaTo(0, 0.2, 0, function() if IsValid(confirm) then confirm:Remove() end end)
                            end
                        end

                        local btnYes = vgui.Create("DButton", modal)
                        btnYes:SetSize(s(200), s(50))
                        btnYes:SetPos(s(250), s(175))
                        btnYes:SetText("")
                        btnYes.hoverLerp = 0
                        btnYes.Paint = function(self_btn, w, h)
                            self_btn.hoverLerp = Lerp(FrameTime() * 12, self_btn.hoverLerp, self_btn:IsHovered() and 1 or 0)
                            local c = DatItem.col or COLOR_ACCENT
                            RNDX.Draw(12, 0, 0, w, h, ColorAlpha(c, 210 + (45 * self_btn.hoverLerp)), RNDX.SHAPE_FIGMA)
                            draw.SimpleText("АКТИВИРОВАТЬ", "org_20", w/2, h/2, COLOR_BG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end
                        btnYes.DoClick = function()
                            surface.PlaySound("ui/buttonclick.wav")
                            CloseConfirm()
                            net.Start("OnyxDonateInventory.Use")
                            net.WriteString(itemKey)
                            net.SendToServer()
                        end

                        local btnNo = vgui.Create("DButton", modal)
                        btnNo:SetSize(s(200), s(50))
                        btnNo:SetPos(s(30), s(175))
                        btnNo:SetText("")
                        btnNo.hoverLerp = 0
                        btnNo.Paint = function(self_btn, w, h)
                            self_btn.hoverLerp = Lerp(FrameTime() * 12, self_btn.hoverLerp, self_btn:IsHovered() and 1 or 0)
                            local offset = 10 * self_btn.hoverLerp
                            RNDX.Draw(12, 0, 0, w, h, Color(COLOR_ALT.r + offset, COLOR_ALT.g + offset, COLOR_ALT.b + offset), RNDX.SHAPE_FIGMA)
                            draw.SimpleText("ОТМЕНА", "org_20", w/2, h/2, COLOR_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end
                        btnNo.DoClick = function()
                            surface.PlaySound("ui/buttonclick.wav")
                            CloseConfirm()
                        end
                    end

                    local function OpenItemContextMenu()
                        local menu = DermaMenu()
                        
                        menu:AddOption("Активировать", function()
                            if IsValid(useBtn) then
                                useBtn:DoClick()
                            end
                        end):SetIcon("icon16/tick.png")
                        
                        menu:AddOption("Передать игроку", function()
                            if not shizlib or not shizlib.request or not shizlib.request.playerRequest then
                                chat.AddText(Color(255, 100, 100), "Система запросов недоступна!")
                                return
                            end
                            shizlib.request.playerRequest(player.GetAll(), function(targetPly)
                                if not IsValid(targetPly) then return end
                                if amt > 1 then
                                    shizlib.request.number("Количество", "Сколько штук вы хотите передать " .. targetPly:Nick() .. "? (1 - " .. amt .. ")", "?", function(val)
                                        local count = tonumber(val)
                                        if not count or count <= 0 or count > amt then
                                            chat.AddText(Color(255, 100, 100), "Неверное количество!")
                                            return
                                        end
                                        net.Start("OnyxDonateInventory.Give")
                                            net.WriteString(itemKey)
                                            net.WriteEntity(targetPly)
                                            net.WriteUInt(count, 16)
                                        net.SendToServer()
                                    end)
                                else
                                    net.Start("OnyxDonateInventory.Give")
                                        net.WriteString(itemKey)
                                        net.WriteEntity(targetPly)
                                        net.WriteUInt(1, 16)
                                    net.SendToServer()
                                end
                            end, true)
                        end):SetIcon("icon16/user_go.png")
                        
                        menu:AddOption("Выкинуть", function()
                            if amt > 1 then
                                if not shizlib or not shizlib.request or not shizlib.request.number then
                                    chat.AddText(Color(255, 100, 100), "Система запросов недоступна!")
                                    return
                                end
                                shizlib.request.number("Количество", "Сколько штук вы хотите выкинуть? (1 - " .. amt .. ")", "?", function(val)
                                    local count = tonumber(val)
                                    if not count or count <= 0 or count > amt then
                                        chat.AddText(Color(255, 100, 100), "Неверное количество!")
                                        return
                                    end
                                    net.Start("OnyxDonateInventory.Drop")
                                        net.WriteString(itemKey)
                                        net.WriteUInt(count, 16)
                                    net.SendToServer()
                                end)
                            else
                                net.Start("OnyxDonateInventory.Drop")
                                    net.WriteString(itemKey)
                                    net.WriteUInt(1, 16)
                                net.SendToServer()
                            end
                        end):SetIcon("icon16/arrow_down.png")
                        
                        menu:Open()
                    end

                    card.OnMousePressed = function(self_card, mouseCode)
                        if mouseCode == MOUSE_RIGHT then
                            OpenItemContextMenu()
                        end
                    end
                    
                    useBtn.DoRightClick = function()
                        OpenItemContextMenu()
                    end
                end

            if not hasItems then
                noItemsPanel = vgui.Create("DLabel", scroll)
                noItemsPanel:SetSize(s(600), s(200))
                noItemsPanel:SetText("Ваш инвентарь пуст.\nПриобретите товары во вкладках выше.")
                noItemsPanel:SetFont("org_25")
                noItemsPanel:SetTextColor(Color(150, 150, 150))
                noItemsPanel:SetContentAlignment(5)
                noItemsPanel.Think = function(self)
                    if not IsValid(scroll) then return end
                    self:SetPos(scroll:GetWide() / 2 - self:GetWide() / 2, scroll:GetTall() / 2 - self:GetTall() / 2)
                end
            end
        end

        onyx.RefreshInventoryUI = BuildInventoryUI

        local oldClick = tabBtn.DoClick
        tabBtn.DoClick = function()
            oldClick()
            BuildInventoryUI()
        end
        else
            local layout = vgui.Create("DIconLayout", scroll)
            layout:Dock(FILL)
            layout:SetSpaceX(s(15))
            layout:SetSpaceY(s(15))

            if onyx and onyx.Donate then
                for item, DatItem in SortedPairsByMemberValue(onyx.Donate, 'id') do
                    if DatItem.category == catData.id then
                        if onyx.Sheet then
                            onyx.Sheet(layout, item, DatItem)
                        end
                    end
                end
            end
        end

        table.insert(panels, scroll)
        table.insert(tabBtns, tabBtn)
    end

    if tabBtns[1] then
        tabBtns[1]:DoClick()
    end

    local function CreateJuicyBtn(parentRow, txt, callback, visible, dockMode, colorAccent)
        if visible == false then return end
        local btn = vgui.Create("DButton", parentRow)
        btn:SetText("")
        btn.CurrentText = txt
        btn:Dock(dockMode or LEFT)
        btn:DockMargin(0, 0, dockMode == RIGHT and 0 or s(10), 0)
        surface.SetFont("org_18")
        local tw = surface.GetTextSize(txt)
        btn:SetWide(tw + s(40))
        btn.col = colorAccent or COLOR_TEXT
        btn.lerp = 0
        btn.Paint = function(self, w, h)
            self.lerp = Lerp(FrameTime()*15, self.lerp, self:IsHovered() and 1 or 0)
            local offset = self:IsDown() and 2 or 0
            RNDX.Draw(8, 0, offset, w, h - offset, COLOR_ALT, RNDX.SHAPE_FIGMA)
            if self.lerp > 0 then RNDX.Draw(8, 0, offset, w, h - offset, ColorAlpha(self.col, 20 * self.lerp), RNDX.SHAPE_FIGMA) end
            draw.SimpleText(self.CurrentText, "org_18", w/2, h/2 + offset, shizlib.surface.LerpColor(self.lerp, Color(200,200,200), self.col), 1, 1)
        end
        btn.DoClick = callback
        return btn
    end

    local curFunds = (LocalPlayer().IGSFunds and LocalPlayer():IGSFunds()) or 0
    
    local balBtn = CreateJuicyBtn(headerBtns, "Баланс: " .. string.Comma(curFunds) .. " ₽", function() if onyx and onyx.GiveMoney then onyx.GiveMoney() end end, true, LEFT, Color(100, 255, 100))
    if IsValid(balBtn) then
        balBtn.Think = function(self)
            local cur = (LocalPlayer().IGSFunds and LocalPlayer():IGSFunds()) or 0
            local t = "Баланс: " .. string.Comma(cur) .. " ₽"
            if self.CurrentText ~= t then
                self.CurrentText = t
                surface.SetFont("org_18")
                self:SetWide(surface.GetTextSize(t) + s(40))
            end
        end
    end

    CreateJuicyBtn(headerBtns, "Пополнить", function() if onyx and onyx.GiveMoney then onyx.GiveMoney() end end, true, LEFT, COLOR_ACCENT)
    CreateJuicyBtn(headerBtns, "Промокоды", function() end, true, RIGHT, Color(255, 200, 50))
end



local function NewClose(pnl)
    if IsValid(shizlib.f4.Menu) then
        shizlib.f4.Menu:SetVisible(not shizlib.f4.Menu:IsVisible())
        return
    end
end

local function createGPSPanel(pnl)
    local scroll = vgui.Create('DScrollPanel', pnl)
    scroll:Dock(FILL)
    scroll:DockMargin(s(15), s(15), s(15), s(15))
    
    local sbar = scroll:GetVBar()
    sbar:SetWide(s(4))
    sbar.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(COLOR_BG, 100)) end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    sbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(COLOR_ACCENT, 150)) end

    if not ChaikaConfig or not ChaikaConfig.Metka then
        local lbl = vgui.Create("DLabel", scroll)
        lbl:SetText("GPS навигатор не инициализирован")
        lbl:SetFont("org_20")
        lbl:SetTextColor(Color(200, 200, 200))
        lbl:Dock(TOP)
        return
    end

    local grid = vgui.Create("DIconLayout", scroll)
    grid:Dock(TOP)
    grid:SetSpaceX(s(10))
    grid:SetSpaceY(s(10))

    for _, gps in pairs(ChaikaConfig.Metka) do
        local itemW = (pnl:GetWide() - s(60)) / 2
        local card = grid:Add("DButton")
        card:SetSize(itemW, s(85))
        card:SetText("")
        card.lerpHover = 0
        card.active = GetConVarNumber(string.format('shizlib_gps_%s', gps[3])) == 1
        
        card.Paint = function(self, w, h)
            self.lerpHover = math.Approach(self.lerpHover, self:IsHovered() and 1 or 0, FrameTime() * 5)
            self.active = GetConVarNumber(string.format('shizlib_gps_%s', gps[3])) == 1
            
            RNDX.Draw(12, 0, 0, w, h, COLOR_BG, RNDX.SHAPE_FIGMA)
            if self.active or self.lerpHover > 0 then
                local alpha = self.active and 40 or (self.lerpHover * 20)
                RNDX.Draw(12, 0, 0, w, h, ColorAlpha(COLOR_ACCENT, alpha), RNDX.SHAPE_FIGMA, RNDX.BLUR)
            end

            if self.lerpHover > 0 then
                surface.SetDrawColor(ColorAlpha(COLOR_ACCENT, self.lerpHover * 20))
                surface.DrawRect(0, 0, w, h)
            end
            
            local barWidth = s(4)
            local barHeight = self.active and h or (self.lerpHover * h)
            if barHeight > 0 then
                draw.RoundedBoxEx(12, 0, (h - barHeight) / 2, barWidth, barHeight, COLOR_ACCENT, true, false, true, false)
            end

            draw.SimpleText(string.upper(gps[1]), "org_22", s(20), h/2 - s(12), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            local statusText = self.active and "СИГНАЛ АКТИВЕН" or "ОЖИДАНИЕ"
            local statusCol = self.active and Color(100, 255, 100) or Color(150, 150, 150)
            
            surface.SetDrawColor(statusCol)
            draw.NoTexture()
            local dotSize = s(4)
            surface.DrawRect(s(20), h/2 + s(10), dotSize, dotSize)
            draw.SimpleText(statusText, "org_14", s(30), h/2 + s(10), statusCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            local iconSize = s(24)
            DTR(w - iconSize - s(15), h/2 - iconSize/2, iconSize, iconSize, self.active and COLOR_ACCENT or Color(80, 80, 80), Material("k_f4/actions.png"))
        end

        card.DoClick = function()
            surface.PlaySound('bobby/pop.mp3')
            if timer.Exists('TurnMeToPoint') then timer.Remove('TurnMeToPoint') end
            
            local conVarName = string.format('shizlib_gps_%s', gps[3])
            local newState = GetConVarNumber(conVarName) == 1 and 0 or 1
            RunConsoleCommand(conVarName, newState)
            if newState == 0 then return end
            
            local startAng = LocalPlayer():EyeAngles()
            local destPos = Vector(gps[2])
            local endAngle = (destPos - LocalPlayer():EyePos()):Angle()
            local ratio = 0
            
            timer.Create('TurnMeToPoint', 0, 0, function()
                ratio = math.min(ratio + 2.5 * FrameTime(), 1)
                local smoothedRatio = math.ease.OutExpo(ratio)
                local ang = LerpAngle(smoothedRatio, startAng, endAngle)
                ang.roll = 0
                LocalPlayer():SetEyeAngles(ang)
                if ratio >= 1 then timer.Remove('TurnMeToPoint') end
            end)
        end
    end
end

local function renderButtons(cat, tab, color, category, search)
	for k, v in SortedPairsByMemberValue(tab.cat, "price") do
		if search then
			if not string.find(v.name:lower(), search:lower())
			and not string.find(v.category:lower(), search:lower())
			and not string.find(v.ent:lower(), search:lower())
			and not string.find(v.cmd and v.cmd:lower() or '', search:lower()) then continue end
		end

		if category and v.category ~= category then continue end

		local row = cat:Add('Panel')
		row:DockMargin(0,0,0,1)
        row.lerpHover = 0
        row.Paint = function(self, w, h) RNDX.Draw(8, 0, 0, w, h, Color(22, 22, 22), RNDX.SHAPE_FIGMA) end
        row.PerformLayout = function(self) row:SetSize(cat:GetWide() / 3 - 15, 80) end

        local mdl = ""
        if v.isWeapon then
            local storedInfo = weapons.Get(v.ent)
            mdl = storedInfo.WorldModel
        else
            mdl = v.mdl
        end

        row.item = row:Add("SpawnIcon")
        local item = row.item
        item:SetModel(mdl)
        item:Dock(LEFT)
        item:DockMargin(5, 5, 5, 5)
        item:SetCursor("hand")
        item:SetTooltip(nil)
        item.PerformLayout = function(self) self:SetWide(self:GetTall()) end
        item.PaintOver = function(self, w, h)
            melon.Start()
                surface.SetDrawColor(180, 180, 180)
                surface.DrawRect(0, 0, w, h)
            melon.Source()
                draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 100))
            melon.And(melon.KIND_CUT)
                draw.RoundedBox(0, 3, 3, w - 6, h - 6, color_white)
            melon.End(melon.KIND_STAMP)
        end
        item.DoClick = function(self) tab.funcToBuy(k, v) end
        item.DoRightClick = item.DoClick

        row.BtnBuy = row:Add("DButton")
        row.BtnBuy:Dock(FILL)
        row.BtnBuy:SetZPos(2)
        row.BtnBuy:SetText("")
        row.BtnBuy.Paint = function(self, w, h)
            row.lerpHover = math.Clamp(self:IsHovered() and row.lerpHover + FrameTime()*3 or row.lerpHover - FrameTime()*3, 0, 1)
            draw.RoundedBox(0, 0, 0, w, h, shizlib.surface.LerpColor(row.lerpHover,Color(40, 40, 40, 200), Color(40, 40, 40, 0)))
        end
        row.BtnBuy.DoClick = function(self) tab.funcToBuy(k, v) end
        row.BtnBuy.DoRightClick = row.BtnBuy.DoClick

        row.Paint = function(self, w, h)
            local col = self.lerpHover > 0 and COLOR_HOVER or Color(30, 30, 30, 200)
            RNDX.Draw(8, 0, 0, w, h, col, RNDX.SHAPE_FIGMA)
            draw.SimpleText(v.name, "org_25", self.item:GetWide() + s(15), s(10), shizlib.surface.LerpColor(row.lerpHover, color_white, COLOR_ACCENT), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local priceColor = LocalPlayer():CanAfford(v.price) and color_white or Color(230, 30, 30)
            draw.SimpleText(("%s: %s%s"):format("Цена", string.Comma(v.price), shizlib.GetCurrency()), "org_20", item:GetWide() + s(15), s(45), priceColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
	end
end

local function renderCat(DScrollPanel, tab, search)
    local color = Color(44, 44, 67)
	local renderedCategories = {}

	for k, v in pairs(tab.cat) do
		if search then
			if not string.find(v.name:lower(), search:lower())
			and not string.find(v.category:lower(), search:lower())
			and not string.find(v.ent:lower(), search:lower())
			and not string.find(v.cmd and v.cmd:lower() or '', search:lower()) then continue end
		end

		if renderedCategories[v.category] then continue end
		renderedCategories[v.category] = true

		local cat = vgui.Create('DIconLayout', DScrollPanel)
		cat:Dock(TOP)
		cat:DockMargin(0,0,0,1)
		cat:SetSpaceY(5)
        cat:SetSpaceX(5)
		cat.Paint = nil

		local catBtn = vgui.Create('DButton', cat)
		catBtn:Dock(TOP)
		catBtn:SetTall(30)
		catBtn:SetText("")
		catBtn:DockMargin(0,0,0,1)
		catBtn.DoClick = function(self)
			if cat.closed then
				local tall = 0
				for k, v in pairs(cat:GetChildren()) do
					if k > 1 then
						v:SetVisible(true)
						tall = tall + v:GetTall() + 1
					end
				end
				cat:SizeTo(cat:GetWide(), cat:GetTall()+tall, 0.15, 0, -1, function() cat.closed = false end)
			else
				cat:SizeTo(cat:GetWide(), self:GetTall(), 0.15, 0, -1, function()
					for k, v in pairs(cat:GetChildren()) do if k > 1 then v:Hide() end end
					cat.closed = true
				end)
			end
		end
        catBtn.lerpHover = 0
        catBtn.Paint = function(self, w, h)
			self.lerpHover = math.Clamp(self:IsHovered() and self.lerpHover + FrameTime()*3 or self.lerpHover - FrameTime()*3, 0, 1)
            RNDX.Draw(8, 0, 0, w, h, shizlib.surface.LerpColor(self.lerpHover,Color(22, 22, 22),Color(255,77,119)), RNDX.SHAPE_FIGMA)
            draw.SimpleText(v.category, "org_20", w/2, h/2, self.closed and color_black or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

		renderButtons(cat, tab, color, v.category, search or false)

		if #cat:GetChildren() <= 1 then
			cat:Remove()
			return
		end

		cat:InvalidateLayout(true)
		cat:SizeToChildren(false,true)

		if GetConVar('shizlib_f4_close_tabs'):GetInt() == 1 and not search then
			cat:SetSize(cat:GetWide(),catBtn:GetTall())
			cat.closed = true
		end
	end
end

local function showItems(DScrollPanel, tab, search)
	DScrollPanel:Clear()
	if tab.disableCats then renderButtons(DScrollPanel, tab, search) else renderCat(DScrollPanel, tab, search) end
	if search and #DScrollPanel:GetCanvas():GetChildren() <= 1 then
		local notFound = vgui.Create('DLabel', DScrollPanel)
		notFound:SetText('Здесь пусто!')
		notFound:SetFont('org_20')
		notFound:SizeToContents()
		notFound:Dock(TOP)
		notFound:DockMargin(5,5,0,0)
	end
end

local createShopWep = function(pnl, tab)
    local scroll
    pnl.searchBar = pnl:Add("SHZTextEntry")
    local searchBar = pnl.searchBar
    searchBar:Dock(TOP)
    searchBar:DockMargin(0, 0, 0, s(2))
    searchBar:SetTall(s(30))
    searchBar:SetFont("org_20")
    searchBar:SetPlaceholderText("Search...")
    searchBar:SetUpdateOnType(true)
    searchBar.OnChange = function(self) showItems(scroll, tab, self:GetText()) end

    pnl.Scroll = pnl:Add("DScrollPanel")
    scroll = pnl.Scroll
    scroll:Dock(FILL)
    scroll.items = {}
    local sbar = scroll:GetVBar()
    sbar.Paint = function() end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    sbar.btnGrip.Paint = function() end
    scroll.Paint = function(self, w, h) end

    showItems(scroll, tab)
end

local categoriess = {["Гражданские"] = true,["Государственные служащие"] = true, }

local getCountJob = function(name)
    local count = 0
    for _, v in ipairs(player.GetAll()) do if v:GetNWString("Jobs", "") == name then count = count + 1 end end
    return count
end

local createJobsPanel = function(pnl)
    local col = CFG.theme
    pnl.backgr = pnl:Add("Panel")
    pnl.backgr:Dock(FILL)

    local left = pnl.backgr:Add('Panel')
    left:Dock(LEFT)
    left:SetWide(s(750))

    local scrl = left:Add('DScrollPanel')
    scrl:Dock(FILL)
    scrl:DockMargin(0, s(10), s(10), s(10))
    scrl.Paint = nil
    scrl.VBar:SetWide(s(4))
    local bar = scrl.VBar
    bar:SetHideButtons(true)
    bar.Paint = function(this, w, h) RNDX.Draw(2, 0, 0, w, h, Color(26,27,27)) end

    for cat, _ in pairs(categoriess) do
        local pnlc = scrl:Add('DCollapsibleCategory')
        pnlc:Dock(TOP)
        pnlc:SetLabel('')
        pnlc.Header:SetTall(s(50))
        pnlc.Header:DockMargin(s(25), 0, s(15), s(5))
        pnlc.Paint = nil
        pnlc.TABLE = {}

        pnlc.Header.Paint = function(self, w, h)
            RNDX.Draw(4, 0, 0, w, h, col.bg)
            draw.SimpleText(cat, 'org_20', w * 0.5, h * 0.5, col.white, 1, 1)
        end

        local List = vgui.Create('DIconLayout', pnlc)
        List:Dock(TOP)
        List:SetSpaceY(10)
        List:SetSpaceX(10)
        List:DockMargin(s(25), s(5), 0, 0)

        for inx, v in pairs(rp.Classes) do
            if v.Hide then continue end
            if cat == v.Category then
                local beauty = v.Max == 0 and '∞' or v.Max
                local jcol = v.Color
                local name = v.Name

                if pnlc.TABLE[v.Name] then continue end
                pnlc.TABLE[v.Name] = List:Add('Panel')
                local item = pnlc.TABLE[v.Name]
                item:SetSize(s(223), s(223))

                item.Paint = function(self, w, h) RNDX.Draw(4, 0, 0, w, h, ColorAlpha(col.bg, 150)) end

                local jmodel = "model/error.mdl"
                if v.Name ~= "Гражданский" then jmodel = istable(rp.Classes[inx].Model) and rp.Classes[inx].Model[1] or rp.Classes[inx].Model
                else local tempTable = table.Random(hg.Appearance.PlayerModels[math.random()]) jmodel = tempTable.mdl end
                
                local jobmodel = item:Add("DModelPanel")
                jobmodel:Dock(FILL)
                jobmodel:SetFOV(6.4)
                jobmodel:SetCamPos(Vector(310, 50, 45))
                jobmodel:SetLookAt(Vector(0, 0, 60))
                jobmodel:SetModel(jmodel)
                jobmodel.LayoutEntity = function() end

                local vip = rp.Classes[inx].vip and ' [VIP]' or ''
                jobmodel.PaintOver = function(self, w, h)
                    RNDX.Draw(5, 0, h - s(30), w, s(30), self.Hovered and ColorAlpha(jcol, 200) or jcol)
                    draw.SimpleText(("%s/%s"):format(getCountJob(v.Name), v.Max == 0 and '∞' or v.Max), 'org_18', w * 0.5, h - s(5), self.Hovered and ColorAlpha(col.white, 100) or col.white, 1, 4)
                    draw.SimpleText(name .. vip, 'org_14', w * 0.5, s(5), self.Hovered and ColorAlpha(col.white, 100) or col.white, 1, 3)
                end

                jobmodel.DoClick = function(self, w, h)
                    if IsValid(backgr_right) then backgr_right:Remove() end
                    backgr_right = pnl.backgr:Add('Panel')
                    backgr_right:Dock(FILL)
                    backgr_right:DockMargin(s(25), s(10), s(25), s(10))

                    local title = backgr_right:Add('Panel')
                    title:Dock(TOP)
                    title:SetTall(s(50))
                    title:DockMargin(0, 0, 0, s(10))
                    title.Paint = function(self, w, h)
                        RNDX.Draw(4, 0, 0, w, h, jcol)
                        draw.SimpleText(name, 'org_20', w * 0.5, h * 0.5, col.white, 1, 1)
                    end

                    if v.description then
                        local desc = backgr_right:Add('DLabel')
                        desc:SetFont('org_18')
                        desc:SetTextColor(col.white)
                        desc:SetText(v.description)
                        desc:SetPos(0, s(70))
                        desc:SetWrap(true)
                        desc:SetContentAlignment(7)
                        backgr_right.PerformLayout = function(self, w, h) desc:SetSize(w, s(300)) end
                    end

                    local jobmodel2 = backgr_right:Add("DModelPanel")
                    jobmodel2:Dock(FILL)
                    jobmodel2:SetFOV(6.4)
                    jobmodel2:SetCamPos(Vector(310, 50, 45))
                    jobmodel2:SetLookAt(Vector(0, 0, 60))
                    jobmodel2:SetModel(jmodel)
                    jobmodel2:SetCursor('arrow')
                    jobmodel2.LayoutEntity = function() end

                    local down_pnl = backgr_right:Add('Panel')
                    down_pnl:Dock(BOTTOM)
                    down_pnl:SetTall(s(50))
                    down_pnl:DockMargin(0, s(10), 0, 0)

                    local pick = down_pnl:Add('DButton')
                    pick:Dock(FILL)
                    pick:SetText('')
                    pick:DockMargin(s(10), 0, s(10), 0)
                    pick.Paint = function(self, w, h)
                        RNDX.Draw(4, 0, 0, w, h, self.Hovered and col.white or col.black)
                        draw.SimpleText('Выбрать', 'org_20', w * 0.5, h * 0.5, self.Hovered and col.black or col.white, 1, 1)
                    end

                    pick.DoClick = function()
                        if v.vip and (not LocalPlayer():IsVIP()) then
                            ui.BoolRequest('VIP', 'Это вип работа! Не желаете приобрести VIP?', function(ans)
                                if ans == true then NewClose(fr) RunConsoleCommand("say", "/donate") end
                            end)
                            return
                        end
                        if v.vote then NewClose(fr) else RunConsoleCommand("say", ("/job %s"):format(v.Command)) NewClose(fr) end
                    end
                end
                if inx == 1 then jobmodel:DoClick() end
            end
        end
    end
end

local function BuildRichTopInsideF4(parent)
    parent:Clear()

    local header = vgui.Create("DPanel", parent)
    header:Dock(TOP)
    header:SetTall(s(95))
    header:DockMargin(s(15), 0, s(15), s(15))
    header.Paint = function(self, w, h)
        RNDX.Draw(12, 0, 0, w, h, COLOR_ALT, RNDX.SHAPE_FIGMA)
        RNDX.Draw(12, 0, 0, s(6), h, Color(100, 255, 100), RNDX.SHAPE_FIGMA)
        surface.SetDrawColor(ColorAlpha(Color(100, 255, 100), 10))
        surface.SetMaterial(Material("vgui/gradient-r"))
        surface.DrawTexturedRect(0, 0, w, h)
    end

    local title = vgui.Create("DLabel", header)
    title:Dock(TOP)
    title:SetFont("org_30")
    title:SetText("СПИСОК ФОРБС")
    title:SetTextColor(COLOR_TEXT)
    title:SizeToContents()
    title:DockMargin(s(25), s(20), 0, 0)

    local desc = vgui.Create("DLabel", header)
    desc:Dock(TOP)
    desc:SetFont("org_18")
    desc:SetText("Топ 50 самых богатых людей города.")
    desc:SetTextColor(Color(180, 180, 180))
    desc:SizeToContents()
    desc:DockMargin(s(25), s(5), 0, 0)

    local scroll = vgui.Create("SHZScrollPanel", parent)
    scroll:Dock(FILL)
    scroll:DockMargin(s(15), 0, s(10), s(15))

    local loadLabel = vgui.Create("DLabel", scroll)
    loadLabel:Dock(TOP)
    loadLabel:DockMargin(0, s(20), 0, 0)
    loadLabel:SetFont("org_20")
    loadLabel:SetText("Загрузка данных из базы...")
    loadLabel:SetTextColor(Color(150, 150, 150))
    loadLabel:SetContentAlignment(5)

    shizlib.f4.RichTopScroll = scroll

    net.Start("shizlib_f4_request_rich_top")
    net.SendToServer()
end

local shopCategories = {
    ["GPS"] = {
        id = 2.5,
        draw = function(pnl, data)
            surface.PlaySound("bobby/pop.mp3")
            createGPSPanel(pnl)
        end,
        icon = Material("k_f4/actions.png"),
    },
    ["Профессии"] = {
        id = 2,
        draw = function(pnl, data)
            surface.PlaySound("bobby/pop.mp3")
            createJobsPanel(pnl)
        end,
        icon = Material("k_f4/jobs.png"),
    },
    ["Организации"] = {
        id = 3,
        draw = function(pnl, data)
            surface.PlaySound("bobby/pop.mp3")
            BuildOrgMenuInsideF4(pnl)
        end,
        icon = Material("k_f4/spyware.png"),
    },
    ["Топ Богачей"] = {
        id = 3.8,
        draw = function(pnl, data)
            surface.PlaySound("bobby/pop.mp3")
            BuildRichTopInsideF4(pnl)
        end,
        icon = Material("k_f4/items.png"),
    },
    ["Донат"] = {
        id = 4,
        draw = function(pnl, data)
            surface.PlaySound("bobby/pop.mp3")
            BuildDonateMenuInsideF4(pnl)
        end,
        icon = Material("k_f4/items.png"),
    },
    ["Законы"] = {
        id = 997,
        draw = function(pnl, data)
            surface.PlaySound("bobby/pop.mp3")
            if IsValid(shizlib.f4.Menu) then shizlib.f4.Menu:SetVisible(false) gui.HideGameUI() end
            gui.OpenURL("https://docs.google.com/document/d/1yb3ol63hMHBwdNsufmPO8_Vk5DSUE0f4OOvJ5lcadsE/edit?tab=t.0")
        end,
        icon = Material("k_f4/rules.png"),
    },
    ["Правила"] = {
        id = 998,
        draw = function(pnl, data)
            surface.PlaySound("bobby/pop.mp3")
            if IsValid(shizlib.f4.Menu) then shizlib.f4.Menu:SetVisible(false) gui.HideGameUI() end
            gui.OpenURL("https://docs.google.com/document/d/1bKF7lr-u2FvWsw_Z5iQH7KtEhkORszVJ33g2FT7TCf4/edit?usp=sharing")
        end,
        icon = Material("k_f4/rules.png"),
    },["Discord"] = {
        id = 999,
        draw = function(pnl, data)
            surface.PlaySound("bobby/pop.mp3")
            if IsValid(shizlib.f4.Menu) then shizlib.f4.Menu:SetVisible(false) gui.HideGameUI() end
            gui.OpenURL("https://discord.gg/cSmhecewkY")
        end,
        icon = Material("k_f4/discord.png"),
    },
}

shizlib.f4.CreateMenu = function()
    local scrw, scrh = shizlib.hud.ScrW, shizlib.hud.ScrH

    if IsValid(shizlib.f4.Menu) then
        shizlib.f4.Menu:Remove()
    end

    shizlib.f4.Menu = vgui.Create("EditablePanel")
    local Menu = shizlib.f4.Menu
    Menu:SetSize(0, 0)
    Menu:SetPos(scrw / 2, scrh / 2)
    Menu:MakePopup()
    Menu:MoveTo(0, 0, 0, 0, -1)

    local headers = Menu:Add("Panel")
    headers:Dock(TOP)
    headers:DockMargin(s(400), 0, 0, s(5))
    headers:SetTall(0)
    headers.name = ""
    headers.Paint = function(self, w, h)
        RNDX.Draw(0, 0, 0, w, h, COLOR_BG, RNDX.SHAPE_FIGMA)
        draw.SimpleText( self.name, "org_40", s(20), h/2, color_white, 0, 1 )
    end 

    headers.cls = headers:Add("DButton")
	local cls = headers.cls
	cls:SetPos( ( shizlib.hud.ScrW - s(400)) - s(20 + 95), s(15))
	cls:SetSize(s(95), s(26))
	cls:SetCursor("hand")
	cls:SetText("")
	cls.lerpHover = 0
	cls.Paint = function(self, w, h)
		self.lerpHover = math.Clamp(self:IsHovered() and self.lerpHover + FrameTime()*3 or self.lerpHover - FrameTime()*3, 0, 1)
		draw.RoundedBox(6,0,0,w,h, shizlib.surface.LerpColor(self.lerpHover,Color(255,255,255,0),color_white) )
		draw.RoundedBox(5,w-s(38),0,s(38),h,color_white)
		draw.SimpleText("Выход", "org_14", s(5), h*.5, shizlib.surface.LerpColor(self.lerpHover,color_white,color_black), 0, 1)
		draw.SimpleText("Esc", "org_14", w-s(7), h*.5, color_black, 2, 1)
	end
	cls.DoClick = function(self)
		Menu:SetVisible(false)
        gui.HideGameUI()
	end
	cls.DoRightClick = cls.DoClick
	cls.Think = function(self)
		if(input.IsKeyDown(KEY_ESCAPE) || gui.IsGameUIVisible()) then
			Menu:SetVisible(false)
            gui.HideGameUI()
		end
	end

    Menu.Panel = Menu:Add("EditablePanel")
    local pnl = Menu.Panel
    pnl:SetSize(0, scrh - s(40))
    pnl:SetPos(scrw - s(440), s(110))
    pnl.Paint = function(n, w, h) end

    Menu:SizeTo(scrw, scrh, 0, 0, -1, function()

            pnl:SizeTo(scrw - s(410), scrh - s(80), 0, 0, -1)
            pnl:MoveTo(s(405), s(70), 0, 0, -1)
        
            headers:SizeTo(headers:GetWide(), s(60), 0, 0, -1)

            Menu.Category = Menu:Add("Panel")
            local cat = Menu.Category
            cat:SetSize(0, scrh)
            cat:SetPos(0, 0)
            cat:SizeTo(s(400), scrh, 0, 0, -1)
            cat.Items = {}
            cat.Paint = function(self, w, h)
                RNDX.Draw(0, 0, 0, w, h, Color(22, 22, 22), RNDX.SHAPE_FIGMA)
            end

            cat.Items[0] = cat:Add("Panel")
            local item = cat.Items[0]
            item:Dock(TOP)
            item:DockMargin(0, 0, 0, s(10))
            item:SetTall(s(60))
            item.Paint = function(self, w, h)
                RNDX.Draw(0, 0, 0, w, h, Color(17, 17, 17), RNDX.SHAPE_FIGMA)
                draw.SimpleText( "Добро пожаловать,", "org_20", s(75), s(5), Color(57, 57,57), 0, 0 )
                draw.SimpleText( LocalPlayer():Name(), "org_25", s(75), s(25), color_white, 0, 0 )
            end

            item.Avatar = item:Add("AvatarImage")
            item.Avatar:SetPos(s(15), s(5))
            item.Avatar:SetSize(s(50), s(50))
            item.Avatar:SetSteamID(LocalPlayer():SteamID64(), 128)

            local i = 1
            for name, data in SortedPairsByMemberValue(shopCategories,'id') do
                cat.Items[i] = cat:Add("DButton")
                local item = cat.Items[i]
                item.ShowIn = CurTime() + (.2 * i)
                item:SetAlpha(0)
                item:AlphaTo(255, .4, .2 * i)
                item:Dock(TOP)
                item:DockMargin(s(5), s(5), s(5), 0)
                item:SetTall(40)
                item:SetText("")
                item.active = false
		        item.lerpHover = 0
                pnl.categoryName = name
                item.Paint = function(self, w, h)
		            self.lerpHover = math.Clamp(self:IsHovered() and self.lerpHover + FrameTime()*3 or self.lerpHover - FrameTime()*3, 0, 1)
                    if item.ShowIn > CurTime() then return end
                    
                    local lerpVal = math.max(self.lerpHover, self.active and 1 or 0)
                    local iconCol = shizlib.surface.LerpColor(lerpVal, Color(150, 150, 150), COLOR_ACCENT)
                    local textCol = shizlib.surface.LerpColor(lerpVal, Color(200, 200, 200), color_white)

                    DTR(s(25), h/2 - 10, 20, 20, iconCol, data.icon)
                    draw.SimpleText(name, "org_22", s(60), h/2, textCol, 0, 1)
                    
                    if self.active then draw.RoundedBox(0, 0, 0, s(4), h, COLOR_ACCENT) end
                end
                item.DoClick = function(self)
                    headers.name = name
                    for _, items in ipairs(cat.Items) do items.active = false end
                    self.active = true
                    pnl:Clear()
                    data.draw(pnl, data)
                end
                item.DoRightClick = item.DoClick
                i = i + 1
            end
    end)
    Menu.Paint = function(self, w, h)
        RNDX.Draw(0, 0, 0, w, h, nil, RNDX.SHAPE_FIGMA + RNDX.BLUR)
    end
end

concommand.Add("shizlib_f4_open", function() shizlib.f4.CreateMenu() end)
hook.Add("PlayerButtonDown", "F4Open", function(ply, but)
    if ply == LocalPlayer() and but == KEY_F4 and IsFirstTimePredicted() then shizlib.f4.CreateMenu() end
end)
concommand.Add("shizlib_f4_reload", function() if IsValid(shizlib.f4.Menu) then shizlib.f4.Menu:Remove() end end)

netstream.Hook("shizlib_playermodel_sync", function(data)
    local tbl = util.JSONToTable(data.tbl)
    LocalPlayer().__skinData = tbl
end)

local autoCompliteForCommand = function(cmd, args, ...)
    local possibleArgs = { ... }
	local autoCompletes = {}
	local arg = string.Split( args:TrimLeft(), " " )
	local lastItem = nil
	for i, str in pairs( arg ) do
		if ( str == "" && ( lastItem && lastItem == "" ) ) then table.remove( arg, i ) end
		lastItem = str
	end

	local numArgs = #arg
	local lastArg = table.remove( arg, numArgs )
	local prevArgs = table.concat( arg, " " )
	if ( #prevArgs > 0 ) then prevArgs = " " .. prevArgs end

	local possibilities = possibleArgs[ numArgs ] or { lastArg }
	for _, acStr in pairs( possibilities ) do
		if ( !acStr:StartsWith( lastArg ) ) then continue end
		table.insert( autoCompletes, cmd .. prevArgs .. " " .. acStr )
	end
	return autoCompletes
end

concommand.Add("shizlib_f4_buy", function(ply, cmd, args) RunConsoleCommand("__shizlib_f4_buy", args[2], args[1]) end, function(cmd, args)
    return autoCompliteForCommand(cmd, args, shizlib.config_rp.AllCategories, shizlib.config_rp.AllItems)
end)

net.Receive("Org_SendAllOrgs", function()
    local orgs = net.ReadTable()
    shizlib.f4.DataCache.AllOrgs = orgs
    
    if IsValid(shizlib.f4.OrgAllPanel) then 
        shizlib.f4.OrgAllPanel:Populate(orgs) 
    end
end)

net.Receive("Org_SendMyOrgData", function()
    local hasData = net.ReadBool()
    
    if not hasData then 
        shizlib.f4.DataCache.MyOrg = nil
        if IsValid(shizlib.f4.OrgMyPanel) then
            shizlib.f4.OrgMyPanel:SetData("ОШИБКА ДАННЫХ", false, {}, {}, "Организация не найдена на сервере или была удалена.", Color(255, 80, 80), 0, 0, 0)
        end
        return 
    end
    
    local d = {
        orgName = net.ReadString(),
        isOwner = net.ReadBool(),
        members = net.ReadTable(),
        ranks = net.ReadTable(),
        motd = net.ReadString(),
        color = net.ReadColor(),
        points = net.ReadDouble(),
        bank = net.ReadUInt(32),
        slotLevel = net.ReadUInt(8),
        extraSlots = net.ReadUInt(16)
    }
    shizlib.f4.DataCache.MyOrg = d

    if IsValid(shizlib.f4.OrgMyPanel) then 
        shizlib.f4.OrgMyPanel:SetData(d.orgName, d.isOwner, d.members, d.ranks, d.motd, d.color, d.points, d.bank, d.slotLevel, d.extraSlots)
    end
end)

net.Receive("Org_SendOrgMembers", function()
    if not IsValid(shizlib.f4.OrgMembersScroll) then return end
    local scroll = shizlib.f4.OrgMembersScroll
    local count = net.ReadUInt(8)
    
    scroll:Clear()
    for i = 1, count do
        CreateMemberEntry({
            SteamID = net.ReadString(), 
            Name = net.ReadString(), 
            Rank = net.ReadString(), 
            Online = net.ReadBool(),
            LastSeen = net.ReadUInt(32),
            Playtime = net.ReadUInt(32)
        }, scroll, false, nil, "", i)
    end
end)

net.Receive("Org_UpdateMotDNotify", function()
    local newMotD = net.ReadString()
    if IsValid(shizlib.f4.OrgMyPanel) then shizlib.f4.OrgMyPanel:UpdateMotD(newMotD) end
end)

local PLAYER = FindMetaTable("Player")
function PLAYER:GetOrg() return self:GetNetVar("Org") end
function PLAYER:GetOrgData() return self:GetNetVar("OrgData") end
function PLAYER:GetOrgColor() local c = self:GetNetVar("OrgColor") return c and Color(c.r, c.g, c.b) or Color(255, 255, 255) end

net.Receive("shizlib_f4_send_rich_top", function()
    if not IsValid(shizlib.f4.RichTopScroll) then return end
    local scroll = shizlib.f4.RichTopScroll
    scroll:Clear()

    local count = net.ReadUInt(8)
    if count == 0 then
        local emptyLabel = vgui.Create("DLabel", scroll)
        emptyLabel:Dock(TOP)
        emptyLabel:DockMargin(0, s(20), 0, 0)
        emptyLabel:SetFont("org_20")
        emptyLabel:SetText("Список пуст.")
        emptyLabel:SetTextColor(Color(150, 150, 150))
        emptyLabel:SetContentAlignment(5)
        return
    end

    for i = 1, count do
        local steamid = net.ReadString()
        local steamid64 = net.ReadString()
        local walletStr = net.ReadString()

        local pnl = vgui.Create("DPanel", scroll)
        pnl:Dock(TOP)
        pnl:SetTall(s(65))
        pnl:DockMargin(0, 0, s(5), s(10))
        
        pnl.playerName = steamid 
        
        if steamid64 ~= "" then
            steamworks.RequestPlayerInfo(steamid64, function(steamName)
                if IsValid(pnl) then
                    pnl.playerName = steamName or steamid
                end
            end)
        end

        if ApplySpawnAnimation then ApplySpawnAnimation(pnl, i) end

        pnl.lerpHover = 0
        pnl.Paint = function(self, w, h)
            self.lerpHover = Lerp(FrameTime() * 8, self.lerpHover, self:IsHovered() and 1 or 0)
            RNDX.Draw(8, 0, 0, w, h, Color(22, 22, 28, 255), RNDX.SHAPE_FIGMA)

            if self.lerpHover > 0 then
                RNDX.Draw(8, 0, 0, w, h, ColorAlpha(Color(100, 255, 100), 15 * self.lerpHover), RNDX.SHAPE_FIGMA)
                RNDX.Draw(8, 0, 0, s(5), h, ColorAlpha(Color(100, 255, 100), 255 * self.lerpHover), RNDX.SHAPE_FIGMA)
            end

            local medalCol = color_white
            if i == 1 then medalCol = Color(255, 215, 0)
            elseif i == 2 then medalCol = Color(200, 200, 200)
            elseif i == 3 then medalCol = Color(205, 127, 50)
            end

            draw.SimpleText("#" .. i, "org_25", s(20), h/2, medalCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            draw.SimpleText(self.playerName, "org_22", s(120), h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            local priceCol = shizlib.surface.LerpColor(self.lerpHover, Color(100, 255, 100), color_white)
            draw.SimpleText(string.Comma(walletStr) .. " " .. (shizlib.GetCurrency and shizlib.GetCurrency() or "$"), "org_22", w - s(25), h/2, priceCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        local avaFrame = vgui.Create("DPanel", pnl)
        avaFrame:SetSize(s(45), s(45))
        avaFrame:SetPos(s(60), s(10))
        avaFrame.Paint = function(self, w, h) RNDX.Draw(6, 0, 0, w, h, Color(15, 15, 20), RNDX.SHAPE_FIGMA) end
        
        local ava = vgui.Create("AvatarImage", avaFrame)
        ava:Dock(FILL)
        ava:DockMargin(s(2), s(2), s(2), s(2))
        if steamid64 and steamid64 ~= "" then ava:SetSteamID(steamid64, 64) end
    end
end)

net.Receive("OnyxDonateInventory.Sync", function()
	local tbl = net.ReadTable()
	if IsValid(LocalPlayer()) then
		LocalPlayer().DonateInventory = tbl
		if IsValid(onyx.InventoryScroll) and onyx.RefreshInventoryUI then
			onyx.RefreshInventoryUI()
		end
	end
end)