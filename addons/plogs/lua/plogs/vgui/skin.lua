--[[
addons/lgos/lua/plogs/vgui/skin.lua
--]]
local surface 				= surface
local draw 					= draw

local SKIN 		= {}

SKIN.PrintName 	= 'pLogs'
SKIN.Author 	= 'aStonedPenguin'

if plogs.cfg.DarkUI then
	-- Not finished
	SKIN.Background 			= Color(0,0,0,170)
	SKIN.Header 				= Color(0,0,0,170)
	SKIN.Outline 				= Color(0,0,0,170)

	SKIN.Panel 					= Color(0,0,0,170)

	SKIN.Button 				= Color(0,0,0,170)
	SKIN.ButtonHovered			= Color(50,50,50,170)
	SKIN.ButtonText				= Color(255,255,255)

	SKIN.Close 					= SKIN.ButtonText
	SKIN.CloseHovered 			= Color(255,255,255)

	SKIN.TabButton 				= SKIN.Header

	SKIN.TextEntry 				= SKIN.Button
	SKIN.TextEntryOutline 		= SKIN.Outline
	SKIN.TextEntryText 			= SKIN.ButtonText
	SKIN.TextEntryHighlight 	= Color(152, 25, 29)

	SKIN.ListBackground			= SKIN.TextEntry
	SKIN.ListViewLine 			= SKIN.Button
	SKIN.ListViewLineAlt 		= SKIN.ButtonHovered
	SKIN.ListViewLineHighlight 	= SKIN.TextEntryHighlight
	SKIN.ListViewText			= SKIN.ButtonText

else

	SKIN.Background 			= Color(41,41,41,170)
	SKIN.Header 				= Color(41,41,41,170)
	SKIN.Outline 				= Color(151,151,151,175)

	SKIN.Panel 					= Color(0,0,0,170)

	SKIN.Button 				= Color(41,41,41,170)
	SKIN.ButtonHovered			= Color(151, 151, 151)

	SKIN.Close 					= Color(255,255,255)
	SKIN.CloseHovered 			= Color(152, 25, 29)

	SKIN.TabButton 				= SKIN.Header

	SKIN.TextEntry 				= SKIN.Button
	SKIN.TextEntryOutline 		= SKIN.Outline
	SKIN.TextEntryText 			= Color(255,255,255)
	SKIN.TextEntryHighlight 	= Color(152, 25, 29)

	SKIN.ListBackground			= SKIN.TextEntry
	SKIN.ListViewLine 			= SKIN.Button
	SKIN.ListViewLineAlt 		= Color(75,75,75,170)
	SKIN.ListViewLineHighlight 	= Color(151, 151, 151)
	SKIN.ListViewText			= Color(255,255,255)
	SKIN.ProgressBar 			= Color(151, 151, 151)
end

plogs.ui					= SKIN

----------------------------------------------------------------
-- Frames
----------------------------------------------------------------
function SKIN:PaintFrame(self, w, h)
	--plogs.draw.Blur(self)
	plogs.draw.OutlinedBox(0, 0, w, h, SKIN.Background, SKIN.Outline)
	plogs.draw.OutlinedBox(0, 0, w, 30, SKIN.Header, SKIN.Outline)
end

function SKIN:PaintPanel(self, w, h)
	if not (self.m_bBackground) then return end

	plogs.draw.OutlinedBox(0, 0, w, h, SKIN.Panel, SKIN.Outline)
end

function SKIN:PaintShadow() end

----------------------------------------------------------------
-- Buttons                                                     
----------------------------------------------------------------
function SKIN:PaintButton(self, w, h)
	if not (self.m_bBackground) then return end 

	plogs.draw.OutlinedBox(0, 0, w, h, self.Hovered and SKIN.ButtonHovered or SKIN.Button, SKIN.Outline)

	if not self.fontset then
		self:SetTextColor(SKIN.Close)
		self:SetFont('plogs.ui.20')
		self.fontset = true
	end
end

----------------------------------------------------------------
-- Close Button
----------------------------------------------------------------
function SKIN:PaintWindowCloseButton(panel, w, h)
	if not (panel.m_bBackground) then return end

	draw.SimpleText('x', 'plogs.ui.26', 11, 0, (self.Hovered and SKIN.CloseHovered or SKIN.Close), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) 
end

----------------------------------------------------------------
-- Text Entry                                                 
----------------------------------------------------------------
function SKIN:PaintTextEntry(self, w, h)
	plogs.draw.OutlinedBox(0, 0, w, h, SKIN.TextEntry, SKIN.TextEntryOutline)
	
	self:DrawTextEntryText(SKIN.TextEntryText, SKIN.TextEntryHighlight, SKIN.TextEntryText)
end

----------------------------------------------------------------
-- List View                                                 
----------------------------------------------------------------
function SKIN:PaintListView(self, w, h)
	--plogs.draw.Box(0, 0, w, h, SKIN.ListBackground)
end

function SKIN:PaintListViewLine(self, w, h)
	local col = ((self:IsSelected() or self:IsHovered()) and SKIN.ListViewLineHighlight or SKIN.ListViewLine)

	plogs.draw.Box(0, 0, w, h, ((self.m_bAlt and not (self:IsSelected() or self:IsHovered())) and SKIN.ListViewLineAlt or col))

	for k, v in ipairs(self.Columns) do
		if (self:IsSelected() or self:IsHovered()) then
			
			v:SetFont('plogs.ui.18')
			v:SetTextColor(SKIN.ListViewTextHighlight)
		else
			v:SetFont('plogs.ui.16')
			v:SetTextColor(SKIN.ListViewText)
		end	
	end
end


----------------------------------------------------------------
-- Scrollbar                                                  --
----------------------------------------------------------------
function SKIN:PaintScrollBarGrip(self, w, h)
	plogs.draw.OutlinedBox(0, 0, w, h, self.Hovered and SKIN.ButtonHovered or SKIN.Button, SKIN.Outline)
end
SKIN.PaintButtonDown 	= SKIN.PaintScrollBarGrip
SKIN.PaintButtonUp 		= SKIN.PaintScrollBarGrip

function SKIN:PaintScrollPanel(self, w, h) end
function SKIN:PaintVScrollBar(self, w, h) end

----------------------------------------------------------------
-- Tabs                                                 
----------------------------------------------------------------
/*
function SKIN:PaintTabListPanel(self, w, h)
	surface.SetDrawColor(SKIN.Outline)
	surface.DrawOutlinedRect(0, 0, w, h)
end

SKIN.PaintTabPanel = SKIN.PaintTabListPanel
*/
function SKIN:PaintTabListButton(self, w, h)
	if (self.Active or self.Hovered) then
		plogs.draw.OutlinedBox(0, 0, w, h, SKIN.TabButton, SKIN.Outline)
		if self.Hovered then
			plogs.draw.Box(1, 1, 6, h - 2, SKIN.ProgressBar)
		else
			plogs.draw.Box(1, 1, 3, h - 2, SKIN.ProgressBar)
		end
	else
		plogs.draw.Outline(0, 0, w, h, SKIN.Outline)
	end
	self:SetTextColor(SKIN.Close)
end

----------------------------------------------------------------
-- ComboBox                                                 
----------------------------------------------------------------
function SKIN:PaintComboBox(self, w, h)
	if IsValid(self.Menu) and not self.Menu.SkinSet then
		self.Menu:SetSkin('pLogs')
		self.Menu.SkinSet = true
	end

	plogs.draw.OutlinedBox(0, 0, w, h, ((self.Hovered or self.Depressed or self:IsMenuOpen()) and SKIN.ButtonHovered or SKIN.Button), SKIN.Outline)
end

function SKIN:PaintComboDownArrow(self, w, h)
	surface.SetDrawColor(SKIN.ListViewLineHighlight)
	draw.NoTexture()
	surface.DrawPoly({
		{x = 0, y = w * .5},
		{x = h, y = 0},
		{x = h, y = w}
	})

end

----------------------------------------------------------------
-- DMenu                                                 
----------------------------------------------------------------
function SKIN:PaintMenu(self, w, h)
	plogs.draw.OutlinedBox(0, 0, w, h, SKIN.Button, SKIN.Outline)
end

function SKIN:PaintMenuOption(self, w, h)
	if not self.FontSet then
		self:SetFont('plogs.ui.20')
		self:SetTextInset(5, 0)
		self.FontSet = true
	end
	
	self:SetTextColor(SKIN.Close)

	plogs.draw.OutlinedBox(0, 0, w, h, SKIN.Button, SKIN.Outline)
	
	if self.m_bBackground and  (self.Hovered or self.Highlight) then
		plogs.draw.OutlinedBox(0, 0, w, h, SKIN.ButtonHovered , SKIN.Outline)
	end
end

derma.DefineSkin('pLogs', 'pLogs\'s derma skin', SKIN)


