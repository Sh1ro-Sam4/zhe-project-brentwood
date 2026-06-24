function weight( x )
	return x / 1920 * ScrW()
end

function height( y )
	return y / 1080 * ScrH()
end

local PANEL = {}

AccessorFunc( PANEL, "ActiveButton", "ActiveButton" )

function PANEL:Init()
	Sheeeeesh = vgui.Create("DPanel", self)
	Sheeeeesh:SetSize(weight(300), height(532))
	Sheeeeesh:SetPos(weight(0), height(134))
	Sheeeeesh.Paint = function() end

	self.Navigation = vgui.Create( "DScrollPanel", Sheeeeesh )
	self.Navigation:Dock( LEFT )
	self.Navigation:SetWidth( weight(248) )
	self.Navigation:DockMargin( weight(20), height(20), weight(0), height(0) )

	self.Content = vgui.Create( "Panel", self )
	self.Content:SetSize(weight(1024), height(696))
	self.Content:SetPos(weight(288), height(20))

	self.Items = {}

end

function PANEL:UseButtonOnlyStyle()
	self.ButtonOnly = true
end

function PANEL:AddSheet( panel, material, label )

	if ( !IsValid( panel ) ) then return end

	local Sheet = {}
	
	if ( self.ButtonOnly ) then
		Sheet.Button = vgui.Create( "DImageButton", self.Navigation )
	else
		Sheet.Button = vgui.Create( "DButton", self.Navigation )
	end

	Sheet.Button.Target = panel
	Sheet.Button:Dock( TOP )
	Sheet.Button:SetText( "" )
    Sheet.Button:SetWidth(weight(248))
	Sheet.Button:DockMargin( 0, height(10), 0, 0 )
	Sheet.Button.Paint = function(self, w, h)
        local col
        if Sheet.Button:IsHovered() then
            col = Color(255,255,255,30)
        else
            col = Color(255,255,255,8)
        end
		draw.RoundedBox(10, 0, 0, weight(248), height(76), col)
		surface.SetMaterial(Material( material ))
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(weight(26), height(26), weight(24), height(24))
        draw.SimpleText(label, "onyx.2.28", weight(75), h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        Sheet.Button:SetPos(weight(0), height(164))
		Sheet.Button:SetSize(weight(248), height(76))
	end

	Sheet.Button.DoClick = function()
		self:SetActiveButton( Sheet.Button )
	end

	Sheet.Panel = panel
	Sheet.Panel:SetParent( self.Content )
	Sheet.Panel:SetVisible( false )

	if ( self.ButtonOnly ) then
		Sheet.Button:SizeToContents()
	end

	table.insert( self.Items, Sheet )

	if ( !IsValid( self.ActiveButton ) ) then
		self:SetActiveButton( Sheet.Button )
	end
	
	return Sheet
end

function PANEL:SetActiveButton( active )

	if ( self.ActiveButton == active ) then return end

	if ( self.ActiveButton && self.ActiveButton.Target ) then
		self.ActiveButton.Target:SetVisible( false )
		self.ActiveButton:SetSelected( false )
		self.ActiveButton:SetToggle( false )
	end

	self.ActiveButton = active
	active.Target:SetVisible( true )
	active:SetSelected( true )
	active:SetToggle( true )

	self.Content:InvalidateLayout()

end

derma.DefineControl( "TSheet", "", PANEL, "Panel" )