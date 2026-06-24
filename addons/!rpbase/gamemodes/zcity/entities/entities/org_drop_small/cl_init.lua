include('shared.lua')

local color_bg = Color(6, 12, 8, 245)
local color_main = Color(0, 255, 60)
local color_dark_green = Color(0, 80, 25)
local color_red = Color(255, 40, 40)
local color_dark_red = Color(100, 15, 15)
local color_yellow = Color(255, 200, 0)
local color_white = Color(255, 255, 255)
local color_gray = Color(120, 140, 120)

surface.CreateFont('Term_Huge', {font = "Hitmarker Normal", size = 50, weight = 300, scanlines = 2, antialias = true})
surface.CreateFont('Term_Header', {font = "Hitmarker Normal", size = 32, weight = 300, scanlines = 2, antialias = true})
surface.CreateFont('Term_Main', {font = "Hitmarker Normal", size = 22, weight = 300, scanlines = 2, antialias = true})
surface.CreateFont('Term_Small', {font = "Hitmarker Normal", size = 16, weight = 300, scanlines = 2, antialias = true})

local function DrawTerminalFrame(x, y, w, h, isPowered, shake)
	local dx = shake > 0.3 and math.random(-3, 3) or 0
	x = x + dx

	draw.RoundedBox(0, x, y, w, h, color_bg)
    
	local mainCol = isPowered and color_main or color_dark_red
	local frameCol = isPowered and color_dark_green or color_dark_red

	surface.SetDrawColor(mainCol.r, mainCol.g, mainCol.b, 8)
	for i = 0, h, 20 do surface.DrawRect(x, y + i, w, 1) end
	for i = 0, w, 20 do surface.DrawRect(x + i, y, 1, h) end

	surface.SetDrawColor(frameCol)
	surface.DrawOutlinedRect(x + 2, y + 2, w - 4, h - 4, 1)
    
	local cl = 30 
	local th = 3
	surface.SetDrawColor(mainCol)
	surface.DrawRect(x + 2, y + 2, cl, th) surface.DrawRect(x + 2, y + 2, th, cl)
	surface.DrawRect(x + w - cl - 2, y + 2, cl, th) surface.DrawRect(x + w - th - 2, y + 2, th, cl)
	surface.DrawRect(x + 2, y + h - th - 2, cl, th) surface.DrawRect(x + 2, y + h - cl - 2, th, cl)
	surface.DrawRect(x + w - cl - 2, y + h - th - 2, cl, th) surface.DrawRect(x + w - th - 2, y + h - cl - 2, th, cl)
end

local function DrawHackerButton(cx, cy, x, y, w, h, text, colMain, colHover, isDown)
	local isHovered = cx >= x and cx <= x + w and cy >= y and cy <= y + h
	local drawCol = isHovered and colHover or colMain
    
	local p = (isHovered and isDown) and 2 or 0
	x = x + p
	y = y + p
	w = w - p * 2
	h = h - p * 2

	surface.SetDrawColor(0, 0, 0, 180)
	surface.DrawRect(x, y, w, h)
    
	if isHovered then
		surface.SetDrawColor(drawCol.r, drawCol.g, drawCol.b, 25)
		surface.DrawRect(x, y, w, h)
	end
    
	surface.SetDrawColor(drawCol.r, drawCol.g, drawCol.b, 80)
	surface.DrawOutlinedRect(x, y, w, h, 1)
    
	surface.SetDrawColor(drawCol)
	local cl = 12
	local th = 2
	surface.DrawRect(x, y, cl, th) surface.DrawRect(x, y, th, cl)
	surface.DrawRect(x + w - cl, y, cl, th) surface.DrawRect(x + w - th, y, th, cl)
	surface.DrawRect(x, y + h - th, cl, th) surface.DrawRect(x, y + h - cl, th, cl)
	surface.DrawRect(x + w - cl, y + h - th, cl, th) surface.DrawRect(x + w - th, y + h - cl, th, cl)
    
	local txtPrefix = isHovered and "> " or ""
	local txtSuffix = isHovered and " <" or ""
	draw.SimpleText(txtPrefix .. text .. txtSuffix, "Term_Main", x + w/2, y + h/2 - 1, drawCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
	return isHovered
end

function ENT:Draw()
	self:DrawModel()

	local ply = LocalPlayer()
	if ply:GetPos():DistToSqr(self:GetPos()) > 250000 then return end

	local attachment = self:GetAttachment(2)
	if not attachment then return end

	local screenW, screenH = 615, 368 
	local x, y = -(screenW / 128), -(screenH / 64) 

	local pos = self:GetPos()
	local ang = self:GetAngles()

	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 70)
    
	local scale = 0.035
	local camOrigin = pos + ang:Up() * 21.1 + ang:Forward() * 14.5 - ang:Right() * 53.3
    
	self.LastLevel = self.LastLevel or self:GetLevel()
	self.GlitchForce = self.GlitchForce or 0

	if self:GetLevel() ~= self.LastLevel then
		self.GlitchForce = 1.0
		self.LastLevel = self:GetLevel()
	end

	self.GlitchForce = math.Approach(self.GlitchForce, 0, FrameTime() * 2.5)

	local activeShake = self.GlitchForce
	if self.NextClick and self.NextClick > CurTime() then
		local diff = self.NextClick - CurTime()
		if diff > 0.1 then
			activeShake = math.max(activeShake, diff * 1.5)
		end
	end

	local cursorX, cursorY = -1, -1
	
	local eyePos = hg and hg.eye and hg.eye(ply) or ply:EyePos()
	local traceHit = util.IntersectRayWithPlane(eyePos, ply:GetAimVector(), camOrigin, ang:Up())
    
	if traceHit then
		local hitDir = traceHit - eyePos
		if hitDir:Dot(ply:GetAimVector()) > 0 then
			local diff = traceHit - camOrigin
			cursorX = diff:Dot(ang:Forward()) / scale
			cursorY = diff:Dot(ang:Right()) / scale
		end
	end

	local isDown = ply:KeyDown(IN_USE) or ply:KeyDown(IN_ATTACK)
	local isClicked = false
	local inRange = ply:GetPos():DistToSqr(pos) < 15000
    
	if isDown then
		if not self.ButtonDown then
			if inRange then isClicked = true end
			self.ButtonDown = true
		end
	else
		self.ButtonDown = false
	end

	local clickMain = isClicked and not self.ConfirmSell
	local mainCursorX = self.ConfirmSell and -1 or cursorX
	local mainCursorY = self.ConfirmSell and -1 or cursorY

	cam.Start3D2D(camOrigin, ang, scale)
        
		local isPowered = self:GetIsPowered()
		DrawTerminalFrame(x, y, screenW, screenH, isPowered, activeShake)

		local ownerText = "UNKNOWN"
		local ownerColor = color_gray
		--self:SetORGIANAME("FEMBOY")
		--self:SetORGIACOLOR(Color(255,127,223))
		--if IsValid(self:CPPIGetOwner()) and self:CPPIGetOwner().GetOrg then
			ownerText = self:GetORGIANAME()
			ownerColor = color_main
		--end

		local blink = math.floor(CurTime() * 2) % 2 == 0 and "_" or ""

		draw.SimpleText("SYS: IMP-OS2-IG-42Y", "Term_Main", x + 20, y + 15, isPowered and color_main or color_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("ORG: " .. ownerText, "Term_Main", x + 20, y + 35, isPowered and ownerColor or color_dark_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("INTEGRITY: " .. self:GetHP(), "Term_Main", x + 20, y + 55, isPowered and ownerColor or color_dark_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		local sellW, sellH = 140, 35
		local sellX = x + screenW - sellW - 20
		local sellY = y + 15
		if DrawHackerButton(mainCursorX, mainCursorY, sellX, sellY, sellW, sellH, "SELL UNIT", color_dark_red, color_red, isDown) and clickMain and inRange then
			if not self.NextClick or CurTime() > self.NextClick then
				self.NextClick = CurTime() + 0.3
				self.ConfirmSell = true
			end
		end

		surface.SetDrawColor(isPowered and color_dark_green or color_dark_red)
		surface.DrawLine(x + 15, y + 60, x + screenW - 15, y + 60)

		local currentLevel = self:GetLevel() or 1
		local maxLevel = 16

		if not isPowered then
			draw.SimpleText("SYSTEM OFFLINE", "Term_Huge", x + screenW/2, y + 130, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("AWAITING BOOT SEQUENCE" .. blink, "Term_Main", x + screenW/2, y + 170, color_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			local btnW, btnH = 280, 45
			local btnX = x + (screenW/2) - (btnW/2)
			if DrawHackerButton(mainCursorX, mainCursorY, btnX, y + 220, btnW, btnH, "BOOT SYSTEM", color_red, color_white, isDown) and clickMain and inRange then
				if not self.NextClick or CurTime() > self.NextClick then
					self.NextClick = CurTime() + 0.3
					net.Start("Terminal_Toggle_Power")
					net.WriteEntity(self)
					net.SendToServer()
				end
			end
		else
			local rateHr = 0.01 * currentLevel
			local rateMin = rateHr / 60
			local rateSec = rateHr / 3600
			local currentBank = self:GetBank()

			draw.SimpleText("DATABANK BALANCE", "Term_Main", x + screenW/2, y + 85, color_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(string.format("%.6f PTS", currentBank), "Term_Huge", x + screenW/2, y + 125, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			draw.SimpleText(string.format("RATE: %.2f/HR | %.4f/MIN | %.6f/SEC", rateHr, rateMin, rateSec), "Term_Small", x + screenW/2, y + 165, color_yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("LEVEL: " .. currentLevel .. " / " .. maxLevel .. "   ||   STATUS: ACTIVE" .. blink, "Term_Small", x + screenW/2, y + 185, color_main, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("The upgrade price is $75,000", "Term_Small", x + screenW/2, y + 205, color_main, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			local btnW, btnH = 200, 40
			local spacingX = 20
			local btnY1 = y + 220
			local btnY2 = y + 270

			local btnX1 = x + screenW/2 - btnW - (spacingX/2)
			if currentLevel >= maxLevel then
				DrawHackerButton(mainCursorX, mainCursorY, btnX1, btnY1, btnW, btnH, "MAX LEVEL", color_dark_red, color_dark_red, false)
			else
				if DrawHackerButton(mainCursorX, mainCursorY, btnX1, btnY1, btnW, btnH, "UPGRADE SYSTEM", color_yellow, color_white, isDown) and clickMain and inRange then
					if not self.NextClick or CurTime() > self.NextClick then
						self.NextClick = CurTime() + 0.3
						net.Start("Terminal_Upgrade_Rack")
						net.WriteEntity(self)
						net.SendToServer()
					end
				end
			end

			local btnX2 = x + screenW/2 + (spacingX/2)
			if DrawHackerButton(mainCursorX, mainCursorY, btnX2, btnY1, btnW, btnH, "COLLECT POINTS", color_main, color_white, isDown) and clickMain and inRange then
				if not self.NextClick or CurTime() > self.NextClick then
					self.NextClick = CurTime() + 0.3
					net.Start("Terminal_Collect_Bank")
					net.WriteEntity(self)
					net.SendToServer()
				end
			end

			local btnW_full = btnW * 2 + spacingX
			if DrawHackerButton(mainCursorX, mainCursorY, btnX1, btnY2, btnW_full, btnH, "SHUTDOWN SYSTEM", color_dark_green, color_red, isDown) and clickMain and inRange then
				if not self.NextClick or CurTime() > self.NextClick then
					self.NextClick = CurTime() + 0.3
					net.Start("Terminal_Toggle_Power")
					net.WriteEntity(self)
					net.SendToServer()
				end
			end
		end

		if self.ConfirmSell then
			surface.SetDrawColor(0, 0, 0, 235)
			surface.DrawRect(x, y, screenW, screenH)

			local mw, mh = 420, 200
			local mx, my = x + screenW/2 - mw/2, y + screenH/2 - mh/2

			surface.SetDrawColor(color_dark_red.r, color_dark_red.g, color_dark_red.b, 60)
			surface.DrawRect(mx, my, mw, mh)
			
			surface.SetDrawColor(color_red)
			surface.DrawOutlinedRect(mx, my, mw, mh, 2)

			draw.SimpleText("WARNING", "Term_Header", mx + mw/2, my + 35, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("ARE YOU SURE YOU WANT TO SELL THIS UNIT?", "Term_Small", mx + mw/2, my + 75, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("ALL STORED DATABANK POINTS WILL BE LOST!", "Term_Small", mx + mw/2, my + 95, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Сashback : " ..  self:GetLevel() * 10000 + 50000 .. "$", "Term_Small", mx + mw/2, my + 115, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			local bw, bh = 160, 45
			if DrawHackerButton(cursorX, cursorY, mx + 30, my + 130, bw, bh, "CONFIRM", color_dark_red, color_red, isDown) and isClicked and inRange then
				if not self.NextClick or CurTime() > self.NextClick then
					self.NextClick = CurTime() + 0.3
					self.ConfirmSell = false
					net.Start("Terminal_Sell_Rack")
					net.WriteEntity(self)
					net.SendToServer()
				end
			end

			if DrawHackerButton(cursorX, cursorY, mx + mw - bw - 30, my + 130, bw, bh, "CANCEL", color_dark_green, color_main, isDown) and isClicked and inRange then
				if not self.NextClick or CurTime() > self.NextClick then
					self.NextClick = CurTime() + 0.3
					self.ConfirmSell = false
				end
			end
		end

		if inRange and cursorX > x and cursorX < x + screenW and cursorY > y and cursorY < y + screenH then
			local cCol = (self.ConfirmSell or not isPowered) and color_red or color_main
			surface.SetDrawColor(cCol)
			
			surface.DrawRect(cursorX - 1, cursorY - 1, 2, 2)
			
			surface.DrawRect(cursorX - 8, cursorY, 4, 1)
			surface.DrawRect(cursorX + 5, cursorY, 4, 1)
			surface.DrawRect(cursorX, cursorY - 8, 1, 4)
			surface.DrawRect(cursorX, cursorY + 5, 1, 4)
		end

		local randCode1 = "0x" .. string.format("%04X", math.random(1000, 9999))
		local randCode2 = "0x" .. string.format("%04X", math.random(1000, 9999))
		local bottomCol = (self.ConfirmSell or not isPowered) and color_dark_red or color_dark_green

		surface.SetDrawColor(bottomCol)
		surface.DrawLine(x + 15, y + screenH - 35, x + screenW - 15, y + screenH - 35)

		draw.SimpleText(randCode1, "Term_Small", x + 15, y + screenH - 28, bottomCol)
		draw.SimpleText(randCode2, "Term_Small", x + screenW - 15, y + screenH - 28, bottomCol, TEXT_ALIGN_RIGHT)

		if activeShake > 0.05 then
			for i = 1, math.random(1, 3) do
				local gH = math.random(1, 4)
				local gY = y + math.random(2, screenH - gH - 2)
				local gA = math.min(60, activeShake * 120)
				
				surface.SetDrawColor(color_main.r, color_main.g, color_main.b, gA)
				surface.DrawRect(x + 2, gY, screenW - 4, gH)
				
				if math.random() > 0.6 then
					surface.SetDrawColor(255, 255, 255, gA * 0.5)
					surface.DrawRect(x + 2, gY + math.random(-5, 5), screenW - 4, 1)
				end
			end
		end

	cam.End3D2D()
end