--[[---------------------------------------------------------------------------
This is an example of a custom entity.
---------------------------------------------------------------------------]]
include("shared.lua")

surface.CreateFont( "DispenserZavod", {
	font = "Roboto Light", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 25,
	weight = 500,
	extended = true
} )

function ENT:Initialize()
end

function ENT:Draw()
	self:DrawModel()

	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	Ang:RotateAroundAxis(Ang:Forward(), 90)
	Ang:RotateAroundAxis(Ang:Right(), -90)

	cam.Start3D2D(Pos + Ang:Up() * 4.6, Ang, 0.11)
	--	draw.WordBox(2, -TextWidth2*0.5, 18, owner, "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255))
	cam.End3D2D()
end

function ENT:Think()
end

function RationMenu()
	local RNDX = include("shizlib/client/rndx_cl.lua")
    local int = 0
    local base = vgui.Create("DLabel")
    base:SetSize(ScrW(), ScrH())
    base:SetPos(0, 0)
    base:SetAlpha(0)
    base:AlphaTo(255, 0.3, 0)
    base:MakePopup()
    base:SetText("")

    function base:Paint()
        RNDX.Draw(0, 0, 0, self:GetWide(), self:GetTall(), nil, RNDX.BLUR)
        RNDX.Draw(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 200))
    end

    local can = vgui.Create("DButton", base)
    can:SetSize(128, 128)
    can:SetText("")
    can:SetPos(ScrW() / 2 + 256, ScrH() / 2 - 128)

    function can:Paint(w, h)
        shizlib.surface.DTR(0, 0, w, h, Color(255, 255, 255), "shizlib/icon17/256/bottle.png")
    end

    function can:DoClick()
        can:MoveTo(ScrW() / 2 - 56, ScrH() / 2 - 56, 0.3, 0)

        timer.Simple(0.15, function() int = int + 1
            surface.PlaySound("physics/plastic/plastic_barrel_impact_soft" .. math.random(1, 3) .. ".wav")
        end)

        timer.Simple(0.3, function() can:Remove() end)
    end

    local can = vgui.Create("DButton", base)
    can:SetSize(128, 128)
    can:SetText("")
    can:SetPos(ScrW() / 2 + 256, ScrH() / 2)

    function can:Paint(w, h)
        shizlib.surface.DTR(0, 0, w, h, Color(255, 255, 255), "shizlib/icon17/256/bottle.png")
    end

    function can:DoClick()
        can:MoveTo(ScrW() / 2 - 56, ScrH() / 2 - 56, 0.3, 0)

        timer.Simple(0.15, function() int = int + 1
            surface.PlaySound("physics/plastic/plastic_barrel_impact_soft" .. math.random(1, 3) .. ".wav")
        end)

        timer.Simple(0.3, function() can:Remove() end)
    end

    local food = vgui.Create("DButton", base)
    food:SetSize(256, 256)
    food:SetText("")
    food:SetPos(ScrW() / 2 - 256 - 256, ScrH() / 2 - 128)

    function food:Paint(w, h)
        shizlib.surface.DTR(0, 0, w, h, Color(255, 255, 255), "shizlib/icon17/256/flesh.png")
    end

    function food:DoClick()
        food:MoveTo(ScrW() / 2 - 128, ScrH() / 2 - 128, 0.3, 0)

        timer.Simple(0.15, function() int = int + 1
            surface.PlaySound("physics/plastic/plastic_barrel_impact_soft" .. math.random(1, 3) .. ".wav")
        end)

        timer.Simple(0.3, function() food:Remove() end)
    end

    local label = vgui.Create("DLabel", base)
    label:SetSize(512, 512)
    label:SetText("")
    label:Center()

    function label:Paint(w, h)
        shizlib.surface.DTR(0, 0, w, h, Color(255, 255, 255), "shizlib/icon17/256/can.png")
    end

    function label:Think()
        if int == 3 then int = 4
            surface.PlaySound("buttons/bell1.wav")
            label:SizeTo(400, 400, 0.3, 0)
            label:MoveTo(ScrW() / 2 - 200, ScrH() / 2 - 200, 0.3, 0)
            base:AlphaTo(0, 0.3, 0)

            timer.Simple(0.3, function() base:Remove() end)

            net.Start("rationSuccess")
            net.SendToServer(LocalPlayer())
        end
    end
end
