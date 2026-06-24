local s, DTR = shizlib.surface.s, shizlib.surface.DTR

concommand.Add("acceptorg", function()
    net.Start("Org_AcceptInvite")
    net.SendToServer()
end)

surface.CreateFont("MM_BigNameB", {
  font = "Hitmarker Normal",
  size = ScreenScale( 20 ),
	extended = true,
	--scanlines = 3,
  weight = 700
})

surface.CreateFont("MM_BigName", {
  font = "Hitmarker Normal",
  size = ScreenScale( 14 ),
	extended = true,
	--scanlines = 3,
  weight = 700
})

surface.CreateFont("MM_ESC", {
  font = "Hitmarker Normal",
  size = ScreenScale( 12 ),
	extended = true,
	--scanlines = 3,
  weight = 700
})


surface.CreateFont("MM_RoleName", {
  font = "Hitmarker Normal",
  size = ScreenScale( 10 ),
	extended = true,
	--scanlines = 3,
  weight = 700
})

surface.CreateFont("MM_SmallName", {
  font = "Hitmarker Normal",
  size = ScreenScale( 4 ),
	extended = true,
	--scanlines = 3,
  weight = 700
})

surface.CreateFont("MM_Level", {
  font = "Hitmarker Normal",
  size = ScreenScale( 8 ),
	extended = true,
	--scanlines = 3,
  weight = 300
})

surface.CreateFont("MM_Exp", {
  font = "Hitmarker Normal",
  size = ScreenScale( 7 ),
	extended = true,
	--scanlines = 3,
  weight = 300
})

local clr = color_white
local clr1 = Color( 255, 69, 0 )
local red = Color(255,0,0)

local function BreachVersionIndicator()

	local widthz = ScrW()
	local heightz = ScrH()
    --draw.SimpleText( "Будте осторожны с тратой денег, не покупайте деньги в донате", "shizlib.Label", widthz * 0.5008, heightz * 0.97495, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	--draw.SimpleText( "Проходит Деноминация (Экономика проходит перерасчет прямо сейчас)", "shizlib.Label", widthz * 0.5008, heightz * 0.9895, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
  if LocalPlayer() and LocalPlayer():GetHunger() then
    draw.SimpleText( "Голод : "..LocalPlayer():GetHunger(), "MM_Level", widthz * 0.5, heightz * 0.975, clr1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	  draw.SimpleText( "#Я сейчас это спрячу но пока пусть повесит#", "shizlib.Label", widthz * 0.5, heightz * 0.99, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
  end
end
hook.Remove( "HUDPaintBackground", "BreachVersionIndicator", BreachVersionIndicator )
