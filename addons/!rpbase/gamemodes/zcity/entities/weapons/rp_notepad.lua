if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik1_base"
SWEP.PrintName = "Блокнот"
SWEP.Instructions = ""
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminOnly = false
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

SWEP.WorldModel = "models/props_lab/clipboard.mdl"
SWEP.ViewModel = ""
SWEP.HoldType = "normal"

SWEP.setrhik = true
SWEP.setlhik = false

SWEP.LHPos = Vector(0,0,0)
SWEP.LHAng = Angle(0,0,0)

SWEP.RHPosOffset = Vector(0,0,-7)
SWEP.RHAngOffset = Angle(0,45,-90)

SWEP.LHPosOffset = Vector(0,0,0)
SWEP.LHAngOffset = Angle(0,0,0)

SWEP.handPos = Vector(0,0,0)
SWEP.handAng = Angle(0,0,0)

SWEP.UsePistolHold = false

SWEP.offsetVec = Vector(5,-4,-3)
SWEP.offsetAng = Angle(-130,0,0)   

SWEP.HeadPosOffset = Vector(12,3,-5)
SWEP.HeadAngOffset = Angle(-90,0,-90)

SWEP.BaseBone = "ValveBiped.Bip01_Head1"

SWEP.HoldLH = "normal"
SWEP.HoldRH = "normal"

SWEP.HoldClampMax = 35
SWEP.HoldClampMin = 35

SWEP.Skin = 2

if SERVER then
    util.AddNetworkString("NotepadRequestData")
    util.AddNetworkString("NotepadSaveData")

    if not sql.TableExists("rp_notepad") then
        sql.Query([[
            CREATE TABLE IF NOT EXISTS rp_notepad (
                steamid VARCHAR(32) PRIMARY KEY,
                notepad TEXT NOT NULL DEFAULT ''
            )
        ]])
    end

    local function GetNotepadData(ply)
        if not IsValid(ply) or not ply:SteamID() then return "" end
        local steamid = ply:SteamID()
        local data = sql.Query("SELECT notepad FROM rp_notepad WHERE steamid = " .. sql.SQLStr(steamid))
        
        if data and #data > 0 then
            return data[1].notepad or ""
        else
            sql.Query("INSERT INTO rp_notepad (steamid, notepad) VALUES (" .. sql.SQLStr(steamid) .. ", '')")
            return ""
        end
    end

    local function SaveNotepadData(ply, text)
        if not IsValid(ply) or not ply:SteamID() then return end
        local steamid = ply:SteamID()
        sql.Query("REPLACE INTO rp_notepad (steamid, notepad) VALUES (" .. sql.SQLStr(steamid) .. ", " .. sql.SQLStr(text) .. ")")
    end

    net.Receive("NotepadSaveData", function(len, ply)
        local text = net.ReadString()
        SaveNotepadData(ply, text)
    end)

    net.Receive("NotepadRequestData", function(len, ply)
        local data = GetNotepadData(ply)
        net.Start("NotepadRequestData")
        net.WriteString(data)
        net.Send(ply)
    end)

    hook.Add("PlayerDisconnected", "SaveNotepadOnLeave", function(ply)
        if IsValid(ply) then
            local data = ply:GetNWString("notepad_cache", "")
            SaveNotepadData(ply, data)
        end
    end)

    return
end

local color_black = Color(0,0,0)
local col_pnl = Color(255,240,185)
local col_btn = Color(0,100,0)
local col_btnout = Color(0,160,0)

function SWEP:CreateMenu()
    if IsValid(self.menu) then self.menu:Remove() end
    self.menu = vgui.Create("DFrame")
    self.menu:SetSize(ScrW() * 0.5, ScrH() * 0.7)
    self.menu:Center()
    self.menu:SetTitle("Блокнот")
    self.menu:ShowCloseButton(true)
    self.menu:SetDraggable(false)
    self.menu:MakePopup()

    local panel = vgui.Create('DPanel', self.menu)
    panel:Dock(FILL)
    panel:DockMargin(2,2,2,2)
    panel.Paint = function(s, w, h) end

    local panel2 = vgui.Create('DPanel', panel)
    panel2:Dock(FILL)
    panel2:DockMargin(2,2,2,2)
    panel2.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, col_pnl)
    end

    self.txt = vgui.Create('DTextEntry', panel2)
    self.txt:Dock(FILL)
    self.txt:SetFont('ui.15')
    self.txt:SetMultiline(true)
    self.txt:SetText("Загрузка...")

    self.txt.OnTextChanged = function(self)
        if (#self:GetValue() > 2000) then
            self:SetText(string.sub(self:GetValue(), 1, 2000))
            chat.AddText('Записка не может превышать 2000 символов.')
        end
    end

    local btn = vgui.Create('DButton', panel)
    btn:SetTall(30)
    btn:Dock(BOTTOM)
    btn:DockMargin(0, 5, 0, 0)
    btn:SetText('Принять')
    btn.DoClick = function()
        surface.PlaySound('buttons/blip1.wav')
        self:SaveNote()
        self.menu:Close()
    end

    self.menu.OnClose = function()
        gui.EnableScreenClicker(false)
        self.MouseHasControl = false
        self:SaveNote()
    end

    net.Start("NotepadRequestData")
    net.SendToServer()

    net.Receive("NotepadRequestData", function()
        local data = net.ReadString()
        if IsValid(self.txt) then
            self.txt:SetText(data)
        end
    end)
end

function SWEP:SaveNote()
    if not IsValid(self.txt) then return end
    local text = self.txt:GetValue()
    net.Start("NotepadSaveData")
    net.WriteString(text)
    net.SendToServer()
end

function SWEP:PrimaryAttack()
    self:CreateMenu()
end

function SWEP:SecondaryAttack()
end