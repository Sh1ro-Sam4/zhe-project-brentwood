local PLAYER = FindMetaTable('Player')
function PLAYER:HasPremium()
    if self:SteamID64() == GetGlobalString("OnyxTop1Donator_Day", "") then
		return true
	end
    return self:GetNWInt("premium", 0) > os.time()
end

local s, DTR = shizlib.surface.s, shizlib.surface.DTR
local RNDX = include("shizlib/client/rndx_cl.lua")
local mat1 = Material("rpui/check.png", "smooth mips")
local theme = CFG.theme
local otrub_surredent_pnl = nil

netstream.Hook("otrbu_surredent", function()
    local client = LocalPlayer()
    -- if not client:IsSuperAdmin() then return end

    if IsValid(otrub_surredent_pnl) then otrub_surredent_pnl:Remove() end
    otrub_surredent_pnl = vgui.Create("EditablePanel")
    otrub_surredent_pnl:SetPos(0, 0)
    otrub_surredent_pnl:SetSize(shizlib.hud.ScrW, shizlib.hud.ScrH)
    otrub_surredent_pnl.Think = function(self)
        if not client:Alive() then self:Remove() return end 
        local org = client.organism
        if not org.otrub then self:Remove() return end
    end
    local pnl = otrub_surredent_pnl

    pnl.SurredentBtn = pnl:Add("DButton")
    pnl.SurredentBtn:SetSize( s(300), s(60) )
    pnl.SurredentBtn:SetText("")
    pnl.SurredentBtn.PerformLayout = function(self)
        self:SetPos( (shizlib.hud.ScrW * .5) - (self:GetWide() * .5), (shizlib.hud.ScrH * .8) - (self:GetTall() * .5) )
    end
    pnl.SurredentBtn.Paint = function(self, w, h)
        local isHovered = self:IsHovered()
        local firstColor = isHovered and color_black or color_white
        local secondColor = isHovered and color_white or Color(32,32,32)

        RNDX.Draw(8,0,0,w,h,secondColor)

        -- RNDX.Draw(4,s(10),s(10),s(40),s(40),Color(24,24,24))
        -- surface.SetMaterial(mat1)
        -- surface.SetDrawColor(255,255,255)
        -- surface.DrawTexturedRect(s(24),s(26),s(12),s(12))

        draw.SimpleText('Сдаться','IB_20',w/2,h/2,firstColor,1,1)
    end
    pnl.SurredentBtn.DoClick = function()
        netstream.Start("otrbu_surredent")
    end
    pnl.SurredentBtn.DoRightClick = pnl.SurredentBtn.DoClick
end)