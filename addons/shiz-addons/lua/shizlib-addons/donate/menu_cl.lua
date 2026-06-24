onyx = onyx or {}

-- [ CFG THEME INTEGRATION ]
local theme = CFG and CFG.theme or {
    bg = Color(22, 22, 22),
    bg_alt = Color(40, 40, 40),
    red = Color(222,91,73, 255),
    accent = Color(255,77,119),
    focus = Color(245, 245, 245, 25),
    black = Color(12, 12, 12),
    black2 = Color(24, 24, 24),
    black3 = Color(30, 30, 30),
    black4 = Color(17, 17, 17, 200),
    white = Color(230, 230, 230),
    hvr = Color(22, 22, 22, 100),
}

-- [ MATERIALS & CONFIG ]
local gold = Material('materials/shizlib/donate/coins.png', 'smooth')
local promo = Material('materials/shizlib/donate/promo.png', 'smooth')
local shop = Material('materials/shizlib/donate/inv.png', 'smooth')
local history = Material('materials/shizlib/donate/history.png', 'smooth')
local cart = Material('materials/shizlib/donate/cart.png', 'smooth')
local privileges = 'materials/shizlib/donate/privileges.png'
local guns = 'materials/shizlib/donate/guns.png'
local money = 'materials/shizlib/donate/money.png'
local other = 'materials/shizlib/donate/other.png'

local s = shizlib.surface and shizlib.surface.s or function(v) return v end
local RNDX = include("shizlib/client/rndx_cl.lua")

local color_accent = theme.accent
local color_accent_dark = theme.red
local color_glass = ColorAlpha(theme.black, 240)
local color_offwhite = Color(210, 210, 210)
local color_muted = Color(140, 140, 140)

local blur = Material('pp/blurscreen')
local gradient_up = Material('gui/gradient_up')
local gradient_down = Material('gui/gradient_down')
local gradient_right = Material('gui/gradient')
local panel = FindMetaTable('Panel')

-- [ SOUNDS ]
local sound_hover = "ui/buttonrollover.wav"
local sound_click = "ui/buttonclick.wav"

local function PlayHover() surface.PlaySound(sound_hover) end
local function PlayClick() 
    if shizlib and shizlib.surface and shizlib.surface.clickSound then 
        shizlib.surface.clickSound() 
    else 
        surface.PlaySound(sound_click) 
    end 
end

--[ UTILS ]
function panel:DrawBlur(amount, heavyness)
    if not IsValid(self) then return end
    local x, y = self:LocalToScreen(0, 0)
    local scrW, scrH = ScrW(), ScrH()
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(blur)
    for i = 1, heavyness do
        blur:SetFloat('$blur', (i / 3) * (amount or 6))
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
    end
end

local function DrawShadow(x, y, w, h, passes, opac)
    for i = 1, passes do
        RNDX.Draw(16, x - i, y - i, w + (i * 2), h + (i * 2), Color(0, 0, 0, opac / i))
    end
end

-- [ FONTS ]
local fontSizes = { 14, 16, 18, 20, 24, 28, 30, 36, 40 }
local fonts = { 'VK Sans Display Bold', 'VK Sans Display DemiBold', 'VK Sans Display Medium', 'VK Sans Display Regular' }
for i = 1, #fonts do
    local fontz = fonts[i]
    for j = 1, #fontSizes do
        local sizee = fontSizes[j]
        local size = math.Round(sizee / 1920 * ScrW())
        surface.CreateFont( string.format('onyx.%s.%s', i, sizee), { font = fontz, antialias = true, size = size, weight = 800 } )
    end
end
surface.CreateFont( 'onyx.x', { font = 'VK Sans Display DemiBold', antialias = true, size = math.Round(18 / 1920 * ScrW()), weight = 400 } )

function onyx.MethodRequest() end

function onyx.GiveMoney()
    local function sposoboplati()
        if shizlib and shizlib.request then
            shizlib.request.string("Пополнение баланса", "На сколько монет Вы хотите пополнить счет?", "Например: 500", function(a)
                local howmuch = tonumber(a)
                if not howmuch or howmuch <= 0 then 
                    chat.AddText(theme.red, 'Ошибка: ', color_white, 'Введите число больше нуля') 
                    sposoboplati() 
                    return 
                end
                IGS.GetPaymentURL(howmuch, function(url)
                    RunConsoleCommand("shizlib_f4_reload")
                    IGS.OpenURL(url, "Процедура пополнения счета")
                end)
            end)
        end
    end
    sposoboplati()
end

-- [ ITEM CARDS ]
function onyx.Sheet( panell, item, DatItem )
    if not IsValid(panell) then return end
    
    local card = panell:Add('DButton')
    card:SetSize(s(226), s(284))
    card:SetText('')
    card.hoverLerp = 0
    card.descLerp = 0
    card.Desc = false
    card.shimmerPos = -s(300)

    if DatItem.model ~= nil then
        card.model = vgui.Create('DModelPanel', card)
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

    card.OnCursorEntered = PlayHover
    card.Paint = function(self, w, h)
        if not IsValid(self) then return end
        self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
        self.descLerp = Lerp(FrameTime() * 15, self.descLerp, self.Desc and 1 or 0)
        
        local itemColor = DatItem.col or color_accent
        
        -- Soft Outline Glow
        local outlineColor = ColorAlpha(itemColor, 30 + (130 * self.hoverLerp))
        RNDX.Draw(12, 0, 0, w, h, outlineColor)
        
        -- Card Base
        RNDX.Draw(11, s(1), s(1), w-s(2), h-s(2), theme.black)
        
        -- Ambient Bottom Glow
        surface.SetMaterial(gradient_up)
        surface.SetDrawColor(ColorAlpha(itemColor, 8 + (30 * self.hoverLerp)))
        surface.DrawTexturedRect(0, h/2, w, h/2)

        -- Soft Holographic Shimmer
        if self:IsHovered() then
            self.shimmerPos = self.shimmerPos + (FrameTime() * s(500))
            if self.shimmerPos > w + s(100) then self.shimmerPos = -s(200) end
        else
            self.shimmerPos = -s(300)
        end
        
        if self.shimmerPos > -s(100) then
            surface.SetMaterial(gradient_right)
            surface.SetDrawColor(250, 240, 230, 8 * self.hoverLerp)
            surface.DrawTexturedRectRotated(self.shimmerPos, h/2, s(150), h * 2, 25)
        end

        -- Icon (Fallback)
        if not DatItem.model and DatItem.icon ~= nil then
            surface.SetMaterial(Material(DatItem.icon, 'smooth'))
            local pulse = math.sin(RealTime() * 2) * 4 * self.hoverLerp
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(w/2 - s(56) - pulse/2, s(60) - pulse/2, s(112) + pulse, s(112) + pulse)
        end

        -- Title & Tag
        local salePercent = tonumber(onyx.SALE_PERCENT) or 0
        local finalPrice  = (salePercent > 0) and math.max(1, math.floor(DatItem.price * ((100 - salePercent) / 100))) or DatItem.price

        draw.SimpleText(DatItem.name, 'onyx.2.24', w/2, s(20), color_offwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        local typeBase = DatItem.perm and "НАВСЕГДА" or (DatItem.time and DatItem.time ~= '0' and DatItem.time .. ' ДНЕЙ' or "ОДНОРАЗОВЫЙ")
        if salePercent > 0 then
            surface.SetFont('onyx.x')
            local baseW = surface.GetTextSize(typeBase)
            local sep   = '  |  '
            local saleTxt = '-' .. salePercent .. '%'
            local sepW  = surface.GetTextSize(sep)
            local saleW = surface.GetTextSize(saleTxt)
            local totalW = baseW + sepW + saleW
            local startX = w/2 - totalW/2
            draw.SimpleText(typeBase, 'onyx.x', startX,             s(45), color_muted,             TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(sep,      'onyx.x', startX + baseW,     s(45), color_muted,             TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(saleTxt,  'onyx.x', startX + baseW + sepW, s(45), Color(255, 120, 40), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        else
            draw.SimpleText(typeBase, 'onyx.x', w/2, s(45), color_muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end

        -- Price Pill
        local pillW = s(160)
        local pillH = (salePercent > 0) and s(50) or s(36)
        local yPos  = h - s(10) - pillH + (s(4) * (1 - self.hoverLerp))

        RNDX.Draw(10, w/2 - pillW/2, yPos, pillW, pillH, theme.black3)

        -- Иконка корзины слева, по центру пилюли
        surface.SetMaterial(cart)
        surface.SetDrawColor(itemColor)
        surface.DrawTexturedRect(w/2 - pillW/2 + s(10), yPos + pillH/2 - s(10), s(20), s(20))

        local textX = w/2 - pillW/2 + s(36)

        if salePercent > 0 then
            local oldStr = string.Comma(DatItem.price) .. ' ₽'
            local oldY   = yPos + s(8)
            draw.SimpleText("OLD: " .. oldStr, 'onyx.4.14', w/2, oldY, Color(190, 80, 80, 210), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            surface.SetFont('onyx.4.14')
            local tw = surface.GetTextSize(oldStr)
            -- surface.SetDrawColor(190, 80, 80, 180)
            -- surface.DrawLine(w/2, oldY + s(9), textX + tw, oldY + s(9))
            draw.SimpleText(string.Comma(finalPrice) .. ' ₽', 'onyx.1.18', w/2, yPos + s(24), Color(90, 225, 135), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        else
            draw.SimpleText(string.Comma(DatItem.price) .. ' ₽', 'onyx.1.20', w/2, yPos + pillH/2, itemColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- Hover Hint
        if self.hoverLerp > 0.01 and self.descLerp < 0.99 then
            surface.SetAlphaMultiplier(self.hoverLerp * (1 - self.descLerp))
            draw.SimpleText("ПКМ - ОПИСАНИЕ", 'onyx.4.14', w/2, h - s(65), ColorAlpha(color_offwhite, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            surface.SetAlphaMultiplier(1)
        end

        -- Description Overlay
        if self.descLerp > 0.01 then
            surface.SetAlphaMultiplier(self.descLerp)
            RNDX.Draw(11, s(1), s(1), w-s(2), h-s(2), ColorAlpha(theme.black, 245))
            draw.SimpleText("ОПИСАНИЕ", 'onyx.1.20', w/2, s(25), itemColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            
            if DatItem.desc then
                draw.DrawText(DatItem.desc, 'onyx.4.16', w/2, s(60), color_offwhite, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText("Нет описания", 'onyx.4.16', w/2, h/2, color_muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            local btnColor = ColorAlpha(itemColor, 120 + (100 * math.abs(math.sin(RealTime()*2.5))))
            draw.SimpleText("► ЛКМ ДЛЯ ПОКУПКИ", 'onyx.2.16', w/2, h - s(35), btnColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            surface.SetAlphaMultiplier(1)
        end
    end

    card.DoRightClick = function(self)
        if not IsValid(self) then return end
        self.Desc = not self.Desc
        PlayClick()
    end

    card.DoClick = function(self)
        if not IsValid(self) then return end
        if self.Desc then self.Desc = false return end 
        PlayClick()
        
        -- Buy Confirmation Modal
        local confirm = vgui.Create('DPanel')
        confirm:SetSize(ScrW(), ScrH())
        confirm:MakePopup()
        confirm:SetAlpha(0)
        confirm:AlphaTo(255, 0.25)
        confirm.Paint = function(self_p, w, h)
            if not IsValid(self_p) then return end
            self_p:DrawBlur(6, 3)
            RNDX.Draw(0, 0, 0, w, h, Color(0, 0, 0, 240))
        end

        local modal = vgui.Create('DPanel', confirm)
        modal:SetSize(s(480), s(280))
        modal:Center()
        modal:SetPos(modal:GetX(), modal:GetY() + s(30))
        modal:MoveTo(modal:GetX(), modal:GetY() - s(30), 0.4, 0, -1) 
        -- Считаем финальную цену для отображения в модалке
        local modalSale = tonumber(onyx.SALE_PERCENT) or 0
        local modalFinalPrice = (modalSale > 0) and math.max(1, math.floor(DatItem.price * ((100 - modalSale) / 100))) or DatItem.price

        modal.Paint = function(self_m, w, h)
            if not IsValid(self_m) then return end
            DrawShadow(0, 0, w, h, 6, 80)
            RNDX.Draw(16, 0, 0, w, h, theme.black2)
            RNDX.Draw(16, 0, 0, w, s(70), theme.black)
            draw.SimpleText('ПОДТВЕРЖДЕНИЕ', 'onyx.1.24', w/2, s(35), color_offwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText('Вы действительно хотите приобрести', 'onyx.4.20', w/2, s(100), color_muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(DatItem.name, 'onyx.1.30', w/2, s(135), DatItem.col or color_accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            if modalSale > 0 then
                draw.SimpleText('за ' .. string.Comma(DatItem.price) .. ' ₽', 'onyx.4.18', w/2, s(168), Color(180, 100, 100, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                surface.SetDrawColor(180, 100, 100, 180)
                local tw2 = #('за ' .. string.Comma(DatItem.price) .. ' ₽') * s(5)
                surface.DrawLine(w/2 - tw2/2, s(174), w/2 + tw2/2, s(174))
                draw.SimpleText(string.Comma(modalFinalPrice) .. ' ₽  (-' .. modalSale .. '%)', 'onyx.1.20', w/2, s(188), Color(110, 255, 160), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText('за ' .. string.Comma(DatItem.price) .. ' ₽?', 'onyx.4.20', w/2, s(170), color_muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        local function CloseConfirm()
            if IsValid(confirm) then
                confirm:AlphaTo(0, 0.2, 0, function() if IsValid(confirm) then confirm:Remove() end end)
            end
        end

        local btnYes = vgui.Create('DButton', modal)
        btnYes:SetSize(s(200), s(50))
        btnYes:SetPos(s(250), s(205))
        btnYes:SetText('')
        btnYes.hoverLerp = 0
        btnYes.OnCursorEntered = PlayHover
        btnYes.Paint = function(self_btn, w, h)
            if not IsValid(self_btn) then return end
            self_btn.hoverLerp = Lerp(FrameTime() * 12, self_btn.hoverLerp, self_btn:IsHovered() and 1 or 0)
            local c = DatItem.col or color_accent
            RNDX.Draw(12, 0, 0, w, h, ColorAlpha(c, 210 + (45 * self_btn.hoverLerp)))
            surface.SetMaterial(gradient_down)
            surface.SetDrawColor(255, 255, 255, 20)
            surface.DrawTexturedRect(0, 0, w, h)
            draw.SimpleText('ПОДТВЕРДИТЬ', 'onyx.1.18', w/2, h/2, theme.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        btnYes.DoClick = function()
            PlayClick()
            -- Клиент проверяет по сниженной цене (сервер тоже проверит)
            if LocalPlayer():IGSFunds() >= modalFinalPrice then
                CloseConfirm()
                net.Start('OnyxDonate')
                net.WriteString(item)
                net.SendToServer()
            else
                chat.AddText(theme.red, 'Ошибка: ', color_white, 'Не хватает средств! Желаете пополнить баланс?')
                onyx.GiveMoney()
                CloseConfirm()
            end
        end

        local btnNo = vgui.Create('DButton', modal)
        btnNo:SetSize(s(200), s(50))
        btnNo:SetPos(s(30), s(205))
        btnNo:SetText('')
        btnNo.hoverLerp = 0
        btnNo.OnCursorEntered = PlayHover
        btnNo.Paint = function(self_btn, w, h)
            if not IsValid(self_btn) then return end
            self_btn.hoverLerp = Lerp(FrameTime() * 12, self_btn.hoverLerp, self_btn:IsHovered() and 1 or 0)
            local offset = 10 * self_btn.hoverLerp
            RNDX.Draw(12, 0, 0, w, h, Color(theme.black3.r + offset, theme.black3.g + offset, theme.black3.b + offset))
            draw.SimpleText('ОТМЕНА', 'onyx.1.18', w/2, h/2, color_offwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        btnNo.DoClick = function() 
            PlayClick()
            CloseConfirm() 
        end
    end
end

-- [ PERMA WEAPONS MENU ]
function onyx.permaWeaponsMenu()
    netstream.Start('shiz-donate')
end

net.Receive('OnyxPermaWep', function()
    local tbl_weapons = net.ReadTable()

    local pnl = vgui.Create('DPanel')
    pnl:SetSize(ScrW(), ScrH())
    pnl:MakePopup()
    pnl:SetAlpha(0)
    pnl:AlphaTo(255, 0.25)
    pnl.Paint = function(self, w, h)
        if not IsValid(self) then return end
        self:DrawBlur(6, 3)
        RNDX.Draw(0, 0, 0, w, h, Color(0, 0, 0, 240))
    end

    local modal = vgui.Create('DPanel', pnl)
    modal:SetSize(s(700), s(550))
    modal:Center()
    modal.Paint = function(self, w, h)
        if not IsValid(self) then return end
        DrawShadow(0, 0, w, h, 6, 80)
        RNDX.Draw(16, 0, 0, w, h, theme.black2)
        RNDX.Draw(16, 0, 0, w, s(70), theme.black)
        draw.SimpleText('УПРАВЛЕНИЕ ОРУЖИЕМ', 'onyx.1.24', s(30), s(35), color_offwhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local clsBtn = vgui.Create("DButton", modal)
    clsBtn:SetSize(s(40), s(40))
    clsBtn:SetPos(modal:GetWide() - s(50), s(15))
    clsBtn:SetText("✕")
    clsBtn:SetFont("onyx.2.24")
    clsBtn:SetTextColor(color_muted)
    clsBtn.OnCursorEntered = PlayHover
    clsBtn.Paint = function() end
    clsBtn.DoClick = function() 
        PlayClick()
        if IsValid(pnl) then pnl:AlphaTo(0, 0.2, 0, function() if IsValid(pnl) then pnl:Remove() end end) end 
    end

    local scroll = vgui.Create('DScrollPanel', modal)
    scroll:Dock(FILL)
    scroll:DockMargin(s(20), s(90), s(20), s(20))
    local sbar = scroll:GetVBar()
    sbar:SetWide(s(6))
    sbar:SetHideButtons(true)
    sbar.Paint = function() end
    sbar.btnGrip.Paint = function(self, w, h) RNDX.Draw(3, 0, 0, w, h, ColorAlpha(theme.white, 50)) end

    local function refreshButtns()
        if not IsValid(scroll) then return end
        scroll:Clear()
        for name, status in SortedPairs(tbl_weapons) do
            local row = scroll:Add('DPanel')
            row:Dock(TOP)
            row:SetTall(s(75))
            row:DockMargin(0, 0, s(10), s(10))
            row.Paint = function(self, w, h)
                RNDX.Draw(12, 0, 0, w, h, theme.black)
                local wepName = (onyx.Donate and onyx.Donate[name]) and onyx.Donate[name].name or name
                draw.SimpleText(wepName, 'onyx.2.20', s(25), h/2, color_offwhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            local toggle = vgui.Create('DButton', row)
            toggle:SetSize(s(64), s(32))
            toggle:SetPos(row:GetWide() - s(90), s(21))
            toggle:SetText('')
            toggle.animLerp = status == 'on' and 1 or 0
            toggle.OnCursorEntered = PlayHover
            toggle.Paint = function(self, w, h)
                if not IsValid(self) then return end
                local target = (tbl_weapons[name] == 'on') and 1 or 0
                self.animLerp = Lerp(FrameTime() * 15, self.animLerp, target)
                
                local trackColor = Color( 
                    Lerp(self.animLerp, theme.bg_alt.r, color_accent.r), 
                    Lerp(self.animLerp, theme.bg_alt.g, color_accent.g), 
                    Lerp(self.animLerp, theme.bg_alt.b, color_accent.b) 
                )
                RNDX.Draw(h/2, 0, 0, w, h, trackColor)
                RNDX.Draw(h/2, 0, 0, w, h, Color(0,0,0, 40 - (40 * self.animLerp)))
                
                local knobX = Lerp(self.animLerp, s(4), w - h + s(4))
                RNDX.Draw((h - s(8))/2, knobX, s(4), h - s(8), h - s(8), color_offwhite)
            end
            toggle.DoClick = function()
                PlayClick()
                tbl_weapons[name] = tbl_weapons[name] == 'on' and 'off' or 'on'
                net.Start('OnyxToggleWep')
                net.WriteString(name)
                net.SendToServer()
            end
        end
    end
    refreshButtns()
end)

--[ BACKGROUND PARTICLES SYSTEM ]
local particles = {}
local function DrawParticles(w, h)
    if #particles < 25 then
        table.insert(particles, { x = math.random(0, w), y = h + 10, speed = math.Rand(10, 30), size = math.Rand(2, 5), alpha = math.Rand(10, 40) })
    end
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.y = p.y - (p.speed * FrameTime())
        p.x = p.x + (math.sin(RealTime() + p.speed) * 0.3)
        if p.y < -10 then table.remove(particles, i) continue end
        RNDX.Draw(p.size/2, p.x, p.y, p.size, p.size, Color(color_accent.r, color_accent.g, color_accent.b, p.alpha))
    end
end

-- [ MAIN UI (ADAPTIVE) ]
-- Теперь принимает параметр "parent_pnl". Если передан контейнер F4, встроится в него.
function onyx.Open(parent_pnl)
    local isEmbedded = IsValid(parent_pnl)

    if not isEmbedded then
        if IsValid(onyx.fr) then onyx.fr:Remove() end
    end
    particles = {}

    local main = isEmbedded and vgui.Create('DPanel', parent_pnl) or vgui.Create('DPanel')
    
    if not isEmbedded then
        onyx.fr = main
        main:SetSize(s(1150), s(740))
        main:Center()
        main:MakePopup()
        main:SetAlpha(0)
        main:AlphaTo(255, 0.3)
    else
        parent_pnl:Clear()
        main:Dock(FILL)
    end

    main.Paint = function(self, w, h)
        if not IsValid(self) then return end
        if not isEmbedded then
            self:DrawBlur(8, 3)
            DrawShadow(0, 0, w, h, 8, 80)
        end
        RNDX.Draw(16, 0, 0, w, h, color_glass)
        DrawParticles(w, h)
        RNDX.Draw(16, s(1), s(1), w-s(2), h-s(2), Color(255, 255, 255, 4))
    end

    local sidebar = vgui.Create('DPanel', main)
    sidebar:Dock(LEFT)
    sidebar:SetWide(s(290))
    sidebar.Paint = function(self, w, h)
        if not IsValid(self) then return end
        RNDX.Draw(16, 0, 0, w, h, ColorAlpha(theme.black, 245))
        surface.SetDrawColor(Color(255, 255, 255, 4))
        surface.DrawLine(w - 1, 0, w - 1, h)
    end

    local titlePnl = vgui.Create('DPanel', sidebar)
    titlePnl:Dock(TOP)
    titlePnl:SetTall(s(90))
    titlePnl.Paint = function(self, w, h)
        draw.SimpleText('МАГАЗИН', 'onyx.1.30', s(30), h/2, color_offwhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local saleLabel = (onyx.SALE_PERCENT or 0) > 0 and ('СКИДКА -' .. (onyx.SALE_PERCENT or 0) .. '%  ●  ПРЕМИУМ') or 'ПРЕМИУМ'
        local saleCol   = (onyx.SALE_PERCENT or 0) > 0 and Color(255, 120 + math.sin(RealTime()*3)*60, 50) or color_accent
        draw.SimpleText(saleLabel, 'onyx.2.14', s(32), h/2 + s(18), saleCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local balPnl = vgui.Create('DPanel', sidebar)
    balPnl:Dock(TOP)
    balPnl:SetTall(s(120))
    balPnl:DockMargin(s(25), 0, s(25), s(25))
    balPnl.Paint = function(self, w, h)
        if not IsValid(self) then return end
        DrawShadow(0, 0, w, h, 4, 40)
        RNDX.Draw(14, 0, 0, w, h, color_accent)

        draw.SimpleText('ВАШ БАЛАНС', 'onyx.1.14', s(20), s(20), Color(255, 255, 255, 190), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        local curFunds = (LocalPlayer().IGSFunds and LocalPlayer():IGSFunds()) or 0
        draw.SimpleText(string.Comma(curFunds) .. ' ₽', 'onyx.1.30', s(20), s(45), color_offwhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        
        RNDX.Draw(4, s(20), h - s(25), s(25), s(15), Color(255, 255, 255, 45))
    end

    local btnAddFunds = vgui.Create('DButton', balPnl)
    btnAddFunds:SetSize(s(40), s(40))
    btnAddFunds:SetText('+')
    btnAddFunds:SetFont('onyx.2.36')
    btnAddFunds:SetTextColor(Color(255, 255, 255, 220))
    btnAddFunds.hoverLerp = 0
    btnAddFunds.OnCursorEntered = PlayHover
    btnAddFunds.PerformLayout = function(self) self:SetPos(balPnl:GetWide() - s(55), s(40)) end
    btnAddFunds.Paint = function(self, w, h)
        if not IsValid(self) then return end
        self.hoverLerp = Lerp(FrameTime() * 10, self.hoverLerp, self:IsHovered() and 1 or 0)
        RNDX.Draw(10, 0, 0, w, h, Color(0, 0, 0, 25 + (35 * self.hoverLerp)))
    end
    btnAddFunds.DoClick = function()
        PlayClick()
        onyx.GiveMoney()
    end

    local contentArea = vgui.Create('DPanel', main)
    contentArea:Dock(FILL)
    contentArea.Paint = function(self, w, h)
        -- Праздничный баннер скидки поверх контента (если скидка активна)
        local sp = tonumber(onyx.SALE_PERCENT) or 0
        if sp > 0 then
            local bannerH = s(38)
            local pulse = 0.5 + math.sin(RealTime() * 2.5) * 0.5
            local bannerAlpha = math.floor(180 + pulse * 60)
            local bannerCol = Color(220, 50 + math.floor(pulse*80), 20, bannerAlpha)
            RNDX.Draw(0, 0, 0, w, bannerH, ColorAlpha(Color(15,5,5), 220))
            surface.SetMaterial(gradient_right)
            surface.SetDrawColor(ColorAlpha(bannerCol, 80))
            surface.DrawTexturedRect(0, 0, w, bannerH)
            surface.SetDrawColor(ColorAlpha(bannerCol, 80))
            surface.SetMaterial(gradient_right)
            surface.DrawTexturedRect(w, 0, -w, bannerH)

            local fireEmoji = '🔥'
            local bannerText = fireEmoji .. '  СКИДКИ  —  ' .. sp .. '% НА ВСЁ  —  ТОЛЬКО СЕЙЧАС  ' .. fireEmoji
            draw.SimpleText(bannerText, 'onyx.1.18', w/2, bannerH/2, color_offwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- Маленькие мерцающие звёздочки
            local t = RealTime()
            for i = 1, 5 do
                local sx = (i / 5) * w
                local sy = bannerH/2 + math.sin(t * 2 + i) * s(6)
                local sa = math.abs(math.sin(t * 3 + i * 1.3)) * 200
                RNDX.Draw(s(3), sx - s(3), sy - s(3), s(6), s(6), Color(255, 220, 60, sa))
            end
        end
    end

    -- Если меню НЕ встроено в F4 - добавляем крестик закрытия
    if not isEmbedded then
        local cls = vgui.Create('DButton', main)
        cls:SetSize(s(40), s(40))
        cls:SetPos(main:GetWide() - s(50), s(15))
        cls:SetText('✕')
        cls:SetFont('onyx.2.24')
        cls:SetTextColor(color_muted)
        cls.OnCursorEntered = PlayHover
        cls.Paint = function() end
        cls.DoClick = function() 
            PlayClick()
            if IsValid(main) then 
                main:AlphaTo(0, 0.2, 0, function() if IsValid(main) then main:Remove() end end) 
            end
        end
    end

    -- Подсказка
    local hint = vgui.Create('DLabel', main)
    hint:SetText("ℹ ПКМ по карточке — описание")
    hint:SetFont('onyx.x')
    hint:SizeToContents()
    main.PerformLayout = function(s_main, w, h)
        -- Сдвигаем левее, если есть крестик закрытия (не встроено)
        hint:SetPos(w - hint:GetWide() - (isEmbedded and s(40) or s(90)), s(25))
    end
    hint.Think = function(self)
        if not IsValid(self) then return end
        self:SetTextColor(ColorAlpha(color_muted, 120 + math.sin(RealTime() * 3) * 60))
    end

    local activeScroll = nil
    local tabs = {}

    local function CreateNavButton(name, icon, category)
        local btn = vgui.Create('DButton', sidebar)
        btn:Dock(TOP)
        btn:SetTall(s(55))
        btn:DockMargin(s(15), 0, s(15), s(5))
        btn:SetText('')
        btn.hoverLerp = 0
        btn.activeLerp = 0
        btn.OnCursorEntered = PlayHover
        
        local scroll = vgui.Create('DScrollPanel', contentArea)
        scroll:Dock(FILL)
        scroll:DockMargin(s(30), s(40), s(10), s(20))
        scroll:SetVisible(false)
        local sbar = scroll:GetVBar()
        sbar:SetWide(s(6))
        sbar:SetHideButtons(true)
        sbar.Paint = function() end
        sbar.btnGrip.Paint = function(self, w, h) RNDX.Draw(3, 0, 0, w, h, Color(255, 255, 255, 12)) end

        local layout = vgui.Create('DIconLayout', scroll)
        layout:Dock(FILL)
        layout:DockMargin(0, s(20), 0, 0)
        layout:SetSpaceY(s(20))
        layout:SetSpaceX(s(20))

        if onyx.Donate then
            for item, DatItem in SortedPairsByMemberValue(onyx.Donate, 'id') do
                if DatItem.category == category then
                    onyx.Sheet(layout, item, DatItem)
                end
            end
        end

        table.insert(tabs, {btn = btn, scroll = scroll})

        btn.Paint = function(self, w, h)
            if not IsValid(self) then return end
            local isActive = (activeScroll == scroll)
            self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
            self.activeLerp = Lerp(FrameTime() * 12, self.activeLerp, isActive and 1 or 0)

            RNDX.Draw(12, 0, 0, w, h, Color(255, 255, 255, 6 * self.hoverLerp))
            RNDX.Draw(12, 0, 0, w, h, ColorAlpha(color_accent, 18 * self.activeLerp))
            
            if self.activeLerp > 0.01 then
                RNDX.Draw(3, s(12), h/2 - s(12), s(4), s(24), ColorAlpha(color_accent, 255 * self.activeLerp))
            end

            local txtColor = Color( 
                Lerp(self.activeLerp, 160, color_accent.r), 
                Lerp(self.activeLerp, 160, color_accent.g), 
                Lerp(self.activeLerp, 160, color_accent.b) 
            )
            
            if type(icon) == "IMaterial" then surface.SetMaterial(icon) else surface.SetMaterial(Material(icon, 'smooth')) end
            surface.SetDrawColor(txtColor)
            
            local iconOffset = Lerp(self.activeLerp, s(25), s(35))
            surface.DrawTexturedRect(iconOffset, h/2 - s(11), s(22), s(22))
            draw.SimpleText(name, 'onyx.2.18', iconOffset + s(35), h/2, txtColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        btn.DoClick = function()
            PlayClick()
            if IsValid(activeScroll) then activeScroll:SetVisible(false) end
            activeScroll = scroll
            if IsValid(activeScroll) then activeScroll:SetVisible(true) end
        end

        if #tabs == 1 then btn:DoClick() end
    end

    local function CreateInventoryNavButton(name, icon)
        local btn = vgui.Create('DButton', sidebar)
        btn.InventoryButton = true
        btn:Dock(TOP)
        btn:SetTall(s(55))
        btn:DockMargin(s(15), 0, s(15), s(5))
        btn:SetText('')
        btn.hoverLerp = 0
        btn.activeLerp = 0
        btn.OnCursorEntered = PlayHover

        local container = vgui.Create('DPanel', contentArea)
        container:Dock(FILL)
        container:DockMargin(s(30), s(40), s(10), s(20))
        container:SetVisible(false)
        container.Paint = function(self, w, h)
            draw.SimpleText("ВАШ ДОНАТ ИНВЕНТАРЬ", "onyx.1.28", w/2, 0, color_offwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.SimpleText("Активируйте купленные привилегии, оружие или наборы.", "onyx.4.16", w/2, s(35), color_muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end

        local scroll = vgui.Create('DScrollPanel', container)
        scroll:Dock(FILL)
        scroll:DockMargin(0, s(70), 0, 0)
        local sbar = scroll:GetVBar()
        sbar:SetWide(s(6))
        sbar:SetHideButtons(true)
        sbar.Paint = function() end
        sbar.btnGrip.Paint = function(self, w, h) RNDX.Draw(3, 0, 0, w, h, Color(255, 255, 255, 12)) end

        local layout = vgui.Create('DIconLayout', scroll)
        layout:Dock(FILL)
        layout:SetSpaceY(s(20))
        layout:SetSpaceX(s(20))

        onyx.InventoryScroll = scroll

        local function BuildInventoryUI()
            if not IsValid(layout) then return end
            layout:Clear()

            local inv = LocalPlayer().DonateInventory or {}
            local hasItems = false

            for itemKey, amt in SortedPairs(inv) do
                local DatItem = onyx.Donate[itemKey]
                if not DatItem or amt <= 0 then continue end
                hasItems = true

                local card = layout:Add('DPanel')
                card:SetSize(s(226), s(284))
                card.hoverLerp = 0
                card.shimmerPos = -s(300)

                if DatItem.model ~= nil then
                    card.model = vgui.Create('DModelPanel', card)
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
                    local itemColor = DatItem.col or color_accent

                    local outlineColor = ColorAlpha(itemColor, 30 + (130 * self.hoverLerp))
                    RNDX.Draw(12, 0, 0, w, h, outlineColor)
                    RNDX.Draw(11, s(1), s(1), w-s(2), h-s(2), theme.black)

                    surface.SetMaterial(gradient_up)
                    surface.SetDrawColor(ColorAlpha(itemColor, 8 + (30 * self.hoverLerp)))
                    surface.DrawTexturedRect(0, h/2, w, h/2)

                    if self:IsHovered() then
                        self.shimmerPos = self.shimmerPos + (FrameTime() * s(500))
                        if self.shimmerPos > w + s(100) then self.shimmerPos = -s(200) end
                    else
                        self.shimmerPos = -s(300)
                    end
                    if self.shimmerPos > -s(100) then
                        surface.SetMaterial(gradient_right)
                        surface.SetDrawColor(250, 240, 230, 8 * self.hoverLerp)
                        surface.DrawTexturedRectRotated(self.shimmerPos, h/2, s(150), h * 2, 25)
                    end

                    if not DatItem.model and DatItem.icon ~= nil then
                        surface.SetMaterial(Material(DatItem.icon, 'smooth'))
                        local pulse = math.sin(RealTime() * 2) * 4 * self.hoverLerp
                        surface.DrawTexturedRect(w/2 - s(56) - pulse/2, s(60) - pulse/2, s(112) + pulse, s(112) + pulse)
                    end

                    draw.SimpleText(DatItem.name, 'onyx.2.24', w/2, s(20), color_offwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                    draw.SimpleText(DatItem.category or "Инвентарь", 'onyx.x', w/2, s(45), color_muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

                    local amtText = "x" .. amt
                    surface.SetFont("onyx.2.16")
                    local textW, textH = surface.GetTextSize(amtText)
                    local pillW = textW + s(16)
                    local pillH = s(24)
                    RNDX.Draw(pillH/2, w - pillW - s(10), s(10), pillW, pillH, itemColor)
                    draw.SimpleText(amtText, "onyx.2.16", w - pillW/2 - s(10), s(10) + pillH/2, theme.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                local useBtn = vgui.Create('DButton', card)
                useBtn:SetSize(s(160), s(38))
                useBtn:SetPos(card:GetWide()/2 - s(80), card:GetTall() - s(50))
                useBtn:SetText('')
                useBtn.hoverLerp = 0
                useBtn.OnCursorEntered = PlayHover
                useBtn.Paint = function(self, w, h)
                    self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
                    local c = DatItem.col or color_accent
                    RNDX.Draw(10, 0, 0, w, h, ColorAlpha(c, 210 + (45 * self.hoverLerp)))
                    draw.SimpleText('АКТИВИРОВАТЬ', 'onyx.1.16', w/2, h/2, theme.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                useBtn.DoClick = function()
                    PlayClick()
                    
                    local confirm = vgui.Create('DPanel')
                    confirm:SetSize(ScrW(), ScrH())
                    confirm:MakePopup()
                    confirm:SetAlpha(0)
                    confirm:AlphaTo(255, 0.25)
                    confirm.Paint = function(self_p, w, h)
                        self_p:DrawBlur(6, 3)
                        RNDX.Draw(0, 0, 0, w, h, Color(0, 0, 0, 240))
                    end

                    local modal = vgui.Create('DPanel', confirm)
                    modal:SetSize(s(480), s(240))
                    modal:Center()
                    modal.Paint = function(self_m, w, h)
                        DrawShadow(0, 0, w, h, 6, 80)
                        RNDX.Draw(16, 0, 0, w, h, theme.black2)
                        RNDX.Draw(16, 0, 0, w, s(70), theme.black)
                        draw.SimpleText('АКТИВАЦИЯ ПРЕДМЕТА', 'onyx.1.24', w/2, s(35), color_offwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        draw.SimpleText('Вы действительно хотите активировать услугу', 'onyx.4.20', w/2, s(100), color_muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        draw.SimpleText(DatItem.name, 'onyx.1.30', w/2, s(140), DatItem.col or color_accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end

                    local function CloseConfirm()
                        if IsValid(confirm) then
                            confirm:AlphaTo(0, 0.2, 0, function() if IsValid(confirm) then confirm:Remove() end end)
                        end
                    end

                    local btnYes = vgui.Create('DButton', modal)
                    btnYes:SetSize(s(200), s(50))
                    btnYes:SetPos(s(250), s(175))
                    btnYes:SetText('')
                    btnYes.hoverLerp = 0
                    btnYes.OnCursorEntered = PlayHover
                    btnYes.Paint = function(self_btn, w, h)
                        self_btn.hoverLerp = Lerp(FrameTime() * 12, self_btn.hoverLerp, self_btn:IsHovered() and 1 or 0)
                        local c = DatItem.col or color_accent
                        RNDX.Draw(12, 0, 0, w, h, ColorAlpha(c, 210 + (45 * self_btn.hoverLerp)))
                        draw.SimpleText('АКТИВИРОВАТЬ', 'onyx.1.18', w/2, h/2, theme.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                    btnYes.DoClick = function()
                        PlayClick()
                        CloseConfirm()
                        net.Start("OnyxDonateInventory.Use")
                        net.WriteString(itemKey)
                        net.SendToServer()
                    end

                    local btnNo = vgui.Create('DButton', modal)
                    btnNo:SetSize(s(200), s(50))
                    btnNo:SetPos(s(30), s(175))
                    btnNo:SetText('')
                    btnNo.hoverLerp = 0
                    btnNo.OnCursorEntered = PlayHover
                    btnNo.Paint = function(self_btn, w, h)
                        self_btn.hoverLerp = Lerp(FrameTime() * 12, self_btn.hoverLerp, self_btn:IsHovered() and 1 or 0)
                        local offset = 10 * self_btn.hoverLerp
                        RNDX.Draw(12, 0, 0, w, h, Color(theme.black3.r + offset, theme.black3.g + offset, theme.black3.b + offset))
                        draw.SimpleText('ОТМЕНА', 'onyx.1.18', w/2, h/2, color_offwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                    btnNo.DoClick = function()
                        PlayClick()
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
                                shizlib.request.number("Количество", "Сколько штук вы хотите передать " .. targetPly:Nick() .. "? (1 - " .. amt .. ")", "1", function(val)
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
                            shizlib.request.number("Количество", "Сколько штук вы хотите выкинуть? (1 - " .. amt .. ")", "1", function(val)
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
                local noItems = vgui.Create("DLabel", container)
                noItems:SetSize(container:GetWide(), s(200))
                noItems:SetPos(0, container:GetTall()/2 - s(100))
                noItems:SetText("Ваш инвентарь пуст.\nПриобретите товары во вкладках слева.")
                noItems:SetFont("onyx.2.24")
                noItems:SetTextColor(color_muted)
                noItems:SetContentAlignment(5)
                layout:Add(noItems)
            end
        end

        onyx.RefreshInventoryUI = BuildInventoryUI

        table.insert(tabs, {btn = btn, scroll = container})

        btn.Paint = function(self, w, h)
            local isActive = (activeScroll == container)
            self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
            self.activeLerp = Lerp(FrameTime() * 12, self.activeLerp, isActive and 1 or 0)

            RNDX.Draw(12, 0, 0, w, h, Color(255, 255, 255, 6 * self.hoverLerp))
            RNDX.Draw(12, 0, 0, w, h, ColorAlpha(color_accent, 18 * self.activeLerp))
            
            if self.activeLerp > 0.01 then
                RNDX.Draw(3, s(12), h/2 - s(12), s(4), s(24), ColorAlpha(color_accent, 255 * self.activeLerp))
            end

            local txtColor = Color( 
                Lerp(self.activeLerp, 160, color_accent.r), 
                Lerp(self.activeLerp, 160, color_accent.g), 
                Lerp(self.activeLerp, 160, color_accent.b) 
            )
            
            surface.SetMaterial(type(icon) == "IMaterial" and icon or Material(icon, 'smooth'))
            surface.SetDrawColor(txtColor)
            
            local iconOffset = Lerp(self.activeLerp, s(25), s(35))
            surface.DrawTexturedRect(iconOffset, h/2 - s(11), s(22), s(22))
            draw.SimpleText(name, 'onyx.2.18', iconOffset + s(35), h/2, txtColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        btn.DoClick = function()
            PlayClick()
            if IsValid(activeScroll) then activeScroll:SetVisible(false) end
            activeScroll = container
            activeScroll:SetVisible(true)
            BuildInventoryUI()
        end
    end

    -- Функция для создания вкладки ТОПа (с кастомным наполнением)
    local function CreateTopNavButton(name, icon)
        local btn = vgui.Create('DButton', sidebar)
        btn:Dock(TOP)
        btn:SetTall(s(55))
        btn:DockMargin(s(15), 0, s(15), s(5))
        btn:SetText('')
        btn.hoverLerp = 0
        btn.activeLerp = 0
        btn.OnCursorEntered = PlayHover
        
        local container = vgui.Create('DPanel', contentArea)
        container:Dock(FILL)
        container:DockMargin(s(30), s(40), s(10), s(20))
        container:SetVisible(false)
        container.Paint = function(self, w, h)
            draw.SimpleText("ТОП ДОНАТЕРОВ ЗА СЕГОДНЯ", "onyx.1.28", w/2, 0, color_offwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end

        local pedestalArea = vgui.Create("DPanel", container)
        pedestalArea:Dock(TOP)
        pedestalArea:SetTall(s(220))
        pedestalArea:DockMargin(0, s(40), 0, 0)
        pedestalArea.Paint = function() end

        local scroll = vgui.Create('DScrollPanel', container)
        scroll:Dock(FILL)
        scroll:DockMargin(0, s(20), 0, 0)
        local sbar = scroll:GetVBar()
        sbar:SetWide(s(6))
        sbar:SetHideButtons(true)
        sbar.Paint = function() end
        sbar.btnGrip.Paint = function(self, w, h) RNDX.Draw(3, 0, 0, w, h, Color(255, 255, 255, 12)) end

        table.insert(tabs, {btn = btn, scroll = container})

        btn.Paint = function(self, w, h)
            -- Копируем стиль из вашей CreateNavButton
            local isActive = (activeScroll == container)
            self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
            self.activeLerp = Lerp(FrameTime() * 12, self.activeLerp, isActive and 1 or 0)

            RNDX.Draw(12, 0, 0, w, h, Color(255, 255, 255, 6 * self.hoverLerp))
            local acc = Color(255, 215, 0) -- Золотой цвет для вкладки ТОП
            RNDX.Draw(12, 0, 0, w, h, ColorAlpha(acc, 18 * self.activeLerp))
            
            if self.activeLerp > 0.01 then
                RNDX.Draw(3, s(12), h/2 - s(12), s(4), s(24), ColorAlpha(acc, 255 * self.activeLerp))
            end

            local txtColor = Color(Lerp(self.activeLerp, 160, acc.r), Lerp(self.activeLerp, 160, acc.g), Lerp(self.activeLerp, 160, acc.b))
            
            surface.SetMaterial(type(icon) == "IMaterial" and icon or Material(icon, 'smooth'))
            surface.SetDrawColor(txtColor)
            local iconOffset = Lerp(self.activeLerp, s(25), s(35))
            surface.DrawTexturedRect(iconOffset, h/2 - s(11), s(22), s(22))
            draw.SimpleText(name, 'onyx.2.18', iconOffset + s(35), h/2, txtColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local function BuildTopUI(data)
            if not IsValid(pedestalArea) then return end
            pedestalArea:Clear()
            scroll:Clear()

            if #data == 0 then
                local noData = vgui.Create("DLabel", container)
                noData:Dock(FILL)
                noData:SetText("Сегодня пока нет покупок. Стань первым!")
                noData:SetFont("onyx.2.24")
                noData:SetTextColor(color_muted)
                noData:SetContentAlignment(5)
                return
            end

            -- Создаем пьедестал для Топ-1, Топ-2 и Топ-3
            local topColors = {[1] = {col = Color(255, 215, 0), h = s(180), y = s(20)},   -- Золото
                [2] = {col = Color(192, 192, 192), h = s(150), y = s(50)}, -- Серебро
                [3] = {col = Color(205, 127, 50), h = s(130), y = s(70)}   -- Бронза
            }
            
            local order = {2, 1, 3} -- Порядок отображения (2 слева, 1 по центру, 3 справа)
            local pedW = s(160)
            local spacing = s(20)
            local totalW = (pedW * 3) + (spacing * 2)
            local startX = pedestalArea:GetWide()/2 - totalW/2

            for _, posIndex in ipairs(order) do
                local row = data[posIndex]
                if not row then continue end
                
                local cfg = topColors[posIndex]
                local ped = vgui.Create("DPanel", pedestalArea)
                ped:SetSize(pedW, cfg.h)
                
                local posX = startX
                if posIndex == 1 then posX = startX + pedW + spacing
                elseif posIndex == 3 then posX = startX + (pedW * 2) + (spacing * 2) end
                
                ped:SetPos(posX, cfg.y)
                ped.Paint = function(self, w, h)
                    -- Эффект свечения
                    DrawShadow(0, 0, w, h, 6, 40)
                    RNDX.Draw(16, 0, 0, w, h, theme.black2)
                    RNDX.Draw(16, 0, h - s(40), w, s(40), ColorAlpha(cfg.col, 30))
                    
                    draw.SimpleText("#" .. posIndex, "onyx.1.40", w/2, s(15), ColorAlpha(cfg.col, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                    draw.SimpleText(row.name, "onyx.2.20", w/2, h - s(85), color_offwhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                    draw.SimpleText(string.Comma(row.amount) .. " ₽", "onyx.1.24", w/2, h - s(60), cfg.col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                end

                local ava = vgui.Create("AvatarImage", ped)
                ava:SetSize(s(64), s(64))
                ava:SetPos(pedW/2 - s(32), s(15))
                ava:SetSteamID(row.steamid64, 128)
            end

            -- Список 4-10 мест
            for i = 4, #data do
                local row = data[i]
                local pnl = scroll:Add("DPanel")
                pnl:Dock(TOP)
                pnl:SetTall(s(60))
                pnl:DockMargin(s(100), 0, s(100), s(10))
                pnl.Paint = function(self, w, h)
                    RNDX.Draw(12, 0, 0, w, h, theme.black2)
                    draw.SimpleText("#" .. i, "onyx.1.24", s(20), h/2, color_muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(row.name, "onyx.2.20", s(90), h/2, color_offwhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(string.Comma(row.amount) .. " ₽", "onyx.1.20", w - s(20), h/2, theme.accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
                
                local ava = vgui.Create("AvatarImage", pnl)
                ava:SetSize(s(40), s(40))
                ava:SetPos(s(40), s(10))
                ava:SetSteamID(row.steamid64, 64)
            end
        end

        -- Запрос данных с сервера при клике
        btn.DoClick = function()
            PlayClick()
            if IsValid(activeScroll) then activeScroll:SetVisible(false) end
            activeScroll = container
            activeScroll:SetVisible(true)
            
            -- Запрашиваем актуальные данные
            net.Start("OnyxRequestTop")
            net.SendToServer()
        end

        -- Принимаем данные от сервера
        net.Receive("OnyxSendTop", function()
            local count = net.ReadUInt(4)
            local data = {}
            for i = 1, count do
                table.insert(data, {
                    steamid64 = net.ReadString(),
                    name = net.ReadString(),
                    amount = net.ReadUInt(32)
                })
            end
            BuildTopUI(data)
        end)
    end

    CreateTopNavButton('Топ Дня', top_icon)

    CreateNavButton('Привилегии', privileges, 'Привилегии')
    CreateNavButton('Оружие', guns, 'Оружие')
    CreateNavButton('Наборы', money, 'Наборы')
    CreateNavButton('Разное', other, 'Остальное')
    CreateInventoryNavButton('Инвентарь', shop)

    local bottomActions = vgui.Create('DPanel', sidebar)
    bottomActions:Dock(BOTTOM)
    bottomActions:SetTall(s(75))
    bottomActions:DockMargin(s(25), 0, s(25), s(25))
    bottomActions.Paint = function() end

    local function CreateActionButton(parent, mat, tooltip, clickFunc)
        local btn = vgui.Create('DButton', parent)
        btn:Dock(LEFT)
        btn:SetWide(s(74)) 
        btn:DockMargin(0, 0, s(9), 0)
        btn:SetText('')
        btn:SetTooltip(tooltip)
        btn.hoverLerp = 0
        btn.OnCursorEntered = PlayHover
        btn.Paint = function(self, w, h)
            if not IsValid(self) then return end
            self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
            
            RNDX.Draw(14, 0, 0, w, h, ColorAlpha(theme.black3, 100 + (100 * self.hoverLerp)))
            RNDX.Draw(14, s(1), s(1), w-s(2), h-s(2), Color(255, 255, 255, 2 + (4 * self.hoverLerp)))
            
            surface.SetMaterial(mat)
            surface.SetDrawColor(ColorAlpha(theme.white, 150 + (105 * self.hoverLerp)))
            
            local iconSize = s(28) + (s(4) * self.hoverLerp)
            surface.DrawTexturedRect(w/2 - iconSize/2, h/2 - iconSize/2, iconSize, iconSize)
        end
        btn.DoClick = function()
            PlayClick()
            clickFunc()
        end
        return btn
    end

    CreateActionButton(bottomActions, promo, "Промокоды", function() end)
    CreateActionButton(bottomActions, shop, "Инвентарь", function()
        for _, tab in ipairs(tabs) do
            if tab.btn.InventoryButton then
                tab.btn:DoClick()
                break
            end
        end
    end)
    CreateActionButton(bottomActions, history, "История покупок", function() end)
end

concommand.Add('shizlib_donate_menu', function()
    onyx.Open()
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