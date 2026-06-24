-- shizlib = shizlib or {}
-- shizlib.CurfewActive = false
-- shizlib.CurfewReason = ""

-- net.Receive("shizlib_curfew_update", function()
--     shizlib.CurfewActive = net.ReadBool()
--     shizlib.CurfewReason = net.ReadString()
-- end)

-- function shizlib.IsCurfewActive() return shizlib.CurfewActive end
-- function shizlib.GetCurfewReason() return shizlib.CurfewReason end

-- hook.Add("HUDPaint", "shizlib_CurfewHUD", function()
--     if not shizlib.IsCurfewActive() then return end
    
--     local scrW = ScrW()
--     local alpha = (math.sin(RealTime() * 3) + 1) * 127 -- Pulsing effect
    
--     draw.SimpleText("CURFEW ACTIVE", "DermaLarge", scrW / 2, 50, Color(255, 50, 50, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
--     draw.SimpleText("Reason: " .. shizlib.GetCurfewReason(), "DermaDefault", scrW / 2, 80, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
-- end)
