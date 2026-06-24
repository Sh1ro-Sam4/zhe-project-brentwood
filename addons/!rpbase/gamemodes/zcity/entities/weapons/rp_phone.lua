if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik1_base"
SWEP.PrintName = "Телефон"
SWEP.Instructions = ""
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminOnly = false

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_phone")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_phone"
end

SWEP.Slot = 0
SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

SWEP.WorldModel = "models/ivancorn/gtaiv/electrical/phones/cellphone_badger_crappy.mdl"
SWEP.ViewModel = ""
SWEP.HoldType = "normal"

SWEP.setrhik = true
SWEP.setlhik = false

SWEP.LHPos = Vector(0,0,0)
SWEP.LHAng = Angle(0,0,0)

SWEP.RHPosOffset = Vector(1,-1,-4)
SWEP.RHAngOffset = Angle(0,45,-90)

SWEP.LHPosOffset = Vector(0,0,0)
SWEP.LHAngOffset = Angle(0,0,0)

SWEP.handPos = Vector(0,0,0)
SWEP.handAng = Angle(0,0,0)

SWEP.UsePistolHold = false

SWEP.offsetVec = Vector(5,-2,-2)
SWEP.offsetAng = Angle(0,90,120)   

SWEP.HeadPosOffset = Vector(12,3,-5)
SWEP.HeadAngOffset = Angle(-90,0,-90)

SWEP.BaseBone = "ValveBiped.Bip01_Head1"

SWEP.HoldLH = "normal"
SWEP.HoldRH = "normal"

SWEP.HoldClampMax = 35
SWEP.HoldClampMin = 35

SWEP.Skin = 2

function SWEP:SecondaryAttack()
end

if SERVER then return end

-- Глобальная переменная для отслеживания активного телефона
RP_PHONE_ACTIVE_WEP = RP_PHONE_ACTIVE_WEP or nil

-- ФИКС: Ультимативный хук-предохранитель. Работает ВСЕГДА, даже если Holster/OnRemove не вызвались движком
hook.Add("Think", "RP_Phone_SafetyCheck", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local wep = ply:GetActiveWeapon()
    local isPhoneActive = IsValid(wep) and wep:GetClass() == "rp_phone"
    
    -- Если игрок мертв ИЛИ в руках больше не телефон
    if not ply:Alive() or not isPhoneActive then
        if IsValid(RP_PHONE_ACTIVE_WEP) then
            if RP_PHONE_ACTIVE_WEP.MouseHasControl then
                gui.EnableScreenClicker(false)
                RP_PHONE_ACTIVE_WEP.MouseHasControl = false
            end
            if IsValid(RP_PHONE_ACTIVE_WEP.menu) then
                -- Снимаем фокус с меню перед удалением
                RP_PHONE_ACTIVE_WEP.menu:SetMouseInputEnabled(false)
                RP_PHONE_ACTIVE_WEP.menu:SetKeyboardInputEnabled(false)
                RP_PHONE_ACTIVE_WEP.menu:Remove()
            end
            RP_PHONE_ACTIVE_WEP = nil
        end
    else
        RP_PHONE_ACTIVE_WEP = wep
    end
end)

hook.Add("GUIMousePressed", "HideCursorOnRightClick", function(mouseCode)
    if mouseCode == MOUSE_RIGHT then
        local ply = LocalPlayer()
        if IsValid(ply) and ply:Alive() then
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) and wep:GetClass() == "rp_phone" then
                if IsValid(wep.menu) then
                    wep.menu:SetMouseInputEnabled(false)
                    wep.menu:SetKeyboardInputEnabled(false)
                    wep.menu:Close()
                end
                if wep.MouseHasControl then
                    gui.EnableScreenClicker(false)
                    wep.MouseHasControl = false
                end
            end
        end
    end
end)

local numbat = math.random(20, 100)

local color_black = Color(0,0,0)
local col_bg = Color(0,75,0)
local col_pnl = Color(0,75,0, 50)
local col_btn = Color(0,100,0)
local col_btnout = Color(0,160,0)

function SWEP:CreateMenu()
    if IsValid(self.menu) then self.menu:Remove() end
    
    local baseW, baseH = 1920, 1080
    local baseMenuW, baseMenuH = 110, 103
    local currentW, currentH = 1920, 1080
    local scaleX = currentW / baseW
    local scaleY = currentH / baseH
    local scale = math.min(scaleX, scaleY)
    local menuW = math.floor(baseMenuW * scale)
    local menuH = math.floor(baseMenuH * scale)
    
    self.menu = vgui.Create( "DFrame" )
    self.menu:SetSize( menuW, menuH )
    self.menu:SetPos(1920 / 2.12,1080 / 1.75)
    self.menu:SetTitle("")
    self.menu:ShowCloseButton(false)
    self.menu:SetDraggable(false)
    local tablet = self
    self.menu.Paint = function(s, w, h)
        local time = os.date("%H:%M") 
        draw.RoundedBox(4, 0, 0, w, h, col_bg)
        draw.SimpleText(time, 'ui.12', 3, 0, color_black)
    end
    
    function self.menu:Think()
        local ply = LocalPlayer()
        if not IsValid(tablet) or not IsValid(ply) or not ply:Alive() then
            if IsValid(tablet) and tablet.MouseHasControl then
                gui.EnableScreenClicker(false)
                tablet.MouseHasControl = false
            end
            self:Remove()
            return
        end
    end

    local wifi = vgui.Create('DLabel', self.menu)
    wifi:SetPos(self.menu:GetWide() / 1.43, -4)
    wifi:SetFont('SVG_25_3D')
    wifi:SetText('s')
    wifi:SetTextColor(color_black)

    local batary = vgui.Create('DLabel', self.menu)
    batary:SetPos(self.menu:GetWide() / 1.23, -2)
    batary:SetFont('ui.12')
    batary:SetText('99' .. '%')
    batary:SetTextColor(color_black)

    self.panel = vgui.Create('DScrollPanel', self.menu)
    self.panel:Dock(FILL)
    self.panel:DockMargin(0, -14, 0, 0)
    self.panel.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, color_black)
        draw.RoundedBox(0, 0, 0, w, h, col_pnl)
    end

    self.call = vgui.Create('DButton', self.panel)
    self.call:Dock(TOP)
    self.call:DockMargin(3,3,3,3)
    self.call:SetText('Контакты')

    self.call.Paint = function(s, w, h)
        if s.Hovered then
            col_btn = Color(0,75,0)
        else
            col_btn = Color(0,100,0)
        end

        surface.SetDrawColor(col_btn)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(col_btnout)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    self.call.DoClick = function()
        surface.PlaySound('garrysmod/ui_click.wav')
        self:callmenu()
        self.call:Remove()
    end

    self.news = vgui.Create('DButton', self.panel)
    self.news:Dock(TOP)
    self.news:DockMargin(3,3,3,3)
    self.news:SetText('GPS')

    self.news.Paint = function(s, w, h)
        if s.Hovered then
            col_btn = Color(0,75,0)
        else
            col_btn = Color(0,100,0)
        end

        surface.SetDrawColor(col_btn)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(col_btnout)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    self.news.DoClick = function()
        surface.PlaySound('garrysmod/ui_click.wav')
        self:opennews()
    end

    self.house = vgui.Create('DButton', self.panel)
    self.house:Dock(TOP)
    self.house:DockMargin(3,3,3,3)
    self.house:SetText('Недвижимость')

    self.house.Paint = function(s, w, h)
        if s.Hovered then
            col_btn = Color(0,75,0)
        else
            col_btn = Color(0,100,0)
        end

        surface.SetDrawColor(col_btn)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(col_btnout)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    self.house.DoClick = function()
        surface.PlaySound('garrysmod/ui_click.wav')
        self:openhouse()
    end
end

function SWEP:opennews()
    local panelnews = vgui.Create('DScrollPanel', self.menu)
    panelnews:Dock(FILL)
    panelnews:DockMargin(0, -14, 0, 0)
    panelnews.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, color_black)
        draw.RoundedBox(0, 0, 0, w, h, col_pnl)
    end

    for _, gps in pairs(ChaikaConfig.Metka) do
        local gpsbtn = vgui.Create('DButton', panelnews)
        gpsbtn:Dock(TOP)
        gpsbtn:DockMargin(3,3,3,3)
        gpsbtn:SetFont('ui.12')
        gpsbtn:SetText(gps[1])

        gpsbtn.Paint = function(s, w, h)
            if s.Hovered then
                col_btn = Color(0,75,0)
            else
                col_btn = Color(0,100,0)
            end

            surface.SetDrawColor(col_btn)
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(col_btnout)
            surface.DrawOutlinedRect(0, 0, w, h)
        end

        gpsbtn.DoClick = function()
            surface.PlaySound('garrysmod/ui_click.wav')
            if timer.Exists('TurnMeToPoint') then timer.Remove('TurnMeToPoint') end
            RunConsoleCommand( string.format('shizlib_gps_%s', gps[3]), GetConVarNumber(string.format('shizlib_gps_%s', gps[3])) == 1 and 0 or 1 )
            if GetConVarNumber(string.format('shizlib_gps_%s', gps[3])) == 1 then return end
            local startAng = LocalPlayer():EyeAngles()
            local endAngle = ( ( Vector(gps[2]) + Vector(0,0,0) ) - LocalPlayer():EyePos() ):Angle()
            local ratio = 0
            timer.Create('TurnMeToPoint', 0, 0, function()
                ratio = ratio + 1*FrameTime()
                local ang = LerpAngle(ratio, startAng, endAngle)
                ang.roll = 0
                LocalPlayer():SetEyeAngles(ang)
                if ratio >= 1 then timer.Remove('TurnMeToPoint') end
            end)
        end
    end
end

function SWEP:openhouse()
    local panelhouse = vgui.Create('DScrollPanel', self.menu)
    panelhouse:Dock(FILL)
    panelhouse:DockMargin(0, -14, 0, 0)
    panelhouse.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, color_black)
        draw.RoundedBox(0, 0, 0, w, h, col_pnl)
    end

    for _, dom in ipairs(cfg.doors) do
        if dom.Teams then continue end
        
        local ply = LocalPlayer()
        
        local house = vgui.Create('DButton', panelhouse)
        house:Dock(TOP)
        house:DockMargin(3, 3, 3, 3)
        house:SetText(dom.Name .. ' - ' .. (dom.Price or cfg.defaultprice) .. ' $')

        house.Paint = function(s, w, h)
            local col_btn
            if s.Hovered then
                col_btn = Color(0, 75, 0)
            else
                col_btn = Color(0, 100, 0)
            end

            surface.SetDrawColor(col_btn)
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(col_btnout)
            surface.DrawOutlinedRect(0, 0, w, h)
        end

        house.DoClick = function()
            surface.PlaySound('garrysmod/ui_click.wav')
            
            local targetDoor = nil
            for _, ent in ents.Iterator() do
                if ent:IsManagedDoor() then
                    local cfg = ent:GetDoorCfg()
                    if cfg and cfg.Name == dom.Name then
                        targetDoor = ent
                        break
                    end
                end
            end

            if self.MouseHasControl then
                gui.EnableScreenClicker(false)
                self.MouseHasControl = false
            end
            if IsValid(self.menu) then
                self.menu:SetMouseInputEnabled(false)
                self.menu:SetKeyboardInputEnabled(false)
                self.menu:Close()
            end
            
            if IsValid(targetDoor) then
                net.Start("DoorSys.Action")
                    net.WriteEntity(targetDoor)
                    net.WriteString("buy")
                net.SendToServer()
            end
        end
    end
end

function SWEP:callmenu()
    local panelcall = vgui.Create('DScrollPanel', self.menu)
    panelcall:Dock(FILL)
    panelcall:DockMargin(0, -14, 0, 0)
    panelcall.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, color_black)
        draw.RoundedBox(0, 0, 0, w, h, col_pnl)
    end

    local call911 = vgui.Create('DButton', panelcall)
    call911:Dock(TOP)
    call911:DockMargin(3,3,3,3)
    call911:SetText('911')

    call911.Paint = function(s, w, h)
        if s.Hovered then
            col_btn = Color(0,75,0)
        else
            col_btn = Color(0,100,0)
        end

        surface.SetDrawColor(col_btn)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(col_btnout)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    call911.DoClick = function()
        surface.PlaySound('garrysmod/ui_click.wav')
        LocalPlayer():EmitSound('phone/gudok.wav', 60)

        timer.Simple(3, function()
            LocalPlayer():EmitSound('phone/911.wav', 60)
        end)
        timer.Simple(5, function()
            self:open911()
        end)
    end

    for _, ply in ipairs(player.GetAll()) do
        if ply == LocalPlayer() then continue end
        local callbtn = vgui.Create('DButton', panelcall)
        callbtn:Dock(TOP)
        callbtn:DockMargin(3,3,3,3)
        callbtn:SetText(ply:GetPlayerName())

        callbtn.Paint = function(s, w, h)
            if s.Hovered then
                col_btn = Color(0,75,0)
            else
                col_btn = Color(0,100,0)
            end

            surface.SetDrawColor(col_btn)
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(col_btnout)
            surface.DrawOutlinedRect(0, 0, w, h)
        end

        callbtn.DoClick = function()
            surface.PlaySound('garrysmod/ui_click.wav')
            if IsValid(ply) then
                Phone.StartCall(ply)
            end
        end
    end
end

function SWEP:open911()
    local panel911 = vgui.Create('DScrollPanel', self.menu)
    panel911:Dock(FILL)
    panel911:DockMargin(0, -14, 0, 0)
    panel911.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, color_black)
        draw.RoundedBox(0, 0, 0, w, h, col_pnl)
    end

    local callpolice = vgui.Create('DButton', panel911)
    callpolice:Dock(TOP)
    callpolice:DockMargin(3,3,3,3)
    callpolice:SetText('Полиция')

    callpolice.Paint = function(s, w, h)
        if s.Hovered then
            col_btn = Color(0,75,0)
        else
            col_btn = Color(0,100,0)
        end

        surface.SetDrawColor(col_btn)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(col_btnout)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    callpolice.DoClick = function()
        surface.PlaySound('garrysmod/ui_click.wav')
        Derma_StringRequest("Вызов полиции", "Сообщение для полиции?", "", function(text)
            net.Start("rp.GovernmentRequare")
                net.WriteString(text)
            net.SendToServer()
        end)
        
        if self.MouseHasControl then
            gui.EnableScreenClicker(false)
            self.MouseHasControl = false
        end
        if IsValid(self.menu) then
            self.menu:SetMouseInputEnabled(false)
            self.menu:SetKeyboardInputEnabled(false)
            self.menu:Close()
        end
    end
end



function SWEP:PrimaryAttack()
    -- ФИКС: Защита от спама ЛКМ, из-за которого ломался gui.EnableScreenClicker
    if IsValid(self.menu) and not self.MouseHasControl then
        self.menu:SetMouseInputEnabled( true )
        self.menu:SetKeyboardInputEnabled( true )
        self.menu:MakePopup()
        self.MouseHasControl = true
        gui.EnableScreenClicker(true)
    end
end

function SWEP:AddDrawModel(ent)
    if not IsValid(self:GetOwner()) or self:GetOwner() ~= LocalPlayer() then return end
    if not IsValid(self.menu) then self:CreateMenu() end
    if not IsValid(self.menu) then return end

    local pos, ang = ent:GetRenderOrigin(), ent:GetRenderAngles()
    local basePos = pos + ang:Up() * 11.3 + ang:Forward() * -14.5 + ang:Right() * .55
    local baseH = 1080
    local currentH = 1080
    local baseScale = 0.0151
    local scale3d = baseScale * (baseH / currentH)
    local menuW, menuH = self.menu:GetSize()
    local menuHeight = menuH
    local heightDiff = menuHeight * (baseScale - scale3d)
    local posOffset = heightDiff / 12
    pos = basePos + ang:Up() * posOffset
    ang = Angle(ang.p - 0, ang.y + 0, ang.r + 90)
    
    vgui.Start3D2D(pos, ang, scale3d)
        self.menu:Paint3D2D()
    vgui.End3D2D()
end

function SWEP:Holster()
    if self.MouseHasControl then
        gui.EnableScreenClicker(false)
        self.MouseHasControl = false
    end
    if IsValid(self.menu) then
        self.menu:SetMouseInputEnabled(false)
        self.menu:SetKeyboardInputEnabled(false)
        self.menu:Remove()
    end
    return true
end

function SWEP:OnRemove()
    if self.MouseHasControl then
        gui.EnableScreenClicker(false)
        self.MouseHasControl = false
    end
    if IsValid(self.menu) then
        self.menu:SetMouseInputEnabled(false)
        self.menu:SetKeyboardInputEnabled(false)
        self.menu:Remove()
    end
end