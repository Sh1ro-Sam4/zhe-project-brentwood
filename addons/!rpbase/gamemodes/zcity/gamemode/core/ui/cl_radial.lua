function draw.CirclePart(x, y, radius, seg, parts, pos)
	local cir = {}
	table.insert(cir, {
		x = x,
		y = y,
		u = 0.5,
		v = 0.5
	})

	for i = 0, seg do
		local a = math.rad((i / seg) * -360 / parts - pos * 360 / parts) + math.pi
		table.insert(cir, {
			x = x + math.sin(a) * radius,
			y = y + math.cos(a) * radius,
			u = math.sin(a) / 2 + 0.5,
			v = math.cos(a) / 2 + 0.5
		})
		--draw.DrawText("asd","HomigradFontBig",x + math.sin(a) * radius,y + math.cos(a) * radius)
	end

	--local a = math.rad(0)
	--table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	surface.DrawPoly(cir)
	render.PopFilterMin()
end

if IsValid(MENUPANELHUYHUY) then
	MENUPANELHUYHUY:Remove()
	MENUPANELHUYHUY = nil
end

hg.radialOptions = hg.radialOptions or {}
local colBlack = Color(0, 0, 0, 152)
local colOption = Color(0, 0, 0, 152)
local colWhite = Color(255, 255, 255, 255)
local colWhiteTransparent = ColorAlpha(CFG.theme.accent, 160)
local colTransparent = Color(0, 0, 0, 0)
local matHuy = Material("vgui/white")
local vecXY = Vector(0, 0)
local vecDown = Vector(0, 1)
local isMouseIntersecting = false
local isMouseOnRadial = false
local current_option = 1
local current_option_select = 1
local hook_Run = hook.Run


local menuPanel

local colBack = Color(0,0,0)
local colMoney = Color(0, 255, 0)
local function CreateRadialMenu(options_arg)
	local sizeX, sizeY = ScrW(), ScrH()
	hg.radialOptions = {}
	local paining = lply.organism and lply.organism.pain and (lply.organism.pain > 100) or false
	
	if !options_arg then
		local functions = hook.GetTable()["radialOptions"]
		for i, func in SortedPairs(functions) do
			func()
		end
	end

	//hook_Run("radialOptions")
	local options1 = options_arg or hg.radialOptions

	hg.radialOptions = options1
	
	if IsValid(MENUPANELHUYHUY) then
		MENUPANELHUYHUY:Remove()
		MENUPANELHUYHUY = nil
	end

	MENUPANELHUYHUY = vgui.Create("DPanel")
	menuPanel = MENUPANELHUYHUY
	menuPanel:SetPos(ScrW() / 2 - sizeX / 2, ScrH() / 2 - sizeY / 2)
	menuPanel:SetSize(sizeX, sizeY)
	menuPanel:MakePopup()
	menuPanel:SetKeyBoardInputEnabled(false)
	menuPanel:SetAlpha(0)
	menuPanel:AlphaTo(255,0.2)
	if !options_arg then input.SetCursorPos(sizeX / 2, sizeY / 2) end

	function menuPanel:Close()
		if not IsValid(menuPanel) then return end
		menuPanel:AlphaTo(0,0.1,0,function()
			if IsValid(menuPanel) then
				menuPanel:Remove()
				menuPanel = nil
			end
		end)
	end

	local thinkwait = 0
	if !options_arg then
		menuPanel.Think = function()
			if menuPanel:GetAlpha() < 255 then return end
			if thinkwait > CurTime() then return end
			thinkwait = CurTime() + 0.25
			table.Empty(hg.radialOptions)
			local functions = hook.GetTable()["radialOptions"]
			
			for i, func in SortedPairs(functions) do
				//if i == "zmeyka_test" then continue end
				func()
			end
		end
	end
	
	local sizePan = 0
	local optionSelected = {}
	menuPanel.Paint = function(self, w, h)
		local x, y = input.GetCursorPos()
		x = x - sizeX / 2
		y = y - sizeY / 2
		vecXY.x = x
		vecXY.y = y
		local deg = (vecXY:GetNormalized() - vecDown):Angle()
		deg = math.NormalizeAngle((deg[2] - 180) * 2) + 180
		
		local options = {}
		if paining then
			options[#options + 1] = {function() RunConsoleCommand("hg_phrase") end, ""}
		else
			options = options1
		end

		sizePan = LerpFT( menuPanel:GetAlpha() > 100 and 0.05 or 0.25,sizePan,(menuPanel:GetAlpha()/255))
		local viewLerp = Lerp(math.ease.OutExpo(sizePan),0,1)
		for num, option in ipairs(options) do
			local num = num - 1
			
			local r = ScrH() * (options_arg ~= nil and 0.4 or 0.45) * viewLerp * .8
			local partDeg = 360 / #options
			local sqrt = math.sqrt(x ^ 2 + y ^ 2)
			isMouseOnRadial = sqrt <= r and sqrt > 4
			isMouseIntersecting = isMouseOnRadial and deg > num * partDeg and deg < (num + 1) * partDeg
			if isMouseIntersecting then current_option = num + 1 end
			if sqrt > 0 and current_option > 0 and num and !intersect_xyPartDeg then return end

			optionSelected[num] = optionSelected[num] or 0
			optionSelected[num] = LerpFT(0.1, optionSelected[num], isMouseIntersecting and 1 or 0)
			
			if option[3] then
				surface.SetMaterial(matHuy)
				surface.SetDrawColor(isMouseIntersecting and colBlack or colBlack)
				draw.CirclePart(w / 2, h / 2, r, 40, #options, num)
				local count = #option[4]
				
				local selectedPart = count - (math.floor((r - sqrt) / (r / count)))
				
				current_option_select = selectedPart
				for i, opt in pairs(option[4]) do
					local selected = selectedPart == i
					surface.SetMaterial(matHuy)
					surface.SetDrawColor((selected and isMouseIntersecting) and colWhiteTransparent or colTransparent)
					draw.CirclePart(w / 2, h / 2, r * (i / count), 40, #options, num)
					local a = -partDeg * num - partDeg / 2
					a = math.rad(a) + math.pi

					if paining then
						math.randomseed(math.Round(CurTime() / 5 + num + i, 0))
						opt = ""//hg.get_status_message(ply)
						math.randomseed(os.time())
					end

					draw.DrawText(opt, "ui.15", ScrW() / 2 + math.sin(a) * r * (i / count - 0.5 / count), ScrH() / 2 + math.cos(a) * r * (i / count - 0.5 / count), colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end

				continue
			end
			
			--print(options_arg ~= nil and true or false)
			surface.SetMaterial(matHuy)	
			surface.SetDrawColor(colWhiteTransparent:Lerp(options_arg ~= nil and colOption or colBlack, 1 - optionSelected[num]))
			draw.CirclePart(w / 2, h / 2, r * (1 + 0.1 * optionSelected[num]), 30, #options, num)
			local a = -partDeg * num - partDeg / 2
			a = math.rad(a) + math.pi
			local txt = option[2]
			if txt and !options_old then return end
			if paining then
				math.randomseed(math.Round(CurTime() / 5 + num, 0))
				txt = hg.get_status_message(ply)
				math.randomseed(os.time())
			end
			draw.DrawText(txt, "ui.20", ScrW() / 2 + math.sin(a) * r * 0.75, ScrH() / 2 + math.cos(a) * r * 0.75, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			if not paining then
				local moneyText = FormatMoney(lply:GetMoney()) or 0
				draw.SimpleText(lply:GetPlayerName(), "ui.60", ScrW() * 0.0215 * viewLerp, ScrH() * 0.042, colBack, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText( rp.GetClassName(lply:GetPlayerClass()), "ui.60", ScrW() * 0.0215 * viewLerp, ScrH() * 0.103, colBack, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText(moneyText, "ui.60", ScrW() * 0.0215 * viewLerp, ScrH() * 0.166, colBack, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				local col = lply:GetPlayerColor():ToColor()
				local colJob = rp.GetClassColor(lply:GetPlayerClass())
				draw.SimpleText(lply:GetPlayerName(), "ui.60", ScrW() * 0.02 * viewLerp, ScrH() * 0.04, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText( rp.GetClassName(lply:GetPlayerClass()), "ui.60", ScrW() * 0.02 * viewLerp, ScrH() * 0.1, colJob, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText(moneyText, "ui.60", ScrW() * 0.02 * viewLerp, ScrH() * 0.163, colMoney, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end
	end
end

local function PressRadialMenu(mouseClick)
	local options = hg.radialOptions
	--print(options[current_option][1])
	--[[if lply.organism and lply.organism.pain and lply.organism.pain > 100 then
		hook_Run("RadialMenuPressed")

		if IsValid(menuPanel) then
			menuPanel:Close()
		end

		return
	end--]]

	hook_Run("RadialMenuPressed")

	local needed_mouseclick
	if IsValid(menuPanel) and options[current_option] and isMouseOnRadial then
		local func = options[current_option][1]
		if isfunction(func) then needed_mouseclick = func(mouseClick, current_option_select) end
	end

	if needed_mouseclick != -1 and IsValid(menuPanel) and mouseClick != (needed_mouseclick or 2) then
		menuPanel:Close()
	end
end

hg.CreateRadialMenu = CreateRadialMenu
hg.PressRadialMenu = PressRadialMenu

local firstTime = true
local firstTime2 = true
local firstTime3 = true
local firstTime4 = true
local firstTime5 = true
local firstTime6 = true

-- first time?..

hook.Add("HG_OnOtrub", "resetshit", function(ply)
	if ply == lply then
		hook_Run("RadialMenuPressed")

		if IsValid(menuPanel) then
			menuPanel:Close()
		end
	end
end)

hook.Add( "PlayerBindPress", "PlayerBindPressExample2huy", function( ply, bind, pressed )
	if string.find(bind, "+menu") then

		if (lply.organism and lply.organism.otrub) then
			return (bind == "+menu") or nil
		end

		if (bind == "+menu") then
			if pressed and !IsValid(MENUPANELHUYHUY) then
				CreateRadialMenu()
			else
				PressRadialMenu(1)
			end
		else
			return
		end

		return true
	end
end)

hook.Add("Think", "hg-radial-menu", function()
	if (lply.organism and lply.organism.otrub) then

		if IsValid(menuPanel) then
			hook_Run("RadialMenuPressed")
			menuPanel:Close()
		end

		return
	end
	
	if (engine.ActiveGamemode() ~= "zcity" and input.IsKeyDown(KEY_Q)) or (engine.ActiveGamemode() == "zcity" and input.IsKeyDown(KEY_C)) then
		if firstTime then
			firstTime = false
			--CreateRadialMenu()
		end

		firstTime4 = true
	else
		if firstTime4 then
			firstTime4 = false
			--PressRadialMenu()
		end

		firstTime = true
	end

	if input.IsMouseDown(MOUSE_LEFT) then
		if firstTime2 then
			firstTime2 = false
			--print("pressed")
		end

		firstTime3 = true
	else
		if firstTime3 then
			firstTime3 = false
			--print("released")
			PressRadialMenu(1)
		end

		firstTime2 = true
	end

	if input.IsMouseDown(MOUSE_RIGHT) then
		if firstTime5 then
			firstTime5 = false
			--print("pressed")
		end

		firstTime6 = true
	else
		if firstTime6 then
			firstTime6 = false
			--print("released")
			PressRadialMenu(2)
		end

		firstTime5 = true
	end
end)

local function dropWeapon()
	RunConsoleCommand("+drop")
end

hook.Add("radialOptions", "77", function()
	local organism = lply.organism or {}
	local wep = lply:GetActiveWeapon()
	if not organism.otrub and IsValid(wep) and cfg.disallowdrop[wep:GetClass()] then return false end
		local tbl = {dropWeapon, "Выбросить"}
		hg.radialOptions[#hg.radialOptions + 1] = tbl
end)

local randomGestures = {
    {"Помахать", "wave"},
    {"Отдать честь", "salute"},
    {"Стоять", "halt"},
    {"Группа", "group"},
    {"Вперед", "forward"},
    {"Не согласен", "disagree"},
    --{"Согласен", "agree"},
    {"Сюда", "becon"},
    {"Показать пальцем", function() RunConsoleCommand("hg_hand_gesture", "point") end},
    {"Средний палец", function() RunConsoleCommand("hg_hand_gesture", "fuckyou") end},
    {"Большой палец вверх", function() RunConsoleCommand("hg_hand_gesture", "thumb_up") end},
}

concommand.Add("hg_randomgesture",function()
	randomGesture()
end)

hook.Add("radialOptions", "7", function()
    local ply = LocalPlayer()
    local organism = ply.organism or {}

    if ply:Alive() and not organism.otrub and hg.GetCurrentCharacter(ply) == ply then
        local tbl = {function(mouseClick)
            if mouseClick == 1 then
                local randElement = randomGestures[math.random(#randomGestures)]
                local action = randElement[2]
                
                if isfunction(action) then
                    action()
                else
                    RunConsoleCommand("act", action)
                end
            else
                local commands = {}
                for i, data in ipairs(randomGestures) do
                    commands[i] = {
                        [1] = function()
                            if isfunction(data[2]) then
                                data[2]()
                            else
                                RunConsoleCommand("act", data[2])
                            end
                        end,
                        [2] = data[1]
                    }
                end
                CreateRadialMenu(commands)
            end
        end, "Жесты\nПКМ - Меню"}
        hg.radialOptions[#hg.radialOptions + 1] = tbl
    end
end)

hook.Add("radialOptions", "self_inspect", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local organism = ply.organism or {}

    if ply:Alive() and not organism.otrub and hg.GetCurrentCharacter(ply) == ply then
        local tbl = {function()
            RunConsoleCommand("hg_selfinspect_")
        end, "Осмотреть себя"}
        hg.radialOptions[#hg.radialOptions + 1] = tbl

        -- Осмотр других игроков/рэгдоллов для медиков
        local function isMedic(p)
            if not IsValid(p) then return false end
            if p.Profession == "doctor" then return true end
            if p:Team() == TEAM_MEDIC then return true end
            if p.GetPlayerClass and p:GetPlayerClass() == TEAM_MEDIC then return true end
            return false
        end

        if isMedic(ply) then
            local trace = ply:GetEyeTrace()
            local ent = trace.Entity
            if IsValid(ent) and (trace.StartPos:Distance(trace.HitPos) < 100) then
                local target = ent:IsPlayer() and ent or hg.RagdollOwner(ent)
                if IsValid(target) and target ~= ply then
                    local tbl2 = {function()
                        RunConsoleCommand("hg_inspect_", target:EntIndex())
                    end, "Осмотреть: " .. target:Name()}
                    hg.radialOptions[#hg.radialOptions + 1] = tbl2
                end
            end
        end
    end
end)

local hint
local hg_hints = ConVarExists("hg_hints") and GetConVar("hg_hints") or CreateClientConVar("hg_hints", "1", true, false, "Enable\\Disable hints.")

local HintBackgroundColor = Color( 0, 0, 0, 200 )

hook.Remove("HUDPaint","EntHints",function()
	if not hg_hints:GetBool() then return end 
	if lply.organism and lply.organism.otrub then return end
	if !lply:Alive() then return end
	
	local trace = hg.eyeTrace(lply)

	if not trace then return end

	HintBackgroundColor.a = LerpFT(0.1, HintBackgroundColor.a, (IsValid(trace.Entity) and trace.Entity.HudHintMarkup) and 200 or 0)

	hg.BasicHudHint(trace.Entity, trace, hint)
end)

function hg.BasicHudHint(ent, trace)
	hint = (IsValid(ent) and ent.HudHintMarkup) or hint

	if not hint then return end

	local x, y = trace.HitPos:ToScreen().x, trace.HitPos:ToScreen().y
	y = y + 145 + -45

	draw.RoundedBox(2, x - hint:GetWidth() / 2 - 2.5, y - 2.5, hint:GetWidth() + 5, hint:GetHeight() + 5, HintBackgroundColor)
	
	hint:Draw(x, y, TEXT_ALIGN_CENTER, nil, 175 * (HintBackgroundColor.a / 200), TEXT_ALIGN_CENTER)

	if ent.AdditionalInfoFunc then
		local str = ent.AdditionalInfoFunc()

		local w, h = surface.GetTextSize(str)
		surface.SetFont("ZCity_Tiny")
		surface.SetTextColor(color_white)
		surface.SetTextPos(x - w * 0.5, y + hint:GetHeight() + h)
		surface.DrawText(str)
	end
end

surface.CreateFont('selfinspect_font_16',{font = "Roboto",size = 21,extended = true,weight = 600,shadow = true, antialias = true})
surface.CreateFont('selfinspect_font_14',{font = "Roboto",size = 19,extended = true,weight = 600,shadow = true, antialias = true})
surface.CreateFont('selfinspect_font_12',{font = "Roboto",size = 17,extended = true,weight = 600,shadow = true, antialias = true})

net.Receive("SelfInspect_OpenMenu", function()
	local data = net.ReadTable()
	if not data then return end

	local s = (shizlib and shizlib.surface and shizlib.surface.s) or function(val) return val end
	local RNDX = rawget(_G, "RNDX")
	if not RNDX then
		pcall(function() RNDX = include("shizlib/client/rndx_cl.lua") end)
	end

	local function drawBox(r, x, y, w, h, col)
		if RNDX and RNDX.Draw then
			RNDX.Draw(r, x, y, w, h, col, RNDX.SHAPE_FIGMA)
		else
			draw.RoundedBox(r, x, y, w, h, col)
		end
	end

	local function lerpColor(t, from, to)
		if shizlib and shizlib.surface and shizlib.surface.LerpColor then
			return shizlib.surface.LerpColor(t, from, to)
		end
		return Color(
			Lerp(t, from.r, to.r),
			Lerp(t, from.g, to.g),
			Lerp(t, from.b, to.b),
			Lerp(t, from.a, to.a)
		)
	end

	surface.CreateFont('selfinspect_title', { font = 'Montserrat', size = s(24), weight = 800, extended = true, antialias = true })
	surface.CreateFont('selfinspect_sub', { font = 'Montserrat', size = s(16), weight = 700, extended = true, antialias = true })
	surface.CreateFont('selfinspect_text', { font = 'Montserrat', size = s(14), weight = 600, extended = true, antialias = true })
	surface.CreateFont('selfinspect_text_bold', { font = 'Montserrat', size = s(14), weight = 800, extended = true, antialias = true })
	surface.CreateFont('selfinspect_small', { font = 'Montserrat', size = s(12), weight = 500, extended = true, antialias = true })
	surface.CreateFont('selfinspect_distress', { font = 'Montserrat', size = s(28), weight = 800, extended = true, antialias = true })

	local badness = 0
	if data.isSelf ~= false then
		local consciousnessFactor = math.Clamp((0.8 - (data.consciousness or 1)) / 0.4, 0, 1)
		local bloodFactor = math.Clamp((4200 - (data.blood or 5000)) / 1300, 0, 1)
		local painFactor = math.Clamp(((data.pain or 0) - 30) / 50, 0, 1)
		local o2Factor = math.Clamp((20 - (data.o2 or 30)) / 15, 0, 1)
		local bleedFactor = math.Clamp((data.bleed or 0) / 8, 0, 1)
		badness = math.max(consciousnessFactor, bloodFactor, painFactor, o2Factor, bleedFactor)
	end

	local phrases = {
		"В глазах темнеет...",
		"Я теряю сознание...",
		"Холодно... так холодно...",
		"Нужно дышать...",
		"Дыши... просто дыши...",
		"Сердце... сейчас остановится...",
		"Только не засыпай...",
		"Я умираю?...",
		"Все плывет...",
		"Слишком много боли...",
		"Мама?...",
		"Где я?...",
		"Шум... в ушах этот гул...",
		"Свет... угасает...",
		"Кто-нибудь... помогите..."
	}

	local floatingPhrases = {}
	for i = 1, 12 do
		table.insert(floatingPhrases, {
			text = phrases[math.random(1, #phrases)],
			x = math.random(s(50), s(550)),
			y = math.random(s(80), s(450)),
			angle = math.random(-20, 20),
			speedX = math.Rand(-8, 8),
			speedY = math.Rand(-8, 8),
			scale = math.Rand(0.8, 1.25),
			rotSpeed = math.Rand(-4, 4)
		})
	end

	local function drawGlitchText(text, font, x, y, col, alignX, alignY)
		alignX = alignX or 0
		alignY = alignY or 0
		
		local drawCol = col
		if badness > 0.3 and math.random() < 0.1 then
			drawCol = Color(col.r, col.g, col.b, col.a * math.Rand(0.3, 1))
		end
		
		if badness > 0.4 and math.random() < 0.2 then
			local offset = math.random(1, 3) * badness
			draw.SimpleText(text, font, x - offset, y, Color(0, 255, 255, drawCol.a * 0.8), alignX, alignY)
			draw.SimpleText(text, font, x + offset, y, Color(255, 50, 100, drawCol.a * 0.8), alignX, alignY)
		else
			draw.SimpleText(text, font, x, y, drawCol, alignX, alignY)
		end
	end

	local COLORS = {
		BG = Color(22, 22, 22),
		TEXT = Color(255, 255, 255),
		TEXT_DIM = Color(160, 160, 160),
		GREEN = Color(46, 204, 113),
		YELLOW = Color(241, 196, 15),
		ORANGE = Color(230, 126, 34),
		RED = Color(231, 76, 60),
	}

	local menuW, menuH = s(620), s(540)
	local fr = vgui.Create("EditablePanel")
	fr:SetSize(menuW, menuH)
	fr:Center()
	fr:MakePopup()
	fr:SetAlpha(0)
	fr:AlphaTo(255, 0.2)

	fr.Paint = function(self, w, h)
		local dx, dy = 0, 0
		if badness > 0.3 and math.random() < 0.15 then
			dx = math.random(-3, 3) * badness
			dy = math.random(-3, 3) * badness
		end

		drawBox(8, dx, dy, w, h, COLORS.BG)

		if badness > 0.2 and math.random() < (badness * 0.4) then
			surface.SetDrawColor(220, 50, 50, math.random(40, 160) * badness)
			local staticY = math.random(0, h)
			surface.DrawRect(0, staticY, w, math.random(2, 6))
		end
	end

	fr.PaintOver = function(self, w, h)
		if badness > 0.1 then
			local ft = FrameTime()
			local px, py = self:LocalToScreen(0, 0)
			render.SetScissorRect(px, py, px + w, py + h, true)

			for _, p in ipairs(floatingPhrases) do
				p.x = p.x + p.speedX * ft
				p.y = p.y + p.speedY * ft
				p.angle = p.angle + p.rotSpeed * ft
				
				if p.x < 0 then p.x = w end
				if p.x > w then p.x = 0 end
				if p.y < s(50) then p.y = h end
				if p.y > h then p.y = s(50) end

				local alpha = math.Clamp(badness * 75 * p.scale, 0, 150)
				local col = Color(220, 30, 30, alpha)
				
				local m = Matrix()
				m:Translate(Vector(p.x, p.y, 0))
				m:Rotate(Angle(0, p.angle, 0))
				m:Scale(Vector(p.scale, p.scale, 1))
				
				cam.PushModelMatrix(m, true)
					draw.SimpleText(p.text, "selfinspect_distress", 0, 0, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				cam.PopModelMatrix()
			end

			render.SetScissorRect(0, 0, 0, 0, false)
		end
	end

	fr.Think = function(self)
		if input.IsKeyDown(KEY_ESCAPE) then
			self:Remove()
			gui.HideGameUI()
		end
		
		if badness > 0.4 then
			local px, py = self:GetPos()
			if not self.OrigX then
				self.OrigX, self.OrigY = px, py
			end
			if math.random() < (badness * 0.3) then
				local offX = math.random(-4, 4) * badness
				local offY = math.random(-4, 4) * badness
				self:SetPos(self.OrigX + offX, self.OrigY + offY)
			else
				self:SetPos(self.OrigX, self.OrigY)
			end
		end
	end

	local mtitle = fr:Add("DLabel")
	mtitle:Dock(TOP)
	mtitle:DockMargin(s(40), s(36), 0, s(12))
	mtitle:SetTall(s(29))
	local titleText = "Результаты осмотра"
	if data.targetName and data.targetName ~= "себя" then
		titleText = "Осмотр: " .. data.targetName
	end
	mtitle:SetText(titleText)
	mtitle:SetFont("selfinspect_title")
	mtitle:SetTextColor(Color(230, 230, 230))

	local close = fr:Add("EditablePanel")
	close:SetSize(s(90) + s(5), s(26))
	close:SetPos(menuW - s(29) - s(90), s(35))
	close:SetCursor("hand")
	close.lerpHover = 0
	close.Paint = function(self, w, h)
		self.lerpHover = math.Clamp(self:IsHovered() and self.lerpHover + FrameTime()*3 or self.lerpHover - FrameTime()*3, 0, 1)
		local lerpedBG = lerpColor(self.lerpHover, Color(255, 255, 255, 0), color_white)
		local lerpedText = lerpColor(self.lerpHover, color_white, color_black)
		
		drawBox(6, 0, 0, w, h, lerpedBG)
		drawBox(5, w - s(38), 0, s(38), h, color_white)
		
		draw.SimpleText("Выход", "IB_14", s(5), h * 0.5 - 1, lerpedText, 0, 1)
		draw.SimpleText("Esc", "IB_14", w - s(7), h * 0.5 - 1, color_black, 2, 1)
	end
	close.OnMousePressed = function()
		fr:Remove()
	end

	local divider = fr:Add("Panel")
	divider:Dock(TOP)
	divider:DockMargin(s(40), s(10), s(40), 0)
	divider:SetTall(s(2))
	divider.Paint = function(self, w, h)
		drawBox(0, 0, 0, w, h, Color(45, 45, 45))
	end

	local scroll = fr:Add("DScrollPanel")
	scroll:Dock(FILL)
	scroll:DockMargin(s(40), s(20), s(40), s(30))

	local sbar = scroll:GetVBar()
	sbar:SetWide(s(6))
	sbar:Dock(RIGHT)
	sbar.Paint = function(self, w, h)
		drawBox(3, 0, 0, w, h, Color(0, 0, 0, 80))
	end
	sbar.btnUp.Paint = function() end
	sbar.btnDown.Paint = function() end
	sbar.btnGrip.Paint = function(self, w, h)
		local hover = self:IsHovered() or self.Depressed
		drawBox(3, 0, 0, w, h, Color(255, 255, 255, hover and 220 or 120))
	end

	local function addSection(titleText)
		local sec = scroll:Add("Panel")
		sec:Dock(TOP)
		sec:DockMargin(0, 0, s(10), s(15))
		sec:SetTall(s(30))
		
		local titleLbl = sec:Add("DLabel")
		titleLbl:Dock(TOP)
		titleLbl:SetFont("selfinspect_sub")
		titleLbl:SetTextColor(Color(200, 200, 200))
		titleLbl:SetText(titleText)
		titleLbl:DockMargin(s(5), 0, 0, s(8))
		titleLbl:SizeToContents()
		
		local contentArea = sec:Add("Panel")
		contentArea:Dock(TOP)
		contentArea:SetTall(0)
		
		function sec:AddRow(labelText, valueText, valueColor, descriptionText)
			local row = contentArea:Add("Panel")
			row:Dock(TOP)
			row:DockMargin(0, 0, 0, s(6))
			row:SetTall(s(54))
			
			row.Paint = function(self, w, h)
				local hover = self:IsHovered()
				local bgCol = hover and Color(36, 36, 36) or Color(26, 26, 26)
				drawBox(6, 0, 0, w, h, bgCol)
				
				local rdx, rdy = 0, 0
				if badness > 0.4 and math.random() < 0.1 then
					rdx = math.random(-2, 2) * badness
					rdy = math.random(-2, 2) * badness
				end
				
				drawGlitchText(labelText, "selfinspect_text", s(15) + rdx, h * 0.3 + rdy, COLORS.TEXT_DIM, 0, 1)
				drawGlitchText(valueText, "selfinspect_text_bold", s(160) + rdx, h * 0.3 + rdy, valueColor, 0, 1)
				
				if descriptionText and descriptionText ~= "" then
					drawGlitchText(descriptionText, "selfinspect_small", s(15) + rdx, h * 0.75 + rdy, Color(130, 130, 130), 0, 1)
				end
			end
			
			contentArea:SetTall(contentArea:GetTall() + s(60))
			sec:SetTall(sec:GetTall() + s(60))
		end
		
		return sec
	end

	-- 1. Жизненные показатели
	local secVitals = addSection("Жизненные показатели")

	-- Pulse calculation
	local pulseVal = math.Round(data.pulse)
	local pulseStr, pulseColor, pulseDesc = "", Color(255, 255, 255), ""
	if data.heartstop or pulseVal <= 15 then
		pulseStr = "Асистолия (клиническая смерть)"
		pulseColor = COLORS.RED
		pulseDesc = "Пульс не определяется. Требуется немедленная реанимация."
	elseif pulseVal < 40 then
		pulseStr = "Критическая брадикардия"
		pulseColor = COLORS.RED
		pulseDesc = "Нитевидный, слабый пульс (" .. pulseVal .. " уд/мин). Опасность остановки сердца."
	elseif pulseVal < 55 then
		pulseStr = "Брадикардия"
		pulseColor = COLORS.ORANGE
		pulseDesc = "Пульс замедлен (" .. pulseVal .. " уд/мин). Нарушение кровообращения."
	elseif pulseVal <= 90 then
		pulseStr = "Нормокардия"
		pulseColor = COLORS.GREEN
		pulseDesc = "Пульс стабильный, хорошего наполнения (" .. pulseVal .. " уд/мин)."
	elseif pulseVal <= 130 then
		pulseStr = "Умеренная тахикардия"
		pulseColor = COLORS.YELLOW
		pulseDesc = "Пульс учащен (" .. pulseVal .. " уд/мин). Стресс, боль или кровопотеря."
	else
		pulseStr = "Выраженная тахикардия"
		pulseColor = COLORS.RED
		pulseDesc = "Критическое сердцебиение (" .. pulseVal .. " уд/мин). Сильный шок."
	end
	secVitals:AddRow("Пульс:", pulseStr, pulseColor, pulseDesc)

	-- Breathing calculation
	local breathingStr, breathingColor, breathingDesc = "", Color(255, 255, 255), ""
	if data.lungsfunction == false then
		breathingStr = "Апноэ (остановка дыхания)"
		breathingColor = COLORS.RED
		breathingDesc = "Самостоятельное дыхание отсутствует!"
	elseif data.lungsL_dmg > 0.1 and data.lungsR_dmg > 0.1 then
		breathingStr = "Двусторонний пневмоторакс"
		breathingColor = COLORS.RED
		breathingDesc = "Оба легких повреждены. Критическое удушье, хрипы."
	elseif data.lungsL_dmg > 0.1 then
		breathingStr = "Левосторонний пневмоторакс"
		breathingColor = COLORS.RED
		breathingDesc = "Левое легкое повреждено. Дыхание затруднено, влажные хрипы."
	elseif data.lungsR_dmg > 0.1 then
		breathingStr = "Правосторонний пневмоторакс"
		breathingColor = COLORS.RED
		breathingDesc = "Правое легкое повреждено. Дыхание затруднено, влажные хрипы."
	elseif data.o2 < 12 then
		breathingStr = "Тяжелая одышка"
		breathingColor = COLORS.ORANGE
		breathingDesc = "Дыхание частое, поверхностное. Нехватка кислорода."
	else
		breathingStr = "Чистое везикулярное дыхание"
		breathingColor = COLORS.GREEN
		breathingDesc = "Дыхание ровное, стабильное. Посторонних шумов нет."
	end
	secVitals:AddRow("Дыхание:", breathingStr, breathingColor, breathingDesc)

	-- Blood level calculation
	local bloodPercent = math.Round((data.blood / 5000) * 100)
	local bloodStr, bloodColor, bloodDesc = "", Color(255, 255, 255), ""
	if bloodPercent < 50 then
		bloodStr = "Критическая гиповолемия (" .. bloodPercent .. "%)"
		bloodColor = COLORS.RED
		bloodDesc = "Терминальная кровопотеря (" .. math.Round(data.blood) .. " мл). Угроза жизни."
	elseif bloodPercent < 70 then
		bloodStr = "Тяжелая гиповолемия (" .. bloodPercent .. "%)"
		bloodColor = COLORS.RED
		bloodDesc = "Геморрагический шок III ст. (" .. math.Round(data.blood) .. " мл). Бледная холодная кожа."
	elseif bloodPercent < 85 then
		bloodStr = "Умеренная гиповолемия (" .. bloodPercent .. "%)"
		bloodColor = COLORS.ORANGE
		bloodDesc = "Геморрагический шок I-II ст. (" .. math.Round(data.blood) .. " мл). Сильная слабость."
	elseif bloodPercent < 95 then
		bloodStr = "Легкая гиповолемия (" .. bloodPercent .. "%)"
		bloodColor = COLORS.YELLOW
		bloodDesc = "Незначительная кровопотеря (" .. math.Round(data.blood) .. " мл)."
	else
		bloodStr = "Нормоволемия (" .. bloodPercent .. "%)"
		bloodColor = COLORS.GREEN
		bloodDesc = "Объем циркулирующей крови в пределах нормы (" .. math.Round(data.blood) .. " мл)."
	end
	secVitals:AddRow("Объем крови (ОЦК):", bloodStr, bloodColor, bloodDesc)

	-- Oxygen saturation calculation
	local o2Percent = math.Round((data.o2 / 30) * 100)
	local o2Str, o2Color, o2Desc = "", Color(255, 255, 255), ""
	if o2Percent < 30 then
		o2Str = "Критическая гипоксия (" .. o2Percent .. "%)"
		o2Color = COLORS.RED
		o2Desc = "Асфиксия крайней степени. Отек или повреждение дыхательных путей."
	elseif o2Percent < 60 then
		o2Str = "Выраженная гипоксия (" .. o2Percent .. "%)"
		o2Color = COLORS.ORANGE
		o2Desc = "Острая дыхательная недостаточность. Пациент задыхается."
	elseif o2Percent < 85 then
		o2Str = "Умеренная гипоксия (" .. o2Percent .. "%)"
		o2Color = COLORS.YELLOW
		o2Desc = "Недостаточное насыщение крови кислородом."
	else
		o2Str = "Нормоксия (" .. o2Percent .. "%)"
		o2Color = COLORS.GREEN
		o2Desc = "Насыщение крови кислородом в норме."
	end
	secVitals:AddRow("Насыщение O2:", o2Str, o2Color, o2Desc)

	-- 2. Неврологический статус
	local secNeurology = addSection("Неврологический статус")

	-- Consciousness calculation
	local conStr, conColor, conDesc = "", Color(255, 255, 255), ""
	if data.consciousness < 0.5 then
		conStr = "Сопор / Угнетено"
		conColor = COLORS.RED
		conDesc = "Предобморочное состояние. Реакции почти отсутствуют."
	elseif data.consciousness < 0.8 then
		conStr = "Оглушение / Спутано"
		conColor = COLORS.ORANGE
		conDesc = "Сильное головокружение, двоение в глазах. Спутанные мысли."
	else
		conStr = "Ясное сознание"
		conColor = COLORS.GREEN
		conDesc = "Адекватное восприятие реальности и хорошая реакция."
	end
	secNeurology:AddRow("Сознание:", conStr, conColor, conDesc)

	-- Pain calculation
	local painVal = math.Round(data.pain)
	local painStr, painColor, painDesc = "", Color(255, 255, 255), ""
	if painVal == 0 then
		painStr = "Отсутствует"
		painColor = COLORS.GREEN
		painDesc = "Болевые ощущения полностью отсутствуют."
	elseif painVal <= 15 then
		painStr = "Слабая боль"
		painColor = COLORS.GREEN
		painDesc = "Локальная, терпимая тупая боль."
	elseif painVal <= 45 then
		painStr = "Умеренная боль"
		painColor = COLORS.YELLOW
		painDesc = "Постоянное чувство дискомфорта и ломоты."
	elseif painVal <= 75 then
		painStr = "Сильная боль"
		painColor = COLORS.ORANGE
		painDesc = "Выраженный болевой синдром. Требуется анальгетик."
	else
		painStr = "Критическая боль"
		painColor = COLORS.RED
		painDesc = "Угроза болевого шока. Ограничение двигательной способности."
	end
	secNeurology:AddRow("Болевой синдром:", painStr, painColor, painDesc)

	-- Analgesia calculation
	local anVal = data.analgesia or 0
	local anStr, anColor, anDesc = "", Color(255, 255, 255), ""
	if anVal > 5 then
		anStr = "Глубокая анальгезия"
		anColor = COLORS.GREEN
		anDesc = "Боль полностью купирована сильными препаратами."
	elseif anVal > 1 then
		anStr = "Умеренное обезболивание"
		anColor = COLORS.GREEN
		anDesc = "Обезболивающие препараты действуют стабильно."
	elseif anVal > 0.1 then
		anStr = "Слабый эффект"
		anColor = COLORS.YELLOW
		anDesc = "Действие препарата заканчивается. Скоро вернется боль."
	else
		anStr = "Эффект отсутствует"
		anColor = COLORS.TEXT_DIM
		anDesc = "Обезболивающие вещества в организме отсутствуют."
	end
	secNeurology:AddRow("Обезболивание:", anStr, anColor, anDesc)

	-- 3. Кровотечения
	local secBleeding = addSection("Состояние сосудов и кровотечения")

	-- External bleed
	local bVal = data.bleed or 0
	local bStr, bColor, bDesc = "", Color(255, 255, 255), ""
	if bVal == 0 then
		bStr = "Отсутствует"
		bColor = COLORS.GREEN
		bDesc = "Внешних повреждений сосудов не обнаружено."
	elseif bVal < 0.05 then
		bStr = "Незначительное / Остановлено"
		bColor = COLORS.GREEN
		bDesc = "Капиллярное подтекание, кровь сворачивается."
	elseif bVal <= 1 then
		bStr = "Слабое кровотечение"
		bColor = COLORS.YELLOW
		bDesc = "Медленное венозное или капиллярное кровотечение. Требуется бинт."
	elseif bVal <= 4 then
		bStr = "Умеренное кровотечение"
		bColor = COLORS.ORANGE
		bDesc = "Активное венозное кровотечение. Срочно наложите жгут/повязку."
	elseif bVal <= 8 then
		bStr = "Сильное кровотечение"
		bColor = COLORS.RED
		bDesc = "Массивное кровотечение, обильная потеря крови."
	else
		bStr = "Критическое (Артериальное)"
		bColor = COLORS.RED
		bDesc = "Артериальное кровотечение! Пульсирующее излияние алой крови!"
	end
	secBleeding:AddRow("Наружное кровотечение:", bStr, bColor, bDesc)

	-- Internal bleed
	local ibVal = data.internalBleed or 0
	local ibStr, ibColor, ibDesc = "", Color(255, 255, 255), ""
	if ibVal == 0 then
		ibStr = "Отсутствует"
		ibColor = COLORS.GREEN
		ibDesc = "Внутренних кровоизлияний не обнаружено."
	elseif ibVal < 0.05 then
		ibStr = "Незначительное"
		ibColor = COLORS.GREEN
		ibDesc = "Мелкие подкожные гематомы."
	elseif ibVal <= 1 then
		ibStr = "Слабое внутреннее"
		ibColor = COLORS.YELLOW
		ibDesc = "Излияние крови в мягкие ткани. Образуются синяки."
	elseif ibVal <= 4 then
		ibStr = "Умеренное внутреннее"
		ibColor = COLORS.ORANGE
		ibDesc = "Скопление крови в брюшной или грудной полости."
	else
		ibStr = "Тяжелое внутреннее"
		ibColor = COLORS.RED
		ibDesc = "Массивное внутреннее кровотечение! Требуется хирургическая помощь."
	end
	secBleeding:AddRow("Внутреннее излияние:", ibStr, ibColor, ibDesc)

	-- 4. Опорно-двигательный аппарат
	local secTraumas = addSection("Опорно-двигательный аппарат")
	local hasTraumas = false

	-- Check legs fractures
	if data.lleg >= 1 then
		secTraumas:AddRow("Левая нога:", "Закрытый перелом", COLORS.RED, "Смещение кости голени/бедра левой ноги. Движение сильно затруднено.")
		hasTraumas = true
	elseif data.lleg > 0 then
		secTraumas:AddRow("Левая нога:", "Ушиб / Тупая травма", COLORS.YELLOW, "Сильный ушиб, растяжение мышц или трещина кости левой ноги.")
		hasTraumas = true
	end

	if data.rleg >= 1 then
		secTraumas:AddRow("Правая нога:", "Закрытый перелом", COLORS.RED, "Смещение кости голени/бедра правой ноги. Движение сильно затруднено.")
		hasTraumas = true
	elseif data.rleg > 0 then
		secTraumas:AddRow("Правая нога:", "Ушиб / Тупая травма", COLORS.YELLOW, "Сильный ушиб, растяжение мышц или трещина кости правой ноги.")
		hasTraumas = true
	end

	-- Check arms fractures
	if data.larm >= 1 then
		secTraumas:AddRow("Левая рука:", "Закрытый перелом", COLORS.RED, "Перелом лучевой/плечевой кости левой руки. Невозможно держать оружие.")
		hasTraumas = true
	elseif data.larm > 0 then
		secTraumas:AddRow("Левая рука:", "Ушиб / Тупая травма", COLORS.YELLOW, "Сильный ушиб или трещина кости левой руки.")
		hasTraumas = true
	end

	if data.rarm >= 1 then
		secTraumas:AddRow("Правая рука:", "Закрытый перелом", COLORS.RED, "Перелом лучевой/плечевой кости правой руки. Невозможно держать оружие.")
		hasTraumas = true
	elseif data.rarm > 0 then
		secTraumas:AddRow("Правая рука:", "Ушиб / Тупая травма", COLORS.YELLOW, "Сильный ушиб или трещина кости правой руки.")
		hasTraumas = true
	end

	-- Check dislocations
	if data.llegdislocation then
		secTraumas:AddRow("Сустав левой ноги:", "Вывих сустава", COLORS.ORANGE, "Смещение сустава левой ноги. Требуется вправление.")
		hasTraumas = true
	end
	if data.rlegdislocation then
		secTraumas:AddRow("Сустав правой ноги:", "Вывих сустава", COLORS.ORANGE, "Смещение сустава правой ноги. Требуется вправление.")
		hasTraumas = true
	end
	if data.larmdislocation then
		secTraumas:AddRow("Сустав левой руки:", "Вывих сустава", COLORS.ORANGE, "Смещение плечевого/локтевого сустава левой руки. Требуется вправление.")
		hasTraumas = true
	end
	if data.rarmdislocation then
		secTraumas:AddRow("Сустав правой руки:", "Вывих сустава", COLORS.ORANGE, "Смещение плечевого/локтевого сустава правой руки. Требуется вправление.")
		hasTraumas = true
	end
	if data.jawdislocation then
		secTraumas:AddRow("Нижняя челюсть:", "Вывих челюсти", COLORS.ORANGE, "Сустав челюсти смещен. Речь затруднена.")
		hasTraumas = true
	end

	-- Check spine & brain
	if data.spine1 >= 0.1 or data.spine2 >= 0.1 or data.spine3 >= 0.1 then
		secTraumas:AddRow("Позвоночник:", "Травма позвоночного столба", COLORS.RED, "Риск повреждения спинного мозга и паралича.")
		hasTraumas = true
	end
	if data.brain >= 0.1 then
		secTraumas:AddRow("Головной мозг:", "Черепно-мозговая травма", COLORS.ORANGE, "Сотрясение мозга, дезориентация и тошнота.")
		hasTraumas = true
	end

	if not hasTraumas then
		secTraumas:AddRow("Целостность скелета:", "Без повреждений", COLORS.GREEN, "Кости целы, суставы в норме. Патологий не обнаружено.")
	end

	-- 5. Открытые раны
	local secWounds = addSection("Открытые раны")
	local hasWounds = false

	if data.bulletwounds > 0 then
		secWounds:AddRow("Пулевые ранения:", "Активные раны: " .. data.bulletwounds, COLORS.RED, "Сквозные или слепые раневые каналы от огнестрельного оружия.")
		hasWounds = true
	end
	if data.stabwounds > 0 then
		secWounds:AddRow("Колотые раны:", "Активные раны: " .. data.stabwounds, COLORS.RED, "Узкие глубокие ранения, нанесенные колющим предметом.")
		hasWounds = true
	end
	if data.slashwounds > 0 then
		secWounds:AddRow("Резаные раны:", "Активные раны: " .. data.slashwounds, COLORS.RED, "Широкие поверхностные порезы от острого оружия.")
		hasWounds = true
	end
	if data.explosionwounds > 0 then
		secWounds:AddRow("Осколочные раны:", "Активные раны: " .. data.explosionwounds, COLORS.RED, "Множественные поражения от взрыва осколков.")
		hasWounds = true
	end
	if data.burns > 0 then
		secWounds:AddRow("Ожоги:", "Поражено эпидермиса: " .. math.Round(data.burns) .. "%", COLORS.ORANGE, "Термическое или химическое повреждение кожных покровов.")
		hasWounds = true
	end
	if data.bruises > 0 then
		secWounds:AddRow("Ушибы / Гематомы:", "Количество: " .. data.bruises, COLORS.YELLOW, "Подкожные излияния и ссадины от ударов тупыми предметами.")
		hasWounds = true
	end

	if not hasWounds then
		secWounds:AddRow("Кожные покровы:", "Чистые", COLORS.GREEN, "Открытых ран, ожогов и сильных гематом на теле не обнаружено.")
	end
end)

