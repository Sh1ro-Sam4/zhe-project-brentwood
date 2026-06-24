include('shared.lua')
local color_white = Color(255,255,255)
local color_black = Color(0,0,0)
local color_bg = Color(10,10,10)

local ang = Angle(0, 90, 90)

local draw_SimpleText 			= draw.SimpleText
local draw_Box 					= draw.Box
local draw_RoundedBox 			= draw.RoundedBox
local cam_Start3D2D 			= cam.Start3D2D
local cam_End3D2D 				= cam.End3D2D
local math_Clamp 				= math.Clamp
local math_Round 				= math.Round
local CurTime 					= CurTime
local IsValid 					= IsValid

local complex_off = Vector(0, 0, 12)

local function predict(timeValue, value)
	return math_Clamp(math_Round((CurTime() - timeValue)/value, 2), 0, 1)
end
local last_taker = nil

local orgs_in_zone = {}

function ENT:Think()
	
	--for k,v in pairs(ents.FindInBox(Vector(2483, 3000, -169), Vector(1847, 3417, 201))) do
	--	
	--end
	--if !self:GetPos():WithinAABox(Vector(1681, -2307, -97), Vector(1220, -1560, 421)) then
	--	self:Remove()
	--end
	orgs_in_zone = {}

	for k,v in pairs(ents.FindInSphere(self:GetPos(), 100)) do
		if v:IsPlayer() and v:Alive() and v:GetOrg() != nil and !IsGov(v:GetPlayerClass()) then
			--if !table.HasValue(orgs_in_zone,v:GetOrg()) then
			--	local orgia = {
			--		name = v:GetOrg(),
			--		color = v:GetOrgColor()
			--	}
			--	table.insert(orgs_in_zone,orgia)
			--end
			local have = false
			for k,v2 in pairs(orgs_in_zone) do
				if v2.name == v:GetOrg() then
					have = true
				end
			end
			if !have then
				local orgia = {
					name = v:GetOrg(),
					color = v:GetOrgColor()
				}
				table.insert(orgs_in_zone,orgia)
			end
			--table.insert(orgs_in_zone,v)
		end
	end

	self:NextThink( CurTime() + 1 )

	return true
end

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos() + complex_off
	ang.y = (LocalPlayer():EyeAngles().y - 90)

	local dist = LocalPlayer():GetPos():Distance(self:GetPos())
    local inView = dist <= 150000

    if (not inView) then return end

	color_white.a = 255 - (dist/500)
	color_black.a = color_white.a

	local x = math.sin(CurTime() * math.pi) * 30

	    -- if ragowner and ragowner:IsPlayer() and ragowner:GetOrg() then
		--    local org = ragowner:GetOrg() or ''
		--    local orgcol = ragowner:GetOrgColor() or color_white
        --    orgcol.a = 255 * Size * 1.5
        --    draw.SimpleTextOutlined(org, "HomigradFontLarge", x, y + 100, orgcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, .6, color_black)
		--end

	if table.Count(orgs_in_zone) == 1 then
		--self:SetLastTake(CurTime())
		--if last_taker == orgs_in_zone[1].name then
		if last_taker == orgs_in_zone[1].name then
			if !timer.Exists("SelfLifeTime_"..self:EntIndex()) then
				timer.Create("SelfLifeTime_"..self:EntIndex(), 120, 1, function()
				end)
			end
		else
			timer.Remove("SelfLifeTime_"..self:EntIndex())
		end
		last_taker = orgs_in_zone[1].name
	else
		timer.Remove("SelfLifeTime_"..self:EntIndex())
		last_taker = nil
	end

	cam.Start3D2D((pos + self:GetForward() ), ang, 0.03)
		
		if true then
			local new_x = x - 2950
			draw.SimpleTextOutlined('Я ЯЩИК И СЕЙЧАС У МЕНЯ НЕТ НАСТРОЕНИЯ КОМУ ТО ЧТО ТО ДАВАТЬ!!!', '3d2d', 0, new_x, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
			--continue 
		else
		
		local new_x = x - 2950
		draw.SimpleTextOutlined('Ящик с очками организации', '3d2d', 0, new_x, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		local looted = false
		for k,v in pairs(orgs_in_zone) do
			new_x = new_x - 100
			draw.SimpleTextOutlined(v.name or '', '3d2d', 0, new_x, v.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
			looted = true
		end
		if looted then
			new_x = new_x - 100
			draw.SimpleTextOutlined('Пытаются залутать', '3d2d', 0, new_x, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		end
		new_x = new_x - 100
		if timer.Exists("SelfLifeTime_"..self:EntIndex()) then
			--math.Round(timer.TimeLeft("SelfLifeTime_"..self:EntIndex())) or ""
			draw.SimpleTextOutlined('Организация '.. orgs_in_zone[1].name .. " Получит очки через : " .. math.Round(timer.TimeLeft("SelfLifeTime_"..self:EntIndex())), '3d2d', 0, new_x, Color(143,255,121), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		else
			if table.Count(orgs_in_zone) != 0 then
				draw.SimpleTextOutlined('Несколько организаций одновременно не могут лутать очки', '3d2d', 0, new_x, Color(255,121,121), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
			end
		end
		end
	cam.End3D2D()

end