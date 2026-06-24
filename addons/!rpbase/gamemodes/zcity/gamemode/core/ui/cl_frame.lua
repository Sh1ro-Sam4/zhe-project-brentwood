--
local s = shizlib.surface.s
local DTR = shizlib.surface.DTR
local RNDX = include("shizlib/client/rndx_cl.lua")
local colors = CFG.theme
----
local PANEL = {}
--[[
hg.VGUI.SecondaryColor = Color(155,0,0,240)
hg.VGUI.BackgroundColor = Color(25,25,35,220)]]
local color_blacky = CFG.theme.bg
local color_reddy = CFG.theme.accent

function PANEL:Init()
    self.Itensens = {}
    self:SetAlpha( 0 )
    self:SetTitle( "" )

    self.DrawBorder = true

    self.ColorBG = Color(color_blacky:Unpack())
    self.ColorBR = Color(color_reddy:Unpack())
    self.BlurStrengh = 2

    timer.Simple(0,function()
        self:First()
    end)
end

function PANEL:Paint(w,h)
    RNDX.Draw(8, 0, 0, w, h, nil, RNDX.BLUR)
    RNDX.Draw(8, 0, 0, w, h, ColorAlpha(colors.bg, 200))
    -- draw.RoundedBox(0,0,0,w,h,self.ColorBG)
    -- draw.Blur(self, self.BlurStrengh)

    -- if self.DrawBorder then
    --     surface.SetDrawColor(self.ColorBR)
    --     surface.DrawOutlinedRect(0,0,w,h,1.5)
    -- end
end

function PANEL:SetBorder( bDraw )
    self.DrawBorder = bDraw
end

function PANEL:SetColorBG( cColor )
    self.ColorBG = cColor
end

function PANEL:SetColorBR( cColor )
    self.ColorBR = cColor
end

function PANEL:SetBlurStrengh( floatVal )
    self.BlurStrengh = floatVal
end

function PANEL:First( ply )
    self:SetY(self:GetY() + self:GetTall())
    self:MoveTo(self:GetX(), self:GetY() - self:GetTall(), 0.4, 0, 0.2, function() end)
    self:AlphaTo( 255, 0.2, 0.1, nil )

    if self.PostInit then
        self:PostInit()
    end
end

function PANEL:Close()
    if self.Closing then return end
    self.Closing = true
    self:MoveTo(self:GetX(), ScrH() / 2 + self:GetTall(), 5, 0, 0.3, function()
    end)
    self:AlphaTo( 0, 0.2, 0, function() 
        if self.OnClose then self:OnClose() end 
        self:Remove() 
    end)
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(false)
end

vgui.Register( "ZFrame", PANEL, "DFrame")

