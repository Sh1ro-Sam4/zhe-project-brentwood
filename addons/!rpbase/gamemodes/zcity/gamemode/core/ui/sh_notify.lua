if SERVER then
	AddCSLuaFile()

    function notif(ply, text, type)
        if not type then
            type = NOTIFY_GENERIC
        end
        if not dur then
            dur = 4
        end
		if ply == nil then
			for _, pl in player.Iterator() do
				pl:SSendLua(("shizlib.notify.Create('%s', %s, %s)"):format(text, type, dur))
			end
		else
        	ply:SSendLua(("shizlib.notify.Create('%s', %s, %s)"):format(text, type, dur))
		end
    end

	function DarkRP.notify(ply, type, dur, text)
		if not type then
            type = NOTIFY_GENERIC
        end
        if not dur then
            dur = 4
        end
        if ply == nil then
			for _, pl in player.Iterator() do
				pl:SSendLua(("shizlib.notify.Create('%s', %s, %s)"):format(text, type, dur))
			end
		else
        	ply:SSendLua(("shizlib.notify.Create('%s', %s, %s)"):format(text, type, dur))
		end
	end

    shizlib.notify = shizlib.notify or {}
    function shizlib.notify.Send(ply, text, type, dur)
        if not type then
            type = NOTIFY_GENERIC
        end
        if not dur then
            dur = 4
        end
        ply:SSendLua(("shizlib.notify.Create('%s', %s, %s)"):format(text, type, dur))
    end
end

if SERVER then
    function PLAYER:SSendLua(code)
        netstream.Start(self, "client_code", {string = code})
    end
else
    netstream.Hook("client_code", function(data)
        RunString(data.string and data.string or "")
    end)
end

if SERVER then return end

local RNDX = include("shizlib/client/rndx_cl.lua")

NOTIFY_GENERIC	= 0
NOTIFY_ERROR	= 1
NOTIFY_UNDO		= 2
NOTIFY_HINT		= 3
NOTIFY_CLEANUP	= 4

if shizlib.notify and shizlib.notify.Cache then
	for _, pnl in ipairs(shizlib.notify.Cache) do
		pnl:Remove()
	end
end

shizlib.notify = {}
shizlib.notify.Cache = {}
shizlib.notify.CacheNotify = {}

shizlib.notify.Materials = {}
shizlib.notify.Materials[NOTIFY_GENERIC]	= Material( "vgui/notices/generic" )
shizlib.notify.Materials[NOTIFY_ERROR]		= Material( "vgui/notices/error" )
shizlib.notify.Materials[NOTIFY_UNDO]		= Material( "vgui/notices/undo" )
shizlib.notify.Materials[NOTIFY_HINT]		= Material( "vgui/notices/hint" )
shizlib.notify.Materials[NOTIFY_CLEANUP]	= Material( "vgui/notices/cleanup" )

shizlib.notify.Create = function(text, type, time)
    if not type then
        type = NOTIFY_GENERIC
    end
    if not time then
        time = 8
    end
    local pnl = vgui.Create("SNoticePanel")
    pnl.StartTime = SysTime()
    pnl.Length = math.max( time, 0 )
    pnl.VelX = -5
    pnl.VelY = 0
    pnl.fx = -200
    pnl.fy = shizlib.hud.ScrH
    pnl.Text = text
	pnl:SetAlpha( 255 )
	pnl:SetText( text )
	pnl:SetLegacyType( type )
    pnl:SetPos(pnl.fx, pnl.fy)
    
	shizlib.notify.CacheNotify[text] = CurTime() + time
    table.insert(shizlib.notify.Cache, pnl)

	return pnl
end

local function UpdateNotice( pnl, total_h )

	local x = pnl.fx
	local y = pnl.fy

	local w = pnl:GetWide() + 16
	local h = pnl:GetTall() + 4

	local ideal_y = 20 + h + total_h
	local ideal_x = 5

	local timeleft = pnl.StartTime - ( SysTime() - pnl.Length )
	if ( pnl.Length < 0 ) then timeleft = 1 end

	if ( timeleft < 0.7 ) then
		ideal_x = ideal_x - 50
	end

	if ( timeleft < 0.2 ) then
		ideal_x = ideal_x + w * 2
	end

	local spd = RealFrameTime() * 15

	y = y + pnl.VelY * spd
	x = x + pnl.VelX * spd

	local dist = ideal_y - y
	pnl.VelY = pnl.VelY + dist * spd * 1
	if ( math.abs( dist ) < 2 && math.abs( pnl.VelY ) < 0.1 ) then pnl.VelY = 0 end
	dist = ideal_x - x
	pnl.VelX = pnl.VelX + dist * spd * 1
	if ( math.abs( dist ) < 2 && math.abs( pnl.VelX ) < 0.1 ) then pnl.VelX = 0 end

	pnl.VelX = pnl.VelX * ( 0.95 - RealFrameTime() * 8 )
	pnl.VelY = pnl.VelY * ( 0.95 - RealFrameTime() * 8 )

	pnl.fx = x
	pnl.fy = y

	if ( ideal_y > -ScrH() ) then
		pnl:SetPos( pnl.fx, pnl.fy )
	end

	return total_h + h

end

local function Update()

	if ( !shizlib.notify.Cache ) then return end

	local h = 0
	for key, pnl in pairs( shizlib.notify.Cache ) do

		h = UpdateNotice( pnl, h )

	end

	for k, Panel in pairs( shizlib.notify.Cache ) do

		if ( !IsValid( Panel ) || Panel:KillSelf() ) then shizlib.notify.Cache[ k ] = nil end

	end

end

hook.Add( "Think", "shizlib_sub_notification", Update )

local PANEL = {}

function PANEL:Init()

	self:DockPadding( 3, 3, 3, 3 )

	self.Label = vgui.Create( "DLabel", self )
	self.Label:Dock( FILL )
	self.Label:SetFont( "font.18" )
	self.Label:SetTextColor( color_white )
	self.Label:SetExpensiveShadow( 1, Color( 0, 0, 0, 200 ) )
	self.Label:SetContentAlignment( 5 )

	self:SetBackgroundColor( Color( 20, 20, 20, 150 ) )

end

function PANEL:SetText( txt )

	self.Label:SetText( txt )
	self:SizeToContents()

end

function PANEL:SizeToContents()

	self.Label:SizeToContents()

	local width, tall = self.Label:GetSize()

	tall = math.max( tall, 32 ) + 6
	width = width + 20

	if ( IsValid( self.Image ) ) then
		width = width + 32 + 8

		local x = ( tall - 36 ) / 2
		self.Image:DockMargin( 0, x, 0, x )
	end

	if ( self.Progress ) then
		tall = tall + 10
		self.Label:DockMargin( 0, 0, 0, 10 )
	end

	self:SetSize( width, tall )

	self:InvalidateLayout()

end

function PANEL:SetLegacyType( t )

	self:SizeToContents()

end

function PANEL:Paint( w, h )

	local shouldDraw = !( LocalPlayer && IsValid( LocalPlayer() ) && IsValid( LocalPlayer():GetActiveWeapon() ) && LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera" )

	if ( IsValid( self.Label ) ) then self.Label:SetVisible( shouldDraw ) end
	if ( IsValid( self.Image ) ) then self.Image:SetVisible( shouldDraw ) end

	if ( !shouldDraw ) then return end

	RNDX.Draw(16, 0, 0, w, h, Color(22, 22, 22, 220), RNDX.SHAPE_FIGMA)
	RNDX.Draw(16, 0, 0, w, h, nil, RNDX.BLUR + RNDX.SHAPE_FIGMA)


	if self.Length and self.Length > 0 then
		local elapsed = SysTime() - (self.StartTime or 0)
		local frac = math.Clamp(1 - (elapsed / self.Length), 0, 1)
		local barH = 3
		local barY = h - barH - 6
		local bgW = w - 12
		local fgW = math.max(2, math.Round(bgW * frac))
		RNDX.Draw(3, 6, barY, bgW, barH, Color(30, 30, 30, 180), RNDX.SHAPE_FIGMA)
		RNDX.Draw(3, 6, barY, fgW, barH, Color(255,77,119,220), RNDX.SHAPE_FIGMA)
	end

	if ( !self.Progress ) then return end

	local boxX, boxY = 10, self:GetTall() - 13
	local boxW, boxH = self:GetWide() - 20, 5
	local boxInnerW = boxW - 2

    surface.SetDrawColor( 0, 100, 0, 150 )
	surface.DrawRect( boxX, boxY, boxW, boxH )

	surface.SetDrawColor( 0, 50, 0, 255 )
	surface.DrawRect( boxX + 1, boxY + 1, boxW - 2, boxH - 2 )

	local w = math.ceil( boxInnerW * 0.25 )
	local x = math.fmod( math.floor( SysTime() * 200 ), boxInnerW + w ) - w

	if ( self.ProgressFrac ) then
		x = 0
		w = math.ceil( boxInnerW * self.ProgressFrac )
	end

	if ( x + w > boxInnerW ) then w = math.ceil( boxInnerW - x ) end
	if ( x < 0 ) then
		w = w + x
		x = 0
	end

	surface.SetDrawColor( 0, 255, 0, 255 )
	surface.DrawRect( boxX + 1 + x, boxY + 1, w, boxH - 2 )

end

function PANEL:SetProgress( frac )

	self.Progress = true
	self.ProgressFrac = frac

	self:SizeToContents()

end

function PANEL:KillSelf()

	if ( self.Length < 0 ) then return false end

	if ( self.StartTime + self.Length < SysTime() ) then

		self:Remove()
		return true

	end

	return false

end

vgui.Register( "SNoticePanel", PANEL, "DPanel" )

net.Receive('NotifSystem', function()
	local message = net.ReadString()
	local status = net.ReadString()

	notif(message, status)
end)

hook.Add('ShutDown', 'NotifLib_ClearCache', function()
	cachedLines = {}
	cachedFontHeights = {}
end)