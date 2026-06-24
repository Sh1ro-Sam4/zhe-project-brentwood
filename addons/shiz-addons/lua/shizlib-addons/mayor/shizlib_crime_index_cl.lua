-- shizlib = shizlib or {}

-- shizlib.CrimeIndex = 0

-- net.Receive("shizlib_crime_index_update", function()
--     shizlib.CrimeIndex = net.ReadFloat()
-- end)

-- hook.Remove("HUDPaint", "shizlib_CrimeHUD", function()
--     local scrW, scrH = ScrW(), ScrH()
--     local barWidth = 200
--     local barHeight = 20
--     local x = (scrW / 2) - (barWidth / 2)
--     local y = scrH - 50

--     draw.RoundedBox(0, x, y, barWidth, barHeight, Color(50, 50, 50, 200))
--     draw.RoundedBox(0, x, y, (shizlib.CrimeIndex / 100) * barWidth, barHeight, Color(255, 50, 50, 200))
--     draw.SimpleText("Crime Index: " .. math.Round(shizlib.CrimeIndex), "DermaDefault", x + (barWidth / 2), y + (barHeight / 2), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
-- end)