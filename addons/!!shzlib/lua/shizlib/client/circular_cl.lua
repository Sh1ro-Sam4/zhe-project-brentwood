local function ease(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end

surface.CreateFont('shizlib.use-normal', {
	font = 'Calibri',
	extended = true,
	size = 27,
	weight = 350,
})
surface.CreateFont('shizlib.use-normal-sh', {
	font = 'Calibri',
	extended = true,
	size = 27,
	blursize = 5,
	weight = 350,
})

local function drawText(text, font, x, y, xal, yal, col, shCol)
	draw.Text {
		text = text,
		font = font .. '-sh',
		pos = { x, y + 2 },
		xalign = xal,
		yalign = yal,
		color = shCol,
	}

	draw.Text {
		text = text,
		font = font,
		pos = { x, y },
		xalign = xal,
		yalign = yal,
		color = col,
	}
end

function shizlib.circularMenu(opts)
	local colors = (CFG and CFG.theme) or {
		bg = Color(35, 35, 35),
		accent = Color(255, 100, 0)
	}

	local buts = shizlib.table.mapSequential(opts, function(v)
		v[1] = v[1] or 'Действие'
		v[2] = v[2] or 'shizlib/icon17/64/can.png'
		v[3] = v[3] or function() end

		return {
			text = markup.Parse('<font=shizlib.use-normal><color=238,238,238>' .. v[1] .. '</color></font>', 250),
			textSh = markup.Parse('<font=shizlib.use-normal-sh><color=0,0,0>' .. v[1] .. '</color></font>', 250),
			icon = Material(v[2], ''),
			anim = 0,
			action = v[3],
		}
	end)

	local butsNum = #buts
	local butSize = math.pi * 2 / butsNum
	local segsPerBut = math.ceil(80 / butsNum)

	local polysBut = {}
	for i = 1, butsNum do
		local ang2 = butSize * (i - 1) + math.pi / 2
		polysBut[i] = {}
		for i2 = 0, segsPerBut do
			polysBut[i][i2] = -i2 / segsPerBut * butSize - ang2
		end
	end

	if IsValid(shizlib.usePnl) then
		shizlib.usePnl:Remove()
	end

	local p = vgui.Create('DFrame')
	p:SetSize(ScrW(), ScrH())
	p:SetPos(0, 0)
	p:SetMouseInputEnabled(false)
	p:SetKeyboardInputEnabled(false)
	p:SetDraggable(false)
	p:ShowCloseButton(false)
	p:SetTitle('')
	p:SetZPos(999)
	shizlib.usePnl = p

	p.al = 0
	p.mx = 0
	p.my = 0
	p.active = true
	p.wasPressing2 = true

	p.Paint = function(self, w, h)
		local st = ease(self.al, 0, 1, 1)
		local cx, cy = w / 2, h / 2

		draw.NoTexture()
		surface.SetDrawColor(35, 35, 35, st * 150)

		if st > 0 then
			for i = 1, butsNum do
				local st2 = buts[i].anim
				local arcW = 100
				local bgcol = Color(colors.bg.r / 2, colors.bg.g / 2, colors.bg.b / 2, 180 * st + 70 * st2)
				local wcol = Color(180 + 75 * st2, 180 + 75 * st2, 180 + 75 * st2, 100 * st + 150 * st2)

				draw.NoTexture()

				for i2 = 1, segsPerBut do
					local r1, r2 = 250 * st, math.max(250 * st - arcW, 0)
					local v1, v2 = polysBut[i][i2 - 1], polysBut[i][i2]
					local c1, c2 = math.cos(v1), math.cos(v2)
					local s1, s2 = math.sin(v1), math.sin(v2)

					surface.SetDrawColor(bgcol.r, bgcol.g, bgcol.b, bgcol.a)
					surface.DrawPoly({
						{ x = cx + c1 * r2, y = cy - s1 * r2 },
						{ x = cx + c1 * r1, y = cy - s1 * r1 },
						{ x = cx + c2 * r1, y = cy - s2 * r1 },
						{ x = cx + c2 * r2, y = cy - s2 * r2 },
					})

					if st2 ~= 0 then
						local r3 = r2 - st2 * 5
						surface.SetDrawColor(colors.accent)
						surface.DrawPoly({
							{ x = cx + c1 * r3, y = cy - s1 * r3 },
							{ x = cx + c1 * r2, y = cy - s1 * r2 },
							{ x = cx + c2 * r2, y = cy - s2 * r2 },
							{ x = cx + c2 * r3, y = cy - s2 * r3 },
						})
					end
				end

				local iconSize = 64
				local v = butSize * (i - 0.5) + math.pi / 2
				local c, s = math.cos(v), math.sin(v)
				surface.SetMaterial(buts[i].icon)
				surface.SetDrawColor(wcol.r, wcol.g, wcol.b, wcol.a)
				surface.DrawTexturedRect(
					cx + c * 198 * st - iconSize / 2,
					cy + s * 198 * st - iconSize / 2,
					iconSize,
					iconSize
				)
			end

			if self.selected ~= 0 then
				buts[self.selected].textSh:Draw(w / 2, h / 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 255 * self.al)
				buts[self.selected].text:Draw(w / 2, h / 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 255 * self.al)
			end

			local col1, col2 = Color(238, 238, 238, 255 * self.al), Color(0, 0, 0, 255 * self.al)
			drawText('ЛКМ - выбрать', 'shizlib.use-normal', w - 15, h - 35, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, col1, col2)
			drawText('ПКМ - отменить', 'shizlib.use-normal', w - 15, h - 10, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, col1, col2)
		end
	end

	p.Think = function(self)
		local selected = 0
		if self.al > 0 then
			if self.mx^2 + self.my^2 > 4000 then
				local tan = math.atan2(self.my, self.mx) + math.pi / 2
				tan = tan > math.pi and tan - 2 * math.pi or tan
				local ang = (tan / math.pi + 1) / 2
				local butSizeRel = 1 / butsNum
				selected = math.Round((ang + butSizeRel / 2) * butsNum)
			end
		end
		self.selected = math.Clamp(selected, 0, butsNum)

		self.al = math.Approach(self.al, self.active and 1 or 0, FrameTime() / 0.3)
		for i = 1, #buts do
			if self.selected == i and self.active then
				buts[i].anim = math.Approach(buts[i].anim, 1, FrameTime() / 0.1)
			else
				buts[i].anim = math.Approach(buts[i].anim, 0, FrameTime() / 0.2)
			end
		end

		if self.active and gui.IsGameUIVisible() then
			gui.HideGameUI()
			self.close()
		end
	end

	p.open = function(self)
		self.active = true
		self.mx = 0
		self.my = 0
	end

	p.close = function(self)
		p.active = false
		timer.Simple(1, function()
			if IsValid(p) then
				p:Remove()
			end
		end)
	end

	hook.Add('InputMouseApply', p, function(self, cmd, x, y, ang)
		if self.active then
			if x ~= 0 or y ~= 0 then
				local v = Vector(self.mx + x, self.my + y, 0)
				if v:LengthSqr() > 10000 then
					v = v:GetNormalized() * 100
				end

				self.mx = v.x
				self.my = v.y
			end

			cmd:SetMouseX(0)
			cmd:SetMouseY(0)

			return true
		end
	end)

	hook.Add('CreateMove', p, function(self, cmd)
		if self.active then
			if cmd:KeyDown(IN_ATTACK) then
				if self.selected and self.selected ~= 0 then
					if CFG and CFG.skinSound and CFG.skinSound.press then
						surface.PlaySound(CFG.skinSound.press)
					end
					buts[self.selected].action()
				end
				self.close()
			end

			if not self.wasPressing2 then
				if cmd:KeyDown(IN_ATTACK2) then
					self.close()
				end
			end
			self.wasPressing2 = cmd:KeyDown(IN_ATTACK2)
			cmd:RemoveKey(IN_ATTACK)
			cmd:RemoveKey(IN_ATTACK2)
		end
	end)

	p:open()
end