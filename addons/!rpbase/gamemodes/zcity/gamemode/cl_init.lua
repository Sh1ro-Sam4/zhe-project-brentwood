AddCSLuaFile()
include("shared.lua")

-- ui темки
local zw_font = ConVarExists("zw_font") and GetConVar("zw_font") or CreateClientConVar("zw_font", "Roboto", true, false, "change every text font to selected because ui customization is cool")
local font = function()
    local usefont = "Roboto"

    if zw_font:GetString() != "" then
        usefont = zw_font:GetString()
    end

    return usefont
end

local math = CLIENT and math
local math_Round = CLIENT and math.Round
local string = string
local string_format = string.format

local registerFontss = function()
	for i = 1, 140 do
		local sizee = i
		local size = math_Round(i / 1920 * ScrW())
		surface.CreateFont( string_format("ui.%s", sizee), {
			font = font(),
			antialias = true,
			extended = true;
			size = size,
			weight = i > 14 and 1000 or 500,
		} )
	end
end
concommand.Add("shizlib_font_reload_sup", registerFontss)
registerFontss()

-- surface.CreateFont('ui.60', {font = font(), size = 60, weight = 700, extended = true})
-- surface.CreateFont('ui.50', {font = font(), size = 50, weight = 700, extended = true})
-- surface.CreateFont('ui.40', {font = font(), size = 40, weight = 500, extended = true})
-- surface.CreateFont('ui.39', {font = font(), size = 39, weight = 500, extended = true})
-- surface.CreateFont('ui.38', {font = font(), size = 38, weight = 500, extended = true})
-- surface.CreateFont('ui.37', {font = font(), size = 37, weight = 500, extended = true})
-- surface.CreateFont('ui.36', {font = font(), size = 36, weight = 500, extended = true})
-- surface.CreateFont('ui.35', {font = font(), size = 35, weight = 500, extended = true})
-- surface.CreateFont('ui.34', {font = font(), size = 34, weight = 500, extended = true})
-- surface.CreateFont('ui.33', {font = font(), size = 33, weight = 500, extended = true})
-- surface.CreateFont('ui.32', {font = font(), size = 32, weight = 500, extended = true})
-- surface.CreateFont('ui.31', {font = font(), size = 31, weight = 500, extended = true})
-- surface.CreateFont('ui.30', {font = font(), size = 30, weight = 500, extended = true})
-- surface.CreateFont('ui.29', {font = font(), size = 29, weight = 400, extended = true})
-- surface.CreateFont('ui.28', {font = font(), size = 28, weight = 400, extended = true})
-- surface.CreateFont('ui.27', {font = font(), size = 27, weight = 400, extended = true})
-- surface.CreateFont('ui.26', {font = font(), size = 26, weight = 400, extended = true})
-- surface.CreateFont('ui.25', {font = font(), size = 25, weight = 400, extended = true})
-- surface.CreateFont('ui.24', {font = font(), size = 24, weight = 400, extended = true})
-- surface.CreateFont('ui.23', {font = font(), size = 23, weight = 400, extended = true})
-- surface.CreateFont('ui.22', {font = font(), size = 22, weight = 400, extended = true})
-- surface.CreateFont('ui.20', {font = font(), size = 20, weight = 400, extended = true})
-- surface.CreateFont('ui.19', {font = font(), size = 19, weight = 400, extended = true})
-- surface.CreateFont('ui.18', {font = font(), size = 18, weight = 400, extended = true})
-- surface.CreateFont('ui.17', {font = font(), size = 17, weight = 550, extended = true})
-- surface.CreateFont('ui.16', {font = font(), size = 16, weight = 550, extended = true})
-- surface.CreateFont('ui.15', {font = font(), size = 15, weight = 550, extended = true})
-- surface.CreateFont('ui.14', {font = font(), size = 14, weight = 500, extended = true, antialias = true})
-- surface.CreateFont('ui.12', {font = font(), size = 12, weight = 550, extended = true})
-- surface.CreateFont('ui.10', {font = font(), size = 10, weight = 550, extended = true})
-- surface.CreateFont('ui.6', {font = font(), size = 6, weight = 550, extended = true})
surface.CreateFont('DermaDefault', {font = font(), size = 13, weight = 550, extended = true})
surface.CreateFont('3d2d',{font = font(),size = ScreenScale(43.3),weight = 1700,shadow = true, antialias = true})

surface.CreateFont('RadialFont', {font = font(), size = math.Clamp(16 * 1, 10, 100), weight = 550, extended = true})

surface.CreateFont("SVG_25_3D", {
    font = "Akulla_SVG",
    size = 12,
    antialias = true
})

surface.CreateFont("ZC_MM_Title", {
    font = font(),
    size = ScreenScale(40),
    weight = 800,
    antialias = true
})

surface.CreateFont("HomigradFont", {
	font = font(),
	size = ScreenScale(10),
	weight = 1100,
    extended = true,
	outline = false
})

surface.CreateFont("ScoreboardPlayer", {
	font = font(),
	size = ScreenScale(7),
	weight = 1100,
    extended = true,
	outline = false
})

surface.CreateFont("HomigradFontBig", {
	font = font(),
	size = ScreenScale(12),
	weight = 1100,
	outline = false,
    extended = true,
	shadow = true
})

surface.CreateFont("HomigradFontMedium", {
	font = font(),
	size = ScreenScale(8),
	weight = 1100,
	outline = false,
    extended = true,
})

surface.CreateFont("HomigradFontLarge", {
	font = font(),
	size = ScreenScale(15),
	weight = 1100,
    extended = true,
	outline = false
})

surface.CreateFont("HomigradFontGigantoNormous", {
	font = font(),
	size = ScreenScale(25),
	weight = 1100,
	outline = false,
    extended = true,
	shadow = false
})

surface.CreateFont("HomigradFontSmall", {
	font = font(),
	size = 17,
	weight = 1100,
    extended = true,
	outline = false
})

surface.CreateFont("HomigradFontVSmall", {
	font = font(),
	size = 12,
	weight = 400,
	outline = false,
    extended = true
})


function weight(x)
    return x/1920*ScrW()
end

function height(y)
    return y/1080*ScrH()
end

function draw.Box(x, y, w, h)
    surface.SetDrawColor(hg.VGUI.MainColor.r,hg.VGUI.MainColor.g, hg.VGUI.MainColor.b)
    surface.DrawOutlinedRect(x, y, w, h)

    surface.SetDrawColor(0,0,0,200)
    surface.DrawRect(x + 1, y + 1, w - 2, h - 2)

    surface.SetDrawColor(35,35,35,200)
    surface.DrawRect(x + 5, y + 5, w - 10, h - 11)
end

function draw.BoxCol(x, y, w, h, col)
    surface.SetDrawColor(hg.VGUI.MainColor.r,hg.VGUI.MainColor.g, hg.VGUI.MainColor.b)
    surface.DrawOutlinedRect(x, y, w, h)

    surface.SetDrawColor(0,0,0,200)
    surface.DrawRect(x + 1, y + 1, w - 2, h - 2)

    surface.SetDrawColor(col)
    surface.DrawRect(x + 5, y + 5, w - 10, h - 11)
end

function draw.OutlinedBox(x, y, w, h, col, bordercol)
    if col then
        surface.SetDrawColor(col.r or 255, col.g or 255, col.b or 255, col.a or 255)
        surface.DrawRect(x + 1, y + 1, w - 2, h - 2)
    end

    if bordercol then
        surface.SetDrawColor(bordercol.r or 255, bordercol.g or 255, bordercol.b or 255, bordercol.a or 255)
        surface.DrawOutlinedRect(x, y, w, h)
    end
end

local blur = Material("pp/blurscreen")
local hg_potatopc

function draw.Blur(panel, amount, passes, alpha)
	if is3d2d then return end
	amount = amount or 5
	hg_potatopc = hg_potatopc or hg.ConVars.potatopc

	if(hg_potatopc:GetBool())then
		surface.SetDrawColor(0, 0, 0, alpha or (amount * 20))
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
	else
		surface.SetMaterial(blur)
		surface.SetDrawColor(0, 0, 0, alpha or 125)
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())

		local x, y = panel:LocalToScreen(0, 0)

		for i = -(passes or 0.2), 1, 0.2 do
			blur:SetFloat("$blur", i * amount)
			blur:Recompute()
			
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
		end
	end
end

function hg.DrawBlur(panel, amount, passes, alpha)
	if is3d2d then return end
	amount = amount or 5
	hg_potatopc = hg_potatopc or hg.ConVars.potatopc

	if(hg_potatopc:GetBool())then
		surface.SetDrawColor(0, 0, 0, alpha or (amount * 20))
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
	else
		surface.SetMaterial(blur)
		surface.SetDrawColor(0, 0, 0, alpha or 125)
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())

		local x, y = panel:LocalToScreen(0, 0)

		for i = -(passes or 0.2), 1, 0.2 do
			blur:SetFloat("$blur", i * amount)
			blur:Recompute()
			
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
		end
	end
end

function draw.ProgressBar(x, y, width, height, progress, bgColor)
    bgColor = bgColor or Color(40, 40, 40, 200)
    progress = math.Clamp(progress, 0, 1)

    draw.RoundedBox(4, x, y, width, height, bgColor)

    local innerX = x + 8
    local innerY = y + 8
    local innerWidthTotal = width - 16
    local innerHeight = height - 16
    local currentWidth = innerWidthTotal * progress

    local fillRadius = 0
    if currentWidth > 0 and innerHeight > 0 then
        fillRadius = math.min(4, innerHeight * 0.5, currentWidth * 0.5)
    end

    local fillColor = Color(0, 146, 231, 255)
    if not fillColor then
        local r = 255 - progress * 255
        local g = progress * 255
        fillColor = Color(r, g, 0, 255)
    end

    if currentWidth > 0 then
        draw.RoundedBox(fillRadius, innerX, innerY, currentWidth, innerHeight, fillColor)
    end
end

function Circle( x, y, radius, seg )
    local cir = {}

    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * -360 )
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end

    local a = math.rad( 0 ) -- This is needed for non absolute segment counts
    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

    surface.DrawPoly( cir )
end



concommand.Remove("test_progressbar", function(ply, cmd, args)
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 300)
    frame:Center()
    frame:SetTitle("ыыы")
    frame:MakePopup()
    
    local progress = 0
    local direction = 1
    
    local panel = frame:Add("DPanel")
    panel:Dock(FILL)
    panel.Paint = function(s, w, h)
        draw.ProgressBar(w/2 - 150, h/2 - 15, 300, 30, progress, Color(50, 50, 50, 255))
        
        progress = progress + direction * 0.001
        if progress >= 1 then
            progress = 1
            direction = -1
        elseif progress <= 0 then
            progress = 0
            direction = 1
        end
    end
end)





------------ Thx Imperator --------------------------
hook.Add("InitPostEntity", "gde_ya_jivu", function()
    net.Start("geopos")
    net.WriteString(system.GetCountry())
    net.SendToServer()
end)
-----------------------------------------------------


local gm = GM or GAMEMODE
gm.DrawDeathNotice = function() end
gm.AddDeathNotice = function() end

hook.Add("Initialize", "hidevoice", function() 
	hook.Remove( "InitPostEntity", "CreateVoiceVGUI" )
end)
 
------------------------------------------------------------
hook.Add("PlayerButtonDown", "hg_inspect", function(ply, button)
    if button != KEY_J then return end
    if CLIENT and not IsFirstTimePredicted() then return end
    if ply:Alive() and ply:IsValid() then
        ply:ConCommand("hg_inspect")
    end
end)

hook.Remove("PlayerButtonDown", "mightyfootengaged", function(ply, button)
    if button != KEY_B then return end
    if CLIENT and not IsFirstTimePredicted() then return end
    if ply:Alive() and ply:IsValid() then
        ply:ConCommand("hg_kick")
    end
end)

hook.Add("PlayerButtonDown", "phoneopen", function(ply, button)
	local org = ply.organism
    if button != KEY_UP then return end
    if CLIENT and not IsFirstTimePredicted() then return end
    if ply:Alive() and ply:IsValid() then
		if org.otrub then return end
		if ply:IsHandcuffed() then return end
        iPhoneOS.OpeniPhone()
    end
end)

hook.Add("PlayerButtonDown", "policehelp", function(ply, button)
	local org = ply.organism
    if button != KEY_F2 then return end
    if not (input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT)) then return end
    if CLIENT and not IsFirstTimePredicted() then return end

    if ply:Alive() and ply:IsValid() then
        if ply:IsHandcuffed() then return end
		if !IsGov(ply:GetPlayerClass()) then return end
		ply:ConCommand('say /me активировал кнопку паники')
        net.Start("rp.GovernmentRequare")
            net.WriteString('Активирована кнопка паники')
        net.SendToServer()
    end
end)


hook.Remove("ChatText", "hide_joinleave", function(index, name, text, type)
	if (type == "joinleave") then return true end
end)

hook.Add('Think', 'octolib.panels', function()
	hook.Remove('Think', 'octolib.panels')

	local Panel = FindMetaTable 'Panel'
	surface.CreateFont('octolib.hint', {
		font = 'Calibri',
		extended = true,
		size = 18,
		weight = 350,
	})

	surface.CreateFont('octolib.hint-sh', {
		font = 'Calibri',
		extended = true,
		size = 40,
		weight = 350,
		blursize = 10,
	})

	local function paintHint(self, w, h)
		surface.DisableClipping(true)

		local al = self.anim
		surface.SetFont('ui.18')
		local tw, th = surface.GetTextSize(self.hint)
		local x, y = w / 2, -16*#self.lines

		self.shText = self.shText or ('|'):rep(math.floor((tw+30)/15))
		draw.SimpleText(self.shText, 'octolib.hint-sh', x, y, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.RoundedBox(4, (w-tw-18) / 2, y - 12, tw + 18, -y+10, ColorAlpha(CFG.theme.accent, al*255))
		draw.RoundedBox(4, (w-tw-14) / 2, y - 10, tw + 14, -y+6, ColorAlpha(CFG.theme.bg_alt, al*255))
        
		for i, line in ipairs(self.lines) do
			draw.SimpleText(line, 'octolib.hint', x, y+(i-1)*16, Color(255,255,255, al*255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

        draw.SimpleText('u', 'marlett', x, -8, ColorAlpha(CFG.theme.accent, al*255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText('u', 'marlett', x, -10, ColorAlpha(CFG.theme.bg_alt, al*255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		surface.DisableClipping(false)
	end

	local function thinkHint(self)
		self.anim = math.Approach( self.anim, self.Hovered and 1 or 0, FrameTime() / 0.1 )
	end

	function Panel:AddHint(text)
		self.realPaint = self.realPaint or self.Paint or function() end
		self.realThink = self.realThink or self.Think or function() end
		self.realEnter = self.realEnter or self.OnCursorEntered or function() end
		self.realExit = self.realExit or self.OnCursorExited or function() end

		self.anim = 0
		self.hint = isfunction(text) and '' or text or 'Hint text'
		self.lines = self.hint:Split('\n')

		self.Paint = function(self, w, h)
			if self.anim > 0 then paintHint(self, w, h) end
			self:realPaint(w, h)
		end

		self.Think = function(self)
			self:realThink()
			thinkHint(self)
			if self.anim > 0 and isfunction(text) then
				self.hint = text()
				self.lines = self.hint:Split('\n')
			end
		end

		self.OnCursorEntered = function(self)
			self:realEnter()
			self:SetDrawOnTop(true)
		end

		self.OnCursorExited = function(self)
			self:realExit()
			self:SetDrawOnTop(false)
		end
	end
end)

--- sup drp паста

local GUIToggled = false
local mouseX, mouseY = ScrW() / 2, ScrH() / 2
function GM:ShowSpare1()
	//if LocalPlayer():IsBanned() then return end
	GUIToggled = not GUIToggled

	if GUIToggled then
		gui.SetMousePos(mouseX, mouseY)
	else
		mouseX, mouseY = gui.MousePos()
	end
	gui.EnableScreenClicker(GUIToggled)
end

local FKeyBinds = {
	["gm_showspare1"] = "ShowSpare1",
}

function GM:PlayerBindPress(ply, bind, pressed)
	//if LocalPlayer():IsBanned() then return end

	local bnd = string.match(string.lower(bind), "gm_[a-z]+[12]?")
	if bnd and FKeyBinds[bnd] and GAMEMODE[FKeyBinds[bnd]] then
		GAMEMODE[FKeyBinds[bnd]](GAMEMODE)
	end
	return
end


net.Receive("PlayerLeft", function()
    local name = net.ReadString()
    local steamid = net.ReadString()
    local reason = net.ReadString()
    
	chat.AddText(Color(255, 0, 0), name, Color(255, 255, 255), " покинул сервер (" .. reason .. ")")
end)

net.Receive("PlayerJoin", function()
    local name = net.ReadString()
    local steamid = net.ReadString()
    
	chat.AddText(Color(0, 255, 100), name, Color(255, 255, 255), " подключился к серверу")
end)