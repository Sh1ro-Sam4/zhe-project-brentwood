include('shared.lua')

local color_white = Color(255, 255, 255)
local color_bg = Color(10, 10, 10, 220)
local color_accent = Color(46, 204, 113)
local color_hover = Color(52, 152, 219)

surface.CreateFont("RackFont_Large", {font = "Roboto", size = 48, weight = 800})
surface.CreateFont("RackFont_Small", {font = "Roboto", size = 28, weight = 500})


local slot_offsets = {
	[1] = Vector(-25, -70, 8),
	[2] = Vector(-25, -20, 8),
	[3] = Vector(25, -20, 8),
	[4] = Vector(25, -70, 8),
	[5] = Vector(-25, 70, 8),
	[6] = Vector(-25, 20, 8),
	[7] = Vector(25, 20, 8),
	[8] = Vector(25, 70, 8),
}

local custom_alignments = {
	["spawned_weapon"] = {
		offset = Vector(0, 0, -4),
		angle = Angle(0, 45, 90)
	},
	["chips"] = {
		offset = Vector(0, 0, -4),
		angle = Angle(0, 90, 0)
	},
	["rp_money_printer_pro"] = {
		offset = Vector(12, 12, 1),
		angle = Angle(0, 90, 0)
	},
}

function ENT:Initialize()
	self.CSModels = {}
end

function ENT:GetItemAlignment(item)
	if not item then return Vector(0,0,0), Angle(0,0,0) end

	local model = item:GetModel() or ""
	local class = item:GetClass() or ""

	if custom_alignments[model] then
		return custom_alignments[model].offset, custom_alignments[model].angle
	end

	if custom_alignments[class] then
		return custom_alignments[class].offset, custom_alignments[class].angle
	end

	if class == "spawned_weapon" or string.find(model, "weapons/w_") then
		return Vector(0, 0, -5), Angle(0, 45, 90)
	end

	return Vector(0, 0, 0), Angle(0, 0, 0)
end

function ENT:Draw()
	self:DrawModel()

	local conID = self:GetContainerID()
	local con = conID and itemstore.containers.Get(conID) or nil
	if not con then return end

	local tr = LocalPlayer():GetEyeTrace()
	local hovered_slot = nil
	if tr.Entity == self and tr.HitPos then
		local closest_dist = 22
		for i = 1, 8 do
			local item_world_pos = self:LocalToWorld(slot_offsets[i])
			local dist = tr.HitPos:Distance(item_world_pos)
			if dist < closest_dist then
				closest_dist = dist
				hovered_slot = i
			end
		end
	end

	for i = 1, 8 do
		local item = con:GetItem(i)

		if item then
			local model = item:GetModel() or "models/error.mdl"

			if not IsValid(self.CSModels[i]) then
				self.CSModels[i] = ClientsideModel(model)
				self.CSModels[i]:SetNoDraw(true)
			elseif self.CSModels[i]:GetModel() ~= model then
				self.CSModels[i]:SetModel(model)
			end

			local isHovered = (hovered_slot == i)
			
			local local_offset, local_angle = self:GetItemAlignment(item)

			local float_offset = isHovered and math.sin(CurTime() * 4 + i) * 1.5 or 0
			
			local pos = self:LocalToWorld(slot_offsets[i] + local_offset + Vector(0, 0, 0))
			local ang = self:LocalToWorldAngles(local_angle)

			self.CSModels[i]:SetPos(pos)
			self.CSModels[i]:SetAngles(ang)
			self.CSModels[i]:SetColor(item:GetColor() or color_white)
			self.CSModels[i]:SetMaterial(item:GetMaterial() or "")
			self.CSModels[i]:DrawModel()

			if isHovered then
				local textPos = pos + self:GetUp() * 10
				local textAng = LocalPlayer():EyeAngles()
				textAng:RotateAroundAxis(textAng:Forward(), 90)
				textAng:RotateAroundAxis(textAng:Right(), 90)

				local itemName = item:GetName() or "Товар"
				local price = item:GetData("ShopPrice")

				cam.Start3D2D(textPos, textAng, 0.05)
					surface.SetFont("RackFont_Large")
					local w, h = surface.GetTextSize(itemName)
					w = math.max(w, 200)

					draw.RoundedBox(8, -(w/2) - 15, -50, w + 30, 110, color_bg)

					draw.SimpleText(itemName, "RackFont_Large", 0, -22, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					if price then
						draw.SimpleText("$" .. string.Comma(price), "RackFont_Large", 0, 22, color_accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					else
						draw.SimpleText("Цена не указана", "RackFont_Small", 0, 22, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				cam.End3D2D()
			end
		else
			if IsValid(self.CSModels[i]) then
				self.CSModels[i]:Remove()
				self.CSModels[i] = nil
			end
		end
	end

	local dist = LocalPlayer():GetPos():DistToSqr(self:GetPos())
	if dist > 200000 then return end

	if not hovered_slot then
		local textPos = self:GetPos() + self:GetUp() * 15
		local textAng = LocalPlayer():EyeAngles()
		textAng:RotateAroundAxis(textAng:Forward(), 90)
		textAng:RotateAroundAxis(textAng:Right(), 90)

		cam.Start3D2D(textPos, textAng, 0.06)
			--draw.RoundedBox(8, -250, -35, 500, 70, color_bg)
			--draw.SimpleText("Стеллаж продаж", "RackFont_Large", 0, -12, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			--draw.SimpleText("Наведите взгляд на предмет, чтобы узнать цену", "RackFont_Small", 0, 18, color_hover, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end

function ENT:OnRemove()
	if self.CSModels then
		for i = 1, 8 do
			if IsValid(self.CSModels[i]) then
				self.CSModels[i]:Remove()
			end
		end
	end
end

net.Receive("Tokar_OpenMenu", function()
	local rack = net.ReadEntity()
	local isOwner = net.ReadBool()

	if not IsValid(rack) then return end

	local conID = rack:GetContainerID()
	local con = conID and itemstore.containers.Get(conID) or nil
	if not con then return end

	local frame = vgui.Create("DFrame")
	frame:SetSize(isOwner and 780 or 440, 480)
	frame:Center()
	frame:SetTitle(isOwner and "Панель управления стеллажом" or "Витрина товаров")
	frame:MakePopup()
	frame:SetSkin("itemstore")

	local leftPanel = vgui.Create("DPanel", frame)
	leftPanel:SetSize(410, 440)
	leftPanel:Dock(LEFT)
	leftPanel:DockPadding(10, 10, 10, 10)
	leftPanel.Paint = function(_, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20, 150))
	end

	local grid = vgui.Create("DGrid", leftPanel)
	grid:Dock(FILL)
	grid:SetCols(4)
	grid:SetColWide(95)
	grid:SetRowHeight(190)

	local selectedSlot = nil

	for i = 1, 8 do
		local slotBtn = vgui.Create("DButton")
		slotBtn:SetSize(90, 180)
		slotBtn:SetText("")
		
		local item = con:GetItem(i)

		if item then
			slotBtn.Paint = function(self, w, h)
				draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(40, 40, 40, 200) or Color(30, 30, 30, 180))
				draw.SimpleText("Слот #" .. i, "DermaDefault", w/2, 10, Color(150, 150, 150), TEXT_ALIGN_CENTER)
				
				local price = item:GetData("ShopPrice") or 0
				draw.SimpleText("$" .. string.Comma(price), "DermaDefaultBold", w/2, h - 20, color_accent, TEXT_ALIGN_CENTER)
			end

			local modelPreview = vgui.Create("DModelPanel", slotBtn)
			modelPreview:SetSize(80, 80)
			modelPreview:SetPos(5, 30)
			modelPreview:SetModel(item:GetModel() or "models/error.mdl")
			modelPreview:SetColor(item:GetColor() or color_white)
			modelPreview.Entity:SetMaterial(item:GetMaterial() or "")
			modelPreview:SetLookAt(Vector(0,0,0))
			modelPreview:SetCamPos(Vector(25,25,25))
			modelPreview.LayoutEntity = function() end

			local nameLabel = vgui.Create("DLabel", slotBtn)
			nameLabel:SetSize(80, 35)
			nameLabel:SetPos(5, 115)
			nameLabel:SetText(item:GetName() or "Товар")
			nameLabel:SetWrap(true)
			nameLabel:SetContentAlignment(5)

			slotBtn.DoClick = function()
				if isOwner then
					local menu = DermaMenu()
					menu:AddOption("Забрать предмет", function()
						net.Start("Tokar_TakeItem")
							net.WriteEntity(rack)
							net.WriteUInt(i, 8)
						net.SendToServer()
						frame:Close()
					end):SetIcon("icon16/arrow_undo.png")

					menu:AddOption("Изменить цену", function()
						Derma_StringRequest("Изменить цену", "Введите новую цену предмета ($):", item:GetData("ShopPrice") or "1000", function(priceStr)
							local price = tonumber(priceStr)
							if not price or price <= 0 then return end
							net.Start("Tokar_ChangePrice")
								net.WriteEntity(rack)
								net.WriteUInt(i, 8)
								net.WriteUInt(price, 32)
							net.SendToServer()
							frame:Close()
						end)
					end):SetIcon("icon16/pencil.png")
					menu:Open()
				else
					local price = item:GetData("ShopPrice") or 0
					Derma_Query("Вы действительно хотите купить " .. (item:GetName() or "этот предмет") .. " за $" .. string.Comma(price) .. "?", "Покупка товара",
						"Купить", function()
							net.Start("Tokar_BuyItem")
								net.WriteEntity(rack)
								net.WriteUInt(i, 8)
							net.SendToServer()
							frame:Close()
						end,
						"Отмена", function() end
					)
				end
			end
		else
			slotBtn.Paint = function(self, w, h)
				local borderCol = (selectedSlot == i) and color_hover or Color(50, 50, 50, 100)
				draw.RoundedBox(6, 0, 0, w, h, Color(15, 15, 15, 150))
				
				surface.SetDrawColor(borderCol)
				surface.DrawOutlinedRect(0, 0, w, h, 2)

				draw.SimpleText("Слот #" .. i, "DermaDefault", w/2, 15, Color(100, 100, 100), TEXT_ALIGN_CENTER)
				draw.SimpleText(isOwner and "+ Пусто" or "Пусто", "DermaDefault", w/2, h/2, Color(100, 100, 100), TEXT_ALIGN_CENTER)
			end

			if isOwner then
				slotBtn.DoClick = function()
					selectedSlot = i
					chat.AddText(color_hover, "[Стеллаж] Вы выбрали слот #" .. i .. ". Теперь выберите предмет из списка справа!")
				end
			end
		end

		grid:AddItem(slotBtn)
	end

	if isOwner then
		local rightPanel = vgui.Create("DPanel", frame)
		rightPanel:SetSize(340, 440)
		rightPanel:Dock(RIGHT)
		rightPanel:DockPadding(10, 10, 10, 10)
		rightPanel.Paint = function(_, w, h)
			draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20, 150))
		end

		local invTitle = vgui.Create("DLabel", rightPanel)
		invTitle:Dock(TOP)
		invTitle:SetFont("DermaDefaultBold")
		invTitle:SetText("Ваш личный инвентарь:")
		invTitle:SetTall(20)

		local list = vgui.Create("DListView", rightPanel)
		list:Dock(FILL)
		list:AddColumn("Слот"):SetFixedWidth(45)
		list:AddColumn("Название предмета")

		local invID = LocalPlayer().InventoryID
		local inv = invID and itemstore.containers.Get(invID) or nil
		
		local hasItems = false
		if inv then
			for slot, item in pairs(inv:GetItems()) do
				if item then
					hasItems = true
					local name = item:GetName() or item:GetClass()
					list:AddLine(slot, name).SlotID = slot
				end
			end
		end

		if not hasItems then
			local line = list:AddLine("", "Инвентарь не синхронизирован!")
			line:SetDisabled(true)
			list:AddLine("", "Откройте инвентарь на /inv один раз,")
			list:AddLine("", "чтобы прогрузить список предметов.")
		end

		local putBtn = vgui.Create("DButton", rightPanel)
		putBtn:Dock(BOTTOM)
		putBtn:SetTall(35)
		putBtn:SetText("Выставить на выбранный слот")
		putBtn.DoClick = function()
			if not selectedSlot then
				Derma_Message("Сначала выберите пустой слот слева (он подсветится синей рамкой)!", "Внимание", "ОК")
				return
			end

			local selectedLine = list:GetSelectedLine()
			if not selectedLine then
				Derma_Message("Выберите предмет из вашего инвентаря в списке выше!", "Внимание", "ОК")
				return
			end

			local invSlot = list:GetLine(selectedLine).SlotID
			if not invSlot then return end

			Derma_StringRequest("Вывешивание товара", "Укажите цену для продажи товара ($):", "1000", function(priceStr)
				local price = tonumber(priceStr)
				if not price or price <= 0 then return end

				net.Start("Tokar_PutItem")
					net.WriteEntity(rack)
					net.WriteUInt(selectedSlot, 8)
					net.WriteUInt(invSlot, 16)
					net.WriteUInt(price, 32)
				net.SendToServer()

				frame:Close()
			end)
		end
	end
end)