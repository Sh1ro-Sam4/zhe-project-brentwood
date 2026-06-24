local draw_SimpleText = draw.SimpleText
local draw_DrawText = draw.DrawText

local black = Color(0, 0, 0, 255)
local white = Color(255, 255, 255, 200)
local red = Color(128, 30, 30, 255)

doorcache = {}
local trace = {}
local offset = Angle(0, 90, 90)

timer.Create("Chifumas_DoorsRefresh", 1, 0, function()
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local doorcount = 0
    doorcache = {}
    for k, v in ipairs(ents.FindInSphere(client:GetPos(), 300)) do
        if not IsValid(v) or not hgIsDoor(v) then continue end
        doorcount = doorcount + 1
        doorcache[doorcount] = v
    end
end)

hook.Add("PostDrawTranslucentRenderables","Door_Draw_3D_Data",function()
    for k, v in ipairs(doorcache) do
        if not IsValid(v) then continue end
        local client = LocalPlayer()
        local pos = v:LocalToWorld(v:OBBCenter())
        pos.z = pos.z + 17.5
        trace.start = client:GetPos() + client:OBBCenter()
        trace.endpos = pos
        trace.filter = client
        local tr = util.TraceLine(trace)
        if tr.Entity ~= v then continue end
        if not v:IsManagedDoor() then continue end
        if pos:DistToSqr(tr.HitPos) > 65 then continue end

        local teams = v:IsDoorForTeamsOnly()
        local owner = v:GetDoorOwnerSID64()
        local name = v:GetDoorDisplayName()
        local costdoor = v:GetDoorPrice()
        local nick = v:GetDoorOwnerName() 
        local coowners = v:GetDoorCoOwners()
        local colnick = color_white

        cam.Start3D2D(tr.HitPos + tr.HitNormal, tr.HitNormal:Angle() + offset, .02)
            draw.SimpleTextOutlined(name, "3d2d", 0, 40, color_white, 1, TEXT_ALIGN_TOP, 1, color_black)

            if owner == "" and not teams then
                nick = "F2 - Арендовать"
                colnick = Color(255,255,51)
                draw.SimpleTextOutlined(nick, "3d2d", 0, 200, colnick, 1, TEXT_ALIGN_TOP, 1, color_black)
                draw.SimpleTextOutlined("$".. (costdoor or "0"), "3d2d", 0, 380, Color(50,200,50), 1, TEXT_ALIGN_TOP, 1, color_black)
            else
                draw.SimpleTextOutlined(nick and nick .. v:GetDoorOwnerId() or nick, "3d2d", 0, 200, colnick, 1, TEXT_ALIGN_TOP, 1, color_black)

                if #coowners > 0 then
                    local coY = 360
                    draw.SimpleTextOutlined("Совладельцы:", "3d2d", 0, coY, colnick, 1, TEXT_ALIGN_TOP, 1, color_black)
                    coY = coY + 160
                    for _, sid in ipairs(coowners) do
                        local p = player.GetBySteamID64(sid)
                        local coName = IsValid(p) and p:Nick() or ""
                        draw.SimpleTextOutlined(coName, "3d2d", 0, coY, Color(200,200,200), 1, TEXT_ALIGN_TOP, 1, color_black)
                        coY = coY + 160
                    end
                end
            end
        cam.End3D2D()
    end
end)