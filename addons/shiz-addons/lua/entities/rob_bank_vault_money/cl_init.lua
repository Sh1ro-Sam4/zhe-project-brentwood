include("shared.lua")
-- include("autorun/shared/bank_config.lua")
local restrictedIcon = Material("icon16/cancel.png", "unlitgeneric")

surface.CreateFont("bank_3d2d", {
	font = "DermaLarge",
	size = BANK_CONFIG.BankStringSize
})

local playerGA = player.GetAll
local musara = {}
local i = 0
timer.Create('cachevault', 5, 0, function()
	-- musara = table.Filter(playerGA(), function(pl) return pl:isCP()
	musara = {}
	for _, ply in player.Iterator() do
		if IsGov(ply:GetPlayerClass()) then
			table.insert(musara, i, ply)
			i = i + 1
		end
	end
end)

local function isAllowedToRob()
	local cops = 0

	for k, v in pairs(musara) do
		cops = cops + 1
	end

	return cops >= BANK_CONFIG.MinCopJobs, cops
end

local g_grds, g_wgrd, g_sz
function draw.GradientBox(x, y, w, h, al, ...)
	g_grds = {...}
	al = math.Clamp(math.floor(al), 0, 1)
	if(al == 1) then
		local t = w
		w, h = h, t
	end
	g_wgrd = w / (#g_grds - 1)
	local n
	//76561198092742034
	for i = 1, w do
		for c = 1, #g_grds do
			n = c
			if(i <= g_wgrd * c) then break end
		end
		g_sz = i - (g_wgrd * (n - 1))
		surface.SetDrawColor(
			Lerp(g_sz/g_wgrd, g_grds[n].r, g_grds[n + 1].r),
			Lerp(g_sz/g_wgrd, g_grds[n].g, g_grds[n + 1].g),
			Lerp(g_sz/g_wgrd, g_grds[n].b, g_grds[n + 1].b),
			Lerp(g_sz/g_wgrd, g_grds[n].a, g_grds[n + 1].a))
		if(al == 1) then surface.DrawRect(x, y + i, h, 1)
		else surface.DrawRect(x + i, y, 1, h) end
	end
end

local function paintBar(x, y, w, h, border, color, value)
	local darkColor = Color(color.r / 1.8, color.g / 1.8, color.b / 1.8)

	local emptyColor = Color(color.r * 0.6, color.g * 0.6, color.b * 0.6)
	local darkEmptyColor = Color(emptyColor.r / 1.8, emptyColor.g / 1.8, emptyColor.b / 1.8)

	surface.SetDrawColor(border)
	surface.DrawOutlinedRect(x, y, w, h)

	x = x + 1
	y = y + 1
	w = w - 2
	h = h - 2

	surface.SetDrawColor(emptyColor)
	surface.DrawRect(x, y, w, h / 2)

	draw.GradientBox(x, y + h / 2 - 1, w, h / 2, 1, emptyColor, darkEmptyColor)

	local width = w * math.Clamp(value, 0, 1)

	surface.SetDrawColor(color)
	surface.DrawRect(x, y, width, h / 2)

	draw.GradientBox(x, y + h / 2 - 1, width, h / 2, 1, color, darkColor)
end

ENT.smooth = 0
ENT.progressSmooth = 0

local function jobCanRob()
	-- if(table.Count(BANK_CONFIG.AllowedJobs) > 0) || LocalPlayer():isCP() then
	-- 	if(!BANK_CONFIG.AllowedJobs[team.GetName(LocalPlayer():Team())]) then
	-- 		return false //76561198092742034
	-- 	else return true end
	-- else return true end
	return not IsGov(LocalPlayer():GetPlayerClass())
end

local ang = Angle(0, 90, 90)
local color_white = color_white
local color_black = color_black
function ENT:Draw()
    self:DrawModel()
	local inView, dist = self:InDistance(100000)
	if (not inView) then return end
	local alpha = 255 - (dist/590)
	color_white.a = alpha
	color_black.a = alpha
	local allowed, copCount = isAllowedToRob()
    local Pos = self:GetPos()
    local Ang = self:GetAngles()

	local y = -1250

    ang.y = (LocalPlayer():EyeAngles().y - 90)
    cam.Start3D2D(Pos + Ang:Up() * 5 , ang, 0.06)
		if allowed and self:GetCooldown() == 0 and jobCanRob() then
			draw.SimpleTextOutlined(string.format(BANK_CONFIG.BankString, shizlib.FormatMoney(self:GetHeldMoney()), shizlib.FormatMoney(BANK_CONFIG.Max)), "bank_3d2d", 0, y, BANK_CONFIG.BankStringColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black)
			//76561198092742034
			self.smooth = Lerp(10 * FrameTime(), self.smooth, self:GetHeldMoney() / BANK_CONFIG.Max)
			paintBar(-400, y+80, 800, 50, color_black, BANK_CONFIG.BarColor, self.smooth)

			-- self.progressSmooth = Lerp(10 * FrameTime(), self.progressSmooth, (self:GetDelay() - CurTime()) / BANK_CONFIG.Delay)
			-- paintBar(-400, y+130, 800, 20, color_black, BANK_CONFIG.ProgressColor, math.Remap(self.progressSmooth, 0, 1, 1, 0))
		else
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(restrictedIcon)
			surface.DrawTexturedRect(-50, y+(-50*4), 100, 100)

			local text

			if !allowed then
				text = string.format(BANK_CONFIG.CannotRobCopString, copCount, BANK_CONFIG.MinCopJobs)
			elseif self:GetCooldown() ~= 0 then
				local time = CurTime() - self:GetCooldown()
				time = math.Round(time)
				time = math.abs(time)
				time = math.Clamp(time, 0, BANK_CONFIG.CooldownTime)

				text = string.format(BANK_CONFIG.CooldownString, time)
			elseif !jobCanRob() then
				text = string.format(BANK_CONFIG.CannotRobAsCopString, team.GetName(LocalPlayer():Team()))
			else
				text = "Нельзя грабить"
			end

			draw.SimpleTextOutlined(text, "bank_3d2d", 0, y, BANK_CONFIG.BankStringColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black)
		end
	cam.End3D2D()
end