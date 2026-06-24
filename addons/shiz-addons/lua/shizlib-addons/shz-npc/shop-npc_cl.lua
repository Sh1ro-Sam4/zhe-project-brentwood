local RNDX = include("shizlib/client/rndx_cl.lua")
local s = shizlib.surface.s

local IsValid = IsValid
local vgui_Create = vgui.Create
local Lerp = Lerp
local FrameTime = FrameTime
local Color = Color
local ColorAlpha = ColorAlpha
local math_Round = math.Round
local math_max = math.max
local math_abs = math.abs
local math_ceil = math.ceil
local tonumber = tonumber
local tostring = tostring
local string_format = string.format
local SortedPairs = SortedPairs
local pairs = pairs
local LocalPlayer = LocalPlayer
local CurTime = CurTime
local net_Start = net.Start
local net_WriteString = net.WriteString
local net_WriteInt = net.WriteInt
local net_WriteEntity = net.WriteEntity
local net_SendToServer = net.SendToServer
local net_Receive = net.Receive
local net_ReadEntity = net.ReadEntity
local net_ReadTable = net.ReadTable
local netstream_Start = netstream.Start
local netstream_Hook = netstream.Hook
local surface_SetFont = surface.SetFont
local surface_GetTextSize = surface.GetTextSize
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawLine = surface.DrawLine
local draw_SimpleText = draw.SimpleText
local table_IsEmpty = table.IsEmpty
local Vector = Vector
local Derma_Message = Derma_Message
local Derma_Query = Derma_Query
local RunConsoleCommand = RunConsoleCommand
local timer_Simple = timer.Simple
local concommand_Add = concommand.Add

local itemstore_Translate = itemstore and itemstore.Translate or function(str) return str end
local draw_RoundedBox = RNDX.DrawRoundedBox or draw.RoundedBox
local draw_RoundedBoxEx = RNDX.DrawRoundedBoxEx or draw.RoundedBoxEx
local color_white = color_white

kas = kas or {}
kas.shop_npc = kas.shop_npc or {}

local fr

function kas.shop_npc.PoliceWeapons(ent)
    if IsValid(fr) then fr:Remove() end

    fr = vgui_Create('SHZFrame')
    fr:SetSize(s(900), s(600))
    fr:Center()
    fr:SetTitle(kas.shop_npc.type[ent:GetKasType()].overhead)
    fr:MakePopup()
    
    local scroll = fr:Add('SHZScrollPanel')
    scroll:Dock(FILL)
    scroll:DockMargin(s(12), s(12), s(12), s(12))

    for k, item in SortedPairs(kas.shop_npc.police.cfg) do
        local pnl = scroll:Add('Panel')
        pnl:Dock(TOP)
        pnl:DockMargin(0, 0, s(8), s(10))
        pnl:SetTall(s(90))
        
        pnl.hoverA = 0
        function pnl:Paint(w, h)
            self.hoverA = Lerp(FrameTime() * 10, self.hoverA, self:IsHovered() and 1 or 0)
            
            draw_RoundedBox(s(8), 0, 0, w, h, Color(30, 30, 30, 240))
            draw_RoundedBox(s(8), 0, 0, w, h, ColorAlpha(color_white, 5 * self.hoverA))

            draw_RoundedBoxEx(s(8), 0, 0, s(4), h, ColorAlpha(Color(50, 150, 255), 255 * self.hoverA), true, false, true, false)

            draw_RoundedBox(s(8), s(8), s(8), h - s(16), h - s(16), Color(15, 15, 15, 200))
            
            local textX = h + s(8)
            draw_SimpleText(item.name, 'font.24', textX, s(18), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw_SimpleText(item.description, 'font.18', textX, s(46), Color(180, 180, 180), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local mdl = pnl:Add('DModelPanel')
        mdl:SetModel(item.model)
        mdl:SetPos(s(8), s(8))
        mdl:SetSize(pnl:GetTall() - s(16), pnl:GetTall() - s(16))
        local mn, mx = mdl.Entity:GetRenderBounds()
        local size = math_max(math_abs(mn.x) + math_abs(mx.x), math_abs(mn.y) + math_abs(mx.y), math_abs(mn.z) + math_abs(mx.z))
        mdl:SetFOV(45)
        mdl:SetCamPos(Vector(size, size, size))
        mdl:SetLookAt((mn + mx) * 0.5)

        local btn = pnl:Add('DButton')
        btn:Dock(RIGHT)
        btn:SetWide(s(140))
        btn:DockMargin(0, s(25), s(15), s(25))
        btn:SetText('')
        btn.hoverLerp = 0
        function btn:Paint(w, h)
            self.hoverLerp = Lerp(FrameTime() * 10, self.hoverLerp, self:IsHovered() and 1 or 0)
            draw_RoundedBox(s(6), 0, 0, w, h, Color(40 + (10 * self.hoverLerp), 100 + (30 * self.hoverLerp), 200 + (40 * self.hoverLerp)))
            draw_SimpleText('ПОЛУЧИТЬ', 'font.18', w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        function btn:DoClick()
            if not self.cd or self.cd < CurTime() then
                netstream_Start('kas.shop_npc.police', { ent, k })
                self.cd = CurTime() + 1
            end
        end
    end
end

function kas.shop_npc.SkillMenu(ent)
    if IsValid(fr) then fr:Remove() end

    fr = vgui_Create('SHZFrame')
    fr:SetSize(s(900), s(600))
    fr:SetTitle(kas.shop_npc.type[ent:GetKasType()].overhead)
    fr:Center()
    fr:MakePopup()
    
    local scroll = fr:Add('SHZScrollPanel')
    scroll:Dock(FILL)
    scroll:DockMargin(s(12), s(12), s(12), s(12))

    for idx, skill in SortedPairs(kas.shop_npc.skills.cfg) do
        local pnl = scroll:Add('Panel')
        pnl:Dock(TOP)
        pnl:DockMargin(0, 0, s(8), s(10))
        pnl:SetTall(s(90))
        
        pnl.hoverA = 0
        function pnl:Paint(w, h)
            self.hoverA = Lerp(FrameTime() * 10, self.hoverA, self:IsHovered() and 1 or 0)
            
            draw_RoundedBox(s(8), 0, 0, w, h, Color(30, 30, 30, 240))
            draw_RoundedBox(s(8), 0, 0, w, h, ColorAlpha(color_white, 5 * self.hoverA))
            
            draw_RoundedBoxEx(s(8), 0, 0, s(4), h, ColorAlpha(Color(150, 50, 255), 255 * self.hoverA), true, false, true, false)
            
            draw_RoundedBox(s(8), s(8), s(8), h - s(16), h - s(16), Color(15, 15, 15, 200))

            local textX = h + s(8)
            local currentStage = LocalPlayer().skillData[idx] or 0
            local stageText = currentStage == skill.max and 'MAX' or tostring(currentStage)
            
            draw_SimpleText(string_format('%s | %s', stageText, skill.name), 'font.24', textX, s(14), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw_SimpleText(skill.description, 'font.18', textX, s(40), Color(180, 180, 180), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            
            local basePrice = skill.price + (skill.nextStage * currentStage)
            local taxAmount = math_ceil(basePrice * (ECONOMICS.Taxes and ECONOMICS.Taxes["Purchase"] or 0))
            local priceFinal = basePrice + taxAmount
            
            draw_SimpleText(string_format('Цена: %s', shizlib.FormatMoney(priceFinal)), 'font.18', textX, s(60), Color(200, 255, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local mdl = pnl:Add('DModelPanel')
        mdl:SetModel(skill.model)
        mdl:SetPos(s(8), s(8))
        mdl:SetSize(pnl:GetTall() - s(16), pnl:GetTall() - s(16))
        local mn, mx = mdl.Entity:GetRenderBounds()
        local size = math_max(math_abs(mn.x) + math_abs(mx.x), math_abs(mn.y) + math_abs(mx.y), math_abs(mn.z) + math_abs(mx.z))
        mdl:SetFOV(45)
        mdl:SetCamPos(Vector(size, size, size))
        mdl:SetLookAt((mn + mx) * 0.5)

        local currentStage = LocalPlayer().skillData[idx] or 0
        local basePrice = skill.price + (skill.nextStage * currentStage)
        local taxAmount = math_ceil(basePrice * (ECONOMICS.Taxes and ECONOMICS.Taxes["Purchase"] or 0))
        local priceFinal = basePrice + taxAmount
        
        local btn = pnl:Add('DButton')
        btn:Dock(RIGHT)
        btn:SetWide(s(200))
        btn:DockMargin(0, s(25), s(15), s(25))
        btn:SetText('')
        btn.hoverLerp = 0
        function btn:Paint(w, h)
            self.hoverLerp = Lerp(FrameTime() * 10, self.hoverLerp, self:IsHovered() and 1 or 0)
            draw_RoundedBox(s(6), 0, 0, w, h, Color(100 + (20 * self.hoverLerp), 40 + (10 * self.hoverLerp), 200 + (40 * self.hoverLerp)))
            draw_SimpleText('УЛУЧШИТЬ (' .. shizlib.FormatMoney(priceFinal) .. ')', 'font.18', w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        function btn:DoClick()
            if not self.cd or self.cd < CurTime() then
                net_Start('kas.shop_npc')
                    net_WriteString('skill')
                    net_WriteInt(idx, 8)
                    net_WriteEntity(ent)
                net_SendToServer()
                self.cd = CurTime() + 1
            end
        end
    end
end

function kas.shop_npc.SellerMenu(ent)
    local inv
    if IsValid(fr) then fr:Remove() end

    inv = vgui_Create( "ItemStoreContainerWindow" )
    inv:SetTitle( itemstore_Translate( "inventory" ) )
    inv:SetContainerID( LocalPlayer().InventoryID )
    inv:ShowCloseButton( false )
    inv:SetDraggable( true )
    inv:InvalidateLayout( true )
    inv.__PerformLayout = inv.PerformLayout
    inv.PerformLayout = function( self )
        self:__PerformLayout()
        if IsValid(fr) then
            self:SetPos( fr:GetPos() + fr:GetWide() + s(10), shizlib.hud.ScrH / 2 - self:GetTall() / 2 )
        end
    end
    inv.__Think = inv.Think
    function inv:Think()
        self:__Think()
        if not IsValid(fr) then self:Remove() end
    end

    fr = vgui_Create('SHZFrame')
    fr:SetSize(s(750), s(650))
    fr:SetTitle(kas.shop_npc.type[ent:GetKasType()].overhead)
    fr:Center()
    fr:MakePopup()
    function fr:Close()
        if IsValid(inv) then inv:AlphaTo(0, 0.3, 0, function(_,pnl) inv:Remove() end) end
        self:AlphaTo(0, 0.3, 0, function(_,pnl) pnl:Remove() end)
    end

    local scroll = fr:Add('SHZScrollPanel')
    scroll:Dock(FILL)
    scroll:DockMargin(s(12), s(12), s(12), s(12))

    for idx, item in SortedPairs(kas.shop_npc.type[ent:GetKasType()].shop_list) do
        local pnl = scroll:Add('Panel')
        pnl:Dock(TOP)
        pnl:DockMargin(0, 0, s(8), s(10))
        pnl:SetTall(s(90))
        
        local hasPrem = LocalPlayer():HasPremium()
        local basePrice = tonumber(item.price)
        local rawSellPrice = basePrice / 2
        local discountedPrice = hasPrem and (basePrice * 0.8) or basePrice
        local finalBuyPrice, finalSellPrice = discountedPrice, rawSellPrice

        if item.notax != true then
            local niggerz, buyTax = ECONOMICS.CalcTax( "Purchase", discountedPrice )
            finalBuyPrice = discountedPrice + buyTax
            local sellTax = 0
            finalSellPrice, sellTax = ECONOMICS.CalcTax( "Sell", rawSellPrice )
        end

        pnl.hoverA = 0
        function pnl:Paint(w, h)
            self.hoverA = Lerp(FrameTime() * 12, self.hoverA, self:IsHovered() and 1 or 0)
            
            draw_RoundedBox(s(8), 0, 0, w, h, Color(30, 30, 30, 240))
            draw_RoundedBox(s(8), 0, 0, w, h, ColorAlpha(color_white, 5 * self.hoverA))
            
            draw_RoundedBoxEx(s(8), 0, 0, s(4), h, ColorAlpha(Color(100, 255, 100), 255 * self.hoverA), true, false, true, false)
            
            draw_RoundedBox(s(8), s(8), s(8), h - s(16), h - s(16), Color(15, 15, 15, 200))

            local textX = h + s(8)
            draw_SimpleText(item.name, 'font.24', textX, s(16), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            
            if hasPrem then
                surface_SetFont('font.18')
                local origW = surface_GetTextSize(shizlib.FormatMoney(basePrice))
                draw_SimpleText(shizlib.FormatMoney(basePrice), 'font.18', textX, s(46), Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                
                surface_SetDrawColor(Color(255, 80, 80))
                surface_DrawLine(textX, s(46) + s(9), textX + origW, s(46) + s(9))
                
                draw_SimpleText(shizlib.FormatMoney(finalBuyPrice), 'font.20', textX + origW + s(10), s(44), Color(255, 215, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                
                surface_SetFont('font.20')
                local newW = surface_GetTextSize(shizlib.FormatMoney(finalBuyPrice))
                local badgeX = textX + origW + s(10) + newW + s(10)
                draw_RoundedBox(s(4), badgeX, s(45), s(70), s(18), Color(255, 215, 0, 30))
                draw_SimpleText("PREMIUM -20%", 'DermaDefault', badgeX + s(35), s(45) + s(9), Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw_SimpleText(shizlib.FormatMoney(finalBuyPrice), 'font.20', textX, s(44), Color(150, 255, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
        end

        local mdl = pnl:Add('DModelPanel')
        mdl:SetModel(item.model)
        mdl:SetPos(s(8), s(8))
        mdl:SetSize(pnl:GetTall() - s(16), pnl:GetTall() - s(16))
        local mn, mx = mdl.Entity:GetRenderBounds()
        local size = math_max(math_abs(mn.x) + math_abs(mx.x), math_abs(mn.y) + math_abs(mx.y), math_abs(mn.z) + math_abs(mx.z))
        mdl:SetFOV(45)
        mdl:SetCamPos(Vector(size, size, size))
        mdl:SetLookAt((mn + mx) * 0.5)

        local actionPnl = pnl:Add("Panel")
        actionPnl:Dock(RIGHT)
        actionPnl:SetWide(s(160))
        actionPnl:DockMargin(0, s(12), s(15), s(12))

        local btnBuy = actionPnl:Add('DButton')
        btnBuy:Dock(TOP)
        btnBuy:SetTall(s(30))
        btnBuy:SetText('')
        btnBuy.hoverLerp = 0
        function btnBuy:Paint(w, h)
            self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
            draw_RoundedBox(s(6), 0, 0, w, h, Color(40 + (10 * self.hoverLerp), 160 + (30 * self.hoverLerp), 80 + (20 * self.hoverLerp)))
            draw_SimpleText('КУПИТЬ', 'font.18', w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        function btnBuy:DoClick()
            if not self.cd or self.cd < CurTime() then
                net_Start('kas.shop_npc')
                    net_WriteString('seller')
                    net_WriteInt(idx, 8)
                    net_WriteEntity(ent)
                net_SendToServer()
                self.cd = CurTime() + .3
            end
        end

        local btnSell = actionPnl:Add('DButton')
        btnSell:Dock(BOTTOM)
        btnSell:SetTall(s(30))
        btnSell:SetText('')
        btnSell.hoverLerp = 0
        function btnSell:Paint(w, h)
            self.hoverLerp = Lerp(FrameTime() * 12, self.hoverLerp, self:IsHovered() and 1 or 0)
            draw_RoundedBox(s(6), 0, 0, w, h, Color(40 + (20 * self.hoverLerp), 40 + (20 * self.hoverLerp), 40 + (20 * self.hoverLerp)))
            local txtCol = Color(255, 100 + (50 * self.hoverLerp), 100 + (50 * self.hoverLerp))
            draw_SimpleText('ПРОДАТЬ (' .. shizlib.FormatMoney(finalSellPrice) .. ')', 'font.18', w/2, h/2, txtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        function btnSell:DoClick()
            if not self.cd or self.cd < CurTime() then
                net_Start('kas.shop_npc')
                    net_WriteString('seller-sell')
                    net_WriteInt(idx, 8)
                    net_WriteEntity(ent)
                net_SendToServer()
                self.cd = CurTime() + .3
            end
        end
    end
end

net_Receive('kas.shop_npc', function()
    local ent = net_ReadEntity()
    local kasType = ent:GetKasType()
    if kasType == 'skill' then
        kas.shop_npc.SkillMenu(ent)
        return
    end
    kas.shop_npc.SellerMenu(ent)
end)

netstream_Hook('kas.shop_npc.police', function(data)
    if not LocalPlayer():isCP() then return end
    kas.shop_npc.PoliceWeapons(data)
end)

netstream_Hook('kas.shop_npc.skills.sync', function(data)
    LocalPlayer().skillData = data
end)

concommand_Add("whitelist", function()
    net_Start("open_wl_menu")
    net_SendToServer()
end)

net_Receive("open_wl_menu", function(len)
    local factionData = net_ReadTable()
    if not factionData or table_IsEmpty(factionData) then return end

    local frame = vgui_Create("DFrame")
    frame:SetSize(s(445), s(500))
    frame:SetTitle("Император подарил ВайтЛист")
    frame:MakePopup()
    frame:ShowCloseButton(true)
    frame:Center()

    local sheet = vgui_Create("DPropertySheet", frame)
    sheet:Dock(FILL)

    for factionKey, data in pairs(factionData) do
        local factionInfo = data.info
        local users = data.users
        local myRole = data.myRole or "none"

        local panel = vgui_Create("DPanel")
        panel:SetPaintBackground(false)

        local addPanel = vgui_Create("DPanel", panel)
        addPanel:Dock(TOP)
        addPanel:SetTall(s(40))
        addPanel:DockMargin(s(5), s(5), s(5), s(5))

        local steamIDEntry = vgui_Create("DTextEntry", addPanel)
        steamIDEntry:Dock(LEFT)
        steamIDEntry:SetWide(s(200))
        steamIDEntry:SetPlaceholderText("SteamID64")
        steamIDEntry:SetText("7656119...")

        local rankCombo = vgui_Create("DComboBox", addPanel)
        rankCombo:Dock(RIGHT)
        rankCombo:SetWide(s(130))
        rankCombo:DockMargin(0, 0, 0, 0)
        for rankKey, rankName in SortedPairs(factionInfo.ranks) do
            if myRole == "admin" then
                rankCombo:AddChoice(rankName, rankKey)
            elseif myRole == "leader" then
                if rankKey == factionKey .. ".User" or rankKey == factionKey .. ".Deputy" then
                    rankCombo:AddChoice(rankName, rankKey)
                end
            elseif myRole == "deputy" then
                if rankKey == factionKey .. ".User" then
                    rankCombo:AddChoice(rankName, rankKey)
                end
            end
        end
        rankCombo:ChooseOptionID(1)

        local addButton = vgui_Create("DButton", addPanel)
        addButton:Dock(RIGHT)
        addButton:SetWide(s(80))
        addButton:SetText("Добавить")
        addButton.DoClick = function()
            local steamid = steamIDEntry:GetText():Trim()
            if steamid == "" or not steamid:match("^%d+$") or #steamid ~= 17 then
                Derma_Message("Введите корректный SteamID64 (17 цифр)", "Ошибка", "OK")
                return
            end
            local _, rankKey = rankCombo:GetSelected()
            if not rankKey then
                Derma_Message("Выберите ранг для выдачи", "Ошибка", "OK")
                return
            end
            net_Start("add_whitelist_user")
            net_WriteString(factionKey)
            net_WriteString(rankKey)
            net_WriteString(steamid)
            net_SendToServer()
            frame:Close()
            timer_Simple(0.5, function() RunConsoleCommand("whitelist") end)
        end

        local scroll = vgui_Create("DScrollPanel", panel)
        scroll:Dock(FILL)
        scroll:DockMargin(s(5), 0, s(5), s(5))

        if table_IsEmpty(users) then
            local emptyLabel = vgui_Create("DLabel", scroll)
            emptyLabel:SetText("Нет пользователей в этой фракции")
            emptyLabel:SetFont("DermaDefault")
            emptyLabel:SetContentAlignment(5)
            emptyLabel:Dock(TOP)
            emptyLabel:SetTall(s(30))
        else
            for steamid, ranks in SortedPairs(users) do
                for rankKey, rankName in pairs(ranks) do
                    local btn = vgui_Create("DButton", scroll)
                    btn:Dock(TOP)
                    btn:SetTall(s(30))
                    btn:DockMargin(0, 0, 0, s(5))
                    btn:SetText(rankName .. " - " .. steamid)

                    local canRemove = false
                    if myRole == "admin" then
                        canRemove = true
                    elseif myRole == "leader" then
                        if rankKey == factionKey .. ".User" or rankKey == factionKey .. ".Deputy" then
                            canRemove = true
                        end
                    elseif myRole == "deputy" then
                        if rankKey == factionKey .. ".User" then
                            canRemove = true
                        end
                    end

                    if rankKey:find("%.Leader$") then
                        btn.Paint = function(self, w, h)
                            draw_RoundedBox(0, 0, 0, w, h, Color(220, 60, 60))
                            self:SetTextColor(color_white)
                        end
                    elseif rankKey:find("%.Deputy$") then
                        btn.Paint = function(self, w, h)
                            draw_RoundedBox(0, 0, 0, w, h, Color(220, 160, 60))
                            self:SetTextColor(color_white)
                        end
                    end

                    if not canRemove then
                        btn:SetEnabled(false)
                    else
                        btn.DoClick = function()
                            Derma_Query(
                                "Удалить пользователя " .. steamid .. " из ранга " .. rankName .. "?",
                                "Подтверждение",
                                "Да",
                                function()
                                    net_Start("remove_whitelist_user")
                                    net_WriteString(factionKey)
                                    net_WriteString(rankKey)
                                    net_WriteString(steamid)
                                    net_SendToServer()
                                    frame:Close()
                                    timer_Simple(0.5, function() RunConsoleCommand("whitelist") end)
                                end,
                                "Нет",
                                function() end
                            )
                        end
                    end
                end
            end
        end

        sheet:AddSheet(factionInfo.name, panel, "icon16/group.png")
    end
end)


concommand.Add('__mega_music', function(pl)
    hg.DynamicMusicV2.Player.Start("overdose")
end)

concommand.Add('__stop_mega_music', function(pl)
    hg.DynamicMusicV2.Player.Stop()
end)


-- [[DBG MOMENT]] --

local disabledWeps = {
    weapon_hands_sh = true,
    itemstore_pickup = true,
    rp_ziplock = true,
    weapon_handcuffs = true,
    weapon_handcuffs_key = true,
}

local disabledEnts = {
    rp_atm = true,
}

local usebleEnts = {
    rp_atm = true,
    shop_npc = true,
    soda_machine_good_build_in_wall = true,
    shz_trashcan_ragdoll = true,
    zavod_stanoc = true,
    zavod_rationdispenser = true,
    zavod_fooddispenser = true,
    zavod_waterdispenser = true,
    zavod_drop = true,
    zavod_product = true,
    zavod_final = true,
    zavod_detal = true,
    prop_ragdoll = true,
    police_arsenal = true,
    rp_maskirovka = true,
    spawned_weapon = true,
    rp_atm = true,
}

local function postDrawTranslucentRenderables()
    local ply = LocalPlayer()
    local chPosOff, chAngOff, chDefault = Vector(0,0,0), Angle(0,90,90), Material('shizlib/icon17/256/hand.png')
    
	local override = hook.Run('dbg-view.chShouldDraw', ply)

    if override == nil then
        local wep, veh = ply:GetActiveWeapon(), ply:GetVehicle()
        if IsValid(wep) and disabledWeps[wep:GetClass()] and not (wep.GetFists and wep:GetFists()) then
            override = not IsValid(veh) or ply:GetAllowWeaponsInVehicle()
        end
    end

	if not override then return end

	local aim = (ply.viewAngs or ply:EyeAngles()):Forward()
	local tr = hook.Run('dbg-view.chTraceOverride')
	if not tr then
		local pos = ply:GetShootPos()
		local endpos = pos + aim * 2000
		tr = hg.eyeTrace(ply, 2000, nil, aim)
	end

	local _icon, _alpha, _scale = hook.Run('dbg-view.chOverride', tr)
	local n = tr.Hit and tr.HitNormal or -aim
	if math.abs(n.z) > 0.98 then
		n:Add(-aim * 0.01)
	end
	local chPos, chAng = LocalToWorld(chPosOff, chAngOff, tr.HitPos, n:Angle())
    local trace = hg.eyeTrace(ply)
    local Size = math.max(math.min(1 - trace.Fraction, 1), 0.1)
    local alpha = math.Clamp(255 * Size * 1.5, 0, 255)
	cam.Start3D2D(chPos, chAng, math.pow(tr.Fraction, 0.5) * (_scale or 0.2))
        cam.IgnoreZ(true)
        
        if not hook.Run('dbg-view.chPaint', tr, _icon) then
            local distance = ply:GetPos():Distance(tr.HitPos)
            
            if distance > 80 then 
                cam.IgnoreZ(false)
                cam.End3D2D()
                return 
            end

            if disabledEnts[tr.Entity:GetClass()] then 
                cam.IgnoreZ(false)
                cam.End3D2D()
                return 
            end

            if !usebleEnts[tr.Entity:GetClass()] and !tr.Entity:IsPlayer() then 
                cam.IgnoreZ(false)

                surface.SetDrawColor(Color(125, 125, 125))
                draw.NoTexture()
                Circle(-32, -32, 35 * Size + 15, 32)
                surface.SetDrawColor(Color(255, 255, 255))
                draw.NoTexture()
                Circle(-32, -32, 25 * Size + 10, 32)

                cam.End3D2D()
                return 
            end
            
            if _icon then 
                surface.SetDrawColor(255, 255, 255, _alpha or 150)
            else
                local clr = Color(255, 255, 255, alpha or 255)
                surface.SetDrawColor(clr)
            end
            
            surface.SetMaterial(_icon or chDefault)
            surface.DrawTexturedRect(-32, -32, 64, 64)
        end
        
        cam.IgnoreZ(false)
    cam.End3D2D()

end

hook.Add('PostDrawTranslucentRenderables', 'dbg-view', postDrawTranslucentRenderables)

local delays = {}

surface.CreateFont('octolib.use', {
	font = 'Calibri',
	extended = true,
	size = 82,
	weight = 350,
})

surface.CreateFont('octolib.use-sh', {
	font = 'Calibri',
	extended = true,
	size = 82,
	weight = 350,
	blursize = 5,
})

netstream.Hook('octolib.delay', function(id, active, text, time)

	local id = id
	local active = active

	if active then
		delays[id] = {
			text = text,
			start = CurTime(),
			time = time - CurTime(),
		}
	else
		delays[id] = nil
	end

end)

local cx, cy = 0, 0
local size = 40
local p1, p2 = {}, {}
for i = 1, 36 do
	local a1 = math.rad((i-1) * -10 + 180)
	local a2 = math.rad(i * -10 + 180)
	p1[i] = { x = cx + math.sin(a1) * size, y = cy + math.cos(a1) * size }
	p2[i] = {
		{ x = cx, y = cy },
		{ x = cx + math.sin(a1) * size, y = cy + math.cos(a1) * size },
		{ x = cx + math.sin(a2) * size, y = cy + math.cos(a2) * size },
	}
end

local override
hook.Add('dbg-view.chShouldDraw', 'octolib.delay', function()

	override = table.Count(delays) > 0
	if override then return true end

end)

hook.Add('dbg-view.chPaint', 'octolib.delay', function(tr, icon)

	for id, data in pairs(delays) do
		local segs = math.min(math.ceil((CurTime() - data.start) / data.time * 36), 36)
		local text = data.text .. ('.'):rep(math.floor(CurTime() * 2 % 4))
		draw.SimpleText(text, 'octolib.use-sh', 0 + 60, 0, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(text, 'octolib.use', 0 + 60, 0, Color(255,255,255, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		draw.NoTexture()
		surface.SetDrawColor(255,255,255, 50)
		surface.DrawPoly(p1)

		surface.SetDrawColor(255,255,255, 150)
		for i = 1, segs do
			surface.DrawPoly(p2[i])
		end

		return true
	end

end)

hook.Add('dbg-view.chOverride', 'octolib.delay', function(tr, icon)

	local ply = LocalPlayer()
	if override and (not tr.Hit or tr.Fraction > 0.03) then
		local aim = (ply.viewAngs or ply:EyeAngles()):Forward()
		tr.HitPos = ply:GetShootPos() + aim * 60
		tr.HitNormal = -aim
		tr.Fraction = 0.03
	end

end)