-- util.AddNetworkString("shizlib_curfew_update")

-- shizlib = shizlib or {}
-- shizlib.CurfewActive = false
-- shizlib.CurfewReason = "No reason specified"
-- function shizlib.ToggleCurfew(active, reason)
--     shizlib.CurfewActive = active
--     shizlib.CurfewReason = reason or "No reason specified"
    
--     net.Start("shizlib_curfew_update")
--         net.WriteBool(shizlib.CurfewActive)
--         net.WriteString(shizlib.CurfewReason)
--     net.Broadcast()
-- end