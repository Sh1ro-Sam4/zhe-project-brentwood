include('shared.lua')
surface.CreateFont("VendingScreenTitle", {
    font = "Roboto",
    size = 45,
    weight = 800,
    extended = true,
})
surface.CreateFont("VendingScreenInfo", {
    font = "Roboto",
    size = 22,
    weight = 600,
    extended = true,
})
surface.CreateFont("VendingScreenMini", {
    font = "Roboto",
    size = 18,
    weight = 500,
    extended = true,
})
function ENT:Draw()
    self:DrawModel()
    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 100000 then return end
    local oang = self:GetAngles()
    local ang = self:GetAngles()
    ang:RotateAroundAxis(oang:Up(), 90)
    ang:RotateAroundAxis(oang:Right(), -90)
    ang:RotateAroundAxis(oang:Forward(), 0)
    local posX = 17.35    
    local posY = 21.7  
    local posZ = 29    
    local offset = Vector(posX, posY, posZ)
    local pos = self:LocalToWorld(offset)
    cam.Start3D2D(pos, ang, 0.04)   
        local stock = GetGlobalInt("ZAVOD_RATION", 0)
        local isAvailable = stock > 0
        draw.RoundedBox(4, -105, 0, 210, 260, Color(12, 18, 25, 250))
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawOutlinedRect(-105, 0, 210, 260, 2)
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawOutlinedRect(-104, 1, 208, 258, 1)
        local pulse = 150 + math.abs(math.sin(CurTime() * 4)) * 105 
        if isAvailable then
            draw.SimpleText("ГОТОВ К ВЫДАЧЕ", "VendingScreenMini", 0, 25, Color(0, 255, 100, pulse), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("ОШИБКА: ПУСТО", "VendingScreenMini", 0, 25, Color(255, 50, 50, pulse), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        draw.RoundedBox(0, -90, 45, 180, 1, Color(255, 255, 255, 15))
        draw.SimpleText("СТОИМОСТЬ ПОКУПКИ", "VendingScreenMini", 0, 80, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        local priceColor = isAvailable and Color(46, 204, 113) or Color(100, 100, 100)
        draw.SimpleText(shizlib.FormatMoney(30), "VendingScreenTitle", 0, 120, priceColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.RoundedBox(4, -80, 180, 160, 55, Color(0, 0, 0, 180))
        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawOutlinedRect(-80, 180, 160, 55, 1)
        draw.SimpleText("В НАЛИЧИИ:", "VendingScreenMini", 0, 198, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        local stockColor = isAvailable and Color(255, 200, 0) or Color(231, 76, 60)
        draw.SimpleText(stock .. " ШТ.", "VendingScreenInfo", 0, 220, stockColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(0, 0, 0, 60)
        for i = 0, 260, 4 do
            surface.DrawRect(-105, i, 210, 2)
        end
    cam.End3D2D()
end