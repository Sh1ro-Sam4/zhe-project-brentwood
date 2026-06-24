if CLIENT then
    hg = hg or {}
    hg.WeaponSelector = hg.WeaponSelector or {}
    local WS = hg.WeaponSelector

    CreateClientConVar("hg_ws_mode", "1", true, false, "", 0, 1)

    WS.Radial = WS.Radial or {}
    local Radial = WS.Radial

    function WS.GetPrintName(self)
        local class = self:GetClass()
        local phrase = language.GetPhrase(class)
        return phrase ~= class and phrase or self:GetPrintName()
    end

    WS.Show = 0
    WS.Transparent = 0
    WS.LastSelectedSlot = 0
    WS.LastSelectedSlotPos = 0
    WS.SelectedSlot = 0
    WS.SelectedSlotPos = 0

    Radial.isOpen = false
    Radial.selected = nil
    Radial.currentWeaponClass = nil
    Radial.lastHoveredClass = nil
    Radial.animateStates = {}
    Radial.hoverScales = {}
    Radial.blacklist = {}

    function WS.DrawText(text, font, posX, posY, color, textAlign)
        draw.DrawText(text, font, posX + 2, posY + 2, ColorAlpha(color_black, WS.Transparent * 255), textAlign)
        draw.DrawText(text, font, posX, posY, ColorAlpha(color, WS.Transparent * 255), textAlign)
    end

    function WS.GetSelectedWeapon()
        if not IsValid(LocalPlayer()) or not LocalPlayer():Alive() then return end
        local Weapons = WS.GetWeaponTable(LocalPlayer())
        return Weapons[WS.SelectedSlot] and Weapons[WS.SelectedSlot][WS.SelectedSlotPos] or Weapons[WS.LastSelectedSlot][WS.LastSelectedSlotPos] or Weapons[0][0]
    end

    function WS.GetWeaponTable(ply)
        if not IsValid(ply) or not ply:Alive() then return end
        local WeaponsGet = ply:GetWeapons()
        local FormatedTable = {
            [0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {},
        }

        table.sort(WeaponsGet, function(a, b) return (a.SlotPos or 0) > (b.SlotPos or 0) end)

        for k, wep in ipairs(WeaponsGet) do
            local tTbl = FormatedTable[wep.Slot or 0]
            local iMinPos = math.min((wep.SlotPos and wep.SlotPos) or 1, ((#tTbl or 0) + 1)) - 1
            local iPos = tTbl[iMinPos] and #tTbl + 1 or iMinPos
            tTbl[iPos] = wep
        end
        return FormatedTable
    end

    local scrW, scrH = ScrW(), ScrH()
    local AcsentColor = CFG.theme.accent
    local gradient_u = Material("vgui/gradient-d")

    function WS.WeaponSelectorDraw(ply)
        if not IsValid(ply) or not ply:Alive() then return end
        if WS.Show < CurTime() then
            WS.SelectedSlot = WS.LastSelectedSlot
            WS.SelectedSlotPos = -1
            return
        end
        local Weapons = WS.GetWeaponTable(ply)
        local SelectedWep = WS.GetSelectedWeapon()
        if not IsValid(SelectedWep) then return end
        WS.Transparent = LerpFT(0.2, WS.Transparent, math.min(WS.Show - CurTime(), 1))
        local SuperAmmout = 0
        local AmmoutSlots = 0
        for i = 0, #Weapons do
            local slotTbl = Weapons[i]
            if table.Count(slotTbl) < 1 then continue end
            AmmoutSlots = AmmoutSlots + 1
        end

        for i = 0, #Weapons do
            local slotTbl = Weapons[i]
            if table.Count(slotTbl) < 1 then continue end
            local sizeX = scrW * 0.1
            local position = scrW / 2 + ((SuperAmmout - (AmmoutSlots / 2)) * sizeX)

            WS.DrawText(i + 1, "HomigradFontMedium", position + sizeX / 2, scrH * 0.02, ColorAlpha(color_white, WS.Transparent * 255), TEXT_ALIGN_CENTER)

            local Ammout = 0
            local lastPos = 0
            for Id = 0, #slotTbl do
                wepId = Id
                local wep = slotTbl[wepId]
                if not wep then continue end
                local sizeH = SelectedWep == wep and (scrH * 0.12) or (scrH * 0.025)
                local LastSelected = 0
                if slotTbl[wepId - 1] and SelectedWep == slotTbl[wepId - 1] then
                    lastPos = (scrH * 0.095)
                end
                draw.RoundedBox(
                    0,
                    position,
                    (scrH * 0.025) * (Ammout) + (scrH * 0.05) + lastPos,
                    sizeX,
                    sizeH,
                    ColorAlpha(color_black, WS.Transparent * 205)
                )
                draw.RoundedBox(
                    0,
                    position,
                    ((scrH * 0.025) * (Ammout) + (scrH * 0.05) + lastPos) + sizeH - 2,
                    sizeX,
                    2,
                    ColorAlpha(color_black, WS.Transparent * 205)
                )
                surface.SetDrawColor(ColorAlpha(CFG.theme.accent, WS.Transparent * (SelectedWep == wep and 180 or 0)))
                surface.SetMaterial(gradient_u)
                surface.DrawTexturedRect(position, (scrH * 0.025) * (Ammout) + (scrH * 0.05) + lastPos, sizeX, sizeH)
                if SelectedWep == wep then
                    surface.SetDrawColor(ColorAlpha(CFG.theme.accent, WS.Transparent * 155))
                    surface.DrawOutlinedRect(position, (scrH * 0.025) * (Ammout) + (scrH * 0.05) + lastPos, sizeX, sizeH, 2)
                end
                local sizeHi = (scrH * 0.025) * (Ammout) + (scrH * 0.05) + lastPos
                sizeHi = sizeHi + 2.5
                WS.DrawText(WS.GetPrintName(wep), "HomigradFontSmall", position + sizeX / 2, sizeHi, ColorAlpha(color_white, WS.Transparent * 255), TEXT_ALIGN_CENTER)
                Ammout = Ammout + 1

                if SelectedWep == wep and wep.DrawWeaponSelection then
                    wep:DrawWeaponSelection(position + 5, (scrH * 0.025) * (Ammout) + (scrH * 0.055) + lastPos, sizeX - 10, sizeH, WS.Transparent * 255)
                end
            end
            SuperAmmout = SuperAmmout + 1
        end
    end

    local tAcceptKeys = {
        ["slot1"] = 1,
        ["slot2"] = 2,
        ["slot3"] = 3,
        ["slot4"] = 4,
        ["slot5"] = 5,
        ["slot6"] = 6,
    }

    local function GetUpper(Weapons)
        if #LocalPlayer():GetWeapons() < 1 then return end
        WS.SelectedSlot = WS.SelectedSlot < 0 and #Weapons or WS.SelectedSlot - 1
        WS.SelectedSlotPos = Weapons[WS.SelectedSlot] and #Weapons[WS.SelectedSlot] or 0

        if Weapons[WS.SelectedSlot] == nil or Weapons[WS.SelectedSlot][WS.SelectedSlotPos] == nil then
            GetUpper(Weapons)
        end
    end

    local function GetDown(Weapons)
        if #LocalPlayer():GetWeapons() < 1 then return end
        WS.SelectedSlot = WS.SelectedSlot > #Weapons and 0 or WS.SelectedSlot + 1
        WS.SelectedSlotPos = 0

        if Weapons[WS.SelectedSlot] == nil or Weapons[WS.SelectedSlot][WS.SelectedSlotPos] == nil then
            GetDown(Weapons)
        end
    end

    local LastSelected = 0

    local function get_active_tool(ply, tool)
        local activeWep = ply:GetActiveWeapon()
        if not IsValid(activeWep) or activeWep:GetClass() ~= "gmod_tool" or activeWep.Mode ~= tool then return end
        return activeWep:GetToolObject(tool)
    end

    local function canUseSelector(ply)
        local wep = ply:GetActiveWeapon()
        local tool = get_active_tool(ply, "submaterial")
        if tool and IsValid(ply:GetEyeTraceNoCursor().Entity) then
            return true
        end

        return IsAiming(ply) or (IsValid(wep) and wep:GetClass() == "weapon_physgun" and ply:KeyDown(IN_ATTACK)) or (lply.organism and lply.organism.pain and lply.organism.pain > 100)
    end

    function WS.ChangeSelectionWep(ply, key)
        if not IsValid(ply) or not ply:Alive() then return end
        if ply.organism and ply.organism.otrub then return end
        if canUseSelector(ply) then return end
        local iPos = tAcceptKeys[key]
        if iPos or key == "invnext" or key == "invprev" or key == "lastinv" then

            local Weapons = WS.GetWeaponTable(ply)

            WS.Show = CurTime() + 4
            surface.PlaySound("arc9_eft_shared/weapon_generic_rifle_spin" .. math.random(10) .. ".ogg")
            if iPos then
                iPos = iPos - 1
                if LastSelected ~= iPos then
                    WS.SelectedSlotPos = -1
                end
                WS.SelectedSlotPos = (Weapons[iPos] and LastSelected == iPos and WS.SelectedSlotPos + 1 > #Weapons[iPos] and 0 or math.min(WS.SelectedSlotPos + 1, #Weapons[iPos])) or 0
                WS.SelectedSlot = iPos
                LastSelected = iPos
            elseif key == "invprev" then
                WS.SelectedSlotPos = WS.SelectedSlotPos - 1
                if Weapons[WS.SelectedSlot] and WS.SelectedSlotPos < 0 then
                    GetUpper(Weapons)
                end
            elseif key == "invnext" then
                WS.SelectedSlotPos = WS.SelectedSlotPos + 1
                if Weapons[WS.SelectedSlot] and WS.SelectedSlotPos > #Weapons[WS.SelectedSlot] then
                    GetDown(Weapons)
                end
            elseif key == "lastinv" and IsValid(WS.LastInv) then
                WS.Show = 0
                WS.LastInv = WS.LastInv or "weapon_hands_sh"
                local oldwep = ply:GetActiveWeapon()
                input.SelectWeapon(WS.LastInv)
                WS.LastInv = oldwep
            end

        end
    end

    function WS.SetActuallyWeapon(ply, cmd)
        if not IsValid(ply) or not ply:Alive() then return end
        if (cmd:KeyDown(IN_ATTACK) or cmd:KeyDown(IN_ATTACK2)) and WS.Show > CurTime() then

            if WS.Selected and WS.Selected > CurTime() then
                cmd:RemoveKey(IN_ATTACK)
                cmd:RemoveKey(IN_ATTACK2)
            else
                cmd:RemoveKey(IN_ATTACK)
                cmd:RemoveKey(IN_ATTACK2)

                if IsValid(WS.GetSelectedWeapon()) then
                    WS.LastInv = WS.LastInv ~= ply:GetActiveWeapon() and WS.LastInv or ply:GetActiveWeapon()
                    input.SelectWeapon(WS.GetSelectedWeapon())
                end
                cmd:RemoveKey(IN_ATTACK)
                cmd:RemoveKey(IN_ATTACK2)

                WS.LastSelectedSlot = WS.SelectedSlot
                WS.LastSelectedSlotPos = WS.SelectedSlotPos
                WS.Selected = CurTime() + 0.2
                WS.Show = CurTime() + 0.2
                surface.PlaySound("arc9_eft_shared/weapon_generic_spin" .. math.random(1, 10) .. ".ogg")
            end
        end
    end

    local function Radial_GetFilteredWeapons()
        local weps = {}
        local centerWep = nil
        local ply = LocalPlayer()
        if not IsValid(ply) then return weps end

        local class = string.Trim('weapon_hands_sh')
        if class ~= "" then
            local wep = ply:GetWeapon(class)
            if IsValid(wep) and not Radial.blacklist[class] then
                centerWep = wep
            end
        end

        for _, wep in ipairs(ply:GetWeapons()) do
            local cls = wep:GetClass()
            if not Radial.blacklist[cls] and (not centerWep or cls ~= centerWep:GetClass()) then
                table.insert(weps, wep)
            end
        end

        if centerWep then
            table.insert(weps, 1, centerWep)
        end

        return weps
    end

    local function Radial_SwitchToWeapon(class)
        if not class then return end
        local ply = LocalPlayer()
        if ply:HasWeapon(class) then
            local active = ply:GetActiveWeapon()
            if IsValid(active) then
                ply.LastInv = active
            end

            RunConsoleCommand("use", class)
        end
    end

    local function Radial_DrawFilledCircle(x, y, radius, segments, color)
        local vertices = {}
        table.insert(vertices, { x = x, y = y })
        for i = 0, segments do
            local angle = math.rad((i / segments) * 360)
            table.insert(vertices, {
                x = x + math.cos(angle) * radius,
                y = y + math.sin(angle) * radius
            })
        end
        draw.NoTexture()
        surface.SetDrawColor(color)
        surface.DrawPoly(vertices)
    end

    local function Radial_Draw()
        if not Radial.isOpen then return end
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() or ply:InVehicle() then return end

        local items = Radial_GetFilteredWeapons()
        if #items == 0 then return end

        local sw, sh = ScrW(), ScrH()
        local cx, cy = sw * 0.5, sh * 0.5
        local mx, my = gui.MousePos()

        local boxsc = math.Clamp(2, 0.5, 6)
        local r = math.Clamp(120 + (#items * 8), 80, math.min(sw, sh) * 0.5 - 50)
        local step = (#items > 1) and 360 / (#items - 1) or 360
        local centerEnabled = 1

        surface.SetFont("RadialFont")

        local closestDist, hovered = math.huge, nil
        for i, wep in ipairs(items) do
            local id = wep:GetClass()
            local state = Radial.animateStates[id] or { posFrac = 0, alphaFrac = 0 }
            Radial.animateStates[id] = state

            state.posFrac = Lerp(FrameTime() * 10, state.posFrac, 1)
            state.alphaFrac = Lerp(FrameTime() * 5, state.alphaFrac, 1)

            local isCenter = centerEnabled and (i == 1)
            local ang = isCenter and 0 or math.rad((i - 2) * step - 90)
            local tx = isCenter and cx or (cx + math.cos(ang) * r * state.posFrac)
            local ty = isCenter and cy or (cy + math.sin(ang) * r * state.posFrac)

            local disp = wep:GetPrintName()
            local tw, th = surface.GetTextSize(disp)

            Radial.hoverScales[id] = Lerp(FrameTime() * 10, Radial.hoverScales[id] or 0, (wep == Radial.selected) and 1 or 0)
            local sc = 1 + Radial.hoverScales[id] * 0.3

            if isCenter then
                local radOutline = math.max(tw, th) * 0.5 * sc * 2 + 3
                local fillColor

                if wep == Radial.selected then
                    fillColor = Color(hg.VGUI.MainColor.r, hg.VGUI.MainColor.g, hg.VGUI.MainColor.b, 240 * state.alphaFrac)
                else
                    fillColor = Color(0, 0, 0, 240 * state.alphaFrac)
                end

                draw.NoTexture()
                surface.SetDrawColor(fillColor)
                Radial_DrawFilledCircle(tx, ty, radOutline, 32, fillColor)

                draw.SimpleTextOutlined(disp, "RadialFont", tx, ty, Color(255, 255, 255, 225000 * state.alphaFrac), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, .6, color_black)
            else
                local padX = 4 * 6 * sc
                local padY = 2 * 6 * sc
                local w, h = tw * sc, th * sc
                local boxColor
                if wep == Radial.selected then
                    boxColor = Color(hg.VGUI.MainColor.r, hg.VGUI.MainColor.g, hg.VGUI.MainColor.b, 240 * state.alphaFrac)
                else
                    boxColor = Color(0, 0, 0, 240 * state.alphaFrac)
                end

                draw.RoundedBox(4, tx - w * 0.5 - padX, ty - h * 0.5 - padY, w + padX * 2, h + padY * 2, boxColor)
                draw.SimpleTextOutlined(disp, "RadialFont", tx, ty - 2, Color(255, 255, 255, 255 * state.alphaFrac), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, .6, color_black)
            end
        end

        local closestDist2, hovered2 = math.huge, nil
        for i, wep in ipairs(items) do
            local isCenter = centerEnabled and (i == 1)
            local ang = isCenter and 0 or math.rad((i - 2) * step - 90)
            local tx = isCenter and cx or (cx + math.cos(ang) * r)
            local ty = isCenter and cy or (cy + math.sin(ang) * r)
            local d = math.Distance(mx, my, tx, ty)
            if d < 100 and d < closestDist2 then
                closestDist2, hovered2 = d, wep
            end
        end

        if hovered2 ~= Radial.selected then
            if hovered2 then
                surface.PlaySound("arc9_eft_shared/weapon_generic_rifle_spin" .. math.random(10) .. ".ogg")
            end
            Radial.selected = hovered2
        end

        if not Radial.selected then
            Radial.lastHoveredClass = nil
        else
            Radial.lastHoveredClass = Radial.selected:GetClass()
        end
    end

    local function Radial_Think()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local keynum = { KEY_1, MOUSE_MIDDLE }
        local down = false
        for k, v in pairs(keynum) do
            down = down or input.IsButtonDown(v)
        end

        local inSpawn = spawnmenu and spawnmenu.IsVisible and spawnmenu:IsVisible()
        local inConsole = gui.IsConsoleVisible()
        local inGameUI = gui.IsGameUIVisible()
        local inChat = chat and chat.IsTyping and chat.IsTyping()
        local hasFocus = vgui.GetKeyboardFocus() ~= nil

        if down and ply:Alive() and not inSpawn and not inConsole and not inGameUI and not inChat and not hasFocus then
            if not Radial.isOpen then
                Radial.isOpen = true
                Radial.animateStates = {}
                surface.PlaySound("arc9_eft_shared/weapon_generic_rifle_spin" .. math.random(10) .. ".ogg")
                gui.EnableScreenClicker(true)
                local active = ply:GetActiveWeapon()
                if IsValid(active) then
                    Radial.currentWeaponClass = active:GetClass()
                end
            end
        else
            if Radial.isOpen then
                Radial.isOpen = false
                gui.EnableScreenClicker(false)
                if Radial.selected and IsValid(ply) then
                    local cls = Radial.selected:GetClass()
                    if cls ~= Radial.currentWeaponClass then
                        surface.PlaySound("arc9_eft_shared/weapon_generic_spin" .. math.random(1, 10) .. ".ogg")
                        Radial_SwitchToWeapon(cls)
                    end
                end
                Radial.selected = nil
            end
        end
    end

    local function Radial_Lastinv(ply, bind, pressed)
        if not pressed or not IsValid(ply) then return end
        if string.find(bind, "lastinv") and IsValid(LocalPlayer().LastInv) then
            Radial_SwitchToWeapon(LocalPlayer().LastInv:GetClass())
            return true
        end
    end

    local tHideElements = {
        ["CHudWeaponSelection"] = true
    }

    hook.Add("HUDShouldDraw", "HG_WeaponSelector_HUDShouldDraw", function(sElementName)
        if GetConVarNumber("hg_ws_mode") == 0 then
            if tHideElements[sElementName] then return false end
        end
    end)

    hook.Add("HUDPaint", "HG_WeaponSelector_HUDPaint", function()
        local mode = GetConVarNumber("hg_ws_mode")
        if mode == 0 then
            WS.WeaponSelectorDraw(LocalPlayer())
        elseif mode == 1 then
            Radial_Draw()
        end
    end)

    hook.Add("PlayerBindPress", "HG_WeaponSelector_PlayerBindPress", function(ply, bind, pressed)
        local mode = GetConVarNumber("hg_ws_mode")
        if mode == 0 then
            WS.ChangeSelectionWep(ply, bind)
        elseif mode == 1 then
            Radial_Lastinv(ply, bind, pressed)
        end
    end)

    hook.Add("StartCommand", "HG_WeaponSelector_StartCommand", function(ply, cmd)
        if GetConVarNumber("hg_ws_mode") == 0 then
            WS.SetActuallyWeapon(ply, cmd)
        end
    end)

    hook.Add("Think", "HG_WeaponSelector_Think", function()
        if GetConVarNumber("hg_ws_mode") == 1 then
            Radial_Think()
        end
    end)
end