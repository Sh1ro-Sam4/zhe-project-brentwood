if not CLIENT then return end
iPhoneOS = iPhoneOS or {}
iPhoneOS.Apps = iPhoneOS.Apps or {}

iPhoneOS.Apps["paint"] = function(appID)
    local theme = iPhoneOS.GetTheme()
        -- === РИСОВАНИЕ ===
        iPhoneOS.CurrentApp.bgColor = theme.bg
        local currentDrawing = {}
        local isDrawing = false
        
        local canvas = vgui.Create("DPanel", iPhoneOS.CurrentApp)
        canvas:SetPos(0, 80)
        canvas:SetSize(iPhoneOS.SCREEN_W, iPhoneOS.SCREEN_H - 160)
        canvas.Paint = function(self, w, h)
            iPhoneOS.DrawRounded(0, 0, 0, w, h, theme.bg2)
            surface.SetDrawColor(theme.text)
            for _, line in ipairs(currentDrawing) do 
                for i=1, #line-1 do 
                    surface.DrawLine(line[i].x, line[i].y, line[i+1].x, line[i+1].y)
                    surface.DrawRect(line[i].x - 1, line[i].y - 1, 3, 3) 
                end 
            end
        end
        canvas.OnMousePressed = function() isDrawing = true; table.insert(currentDrawing, {}) end
        canvas.OnMouseReleased = function() isDrawing = false end
        canvas.OnCursorMoved = function(self, x, y) 
            if isDrawing then table.insert(currentDrawing[#currentDrawing], {x=x, y=y}) end 
        end

        local btnSave = vgui.Create("DButton", iPhoneOS.CurrentApp)
        btnSave:SetPos(iPhoneOS.SCREEN_W/2 - 50, iPhoneOS.SCREEN_H - 60)
        btnSave:SetSize(100, 40)
        btnSave:SetText("Сохранить")
        btnSave:SetFont("iOS_Text")
        btnSave:SetTextColor(color_white)
        btnSave.Paint = function(self, w, h) iPhoneOS.DrawRounded(12, 0, 0, w, h, theme.accent) end
        btnSave.DoClick = function() 
            if #currentDrawing > 0 then 
                table.insert(iPhoneOS.PhoneData.Drawings, currentDrawing)
                iPhoneOS.SavePhoneData()
                currentDrawing = {}
                iPhoneOS.ShowPhoneNotification("Галерея", "Рисунок сохранен!", nil, "paint") 
            end 
        end

        local btnClear = vgui.Create("DButton", iPhoneOS.CurrentApp)
        btnClear:SetPos(20, 40)
        btnClear:SetSize(80, 30)
        btnClear:SetText("Очистить")
        btnClear:SetFont("iOS_Text")
        btnClear:SetTextColor(Color(231, 76, 60))
        btnClear.Paint = function() end
        btnClear.DoClick = function() currentDrawing = {} end
end
