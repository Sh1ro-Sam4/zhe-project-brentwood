gpspos = {}
local i = i or 0
function AddGPSPos(pos,time,text,icon)
    local key = text
    gpspos[key] = {p = pos, i = icon}
    
     timer.Create(key .. i, time, 1, function()
        if gpspos[key] ~= nil then
            gpspos[key] = nil
        end
    end)
    i = i + 1
end