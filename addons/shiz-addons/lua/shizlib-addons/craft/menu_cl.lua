local s = shizlib.surface.s or function(v) return v end
local DTR = shizlib.surface.DTR
local RNDX = include("shizlib/client/rndx_cl.lua")

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

shizlib.Crafting = shizlib.Crafting or {}

surface.CreateFont('shz-craft-hero', { font = 'Montserrat', size = s(32), weight = 800, antialias = true })
surface.CreateFont('shz-craft-title', { font = 'Montserrat', size = s(24), weight = 700, antialias = true })
surface.CreateFont('shz-craft-name', { font = 'Montserrat', size = s(18), weight = 700, antialias = true })
surface.CreateFont('shz-craft-desc', { font = 'Montserrat', size = s(15), weight = 500, antialias = true })
surface.CreateFont('shz-craft-btn', { font = 'Montserrat', size = s(18), weight = 800, antialias = true })
surface.CreateFont('shz-craft-small', { font = 'Montserrat', size = s(14), weight = 600, antialias = true })
surface.CreateFont('shz-craft-tiny', { font = 'Montserrat', size = s(12), weight = 700, antialias = true })

local function DrawShadow(x, y, w, h, passes, opac)
    for i = 1, passes do
        RNDX.Draw(8, x - i, y - i, w + (i * 2), h + (i * 2), Color(0, 0, 0, opac / i))
    end
end

local function PlayHover() surface.PlaySound("ui/buttonrollover.wav") end
local function PlayClick() 
    if shizlib and shizlib.surface and shizlib.surface.clickSound then shizlib.surface.clickSound() else surface.PlaySound("ui/buttonclick.wav") end 
end

function shizlib.Crafting.openRecipeMenu(pnl, tbl, ent, base)
    pnl:Clear()
    
    pnl:SetAlpha(0)
    pnl:AlphaTo(255, 0.4, 0)
    local startY = pnl:GetY()
    pnl:SetPos(pnl:GetX(), startY)
    -- pnl:SetPos(pnl:GetX(), startY + s(15))
    -- pnl:MoveTo(pnl:GetX(), startY, 0.5, 0, -1)

    local hero = pnl:Add("Panel")
    hero:Dock(TOP)
    hero:SetTall(s(180))
    hero:DockMargin(s(40), s(40), s(40), 0)
    
    local resultIcon = string.format('shizlib/icon17/64/%s.png', (tbl.base == 'weapon' and CFG.icon17[tbl.entity]) or (tbl.base == 'resource' and shizlib.Resources[tbl.entity].icon) or tbl.icon or "error")
    
    hero.Paint = function(self, w, h)
        RNDX.Draw(8, 0, 0, w, h, theme.black3)
        RNDX.Draw(8, s(1), s(1), w-s(2), h-s(2), theme.black2)
        
        draw.SimpleText(tbl.name:upper(), 'shz-craft-hero', s(30), s(30), theme.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        
        local desc = tbl.description or "Описание отсутствует."
        --draw.DrawText(desc, 'shz-craft-desc', s(30), s(75), Color(150, 150, 160), TEXT_ALIGN_LEFT)

        -- surface.SetMaterial(Material("gui/gradient"))
        surface.SetMaterial(Material("k_cards/krug.png"))
        surface.SetDrawColor(ColorAlpha(theme.accent, 30 + math.sin(RealTime() * 2) * 10))
        surface.DrawTexturedRectRotated(w - s(90), h/2, s(250), s(250), RealTime() * 10)
        
        RNDX.Draw(8, w - s(140), h/2 - s(50), s(100), s(100), theme.black)
        RNDX.Draw(8, w - s(139), h/2 - s(49), s(98), s(98), theme.black3)

        if base ~= 'food' and base ~= 'accessory' then
            surface.SetMaterial(Material(resultIcon, "smooth"))
            surface.SetDrawColor(255, 255, 255)
            surface.DrawTexturedRect(w - s(125), h/2 - s(35), s(70), s(70))
        end

        if tbl.amount > 1 then
            RNDX.Draw(8, w - s(65), h/2 + s(35), s(35), s(25), theme.accent)
            draw.SimpleText("x" .. tbl.amount, 'shz-craft-small', w - s(47), h/2 + s(47), theme.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    if base == 'food' or base == 'accessory' or base == 'armor' or base == 'attachment' then
        local mdl = vgui.Create('DModelPanel', hero)
        mdl:SetSize(s(100), s(100))
        mdl:SetPos(hero:GetWide() - s(140), hero:GetTall()/2 - s(50))
        
        mdl:SetDirectionalLight(BOX_TOP, Color(255, 255, 255))
        mdl:SetDirectionalLight(BOX_FRONT, Color(230, 230, 230))
        mdl:SetAmbientLight(Color(60, 60, 70))
        
        local modelPath
        if base == 'food' then
            modelPath = shizlib.Food[tbl.entity].model
        elseif base == 'accessory' then
            modelPath = SH_ACC.List[tbl.entity].mdl
        elseif base == 'armor' then
            local armorName = string.Replace(tbl.entity, 'ent_armor_', '')
            if hg and hg.armor then
                for placement, armorTbl in pairs(hg.armor) do
                    if armorTbl[armorName] then
                        modelPath = armorTbl[armorName].model
                        break
                    end
                end
            end
        elseif base == 'attachment' then
            local attachName = string.Replace(tbl.entity, 'ent_att_', '')
            if hg and hg.GetAttachmentTab then
                local attachmentTab = hg.GetAttachmentTab(attachName)
                if attachmentTab and hg.attachments and hg.attachments[attachmentTab] and hg.attachments[attachmentTab][attachName] then
                    modelPath = hg.attachments[attachmentTab][attachName][2]
                end
            end
        end

        if modelPath then
            mdl:SetModel(modelPath)
        end
        mdl.LayoutEntity = function(s_panel, ent_mdl)
            ent_mdl:SetAngles(Angle(0, RealTime() * 35, 0))
            ent_mdl:SetPos(Vector(0, 0, math.sin(RealTime() * 3) * 1.5))
        end
        if IsValid(mdl.Entity) then
            local mn, mx = mdl.Entity:GetRenderBounds()
            local size = math.max(math.abs(mn.x) + math.abs(mx.x), math.abs(mn.y) + math.abs(mx.y), math.abs(mn.z) + math.abs(mx.z))
            mdl:SetFOV(45)
            mdl:SetCamPos(Vector(size, size, size * 0.5))
            mdl:SetLookAt((mn + mx) * 0.5)
        end
    end

    local ingTitle = pnl:Add("DLabel")
    ingTitle:Dock(TOP)
    ingTitle:DockMargin(s(40), s(30), s(40), s(15))
    ingTitle:SetText("НЕОБХОДИМЫЕ МАТЕРИАЛЫ")
    ingTitle:SetFont("shz-craft-small")
    ingTitle:SetTextColor(Color(140, 140, 150))
    
    local resScroll = pnl:Add("DScrollPanel")
    resScroll:Dock(FILL)
    resScroll:DockMargin(s(40), 0, s(40), s(20))
    local rsbar = resScroll:GetVBar()
    rsbar:SetWide(0)
    
    local resourcesList = resScroll:Add('DIconLayout')
    resourcesList:Dock(FILL)
    resourcesList:SetSpaceX(s(15))
    resourcesList:SetSpaceY(s(15))

    for k, v in pairs(tbl.resources) do
        local icon = resourcesList:Add('Panel')
        icon:SetSize(s(290), s(70))
        
        local ingIcon = (base ~= 'food') and string.format('shizlib/icon17/64/%s.png', shizlib.Resources[v.class].icon) or nil
        local ingName = (base ~= 'food') and shizlib.Resources[v.class].name or shizlib.Food[v.class].name

        icon.Paint = function(self, w, h)
            RNDX.Draw(8, 0, 0, w, h, theme.black3)
            RNDX.Draw(8, s(1), s(1), w-s(2), h-s(2), theme.black)
            
            RNDX.Draw(8, s(10), s(10), s(50), s(50), theme.black2)

            if ingIcon then
                surface.SetMaterial(Material(ingIcon, "smooth"))
                surface.SetDrawColor(255, 255, 255)
                surface.DrawTexturedRect(s(15), s(15), s(40), s(40))
            end

            draw.SimpleText(ingName, 'shz-craft-small', s(75), h/2 - s(8), theme.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            RNDX.Draw(8, s(75), h/2 + s(4), s(24), s(18), ColorAlpha(theme.accent, 40))
            draw.SimpleText("x" .. v.amount, 'shz-craft-tiny', s(87), h/2 + s(13), theme.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if base == 'food' then
            local mdl = icon:Add('DModelPanel')
            mdl:SetSize(s(46), s(46))
            mdl:SetPos(s(12), s(12))
            mdl:SetModel(shizlib.Food[v.class].model)
            mdl.LayoutEntity = function() end
            if IsValid(mdl.Entity) then
                local mn, mx = mdl.Entity:GetRenderBounds()
                local size = math.max(math.abs(mn.x) + math.abs(mx.x), math.abs(mn.y) + math.abs(mx.y), math.abs(mn.z) + math.abs(mx.z))
                mdl:SetFOV(45)
                mdl:SetCamPos(Vector(size, size, size * 0.5))
                mdl:SetLookAt((mn + mx) * 0.5)
            end
        end
    end

    local craftBtn = pnl:Add('DButton')
    craftBtn:Dock(BOTTOM)
    craftBtn:SetTall(s(65))
    craftBtn:DockMargin(s(40), 0, s(40), s(40))
    craftBtn:SetText("")
    craftBtn.hoverLerp = 0
    craftBtn.OnCursorEntered = PlayHover
    craftBtn.Paint = function(self, w, h)
        if not IsValid(self) then return end
        self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
        
        local pulse = math.sin(RealTime() * 4) * 20
        RNDX.Draw(8, 0, 0, w, h, ColorAlpha(theme.accent, 200 + pulse + (35 * self.hoverLerp)))
        
        -- surface.SetMaterial(Material("gui/gradient_down"))
        -- surface.SetDrawColor(255, 255, 255, 25)
        -- surface.DrawTexturedRect(0, 0, w, h)

        draw.SimpleText("СОЗДАТЬ ПРЕДМЕТ", "shz-craft-btn", w/2, h/2, theme.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    craftBtn.DoClick = function(self)
        PlayClick()
        netstream.Start('Crafting.Craft', {id = tbl.id, Ent = ent, Cfg = base})
    end
end

function shizlib.Crafting.Menu(tbl, ent)
    local client = LocalPlayer()
    if IsValid(client.__Crafting) then client.__Crafting:Remove() end
    
    client.__Crafting = vgui.Create("EditablePanel")
    local pnl = client.__Crafting
    pnl:SetPos(0, 0)
    pnl:SetSize(ScrW(), ScrH())
    pnl:MakePopup()
    
    pnl:SetAlpha(0)
    pnl:AlphaTo(255, 0.3)
    
    pnl.Paint = function(self, w, h)
        if not IsValid(self) then return end
        RNDX.Draw(0, 0, 0, w, h, nil, RNDX.BLUR)
        RNDX.Draw(0, 0, 0, w, h, Color(10, 10, 15, 200))
    end

    pnl.CloseBtn = pnl:Add("DButton")
    pnl.CloseBtn:Dock(FILL)
    pnl.CloseBtn:SetText("")
    pnl.CloseBtn.Paint = nil
    
    local function CloseMenu()
        if IsValid(pnl) then
            pnl:AlphaTo(0, 0.2, 0, function() if IsValid(pnl) then pnl:Remove() end end)
        end
    end
    
    pnl.CloseBtn.Think = function(self)
        if input.IsKeyDown(KEY_ESCAPE) or gui.IsGameUIVisible() then
            CloseMenu()
            gui.HideGameUI()
        end
    end
    pnl.CloseBtn.DoClick = CloseMenu
    pnl.CloseBtn.DoRightClick = CloseMenu

    pnl.MainFrame = pnl:Add('Panel')
    local fr = pnl.MainFrame
    fr:SetSize(s(1000), s(680))
    fr:Center()
    
    local startY = fr:GetY()
    fr:SetPos(fr:GetX(), startY)
    -- fr:SetPos(fr:GetX(), startY + s(40))
    -- fr:MoveTo(fr:GetX(), startY, 0.5, 0, -1)

    fr.Paint = function(self, w, h)
        if not IsValid(self) then return end
        DrawShadow(0, 0, w, h, 8, 80)
        
        RNDX.Draw(8, 0, 0, w, h, theme.black2)
        RNDX.Draw(8, 0, 0, s(320), h, theme.black)
        
        surface.SetDrawColor(Color(255, 255, 255, 5))
        surface.DrawLine(s(320), 0, s(320), h)
    end
    
    local sidebar = fr:Add("Panel")
    sidebar:Dock(LEFT)
    sidebar:SetWide(s(320))
    
    local sidebarTitle = sidebar:Add("Panel")
    sidebarTitle:Dock(TOP)
    sidebarTitle:SetTall(s(90))
    sidebarTitle.Paint = function(self, w, h)
        draw.SimpleText("МЕНЮ СОЗДАНИЯ", "shz-craft-title", s(30), h/2, theme.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local scroll = sidebar:Add('DScrollPanel')
    scroll:Dock(FILL)
    scroll:DockMargin(s(20), 0, s(20), s(20))
    
    local sbar = scroll:GetVBar()
    sbar:SetWide(s(4))
    sbar:SetHideButtons(true)
    sbar.Paint = function() end
    sbar.btnGrip.Paint = function(span, w, h) RNDX.Draw(8, 0, 0, w, h, Color(255, 255, 255, 15)) end

    local contentArea = fr:Add('Panel')
    contentArea:Dock(FILL)

    local activeRecipe = nil

    local isFirst = true
    for k, v in pairs(tbl) do
        local icon
        if v.base == 'weapon' then
            icon = string.format('shizlib/icon17/64/%s.png', CFG.icon17[v.entity] or "error")
        elseif v.base == 'resource' then
            icon = string.format('shizlib/icon17/64/%s.png', shizlib.Resources[v.entity].icon or "error")
        elseif v.icon then
            icon = string.format('shizlib/icon17/64/%s.png', v.icon)
        end
        
        local recipeBtn = scroll:Add('DButton')
        recipeBtn:Dock(TOP)
        recipeBtn:DockMargin(0, 0, s(5), s(10))
        recipeBtn:SetTall(s(60))
        if v.base ~= 'accessory' and icon then
            recipeBtn.Icon = Material(icon, "smooth")
        end
        recipeBtn:SetText("")
        recipeBtn.lerpHover = 0
        recipeBtn.lerpActive = 0
        recipeBtn.OnCursorEntered = PlayHover
        
        recipeBtn.Paint = function(self, w, h)
            if not IsValid(self) then return end
            local isActive = (activeRecipe == self)
            
            self.lerpHover = Lerp(FrameTime() * 12, self.lerpHover, self:IsHovered() and 1 or 0)
            self.lerpActive = Lerp(FrameTime() * 12, self.lerpActive, isActive and 1 or 0)
            
            RNDX.Draw(8, 0, 0, w, h, Color(255, 255, 255, 3 * self.lerpHover))
            RNDX.Draw(8, 0, 0, w, h, ColorAlpha(theme.accent, 15 * self.lerpActive))
            
            if self.lerpActive > 0.01 then
                RNDX.Draw(8, 0, h/2 - s(14), s(4), s(28), ColorAlpha(theme.accent, 255 * self.lerpActive))
            end

            local txtColor = Color(
                Lerp(self.lerpActive, 170, theme.accent.r), 
                Lerp(self.lerpActive, 170, theme.accent.g), 
                Lerp(self.lerpActive, 170, theme.accent.b)
            )

            local textOffset = s(20)
            if v.base ~= 'accessory' then
                textOffset = s(65)
                local iconOffset = Lerp(self.lerpActive, s(20), s(25))
                surface.SetMaterial(self.Icon)
                surface.SetDrawColor(txtColor)
                surface.DrawTexturedRect(iconOffset, h/2 - s(14), s(28), s(28))
            end
            
            draw.SimpleText(v.name, 'shz-craft-name', textOffset, h/2, txtColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        recipeBtn.DoClick = function(self)
            PlayClick()
            if activeRecipe == self then return end
            activeRecipe = self
            shizlib.Crafting.openRecipeMenu(contentArea, v, ent, v.base)
        end

        if isFirst then
            recipeBtn:DoClick()
            isFirst = false
        end
    end
    
    if isFirst then
        local emptyMsg = contentArea:Add("DLabel")
        emptyMsg:Dock(FILL)
        emptyMsg:SetText("Нет доступных рецептов")
        emptyMsg:SetFont("shz-craft-title")
        emptyMsg:SetTextColor(Color(100, 100, 100))
        emptyMsg:SetContentAlignment(5)
    end
end

concommand.Add('shizlib_craftmenu', function()
    shizlib.Crafting.Menu(shizlib.Crafting.Recipes, Entity(1))
end)

netstream.Hook('shizlib-crafting.open', function(data)
    if data.ent:GetClass() == 'shizlib_bench_stove' then
        shizlib.Crafting.Menu(shizlib.Crafting.RecipesCook, data.ent)
    else
        shizlib.Crafting.Menu(shizlib.Crafting.Recipes, data.ent)
    end
end)