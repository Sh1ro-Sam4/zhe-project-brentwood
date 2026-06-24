shizlib.draw = shizlib.draw or {}

function shizlib.draw.ShadowText(str, font, font_shadow, x, y, color, xalign, yalign)
    surface.SetFont(font)
    local w, h = surface.GetTextSize(str)
    x = (x or 0) - w * (xalign or 0)
    y = (y or 0) - h * (yalign or 0)
    surface.SetTextColor(color_black)
    surface.SetTextPos(x + 2, y + 2)
    surface.DrawText(str)
    surface.SetTextColor(color or color_white)
    surface.SetTextPos(x, y)
    surface.DrawText(str)

    return tw, th
end

function shizlib.draw.RainbowText(frequency, str, font, x, y)
	surface.SetFont(font)
	surface.SetTextPos(x, y)
	for i = 1, #str do
		local col = HSVToColor(((CurTime() * frequency) + i * 10) % 360, 1, 1)
		surface.SetTextColor(col.r, col.g, col.b)
		surface.DrawText(utf8.sub(str, i, i))
	end
end

function shizlib.draw.RainbowTextOutlined(frequency, str, font, x, y, outlinewidth, outlinecolour)
	local steps = ( outlinewidth * 2 ) / 3
	if steps < 1 then steps = 1 end

	for _x = -outlinewidth, outlinewidth, steps do
		for _y = -outlinewidth, outlinewidth, steps do
			draw.SimpleText(str, font, x + _x, y + _y, outlinecolour)
		end
	end

	return shizlib.draw.RainbowText(frequency, str, font, x, y)
end

local function ClampPanelPosition(panel)
    local x, y = panel:GetPos()
    local w, h = panel:GetSize()
    local screenWidth, screenHeight = ScrW(), ScrH()

    if x < 0 then
        x = 0
    elseif x + w > screenWidth then
        x = screenWidth - w
    end

    if y < 0 then
        y = 0
    elseif y + h > screenHeight then
        y = screenHeight - h
    end

    panel:SetPos(x, y)
end

shizlib.vgui = shizlib.vgui or {}
function shizlib.vgui.derma_menu()
    while IsValid(shizlib.vgui.menu_derma_menu) do
        shizlib.vgui.menu_derma_menu:Remove()
    end

    local mouse_pos_x, mouse_pos_y = input.GetCursorPos()

    shizlib.vgui.menu_derma_menu = vgui.Create('DPanel')
    shizlib.vgui.menu_derma_menu:SetSize(200, 100)
    shizlib.vgui.menu_derma_menu:SetPos(mouse_pos_x - shizlib.vgui.menu_derma_menu:GetWide() * 0.5, mouse_pos_y)
    shizlib.vgui.menu_derma_menu:MakePopup()
    shizlib.vgui.menu_derma_menu:SetIsMenu(true)
    shizlib.vgui.menu_derma_menu:SetKeyBoardInputEnabled(false)
    shizlib.vgui.menu_derma_menu.Paint = function(self, w, h)
        --local x, y = self:LocalToScreen()
        local x, y = 0, 0

        draw.RoundedBox(6, x, y, w, h, Color(37, 37, 37))
    end
    shizlib.vgui.menu_derma_menu.tall = 6
    shizlib.vgui.menu_derma_menu.max_width = 0

    shizlib.vgui.menu_derma_menu.sp = vgui.Create('DScrollPanel', shizlib.vgui.menu_derma_menu)
    shizlib.vgui.menu_derma_menu.sp:Dock(FILL)
    shizlib.vgui.menu_derma_menu.sp:DockMargin(2, 4, 2, 2)

    RegisterDermaMenuForClose(shizlib.vgui.menu_derma_menu)

    function shizlib.vgui.menu_derma_menu:AddOption(name, func, icon)
        local option = vgui.Create('XeninUI.ButtonV2', shizlib.vgui.menu_derma_menu.sp)
        option:Dock(TOP)
        option:DockMargin(2, shizlib.vgui.menu_derma_menu.tall == 0 and 2 or 0, 2, 2)
        option:SetTall(20)
        option:SetRoundness(8)
        option:SetFont('bauhaus_lt_20')
        option:SetText(name)
        option.DoClick = function()

            func()

            shizlib.vgui.menu_derma_menu:Remove()
        end

        surface.SetFont('bauhaus_lt_15')

        shizlib.vgui.menu_derma_menu.max_width = math.max(shizlib.vgui.menu_derma_menu.max_width, surface.GetTextSize(name))

        if icon then
            option.icon = vgui.Create('DPanel', option)
            option.icon:SetSize(16, 16)
            option.icon:SetPos(2, 2)

            local mat_icon = Material(icon)

            option.icon.Paint = function(_, w, h)
                surface.SetDrawColor(color_white)
                surface.SetMaterial(mat_icon)
                surface.DrawTexturedRect(0, 0, w, h)
            end
        end

        shizlib.vgui.menu_derma_menu.tall = shizlib.vgui.menu_derma_menu.tall + 22 + (shizlib.vgui.menu_derma_menu.tall == 0 and 2 or 0)
        shizlib.vgui.menu_derma_menu:SetTall(math.Clamp(shizlib.vgui.menu_derma_menu.tall, 0, ScrH() * 0.5))
        shizlib.vgui.menu_derma_menu:SetWide(shizlib.vgui.menu_derma_menu.max_width + 72)

        ClampPanelPosition(shizlib.vgui.menu_derma_menu)
    end

    function shizlib.vgui.menu_derma_menu:AddSpacer()
        local pan_spacer = vgui.Create('DPanel', shizlib.vgui.menu_derma_menu.sp)
        pan_spacer:Dock(TOP)
        pan_spacer:DockMargin(0, 2, 0, 4)
        pan_spacer:SetTall(4)
        pan_spacer.Paint = function(_, w, h)
            draw.RoundedBox(2, 6, 0, w - 12, h, Color(200, 200, 200, 50))
        end

        shizlib.vgui.menu_derma_menu.tall = shizlib.vgui.menu_derma_menu.tall + 10
        shizlib.vgui.menu_derma_menu:SetTall(shizlib.vgui.menu_derma_menu.tall)
    end

    function shizlib.vgui.menu_derma_menu:GetDeleteSelf()
        return true
    end

    return shizlib.vgui.menu_derma_menu
end

local surface_SetFont 		= surface.SetFont
local surface_GetTextSize 	= surface.GetTextSize
local string_Explode 		= string.Explode
local ipairs 				= ipairs

function string.Wrap(font, text, width)
	surface_SetFont(font)
		
	local sw = surface_GetTextSize(' ')
	local ret = {}
		
	local w = 0
	local s = ''

	local t = string_Explode('\n', text)
	for i = 1, #t do
		local t2 = string_Explode(' ', t[i], false)
		for i2 = 1, #t2 do
			local neww = surface_GetTextSize(t2[i2])
				
			if (w + neww >= width) then
				ret[#ret + 1] = s
				w = neww + sw
				s = t2[i2] .. ' '
			else
				s = s .. t2[i2] .. ' '
				w = w + neww + sw
			end
		end
		ret[#ret + 1] = s
		w = 0
		s = ''
	end
		
	if (s ~= '') then
		ret[#ret + 1] = s
	end

	return ret
end

-- surface.CreateFont('ui.100', { font = 'Montserrat Medium', size = 100, weight = 800, extended = true, }) 
-- surface.CreateFont('ui.85', { font = 'Montserrat Medium', size = 85, weight = 700, extended = true, }) 
-- surface.CreateFont('ui.60', { font = 'Montserrat Medium', size = 60, weight = 700, extended = true, }) 
-- surface.CreateFont('ui.45', { font = 'Montserrat Medium', size = 40, weight = 550, extended = true, }) 
-- surface.CreateFont('ui.40', { font = 'Montserrat Medium', size = 40, weight = 500, extended = true, }) 
-- surface.CreateFont('ui.39', { font = 'Montserrat Medium', size = 39, weight = 500, extended = true, }) 
-- surface.CreateFont('ui.38', { font = 'Montserrat Medium', size = 38, weight = 500, extended = true, }) 
-- surface.CreateFont('ui.37', { font = 'Montserrat Medium', size = 37, weight = 500, extended = true, }) 
-- surface.CreateFont('ui.36', { font = 'Montserrat Medium', size = 36, weight = 500, extended = true, }) 
-- surface.CreateFont('ui.35', { font = 'Montserrat Medium', size = 35, weight = 500, extended = true, }) 
-- surface.CreateFont('ui.34', { font = 'Montserrat Medium', size = 34, weight = 500, extended = true, }) 
-- surface.CreateFont('ui.33', { font = 'Montserrat Medium', size = 33, weight = 500, extended = true, }) 
-- surface.CreateFont('ui.32', { font = 'Montserrat Medium', size = 32, weight = 500, extended = true, }) 
-- surface.CreateFont('ui.31', { font = 'Montserrat Medium', size = 31, weight = 500, extended = true, }) 
-- surface.CreateFont('ui.30', { font = 'Montserrat Medium', size = 30, weight = 500, extended = true, }) 
-- surface.CreateFont('ui.29', { font = 'Montserrat Medium', size = 29, weight = 500, extended = true, }) 
-- surface.CreateFont('ui.28', { font = 'Montserrat Medium', size = 28, weight = 500, extended = true, }) 
-- surface.CreateFont('ui.27', { font = 'Montserrat Medium', size = 27, weight = 400, extended = true, }) 
-- surface.CreateFont('ui.26', { font = 'Montserrat Medium', size = 26, weight = 400, extended = true, }) 
-- surface.CreateFont('ui.25', { font = 'Montserrat Medium', size = 25, weight = 400, extended = true, }) 
-- surface.CreateFont('ui.24', { font = 'Montserrat Medium', size = 24, weight = 400, extended = true, }) 
-- surface.CreateFont('ui.23', { font = 'Montserrat Medium', size = 23, weight = 400, extended = true, }) 
-- surface.CreateFont('ui.22', { font = 'Montserrat Medium', size = 22, weight = 400, extended = true, }) 
-- surface.CreateFont('ui.20', { font = 'Montserrat Medium', size = 19, weight = 400, extended = true, }) 
-- surface.CreateFont('ui.19', { font = 'Montserrat Medium', size = 19, weight = 400, extended = true, }) 
-- surface.CreateFont('ui.18', { font = 'Montserrat Medium', size = 18, weight = 400, extended = true, }) 
-- surface.CreateFont('ui.17', { font = 'Montserrat Medium', size = 17, weight = 550, extended = true, }) 
-- surface.CreateFont('ui.16', { font = 'Montserrat Medium', size = 16, weight = 550, extended = true, }) 
-- surface.CreateFont('ui.15', { font = 'Montserrat Medium', size = 15, weight = 550, extended = true, }) 
-- surface.CreateFont('ui.14', { font = 'Montserrat Medium', size = 14, weight = 550, extended = true, }) 
-- surface.CreateFont('ui.13', { font = 'Montserrat Medium', size = 13, weight = 550, extended = true, }) 
-- surface.CreateFont('ui.12', { font = 'Montserrat Medium', size = 12, weight = 550, extended = true, }) 
-- surface.CreateFont('ui.10', { font = 'Montserrat Medium', size = 10, weight = 550, extended = true, }) 
-- surface.CreateFont('ui.5percent', { font = 'Montserrat Medium', size = math.ceil(ScrH() * 0.05), weight = 500, antialias = true }) 
-- surface.CreateFont('ul.30', { font = 'Montserrat Medium', size = 30, weight = 500, extended = true, }) 
-- surface.CreateFont('ul.29', { font = 'Montserrat Medium', size = 29, weight = 500, extended = true, }) 
-- surface.CreateFont('ul.28', { font = 'Montserrat Medium', size = 28, weight = 500, extended = true, }) 
-- surface.CreateFont('ul.27', { font = 'Montserrat Medium', size = 27, weight = 400, extended = true, }) 
-- surface.CreateFont('ul.26', { font = 'Montserrat Medium', size = 26, weight = 400, extended = true, }) 
-- surface.CreateFont('ul.25', { font = 'Montserrat Medium', size = 25, weight = 400, extended = true, }) 
-- surface.CreateFont('ul.24', { font = 'Montserrat Medium', size = 24, weight = 400, extended = true, }) 
-- surface.CreateFont('ul.23', { font = 'Montserrat Medium', size = 23, weight = 400, extended = true, }) 
-- surface.CreateFont('ul.22', { font = 'Montserrat Medium', size = 22, weight = 400, extended = true, }) 
-- surface.CreateFont('ul.20', { font = 'Montserrat Medium', size = 20, weight = 400, extended = true, }) 
-- surface.CreateFont('ul.19', { font = 'Montserrat Medium', size = 19, weight = 400, extended = true, }) 
-- surface.CreateFont('ul.18', { font = 'Montserrat Medium', size = 18, weight = 400, extended = true, }) 
-- surface.CreateFont('ul.17', { font = 'Montserrat Medium', size = 15, weight = 550, extended = true, }) 
-- surface.CreateFont('ul.15', { font = 'Montserrat Medium', size = 15, weight = 550, extended = true, }) 
-- surface.CreateFont('ul.12', { font = 'Montserrat Medium', size = 12, weight = 550, extended = true, })