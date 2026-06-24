if not CLIENT then return end
iPhoneOS = iPhoneOS or {}
iPhoneOS.Apps = iPhoneOS.Apps or {}

iPhoneOS.Apps["files"] = function(appID)
    local theme = iPhoneOS.GetTheme()
    iPhoneOS.CurrentApp.bgColor = theme.bg

    local currentFolder = nil -- nil = корень, "notes" = заметки, "drawings" = рисунки, "received" = полученные

    -- Заголовок
    local header = vgui.Create("DPanel", iPhoneOS.CurrentApp)
    header:SetSize(iPhoneOS.SCREEN_W, 80)

    local titleLbl = vgui.Create("DLabel", header)
    titleLbl:SetFont("iOS_Title")
    titleLbl:SetTextColor(theme.text)

    local backBtn = vgui.Create("DButton", header)
    backBtn:SetPos(10, 42)
    backBtn:SetSize(50, 30)
    backBtn:SetText("← ")
    backBtn:SetFont("iOS_AppTitle")
    backBtn:SetTextColor(theme.accent)
    backBtn.Paint = function() end
    backBtn:SetVisible(false)

    header.Paint = function(self, w, h)
        iPhoneOS.DrawRounded(32, 0, 0, w, 64, theme.bg2)
        iPhoneOS.DrawRounded(0, 0, 32, w, h - 32, theme.bg2)
        surface.SetDrawColor(theme.line)
        surface.DrawLine(0, h-1, w, h-1)
    end

    -- Контент
    local scroll = vgui.Create("DScrollPanel", iPhoneOS.CurrentApp)
    scroll:SetPos(0, 80)
    scroll:SetSize(iPhoneOS.SCREEN_W, iPhoneOS.SCREEN_H - 80)
    iPhoneOS.StyleScrollbar(scroll, theme)

    local function CountItems(tbl)
        if not tbl then return 0 end
        return #tbl
    end

    local function DrawFolderIcon(x, y, s, col)
        iPhoneOS.DrawRounded(4, x, y + 4, s, s - 4, col)
        iPhoneOS.DrawRounded(3, x, y, s * 0.45, 6, col)
    end

    local function CreateFileRow(parent, icon, name, subtitle, onClick)
        local row = parent:Add("DButton")
        row:Dock(TOP)
        row:DockMargin(12, 0, 12, 6)
        row:SetTall(60)
        row:SetText("")
        row.Paint = function(self, w, h)
            iPhoneOS.DrawRounded(14, 0, 0, w, h, self:IsHovered() and ColorAlpha(theme.bg2, 255) or theme.bg2)
            
            -- Иконка
            if icon == "folder" then
                DrawFolderIcon(14, 16, 30, theme.accent)
            elseif icon == "note" then
                iPhoneOS.DrawRounded(6, 16, 14, 26, 32, ColorAlpha(theme.accent, 40))
                iPhoneOS.DrawRounded(2, 22, 22, 14, 3, theme.accent)
                iPhoneOS.DrawRounded(2, 22, 28, 10, 3, theme.accent)
                iPhoneOS.DrawRounded(2, 22, 34, 14, 3, theme.accent)
            elseif icon == "drawing" then
                iPhoneOS.DrawRounded(6, 16, 14, 26, 32, ColorAlpha(Color(155, 89, 182), 40))
                iPhoneOS.DrawRounded(8, 22, 20, 14, 14, Color(155, 89, 182))
            elseif icon == "received" then
                iPhoneOS.DrawRounded(6, 16, 14, 26, 32, ColorAlpha(Color(52, 152, 219), 40))
                iPhoneOS.DrawRounded(2, 22, 22, 14, 3, Color(52, 152, 219))
                iPhoneOS.DrawRounded(2, 22, 28, 10, 3, Color(52, 152, 219))
            end

            -- Текст
            draw.SimpleText(name, "iOS_AppTitle", 55, h/2 - 8, theme.text, TEXT_ALIGN_LEFT)
            draw.SimpleText(subtitle, "iOS_IconList", 55, h/2 + 10, theme.subText, TEXT_ALIGN_LEFT)

            -- Стрелка вправо
            draw.SimpleText("›", "iOS_Title", w - 15, h/2, theme.subText, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
        row.DoClick = function()
            iPhoneOS.PlayUISound("Click")
            onClick()
        end
        return row
    end

    local function ShowRoot()
        currentFolder = nil
        scroll:Clear()
        titleLbl:SetText("Проводник")
        titleLbl:SetPos(20, 40)
        titleLbl:SizeToContents()
        backBtn:SetVisible(false)

        local notesCount = CountItems(iPhoneOS.PhoneData.Notes)
        local drawingsCount = CountItems(iPhoneOS.PhoneData.Drawings)
        local receivedCount = CountItems(iPhoneOS.PhoneData.ReceivedNotes)

        -- Информационная карточка
        local infoCard = scroll:Add("DPanel")
        infoCard:Dock(TOP)
        infoCard:DockMargin(12, 10, 12, 15)
        infoCard:SetTall(70)
        infoCard.Paint = function(self, w, h)
            iPhoneOS.DrawRounded(16, 0, 0, w, h, theme.bg2)
            local total = notesCount + drawingsCount + receivedCount
            draw.SimpleText("Всего файлов: " .. total, "iOS_AppTitle", 15, 15, theme.text, TEXT_ALIGN_LEFT)
            
            local parts = {}
            if notesCount > 0 then table.insert(parts, notesCount .. " заметок") end
            if drawingsCount > 0 then table.insert(parts, drawingsCount .. " рисунков") end
            if receivedCount > 0 then table.insert(parts, receivedCount .. " полученных") end
            local desc = #parts > 0 and table.concat(parts, "  •  ") or "Пусто"
            draw.SimpleText(desc, "iOS_IconList", 15, 42, theme.subText, TEXT_ALIGN_LEFT)
        end

        CreateFileRow(scroll, "folder", "Мои заметки", notesCount .. " файлов", function()
            ShowFolder("notes")
        end)

        CreateFileRow(scroll, "folder", "Мои рисунки", drawingsCount .. " файлов", function()
            ShowFolder("drawings")
        end)

        CreateFileRow(scroll, "folder", "Полученные заметки", receivedCount .. " файлов", function()
            ShowFolder("received")
        end)
    end

    function ShowFolder(folderID)
        currentFolder = folderID
        scroll:Clear()
        backBtn:SetVisible(true)

        local items = {}
        local folderName = ""
        local emptyText = ""

        if folderID == "notes" then
            folderName = "Мои заметки"
            emptyText = "Нет сохранённых заметок"
            items = iPhoneOS.PhoneData.Notes or {}
        elseif folderID == "drawings" then
            folderName = "Мои рисунки"
            emptyText = "Нет сохранённых рисунков"
            items = iPhoneOS.PhoneData.Drawings or {}
        elseif folderID == "received" then
            folderName = "Полученные"
            emptyText = "Нет полученных заметок"
            items = iPhoneOS.PhoneData.ReceivedNotes or {}
        end

        titleLbl:SetText(folderName)
        titleLbl:SetPos(60, 40)
        titleLbl:SizeToContents()

        if #items == 0 then
            local empty = scroll:Add("DPanel")
            empty:Dock(TOP)
            empty:DockMargin(0, 40, 0, 0)
            empty:SetTall(100)
            empty.Paint = function(self, w, h)
                draw.SimpleText("📂", "iOS_DialerNum", w/2, 15, theme.subText, TEXT_ALIGN_CENTER)
                draw.SimpleText(emptyText, "iOS_Text", w/2, 65, theme.subText, TEXT_ALIGN_CENTER)
            end
            return
        end

        for i, item in ipairs(items) do
            if folderID == "drawings" then
                -- Рисунок: превью
                local card = scroll:Add("DButton")
                card:Dock(TOP)
                card:DockMargin(12, 6, 12, 0)
                card:SetTall(120)
                card:SetText("")
                card.Paint = function(self, w, h)
                    iPhoneOS.DrawRounded(14, 0, 0, w, h, theme.bg2)
                    if self:IsHovered() then
                        iPhoneOS.DrawRounded(14, 0, 0, w, h, Color(0,0,0,20))
                    end
                    
                    draw.SimpleText("Рисунок #" .. i, "iOS_AppTitle", 15, 10, theme.text, TEXT_ALIGN_LEFT)
                    draw.SimpleText(#item .. " линий", "iOS_IconList", 15, 30, theme.subText, TEXT_ALIGN_LEFT)

                    -- Миниатюра
                    local previewX = w - 100
                    local previewY = 10
                    local previewS = 100
                    iPhoneOS.DrawRounded(8, previewX, previewY, previewS, previewS, theme.bg)
                    surface.SetDrawColor(theme.accent)
                    local scale = previewS / iPhoneOS.SCREEN_W
                    for _, line in ipairs(item) do
                        for j = 1, #line - 1 do
                            surface.DrawLine(
                                previewX + line[j].x * scale,
                                previewY + line[j].y * scale,
                                previewX + line[j+1].x * scale,
                                previewY + line[j+1].y * scale
                            )
                        end
                    end

                    -- Кнопка удалить
                    draw.SimpleText("×", "iOS_Title", w - 115, 15, Color(231, 76, 60), TEXT_ALIGN_CENTER)
                end
                card.DoClick = function()
                    -- Удаление по правому краю
                    local mx = card:LocalCursorPos()
                    if mx and mx < 30 then return end
                end
            else
                -- Заметка: текст
                local preview = iPhoneOS.SafeSub(item, 40) or ""
                local iconType = (folderID == "received") and "received" or "note"
                
                local card = scroll:Add("DButton")
                card:Dock(TOP)
                card:DockMargin(12, 6, 12, 0)
                card:SetTall(65)
                card:SetText("")
                card.Paint = function(self, w, h)
                    iPhoneOS.DrawRounded(14, 0, 0, w, h, self:IsHovered() and ColorAlpha(theme.bg2, 255) or theme.bg2)
                    
                    if iconType == "received" then
                        iPhoneOS.DrawRounded(6, 14, h/2 - 12, 24, 24, ColorAlpha(Color(52, 152, 219), 30))
                        draw.SimpleText("↓", "iOS_AppTitle", 26, h/2, Color(52, 152, 219), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    else
                        iPhoneOS.DrawRounded(6, 14, h/2 - 12, 24, 24, ColorAlpha(theme.accent, 30))
                        draw.SimpleText("📝", "iOS_IconList", 26, h/2, theme.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                    
                    draw.SimpleText("Заметка #" .. i, "iOS_AppTitle", 48, h/2 - 10, theme.text, TEXT_ALIGN_LEFT)
                    draw.SimpleText(preview, "iOS_IconList", 48, h/2 + 8, theme.subText, TEXT_ALIGN_LEFT)
                end
                card.DoClick = function()
                    iPhoneOS.PlayUISound("Click")
                    ShowNoteDetail(item, i, folderID)
                end
            end
        end
    end

    function ShowNoteDetail(noteText, idx, folderID)
        scroll:Clear()
        titleLbl:SetText("Заметка #" .. idx)
        titleLbl:SetPos(60, 40)
        titleLbl:SizeToContents()
        backBtn:SetVisible(true)

        local contentPanel = scroll:Add("DPanel")
        contentPanel:Dock(TOP)
        contentPanel:DockMargin(12, 10, 12, 10)

        -- Подсчитаем высоту текста
        surface.SetFont("iOS_Text")
        local lines = string.Explode("\n", noteText)
        local totalH = 0
        for _, line in ipairs(lines) do
            local _, lh = surface.GetTextSize(line ~= "" and line or " ")
            totalH = totalH + lh
        end
        contentPanel:SetTall(math.max(totalH + 30, 100))

        contentPanel.Paint = function(self, w, h)
            iPhoneOS.DrawRounded(16, 0, 0, w, h, theme.bg2)
            draw.DrawText(noteText, "iOS_Text", 15, 15, theme.text, TEXT_ALIGN_LEFT)
        end

        -- Кнопка удалить
        local delBtn = scroll:Add("DButton")
        delBtn:Dock(TOP)
        delBtn:DockMargin(12, 5, 12, 0)
        delBtn:SetTall(42)
        delBtn:SetText("Удалить")
        delBtn:SetFont("iOS_Text")
        delBtn:SetTextColor(color_white)
        delBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(200, 50, 50) or Color(231, 76, 60)
            iPhoneOS.DrawRounded(12, 0, 0, w, h, col)
        end
        delBtn.DoClick = function()
            iPhoneOS.PlayUISound("Click")
            if folderID == "notes" then
                table.remove(iPhoneOS.PhoneData.Notes, idx)
            elseif folderID == "received" then
                table.remove(iPhoneOS.PhoneData.ReceivedNotes, idx)
            end
            iPhoneOS.SavePhoneData()
            iPhoneOS.ShowPhoneNotification("Проводник", "Файл удалён", Color(231, 76, 60), "files")
            ShowFolder(folderID)
        end

        -- Обновляем кнопку назад чтобы шла в папку, а не в корень
        backBtn.DoClick = function()
            iPhoneOS.PlayUISound("Click")
            ShowFolder(folderID)
        end
        return
    end

    -- Настраиваем кнопку назад для корня
    backBtn.DoClick = function()
        iPhoneOS.PlayUISound("Click")
        ShowRoot()
    end

    ShowRoot()
end
