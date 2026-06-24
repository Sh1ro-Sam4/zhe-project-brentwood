AddCSLuaFile()

SWEP.PrintName = "Админская тулза"
SWEP.Author = "NEURO-SAMA"
SWEP.Purpose = "Быстрый доступ к бану, кику и информации об игроке."
SWEP.Instructions = "Нажмите ЛКМ по игроку, чтобы открыть админское меню."

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "Admin"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/c_toolgun.mdl")
SWEP.WorldModel = Model("models/weapons/w_toolgun.mdl")
SWEP.ViewModelFOV = 54
SWEP.HoldType = "pistol"
SWEP.NoDrop = true
SWEP.UnDroppable = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local function FormatPlaytime(seconds)
    if not seconds or seconds < 0 then return "N/A" end
    local hours = math.floor(seconds / 3600)
    local mins = math.floor(seconds % 3600 / 60)
    return Format("%d ч %02d мин", hours, mins)
end

if SERVER then
    util.AddNetworkString("AdminTool_OpenMenu")
    util.AddNetworkString("AdminTool_PerformAction")

    local function PerformAdminAction(ply, data)
        if not IsValid(ply) or not ply:IsPlayer() or not ply:IsAdmin() then return end

        local target = EntIndexToHScript(data.targetIndex or 0)
        if not IsValid(target) or not target:IsPlayer() then return end
        if target == ply then return end
        if not target:Alive() then return end

        local action = data.action or ""
        local reason = data.reason or ""
        local length = tonumber(data.length) or 0

        if action == "quick_kick" then
            target:Kick("Нарушение атмосферы")
            return
        end

        if action == "kick" then
            if reason == "" then reason = "Кик от администратора" end
            target:Kick(reason)
            return
        end

        if action == "ban" then
            if reason == "" then reason = "Бан от администратора" end
            if length <= 0 then length = 60 end

            if PerformKickBan then
                PerformKickBan(target, length, reason)
            else
                RunConsoleCommand("banid", tostring(length), tostring(target:UserID()))
                target:Kick(reason)
            end
            return
        end
    end

    net.Receive("AdminTool_PerformAction", function(len, ply)
        local action = net.ReadString()
        local targetIndex = net.ReadInt(16)
        local reason = net.ReadString()
        local length = net.ReadString()

        PerformAdminAction(ply, {
            action = action,
            targetIndex = targetIndex,
            reason = reason,
            length = length
        })
    end)
end

if CLIENT then
    surface.CreateFont("AdminTool.Title", {
        font = "Montserrat",
        size = 28,
        weight = 700,
        extended = true,
        antialias = true
    })
    surface.CreateFont("AdminTool.Header", {
        font = "Montserrat",
        size = 18,
        weight = 600,
        extended = true,
        antialias = true
    })
    surface.CreateFont("AdminTool.Info", {
        font = "Montserrat",
        size = 14,
        weight = 500,
        extended = true,
        antialias = true
    })
    surface.CreateFont("AdminTool.Button", {
        font = "Montserrat",
        size = 15,
        weight = 700,
        extended = true,
        antialias = true
    })

    local theme = {
        bg = Color(20, 20, 20),
        header = Color(14, 14, 18),
        panel = Color(28, 30, 40),
        panel_alt = Color(34, 36, 48),
        accent = Color(255, 77, 119),
        accent_hover = Color(255, 100, 145),
        danger = Color(235, 80, 80),
        danger_hover = Color(255, 100, 100),
        warning = Color(245, 155, 70),
        warning_hover = Color(255, 180, 95),
        text = Color(235, 235, 235),
        text_sub = Color(165, 175, 195),
        text_muted = Color(110, 120, 135),
        hover = Color(48, 54, 73)
    }

    local blur = Material("pp/blurscreen")
    local function DrawBlur(panel, amount, passes)
        if not IsValid(panel) then return end
        local x, y = panel:LocalToScreen(0, 0)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(blur)
        for i = 1, (passes or 3) do
            blur:SetFloat("$blur", (i / (passes or 3)) * (amount or 6))
            blur:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
        end
    end

    local function DrawShadow(x, y, w, h)
        for i = 1, 6 do
            draw.RoundedBox(12, x - i, y - i, w + (i * 2), h + (i * 2), Color(0, 0, 0, 14))
        end
    end

    local function CreateStyledButton(parent, text, icon, x, y, w, h, bgColor, hoverColor, textColor, callback)
        local btn = vgui.Create("DButton", parent)
        btn:SetPos(x, y)
        btn:SetSize(w, h)
        btn:SetText("")
        btn:SetFont("AdminTool.Button")
        btn.hovering = false
        btn.label = (icon and icon .. " " or "") .. text
        btn.bgColor = bgColor
        btn.hoverColor = hoverColor
        btn.textColor = textColor

        btn.Paint = function(self, bw, bh)
            local color = self.hovering and self.hoverColor or self.bgColor
            draw.RoundedBox(10, 0, 0, bw, bh, color)
            draw.SimpleText(self.label, "AdminTool.Button", bw / 2, bh / 2, self.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        function btn:OnCursorEntered()
            self.hovering = true
            surface.PlaySound("ui/buttonrollover.wav")
        end

        function btn:OnCursorExited()
            self.hovering = false
        end

        function btn:DoClick()
            surface.PlaySound("ui/buttonclick.wav")
            if callback then callback() end
        end

        return btn
    end

    local function ExecuteSamAdminCommand(commandName, ...)
        RunConsoleCommand("sam", commandName, ...)
    end

    local function RequestKick(target, backdrop)
        if not shizlib or not shizlib.request or not shizlib.request.string then return end
        local defaultReason = "Нарушение атмосферы"
        shizlib.request.string("Кик игрока", "Введите причину кика для " .. target:Nick(), defaultReason, function(reason)
            reason = reason or defaultReason
            ExecuteSamAdminCommand("kick", target:SteamID(), reason)
            if IsValid(backdrop) then
                backdrop:AlphaTo(0, 0.2, 0, function()
                    if IsValid(backdrop) then backdrop:Remove() end
                end)
            end
        end)
    end

    local function RequestBan(target, backdrop)
        if not shizlib or not shizlib.request or not shizlib.request.number or not shizlib.request.string then return end
        shizlib.request.number("Длительность бана", "Укажите длительность бана в минутах для " .. target:Nick(), "60", function(length)
            length = tonumber(length) or 60
            if length <= 0 then length = 60 end
            shizlib.request.string("Причина бана", "Введите причину бана для " .. target:Nick(), "Нарушение атмосферы", function(reason)
                reason = reason or "Нарушение атмосферы"
                ExecuteSamAdminCommand("ban", target:SteamID(), tostring(length), reason)
                if IsValid(backdrop) then
                    backdrop:AlphaTo(0, 0.2, 0, function()
                        if IsValid(backdrop) then backdrop:Remove() end
                    end)
                end
            end)
        end)
    end

    local function MakeAdminMenu(target, playtime)
        if not IsValid(target) then return end

        local backdrop = vgui.Create("DPanel")
        backdrop:SetSize(ScrW(), ScrH())
        backdrop:MakePopup()
        backdrop:SetAlpha(0)
        backdrop:AlphaTo(255, 0.25)
        backdrop.Paint = function(self, w, h)
            DrawBlur(self, 6, 4)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
        end

        local frame = vgui.Create("DPanel", backdrop)
        frame:SetSize(520, 520)
        frame:Center()
        frame.Paint = function(self, w, h)
            DrawShadow(0, 0, w, h)
            draw.RoundedBox(16, 0, 0, w, h, theme.bg)
            draw.RoundedBoxEx(16, 0, 0, w, 100, theme.header, true, true, false, false)
            draw.SimpleText("Админская панель", "AdminTool.Title", 24, 24, theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Выберите действие для игрока", "AdminTool.Info", 24, 56, theme.text_sub, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local closeBtn = vgui.Create("DButton", frame)
        closeBtn:SetPos(frame:GetWide() - 44, 24)
        closeBtn:SetSize(28, 28)
        closeBtn:SetText("✕")
        closeBtn:SetFont("AdminTool.Header")
        closeBtn:SetTextColor(theme.text_sub)
        closeBtn.Paint = function(self, w, h)
            if self:IsHovered() then
                draw.RoundedBox(10, 0, 0, w, h, Color(255, 255, 255, 16))
            end
        end
        closeBtn.DoClick = function()
            backdrop:AlphaTo(0, 0.2, 0, function()
                if IsValid(backdrop) then backdrop:Remove() end
            end)
        end
        closeBtn.OnCursorEntered = function(self)
            self:SetTextColor(theme.accent)
            surface.PlaySound("ui/buttonrollover.wav")
        end
        closeBtn.OnCursorExited = function(self)
            self:SetTextColor(theme.text_sub)
        end

        local infoPanel = vgui.Create("DPanel", frame)
        infoPanel:SetPos(20, 120)
        infoPanel:SetSize(480, 155)
        infoPanel.Paint = function(self, w, h)
            draw.RoundedBox(14, 0, 0, w, h, theme.panel)
            draw.RoundedBox(14, 0, 0, w, 45, theme.panel_alt)
            draw.SimpleText("Информация", "AdminTool.Header", 18, 22, theme.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            if self:IsHovered() then
                draw.RoundedBox(14, 0, 0, w, h, Color(255, 255, 255, 8))
            end
        end

        local infoButton = vgui.Create("DButton", infoPanel)
        infoButton:Dock(FILL)
        infoButton:SetText("")
        infoButton.OnCursorEntered = function(self)
            self:SetCursor("hand")
        end
        infoButton.Paint = function() end
        infoButton.DoClick = function()
            SetClipboardText(target:SteamID())
            notification.AddLegacy("SteamID скопирован!", NOTIFY_GENERIC, 3)
            surface.PlaySound("ui/buttonclick.wav")
        end

        local avatar = vgui.Create("AvatarImage", infoPanel)
        avatar:SetPos(18, 50)
        avatar:SetSize(70, 70)
        avatar:SetPlayer(target, 64)

        local nameLabel = vgui.Create("DLabel", infoPanel)
        nameLabel:SetPos(104, 20)
        nameLabel:SetSize(350, 24)
        nameLabel:SetFont("AdminTool.Header")
        nameLabel:SetText(target:Nick())
        nameLabel:SetTextColor(theme.text)

        local rankText = target:GetUserGroup()

        local hasPremium = false
        if type(target.IsPremium) == "function" and target:IsPremium() then
            hasPremium = true
        elseif target.GetNWBool and (target:GetNWBool("Premium", false) or target:GetNWBool("premium", false)) then
            hasPremium = true
        end

        local moneyAmount = "N/A"
        if type(target.getDarkRPVar) == "function" then
            local money = target:getDarkRPVar("money")
            if money then
                if DarkRP and type(DarkRP.formatMoney) == "function" then
                    moneyAmount = DarkRP.formatMoney(money)
                else
                    moneyAmount = tostring(money)
                end
            end
        elseif target.GetNWInt then
            local money = target:GetNWInt("money", 0)
            moneyAmount = tostring(money)
        end

        local statusLabel = vgui.Create("DLabel", infoPanel)
        statusLabel:SetPos(104, 48)
        statusLabel:SetSize(350, 20)
        statusLabel:SetFont("AdminTool.Info")
        statusLabel:SetText("Ранг: " .. rankText .. " • Премиум: " .. (hasPremium and "Да" or "Нет"))
        statusLabel:SetTextColor(theme.text_sub)

        local timeLabel = vgui.Create("DLabel", infoPanel)
        timeLabel:SetPos(104, 70)
        timeLabel:SetSize(350, 20)
        timeLabel:SetFont("AdminTool.Info")
        timeLabel:SetText("Время: " .. playtime)
        timeLabel:SetTextColor(theme.text_sub)

        local moneyLabel = vgui.Create("DLabel", infoPanel)
        moneyLabel:SetPos(104, 92)
        moneyLabel:SetSize(350, 20)
        moneyLabel:SetFont("AdminTool.Info")
        moneyLabel:SetText("Деньги: " .. moneyAmount)
        moneyLabel:SetTextColor(theme.text_sub)

        local steamLabel = vgui.Create("DLabel", infoPanel)
        steamLabel:SetPos(104, 114)
        steamLabel:SetSize(350, 20)
        steamLabel:SetFont("AdminTool.Info")
        steamLabel:SetText("SteamID: " .. target:SteamID() .. " (клик для копирования)")
        steamLabel:SetTextColor(theme.accent)

        CreateStyledButton(frame, "Быстрый кик", "", 20, 290, 220, 50, theme.accent, theme.accent_hover, theme.bg, function()
            ExecuteSamAdminCommand("kick", target:SteamID(), "Нарушение атмосферы")
            backdrop:AlphaTo(0, 0.2, 0, function()
                if IsValid(backdrop) then backdrop:Remove() end
            end)
        end)

        CreateStyledButton(frame, "Кик", "", 260, 290, 220, 50, theme.warning, theme.warning_hover, theme.bg, function()
            RequestKick(target, backdrop)
        end)

        CreateStyledButton(frame, "Скопировать SteamID", "", 20, 350, 220, 50, theme.panel_alt, theme.hover, theme.text, function()
            SetClipboardText(target:SteamID())
            notification.AddLegacy("SteamID скопирован!", NOTIFY_GENERIC, 3)
        end)

        CreateStyledButton(frame, "Бан", "", 260, 350, 220, 50, theme.danger, theme.danger_hover, theme.text, function()
            RequestBan(target, backdrop)
        end)
    end

    local function OpenReasonForm(mode, target, backdrop)
        if mode == "kick" then
            RequestKick(target, backdrop)
        elseif mode == "ban" then
            RequestBan(target, backdrop)
        end
    end

    net.Receive("AdminTool_OpenMenu", function()
        local target = net.ReadEntity()
        local playtime = net.ReadString()
        if not IsValid(target) then return end
        MakeAdminMenu(target, playtime)
    end)
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() or not owner:IsAdmin() then return end

    owner:LagCompensation(true)
    local tr = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * 200,
        filter = owner,
        mask = MASK_SHOT
    })
    owner:LagCompensation(false)

    local target = tr.Entity
    if IsValid(target) and target:IsPlayer() then
        if SERVER then
            local playtime = "N/A"
            if target.GetUTimeTotalTime then
                playtime = FormatPlaytime(target:GetUTimeTotalTime())
            elseif target.TimeConnected then
                playtime = FormatPlaytime(target:TimeConnected())
            end

            net.Start("AdminTool_OpenMenu")
            net.WriteEntity(target)
            net.WriteString(playtime)
            net.Send(owner)
        end
    end

    self:SetNextPrimaryFire(CurTime() + 0.5)
end

function SWEP:SecondaryAttack()
    self:PrimaryAttack()
end