if not CLIENT then return end
iPhoneOS = iPhoneOS or {}
iPhoneOS.Apps = iPhoneOS.Apps or {}

iPhoneOS.Apps["calc"] = function(appID)
    local theme = iPhoneOS.GetTheme()
        -- === КАЛЬКУЛЯТОР ===
        iPhoneOS.CurrentApp.bgColor = theme.bg
        local display = vgui.Create("DLabel", iPhoneOS.CurrentApp)
        display:SetPos(20, 80)
        display:SetSize(iPhoneOS.SCREEN_W - 40, 80)
        display:SetFont("iOS_DialerNum")
        display:SetText("0")
        display:SetTextColor(theme.text)
        display:SetContentAlignment(6)

        local gridW = 258
        local grid = vgui.Create("DIconLayout", iPhoneOS.CurrentApp)
        grid:SetPos((iPhoneOS.SCREEN_W - gridW)/2, 200)
        grid:SetSize(gridW, 400)
        grid:SetSpaceY(10)
        grid:SetSpaceX(10)

        local calcState = { val = "0", op = nil, prev = nil, reset = false }
        local buttons = {
            {"C", "sys"}, {"±", "sys"}, {"%", "sys"}, {"/", "op"},
            {"7", "num"}, {"8", "num"}, {"9", "num"}, {"*", "op"},
            {"4", "num"}, {"5", "num"}, {"6", "num"}, {"-", "op"},
            {"1", "num"}, {"2", "num"}, {"3", "num"}, {"+", "op"},
            {"0", "num", true}, {".", "num"}, {"=", "op"}
        }

        local btnSize = 57
        for _, data in ipairs(buttons) do
            local btn = grid:Add("DButton")
            local isZero = data[3]
            local btnType = data[2]
            btn:SetSize(isZero and (btnSize * 2 + 10) or btnSize, btnSize)
            btn:SetText(data[1])
            btn:SetFont("iOS_Title")
            
            local btnColor = (btnType == "op") and theme.accent or (btnType == "sys" and theme.line or theme.bg2)
            local txtColor = (btnType == "op") and color_white or theme.text
            btn:SetTextColor(txtColor)

            btn.Paint = function(self, w, h)
                local col = self:IsHovered() and Color(btnColor.r + 20, btnColor.g + 20, btnColor.b + 20) or btnColor
                iPhoneOS.DrawRounded(btnSize/2, 0, 0, w, h, col)
            end
            
            btn.DoClick = function()
                iPhoneOS.PlayUISound("Rollover")
                local txt = data[1]
                if txt == "C" then
                    calcState.val = "0"
                    calcState.op = nil
                    calcState.prev = nil
                elseif txt == "±" then
                    if string.sub(calcState.val, 1, 1) == "-" then 
                        calcState.val = string.sub(calcState.val, 2) 
                    elseif calcState.val ~= "0" then 
                        calcState.val = "-" .. calcState.val 
                    end
                elseif txt == "%" then
                    calcState.val = tostring((tonumber(calcState.val) or 0) / 100)
                elseif txt == "/" or txt == "*" or txt == "-" or txt == "+" then
                    calcState.prev = tonumber(calcState.val) or 0
                    calcState.op = txt
                    calcState.reset = true
                elseif txt == "=" then
                    if calcState.op and calcState.prev then
                        local cur = tonumber(calcState.val) or 0
                        local res = 0
                        if calcState.op == "+" then res = calcState.prev + cur
                        elseif calcState.op == "-" then res = calcState.prev - cur
                        elseif calcState.op == "*" then res = calcState.prev * cur
                        elseif calcState.op == "/" then res = (cur == 0) and 0 or (calcState.prev / cur) end
                        calcState.val = (res == math.floor(res)) and tostring(math.floor(res)) or tostring(math.Round(res, 4))
                        calcState.op = nil
                        calcState.prev = nil
                        calcState.reset = true
                    end
                elseif txt == "." then
                    if not string.find(calcState.val, "%.") then 
                        calcState.val = calcState.val .. "."
                        calcState.reset = false 
                    end
                else
                    if calcState.reset then 
                        calcState.val = txt
                        calcState.reset = false 
                    else 
                        calcState.val = (calcState.val == "0") and txt or string.sub(calcState.val .. txt, 1, 12) 
                    end
                end
                display:SetText(string.sub(calcState.val, 1, 12))
            end
        end
end
