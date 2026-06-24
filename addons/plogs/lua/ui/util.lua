
-----------------------------------------------------
surface.CreateFont('ui.40', {font = 'roboto', size = 40, weight = 500})
surface.CreateFont('ui.39', {font = 'roboto', size = 39, weight = 500})
surface.CreateFont('ui.38', {font = 'roboto', size = 38, weight = 500})
surface.CreateFont('ui.37', {font = 'roboto', size = 37, weight = 500})
surface.CreateFont('ui.36', {font = 'roboto', size = 36, weight = 500})
surface.CreateFont('ui.35', {font = 'roboto', size = 35, weight = 500})
surface.CreateFont('ui.34', {font = 'roboto', size = 34, weight = 500})
surface.CreateFont('ui.33', {font = 'roboto', size = 33, weight = 500})
surface.CreateFont('ui.32', {font = 'roboto', size = 32, weight = 500})
surface.CreateFont('ui.31', {font = 'roboto', size = 31, weight = 500})
surface.CreateFont('ui.30', {font = 'roboto', size = 30, weight = 500})
surface.CreateFont('ui.29', {font = 'roboto', size = 29, weight = 500})
surface.CreateFont('ui.28', {font = 'roboto', size = 28, weight = 500})
surface.CreateFont('ui.27', {font = 'roboto', size = 27, weight = 400})
surface.CreateFont('ui.26', {font = 'roboto', size = 26, weight = 400})
surface.CreateFont('ui.25', {font = 'roboto', size = 25, weight = 400})
surface.CreateFont('ui.24', {font = 'roboto', size = 24, weight = 400})
surface.CreateFont('ui.23', {font = 'roboto', size = 23, weight = 400})
surface.CreateFont('ui.22', {font = 'roboto', size = 22, weight = 400})
surface.CreateFont('ui.20', {font = 'roboto', size = 20, weight = 400})
surface.CreateFont('ui.19', {font = 'roboto', size = 19, weight = 400})
surface.CreateFont('ui.18', {font = 'roboto', size = 18, weight = 400})
surface.CreateFont('ui.17', {font = 'roboto', size = 15, weight = 550})
surface.CreateFont('ui.15', {font = 'roboto', size = 15, weight = 550})

local surface_SetDrawColor 	= surface.SetDrawColor
local surface_SetMaterial 	= surface.SetMaterial
local surface_DrawRect 		= surface.DrawRect
local surface_DrawTexturedRect = surface.DrawTexturedRect
local render_UpdateScreenEffectTexture = render.UpdateScreenEffectTexture
local ScrW = ScrW
local ScrH = ScrH

local function DrawRect(x, y, w, h, t)
	if not t then t = 1 end
	surface_DrawRect(x, y, w, t)
	surface_DrawRect(x, y + (h - t), w, t)
	surface_DrawRect(x, y, t, h)
	surface_DrawRect(x + (w - t), y, t, h)
end

function draw.Box(x, y, w, h, col)
	surface_SetDrawColor(col)
	surface_DrawRect(x, y, w, h)
end

function draw.Outline(x, y, w, h, col, thickness)
	surface_SetDrawColor(col)
	DrawRect(x, y, w, h, thickness)
end

function draw.OutlinedBox(x, y, w, h, col, bordercol, thickness)
	surface_SetDrawColor(col)
	surface_DrawRect(x + 1, y + 1, w - 1, h - 1)

	surface_SetDrawColor(bordercol)
	DrawRect(x, y, w, h, thickness)
end
--[[
local blur = Material('pp/blurscreen')
function draw.Blur(panel, amount) -- Thanks nutscript
	local x, y = panel:LocalToScreen(0, 0)
	local scrW, scrH = ScrW(), ScrH()
	surface_SetDrawColor(255, 255, 255)
	surface_SetMaterial(blur)
	for i = 1, 3 do
		blur:SetFloat('$blur', (i / 3) * (amount or 6))
		blur:Recompute()
		render_UpdateScreenEffectTexture()
		surface_DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end
--]]
local vguiFucs = {
	['DTextEntry'] = function(self, p)
		self:SetFont('ui.20')
	end,	
	['DLabel'] = function(self, p)
		self:SetFont('ui.22')
		self:SetColor(ui.col.White)
	end,
	['DButton'] = function(self, p)
		self:SetFont('ui.20')
	end,
	['DComboBox'] = function(self, p)
		self:SetFont('ui.22')
	end,
}

timer.Simple(0, function()
	vgui.GetControlTable('DButton').SetBackgroundColor = function(self, color)
		self.BackgroundColor = color
	end
end)

function ui.Create(t, f, p)
	local parent
	if (not isfunction(f)) and (f ~= nil) then
		parent = f
	elseif not isfunction(p) and (p ~= nil) then
		parent = p
	end

	local v = vgui.Create(t, parent)
	v:SetSkin('SUP')

	if vguiFucs[t] then vguiFucs[t](v, parent) end

	if isfunction(f) then f(v, parent) elseif isfunction(p) then p(v, f) end

	return v
end

function ui.Label(txt, font, x, y, parent)
	return ui.Create('DLabel', function(self, p)
		self:SetText(txt)
		self:SetFont(font)
		self:SetTextColor(ui.col.White)
		self:SetPos(x, y)
		self:SizeToContents()
		self:SetWrap(true)
		self:SetAutoStretchVertical(true)
	end, parent)
end

function ui.DermaMenu(p)
	local m = DermaMenu(p)
	m:SetSkin('SUP')
	return m
end

function ui.OpenURL(url, title)
	local w, h = ScrW() * .9, ScrH() * .9

	local fr = ui.Create('ui_frame', function(self)
		self:SetSize(w, h)
		self:SetTitle(url)
		self:Center()
		self:MakePopup()
	end)

	ui.Create('HTML', function(self)
		self:SetPos(5, 32)
		self:SetSize(w - 10, h - 37)
		self:OpenURL(url)
	end, fr)

	return fr
end