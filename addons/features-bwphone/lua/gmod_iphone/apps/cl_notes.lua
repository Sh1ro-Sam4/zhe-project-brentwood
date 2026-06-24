if not CLIENT then return end
iPhoneOS = iPhoneOS or {}
iPhoneOS.Apps = iPhoneOS.Apps or {}

iPhoneOS.Apps["notes"] = function(appID)
    local theme = iPhoneOS.GetTheme()
        -- === ЗАМЕТКИ ===
        iPhoneOS.CurrentApp.bgColor = theme.bg
        local currentTab = "local"
        local header = vgui.Create("DPanel", iPhoneOS.CurrentApp)
        header:SetSize(iPhoneOS.SCREEN_W, 110)
        header.Paint = function(self, w, h) 
            iPhoneOS.DrawRounded(32, 0, 0, w, 64, theme.bg2)
            iPhoneOS.DrawRounded(0, 0, 32, w, h - 32, theme.bg2)
            draw.SimpleText("Заметки", "iOS_Title", 20, 45, theme.text, TEXT_ALIGN_LEFT)
            surface.SetDrawColor(theme.line)
            surface.DrawLine(0, 109, w, 109) 
        end
        
        local scroll = vgui.Create("DScrollPanel", iPhoneOS.CurrentApp)
        scroll:SetPos(0, 110)
        scroll:SetSize(iPhoneOS.SCREEN_W, iPhoneOS.SCREEN_H - 110)
        iPhoneOS.StyleScrollbar(scroll, theme)
        local RefreshNotesList

        local tabLocal = vgui.Create("DButton", header)
        tabLocal:SetPos(20, 80)
        tabLocal:SetSize((iPhoneOS.SCREEN_W-40)/2, 25)
        tabLocal:SetText("Мои заметки")
        tabLocal:SetFont("iOS_IconList")
        
        local tabRecv = vgui.Create("DButton", header)
        tabRecv:SetPos(20 + (iPhoneOS.SCREEN_W-40)/2, 80)
        tabRecv:SetSize((iPhoneOS.SCREEN_W-40)/2, 25)
        tabRecv:SetText("Полученные")
        tabRecv:SetFont("iOS_IconList")
        
        local function UpdateTabColors() 
            tabLocal:SetTextColor(currentTab == "local" and theme.text or theme.subText)
            tabRecv:SetTextColor(currentTab == "received" and theme.text or theme.subText) 
        end

        tabLocal.Paint = function() end
        tabLocal.DoClick = function() currentTab = "local"; UpdateTabColors(); RefreshNotesList(); iPhoneOS.PlayUISound("Click") end
        
        tabRecv.Paint = function() end
        tabRecv.DoClick = function() currentTab = "received"; UpdateTabColors(); RefreshNotesList(); iPhoneOS.PlayUISound("Click") end
        UpdateTabColors()
        
        local function OpenNoteEditor(noteIdx)
            local editor = vgui.Create("DPanel", iPhoneOS.CurrentApp)
            editor:SetSize(iPhoneOS.SCREEN_W, iPhoneOS.SCREEN_H)
            editor.Paint = function(self, w, h) iPhoneOS.DrawRounded(32, 0, 0, w, h, theme.bg) end
            
            local textEntry = vgui.Create("DTextEntry", editor)
            textEntry:SetPos(15, 80)
            textEntry:SetSize(iPhoneOS.SCREEN_W - 30, iPhoneOS.SCREEN_H - 100)
            textEntry:SetMultiline(true)
            textEntry:SetFont("iOS_Note")
            textEntry:SetTextColor(theme.text)
            
            local activeDB = currentTab == "local" and iPhoneOS.PhoneData.Notes or iPhoneOS.PhoneData.ReceivedNotes
            if noteIdx then textEntry:SetValue(activeDB[noteIdx]) end
            
            textEntry.Paint = function(self, w, h) self:DrawTextEntryText(theme.text, theme.accent, theme.text) end
            textEntry.OnGetFocus = function() if IsValid(_G.iPhoneFrame_Global) then _G.iPhoneFrame_Global:SetKeyboardInputEnabled(true) end end
            textEntry.OnLoseFocus = function() if IsValid(_G.iPhoneFrame_Global) then _G.iPhoneFrame_Global:SetKeyboardInputEnabled(false) end end

            local backBtn = vgui.Create("DButton", editor)
            backBtn:SetPos(10, 45)
            backBtn:SetSize(80, 30)
            backBtn:SetText("< Назад")
            backBtn:SetFont("iOS_AppTitle")
            backBtn:SetTextColor(theme.accent)
            backBtn.Paint = function() end
            backBtn.DoClick = function()
                local txt = textEntry:GetValue()
                if txt ~= "" then 
                    if noteIdx then activeDB[noteIdx] = txt else table.insert(activeDB, 1, txt) end
                    iPhoneOS.SavePhoneData()
                elseif noteIdx then 
                    table.remove(activeDB, noteIdx)
                    iPhoneOS.SavePhoneData() 
                end
                editor:Remove()
                RefreshNotesList()
            end
        end

        RefreshNotesList = function()
            scroll:Clear()
            local activeDB = currentTab == "local" and iPhoneOS.PhoneData.Notes or iPhoneOS.PhoneData.ReceivedNotes
            if #activeDB == 0 then 
                local lbl = scroll:Add("DLabel")
                lbl:Dock(TOP)
                lbl:SetTall(60)
                lbl:SetText("Нет заметок")
                lbl:SetFont("iOS_Text")
                lbl:SetTextColor(theme.subText)
                lbl:SetContentAlignment(5) 
            end
            for i, text in ipairs(activeDB) do
                local btn = scroll:Add("DButton")
                btn:Dock(TOP)
                btn:SetTall(60)
                btn:SetText("")
                btn.Paint = function(self, w, h)
                    if self:IsHovered() then iPhoneOS.DrawRounded(0, 0, 0, w, h, Color(0,0,0,30)) end
                    draw.SimpleText(iPhoneOS.SafeSub(text, 25) .. "...", "iOS_AppTitle", 20, h/2, theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    surface.SetDrawColor(theme.line)
                    surface.DrawLine(20, h-1, w, h-1) 
                end
                btn.DoClick = function() OpenNoteEditor(i) end
            end
        end
        RefreshNotesList()

        local addBtn = vgui.Create("DButton", header)
        addBtn:SetPos(iPhoneOS.SCREEN_W - 50, 40)
        addBtn:SetSize(40, 30)
        addBtn:SetText("+")
        addBtn:SetFont("iOS_Title")
        addBtn:SetTextColor(theme.accent)
        addBtn.Paint = function() end
        addBtn.DoClick = function() currentTab = "local"; UpdateTabColors(); OpenNoteEditor(nil) end
end
