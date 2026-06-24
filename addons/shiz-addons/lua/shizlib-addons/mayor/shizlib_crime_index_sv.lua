-- shizlib = shizlib or {}

-- shizlib.CrimeIndex = 0
-- util.AddNetworkString("shizlib_crime_index_update")

-- function shizlib.AddCrimeIndex(value)
--     shizlib.CrimeIndex = math.Clamp(shizlib.CrimeIndex + value, 0, 100)
--     net.Start("shizlib_crime_index_update")
--         net.WriteFloat(shizlib.CrimeIndex)
--     net.Broadcast()
-- end