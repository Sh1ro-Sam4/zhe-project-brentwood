include("shared.lua")
-- include("autorun/shared/bank_config.lua")

surface.CreateFont("bag_3d2d", {
	font = "DermaLarge",
	size = BANK_CONFIG.BagStringSize
})

function ENT:Draw()
	self:DrawModel()
	if self:GetPos():Distance( LocalPlayer():GetPos() ) > 300 then return end
	local pos = self:GetPos()
	local ang = self:GetAngles()

	local time
	if self:GetNWInt("GetTime") - CurTime() > 0 then
		time = self:GetNWInt("GetTime") - CurTime()
	else
		time = 0
	end

	ang:RotateAroundAxis(ang:Forward(), 90)

	cam.Start3D2D(pos + ang:Up() * 4.2, ang, .06)
		-- draw.SimpleTextOutlined(string.format(BANK_CONFIG.BagString, BANK_CONFIG.Distance - math.Round(self:GetVaultPos():Distance(self:GetPos()) / 53)), "bag_3d2d", 0, 0, BANK_CONFIG.BagStringColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black) //76561198092742034
		draw.SimpleTextOutlined( ("Откроется через: %s"):format( string.format("%02d", time) ) , "bag_3d2d", 0, 0, BANK_CONFIG.BagStringColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black) //76561198092742034
	cam.End3D2D()

	ang:RotateAroundAxis(ang:Forward(), 180)
	ang:RotateAroundAxis(ang:Up(), 180)

	cam.Start3D2D(pos + ang:Up() * 4.3, ang, .06)
		draw.SimpleTextOutlined( shizlib.FormatMoney(self:GetMoney()), "bag_3d2d", 0, 0, BANK_CONFIG.BagStringColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black)
	cam.End3D2D()
end