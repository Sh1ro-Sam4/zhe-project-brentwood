-- -- [ CFG THEME INTEGRATION (Fallback provided) ]
-- local theme = CFG and CFG.theme or {
--     bg = Color(22, 22, 22),
--     bg_alt = Color(40, 40, 40),
--     red = Color(222,91,73, 255),
--     accent = Color(255,77,119),
--     focus = Color(245, 245, 245, 25),
--     black = Color(12, 12, 12),
--     black2 = Color(24, 24, 24),
--     black3 = Color(30, 30, 30),
--     black4 = Color(17, 17, 17, 200),
--     white = Color(230, 230, 230),
--     hvr = Color(22, 22, 22, 100),
-- }

-- -- Screen scaling utility (fallback if shizlib.surface.s is missing)
-- local s = (shizlib and shizlib.surface and shizlib.surface.s) and shizlib.surface.s or function(v) return math.Round(v / 1080 * ScrH()) end

-- -- Create sleek fonts for this menu
-- surface.CreateFont("Mayor.Title", { font = "Montserrat", size = s(26), weight = 800, extended = true, antialias = true })
-- surface.CreateFont("Mayor.Label", { font = "Montserrat", size = s(18), weight = 600, extended = true, antialias = true })
-- surface.CreateFont("Mayor.Sub",   { font = "Montserrat", size = s(14), weight = 500, extended = true, antialias = true })
-- surface.CreateFont("Mayor.Btn",   { font = "Montserrat", size = s(16), weight = 700, extended = true, antialias = true })

-- -- [ UTILS & EFFECTS ]
-- local blur = Material("pp/blurscreen")
-- local function DrawBlur(panel, amount, heavyness)
--     if not IsValid(panel) then return end
--     local x, y = panel:LocalToScreen(0, 0)
--     surface.SetDrawColor(255, 255, 255)
--     surface.SetMaterial(blur)
--     for i = 1, heavyness do
--         blur:SetFloat("$blur", (i / 3) * (amount or 6))
--         blur:Recompute()
--         render.UpdateScreenEffectTexture()
--         surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
--     end
-- end

-- local function DrawShadow(x, y, w, h, passes, opac)
--     for i = 1, passes do
--         draw.RoundedBox(16, x - i, y - i, w + (i * 2), h + (i * 2), Color(0, 0, 0, opac / i))
--     end
-- end

-- local function PlayHover() surface.PlaySound("ui/buttonrollover.wav") end
-- local function PlayClick() 
--     if shizlib and shizlib.surface and shizlib.surface.clickSound then shizlib.surface.clickSound() else surface.PlaySound("ui/buttonclick.wav") end 
-- end

-- -- [ MAIN MENU ]
-- local function CreateMayorMenu()
--     -- Only allow Mayor
--     if LocalPlayer():GetPlayerClass() ~= TEAM_MAYOR then return end

--     local pnl = vgui.Create("DPanel")
--     pnl:SetSize(ScrW(), ScrH())
--     pnl:MakePopup()
--     pnl:SetAlpha(0)
--     pnl:AlphaTo(255, 0.25)
--     pnl.Paint = function(self, w, h)
--         if not IsValid(self) then return end
--         DrawBlur(self, 6, 3)
--         draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
--     end

--     local modal = vgui.Create("DPanel", pnl)
--     modal:SetSize(s(500), s(340))
--     modal:Center()
--     modal:SetPos(modal:GetX(), modal:GetY() + s(30))
--     modal:MoveTo(modal:GetX(), modal:GetY() - s(30), 0.4, 0, -1) -- Spring pop-up
--     modal.Paint = function(self, w, h)
--         if not IsValid(self) then return end
--         DrawShadow(0, 0, w, h, 6, 80)
        
--         -- Background
--         draw.RoundedBox(16, 0, 0, w, h, theme.black2)
--         -- Header Banner
--         draw.RoundedBoxEx(16, 0, 0, w, s(70), theme.black, true, true, false, false)
        
--         draw.SimpleText("ПАНЕЛЬ МЭРА", "Mayor.Title", s(30), s(35), theme.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
--         -- Divider Line
--         draw.RoundedBox(0, s(30), s(160), w - s(60), 1, ColorAlpha(theme.white, 10))
--     end

--     -- Close Button
--     local clsBtn = vgui.Create("DButton", modal)
--     clsBtn:SetSize(s(40), s(40))
--     clsBtn:SetPos(modal:GetWide() - s(50), s(15))
--     clsBtn:SetText("✕")
--     clsBtn:SetFont("Mayor.Title")
--     clsBtn:SetTextColor(Color(140, 140, 140))
--     clsBtn.OnCursorEntered = PlayHover
--     clsBtn.Paint = function() end
--     clsBtn.DoClick = function() 
--         PlayClick()
--         if IsValid(pnl) then pnl:AlphaTo(0, 0.2, 0, function() if IsValid(pnl) then pnl:Remove() end end) end 
--     end

--     -- [ 1. CURFEW ROW ]
--     local curfewRow = vgui.Create("DPanel", modal)
--     curfewRow:SetSize(modal:GetWide() - s(60), s(60))
--     curfewRow:SetPos(s(30), s(90))
--     curfewRow.Paint = function(self, w, h)
--         draw.SimpleText("Комендантский час", "Mayor.Label", 0, h/2 - s(8), theme.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
--         draw.SimpleText("Ограничивает передвижение граждан", "Mayor.Sub", 0, h/2 + s(10), ColorAlpha(theme.white, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
--     end

--     -- iOS Style Curfew Toggle
--     local isCurfew = shizlib and shizlib.IsCurfewActive and shizlib.IsCurfewActive() or false
--     local curfewToggle = vgui.Create("DButton", curfewRow)
--     curfewToggle:SetSize(s(64), s(32))
--     curfewToggle:SetPos(curfewRow:GetWide() - s(64), s(14))
--     curfewToggle:SetText("")
--     curfewToggle.animLerp = isCurfew and 1 or 0
--     curfewToggle.OnCursorEntered = PlayHover
--     curfewToggle.Paint = function(self, w, h)
--         if not IsValid(self) then return end
--         self.animLerp = Lerp(FrameTime() * 15, self.animLerp, isCurfew and 1 or 0)
        
--         -- Blend from dark grey to accent color
--         local trackColor = Color( 
--             Lerp(self.animLerp, theme.bg_alt.r, theme.accent.r), 
--             Lerp(self.animLerp, theme.bg_alt.g, theme.accent.g), 
--             Lerp(self.animLerp, theme.bg_alt.b, theme.accent.b) 
--         )
        
--         draw.RoundedBox(h/2, 0, 0, w, h, trackColor)
--         draw.RoundedBox(h/2, 0, 0, w, h, Color(0,0,0, 40 - (40 * self.animLerp))) -- Inner shadow
        
--         local knobX = Lerp(self.animLerp, s(4), w - h + s(4))
--         draw.RoundedBox((h - s(8))/2, knobX, s(4), h - s(8), h - s(8), theme.white)
--     end
--     curfewToggle.DoClick = function()
--         PlayClick()
--         isCurfew = not isCurfew
--         net.Start("shizlib_mayor_command")
--             net.WriteString("toggle_curfew")
--             net.WriteBool(isCurfew)
--         net.SendToServer()
--     end


--     -- [ 2. TAX ROW ]
--     local taxRow = vgui.Create("DPanel", modal)
--     taxRow:SetSize(modal:GetWide() - s(60), s(80))
--     taxRow:SetPos(s(30), s(180))
--     taxRow.Paint = function(self, w, h)
--         draw.SimpleText("Налог на покупки", "Mayor.Label", 0, s(15), theme.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
--         -- Dynamic percentage label
--         draw.SimpleText(math.Round(self.slider:GetValue() * 100) .. "%", "Mayor.Label", w, s(15), theme.accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
--     end

--     -- Custom Slider
--     local taxSlider = vgui.Create("DSlider", taxRow)
--     taxRow.slider = taxSlider
--     taxSlider:SetSize(taxRow:GetWide(), s(20))
--     taxSlider:SetPos(0, s(40))
--     taxSlider:SetSlideX((shizlib and shizlib.TaxRate_Purchase or 0) / 0.25) -- Normalize 0-0.25 to 0-1
    
--     taxSlider.Paint = function(self, w, h)
--         if not IsValid(self) then return end
--         local barH = s(6)
--         local barY = h/2 - barH/2
        
--         -- Background track
--         draw.RoundedBox(barH/2, 0, barY, w, barH, theme.black3)
        
--         -- Filled track
--         local fillW = w * self:GetSlideX()
--         if fillW > 0 then
--             draw.RoundedBox(barH/2, 0, barY, fillW, barH, theme.accent)
--         end
--     end
    
--     taxSlider.Knob:SetSize(s(16), s(16))
--     taxSlider.Knob.hoverLerp = 0
--     taxSlider.Knob.Paint = function(self, w, h)
--         if not IsValid(self) then return end
--         self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, (self:IsHovered() or taxSlider:IsEditing()) and 1 or 0)
        
--         local knobSize = s(12) + (s(4) * self.hoverLerp)
--         draw.RoundedBox(knobSize/2, w/2 - knobSize/2, h/2 - knobSize/2, knobSize, knobSize, theme.white)
--     end

--     -- [ 3. SAVE BUTTON ]
--     local btnSave = vgui.Create("DButton", modal)
--     btnSave:SetSize(modal:GetWide() - s(60), s(45))
--     btnSave:SetPos(s(30), modal:GetTall() - s(65))
--     btnSave:SetText("")
--     btnSave.hoverLerp = 0
--     btnSave.OnCursorEntered = PlayHover
--     btnSave.Paint = function(self, w, h)
--         if not IsValid(self) then return end
--         self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
        
--         draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(theme.accent, 210 + (45 * self.hoverLerp)))
        
--         -- Inner subtle gradient
--         surface.SetDrawColor(255, 255, 255, 15)
--         surface.SetMaterial(Material("gui/gradient_down"))
--         surface.DrawTexturedRect(0, 0, w, h)
        
--         draw.SimpleText("СОХРАНИТЬ ИЗМЕНЕНИЯ", "Mayor.Btn", w/2, h/2, theme.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
--     end
--     btnSave.DoClick = function()
--         PlayClick()
        
--         local finalTax = math.Round(taxSlider:GetSlideX() * 0.25, 2) -- Map 0-1 back to 0-0.25
--         net.Start("shizlib_mayor_command")
--             net.WriteString("set_taxes")
--             net.WriteFloat(finalTax)
--         net.SendToServer()
        
--         -- Flash success color briefly
--         theme.accent, theme._oldAcc = Color(80, 220, 100), theme.accent
--         timer.Simple(0.3, function() if theme._oldAcc then theme.accent = theme._oldAcc end end)
        
--         -- Close smoothly
--         if IsValid(pnl) then pnl:AlphaTo(0, 0.3, 0.2, function() if IsValid(pnl) then pnl:Remove() end end) end
--     end
-- end

-- concommand.Add("mayor_menu", CreateMayorMenu)